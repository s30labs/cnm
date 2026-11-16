#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Prueba de como ProvisionLite aplica el reordenamiento por etiqueta
# (PROY-CNM-Alertas-Azules §7, P1): interruptor, foto previa, watch/status del
# modo 0, c_label y avisos en qactions. Sin base de datos: Store y dbh simulados.
#
#   perl t/PROV_label_remap_apply.t      (desde /opt/crawler/bin)
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use FindBin; use lib "$FindBin::Bin/..";
use strict;
use Test::More;
use ProvisionLite;

#------------------------------------------------------------------------------
package FakeDBH; sub new { bless {}, shift } sub quote { my ($s,$v)=@_; return defined $v ? "'$v'" : 'NULL'; }
package FakeStore;
sub new { my ($c,%a)=@_; return bless { %a, updates=>[], qactions=>[] }, $c; }
sub get_from_db { my ($s,$dbh,$what,$table,$where)=@_; return ($table =~ /prov_template_metrics2iid/) ? $s->{tpl} : $s->{met}; }
sub update_db   { my ($s,$dbh,$table,$data,$where)=@_; push @{$s->{updates}}, [$table,$data->{c_label},$where]; return 1; }
sub log_qactions{ my ($s,$dbh,$d)=@_; push @{$s->{qactions}}, $d; return 1; }
package TProv; our @ISA=('ProvisionLite');
sub new { my ($c,%a)=@_; return bless { %a }, $c; }
sub istore { $_[0]->{store} } sub dbh { $_[0]->{dbh} } sub cfg { $_[0]->{cfg} } sub log { }
package main;
#------------------------------------------------------------------------------

# 1. Interruptor
is(TProv->new(cfg=>{ prov_remap_by_label=>['1'] })->remap_by_label_enabled(), 1, 'interruptor: PROV_REMAP_BY_LABEL = 1 activa');
is(TProv->new(cfg=>{ prov_remap_by_label=>['0'] })->remap_by_label_enabled(), 0, 'interruptor: 0 desactiva');
is(TProv->new(cfg=>{ })->remap_by_label_enabled(), 0, 'interruptor: si no esta, desactivado');
is(TProv->new(cfg=>''  )->remap_by_label_enabled(), 0, 'interruptor: sin configuracion, desactivado');

# 2. cnm-areas en modo 0: plantilla y metrics antes del cambio de maquina virtual
my $store = FakeStore->new(
	tpl => [ ['disk_mibhost','31','USO DE DISCO / (cnm-areas)','m31',0],
	         ['disk_mibhost','36','USO DE DISCO /var (cnm-areas)','0',0],
	         ['disk_mibhost','37','USO DE DISCO /run/lock (cnm-areas)','0',0],
	         ['disk_mibhost','41','USO DE DISCO /boot (cnm-areas)','0',0],
	         ['disk_mibhost','43','USO DE DISCO /home (cnm-areas)','m43',0] ],
	met => [ ['disk_mibhost','31','USO DE DISCO / (cnm-areas)','Raiz'],
	         ['disk_mibhost','36','USO DE DISCO /var (cnm-areas)',undef],
	         ['disk_mibhost','43','USO DE DISCO /home (cnm-areas)','Usuarios'] ] );
my $p = TProv->new(store=>$store, dbh=>FakeDBH->new, cfg=>{ prov_remap_by_label=>['1'] });

my $snap = $p->snapshot_instances(1);
is($snap->{disk_mibhost}{31}{c_label}, 'Raiz', 'foto: c_label sale de metrics');
is($snap->{disk_mibhost}{43}{watch},   'm43',  'foto: watch sale de la plantilla');
ok(! defined $snap->{disk_mibhost}{36}{c_label}, 'foto: c_label NULL queda undef');

# La plantilla actual ($v->{IIDS}) y lo que responde el equipo ($MDATA)
my %IIDS = map { my ($st,$iid,$l,$w,$s)=@$_; ($iid => { label=>$l, watch=>$w, status=>$s, mname=>"disk_mibhost-$iid" }) } @{$store->{tpl}};
my $v = { type=>'snmp', subtype=>'disk_mibhost', IIDS=>\%IIDS };
my $MDATA = { 36=>{ label=>'USO DE DISCO / (cnm-areas)',         name=>'disk_mibhost-36' },
              43=>{ label=>'USO DE DISCO /run/lock (cnm-areas)', name=>'disk_mibhost-43' },
              52=>{ label=>'USO DE DISCO /boot (cnm-areas)',     name=>'disk_mibhost-52' },
              54=>{ label=>'USO DE DISCO /store/mysql (cnm-areas)', name=>'disk_mibhost-54' } };

# Lo que deja la fase B de hoy: 36 y 43 'change' con el watch de su iid; 52 y 54, iid nuevos, con status=1
my %nochange = ();
my %change = ( 36=>{ watch=>'0', status=>0 }, 43=>{ watch=>'m43', status=>0 }, 52=>{ watch=>'0', status=>1 }, 54=>{ watch=>'0', status=>1 } );

my $rm = $p->remap_instances(1,$v,$MDATA,$snap->{disk_mibhost},0);
$p->apply_remap_watch_status($rm,\%nochange,\%change);
is($change{36}{watch}, 'm31', 'modo 0: el monitor de / pasa del 31 al 36');
is($change{43}{watch}, '0',   'modo 0: el 43 deja el monitor de /home (que ha desaparecido)');
is($change{52}{status}, 0,    'modo 0: /boot cambia de iid (41 -> 52) y conserva su estado: activa');
is($change{54}{status}, 1,    'modo 0: /store/mysql, nueva, se queda inactiva como hoy (status=1)');

$p->apply_remap_c_label(1,'disk_mibhost',$MDATA,$rm,$snap->{disk_mibhost});
my %upd = map { ($_->[2] => $_->[1]) } @{$store->{updates}};
is($upd{"id_dev=1 AND name='disk_mibhost-36'"}, 'Raiz', 'c_label: Raiz pasa al 36');
ok(exists $upd{"id_dev=1 AND name='disk_mibhost-43'"} && ! defined $upd{"id_dev=1 AND name='disk_mibhost-43'"}, 'c_label: el 43 se queda sin el de /home');
ok(! exists $upd{"id_dev=1 AND name='disk_mibhost-52'"}, 'c_label: el 52 no se toca (no tenia ni tiene)');

my @q = map { $_->{descr} } @{$store->{qactions}};
ok((grep { $_ eq 'Instancias reordenadas por etiqueta' } @q), 'qactions: anota las reordenadas');
my ($aviso) = grep { $_->{descr} eq 'Instancias desaparecidas con monitor o c_label' } @{$store->{qactions}};
ok($aviso && $aviso->{rcstr} =~ m{/home} && $aviso->{rcstr} !~ m{/var}, 'qactions: avisa de /home (monitor y c_label) y no de /var');
ok(!(grep { !defined $_->{rc} || $_->{rc} !~ /^-?\d+$/ } @{$store->{qactions}}), 'qactions: rc es un entero, como la columna qactions.rc');

done_testing();
