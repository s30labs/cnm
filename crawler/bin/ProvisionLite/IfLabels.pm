#####################################################################################################
# Fichero: (ProvisionLite::IfLabels.pm)
# Descripcion:
#	Etiqueta de cada interfaz para las metricas de interfaz (traffic_mibii_if, status_mibii_if):
#	el mismo texto para los dos subtipos, elegido por iid entre ifName, ifDescr e ifAlias.
#
#	Orden, por iid (choose_labels):
#	  1. ifName, salvo que este vacio, sea un nombre generico de Windows (ethernet_32768,
#	     loopback_0, tunnel_32768...) o se repita en el equipo;
#	  2. ifDescr, salvo que este vacio o se repita;
#	  3. ifAlias, salvo que este vacio o se repita;
#	  4. si ninguno vale, el primero que tenga texto (ifName, ifDescr, ifAlias), aunque se repita.
#	Por que (medido en wwcnmprd03, 18-nov-2026): ifName es el mejor en ESXi, FortiGate, NetScaler,
#	switches y Linux; en Windows es generico y el bueno es ifDescr; ifAlias lo escribe el usuario
#	y en ESXi se repite (vSwitch0).
#
#	Cada columna se lee en su propio recorrido (read_columns): un fallo en los contadores de
#	64 bits ya no cambia el origen de la etiqueta.
#	Diseno: cnm-docs, REG-CNM-Deuda 4.108.
# Set Tab=3
#####################################################################################################
package ProvisionLite::IfLabels;
$VERSION='1.00';
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(read_columns choose_labels if_labels generic_ifname);

my @COLUMNS = ('ifName','ifDescr','ifAlias');

#----------------------------------------------------------------------------
# generic_ifname($v)
# Nombres que pone Windows en ifName: tipo de interfaz y un numero, sin significado.
#----------------------------------------------------------------------------
sub generic_ifname {
my ($v)=@_;
	return ((defined $v) && ($v =~ /^(ethernet|loopback|tunnel|ppp|wireless|other)_\d+$/)) ? 1 : 0;
}

#----------------------------------------------------------------------------
# read_columns($snmp,\%snmpcfg)
# Recorre ifName, ifDescr e ifAlias, cada uno por separado. Devuelve
# { ifName=>{iid=>valor}, ifDescr=>{...}, ifAlias=>{...} }. Se descartan las filas
# sin iid numerico (las que devuelve core_snmp_table cuando falla).
#----------------------------------------------------------------------------
sub read_columns {
my ($snmp,$snmpcfg)=@_;

	my %col=();
	foreach my $c (@COLUMNS) {
		my $res = $snmp->core_snmp_table({ %$snmpcfg, 'oid'=>$c });
		foreach my $l (@{ $res || [] }) {
			my ($iid,$v) = split(':@:',$l,2);
			next if ((! defined $iid) || ($iid !~ /^\d+$/));
			$v = '' if ((! defined $v) || ($v eq 'U'));
			$v =~ s/^\s+|\s+$//g;
			$col{$c}{$iid} = $v;
		}
	}
	return \%col;
}

#----------------------------------------------------------------------------
# choose_labels(\%col)
# Devuelve { iid => { label=>, source=> } } para todos los iid que aparecen en alguna columna.
#----------------------------------------------------------------------------
sub choose_labels {
my ($col)=@_;

	my %dup=();
	foreach my $c (@COLUMNS) {
		my %n=();
		$n{$_}++ foreach (grep { $_ ne '' } values %{ $col->{$c} || {} });
		$dup{$c} = { map { $_=>1 } grep { $n{$_} > 1 } keys %n };
	}

	my %iids = map { $_=>1 } map { keys %{ $col->{$_} || {} } } @COLUMNS;
	my %out=();
	foreach my $iid (keys %iids) {
		my %v = map { $_ => (defined $col->{$_}{$iid} ? $col->{$_}{$iid} : '') } @COLUMNS;
		my $src;
		if (($v{'ifName'} ne '') && (! generic_ifname($v{'ifName'})) && (! $dup{'ifName'}{$v{'ifName'}})) { $src='ifName'; }
		elsif (($v{'ifDescr'} ne '') && (! $dup{'ifDescr'}{$v{'ifDescr'}})) { $src='ifDescr'; }
		elsif (($v{'ifAlias'} ne '') && (! $dup{'ifAlias'}{$v{'ifAlias'}})) { $src='ifAlias'; }
		else { ($src) = grep { $v{$_} ne '' } @COLUMNS; }
		next if (! defined $src);
		$out{$iid} = { 'label'=>$v{$src}, 'source'=>$src };
	}
	return \%out;
}

#----------------------------------------------------------------------------
# if_labels($snmp,\%snmpcfg): read_columns + choose_labels
#----------------------------------------------------------------------------
sub if_labels {
my ($snmp,$snmpcfg)=@_;
	return choose_labels(read_columns($snmp,$snmpcfg));
}

1;
