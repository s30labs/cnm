-- =============================================================================
-- Contadores SNMP: diccionario de subtypes que son contadores acumulados y
-- ultimo valor crudo de cada metrica. Con ellos el loader (cnm_ts_loader.pl)
-- guarda en series la TASA por segundo, no el contador.
--
-- Diseno: REV-SEM-Contadores-SNMP (cnm-docs), apartado «Las dos tablas nuevas».
-- Este fichero no existia: las tablas se crearon con el DDL de esa revision.
-- Se reconstruye de alli y de lo desplegado (medido el 8-nov-2026).
--
-- Quien escribe:
--   sem_counter_dict  : cnm_ts_sync_semantics.pl (INSERT ... ON CONFLICT DO NOTHING)
--   sem_counter_state : cnm_ts_loader.pl (UPSERT con el ultimo crudo del lote)
-- =============================================================================

-- Que subtypes son contadores
CREATE TABLE IF NOT EXISTS sem_counter_dict (
  subtype  text PRIMARY KEY,
  nota     text,
  -- Cuando entro este subtype en el diccionario. Lo cargado ANTES de esta
  -- fecha son valores crudos, no tasas. Imprescindible cuando el sync da de
  -- alta un subtype nuevo: hasta esa hora se estuvo cargando el contador.
  desde    timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE sem_counter_dict IS 'Subtypes cuyo valor es un contador acumulado SNMP. El loader los convierte a tasa por segundo. Ver REV-SEM-09.';

-- Ultimo valor CRUDO por metrica, para enlazar entre lotes
CREATE TABLE IF NOT EXISTS sem_counter_state (
  id_metric  integer     NOT NULL,
  ds         smallint    NOT NULL,
  last_time  timestamptz NOT NULL,
  last_raw   double precision NOT NULL,
  PRIMARY KEY (id_metric, ds)
);

COMMENT ON TABLE sem_counter_state IS 'Ultimo valor crudo por metrica, para calcular la diferencia entre lotes. Se puede vaciar sin perder datos: solo provoca un NULL en la primera muestra siguiente de cada metrica.';
