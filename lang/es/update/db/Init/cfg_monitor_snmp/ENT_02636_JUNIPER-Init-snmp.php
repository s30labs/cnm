<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_fwdd_cpu',
		'descr' => 'USO DE CPU DEL FWDD',
		'items' => 'jnxFwddMicroKernelCPUUsage.0|jnxFwddRtThreadsCPUUsage.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_fwdd_heap',
		'descr' => 'USO DE HEAP DEL FWDD',
		'items' => 'jnxFwddHeapUsage.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_fwdd_dma',
		'descr' => 'USO DE DMA DEL FWDD',
		'items' => 'jnxFwddDmaMemUsage.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_spu_cpu',
		'descr' => 'USO DE CPU EN SPU',
		'items' => 'jnxJsSPUMonitoringCPUUsage',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_spu_mem',
		'descr' => 'USO DE MEMORIA EN SPU',
		'items' => 'jnxJsSPUMonitoringMemoryUsage',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_spu_ses',
		'descr' => 'SESIONES EN SPU',
		'items' => 'jnxJsSPUMonitoringCurrentFlowSession',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'jun_spu_cp_ses',
		'descr' => 'SESIONES CP EN SPU',
		'items' => 'jnxJsSPUMonitoringCurrentCPSession',
	);

?>
