# ----------------------------------------------------------------------------------------------
# CapacityMetrics.pm
# ----------------------------------------------------------------------------------------------
package CapacityMetrics;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

require Exporter;

@EXPORT_OK = qw( %Functions );

@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

# ----------------------------------------------------------------------------------------------
# CapacityMetrics Funcions defined
# ----------------------------------------------------------------------------------------------
%CapacityMetrics::Functions = (

   #------------------------------------------------------------
   'disk_mibhost' => \&CapacityMetrics::disk_mibhost,
   'disk_mibhostp' => \&CapacityMetrics::disk_mibhostp,
   'xagt_004403' => \&CapacityMetrics::xagt_004403,
   'default' => \&CapacityMetrics::default,

);

# ----------------------------------------------------------------------------------------------
# snmp | disk_mibhost | USO DE DISCO
# ----------------------------------------------------------------------------------------------
sub CapacityMetrics::disk_mibhost {
my ($values)=@_;

	my $v=0;
	if ($values->[0] != 0) {
		$v = ($values->[1] / $values->[0])*100;
	}
	return $v;
}

# ----------------------------------------------------------------------------------------------
# snmp | disk_mibhostp | USO DE DISCO (%)
# ----------------------------------------------------------------------------------------------
sub CapacityMetrics::disk_mibhostp {
my ($values)=@_;
	return $values->[0];
}


# ----------------------------------------------------------------------------------------------
# xagent | xagt_004403 | USO DE DISCO (%)
# ----------------------------------------------------------------------------------------------
sub CapacityMetrics::xagt_004403 {
my ($values)=@_;
   return $values->[0];
}


# ----------------------------------------------------------------------------------------------
# all | default function
# ----------------------------------------------------------------------------------------------
sub CapacityMetrics::default {
my ($values)=@_;
   return $values->[0];
}


1;

