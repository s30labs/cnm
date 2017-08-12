<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_ipInAddrErrors',
		'descr' => 'DISCARDED INPUT DATAGRAMS',
		'items' => 'ipInAddrErrors.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_ipRoutingDiscards',
		'descr' => 'DISCARDED DATAGRAMS BY ROUTING',
		'items' => 'ipRoutingDiscards.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_ipOutNoRoutes',
		'descr' => 'DATAGRAMS WITH NO ROUTE',
		'items' => 'ipOutNoRoutes.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_uptime',
		'descr' => 'UPTIME',
		'items' => 'sysUpTime.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_glob_ifstat',
		'descr' => 'INTERFACE STATUS SUMMARY',
		'items' => 'up|admin down|down|unk',
	);

?>
