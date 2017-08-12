<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_mem_swap',
		'descr' => 'USO DE MEMORIA (SWAP)',
		'items' => 'memAvailSwap.0|memTotalSwap.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_mem_real',
		'descr' => 'USO DE MEMORIA (REAL)',
		'items' => 'memAvailReal.0|memTotalReal.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_mem_buffer',
		'descr' => 'USO DE MEMORIA (BUFFER)',
		'items' => 'memShared.0|memBuffer.0|memCached.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_swap',
		'descr' => 'USO DE SWAP',
		'items' => 'ssRawSwapIn.0|ssRawSwapOut.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_io',
		'descr' => 'USO DE IO',
		'items' => 'ssIORawSent.0|ssIORawReceived.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_int',
		'descr' => 'USO DE INTERRUPCIONES',
		'items' => 'ssRawInterrupts.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cswitches',
		'descr' => 'CAMBIOS DE CONTEXTO',
		'items' => 'ssRawContexts.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_soft_irq',
		'descr' => 'TIEMPO DE CPU DE IRQ SW (Linux 2.6)',
		'items' => 'ssCpuRawSoftIRQ.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cpu_usage',
		'descr' => 'USO DE CPU (%)',
		'items' => 'ssCpuIdle.0|ssCpuUser.0|ssCpuSystem.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_load3',
		'descr' => 'CARGA DEL SISTEMA',
		'items' => 'Load-1|Load-5|Load-15',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cpu_raw_usage',
		'descr' => 'USO DE CPU raw-1cpu (%)',
		'items' => 'Idle|User|System',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cpu2_raw_usage',
		'descr' => 'USO DE CPU raw-2cpu (%)',
		'items' => 'Idle|User|System',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cpu4_raw_usage',
		'descr' => 'USO DE CPU raw-4cpu (%)',
		'items' => 'Idle|User|System',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cpu8_raw_usage',
		'descr' => 'USO DE CPU raw-8cpu (%)',
		'items' => 'Idle|User|System',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_cpu16_raw_usage',
		'descr' => 'USO DE CPU raw-16cpu (%)',
		'items' => 'Idle|User|System',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_disk_acc_bytes',
		'descr' => 'ACCESO A DISCO (BYTES)',
		'items' => 'diskIONRead|diskIONWritten',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_disk_acc',
		'descr' => 'ACCESO A DISCO',
		'items' => 'diskIOReads|diskIOWrites',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_lmsensors_temp',
		'descr' => 'SENSOR DE TEMPERATURA',
		'items' => 'lmTempSensorsValue',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucd_lmsensors_volt',
		'descr' => 'SENSOR DE VOLTAJE',
		'items' => 'lmVoltSensorsValue',
	);

?>
