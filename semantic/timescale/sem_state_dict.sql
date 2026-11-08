-- =============================================================================
-- sem_state_dict — diccionario de estados one-hot de CNM (fuente: cfg_monitor,
--   cfg_monitor_snmp, cfg_monitor_agent).
--   Este fichero crea SOLO la tabla. Su contenido se genera de la configuracion
--   de monitores de cada instalacion y no se versiona aqui: son datos, no esquema
--   (el volcado con los datos es cnm_state_dict.sql, excluido en ../.gitignore).
--   Clave = subtype (estable). ds = indice 1-based; state_label = etiqueta;
--   is_good = estado nominal (DS1 por convencion de la config; revisar excepciones).
--   Un subtype presente aqui => metrica one-hot => se colapsa en el loader (§4.9).
-- =============================================================================
CREATE TABLE IF NOT EXISTS sem_state_dict (
  subtype      text     NOT NULL,
  ds           smallint NOT NULL,   -- indice de DS, 1-based
  state_label  text     NOT NULL,
  is_good      boolean  NOT NULL DEFAULT false,
  PRIMARY KEY (subtype, ds)
);
