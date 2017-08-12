<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_battery_status',
		'descr' => 'UPS BATTERY STATUS',
		'items' => 'Estado (2:Normal)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_battery_usage',
		'descr' => 'UPS SECONDS ON BATTERY',
		'items' => 'upsSecondsOnBattery.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_time_estimate',
		'descr' => 'UPS ESTIMATED TIME REMAINIG',
		'items' => 'upsEstimatedMinutesRemaining.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_charge_estimate',
		'descr' => 'UPS ESTIMATED CHARGE REMAINIG',
		'items' => 'upsEstimatedChargeRemaining.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_voltage',
		'descr' => 'UPS BATTERY VOLTAGE',
		'items' => 'Volts (0.1 Volt DC)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_current',
		'descr' => 'UPS BATTERY CURRENT',
		'items' => 'Amps (0.1 Amp DC)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_temperature',
		'descr' => 'UPS BATTERY TEMPERATURE',
		'items' => 'Degrees Celsius',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_num_lines',
		'descr' => 'UPS NUMBER OF LINES',
		'items' => 'Input Lines|Output Lines|Bypass Lines',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_in_freq',
		'descr' => 'UPS INPUT FREQUENCY IN LINE',
		'items' => 'Frequency (0.1 Hertz)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_in_voltage',
		'descr' => 'UPS INPUT LINE VOLTAGE',
		'items' => 'Voltage (RMS Volts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_in_current',
		'descr' => 'UPS INPUT LINE CURRENT',
		'items' => 'Current (0.1 RMS Amp)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_in_power',
		'descr' => 'UPS INPUT LINE POWER',
		'items' => 'Power (Watts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_out_voltage',
		'descr' => 'UPS OUTPUT LINE VOLTAGE',
		'items' => 'Voltage (RMS Volts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_out_current',
		'descr' => 'UPS OUTPUT LINE CURRENT',
		'items' => 'Current (0.1 RMS Amp)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_out_power',
		'descr' => 'UPS OUTPUT LINE POWER',
		'items' => 'Power (Watts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_out_load_perc',
		'descr' => 'UPS OUTPUT LINE LOAD',
		'items' => 'Load (%)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_byp_voltage',
		'descr' => 'UPS BYPASS VOLTAGE',
		'items' => 'Potencia (Watts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_byp_current',
		'descr' => 'UPS BYPASS CURRENT',
		'items' => 'Potencia (Watts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ups_byp_power',
		'descr' => 'UPS BYPASS POWER',
		'items' => 'Potencia (Watts)',
	);

?>
