#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# CNMControl::Audit - One audit row in qactions for each apply
#
#	The row is written as the console writes an action that is already done
#	(info_qactions, custom_pro onm/inc/Store.php:3093): status 3 (STAT_END), so the queue of
#	the engine, which only takes status 0 (crawler/bin/Crawler/Actions.pm:149, :1227), does
#	not run it. The console shows every row of qactions in its audit screen
#	(onm/custom/mod_auditoria_layout.php, query all_qactions): date, descr, auser, rc and
#	rcstr. Decision of 28-nov-2026: atype 24 (ATYPE_CNM_CONTROL), one row per apply.
#
#	Only an apply that runs actions writes a row: a plan, or an apply that stops before
#	writing (errors in the plan, nothing to do), changes nothing.
#	The row carries no credential: descr counts actions, rcstr has the errors of cnm-control
#	(they do not carry the community) and the run directory.
#-------------------------------------------------------------------------------------------
package CNMControl::Audit;
use strict;
use Exporter;
use vars qw(@ISA @EXPORT_OK $VERSION);
@ISA = qw(Exporter);
@EXPORT_OK = qw(audit_row audit_write);
$VERSION='0.10';

# The same value as ATYPE_CNM_CONTROL in crawler/bin/ATypes.pm (checked by t/CTL_audit.t
# where ATypes.pm is available)
use constant ATYPE_CNM_CONTROL => 24;
use constant STAT_END => 3;

#----------------------------------------------------------------------------
# audit_row: the columns of the row.
#  plan    the plan that was applied (its actions)
#  ok      1 if the apply ended as asked (the check plan is empty)
#  errors  [ apply errors ], pending (actions still pending in the check)
#  run     run directory (its base name makes the name unique: PRIMARY KEY (name))
#  origin, user, t0, t1
#----------------------------------------------------------------------------
sub audit_row {
my (%a)=@_;
	my %n=();
	$n{"$_->{kind} $_->{op}"}++ foreach (@{$a{plan}{actions}});
	my $descr = 'cnm-control apply: '.join(', ', map { "$_ $n{$_}" } sort keys %n);
	my $id = $a{run}; $id =~ s{.*/}{}; $id =~ s/-apply$//;
	my $rcstr = $a{ok} ? "OK" : "ERROR";
	if (! $a{ok}) {
		my @e = @{$a{errors} || []};
		push @e, "$a{pending} acciones pendientes en la comprobacion" if ($a{pending});
		$rcstr .= ': '.join(' | ', @e) if (@e);
		$rcstr = substr($rcstr,0,2000).' ...' if (length($rcstr) > 2000);
	}
	$rcstr .= " ($a{run})";
	return {
		name       => "cnm-control-$id",
		descr      => (length($descr) > 255) ? substr($descr,0,251).' ...' : $descr,
		action     => 'cnm-control',
		atype      => ATYPE_CNM_CONTROL,
		params     => "run=$a{run};origin=$a{origin}",
		auser      => substr($a{user},0,50),
		date_store => $a{t0}, date_start => $a{t0}, date_end => $a{t1},
		status     => STAT_END,
		rc         => $a{ok} ? 0 : 1,
		rcstr      => $rcstr,
	};
}

#----------------------------------------------------------------------------
# audit_write: inserts the row. Returns '' or the error (the apply is already done: the
# caller shows it as a warning).
#----------------------------------------------------------------------------
sub audit_write {
my ($dbh,$row)=@_;
	my @c = qw(name descr action atype params auser date_store date_start date_end status rc rcstr);
	eval {
		local $dbh->{RaiseError}=1; local $dbh->{PrintError}=0;
		$dbh->do("INSERT INTO qactions (".join(',',@c).") VALUES (".join(',',('?') x @c).")", undef, map { $row->{$_} } @c);
	};
	my $e=$@; chomp $e;
	return $e;
}

1;
