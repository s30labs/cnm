<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mon_snmp',
		'descr' => 'SIN RESPUESTA SNMP',
		'items' => '',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'disk_mibhost',
		'descr' => 'USO DE DISCO',
		'items' => 'Disco Total|Disco Usado',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'disk_mibhostp',
		'descr' => 'USO DE DISCO (%)',
		'items' => 'Disco Usado (%)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'proc_cnt_mibhost',
		'descr' => 'NUMERO DE PROCESOS',
		'items' => 'Numero de Procesos',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'users_cnt_mibhost',
		'descr' => 'NUMERO DE USUARIOS',
		'items' => 'Numero de Usuarios',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'esp_cpu_mibhost',
		'descr' => 'USO DE CPU',
		'items' => 'items_fx(cpu)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'esp_cpu_avg_mibhost',
		'descr' => 'USO PROMEDIADO DE CPU',
		'items' => 'Promedio de CPU',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'traffic_mibii_if',
		'descr' => 'TRAFICO EN INTERFAZ ',
		'items' => 'Bits RX|Bits TX',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'traffic_mibii_if_perc',
		'descr' => 'CONSUMO DE ANCHO DE BANDA',
		'items' => 'Porcentaje de uso',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'traffic_mibii_if_hc',
		'descr' => 'TRAFICO EN INTERFAZ (HC)',
		'items' => 'Bits RX|Bits TX',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkts_type_mibii_if',
		'descr' => 'TIPO DE TRAFICO EN INTERFAZ (UCAST/NUCAST)',
		'items' => 'PKTS ucast in|PKTS nucast in|PKTS ucast out|PKTS nucast out',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkts_type_mibii_if_ext',
		'descr' => 'TIPO DE TRAFICO EN INTERFAZ (UCAST/MUCAST/BCAST)',
		'items' => 'pkts ucast in|pkts mucast in|pkts bcast in|pkts ucast out|pkts mcast out|pkts bcast out',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkts_type_mibrmon',
		'descr' => 'TIPO DE TRAFICO EN INTERFAZ (RMON)',
		'items' => 'pkts totales |pkt broadcast |pkts multicast',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ip_pkts_discard',
		'descr' => 'PAQUETES IP DESCARTADOS',
		'items' => 'PKTS in|PKTS out',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tcp_estab',
		'descr' => 'SESIONES TCP ESTABLECIDAS',
		'items' => 'Sesiones TCP',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tcp_ap',
		'descr' => 'SESIONES TCP ACTIVAS/PASIVAS',
		'items' => 'Sesiones TCP Activas|Sesiones TCP Pasivas',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'udp_pkts',
		'descr' => 'PAQUETES UDP',
		'items' => 'Datagramas UDP IN|Datagramas UDP OUT',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'arp_mibii_cnt',
		'descr' => 'VECINOS EN LAN - ARP',
		'items' => 'Entradas en la tabla ARP',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'esp_arp_mibii_cnt',
		'descr' => 'VECINOS EN LAN - ARP',
		'items' => 'Entradas en la tabla ARP',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkts_discard_mibii_if',
		'descr' => 'PAQUETES DESCARTADOS EN INTERFAZ',
		'items' => 'pkts descartados in|pkts descartados out',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'errors_mibii_if',
		'descr' => 'ERRORES EN INTERFAZ',
		'items' => 'errores in|errores out',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'status_mibii_if',
		'descr' => 'ESTADO DE INTERFAZ',
		'items' => 'Up|Admin Down|Down|Unk',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'nortel_memory',
		'descr' => 'USO DE MEMORIA',
		'items' => 'Bytes libres|Bytes Totales',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'nortel_cpu',
		'descr' => 'USO DE CPU',
		'items' => 'Porcentaje de uso de CPU',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_memory',
		'descr' => 'USO DE MEMORIA',
		'items' => 'Bytes usados|Bytes libres',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_cpu',
		'descr' => 'USO DE CPU',
		'items' => 'Porcentaje de uso de CPU',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_buffer_usage',
		'descr' => 'USO DE BUFFERS DE MEMORIA',
		'items' => 'bufferSmallTotal|bufferMiddleTotal|bufferBigTotal|bufferLargeTotal|bufferHugeTotal',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_buffer_errors',
		'descr' => 'ERRORES EN BUFFERS DE MEMORIA',
		'items' => 'Buffer Failures|No Free Memory',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_ds0_usage',
		'descr' => 'OCUPACION DE BASICOS-RDSI',
		'items' => 'Ocupados RDSI (DS0s)|Maximo valor en DS0s',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_ds0_errors',
		'descr' => 'ERRORES EN BASICOS-RDSI',
		'items' => 'Reject RDSI|Sin recursos RDSI',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_modem_usage',
		'descr' => 'OCUPACION DE MODEMS ANALOGICOS',
		'items' => 'Modems ocupados|Modems disponibles',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_modem_errors',
		'descr' => 'ERRORES EN MODEMS ANALOGICOS',
		'items' => 'Reject en modem|Sin recursos de modem',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_wap_users',
		'descr' => 'USUARIOS ACTIVOS EN ACCESS POINT',
		'items' => 'Usuarios',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'enterasys_cpu_usage',
		'descr' => 'USO DE CPU',
		'items' => 'Uso de CPU',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'enterasys_flow3',
		'descr' => 'FLUJOS DE NIVEL3',
		'items' => 'Flujos de nivel 3 Aprendidos|Flujos de nivel 3 Caducados',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'enterasys_flow2',
		'descr' => 'FLUJOS DE NIVEL2',
		'items' => 'Flujos de nivel 2 Aprendidos|Flujos de nivel 2 Caducados',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'brocade_frames_port',
		'descr' => 'TRAFICO POR PUERTO FIBER-CHANNEL',
		'items' => 'Frames Tx (IID)|Frames Rx (IID)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'brocade_status_port',
		'descr' => 'ESTADO DEL PUERTO FIBER-CHANNEL',
		'items' => 'UP (IID)|DOWN (IID)|UNK (IID)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'novell_nw_fs_read_write',
		'descr' => 'ACTIVIDAD DEL SISTEMA DE FICHEROS',
		'items' => 'Lecturas|Escrituras',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'novell_nw_fs_cache',
		'descr' => 'USO DEL CACHE',
		'items' => 'Checks|Hits',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'novell_nw_open_files',
		'descr' => 'FICHEROS EN USO',
		'items' => 'Ficheros abiertos',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'novell_nw_disk_usage',
		'descr' => 'USO DE DISCO',
		'items' => 'Disco Total (IID)|Disco Libre (IID)|Disco Liberable (IID)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'novell_nw_disk_dir',
		'descr' => 'USO DE DIRECTORIOS',
		'items' => 'Directorios Totales (IID)|Directorios en Uso (IID)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'checkpoint_numconex',
		'descr' => 'NUMERO DE CONEXIONES',
		'items' => 'fwNumConn',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'checkpoint_peakconex',
		'descr' => 'MAXIMO NUMERO DE CONEXIONES',
		'items' => 'fwPeakNumConn',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucdavis_interrupts',
		'descr' => 'USO DE INTERRUPCIONES',
		'items' => 'Interrupciones|Cambios de Contexto',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucdavis_cpu',
		'descr' => 'USO DE CPU',
		'items' => 'User|System|Idle',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_files_sent',
		'descr' => 'Numero Total de Ficheros enviados',
		'items' => 'Ficheros',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_current_users',
		'descr' => 'Usuarios conectados actualmente',
		'items' => 'Anonimos|NoAnonimos',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_total_users',
		'descr' => 'Usuarios conectados',
		'items' => 'Anonimos|NoAnonimos',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_max_users',
		'descr' => 'Maximo numeo de Usuarios conectados',
		'items' => 'Anonimos|NoAnonimos',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_current_connections',
		'descr' => 'Conexiones actuales',
		'items' => 'Conexiones',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_connections',
		'descr' => 'Intentos de conexion',
		'items' => 'connectionAttempts|logonAttempts',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_request_type1',
		'descr' => 'Peticiones de tipo GET/POST/HEAD/Otros',
		'items' => 'totalGets|totalPosts|totalHeads|totalOthers',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_request_type2',
		'descr' => 'Peticiones de tipo CGI/BGI',
		'items' => 'totalCGIRequests.0|totalBGIRequests.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_error_notfound',
		'descr' => 'Error 404 - Page Not Found',
		'items' => 'totalNotFoundErrors.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'squid_cache_memory',
		'descr' => 'Uso de memoria por la cache',
		'items' => 'Kb',
	);

?>
