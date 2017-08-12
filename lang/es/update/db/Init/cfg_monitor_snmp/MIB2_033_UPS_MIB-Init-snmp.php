<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_battery_status',
		'descr' => 'ESTADO DE LA BATERIA',
		'items' => 'Estado (2:Normal)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_battery_usage',
		'descr' => 'TIEMPO DE USO DE LA BATERIA',
		'items' => 'upsSecondsOnBattery.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_time_estimate',
		'descr' => 'TIEMPO ESTIMADO RESTANTE DE LA BATERIA',
		'items' => 'upsEstimatedMinutesRemaining.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_charge_estimate',
		'descr' => 'CARGA ESTIMADA RESTANTE DE LA BATERIA',
		'items' => 'upsEstimatedChargeRemaining.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_voltage',
		'descr' => 'VOLTAJE DE LA BATERIA',
		'items' => 'Voltios (0.1 Volt DC)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_current',
		'descr' => 'CORRIENTE DE LA BATERIA',
		'items' => 'Amperios (0.1 Amp DC)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_temperature',
		'descr' => 'TEMPERATURA DE LA BATERIA',
		'items' => 'Grados Centigrados',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_num_lines',
		'descr' => 'NUMERO DE LINEAS',
		'items' => 'Lineas de Entrada|Lineas de Salida|Lineas de Bypass',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_in_freq',
		'descr' => 'FRECUENCIA DE ENTRADA EN LINEA',
		'items' => 'Frecuencia (0.1 Hertz)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_in_voltage',
		'descr' => 'VOLTAJE DE ENTRADA EN LINEA',
		'items' => 'Voltaje (RMS Volts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_in_current',
		'descr' => 'CORRIENTE DE ENTRADA EN LINEA',
		'items' => 'Corriente (0.1 RMS Amp)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_in_power',
		'descr' => 'POTENCIA DE ENTRADA EN LINEA',
		'items' => 'Potencia (Watts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_out_voltage',
		'descr' => 'VOLTAJE DE SALIDA EN LINEA',
		'items' => 'Voltaje (RMS Volts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_out_current',
		'descr' => 'CORRIENTE DE SALIDA EN LINEA',
		'items' => 'Corriente (0.1 RMS Amp)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_out_power',
		'descr' => 'POTENCIA DE SALIDA EN LINEA',
		'items' => 'Potencia (Watts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_out_load_perc',
		'descr' => 'CARGA DE SALIDA EN LINEA',
		'items' => 'Porcentaje de Carga (%)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_byp_voltage',
		'descr' => 'VOLTAJE DE BYPASS EN LINEA',
		'items' => 'Voltaje (RMS Volts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_byp_current',
		'descr' => 'CORRIENTE DE BYPASS EN LINEA',
		'items' => 'Corriente (0.1 RMS Amp)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_byp_power',
		'descr' => 'POTENCIA DE BYPASS EN LINEA',
		'items' => 'Potencia (Watts)',
	);

?>
