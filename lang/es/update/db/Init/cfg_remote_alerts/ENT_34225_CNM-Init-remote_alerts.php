<?
	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'CNM-NOTIFICATIONS-MIB::cnmNotifNoLinkSet',
		'hiid' => '842b1bd2b7',
		'descr' => 'EL INTERFAZ DE RED NO TIENE LINK',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'CNM-NOTIFICATIONS-MIB::cnmNotiIFDownfSet',
		'hiid' => '842b1bd2b7',
		'descr' => 'EL INTERFAZ DE RED ESTA CAIDO',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'CNM-NOTIFICATIONS-MIB::cnmNotifMCNMNoAccessToRemote',
		'hiid' => '842b1bd2b7',
		'descr' => 'SIN ACCESO A CNM REMOTO',
	);

?>
