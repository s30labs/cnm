<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'poe_pse_status',
		'descr' => 'POE POWER SUPPLY STATUS',
		'items' => 'on(1)|off(2)|faulty(3)|unk',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'poe_pse_usage',
		'descr' => 'POE POWER SUPPLY CONSUMPTION',
		'items' => 'pethMainPseConsumptionPower|pethMainPsePower',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'poe_pse_usagep',
		'descr' => 'POE POWER SUPPLY CONSUMPTION (%)',
		'items' => 'pethMainPsePower|pethMainPseConsumptionPower',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'poe_class_types',
		'descr' => 'POE POWER CLASSES',
		'items' => 'class0(1)|class1(2)|class2(3)|class3(4)|class4(5)',
	);

?>
