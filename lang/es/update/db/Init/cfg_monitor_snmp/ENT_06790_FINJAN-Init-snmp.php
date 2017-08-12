<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_scan_reqs',
		'descr' => 'TASA DE ESCANEO',
		'items' => 'vsScannerReqs-per-second.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_scan_thro',
		'descr' => 'TASA DE TRANSFERENCIA',
		'items' => 'vsScannerThroughput-in-total.0|vsScannerThroughput-out-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_sum_block',
		'descr' => 'PETICIONES BLOQUEADAS (TOTALES)',
		'items' => 'vsSummaryBlocked-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_det_block',
		'descr' => 'PETICIONES BLOQUEADAS (DETALLE)',
		'items' => 'vsScannerBlocked-AV-total.0|vsScannerBlocked-BA-total.0|vsScannerBlocked-blackList-total.0|vsScannerBlocked-URLCat-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_sum_log',
		'descr' => 'PETICIONES REGISTRADAS (TOTALES)',
		'items' => 'vsSummaryLogged-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_det_log',
		'descr' => 'PETICIONES REGISTRADAS (DETALLE)',
		'items' => 'vsScannerLogged-logsDb-total.0|vsScannerLogged-archive-total.0|vsScannerLogged-reportsDb-total.0|vsScannerLogged-syslog-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_scan_reqs_tot',
		'descr' => 'PETICIONES ESCANEADAS (TOTALES)',
		'items' => 'vsScannerReqs-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_scan_reqs_det',
		'descr' => 'PETICIONES ESCANEADAS (DETALLE)',
		'items' => 'vsHTTPReqs-total.0|vsHTTPSReqs-total.0|vsFTPReqs-total.0|vsICAPReqs-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_http_thro',
		'descr' => 'TASA DE TRANSFERENCIA HTTP',
		'items' => 'vsHTTPThroughput-in-total.0|vsHTTPThroughput-out-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_http_block',
		'descr' => 'PETICIONES HTTP BLOQUEADAS (TOTALES)',
		'items' => 'vsHTTPBlocked-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_http_block_det',
		'descr' => 'PETICIONES HTTP BLOQUEADAS (DETALLE)',
		'items' => 'vsHTTPBlocked-AV-total.0|vsHTTPBlocked-BA-total.0|vsHTTPBlocked-blackList-total.0|vsHTTPBlocked-URLCat-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_https_thro',
		'descr' => 'TASA DE TRANSFERENCIA HTTPS',
		'items' => 'vsHTTPSThroughput-in-total.0|vsHTTPSThroughput-out-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_https_block',
		'descr' => 'PETICIONES HTTPS BLOQUEADAS (TOTALES)',
		'items' => 'vsHTTPSBlocked-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_https_block_det',
		'descr' => 'PETICIONES HTTPS BLOQUEADAS (DETALLE)',
		'items' => 'vsHTTPSBlocked-AV-total.0|vsHTTPSBlocked-BA-total.0|vsHTTPSBlocked-blackList-total.0|vsHTTPSBlocked-URLCat-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_ftp_thro',
		'descr' => 'TASA DE TRANSFERENCIA FTP',
		'items' => 'vsFTPThroughput-in-total.0|vsFTPThroughput-out-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_ftp_block',
		'descr' => 'PETICIONES FTP BLOQUEADAS (TOTALES)',
		'items' => 'vsFTPBlocked-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_ftp_block_det',
		'descr' => 'PETICIONES FTP BLOQUEADAS (DETALLE)',
		'items' => 'vsFTPBlocked-AV-total.0|vsFTPBlocked-BA-total.0|vsFTPBlocked-blackList-total.0|vsFTPBlocked-URLCat-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_icap_thro',
		'descr' => 'TASA DE TRANSFERENCIA ICAP',
		'items' => 'vsICAPThroughput-in-total.0|vsICAPThroughput-out-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_icap_block',
		'descr' => 'PETICIONES ICAP BLOQUEADAS (TOTALES)',
		'items' => 'vsICAPBlocked-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_icap_block_det',
		'descr' => 'PETICIONES ICAP BLOQUEADAS (DETALLE)',
		'items' => 'vsICAPBlocked-AV-total.0|vsICAPBlocked-BA-total.0|vsICAPBlocked-blackList-total.0|vsICAPBlocked-URLCat-total.0',
	);

?>
