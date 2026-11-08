-- =============================================================================
-- AGREGADO DIARIO series_1d  ·  nivel de largo plazo
--
-- SE EJECUTA EN TIMESCALE. Requiere timescaledb_toolkit (percentile_agg).
--
-- POR QUE EXISTE. Se evaluaron tres justificaciones y solo la tercera resistio
-- la medicion:
--
--   1. AHORRO DE ESPACIO -> DESCARTADA. Comprimir series_1h dio 10,4x
--      (701 MB -> 68 MB por chunk). El espacio dejo de ser el problema.
--
--   2. FALTA DE work_mem -> DESCARTADA. Con 256MB el HashAggregate pasa de
--      5 lotes a 1, sin volcar a disco... y el tiempo solo baja un 5%
--      (2.008 -> 1.909 ms). No era memoria.
--
--   3. COSTE DEL ROLLUP DE SKETCHES -> CONFIRMADA. Combinar t-digest es coste
--      de CPU y escala PEOR que lineal (exponente medido ~1,16):
--
--        ventana   desde series_1h   desde series_1d
--        --------  ---------------   ---------------
--        7 dias        1,9 s (medido)      ~0,1 s
--        22 dias       7,2 s (medido)      ~0,3 s
--        1 mes        ~10 s                ~0,3 s
--        1 año       ~191 s                ~4 s
--
--      Una comparativa interanual sobre el horario tardaria mas de 3 minutos.
--
-- LA IDEA: el diario guarda el sketch YA COMBINADO de las 24 horas del dia. El
-- trabajo de combinar se hace UNA VEZ, en segundo plano al refrescar, en lugar
-- de repetirse en cada consulta. Una consulta mensual pasa de combinar 720
-- sketches por metrica a combinar 30.
--
-- QUE SE CONSERVA Y QUE NO frente al horario:
--   conserva : media (ponderada), min, max, ultimo, y percentiles REALES
--   pierde   : a que HORA del dia ocurrio cada cosa
-- No es la perdida de RRD: RRD guarda un numero y la distribucion desaparece;
-- aqui el t-digest conserva la forma, asi que el p95 del dia -y del mes, y del
-- año- sigue siendo correcto.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. El agregado, construido SOBRE series_1h (no sobre el crudo)
--
-- Asi sobrevive a la retencion de 90 dias del crudo y aprovecha que el horario
-- ya esta calculado.
--
-- LA MEDIA NO SE PUEDE PROMEDIAR: un bucket con 12 muestras y otro con 288 no
-- pesan igual. Se guardan sum(avg*n) y sum(n) por separado y la division se
-- hace AL LEER, en la vista v_series_1d. Un agregado continuo no admite la
-- division dentro de la definicion.
-- ---------------------------------------------------------------------------
-- ZONA HORARIA EXPLICITA en time_bucket. IMPRESCINDIBLE:
--   Sin ella, los buckets se alinean a MEDIANOCHE UTC. Con el servidor en
--   Europe/Madrid (+02:00 en verano) un "dia" iria de las 02:00 a las 02:00
--   hora local, y un informe "de agosto" cubriria del 1-ago 02:00 al
--   1-sep 02:00. Para un entregable mensual eso no vale.
--
--   Peor aun: el desfase NO es constante. En invierno España esta en +01:00,
--   asi que seria de una hora en vez de dos, y el dia del cambio de horario
--   meteria 23 o 25 horas en un bucket de 24.
--
--   Con la zona horaria, time_bucket respeta los limites locales y gestiona el
--   cambio de hora. Verificado: sin ella, comparar el mismo periodo desde
--   series_1h y series_1d daba 20.729 de 20.731 metricas con recuentos
--   distintos; alineando a UTC coincidian exactamente (6.856.951 = 6.856.951),
--   lo que confirmo que el calculo era correcto y el problema, el encuadre.
CREATE MATERIALIZED VIEW IF NOT EXISTS series_1d
WITH (timescaledb.continuous) AS
SELECT time_bucket('1 day', bucket, 'Europe/Madrid') AS dia,
       id_metric,
       ds,
       sum(n)                    AS n,
       sum(avg_value * n)        AS suma_ponderada,   -- media = suma/n al leer
       min(min_value)            AS min_value,
       max(max_value)            AS max_value,
       last(last_value, bucket)  AS last_value,
       rollup(pct_sketch)        AS pct_sketch        -- t-digest YA combinado
FROM series_1h
GROUP BY dia, id_metric, ds
WITH NO DATA;

-- ---------------------------------------------------------------------------
-- 2. Refresco automatico
--
-- start_offset de 7 dias (no de 2, como seria lo justo): si el trabajo no corre
-- durante unos dias -reinicio, mantenimiento-, los buckets que queden fuera de
-- la ventana NO se recuperarian nunca. Con 7 dias hay auto-reparacion.
--   (series_1h usa 3 horas y no la tiene: ver DOC-SEM-01 C4.)
--
-- end_offset de 1 dia: no se materializa el dia en curso, que aun cambia.
-- ---------------------------------------------------------------------------
SELECT add_continuous_aggregate_policy('series_1d',
    start_offset      => INTERVAL '7 days',
    end_offset        => INTERVAL '1 day',
    schedule_interval => INTERVAL '1 hour',
    if_not_exists     => TRUE);

-- ---------------------------------------------------------------------------
-- 3. Compresion
--
-- Medida sobre series_1h: 10,4x de reduccion y las consultas simples 8x mas
-- rapidas (2.195 -> 272 ms). El almacenamiento columnar lee solo las columnas
-- necesarias, y este agregado se consulta siempre por rangos amplios.
--
-- compress_after de 90 dias, MUY holgado a proposito: comprimir un chunk de un
-- agregado continuo lo deja de SOLO LECTURA, y su refresco fallaria. Con 90
-- dias hay margen de sobra para cualquier recalculo retroactivo.
-- Si hiciera falta: decompress_chunk -> refresh -> compress_chunk.
-- ---------------------------------------------------------------------------
ALTER MATERIALIZED VIEW series_1d SET (timescaledb.compress = true);
SELECT add_compression_policy('series_1d', compress_after => INTERVAL '90 days',
                              if_not_exists => TRUE);

-- ---------------------------------------------------------------------------
-- 4. Retencion: NINGUNA
--
-- A 46.410 filas/dia son ~17 M al año; comprimido, menos de 1 GB/año. Diez años
-- caben en lo que series_1h ocupa en uno. Este es el nivel de largo plazo: se
-- conserva indefinidamente y se revisa si alguna vez estorba.
-- ---------------------------------------------------------------------------

-- ---------------------------------------------------------------------------
-- 5. Vista de consulta
--
-- Resuelve la media ponderada y extrae los percentiles del sketch, para que
-- quien consulte no tenga que saber que por dentro hay una suma y un t-digest.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_series_1d AS
SELECT dia, id_metric, ds, n,
       suma_ponderada / NULLIF(n,0)          AS avg_value,
       min_value, max_value, last_value,
       approx_percentile(0.50, pct_sketch)   AS p50,
       approx_percentile(0.95, pct_sketch)   AS p95,
       approx_percentile(0.99, pct_sketch)   AS p99,
       pct_sketch                             -- expuesto para poder re-agregar
FROM series_1d;

COMMENT ON VIEW v_series_1d IS
  'Lectura de series_1d con la media ponderada resuelta y los percentiles ya '
  'extraidos. Para agregar VARIOS dias hay que usar series_1d directamente y '
  'rollup(pct_sketch): promediar los p95 de esta vista NO da el p95 del periodo.';

-- Permisos: ajustar el rol si no es cnm_loader.
\set app_user cnm_loader
GRANT SELECT ON series_1d, v_series_1d TO :app_user;
