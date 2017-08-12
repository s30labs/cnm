#---------------------------------------------------------------------------
package ENT_00009_CISCO;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_00009_CISCO::ENTERPRISE_PREFIX='00009';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
# Opciones de filtrado: 
# 		#text_filter, #select_filter, #select_filter_strict, #numeric_filter
#---------------------------------------------------------------------------
%ENT_00009_CISCO::TABLE_APPS =(

   'PROCTABLE' => {

      'col_filters' => '#text_filter,#text_filter,#text_filter,#select_filter,#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter,#text_filter',
      'col_widths' => '15.20.15.20.25.25.20.20.20.20.20.20.20.30.25.20.20.25.25.25',
      'col_sorting' => 'int.str.int.str.int.int.int.int.int.int.int.int.int.int.int.int.int.int.int.int.int.int.int.int.int',

      'oid_cols' => 'cpmProcessPID_cpmProcessName_cpmProcessuSecs_cpmProcessTimeCreated_cpmProcessAverageUSecs_cpmProcExtMemAllocated_cpmProcExtMemFreed_cpmProcExtInvoked_cpmProcExtRuntime_cpmProcExtUtil5Sec_cpmProcExtUtil1Min_cpmProcExtUtil5Min_cpmProcExtPriority_cpmProcExtMemAllocatedRev_cpmProcExtMemFreedRev_cpmProcExtInvokedRev_cpmProcExtRuntimeRev_cpmProcExtUtil5SecRev_cpmProcExtUtil1MinRev_cpmProcExtUtil5MinRev_cpmProcExtPriorityRev',
      'oid_last' => 'CISCO-PROCESS-MIB::cpmProcessTable',
      'name' => 'TABLA DE PROCESOS',
      'descr' => 'Muestra Informacion en detalle sobre los procesos en curso del dispositivo',
      'xml_file' => '00009-CISCO-PROCESS.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_processestable',
      'range' => 'CISCO-PROCESS-MIB::cpmProcessTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-PROCESS.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

   'MEMTABLE' => {

      'col_filters' => '#text_filter,#text_filter,#text_filter',
      'col_widths' => '20.20.20',
      'col_sorting' => 'str.int.int',

      'oid_cols' => 'ciscoMemoryPoolName_ciscoMemoryPoolUsed_ciscoMemoryPoolFree',
      'oid_last' => 'CISCO-MEMORY-POOL-MIB::ciscoMemoryPoolTable',
      'name' => 'USO DE MEMORIA',
      'descr' => 'Muestra Informacion en detalle sobre el uso de memoria del dispositivo',
      'xml_file' => '00009-CISCO-MEMORY.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_memoryused',
      'range' => 'CISCO-MEMORY-POOL-MIB::ciscoMemoryPoolTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-MEMORY.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

   'CPUTABLE' => {

      'col_filters' => '#text_filter,#text_filter,#text_filter,#text_filter,',
      'col_widths' => '20.17.17.17',
      'col_sorting' => 'int.int.int.int',

      'oid_cols' => 'cpmCPUTotalPhysicalIndex_cpmCPUTotal5sec_cpmCPUTotal1min_cpmCPUTotal5min',
      'oid_last' => 'CISCO-PROCESS-MIB::cpmCPUTotalTable',
      'name' => 'USO DE CPU',
      'descr' => 'Muestra Informacion en detalle sobre el uso de CPU del dispositivo',
      'xml_file' => '00009-CISCO-CPU.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_cpuuse',
      'range' => 'CISCO-PROCESS-MIB::cpmCPUTotalTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-CPU.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

   'FLASHTABLE' => {

      'col_filters' => '#text_filter,#numeric_filter,#select_filter',
      'col_widths' => '40.15.15',
      'col_sorting' => 'str.int.int',

      'oid_cols' => 'flashDirName_flashDirSize_flashDirStatus',
      'oid_last' => 'OLD-CISCO-FLASH-MIB::lflashFileDirTable',
      'name' => 'CONTENIDO DE LA MEMORIA FLASH',
      'descr' => 'Muestra Informacion sobre el uso de la memoria Flash del dispositivo',
      'xml_file' => '00009-CISCO-FLASH.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_flashuse',
      'range' => 'OLD-CISCO-FLASH-MIB::lflashFileDirTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-FLASH.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

   'CHASISTABLE' => {

      'col_filters' => '#text_filter,#text_filter,#text_filter,#select_filter,#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter',
      'col_widths' => '20.20.20.15.25.25.15.15.20',
      'col_sorting' => 'str.str.str.int.int.int.int.int.int',

      'oid_cols' => 'cardIndex_cardType_cardDescr_cardSerial_cardHwVersion_cardSwVersion_cardSlotNumber_cardContainedByIndex_cardOperStatus_cardSlots',
      'oid_last' => 'OLD-CISCO-CHASSIS-MIB::cardTable',
      'name' => 'INFORMACION DEL CHASIS',
      'descr' => 'Muestra Informacion sobre el chasis del dispositivo',
      'xml_file' => '00009-CISCO-CHASIS.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_chasisinfo',
      'range' => 'OLD-CISCO-CHASSIS-MIB::cardTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-CHASIS.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

   'VOLTINFO' => {

      'col_filters' => '#text_filter,#text_filter,#text_filter,#select_filter,#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter',
      'col_widths' => '20.20.20.15.25.25.15.15.20',
      'col_sorting' => 'str.str.str.int.int.int.int.int.int',

      'oid_cols' => 'ciscoEnvMonVoltageStatusDescr_ciscoEnvMonVoltageStatusValue_ciscoEnvMonVoltageThresholdLow_ciscoEnvMonVoltageThresholdHigh_ciscoEnvMonVoltageLastShutdown_ciscoEnvMonVoltageState',
      'oid_last' => 'CISCO-ENVMON-MIB::ciscoEnvMonVoltageStatusTable',
      'name' => 'ESTADO DEL EQUIPO - VOLTAJE',
      'descr' => 'Muestra Informacion sobre el estado de los voltajes del dispositivo',
      'xml_file' => '00009-CISCO-ENVMON-VOLTAGE.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_voltage',
      'range' => 'CISCO-ENVMON-MIB::ciscoEnvMonVoltageStatusTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-ENVMON-VOLTAGE.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

   'TEMPINFO' => {

      'col_filters' => '#text_filter,#select_filter,#numeric_filter,#numeric_filter.#numeric_filter',
      'col_widths' => '35.35.35.35.30',
      'col_sorting' => 'str.int.int.int.int',

      'oid_cols' => 'ciscoEnvMonTemperatureStatusDescr_ciscoEnvMonTemperatureStatusValue_ciscoEnvMonTemperatureThreshold_ciscoEnvMonTemperatureLastShutdown_ciscoEnvMonTemperatureState',
      'oid_last' => 'CISCO-ENVMON-MIB::ciscoEnvMonTemperatureStatusTable',
      'name' => 'ESTADO DEL EQUIPO - TEMPERATURA',
      'descr' => 'Muestra Informacion sobre el estado de las temperaturas del dispositivo',
      'xml_file' => '00009-CISCO-ENVMON-TEMPERATURE.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_temperature',
      'range' => 'CISCO',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-ENVMON-TEMPERATURE.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

   'FANINFO' => {

      'col_filters' => '#text_filter,#select_filter',
      'col_widths' => '40.25',
      'col_sorting' => 'str.int',

      'oid_cols' => 'ciscoEnvMonFanStatusDescr_ciscoEnvMonFanState',
      'oid_last' => 'CISCO-ENVMON-MIB::ciscoEnvMonFanStatusTable',
      'name' => 'ESTADO DEL EQUIPO - VENTILADORES',
      'descr' => 'Muestra Informacion sobre el estado de los ventiladores del dispositivo',
      'xml_file' => '00009-CISCO-ENVMON-FAN.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_fan',
      'range' => 'CISCO-ENVMON-MIB::ciscoEnvMonFanStatusTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-ENVMON-FAN.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

   'POWERSUPINFO' => {

      'col_filters' => '#text_filter,#select_filter,#select_filter',
      'col_widths' => '40.25.25',
      'col_sorting' => 'str.int.int',

      'oid_cols' => 'ciscoEnvMonSupplyStatusDescr_ciscoEnvMonSupplyState_ciscoEnvMonSupplySource',
      'oid_last' => 'CISCO-ENVMON-MIB::ciscoEnvMonSupplyStatusTable',
      'name' => 'ESTADO DEL EQUIPO - FUENTES DE ALIMENTACION',
      'descr' => 'Muestra Informacion sobre el estado de las fuentes de alimentacion del dispositivo',
      'xml_file' => '00009-CISCO-ENVMON-SUPPLY.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_powersupply',
      'range' => 'CISCO',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-ENVMON-SUPPLY.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

   'IPSECTUNINFO' => {

      'col_filters' => '#text_filter,#text_filter,#text_filter,#select_filter,#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter',
      'col_widths' => '20.20.20.15.25.25.15.15.20',
      'col_sorting' => 'str.str.str.int.int.int.int.int.int',

      'oid_cols' => 'cikeTunLocalType_cikeTunLocalValue_cikeTunLocalAddr_cikeTunLocalName_cikeTunRemoteType_cikeTunRemoteValue_cikeTunRemoteAddr_cikeTunRemoteName_cikeTunNegoMode',
      'oid_last' => 'CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunnelTable',
      'name' => 'TUNELES IPSEC',
      'descr' => 'Muestra Informacion sobre los tuneles IPSEC establecidos del dispositivo',
      'xml_file' => '00009-CISCO-IPSEC-TUNNEL.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_ipsectunnels',
      'range' => 'CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunnelTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-IPSEC-TUNNEL.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

   'CRYPTOMAPINFO' => {

      'col_filters' => '#select_filter,#text_filter,#text_filter,#select_filter,#select_filter.#select_filter.#select_filter.#select_filter',
      'col_widths' => '20.20.20.15.25.25.15.15',
      'col_sorting' => 'str.str.str.int.int.int.int.int',

      'oid_cols' => 'cipsStaticCryptomapType_cipsStaticCryptomapDescr_cipsStaticCryptomapPeer_cipsStaticCryptomapPeer_cipsStaticCryptomapNumPeers_cipsStaticCryptomapPfs_cipsStaticCryptomapLifetime_cipsStaticCryptomapLevelHost',
      'oid_last' => 'CISCO-IPSEC-MIB::cipsStaticCryptomapTable',
      'name' => 'TUNELES IPSEC',
      'descr' => 'Muestra Informacion sobre los tuneles IPSEC configurados en el dispositivo',
      'xml_file' => '00009-CISCO-CRYPTOMAP-TUNNEL.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_cryptotunnels',
      'range' => 'CISCO-IPSEC-MIB::cipsStaticCryptomapTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-CRYPTOMAP-TUNNEL.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

   'FIREWALL_HW_STATUS' => {

      'col_filters' => '#select_filter,#text_filter,#select_filter,#text_filter',
      'col_widths' => '20.30.20.30',
      'col_sorting' => 'int.str.int.str',

      'oid_cols' => 'cfwHardwareType_cfwHardwareInformation_cfwHardwareStatusValue_cfwHardwareStatusDetail',
      'oid_last' => 'CISCO-FIREWALL-MIB::cfwHardwareStatusTable',
      'name' => 'ESTADO DEL HARDWARE DEL FIREWALL',
      'descr' => 'Muestra informacion sobre los valores de estado del firewall interno',
      'xml_file' => '00009-CISCO-FIREWALL-HW-STATUS.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_fw_hw_status',
      'range' => 'CISCO-FIREWALL-MIB::cfwHardwareStatusTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-FIREWALL-HW-STATUS.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

   'FIREWALL_CON_STATUS' => {

      'col_filters' => '#select_filter,#select_filter,#text_filter,#numeric_filter,#select_filter',
      'col_widths' => '20.20.30.15.15',
      'col_sorting' => 'int.int.str.int.int',

      'oid_cols' => 'cfwConnectionStatService_cfwConnectionStatType_cfwConnectionStatDescription_cfwConnectionStatCount_cfwConnectionStatValue',
      'oid_last' => 'CISCO-FIREWALL-MIB::cfwConnectionStatTable',
      'name' => 'ESTADO DE LAS CONEXIONES DEL FIREWALL',
      'descr' => 'Muestra informacion sobre los valores de estado de las conexiones del firewall interno',
      'xml_file' => '00009-CISCO-FIREWALL-CON-STATUS.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_fw_con_status',
      'range' => 'CISCO-FIREWALL-MIB::cfwConnectionStatTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-FIREWALL-CON-STATUS.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

   'NAT_EXT_INFO' => {

      'col_filters' => '#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter',
      'col_widths' => '20.20.20.20',
      'col_sorting' => 'int.int.int.int',

      'oid_cols' => 'cneAddrTranslationNumActive_cneAddrTranslationNumPeak_cneAddrTranslation1min_cneAddrTranslation5min',
      'oid_last' => 'CISCO-NAT-EXT-MIB::cneAddrTranslationStatsTable',
      'name' => 'ESTADISTICAS DE NAT',
      'descr' => 'Muestra informacion sobre las estadisticas de NAT del dispositivo',
      'xml_file' => '00009-CISCO-NAT-EXT-STATUS.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_nat_ext_status',
      'range' => 'CISCO-NAT-EXT-MIB::cneAddrTranslationStatsTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-NAT-EXT-STATUS.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO',
   },

#CISCO-NAT-EXT-MIB::cneAddrTranslationStatsTable
#	cneAddrTranslationNumActive(1)
#	cneAddrTranslationNumPeak(2)
#	cneAddrTranslation5min(4) 

   'VLANTABLE' => {

      'col_filters' => '#text_filter,#select_filter,#select_filter,#select_filter',
      'col_widths' => '35.15.15.15',
      'col_sorting' => 'str.str.str.str',

      'oid_cols' => 'vtpVlanName_vtpVlanType_vtpVlanState_vtpVlanMtu',
      'oid_last' => 'CISCO-VTP-MIB::vtpVlanTable',
      'name' => 'TABLA DE VLANs',
      'descr' => 'Muestra Informacion sobre las VLANs definidas en el equipo',
      'xml_file' => '00009-CISCO-VLAN-TABLE.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO',
      'aname'=>'app_cisco_vlans',
      'range' => 'CISCO-VTP-MIB::vtpVlanTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-VLAN-TABLE.xml -w xml ',
      'itil_type' => 1,    'apptype'=>'NET.CISCO',
   },


#   '' => {
#
#      'col_filters' => '#text_filter,#text_filter,#text_filter,#select_filter,#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter.#numeric_filter',
#      'col_widths' => '20.20.20.15.25.25.15.15.20',
#      'col_sorting' => 'str.str.str.int.int.int.int.int.int',
#
#      'oid_cols' => '',
#      'oid_last' => '',
#      'name' => '',
#      'descr' => '',
#      'xml_file' => '',
#      'params' => '[-n;IP;]',
#      'ipparam' => '[-n;IP;]',
#      'subtype'=>'',
#      'aname'=>'',
#      'range' => '',
#      'enterprise' => '00009',  #5 CIFRAS !!!!
#      'cmd' => '/opt/crawler/bin/libexec/snmptable -f  -w xml ',
#   },


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00009_CISCO::METRICS=(

#	{  'name'=> 'TASA DE ESCANEO',   'oid'=>'FINJAN-MIB::vsScannerReqs-per-second.0', 'subtype'=>'finjan_scan_reqs', 'class'=>'FINJAN' },
#	{  'name'=> 'TASA DE TRANSFERENCIA',   'oid'=>'FINJAN-MIB::vsScannerThroughput-in-total.0|FINJAN-MIB::vsScannerThroughput-out-total.0', 'subtype'=>'finjan_scan_thro', 'class'=>'FINJAN' },
	#{	'name'=> 'MEMORIA ASIGNADA',	'oid'=>'WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0|WINDOWS-NT-PERFORMANCE::memoryCommitLimit.0', 'subtype'=>'winnt_memory_committed_bytes', 'class'=>'WINDOWS-NT'},


   # SYNTAX INTEGER {notKnown(1), disabled(2), initialization(3), negotiation(4), standbyCold(5), standbyColdConfig(6), standbyColdFileSys(7), standbyColdBulk(8), standbyHot(9), activeFast(10), activeDrain(11), activePreconfig(12), activePostconfig(13), active(14), activeExtraload(15), activeHandback(16)}

#   {  'name'=> 'ESTADO DE LA SUPERVISORA',  'oid'=>'CISCO-RF-MIB::cRFStatusUnitState', 'subtype'=>'cisco_rf_state', 'class'=>'CISCO',  'esp'=>'MAP(1)(1,0,0,0,0,0)|MAP(2)(0,1,0,0,0,0)|MAP(3)(0,0,1,0,0,0)|MAP(4)(0,0,0,1,0,0)|MAP(5)(0,0,0,0,1,0)|MAP(6)(0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'items'=>'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00009_CISCO::METRICS_TAB=(


#	{	'name'=> 'ESTADO DE PERFILES DEL AP',  'oid'=>'bsnAPIfLoadProfileState|bsnAPIfInterferenceProfileState|bsnAPIfNoiseProfileState|bsnAPIfCoverageProfileState', 'subtype'=>'airspace_ap_profiles', 'class'=>'CISCO-AIRONET', 'range'=>'AIRESPACE-WIRELESS-MIB::bsnAPIfProfileStateTable', 'get_iid'=>'bsnAPDot3MacAddress' },

	# SYNTAX        INTEGER {normal(1), warning(2), critical(3), shutdown(4), notPresent(5), notFunctioning(6)}
	# 
   {  'name'=> 'ESTADO DEL VENTILADOR',  'oid'=>'ciscoEnvMonFanState', 'subtype'=>'cisco_fan_state', 'class'=>'CISCO', 'range'=>'CISCO-ENVMON-MIB::ciscoEnvMonFanStatusTable', 'get_iid'=>'ciscoEnvMonFanStatusDescr',  'esp'=>'MAP(1)(1,0,0,0,0,0)|MAP(2)(0,1,0,0,0,0)|MAP(3)(0,0,1,0,0,0)|MAP(4)(0,0,0,1,0,0)|MAP(5)(0,0,0,0,1,0)|MAP(6)(0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'items'=>'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)', 'itil_type' => 4, 'apptype'=>'NET.CISCO' },

	# SYNTAX        INTEGER {normal(1), warning(2), critical(3), shutdown(4), notPresent(5), notFunctioning(6)}
	# 
   {  'name'=> 'ESTADO DE LA FUENTE DE ALIMENTACION',  'oid'=>'ciscoEnvMonSupplyState', 'subtype'=>'cisco_powersup_state', 'class'=>'CISCO', 'range'=>'CISCO-ENVMON-MIB::ciscoEnvMonSupplyStatusTable', 'get_iid'=>'ciscoEnvMonSupplyStatusDescr',  'esp'=>'MAP(1)(1,0,0,0,0,0)|MAP(2)(0,1,0,0,0,0)|MAP(3)(0,0,1,0,0,0)|MAP(4)(0,0,0,1,0,0)|MAP(5)(0,0,0,0,1,0)|MAP(6)(0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'items'=>'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)', 'itil_type' => 4, 'apptype'=>'NET.CISCO' },

   # SYNTAX        INTEGER {normal(1), warning(2), critical(3), shutdown(4), notPresent(5), notFunctioning(6)}
   #
   {  'name'=> 'ESTADO DE LA TEMPERATURA',  'oid'=>'ciscoEnvMonTemperatureState', 'subtype'=>'cisco_temperature_state', 'class'=>'CISCO', 'range'=>'CISCO-ENVMON-MIB::ciscoEnvMonTemperatureStatusTable', 'get_iid'=>'ciscoEnvMonTemperatureStatusDescr',  'esp'=>'MAP(1)(1,0,0,0,0,0)|MAP(2)(0,1,0,0,0,0)|MAP(3)(0,0,1,0,0,0)|MAP(4)(0,0,0,1,0,0)|MAP(5)(0,0,0,0,1,0)|MAP(6)(0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'items'=>'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)', 'itil_type' => 4, 'apptype'=>'NET.CISCO' },

   # SYNTAX        INTEGER {normal(1), warning(2), critical(3), shutdown(4), notPresent(5), notFunctioning(6)}
   #
   {  'name'=> 'ESTADO DEL VOLTAJE',  'oid'=>'ciscoEnvMonVoltageState', 'subtype'=>'cisco_voltage_state', 'class'=>'CISCO', 'range'=>'CISCO-ENVMON-MIB::ciscoEnvMonVoltageStatusTable', 'get_iid'=>'ciscoEnvMonVoltageStatusDescr',  'esp'=>'MAP(1)(1,0,0,0,0,0)|MAP(2)(0,1,0,0,0,0)|MAP(3)(0,0,1,0,0,0)|MAP(4)(0,0,0,1,0,0)|MAP(5)(0,0,0,0,1,0)|MAP(6)(0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'items'=>'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)', 'itil_type' => 4, 'apptype'=>'NET.CISCO' },

#root@cnm-pro:/opt/cnm# snmptranslate -Td -On CISCO-VTP-MIB::vtpVlanState
#.1.3.6.1.4.1.9.9.46.1.3.1.1.2
#  SYNTAX        INTEGER {operational(1), suspended(2), mtuTooBigForDevice(3), mtuTooBigForTrunk(4)}
#  DESCRIPTION   "The state of this VLAN.
#
#            The state 'mtuTooBigForDevice' indicates that this device
#            cannot participate in this VLAN because the VLAN's MTU is
#            larger than the device can support.
#
#            The state 'mtuTooBigForTrunk' indicates that while this
#            VLAN's MTU is supported by this device, it is too large for
#            one or more of the device's trunk ports."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) cisco(9) ciscoMgmt(9) ciscoVtpMIB(46) vtpMIBObjects(1) vlanInfo(3) vtpVlanTable(1) vtpVlanEntry(1) 2 }

   {  'name'=> 'TABLA DE VLANs',  'oid'=>'vtpVlanState', 'subtype'=>'cisco_vlan_sum', 'class'=>'CISCO', 'range'=>'CISCO-VTP-MIB::vtpVlanTable', 'get_iid'=>'vtpVlanName', 'itil_type'=>1, 'mtype'=>'STD_BASE',
'esp'=>'TABLE(MATCH)(1)|TABLE(MATCH)(3)|TABLE(MATCH)(2)|TABLE(MATCH)(4)', 'items'=>'operational(1)|suspended(2)|mtuTooBigForDevice(3)|mtuTooBigForTrunk(4)', 'apptype'=>'NET.CISCO' },

);


1;
__END__
