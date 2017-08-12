<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ciscocm_reg_phones',
		'descr' => 'TELEFONOS REGISTRADOS',
		'items' => 'ccmRegisteredPhones.0|ccmUnregisteredPhones.0|ccmRejectedPhones.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ciscocm_reg_gws',
		'descr' => 'GATEWAYS REGISTRADOS',
		'items' => 'ccmRegisteredGateways.0|ccmUnregisteredGateways.0|ccmRejectedGateways.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ciscocm_reg_mdev',
		'descr' => 'DISPOSITIVOS REGISTRADOS',
		'items' => 'ccmRegisteredMediaDevices.0|ccmUnregisteredMediaDevices.0|ccmRejectedMediaDevices.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ciscocm_reg_ctis',
		'descr' => 'DISPOSITIVOS CTI REGISTRADOS',
		'items' => 'ccmRegisteredCTIDevices.0|ccmUnregisteredCTIDevices.0|ccmRejectedCTIDevices.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ciscocm_reg_vmail',
		'descr' => 'DISPOSITIVOS VOICE MAIL REGISTRADOS',
		'items' => 'ccmRegisteredVoiceMailDevices.0|ccmUnregisteredVoiceMailDevices.0|ccmRejectedVoiceMailDevices.0',
	);

?>
