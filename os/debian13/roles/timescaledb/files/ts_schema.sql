-- =============================================================================
-- Esquema del almacén analítico TimescaleDB (CNM).
-- Ver cnm_arquitectura_timescale.md (§4 esquema, §4.6 compresión/retención,
-- §4.7/§6.10 continuous aggregate con sketch de percentiles).
-- Idempotente: se puede reaplicar sin efectos secundarios.
-- Se ejecuta como superusuario (postgres); al final concede permisos al loader.
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS timescaledb_toolkit;   -- percentile_agg (t-digest), §6.10

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
-- sketch de percentiles (t-digest) por (id_metric, ds, hora): base del baseline
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
       percentile_agg(value) AS pct_sketch      -- t-digest; mediana/IQR se extraen al leer
FROM series
GROUP BY bucket, id_metric, ds
WITH NO DATA;

SELECT add_continuous_aggregate_policy('series_1h',
    start_offset      => INTERVAL '3 hours',
    end_offset        => INTERVAL '1 hour',
    schedule_interval => INTERVAL '1 hour',
    if_not_exists => TRUE);

-- Permisos para el usuario del loader (sustituido por Ansible: :loader_user).
-- (Se concede vía tarea Ansible independiente para poder parametrizar el nombre.)
