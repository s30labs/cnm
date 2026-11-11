-- =============================================================================
-- Esquema del almacén analítico TimescaleDB (CNM).
-- Ver cnm_arquitectura_timescale.md (§4 esquema, §4.6 compresión/retención,
-- §4.7/§6.10 continuous aggregate con sketch de percentiles).
-- Idempotente: se puede reaplicar sin efectos secundarios.
-- Se ejecuta como superusuario (postgres). Los permisos de lo que crea los
-- dan los permisos por defecto del principio (ver ese bloque).
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS timescaledb_toolkit;   -- percentile_agg (UddSketch), §6.10

-- ---------------------------------------------------------------------------
-- Permisos POR DEFECTO de lo que cree postgres en public. Es lo desplegado
-- (medido el 8-nov-2026); su origen no esta documentado. Con ellos, cada tabla,
-- vista o funcion que se cree DESPUES de este bloque da (por eso va antes de
-- crear series):
--   * a cnm_loader, TODOS los permisos (ALL), no solo los que conceden los
--     ficheros siguientes;
--   * a grafana_ro, lectura (SELECT) de todo, incluidas las tablas internas que
--     la API publica oculta tras las vistas api_*.
-- Son mas de los que hacen falta: ver la entrada de seguridad correspondiente
-- en cnm-docs. Aqui se recogen tal cual para que el repositorio reproduzca
-- lo desplegado. Si el rol no existe, no se concede (el permiso por defecto
-- exige que exista).
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'cnm_loader') THEN
    ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
      GRANT ALL ON TABLES TO cnm_loader;
  END IF;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'grafana_ro') THEN
    ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public
      GRANT SELECT ON TABLES TO grafana_ro;
    GRANT USAGE ON SCHEMA public TO grafana_ro;
  END IF;
END $$;

-- ---------------------------------------------------------------------------
-- Hipertabla cruda, formato estrecho (§4.1)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS series (
  time            timestamptz      NOT NULL,
  id_metric       integer          NOT NULL,
  ds              smallint         NOT NULL,
  value           double precision,            -- NULL = medido sin dato (§4.3)
  sem_instance_id integer                       -- resuelto en carga (§4.5) o NULL
);

SELECT create_hypertable('series','time',
    chunk_time_interval => INTERVAL '1 day',
    if_not_exists => TRUE);

-- Unicidad/idempotencia; incluye la columna de partición 'time' (§4.8).
-- Da soporte al ON CONFLICT (time,id_metric,ds) del loader.
CREATE UNIQUE INDEX IF NOT EXISTS series_uq       ON series (id_metric, ds, time);
-- Patrón de consulta analítica por identidad (§4.8)
CREATE INDEX        IF NOT EXISTS series_inst_time ON series (sem_instance_id, time DESC);

-- ---------------------------------------------------------------------------
-- Compresión de chunks antiguos (§4.6). Se comprime lo > 7 días; lo reciente
-- queda sin comprimir para la ingesta.
-- ---------------------------------------------------------------------------
ALTER TABLE series SET (
  timescaledb.compress,
  timescaledb.compress_segmentby = 'id_metric, ds',
  timescaledb.compress_orderby   = 'time DESC'
);
SELECT add_compression_policy('series', INTERVAL '7 days', if_not_exists => TRUE);

-- ---------------------------------------------------------------------------
-- Retención del crudo (§4.6). Ajustar el intervalo según política (60-90 días).
-- Los agregados (abajo) se conservan aunque se descarte el crudo.
-- ---------------------------------------------------------------------------
SELECT add_retention_policy('series', INTERVAL '90 days', if_not_exists => TRUE);

-- ---------------------------------------------------------------------------
-- Continuous aggregate horario (§4.7). Mantiene, de forma incremental, un
-- sketch de percentiles (UddSketch) por (id_metric, ds, hora): base del baseline
-- estacional de §6.10 sin recorrer crudo. Nota: agregar 'avg' sobre estados no
-- tiene sentido; para conceptos de estado se usa 'last_value' (§4.4).
-- ---------------------------------------------------------------------------
CREATE MATERIALIZED VIEW IF NOT EXISTS series_1h
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 hour', time) AS bucket,
       id_metric, ds,
       count(*)              AS n,
       avg(value)            AS avg_value,
       min(value)            AS min_value,
       max(value)            AS max_value,
       last(value, time)     AS last_value,
       percentile_agg(value) AS pct_sketch      -- UddSketch (200 cubos, error max. 0,001); mediana/IQR al leer
FROM series
GROUP BY bucket, id_metric, ds
WITH NO DATA;

-- start_offset de 1 dia, no de 3 horas: es lo desplegado (medido el
-- 8-nov-2026, trabajo 1002). Recalcula el ultimo dia en cada pasada, de modo
-- que una muestra que llega tarde (loader parado, spool recuperado) entra en su
-- hora aunque llegue hasta 23 h despues.
SELECT add_continuous_aggregate_policy('series_1h',
    start_offset      => INTERVAL '1 day',
    end_offset        => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour',
    if_not_exists => TRUE);

-- Compresion y retencion de series_1h (RUNBOOK-SEM-Hito02-Agregado-Diario §6,
-- en cnm-docs). La retencion BORRA horas de mas de dos años: lo que se
-- conserva despues es series_1d (cnm_series_1d.sql).
--
-- segmentby id_metric, ds (F23, noviembre de 2026; cnm-docs REG-SEM-Pendientes).
-- Cada lote comprimido guarda UNA serie, con sus horas seguidas, como el crudo.
-- Sin segmentby cada lote mezclaba miles de metricas y leer una obligaba a
-- descomprimir casi todo el chunk. Medido el 11-nov-2026 sobre septiembre, con
-- f_informe_capacidad sin cambios: un rol 17,6 s -> 2,6 s, el informe completo
-- igual (42 -> 45 s), resultado identico y un 27-31 % menos de espacio.
-- Solo afecta a los chunks que se comprimen DESPUES de aplicarlo; los ya
-- comprimidos conservan su configuracion hasta recomprimirlos.
ALTER MATERIALIZED VIEW series_1h SET (timescaledb.compress = true,
  timescaledb.compress_segmentby = 'id_metric, ds',
  timescaledb.compress_orderby   = 'bucket');
SELECT add_compression_policy('series_1h', compress_after => INTERVAL '30 days',
                              if_not_exists => TRUE);
SELECT add_retention_policy('series_1h', drop_after => INTERVAL '2 years',
                            if_not_exists => TRUE);


-- Permisos para el usuario del loader (sustituido por Ansible: :loader_user).
-- (Se concede vía tarea Ansible independiente para poder parametrizar el nombre.)
