#!/usr/bin/perl -w
#------------------------------------------------------------------------------
# Test of the whole flow read -> plan -> apply -> plan again, with an in-memory fake
# database and a fake provisioning engine. It runs all the Perl code of the kinds; it does
# NOT test the SQL against MariaDB nor the real engine: that is measured on a test appliance.
#
#   cd /opt/cnm/control && perl t/CTL_flow.t
#------------------------------------------------------------------------------
use FindBin; use lib "$FindBin::Bin/../lib";
use strict;
use Test::More;
use File::Temp qw(tempdir);
use Storable qw(dclone);
use CNMControl::Core qw(validate_state make_plan apply_plan);
use CNMControl::Kind::Device;

#--- Fake database ----------------------------------------------------------------
package FakeDBH;
sub new { my $c=shift; return bless { t=>shift, log=>[] }, $c; }
sub _take { my ($b,$n)=@_; return splice(@$b,0,$n); }
sub selectall_arrayref {
my ($s,$q,$attr,@b)=@_; my $t=$s->{t}; push @{$s->{log}}, $q;
	my $slice = $attr && $attr->{Slice};
	my @r;
	if    ($q =~ /^SELECT monitor,lapse FROM cfg_monitor$/)   { @r = map { [$_, $t->{cfg_monitor}{$_}] } keys %{$t->{cfg_monitor}}; }
	elsif ($q =~ /FROM cfg_monitor_(snmp|agent)/)              { @r = (); }
	elsif ($q =~ /FROM cfg_host_types/)                        { @r = map { [$_] } @{$t->{types}}; }
	elsif ($q =~ /SELECT id,descr FROM devices_custom_types/)  { my $i=0; @r = map { [++$i, $_] } @{$t->{fields}}; }
	elsif ($q =~ /FROM devices_custom_data WHERE id_dev IN/)   { my %i=map{$_=>1}@b; my $n=0; my %col=map { uc($_) => 'columna'.++$n } @{$t->{fields}};
		foreach my $d (grep { $i{$_->{id_dev}} } @{$t->{devices}}) {
			my $c=$t->{custom}{$d->{ip}} or next;
			push @r, { id_dev=>$d->{id_dev}, map { ($col{$_} => $c->{$_}) } keys %$c }; } }
	elsif ($q =~ /FROM cfg_views WHERE cid=\? AND name=\?/)    { @r = grep { $_->{cid} eq $b[0] && lc($_->{name}) eq lc($b[1]) } @{$t->{views}}; }
	elsif ($q =~ /SELECT DISTINCT cid_ip FROM cfg_views WHERE cid=\?/) { my %u=(); @r = map { [$_] } grep { !$u{$_}++ }
		map { $_->{cid_ip} } grep { $_->{cid} eq $b[0] && $_->{cid_ip} ne '' && $_->{cid_ip} ne '127.0.0.1' } @{$t->{views}}; }
	elsif ($q =~ /FROM cfg_views2views WHERE cid_view=\? AND cid_subview=\?/) { @r = map { [$_->[0],$_->[1]] } @{$t->{v2v}||[]}; }
	elsif ($q =~ /SELECT login_name FROM cfg_user2view WHERE id_cfg_view=\?/) { @r = map { [$_->[1]] } grep { $_->[0]==$b[0] } @{$t->{u2v}||[]}; }
	elsif ($q =~ /SELECT name FROM cfg_views_types/)           { @r = map { [$_] } @{$t->{view_types}||[]}; }
	elsif ($q =~ /FROM devices WHERE ip IN/)                   { my %i=map{$_=>1}@b; @r = grep { $i{$_->{ip}} } @{$t->{devices}}; }
	elsif ($q =~ /FROM devices WHERE LOWER\(CONCAT/)           { my %i=map{$_=>1}@b; @r = grep { $i{lc "$_->{name}.$_->{domain}"} } @{$t->{devices}}; }
	elsif ($q =~ /FROM metrics WHERE id_dev IN \(([?,]+)\) AND name IN/) { my $n=($1=~tr/?//); my %d=map{$_=>1} _take(\@b,$n); my %m=map{$_=>1}@b;
		@r = grep { $d{$_->{id_dev}} && $m{$_->{name}} } @{$t->{metrics}}; }
	elsif ($q =~ /FROM prov_default_metrics2device WHERE id_dev IN/) { my %i=map{$_=>1}@b;
		foreach my $d (grep { $i{$_} } keys %{$t->{assist}||{}}) { push @r, [ $d, $_, 1 ] foreach (keys %{$t->{assist}{$d}}); } }
	elsif ($q =~ /FROM cfg_views2metrics WHERE id_metric IN/)  { my %m=map{$_=>1}@b;
		@r = map { [$_->[0],$_->[1]] } grep { $m{$_->[1]} } @{$t->{v2m}}; }
	else { die "query not simulated: $q"; }
	return [ map { $slice ? {%$_} : $_ } @r ];
}
sub selectcol_arrayref {
my ($s,$q,$attr,$v)=@_; my $t=$s->{t};
	return [ map { $_->{id_dev} } grep { $_->{ip} eq $v } @{$t->{devices}} ] if ($q =~ /WHERE ip=\?/);
	return [ map { $_->{id_dev} } grep { lc("$_->{name}.$_->{domain}") eq $v } @{$t->{devices}} ];
}
sub selectrow_hashref {
my ($s,$q,$attr,@b)=@_; my $t=$s->{t};
	if ($q =~ /FROM devices WHERE ip=\?/) { my ($d)=grep { $_->{ip} eq $b[0] } @{$t->{devices}}; return $d; }
	if ($q =~ /FROM metrics WHERE id_dev=\? AND name=\?/) { my ($m)=grep { $_->{id_dev}==$b[0] && $_->{name} eq $b[1] } @{$t->{metrics}}; return $m; }
	if ($q =~ /FROM cfg_users WHERE login_name=\?/) { my ($u)=grep { lc($_->{login_name}) eq lc($b[0]) } @{$t->{users}||[]}; return $u ? {%$u} : undef; }
	if ($q =~ /SELECT id_cfg_view,cid,cid_ip FROM cfg_views WHERE cid=\? AND name=\?/) {
		my ($v)=grep { $_->{cid} eq $b[0] && lc($_->{name}) eq lc($b[1]) } @{$t->{views}}; return $v ? { map { $_=>$v->{$_} } qw(id_cfg_view cid cid_ip) } : undef; }
	die "query not simulated: $q";
}
sub selectrow_array {
my ($s,$q,$attr,@b)=@_; my $t=$s->{t}; my $v=$b[0];
	return ($t->{last_id}) if ($q =~ /LAST_INSERT_ID/);
	if ($q =~ /FROM cnm\.cfg_cnms/) { die "sin permiso sobre cnm" if ($t->{cnm_denied}); return (scalar(grep { $_->[0] eq $b[0] && $_->[1] eq $b[1] } @{$t->{cnms}||[]})); }
	if ($q =~ /id_cfg_subview\) FROM cfg_views2views/) { my %u=map { $_->[1]=>1 } grep { $_->[0]==$v } @{$t->{v2v}||[]}; return scalar(keys %u); }
	my %u=map { $_->[1]=>1 } grep { $_->[0]==$v } @{$t->{v2m}}; return scalar(keys %u);
}
sub do {
my ($s,$q,$attr,@b)=@_; my $t=$s->{t}; push @{$s->{log}}, $q;
	die "simulated failure" if ($t->{fail_do} && $q =~ /$t->{fail_do}/);
	if ($q =~ /^UPDATE metrics SET c_label/) { $_->{c_label}=$b[0] foreach (grep { $_->{id_metric}==$b[1] } @{$t->{metrics}}); }
	elsif ($q =~ /^INSERT IGNORE INTO cfg_views2metrics/) { push @{$t->{v2m}}, [ $b[0],$b[1],$b[2] ] if (! grep { $_->[0]==$b[0] && $_->[1]==$b[1] } @{$t->{v2m}}); }
	elsif ($q =~ /^UPDATE cfg_views SET nmetrics/) { $_->{nmetrics}=$b[0] foreach (grep { $_->{id_cfg_view}==$b[1] } @{$t->{views}}); }
	elsif ($q =~ /^INSERT INTO cfg_views \(name,type,itil_type,ruled,global,cid,cid_ip,internal,live_metric,live_remote,sla\)/) {
		die "Duplicate entry" if (grep { $_->{cid} eq $b[4] && lc($_->{name}) eq lc($b[0]) } @{$t->{views}});
		push @{$t->{views}}, { id_cfg_view=>++$t->{seq_view}, name=>$b[0], type=>$b[1], itil_type=>$b[2], global=>$b[3], cid=>$b[4], cid_ip=>$b[5],
									  ruled=>0, live_metric=>0, sla=>0, nmetrics=>0, nsubviews=>0 };
		$t->{last_id}=$t->{seq_view}; }
	elsif ($q =~ /^DELETE FROM search_store2cfg_views2(metrics|remote_alerts) WHERE id_cfg_view=\?/) { push @{$t->{cleared}}, "$1:$b[0]"; }
	elsif ($q =~ /^INSERT INTO cfg_views2views/) { die "Duplicate entry" if (grep { $_->[0]==$b[0] && $_->[1]==$b[1] } @{$t->{v2v}||[]});
		push @{$t->{v2v}}, [ @b ]; }
	elsif ($q =~ /^INSERT IGNORE INTO cfg_user2view/) { push @{$t->{u2v}}, [ $b[0], $b[4], $b[1], $b[2], $b[3] ] if (! grep { $_->[0]==$b[0] && $_->[1] eq $b[4] } @{$t->{u2v}||[]}); }
	elsif ($q =~ /^UPDATE cfg_views SET nsubviews/) { $_->{nsubviews}=$b[0] foreach (grep { $_->{id_cfg_view}==$b[1] } @{$t->{views}}); }
	else { die "do not simulated: $q"; }
	return 1;
}
sub begin_work { $_[0]{saved}=Storable::dclone($_[0]{t}); }
sub commit     { }
sub rollback   { %{$_[0]{t}} = %{$_[0]{saved}}; }

#--- Fake engine ------------------------------------------------------------------
package FakeProv;
sub new { return bless { t=>$_[1], calls=>[] }, $_[0]; }
sub prov_do_set_device_metric {
my ($s,$in)=@_; my $t=$s->{t}; push @{$s->{calls}}, { %$in };
	if ($in->{init}==11) {
		my $f="$CNMControl::Kind::Device::TMP_WEB/$in->{file}";
		open(my $fh,'<',$f) or die "no CSV $f"; my @l=<$fh>; close $fh; unlink $f;
		chomp(my $h = shift @l); my @hd=split(/&\|&/,$h,-1);
		foreach (@l) { chomp; my @d=split(/&\|&/,$_,-1);
			push @{$t->{devices}}, { id_dev=>++$t->{seq_dev}, name=>$d[0], domain=>$d[1], ip=>$d[2], type=>$d[8] };
			$t->{custom}{$d[2]}{uc $hd[$_]} = ($d[$_] eq '' ? '-' : $d[$_]) for (15..$#hd); }
	}
	elsif ($in->{init}==1) {
		foreach my $id (split(/,/,$in->{id_dev})) {
			# Without fast the engine rebuilds the assistant: only what the device offers
			if (! $in->{fast}) { my ($d)=grep { $_->{id_dev}==$id } @{$t->{devices}};
				$t->{assist}{$id} = $t->{responds}{$d->{ip}} ? { disp_icmp=>1, mon_icmp=>1 } : {}; } foreach my $def (split(/,/,$in->{default})) {
			my (undef,undef,undef,$sub)=split(/\./,$def);
			push @{$t->{metrics}}, { id_metric=>++$t->{seq_met}, id_dev=>$id, name=>$sub, status=>'0', c_label=>undef }; } }
	}
}

#--- Test -------------------------------------------------------------------------
package main;
$CNMControl::Kind::Device::TMP_WEB = tempdir(CLEANUP=>1);

sub base {
	return { cfg_monitor=>{ disp_icmp=>60, mon_icmp=>300 }, types=>['Router'], fields=>['Proveedor','CNM-METRICS'],
		views=>[ { id_cfg_view=>162, name=>'Tiendas', live_metric=>0, cid=>'default', cid_ip=>'1.1.1.1', nmetrics=>0 } ],
		devices=>[ { id_dev=>12, name=>'tda-00', domain=>'local', ip=>'10.0.0.100', type=>'' } ],
		metrics=>[ { id_metric=>500, id_dev=>12, name=>'disp_icmp', status=>'0', c_label=>'viejo' } ],
		v2m=>[], seq_dev=>12, seq_met=>500, responds=>{ '10.0.0.1'=>1 } };
}
sub ctx { my $t=shift; my $p=FakeProv->new($t); return ({ dbh=>FakeDBH->new($t), cid=>'default', cache=>{}, pending=>{}, provision=>sub { $p },
										  local_ip=>sub { exists $t->{ip} ? $t->{ip} : '1.1.1.1' } }, $p); }
sub resources {
	my @r=();
	foreach my $d (['tda-00','10.0.0.100'],['tda-01','10.0.0.1'],['tda-02','10.0.0.2']) {
		push @r, { kind=>'view', name=>'Tiendas' },
					{ kind=>'device', name=>$d->[0], domain=>'local', ip=>$d->[1], ($d->[0] eq 'tda-01' ? (fields=>{ proveedor=>'ACME' }) : ()) },
					map { { kind=>'metric', device=>"$d->[0].local", subtype=>$_, c_label=>"$_ $d->[0]", views=>['Tiendas'] } } ('disp_icmp','mon_icmp');
	}
	return { version=>1, resources=>\@r };
}

my $t = base();
my ($bk,$err) = validate_state(resources());
is(scalar(@$err), 0, 'estado valido');
my ($c,$prov) = ctx($t);
my $pl = make_plan($c,$bk);
is(scalar(@{$pl->{errors}}), 0, 'plan sin errores') or diag(join("\n",@{$pl->{errors}}));
my %n=(); $n{"$_->{kind}.$_->{op}"}++ foreach (@{$pl->{actions}});
is_deeply(\%n, { 'device.create'=>2, 'metric.provision'=>5, 'metric.c_label'=>6, 'metric.view+'=>6 },
	'2 altas, 5 provisiones (tda-00 ya tiene disp_icmp), 6 titulos (uno cambia), 6 asociaciones');

my $e = apply_plan($c,$pl);
is(scalar(@$e), 0, 'apply sin errores') or diag(join("\n",@$e));
my @calls = @{$prov->{calls}};
is(scalar(grep { $_->{init}==11 } @calls), 1, 'una sola llamada de alta para todos');
my @p = grep { $_->{init}==1 } @calls;
is(scalar(@p), 2, 'dos llamadas de provision: un grupo por conjunto de subtipos');
ok((grep { $_->{id_dev} eq '13,14' && $_->{default} eq '1.60.latency.disp_icmp,1.300.latency.mon_icmp' && ! exists $_->{fast} } @p),
	'los dos nuevos juntos, con los dos subtipos y su lapse, y sin fast: el motor les calcula el asistente');
ok((grep { $_->{id_dev} eq '12' && $_->{default} eq '1.300.latency.mon_icmp' && $_->{fast}==1 } @p), 'el existente solo pide lo que le falta, con fast=1');
my @pa = grep { $_->{op} eq 'provision' } @{$pl->{actions}};
is(scalar(grep { $_->{text} =~ /\+ asistente$/ } @pa), 4, 'el plan avisa del asistente en las 4 provisiones de dispositivos nuevos');
is((grep { $_->{id_cfg_view}==162 } @{$t->{views}})[0]{nmetrics}, 6, 'contador de la vista actualizado');
like(join(' ',@{$pl->{warnings}}), qr/tda-00.*no tiene asistente calculado/, 'plan: el existente sin asistente da aviso');
my @aw = @{$c->{apply_warnings}||[]};
is(scalar(@aw), 2, 'tras aplicar: 2 avisos, las 2 metricas del nuevo que no responde');
ok(! grep({ /tda-01/ } @aw) && (grep({ /tda-02.local disp_icmp/ } @aw) == 1), '... de tda-02, no de tda-01 (que si responde)');
ok(! glob("$CNMControl::Kind::Device::TMP_WEB/*"), 'no queda el CSV del alta (ni su temporal)');
is_deeply($t->{custom}{'10.0.0.1'}, { PROVEEDOR=>'ACME' }, 'campo de usuario en el CSV del alta, con el nombre de devices_custom_types');
is_deeply($t->{custom}{'10.0.0.2'}, { PROVEEDOR=>'-' }, 'el otro alta del lote lleva el valor por defecto del motor');

my ($c2) = ctx($t);
my $pl2 = make_plan($c2,$bk);
is(scalar(@{$pl2->{actions}}), 0, 'el plan calculado otra vez sale vacio: ha convergido');
is(scalar(@{$pl2->{warnings}}), 0, '... y sin avisos: los campos de usuario guardados coinciden');

# Plan with errors: a conflicting IP; its metrics' errors are derived and the text says so
my $t4 = base();
my ($bk4) = validate_state({ version=>1, resources=>[
	{ kind=>'view', name=>'Tiendas' },
	{ kind=>'device', name=>'otro', domain=>'local', ip=>'10.0.0.100' },
	map { { kind=>'metric', device=>'otro.local', subtype=>$_, views=>['Tiendas'] } } ('disp_icmp','mon_icmp') ] });
my ($c4) = ctx($t4);
my $pl4 = make_plan($c4,$bk4);
is(scalar(@{$pl4->{errors}}).'+'.scalar(@{$pl4->{derived}}), '1+2', 'IP en conflicto: 1 error y 2 derivados');
my $tx = CNMControl::Core::plan_text($pl4);
like($tx, qr/^  NO SE PUEDE APLICAR: 1 error \(y 2 derivados de el\)/, 'el texto empieza diciendo que no se puede aplicar');
unlike($tx, qr/sin cambios\)/, '... no dice "(sin cambios)"');
like($tx, qr/2 errores mas, derivados de los anteriores; --verbose/, '... y agrupa los derivados');
like(CNMControl::Core::plan_text($pl4,1), qr/\(derivado\).*\n.*\(derivado\)/, 'con --verbose, los lista');

# Failure in the middle of the transaction: c_label and views are rolled back
my $t3 = base(); $t3->{fail_do}='INSERT IGNORE';
my ($c3) = ctx($t3);
my $e3 = apply_plan($c3, make_plan($c3,$bk));
like(join(' ',@$e3), qr/deshecho/, 'error en la transaccion: se informa');
is((grep { $_->{id_metric}==500 } @{$t3->{metrics}})[0]{c_label}, 'viejo', '... y el c_label vuelve a su valor');
is(scalar(@{$t3->{v2m}}), 0, '... y no queda ninguna asociacion');

#=== Views: create with a model view, parents (one of them new) and users =============
sub vbase {
	my $t = base();
	push @{$t->{views}}, { id_cfg_view=>170, name=>'Sedes', type=>'Sedes', itil_type=>1, global=>0, ruled=>0, live_metric=>0, sla=>0, cid=>'default', cid_ip=>'1.1.1.1', nsubviews=>1 },
								{ id_cfg_view=>171, name=>'Plantilla', type=>'Sedes', itil_type=>4, global=>1, ruled=>0, live_metric=>0, sla=>0, cid=>'default', cid_ip=>'1.1.1.1' },
								{ id_cfg_view=>172, name=>'Con reglas', type=>'Sedes', itil_type=>1, global=>0, ruled=>1, live_metric=>0, sla=>0, cid=>'default', cid_ip=>'1.1.1.1' };
	$t->{v2v} = [ [170,162,'default','1.1.1.1','default','1.1.1.1'] ];		# Sedes > Tiendas
	$t->{users} = [ { id_user=>1, login_name=>'admin' }, { id_user=>2, login_name=>'noc' }, { id_user=>3, login_name=>'operador1' } ];
	$t->{u2v} = [];
	$t->{view_types} = ['Sedes','General'];
	$t->{cnms} = [ ['default','1.1.1.1'] ];
	$t->{seq_view} = 200;
	return $t;
}
sub vstate { return { version=>1, resources=>[ @_ ] }; }
my @vres = (
	{ kind=>'view', name=>'Sede Madrid', create=>1, like=>'Plantilla', parents=>['Sedes','Sede Norte'], users=>['noc','OPERADOR1'] },
	{ kind=>'view', name=>'Sede Norte', create=>1, fields=>{ type=>'general' }, parents=>['Sedes'] },	# after its child
	{ kind=>'view', name=>'tiendas', users=>['noc'] },
	{ kind=>'view', name=>'Sede Madrid' },		# bare reference, as icmp-basic writes it
	{ kind=>'device', name=>'mad-01', domain=>'local', ip=>'10.0.1.1' },
	map { { kind=>'metric', device=>'mad-01.local', subtype=>$_, c_label=>"$_ mad-01", views=>['Sede Madrid'] } } ('disp_icmp','mon_icmp'),
);
my $tv = vbase();
my ($bkv,$errv) = validate_state(vstate(@vres));
is(scalar(@$errv), 0, 'vistas: estado valido; la referencia suelta se funde con la definicion') or diag(join("\n",@$errv));
my ($cv) = ctx($tv);
my $plv = make_plan($cv,$bkv);
is(scalar(@{$plv->{errors}})+scalar(@{$plv->{derived}}), 0, 'vistas: plan sin errores') or diag(join("\n",@{$plv->{errors}},map { "deriv: $_" } @{$plv->{derived}}));
%n=(); $n{"$_->{kind}.$_->{op}"}++ foreach (@{$plv->{actions}});
is_deeply(\%n, { 'view.create'=>2, 'view.parent+'=>3, 'view.user+'=>3, 'device.create'=>1, 'metric.provision'=>2, 'metric.c_label'=>2, 'metric.view+'=>2 },
	'2 vistas nuevas, 3 padres, 3 usuarios (uno en una vista que ya existe) y las metricas a la vista nueva');
my ($cr) = grep { $_->{op} eq 'create' && ($_->{name}//'') eq 'Sede Madrid' } @{$plv->{actions}};
is_deeply($cr->{fields}, { type=>'Sedes', itil_type=>4, global=>1 }, 'like: type, itil_type y global de la vista modelo');
($cr) = grep { $_->{op} eq 'create' && ($_->{name}//'') eq 'Sede Norte' } @{$plv->{actions}};
is_deeply($cr->{fields}, { type=>'General', itil_type=>1, global=>0 }, 'sin like: el tipo con el nombre de cfg_views_types, itil 1 y global 0');

$e = apply_plan($cv,$plv);
is(scalar(@$e), 0, 'vistas: apply sin errores') or diag(join("\n",@$e));
my %vw = map { $_->{name} => $_ } @{$tv->{views}};
ok($vw{'Sede Madrid'} && $vw{'Sede Norte'}, 'las dos vistas creadas');
is($vw{'Sede Madrid'}{cid_ip}, '1.1.1.1', 'con el cid_ip de /cfg/onm.if');
my %edge = map {; "$_->[0]>$_->[1]" => 1 } @{$tv->{v2v}};
my ($idm,$idn) = ($vw{'Sede Madrid'}{id_cfg_view}, $vw{'Sede Norte'}{id_cfg_view});
ok($edge{"170>$idm"} && $edge{"170>$idn"} && $edge{"$idn>$idm"}, 'enlaces: Sedes > Madrid, Sedes > Norte y Norte > Madrid (dos padres)');
is($vw{'Sedes'}{nsubviews}, 3, 'nsubviews del padre: Tiendas, Madrid y Norte');
is($vw{'Sede Norte'}{nsubviews}, 1, 'nsubviews de la vista nueva que es padre');
is_deeply([ sort map { "$_->[0]:$_->[1]" } @{$tv->{u2v}} ], [ sort ("$idm:noc", "$idm:operador1", "162:noc") ],
	'usuarios con su login_name de cfg_users (OPERADOR1 -> operador1)');
is(scalar(@{$tv->{cleared}}), 4, 'busquedas almacenadas limpiadas al crear, como save() de la consola');
is(scalar(grep { $_->[0]==$idm } @{$tv->{v2m}}), 2, 'las dos metricas en la vista creada en el mismo apply');
is($vw{'Sede Madrid'}{nmetrics}, 2, 'y su contador');
my ($cv2) = ctx($tv);
my $plv2 = make_plan($cv2,$bkv);
is(scalar(@{$plv2->{actions}}).'+'.scalar(@{$plv2->{errors}}), '0+0', 'vistas: el plan calculado otra vez sale vacio');

# Existing view with different fields: warning, no change
my ($bkw) = validate_state(vstate({ kind=>'view', name=>'Sedes', create=>1, fields=>{ type=>'General' } }));
my ($cw) = ctx($tv); my $plw = make_plan($cw,$bkw);
is(scalar(@{$plw->{actions}}), 0, 'vista existente con otro tipo: sin acciones');
like(join(' ',@{$plw->{warnings}}), qr/no se modifican sus campos; difiere: type 'Sedes' -> 'General'/, '... y aviso con la diferencia');

# Red cases: the plan is blocked and nothing is written
my @red = (
	[ 'ciclo con un enlace existente', {}, [ { kind=>'view', name=>'Sedes', parents=>['Tiendas'] } ], qr/ciclo.*'Tiendas'/ ],
	[ 'ciclo entre dos vistas nuevas', {}, [ { kind=>'view', name=>'A', create=>1, fields=>{type=>'Sedes'}, parents=>['B'] },
														 { kind=>'view', name=>'B', create=>1, fields=>{type=>'Sedes'}, parents=>['A'] } ], qr/ciclo/ ],
	[ 'padre inexistente', {}, [ { kind=>'view', name=>'A', create=>1, fields=>{type=>'Sedes'}, parents=>['Nada'] } ], qr/padre 'Nada' no existe/ ],
	[ 'usuario inexistente', {}, [ { kind=>'view', name=>'A', create=>1, fields=>{type=>'Sedes'}, users=>['nadie'] } ], qr/usuario 'nadie' no existe/ ],
	[ 'sin tipo', {}, [ { kind=>'view', name=>'A', create=>1 } ], qr/falta el tipo/ ],
	[ 'tipo inexistente', {}, [ { kind=>'view', name=>'A', create=>1, fields=>{type=>'Otro'} } ], qr/tipo de vista 'Otro' no existe/ ],
	[ 'modelo con reglas', {}, [ { kind=>'view', name=>'A', create=>1, like=>'Con reglas' } ], qr/con reglas o con SLA/ ],
	[ 'modelo inexistente', {}, [ { kind=>'view', name=>'A', create=>1, like=>'Nada' } ], qr/modelo 'Nada' no existe/ ],
	[ 'IP local distinta', { ip=>'2.2.2.2' }, [ { kind=>'view', name=>'A', create=>1, fields=>{type=>'Sedes'} } ], qr/\(2\.2\.2\.2\) no es el cid_ip.*\(1\.1\.1\.1\)/ ],
	[ 'sin IP local', { ip=>undef }, [ { kind=>'view', name=>'A', create=>1, fields=>{type=>'Sedes'} } ], qr/no se puede saber la IP/ ],
	[ 'sin fila en cfg_cnms', { cnms=>[] }, [ { kind=>'view', name=>'A', create=>1, fields=>{type=>'Sedes'} } ], qr/cfg_cnms no tiene/ ],
	[ 'cnm.cfg_cnms ilegible', { cnm_denied=>1 }, [ { kind=>'view', name=>'A', create=>1, fields=>{type=>'Sedes'} } ], qr/no se puede leer cnm\.cfg_cnms/ ],
	[ 'dos cid_ip', { extra_view=>1 }, [ { kind=>'view', name=>'A', create=>1, fields=>{type=>'Sedes'} } ], qr/mas de un cid_ip/ ],
);
foreach my $c (@red) {
	my ($name,$over,$res,$re) = @$c;
	my $tr = vbase(); $tr->{$_}=$over->{$_} foreach (grep { $_ ne 'extra_view' } keys %$over);
	push @{$tr->{views}}, { id_cfg_view=>180, name=>'Otra', type=>'Sedes', cid=>'default', cid_ip=>'3.3.3.3' } if ($over->{extra_view});
	my $before = Storable::dclone($tr);
	my ($bkr,$er0) = validate_state(vstate(@$res));
	my ($crr) = ctx($tr);
	my $plr = @$er0 ? { errors=>$er0, derived=>[], actions=>[] } : make_plan($crr,$bkr);
	like(join(' | ',@{$plr->{errors}}), $re, "rojo: $name");
	ok(CNMControl::Core::blocked($plr), "... bloquea el apply");
	is_deeply($tr, $before, "... y no ha escrito nada");
}
# Two views created with a wrong cid_ip: the second error is derived from the first
my $td = vbase(); $td->{ip}='2.2.2.2';
my ($bkd) = validate_state(vstate(map { { kind=>'view', name=>$_, create=>1, fields=>{type=>'Sedes'} } } ('A','B')));
my ($cd) = ctx($td); my $pld = make_plan($cd,$bkd);
is(scalar(@{$pld->{errors}}).'+'.scalar(@{$pld->{derived}}), '1+1', 'cid_ip: un error y el resto derivados');
# A metric to a view that cannot be created: derived
($bkd) = validate_state(vstate({ kind=>'view', name=>'A', create=>1 }, { kind=>'metric', device=>'tda-00.local', subtype=>'disp_icmp', views=>['A'] }));
($cd) = ctx(vbase()); $pld = make_plan($cd,$bkd);
like(join(' ',@{$pld->{errors}}), qr/falta el tipo/, 'vista que no se puede crear: su error');
like(join(' ',@{$pld->{derived}}), qr/vista 'A' no existe ni se crea/, '... y el de la metrica, derivado');
# Two full definitions that disagree
my (undef,$erm) = validate_state(vstate({ kind=>'view', name=>'A', create=>1, like=>'Plantilla' }, { kind=>'view', name=>'a', create=>1, like=>'Sedes' }));
like(join(' ',@$erm), qr/repetido con valores distintos: 'like' distinto/, 'dos definiciones con distinto like: error');
my ($bkm) = validate_state(vstate({ kind=>'view', name=>'A', create=>1, like=>'Plantilla', users=>['noc'] }, { kind=>'view', name=>'A', create=>1, like=>'Plantilla', users=>['admin'] }));
is_deeply($bkm->{view}[0]{users}, ['noc','admin'], 'dos definiciones iguales salvo usuarios: se juntan (modo aditivo)');

# Failure in the middle of the view transaction: nothing stays
my $tf = vbase(); $tf->{fail_do}='INSERT IGNORE INTO cfg_user2view';
my ($cf) = ctx($tf);
my $before = Storable::dclone($tf);
my $ef = apply_plan($cf, make_plan($cf,$bkv));
like(join(' ',@$ef), qr/vistas \(deshecho\)/, 'error en la transaccion de vistas: se informa');
is_deeply([ map { $_->{name} } @{$tf->{views}} ], [ map { $_->{name} } @{$before->{views}} ], '... no queda ninguna vista nueva');
is_deeply($tf->{v2v}, $before->{v2v}, '... ni ningun enlace');
ok(!(grep { $_->{ip} eq '10.0.1.1' } @{$tf->{devices}}), '... y no se ha seguido con los dispositivos');

# Messages name the view as written, not as its key
my ($bkl) = validate_state(vstate({ kind=>'view', name=>'Sede Rara', create=>1 }));
my ($cl) = ctx(vbase()); my $pll = make_plan($cl,$bkl);
like($pll->{errors}[0], qr/\(view Sede Rara\): falta el tipo/, 'el mensaje nombra la vista como se escribio');

done_testing();
