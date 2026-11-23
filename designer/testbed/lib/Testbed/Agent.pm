#####################################################################################################
# Fichero: (Testbed::Agent.pm)
# Descripcion:
#	Lo que responde cnm-testbed-agent (pass_persist de net-snmp) para la tabla de
#	CNM-TESTBED-MIB, segun un escenario. Funciones puras: no leen ni escriben ficheros;
#	el agente lee el escenario y el contador de lecturas y llama a estas funciones.
#	Lo usan cnm-testbed-agent y cnm-testbed. Diseno: cnm-docs, PROY-CNM-Alertas-Azules §6.
#
#	Escenario (texto clave = valor, una por linea):
#	  mode   = complete | empty | cut-once | cut-always | cut-labels | drop | reorder
#	           cut-labels: en la primera lectura solo se corta la columna de etiquetas; la
#	           de valores (de la que salen las instancias) sale entera
#	  rows   = N        filas de la tabla (por defecto 5)
#	  cut_at = K        cut-*: cuantas filas devuelve la lectura cortada
#	  drop   = 2,4      indices que faltan, en cualquier modo salvo empty (en drop es
#	                    lo unico que cambia; en cut-once/cut-always se combina con el corte)
#	  delay  = S        segundos de espera antes de cada respuesta (0 por defecto)
#
#	Una "lectura" es lo que hace snmp_get_iid (Crawler/SNMP.pm:3288): recorre primero la
#	columna que se monitoriza (oid_tab, aqui la de valores), de la que saca las instancias,
#	y despues la de etiquetas (get_iid). El crawler, al leer las metricas, recorre solo la
#	columna de valores (core_snmp_table). Por eso la cuenta (read_step) solo pasa a la
#	lectura siguiente cuando la anterior ya ha recorrido las etiquetas: los recorridos del
#	crawler no la hacen avanzar y la provision recibe siempre su lectura cortada.
#	cut-once corta solo la primera lectura; cut-always, todas.
#	Historia: v1.00 contaba en la columna de etiquetas (la segunda lectura salia con la
#	columna de valores cortada); v1.01 contaba en la de valores (el crawler se llevaba el
#	corte: 4 lecturas en 9 minutos sin provisionar, cnm-11-8-test, 22-nov-2026).
#	El corte es silencioso: tras la fila K de la columna, el siguiente OID es el de la
#	siguiente columna, como un agente que devuelve menos filas sin dar error.
# Set Tab=3
#####################################################################################################
package Testbed::Agent;
$VERSION='1.03';
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(BASE_OID COL_LABEL COL_VALUE parse_scenario check_scenario scenario_text
						 table_rows oid_cmp walk_kind read_step parse_reads reads_text answer_get answer_getnext);

use constant BASE_OID  => '.1.3.6.1.4.1.8072.9999.9999.7';	# cnmTestbed
use constant ENTRY_OID => '.1.3.6.1.4.1.8072.9999.9999.7.1.1';	# cnmTestbedEntry
use constant COL_LABEL => 2;
use constant COL_VALUE => 3;

my %MODES = map { $_ => 1 } qw(complete empty cut-once cut-always cut-labels drop reorder);

#----------------------------------------------------------------------------
# parse_scenario($text) -> {mode,rows,cut_at,drop=>[...],delay}
# Lo que falta toma su valor por defecto. No valida: para eso, check_scenario.
#----------------------------------------------------------------------------
sub parse_scenario {
my $text=shift;
	my %s=( mode=>'complete', rows=>5, cut_at=>2, drop=>[], delay=>0 );
	return \%s if (! defined $text);
	foreach my $l (split(/\n/,$text)) {
		next if ($l =~ /^\s*(#|$)/);
		next if ($l !~ /^\s*(\w+)\s*=\s*(.*?)\s*$/);
		my ($k,$v)=($1,$2);
		if ($k eq 'drop') { $s{'drop'} = [ grep { /^\d+$/ } split(/\s*,\s*/,$v) ]; }
		elsif (exists $s{$k}) { $s{$k}=$v; }
	}
	return \%s;
}

#----------------------------------------------------------------------------
# check_scenario($s) -> '' si es valido, o el motivo
#----------------------------------------------------------------------------
sub check_scenario {
my $s=shift;
	return "modo desconocido: $s->{'mode'}" if (! $MODES{$s->{'mode'}});
	return "rows debe ser un entero entre 1 y 1000" if (($s->{'rows'} !~ /^\d+$/) || ($s->{'rows'} < 1) || ($s->{'rows'} > 1000));
	return "cut_at debe ser un entero entre 0 y rows" if (($s->{'cut_at'} !~ /^\d+$/) || ($s->{'cut_at'} > $s->{'rows'}));
	return "delay debe ser un entero entre 0 y 60" if (($s->{'delay'} !~ /^\d+$/) || ($s->{'delay'} > 60));
	foreach my $d (@{$s->{'drop'}}) { return "drop fuera de rango: $d" if (($d < 1) || ($d > $s->{'rows'})); }
	return '';
}

#----------------------------------------------------------------------------
# scenario_text($s) -> texto del fichero de escenario
#----------------------------------------------------------------------------
sub scenario_text {
my $s=shift;
	return "mode = $s->{'mode'}\nrows = $s->{'rows'}\ncut_at = $s->{'cut_at'}\n"
			."drop = ".join(',',@{$s->{'drop'}})."\ndelay = $s->{'delay'}\n";
}

#----------------------------------------------------------------------------
# table_rows($s,$read_no,$full) -> [ [index,label,value], ... ] ordenadas por indice
# $read_no: numero de la lectura en curso (1 la primera). $full: 1 para ignorar el
# corte (lo que el equipo "tiene"; se usa para los get de una fila concreta).
#----------------------------------------------------------------------------
sub table_rows {
my ($s,$read_no,$full)=@_;
	my $n=$s->{'rows'};
	my $mode=$s->{'mode'};
	return [] if ($mode eq 'empty');
	my %drop = map { $_ => 1 } @{$s->{'drop'}};
	my @r=();
	foreach my $i (1..$n) {
		next if ($drop{$i});
		# reorder: la etiqueta de la fila k pasa al indice n+1-k (mismas etiquetas, otros indices)
		my $k = ($mode eq 'reorder') ? ($n+1-$i) : $i;
		push @r, [ $i, "fila-$k", $k*10 ];
	}
	return \@r if ($full);
	if (($mode eq 'cut-always') || ((($mode eq 'cut-once') || ($mode eq 'cut-labels')) && ($read_no <= 1))) {
		splice(@r, $s->{'cut_at'}) if (scalar(@r) > $s->{'cut_at'});
	}
	return \@r;
}

#----------------------------------------------------------------------------
# oid_cmp($a,$b): -1, 0 o 1 comparando los OID numericos componente a componente
#----------------------------------------------------------------------------
sub oid_cmp {
my ($a,$b)=@_;
	my @a=grep { $_ ne '' } split(/\./,$a);
	my @b=grep { $_ ne '' } split(/\./,$b);
	for (my $i=0; ($i<@a) && ($i<@b); $i++) {
		return $a[$i] <=> $b[$i] if ($a[$i] != $b[$i]);
	}
	return scalar(@a) <=> scalar(@b);
}

#----------------------------------------------------------------------------
# walk_kind($oid) -> 'branch' | 'value' | 'label' | undef: que empieza un getnext de $oid.
# 'branch': la tabla o una rama superior a las columnas (recorre etiquetas y valores);
# 'value' y 'label': el principio de esa columna; undef: un getnext a mitad de recorrido.
#----------------------------------------------------------------------------
sub walk_kind {
my $oid=shift;
	return undef if (oid_cmp($oid,BASE_OID) < 0);
	foreach my $p (BASE_OID, BASE_OID.'.1', ENTRY_OID) { return 'branch' if (oid_cmp($oid,$p) == 0); }
	return 'value' if (oid_cmp($oid, ENTRY_OID.'.'.COL_VALUE) == 0);
	return 'label' if (oid_cmp($oid, ENTRY_OID.'.'.COL_LABEL) == 0);
	return undef;
}

#----------------------------------------------------------------------------
# read_step($state,$oid) -> estado nuevo. $state = { reads => N, labels => 0|1 }:
# N es la lectura en curso (0 si no ha empezado ninguna) y labels, si ya ha recorrido
# las etiquetas. Se pasa a la lectura siguiente con un recorrido de valores o de la rama
# solo si no habia empezado ninguna o la en curso ya recorrio las etiquetas.
#----------------------------------------------------------------------------
sub read_step {
my ($st,$oid)=@_;
	my %s = ( reads => ($st->{'reads'} || 0), labels => ($st->{'labels'} ? 1 : 0) );
	my $k = walk_kind($oid);
	return \%s if (! defined $k);
	if (($k eq 'value') || ($k eq 'branch')) {
		if (($s{'reads'} == 0) || $s{'labels'}) { $s{'reads'}++; $s{'labels'}=0; }
		$s{'labels'}=1 if ($k eq 'branch');
	}
	else {	# label
		$s{'reads'}=1 if ($s{'reads'} == 0);
		$s{'labels'}=1;
	}
	return \%s;
}

# parse_reads($text) -> estado; reads_text($state) -> "N L\n". Acepta el formato antiguo ("N").
sub parse_reads {
my $t=shift;
	return { reads=>0, labels=>0 } if ((! defined $t) || ($t !~ /^\s*(\d+)(?:\s+([01]))?/));
	return { reads=>$1+0, labels=>(defined $2 ? $2+0 : 0) };
}
sub reads_text { my $s=shift; return ($s->{'reads'}||0).' '.($s->{'labels'} ? 1 : 0)."\n"; }

# Las filas como lista ordenada de [oid,tipo,valor]
sub _varbinds {
my ($rows,$vrows)=@_;
	$vrows ||= $rows;	# filas de la columna de valores (cut-labels: enteras)
	my @v=();
	foreach my $r (@$rows)  { push @v, [ ENTRY_OID.'.'.COL_LABEL.'.'.$r->[0], 'string', $r->[1] ]; }
	foreach my $r (@$vrows) { push @v, [ ENTRY_OID.'.'.COL_VALUE.'.'.$r->[0], 'gauge', $r->[2] ]; }
	return \@v;
}

#----------------------------------------------------------------------------
# answer_get($s,$oid) -> [oid,tipo,valor] o undef (NONE). Sin corte: es una fila concreta.
#----------------------------------------------------------------------------
sub answer_get {
my ($s,$oid)=@_;
	foreach my $vb (@{_varbinds(table_rows($s,0,1))}) { return $vb if (oid_cmp($vb->[0],$oid) == 0); }
	return undef;
}

#----------------------------------------------------------------------------
# answer_getnext($s,$oid,$read_no) -> [oid,tipo,valor] o undef (fin de la tabla)
#----------------------------------------------------------------------------
sub answer_getnext {
my ($s,$oid,$read_no)=@_;
	my $vrows = ($s->{'mode'} eq 'cut-labels') ? table_rows($s,$read_no,1) : undef;
	foreach my $vb (@{_varbinds(table_rows($s,$read_no,0), $vrows)}) { return $vb if (oid_cmp($vb->[0],$oid) > 0); }
	return undef;
}

1;
__END__
