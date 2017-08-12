#---------------------------------------------------------------------------
package ENT_09694_ARBOR;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_09694_ARBOR::ENTERPRISE_PREFIX='09694';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_09694_ARBOR::TABLE_APPS =(

);

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO GET
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_09694_ARBOR::GET_APPS =(

#   {  'name'=> 'USO DE SESIONES',      'oid'=>'PAN-COMMON-MIB::panSessionUtilization.0', 'subtype'=>'pan_ses_usage', 'class'=>'PAN-COMMON-MIB', 'include'=>'0', 'itil_type' => 1, 'apptype'=>'NET.PALO_ALTO' },
#   { 'name'=> 'SESIONES ACTIVAS',  'oid'=>'PAN-COMMON-MIB::panSessionActive.0|PAN-COMMON-MIB::panSessionActiveTcp.0|PAN-COMMON-MIB::panSessionActiveUdp.0|PAN-COMMON-MIB::panSessionActiveICMP.0', 'subtype'=>'pan_ses_active', 'class'=>'NET.PALO_ALTO'},


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_09694_ARBOR::METRICS=(


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_09694_ARBOR::METRICS_TAB=(

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_09694_ARBOR::REMOTE_ALERTS=(


#subHostDown         NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::subHostDown', 'class'=>'ARBOR NETW',
      'descr'=>'CAIDA DE SUBHOST', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapSubhostName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapSubhostName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailProtectionGroupError          NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailProtectionGroupError', 'class'=>'ARBOR NETW',
      'descr'=>'ERROR EN GRUPO DE PROTECCION', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailProtectionGroupId;pravailProtectionGroupName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailProtectionGroupId', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'pravailProtectionGroupName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },


#pravailConfigMissing        NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailConfigMissing', 'class'=>'ARBOR NETW',
      'descr'=>'EQUIPO SIN CONFIGURACION', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailConfigError          NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailConfigError', 'class'=>'ARBOR NETW',
      'descr'=>'ERROR DE CONFIGURACION', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailHwDeviceDown  NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailHwDeviceDown', 'class'=>'ARBOR NETW',
      'descr'=>'DISPOSITVO HARDWARE CAIDO', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailHwSensorCritical NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailHwSensorCritical', 'class'=>'ARBOR NETW',
      'descr'=>'SENSOR HARDWARE EN ESTADO CRITICO', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailSwComponentDown  NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailSwComponentDown', 'class'=>'ARBOR NETW',
      'descr'=>'PROCESO SOFTWARE CAIDO', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapSubhostName;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapSubhostName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailSystemStatusCritical NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailSystemStatusCritical', 'class'=>'ARBOR NETW',
      'descr'=>'SISTEMA EN ESTADO CRITICO', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailSystemStatusDegraded NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailSystemStatusDegraded', 'class'=>'ARBOR NETW',
      'descr'=>'SISTEMA DEGRADADO', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailFilesystemCritical NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailFilesystemCritical', 'class'=>'ARBOR NETW',
      'descr'=>'SISTEMA DE FICHEROS LLENO', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailGRETunnelFailure NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailGRETunnelFailure', 'class'=>'ARBOR NETW',
      'descr'=>'ERROR EN TUNEL GRE', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailNextHopUnreachable NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailNextHopUnreachable', 'class'=>'ARBOR NETW',
      'descr'=>'NO SE ALCANZA NEXT HOP', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailPerformance NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailPerformance', 'class'=>'ARBOR NETW',
      'descr'=>'SISTEMA DEGRADADO', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailSystemStatusError NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailSystemStatusError', 'class'=>'ARBOR NETW',
      'descr'=>'ERROR DE ESTADO', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailCloudSignalTimeout NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailCloudSignalTimeout', 'class'=>'ARBOR NETW',
      'descr'=>'TIMEOUT EN ACCESO A SERVICIOS EN LA NUBE', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailCloudSignalThreshold NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailCloudSignalThreshold', 'class'=>'ARBOR NETW',
      'descr'=>'ERRROR EN ACCESO A SERVICIOS EN LA NUBE', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrapComponentName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailDeploymentModeChange NOTIFICATION-TYPE
#pravailProtectionLevelChange NOTIFICATION-TYPE
#pravailTrapBlockHostDetail NOTIFICATION-TYPE
#pravailTrapBlockHostSummary NOTIFICATION-TYPE

#pravailTrapTraffic NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailTrapTraffic', 'class'=>'ARBOR NETW',
      'descr'=>'EXCESO DE TRAFICO EN GRUPO DE PROTECCION', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrafficLevel', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'pravailTrafficUnits', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'pravailProtectionGroupName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'pravailURL', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },
	

#pravailTrapBotnetAttack NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailTrapBotnetAttack', 'class'=>'ARBOR NETW',
      'descr'=>'ATAQUE DE BOTNET', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrafficLevel', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'pravailTrafficUnits', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'pravailProtectionGroupName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'pravailURL', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },
   

#pravailTrapLicenseLimit NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailTrapLicenseLimit', 'class'=>'ARBOR NETW',
      'descr'=>'EXCEDIDO EL LIMITE DE LICENCIAS', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailURL',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailURL', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },

#pravailTrapBlockedTraffic NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'PRAVAIL-MIB::pravailTrapBlockedTraffic', 'class'=>'ARBOR NETW',
      'descr'=>'EL TRAFICO BLOQUEADO SUPERA EL UMBRAL DEL GRUPO DE PROTECCION', 'severity'=>'2', 'enterprise'=>'ent.9694',
      'vardata' =>'sysName;pravailTrapString;pravailTrapDetail;pravailTrapComponentName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'sysName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'pravailTrapString', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'pravailTrapDetail', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'pravailTrafficLevel', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'pravailTrafficUnits', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v6', 'descr'=>'pravailProtectionGroupName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v7', 'descr'=>'pravailURL', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.ARBOR', 'itil_type'=>'1'  },
   

#pravailProtectionGroupLevelChange NOTIFICATION-TYPE
#pravailProtectionGroupModeChange NOTIFICATION-TYPE


);


1;
__END__
