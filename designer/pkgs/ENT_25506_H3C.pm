#---------------------------------------------------------------------------
package ENT_25506_H3C;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_25506_H3C::ENTERPRISE_PREFIX='25506';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_25506_H3C::TABLE_APPS =(

#	'VMINFO' => {
#
#      'col_filters' => '#text_filter.#text_filter.#text_filter.#numeric_filter.#select_filter.#numeric_filter.#select_filter',
#      'col_widths' => '25.30.25.20.20.20.20',
#      'col_sorting' => 'str.str.str.int.int.int.int',
#
#		'oid_cols' => 'vmDisplayName_vmConfigFile_vmGuestOS_vmMemSize_vmState_vmVMID_vmGuestState',
#		'oid_last' => 'VMWARE-VMINFO-MIB::vmTable',
#		'name' => 'MAQUINAS VIRTUALES CONFIGURADAS EN EL SISTEMA',
#		'descr' => 'Muestra las maquinas virtuales configuradas en el sistema',
#		'xml_file' => '25506-VMWARE-VMINFO-MIB.xml',
#		'params' => '[-n;IP;]',
#		'ipparam' => '[-n;IP;]',
#		'subtype'=>'VMWARE',
#		'aname'=>'app_vmware_vminfo_table',
#		'range' => 'VMWARE-VMINFO-MIB::vmTable',
#		'enterprise' => '25506',  #5 CIFRAS !!!!
#		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 25506-VMWARE-VMINFO-MIB.xml -w xml ',
#		'itil_type' => 1,		'apptype'=>'VIRTUAL.VMWARE',
#	},

);

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO GET
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_25506_H3C::GET_APPS =(

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
#      'xml_file' => '25506-VMWARE-get-info.xml',
#      'params' => '[-n;IP;]',
#      'ipparam' => '[-n;IP;]',
#      'subtype'=>'VMWARE',		'apptype'=>'VIRTUAL.VMWARE',
#      'aname'=>'app_vmware_get_info',
#      'range' => 'VMWARE-SYSTEM-MIB::vmwProdName.0',
#      'enterprise' => '25506',  #5 CIFRAS !!!!
#      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 25506-VMWARE-get-info.xml -w xml ',
#      'itil_type' => 1,
#  },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
# 'mtype'=>'STD_SOLID' 	-> Metricas de estado (fx MAP ...)
# 'mtype'=>'STD_AREA'  	-> Area rellena
# 'mtype'=>'STD_BASE'	-> Por defecto
#---------------------------------------------------------------------------
@ENT_25506_H3C::METRICS=(

#HH3C-LSW-DEV-ADM-MIB::hh3cLswSysCpuRatio
#hh3cLswSysCpuRatio OBJECT-TYPE
#  -- FROM       HH3C-LSW-DEV-ADM-MIB
#  SYNTAX        INTEGER (0..100)
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   "CPU usage of the system in accuracy of 1%, and the range of value is 1 to 100."

	{	'name'=> 'USO DE CPU',	'oid'=>'HH3C-LSW-DEV-ADM-MIB::hh3cLswSysCpuRatio.0', 'subtype'=>'h3c_cpu_usage', 'class'=>'H3C', 'vlabel'=>'percent', 'include'=>1, 'items'=>'Uso de CPU (%)', 'itil_type' => 1, 'apptype'=>'NET.H3C', 'mtype'=>'STD_AREA' },


#HH3C-LSW-DEV-ADM-MIB::hh3cLswSysMemoryRatio
#hh3cLswSysMemoryRatio OBJECT-TYPE
#  -- FROM       HH3C-LSW-DEV-ADM-MIB
#  SYNTAX        Unsigned32 (0..100)
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   "The percentage of system memory in use.
#        Note that the system memory means the memory can be used by the software
#        platform.
#
#                                hh3cLswSysMemoryUsed
#        hh3cLswSysMemoryRatio = --------------------
#                                 hh3cLswSysMemory
#
#        For the distributed device, it represents the memory used ratio on the
#        master slot."

   {  'name'=> 'USO DE MEMORIA',  'oid'=>'HH3C-LSW-DEV-ADM-MIB::hh3cLswSysMemoryRatio.0', 'subtype'=>'h3c_mem_usage', 'class'=>'H3C', 'vlabel'=>'percent', 'include'=>1, 'items'=>'Uso de Memoria (%)', 'itil_type' => 1, 'apptype'=>'NET.H3C', 'mtype'=>'STD_AREA' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_25506_H3C::METRICS_TAB=(

#hh3cDevMFanStatus OBJECT-TYPE
#  -- FROM       HH3C-LswDEVM-MIB
#  SYNTAX        INTEGER {active(1), deactive(2), not-install(3), unsupport(4)}
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   " Fan status: active (1), deactive (2) not installed (3) and unsupported (4)"

   {  'name'=> 'ESTADO DEL VENTILADOR',  'oid'=>'hh3cDevMFanStatus', 'subtype'=>'h3c_fan_status', 'class'=>'H3C', 'range'=>'HH3C-LswDEVM-MIB::hh3cdevMFanStatusTable', 'vlabel'=>'estado', 'get_iid'=>'hh3cDevMFanNum', 'include'=>'1', 'items'=>'active|deactive|not installed|unsupported',
'esp'=>'MAP(1)(1,0,0,0)|MAP(2)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(4)(0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 1, 'apptype'=>'NET.H3C'
},


#HH3C-LswDEVM-MIB::hh3cDevMPowerStatus
#hh3cDevMPowerStatus OBJECT-TYPE
#  -- FROM       HH3C-LswDEVM-MIB
#  SYNTAX        INTEGER {active(1), deactive(2), not-install(3), unsupport(4)}
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   " Power status: active (1), deactive (2) not installed (3) and unsupported    "


   {  'name'=> 'ESTADO DE LA FUENTE',  'oid'=>'hh3cDevMPowerStatus', 'subtype'=>'h3c_power_status', 'class'=>'H3C', 'range'=>'HH3C-LswDEVM-MIB::hh3cdevMPowerStatusTable', 'get_iid'=>'hh3cDevMPowerNum', 'mtype'=>'STD_SOLID', 'itil_type'=>1, 
'esp'=>'MAP(1)(1,0,0,0)|MAP(2)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(4)(0,0,0,1)', 'items'=>'active|deactive|not installed|unsupported', 'apptype'=>'NET.H3C'
},

#HH3C-LSW-DEV-ADM-MIB::hh3cLswSlotCpuRatio
#hh3cLswSlotCpuRatio OBJECT-TYPE
#  -- FROM       HH3C-LSW-DEV-ADM-MIB
#  SYNTAX        INTEGER
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   "CPU usage of the slot in accuracy of 1%, and the range of value is 1 to 100."

	{	'name'=> 'USO DE CPU EN SLOT',  'oid'=>'hh3cLswSlotCpuRatio', 'subtype'=>'h3c_cpu_usage_slot', 'class'=>'H3C', 'range'=>'HH3C-LSW-DEV-ADM-MIB::hh3cLswSlotTable', 'get_iid'=>'hh3cLswSlotDesc', 'mtype'=>'STD_AREA', 'itil_type' => 1, 'items'=>'Uso de CPU (%)', 'apptype'=>'NET.H3C' },


#HH3C-LSW-DEV-ADM-MIB::hh3cLswSlotAdminStatus
#hh3cLswSlotAdminStatus OBJECT-TYPE
#  -- FROM       HH3C-LSW-DEV-ADM-MIB
#  SYNTAX        INTEGER {not-install(1), normal(2), fault(3), forbidden(4)}
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   "Slot status."
#HH3C-LSW-DEV-ADM-MIB::hh3cLswSlotOperStatus
#hh3cLswSlotOperStatus OBJECT-TYPE
#  -- FROM       HH3C-LSW-DEV-ADM-MIB
#  SYNTAX        INTEGER {disable(1), enable(2), reset(3), test(4)}
#  MAX-ACCESS    read-write
#  STATUS        current
#  DESCRIPTION   "Slot operation status."


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_25506_H3C::REMOTE_ALERTS=(

#   {  'type'=>'snmp', 'subtype'=>'VMWARE-TRAPS-MIB::vmPoweredOn', 'class'=>'VMWARE',
#      'descr'=>'MAQUINA VIRTUAL ARRANCADA', 'severity'=>'2',
#      'vardata' =>'vmID;vmConfigFile', 'enterprise'=>'ent.6876',
#      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'vmID', 'fx'=>'MATCH', 'expr'=>''},
#							  {'v'=>'v1', 'descr'=>'vmConfigFile', 'fx'=>'MATCH', 'expr'=>''} ],
#      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
#      'action'=>'SET', 'script'=>'',   'apptype'=>'VIRTUAL.VMWARE', 'itil_type'=>'1'  },

);


1;
__END__
