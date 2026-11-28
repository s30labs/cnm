#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# CTL_audit.t - The audit row of an apply (CNMControl::Audit)
#-------------------------------------------------------------------------------------------
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use CNMControl::Audit qw(audit_row audit_write);

my $plan = { actions=>[ { kind=>'device', op=>'create' }, { kind=>'device', op=>'create' }, { kind=>'device', op=>'ip' },
								{ kind=>'metric', op=>'provision' } ] };
my $run = '/store/data/support/cnm-control/runs/20261128-190501-apply';
my $r = audit_row(plan=>$plan, ok=>1, errors=>[], pending=>0, run=>$run, origin=>'perfil p + x.csv', user=>'operador', t0=>100, t1=>130);
is_deeply($r, { name=>'cnm-control-20261128-190501', descr=>'cnm-control apply: device create 2, device ip 1, metric provision 1',
					 action=>'cnm-control', atype=>24, params=>"run=$run;origin=perfil p + x.csv", auser=>'operador',
					 date_store=>100, date_start=>100, date_end=>130, status=>3, rc=>0, rcstr=>"OK ($run)" },
	'apply correcto: la fila completa (atype 24, terminada, rc 0, nombre unico por ejecucion)');

my $re = audit_row(plan=>$plan, ok=>0, errors=>[ 'dispositivos modificados, pero no se ha recalculado su asistente (x)' ], pending=>2,
						 run=>$run, origin=>'o', user=>'u', t0=>1, t1=>2);
is($re->{rc}, 1, 'apply con error: rc 1');
is($re->{rcstr}, "ERROR: dispositivos modificados, pero no se ha recalculado su asistente (x) | 2 acciones pendientes en la comprobacion ($run)",
	'... rcstr con los errores, lo pendiente y el directorio');
my $rc = audit_row(plan=>$plan, ok=>0, errors=>[], pending=>1, run=>$run, origin=>'o', user=>'u', t0=>1, t1=>2);
like($rc->{rcstr}, qr/^ERROR: 1 acciones pendientes en la comprobacion \(/, 'sin errores pero con pendientes: ERROR');

# Long values: descr fits varchar(255), rcstr is cut, auser fits varchar(50)
my $big = { actions=>[ map { { kind=>'metric', op=>"op$_" } } (1..60) ] };
my $rl = audit_row(plan=>$big, ok=>0, errors=>[ 'x' x 3000 ], pending=>0, run=>$run, origin=>'o', user=>('u' x 80), t0=>1, t1=>2);
ok(length($rl->{descr}) <= 255 && $rl->{descr} =~ / \.\.\.$/, 'descr de mas de 255: cortado');
ok(length($rl->{rcstr}) < 2100 && $rl->{rcstr} =~ /\.\.\. \(\Q$run\E\)$/, 'rcstr largo: cortado, con el directorio');
is(length($rl->{auser}), 50, 'auser: hasta 50');

# The INSERT
{	package FakeDBH; sub new { bless { q=>[] }, shift; }
	sub do { my ($s,$q,undef,@b)=@_; die "simulated failure\n" if ($s->{fail}); push @{$s->{q}}, [ $q, @b ]; return 1; } }
my $dbh = FakeDBH->new();
is(audit_write($dbh,$r), '', 'audit_write: sin error');
is($dbh->{q}[0][0], 'INSERT INTO qactions (name,descr,action,atype,params,auser,date_store,date_start,date_end,status,rc,rcstr) VALUES (?,?,?,?,?,?,?,?,?,?,?,?)',
	'... un INSERT con parametros');
is_deeply([ @{$dbh->{q}[0]}[1..12] ], [ @$r{qw(name descr action atype params auser date_store date_start date_end status rc rcstr)} ], '... con los valores de la fila');
$dbh->{fail}=1;
is(audit_write($dbh,$r), 'simulated failure', 'fallo del INSERT: devuelve el error (el apply lo muestra como aviso)');

# The same value as the engine, where crawler/bin is available (repository or appliance)
my $atypes = "$FindBin::Bin/../../crawler/bin/ATypes.pm";
SKIP: {
	skip "no esta $atypes", 1 if (! -f $atypes);
	require $atypes;
	is(ATypes::ATYPE_CNM_CONTROL(), CNMControl::Audit::ATYPE_CNM_CONTROL(), 'ATYPE_CNM_CONTROL igual en crawler/bin/ATypes.pm');
}

done_testing();
