#---------------------------------------------------------------------------
package ENT_02021_UCDAVIS;

#Incluye LM-SENSORS-MIB
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_02021_UCDAVIS::ENTERPRISE_PREFIX='02021';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_02021_UCDAVIS::TABLE_APPS =(

#	'TABLA DE CARACTERISTICAS DE LA FUENTE DE ALIMENTACION' => {
#		'oid_cols' => 'cpqHeFltTolPowerSupplyChassis_cpqHeFltTolPowerSupplyBay_cpqHeFltTolPowerSupplyPresent_cpqHeFltTolPowerSupplyCondition_cpqHeFltTolPowerSupplyStatus_cpqHeFltTolPowerSupplyMainVoltage_cpqHeFltTolPowerSupplyCapacityUsed_cpqHeFltTolPowerSupplyCapacityMaximum_cpqHeFltTolPowerSupplyRedundant_cpqHeFltTolPowerSupplyModel_cpqHeFltTolPowerSupplySerialNumber_cpqHeFltTolPowerSupplyAutoRev_cpqHeFltTolPowerSupplyHotPlug_cpqHeFltTolPowerSupplyFirmwareRev',
#
#			'oid_last' => 'CPQHLTH-MIB::cpqHeFltTolPowerSupplyTable',
#			'name' => 'COMPAQ - CARACTERISTICAS DE LA FUENTE DE ALIMENTACION',
#			'descr' => 'Muestra la tabla de caracteristicas de las fuentes de alimentacion del servidor',
#			'xml_file' => '00232-COMPAQ-MIB_CPQHLTH_POWER_SUPPLY_TABLE.xml',
#			'params' => '[-n;IP;]',
#			'ipparam' => '[-n;IP;]',
#			'subtype'=>'COMPAQ',
#			'aname'=>'app_compaq_power_supply_table',
#			'range' => 'CPQHLTH-MIB::cpqHeFltTolPowerSupplyTable',
#			'enterprise' => '00232',  #5 CIFRAS !!!!
#			'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00232-COMPAQ-MIB_CPQHLTH_POWER_SUPPLY_TABLE.xml -w xml ',
#	},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_02021_UCDAVIS::METRICS=(

#UCD-SNMP-MIB::memIndex.0 = INTEGER: 0
#UCD-SNMP-MIB::memErrorName.0 = STRING: swap
#UCD-SNMP-MIB::memTotalSwap.0 = INTEGER: 1048572
#UCD-SNMP-MIB::memAvailSwap.0 = INTEGER: 0
#UCD-SNMP-MIB::memTotalReal.0 = INTEGER: 503609340
#UCD-SNMP-MIB::memAvailReal.0 = INTEGER: 1855088
#UCD-SNMP-MIB::memTotalFree.0 = INTEGER: 1855088
#UCD-SNMP-MIB::memMinimumSwap.0 = INTEGER: 16000
#UCD-SNMP-MIB::memShared.0 = INTEGER: 7139372
#UCD-SNMP-MIB::memBuffer.0 = INTEGER: 21568
#UCD-SNMP-MIB::memCached.0 = INTEGER: 36900104
#UCD-SNMP-MIB::memSwapError.0 = INTEGER: 1
#UCD-SNMP-MIB::memSwapErrorMsg.0 = STRING: Running out of swap space (0)

# ( ((memTotalFree + memBuffer + memCache) / memTotalReal) ) * 100
   {  'name'=> 'MEMORIA DISPONIBLE EN SO LINUX (%)',   'oid'=>'UCD-SNMP-MIB::memTotalFree.0|UCD-SNMP-MIB::memBuffer.0|UCD-SNMP-MIB::memCached.0|UCD-SNMP-MIB::memTotalReal.0', 'subtype'=>'ucd_mem_linux', 'class'=>'UCDAVIS', 'include'=>1, 'esp'=>'100*(o1+o2+o3)/o4',  'vlabel'=>'Percent', 'items'=>'Memory available', 'itil_type' => 4, 'apptype'=>'SO.UCDAVIS' },

	{  'name'=> 'USO DE MEMORIA (SWAP)',   'oid'=>'UCD-SNMP-MIB::memAvailSwap.0|UCD-SNMP-MIB::memTotalSwap.0', 'subtype'=>'ucd_mem_swap', 'class'=>'UCDAVIS', 'include'=>1, 'esp'=>'o1*1024|o2*1024', 'apptype'=>'SO.UCDAVIS' },
	{  'name'=> 'USO DE MEMORIA (REAL)',   'oid'=>'UCD-SNMP-MIB::memAvailReal.0|UCD-SNMP-MIB::memTotalReal.0', 'subtype'=>'ucd_mem_real', 'class'=>'UCDAVIS', 'include'=>1, 'esp'=>'o1*1024|o2*1024', 'apptype'=>'SO.UCDAVIS' },
	{  'name'=> 'USO DE MEMORIA (BUFFER)',   'oid'=>'UCD-SNMP-MIB::memShared.0|UCD-SNMP-MIB::memBuffer.0|UCD-SNMP-MIB::memCached.0', 'subtype'=>'ucd_mem_buffer', 'class'=>'UCDAVIS', 'include'=>1, 'esp'=>'o1*1024|o2*1024|o3*1024', 'apptype'=>'SO.UCDAVIS' },

	{  'name'=> 'USO DE SWAP',   'oid'=>'UCD-SNMP-MIB::ssRawSwapIn.0|UCD-SNMP-MIB::ssRawSwapOut.0', 'subtype'=>'ucd_swap', 'class'=>'UCDAVIS', 'include'=>1, 'apptype'=>'SO.UCDAVIS' },
	{  'name'=> 'USO DE IO',   'oid'=>'UCD-SNMP-MIB::ssIORawSent.0|UCD-SNMP-MIB::ssIORawReceived.0', 'subtype'=>'ucd_io', 'class'=>'UCDAVIS', 'include'=>1, 'apptype'=>'SO.UCDAVIS' },
	{  'name'=> 'USO DE INTERRUPCIONES',   'oid'=>'UCD-SNMP-MIB::ssRawInterrupts.0', 'subtype'=>'ucd_int', 'class'=>'UCDAVIS', 'include'=>1, 'apptype'=>'SO.UCDAVIS' },
	{  'name'=> 'CAMBIOS DE CONTEXTO',   'oid'=>'UCD-SNMP-MIB::ssRawContexts.0', 'subtype'=>'ucd_cswitches', 'class'=>'UCDAVIS', 'include'=>1, 'apptype'=>'SO.UCDAVIS' },
	{  'name'=> 'TIEMPO DE CPU DE IRQ SW (Linux 2.6)',   'oid'=>'UCD-SNMP-MIB::ssCpuRawSoftIRQ.0', 'subtype'=>'ucd_soft_irq', 'class'=>'UCDAVIS', 'include'=>0, 'apptype'=>'SO.UCDAVIS' },
	{  'name'=> 'USO DE CPU (%)',   'oid'=>'UCD-SNMP-MIB::ssCpuIdle.0|UCD-SNMP-MIB::ssCpuUser.0|UCD-SNMP-MIB::ssCpuSystem.0', 'subtype'=>'ucd_cpu_usage', 'class'=>'UCDAVIS', 'include'=>1, 'apptype'=>'SO.UCDAVIS' },
	{  'name'=> 'CARGA DEL SISTEMA',   'oid'=>'UCD-SNMP-MIB::laLoad.1|UCD-SNMP-MIB::laLoad.2|UCD-SNMP-MIB::laLoad.3', 'subtype'=>'ucd_load3', 'class'=>'UCDAVIS', 'include'=>1, 'apptype'=>'SO.UCDAVIS', 'items'=>'Load-1|Load-5|Load-15' },

#Se dividen por 1/num_cpus. Realmente el calculo es: 100/lapse*num_ticks*num_cpu
#La division por lapse es interna
#num_ticks es 100 en los linux. Se valida haciendo ejecutando: getconf CLK_TCK
#Por eso queda 1/num_cpus
	{  'name'=> 'USO DE CPU raw-1cpu (%)',   'oid'=>'UCD-SNMP-MIB::ssCpuRawIdle.0|UCD-SNMP-MIB::ssCpuRawUser.0|UCD-SNMP-MIB::ssCpuRawSystem.0', 'subtype'=>'ucd_cpu_raw_usage', 'class'=>'UCDAVIS', 'include'=>0,
'esp'=>'1*o1|1*o2|1*o3', 'items'=>'Idle|User|System', 'apptype'=>'SO.UCDAVIS'
 },

   {  'name'=> 'USO DE CPU raw-2cpu (%)',   'oid'=>'UCD-SNMP-MIB::ssCpuRawIdle.0|UCD-SNMP-MIB::ssCpuRawUser.0|UCD-SNMP-MIB::ssCpuRawSystem.0', 'subtype'=>'ucd_cpu2_raw_usage', 'class'=>'UCDAVIS', 'include'=>0,
'esp'=>'(1/2)*o1|(1/2)*o2|(1/2)*o3', 'items'=>'Idle|User|System', 'apptype'=>'SO.UCDAVIS'
 },

   {  'name'=> 'USO DE CPU raw-4cpu (%)',   'oid'=>'UCD-SNMP-MIB::ssCpuRawIdle.0|UCD-SNMP-MIB::ssCpuRawUser.0|UCD-SNMP-MIB::ssCpuRawSystem.0', 'subtype'=>'ucd_cpu4_raw_usage', 'class'=>'UCDAVIS', 'include'=>0,
'esp'=>'(1/4)*o1|(1/4)*o2|(1/4)*o3', 'items'=>'Idle|User|System', 'apptype'=>'SO.UCDAVIS'
 },

   {  'name'=> 'USO DE CPU raw-8cpu (%)',   'oid'=>'UCD-SNMP-MIB::ssCpuRawIdle.0|UCD-SNMP-MIB::ssCpuRawUser.0|UCD-SNMP-MIB::ssCpuRawSystem.0', 'subtype'=>'ucd_cpu8_raw_usage', 'class'=>'UCDAVIS', 'include'=>0,
'esp'=>'(1/8)*o1|(1/8)*o2|(1/8)*o3', 'items'=>'Idle|User|System', 'apptype'=>'SO.UCDAVIS'
 },

   {  'name'=> 'USO DE CPU raw-16cpu (%)',   'oid'=>'UCD-SNMP-MIB::ssCpuRawIdle.0|UCD-SNMP-MIB::ssCpuRawUser.0|UCD-SNMP-MIB::ssCpuRawSystem.0', 'subtype'=>'ucd_cpu16_raw_usage', 'class'=>'UCDAVIS', 'include'=>0,
'esp'=>'(1/16)*o1|(1/16)*o2|(1/16)*o3', 'items'=>'Idle|User|System', 'apptype'=>'SO.UCDAVIS'
 },

#UCD-SNMP-MIB::laLoadInt.1 = INTEGER: 7
#UCD-SNMP-MIB::laLoadInt.2 = INTEGER: 3
#UCD-SNMP-MIB::laLoadInt.3 = INTEGER: 4

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid NO DEBE IR CUALIFICADO !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_02021_UCDAVIS::METRICS_TAB=(

# Aunque sea tabla, es mejor meter las tres instancias en una unica metrica de tipo escalar. 
#	{	'name'=> 'CARGA DEL SISTEMA',  'oid'=>'laLoad', 'subtype'=>'ucd_load', 'class'=>'UCDAVIS', 'range'=>'UCD-SNMP-MIB::laTable', 'get_iid'=>'laIndex', 'itil_type'=>1, 'include'=>1, 'apptype'=>'SO.UCDAVIS' },

	{	'name'=> 'ACCESO A DISCO (BYTES)',  'oid'=>'diskIONRead|diskIONWritten', 'subtype'=>'ucd_disk_acc_bytes', 'class'=>'UCDAVIS', 'range'=>'UCD-DISKIO-MIB::diskIOTable', 'get_iid'=>'diskIOIndex', 'itil_type'=>1, 'include'=>0, 'apptype'=>'SO.UCDAVIS' },

	{	'name'=> 'ACCESO A DISCO',  'oid'=>'diskIOReads|diskIOWrites', 'subtype'=>'ucd_disk_acc', 'class'=>'UCDAVIS', 'range'=>'UCD-DISKIO-MIB::diskIOTable', 'get_iid'=>'diskIOIndex', 'itil_type'=>1, 'include'=>0, 'apptype'=>'SO.UCDAVIS' },

	{	'name'=> 'SENSOR DE TEMPERATURA',  'oid'=>'lmTempSensorsValue', 'subtype'=>'ucd_lmsensors_temp', 'class'=>'UCDAVIS-LMSENSORS', 'range'=>'LM-SENSORS-MIB::lmTempSensorsTable', 'get_iid'=>'lmTempSensorsIndex', 'itil_type'=>1, 'include'=>1, 'items'=>'Grados C', 'esp'=>'o1/1000', 'apptype'=>'SO.UCDAVIS' },

	{	'name'=> 'SENSOR DE VOLTAJE',  'oid'=>'lmVoltSensorsValue', 'subtype'=>'ucd_lmsensors_volt', 'class'=>'UCDAVIS-LMSENSORS', 'range'=>'LM-SENSORS-MIB::lmVoltSensorsTable', 'get_iid'=>'lmVoltSensorsIndex', 'itil_type'=>1, 'include'=>1, 'apptype'=>'SO.UCDAVIS' },

);


1;
__END__
