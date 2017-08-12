#####################################################################################################
# ATypes.pm
#####################################################################################################
package ATypes;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

require Exporter;

@EXPORT_OK = qw(	ATYPE_USER_LOGIN
						ATYPE_DB_MANT_TABLE_LIMIT
						ATYPE_SET_METRICS_FROM_ASISTANT
						ATYPE_SET_METRICS_FROM_TEMPLATE
						ATYPE_SET_TEMPLATE_FROM_ASISTANT
						ATYPE_RESET_METRICS
						ATYPE_SET_METRICS_FROM_TEMPLATE_CHANGE_DEVICE
						ATYPE_SET_METRICS_FROM_TEMPLATE_CHANGE_METRIC
						ATYPE_SET_METRICS_FROM_ASISTANT_BLOCK
						ATYPE_SET_METRICS_FROM_TEMPLATE_BLOCK
						ATYPE_SET_TEMPLATE_FROM_ASISTANT_BLOCK
						ATYPE_CLONE_METRICS
						ATYPE_IIDS_MODIFIED
						ATYPE_IIDS_ERASED
						ATYPE_DEVICE2INACTIVE
						ATYPE_DEVICE2ACTIVE
						ATYPE_DEVICE2MAINTENANCE
						ATYPE_GET_CSV_DEVICES
						ATYPE_GET_CSV_METRICS
						ATYPE_GET_CSV_VIEWS
						ATYPE_NETWORK_AUDIT
						ATYPE_APP_EXECUTED
						ATYPE_MCNM_DOMAIN_SYNC
						ATYPE_NOTIF_BY_EMAIL
                  ATYPE_NOTIF_BY_SMS
                  ATYPE_NOTIF_BY_TRAP
                  ATYPE_NOTIF_BY_TELEGRAM
);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);
$VERSION = '1.00';


#----------------------------------------------------------------------------
use constant ATYPE_USER_LOGIN 										=> 1;
use constant ATYPE_DB_MANT_TABLE_LIMIT								=> 2;


use constant ATYPE_SET_METRICS_FROM_ASISTANT 					=> 10;
use constant ATYPE_SET_METRICS_FROM_TEMPLATE 					=> 11;
use constant ATYPE_SET_TEMPLATE_FROM_ASISTANT 					=> 12;
use constant ATYPE_RESET_METRICS 									=> 13;
use constant ATYPE_SET_METRICS_FROM_TEMPLATE_CHANGE_DEVICE 	=> 14;
use constant ATYPE_SET_METRICS_FROM_TEMPLATE_CHANGE_METRIC 	=> 15;

use constant ATYPE_SET_METRICS_FROM_ASISTANT_BLOCK    		=> 16;
use constant ATYPE_SET_METRICS_FROM_TEMPLATE_BLOCK    		=> 17;
use constant ATYPE_SET_TEMPLATE_FROM_ASISTANT_BLOCK   		=> 18;

use constant ATYPE_CLONE_METRICS 									=> 19;

use constant ATYPE_IIDS_MODIFIED 									=> 20;
use constant ATYPE_IIDS_ERASED 										=> 21;


use constant ATYPE_DEVICE2INACTIVE 				=> 30;
use constant ATYPE_DEVICE2ACTIVE 				=> 31;
use constant ATYPE_DEVICE2MAINTENANCE 			=> 32;

use constant ATYPE_GET_CSV_DEVICES 				=> 40;
use constant ATYPE_GET_CSV_METRICS 				=> 41;
use constant ATYPE_GET_CSV_VIEWS 				=> 42;

use constant ATYPE_NETWORK_AUDIT 				=> 50;
use constant ATYPE_APP_EXECUTED 					=> 51;

#----------------------------------------------------------------------------
use constant ATYPE_MCNM_DOMAIN_SYNC 			=> 200;



#----------------------------------------------------------------------------
use constant ATYPE_NOTIF_BY_EMAIL 				=> 1001;
use constant ATYPE_NOTIF_BY_SMS 					=> 1002;
use constant ATYPE_NOTIF_BY_TRAP 				=> 1003;
use constant ATYPE_NOTIF_BY_TELEGRAM			=> 1004;
#----------------------------------------------------------------------------

1;
__END__
