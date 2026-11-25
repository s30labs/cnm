#####################################################################################################
# File: (ProvisionLite/BlueAlertsFix.pm)
# Description:
#	Decisions of cnm-blue-alerts-fix, the launcher that enqueues a reprovision from the template
#	for the devices with SNMP blue alerts (PROY-CNM-Alertas-Azules, section 6.3 and point 8).
#
#	- auto_enabled: the onm.conf key BLUE_ALERTS_FIX turns on the daily run (-a). Off when
#	  the line is missing: it is a new automatic action.
#	- kept_mnames: the metric names listed in a 'Provision: azules conservadas' notice
#	  (REG-CNM-Deuda 4.136). Notices in observation mode (PROV_GUARD 2) do not count.
#	- plan_devices: which devices are enqueued. A device is skipped when it already has a
#	  pending reprovision, or when every blue alert it has was kept by a provision that ran
#	  after the alert appeared: reprovisioning it again would change nothing.
#	- take_lock: a non-blocking lock so that two runs never overlap.
#
#	Pure functions except take_lock, which opens and locks a file.
# Set Tab=3
#####################################################################################################
package ProvisionLite::BlueAlertsFix;
$VERSION='1.00';
use strict;
use Fcntl qw(:flock O_RDWR O_CREAT);
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(NOTICE_BLUE_KEPT auto_enabled kept_mnames plan_devices take_lock);

use constant NOTICE_BLUE_KEPT => 'Provision: azules conservadas';

#----------------------------------------------------------------------------
# auto_enabled($value) -> 1 only with an explicit 1 (BLUE_ALERTS_FIX = 1).
# $value: the onm.conf value, undef when the line is missing.
#----------------------------------------------------------------------------
sub auto_enabled {
my $v=shift;
	return ((defined $v) && ($v =~ /^\s*1\s*$/)) ? 1 : 0;
}

#----------------------------------------------------------------------------
# kept_mnames($rcstr) -> metric names kept by the provision that wrote the notice.
# Empty for observation notices ('Observacion, no se aplica: ...') and for any other text.
#----------------------------------------------------------------------------
sub kept_mnames {
my $rcstr=shift;
	return () if ((! defined $rcstr) || ($rcstr =~ /^Observacion/));
	return () if ($rcstr !~ /se conserva la metrica en azul:\s*(.*?)\s*$/);
	return grep { $_ ne '' } split(/\s+/,$1);
}

#----------------------------------------------------------------------------
# plan_devices($blues,$kept,$pending,$force) -> { todo=>[...], pending=>[...], kept=>[...] }
# $blues:   [ [id_dev, mname, date], ... ] SNMP blue alerts (date: when the alert appeared).
# $kept:    [ [id_dev, date_start, rcstr], ... ] 'Provision: azules conservadas' notices.
# $pending: { id_dev => 1 } devices with a reprovision pending or running.
# $force:   with 1 the kept rule is ignored (a pending reprovision is never duplicated).
# Each list is sorted by id_dev.
#----------------------------------------------------------------------------
sub plan_devices {
my ($blues,$kept,$pending,$force)=@_;
	$pending = {} if (ref($pending) ne 'HASH');

	# Last time each (device, metric) was kept
	my %last=();
	foreach my $k (@{$kept || []}) {
		next if ((ref($k) ne 'ARRAY') || (! defined $k->[0]) || (! defined $k->[1]));
		foreach my $m (kept_mnames($k->[2])) {
			my $key = "$k->[0]\t$m";
			$last{$key} = $k->[1] if ((! defined $last{$key}) || ($k->[1] > $last{$key}));
		}
	}

	# A device is 'kept' when all its blues were kept after they appeared
	my %all_kept=();
	foreach my $b (@{$blues || []}) {
		next if ((ref($b) ne 'ARRAY') || (! defined $b->[0]));
		my ($dev,$m,$date) = @$b;
		$all_kept{$dev} = 1 if (! exists $all_kept{$dev});
		my $t = (defined $m) ? $last{"$dev\t$m"} : undef;
		$all_kept{$dev} = 0 if ((! defined $t) || (! defined $date) || ($t < $date));
	}

	my %r = ( todo=>[], pending=>[], kept=>[] );
	foreach my $dev (sort { $a <=> $b } keys %all_kept) {
		if ($pending->{$dev}) { push @{$r{'pending'}}, $dev; }
		elsif ($all_kept{$dev} && (! $force)) { push @{$r{'kept'}}, $dev; }
		else { push @{$r{'todo'}}, $dev; }
	}
	return \%r;
}

#----------------------------------------------------------------------------
# take_lock($file) -> open handle holding an exclusive lock, or undef if another
# process holds it. The lock lasts while the handle is open (until exit).
#----------------------------------------------------------------------------
sub take_lock {
my $file=shift;
	sysopen(my $fh, $file, O_RDWR|O_CREAT, 0600) or die "No se puede abrir $file: $!\n";
	return flock($fh, LOCK_EX|LOCK_NB) ? $fh : undef;
}

1;
