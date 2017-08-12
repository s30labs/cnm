<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_log_file',
		'descr' => 'LOG OCUPATION',
		'items' => 'logFullPercent.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_sign_webu',
		'descr' => 'SIGNED IN WEB USERS',
		'items' => 'signedInWebUsers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_sign_mailu',
		'descr' => 'SIGNED IN MAIL USERS',
		'items' => 'signedInMailUsers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_cpu_usage',
		'descr' => 'CPU USAGE',
		'items' => 'iveCpuUtil.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_mem_usage',
		'descr' => 'MEMOY USAGE',
		'items' => 'iveMemoryUtil.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_users',
		'descr' => 'CONCURRENT USERS',
		'items' => 'iveConcurrentUsers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_cluster_users',
		'descr' => 'CLUSTER CONCURRENT USERS',
		'items' => 'clusterConcurrentUsers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_swap_usage',
		'descr' => 'SWAP USAGE',
		'items' => 'iveSwapUtil.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_disk_usage',
		'descr' => 'DISK USAGE',
		'items' => 'diskFullPercent.0',
	);

?>
