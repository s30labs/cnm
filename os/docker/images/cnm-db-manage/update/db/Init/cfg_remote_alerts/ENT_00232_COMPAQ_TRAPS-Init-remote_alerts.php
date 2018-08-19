<?php

   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQCLUSTER-MIB::cpqClusterNodeDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Nodo cluster degradado (15003  in CPQCLUS.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterNodeName',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQCLUSTER-MIB::cpqClusterFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cluster fallido (15002 in CPQCLUS.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterName',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQCLUSTER-MIB::cpqClusterDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cluster degradado (15001 in CPQCLUS.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterName',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQCLUSTER-MIB::cpqClusterNodeFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Nodo cluster fallido (15004 in CPQCLUS.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterNodeName',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQCLUSTER-MIB::cpqClusterResourceDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Recurso cluster degradado (15005 in CPQCLUS.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterResourceName',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQCLUSTER-MIB::cpqClusterResourceFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP:  Recurso cluster fallido (15006 in CPQCLUS.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterResourceName',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQCLUSTER-MIB::cpqClusterNetworkDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Red cluster degradada (15007 in CPQCLUS.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterNetworkName',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeThermalTempFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Temperatura fallida (6003 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeThermalTempDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Temperatura degradada (6004 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqHeThermalDegradedAction',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeThermalTempOk',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Temperatura normalizada (6005 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeThermalSystemFanFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilador sistema fallido (6006 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeThermalSystemFanDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilador sistema degradado (6007 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeThermalSystemFanOk',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilador sistema normalizado (6008 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeThermalCpuFanFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilador CPU fallido (6009 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeThermalCpuFanOk',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilador CPU normalizado (6010 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHePostError',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Errores ocurridos durante arranque (6013 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeFltTolPwrSupplyDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Alimentación redundante degradada (6014 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3ThermalTempFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Temperatura fallida (6017 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3ThermalTempDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Temperatura degradada (6018 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3ThermalTempOk',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Temperatura normalizada (6019 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3ThermalSystemFanFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilador sistema fallido (6020 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3ThermalSystemFanDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilador sistema degradado (6021 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3ThermalSystemFanOk',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilador sistema normalizado (6022 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3ThermalCpuFanFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilador CPU fallido (6023 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3ThermalCpuFanOk',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilador CPU normalizado (6024 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3PostError',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Errores ocurridos durante arranque (6027 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3FltTolPwrSupplyDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Alimentación redundante degradada (6028 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3FltTolPowerSupplyDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Alimentación redundante degradada (6030 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3FltTolPowerSupplyFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Alimentación redundante fallida (6031 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3FltTolPowerRedundancyLost',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Alimentación redundante fallida (6032 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3FltTolPowerSupplyInserted',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fuente de alimentación insertada (6033 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3FltTolPowerSupplyRemoved',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fuente de alimentación retirada (6034 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3FltTolFanDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilación redundante degradada (6035 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3FltTolFanFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilación redundante fallida (6036 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3FltTolFanRedundancyLost',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilación redundante fallida (6037 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3FltTolFanInserted',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilación redundante insertada (6038 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3FltTolFanRemoved',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilación redundante retirada (6039 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3TemperatureFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Temperatura fallida (6040 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3TemperatureDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Temperatura degradada (6041 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3TemperatureOk',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Temperatura normalizada (6042 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3PowerConverterDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Convertidor alimentación degradado (6043 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3PowerConverterFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Convertidor alimentación fallido (6044 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3PowerConverterRedundancyLost',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Convertidor alimentación fallido (6045 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3CacheAccelParityError',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo de paridad en caché (6046 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeResilientMemOnlineSpareEngaged',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo memoria física (6047 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe4FltTolPowerSupplyOk',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Alimentación redundante normalizada (6048 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe4FltTolPowerSupplyDegraded',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Alimentación redundante degradada (6049 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe4FltTolPowerSupplyFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Alimentación redundante fallida (6050 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeResilientMemMirroredMemoryEngaged',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo memoria física (6051 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeResilientAdvancedECCMemoryEngaged',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo memoria física (6052 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeResilientMemXorMemoryEngaged',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo memoria física (6053 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3FltTolPowerRedundancyRestored',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Alimentación redundante normalizada (6054 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe3FltTolFanRedundancyRestored',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Ventilación redundante normalizada (6055 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHe4CorrMemReplaceMemModule',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo memoria física (6056 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeResMemBoardRemoved',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Memoria física retirada (6057 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeResMemBoardInserted',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Memoria física insertada (6058 in CPQHLTH.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQHLTH-MIB::cpqHeResMemBoardBusError',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo memoria física (6059 in CPQHLTH.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '4', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDaLogDrvStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco lógico (1 in  CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaLogDrvStatus',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDaSpareStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco spare (2 in  CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaSpareStatus;cpqDaSpareBusNumber',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDaPhyDrvStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco físico (3 in  CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaPhyDrvStatus;cpqDaPhyDrvBusNumber',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDaPhyDrvThreshPassedTrap',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Disco físico degradado (4 in  CPQIDA.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaPhyDrvThreshPassed;cpqDaPhyDrvBusNumber',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDaAccelStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado aceleradora discos (5 in  CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaAccelStatus',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDaAccelBadDataTrap',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo aceleradora discos (6 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaAccelBadData',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDaAccelBatteryFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo batería aceleradora discos (7 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaAccelBattery',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa2LogDrvStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco lógico (3001 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaLogDrvStatus',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa3SpareStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco spare (3009 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaSpareStatus;cpqDaSpareBusNumber',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa2SpareStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco spare (3002 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaSpareStatus;cpqDaSpareBusNumber',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa2PhyDrvStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco físico (3003  in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaPhyDrvStatus;cpqDaPhyDrvBusNumber',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa2PhyDrvThreshPassedTrap',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Disco físico degradado (3004  in CPQIDA.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaPhyDrvThreshPassed;cpqDaPhyDrvBusNumber',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa2AccelStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado aceleradora discos (3005 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaAccelStatus',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa2AccelBadDataTrap',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo aceleradora discos (3006 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaAccelBadData',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa2AccelBatteryFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo batería aceleradora discos (3007 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'cpqDaAccelBattery',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa3LogDrvStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco lógico (3008 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaLogDrvStatus',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa3PhyDrvStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco físico (3010 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaPhyDrvStatus;cpqDaPhyDrvBusNumber',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa3PhyDrvThreshPassedTrap',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Disco físico degradado (3011 in CPQIDA.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaPhyDrvThreshPassed;cpqDaPhyDrvBusNumber',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa3AccelStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado aceleradora discos (3012 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaAccelStatus',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa3AccelBadDataTrap',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo aceleradora discos (3013 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaAccelBadData',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa3AccelBatteryFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo batería aceleradora discos (3014 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaAccelBattery',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDaCntlrStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado controladora discos (3015 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrSlot;cpqDaCntlrBoardStatus',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDaCntlrActive',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Controladora discos activa (3016 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrSlot;cpqDaCntlrPartnerSlot',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa4SpareStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco spare (3017 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaSpareStatus;cpqDaSpareCntlrIndex;cpqDaSpareBusNumber;cpqDaSpareBay',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa4PhyDrvStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco físico (3018 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaPhyDrvStatus;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvBusNumber;cpqDaPhyDrvBay',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa4PhyDrvThreshPassedTrap',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Disco físico degradado (3019 in CPQIDA.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvBusNumber;cpqDaPhyDrvBay',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa5AccelStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado aceleradora discos (3025 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrSlot;cpqDaCntlrModel;cpqDaAccelSerialNumber;cpqDaAccelTotalMemory;cpqDaAccelStatus;cpqDaAccelErrCode',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa5AccelBadDataTrap',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo aceleradora discos (3026 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrSlot;cpqDaCntlrModel;cpqDaAccelSerialNumber;cpqDaAccelTotalMemory',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa5AccelBatteryFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo batería aceleradora discos (3027 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrSlot;cpqDaCntlrModel;cpqDaAccelSerialNumber;cpqDaAccelTotalMemory',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa5CntlrStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado controladora discos (3028 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrSlot;cpqDaCntlrBoardStatus;cpqDaCntlrModel;cpqDaCntlrSerialNumber;cpqDaCntlrFWRev;cpqDaAccelTotalMemory',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa5PhyDrvStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco físico (3029 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaPhyDrvStatus;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvBusNumber;cpqDaPhyDrvBay;cpqDaPhyDrvModel;cpqDaPhyDrvFWRev;cpqDaPhyDrvSerialNum;cpqDaPhyDrvFailureCode',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa5PhyDrvThreshPassedTrap',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Disco físico degradado (3030 in CPQIDA.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvBusNumber;cpqDaPhyDrvBay;cpqDaPhyDrvModel;cpqDaPhyDrvFWRev;cpqDaPhyDrvSerialNum',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa6CntlrStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado controladora discos (3033 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaCntlrIndex;cpqDaCntlrBoardStatus;cpqDaCntlrModel;cpqDaCntlrSerialNumber;cpqDaCntlrFWRev;cpqDaAccelTotalMemory',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa6LogDrvStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco lógico (3034 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaLogDrvCntlrIndex;cpqDaLogDrvIndex;cpqDaLogDrvStatus',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa6SpareStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco spare (3035 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaSpareCntlrIndex;cpqDaSparePhyDrvIndex;cpqDaSpareStatus;cpqDaSpareBusNumber;cpqDaSpareBay',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa6PhyDrvStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco físico (3036 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvIndex;cpqDaPhyDrvBusNumber;cpqDaPhyDrvBay;cpqDaPhyDrvModel;cpqDaPhyDrvFWRev;cpqDaPhyDrvSerialNum;cpqDaPhyDrvFailureCode;cpqDaPhyDrvStatus',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa6PhyDrvThreshPassedTrap',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Disco físico degradado (3037 in CPQIDA.MIB). CRITICO',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvIndex;cpqDaPhyDrvBusNumber;cpqDaPhyDrvBay;cpqDaPhyDrvModel;cpqDaPhyDrvFWRev;cpqDaPhyDrvSerialNum',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa6AccelStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado aceleradora discos (3038 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaCntlrModel;cpqDaAccelCntlrIndex;cpqDaAccelSerialNumber;cpqDaAccelTotalMemory;cpqDaAccelStatus;cpqDaAccelErrCode',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa6AccelBadDataTrap',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo aceleradora discos (3039 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaCntlrModel;cpqDaAccelCntlrIndex;cpqDaAccelSerialNumber;cpqDaAccelTotalMemory',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa6AccelBatteryFailed',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Fallo batería aceleradora discos (3040 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaCntlrModel;cpqDaAccelCntlrIndex;cpqDaAccelSerialNumber;cpqDaAccelTotalMemory',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa7PhyDrvStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco físico (3046 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvIndex;cpqDaPhyDrvLocationString;cpqDaPhyDrvType;cpqDaPhyDrvModel;cpqDaPhyDrvFWRev;cpqDaPhyDrvSerialNum;cpqDaPhyDrvFailureCode;cpqDaPhyDrvStatus;cpqDaPhyDrvBusNumber',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'CPQIDA-MIB::cpqDa7SpareStatusChange',      'hiid' => 'ea1c3c284d',
      'descr' => 'HP TRAP: Cambio estado disco spare (3047 in CPQIDA.MIB)',    'mode'=>'INC',    'expr'=>'AND',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaSpareCntlrIndex;cpqDaSparePhyDrvIndex;cpqDaSpareStatus;cpqDaSpareLocationString;cpqDaSpareBusNumber',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.232',
      'apptype' => 'HW.HP', 'itil_type' => '1', 'class'=>'COMPAQ', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH',  'expr'=>'')
      )
   );


?>
