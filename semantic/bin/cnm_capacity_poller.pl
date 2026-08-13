#!/usr/bin/perl
#
# cnm_capacity_poller.pl - Populate sem_instance.capacity via SNMP.
#
# See `perldoc cnm_capacity_poller.pl` (POD at the end of this file) for full
# documentation, including how to add a new capacity type.
#
use strict;
use warnings;
use Getopt::Long qw(:config no_ignore_case bundling);
use Pod::Usage;
use DBI;
use SNMP;

# RRDs (rrdtool Perl binding) is preferred for reading capacity from .rrd files.
# Older RRDs builds expose only some functions, so we check for info()
# specifically; if it is unavailable we shell out to the rrdtool binary.
my $HAVE_RRDS_INFO = eval { require RRDs; 1 } && defined &RRDs::info;

# ============================================================================
# CONFIG (defaults; override via options or environment)
# ============================================================================
my %CFG = (
    db_host   => $ENV{CNM_DB_HOST} || 'localhost',
    db_name   => $ENV{CNM_DB_NAME} || 'onm',
    db_user   => $ENV{CNM_DB_USER} || 'root',
    db_pass   => $ENV{CNM_DB_PASS} || '',
    db_port   => $ENV{CNM_DB_PORT} || 3306,

    snmp_port    => 161,
    snmp_timeout => 1_000_000,   # microseconds (SNMP.pm uses us): 1s
    snmp_retries => 2,
    get_chunk    => 30,          # OIDs per SNMP GET request
);

# ============================================================================
# LOGGING - several verbosity levels (controlled by -v / --debug / --quiet)
# ============================================================================
use constant { L_ERR => 0, L_WARN => 1, L_INFO => 2, L_DEBUG => 3, L_TRACE => 4 };
my @L_NAME = qw(ERROR WARN INFO DEBUG TRACE);
my $VERBOSITY = L_WARN;   # default: errors, warnings and the final summary

sub logmsg {
    my ($level, $fmt, @args) = @_;
    return if $level > $VERBOSITY;
    my @t = localtime; my $ts = sprintf '%04d-%02d-%02d %02d:%02d:%02d',
        $t[5]+1900, $t[4]+1, $t[3], $t[2], $t[1], $t[0];
    printf STDERR "%s [%-5s] $fmt\n", $ts, $L_NAME[$level], @args;
}
sub err   { logmsg(L_ERR,   @_) }
sub warnx { logmsg(L_WARN,  @_) }
sub info  { logmsg(L_INFO,  @_) }
sub debug { logmsg(L_DEBUG, @_) }
sub trace { logmsg(L_TRACE, @_) }

# ============================================================================
# OID CONSTANTS (numeric, so no MIB files are required)
# ============================================================================
my $OID_IF_SPEED     = '.1.3.6.1.2.1.2.2.1.5';      # ifSpeed      (bps,  Gauge32)
my $OID_IF_HIGHSPEED = '.1.3.6.1.2.1.31.1.1.1.15';  # ifHighSpeed  (Mbps, Gauge32)
my $OID_IF_ALIAS     = '.1.3.6.1.2.1.31.1.1.1.18';  # ifAlias      (DisplayString)
use constant IF_SPEED_MAX => 4294967295;            # ifSpeed saturated -> use ifHighSpeed

# ============================================================================
# CAPACITY RESOLVER REGISTRY
#
# One entry per concept (canonical_id). Each resolver declares:
#   oids    => sub ($iid) { returns (label => numeric_oid, ...) to GET }
#   compute => sub (%values_by_label) { returns ($capacity, $source, $info) }
#       $capacity/$source: capacity in the concept unit + its source label,
#                          or (undef, undef) when not determinable.
#       $info: optional free-text for sem_instance.instance_info (e.g. ifAlias).
#              Return a DEFINED value (possibly '') to mean "this concept has a
#              text source, captured"; return undef when it has none.
#
# To ADD A NEW CAPACITY TYPE (e.g. device.memory.bytes, device.disk.bytes):
#   add a new key here with its oids/compute. Nothing else in the script needs
#   to change: the work-list, polling and writeback are concept-agnostic.
# ============================================================================
my %RESOLVERS = (
    'net.iface.traffic_bps' => {
        desc    => 'Interface nominal speed (ifHighSpeed/ifSpeed) + ifAlias as instance_info',
        oids    => sub {
            my $iid = shift;
            return ( ifhs  => "$OID_IF_HIGHSPEED.$iid",
                     ifs   => "$OID_IF_SPEED.$iid",
                     alias => "$OID_IF_ALIAS.$iid" );
        },
        compute => sub {
            my %v = @_;
            # instance_info: ifAlias (trimmed). Defined (possibly '') so the
            # poller marks it captured even when the interface has no alias.
            my $info = $v{alias};
            $info = '' unless defined $info;
            $info =~ s/^\s+|\s+$//g;
            my $hs = $v{ifhs};
            my $s  = $v{ifs};
            # ifHighSpeed (Mbps) is preferred and handles speeds > 4 Gbps.
            return ($hs * 1_000_000, 'ifHighSpeed', $info)
                if defined $hs && $hs =~ /^\d+$/ && $hs > 0;
            # Fallback to ifSpeed (bps); ignore the saturated sentinel value.
            return ($s, 'ifSpeed', $info)
                if defined $s && $s =~ /^\d+$/ && $s > 0 && $s != IF_SPEED_MAX;
            return (undef, undef, $info);   # no capacity, but alias may still exist
        },
    },
    # SNMP resolvers for other capacity concepts would go here, keyed by concept.
);

# ============================================================================
# RRD-BASED CAPACITY (capacity lives inside the metric itself)
# ============================================================================
# Some metrics already carry their total as one of their RRD data sources (CNM
# polls "total" and "used" together), so capacity needs NO extra SNMP -- it is
# read straight from the metric's .rrd file. This is keyed by SUBTYPE, because
# the DS layout is a property of the collector module, not of the concept (the
# same disk_mibhost RRD serves disk and memory rows alike).
#
#   total_idx => N : the 0-based position, within metrics.items, of the DS that
#                    holds the total/capacity. disk_mibhost = "Disco Total (1) |
#                    Disco Usado (1)" -> total is index 0.
#
# The 8 byte-valued MEMORY subtypes (cisco_memory, ucd_mem_*, vmware_mem_*) also
# carry their totals in RRD and would slot in here with their own total_idx (and,
# for some, a derived "used"); they are deferred -- see cnm_documentacion_producto.md.
my %RRD_CAPACITY = (
    'disk_mibhost' => { total_idx => 0, source => 'rrd:total' },
);

# Read the capacity (total) for one instance from its RRD file.
# $path is the absolute .rrd path; $cfg is the %RRD_CAPACITY entry.
# Reads each DS's last submitted value (last_ds) and maps it by the DS's own
# .index, so we pick the right total regardless of DS naming. Prefers RRDs::info
# (older RRDs lack lastupdate); falls back to parsing `rrdtool info`.
# Returns ($capacity, $source) or (undef, undef) if not readable.
sub rrd_capacity {
    my ($path, $cfg) = @_;
    my $idx = $cfg->{total_idx};
    my (%name_idx, %name_last);
    if ($HAVE_RRDS_INFO) {
        my $info = RRDs::info($path);
        if (my $e = RRDs::error()) { warnx('RRDs::info %s: %s', $path, $e); return (undef, undef); }
        for my $k (keys %$info) {
            if    ($k =~ /^ds\[(.+?)\]\.index$/)   { $name_idx{$1}  = $info->{$k}; }
            elsif ($k =~ /^ds\[(.+?)\]\.last_ds$/) { $name_last{$1} = $info->{$k}; }
        }
    } else {
        my @out = qx(rrdtool info "$path" 2>/dev/null);
        return (undef, undef) unless @out;
        for my $line (@out) {
            if    ($line =~ /^ds\[(.+?)\]\.index\s*=\s*(\d+)/)              { $name_idx{$1}  = $2; }
            elsif ($line =~ /^ds\[(.+?)\]\.last_ds\s*=\s*"?([^"\s]+)"?/)    { $name_last{$1} = $2; }
        }
    }
    my %last_by_idx;
    $last_by_idx{ $name_idx{$_} } = $name_last{$_} for keys %name_idx;
    my $cap = $last_by_idx{$idx};
    return (undef, undef) unless defined $cap && $cap =~ /^[\d.]+(?:[eE][+-]?\d+)?$/ && $cap > 0;
    return ($cap + 0, $cfg->{source});
}

# ============================================================================
# DB LAYER
# ============================================================================
sub db_connect {
    my $dsn = sprintf 'DBI:mysql:database=%s;host=%s;port=%s',
        $CFG{db_name}, $CFG{db_host}, $CFG{db_port};
    debug('Connecting to %s as %s', $dsn, $CFG{db_user});
    my $dbh = DBI->connect($dsn, $CFG{db_user}, $CFG{db_pass},
        { RaiseError => 1, PrintError => 0, AutoCommit => 1 })
        or die "DB connect failed: $DBI::errstr\n";
    return $dbh;
}

# Build the work-list: active instances of capacity-needing concepts.
# Returns arrayref of hashrefs: { instance_id, iddev, iid, canonical_id,
# instance_info_source }. By default ONLY devices with status=0 (activo) are
# polled. status=1 (de baja) does no polling; status=2 (mantenimiento) is also
# skipped because in practice operators park unreachable equipment there, so SNMP
# would only time out. COALESCE treats NULL/unset status as active.
# --include-inactive overrides. Without --refresh, an instance is selected if it
# still needs capacity OR has never had an instance_info attempt (source NULL);
# a user-provided instance_info (source='user') is non-NULL so it is never re-
# fetched on its account, and is protected at write time besides.
sub fetch_worklist {
    my ($dbh, $opt) = @_;
    # Effective concept = instance override (heterogeneous subtypes, e.g. memory
    # rows inside disk_mibhost) or, failing that, the subtype's mapped concept.
    my $eff = 'COALESCE(i.canonical_override, mc.canonical_id)';
    my @where = ('i.valid_to IS NULL', 'c.needs_instance_capacity = 1', "b.status = 'active'");
    push @where, 'COALESCE(d.status, 0) = 0' unless $opt->{include_inactive};
    my @bind;
    if ($opt->{concept}) { push @where, "$eff = ?"; push @bind, $opt->{concept}; }
    if (defined $opt->{device}) { push @where, 'i.iddev = ?'; push @bind, $opt->{device}; }
    push @where, '(i.capacity IS NULL OR i.instance_info_source IS NULL)' unless $opt->{refresh};
    my $sql = sprintf q{
        SELECT i.instance_id, i.iddev, b.iid, %s AS canonical_id, i.subtype,
               i.instance_info_source,
               m.file_path, m.file, CONVERT(m.items USING latin1) AS items
          FROM sem_instance i
          JOIN sem_metric_concept   mc ON mc.subtype      = i.subtype
          JOIN sem_canonical_concept c ON c.canonical_id  = %s
          JOIN sem_metric_binding    b ON b.instance_id   = i.instance_id
          JOIN devices               d ON d.id_dev        = i.iddev
          JOIN metrics               m ON m.id_metric     = b.idmetric
         WHERE %s
         ORDER BY i.iddev}, $eff, $eff, join(' AND ', @where);
    trace('worklist SQL: %s', $sql);
    return $dbh->selectall_arrayref($sql, { Slice => {} }, @bind);
}

# Resolve a device's SNMP parameters. Returns a hashref describing the session,
# or undef if the device/profile cannot be resolved.
sub fetch_device_snmp {
    my ($dbh, $iddev) = @_;
    my $d = $dbh->selectrow_hashref(
        'SELECT ip, version, community FROM devices WHERE id_dev = ?', undef, $iddev);
    unless ($d && $d->{ip}) { warnx('iddev=%s: not found in devices', $iddev); return undef; }

    my $ver = $d->{version} // '1';
    my %p = (ip => $d->{ip});
    if ($ver eq '3') {
        # community holds the SNMPv3 profile id
        my $pr = $dbh->selectrow_hashref(
            'SELECT sec_name, sec_level, auth_proto, auth_pass, priv_proto, priv_pass
               FROM profiles_snmpv3 WHERE id_profile = ?', undef, $d->{community});
        unless ($pr) {
            warnx('iddev=%s: SNMPv3 profile id=%s not found', $iddev, $d->{community});
            return undef;
        }
        @p{qw(version sec_name sec_level auth_proto auth_pass priv_proto priv_pass)} =
            (3, @{$pr}{qw(sec_name sec_level auth_proto auth_pass priv_proto priv_pass)});
    }
    else {
        $p{version}   = ($ver =~ /2/) ? '2c' : '1';
        $p{community} = $d->{community};
    }
    return \%p;
}

# Write capacity and/or instance_info for one instance (honours --dry-run).
# $cap/$cap_src: write capacity when $cap is defined (also stamps capacity_polled_at).
# $write_info: when true, write instance_info=$info (NULL if empty) + the given
#              $info_src. The caller sets $write_info false when the current
#              source is 'user', so user-provided text is never overwritten.
sub update_instance {
    my ($dbh, $instance_id, $cap, $cap_src, $write_info, $info, $info_src, $dry) = @_;
    my (@set, @bind);
    if (defined $cap) {
        push @set, 'capacity = ?', 'capacity_source = ?', 'capacity_polled_at = NOW()';
        push @bind, $cap, $cap_src;
    }
    if ($write_info) {
        push @set, 'instance_info = ?', 'instance_info_source = ?';
        push @bind, (defined $info && $info ne '' ? $info : undef), $info_src;
    }
    return unless @set;
    if ($dry) {
        info('DRY-RUN: instance_id=%s %s (not written)', $instance_id, join(', ', @set));
        return;
    }
    my $sql = 'UPDATE sem_instance SET ' . join(', ', @set) . ' WHERE instance_id = ?';
    $dbh->prepare_cached($sql)->execute(@bind, $instance_id);
}

# ============================================================================
# SNMP LAYER
# ============================================================================
# Build an SNMP::Session for v1 / v2c / v3 from the params hashref.
sub snmp_session {
    my ($p) = @_;
    my %common = (
        DestHost   => $p->{ip},
        RemotePort => $CFG{snmp_port},
        Timeout    => $CFG{snmp_timeout},
        Retries    => $CFG{snmp_retries},
        UseNumeric => 1,
    );
    my $sess;
    if (($p->{version} // '') eq '3') {
        my %v3 = (Version => 3, SecName => $p->{sec_name},
                  SecLevel => lc($p->{sec_level} || 'noAuthNoPriv'));
        # Add auth/priv material only at the level the profile declares.
        if ($v3{SecLevel} ne 'noauthnopriv') {
            $v3{AuthProto} = uc($p->{auth_proto} || 'MD5');
            $v3{AuthPass}  = $p->{auth_pass};
        }
        if ($v3{SecLevel} eq 'authpriv') {
            $v3{PrivProto} = uc($p->{priv_proto} || 'DES');
            $v3{PrivPass}  = $p->{priv_pass};
        }
        # SNMP.pm expects the canonical spellings:
        $v3{SecLevel} = { noauthnopriv=>'noAuthNoPriv', authnopriv=>'authNoPriv',
                          authpriv=>'authPriv' }->{$v3{SecLevel}} || 'noAuthNoPriv';
        trace('v3 session %s secName=%s level=%s', $p->{ip}, $p->{sec_name}, $v3{SecLevel});
        $sess = SNMP::Session->new(%common, %v3);
    }
    else {
        trace('v%s session %s community=***', $p->{version}, $p->{ip});
        $sess = SNMP::Session->new(%common,
            Version => $p->{version}, Community => $p->{community});
    }
    unless ($sess) { warnx('%s: could not create SNMP session', $p->{ip}); return undef; }
    return $sess;
}

# GET a list of numeric OIDs (chunked). Returns hashref { oid => value }, or
# undef if the device did not answer at all (treated as unreachable).
sub snmp_get_oids {
    my ($sess, $oids) = @_;
    my %val;
    my $answered = 0;
    for (my $i = 0; $i < @$oids; $i += $CFG{get_chunk}) {
        my $end   = $i + $CFG{get_chunk} - 1; $end = $#$oids if $end > $#$oids;
        my @slice = @{$oids}[$i .. $end];
        my $vl    = SNMP::VarList->new(map { [$_] } @slice);
        my @res   = $sess->get($vl);
        if ($sess->{ErrorNum}) {
            warnx('SNMP GET error on %s: %s', $sess->{DestHost}, $sess->{ErrorStr});
            next;   # try remaining chunks; a single bad chunk should not abort
        }
        $answered = 1;
        for my $j (0 .. $#slice) {
            my $v = $vl->[$j]->val;
            $v = undef if !defined $v
                       || $v eq 'NOSUCHOBJECT' || $v eq 'NOSUCHINSTANCE' || $v eq 'ENDOFMIBVIEW';
            $val{ $slice[$j] } = $v;
            trace('  %s = %s', $slice[$j], defined $v ? $v : '<none>');
        }
    }
    return $answered ? \%val : undef;
}

# ============================================================================
# CORE
# ============================================================================
# Process every work item of a single device with one SNMP session.
sub process_device {
    my ($dbh, $iddev, $items, $opt, $stats) = @_;
    $stats->{devices}++;

    my $p = fetch_device_snmp($dbh, $iddev) or do { $stats->{dev_no_params}++; return };
    my $sess = snmp_session($p)             or do { $stats->{dev_no_session}++; return };

    # Collect all OIDs to GET for this device, remembering which belongs to whom.
    my (@oids, @plan);
    for my $it (@$items) {
        my $r = $RESOLVERS{ $it->{canonical_id} } or next;   # skip handled in caller
        my %map = $r->{oids}->($it->{iid});
        push @plan, { item => $it, resolver => $r, labels => { %map } };
        push @oids, values %map;
    }
    return unless @oids;

    debug('iddev=%s (%s): %d instance(s), %d OID(s)', $iddev, $p->{ip}, scalar @plan, scalar @oids);
    my $vals = snmp_get_oids($sess, \@oids);
    unless (defined $vals) {
        warnx('iddev=%s (%s): unreachable / no SNMP answer', $iddev, $p->{ip});
        $stats->{dev_unreachable}++;
        return;
    }

    for my $pl (@plan) {
        $stats->{instances}++;
        my $it = $pl->{item};
        my %by_label = map { $_ => $vals->{ $pl->{labels}{$_} } } keys %{ $pl->{labels} };
        my ($cap, $src, $info) = $pl->{resolver}{compute}->(%by_label);

        # Capacity (may be undeterminable; that is fine, alias can still apply).
        if (defined $cap) { $stats->{updated}++; }
        else {
            warnx('iddev=%s instance_id=%s (%s): capacity not determinable',
                  $iddev, $it->{instance_id}, $it->{canonical_id});
            $stats->{no_capacity}++;
        }

        # instance_info: write only if the resolver yields one AND the current
        # source is not user-provided. Mark attempted ('ifAlias' even when the
        # alias is empty; 'none' when this concept has no text source) so the
        # instance is not re-polled for info every cycle.
        my $cur_src   = $it->{instance_info_source};
        my $user_held = defined $cur_src && $cur_src eq 'user';
        my $write_info = 0;
        my $info_src;
        if (!$user_held) {
            $write_info = 1;
            $info_src = defined $info ? 'ifAlias' : 'none';
        }
        $stats->{info_captured}++ if $write_info && defined $info && $info ne '';

        if (defined $cap || $write_info) {
            info('instance_id=%s %s -> capacity=%s (%s) info=%s',
                 $it->{instance_id}, $it->{canonical_id},
                 (defined $cap ? $cap : 'n/a'), (defined $src ? $src : '-'),
                 ($user_held ? '[user-kept]' : (defined $info && $info ne '' ? "'$info'" : '-')));
            update_instance($dbh, $it->{instance_id}, $cap, $src,
                            $write_info, $info, $info_src, $opt->{dry_run});
        }
    }
}

sub main {
    my %opt;
    GetOptions(
        'dry-run|n'   => \$opt{dry_run},
        'refresh'     => \$opt{refresh},
        'concept=s'   => \$opt{concept},
        'device=i'    => \$opt{device},
        'include-inactive' => \$opt{include_inactive},
        'verbose|v+'  => sub { $VERBOSITY++ },
        'quiet|q'     => sub { $VERBOSITY = L_ERR },
        'debug=i'     => \$VERBOSITY,
        'db-host=s'   => \$CFG{db_host},
        'db-name=s'   => \$CFG{db_name},
        'db-user=s'   => \$CFG{db_user},
        'db-pass=s'   => \$CFG{db_pass},
        'db-port=i'   => \$CFG{db_port},
        'snmp-port=i'    => \$CFG{snmp_port},
        'snmp-timeout=i' => \$CFG{snmp_timeout},
        'snmp-retries=i' => \$CFG{snmp_retries},
        'help|h'      => sub { pod2usage(-verbose => 1) },
        'man'         => sub { pod2usage(-verbose => 2) },
    ) or pod2usage(-verbose => 0);

    info('Starting capacity poller%s', $opt{dry_run} ? ' (DRY-RUN)' : '');
    my $dbh = db_connect();

    my $work = fetch_worklist($dbh, \%opt);
    info('Work-list: %d instance(s)', scalar @$work);

    # Partition: RRD-capacity instances (capacity read from the metric's own
    # .rrd, keyed by subtype) vs SNMP instances (grouped by device).
    my (%by_dev, %stats, %skipped, @rrd_work);
    for my $it (@$work) {
        if ($RRD_CAPACITY{ $it->{subtype} }) { push @rrd_work, $it; next; }
        unless ($RESOLVERS{ $it->{canonical_id} }) {
            $skipped{ $it->{canonical_id} }++;   # concept with no resolver yet
            next;
        }
        push @{ $by_dev{ $it->{iddev} } }, $it;
    }
    warnx('Skipped %d instance(s) of concept %s: no resolver implemented yet', $_->[1], $_->[0])
        for map { [$_, $skipped{$_}] } sort keys %skipped;

    # RRD-capacity instances (disk, and later memory) -- no SNMP, no device session.
    for my $it (@rrd_work) {
        $stats{instances}++;
        my $cfg  = $RRD_CAPACITY{ $it->{subtype} };
        my $path = ($it->{file_path} // '') . ($it->{file} // '');
        my ($cap, $src) = rrd_capacity($path, $cfg);
        if (defined $cap) { $stats{updated}++; }
        else {
            warnx('instance_id=%s (%s) subtype=%s: capacity not readable from %s',
                  $it->{instance_id}, $it->{canonical_id}, $it->{subtype}, $path);
            $stats{no_capacity}++;
        }
        # Mark instance_info attempted ('none': RRD-capacity concepts have no text
        # source) so the instance is not re-selected forever; never touch 'user'.
        my $cur = $it->{instance_info_source};
        my $write_info = !(defined $cur && $cur eq 'user');
        info('instance_id=%s %s -> capacity=%s (%s) [rrd]',
             $it->{instance_id}, $it->{canonical_id}, (defined $cap ? $cap : 'n/a'),
             (defined $src ? $src : '-'));
        update_instance($dbh, $it->{instance_id}, $cap, $src,
                        $write_info, undef, 'none', $opt{dry_run})
            if defined $cap || $write_info;
    }

    for my $iddev (sort { $a <=> $b } keys %by_dev) {
        process_device($dbh, $iddev, $by_dev{$iddev}, \%opt, \%stats);
    }

    $dbh->disconnect;

    my $skipped_total = 0; $skipped_total += $_ for values %skipped;

    # Summary always on STDOUT.
    printf "\n==== Capacity poller summary%s ====\n", $opt{dry_run} ? ' (DRY-RUN)' : '';
    printf "  Devices processed     : %d\n", $stats{devices}        || 0;
    printf "  Devices unreachable   : %d\n", $stats{dev_unreachable}|| 0;
    printf "  Devices w/o params    : %d\n", $stats{dev_no_params}  || 0;
    printf "  Devices w/o session   : %d\n", $stats{dev_no_session} || 0;
    printf "  Instances evaluated   : %d\n", $stats{instances}      || 0;
    printf "  Capacities %-12s: %d\n", ($opt{dry_run} ? 'would-update' : 'updated'),
                                       $stats{updated}     || 0;
    printf "  Not determinable      : %d\n", $stats{no_capacity}    || 0;
    printf "  instance_info captured: %d\n", $stats{info_captured}  || 0;
    printf "  Skipped (no resolver) : %d\n", $skipped_total;
    return ($stats{dev_unreachable} || $stats{no_capacity}) ? 1 : 0;
}

exit main();

__END__

=head1 NAME

cnm_capacity_poller.pl - Populate sem_instance.capacity via SNMP for the CNM semantic layer.

=head1 SYNOPSIS

  cnm_capacity_poller.pl [options]

  # First run: see what it would do, nothing written
  cnm_capacity_poller.pl --dry-run -vv

  # Real run, only interface traffic, only one device (testing)
  cnm_capacity_poller.pl --concept net.iface.traffic_bps --device 501 -v

  # Re-poll everything (e.g. after link renegotiation)
  cnm_capacity_poller.pl --refresh

=head1 DESCRIPTION

Fills the per-instance nominal C<capacity> on C<sem_instance> for concepts
flagged C<needs_instance_capacity=1>. Capacity is what turns a raw gauge into a
saturation SLI (e.g. C<traffic_bps / capacity = link utilisation>). Because it
lives on the stable identity (C<sem_instance>), it survives idmetric/iid churn
and only needs re-polling on C<--refresh> or when the underlying value changes.

The script is B<read-only on CNM> (it only SELECTs device SNMP parameters) and
performs B<SNMP GET only> (never SET). The only table it writes is
C<sem_instance> (columns C<capacity>, C<capacity_source>, C<capacity_polled_at>).

Run it B<after> the Phase-3 reconciliation, so active bindings (and their iids)
are current.

=head2 How it works

=over

=item 1. Builds a work-list: active instances of capacity-needing concepts,
with the iid of their active incarnation (the SNMP index, e.g. ifIndex).

=item 2. Groups the work-list by device and polls each device once.

=item 3. Resolves the device's SNMP parameters from C<devices> (v1/v2c via
C<community>); for C<version='3'> the C<community> column holds the
C<profiles_snmpv3.id_profile> with the v3 credentials.

=item 4. GETs the capacity OIDs (chunked) and computes the capacity per the
concept resolver, then writes it back.

=back

=head1 OPTIONS

=over

=item B<--dry-run, -n>     Poll and report, do not write.

=item B<--refresh>         Re-poll instances that already have a capacity.

=item B<--concept ID>      Limit to one canonical_id (default: all resolvers).

=item B<--device N>        Limit to one iddev (testing).

=item B<--include-inactive> Poll devices regardless of status. By default ONLY
status=0 (activo) devices are polled: status=1 (de baja) does no polling, and
status=2 (mantenimiento) is also skipped because operators routinely park
unreachable equipment there, so SNMP would only time out.

=item B<-v, --verbose>     Increase verbosity (stackable: -v INFO, -vv DEBUG, -vvv TRACE).

=item B<--debug N>         Set verbosity level explicitly (0=ERROR..4=TRACE).

=item B<-q, --quiet>       Errors only.

=item B<--db-host/name/user/pass/port>  DB connection (defaults from CNM_DB_* env).

=item B<--snmp-port/timeout/retries>    SNMP tuning (timeout in microseconds).

=item B<--help, --man>     Usage / full manual.

=back

=head1 ADDING A NEW CAPACITY TYPE

Add one entry to C<%RESOLVERS>, keyed by the concept's canonical_id, e.g.:

  'device.disk.bytes' => {
      desc    => 'Storage size = hrStorageSize * hrStorageAllocationUnits',
      oids    => sub { my $iid = shift;
                       ( size  => ".1.3.6.1.2.1.25.2.3.1.5.$iid",
                         units => ".1.3.6.1.2.1.25.2.3.1.4.$iid" ) },
      compute => sub { my %v = @_;
                       return (undef,undef) unless $v{size} && $v{units};
                       ($v{size} * $v{units}, 'hrStorageSize') },
  };

Nothing else changes: the work-list, polling, chunking and write-back are
concept-agnostic. For device-level (single-instance) concepts the iid is 'ALL';
have the resolver emit the scalar OID (".0") and ignore the iid.

=head1 REQUIRED SCHEMA

The audit columns are part of cnm_semantic_schema_v3.sql. For an already-created
table apply:

  ALTER TABLE sem_instance
    ADD COLUMN capacity_source    VARCHAR(32) NULL AFTER capacity,
    ADD COLUMN capacity_polled_at TIMESTAMP   NULL DEFAULT NULL AFTER capacity_source,
    ADD COLUMN instance_info        VARCHAR(255) CHARACTER SET latin1 NULL AFTER capacity_polled_at,
    ADD COLUMN instance_info_source VARCHAR(16)  NULL AFTER instance_info;

=head1 EXIT STATUS

0 on a clean run; 1 if any device was unreachable or any capacity was not
determinable (so cron can flag attention).

=cut
