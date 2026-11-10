-- ═══════════════════════════════════════════════════════════════════════════
-- >> EJECUTAR   ·   Orden de aplicacion: 7 de 10
-- Informe de capacidad.
-- Instalacion desde cero: ejecutar los ficheros por su numero de orden.
-- Instalacion en marcha: ver DOC-SEM-00 'Como se anade una columna a la replica'.
-- ═══════════════════════════════════════════════════════════════════════════

-- =============================================================================
-- INFORME DE CAPACIDAD Y DISPONIBILIDAD  ·  sustituye al generado desde RRDs
--
-- ORDEN: DESPUES de sem_role_lookup.sql, cnm_vistas_intervalos.sql y
--        cnm_vistas_estado.sql.
--
-- FUENTE: series_1h (continuous aggregate), NO el crudo. Medido sobre 8 dias:
--   crudo 33,9 s  |  series_1h 10,6 s  (3,2x mas rapido, 13x menos filas).
--
-- RENDIMIENTO ACTUAL, medido en septiembre de 2026 sobre un MES completo:
--   ~38 s para 1.189 filas de salida, con 6,5 GB leidos de disco.
--
--   El coste esta en leer un mes de series_1h, que esta COMPRIMIDO: el acceso
--   por indice no evita descomprimir el bloque entero. Se intentaron dos
--   optimizaciones sin ganancia apreciable:
--     - unificar dos escaneos en uno con FILTER: mismo numero de filas leidas,
--       36,6 s -> 38,4 s. No reduce el trabajo, solo lo reorganiza.
--     - un CTE aparte para el DS de capacidad: peor, añadia un segundo escaneo.
--
--   NO se optimiza mas a proposito: es un informe MENSUAL. Las alternativas
--   -no comprimir series_1h, materializar el resultado- cuestan disco o
--   complejidad para ganar segundos en algo que se ejecuta doce veces al año.
--
--   Ojo al comparar cifras: el informe pasó de ~167 a 1.189 filas al tomar la
--   capacidad del dato medido (REV-SEM-08), asi que no es la misma carga.
--   Extrapolado a un mes: ~2,2 min frente a ~41 s.
--   Se pierde precision en el MOMENTO del maximo (hora en vez de segundo) y los
--   percentiles pasan a ser aproximados (t-digest, error tipico <1%). A cambio
--   el informe no depende de la retencion de 90 dias del crudo.
--
-- QUE CORRIGE DEL INFORME ACTUAL (2026-07-CNM-Report.csv, 122 filas):
--   a. Los max/min eran de un RRA que abarca AÑOS: 121 de 122 filas tenian
--      marcas de tiempo de 2023, 2024 o 2025 en un informe titulado "julio 2026".
--      Aqui son de la ventana pedida, sin excepcion.
--   b. La lista de servidores era un fichero de configuracion; aqui sale del ROL.
--   c. La mediana era aproximada por consolidacion RRD; aqui hay percentiles
--      reales (p50, p95, p99).
--   d. No aplicaba value_scale: valores de fuentes distintas no eran comparables.
--   e. No informaba de la COBERTURA del dato (cuantos dias hubo medida).
--
-- LIMITE: series arranca el 2026-07-22. El primer mes natural completo es
--   agosto de 2026.
--
-- PL/pgSQL Y NO SQL (noviembre de 2026). Las dos funciones eran LANGUAGE sql.
--   Al hacerlas SECURITY DEFINER con search_path fijo (cnm_api_publica.sql,
--   septiembre de 2026) PostgreSQL deja de integrarlas en la consulta que las
--   llama y, en PostgreSQL 17, las planifica con PLAN GENERICO: sin conocer
--   p_desde ni p_hasta ni el rol. Medido en wwcnmtmdbprd01 el 8/9-nov-2026,
--   octubre completo, mismo cuerpo:
--     plan generico     (lo que hacia la funcion)  1.210 s
--     plan con valores                              138 s
--   El generico estimaba 15 instancias (habia 3.046) y metia el CTE hist dentro
--   de un bucle anidado: se repetia una vez por fila. PL/pgSQL usa la cache de
--   planes y, con plan_cache_mode = force_custom_plan, planifica SIEMPRE con
--   los valores de la llamada. Sigue siendo SECURITY DEFINER: la PoC llama a
--   estas funciones como cnm_api (REF-SEM-API-Externa §11).
--
--   #variable_conflict use_column: en PL/pgSQL las columnas de RETURNS TABLE
--   son variables, y chocan con las columnas del mismo nombre del cuerpo
--   (role_id, subtype...). Asi se resuelven a la columna, como en SQL.
--
--   Dos columnas llevan ahora conversion explicita a bigint: n_muestras y los
--   dos contadores de incidencias del resumen por rol salen de sum(bigint),
--   que es numeric. LANGUAGE sql la hacia implicita; RETURN QUERY exige el
--   tipo exacto. El valor no cambia: son sumas de enteros.
--
-- p_roles (noviembre de 2026). LISTA de roles, alternativa al patron. Filtra
--   en inst, ANTES de leer las series. Hasta ahora cnm_informe_csv.pl filtraba
--   las listas FUERA (WHERE role_id = ANY), asi que calculaba todos los roles
--   para quedarse con cinco. Va al final y con DEFAULT NULL: las llamadas de
--   dos, tres o cuatro argumentos siguen valiendo.
--
-- hist POR ROL E INSTANCIA (noviembre de 2026). Agrupaba solo por instancia y
--   se cruzaba solo por instancia, cuando todo lo demas va por (rol,
--   instancia). Una instancia en dos roles, con los dos en el calculo, metia
--   dos veces cada dato diario en su historia: el resultado dependia de que
--   roles se pidieran. tendencia_3m no cambia (la regresion es invariante al
--   duplicar) y p95_mes_anterior tampoco con UddSketch (dobla cada cubeta).
--   Medido el 9-nov-2026 en produccion: 0 instancias de saturacion en mas de
--   un rol; pct_sketch es uddsketch; en 2.514 series de septiembre, duplicar no
--   cambia el p95 (diferencia maxima 0). Sin efecto hoy: se corrige para que
--   no dependa del filtro ni del algoritmo del sketch.
--
-- USO Y TOTAL SEPARADOS (noviembre de 2026). bkt lee del agregado horario
--   los DS del uso (ds_valor) Y el del total (ds_total), porque de este saca
--   la capacidad. Pero agregaba TODAS las filas en n, minimo, maximo, media,
--   ultimo y en el sketch: solo total_ds filtraba. En disk_mibhost (uso en
--   ds 2, total en ds 1; 1.647 instancias de saturacion el 10-nov-2026) el
--   sketch mezclaba uso y total y el p95 caia en el total. Medido el
--   9-nov-2026, fragodbprd01 C:, octubre: el informe daba p95 59,54 GiB y 100 %;
--   el p95 del uso (ds 2) es 36,84 GiB, un 61,9 % de 59,51. Es el sintoma de
--   REV-SEM-Metrica-de-Capacidad, que volvio con el OR h.ds = i.ds_total.
--   Ahora todo lo que es uso se agrega con FILTER sobre ds_list, y el total
--   solo da total_ds. Las instancias sin ds_total no cambian: para ellas el
--   FILTER deja pasar todas las filas.
--
-- DESEMPATES (noviembre de 2026). Cinco sitios elegian entre empates sin
--   criterio, y el resultado dependia del plan. Medido en el ensayo del
--   9-nov-2026: con el plan nuevo cambiaron peor_instancia en dos roles (45
--   instancias al 100 % en uno) y ultimo en una interfaz. Ahora:
--     inst          con varias metricas en la instancia, la mas reciente
--     last_v        idem: a igual DS, la metrica mas reciente
--     momento_max   a igual maximo, la ULTIMA hora en que se alcanzo: dice
--                   si el recurso seguia al maximo al final del periodo. La
--                   version anterior devolvia una cualquiera de las empatadas
--     peor          a igual porcentaje, orden por bytes (COLLATE "C") de
--                   dispositivo e instancia. No por la saturacion sin recortar: casi todas
--                   superan la capacidad en menos del 1 %, dentro del error del
--                   sketch; seria ordenar por ruido
--     ORDER BY      la instancia como ultima clave
-- =============================================================================

DROP FUNCTION IF EXISTS f_unidad_legible(text, double precision);
DROP VIEW IF EXISTS v_informe_capacidad_ejemplo;
DROP FUNCTION IF EXISTS f_informe_capacidad_rol(timestamptz, timestamptz, text);
DROP FUNCTION IF EXISTS f_informe_capacidad_rol(timestamptz, timestamptz, text, numeric);
DROP FUNCTION IF EXISTS f_informe_capacidad_rol(timestamptz, timestamptz, text, numeric, text[]);
-- Se sueltan TODAS las firmas: PostgreSQL admite sobrecarga, asi que sin esto
-- quedarian la version antigua y la nueva conviviendo, y las llamadas de tres
-- argumentos serian ambiguas.
DROP FUNCTION IF EXISTS f_informe_capacidad(timestamptz, timestamptz, text);
DROP FUNCTION IF EXISTS f_informe_capacidad(timestamptz, timestamptz, text, numeric);
DROP FUNCTION IF EXISTS f_informe_capacidad(timestamptz, timestamptz, text, numeric, text[]);

-- -----------------------------------------------------------------------------
-- 0. UNIDAD DE PRESENTACION
--
-- Los bytes en crudo son ilegibles: 63898120192 no dice nada, 59,51 GB si. Se
-- elige UN factor por instancia -segun su MAXIMO- y se aplica a todas sus
-- columnas, de modo que los valores de una misma fila siguen siendo comparables
-- entre si. No se mezcla MB en una columna y GB en otra.
--
-- Devuelve (factor, etiqueta). Solo escala unidades acumulativas; pct, ms, state
-- y similares se dejan como estan.
-- -----------------------------------------------------------------------------
CREATE FUNCTION f_unidad_legible(p_unit text, p_max double precision)
RETURNS TABLE (factor double precision, etiqueta text)
LANGUAGE sql IMMUTABLE PARALLEL SAFE
AS $$
SELECT * FROM (VALUES (
  CASE
    WHEN p_unit IN ('bytes','B') THEN
      CASE WHEN p_max >= 1024.0^4 THEN 1024.0^4
           WHEN p_max >= 1024.0^3 THEN 1024.0^3
           WHEN p_max >= 1024.0^2 THEN 1024.0^2
           WHEN p_max >= 1024.0   THEN 1024.0
           ELSE 1 END
    WHEN p_unit IN ('bps','bits_per_second') THEN
      CASE WHEN p_max >= 1e9 THEN 1e9
           WHEN p_max >= 1e6 THEN 1e6
           WHEN p_max >= 1e3 THEN 1e3
           ELSE 1 END
    ELSE 1
  END,
  CASE
    WHEN p_unit IN ('bytes','B') THEN
      CASE WHEN p_max >= 1024.0^4 THEN 'TB'
           WHEN p_max >= 1024.0^3 THEN 'GB'
           WHEN p_max >= 1024.0^2 THEN 'MB'
           WHEN p_max >= 1024.0   THEN 'KB'
           ELSE 'bytes' END
    WHEN p_unit IN ('bps','bits_per_second') THEN
      CASE WHEN p_max >= 1e9 THEN 'Gbps'
           WHEN p_max >= 1e6 THEN 'Mbps'
           WHEN p_max >= 1e3 THEN 'Kbps'
           ELSE 'bps' END
    ELSE COALESCE(p_unit,'')
  END
)) AS t(f, e);
$$;

COMMENT ON FUNCTION f_unidad_legible(text, double precision) IS
  'Elige factor y etiqueta de presentacion segun el maximo de la instancia. '
  'Un unico factor por fila: las columnas de una misma fila son comparables.';

-- -----------------------------------------------------------------------------
-- 1. DETALLE POR INSTANCIA  (un disco, una interfaz, un KPI...)
--
-- Incluye el tiempo en alerta DE ESA INSTANCIA, no del rol: asi la columna es
-- sumable y sustituye limpiamente al "Time Above High Level" del informe actual,
-- que tambien era por metrica. El agregado por rol esta en la funcion 2.
-- -----------------------------------------------------------------------------
CREATE FUNCTION f_informe_capacidad(
  p_desde        timestamptz,
  p_hasta        timestamptz,
  p_role_pattern text DEFAULT '%',
  -- REV-SEM-08 · umbral de relevancia para TRAFICO, en % de la capacidad.
  --
  -- De 1.139 interfaces monitorizadas, el 92 % mueve menos del 1 % de su
  -- capacidad: puertos de acceso, interfaces de gestion, enlaces de reserva.
  -- Listarlas todas hace ilegible el informe sin aportar nada.
  --
  -- El criterio es el PORCENTAJE, no los Mbps: un enlace de 100 Mbps al 15 %
  -- importa mas que uno de 10 Gbps al 0,5 %, aunque el segundo mueva mas.
  --
  -- Se filtra en la PRESENTACION, no en el calculo: las interfaces se procesan
  -- igual y estan disponibles si se pregunta por una concreta. Con 0 se ven
  -- todas.
  --
  -- Solo afecta al trafico. El resto de conceptos no se filtra nunca: un disco
  -- al 3 % sigue siendo informacion util para dimensionar.
  p_umbral_trafico numeric DEFAULT 1.0,
  -- LISTA de roles. NULL = sin lista: manda p_role_pattern. Con lista se
  -- aplican los dos filtros a la vez (el patron por defecto, '%', no filtra).
  p_roles        text[] DEFAULT NULL
)
RETURNS TABLE (
  role_id            text,
  role_display_name  text,
  role_type          text,
  criticality        smallint,
  dispositivo        text,
  ip                 text,
  iddev              bigint,
  instancia          text,
  subtype            text,
  canonical_id       text,
  unidad             text,      -- unidad de PRESENTACION (GB, Mbps, pct...)
  unidad_canonica    text,      -- la del concepto, sin escalar
  signal_class       text,
  -- cobertura del dato
  n_muestras         bigint,
  horas_con_dato     bigint,
  pct_cobertura      numeric,
  -- estadisticos, en la unidad de PRESENTACION (mismo factor en toda la fila)
  minimo             numeric,
  maximo             numeric,
  momento_max        timestamptz,
  media              numeric,
  p50                numeric,
  p95                numeric,
  p99                numeric,
  ultimo             numeric,
  -- capacidad
  capacidad          numeric,
  pct_p95_capacidad  numeric,
  aviso_capacidad    text,
  aviso_valor        text,
  desviacion         text,
  -- EVOLUCION HISTORICA. Sale de series_1d, que se conserva indefinidamente,
  -- asi que no depende de la retencion del crudo ni del horario.
  p95_mes_anterior   numeric,   -- el mismo p95, del mes previo
  variacion_pp       numeric,   -- diferencia en puntos porcentuales
  tendencia_3m       numeric,   -- puntos por mes, recta sobre 3 meses
  meses_hasta_90pct  numeric,   -- (90 - pct actual) / tendencia
  -- disponibilidad de ESTA instancia
  minutos_en_alerta  numeric,
  n_incidencias      bigint,
  pct_tiempo_alerta  numeric,
  -- contexto
  ventana_en_curso   boolean,
  dev_custom         jsonb
)
LANGUAGE plpgsql STABLE PARALLEL SAFE SECURITY DEFINER
SET search_path = public, pg_temp
SET plan_cache_mode = force_custom_plan
AS $$
#variable_conflict use_column
BEGIN
RETURN QUERY
WITH ventana AS (
  -- La ventana se RECORTA a now() si aun no ha terminado. Sin esto, un informe
  -- de agosto lanzado el dia 12 dividiria entre las 744 horas del mes completo y
  -- daria 35% de cobertura a metricas medidas al 100% de lo transcurrido.
  -- Verificado: 262 horas con dato sobre 262 transcurridas se reportaban como 35,2%.
  SELECT tstzrange(p_desde, LEAST(p_hasta, now()), '[)')                AS v,
         EXTRACT(epoch FROM (LEAST(p_hasta, now()) - p_desde))::numeric AS segs,
         GREATEST(1, floor(EXTRACT(epoch FROM (LEAST(p_hasta, now()) - p_desde))/3600)::bigint) AS horas,
         (p_hasta > now())                                              AS ventana_en_curso
),
-- Una fila por instancia con su escala y capacidad. IMPRESCINDIBLE:
-- sem_role_lookup puede tener varias filas por instancia (multi-rol), y
-- multiplicar por value_scale DENTRO de un agregado que lo lleva en el GROUP BY
-- producia percentiles multiplicados varias veces. Sintoma real: el p50 de un
-- disco salia 10.000 veces mayor que su media.
inst AS (
  SELECT DISTINCT ON (l.role_id, m.instance_id)
         l.role_id, m.instance_id, m.iddev,
         l.value_scale, l.capacity, l.unit, l.canonical_id, l.subtype,
         l.ds_valor, l.ds_total, l.instance_kind,
         -- ds_valor es texto ('2', '1,2'): se convierte a array para poder
         -- filtrar con ANY() y saber cuantos DS hay que sumar.
         string_to_array(l.ds_valor, ',')::smallint[]        AS ds_list,
         cardinality(string_to_array(l.ds_valor, ','))       AS n_ds,
         l.plausible_min, l.plausible_max,
         l.signal_class, l.role_display_name, l.role_type, l.criticality,
         m.stable_key, m.dev_name, m.dev_ip, m.dev_custom
  FROM sem_role_lookup l
  JOIN sem_metric_map  m ON m.instance_id = l.sem_instance_id
  WHERE l.role_id LIKE p_role_pattern
    AND (p_roles IS NULL OR l.role_id = ANY (p_roles))
    -- SOLO saturacion. Las health_sli quedan fuera a proposito: sus valores son
    -- codigos de estado (1=Disponible, 3=No disponible) o latencias donde lo que
    -- importa es si responde, no cuanto tarda. Un p95 sobre un enumerado de
    -- estados no significa nada. Su informacion util -disponibilidad- esta en el
    -- fichero de roles y en f_role_health.
    AND l.signal_class = 'saturation'
    -- REV-SEM-08 · SOLO subtypes reducibles a UN DS.
    --
    -- ds_valor NULL  -> el uso es una formula (ucd_cpu_usage = 100-o1,
    --                   ucd_mem_swap = o2-o1). Se EXCLUYE declarandolo, en vez
    --                   de publicar un numero equivocado. Son 17 metricas.
    -- ds_valor con varios DS -> SI entra: se suman. Ver el CTE bkt.
    AND l.ds_valor IS NOT NULL
  -- desempate: con varias metricas en la instancia, la mas reciente
  ORDER BY l.role_id, m.instance_id, m.idmetric DESC
),
-- Estadisticos desde el agregado horario, SIN escalar todavia.
--   La media se pondera por n: un bucket con 12 muestras y otro con 288 no pesan
--   igual. avg(avg_value) daria un resultado sesgado.
--   rollup() combina los t-digest horarios: el percentil del periodo es correcto,
--   no una media de percentiles.
-- SUMA DE LOS DS DEL USO, POR BUCKET (REV-SEM-08).
--
-- Para casi todos los subtypes ds_valor es UN solo DS y este CTE no cambia nada.
-- Para el trafico son dos -RX y TX-, porque comparten enlace y lo que satura es
-- la suma: un enlace de 1 Gbps con 600 Mbps de RX y 500 de TX esta al 110 %,
-- aunque ninguno por separado llegue al 60 %.
--
-- Sumar AQUI, por bucket, y no despues, es lo que hace que la media salga
-- exacta: avg(rx+tx) por hora, y luego la media ponderada de las horas.
bkt AS (
  SELECT i.role_id, i.instance_id, i.iddev, i.n_ds, h.bucket,
         -- SOLO los DS del uso (ds_valor). El JOIN trae tambien las filas del
         -- DS del total (ds_total), que solo sirven para total_ds: sin este
         -- FILTER, en disk_mibhost el sketch mezclaba uso y total y el p95 caia
         -- en el total (todos los discos al 100 %), ultimo era el total y
         -- minimo/maximo/media y n sumaban los dos. Ver la cabecera.
         sum(h.n)                FILTER (WHERE h.ds = ANY(i.ds_list)) AS n,
         sum(h.min_value)        FILTER (WHERE h.ds = ANY(i.ds_list)) AS min_v,
         sum(h.max_value)        FILTER (WHERE h.ds = ANY(i.ds_list)) AS max_v,
         sum(h.avg_value * h.n)  FILTER (WHERE h.ds = ANY(i.ds_list))
           / NULLIF(sum(h.n)     FILTER (WHERE h.ds = ANY(i.ds_list)), 0) AS avg_v,
         (array_agg(h.last_value ORDER BY h.ds, h.id_metric DESC) FILTER (WHERE h.ds = ANY(i.ds_list)))[1] AS last_v,
         -- con UN solo DS, rollup de un unico sketch devuelve ese sketch.
         -- Con varios seria incorrecto, por eso est solo lo usa si n_ds = 1.
         rollup(h.pct_sketch)    FILTER (WHERE h.ds = ANY(i.ds_list)) AS sk,
         -- la capacidad, si el subtype la trae en un DS
         max(h.max_value) FILTER (WHERE h.ds = i.ds_total) AS total_ds
  FROM inst i
  JOIN sem_metric_map m2 ON m2.instance_id = i.instance_id
  JOIN series_1h      h  ON h.id_metric    = m2.idmetric
  WHERE h.bucket >= p_desde AND h.bucket < LEAST(p_hasta, now())
    AND (h.ds = ANY(i.ds_list) OR h.ds = i.ds_total)
    AND h.n > 0
    -- REV-SEM-09 · el tramo CRUDO de los contadores SNMP queda fuera.
    --
    -- Hasta el 8-sep-2026 los contadores se cargaban sin convertir: el valor era
    -- el acumulado del agente, no una tasa. Sin este filtro, un informe de
    -- agosto publicaria 1.316 Gbps en un enlace de 1 Gbps.
    --
    -- sem_counter_dict.desde marca, por subtype, cuando el loader empezo a
    -- convertirlo. El histórico anterior sigue almacenado -borrarlo costaba mas
    -- que dejarlo- pero NO se publica.
    AND NOT EXISTS (
          SELECT 1 FROM sem_counter_dict cd
           WHERE cd.subtype = i.subtype
             AND h.bucket   < cd.desde)
  GROUP BY 1,2,3,4,5
),
est AS (
  -- Agrega sobre bkt, que ya trae los DS sumados por hora.
  --
  -- QUE SALE EXACTO CON VARIOS DS Y QUE NO:
  --   media   -> EXACTA. La media es lineal.
  --   maximo  -> COTA SUPERIOR: max(rx)+max(tx) >= max(rx+tx), porque los picos
  --              pueden darse en instantes distintos. Conservador: si esa cota
  --              esta holgada, el enlace lo esta con certeza.
  --   minimo  -> cota INFERIOR, por lo mismo.
  --   p50/p95/p99 -> NULL. Los percentiles NO se pueden sumar: el t-digest de RX
  --              mas el de TX no es el de RX+TX. Obtenerlos exigiria un agregado
  --              continuo que sumase antes de construir el sketch: ~16 GB a 2
  --              años y no reconstruible pasados 90 dias de retencion del crudo.
  --              Se dejan vacios DECLARANDOLO. Ver DOC-SEM-09 §6.
  SELECT b.role_id, b.instance_id, b.iddev,
         -- Una hora con dato del total pero no del uso llega de bkt con n NULL:
         -- no cuenta como hora con dato ni aporta valores. Sin DS de uso en
         -- toda la ventana, la instancia sale como SIN DATO (p95 NULL) y no
         -- desaparece del informe.
         COALESCE(sum(b.n), 0)                           AS n_muestras,
         count(b.n)                                      AS horas_con_dato,
         min(b.min_v)                                    AS minimo_raw,
         max(b.max_v)                                    AS maximo_raw,
         sum(b.avg_v * b.n) / NULLIF(sum(b.n),0)         AS media_raw,
         CASE WHEN min(b.n_ds) = 1 AND count(b.sk) > 0
              THEN approx_percentile(0.50, rollup(b.sk) FILTER (WHERE b.sk IS NOT NULL)) END AS p50_raw,
         CASE WHEN min(b.n_ds) = 1 AND count(b.sk) > 0
              THEN approx_percentile(0.95, rollup(b.sk) FILTER (WHERE b.sk IS NOT NULL)) END AS p95_raw,
         CASE WHEN min(b.n_ds) = 1 AND count(b.sk) > 0
              THEN approx_percentile(0.99, rollup(b.sk) FILTER (WHERE b.sk IS NOT NULL)) END AS p99_raw,
         (array_agg(b.last_v ORDER BY b.bucket DESC) FILTER (WHERE b.n IS NOT NULL))[1] AS ultimo_raw,
         (array_agg(b.bucket ORDER BY b.max_v DESC NULLS LAST, b.bucket DESC)
            FILTER (WHERE b.n IS NOT NULL))[1]           AS momento_max,
         max(b.total_ds)                                 AS total_ds
  FROM bkt b
  GROUP BY 1,2,3
),
-- EVOLUCION HISTORICA · de series_1d, no del horario.
--
-- POR QUE series_1d Y NO series_1h:
--   series_1d tiene retencion INDEFINIDA. El horario guarda 2 años y el crudo
--   90 dias, asi que para comparar con hace 3 meses el diario es la unica
--   fuente que estara siempre.
--
-- QUE CALCULA:
--   mes_ant  -> el p95 del mes natural anterior a la ventana
--   pend     -> puntos porcentuales por mes, con una regresion lineal sobre los
--               p95 mensuales de los 3 meses previos
--
-- LIMITE IMPORTANTE: con menos de 3 meses de historia la pendiente no es
-- fiable, asi que sale NULL. Mejor una columna vacia que un numero inventado:
-- en septiembre de 2026 el sistema solo tiene 47 dias de datos.
hist AS (
  SELECT i.role_id, i.instance_id,
         -- p95 del mes anterior a la ventana
         -- Con varios DS el percentil no es sumable (ver est), asi que no se
         -- publica historico de percentiles para trafico.
         CASE WHEN min(i.n_ds) = 1 THEN
           approx_percentile(0.95, rollup(d.pct_sketch)
             FILTER (WHERE d.dia >= date_trunc('month', p_desde) - interval '1 month'
                       AND d.dia <  date_trunc('month', p_desde)))
         END                                                              AS p95_ant,
         -- pendiente: puntos por mes sobre los 3 meses previos.
         -- regr_slope da unidades por DIA, asi que se multiplica por 30.
         CASE WHEN count(DISTINCT date_trunc('month', d.dia))
                   FILTER (WHERE d.dia >= date_trunc('month', p_desde) - interval '3 months'
                             AND d.dia <  date_trunc('month', p_desde)) >= 3
              THEN regr_slope(d.max_value, EXTRACT(epoch FROM d.dia)/86400) * 30
         END                                                              AS pend_mes
  FROM inst i
  JOIN sem_metric_map m3 ON m3.instance_id = i.instance_id
  JOIN series_1d      d  ON d.id_metric = m3.idmetric
                        -- mismo criterio que en bkt: los DS del uso
                        AND d.ds       = ANY(i.ds_list)
                        AND d.dia      >= date_trunc('month', p_desde) - interval '3 months'
                        AND d.dia      <  date_trunc('month', p_desde)
                        AND d.n > 0
                        -- REV-SEM-09 · mismo filtro que en bkt: el histórico
                        -- anterior a la conversion son contadores crudos.
                        AND NOT EXISTS (
                              SELECT 1 FROM sem_counter_dict cd
                               WHERE cd.subtype = i.subtype
                                 AND d.dia      < cd.desde)
  GROUP BY 1, 2
),
-- Tiempo en alerta POR INSTANCIA, con los intervalos solapados fusionados.
alerta AS (
  SELECT x.role_id, x.sem_instance_id,
         sum(EXTRACT(epoch FROM (upper(r) - lower(r))))::numeric AS segs_alerta,
         count(*)                                                AS n_incidencias
  FROM (
    SELECT i.role_id, i.sem_instance_id,
           unnest(range_agg(i.rango * w.v)) AS r
    FROM v_alert_intervals i, ventana w
    WHERE i.canal <> 'no_agrega' AND i.rango && w.v
    GROUP BY i.role_id, i.sem_instance_id
  ) x
  GROUP BY x.role_id, x.sem_instance_id
),
-- value_scale aplicado UNA sola vez, y factor de presentacion elegido a partir
-- del mayor valor de la fila (capacidad incluida).
esc AS (
  SELECT e.role_id, e.instance_id, e.iddev, e.n_muestras, e.horas_con_dato,
         e.momento_max,
         i.role_display_name, i.role_type, i.criticality, i.dev_name, i.dev_ip,
         i.stable_key, i.subtype, i.canonical_id, i.unit, i.signal_class,
         i.instance_kind,   -- lo usa el filtro de trafico del SELECT final
         -- CAPACIDAD EFECTIVA, por orden de fiabilidad (REV-SEM-08):
         --
         --   1. total_ds    -> el propio dato la trae (disk_mibhost ds=1). Es la
         --                     mejor fuente: se mide en cada ciclo y refleja los
         --                     cambios de tamaño al instante.
         --   2. i.capacity  -> el inventario, poblado por el poller. Una foto,
         --                     que puede tener meses.
         --   3. 100         -> implicita si el concepto es un porcentaje.
         --                     device.cpu.pct no necesita capacity declarada.
         --
         -- El orden 1 antes que 2 es lo que resuelve los 204 elementos «sin
         -- capacidad declarada» del informe de cobertura: casi todos son discos.
         COALESCE(e.total_ds * i.value_scale,
                  i.capacity,
                  CASE WHEN i.unit = 'pct' THEN 100 END) AS capacity,
         i.plausible_min, i.plausible_max,
         i.dev_custom,
         i.value_scale,                     -- para escalar el historico (REV-SEM-08)
         e.minimo_raw * i.value_scale AS minimo_c,
         e.maximo_raw * i.value_scale AS maximo_c,
         e.media_raw  * i.value_scale AS media_c,
         e.p50_raw    * i.value_scale AS p50_c,
         e.p95_raw    * i.value_scale AS p95_c,
         e.p99_raw    * i.value_scale AS p99_c,
         e.ultimo_raw * i.value_scale AS ultimo_c,
         u.factor, u.etiqueta
  FROM est e
  JOIN inst i ON i.role_id = e.role_id AND i.instance_id = e.instance_id
  -- La unidad legible se elige con el mayor valor de la fila, capacidad
  -- incluida, y esa capacidad ahora puede venir del DS medido.
  CROSS JOIN LATERAL f_unidad_legible(
       i.unit,
       GREATEST(COALESCE(e.maximo_raw * i.value_scale, 0),
                COALESCE(e.total_ds   * i.value_scale, i.capacity, 0))) u
)
SELECT x.role_id, x.role_display_name, x.role_type, x.criticality,
       x.dev_name, x.dev_ip, x.iddev,
       x.stable_key, x.subtype, x.canonical_id, x.etiqueta, x.unit, x.signal_class,
       x.n_muestras::bigint, x.horas_con_dato,
       round(100.0 * x.horas_con_dato / w.horas, 1),
       round((x.minimo_c / x.factor)::numeric, 2),
       round((x.maximo_c / x.factor)::numeric, 2),
       x.momento_max,
       round((x.media_c  / x.factor)::numeric, 2),
       round((x.p50_c    / x.factor)::numeric, 2),
       round((x.p95_c    / x.factor)::numeric, 2),
       round((x.p99_c    / x.factor)::numeric, 2),
       round((x.ultimo_c / x.factor)::numeric, 2),
       round((x.capacity / x.factor)::numeric, 2),
       -- El porcentaje se RECORTA a 100. Un p95 aproximado puede rebasar la
       -- capacidad por decimas (t-digest), y un 100,05% resta credibilidad sin
       -- aportar nada. Los excesos GRANDES no son saturacion sino capacidad mal
       -- declarada en el inventario: van a 'aviso_capacidad', que los senala sin
       -- ensuciar el porcentaje.
       -- OJO con LEAST: en PostgreSQL IGNORA los NULL, asi que
       -- LEAST(NULL, 100.00) devuelve 100.00. Sin el 'p95_c IS NOT NULL' las
       -- instancias que no reportan ningun valor salian al 100 % de ocupacion,
       -- que es justo lo contrario de lo que ocurre: no es que esten llenas, es
       -- que no se sabe nada de ellas. Medido: 19 instancias en 11 equipos.
       CASE WHEN x.capacity > 0 AND x.p95_c IS NOT NULL
            THEN LEAST(round((100 * x.p95_c / x.capacity)::numeric, 2), 100.00) END,
       CASE
            -- SIN DATO. La instancia esta declarada y tiene capacidad conocida,
            -- pero no ha producido un solo valor en la ventana. Es informacion
            -- util para mantenimiento -suele corresponder a equipos con aviso en
            -- la consola de CNM-, no un recurso saturado.
            -- Con capacidad conocida o sin ella: si no hay valor, no hay nada
            -- que evaluar. Se señalan las dos, distinguiendolas, porque son
            -- problemas distintos: una no mide, la otra ni mide ni se sabe
            -- contra que compararla.
            WHEN x.p95_c IS NULL AND x.capacity > 0
            THEN 'SIN DATO: la instancia no ha reportado ningun valor en la ventana'
            WHEN x.p95_c IS NULL
            THEN 'SIN DATO NI CAPACIDAD: no reporta valores y no se conoce su total'
            WHEN x.capacity > 0 AND x.p95_c > x.capacity * 1.05
            THEN 'CAPACIDAD DECLARADA DUDOSA: p95 la supera en '
                 || round((100 * x.p95_c / x.capacity)::numeric, 0)::text || '%'
            WHEN x.capacity > 0 AND x.p95_c > x.capacity
            THEN 'al limite'
            -- AGOTAMIENTO PREVISTO. Solo con 3 meses de historia y pendiente
            -- positiva. Es una extrapolacion lineal: ordena por urgencia, no
            -- promete una fecha.
            WHEN x.capacity > 0 AND h.pend_mes > 0 AND x.p95_c IS NOT NULL
                 AND 100 * x.p95_c / x.capacity < 90
                 AND (90 - 100 * x.p95_c / x.capacity)
                     / (100 * h.pend_mes * x.value_scale / x.capacity) <= 12
            THEN 'AGOTAMIENTO PREVISTO: alcanza el 90 % en '
                 || round(((90 - 100 * x.p95_c / x.capacity)
                    / (100 * h.pend_mes * x.value_scale / x.capacity))::numeric, 0)
                 || ' meses'
            END,
       -- AVISO_VALOR: valores IMPOSIBLES o implausibles. No es un umbral de
       -- alerta: senala que el DATO es sospechoso, no que el recurso vaya mal.
       -- Un device.cpu.pct de 340 no es una CPU saturada, es un contador que ha
       -- dado la vuelta o un script mal hecho.
       CASE
         WHEN x.plausible_max IS NOT NULL AND x.maximo_c > x.plausible_max
              THEN 'VALOR IMPOSIBLE: maximo ' || round(x.maximo_c::numeric,2)
                   || ' supera el limite fisico ' || round(x.plausible_max::numeric,2)
         WHEN x.plausible_min IS NOT NULL AND x.minimo_c < x.plausible_min
              THEN 'VALOR IMPOSIBLE: minimo ' || round(x.minimo_c::numeric,2)
                   || ' por debajo del limite ' || round(x.plausible_min::numeric,2)
         WHEN x.minimo_c = x.maximo_c AND x.n_muestras > 100
              THEN 'CONSTANTE: el valor no ha cambiado en ' || x.n_muestras || ' muestras'
       END,
       -- DESVIACION: valores plausibles pero anomalos. Compara el periodo con su
       -- propio comportamiento, sin depender de catalogo poblado.
       --   p95/p50 alto  -> picos muy por encima de lo habitual
       --   p50 cercano al maximo -> saturacion sostenida, no puntual
       CASE
         WHEN x.p50_c > 0 AND x.p99_c / x.p50_c > 10
              THEN 'PICOS EXTREMOS: p99 es ' || round((x.p99_c/x.p50_c)::numeric,1)
                   || 'x la mediana'
         WHEN x.p50_c > 0 AND x.p95_c / x.p50_c > 3
              THEN 'PICOS: p95 es ' || round((x.p95_c/x.p50_c)::numeric,1) || 'x la mediana'
         WHEN x.maximo_c > 0 AND x.p50_c / x.maximo_c > 0.9
              THEN 'SOSTENIDO: la mediana esta al '
                   || round((100*x.p50_c/x.maximo_c)::numeric,0) || '% del maximo'
       END,
       -- EVOLUCION HISTORICA
       -- p95 del mes anterior, en la misma escala y unidad que el actual
       CASE WHEN x.capacity > 0 AND h.p95_ant IS NOT NULL
            THEN LEAST(round((100 * h.p95_ant * x.value_scale / x.capacity)::numeric, 2), 100.00)
       END,
       -- variacion en puntos porcentuales: positiva = esta subiendo
       CASE WHEN x.capacity > 0 AND h.p95_ant IS NOT NULL AND x.p95_c IS NOT NULL
            THEN round((100 * x.p95_c / x.capacity
                      - 100 * h.p95_ant * x.value_scale / x.capacity)::numeric, 2)
       END,
       -- tendencia en puntos por mes. NULL si no hay 3 meses de historia.
       CASE WHEN x.capacity > 0 AND h.pend_mes IS NOT NULL
            THEN round((100 * h.pend_mes * x.value_scale / x.capacity)::numeric, 2)
       END,
       -- meses hasta el 90 %. Solo si CRECE: con pendiente <=0 no se agota.
       -- Es una extrapolacion lineal: sirve para PRIORIZAR, no para prometer
       -- una fecha. Un disco que crece por lotes no sigue una recta.
       CASE WHEN x.capacity > 0 AND x.p95_c IS NOT NULL
                 AND h.pend_mes > 0
                 AND 100 * x.p95_c / x.capacity < 90
            THEN round(((90 - 100 * x.p95_c / x.capacity)
                        / (100 * h.pend_mes * x.value_scale / x.capacity))::numeric, 1)
       END,
       round(COALESCE(a.segs_alerta, 0)/60, 1),
       COALESCE(a.n_incidencias, 0),
       LEAST(round(100.0 * COALESCE(a.segs_alerta,0) / NULLIF(w.segs,0), 2), 100.00),
       w.ventana_en_curso,
       x.dev_custom
FROM esc x
LEFT JOIN alerta a ON a.role_id = x.role_id AND a.sem_instance_id = x.instance_id
LEFT JOIN hist   h ON h.role_id = x.role_id AND h.instance_id = x.instance_id
CROSS JOIN ventana w
-- REV-SEM-08 · DOS filtros para el trafico, y son complementarios:
--
--   1. POR NATURALEZA: que la interfaz sea un enlace real. Se usa
--      instance_kind, derivado de ifType por el poller. Un loopback no es un
--      enlace: su trafico es el equipo hablando consigo mismo, y su 'capacidad'
--      de 10 Mbps es el valor por defecto del agente, no una velocidad. Sin
--      este filtro salian loopbacks al 206 % de ocupacion.
--
--      Se filtra por instance_kind y NO por el nombre ('lo', 'vSwitch0'),
--      porque los nombres varian entre sistemas operativos y habria que
--      mantener una lista. ifType es un estandar de MIB-II.
--
--   2. POR RELEVANCIA: cuanta carga mueve, en % de su capacidad. De 1.139
--      interfaces, el 92 % mueve menos del 1 % de la suya. El criterio es el
--      porcentaje y no los Mbps: un enlace de 100 Mbps al 15 % importa mas que
--      uno de 10 Gbps al 0,5 %.
--
-- Con trafico no hay p95 -no se pueden sumar los DS-, asi que se compara el
-- maximo, que es una cota superior.
--
-- instance_kind NULL = el poller aun no lo ha resuelto: se deja pasar, para no
-- ocultar interfaces por falta de un dato que llega en el siguiente ciclo.
WHERE x.canonical_id <> 'net.iface.traffic_bps'
   OR ( COALESCE(x.instance_kind,'') NOT IN ('loopback','virtual','tunnel')
        AND ( p_umbral_trafico <= 0
              OR x.capacity IS NULL
              OR 100 * x.maximo_c / NULLIF(x.capacity,0) >= p_umbral_trafico ) )
ORDER BY x.role_id, x.dev_name, x.canonical_id, x.stable_key, x.instance_id;
END;
$$;

COMMENT ON FUNCTION f_informe_capacidad(timestamptz, timestamptz, text, numeric, text[]) IS
  'Informe de capacidad por INSTANCIA. SOLO metricas de saturacion: un percentil '
  'sobre un codigo de estado (health_sli) no significa nada. Lee de series_1h: '
  'percentiles aproximados por t-digest, momento del maximo con precision '
  'horaria. Aplica value_scale. minutos_en_alerta es de la instancia, sumable.';

-- -----------------------------------------------------------------------------
-- 2. RESUMEN POR ROL
--
-- No es la suma del detalle: el tiempo en alerta se fusiona a nivel de rol, asi
-- que dos instancias en alerta simultanea cuentan una sola vez. Sumar la columna
-- del detalle daria un valor mayor y sin sentido.
-- -----------------------------------------------------------------------------
CREATE FUNCTION f_informe_capacidad_rol(
  p_desde        timestamptz,
  p_hasta        timestamptz,
  p_role_pattern text DEFAULT '%',
  -- se propaga a la funcion de detalle: el resumen por rol debe agregar
  -- exactamente las mismas filas que se publican en el detalle.
  p_umbral_trafico numeric DEFAULT 1.0,
  -- idem: se propaga, para que el resumen agregue las mismas filas del detalle
  p_roles        text[] DEFAULT NULL
)
RETURNS TABLE (
  role_id            text,
  role_display_name  text,
  role_type          text,
  criticality        smallint,
  n_dispositivos     bigint,
  n_instancias       bigint,
  pct_cobertura_media numeric,
  -- disponibilidad FUSIONADA a nivel de rol
  minutos_en_alerta  numeric,
  pct_tiempo_alerta  numeric,
  n_incidencias_rol  bigint,
  n_incidencias_senal bigint,
  ventana_en_curso   boolean,
  -- saturacion: el peor p95 sobre capacidad de todo el rol
  peor_pct_capacidad numeric,
  peor_instancia     text
)
LANGUAGE plpgsql STABLE PARALLEL SAFE SECURITY DEFINER
SET search_path = public, pg_temp
SET plan_cache_mode = force_custom_plan
AS $$
#variable_conflict use_column
BEGIN
RETURN QUERY
WITH det AS (
  SELECT * FROM f_informe_capacidad(p_desde, p_hasta, p_role_pattern,
                                    p_umbral_trafico, p_roles)
),
alerta_rol AS (
  SELECT role_id,
         sum(segundos_en_alerta) FILTER (WHERE canal LIKE 'salud%') AS segs,
         sum(n_incidencias_rol)   FILTER (WHERE canal LIKE 'salud%') AS n_rol,
         sum(n_incidencias_senal) FILTER (WHERE canal LIKE 'salud%') AS n_senal
  FROM f_role_alert_time(p_desde, p_hasta)
  GROUP BY 1
),
peor AS (
  -- Separador ASCII a proposito: un caracter no ASCII (el punto medio U+00B7)
  -- se codifica correctamente en UTF-8, pero Excel y otras herramientas que
  -- abren el CSV como Latin-1 lo muestran como dos simbolos raros. En un fichero
  -- destinado a abrirse en hoja de calculo no compensa.
  SELECT DISTINCT ON (role_id) role_id, pct_p95_capacidad,
         dispositivo || ' - ' || instancia AS quien
  FROM det WHERE pct_p95_capacidad IS NOT NULL
  -- desempate alfabetico: con el porcentaje recortado a 100 empatan muchas
  -- COLLATE "C" (orden por bytes): el desempate no depende de la colacion de
  -- la base y se puede comprobar fuera (verifica_peor.py).
  ORDER BY role_id, pct_p95_capacidad DESC,
           dispositivo COLLATE "C", instancia COLLATE "C", canonical_id COLLATE "C"
)
SELECT d.role_id, min(d.role_display_name), min(d.role_type), min(d.criticality),
       count(DISTINCT d.iddev), count(*),
       round(avg(d.pct_cobertura), 1),
       round(COALESCE(min(a.segs),0)/60, 1),
       round(100.0 * COALESCE(min(a.segs),0)
             / NULLIF(EXTRACT(epoch FROM (LEAST(p_hasta, now()) - p_desde))::numeric,0), 2),
       COALESCE(min(a.n_rol), 0)::bigint,
       COALESCE(min(a.n_senal), 0)::bigint,
       bool_or(d.ventana_en_curso),
       min(p.pct_p95_capacidad), min(p.quien)
FROM det d
LEFT JOIN alerta_rol a ON a.role_id = d.role_id
LEFT JOIN peor       p ON p.role_id = d.role_id
GROUP BY d.role_id
ORDER BY d.role_id;
END;
$$;

COMMENT ON FUNCTION f_informe_capacidad_rol(timestamptz, timestamptz, text, numeric, text[]) IS
  'Resumen por ROL. minutos_en_alerta esta FUSIONADO a nivel de rol: NO es la '
  'suma del detalle (dos instancias en alerta simultanea cuentan una vez).';

\set app_user cnm_loader
GRANT EXECUTE ON FUNCTION f_informe_capacidad(timestamptz, timestamptz, text, numeric, text[]) TO :app_user;
GRANT EXECUTE ON FUNCTION f_informe_capacidad_rol(timestamptz, timestamptz, text, numeric, text[]) TO :app_user;
