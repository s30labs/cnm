<?
	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'CISCO-CCM-MIB::ccmCallManagerFailed',
		'hiid' => '9d987a25b1',
		'descr' => 'FALLO EN CALL MANAGER',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'CISCO-CCM-MIB::ccmPhoneFailed',
		'hiid' => '9d987a25b1',
		'descr' => 'FALLO EN TELEFONO',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'CISCO-CCM-MIB::ccmPhoneStatusUpdate',
		'hiid' => '9d987a25b1',
		'descr' => 'ACTUALIZACION DE TELEFONO',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'CISCO-CCM-MIB::ccmGatewayFailed',
		'hiid' => '90ac57f4f0',
		'descr' => 'FALLO DE GATEWAY',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'CISCO-CCM-MIB::ccmMediaResourceListExhausted',
		'hiid' => '1a8f9efa98',
		'descr' => 'AGOTADA LISTA DE RECURSOS',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'CISCO-CCM-MIB::ccmRouteListExhausted',
		'hiid' => '9d987a25b1',
		'descr' => 'AGOTADA LISTA DE RUTAS DE TELEFONIA',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'CISCO-CCM-MIB::ccmGatewayLayer2Change',
		'hiid' => '9d987a25b1',
		'descr' => 'CAMBIO EN NIVEL 2',
	);

?>
