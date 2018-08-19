<?php
      $TIPS[]=array(
         'id_ref' => 'socups_battery_status',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Estado (2:Normal)</strong> a partir de los siguientes atributos de la mib SOCOMECUPS-MIB:<br><br><strong>SOCOMECUPS-MIB::socoupsBatteryStatus.0 (GAUGE):</strong> "The present battery status"
',
      );


      $TIPS[]=array(
         'id_ref' => 'socups_battery_usage',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>socoupsSecondsOnBattery.0</strong> a partir de los siguientes atributos de la mib SOCOMECUPS-MIB:<br><br><strong>SOCOMECUPS-MIB::socoupsSecondsOnBattery.0 (GAUGE):</strong> "If the unit is on battery power, the elapsed time
         since the UPS last switched to battery power, or the
         time since the network management subsystem was last
         restarted, whichever is less.  -1 shall be returned
         if the unit is not on battery power."
',
      );


      $TIPS[]=array(
         'id_ref' => 'socups_time_remaining',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>socoupsEstimatedMinutesRemaining.0</strong> a partir de los siguientes atributos de la mib SOCOMECUPS-MIB:<br><br><strong>SOCOMECUPS-MIB::socoupsEstimatedMinutesRemaining.0 (GAUGE):</strong> "An estimate of the time to battery charge depletion
         under the present load conditions if the utility power
         is off and remains off, or if it were to be lost and
         remain off."
',
      );


      $TIPS[]=array(
         'id_ref' => 'socups_charge_remaining',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>socupsEstimatedChargeRemaining.0</strong> a partir de los siguientes atributos de la mib SOCOMECUPS-MIB:<br><br><strong>SOCOMECUPS-MIB::socupsEstimatedChargeRemaining.0 (GAUGE):</strong> "An estimate of the battery charge remaining expressed
          as a percent of full charge."
',
      );


      $TIPS[]=array(
         'id_ref' => 'socups_voltage',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Voltaje (0.1 Volt DC)</strong> a partir de los siguientes atributos de la mib SOCOMECUPS-MIB:<br><br><strong>SOCOMECUPS-MIB::socoupsBatteryVoltage.0 (GAUGE):</strong> "The magnitude of the present battery voltage in 0.1 Volt DC."
',
      );


      $TIPS[]=array(
         'id_ref' => 'socups_num_lines',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Lineas de Entrada|Lineas de Salida|Lineas de Bypass</strong> a partir de los siguientes atributos de la mib SOCOMECUPS-MIB:<br><br><strong>SOCOMECUPS-MIB::socoupsInputNumLines.0 (GAUGE):</strong> "The number of input lines utilized in this device.
           This variable indicates the number of rows in the
           input table."
<strong>SOCOMECUPS-MIB::socoupsOutputNumLines.0 (GAUGE):</strong> "The number of output lines utilized in this device.
           This variable indicates the number of rows in the
           output table."
<strong>SOCOMECUPS-MIB::socoupsBypassNumLines.0 (GAUGE):</strong> "The number of bypass lines utilized in this device.
              This entry indicates the number of rows in the bypass
              table."
',
      );


      $TIPS[]=array(
         'id_ref' => 'socups_in_voltage',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Voltaje (0.1 Volts)</strong> a partir de los siguientes atributos de la mib SOCOMECUPS-MIB:<br><br><strong>SOCOMECUPS-MIB::socoupsInputVoltage (GAUGE):</strong> "The input utility line voltage in 0.1 volts."
<strong>SOCOMECUPS-MIB::socoupsInputVoltageMax (GAUGE):</strong> "The maximum utility line voltage in 0.1 VAC for last 1 minute."
<strong>SOCOMECUPS-MIB::socoupsInputVoltageMin (GAUGE):</strong> "The minimum utility line voltage in 0.1 VAC for last 1 minute."
',
      );


      $TIPS[]=array(
         'id_ref' => 'socups_in_current',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Corriente (0.1 Amp)</strong> a partir de los siguientes atributos de la mib SOCOMECUPS-MIB:<br><br><strong>SOCOMECUPS-MIB::socoupsInputCurrent (GAUGE):</strong> "The magnitude of the present input current in 0.1 A."
',
      );


      $TIPS[]=array(
         'id_ref' => 'socups_out_voltage',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Voltaje (0.1 Volts)</strong> a partir de los siguientes atributos de la mib SOCOMECUPS-MIB:<br><br><strong>SOCOMECUPS-MIB::socoupsOutputVoltage (GAUGE):</strong> "The output voltage of the UPS system in 0.1 volts."
',
      );


      $TIPS[]=array(
         'id_ref' => 'socups_out_current',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Corriente (0.1 Amp)</strong> a partir de los siguientes atributos de la mib SOCOMECUPS-MIB:<br><br><strong>SOCOMECUPS-MIB::socoupsOutputCurrent (GAUGE):</strong> "The output current of the UPS system in 0.1 Amps."
',
      );


      $TIPS[]=array(
         'id_ref' => 'socups_out_load_perc',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Porcentaje de carga (%)</strong> a partir de los siguientes atributos de la mib SOCOMECUPS-MIB:<br><br><strong>SOCOMECUPS-MIB::socoupsOutputPercentLoad (GAUGE):</strong> "The percentage of the UPS power capacity presently
              being used on this output line, i.e., the greater of
              the percent load of true power capacity and the
              percent load of VA."
',
      );


      $TIPS[]=array(
         'id_ref' => 'socups_byp_voltage',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Voltaje (0.1 Volts)</strong> a partir de los siguientes atributos de la mib SOCOMECUPS-MIB:<br><br><strong>SOCOMECUPS-MIB::socoupsBypassVoltage (GAUGE):</strong> "The present bypass voltage."
',
      );


      $TIPS[]=array(
         'id_ref' => 'socups_byp_current',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>Corriente (0.1 Amp)</strong> a partir de los siguientes atributos de la mib SOCOMECUPS-MIB:<br><br><strong>SOCOMECUPS-MIB::socoupsBypassCurrent (GAUGE):</strong> "The present bypass current."
',
      );


?>
