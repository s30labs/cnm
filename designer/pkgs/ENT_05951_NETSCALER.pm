#---------------------------------------------------------------------------
package ENT_05951_NETSCALER;
#---------------------------------------------------------------------------
#/opt/cnm/designer/gconf -m ENT_05951_NETSCALER

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_05951_NETSCALER::ENTERPRISE_PREFIX='05951';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_05951_NETSCALER::TABLE_APPS =(

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
%ENT_05951_NETSCALER::GET_APPS =(

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
@ENT_05951_NETSCALER::METRICS=(

#	{  'name'=> 'TASA DE ESCANEO',   'oid'=>'FINJAN-MIB::vsScannerReqs-per-second.0', 'subtype'=>'finjan_scan_reqs', 'class'=>'FINJAN' },
#	{  'name'=> 'TASA DE TRANSFERENCIA',   'oid'=>'FINJAN-MIB::vsScannerThroughput-in-total.0|FINJAN-MIB::vsScannerThroughput-out-total.0', 'subtype'=>'finjan_scan_thro', 'class'=>'FINJAN' },
	{	'name'=> 'USO DE CPU TOTAL',	'oid'=>'NS-ROOT-MIB::resCpuUsage.0', 'subtype'=>'netscaler_cpu_total', 'class'=>'NETSCALER', 'include'=>'1', 'apptype'=>'NET.NETSCALER' },
	{	'name'=> 'USO DE MEMORIA TOTAL',	'oid'=>'NS-ROOT-MIB::resMemUsage.0', 'subtype'=>'netscaler_mem_total', 'class'=>'NETSCALER', 'include'=>'1', 'apptype'=>'NET.NETSCALER', 'esp'=>'INT(o1)' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_05951_NETSCALER::METRICS_TAB=(

#	{	'name'=> 'USO DE CPU EN VM',  'oid'=>'cpuUtil', 'subtype'=>'vmware_cpu_util', 'class'=>'VMWARE', 'range'=>'VMWARE-RESOURCES-MIB::cpuTable', 'get_iid'=>'cpuVMID', 'itil_type' => 1, 'apptype'=>'VIRTUAL.VMWARE' },
#	{	'name'=> 'USO DE MEMORIA EN VM',  'oid'=>'memUtil|memConfigured', 'subtype'=>'vmware_mem_util', 'class'=>'VMWARE', 'range'=>'VMWARE-RESOURCES-MIB::memTable', 'get_iid'=>'memVMID', 'itil_type' => 1, 'apptype'=>'VIRTUAL.VMWARE' },
#	{	'name'=> 'USO DE DISCO EN VM',  'oid'=>'kbRead|kbWritten', 'subtype'=>'vmware_disk_util_kb', 'class'=>'VMWARE', 'range'=>'VMWARE-RESOURCES-MIB::vmwHBATable', 'get_iid'=>'hbaName', 'itil_type' => 1, 'apptype'=>'VIRTUAL.VMWARE' },


	{	'name'=> 'USO DE CPU',  'oid'=>'nsCPUusage', 'subtype'=>'netscaler_cpu_usage', 'class'=>'NETSCALER', 'range'=>'NS-ROOT-MIB::nsCPUTable', 'get_iid'=>'nsCPUname', 'include'=>'1', 'items'=>'nsCPUusage', 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.NETSCALER', 'params'=>'[{"key":"iid_mode","value":"ascii"}]' },

#root@cnm-areas:/opt/cnm/designer# snmptranslate -Td NS-ROOT-MIB::sysHealthDiskPerusage
#NS-ROOT-MIB::sysHealthDiskPerusage
#sysHealthDiskPerusage OBJECT-TYPE
#  -- FROM       NS-ROOT-MIB
#  SYNTAX        Gauge32
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   "The Percentage of the disk space used."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) netScaler(5951) nsProducts(4) rs9000(1) nsSysGroup(1) nsResourceGroup(41) nsSysHealthDiskTable(8) nsSysHealthDiskEntry(1) 5 }
#
	{	'name'=> 'USO DE DISCO',  'oid'=>'sysHealthDiskPerusage', 'subtype'=>'netscaler_disk_usage', 'class'=>'NETSCALER', 'range'=>'NS-ROOT-MIB::nsSysHealthDiskTable', 'get_iid'=>'sysHealthDiskName', 'include'=>'1', 'items'=>'sysHealthDiskPerusage', 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.NETSCALER', 'params'=>'[{"key":"iid_mode","value":"ascii"}]' },

	{	'name'=> 'ACTIVIDAD EN VSERVER',  'oid'=>'vsvrTotalRequests|vsvrTotalResponses', 'subtype'=>'netscaler_vsvr_activity', 'class'=>'NETSCALER', 'range'=>'NS-ROOT-MIB::vserverTable', 'get_iid'=>'vsvrName', 'include'=>'1', 'items'=>'vsvrTotalRequests|vsvrTotalResponses', 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.NETSCALER', 'params'=>'[{"key":"iid_mode","value":"ascii"}]' },
	{	'name'=> 'TRAFICO EN VSERVER',  'oid'=>'vsvrTotalRequestBytes|vsvrTotalResponseBytes', 'subtype'=>'netscaler_vsvr_traffic', 'class'=>'NETSCALER', 'range'=>'NS-ROOT-MIB::vserverTable', 'get_iid'=>'vsvrName', 'include'=>'1', 'items'=>'vsvrTotalRequestBytes|vsvrTotalResponseBytes', 'esp'=>'o1*8|o2*8', 'itil_type' => 1, 'apptype'=>'NET.NETSCALER', 'params'=>'[{"key":"iid_mode","value":"ascii"}]' },

	{	'name'=> 'PAQUETES EN VSERVER',  'oid'=>'vsvrTotalPktsSent|vsvrTotalPktsRecvd', 'subtype'=>'netscaler_vsvr_pkts', 'class'=>'NETSCALER', 'range'=>'NS-ROOT-MIB::vserverTable', 'get_iid'=>'vsvrName', 'include'=>'1', 'items'=>'vsvrTotalPktsSent|vsvrTotalPktsRecvd', 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.NETSCALER', 'params'=>'[{"key":"iid_mode","value":"ascii"}]' },
	{	'name'=> 'CLIENTES TOTALES EN VSERVER',  'oid'=>'vsvrTotalClients', 'subtype'=>'netscaler_vsvr_cli_tot', 'class'=>'NETSCALER', 'range'=>'NS-ROOT-MIB::vserverTable', 'get_iid'=>'vsvrName', 'include'=>'1', 'items'=>'vsvrTotalClients', 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.NETSCALER', 'params'=>'[{"key":"iid_mode","value":"ascii"}]' },
	{	'name'=> 'TASA DE CONEXIONES EN VSERVER',  'oid'=>'vsvrClientConnOpenRate', 'subtype'=>'netscaler_vsvr_open_rate', 'class'=>'NETSCALER', 'range'=>'NS-ROOT-MIB::vserverTable', 'get_iid'=>'vsvrName', 'include'=>'1', 'items'=>'vsvrClientConnOpenRate', 'esp'=>'INT(o1)', 'itil_type' => 1, 'apptype'=>'NET.NETSCALER', 'params'=>'[{"key":"iid_mode","value":"ascii"}]' },

	{	'name'=> 'SURGE COUNT',  'oid'=>'vsvrSurgeCount', 'subtype'=>'netscaler_vsvr_surge_cnt', 'class'=>'NETSCALER', 'range'=>'NS-ROOT-MIB::vserverTable', 'get_iid'=>'vsvrName', 'include'=>'1', 'items'=>'vsvrSurgeCount', 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.NETSCALER', 'params'=>'[{"key":"iid_mode","value":"ascii"}]' },
	{	'name'=> 'SALUD DEL VSERVER',  'oid'=>'vsvrHealth', 'subtype'=>'netscaler_vsvr_health', 'class'=>'NETSCALER', 'range'=>'NS-ROOT-MIB::vserverTable', 'get_iid'=>'vsvrName', 'include'=>'1', 'items'=>'vsvrHealth', 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.NETSCALER', 'params'=>'[{"key":"iid_mode","value":"ascii"}]' },


	{	'name'=> 'CONTADOR DE SALUD',  'oid'=>'sysHealthCounterValue', 'subtype'=>'netscaler_health_cnt', 'class'=>'NETSCALER', 'range'=>'NS-ROOT-MIB::nsSysHealthTable', 'get_iid'=>'sysHealthCounterName', 'include'=>'0', 'items'=>'vsvrHealth', 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.NETSCALER', 'params'=>'[{"key":"iid_mode","value":"ascii"}]' },
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
 {  'name'=> 'ESTADO DEL VSERVER',   'oid'=>'NS-ROOT-MIB::vsvrState', 'subtype'=>'netscaler_vsvr_status', 'class'=>'NETSCALER', 'range'=>'NS-ROOT-MIB::vserverTable', 'vlabel'=>'Status', 'get_iid'=>'vsvrName', 'include'=>'1', 'items'=>'up(7)|down(1)|unknown(2)|busy(3)|outOfService(4)|transitionToOutOfService(5)|transitionToOutOfServiceDown(8)', 'esp'=>'MAP(7)(1,0,0,0,0,0,0,0)|MAP(1)(0,1,0,0,0,0,0,0)|MAP(2)(0,0,1,0,0,0,0,0)|MAP(3)(0,0,0,1,0,0,0,0)|MAP(4)(0,0,0,0,1,0,0,0)|MAP(5)(0,0,0,0,0,1,0,0)|MAP(6)(0,0,0,0,0,0,1,0)|MAP(8)(0,0,0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.NETSCALER', 'params'=>'[{"key":"iid_mode","value":"ascii"}]' },


#NS-ROOT-MIB::haCurState
#haCurState OBJECT-TYPE
#  -- FROM       NS-ROOT-MIB
#  -- TEXTUAL CONVENTION HAState
#  SYNTAX        INTEGER {unknown(0), init(1), down(2), up(3), partialFail(4), monitorFail(5), monitorOk(6), completeFail(7), dumb(8), disabled(9), partialFailSsl(10), routemonitorFail(11)}
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   "State of the HA node, based on its health, in a high availability setup. Possible values are:
#UP - Indicates that the node is accessible and can function as either a primary or secondary node.
#DISABLED - Indicates that the high availability status of the node has been manually disabled. Synchronization and propagation cannot take place between the peer nodes.
#INIT - Indicates that the node is in the process of becoming part of the high availability configuration.
#PARTIALFAIL - Indicates that one of the high availability monitored interfaces has failed because of a card or link failure. This state triggers a failover.
#COMPLETEFAIL - Indicates that all the interfaces of the node are unusable, because the interfaces on which high availability monitoring is enabled are not connected or are manually disabled. This state triggers a failover.
#DUMB - Indicates that the node is in listening mode. It does not participate in high availability transitions or transfer configuration from the peer node. This is a configured value, not a statistic.
#PARTIALFAILSSL - Indicates that the SSL card has failed. This state triggers a failover.
#ROUTEMONITORFAIL - Indicates that the route monitor has failed. This state triggers a failover."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) netScaler(5951) nsProducts(4) rs9000(1) nsSysGroup(1) nsHighAvailabilityGroup(23) 24 }
#
#	{	'name'=> 'MEMORIA CONFIGURADA EN VM',  'oid'=>'vmwVmMemSize', 'subtype'=>'vmware_mem_cfg', 'class'=>'VMWARE', 'range'=>'VMWARE-VMINFO-MIB::vmwVmTable', 'get_iid'=>'vmwVmDisplayName', 'itil_type' => 1, 'apptype'=>'VIRTUAL.VMWARE' },
#   {  'name'=> 'ESTADO DE VM',  'oid'=>'vmwVmGuestState', 'subtype'=>'vmware_vm_status', 'class'=>'VMWARE', 'range'=>'VMWARE-VMINFO-MIB::vmwVmTable', 'get_iid'=>'vmwVmDisplayName', 'itil_type'=>1,
#'esp'=>'MAPS("running")(1,0)|MAPS("notRunning")(0,1)', 'mtype'=>'STD_SOLID', 'items'=>'running|notRunning', 'apptype'=>'VIRTUAL.VMWARE'
#},

#   {  'name'=> 'ESTADO GLOBAL DE TODAS LAS VM',  'oid'=>'vmwVmGuestState', 'subtype'=>'vmware_vm_glob_status', 'class'=>'VMWARE', 'range'=>'VMWARE-VMINFO-MIB::vmwVmTable', 'get_iid'=>'vmwVmDisplayName', 'itil_type'=>1,
#'esp'=>'TABLE(MATCH)("running")|TABLE(MATCH)("notRunning")', 'items'=>'running|notRunning', 'apptype'=>'VIRTUAL.VMWARE'
#},
#
#   {  'name'=> 'MEMORIA GLOBAL DE TODAS LAS VM',  'oid'=>'vmwVmGuestState|vmwVmMemSize', 'subtype'=>'vmware_vm_glob_mem', 'class'=>'VMWARE', 'range'=>'VMWARE-VMINFO-MIB::vmwVmTable', 'get_iid'=>'vmwVmDisplayName', 'itil_type'=>1,
#'esp'=>'TABLE(SUM)("running")|TABLE(SUM)("notRunning")', 'items'=>'running|notRunning', 'apptype'=>'VIRTUAL.VMWARE'
#},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_05951_NETSCALER::REMOTE_ALERTS=(

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
