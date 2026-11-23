#-------------------------------------------------------------------------------------------
# Testbed::Ucd
# Si hay que esperar tras reiniciar snmpd antes de provisionar. Funciones puras.
#
# net-snmp no devuelve los valores de UCD-SNMP-MIB calculados sobre el ultimo minuto
# (ssCpuIdle, ssCpuUser, ssSwapIn...) hasta tener un minuto de historia (vmstat.c). Una
# provision dentro de ese minuto ve "No existe OID/IID" y quita la fila de la plantilla.
# Para no mantener una lista de objetos, se espera si el equipo tiene en la plantilla
# alguna fila activa de un subtipo de la empresa 2021 (UCD): cfg_monitor_snmp.enterprise
# = 2021, o algun OID de cfg_monitor_snmp.oid bajo .1.3.6.1.4.1.2021. (por si un subtipo
# a medida no lleva enterprise).
#-------------------------------------------------------------------------------------------
package Testbed::Ucd;
use strict;
use Exporter 'import';
our @EXPORT_OK = qw(UCD_ENTERPRISE is_ucd_monitor ucd_subtypes_in_use);

use constant UCD_ENTERPRISE => 2021;

# is_ucd_monitor({enterprise, oid}) -> 1 si el subtipo es de UCD
sub is_ucd_monitor {
my $c=shift;
	return 0 if (ref($c) ne 'HASH');
	my $e = $c->{'enterprise'};
	return 1 if ((defined $e) && ($e =~ /^\s*(\d+)\s*$/) && ($1 == UCD_ENTERPRISE));
	foreach my $o (split(/\|/, (defined $c->{'oid'}) ? $c->{'oid'} : '')) {
		return 1 if ($o =~ /^\s*\.?1\.3\.6\.1\.4\.1\.2021\./);
	}
	return 0;
}

# ucd_subtypes_in_use(\@rows) -> subtipos UCD con alguna fila activa (status 0), ordenados.
# @rows: { subtype, status, enterprise, oid } de la plantilla del equipo con su cfg_monitor_snmp.
sub ucd_subtypes_in_use {
my $rows=shift;
	my %s=();
	foreach my $r (@{$rows || []}) {
		next if ((! defined $r->{'status'}) || ($r->{'status'} ne '0'));
		$s{$r->{'subtype'}}=1 if (is_ucd_monitor($r));
	}
	return sort keys %s;
}

1;
