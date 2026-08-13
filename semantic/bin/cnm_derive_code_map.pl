#!/usr/bin/perl
# =============================================================================
# cnm_derive_code_map.pl — deriva el mapa código KPI -> role_id desde el MAESTRO.
#
# El código KPI de una métrica es <proc>-<sp>-KPI####. Se resuelve a rol por
# JERARQUÍA con fallback (dos niveles):
#   1. <proc>-<sp>  (subproceso, EXACTO)  -> prioridad 1
#   2. <proc>       (proceso, FALLBACK)   -> si el SP no tiene línea propia
# Ambos niveles salen del orig_id de los roles del maestro. Este script LEE el
# maestro y produce un CSV de mapeo que el binding usa como insumo (dos pasadas).
#
# NO toca la BD. Solo lee el maestro y escribe el CSV.
#
#   perl cnm_derive_code_map.pl --maestro cnm_roles_maestro.csv
#        [--out cnm_code_role_map.csv] [--only-live]
#
# Salida CSV: code_prefix;level;role_id;role_type;orig_id_completo;multivalor
#   level = 'subprocess' (^[PWTIBD]\d+-SP\d+$)  |  'process' (^[PWTIBD]\d+$)
#
# Reglas / avisos:
#   - orig_id multivalor: separadores ',' y '/'. NO se asume que P## y W## compartan
#     número: cada prefijo listado apunta al mismo rol, tal cual esté escrito.
#   - colisión (mismo prefijo -> distintos roles): ERROR duro, aborta.
#   - SOSPECHOSOS: orig_id que PARECEN código pero están malformados (p.ej. 'P21-0004'
#     sin 'SP') se reportan como posibles ERRATAS, no entran al mapa.
# =============================================================================
use strict; use warnings;
use Getopt::Long;
use Text::CSV;

my %o=(out=>'cnm_code_role_map.csv', 'only-live'=>0);
GetOptions(\%o,'maestro=s','out=s','only-live') or die;
defined $o{maestro} or die "Falta --maestro <csv>\n";

my $csv=Text::CSV->new({binary=>1,sep_char=>';',auto_diag=>1});
open(my $fh,'<:encoding(latin1)',$o{maestro}) or die "No puedo abrir $o{maestro}: $!\n";
my $hdr=$csv->getline($fh);
$csv->column_names(map {my $h=$_; $h=~s/^\x{feff}//; $h=~s/^\s+|\s+$//g; $h} @$hdr);

my $re_sp   = qr/^[PWTIBD]\d+-SP\d+$/;   # subproceso
my $re_proc = qr/^[PWTIBD]\d+$/;         # proceso (fallback)
my $re_susp = qr/^[PWTIBD]\d+-\d/;       # parece código pero malformado (sin SP)

my (%map, %collision, @suspicious, @ignored, $n_roles);
while (my $row=$csv->getline_hr($fh)) {
  my $oid=defined $row->{orig_id}?$row->{orig_id}:''; $oid=~s/^\s+|\s+$//g;
  my $rid=defined $row->{role_id}?$row->{role_id}:''; $rid=~s/^\s+|\s+$//g;
  next unless $rid; $n_roles++;
  if ($o{'only-live'}) {
    my $st=$row->{status}//''; my $ac=uc($row->{accion}//'');
    next if $ac eq 'BORRAR';
    next if $st && $st ne 'active';
  }
  next unless length $oid;
  my @parts=grep {length} map {s/^\s+|\s+$//g; $_} split m{[,/]}, $oid;
  for my $p (@parts) {
    my $level;
    if    ($p =~ $re_sp)   { $level='subprocess'; }
    elsif ($p =~ $re_proc) { $level='process'; }
    elsif ($p =~ $re_susp) { push @suspicious, "$p -> $rid (¿errata? parece código sin 'SP')"; next; }
    else                   { push @ignored, "$p -> $rid"; next; }   # E##, ajenos
    if (exists $map{$p} && $map{$p}{role_id} ne $rid) {
      $collision{$p}{$map{$p}{role_id}}=1; $collision{$p}{$rid}=1;
    }
    $map{$p}={role_id=>$rid, level=>$level, role_type=>($row->{role_type}//''),
              orig=>$oid, multi=>(@parts>1?1:0)};
  }
}
close($fh);

if (%collision) {
  print STDERR "\nERROR: prefijos que apuntan a MÁS de un role_id (colisión):\n";
  print STDERR "  $_ -> ".join(", ",sort keys %{$collision{$_}})."\n" for sort keys %collision;
  die "Corrige el maestro (un prefijo no puede mapear a dos roles).\n";
}

open(my $out,'>:encoding(latin1)',$o{out}) or die "No puedo escribir $o{out}: $!\n";
print $out "code_prefix;level;role_id;role_type;orig_id_completo;multivalor\n";
for my $p (sort keys %map){
  my $m=$map{$p};
  print $out join(';',$p,$m->{level},$m->{role_id},$m->{role_type},$m->{orig},($m->{multi}?'sí':''))."\n";
}
close($out);

my ($nsp,$nproc)=(0,0); for (values %map){ $_->{level} eq 'subprocess' ? $nsp++ : $nproc++; }
printf "Maestro leído: %d roles.\n",$n_roles;
printf "Mapa código->rol generado en %s\n",$o{out};
printf "  nivel subproceso (<proc>-SP, prioridad 1): %d\n",$nsp;
printf "  nivel proceso    (<proc>, fallback)      : %d\n",$nproc;
my $mu=grep {$map{$_}{multi}} keys %map;
printf "  prefijos de orig_id multivalor (P/W u otros hermanos): %d\n",$mu;
if (@suspicious){
  printf "\n! POSIBLES ERRATAS en orig_id (%d) — revisar en el maestro:\n",scalar @suspicious;
  print  "    $_\n" for @suspicious;
}
printf "\nIgnorados (orig_id ajenos al código KPI, p.ej. E##): %d\n",scalar @ignored;
print  "  (muestra): ".join(" | ",@ignored[0..($#ignored<4?$#ignored:4)])."\n" if @ignored;
print  "\nResolución en binding (dos pasadas): dado X##-SP##-KPI####,\n";
print  "  1) busca X##-SP## (subprocess);  2) si no, X## (process);  3) si no, sin rol.\n";
