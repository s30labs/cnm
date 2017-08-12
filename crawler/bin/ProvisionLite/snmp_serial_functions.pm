#####################################################################################################
# Fichero: ProvisionLite::snmp_serial_functions.pm
# Set Tab=3
#####################################################################################################
package ProvisionLite::snmp_serial_functions;
$VERSION='1.00';
use strict;
use Crawler::SNMP;
use Data::Dumper;

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
sub snmp_fx_serialn_by_entity {
my ($desc,$snmp)=@_;

   my $serialn = '';
	if (!defined $snmp) {
		$snmp->log('warning',"snmp_fx_serialn_cisco::[WARN] snmp NO DEFINIDO");
		return $serialn;
	}
	if (ref($snmp) ne 'Crawler::SNMP') {
		$snmp->log('warning',"snmp_fx_serialn_cisco::[WARN] snmp NO ES OBJETO");
		return $serialn;
	}

   $desc->{'oid'}='ENTITY-MIB::entPhysicalTable';
   my $entity_table=$snmp->core_snmp_table_hash($desc);
	my $rc=$snmp->err_num();
	if ($rc) {
		my $err_str=$snmp->err_str();
		$snmp->log('warning',"snmp_fx_serialn_cisco::[WARN] rc=$rc ($err_str)");
		return $serialn;
	}

#print Dumper($entity_table);

#          '2003' => {
#                      'entPhysicalHardwareRev' => '',
#                      'entPhysicalIsFRU' => '2',
#                      'entPhysicalAssetID' => '',
#                      'entPhysicalDescr' => 'Switch 2 - WS-C3750-48P - Power Supply 0',
#                      'entPhysicalContainedIn' => '2001',
#                      'entPhysicalSerialNum' => 'DTN1323443D',
#                      'entPhysicalSoftwareRev' => '',
#                      'entPhysicalClass' => '6',
#                      'entPhysicalParentRelPos' => '2',
#                      'entPhysicalAlias' => '',
#                      'entPhysicalMfgName' => '',
#                      'entPhysicalName' => 'Switch 2 - WS-C3750-48P - Power Supply 0',
#                      'entPhysicalVendorType' => '.1.3.6.1.4.1.9.12.3.1.6.95',
#                      'entPhysicalModelName' => '',
#                      'entPhysicalFirmwareRev' => ''
#                    }

   foreach my $iid (keys %$entity_table) {
      if (exists $entity_table->{$iid}->{'entPhysicalSerialNum'}) {
         my $s = $entity_table->{$iid}->{'entPhysicalSerialNum'};
			my $n = $entity_table->{$iid}->{'entPhysicalDescr'};
			if ($s ne '') {
				$snmp->log('debug',"snmp_fx_serialn_cisco::[INFO] iid=$iid ($n) SERIAL=$s");			
			}

			# Revisar cuales el mejor criterio para elegir el serialn .....
			if ( ($s ne '') && ($serialn eq '') ) { $serialn=$s; }
      }
   }

   return $serialn;

}

1;
__END__

