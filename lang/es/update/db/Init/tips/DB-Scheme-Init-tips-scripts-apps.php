<?
	$TIPS[]=array(
		'id_ref' => 'ws_set_device',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Modifica campos de dispositivo</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'ws_get_csv_devices',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Obtiene el inventario de dispositivos del sistema</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'ws_get_csv_metrics',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Obtiene el inventario de metricas del sistema</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'ws_get_csv_views',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Obtiene el inventario de vistas del sistema</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'ws_get_csv_view_metrics',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Obtiene el inventario de metricas asociadas a una vista definida en el sistema</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'audit',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Realiza una auditoria de los rangos de IPs especificados</strong><br>Los rangos se pueden especificar de la siguiente forma:<br>audit -a 1.1.1.1-20<br>audit -a 1.1.1.1,2.2.2.2<br>audit -a 1.1.1.0/24<br>audit -a 1.1.1.*',
	);

	$TIPS[]=array(
		'id_ref' => 'generate_report.php',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Generador de informes del sistema</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_app_restore_passive_from_active.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Si el equipo es PASIVO, le permite recuperar datos desde el Backup de un equipo ACTIVO.</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'mib2_if',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Obtiene una tabla con los interfaces configurados en el dispositivo</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'mibhost_disk',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Obtiene una tabla con datos sobre el uso de disco del dispositivo</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'get_cdp',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Obtiene una tabla con los vecinos CDP del dispositivo</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'cisco_ccm_device_pools',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Obtiene una tabla con datos sobre los Device Pools definidos en un Call Manager de Cisco</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'snmptable',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Permite obtener una tabla SNMP del dispositivo en base a un fichero descriptor</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'cnm-ping',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Ping a dispositivo</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'cnm-traceroute',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Traceroute a dispositivo</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'cnm-nmap',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Escaneo de puertos a dispositivo</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_tcp',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Monitor de puerto TCP de dispositivo</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'cnm-sslcerts',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Obtiene la informacion relevante de los certificados SSL de un servidor</strong><br>Utiliza el comando openssl de linux con la opcion s_client.',
	);

	$TIPS[]=array(
		'id_ref' => 'mon_smtp_ext',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Obtiene el banner de un servidor SMTP</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_app_get_conf_telnet_comtrend_router.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Obtiene la configuracíon de un router COMTREND conectandose mediante Telnet y ejecutando el comando dumpcfg</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_app_get_conf_telnet_cisco_router.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Obtiene la configuracíon de un equipo (router, switch ...) con CISCO IOS conectandose mediante Telnet y ejecutando el comando show running config</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_app_check_remote_cfgs.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>Obtiene las diferencias encontradas entre los ficheros de configuracion almacenados de un dispositivo</strong><br>',
	);

?>
