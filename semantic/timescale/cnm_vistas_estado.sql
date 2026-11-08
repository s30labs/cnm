-- =============================================================================
-- ESTADO DE SALUD POR ROL  ·  Hito 02
--
-- ORDEN: DESPUES de cnm_alerts_replica.sql, sem_role_lookup.sql,
--        cnm_vistas_cruzadas.sql y cnm_vistas_intervalos.sql.
--
-- DOS EJES INDEPENDIENTES, que sin separar se confundirian en un solo numero:
--   SALUD      = caidos / evaluables     -> ¿funciona el servicio?
--   FIABILIDAD = evaluables / total      -> ¿cuanto me puedo fiar de esa cifra?
--
--   Un sitio con 4 equipos, 2 sin datos y 2 caidos sale 'down' con fiabilidad
--   0,50. Otro con los 4 medidos y 2 caidos sale 'down' con fiabilidad 1,00.
--   La etiqueta coincide; la confianza en ella, no.
--
-- EL UMBRAL SE APLICA SOBRE LOS EVALUABLES, no sobre el total: no parece
--   razonable diluir el porcentaje con equipos que no se estan midiendo. La
--   contrapartida (un rol con un solo equipo medido llega a 'down' facilmente)
--   queda expuesta en la columna fiabilidad.
--
-- SE DEVUELVE EL PORCENTAJE, no solo la etiqueta: el umbral solo afecta al
--   NOMBRE del estado. Cambiar health_threshold es un UPDATE, sin recalcular
--   nada ni tocar historico.
--
-- LIMITACION HEREDADA: cnm_alerts_store solo tiene alertas CERRADAS. Para el
--   instante presente hara falta --with-open en cnm_ts_sync_alerts.pl. Mientras
--   tanto la funcion es fiable para cualquier momento PASADO.
-- =============================================================================

DROP VIEW IF EXISTS v_role_health_now;
DROP FUNCTION IF EXISTS f_role_health(timestamptz, integer, integer);

CREATE FUNCTION f_role_health(
  p_momento         timestamptz DEFAULT now(),
  p_ventana_icmp_s  integer     DEFAULT 300,   -- 5 min: ICMP sondea cada 1-5 min
  p_ventana_otros_s integer     DEFAULT 900    -- 15 min: el resto de subtipos
)
RETURNS TABLE (
  role_id           text,
  role_display_name text,
  role_type         text,
  criticality       smallint,
  estado            text,
  pct_caidos        numeric,
  fiabilidad        numeric,
  n_total           bigint,
  n_evaluables      bigint,
  n_caidos          bigint,
  n_sin_dato        bigint,
  umbral            numeric,
  dias_alerta_mas_antigua numeric,
  n_alertas_abiertas      bigint
)
LANGUAGE sql STABLE PARALLEL SAFE
AS $$
-- 1. UNIDADES DE AGREGACION con senal primaria de salud (REV-SEM-04).
--
--    La unidad depende del SCOPE del concepto, es decir, de quien es propiedad
--    la metrica. En CNM toda metrica cuelga de un dispositivo por requisito
--    estructural, pero eso no significa que SEA del dispositivo:
--
--      scope = 'device' -> unidad = el DISPOSITIVO
--          El ping de un switch es del switch. Varias instancias del mismo
--          concepto en un equipo estan correlacionadas: si cae el equipo, caen
--          todas. Agruparlas es correcto.
--
--      scope = 'flow' / 'entity' -> unidad = la SENAL (senal_id)
--          El descuadre ICG-SAP se calcula DESDE un servidor, pero podria colgar
--          de otro sin cambiar lo que mide. Sus instancias son independientes
--          entre si: agruparlas por dispositivo destruye informacion.
--
--    Efecto medido en proc.sales_integration.sap_sales (47 senales, 2 equipos):
--    con agregacion por dispositivo, 10 descuadres fallando daban 'healthy'
--    porque los 2 servidores seguian respondiendo. Por senal dan 21,3% degraded.
--
--    Para los emplazamientos NO cambia nada: los conceptos ICMP tienen ~1
--    instancia por dispositivo, y la consolidacion ICMP de REV-SEM-02 ya colapsa
--    la pareja mon_icmp+disp_icmp de cada equipo en una sola senal logica.
--    Son 2.836 bindings, el 76% del total.
--
--    LIMITACION de 'entity': el modelo no tiene identidad de entidad todavia, asi
--    que se agrega igual que 'flow' (por instancia). Un certificado wildcard en
--    cinco equipos sigue contando cinco veces, pero al menos no colapsa por
--    dispositivo. Son 10 bindings: error residual despreciable. Ver REV-SEM-04.
WITH base AS (
  -- Una fila por (rol, senal) con su clave de agregacion ya resuelta.
  SELECT l.role_id, l.role_display_name, l.role_type, l.criticality,
         l.health_threshold, l.is_primary, l.sem_instance_id, m.iddev,
         l.canonical_id, l.scope,
         CASE WHEN l.scope = 'device' THEN 'dev:'  || m.iddev
              ELSE                         'inst:' || l.sem_instance_id END AS unidad_id
  FROM sem_role_lookup l
  JOIN sem_metric_map  m ON m.instance_id = l.sem_instance_id
  WHERE l.signal_class = 'health_sli' AND l.weight > 0
),
dev AS (
  SELECT role_id,
         min(role_display_name) AS nom,
         min(role_type)         AS tipo,
         min(criticality)       AS crit,
         min(health_threshold)  AS thr,
         unidad_id,
         min(iddev)             AS iddev,
         bool_or(canonical_id IN ('net.icmp.latency','net.icmp.availability')) AS es_icmp
  FROM base
  GROUP BY role_id, unidad_id
  -- FILTRO DE PRIMARIA, distinto segun el scope:
  --   device -> exige que el dispositivo tenga una senal primaria. Es la
  --      garantia de REV-SEM-03 A1: una primaria por (rol, dispositivo).
  --   flow / entity -> NO se exige. Con estos scopes la unidad ES la senal, y
  --      is_primary sigue designandose por DISPOSITIVO (REV-SEM-03 A1), de modo
  --      que de 10 descuadres del mismo equipo solo uno la lleva. Exigirla
  --      descartaria las otras nueve y colapsaria la unidad a 1, anulando
  --      justamente lo que REV-SEM-04 persigue.
  --      Todas estas senales son health_sli con weight > 0, asi que su
  --      pertenencia al canal de salud ya esta garantizada.
  HAVING bool_or(is_primary) OR min(scope) <> 'device'
),
-- 2. TODAS las metricas de salud de cada dispositivo. Se miran todas, no solo la
--    de la senal primaria: para decidir "se esta midiendo" basta con que alguna
--    tenga dato. Importa sobre todo en ICMP, donde mon_icmp sondea cada 5 min y
--    con ventana de 5 min podria dar 0 muestras por efecto de borde, mientras que
--    disp_icmp (1 min) da 5.
met AS (
  SELECT DISTINCT d.role_id, d.unidad_id, d.es_icmp, mm.idmetric
  FROM dev d
  JOIN base b          ON b.role_id = d.role_id AND b.unidad_id = d.unidad_id
  JOIN sem_metric_map mm ON mm.instance_id = b.sem_instance_id
),
-- 3. Dispositivos CON dato en su ventana.
--
--    ds = 1 ES IMPRESCINDIBLE. Muchas metricas custom son MULTIVALOR: devuelven
--    varios items en DS distintos, y el ultimo suele ser un codigo de resultado
--    de la propia medida ("0=OK, 1=Connect Error, 2=Timeout, 3=Other"). Medido:
--    1.130 de 1.830 subtipos custom tienen 2-7 DS, y el 86% de los health_sli
--    son multivalor.
--
--    Sin este filtro, un script que falla al conectar puede devolver U (NULL) en
--    el DS 1 -la medida real- y un 1 = Connect Error en el DS 3. Ese 1 es un
--    valor NO nulo, asi que contariamos el dispositivo como "medido" cuando la
--    medicion fallo. Justo lo contrario de lo que queremos.
--
--    v1 (DS 1) es siempre el item principal: es el que referencian todas las
--    expresiones de alerta, y las metricas de estado one-hot llegan ya
--    colapsadas a ds=1 por el loader. Verificado: 0 metricas cuyo DS minimo no
--    sea 1.
--
--    value IS NOT NULL es deliberado: el esquema define value NULL como
--    "medido sin dato" (§4.3), que a efectos de salud es lo mismo que no medir.
--    El primer filtro de tiempo usa la ventana MAYOR para que el planificador
--    pueda excluir chunks; el segundo afina por tipo de senal.
condato AS (
  SELECT DISTINCT me.role_id, me.unidad_id
  FROM met me
  JOIN series s ON s.id_metric = me.idmetric
  WHERE s.time >  p_momento - make_interval(secs => GREATEST(p_ventana_icmp_s, p_ventana_otros_s))
    AND s.time <= p_momento
    AND s.ds = 1                 -- solo la medida principal (ver nota arriba)
    AND s.value IS NOT NULL
    AND s.time >  p_momento - make_interval(
                    secs => CASE WHEN me.es_icmp THEN p_ventana_icmp_s ELSE p_ventana_otros_s END)
),
-- 4. Dispositivos CAIDOS: alerta del canal primario abierta en ese instante.
-- Dispositivos CAIDOS: alerta del canal primario vigente en ese instante.
-- Incluye las AUN ABIERTAS (rango sin fin), sin las cuales un rol que sigue
-- caido hoy apareceria como healthy.
caido AS (
  SELECT i.role_id, l.unidad_id,
         max(EXTRACT(epoch FROM (p_momento - i.started_at))/86400.0) AS dias_mas_antigua,
         count(*) FILTER (WHERE i.abierta)                           AS n_abiertas
  FROM v_alert_intervals i
  JOIN base l ON l.sem_instance_id = i.sem_instance_id AND l.role_id = i.role_id
  WHERE i.canal = 'salud_primaria'
    AND i.rango @> p_momento
  GROUP BY 1,2
),
agg AS (
  SELECT d.role_id, d.nom, d.tipo, d.crit, d.thr,
         count(*)                                              AS n_total,
         count(*) FILTER (WHERE cd.unidad_id IS NOT NULL)       AS n_evaluables,
         count(*) FILTER (WHERE cd.unidad_id IS NOT NULL
                            AND ca.unidad_id IS NOT NULL)       AS n_caidos,
         max(ca.dias_mas_antigua) FILTER (WHERE cd.unidad_id IS NOT NULL) AS dias_ant,
         COALESCE(sum(ca.n_abiertas) FILTER (WHERE cd.unidad_id IS NOT NULL),0) AS n_abiertas
  FROM dev d
  LEFT JOIN condato cd ON cd.role_id = d.role_id AND cd.unidad_id = d.unidad_id
  LEFT JOIN caido   ca ON ca.role_id = d.role_id AND ca.unidad_id = d.unidad_id
  GROUP BY 1,2,3,4,5
)
SELECT a.role_id, a.nom, a.tipo, a.crit,
       CASE
         WHEN a.n_evaluables = 0                        THEN 'unknown'
         WHEN a.n_caidos > a.thr * a.n_evaluables       THEN 'down'
         WHEN a.n_caidos > 0                            THEN 'degraded'
         ELSE                                                'healthy'
       END,
       round(100.0 * a.n_caidos     / NULLIF(a.n_evaluables,0), 2),
       round(100.0 * a.n_evaluables / NULLIF(a.n_total,0),      2),
       a.n_total, a.n_evaluables, a.n_caidos,
       a.n_total - a.n_evaluables,
       a.thr,
       round(a.dias_ant::numeric, 1),
       a.n_abiertas
FROM agg a
ORDER BY CASE WHEN a.n_evaluables = 0 THEN 3
              WHEN a.n_caidos > a.thr * a.n_evaluables THEN 0
              WHEN a.n_caidos > 0 THEN 1 ELSE 2 END,
         a.crit NULLS LAST,
         a.n_caidos DESC;
$$;

COMMENT ON FUNCTION f_role_health(timestamptz, integer, integer) IS
  'Estado de salud por rol en un instante. Dos ejes: SALUD (pct_caidos sobre '
  'evaluables) y FIABILIDAD (evaluables sobre total). El umbral solo afecta a la '
  'etiqueta: pct_caidos es el dato. Ventana ICMP mas corta (5 min) porque su '
  'sondeo es de 1-5 min. Incluye alertas AUN ABIERTAS (requiere --only-open o '
  '--with-open en cnm_ts_sync_alerts.pl): sin ellas un rol caido hoy apareceria '
  'como healthy. dias_alerta_mas_antigua permite distinguir una caida reciente '
  'de una alerta desatendida sin aplicar ninguna politica.';

CREATE VIEW v_role_health_now AS SELECT * FROM f_role_health(now());

\set app_user cnm_loader
GRANT SELECT  ON v_role_health_now TO :app_user;
GRANT EXECUTE ON FUNCTION f_role_health(timestamptz, integer, integer) TO :app_user;
