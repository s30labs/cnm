<?
	$TIPS[]=array(
		'id_ref' => 'ucd_mem_swap',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>memAvailSwap.0|memTotalSwap.0</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::memAvailSwap.0 (GAUGE):</strong> "Available Swap Space on the host."
<strong>UCD-SNMP-MIB::memTotalSwap.0 (GAUGE):</strong> "Total Swap Size configured for the host."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_mem_real',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>memAvailReal.0|memTotalReal.0</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::memAvailReal.0 (GAUGE):</strong> "Available Real/Physical Memory Space on the host."
<strong>UCD-SNMP-MIB::memTotalReal.0 (GAUGE):</strong> "Total Real/Physical Memory Size on the host."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_mem_buffer',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>memShared.0|memBuffer.0|memCached.0</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::memShared.0 (GAUGE):</strong> "Total Shared Memory"
<strong>UCD-SNMP-MIB::memBuffer.0 (GAUGE):</strong> "Total Buffered Memory"
<strong>UCD-SNMP-MIB::memCached.0 (GAUGE):</strong> "Total Cached Memory"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_swap',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ssRawSwapIn.0|ssRawSwapOut.0</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::ssRawSwapIn.0 (COUNTER):</strong> "Number of blocks swapped in"
<strong>UCD-SNMP-MIB::ssRawSwapOut.0 (COUNTER):</strong> "Number of blocks swapped out"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_io',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ssIORawSent.0|ssIORawReceived.0</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::ssIORawSent.0 (COUNTER):</strong> "Number of blocks sent to a block device"
<strong>UCD-SNMP-MIB::ssIORawReceived.0 (COUNTER):</strong> "Number of blocks received from a block device"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_int',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ssRawInterrupts.0</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::ssRawInterrupts.0 (COUNTER):</strong> "Number of interrupts processed"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_cswitches',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ssRawContexts.0</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::ssRawContexts.0 (COUNTER):</strong> "Number of context switches"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_soft_irq',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ssCpuRawSoftIRQ.0</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::ssCpuRawSoftIRQ.0 (COUNTER):</strong> "Soft IRQ CPU time. This is for Linux 2.6"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_cpu_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ssCpuIdle.0|ssCpuUser.0|ssCpuSystem.0</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::ssCpuIdle.0 (GAUGE):</strong> "percentages of idle CPU time. Deprecated, replaced by of the
 	ssCpuRawIdle object"
<strong>UCD-SNMP-MIB::ssCpuUser.0 (GAUGE):</strong> "percentages of user CPU time. Deprecated, replaced by the ssCpuRawUser
 	object"
<strong>UCD-SNMP-MIB::ssCpuSystem.0 (GAUGE):</strong> "percentages of system CPU time. Deprecated, replaced by of the
 	ssCpuRawSystem object"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_load3',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Load-1|Load-5|Load-15</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::laLoad.1 (GAUGE):</strong> "The 1,5 and 10 minute load averages (one per row)."
<strong>UCD-SNMP-MIB::laLoad.2 (GAUGE):</strong> "The 1,5 and 10 minute load averages (one per row)."
<strong>UCD-SNMP-MIB::laLoad.3 (GAUGE):</strong> "The 1,5 and 10 minute load averages (one per row)."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_cpu_raw_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Idle|User|System</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::ssCpuRawIdle.0 (COUNTER):</strong> "idle CPU time."
<strong>UCD-SNMP-MIB::ssCpuRawUser.0 (COUNTER):</strong> "user CPU time."
<strong>UCD-SNMP-MIB::ssCpuRawSystem.0 (COUNTER):</strong> "system CPU time."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_cpu2_raw_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Idle|User|System</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::ssCpuRawIdle.0 (COUNTER):</strong> "idle CPU time."
<strong>UCD-SNMP-MIB::ssCpuRawUser.0 (COUNTER):</strong> "user CPU time."
<strong>UCD-SNMP-MIB::ssCpuRawSystem.0 (COUNTER):</strong> "system CPU time."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_cpu4_raw_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Idle|User|System</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::ssCpuRawIdle.0 (COUNTER):</strong> "idle CPU time."
<strong>UCD-SNMP-MIB::ssCpuRawUser.0 (COUNTER):</strong> "user CPU time."
<strong>UCD-SNMP-MIB::ssCpuRawSystem.0 (COUNTER):</strong> "system CPU time."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_cpu8_raw_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Idle|User|System</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::ssCpuRawIdle.0 (COUNTER):</strong> "idle CPU time."
<strong>UCD-SNMP-MIB::ssCpuRawUser.0 (COUNTER):</strong> "user CPU time."
<strong>UCD-SNMP-MIB::ssCpuRawSystem.0 (COUNTER):</strong> "system CPU time."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_cpu16_raw_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Idle|User|System</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::ssCpuRawIdle.0 (COUNTER):</strong> "idle CPU time."
<strong>UCD-SNMP-MIB::ssCpuRawUser.0 (COUNTER):</strong> "user CPU time."
<strong>UCD-SNMP-MIB::ssCpuRawSystem.0 (COUNTER):</strong> "system CPU time."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_disk_acc_bytes',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>diskIONRead|diskIONWritten</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::diskIONRead (GAUGE):</strong> <strong>UCD-SNMP-MIB::diskIONWritten (GAUGE):</strong> ',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_disk_acc',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>diskIOReads|diskIOWrites</strong> a partir de los siguientes atributos de la mib UCD-SNMP-MIB:<br><br><strong>UCD-SNMP-MIB::diskIOReads (GAUGE):</strong> <strong>UCD-SNMP-MIB::diskIOWrites (GAUGE):</strong> ',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_lmsensors_temp',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>lmTempSensorsValue</strong> a partir de los siguientes atributos de la mib LM-SENSORS-MIB:<br><br><strong>LM-SENSORS-MIB::lmTempSensorsValue (GAUGE):</strong> "The temperature of this sensor in mC."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ucd_lmsensors_volt',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>lmVoltSensorsValue</strong> a partir de los siguientes atributos de la mib LM-SENSORS-MIB:<br><br><strong>LM-SENSORS-MIB::lmVoltSensorsValue (GAUGE):</strong> "The voltage in mV."
',
	);

?>
