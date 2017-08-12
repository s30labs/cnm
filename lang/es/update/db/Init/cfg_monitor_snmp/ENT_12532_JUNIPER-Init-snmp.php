<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_log_file',
		'descr' => 'OCUPACION DEL LOG',
		'items' => 'logFullPercent.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_sign_webu',
		'descr' => 'USUARIOS DE WEB FIRMADOS',
		'items' => 'signedInWebUsers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_sign_mailu',
		'descr' => 'USUARIOS DE CORREO FIRMADOS',
		'items' => 'signedInMailUsers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_cpu_usage',
		'descr' => 'USO DE CPU',
		'items' => 'iveCpuUtil.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_mem_usage',
		'descr' => 'USO DE MEMORIA',
		'items' => 'iveMemoryUtil.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_users',
		'descr' => 'USUARIOS CONCURRENTES',
		'items' => 'iveConcurrentUsers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_cluster_users',
		'descr' => 'USUARIOS CONCURRENTES DEL CLUSTER',
		'items' => 'clusterConcurrentUsers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_swap_usage',
		'descr' => 'USO DE SWAP',
		'items' => 'iveSwapUtil.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'juniper_disk_usage',
		'descr' => 'USO DE DISCO',
		'items' => 'diskFullPercent.0',
	);

?>
