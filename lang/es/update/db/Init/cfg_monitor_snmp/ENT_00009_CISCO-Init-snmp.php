<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_fan_state',
		'descr' => 'ESTADO DEL VENTILADOR',
		'items' => 'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_powersup_state',
		'descr' => 'ESTADO DE LA FUENTE DE ALIMENTACION',
		'items' => 'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_temperature_state',
		'descr' => 'ESTADO DE LA TEMPERATURA',
		'items' => 'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_voltage_state',
		'descr' => 'ESTADO DEL VOLTAJE',
		'items' => 'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_vlan_sum',
		'descr' => 'TABLA DE VLANs',
		'items' => 'operational(1)|suspended(2)|mtuTooBigForDevice(3)|mtuTooBigForTrunk(4)',
	);

?>
