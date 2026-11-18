#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Prueba de la etiqueta de interfaz (ProvisionLite::IfLabels) y de los modulos
# traffic_mibii_if y status_mibii_if que la usan. SNMP simulado con lo medido en
# wwcnmprd03 el 18-nov-2026 (ESXi, Windows, FortiGate, NetScaler, Linux).
#
#   perl t/PROV_if_labels.t      (desde /opt/crawler/bin)
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use FindBin; use lib "$FindBin::Bin/..";
use strict;
use Test::More;
use ProvisionLite;
use ProvisionLite::IfLabels qw(read_columns choose_labels generic_ifname);

# Equipos: iid => [ifDescr, ifName, ifAlias, ifHCInOctets, ifHCOutOctets]
my %DEV = (
	esxi => {
		1  => ['Device vmnic0 at 18:00.0 bnxtnet','vmnic0','18:00.0',100,200],
		9  => ['Link Aggregation VLAN-152-LAN-BACKUP on switch: vSwitch1, load balancing algorithm: source port id hash','VLAN-152-LAN-BACKUP','vSwitch1',5,6],
		10 => ['Link Aggregation VLAN-153-vMotion on switch: vSwitch1, load balancing algorithm: source port id hash','VLAN-153-vMotion','vSwitch1',7,8],
		31 => ['Traditional Virtual VMware switch: vSwitch1','vSwitch1','vSwitch1',9,10],
		37 => ['Virtual interface: vmk0 on vswitch vSwitch0 portgroup: VLAN-150-3784-ESXi-Management','vmk0','vmk0-vSwitch0',11,12] },
	windows => {
		1  => ['Software Loopback Interface 1.','loopback_0','Loopback Pseudo-Interface 1',undef,undef],
		2  => ['Red Hat VirtIO Ethernet Adapter.','ethernet_32768','Ethernet Instance 0',undef,undef],
		7  => ['Microsoft ISATAP Adapter.','tunnel_32768','isatap.openstacklocal',undef,undef],
		10 => ['Red Hat VirtIO Ethernet Adapter-QoS Packet Scheduler-0000.','ethernet_1','Ethernet Instance 0-QoS Packet Scheduler-0000',undef,undef] },
	fortigate => {
		1 => ['','dmz','',0,0],
		3 => ['','wan1','INTERNET',3,4],
		7 => ['','port1','Conexion_FW_CORE',5,6] },
	netscaler => {
		1 => ['0/1','0/1','',2872046291,1685852819],
		2 => ['LO/1','LO/1','',2051292016,3001093224] },
	linux => {
		1 => ['lo','lo','',5,5],
		2 => ['eth0','eth0','',40,11] },
);
my %IDX = (ifDescr=>0, ifName=>1, ifAlias=>2, ifHCInOctets=>3, ifHCOutOctets=>4);

#------------------------------------------------------------------------------
# SNMP simulado: core_snmp_table como el real (filas iid:@:v1:@:v2...; 'U' si falta
# una columna; con error y sin filas, una lista de 'U'; el texto de fin de vista que
# devuelve Windows al pedir contadores de 64 bits)
#------------------------------------------------------------------------------
package FakeSNMP;
sub new { my ($c,$d)=@_; return bless { d=>$d, calls=>[] }, $c; }
sub hex2ascii { return $_[1]; }
sub core_snmp_table {
	my ($s,$cfg)=@_;
	my @cols = split(/_/,$cfg->{'oid'});
	push @{$s->{calls}}, $cfg->{'oid'};
	my $d = $DEV{$s->{d}};
	if ($s->{d} eq 'windows' && $cfg->{'oid'} =~ /^ifHC/) {
		return [ ':@:No more variables left in this MIB View (It is past the end of the MIB tree):@:U' ];
	}
	my @out=();
	foreach my $iid (sort { $a <=> $b } keys %$d) {
		my @v=();
		foreach my $c (@cols) {
			if    ($c eq 'ifType')  { push @v, 6; }
			elsif ($c eq 'ifSpeed') { push @v, 1000000000; }
			elsif ($c =~ /^if(In|Out)Octets$/) { push @v, 1; }
			elsif ($c =~ /^if(AdminStatus|OperStatus)$/) { push @v, 1; }
			else { my $x = $d->{$iid}->[$IDX{$c}]; push @v, defined $x ? $x : 'U'; }
		}
		push @out, join(':@:',$iid,@v);
	}
	return \@out;
}
package main;

sub labels_of {
	my ($dev)=@_;
	return choose_labels(read_columns(FakeSNMP->new($dev),{}));
}

#------------------------------------------------------------------------------
# 1. generic_ifname
#------------------------------------------------------------------------------
ok(generic_ifname($_), "generico: $_") foreach (qw(ethernet_32768 loopback_0 tunnel_32768 ppp_32768 ethernet_1));
ok(!generic_ifname($_), "no generico: $_") foreach ('vmnic0','eth0','port1','Gi0/1','0/1','VLAN-153-vMotion','ethernet','eth_0x');

#------------------------------------------------------------------------------
# 2. choose_labels con lo medido
#------------------------------------------------------------------------------
my $l = labels_of('esxi');
is($l->{1}{label}, 'vmnic0', 'ESXi: tarjeta fisica por ifName');
is($l->{9}{label}, 'VLAN-152-LAN-BACKUP', 'ESXi: grupo de puertos por ifName (no vSwitch1 de ifAlias)');
is($l->{37}{label}, 'vmk0', 'ESXi: vmk por ifName');
is($l->{31}{source}, 'ifName', 'ESXi: el conmutador tambien por ifName');

$l = labels_of('windows');
is($l->{2}{label}, 'Red Hat VirtIO Ethernet Adapter.', 'Windows: ifName generico, se usa ifDescr');
is($l->{1}{source}, 'ifDescr', 'Windows: loopback_0 tambien cae a ifDescr');
is($l->{10}{label}, 'Red Hat VirtIO Ethernet Adapter-QoS Packet Scheduler-0000.', 'Windows: los filtros conservan su ifDescr (CNM-METRICS los reconoce)');

$l = labels_of('fortigate');
is($l->{1}{label}, 'dmz', 'FortiGate: ifDescr vacio, ifName');
is($l->{3}{label}, 'wan1', 'FortiGate: ifName antes que ifAlias');

$l = labels_of('netscaler');
is($l->{1}{label}, '0/1', 'NetScaler: ifName');
$l = labels_of('linux');
is($l->{2}{label}, 'eth0', 'Linux: eth0');

# Repetidos y vacios
my $c = choose_labels({ ifName=>{1=>'x',2=>'x',3=>'z'}, ifDescr=>{1=>'d1',2=>'d2',3=>'d3'}, ifAlias=>{} });
is_deeply([$c->{1}{label},$c->{2}{label},$c->{3}{label}], ['d1','d2','z'], 'ifName repetido: esas dos van a ifDescr, la otra se queda');
$c = choose_labels({ ifName=>{1=>'',2=>''}, ifDescr=>{1=>'d',2=>'d'}, ifAlias=>{1=>'a1',2=>'a2'} });
is_deeply([$c->{1}{source},$c->{2}{source}], ['ifAlias','ifAlias'], 'ifName vacio e ifDescr repetido: ifAlias');
$c = choose_labels({ ifName=>{1=>'n',2=>'n'}, ifDescr=>{1=>'d',2=>'d'}, ifAlias=>{1=>'a',2=>'a'} });
is($c->{1}{label}, 'n', 'todo repetido: el primero con texto');
$c = choose_labels({ ifName=>{1=>''}, ifDescr=>{1=>''}, ifAlias=>{1=>''} });
ok(! exists $c->{1}, 'todo vacio: sin etiqueta (el modulo deja la suya)');

#------------------------------------------------------------------------------
# 3. read_columns: filas de error y 'U'
#------------------------------------------------------------------------------
package BadSNMP; sub new { bless {}, shift }
sub core_snmp_table { my ($s,$c)=@_; return $c->{oid} eq 'ifName' ? ['U','U'] : $c->{oid} eq 'ifDescr' ? ['1:@:  eth0  ','2:@:U'] : [':@:No more variables left in this MIB View']; }
package main;
my $col = read_columns(BadSNMP->new,{});
is_deeply($col->{ifName} || {}, {}, 'read_columns: la lista de U de un error no da filas');
is_deeply($col->{ifDescr}, {1=>'eth0',2=>''}, 'read_columns: recorta espacios y un U es vacio');
is_deeply($col->{ifAlias} || {}, {}, 'read_columns: el texto de fin de vista no es una fila');
my $f = FakeSNMP->new('esxi'); read_columns($f,{});
is_deeply($f->{calls}, ['ifName','ifDescr','ifAlias'], 'read_columns: cada columna en su propio recorrido');

#------------------------------------------------------------------------------
# 4. Los modulos: la misma etiqueta en trafico y estado; el trafico por 64 bits donde hay
#------------------------------------------------------------------------------
sub core { my ($x)=@_; $x =~ s/^(TRAFICO EN INTERFAZ|ESTADO DE INTERFAZ)\s+//; return $x; }
sub run_module {
	my ($fx,$dev,$label)=@_;
	my %d = (subtype=>$fx, label=>$label, items=>'A|B', oid=>'.1.3.6.1.2.1.2.2.1.10.IID|.1.3.6.1.2.1.2.2.1.16.IID', mtype=>'STD', vlabel=>'v', mode=>'COUNTER');
	return &{$ProvisionLite::Class2fx{$fx}}({ ip=>'1.2.3.4', full_name=>'eq' }, FakeSNMP->new($dev), \%d);
}
foreach my $dev (qw(esxi windows fortigate netscaler linux)) {
	my $t = run_module('traffic_mibii_if',$dev,'TRAFICO EN INTERFAZ ');
	my $s = run_module('status_mibii_if',$dev,'ESTADO DE INTERFAZ');
	my %tl = map { $_ => core($t->{$_}{label}) } keys %$t;
	my %sl = map { $_ => core($s->{$_}{label}) } keys %$s;
	ok(scalar(keys %tl) > 0 && scalar(keys %sl) > 0, "$dev: los dos modulos dan instancias");
	is_deeply(\%tl, { map { $_ => $sl{$_} } keys %tl }, "$dev: trafico y estado con la misma etiqueta");
}
my $t = run_module('traffic_mibii_if','windows','TRAFICO EN INTERFAZ ');
is($t->{2}{label}, 'TRAFICO EN INTERFAZ  Red Hat VirtIO Ethernet Adapter. (eq)', 'traffic Windows: etiqueta por ifDescr (antes, con el ifName renombrado, ifAlias)');
like($t->{2}{items}, qr/ifTable \(2\)/, 'traffic Windows: sin 64 bits, ifTable');
$t = run_module('traffic_mibii_if','esxi','TRAFICO EN INTERFAZ ');
is($t->{9}{label}, 'TRAFICO EN INTERFAZ  VLAN-152-LAN-BACKUP (eq)', 'traffic ESXi: el grupo de puertos por ifName');
like($t->{9}{items}, qr/ifXTable \(9\)/, 'traffic ESXi: con 64 bits, ifXTable');
like($t->{9}{oid}, qr/^\.1\.3\.6\.1\.2\.1\.31\.1\.1\.1\.6\.9\|/, 'traffic ESXi: OID de ifHCInOctets');
$t = run_module('traffic_mibii_if','fortigate','TRAFICO EN INTERFAZ ');
like($t->{1}{items}, qr/ifTable \(1\)/, 'traffic FortiGate: contadores de 64 bits a cero, ifTable');
my $s = run_module('status_mibii_if','windows','ESTADO DE INTERFAZ');
is($s->{7}{label}, 'ESTADO DE INTERFAZ Microsoft ISATAP Adapter. (eq)', 'status Windows: ifDescr (antes, con el ifName renombrado, tunnel_32768)');

done_testing();
