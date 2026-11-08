-- =============================================================================
-- Replica de alertas de CNM en el servidor analitico (PostgreSQL/Timescale)
--
-- MOTIVO (urgente): CNM purga alerts_store POR NUMERO DE FILAS, no por fecha.
--   Medido: ~3.886 filas/dia y ~579.000 filas en tabla -> retencion efectiva de
--   unos 5-7 meses. Verificado por año de archivado: 2024 y 2025 estan a CERO;
--   solo sobreviven 57 filas anteriores a 2026 (residuos que la purga no barrio).
--   Cada mes sin replicar es un mes de historico que CNM borra sin retorno.
--
-- ALCANCE: esto SOLO captura. No calcula salud, no interpreta severidades, no
--   filtra por tipo. La interpretacion vive en las vistas, que llegan despues.
--   Criterio: capturar ANCHO, interpretar ESTRECHO. Si mañana cambia el criterio
--   de que tipos valen, no querremos haber tirado el dato.
--
-- NO TOCA series. Este fichero no contiene ninguna sentencia sobre la hipertabla
--   de series temporales. Las dos tablas de abajo son nuevas y de nombre propio.
--
-- EJECUCION: una sola vez, antes del primer uso de cnm_ts_sync_alerts.pl.
--   El script de sincronizacion NO crea tablas: si no existen, aborta.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. HISTORICO DE ALERTAS (espejo de alerts_store)
--
-- Sin politica de retencion: es justo lo contrario de lo que hace CNM. Aqui se
-- guarda todo. A ~1,4 M filas/año, diez años son 14 M filas: perfectamente
-- manejable como tabla normal. NO se hace hipertabla porque las filas llegan
-- ordenadas por date_store (archivado) y no por date (inicio del incidente),
-- lo que generaria insercion desordenada en los chunks sin ganancia real.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cnm_alerts_store (
  id_alert         bigint   PRIMARY KEY,     -- PK en origen; las filas archivadas no cambian
  id_device        integer,
  id_metric        bigint,                   -- 0 = alerta sin metrica (0,16% del historico)
  id_alert_type    integer,
  watch            text,                     -- id del monitor (alert_type.monitor)
  severity         smallint,                 -- 1 rojo | 2 naranja | 3 amarillo | 4 azul
  duration         integer,                  -- SEGUNDOS. Verificado: = date_store - date

  -- Epochs tal cual vienen de CNM (int unix). Se conservan crudos para poder
  -- auditar contra el origen sin ambiguedad de zona horaria.
  date_epoch       bigint,                   -- inicio del incidente
  date_store_epoch bigint,                   -- archivado (cierre). MARCA DE AGUA del sync
  date_last_epoch  bigint,                   -- ultima vez que se observo la condicion

  counter          integer,
  type             text,                     -- snmp | latency | xagent | syslog | snmp-trap
  subtype          text,
  mname            text,
  label            text,
  cause            text,
  ack              integer,
  mnt              integer,                  -- mantenimiento (hoy siempre 0 en origen)
  event_data       text,                     -- CLAVE: contiene la expresion que disparo
                                             -- la alerta, p.ej. **ALERT (v1>92) (94 > 92)**

  replicated_at    timestamptz NOT NULL DEFAULT now(),

  -- Columnas derivadas: materializan el intervalo para no recalcularlo en cada
  -- consulta. to_timestamp() sobre epoch da timestamptz correcto sea cual sea
  -- la zona del servidor.
  started_at   timestamptz GENERATED ALWAYS AS (to_timestamp(date_epoch)) STORED,
  stored_at    timestamptz GENERATED ALWAYS AS (to_timestamp(date_store_epoch)) STORED,
  last_seen_at timestamptz GENERATED ALWAYS AS (to_timestamp(date_last_epoch)) STORED,
  ended_at     timestamptz GENERATED ALWAYS AS
                 (to_timestamp(date_epoch + COALESCE(duration,0))) STORED,

  -- Nombre e IP del equipo. Se anadieron despues de la primera version de este
  -- fichero; estan desplegadas (medido el 8-nov-2026).
  dev_name     text,
  dev_ip       text
);

-- Marca de agua del sync: MAX(date_store_epoch).
CREATE INDEX IF NOT EXISTS cnm_alerts_store_ix_watermark
  ON cnm_alerts_store (date_store_epoch DESC);

-- Union con el binding (id_metric) acotando por tiempo: patron de las vistas.
CREATE INDEX IF NOT EXISTS cnm_alerts_store_ix_metric
  ON cnm_alerts_store (id_metric, started_at DESC);

-- Barridos por ventana temporal filtrando por tipo evaluable.
CREATE INDEX IF NOT EXISTS cnm_alerts_store_ix_ventana
  ON cnm_alerts_store (started_at DESC)
  WHERE type IN ('snmp','latency','xagent');

COMMENT ON TABLE cnm_alerts_store IS
  'Espejo del historico de alertas de CNM (alerts_store). CNM lo purga por numero '
  'de filas; aqui se conserva indefinidamente. Solo lectura: lo escribe '
  'cnm_ts_sync_alerts.pl. No editar a mano.';
COMMENT ON COLUMN cnm_alerts_store.duration IS
  'Segundos. Verificado sobre 115.493 filas: duration = date_store - date en el '
  '100% de los casos. Esta CUANTIZADA al ciclo de polling (picos en 60/120/180/240 s), '
  'asi que sobreestima la caida hasta un ciclo mas el retardo de archivado '
  '(99,4% por debajo de 5 min con type IN (snmp,latency,xagent)).';
COMMENT ON COLUMN cnm_alerts_store.date_store_epoch IS
  'Instante de archivado. Es la MARCA DE AGUA del sync incremental: monotona por '
  'definicion. NO usar id_alert como marca: una alerta abierta hace meses tiene '
  'id bajo y llega al historico hoy al cerrarse; sincronizar por MAX(id_alert) '
  'perderia justo las alertas mas largas, que son las que mas pesan en el uptime.';

-- -----------------------------------------------------------------------------
-- 2. ALERTAS ABIERTAS (espejo de alerts)
--
-- Se reemplaza entera en cada pasada (son ~455 filas). Es una FOTO del momento,
-- no un historico: no tiene sentido acumularla.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cnm_alerts_open (
  id_alert        bigint,
  id_device       integer NOT NULL,
  id_metric       bigint,
  id_alert_type   integer,
  watch           text,
  severity        smallint,
  date_epoch      bigint,
  date_last_epoch bigint,
  counter         integer,
  ack             integer,
  notif           integer,
  critic          integer,
  type            text,
  subtype         text,
  mname           text    NOT NULL,
  label           text,
  cause           text,
  mode            text    NOT NULL,   -- en alerts es varchar; en alerts_store es int
  cid             text    NOT NULL,
  event_data      text,
  refreshed_at    timestamptz NOT NULL DEFAULT now(),

  started_at   timestamptz GENERATED ALWAYS AS (to_timestamp(date_epoch)) STORED,
  last_seen_at timestamptz GENERATED ALWAYS AS (to_timestamp(date_last_epoch)) STORED,

  -- Nombre e IP del equipo, como en cnm_alerts_store.
  dev_name     text,
  dev_ip       text,

  -- Misma PK que en origen: (id_device, mname, mode, cid)
  PRIMARY KEY (id_device, mname, mode, cid)
);

CREATE INDEX IF NOT EXISTS cnm_alerts_open_ix_metric ON cnm_alerts_open (id_metric);

COMMENT ON TABLE cnm_alerts_open IS
  'Foto de las alertas en curso en CNM (tabla alerts). Se reemplaza entera en '
  'cada sincronizacion. Lo escribe cnm_ts_sync_alerts.pl.';

-- =============================================================================
-- 3. VISTAS DE GOBERNANZA (deuda visible, no escondida)
-- =============================================================================

-- Frescura y volumen de la replica. Si el sync se para, esto lo delata.
CREATE OR REPLACE VIEW v_alerts_replica_health AS
SELECT count(*)                                   AS filas,
       min(stored_at)                             AS archivado_mas_antiguo,
       max(stored_at)                             AS archivado_mas_reciente,
       now() - max(stored_at)                     AS retraso_frente_a_cnm,
       max(replicated_at)                         AS ultima_sync,
       now() - max(replicated_at)                 AS antiguedad_sync,
       count(*) FILTER (WHERE id_metric = 0)      AS sin_metrica,
       count(*) FILTER (WHERE type IN ('snmp','latency','xagent')) AS evaluables
FROM cnm_alerts_store;

-- Reparto por tipo y severidad: control de que la captura no se sesga.
CREATE OR REPLACE VIEW v_alerts_replica_mix AS
SELECT type, severity, count(*) AS n,
       min(started_at) AS desde, max(started_at) AS hasta
FROM cnm_alerts_store
GROUP BY type, severity
ORDER BY type, severity;

-- Alertas abiertas persistentes. NO decide por el operador: expone el hecho.
-- Con ack=0 en las 460 abiertas y mnt=0 en todo el historico, hoy no hay forma
-- automatica de distinguir "desatendida asumida" de "incidencia real en curso".
CREATE OR REPLACE VIEW v_alerts_open_persistentes AS
SELECT id_device, id_metric, type, subtype, severity, label,
       started_at, last_seen_at, ack,
       floor(EXTRACT(epoch FROM now() - started_at)/86400)::int AS dias_abierta,
       (now() - last_seen_at > interval '1 day')                AS sin_reobservar_24h
FROM cnm_alerts_open
WHERE type IN ('snmp','latency','xagent')
  AND now() - started_at > interval '30 days'
ORDER BY started_at;

-- =============================================================================
-- 4. PERMISOS PARA EL USUARIO DE LOS SCRIPTS
--
-- El DDL se aplica como 'postgres' (propietario), pero cnm_ts_sync_alerts.pl
-- conecta con un usuario de aplicacion. Sin estos GRANT falla con
-- "permission denied for table cnm_alerts_store". TRUNCATE es un privilegio
-- APARTE en PostgreSQL: no va incluido en DELETE ni en INSERT.
--
-- Ajustar el nombre del rol si no es cnm_loader.
-- =============================================================================
\set app_user cnm_loader

GRANT SELECT, INSERT           ON cnm_alerts_store TO :app_user;
GRANT SELECT, INSERT, TRUNCATE ON cnm_alerts_open  TO :app_user;
GRANT SELECT ON v_alerts_replica_health, v_alerts_replica_mix,
                v_alerts_open_persistentes TO :app_user;

-- El script crea una tabla TEMP (stg_store) durante la carga. El privilegio
-- TEMPORARY suele estar concedido a PUBLIC por defecto; si se ha revocado:
--   GRANT TEMPORARY ON DATABASE obs TO cnm_loader;
