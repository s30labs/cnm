<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_cpu_util',
		'descr' => 'USO DE CPU EN VM',
		'items' => 'cpuUtil',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_mem_util',
		'descr' => 'USO DE MEMORIA EN VM',
		'items' => 'memUtil|memConfigured',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_disk_util_kb',
		'descr' => 'USO DE DISCO EN VM',
		'items' => 'kbRead|kbWritten',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_net_util_kb',
		'descr' => 'USO DE RED EN VM',
		'items' => 'kbTx|kbRx',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_mem_cfg',
		'descr' => 'MEMORIA CONFIGURADA EN VM',
		'items' => 'vmMemSize',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_vm_status',
		'descr' => 'ESTADO DE VM',
		'items' => 'running|notRunning',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_vm_glob_status',
		'descr' => 'ESTADO GLOBAL DE TODAS LAS VM',
		'items' => 'running|notRunning',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'vmware_vm_glob_mem',
		'descr' => 'MEMORIA GLOBAL DE TODAS LAS VM',
		'items' => 'running|notRunning',
	);

?>
