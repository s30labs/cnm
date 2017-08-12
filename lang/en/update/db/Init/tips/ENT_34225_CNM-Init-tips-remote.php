<?
	$TIPS[]=array(
		'id_ref' => 'CNM-NOTIFICATIONS-MIB::cnmNotifNoLinkSet',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Este trap se genera cuando se detecta que no hay link en el interfaz Ethernet. Lo mas probable es que se haya quitado el cable de red o el puerto del switch este deshabilitado. Si no es asi, revisar la placa de red del CNM por si hubiera un problema hardware"
v1: <strong>cnmNotifCode</strong><br>"Cadena de texto con un codigo sobre el trap."
<br>INTEGER
   <br>v2: <strong>cnmNotifMsg</strong><br>"Texto del trap."
<br>OCTET STRING
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CNM-NOTIFICATIONS-MIB::cnmNotiIFDownfSet',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Este trap se genera cuando se detecta que el interfaz Ethernet de trabajo esta caido o deshabilitado desde el sistema operativo del CNM"
v1: <strong>cnmNotifCode</strong><br>"Cadena de texto con un codigo sobre el trap."
<br>INTEGER
   <br>v2: <strong>cnmNotifMsg</strong><br>"Texto del trap."
<br>OCTET STRING
   <br>',
	);

	$TIPS[]=array(
		'id_ref' => 'CNM-NOTIFICATIONS-MIB::cnmNotifMCNMNoAccessToRemote',
		'tip_type' => 'remote',
		'name' => 'CNM-Info',
		'descr' => '"Este trap se genera cuando el CNM Central (Proxy) en un entorno Multi CNM no detecta un CNM remoto"
v1: <strong>cnmNotifCode</strong><br>"Cadena de texto con un codigo sobre el trap."
<br>INTEGER
   <br>v2: <strong>cnmNotifMsg</strong><br>"Texto del trap."
<br>OCTET STRING
   <br>',
	);

?>
