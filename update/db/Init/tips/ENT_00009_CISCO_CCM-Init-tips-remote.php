<?php
      $TIPS[]=array(
         'id_ref' => 'CISCO-CCM-MIB::ccmCallManagerFailed',  'tip_type' => 'remote', 'url' => '',
         'date' => '',     'tip_class' => 1, 'name' => 'CNM-Info',
         'descr' => '"This Notification signifies that the CallManager process
         detects a failure in one of its critical subsystems. It can
         also be detected from a heartbeat/event monitoring process."
v1: <strong>ccmAlarmSeverity</strong><br>"The Alarm Severity code.
             emergency:                System unusable
             alert:                    Immediate response needed
             critical:                 Critical condition
             error:                    Error condition
             warning:                  Warning condition
             notice:                   Normal but significant condition
             informational:            Informational situation."
<br>INTEGER {emergency(1), alert(2), critical(3), error(4), warning(5), notice(6), informational(7)} 
   <br>v2: <strong>ccmFailCauseCode</strong><br>"The Cause code of the failure. This cause is derived from a
         monitoring thread in the CallManager or from a heartbeat
         monitoring process.
           unknown:                   Unknown
           heartBeatStopped:          The CallManager stops generating
                                      a heartbeat
           routerThreadDied:          The CallManager detects the death
                                      of the router thread
           timerThreadDied:           The CallManager detects the death
                                      of the timer thread
           criticalThreadDied:        The CallManager detects the death
                                      of one of its critical threads
           deviceMgrInitFailed:       The CallManager fails to start its
                                      device manager subsystem
           digitAnalysisInitFailed:   The CallManager fails to start its
                                      digit analysis subsystem
           callControlInitFailed:     The CallManager fails to start its
                                      call control subsystem
           linkMgrInitFailed:         The CallManager fails to start its
                                      link manager subsystem
           dbMgrInitFailed:           The CallManager fails to start its
                                      database manager subsystem
           msgTranslatorInitFailed:   The CallManager fails to start its
                                      message translation manager
                                      subsystem
           suppServicesInitFailed:    The CallManager fails to start its
                                      supplementary services subsystem."
<br>INTEGER {unknown(1), heartBeatStopped(2), routerThreadDied(3), timerThreadDied(4), criticalThreadDied(5), deviceMgrInitFailed(6), digitAnalysisInitFailed(7), callControlInitFailed(8), linkMgrInitFailed(9), dbMgrInitFailed(10), msgTranslatorInitFailed(11), suppServicesInitFailed(12)} 
   <br>',
      );


      $TIPS[]=array(
         'id_ref' => 'CISCO-CCM-MIB::ccmPhoneFailed',  'tip_type' => 'remote', 'url' => '',
         'date' => '',     'tip_class' => 1, 'name' => 'CNM-Info',
         'descr' => '"This Notification will be generated in the intervals 
         specified in ccmPhoneFailedAlarmInterval if there is 
         at least one entry in the ccmPhoneFailedTable."
v1: <strong>ccmAlarmSeverity</strong><br>"The Alarm Severity code.
             emergency:                System unusable
             alert:                    Immediate response needed
             critical:                 Critical condition
             error:                    Error condition
             warning:                  Warning condition
             notice:                   Normal but significant condition
             informational:            Informational situation."
<br>INTEGER {emergency(1), alert(2), critical(3), error(4), warning(5), notice(6), informational(7)} 
   <br>v2: <strong>ccmPhoneFailures</strong><br>"The count of the phone initialization or communication
         failures that are stored in the ccmPhoneFailedTable object."
<br>Unsigned32
   <br>',
      );


      $TIPS[]=array(
         'id_ref' => 'CISCO-CCM-MIB::ccmPhoneStatusUpdate',  'tip_type' => 'remote', 'url' => '',
         'date' => '',     'tip_class' => 1, 'name' => 'CNM-Info',
         'descr' => '"This Notification will be generated in the intervals 
         specified in ccmPhoneStatusUpdateInterv if there is 
         at least one entry in the ccmPhoneStatusUpdateTable."
v1: <strong>ccmAlarmSeverity</strong><br>"The Alarm Severity code.
             emergency:                System unusable
             alert:                    Immediate response needed
             critical:                 Critical condition
             error:                    Error condition
             warning:                  Warning condition
             notice:                   Normal but significant condition
             informational:            Informational situation."
<br>INTEGER {emergency(1), alert(2), critical(3), error(4), warning(5), notice(6), informational(7)} 
   <br>v2: <strong>ccmPhoneUpdates</strong><br>"The count of the phone status changes that are stored in
         the ccmPhoneStatusUpdateTable object."
<br>Unsigned32
   <br>',
      );


      $TIPS[]=array(
         'id_ref' => 'CISCO-CCM-MIB::ccmGatewayFailed',  'tip_type' => 'remote', 'url' => '',
         'date' => '',     'tip_class' => 1, 'name' => 'CNM-Info',
         'descr' => '"This Notification indicates that at least one gateway has
         attempted to register or communicate with the CallManager
         and failed."
v1: <strong>ccmAlarmSeverity</strong><br>"The Alarm Severity code.
             emergency:                System unusable
             alert:                    Immediate response needed
             critical:                 Critical condition
             error:                    Error condition
             warning:                  Warning condition
             notice:                   Normal but significant condition
             informational:            Informational situation."
<br>INTEGER {emergency(1), alert(2), critical(3), error(4), warning(5), notice(6), informational(7)} 
   <br>v2: <strong>ccmGatewayName</strong><br>"This is the Gateway name assigned to the Gateway in
         the CallManager. This name is assigned when a new
         device of type Gateway is added to the CallManager."
<br>OCTET STRING (0..128) 
   <br>v3: <strong>ccmGatewayInetAddressType</strong><br>"Represents the type of address stored in
         ccmGatewayInetAddress."
<br>INTEGER {unknown(0), ipv4(1), ipv6(2), ipv4z(3), ipv6z(4), dns(16)} 
   <br>v4: <strong>ccmGatewayInetAddress</strong><br>"The last known IP Address of the gateway. A value of
          all zeros indicates that the IP Address is not available."
<br>OCTET STRING (0..255) 
   <br>v5: <strong>ccmGatewayFailCauseCode</strong><br>"States the reason for a gateway device communication error."
<br>INTEGER {noError(0), unknown(1), noEntryInDatabase(2), databaseConfigurationError(3), deviceNameUnresolveable(4), maxDevRegReached(5), connectivityError(6), initializationError(7), deviceInitiatedReset(8), callManagerReset(9)} 
   <br>',
      );


      $TIPS[]=array(
         'id_ref' => 'CISCO-CCM-MIB::ccmMediaResourceListExhausted',  'tip_type' => 'remote', 'url' => '',
         'date' => '',     'tip_class' => 1, 'name' => 'CNM-Info',
         'descr' => '"This Notification indicates that the CallManager has run out
         a certain specified type of resource."
v1: <strong>ccmAlarmSeverity</strong><br>"The Alarm Severity code.
             emergency:                System unusable
             alert:                    Immediate response needed
             critical:                 Critical condition
             error:                    Error condition
             warning:                  Warning condition
             notice:                   Normal but significant condition
             informational:            Informational situation."
<br>INTEGER {emergency(1), alert(2), critical(3), error(4), warning(5), notice(6), informational(7)} 
   <br>v2: <strong>ccmMediaResourceType</strong><br>"The type of media resource.
             unknown:                Unknown resource type
             mediaTerminationPoint:  Media Termination Point
             transcoder:             Transcoder
             conferenceBridge:       Conference Bridge
             musicOnHold:            Music On Hold."
<br>INTEGER {unknown(1), mediaTerminationPoint(2), transcoder(3), conferenceBridge(4), musicOnHold(5)} 
   <br>v3: <strong>ccmMediaResourceListName</strong><br>"The name of a Media Resource List. This name is assigned
         when a new Media Resource List is added to the CallManager."
<br>OCTET STRING (0..128) 
   <br>',
      );


      $TIPS[]=array(
         'id_ref' => 'CISCO-CCM-MIB::ccmRouteListExhausted',  'tip_type' => 'remote', 'url' => '',
         'date' => '',     'tip_class' => 1, 'name' => 'CNM-Info',
         'descr' => '"This Notification indicates that the CallManager could not
         find an available route in the indicated route list."
v1: <strong>ccmAlarmSeverity</strong><br>"The Alarm Severity code.
             emergency:                System unusable
             alert:                    Immediate response needed
             critical:                 Critical condition
             error:                    Error condition
             warning:                  Warning condition
             notice:                   Normal but significant condition
             informational:            Informational situation."
<br>INTEGER {emergency(1), alert(2), critical(3), error(4), warning(5), notice(6), informational(7)} 
   <br>v2: <strong>ccmRouteListName</strong><br>"The name of a Route List. This name is assigned when a new
         Route List is added to the CallManager."
<br>OCTET STRING (0..128) 
   <br>',
      );


      $TIPS[]=array(
         'id_ref' => 'CISCO-CCM-MIB::ccmGatewayLayer2Change',  'tip_type' => 'remote', 'url' => '',
         'date' => '',     'tip_class' => 1, 'name' => 'CNM-Info',
         'descr' => '"This Notification is sent when the D-Channel/Layer 2 of an
         interface in a skinny gateway that has registered with the
         CallManager changes state."
v1: <strong>ccmAlarmSeverity</strong><br>"The Alarm Severity code.
             emergency:                System unusable
             alert:                    Immediate response needed
             critical:                 Critical condition
             error:                    Error condition
             warning:                  Warning condition
             notice:                   Normal but significant condition
             informational:            Informational situation."
<br>INTEGER {emergency(1), alert(2), critical(3), error(4), warning(5), notice(6), informational(7)} 
   <br>v2: <strong>ccmRouteListName</strong><br>"The name of a Route List. This name is assigned when a new
         Route List is added to the CallManager."
<br>OCTET STRING (0..128) 
   <br>',
      );


?>
