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
use ProvisionLite::Orphans qw(RETENTION_DAYS NODATA_DAYS file_kind stamp_epoch classify_files map_unknown_index has_valid_data retire_decision);

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

#--- has_valid_data -------------------------------------------------------------------------
is(has_valid_data([ [undef,undef], [undef] ]), 0, 'has_valid_data: only NaN');
is(has_valid_data([ [undef,undef], [undef,0] ]), 1, 'has_valid_data: a 0 is a valid value');
is(has_valid_data([ [undef], [3.5] ]), 1, 'has_valid_data: one value');
is(has_valid_data([]), 0, 'has_valid_data: no rows');
is(has_valid_data(undef), 0, 'has_valid_data: undef');
is(has_valid_data([ 'x', [undef] ]), 0, 'has_valid_data: a row that is not a list is ignored');

#--- MAP status metrics (one DS per state; the unknown state at 1 is no data) --------------
is(map_unknown_index('Up|No computable|No disponible|Unk'), 3, 'map_unknown_index: Unk, the 4th');
is(map_unknown_index('Disponible|No computable|No Disponible|Desconocido'), 3, 'map_unknown_index: Desconocido');
is(map_unknown_index('ok|Unknown|fail'), 1, 'map_unknown_index: Unknown in the middle');
is(map_unknown_index('Up|Down'), undef, 'map_unknown_index: no unknown state');
is(map_unknown_index('Up|Unknown state'), undef, 'map_unknown_index: only the whole label');
is(map_unknown_index(undef), undef, 'map_unknown_index: undef');
my $MAP = { unknown=>3 };
is(has_valid_data([ [0,0,0,1], [0,0,0,1] ], $MAP), 0, 'MAP: only Unk is no data (the 437 gap)');
is(has_valid_data([ [0,0,0,1], [1,0,0,0] ], $MAP), 1, 'MAP: one Up is data');
is(has_valid_data([ [0,0,1,0] ], $MAP), 1, 'MAP: No disponible is data (the device answered)');
is(has_valid_data([ [0,0,0,0.25] ], $MAP), 0, 'MAP: a consolidated fraction of Unk is no data');
is(has_valid_data([ [0.75,0,0,0.25] ], $MAP), 1, 'MAP: a consolidated fraction of Up is data');
is(has_valid_data([ [0,0,0,0] ], $MAP), 0, 'MAP: all states at 0 is no data');
is(has_valid_data([ [undef,undef,undef,undef] ], $MAP), 0, 'MAP: U is no data');
is(has_valid_data([ [0,0,0,0] ], { unknown=>undef }), 0, 'MAP without unknown state: all at 0 is no data');
is(has_valid_data([ [0,1] ], { unknown=>undef }), 1, 'MAP without unknown state: a state at 1 is data');
is(has_valid_data([ [0,0,0,1] ]), 1, 'not MAP: any value is data');

#--- retire_decision ------------------------------------------------------------------------
is(NODATA_DAYS, 180, 'NODATA_DAYS: 180 (decision of 27-nov-2026)');
my %OK = ( device=>1, type=>'snmp', status=>0, has_row=>0, subtype_rows=>3, c_label=>'', rrd=>'nodata' );
sub rd { my %m=(%OK,@_); return [ retire_decision(\%m) ]; }
is_deeply(rd(), [1,'sin datos en 180 dias'], 'retire: SNMP, no row, subtype in the template, no c_label, no data');
is_deeply(rd(rrd=>'missing'), [1,'sin rrd'], 'retire: no RRD');
is_deeply(rd(c_label=>undef), [1,'sin datos en 180 dias'], 'retire: c_label NULL is no c_label');
is_deeply(rd(device=>0), [0,'equipo borrado'], 'retire: never on a device that no longer exists');
is_deeply(rd(type=>'xagent'), [0,'no es snmp'], 'retire: never xagent');
is_deeply(rd(type=>'latency'), [0,'no es snmp'], 'retire: never latency');
is_deeply(rd(type=>undef), [0,'no es snmp'], 'retire: no type');
is_deeply(rd(status=>3), [0,'status 3'], 'retire: already retired');
is_deeply(rd(has_row=>1), [0,'con fila'], 'retire: with a template row');
is_deeply(rd(subtype_rows=>0), [0,'subtipo sin filas en la plantilla'], 'retire: subtype not provisioned from the template (device 2089)');
is_deeply(rd(c_label=>'KPI0050'), [0,'con c_label'], 'retire: never with c_label');
is_deeply(rd(rrd=>'data'), [0,'con datos en 180 dias'], 'retire: never while collecting data');
is_deeply(rd(rrd=>'error'), [0,'no se puede leer el rrd'], 'retire: never if the RRD cannot be read');
is_deeply(rd(rrd=>undef), [0,'no se puede leer el rrd'], 'retire: never without RRD state');
is_deeply(rd(status=>2), [1,'sin datos en 180 dias'], 'retire: status 2 (inactive) can be retired');
is_deeply([ retire_decision({ %OK }, 30) ], [1,'sin datos en 30 dias'], 'retire: the window of -D in the text');

done_testing();
