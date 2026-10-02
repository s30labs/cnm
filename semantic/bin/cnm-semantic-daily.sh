#!/bin/bash
# =============================================================================
# cnm-semantic-daily.sh · Cadena diaria de mantenimiento de la capa semantica
# Ubicacion: /opt/cnm/semantic/bin/cnm-semantic-daily.sh · Servidor CNM · root.
# Sustituye en cnm-daily a la linea de cnm_ts_sync_semantics.pl.
#
#   cnm-semantic-daily.sh                  cadena completa (lo que ejecuta cnm-daily)
#   cnm-semantic-daily.sh --sin-capacidad  sin el poller SNMP (propagacion rapida a mano)
#   cnm-semantic-daily.sh --ensayo         todo en modo ensayo: no escribe nada
#   cnm-semantic-daily.sh --conf FICHERO   otro semantic.conf
#
# CONFIGURACION (REV-SEM-12):
#   /opt/data/semantic/semantic.conf  (clave = valor; SIN secretos; lo comparten
#      otros scripts). Claves que usa este script: db_name, db_port, data_dir y la
#      seccion "Cadena diaria": code_role_map, pg_host, pg_db, credentials_file,
#      semantic_daily_log, crawler_bin.
#   credentials_file (por defecto /opt/data/semantic/semantic.credentials):
#      root, permisos 600, clave = valor: my_user, my_pass, ro_user, ro_pass,
#      pg_user, pg_pass.
#   Ninguno de los dos se ejecuta: se leen linea a linea. semantic.conf se
#   interpreta igual que CNMSemanticConf.pm (claves libres; '#' comenta hasta el
#   final de la linea); en credentials_file '#' solo comenta al inicio de linea.
#   Tambien se respeta $CNM_SEMANTIC_CONF, como en el modulo.
#   MySQL siempre por 'localhost' (socket): cnm_ts_ro solo existe como @localhost y
#   db_host=127.0.0.1 forzaria TCP. db_host de semantic.conf no se usa aqui.
#
# ORDEN Y POLITICA:
#   1 cnm_mirror.pl --commit           hechos; si falla -> se omiten 2, 3 y 4
#   2 cnm_reconcile.pl --commit        retira roles de instancias dormidas (reversible)
#   3 cnm_capacity_poller.pl --refresh salida 1 = algun equipo no responde: NORMAL
#   4 cnm_binding.pl --commit          roles de instancias vivas (usa la capacidad de 3)
#   5 cnm_ts_sync_semantics.pl         publica en Timescale; se ejecuta SIEMPRE
#   6 aviso: roles retirados sobre instancias que vuelven a vivir
#   NUNCA: cnm_reconcile.pl --purge (borrado fisico; solo a mano)
#
# Idempotente: se puede lanzar a mano cuantas veces se quiera. Un bloqueo impide
# solapes (la segunda ejecucion sale sin hacer nada).
# Salida: 0 todo bien · 1 algun paso fallo · 2 configuracion · 3 ya en ejecucion
# =============================================================================
set -uo pipefail
# Mismo orden que CNMSemanticConf.pm: --conf, $CNM_SEMANTIC_CONF, ruta estandar
CONF=${CNM_SEMANTIC_CONF:-/opt/data/semantic/semantic.conf}
MODO=commit; CAPACIDAD=1
while [ $# -gt 0 ]; do
  case "$1" in
    --ensayo) MODO=ensayo ;;
    --sin-capacidad) CAPACIDAD=0 ;;
    --conf) CONF="${2:?falta el fichero}"; shift ;;
    -h|--help) sed -n '2,38p' "$0"; exit 0 ;;
    *) echo "opcion desconocida: $1" >&2; exit 2 ;;
  esac; shift
done

# Lee "clave = valor" sin ejecutar nada. Separa por el PRIMER '='; recorta espacios;
# si la clave se repite gana la ultima. Devuelve vacio si no existe.
#   leer_conf: IGUAL que CNMSemanticConf.pm -> '#' inicia comentario en cualquier
#              punto de la linea (semantic.conf lo comparten otros scripts).
#   leer_cred: '#' solo es comentario al principio de linea, porque una clave
#              puede contener '#'.
leer_conf() { _leer "$1" "$2" 1; }
leer_cred() { _leer "$1" "$2" 0; }
_leer() {  # fichero clave quitar_comentario_en_linea
  # OJO: espacios y tabuladores explicitos, NO [[:space:]]: el awk de Debian 8
  # (mawk 1.3.3) no soporta clases POSIX y dejaria los espacios del alineado
  # dentro de la clave, con lo que ninguna clave casaria.
  awk -v k="$2" -v inl="$3" '
    /^[ \t]*#/ { next }
    { if (inl == 1) sub(/#.*$/, "") }
    !/=/ { next }
    { i = index($0, "="); c = substr($0, 1, i-1); v = substr($0, i+1)
      gsub(/^[ \t]+|[ \t]+$/, "", c); gsub(/^[ \t]+|[ \t]+$/, "", v)
      if (c == k) { r = v } }
    END { printf "%s", r }' "$1"
}

[ -r "$CONF" ] || { echo "ERROR: no se puede leer $CONF" >&2; exit 2; }
MY_DB=$(leer_conf "$CONF" db_name);            MY_DB=${MY_DB:-onm}
MY_PORT=$(leer_conf "$CONF" db_port);          MY_PORT=${MY_PORT:-3306}
DATA_DIR=$(leer_conf "$CONF" data_dir);        DATA_DIR=${DATA_DIR:-/opt/data/semantic}
MAP=$(leer_conf "$CONF" code_role_map);        MAP=${MAP:-$DATA_DIR/cnm_code_role_map.csv}
PG_HOST=$(leer_conf "$CONF" pg_host)
PG_DB=$(leer_conf "$CONF" pg_db)
CRED=$(leer_conf "$CONF" credentials_file);    CRED=${CRED:-$DATA_DIR/semantic.credentials}
LOG=$(leer_conf "$CONF" semantic_daily_log);   LOG=${LOG:-/var/log/cnm/cnm-semantic-daily.log}
CRAWLER_BIN=$(leer_conf "$CONF" crawler_bin);  CRAWLER_BIN=${CRAWLER_BIN:-/opt/cnm/crawler/bin}
SEM_BIN=${SEM_BIN:-$(dirname "$(readlink -f "$0")")}
LOCK=${LOCK:-/var/lock/cnm-semantic-daily.lock}
PERL=${PERL:-/usr/bin/perl}
MYSQL=${MYSQL:-mysql}
[ -n "$PG_HOST" ] && [ -n "$PG_DB" ] || { echo "ERROR: faltan pg_host / pg_db en $CONF" >&2; exit 2; }
[ -r "$MAP" ] || { echo "ERROR: no se puede leer el mapa $MAP" >&2; exit 2; }

# Credenciales: fichero de root con permisos 600
[ -f "$CRED" ] || { echo "ERROR: no existe $CRED" >&2; exit 2; }
perm=$(stat -c '%a %U' "$CRED")
[ "$perm" = "600 root" ] || { echo "ERROR: $CRED debe ser de root con permisos 600 (tiene: $perm)" >&2; exit 2; }
MY_USER=$(leer_cred "$CRED" my_user); MY_PASS=$(leer_cred "$CRED" my_pass)
RO_USER=$(leer_cred "$CRED" ro_user); RO_PASS=$(leer_cred "$CRED" ro_pass)
PG_USER=$(leer_cred "$CRED" pg_user); PG_PASS=$(leer_cred "$CRED" pg_pass)
for v in MY_USER MY_PASS RO_USER RO_PASS PG_USER PG_PASS; do
  [ -n "${!v}" ] || { echo "ERROR: falta $(echo "$v" | tr 'A-Z' 'a-z') en $CRED" >&2; exit 2; }
done
mkdir -p "$(dirname "$LOG")"

# Bloqueo: una sola ejecucion a la vez
exec 9>"$LOCK"
if ! flock -n 9; then
  echo "$(date '+%F %T') [semantic-daily] ya hay una ejecucion en curso: no se hace nada" | tee -a "$LOG" >&2
  exit 3
fi

log() { echo "$(date '+%F %T') [semantic-daily] $*" | tee -a "$LOG"; }
# paso NOMBRE "codigos-aceptables" comando... · salida al log con claves enmascaradas
paso() {
  local nombre=$1 ok=$2; shift 2
  local ini rc dur; ini=$(date +%s)
  log "INICIO $nombre"
  "$@" 2>&1 | sed -E 's/(--(pass|pg-pass|my-pass|db-pass)[ =])[^ ]+/\1*****/g' >> "$LOG"
  rc=${PIPESTATUS[0]}; dur=$(( $(date +%s) - ini ))
  if [[ " $ok " == *" $rc "* ]]; then log "FIN    $nombre · salida=$rc · ${dur}s · OK"; return 0
  else log "FIN    $nombre · salida=$rc · ${dur}s · FALLO"; return 1; fi
}

# OJO: con 'set -u', bash 4.3 (Debian 8) trata "${ARRAY[@]}" vacio como variable
# no definida y aborta. Por eso se expanden como ${ARRAY[@]+"${ARRAY[@]}"}, que
# funciona en 4.3 y en versiones posteriores.
COMMIT=(); [ "$MODO" = commit ] && COMMIT=(--commit)
DRY=();    [ "$MODO" = ensayo ] && DRY=(--dry-run)
FALLOS=0
log "==== cadena diaria · modo=$MODO · capacidad=$([ $CAPACIDAD = 1 ] && echo si || echo no) · conf=$CONF ===="

# 1 · espejo
if paso "1 mirror" "0" "$PERL" "$SEM_BIN/cnm_mirror.pl" --user "$MY_USER" --pass "$MY_PASS" \
        --host localhost --db "$MY_DB" ${COMMIT[@]+"${COMMIT[@]}"}; then
  # 2 · reconcile (solo retirar; NUNCA --purge)
  paso "2 reconcile" "0" "$PERL" "$SEM_BIN/cnm_reconcile.pl" --user "$MY_USER" --pass "$MY_PASS" \
       --host localhost --db "$MY_DB" ${COMMIT[@]+"${COMMIT[@]}"} || FALLOS=1
  # 3 · capacidad (credenciales por entorno: no aparecen en ps)
  if [ "$CAPACIDAD" = 1 ]; then
    CNM_DB_HOST=localhost CNM_DB_PORT="$MY_PORT" CNM_DB_NAME="$MY_DB" \
    CNM_DB_USER="$MY_USER" CNM_DB_PASS="$MY_PASS" \
      paso "3 capacity_poller" "0 1" "$PERL" "$SEM_BIN/cnm_capacity_poller.pl" --refresh ${DRY[@]+"${DRY[@]}"} || FALLOS=1
  else
    log "OMITIDO 3 capacity_poller (--sin-capacidad)"
  fi
  # 4 · binding
  paso "4 binding" "0" "$PERL" "$SEM_BIN/cnm_binding.pl" --user "$MY_USER" --pass "$MY_PASS" \
       --host localhost --db "$MY_DB" --map "$MAP" ${COMMIT[@]+"${COMMIT[@]}"} || FALLOS=1
else
  FALLOS=1
  log "OMITIDOS 2, 3 y 4: el espejo ha fallado y trabajarian sobre un espejo desactualizado"
fi

# 5 · replica a Timescale (siempre)
paso "5 sync_semantics" "0" "$PERL" "$CRAWLER_BIN/cnm_ts_sync_semantics.pl" \
     --pg-host "$PG_HOST" --pg-db "$PG_DB" --pg-user "$PG_USER" --pg-pass "$PG_PASS" \
     --my-db "$MY_DB" --my-user "$RO_USER" --my-pass "$RO_PASS" -v ${DRY[@]+"${DRY[@]}"} || FALLOS=1

# 6 · aviso: roles retirados cuya instancia vuelve a estar viva
n=$(MYSQL_PWD="$MY_PASS" "$MYSQL" -u "$MY_USER" -h localhost -N -B "$MY_DB" -e \
    "SELECT count(*) FROM sem_binding_role b JOIN sem_instance i ON i.instance_id = b.instance_id
      WHERE b.status = 'retired' AND i.valid_to IS NULL" 2>>"$LOG")
if [ -z "$n" ]; then log "AVISO 6: no se pudo comprobar roles retirados sobre instancias vivas"
elif [ "$n" != 0 ]; then log "AVISO 6: $n roles retirados sobre instancias que vuelven a estar vivas: revisar a mano (REV-SEM-12)"
else log "OK     6 · ningun rol retirado sobre instancias vivas"; fi

log "==== fin · $([ $FALLOS = 0 ] && echo 'todo OK' || echo 'CON FALLOS: ver arriba') ===="
exit $FALLOS
