#!/usr/bin/perl
# =============================================================================
# cnm_fix_crosswalk_roleids.pl — corrige role_id del crosswalk desincronizados
# con el maestro (normalización .pais->_pais + errata eesbase->essbase + overrides).
# Corrige SOLO la columna role_id (por cabecera). NO toca alternativas ni otras.
# Mapa EXPLÍCITO (no regex ciega): así NO rompe svc.vtom.pt (que mantiene el punto).
# Dry-run por defecto; --commit escribe (backup .bak). Idempotente.
#   perl cnm_fix_crosswalk_roleids.pl --in cw.csv [--out cw_fixed.csv] [--commit]
# =============================================================================
use strict; use warnings;
use Getopt::Long; use Text::CSV;
my %o; GetOptions(\%o,'in=s','out=s','commit') or die;
$o{in} or die "Falta --in <crosswalk.csv>\n";
my $DRY=!$o{commit};

# correcciones por role_id EXACTO (izq roto -> der correcto en el maestro)
my %fix = (
  'app.eesbase_hyperion' => 'app.essbase_hyperion',
  'svc.rds.mx'           => 'svc.rds_mx',
  'app.icg.pt'           => 'app.icg_pt',
  'app.icg.mx'           => 'app.icg_mx',
  'app.fdk.us'           => 'app.fdk_us',
  'app.fdk.de'           => 'app.fdk_de',
  'app.thetys.us'        => 'app.thetys_us',
  'app.diapason.us'      => 'app.diapason_us',
  'svc.nas.fr'           => 'svc.nas_fr',
  'app.uman.pt'          => 'app.uman_pt',
  'app.wepex.us'         => 'app.wepex_us',
  'app.muneris.de'       => 'app.muneris_de',
  'app.sap_r3.fr'        => 'app.sap_r3_fr',
);
# overrides por col1_value (decisión del cliente; prevalecen sobre el mapa)
my %override = (
  'CUBOS RDS'       => 'svc.rds_areas2_com',
  'ICG PT/ES'       => 'app.icg',
  'ICG ESP Hoteles' => 'app.icg',
);

my $sep = ($o{in}=~/\.tsv$/)?"\t":";";
my $csv=Text::CSV->new({binary=>1,sep_char=>$sep,auto_diag=>1,eol=>"\n"});
open(my $fh,'<:encoding(latin1)',$o{in}) or die "No abro $o{in}: $!\n";
my $h=$csv->getline($fh); $h->[0]=~s/^\x{feff}// if @$h;
my %ix; $ix{lc $h->[$_]}=$_ for 0..$#$h;
my $ck = defined $ix{'col1_value'} ? $ix{'col1_value'} : $ix{'valor'};
my $rk = defined $ix{'role_id'} ? $ix{'role_id'} : $ix{'role_id_propuesto'};
my $vk = defined $ix{'validado_cliente'} ? $ix{'validado_cliente'} : $ix{'validado'};
defined $ck && defined $rk or die "No encuentro col1_value/role_id en la cabecera\n";

my $out=$o{out}||($o{in}=~s/\.csv$/_fixed.csv/r);
my @rows=($h); my (@changes,$n_ok_fixed,$n_total);
while (my $r=$csv->getline($fh)) {
  next unless grep { defined && /\S/ } @$r;
  $n_total++;
  my $col1=$r->[$ck]//''; $col1=~s/^\s+|\s+$//g;
  my $rid =$r->[$rk]//''; $rid =~s/^\s+|\s+$//g;
  my $vld = defined $vk ? uc($r->[$vk]//'') : 'OK'; $vld=~s/^\s+|\s+$//g;
  my $new;
  if (exists $override{$col1})      { $new=$override{$col1}; }
  elsif (exists $fix{$rid})         { $new=$fix{$rid}; }
  if (defined $new && $new ne $rid) {
    push @changes, sprintf("  [%s] %-18s %-22s -> %s", $vld, "\"$col1\"", $rid, $new);
    $r->[$rk]=$new;
    $n_ok_fixed++ if $vld eq 'OK';
  }
  push @rows,$r;
}
close($fh);

printf "Filas leídas: %d | correcciones: %d (de ellas en filas OK: %d)\n",
       $n_total, scalar @changes, $n_ok_fixed;
print "$_\n" for @changes;

if ($DRY){ print "\nDRY-RUN: nada escrito. Revisa y reejecuta con --commit.\n"; exit 0; }
# backup + escribir
if (-e $out){ } # noop
rename($o{in}, $o{in}.'.bak') if $out eq $o{in};
open(my $w,'>:encoding(latin1)',$out) or die "No escribo $out: $!\n";
$csv->print($w,$_) for @rows;
close($w);
print "\nESCRITO: $out",($out eq $o{in}?" (backup en $o{in}.bak)":""),"\n";
