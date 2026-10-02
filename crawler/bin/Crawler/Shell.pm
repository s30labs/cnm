package Crawler::Shell;
#-------------------------------------------------------------------------------
# Crawler::Shell - Construccion segura de ordenes de shell
#
# Producto CNM. /opt/cnm/crawler/bin/Crawler/Shell.pm
#
# Funciones puras: sin estado, sin E/S, sin configuracion. Compatible con
# perl 5.8 en adelante (probado en 5.20 / Debian 8 y 5.38 / Debian 13).
#
# Ver REF-CNM-02 seccion 13 para el criterio completo.
#-------------------------------------------------------------------------------
use strict;
use warnings;
use Exporter;

use vars qw(@ISA @EXPORT_OK $VERSION);
@ISA       = qw(Exporter);
@EXPORT_OK = qw(sh cmd mask);
$VERSION   = '1.00';

#--- Conjunto de caracteres que /bin/sh NO interpreta. Un valor formado solo
#--- por estos se emite sin comillas: no cambia el resultado y deja la orden
#--- legible en los logs y en los volcados de depuracion.
my $SEGURO = qr{^[A-Za-z0-9_\@\%\+\=\:\,\./\-]+$};

#-------------------------------------------------------------------------------
# sh($valor) -> el valor listo para ocupar UN argumento de /bin/sh
#-------------------------------------------------------------------------------
sub sh {
my @a = @_;
   #--- Tolerar la invocacion como metodo de clase: Crawler::Shell->sh($v).
   #--- Sin esto devolveria el nombre del paquete entrecomillado, en silencio.
   if ((scalar(@a) == 2) && (defined $a[0]) && ($a[0] eq __PACKAGE__)) { shift @a; }
my $v = $a[0];

   if ((! defined $v) || ($v eq '')) { return "''"; }
   if ($v =~ $SEGURO)                { return $v; }

   #--- Entrecomillado fuerte. Dentro de '...' el shell no interpreta NADA,
   #--- ni siquiera la barra invertida. La unica secuencia imposible es la
   #--- propia comilla simple, que se cierra, se escapa y se reabre.
   $v =~ s/'/'\\''/g;
   return "'".$v."'";
}

#-------------------------------------------------------------------------------
# cmd(@argv) -> la orden completa, con cada elemento entrecomillado
#-------------------------------------------------------------------------------
sub cmd {
my @a = @_;
   if ((defined $a[0]) && ($a[0] eq __PACKAGE__)) { shift @a; }
   return join(' ', map { sh($_) } @a);
}

#-------------------------------------------------------------------------------
# mask($texto, @valores) -> el texto con esos valores ocultos
#-------------------------------------------------------------------------------
sub mask {
my @a = @_;
   if ((defined $a[0]) && ($a[0] eq __PACKAGE__)) { shift @a; }
my $txt = shift @a;
   if (! defined $txt) { return ''; }

   #--- Primero la forma ENTRECOMILLADA y despues la cruda. Al reves, tras
   #--- sustituir el valor quedarian las comillas sueltas y el resultado
   #--- delataria la longitud y la forma del original.
my @formas;
   foreach my $v (@a) {
      next if ((! defined $v) || (length($v) < 3));
      push(@formas, sh($v));
      push(@formas, $v);
   }
   foreach my $f (sort { length($b) <=> length($a) } @formas) {
      my $q = quotemeta($f);
      $txt =~ s/$q/'*' x 6/ge;
   }
   return $txt;
}

1;

__END__

=head1 NAME

Crawler::Shell - Construccion segura de ordenes de shell

=head1 SYNOPSIS

   use lib '/opt/cnm/crawler/bin';
   use Crawler::Shell qw(sh cmd mask);

   # Una orden sencilla
   my $orden = cmd('/usr/bin/snmpwalk','-v2c','-c',$comunidad,$ip,$oid);

   # Una orden que viaja DENTRO de un contenedor
   my $int = cmd('/opt/mssql-tools/bin/sqlcmd','-C','-y','0','-s','|',
                 '-S',$host,'-d','AREAS','-U',$user,'-P',$pwd,'-Q',$sql);
   my $ext = cmd('docker','run','--rm','-i',$imagen,'sh','-c',$int);

   # La sintaxis de shell se pega a mano, FUERA del escapador
   $ext .= ' 2>'.sh($fichero_error);

   # Para registrar la orden sin exponer la clave
   $crawler->log('debug', mask($ext, $pwd));

=head1 DESCRIPTION

Casi todos los conectores de CNM obtienen el dato lanzando un cliente externo
(C<hdbsql>, C<sqlcmd>, C<smbclient>, C<snmpwalk>, C<curl>...), a menudo dentro
de un contenedor. El valor que se pasa a ese cliente atraviesa varias capas,
y B<cada una tiene su propia sintaxis>:

   perl -> fichero .sh -> bash -> docker -> shell del contenedor -> cliente -> SQL

La norma de la casa es B<escapar una vez por frontera, en la direccion del
viaje, y ninguna mas>. Ni una de menos (inyeccion) ni una de mas (el valor
llega con barras invertidas de adorno).

De ahi salen cuatro reglas practicas:

=over 4

=item 1.

B<Construir listas, no cadenas.> Una orden es un vector de argumentos; el
texto es solo su serializacion.

=item 2.

B<Sustituir antes de entrecomillar, nunca despues.> Los marcadores
C<__NUMSERIE__> obligan a inyectar texto cuando las comillas ya estan puestas.

=item 3.

B<Entrecomillar todo.> C<'-C' '-y' '0'> funciona igual que C<-C -y 0>. Lo que
B<no> pasa por el escapador es la sintaxis que si se quiere interpretar:
C<< 2> >>, C<|>, C<&&>.

=item 4.

B<Ninguna comilla en la plantilla.> Si en el codigo fuente hay una comilla
pegada a una variable, sobra. Las comillas las pone C<sh()>.

=back

El criterio completo, con el estado medido de C</opt/cnm-areas>, esta en
C<REF-CNM-02-Motor-Perl-Interno-app-runner.md> seccion 13.

=head1 FUNCTIONS

Ninguna se exporta por defecto. Las tres son puras: no guardan estado, no
tocan disco ni red, y devuelven siempre el mismo resultado para la misma
entrada. Se pueden invocar como funciones o como metodos de clase
(C<< Crawler::Shell->sh($v) >>), pero B<no> hay constructor: no hay nada que
construir.

=head2 sh($valor)

Devuelve C<$valor> preparado para ocupar B<un> argumento de C</bin/sh>.

   sh("a'b")            #  'a'\''b'
   sh('100%$(whoami)')  #  '100%$(whoami)'
   sh('-C')             #  -C          (no necesita comillas)
   sh('')               #  ''          (un argumento vacio, no nada)
   sh(undef)            #  ''

Un C<undef> produce un argumento B<vacio>, no la ausencia de argumento. Es
deliberado: con C<-P ''> el cliente falla al autenticar y se ve en el log,
mientras que omitir el valor desplazaria el resto de la linea de ordenes y el
fallo seria mucho mas dificil de leer.

El entrecomillado es B<fuerte> (comilla simple): dentro de C<'...'> el shell
no interpreta nada, ni siquiera la barra invertida. La unica secuencia
imposible es la propia comilla simple, que se cierra, se escapa y se reabre
(C<'\''>).

Los valores formados solo por caracteres inertes se devuelven sin comillas. No
cambia el resultado y mantiene las ordenes legibles.

=head2 cmd(@argv)

Serializa un vector de argumentos aplicando C<sh()> a cada uno.

   cmd('psql','-h',$host,'-U',$user,'-c',$consulta)

B<Compone consigo misma>, que es lo que hace manejable el anidamiento en
contenedores: la orden interior es, para la exterior, un valor mas, y recibe
una capa adicional de entrecomillado de forma automatica.

=head2 mask($texto, @valores)

Devuelve C<$texto> con cada uno de C<@valores> sustituido por asteriscos. Se
oculta tanto la forma cruda como la entrecomillada, y se empieza por la mas
larga para que no queden restos.

   mask($orden, $pwd)   #  ... -U usuario -P ****** -Q '...'

Los valores de menos de tres caracteres se ignoran: enmascararlos destrozaria
el resto del texto sin ocultar nada util.

B<Es una ayuda para trazas, no un control de seguridad.> Solo oculta los
valores que se le pasan. Si la orden lleva una credencial que el llamante no
declara, C<mask> no la ve.

=head1 LO QUE ESTE MODULO NO CUBRE

C<sh()> protege B<una sola frontera>: la del shell. Las demas necesitan su
propio tratamiento y B<no son intercambiables>:

   Frontera            Herramienta correcta              Nunca
   -----------------   -------------------------------   --------
   shell / docker      Crawler::Shell::sh()              sprintf con comillas
   SQL                 prepare + ?, o validacion         sh()
   URL                 URI::Escape::uri_escape           sh()
   filtro LDAP         escape RFC 4515                   sh()
   JSON                encode_json                       concatenar
   regex               quotemeta                         nada

Con clientes de linea de ordenes (C<sqlcmd>, C<hdbsql>) B<no hay C<prepare>
posible>: no es DBI. La unica defensa para los valores que entran en el texto
SQL es validar el formato antes de componerlo. Que un valor llegue literal al
shell B<no lo hace inocuo para el servidor remoto>.

Tampoco protege del B<getopt del cliente>: un valor que empieza por C<-> se
entrecomilla correctamente y aun asi el cliente puede tomarlo por una opcion.
Para eso esta el separador C<-->, cuando el cliente lo admite.

Y no gestiona credenciales: eso es C<CNMAreas::Credentials>, cuyo metodo
C<sh()> delega en este modulo.

=head1 VALIDACION

El escapado no se valida leyendolo, se valida B<ejecutandolo>. El
procedimiento, que sirve para cualquier sustitucion en un conector, es
sustituir el binario por un script que vuelque lo que recibe:

   #!/bin/sh
   i=0
   for a in "$@"; do i=$((i+1)); printf 'arg[%d]=[%s]\n' "$i" "$a"; done

Se ejecuta la version vieja y la nueva contra el y se comparan con C<diff>. Si
salen identicas, el cambio es seguro por construccion y B<no necesita ventana
de produccion>.

La bateria de C<t/shell.t> cubre dos capas de anidamiento y contrasenas con
C<$>, comillas simples y dobles, acentos graves, barras invertidas, C<%>,
tuberias, puntos y coma, ampersands, espacios y tabuladores.

=head1 VER TAMBIEN

C<REF-CNM-02> seccion 13 (criterio y estado del codigo),
C<CNMAreas::Credentials>,
C<cnm-areas-credenciales.pl --quoting> (mide el cumplimiento).

=cut
