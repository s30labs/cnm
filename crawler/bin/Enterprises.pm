#----------------------------------------------------------------------------------------------------
# Enterprises.pm
# Contiene los multiples enterprises que puede soportar un enterprise determinado.
#----------------------------------------------------------------------------------------------------
package Enterprises;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

require Exporter;

@EXPORT_OK = qw(	%ENTERPRISE_CHECKS );
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);
$VERSION = '1.00';

#----------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------
%Enterprises::ENTERPRISE_CHECKS = (

	# Microsoft
	'311' => [ 
					{'enterprise' => '231', 'oid' => '.1.3.6.1.4.1.231.2.49.1.1.1.0'}, 		# Fujitsu Server View (RAID)
					{'enterprise' => '232', 'oid' => '.1.3.6.1.4.1.232.6.1.1.0'}, 				# Compaq
					{'enterprise' => '9', 'oid' => '.1.3.6.1.4.1.9.9.156.1.1.1.1.2.1'}, 		# Cisco Call Manager
					{'enterprise' => '77', 'oid' => '.1.3.6.1.4.1.77.1.2.4.0'},					# Lan Manager
					{'enterprise' => '37455', 'oid' => '.1.3.6.1.4.1.37455.3.1.1.1.1.0'}, 	# OCR SRM
					#{'enterprise' => '', 'oid' => ''}, 		#
				],

	# CNM
	'34225' => [
					{'enterprise' => '2021', 'oid' => '.1.3.6.1.4.1.2021.4.1.0'}, 				# UCDavis
				],

	# Net-SNMP
	'8072' => [
					{'enterprise' => '2021', 'oid' => '.1.3.6.1.4.1.2021.4.1.0'}, 				# UCDavis
					{'enterprise' => '6876', 'oid' => '.1.3.6.1.4.1.6876.1.1.0'}, 				# VMWare ESX-Server
					{'enterprise' => '2620', 'oid' => '.1.3.6.1.4.1.2620.1.1.1.0'}, 			# Checkpoint
					{'enterprise' => '22736', 'oid' => '.1.3.6.1.4.1.22736.1.1.1.0'}, 		# Asterisk
					{'enterprise' => '39959', 'oid' => '.1.3.6.1.4.1.39959.1.1.1.1.0'},     # CIRCUTOR-POWERSTUDIO-MIB
				],
);


1;
__END__
