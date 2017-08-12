#---------------------------------------------------------------------------
package ENT_14179_AIRSPACE;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_14179_AIRSPACE::ENTERPRISE_PREFIX='14179';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
# Opciones de filtrado: 
# 		#text_filter, #select_filter, #select_filter_strict, #numeric_filter
#---------------------------------------------------------------------------
%ENT_14179_AIRSPACE::TABLE_APPS =(

	'APINFO' => {

      'col_filters' => '#text_filter.#text_filter.#select_filter.#select_filter.#select_filter.#select_filter.#text_filter.#select_filter.#text_filter.#select_filter.#select_filter.#text_filter.#select_filter',
		'col_widths' => '25.25.15.15.20.20.20.20.20.20.20.20.15',
		'col_sorting' => 'str.str.int.str.str.str.str.str.str.str.str.str.int',
		'use_enums' => '0',

      'oid_cols' => 'bsnAPName_bsnAPLocation_bsnAPOperationStatus_bsnAPSoftwareVersion_bsnAPModel_bsnAPSerialNumber_bsnApIpAddress_bsnAPType_bsnAPStaticIPAddress_bsnAPGroupVlanName_bsnAPIOSVersion_bsnAPEthernetMacAddress_bsnAPAdminStatus',
      'oid_last' => 'AIRESPACE-WIRELESS-MIB::bsnAPTable',
      'name' => 'INFO SOBRE LOS APS CONECTADOS',
      'descr' => 'Muestra informacion relevante sobre los APs que dependen de este equipo',
      'xml_file' => '14179-AIRSPACE-APINFO-MIB.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-AIRONET',
      'aname'=>'app_airspace_apinfo_table',
      'range' => 'AIRESPACE-WIRELESS-MIB::bsnAPTable',
      'enterprise' => '14179',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 14179-AIRSPACE-APINFO-MIB.xml -M 1 -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO-WIRELESS',
	},

   'MOBILEINFO' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#select_filter.#select_filter.#select_filter.#text_filter.#select_filter.#select_filter.#select_filter.#text_filter.#select_filter',
      'col_widths' => '20.20.25.20.17.17.20.15.17.17.20.15.20',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str.str.str.str.str',
		'use_enums' => '0',
      'oid_cols' => 'bsnMobileStationMacAddress_bsnMobileStationIpAddress_bsnMobileStationUserName_bsnMobileStationAPMacAddr_bsnMobileStationAPIfSlotId_bsnMobileStationEssIndex_bsnMobileStationSsid_bsnMobileStationAID_bsnMobileStationStatus_bsnMobileStationReasonCode_bsnMobileStationMobilityStatus_bsnMobileStationVlanId_bsnMobileStationPolicyType',

      'oid_last' => 'AIRESPACE-WIRELESS-MIB::bsnMobileStationTable',
      'name' => 'INFO SOBRE LAS ESTACIONES MOVILES CONECTADAS',
      'descr' => 'Muestra informacion relevante las estaciones moviles cnectadas a este equipo',
      'xml_file' => '14179-AIRSPACE-MOBINFO-MIB.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-AIRONET',
      'aname'=>'app_airspace_mobinfo_table',
      'range' => 'AIRESPACE-WIRELESS-MIB::bsnMobileStationTable',
      'enterprise' => '14179',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 14179-AIRSPACE-MOBINFO-MIB.xml -M 1 -w xml ',
      'itil_type' => 1,    'apptype'=>'NET.CISCO-WIRELESS',
   },


   'ROGUEINFO' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#select_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '20.20.20.20.20.15.15.15.15.20.20.20',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str.str.str.str',
		'use_enums' => '0',

      'oid_cols' => 'bsnRogueAPDot11MacAddress_bsnRogueAPTotalDetectingAPs_bsnRogueAPFirstReported_bsnRogueAPLastReported_bsnRogueAPContainmentLevel_bsnRogueAPType_bsnRogueAPOnNetwork_bsnRogueAPTotalClients_bsnRogueAPRowStatus_bsnRogueAPMaxDetectedRSSI_bsnRogueAPSSID_bsnRogueAPState',
      'oid_last' => 'AIRESPACE-WIRELESS-MIB::bsnRogueAPTable',
      'name' => 'INFO SOBRE LOS ROGUE APS CONECTADOS',
      'descr' => 'Muestra informacion relevante sobre los Rogue APs que dependen de este equipo',
      'xml_file' => '14179-AIRSPACE-ROGUEINFO-MIB.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-AIRONET',
      'aname'=>'app_airspace_rogueinfo_table',
      'range' => 'AIRESPACE-WIRELESS-MIB::bsnRogueAPTable',
      'enterprise' => '14179',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 14179-AIRSPACE-ROGUEINFO-MIB.xml -M 1 -w xml ',
      'itil_type' => 1,    'apptype'=>'NET.CISCO-WIRELESS',
   },

   'APIFINFO' => {

      'col_filters' => '#select_filter.#select_filter.#select_filter.#select_filter.#select_filter.#select_filter.#text_filter.#text_filter.#text_filter.#select_filter.#select_filter.#text_filter.#text_filter.#select_filter',
      'col_widths' => '15.15.15.15.20.20.20.20.20.20.20.20.20.15',
      'col_sorting' => 'str.str.int.str.str.str.str.str.str.str.str.str.str.int',

      'oid_cols' => 'bsnAPIfSlotId_bsnAPIfType_bsnAPIfPhyChannelAssignment_bsnAPIfPhyChannelNumber_bsnAPIfPhyTxPowerControl_bsnAPIfPhyTxPowerLevel_bsnAPIfPhyAntennaType_bsnAPIfPhyAntennaMode_bsnAPIfPhyAntennaDiversity_bsnAPIfOperStatus_bsnApIfNoOfUsers_bsnAPIfAntennaGain_bsnAPIfChannelList_bsnAPIfAdminStatus',

      'oid_last' => 'AIRESPACE-WIRELESS-MIB::bsnAPIfTable',
      'name' => 'INFO SOBRE LOS INTERFACES DE LOS APS CONECTADOS',
      'descr' => 'Muestra informacion relevante sobre los interfaces de los APs que dependen de este equipo',
      'xml_file' => '14179-AIRSPACE-APIFINFO-MIB.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-AIRONET',
      'aname'=>'app_airspace_apifinfo_table',
      'range' => 'AIRESPACE-WIRELESS-MIB::bsnAPIfTable',
      'enterprise' => '14179',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 14179-AIRSPACE-APIFINFO-MIB.xml -M 1 -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO-WIRELESS',
   },


   'APLOAD' => {

      'col_filters' => '#text_filter,#text_filter,#text_filter,#select_filter,#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter',
      'col_widths' => '20.20.20.15.25.25.15.15.20',
      'col_sorting' => 'str.str.str.int.int.int.int.int.int',

      'oid_cols' => 'bsnAPName_bsnApIpAddress_bsnAPDot3MacAddress_bsnAPIfSlotId_bsnAPIfLoadRxUtilization_bsnAPIfLoadTxUtilization_bsnAPIfLoadChannelUtilization_bsnAPIfLoadNumOfClients_bsnAPIfPoorSNRClients',
      'oid_last' => 'AIRESPACE-WIRELESS-MIB::bsnAPIfLoadParametersTable',
      'name' => 'CARGA DE LOS APS CONECTADOS',
      'descr' => 'Muestra informacion relevante sobre la carga que tienen los APs que dependen de este equipo',
      'xml_file' => '14179-AIRSPACE-APLOAD-MIB.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-AIRONET',
      'aname'=>'app_airspace_apload_table',
      'range' => 'AIRESPACE-WIRELESS-MIB::bsnAPIfLoadParametersTable',
      'enterprise' => '14179',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 14179-AIRSPACE-APLOAD-MIB.xml  -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO-WIRELESS',

   },


   'APPROFILE' => {

      'col_filters' => '#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter',
      'col_widths' => '15.15.15.15',
      'col_sorting' => 'int.int.int.int',

      'oid_cols' => 'bsnAPIfLoadProfileState_bsnAPIfInterferenceProfileState_bsnAPIfNoiseProfileState_bsnAPIfCoverageProfileState',
      'oid_last' => 'AIRESPACE-WIRELESS-MIB::bsnAPIfProfileStateTable',
      'name' => 'ESTADO DE LOS PERFILES DE LOS APS CONECTADOS',
      'descr' => 'Muestra informacion relevante sobre los perfiles de carga, interferencia, cobertura y ruido de los APs que dependen de este equipo',
      'xml_file' => '14179-AIRSPACE-APPROFILE-MIB.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-AIRONET',
      'aname'=>'app_airspace_approfiles_table',
      'range' => 'AIRESPACE-WIRELESS-MIB::bsnAPIfProfileStateTable',
      'enterprise' => '14179',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 14179-AIRSPACE-APPROFILE-MIB.xml -M 1 -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO-WIRELESS',

   },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_14179_AIRSPACE::METRICS=(

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
@ENT_14179_AIRSPACE::METRICS_TAB=(

	{	'name'=> 'NUMERO DE CLIENTES EN AP',  'oid'=>'bsnAPIfLoadNumOfClients', 'subtype'=>'airspace_nclients', 'class'=>'CISCO-AIRONET', 'range'=>'AIRESPACE-WIRELESS-MIB::bsnAPIfLoadParametersTable', 'get_iid'=>'bsnAPDot3MacAddress', 'itil_type' => 1, 'apptype'=>'NET.CISCO-WIRELESS' },

	{	'name'=> 'ESTADO DEL AP',  'oid'=>'bsnAPOperationStatus|bsnAPAdminStatus', 'subtype'=>'airspace_ap_status', 'class'=>'CISCO-AIRONET', 'range'=>'AIRESPACE-WIRELESS-MIB::bsnAPTable', 'get_iid'=>'bsnApIpAddress', 'itil_type' => 1, 'apptype'=>'NET.CISCO-WIRELESS' },

	{	'name'=> 'ESTADO DE PERFILES DEL AP',  'oid'=>'bsnAPIfLoadProfileState|bsnAPIfInterferenceProfileState|bsnAPIfNoiseProfileState|bsnAPIfCoverageProfileState', 'subtype'=>'airspace_ap_profiles', 'class'=>'CISCO-AIRONET', 'range'=>'AIRESPACE-WIRELESS-MIB::bsnAPIfProfileStateTable', 'get_iid'=>'bsnAPDot3MacAddress', 'itil_type' => 1, 'apptype'=>'NET.CISCO-WIRELESS' },

);


1;
__END__
