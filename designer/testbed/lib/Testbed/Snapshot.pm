#####################################################################################################
# Fichero: (Testbed::Snapshot.pm)
# Descripcion:
#	Compara dos fotos del estado de un equipo y prepara lo necesario para volver a una
#	de ellas. Funciones puras: no leen ni escriben la base; cnm-testbed hace las
#	consultas, guarda las fotos en JSON y ejecuta el plan. Diseno: cnm-docs,
#	PROY-CNM-Alertas-Azules §6.
#
#	Una foto:
#	  { id_dev, taken,
#	    parents  => { subtype => {id_template_metric,id_dev,id_dest,lapse,type,subtype} },
#	    template => { "subtype|iid" => {id_template_metric,id_dev,id_dest,iid,hiid,mname,
#	                                    watch,label,status,subtype} },
#	    metrics  => { name => {name,subtype,iid,c_label,watch,status} },
#	    blue     => [ mname, ... ],      alertas en azul (severity 4) del equipo
#	    qactions_max => N }
# Set Tab=3
#####################################################################################################
package Testbed::Snapshot;
$VERSION='1.00';
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(TEMPLATE_FIELDS METRIC_FIELDS inactive_mnames diff_snapshots diff_is_empty diff_lines restore_plan);

use constant TEMPLATE_FIELDS => [ qw(watch label status mname) ];
use constant METRIC_FIELDS   => [ qw(c_label watch status) ];

sub _d { my $v=shift; return (defined $v) ? $v : ''; }

sub _diff_hash {
my ($a,$b,$fields)=@_;
	my %r=( removed=>[], added=>[], changed=>[] );
	$a ||= {}; $b ||= {};
	foreach my $k (sort keys %$a) {
		if (! exists $b->{$k}) { push @{$r{'removed'}}, $k; next; }
		foreach my $f (@$fields) {
			my ($x,$y)=(_d($a->{$k}{$f}), _d($b->{$k}{$f}));
			push @{$r{'changed'}}, [ $k, $f, $x, $y ] if ($x ne $y);
		}
	}
	foreach my $k (sort keys %$b) { push @{$r{'added'}}, $k if (! exists $a->{$k}); }
	return \%r;
}

#----------------------------------------------------------------------------
# inactive_mnames(@snaps) -> { mname => 1 } de las instancias inactivas (status distinto
# de 0) en la plantilla de cualquiera de las fotos. Sus metricas no se comparan: la
# provision las borra de las metricas en curso (ProvisionLite.pm, "Si no son metricas
# activas"), asi que pueden estar en una foto y no en otra sin que nada vaya mal.
#----------------------------------------------------------------------------
sub inactive_mnames {
	my %i=();
	foreach my $s (@_) {
		foreach my $r (values %{$s->{'template'} || {}}) {
			$i{$r->{'mname'}}=1 if ((defined $r->{'mname'}) && (_d($r->{'status'}) ne '0'));
		}
	}
	return \%i;
}

sub _active_metrics {
my ($m,$inactive)=@_;
	my %r = map { $_ => $m->{$_} } grep { ! $inactive->{$_} } keys %{$m || {}};
	return \%r;
}

#----------------------------------------------------------------------------
# diff_snapshots($a,$b): diferencias de $a (antes) a $b (despues).
# Las metricas de instancias inactivas no se comparan (inactive_mnames).
#----------------------------------------------------------------------------
sub diff_snapshots {
my ($a,$b)=@_;
	my %ba = map { $_ => 1 } @{$a->{'blue'} || []};
	my %bb = map { $_ => 1 } @{$b->{'blue'} || []};
	my $inactive = inactive_mnames($a,$b);
	return {
		'template' => _diff_hash($a->{'template'}, $b->{'template'}, TEMPLATE_FIELDS),
		'metrics'  => _diff_hash(_active_metrics($a->{'metrics'},$inactive), _active_metrics($b->{'metrics'},$inactive), METRIC_FIELDS),
		'blue'     => { removed => [ sort grep { ! $bb{$_} } keys %ba ],
							 added   => [ sort grep { ! $ba{$_} } keys %bb ] },
	};
}

sub diff_is_empty {
my $d=shift;
	foreach my $t ('template','metrics') { foreach my $k ('removed','added','changed') { return 0 if (@{$d->{$t}{$k}}); } }
	return 0 if (@{$d->{'blue'}{'removed'}} || @{$d->{'blue'}{'added'}});
	return 1;
}

#----------------------------------------------------------------------------
# diff_lines($d) -> lineas de texto, sin tildes, para mostrar
#----------------------------------------------------------------------------
sub diff_lines {
my $d=shift;
	my @l=();
	my %name=( template=>'plantilla', metrics=>'metrica' );
	foreach my $t ('template','metrics') {
		push @l, "  $name{$t} quitada: $_" foreach (@{$d->{$t}{'removed'}});
		push @l, "  $name{$t} nueva:   $_" foreach (@{$d->{$t}{'added'}});
		push @l, "  $name{$t} cambia:  $_->[0] $_->[1]: '$_->[2]' -> '$_->[3]'" foreach (@{$d->{$t}{'changed'}});
	}
	push @l, "  azul que ya no esta: $_" foreach (@{$d->{'blue'}{'removed'}});
	push @l, "  azul nueva:          $_" foreach (@{$d->{'blue'}{'added'}});
	return @l;
}

#----------------------------------------------------------------------------
# restore_plan($snap,$now): que hacer para volver de $now a $snap.
# Devuelve {
#	parents_insert  => [ fila ]          prov_template_metrics que faltan
#	parents_delete  => [ fila ]          prov_template_metrics que sobran (con sus filas)
#	template_insert => [ fila ]          prov_template_metrics2iid que faltan
#	template_update => [ [fila,campos] ] filas que cambian (watch,label,status)
#	template_delete => [ fila ]          filas que sobran
#	c_label         => [ [name,c_label] ] el c_label de cada metrica de la foto; se aplica
#	                                      despues de provisionar, donde sea distinto
# }
#----------------------------------------------------------------------------
sub restore_plan {
my ($snap,$now)=@_;
	my %p=( parents_insert=>[], parents_delete=>[], template_insert=>[], template_update=>[], template_delete=>[], c_label=>[] );
	my ($sp,$np)=($snap->{'parents'} || {}, $now->{'parents'} || {});
	foreach my $s (sort keys %$sp) { push @{$p{'parents_insert'}}, $sp->{$s} if (! exists $np->{$s}); }
	foreach my $s (sort keys %$np) { push @{$p{'parents_delete'}}, $np->{$s} if (! exists $sp->{$s}); }

	my ($st,$nt)=($snap->{'template'} || {}, $now->{'template'} || {});
	foreach my $k (sort keys %$st) {
		if (! exists $nt->{$k}) { push @{$p{'template_insert'}}, $st->{$k}; next; }
		my @f = grep { _d($st->{$k}{$_}) ne _d($nt->{$k}{$_}) } qw(watch label status);
		push @{$p{'template_update'}}, [ $st->{$k}, \@f ] if (@f);
	}
	foreach my $k (sort keys %$nt) { push @{$p{'template_delete'}}, $nt->{$k} if (! exists $st->{$k}); }

	my $sm = $snap->{'metrics'} || {};
	foreach my $n (sort keys %$sm) { push @{$p{'c_label'}}, [ $n, _d($sm->{$n}{'c_label'}) ]; }
	return \%p;
}

1;
__END__
