#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# Fichero: cpan-install.pl
#
# Instalador / verificador de los modulos PERL necesarios para CNM.
# Lee la lista de /opt/cnm/os/debian13/cpan-modules.txt (formato: "Modulo<ws>version").
#
# Modos:
#   (sin -i)  CHECK : informa de que esta instalado y compara con lo disponible en CPAN.
#   -i        INSTALL: instala lo que falte (cpanm como autoridad e idempotente).
#   -p        PIN    : (solo con -i) fija la version exacta indicada en el fichero.
#   -h        Ayuda.
#
# Notas de diseno:
#   - La deteccion "ya instalado?" se hace cargando el modulo (require en proceso hijo),
#     NO con ExtUtils::Installed->validate(), que comprueba .packlist y da falsos
#     negativos en modulos del core / dual-life / instalados por apt (libxxx-perl).
#   - En modo install NO se usa -f: asi cpanm salta limpiamente lo ya satisfecho y los
#     fallos de compilacion afloran en el codigo de retorno en vez de quedar ocultos.
#   - Se acumulan los modulos que fallan y se imprime un resumen + exit code != 0.
#   - Los logs van a un directorio persistente (no /tmp, que en Debian 13 es tmpfs).
#-------------------------------------------------------------------------------------------
use lib "/opt/cnm/crawler/bin/support";
use strict;
use warnings;
use Getopt::Std;
use File::Path qw(make_path);

#-------------------------------------------------------------------------------------------
my %opts=();
getopts("iph", \%opts);

if ($opts{h}) { die usage(); }

my $INSTALL = $opts{i} ? 1 : 0;
my $PIN     = $opts{p} ? 1 : 0;

#-------------------------------------------------------------------------------------------
my $MODULES_FILE = '/opt/cnm/os/debian13/cpan-modules.txt';
my $LOGDIR       = '/var/log/cnm/cpan';

if ($INSTALL) {
   make_path($LOGDIR) unless -d $LOGDIR;
}

#-------------------------------------------------------------------------------------------
open my $fh, '<', $MODULES_FILE or die "No se pudo abrir $MODULES_FILE: $!\n";

my @failed;        # modulos que cpanm no consiguio instalar
my %seen_hash;     # para detectar duplicados en la lista

print_legend();

while (my $linea = <$fh>) {
   chomp $linea;
   $linea =~ s/^\s+//;                     # quita espacios iniciales
   next if $linea =~ /^\s*$/ || $linea =~ /^#/;   # vacias o comentario

   my ($modulo, $version) = split /\s+/, $linea, 2;
   next unless defined $modulo && length $modulo;
   $version = defined $version ? trim($version) : '';

   # Aviso de duplicados (inofensivos para cpanm, pero ensucian el resumen)
   if ($seen_hash{$modulo}++) {
      report('DUP', $modulo, 'repetido en la lista, se omite');
      next;
   }

   if ($INSTALL) { install_module($modulo, $version); }
   else          { check_module($modulo, $version);   }
}
close $fh;

#-------------------------------------------------------------------------------------------
# Resumen final (solo install)
#-------------------------------------------------------------------------------------------
if ($INSTALL) {
   print "\n", "=" x 70, "\n";
   if (@failed) {
      print scalar(@failed)." modulo(s) FALLARON:\n";
      print "  - $_\n" for @failed;
      print "Revisa los logs en $LOGDIR/<modulo>.log\n";
      exit 1;
   }
   else {
      print "Todos los modulos instalados/verificados correctamente.\n";
      exit 0;
   }
}

#-------------------------------------------------------------------------------------------
# Instala un modulo dejando que cpanm decida (sin -f). Acumula fallos.
#-------------------------------------------------------------------------------------------
sub install_module {
   my ($modulo, $version) = @_;

   my $target = $modulo;
   if ($PIN && length $version && $version ne '0') {
      # Pin exacto a la version del fichero. OJO: versiones multi-punto (p.ej. 2.4.0)
      # pueden no resolver; validar caso a caso si activas -p.
      $target = "$modulo~==$version";
   }

   my $log = "$LOGDIR/$modulo.log";
   my $rc  = system(qq{cpanm --notest "$target" > "$log" 2>&1});

   if ($rc != 0) {
      push @failed, $modulo;
      report('FAIL', $modulo, "fallo al instalar (ver $log)");
      return;
   }

   # Instalacion OK: intentamos reportar la version realmente instalada.
   my $vinst = installed_version($modulo);
   if (!defined $vinst) {
      # Nombre de distribucion (p.ej. MailTools) o no cargable por su nombre:
      # cpanm dijo OK, pero no podemos verificar version cargando por nombre.
      report('OK', $modulo, 'instalado (version no verificable por nombre)');
      return;
   }

   my $ref  = (length $version && $version ne '0') ? $version : '-';
   my $mism = ($ref ne '-' && $ref ne $vinst);
   report($mism ? 'VER' : 'OK', $modulo, "instalada=$vinst   fichero=$ref");
}

#-------------------------------------------------------------------------------------------
# Comprueba (sin instalar) si el modulo esta y compara con lo disponible en CPAN.
#-------------------------------------------------------------------------------------------
sub check_module {
   my ($modulo, $version) = @_;

   my $vinst = installed_version($modulo);
   if (!defined $vinst) {
      report('UNK', $modulo, 'no instalado');
      return;
   }

   # Version disponible en CPAN (informativo). cpanm --info hace red: en listados
   # grandes es lento; si no interesa, se puede comentar este bloque.
   my $cpan_version = '';
   my $info = `cpanm --info $modulo 2>/dev/null`;
   chomp $info;
   if    ($info =~ /^\S+\-(\S+)\.tar\.gz$/) { $cpan_version = $1; }
   elsif ($info =~ /^\S+\-(\S+)\.tgz$/)     { $cpan_version = $1; }

   my $ref  = ($cpan_version ne '') ? $cpan_version : '-';
   my $mism = ($ref ne '-' && $ref ne $vinst);
   report($mism ? 'VER' : 'OK', $modulo, "instalada=$vinst   cpan=$ref");
}

#-------------------------------------------------------------------------------------------
# Devuelve la version instalada del modulo, o undef si no se puede cargar por su nombre.
# Usa un proceso hijo que HEREDA el @INC del padre (-I), de modo que ve los mismos modulos
# que vera CNM en ejecucion (incluido el "use lib" y cualquier prefijo a medida). El require
# va dentro de un eval para no volcar "Can't locate ..." a la terminal y dar un exit limpio.
#-------------------------------------------------------------------------------------------
sub installed_version {
   my ($modulo) = @_;

   my @inc  = map { "-I$_" } @INC;     # misma visibilidad de modulos que este script
   my $code = "\$SIG{__WARN__} = sub {}; "           # silencia avisos del modulo (p.ej. smartmatch)
            . "eval { require $modulo; 1 } or exit 1; "
            . "my \$v = eval { $modulo->VERSION }; "
            . "print defined \$v ? \$v : 'N/A';";

   my $out = '';
   if (open(my $p, '-|', $^X, @inc, '-e', $code)) {
      local $/;
      $out = <$p>;
      close $p;            # al cerrar el pipe, $? recoge el exit del hijo
   }
   return undef if ($? >> 8) != 0;     # require fallo -> no instalado / no cargable
   $out = 'N/A' unless defined $out && length $out;
   return $out;
}

#-------------------------------------------------------------------------------------------
sub trim {
   my ($s) = @_;
   $s =~ s/^\s+//;
   $s =~ s/\s+$//;
   return $s;
}

#-------------------------------------------------------------------------------------------
# Salida consistente:   [TAG ] modulo                              detalle
#-------------------------------------------------------------------------------------------
sub report {
   my ($tag, $modulo, $detail) = @_;
   printf "[%-4s] %-34s %s\n", $tag, $modulo, (defined $detail ? $detail : '');
}

sub print_legend {
   print "Leyenda: OK=correcto  VER=version distinta  DUP=duplicado  UNK=no instalado  FAIL=fallo\n";
   print "         'instalada'=version en el sistema ; 'fichero'/'cpan'=version de referencia\n";
   print "-" x 78, "\n";
}

#-------------------------------------------------------------------------------------------
sub usage {
   my @fpth = split('/', $0, 10);
   my $me   = $fpth[$#fpth];
   return <<USAGE;
Instalador / verificador de modulos PERL para CNM

$me        : Modo CHECK (lista que esta instalado y compara con CPAN)
$me -i     : Modo INSTALL (instala lo que falte)
$me -i -p  : INSTALL fijando la version exacta del fichero (pin)
$me -h     : Ayuda

Lista de modulos: $MODULES_FILE
Logs (install):   $LOGDIR/<modulo>.log
USAGE
}
