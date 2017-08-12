#---------------------------------------------------------------------------
package ENT_00232_COMPAQ;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_00232_COMPAQ::ENTERPRISE_PREFIX='00232';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_00232_COMPAQ::TABLE_APPS =(

	'TABLA DE CARACTERISTICAS DE LA FUENTE DE ALIMENTACION' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '25.25.25.25.25.25.25.25.25.25.25.25.25.25',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str.str.str.str.str.str',

		'oid_cols' => 'cpqHeFltTolPowerSupplyChassis_cpqHeFltTolPowerSupplyBay_cpqHeFltTolPowerSupplyPresent_cpqHeFltTolPowerSupplyCondition_cpqHeFltTolPowerSupplyStatus_cpqHeFltTolPowerSupplyMainVoltage_cpqHeFltTolPowerSupplyCapacityUsed_cpqHeFltTolPowerSupplyCapacityMaximum_cpqHeFltTolPowerSupplyRedundant_cpqHeFltTolPowerSupplyModel_cpqHeFltTolPowerSupplySerialNumber_cpqHeFltTolPowerSupplyAutoRev_cpqHeFltTolPowerSupplyHotPlug_cpqHeFltTolPowerSupplyFirmwareRev',

		'oid_last' => 'CPQHLTH-MIB::cpqHeFltTolPowerSupplyTable',
		'name' => 'COMPAQ - CARACTERISTICAS DE LA FUENTE DE ALIMENTACION',
		'descr' => 'Muestra la tabla de caracteristicas de las fuentes de alimentacion del servidor',
		'xml_file' => '00232-COMPAQ-MIB_CPQHLTH_POWER_SUPPLY_TABLE.xml',
		'params' => '[-n;IP;]',
		'ipparam' => '[-n;IP;]',
		'subtype'=>'COMPAQ',
		'aname'=>'app_compaq_power_supply_table',
		'range' => 'CPQHLTH-MIB::cpqHeFltTolPowerSupplyTable',
		'enterprise' => '00232',  #5 CIFRAS !!!!
		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00232-COMPAQ-MIB_CPQHLTH_POWER_SUPPLY_TABLE.xml -w xml ',
		'itil_type' => 1,  'apptype'=>'HW.HP',
	},


   'TABLA DE PROCESOS' => {
	
      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
    	'col_widths' => '25.25.25.25.25.25.25.25.25',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str',

      'oid_cols' => 'cpqOsProcessInstance_cpqOsProcessThreadCount_cpqOsProcessPrivateBytes_cpqOsProcessPageFileBytes_cpqOsProcessWorkingSet_cpqOsProcessCpuTimePercent_cpqOsProcessPrivilegedTimePercent_cpqOsProcessPageFaultsPerSec_cpqOsProcessCondition',

      'oid_last' => 'CPQOS-MIB::cpqOsProcessTable',
      'name' => 'COMPAQ - TABLA DE PROCESOS',
      'descr' => 'Muestra la tabla de procesos del Sistema Operativo',
      'xml_file' => '00232-COMPAQ-MIB_CPQOS_PROCESS_TABLE.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'COMPAQ',
      'aname'=>'app_compaq_processes_table',
      'range' => 'CPQOS-MIB::cpqOsProcessTable',
      'enterprise' => '00232',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00232-COMPAQ-MIB_CPQOS_PROCESS_TABLE.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'HW.HP',
   },


   'TABLA DE USO DE PCI' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '25.25.25.25.25.25',
      'col_sorting' => 'str.str.str.str.str.str',

      'oid_cols' => 'cpqSePciSlotBusNumberIndex_cpqSePciSlotDeviceNumberIndex_cpqSePciPhysSlot_cpqSePciSlotSubSystemID_cpqSePciSlotBoardName_cpqSePciSlotWidth_cpqSePciSlotSpeed',

      'oid_last' => 'CPQSTDEQ-MIB::cpqSePciSlotTable',
      'name' => 'COMPAQ - INFORMACION SOBRE LOS SLOTS PCI',
      'descr' => 'Muestra informacion sobre el uso de los slots PCI definidos en el sistema',
      'xml_file' => '00232-COMPAQ-MIB_CPQSTDEQ_PCI_TABLE.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'COMPAQ',
      'aname'=>'app_compaq_pci_table',
      'range' => 'CPQSTDEQ-MIB::cpqSePciSlotTable',
      'enterprise' => '00232',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00232-COMPAQ-MIB_CPQSTDEQ_PCI_TABLE.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'HW.HP',
   },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00232_COMPAQ::METRICS=(

	{  'name'=> 'ESTADO DEL VENTILADOR',   'oid'=>'CPQHLTH-MIB::cpqHeThermalSystemFanStatus.0', 'subtype'=>'cpq_fan_status', 'class'=>'COMPAQ', 'itil_type' => 4, 'apptype'=>'HW.HP' },
	{  'name'=> 'TEMPERATURA DEL SISTEMA',   'oid'=>'CPQHLTH-MIB::cpqHeThermalTempStatus.0', 'subtype'=>'cpq_tmp_status', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
	{  'name'=> 'TEMPERATURA DE LA CPU',   'oid'=>'CPQHLTH-MIB::cpqHeThermalCpuFanStatus.0', 'subtype'=>'cpq_cpu_status', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
	{  'name'=> 'THREADS DE SISTEMA OPERATIVO',   'oid'=>'CPQOS-MIB::cpqOsSystemThreads.0', 'subtype'=>'cpq_os_threads', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
	{  'name'=> 'CAMBIOS DE CONTEXTO EN SISTEMA OPERATIVO',   'oid'=>'CPQOS-MIB::cpqOsSysContextSwitchesPersec.0', 'subtype'=>'cpq_os_context', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
	{  'name'=> 'TRHEADS EN COLA DE PROCESO',   'oid'=>'CPQOS-MIB::cpqOsSysCpuQueueLength.0', 'subtype'=>'cpq_os_cpu_queue', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
	{  'name'=> 'NUMERO DE PROCESOS',   'oid'=>'CPQOS-MIB::cpqOsSysProcesses.0', 'subtype'=>'cpq_os_processes', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
	{  'name'=> 'ESTADO DEL PROCESADOR',   'oid'=>'CPQOS-MIB::cpqOsProcessorStatus.0', 'subtype'=>'cpq_processor_status', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
	{  'name'=> 'ERRORES EN CONEXIONES TCP',   'oid'=>'CPQOS-MIB::cpqOsTcpConnectionFailures.1', 'subtype'=>'cpq_tcp_errors', 'class'=>'COMPAQ', 'itil_type' => 1, 'apptype'=>'HW.HP' },
#	{  'name'=> 'USO DE CPU (%)',   'oid'=>'', 'subtype'=>'cpq_cpu_status', 'class'=>'COMPAQ' },
	#{  'name'=> 'FALLOS EN DNS',   'oid'=>'ASYNCOS-MAIL-MIB::outstandingDNSRequests.0|ASYNCOS-MAIL-MIB::pendingDNSRequests.0', 'subtype'=>'ironport_dns_failures', 'class'=>'IRONPORT' },
	#{	'name'=> 'MEMORIA ASIGNADA',	'oid'=>'WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0|WINDOWS-NT-PERFORMANCE::memoryCommitLimit.0', 'subtype'=>'winnt_memory_committed_bytes', 'class'=>'WINDOWS-NT'},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid NO DEBE IR CUALIFICADO !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00232_COMPAQ::METRICS_TAB=(

	{	'name'=> 'FUENTE DE ALIMENTACION - ESTADO',  'oid'=>'cpqHeFltTolPowerSupplyCondition', 'subtype'=>'cpq_powersup_stat', 'class'=>'COMPAQ', 'range'=>'CPQHLTH-MIB::cpqHeFltTolPowerSupplyTable', 'get_iid'=>'cpqHeFltTolPowerSupplyBay', 'itil_type' => 4, 'apptype'=>'HW.HP' },
	{	'name'=> 'FUENTE DE ALIMENTACION - POTENCIA EN USO',  'oid'=>'cpqHeFltTolPowerSupplyCapacityUsed', 'subtype'=>'cpq_powersup_capacity', 'class'=>'COMPAQ', 'range'=>'CPQHLTH-MIB::cpqHeFltTolPowerSupplyTable', 'get_iid'=>'cpqHeFltTolPowerSupplyBay', 'itil_type' => 1, 'apptype'=>'HW.HP' },
	{	'name'=> 'CPU - PORCENTAJE DE USO',  'oid'=>'cpqHoCpuUtilFiveMin', 'subtype'=>'cpq_cpu_usage', 'class'=>'COMPAQ', 'range'=>'CPQHOST-MIB::cpqHoCpuUtilTable', 'get_iid'=>'cpqHoCpuUtilUnitIndex', 'itil_type' => 1, 'apptype'=>'HW.HP' },
	{	'name'=> 'USO DE DISCO',  'oid'=>'cpqHoFileSysSpaceUsed|cpqHoFileSysSpaceTotal', 'subtype'=>'cpq_disk_usage', 'class'=>'COMPAQ', 'range'=>'CPQHOST-MIB::cpqHoFileSysTable', 'get_iid'=>'cpqHoFileSysDesc', 'itil_type' => 1, 'apptype'=>'HW.HP' },
	{	'name'=> 'CPU - INTERRUPCIONES POR SEGUNDO',  'oid'=>'cpqOsCpuInterruptsPerSec', 'subtype'=>'cpq_cpu_interrupts', 'class'=>'COMPAQ', 'range'=>'CPQOS-MIB::cpqOsProcessorTable', 'get_iid'=>'cpqOsCpuInstance', 'itil_type' => 1, 'apptype'=>'HW.HP' },
	{	'name'=> 'ESTADO LOGICO DEL ARRAY DE DISCOS',  'oid'=>'cpqDaLogDrvStatus', 'subtype'=>'cpq_da_log_status', 'class'=>'COMPAQ', 'range'=>'CPQIDA-MIB::cpqDaLogDrvTable', 'get_iid'=>'cpqDaLogDrvIndex', 'itil_type' => 4, 'apptype'=>'HW.HP' },
	{	'name'=> 'ESTADO FISICO DEL ARRAY DE DISCOS',  'oid'=>'cpqDaPhyDrvStatus', 'subtype'=>'cpq_da_phy_status', 'class'=>'COMPAQ', 'range'=>'CPQIDA-MIB::cpqDaPhyDrvTable', 'get_iid'=>'cpqDaPhyDrvIndex', 'itil_type' => 4, 'apptype'=>'HW.HP' },

);


1;
__END__
