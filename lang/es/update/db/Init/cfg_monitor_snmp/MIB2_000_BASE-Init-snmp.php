<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_ipInAddrErrors',
		'descr' => 'DATAGRAMAS DE ENTRADA DESCARTADOS',
		'items' => 'ipInAddrErrors.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_ipRoutingDiscards',
		'descr' => 'DESCARTES POR ROUTING',
		'items' => 'ipRoutingDiscards.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_ipOutNoRoutes',
		'descr' => 'DATAGRAMAS SIN RUTA',
		'items' => 'ipOutNoRoutes.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_uptime',
		'descr' => 'TIEMPO EN FUNCIONAMIENTO',
		'items' => 'sysUpTime.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_glob_ifstat',
		'descr' => 'RESUMEN ESTADO DE INTERFACES',
		'items' => 'up|admin down|down|unk',
	);

?>
