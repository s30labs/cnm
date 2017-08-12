<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_fan_status',
		'descr' => 'COMPAQ FAN STATUS',
		'items' => 'cpqHeThermalSystemFanStatus.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_tmp_status',
		'descr' => 'COMPAQ TEMPERATURE STATUS',
		'items' => 'cpqHeThermalTempStatus.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_cpu_status',
		'descr' => 'COMPAQ CPU TEMPERATURE',
		'items' => 'cpqHeThermalCpuFanStatus.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_os_threads',
		'descr' => 'COMPAQ OS THREADS',
		'items' => 'cpqOsSystemThreads.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_os_context',
		'descr' => 'COMPAQ OS CONTEXT SWITCHES',
		'items' => 'cpqOsSysContextSwitchesPersec.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_os_cpu_queue',
		'descr' => 'COMPAQ OS QUEUE TRHEADS',
		'items' => 'cpqOsSysCpuQueueLength.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_os_processes',
		'descr' => 'COMPAQ OS NUMBER OF PROCESSES',
		'items' => 'cpqOsSysProcesses.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_processor_status',
		'descr' => 'COMPAQ OS PROCESSOR STATUS',
		'items' => 'cpqOsProcessorStatus.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_tcp_errors',
		'descr' => 'COMPAQ OS TCP ERRORS',
		'items' => 'cpqOsTcpConnectionFailures.1',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_powersup_stat',
		'descr' => 'COMPAQ POWER SUPPLY STATUS',
		'items' => 'cpqHeFltTolPowerSupplyCondition',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_powersup_capacity',
		'descr' => 'COMPAQ POWER SUPPLY CAPACITY USED',
		'items' => 'cpqHeFltTolPowerSupplyCapacityUsed',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_cpu_usage',
		'descr' => 'COMPAQ CPU USAGE',
		'items' => 'cpqHoCpuUtilFiveMin',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_disk_usage',
		'descr' => 'COMPAQ DISK USAGE',
		'items' => 'cpqHoFileSysSpaceUsed|cpqHoFileSysSpaceTotal',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_cpu_interrupts',
		'descr' => 'COMPAQ OS INTERRUPTS',
		'items' => 'cpqOsCpuInterruptsPerSec',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_da_log_status',
		'descr' => 'COMPAQ DISK ARRAY LOGICAL STATUS',
		'items' => 'cpqDaLogDrvStatus',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cpq_da_phy_status',
		'descr' => 'COMPAQ DISK ARRAY PHYSICAL STATUS',
		'items' => 'cpqDaPhyDrvStatus',
	);

?>
