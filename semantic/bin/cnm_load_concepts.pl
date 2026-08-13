#!/usr/bin/perl
# =============================================================================
# cnm_load_concepts.pl — carga sem_metric_concept desde reglas externas.
# Expande reglas por familia/exact a filas por subtype REAL presente en metrics
# y aún sin concepto. Resuelve la deuda de "métricas sin concepto" del mirror.
#
# Propiedades: DRY-RUN por defecto (--commit escribe), ADITIVO (no toca mapeos
# existentes), IDEMPOTENTE, valida FK contra sem_canonical_concept, NUNCA carga
# confidence=ai_suggested (gate de seguridad del modelo).
#
#   perl cnm_load_concepts.pl --user U --pass P --db onm [--host H]
#        [--rules concept_rules.conf] [--commit] [-v]
# =============================================================================
use strict; use warnings;
use DBI; use Getopt::Long;

my %o=(host=>'127.0.0.1', db=>'onm', rules=>'', commit=>0, v=>0);
GetOptions(\%o,'user=s','pass=s','db=s','host=s','rules=s','commit','v') or die;
defined $o{user} && defined $o{pass} or die "Faltan --user/--pass\n";
my $DRY=!$o{commit};

# --- localizar reglas ---
my @cand=($o{rules},'./concept_rules.conf','/opt/data/semantic/concept_rules.conf',
          './semantic/concept_rules.conf.example','./concept_rules.conf.example');
my $rf; for (@cand){ next unless $_; if (-r $_){ $rf=$_; last; } }
die "No encuentro concept_rules.conf (usa --rules)\n" unless $rf;

# --- cargar reglas ---
my @rules; my $ln=0;
open(my $fh,'<',$rf) or die "No puedo leer $rf: $!\n";
while (my $line=<$fh>){
  $ln++; $line=~s/\r?\n$//; $line=~s/\s*#.*$//;   # quita comentarios de fin de línea
  next if $line=~/^\s*$/;
  my @f=split /\|/,$line; for (@f){ s/^\s+|\s+$//g if defined }
  my ($match,$sel,$cid,$conf,$vs,$orig)=@f;
  die "regla inválida (línea $ln): faltan campos\n" unless defined $cid && length $cid;
  $match=~/^(family|exact)$/ or die "match inválido '$match' (línea $ln)\n";
  $conf ||= 'inherited'; $vs=defined $vs && length $vs ? $vs : '1.0'; $orig ||= 'custom';
  $conf=~/^(human_confirmed|ai_suggested|inherited)$/ or die "confidence inválido '$conf' (línea $ln)\n";
  die "GATE: no se permite ai_suggested en carga (línea $ln)\n" if $conf eq 'ai_suggested';
  $orig=~/^(standard|custom)$/ or die "origin inválido '$orig' (línea $ln)\n";
  $vs=~/^-?\d+(\.\d+)?$/ or die "value_scale no numérico '$vs' (línea $ln)\n";
  push @rules,{match=>$match,sel=>$sel,cid=>$cid,conf=>$conf,vs=>$vs,orig=>$orig,line=>$ln};
}
close($fh);
print "Reglas de concepto: $rf (".scalar(@rules)." activas)\n";
print "MODO: ",($DRY?"DRY-RUN (no escribe; usa --commit)":"COMMIT"),"\n";

my $dbh=DBI->connect("DBI:mysql:database=$o{db};host=$o{host}",$o{user},$o{pass},
       {RaiseError=>1,AutoCommit=>0,mysql_enable_utf8=>0}) or die DBI->errstr;

# --- validar canonical_id de las reglas contra el catálogo (FK) ---
my %concept_ok=map {$_->[0]=>1} @{$dbh->selectall_arrayref("SELECT canonical_id FROM sem_canonical_concept")};
my @bad=grep { !$concept_ok{$_->{cid}} } @rules;
if (@bad){
  print "\nERROR: reglas apuntan a canonical_id inexistente:\n";
  printf "  línea %d: %s\n",$_->{line},$_->{cid} for @bad;
  $dbh->rollback; $dbh->disconnect; die "Corrige las reglas antes de cargar.\n";
}

# --- subtypes de metrics aún sin concepto ---
my %mapped=map {$_->[0]=>1} @{$dbh->selectall_arrayref("SELECT subtype FROM sem_metric_concept")};
my %unmapped;   # subtype -> familia
{
  my $q=$dbh->prepare("SELECT DISTINCT subtype FROM metrics WHERE COALESCE(status,0) IN (0,2)");
  $q->execute;
  while (my ($s)=$q->fetchrow_array){
    next if $mapped{$s};
    (my $fam=$s)=~s/-.*$//;   # familia = antes del 1er '-'
    $unmapped{$s}=$fam;
  }
}
printf "Subtypes sin concepto en metrics: %d\n", scalar keys %unmapped;

# --- expandir reglas a filas por subtype real ---
my @plan;         # {subtype,cid,conf,vs,orig,rule_line}
my %claimed;      # subtype ya asignado por una regla (primera gana)
for my $r (@rules){
  for my $s (sort keys %unmapped){
    next if $claimed{$s};
    my $hit = $r->{match} eq 'exact'  ? ($s eq $r->{sel})
            : $r->{match} eq 'family' ? ($unmapped{$s} eq $r->{sel})
            : 0;
    next unless $hit;
    $claimed{$s}=1;
    push @plan,{subtype=>$s,cid=>$r->{cid},conf=>$r->{conf},vs=>$r->{vs},orig=>$r->{orig},line=>$r->{line}};
  }
}

# --- informe ---
my %by_cid; $by_cid{$_->{cid}}++ for @plan;
print "\n=== PLAN: ", scalar(@plan), " subtypes a mapear ===\n";
for my $cid (sort keys %by_cid){ printf "  %-32s <- %d subtypes\n",$cid,$by_cid{$cid}; }
my $sin = (scalar keys %unmapped) - scalar(@plan);
printf "\nSubtypes que quedan SIN concepto (ninguna regla los cubre): %d\n",$sin;
if ($o{v} && $sin){
  print "  (muestra):\n";
  my $n=0; for my $s (sort keys %unmapped){ next if $claimed{$s}; printf "    %s\n",$s; last if ++$n>=20; }
}

if ($DRY){ print "\nDRY-RUN: nada escrito. Revisa el plan y reejecuta con --commit.\n"; $dbh->rollback; $dbh->disconnect; exit 0; }

# --- commit ---
eval {
  my $ins=$dbh->prepare(
    "INSERT INTO sem_metric_concept (subtype,canonical_id,origin,confidence,source,value_scale)
     VALUES (?,?,?,?,'rules',?)
     ON DUPLICATE KEY UPDATE subtype=subtype");   # no pisa mapeos existentes
  my $n=0;
  for my $p (@plan){ $ins->execute($p->{subtype},$p->{cid},$p->{orig},$p->{conf},$p->{vs}); $n++; }
  $dbh->commit;
  print "\nCOMMIT OK. conceptos cargados=$n (subtypes ya mapeados se respetan)\n";
  print "Reejecuta cnm_mirror.pl para incorporar estas métricas al espejo.\n";
  1;
} or do { my $e=$@||'err'; $dbh->rollback; die "\nERROR (rollback): $e\n"; };
$dbh->disconnect;
