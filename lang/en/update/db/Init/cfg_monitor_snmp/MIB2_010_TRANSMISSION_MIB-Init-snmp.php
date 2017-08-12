<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dial_peer_ctime',
		'descr' => 'DIAL PEER CONNECT TIME',
		'items' => 'dialCtlPeerStatsConnectTime',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dial_peer_calls',
		'descr' => 'DIAL PEER CALLS',
		'items' => 'dialCtlPeerStatsSuccessCalls|dialCtlPeerStatsFailCalls|dialCtlPeerStatsAcceptCalls|dialCtlPeerStatsRefuseCalls',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_glob_duplex',
		'descr' => 'INTERFACE DUPLEX MODE SUMMARY',
		'items' => 'fullDuplex|unknown|halfDuplex',
	);

?>
