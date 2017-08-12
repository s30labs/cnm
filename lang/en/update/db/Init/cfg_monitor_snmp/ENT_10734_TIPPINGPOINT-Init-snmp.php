<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tip_pkts_block',
		'descr' => 'PACKETS LOST',
		'items' => 'policyPacketsDropped.0|policyPacketsBlocked.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tip_pkts_flow',
		'descr' => 'PACKET FLOW',
		'items' => 'policyPacketsIncoming.0|policyPacketsOutgoing.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tip_pkts_perm',
		'descr' => 'PACKETS PERMITTED',
		'items' => 'policyPacketsPermitted.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tip_pkts_inval',
		'descr' => 'PACKETS INVALID',
		'items' => 'policyPacketsInvalid.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tip_alerts_proto',
		'descr' => 'PROTOCOL ALERT COUNT',
		'items' => 'protocolAlertCount',
	);

?>
