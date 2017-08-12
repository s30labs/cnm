#---------------------------------------------------------------------------
package ENT_06790_FINJAN;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_06790_FINJAN::ENTERPRISE_PREFIX='06790';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_06790_FINJAN::TABLE_APPS =(

#	'TOP TEN' => {
#
#		'oid_cols' => 'policyHitCount_tppolicyName_policyUUID',
#		'oid_last' => 'TPT-POLICY::topTenHitsByPolicyTable',
#		'name' => 'TABLA DE VULNERABILIDADES - TOP TEN',
#		'descr' => 'Muestra las 10 vulnerabilidades con mayor numero de ocurrencias',
#		'xml_file' => '10734-TIPPINGPOINT-MIB_TOP_TEN_HITS.xml',
#		'params' => '[-n;IP;]',
#		'ipparam' => '[-n;IP;]',
#		'subtype'=>'TIPPING-POINT',
#		'aname'=>'app_tip_top_ten_table',
#		'range' => 'TPT-POLICY::topTenHitsByPolicyTable',
#		'enterprise' => '10734',  #5 CIFRAS !!!!
#		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 10734-TIPPINGPOINT-MIB_TOP_TEN_HITS.xml -w xml ',
#	},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_06790_FINJAN::METRICS=(

	{  'name'=> 'TASA DE ESCANEO',   'oid'=>'FINJAN-MIB::vsScannerReqs-per-second.0', 'subtype'=>'finjan_scan_reqs', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
	{  'name'=> 'TASA DE TRANSFERENCIA',   'oid'=>'FINJAN-MIB::vsScannerThroughput-in-total.0|FINJAN-MIB::vsScannerThroughput-out-total.0', 'subtype'=>'finjan_scan_thro', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
	{  'name'=> 'PETICIONES BLOQUEADAS (TOTALES)',   'oid'=>'FINJAN-MIB::vsSummaryBlocked-total.0', 'subtype'=>'finjan_sum_block', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
	{  'name'=> 'PETICIONES BLOQUEADAS (DETALLE)',   'oid'=>'FINJAN-MIB::vsScannerBlocked-AV-total.0|FINJAN-MIB::vsScannerBlocked-BA-total.0|FINJAN-MIB::vsScannerBlocked-blackList-total.0|FINJAN-MIB::vsScannerBlocked-URLCat-total.0', 'subtype'=>'finjan_det_block', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
	{  'name'=> 'PETICIONES REGISTRADAS (TOTALES)',   'oid'=>'FINJAN-MIB::vsScannerLogged-total.0', 'subtype'=>'finjan_sum_log', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
	{  'name'=> 'PETICIONES REGISTRADAS (DETALLE)',   'oid'=>'FINJAN-MIB::vsScannerLogged-logsDb-total.0|FINJAN-MIB::vsScannerLogged-archive-total.0|FINJAN-MIB::vsScannerLogged-reportsDb-total.0|FINJAN-MIB::vsScannerLogged-syslog-total.0', 'subtype'=>'finjan_det_log', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
   {  'name'=> 'PETICIONES ESCANEADAS (TOTALES)',   'oid'=>'FINJAN-MIB::vsScannerReqs-total.0', 'subtype'=>'finjan_scan_reqs_tot', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
   {  'name'=> 'PETICIONES ESCANEADAS (DETALLE)',   'oid'=>'FINJAN-MIB::vsHTTPReqs-total.0|FINJAN-MIB::vsHTTPSReqs-total.0|FINJAN-MIB::vsFTPReqs-total.0|FINJAN-MIB::vsICAPReqs-total.0', 'subtype'=>'finjan_scan_reqs_det', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },

   {  'name'=> 'TASA DE TRANSFERENCIA HTTP',   'oid'=>'FINJAN-MIB::vsHTTPThroughput-in-total.0|FINJAN-MIB::vsHTTPThroughput-out-total.0', 'subtype'=>'finjan_http_thro', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
   {  'name'=> 'PETICIONES HTTP BLOQUEADAS (TOTALES)',   'oid'=>'FINJAN-MIB::vsHTTPBlocked-total.0', 'subtype'=>'finjan_http_block', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
   {  'name'=> 'PETICIONES HTTP BLOQUEADAS (DETALLE)',   'oid'=>'FINJAN-MIB::vsHTTPBlocked-AV-total.0|FINJAN-MIB::vsHTTPBlocked-BA-total.0|FINJAN-MIB::vsHTTPBlocked-blackList-total.0|FINJAN-MIB::vsHTTPBlocked-URLCat-total.0', 'subtype'=>'finjan_http_block_det', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },

   {  'name'=> 'TASA DE TRANSFERENCIA HTTPS',   'oid'=>'FINJAN-MIB::vsHTTPSThroughput-in-total.0|FINJAN-MIB::vsHTTPSThroughput-out-total.0', 'subtype'=>'finjan_https_thro', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
   {  'name'=> 'PETICIONES HTTPS BLOQUEADAS (TOTALES)',   'oid'=>'FINJAN-MIB::vsHTTPSBlocked-total.0', 'subtype'=>'finjan_https_block', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
   {  'name'=> 'PETICIONES HTTPS BLOQUEADAS (DETALLE)',   'oid'=>'FINJAN-MIB::vsHTTPSBlocked-AV-total.0|FINJAN-MIB::vsHTTPSBlocked-BA-total.0|FINJAN-MIB::vsHTTPSBlocked-blackList-total.0|FINJAN-MIB::vsHTTPSBlocked-URLCat-total.0', 'subtype'=>'finjan_https_block_det', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },

   {  'name'=> 'TASA DE TRANSFERENCIA FTP',   'oid'=>'FINJAN-MIB::vsFTPThroughput-in-total.0|FINJAN-MIB::vsFTPThroughput-out-total.0', 'subtype'=>'finjan_ftp_thro', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
   {  'name'=> 'PETICIONES FTP BLOQUEADAS (TOTALES)',   'oid'=>'FINJAN-MIB::vsFTPBlocked-total.0', 'subtype'=>'finjan_ftp_block', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
   {  'name'=> 'PETICIONES FTP BLOQUEADAS (DETALLE)',   'oid'=>'FINJAN-MIB::vsFTPBlocked-AV-total.0|FINJAN-MIB::vsFTPBlocked-BA-total.0|FINJAN-MIB::vsFTPBlocked-blackList-total.0|FINJAN-MIB::vsFTPBlocked-URLCat-total.0', 'subtype'=>'finjan_ftp_block_det', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },

   {  'name'=> 'TASA DE TRANSFERENCIA ICAP',   'oid'=>'FINJAN-MIB::vsICAPThroughput-in-total.0|FINJAN-MIB::vsICAPThroughput-out-total.0', 'subtype'=>'finjan_icap_thro', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
   {  'name'=> 'PETICIONES ICAP BLOQUEADAS (TOTALES)',   'oid'=>'FINJAN-MIB::vsICAPBlocked-total.0', 'subtype'=>'finjan_icap_block', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },
   {  'name'=> 'PETICIONES ICAP BLOQUEADAS (DETALLE)',   'oid'=>'FINJAN-MIB::vsICAPBlocked-AV-total.0|FINJAN-MIB::vsICAPBlocked-BA-total.0|FINJAN-MIB::vsICAPBlocked-blackList-total.0|FINJAN-MIB::vsICAPBlocked-URLCat-total.0', 'subtype'=>'finjan_icap_block_det', 'class'=>'FINJAN', 'itil_type' => 1, 'apptype'=>'NET.FINJAN' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_06790_FINJAN::METRICS_TAB=(

#	{	'name'=> 'ALERTAS POR PROTOCOLO',  'oid'=>'TPT-POLICY::protocolAlertCount', 'subtype'=>'tip_alerts_proto', 'class'=>'TIPPING-POINT', 'range'=>'TPT-POLICY::alertsByProtocolTable', 'get_iid'=>'alertProtocol' },

#	{	'name'=> 'FALLOS AL ACTUALIZAR',  'oid'=>'updateFailures', 'subtype'=>'ironport_update_fail', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
#	{	'name'=> 'TASA DE ACTUALIZACIONES',  'oid'=>'updates', 'subtype'=>'ironport_update_rate', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
# 	{	'name'=> '',  'oid'=>'', 'subtype'=>'ironport_temperature', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::', 'get_iid'=>'ASYNCOS-MAIL-MIB::' },

);


1;
__END__
