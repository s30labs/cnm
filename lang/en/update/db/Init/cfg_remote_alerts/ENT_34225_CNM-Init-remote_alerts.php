<?
	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'CNM-NOTIFICATIONS-MIB::cnmNotifNoLinkSet',
		'hiid' => '842b1bd2b7',
		'descr' => 'NO LINK IN NETWORK INTERFACE',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'CNM-NOTIFICATIONS-MIB::cnmNotiIFDownfSet',
		'hiid' => '842b1bd2b7',
		'descr' => 'NETWORK INTERFACE DOWN',
	);

	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'snmp',
		'subtype' => 'CNM-NOTIFICATIONS-MIB::cnmNotifMCNMNoAccessToRemote',
		'hiid' => '842b1bd2b7',
		'descr' => 'NO ACCESS TO REMOTE CNM',
	);

?>
