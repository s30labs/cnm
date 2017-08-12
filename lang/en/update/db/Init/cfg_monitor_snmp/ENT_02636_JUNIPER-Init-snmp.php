<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_fwdd_cpu',
		'descr' => 'FWDD CPU USAGE',
		'items' => 'jnxFwddMicroKernelCPUUsage.0|jnxFwddRtThreadsCPUUsage.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_fwdd_heap',
		'descr' => 'FWDD HEAP USAGE',
		'items' => 'jnxFwddHeapUsage.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_fwdd_dma',
		'descr' => 'FWDD DMA MEMORY USAGE',
		'items' => 'jnxFwddDmaMemUsage.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_spu_cpu',
		'descr' => 'SPU CPU USAGE',
		'items' => 'jnxJsSPUMonitoringCPUUsage',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_spu_mem',
		'descr' => 'SPU MEMORY USAGE',
		'items' => 'jnxJsSPUMonitoringMemoryUsage',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_spu_ses',
		'descr' => 'SPU SESSIONS',
		'items' => 'jnxJsSPUMonitoringCurrentFlowSession',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_spu_cp_ses',
		'descr' => 'SPU CP SESSIONS',
		'items' => 'jnxJsSPUMonitoringCurrentCPSession',
	);

?>
