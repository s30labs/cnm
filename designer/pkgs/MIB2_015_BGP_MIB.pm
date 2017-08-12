#---------------------------------------------------------------------------
package MIB2_015_BGP_MIB;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$MIB2_015_BGP_MIB::ENTERPRISE_PREFIX='00000';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
# Opciones de filtrado: 
# 		#text_filter, #select_filter, #select_filter_strict, #numeric_filter
#---------------------------------------------------------------------------
%MIB2_015_BGP_MIB::TABLE_APPS =(

   'BGPTABLE' => {

      'col_filters' => '#text_filter.#text_filter.#select_filter.#select_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.int.int.int.int',


      'oid_cols' => 'bgpPeerIdentifier_bgpPeerState_bgpPeerAdminStatus_bgpPeerNegotiatedVersion_bgpPeerLocalAddr_bgpPeerLocalPort_bgpPeerRemoteAddr_bgpPeerRemotePort_bgpPeerRemoteAs_bgpPeerInUpdates_bgpPeerOutUpdates_bgpPeerInTotalMessages_bgpPeerOutTotalMessages_bgpPeerLastError_bgpPeerFsmEstablishedTransitions_bgpPeerFsmEstablishedTime_bgpPeerConnectRetryInterval_bgpPeerHoldTime_bgpPeerKeepAlive_bgpPeerHoldTimeConfigured_bgpPeerKeepAliveConfigured_bgpPeerMinASOriginationInterval_bgpPeerMinRouteAdvertisementInterval_bgpPeerInUpdateElapsedTime',
      'oid_last' => 'BGP4-MIB::bgpPeerTable',
      'name' => 'TABLA DE PEERS BGP',
      'descr' => 'Muestra la tabla de peers BGP.',
      'xml_file' => '00000-MIB2-BGP4-PEER_TABLE.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'MIB2-BGP',
      'aname'=>'app_mib2_bgppeers',
      'range' => 'BGP4-MIB::bgpPeerTable',
      'enterprise' => '00000',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-MIB2-BGP4-PEER_TABLE.xml  -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.BGP-MIB',
   },



);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_015_BGP_MIB::METRICS=(

#	{  'name'=> 'TASA DE ESCANEO',   'oid'=>'FINJAN-MIB::vsScannerReqs-per-second.0', 'subtype'=>'finjan_scan_reqs', 'class'=>'FINJAN' },
#	{  'name'=> 'TASA DE TRANSFERENCIA',   'oid'=>'FINJAN-MIB::vsScannerThroughput-in-total.0|FINJAN-MIB::vsScannerThroughput-out-total.0', 'subtype'=>'finjan_scan_thro', 'class'=>'FINJAN' },
	#{	'name'=> 'MEMORIA ASIGNADA',	'oid'=>'WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0|WINDOWS-NT-PERFORMANCE::memoryCommitLimit.0', 'subtype'=>'winnt_memory_committed_bytes', 'class'=>'WINDOWS-NT'},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_015_BGP_MIB::METRICS_TAB=(


#	{	'name'=> 'ESTADO DE PERFILES DEL AP',  'oid'=>'bsnAPIfLoadProfileState|bsnAPIfInterferenceProfileState|bsnAPIfNoiseProfileState|bsnAPIfCoverageProfileState', 'subtype'=>'airspace_ap_profiles', 'class'=>'CISCO-AIRONET', 'range'=>'AIRESPACE-WIRELESS-MIB::bsnAPIfProfileStateTable', 'get_iid'=>'bsnAPDot3MacAddress' },


);


1;
__END__
