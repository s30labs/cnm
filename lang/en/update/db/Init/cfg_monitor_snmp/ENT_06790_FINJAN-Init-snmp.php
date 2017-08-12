<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_scan_reqs',
		'descr' => 'SCAN RATE',
		'items' => 'vsScannerReqs-per-second.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_scan_thro',
		'descr' => 'SCANNER THROUGHPUT',
		'items' => 'vsScannerThroughput-in-total.0|vsScannerThroughput-out-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_sum_block',
		'descr' => 'BLOCKED SUMMARY (TOTAL)',
		'items' => 'vsSummaryBlocked-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_det_block',
		'descr' => 'SCANNER BLOCKED (DETAILED)',
		'items' => 'vsScannerBlocked-AV-total.0|vsScannerBlocked-BA-total.0|vsScannerBlocked-blackList-total.0|vsScannerBlocked-URLCat-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_sum_log',
		'descr' => 'LOGGED SUMMARY (TOTAL)',
		'items' => 'vsSummaryLogged-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_det_log',
		'descr' => 'LOGGED SCANNER (DETAIL)',
		'items' => 'vsScannerLogged-logsDb-total.0|vsScannerLogged-archive-total.0|vsScannerLogged-reportsDb-total.0|vsScannerLogged-syslog-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_scan_reqs_tot',
		'descr' => 'SCANNER REQUESTS (TOTAL)',
		'items' => 'vsScannerReqs-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_scan_reqs_det',
		'descr' => 'SCANNER REQUESTS (DETAIL)',
		'items' => 'vsHTTPReqs-total.0|vsHTTPSReqs-total.0|vsFTPReqs-total.0|vsICAPReqs-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_http_thro',
		'descr' => 'HTTP THROUGHPUT',
		'items' => 'vsHTTPThroughput-in-total.0|vsHTTPThroughput-out-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_http_block',
		'descr' => 'HTTP BLOCKED (TOTAL)',
		'items' => 'vsHTTPBlocked-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_http_block_det',
		'descr' => 'HTTP BLOCKED (DETAIL)',
		'items' => 'vsHTTPBlocked-AV-total.0|vsHTTPBlocked-BA-total.0|vsHTTPBlocked-blackList-total.0|vsHTTPBlocked-URLCat-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_https_thro',
		'descr' => 'HTTPS THROUGHPUT',
		'items' => 'vsHTTPSThroughput-in-total.0|vsHTTPSThroughput-out-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_https_block',
		'descr' => 'HTTPS BLOCKED (TOTAL)',
		'items' => 'vsHTTPSBlocked-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_https_block_det',
		'descr' => 'HTTPS BLOCKED (DETAIL)',
		'items' => 'vsHTTPSBlocked-AV-total.0|vsHTTPSBlocked-BA-total.0|vsHTTPSBlocked-blackList-total.0|vsHTTPSBlocked-URLCat-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_ftp_thro',
		'descr' => 'FTP THROUGHPUT',
		'items' => 'vsFTPThroughput-in-total.0|vsFTPThroughput-out-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_ftp_block',
		'descr' => 'FTP BLOCKED (TOTAL)',
		'items' => 'vsFTPBlocked-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_ftp_block_det',
		'descr' => 'FTP BLOCKED (DETAIL)',
		'items' => 'vsFTPBlocked-AV-total.0|vsFTPBlocked-BA-total.0|vsFTPBlocked-blackList-total.0|vsFTPBlocked-URLCat-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_icap_thro',
		'descr' => 'ICAP THROUGHPUT',
		'items' => 'vsICAPThroughput-in-total.0|vsICAPThroughput-out-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_icap_block',
		'descr' => 'ICAP BLOCKED (TOTAL)',
		'items' => 'vsICAPBlocked-total.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'finjan_icap_block_det',
		'descr' => 'ICAP BLOCKED (DETAIL)',
		'items' => 'vsICAPBlocked-AV-total.0|vsICAPBlocked-BA-total.0|vsICAPBlocked-blackList-total.0|vsICAPBlocked-URLCat-total.0',
	);

?>
