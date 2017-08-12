#---------------------------------------------------------------------------
package ENT_25461_PAN;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_25461_PAN::ENTERPRISE_PREFIX='34225';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_25461_PAN::TABLE_APPS =(

);

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO GET
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_25461_PAN::GET_APPS =(

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_25461_PAN::METRICS=(

   {  'name'=> 'USO DE SESIONES',      'oid'=>'PAN-COMMON-MIB::panSessionUtilization.0', 'subtype'=>'pan_ses_usage', 'class'=>'PAN-COMMON-MIB', 'include'=>'1', 'itil_type' => 1, 'apptype'=>'NET.PALO_ALTO' },
   { 'name'=> 'SESIONES ACTIVAS',  'oid'=>'PAN-COMMON-MIB::panSessionActive.0|PAN-COMMON-MIB::panSessionActiveTcp.0|PAN-COMMON-MIB::panSessionActiveUdp.0|PAN-COMMON-MIB::panSessionActiveICMP.0', 'subtype'=>'pan_ses_active', 'class'=>'PAN-COMMON-MIB', 'include'=>'1', 'itil_type' => 1, 'apptype'=>'NET.PALO_ALTO' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_25461_PAN::METRICS_TAB=(

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_25461_PAN::REMOTE_ALERTS=(

#panThreatTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panThreatTrap', 'class'=>'PALO ALTO',
      'descr'=>'EVENTO MALICIOSO', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panTimeGenerated;panSource;panDestination;panNatSource;panNatDestination;panRule;panSrcUser;panDstUser;panApplication;panVsys;panSourceZone;panDestinationZone;panIngressInterface;panEgressInterface;panLogForwardingProfile;panSessionID;panRepeatCount;panSourcePort;panDestinationPort;panNatSourcePort;panNatDestinationPort;panFlags;panProtocol;panAction;panMiscellaneous;panThreatId;panThreatCategory;panThreatSeverity;panThreatDirection;panSeqno;panActionflags;panSrcloc;panDstloc;panThreatContentType',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v5', 'descr'=>'panTimeGenerated', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v6', 'descr'=>'panSource', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v7', 'descr'=>'panDestination', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v8', 'descr'=>'panNatSource', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v9', 'descr'=>'panNatDestination', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v10', 'descr'=>'panRule', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v11', 'descr'=>'panSrcUser', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v12', 'descr'=>'panDstUser', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v13', 'descr'=>'panApplication', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v14', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v15', 'descr'=>'panSourceZone', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v16', 'descr'=>'panDestinationZone', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v17', 'descr'=>'panIngressInterface', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v18', 'descr'=>'panEgressInterface', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v19', 'descr'=>'panLogForwardingProfile', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v20', 'descr'=>'panSessionID', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v21', 'descr'=>'panRepeatCount', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v22', 'descr'=>'panSourcePort', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v23', 'descr'=>'panDestinationPort', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v24', 'descr'=>'panNatSourcePort', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v25', 'descr'=>'panNatDestinationPort', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v26', 'descr'=>'panFlags', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v27', 'descr'=>'panProtocol', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v28', 'descr'=>'panAction', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v29', 'descr'=>'panMiscellaneous', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v30', 'descr'=>'panThreatId', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v31', 'descr'=>'panThreatCategory', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v32', 'descr'=>'panThreatSeverity', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v33', 'descr'=>'panThreatDirection', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v34', 'descr'=>'panSeqno', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v35', 'descr'=>'panActionflags', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v36', 'descr'=>'panSrcloc', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v37', 'descr'=>'panDstloc', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v38', 'descr'=>'panThreatContentType', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#	   panReceiveTime                 1.3.6.1.4.1.25461.2.1.3.1.2    TimeStamp                      
#	   panSerial                      1.3.6.1.4.1.25461.2.1.3.1.3    OCTET STRING                   
#	   panEventType                   1.3.6.1.4.1.25461.2.1.3.1.4    OCTET STRING                   
#	   panEventSubType                1.3.6.1.4.1.25461.2.1.3.1.5    OCTET STRING                   
#	   panTimeGenerated               1.3.6.1.4.1.25461.2.1.3.1.72   TimeStamp                      
#	   panSource                      1.3.6.1.4.1.25461.2.1.3.1.50   IpAddress                      
#	   panDestination                 1.3.6.1.4.1.25461.2.1.3.1.51   IpAddress                      
#	   panNatSource                   1.3.6.1.4.1.25461.2.1.3.1.52   IpAddress                      
#	   panNatDestination              1.3.6.1.4.1.25461.2.1.3.1.53   IpAddress                      
#	   panRule                        1.3.6.1.4.1.25461.2.1.3.1.54   OCTET STRING                   
#	   panSrcUser                     1.3.6.1.4.1.25461.2.1.3.1.55   OCTET STRING                   
#	   panDstUser                     1.3.6.1.4.1.25461.2.1.3.1.56   OCTET STRING                   
#	   panApplication                 1.3.6.1.4.1.25461.2.1.3.1.57   OCTET STRING                   
#	   panVsys                        1.3.6.1.4.1.25461.2.1.3.1.7    OCTET STRING                   
#	   panSourceZone                  1.3.6.1.4.1.25461.2.1.3.1.58   OCTET STRING                   
#	   panDestinationZone             1.3.6.1.4.1.25461.2.1.3.1.59   OCTET STRING                   
#	   panIngressInterface            1.3.6.1.4.1.25461.2.1.3.1.60   Counter64                      
#	   panEgressInterface             1.3.6.1.4.1.25461.2.1.3.1.61   Counter64                      
#	   panLogForwardingProfile        1.3.6.1.4.1.25461.2.1.3.1.62   OCTET STRING                   
#	   panSessionID                   1.3.6.1.4.1.25461.2.1.3.1.63   Counter32                      
#	   panRepeatCount                 1.3.6.1.4.1.25461.2.1.3.1.64   Counter32                      
#	   panSourcePort                  1.3.6.1.4.1.25461.2.1.3.1.65   Counter32                      
#	   panDestinationPort             1.3.6.1.4.1.25461.2.1.3.1.66   Counter32                      
#	   panNatSourcePort               1.3.6.1.4.1.25461.2.1.3.1.67   Counter32                      
#	   panNatDestinationPort          1.3.6.1.4.1.25461.2.1.3.1.68   Counter32                      
#	   panFlags                       1.3.6.1.4.1.25461.2.1.3.1.69   Counter32                      
#	   panProtocol                    1.3.6.1.4.1.25461.2.1.3.1.70   Counter32                      
#	   panAction                      1.3.6.1.4.1.25461.2.1.3.1.71   Counter32                      
#	   panMiscellaneous               1.3.6.1.4.1.25461.2.1.3.1.205  OCTET STRING                   
#	   panThreatId                    1.3.6.1.4.1.25461.2.1.3.1.200  Counter32                      
#	   panThreatCategory              1.3.6.1.4.1.25461.2.1.3.1.201  OCTET STRING                   
#	   panThreatSeverity              1.3.6.1.4.1.25461.2.1.3.1.203  INTEGER                        
#		{
#		   unused(1)
#		   informational(2)
#		   low(3)
#		   medium(4)
#		   high(5)
#		   critical(6)
#		}
#	   panThreatDirection             1.3.6.1.4.1.25461.2.1.3.1.204  Counter32                      
#	   panSeqno                       1.3.6.1.4.1.25461.2.1.3.1.8    Counter64                      
#	   panActionflags                 1.3.6.1.4.1.25461.2.1.3.1.9    Counter64                      
#	   panSrcloc                      1.3.6.1.4.1.25461.2.1.3.1.73   OCTET STRING                   
#	   panDstloc                      1.3.6.1.4.1.25461.2.1.3.1.74   OCTET STRING                   
#	   panThreatContentType           1.3.6.1.4.1.25461.2.1.3.1.202  OCTET STRING                   


#panGeneralGeneralTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panGeneralGeneralTrap', 'class'=>'PALO ALTO',
      'descr'=>'EVENTO IMPORTANTE DEL SISTEMA', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'>=', 'expr'=>'5'},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panGeneralGeneralTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panGeneralGeneralTrap', 'class'=>'PALO ALTO',
      'descr'=>'EVENTO DEL SISTEMA', 'severity'=>'3', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'<', 'expr'=>'5'},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#	   panReceiveTime                 1.3.6.1.4.1.25461.2.1.3.1.2    TimeStamp                      
#	   panSerial                      1.3.6.1.4.1.25461.2.1.3.1.3    OCTET STRING                   
#	   panEventType                   1.3.6.1.4.1.25461.2.1.3.1.4    OCTET STRING                   
#	   panEventSubType                1.3.6.1.4.1.25461.2.1.3.1.5    OCTET STRING                   
#	   panVsys                        1.3.6.1.4.1.25461.2.1.3.1.7    OCTET STRING                   
#	   panSystemEventId               1.3.6.1.4.1.25461.2.1.3.1.300  Counter32                      
#	   panSystemObject                1.3.6.1.4.1.25461.2.1.3.1.301  OCTET STRING                   
#	   panSystemModule                1.3.6.1.4.1.25461.2.1.3.1.302  Counter32                      
#	   panSystemSeverity              1.3.6.1.4.1.25461.2.1.3.1.303  INTEGER                        
#		{
#		   unused(1)
#		   informational(2)
#		   low(3)
#		   medium(4)
#		   high(5)
#		   critical(6)
#		}
#	   panSystemDescription           1.3.6.1.4.1.25461.2.1.3.1.304  OCTET STRING                   



#panGeneralSystemShutdownTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panGeneralSystemShutdownTrap', 'class'=>'PALO ALTO',
      'descr'=>'CAIDA DEL SISTEMA', 'severity'=>'1', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },


#panHWDiskErrorsTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHWDiskErrorsTrap', 'class'=>'PALO ALTO',
      'descr'=>'PROBLEMA FISICO EN DISCO', 'severity'=>'1', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAHa1LinkChangeTrap NOTIFICATION-TYPE
#panHAHa2LinkChangeTrap NOTIFICATION-TYPE
#panHADataplaneDownTrap NOTIFICATION-TYPE
#panHAPolicyPushFailTrap NOTIFICATION-TYPE
#panHAConnectChangeTrap NOTIFICATION-TYPE
#panHAPathMonitorDownTrap NOTIFICATION-TYPE
#panHALinkMonitorDownTrap NOTIFICATION-TYPE
#panHAPeerSyncFailureTrap NOTIFICATION-TYPE
#panHAConfigFailureTrap NOTIFICATION-TYPE
#panHAPeerErrorTrap NOTIFICATION-TYPE
#panHAPeerVersionUnsupportedTrap NOTIFICATION-TYPE
#panHAPeerVersionDegradedTrap NOTIFICATION-TYPE
#panHAPeerCompatMismatchTrap NOTIFICATION-TYPE
#panHAPeerCompatFailTrap NOTIFICATION-TYPE
#panHAPeerShutdownTrap NOTIFICATION-TYPE
#panHANfsPanlogsFailTrap NOTIFICATION-TYPE
#panHAInternalHaErrorTrap NOTIFICATION-TYPE
#panHAStateChangeTrap NOTIFICATION-TYPE
#panHANonFunctionalLoopTrap

#panHAHa1LinkChangeTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAHa1LinkChangeTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - CAMBIO EN LINK HA1 DE PEER', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAHa2LinkChangeTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAHa2LinkChangeTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - CAMBIO EN LINK HA2 DE PEER', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHADataplaneDownTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHADataplaneDownTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - CAIDA EN DATAPLANE', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAPolicyPushFailTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAPolicyPushFailTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - ERROR AL VOLCAR POLITICA', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAConnectChangeTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAConnectChangeTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - CAMBIO EN CONEXION A PEER', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAPathMonitorDownTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAPathMonitorDownTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - CAIDA EN PATH MONITORIZADO', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHALinkMonitorDownTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHALinkMonitorDownTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - CAIDA EN ENLACE MONITORIZADO', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAPeerSyncFailureTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAPeerSyncFailureTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - ERROR EN SINCRONIZACION DE DATOS', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAConfigFailureTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAConfigFailureTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - ERROR DE CONFIGURACION CON PEER', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAPeerErrorTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAPeerErrorTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - ERROR DEL PEER', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAPeerVersionUnsupportedTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAPeerVersionUnsupportedTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - VERSION EN PEER NO SOPORTADA', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAPeerVersionDegradedTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAPeerVersionDegradedTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - VERSION EN PEER DEGRADADA', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAPeerCompatMismatchTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAPeerCompatMismatchTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - DIFERENCIAS DE COMPATIBILIDAD', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAPeerCompatFailTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAPeerCompatFailTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - ERROR DE COMPATIBILIDAD', 'severity'=>'3', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAPeerShutdownTrap NOTIFICATION-TRYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAPeerShutdownTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - CAIDA DEL SISTEMA', 'severity'=>'1', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHANfsPanlogsFailTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHANfsPanlogsFailTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - FALLO EN NFS PANLOGS', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAInternalHaErrorTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAInternalHaErrorTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - ERROR INTERNO', 'severity'=>'1', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHAStateChangeTrap NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHAStateChangeTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - CAMBIO DE ESTADO', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },

#panHANonFunctionalLoopTrap
   {  'type'=>'snmp', 'subtype'=>'PAN-TRAPS::panHANonFunctionalLoopTrap', 'class'=>'PALO ALTO',
      'descr'=>'HA - BUCLE NO FUNCIONAL', 'severity'=>'2', 'enterprise'=>'ent.25461',
      'vardata' =>'panReceiveTime;panSerial;panEventType;panEventSubType;panVsys;panSystemEventId;panSystemObject;panSystemModule;panSystemSeverity;panSystemDescription',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'panReceiveTime', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'panSerial', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'panEventType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'panEventSubType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'panVsys', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'panSystemEventId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'panSystemObject', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v8', 'descr'=>'panSystemModule', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v9', 'descr'=>'panSystemSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v10', 'descr'=>'panSystemDescription', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.PALO_ALTO', 'itil_type'=>'1'  },



);


1;
__END__
