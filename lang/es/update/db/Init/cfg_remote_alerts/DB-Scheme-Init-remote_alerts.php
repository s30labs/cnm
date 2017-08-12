<?
	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'cnm',
		'subtype' => 'mon_snmp',
		'hiid' => 'ea1c3c284d',
		'descr' => 'SIN RESPUESTA SNMP',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'cnm',
		'subtype' => 'mon_xagent',
		'hiid' => 'ea1c3c284d',
		'descr' => 'SIN RESPUESTA DEL AGENTE REMOTO',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'cnm',
		'subtype' => 'mon_wbem',
		'hiid' => 'ea1c3c284d',
		'descr' => 'SIN RESPUESTA WMI (WBEM)',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'SNMPv2-MIB::coldStart',
		'hiid' => 'ea1c3c284d',
		'descr' => 'INICIO DE EQUIPO (Cold Start)',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'SNMPv2-MIB::warmStart',
		'hiid' => 'ea1c3c284d',
		'descr' => 'INICIO DE EQUIPO (Warm Start)',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'IF-MIB::linkDown',
		'hiid' => 'ea1c3c284d',
		'descr' => 'INTERFAZ CAIDO (Link Down)',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'IF-MIB::linkUp',
		'hiid' => 'ea1c3c284d',
		'descr' => 'INTERFAZ ACTIVO (Link Up)',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'SNMPv2-MIB::authenticationFailure',
		'hiid' => 'ea1c3c284d',
		'descr' => 'ERROR EN AUTENTICACION (Authentication Failure)',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'NOTIFICATION-TEST-MIB::demo-notif',
		'hiid' => 'ea1c3c284d',
		'descr' => 'TRAP DE TEST V2',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'TRAP-TEST-MIB::demo-trap',
		'hiid' => 'ea1c3c284d',
		'descr' => 'TRAP DE TEST V1',
	);

?>
