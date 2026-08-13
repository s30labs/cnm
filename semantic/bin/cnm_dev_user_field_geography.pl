#!/usr/bin/perl
# =============================================================================
# cnm_dev_user_field_geography.pl — puebla un CAMPO DE USUARIO de dispositivo con
#   el codigo de pais (geografia = ambito de servicio) derivado del nombre.
#
# PORTABILIDAD: el campo de usuario donde va la geografia NO es fijo entre
#   instalaciones (depende del orden en que se crearon los campos en el GUI de
#   CNM). Por eso el ID del campo es un PARAMETRO (--field-id, o geography_field_id
#   en semantic.conf), no un valor incrustado. El script escribe en la columna
#   devices_custom_data.columna<ID>.
#
#   Averiguar el ID en una instalacion concreta:
#     SELECT id, descr FROM devices_custom_types ORDER BY id;   -- busca 'Geography'
#
# Regla: codigo = 2 primeras letras del nombre, EN MAYUSCULAS, y SOLO si es un
#   ISO-2 de la lista blanca (evita falsos positivos tipo marca/codigo de site).
#   Semantica: pais al que el servidor DA SERVICIO (= geography, ambito de servicio).
#
# SEGURIDAD / PRODUCCION:
#   - dry-run por defecto; escribe solo con --commit.
#   - Solo servidores (filtro --type-like) y status 0/2 (activos/mantenimiento).
#   - Idempotente y NO destructivo: por defecto solo rellena el campo vacio ('-'/''),
#     preservando valores puestos a mano. Con --force sobrescribe.
#   - Backup CSV de los valores previos antes de cambiar nada.
#
# USO:
#   perl cnm_dev_user_field_geography.pl --field-id 8 --user U --pass P [--db onm]
#        [--host 127.0.0.1] [--type-like '%erver%'] [--iso ES,FR,US,DE,PT,MX]
#        [--commit] [--force] [--backup /ruta/backup.csv] [--conf /ruta/semantic.conf]
#
# Los valores especificos del cliente (db, paises, filtro, field-id) se toman de
# semantic.conf si no se pasan por linea de comandos.
# =============================================================================
use strict;
use warnings;
use DBI;
use Getopt::Long;
use FindBin;
use lib $FindBin::Bin;
use CNMSemanticConf;
use File::Path qw(make_path);
use File::Basename qw(dirname);

my %o=( host=>undef, db=>undef, user=>undef, pass=>undef,
        'type-like'=>undef, iso=>undef, conf=>undef, 'field-id'=>undef,
        commit=>0, force=>0, backup=>undef );
GetOptions(\%o,'host=s','db=s','user=s','pass=s','type-like=s','iso=s','conf=s',
   'field-id=i','commit!','force!','backup=s') or die "Argumentos invalidos\n";

my $CFG = CNMSemanticConf->load($o{conf});
$o{db}          = $CFG->get('db_name')            unless defined $o{db};
$o{host}        = $CFG->get('db_host')            unless defined $o{host};
$o{'type-like'} = $CFG->get('server_type_like')   unless defined $o{'type-like'};
$o{'field-id'}  = $CFG->get('geography_field_id') unless defined $o{'field-id'};
# lista blanca: iso2_whitelist si esta definida; si no, geography_vocab sin 'WW'
unless (defined $o{iso}) {
   my @w = $CFG->list('iso2_whitelist');
   @w = grep { uc($_) ne 'WW' } $CFG->list('geography_vocab') unless @w;
   $o{iso} = join(',', @w);
}

die "Falta --db (ni en semantic.conf)\n" unless $o{db};
die "Falta --user\n" unless $o{user};
die "Falta --field-id (o geography_field_id en semantic.conf): ID del campo de usuario\n"
   ."   donde va la geografia. Averiguar con: SELECT id, descr FROM devices_custom_types ORDER BY id;\n"
   unless defined $o{'field-id'} && "$o{'field-id'}" =~ /^\d+$/;
die "Lista blanca ISO-2 vacia: define geography_vocab o iso2_whitelist en semantic.conf\n"
   unless defined $o{iso} && $o{iso} =~ /\S/;

my $COL = 'columna'.$o{'field-id'};
$o{backup} = ($CFG->get('data_dir') || '/tmp')."/log/geography_${COL}_backup.csv"
   unless defined $o{backup};

my %ISO2 = map { uc($_) => 1 } grep { /\S/ } split(/\s*,\s*/, $o{iso});

print "Config: ".$CFG->source."\n";
printf "Campo de usuario destino: %s (field-id=%d)\n", $COL, $o{'field-id'};
print "Lista blanca ISO-2: ".join(',', sort keys %ISO2)."\n";
print $o{commit} ? "MODO: COMMIT (se escribira)\n" : "MODO: DRY-RUN (no se escribe; usa --commit)\n";
print $o{force}  ? "FORCE: sobrescribe el campo existente\n" : "Solo rellena el campo vacio ('-'/''); preserva manual\n";

my $dbh=DBI->connect("dbi:mysql:database=$o{db};host=$o{host}",$o{user},$o{pass},
   {RaiseError=>1,PrintError=>0,AutoCommit=>0,mysql_enable_utf8=>0})
   or do { no warnings 'once'; die "No conecto: $DBI::errstr\n"; };

# servidores activos con su nombre y el valor actual del campo
my $sth=$dbh->prepare(
   "SELECT d.id_dev, d.name, d.type, COALESCE(c.$COL,'-') AS geo
    FROM devices d
    LEFT JOIN devices_custom_data c ON c.id_dev = d.id_dev
    WHERE d.status IN (0,2) AND d.type LIKE ?");
$sth->execute($o{'type-like'});

my $upd=$dbh->prepare(
   "INSERT INTO devices_custom_data (id_dev, $COL) VALUES (?, ?)
    ON DUPLICATE KEY UPDATE $COL = VALUES($COL)");

make_path(dirname($o{backup})) unless -d dirname($o{backup});
open(my $bk,'>',$o{backup}) or die "No puedo abrir backup $o{backup}: $!\n";
print $bk "id_dev,name,type,geo_old,geo_new,accion\n";

my %by_country; my ($n_total,$n_set,$n_skip_novalid,$n_skip_hasval,$n_skip_nomatch)=(0,0,0,0,0);
while (my $r=$sth->fetchrow_hashref) {
   $n_total++;
   my $name=$r->{name}//'';
   my $code=uc(substr($name,0,2));
   my $old=$r->{geo};
   $old='-' if !defined $old || $old eq '';

   # codigo valido ISO-2 en la lista blanca?
   unless ($code=~/^[A-Z]{2}$/ && $ISO2{$code}) {
      $n_skip_novalid++;
      print $bk join(',', $r->{id_dev}, csv($name), csv($r->{type}), csv($old), '', 'skip_no_iso2')."\n";
      next;
   }
   # ya tiene valor y no forzamos?
   if (!$o{force} && $old ne '-') {
      $n_skip_hasval++;
      print $bk join(',', $r->{id_dev}, csv($name), csv($r->{type}), csv($old), '', 'skip_ya_tiene')."\n";
      next;
   }
   # cambia realmente?
   if ($old eq $code) { $n_skip_nomatch++; next; }

   $by_country{$code}++;
   $n_set++;
   print $bk join(',', $r->{id_dev}, csv($name), csv($r->{type}), csv($old), $code, 'set')."\n";
   $upd->execute($r->{id_dev}, $code) if $o{commit};
}
close($bk);

if ($o{commit}) { $dbh->commit; } else { $dbh->rollback; }
$dbh->disconnect;

print "\n=== RESUMEN ===\n";
print "Servidores evaluados (status 0/2, type LIKE '$o{'type-like'}'): $n_total\n";
print "$COL a asignar: $n_set\n";
for my $c (sort keys %by_country) { printf "   %-4s %d\n", $c, $by_country{$c}; }
print "Saltados - sin ISO-2 valido: $n_skip_novalid\n";
print "Saltados - ya tenian valor (sin --force): $n_skip_hasval\n";
print "Saltados - ya correctos: $n_skip_nomatch\n";
print "Backup de valores previos: $o{backup}\n";
print $o{commit} ? "\nCAMBIOS APLICADOS.\n" : "\nDRY-RUN: nada escrito. Revisa el backup y reejecuta con --commit.\n";

sub csv { my $s=shift; $s='' unless defined $s; if ($s=~/[",\n]/){$s=~s/"/""/g;return "\"$s\"";} return $s; }
