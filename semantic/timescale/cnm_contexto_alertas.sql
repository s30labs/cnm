-- =============================================================================
-- CONTEXTO SEMANTICO DE ALERTAS
--
-- ORDEN: DESPUES de cnm_vistas_intervalos.sql y cnm_vistas_estado.sql.
--
-- QUE ES Y QUE NO ES.
--   NO es analisis de causa raiz. No infiere causalidad ni propone culpables:
--   eso exige un modelo de dependencias que no tenemos y produce conclusiones
--   dificiles de auditar.
--
--   SI es CONTEXTO: responder, para una alerta concreta, las preguntas que un
--   operador se hace antes de actuar y que hoy exigen abrir cinco pantallas:
--     - ¿que mide realmente esta metrica?
--     - ¿a que servicio afecta y como de critico es?
--     - ¿esta pasando algo mas en el mismo equipo ahora mismo?
--     - ¿le pasa a mas equipos del mismo rol?
--     - ¿es la primera vez o lleva meses repitiendose?
--     - ¿es un parpadeo o algo que dura?
--
--   La diferencia con el RCA es deliberada: aqui todo lo que se muestra es un
--   HECHO OBSERVADO, no una inferencia. El operador saca la conclusion.
-- =============================================================================

DROP VIEW IF EXISTS v_alert_context;
DROP FUNCTION IF EXISTS f_alert_context(bigint);

-- -----------------------------------------------------------------------------
-- 1. CONTEXTO DE UNA ALERTA CONCRETA
--
-- Recibe un id_alert y devuelve UNA fila con todo lo que se sabe alrededor.
-- Pensado para ser el "dame contexto" de una consola, un chat o un correo.
-- -----------------------------------------------------------------------------
CREATE FUNCTION f_alert_context(p_id_alert bigint)
RETURNS TABLE (
  -- la alerta
  id_alert            bigint,
  inicio              timestamptz,
  fin                 timestamptz,
  abierta             boolean,
  duracion_min        numeric,
  severidad           smallint,
  texto               text,
  expresion           text,

  -- QUE se mide (semantica)
  que_mide            text,
  concepto            text,
  unidad              text,
  direccion           text,
  clase_senal         text,
  es_primaria         boolean,

  -- DONDE (identidad)
  dispositivo         text,
  ip                  text,
  instancia           text,

  -- A QUIEN afecta (negocio)
  rol                 text,
  rol_nombre          text,
  tipo_rol            text,
  criticidad          smallint,
  estado_del_rol      text,
  pct_rol_afectado    numeric,

  -- HISTORIA de esta misma senal
  veces_30d           bigint,
  veces_90d           bigint,
  minutos_30d         numeric,
  primera_vez         timestamptz,
  duracion_media_min  numeric,
  patron              text,

  -- QUE MAS pasa alrededor (hechos, no causas)
  otras_del_equipo    bigint,
  otras_del_rol       bigint,
  simultaneas_15min   bigint,
  detalle_simultaneas text
)
LANGUAGE sql STABLE
AS $$
WITH a AS (
  SELECT * FROM v_alert_intervals WHERE id_alert = p_id_alert LIMIT 1
),
-- Historia de la MISMA senal logica, no solo de la misma metrica: si CNM
-- reasigno el id_metric, o si la pareja ICMP alterna, sigue siendo el mismo
-- problema del mismo equipo.
hist AS (
  SELECT count(*)                                                  AS veces_total,
         count(*) FILTER (WHERE i.started_at > now() - interval '30 days') AS veces_30d,
         count(*) FILTER (WHERE i.started_at > now() - interval '90 days') AS veces_90d,
         sum(i.duracion_s) FILTER (WHERE i.started_at > now() - interval '30 days')
           / 60.0                                                  AS minutos_30d,
         min(i.started_at)                                         AS primera_vez,
         avg(i.duracion_s) / 60.0                                  AS dur_media_min
  FROM v_alert_intervals i, a
  WHERE i.senal_id = a.senal_id AND i.role_id = a.role_id
),
-- Vecindad: que MAS estaba alertando en el mismo equipo y en el mismo rol
-- cuando empezo esta. Es correlacion temporal, NO causalidad.
vecindad AS (
  SELECT count(*) FILTER (WHERE i.iddev = a.iddev)                 AS del_equipo,
         count(*) FILTER (WHERE i.role_id = a.role_id)             AS del_rol,
         count(*) FILTER (WHERE i.started_at
                                BETWEEN a.started_at - interval '15 minutes'
                                    AND a.started_at + interval '15 minutes') AS simultaneas,
         string_agg(DISTINCT
                    CASE WHEN i.started_at
                              BETWEEN a.started_at - interval '15 minutes'
                                  AND a.started_at + interval '15 minutes'
                         THEN COALESCE(i.dev_name,'dev'||i.iddev)||' · '||i.canonical_id
                    END, E'\n' ) AS detalle
  FROM v_alert_intervals i, a
  WHERE i.id_alert <> a.id_alert
    AND i.rango && tstzrange(a.started_at - interval '15 minutes',
                             COALESCE(a.ended_at, now()) + interval '15 minutes')
),
salud AS (
  SELECT h.estado, h.pct_caidos
  FROM a, LATERAL f_role_health(COALESCE(a.ended_at, now())) h
  WHERE h.role_id = a.role_id
)
SELECT a.id_alert, a.started_at, a.ended_at, a.abierta,
       round(a.duracion_s/60.0, 1), a.severity, a.label,
       -- la expresion que disparo la alerta: el dato mas util para entender el
       -- umbral, y hoy solo visible abriendo la alerta en CNM
       (SELECT substring(s.event_data from '\*\*ALERT[^*]*')
          FROM cnm_alerts_store s WHERE s.id_alert = a.id_alert
         UNION ALL
        SELECT substring(o.event_data from '\*\*ALERT[^*]*')
          FROM cnm_alerts_open o WHERE o.id_alert = a.id_alert
         LIMIT 1),

       a.concepto_nombre, a.canonical_efectivo, a.unit, a.direccion,
       a.signal_class, a.is_primary,

       COALESCE(a.dev_name, 'dev'||a.iddev), m.dev_ip, a.subtype,

       a.role_id, a.role_display_name, a.role_type, a.criticality,
       s.estado, s.pct_caidos,

       h.veces_30d, h.veces_90d, round(h.minutos_30d, 1), h.primera_vez,
       round(h.dur_media_min, 1),
       -- Patron: la combinacion frecuencia/duracion dice mas que cualquiera de
       -- las dos por separado.
       CASE
         WHEN h.veces_30d IS NULL OR h.veces_30d <= 1 THEN 'primera vez en 30 dias'
         WHEN h.dur_media_min < 15 AND h.veces_30d > 20 THEN
              'PARPADEO RECURRENTE: '||h.veces_30d||' veces en 30 dias, media '
              ||round(h.dur_media_min,1)||' min'
         WHEN h.dur_media_min > 1440 THEN
              'CAIDAS LARGAS: media '||round(h.dur_media_min/1440,1)||' dias'
         WHEN h.veces_30d > 10 THEN
              'RECURRENTE: '||h.veces_30d||' veces en 30 dias'
         ELSE 'ocasional: '||h.veces_30d||' veces en 30 dias'
       END,

       v.del_equipo, v.del_rol, v.simultaneas, v.detalle
FROM a
LEFT JOIN sem_metric_map m ON m.idmetric = a.id_metric
CROSS JOIN hist h
CROSS JOIN vecindad v
LEFT JOIN salud s ON true;
$$;

COMMENT ON FUNCTION f_alert_context(bigint) IS
  'Contexto semantico de una alerta: que mide, a quien afecta, si es recurrente '
  'y que mas pasaba alrededor. NO hace analisis de causa raiz: todo lo que '
  'devuelve es un hecho observado, no una inferencia.';

-- -----------------------------------------------------------------------------
-- 2. LAS ALERTAS ABIERTAS, YA CON CONTEXTO
--
-- El caso de uso diario: "que tengo encima de la mesa y por donde empiezo".
-- Ordenada por criticidad del rol y luego por antiguedad.
-- -----------------------------------------------------------------------------
CREATE VIEW v_alert_context AS
SELECT i.id_alert,
       i.started_at,
       round(EXTRACT(epoch FROM (now() - i.started_at))/3600.0, 1) AS horas_abierta,
       i.severity                                                  AS severidad,
       COALESCE(i.dev_name, 'dev'||i.iddev)                        AS dispositivo,
       i.subtype                                                   AS instancia,
       i.concepto_nombre                                           AS que_mide,
       i.canonical_efectivo                                        AS concepto,
       i.role_id                                                   AS rol,
       i.role_display_name                                         AS rol_nombre,
       i.criticality                                               AS criticidad,
       i.canal,
       -- recurrencia de esta misma senal, resuelta en la propia vista
       (SELECT count(*) FROM v_alert_intervals x
         WHERE x.senal_id = i.senal_id AND x.role_id = i.role_id
           AND x.started_at > now() - interval '30 days')          AS veces_30d,
       i.label                                                     AS texto
FROM v_alert_intervals i
WHERE i.abierta
  AND i.canal <> 'no_agrega'
ORDER BY i.criticality NULLS LAST, i.started_at;

COMMENT ON VIEW v_alert_context IS
  'Alertas abiertas con su contexto minimo: que mide, a que servicio afecta, '
  'cuanto lleva y si es recurrente. Para el detalle completo de una, '
  'f_alert_context(id_alert).';

\set app_user cnm_loader
GRANT SELECT  ON v_alert_context TO :app_user;
GRANT EXECUTE ON FUNCTION f_alert_context(bigint) TO :app_user;
