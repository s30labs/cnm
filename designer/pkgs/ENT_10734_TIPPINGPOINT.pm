#---------------------------------------------------------------------------
package ENT_10734_TIPPINGPOINT;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_10734_TIPPINGPOINT::ENTERPRISE_PREFIX='10734';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_10734_TIPPINGPOINT::TABLE_APPS =(

	'TOP TEN' => {

      'col_filters' => '#numeric_filter.#text_filter.#text_filter',
      'col_widths' => '25.25.25',
      'col_sorting' => 'int.str.str',

		'oid_cols' => 'policyHitCount_tppolicyName_policyUUID',
		'oid_last' => 'TPT-POLICY::topTenHitsByPolicyTable',
		'name' => 'TABLA DE VULNERABILIDADES - TOP TEN',
		'descr' => 'Muestra las 10 vulnerabilidades con mayor numero de ocurrencias',
		'xml_file' => '10734-TIPPINGPOINT-MIB_TOP_TEN_HITS.xml',
		'params' => '[-n;IP;]',
		'ipparam' => '[-n;IP;]',
		'subtype'=>'TIPPING-POINT',
		'aname'=>'app_tip_top_ten_table',
		'range' => 'TPT-POLICY::topTenHitsByPolicyTable',
		'enterprise' => '10734',  #5 CIFRAS !!!!
		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 10734-TIPPINGPOINT-MIB_TOP_TEN_HITS.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.TIPPINGPOINT',
	},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_10734_TIPPINGPOINT::METRICS=(

	{  'name'=> 'PAQUETES ELIMINADOS',   'oid'=>'TPT-POLICY::policyPacketsDropped.0|TPT-POLICY::policyPacketsBlocked.0', 'subtype'=>'tip_pkts_block', 'class'=>'TIPPING-POINT', 'itil_type' => 1, 'apptype'=>'NET.TIPPINGPOINT' },
	{  'name'=> 'PAQUETES CURSADOS',   'oid'=>'TPT-POLICY::policyPacketsIncoming.0|TPT-POLICY::policyPacketsOutgoing.0', 'subtype'=>'tip_pkts_flow', 'class'=>'TIPPING-POINT', 'itil_type' => 1, 'apptype'=>'NET.TIPPINGPOINT' },
	{  'name'=> 'PAQUETES PERMITIDOS',   'oid'=>'TPT-POLICY::policyPacketsPermitted.0', 'subtype'=>'tip_pkts_perm', 'class'=>'TIPPING-POINT', 'itil_type' => 1, 'apptype'=>'NET.TIPPINGPOINT' },
	{  'name'=> 'PAQUETES INVALIDOS',   'oid'=>'TPT-POLICY::policyPacketsInvalid.0', 'subtype'=>'tip_pkts_inval', 'class'=>'TIPPING-POINT', 'itil_type' => 1, 'apptype'=>'NET.TIPPINGPOINT' },
#	{  'name'=> 'USO DE CPU (%)',   'oid'=>'', 'subtype'=>'cpq_cpu_status', 'class'=>'COMPAQ' },
	#{  'name'=> 'FALLOS EN DNS',   'oid'=>'ASYNCOS-MAIL-MIB::outstandingDNSRequests.0|ASYNCOS-MAIL-MIB::pendingDNSRequests.0', 'subtype'=>'ironport_dns_failures', 'class'=>'IRONPORT' },
	#{	'name'=> 'MEMORIA ASIGNADA',	'oid'=>'WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0|WINDOWS-NT-PERFORMANCE::memoryCommitLimit.0', 'subtype'=>'winnt_memory_committed_bytes', 'class'=>'WINDOWS-NT'},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_10734_TIPPINGPOINT::METRICS_TAB=(

	{	'name'=> 'ALERTAS POR PROTOCOLO',  'oid'=>'TPT-POLICY::protocolAlertCount', 'subtype'=>'tip_alerts_proto', 'class'=>'TIPPING-POINT', 'range'=>'TPT-POLICY::alertsByProtocolTable', 'get_iid'=>'alertProtocol', 'itil_type' => 1, 'apptype'=>'NET.TIPPINGPOINT' },

);


1;
__END__
