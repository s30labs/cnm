#---------------------------------------------------------------------------
package ENT_00674_DELL;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_00674_DELL::ENTERPRISE_PREFIX='00674';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_00674_DELL::TABLE_APPS =(

#	'TABLA DE CARACTERISTICAS DE LA FUENTE DE ALIMENTACION' => {
#
#      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
#      'col_widths' => '25.25.25.25.25.25.25.25.25.25.25.25.25.25',
#      'col_sorting' => 'str.str.str.str.str.str.str.str.str.str.str.str.str.str',
#
#		'oid_cols' => 'cpqHeFltTolPowerSupplyChassis_cpqHeFltTolPowerSupplyBay_cpqHeFltTolPowerSupplyPresent_cpqHeFltTolPowerSupplyCondition_cpqHeFltTolPowerSupplyStatus_cpqHeFltTolPowerSupplyMainVoltage_cpqHeFltTolPowerSupplyCapacityUsed_cpqHeFltTolPowerSupplyCapacityMaximum_cpqHeFltTolPowerSupplyRedundant_cpqHeFltTolPowerSupplyModel_cpqHeFltTolPowerSupplySerialNumber_cpqHeFltTolPowerSupplyAutoRev_cpqHeFltTolPowerSupplyHotPlug_cpqHeFltTolPowerSupplyFirmwareRev',
#
#		'oid_last' => 'CPQHLTH-MIB::cpqHeFltTolPowerSupplyTable',
#		'name' => 'COMPAQ - CARACTERISTICAS DE LA FUENTE DE ALIMENTACION',
#		'descr' => 'Muestra la tabla de caracteristicas de las fuentes de alimentacion del servidor',
#		'xml_file' => '00232-COMPAQ-MIB_CPQHLTH_POWER_SUPPLY_TABLE.xml',
#		'params' => '[-n;IP;]',
#		'ipparam' => '[-n;IP;]',
#		'subtype'=>'COMPAQ',
#		'aname'=>'app_compaq_power_supply_table',
#		'range' => 'CPQHLTH-MIB::cpqHeFltTolPowerSupplyTable',
#		'enterprise' => '00232',  #5 CIFRAS !!!!
#		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00232-COMPAQ-MIB_CPQHLTH_POWER_SUPPLY_TABLE.xml -w xml ',
#		'itil_type' => 1,  'apptype'=>'HW.HP',
#	},
#

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00674_DELL::METRICS=(

#	{  'name'=> 'ESTADO DEL VENTILADOR',   'oid'=>'CPQHLTH-MIB::cpqHeThermalSystemFanStatus.0', 'subtype'=>'cpq_fan_status', 'class'=>'COMPAQ', 'itil_type' => 4, 'apptype'=>'HW.HP' },
#	{  'name'=> 'TEMPERATURA DEL SISTEMA',   'oid'=>'CPQHLTH-MIB::cpqHeThermalTempStatus.0', 'subtype'=>'cpq_tmp_status', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
#	{  'name'=> 'TEMPERATURA DE LA CPU',   'oid'=>'CPQHLTH-MIB::cpqHeThermalCpuFanStatus.0', 'subtype'=>'cpq_cpu_status', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
#	{  'name'=> 'THREADS DE SISTEMA OPERATIVO',   'oid'=>'CPQOS-MIB::cpqOsSystemThreads.0', 'subtype'=>'cpq_os_threads', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
#	{  'name'=> 'CAMBIOS DE CONTEXTO EN SISTEMA OPERATIVO',   'oid'=>'CPQOS-MIB::cpqOsSysContextSwitchesPersec.0', 'subtype'=>'cpq_os_context', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
#	{  'name'=> 'TRHEADS EN COLA DE PROCESO',   'oid'=>'CPQOS-MIB::cpqOsSysCpuQueueLength.0', 'subtype'=>'cpq_os_cpu_queue', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
#	{  'name'=> 'NUMERO DE PROCESOS',   'oid'=>'CPQOS-MIB::cpqOsSysProcesses.0', 'subtype'=>'cpq_os_processes', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
#	{  'name'=> 'ESTADO DEL PROCESADOR',   'oid'=>'CPQOS-MIB::cpqOsProcessorStatus.0', 'subtype'=>'cpq_processor_status', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
#	{  'name'=> 'ERRORES EN CONEXIONES TCP',   'oid'=>'CPQOS-MIB::cpqOsTcpConnectionFailures.1', 'subtype'=>'cpq_tcp_errors', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid NO DEBE IR CUALIFICADO !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00674_DELL::METRICS_TAB=(

#  SYNTAX        INTEGER { other(1), unknown(2), ok(3), nonCritical(4), critical(5), nonRecoverable(6) }
   {  'name'=> 'FUENTE DE ALIMENTACION - ESTADO',   'oid'=>'MIB-Dell-10892::powerSupplyStatus', 'subtype'=>'dell_powersup_stat', 'class'=>'DELL', 'range'=>'MIB-Dell-10892::powerSupplyTable', 'vlabel'=>'estado', 'get_iid'=>'powerSupplyLocationName', 'include'=>'0', 'items'=>'Full(8)|Loading(7)|Down(1)|Attempt(2)|Init(3)|2W(4)|ExchSt(5)|Exch(6)', 'esp'=>'MAP(8)(1,0,0,0,0,0,0,0)|MAP(7)(0,1,0,0,0,0,0,0)|MAP(1)(0,0,1,0,0,0,0,0)|MAP(2)(0,0,0,1,0,0,0,0)|MAP(3)(0,0,0,0,1,0,0,0)|MAP(4)(0,0,0,0,0,1,0,0)|MAP(5)(0,0,0,0,0,0,1,0)|MAP(6)(0,0,0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.DELL' },

#{ other(1), unknown(2), ok(3), nonCritical(4), critical(5), nonRecoverable(6) }
# El orden en itms => verde|azul|rojo|naranja
# ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)
   {  'name'=> 'FUENTE DE ALIMENTACION - ESTADO GLOBAL',   'oid'=>'MIB-Dell-10892::systemStatePowerSupplyStatusCombined', 'subtype'=>'dell_powersup_gstat', 'class'=>'DELL', 'range'=>'MIB-Dell-10892::systemStateTable', 'vlabel'=>'estado', 'get_iid'=>'systemStatechassisIndex', 'include'=>'0', 'items'=>'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)', 'esp'=>'MAP(3)(0,0,0,0,0,1)|MAP(2)(0,0,0,0,1,0)|MAP(5)(0,0,0,1,0,0)|MAP(4)(0,0,1,0,0,0)|MAP(6)(0,1,0,0,0,0)|MAP(1)(1,0,0,0,0,0)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.DELL' },

   {  'name'=> 'VOLTAJE - ESTADO GLOBAL',   'oid'=>'MIB-Dell-10892::systemStateVoltageStatusCombined', 'subtype'=>'dell_volt_gstat', 'class'=>'DELL', 'range'=>'MIB-Dell-10892::systemStateTable', 'vlabel'=>'estado', 'get_iid'=>'systemStatechassisIndex', 'include'=>'0', 'items'=>'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)', 'esp'=>'MAP(3)(0,0,0,0,0,1)|MAP(2)(0,0,0,0,1,0)|MAP(5)(0,0,0,1,0,0)|MAP(4)(0,0,1,0,0,0)|MAP(6)(0,1,0,0,0,0)|MAP(1)(1,0,0,0,0,0)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.DELL' },

   {  'name'=> 'VENTILADORES - ESTADO GLOBAL',   'oid'=>'MIB-Dell-10892::systemStateCoolingDeviceStatusCombined', 'subtype'=>'dell_coold_gstat', 'class'=>'DELL', 'range'=>'MIB-Dell-10892::systemStateTable', 'vlabel'=>'estado', 'get_iid'=>'systemStatechassisIndex', 'include'=>'0', 'items'=>'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)', 'esp'=>'MAP(3)(0,0,0,0,0,1)|MAP(2)(0,0,0,0,1,0)|MAP(5)(0,0,0,1,0,0)|MAP(4)(0,0,1,0,0,0)|MAP(6)(0,1,0,0,0,0)|MAP(1)(1,0,0,0,0,0)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.DELL' },

   {  'name'=> 'TEMPERATURA - ESTADO GLOBAL',   'oid'=>'MIB-Dell-10892::systemStateTemperatureStatusCombined', 'subtype'=>'dell_temp_gstat', 'class'=>'DELL', 'range'=>'MIB-Dell-10892::systemStateTable', 'vlabel'=>'estado', 'get_iid'=>'systemStatechassisIndex', 'include'=>'0', 'items'=>'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)', 'esp'=>'MAP(3)(0,0,0,0,0,1)|MAP(2)(0,0,0,0,1,0)|MAP(5)(0,0,0,1,0,0)|MAP(4)(0,0,1,0,0,0)|MAP(6)(0,1,0,0,0,0)|MAP(1)(1,0,0,0,0,0)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.DELL' },

   {  'name'=> 'MEMORIA - ESTADO GLOBAL',   'oid'=>'MIB-Dell-10892::systemStateMemoryDeviceStatusCombined', 'subtype'=>'dell_memory_gstat', 'class'=>'DELL', 'range'=>'MIB-Dell-10892::systemStateTable', 'vlabel'=>'estado', 'get_iid'=>'systemStatechassisIndex', 'include'=>'0', 'items'=>'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)', 'esp'=>'MAP(3)(0,0,0,0,0,1)|MAP(2)(0,0,0,0,1,0)|MAP(5)(0,0,0,1,0,0)|MAP(4)(0,0,1,0,0,0)|MAP(6)(0,1,0,0,0,0)|MAP(1)(1,0,0,0,0,0)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.DELL' },

   {  'name'=> 'INTRUSION CHASIS - ESTADO GLOBAL',   'oid'=>'MIB-Dell-10892::systemStateChassisIntrusionStatusCombined', 'subtype'=>'dell_chasis_gstat', 'class'=>'DELL', 'range'=>'MIB-Dell-10892::systemStateTable', 'vlabel'=>'estado', 'get_iid'=>'systemStatechassisIndex', 'include'=>'0', 'items'=>'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)', 'esp'=>'MAP(3)(0,0,0,0,0,1)|MAP(2)(0,0,0,0,1,0)|MAP(5)(0,0,0,1,0,0)|MAP(4)(0,0,1,0,0,0)|MAP(6)(0,1,0,0,0,0)|MAP(1)(1,0,0,0,0,0)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.DELL' },

   {  'name'=> 'POTENCIA - ESTADO GLOBAL',   'oid'=>'MIB-Dell-10892::systemStatePowerUnitStatusCombined', 'subtype'=>'dell_power_gstat', 'class'=>'DELL', 'range'=>'MIB-Dell-10892::systemStateTable', 'vlabel'=>'estado', 'get_iid'=>'systemStatechassisIndex', 'include'=>'0', 'items'=>'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)', 'esp'=>'MAP(3)(0,0,0,0,0,1)|MAP(2)(0,0,0,0,1,0)|MAP(5)(0,0,0,1,0,0)|MAP(4)(0,0,1,0,0,0)|MAP(6)(0,1,0,0,0,0)|MAP(1)(1,0,0,0,0,0)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.DELL' },

   {  'name'=> 'VENTILACION - ESTADO GLOBAL',   'oid'=>'MIB-Dell-10892::systemStateCoolingUnitStatusCombined', 'subtype'=>'dell_coolu_gstat', 'class'=>'DELL', 'range'=>'MIB-Dell-10892::systemStateTable', 'vlabel'=>'estado', 'get_iid'=>'systemStatechassisIndex', 'include'=>'0', 'items'=>'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)', 'esp'=>'MAP(3)(0,0,0,0,0,1)|MAP(2)(0,0,0,0,1,0)|MAP(5)(0,0,0,1,0,0)|MAP(4)(0,0,1,0,0,0)|MAP(6)(0,1,0,0,0,0)|MAP(1)(1,0,0,0,0,0)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.DELL' },

   {  'name'=> 'PROCESADOR - ESTADO GLOBAL',   'oid'=>'MIB-Dell-10892::systemStateProcessorDeviceStatusCombined', 'subtype'=>'dell_proc_gstat', 'class'=>'DELL', 'range'=>'MIB-Dell-10892::systemStateTable', 'vlabel'=>'estado', 'get_iid'=>'systemStatechassisIndex', 'include'=>'0', 'items'=>'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)', 'esp'=>'MAP(3)(0,0,0,0,0,1)|MAP(2)(0,0,0,0,1,0)|MAP(5)(0,0,0,1,0,0)|MAP(4)(0,0,1,0,0,0)|MAP(6)(0,1,0,0,0,0)|MAP(1)(1,0,0,0,0,0)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.DELL' },

   {  'name'=> 'BATERIA - ESTADO GLOBAL',   'oid'=>'MIB-Dell-10892::systemStateBatteryStatusCombined', 'subtype'=>'dell_battery_gstat', 'class'=>'DELL', 'range'=>'MIB-Dell-10892::systemStateTable', 'vlabel'=>'estado', 'get_iid'=>'systemStatechassisIndex', 'include'=>'0', 'items'=>'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)', 'esp'=>'MAP(3)(0,0,0,0,0,1)|MAP(2)(0,0,0,0,1,0)|MAP(5)(0,0,0,1,0,0)|MAP(4)(0,0,1,0,0,0)|MAP(6)(0,1,0,0,0,0)|MAP(1)(1,0,0,0,0,0)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.DELL' },

#{ready(1), failed(2), online(3), offline(4), degraded(6), recovering(7), removed(11), resynching(15), rebuild(24), noMedia(25), formatting(26), diagnostics(28), predictiveFailure(34), initializing(35), foreign(39), clear(40), unsupported(41), incompatible(53)}
   {  'name'=> 'ARRAY DE DISCOS - ESTADO DISCO',   'oid'=>'StorageManagement-MIB::arrayDiskState', 'subtype'=>'dell_adisk_stat', 'class'=>'DELL', 'range'=>'StorageManagement-MIB::arrayDiskTable', 'vlabel'=>'estado', 'get_iid'=>'arrayDiskName', 'include'=>'0', 'items'=>'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)', 'esp'=>'MAP(3)(0,0,0,0,0,1)|MAP(2)(0,0,0,0,1,0)|MAP(5)(0,0,0,1,0,0)|MAP(4)(0,0,1,0,0,0)|MAP(6)(0,1,0,0,0,0)|MAP(1)(1,0,0,0,0,0)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.DELL' },

#{ready(1), failed(2), online(3), offline(4), degraded(6)}
#ready(1)|offline(4)|failed(2)|degraded(6)|online(3)
   {  'name'=> 'ARRAY DE DISCOS - ESTADO CONTROLADOR',   'oid'=>'StorageManagement-MIB::controllerState', 'subtype'=>'dell_adisk_cstat', 'class'=>'DELL', 'range'=>'StorageManagement-MIB::controllerTable', 'vlabel'=>'estado', 'get_iid'=>'controllerNumber', 'include'=>'0', 'items'=>'ready(1)|offline(4)|failed(2)|degraded(6)|online(3)', 'esp'=>'MAP(1)(0,0,0,0,1)|MAP(4)(0,0,0,1,0)|MAP(2)(0,0,1,0,0)|MAP(6)(0,1,0,0,0)|MAP(3)(1,0,0,0,0)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.DELL' },

##SSORO4A@spectrum$ snmpwalk -v 2c -c CCMRO 10.64.121.6 StorageManagement-MIB::arrayDiskTable
#StorageManagement-MIB::arrayDiskNumber.1 = INTEGER: 1
#StorageManagement-MIB::arrayDiskNumber.2 = INTEGER: 2
#StorageManagement-MIB::arrayDiskName.1 = STRING: "Physical Disk 0:0:0"
#StorageManagement-MIB::arrayDiskName.2 = STRING: "Physical Disk 0:0:1"
#StorageManagement-MIB::arrayDiskVendor.1 = STRING: "DELL    "
#StorageManagement-MIB::arrayDiskVendor.2 = STRING: "DELL    "
#StorageManagement-MIB::arrayDiskState.1 = INTEGER: online(3)
#StorageManagement-MIB::arrayDiskState.2 = INTEGER: online(3)
#StorageManagement-MIB::arrayDiskProductID.1 = STRING: "HUS153073VLS300 "
#StorageManagement-MIB::arrayDiskProductID.2 = STRING: "HUS153073VLS300 "
#StorageManagement-MIB::arrayDiskSerialNo.1 = STRING: "J2VHZHMC            "
#StorageManagement-MIB::arrayDiskSerialNo.2 = STRING: "J2VJT7RC            "
#StorageManagement-MIB::arrayDiskRevision.1 = STRING: "A280"
#StorageManagement-MIB::arrayDiskRevision.2 = STRING: "A280"
#StorageManagement-MIB::arrayDiskEnclosureID.1 = STRING: "0"
#StorageManagement-MIB::arrayDiskEnclosureID.2 = STRING: "0"
#StorageManagement-MIB::arrayDiskChannel.1 = INTEGER: 0
#StorageManagement-MIB::arrayDiskChannel.2 = INTEGER: 0
#StorageManagement-MIB::arrayDiskLengthInMB.1 = INTEGER: 68664
#StorageManagement-MIB::arrayDiskLengthInMB.2 = INTEGER: 68664
#StorageManagement-MIB::arrayDiskLengthInBytes.1 = INTEGER: 0
#StorageManagement-MIB::arrayDiskLengthInBytes.2 = INTEGER: 0
#StorageManagement-MIB::arrayDiskLargestContiguousFreeSpaceInMB.1 = INTEGER: 0
#StorageManagement-MIB::arrayDiskLargestContiguousFreeSpaceInMB.2 = INTEGER: 0
#StorageManagement-MIB::arrayDiskLargestContiguousFreeSpaceInBytes.1 = INTEGER: 0
#StorageManagement-MIB::arrayDiskLargestContiguousFreeSpaceInBytes.2 = INTEGER: 0
#StorageManagement-MIB::arrayDiskTargetID.1 = INTEGER: 0
#StorageManagement-MIB::arrayDiskTargetID.2 = INTEGER: 1
#StorageManagement-MIB::arrayDiskLunID.1 = INTEGER: 0
#StorageManagement-MIB::arrayDiskLunID.2 = INTEGER: 0
#StorageManagement-MIB::arrayDiskUsedSpaceInMB.1 = INTEGER: 68664
#StorageManagement-MIB::arrayDiskUsedSpaceInMB.2 = INTEGER: 68664
#StorageManagement-MIB::arrayDiskUsedSpaceInBytes.1 = INTEGER: 0
#StorageManagement-MIB::arrayDiskUsedSpaceInBytes.2 = INTEGER: 0
#StorageManagement-MIB::arrayDiskFreeSpaceInMB.1 = INTEGER: 0
#StorageManagement-MIB::arrayDiskFreeSpaceInMB.2 = INTEGER: 0
#StorageManagement-MIB::arrayDiskFreeSpaceInBytes.1 = INTEGER: 0
#StorageManagement-MIB::arrayDiskFreeSpaceInBytes.2 = INTEGER: 0
#StorageManagement-MIB::arrayDiskBusType.1 = INTEGER: sas(8)
#StorageManagement-MIB::arrayDiskBusType.2 = INTEGER: sas(8)
#StorageManagement-MIB::arrayDiskSpareState.1 = INTEGER: notASpare(5)
#StorageManagement-MIB::arrayDiskSpareState.2 = INTEGER: notASpare(5)
#StorageManagement-MIB::arrayDiskRollUpStatus.1 = INTEGER: ok(3)
#StorageManagement-MIB::arrayDiskRollUpStatus.2 = INTEGER: ok(3)
#StorageManagement-MIB::arrayDiskComponentStatus.1 = INTEGER: ok(3)
#StorageManagement-MIB::arrayDiskComponentStatus.2 = INTEGER: ok(3)
#StorageManagement-MIB::arrayDiskNexusID.1 = STRING: "\\0\\0\\0\\0"
#StorageManagement-MIB::arrayDiskNexusID.2 = STRING: "\\0\\0\\0\\1"
#StorageManagement-MIB::arrayDiskPartNumber.1 = STRING: "SG0MM406125687BU0RR5A00 "
#StorageManagement-MIB::arrayDiskPartNumber.2 = STRING: "SG0MM406125687BU0RR1A00 "
#StorageManagement-MIB::arrayDiskSASAddress.1 = STRING: "5000CCA0051D104D"
#StorageManagement-MIB::arrayDiskSASAddress.2 = STRING: "5000CCA0051E83DD"
#StorageManagement-MIB::arrayDiskNegotiatedSpeed.1 = INTEGER: 3072
#StorageManagement-MIB::arrayDiskNegotiatedSpeed.2 = INTEGER: 3072
#StorageManagement-MIB::arrayDiskCapableSpeed.1 = INTEGER: 3072
#StorageManagement-MIB::arrayDiskCapableSpeed.2 = INTEGER: 3072
#StorageManagement-MIB::arrayDiskSmartAlertIndication.1 = INTEGER: no(1)
#StorageManagement-MIB::arrayDiskSmartAlertIndication.2 = INTEGER: no(1)
#StorageManagement-MIB::arrayDiskManufactureDay.1 = STRING: "06"
#StorageManagement-MIB::arrayDiskManufactureDay.2 = STRING: "06"
#StorageManagement-MIB::arrayDiskManufactureWeek.1 = STRING: "48"
#StorageManagement-MIB::arrayDiskManufactureWeek.2 = STRING: "48"
#StorageManagement-MIB::arrayDiskManufactureYear.1 = STRING: "2007"
#StorageManagement-MIB::arrayDiskManufactureYear.2 = STRING: "2007"
#StorageManagement-MIB::arrayDiskEntry.35.1 = INTEGER: 2
#StorageManagement-MIB::arrayDiskEntry.35.2 = INTEGER: 2
#StorageManagement-MIB::arrayDiskEntry.36.1 = INTEGER: 1
#StorageManagement-MIB::arrayDiskEntry.36.2 = INTEGER: 1
#StorageManagement-MIB::arrayDiskEntry.40.1 = INTEGER: 0
#StorageManagement-MIB::arrayDiskEntry.40.2 = INTEGER: 0
#StorageManagement-MIB::arrayDiskEntry.41.1 = INTEGER: 0
#StorageManagement-MIB::arrayDiskEntry.41.2 = INTEGER: 0
#
#controllerTable
#StorageManagement-MIB::controllerNumber.1 = INTEGER: 1
#StorageManagement-MIB::controllerName.1 = STRING: "SAS 6/iR Integrated"
#StorageManagement-MIB::controllerVendor.1 = STRING: "DELL"
#StorageManagement-MIB::controllerType.1 = INTEGER: sas(6)
#StorageManagement-MIB::controllerState.1 = INTEGER: degraded(6)
#


);


1;
__END__
