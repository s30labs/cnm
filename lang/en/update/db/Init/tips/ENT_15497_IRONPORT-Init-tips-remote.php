<?
	$TIPS[]=array(
		'id_ref' => 'ASYNCOS-MAIL-MIB::resourceConservationMode',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Memory or queue utilization caused system to enter resource
          conservation mode."
v1: <strong>resourceConservationReason</strong><br>"Reason system is in Resource Conservation Mode."
<br>INTEGER {noResourceConservation(1), memoryShortage(2), queueSpaceShortage(3), queueFull(4)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'ASYNCOS-MAIL-MIB::powerSupplyStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Sent when power supply status changes."
v1: <strong>powerSupplyStatus</strong><br>"The overall status of power supply."
<br>INTEGER {powerSupplyNotInstalled(1), powerSupplyHealthy(2), powerSupplyNoAC(3), powerSupplyFaulty(4)} 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'ASYNCOS-MAIL-MIB::highTemperature',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Temperature has exceeded a recoverable failure threshold."
v1: <strong>temperatureName</strong><br>"Descriptive name of measurement.  E.g. Ambient Temperature."
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'ASYNCOS-MAIL-MIB::fanFailure',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Speed of fan fanName has gone to zero."
v1: <strong>fanName</strong><br>"Name of Fan.  E.g., FAN 1."
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'ASYNCOS-MAIL-MIB::keyExpiration',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Key will expire."
v1: <strong>keyDescription</strong><br>"Description of key."
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'ASYNCOS-MAIL-MIB::updateFailure',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Update failure (spam rules, virus patterns, outbreak updates, etc.)"
v1: <strong>updateServiceName</strong><br>"Name of service for which update has been done."
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'ASYNCOS-MAIL-MIB::raidStatusChange',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Drive with ID: RAIDID has changed status."
v1: <strong>raidID</strong><br>"Name of RAID component.  E.g.: RAID 1, DISK 2."
<br>OCTET STRING (0..255) 
   <br>',
	);

?>
