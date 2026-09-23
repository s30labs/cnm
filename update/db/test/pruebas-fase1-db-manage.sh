#!/bin/bash
# =============================================================================
# Pruebas de regresión de la fase 1 de REV-CNM-02 (db-manage.php)
#
# SEGURO EN UN APPLIANCE REAL: no borra bases de datos, no reinstala plugins y
# no toca /cfg/onm.conf. La prueba de la contraseña usa variables de entorno,
# que get_db_credentials() consulta antes que el fichero.
#
# Uso:  CNM_TEST_OK=1 ./pruebas-fase1-db-manage.sh
# =============================================================================
set -u
[ "${CNM_TEST_OK:-0}" = "1" ] || { echo "Ejecutar con CNM_TEST_OK=1"; exit 1; }

DBM="php /update/db/db-manage.php"
GUI_LOG=/var/log/apache2/cnm_gui.log
OK=0; KO=0

check(){ # descripción, rc_esperado, rc_obtenido
   if [ "$2" = "$3" ]; then echo "  [OK]   $1 (RC=$3)"; OK=$((OK+1));
   else echo "  [FALLO] $1 (esperado RC=$2, obtenido RC=$3)"; KO=$((KO+1)); fi
}

echo "== T1 · ejecución estándar: RC=0 y resumen sin errores"
$DBM > /tmp/t1.log 2>&1; check "db-manage estándar" 0 $?
tail -1 /tmp/t1.log

echo "== T2 · idempotencia: los recuentos no cambian"
cnt(){ mysql -N onm -e "SELECT
  (SELECT COUNT(*) FROM cfg_monitor),(SELECT COUNT(*) FROM cfg_monitor_snmp),
  (SELECT COUNT(*) FROM tips),(SELECT COUNT(*) FROM plugin_base),
  (SELECT COUNT(*) FROM cfg_report2item),(SELECT COUNT(*) FROM alert_type)"; }
A=$(cnt); $DBM > /tmp/t2.log 2>&1; RC=$?; B=$(cnt)
check "segunda ejecución" 0 $RC
if [ "$A" = "$B" ]; then echo "  [OK]   recuentos iguales: $A"; OK=$((OK+1));
else echo "  [FALLO] recuentos distintos: [$A] -> [$B]"; KO=$((KO+1)); fi

echo "== T3 · IP sin BBDD de cliente: debe abortar con RC=3"
CNM_LOCAL_IP=203.0.113.99 $DBM > /tmp/t3.log 2>&1; check "IP inexistente" 3 $?
grep -q "No hay BBDD de cliente" /tmp/t3.log && echo "  [OK]   mensaje explícito" && OK=$((OK+1))

echo "== T4 · credenciales incorrectas: debe abortar con RC=1"
CNM_DB_SERVER=localhost CNM_DB_PASSWORD=clave-que-no-es $DBM > /tmp/t4.log 2>&1; check "clave incorrecta" 1 $?

echo "== T5 · sin contraseñas en la salida ni en el log"
N=$(cat /tmp/t1.log /tmp/t4.log 2>/dev/null | grep -cE "password=>[^*]|IDENTIFIED BY '[^*]") || true
M=$(grep -cE "password=>[^*]|IDENTIFIED BY '[^*]" "$GUI_LOG" 2>/dev/null) || true
M=${M:-0}
if [ "$N" = "0" ] && [ "$M" = "0" ]; then echo "  [OK]   0 contraseñas visibles"; OK=$((OK+1));
else echo "  [FALLO] contraseñas visibles: salida=$N log=$M"; KO=$((KO+1)); fi

echo "== T6 · opción -u (antes: error fatal RC=255)"
$DBM -u cfg_users > /tmp/t6.log 2>&1; check "-u cfg_users" 0 $?

echo "== T7 · opción -x (antes: error fatal RC=255)"
printf '<?xml version="1.0"?><root><data><TIPS/></data></root>' > /tmp/prueba-vacia.xml
$DBM -x /tmp/prueba-vacia.xml > /tmp/t7.log 2>&1; check "-x fichero xml" 0 $?

echo
echo "RESULTADO: $OK correctas, $KO fallidas"
[ "$KO" = "0" ] || exit 1

cat <<'FIN'

Pruebas que NO están aquí porque solo deben hacerse en laboratorio:
  · instalación desde cero (DROP de cnm y onm)
  · contraseña de BBDD que contiene '='
  · reinstalación de un plugin (borra parámetros de métricas del usuario: A4)
  · error de datos provocado (trigger que bloquea un INSERT) para ver el RC=2
FIN
