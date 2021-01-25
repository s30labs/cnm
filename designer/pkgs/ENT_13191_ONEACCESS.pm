#---------------------------------------------------------------------------
package ENT_13191_ONEACCESS;
#---------------------------------------------------------------------------
#/opt/cnm/designer/gconf -m ENT_13191_ONEACCESS

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_13191_ONEACCESS::ENTERPRISE_PREFIX='13191';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_13191_ONEACCESS::TABLE_APPS =(

#	'VMINFO' => {
#
#      'col_filters' => '#text_filter.#text_filter.#text_filter.#numeric_filter.#select_filter.#numeric_filter.#select_filter.#text_filter',
#      'col_widths' => '20.30.25.15.15.15.15.20',
#      'col_sorting' => 'str.str.str.int.int.int.int.str',
#
#      'oid_cols' => 'vmwVmDisplayName_vmwVmConfigFile_vmwVmGuestOS_vmwVmMemSize_vmwVmState_vmwVmGuestState_vmwVmCpus_vmwVmUUID',
#		'oid_last' => 'VMWARE-VMINFO-MIB::vmwVmTable',
#
#		'name' => 'MAQUINAS VIRTUALES CONFIGURADAS EN EL SISTEMA',
#		'descr' => 'Muestra las maquinas virtuales configuradas en el sistema',
#		'xml_file' => '06876-VMWARE-VMINFO-MIB.xml',
#		'params' => '[-n;IP;]',
#		'ipparam' => '[-n;IP;]',
#		'subtype'=>'VMWARE',
#		'aname'=>'app_vmware_vminfo_table',
#		'range' => 'VMWARE-VMINFO-MIB::vmwVmTable',
#		'enterprise' => '06876',  #5 CIFRAS !!!!
#		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 06876-VMWARE-VMINFO-MIB.xml -w xml ',
#		'itil_type' => 1,		'apptype'=>'VIRTUAL.VMWARE',
#	},
#
);

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO GET
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_13191_ONEACCESS::GET_APPS =(

#  'GET_INFO' => {
#
#      items => [
#
#                  {  'name'=> 'NOMBRE DEL PRODUCTO',   'oid'=>'VMWARE-SYSTEM-MIB::vmwProdName.0', 'esp'=>'' },
#                  {  'name'=> 'VERSION DEL PRODUCTO',   'oid'=>'VMWARE-SYSTEM-MIB::vmwProdVersion.0', 'esp'=>'' },
#                  {  'name'=> 'OID DEL PRODUCTO',   'oid'=>'VMWARE-SYSTEM-MIB::vmwProdOID.0', 'esp'=>'' },
#                  {  'name'=> 'REFERENCIA DEL PRODUCTO',   'oid'=>'VMWARE-SYSTEM-MIB::vmwProdBuild.0', 'esp'=>'' },
#      ],
#
#		'oid_cols' => 'vmwProdName_vmwProdVersion_vmwProdOID_vmwProdBuild',
#      'name' => 'INFORMACION BASICA VMWARE',
#      'descr' => 'Muestra informacion basica sobre el equipo',
#      'xml_file' => '06876-VMWARE-get-info.xml',
#      'params' => '[-n;IP;]',
#      'ipparam' => '[-n;IP;]',
#      'subtype'=>'VMWARE',		'apptype'=>'VIRTUAL.VMWARE',
#      'aname'=>'app_vmware_get_info',
#      'range' => 'VMWARE-SYSTEM-MIB::vmwProdName.0',
#      'enterprise' => '06876',  #5 CIFRAS !!!!
#      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 06876-VMWARE-get-info.xml -w xml ',
#      'itil_type' => 1,
#  },
#
);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_13191_ONEACCESS::METRICS=(

#	{  'name'=> 'TASA DE TRANSFERENCIA',   'oid'=>'FINJAN-MIB::vsScannerThroughput-in-total.0|FINJAN-MIB::vsScannerThroughput-out-total.0', 'subtype'=>'finjan_scan_thro', 'class'=>'FINJAN' },
#	{	'name'=> 'USO DE CPU (%)',	'oid'=>'ONEACCESS-SYS-MIB::oacSysCpuUsedOneMinuteValue.0', 'subtype'=>'oneaccess_cpu_total', 'class'=>'ONEACCESS', 'include'=>'1', 'apptype'=>'NET.ONEACCESS' },
	{	'name'=> 'USO DE MEMORIA',	'oid'=>'ONEACCESS-SYS-MIB::oacSysMemoryUsed.0', 'subtype'=>'oneaccess_mem_total', 'class'=>'ONEACCESS', 'include'=>'1', 'apptype'=>'NET.ONEACCESS' },

);

#ONEACCESS-SYS-MIB::oacSysMemoryUsed.0 = Gauge32: 38

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_13191_ONEACCESS::METRICS_TAB=(

#	{	'name'=> 'USO DE CPU EN VM',  'oid'=>'cpuUtil', 'subtype'=>'vmware_cpu_util', 'class'=>'VMWARE', 'range'=>'VMWARE-RESOURCES-MIB::cpuTable', 'get_iid'=>'cpuVMID', 'itil_type' => 1, 'apptype'=>'VIRTUAL.VMWARE' },
#	{	'name'=> 'USO DE MEMORIA EN VM',  'oid'=>'memUtil|memConfigured', 'subtype'=>'vmware_mem_util', 'class'=>'VMWARE', 'range'=>'VMWARE-RESOURCES-MIB::memTable', 'get_iid'=>'memVMID', 'itil_type' => 1, 'apptype'=>'VIRTUAL.VMWARE' },
#	{	'name'=> 'USO DE DISCO EN VM',  'oid'=>'kbRead|kbWritten', 'subtype'=>'vmware_disk_util_kb', 'class'=>'VMWARE', 'range'=>'VMWARE-RESOURCES-MIB::vmwHBATable', 'get_iid'=>'hbaName', 'itil_type' => 1, 'apptype'=>'VIRTUAL.VMWARE' },


#ONEACCESS-SYS-MIB::oacSysCpuUsedOneMinuteValue.0
#oacSysCpuUsedOneMinuteValue OBJECT-TYPE
#  -- FROM       ONEACCESS-SYS-MIB
#  SYNTAX        Unsigned32
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   "Cpu load for the last minute period"
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) oneAccess(13191) oacExperimental(10) oacExpInternalModules(3) oacExpIMSystem(3) oacExpIMSysStatistics(1) oacSysCpuStatistics(2) oacSysCpuUsedCoresTable(3) oacSysCpuUsedCoresEntry(1) oacSysCpuUsedOneMinuteValue(4) 0 }

	#{	'name'=> 'USO DE CPU',  'oid'=>'oacSysCpuUsedOneMinuteValue', 'subtype'=>'oneaccess_cpu_usage', 'class'=>'ONEACCESS', 'range'=>'ONEACCESS-SYS-MIB::oacSysCpuUsedCoresTable', 'get_iid'=>'oacSysCpuUsedIndex', 'include'=>'1', 'items'=>'oacSysCpuUsedOneMinuteValue', 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.ONEACCESS', 'params'=>'[{"key":"iid_mode","value":"ascii"}]' },
	{	'name'=> 'USO DE CPU',  'oid'=>'oacSysCpuUsedOneMinuteValue', 'subtype'=>'oneaccess_cpu_usage', 'class'=>'ONEACCESS', 'range'=>'ONEACCESS-SYS-MIB::oacSysCpuUsedCoresTable', 'get_iid'=>'oacSysCpuUsedIndex', 'include'=>'1', 'items'=>'oacSysCpuUsedOneMinuteValue', 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.ONEACCESS' },

#ONEACCESS-CELLULAR-MIB::oacCellSignalStrength.1 = INTEGER: -54
#ONEACCESS-CELLULAR-MIB::oacCellEcIo.1 = INTEGER: 0
#ONEACCESS-CELLULAR-MIB::oacCellRSRQ.1 = INTEGER: -10
#ONEACCESS-CELLULAR-MIB::oacCellRSRP.1 = INTEGER: -91
#ONEACCESS-CELLULAR-MIB::oacCellSNR.1 = INTEGER: 7

#ONEACCESS-CELLULAR-MIB::oacCellSignalStrength
#oacCellSignalStrength OBJECT-TYPE
#  -- FROM       ONEACCESS-CELLULAR-MIB
#  SYNTAX        Integer32
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   "Signal strength (dBm)"
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) oneAccess(13191) oacExperimental(10) oacExpInternalModules(3) oacExpIMCellRadio(9) oacCellRadioModuleTable(2) oacCellRadioModuleEntry(1) 41 }

	{	'name'=> 'PARAMETROS RADIO',  'oid'=>'oacCellSignalStrength|oacCellRSRQ|oacCellRSRP|oacCellSNR', 'subtype'=>'oneaccess_radio_params', 'class'=>'ONEACCESS', 'range'=>'ONEACCESS-CELLULAR-MIB::oacCellRadioModuleTable', 'get_iid'=>'oacCellModuleIndex', 'include'=>'1', 'items'=>'oacCellSignalStrength|oacCellRSRQ|oacCellRSRP|oacCellSNR', 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.ONEACCESS', 'mtype'=>'STD_ANAL' },

#NS-ROOT-MIB::vsvrState
#vsvrState OBJECT-TYPE
#  -- FROM       NS-ROOT-MIB
#  -- TEXTUAL CONVENTION EntityState
#  SYNTAX        INTEGER {down(1), unknown(2), busy(3), outOfService(4), transitionToOutOfService(5), up(7), transitionToOutOfServiceDown(8)}
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   "Current state of the server. There are seven possible values: UP(7), DOWN(1), UNKNOWN(2), BUSY(3), OFS(Out of Service)(4), TROFS(Transition Out of Service)(5), TROFS_DOWN(Down When going Out of Service)(8)"
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) netScaler(5951) nsProducts(4) rs9000(1) nsVserverGroup(3) vserverTable(1) vserverEntry(1) 5 }
#
# {  'name'=> 'ESTADO DEL VSERVER',   'oid'=>'NS-ROOT-MIB::vsvrState', 'subtype'=>'netscaler_vsvr_status', 'class'=>'NETSCALER', 'range'=>'NS-ROOT-MIB::vserverTable', 'vlabel'=>'Status', 'get_iid'=>'vsvrName', 'include'=>'1', 'items'=>'up(7)|down(1)|unknown(2)|busy(3)|outOfService(4)|transitionToOutOfService(5)|transitionToOutOfServiceDown(8)', 'esp'=>'MAP(7)(1,0,0,0,0,0,0,0)|MAP(1)(0,1,0,0,0,0,0,0)|MAP(2)(0,0,1,0,0,0,0,0)|MAP(3)(0,0,0,1,0,0,0,0)|MAP(4)(0,0,0,0,1,0,0,0)|MAP(5)(0,0,0,0,0,1,0,0)|MAP(6)(0,0,0,0,0,0,1,0)|MAP(8)(0,0,0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.NETSCALER', 'params'=>'[{"key":"iid_mode","value":"ascii"}]' },


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_13191_ONEACCESS::REMOTE_ALERTS=(

#   {  'type'=>'snmp', 'subtype'=>'VMWARE-TRAPS-MIB::vmPoweredOn', 'class'=>'VMWARE',
#      'descr'=>'MAQUINA VIRTUAL ARRANCADA', 'severity'=>'2',
#      'vardata' =>'vmID;vmConfigFile', 'enterprise'=>'ent.6876',
#      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH', 'expr'=>''},
#							  {'v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH', 'expr'=>''} ],
#      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
#      'action'=>'SET', 'script'=>'',   'apptype'=>'VIRTUAL.VMWARE', 'itil_type'=>'1'  },
#
#   {  'type'=>'snmp', 'subtype'=>'VMWARE-TRAPS-MIB::vmPoweredOff', 'class'=>'VMWARE',
#      'descr'=>'MAQUINA VIRTUAL APAGADA', 'severity'=>'1',
#      'vardata' =>'vmID;vmConfigFile', 'enterprise'=>'ent.6876',
#      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH', 'expr'=>''},
#                       {'v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH', 'expr'=>''} ],
#      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
#      'action'=>'SET', 'script'=>'',   'apptype'=>'VIRTUAL.VMWARE', 'itil_type'=>'1'  },
#
#   {  'type'=>'snmp', 'subtype'=>'VMWARE-TRAPS-MIB::vmHBLost', 'class'=>'VMWARE',
#      'descr'=>'PERDIDA DE HEATBEAT CON EL HOST', 'severity'=>'2',
#      'vardata' =>'vmID;vmConfigFile', 'enterprise'=>'ent.6876',
#      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH', 'expr'=>''},
#                       {'v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH', 'expr'=>''} ],
#      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
#      'action'=>'SET', 'script'=>'',   'apptype'=>'VIRTUAL.VMWARE', 'itil_type'=>'1'  },
#
#   {  'type'=>'snmp', 'subtype'=>'VMWARE-TRAPS-MIB::vmHBDetected', 'class'=>'VMWARE',
#      'descr'=>'RECUPERADO HEATBEAT CON EL HOST', 'severity'=>'2',
#      'vardata' =>'vmID;vmConfigFile', 'enterprise'=>'ent.6876',
#      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH', 'expr'=>''},
#                       {'v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH', 'expr'=>''} ],
#      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
#      'action'=>'SET', 'script'=>'',   'apptype'=>'VIRTUAL.VMWARE', 'itil_type'=>'1'  },
#
#   {  'type'=>'snmp', 'subtype'=>'VMWARE-TRAPS-MIB::vmSuspended', 'class'=>'VMWARE',
#      'descr'=>'MAQUINA VIRTUAL SUSPENDIDA', 'severity'=>'2',
#      'vardata' =>'vmID;vmConfigFile', 'enterprise'=>'ent.6876',
#      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH', 'expr'=>''},
#                       {'v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH', 'expr'=>''} ],
#      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
#      'action'=>'SET', 'script'=>'',   'apptype'=>'VIRTUAL.VMWARE', 'itil_type'=>'1'  },

);


1;
__END__
