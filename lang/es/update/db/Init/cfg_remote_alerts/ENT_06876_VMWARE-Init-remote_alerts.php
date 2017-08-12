<?
	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'VMWARE-TRAPS-MIB::vmPoweredOn',
		'hiid' => '842b1bd2b7',
		'descr' => 'MAQUINA VIRTUAL ARRANCADA',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'VMWARE-TRAPS-MIB::vmPoweredOff',
		'hiid' => '842b1bd2b7',
		'descr' => 'MAQUINA VIRTUAL APAGADA',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'VMWARE-TRAPS-MIB::vmHBLost',
		'hiid' => '842b1bd2b7',
		'descr' => 'PERDIDA DE HEATBEAT CON EL HOST',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'VMWARE-TRAPS-MIB::vmHBDetected',
		'hiid' => '842b1bd2b7',
		'descr' => 'RECUPERADO HEATBEAT CON EL HOST',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'VMWARE-TRAPS-MIB::vmSuspended',
		'hiid' => '842b1bd2b7',
		'descr' => 'MAQUINA VIRTUAL SUSPENDIDA',
	);

?>
