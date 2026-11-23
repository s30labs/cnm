#####################################################################################################
# Fichero: (Testbed::Battery.pm)
# Descripcion:
#	La bateria de la salvaguarda de la provision (PROV_GUARD, REG-CNM-Deuda 4.104): los
#	casos, lo que se espera de cada uno con PROV_GUARD a 0, 1 o 2, y la comparacion con lo
#	que ha pasado. Funciones puras: no leen ni escriben ficheros ni la base; cnm-testbed
#	battery prepara cada caso, provisiona, hace la foto y llama a evaluate().
#
#	PROV_GUARD (ProvisionLite/ProvGuard.pm):
#	  0  lo de siempre (tambien sin la linea en /cfg/onm.conf)
#	  1  la salvaguarda actua: G1 (lectura sin datos) no toca la metrica; G2 (faltan
#	     instancias) relee y solo quita las que faltan en las dos lecturas
#	  2  observacion: deja los mismos avisos en qactions, pero hace lo de siempre
#	Por eso con 0 y con 2 se espera lo mismo en la plantilla ('today'), y con 1 lo de
#	'guard'. Los avisos solo se esperan con 1 y 2 (con 2, empezando por "Observacion").
#
#	Lo que se mira despues de provisionar, contra la foto "base":
#	  - las filas de la plantilla del subtipo de prueba (cnm_testbed_rows|N) que deben estar,
#	    con su watch y su status de la foto (las nuevas, status 1 y sin monitor), y la
#	    metrica de cada fila activa;
#	  - en el caso de snmpd, la fila ucd_cpu_usage|ALL;
#	  - que el resto de la plantilla del equipo no ha cambiado;
#	  - los avisos de la salvaguarda en qactions;
#	  - en el caso de reorder, a donde va el c_label de fila-1 (depende de PROV_REMAP_BY_LABEL).
# Set Tab=3
#####################################################################################################
package Testbed::Battery;
$VERSION='1.00';
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(SUBTYPE UCD_SUBTYPE NOTICE_SKIP NOTICE_REREAD cases select_cases parse_modes
						 expected set_guard_line evaluate split_blues);

use constant SUBTYPE       => 'cnm_testbed_rows';
use constant UCD_SUBTYPE   => 'ucd_cpu_usage';
use constant UCD_KEY       => 'ucd_cpu_usage|ALL';
use constant NOTICE_SKIP   => 'Provision: metrica sin cambios';
use constant NOTICE_REREAD => 'Provision: instancias recuperadas en la segunda lectura';
use constant MAX_ROW       => 6;

# rows: filas de la tabla de prueba que deben quedar en la plantilla
# notice: aviso esperado con PROV_GUARD 1 y 2 (undef: ninguno)
my @CASES = (
	{ id=>1,  name=>'complete',      what=>'tabla completa',
	  scenario=>{ mode=>'complete' },
	  today=>{ rows=>[1..5] }, guard=>{ rows=>[1..5] }, notice=>undef },
	{ id=>2,  name=>'empty',         what=>'tabla vacia (G1)',
	  scenario=>{ mode=>'empty' },
	  today=>{ rows=>[] },     guard=>{ rows=>[1..5] }, notice=>NOTICE_SKIP },
	{ id=>3,  name=>'empty-forced',  what=>'tabla vacia con plite -F',
	  scenario=>{ mode=>'empty' }, force=>1,
	  today=>{ rows=>[] },     guard=>{ rows=>[] },     notice=>undef },
	{ id=>4,  name=>'cut-once',      what=>'la primera lectura se corta en 2 (G2)',
	  scenario=>{ mode=>'cut-once', cut_at=>2 },
	  today=>{ rows=>[1,2] },  guard=>{ rows=>[1..5] }, notice=>NOTICE_REREAD },
	{ id=>5,  name=>'drop',          what=>'faltan las filas 2 y 4 en todas las lecturas',
	  scenario=>{ mode=>'drop', drop=>[2,4] },
	  today=>{ rows=>[1,3,5] },guard=>{ rows=>[1,3,5] },notice=>undef },
	{ id=>6,  name=>'cut-always',    what=>'todas las lecturas se cortan en 2 (limite aceptado)',
	  scenario=>{ mode=>'cut-always', cut_at=>2 },
	  today=>{ rows=>[1,2] },  guard=>{ rows=>[1,2] },  notice=>undef },
	{ id=>7,  name=>'reorder',       what=>'las mismas etiquetas en otros indices',
	  scenario=>{ mode=>'reorder' }, remap_check=>1,
	  today=>{ rows=>[1..5] }, guard=>{ rows=>[1..5] }, notice=>undef },
	{ id=>8,  name=>'cut-once-drop', what=>'la primera lectura se corta en 2 y la fila 5 falta siempre',
	  scenario=>{ mode=>'cut-once', cut_at=>2, drop=>[5] },
	  today=>{ rows=>[1,2] },  guard=>{ rows=>[1..4] }, notice=>NOTICE_REREAD },
	{ id=>9,  name=>'new-row',       what=>'aparece la fila 6',
	  scenario=>{ mode=>'complete', rows=>6 }, new=>[6],
	  today=>{ rows=>[1..6] }, guard=>{ rows=>[1..6] }, notice=>undef },
	{ id=>10, name=>'snmpd-restart', what=>'reiniciar snmpd y provisionar sin esperar (ssCpuIdle, G1)',
	  scenario=>{ mode=>'complete' }, restart=>1, subtype=>UCD_SUBTYPE,
	  today=>{ ucd=>0 },       guard=>{ ucd=>1 },       notice=>NOTICE_SKIP },
	# Exploratorio (no entra por defecto, solo con --case 11): lo esperado es lo ideal, que
	# nada cambie; si falla, los fallos dicen que hace hoy la provision. G2 no lo cubre:
	# las instancias salen de la columna de valores, que llega entera.
	{ id=>11, name=>'label-cut',     what=>'en la primera lectura solo se cortan las etiquetas (exploratorio)',
	  scenario=>{ mode=>'cut-labels', cut_at=>2 }, explore=>1, labels_intact=>1,
	  today=>{ rows=>[1..5] }, guard=>{ rows=>[1..5] }, notice=>undef },
);

#----------------------------------------------------------------------------
# cases() -> lista de casos (copias), con el escenario completo (rows 5, cut_at 2,
# drop vacio y delay 0 si no se dice otra cosa) y el subtipo que mira cada uno
#----------------------------------------------------------------------------
sub cases {
	my @r=();
	foreach my $c (@CASES) {
		my %c = %$c;
		$c{'scenario'} = { mode=>'complete', rows=>5, cut_at=>2, drop=>[], delay=>0, %{$c->{'scenario'}} };
		$c{'subtype'} ||= SUBTYPE;
		push @r, \%c;
	}
	return @r;
}

#----------------------------------------------------------------------------
# select_cases($spec) -> (\@casos, $error). $spec: undef o '' (todos salvo los exploratorios), o lista separada
# por comas de numeros o nombres ("4,reorder"). Mantiene el orden de la bateria.
#----------------------------------------------------------------------------
sub select_cases {
my $spec=shift;
	my @all = cases();
	return ([ grep { ! $_->{'explore'} } @all ],'') if ((! defined $spec) || ($spec eq ''));
	my %want=();
	foreach my $w (split(/\s*,\s*/,$spec)) {
		my ($c) = grep { ($_->{'id'} eq $w) || ($_->{'name'} eq $w) } @all;
		return (undef,"caso desconocido: $w") if (! $c);
		$want{$c->{'id'}}=1;
	}
	return ([ grep { $want{$_->{'id'}} } @all ],'');
}

#----------------------------------------------------------------------------
# parse_modes($spec) -> (\@modos, $error). Por defecto 0,2,1. Sin repetir, en el orden dado.
#----------------------------------------------------------------------------
sub parse_modes {
my $spec=shift;
	$spec = '0,2,1' if ((! defined $spec) || ($spec eq ''));
	my @m=(); my %seen=();
	foreach my $v (split(/\s*,\s*/,$spec)) {
		return (undef,"PROV_GUARD no valido: $v (0, 1 o 2)") if ($v !~ /^[012]$/);
		push @m, $v if (! $seen{$v}++);
	}
	return (\@m,'');
}

#----------------------------------------------------------------------------
# expected($case,$mode) -> lo que se espera en la plantilla con ese PROV_GUARD
#----------------------------------------------------------------------------
sub expected {
my ($case,$mode)=@_;
	return ($mode eq '1') ? $case->{'guard'} : $case->{'today'};
}

#----------------------------------------------------------------------------
# set_guard_line($text,$mode) -> el texto de onm.conf con una sola linea activa
# "PROV_GUARD = $mode", al final. Quita las lineas activas que hubiera; las comentadas
# (#PROV_GUARD...) se quedan. Para volver atras se escribe el texto original.
#----------------------------------------------------------------------------
sub set_guard_line {
my ($text,$mode)=@_;
	$text = '' if (! defined $text);
	my @l = grep { ! /^\s*PROV_GUARD\b/ } split(/\n/,$text,-1);
	pop @l if ((@l) && ($l[-1] eq ''));
	return join("\n",@l,"PROV_GUARD = $mode")."\n";
}

#----------------------------------------------------------------------------
# split_blues(\@mnames) -> (\@de_prueba, \@otras): metricas en azul de la tabla de prueba
# (cnm_testbed_rows-N) y el resto. Las de prueba pueden ser pasajeras: si el crawler lee la
# tabla durante un caso con corte, las filas cortadas le dan U hasta su siguiente ciclo.
#----------------------------------------------------------------------------
sub split_blues {
my $m=shift;
	my $re = qr/^\Q${\ SUBTYPE}\E-\d+$/;
	return ([ grep { $_ =~ $re } @{$m || []} ], [ grep { $_ !~ $re } @{$m || []} ]);
}

sub _row  { my ($snap,$iid)=@_; return $snap->{'template'}{SUBTYPE."|$iid"}; }
sub _clab { my ($snap,$m)=@_; my $r=$snap->{'metrics'}{$m}; return ((defined $r) && (defined $r->{'c_label'})) ? $r->{'c_label'} : ''; }
sub _v    { my $v=shift; return (defined $v) ? $v : ''; }

#----------------------------------------------------------------------------
# evaluate({case,mode,remap,base,after,notices}) -> lista de fallos (vacia: OK)
# notices: [ {descr,rcstr}, ... ] avisos de la salvaguarda de esta provision para el
# subtipo del caso.
#----------------------------------------------------------------------------
sub evaluate {
my $a=shift;
	my ($c,$mode,$base,$after) = @{$a}{qw(case mode base after)};
	my @f=();
	my $exp = expected($c,$mode);
	my %new = map { $_ => 1 } @{$c->{'new'} || []};

	# 1. Filas de la tabla de prueba
	if (defined $exp->{'rows'}) {
		my %want = map { $_ => 1 } @{$exp->{'rows'}};
		foreach my $i (1..MAX_ROW) {
			my $r = _row($after,$i);
			if ($want{$i} && (! $r))  { push @f, "fila $i: tenia que quedar en la plantilla y no esta"; next; }
			if ((! $want{$i}) && $r)  { push @f, "fila $i: no tenia que quedar en la plantilla y esta"; next; }
			next if (! $r);
			my $b = _row($base,$i);
			if ($new{$i}) {
				push @f, "fila $i (nueva): status "._v($r->{'status'})." en vez de 1" if (_v($r->{'status'}) ne '1');
				push @f, "fila $i (nueva): monitor "._v($r->{'watch'})." en vez de ninguno" if (_v($r->{'watch'}) ne '0');
			}
			elsif (! $b) { push @f, "fila $i: no esta en la foto base"; }
			else {
				foreach my $k ('status','watch') {
					push @f, "fila $i: $k "._v($r->{$k})." en vez de "._v($b->{$k}) if (_v($r->{$k}) ne _v($b->{$k}));
				}
				# Una fila activa tiene su metrica (la provision borra las de las filas en azul)
				push @f, "fila $i: activa en la plantilla y sin su metrica ".SUBTYPE."-$i"
					if ((_v($r->{'status'}) eq '0') && (! $after->{'metrics'}{SUBTYPE."-$i"}));
			}
		}
	}

	# 2. ucd_cpu_usage
	if (defined $exp->{'ucd'}) {
		if (! $base->{'template'}{UCD_KEY()}) { push @f, "la foto base no tiene ".UCD_KEY.": el caso no se puede evaluar"; }
		else {
			my $has = $after->{'template'}{UCD_KEY()} ? 1 : 0;
			push @f, UCD_KEY.": ".($has ? "esta" : "no esta")." y se esperaba que ".($exp->{'ucd'} ? "estuviera" : "no estuviera")
				if ($has != $exp->{'ucd'});
		}
	}

	# 3. El resto de la plantilla no cambia
	my %mine = ( SUBTYPE() => 1 );
	$mine{UCD_SUBTYPE()}=1 if (defined $exp->{'ucd'});
	my %keys = map { $_ => 1 } (keys %{$base->{'template'}}, keys %{$after->{'template'}});
	my @other=();
	foreach my $k (sort keys %keys) {
		my ($st) = split(/\|/,$k,2);
		next if ($mine{$st});
		my ($b,$r) = ($base->{'template'}{$k}, $after->{'template'}{$k});
		if (! $r)    { push @other, "$k ha desaparecido"; next; }
		if (! $b)    { push @other, "$k es nueva"; next; }
		foreach my $f ('status','watch') {
			push @other, "$k: $f "._v($b->{$f})." -> "._v($r->{$f}) if (_v($b->{$f}) ne _v($r->{$f}));
		}
	}
	push @f, "otras filas de la plantilla han cambiado: ".join('; ',@other) if (@other);

	# 4. Avisos de la salvaguarda
	my @n = @{$a->{'notices'} || []};
	if ($mode eq '0') {
		push @f, "con PROV_GUARD 0 no tenia que haber avisos y hay ".scalar(@n).": ".join(' | ', map { $_->{'descr'} } @n) if (@n);
	}
	else {
		my $want = $c->{'notice'};
		my @ok  = grep { (defined $want) && ($_->{'descr'} eq $want) } @n;
		my @bad = grep { (! defined $want) || ($_->{'descr'} ne $want) } @n;
		push @f, "falta el aviso \"$want\"" if ((defined $want) && (! @ok));
		push @f, "aviso que no se esperaba: ".join(' | ', map { $_->{'descr'} } @bad) if (@bad);
		foreach my $x (@ok) {
			my $obs = (_v($x->{'rcstr'}) =~ /^Observacion/) ? 1 : 0;
			push @f, "con PROV_GUARD 2 el aviso tiene que empezar por \"Observacion\"" if (($mode eq '2') && (! $obs));
			push @f, "con PROV_GUARD 1 el aviso no puede empezar por \"Observacion\"" if (($mode eq '1') && $obs);
		}
	}

	# 5. label-cut: etiquetas y c_label de las filas como en la foto
	if ($c->{'labels_intact'}) {
		foreach my $i (1..5) {
			my ($b,$r) = (_row($base,$i), _row($after,$i));
			next if ((! $b) || (! $r));
			push @f, "fila $i: etiqueta '"._v($r->{'label'})."' en vez de '"._v($b->{'label'})."'" if (_v($r->{'label'}) ne _v($b->{'label'}));
			my ($cb,$ca) = (_clab($base,SUBTYPE."-$i"), _clab($after,SUBTYPE."-$i"));
			push @f, "fila $i: c_label '$ca' en vez de '$cb'" if ($ca ne $cb);
		}
	}

	# 6. reorder: el c_label de fila-1 (iid 1 en la foto base; con reorder su etiqueta pasa al iid 5)
	if ($c->{'remap_check'}) {
		my $x = _clab($base, SUBTYPE.'-1');
		if ($x eq '') { push @f, "la foto base no tiene c_label en ".SUBTYPE."-1: el caso no se puede evaluar"; }
		elsif ($a->{'remap'}) {
			my $l5 = _row($after,5);
			push @f, "con PROV_REMAP_BY_LABEL 1 la fila 5 tenia que tener la etiqueta fila-1" if ((! $l5) || (_v($l5->{'label'}) !~ /\bfila-1\b/));
			push @f, "con PROV_REMAP_BY_LABEL 1 el c_label de fila-1 tenia que pasar a ".SUBTYPE."-5" if (_clab($after,SUBTYPE.'-5') ne $x);
			push @f, "con PROV_REMAP_BY_LABEL 1 ".SUBTYPE."-1 no puede quedarse con el c_label de fila-1" if (_clab($after,SUBTYPE.'-1') eq $x);
		}
		else {
			push @f, "con PROV_REMAP_BY_LABEL 0 el c_label tenia que quedarse en ".SUBTYPE."-1" if (_clab($after,SUBTYPE.'-1') ne $x);
		}
	}
	return @f;
}

1;
__END__
