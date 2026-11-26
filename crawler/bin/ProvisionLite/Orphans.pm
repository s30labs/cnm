#####################################################################################################
# File: (ProvisionLite/Orphans.pm)
# Description:
#	Classification used by support/cnm-orphan-metrics, the one-off cleanup of what removed
#	template rows left behind before REG-CNM-Deuda 4.107 (PROY-CNM-Alertas-Azules, point 21):
#
#	- In a device RRD directory (/opt/data/rrd/elements/<id_dev 10 digits>/), each file is:
#	    metric    a .rrd that belongs to a metric (metrics.file)
#	    orphan    a .rrd that belongs to no metric
#	    removed   <file>.rrd.removed-AAAAMMDD-HHMMSS, archived by the retirement of 4.107
#	    archived  <file>.rrd.orphan-AAAAMMDD-HHMMSS, an orphan archived by this tool
#	    other     anything else (not touched)
#	- removed and archived files are due for purge when their stamp is older than the
#	  retention (90 days, PROY-CNM-Alertas-Azules section 8, 24-nov-2026). The age counts
#	  from the stamp, never from the file mtime: an orphan written in 2023 and archived
#	  today is kept 90 days from today.
#
#	Pure functions: they do not read the disk or the database.
# Set Tab=3
#####################################################################################################
package ProvisionLite::Orphans;
$VERSION='1.00';
use strict;
use Time::Local qw(timelocal);
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(RETENTION_DAYS file_kind stamp_epoch classify_files);

use constant RETENTION_DAYS => 90;

#----------------------------------------------------------------------------
# file_kind($name) -> ($kind, $stamp)
# $name: a file name, without directory. $stamp only for removed and archived.
# A .rrd is returned as 'rrd': whether it is a metric or an orphan is decided by the caller.
#----------------------------------------------------------------------------
sub file_kind {
my $name=shift;
	return ('other',undef) if ((! defined $name) || ($name eq '') || ($name =~ m{/}));
	return ('rrd',undef) if ($name =~ /\.rrd$/);
	return ('removed',$1)  if ($name =~ /\.rrd\.removed-(\d{8}-\d{6})$/);
	return ('archived',$1) if ($name =~ /\.rrd\.orphan-(\d{8}-\d{6})$/);
	return ('other',undef);
}

#----------------------------------------------------------------------------
# stamp_epoch($stamp) -> epoch of AAAAMMDD-HHMMSS (local time), undef if not valid.
#----------------------------------------------------------------------------
sub stamp_epoch {
my $s=shift;
	return undef if ((! defined $s) || ($s !~ /^(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})(\d{2})$/));
	my ($y,$mo,$d,$h,$mi,$se)=($1,$2,$3,$4,$5,$6);
	my $t = eval { timelocal($se,$mi,$h,$d,$mo-1,$y) };
	return $@ ? undef : $t;
}

#----------------------------------------------------------------------------
# classify_files($dir,$files,$metric_files,$now,$days) -> hash of lists of file names:
#   { metric=>[...], orphan=>[...], removed=>[...], archived=>[...], due=>[...], other=>[...] }
# $dir:          the device directory as it appears in metrics.file ('0000000032').
# $files:        [ names ] in that directory (no paths).
# $metric_files: { 'dir/name' => 1 } from metrics.file of the device (any type).
# $now, $days:   to decide 'due' (removed or archived older than $days; default RETENTION_DAYS).
# 'due' repeats the names of removed/archived that can be purged. Every list is sorted.
#----------------------------------------------------------------------------
sub classify_files {
my ($dir,$files,$metric_files,$now,$days)=@_;
	$days = RETENTION_DAYS if (! defined $days);
	$now = time() if (! defined $now);
	$metric_files = {} if (ref($metric_files) ne 'HASH');
	my %r = map { $_ => [] } qw(metric orphan removed archived due other);
	foreach my $f (sort @{$files || []}) {
		my ($kind,$stamp) = file_kind($f);
		if ($kind eq 'rrd') {
			push @{$r{ $metric_files->{"$dir/$f"} ? 'metric' : 'orphan' }}, $f;
			next;
		}
		push @{$r{$kind}}, $f;
		next if (($kind ne 'removed') && ($kind ne 'archived'));
		my $t = stamp_epoch($stamp);
		push @{$r{'due'}}, $f if ((defined $t) && ($now - $t >= $days*86400));
	}
	return \%r;
}

1;
