<?php

   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'BRIDGE-MIB::newRoot',      'hiid' => 'ea1c3c284d',
      'descr' => 'NUEVO ROOT DE SPANNING TREE',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'mib-2.17',
      'apptype' => 'NET.BASE', 'itil_type' => '1', 'class'=>'BRIDGE-MIB', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'BRIDGE-MIB::topologyChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'CAMBIO DE TOPOLOGIA DE SPANNING TREE',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'mib-2.17',
      'apptype' => 'NET.BASE', 'itil_type' => '1', 'class'=>'BRIDGE-MIB', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );


?>
