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
	elsif ($q =~ /SELECT id_cfg_view,name FROM cfg_views WHERE cid=\?/) { @r = map { [$_->{id_cfg_view},$_->{name}] } grep { $_->{cid} eq $b[0] } @{$t->{views}}; }
	elsif ($q =~ /SELECT id_cfg_view FROM cfg_views2views WHERE id_cfg_subview=\? AND cid_subview=\? FOR UPDATE/) { @r = map { [$_->[0]] } grep { $_->[1]==$b[0] } @{$t->{v2v}||[]}; }
	elsif ($q =~ /SELECT login_name FROM cfg_user2view WHERE id_cfg_view=\?/) { @r = map { [$_->[1]] } grep { $_->[0]==$b[0] } @{$t->{u2v}||[]}; }
	elsif ($q =~ /SELECT name FROM cfg_views_types/)           { @r = map { [$_] } @{$t->{view_types}||[]}; }
	elsif ($q =~ /FROM devices WHERE ip IN/)                   { my %i=map{$_=>1}@b; @r = grep { $i{$_->{ip}} } @{$t->{devices}}; }
	elsif ($q =~ /FROM devices WHERE LOWER\(name\) IN/)         { my %i=map{$_=>1}@b; @r = grep { $i{lc $_->{name}} } @{$t->{devices}}; }
	elsif ($q =~ /SELECT id_dev,name,c_label FROM metrics WHERE id_dev IN/) { my %i=map{$_=>1}@b;
		@r = map { [ $_->{id_dev}, $_->{name}, $_->{c_label} ] } grep { $i{$_->{id_dev}} && defined $_->{c_label} && $_->{c_label} ne '' } @{$t->{metrics}}; }
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
	if ($q =~ /SELECT ip,name,domain,type,critic,geodata,status,version,community FROM devices WHERE id_dev=\? FOR UPDATE/) { my ($d)=grep { $_->{id_dev}==$b[0] } @{$t->{devices}};
		return $d ? { map { $_=>$d->{$_} } qw(ip name domain type critic geodata status version community) } : undef; }
	if ($q =~ /SELECT \* FROM devices_custom_data WHERE id_dev=\? FOR UPDATE/) { my ($d)=grep { $_->{id_dev}==$b[0] } @{$t->{devices}};
		my $c=$t->{custom}{$d->{ip}} or return undef; my $n=0; my %col=map { uc($_) => 'columna'.++$n } @{$t->{fields}};
		return { id_dev=>$b[0], map { ($col{$_} => $c->{$_}) } keys %$c }; }
	if ($q =~ /SELECT type,itil_type,global FROM cfg_views WHERE id_cfg_view=\? AND cid=\? AND cid_ip=\? FOR UPDATE/) {
		my ($v)=grep { $_->{id_cfg_view}==$b[0] } @{$t->{views}}; return $v ? { map { $_=>$v->{$_} } qw(type itil_type global) } : undef; }
	if ($q =~ /SELECT name,domain,ip,version,community FROM devices WHERE id_dev=\?/) { my ($d)=grep { $_->{id_dev}==$b[0] } @{$t->{devices}};
		return $d ? { map { $_=>$d->{$_} } qw(name domain ip version community) } : undef; }
	if ($q =~ /SELECT id_cfg_view,cid,cid_ip FROM cfg_views WHERE id_cfg_view=\?/) { my ($v)=grep { $_->{id_cfg_view}==$b[0] } @{$t->{views}};
		return $v ? { map { $_=>$v->{$_} } qw(id_cfg_view cid cid_ip) } : undef; }
	if ($q =~ /FROM cfg_users WHERE login_name=\?/) { my ($u)=grep { lc($_->{login_name}) eq lc($b[0]) } @{$t->{users}||[]}; return $u ? {%$u} : undef; }
	if ($q =~ /SELECT id_cfg_view,cid,cid_ip FROM cfg_views WHERE cid=\? AND name=\?/) {
		my ($v)=grep { $_->{cid} eq $b[0] && lc($_->{name}) eq lc($b[1]) } @{$t->{views}}; return $v ? { map { $_=>$v->{$_} } qw(id_cfg_view cid cid_ip) } : undef; }
	die "query not simulated: $q";
}
sub selectrow_array {
my ($s,$q,$attr,@b)=@_; my $t=$s->{t}; my $v=$b[0];
	return ($t->{last_id}) if ($q =~ /LAST_INSERT_ID/);
	return (scalar(grep { $_->{ip} eq $b[0] } @{$t->{devices}})) if ($q =~ /^SELECT COUNT\(\*\) FROM devices WHERE ip=\?$/);
	return (scalar(grep { lc("$_->{name}.$_->{domain}") eq $b[0] && $_->{id_dev}!=$b[1] } @{$t->{devices}})) if ($q =~ /^SELECT COUNT\(\*\) FROM devices WHERE LOWER\(CONCAT\(name,'\.',domain\)\)=\? AND id_dev<>\?$/);
	return (scalar(keys %{$t->{assist}{$b[0]}||{}})) if ($q =~ /^SELECT COUNT\(\*\) FROM prov_default_metrics2device WHERE id_dev=\?$/);
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
	elsif ($q =~ /^DELETE FROM cfg_views2views WHERE id_cfg_view=\? AND id_cfg_subview=\?/) { $t->{v2v} = [ grep { !($_->[0]==$b[0] && $_->[1]==$b[1]) } @{$t->{v2v}||[]} ]; }
	elsif ($q =~ /^INSERT INTO cfg_views2views/) { die "Duplicate entry" if (grep { $_->[0]==$b[0] && $_->[1]==$b[1] } @{$t->{v2v}||[]});
		push @{$t->{v2v}}, [ @b ]; }
	elsif ($q =~ /^INSERT IGNORE INTO cfg_user2view/) { push @{$t->{u2v}}, [ $b[0], $b[4], $b[1], $b[2], $b[3] ] if (! grep { $_->[0]==$b[0] && $_->[1] eq $b[4] } @{$t->{u2v}||[]}); }
	elsif ($q =~ /^UPDATE cfg_views SET nsubviews/) { $_->{nsubviews}=$b[0] foreach (grep { $_->{id_cfg_view}==$b[1] } @{$t->{views}}); }
	elsif ($q =~ /^UPDATE devices SET (.+) WHERE id_dev=\?$/) { my @c = map { s/=\?//r } split(/,/,$1); my $id=pop @b;
		my ($d)=grep { $_->{id_dev}==$id } @{$t->{devices}}; @$d{@c}=@b; }
	elsif ($q =~ /^UPDATE (alerts|alerts_read) SET critic=\? WHERE id_device=\?$/) { $t->{alert_critic}{"$1:$b[1]"}=$b[0]; }
	elsif ($q =~ /^UPDATE (metrics|prov_template_metrics2iid) SET label=CONCAT\(LEFT\(label,CHAR_LENGTH\(label\)-CHAR_LENGTH\(\?\)\),\?\) WHERE id_dev=\? AND RIGHT\(label,CHAR_LENGTH\(\?\)\)=\?$/) {
		my ($o,$n,$id)=@b; my $l = ($1 eq 'metrics') ? $t->{metrics} : ($t->{tm2iid} ||= []);
		foreach my $m (grep { $_->{id_dev}==$id && defined $_->{label} && lc(substr($_->{label},-length($o))) eq lc($o) } @$l) { substr($m->{label},-length($o)) = $n; } }
	elsif ($q =~ /^UPDATE cfg_remote_alerts2device SET target=\? WHERE target=\?$/) { $_->[1]=$b[0] foreach (grep { $_->[1] eq $b[1] } @{$t->{remote}||[]}); }
	elsif ($q =~ /^UPDATE task2device SET ip=\? WHERE ip=\?$/) { $_->{ip}=$b[0] foreach (grep { $_->{ip} eq $b[1] } @{$t->{tasks}||[]}); }
	elsif ($q =~ /^INSERT IGNORE INTO devices_custom_data/) { my ($d)=grep { $_->{id_dev}==$b[0] } @{$t->{devices}}; $t->{custom}{$d->{ip}} ||= {}; }
	elsif ($q =~ /^UPDATE devices_custom_data SET (columna\d+)='-' WHERE id_dev=\? AND/) { my $c=$1; my ($d)=grep { $_->{id_dev}==$b[0] } @{$t->{devices}};
		my $n=0; my %name=map { ('columna'.++$n) => uc($_) } @{$t->{fields}}; my $h=$t->{custom}{$d->{ip}};
		$h->{$name{$c}}='-' if ((! defined $h->{$name{$c}}) || ($h->{$name{$c}} eq '')); }
	elsif ($q =~ /^UPDATE devices_custom_data SET (.+) WHERE id_dev=\?$/) { my @c = map { s/=\?//r } split(/,/,$1); my $id=pop @b;
		my ($d)=grep { $_->{id_dev}==$id } @{$t->{devices}}; my $n=0; my %name=map { ('columna'.++$n) => uc($_) } @{$t->{fields}};
		$t->{custom}{$d->{ip}}{$name{$c[$_]}}=$b[$_] for (0..$#c); }
	elsif ($q =~ /^UPDATE cfg_views SET (.+) WHERE id_cfg_view=\? AND cid=\? AND cid_ip=\?$/) { my @c = map { s/=\?//r } split(/,/,$1);
		my (undef,undef)=(pop @b, pop @b); my $id=pop @b; my ($v)=grep { $_->{id_cfg_view}==$id } @{$t->{views}}; @$v{@c}=@b; }
	else { die "do not simulated: $q"; }
	return 1;
}
sub begin_work { $_[0]{saved}=Storable::dclone($_[0]{t}); }
sub commit     { }
sub rollback   { %{$_[0]{t}} = %{$_[0]{saved}}; }

#--- Fake engine ------------------------------------------------------------------
package FakeStore;
sub new { return bless { t=>$_[1], lv=>'info' }, $_[0]; }
sub log_level { my ($s,$l)=@_; $s->{lv}=$l if (defined $l); return $s->{lv}; }
sub store_device_record { my ($s,$dbh,$ip)=@_; die "simulated record failure\n" if ($s->{t}{fail_record});
	push @{$s->{t}{records}}, "$ip:$s->{lv}"; }
sub set_graph_subtables { push @{$_[0]{t}{ws}}, 'subtables'; }
sub store_crawler_work { my ($s,$dbh,$id,$tnow,$cid)=@_;
	if ($s->{t}{fail_ws}) { $s->{err}=1146; $s->{errstr}='simulated work failure'; return undef; }
	push @{$s->{t}{ws}}, "work:$id:$cid"; return 1; }
sub consolidate_work_tables { push @{$_[0]{t}{ws}}, 'consolidate'; }
sub error    { return $_[0]{err} || 0; }
sub errorstr { return $_[0]{errstr} || ''; }
package FakeSNMP;
sub new { return bless { t=>$_[1] }, $_[0]; }
sub store { } sub dbh { }
sub snmp_mib2_system { my ($s,$d)=@_; push @{$s->{t}{mib2_asked}}, "$d->{host_ip}:v$d->{version}:".($d->{community} eq 'buena' ? 'ok' : 'otra');
	@$d{qw(sysdesc sysoid sysloc enterprise)} = (('** sin respuesta snmp **') x 3, 0);
	return (1,'Timeout') if ($d->{community} ne 'buena');
	@$d{qw(sysdesc sysoid sysloc enterprise mac mac_vendor network switch)} = ("Linux\nx86", '.1.3.6.1.4.1.8072', 'CPD', '8072', 'aa:bb:cc:dd:ee:ff:99', 'ACME', '10.0.0.0', 0);
	return (0, $d->{host_ip} eq '10.0.0.104' ? 'OKTimeout en partes de la MIB' : 'OK'); }
package FakeProv;
sub new { return bless { t=>$_[1], calls=>[], store=>FakeStore->new($_[1]), snmp=>FakeSNMP->new($_[1]) }, $_[0]; }
sub istore { return $_[0]{store}; }
sub get_check_vectors { push @{$_[0]{t}{asst}}, 'vectors'; }
sub reset_check_vectors { push @{$_[0]{t}{asst}}, 'reset'; }
# The assistant is computed with what the device is at that moment: what it offers at its IP
sub prov_device_app_metrics { my ($s,$id)=@_; my $t=$s->{t}; die "simulated assistant failure\n" if ($t->{fail_assist});
	my ($d)=grep { $_->{id_dev}==$id } @{$t->{devices}}; push @{$t->{asst}}, "app:$id:$d->{ip}:$d->{name}";
	$t->{assist}{$id} = $t->{responds}{$d->{ip}} ? { disp_icmp=>1, mon_icmp=>1 } : {}; }
sub snmp { return $_[0]{snmp}; }
sub prov_do_set_device_metric {
my ($s,$in)=@_; my $t=$s->{t}; push @{$s->{calls}}, { %$in };
	if ($in->{init}==11) {
		my $f="$CNMControl::Kind::Device::TMP_WEB/$in->{file}";
		open(my $fh,'<',$f) or die "no CSV $f"; my @l=<$fh>; close $fh; unlink $f;
		chomp(my $h = shift @l); my @hd=split(/&\|&/,$h,-1);
		foreach (@l) { chomp; my @d=split(/&\|&/,$_,-1);
			push @{$t->{devices}}, { id_dev=>++$t->{seq_dev}, name=>$d[0], domain=>$d[1], ip=>$d[2], type=>$d[8], critic=>$d[7], status=>$d[9], community=>$d[10], version=>$d[11] };
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

#=== Views: create with a model view, a parent (new or existing) and users ===========
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
	{ kind=>'view', name=>'Sede Madrid', create=>1, like=>'Plantilla', parent=>'Sede Norte', users=>['noc','OPERADOR1'] },	# its parent comes after
	{ kind=>'view', name=>'Sede Norte', create=>1, fields=>{ type=>'general' }, parent=>'Sedes' },
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
is_deeply(\%n, { 'view.create'=>2, 'view.parent+'=>2, 'view.user+'=>3, 'device.create'=>1, 'metric.provision'=>2, 'metric.c_label'=>2, 'metric.view+'=>2 },
	'2 vistas nuevas con su padre, 3 usuarios (uno en una vista que ya existe) y las metricas a la vista nueva');
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
ok($edge{"170>$idn"} && $edge{"$idn>$idm"} && (scalar(@{$tv->{v2v}})==3), 'enlaces: Sedes > Norte y Norte > Madrid (un padre cada una)');
is($vw{'Sedes'}{nsubviews}, 2, 'nsubviews del padre: Tiendas y Norte');
is($vw{'Sede Norte'}{nsubviews}, 1, 'nsubviews de la vista nueva que es padre');
is_deeply([ sort map { "$_->[0]:$_->[1]" } @{$tv->{u2v}} ], [ sort ("$idm:noc", "$idm:operador1", "162:noc") ],
	'usuarios con su login_name de cfg_users (OPERADOR1 -> operador1)');
is(scalar(@{$tv->{cleared}}), 4, 'busquedas almacenadas limpiadas al crear, como save() de la consola');
is(scalar(grep { $_->[0]==$idm } @{$tv->{v2m}}), 2, 'las dos metricas en la vista creada en el mismo apply');
is($vw{'Sede Madrid'}{nmetrics}, 2, 'y su contador');
my ($cv2) = ctx($tv);
my $plv2 = make_plan($cv2,$bkv);
is(scalar(@{$plv2->{actions}}).'+'.scalar(@{$plv2->{errors}}), '0+0', 'vistas: el plan calculado otra vez sale vacio');

# Existing view with different fields: update (modify, phase 1)
my ($bkw) = validate_state(vstate({ kind=>'view', name=>'Sedes', fields=>{ type=>'General', itil_type=>3 } }));
my ($cw) = ctx($tv); my $plw = make_plan($cw,$bkw);
is(join(',', map { "$_->{kind}.$_->{op}" } @{$plw->{actions}}), 'view.update', 'vista existente con otro tipo: una modificacion (sin "create")');
like($plw->{actions}[0]{text}, qr/"Sedes" itil_type '1' -> '3', type 'Sedes' -> 'General'/, '... con el valor anterior y el nuevo');
like(CNMControl::Core::plan_text($plw), qr/MODIFICA: view\.itil_type en 1, view\.type en 1/, '... y contada por atributo');
is(scalar(@{$plw->{warnings}}), 0, '... sin avisos');
my $before_v = Storable::dclone($tv);
my ($sedes) = grep { $_->{name} eq 'Sedes' } @{$tv->{views}};
$sedes->{type}='Otro tipo';		# someone changes it in the console between plan and apply
my $ew = apply_plan($cw,$plw);
like(join(' ',@$ew), qr/vista 'Sedes': type vale 'Otro tipo' y el plan esperaba 'Sedes'; ha cambiado desde el plan/, 'precondicion: cambio entre plan y apply -> error');
($sedes) = grep { $_->{name} eq 'Sedes' } @{$tv->{views}};
is($sedes->{itil_type}, 1, '... y no se escribe nada (itil_type sigue en 1)');
$sedes->{type}='Sedes';
($cw) = ctx($tv); $plw = make_plan($cw,$bkw);
is(scalar(@{apply_plan($cw,$plw)}), 0, 'vista: modificacion aplicada');
($sedes) = grep { $_->{name} eq 'Sedes' } @{$tv->{views}};
is("$sedes->{type}/$sedes->{itil_type}", 'General/3', '... type e itil_type nuevos');
ok((grep { $_ eq 'metrics:170' } @{$tv->{cleared}}), '... y busquedas almacenadas limpiadas, como save()');
($cw) = ctx($tv); is(scalar(@{make_plan($cw,$bkw)->{actions}}), 0, '... el plan calculado otra vez sale vacio');

# Red cases: the plan is blocked and nothing is written
my @red = (
	[ 'ciclo con un enlace existente', {}, [ { kind=>'view', name=>'Sedes', parent=>'Tiendas' } ], qr/ciclo.*'Tiendas'/ ],
	[ 'ciclo entre dos vistas nuevas', {}, [ { kind=>'view', name=>'A', create=>1, fields=>{type=>'Sedes'}, parent=>'B' },
														 { kind=>'view', name=>'B', create=>1, fields=>{type=>'Sedes'}, parent=>'A' } ], qr/ciclo/ ],
	[ 'padre inexistente', {}, [ { kind=>'view', name=>'A', create=>1, fields=>{type=>'Sedes'}, parent=>'Nada' } ], qr/padre 'Nada' no existe/ ],
	[ 'padre a una vista que ya tiene dos', { two_parents=>1 }, [ { kind=>'view', name=>'Tiendas', parent=>'Plantilla' } ], qr/tiene 2 padres \('Sedes', 'Plantilla'\): una vista tiene un solo padre/ ],
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
	my $tr = vbase(); $tr->{$_}=$over->{$_} foreach (grep { $_ ne 'extra_view' && $_ ne 'two_parents' } keys %$over);
	push @{$tr->{views}}, { id_cfg_view=>180, name=>'Otra', type=>'Sedes', cid=>'default', cid_ip=>'3.3.3.3' } if ($over->{extra_view});
	push @{$tr->{v2v}}, [171,162,'default','1.1.1.1','default','1.1.1.1'] if ($over->{two_parents});
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

#=== 0010: defaults only when creating; differences of an existing device ==================
my $tc = base(); $tc->{devices}[0]{critic}=75; $tc->{devices}[0]{version}=2; $tc->{devices}[0]{community}='secreta';
my ($bkc) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100' },
											 { kind=>'device', name=>'nuevo-01', domain=>'local', ip=>'10.0.9.1' }));
my ($cc) = ctx($tc); my $plc = make_plan($cc,$bkc);
is(scalar(@{$plc->{warnings}}), 0, 'existente sin critic ni snmp en el estado: ni aviso ni cambio (no se aplica el 50 por defecto)');
like($plc->{actions}[0]{text}, qr/snmp=v0$/, 'alta sin critic ni snmp: texto sin critic');
is(scalar(@{apply_plan($cc,$plc)}), 0, 'alta aplicada');
my ($nd) = grep { $_->{ip} eq '10.0.9.1' } @{$tc->{devices}};
is("$nd->{critic}/$nd->{version}/$nd->{community}", '50/0/', 'al crear: critic 50 y version 0 por defecto');
($bkc) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100', critic=>100, snmp=>{ version=>2, community=>'otra' } }));
($cc) = ctx($tc); $plc = make_plan($cc,$bkc);
is(scalar(@{$plc->{warnings}}), 0, 'existente con community distinta: sin avisos (fase 2: se modifica)');
unlike(join(' ',@{$plc->{warnings}}, map { $_->{text} } @{$plc->{actions}}), qr/secreta|otra/, '... sin escribir ninguna comunidad');
is(join(' ', map { $_->{text} } @{$plc->{actions}}), "tda-00.local community (cambia; no se muestra), critic '75' -> '100' (+ MIB-2) (+ workset) (+ critic de sus alertas) (+ recarga de traps)", '... community y critic: una modificacion, con MIB-2 y workset');

#=== Modify, phase 1: device type, critic, geodata and user fields ============================
my $tm = base(); $tm->{devices}[0]{critic}=50; $tm->{devices}[0]{geodata}=''; $tm->{custom}{'10.0.0.100'}={ PROVEEDOR=>'Viejo' };
$tm->{types}=['Router','Switch'];
my ($bkm2) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100', type=>'Switch', critic=>75,
												 geodata=>'40.4168,-3.7038', fields=>{ proveedor=>'Nuevo', 'CNM-METRICS'=>'x.json' } }));
my ($cm) = ctx($tm); my $plm = make_plan($cm,$bkm2);
is(join(',', map { "$_->{kind}.$_->{op}" } @{$plm->{actions}}), 'device.update', 'dispositivo existente con cambios: una modificacion');
like($plm->{actions}[0]{text}, qr/^tda-00\.local critic '50' -> '75', geodata '' -> '40\.4168,-3\.7038', type '' -> 'Switch', Proveedor 'Viejo' -> 'Nuevo', CNM-METRICS '-' -> 'x\.json' \(\+ critic de sus alertas\) \(\+ recarga de traps\)$/,
	'... cada cambio con su valor anterior (campo sin valor = -)');
like(CNMControl::Core::plan_text($plm), qr/MODIFICA: device\.CNM-METRICS en 1, device\.Proveedor en 1, device\.critic en 1, device\.geodata en 1, device\.type en 1/, '... contada por atributo');
my $tm_before = Storable::dclone($tm);
$tm->{custom}{'10.0.0.100'}{PROVEEDOR}='Tocado';		# changed in the console after the plan
my $em = apply_plan($cm,$plm);
like(join(' ',@$em), qr/dispositivos \(deshecho, no se ha modificado ninguno\): id_dev=12 \(10\.0\.0\.100\): Proveedor vale 'Tocado' y el plan esperaba 'Viejo'/,
	'precondicion de un campo de usuario: error');
is($tm->{devices}[0]{critic}, 50, '... y nada escrito (critic sigue en 50)');
ok(! $tm->{records}, '... ni ficha regenerada');
$tm->{custom}{'10.0.0.100'}{PROVEEDOR}='Viejo';
($cm) = ctx($tm); $plm = make_plan($cm,$bkm2);
is(scalar(@{apply_plan($cm,$plm)}), 0, 'modificacion aplicada');
is(join('/', @{$tm->{devices}[0]}{qw(type critic geodata)}), 'Switch/75/40.4168,-3.7038', '... devices: type, critic y geodata');
is_deeply($tm->{custom}{'10.0.0.100'}, { PROVEEDOR=>'Nuevo', 'CNM-METRICS'=>'x.json' }, '... campos de usuario');
is_deeply($tm->{records}, ['10.0.0.100:warning'], '... ficha regenerada por el motor, con el almacen en nivel warning (la comunidad no llega a engine.log)');
is($cm->{provision}->()->istore()->log_level(), 'info', '... y el nivel se restaura despues');
($cm) = ctx($tm); is(scalar(@{make_plan($cm,$bkm2)->{actions}}), 0, '... el plan calculado otra vez sale vacio');
# Precondition on a devices column
my $tp = base(); $tp->{devices}[0]{critic}=50;
my ($bkp) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100', critic=>75 }));
my ($cp) = ctx($tp); my $plp = make_plan($cp,$bkp);
$tp->{devices}[0]{critic}=25;
like(join(' ',@{apply_plan($cp,$plp)}), qr/critic vale '25' y el plan esperaba '50'/, 'precondicion de una columna de devices: error');
is($tp->{devices}[0]{critic}, 25, '... y no se escribe');
# A device without a row in devices_custom_data: the other columns get '-'
my $tz = base();
my ($bkz) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100', fields=>{ proveedor=>'ACME' } }));
my ($cz) = ctx($tz); is(scalar(@{apply_plan($cz, make_plan($cz,$bkz))}), 0, 'campo de usuario en un equipo sin fila de campos');
is_deeply($tz->{custom}{'10.0.0.100'}, { PROVEEDOR=>'ACME', 'CNM-METRICS'=>'-' }, "... la fila se crea y las demas columnas quedan en '-', como la consola");
# Undeclared attributes are not touched
my ($bkm3) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100' }));
($cm) = ctx($tm); is(scalar(@{make_plan($cm,$bkm3)->{actions}}), 0, 'sin atributos declarados: nada que modificar');
# Record failure: the data stays, warning
my $tr2 = base(); $tr2->{fail_record}=1;
my ($bkr2) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100', critic=>100 }));
my ($cr2) = ctx($tr2); my $plr2 = make_plan($cr2,$bkr2);
is(scalar(@{apply_plan($cr2,$plr2)}), 0, 'fallo al regenerar la ficha: no es error');
is($tr2->{devices}[0]{critic}, 100, '... el dato queda escrito');
like(join(' ',@{$cr2->{apply_warnings}||[]}), qr/modificado, pero no se ha regenerado su ficha/, '... y se avisa');
# geodata validation
my (undef,$eg) = validate_state(vstate({ kind=>'device', name=>'a', domain=>'b', ip=>'1.1.1.1', geodata=>'x' x 31 }));
like(join(' ',@$eg), qr/geodata" de mas de 30/, 'geodata de mas de 30 caracteres: rechazado');

#=== 0010: validation errors derived from an earlier kind of the same line ================
my (undef,$e10,$d10) = validate_state(vstate(
	{ kind=>'device', name=>'MAL:1.2.3.4', domain=>'local', ip=>'10.0.9.2', _origin=>'e.csv linea 3' },
	map { { kind=>'metric', device=>'MAL:1.2.3.4.local', subtype=>$_, _origin=>'e.csv linea 3' } } ('disp_icmp','mon_icmp')));
is(scalar(@$e10).'+'.scalar(@$d10), '1+2', 'nombre no valido: 1 error y 2 derivados (las metricas de la misma linea)');
like($e10->[0], qr/solo letras, cifras, _ y -.*separador del CSV/, '... el error explica la regla y sugiere el separador');
my (undef,$e11,$d11) = validate_state(vstate(
	{ kind=>'metric', device=>'x', subtype=>'disp_icmp', _origin=>'e.csv linea 4' },
	{ kind=>'device', name=>'ok', domain=>'local', ip=>'300.1.1.1', _origin=>'e.csv linea 5' }));
is(scalar(@$e11).'+'.scalar(@$d11), '2+0', 'errores de lineas distintas: no son derivados');

#=== Modify, phase 2: status and SNMP, with the work of workset ===========================
my $t2 = base(); @{$t2->{devices}[0]}{qw(status version community critic)} = (0, 2, 'secreta', 50);
push @{$t2->{devices}}, { id_dev=>13, name=>'tda-01', domain=>'local', ip=>'10.0.0.101', type=>'', critic=>50, status=>0, version=>0 };
my ($bk2) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100', status=>2, snmp=>{ version=>2, community=>'nueva' } },
										  { kind=>'device', name=>'tda-01', domain=>'local', ip=>'10.0.0.101', critic=>75 }));
my ($cw2) = ctx($t2); my $plw2 = make_plan($cw2,$bk2);
my %tx = map { $_->{ip} => $_->{text} } @{$plw2->{actions}};
is($tx{'10.0.0.100'}, "tda-00.local community (cambia; no se muestra), status '0' -> '2' (+ MIB-2) (+ workset) (+ recarga de traps)", 'status y community: modificacion con MIB-2 y workset');
is($tx{'10.0.0.101'}, "tda-01.local critic '50' -> '75' (+ critic de sus alertas) (+ recarga de traps)", 'solo critic: sin workset, con alertas y traps');
unlike(CNMControl::Core::plan_text($plw2), qr/secreta|nueva/, 'la comunidad no sale en el plan');
like(CNMControl::Core::plan_text($plw2), qr/MODIFICA: device\.community en 1, device\.critic en 1, device\.status en 1/, 'MODIFICA cuenta community sin su valor');
$t2->{devices}[0]{community}='tocada';		# changed after the plan
my $e2 = apply_plan($cw2,$plw2);
like(join(' ',@$e2), qr/id_dev=12 \(10\.0\.0\.100\): community ha cambiado desde el plan/, 'precondicion de la comunidad: error');
unlike(join(' ',@$e2), qr/tocada|secreta|nueva/, '... sin mostrar ningun valor');
ok(! $t2->{ws}, '... y sin regenerar nada');
$t2->{devices}[0]{community}='secreta';
($cw2) = ctx($t2); $plw2 = make_plan($cw2,$bk2);
is(scalar(@{apply_plan($cw2,$plw2)}), 0, 'status y SNMP: aplicado');
is(join('/', @{$t2->{devices}[0]}{qw(status version community)}), '2/2/nueva', '... devices: status, version y community');
is_deeply($t2->{ws}, [ 'subtables', 'work:12:default', 'consolidate' ], '... datos de los crawlers solo del dispositivo con status o SNMP, y una consolidacion');
($cw2) = ctx($t2); is(scalar(@{make_plan($cw2,$bk2)->{actions}}), 0, '... el plan calculado otra vez sale vacio');
# Regeneration fails: the data stays, and it is an error with the command to finish by hand
my $t3w = base(); $t3w->{fail_ws}=1;
my ($bk3w) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100', status=>1 }));
my ($c3w) = ctx($t3w); my $e3w = apply_plan($c3w, make_plan($c3w,$bk3w));
like(join(' ',@$e3w), qr/no se han regenerado los datos de los crawlers \(store_crawler_work id_dev=12: simulated work failure\)\. Ejecutar: \/opt\/crawler\/bin\/workset -c default -i 12/,
	'fallo al regenerar: error con la orden para terminarlo a mano');
is($t3w->{devices}[0]{status}, 1, '... y el estado queda escrito');
# SNMPv3 device: its SNMP is not touched
my $tv3 = base(); @{$tv3->{devices}[0]}{qw(version community)} = (3, '7');
my ($bkv3) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100', snmp=>{ version=>2, community=>'x' } }));
my ($cv3) = ctx($tv3); my $plv3 = make_plan($cv3,$bkv3);
like(join(' ',@{$plv3->{errors}}), qr/tiene SNMPv3 .*no se modifica en esta fase/, 'dispositivo SNMPv3: error');
is(scalar(@{$plv3->{actions}}), 0, '... sin acciones');
# Empty SNMP from a profile declares nothing; a community without a version is an error
my ($bk5) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100', snmp=>{} }));
ok(! exists $bk5->{device}[0]{snmp}, 'snmp {} (celdas vacias): no declara nada');
my (undef,$e5) = validate_state(vstate({ kind=>'device', name=>'a', domain=>'b', ip=>'1.1.1.1', snmp=>{ community=>'x' } }));
like(join(' ',@$e5), qr/snmp\.version obligatoria/, 'community sin version: error (no se supone version 0)');
# Status when creating
my $t6 = base();
my ($bk6) = validate_state(vstate({ kind=>'device', name=>'nuevo-02', domain=>'local', ip=>'10.0.9.3', status=>2 }));
my ($c6) = ctx($t6); my $pl6 = make_plan($c6,$bk6);
like($pl6->{actions}[0]{text}, qr/status=2/, 'alta con status: en el plan');
is(scalar(@{apply_plan($c6,$pl6)}), 0, '... aplicada');
my ($n6) = grep { $_->{ip} eq '10.0.9.3' } @{$t6->{devices}};
is($n6->{status}, 2, '... con el status en el CSV del motor');

#=== MIB-2 when SNMP changes (0013) ==========================================================
my $tmb = base(); @{$tmb->{devices}[0]}{qw(version community sysdesc mac)} = (2, 'vieja', 'antes', '00:00:00:00:00:00');
push @{$tmb->{devices}}, { id_dev=>13, name=>'tda-01', domain=>'local', ip=>'10.0.0.101', type=>'', version=>2, community=>'vieja', sysdesc=>'antes', status=>0 },
								 { id_dev=>14, name=>'tda-02', domain=>'local', ip=>'10.0.0.102', type=>'', version=>2, community=>'vieja', sysdesc=>'antes', status=>0 },
								 { id_dev=>15, name=>'tda-03', domain=>'local', ip=>'10.0.0.103', type=>'', version=>2, community=>'vieja', sysdesc=>'antes', status=>0 };
my ($bkmb) = validate_state(vstate(
	{ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100', snmp=>{ version=>2, community=>'buena' } },
	{ kind=>'device', name=>'tda-01', domain=>'local', ip=>'10.0.0.101', snmp=>{ version=>2, community=>'mala' } },
	{ kind=>'device', name=>'tda-02', domain=>'local', ip=>'10.0.0.102', snmp=>{ version=>0 } },
	{ kind=>'device', name=>'tda-03', domain=>'local', ip=>'10.0.0.103', status=>2 }));
my ($cmb) = ctx($tmb); my $plmb = make_plan($cmb,$bkmb);
my %mt = map { $_->{ip} => $_->{text} } @{$plmb->{actions}};
like($mt{'10.0.0.103'}, qr/status '0' -> '2' \(\+ workset\) \(\+ recarga de traps\)$/, 'solo status: sin MIB-2');
is(scalar(@{apply_plan($cmb,$plmb)}), 0, 'SNMP cambiado en tres equipos: aplicado');
is_deeply([ sort @{$tmb->{mib2_asked}} ], [ '10.0.0.100:v2:ok', '10.0.0.101:v2:otra' ], 'MIB-2 preguntada con la comunidad nueva, solo a los equipos con version 1 o 2');
my %dv = map { $_->{ip} => $_ } @{$tmb->{devices}};
is(join('|', @{$dv{'10.0.0.100'}}{qw(sysdesc sysoid sysloc enterprise mac mac_vendor network switch)}), 'Linux x86|.1.3.6.1.4.1.8072|CPD|8072|aa:bb:cc:dd:ee:ff|ACME|10.0.0.0|0',
	'responde: columnas de store_device (sysdesc sin saltos, mac a 17)');
is(join('|', @{$dv{'10.0.0.101'}}{qw(sysdesc sysoid sysloc enterprise)}), '** sin respuesta snmp **|** sin respuesta snmp **|** sin respuesta snmp **|0', 'no responde: los valores del motor');
like(join(' ',@{$cmb->{apply_warnings}}), qr/device 10\.0\.0\.101: no responde por SNMP con los datos nuevos \(Timeout\)/, '... y aviso');
unlike(join(' ',@{$cmb->{apply_warnings}}), qr/10\.0\.0\.10[02]/, 'sin aviso para el que responde ni para version 0');
is($dv{'10.0.0.102'}{sysdesc}, '** sin respuesta snmp **', 'version 0: sin preguntar, los valores del motor');
is($dv{'10.0.0.103'}{sysdesc}, 'antes', 'solo status: MIB-2 sin tocar');
# A part of the MIB that does not answer in time: warning; a plain 'OK': none
push @{$tmb->{devices}}, { id_dev=>16, name=>'tda-04', domain=>'local', ip=>'10.0.0.104', type=>'', version=>2, community=>'vieja', status=>0 };
($bkmb) = validate_state(vstate({ kind=>'device', name=>'tda-04', domain=>'local', ip=>'10.0.0.104', snmp=>{ version=>2, community=>'buena' } }));
($cmb) = ctx($tmb); is(scalar(@{apply_plan($cmb, make_plan($cmb,$bkmb))}), 0, 'MIB-2 con una parte sin respuesta: aplicado');
like(join(' ',@{$cmb->{apply_warnings}||[]}), qr/device 10\.0\.0\.104: MIB-2 incompleta: OKTimeout en partes de la MIB/, '... y aviso de MIB-2 incompleta');

#=== One parent: move, two parents, precondition (0015) ======================================
my $tmv = vbase();		# Sedes(170) > Tiendas(162); Plantilla(171) without parent
my ($bkmv) = validate_state(vstate({ kind=>'view', name=>'Tiendas', parent=>'Plantilla' }));
my ($cmv) = ctx($tmv); my $plmv = make_plan($cmv,$bkmv);
is(join(' ', map { "$_->{op}: $_->{text}" } @{$plmv->{actions}}), 'move: "Tiendas" padre "Sedes" -> "Plantilla"', 'otro padre: se mueve la vista');
is(scalar(@{apply_plan($cmv,$plmv)}), 0, '... aplicado');
is_deeply([ map { "$_->[0]>$_->[1]" } @{$tmv->{v2v}} ], [ '171>162' ], '... el enlace viejo se borra y queda uno');
my %vmv = map { $_->{name} => $_ } @{$tmv->{views}};
is("$vmv{Sedes}{nsubviews}/$vmv{Plantilla}{nsubviews}", '0/1', '... y los contadores de los dos padres');
($cmv) = ctx($tmv); is(scalar(@{make_plan($cmv,$bkmv)->{actions}}), 0, '... el plan calculado otra vez sale vacio');
# A move replaces the old link also for the cycle check: Sedes > Tiendas becomes
# Plantilla > Tiendas > Sedes, which is not a cycle
my ($bkcy) = validate_state(vstate({ kind=>'view', name=>'Tiendas', parent=>'Plantilla' }, { kind=>'view', name=>'Sedes', parent=>'Tiendas' }));
my ($ccy) = ctx(vbase()); my $plcy = make_plan($ccy,$bkcy);
is(scalar(@{$plcy->{errors}}), 0, 'mover e invertir padre e hija en el mismo estado: no es un ciclo') or diag(join(' ',@{$plcy->{errors}}));
is(join(',', sort map { $_->{op} } @{$plcy->{actions}}), 'move,parent+', '... mover Tiendas y dar padre a Sedes');
# Same parent: nothing
($bkmv) = validate_state(vstate({ kind=>'view', name=>'Tiendas', parent=>'plantilla' }));
($cmv) = ctx($tmv); is(scalar(@{make_plan($cmv,$bkmv)->{actions}}), 0, 'mismo padre (sin distinguir mayusculas): nada');
# Precondition: the parents change between plan and apply
($bkmv) = validate_state(vstate({ kind=>'view', name=>'Tiendas', parent=>'Sedes' }));
($cmv) = ctx($tmv); $plmv = make_plan($cmv,$bkmv);
push @{$tmv->{v2v}}, [170,162,'default','1.1.1.1','default','1.1.1.1'];		# someone links it in the console
like(join(' ',@{apply_plan($cmv,$plmv)}), qr/vista 'Tiendas': sus padres han cambiado desde el plan/, 'precondicion de los padres: error');
is(scalar(grep { $_->[1]==162 } @{$tmv->{v2v}}), 2, '... y no se toca nada');
# A view with two parents: warning without "parent"; error with it (red cases above)
my ($bk2p) = validate_state(vstate({ kind=>'view', name=>'Tiendas', users=>['noc'] }));
my ($c2p) = ctx($tmv); my $pl2p = make_plan($c2p,$bk2p);
like(join(' ',@{$pl2p->{warnings}}), qr/tiene 2 padres \('Sedes', 'Plantilla'\)/, 'vista con dos padres sin "parent": aviso');
is(scalar(@{$pl2p->{errors}}), 0, '... sin error');
# "parents" is not accepted any more; "parent" must agree in two definitions
my (undef,$ep) = validate_state(vstate({ kind=>'view', name=>'A', parents=>['B'] }));
like(join(' ',@$ep), qr/"parents" ya no se admite: una vista tiene un solo padre; usar "parent"/, '"parents": error que explica el cambio');
my (undef,$ep2) = validate_state(vstate({ kind=>'view', name=>'A', parent=>'B' }, { kind=>'view', name=>'A', parent=>'C' }));
like(join(' ',@$ep2), qr/'parent' distinto en las dos definiciones/, 'dos definiciones con distinto padre: error');


#=== 0016: the default domain only when creating ==============================================
my $tdd = base(); $tdd->{devices}[0]{domain}='es.local'; $tdd->{devices}[0]{critic}=50;
my @rdd = ({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100', critic=>75, _domain_default=>1, _origin=>'d.csv linea 2' },
			  { kind=>'metric', device=>'tda-00.local', subtype=>'disp_icmp', c_label=>'nuevo', _origin=>'d.csv linea 2' });
my ($bkdd,$edd) = validate_state(vstate(@rdd));
is(scalar(@$edd), 0, '_domain_default: admitido por la validacion');
my ($cdd) = ctx($tdd); my $pldd = make_plan($cdd,$bkdd);
is(scalar(@{$pldd->{errors}}).'+'.scalar(@{$pldd->{derived}}), '0+0', 'IP y nombre existentes en otro dominio, dominio por defecto: sin errores')
	or diag(join(' ',@{$pldd->{errors}},@{$pldd->{derived}}));
is(join(' | ', map { $_->{text} } @{$pldd->{actions}}), "tda-00.es.local critic '50' -> '75' (+ critic de sus alertas) (+ recarga de traps) | tda-00.es.local disp_icmp: \"viejo\" -> \"nuevo\"",
	'... se modifica el equipo con su dominio, y la metrica lo encuentra');
is(scalar(@{apply_plan($cdd,$pldd)}), 0, '... aplicado');
is("$tdd->{devices}[0]{critic}/$tdd->{devices}[0]{domain}/$tdd->{metrics}[0]{c_label}", '75/es.local/nuevo', '... critic y c_label escritos; el dominio no cambia');
# Without the mark (domain written in the CSV): conflict, as before
delete $rdd[0]{_domain_default};
my ($bkd2) = validate_state(vstate(@rdd)); my ($cd2) = ctx(base()); $cd2->{dbh}{t}{devices}[0]{domain}='es.local';
like(join(' ',@{make_plan($cd2,$bkd2)->{errors}}), qr/la IP ya es de tda-00\.es\.local/, 'dominio escrito en el CSV y distinto: conflicto, como antes');
# A different name with the default domain: still a conflict
my ($bkd3) = validate_state(vstate({ kind=>'device', name=>'otro', domain=>'local', ip=>'10.0.0.100', _domain_default=>1 }));
my ($cd3) = ctx(base());
like(join(' ',@{make_plan($cd3,$bkd3)->{errors}}), qr/la IP ya es de tda-00\.local/, 'nombre distinto con dominio por defecto: conflicto');

#=== 0018: critic of the alerts and reload of trap_manager, as the device screen =============
my $RF = "$CNMControl::Kind::Device::TMP_WEB/syslog.reload";
sub reload_text { return (-e $RF) ? do { open(my $h,'<',$RF); local $/; <$h> } : undef; }
my $ta = base(); @{$ta->{devices}[0]}{qw(critic status)} = (50, 0);
push @{$ta->{devices}}, { id_dev=>13, name=>'tda-01', domain=>'local', ip=>'10.0.0.101', type=>'', critic=>50, status=>0, geodata=>'' };
unlink $RF;
my ($bka) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.100', critic=>75 }));
my ($ca) = ctx($ta); my $pla = make_plan($ca,$bka);
is(scalar(@{apply_plan($ca,$pla)}), 0, 'critic: aplicado');
is_deeply($ta->{alert_critic}, { 'alerts:12'=>75, 'alerts_read:12'=>75 }, '... el critic nuevo en alerts y alerts_read, solo de ese equipo');
is(reload_text(), '1', "... y se pide la recarga del gestor de traps ('1' en syslog.reload)");
# status only: reload, no alerts; written after another '1' (append, as the console)
my ($bks) = validate_state(vstate({ kind=>'device', name=>'tda-01', domain=>'local', ip=>'10.0.0.101', status=>2 }));
delete $ta->{alert_critic};
my ($cs) = ctx($ta); my $pls = make_plan($cs,$bks);
is(scalar(@{apply_plan($cs,$pls)}), 0, 'status: aplicado');
ok(! $ta->{alert_critic}, '... sin tocar las alertas');
is(reload_text(), '11', '... recarga pedida otra vez, anadiendo al fichero');
# Other attributes: neither
unlink $RF;
my ($bko) = validate_state(vstate({ kind=>'device', name=>'tda-01', domain=>'local', ip=>'10.0.0.101', geodata=>'1,2', fields=>{ proveedor=>'X' } }));
my ($co) = ctx($ta); my $plo = make_plan($co,$bko);
unlike($plo->{actions}[0]{text}, qr/alertas|traps/, 'geodata y campo de usuario: el plan no anuncia ni alertas ni traps');
is(scalar(@{apply_plan($co,$plo)}), 0, '... aplicado');
ok((! $ta->{alert_critic}) && (! -e $RF), '... sin tocar alertas ni pedir recarga');
# The alerts go in the transaction: if they fail, nothing is written and no reload is asked
my $tf = base(); $tf->{devices}[0]{critic}=50; $tf->{fail_do}='^UPDATE alerts_read';
my ($cf) = ctx($tf); my $plf = make_plan($cf,$bka);
like(join(' ',@{apply_plan($cf,$plf)}), qr/deshecho, no se ha modificado ninguno.*simulated failure/, 'fallo en alerts_read: error');
is($tf->{devices}[0]{critic}, 50, '... devices.critic sin cambiar');
ok((! $tf->{alert_critic}) && (! -e $RF), '... ni alertas ni recarga');
# The reload file cannot be written: error with the command; the data stays
my $tw = base(); $tw->{devices}[0]{critic}=50;
{	local $CNMControl::Kind::Device::RELOAD = 'no/existe/syslog.reload';
	my ($cw) = ctx($tw); my $ew = apply_plan($cw, make_plan($cw,$bka));
	like(join(' ',@$ew), qr/no se ha pedido la recarga del gestor de traps .*Ejecutar: echo 1 >> \S+no\/existe\/syslog\.reload/, 'recarga imposible: error con la orden');
	is($tw->{devices}[0]{critic}, 75, '... y el dato queda escrito');
}
unlink $RF;

#=== 0019: phase 3, name, domain or IP of a device ==========================================
sub ibase {
	my $t = base(); $RF = "$CNMControl::Kind::Device::TMP_WEB/syslog.reload"; unlink $RF;
	@{$t->{devices}[0]}{qw(critic status version geodata)} = (50, 0, 0, '');
	$t->{metrics}[0]{label} = 'Disponibilidad (tda-00.local)'; $t->{metrics}[0]{c_label} = 'Disp tda-00 y 10.0.0.100';
	$t->{tm2iid} = [ { id_dev=>12, label=>'Disponibilidad (tda-00.local)' }, { id_dev=>12, label=>'Otra (tda-00.local) fin' } ];
	$t->{remote} = [ [ 7, '10.0.0.100' ], [ 8, '10.9.9.9' ] ];
	$t->{tasks}  = [ { name=>'t1', ip=>'10.0.0.100' }, { name=>'t2', ip=>'10.9.9.9' } ];
	$t->{responds} = { '10.0.0.100'=>1, '10.0.0.150'=>1 };
	return $t;
}
# Rename
my $ti = ibase();
my ($bki,$ei) = validate_state(vstate({ kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.0.100', from=>{ name=>'tda-00' } },
	{ kind=>'metric', device=>'tda-10.local', subtype=>'mon_icmp' }));
is(scalar(@$ei), 0, 'renombrar: estado valido');
my ($ci) = ctx($ti); my $pli = make_plan($ci,$bki);
is(scalar(@{$pli->{errors}}), 0, '... plan sin errores') or diag(join("\n",@{$pli->{errors}}));
is(join(' | ', map { "$_->{op}: $_->{text}" } @{$pli->{actions}}),
	'rename: tda-00.local -> tda-10.local (+ etiquetas de sus metricas) (+ asistente) (+ recarga de traps) | provision: tda-10.local mon_icmp (lapse 300)',
	'... una accion rename y la metrica del nombre nuevo encuentra el equipo');
like(join(' ',@{$pli->{warnings}}), qr/1 metricas con 'tda-00' en el titulo, que no se cambia: disp_icmp "Disp tda-00 y 10\.0\.0\.100"\. Para cambiarlo: columna c_label/,
	'... aviso de los titulos con el nombre anterior');
like(CNMControl::Core::plan_text($pli), qr/MODIFICA: device\.name en 1/, '... MODIFICA cuenta el nombre');
is(scalar(@{apply_plan($ci,$pli)}), 0, '... aplicado') or diag(join("\n",@{apply_plan($ci,$pli)}));
is("$ti->{devices}[0]{name}.$ti->{devices}[0]{domain} $ti->{devices}[0]{ip}", 'tda-10.local 10.0.0.100', '... devices: el nombre nuevo, la misma IP');
is($ti->{metrics}[0]{label}, 'Disponibilidad (tda-10.local)', '... el sufijo de la etiqueta de la metrica');
is(join(' | ', map { $_->{label} } @{$ti->{tm2iid}}), 'Disponibilidad (tda-10.local) | Otra (tda-00.local) fin', '... y el de la plantilla, solo al final');
is($ti->{metrics}[0]{c_label}, 'Disp tda-00 y 10.0.0.100', '... el titulo no se toca');
is_deeply($ti->{asst}, [ 'vectors', 'reset', 'app:12:10.0.0.100:tda-10' ], '... asistente recalculado despues del cambio, con el nombre nuevo');
ok(! $ti->{ws}, '... sin workset (renombrar no lo pide, como la consola)');
is(reload_text(), '1', '... recarga del gestor de traps');
is_deeply($ti->{records}, [ '10.0.0.100:warning' ], '... ficha regenerada');
is(join(',', map { $_->{name} } grep { $_->{id_dev}==12 } @{$ti->{metrics}}), 'disp_icmp,mon_icmp', '... la metrica del estado, provisionada en el mismo equipo');
($ci) = ctx($ti); my $pli2 = make_plan($ci,$bki);
is(scalar(@{$pli2->{actions}}).'/'.scalar(@{$pli2->{errors}}).'/'.scalar(@{$pli2->{warnings}}), '0/0/0', '... el plan calculado otra vez sale vacio, sin errores ni avisos');
# IP change, with a metric that uses the new IP
my $tp3 = ibase();
my ($bkp3) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.150', from=>{ ip=>'10.0.0.100' } },
	{ kind=>'metric', device=>'10.0.0.150', subtype=>'disp_icmp', c_label=>'Disp nueva' }));
my ($cp3) = ctx($tp3); my $plp3 = make_plan($cp3,$bkp3);
is(scalar(@{$plp3->{errors}}), 0, 'cambio de IP: plan sin errores') or diag(join("\n",@{$plp3->{errors}}));
is($plp3->{actions}[0]{op}.': '.$plp3->{actions}[0]{text},
	"ip: tda-00.local ip '10.0.0.100' -> '10.0.0.150' (+ alertas remotas y tareas) (+ MIB-2) (+ workset) (+ asistente) (+ recarga de traps)", '... una accion ip, con todo lo que hace la consola');
like(join(' ',@{$plp3->{warnings}}), qr/1 metricas con '10\.0\.0\.100' en el titulo/, '... aviso de los titulos con la IP anterior');
like(CNMControl::Core::plan_text($plp3), qr/MODIFICA: device\.ip en 1, metric\.c_label en 1/, '... MODIFICA cuenta la IP y el titulo que cambia');
is(scalar(@{apply_plan($cp3,$plp3)}), 0, '... aplicado');
is($tp3->{devices}[0]{ip}, '10.0.0.150', '... devices: la IP nueva');
is(join(' ', map { "$_->[0]:$_->[1]" } @{$tp3->{remote}}), '7:10.0.0.150 8:10.9.9.9', '... alertas remotas de la IP anterior, a la nueva');
is(join(' ', map { "$_->{name}:$_->{ip}" } @{$tp3->{tasks}}), 't1:10.0.0.150 t2:10.9.9.9', '... y tareas');
is_deeply($tp3->{ws}, [ 'subtables', 'work:12:default', 'consolidate' ], '... workset');
is($tp3->{devices}[0]{sysdesc}, '** sin respuesta snmp **', '... MIB-2 escrita (sin SNMP: lo que deja el motor)');
is_deeply($tp3->{asst}, [ 'vectors', 'reset', 'app:12:10.0.0.150:tda-00' ], '... asistente con la IP nueva');
is_deeply($tp3->{records}, [ '10.0.0.150:warning' ], '... ficha de la IP nueva');
is($tp3->{metrics}[0]{c_label}, 'Disp nueva', '... la metrica de la IP nueva encuentra el equipo');
is($tp3->{metrics}[0]{label}, 'Disponibilidad (tda-00.local)', '... la etiqueta no cambia (no cambia el nombre)');
($cp3) = ctx($tp3); my $plp3b = make_plan($cp3,$bkp3);
is(scalar(@{$plp3b->{actions}}).'/'.scalar(@{$plp3b->{errors}}), '0/0', '... el plan calculado otra vez sale vacio y sin errores (ya hecho)');
# A metric with the old IP or the old name: error
my ($bkg) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.150', from=>{ ip=>'10.0.0.100' } },
	{ kind=>'metric', device=>'10.0.0.100', subtype=>'disp_icmp', c_label=>'x' }));
my ($cg) = ctx(ibase());
like(join(' ',@{make_plan($cg,$bkg)->{errors}}), qr/el dispositivo '10\.0\.0\.100' pasa a ser '10\.0\.0\.150' en este estado/, 'metrica con la IP anterior: error');
($bkg) = validate_state(vstate({ kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.0.100', from=>{ name=>'tda-00' } },
	{ kind=>'metric', device=>'tda-00.local', subtype=>'disp_icmp', c_label=>'x' }));
($cg) = ctx(ibase());
like(join(' ',@{make_plan($cg,$bkg)->{errors}}), qr/el dispositivo 'tda-00\.local' pasa a ser 'tda-10\.local'/, 'metrica con el nombre anterior: error');
# Conflicts
sub iplan { my ($t,@r)=@_; my ($bk,$e) = validate_state(vstate(@r)); return { errors=>$e } if (@$e); my ($c) = ctx($t); return make_plan($c,$bk); }
my $tx2 = ibase(); push @{$tx2->{devices}}, { id_dev=>13, name=>'tda-10', domain=>'local', ip=>'10.0.0.150', type=>'' };
like(join(' ',@{iplan($tx2, { kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.150', from=>{ ip=>'10.0.0.100' } })->{errors}}),
	qr/la IP nueva 10\.0\.0\.150 ya es de tda-10\.local \(id_dev=13\)/, 'IP nueva ocupada: error');
like(join(' ',@{iplan($tx2, { kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.0.100', from=>{ name=>'tda-00' } })->{errors}}),
	qr/el nombre nuevo tda-10\.local ya lo usa la IP 10\.0\.0\.150 \(id_dev=13\)/, 'nombre nuevo ocupado: error');
like(join(' ',@{iplan(ibase(), { kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.0.100', from=>{ name=>'otro' } })->{errors}}),
	qr/la IP 10\.0\.0\.100 es de tda-00\.local \(id_dev=12\), no de otro\.local/, 'nombre anterior que no es el del equipo: error');
like(join(' ',@{iplan(ibase(), { kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.150', from=>{ ip=>'10.0.0.99' } })->{errors}}),
	qr/no hay ningun dispositivo con la IP 10\.0\.0\.99 \(ni con la nueva, 10\.0\.0\.150\)/, 'IP anterior sin equipo: error');
like(join(' ',@{iplan(ibase(), { kind=>'device', name=>'otro', domain=>'local', ip=>'10.0.0.150', from=>{ ip=>'10.0.0.100' } })->{errors}}),
	qr/la IP 10\.0\.0\.100 es de tda-00\.local \(id_dev=12\), no de otro\.local/, 'cambio de IP con otro nombre: error');
like(join(' ',@{iplan(ibase(), { kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.0.99', from=>{ name=>'tda-00' } })->{errors}}),
	qr/no hay ningun dispositivo con la IP 10\.0\.0\.99: nada que renombrar/, 'renombrar sin equipo en esa IP: error');
like(join(' ',@{iplan(ibase(), { kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.0.100', from=>{ name=>'tda-00' }, _origin=>'a linea 2' },
										{ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.150', from=>{ ip=>'10.0.0.100' }, _origin=>'a linea 3' })->{errors}}),
	qr/ya esta en a linea 2: un dispositivo, un recurso/, 'el mismo equipo en dos recursos: error');
my $tx3 = ibase(); push @{$tx3->{devices}}, { id_dev=>13, name=>'tda-01', domain=>'local', ip=>'10.0.0.101', type=>'' };
like(join(' ',@{iplan($tx3, { kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.0.100', from=>{ name=>'tda-00' } },
								  { kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.0.101', from=>{ name=>'tda-01' } })->{errors}}),
	qr/el nombre nuevo tda-10\.local lo usa otro dispositivo de este estado/, 'dos equipos al mismo nombre nuevo: error');
like(join(' ',@{iplan(ibase(), { kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.0.100', from=>{ name=>'tda-00' } },
										{ kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.9.9' })->{errors}}),
	qr/el nombre o la IP los toma otro dispositivo de este estado/, 'alta con el nombre que toma un renombrado: error');
like(join(' ',@{iplan(ibase(), { kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.9.9' },
										{ kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.0.100', from=>{ name=>'tda-00' } })->{errors}}),
	qr/el nombre nuevo tda-10\.local lo usa otro dispositivo de este estado/, '... y en el otro orden');
like(join(' ',@{iplan(ibase(), { kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.0.100' })->{errors}}),
	qr/la IP ya es de tda-00\.local \(id_dev=12\) \(para cambiarle el nombre: columna name_from\)/, 'sin from y nombre distinto: conflicto, con la pista');
# Precondition: someone changed it after the plan
my $tq = ibase(); my ($bkq) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'local', ip=>'10.0.0.150', from=>{ ip=>'10.0.0.100' } }));
my ($cq) = ctx($tq); my $plq = make_plan($cq,$bkq);
push @{$tq->{devices}}, { id_dev=>13, name=>'otro', domain=>'local', ip=>'10.0.0.150', type=>'' };
like(join(' ',@{apply_plan($cq,$plq)}), qr/deshecho, no se ha modificado ninguno\): id_dev=12 \(10\.0\.0\.100\): la IP nueva 10\.0\.0\.150 ya la tiene otro dispositivo/, 'IP nueva ocupada despues del plan: error');
is(join(' ', $tq->{devices}[0]{ip}, map { $_->[1] } @{$tq->{remote}}), '10.0.0.100 10.0.0.100 10.9.9.9', '... nada escrito');
ok((! $tq->{asst}) && (! -e $RF), '... ni asistente ni recarga');
my $tq2 = ibase(); my ($bkq2) = validate_state(vstate({ kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.0.100', from=>{ name=>'tda-00' } }));
my ($cq2) = ctx($tq2); my $plq2 = make_plan($cq2,$bkq2);
$tq2->{devices}[0]{name}='cambiado';
like(join(' ',@{apply_plan($cq2,$plq2)}), qr/name vale 'cambiado' y el plan esperaba 'tda-00'/, 'nombre cambiado despues del plan: error');
is($tq2->{metrics}[0]{label}, 'Disponibilidad (tda-00.local)', '... la etiqueta sin tocar');
my $tq3 = ibase(); my ($cq3) = ctx($tq3); my $plq3 = make_plan($cq3,$bkq2);
push @{$tq3->{devices}}, { id_dev=>13, name=>'tda-10', domain=>'local', ip=>'10.0.0.101', type=>'' };
like(join(' ',@{apply_plan($cq3,$plq3)}), qr/el nombre nuevo tda-10\.local ya lo tiene otro dispositivo; ha cambiado desde el plan/, 'nombre nuevo ocupado despues del plan: error');
is($tq3->{devices}[0]{name}, 'tda-00', '... nada escrito');
# The assistant fails: error with the command, the data stays; empty assistant: warning
my $ta3 = ibase(); $ta3->{fail_assist}=1; my ($ca3) = ctx($ta3);
like(join(' ',@{apply_plan($ca3, make_plan($ca3,$bkq))}), qr/no se ha recalculado su asistente \(simulated assistant failure\)\. Ejecutar: \/opt\/crawler\/bin\/prov_device_app_metrics -c default -i 12/,
	'fallo del asistente: error con la orden');
is($ta3->{devices}[0]{ip}, '10.0.0.150', '... y el cambio queda escrito');
my $ta4 = ibase(); $ta4->{responds}={}; my ($ca4) = ctx($ta4);
is(scalar(@{apply_plan($ca4, make_plan($ca4,$bkq))}), 0, 'asistente vacio: no es error');
like(join(' ',@{$ca4->{apply_warnings}||[]}), qr/device 10\.0\.0\.150: asistente recalculado, pero vacio/, '... y se avisa');
# Rename with the domain of the profile: the device keeps its own
my $tdr = ibase(); $tdr->{devices}[0]{domain}='es.local'; $tdr->{metrics}[0]{label}='D (tda-00.es.local)';
my ($bkdr) = validate_state(vstate({ kind=>'device', name=>'tda-10', domain=>'local', ip=>'10.0.0.100', from=>{ name=>'tda-00' }, _domain_default=>1 },
	{ kind=>'metric', device=>'tda-10.local', subtype=>'disp_icmp', c_label=>'Nuevo' }));
my ($cdr) = ctx($tdr); my $pldr = make_plan($cdr,$bkdr);
is(join(' | ', map { $_->{text} } @{$pldr->{actions}}),
	'tda-00.es.local -> tda-10.es.local (+ etiquetas de sus metricas) (+ asistente) (+ recarga de traps) | tda-10.es.local disp_icmp: "Disp tda-00 y 10.0.0.100" -> "Nuevo"',
	'renombrar con el dominio por defecto: conserva el suyo');
is(scalar(@{apply_plan($cdr,$pldr)}), 0, '... aplicado');
is("$tdr->{devices}[0]{name}.$tdr->{devices}[0]{domain} $tdr->{metrics}[0]{label}", 'tda-10.es.local D (tda-10.es.local)', '... nombre y etiqueta');
($cdr) = ctx($tdr); my $pldr2 = make_plan($cdr,$bkdr);
is(scalar(@{$pldr2->{actions}}).'/'.scalar(@{$pldr2->{errors}}), '0/0', '... el plan calculado otra vez sale vacio y sin errores');
# Domain only, with other attributes in the same row
my $tdo = ibase();
my ($bkdo) = validate_state(vstate({ kind=>'device', name=>'tda-00', domain=>'es.local', ip=>'10.0.0.100', from=>{ domain=>'local' }, critic=>75 }));
my ($cdo) = ctx($tdo); my $pldo = make_plan($cdo,$bkdo);
is($pldo->{actions}[0]{text}, "tda-00.local -> tda-00.es.local, critic '50' -> '75' (+ etiquetas de sus metricas) (+ critic de sus alertas) (+ asistente) (+ recarga de traps)",
	'cambio de dominio y critic en la misma fila: una accion');
is(scalar(@{apply_plan($cdo,$pldo)}), 0, '... aplicado');
is("$tdo->{devices}[0]{domain}/$tdo->{devices}[0]{critic}/$tdo->{alert_critic}{'alerts:12'}", 'es.local/75/75', '... dominio, critic y alertas');
unlink $RF;

#=== 0017: the c_label of the profile does not replace an existing title =====================
my $tlb = base(); push @{$tlb->{metrics}}, { id_metric=>501, id_dev=>12, name=>'mon_icmp', status=>'0', c_label=>'' };
my ($bklb) = validate_state(vstate(
	{ kind=>'metric', device=>'tda-00.local', subtype=>'disp_icmp', c_label=>'Plantilla', _label_default=>1 },
	{ kind=>'metric', device=>'tda-00.local', subtype=>'mon_icmp',  c_label=>'Plantilla mon', _label_default=>1 }));
my ($clb) = ctx($tlb); my $pllb = make_plan($clb,$bklb);
is(join(' | ', map { $_->{text} } @{$pllb->{actions}}), 'tda-00.local mon_icmp: (vacio) -> "Plantilla mon"',
	'plantilla del perfil: no toca un titulo que ya existe; si pone el de una metrica sin titulo');
my ($bklx) = validate_state(vstate({ kind=>'metric', device=>'tda-00.local', subtype=>'disp_icmp', c_label=>'Explicito' }));
($clb) = ctx($tlb);
is(join(' | ', map { $_->{text} } @{make_plan($clb,$bklx)->{actions}}), 'tda-00.local disp_icmp: "viejo" -> "Explicito"', 'titulo explicito: cambia el que existe');
my ($bkln) = validate_state(vstate({ kind=>'device', name=>'nuevo-09', domain=>'local', ip=>'10.0.9.9' },
	{ kind=>'metric', device=>'nuevo-09.local', subtype=>'disp_icmp', c_label=>'Plantilla nueva', _label_default=>1 }));
($clb) = ctx($tlb);
like(join(' | ', map { $_->{text} } @{make_plan($clb,$bkln)->{actions}}), qr/nuevo-09\.local disp_icmp: \(vacio\) -> "Plantilla nueva"/, 'plantilla en una metrica nueva: se pone');

done_testing();
