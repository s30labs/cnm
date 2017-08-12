<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_cpu_util',
		'descr' => 'CPU USAGE IN VM',
		'items' => 'cpuUtil',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_mem_util',
		'descr' => 'MEMORY USAGE IN VM',
		'items' => 'memUtil|memConfigured',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_disk_util_kb',
		'descr' => 'DISK USAGE IN VM',
		'items' => 'kbRead|kbWritten',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_net_util_kb',
		'descr' => 'NETWORK USAGE IN VM',
		'items' => 'kbTx|kbRx',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_mem_cfg',
		'descr' => 'CONFIGURED MEMORY IN VM',
		'items' => 'vmMemSize',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_vm_status',
		'descr' => 'VM STATUS',
		'items' => 'running|notRunning',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_vm_glob_status',
		'descr' => 'GLOBAL STATUS OF ALL VM',
		'items' => 'running|notRunning',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_vm_glob_mem',
		'descr' => 'GLOBAL MEMORY OF ALL VM',
		'items' => 'running|notRunning',
	);

?>
