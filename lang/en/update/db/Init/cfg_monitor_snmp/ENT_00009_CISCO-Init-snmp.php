<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_fan_state',
		'descr' => 'FAN STATUS',
		'items' => 'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_powersup_state',
		'descr' => 'POWER SUPPLY STATUS',
		'items' => 'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_temperature_state',
		'descr' => 'TEMPERATURE STATUS',
		'items' => 'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_voltage_state',
		'descr' => 'VOLTAGE STATUS',
		'items' => 'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_vlan_sum',
		'descr' => 'VLAN TABLE',
		'items' => 'operational(1)|suspended(2)|mtuTooBigForDevice(3)|mtuTooBigForTrunk(4)',
	);

?>
