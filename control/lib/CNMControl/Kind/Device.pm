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
#	  "fields": { "CNM-METRICS": "icmp-basic.json" } }     user fields
#
#	Creation follows the same path as the CSV provisioning of the web console: a file in the
#	format read by get_devices_from_csv_web ('&|&' separator, in /var/www/html/onm/tmp/) and
#	prov_do_set_device_metric with init=11, which creates the device (devices, user fields,
#	network, organizational profile Global, record) and builds no assistant and no metrics
#	(crawler/bin/ProvisionLite.pm:529-583, :985-1033 and :1107).
#
#	Skeleton: create only. A device that already exists with the same IP and name is
#	accepted and left untouched; an IP that belongs to another name is a conflict.
#	validate, key and diff are pure; read and apply use $ctx->{dbh} and $ctx->{provision}.
#	Design: cnm-docs, PROY-CNM-cnm-control-Diseno §3.2 and §5.
# Set Tab=3
#####################################################################################################
package CNMControl::Kind::Device;
$VERSION='0.30';
use strict;

my %KEYS    = map { $_=>1 } qw(kind name domain ip type critic snmp fields);
our $TMP_WEB = '/var/www/html/onm/tmp';	# 'our': the tests change it
my $SEP     = '&|&';
my @HEADER  = ('NOMBRE','DOMINIO','IP','LOCALIZACION','DESCRIPCION','OID','MAC','CRIT','TIPO',
					'ESTADO','COMUNIDAD','VERSION','PERFIL ORGANIZATIVO','GESTOR','GEODATA');

sub order { return 20; }
sub key   { my ($c,$r)=@_; return $r->{ip}; }

# store_device builds its SQL by pasting the values (crawler/bin/Crawler/Store.pm:858-870)
# and the CSV uses '&|&': nothing that breaks either of them is accepted.
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
	if (defined $r->{snmp}) {
		my $s = $r->{snmp};
		return (undef,'"snmp" tiene que ser un objeto') if (ref($s) ne 'HASH');
		foreach my $k (keys %$s) { return (undef,"snmp: clave desconocida '$k'") if ($k !~ /^(version|community)$/); }
		my $v = defined $s->{version} ? "$s->{version}" : '0';
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
		my $q = "SELECT id_dev,name,domain,ip,type,critic,version,community FROM devices WHERE ip IN (".join(',',('?') x @ips).")";
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
			# Warn only about real differences: the skeleton does not modify existing devices
			my @dif=();
			push @dif, "type '".($d->{type}||'')."' -> '$r->{type}'" if (defined $r->{type} && $r->{type} ne ($d->{type}||''));
			push @dif, "critic $d->{critic} -> $r->{critic}" if (defined $r->{critic} && defined $d->{critic} && ($r->{critic} != $d->{critic}));
			if ($r->{snmp} && defined $d->{version}) {
				push @dif, "snmp version $d->{version} -> $r->{snmp}{version}" if ($r->{snmp}{version} != $d->{version});
				push @dif, "snmp community distinta (no se muestra)"
					if (($r->{snmp}{version} > 0) && ($r->{snmp}{version} == $d->{version}) && (($d->{community}||'') ne $r->{snmp}{community}));
			}
			foreach my $k (sort keys %{$r->{fields} || {}}) {
				my $col = $ctx->{cache}{field_cols}{uc $k} or next;
				my $now = (defined $d->{custom} && defined $d->{custom}{$col}) ? $d->{custom}{$col} : '-';
				push @dif, "$k '$now' -> '$r->{fields}{$k}'" if ($now ne $r->{fields}{$k});
			}
			push @warn, "ya existe (id_dev=$d->{id_dev}) y difiere: ".join(', ',@dif)."; el esqueleto no modifica dispositivos existentes" if (@dif);
		}
	}
	else {
		if (@by_name) { push @err, "el nombre $fqdn ya lo usa la IP $by_name[0]{ip} (id_dev=$by_name[0]{id_dev})"; }
		elsif (! @err) {
			$ctx->{pending}{lc $fqdn}=1; $ctx->{pending}{$r->{ip}}=1;
			push @acc, { kind=>'device', op=>'create', ref=>$r->{ip}, resource=>$r,
							 text=>"$fqdn $r->{ip}".(defined $r->{type} ? " type=$r->{type}" : '')." snmp=v".($r->{snmp} ? $r->{snmp}{version} : 0).(defined $r->{critic} ? " critic=$r->{critic}" : '')
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
my @err=();
	my @rs = map { $_->{resource} } @$acc;
	my %fields=(); foreach my $r (@rs) { $fields{$ctx->{cache}{fields}{uc $_}}=1 foreach (keys %{$r->{fields}||{}}); }
	my @fc = sort keys %fields;
	my @lines = ( join($SEP, @HEADER, @fc) );
	foreach my $r (@rs) {
		my %rc = map { uc($_) => $r->{fields}{$_} } keys %{$r->{fields}||{}};
		push @lines, join($SEP, $r->{name}, $r->{domain}, $r->{ip}, '', '', '', '', (defined $r->{critic} ? $r->{critic} : 50),
			(defined $r->{type} ? $r->{type} : ''), 0, ($r->{snmp} ? ($r->{snmp}{community}||'') : ''), ($r->{snmp} ? $r->{snmp}{version} : 0), '', 1, '',
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

1;
