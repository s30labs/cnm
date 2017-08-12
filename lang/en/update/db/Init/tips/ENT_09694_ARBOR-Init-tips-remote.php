<?
	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::subHostDown',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Generated when a subhost transitions to inactive"
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapSubhostName</strong><br>"Temporary string for reporting the name of a subhost"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailProtectionGroupError',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"A protection group has an error"
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailProtectionGroupId</strong><br>"Protection group id."
<br>Unsigned32
   <br>v5: <strong>pravailProtectionGroupName</strong><br>"Name of this protection group"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailConfigMissing',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"This is no longer used."
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailConfigError',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Generated when an internal configuration error is detected."
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailHwDeviceDown',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"A hardware device has failed."
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailHwSensorCritical',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"A hardware sensor is reading an alarm condition."
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailSwComponentDown',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"A software program has failed."
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapSubhostName</strong><br>"Temporary string for reporting the name of a subhost"
<br>OCTET STRING (0..255) 
   <br>v5: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailSystemStatusCritical',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The Pravail system is experiencing a critical failure."
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailSystemStatusDegraded',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The Pravail system is experiencing degraded performance."
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailFilesystemCritical',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"A filesystem is near capacity."
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailGRETunnelFailure',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"A GRE tunnel failed."
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailNextHopUnreachable',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The next hop system is unreachable from the Pravail system."
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailPerformance',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The Pravail system is dropping traffic because of high 
                  traffic rates."
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailSystemStatusError',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The Pravail system is experiencing an error."
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailCloudSignalTimeout',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"There is a timeout communicating with cloud services"
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailCloudSignalThreshold',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"There is a threshold error with cloud services"
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailTrapTraffic',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Traffic exceeded the threshold for a Pravail protection group"
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailTrapBotnetAttack',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Botnet traffic which was detected but not blocked
                  exceed the threshold for a Pravail protection group"
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailTrapLicenseLimit',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"The total bandwidth of traffic in the Pravail system
                  is approaching the license limit"
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailURL</strong><br>"URL on a Pravail device which contains additional information
                  about the event which caused a Trap notification to be sent."
<br>OCTET STRING (0..255) 
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'PRAVAIL-MIB::pravailTrapBlockedTraffic',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Blocked traffic exceeded the threshold for a Pravail 
                  protection group"
v1: <strong>sysName</strong><br><br><br>v2: <strong>pravailTrapString</strong><br>"Temporary string for reporting information in traps"
<br>OCTET STRING (0..255) 
   <br>v3: <strong>pravailTrapDetail</strong><br>"Temporary string for reporting additional detail (if any)
                 about a trap"
<br>OCTET STRING (0..255) 
   <br>v4: <strong>pravailTrapComponentName</strong><br>"Temporary string for reporting the name of a program or device"
<br>OCTET STRING (0..255) 
   <br>',
	);

?>
