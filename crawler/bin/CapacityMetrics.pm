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

   'traffic_mibii_if' => \&CapacityMetrics::traffic_mibii_if,
   'traffic_mibii_if_hc' => \&CapacityMetrics::traffic_mibii_if,
   'xagt_004404' => \&CapacityMetrics::traffic_mibii_if,

   'mib2_glob_ifstat' => \&CapacityMetrics::mib2_glob_ifstat,

   'default' => \&CapacityMetrics::default,
   #'' => \&CapacityMetrics::,

);

# ----------------------------------------------------------------------------------------------
# snmp | disk_mibhost | USO DE DISCO
# ----------------------------------------------------------------------------------------------
sub CapacityMetrics::disk_mibhost {
my ($values,$m)=@_;

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
my ($values,$m)=@_;
	return $values->[0];
}


# ----------------------------------------------------------------------------------------------
# xagent | xagt_004403 | USO DE DISCO (%)
# ----------------------------------------------------------------------------------------------
sub CapacityMetrics::xagt_004403 {
my ($values,$m)=@_;
   return $values->[0];
}

# ----------------------------------------------------------------------------------------------
# xagent | xagt_004403 | USO DE DISCO (%)
# ----------------------------------------------------------------------------------------------
sub CapacityMetrics::traffic_mibii_if {
my ($values,$m)=@_;

   my $v=0;
   if (($values->[0] =~ /\d+/) && ($values->[1] =~ /\d+/)) {
      $v = $values->[0] + $values->[1];
		if ($m->{'metriclevel1'} =~ /\d+/) { $v = ($v / $m->{'metriclevel1'})*100; }
print "-----v=$v >> $values->[0] | $values->[1]\n";
   }
   return $v;
}

# ----------------------------------------------------------------------------------------------
# snmp | mib2_glob_ifstat | RESUMEN ESTADO DE INTERFACES
# ----------------------------------------------------------------------------------------------
sub CapacityMetrics::mib2_glob_ifstat {
my ($values,$m)=@_;

	my $v=0;
	#up|admin down|down|unk
	if ($values->[3] !~ /\d+/) { $values->[3]=0; }
   if (($values->[0] =~ /\d+/) && ($values->[1] =~ /\d+/) && ($values->[2] =~ /\d+/) && ($values->[3] =~ /\d+/)) {
		my $tot = $values->[0] + $values->[1] + $values->[2] + $values->[3];
		my $in_use = $values->[0]+$values->[2];
      $v = ($in_use/$tot)*100;
   }
   return $v;

}



# ----------------------------------------------------------------------------------------------
# all | default function
# ----------------------------------------------------------------------------------------------
sub CapacityMetrics::default {
my ($values,$m)=@_;
   return $values->[0];
}


1;

