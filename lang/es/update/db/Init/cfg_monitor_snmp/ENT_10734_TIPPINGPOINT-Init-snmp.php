<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tip_pkts_block',
		'descr' => 'PAQUETES ELIMINADOS',
		'items' => 'policyPacketsDropped.0|policyPacketsBlocked.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tip_pkts_flow',
		'descr' => 'PAQUETES CURSADOS',
		'items' => 'policyPacketsIncoming.0|policyPacketsOutgoing.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tip_pkts_perm',
		'descr' => 'PAQUETES PERMITIDOS',
		'items' => 'policyPacketsPermitted.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tip_pkts_inval',
		'descr' => 'PAQUETES INVALIDOS',
		'items' => 'policyPacketsInvalid.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tip_alerts_proto',
		'descr' => 'ALERTAS POR PROTOCOLO',
		'items' => 'protocolAlertCount',
	);

?>
