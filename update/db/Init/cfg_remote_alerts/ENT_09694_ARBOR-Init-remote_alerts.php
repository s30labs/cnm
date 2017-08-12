<?php

   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::subHostDown',      'hiid' => 'b639a187f3',
      'descr' => 'CAIDA DE SUBHOST',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapSubhostName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapSubhostName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailProtectionGroupError',      'hiid' => '90ac57f4f0',
      'descr' => 'ERROR EN GRUPO DE PROTECCION',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailProtectionGroupId;pravailProtectionGroupName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailProtectionGroupId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'pravailProtectionGroupName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailConfigMissing',      'hiid' => 'b639a187f3',
      'descr' => 'EQUIPO SIN CONFIGURACION',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailConfigError',      'hiid' => 'b639a187f3',
      'descr' => 'ERROR DE CONFIGURACION',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailHwDeviceDown',      'hiid' => 'b639a187f3',
      'descr' => 'DISPOSITVO HARDWARE CAIDO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailHwSensorCritical',      'hiid' => 'b639a187f3',
      'descr' => 'SENSOR HARDWARE EN ESTADO CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailSwComponentDown',      'hiid' => 'dba32c578c',
      'descr' => 'PROCESO SOFTWARE CAIDO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapSubhostName;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapSubhostName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailSystemStatusCritical',      'hiid' => 'b639a187f3',
      'descr' => 'SISTEMA EN ESTADO CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailSystemStatusDegraded',      'hiid' => 'b639a187f3',
      'descr' => 'SISTEMA DEGRADADO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailFilesystemCritical',      'hiid' => 'b639a187f3',
      'descr' => 'SISTEMA DE FICHEROS LLENO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailGRETunnelFailure',      'hiid' => 'b639a187f3',
      'descr' => 'ERROR EN TUNEL GRE',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailNextHopUnreachable',      'hiid' => 'b639a187f3',
      'descr' => 'NO SE ALCANZA NEXT HOP',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailPerformance',      'hiid' => '1a8f9efa98',
      'descr' => 'SISTEMA DEGRADADO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailSystemStatusError',      'hiid' => 'b639a187f3',
      'descr' => 'ERROR DE ESTADO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailCloudSignalTimeout',      'hiid' => 'b639a187f3',
      'descr' => 'TIMEOUT EN ACCESO A SERVICIOS EN LA NUBE',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailCloudSignalThreshold',      'hiid' => 'b639a187f3',
      'descr' => 'ERRROR EN ACCESO A SERVICIOS EN LA NUBE',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailTrapTraffic',      'hiid' => 'd193e9716c',
      'descr' => 'EXCESO DE TRAFICO EN GRUPO DE PROTECCION',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrafficLevel', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'pravailTrafficUnits', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'pravailProtectionGroupName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'pravailURL', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailTrapBotnetAttack',      'hiid' => 'd193e9716c',
      'descr' => 'ATAQUE DE BOTNET',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrafficLevel', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'pravailTrafficUnits', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'pravailProtectionGroupName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'pravailURL', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailTrapLicenseLimit',      'hiid' => 'b639a187f3',
      'descr' => 'EXCEDIDO EL LIMITE DE LICENCIAS',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailURL',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailURL', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PRAVAIL-MIB::pravailTrapBlockedTraffic',      'hiid' => 'd193e9716c',
      'descr' => 'EL TRAFICO BLOQUEADO SUPERA EL UMBRAL DEL GRUPO DE PROTECCION',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.9694',
      'apptype' => 'NET.ARBOR', 'itil_type' => '1', 'class'=>'ARBOR NETW', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'pravailTrafficLevel', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'pravailTrafficUnits', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'pravailProtectionGroupName', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'pravailURL', 'fx'=>'MATCH',  'expr'=>'')
      )
   );


?>
