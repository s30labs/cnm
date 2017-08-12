<?
	$CFG_MONITOR[]=array(
		'monitor' => 'disp_icmp',
		'description' => 'DISPONIBILIDAD ICMP (ping)',
		'items' => 'Disponible|No computable|No Disponible|Desconocido',
		'vlabel' => 'estado',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_icmp',
		'description' => 'SERVICIO ICMP (ping)',
		'items' => 'Tiempo de Respuesta',
		'vlabel' => 'segs',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ip_icmp2',
		'description' => 'SERVICIO ICMP - PRIORIDAD MEDIA (ping)',
		'items' => 'Tiempo de Respuesta',
		'vlabel' => 'segs',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ip_icmp3',
		'description' => 'SERVICIO ICMP - PRIORIDAD BAJA (ping)',
		'items' => 'Tiempo de Respuesta',
		'vlabel' => 'segs',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_http',
		'description' => 'WWW - TIEMPO DE RESPUESTA',
		'items' => 'Tiempo de Respuesta',
		'vlabel' => 'segs',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_httprc',
		'description' => 'WWW - RESPUESTA DEL SERVIDOR',
		'items' => 'Codigo de Respuesta',
		'vlabel' => 'tiempo',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_httplinks',
		'description' => 'WWW - NUMERO DE ENLACES',
		'items' => 'Numero de Enlaces',
		'vlabel' => 'num',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_httppage',
		'description' => 'WWW - DIFERENCIAS EN LA PAGINA',
		'items' => 'Numero de Diferencias',
		'vlabel' => 'diffs',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_pop3',
		'description' => 'POP3',
		'items' => 'Tiempo de Respuesta',
		'vlabel' => 'tiempo',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_imap',
		'description' => 'IMAP',
		'items' => 'Tiempo de Respuesta',
		'vlabel' => 'tiempo',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_smtp',
		'description' => 'SMTP',
		'items' => 'Tiempo de Respuesta',
		'vlabel' => 'tiempo',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_dns',
		'description' => 'DNS',
		'items' => 'Tiempo de Respuesta',
		'vlabel' => 'tiempo',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_tcp',
		'description' => 'TCP PORT',
		'items' => 'Tiempo de Respuesta',
		'vlabel' => 'tiempo',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ssh',
		'description' => 'SSH',
		'items' => 'Tiempo de Respuesta',
		'vlabel' => 'tiempo',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_snmp',
		'description' => 'Monitor de variable snmp',
		'items' => 'Tiempo de Respuesta',
		'vlabel' => 'tiempo',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_smb',
		'description' => 'SMB/CIFS - ACCESO A FICHERO',
		'items' => 'Size',
		'vlabel' => 'bytes',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ntp',
		'description' => 'NTP',
		'items' => 'Tiempo de Respuesta',
		'vlabel' => 'tiempo',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_xagent',
		'description' => 'MONITOR DE AGENTE REMOTO (XAGENT)',
		'items' => 'Tiempo de Respuesta',
		'vlabel' => 'tiempo',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ldap',
		'description' => 'LDAP',
		'items' => 'tiempo',
		'vlabel' => 'tiempo',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ldap_attr',
		'description' => 'LDAP - ATTR',
		'items' => '0 NOK, 1 OK',
		'vlabel' => 'tiempo',
	);

	$CFG_MONITOR[]=array(
		'monitor' => 'mon_ldap_val',
		'description' => 'LDAP - VAL',
		'items' => 'valor',
		'vlabel' => 'tiempo',
	);

?>
