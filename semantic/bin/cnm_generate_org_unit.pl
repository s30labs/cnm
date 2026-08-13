#!/usr/bin/perl
# =============================================================================
# cnm_generate_org_unit.pl — carga sem_org_unit desde un CSV de unidades org.
#
# Mismo patron que cnm_generate_roles.pl: dry-run por defecto, upsert idempotente
# por org_id, validacion de integridad antes de escribir, dos pasadas para el FK
# jerarquico (parent_org_id), y no pisa con blancos.
#
# CSV (cabecera, separador ; o , autodetectado; latin1):
#   org_id ; display_name ; parent_org_id ; kind ; geography ; contact ; Comentarios
#   - org_id        OBLIGATORIO, unico. Clave.
#   - display_name  OBLIGATORIO.
#   - parent_org_id opcional; si esta, debe existir en el propio CSV o en la tabla.
#   - kind          team|department|division|company  (ENUM; por defecto 'team')
#   - geography     opcional (ISO-2 + WW). Se valida contra semantic.conf si hay.
#   - contact       opcional: nombre o email. Si parece email, se valida el formato.
#   - columnas extra (Comentarios...) se ignoran.
#
# USO:
#   perl cnm_generate_org_unit.pl --file cnm_org_unit.csv --db-user U --db-pass P
#        [--db-name onm] [--db-host 127.0.0.1] [--db-port 3306]
#        [--commit] [--operator NOMBRE] [--note "..."] [--conf ruta] [-v]
# =============================================================================
use strict;
use warnings;
use Text::CSV;
use DBI;
use Getopt::Long;
use POSIX ();
use FindBin;
use lib $FindBin::Bin;
use CNMSemanticConf;

my %o=( file=>undef, 'db-name'=>undef, 'db-host'=>undef, 'db-port'=>3306,
        'db-user'=>undef, 'db-pass'=>undef, conf=>undef,
        commit=>0, operator=>undef, note=>'', verbose=>0 );
GetOptions(\%o,'file=s','db-name=s','db-host=s','db-port=i','db-user=s','db-pass=s',
   'conf=s','commit!','operator=s','note=s','verbose|v!') or die "Argumentos invalidos\n";
die "Falta --file\n"    unless $o{file};
die "Falta --db-user\n" unless $o{'db-user'};

my $CFG = CNMSemanticConf->load($o{conf});
$o{'db-name'} = $CFG->get('db_name')            unless defined $o{'db-name'};
$o{'db-host'} = $CFG->get('db_host','127.0.0.1') unless defined $o{'db-host'};
$o{operator}  = ($ENV{USER}||'generator')        unless defined $o{operator};
my %GEO = map {$_=>1} $CFG->list('geography_vocab');   # vocabulario del cliente (opcional)

my %KIND = map {$_=>1} qw(team department division company);

# ---------- cargar CSV (separador autodetectado) ----------
my $sep = do {
   open(my $s,'<',$o{file}) or die "No puedo abrir $o{file}: $!\n";
   my $l=<$s>; close($s);
   (defined $l && ($l=~tr/;//) > ($l=~tr/,//)) ? ';' : ',';
};
my $csv = Text::CSV->new({ binary=>1, sep_char=>$sep, auto_diag=>1 });
open(my $fh,'<',$o{file}) or die "No puedo abrir $o{file}: $!\n";
my $hdr = $csv->getline($fh);
die "CSV vacio\n" unless $hdr;
$hdr->[0] =~ s/^\x{feff}// if @$hdr;                 # quitar BOM
my %ix; $ix{$hdr->[$_]}=$_ for 0..$#$hdr;
for my $req (qw(org_id display_name)) {
   die "Falta la columna obligatoria '$req' en el CSV\n" unless exists $ix{$req};
}
my @rows;
while (my $r=$csv->getline($fh)) {
   next unless grep { defined && /\S/ } @$r;         # saltar filas vacias
   my %row = map { $_ => (defined $r->[$ix{$_}] ? _trim($r->[$ix{$_}]) : '') } keys %ix;
   push @rows, \%row;
}
close($fh);
printf "CSV: %d unidades  (separador '%s')\n", scalar(@rows), $sep;

# ---------- validacion de integridad (antes de tocar la BD) ----------
my @err; my %ids;
for my $i (0..$#rows) {
   my $r = $rows[$i]; my $n = $i+2;
   my $id = $r->{org_id};
   push @err,"fila $n: org_id vacio" unless length $id;
   push @err,"fila $n: org_id duplicado '$id'" if length $id && $ids{$id}++;
   push @err,"fila $n: display_name vacio ($id)" unless length $r->{display_name};
   my $k = $r->{kind} // '';
   $k = 'team' if $k eq '';
   push @err,"fila $n: kind invalido '$k' ($id)" unless $KIND{$k};
   $r->{kind} = $k;
   if (length($r->{geography}//'') && %GEO && !$GEO{$r->{geography}}) {
      push @err,"fila $n: geography '$r->{geography}' fuera del vocabulario ($id)";
   }
   my $c = $r->{contact}//'';
   if ($c =~ /\@/ && $c !~ /^[^@\s]+\@[^@\s]+\.[^@\s]+$/) {
      push @err,"fila $n: contact parece email pero el formato es invalido: '$c' ($id)";
   }
}
# parents: deben existir en el CSV o (se comprobara) en la tabla
my %csv_ids = %ids;
my @parent_no_csv;
for my $i (0..$#rows) {
   my $r=$rows[$i]; my $p=$r->{parent_org_id}//'';
   next unless length $p;
   push @err,"fila ".($i+2).": un org es su propio parent ($r->{org_id})" if $p eq $r->{org_id};
   push @parent_no_csv, [$i+2,$r->{org_id},$p] unless $csv_ids{$p};
}
# ciclos
for my $r (@rows) {
   my %seen; my $cur=$r->{org_id}; my $hops=0;
   while (length $cur) {
      if ($seen{$cur}++) { push @err,"ciclo jerarquico detectado en '$r->{org_id}'"; last; }
      last if $hops++>100;
      my ($p) = map { $_->{parent_org_id} } grep { $_->{org_id} eq $cur } @rows;
      last unless defined $p && length $p;
      $cur=$p;
   }
}

if (@err) {
   print "\n=== ERRORES (no se carga nada) ===\n"; print "  x $_\n" for @err;
   exit 1;
}

# ---------- conectar ----------
my $dsn="dbi:mysql:database=$o{'db-name'};host=$o{'db-host'};port=$o{'db-port'}";
my $dbh=DBI->connect($dsn,$o{'db-user'},$o{'db-pass'},
   {RaiseError=>1,PrintError=>0,AutoCommit=>0,mysql_enable_utf8=>0})
   or do { no warnings 'once'; die "No conecto: $DBI::errstr\n"; };

# parents que no estan en el CSV: comprobar que existan en la tabla
if (@parent_no_csv) {
   my $chk=$dbh->prepare("SELECT 1 FROM sem_org_unit WHERE org_id=?");
   for my $pn (@parent_no_csv) {
      $chk->execute($pn->[2]); my ($ok)=$chk->fetchrow_array;
      push @err,"fila $pn->[0]: parent_org_id '$pn->[2]' no existe ni en el CSV ni en la tabla ($pn->[1])" unless $ok;
   }
   if (@err) {
      print "\n=== ERRORES (no se carga nada) ===\n"; print "  x $_\n" for @err;
      $dbh->rollback; $dbh->disconnect; exit 1;
   }
}

# ---------- upsert en dos pasadas (para el FK jerarquico) ----------
# 1a pasada: insertar/actualizar SIN parent (evita fallo de FK si el padre va despues)
# 2a pasada: fijar parent_org_id
my $up1=$dbh->prepare(
  "INSERT INTO sem_org_unit (org_id,display_name,kind,geography,contact)
   VALUES (?,?,?,?,?)
   ON DUPLICATE KEY UPDATE
     display_name=VALUES(display_name), kind=VALUES(kind),
     geography=COALESCE(NULLIF(VALUES(geography),''),geography),
     contact=COALESCE(NULLIF(VALUES(contact),''),contact)");
my $up2=$dbh->prepare("UPDATE sem_org_unit SET parent_org_id=? WHERE org_id=?");

my ($n_ins,$n_upd)=(0,0);
my $exist=$dbh->prepare("SELECT 1 FROM sem_org_unit WHERE org_id=?");
for my $r (@rows) {
   $exist->execute($r->{org_id}); my ($e)=$exist->fetchrow_array;
   $e ? $n_upd++ : $n_ins++;
   $up1->execute($r->{org_id},$r->{display_name},$r->{kind},
                 ($r->{geography}//''),($r->{contact}//''));
}
my $n_parent=0;
for my $r (@rows) {
   my $p=$r->{parent_org_id}//'';
   $n_parent++ if length $p;
   $up2->execute(length($p)?$p:undef, $r->{org_id});
}

# ---------- auditoria (mismo esquema y formato que cnm_generate_roles) ----------
if ($o{commit}) {
   my $batch = POSIX::strftime("%Y%m%d%H%M%S", localtime) . "-$$";
   $dbh->{AutoCommit}=1;   # el CREATE hace commit implicito
   eval {
      $dbh->do(q{CREATE TABLE IF NOT EXISTS sem_load_audit (
        batch_id VARCHAR(32) PRIMARY KEY, ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        file VARCHAR(255), operator VARCHAR(128), note VARCHAR(255),
        n_insert INT, n_update INT, n_parent INT, n_skipped INT
      ) ENGINE=InnoDB DEFAULT CHARSET=latin1});
      $dbh->do("INSERT INTO sem_load_audit (batch_id,file,operator,note,n_insert,n_update,n_parent,n_skipped) VALUES (?,?,?,?,?,?,?,?)",
               undef, $batch, $o{file}, $o{operator}, ($o{note}||'org_unit load'),
               $n_ins, $n_upd, $n_parent, 0);
   };
   warn "AVISO: no pude registrar auditoria: $@\n" if $@;
   $dbh->{AutoCommit}=0;
}

if ($o{commit}) { $dbh->commit; print "\n"; }
else            { $dbh->rollback; }

print "=== RESUMEN ===\n";
printf "Unidades en el CSV : %d\n", scalar(@rows);
printf "  altas  (INSERT)  : %d\n", $n_ins;
printf "  updates(UPDATE)  : %d\n", $n_upd;
print $o{commit} ? "CAMBIOS APLICADOS (sem_org_unit).\n"
                 : "DRY-RUN: nada escrito. Revisa y reejecuta con --commit.\n";
$dbh->disconnect;

sub _trim { my $s=shift; return '' unless defined $s; $s=~s/^\s+|\s+$//g; return $s; }
