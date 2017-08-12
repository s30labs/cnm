<?php

   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CISCO-SYSLOG-MIB::clogMessageGenerated',      'hiid' => '56cb05e1a6',
      'descr' => 'CISCO SYSLOG - MENSAJE CRITICO',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'clogHistFacility;clogHistSeverity;clogHistMsgName;clogHistMsgText;clogHistTimestamp',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9',
      'apptype' => 'NET.CISCO', 'itil_type' => '1', 'class'=>'CISCO', 'include'=>'1',
		'set_hiid' => '56cb05e1a6', 
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v3', 'descr'=>'clogHistSeverity', 'fx'=>'<=',  'expr'=>'3')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CISCO-SYSLOG-MIB::clogMessageGenerated',      'hiid' => '26f1085a97',
      'descr' => 'CISCO SYSLOG - MENSAJE IMPORTANTE',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'clogHistFacility;clogHistSeverity;clogHistMsgName;clogHistMsgText;clogHistTimestamp',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9',
      'apptype' => 'NET.CISCO', 'itil_type' => '1', 'class'=>'CISCO', 'include'=>'1',
		'set_hiid' => '26f1085a97', 
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v3', 'descr'=>'clogHistSeverity', 'fx'=>'=',  'expr'=>'4')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CISCO-SYSLOG-MIB::clogMessageGenerated',      'hiid' => 'badb9024d4',
      'descr' => 'CISCO SYSLOG - AVISO',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'clogHistFacility;clogHistSeverity;clogHistMsgName;clogHistMsgText;clogHistTimestamp',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9',
      'apptype' => 'NET.CISCO', 'itil_type' => '1', 'class'=>'CISCO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v3', 'descr'=>'clogHistSeverity', 'fx'=>'=',  'expr'=>'5')
      )
   );


?>
