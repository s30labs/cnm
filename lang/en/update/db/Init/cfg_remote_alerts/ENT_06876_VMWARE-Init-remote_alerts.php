<?
	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'VMWARE-TRAPS-MIB::vmPoweredOn',
		'hiid' => '842b1bd2b7',
		'descr' => 'VIRTUAL MACHINE POWERED ON',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'VMWARE-TRAPS-MIB::vmPoweredOff',
		'hiid' => '842b1bd2b7',
		'descr' => 'VIRTUAL MACHINE POWERED OFF',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'VMWARE-TRAPS-MIB::vmHBLost',
		'hiid' => '842b1bd2b7',
		'descr' => 'LOST HEARTBEAT WITH THE HOST',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'VMWARE-TRAPS-MIB::vmHBDetected',
		'hiid' => '842b1bd2b7',
		'descr' => 'DETECTED HEARTBEAT WITH THE HOST',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'VMWARE-TRAPS-MIB::vmSuspended',
		'hiid' => '842b1bd2b7',
		'descr' => 'VIRTUAL MACHINE SUSPENDED',
	);

?>
