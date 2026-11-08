-- =============================================================================
-- Vistas que CRUZAN las dos replicas (alertas x semantica)
--
-- ORDEN: este fichero se aplica DESPUES de cnm_alerts_replica.sql Y de
--   sem_role_lookup.sql. Las vistas de aqui referencian tablas de ambos, asi
--   que si se aplica antes fallara.
--
--   Los otros dos ficheros siguen siendo independientes entre si (se pueden
--   aplicar en cualquier orden): las dependencias cruzadas se concentran aqui
--   a proposito, para no acoplarlos.
--
-- ALCANCE: gobernanza y diagnostico. Las vistas de intervalos y de salud por rol
--   se añadiran a este mismo fichero cuando se diseñen.
--
-- NO TOCA series ni ninguna tabla de produccion: solo crea vistas de lectura.
-- =============================================================================

DROP VIEW IF EXISTS v_alertas_canario_identidad;
DROP VIEW IF EXISTS v_alertas_cobertura_rol;

-- -----------------------------------------------------------------------------
-- CANARIO DE IDENTIDAD
--
-- Compara los dos componentes de identidad que SI viaja en la alerta
-- (id_device, subtype) contra los de la instancia a la que resuelve su
-- id_metric. Una discrepancia significa que ese id_metric ya no corresponde a
-- la metrica que genero la alerta: reutilizacion de identificador tras un
-- cambio de topologia mal absorbido.
--
-- NO filtra nada. Solo hace visible el problema. Medido sobre 515.623 alertas
-- de 5,9 meses: 0 discrepancias. El dia que devuelva filas, algo cambio.
--
-- El tercer componente (stable_key) no viaja en la alerta, asi que una
-- reutilizacion DENTRO del mismo dispositivo y mismo subtype no se detectaria.
-- Es el limite conocido de esta comprobacion.
-- -----------------------------------------------------------------------------
CREATE VIEW v_alertas_canario_identidad AS
SELECT a.id_alert, a.started_at, a.id_metric, a.type, a.severity,
       a.id_device  AS device_alerta,  m.iddev   AS device_instancia,
       a.subtype    AS subtype_alerta, m.subtype AS subtype_instancia,
       m.stable_key, m.instance_id,
       (a.id_device IS DISTINCT FROM m.iddev)   AS discrepa_device,
       (a.subtype   IS DISTINCT FROM m.subtype) AS discrepa_subtype
FROM cnm_alerts_store a
JOIN sem_metric_map   m ON m.idmetric = a.id_metric
WHERE a.id_metric > 0
  AND a.date_epoch IS NOT NULL
  AND a.type IN ('snmp','latency','xagent')
  AND (a.id_device IS DISTINCT FROM m.iddev OR a.subtype IS DISTINCT FROM m.subtype);

-- -----------------------------------------------------------------------------
-- COBERTURA: cuanto del historico de alertas llega hasta un rol de negocio
--
-- Los tres escalones de perdida, separados para poder actuar sobre cada uno:
--   sin_metrica      -> alerta a nivel de dispositivo (id_metric = 0). ~0,16%
--   sin_mapa         -> el id_metric ya no esta en sem_metric_binding. Si crece,
--                       suele indicar que el mirror va retrasado, NO un problema
--                       de identidad.
--   sin_rol          -> la instancia existe pero no tiene atadura a ningun rol
--   sin_peso         -> atada, pero con weight = 0 (diagnostic: no agrega)
-- -----------------------------------------------------------------------------
CREATE VIEW v_alertas_cobertura_rol AS
WITH base AS (
  SELECT a.id_alert, a.id_metric, m.instance_id,
         EXISTS (SELECT 1 FROM sem_role_lookup l
                  WHERE l.sem_instance_id = m.instance_id)                 AS tiene_rol,
         EXISTS (SELECT 1 FROM sem_role_lookup l
                  WHERE l.sem_instance_id = m.instance_id AND l.weight > 0) AS agrega
  FROM cnm_alerts_store a
  LEFT JOIN sem_metric_map m ON m.idmetric = a.id_metric
  WHERE a.type IN ('snmp','latency','xagent')
    AND a.severity <> 4
    AND a.date_epoch IS NOT NULL
)
SELECT count(*)                                                   AS alertas_evaluables,
       count(*) FILTER (WHERE id_metric = 0)                      AS sin_metrica,
       count(*) FILTER (WHERE id_metric > 0 AND instance_id IS NULL) AS sin_mapa,
       count(*) FILTER (WHERE instance_id IS NOT NULL AND NOT tiene_rol) AS sin_rol,
       count(*) FILTER (WHERE tiene_rol AND NOT agrega)           AS sin_peso,
       count(*) FILTER (WHERE agrega)                             AS llegan_a_rol,
       round(100.0 * count(*) FILTER (WHERE agrega)
             / NULLIF(count(*),0), 2)                             AS pct_llegan_a_rol
FROM base;

-- Permisos: ajustar el rol si no es cnm_loader.
\set app_user cnm_loader
GRANT SELECT ON v_alertas_canario_identidad, v_alertas_cobertura_rol TO :app_user;
