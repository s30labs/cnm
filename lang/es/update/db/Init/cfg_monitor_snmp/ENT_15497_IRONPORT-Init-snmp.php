<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_cpu_usage',
		'descr' => 'USO DE CPU (%)',
		'items' => 'perCentCPUUtilization.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_memory_usage',
		'descr' => 'USO DE MEMORIA (%)',
		'items' => 'perCentMemoryUtilization.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_disk_usage',
		'descr' => 'USO DE DISCO (%)',
		'items' => 'perCentDiskIOUtilization.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_queue_usage',
		'descr' => 'USO DE LA COLA (%)',
		'items' => 'perCentQueueUtilization.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_open_files',
		'descr' => 'FICHEROS/SOCKETS ABIERTOS',
		'items' => 'openFilesOrSockets.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_mail_threads',
		'descr' => 'THREADS DE CORREO',
		'items' => 'mailTransferThreads.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_dns_failures',
		'descr' => 'FALLOS EN DNS',
		'items' => 'outstandingDNSRequests.0|pendingDNSRequests.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_queue_messages',
		'descr' => 'MENSAJES EN LA COLA DE TRABAJO',
		'items' => 'workQueueMessages.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_oldest_message',
		'descr' => 'TIEMPO EN COLA DEL MENSAJE MAS ANTIGUO',
		'items' => 'oldestMessageAge.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_fanrpms1',
		'descr' => 'VELOCIDAD VENTILADOR (FAN 1)',
		'items' => 'fanRPMs.1',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_fanrpms2',
		'descr' => 'VELOCIDAD VENTILADOR (FAN 2)',
		'items' => 'fanRPMs.2',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_temperature1',
		'descr' => 'TEMPERATURA',
		'items' => 'degreesCelsius.1',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_keyexpiration',
		'descr' => 'CADUCIDAD DE LICENCIAS',
		'items' => 'Dias hasta la caducidad',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_update_fail',
		'descr' => 'FALLOS AL ACTUALIZAR',
		'items' => 'updateFailures',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_update_rate',
		'descr' => 'TASA DE ACTUALIZACIONES',
		'items' => 'updates',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_raid_status',
		'descr' => 'ESTADO DEL RAID',
		'items' => 'driveHealthy(1)|driveRebuild(3)|driveFailure(2)|unk',
	);

?>
