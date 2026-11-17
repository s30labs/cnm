#####################################################################################################
# Fichero: (ProvisionLite::MetricsFile.pm)
# Descripcion:
#	Formato de los ficheros del campo de dispositivo CNM-METRICS (version 2): lectura,
#	validacion, decision sobre cada metrica de la plantilla, edicion y migracion desde
#	el formato antiguo (version 1, solo "enable").
#
#	{
#	  "version": 2,
#	  "descr":   "texto libre (opcional)",
#	  "default": "keep" | "disable",
#	  "order":   ["enable","disable"] | ["disable","enable"],
#	  "enable":  [ {"type":"latency","subtype":"disp_icmp","label_like":"ICMP","watch":"..."} ],
#	  "disable": [ {"type":"snmp","subtype":"disk_mibhost","label_like":"^USO DE DISCO /run/user/"} ]
#	}
#
#	Cada metrica de la plantilla (type, subtype, label) se compara con las listas en el
#	orden de "order". La primera entrada que case decide: enable => activa (status 0),
#	disable => inactiva (status 1). Si no casa ninguna, decide "default":
#	keep => se queda como esta; disable => inactiva.
#	En una entrada: type obligatorio; subtype opcional (sin el, cualquier subtipo del type);
#	label_like obligatorio, expresion regular sobre la etiqueta completa; watch, solo en
#	enable y opcional: si viene y no esta vacio, es el monitor que se asocia.
#
#	Funciones puras: no leen ni escriben la base ni ficheros. Las usan
#	Crawler::Store::set_template_metrics_by_custom_file y support/cnm-metrics-file.
#	Diseno: cnm-docs, REG-CNM-Deuda 4.102 y 4.105.
# Set Tab=3
#####################################################################################################
package ProvisionLite::MetricsFile;
$VERSION='1.00';
use strict;
use JSON;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(parse_text check_data decide plan_changes v1_to_v2 encode_data
						  add_entry remove_entry valid_file_name);

my @LISTS = ('enable','disable');
my %TOP_KEYS = map { $_=>1 } qw(version descr default order enable disable);
my %ENTRY_KEYS = ( 'enable'  => { map { $_=>1 } qw(type subtype label_like watch descr) },
						 'disable' => { map { $_=>1 } qw(type subtype label_like descr) } );

#----------------------------------------------------------------------------
# valid_file_name($name)
# Solo un nombre de fichero dentro del directorio de automatizacion: sin rutas.
#----------------------------------------------------------------------------
sub valid_file_name {
my ($name)=@_;
	return ((defined $name) && ($name =~ /^[\w][\w.\-]*\.json$/)) ? 1 : 0;
}

#----------------------------------------------------------------------------
# parse_text($text)
# Devuelve ($cfg, undef) si el fichero es valido, o (undef, $error) si no lo es.
# $cfg es check_data() del contenido: los datos tal cual mas las expresiones compiladas.
#----------------------------------------------------------------------------
sub parse_text {
my ($text)=@_;

	if ((! defined $text) || ($text !~ /\S/)) { return (undef, 'fichero vacio'); }

	my $data;
	eval { $data = JSON->new->decode($text); };
	if ($@) {
		my $e = $@; $e =~ s/\s+at \S+ line \d+\.?\s*$//;
		return (undef, "JSON no valido: $e");
	}
	return check_data($data);
}

#----------------------------------------------------------------------------
# check_data($data)
# Valida una estructura ya decodificada. Devuelve ($cfg, undef) o (undef, $error).
#----------------------------------------------------------------------------
sub check_data {
my ($data)=@_;

	if (ref($data) ne 'HASH') { return (undef, 'el fichero no es un objeto JSON'); }

	if (! exists $data->{'version'}) {
		return (undef, 'sin "version": formato antiguo, hay que migrarlo (cnm-metrics-file migrate)');
	}
	if ($data->{'version'} ne '2') { return (undef, "version no soportada: $data->{'version'}"); }

	foreach my $k (sort keys %$data) {
		if (! $TOP_KEYS{$k}) { return (undef, "clave desconocida: \"$k\""); }
	}

	my $default = $data->{'default'};
	if ((! defined $default) || ($default !~ /^(keep|disable)$/)) {
		return (undef, '"default" tiene que ser "keep" o "disable"');
	}

	my $order = $data->{'order'};
	if ((ref($order) ne 'ARRAY') || (scalar(@$order) != 2)
		|| (join(',', sort map { defined $_ ? $_ : '' } @$order) ne 'disable,enable')) {
		return (undef, '"order" tiene que ser ["enable","disable"] o ["disable","enable"]');
	}

	my %cfg = ('default'=>$default, 'order'=>[ @$order ], 'data'=>$data);
	foreach my $list (@LISTS) {
		my $entries = exists $data->{$list} ? $data->{$list} : [];
		if (ref($entries) ne 'ARRAY') { return (undef, "\"$list\" tiene que ser una lista"); }

		my @checked=();
		my $n=0;
		foreach my $e (@$entries) {
			$n++;
			my $where = "$list #$n";
			if (ref($e) ne 'HASH') { return (undef, "$where: no es un objeto"); }
			foreach my $k (sort keys %$e) {
				if (! $ENTRY_KEYS{$list}{$k}) { return (undef, "$where: clave no admitida: \"$k\""); }
			}
			foreach my $k (sort keys %$e) {
				if (ref($e->{$k})) { return (undef, "$where: \"$k\" tiene que ser un texto"); }
			}
			if ((! defined $e->{'type'}) || ($e->{'type'} eq '')) { return (undef, "$where: falta \"type\""); }
			if ((! defined $e->{'label_like'}) || ($e->{'label_like'} eq '')) {
				return (undef, "$where: falta \"label_like\"");
			}
			if ((exists $e->{'subtype'}) && ((! defined $e->{'subtype'}) || ($e->{'subtype'} eq ''))) {
				return (undef, "$where: \"subtype\" vacio (para cualquier subtipo, se quita la clave)");
			}
			my $re;
			eval { my $p = $e->{'label_like'}; $re = qr/$p/; };
			if ($@) {
				my $err = $@; $err =~ s/\s+at \S+ line \d+\.?\s*$//;
				return (undef, "$where: expresion regular no valida en \"label_like\": $err");
			}
			push @checked, { %$e, 're'=>$re, 'ref'=>$where };
		}
		$cfg{$list} = \@checked;
	}

	return (\%cfg, undef);
}

#----------------------------------------------------------------------------
# decide($cfg, $row)
# $row: { type=>, subtype=>, label=>, status=>, watch=> }  (una fila de la plantilla)
# Devuelve { status=>, watch=>, by=> }. by es la entrada que ha decidido
# ("enable #2", "disable #1") o "default".
#----------------------------------------------------------------------------
sub decide {
my ($cfg,$row)=@_;

	my $label = defined $row->{'label'} ? $row->{'label'} : '';
	foreach my $list (@{$cfg->{'order'}}) {
		foreach my $e (@{$cfg->{$list}}) {
			next if ($e->{'type'} ne $row->{'type'});
			next if ((defined $e->{'subtype'}) && ($e->{'subtype'} ne $row->{'subtype'}));
			next if ($label !~ $e->{'re'});

			if ($list eq 'disable') { return { 'status'=>1, 'watch'=>$row->{'watch'}, 'by'=>$e->{'ref'} }; }
			my $watch = ((defined $e->{'watch'}) && ($e->{'watch'} ne '')) ? $e->{'watch'} : $row->{'watch'};
			return { 'status'=>0, 'watch'=>$watch, 'by'=>$e->{'ref'} };
		}
	}

	my $status = ($cfg->{'default'} eq 'disable') ? 1 : $row->{'status'};
	return { 'status'=>$status, 'watch'=>$row->{'watch'}, 'by'=>'default' };
}

#----------------------------------------------------------------------------
# plan_changes($cfg, \@rows)
# Devuelve las filas que cambian: [ { row=>, status=>, watch=>, by=> } ].
# Una fila que se queda igual no aparece.
#----------------------------------------------------------------------------
sub plan_changes {
my ($cfg,$rows)=@_;

	my @changes=();
	foreach my $row (@$rows) {
		my $d = decide($cfg,$row);
		my $old_watch = defined $row->{'watch'} ? $row->{'watch'} : '';
		my $new_watch = defined $d->{'watch'} ? $d->{'watch'} : '';
		next if (($d->{'status'} == $row->{'status'}) && ($new_watch eq $old_watch));
		push @changes, { 'row'=>$row, %$d };
	}
	return \@changes;
}

#----------------------------------------------------------------------------
# v1_to_v2($data)
# Formato antiguo: { "enable": [...] }. Todo lo que no casa con enable queda inactivo,
# asi que equivale a default=disable. Un watch vacio no hacia nada y se quita.
# Devuelve ($data2, undef) o (undef, $error).
#----------------------------------------------------------------------------
sub v1_to_v2 {
my ($data)=@_;

	if (ref($data) ne 'HASH') { return (undef, 'el fichero no es un objeto JSON'); }
	if (exists $data->{'version'}) { return (undef, "ya tiene version ($data->{'version'})"); }
	foreach my $k (sort keys %$data) {
		if (($k ne 'enable') && ($k ne 'disable')) { return (undef, "clave desconocida en el formato antiguo: \"$k\""); }
	}
	if ((exists $data->{'disable'}) && (ref($data->{'disable'}) eq 'ARRAY') && (scalar @{$data->{'disable'}})) {
		return (undef, '"disable" no estaba implementado en el formato antiguo y tiene entradas: revisalo a mano');
	}

	my @enable=();
	foreach my $e (@{ $data->{'enable'} || [] }) {
		if (ref($e) ne 'HASH') { return (undef, 'una entrada de "enable" no es un objeto'); }
		my %n = %$e;
		if ((exists $n{'watch'}) && ((! defined $n{'watch'}) || ($n{'watch'} eq ''))) { delete $n{'watch'}; }
		# En el formato antiguo una entrada sin subtipo no casaba nunca; en el nuevo casaria
		# con todos. No se adivina: se revisa a mano.
		if ((! defined $n{'subtype'}) || ($n{'subtype'} eq '')) {
			return (undef, 'una entrada de "enable" no tiene "subtype": revisalo a mano');
		}
		push @enable, \%n;
	}

	my %d2 = ('version'=>2, 'default'=>'disable', 'order'=>['enable','disable'], 'enable'=>\@enable, 'disable'=>[]);
	my ($cfg,$err) = check_data(\%d2);
	if ($err) { return (undef, "el resultado no es valido: $err"); }
	return (\%d2, undef);
}

#----------------------------------------------------------------------------
# encode_data($data)
# Texto del fichero: JSON legible, claves ordenadas y en el orden logico arriba.
#----------------------------------------------------------------------------
sub encode_data {
my ($data)=@_;

	my $json = JSON->new->canonical(1)->pretty;
	my @parts=();
	foreach my $k (qw(version descr default order)) {
		next if (! exists $data->{$k});
		my $val = $data->{$k};
		# version se escribe siempre como numero (2, no "2"): segun como se haya usado antes
		# en Perl, el valor puede llegar marcado como texto y JSON lo escribiria entre comillas.
		if (($k eq 'version') && (defined $val) && ($val =~ /^\d+$/)) { $val = int($val); }
		my $v = JSON->new->canonical(1)->allow_nonref->encode($val);
		push @parts, "  \"$k\": $v";
	}
	foreach my $list (@LISTS) {
		my $entries = $data->{$list} || [];
		my @lines = map { '    '.JSON->new->canonical(1)->encode($_) } @$entries;
		push @parts, "  \"$list\": [".(scalar @lines ? "\n".join(",\n",@lines)."\n  " : '').']';
	}
	return "{\n".join(",\n",@parts)."\n}\n";
}

#----------------------------------------------------------------------------
# add_entry($data, $list, $entry)   remove_entry($data, $list, $entry)
# Editan una copia de $data. Una entrada es la misma si coinciden type, subtype,
# label_like (y watch al anadir en enable se sustituye). Devuelven ($data2, $msg).
#----------------------------------------------------------------------------
sub _same {
my ($a,$b)=@_;
	foreach my $k (qw(type subtype label_like)) {
		my ($x,$y) = (defined $a->{$k} ? $a->{$k} : "\0", defined $b->{$k} ? $b->{$k} : "\0");
		return 0 if ($x ne $y);
	}
	return 1;
}

sub _copy { return JSON->new->decode(JSON->new->encode($_[0])); }

sub add_entry {
my ($data,$list,$entry)=@_;

	my $d2 = _copy($data);
	$d2->{$list} ||= [];
	foreach my $i (0 .. $#{$d2->{$list}}) {
		next if (! _same($d2->{$list}->[$i], $entry));
		$d2->{$list}->[$i] = { %$entry };
		return ($d2, "ya estaba en $list: se sustituye");
	}
	push @{$d2->{$list}}, { %$entry };
	return ($d2, "se anade a $list");
}

sub remove_entry {
my ($data,$list,$entry)=@_;

	my $d2 = _copy($data);
	my @keep = grep { ! _same($_, $entry) } @{ $d2->{$list} || [] };
	my $n = scalar(@{ $d2->{$list} || [] }) - scalar(@keep);
	$d2->{$list} = \@keep;
	return ($d2, $n ? "se quita de $list" : "no estaba en $list: no cambia nada");
}

1;
