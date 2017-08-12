<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_fan_status',
		'descr' => 'ESTADO DEL VENTILADOR',
		'items' => 'cpqHeThermalSystemFanStatus.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_tmp_status',
		'descr' => 'TEMPERATURA DEL SISTEMA',
		'items' => 'cpqHeThermalTempStatus.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_cpu_status',
		'descr' => 'TEMPERATURA DE LA CPU',
		'items' => 'cpqHeThermalCpuFanStatus.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_os_threads',
		'descr' => 'THREADS DE SISTEMA OPERATIVO',
		'items' => 'cpqOsSystemThreads.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_os_context',
		'descr' => 'CAMBIOS DE CONTEXTO EN SISTEMA OPERATIVO',
		'items' => 'cpqOsSysContextSwitchesPersec.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_os_cpu_queue',
		'descr' => 'TRHEADS EN COLA DE PROCESO',
		'items' => 'cpqOsSysCpuQueueLength.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_os_processes',
		'descr' => 'NUMERO DE PROCESOS',
		'items' => 'cpqOsSysProcesses.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_processor_status',
		'descr' => 'ESTADO DEL PROCESADOR',
		'items' => 'cpqOsProcessorStatus.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_tcp_errors',
		'descr' => 'ERRORES EN CONEXIONES TCP',
		'items' => 'cpqOsTcpConnectionFailures.1',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_powersup_stat',
		'descr' => 'FUENTE DE ALIMENTACION - ESTADO',
		'items' => 'cpqHeFltTolPowerSupplyCondition',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_powersup_capacity',
		'descr' => 'FUENTE DE ALIMENTACION - POTENCIA EN USO',
		'items' => 'cpqHeFltTolPowerSupplyCapacityUsed',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_cpu_usage',
		'descr' => 'CPU - PORCENTAJE DE USO',
		'items' => 'cpqHoCpuUtilFiveMin',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_disk_usage',
		'descr' => 'USO DE DISCO',
		'items' => 'cpqHoFileSysSpaceUsed|cpqHoFileSysSpaceTotal',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_cpu_interrupts',
		'descr' => 'CPU - INTERRUPCIONES POR SEGUNDO',
		'items' => 'cpqOsCpuInterruptsPerSec',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_da_log_status',
		'descr' => 'ESTADO LOGICO DEL ARRAY DE DISCOS',
		'items' => 'cpqDaLogDrvStatus',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_da_phy_status',
		'descr' => 'ESTADO FISICO DEL ARRAY DE DISCOS',
		'items' => 'cpqDaPhyDrvStatus',
	);

?>
