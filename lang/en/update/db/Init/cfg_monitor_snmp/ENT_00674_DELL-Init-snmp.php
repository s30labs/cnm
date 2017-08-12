<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_powersup_stat',
		'descr' => 'DELL POWER SUPPLY STATUS',
		'items' => 'Full(8)|Loading(7)|Down(1)|Attempt(2)|Init(3)|2W(4)|ExchSt(5)|Exch(6)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_powersup_gstat',
		'descr' => 'DELL POWER SUPPLY GLOBAL STATUS',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_volt_gstat',
		'descr' => 'DELL VOLTAGE GLOBAL STATUS',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_coold_gstat',
		'descr' => 'DELL FANS GLOBAL STATUS',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_temp_gstat',
		'descr' => 'DELL TEMPERATURE GLOBAL STATUS',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_memory_gstat',
		'descr' => 'DELL MEMORY GLOBAL STATUS',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_chasis_gstat',
		'descr' => 'DELL CHASSIS GLOBAL STATUS',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_power_gstat',
		'descr' => 'DELL POWER GLOBAL STATUS',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_coolu_gstat',
		'descr' => 'DELL COOLING GLOBAL STATUS',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_proc_gstat',
		'descr' => 'DELL PROCESSOR GLOBAL STATUS',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_battery_gstat',
		'descr' => 'DELL BATTERY GLOBAL STATUS',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_adisk_stat',
		'descr' => 'DELL DISK ARRAY - DISK STATUS',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_adisk_cstat',
		'descr' => 'DELL DISK ARRAY - CONTROLLER STATUS',
		'items' => 'ready(1)|offline(4)|failed(2)|degraded(6)|online(3)',
	);

?>
