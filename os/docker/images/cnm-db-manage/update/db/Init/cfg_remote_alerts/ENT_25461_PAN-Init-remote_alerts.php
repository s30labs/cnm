<?php

   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panThreatTrap',      'hiid' => '8fd3cae694',
      'descr' => 'EVENTO MALICIOSO',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panTimeGenerated;panSource;panDestination;panNatSource;panNatDestination;panRule;panSrcUser;panDstUser;panApplication;panVsys;panSourceZone;panDestinationZone;panIngressInterface;panEgressInterface;panLogForwardingProfile;panSessionID;panRepeatCount;panSourcePort;panDestinationPort;panNatSourcePort;panNatDestinationPort;panFlags;panProtocol;panAction;panMiscellaneous;panThreatId;panThreatCategory;panThreatSeverity;panThreatDirection;panSeqno;panActionflags;panSrcloc;panDstloc;panThreatContentType',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panTimeGenerated', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSource', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panDestination', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panNatSource', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panNatDestination', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panRule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v11', 'descr'=>'panSrcUser', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v12', 'descr'=>'panDstUser', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v13', 'descr'=>'panApplication', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v14', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v15', 'descr'=>'panSourceZone', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v16', 'descr'=>'panDestinationZone', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v17', 'descr'=>'panIngressInterface', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v18', 'descr'=>'panEgressInterface', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v19', 'descr'=>'panLogForwardingProfile', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v20', 'descr'=>'panSessionID', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v21', 'descr'=>'panRepeatCount', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v22', 'descr'=>'panSourcePort', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v23', 'descr'=>'panDestinationPort', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v24', 'descr'=>'panNatSourcePort', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v25', 'descr'=>'panNatDestinationPort', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v26', 'descr'=>'panFlags', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v27', 'descr'=>'panProtocol', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v28', 'descr'=>'panAction', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v29', 'descr'=>'panMiscellaneous', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v30', 'descr'=>'panThreatId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v31', 'descr'=>'panThreatCategory', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v32', 'descr'=>'panThreatSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v33', 'descr'=>'panThreatDirection', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v34', 'descr'=>'panSeqno', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v35', 'descr'=>'panActionflags', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v36', 'descr'=>'panSrcloc', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v37', 'descr'=>'panDstloc', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v38', 'descr'=>'panThreatContentType', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panGeneralGeneralTrap',      'hiid' => '882e4272e5',
      'descr' => 'EVENTO IMPORTANTE DEL SISTEMA',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'>=',  'expr'=>'5'),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panGeneralGeneralTrap',      'hiid' => '37fadeef61',
      'descr' => 'EVENTO DEL SISTEMA',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'<',  'expr'=>'5'),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panGeneralSystemShutdownTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'CAIDA DEL SISTEMA',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHWDiskErrorsTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'PROBLEMA FISICO EN DISCO',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAHa1LinkChangeTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - CAMBIO EN LINK HA1 DE PEER',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAHa2LinkChangeTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - CAMBIO EN LINK HA2 DE PEER',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHADataplaneDownTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - CAIDA EN DATAPLANE',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAPolicyPushFailTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - ERROR AL VOLCAR POLITICA',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAConnectChangeTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - CAMBIO EN CONEXION A PEER',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAPathMonitorDownTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - CAIDA EN PATH MONITORIZADO',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHALinkMonitorDownTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - CAIDA EN ENLACE MONITORIZADO',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAPeerSyncFailureTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - ERROR EN SINCRONIZACION DE DATOS',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAConfigFailureTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - ERROR DE CONFIGURACION CON PEER',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAPeerErrorTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - ERROR DEL PEER',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAPeerVersionUnsupportedTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - VERSION EN PEER NO SOPORTADA',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAPeerVersionDegradedTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - VERSION EN PEER DEGRADADA',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAPeerCompatMismatchTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - DIFERENCIAS DE COMPATIBILIDAD',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAPeerCompatFailTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - ERROR DE COMPATIBILIDAD',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAPeerShutdownTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - CAIDA DEL SISTEMA',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHANfsPanlogsFailTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - FALLO EN NFS PANLOGS',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAInternalHaErrorTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - ERROR INTERNO',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '1',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHAStateChangeTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - CAMBIO DE ESTADO',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );



   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',     'subtype' => 'PAN-TRAPS::panHANonFunctionalLoopTrap',      'hiid' => 'dbf05f6816',
      'descr' => 'HA - BUCLE NO FUNCIONAL',    'mode'=>'NEW',    'expr'=>'AND',
		'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'monitor' => '',     'vdata' => '', 'severity' => '2',   'action' => 'SET',   'script' => '', 'enterprise' => 'ent.25461',
      'apptype' => 'NET.PALO_ALTO', 'itil_type' => '1', 'class'=>'PALO ALTO', 'include'=>'1',
		
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
				array('v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH',  'expr'=>''),
array('v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH',  'expr'=>'')
      )
   );


?>
