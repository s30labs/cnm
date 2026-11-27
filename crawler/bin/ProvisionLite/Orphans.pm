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
#	- retire_decision: whether an SNMP metric without a template row can be retired. Only
#	  when its device exists, its subtype has template rows in that device (a subtype with
#	  none is not provisioned from the template, as most of device 2089), it has no
#	  c_label (KPI: reviewed by hand) and its RRD has no valid value in the last NODATA_DAYS
#	  days (or there is no RRD): a metric still collecting data measures something that
#	  exists, with or without a template row.
#	- Status metrics with MAP (cfg_monitor_snmp.esp) store one DS per state and one of them
#	  is always 1, also without data: then the 'unknown' state is the one at 1
#	  (REF-CNM-Funcionamiento 4.4). For them, valid data is any other state above 0.
#
#	Pure functions: they do not read the disk or the database.
# Set Tab=3
#####################################################################################################
package ProvisionLite::Orphans;
$VERSION='1.01';
use strict;
use Time::Local qw(timelocal);
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(RETENTION_DAYS NODATA_DAYS file_kind stamp_epoch classify_files map_unknown_index has_valid_data retire_decision);

use constant RETENTION_DAYS => 90;
use constant NODATA_DAYS => 180;	# default window without valid data for a metric to be retirable (decision of 27-nov-2026)

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

#----------------------------------------------------------------------------
# map_unknown_index($items) -> 0-based DS of the 'unknown' state of a MAP metric, from
# cfg_monitor_snmp.items ('Up|No computable|No disponible|Unk'); undef if there is none.
#----------------------------------------------------------------------------
sub map_unknown_index {
my $items=shift;
	return undef if (! defined $items);
	my @st = split(/\|/,$items,-1);
	for my $i (0..$#st) { return $i if ($st[$i] =~ /^\s*(unk|unknown|desconocido)\s*$/i); }
	return undef;
}

#----------------------------------------------------------------------------
# has_valid_data($rows,$map) -> 1 if the RRDs::fetch rows ([ [v1,v2,...], ... ]) hold data.
# $map undef: any defined value (not U) is data.
# $map = { unknown=>idx|undef } for MAP metrics: data is a value above 0 in a DS that is
# not the unknown state (all states at 0 is no data too).
#----------------------------------------------------------------------------
sub has_valid_data {
my ($rows,$map)=@_;
	my $unk = (ref($map) eq 'HASH') ? $map->{'unknown'} : undef;
	foreach my $line (@{$rows || []}) {
		next if (ref($line) ne 'ARRAY');
		for my $i (0..$#$line) {
			my $v = $line->[$i];
			next if (! defined $v);
			if (! $map) { return 1; }
			next if ((defined $unk) && ($i == $unk));
			return 1 if ($v > 0);
		}
	}
	return 0;
}

#----------------------------------------------------------------------------
# retire_decision($m,$days) -> ($retirable, $reason)
# $m: { device=>1|0, type, status, has_row=>1|0, subtype_rows=>n, c_label, rrd }
#     rrd: 'data' (valid values in the window), 'nodata', 'missing' or 'error'.
# $days: the window, only for the text (default NODATA_DAYS).
# $reason is a short text for the detail file.
#----------------------------------------------------------------------------
sub retire_decision {
my ($m,$days)=@_;
	$days = NODATA_DAYS if (! defined $days);
	return (0,'equipo borrado') if (! $m->{'device'});
	return (0,'no es snmp') if ((! defined $m->{'type'}) || ($m->{'type'} ne 'snmp'));
	return (0,'status 3') if ((defined $m->{'status'}) && ($m->{'status'} eq '3'));
	return (0,'con fila') if ($m->{'has_row'});
	return (0,'subtipo sin filas en la plantilla') if (! $m->{'subtype_rows'});
	return (0,'con c_label') if ((defined $m->{'c_label'}) && ($m->{'c_label'} ne ''));
	my $rrd = $m->{'rrd'} // 'error';
	return (0,"con datos en $days dias") if ($rrd eq 'data');
	return (0,'no se puede leer el rrd') if (($rrd ne 'nodata') && ($rrd ne 'missing'));
	return (1, ($rrd eq 'missing') ? 'sin rrd' : "sin datos en $days dias");
}

1;
