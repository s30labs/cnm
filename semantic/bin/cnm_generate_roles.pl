#!/usr/bin/perl
# =============================================================================
# cnm_generate_roles.pl
# Materializa el Excel/CSV maestro de roles en la tabla sem_business_role.
# Fuente única de verdad = el CSV exportado del maestro validado.
#
# CONTEXTO: appliance CNM (Debian, Perl + MariaDB). Stack sin dependencias
# exóticas: DBI + DBD::mysql + Text::CSV. Charset latin1 (coherente con la
# reconciliación existente); ver NOTA CHARSET al final para Debian 13/utf8mb4.
#
# PRINCIPIOS (código de producción):
#   * Solo escribe en sem_* (jamás en tablas nativas de CNM).
#   * DRY-RUN por defecto: no escribe nada salvo --commit.
#   * Puerta de integridad ANTES de tocar la BD: aborta si hay error duro.
#   * Idempotente: upsert por role_id (nunca DELETE/recreate).
#   * Dos pasadas por la FK self-referencial parent_role_id -> role_id.
#   * No pisa el enriquecimiento puesto a mano: las columnas de enriquecimiento
#     (criticality, owner, sla, metadata, valid_from, valid_to) solo se
#     sobrescriben si el CSV trae valor (salvo --allow-blank-overwrite).
#   * Transacción única; rollback ante cualquier error o en dry-run.
#   * Reversible: log de cambios por lote (sem_role_change_log) + auditoría
#     (sem_load_audit). Filas __dup / marcadas DUPLICADO se excluyen por
#     defecto (no se crean roles espurios).
#
# PROCESO DE VALIDACIÓN Y TESTEO (obligatorio antes de producción):
#   1. Ejecutar SIEMPRE primero en dry-run y revisar el informe (altas,
#      cambios campo a campo, huérfanos, duplicados, saltados).
#   2. Ejecutar --commit sobre una COPIA de la BD (staging), nunca directo.
#   3. Verificar invariantes post-carga (el propio script los comprueba):
#      duplicados=0, parents resueltos=100%, tipos/enum válidos, recuentos.
#   4. Arnés de regresión: un CSV-fixture pequeño (2 procesos, 1 app, 1 svc,
#      1 segmento + 3 sites en cadena concesión->aeropuerto->segmento, 1
#      fila __dup, 1 parent inexistente) con resultado esperado escrito a
#      mano; el dry-run debe reproducirlo exactamente.
#   5. Solo tras (1-4), --commit en producción, con la BD respaldada.
#   Reversión de un lote: ver sem_role_change_log (old_val por role_id/campo)
#   y sem_load_audit (batch_id). El log permite reconstruir el estado previo.
#
# USO:
#   perl cnm_generate_roles.pl --file cnm_roles_maestro.csv \
#        --db-name onm --db-user U --db-pass P [--db-host 127.0.0.1] \
#        [--operator jdoe] [--note "carga inicial"] [-v]        # DRY-RUN
#   ... añadir --commit para escribir de verdad.
#   Flags: --commit --include-dup --allow-blank-overwrite --no-snapshot -v
# =============================================================================
use strict;
use warnings;
use DBI;
use Text::CSV;
use Getopt::Long;
use POSIX qw(strftime);

# ---------- CLI ----------
my %o = (
    file=>undef, 'db-host'=>'127.0.0.1', 'db-port'=>3306, 'db-name'=>undef,
    'db-user'=>undef, 'db-pass'=>undef, commit=>0, 'include-dup'=>0,
    'allow-blank-overwrite'=>0, 'no-snapshot'=>0, operator=>($ENV{USER}||'generator'),
    note=>'', verbose=>0,
);
GetOptions(\%o,
    'file=s','db-host=s','db-port=i','db-name=s','db-user=s','db-pass=s',
    'commit!','include-dup!','allow-blank-overwrite!','no-snapshot!',
    'operator=s','note=s','verbose|v!',
) or die "Error en argumentos\n";
die "Falta --file\n"          unless $o{file};
die "Falta --db-name\n"       unless $o{'db-name'};
my $DRY = !$o{commit};

# ---------- Definición de columnas de la TABLA (lista blanca) ----------
# Columnas de sem_business_role que este generador gestiona.
my @STRUCT = qw(role_type display_name domain environment geography status);
my @ENRICH = qw(criticality owner sla metadata valid_from valid_to);
# parent_role_id se gestiona en 2ª pasada (FK). Helpers del CSV (source,
# orig_id, brand, n_dispositivos, familia, Comentarios, Validación) se ignoran.
my %ENUM = (
    role_type   => {map {$_=>1} qw(business_process business_subprocess application technical_service site)},
    status      => {map {$_=>1} qw(draft active deprecated archived)},
    environment => {map {$_=>1} qw(prod pre dev)},
);
my @REQUIRED = qw(role_id role_type display_name domain);   # NOT NULL en DDL

# ---------- Utilidades ----------
sub trim { my $s=shift; return '' unless defined $s; $s=~s/^\s+//; $s=~s/\s+$//; return $s; }
sub norm { my $s=trim(shift); return length($s)?$s:undef; }   # '' -> undef (NULL)
sub log_v { print STDERR "[v] ",@_,"\n" if $o{verbose}; }

# ---------- Cargar CSV ----------
# Separador: Excel en español exporta con ';'. Se autodetecta de la cabecera
# para no depender de la configuración regional de quien exporta.
my $csv_sep = do {
   open(my $sfh,'<',$o{file}) or die "No puedo abrir $o{file}: $!\n";
   my $l=<$sfh>; close($sfh);
   (defined $l && ($l=~tr/;//) > ($l=~tr/,//)) ? ';' : ',';
};
my $csv = Text::CSV->new({ binary=>1, sep_char=>$csv_sep, auto_diag=>1 });
open(my $fh, '<', $o{file}) or die "No puedo abrir $o{file}: $!\n";
my $hdr = $csv->getline($fh) or die "CSV vacío\n";
my %col; $col{$hdr->[$_]} = $_ for 0..$#$hdr;
for my $r (@REQUIRED, 'parent_role_id') {
    die "El CSV no tiene la columna '$r'\n" unless exists $col{$r};
}
my @rows;
while (my $rec = $csv->getline($fh)) {
    my %h = map { $_ => $rec->[$col{$_}] } keys %col;
    push @rows, \%h;
}
close($fh);
printf "CSV leído: %d filas.\n", scalar @rows;

# ---------- Columna 'accion' (opcional): BORRAR = baja física solicitada ----------
# Separa las filas marcadas BORRAR del flujo normal de upsert. La eliminacion
# fisica es distinta de status=deprecated (baja logica): BORRAR quita el rol de la
# tabla. Se procesa aparte, con comprobacion de dependencias (bindings + hijos).
my @rows_delete;
if (exists $col{accion}) {
    my @keep;
    for my $r (@rows) {
        my $acc = uc(trim($r->{accion}//''));
        if    ($acc eq 'BORRAR') { push @rows_delete, $r; }
        elsif ($acc eq '' )      { push @keep, $r; }
        else { die "accion invalida '$r->{accion}' en role_id '".trim($r->{role_id}//'')."' (solo 'BORRAR' o vacio)\n"; }
    }
    @rows = @keep;
    printf "  de ellas, marcadas BORRAR (baja fisica): %d\n", scalar @rows_delete;
}

# ---------- Puerta de integridad (antes de tocar la BD) ----------
my (@errors, @warnings, @skipped);
my %seen_id;
for my $i (0..$#rows) {
    my $h = $rows[$i]; my $ln = $i+2;
    my $rid = trim($h->{role_id});
    # duplicados marcados / desambiguados: excluir salvo --include-dup
    if (!$o{'include-dup'} && ($rid =~ /__dup/ || (($h->{'Validación'}||'') =~ /DUPLICADO/i))) {
        push @skipped, "$rid (fila $ln): marcado duplicado -> excluido";
        $h->{__skip}=1; next;
    }
    for my $c (@REQUIRED) {
        push @errors, "fila $ln: '$c' vacío" unless length(trim($h->{$c}));
    }
    push @errors, "fila $ln: role_id duplicado en el fichero: $rid" if $seen_id{$rid}++;
    my $rt = trim($h->{role_type});
    push @errors, "fila $ln: role_type inválido '$rt'" if $rt && !$ENUM{role_type}{$rt};
    my $st = trim($h->{status});
    push @errors, "fila $ln: status inválido '$st'" if $st && !$ENUM{status}{$st};
    my $env = trim($h->{environment});
    push @errors, "fila $ln: environment inválido '$env'" if $env && !$ENUM{environment}{$env};
    my $cr = trim($h->{criticality});
    push @errors, "fila $ln: criticality fuera de 1-5 '$cr'" if length($cr) && $cr !~ /^[1-5]$/;
    for my $d (qw(valid_from valid_to)) {
        my $v = trim($h->{$d});
        push @errors, "fila $ln: $d no es fecha YYYY-MM-DD '$v'" if length($v) && $v !~ /^\d{4}-\d{2}-\d{2}$/;
    }
}
my @live = grep { !$_->{__skip} } @rows;

# ---------- Conexión ----------
my $dsn = "DBI:mysql:database=$o{'db-name'};host=$o{'db-host'};port=$o{'db-port'};mysql_enable_utf8=0";
my $dbh = DBI->connect($dsn, $o{'db-user'}, $o{'db-pass'},
    { RaiseError=>1, PrintError=>0, AutoCommit=>0 }) or die $DBI::errstr;

# role_ids existentes en BD (para resolver parents y diffs)
my %existing;
{
    my $q = $dbh->prepare("SELECT role_id, ".join(",", @STRUCT, @ENRICH, 'parent_role_id')." FROM sem_business_role");
    $q->execute;
    while (my $row = $q->fetchrow_hashref) { $existing{$row->{role_id}} = $row; }
}
printf "Roles ya en BD: %d\n", scalar keys %existing;

# resolución de parents: existen en fichero (no saltados) o en BD
my %file_ids = map { trim($_->{role_id}) => 1 } @live;
for my $i (0..$#live) {
    my $h=$live[$i];
    my $p = trim($h->{parent_role_id});
    next unless length $p;
    unless ($file_ids{$p} || $existing{$p}) {
        push @errors, "role ".trim($h->{role_id}).": parent_role_id inexistente '$p'";
    }
}

# roles en BD que NO están en el fichero (informativo; no se tocan)
my @in_db_not_file = grep { !$file_ids{$_} } keys %existing;

# ---------- Informe de puerta ----------
print "\n==== PUERTA DE INTEGRIDAD ====\n";
printf "Filas a procesar: %d | excluidas (dup): %d\n", scalar @live, scalar @skipped;
if (@skipped) { print "  - $_\n" for @skipped[0..($#skipped>9?9:$#skipped)]; }
if (@errors) {
    print "ERRORES DUROS (", scalar @errors, "):\n";
    print "  * $_\n" for @errors[0..($#errors>29?29:$#errors)];
    print "ABORTADO: corrige el maestro y reintenta. No se ha escrito nada.\n";
    $dbh->rollback; $dbh->disconnect; exit 2;
}
print "Integridad OK (0 errores duros).\n";
printf "Roles en BD que no están en el fichero (no se tocan): %d\n", scalar @in_db_not_file;

# ---------- Procesamiento de BAJAS FÍSICAS (accion=BORRAR) ----------
# Para cada rol marcado BORRAR se comprueban dependencias:
#   - bindings: filas en sem_binding_role que referencian el role_id
#   - hijos: roles con parent_role_id = ese role_id (que NO esten tambien en el
#            lote de BORRAR)
# a) sin dependencias -> SEGURO: se borra (en --commit).
# b) con dependencias -> BLOQUEADO: no se borra; se genera un .sql con los DELETE
#    (bindings primero, luego rol) para que el administrador decida.
my (@del_safe, @del_blocked, @del_missing);
if (@rows_delete) {
    my %del_set = map { trim($_->{role_id}) => 1 } @rows_delete;
    # ¿existe la tabla de bindings? (puede no estar poblada aun)
    my $has_binding_tbl = do {
        my $r = eval { $dbh->selectrow_array("SELECT 1 FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name='sem_binding_role'") };
        $r ? 1 : 0;
    };
    for my $r (@rows_delete) {
        my $rid = trim($r->{role_id});
        unless ($existing{$rid}) {   # no esta en BD: BORRAR de algo inexistente
            push @del_missing, $rid;   # se reporta aparte (no es una baja real)
            next;
        }
        my $n_bind = 0;
        if ($has_binding_tbl) {
            ($n_bind) = $dbh->selectrow_array("SELECT COUNT(*) FROM sem_binding_role WHERE role_id=?", undef, $rid);
        }
        # hijos que NO se borran tambien en este lote
        my @children = grep { ($existing{$_}{parent_role_id}//'') eq $rid && !$del_set{$_} } keys %existing;
        if ($n_bind==0 && !@children) { push @del_safe,    { rid=>$rid, note=>'', n_bind=>0, children=>[] }; }
        else                          { push @del_blocked, { rid=>$rid, n_bind=>$n_bind, children=>[@children] }; }
    }

    print "\n==== BAJAS FÍSICAS SOLICITADAS (accion=BORRAR): ", scalar @rows_delete, " ====\n";
    printf "  seguras (sin bindings ni hijos): %d\n", scalar @del_safe;
    printf "  bloqueadas (con dependencias)  : %d\n", scalar @del_blocked;
    if (@del_missing) {
        printf "  IGNORADAS (role_id no existe en BD, nada que borrar): %d\n", scalar @del_missing;
        print  "     $_\n" for @del_missing;
        print  "     ^ revisa si el role_id es correcto: un BORRAR que no encuentra su objetivo\n";
        print  "       suele ser un nombre viejo/erroneo. No se ha borrado nada por estas filas.\n";
    }

    # generar el .sql para las bloqueadas (siempre, aunque sea dry-run)
    if (@del_blocked) {
        my $sqlfile = $o{file}; $sqlfile =~ s/\.[^.]+$//; $sqlfile .= "_bajas_bloqueadas.sql";
        open(my $sf,'>',$sqlfile) or die "No puedo escribir $sqlfile: $!\n";
        print $sf "-- Bajas BLOQUEADAS por dependencias. Generado por cnm_generate_roles.pl\n";
        print $sf "-- Revisar y ejecutar A MANO si se confirma la eliminacion.\n";
        print $sf "-- Cada rol tiene bindings y/o roles hijos que quedarian huerfanos.\n\n";
        print $sf "START TRANSACTION;\n\n";
        for my $d (@del_blocked) {
            print $sf "-- rol '$d->{rid}': bindings=$d->{n_bind}";
            print $sf ", hijos=".join('|',@{$d->{children}}) if @{$d->{children}};
            print $sf "\n";
            print $sf "--   Opcion A (borrar tambien sus bindings):\n";
            print $sf "DELETE FROM sem_binding_role WHERE role_id='$d->{rid}';\n" if $d->{n_bind};
            if (@{$d->{children}}) {
                print $sf "--   ATENCION: hijos que quedarian sin parent (reasignar antes):\n";
                print $sf "--   ".join(", ",@{$d->{children}})."\n";
            }
            print $sf "DELETE FROM sem_business_role WHERE role_id='$d->{rid}';\n\n";
        }
        print $sf "COMMIT;\n";
        close($sf);
        print "  -> generado: $sqlfile  (DELETE para revisar y aplicar a mano)\n";
        for my $d (@del_blocked) {
            printf "     BLOQUEADO %-40s bindings=%d%s\n", $d->{rid}, $d->{n_bind},
                   (@{$d->{children}}?" hijos=".scalar(@{$d->{children}}):"");
        }
    }
}

# ---------- Planificación (read-modify-write, sin escribir) ----------
my (@plan_ins, @plan_upd, @plan_parent, @unchanged);
for my $h (@live) {
    my $rid = trim($h->{role_id});
    my $ex  = $existing{$rid};
    # valores objetivo
    my %tgt;
    $tgt{$_} = norm($h->{$_}) for @STRUCT;
    $tgt{status} ||= ($ex ? $ex->{status} : 'draft');
    # criticality: NOT NULL default 3
    my $cr = trim($h->{criticality});
    if    (length $cr)      { $tgt{criticality} = $cr; }
    elsif ($ex)             { $tgt{criticality} = $ex->{criticality}; }   # no pisar
    else                    { $tgt{criticality} = 3; }
    # enriquecimiento: solo pisa si el CSV trae valor (salvo override)
    for my $c (qw(owner sla metadata valid_from valid_to)) {
        my $v = norm($h->{$c});
        if (defined $v)                        { $tgt{$c} = $v; }
        elsif ($o{'allow-blank-overwrite'})    { $tgt{$c} = undef; }
        elsif ($ex)                            { $tgt{$c} = $ex->{$c}; }
        else                                   { $tgt{$c} = undef; }
    }
    if (!$ex) {
        push @plan_ins, { rid=>$rid, tgt=>\%tgt, parent=>norm($h->{parent_role_id}) };
    } else {
        my @diff;
        for my $c (@STRUCT, @ENRICH) {
            my $a = defined $ex->{$c} ? $ex->{$c} : '';
            my $b = defined $tgt{$c}  ? $tgt{$c}  : '';
            push @diff, "$c: '$a'->'$b'" if $a ne $b;
        }
        push @plan_upd, { rid=>$rid, tgt=>\%tgt, diff=>\@diff } if @diff;
        push @unchanged, $rid unless @diff;
        # parent (2ª pasada) — diff aparte
        my $pa = defined $ex->{parent_role_id} ? $ex->{parent_role_id} : '';
        my $pb = norm($h->{parent_role_id}); $pb = defined $pb ? $pb : '';
        push @plan_parent, { rid=>$rid, parent=>(length($pb)?$pb:undef), old=>$pa } if $pa ne $pb;
    }
}

# ---------- Informe del plan ----------
print "\n==== PLAN (", ($DRY?"DRY-RUN, no se escribe":"COMMIT"), ") ====\n";
printf "ALTAS: %d | MODIFICACIONES: %d | cambios de parent: %d | sin cambios: %d\n",
    scalar @plan_ins, scalar @plan_upd, scalar @plan_parent, scalar @unchanged;
if ($o{verbose}) {
    print "-- ALTAS --\n";      printf("  + %s (%s)\n",$_->{rid},$_->{tgt}{role_type}) for @plan_ins;
    print "-- MODIFICACIONES --\n"; printf("  ~ %s | %s\n",$_->{rid},join('; ',@{$_->{diff}})) for @plan_upd;
    print "-- PARENTS --\n";     printf("  ^ %s: '%s'->'%s'\n",$_->{rid},$_->{old},(defined $_->{parent}?$_->{parent}:'NULL')) for @plan_parent;
}

if ($DRY) {
    print "\nDRY-RUN: nada escrito. Revisa el plan y ejecuta con --commit sobre una copia primero.\n";
    $dbh->rollback; $dbh->disconnect; exit 0;
}

# =============================================================================
# EJECUCIÓN (--commit): tablas de auditoría, snapshot, dos pasadas, verificación
# =============================================================================
my $batch = strftime("%Y%m%d%H%M%S", localtime) . "-$$";
my $now_by = $o{operator};

# tablas auxiliares (fuera de la txn: DDL hace commit implícito)
$dbh->{AutoCommit}=1;
$dbh->do(q{CREATE TABLE IF NOT EXISTS sem_load_audit (
  batch_id VARCHAR(32) PRIMARY KEY, ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  file VARCHAR(255), operator VARCHAR(128), note VARCHAR(255),
  n_insert INT, n_update INT, n_parent INT, n_skipped INT
) ENGINE=InnoDB DEFAULT CHARSET=latin1});
$dbh->do(q{CREATE TABLE IF NOT EXISTS sem_role_change_log (
  id BIGINT AUTO_INCREMENT PRIMARY KEY, batch_id VARCHAR(32), ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  role_id VARCHAR(64), action VARCHAR(8), field VARCHAR(32), old_val TEXT, new_val TEXT,
  KEY ix_batch (batch_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1});
$dbh->{AutoCommit}=0;

eval {
    my @allcols = (@STRUCT, @ENRICH);
    # INSERT (parent NULL; se fija en pasada 2). created_by + deprecated_*.
    my $ins_sql = "INSERT INTO sem_business_role (role_id, ".join(",",@allcols).", created_by".
                  ($DRY?"":"" ) . ") VALUES (?,".join(",",("?")x@allcols).",?)";
    my $ins = $dbh->prepare($ins_sql);
    my $upd_dep = $dbh->prepare("UPDATE sem_business_role SET deprecated_at=NOW(), deprecated_by=?, deprecated_reason=? WHERE role_id=? AND deprecated_at IS NULL");
    my $log = $dbh->prepare("INSERT INTO sem_role_change_log (batch_id,role_id,action,field,old_val,new_val) VALUES (?,?,?,?,?,?)");

    for my $p (@plan_ins) {
        my @vals = map { $p->{tgt}{$_} } @allcols;
        $ins->execute($p->{rid}, @vals, $now_by);
        $log->execute($batch, $p->{rid}, 'INSERT', undef, undef, undef);
        $upd_dep->execute($now_by, "carga maestro $batch", $p->{rid})
            if ($p->{tgt}{status}||'') eq 'deprecated';
    }
    # UPDATE (por campos que cambian) con snapshot en el change_log
    for my $p (@plan_upd) {
        my $ex = $existing{$p->{rid}};
        my @set; my @bind;
        for my $c (@STRUCT, @ENRICH) {
            my $a = defined $ex->{$c} ? $ex->{$c} : '';
            my $b = defined $p->{tgt}{$c} ? $p->{tgt}{$c} : '';
            next if $a eq $b;
            push @set, "$c=?"; push @bind, $p->{tgt}{$c};
            $log->execute($batch,$p->{rid},'UPDATE',$c,$ex->{$c},$p->{tgt}{$c}) unless $o{'no-snapshot'};
        }
        if (@set) {
            $dbh->do("UPDATE sem_business_role SET ".join(",",@set)." WHERE role_id=?", undef, @bind, $p->{rid});
        }
        $upd_dep->execute($now_by, "carga maestro $batch", $p->{rid})
            if ($p->{tgt}{status}||'') eq 'deprecated' && ($ex->{status}||'') ne 'deprecated';
    }
    # ---- BAJAS FÍSICAS seguras (accion=BORRAR sin dependencias) ----
    for my $d (@del_safe) {
        next unless $existing{$d->{rid}};            # no-op si no existe
        $log->execute($batch, $d->{rid}, 'DELETE', undef,
                      ($existing{$d->{rid}}{display_name}//''), undef);
        $dbh->do("DELETE FROM sem_business_role WHERE role_id=?", undef, $d->{rid});
    }

    # 2ª pasada: parent_role_id (ya existen todos los role_id)
    for my $p (@plan_parent) {
        $dbh->do("UPDATE sem_business_role SET parent_role_id=? WHERE role_id=?", undef, $p->{parent}, $p->{rid});
        $log->execute($batch,$p->{rid},'UPDATE','parent_role_id',$p->{old},(defined $p->{parent}?$p->{parent}:undef)) unless $o{'no-snapshot'};
    }
    # también fijar parent en las ALTAS
    for my $p (@plan_ins) {
        next unless defined $p->{parent};
        $dbh->do("UPDATE sem_business_role SET parent_role_id=? WHERE role_id=?", undef, $p->{parent}, $p->{rid});
    }

    # ---- verificación post-carga (invariantes) ----
    my ($dups) = $dbh->selectrow_array("SELECT COUNT(*) FROM (SELECT role_id FROM sem_business_role GROUP BY role_id HAVING COUNT(*)>1) t");
    die "POST-CHECK: role_id duplicados=$dups\n" if $dups;
    my ($orph) = $dbh->selectrow_array("SELECT COUNT(*) FROM sem_business_role c LEFT JOIN sem_business_role p ON p.role_id=c.parent_role_id WHERE c.parent_role_id IS NOT NULL AND p.role_id IS NULL");
    die "POST-CHECK: parents huérfanos=$orph\n" if $orph;

    $dbh->do("INSERT INTO sem_load_audit (batch_id,file,operator,note,n_insert,n_update,n_parent,n_skipped) VALUES (?,?,?,?,?,?,?,?)",
        undef, $batch, $o{file}, $o{operator}, $o{note},
        scalar @plan_ins, scalar @plan_upd, scalar @plan_parent, scalar @skipped);

    $dbh->commit;
    1;
} or do {
    my $e = $@ || 'error desconocido';
    eval { $dbh->rollback };
    print "\nERROR durante la carga: $e\nROLLBACK aplicado. No se ha modificado nada.\n";
    $dbh->disconnect; exit 3;
};

printf "\nCOMMIT OK. batch_id=%s  altas=%d  cambios=%d  parents=%d  bajas=%d\n",
    $batch, scalar @plan_ins, scalar @plan_upd, scalar @plan_parent, scalar @del_safe;
print "Bajas BLOQUEADAS (revisar .sql): ".scalar(@del_blocked)."\n" if @del_blocked;
print "Reversión: consulta sem_role_change_log WHERE batch_id='$batch' (old_val por campo).\n";
$dbh->disconnect;
exit 0;

# =============================================================================
# NOTA CHARSET (Debian 11 -> 13): se usa latin1 (mysql_enable_utf8=0) por
# coherencia con la reconciliación y el esquema actuales. En la migración a
# Debian 13, si se unifica a utf8mb4, basta cambiar el DSN (mysql_enable_utf8mb4)
# y la CHARSET de las tablas auxiliares; la lógica no cambia.
# =============================================================================
