-- ═══════════════════════════════════════════════════════════════════════════
-- >> EJECUTAR   ·   Orden de aplicacion: 10 de 10
-- Vistas api_* y usuario cnm_api. EL ULTIMO: depende de todo.
-- Instalacion desde cero: ejecutar los ficheros por su numero de orden.
-- Instalacion en marcha: ver DOC-SEM-00 'Como se anade una columna a la replica'.
-- ═══════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- CAPA PUBLICA · superficie estable para consumidores externos
--
-- ORDEN: el ULTIMO de todos los DDL.
--
-- PARA QUE. La plataforma analitica es el punto de integracion con IA y con
-- proyectos de terceros. Un tercero no debe consultar las tablas internas:
--   - sus nombres y columnas cambian cuando cambia el modelo (ha pasado cuatro
--     veces en un mes: REV-SEM-01 a 04);
--   - contienen decisiones internas (senal_id, canal, scope) que exigen conocer
--     el modelo para no malinterpretarlas;
--   - un JOIN mal hecho sobre 217 M filas afecta a todos.
--
-- Esta capa es un CONTRATO: nombres estables, semantica documentada y una
-- promesa de compatibilidad. Lo de dentro puede cambiar; esto no, sin aviso.
--
-- CONVENCION DE NOMBRES
--   api_*  -> superficie publica. Estable. Documentada en DOC-SEM-05.
--   v_*    -> vistas internas. Pueden cambiar sin aviso.
--   sem_*, cnm_*, series* -> tablas. NO consultar directamente desde fuera.
--
-- REGLA PARA QUIEN MANTIENE ESTO: se pueden AÑADIR columnas a una vista api_*;
-- no se pueden quitar ni renombrar, ni cambiar el significado de una existente.
-- Si hace falta, se crea api_<nombre>_v2 y se mantienen ambas un tiempo.
-- =============================================================================

DROP VIEW IF EXISTS api_alertas;
DROP VIEW IF EXISTS api_salud_roles;
DROP VIEW IF EXISTS api_inventario;
DROP VIEW IF EXISTS api_metricas_dia;
DROP VIEW IF EXISTS api_diccionario;

-- -----------------------------------------------------------------------------
-- api_inventario · QUE se esta midiendo
--
-- El punto de partida de cualquier integracion: que metricas existen, que miden,
-- de que equipo son y a que servicio pertenecen.
-- -----------------------------------------------------------------------------
CREATE VIEW api_inventario AS
SELECT m.idmetric                AS metrica_id,
       m.iddev                   AS dispositivo_id,
       m.dev_name                AS dispositivo,
       m.dev_ip                  AS ip,
       m.stable_key              AS instancia,
       l.subtype                 AS tipo_metrica,
       l.canonical_id            AS concepto,
       l.concepto_nombre         AS concepto_nombre,
       l.unit                    AS unidad,
       l.direction               AS direccion,
       l.signal_class            AS clase,
       l.capacity                AS capacidad,
       -- que ES la instancia, cuando se sabe: ethernet, loopback, virtual,
       -- tunnel... Util para entender por que una interfaz no aparece en
       -- informes de capacidad. Ver REV-SEM-08.
       l.instance_kind           AS tipo_instancia,
       -- ESTADO DEL DISPOSITIVO (REV-SEM-05). Sin esto, un consumidor no puede
       -- distinguir un equipo activo de uno DE BAJA o EN MANTENIMIENTO, y los
       -- listaria todos como si fueran normales. En septiembre de 2026 hay 604
       -- equipos de una operacion retirada que aparecerian sin distintivo.
       CASE m.dev_status WHEN 0 THEN 'activo'
                         WHEN 1 THEN 'de_baja'
                         WHEN 2 THEN 'mantenimiento' END AS estado_dispositivo,
       l.role_id                 AS rol,
       l.role_display_name       AS rol_nombre,
       l.role_type               AS rol_tipo,
       l.criticality             AS criticidad,
       l.is_primary              AS es_primaria,
       l.weight                  AS peso,
       m.dev_custom              AS inventario
FROM sem_metric_map  m
JOIN sem_role_lookup l ON l.sem_instance_id = m.instance_id;

COMMENT ON VIEW api_inventario IS
  'Catalogo de lo que se mide: metrica, equipo, concepto y rol de negocio. '
  'clase = health_sli (indica si funciona) | saturation (cuanto se usa) | '
  'diagnostic (contexto). peso = 0 significa que no agrega a la salud.';

-- -----------------------------------------------------------------------------
-- api_alertas · QUE ha fallado y cuando
--
-- Una fila por alerta, cerrada o abierta, con su rol y su semantica ya resueltos.
-- Es el punto de entrada para analisis de incidencias, correlaciones o
-- entrenamiento de modelos.
-- -----------------------------------------------------------------------------
CREATE VIEW api_alertas AS
SELECT i.id_alert            AS alerta_id,
       i.started_at          AS inicio,
       i.ended_at            AS fin,
       i.abierta,
       round(i.duracion_s/60.0, 1) AS duracion_min,
       i.severity            AS severidad,
       i.type                AS origen,
       i.label               AS texto,
       i.iddev               AS dispositivo_id,
       i.dev_name            AS dispositivo,
       mm.dev_ip             AS ip,
       mm.stable_key         AS instancia,
       -- el umbral configurado en CNM, en lenguaje natural: 'Disk Usage Higher
       -- than 80%'. Permite explicar POR QUE salto la alerta sin consultar CNM.
       mm.monitor_causa      AS umbral,
       i.subtype             AS tipo_metrica,
       i.id_metric           AS metrica_id,
       i.canonical_efectivo  AS concepto,
       i.concepto_nombre     AS concepto_nombre,
       i.signal_class        AS clase,
       i.role_id             AS rol,
       i.role_display_name   AS rol_nombre,
       i.role_type           AS rol_tipo,
       i.criticality         AS criticidad,
       -- 'afecta_a_salud' en vez de exponer el canal interno: lo que un tercero
       -- necesita saber es si esta alerta cuenta para la salud del servicio.
       (i.canal IN ('salud_primaria','salud_secundaria')) AS afecta_a_salud,
       (i.canal = 'riesgo')                               AS es_riesgo,
       -- FRESCURA (REV-SEM-11, 17-sep-2026). Cuando se leyeron de CNM por ultima
       -- vez las alertas ABIERTAS: 'abierta' solo es cierta hasta ese momento. Si
       -- tiene mas de ~1 h, la replica de abiertas no se esta ejecutando. Mismo
       -- valor en todas las filas (subconsulta no correlacionada: se calcula una vez).
       (SELECT max(o.refreshed_at) FROM cnm_alerts_open o) AS ultima_lectura_alertas
FROM v_alert_intervals i
-- LEFT y DISTINCT ON: una instancia puede tener varias metricas, y no todas las
-- alertas tienen metrica en el mapa. Sin esto se multiplicarian filas.
LEFT JOIN LATERAL (SELECT m.dev_ip, m.stable_key, m.monitor_causa
                     FROM sem_metric_map m
                    WHERE m.idmetric = i.id_metric
                    LIMIT 1) mm ON true;

COMMENT ON VIEW api_alertas IS
  'Alertas con rol y semantica resueltos. Incluye abiertas (fin IS NULL). '
  'Los umbrales son los de los monitores de CNM: esta vista no reinterpreta '
  'nada, solo enriquece. ultima_lectura_alertas = cuando se leyo de CNM el estado '
  'de las abiertas; con mas de ~1 h de antiguedad, abierta no es fiable.';

-- -----------------------------------------------------------------------------
-- api_salud_roles · COMO esta cada servicio ahora
-- -----------------------------------------------------------------------------
CREATE VIEW api_salud_roles AS
SELECT role_id            AS rol,
       role_display_name  AS rol_nombre,
       role_type          AS rol_tipo,
       criticality        AS criticidad,
       estado,
       pct_caidos         AS pct_afectado,
       fiabilidad,
       n_total            AS unidades,
       n_evaluables       AS unidades_evaluables,
       n_caidos           AS unidades_afectadas,
       n_sin_dato         AS unidades_sin_dato,
       -- el umbral con el que se calculo el estado. Sin el, un consumidor no
       -- puede saber por que un rol con el 40 % afectado sale 'degraded' y otro
       -- con el 40 % sale 'down': el umbral es configurable POR ROL.
       umbral             AS umbral_down,
       dias_alerta_mas_antigua AS dias_alerta_antigua,
       n_alertas_abiertas,
       -- FRESCURA (REV-SEM-11 y DOC-SEM-10 H10, 17-sep-2026). Dos fuentes, dos
       -- columnas; mismo valor en todas las filas (se calculan una vez):
       --  ultimo_dato_plataforma: ultima muestra recibida por la PLATAFORMA, no la
       --    del rol. Si tiene mas de unos minutos, los 'unknown' se deben a que no
       --    llegan datos, no a los servicios. NULL = nada en las ultimas 24 h.
       --  ultima_lectura_alertas: cuando se leyeron de CNM las alertas abiertas.
       --    Con mas de ~1 h, 'estado' no es fiable.
       (SELECT max(s.time) FROM series s
         WHERE s.time > now() - interval '1 day')         AS ultimo_dato_plataforma,
       (SELECT max(o.refreshed_at) FROM cnm_alerts_open o) AS ultima_lectura_alertas
FROM v_role_health_now;

COMMENT ON VIEW api_salud_roles IS
  'Estado actual por rol. estado = healthy|degraded|down|unknown. '
  'fiabilidad = %% de unidades con dato: un estado con fiabilidad baja es menos '
  'de fiar. pct_afectado se calcula sobre las unidades EVALUABLES. '
  'Antes de interpretar: ultimo_dato_plataforma (minutos) y ultima_lectura_alertas '
  '(menos de ~1 h). Si alguna esta vieja, el estado no es fiable.';

-- -----------------------------------------------------------------------------
-- api_metricas_dia · SERIE TEMPORAL agregada por dia
--
-- Se expone el nivel DIARIO y no el crudo a proposito:
--   - el crudo son 217 M filas y solo conserva 90 dias;
--   - el diario cubre todo el historico y responde en segundos;
--   - para una integracion externa, la resolucion diaria cubre la practica
--     totalidad de los casos (tendencias, capacidad, informes).
-- Quien necesite resolucion fina debe pedirlo y justificarlo.
-- -----------------------------------------------------------------------------
CREATE VIEW api_metricas_dia AS
-- DOS CORRECCIONES respecto a la primera version (REV-SEM-08 y REV-SEM-09):
--
-- 1. El DS que se publica es el DECLARADO, no el 1 fijo. En disk_mibhost el
--    ds=1 es el TAMAÑO TOTAL del disco y el ds=2 el usado: con el ds=1 esta
--    vista publicaba la capacidad como si fuera el consumo, el mismo fallo que
--    hacia que el informe diera 78 de 78 discos al 100 %.
--
--    Los subtypes cuyo uso es una formula (ds_valor NULL) se EXCLUYEN
--    declarandolo, y los de varios DS -trafico RX+TX- se suman, con los
--    percentiles a NULL porque no son sumables. Ver DOC-SEM-09 §6.1.
--
-- 2. Se excluye el tramo CRUDO de los contadores SNMP. Hasta el 8-sep-2026 se
--    cargaban sin convertir a tasa: publicarlos daria 1,2 Tbps en un enlace de
--    1 Gbps. sem_counter_dict.desde marca la frontera por subtype.
SELECT d.dia,
       min(d.id_metric)                       AS metrica_id,
       i.dispositivo,
       i.instancia,
       i.concepto,
       i.unidad,
       i.rol,
       sum(d.n)                               AS muestras,
       sum(d.avg_value * d.n) / NULLIF(sum(d.n),0) * i.escala  AS media,
       sum(d.min_value) * i.escala            AS minimo,
       sum(d.max_value) * i.escala            AS maximo,
       -- percentiles solo con UN DS: el t-digest de RX mas el de TX no es el de
       -- RX+TX, asi que con varios DS no hay percentil posible.
       CASE WHEN i.n_ds = 1 THEN min(d.p50) * i.escala END AS p50,
       CASE WHEN i.n_ds = 1 THEN min(d.p95) * i.escala END AS p95,
       CASE WHEN i.n_ds = 1 THEN min(d.p99) * i.escala END AS p99,
       i.capacidad
FROM v_series_1d d
JOIN (SELECT m.idmetric, m.subtype, m.dev_name AS dispositivo,
             m.stable_key AS instancia,
             l.canonical_id AS concepto, l.unit AS unidad, l.role_id AS rol,
             l.value_scale AS escala, l.capacity AS capacidad,
             string_to_array(l.ds_valor, ',')::smallint[]  AS ds_list,
             cardinality(string_to_array(l.ds_valor, ',')) AS n_ds
        FROM sem_metric_map m
        JOIN sem_role_lookup l ON l.sem_instance_id = m.instance_id
       WHERE l.ds_valor IS NOT NULL) i
  ON i.idmetric = d.id_metric
WHERE d.ds = ANY(i.ds_list)
  AND NOT EXISTS (SELECT 1 FROM sem_counter_dict cd
                   WHERE cd.subtype = i.subtype
                     AND d.dia < cd.desde)
GROUP BY d.dia, i.dispositivo, i.instancia, i.concepto, i.unidad, i.rol,
         i.escala, i.capacidad, i.n_ds;

COMMENT ON VIEW api_metricas_dia IS
  'Serie diaria por metrica, en unidad canonica (value_scale ya aplicado). '
  'Percentiles reales, no medias de medias. Cubre todo el historico. '
  'Filtrar SIEMPRE por dia: sin filtro recorre millones de filas.';

-- -----------------------------------------------------------------------------
-- api_diccionario · el vocabulario, para no tener que preguntarlo
--
-- Un consumidor externo -o un modelo de lenguaje- necesita saber que significa
-- cada valor de las columnas categoricas. Exponerlo como datos evita que haya
-- que documentarlo en un sitio que se desactualiza.
-- -----------------------------------------------------------------------------
CREATE VIEW api_diccionario AS
SELECT * FROM (VALUES
 ('clase','health_sli','Indica si el servicio funciona. Su fallo afecta a la salud'),
 ('clase','saturation','Indica cuanto se usa de un recurso. Su fallo indica riesgo'),
 ('clase','diagnostic','Contexto para investigar. NO afecta a la salud'),
 ('clase','informative','Informativa. No agrega'),
 ('estado','healthy','Todas las unidades medidas responden bien'),
 ('estado','degraded','Alguna unidad afectada, sin superar el umbral del rol'),
 ('estado','down','Fraccion de unidades afectadas por encima del umbral'),
 ('estado','unknown','No hay dato reciente: no se puede afirmar nada'),
 ('severidad','1','Critica (roja)'),
 ('severidad','2','Mayor (naranja)'),
 ('severidad','3','Menor (amarilla)'),
 ('severidad','4','Sin dato (azul). Excluida de los calculos de salud'),
 ('direccion','higher_is_worse','Cuanto mas alto, peor'),
 ('direccion','lower_is_worse','Cuanto mas bajo, peor'),
 ('direccion','out_of_band','Malo al desviarse en cualquier sentido del valor esperado'),
 ('rol_tipo','site','Emplazamiento fisico'),
 ('rol_tipo','application','Aplicacion'),
 ('rol_tipo','technical_service','Servicio tecnico de soporte'),
 ('rol_tipo','business_process','Proceso de negocio'),
 ('rol_tipo','business_subprocess','Subproceso de negocio'),
 ('origen','snmp','Sondeo SNMP'),
 ('origen','latency','Sondeo de latencia o disponibilidad de red'),
 ('origen','xagent','Script externo o KPI personalizado'),
 -- tipo_instancia (REV-SEM-08): derivado de ifType. Explica por que una interfaz
 -- puede no aparecer en informes de capacidad.
 ('tipo_instancia','ethernet','Interfaz de red fisica'),
 ('tipo_instancia','loopback','Interfaz interna del equipo consigo mismo. NO es un enlace'),
 ('tipo_instancia','virtual','Adaptador virtual, sin enlace fisico'),
 ('tipo_instancia','tunnel','Tunel: no tiene velocidad nominal propia'),
 ('tipo_instancia','ppp','Enlace punto a punto: no declara ancho de banda'),
 ('tipo_instancia','aggregate','Agregacion de varios enlaces'),
 ('tipo_instancia','vlan','Interfaz de VLAN'),
 ('tipo_instancia','wan','Enlace de area extensa'),
 -- estado_dispositivo (REV-SEM-05): el equipo puede estar de baja o aparcado.
 ('estado_dispositivo','activo','Se sondea y genera alertas'),
 ('estado_dispositivo','de_baja','NO se sondea. No producira datos ni alertas'),
 ('estado_dispositivo','mantenimiento','Se sondea pero NO alerta: no puede aparecer como caido'),
 -- avisos sobre la propia calidad del dato
 ('nota','percentiles_trafico','El trafico suma entrada y salida, y los percentiles '
                              ||'no son sumables: p50, p95 y p99 salen vacios'),
 ('nota','maximo_trafico','Con trafico, el maximo es una COTA SUPERIOR: los picos de '
                         ||'entrada y salida pueden darse en instantes distintos'),
 ('nota','percentiles_no_promediar','La media de los p95 diarios NO es el p95 del '
                                   ||'periodo. Puede desviarse decenas de puntos'),
 -- frescura (REV-SEM-11): como saber si el estado publicado esta al dia
 ('nota','ultimo_dato_plataforma','Ultima muestra recibida por TODA la plataforma, no '
                                 ||'por el rol. Con mas de unos minutos de antiguedad, '
                                 ||'los estados unknown se deben a que no llegan datos'),
 ('nota','ultima_lectura_alertas','Momento en que se leyeron de CNM las alertas '
                                 ||'abiertas (se renueva cada hora). NO es la hora de '
                                 ||'la ultima alerta. Con mas de ~1 h, estado y abierta '
                                 ||'no son fiables'),
 ('nota','estado_instantaneo','estado refleja el instante actual: una unidad cuenta '
                             ||'como afectada si tiene ahora una alerta primaria abierta '
                             ||'y dato en los ultimos 5 min (ICMP) o 15 min (resto), sin '
                             ||'importar la antiguedad de la alerta')
) AS t(columna, valor, significado);

COMMENT ON VIEW api_diccionario IS
  'Significado de los valores categoricos de las vistas api_*. Consultable como '
  'datos para que un consumidor -humano o automatico- no dependa de documentacion externa.';

-- =============================================================================
-- USUARIO DE SOLO LECTURA para consumidores externos
--
-- Se crea SIN contrasena: asignarla fuera de este fichero para no dejarla en un
-- script versionado.
--   ALTER ROLE cnm_api WITH PASSWORD '...';
--
-- Lee las vistas api_*. No tiene acceso a las tablas ni a las vistas internas.
-- OJO (revisado 16-sep-2026, DOC-SEM-08 §11): SI puede EJECUTAR las funciones
-- SECURITY DEFINER de la cadena (f_role_health, f_informe_capacidad...), porque
-- PostgreSQL concede EXECUTE a PUBLIC por defecto. Riesgo revisado y aceptado; las
-- funciones no forman parte del contrato estable. Si se revoca a PUBLIC, conceder
-- ANTES EXECUTE a cnm_api y al usuario de la aplicacion, o api_salud_roles falla.
-- =============================================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'cnm_api') THEN
    CREATE ROLE cnm_api LOGIN;
  END IF;
END $$;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM cnm_api;
GRANT USAGE ON SCHEMA public TO cnm_api;
GRANT SELECT ON api_inventario, api_alertas, api_salud_roles,
                api_metricas_dia, api_diccionario TO cnm_api;

-- Salvaguarda: limita el tiempo de una consulta y evita que un JOIN mal hecho
-- deje el servidor ocupado indefinidamente.
ALTER ROLE cnm_api SET statement_timeout = '120s';
ALTER ROLE cnm_api SET idle_in_transaction_session_timeout = '60s';

-- =============================================================================
-- SECURITY DEFINER EN LAS FUNCIONES DE LA CADENA
--
-- POR QUE HACE FALTA. Las vistas se ejecutan con los permisos de SU PROPIETARIO
-- sobre las tablas de debajo: por eso api_salud_roles puede leer sem_role_lookup
-- aunque cnm_api no tenga acceso a esa tabla.
--
-- Pero las FUNCIONES son SECURITY INVOKER por defecto: corren con los permisos
-- de quien LLAMA. Asi que la cadena
--
--     api_salud_roles  ->  v_role_health_now  ->  f_role_health()
--          (vista, ok)        (vista, ok)          (funcion: ROMPE)
--
-- fallaba con «permission denied for view v_alert_intervals», porque la funcion
-- se ejecutaba como cnm_api y ese usuario no ve las vistas internas.
--
-- La alternativa -dar GRANT SELECT a cnm_api sobre v_alert_intervals y demas-
-- se DESCARTA: romperia el aislamiento que promete DOC-SEM-05, donde el usuario
-- externo solo debe ver las cinco vistas api_*.
--
-- EL search_path FIJO NO ES OPCIONAL. Con SECURITY DEFINER la funcion corre con
-- privilegios del propietario; sin acotar el search_path, un usuario podria
-- crear objetos en un esquema propio y desviar las referencias de la funcion
-- hacia ellos. Es la precaucion estandar para SECURITY DEFINER.
-- =============================================================================
DO $$
DECLARE f record;
BEGIN
  FOR f IN
    SELECT p.oid::regprocedure AS firma
      FROM pg_proc p
      JOIN pg_namespace n ON n.oid = p.pronamespace
     WHERE n.nspname = 'public'
       AND p.proname IN ('f_role_health','f_role_alert_time','f_device_alert_time',
                         'f_alert_context','f_unidad_legible',
                         'f_informe_capacidad','f_informe_capacidad_rol')
  LOOP
    EXECUTE format('ALTER FUNCTION %s SECURITY DEFINER', f.firma);
    EXECUTE format('ALTER FUNCTION %s SET search_path = public, pg_temp', f.firma);
  END LOOP;
END $$;

\set app_user cnm_loader
GRANT SELECT ON api_inventario, api_alertas, api_salud_roles,
                api_metricas_dia, api_diccionario TO :app_user;
