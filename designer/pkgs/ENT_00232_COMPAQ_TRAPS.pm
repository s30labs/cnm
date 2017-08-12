#---------------------------------------------------------------------------
package ENT_00232_COMPAQ_TRAPS;
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_00232_COMPAQ_TRAPS::ENTERPRISE_PREFIX='00232';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
# Opciones de filtrado: 
# 		#text_filter, #select_filter, #select_filter_strict, #numeric_filter
#---------------------------------------------------------------------------
%ENT_00232_COMPAQ_TRAPS::TABLE_APPS =(

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00232_COMPAQ_TRAPS::METRICS=(

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00232_COMPAQ_TRAPS::METRICS_TAB=(


);


#---------------------------------------------------------------------------
#select descr,subtype,severity,mode,action from cfg_remote_alerts where subtype like '232%';
#Son traps v1
#---------------------------------------------------------------------------
@ENT_00232_COMPAQ_TRAPS::REMOTE_ALERTS=(


#CPQCLUSTER-MIB
   {  'type'=>'snmp', 'subtype'=>'CPQCLUSTER-MIB::cpqClusterNodeDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Nodo cluster degradado (15003  in CPQCLUS.MIB)', 'severity'=>'3',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterNodeName', 'enterprise'=>'ent.232',
      'remote2expr'=>[ 	{'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQCLUSTER-MIB::cpqClusterFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cluster fallido (15002 in CPQCLUS.MIB). CRITICO', 'severity'=>'1',
		'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterName', 'enterprise'=>'ent.232',
      'remote2expr'=>[ 	{'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQCLUSTER-MIB::cpqClusterDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cluster degradado (15001 in CPQCLUS.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterName', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQCLUSTER-MIB::cpqClusterNodeFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Nodo cluster fallido (15004 in CPQCLUS.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterNodeName', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQCLUSTER-MIB::cpqClusterResourceDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Recurso cluster degradado (15005 in CPQCLUS.MIB)', 'severity'=>'3',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterResourceName', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQCLUSTER-MIB::cpqClusterResourceFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP:  Recurso cluster fallido (15006 in CPQCLUS.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterResourceName', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQCLUSTER-MIB::cpqClusterNetworkDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Red cluster degradada (15007 in CPQCLUS.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqClusterNetworkName', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },




#CPQHLTH-MIB
   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeThermalTempFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Temperatura fallida (6003 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeThermalTempDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Temperatura degradada (6004 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'cpqHeThermalDegradedAction', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeThermalTempOk', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Temperatura normalizada (6005 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeThermalSystemFanFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilador sistema fallido (6006 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeThermalSystemFanDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilador sistema degradado (6007 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeThermalSystemFanOk', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilador sistema normalizado (6008 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeThermalCpuFanFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilador CPU fallido (6009 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeThermalCpuFanOk', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilador CPU normalizado (6010 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHePostError', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Errores ocurridos durante arranque (6013 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeFltTolPwrSupplyDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Alimentación redundante degradada (6014 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3ThermalTempFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Temperatura fallida (6017 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3ThermalTempDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Temperatura degradada (6018 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3ThermalTempOk', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Temperatura normalizada (6019 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3ThermalSystemFanFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilador sistema fallido (6020 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3ThermalSystemFanDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilador sistema degradado (6021 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3ThermalSystemFanOk', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilador sistema normalizado (6022 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3ThermalCpuFanFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilador CPU fallido (6023 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3ThermalCpuFanOk', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilador CPU normalizado (6024 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3PostError', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Errores ocurridos durante arranque (6027 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3FltTolPwrSupplyDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Alimentación redundante degradada (6028 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3FltTolPowerSupplyDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Alimentación redundante degradada (6030 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3FltTolPowerSupplyFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Alimentación redundante fallida (6031 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3FltTolPowerRedundancyLost', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Alimentación redundante fallida (6032 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3FltTolPowerSupplyInserted', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fuente de alimentación insertada (6033 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3FltTolPowerSupplyRemoved', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fuente de alimentación retirada (6034 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3FltTolFanDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilación redundante degradada (6035 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3FltTolFanFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilación redundante fallida (6036 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3FltTolFanRedundancyLost', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilación redundante fallida (6037 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3FltTolFanInserted', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilación redundante insertada (6038 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3FltTolFanRemoved', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilación redundante retirada (6039 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3TemperatureFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Temperatura fallida (6040 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3TemperatureDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Temperatura degradada (6041 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3TemperatureOk', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Temperatura normalizada (6042 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3PowerConverterDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Convertidor alimentación degradado (6043 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3PowerConverterFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Convertidor alimentación fallido (6044 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3PowerConverterRedundancyLost', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Convertidor alimentación fallido (6045 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3CacheAccelParityError', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo de paridad en caché (6046 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeResilientMemOnlineSpareEngaged', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo memoria física (6047 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe4FltTolPowerSupplyOk', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Alimentación redundante normalizada (6048 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe4FltTolPowerSupplyDegraded', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Alimentación redundante degradada (6049 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe4FltTolPowerSupplyFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Alimentación redundante fallida (6050 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeResilientMemMirroredMemoryEngaged', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo memoria física (6051 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeResilientAdvancedECCMemoryEngaged', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo memoria física (6052 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeResilientMemXorMemoryEngaged', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo memoria física (6053 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3FltTolPowerRedundancyRestored', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Alimentación redundante normalizada (6054 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe3FltTolFanRedundancyRestored', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Ventilación redundante normalizada (6055 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHe4CorrMemReplaceMemModule', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo memoria física (6056 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeResMemBoardRemoved', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Memoria física retirada (6057 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeResMemBoardInserted', 'class'=>'COMPAQ',

      'descr'=>'HP TRAP: Memoria física insertada (6058 in CPQHLTH.MIB)', 'severity'=>'3',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },

   {  'type'=>'snmp', 'subtype'=>'CPQHLTH-MIB::cpqHeResMemBoardBusError', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo memoria física (6059 in CPQHLTH.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'4'  },


#CPQIDA-MIB
   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDaLogDrvStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco lógico (1 in  CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'cpqDaLogDrvStatus', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDaSpareStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco spare (2 in  CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'cpqDaSpareStatus;cpqDaSpareBusNumber', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDaPhyDrvStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco físico (3 in  CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'cpqDaPhyDrvStatus;cpqDaPhyDrvBusNumber', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDaPhyDrvThreshPassedTrap', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Disco físico degradado (4 in  CPQIDA.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'cpqDaPhyDrvThreshPassed;cpqDaPhyDrvBusNumber', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDaAccelStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado aceleradora discos (5 in  CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'cpqDaAccelStatus', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDaAccelBadDataTrap', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo aceleradora discos (6 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'cpqDaAccelBadData', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDaAccelBatteryFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo batería aceleradora discos (7 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'cpqDaAccelBattery', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa2LogDrvStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco lógico (3001 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'cpqDaLogDrvStatus', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa3SpareStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco spare (3009 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaSpareStatus;cpqDaSpareBusNumber', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa2SpareStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco spare (3002 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'cpqDaSpareStatus;cpqDaSpareBusNumber', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa2PhyDrvStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco físico (3003  in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'cpqDaPhyDrvStatus;cpqDaPhyDrvBusNumber', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa2PhyDrvThreshPassedTrap', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Disco físico degradado (3004  in CPQIDA.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'cpqDaPhyDrvThreshPassed;cpqDaPhyDrvBusNumber', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa2AccelStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado aceleradora discos (3005 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'cpqDaAccelStatus', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'', 
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa2AccelBadDataTrap', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo aceleradora discos (3006 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'cpqDaAccelBadData', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa2AccelBatteryFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo batería aceleradora discos (3007 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'cpqDaAccelBattery', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa3LogDrvStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco lógico (3008 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaLogDrvStatus', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa3PhyDrvStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco físico (3010 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaPhyDrvStatus;cpqDaPhyDrvBusNumber', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa3PhyDrvThreshPassedTrap', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Disco físico degradado (3011 in CPQIDA.MIB). CRITICO', 'severity'=>'1',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaPhyDrvThreshPassed;cpqDaPhyDrvBusNumber', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa3AccelStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado aceleradora discos (3012 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaAccelStatus', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa3AccelBadDataTrap', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo aceleradora discos (3013 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaAccelBadData', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa3AccelBatteryFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo batería aceleradora discos (3014 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaAccelBattery', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDaCntlrStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado controladora discos (3015 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrSlot;cpqDaCntlrBoardStatus', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDaCntlrActive', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Controladora discos activa (3016 in CPQIDA.MIB)', 'severity'=>'3',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrSlot;cpqDaCntlrPartnerSlot', 'enterprise'=>'ent.232',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa4SpareStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco spare (3017 in CPQIDA.MIB)', 'severity'=>'3', 'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaSpareStatus;cpqDaSpareCntlrIndex;cpqDaSpareBusNumber;cpqDaSpareBay',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa4PhyDrvStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco físico (3018 in CPQIDA.MIB)', 'severity'=>'3',  'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaPhyDrvStatus;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvBusNumber;cpqDaPhyDrvBay',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa4PhyDrvThreshPassedTrap', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Disco físico degradado (3019 in CPQIDA.MIB). CRITICO', 'severity'=>'1', 'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvBusNumber;cpqDaPhyDrvBay',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa5AccelStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado aceleradora discos (3025 in CPQIDA.MIB)', 'severity'=>'3', 'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrSlot;cpqDaCntlrModel;cpqDaAccelSerialNumber;cpqDaAccelTotalMemory;cpqDaAccelStatus;cpqDaAccelErrCode',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'', 
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa5AccelBadDataTrap', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo aceleradora discos (3026 in CPQIDA.MIB)', 'severity'=>'3', 'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrSlot;cpqDaCntlrModel;cpqDaAccelSerialNumber;cpqDaAccelTotalMemory',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa5AccelBatteryFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo batería aceleradora discos (3027 in CPQIDA.MIB)', 'severity'=>'3',  'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrSlot;cpqDaCntlrModel;cpqDaAccelSerialNumber;cpqDaAccelTotalMemory',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa5CntlrStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado controladora discos (3028 in CPQIDA.MIB)', 'severity'=>'3', 'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrSlot;cpqDaCntlrBoardStatus;cpqDaCntlrModel;cpqDaCntlrSerialNumber;cpqDaCntlrFWRev;cpqDaAccelTotalMemory',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa5PhyDrvStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco físico (3029 in CPQIDA.MIB)', 'severity'=>'3',  'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaPhyDrvStatus;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvBusNumber;cpqDaPhyDrvBay;cpqDaPhyDrvModel;cpqDaPhyDrvFWRev;cpqDaPhyDrvSerialNum;cpqDaPhyDrvFailureCode',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa5PhyDrvThreshPassedTrap', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Disco físico degradado (3030 in CPQIDA.MIB). CRITICO', 'severity'=>'1',  'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvBusNumber;cpqDaPhyDrvBay;cpqDaPhyDrvModel;cpqDaPhyDrvFWRev;cpqDaPhyDrvSerialNum',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa6CntlrStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado controladora discos (3033 in CPQIDA.MIB)', 'severity'=>'3', 'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaCntlrIndex;cpqDaCntlrBoardStatus;cpqDaCntlrModel;cpqDaCntlrSerialNumber;cpqDaCntlrFWRev;cpqDaAccelTotalMemory',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   ,{  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa6LogDrvStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco lógico (3034 in CPQIDA.MIB)', 'severity'=>'3',  'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaLogDrvCntlrIndex;cpqDaLogDrvIndex;cpqDaLogDrvStatus',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa6SpareStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco spare (3035 in CPQIDA.MIB)', 'severity'=>'3', 'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaSpareCntlrIndex;cpqDaSparePhyDrvIndex;cpqDaSpareStatus;cpqDaSpareBusNumber;cpqDaSpareBay',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa6PhyDrvStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco físico (3036 in CPQIDA.MIB)', 'severity'=>'3',  'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvIndex;cpqDaPhyDrvBusNumber;cpqDaPhyDrvBay;cpqDaPhyDrvModel;cpqDaPhyDrvFWRev;cpqDaPhyDrvSerialNum;cpqDaPhyDrvFailureCode;cpqDaPhyDrvStatus',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa6PhyDrvThreshPassedTrap', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Disco físico degradado (3037 in CPQIDA.MIB). CRITICO', 'severity'=>'1',  'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvIndex;cpqDaPhyDrvBusNumber;cpqDaPhyDrvBay;cpqDaPhyDrvModel;cpqDaPhyDrvFWRev;cpqDaPhyDrvSerialNum',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa6AccelStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado aceleradora discos (3038 in CPQIDA.MIB)', 'severity'=>'3',  'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaCntlrModel;cpqDaAccelCntlrIndex;cpqDaAccelSerialNumber;cpqDaAccelTotalMemory;cpqDaAccelStatus;cpqDaAccelErrCode',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa6AccelBadDataTrap', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo aceleradora discos (3039 in CPQIDA.MIB)', 'severity'=>'3',  'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaCntlrModel;cpqDaAccelCntlrIndex;cpqDaAccelSerialNumber;cpqDaAccelTotalMemory',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa6AccelBatteryFailed', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Fallo batería aceleradora discos (3040 in CPQIDA.MIB)', 'severity'=>'3',  'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaCntlrModel;cpqDaAccelCntlrIndex;cpqDaAccelSerialNumber;cpqDaAccelTotalMemory',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa7PhyDrvStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco físico (3046 in CPQIDA.MIB)', 'severity'=>'3',  'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaPhyDrvCntlrIndex;cpqDaPhyDrvIndex;cpqDaPhyDrvLocationString;cpqDaPhyDrvType;cpqDaPhyDrvModel;cpqDaPhyDrvFWRev;cpqDaPhyDrvSerialNum;cpqDaPhyDrvFailureCode;cpqDaPhyDrvStatus;cpqDaPhyDrvBusNumber',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'CPQIDA-MIB::cpqDa7SpareStatusChange', 'class'=>'COMPAQ',
      'descr'=>'HP TRAP: Cambio estado disco spare (3047 in CPQIDA.MIB)', 'severity'=>'3', 'enterprise'=>'ent.232',
      'vardata' =>'sysName;cpqHoTrapFlags;cpqDaCntlrHwLocation;cpqDaSpareCntlrIndex;cpqDaSparePhyDrvIndex;cpqDaSpareStatus;cpqDaSpareLocationString;cpqDaSpareBusNumber',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'HW.HP', 'itil_type'=>'1'  },

);

1;
__END__
