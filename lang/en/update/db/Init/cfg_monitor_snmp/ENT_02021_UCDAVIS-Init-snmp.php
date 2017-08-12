<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_mem_swap',
		'descr' => 'MEMORY USAGE (SWAP)',
		'items' => 'memAvailSwap.0|memTotalSwap.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_mem_real',
		'descr' => 'MEMORY USAGE (REAL)',
		'items' => 'memAvailReal.0|memTotalReal.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_mem_buffer',
		'descr' => 'MEMORY USAGE (BUFFER)',
		'items' => 'memShared.0|memBuffer.0|memCached.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_swap',
		'descr' => 'SWAP USAGE',
		'items' => 'ssRawSwapIn.0|ssRawSwapOut.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_io',
		'descr' => 'IO USAGE',
		'items' => 'ssIORawSent.0|ssIORawReceived.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_int',
		'descr' => 'INTERRUPTS USAGE',
		'items' => 'ssRawInterrupts.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cswitches',
		'descr' => 'CONTEXT SWITCHES',
		'items' => 'ssRawContexts.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_soft_irq',
		'descr' => 'SW IRQ CPU TIME(Linux 2.6)',
		'items' => 'ssCpuRawSoftIRQ.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cpu_usage',
		'descr' => 'CPU USAGE (%)',
		'items' => 'ssCpuIdle.0|ssCpuUser.0|ssCpuSystem.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_load3',
		'descr' => 'SYSTEM LOAD',
		'items' => 'Load-1|Load-5|Load-15',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cpu_raw_usage',
		'descr' => 'CPU USAGE raw-1cpu (%)',
		'items' => 'Idle|User|System',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cpu2_raw_usage',
		'descr' => 'CPU USAGE raw-2cpu (%)',
		'items' => 'Idle|User|System',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cpu4_raw_usage',
		'descr' => 'CPU USAGE raw-4cpu (%)',
		'items' => 'Idle|User|System',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cpu8_raw_usage',
		'descr' => 'CPU USAGE raw-8cpu (%)',
		'items' => 'Idle|User|System',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cpu16_raw_usage',
		'descr' => 'CPU USAGE raw-16cpu (%)',
		'items' => 'Idle|User|System',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_disk_acc_bytes',
		'descr' => 'DISK ACCESS (BYTES)',
		'items' => 'diskIONRead|diskIONWritten',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_disk_acc',
		'descr' => 'DISK ACCESS',
		'items' => 'diskIOReads|diskIOWrites',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_lmsensors_temp',
		'descr' => 'TEMPERATURE SENSOR',
		'items' => 'lmTempSensorsValue',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_lmsensors_volt',
		'descr' => 'VOLTAGE SENSOR',
		'items' => 'lmVoltSensorsValue',
	);

?>
