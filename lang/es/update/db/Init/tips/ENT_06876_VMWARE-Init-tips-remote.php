<?
	$TIPS[]=array(
		'id_ref' => 'VMWARE-TRAPS-MIB::vmPoweredOn',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"This trap is sent when a virtual machine is powered ON from a suspended 
        or a powered off state."
v1: <strong>vmID</strong><br>"This is the ID of the affected vm generating the trap. If the vmID
       is non-existent, (such as for a power-off trap) -1 is returned."
<br>INTEGER
   <br>v2: <strong>vmConfigFile</strong><br>"This is the config file of the affected vm generating the trap."
<br>OCTET STRING
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'VMWARE-TRAPS-MIB::vmPoweredOff',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"This trap is sent when a virtual machine is powered OFF."
v1: <strong>vmID</strong><br>"This is the ID of the affected vm generating the trap. If the vmID
       is non-existent, (such as for a power-off trap) -1 is returned."
<br>INTEGER
   <br>v2: <strong>vmConfigFile</strong><br>"This is the config file of the affected vm generating the trap."
<br>OCTET STRING
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'VMWARE-TRAPS-MIB::vmHBLost',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"This trap is sent when a virtual machine detects a loss in guest heartbeat."
v1: <strong>vmID</strong><br>"This is the ID of the affected vm generating the trap. If the vmID
       is non-existent, (such as for a power-off trap) -1 is returned."
<br>INTEGER
   <br>v2: <strong>vmConfigFile</strong><br>"This is the config file of the affected vm generating the trap."
<br>OCTET STRING
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'VMWARE-TRAPS-MIB::vmHBDetected',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"This trap is sent when a virtual machine detects or regains the guest heartbeat."
v1: <strong>vmID</strong><br>"This is the ID of the affected vm generating the trap. If the vmID
       is non-existent, (such as for a power-off trap) -1 is returned."
<br>INTEGER
   <br>v2: <strong>vmConfigFile</strong><br>"This is the config file of the affected vm generating the trap."
<br>OCTET STRING
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'VMWARE-TRAPS-MIB::vmSuspended',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"This trap is sent when a virtual machine is suspended."
v1: <strong>vmID</strong><br>"This is the ID of the affected vm generating the trap. If the vmID
       is non-existent, (such as for a power-off trap) -1 is returned."
<br>INTEGER
   <br>v2: <strong>vmConfigFile</strong><br>"This is the config file of the affected vm generating the trap."
<br>OCTET STRING
   <br>',
	);

?>
