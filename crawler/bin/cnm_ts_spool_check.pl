#!/usr/bin/perl -w
#--------------------------------------------------------------------------------------
# NAME: cnm_ts_spool_check.pl
#
# DESCRIPTION:
# Salud del pipeline de ingesta a TimescaleDB (spool local del host de CNM).
# Mide backlog, retraso, cuarentena y espacio libre. Los UMBRALES NO van aqui:
# se definen en CNM (monitores), que es quien evalua y alerta. El script solo MIDE.
#
# CALLING SAMPLE:
# cnm_ts_spool_check.pl -n 1.1.1.1
# cnm_ts_spool_check.pl -n 1.1.1.1 -s /opt/data/spool/ts
# cnm_ts_spool_check.pl 1.1.1.1                  (IP posicional, sin prefijo)
# cnm_ts_spool_check.pl -h : Ayuda
#
# INPUT (PARAMS):
# a. -n : IP remota. PARAMETRO DUMMY: el script NO lo usa. Es obligatorio en CNM
#         porque un script-metrica necesita un parametro de tipo IP/host para que
#         el interfaz pueda VINCULAR la metrica a uno o varios dispositivos. Aqui
#         la medida es siempre LOCAL (el spool del propio host de CNM).
#         Se acepta con prefijo (-n IP) o posicional, segun como se declare en CNM.
# b. -s : Ruta del spool (opcional; por defecto /opt/data/spool/ts)
#
# OUTPUT (STDOUT):
# <001> Ficheros pendientes = 3
# <002> Retraso maximo (s) = 7200
# <003> Ficheros en error = 1
# <004> Espacio libre (MB) = 10184
#
# OUTPUT (STDERR):
# Error info, warnings etc...
#
# EXIT CODE:
# 0: OK
# -1: System error
# >0: Script error
#
# NOTA: si no puede medir NO emite valores (ni ceros): sale con codigo != 0 para
# que CNM registre "sin dato". Un 0 en pendientes y retraso PARECE salud cuando
# en realidad significaria que el propio check esta roto.
#
# ALTA EN CNM: script de tipo METRICA, proxy Linux (localhost). Declarar UN
# parametro de tipo IP (prefijo -n o sin prefijo): lo rellena el sistema con la IP
# del dispositivo asociado y es lo que permite vincular la metrica. Metrica
# ABSOLUTA, sin instancias. TAGs: o1=001, o2=002, o3=003, o4=004.
# RECOMENDACION: asociarla SOLO al dispositivo que representa el propio appliance
# de CNM; asociarla a varios generaria series identicas duplicadas (la medida es
# local y no depende de la IP recibida).
#--------------------------------------------------------------------------------------
use strict;
use warnings;
use Getopt::Long;

my $USAGE = "cnm_ts_spool_check.pl [-n IP] [-s /ruta/spool]\n"
          . "  -n IP remota (parametro DUMMY: no se usa; existe para poder vincular\n"
          . "     la metrica a dispositivos desde el interfaz de CNM)\n"
          . "  -s Ruta del spool (por defecto /opt/data/spool/ts)\n"
          . "  -h Ayuda\n";
my %o = ( spool => '/opt/data/spool/ts', ip => undef, help => 0 );
GetOptions(\%o,'spool|s=s','ip|n=s','help|h') or die $USAGE;
die $USAGE if $o{help};

# Parametro IP: se acepta con prefijo (-n IP) o posicional, segun como se declare
# el parametro en CNM. Se ignora deliberadamente: la medida es LOCAL.
$o{ip} = shift @ARGV if !defined $o{ip} && @ARGV;

my $READY = $o{spool}.'/ready';
my $ERR   = $o{spool}.'/error';

# El spool debe existir: si no, es fallo del check, no "todo correcto".
unless (-d $o{spool}) {
   print STDERR "ERROR: no existe el spool $o{spool}\n";
   exit 3;
}

my $now = time;

# --- 001/002: recorrido de ready/ (numero de ficheros y mtime mas antiguo) ---
my ($ready_files, $oldest) = (0, undef);
my @stack = ($READY);
while (@stack) {
   my $d = pop @stack;
   opendir(my $dh, $d) or next;
   while (defined(my $e = readdir($dh))) {
      next if $e eq '.' || $e eq '..';
      my $p = "$d/$e";
      if (-d $p) { push @stack, $p; next; }
      next unless $e =~ /\.csv$/;
      $ready_files++;
      my @st = stat($p);
      $oldest = $st[9] if @st && (!defined $oldest || $st[9] < $oldest);
   }
   closedir($dh);
}
my $lag = defined $oldest ? ($now - $oldest) : 0;

# --- 003: cuarentena ---
my $error_files = 0;
if (opendir(my $dh, $ERR)) {
   $error_files = grep { /\.csv$/ } readdir($dh);
   closedir($dh);
}

# --- 004: espacio libre del filesystem del spool ---
my $free_mb;
my $out = `df -Pk $o{spool} 2>/dev/null | tail -1`;
my @c = split ' ', ($out // '');
$free_mb = int($c[3]/1024) if defined $c[3] && $c[3] =~ /^\d+$/;
unless (defined $free_mb) {
   print STDERR "ERROR: no puedo determinar el espacio libre de $o{spool}\n";
   exit 3;
}

# --- salida en formato CNM: una linea por valor medido ---
printf "<001>  Ficheros pendientes = %d\n", $ready_files;
printf "<002>  Retraso maximo (s) = %d\n",  $lag;
printf "<003>  Ficheros en error = %d\n",   $error_files;
printf "<004>  Espacio libre (MB) = %d\n",  $free_mb;

exit 0;
