<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_battery_status',
		'descr' => 'ESTADO DE LA BATERIA',
		'items' => 'Estado (2:Normal)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_battery_usage',
		'descr' => 'TIEMPO DE USO DE LA BATERIA',
		'items' => 'socoupsSecondsOnBattery.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_time_remaining',
		'descr' => 'TIEMPO ESTIMADO RESTANTE DE LA BATERIA',
		'items' => 'socoupsEstimatedMinutesRemaining.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_charge_remaining',
		'descr' => 'CARGA ESTIMADA RESTANTE DE LA BATERIA',
		'items' => 'socupsEstimatedChargeRemaining.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_voltage',
		'descr' => 'VOLTAJE DE LA BATERIA',
		'items' => 'Voltaje (0.1 Volt DC)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_num_lines',
		'descr' => 'NUMERO DE LINEAS',
		'items' => 'Lineas de Entrada|Lineas de Salida|Lineas de Bypass',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_in_voltage',
		'descr' => 'VOLTAJE DE ENTRADA EN LINEA',
		'items' => 'Voltaje (0.1 Volts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_in_current',
		'descr' => 'CORRIENTE DE ENTRADA EN LINEA',
		'items' => 'Corriente (0.1 Amp)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_out_voltage',
		'descr' => 'VOLTAJE DE SALIDA EN LINEA',
		'items' => 'Voltaje (0.1 Volts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_out_current',
		'descr' => 'CORRIENTE DE SALIDA EN LINEA',
		'items' => 'Corriente (0.1 Amp)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_out_load_perc',
		'descr' => 'CARGA DE SALIDA EN LINEA',
		'items' => 'Porcentaje de carga (%)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_byp_voltage',
		'descr' => 'VOLTAJE DE BYPASS EN LINEA',
		'items' => 'Voltaje (0.1 Volts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_byp_current',
		'descr' => 'CORRIENTE DE BYPASS EN LINEA',
		'items' => 'Corriente (0.1 Amp)',
	);

?>
