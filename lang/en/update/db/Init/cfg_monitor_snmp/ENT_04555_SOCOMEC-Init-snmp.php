<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_battery_status',
		'descr' => 'SOCOMEC BATTERY STATUS',
		'items' => 'Status (2:Normal)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_battery_usage',
		'descr' => 'SOCOMEC BATTERY USAGE TIME',
		'items' => 'socoupsSecondsOnBattery.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_time_remaining',
		'descr' => 'SOCOMEC BATTERY REMAINING TIME',
		'items' => 'socoupsEstimatedMinutesRemaining.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_charge_remaining',
		'descr' => 'SOCOMEC BATTERY LOAD CHARGE REMAINING',
		'items' => 'socupsEstimatedChargeRemaining.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_voltage',
		'descr' => 'SOCOMEC BATTERY VOLTAGE',
		'items' => 'Voltage (0.1 Volt DC)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_num_lines',
		'descr' => 'SOCOMEC NUMBER OF LINES',
		'items' => 'Input lines|Output lines|Bypass lines',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_in_voltage',
		'descr' => 'SOCOMEC LINE INPUT VOLTAGE',
		'items' => 'Voltage (0.1 Volts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_in_current',
		'descr' => 'SOCOMEC LINE INPUT CURRENT',
		'items' => 'Current (0.1 Amp)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_out_voltage',
		'descr' => 'SOCOMEC LINE OUTPUT VOLTAGE',
		'items' => 'Voltage (0.1 Volts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_out_current',
		'descr' => 'SOCOMEC LINE OUTPUT CURRENT',
		'items' => 'Current (0.1 Amp)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_out_load_perc',
		'descr' => 'SOCOMEC LINE OUTPUT LOAD',
		'items' => 'Load percentage (%)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_byp_voltage',
		'descr' => 'SOCOMEC LINE BYPASS VOLTAGE',
		'items' => 'Voltage (0.1 Volts)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'socups_byp_current',
		'descr' => 'SOCOMEC LINE BYPASS CURRENT',
		'items' => 'Current (0.1 Amp)',
	);

?>
