<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ciscocm_reg_phones',
		'descr' => 'REGISTERED PHONES',
		'items' => 'ccmRegisteredPhones.0|ccmUnregisteredPhones.0|ccmRejectedPhones.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ciscocm_reg_gws',
		'descr' => 'REGISTERED GATEWAYS',
		'items' => 'ccmRegisteredGateways.0|ccmUnregisteredGateways.0|ccmRejectedGateways.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ciscocm_reg_mdev',
		'descr' => 'REGISTERED DEVICES',
		'items' => 'ccmRegisteredMediaDevices.0|ccmUnregisteredMediaDevices.0|ccmRejectedMediaDevices.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ciscocm_reg_ctis',
		'descr' => 'REGISTERED CTI DEVICES',
		'items' => 'ccmRegisteredCTIDevices.0|ccmUnregisteredCTIDevices.0|ccmRejectedCTIDevices.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ciscocm_reg_vmail',
		'descr' => 'REGISTERED VOICE MAIL DEVICES',
		'items' => 'ccmRegisteredVoiceMailDevices.0|ccmUnregisteredVoiceMailDevices.0|ccmRejectedVoiceMailDevices.0',
	);

?>
