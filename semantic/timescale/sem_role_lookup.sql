-- ═══════════════════════════════════════════════════════════════════════════
-- >> EJECUTAR   ·   Orden de aplicacion: 2 de 10
-- Replica semantica. En instalacion EXISTENTE basta ALTER TABLE: ver DOC-SEM-00.
-- Instalacion desde cero: ejecutar los ficheros por su numero de orden.
-- Instalacion en marcha: ver DOC-SEM-00 'Como se anade una columna a la replica'.
-- ═══════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- sem_role_lookup  ·  replica de solo lectura de la capa semantica en PostgreSQL
-- Alineada con cnm_semantic_schema_v3.sql (v3.7)
--
-- QUE ES: proyeccion aplanada de sem_binding_role + sem_business_role +
--   sem_instance + sem_metric_concept + sem_canonical_concept (MariaDB, onm),
--   copiada al host Timescale para poder unirla con series. NO es fuente de
--   verdad: se reemplaza integra en cada sincronizacion.
--
-- POR QUE EXISTE: series (PostgreSQL) y sem_binding_role (MariaDB) viven en
--   motores y hosts distintos; no hay JOIN posible. Esta tabla permite resolver
--   el rol EN CONSULTA en vez de hornearlo en la ingesta.
--
-- IMPORTANTE: esta tabla NO solo trae el rol. Trae tambien lo que hace falta
--   para que el valor crudo de series sea COMPARABLE entre instancias:
--     value_scale  -> conversion a la unidad canonica del concepto
--     capacity     -> denominador de saturacion (concepts con needs_capacity)
--     direction    -> sentido de "peor" (no se pueden promediar sentidos mixtos)
--     expected_value -> referencia para conceptos out_of_band
--   Sin estos campos, cualquier media por rol mezcla peras con manzanas.
-- =============================================================================

-- RE-EJECUTABLE Y NO DESTRUCTIVO.
--   Tablas: CREATE TABLE IF NOT EXISTS -> relanzar el fichero NO borra la
--   replica ya cargada, y no arrastra por CASCADE las vistas cruzadas que
--   dependen de ella (cnm_vistas_cruzadas.sql). Si alguna vez cambia la
--   ESTRUCTURA de una tabla hay que hacer el DROP a mano, de forma consciente:
--     DROP TABLE sem_role_lookup CASCADE;   -- y reaplicar cnm_vistas_cruzadas.sql
--
--   Vistas: DROP + CREATE. No tienen datos, y CREATE OR REPLACE VIEW no permite
--   renombrar columnas, asi que reemplazarlas es la unica via limpia.
DROP VIEW IF EXISTS v_sem_peso_incoherente;
DROP VIEW IF EXISTS v_sem_map_health;
DROP VIEW IF EXISTS v_sem_coverage;
DROP VIEW IF EXISTS v_sem_lookup_freshness;
DROP VIEW IF EXISTS v_sem_multirole;
DROP VIEW IF EXISTS v_sem_debt;

CREATE TABLE IF NOT EXISTS sem_role_lookup (
  -- Clave de union con series. sem_instance_id (no instance_id) para permitir
  -- JOIN ... USING (sem_instance_id).
  sem_instance_id  bigint       NOT NULL,
  role_id          text         NOT NULL,

  -- --- vinculo instancia->rol (Trabajo B: juicio revisable) ---
  relation_type    text         NOT NULL,   -- direct | shared_dependency | derived
  is_primary       boolean      NOT NULL DEFAULT false,
  weight           numeric(3,2) NOT NULL DEFAULT 1.00,
  binding_confidence text,                  -- human_confirmed | ai_suggested | inherited
  binding_source   text,                    -- manual | onboarding | clustering | llm_batch | rules

  -- --- rol de negocio ---
  role_display_name text,
  role_type        text,                    -- technical_service | application | ...
  role_domain      text,
  criticality      smallint,
  environment      text,

  -- Politica de agregacion de salud del rol (REV-SEM-03). Una sola columna:
  --   down si dispositivos_caidos > health_threshold * total
  -- 0 = cae con cualquiera | 0.500 = mas de la mitad | 0.990 = solo si caen todos
  health_threshold      numeric(4,3) NOT NULL DEFAULT 0.500,
  health_threshold_note text,

  -- --- semantica de la senal (signal_class EFECTIVA ya resuelta) ---
  signal_class     text,                    -- health_sli | saturation | diagnostic | informative
  canonical_id     text,
  concepto_nombre  text,        -- display_name del concepto: 'Uso de disco', 'Ping'
  category         text,
  direction        text,                    -- higher_is_worse | lower_is_worse | out_of_band
  unit             text,
  is_business      boolean      NOT NULL DEFAULT false,

  -- REV-SEM-04: de quien es propiedad la metrica. En CNM toda metrica cuelga de
  -- un dispositivo por requisito estructural, pero eso no significa que SEA del
  -- dispositivo. Determina la unidad de agregacion en f_role_health.
  --   device -> propiedad del equipo (ICMP, interfaces, servicios)
  --   flow   -> propiedad de un proceso que atraviesa sistemas (jobs, descuadres)
  --   entity -> propiedad de una entidad con vida propia (certificados)
  scope            text         NOT NULL DEFAULT 'device',

  -- --- aritmetica: sin esto el valor crudo de series no es comparable ---
  value_scale      double precision NOT NULL DEFAULT 1.0,

  -- REV-SEM-08 · que DS lleva el valor de uso y cual la capacidad.
  --
  -- ds_valor: lista de DS separados por comas cuyos valores se SUMAN.
  --   '1' por defecto. '2' en disk_mibhost, donde ds=1 es el TOTAL del disco y
  --   ds=2 el usado. '1,2' en trafico, porque RX y TX comparten enlace y su
  --   suma es lo que satura.
  --   NULL = el subtype NO se puede reducir a un DS (su uso es una formula,
  --   como 100-o1 en ucd_cpu_usage) y el informe lo EXCLUYE declarandolo, en
  --   vez de publicar un numero equivocado.
  --
  -- ds_total: DS con la capacidad, cuando viene en la propia metrica. Evita
  --   depender del poller: en disk_mibhost el tamaño se mide en cada ciclo.
  ds_valor         text DEFAULT '1',
  ds_total         smallint,
  capacity         double precision,
  needs_capacity   boolean      NOT NULL DEFAULT false,
  expected_value   text,
  plausible_min    double precision,
  plausible_max    double precision,

  -- --- identidad (para diagnostico y presentacion) ---
  subtype          text,
  stable_key       text,
  iddev            bigint,
  -- Tipo de interfaz (loopback, virtual, tunnel...), derivado de ifType por el
  -- poller. Lo usa el filtro de trafico de f_informe_capacidad
  -- (REV-SEM-Metrica-de-Capacidad). Desplegada; medido el 8-nov-2026.
  instance_kind    text,

  refreshed_at     timestamptz  NOT NULL DEFAULT now(),

  PRIMARY KEY (sem_instance_id, role_id)
);

CREATE INDEX IF NOT EXISTS sem_role_lookup_role  ON sem_role_lookup (role_id);
CREATE INDEX IF NOT EXISTS sem_role_lookup_class ON sem_role_lookup (signal_class) WHERE weight > 0;

COMMENT ON TABLE sem_role_lookup IS
  'Replica de solo lectura de la capa semantica de CNM (fuente: sem_binding_role '
  'en MariaDB/onm). Se reemplaza integra en cada sync; no editar a mano.';
COMMENT ON COLUMN sem_role_lookup.ds_valor IS
  'DS que se SUMAN para dar el valor de uso, separados por comas. NULL = el '
  'subtype no se puede reducir a un DS y el informe de capacidad lo excluye. '
  'Ver REV-SEM-08.';
COMMENT ON COLUMN sem_role_lookup.ds_total IS
  'DS que contiene la capacidad, cuando viene en la propia metrica (disk_mibhost '
  'ds=1). Tiene prioridad sobre sem_instance.capacity. Ver REV-SEM-08.';

COMMENT ON COLUMN sem_role_lookup.value_scale IS
  'Multiplicador del valor crudo de series a la unidad canonica del concepto. '
  'TODA consulta analitica debe aplicarlo: value * value_scale.';
COMMENT ON COLUMN sem_role_lookup.direction IS
  'higher_is_worse | lower_is_worse | out_of_band. Valores con direction distinta '
  'NO son promediables entre si sin normalizar antes a una escala comun.';
COMMENT ON COLUMN sem_role_lookup.capacity IS
  'Denominador de saturacion. Si needs_capacity y capacity IS NULL, la saturacion '
  'de esa instancia NO es evaluable (deuda detectable, ver v_sem_debt).';

-- =============================================================================
-- sem_metric_map  ·  puente id_metric -> instancia
--
-- POR QUE HACE FALTA: cnm_alerts_store trae id_metric; sem_role_lookup esta
--   indexada por sem_instance_id. Sin esta tabla no se pueden unir, y no hay
--   forma de llegar del historico de alertas al rol de negocio.
--
-- POR QUE NO SE DERIVA DEL LABEL DE LA ALERTA: alerts.label sale de
--   alert_type.cause (descripcion del MONITOR), no de metrics.label. Los
--   monitores compartidos ("Disk Usage Higher than 80% - 90%", "DEVICE WITH NO
--   CONECTIVITY (ICMP)") cubren cientos de metricas a la vez, asi que el label
--   no identifica la instancia justo en los subtipos multi-instancia, que son
--   los que necesitan stable_key. Ademas obligaria a reimplementar las 18 reglas
--   de stable_key_rules.conf en el lado analitico, duplicando logica que ya
--   resuelve CNMStableKey.pm.
--
-- SOBRE LA VOLATILIDAD DE id_metric: los id_metric cambian cuando cambia la
--   topologia monitorizada (se sustituye un disco, se reconfigura una interfaz),
--   no de forma continua. Y la capa semantica YA absorbe ese cambio: al recrearse
--   la metrica, CNMStableKey deriva la MISMA stable_key del nombre real, asi que
--   el idmetric nuevo apunta a la MISMA instance_id que el viejo. La fila antigua
--   se conserva (PK = idmetric), de modo que las alertas historicas y las nuevas
--   resuelven a la misma instancia. Verificado sobre 515.623 alertas de 5,9 meses:
--   CERO discrepancias de iddev o subtype.
--
-- iddev y subtype se traen desnormalizados como CANARIO, no como filtro: no se
--   descarta ninguna fila por ellos; solo se hacen visibles las incoherencias
--   (ver cnm_vistas_cruzadas.sql). Hoy dan 0; el dia que den otra cosa estaran
--   avisando de un cambio de topologia mal absorbido.
-- =============================================================================

CREATE TABLE IF NOT EXISTS sem_metric_map (
  idmetric      bigint PRIMARY KEY,   -- une con cnm_alerts_store.id_metric
  instance_id   bigint NOT NULL,      -- une con sem_role_lookup.sem_instance_id
  iddev         bigint,               -- canario de coherencia
  subtype       text,                 -- canario de coherencia
  stable_key    text,                 -- diagnostico legible

  -- Datos del dispositivo, para informes legibles sin volver a CNM.
  dev_name      text,                 -- devices.name
  dev_ip        text,                 -- devices.ip
  -- devices.status: 0=activo, 1=de baja (sin polling), 2=mantenimiento
  -- (hay polling pero NO alerta). El estado 2 es el delicado: esas metricas
  -- tienen datos -asi que parecen evaluables- pero nunca produciran una alerta.
  dev_status    smallint DEFAULT 0,
  -- Columnas personalizadas de devices_custom_data, con su NOMBRE FUNCIONAL
  -- segun devices_custom_types (Application, Site, Geography, RoleID...).
  -- jsonb y no columnas fijas porque su numero varia entre instalaciones.
  --   Ejemplo: {"Application": "BW", "RoleID": "app.sap_bw"}
  --   Acceso:  dev_custom->>'Site'
  dev_custom    jsonb,

  -- Vinculo con lo que se ve en la consola de CNM. Sin esto, quien mire un
  -- resultado de la capa analitica no puede localizar la metrica en el interfaz.
  --
  -- OJO con la semantica exacta de estos campos, verificada contra el esquema:
  metric_name   text,   -- metrics.name: subtype+iid si hay instancia, subtype si no.
                        -- NO es el monitor.
  metric_label  text,   -- metrics.label: 'USO DE DISCO C:\ Label: (dwdata06...)'
  metric_type   text,   -- metrics.type: snmp | latency | xagent

  -- EL MONITOR y su umbral, de metrics.watch -> alert_type.
  -- Es lo que permite contrastar el modelo semantico con lo configurado en CNM:
  -- si una metrica esta clasificada como 'uso de disco' pero su monitor dice
  -- 'Memory Usage Higher than 95%', hay un error de clasificacion.
  monitor           text,      -- metrics.watch = alert_type.monitor
  monitor_causa     text,      -- 'Disk Usage Higher than 80% - 90%'
  monitor_expr      text,      -- la expresion evaluada
  monitor_severidad smallint,  -- severidad que produce

  refreshed_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS sem_metric_map_ix_instance ON sem_metric_map (instance_id);
CREATE INDEX IF NOT EXISTS sem_metric_map_ix_dev      ON sem_metric_map (iddev);

COMMENT ON TABLE sem_metric_map IS
  'Replica de sem_metric_binding + identidad de sem_instance. Puente entre el '
  'id_metric de las alertas y el sem_instance_id de la capa semantica. Se '
  'reemplaza integra en cada sync; no editar a mano.';
COMMENT ON COLUMN sem_metric_map.iddev IS
  'Canario, no filtro: si no coincide con cnm_alerts_store.id_device, ese '
  'id_metric no puede ser la metrica que genero la alerta.';

-- =============================================================================
-- Vistas de gobernanza (espiritu de v_binding_health: deuda visible)
-- =============================================================================

-- Salud del puente: cuantas metricas mapean y cuantas instancias alcanzan rol.
CREATE OR REPLACE VIEW v_sem_map_health AS
SELECT (SELECT count(*) FROM sem_metric_map)                       AS metricas_mapeadas,
       (SELECT count(DISTINCT instance_id) FROM sem_metric_map)    AS instancias_distintas,
       (SELECT count(*) FROM sem_metric_map m
          WHERE EXISTS (SELECT 1 FROM sem_role_lookup l
                         WHERE l.sem_instance_id = m.instance_id)) AS metricas_con_rol,
       (SELECT max(refreshed_at) FROM sem_metric_map)              AS ultima_sync,
       (SELECT now() - max(refreshed_at) FROM sem_metric_map)      AS antiguedad;

CREATE OR REPLACE VIEW v_sem_lookup_freshness AS
SELECT max(refreshed_at)               AS ultima_sync,
       now() - max(refreshed_at)       AS antiguedad,
       count(*)                        AS filas,
       count(DISTINCT role_id)         AS roles,
       count(DISTINCT sem_instance_id) AS instancias
FROM sem_role_lookup;

CREATE OR REPLACE VIEW v_sem_coverage AS
SELECT count(*)                                                     AS muestras_1h,
       count(s.sem_instance_id)                                     AS con_instancia,
       count(l.role_id)                                             AS con_rol,
       round(100.0*count(s.sem_instance_id)/NULLIF(count(*),0), 2)  AS pct_instancia,
       round(100.0*count(l.role_id)/NULLIF(count(*),0), 2)          AS pct_rol
FROM series s
LEFT JOIN sem_role_lookup l USING (sem_instance_id)
WHERE s.time > now() - interval '1 hour';

-- Multi-rol: hoy deberia dar 0 filas. Si aparece, el JOIN con series multiplica
-- filas y sumar roles entre si contaria doble.
CREATE OR REPLACE VIEW v_sem_multirole AS
SELECT sem_instance_id, count(*) AS n_roles,
       string_agg(role_id, ', ' ORDER BY role_id) AS roles
FROM sem_role_lookup
GROUP BY sem_instance_id
HAVING count(*) > 1;

-- PESO INCOHERENTE CON LA CLASE DE SENAL.
--
-- signal_class viene del CONCEPTO (Trabajo A); weight e is_primary viven en el
-- BINDING (Trabajo B). Cambiar el concepto de una metrica NO actualiza su peso:
-- hace falta reejecutar cnm_binding.pl. Si no se hace, quedan bindings con la
-- clase nueva y el peso viejo.
--
-- Caso real (REV-SEM-01, agosto 2026): al mover 50 metricas de importe de
-- flow.job.status (health_sli) a biz.amount.eur (diagnostic) sin rebindear,
-- quedaron 50 bindings 'diagnostic' con peso 0,50 y 1,00. El efecto colateral
-- fue que 2 dispositivos se quedaron SIN primaria de salud, rompiendo en
-- silencio la garantia de REV-SEM-03 accion 1.
--
-- REGLA: diagnostic/informative -> 0.00 | health_sli -> 1.00 o 0.50
--        saturation -> 0.50
--
-- Si esta vista devuelve filas: reejecutar cnm_binding.pl --commit y resincronizar.
CREATE OR REPLACE VIEW v_sem_peso_incoherente AS
SELECT signal_class, weight, count(*) AS bindings,
       count(DISTINCT role_id)   AS roles,
       string_agg(DISTINCT canonical_id, ', ') AS conceptos
FROM sem_role_lookup
WHERE (signal_class IN ('diagnostic','informative') AND weight <> 0)
   OR (signal_class = 'health_sli' AND weight NOT IN (0.5, 1.0))
   OR (signal_class = 'saturation' AND weight <> 0.5)
GROUP BY 1,2;

-- Deuda detectable declarada en el propio esquema semantico (lineas 37-39 de
-- cnm_semantic_schema_v3.sql), mas la que introduce la replica.
CREATE OR REPLACE VIEW v_sem_debt AS
SELECT 'saturacion no evaluable (needs_capacity sin capacity)' AS problema,
       count(*) AS n
  FROM sem_role_lookup WHERE needs_capacity AND capacity IS NULL AND weight > 0
UNION ALL
SELECT 'out_of_band sin expected_value', count(*)
  FROM sem_role_lookup WHERE direction='out_of_band' AND expected_value IS NULL AND weight > 0
UNION ALL
SELECT 'sin concepto canonico (subtype no mapeado)', count(*)
  FROM sem_role_lookup WHERE canonical_id IS NULL
UNION ALL
SELECT 'sin signal_class efectiva', count(*)
  FROM sem_role_lookup WHERE signal_class IS NULL
UNION ALL
SELECT 'binding no confirmado por humano (ai_suggested)', count(*)
  FROM sem_role_lookup WHERE binding_confidence = 'ai_suggested'
UNION ALL
SELECT 'health_sli sin plausible_max ni capacity (no normalizable)', count(*)
  FROM sem_role_lookup
 WHERE signal_class='health_sli' AND weight > 0
   AND direction <> 'out_of_band' AND plausible_max IS NULL AND capacity IS NULL;

-- =============================================================================
-- PERMISOS PARA EL USUARIO DE LOS SCRIPTS
-- Sin esto, cnm_ts_sync_semantics.pl falla con "permission denied".
-- TRUNCATE es un privilegio APARTE en PostgreSQL.
-- Ajustar el nombre del rol si no es cnm_loader.
-- =============================================================================
\set app_user cnm_loader

GRANT SELECT, INSERT, TRUNCATE ON sem_role_lookup TO :app_user;
GRANT SELECT, INSERT, TRUNCATE ON sem_metric_map  TO :app_user;
GRANT SELECT ON v_sem_coverage, v_sem_debt, v_sem_lookup_freshness,
                v_sem_multirole, v_sem_map_health, v_sem_peso_incoherente TO :app_user;
