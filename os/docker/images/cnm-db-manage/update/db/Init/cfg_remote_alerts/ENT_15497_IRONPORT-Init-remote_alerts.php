<?php

   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'ASYNCOS-MAIL-MIB::resourceConservationMode',      'hiid' => 'ea1c3c284d',
      'descr' => 'IRONPORT - RECURSO EN MODO CONSERVACION',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'resourceConservationReason',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.15497',
      'apptype' => 'NET.IRONPORT', 'itil_type' => '1', 'class'=>'IRONPORT', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'resourceConservationReason', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'ASYNCOS-MAIL-MIB::powerSupplyStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'IRONPORT - CAMBIO DE ESTADO DE LA FUENTE DE ALIMENTACION',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'powerSupplyStatus',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.15497',
      'apptype' => 'NET.IRONPORT', 'itil_type' => '1', 'class'=>'IRONPORT', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'powerSupplyStatus', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'ASYNCOS-MAIL-MIB::highTemperature',      'hiid' => 'ea1c3c284d',
      'descr' => 'IRONPORT - TEMPERATURA EXCESIVA',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'temperatureName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.15497',
      'apptype' => 'NET.IRONPORT', 'itil_type' => '1', 'class'=>'IRONPORT', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'temperatureName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'ASYNCOS-MAIL-MIB::fanFailure',      'hiid' => 'ea1c3c284d',
      'descr' => 'IRONPORT - FALLO DEL VENTILADOR',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'fanName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.15497',
      'apptype' => 'NET.IRONPORT', 'itil_type' => '1', 'class'=>'IRONPORT', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'fanName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'ASYNCOS-MAIL-MIB::keyExpiration',      'hiid' => 'ea1c3c284d',
      'descr' => 'IRONPORT - CLAVE CADUCADA',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'keyDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.15497',
      'apptype' => 'NET.IRONPORT', 'itil_type' => '1', 'class'=>'IRONPORT', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'keyDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'ASYNCOS-MAIL-MIB::updateFailure',      'hiid' => 'ea1c3c284d',
      'descr' => 'IRONPORT - FALLO DE ACTUALIZACION',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'updateServiceName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.15497',
      'apptype' => 'NET.IRONPORT', 'itil_type' => '1', 'class'=>'IRONPORT', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'updateServiceName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'ASYNCOS-MAIL-MIB::raidStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'IRONPORT - CAMBIO DE ESTADO DEL RAID',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'raidID',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.15497',
      'apptype' => 'NET.IRONPORT', 'itil_type' => '1', 'class'=>'IRONPORT', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'raidID', 'fx'=>'MATCH',  'expr'=>'')
      )
   );


?>
