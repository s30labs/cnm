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
#	name, domain and ip are not modified yet (phase 3). An IP that belongs to another name
#	is a conflict.
#	validate, key and diff are pure; read and apply use $ctx->{dbh} and $ctx->{provision}.
#	Design: cnm-docs, PROY-CNM-cnm-control-Diseno §3.2 and §5.
# Set Tab=3
#####################################################################################################
package CNMControl::Kind::Device;
$VERSION='0.60';
use strict;

my %KEYS    = map { $_=>1 } qw(kind name domain ip type critic geodata status snmp fields);
our $TMP_WEB = '/var/www/html/onm/tmp';	# 'our': the tests change it
my $SEP     = '&|&';
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

sub validate {
my ($c,$r)=@_;
	foreach my $k (keys %$r) { return (undef,"clave desconocida '$k'") if (! $KEYS{$k}); }
	foreach my $k ('name','domain','ip') { return (undef,"falta \"$k\"") if ((! defined $r->{$k}) || ($r->{$k} eq '')); }
	return (undef,"nombre no valido '$r->{name}': solo letras, cifras, _ y -, empezando por letra o cifra, hasta 50 (devices.name)"._sep_hint($r->{name}))
		if ($r->{name}  !~ /^[A-Za-z0-9][\w\-]{0,49}$/);
	return (undef,"dominio no valido '$r->{domain}': solo letras, cifras, _, - y ., empezando por letra o cifra, hasta 30 (devices.domain)"._sep_hint($r->{domain}))
		if ($r->{domain} !~ /^[A-Za-z0-9][\w.\-]{0,29}$/);
	return (undef,"ip no valida '$r->{ip}'")
		if (($r->{ip} !~ /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/) || grep { $_ > 255 } ($1,$2,$3,$4));
	my %n = ( kind=>'device', name=>$r->{name}, domain=>$r->{domain}, ip=>$r->{ip} );
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
	my @ips = map { $_->{ip} } @$rs;
	my @fqdn = map { lc("$_->{name}.$_->{domain}") } @$rs;
	if (@ips) {
		my $q = "SELECT id_dev,name,domain,ip,type,critic,geodata,status,version,community FROM devices WHERE ip IN (".join(',',('?') x @ips).")";
		foreach my $d (@{ $dbh->selectall_arrayref($q, { Slice=>{} }, @ips) }) { push @{$cur{$d->{ip}}{by_ip}}, $d; }
		$q = "SELECT id_dev,name,domain,ip FROM devices WHERE LOWER(CONCAT(name,'.',domain)) IN (".join(',',('?') x @fqdn).")";
		my %by_fqdn=();
		foreach my $d (@{ $dbh->selectall_arrayref($q, { Slice=>{} }, @fqdn) }) { push @{$by_fqdn{lc("$d->{name}.$d->{domain}")}}, $d; }
		foreach my $r (@$rs) { $cur{$r->{ip}}{by_name} = $by_fqdn{lc("$r->{name}.$r->{domain}")} || []; }
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
	my %want = map { $_->{ip} => 1 } grep { $_->{fields} } @$rs;
	my @ids = map { $_->{id_dev} } grep { $want{$_->{ip}} } map { @{$_->{by_ip}||[]} } values %cur;
	if (@ids) {
		my $q = "SELECT * FROM devices_custom_data WHERE id_dev IN (".join(',',('?') x @ids).")";
		my %by_id = map { $_->{id_dev} => $_ } @{ $dbh->selectall_arrayref($q, { Slice=>{} }, @ids) };
		foreach my $c (values %cur) {
			foreach my $d (@{$c->{by_ip}||[]}) { $d->{custom} = $by_id{$d->{id_dev}} || {}; }
		}
	}
	return \%cur;
}

#----------------------------------------------------------------------------
# diff: a device to create is recorded in $ctx->{pending} so that the metric kind (planned
# afterwards) accepts metrics of a device that does not exist yet.
#----------------------------------------------------------------------------
sub diff {
my ($c,$r,$cur,$ctx)=@_;
my (@acc,@err,@warn);
	my $fqdn = "$r->{name}.$r->{domain}";
	my @by_ip   = $cur ? @{$cur->{by_ip} || []} : ();
	my @by_name = $cur ? grep { $_->{ip} ne $r->{ip} } @{$cur->{by_name} || []} : ();
	push @err, "el tipo '$r->{type}' no existe (crear tipos llega en el MVP)"
		if (defined $r->{type} && ! $ctx->{cache}{types}{$r->{type}});
	foreach my $k (sort keys %{$r->{fields} || {}}) {
		push @err, "el campo de usuario '$k' no existe (cnm-control list fields)" if (! $ctx->{cache}{fields}{uc $k});
	}
	if (@by_ip > 1) { push @err, scalar(@by_ip)." dispositivos con esa IP"; }
	elsif (@by_ip == 1) {
		my $d=$by_ip[0];
		if (lc("$d->{name}.$d->{domain}") ne lc($fqdn)) {
			push @err, "la IP ya es de $d->{name}.$d->{domain} (id_dev=$d->{id_dev})";
		}
		else {
			# Phase 1: data-only attributes. Phase 2: status and SNMP, with workset
			my (%chg,%fchg);
			foreach my $a (qw(type critic geodata status)) {
				next if (! defined $r->{$a});
				my $now = defined $d->{$a} ? "$d->{$a}" : '';
				$chg{$a} = [ $now, "$r->{$a}" ] if ($now ne "$r->{$a}");
			}
			if ($r->{snmp}) {
				if (defined $d->{version} && ($d->{version} == 3)) {
					push @err, "tiene SNMPv3 (credencial en profiles_snmpv3): su SNMP no se modifica en esta fase";
				}
				else {
					my $now = defined $d->{version} ? "$d->{version}" : '';
					$chg{version} = [ $now, "$r->{snmp}{version}" ] if ($now ne "$r->{snmp}{version}");
					if ($r->{snmp}{version} > 0) {
						my $c = defined $d->{community} ? $d->{community} : '';
						$chg{community} = [ $c, $r->{snmp}{community} ] if ($c ne $r->{snmp}{community});
					}
				}
			}
			foreach my $k (sort keys %{$r->{fields} || {}}) {
				my $col = $ctx->{cache}{field_cols}{uc $k} or next;
				my $now = (defined $d->{custom} && defined $d->{custom}{$col} && $d->{custom}{$col} ne '') ? $d->{custom}{$col} : '-';
				$fchg{$col} = [ $now, $r->{fields}{$k}, $ctx->{cache}{fields}{uc $k} ] if ($now ne $r->{fields}{$k});
			}
			if ((%chg || %fchg) && (! @err)) {
				my $ws = (grep { $chg{$_} } qw(status version community)) ? 1 : 0;
				my $mib2 = ($chg{version} || $chg{community}) ? 1 : 0;
				push @acc, { kind=>'device', op=>'update', ref=>$r->{ip}, id_dev=>$d->{id_dev}, ip=>$r->{ip}, changes=>\%chg, fchanges=>\%fchg, workset=>$ws, mib2=>$mib2,
								 text=>"$fqdn ".join(', ', (map { _show($_,$chg{$_}) } sort keys %chg),
															(map { "$fchg{$_}[2] '$fchg{$_}[0]' -> '$fchg{$_}[1]'" } sort keys %fchg)).($mib2 ? ' (+ MIB-2)' : '').($ws ? ' (+ workset)' : '') };
			}
		}
	}
	else {
		if (@by_name) { push @err, "el nombre $fqdn ya lo usa la IP $by_name[0]{ip} (id_dev=$by_name[0]{id_dev})"; }
		elsif (! @err) {
			$ctx->{pending}{lc $fqdn}=1; $ctx->{pending}{$r->{ip}}=1;
			push @acc, { kind=>'device', op=>'create', ref=>$r->{ip}, resource=>$r,
							 text=>"$fqdn $r->{ip}".(defined $r->{type} ? " type=$r->{type}" : '')." snmp=v".($r->{snmp} ? $r->{snmp}{version} : 0).(defined $r->{critic} ? " critic=$r->{critic}" : '').(defined $r->{status} ? " status=$r->{status}" : '')
								.(%{$r->{fields}||{}} ? ' custom: '.join(', ', map { "$_=$r->{fields}{$_}" } sort keys %{$r->{fields}}) : '') };
		}
	}
	if (@err) { $ctx->{failed}{lc $fqdn}=1; $ctx->{failed}{$r->{ip}}=1; }	# for the derived errors of the metrics
	return (\@acc,\@err,\@warn);
}

#----------------------------------------------------------------------------
# apply: one file for all the creations and a single call to the engine.
# The file is written under a temporary name and renamed when complete (style guide §2.6).
#----------------------------------------------------------------------------
sub apply {
my ($c,$ctx,$acc)=@_;
	my @create = grep { $_->{op} eq 'create' } @$acc;
	my @update = grep { $_->{op} eq 'update' } @$acc;
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
			my $d = $dbh->selectrow_hashref("SELECT ip,type,critic,geodata,status,version,community FROM devices WHERE id_dev=? FOR UPDATE", undef, $id);
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
			if (my @a = sort keys %{$x->{changes}}) {
				$dbh->do("UPDATE devices SET ".join(',', map { "$_=?" } @a)." WHERE id_dev=?", undef, (map { $x->{changes}{$_}[1] } @a), $id);
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
		push @{$ctx->{apply_warnings}}, "device $x->{ip}: $w" if ($w);
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

	# Device records: the data is already written; a failure here is a warning. The engine logs
	# the whole record at level info, and the record carries the SNMP community: that call
	# runs with the store at level warning, so the community does not reach engine.log.
	my $store = eval { $ctx->{provision}->()->istore() };
	foreach my $x (@$acc) {
		if (! $store) { push @{$ctx->{apply_warnings}}, "device $x->{ip}: no se ha regenerado su ficha (sin acceso al motor)"; next; }
		my $lv = $store->log_level();
		eval { $store->log_level('warning'); $store->store_device_record($dbh, $x->{ip}); };
		my $e = $@;
		$store->log_level($lv);
		push @{$ctx->{apply_warnings}}, "device $x->{ip}: modificado, pero no se ha regenerado su ficha: $e" if ($e);
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
