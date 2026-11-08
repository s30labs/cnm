-- =============================================================================
-- INTERVALOS DE ALERTA POR ROL  ·  Hito 02
--
-- ORDEN: se aplica DESPUES de cnm_alerts_replica.sql y sem_role_lookup.sql.
--   Ampliacion de cnm_vistas_cruzadas.sql (mismas dependencias).
--
-- QUE RESUELVE: pasar de "una fila por alerta" a "tiempo real en alerta por rol
--   y canal", que NO es la suma de duraciones. Si tres metricas de un rol alertan
--   a la vez, sumar cuenta triple. Hay que FUSIONAR los intervalos solapados.
--
-- ALERTAS CERRADAS Y ABIERTAS (actualizado 17-sep-2026, REV-SEM-11):
--   alerts_store solo contiene alertas CERRADAS; las AUN ABIERTAS llegan por
--   cnm_alerts_open, que la replica reemplaza entera cada hora con
--   'cnm_ts_sync_alerts.pl --only-open' (cnm-hourly). Si esa carga deja de
--   ejecutarse, las abiertas se congelan: comprobar max(refreshed_at).
--   Hasta el 16-sep-2026 esa carga no estaba programada y la foto de abiertas
--   era del 8-ago-2026 (REV-SEM-11).
--
-- SEGUNDA LIMITACION: esto mide TIEMPO EN ALERTA, no uptime. Ausencia de alerta
--   no demuestra que se estuviera midiendo. Convertirlo en disponibilidad real
--   exige cruzar con series para saber si habia dato.
--
-- TERCERA: duration esta CUANTIZADA al ciclo de polling (picos en 60/120/180/240 s).
--   Una alerta de 240 s pudo ser un problema de 1 s o de 4 min. En ventanas
--   mensuales se diluye; en ventanas de una hora, no.
--
-- NO TOCA series ni ninguna tabla: solo crea vistas y una funcion de lectura.
-- =============================================================================

DROP VIEW IF EXISTS v_role_alert_time_30d;
DROP VIEW IF EXISTS v_role_alert_time_7d;
DROP FUNCTION IF EXISTS f_role_alert_time(timestamptz, timestamptz);
DROP FUNCTION IF EXISTS f_role_alert_time(timestamptz, timestamptz, integer);
DROP VIEW IF EXISTS v_device_sin_primaria;
DROP VIEW IF EXISTS v_device_alert_time_30d;
DROP FUNCTION IF EXISTS f_device_alert_time(timestamptz, timestamptz, integer);
DROP VIEW IF EXISTS v_alert_intervals;

-- -----------------------------------------------------------------------------
-- 1. VISTA BASE: una fila por alerta evaluable, enriquecida con rol y semantica
--
-- FILTRA lo estructuralmente no evaluable:
--   type NOT IN (snmp,latency,xagent) -> syslog y snmp-trap se cierran a mano,
--       asi que su "duration" mide el tiempo hasta que un operador la cerro, no
--       lo que duro el problema.
--   severity = 4 (azules)             -> "la instancia no responde": ausencia de
--       dato, no fallo del servicio. Corresponde a 'unknown', no a caida.
--   date_epoch IS NULL                -> filas anomalas sin fecha de inicio.
--   id_metric = 0                     -> alerta de dispositivo, sin metrica.
--
-- NO filtra por weight: expone TODO con su peso para que el consumidor decida.
-- Asi la misma vista sirve para calcular salud y para analizar ruido de alertas
-- (hoy el 88% de los eventos caen sobre senales diagnostic, dato valioso en si).
-- -----------------------------------------------------------------------------
-- CONSOLIDACION ICMP (documentacion_producto.md §4.4)
--   mon_icmp (sondeo 5 min, mide latencia) y disp_icmp (sondeo 1 min, mide
--   estado) alertan AMBOS por "no hay respuesta". Cual de los dos se lleva la
--   alerta depende de en que ciclo cayo el fallo: para el alertado significan lo
--   mismo. CNM ya lo consolida internamente registrando ambos como 'mon_icmp'
--   en el campo mname de la tabla de alertas.
--
--   Sin consolidar, marcar is_primary en solo una de las dos reparte eventos
--   IDENTICOS entre dos canales de significado distinto (down vs degraded).
--   Medido en site.es_ai_bcn, dispositivo 1634: la primaria recogio 61 segundos
--   y la secundaria 19,41 dias, siendo la misma condicion fisica.
--
--   bool_or: si CUALQUIERA de la pareja del dispositivo esta marcada como
--   primaria, la senal consolidada del dispositivo es primaria. Preserva la
--   intencion del binding y elimina el reparto arbitrario. Se calcula sobre
--   sem_role_lookup (no sobre las alertas) para que valga aunque en un periodo
--   dado solo haya alertado una de las dos metricas.
CREATE VIEW v_alert_intervals AS
WITH icmp_dev AS (
  SELECT l.role_id, m.iddev,
         bool_or(l.is_primary) AS es_primaria
    FROM sem_role_lookup l
    JOIN sem_metric_map  m ON m.instance_id = l.sem_instance_id
   WHERE l.canonical_id IN ('net.icmp.latency','net.icmp.availability')
   GROUP BY 1,2
)
SELECT
  a.id_alert,
  a.started_at,
  a.ended_at,
  a.duration                                        AS duracion_s,
  tstzrange(a.started_at, a.ended_at, '[)')          AS rango,

  l.role_id,
  l.role_display_name,
  l.role_type,
  l.criticality,
  l.sem_instance_id,
  a.id_metric,
  a.subtype,
  l.canonical_id,                                    -- SIN modificar: auditable
  l.concepto_nombre,                                 -- 'Uso de disco', 'Ping'...
  l.unit,
  l.direction        AS direccion,
  l.signal_class,
  l.is_primary,
  l.weight,

  -- Concepto EFECTIVO tras consolidar la pareja ICMP.
  CASE WHEN l.canonical_id IN ('net.icmp.latency','net.icmp.availability')
       THEN 'net.icmp.availability' ELSE l.canonical_id END AS canonical_efectivo,

  -- SENAL LOGICA: unidad minima de "algo que falla". Para ICMP es el DISPOSITIVO
  -- (sus dos metricas son la misma senal); para el resto, la instancia semantica.
  -- Es la clave de agrupacion de n_incidencias_senal.
  CASE WHEN l.canonical_id IN ('net.icmp.latency','net.icmp.availability')
       THEN 'dev:'||mm.iddev||':icmp'
       ELSE 'inst:'||l.sem_instance_id END AS senal_id,

  mm.iddev,
  a.dev_name,

  a.severity,
  a.type,
  a.label,
  false AS abierta,

  -- CANAL: separa los tres flujos que NO deben fusionarse entre si.
  -- binding.md §6: salud agrega health_sli (primaria 1.00 / secundaria 0.50);
  -- riesgo agrega saturation (0.50). diagnostic/informative no agregan.
  -- Para ICMP usa la primaria CONSOLIDADA del dispositivo (id.es_primaria);
  -- para el resto, el is_primary del binding.
  -- CANAL. Con scope='device' se usa la primaria consolidada del dispositivo.
  -- Con scope='flow'/'entity' TODA senal health_sli es primaria: la unidad de
  -- agregacion es la propia senal (REV-SEM-04), mientras que is_primary se
  -- designa por DISPOSITIVO (REV-SEM-03 A1). De 10 descuadres del mismo equipo
  -- solo uno llevaria is_primary, y los otros 9 caerian a salud_secundaria,
  -- quedando fuera del calculo de 'down'. Seria justo lo contrario de lo que
  -- REV-SEM-04 persigue.
  CASE
    WHEN l.weight = 0 THEN 'no_agrega'
    WHEN l.signal_class = 'health_sli' AND l.scope <> 'device' THEN 'salud_primaria'
    WHEN l.signal_class = 'health_sli'
         AND COALESCE(id.es_primaria, l.is_primary) THEN 'salud_primaria'
    WHEN l.signal_class = 'health_sli'              THEN 'salud_secundaria'
    WHEN l.signal_class = 'saturation'              THEN 'riesgo'
    ELSE 'no_agrega'
  END AS canal
FROM cnm_alerts_store a
JOIN sem_metric_map   mm ON mm.idmetric       = a.id_metric
JOIN sem_role_lookup  l  ON l.sem_instance_id = mm.instance_id
LEFT JOIN icmp_dev    id ON id.role_id = l.role_id AND id.iddev = mm.iddev
WHERE a.type IN ('snmp','latency','xagent')
  AND a.severity <> 4
  AND a.date_epoch IS NOT NULL
  AND a.id_metric > 0

UNION ALL

-- ---------------------------------------------------------------------------
-- ALERTAS AUN ABIERTAS (cnm_alerts_open)
--
-- SIN ESTO, LA SALUD ES FALSA. cnm_alerts_store solo contiene alertas CERRADAS,
-- asi que un rol que sigue caido AHORA no aparece nunca como caido: su alerta
-- esta abierta. Medido en produccion: 250 alertas abiertas de tipos evaluables,
-- 76 de ellas con mas de 30 dias y la mas antigua de 1.584 dias. Todo eso era
-- invisible, y la funcion de estado devolvia 'healthy' sobre emplazamientos que
-- llevaban un mes apagados.
--
-- El intervalo es tstzrange(inicio, NULL) = [inicio, infinito): la alerta sigue
-- vigente. Al intersecarlo con la ventana consultada queda acotado, asi que las
-- sumas de tiempo siguen siendo finitas.
--
-- La columna 'abierta' permite distinguirlas sin aplicar ninguna politica: una
-- caida de 20 minutos y otra de 582 dias se ven distintas sin que la vista
-- decida por el operador cual es "real" y cual esta desatendida.
--
-- EXCLUSION DE LAS YA ARCHIVADAS (REV-SEM-11, aplicado 16-sep-2026). Una alerta
-- puede estar a la vez en cnm_alerts_open y en cnm_alerts_store: la replica lee
-- alerts y alerts_store en instantes distintos mientras notificationsd las mueve
-- cada minuto, y si la foto de abiertas se retrasa, lo que CNM ya cerro sigue en
-- ella. Sin el NOT EXISTS la alerta sale DOS veces (cerrada y abierta con rango
-- infinito) y f_role_health la cuenta como caida para siempre. El 16-sep-2026
-- habia 151 duplicadas y 51 roles no sanos solo por ellas.
-- ---------------------------------------------------------------------------
SELECT
  a.id_alert,
  a.started_at,
  NULL::timestamptz                              AS ended_at,
  EXTRACT(epoch FROM (now() - a.started_at))::int AS duracion_s,
  tstzrange(a.started_at, NULL, '[)')             AS rango,
  l.role_id, l.role_display_name, l.role_type, l.criticality,
  l.sem_instance_id, a.id_metric, a.subtype,
  l.canonical_id, l.concepto_nombre, l.unit, l.direction, l.signal_class,
  l.is_primary, l.weight,
  CASE WHEN l.canonical_id IN ('net.icmp.latency','net.icmp.availability')
       THEN 'net.icmp.availability' ELSE l.canonical_id END,
  CASE WHEN l.canonical_id IN ('net.icmp.latency','net.icmp.availability')
       THEN 'dev:'||mm.iddev||':icmp'
       ELSE 'inst:'||l.sem_instance_id END,
  mm.iddev, a.dev_name,
  a.severity, a.type, a.label,
  true AS abierta,
  CASE
    WHEN l.weight = 0 THEN 'no_agrega'
    WHEN l.signal_class = 'health_sli' AND l.scope <> 'device' THEN 'salud_primaria'
    WHEN l.signal_class = 'health_sli'
         AND COALESCE(id.es_primaria, l.is_primary) THEN 'salud_primaria'
    WHEN l.signal_class = 'health_sli'              THEN 'salud_secundaria'
    WHEN l.signal_class = 'saturation'              THEN 'riesgo'
    ELSE 'no_agrega'
  END
FROM cnm_alerts_open a
JOIN sem_metric_map   mm ON mm.idmetric       = a.id_metric
JOIN sem_role_lookup  l  ON l.sem_instance_id = mm.instance_id
LEFT JOIN icmp_dev    id ON id.role_id = l.role_id AND id.iddev = mm.iddev
WHERE a.type IN ('snmp','latency','xagent')
  AND a.severity <> 4
  AND a.date_epoch IS NOT NULL
  AND a.id_metric > 0
  AND NOT EXISTS (SELECT 1 FROM cnm_alerts_store s WHERE s.id_alert = a.id_alert);

COMMENT ON VIEW v_alert_intervals IS
  'Una fila por alerta evaluable con su rol, canal y semantica. Base de '
  'f_role_alert_time. NO filtra por weight: canal=no_agrega marca lo que no '
  'contribuye a salud ni a riesgo. Alertas cerradas (cnm_alerts_store) y abiertas '
  '(cnm_alerts_open, excluidas las ya archivadas: REV-SEM-11). abierta=true: rango '
  'sin fin. La foto de abiertas se renueva cada hora: ver max(refreshed_at).';

-- -----------------------------------------------------------------------------
-- 2. FUNCION: tiempo FUSIONADO en alerta por rol y canal dentro de una ventana
--
-- EL NUCLEO DEL CALCULO es range_agg: agrega los intervalos de cada
-- (rol, canal) en un multirango que FUSIONA automaticamente los solapes. Sumar
-- duraciones daria un resultado sin sentido (tres metricas en alerta a la vez
-- durante una hora no son tres horas de caida).
--
-- El operador '*' interseca cada intervalo con la ventana pedida, de modo que
-- una alerta que empieza antes o acaba despues aporta solo su parte dentro.
--
-- Funcion y no vista porque la ventana es un parametro. STABLE + PARALLEL SAFE
-- para que el planificador la trate bien.
-- -----------------------------------------------------------------------------
-- p_tolerancia_s: dos alertas separadas por MENOS de este margen se tratan como
--   una sola incidencia. Motivo: CNM cierra y reabre la alerta cuando cambia algo
--   de la metrica, dejando varios registros de un unico incidente continuo.
--   Caso real medido (site.es_ai_bcn): una caida de 55,5 dias quedo partida en 4
--   alertas separadas por huecos de 61 s, 34 s y 61 s -- un ciclo de polling.
--   Los huecos sumaban 2,6 minutos, el 0,0033% del periodo.
--   El tiempo total NO cambia con la tolerancia; lo que cambia es n_incidencias,
--   que sin ella cuenta 4 fallos donde hubo 1.
--   Por defecto 300 s = 5 min, holgado frente al ciclo de polling mas largo (4 min).
--   Con 0 se desactiva la reagrupacion.
CREATE FUNCTION f_role_alert_time(p_desde timestamptz, p_hasta timestamptz,
                                  p_tolerancia_s integer DEFAULT 300)
RETURNS TABLE (
  role_id            text,
  role_display_name  text,
  role_type          text,
  criticality        smallint,
  canal              text,
  segundos_en_alerta   numeric,
  pct_ventana          numeric,
  n_incidencias_rol    bigint,
  n_incidencias_senal  bigint,
  n_alertas            bigint,
  n_metricas           bigint,
  n_senales            bigint
)
LANGUAGE sql STABLE PARALLEL SAFE
AS $$
WITH ventana AS (
  SELECT tstzrange(p_desde, p_hasta, '[)') AS v,
         EXTRACT(epoch FROM (p_hasta - p_desde))::numeric AS segs
),
-- Recuentos ANTES de fusionar: cuantas alertas y cuantas metricas distintas
-- contribuyeron. Se pierden al fusionar, y son utiles para diagnostico.
crudo AS (
  SELECT i.role_id, i.role_display_name, i.role_type, i.criticality, i.canal,
         count(*)                     AS n_alertas,
         count(DISTINCT i.id_metric)  AS n_metricas,
         count(DISTINCT i.senal_id)   AS n_senales
  FROM v_alert_intervals i, ventana w
  WHERE i.canal <> 'no_agrega'
    AND i.rango && w.v
  GROUP BY 1,2,3,4,5
),
-- DOS RECUENTOS DE INCIDENCIAS, porque miden cosas distintas y ambas son
-- legitimas (ninguna cifra unica responde bien a las dos preguntas):
--
--   n_incidencias_rol   -> "¿cuantas veces estuvo AFECTADO EL SERVICIO?"
--       Fusiona a nivel de rol. Un corte de WAN que tumba 5 equipos a la vez es
--       UN incidente para el negocio. Es la cifra de cara al usuario del rol.
--
--   n_incidencias_senal -> "¿cuantos FALLOS hubo?"
--       Fusiona por senal logica (dispositivo en ICMP, instancia en el resto).
--       Ese mismo corte de WAN son 5 fallos. Es la cifra para MTBF y para saber
--       que equipo falla mas. NUNCA fusiona eventos independientes.
--
-- Con dos dispositivos alternandose (caso site.es_ai_bcn) la primera dira "el
-- sitio tuvo problemas casi continuamente" y la segunda "hubo N incidentes
-- repartidos entre dos equipos". Las dos son ciertas.
--
-- FUSION EN DOS PASOS.
--   Paso 1: range_agg une los intervalos SOLAPADOS (tiempo real, sin contar
--           dos veces lo simultaneo). De aqui sale segundos_en_alerta.
--   Paso 2: sobre esos intervalos ya fusionados, se cuentan como UNA incidencia
--           los que estan separados por menos de p_tolerancia_s. De aqui sale
--           n_incidencias. El tiempo NO se altera: solo se agrupa el recuento.
-- (a) Fusion a nivel de ROL: de aqui salen el TIEMPO y n_incidencias_rol.
fus_rol AS (
  SELECT i.role_id, i.canal,
         unnest(range_agg(i.rango * w.v)) AS r
  FROM v_alert_intervals i, ventana w
  WHERE i.canal <> 'no_agrega' AND i.rango && w.v
  GROUP BY i.role_id, i.canal
),
cortes_rol AS (
  SELECT role_id, canal, r,
         CASE WHEN lag(upper(r)) OVER (PARTITION BY role_id, canal ORDER BY lower(r))
                   IS NULL
               OR lower(r) - lag(upper(r)) OVER (PARTITION BY role_id, canal
                                                 ORDER BY lower(r))
                  > make_interval(secs => p_tolerancia_s)
              THEN 1 ELSE 0 END AS nueva
  FROM fus_rol
),
tot_rol AS (
  SELECT role_id, canal,
         sum(EXTRACT(epoch FROM (upper(r) - lower(r))))::numeric AS segundos,
         sum(nueva)::bigint                                      AS n_inc_rol
  FROM cortes_rol GROUP BY role_id, canal
),
-- (b) Fusion por SENAL LOGICA: de aqui sale n_incidencias_senal. El tiempo de
--     esta rama NO se usa (sumarlo contaria doble lo simultaneo).
fus_senal AS (
  SELECT i.role_id, i.canal, i.senal_id,
         unnest(range_agg(i.rango * w.v)) AS r
  FROM v_alert_intervals i, ventana w
  WHERE i.canal <> 'no_agrega' AND i.rango && w.v
  GROUP BY i.role_id, i.canal, i.senal_id
),
cortes_senal AS (
  SELECT role_id, canal, senal_id,
         CASE WHEN lag(upper(r)) OVER (PARTITION BY role_id, canal, senal_id
                                       ORDER BY lower(r)) IS NULL
               OR lower(r) - lag(upper(r)) OVER (PARTITION BY role_id, canal, senal_id
                                                 ORDER BY lower(r))
                  > make_interval(secs => p_tolerancia_s)
              THEN 1 ELSE 0 END AS nueva
  FROM fus_senal
),
tot_senal AS (
  SELECT role_id, canal, sum(nueva)::bigint AS n_inc_senal
  FROM cortes_senal GROUP BY role_id, canal
)
SELECT c.role_id, c.role_display_name, c.role_type, c.criticality, c.canal,
       t.segundos,
       round(100 * t.segundos / NULLIF(w.segs,0), 4) AS pct_ventana,
       t.n_inc_rol, s.n_inc_senal,
       c.n_alertas, c.n_metricas, c.n_senales
FROM crudo c
JOIN tot_rol   t ON t.role_id = c.role_id AND t.canal = c.canal
JOIN tot_senal s ON s.role_id = c.role_id AND s.canal = c.canal
CROSS JOIN ventana w
ORDER BY t.segundos DESC;
$$;

COMMENT ON FUNCTION f_role_alert_time(timestamptz, timestamptz, integer) IS
  'Tiempo FUSIONADO en alerta por rol y canal en una ventana. Los intervalos '
  'solapados se unen (range_agg): NO es la suma de duraciones. n_incidencias '
  'reagrupa los tramos separados por menos de p_tolerancia_s (CNM parte un '
  'unico incidente en varias alertas al reabrirlas). Dos recuentos: _rol '
  '(cuantas veces se vio afectado el servicio) y _senal (cuantos fallos hubo, '
  'por dispositivo/instancia). Solo alertas cerradas; mide tiempo, no uptime.';

-- -----------------------------------------------------------------------------
-- 3. Vistas de conveniencia para las ventanas habituales
-- -----------------------------------------------------------------------------
CREATE VIEW v_role_alert_time_7d AS
  SELECT * FROM f_role_alert_time(now() - interval '7 days', now());

CREATE VIEW v_role_alert_time_30d AS
  SELECT * FROM f_role_alert_time(now() - interval '30 days', now());

-- =============================================================================
-- 4. SALUD POR DISPOSITIVO  (NIVEL 1 del modelo de dos niveles)
--
-- POR QUE EXISTE: is_primary designa UNA senal por rol (binding.md §6), lo que
--   asume que el rol tiene un unico punto de entrada. Falso para el 47,3% de los
--   roles con senal de salud (201 de 425): sitios remotos con varios equipos,
--   parejas router principal+backup, flotas de terminales de pago (hasta 100
--   dispositivos en un solo rol).
--
--   La salida es separar dos niveles:
--     NIVEL 1 (esto)  -> salud de CADA DISPOSITIVO. Objetivo, sin decisiones.
--     NIVEL 2 (futuro)-> politica de agregacion que combina los dispositivos
--                        para dar la salud del ROL (redundante / todos_criticos
--                        / umbral / designada). Ver REV-SEM-03.
--
-- ESTE NIVEL NO DEPENDE DE LA POLITICA: es util por si mismo ("que equipos han
--   fallado mas este mes") y es el insumo de todas las politicas. Cuando se
--   decida el nivel 2, se construye encima sin rehacer nada de aqui.
-- =============================================================================
CREATE FUNCTION f_device_alert_time(p_desde timestamptz, p_hasta timestamptz,
                                    p_tolerancia_s integer DEFAULT 300)
RETURNS TABLE (
  role_id            text,
  iddev              bigint,
  dev_name           text,
  canal              text,
  segundos_en_alerta numeric,
  pct_ventana        numeric,
  n_incidencias      bigint,
  n_alertas          bigint,
  n_senales          bigint
)
LANGUAGE sql STABLE PARALLEL SAFE
AS $$
WITH ventana AS (
  SELECT tstzrange(p_desde, p_hasta, '[)') AS v,
         EXTRACT(epoch FROM (p_hasta - p_desde))::numeric AS segs
),
crudo AS (
  SELECT i.role_id, i.iddev,
         max(i.dev_name)              AS dev_name,   -- puede variar si se renombro
         i.canal,
         count(*)                     AS n_alertas,
         count(DISTINCT i.senal_id)   AS n_senales
  FROM v_alert_intervals i, ventana w
  WHERE i.canal <> 'no_agrega' AND i.rango && w.v
  GROUP BY 1,2,4
),
-- Fusion a nivel de DISPOSITIVO: las senales simultaneas del mismo equipo no
-- cuentan dos veces (un equipo caido puede alertar por ICMP y por disco a la vez).
fus AS (
  SELECT i.role_id, i.iddev, i.canal,
         unnest(range_agg(i.rango * w.v)) AS r
  FROM v_alert_intervals i, ventana w
  WHERE i.canal <> 'no_agrega' AND i.rango && w.v
  GROUP BY i.role_id, i.iddev, i.canal
),
cortes AS (
  SELECT role_id, iddev, canal, r,
         CASE WHEN lag(upper(r)) OVER (PARTITION BY role_id, iddev, canal
                                       ORDER BY lower(r)) IS NULL
               OR lower(r) - lag(upper(r)) OVER (PARTITION BY role_id, iddev, canal
                                                 ORDER BY lower(r))
                  > make_interval(secs => p_tolerancia_s)
              THEN 1 ELSE 0 END AS nueva
  FROM fus
),
tot AS (
  SELECT role_id, iddev, canal,
         sum(EXTRACT(epoch FROM (upper(r) - lower(r))))::numeric AS segundos,
         sum(nueva)::bigint                                      AS n_inc
  FROM cortes GROUP BY 1,2,3
)
SELECT c.role_id, c.iddev, c.dev_name, c.canal,
       t.segundos,
       round(100 * t.segundos / NULLIF(w.segs,0), 4) AS pct_ventana,
       t.n_inc, c.n_alertas, c.n_senales
FROM crudo c
JOIN tot t ON t.role_id=c.role_id AND t.iddev=c.iddev AND t.canal=c.canal
CROSS JOIN ventana w
ORDER BY t.segundos DESC;
$$;

COMMENT ON FUNCTION f_device_alert_time(timestamptz, timestamptz, integer) IS
  'NIVEL 1 del modelo de salud: tiempo en alerta por DISPOSITIVO, rol y canal. '
  'No depende de ninguna politica de agregacion: es el insumo objetivo sobre el '
  'que se construira la salud del rol (ver REV-SEM-03).';

CREATE VIEW v_device_alert_time_30d AS
  SELECT * FROM f_device_alert_time(now() - interval '30 days', now());

-- Cobertura de primaria por dispositivo: los equipos que HOY no pueden producir
-- un estado 'down' porque ninguna de sus senales esta marcada como primaria.
-- Con la regla actual (una primaria por ROL) esto es lo esperable en cuanto un
-- rol tiene mas de un dispositivo. Hace visible el alcance del problema.
CREATE VIEW v_device_sin_primaria AS
SELECT l.role_id, l.role_type, m.iddev,
       count(*)                                        AS senales_salud,
       count(*) FILTER (WHERE l.is_primary)            AS primarias
FROM sem_role_lookup l
JOIN sem_metric_map  m ON m.instance_id = l.sem_instance_id
WHERE l.signal_class = 'health_sli' AND l.weight > 0
GROUP BY 1,2,3
HAVING count(*) FILTER (WHERE l.is_primary) = 0;

-- Permisos: ajustar el rol si no es cnm_loader.
\set app_user cnm_loader
GRANT SELECT  ON v_alert_intervals, v_role_alert_time_7d, v_role_alert_time_30d,
                 v_device_alert_time_30d, v_device_sin_primaria TO :app_user;
GRANT EXECUTE ON FUNCTION f_device_alert_time(timestamptz, timestamptz, integer) TO :app_user;
GRANT EXECUTE ON FUNCTION f_role_alert_time(timestamptz, timestamptz, integer) TO :app_user;
