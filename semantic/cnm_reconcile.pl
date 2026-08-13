#!/usr/bin/perl
# =============================================================================
# cnm_reconcile.pl — MANTENIMIENTO: retira ataduras a rol obsoletas.
#
# Complementa al binding: el binding ATA (aditivo), el reconcile DESATA
# (destructivo). NUNCA en la misma pasada.
#
# CRITERIO ÚNICO (verificado con datos): retira la atadura a rol
# (sem_binding_role) de toda instancia CADUCADA (sem_instance.valid_to NOT NULL).
# NO mira status de dispositivo ni de métrica. La granularidad es fina (una
# instancia por interfaz/ítem), así que "instancia caducada" captura todos los
# casos de borrado real, incluido eliminar métricas sueltas de un equipo vivo.
#
# ESCALERA DE DESTRUCTIVIDAD:
#   VIVO --(mirror)--> STALE --(reconcile)--> RETIRED --(reconcile --purge)--> BORRADO
#   - retire (por defecto): marca status='retired', retired_at=NOW(). Reversible.
#   - purge (--purge): DELETE físico de lo retired desde hace > retención días.
#
# Propiedades: DRY-RUN por defecto (--commit actúa). NO destructivo en modo
# normal (marca retired, no borra). IDEMPOTENTE. SEPARADO del binding.
# human_confirmed se retira igual (decisión cliente), avisando cuántas.
# INMUNE a collation: carga en hashes Perl, compara en Perl, JOIN SQL solo por
# claves numéricas.
#
#   perl cnm_reconcile.pl --user U --pass P --db onm [--host H]
#        [--commit] [--purge] [--retention-days N] [-v]
# =============================================================================
use strict; use warnings;
use FindBin; use lib $FindBin::Bin;
use DBI; use Getopt::Long;

my %o=(host=>'127.0.0.1', db=>'onm', commit=>0, purge=>0,
       'retention-days'=>30, v=>0);
GetOptions(\%o,'user=s','pass=s','db=s','host=s',
           'commit','purge','retention-days=i','v') or die;
defined $o{user} && defined $o{pass} or die "Faltan --user/--pass\n";
my $DRY=!$o{commit};
my $RET=$o{'retention-days'};
$RET>=0 or die "--retention-days debe ser >= 0\n";

my $dbh=DBI->connect("DBI:mysql:database=$o{db};host=$o{host}",$o{user},$o{pass},
  {RaiseError=>1,AutoCommit=>0,mysql_enable_utf8=>1}) or die $DBI::errstr;

printf "MODO: %s%s\n", ($o{purge}?'PURGE':'RETIRE'),
                       ($DRY?' (DRY-RUN; usa --commit para actuar)':' (COMMIT)');

# ---------------------------------------------------------------------------
# Verificación de esquema: sem_binding_role debe tener status y retired_at.
# ---------------------------------------------------------------------------
my %cols = map { $_->[0]=>1 } @{ $dbh->selectall_arrayref(
  "SHOW COLUMNS FROM sem_binding_role") };
unless ($cols{status} && $cols{retired_at}) {
  die "ERROR: sem_binding_role no tiene columnas 'status'/'retired_at'.\n".
      "Ejecuta antes el ALTER (ver schema/cnm_reconcile_schema.sql):\n".
      "  ALTER TABLE sem_binding_role\n".
      "    ADD COLUMN status ENUM('active','retired') NOT NULL DEFAULT 'active',\n".
      "    ADD COLUMN retired_at DATETIME NULL;\n";
}

if ($o{purge}) { do_purge($dbh); }
else           { do_retire($dbh); }

# ===========================================================================
# MODO RETIRE
# ===========================================================================
sub do_retire {
  my ($dbh)=@_;

  # 1. instancias CADUCADAS -> hash (comparación en Perl, inmune a collation)
  my %muerta;
  my $qi=$dbh->prepare("SELECT instance_id FROM sem_instance WHERE valid_to IS NOT NULL");
  $qi->execute; while (my ($iid)=$qi->fetchrow_array){ $muerta{$iid}=1; }
  my $n_muertas=scalar keys %muerta;

  # 2. ataduras ACTIVAS cuya instancia está muerta = candidatas
  #    (cargamos todas las activas y filtramos en Perl)
  my @cand; my $n_conf=0;
  my $qb=$dbh->prepare(
    "SELECT instance_id, role_id, confidence FROM sem_binding_role WHERE status='active'");
  $qb->execute;
  while (my ($iid,$rid,$conf)=$qb->fetchrow_array){
    next unless $muerta{$iid};
    push @cand, [$iid,$rid,$conf];
    $n_conf++ if defined $conf && $conf eq 'human_confirmed';
  }

  printf "=== RECONCILE (retire) ===\n";
  printf "  instancias caducadas          : %d\n", $n_muertas;
  printf "  ataduras a rol a RETIRAR      : %d\n", scalar @cand;
  printf "    de ellas human_confirmed    : %d  %s\n", $n_conf,
         ($n_conf? '(se retiran igual; aviso por transparencia)':'');

  if ($o{v}) {
    printf "  (detalle instancia | rol | confidence):\n";
    for my $c (@cand){ printf "    %-10s %-30s %s\n", @$c; }
  }

  if (!@cand){ print "Nada que retirar. Modelo limpio.\n"; $dbh->rollback; return; }

  if ($DRY){ print "DRY-RUN: nada escrito. Reejecuta con --commit para retirar.\n";
             $dbh->rollback; return; }

  # 3. COMMIT: marcar retired (solo las active cuya instancia está muerta)
  my $upd=$dbh->prepare(
    "UPDATE sem_binding_role SET status='retired', retired_at=NOW()
      WHERE instance_id=? AND role_id=? AND status='active'");
  my $n=0; for my $c (@cand){ $n+=$upd->execute($c->[0],$c->[1]); }
  $dbh->commit;
  printf "COMMIT OK. ataduras retiradas=%d (confirmadas incluidas=%d)\n", $n, $n_conf;
}

# ===========================================================================
# MODO PURGE  (borra físicamente lo retired antiguo)
# ===========================================================================
sub do_purge {
  my ($dbh)=@_;

  # candidatos: retired con retired_at anterior a (hoy - retención)
  my $qc=$dbh->prepare(
    "SELECT COUNT(*) FROM sem_binding_role
      WHERE status='retired'
        AND retired_at IS NOT NULL
        AND retired_at < (NOW() - INTERVAL ? DAY)");
  $qc->execute($RET);
  my ($n_purge)=$qc->fetchrow_array;

  printf "=== RECONCILE (purge) ===\n";
  printf "  retención (días)              : %d\n", $RET;
  printf "  ataduras retired a BORRAR     : %d\n", $n_purge;

  if ($o{v} && $n_purge){
    my $qd=$dbh->prepare(
      "SELECT instance_id, role_id, retired_at FROM sem_binding_role
        WHERE status='retired' AND retired_at IS NOT NULL
          AND retired_at < (NOW() - INTERVAL ? DAY)
        ORDER BY retired_at LIMIT 50");
    $qd->execute($RET);
    printf "  (muestra instancia | rol | retired_at):\n";
    while (my @r=$qd->fetchrow_array){ printf "    %-10s %-30s %s\n", @r; }
  }

  if (!$n_purge){ print "Nada que purgar.\n"; $dbh->rollback; return; }

  if ($DRY){ print "DRY-RUN: nada borrado. Reejecuta con --commit --purge.\n";
             $dbh->rollback; return; }

  my $del=$dbh->do(
    "DELETE FROM sem_binding_role
      WHERE status='retired' AND retired_at IS NOT NULL
        AND retired_at < (NOW() - INTERVAL ? DAY)", undef, $RET);
  $dbh->commit;
  printf "COMMIT OK. ataduras BORRADAS físicamente=%d\n", $del;
}

END { $dbh->disconnect if $dbh; }
