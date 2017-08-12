<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_cpu_usage_perc',
		'descr' => 'CPU USAGE (%)',
		'items' => 'nsResCpuAvg.0|nsResCpuLast1Min.0|nsResCpuLast5Min.0|nsResCpuLast15Min.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_mem_usage',
		'descr' => 'MEMORY USAGE',
		'items' => 'nsResMemAllocate.0|nsResMemLeft.0|nsResMemFrag.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_session_usage',
		'descr' => 'SESSIONS USAGE',
		'items' => 'nsResSessAllocate.0|nsResSessFailed.0|nsResSessMaxium.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_active_users',
		'descr' => 'ACTIVE USERS',
		'items' => 'nsUACActiveUsers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_url_filter_stat',
		'descr' => 'WEB FILTER STATUS',
		'items' => 'running(1)|N/A(2)|Down(3)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_power_status',
		'descr' => 'POWER STATUS',
		'items' => 'Good(1)|Fail(0)|Not Installed(2)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_slot_status',
		'descr' => 'SLOT STATUS',
		'items' => 'Good(1)|Fail(0)|Not Installed(2)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ns_tunnel_status',
		'descr' => 'TUNNEL STATUS',
		'items' => 'Up(1)|Unk(2)|Down(0)',
	);

?>
