#!/usr/bin/perl
# =============================================================================
# cnm_mirror.pl — ESPEJO FACTUAL de metrics -> sem_instance + sem_metric_binding
#
# Trabajo A del binding (mirroring): mantiene la IDENTIDAD ESTABLE de cada métrica
# y su incarnación actual (idmetric/iid). NO decide roles (eso es cnm_binding.pl).
#
# Propiedades (patrón de producción del proyecto):
#   - DRY-RUN por defecto; escribe solo con --commit.
#   - ADITIVO y NO DESTRUCTIVO: nunca borra. Lo que desaparece de CNM se marca
#     'stale' (valid_to=now); el enriquecimiento de sem_instance se preserva.
#   - IDEMPOTENTE: reejecutar no duplica ni cambia nada si CNM no cambió.
#   - Usa CNMStableKey (misma lógica que el diagnóstico) para el stable_key.
#
#   perl cnm_mirror.pl --user U --pass P --db onm [--host H] [--rules F]
#        [--commit] [-v]
# =============================================================================
use strict; use warnings;
use FindBin; use lib $FindBin::Bin;
use DBI; use Getopt::Long;
use CNMStableKey;

my %o=(host=>'127.0.0.1', db=>'onm', rules=>'', commit=>0, v=>0);
GetOptions(\%o,'user=s','pass=s','db=s','host=s','rules=s','commit','v') or die;
defined $o{user} && defined $o{pass} or die "Faltan --user/--pass\n";
my $DRY = !$o{commit};

my $rf = CNMStableKey::find_rules_file($o{rules}) or die "No encuentro stable_key_rules.conf (usa --rules)\n";
my $sk = CNMStableKey->new(rules_file=>$rf);
print "Reglas stable_key: $rf (".$sk->n_rules." reglas)\n";
print "MODO: ", ($DRY?"DRY-RUN (no se escribe; usa --commit)":"COMMIT (se escribira)"), "\n";

my $dbh=DBI->connect("DBI:mysql:database=$o{db};host=$o{host}",$o{user},$o{pass},
       {RaiseError=>1,AutoCommit=>0,mysql_enable_utf8=>0}) or die DBI->errstr;

# ---- 0. catálogo de subtypes con concepto (gate de la FK) -------------------
my %concept_ok = map {$_->[0]=>1}
   @{$dbh->selectall_arrayref("SELECT subtype FROM sem_metric_concept")};
print "Subtypes con concepto en sem_metric_concept: ".scalar(keys %concept_ok)."\n";

# ---- 1. leer metrics activas de CNM ----------------------------------------
# identidad CNM de la incarnación: idmetric (PK sintetica en metrics? -> usamos
# id_metric). Traemos lo necesario para derivar y para el binding.
my $mq=$dbh->prepare(
  "SELECT id_metric, id_dev, subtype, COALESCE(iid,'ALL') iid, label
     FROM metrics WHERE COALESCE(status,0) IN (0,2)");
$mq->execute;

my %live_idmetric;      # idmetric -> {iddev,subtype,iid,stable_key}
my %need_instance;      # "iddev|subtype|stable_key" -> {iddev,subtype,stable_key,via}
my %stat;               # contadores
my @no_concept;         # subtypes sin concepto (gate FK)
while (my ($idm,$iddev,$subtype,$iid,$label)=$mq->fetchrow_array) {
  $stat{metrics_leidas}++;
  my ($via,$skey)=$sk->derive($subtype,$iid,$label);
  $stat{"via_$via"}++;
  unless ($concept_ok{$subtype}) {
    push @no_concept,$subtype if @no_concept<50;
    $stat{sin_concepto}++;
    next;   # no se puede crear instancia sin concepto (FK) -> saltar
  }
  my $ikey="$iddev|$subtype|$skey";
  $need_instance{$ikey} //= {iddev=>$iddev,subtype=>$subtype,stable_key=>$skey,via=>$via};
  $live_idmetric{$idm}={iddev=>$iddev,subtype=>$subtype,iid=>$iid,ikey=>$ikey};
}
$stat{instancias_necesarias}=scalar keys %need_instance;
$stat{idmetrics_vivos}=scalar keys %live_idmetric;

# ---- 2. estado actual de sem_instance / sem_metric_binding ------------------
my %inst_id;   # "iddev|subtype|stable_key" -> instance_id
{
  my $q=$dbh->prepare("SELECT instance_id,iddev,subtype,stable_key FROM sem_instance");
  $q->execute;
  while (my ($id,$iddev,$sub,$sk2)=$q->fetchrow_array){ $inst_id{"$iddev|$sub|$sk2"}=$id; }
}
my %bind_now;  # idmetric -> {instance_id,iid,status}
{
  my $q=$dbh->prepare("SELECT idmetric,instance_id,iid,status FROM sem_metric_binding");
  $q->execute;
  while (my ($idm,$iid2,$iidv,$st)=$q->fetchrow_array){ $bind_now{$idm}={instance_id=>$iid2,iid=>$iidv,status=>$st}; }
}

# ---- 3. plan de cambios -----------------------------------------------------
# 3a. instancias a crear (las necesarias que no existen)
my @inst_create = grep { !$inst_id{$_} } keys %need_instance;
# 3b. instancias a reactivar (existían stale y vuelven a tener incarnación) -> se
#     resuelve al reactivar por binding; marcamos valid_to=NULL si estaba fijado.
# 3c. bindings a crear/actualizar
my (@bind_ins,@bind_upd);
for my $idm (keys %live_idmetric){
  my $L=$live_idmetric{$idm};
  # instance_id: si ya existe úsalo; si se va a crear, se resuelve en commit
  my $cur=$bind_now{$idm};
  if (!$cur){ push @bind_ins,$idm; }
  else {
    # actualizar si cambió iid o estaba stale
    push @bind_upd,$idm if $cur->{iid} ne $L->{iid} || $cur->{status} ne 'active';
  }
}
# 3d. bindings a marcar stale (están en la tabla pero ya no en metrics vivas)
my @bind_stale = grep { !$live_idmetric{$_} && $bind_now{$_}{status} ne 'stale' } keys %bind_now;

$stat{inst_a_crear}=scalar @inst_create;
$stat{bind_a_crear}=scalar @bind_ins;
$stat{bind_a_actualizar}=scalar @bind_upd;
$stat{bind_a_stale}=scalar @bind_stale;

# ---- 4. informe -------------------------------------------------------------
print "\n=== RESUMEN ===\n";
printf "  métricas leídas de CNM        : %d\n",$stat{metrics_leidas}//0;
printf "  idmetrics vivos               : %d\n",$stat{idmetrics_vivos}//0;
printf "  instancias estables necesarias: %d\n",$stat{instancias_necesarias}//0;
print  "  ---- derivación stable_key ----\n";
for my $v (qw(ALL iid_stable parsed_label iid_weak iid_fallback)){
  printf "    %-14s %d\n",$v,$stat{"via_$v"} if $stat{"via_$v"};
}
if ($stat{sin_concepto}){
  printf "  ! métricas SALTADAS (subtype sin concepto en sem_metric_concept): %d\n",$stat{sin_concepto};
  my %u; $u{$_}=1 for @no_concept;
  print  "    subtypes: ".join(", ",sort keys %u)."\n";
  print  "    -> dar de alta esos subtypes en sem_metric_concept antes de bindearlos\n";
}
print  "  ---- plan de escritura ----\n";
printf "    instancias a crear          : %d\n",$stat{inst_a_crear};
printf "    bindings a crear            : %d\n",$stat{bind_a_crear};
printf "    bindings a actualizar       : %d\n",$stat{bind_a_actualizar};
printf "    bindings a marcar stale     : %d\n",$stat{bind_a_stale};

# ---- 5. ejecución (solo --commit) ------------------------------------------
if ($DRY){
  print "\nDRY-RUN: nada escrito. Revisa el plan y reejecuta con --commit.\n";
  $dbh->rollback; $dbh->disconnect; exit 0;
}

eval {
  # 5a. crear instancias nuevas
  my $ins_inst=$dbh->prepare(
    "INSERT INTO sem_instance (iddev,subtype,stable_key,instance_info_source)
     VALUES (?,?,?,?)
     ON DUPLICATE KEY UPDATE valid_to=NULL");   # reactiva si estaba stale
  for my $k (@inst_create){
    my $n=$need_instance{$k};
    my $src = $n->{via} eq 'parsed_label' ? 'parsed_label'
            : $n->{via} eq 'iid_stable'   ? 'iid'
            : $n->{via} eq 'iid_weak'     ? 'iid_weak'
            : 'none';
    $ins_inst->execute($n->{iddev},$n->{subtype},$n->{stable_key},$src);
  }
  # refrescar mapa de instance_id (incluye las recién creadas)
  %inst_id=();
  my $q=$dbh->prepare("SELECT instance_id,iddev,subtype,stable_key FROM sem_instance");
  $q->execute;
  while (my ($id,$iddev,$sub,$sk2)=$q->fetchrow_array){ $inst_id{"$iddev|$sub|$sk2"}=$id; }

  # 5b. reactivar instancias que tenían valid_to y vuelven a estar vivas
  my $react=$dbh->prepare("UPDATE sem_instance SET valid_to=NULL WHERE instance_id=? AND valid_to IS NOT NULL");
  my %live_inst; $live_inst{$inst_id{$live_idmetric{$_}{ikey}}}=1 for keys %live_idmetric;
  $react->execute($_) for keys %live_inst;

  # 5c. crear/actualizar bindings
  my $ins_bind=$dbh->prepare(
    "INSERT INTO sem_metric_binding (idmetric,instance_id,iid,status)
     VALUES (?,?,?,'active')
     ON DUPLICATE KEY UPDATE instance_id=VALUES(instance_id), iid=VALUES(iid),
                             status='active', valid_to=NULL");
  for my $idm (@bind_ins,@bind_upd){
    my $L=$live_idmetric{$idm};
    my $iid_id=$inst_id{$L->{ikey}} or next;
    $ins_bind->execute($idm,$iid_id,$L->{iid});
  }

  # 5d. marcar stale lo desaparecido (NO borrar)
  my $mk_stale=$dbh->prepare("UPDATE sem_metric_binding SET status='stale', valid_to=NOW() WHERE idmetric=?");
  $mk_stale->execute($_) for @bind_stale;

  # 5e. instancias sin ninguna incarnación viva -> valid_to=NOW() (kept, not deleted)
  $dbh->do(
    "UPDATE sem_instance i
        LEFT JOIN sem_metric_binding b
          ON b.instance_id=i.instance_id AND b.status='active'
        SET i.valid_to=NOW()
      WHERE b.idmetric IS NULL AND i.valid_to IS NULL");

  $dbh->commit;
  print "\nCOMMIT OK. instancias creadas=$stat{inst_a_crear}, bindings nuevos=$stat{bind_a_crear}, ".
        "actualizados=$stat{bind_a_actualizar}, marcados stale=$stat{bind_a_stale}\n";
  1;
} or do {
  my $e=$@||'error'; $dbh->rollback;
  die "\nERROR (rollback, nada escrito): $e\n";
};
$dbh->disconnect;
