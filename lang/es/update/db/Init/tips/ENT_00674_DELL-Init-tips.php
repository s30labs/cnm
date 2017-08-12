<?
	$TIPS[]=array(
		'id_ref' => 'dell_powersup_stat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Full(8)|Loading(7)|Down(1)|Attempt(2)|Init(3)|2W(4)|ExchSt(5)|Exch(6)</strong> a partir de los siguientes atributos de la mib MIB-Dell-10892:<br><br><strong>MIB-Dell-10892::powerSupplyStatus (GAUGE):</strong> "0600.0012.0001.0005 This attribute defines the status of the power supply."
',
	);

	$TIPS[]=array(
		'id_ref' => 'dell_powersup_gstat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)</strong> a partir de los siguientes atributos de la mib MIB-Dell-10892:<br><br><strong>MIB-Dell-10892::systemStatePowerSupplyStatusCombined (GAUGE):</strong> "0200.0010.0001.0009 This attribute defines the combined status of all
 power supplies of this chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'dell_volt_gstat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)</strong> a partir de los siguientes atributos de la mib MIB-Dell-10892:<br><br><strong>MIB-Dell-10892::systemStateVoltageStatusCombined (GAUGE):</strong> "0200.0010.0001.0012 This attribute defines the combined status of all
 voltage probes of this chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'dell_coold_gstat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)</strong> a partir de los siguientes atributos de la mib MIB-Dell-10892:<br><br><strong>MIB-Dell-10892::systemStateCoolingDeviceStatusCombined (GAUGE):</strong> "0200.0010.0001.0021 This attribute defines the combined status of all
 cooling devices of this chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'dell_temp_gstat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)</strong> a partir de los siguientes atributos de la mib MIB-Dell-10892:<br><br><strong>MIB-Dell-10892::systemStateTemperatureStatusCombined (GAUGE):</strong> "0200.0010.0001.0024 This attribute defines the combined status of all
 temperature probes of this chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'dell_memory_gstat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)</strong> a partir de los siguientes atributos de la mib MIB-Dell-10892:<br><br><strong>MIB-Dell-10892::systemStateMemoryDeviceStatusCombined (GAUGE):</strong> "0200.0010.0001.0027 This attribute defines the combined status of all
 memory devices of this chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'dell_chasis_gstat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)</strong> a partir de los siguientes atributos de la mib MIB-Dell-10892:<br><br><strong>MIB-Dell-10892::systemStateChassisIntrusionStatusCombined (GAUGE):</strong> "0200.0010.0001.0030 This attribute defines the combined status of all
 intrusion detection devices of this chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'dell_power_gstat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)</strong> a partir de los siguientes atributos de la mib MIB-Dell-10892:<br><br><strong>MIB-Dell-10892::systemStatePowerUnitStatusCombined (GAUGE):</strong> "0200.0010.0001.0042 This attribute defines the combined status
 of all power units of this chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'dell_coolu_gstat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)</strong> a partir de los siguientes atributos de la mib MIB-Dell-10892:<br><br><strong>MIB-Dell-10892::systemStateCoolingUnitStatusCombined (GAUGE):</strong> "0200.0010.0001.0044 This attribute defines the combined status
 of all cooling units of this chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'dell_proc_gstat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)</strong> a partir de los siguientes atributos de la mib MIB-Dell-10892:<br><br><strong>MIB-Dell-10892::systemStateProcessorDeviceStatusCombined (GAUGE):</strong> "0200.0010.0001.0050 This attribute defines the combined status of all
 processor devices of this chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'dell_battery_gstat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)</strong> a partir de los siguientes atributos de la mib MIB-Dell-10892:<br><br><strong>MIB-Dell-10892::systemStateBatteryStatusCombined (GAUGE):</strong> "0200.0010.0001.0052 This attribute defines the combined status of all
 batteries of this chassis."
',
	);

	$TIPS[]=array(
		'id_ref' => 'dell_adisk_stat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ok(3)|unknown(2)|critical(5)|nonCritical(4)|nonRecoverable(6)|other(1)</strong> a partir de los siguientes atributos de la mib StorageManagement-MIB:<br><br><strong>StorageManagement-MIB::arrayDiskState (GAUGE):</strong> "The current condition of the array disk.
 				Possible states:
 				 0: Unknown
 				 1: Ready - Available for use, but no RAID configuration has been assigned. 
 				 2: Failed - Not operational.
 				 3: Online - Operational. RAID configuration has been assigned.
 				 4: Offline - The drive is not available to the RAID controller. 
 				 6: Degraded - Refers to a fault-tolerant array/virtual disk that has a failed disk. 
 				 7: Recovering - Refers to state of recovering from bad blocks on disks. 
 				11: Removed - Indicates that array disk has been removed. 
 				15: Resynching - Indicates one of the following types of disk operations: Transform Type, Reconfiguration, and Check Consistency. 
 				24: Rebuild
 				25: No Media - CD-ROM or removable disk has no media. 
 				26: Formatting - In the process of formatting. 
 				28: Diagnostics - Diagnostics are running. 
 				34: Predictive failure
 				35: Initializing: Applies only to virtual disks on PERC, PERC 2/SC, and PERC 2/DC controllers.
 				39: Foreign
 				40: Clear
 				41: Unsupported
 				53: Incompatible
 				
 				"
',
	);

	$TIPS[]=array(
		'id_ref' => 'dell_adisk_cstat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ready(1)|offline(4)|failed(2)|degraded(6)|online(3)</strong> a partir de los siguientes atributos de la mib StorageManagement-MIB:<br><br><strong>StorageManagement-MIB::controllerState (GAUGE):</strong> "The current condition of the controllers subsystem 
 				(which includes any devices connected to it.)
 				Possible states:
 				0: Unknown
 				1: Ready
 				2: Failed
 				3: Online
 				4: Offline
 				6: Degraded"
',
	);

?>
