#!/bin/bash
#==============================================================================
# t-plugin-semantic.sh · v1.3 · 10-oct-2026
#
# Valida el plugin /opt/cnm/update/cnm-semantic contra el gestor de ESTE equipo.
# Existe porque toda la validacion del plugin esta hecha sobre MariaDB 10.11
# —el laboratorio— y el destino es MariaDB 11.8. Es el bloqueante B1 de
# claude/RUNBOOK-CORTE-CNMPRD02 §0.1.
#
# DOS MODOS, y la diferencia importa:
#
#   --huella     SOLO LECTURA. Saca las tres huellas del esquema sem_* para
#                comparar dos equipos. Es el modo que se ejecuta en el ORIGEN.
#
#   --validar    Instala, rompe y reinstala. DESTRUCTIVO sobre la base de datos
#                de este equipo. Solo para el DESTINO, antes del corte, cuando
#                su 'onm' todavia no vale nada. Exige --si.
#
# CONTRATO DE SALIDA (REF-CNM-03 §7):
#   PASA   evaluado y correcto        FALLA  evaluado y mal
#   N/A    no se ha podido evaluar    AVISO  correcto, pero hay algo que mirar
#   rc=0 ningun FALLA · rc=1 algun FALLA · rc=2 no se ha podido ejecutar
#
# Ninguna orden de este guion lleva una contrasena: 'mariadb' usa el
# /root/.my.cnf que escribe el rol mysql, y db-manage.php resuelve la suya.
#==============================================================================
set -u

PLUGIN=/opt/cnm/update/cnm-semantic
DBMANAGE=""        # se descubre en T5: ver busca_dbmanage()
BD=onm
SALIDA=/root/plugin-semantic-$(hostname -s)
MODO=""
SI=0

P=0; F=0; NA=0; AV=0

uso () {
  sed -n '2,25p' "$0" | sed 's/^# \?//'
  cat <<'FIN'
USO
  t-plugin-semantic.sh --huella  [-b <bd>] [-o <dir>]
  t-plugin-semantic.sh --validar [-b <bd>] [-o <dir>] --si

  -b <bd>    base de datos de cliente           (por defecto: onm)
  -o <dir>   donde deja las huellas             (por defecto: /root/plugin-semantic-<host>)
  --si       confirma el modo --validar, que ESCRIBE en la base de datos
FIN
  exit 2
}

ok   () { printf '  %-4s PASA   %s\n'  "$1" "$2"; P=$((P+1)); }
mal  () { printf '  %-4s FALLA  %s\n'  "$1" "$2"; F=$((F+1)); }
na   () { printf '  %-4s N/A    %s\n'  "$1" "$2"; NA=$((NA+1)); }
avi  () { printf '  %-4s AVISO  %s\n'  "$1" "$2"; AV=$((AV+1)); }
tit  () { printf '\n== %s\n' "$1"; }

# OJO con esta funcion. Su primera version hacia 2>/dev/null, y un error de SQL
# daba una huella VACIA en silencio: paso con un 'ORDER BY 1,2,3' sobre un
# SELECT de una sola columna, que MariaDB rechaza. Lo cazo la regla 1 —«vacio»
# no puede significar «aprobado»— y no el guion, que es justo lo que no debe
# pasar. Ahora los errores se ACUMULAN en un fichero y se revisan al final.
q () {
  mariadb -N -B "$BD" -e "$1" 2>>"$SALIDA/sql-errores.txt"
}

# Dos veces en un dia he afirmado una ruta sin medirla. Esta se busca.
busca_dbmanage () {
  local c
  c=$(command -v db-manage 2>/dev/null) && { echo "$c"; return; }
  for c in /opt/cnm/update/db-manage.php /opt/cnm/db-manage.php \
           /opt/cnm/update/db/db-manage.php /opt/cnm/bin/db-manage.php; do
    [ -f "$c" ] && { echo "$c"; return; }
  done
  find /opt/cnm -maxdepth 4 -name 'db-manage*' -type f 2>/dev/null | head -1
}

# Ensena POR QUE ha fallado algo, sin obligar a ir a buscar el log, y sin
# imprimir valores sensibles: enmascara lo que parezca una contrasena.
diagnostico () {
  [ -s "$1" ] || { printf '      (el log %s esta vacio)\n' "$1"; return; }
  printf '      --- lineas con error de %s (valores enmascarados):\n' "$1"
  grep -i -E 'error|fatal|denied|cannot|no such|unknown|failed|exit' "$1" 2>/dev/null \
    | head -12 \
    | sed -E "s/((-p|--password=|password=|PWD=|identified by ')[^ '\"]*)/\2***/Ig" \
    | sed 's/^/      /'
}

while [ $# -gt 0 ]; do
  case "$1" in
    --huella)  MODO=huella ;;
    --validar) MODO=validar ;;
    --si)      SI=1 ;;
    -b) shift; BD="${1:-}" ;;
    -o) shift; SALIDA="${1:-}" ;;
    -h|--help) uso ;;
    *) echo "opcion desconocida: $1"; uso ;;
  esac
  shift
done
[ -n "$MODO" ] || uso
[ "$MODO" = validar ] && [ $SI -eq 0 ] && {
  echo "ERROR: --validar ESCRIBE en la base de datos '$BD' de $(hostname -s)."
  echo "       Solo tiene sentido en el DESTINO, antes del corte. Anade --si."
  exit 2
}

mariadb -N -B -e "SELECT 1" >/dev/null 2>&1 || {
  echo "ERROR: no se puede conectar al gestor. Falta /root/.my.cnf o no arranca."
  exit 2
}
mkdir -p "$SALIDA" || exit 2

#--- las cinco diferencias de presentacion -----------------------------------
# Se normalizan IGUAL en los dos lados, y se ve lo que hacen. Sin esto, la
# comparacion da ~165 diferencias falsas sobre las 121 columnas del modelo
# (medido: 30 falsas sobre una muestra de 22) y la de verdad queda enterrada.
cat > "$SALIDA/normaliza.awk" <<'AWK'
BEGIN { FS="|"; OFS="|" }
{
  gsub(/utf8mb3/, "utf8", $8); gsub(/utf8mb3/, "utf8", $9)   # 1 · nombre del charset
  gsub(/\(\)/, "", $6); gsub(/\(\)/, "", $7)                 # 2 · current_timestamp()
  $6 = toupper($6) == "CURRENT_TIMESTAMP" ? "CURRENT_TIMESTAMP" : $6
  $7 = toupper($7)
  if ($6 ~ /^'.*'$/) { $6 = substr($6, 2, length($6)-2) }     # 3 · defectos entrecomillados
  if ($6 == "NULL" || $6 == "") { $6 = "~" }                  # 4 · DEFAULT NULL
  if ($7 == "")                 { $7 = "~" }                  # 5 · EXTRA vacio
  print
}
AWK

huellas () {
  : > "$SALIDA/sql-errores.txt"
  # COLUMNAS · COLUMN_COMMENT va al ULTIMO a proposito: es el unico campo que
  # puede contener el separador. No afecta a la comparacion, que es linea a
  # linea; solo a la lectura del diff.
  q "SELECT CONCAT_WS('|', TABLE_NAME, COLUMN_NAME, ORDINAL_POSITION, COLUMN_TYPE,
            IS_NULLABLE, IFNULL(COLUMN_DEFAULT,'~'), IFNULL(EXTRA,'~'),
            IFNULL(CHARACTER_SET_NAME,'~'), IFNULL(COLLATION_NAME,'~'),
            IFNULL(COLUMN_COMMENT,'~'))
     FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA='$BD' AND TABLE_NAME LIKE 'sem\\_%'
       AND TABLE_NAME NOT LIKE '%\\_bak\\_%'
     ORDER BY TABLE_NAME, ORDINAL_POSITION" | awk -f "$SALIDA/normaliza.awk" > "$SALIDA/columnas.txt"

  # INDICES · sin CARDINALITY, que depende de los datos y no del esquema
  q "SELECT CONCAT_WS('|', TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX, COLUMN_NAME,
            NON_UNIQUE, IFNULL(SUB_PART,'~'), INDEX_TYPE)
     FROM information_schema.STATISTICS
     WHERE TABLE_SCHEMA='$BD' AND TABLE_NAME LIKE 'sem\\_%'
       AND TABLE_NAME NOT LIKE '%\\_bak\\_%'
     ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX" > "$SALIDA/indices.txt"

  # CLAVES AJENAS · con sus reglas ON UPDATE / ON DELETE, que SHOW CREATE si
  # ensena y un recuento no
  q "SELECT CONCAT_WS('|', k.TABLE_NAME, k.CONSTRAINT_NAME, k.ORDINAL_POSITION,
            k.COLUMN_NAME, k.REFERENCED_TABLE_NAME, k.REFERENCED_COLUMN_NAME,
            r.UPDATE_RULE, r.DELETE_RULE)
     FROM information_schema.KEY_COLUMN_USAGE k
     JOIN information_schema.REFERENTIAL_CONSTRAINTS r
       ON r.CONSTRAINT_SCHEMA=k.CONSTRAINT_SCHEMA
      AND r.CONSTRAINT_NAME=k.CONSTRAINT_NAME
     WHERE k.TABLE_SCHEMA='$BD' AND k.REFERENCED_TABLE_NAME IS NOT NULL
       AND k.TABLE_NAME LIKE 'sem\\_%'
     ORDER BY k.TABLE_NAME, k.CONSTRAINT_NAME, k.ORDINAL_POSITION" > "$SALIDA/ajenas.txt"

  # Las 17 columnas TIMESTAMP del modelo · RUNBOOK-MIGRACION-CNMPRD02 §1.5.bis
  q "SELECT CONCAT_WS('|', TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE,
            IFNULL(COLUMN_DEFAULT,'~'), IFNULL(EXTRA,'~'), '~','~','~')
     FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA='$BD' AND DATA_TYPE='timestamp'
       AND TABLE_NAME LIKE 'sem\\_%' AND TABLE_NAME NOT LIKE '%\\_bak\\_%'
     ORDER BY TABLE_NAME, ORDINAL_POSITION" | awk -f "$SALIDA/normaliza.awk" > "$SALIDA/timestamp.txt"
}

# Un error de SQL no puede quedar en silencio: una huella vacia por una consulta
# mal escrita se parece demasiado a una huella vacia porque no hay nada.
revisa_sql () {
  if [ -s "$SALIDA/sql-errores.txt" ]; then
    mal "$1" "ERROR de SQL en las huellas: $(grep -m1 -i 'error' "$SALIDA/sql-errores.txt" || head -1 "$SALIDA/sql-errores.txt"). Ver $SALIDA/sql-errores.txt"
    return 1
  fi
  return 0
}

cuenta_tablas  () { q "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$BD' AND TABLE_TYPE='BASE TABLE' AND TABLE_NAME LIKE 'sem\\_%' AND TABLE_NAME NOT LIKE '%\\_bak\\_%'"; }
cuenta_bak     () { q "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='$BD' AND TABLE_NAME LIKE '%\\_bak\\_%'"; }
cuenta_ajenas  () { q "SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS WHERE CONSTRAINT_SCHEMA='$BD' AND CONSTRAINT_TYPE='FOREIGN KEY'"; }
cuenta_vistas  () { q "SELECT COUNT(*) FROM information_schema.VIEWS WHERE TABLE_SCHEMA='$BD' AND TABLE_NAME NOT LIKE 'vlogp\\_%'"; }

printf '================================================================\n'
printf ' t-plugin-semantic.sh · %s · bd=%s · modo=%s\n' "$(hostname -s)" "$BD" "$MODO"
printf ' %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
printf '================================================================\n'

#=== T1 · el entorno del gestor ==============================================
tit "T1 · entorno del gestor"
VER=$(mariadb -N -B -e "SELECT VERSION()")
SQLM=$(mariadb -N -B -e "SELECT @@sql_mode")
EDFT=$(mariadb -N -B -e "SELECT @@explicit_defaults_for_timestamp")
printf '  version ............ %s\n' "$VER"
printf '  sql_mode ........... %s\n' "$SQLM"
printf '  explicit_defaults .. %s\n' "$EDFT"
case "$SQLM" in
  *NO_ZERO_DATE*) mal T1 "sql_mode incluye NO_ZERO_DATE: el CREATE de sem_sla_evaluation fallara (period_start/_end llevan '0000-00-00 00:00:00')" ;;
  *)              ok  T1 "sql_mode sin NO_ZERO_DATE: los dos defectos de fecha cero son legales" ;;
esac
[ "$EDFT" = "1" ] && avi T1 "explicit_defaults_for_timestamp=ON. No afecta a lo que viaja en el volcado, que lleva las columnas declaradas; si afectaria a rederivar el esquema del .sql del repositorio (RUNBOOK-MIGRACION-CNMPRD02 §1.3.a)"

#=== Modo solo lectura =======================================================
if [ "$MODO" = huella ]; then
  tit "T6 · huellas del esquema (solo lectura)"
  huellas
  revisa_sql T6
  printf '  tablas sem_* ....... %s   (+%s copias _bak_)\n' "$(cuenta_tablas)" "$(cuenta_bak)"
  printf '  claves ajenas ...... %s\n' "$(cuenta_ajenas)"
  printf '  vistas no vlogp_ ... %s\n' "$(cuenta_vistas)"
  for f in columnas indices ajenas timestamp; do
    n=$(wc -l < "$SALIDA/$f.txt")
    [ "$n" -gt 0 ] && ok T6 "$f.txt · $n lineas" || mal T6 "$f.txt VACIO: una huella vacia no es un aprobado"
  done
  printf '\n  Huellas en %s\n' "$SALIDA"
  printf '  Copiarlas al otro equipo y comparar linea a linea:\n'
  printf '    for f in columnas indices ajenas timestamp; do\n'
  printf '      echo "== $f"; diff <origen>/$f.txt <destino>/$f.txt; done\n'
fi

#=== Modo destructivo ========================================================
if [ "$MODO" = validar ]; then
  [ -x "$PLUGIN/install" ] || { na T2 "no existe $PLUGIN/install"; }
  if [ -x "$PLUGIN/install" ]; then

    NVISTAS_SQL=$(ls -1 "$PLUGIN"/sql/views/*.sql 2>/dev/null | wc -l)

    #--- que vistas NO se pueden evaluar en esta instalacion, y por que -------
    # devices_custom_data se declara con UNA sola columna, id_dev: las columnaN
    # las crea el producto dinamicamente, una por cada campo de usuario que el
    # cliente define en el GUI (columna<id de devices_custom_types>). En una
    # instalacion recien hecha no hay ninguna, asi que una vista que use
    # columna7 NO PUEDE crearse, y eso no es un defecto del plugin ni del gestor.
    #
    # Sin esto el test decia FALLA sobre algo que es correcto. Es la regla 7:
    # una comprobacion que no sabe decir «no lo se» no puede decir «esta mal».
    COLS_HAY=$(q "SELECT GROUP_CONCAT(COLUMN_NAME) FROM information_schema.COLUMNS
                   WHERE TABLE_SCHEMA='$BD' AND TABLE_NAME='devices_custom_data'
                     AND COLUMN_NAME LIKE 'columna%'")
    # GROUP_CONCAT sobre cero filas devuelve NULL, y mariadb lo imprime como la
    # cadena "NULL". Sin esto el mensaje dice "tiene: NULL", que se lee mal.
    [ "$COLS_HAY" = "NULL" ] && COLS_HAY=""
    NO_EVAL=""
    for f in "$PLUGIN"/sql/views/*.sql; do
      for c in $(grep -oE 'columna[0-9]+' "$f" 2>/dev/null | sort -u); do
        case ",$COLS_HAY," in
          *",$c,"*) ;;
          *) NO_EVAL="$NO_EVAL $(basename "$f" .sql)[$c]"; break ;;
        esac
      done
    done
    N_NO_EVAL=$(echo $NO_EVAL | wc -w)
    NVISTAS_ESP=$((NVISTAS_SQL - N_NO_EVAL))
    ESQUEMA_OK=0   # lo pone a 1 el T2 si de verdad quedan las 12 tablas

    #--- T2 · instalacion desde cero -----------------------------------------
    tit "T2 · instalacion desde cero"
    T0=$(cuenta_tablas)
    printf '  tablas sem_* antes . %s\n' "$T0"
    [ "$T0" -eq 0 ] || avi T2 "ya hay $T0 tablas sem_*: esto NO es una instalacion desde cero, es una convergencia. Las dos pruebas valen, pero no son la misma"
    "$PLUGIN/install" > "$SALIDA/t2-install.log" 2>&1; RC=$?
    TT=$(cuenta_tablas); AA=$(cuenta_ajenas); VV=$(cuenta_vistas)
    printf '  rc=%s · tablas=%s · ajenas=%s · vistas=%s · ficheros de vista=%s\n' "$RC" "$TT" "$AA" "$VV" "$NVISTAS_SQL"
    if [ "$TT" -eq 12 ]; then ok T2 "12 tablas sem_*"; ESQUEMA_OK=1
    else mal T2 "$TT tablas sem_*, se esperaban 12"; diagnostico "$SALIDA/t2-install.log"; fi
    [ "$AA" -eq 11 ] && ok T2 "11 claves ajenas" || mal T2 "$AA claves ajenas, se esperaban 11"
    if [ "$NVISTAS_SQL" -eq 0 ]; then
      na T2 "no se pueden contar los ficheros de sql/views/"
    else
      if [ "$N_NO_EVAL" -gt 0 ]; then
        avi T2 "$N_NO_EVAL vista(s) NO se pueden crear en esta instalacion porque usan una columna de usuario que todavia no existe:$NO_EVAL"
        printf '      devices_custom_data tiene: %s\n' "${COLS_HAY:-ninguna columnaN}"
        printf '      Las columnaN las crea el GUI al definir campos de usuario. Sobre la\n'
        printf '      onm RESTAURADA del corte existiran, y entonces estas vistas si se crean.\n'
      fi
      if [ "$VV" -eq "$NVISTAS_ESP" ]; then
        ok T2 "$VV vistas, las $NVISTAS_ESP evaluables de $NVISTAS_SQL"
      else
        mal T2 "$VV vistas y se esperaban $NVISTAS_ESP evaluables (de $NVISTAS_SQL ficheros): no cuadran"
      fi
    fi
    # OJO con la marca. La v1.0 buscaba 'errores: 0' a secas, y eso lo imprime
    # TAMBIEN db-manage en su propio resumen: con 8 vistas de 11 el test daba
    # PASA porque casaba la linea de db-manage y no la del post-install, que
    # decia 'errores: 3'. Una marca que casa en dos sitios distintos no es una
    # marca. Ahora se exige la linea COMPLETA del post-install.
    if grep -qE 'Vistas aplicadas:.*errores: 0' "$SALIDA/t2-install.log"; then
      ok T2 "el post-install dice 'Vistas aplicadas: N · errores: 0'"
    else
      if [ "$N_NO_EVAL" -gt 0 ] && [ "$VV" -eq "$NVISTAS_ESP" ]; then
        avi T2 "el post-install dice 'errores: $N_NO_EVAL', y son exactamente las $N_NO_EVAL que no se pueden evaluar aqui. No es un fallo: se valida en el ensayo sobre la onm restaurada"
      else
        mal T2 "el post-install NO dice 'errores: 0'. rc=$RC no es prueba, y rc=2 significa justo esto: alguna vista fallo"
      fi
      grep -n 'cnm-semantic.*ERROR' "$SALIDA/t2-install.log" | head -12 | sed 's/^/      /'
    fi

    #--- T3 · idempotencia, cinco veces --------------------------------------
    tit "T3 · idempotencia · cinco ejecuciones seguidas"
    if [ "$ESQUEMA_OK" -eq 0 ]; then
      na T3 "T2 no ha dejado las 12 tablas, asi que aqui no hay idempotencia que medir: cinco pasadas sobre una instalacion que no existe miden cinco veces el mismo fallo, no la idempotencia del plugin"
    else
    MALAS=0
    for i in 1 2 3 4 5; do
      "$PLUGIN/install" > "$SALIDA/t3-$i.log" 2>&1
      A=$(grep -c 'ESQUEMA: 0 ALTER' "$SALIDA/t3-$i.log")
      E=$(grep -c 'errores: 0'       "$SALIDA/t3-$i.log")
      printf '  pasada %s · "ESQUEMA: 0 ALTER"=%s · "errores: 0"=%s\n' "$i" "$A" "$E"
      [ "$A" -ge 1 ] && [ "$E" -ge 1 ] || MALAS=$((MALAS+1))
    done
    [ "$MALAS" -eq 0 ] && ok T3 "las cinco pasadas: 0 ALTER y 0 errores" \
      || { mal T3 "$MALAS de 5 pasadas no estan limpias: el plugin no converge en $VER"; diagnostico "$SALIDA/t3-1.log"; }
    fi

    #--- T4 · convergencia · cuatro roturas deliberadas ----------------------
    # Este es el test que puede ponerse en rojo: si el plugin no restaura algo,
    # aqui se ve. Las cuatro roturas son las cuatro formas en que un esquema
    # puede divergir, y las cuatro las tiene que arreglar el mismo install.
    tit "T4 · convergencia · se rompe a proposito y se mira si lo arregla"
    if [ "$ESQUEMA_OK" -eq 0 ]; then
      na T4 "sin las 12 tablas no se puede romper nada para ver si lo arregla"
    else
    huellas; revisa_sql T4
    cp "$SALIDA/columnas.txt" "$SALIDA/t4-ref-columnas.txt"
             cp "$SALIDA/indices.txt"  "$SALIDA/t4-ref-indices.txt"
             cp "$SALIDA/ajenas.txt"   "$SALIDA/t4-ref-ajenas.txt"

    rompe () { # $1 id · $2 descripcion · $3 SQL que rompe · $4 huella a comparar
      mariadb "$BD" -e "$3" 2>"$SALIDA/t4-$1.err"
      if [ -s "$SALIDA/t4-$1.err" ]; then
        na T4 "$2 · no se ha podido romper: $(grep -m1 -i 'error' "$SALIDA/t4-$1.err" || head -1 "$SALIDA/t4-$1.err")"
        return
      fi
      huellas; revisa_sql T4 || return
      ROTO=$(diff "$SALIDA/t4-ref-$4.txt" "$SALIDA/$4.txt" | grep -c '^[<>]')
      if [ "$ROTO" -eq 0 ]; then
        mal T4 "$2 · la huella NO ha detectado la rotura: la comparacion no sirve"
        return
      fi
      "$PLUGIN/install" > "$SALIDA/t4-$1.log" 2>&1
      huellas; revisa_sql T4 || return
      QUEDA=$(diff "$SALIDA/t4-ref-$4.txt" "$SALIDA/$4.txt" | grep -c '^[<>]')
      [ "$QUEDA" -eq 0 ] && ok T4 "$2 · roto ($ROTO lineas) y restaurado" \
        || mal T4 "$2 · roto ($ROTO lineas) y NO restaurado: quedan $QUEDA"
    }

    rompe col "columna borrada (sem_metric_concept.ds_total)" \
      "ALTER TABLE sem_metric_concept DROP COLUMN ds_total" columnas
    rompe tipo "tipo cambiado (sem_business_role.health_threshold)" \
      "ALTER TABLE sem_business_role MODIFY health_threshold decimal(5,2) NOT NULL DEFAULT 0.50" columnas
    rompe idx "indice borrado (sem_binding_role.ix_retired)" \
      "DROP INDEX ix_retired ON sem_binding_role" indices
    rompe fk  "clave ajena borrada (sem_metric_concept_ibfk_1)" \
      "ALTER TABLE sem_metric_concept DROP FOREIGN KEY sem_metric_concept_ibfk_1" ajenas

    A=$(cuenta_ajenas)
    [ "$A" -eq 11 ] && ok T4 "siguen 11 claves ajenas despues de todo" \
      || mal T4 "quedan $A claves ajenas de 11. OJO: 'ESQUEMA: 0 ALTER' NO cuenta las ajenas (RUNBOOK-MIGRACION-CNMPRD02 §1.6), asi que hay que contarlas aparte SIEMPRE"
    fi

    #--- T5 · db-manage estandar despues del plugin --------------------------
    tit "T5 · db-manage estandar despues del plugin"
    DBMANAGE=$(busca_dbmanage)
    printf '  db-manage .......... %s\n' "${DBMANAGE:-NO ENCONTRADO}"
    if [ -n "$DBMANAGE" ] && [ -f "$DBMANAGE" ]; then
      case "$DBMANAGE" in *.php) php "$DBMANAGE" ;; *) "$DBMANAGE" ;; esac > "$SALIDA/t5-dbmanage.log" 2>&1; RC=$?
      N1347=$(grep -c 1347 "$SALIDA/t5-dbmanage.log")
      printf '  rc=%s · errores 1347=%s\n' "$RC" "$N1347"
      [ "$N1347" -eq 0 ] && ok T5 "0 errores 1347: A21 sigue aplicada" \
        || mal T5 "$N1347 errores 1347: el ALTER sobre una vista ha vuelto. Sin A21 esta migracion no es viable"
      grep -q 'RESULTADO: correcto' "$SALIDA/t5-dbmanage.log" && ok T5 "la salida dice 'RESULTADO: correcto'" \
        || mal T5 "la salida NO dice 'RESULTADO: correcto': ver $SALIDA/t5-dbmanage.log"
      grep -q 'ESQUEMA: 0 ALTER' "$SALIDA/t5-dbmanage.log" && ok T5 "0 ALTER: el plugin no deja nada que db-manage quiera cambiar" \
        || avi T5 "db-manage quiere cambiar algo del esquema despues del plugin: mirar que"
    else
      na T5 "no se encuentra db-manage. Buscado: command -v db-manage, /opt/cnm/update/, /opt/cnm/, /opt/cnm/update/db/, /opt/cnm/bin/ y un find en /opt/cnm"
    fi

    #--- T6 · huellas, para comparar con el origen ---------------------------
    tit "T6 · huellas del esquema"
    if [ "$ESQUEMA_OK" -eq 0 ]; then
      na T6 "sin las 12 tablas, una huella vacia es lo CORRECTO y no dice nada del gestor"
    else
    huellas
    revisa_sql T6
    for f in columnas indices ajenas timestamp; do
      n=$(wc -l < "$SALIDA/$f.txt")
      [ "$n" -gt 0 ] && ok T6 "$f.txt · $n lineas" || mal T6 "$f.txt VACIO: una huella vacia no es un aprobado"
    done
    NTS=$(wc -l < "$SALIDA/timestamp.txt")
    [ "$NTS" -eq 17 ] && ok T6 "17 columnas TIMESTAMP, las del modelo" \
      || avi T6 "$NTS columnas TIMESTAMP, se esperaban 17 (RUNBOOK-MIGRACION-CNMPRD02 §1.5.bis)"
    fi
  fi
fi

#=== veredicto ===============================================================
printf '\n================================================================\n'
printf ' %s pasa · %s falla · %s n/a · %s aviso\n' "$P" "$F" "$NA" "$AV"
if [ $((P+F)) -eq 0 ]; then
  printf ' VEREDICTO: SIN DATOS  (no se evaluo ningun test: eso NO es aprobado)\n'
  printf 'RESUMEN guion=t-plugin-semantic.sh modo=%s pasa=%s falla=%s na=%s aviso=%s veredicto=SIN_DATOS\n' "$MODO" "$P" "$F" "$NA" "$AV"
  exit 2
elif [ "$F" -gt 0 ]; then
  printf ' VEREDICTO: FALLA\n'
  printf 'RESUMEN guion=t-plugin-semantic.sh modo=%s pasa=%s falla=%s na=%s aviso=%s veredicto=FALLA\n' "$MODO" "$P" "$F" "$NA" "$AV"
  exit 1
else
  printf ' VEREDICTO: PASA\n'
  printf 'RESUMEN guion=t-plugin-semantic.sh modo=%s pasa=%s falla=%s na=%s aviso=%s veredicto=PASA\n' "$MODO" "$P" "$F" "$NA" "$AV"
  exit 0
fi
