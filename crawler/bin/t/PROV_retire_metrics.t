#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Prueba de la retirada de metricas al quitar filas de la plantilla
# (REG-CNM-Deuda 4.107) y de que una fila inactiva sin metrica no se da de alta
# (4.106). Sin base de datos: Store, dbh y cliente WS simulados; los RRD, en un
# directorio temporal.
#
#   perl t/PROV_retire_metrics.t      (desde /opt/crawler/bin)
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use FindBin; use lib "$FindBin::Bin/..";
use strict;
use Test::More;
use File::Temp qw(tempdir);
use File::Path qw(make_path);
use ProvisionLite;
use ProvisionLite::ProvGuard qw(GUARD_OFF GUARD_ON GUARD_WATCH);

#------------------------------------------------------------------------------
package FakeDBH; sub new { bless {}, shift } sub quote { my ($s,$v)=@_; return defined $v ? "'$v'" : 'NULL'; }
package FakeWS;  sub new { bless {}, shift } sub store { 1 }
package FakeStore;
sub new { my ($c,%a)=@_; return bless { met=>[], existing=>{}, %a, selects=>[], updates=>[], stored=>[], snmp=>[] }, $c; }
sub get_from_db {
	my ($s,$dbh,$what,$table,$where)=@_;
	push @{$s->{selects}}, [$what,$table,$where];
	# Como Crawler::Store::get_from_db: si la consulta falla, [] y el error en error()
	$s->{_error} = $s->{fail_select} ? 1064 : 0;
	return [] if ($s->{fail_select});
	if ($what eq 'id_metric') {
		my ($n) = ($where =~ /name='([^']*)'/);
		return ((defined $n) && $s->{existing}{$n}) ? [[ 1 ]] : [];
	}
	# id_metric,name,file: las filas cuyo nombre esta en el IN de la consulta
	return [ grep { $where =~ /'\Q$_->[1]\E'/ } @{$s->{met}} ];
}
sub error { $_[0]->{_error} }
sub update_db   { my ($s,$dbh,$table,$data,$where)=@_; push @{$s->{updates}}, [$table,$data,$where]; return $s->{fail_update} ? undef : 1; }
sub store_metric      { my ($s,$dbh,$id,$m)=@_; push @{$s->{stored}}, { %$m }; return 1; }
sub store_metric2snmp { my ($s,$dbh,$t)=@_; push @{$s->{snmp}}, { %$t }; return 1; }
sub store_metric2latency { 1 }
sub store_subdir { return 'elements/'; }
package TProv; our @ISA=('ProvisionLite');
sub new { my ($c,%a)=@_; return bless { %a }, $c; }
sub istore { $_[0]->{store} } sub dbh { $_[0]->{dbh} } sub log { } sub wsclient { FakeWS->new() }
sub cfg { { host_name=>['cnm-test'] } }
sub retire_stamp { '20261124-100000' }
package main;
#------------------------------------------------------------------------------

my $STAMP = '20261124-100000';
my $TMP = tempdir(CLEANUP=>1);
$ProvisionLite::RRD_ELEMENTS_DIR = "$TMP/";

sub rrd   { my $f=shift; make_path("$TMP/".(split m{/},$f)[0]); open(my $fh,'>',"$TMP/$f") or die; print $fh "rrd $f"; close $fh; }
sub there { return (-e "$TMP/".$_[0]) ? 1 : 0; }

my %SNMP = ( type=>'snmp', subtype=>'disk_mibhost' );
# remove: lo que la provision quita de la plantilla (iid => {mname,...})
my %REMOVE = ( 85 => { mname=>'disk_mibhost-85', label=>'/proc/kallsyms' },
               64 => { mname=>'disk_mibhost-64', label=>'/usr/sap' },
               90 => { mname=>'disk_mibhost-90', label=>'sin metrica' } );
# MDATA: lo que el equipo ha devuelto en esta provision
my $MDATA = { 74 => { name=>'disk_mibhost-74', label=>'/proc/kallsyms' }, 55 => { name=>'disk_mibhost-55', label=>'/usr/sap' } };
my @MET = ( [ 101, 'disk_mibhost-85', '0000000032/disk_mibhost-85-STD.rrd' ],
            [ 102, 'disk_mibhost-64', '0000000032/disk_mibhost-64-STD.rrd' ] );

sub setup {
	my %a=@_;
	system("rm -rf '$TMP'/*");
	rrd($_->[2]) foreach (@MET);
	my $st = FakeStore->new(met=>[ @MET ], %a);
	return (TProv->new(store=>$st, dbh=>FakeDBH->new()), $st);
}
sub marked { my $st=shift; return [ sort map { $_->[2] } grep { $_->[0] eq 'metrics' && $_->[1]{status} eq '3' && $_->[1]{refresh} eq '1' } @{$st->{updates}} ]; }

#------------------------------------------------------------------------------
# 1. Con PROV_GUARD a 1: se archiva el RRD y se marca la metrica
#------------------------------------------------------------------------------
my ($p,$st) = setup();
my ($ok,$ko) = $p->retire_removed_metrics(32,\%REMOVE,\%SNMP,$MDATA,GUARD_ON,0);
is_deeply([sort @$ok], ['disk_mibhost-64','disk_mibhost-85'], 'GUARD 1: se retiran las dos metricas con fila quitada');
is_deeply($ko, [], 'GUARD 1: ninguna sin retirar');
is_deeply(marked($st), ['id_metric=101','id_metric=102'], 'GUARD 1: las dos, con status=3 y refresh=1, por id_metric');
is(there('0000000032/disk_mibhost-85-STD.rrd'), 0, 'GUARD 1: el RRD ya no esta con su nombre (cnm-watch no lo borra)');
is(there("0000000032/disk_mibhost-85-STD.rrd.removed-$STAMP"), 1, 'GUARD 1: el RRD esta archivado como .removed-AAAAMMDD-HHMMSS');
is(there("0000000032/disk_mibhost-64-STD.rrd.removed-$STAMP"), 1, 'GUARD 1: el segundo, tambien');
my $sel = (grep { $_->[1] eq 'metrics' } @{$st->{selects}})[0];
like($sel->[2], qr/^id_dev=32 AND type='snmp' AND status!=3 AND name in \(/, 'consulta: del equipo, SNMP y sin las que ya tienen status=3');
like($sel->[2], qr/'disk_mibhost-90'/, 'consulta: una fila quitada sin metrica se pide igual (y no pasa nada)');

#------------------------------------------------------------------------------
# 2. Cuando no se retira nada
#------------------------------------------------------------------------------
foreach my $c ([ 'GUARD 0',  GUARD_OFF,   \%SNMP, 0 ],
               [ 'GUARD 2',  GUARD_WATCH, \%SNMP, 0 ],
               [ 'GUARD sin definir', undef, \%SNMP, 0 ],
               [ 'latency',  GUARD_ON, { type=>'latency', subtype=>'mon_tcp' }, 0 ],
               [ 'xagent',   GUARD_ON, { type=>'xagent',  subtype=>'xagt_1' },  0 ],
               [ 'init=2',   GUARD_ON, \%SNMP, 2 ]) {
	my ($name,$g,$v,$init)=@$c;
	($p,$st) = setup();
	($ok,$ko) = $p->retire_removed_metrics(32,\%REMOVE,$v,$MDATA,$g,$init);
	ok(!@$ok && !@$ko, "$name: no se retira nada");
	is(scalar(@{$st->{selects}}) + scalar(@{$st->{updates}}), 0, "$name: ni se consulta ni se toca la base");
	is(there('0000000032/disk_mibhost-85-STD.rrd'), 1, "$name: el RRD sigue con su nombre");
}
foreach my $init (1,4) {
	($p,$st) = setup();
	($ok) = $p->retire_removed_metrics(32,\%REMOVE,\%SNMP,$MDATA,GUARD_ON,$init);
	is(scalar(@$ok), 2, "init=$init (asistente, csv): se retira como en init=0");
}

#------------------------------------------------------------------------------
# 3. Una metrica cuyo nombre se genera en esta provision no se retira
#------------------------------------------------------------------------------
($p,$st) = setup();
my $md2 = { %$MDATA, 64 => { name=>'disk_mibhost-64', label=>'otra cosa' } };
($ok) = $p->retire_removed_metrics(32,\%REMOVE,\%SNMP,$md2,GUARD_ON,0);
is_deeply($ok, ['disk_mibhost-85'], 'nombre generado en esta provision: no se retira');
unlike((grep { $_->[1] eq 'metrics' } @{$st->{selects}})[0]->[2], qr/'disk_mibhost-64'/, 'nombre generado: ni se pide');
is(there('0000000032/disk_mibhost-64-STD.rrd'), 1, 'nombre generado: su RRD sigue con su nombre');

#------------------------------------------------------------------------------
# 4. Sin filas quitadas, o sin nombre: nada
#------------------------------------------------------------------------------
($p,$st) = setup();
($ok) = $p->retire_removed_metrics(32,{},\%SNMP,$MDATA,GUARD_ON,0);
ok(!@$ok && !@{$st->{selects}}, 'sin filas quitadas: ni se consulta');
($ok) = $p->retire_removed_metrics(32,{ 7 => { mname=>'' }, 8 => {} },\%SNMP,$MDATA,GUARD_ON,0);
ok(!@$ok && !@{$st->{selects}}, 'filas sin mname: ni se consulta');

#------------------------------------------------------------------------------
# 5. Metrica sin RRD en disco: se marca igual
#------------------------------------------------------------------------------
($p,$st) = setup();
unlink "$TMP/0000000032/disk_mibhost-85-STD.rrd";
($ok,$ko) = $p->retire_removed_metrics(32,\%REMOVE,\%SNMP,$MDATA,GUARD_ON,0);
is(scalar(@$ok), 2, 'sin RRD en disco: se retira igual');
is(there("0000000032/disk_mibhost-85-STD.rrd.removed-$STAMP"), 0, 'sin RRD en disco: no se crea ningun archivado');
($p,$st) = setup(met=>[ [ 103, 'disk_mibhost-85', '' ] ]);
($ok) = $p->retire_removed_metrics(32,\%REMOVE,\%SNMP,$MDATA,GUARD_ON,0);
is_deeply(marked($st), ['id_metric=103'], 'metrica con file vacio: se marca, sin tocar el directorio');

#------------------------------------------------------------------------------
# 6. Si el RRD no se puede archivar, la metrica no se marca
#------------------------------------------------------------------------------
($p,$st) = setup();
make_path("$TMP/0000000032/disk_mibhost-85-STD.rrd.removed-$STAMP/ocupado");
($ok,$ko) = $p->retire_removed_metrics(32,\%REMOVE,\%SNMP,$MDATA,GUARD_ON,0);
is_deeply($ko, ['disk_mibhost-85'], 'no se puede archivar: queda como sin retirar');
is_deeply($ok, ['disk_mibhost-64'], 'no se puede archivar: las demas, si');
is_deeply(marked($st), ['id_metric=102'], 'no se puede archivar: esa metrica no se marca');
is(there('0000000032/disk_mibhost-85-STD.rrd'), 1, 'no se puede archivar: su RRD sigue con su nombre');

#------------------------------------------------------------------------------
# 7. Si la metrica no se puede marcar, el RRD vuelve a su nombre
#------------------------------------------------------------------------------
($p,$st) = setup(fail_update=>1);
($ok,$ko) = $p->retire_removed_metrics(32,\%REMOVE,\%SNMP,$MDATA,GUARD_ON,0);
is_deeply([sort @$ko], ['disk_mibhost-64','disk_mibhost-85'], 'no se puede marcar: quedan como sin retirar');
is(there('0000000032/disk_mibhost-85-STD.rrd'), 1, 'no se puede marcar: el RRD vuelve a su nombre');
is(there("0000000032/disk_mibhost-85-STD.rrd.removed-$STAMP"), 0, 'no se puede marcar: no queda el archivado');

#------------------------------------------------------------------------------
# 8. Si no se puede consultar la base: nada
#------------------------------------------------------------------------------
($p,$st) = setup(fail_select=>1);
($ok,$ko) = $p->retire_removed_metrics(32,\%REMOVE,\%SNMP,$MDATA,GUARD_ON,0);
ok(!@$ok && !@$ko && !@{$st->{updates}}, 'consulta fallida ([] y error): no se retira nada');
($p,$st) = setup(met=>[]);
($ok,$ko) = $p->retire_removed_metrics(32,\%REMOVE,\%SNMP,$MDATA,GUARD_ON,0);
ok(!@$ok && !@$ko, 'ninguna metrica para las filas quitadas: nada que retirar');
is(there('0000000032/disk_mibhost-85-STD.rrd'), 1, 'consulta fallida: el RRD sigue con su nombre');

#------------------------------------------------------------------------------
# 9. La marca de tiempo
#------------------------------------------------------------------------------
like(ProvisionLite::retire_stamp(), qr/^\d{8}-\d{6}$/, 'retire_stamp: AAAAMMDD-HHMMSS');

#------------------------------------------------------------------------------
# 10. skip_inactive_metric (4.106)
#------------------------------------------------------------------------------
($p,$st) = setup(existing=>{ 'w_mon_smtp-b31cd73d'=>1 });
is($p->skip_inactive_metric(49,{ name=>'disk_mibhost-172', status=>1 }), 1, 'inactiva sin metrica: se salta');
is($p->skip_inactive_metric(49,{ name=>'w_mon_smtp-b31cd73d', status=>1 }), 0, 'inactiva con metrica: no se salta (se desactiva)');
like($st->{selects}[-1][2], qr/^id_dev=49 AND name='w_mon_smtp-b31cd73d'$/, 'skip_inactive_metric: busca por equipo y nombre');
my $n = scalar(@{$st->{selects}});
is($p->skip_inactive_metric(49,{ name=>'disk_mibhost-1', status=>0 }), 0, 'activa: no se salta');
is($p->skip_inactive_metric(49,{ name=>'disk_mibhost-1' }), 0, 'sin status: no se salta');
is($p->skip_inactive_metric(49,{ status=>1 }), 0, 'sin nombre: no se salta');
is(scalar(@{$st->{selects}}), $n, 'activa, sin status o sin nombre: ni se consulta');
($p,$st) = setup(fail_select=>1);
is($p->skip_inactive_metric(49,{ name=>'disk_mibhost-172', status=>1 }), 0, 'consulta fallida ([] y error): no se salta (lo de siempre)');

#------------------------------------------------------------------------------
# 11. metric2db (4.106): lo inactivo sin metrica no se da de alta
#------------------------------------------------------------------------------
my %M = ( type=>'snmp', subtype=>'disk_mibhost', mtype=>'STD_BASE', label=>'x', lapse=>300, oid=>'.1.3.6.1.2.1.25.2.3.1.6', iid=>'172' );
($p,$st) = setup(existing=>{ 'disk_mibhost-173'=>1 });
$p->metric2db(49,{ community=>'c', version=>2 },{ %M, name=>'disk_mibhost-172', status=>1 });
is(scalar(@{$st->{stored}}) + scalar(@{$st->{snmp}}), 0, 'metric2db: inactiva sin metrica, ni metrics ni metric2snmp');
$p->metric2db(49,{ community=>'c', version=>2 },{ %M, name=>'disk_mibhost-173', status=>1 });
is(scalar(@{$st->{stored}}), 1, 'metric2db: inactiva con metrica, se guarda');
is($st->{stored}[-1]{status}, 3, 'metric2db: inactiva con metrica, con status=3 (como siempre)');
$p->metric2db(49,{ community=>'c', version=>2 },{ %M, name=>'disk_mibhost-42', status=>0 });
is($st->{stored}[-1]{status}, 0, 'metric2db: activa, con status=0');
is($st->{stored}[-1]{file}, '0000000049/disk_mibhost-42-STD.rrd', 'metric2db: el fichero del RRD es el que espera retire_removed_metrics');
is(scalar(@{$st->{snmp}}), 2, 'metric2db: metric2snmp para las dos que se guardan');

done_testing();
