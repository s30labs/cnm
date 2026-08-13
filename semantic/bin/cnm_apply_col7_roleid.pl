#!/usr/bin/perl
# =============================================================================
# cnm_apply_col7_roleid.pl — puebla el campo de usuario RoleID (col7) de cada
#   dispositivo, que luego consume el job de binding.
#
# TRES EJES ORTOGONALES (ver cnm_provision_job_diseno §14b): el rol viene del
# SERVICIO (col1), no de la ubicacion (Site) ni de a quien sirve (geografia).
# Site solo define rol en SITES REMOTOS. Este aplicador implementa dos vias para
# dos poblaciones disjuntas, mas un fallback:
#
#   VIA 1  col1 (Application) -> role_id   [crosswalk validado]      (servicio)
#   VIA 2  col4 (Site) remoto -> role_id   [mapa de sites validado]  (emplazamiento)
#          -> EXCLUYE los datacenters centrales (Site sin valor de rol ahi)
#   VIA 3  (opcional) type    -> role_id   [mapa de tipos]           (fallback)
#
# PRIORIDAD: col1 gana. Si un dispositivo tiene col1 mapeado, se usa esa via y
# NO se mira Site. Site solo actua sobre dispositivos SIN col1 mapeado.
#
# PORTABILIDAD: el id del campo RoleID es un parametro (--field-id / roleid_field_id
# en semantic.conf). Escribe en devices_custom_data.columna<ID>.
#   Averiguar: SELECT id, descr FROM devices_custom_types ORDER BY id;
#
# SEGURIDAD: dry-run por defecto; --commit para escribir. No destructivo (solo
# rellena col7 vacio salvo --force). Backup CSV de valores previos. Idempotente.
# Valida que cada role_id destino EXISTE en el maestro antes de escribir.
#
# FICHEROS DE ENTRADA (CSV, separador ; o , autodetectado, latin1):
#
#   --crosswalk FILE   (via 1)  col1_value ; role_id ; validado_cliente
#       - col1_value        valor EXACTO de col1 en CNM (case/espacios respetados)
#       - role_id           role_id destino (debe existir en el maestro)
#       - validado_cliente  OK | CAMBIAR | DESCARTAR (solo se aplican los 'OK')
#       (acepta tambien la cabecera del propuesta_v2: usa role_id_propuesto)
#
#   --sitemap FILE     (via 2)  site_value ; role_id ; validado_cliente
#       - site_value        valor EXACTO de col4 (Site) en CNM
#       - role_id           role_id de tipo site (debe existir en el maestro)
#       - validado_cliente  OK | CAMBIAR | DESCARTAR
#
#   --typemap FILE     (via 3, opcional)  type_value ; role_id ; validado_cliente
#
# USO:
#   perl cnm_apply_col7_roleid.pl --field-id 7 --db-user U --db-pass P \
#        --crosswalk cw.csv [--sitemap sites.csv] [--typemap types.csv] \
#        --roles cnm_roles_maestro.csv \
#        [--exclude-site 'site.data_center_adam_cerdanyola,site.data_center_tecno_alcala'] \
#        [--commit] [--force] [--conf ruta] [-v]
# =============================================================================
use strict;
use warnings;
use DBI;
use Text::CSV;
use Getopt::Long;
use FindBin;
use lib $FindBin::Bin;
use CNMSemanticConf;
use File::Path qw(make_path);
use File::Basename qw(dirname);

my %o=( host=>undef, db=>undef, user=>undef, pass=>undef, conf=>undef,
        'field-id'=>undef, crosswalk=>undef, sitemap=>undef, typemap=>undef,
        roles=>'cnm_roles_maestro.csv', 'exclude-site'=>undef,
        commit=>0, force=>0, backup=>undef, verbose=>0 );
GetOptions(\%o,'host=s','db=s','user=s','pass=s','conf=s','field-id=i',
   'crosswalk=s','sitemap=s','typemap=s','roles=s','exclude-site=s',
   'commit!','force!','backup=s','verbose|v!') or die "Argumentos invalidos\n";

my $CFG = CNMSemanticConf->load($o{conf});
$o{db}         = $CFG->get('db_name')            unless defined $o{db};
$o{host}       = $CFG->get('db_host','127.0.0.1') unless defined $o{host};
$o{'field-id'} = $CFG->get('roleid_field_id')    unless defined $o{'field-id'};
$o{'exclude-site'} = $CFG->get('central_datacenters') unless defined $o{'exclude-site'};

die "Falta --db (ni en semantic.conf)\n" unless $o{db};
die "Falta --user\n" unless $o{user};
die "Falta --field-id (o roleid_field_id en semantic.conf): ID del campo RoleID.\n"
   ."   Averiguar: SELECT id, descr FROM devices_custom_types ORDER BY id;\n"
   unless defined $o{'field-id'} && "$o{'field-id'}" =~ /^\d+$/;
die "Falta al menos una via: --crosswalk, --sitemap o --typemap\n"
   unless $o{crosswalk} || $o{sitemap} || $o{typemap};

my $COL = 'columna'.$o{'field-id'};
$o{backup} = ($CFG->get('data_dir') || '/tmp')."/log/roleid_${COL}_backup.csv"
   unless defined $o{backup};
my %EXCL = map { $_=>1 } grep { length } split(/\s*,\s*/, ($o{'exclude-site'}//''));

# ---------- utilidades ----------
sub sep_of { my $f=shift; open(my $s,'<',$f) or die "No abro $f: $!\n";
   my $l=<$s>; close($s); return (defined $l && ($l=~tr/;//)>($l=~tr/,//))?';':','; }
sub load_map {
   # lee un CSV de mapeo -> hash {valor_origen => role_id} solo con validado=OK
   # acepta cabeceras flexibles: {col1_value|site_value|type_value|valor},
   #   {role_id|role_id_propuesto}, {validado_cliente|validado}
   my ($file,$key_names)=@_;
   my $csv=Text::CSV->new({binary=>1,sep_char=>sep_of($file),auto_diag=>1});
   open(my $fh,'<',$file) or die "No abro $file: $!\n";
   my $h=$csv->getline($fh); $h->[0]=~s/^\x{feff}// if @$h;
   my %ix; $ix{lc $h->[$_]}=$_ for 0..$#$h;
   my $ck; for (@$key_names){ $ck=$ix{$_}, last if defined $ix{$_}; }
   die "En $file no encuentro la columna de valor (@$key_names)\n" unless defined $ck;
   my $rk = defined $ix{'role_id'} ? $ix{'role_id'} : $ix{'role_id_propuesto'};
   die "En $file no encuentro role_id (ni role_id_propuesto)\n" unless defined $rk;
   my $vk = defined $ix{'validado_cliente'} ? $ix{'validado_cliente'}
          : (defined $ix{'validado'} ? $ix{'validado'} : undef);
   my (%map,$n_ok,$n_skip);
   while (my $r=$csv->getline($fh)) {
      next unless grep { defined && /\S/ } @$r;
      my $val = _t($r->[$ck]); my $rid=_t($r->[$rk]);
      my $vld = defined $vk ? uc(_t($r->[$vk])) : 'OK';
      next if $val eq '' || $rid eq '';
      if (defined $vk && $vld ne 'OK') { $n_skip++; next; }  # solo se aplican los OK
      $map{$val}=$rid; $n_ok++;
   }
   close($fh);
   return (\%map,$n_ok,$n_skip//0);
}
sub _t { my $s=shift; return '' unless defined $s; $s=~s/^\s+|\s+$//g; return $s; }

# ---------- role_id validos (del maestro) ----------
my %VALID_ROLE;
{
   my $csv=Text::CSV->new({binary=>1,sep_char=>sep_of($o{roles}),auto_diag=>1});
   open(my $fh,'<',$o{roles}) or die "No abro $o{roles}: $!\n";
   my $h=$csv->getline($fh); $h->[0]=~s/^\x{feff}// if @$h;
   my %ix; $ix{$h->[$_]}=$_ for 0..$#$h;
   die "El maestro no tiene columna role_id\n" unless defined $ix{role_id};
   while (my $r=$csv->getline($fh)) {
      next unless grep { defined && /\S/ } @$r;
      my $rid=_t($r->[$ix{role_id}]); $VALID_ROLE{$rid}=1 if $rid ne '';
   }
   close($fh);
}
printf "Roles validos en el maestro: %d\n", scalar keys %VALID_ROLE;

# ---------- cargar las vias ----------
my ($cw,$cw_ok,$cw_sk)=(  {},0,0);
my ($sm,$sm_ok,$sm_sk)=(  {},0,0);
my ($tm,$tm_ok,$tm_sk)=(  {},0,0);
($cw,$cw_ok,$cw_sk)=load_map($o{crosswalk},['col1_value','valor']) if $o{crosswalk};
($sm,$sm_ok,$sm_sk)=load_map($o{sitemap},  ['site_value','valor']) if $o{sitemap};
($tm,$tm_ok,$tm_sk)=load_map($o{typemap},  ['type_value','valor']) if $o{typemap};

# validar que los role_id destino existen en el maestro
my @badrole;
for my $m ($cw,$sm,$tm) { for my $k (keys %$m) {
   push @badrole,"$k -> $m->{$k}" unless $VALID_ROLE{$m->{$k}}; } }
if (@badrole) {
   print STDERR "ERROR: role_id destino inexistente en el maestro:\n";
   print STDERR "  x $_\n" for @badrole;
   die "Corrige los mapeos antes de continuar.\n";
}

print "Config: ".$CFG->source."\n";
printf "Campo destino: %s (field-id=%d)\n", $COL, $o{'field-id'};
printf "Via col1 (crosswalk): %d mapeos OK%s\n", $cw_ok, $cw_sk?" ($cw_sk descartados)":"" if $o{crosswalk};
printf "Via Site (sitemap)  : %d mapeos OK%s\n", $sm_ok, $sm_sk?" ($sm_sk descartados)":"" if $o{sitemap};
printf "Via type (typemap)  : %d mapeos OK%s\n", $tm_ok, $tm_sk?" ($tm_sk descartados)":"" if $o{typemap};
print  "Sites excluidos (DC centrales, no siembran rol): ".join(', ',keys %EXCL)."\n" if %EXCL;
print $o{commit} ? "MODO: COMMIT (se escribira)\n" : "MODO: DRY-RUN (no se escribe; usa --commit)\n";
print $o{force}  ? "FORCE: sobrescribe col7 existente\n" : "Solo rellena col7 vacio ('-'/''); preserva manual\n";

# ---------- conectar ----------
my $dbh=DBI->connect("dbi:mysql:database=$o{db};host=$o{host}",$o{user},$o{pass},
   {RaiseError=>1,PrintError=>0,AutoCommit=>0,mysql_enable_utf8=>0})
   or do { no warnings 'once'; die "No conecto: $DBI::errstr\n"; };

# dispositivos activos con col1 (Application=col1), col4 (Site), type y col7 actual
my $sth=$dbh->prepare(
   "SELECT d.id_dev, d.name, d.type,
           COALESCE(c.columna1,'-') AS col1,
           COALESCE(c.columna4,'-') AS site,
           COALESCE(c.$COL,'-')     AS col7
    FROM devices d
    LEFT JOIN devices_custom_data c ON c.id_dev = d.id_dev
    WHERE COALESCE(d.status,0) IN (0,2)");
$sth->execute;

my $upd=$dbh->prepare(
   "INSERT INTO devices_custom_data (id_dev, $COL) VALUES (?, ?)
    ON DUPLICATE KEY UPDATE $COL = VALUES($COL)");

make_path(dirname($o{backup})) unless -d dirname($o{backup});
open(my $bk,'>',$o{backup}) or die "No abro backup $o{backup}: $!\n";
print $bk "id_dev,name,type,col7_old,col7_new,via,role_id\n";

my %by_via; my %by_role;
my ($n,$n_set,$skip_has,$skip_none,$skip_excl,$skip_same)=(0,0,0,0,0,0);
while (my $r=$sth->fetchrow_hashref) {
   $n++;
   my $old=$r->{col7}; $old='-' if !defined $old || $old eq '';
   my ($rid,$via);

   # VIA 1: col1 (servicio) -- gana siempre
   if ($r->{col1} ne '-' && exists $cw->{$r->{col1}}) {
      $rid=$cw->{$r->{col1}}; $via='col1';
   }
   # VIA 2: Site remoto -- solo si NO habia col1 y el site no es un DC central
   elsif ($r->{site} ne '-' && exists $sm->{$r->{site}}) {
      if ($EXCL{ $sm->{$r->{site}} }) { $skip_excl++; next; }  # DC central: no siembra rol
      $rid=$sm->{$r->{site}}; $via='site';
   }
   # VIA 3: type (fallback)
   elsif (exists $tm->{$r->{type}}) {
      $rid=$tm->{$r->{type}}; $via='type';
   }
   else { $skip_none++; next; }                     # ninguna via lo cubre

   if (!$o{force} && $old ne '-') { $skip_has++;     # ya tiene col7 y no forzamos
      print $bk join(',',$r->{id_dev},_c($r->{name}),_c($r->{type}),_c($old),'','skip_ya_tiene','')."\n";
      next; }
   if ($old eq $rid) { $skip_same++; next; }         # ya correcto

   $by_via{$via}++; $by_role{$rid}++; $n_set++;
   print $bk join(',',$r->{id_dev},_c($r->{name}),_c($r->{type}),_c($old),$rid,$via,$rid)."\n";
   $upd->execute($r->{id_dev},$rid) if $o{commit};
}
close($bk);
if ($o{commit}) { $dbh->commit; } else { $dbh->rollback; }
$dbh->disconnect;

print "\n=== RESUMEN ===\n";
print "Dispositivos activos evaluados: $n\n";
print "col7 a asignar: $n_set\n";
printf "   por via col1 (servicio): %d\n", $by_via{col1}//0;
printf "   por via Site (remoto)  : %d\n", $by_via{site}//0;
printf "   por via type (fallback): %d\n", $by_via{type}//0;
print "Saltados - ya tenian col7 (sin --force): $skip_has\n";
print "Saltados - ya correctos: $skip_same\n";
print "Saltados - Site de DC central (excluido): $skip_excl\n";
print "Saltados - ninguna via los cubre: $skip_none\n";
print "Roles distintos asignados: ".(scalar keys %by_role)."\n";
print "Backup de valores previos: $o{backup}\n";
print $o{commit} ? "\nCAMBIOS APLICADOS.\n" : "\nDRY-RUN: nada escrito. Revisa el backup y reejecuta con --commit.\n";

sub _c { my $s=shift; $s='' unless defined $s; if($s=~/[",\n]/){$s=~s/"/""/g;return "\"$s\"";} return $s; }
