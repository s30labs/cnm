#####################################################################################################
# File: (CNMControl::Kind::Device.pm)
# Description:
#	Kind "device" (devices). Key: the IP (PRIMARY KEY (ip,host_idx); host_idx=1).
#
#	{ "kind": "device", "name": "tda-norte-01", "domain": "tiendas.local",
#	  "ip": "10.20.1.10", "type": "Router", "critic": 50,
#	  "snmp": { "version": 0 },                 0 = no SNMP; 1 and 2 need "community"
#	critic and snmp are optional: when the device is created they default to 50 and version 0;
#	an existing device is never changed with a default (only with what the state declares).
#	  "geodata": "40.4168,-3.7038",            devices.geodata (varchar(30))
#	  "status": 0,                              0 active, 1 inactive, 2 maintenance (0 when created)
#	  "fields": { "CNM-METRICS": "icmp-basic.json" } }     user fields
#
#	Creation follows the same path as the CSV provisioning of the web console: a file in the
#	format read by get_devices_from_csv_web ('&|&' separator, in /var/www/html/onm/tmp/) and
#	prov_do_set_device_metric with init=11, which creates the device (devices, user fields,
#	network, organizational profile Global, record) and builds no assistant and no metrics
#	(crawler/bin/ProvisionLite.pm:529-583, :985-1033 and :1107).
#
#	Modify, phase 1 (decision of 26-nov-2026, PROY §9): in a device that already exists with
#	the same IP and name, type, critic, geodata and the user fields that the state declares
#	and that differ are changed (action "update", with the value before and after). Like the
#	console (custom_pro onm/inc/class.cnmdevice.php, save()), but only the columns that change:
#	  devices                UPDATE of type, critic, geodata
#	  devices_custom_data    INSERT IGNORE of the row and UPDATE columnaN; the empty columns
#	                         of that device are set to '-' (save_custom_fields)
#	  tips                   the device record, rebuilt by the engine
#	                         (Crawler::Store::store_device_record, Store.pm:939)
#	All the updates go in one transaction, and each value is checked against the value
#	before of the plan (SELECT ... FOR UPDATE): if someone changed it meanwhile, nothing is
#	written. An empty user field is written as '-', as the console does.
#	Modify, phase 2 (PROY §9, 26-nov-2026): status, snmp.version and snmp.community too.
#	Changing any of them obliges the crawlers' data to be regenerated, as the console does
#	with workset (do_workset(), class.cnmdevice.php:1380). cnm-control does the same work as
#	workset, in the foreground and in its own process, so that a failure is an error of the
#	apply: Crawler::Store set_graph_subtables, store_crawler_work for each device and
#	consolidate_work_tables once (crawler/bin/workset:122-140; ProvisionLite.pm:1736-1747).
#	The community is never shown: not in the plan, not in the messages.
#	A device with SNMPv3 (community holds the id of profiles_snmpv3) keeps its SNMP: error.
#	When version or community change, the device is asked again for its MIB-2 system data,
#	as the provisioning does (prov_do_set_device_metric, ProvisionLite.pm:921, with
#	Crawler::SNMP snmp_mib2_system, SNMP.pm:1126) and as the console does on every save
#	(do_mib2_system): sysloc, sysdesc, sysoid, enterprise, mac, mac_vendor, network and
#	switch, written as store_device does (Store.pm:884-913). If the device does not answer,
#	the values of the engine are kept ('** sin respuesta snmp **') and the apply warns
#	(decision of 27-nov-2026). With version 0 nothing is asked: the same values are written.
#	Two more effects of the device screen of the console (modificar_dispositivo,
#	custom_pro onm/mod_dispositivo_detalle.php:382), the usual path to modify a device
#	(decision of 28-nov-2026; PROY-CNM-cnm-control-Identidad §2):
#	  alerts, alerts_read    when critic changes, the critic of the alerts of the device
#	                         (:505-511, mod_Configure.sql:184-185), in the same transaction
#	  syslog.reload          when name, domain, ip, critic or status change,
#	                         the file that makes notificationsd reload syslog-ng, which runs
#	                         trap_manager; trap_manager keeps name, domain, critic and status
#	                         of each IP in memory (:656, onm/inc/Store.php:2868;
#	                         Crawler.pm:3536; Crawler/LogManager/SNMPTrap.pm:55)
#	The console does both on every save; cnm-control only when the value changes.
#	Modify, phase 3 (decisions of 27 and 28-nov-2026; PROY-CNM-cnm-control-Identidad):
#	name, domain or ip, explicitly, with "from" and the current values:
#	  { "kind": "device", "name": "sede-10", "domain": "local", "ip": "10.1.1.10",
#	    "from": { "name": "sede-01" } }                      rename (name and/or domain)
#	  { ..., "ip": "10.1.1.50", "from": { "ip": "10.1.1.10" } }      IP change
#	One identity change per resource. In the inventory, the columns name_from, domain_from
#	and ip_from (CNMControl::Profile). The same as the device screen of the console:
#	  devices                       UPDATE of name, domain or ip (the new IP or name.domain
#	                                must be free, checked again in the transaction)
#	  metrics, prov_template_metrics2iid   rename: the suffix ' (name.domain)' of label
#	                                (change_metric_label, mod_dispositivo_detalle.php:1381)
#	  cfg_remote_alerts2device, task2device   IP change: target and ip
#	                                (change_device_ip, mod_dispositivo_detalle.php:1400)
#	  then workset and MIB-2 (IP change), the reload of trap_manager, the assistant and
#	  applications (prov_device_app_metrics, in the foreground) and the record.
#	The titles (c_label) that carry the old name or IP are not changed: the plan lists them.
#	Without "from", an IP that belongs to another name is a conflict.
#	validate, key and diff are pure; read and apply use $ctx->{dbh} and $ctx->{provision}.
#	Design: cnm-docs, PROY-CNM-cnm-control-Diseno §3.2 and §5.
# Set Tab=3
#####################################################################################################
package CNMControl::Kind::Device;
$VERSION='0.80';
use strict;

my %KEYS    = map { $_=>1 } qw(kind name domain ip from type critic geodata status snmp fields _domain_default);
our $TMP_WEB = '/var/www/html/onm/tmp';	# 'our': the tests change it
my $SEP     = '&|&';
# What trap_manager keeps of each IP (Crawler/LogManager/SNMPTrap.pm:316-334, :519-527)
my @TRAP_CACHE = qw(name domain ip critic status);
our $RELOAD = 'syslog.reload';		# in $TMP_WEB: the file of reload_trap_manager (onm/inc/Store.php:2870)
my @HEADER  = ('NOMBRE','DOMINIO','IP','LOCALIZACION','DESCRIPCION','OID','MAC','CRIT','TIPO',
					'ESTADO','COMUNIDAD','VERSION','PERFIL ORGANIZATIVO','GESTOR','GEODATA');

sub order { return 20; }
sub key   { my ($c,$r)=@_; return $r->{ip}; }

# store_device builds its SQL by pasting the values (crawler/bin/Crawler/Store.pm:858-870)
# and the CSV uses '&|&': nothing that breaks either of them is accepted.
# A change for the plan and the messages: the community is never shown
sub _show { my ($a,$c)=@_; return ($a eq 'community') ? 'community (cambia; no se muestra)' : "$a '$c->[0]' -> '$c->[1]'"; }

# Hint when a value carries a CSV separator: the inventory line was probably split wrong
sub _sep_hint { my $v=shift; return ($v =~ /[;:,\t]/) ? " (lleva ':', ';', ',' o tabulador: puede que el separador del CSV este mal puesto; en el inventario es ';')" : ''; }
sub _is_clean { my $v=shift; return ((defined $v) && ($v !~ /['"\\`;\r\n]/) && (index($v,$SEP)<0)) ? 1 : 0; }

# Rules of name, domain and ip (also for name_from, domain_from and ip_from)
my %CHECK = (
	name   => sub { my ($v,$k)=@_; return ($v =~ /^[A-Za-z0-9][\w\-]{0,49}$/) ? '' :
						"$k no valido '$v': solo letras, cifras, _ y -, empezando por letra o cifra, hasta 50 (devices.name)"._sep_hint($v); },
	domain => sub { my ($v,$k)=@_; return ($v =~ /^[A-Za-z0-9][\w.\-]{0,29}$/) ? '' :
						"$k no valido '$v': solo letras, cifras, _, - y ., empezando por letra o cifra, hasta 30 (devices.domain)"._sep_hint($v); },
	ip     => sub { my ($v,$k)=@_; return (($v =~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/) && ! grep { $_ > 255 } ($1,$2,$3,$4)) ? '' : "$k no valida '$v'"; },
);

sub validate {
my ($c,$r)=@_;
	foreach my $k (keys %$r) { return (undef,"clave desconocida '$k'") if (! $KEYS{$k}); }
	foreach my $k ('name','domain','ip') { return (undef,"falta \"$k\"") if ((! defined $r->{$k}) || ($r->{$k} eq '')); }
	my %said = (name=>'nombre', domain=>'dominio', ip=>'ip');
	foreach my $k ('name','domain','ip') { my $e = $CHECK{$k}->($r->{$k}, $said{$k}); return (undef,$e) if ($e); }
	my %n = ( kind=>'device', name=>$r->{name}, domain=>$r->{domain}, ip=>$r->{ip} );
	$n{_domain_default}=1 if ($r->{_domain_default});
	# Phase 3: "from" holds the current values of what changes. One identity change per
	# resource: the name and/or the domain (the device is found by its IP), or the IP (the
	# device is found by its name). Decision of 27-nov-2026.
	if (defined $r->{from}) {
		my $f = $r->{from};
		return (undef,'"from" tiene que ser un objeto con los valores actuales: name y domain, o ip') if ((ref($f) ne 'HASH') || (! %$f));
		foreach my $k (keys %$f) { return (undef,"from: clave desconocida '$k' (name, domain o ip)") if ($k !~ /^(name|domain|ip)$/); }
		return (undef,'un cambio de identidad por recurso: el nombre o el dominio (name_from, domain_from) o la IP (ip_from), no los dos')
			if (defined $f->{ip} && (defined $f->{name} || defined $f->{domain}));
		foreach my $k (sort keys %$f) {
			return (undef,"${k}_from vacio") if ((! defined $f->{$k}) || ref($f->{$k}) || ($f->{$k} eq ''));
			my $e = $CHECK{$k}->($f->{$k}, "${k}_from"); return (undef,$e) if ($e);
		}
		if (defined $f->{ip}) { return (undef,"ip_from es igual que ip ($r->{ip}): no hay cambio de IP") if ($f->{ip} eq $r->{ip}); }
		else {
			my $old = (defined $f->{name} ? $f->{name} : $r->{name}).'.'.(defined $f->{domain} ? $f->{domain} : $r->{domain});
			return (undef,"name_from/domain_from: el nombre completo no cambia ($old)") if (lc($old) eq lc("$r->{name}.$r->{domain}"));
		}
		$n{from} = { %$f };
	}
	if (defined $r->{type}) {
		return (undef,'"type" no valido') if (! _is_clean($r->{type}) || $r->{type} eq '');
		$n{type}=$r->{type};
	}
	# critic and snmp: only what is declared. The defaults (50, version 0) are applied when
	# the device is created, never to an existing one (decision of 26-nov-2026)
	if (defined $r->{critic}) {
		return (undef,'critic tiene que ser 25, 50, 75 o 100') if ($r->{critic} !~ /^(25|50|75|100)$/);
		$n{critic} = $r->{critic};
	}
	if (defined $r->{status}) {
		return (undef,'status tiene que ser 0 (activo), 1 (inactivo) o 2 (mantenimiento)') if ($r->{status} !~ /^[012]$/);
		$n{status} = "$r->{status}";
	}
	if (defined $r->{geodata}) {
		return (undef,'"geodata" no valido') if (! _is_clean($r->{geodata}) || $r->{geodata} eq '');
		return (undef,'"geodata" de mas de 30 caracteres (devices.geodata)') if (length($r->{geodata}) > 30);
		$n{geodata}=$r->{geodata};
	}
	# {} (a profile whose SNMP cells are empty) declares nothing
	if (defined $r->{snmp} && ((ref($r->{snmp}) ne 'HASH') || %{$r->{snmp}})) {
		my $s = $r->{snmp};
		return (undef,'"snmp" tiene que ser un objeto') if (ref($s) ne 'HASH');
		foreach my $k (keys %$s) { return (undef,"snmp: clave desconocida '$k'") if ($k !~ /^(version|community)$/); }
		# A community without a version is an error: defaulting to 0 would take SNMP away
		# from an existing device
		return (undef,'snmp.version obligatoria cuando se da snmp.community') if (! defined $s->{version});
		my $v = "$s->{version}";
		return (undef,'snmp.version: 0, 1 o 2 (v3 llega en el MVP)') if ($v !~ /^[012]$/);
		if ($v ne '0') {
			return (undef,'snmp.community obligatoria con version 1 o 2') if ((! defined $s->{community}) || ($s->{community} eq ''));
			return (undef,'snmp.community con caracteres no admitidos') if (! _is_clean($s->{community}));
		}
		$n{snmp} = { version=>$v+0, ($v ne '0' ? (community=>$s->{community}) : ()) };
	}
	if (defined $r->{fields}) {
		return (undef,'"fields" tiene que ser un objeto') if (ref($r->{fields}) ne 'HASH');
		foreach my $k (keys %{$r->{fields}}) {
			return (undef,"fields: nombre o valor no admitido en '$k'") if (! _is_clean($k) || ! _is_clean($r->{fields}{$k}));
		}
		$n{fields} = { %{$r->{fields}} } if (%{$r->{fields}});
	}
	return (\%n, undef);
}

#----------------------------------------------------------------------------
# read: by IP, plus the devices with the same name.domain (to detect a name already used
# with another IP), the device types and the user fields.
#----------------------------------------------------------------------------
sub read {
my ($c,$ctx,$rs)=@_;
	my $dbh=$ctx->{dbh};
	my %cur=();
	my @ips  = map { ($_->{ip}, (($_->{from} && defined $_->{from}{ip}) ? $_->{from}{ip} : ())) } @$rs;
	my @fqdn = map { lc("$_->{name}.$_->{domain}") } @$rs;
	# Renames: the devices with the new name in any domain (the domain may come from the
	# default of the profile and the device keep its own)
	my @names = map { lc $_->{name} } grep { $_->{from} && ! defined $_->{from}{ip} } @$rs;
	my (%by_ip,%by_fqdn,%by_nm);
	if (@ips) {
		my $q = "SELECT id_dev,name,domain,ip,type,critic,geodata,status,version,community FROM devices WHERE ip IN (".join(',',('?') x @ips).")";
		foreach my $d (@{ $dbh->selectall_arrayref($q, { Slice=>{} }, @ips) }) { push @{$by_ip{$d->{ip}}}, $d; }
		$q = "SELECT id_dev,name,domain,ip FROM devices WHERE LOWER(CONCAT(name,'.',domain)) IN (".join(',',('?') x @fqdn).")";
		foreach my $d (@{ $dbh->selectall_arrayref($q, { Slice=>{} }, @fqdn) }) { push @{$by_fqdn{lc("$d->{name}.$d->{domain}")}}, $d; }
		if (@names) {
			$q = "SELECT id_dev,name,domain,ip FROM devices WHERE LOWER(name) IN (".join(',',('?') x @names).")";
			foreach my $d (@{ $dbh->selectall_arrayref($q, { Slice=>{} }, @names) }) { push @{$by_nm{lc $d->{name}}}, $d; }
		}
	}
	foreach my $r (@$rs) {
		my $x = { by_ip=>$by_ip{$r->{ip}} || [], by_name=>$by_fqdn{lc("$r->{name}.$r->{domain}")} || [] };
		if ($r->{from}) {
			if (defined $r->{from}{ip}) { $x->{from_ip} = $by_ip{$r->{from}{ip}} || []; }
			else { $x->{same_name} = $by_nm{lc $r->{name}} || []; }
		}
		$cur{$r->{ip}} = $x;
	}
	$ctx->{cache}{types} ||= { map { $_->[0] => 1 } @{ $dbh->selectall_arrayref("SELECT descr FROM cfg_host_types") } };
	if (! $ctx->{cache}{fields}) {
		# Field name -> column of devices_custom_data: columnaN, N = devices_custom_types.id
		# (crawler/bin/ProvisionLite.pm:540-547)
		foreach my $t (@{ $dbh->selectall_arrayref("SELECT id,descr FROM devices_custom_types") }) {
			$ctx->{cache}{fields}{uc $t->[1]} = $t->[1];
			$ctx->{cache}{field_cols}{uc $t->[1]} = 'columna'.$t->[0];
		}
		$ctx->{cache}{fields} ||= {};
	}
	# Current user fields of the existing devices that declare "fields", to compare them
	my %want = map { ($_->{ip} => 1, (($_->{from} && defined $_->{from}{ip}) ? ($_->{from}{ip} => 1) : ())) } grep { $_->{fields} } @$rs;
	my @ids = map { $_->{id_dev} } map { @{$by_ip{$_}||[]} } sort keys %want;
	if (@ids) {
		my $q = "SELECT * FROM devices_custom_data WHERE id_dev IN (".join(',',('?') x @ids).")";
		my %by_id = map { $_->{id_dev} => $_ } @{ $dbh->selectall_arrayref($q, { Slice=>{} }, @ids) };
		foreach my $d (map { @$_ } values %by_ip) { $d->{custom} = $by_id{$d->{id_dev}} || {}; }
	}
	# Titles of the metrics of the devices that may change their identity: the plan warns
	# about the ones that carry the old name or IP (decision of 27-nov-2026)
	my %idn = map { $_->{id_dev} => 1 } map { @{$cur{$_->{ip}}{by_ip}}, @{$cur{$_->{ip}}{from_ip}||[]} } grep { $_->{from} } @$rs;
	if (my @i = sort { $a <=> $b } keys %idn) {
		my $q = "SELECT id_dev,name,c_label FROM metrics WHERE id_dev IN (".join(',',('?') x @i).") AND c_label IS NOT NULL AND c_label<>''";
		my %lab=(); push @{$lab{$_->[0]}}, [ $_->[1], $_->[2] ] foreach (@{ $dbh->selectall_arrayref($q, undef, @i) });
		$_->{labels} = \%lab foreach (values %cur);
	}
	return \%cur;
}

#----------------------------------------------------------------------------
# diff: a device to create is recorded in $ctx->{pending} so that the metric kind (planned
# afterwards) accepts metrics of a device that does not exist yet. A device that changes its
# name or IP is recorded in $ctx->{dev_alias} (new name or IP => id_dev), so that the metrics
# of this state find it by the new one, and in $ctx->{gone} (old name or IP => new), so that
# a metric that still uses the old one is an error.
#----------------------------------------------------------------------------
sub diff {
my ($c,$r,$cur,$ctx)=@_;
my (@acc,@err,@warn);
	$cur ||= {};
	my $fqdn = "$r->{name}.$r->{domain}";
	push @err, "el tipo '$r->{type}' no existe (crear tipos llega en el MVP)"
		if (defined $r->{type} && ! $ctx->{cache}{types}{$r->{type}});
	foreach my $k (sort keys %{$r->{fields} || {}}) {
		push @err, "el campo de usuario '$k' no existe (cnm-control list fields)" if (! $ctx->{cache}{fields}{uc $k});
	}
	if ($r->{from}) { _diff_identity($r,$cur,$ctx,\@acc,\@err,\@warn); }
	else {
		my @by_ip   = @{$cur->{by_ip} || []};
		my @by_name = grep { $_->{ip} ne $r->{ip} } @{$cur->{by_name} || []};
		if (@by_ip > 1) { push @err, scalar(@by_ip)." dispositivos con esa IP"; }
		elsif (@by_ip == 1) {
			my $d=$by_ip[0];
			$fqdn = _keep_domain($r,$d,$ctx);
			if (lc("$d->{name}.$d->{domain}") ne lc($fqdn)) {
				push @err, "la IP ya es de $d->{name}.$d->{domain} (id_dev=$d->{id_dev}) (para cambiarle el nombre: columna name_from)";
			}
			else { _update($r,$d,$fqdn,{},'update',$ctx,\@acc,\@err); }
		}
		else {
			if (@by_name) { push @err, "el nombre $fqdn ya lo usa la IP $by_name[0]{ip} (id_dev=$by_name[0]{id_dev}) (para cambiarle la IP: columna ip_from)"; }
			elsif ($ctx->{claimed}{lc $fqdn} || $ctx->{claimed}{$r->{ip}}) { push @err, "el nombre o la IP los toma otro dispositivo de este estado al cambiar su identidad"; }
			elsif (! @err) {
				$ctx->{pending}{lc $fqdn}=1; $ctx->{pending}{$r->{ip}}=1;
				push @acc, { kind=>'device', op=>'create', ref=>$r->{ip}, resource=>$r,
								 text=>"$fqdn $r->{ip}".(defined $r->{type} ? " type=$r->{type}" : '')." snmp=v".($r->{snmp} ? $r->{snmp}{version} : 0).(defined $r->{critic} ? " critic=$r->{critic}" : '').(defined $r->{status} ? " status=$r->{status}" : '')
									.(%{$r->{fields}||{}} ? ' custom: '.join(', ', map { "$_=$r->{fields}{$_}" } sort keys %{$r->{fields}}) : '') };
			}
		}
	}
	if (@err) {		# for the derived errors of the metrics
		$ctx->{failed}{lc $fqdn}=1; $ctx->{failed}{$r->{ip}}=1;
	}
	return (\@acc,\@err,\@warn);
}

# The domain came from the default of the profile, which only applies when the device is
# created: the existing device keeps its own (27-nov-2026). Returns the name.domain to use.
sub _keep_domain {
my ($r,$d,$ctx)=@_;
	my $fqdn = "$r->{name}.$r->{domain}";
	if ($r->{_domain_default} && (lc $d->{name} eq lc $r->{name}) && (lc $d->{domain} ne lc $r->{domain})) {
		$ctx->{fqdn_alias}{lc $fqdn} = "$d->{name}.$d->{domain}";
		return "$d->{name}.$d->{domain}";
	}
	return $fqdn;
}

#----------------------------------------------------------------------------
# _diff_identity: phase 3 (PROY-CNM-cnm-control-Diseno §9, PROY-CNM-cnm-control-Identidad).
#  IP change (from.ip):   the device is the one with the IP from.ip and the name of the state.
#  Rename (from.name and/or from.domain): the device is the one with the IP of the state and
#                         the old name.domain.
# If the device already has the new identity (an apply done before, or the check after
# apply), there is nothing to change but the other attributes.
#----------------------------------------------------------------------------
sub _diff_identity {
my ($r,$cur,$ctx,$acc,$err,$warn)=@_;
	my $f = $r->{from};
	my @n = @{$cur->{by_ip} || []};
	return push @$err, scalar(@n)." dispositivos con la IP $r->{ip}" if (@n > 1);
	if (defined $f->{ip}) {
		my @o = @{$cur->{from_ip} || []};
		return push @$err, scalar(@o)." dispositivos con la IP $f->{ip}" if (@o > 1);
		if (@o) {
			my $d = $o[0];
			my $fqdn = _keep_domain($r,$d,$ctx);
			my $dn = "$d->{name}.$d->{domain}";
			if (lc $dn ne lc $fqdn) { return push @$err, "la IP $f->{ip} es de $dn (id_dev=$d->{id_dev}), no de $fqdn"; }
			if (@n) { return push @$err, "la IP nueva $r->{ip} ya es de $n[0]{name}.$n[0]{domain} (id_dev=$n[0]{id_dev})"; }
			if ($ctx->{claimed}{$r->{ip}} || $ctx->{pending}{$r->{ip}}) { return push @$err, "la IP nueva $r->{ip} la usa otro dispositivo de este estado"; }
			$ctx->{claimed}{$r->{ip}}=1; $ctx->{gone}{$f->{ip}}=$r->{ip}; $ctx->{dev_alias}{$r->{ip}}=$d->{id_dev};
			push @$warn, _label_warning($cur, $d, [ $f->{ip} ]);
			return _update($r,$d,$fqdn,{ ip=>[ $d->{ip}, $r->{ip} ] },'ip',$ctx,$acc,$err);
		}
		if (@n) {
			my $fqdn = _keep_domain($r,$n[0],$ctx);
			return _update($r,$n[0],$fqdn,{},'update',$ctx,$acc,$err) if (lc("$n[0]{name}.$n[0]{domain}") eq lc $fqdn);		# already done
			return push @$err, "no hay ningun dispositivo con la IP $f->{ip}, y la IP $r->{ip} es de $n[0]{name}.$n[0]{domain} (id_dev=$n[0]{id_dev})";
		}
		return push @$err, "no hay ningun dispositivo con la IP $f->{ip} (ni con la nueva, $r->{ip}): nada que cambiar";
	}
	return push @$err, "no hay ningun dispositivo con la IP $r->{ip}: nada que renombrar" if (! @n);
	my $d = $n[0];
	my $nd = ($r->{_domain_default} && ! defined $f->{domain}) ? $d->{domain} : $r->{domain};
	my $old = (defined $f->{name} ? $f->{name} : $r->{name}).'.'.(defined $f->{domain} ? $f->{domain} : $nd);
	my $new = "$r->{name}.$nd";
	my $dn = "$d->{name}.$d->{domain}";
	$ctx->{fqdn_alias}{lc "$r->{name}.$r->{domain}"} = $new if (lc $nd ne lc $r->{domain});
	if (lc $dn eq lc $new) { return _update($r,$d,$new,{},'update',$ctx,$acc,$err); }		# already done
	if (lc $dn ne lc $old) { return push @$err, "la IP $r->{ip} es de $dn (id_dev=$d->{id_dev}), no de $old"; }
	my @other = grep { ($_->{id_dev} != $d->{id_dev}) && (lc("$_->{name}.$_->{domain}") eq lc $new) } @{$cur->{same_name} || []};
	if (@other) { return push @$err, "el nombre nuevo $new ya lo usa la IP $other[0]{ip} (id_dev=$other[0]{id_dev})"; }
	if ($ctx->{claimed}{lc $new} || $ctx->{pending}{lc $new}) { return push @$err, "el nombre nuevo $new lo usa otro dispositivo de este estado"; }
	my %id = ();
	$id{name}   = [ $d->{name}, $r->{name} ] if ($d->{name} ne $r->{name});
	$id{domain} = [ $d->{domain}, $nd ]      if ($d->{domain} ne $nd);
	$ctx->{claimed}{lc $new}=1; $ctx->{gone}{lc $dn}=$new;
	$ctx->{dev_alias}{lc $new}=$d->{id_dev}; $ctx->{dev_alias}{lc "$r->{name}.$r->{domain}"}=$d->{id_dev};
	push @$warn, _label_warning($cur, $d, [ map { $id{$_}[0] } grep { $id{$_} } qw(name domain) ]);
	return _update($r,$d,$dn,\%id,'rename',$ctx,$acc,$err,$new);
}

#----------------------------------------------------------------------------
# _label_warning: the titles (c_label) of the device that carry one of the old values. They
# are not rewritten: "sede-1" is inside "sede-12" (decision of 27-nov-2026).
#----------------------------------------------------------------------------
sub _label_warning {
my ($cur,$d,$old)=@_;
	my @l = grep { my $t=lc $_->[1]; grep { index($t, lc $_) >= 0 } @$old } @{($cur->{labels} || {})->{$d->{id_dev}} || []};
	return () if (! @l);
	my @s = map { "$_->[0] \"$_->[1]\"" } sort { $a->[0] cmp $b->[0] } @l;
	my $more = (@s > 5) ? ' y '.(@s - 5).' mas' : '';
	return scalar(@l).' metricas con '.join(' o ', map { "'$_'" } @$old).' en el titulo, que no se cambia: '.join(', ', @s[0 .. (@s > 5 ? 4 : $#s)]).$more
			.'. Para cambiarlo: columna c_label.<subtipo> o --set c_label.<subtipo>="... {name}"';
}

#----------------------------------------------------------------------------
# _update: the action that modifies an existing device $d: the identity changes \%id
# (name, domain or ip) and the attributes of the state that differ. One device, one action:
# a device that two resources of the state touch is an error.
#----------------------------------------------------------------------------
sub _update {
my ($r,$d,$fqdn,$id,$op,$ctx,$acc,$err,$new)=@_;
	if (my $o = $ctx->{dev_touch}{$d->{id_dev}}) {
		return push @$err, "el dispositivo $d->{name}.$d->{domain} (id_dev=$d->{id_dev}) ya esta en $o: un dispositivo, un recurso";
	}
	$ctx->{dev_touch}{$d->{id_dev}} = $r->{_origin} || 'otro recurso de este estado';
	# Phase 1: data-only attributes. Phase 2: status and SNMP, with workset
	my (%chg,%fchg);
	foreach my $a (qw(type critic geodata status)) {
		next if (! defined $r->{$a});
		my $now = defined $d->{$a} ? "$d->{$a}" : '';
		$chg{$a} = [ $now, "$r->{$a}" ] if ($now ne "$r->{$a}");
	}
	if ($r->{snmp}) {
		if (defined $d->{version} && ($d->{version} == 3)) {
			return push @$err, "tiene SNMPv3 (credencial en profiles_snmpv3): su SNMP no se modifica en esta fase";
		}
		my $now = defined $d->{version} ? "$d->{version}" : '';
		$chg{version} = [ $now, "$r->{snmp}{version}" ] if ($now ne "$r->{snmp}{version}");
		if ($r->{snmp}{version} > 0) {
			my $c = defined $d->{community} ? $d->{community} : '';
			$chg{community} = [ $c, $r->{snmp}{community} ] if ($c ne $r->{snmp}{community});
		}
	}
	foreach my $k (sort keys %{$r->{fields} || {}}) {
		my $col = $ctx->{cache}{field_cols}{uc $k} or next;
		my $now = (defined $d->{custom} && defined $d->{custom}{$col} && $d->{custom}{$col} ne '') ? $d->{custom}{$col} : '-';
		$fchg{$col} = [ $now, $r->{fields}{$k}, $ctx->{cache}{fields}{uc $k} ] if ($now ne $r->{fields}{$k});
	}
	return if ((! %chg) && (! %fchg) && (! %$id));
	return if (@$err);
	my %all = (%chg, %$id);
	my $ws     = (grep { $all{$_} } qw(status version community ip)) ? 1 : 0;
	my $mib2   = ($all{version} || $all{community} || $all{ip}) ? 1 : 0;
	my $alerts = $all{critic} ? 1 : 0;
	my $traps  = (grep { $all{$_} } @TRAP_CACHE) ? 1 : 0;
	my $labels = ($all{name} || $all{domain}) ? 1 : 0;
	my $remote = $all{ip} ? 1 : 0;
	my $assist = ($all{name} || $all{domain} || $all{ip}) ? 1 : 0;
	my @what = ( (map { _show($_,$all{$_}) } grep { ($op ne 'rename') || ($_ ne 'name' && $_ ne 'domain') } sort keys %all),
					 (map { "$fchg{$_}[2] '$fchg{$_}[0]' -> '$fchg{$_}[1]'" } sort keys %fchg) );
	my $head = ($op eq 'rename') ? "$fqdn -> $new".(@what ? ',' : '') : $fqdn;
	push @$acc, { kind=>'device', op=>$op, ref=>$r->{ip}, id_dev=>$d->{id_dev}, ip=>$d->{ip}, changes=>\%all, fchanges=>\%fchg,
					  workset=>$ws, mib2=>$mib2, alerts=>$alerts, traps=>$traps, labels=>$labels, remote=>$remote, assistant=>$assist,
					  ($labels ? (old_full=>"$d->{name}.$d->{domain}", new_full=>$new) : ()),
					  text=>join(' ', $head, (@what ? join(', ',@what) : ()))
							.($labels ? ' (+ etiquetas de sus metricas)' : '').($remote ? ' (+ alertas remotas y tareas)' : '')
							.($mib2 ? ' (+ MIB-2)' : '').($ws ? ' (+ workset)' : '').($alerts ? ' (+ critic de sus alertas)' : '')
							.($assist ? ' (+ asistente)' : '').($traps ? ' (+ recarga de traps)' : '') };
	return;
}

#----------------------------------------------------------------------------
# apply: one file for all the creations and a single call to the engine.
# The file is written under a temporary name and renamed when complete (style guide §2.6).
#----------------------------------------------------------------------------
sub apply {
my ($c,$ctx,$acc)=@_;
	my @create = grep { $_->{op} eq 'create' } @$acc;
	my @update = grep { $_->{op} =~ /^(update|rename|ip)$/ } @$acc;
	my $err = @create ? _apply_create($ctx,\@create) : [];
	return $err if (@$err);
	return @update ? _apply_update($ctx,\@update) : [];
}

#----------------------------------------------------------------------------
# _apply_create: one CSV file for all the creations and one call to the engine
#----------------------------------------------------------------------------
sub _apply_create {
my ($ctx,$acc)=@_;
my @err=();
	my @rs = map { $_->{resource} } @$acc;
	my %fields=(); foreach my $r (@rs) { $fields{$ctx->{cache}{fields}{uc $_}}=1 foreach (keys %{$r->{fields}||{}}); }
	my @fc = sort keys %fields;
	my @lines = ( join($SEP, @HEADER, @fc) );
	foreach my $r (@rs) {
		my %rc = map { uc($_) => $r->{fields}{$_} } keys %{$r->{fields}||{}};
		push @lines, join($SEP, $r->{name}, $r->{domain}, $r->{ip}, '', '', '', '', (defined $r->{critic} ? $r->{critic} : 50),
			(defined $r->{type} ? $r->{type} : ''), (defined $r->{status} ? $r->{status} : 0), ($r->{snmp} ? ($r->{snmp}{community}||'') : ''), ($r->{snmp} ? $r->{snmp}{version} : 0), '', 1, (defined $r->{geodata} ? $r->{geodata} : ''),
			map { defined $rc{uc $_} ? $rc{uc $_} : '' } @fc);
	}
	my $file = "cnm-control-".time()."-$$.csv";
	my $path = "$TMP_WEB/$file";
	open(my $fh,'>:encoding(UTF-8)',"$path.tmp") or return [ "no se puede escribir $path.tmp: $!" ];
	print $fh "$_\n" foreach (@lines);
	close($fh) or return [ "no se puede escribir $path.tmp: $!" ];
	rename("$path.tmp",$path) or return [ "no se puede renombrar $path.tmp: $!" ];
	my $prov = $ctx->{provision}->();
	eval { $prov->prov_do_set_device_metric({ 'file'=>$file, 'init'=>11, 'cid'=>$ctx->{cid} }); };
	push @err, "prov_do_set_device_metric: $@" if ($@);
	unlink $path if (-e $path);		# the engine deletes it after reading it; if it is still here, it was not read
	# What counts is what is left in devices
	foreach my $r (@rs) {
		my $d = $ctx->{dbh}->selectrow_hashref("SELECT id_dev,name,domain FROM devices WHERE ip=?", undef, $r->{ip});
		if ((! $d) || (lc("$d->{name}.$d->{domain}") ne lc("$r->{name}.$r->{domain}"))) {
			push @err, "$r->{name}.$r->{domain} $r->{ip}: no quedo dado de alta";
		}
	}
	return \@err;
}

#----------------------------------------------------------------------------
# _apply_update: one transaction for every device; then the records (tips)
#----------------------------------------------------------------------------
sub _apply_update {
my ($ctx,$acc)=@_;
	my $dbh=$ctx->{dbh};
	my @cols = sort values %{$ctx->{cache}{field_cols}||{}};
	eval {
		$dbh->begin_work();
		foreach my $x (@$acc) {
			my $id = $x->{id_dev};
			# Precondition: the values before are still the ones of the plan
			my $d = $dbh->selectrow_hashref("SELECT ip,name,domain,type,critic,geodata,status,version,community FROM devices WHERE id_dev=? FOR UPDATE", undef, $id);
			die "id_dev=$id ($x->{ip}): ya no existe\n" if ((! $d) || ($d->{ip} ne $x->{ip}));
			foreach my $a (sort keys %{$x->{changes}}) {
				my $now = defined $d->{$a} ? "$d->{$a}" : '';
				next if ($now eq $x->{changes}{$a}[0]);
				die "id_dev=$id ($x->{ip}): community ha cambiado desde el plan\n" if ($a eq 'community');
				die "id_dev=$id ($x->{ip}): $a vale '$now' y el plan esperaba '$x->{changes}{$a}[0]'; ha cambiado desde el plan\n";
			}
			if (%{$x->{fchanges}}) {
				my $cd = $dbh->selectrow_hashref("SELECT * FROM devices_custom_data WHERE id_dev=? FOR UPDATE", undef, $id) || {};
				foreach my $col (sort keys %{$x->{fchanges}}) {
					my $now = (defined $cd->{$col} && $cd->{$col} ne '') ? $cd->{$col} : '-';
					die "id_dev=$id ($x->{ip}): $x->{fchanges}{$col}[2] vale '$now' y el plan esperaba '$x->{fchanges}{$col}[0]'; ha cambiado desde el plan\n"
						if ($now ne $x->{fchanges}{$col}[0]);
				}
			}
			# The new identity is still free (devices: PRIMARY KEY (ip,host_idx); name.domain is not
			# unique in the database, but cnm-control does not give a name that another device has)
			if ($x->{changes}{ip}) {
				my ($n) = $dbh->selectrow_array("SELECT COUNT(*) FROM devices WHERE ip=?", undef, $x->{changes}{ip}[1]);
				die "id_dev=$id ($x->{ip}): la IP nueva $x->{changes}{ip}[1] ya la tiene otro dispositivo; ha cambiado desde el plan\n" if ($n);
			}
			if ($x->{labels}) {
				my ($n) = $dbh->selectrow_array("SELECT COUNT(*) FROM devices WHERE LOWER(CONCAT(name,'.',domain))=? AND id_dev<>?", undef, lc $x->{new_full}, $id);
				die "id_dev=$id ($x->{ip}): el nombre nuevo $x->{new_full} ya lo tiene otro dispositivo; ha cambiado desde el plan\n" if ($n);
			}
			if (my @a = sort keys %{$x->{changes}}) {
				$dbh->do("UPDATE devices SET ".join(',', map { "$_=?" } @a)." WHERE id_dev=?", undef, (map { $x->{changes}{$_}[1] } @a), $id);
			}
			if ($x->{labels}) {
				# change_metric_label (custom_pro onm/mod_dispositivo_detalle.php:1381): only the
				# suffix ' (name.domain)' at the end of the label, in the metrics and in the template
				my ($o,$n) = (" ($x->{old_full})", " ($x->{new_full})");
				foreach my $tb ('metrics','prov_template_metrics2iid') {
					$dbh->do("UPDATE $tb SET label=CONCAT(LEFT(label,CHAR_LENGTH(label)-CHAR_LENGTH(?)),?) WHERE id_dev=? AND RIGHT(label,CHAR_LENGTH(?))=?",
								undef, $o, $n, $id, $o, $o);
				}
			}
			if ($x->{remote}) {
				# change_device_ip (mod_dispositivo_detalle.php:1400): remote alerts and tasks of the IP
				$dbh->do("UPDATE cfg_remote_alerts2device SET target=? WHERE target=?", undef, $x->{changes}{ip}[1], $x->{ip});
				$dbh->do("UPDATE task2device SET ip=? WHERE ip=?", undef, $x->{changes}{ip}[1], $x->{ip});
			}
			if ($x->{alerts}) {
				# update_critic_in_alerts and update_critic_in_alerts_read (mod_Configure.sql:184-185)
				$dbh->do("UPDATE alerts SET critic=? WHERE id_device=?", undef, $x->{changes}{critic}[1], $id);
				$dbh->do("UPDATE alerts_read SET critic=? WHERE id_device=?", undef, $x->{changes}{critic}[1], $id);
			}
			if (my @c = sort keys %{$x->{fchanges}}) {
				# save_custom_fields (custom_pro onm/inc/class.cnmdevice.php)
				$dbh->do("INSERT IGNORE INTO devices_custom_data (id_dev) VALUES (?)", undef, $id);
				$dbh->do("UPDATE devices_custom_data SET ".join(',', map { "$_=?" } @c)." WHERE id_dev=?", undef,
							(map { $x->{fchanges}{$_}[1] eq '' ? '-' : $x->{fchanges}{$_}[1] } @c), $id);
				$dbh->do("UPDATE devices_custom_data SET $_='-' WHERE id_dev=? AND ($_ IS NULL OR $_='')", undef, $id) foreach (@cols);
			}
		}
		$dbh->commit();
	};
	if ($@) { my $e=$@; chomp $e; eval { $dbh->rollback(); }; return [ "dispositivos (deshecho, no se ha modificado ninguno): $e" ]; }

	# MIB-2 system data of the devices whose SNMP changed
	foreach my $x (grep { $_->{mib2} } @$acc) {
		my $w = eval { _mib2($ctx, $x->{id_dev}) };
		$w = "MIB-2 no actualizada: $@" if ($@);
		chomp $w if (defined $w);
		push @{$ctx->{apply_warnings}}, "device $x->{ref}: $w" if ($w);
	}

	# Crawlers' data of the devices whose status or SNMP changed: the work of workset
	my @err=();
	my @ws = map { $_->{id_dev} } grep { $_->{workset} } @$acc;
	if (@ws) {
		my $st = eval { $ctx->{provision}->()->istore() };
		my $e = '';
		if (! $st) { $e = 'sin acceso al motor'; }
		else {
			my $tnow = time();
			eval {
				$st->set_graph_subtables($dbh);
				foreach my $id (@ws) {
					my $rv = $st->store_crawler_work($dbh, $id, $tnow, $ctx->{cid});
					die "store_crawler_work id_dev=$id: ".($st->errorstr()||$st->error())."\n" if ((! defined $rv) && $st->error());
				}
				$st->consolidate_work_tables($dbh);
			};
			$e = $@ if ($@);
		}
		if ($e) {
			chomp $e;
			push @err, "dispositivos modificados, pero no se han regenerado los datos de los crawlers ($e). Ejecutar: /opt/crawler/bin/workset -c $ctx->{cid} -i ".join(',',@ws);
		}
	}

	# trap_manager: the reload is asked as the console does (append '1' to the file)
	if (grep { $_->{traps} } @$acc) {
		my $f = "$TMP_WEB/$RELOAD";
		my $ok = open(my $fh,'>>',$f);
		$ok = ((print $fh '1') && close($fh)) ? 1 : 0 if ($ok);
		push @err, "dispositivos modificados, pero no se ha pedido la recarga del gestor de traps ($f: $!). Ejecutar: echo 1 >> $f" if (! $ok);
	}

	# Assistant and applications of the devices whose name, domain or IP changed, in the
	# foreground and in this process (decision of 28-nov-2026): as the provisioning does
	# (prov_do_set_device_metric, ProvisionLite.pm:858-876) and as the console does on every
	# save in the background (mod_dispositivo_detalle.php:659-664). It also runs the local
	# scripts of /opt/cnm.local, if there are any (ProvisionLite.pm:3689-3726).
	my @as = grep { $_->{assistant} } @$acc;
	if (@as) {
		my $p = eval { $ctx->{provision}->() };
		my $e = $p ? '' : 'sin acceso al motor';
		if ($p) {
			eval { $p->get_check_vectors(); foreach my $x (@as) { $p->reset_check_vectors(); $p->prov_device_app_metrics($x->{id_dev}); } };
			$e = $@ if ($@);
		}
		if ($e) {
			chomp $e;
			push @err, "dispositivos modificados, pero no se ha recalculado su asistente ($e). Ejecutar: /opt/crawler/bin/prov_device_app_metrics -c $ctx->{cid} -i ".join(',', map { $_->{id_dev} } @as);
		}
		else {
			foreach my $x (@as) {
				my ($n) = $dbh->selectrow_array("SELECT COUNT(*) FROM prov_default_metrics2device WHERE id_dev=?", undef, $x->{id_dev});
				push @{$ctx->{apply_warnings}}, "device $x->{ref}: asistente recalculado, pero vacio: el equipo no ofrece ninguna metrica (no responde en su IP?)" if (! $n);
			}
		}
	}

	# Device records: the data is already written; a failure here is a warning. The engine logs
	# the whole record at level info, and the record carries the SNMP community: that call
	# runs with the store at level warning, so the community does not reach engine.log.
	my $store = eval { $ctx->{provision}->()->istore() };
	foreach my $x (@$acc) {
		if (! $store) { push @{$ctx->{apply_warnings}}, "device $x->{ref}: no se ha regenerado su ficha (sin acceso al motor)"; next; }
		my $lv = $store->log_level();
		my $ip = $x->{changes}{ip} ? $x->{changes}{ip}[1] : $x->{ip};
		eval { $store->log_level('warning'); $store->store_device_record($dbh, $ip); };
		my $e = $@;
		$store->log_level($lv);
		push @{$ctx->{apply_warnings}}, "device $x->{ref}: modificado, pero no se ha regenerado su ficha: $e" if ($e);
	}
	return \@err;
}

#----------------------------------------------------------------------------
# _mib2($ctx, $id_dev) -> warning text or ''
# Asks the device for its MIB-2 system data with the SNMP object of the provisioning and
# writes the columns that store_device writes from it. The SNMP data comes from the
# database (already committed), so the community is not carried in the action.
#----------------------------------------------------------------------------
my @MIB2 = qw(sysloc sysdesc sysoid enterprise mac mac_vendor network switch);
sub _mib2 {
my ($ctx,$id)=@_;
	my $dbh=$ctx->{dbh};
	my $d = $dbh->selectrow_hashref("SELECT name,domain,ip,version,community FROM devices WHERE id_dev=?", undef, $id);
	return 'no se encuentra para preguntar por MIB-2' if (! $d);
	my %dev = (name=>$d->{name}, domain=>$d->{domain}, ip=>$d->{ip}, host_ip=>$d->{ip}, version=>$d->{version}, community=>$d->{community});
	my ($rc,$rcstr,$w) = (1,'','');
	if ($d->{version} == 0) {
		# What snmp_mib2_system leaves when there is no answer (SNMP.pm:1130-1134)
		@dev{qw(sysdesc sysoid sysloc enterprise)} = ((('** sin respuesta snmp **') x 3), 0);
	}
	else {
		my $snmp = eval { my $p=$ctx->{provision}->(); my $s=$p->snmp(); $s->store($p->istore()); $s->dbh($dbh); $s };
		return 'MIB-2 no consultada (sin acceso al motor)' if (! $snmp);
		($rc,$rcstr) = eval { $snmp->snmp_mib2_system(\%dev) };
		if ($@) { $rc=1; $rcstr=$@; chomp $rcstr; }
		$w = "no responde por SNMP con los datos nuevos ($rcstr); se guarda '** sin respuesta snmp **', como hace el motor" if ($rc);
		# rc 0 comes with rcstr 'OK' (measured on cnm-11-8-test, 27-nov-2026); a part of the
		# MIB that did not answer in time adds this text (Crawler/SNMP.pm, snmp_mib2_system)
		$w = "MIB-2 incompleta: $rcstr" if ((! $rc) && ($rcstr =~ /Timeout en partes de la MIB/));
	}
	# As store_device (Crawler/Store.pm:884-913)
	if (defined $dev{sysdesc}) { $dev{sysdesc} =~ s/[\r\n]/ /g; $dev{sysdesc} = substr($dev{sysdesc},0,250); }
	$dev{mac} = substr($dev{mac},0,17) if (defined $dev{mac});
	my @c = grep { defined $dev{$_} } @MIB2;
	$dbh->do("UPDATE devices SET ".join(',', map { "$_=?" } @c)." WHERE id_dev=?", undef, (map { $dev{$_} } @c), $id) if (@c);
	return $w;
}

1;
