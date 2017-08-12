#---------------------------------------------------------------------------
package ENT_06876_VMWARE;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_06876_VMWARE::ENTERPRISE_PREFIX='06876';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_06876_VMWARE::TABLE_APPS =(

	'VMINFO' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#numeric_filter.#select_filter.#numeric_filter.#select_filter',
      'col_widths' => '25.30.25.20.20.20.20',
      'col_sorting' => 'str.str.str.int.int.int.int',

		'oid_cols' => 'vmDisplayName_vmConfigFile_vmGuestOS_vmMemSize_vmState_vmVMID_vmGuestState',
		'oid_last' => 'VMWARE-VMINFO-MIB::vmTable',
		'name' => 'MAQUINAS VIRTUALES CONFIGURADAS EN EL SISTEMA',
		'descr' => 'Muestra las maquinas virtuales configuradas en el sistema',
		'xml_file' => '06876-VMWARE-VMINFO-MIB.xml',
		'params' => '[-n;IP;]',
		'ipparam' => '[-n;IP;]',
		'subtype'=>'VMWARE',
		'aname'=>'app_vmware_vminfo_table',
		'range' => 'VMWARE-VMINFO-MIB::vmTable',
		'enterprise' => '06876',  #5 CIFRAS !!!!
		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 06876-VMWARE-VMINFO-MIB.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'VIRTUAL.VMWARE',
	},

);

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO GET
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_06876_VMWARE::GET_APPS =(

  'GET_INFO' => {

      items => [

                  {  'name'=> 'NOMBRE DEL PRODUCTO',   'oid'=>'VMWARE-SYSTEM-MIB::vmwProdName.0', 'esp'=>'' },
                  {  'name'=> 'VERSION DEL PRODUCTO',   'oid'=>'VMWARE-SYSTEM-MIB::vmwProdVersion.0', 'esp'=>'' },
                  {  'name'=> 'OID DEL PRODUCTO',   'oid'=>'VMWARE-SYSTEM-MIB::vmwProdOID.0', 'esp'=>'' },
                  {  'name'=> 'REFERENCIA DEL PRODUCTO',   'oid'=>'VMWARE-SYSTEM-MIB::vmwProdBuild.0', 'esp'=>'' },
      ],

		'oid_cols' => 'vmwProdName_vmwProdVersion_vmwProdOID_vmwProdBuild',
      'name' => 'INFORMACION BASICA VMWARE',
      'descr' => 'Muestra informacion basica sobre el equipo',
      'xml_file' => '06876-VMWARE-get-info.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'VMWARE',		'apptype'=>'VIRTUAL.VMWARE',
      'aname'=>'app_vmware_get_info',
      'range' => 'VMWARE-SYSTEM-MIB::vmwProdName.0',
      'enterprise' => '06876',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 06876-VMWARE-get-info.xml -w xml ',
      'itil_type' => 1,
  },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_06876_VMWARE::METRICS=(

#	{  'name'=> 'TASA DE ESCANEO',   'oid'=>'FINJAN-MIB::vsScannerReqs-per-second.0', 'subtype'=>'finjan_scan_reqs', 'class'=>'FINJAN' },
#	{  'name'=> 'TASA DE TRANSFERENCIA',   'oid'=>'FINJAN-MIB::vsScannerThroughput-in-total.0|FINJAN-MIB::vsScannerThroughput-out-total.0', 'subtype'=>'finjan_scan_thro', 'class'=>'FINJAN' },
	#{	'name'=> 'MEMORIA ASIGNADA',	'oid'=>'WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0|WINDOWS-NT-PERFORMANCE::memoryCommitLimit.0', 'subtype'=>'winnt_memory_committed_bytes', 'class'=>'WINDOWS-NT'},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_06876_VMWARE::METRICS_TAB=(

	{	'name'=> 'USO DE CPU EN VM',  'oid'=>'cpuUtil', 'subtype'=>'vmware_cpu_util', 'class'=>'VMWARE', 'range'=>'VMWARE-RESOURCES-MIB::cpuTable', 'get_iid'=>'cpuVMID', 'itil_type' => 1, 'apptype'=>'VIRTUAL.VMWARE' },
	{	'name'=> 'USO DE MEMORIA EN VM',  'oid'=>'memUtil|memConfigured', 'subtype'=>'vmware_mem_util', 'class'=>'VMWARE', 'range'=>'VMWARE-RESOURCES-MIB::memTable', 'get_iid'=>'memVMID', 'itil_type' => 1, 'apptype'=>'VIRTUAL.VMWARE' },
	{	'name'=> 'USO DE DISCO EN VM',  'oid'=>'kbRead|kbWritten', 'subtype'=>'vmware_disk_util_kb', 'class'=>'VMWARE', 'range'=>'VMWARE-RESOURCES-MIB::vmwHBATable', 'get_iid'=>'hbaName', 'itil_type' => 1, 'apptype'=>'VIRTUAL.VMWARE' },
	{	'name'=> 'USO DE RED EN VM',  'oid'=>'kbTx|kbRx', 'subtype'=>'vmware_net_util_kb', 'class'=>'VMWARE', 'range'=>'VMWARE-RESOURCES-MIB::vmwNetTable', 'get_iid'=>'netName', 'itil_type' => 1, 'apptype'=>'VIRTUAL.VMWARE' },

	{	'name'=> 'MEMORIA CONFIGURADA EN VM',  'oid'=>'vmMemSize', 'subtype'=>'vmware_mem_cfg', 'class'=>'VMWARE', 'range'=>'VMWARE-VMINFO-MIB::vmTable', 'get_iid'=>'vmDisplayName', 'itil_type' => 1, 'apptype'=>'VIRTUAL.VMWARE' },
   {  'name'=> 'ESTADO DE VM',  'oid'=>'vmGuestState', 'subtype'=>'vmware_vm_status', 'class'=>'VMWARE', 'range'=>'VMWARE-VMINFO-MIB::vmTable', 'get_iid'=>'vmDisplayName', 'itil_type'=>1,
'esp'=>'MAPS("running")(1,0)|MAPS("notRunning")(0,1)', 'mtype'=>'STD_SOLID', 'items'=>'running|notRunning', 'apptype'=>'VIRTUAL.VMWARE'
},

   {  'name'=> 'ESTADO GLOBAL DE TODAS LAS VM',  'oid'=>'vmGuestState', 'subtype'=>'vmware_vm_glob_status', 'class'=>'VMWARE', 'range'=>'VMWARE-VMINFO-MIB::vmTable', 'get_iid'=>'vmDisplayName', 'itil_type'=>1,
'esp'=>'TABLE(MATCH)("running")|TABLE(MATCH)("notRunning")', 'items'=>'running|notRunning', 'apptype'=>'VIRTUAL.VMWARE'
},

   {  'name'=> 'MEMORIA GLOBAL DE TODAS LAS VM',  'oid'=>'vmGuestState|vmMemSize', 'subtype'=>'vmware_vm_glob_mem', 'class'=>'VMWARE', 'range'=>'VMWARE-VMINFO-MIB::vmTable', 'get_iid'=>'vmDisplayName', 'itil_type'=>1,
'esp'=>'TABLE(SUM)("running")|TABLE(SUM)("notRunning")', 'items'=>'running|notRunning', 'apptype'=>'VIRTUAL.VMWARE'
},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_06876_VMWARE::REMOTE_ALERTS=(

   {  'type'=>'snmp', 'subtype'=>'VMWARE-TRAPS-MIB::vmPoweredOn', 'class'=>'VMWARE',
      'descr'=>'MAQUINA VIRTUAL ARRANCADA', 'severity'=>'2',
      'vardata' =>'vmID;vmConfigFile', 'enterprise'=>'ent.6876',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH', 'expr'=>''},
							  {'v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'VIRTUAL.VMWARE', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'VMWARE-TRAPS-MIB::vmPoweredOff', 'class'=>'VMWARE',
      'descr'=>'MAQUINA VIRTUAL APAGADA', 'severity'=>'1',
      'vardata' =>'vmID;vmConfigFile', 'enterprise'=>'ent.6876',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'VIRTUAL.VMWARE', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'VMWARE-TRAPS-MIB::vmHBLost', 'class'=>'VMWARE',
      'descr'=>'PERDIDA DE HEATBEAT CON EL HOST', 'severity'=>'2',
      'vardata' =>'vmID;vmConfigFile', 'enterprise'=>'ent.6876',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'VIRTUAL.VMWARE', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'VMWARE-TRAPS-MIB::vmHBDetected', 'class'=>'VMWARE',
      'descr'=>'RECUPERADO HEATBEAT CON EL HOST', 'severity'=>'2',
      'vardata' =>'vmID;vmConfigFile', 'enterprise'=>'ent.6876',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'VIRTUAL.VMWARE', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'VMWARE-TRAPS-MIB::vmSuspended', 'class'=>'VMWARE',
      'descr'=>'MAQUINA VIRTUAL SUSPENDIDA', 'severity'=>'2',
      'vardata' =>'vmID;vmConfigFile', 'enterprise'=>'ent.6876',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'VIRTUAL.VMWARE', 'itil_type'=>'1'  },

);


1;
__END__
