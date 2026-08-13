#!/bin/bash
# =============================================================================
# cnm_archivar_maestro.sh — paso 7 del ciclo: archivar la version CARGADA.
#
# Se ejecuta SOLO despues de un --commit con exito. El directorio historico/ no
# es un "por si acaso": es el registro de lo que esta REALMENTE en la base de
# datos, y la referencia contra la que se hara el --diff de la proxima iteracion.
#
# Archiva el CSV *exacto* que se cargo (no uno re-exportado: un re-export puede
# diferir en detalles y produciria cambios fantasma en el siguiente diff) y el
# xlsx que lo genero. Actualiza el symlink historico/ultima_cargada.csv.
#
# RUTAS: el CODIGO vive en /opt/cnm/semantic (repo) y los DATOS del cliente en
# /opt/data/semantic (nunca en el repo). Este script opera sobre los DATOS.
#
# USO:
#   /opt/cnm/semantic/bin/cnm_archivar_maestro.sh --nota "carga inicial roles v1"
#   ... --base /opt/data/semantic --dry-run
#   (o exportando CNM_SEMANTIC_DATA)
# =============================================================================
set -euo pipefail

BASE="${CNM_SEMANTIC_DATA:-/opt/data/semantic}"
CSV="cnm_roles_maestro.csv"
XLSX="cnm_roles_maestro.xlsx"
NOTA=""
DRY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --base)  BASE="$2"; shift 2 ;;
    --csv)   CSV="$2";  shift 2 ;;
    --xlsx)  XLSX="$2"; shift 2 ;;
    --nota)  NOTA="$2"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "Opcion desconocida: $1" >&2; exit 2 ;;
  esac
done

HIST="$BASE/historico"
SRC_CSV="$BASE/$CSV"
SRC_XLSX="$BASE/$XLSX"

# --- comprobaciones previas ---
[ -d "$BASE" ] || { echo "ERROR: no existe el directorio base $BASE" >&2; exit 1; }
[ -f "$SRC_CSV" ] || { echo "ERROR: no encuentro $SRC_CSV" >&2; exit 1; }
if [ ! -f "$SRC_XLSX" ]; then
  echo "AVISO: no encuentro $SRC_XLSX (se archivara solo el CSV)." >&2
  echo "       Si editas el xlsx en otro equipo, subelo antes de archivar:" >&2
  echo "       si no, el historico guardara un libro que no corresponde al CSV cargado." >&2
fi

mkdir -p "$HIST"
TS=$(date +%Y%m%d_%H%M)
DST_CSV="$HIST/cnm_roles_maestro_$TS.csv"
DST_XLSX="$HIST/cnm_roles_maestro_$TS.xlsx"

# no pisar un archivado existente (dos cargas en el mismo minuto)
if [ -e "$DST_CSV" ]; then
  echo "ERROR: ya existe $DST_CSV. Espera un minuto o archiva a mano." >&2
  exit 1
fi

if [ "$DRY" -eq 1 ]; then
  echo "[DRY-RUN] cp $SRC_CSV  -> $DST_CSV"
  [ -f "$SRC_XLSX" ] && echo "[DRY-RUN] cp $SRC_XLSX -> $DST_XLSX"
  echo "[DRY-RUN] ln -sf cnm_roles_maestro_$TS.csv $HIST/ultima_cargada.csv"
  exit 0
fi

cp -p "$SRC_CSV" "$DST_CSV"
[ -f "$SRC_XLSX" ] && cp -p "$SRC_XLSX" "$DST_XLSX"

# symlink relativo: el diff se invoca siempre igual, sin recordar el nombre
ln -sfn "cnm_roles_maestro_$TS.csv" "$HIST/ultima_cargada.csv"

# registro de archivados (complementa al change_log de la BD)
REG="$HIST/registro_cargas.txt"
{
  printf "%s  %s  filas=%s  %s\n" \
     "$(date '+%Y-%m-%d %H:%M:%S')" \
     "cnm_roles_maestro_$TS.csv" \
     "$(( $(wc -l < "$DST_CSV") - 1 ))" \
     "${NOTA:-sin nota}"
} >> "$REG"

echo "Archivado OK:"
echo "  CSV   -> $DST_CSV"
[ -f "$DST_XLSX" ] && echo "  XLSX  -> $DST_XLSX"
echo "  Enlace-> $HIST/ultima_cargada.csv"
echo "  Registro: $REG"
echo
echo "El proximo diff se invoca asi:"
echo "  perl /opt/cnm/semantic/bin/cnm_validar_maestro.pl --csv $BASE/$CSV \\"
echo "       --diff $HIST/ultima_cargada.csv"
