<?
	$TIPS[]=array(
		'id_ref' => 'linux_metric_certificate_expiration_time.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>CADUCIDAD DE CERTIFICADO SSL</strong><br>Obtiene el tiempo que falta para que expire un certificado SSL en segundos y en horas.<br><strong>cnm:/home#linux_metric_certificate_expiration_time.pl 1.1.1.1 443</strong><br><001> Seconds for expiration = 23625802<br><002> Days for expiration = 273',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_metric_mysql_var.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>OBTIENE METRICAS DE SISTEMA DE MySQL</strong><br>Obtiene medidas sobre el uso de buffers, cache o conexiones de la BBDD<br><strong>cnm:/home#linux_metric_mysql_var.pl -user user12 -pwd xxxx -host 1.1.1.1</strong><br><001> buffer_used = 0.11<br><002> read_hits = 99.99<br><003> write_hits = 75.49<br><003> connections = 13.33',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_metric_mail_loop.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>IMPLEMENTA UN BUCLE DE CORREO</strong><br>Obtiene el tiempo (en segs) empleado en el enviar por SMTP un correo a traves del MX especificado y recibirlo por POP3 en el buzon especificado',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_metric_ssh_files_per_proccess.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>CALCULA LOS FICHEROS ABIERTOS POR UN PROCESO CONCRETO</strong><br>Establece una sesion SSH con un equipo remoto y obtiene mediante un comando de bash el numero de ficheroa abiertos por un proceso determinado.<br><strong>cnm:/home#linux_metric_ssh_files_per_proccess.pl -n 1.1.1.1 -u user -p pwd -a apache</strong><br><001> Files opened [apache] = 1544',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_metric_ssh_files_in_dir.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>CALCULA EL NUMERO DE FICHEROS EN UN DIRECTORIO</strong><br>Establece una sesion SSH con un equipo remoto y obtiene mediante un comando de bash el numero de ficheros presentes en un directorio<br><strong>cnm:/home#linux_metric_ssh_files_in_dir.pl -n 1.1.1.1 -u user -p pwd -d /opt [-a pattern]</strong><br><001> Number of Files [/opt|.] = 7',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_metric_route_tag.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>CALCULA LA RUTA A UN DESTINO</strong><br>Obtiene el numero de saltos necesarios para llegar a una IP especificada como parametro. Tambien proporciona un hash MD5 de los saltos para detectar cambios en la misma. Utiliza el comando traceroute con TCP SYNCs.<br><strong>cnm:/home#linux_metric_route_tag.pl -host 1.1.1.1</strong><br><001> Route Tag = 317488<br><002> Number of Hops = 1',
	);

	$TIPS[]=array(
		'id_ref' => 'win32_metric_wmi_core.vbs',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>OBTIENE LOS VALORES DE LOS DIFERENTES CONTADORES WMI</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_metric_snmp_count_proc_multiple_devices.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>OBTIENE EL NUMERO DE PROCESOS EN EJECUCION DE UN DETERMINADO PROCESO EN DIFERENTES EQUIPOS</strong><br>',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_metric_mon_dns.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>OBTIENE DIFERENTES METRICAS DEL SERVICIO DNS</strong><br><strong>cnm:/home#linux_metric_mon_dns.pl -n 192.168.1.254</strong><br><001> Tiempo de respuesta = 0.079323<br><002> TTL = 60',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_metric_mon_http_uri_response.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>OBTIENE DIFERENTES METRICAS DE UN SERVICIO WEB</strong><br><strong>cnm:/home#linux_metric_mon_http_uri_response.pl -u http://www.s30labs.com</strong><br><001> Tiempo de respuesta = 0.781416<br><002> Codigo de error = 200<br><003> Clase de codigo de error = 2<br><004> Numero de links = 49<br><005> Coincidencias de la respuesta = 20',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_metric_mon_imap.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>OBTIENE DIFERENTES METRICAS DEL SERVICIO IMAP (CORREO)</strong><br><strong>cnm:/home#linux_metric_mon_imap.pl -n imap.gmail.com -u info@x.com -c xxxxx</strong><br><001> Tiempo de respuesta = 0.840061<br><002> Mensajes en INBOX = 1<br><003> Mensajes Totales = 2396<br><004> Buzones = 15',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_metric_mon_pop3.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>OBTIENE DIFERENTES METRICAS DEL SERVICIO POP3 (CORREO)</strong><br><strong>cnm:/home#linux_metric_mon_pop3.pl -n pop.gmail.com -u info@x.com -c xxxx</strong><br><001> Tiempo de respuesta = 1.189745<br><002> Mensajes = 1',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_metric_mon_smtp.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>OBTIENE DIFERENTES METRICAS DEL SERVICIO SMTP (CORREO)</strong><br><strong>cnm:/home#linux_metric_mon_smtp.pl -n smtp.gmail.com</strong><br><001> Tiempo de respuesta = 0.156630<br><002> Codigo de error = 250<br><003> Clase de codigo de error = 2',
	);

	$TIPS[]=array(
		'id_ref' => 'linux_metric_wmi_perfOS.pl',
		'tip_type' => 'script',
		'name' => 'Descripcion',
		'descr' => '<strong>OBTIENE METRICAS WMI DE UN EQUIPO WINDOWS</strong><br><strong>cnm:/home#linux_metric_wmi_perfOS.pl -n IP -u user -p pwd -d domain</strong><br>',
	);

?>
