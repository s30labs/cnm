<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pan_ses_usage',
		'descr' => 'USO DE SESIONES',
		'items' => 'panSessionUtilization.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pan_ses_active',
		'descr' => 'SESIONES ACTIVAS',
		'items' => 'panSessionActive.0|panSessionActiveTcp.0|panSessionActiveUdp.0|panSessionActiveICMP.0',
	);

?>
