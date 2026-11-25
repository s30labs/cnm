#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# Tests for ProvisionLite::BlueAlertsFix (cnm-blue-alerts-fix, PROY-CNM-Alertas-Azules point 8)
# and for the BLUE_ALERTS_FIX key in ONMConfig.
# Run: cd /opt/crawler/bin && prove -I. t/PROV_blue_alerts_fix.t
#-------------------------------------------------------------------------------------------
use strict;
use warnings;
use Test::More;
use File::Temp qw(tempdir);
use FindBin;
use lib "$FindBin::Bin/..";
use ProvisionLite::BlueAlertsFix qw(NOTICE_BLUE_KEPT auto_enabled kept_mnames plan_devices take_lock);

#--- auto_enabled: only an explicit 1 -----------------------------------------------------
is(auto_enabled('1'), 1, 'auto_enabled: 1');
is(auto_enabled(' 1 '), 1, 'auto_enabled: 1 with spaces');
is(auto_enabled(undef), 0, 'auto_enabled: no line, off');
is(auto_enabled('0'), 0, 'auto_enabled: 0');
is(auto_enabled(''), 0, 'auto_enabled: empty');
is(auto_enabled('yes'), 0, 'auto_enabled: other text');
is(auto_enabled('11'), 0, 'auto_enabled: 11');

#--- ONMConfig reads BLUE_ALERTS_FIX (one process per file: %CFG is global) ----------------
my $tmp = tempdir(CLEANUP=>1);
sub conf_value {
my $content=shift;
	my $f = "$tmp/onm-".int(rand(1e9)).".conf";
	open(my $fh,'>',$f) or die; print $fh $content; close($fh);
	my $lib = "$FindBin::Bin/..";
	my $v = `$^X -I$lib -MONMConfig -e 'my \$c=conf_base(shift); print defined(\$c->{blue_alerts_fix}) ? "[".\$c->{blue_alerts_fix}->[0]."]" : "undef"' $f 2>&1`;
	return $v;
}
is(conf_value("BLUE_ALERTS_FIX = 1\n"), '[1]', 'ONMConfig: BLUE_ALERTS_FIX = 1');
is(conf_value("A = 1\n"), 'undef', 'ONMConfig: without the line, undef');
is(conf_value("#BLUE_ALERTS_FIX = 1\n"), 'undef', 'ONMConfig: a commented line does not count');
is(auto_enabled(undef), 0, 'and undef is off');

#--- kept_mnames ----------------------------------------------------------------------------
my $TXT = 'host (10.0.0.1) disk_mibhost: la instancia esta en la lectura y se conserva la metrica en azul: disk_mibhost-3 disk_mibhost-7';
is_deeply([kept_mnames($TXT)], ['disk_mibhost-3','disk_mibhost-7'], 'kept_mnames: the listed names');
is_deeply([kept_mnames("$TXT  ")], ['disk_mibhost-3','disk_mibhost-7'], 'kept_mnames: trailing spaces');
is_deeply([kept_mnames("Observacion, no se aplica: $TXT")], [], 'kept_mnames: observation notices do not count');
is_deeply([kept_mnames('Se eliminan: iid=177')], [], 'kept_mnames: another notice');
is_deeply([kept_mnames(undef)], [], 'kept_mnames: undef');
is(NOTICE_BLUE_KEPT, 'Provision: azules conservadas', 'NOTICE_BLUE_KEPT: the descr written by ProvisionLite');

#--- plan_devices ---------------------------------------------------------------------------
sub n_ { my ($dev,$t,@m)=@_; return [ $dev, $t, "x (ip) st: la instancia esta en la lectura y se conserva la metrica en azul: @m" ]; }
my $B = [ [10,'st-1',100], [10,'st-2',100], [20,'st-1',100], [30,'st-5',100] ];

my $p = plan_devices($B, [], {});
is_deeply($p, { todo=>[10,20,30], pending=>[], kept=>[] }, 'plan: without notices, every device is enqueued');

$p = plan_devices($B, [ n_(10,150,'st-1','st-2') ], {});
is_deeply($p->{kept}, [10], 'plan: all the blues of 10 kept after they appeared: skipped');
is_deeply($p->{todo}, [20,30], 'plan: the others are enqueued');

$p = plan_devices($B, [ n_(10,150,'st-1') ], {});
is_deeply($p->{todo}, [10,20,30], 'plan: one blue of 10 was not kept: enqueued');

$p = plan_devices($B, [ n_(10,50,'st-1','st-2') ], {});
is_deeply($p->{todo}, [10,20,30], 'plan: kept before the alert appeared (a new blue): enqueued');

$p = plan_devices($B, [ n_(10,100,'st-1','st-2') ], {});
is_deeply($p->{kept}, [10], 'plan: kept in the same second the alert appeared: skipped');

$p = plan_devices($B, [ n_(10,150,'st-1'), n_(10,160,'st-2') ], {});
is_deeply($p->{kept}, [10], 'plan: kept in two notices: skipped');

$p = plan_devices($B, [ n_(20,150,'st-1','st-2') ], {});
is_deeply($p->{kept}, [20], 'plan: the notice of 20 does not count for 10');
is_deeply($p->{todo}, [10,30], 'plan: 10 is enqueued');

$p = plan_devices($B, [ [10,150,"Observacion, no se aplica: x (ip) st: la instancia esta en la lectura y se conserva la metrica en azul: st-1 st-2"] ], {});
is_deeply($p->{todo}, [10,20,30], 'plan: an observation notice (PROV_GUARD 2) does not skip');

$p = plan_devices($B, [ n_(10,150,'st-1','st-2') ], { 10=>1, 30=>1 });
is_deeply($p, { todo=>[20], pending=>[10,30], kept=>[] }, 'plan: pending comes first');

$p = plan_devices($B, [ n_(10,150,'st-1','st-2') ], {}, 1);
is_deeply($p, { todo=>[10,20,30], pending=>[], kept=>[] }, 'plan: -f enqueues the kept ones');

$p = plan_devices($B, [ n_(10,150,'st-1','st-2') ], { 10=>1 }, 1);
is_deeply($p->{pending}, [10], 'plan: -f never duplicates a pending reprovision');

$p = plan_devices([ [10,'st-1',undef] ], [ n_(10,150,'st-1') ], {});
is_deeply($p->{todo}, [10], 'plan: an alert without date is enqueued');

$p = plan_devices([ [9,'a',1], [100,'a',1], [10,'a',1] ], [], {});
is_deeply($p->{todo}, [9,10,100], 'plan: sorted by number');

is_deeply(plan_devices([], [ n_(10,150,'st-1') ], {}), { todo=>[], pending=>[], kept=>[] }, 'plan: no blues');
is_deeply(plan_devices(undef, undef, undef), { todo=>[], pending=>[], kept=>[] }, 'plan: no data');

#--- take_lock ------------------------------------------------------------------------------
my $lf = "$tmp/lock";
my $l1 = take_lock($lf);
ok($l1, 'take_lock: the first one gets it');
ok(! take_lock($lf), 'take_lock: a second one does not, while the first is held');
close($l1);
my $l2 = take_lock($lf);
ok($l2, 'take_lock: free again once released');
my $other = `$^X -I$FindBin::Bin/.. -MProvisionLite::BlueAlertsFix=take_lock -e 'print take_lock(shift) ? "got" : "busy"' $lf`;
is($other, 'busy', 'take_lock: another process does not get it either');
close($l2);
eval { take_lock("$tmp/nodir/lock") };
like($@, qr/No se puede abrir/, 'take_lock: dies if the file cannot be opened');

done_testing();
