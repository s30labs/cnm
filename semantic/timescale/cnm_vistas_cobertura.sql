-- ═══════════════════════════════════════════════════════════════════════════
-- >> EJECUTAR   ·   Orden de aplicacion: 9 de 10
-- Cuadro de control del modelo. Usa vistas de los pasos anteriores.
-- Instalacion desde cero: ejecutar los ficheros por su numero de orden.
-- Instalacion en marcha: ver DOC-SEM-00 'Como se anade una columna a la replica'.
-- ═══════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- COBERTURA SEMANTICA · el cuadro de control del modelo
--
-- ORDEN: DESPUES de sem_role_lookup.sql y cnm_vistas_cruzadas.sql.
--
-- POR QUE EXISTE. El Hito 01 prometia "paneles para vigilar la propia salud del
-- sistema". Lo que habia eran vistas SQL dispersas -y algunas ni existian en CNM,
-- solo en la capa analitica-, asi que en la practica nadie las miraba: hay que ir
-- a buscarlas una por una.
--
-- Esto las reune en dos vistas pensadas para volcarse a CSV y revisarse
-- periodicamente, con la misma logica que el informe de capacidad: si no se puede
-- entregar en un fichero, no se consulta.
--
-- v_cobertura_resumen  -> una fila por indicador, con su valor y si esta bien
-- v_cobertura_huecos   -> el detalle accionable: QUE hay que arreglar
-- =============================================================================

-- DROPs en orden INVERSO-- DROPs en orden INVERSO de dependencia: v_cobertura_resumen consulta
-- v_roles_con_equipos_inactivos, asi que hay que soltarla primero.
DROP VIEW IF EXISTS v_cobertura_huecos;
DROP VIEW IF EXISTS v_cobertura_resumen;
DROP VIEW IF EXISTS v_roles_con_equipos_inactivos;
DROP VIEW IF EXISTS v_senales_estancadas;

-- -----------------------------------------------------------------------------
-- 1. RESUMEN · un indicador por fila
--
-- Cada fila lleva 'estado' calculado, para que el CSV se pueda leer sin conocer
-- los umbrales. Los umbrales son criterio, no verdad: se documentan aqui.
-- -----------------------------------------------------------------------------
-- 3. IMPACTO DE LOS DISPOSITIVOS NO ACTIVOS
--
-- devices.status: 0=activo · 1=de baja (sin polling) · 2=mantenimiento
--
-- El estado 2 es el problematico y no es evidente: esos equipos SI se sondean
-- -asi que tienen datos y cuentan como unidades evaluables- pero NO alertan, de
-- modo que jamas apareceran como caidos. Salen sanos por construccion.
--
-- Medido en agosto de 2026: 659 equipos en mantenimiento, el 40% del parque.
-- Un rol con 10 equipos, 6 de ellos en mantenimiento, mostraria fiabilidad del
-- 100% y como mucho un 40% de afectacion aunque estuviera todo caido.
--
-- Esta vista NO corrige nada: cuantifica el problema para poder decidir.
-- Ver REV-SEM-05.
-- -----------------------------------------------------------------------------
-- 4. SENALES SIN ACTIVIDAD · indicador de mantenimiento de los datos
--
-- Detecta metricas que ya no miden nada util. NO es un fallo del sistema: es
-- RESIDUO. El sistema mide correctamente algo que dejo de tener sentido.
--
-- HISTORIA DE ESTE INDICADOR, que explica su forma actual. Nacio como "valor
-- constante en 30 dias" con una LISTA de conceptos excluidos, y esa lista no
-- tenia criterio:
--   - se excluyo net.icmp.availability porque daba 300 falsos positivos
--   - pero flow.job.status, igual de "estado binario", se quedo dentro por
--     casualidad, no por diseño
--   - y 'direction' tampoco discrimina: net.icmp.availability,
--     svc.db.query_status y flow.job.status son los tres out_of_band, y la
--     constancia significa cosas opuestas en cada uno
--
-- Se sustituye por DOS CRITERIOS DERIVADOS del funcionamiento del producto.
-- Ver REV-SEM-07 §5.
--
-- CRITERIO 1 · metrica multivalor con TODOS los DS a 0.
--   Las metricas de estado usan la funcion MAP de CNM (cfg_monitor_*.esp), que
--   declara N estados excluyentes donde EXACTAMENTE UNO vale 1. Si todos valen
--   0, no hay estado y por tanto no hay actividad.
--   Validado: detecta los mismos 4 jobs huerfanos de app.bi que se identifican
--   por "su id ya no esta en la tabla de origen". Dos vias, mismo resultado.
--
-- CRITERIO 2 · metrica que solo produce NULL.
--   Las filas existen pero sin valor: el sondeo se ejecuta y no obtiene nada.
--   Se excluyen net.icmp.latency y svc.tcpip.latency, y aqui SI hay razon: si
--   un equipo no responde, su latencia es nula POR DEFINICION y la
--   disponibilidad ya lo señala. Medido: los 90 equipos activos con latencia
--   nula no responden ninguno.
--
-- LO QUE NO DETECTA, y no es subsanable aqui: un job que sigue en la tabla de
-- origen pero lleva meses sin ejecutarse. Su ultimo estado persiste como OK, asi
-- que la metrica reporta actividad normal. La marca de tiempo que lo delataria
-- (date_end) NO llega a la capa analitica. Ver REV-SEM-07 §2.
-- -----------------------------------------------------------------------------
CREATE VIEW v_senales_estancadas AS
-- RENDIMIENTO · tres versiones hicieron falta. Se documenta para no repetirlas:
--   v1) un LATERAL por senal -> ~3.700 escaneos independientes de series
--   v2) sem_metric_map unido DOS veces -> 758.121 ejecuciones del join, 21 s
--   v3) leer del CRUDO -> 29,6 s solo en el CTE de actividad, con 1.069.775
--       bloques leidos de disco (~8 GB)
--
-- Esta version lee de series_1h: 13 veces menos filas y comprimido. Para saber
-- si un DS se activo ALGUNA VEZ en 30 dias, el maximo horario sirve igual que el
-- crudo -max(max_value) es el mismo valor-, asi que no se pierde precision.
--
-- Y el criterio 2 se resuelve POR AUSENCIA: series_1h solo materializa buckets
-- con al menos una muestra NO NULA (la columna n cuenta no nulos). Si una
-- metrica no aparece alli en 30 dias, no ha producido ni un valor.
WITH senal AS MATERIALIZED (
  SELECT m.idmetric, m.dev_name, m.metric_label, (m.monitor IS NOT NULL) AS tiene_monitor,
         l.role_id, l.role_display_name, l.role_type,
         l.canonical_id, l.concepto_nombre, l.is_primary
    FROM sem_role_lookup l
    JOIN sem_metric_map  m ON m.instance_id = l.sem_instance_id
   WHERE l.signal_class = 'health_sli' AND l.weight > 0
),
act AS MATERIALIZED (
  SELECT h.id_metric,
         count(DISTINCT h.ds) AS n_ds,
         sum(h.n)             AS muestras,
         max(h.max_value)     AS mx
    FROM series_1h h
   WHERE h.id_metric IN (SELECT idmetric FROM senal)
     AND h.bucket > now() - interval '30 days'
   GROUP BY 1
)
SELECT x.role_id, x.role_display_name, x.role_type,
       x.dev_name, x.metric_label, x.canonical_id, x.concepto_nombre,
       CASE WHEN a.id_metric IS NULL THEN 'sin ningun valor: solo NULL'
            ELSE 'ningun DS se activa nunca' END AS motivo,
       COALESCE(a.n_ds, 0)                       AS detalle_num,
       COALESCE(a.muestras, 0)                   AS muestras,
       x.is_primary,
       x.tiene_monitor
FROM senal x
LEFT JOIN act a ON a.id_metric = x.idmetric
WHERE (
      -- CRITERIO 1 · ningun DS se activa nunca, con datos suficientes.
      --   Vale para metricas de 1 DS y de N. Una version anterior exigia
      --   n_ds >= 2 y por eso NO detectaba los 4 jobs huerfanos de app.bi, que
      --   solo tienen el DS de 'OK'. Fue una regresion.
      (a.id_metric IS NOT NULL AND a.muestras > 1000 AND a.mx = 0)
      OR
      -- CRITERIO 2 · la metrica no produce NINGUN valor.
      --   Se excluyen latencia ICMP y TCP: si un equipo no responde, su latencia
      --   es nula POR DEFINICION y la disponibilidad ya lo señala. Medido: los
      --   90 equipos activos con latencia nula no responden ninguno.
      (a.id_metric IS NULL
       AND x.canonical_id NOT IN ('net.icmp.latency','svc.tcpip.latency'))
)
ORDER BY x.role_id, x.metric_label;

COMMENT ON VIEW v_senales_estancadas IS
  'Indicador de MANTENIMIENTO DE LOS DATOS: metricas que ya no miden nada util. '
  'Dos criterios: ningun DS se activa nunca (max=0), y metricas que no aparecen '
  'en series_1h (no producen ningun valor). Lee del agregado horario por '
  'rendimiento. NO detecta jobs parados que conservan su estado: ver REV-SEM-07.';





-- -----------------------------------------------------------------------------

CREATE VIEW v_roles_con_equipos_inactivos AS
WITH u AS (
  SELECT l.role_id,
         min(l.role_display_name)  AS role_display_name,
         min(l.role_type)          AS role_type,
         min(l.criticality)        AS criticality,
         m.iddev,
         min(m.dev_name)           AS dev_name,
         min(m.dev_status)         AS dev_status
  FROM sem_role_lookup l
  JOIN sem_metric_map  m ON m.instance_id = l.sem_instance_id
  WHERE l.signal_class = 'health_sli' AND l.weight > 0
  GROUP BY l.role_id, m.iddev
)
SELECT role_id, min(role_display_name) AS role_display_name,
       min(role_type) AS role_type, min(criticality) AS criticality,
       count(*)                                        AS equipos,
       count(*) FILTER (WHERE dev_status = 0)          AS activos,
       count(*) FILTER (WHERE dev_status = 1)          AS de_baja,
       count(*) FILTER (WHERE dev_status = 2)          AS en_mantenimiento,
       -- Porcentaje del rol que NO puede reflejar una caida: los de baja porque
       -- no se sondean, los de mantenimiento porque no alertan.
       round(100.0 * count(*) FILTER (WHERE dev_status <> 0) / count(*), 1)
                                                       AS pct_ciego,
       string_agg(dev_name, ', ') FILTER (WHERE dev_status = 2) AS equipos_mantenimiento
FROM u
GROUP BY role_id
HAVING count(*) FILTER (WHERE dev_status <> 0) > 0
ORDER BY round(100.0 * count(*) FILTER (WHERE dev_status <> 0) / count(*), 1) DESC,
         min(criticality) NULLS LAST;

COMMENT ON VIEW v_roles_con_equipos_inactivos IS
  'Roles con equipos de baja o en mantenimiento. pct_ciego = porcentaje del rol '
  'que NO puede reflejar una caida. Un rol al 100% de pct_ciego siempre saldra '
  'sano, este como este.';

-- -----------------------------------------------------------------------------
CREATE VIEW v_cobertura_resumen AS
WITH ind AS (
  -- Cobertura de clasificacion ------------------------------------------------
  -- Metricas en el mapa: una fila por metrica viva con binding ACTIVO.
  -- NO confundir con los bindings: una instancia puede tener varias metricas,
  -- y un binding es una pareja (instancia, rol).
  SELECT 1::numeric AS orden, 'Clasificacion' AS bloque,
         'Metricas en el mapa semantico' AS indicador,
         count(*)::numeric                            AS valor,
         NULL::numeric                                AS total,
         NULL::numeric                                AS umbral_min,
         'metricas'                                   AS unidad
    FROM sem_metric_map

  UNION ALL
  SELECT 2, 'Clasificacion', 'Ataduras metrica-rol (bindings)',
         count(*), NULL, NULL, 'bindings'
    FROM sem_role_lookup

  UNION ALL
  SELECT 3, 'Clasificacion', 'Dispositivos con rol de negocio',
         count(DISTINCT m.iddev), NULL, NULL, 'dispositivos'
    FROM sem_metric_map m JOIN sem_role_lookup l ON l.sem_instance_id = m.instance_id

  UNION ALL
  -- OJO: solo cuenta los roles PRESENTES en la replica, es decir, los que tienen
  -- al menos un binding. Los roles del maestro sin ninguna atadura NO llegan a
  -- Timescale, asi que este numero no es el tamano del catalogo.
  SELECT 4, 'Clasificacion', 'Roles presentes en la replica',
         count(DISTINCT role_id), NULL, NULL, 'roles'
    FROM sem_role_lookup

  -- Cobertura de alertas -----------------------------------------------------
  UNION ALL
  SELECT 5, 'Alertas', 'Alertas que llegan a un rol (%)',
         pct_llegan_a_rol, 100, 40, '%'
    FROM v_alertas_cobertura_rol

  UNION ALL
  SELECT 6, 'Alertas', 'Alertas sin metrica asociada',
         sin_metrica, alertas_evaluables, NULL, 'alertas'
    FROM v_alertas_cobertura_rol

  UNION ALL
  SELECT 7, 'Alertas', 'Alertas cuya metrica no esta en el mapa',
         sin_mapa, alertas_evaluables, NULL, 'alertas'
    FROM v_alertas_cobertura_rol

  -- Integridad del modelo · TODOS deben ser 0 --------------------------------
  UNION ALL
  SELECT 8, 'Integridad', 'Dispositivos que no pueden reflejar una caida',
         count(*), NULL, NULL, 'dispositivos'
    FROM v_device_sin_primaria

  UNION ALL
  SELECT 9, 'Integridad', 'Bindings con peso incoherente con su clase',
         COALESCE(sum(bindings), 0), NULL, NULL, 'bindings'
    FROM v_sem_peso_incoherente

  UNION ALL
  SELECT 10, 'Integridad', 'Alertas con identidad de metrica incoherente',
         count(*), NULL, NULL, 'alertas'
    FROM v_alertas_canario_identidad

  UNION ALL
  SELECT 11, 'Integridad', 'Instancias atadas a mas de un rol',
         count(*), NULL, NULL, 'instancias'
    FROM v_sem_multirole

  -- Vigilancia efectiva -------------------------------------------------------
  -- Un rol 'ciego total' muestra healthy de forma permanente porque ninguno de
  -- sus equipos puede alertar. Es peor que no monitorizarlo: transmite confianza
  -- infundada. Ver REV-SEM-05.
  UNION ALL
  SELECT 12, 'Vigilancia', 'Roles que NUNCA podran salir caidos',
         count(*), NULL, NULL, 'roles'
    FROM v_roles_con_equipos_inactivos WHERE pct_ciego = 100

  UNION ALL
  SELECT 13, 'Vigilancia', 'Roles con mas de la mitad sin vigilancia',
         count(*), NULL, NULL, 'roles'
    FROM v_roles_con_equipos_inactivos WHERE pct_ciego >= 50 AND pct_ciego < 100

  -- Mantenimiento de los datos ------------------------------------------------
  -- No es un fallo del sistema: es residuo acumulado en el inventario.
  UNION ALL
  SELECT 13.5, 'Mantenimiento', 'Senales que deberian variar y llevan 30 dias sin hacerlo',
         count(*), NULL, NULL, 'senales'
    FROM v_senales_estancadas

  -- Frescura de la replica ---------------------------------------------------
  UNION ALL
  SELECT 14, 'Frescura', 'Horas desde la ultima sincronizacion semantica',
         round(EXTRACT(epoch FROM antiguedad)/3600, 1), NULL, NULL, 'horas'
    FROM v_sem_lookup_freshness
)
SELECT bloque, indicador, valor, total, unidad,
       CASE WHEN total IS NOT NULL
            THEN round(100.0 * valor / NULLIF(total,0), 2) END AS pct,
       -- ESTADO. Los umbrales son criterio explicito:
       --   Integridad -> cualquier valor > 0 es un problema
       --   Cobertura de alertas -> por debajo del 40% el modelo cubre poco
       --   Frescura -> mas de 26 h significa que el sync no corre (es horario)
       CASE
         WHEN bloque = 'Integridad'  AND valor > 0                    THEN 'REVISAR'
         WHEN bloque = 'Integridad'                                    THEN 'ok'
         -- Un solo rol ciego ya merece atencion: muestra verde permanente.
         WHEN bloque = 'Vigilancia'  AND valor > 0                     THEN 'REVISAR'
         WHEN bloque = 'Vigilancia'                                    THEN 'ok'
         -- Mantenimiento: siempre habra algo de residuo. El umbral marca
         -- cuando deja de ser normal y pasa a ser acumulacion.
         WHEN bloque = 'Mantenimiento' AND valor > 50                  THEN 'REVISAR'
         WHEN bloque = 'Mantenimiento'                                 THEN 'ok'
         WHEN umbral_min IS NOT NULL AND valor < umbral_min            THEN 'REVISAR'
         WHEN indicador LIKE 'Horas desde%' AND valor > 26             THEN 'REVISAR'
         ELSE 'ok'
       END                                                            AS estado
FROM ind
ORDER BY orden;

COMMENT ON VIEW v_cobertura_resumen IS
  'Cuadro de control del modelo semantico: un indicador por fila con su estado '
  'ya calculado. Los del bloque Integridad deben dar 0.';

-- -----------------------------------------------------------------------------
-- 2. HUECOS · el detalle accionable
--
-- No repite el resumen: dice QUE hay que arreglar y de quien es. Cada fila es
-- una accion posible.
-- -----------------------------------------------------------------------------
CREATE VIEW v_cobertura_huecos AS
-- Roles sin ninguna metrica atada: apareceran siempre como 'sin datos'
-- OJO: solo ve los roles que estan en la replica. Los del maestro sin ninguna
-- atadura no llegan a Timescale: para auditarlos hay que consultar CNM.
SELECT 'Rol en la replica sin metricas con peso' AS hueco,
       l.role_id                                 AS elemento,
       l.role_display_name                       AS nombre,
       l.role_type                               AS tipo,
       NULL::text                                AS detalle,
       'Instrumentar o archivar el rol'          AS accion
FROM (SELECT DISTINCT role_id, role_display_name, role_type FROM sem_role_lookup) l
WHERE NOT EXISTS (SELECT 1 FROM sem_role_lookup x
                   WHERE x.role_id = l.role_id AND x.weight > 0)

UNION ALL
-- Roles de negocio sin senal de salud: no se puede saber si funcionan
SELECT 'Rol de negocio sin senal de salud',
       l.role_id, min(l.role_display_name), min(l.role_type),
       count(*)::text || ' metricas, ninguna de salud',
       'Vincular un KPI de resultado'
FROM sem_role_lookup l
WHERE l.role_type IN ('business_process','business_subprocess')
GROUP BY l.role_id
HAVING count(*) FILTER (WHERE l.signal_class = 'health_sli' AND l.weight > 0) = 0

UNION ALL
-- Metricas de saturacion sin capacidad: no se puede calcular el % de uso
-- REV-SEM-08 · la capacidad puede venir de TRES sitios, por orden:
--   1. ds_total  -> el propio dato la trae (disk_mibhost ds=1). Se comprueba
--                   que la metrica realmente produzca ese DS, no basta con que
--                   este declarado.
--   2. l.capacity -> el inventario, poblado por el poller.
--   3. 100        -> implicita si la unidad es un porcentaje.
-- Antes solo se miraba la 2, asi que 204 discos salian como huecos teniendo la
-- capacidad medida en cada ciclo.
SELECT 'Saturacion sin capacidad declarada',
       COALESCE(m.dev_name, 'dev'||m.iddev), m.stable_key, l.canonical_id,
       'unidad ' || COALESCE(l.unit,'?'),
       'Revisar el poller de capacidad o el inventario'
FROM sem_role_lookup l
JOIN sem_metric_map  m ON m.instance_id = l.sem_instance_id
WHERE l.signal_class = 'saturation' AND l.weight > 0
  AND l.capacity IS NULL
  AND l.unit <> 'pct'
  AND NOT EXISTS (
        SELECT 1 FROM series_1h t
         WHERE t.id_metric = m.idmetric
           AND l.ds_total IS NOT NULL
           AND t.ds     = l.ds_total
           AND t.bucket > now() - interval '2 days'
           AND t.n > 0)

UNION ALL
-- Senales estancadas: residuo del inventario
SELECT 'Senal estancada (30 dias sin variar)',
       COALESCE(e.dev_name, e.role_id), e.metric_label, e.canonical_id,
       e.motivo || ' · ' || e.muestras || ' muestras',
       'Comprobar si el objeto medido sigue existiendo'
FROM v_senales_estancadas e

UNION ALL
-- Dispositivos sin primaria: no pueden producir un 'down'
SELECT 'Dispositivo sin senal primaria',
       d.role_id, 'dev'||d.iddev, d.role_type,
       d.senales_salud::text || ' senales de salud, 0 primarias',
       'Reejecutar cnm_binding.pl'
FROM v_device_sin_primaria d;

COMMENT ON VIEW v_cobertura_huecos IS
  'Detalle accionable de los huecos del modelo. Una fila = una accion posible. '
  'La columna accion dice que hacer con cada uno.';

\set app_user cnm_loader
GRANT SELECT ON v_cobertura_resumen, v_cobertura_huecos,
                v_roles_con_equipos_inactivos, v_senales_estancadas TO :app_user;
