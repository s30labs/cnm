<?
	$TIPS[]=array(
		'id_ref' => 'app_ironport_keys',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra la caducidad de las licencias de los diferentes componentes del Ironport</strong><br>Utiliza la tabla SNMP ASYNCOS-MAIL-MIB::keyExpirationTable (Enterprise=15497)<br><br><strong>ASYNCOS-MAIL-MIB::keyDescription (GAUGE):</strong><br>"Description of key."
<strong>ASYNCOS-MAIL-MIB::keyIsPerpetual (GAUGE):</strong><br>"True if key is perpetual"
<strong>ASYNCOS-MAIL-MIB::keySecondsUntilExpire (GAUGE):</strong><br>"Seconds until key expires."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_ironport_updates',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra info sobre la actualizacion de los diferentes servicios del appliance</strong><br>Utiliza la tabla SNMP ASYNCOS-MAIL-MIB::updateTable (Enterprise=15497)<br><br><strong>ASYNCOS-MAIL-MIB::updateServiceName (GAUGE):</strong><br>"Name of service for which update has been done."
<strong>ASYNCOS-MAIL-MIB::updates (COUNTER):</strong><br>"Number of updates."
<strong>ASYNCOS-MAIL-MIB::updateFailures (COUNTER):</strong><br>"Number of update failures."
',
	);

	$TIPS[]=array(
		'id_ref' => 'app_ironport_performance',
		'tip_type' => 'app',
		'name' => 'Descripcion',
		'descr' => '<strong>Muestra informacion basica sobre diferentes parametros de rendimiento del equipo</strong><br>Utiliza atributos de la mib ASYNCOS-MAIL-MIB:<br><br><strong>ASYNCOS-MAIL-MIB::perCentCPUUtilization (GAUGE):</strong>&nbsp;"Percent CPU utilization."
<br><strong>ASYNCOS-MAIL-MIB::perCentMemoryUtilization (GAUGE):</strong>&nbsp;"Percent memory utilization."
<br><strong>ASYNCOS-MAIL-MIB::perCentDiskIOUtilization (GAUGE):</strong>&nbsp;"Percent disk I/O utilization."
<br><strong>ASYNCOS-MAIL-MIB::perCentQueueUtilization (GAUGE):</strong>&nbsp;"Percent of total queue capacity used."
<br><strong>ASYNCOS-MAIL-MIB::openFilesOrSockets (GAUGE):</strong>&nbsp;"Number of open files or sockets."
<br><strong>ASYNCOS-MAIL-MIB::mailTransferThreads (GAUGE):</strong>&nbsp;"Number of threads that perform some task related to 
          transferring mail."
<br><strong>ASYNCOS-MAIL-MIB::outstandingDNSRequests (GAUGE):</strong>&nbsp;"Number of DNS requests that have been sent but for which no
          reply has been received."
<br><strong>ASYNCOS-MAIL-MIB::pendingDNSRequests (GAUGE):</strong>&nbsp;"Number of DNS requests waiting to be sent."
<br><strong>ASYNCOS-MAIL-MIB::workQueueMessages (GAUGE):</strong>&nbsp;"Number of messages in the work queue."
<br><strong>ASYNCOS-MAIL-MIB::oldestMessageAge (GAUGE):</strong>&nbsp;"The number of seconds the oldest message has been in queue"
<br>',
	);

?>
