<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_cpu_usage',
		'descr' => 'CPU USAGE (%)',
		'items' => 'perCentCPUUtilization.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_memory_usage',
		'descr' => 'MEMORY USAGE (%)',
		'items' => 'perCentMemoryUtilization.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_disk_usage',
		'descr' => 'DISK USAGE (%)',
		'items' => 'perCentDiskIOUtilization.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_queue_usage',
		'descr' => 'QUEUE UTILIZATION (%)',
		'items' => 'perCentQueueUtilization.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_open_files',
		'descr' => 'OPEN FILES/SOCKETS',
		'items' => 'openFilesOrSockets.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_mail_threads',
		'descr' => 'MAIL THREADS',
		'items' => 'mailTransferThreads.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_dns_failures',
		'descr' => 'DNS FAILURES',
		'items' => 'outstandingDNSRequests.0|pendingDNSRequests.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_queue_messages',
		'descr' => 'WORK QUEUE MESSAGES',
		'items' => 'workQueueMessages.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_oldest_message',
		'descr' => 'OLDEST MESSAGE AGE',
		'items' => 'oldestMessageAge.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_fanrpms1',
		'descr' => 'FAN SPEED (FAN 1)',
		'items' => 'fanRPMs.1',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_fanrpms2',
		'descr' => 'FAN SPEED (FAN 2)',
		'items' => 'fanRPMs.2',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_temperature1',
		'descr' => 'TEMPERATURE',
		'items' => 'degreesCelsius.1',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_keyexpiration',
		'descr' => 'KEY EXPIRATION',
		'items' => 'Days left',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_update_fail',
		'descr' => 'UPDATE FAILURES',
		'items' => 'updateFailures',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_update_rate',
		'descr' => 'UPDATE REATE',
		'items' => 'updates',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ironport_raid_status',
		'descr' => 'RAID STATUS',
		'items' => 'driveHealthy(1)|driveRebuild(3)|driveFailure(2)|unk',
	);

?>
