#!/usr/bin/perl
# =============================================================================
# cnm_stable_key_diag.pl  —  DIAGNÓSTICO (solo lectura) del stable_key.
# Usa el módulo CNMStableKey (lógica compartida con cnm_mirror.pl). Las reglas
# son externas (stable_key_rules.conf). No escribe nada.
#
#   perl cnm_stable_key_diag.pl --user U --pass P --db onm [--host H]
#         [--rules FICHERO] [--subtype X] [--sample 15]
# =============================================================================
use strict; use warnings;
use FindBin; use lib $FindBin::Bin;
use DBI; use Getopt::Long;
use CNMStableKey;

my %o=(host=>'127.0.0.1', db=>'onm', sample=>15, rules=>'');
GetOptions(\%o,'user=s','pass=s','db=s','host=s','subtype=s','sample=i','rules=s') or die;
defined $o{user} && defined $o{pass} or die "Faltan --user/--pass\n";

my $rf = CNMStableKey::find_rules_file($o{rules}) or die "No encuentro stable_key_rules.conf (usa --rules)\n";
my $sk = CNMStableKey->new(rules_file=>$rf);
warn "Reglas cargadas de $rf: ".$sk->n_rules."\n";

my $dbh=DBI->connect("DBI:mysql:database=$o{db};host=$o{host}",$o{user},$o{pass},
       {RaiseError=>1,AutoCommit=>1,mysql_enable_utf8=>0}) or die DBI->errstr;
my $where="COALESCE(status,0) IN (0,2)";
$where.=" AND subtype=".$dbh->quote($o{subtype}) if $o{subtype};
my $q=$dbh->prepare("SELECT subtype, COALESCE(iid,'ALL') iid, label FROM metrics WHERE $where");
$q->execute;

my (%by_via,%by_via_sub,@unresolved,$total);
while (my ($subtype,$iid,$label)=$q->fetchrow_array) {
  $total++;
  my ($via,$key)=$sk->derive($subtype,$iid,$label);
  $by_via{$via}++; $by_via_sub{$via}{$subtype}++;
  push @unresolved,[$subtype,$iid,defined $label?$label:'']
    if $via eq 'iid_fallback' && @unresolved < $o{sample};
}

printf "\n=== DIAGNÓSTICO stable_key sobre %d métricas activas ===\n\n",$total;
printf "%-16s %8s  %6s   %s\n","via","métricas","%","subtypes";
for my $via (qw(ALL iid_stable parsed_label iid_weak iid_fallback)) {
  next unless $by_via{$via};
  printf "%-16s %8d  %5.1f%%   %d\n",$via,$by_via{$via},100*$by_via{$via}/$total,scalar keys %{$by_via_sub{$via}};
}
my $rob=($by_via{ALL}//0)+($by_via{iid_stable}//0)+($by_via{parsed_label}//0);
printf "\nIdentidad ROBUSTA: %d (%.1f%%)\n",$rob,($total?100*$rob/$total:0);
printf "Identidad DÉBIL declarada (iid_weak): %d\n",$by_via{iid_weak}//0;
printf "SIN resolver (iid_fallback): %d\n",$by_via{iid_fallback}//0;
if (@unresolved){
  print "\n--- muestra NO resueltos (añadir su regla al .conf) ---\n";
  printf "  %-26s %-8s %s\n",$_->[0],$_->[1],substr($_->[2],0,66) for @unresolved;
}
if ($by_via{iid_fallback}){
  print "\n--- fallback por subtype ---\n";
  for my $s (sort {$by_via_sub{iid_fallback}{$b}<=>$by_via_sub{iid_fallback}{$a}} keys %{$by_via_sub{iid_fallback}}){
    printf "  %-28s %d\n",$s,$by_via_sub{iid_fallback}{$s};
  }
}
$dbh->disconnect;
