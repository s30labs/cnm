<?
	$TIPS[]=array(
		'id_ref' => 'app_asterisk_chan_type',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion sobre los diferentes tipos de canales soportados</strong><br>Utiliza la tabla SNMP ASTERISK-MIB::astChanTypeTable (Enterprise=22736)<br><br><strong>ASTERISK-MIB::astChanTypeName (GAUGE):</strong><br>"Unique name of the technology we are describing."
<strong>ASTERISK-MIB::astChanTypeDesc (GAUGE):</strong><br>"Description of the channel type (technology)."
<strong>ASTERISK-MIB::astChanTypeDeviceState (GAUGE):</strong><br>"Whether the current technology can hold device states."
<strong>ASTERISK-MIB::astChanTypeIndications (GAUGE):</strong><br>"Whether the current technology supports progress indication."
<strong>ASTERISK-MIB::astChanTypeTransfer (GAUGE):</strong><br>"Whether the current technology supports transfers, where
 		Asterisk can get out from inbetween two bridged channels."
<strong>ASTERISK-MIB::astChanTypeChannels (GAUGE):</strong><br>"Number of active channels using the current technology."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_asterisk_get_info',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion basica sobre el equipo</strong><br>Utiliza atributos de la mib ASTERISK-MIB:<br><br><strong>ASTERISK-MIB::astVersionString (GAUGE):</strong>&nbsp;"Text version string of the version of Asterisk that
 		the SNMP Agent was compiled to run against."
<br><strong>ASTERISK-MIB::astConfigPid (GAUGE):</strong>&nbsp;"The process id of the running Asterisk process."
<br><strong>ASTERISK-MIB::astConfigSocket (GAUGE):</strong>&nbsp;"The control socket for giving Asterisk commands."
<br><strong>ASTERISK-MIB::astNumModules (GAUGE):</strong>&nbsp;"Number of modules currently loaded into Asterisk."
<br><strong>ASTERISK-MIB::astConfigUpTime (GAUGE):</strong>&nbsp;"Time ticks since Asterisk was started."
<br><strong>ASTERISK-MIB::astConfigReloadTime (GAUGE):</strong>&nbsp;"Time ticks since Asterisk was last reloaded."
<br>',
	);

?>
