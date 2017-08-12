<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_powersup_stat',
		'descr' => 'FUENTE DE ALIMENTACION - ESTADO',
		'items' => 'Full(8)|Loading(7)|Down(1)|Attempt(2)|Init(3)|2W(4)|ExchSt(5)|Exch(6)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_powersup_gstat',
		'descr' => 'FUENTE DE ALIMENTACION - ESTADO GLOBAL',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_volt_gstat',
		'descr' => 'VOLTAJE - ESTADO GLOBAL',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_coold_gstat',
		'descr' => 'VENTILADORES - ESTADO GLOBAL',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_temp_gstat',
		'descr' => 'TEMPERATURA - ESTADO GLOBAL',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_memory_gstat',
		'descr' => 'MEMORIA - ESTADO GLOBAL',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_chasis_gstat',
		'descr' => 'INTRUSION CHASIS - ESTADO GLOBAL',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_power_gstat',
		'descr' => 'POTENCIA - ESTADO GLOBAL',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_coolu_gstat',
		'descr' => 'VENTILACION - ESTADO GLOBAL',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_proc_gstat',
		'descr' => 'PROCESADOR - ESTADO GLOBAL',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_battery_gstat',
		'descr' => 'BATERIA - ESTADO GLOBAL',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_adisk_stat',
		'descr' => 'ARRAY DE DISCOS - ESTADO DISCO',
		'items' => 'ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'dell_adisk_cstat',
		'descr' => 'ARRAY DE DISCOS - ESTADO CONTROLADOR',
		'items' => 'ready(1)|offline(4)|failed(2)|degraded(6)|online(3)',
	);

?>
