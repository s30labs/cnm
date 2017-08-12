<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_cpu_usage_perc',
		'descr' => 'USO DE CPU (%)',
		'items' => 'nsResCpuAvg.0|nsResCpuLast1Min.0|nsResCpuLast5Min.0|nsResCpuLast15Min.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_mem_usage',
		'descr' => 'USO DE MEMORIA',
		'items' => 'nsResMemAllocate.0|nsResMemLeft.0|nsResMemFrag.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_session_usage',
		'descr' => 'USO DE SESIONES',
		'items' => 'nsResSessAllocate.0|nsResSessFailed.0|nsResSessMaxium.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_active_users',
		'descr' => 'USUARIOS ACTIVOS',
		'items' => 'nsUACActiveUsers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_url_filter_stat',
		'descr' => 'ESTADO DEL FILTRO WEB',
		'items' => 'running(1)|N/A(2)|Down(3)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_power_status',
		'descr' => 'ESTADO DE LA FUENTE',
		'items' => 'Good(1)|Fail(0)|Not Installed(2)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_slot_status',
		'descr' => 'ESTADO DEL SLOT',
		'items' => 'Good(1)|Fail(0)|Not Installed(2)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_tunnel_status',
		'descr' => 'ESTADO DEL TUNEL',
		'items' => 'Up(1)|Unk(2)|Down(0)',
	);

?>
