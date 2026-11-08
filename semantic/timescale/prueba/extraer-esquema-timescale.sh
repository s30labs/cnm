#!/bin/bash
# extraer-esquema-timescale.sh · Extrae de la base de la capa analítica (TimescaleDB)
# el esquema y el código desplegados. SOLO LEE: no cambia nada en la base.
#
# Dónde:  en el appliance de Timescale, como root.
# Uso:    bash extraer-esquema-timescale.sh [base]      (por defecto: obs)
# Deja:   /root/esquema-timescale-AAAAMMDD-HHMM/ y su .tgz, con sha256.
#
# Verde: termina con "VERDE" y rc=0.  Rojo: cualquier "ROJO" o rc distinto de 0.
set -u
DB=${1:-obs}
D=/root/esquema-timescale-$(date +%Y%m%d-%H%M)
[ -e "$D" ] && { echo "ROJO: $D ya existe; espera un minuto"; exit 1; }
mkdir -p "$D" && cd "$D" || { echo "ROJO: no puedo crear $D"; exit 1; }

PG="runuser -u postgres -- psql -X -d $DB -v ON_ERROR_STOP=1"
rojo=0
paso() {  # paso <fichero> <obligatorio 1/0> <orden...>
  local f=$1 obl=$2; shift 2
  "$@" > "$f" 2> "$f.err"; local rc=$?
  if [ $rc -ne 0 ]; then
    if [ "$obl" = 1 ]; then echo "ROJO: $f rc=$rc (ver $f.err)"; rojo=1
    else echo "aviso: $f rc=$rc (ver $f.err); puede no existir en esta versión"; fi
  elif [ ! -s "$f" ]; then echo "ROJO: $f vacío con rc=0"; rojo=1
  else rm -f "$f.err"; echo "ok: $f ($(wc -l < "$f") líneas)"; fi
}

# 1. Versiones
paso versiones.txt 1 $PG -At -c "select version() union all select extname||' '||extversion from pg_extension order by 1"
paso version-pg_dump.txt 1 runuser -u postgres -- pg_dump --version

# 2. Esquema completo, sin los esquemas internos de TimescaleDB (trozos, catálogo).
#    Los objetos de las extensiones no salen: pg_dump no los vuelca.
#    No incluye roles ni contraseñas de roles (son globales, no de la base).
paso esquema.sql 1 runuser -u postgres -- pg_dump -d "$DB" --schema-only --no-owner \
  --exclude-schema='_timescaledb*' --exclude-schema='timescaledb_*' --exclude-schema='toolkit_experimental'

# 3. Inventario: funciones propias (fuera de extensiones) y vistas
paso funciones.csv 1 $PG --csv -c "
select n.nspname as esquema, p.proname as funcion,
       pg_get_function_identity_arguments(p.oid) as argumentos, l.lanname as lenguaje
from pg_proc p join pg_namespace n on n.oid=p.pronamespace join pg_language l on l.oid=p.prolang
where n.nspname not in ('pg_catalog','information_schema')
  and n.nspname not like '\_timescaledb%' and n.nspname not like 'timescaledb\_%'
  and not exists (select 1 from pg_depend d where d.objid=p.oid and d.deptype='e')
order by 1,2,3"
paso vistas.csv 1 $PG --csv -c "
select schemaname as esquema, viewname as vista from pg_views
where schemaname not in ('pg_catalog','information_schema')
  and schemaname not like '\_timescaledb%' and schemaname not like 'timescaledb\_%'
order by 1,2"

# 4. Si la extensión timescaledb está instalada, hipertablas, agregados y trabajos
#    son obligatorios; la compresión cambia de vista según la versión.
ts=0; grep -q '^timescaledb ' versiones.txt && ts=1
[ $ts = 1 ] || { echo "ROJO: la base $DB no tiene la extensión timescaledb"; rojo=1; }
# Lo propio de TimescaleDB que pg_dump no recoge bien: hipertablas, agregados
#    continuos, compresión, retención y trabajos programados.
paso ts-hipertablas.csv $ts $PG --csv -c "select * from timescaledb_information.hypertables order by 1,2"
paso ts-dimensiones.csv $ts $PG --csv -c "select * from timescaledb_information.dimensions order by 1,2"
paso ts-agregados.csv   $ts $PG --csv -c "select * from timescaledb_information.continuous_aggregates order by 1,2"
paso ts-trabajos.csv    $ts $PG --csv -c "select * from timescaledb_information.jobs order by job_id"
paso ts-compresion.csv  0 $PG --csv -c "select * from timescaledb_information.compression_settings order by 1,2"
paso ts-compresion-h.csv 0 $PG --csv -c "select * from timescaledb_information.hypertable_compression_settings order by 1"

# 5. Posibles secretos: el destino es un repositorio PÚBLICO.
#    Se cuentan aquí; las líneas se miran en el equipo y NO se pegan en ninguna conversación.
grep -niE "password|passwd|secret|user mapping|dbname=|host=|connect" esquema.sql > revisar-secretos.txt; g=$?
case $g in
  0) echo "REVISAR: $(wc -l < revisar-secretos.txt) líneas en revisar-secretos.txt (mirarlas aquí, no pegarlas)";;
  1) echo "ok: ninguna coincidencia de secretos en esquema.sql";;
  *) echo "ROJO: grep rc=$g"; rojo=1;;
esac

# 6. Huellas y paquete
sha256sum * > SHA256SUMS
cd .. && tar czf "$D.tgz" "$(basename "$D")" || { echo "ROJO: tar"; exit 1; }
sha256sum "$D.tgz"
[ $rojo -eq 0 ] && { echo "VERDE: $D.tgz"; exit 0; } || { echo "ROJO: ver arriba"; exit 1; }
