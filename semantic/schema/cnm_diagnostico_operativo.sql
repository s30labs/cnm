-- ============================================================================
-- Consultas de diagnóstico operativo de la capa semántica.
-- Panel de control de COMPLETITUD y CALIDAD. Ejecutar periódicamente y ante
-- cada carga de dispositivos/métricas nuevos. Todas son de solo lectura.
-- Se exponen como VISTAS para poder consultarlas con un simple SELECT.
-- ============================================================================

-- ---------------------------------------------------------------------------
-- VISTA 1: subtypes sin concepto (métricas que NO entran al espejo ni binding)
-- Uso:  SELECT * FROM v_diag_subtypes_sin_concepto;
--       SELECT familia, COUNT(*) subtypes, SUM(metricas) metricas
--         FROM v_diag_subtypes_sin_concepto GROUP BY familia;
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_diag_subtypes_sin_concepto AS
SELECT m.subtype,
       COUNT(*) AS metricas,
       COUNT(DISTINCT m.id_dev) AS dispositivos,
       MIN(LEFT(COALESCE(NULLIF(m.c_label,''),m.label),60)) AS ejemplo_label,
       CASE WHEN m.subtype LIKE 'xagt\_%'   THEN 'xagt(estandar)'
            WHEN m.subtype LIKE 'custom\_%' THEN 'custom(local)'
            WHEN m.subtype LIKE 'w\_mon\_%' THEN 'w_mon'
            ELSE 'otro' END AS familia
FROM metrics m
WHERE COALESCE(m.status,0) IN (0,2)
  AND m.subtype NOT IN (SELECT subtype FROM sem_metric_concept)
GROUP BY m.subtype;

-- ---------------------------------------------------------------------------
-- VISTA 2: col7 huérfanos (RoleID que no existe/activo en el maestro)
-- Uso:  SELECT * FROM v_diag_col7_huerfano;   -- debe estar VACÍA
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_diag_col7_huerfano AS
SELECT c.columna7 AS col7_huerfano, COUNT(*) AS n_dispositivos,
       GROUP_CONCAT(d.name ORDER BY d.name SEPARATOR ', ') AS dispositivos
FROM devices_custom_data c
JOIN devices d ON d.id_dev=c.id_dev
WHERE c.columna7 IS NOT NULL
  AND c.columna7 NOT IN ('','-','unassigned','multiple_roles')
  AND c.columna7 NOT IN (SELECT role_id FROM sem_business_role WHERE status='active')
GROUP BY c.columna7;

-- ---------------------------------------------------------------------------
-- VISTA 3: cobertura de col7 (cuántos dispositivos clasificados)
-- Uso:  SELECT * FROM v_diag_cobertura_col7;
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_diag_cobertura_col7 AS
SELECT
  COUNT(*) AS total_dispositivos,
  SUM(c.columna7 IS NOT NULL AND c.columna7 NOT IN ('','-')) AS con_col7,
  SUM(c.columna7 IS NULL OR c.columna7 IN ('','-'))          AS sin_col7,
  SUM(c.columna7='multiple_roles') AS multiple_roles,
  SUM(c.columna7='unassigned')     AS unassigned
FROM devices d LEFT JOIN devices_custom_data c ON c.id_dev=d.id_dev;

-- ---------------------------------------------------------------------------
-- VISTA 4: subtypes HETEROGÉNEOS (un mismo subtype con labels de naturaleza
-- distinta bajo un solo concepto -> posible error de dato, como xagt_004010).
-- Uso:  SELECT * FROM v_diag_subtypes_heterogeneos;
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_diag_subtypes_heterogeneos AS
SELECT m.subtype,
       COUNT(DISTINCT TRIM(SUBSTRING_INDEX(m.label,'(',1))) AS labels_distintos,
       COUNT(*) AS metricas,
       c.canonical_id AS concepto_unico
FROM metrics m
LEFT JOIN sem_metric_concept c ON c.subtype=m.subtype
WHERE COALESCE(m.status,0) IN (0,2)
GROUP BY m.subtype, c.canonical_id
HAVING labels_distintos > 1;
