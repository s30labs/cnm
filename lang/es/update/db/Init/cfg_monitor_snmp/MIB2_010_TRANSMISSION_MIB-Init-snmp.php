<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dial_peer_ctime',
		'descr' => 'TIEMPO DE CONEXION EN PEER',
		'items' => 'dialCtlPeerStatsConnectTime',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dial_peer_calls',
		'descr' => 'LLAMADAS EN PEER',
		'items' => 'dialCtlPeerStatsSuccessCalls|dialCtlPeerStatsFailCalls|dialCtlPeerStatsAcceptCalls|dialCtlPeerStatsRefuseCalls',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_glob_duplex',
		'descr' => 'RESUMEN DEL MODO DUPLEX DE LOS INTERFACES',
		'items' => 'fullDuplex|unknown|halfDuplex',
	);

?>
