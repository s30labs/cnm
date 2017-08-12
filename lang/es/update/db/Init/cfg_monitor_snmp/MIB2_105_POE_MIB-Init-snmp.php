<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'poe_pse_status',
		'descr' => 'ESTADO DE LA FUENTE',
		'items' => 'on(1)|off(2)|faulty(3)|unk',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'poe_pse_usage',
		'descr' => 'CONSUMO DE LA FUENTE',
		'items' => 'pethMainPseConsumptionPower|pethMainPsePower',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'poe_pse_usagep',
		'descr' => 'CONSUMO DE LA FUENTE (%)',
		'items' => 'pethMainPsePower|pethMainPseConsumptionPower',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'poe_class_types',
		'descr' => 'CLASES DE POTENCIA CONECTADAS',
		'items' => 'class0(1)|class1(2)|class2(3)|class3(4)|class4(5)',
	);

?>
