#---------------------------------------------------------------------------
package MIB2_014_OSPF_MIB;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$MIB2_014_OSPF_MIB::ENTERPRISE_PREFIX='00000';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%MIB2_014_OSPF_MIB::TABLE_APPS =(

	'TABLA DE INTERFACES OSPF' => {

      'col_filters' => '#text_filter.#text_filter.#select_filter.#select_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str',

		'oid_cols' => 'ospfIfIpAddress_ospfAddressLessIf_ospfIfAreaId_ospfIfType_ospfIfAdminStat_ospfIfRtrPriority_ospfIfTransitDelay_ospfIfRetransInterval_ospfIfHelloInterval_ospfIfRtrDeadInterval_ospfIfPollInterval_ospfIfState_ospfIfDesignatedRouter_ospfIfBackupDesignatedRouter_ospfIfEvents_ospfIfAuthKey_ospfIfStatus_ospfIfMulticastForwarding_ospfIfDemand_ospfIfAuthType',
		'oid_last' => 'OSPF-MIB::ospfIfTable',
		'name' => 'OSPF - TABLA DE INTERFACES',
		'descr' => 'Muestra la tabla de interfaces de desde el punto de vista del protocolo OSPF',
		'xml_file' => '00000-OSPF-MIB_INTERFACES_TABLE.xml',
		'params' => '[-n;IP;]',
		'ipparam' => '[-n;IP;]',
		'subtype'=>'MIB2-OSPF',
		'aname'=>'app_mib2_ospf_interfaces_table',
		'range' => 'OSPF-MIB::ospfIfTable',
		'enterprise' => '00000',  #5 CIFRAS !!!!
		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-OSPF-MIB_INTERFACES_TABLE.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.OSPF-MIB', 
	},

   'TABLA DE VECINOS OSPF' => {

      'col_filters' => '#text_filter.#text_filter.#select_filter.#select_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '20.20.20.20.20.20.20.20.20.20.20',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str.str.str',

      'oid_cols' => 'ospfNbrIpAddr_ospfNbrAddressLessIndex_ospfNbrRtrId_ospfNbrOptions_ospfNbrPriority_ospfNbrState_ospfNbrEvents_ospfNbrLsRetransQLen_ospfNbmaNbrStatus_ospfNbmaNbrPermanence_ospfNbrHelloSuppressed',
      'oid_last' => 'OSPF-MIB::ospfNbrTable',
      'name' => 'OSPF - TABLA DE VECINOS',
      'descr' => 'Muestra la tabla de vecinos del equipo desde el punto de vista del protocolo OSPF',
      'xml_file' => '00000-OSPF-MIB_NEIGHBOURS_TABLE.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'MIB2-OSPF',
      'aname'=>'app_mib2_ospf_neighbourss_table',
      'range' => 'OSPF-MIB::ospfNbrTable',
      'enterprise' => '00000',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-OSPF-MIB_NEIGHBOURS_TABLE.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.OSPF-MIB',
  },

   'TABLA DE AREAS OSPF' => {

      'col_filters' => '#text_filter.#text_filter.#select_filter.#select_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '20.20.20.20.20.20.20.20.20',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str',

      'oid_cols' => 'ospfAuthType_ospfImportAsExtern_ospfSpfRuns_ospfAreaBdrRtrCount_ospfAsBdrRtrCount_ospfAreaLsaCount_ospfAreaLsaCksumSum_ospfAreaSummary_ospfAreaStatus',
      'oid_last' => 'OSPF-MIB::ospfAreaTable',
      'name' => 'OSPF - TABLA DE AREAS',
      'descr' => 'Muestra la tabla de areas OSPF del equipo',
      'xml_file' => '00000-OSPF-MIB_AREAS_TABLE.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'MIB2-OSPF',
      'aname'=>'app_mib2_ospf_areas_table',
      'range' => 'OSPF-MIB::ospfAreaTable',
      'enterprise' => '00000',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-OSPF-MIB_AREAS_TABLE.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.OSPF-MIB',
  },

);

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_014_OSPF_MIB::METRICS=(

	{  'name'=> 'OSPF CHECKSUM LSA EXTERNO',      'oid'=>'OSPF-MIB::ospfExternLsaCksumSum.0', 'subtype'=>'mib2_ospfExternLsaCksumSum', 'class'=>'MIB2-OSPF', 'include'=>'0', 'itil_type' => 1, 'apptype'=>'NET.OSPF-MIB' },

);


#OSPF-MIB::ospfRouterId.0 = IpAddress: 10.2.254.101
#OSPF-MIB::ospfAdminStat.0 = INTEGER: 1
#OSPF-MIB::ospfVersionNumber.0 = INTEGER: 2
#OSPF-MIB::ospfAreaBdrRtrStatus.0 = INTEGER: 2
#OSPF-MIB::ospfASBdrRtrStatus.0 = INTEGER: 1
#OSPF-MIB::ospfExternLsaCount.0 = Gauge32: 6831
#OSPF-MIB::ospfExternLsaCksumSum.0 = INTEGER: 439063444
#OSPF-MIB::ospfTOSSupport.0 = INTEGER: 2
#OSPF-MIB::ospfOriginateNewLsas.0 = Counter32: 382
#OSPF-MIB::ospfRxNewLsas.0 = Counter32: 9518045
#OSPF-MIB::ospfExtLsdbLimit.0 = INTEGER: -1
#OSPF-MIB::ospfMulticastExtensions.0 = INTEGER: 0
#OSPF-MIB::ospfExitOverflowInterval.0 = INTEGER: 0
#OSPF-MIB::ospfDemandExtensions.0 = INTEGER: 1
#OSPF-MIB::ospfAreaId.0.0.0.0 = IpAddress: 0.0.0.0

#OSPF-MIB::ospfAuthType.0.0.0.0 = INTEGER: 0
#OSPF-MIB::ospfImportAsExtern.0.0.0.0 = INTEGER: 1
#OSPF-MIB::ospfSpfRuns.0.0.0.0 = Counter32: 239
#OSPF-MIB::ospfAreaBdrRtrCount.0.0.0.0 = Gauge32: 11
#OSPF-MIB::ospfAsBdrRtrCount.0.0.0.0 = Gauge32: 27
#OSPF-MIB::ospfAreaLsaCount.0.0.0.0 = Gauge32: 857
#OSPF-MIB::ospfAreaLsaCksumSum.0.0.0.0 = INTEGER: 54559135
#OSPF-MIB::ospfAreaSummary.0.0.0.0 = INTEGER: 2
#OSPF-MIB::ospfAreaStatus.0.0.0.0 = INTEGER: 1




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_014_OSPF_MIB::METRICS_TAB=(

	{	'name'=> 'OSPF - EJECUCIONES SPF',  'oid'=>'OSPF-MIB::ospfSpfRuns', 'subtype'=>'ospf_SpfRuns', 'class'=>'OSPF-MIB', 'range'=>'OSPF-MIB::ospfAreaTable', 'get_iid'=>'ospfAreaId', 'include'=>'0', 'itil_type' => 1, 'apptype'=>'NET.OSPF-MIB' },
	{	'name'=> 'OSPF - CHECKSUM LSA',  'oid'=>'OSPF-MIB::ospfAreaLsaCksumSum', 'subtype'=>'ospf_AreaLsaCksumSum', 'class'=>'OSPF-MIB', 'range'=>'OSPF-MIB::ospfAreaTable', 'get_iid'=>'ospfAreaId', 'include'=>'0', 'itil_type' => 1, 'apptype'=>'NET.OSPF-MIB' },
	{	'name'=> 'EVENTOS OSPF',  'oid'=>'OSPF-MIB::ospfNbrEvents', 'subtype'=>'ospf_NbrEvents', 'class'=>'OSPF-MIB', 'range'=>'OSPF-MIB::ospfNbrTable', 'get_iid'=>'ospfNbrIpAddr', 'include'=>'0', 'itil_type' => 1, 'apptype'=>'NET.OSPF-MIB' },


	{	'name'=> 'ESTADO OSPF',   'oid'=>'OSPF-MIB::ospfNbrState', 'subtype'=>'ospf_NbrState', 'class'=>'OSPF-MIB', 'range'=>'OSPF-MIB::ospfNbrTable', 'vlabel'=>'estado', 'get_iid'=>'ospfNbrIpAddr', 'include'=>'0', 'items'=>'Full(8)|Loading(7)|Down(1)|Attempt(2)|Init(3)|2W(4)|ExchSt(5)|Exch(6)', 'esp'=>'MAP(8)(1,0,0,0,0,0,0,0)|MAP(7)(0,1,0,0,0,0,0,0)|MAP(1)(0,0,1,0,0,0,0,0)|MAP(2)(0,0,0,1,0,0,0,0)|MAP(3)(0,0,0,0,1,0,0,0)|MAP(4)(0,0,0,0,0,1,0,0)|MAP(5)(0,0,0,0,0,0,1,0)|MAP(6)(0,0,0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.OSPF-MIB' },

#                    down (1),
#                    attempt (2),
#                    init (3),
#                    twoWay (4),
#                    exchangeStart (5),
#                    exchange (6),
#                    loading (7),
#                    full (8)

);


1;
__END__
