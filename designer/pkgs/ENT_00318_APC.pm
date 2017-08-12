#---------------------------------------------------------------------------
package ENT_00318_APC;
#---------------------------------------------------------------------------
# /opt/cnm-designer/gconf -m ENT_00318_APC
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_00318_APC::ENTERPRISE_PREFIX='00318';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_00318_APC::TABLE_APPS =(

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
%ENT_00318_APC::GET_APPS =(

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
@ENT_00318_APC::METRICS=(

#PowerNet-MIB::upsBasicBatteryStatus.0 = INTEGER: 2
#PowerNet-MIB::upsAdvBatteryTemperature.0 = Gauge32: 19
#PowerNet-MIB::upsAdvBatteryRunTimeRemaining.0 = Timeticks: (318000) 0:53:00.00
#PowerNet-MIB::upsAdvBatteryActualVoltage.0 = INTEGER: 481
#PowerNet-MIB::upsAdvBatteryCurrent.0 = INTEGER: 0
#PowerNet-MIB::upsAdvOutputLoad.0 = Gauge32: 16
#PowerNet-MIB::upsCommStatus.0 = INTEGER: 1



#PowerNet-MIB::upsBasicBatteryStatus
#upsBasicBatteryStatus OBJECT-TYPE
#  -- FROM       PowerNet-MIB
#  SYNTAX        INTEGER {unknown(1), batteryNormal(2), batteryLow(3), batteryInFaultCondition(4)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "The status of the UPS batteries. A batteryLow(3) value
#       indicates the UPS will be unable to sustain the current
#       load, and its services will be lost if power is not restored.
#       The amount of run time in reserve at the time of low battery
#       can be configured by the upsAdvConfigLowBatteryRunTime.
#       A batteryInFaultCondition(4)value indicates that a battery
#       installed has an internal error condition."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) apc(318) products(1) hardware(1) ups(1) upsBattery(2) upsBasicBattery(1) 1 }



#	{	'name'=> 'USO DE CPU',	'oid'=>'HH3C-LSW-DEV-ADM-MIB::hh3cLswSysCpuRatio.0', 'subtype'=>'h3c_cpu_usage', 'class'=>'H3C', 'vlabel'=>'percent', 'include'=>1, 'items'=>'Uso de CPU (%)', 'itil_type' => 1, 'apptype'=>'NET.H3C', 'mtype'=>'STD_AREA' },
#verde|azul|rojo|naranja
	{  'name'=> 'ESTADO DE LA BATERIA',   'oid'=>'PowerNet-MIB::upsBasicBatteryStatus.0', 'subtype'=>'apc_bat_status', 'class'=>'APC', 'vlabel'=>'estado', 'include'=>'1', 'items'=>'batteryNormal(2)|unknown(1)|batteryInFaultCondition(4)|batteryLow(3)', 'esp'=>'MAP(2)(1,0,0,0)|MAP(1)(0,1,0,0,)|MAP(4)(0,0,1,0,)|MAP(3)(0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.APC' },


#PowerNet-MIB::upsAdvBatteryTemperature
#upsAdvBatteryTemperature OBJECT-TYPE
#  -- FROM       PowerNet-MIB
#  SYNTAX        Gauge32
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "The current internal UPS temperature expressed in
#       Celsius."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) apc(318) products(1) hardware(1) ups(1) upsBattery(2) upsAdvBattery(2) 2 }

   {  'name'=> 'TEMPERATURA INTERNA',  'oid'=>'PowerNet-MIB::upsAdvBatteryTemperature.0', 'subtype'=>'apc_temperature', 'class'=>'APC', 'vlabel'=>'grados', 'include'=>1, 'items'=>'Temperatura (Celsius)', 'itil_type' => 1, 'apptype'=>'HW.APC', 'mtype'=>'STD_AREA' },


#PowerNet-MIB::upsAdvBatteryActualVoltage.0
#upsAdvBatteryActualVoltage OBJECT-TYPE
#  -- FROM       PowerNet-MIB
#  SYNTAX        INTEGER
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "The actual battery bus voltage in Volts."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) apc(318) products(1) hardware(1) ups(1) upsBattery(2) upsAdvBattery(2) upsAdvBatteryActualVoltage(8) 0 }

   {  'name'=> 'VOLTAJE DE LA BATERIA',  'oid'=>'PowerNet-MIB::upsAdvBatteryActualVoltage.0', 'subtype'=>'apc_voltage', 'class'=>'APC', 'vlabel'=>'volts', 'include'=>1, 'items'=>'Voltaje (Voltios)', 'itil_type' => 1, 'apptype'=>'HW.APC', 'mtype'=>'STD_AREA' },


#PowerNet-MIB::upsAdvOutputLoad.0
#upsAdvOutputLoad OBJECT-TYPE
#  -- FROM       PowerNet-MIB
#  SYNTAX        Gauge32
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "The current UPS load expressed in percent
#       of rated capacity."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) apc(318) products(1) hardware(1) ups(1) upsOutput(4) upsAdvOutput(2) upsAdvOutputLoad(3) 0 }

   {  'name'=> 'CARGA DE LA BATERIA',  'oid'=>'PowerNet-MIB::upsAdvOutputLoad.0', 'subtype'=>'apc_load', 'class'=>'APC', 'vlabel'=>'perc', 'include'=>1, 'items'=>'Carga de la UPS (%)', 'itil_type' => 1, 'apptype'=>'HW.APC', 'mtype'=>'STD_AREA' },


#PowerNet-MIB::upsCommStatus.0
#upsCommStatus OBJECT-TYPE
#  -- FROM       PowerNet-MIB
#  SYNTAX        INTEGER {ok(1), noComm(2)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "The status of agent's communication with UPS. "
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) apc(318) products(1) hardware(1) ups(1) upsComm(8) upsCommStatus(1) 0 }

   {  'name'=> 'ESTADO COMUNICACIONES AGENTE UPS',  'oid'=>'PowerNet-MIB::upsCommStatus.0', 'subtype'=>'apc_comm_status', 'class'=>'APC', 'vlabel'=>'estado', 'include'=>'1', 'items'=>'ok(1)|noComm(2)', 'esp'=>'MAP(1)(1,0,0,0)|MAP(3)(0,1,0,0,)|MAP(2)(0,0,1,0,)|MAP(4)(0,0,0,1)', 'itil_type' => 4, 'apptype'=>'HW.APC', 'mtype'=>'STD_SOLID' },

#PowerNet-MIB::upsAdvBatteryRunTimeRemaining.0
#upsAdvBatteryRunTimeRemaining OBJECT-TYPE
#  -- FROM       PowerNet-MIB
#  SYNTAX        TimeTicks
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "The UPS battery run time remaining before battery
#       exhaustion."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) apc(318) products(1) hardware(1) ups(1) upsBattery(2) upsAdvBattery(2) upsAdvBatteryRunTimeRemaining(3) 0 }

   {  'name'=> 'TIEMPO RESTANTE DE LA BATERIA',  'oid'=>'PowerNet-MIB::upsAdvBatteryRunTimeRemaining.0', 'subtype'=>'apc_bat_time', 'class'=>'APC', 'vlabel'=>'min', 'include'=>1, 'items'=>'Tiempo restante operativo (min.)', 'itil_type' => 1, 'apptype'=>'HW.APC', 'mtype'=>'STD_AREA', 'esp'=>'o1/60' },


);

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00318_APC::METRICS_TAB=(

#hh3cDevMFanStatus OBJECT-TYPE
#  -- FROM       HH3C-LswDEVM-MIB
#  SYNTAX        INTEGER {active(1), deactive(2), not-install(3), unsupport(4)}
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   " Fan status: active (1), deactive (2) not installed (3) and unsupported (4)"

#   {  'name'=> 'ESTADO DEL VENTILADOR',  'oid'=>'hh3cDevMFanStatus', 'subtype'=>'h3c_fan_status', 'class'=>'H3C', 'range'=>'HH3C-LswDEVM-MIB::hh3cdevMFanStatusTable', 'vlabel'=>'estado', 'get_iid'=>'hh3cDevMFanNum', 'include'=>'1', 'items'=>'active|deactive|not installed|unsupported',
#'esp'=>'MAP(1)(1,0,0,0)|MAP(2)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(4)(0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 1, 'apptype'=>'NET.H3C'
#},


#HH3C-LswDEVM-MIB::hh3cDevMPowerStatus
#hh3cDevMPowerStatus OBJECT-TYPE
#  -- FROM       HH3C-LswDEVM-MIB
#  SYNTAX        INTEGER {active(1), deactive(2), not-install(3), unsupport(4)}
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   " Power status: active (1), deactive (2) not installed (3) and unsupported    "


#   {  'name'=> 'ESTADO DE LA FUENTE',  'oid'=>'hh3cDevMPowerStatus', 'subtype'=>'h3c_power_status', 'class'=>'H3C', 'range'=>'HH3C-LswDEVM-MIB::hh3cdevMPowerStatusTable', 'get_iid'=>'hh3cDevMPowerNum', 'mtype'=>'STD_SOLID', 'itil_type'=>1, 
#'esp'=>'MAP(1)(1,0,0,0)|MAP(2)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(4)(0,0,0,1)', 'items'=>'active|deactive|not installed|unsupported', 'apptype'=>'NET.H3C'
#},

#HH3C-LSW-DEV-ADM-MIB::hh3cLswSlotCpuRatio
#hh3cLswSlotCpuRatio OBJECT-TYPE
#  -- FROM       HH3C-LSW-DEV-ADM-MIB
#  SYNTAX        INTEGER
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   "CPU usage of the slot in accuracy of 1%, and the range of value is 1 to 100."

#	{	'name'=> 'USO DE CPU EN SLOT',  'oid'=>'hh3cLswSlotCpuRatio', 'subtype'=>'h3c_cpu_usage_slot', 'class'=>'H3C', 'range'=>'HH3C-LSW-DEV-ADM-MIB::hh3cLswSlotTable', 'get_iid'=>'hh3cLswSlotDesc', 'mtype'=>'STD_AREA', 'itil_type' => 1, 'items'=>'Uso de CPU (%)', 'apptype'=>'NET.H3C' },


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
@ENT_00318_APC::REMOTE_ALERTS=(

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
