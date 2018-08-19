<?php

   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CISCO-CCM-MIB::ccmCallManagerFailed',      'hiid' => '9d987a25b1',
      'descr' => 'FALLO EN CALL MANAGER',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'ccmAlarmSeverity;ccmFailCauseCode',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9.156',
      'apptype' => 'NET.CISCO-VOIP', 'itil_type' => '1', 'class'=>'CISCO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'ccmFailCauseCode', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CISCO-CCM-MIB::ccmPhoneFailed',      'hiid' => '9d987a25b1',
      'descr' => 'FALLO EN TELEFONO',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'ccmAlarmSeverity;ccmPhoneFailures',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9.156',
      'apptype' => 'NET.CISCO-VOIP', 'itil_type' => '1', 'class'=>'CISCO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'ccmPhoneFailures', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CISCO-CCM-MIB::ccmPhoneStatusUpdate',      'hiid' => '9d987a25b1',
      'descr' => 'ACTUALIZACION DE TELEFONO',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'ccmAlarmSeverity;ccmPhoneUpdates',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9.156',
      'apptype' => 'NET.CISCO-VOIP', 'itil_type' => '1', 'class'=>'CISCO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'ccmPhoneUpdates', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CISCO-CCM-MIB::ccmGatewayFailed',      'hiid' => '90ac57f4f0',
      'descr' => 'FALLO DE GATEWAY',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'ccmAlarmSeverity;ccmGatewayName;ccmGatewayInetAddressType;ccmGatewayInetAddress;ccmGatewayFailCauseCode',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9.156',
      'apptype' => 'NET.CISCO-VOIP', 'itil_type' => '1', 'class'=>'CISCO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'ccmGatewayName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'ccmGatewayInetAddressType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'ccmGatewayInetAddress', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'ccmGatewayFailCauseCode', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CISCO-CCM-MIB::ccmMediaResourceListExhausted',      'hiid' => '1a8f9efa98',
      'descr' => 'AGOTADA LISTA DE RECURSOS',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'ccmAlarmSeverity;ccmMediaResourceType;ccmMediaResourceListName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9.156',
      'apptype' => 'NET.CISCO-VOIP', 'itil_type' => '1', 'class'=>'CISCO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'ccmMediaResourceType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'ccmMediaResourceListName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CISCO-CCM-MIB::ccmRouteListExhausted',      'hiid' => '9d987a25b1',
      'descr' => 'AGOTADA LISTA DE RUTAS DE TELEFONIA',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'ccmAlarmSeverity;ccmRouteListName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9.156',
      'apptype' => 'NET.CISCO-VOIP', 'itil_type' => '1', 'class'=>'CISCO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'ccmRouteListName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CISCO-CCM-MIB::ccmGatewayLayer2Change',      'hiid' => '9d987a25b1',
      'descr' => 'CAMBIO EN NIVEL 2',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'ccmAlarmSeverity;ccmRouteListName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9.156',
      'apptype' => 'NET.CISCO-VOIP', 'itil_type' => '1', 'class'=>'CISCO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'ccmRouteListName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );


?>
