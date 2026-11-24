#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Prueba de que los RRD siguen a su etiqueta cuando las instancias cambian de iid
# (el "R2" de PROY-CNM-Alertas-Azules, apartado 5.3; REG-CNM-Deuda 4.107):
# el plan de intercambios, el intercambio en disco (renameat2, x86_64) y
# ProvisionLite::remap_rrd_files con Store y dbh simulados. Los RRD, en un
# directorio temporal; se sigue cada fichero por su numero de inodo.
#
#   perl t/PROV_rrd_remap.t      (desde /opt/crawler/bin)
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use FindBin; use lib "$FindBin::Bin/..";
use strict;
use Test::More;
use File::Temp qw(tempdir);
use File::Path qw(make_path);
use ProvisionLite;
use ProvisionLite::RrdRemap qw(swap_plan apply_plan_to rrd_swap rename2_supported);
use ProvisionLite::ProvGuard qw(GUARD_OFF GUARD_ON GUARD_WATCH);

#------------------------------------------------------------------------------
# 1. swap_plan: cada contenido acaba en el iid nuevo de su etiqueta
#------------------------------------------------------------------------------
sub check_plan {
	my ($moves,$name)=@_;
	my %orig = map { ($_->{from} => "F$_->{from}", $_->{to} => "F$_->{to}") } @$moves;
	my $plan = swap_plan($moves);
	my $after = apply_plan_to(\%orig,$plan);
	my @bad = grep { ($after->{$_->{to}} // '') ne "F$_->{from}" } @$moves;
	ok(!@bad, "$name: cada historico en el iid nuevo de su etiqueta");
	return $plan;
}
my $p;
$p = check_plan([ {from=>1,to=>2}, {from=>2,to=>1} ], 'intercambio de dos');
is(scalar(@$p), 1, 'intercambio de dos: 1 intercambio');
$p = check_plan([ {from=>1,to=>2}, {from=>2,to=>3}, {from=>3,to=>1} ], 'ciclo de tres');
is(scalar(@$p), 2, 'ciclo de tres: 2 intercambios');
# El 2746 del 23-nov: / 55->42, /sapmnt 65->54, /usr/sap 64->55
$p = check_plan([ {from=>55,to=>42}, {from=>65,to=>54}, {from=>64,to=>55} ], '2746 (cadena 64->55->42 y 65->54)');
is(scalar(@$p), 3, '2746: 3 intercambios (2 en la cadena de tres, 1 en la de dos)');
# Lo que habia en el final de una cadena (42) acaba en el principio (64)
my $a2746 = apply_plan_to({ 55=>'raiz', 64=>'usrsap', 65=>'sapmnt', 42=>'vacio42' }, $p);
is($a2746->{64}, 'vacio42', '2746: lo que habia en el 42 queda en el 64 (lo archivara la retirada)');
is_deeply(apply_plan_to({ 55=>'raiz', 64=>'usrsap', 65=>'sapmnt' }, $p), { 42=>'raiz', 55=>'usrsap', 54=>'sapmnt' }, '2746 sin ficheros en 42 y 54: se mueven, y 64 y 65 quedan vacios');
is_deeply(swap_plan([]), [], 'sin movimientos: sin intercambios');
is_deeply(swap_plan([ {from=>7,to=>7} ]), [], 'de un iid a si mismo: se ignora');
# Al azar: correspondencias inyectivas sobre 1..12 (semilla fija)
srand(4107);
my $bad=0;
for my $n (1..300) {
	my @f = (1..12); my @t = (1..12);
	@f = sort { rand() <=> 0.5 } @f; @t = sort { rand() <=> 0.5 } @t;
	my $k = 1 + int(rand(12));
	my @m = grep { $_->{from} != $_->{to} } map { { from=>$f[$_], to=>$t[$_] } } 0..$k-1;
	my %o = map { ($_ => "F$_") } 1..12;
	my $a = apply_plan_to(\%o, swap_plan(\@m));
	$bad++ if (grep { $a->{$_->{to}} ne "F$_->{from}" } @m);
}
is($bad, 0, '300 correspondencias al azar: todas bien');

#------------------------------------------------------------------------------
# 2. rrd_swap en disco
#------------------------------------------------------------------------------
my $T = tempdir(CLEANUP=>1);
sub put  { my ($f,$t)=@_; open(my $h,'>',$f) or die "$f: $!"; print $h $t; close $h; }
sub get  { my $f=shift; open(my $h,'<',$f) or return undef; local $/; my $t=<$h>; close $h; return $t; }
sub ino  { my @s=stat(shift); return @s ? $s[1] : undef; }
SKIP: {
	skip 'renameat2 solo en x86_64', 1 if (! rename2_supported());
	put("$T/a",'A'); put("$T/b",'B');
	my ($ok,$how) = rrd_swap("$T/a","$T/b");
	ok($ok && $how eq 'intercambio' && get("$T/a") eq 'B' && get("$T/b") eq 'A', 'rrd_swap: las dos existen, se intercambian');
	rrd_swap("$T/a","$T/b");
	ok(get("$T/a") eq 'A' && get("$T/b") eq 'B', 'rrd_swap dos veces: todo como estaba');
	unlink "$T/b";
	($ok,$how) = rrd_swap("$T/a","$T/b");
	ok($ok && $how eq 'movido' && ! -e "$T/a" && get("$T/b") eq 'A', 'rrd_swap: solo existe la primera, se mueve');
	($ok,$how) = rrd_swap("$T/a","$T/b");
	ok($ok && $how eq 'movido' && get("$T/a") eq 'A' && ! -e "$T/b", 'rrd_swap: solo existe la segunda, se mueve (y deshace lo anterior)');
	($ok,$how) = rrd_swap("$T/x","$T/y");
	ok($ok && $how eq 'ninguno', 'rrd_swap: no existe ninguna, nada');
	# El destino aparece entre la comprobacion y el movimiento (el recolector lo crea)
	{
		no warnings 'redefine';
		my $orig = \&ProvisionLite::RrdRemap::_renameat2;
		my $first = 1;
		local *ProvisionLite::RrdRemap::_renameat2 = sub {
			my ($x,$y,$f)=@_;
			if ($first && ($f == 1)) { $first=0; put($y,'NUEVO'); }
			return $orig->(@_);
		};
		unlink "$T/b";
		($ok,$how) = rrd_swap("$T/a","$T/b");
	}
	ok($ok && $how eq 'intercambio' && get("$T/b") eq 'A' && get("$T/a") eq 'NUEVO', 'rrd_swap: si el destino aparece entretanto (EEXIST), se intercambian y no se pisa');
	{
		no warnings 'redefine';
		local *ProvisionLite::RrdRemap::_renameat2 = sub { return 13; };
		($ok,$how) = rrd_swap("$T/a","$T/b");
	}
	ok(!$ok && $how =~ /errno 13/, 'rrd_swap: un error se devuelve');
}

#------------------------------------------------------------------------------
# 3. remap_rrd_files
#------------------------------------------------------------------------------
package FakeDBH; sub new { bless {}, shift } sub quote { my ($s,$v)=@_; return defined $v ? "'$v'" : 'NULL'; }
package FakeStore;
sub new { my ($c,%a)=@_; return bless { met=>[], %a, selects=>[], qactions=>[] }, $c; }
sub get_from_db { my ($s,$dbh,$what,$table,$where)=@_; push @{$s->{selects}}, [$what,$table,$where]; $s->{_error}=$s->{fail_select}?1064:0; return $s->{fail_select} ? [] : $s->{met}; }
sub error { $_[0]->{_error} }
sub log_qactions { my ($s,$dbh,$d)=@_; push @{$s->{qactions}}, $d; return 1; }
package TProv; our @ISA=('ProvisionLite');
sub new { my ($c,%a)=@_; return bless { journal=>[], %a }, $c; }
sub istore { $_[0]->{store} } sub dbh { $_[0]->{dbh} } sub log { }
sub rrd_journal { my ($s,$id,$st,$l)=@_; push @{$s->{journal}}, map { [ @$_ ] } @{$l || []}; }
package main;

my $D = "$T/rrd";
$ProvisionLite::RRD_ELEMENTS_DIR = "$D/";
my $DIR = "$D/0000002746";
sub f { return "$DIR/disk_mibhost-$_[0]-STD.rrd"; }
sub md { my ($iid,%x)=@_; return { name=>"disk_mibhost-$iid", mtype=>'STD_BASE', mode=>'GAUGE', label=>"L$iid", %x }; }
my %V = ( type=>'snmp', subtype=>'disk_mibhost', IIDS=>{ 55=>{ mname=>'disk_mibhost-55' }, 64=>{ mname=>'disk_mibhost-64' }, 65=>{ mname=>'disk_mibhost-65' } } );
my $RM = { moved=>[ {from=>55,to=>42,label=>'/'}, {from=>65,to=>54,label=>'/sapmnt'}, {from=>64,to=>55,label=>'/usr/sap'} ] };
my $MDATA = { 42=>md(42), 54=>md(54), 55=>md(55) };
my @MET = ( [55,'disk_mibhost-55','0000002746/disk_mibhost-55-STD.rrd'], [64,'disk_mibhost-64','0000002746/disk_mibhost-64-STD.rrd'], [65,'disk_mibhost-65','0000002746/disk_mibhost-65-STD.rrd'] );
my %INO;
sub setup {
	my %a=@_;
	system("rm -rf '$D'"); make_path($DIR);
	put(f($_), "historico $_") foreach (55,64,65);
	%INO = map { ($_ => ino(f($_))) } (55,64,65);
	my $st = FakeStore->new(met=>[ @MET ], %a);
	return (TProv->new(store=>$st, dbh=>FakeDBH->new()), $st);
}
sub untouched { return (ino(f(55)) == $INO{55}) && (ino(f(64)) == $INO{64}) && (ino(f(65)) == $INO{65}) && ! -e f(42) && ! -e f(54); }

SKIP: {
	skip 'renameat2 solo en x86_64', 30 if (! rename2_supported());
	my ($pv,$st) = setup();
	my ($done,$err) = $pv->remap_rrd_files(2746,\%V,$MDATA,$RM,GUARD_ON,0);
	is($err, '', 'GUARD 1: sin error');
	is(ino(f(42)), $INO{55}, '/: su historico (el fichero del 55) esta ahora en el 42');
	is(ino(f(55)), $INO{64}, '/usr/sap: su historico (el del 64) esta ahora en el 55');
	is(ino(f(54)), $INO{65}, '/sapmnt: su historico (el del 65) esta ahora en el 54');
	ok(! -e f(64) && ! -e f(65), '64 y 65 quedan sin fichero (no habia nada en 42 y 54)');
	is(scalar(@$done), 3, '3 intercambios hechos');
	my ($q) = @{$st->{qactions}};
	ok($q && $q->{descr} eq 'Instancias reordenadas por etiqueta: RRD' && $q->{rc} == 0 && $q->{id_dev} == 2746, 'aviso en qactions con rc=0 y el equipo');
	like($q->{rcstr}, qr/^disk_mibhost: los historicos siguen a su etiqueta \(55 -> 42 ; 65 -> 54 ; 64 -> 55; 3 intercambios\)$/, 'el aviso dice los movimientos');
	is(scalar(@{$pv->{journal}}), 3, 'una linea por intercambio en el registro');
	like($st->{selects}[0][2], qr/^id_dev=2746 AND type='snmp' AND subtype='disk_mibhost'$/, 'consulta las metricas del subtipo del equipo');

	# Con un fichero en el destino (un huerfano en el 42): se intercambia, no se pisa
	($pv,$st) = setup();
	put(f(42),'huerfano 42'); my $i42 = ino(f(42));
	$pv->remap_rrd_files(2746,\%V,$MDATA,$RM,GUARD_ON,0);
	is(ino(f(42)), $INO{55}, 'destino ocupado: el historico de / llega al 42');
	is(ino(f(64)), $i42, 'destino ocupado: el huerfano del 42 queda en el 64 (lo archivara la retirada)');

	# Cuando no se mueve nada
	foreach my $c ([ 'GUARD 0', GUARD_OFF, \%V, $MDATA, 0 ], [ 'GUARD 2', GUARD_WATCH, \%V, $MDATA, 0 ],
	               [ 'latency', GUARD_ON, { %V, type=>'latency' }, $MDATA, 0 ], [ 'init=2', GUARD_ON, \%V, $MDATA, 2 ],
	               [ 'COUNTER', GUARD_ON, \%V, { map { ($_ => md($_, mode=>'COUNTER')) } 42,54,55 }, 0 ]) {
		my ($n,$g,$v,$m,$init)=@$c;
		($pv,$st) = setup();
		($done,$err) = $pv->remap_rrd_files(2746,$v,$m,$RM,$g,$init);
		ok(untouched() && !@$done && !@{$st->{qactions}}, "$n: no se mueve nada ni se avisa");
	}
	($pv,$st) = setup();
	($done) = $pv->remap_rrd_files(2746,\%V,$MDATA,{ moved=>[] },GUARD_ON,0);
	ok(untouched() && !@{$st->{selects}}, 'sin movimientos: ni se consulta');

	# Fallos: no se mueve nada y se avisa con rc=1
	($pv,$st) = setup(met=>[ [55,'disk_mibhost-55','0000002746/otro-nombre.rrd'], @MET[1,2] ]);
	($done,$err) = $pv->remap_rrd_files(2746,\%V,$MDATA,$RM,GUARD_ON,0);
	ok(untouched() && $err =~ /tiene el fichero/ && $st->{qactions}[0]{rc} == 1, 'fichero de la base distinto del calculado: nada, aviso rc=1');
	($pv,$st) = setup(met=>[]);
	($done,$err) = $pv->remap_rrd_files(2746,{ %V, IIDS=>{} },$MDATA,$RM,GUARD_ON,0);
	ok(untouched() && $err =~ /no se sabe el nombre/, 'iid sin nombre conocido: nada, aviso');
	($pv,$st) = setup(fail_select=>1);
	($done,$err) = $pv->remap_rrd_files(2746,\%V,$MDATA,$RM,GUARD_ON,0);
	ok(untouched() && $err =~ /consultar metrics/, 'consulta fallida: nada, aviso');
	{
		no warnings 'redefine';
		local *ProvisionLite::rename2_supported = sub { 0 };
		($pv,$st) = setup();
		($done,$err) = $pv->remap_rrd_files(2746,\%V,$MDATA,$RM,GUARD_ON,0);
	}
	ok(untouched() && $err =~ /x86_64/, 'otra arquitectura: nada, aviso');
	# El segundo intercambio falla: se deshace el primero
	{
		no warnings 'redefine';
		my $n=0;
		local *ProvisionLite::rrd_swap = sub { $n++; return (0,'errno 5') if ($n == 2); return ProvisionLite::RrdRemap::rrd_swap(@_); };
		($pv,$st) = setup();
		($done,$err) = $pv->remap_rrd_files(2746,\%V,$MDATA,$RM,GUARD_ON,0);
	}
	ok(untouched(), 'fallo a mitad: todo vuelve a su sitio');
	ok($err =~ /se deshace/ && !@$done && $st->{qactions}[0]{rc} == 1, 'fallo a mitad: aviso rc=1 y nada hecho');
	ok((grep { $_->[2] eq 'deshecho' } @{$pv->{journal}}) && (grep { $_->[2] =~ /^fallo/ } @{$pv->{journal}}), 'fallo a mitad: el registro dice lo deshecho y el fallo');

	# Nombres: el de la lectura si el iid esta; si no, el de la base o el de la plantilla
	($pv,$st) = setup(met=>[ $MET[0] ]);
	($done,$err) = $pv->remap_rrd_files(2746,\%V,$MDATA,$RM,GUARD_ON,0);
	is($err, '', 'iid que desaparece sin metrica en la base: se usa el nombre de la fila de la plantilla');
	is(ino(f(55)), $INO{64}, 'y su historico se mueve igual');
}

done_testing();
