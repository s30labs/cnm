<?php

   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'VMWARE-TRAPS-MIB::vmPoweredOn',      'hiid' => '842b1bd2b7',
      'descr' => 'MAQUINA VIRTUAL ARRANCADA',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'vmID;vmConfigFile',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.6876',
      'apptype' => 'VIRTUAL.VMWARE', 'itil_type' => '1', 'class'=>'VMWARE', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'VMWARE-TRAPS-MIB::vmPoweredOff',      'hiid' => '842b1bd2b7',
      'descr' => 'MAQUINA VIRTUAL APAGADA',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'vmID;vmConfigFile',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.6876',
      'apptype' => 'VIRTUAL.VMWARE', 'itil_type' => '1', 'class'=>'VMWARE', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'VMWARE-TRAPS-MIB::vmHBLost',      'hiid' => '842b1bd2b7',
      'descr' => 'PERDIDA DE HEATBEAT CON EL HOST',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'vmID;vmConfigFile',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.6876',
      'apptype' => 'VIRTUAL.VMWARE', 'itil_type' => '1', 'class'=>'VMWARE', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'VMWARE-TRAPS-MIB::vmHBDetected',      'hiid' => '842b1bd2b7',
      'descr' => 'RECUPERADO HEATBEAT CON EL HOST',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'vmID;vmConfigFile',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.6876',
      'apptype' => 'VIRTUAL.VMWARE', 'itil_type' => '1', 'class'=>'VMWARE', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'VMWARE-TRAPS-MIB::vmSuspended',      'hiid' => '842b1bd2b7',
      'descr' => 'MAQUINA VIRTUAL SUSPENDIDA',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'vmID;vmConfigFile',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.6876',
      'apptype' => 'VIRTUAL.VMWARE', 'itil_type' => '1', 'class'=>'VMWARE', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH',  'expr'=>'')
      )
   );


?>
