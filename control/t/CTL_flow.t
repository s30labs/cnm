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
	elsif ($q =~ /FROM cfg_views WHERE cid=\? AND name IN/)    { my $cid=shift @b; my %n=map{$_=>1}@b;
		@r = grep { $_->{cid} eq $cid && $n{$_->{name}} } @{$t->{views}}; }
	elsif ($q =~ /FROM devices WHERE ip IN/)                   { my %i=map{$_=>1}@b; @r = grep { $i{$_->{ip}} } @{$t->{devices}}; }
	elsif ($q =~ /FROM devices WHERE LOWER\(CONCAT/)           { my %i=map{$_=>1}@b; @r = grep { $i{lc "$_->{name}.$_->{domain}"} } @{$t->{devices}}; }
	elsif ($q =~ /FROM metrics WHERE id_dev IN \(([?,]+)\) AND name IN/) { my $n=($1=~tr/?//); my %d=map{$_=>1} _take(\@b,$n); my %m=map{$_=>1}@b;
		@r = grep { $d{$_->{id_dev}} && $m{$_->{name}} } @{$t->{metrics}}; }
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
	die "query not simulated: $q";
}
sub selectrow_array {
my ($s,$q,$attr,$v)=@_; my %u=map { $_->[1]=>1 } grep { $_->[0]==$v } @{$s->{t}{v2m}}; return scalar(keys %u);
}
sub do {
my ($s,$q,$attr,@b)=@_; my $t=$s->{t}; push @{$s->{log}}, $q;
	die "simulated failure" if ($t->{fail_do} && $q =~ /$t->{fail_do}/);
	if ($q =~ /^UPDATE metrics SET c_label/) { $_->{c_label}=$b[0] foreach (grep { $_->{id_metric}==$b[1] } @{$t->{metrics}}); }
	elsif ($q =~ /^INSERT IGNORE INTO cfg_views2metrics/) { push @{$t->{v2m}}, [ $b[0],$b[1],$b[2] ] if (! grep { $_->[0]==$b[0] && $_->[1]==$b[1] } @{$t->{v2m}}); }
	elsif ($q =~ /^UPDATE cfg_views SET nmetrics/) { $_->{nmetrics}=$b[0] foreach (grep { $_->{id_cfg_view}==$b[1] } @{$t->{views}}); }
	else { die "do not simulated: $q"; }
	return 1;
}
sub begin_work { $_[0]{saved}=Storable::dclone($_[0]{t}{metrics}); $_[0]{saved2}=Storable::dclone($_[0]{t}{v2m}); }
sub commit     { }
sub rollback   { $_[0]{t}{metrics}=$_[0]{saved}; $_[0]{t}{v2m}=$_[0]{saved2}; }

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
		foreach my $id (split(/,/,$in->{id_dev})) { foreach my $def (split(/,/,$in->{default})) {
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
		v2m=>[], seq_dev=>12, seq_met=>500 };
}
sub ctx { my $t=shift; my $p=FakeProv->new($t); return ({ dbh=>FakeDBH->new($t), cid=>'default', cache=>{}, pending=>{}, provision=>sub { $p } }, $p); }
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

done_testing();
