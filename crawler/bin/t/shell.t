#!/usr/bin/perl
#-------------------------------------------------------------------------------
# t/shell.t - Bateria de Crawler::Shell
#
# No comprueba el TEXTO que produce sh(), sino lo que le llega al programa
# ejecutado. Es la unica comprobacion que vale: el texto intermedio es
# ilegible a proposito y no dice nada por si mismo.
#
#   perl -Ilib t/shell.t          (o prove -Ilib t/shell.t)
#-------------------------------------------------------------------------------
use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use Crawler::Shell qw(sh cmd mask);

my $DIR = tempdir(CLEANUP => 1);

#--- El programa espia: vuelca cada argumento en una linea, delimitado.
open(my $fh,'>',"$DIR/ver") or die $!;
print $fh "#!/bin/sh\n".
          "i=0\n".
          "for a in \"\$\@\"; do i=\$((i+1)); printf 'arg[%d]=[%s]\\n' \"\$i\" \"\$a\"; done\n";
close($fh);
chmod(0755,"$DIR/ver");

#--- Ejecuta una orden a traves de un fichero .sh, igual que execute_mssql_cmd,
#--- y devuelve la lista de argumentos tal y como los recibio el programa.
sub ejecuta {
my ($orden) = @_;
   open(my $f,'>',"$DIR/c.sh") or die $!;
   print $f "#!/bin/bash\n".$orden."\n";
   close($f);
   #--- Se lee TODA la salida de una vez: un valor puede llevar saltos de
   #--- linea, asi que trocear por lineas lo partiria.
   my $out = `bash $DIR/c.sh 2>&1`;
   my @arg;
   while ($out =~ /^arg\[\d+\]=\[(.*?)\]\n/gms) { push(@arg,$1); }
   return @arg;
}

#--- Valores hostiles. Cada uno ataca una capa distinta.
my @HOSTIL = (
   '$clave',              # expansion de variable
   q{a'b},                # cierra el entrecomillado fuerte
   'a"b',                 # cierra el entrecomillado debil
   '`id` x',              # sustitucion de orden, forma antigua
   '$(whoami)',           # sustitucion de orden, forma moderna
   'C:\temp$x!',          # ruta windows: barra invertida + $ + !
   '100%$(whoami)',       # % (rompe sprintf) + sustitucion
   'p|q;r&s',             # tuberia, separador y segundo plano
   "con espacio",         # troceo por espacios
   "tab\there",           # troceo por tabulador
   "salto\nlinea",        # troceo por salto de linea
   '--peligro',           # parece una opcion
);

#===============================================================================
# 1. Una capa: el valor llega literal
#===============================================================================
foreach my $v (@HOSTIL) {
   my @a = ejecuta(cmd("$DIR/ver",'-U','usuario','-P',$v,'-Q','SELECT 1'));
   is(scalar(@a), 6,  'una capa: numero de argumentos');
   is($a[3], $v,      'una capa: el valor llega literal');
}

#===============================================================================
# 2. Dos capas: docker run ... sh -c '<orden>'
#===============================================================================
foreach my $v (@HOSTIL) {
   my $int = cmd("$DIR/ver",'-U','usuario','-P',$v,'-Q','SELECT 1');
   my @a   = ejecuta(cmd('sh','-c',$int));
   is(scalar(@a), 6, 'dos capas: numero de argumentos');
   is($a[3], $v,     'dos capas: el valor llega literal');
}

#===============================================================================
# 3. Tres capas: por si alguna vez hace falta anidar una vez mas
#===============================================================================
{
   my $v   = q{a'b"c$d `e` %f};
   my $i1  = cmd("$DIR/ver",'-P',$v);
   my $i2  = cmd('sh','-c',$i1);
   my @a   = ejecuta(cmd('sh','-c',$i2));
   is($a[1], $v, 'tres capas: el valor llega literal');
}

#===============================================================================
# 4. El dato de runtime dentro del SQL no puede romper el shell
#===============================================================================
{
   my $numserie = q{X"; rm -rf ZONA_PROHIBIDA; echo "};
   my $sql = "SELECT [NUMFAC] FROM T WHERE NUMSERIE='$numserie' AND Z IN (1,2)";
   my $int = cmd("$DIR/ver",'-Q',$sql);
   my @a   = ejecuta(cmd('sh','-c',$int));
   is($a[1], $sql, 'inyeccion en SQL: viaja como texto');
   ok($a[1] =~ /rm -rf ZONA_PROHIBIDA/, 'inyeccion en SQL: llega entera, sin ejecutarse');
}

#===============================================================================
# 5. Vacio y undef producen un argumento vacio, no su ausencia
#===============================================================================
{
   my @a = ejecuta(cmd("$DIR/ver",'-P','','-U',undef,'-d','AREAS'));
   is(scalar(@a), 6, 'vacio/undef: no desaparece ningun argumento');
   is($a[1], '',     'cadena vacia -> argumento vacio');
   is($a[3], '',     'undef -> argumento vacio');
   is($a[5], 'AREAS','el resto de la linea no se desplaza');
}

#===============================================================================
# 6. Legibilidad: lo inerte no se entrecomilla
#===============================================================================
is(sh('-C'),            '-C',            'una opcion no lleva comillas');
is(sh('192.168.1.1'),   '192.168.1.1',   'una ip no lleva comillas');
is(sh('AREAS'),         'AREAS',         'un identificador no lleva comillas');
is(sh('a/b_c-d.e'),     'a/b_c-d.e',     'una ruta simple no lleva comillas');
like(sh('con espacio'), qr/^'.*'$/,      'un espacio si obliga a entrecomillar');

#===============================================================================
# 7. Invocacion como metodo de clase
#===============================================================================
is(Crawler::Shell->sh(q{a'b}), sh(q{a'b}), 'sh como metodo de clase');
is(Crawler::Shell->cmd('a','b'), cmd('a','b'), 'cmd como metodo de clase');

#===============================================================================
# 8. mask
#===============================================================================
{
   my $pwd = q{a'b$c};
   my $orden = cmd('sqlcmd','-U','usuario','-P',$pwd,'-Q','SELECT 1');
   my $m = mask($orden,$pwd);
   ok($m !~ /\Q$pwd\E/,      'mask: el valor crudo desaparece');
   ok($m !~ /\Qsh($pwd)\E/,  'mask: la forma entrecomillada desaparece');
   like($m, qr/-P \*+/,      'mask: queda el asterisco en su sitio');
   like($m, qr/usuario/,     'mask: no toca lo que no se le pide');
   is(mask(undef,$pwd), '',  'mask: undef -> cadena vacia');
   is(mask('ab','ab'), 'ab', 'mask: ignora valores de menos de 3 caracteres');
}

done_testing();
