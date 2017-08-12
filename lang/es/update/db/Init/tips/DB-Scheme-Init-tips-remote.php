<?
	$TIPS[]=array(
		'id_ref' => 'SNMPv2-MIB::coldStart',
		'tip_type' => 'remote' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Alerta generada por trap SNMP, que reporta <strong>el reinicio en frio de un dispositivo. Definido en la MIB: </strong>IF-MIB<br><br><strong>"A coldStart trap signifies that the SNMP entity, supporting a notification originator application, is reinitializing itself and that its configuration may have been altered."</strong>',
	);

	$TIPS[]=array(
		'id_ref' => 'SNMPv2-MIB::warmStart',
		'tip_type' => 'remote' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Alerta generada por trap SNMP, que reporta: <strong>el reinicio en caliente de un dispositivo. Definido en la MIB: </strong>IF-MIB<br><br><strong>"A warmStart trap signifies that the SNMP entity, supporting a notification originator application, is reinitializing itself such that its configuration is unaltered."</strong>',
	);

	$TIPS[]=array(
		'id_ref' => 'IF-MIB::linkDown',
		'tip_type' => 'remote' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Alerta generada por trap SNMP, que reporta: <strong>la caida de un interfaz. Definido en la MIB: </strong>IF-MIB<br><br><strong>"A linkDown trap signifies that the SNMP entity, acting in an agent role, has detected that the ifOperStatus object for one of its communication links is about to enter the down state from some other state (but not from the notPresent state).  This other state is indicated by the included value of ifOperStatus."</strong>',
	);

	$TIPS[]=array(
		'id_ref' => 'IF-MIB::linkUp',
		'tip_type' => 'remote' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Alerta generada por trap SNMP, que reporta: <strong>la activaci&oacute;n de un interfaz. Definido en la MIB: </strong>IF-MIB<br><br><strong>"A linkUp trap signifies that the SNMP entity, acting in an agent role, has detected that the ifOperStatus object for one of its communication links left the down state and transitioned into some other state (but not into the notPresent state).  This other state is indicated by the included value of ifOperStatus."</strong>',
	);

	$TIPS[]=array(
		'id_ref' => 'SNMPv2-MIB::authenticationFailure',
		'tip_type' => 'remote' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => 'Alerta generada por trap SNMP, que reporta: <strong>un error de autenticaci&oacute;n sobre un equipo (acceso SNMP con credenciales incorrectas). Definido en la MIB: </strong>IF-MIB<br><br><strong>"An authenticationFailure trap signifies that the SNMP entity has received a protocol message that is not properly authenticated.  While all implementations of SNMP entities MAY be capable of generating this trap, the snmpEnableAuthenTraps object indicates whether this trap will be generated."</strong>',
	);

	$TIPS[]=array(
		'id_ref' => 'TRAP-TEST-MIB::demotraps:6.TRAP-TEST-MIB::demo-trap',
		'tip_type' => 'remote' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => '',
	);

	$TIPS[]=array(
		'id_ref' => 'NOTIFICATION-TEST-MIB::demo-notif',
		'tip_type' => 'remote' , 'url' => '',
		'name' => 'Descripcion',
		'descr' => '',
	);

?>
