<?php
      $TIPS[]=array(
         'id_ref' => 'f5big_tcp_active',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>sysTcpStatOpen.0</strong> a partir de los siguientes atributos de la mib F5-BIGIP-SYSTEM-MIB:<br><br><strong>F5-BIGIP-SYSTEM-MIB::sysTcpStatOpen.0 (GAUGE):</strong> "The number of current open connections."
',
      );


      $TIPS[]=array(
         'id_ref' => 'f5big_tcp_inactive',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>sysTcpStatCloseWait|sysTcpStatFinWait|sysTcpStatTimeWait</strong> a partir de los siguientes atributos de la mib F5-BIGIP-SYSTEM-MIB:<br><br><strong>F5-BIGIP-SYSTEM-MIB::sysTcpStatCloseWait (GAUGE):</strong> "The number of current connections in CLOSE-WAIT/LAST-ACK."
<strong>F5-BIGIP-SYSTEM-MIB::sysTcpStatFinWait (GAUGE):</strong> "The number of current connections in FIN-WAIT/CLOSING."
<strong>F5-BIGIP-SYSTEM-MIB::sysTcpStatTimeWait (GAUGE):</strong> "The number of current connections in TIME-WAIT."
',
      );


      $TIPS[]=array(
         'id_ref' => 'f5big_pools_tot_mem',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>ltmPoolMemberNumber.0</strong> a partir de los siguientes atributos de la mib F5-BIGIP-LOCAL-MIB:<br><br><strong>F5-BIGIP-LOCAL-MIB::ltmPoolMemberNumber.0 (GAUGE):</strong> "The number of ltmPoolMember entries in the table."
',
      );


      $TIPS[]=array(
         'id_ref' => 'f5big_cpu_temp',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>sysCpuTemperature</strong> a partir de los siguientes atributos de la mib F5-BIGIP-SYSTEM-MIB:<br><br><strong>F5-BIGIP-SYSTEM-MIB::sysCpuTemperature (GAUGE):</strong> "Deprecated! Replaced by sysCpuSensor table.
 			The temperature of the indexed CPU on the system.
 			This is only supported for the platform where
 			the sensor data is available."
',
      );


      $TIPS[]=array(
         'id_ref' => 'f5big_cpu_fans',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>sysCpuFanSpeed</strong> a partir de los siguientes atributos de la mib F5-BIGIP-SYSTEM-MIB:<br><br><strong>F5-BIGIP-SYSTEM-MIB::sysCpuFanSpeed (GAUGE):</strong> "Deprecated! Replaced by sysCpuSensor table.
 			The fan speed (in RPM) of the indexed CPU on the system.,
 			This is only supported for the platform where
 			the sensor data is available."
',
      );


      $TIPS[]=array(
         'id_ref' => 'f5big_chas_fans',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>sysChassisFanSpeed</strong> a partir de los siguientes atributos de la mib F5-BIGIP-SYSTEM-MIB:<br><br><strong>F5-BIGIP-SYSTEM-MIB::sysChassisFanSpeed (GAUGE):</strong> "The actual speed of the indexed chassis fan on the system.
 		This is only supported for the platform where the actual 
 		fan speed data is available.
 		0 means fan speed is unavailable while the associated chassis status is good."
',
      );


      $TIPS[]=array(
         'id_ref' => 'f5big_chas_fan_stat',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>sysChassisFanStatus</strong> a partir de los siguientes atributos de la mib F5-BIGIP-SYSTEM-MIB:<br><br><strong>F5-BIGIP-SYSTEM-MIB::sysChassisFanStatus (GAUGE):</strong> "The status of the indexed chassis fan on the system.,
 		This is only supported for the platform where 
 		the sensor data is available."
',
      );


      $TIPS[]=array(
         'id_ref' => 'f5big_chas_power_stat',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>sysChassisPowerSupplyStatus</strong> a partir de los siguientes atributos de la mib F5-BIGIP-SYSTEM-MIB:<br><br><strong>F5-BIGIP-SYSTEM-MIB::sysChassisPowerSupplyStatus (GAUGE):</strong> "The status of the indexed power supply on the system.,
 		This is only supported for the platform where 
 		the sensor data is available."
',
      );


      $TIPS[]=array(
         'id_ref' => 'f5big_chas_temp',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>sysChassisTempTemperature</strong> a partir de los siguientes atributos de la mib F5-BIGIP-SYSTEM-MIB:<br><br><strong>F5-BIGIP-SYSTEM-MIB::sysChassisTempTemperature (GAUGE):</strong> "The chassis temperature (in Celsius) of the indexed sensor on the system.,
 		This is only supported for the platform where 
 		the sensor data is available."
',
      );


      $TIPS[]=array(
         'id_ref' => 'f5big_pool_active',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>ltmPoolActiveMemberCnt|ltmPoolMemberCnt</strong> a partir de los siguientes atributos de la mib F5-BIGIP-LOCAL-MIB:<br><br><strong>F5-BIGIP-LOCAL-MIB::ltmPoolActiveMemberCnt (GAUGE):</strong> "The number of the current active members in the specified pool."
<strong>F5-BIGIP-LOCAL-MIB::ltmPoolMemberCnt (GAUGE):</strong> "The total number of members in the specified pool."
',
      );


      $TIPS[]=array(
         'id_ref' => 'f5big_pool_avail_stat',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>ltmPoolStatusAvailState|ltmPoolStatusEnabledState</strong> a partir de los siguientes atributos de la mib F5-BIGIP-LOCAL-MIB:<br><br><strong>F5-BIGIP-LOCAL-MIB::ltmPoolStatusAvailState (GAUGE):</strong> "The availability of the specified pool indicated in color.
 		none - error;
 		green - available in some capacity;
 		yellow - not currently available;
 		red - not available;
 		blue - availability is unknown;
 		gray - unlicensed"
<strong>F5-BIGIP-LOCAL-MIB::ltmPoolStatusEnabledState (GAUGE):</strong> "The activity status of the specified pool, as specified 
 		by the user."
',
      );


?>
