<?php
      $TIPS[]=array(
         'id_ref' => 'finjan_scan_reqs',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsScannerReqs-per-second.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsScannerReqs-per-second.0 (GAUGE):</strong> "Average rate of requests scanned per second"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_scan_thro',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsScannerThroughput-in-total.0|vsScannerThroughput-out-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsScannerThroughput-in-total.0 (GAUGE):</strong> "Total input scanned since last reset"
<strong>FINJAN-MIB::vsScannerThroughput-out-total.0 (GAUGE):</strong> "Total output scanned since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_sum_block',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsSummaryBlocked-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsSummaryBlocked-total.0 (COUNTER):</strong> "Total number of requests which were blocked since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_det_block',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsScannerBlocked-AV-total.0|vsScannerBlocked-BA-total.0|vsScannerBlocked-blackList-total.0|vsScannerBlocked-URLCat-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsScannerBlocked-AV-total.0 (COUNTER):</strong> "Total number of requests which were blocked due to Virus detection since last reset"
<strong>FINJAN-MIB::vsScannerBlocked-BA-total.0 (COUNTER):</strong> "Total number of requests which were blocked due to Behavior analysis since last reset"
<strong>FINJAN-MIB::vsScannerBlocked-blackList-total.0 (COUNTER):</strong> "Total number of requests which were blocked due to being Blacklisted since last reset"
<strong>FINJAN-MIB::vsScannerBlocked-URLCat-total.0 (COUNTER):</strong> "Total number of requests which were blocked due to URL category since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_sum_log',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsScannerLogged-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsScannerLogged-total.0 (COUNTER):</strong> "Total number of requests which were logged since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_det_log',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsScannerLogged-logsDb-total.0|vsScannerLogged-archive-total.0|vsScannerLogged-reportsDb-total.0|vsScannerLogged-syslog-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsScannerLogged-logsDb-total.0 (COUNTER):</strong> "Total number of requests which were sent to the logging database since last reset"
<strong>FINJAN-MIB::vsScannerLogged-archive-total.0 (COUNTER):</strong> "Total number of requests which were sent to the archive system since last reset"
<strong>FINJAN-MIB::vsScannerLogged-reportsDb-total.0 (COUNTER):</strong> "Total number of requests which were sent to the reports database since last reset"
<strong>FINJAN-MIB::vsScannerLogged-syslog-total.0 (COUNTER):</strong> "Total number of requests which were sent to the syslog system since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_scan_reqs_tot',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsScannerReqs-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsScannerReqs-total.0 (COUNTER):</strong> "Total number of requests scanned since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_scan_reqs_det',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsHTTPReqs-total.0|vsHTTPSReqs-total.0|vsFTPReqs-total.0|vsICAPReqs-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsHTTPReqs-total.0 (COUNTER):</strong> "Total number of HTTP requests scanned since last reset"
<strong>FINJAN-MIB::vsHTTPSReqs-total.0 (COUNTER):</strong> "Total number of HTTPS requests scanned since last reset"
<strong>FINJAN-MIB::vsFTPReqs-total.0 (COUNTER):</strong> "Total number of FTP requests scanned since last reset"
<strong>FINJAN-MIB::vsICAPReqs-total.0 (COUNTER):</strong> "Total number of ICAP requests scanned since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_http_thro',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsHTTPThroughput-in-total.0|vsHTTPThroughput-out-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsHTTPThroughput-in-total.0 (GAUGE):</strong> "Total HTTP input scanned since last reset"
<strong>FINJAN-MIB::vsHTTPThroughput-out-total.0 (GAUGE):</strong> "Total HTTP output scanned since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_http_block',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsHTTPBlocked-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsHTTPBlocked-total.0 (COUNTER):</strong> "Total number of HTTP requests which were blocked since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_http_block_det',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsHTTPBlocked-AV-total.0|vsHTTPBlocked-BA-total.0|vsHTTPBlocked-blackList-total.0|vsHTTPBlocked-URLCat-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsHTTPBlocked-AV-total.0 (COUNTER):</strong> "Total number of HTTP requests which were blocked due to Virus detection since last reset"
<strong>FINJAN-MIB::vsHTTPBlocked-BA-total.0 (COUNTER):</strong> "Total number of HTTP requests which were blocked due to Behavior analysis since last reset"
<strong>FINJAN-MIB::vsHTTPBlocked-blackList-total.0 (COUNTER):</strong> "Total number of HTTP requests which were blocked due to being blacklisted since last reset"
<strong>FINJAN-MIB::vsHTTPBlocked-URLCat-total.0 (COUNTER):</strong> "Total number of HTTP requests which were blocked due to URL category since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_https_thro',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsHTTPSThroughput-in-total.0|vsHTTPSThroughput-out-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsHTTPSThroughput-in-total.0 (GAUGE):</strong> "Total HTTPS input scanned since last reset"
<strong>FINJAN-MIB::vsHTTPSThroughput-out-total.0 (GAUGE):</strong> "Total HTTPS output scanned since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_https_block',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsHTTPSBlocked-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsHTTPSBlocked-total.0 (COUNTER):</strong> "Total number of HTTPS requests which were blocked since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_https_block_det',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsHTTPSBlocked-AV-total.0|vsHTTPSBlocked-BA-total.0|vsHTTPSBlocked-blackList-total.0|vsHTTPSBlocked-URLCat-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsHTTPSBlocked-AV-total.0 (COUNTER):</strong> "Total number of HTTPS requests which were blocked due to Virus detection since last reset"
<strong>FINJAN-MIB::vsHTTPSBlocked-BA-total.0 (COUNTER):</strong> "Total number of HTTPS requests which were blocked due to Behavior analysis since last reset"
<strong>FINJAN-MIB::vsHTTPSBlocked-blackList-total.0 (COUNTER):</strong> "Total number of HTTPS requests which were blocked due to being blacklisted since last reset"
<strong>FINJAN-MIB::vsHTTPSBlocked-URLCat-total.0 (COUNTER):</strong> "Total number of HTTPS requests which were blocked due to URL category since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_ftp_thro',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsFTPThroughput-in-total.0|vsFTPThroughput-out-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsFTPThroughput-in-total.0 (GAUGE):</strong> "Total FTP input scanned since last reset"
<strong>FINJAN-MIB::vsFTPThroughput-out-total.0 (GAUGE):</strong> "Total FTP output scanned since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_ftp_block',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsFTPBlocked-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsFTPBlocked-total.0 (COUNTER):</strong> "Total number of FTP requests which were blocked since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_ftp_block_det',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsFTPBlocked-AV-total.0|vsFTPBlocked-BA-total.0|vsFTPBlocked-blackList-total.0|vsFTPBlocked-URLCat-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsFTPBlocked-AV-total.0 (COUNTER):</strong> "Total number of FTP requests which were blocked due to Virus detection since last reset"
<strong>FINJAN-MIB::vsFTPBlocked-BA-total.0 (COUNTER):</strong> "Total number of FTP requests which were blocked due to Behavior analysis since last reset"
<strong>FINJAN-MIB::vsFTPBlocked-blackList-total.0 (COUNTER):</strong> "Total number of FTP requests which were blocked due to being blacklisted since last reset"
<strong>FINJAN-MIB::vsFTPBlocked-URLCat-total.0 (COUNTER):</strong> "Total number of FTP requests which were blocked due to URL category since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_icap_thro',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsICAPThroughput-in-total.0|vsICAPThroughput-out-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsICAPThroughput-in-total.0 (GAUGE):</strong> "Total ICAP input scanned since last reset"
<strong>FINJAN-MIB::vsICAPThroughput-out-total.0 (GAUGE):</strong> "Total ICAP output scanned since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_icap_block',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsICAPBlocked-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsICAPBlocked-total.0 (COUNTER):</strong> "Total number of ICAP requests which were blocked since last reset"
',
      );


      $TIPS[]=array(
         'id_ref' => 'finjan_icap_block_det',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>vsICAPBlocked-AV-total.0|vsICAPBlocked-BA-total.0|vsICAPBlocked-blackList-total.0|vsICAPBlocked-URLCat-total.0</strong> a partir de los siguientes atributos de la mib FINJAN-MIB:<br><br><strong>FINJAN-MIB::vsICAPBlocked-AV-total.0 (COUNTER):</strong> "Total number of ICAP requests which were blocked due to Virus detection since last reset"
<strong>FINJAN-MIB::vsICAPBlocked-BA-total.0 (COUNTER):</strong> "Total number of ICAP requests which were blocked due to Behavior analysis since last reset"
<strong>FINJAN-MIB::vsICAPBlocked-blackList-total.0 (COUNTER):</strong> "Total number of ICAP requests which were blocked due to being blacklisted since last reset"
<strong>FINJAN-MIB::vsICAPBlocked-URLCat-total.0 (COUNTER):</strong> "Total number of ICAP requests which were blocked due to URL category since last reset"
',
      );


?>
