<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortigate_cpu_usage',
		'descr' => 'USO DE CPU (%)',
		'items' => 'fgSysCpuUsage.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortigate_mem_usage',
		'descr' => 'USO DE MEMORIA (%)',
		'items' => 'fgSysMemUsage.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortigate_lowmem_usage',
		'descr' => 'USO DE MEMORIA BAJA (%)',
		'items' => 'fgSysLowMemUsage.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortigate_disk_usage',
		'descr' => 'USO DE DISCO',
		'items' => '::FORTINET-FORTIGATE-MIB:fgSysDiskUsage.0|fgSysDiskCapacity.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortigate_ses_count',
		'descr' => 'NUMERO DE SESIONES ACTIVAS',
		'items' => 'fgSysSesCount.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortigate_pol_traffic',
		'descr' => 'TRAFICO EN POLICY',
		'items' => 'fgFwPolPktCount|fgFwPolByteCount',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortinet_cpu_usage',
		'descr' => 'USO DE CPU',
		'items' => 'fnHaStatsCpuUsage',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortinet_memory_usage',
		'descr' => 'USO DE MEMORIA',
		'items' => 'fnHaStatsMemUsage',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortinet_net_usage',
		'descr' => 'TRAFICO DE RED',
		'items' => 'fnHaStatsNetUsage',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortinet_active_sessions',
		'descr' => 'SESIONES ACTIVAS',
		'items' => 'fnHaStatsSesCount',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortinet_packets',
		'descr' => 'PAQUETES PROCESADOS',
		'items' => 'fnHaStatsPktCount',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortinet_bytes',
		'descr' => 'BYTES PROCESADOS',
		'items' => 'fnHaStatsByteCount',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortinet_attacks',
		'descr' => 'ATAQUES EN 20 HORAS',
		'items' => 'fnHaStatsIdsCount',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'fortinet_virus',
		'descr' => 'VIRUS EN 20 HORAS',
		'items' => 'fnHaStatsAvCount',
	);

?>
