#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# Tests for ProvisionLite::Orphans (support/cnm-orphan-metrics, PROY-CNM-Alertas-Azules point 21).
# Run: cd /opt/crawler/bin && prove -I. t/PROV_orphans.t
#-------------------------------------------------------------------------------------------
use strict;
use warnings;
use Test::More;
use Time::Local qw(timelocal);
use FindBin;
use lib "$FindBin::Bin/..";
use ProvisionLite::Orphans qw(RETENTION_DAYS file_kind stamp_epoch classify_files);

is(RETENTION_DAYS, 90, 'RETENTION_DAYS: 90 (decision of 24-nov-2026)');

#--- file_kind ------------------------------------------------------------------------------
is_deeply([file_kind('disk_mibhost-85-STD.rrd')], ['rrd',undef], 'file_kind: .rrd');
is_deeply([file_kind('disk_mibhost-85-STD.rrd.removed-20261123-201500')], ['removed','20261123-201500'], 'file_kind: .removed-');
is_deeply([file_kind('disk_mibhost-85-STD.rrd.orphan-20261126-100000')], ['archived','20261126-100000'], 'file_kind: .orphan-');
is_deeply([file_kind('x.rrd.removed-2026112-201500')], ['other',undef], 'file_kind: a bad stamp is other');
is_deeply([file_kind('x.rrd.removed-20261123-201500.bak')], ['other',undef], 'file_kind: anything after the stamp is other');
is_deeply([file_kind('x.rrd.bak')], ['other',undef], 'file_kind: .rrd.bak is other');
is_deeply([file_kind('x.rrdx')], ['other',undef], 'file_kind: .rrdx is other');
is_deeply([file_kind('notes.txt')], ['other',undef], 'file_kind: other files');
is_deeply([file_kind('a/b.rrd')], ['other',undef], 'file_kind: a path is not a name');
is_deeply([file_kind('')], ['other',undef], 'file_kind: empty');
is_deeply([file_kind(undef)], ['other',undef], 'file_kind: undef');

#--- stamp_epoch ----------------------------------------------------------------------------
is(stamp_epoch('20261126-100000'), timelocal(0,0,10,26,10,2026), 'stamp_epoch: local time');
is(stamp_epoch('20261332-100000'), undef, 'stamp_epoch: month 13 is not valid');
is(stamp_epoch('20260230-100000'), undef, 'stamp_epoch: 30 February is not valid');
is(stamp_epoch('2026112-100000'), undef, 'stamp_epoch: wrong format');
is(stamp_epoch(undef), undef, 'stamp_epoch: undef');

#--- classify_files -------------------------------------------------------------------------
my $NOW = timelocal(0,0,12,26,10,2026);			# 26-nov-2026 12:00
# Stamps built from $NOW, so the limit does not depend on the time zone or a DST change
sub st_ { my @t=localtime(shift); return sprintf('%04d%02d%02d-%02d%02d%02d',$t[5]+1900,$t[4]+1,$t[3],$t[2],$t[1],$t[0]); }
my $S90  = st_($NOW - 90*86400);
my $S90b = st_($NOW - 90*86400 + 1);
my $D = '0000000032';
my %MF = ( "$D/disk_mibhost-1-STD.rrd"=>1, "$D/traffic_mibii_if-4-STD.rrd"=>1, "0000000049/disk_mibhost-85-STD.rrd"=>1 );
my @F = ( 'disk_mibhost-1-STD.rrd', 'traffic_mibii_if-4-STD.rrd',
          'disk_mibhost-85-STD.rrd',                                  # orphan here (the metric is of 49)
          'disk_mibhost-34-STD.rrd',                                  # orphan
          'disk_mibhost-7-STD.rrd.removed-20260801-000000',          # 117 days: due
          'disk_mibhost-8-STD.rrd.removed-20261123-201500',          # 3 days
          "disk_mibhost-9-STD.rrd.orphan-$S90",                      # exactly 90 days: due
          "disk_mibhost-9-STD.rrd.orphan-$S90b",                     # 90 days minus 1 s
          'x.rrd.removed-20261399-000000',                           # bad stamp: removed, never due
          'notes.txt' );
my $c = classify_files($D, \@F, \%MF, $NOW);
is_deeply($c->{metric}, ['disk_mibhost-1-STD.rrd','traffic_mibii_if-4-STD.rrd'], 'classify: the files of metrics');
is_deeply($c->{orphan}, ['disk_mibhost-34-STD.rrd','disk_mibhost-85-STD.rrd'], 'classify: orphans, also one whose name is a metric of another device');
is_deeply($c->{removed}, ['disk_mibhost-7-STD.rrd.removed-20260801-000000','disk_mibhost-8-STD.rrd.removed-20261123-201500','x.rrd.removed-20261399-000000'], 'classify: removed');
is_deeply($c->{archived}, ["disk_mibhost-9-STD.rrd.orphan-$S90","disk_mibhost-9-STD.rrd.orphan-$S90b"], 'classify: archived');
is_deeply($c->{due}, ['disk_mibhost-7-STD.rrd.removed-20260801-000000',"disk_mibhost-9-STD.rrd.orphan-$S90"], 'classify: due from the stamp, 90 days included, a bad stamp never');
is_deeply($c->{other}, ['notes.txt'], 'classify: other');

my $c2 = classify_files($D, \@F, \%MF, $NOW, 1);
is(scalar(@{$c2->{due}}), 4, 'classify: with 1 day, every stamp of more than one day is due');
my $c3 = classify_files($D, ['a.rrd'], undef, $NOW);
is_deeply($c3->{orphan}, ['a.rrd'], 'classify: without metric files, every .rrd is an orphan');
my $c4 = classify_files($D, undef, \%MF, $NOW);
is_deeply($c4, { map { $_ => [] } qw(metric orphan removed archived due other) }, 'classify: no files');

done_testing();
