<?
	$TIPS[]=array(
		'id_ref' => 'ups_battery_status',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Estado (2:Normal)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsBatteryStatus.0 (GAUGE):</strong> "The indication of the capacity remaining in the UPS
                systems batteries.   A value of batteryNormal
                indicates that the remaining run-time is greater than
                upsConfigLowBattTime.  A value of batteryLow indicates
                that the remaining battery run-time is less than or
                equal to upsConfigLowBattTime.  A value of
                batteryDepleted indicates that the UPS will be unable
                to sustain the present load when and if the utility
                power is lost (including the possibility that the
                utility power is currently absent and the UPS is
                unable to sustain the output)."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_battery_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>upsSecondsOnBattery.0</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsSecondsOnBattery.0 (GAUGE):</strong> "If the unit is on battery power, the elapsed time
                since the UPS last switched to battery power, or the
                time since the network management subsystem was last
                restarted, whichever is less.  Zero shall be returned
                if the unit is not on battery power."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_time_estimate',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>upsEstimatedMinutesRemaining.0</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsEstimatedMinutesRemaining.0 (GAUGE):</strong> "An estimate of the time to battery charge depletion
                under the present load conditions if the utility power
                is off and remains off, or if it were to be lost and
                remain off."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_charge_estimate',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>upsEstimatedChargeRemaining.0</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsEstimatedChargeRemaining.0 (GAUGE):</strong> "An estimate of the battery charge remaining expressed
                as a percent of full charge."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_voltage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Voltios (0.1 Volt DC)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsBatteryVoltage.0 (GAUGE):</strong> "The magnitude of the present battery voltage."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_current',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Amperios (0.1 Amp DC)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsBatteryCurrent.0 (GAUGE):</strong> "The present battery current."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_temperature',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Grados Centigrados</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsBatteryTemperature.0 (GAUGE):</strong> "The ambient temperature at or near the UPS Battery
                casing."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_num_lines',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Lineas de Entrada|Lineas de Salida|Lineas de Bypass</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsInputNumLines.0 (GAUGE):</strong> "The number of input lines utilized in this device.
                This variable indicates the number of rows in the
                input table."
<strong>UPS-MIB::upsOutputNumLines.0 (GAUGE):</strong> "The number of output lines utilized in this device.
                This variable indicates the number of rows in the
                output table."
<strong>UPS-MIB::upsBypassNumLines.0 (GAUGE):</strong> "The number of bypass lines utilized in this device.
                This entry indicates the number of rows in the bypass
                table."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_in_freq',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Frecuencia (0.1 Hertz)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsInputFrequency (GAUGE):</strong> "The present input frequency."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_in_voltage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Voltaje (RMS Volts)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsInputVoltage (GAUGE):</strong> "The magnitude of the present input voltage."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_in_current',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Corriente (0.1 RMS Amp)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsInputCurrent (GAUGE):</strong> "The magnitude of the present input current."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_in_power',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Potencia (Watts)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsInputTruePower (GAUGE):</strong> "The magnitude of the present input true power."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_out_voltage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Voltaje (RMS Volts)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsOutputVoltage (GAUGE):</strong> "The present output voltage."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_out_current',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Corriente (0.1 RMS Amp)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsOutputCurrent (GAUGE):</strong> "The present output current."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_out_power',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Potencia (Watts)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsOutputPower (GAUGE):</strong> "The present output true power."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_out_load_perc',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Porcentaje de Carga (%)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsOutputPercentLoad (GAUGE):</strong> "The percentage of the UPS power capacity presently
                being used on this output line, i.e., the greater of
                the percent load of true power capacity and the
                percent load of VA."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_byp_voltage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Voltaje (RMS Volts)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsBypassVoltage (GAUGE):</strong> "The present bypass voltage."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_byp_current',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Corriente (0.1 RMS Amp)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsBypassCurrent (GAUGE):</strong> "The present bypass current."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ups_byp_power',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Potencia (Watts)</strong> a partir de los siguientes atributos de la mib UPS-MIB:<br><br><strong>UPS-MIB::upsBypassPower (GAUGE):</strong> "The present true power conveyed by the bypass."
',
	);

?>
