#####################################################################################################
# File: (CNMControl::Profile.pm)
# Description:
#	Profile + inventory => desired state (list of resources).
#
#	A profile is a template of resources with {param} placeholders. The inventory is a CSV
#	(';' separator, first line = parameter names) with one row per thing to configure.
#	A column named custom.<field> is not a parameter: it carries the value of the user field
#	<field> for the device of that row (any order, case-insensitive; an empty cell leaves the
#	field alone). It overrides the same field set by the profile. Design: PROY §3.3.
#	A column named c_label.<subtype> carries the title of the metric <subtype> of that row
#	(for instance c_label.mon_icmp): an empty cell keeps the c_label of the profile, a value
#	overrides it. The row must have exactly one metric of that subtype.
#	A column named like an attribute of the device (domain, type, critic, status, geodata,
#	version, community), or device.<attribute>, needs no parameter: it goes to the one device
#	resource of the profile (an empty cell leaves the attribute alone; version and community
#	go to "snmp"). If the profile has a parameter with that name that does not mean the same
#	attribute ("type" of a view, for instance), the bare column is the parameter and
#	device.<attribute> is the attribute; if it does mean it, they are the same column.
#	--set column=value fills that column in every row where the cell is empty: a cell wins
#	over --set, and --set over the default of the profile (decision of 27-nov-2026).
#	The domain of a device that comes from the default of the profile (no cell, no --set)
#	is marked "_domain_default": an existing device found by its IP keeps its own domain
#	(CNMControl::Kind::Device).
#	In a list, '|' separates elements: "users": ["{users}"] with users=noc|operador1
#	gives two users (separator chosen by the project management, 26-nov-2026).
#	Each row instantiates every resource of the profile. Resources repeated across rows
#	(the same view, for instance) are merged by CNMControl::Core when identical and are an
#	error when they differ.
#
#	{
#	  "version": 1,
#	  "descr": "free text",
#	  "parameters": {
#	     "name":   { "required": true },
#	     "domain": { "default": "tiendas.local" },
#	     "view":   { "default": "Tiendas" }
#	  },
#	  "resources": [
#	     { "kind": "device", "name": "{name}", "domain": "{domain}", "ip": "{ip}" },
#	     { "kind": "metric", "device": "{name}.{domain}", "subtype": "disp_icmp",
#	       "c_label": "Disponibilidad {name}", "views": ["{view}"] }
#	  ]
#	}
#
#	Pure module: it does not touch the database. Only read_file reads a file.
#	Design: cnm-docs, PROY-CNM-cnm-control-Diseno §3.3.
# Set Tab=3
#####################################################################################################
package CNMControl::Profile;
$VERSION='0.40';
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(check_profile parse_inventory expand read_file);

# Attributes of a device that an inventory column may carry without a parameter
our @DEVICE_ATTRS = qw(domain type critic status geodata version community);
my %DEVICE_ATTRS = map { $_=>1 } @DEVICE_ATTRS;

my %PROFILE_KEYS = map { $_=>1 } qw(version descr parameters resources);
my %PARAM_KEYS   = map { $_=>1 } qw(required default descr);

#----------------------------------------------------------------------------
# read_file($path) -> ($text, $error)
#----------------------------------------------------------------------------
sub read_file {
my ($path)=@_;
	open(my $fh,'<:raw',$path) or return (undef, "no se puede leer $path: $!");
	local $/; my $t=<$fh>; close $fh;
	# Excel adds a BOM when it saves as "CSV UTF-8"; it is not part of the first column
	$t =~ s/^\xEF\xBB\xBF//;
	if (! utf8::decode($t)) {
		# Not UTF-8 (Excel's plain "CSV" is Windows-1252 in Spanish): say where, change nothing
		my $n=0;
		foreach my $l (split(/\n/,$t)) { $n++; my $x=$l; last if (! utf8::decode($x)); }
		return (undef, "$path: no esta en UTF-8 (primera linea con problemas: $n). Guardalo como CSV UTF-8 o conviertelo: iconv -f WINDOWS-1252 -t UTF-8");
	}
	return ($t, undef);
}

#----------------------------------------------------------------------------
# check_profile($data) -> ($profile, $error)
#----------------------------------------------------------------------------
sub check_profile {
my ($p)=@_;
	return (undef,'el perfil no es un objeto JSON') if (ref($p) ne 'HASH');
	foreach my $k (keys %$p) { return (undef,"perfil: clave desconocida '$k'") if (! $PROFILE_KEYS{$k}); }
	return (undef,'perfil: falta "version": 1') if ((! defined $p->{version}) || ($p->{version} ne '1'));
	return (undef,'perfil: "parameters" tiene que ser un objeto') if (ref($p->{parameters}) ne 'HASH');
	return (undef,'perfil: "resources" tiene que ser una lista no vacia')
		if ((ref($p->{resources}) ne 'ARRAY') || (! @{$p->{resources}}));
	foreach my $n (sort keys %{$p->{parameters}}) {
		return (undef,"perfil: nombre de parametro no valido '$n'") if ($n !~ /^[a-z][a-z0-9_]*$/);
		my $d=$p->{parameters}{$n};
		return (undef,"perfil: el parametro '$n' tiene que ser un objeto") if (ref($d) ne 'HASH');
		foreach my $k (keys %$d) { return (undef,"perfil: parametro '$n': clave desconocida '$k'") if (! $PARAM_KEYS{$k}); }
	}
	# Every {x} used in the resources must be declared
	my %used=();
	_walk($p->{resources}, sub { my $s=shift; $used{$1}=1 while ($s =~ /\{([^{}]*)\}/g); });
	foreach my $u (sort keys %used) {
		return (undef,"perfil: se usa {$u} y no esta en \"parameters\"") if (! exists $p->{parameters}{$u});
	}
	return ($p, undef);
}

#----------------------------------------------------------------------------
# parse_inventory($text, $profile, \%set) -> (\@rows, \@errors, \%set_used)
# Each row: { line=>N, values=>{param=>value}, explicit=>{param=>1}, custom=>{field=>value},
# labels=>{subtype=>title}, attrs=>{attribute=>value} } with defaults already applied;
# custom, labels and attrs hold only the non-empty values. explicit: the parameters that
# came from a cell or from --set (not from the default of the profile).
# %set: column => value (--set); %set_used: the columns of %set this profile understood.
#----------------------------------------------------------------------------
sub parse_inventory {
my ($text,$profile,$set)=@_;
my (@rows,@err);
	$set ||= {};
	my %used=();
	my ($header,$nl)=(undef,0);
	my @setval=();		# index of the header => value of --set
	foreach my $l (split(/\r?\n/, $text)) {
		$nl++;
		next if ($l =~ /^\s*(#|$)/);
		my @c = map { my $x=$_; $x =~ s/^\s+|\s+$//g; $x } split(/;/,$l,-1);
		if (! $header) {
			$header=[]; my %seen=();
			foreach my $col (@c) {
				my ($spec,$e) = _column($col, $profile);
				if ($e) { push @err, "inventario linea $nl: $e"; next; }
				push @err, "inventario linea $nl: columna '$col' repetida" if ($seen{$spec->{id}}++);
				push @$header, $spec;
			}
			# --set: the column of the inventory, or a column that every row leaves empty
			foreach my $k (sort keys %$set) {
				my ($spec,$e) = _column($k, $profile);
				next if ($e);
				$used{$k}=1;
				my ($i) = grep { $header->[$_]{id} eq $spec->{id} } (0..$#$header);
				if (! defined $i) { push @$header, $spec; $i=$#$header; }
				$setval[$i] = $set->{$k};
			}
			return ([],\@err,\%used) if (@err);
			next;
		}
		if (scalar(@c) > scalar(@$header)) { push @err, "inventario linea $nl: tiene mas columnas que la cabecera"; next; }
		my (%v,%explicit,%custom,%labels,%attrs);
		for my $i (0..$#$header) {
			my $val = defined $c[$i] ? $c[$i] : '';
			$val = $setval[$i] if (($val eq '') && defined $setval[$i]);
			my $h = $header->[$i];
			if    (defined $h->{custom}) { $custom{$h->{custom}}=$val if ($val ne ''); }
			elsif (defined $h->{label})  { $labels{$h->{label}}=$val if ($val ne ''); }
			elsif (defined $h->{attr})   { $attrs{$h->{attr}}=$val if ($val ne ''); }
			else { $v{$h->{param}}=$val; $explicit{$h->{param}}=1 if ($val ne ''); }
		}
		my $ok=1;
		foreach my $n (sort keys %{$profile->{parameters}}) {
			my $d=$profile->{parameters}{$n};
			if ((! defined $v{$n}) || ($v{$n} eq '')) {
				if (defined $d->{default}) { $v{$n}=$d->{default}; }
				elsif ($d->{required}) { push @err, "inventario linea $nl: falta '$n'"; $ok=0; }
				else { $v{$n}=''; }
			}
		}
		# A default may use other parameters ("{name}.example.local"): one pass, no nesting
		foreach my $n (keys %v) {
			next if ($v{$n} !~ /\{/);
			my $s=$v{$n};
			$s =~ s/\{([^{}]*)\}/(exists $v{$1} && $v{$1} !~ m{[{}]}) ? $v{$1} : "{$1}"/ge;
			if ($s =~ /\{[^{}]*\}/) { push @err, "inventario linea $nl: '$n' usa un parametro sin valor o anidado ($s)"; $ok=0; }
			$v{$n}=$s;
		}
		push @rows, { line=>$nl, values=>\%v, explicit=>\%explicit, custom=>\%custom, labels=>\%labels, attrs=>\%attrs } if ($ok);
	}
	push @err, 'inventario: no tiene cabecera' if (! $header);
	return (\@rows,\@err,\%used);
}

#----------------------------------------------------------------------------
# _column($name, $profile) -> ($spec, $error)
# What an inventory column (or a --set key) is: {param}, {custom}, {label} or {attr}, with
# an {id} to find repeated columns.
#----------------------------------------------------------------------------
sub _column {
my ($col,$profile)=@_;
	if ($col =~ /^custom\.(.+)$/i)  { return ({ custom=>$1, id=>'custom.'.uc $1 }, undef); }
	if ($col =~ /^c_label\.(.+)$/i) { return ({ label=>$1,  id=>'c_label.'.lc $1 }, undef); }
	my @dev = _devices($profile);
	if ($col =~ /^device\.(.+)$/i) {
		my $a = lc $1;
		return (undef, "columna '$col': '$a' no es un atributo del dispositivo (".join(', ',@DEVICE_ATTRS).")") if (! $DEVICE_ATTRS{$a});
		return (undef, "columna '$col': el perfil crea ".scalar(@dev)." dispositivos por fila (tiene que ser 1)") if (@dev != 1);
		return (_param_is_attr($profile,$dev[0],$a) ? { param=>$a, id=>$a } : { attr=>$a, id=>"device.$a" }, undef);
	}
	my $n = lc $col;
	if (exists $profile->{parameters}{$n}) { return ({ param=>$n, id=>$n }, undef); }
	if ($DEVICE_ATTRS{$n}) {
		return (undef, "columna '$n': es un atributo del dispositivo, pero el perfil crea ".scalar(@dev)." dispositivos por fila (tiene que ser 1)") if (@dev != 1);
		return ({ attr=>$n, id=>"device.$n" }, undef);
	}
	return (undef, "columna '$n' no es un parametro del perfil, ni un atributo del dispositivo (".join(', ',@DEVICE_ATTRS)."), ni custom.<campo>, ni c_label.<subtipo>");
}

sub _devices { my $p=shift; return grep { ref($_) eq 'HASH' && defined $_->{kind} && $_->{kind} eq 'device' } @{$p->{resources}}; }

# The parameter <a> of the profile is the attribute <a> of its device ("domain": "{domain}")
sub _param_is_attr {
my ($profile,$dev,$a)=@_;
	return 0 if (! exists $profile->{parameters}{$a});
	my $v = ($a eq 'version' || $a eq 'community') ? (ref($dev->{snmp}) eq 'HASH' ? $dev->{snmp}{$a} : undef) : $dev->{$a};
	return (defined $v && ! ref($v) && $v eq "{$a}") ? 1 : 0;
}

#----------------------------------------------------------------------------
# expand($profile, \@rows, $label) -> (\@resources, \@errors)
# Replaces {param} in every string. A key whose value is exactly "{param}" with an empty
# parameter is dropped (optional parameter). A list loses the elements that end up empty
# (e.g. "views": ["{view}"] with view=''), and a list element with '|' becomes several
# ("views": ["{views}"] with views="A|B"). Every resource carries "_origin" =
# "<label> linea N" for the messages ($label: the inventory file; default 'inventario').
# The attribute columns go to the one device resource (version and community to "snmp"),
# and a domain that comes from the default of the profile is marked "_domain_default".
# The custom.<field> values of a row go to "fields" of the one device
# resource of the profile; a row with custom values and a profile with no device resource,
# or with more than one, is an error. The c_label.<subtype> values go to "c_label" of the
# metric of that subtype in the row; none or more than one such metric is an error.
#----------------------------------------------------------------------------
sub expand {
my ($profile,$rows,$label)=@_;
my (@res,@err);
	$label = 'inventario' if (! defined $label);
	my $n_dev = scalar(_devices($profile));
	foreach my $f (@$rows) {
		my %custom = %{$f->{custom} || {}};
		if (%custom && ($n_dev != 1)) {
			push @err, "inventario linea $f->{line}: tiene columnas custom.* y el perfil crea $n_dev dispositivos por fila (tiene que ser 1)";
			next;
		}
		my @row=();
		foreach my $tpl (@{$profile->{resources}}) {
			my $r = _substitute($tpl, $f->{values});
			$r->{_origin} = "$label linea $f->{line}";
			if ((ref($r) eq 'HASH') && defined $r->{kind} && ($r->{kind} eq 'device')) {
				# Attribute columns: the inventory wins
				my %a = %{$f->{attrs} || {}};
				foreach my $k (grep { $_ ne 'version' && $_ ne 'community' } keys %a) { $r->{$k}=$a{$k}; }
				if (defined $a{version} || defined $a{community}) {
					my %sn = (ref($r->{snmp}) eq 'HASH') ? %{$r->{snmp}} : ();
					$sn{$_}=$a{$_} foreach (grep { defined $a{$_} } qw(version community));
					$r->{snmp}=\%sn;
				}
				# A domain from the default of the profile (no cell, no --set, no attribute)
				if ((! defined $a{domain}) && (ref($tpl) eq 'HASH') && defined $tpl->{domain} && ($tpl->{domain} =~ /^\{([^{}]*)\}$/)
					 && (! $f->{explicit}{$1})) {
					$r->{_domain_default}=1;
				}
			}
			if (%custom && (ref($r) eq 'HASH') && defined $r->{kind} && ($r->{kind} eq 'device')) {
				my %fields = (ref($r->{fields}) eq 'HASH') ? %{$r->{fields}} : ();
				foreach my $k (keys %custom) {
					delete $fields{$_} foreach (grep { uc($_) eq uc($k) } keys %fields);	# the inventory wins
					$fields{$k}=$custom{$k};
				}
				$r->{fields}=\%fields;
			}
			push @row, $r;
		}
		foreach my $s (sort keys %{$f->{labels} || {}}) {
			my @m = grep { (ref($_) eq 'HASH') && defined $_->{kind} && ($_->{kind} eq 'metric')
								&& defined $_->{subtype} && (lc($_->{subtype}) eq lc($s)) } @row;
			if (@m != 1) {
				push @err, "inventario linea $f->{line}: columna c_label.$s, pero el perfil crea ".scalar(@m)." metricas $s en esta fila (tiene que ser 1)";
				next;
			}
			$m[0]{c_label} = $f->{labels}{$s};		# the inventory wins
		}
		push @res, @row;
	}
	return (\@res,\@err);
}

sub _substitute {
my ($x,$v)=@_;
	if (ref($x) eq 'HASH') {
		my %h=();
		foreach my $k (keys %$x) {
			next if ((defined $x->{$k}) && (! ref $x->{$k}) && ($x->{$k} =~ /^\{([^{}]*)\}$/) && ((! defined $v->{$1}) || ($v->{$1} eq '')));
			$h{$k}=_substitute($x->{$k},$v);
		}
		return \%h;
	}
	# In a list, a text with '|' is several elements ("users": ["{users}"] with
	# users="noc|operador1"); the empty ones are dropped
	if (ref($x) eq 'ARRAY') {
		return [ grep { !(defined $_ && !ref($_) && $_ eq '') }
					map { (defined $_ && !ref($_)) ? (map { my $e=$_; $e =~ s/^\s+|\s+$//g; $e } split(/\|/,$_,-1)) : $_ }
					map { _substitute($_,$v) } @$x ];
	}
	return $x if ((! defined $x) || ref($x));		# JSON numbers and booleans, null
	my $s=$x;
	$s =~ s/\{([^{}]*)\}/defined $v->{$1} ? $v->{$1} : ''/ge;
	return $s;
}

sub _walk {
my ($x,$f)=@_;
	if (ref($x) eq 'HASH')     { _walk($_,$f) foreach (values %$x); }
	elsif (ref($x) eq 'ARRAY') { _walk($_,$f) foreach (@$x); }
	elsif ((defined $x) && (! ref($x))) { $f->($x); }
}

1;
