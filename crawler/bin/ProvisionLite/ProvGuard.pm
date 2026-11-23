#####################################################################################################
# Fichero: (ProvisionLite::ProvGuard.pm)
# Descripcion:
#	Salvaguarda de la provision: decide si una metrica SNMP con instancias de UN dispositivo
#	se puede actualizar con lo que ha respondido el equipo, o si hay que dejarla como esta.
#
#	G1. Sin datos: si la plantilla tiene instancias y la respuesta no trae ninguna valida
#	    (vacia, sin datos o solo 'U'), no se toca la metrica.
#	G2. Segunda lectura: si van a desaparecer instancias, se lee otra vez y solo
#	    desaparecen las que faltan en las dos lecturas. Si la segunda lectura no trae
#	    datos, no se toca la metrica.
#	Forzar (force) solo salta G1: una desaparicion total legitima. G2 se aplica siempre.
#
#	Es una funcion pura: no lee ni escribe la base. La llama ProvisionLite.pm.
#	Diseno: cnm-docs, REG-CNM-Deuda 4.104 y PROY-CNM-Alertas-Azules §6.
# Set Tab=3
#####################################################################################################
package ProvisionLite::ProvGuard;
$VERSION='1.00';
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(guard_mode valid_iids guard_decide GUARD_OFF GUARD_ON GUARD_WATCH);

use constant GUARD_OFF   => 0;	# lo de siempre
use constant GUARD_ON    => 1;	# la salvaguarda actua
use constant GUARD_WATCH => 2;	# observacion: avisa de lo que haria, pero hace lo de siempre

#----------------------------------------------------------------------------
# guard_mode($text)
# $text: contenido de /cfg/onm.conf. Devuelve 0, 1 o 2 segun PROV_GUARD.
# Sin la linea, o con un valor que no es 0, 1 o 2, devuelve 0 (lo de siempre).
#----------------------------------------------------------------------------
sub guard_mode {
my $text=shift;
	return GUARD_OFF if (! defined $text);
	my $v;
	foreach my $l (split(/\n/,$text)) {
		next if ($l =~ /^\s*#/);
		if ($l =~ /^\s*PROV_GUARD\s*=\s*(\S*)\s*$/) { $v=$1; }
	}
	return GUARD_OFF if ((! defined $v) || ($v !~ /^[012]$/));
	return $v+0;
}

#----------------------------------------------------------------------------
# valid_iids($mdata)
# Las instancias de una respuesta que son de verdad: ni vacias ni 'U'.
# En contexto escalar, cuantas son.
#----------------------------------------------------------------------------
sub valid_iids {
my $mdata=shift;
	my @v = (ref($mdata) eq 'HASH') ? (grep { (defined $_) && ($_ ne '') && ($_ ne 'U') } keys %$mdata) : ();
	return wantarray ? @v : scalar(@v);
}

#----------------------------------------------------------------------------
# guard_decide($a)
#
# $a: {
#	tpl    => [ iid, ... ]        instancias de la plantilla
#	read   => { iid => ... }      primera lectura (MDATA)
#	reread => sub { ... }         devuelve la segunda lectura; solo se llama si hace falta
#	force  => 0|1
# }
#
# Devuelve {
#	skip       => 0|1      1: no tocar la metrica
#	reason     => texto    por que (sin tildes)
#	missing    => [ iid ]  faltan en la primera lectura
#	reappeared => [ iid ]  faltaban en la primera y estan en la segunda
#	gone       => [ iid ]  faltan en las dos: desaparecen
#	second     => { iid => ... }   las entradas de la segunda lectura de reappeared
#	reread     => 0|1      se ha hecho la segunda lectura
# }
#----------------------------------------------------------------------------
sub guard_decide {
my $a=shift;
	my %r=( skip=>0, reason=>'', missing=>[], reappeared=>[], gone=>[], second=>{}, reread=>0 );
	my @tpl = (ref($a->{'tpl'}) eq 'ARRAY') ? @{$a->{'tpl'}} : ();
	return \%r if (! @tpl);   # nada que proteger

	my $read = $a->{'read'};
	if (! valid_iids($read)) {
		if ($a->{'force'}) { $r{'reason'}='sin datos en la lectura; se fuerza'; $r{'gone'}=[sort @tpl]; return \%r; }
		$r{'skip'}=1; $r{'reason'}='sin datos en la lectura'; return \%r;
	}

	my @missing = sort grep { ! exists $read->{$_} } @tpl;
	$r{'missing'}=\@missing;
	return \%r if (! @missing);

	my $second = (ref($a->{'reread'}) eq 'CODE') ? $a->{'reread'}->() : undef;
	$r{'reread'}=1;
	if (! valid_iids($second)) {
		$r{'skip'}=1; $r{'reason'}='sin datos en la segunda lectura'; return \%r;
	}

	foreach my $iid (@missing) {
		if (exists $second->{$iid}) { push @{$r{'reappeared'}}, $iid; $r{'second'}->{$iid}=$second->{$iid}; }
		else { push @{$r{'gone'}}, $iid; }
	}
	return \%r;
}

1;
__END__
