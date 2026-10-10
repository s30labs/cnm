#!/bin/bash
#-----------------------------------------------------------------------------
# Prepara el sistema para que `cpanm Filesys::SmbClient` funcione SIN
# interaccion.  Pensado para ejecutarse en el rol base ANTES de cpan-install.pl
#
#   ./prep-filesys-smbclient.sh            # lo hace
#   ./prep-filesys-smbclient.sh --comprobar  # solo mira, no toca nada
#
# POR QUE HACE FALTA
#   El Makefile.PL de Filesys-SmbClient-3.2 busca libsmbclient.h y
#   libsmbclient.so con una lista de prefijos FIJA:
#       /usr   /usr/local   /usr/local/samba   /usr/local/samba3
#   a cada uno le anade /include o /lib, y pregunta con prompt().
#   En Debian las cabeceras estan en /usr/include/samba-4.0 y la biblioteca
#   en /usr/lib/<arch>/, asi que NINGUNA de las dos busquedas acierta.
#   Como cpanm fija PERL_MM_USE_DEFAULT=1, los prompt() toman su valor por
#   defecto -que es undef- y el build acaba buscando "/libsmbclient.h".
#
#   En vez de automatizar los dialogos -fragil-, se le da un arbol en uno de
#   los prefijos que SI conoce: /usr/local/samba.  Con eso try_to_find()
#   acierta, los prompt() toman defaults correctos y cpanm no pregunta nada.
#
#   Se enlazan TODAS las cabeceras de samba-4.0, no solo libsmbclient.h: si
#   esa incluye a otras del mismo arbol, con un enlace suelto fallaria al
#   compilar en vez de al configurar.
#
# Idempotente: se puede ejecutar las veces que haga falta.
# Solo crea enlaces simbolicos bajo /usr/local/samba. No toca /usr.
#-----------------------------------------------------------------------------
set -eu
SOLO_MIRAR=0
[ "${1:-}" = "--comprobar" ] && SOLO_MIRAR=1
PREFIJO=/usr/local/samba

fallo() { echo "FALLO: $*" >&2; exit 1; }

#--- 1. el paquete de cabeceras tiene que estar ------------------------------
dpkg -s libsmbclient-dev >/dev/null 2>&1 || fallo \
  "falta libsmbclient-dev. Es dependencia de COMPILACION de Filesys::SmbClient
         (modulo XS), y sin ella el rol funciona en una maquina donde alguien
         la instalo a mano y falla en la siguiente instalacion limpia.
         Anadirla al rol:  apt: name=libsmbclient-dev state=present"

#--- 2. localizar cabecera y biblioteca, sin suponer la arquitectura ---------
H=$(dpkg -L libsmbclient-dev | grep -m1 '/libsmbclient\.h$'  || true)
L=$(dpkg -L libsmbclient-dev | grep -m1 '/libsmbclient\.so$' || true)
[ -n "$H" ] || fallo "libsmbclient-dev no trae libsmbclient.h"
[ -n "$L" ] || fallo "libsmbclient-dev no trae libsmbclient.so"
DIR_H=$(dirname "$H")
DIR_L=$(dirname "$L")

echo "cabecera   : $H"
echo "biblioteca : $L"

#--- 3. que incluye la cabecera (por si hiciera falta mas de un enlace) ------
echo "incluye    : $(grep -c '^#include' "$H" 2>/dev/null || echo '?') directiva(s)"
grep '^#include' "$H" 2>/dev/null | sed 's/^/             /' | head -8

if [ "$SOLO_MIRAR" = 1 ]; then
   echo
   echo "(--comprobar: no se ha tocado nada)"
   echo "se crearia: $PREFIJO/include/*.h  y  $PREFIJO/lib/libsmbclient.so"
   exit 0
fi

#--- 4. el arbol que el Makefile.PL sabe encontrar ---------------------------
install -d -m 0755 "$PREFIJO/include" "$PREFIJO/lib"
n=0
for f in "$DIR_H"/*.h; do
   [ -e "$f" ] || continue
   ln -sfn "$f" "$PREFIJO/include/$(basename "$f")"
   n=$((n+1))
done
ln -sfn "$L" "$PREFIJO/lib/libsmbclient.so"
echo "enlazadas  : $n cabecera(s) en $PREFIJO/include"
echo "enlazada   : $PREFIJO/lib/libsmbclient.so"

#--- 5. comprobar que AHORA el Makefile.PL lo encontraria --------------------
# Se reproduce su busqueda: uno de sus cuatro prefijos + /include y + /lib.
[ -r "$PREFIJO/include/libsmbclient.h" ] || fallo "el enlace de la cabecera no es legible"
[ -r "$PREFIJO/lib/libsmbclient.so" ]    || fallo "el enlace de la biblioteca no es legible"
echo
echo "OK: Filesys::SmbClient ya encuentra las dos. cpanm no preguntara nada."
echo "    Comprobacion despues de instalarlo:"
echo "      perl -MFilesys::SmbClient -e 'print \"carga\\n\"'"
