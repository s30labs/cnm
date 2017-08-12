#--------------------------------------------------------------------------- 
package ENT_02636_JUNIPER;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_02636_JUNIPER::ENTERPRISE_PREFIX='02636';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_02636_JUNIPER::TABLE_APPS =(

   'CHASSIS-INFO' => {

      'col_filters' => '#select_filter,#select_filter,#select_filter,#select_filter,#text_filter,#numeric_filter',
      'col_widths' => '20.20.20.15.25.15',
      'col_sorting' => 'int.int.int.int.str.int',

      'oid_cols' => 'jnxContainersView_jnxContainersLevel_jnxContainersWithin_jnxContainersType_jnxContainersDescr_jnxContainersCount',
      'oid_last' => 'JUNIPER-MIB::jnxContainersTable',
      'name' => 'INFORMACION SOBRE EL CHASIS',
      'descr' => 'Muestra informacion sobre los elementos que componen el chasis del equipo',
      'xml_file' => '02636-JUNIPER-CHASSIS-INFO.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'JUNIPER',
      'aname'=>'app_jun_chassis_info',
      'range' => 'JUNIPER-MIB::jnxContainersTable',
      'enterprise' => '02636',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 02636-JUNIPER-CHASSIS-INFO.xml -w xml ',
		'itil_type' => '1',		'apptype'=>'NET.JUNIPER',
   },

#   'POLICY-STATS' => {
#
#      'col_filters' => '#text_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter',
#      'col_widths' => '20.20.20.15.25.25.15.15.20.20.20.20.20.20',
#      'col_sorting' => 'str.int.int.int.int.int.int.int.int.int.int.int.int.int',
#
#      'oid_cols' => 'jnxJsPolicyStatsCreationTime_jnxJsPolicyStatsInputBytes_jnxJsPolicyStatsInputByteRate_jnxJsPolicyStatsOutputBytes_jnxJsPolicyStatsOutputByteRate_jnxJsPolicyStatsInputPackets_jnxJsPolicyStatsInputPacketRate_jnxJsPolicyStatsOutputPackets_jnxJsPolicyStatsOutputPacketRate_jnxJsPolicyStatsNumSessions_jnxJsPolicyStatsSessionRate_jnxJsPolicyStatsSessionDeleted_jnxJsPolicyStatsLookups_jnxJsPolicyStatsCountAlarm',
#      'oid_last' => 'JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsTable',
#      'name' => 'ESTADO',
#      'descr' => '',
#      'xml_file' => '',
#      'params' => '[-n;IP;]',
#      'ipparam' => '[-n;IP;]',
#      'subtype'=>'JUNIPER',
#      'aname'=>'app_jun_',
#      'range' => 'JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsTable',
#      'enterprise' => '02636',  #5 CIFRAS !!!!
#      'cmd' => '/opt/crawler/bin/libexec/snmptable -f  -w xml ',
#   },

   'VLAN_TABLE' => {

      'col_filters' => '#text_filter,#text_filter,#numeric_filter,#numeric_filter.#numeric_filter',
      'col_widths' => '20.20.20.15.25',
      'col_sorting' => 'str.str.int.int.int',

      'oid_cols' => 'jnxExVlanID_jnxExVlanName_jnxExVlanType_jnxExVlanPortGroupInstance_jnxExVlanTag',
      'oid_last' => 'JUNIPER-VLAN-MIB::jnxExVlanTable',
      'name' => 'TABLA DE VLANs',
      'descr' => 'Muestra informacion sobre las VLANs definidas en el equipo',
      'xml_file' => '02636-JUNIPER-VLAN-TABLE.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'JUNIPER',
      'aname'=>'app_jun_vlan_table',
      'range' => 'JUNIPER-VLAN-MIB::jnxExVlanTable',
      'enterprise' => '02636',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 02636-JUNIPER-VLAN-TABLE.xml -w xml ',
		'itil_type' => '1',		'apptype'=>'NET.JUNIPER',
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
#      'subtype'=>'JUNIPER',
#      'aname'=>'app_jun_',
#      'range' => '',
#      'enterprise' => '02636',  #5 CIFRAS !!!!
#      'cmd' => '/opt/crawler/bin/libexec/snmptable -f  -w xml ',
#   },


#JUNIPER-MIB::jnxContainersIndex.1 = INTEGER: 1
#JUNIPER-MIB::jnxContainersType.1 = OID: JUNIPER-CHASSIS-DEFINES-MIB::jnxChassisSRX240.0

);

#JUNIPER-ALARM-MIB::jnxAlarmRelayMode.0 = INTEGER: 2
#JUNIPER-ALARM-MIB::jnxYellowAlarmState.0 = INTEGER: 3
#JUNIPER-ALARM-MIB::jnxYellowAlarmCount.0 = Gauge32: 1
#JUNIPER-ALARM-MIB::jnxYellowAlarmLastChange.0 = Timeticks: (764) 0:00:07.64
#JUNIPER-ALARM-MIB::jnxRedAlarmState.0 = INTEGER: 2
#JUNIPER-ALARM-MIB::jnxRedAlarmCount.0 = Gauge32: 0
#JUNIPER-ALARM-MIB::jnxRedAlarmLastChange.0 = Timeticks: (0) 0:00:00.00

#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsCreationTime."untrust"."DMZ"."Entrada_Correo" = Timeticks: (42250318) 4 days, 21:21:43.18
#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsInputBytes."untrust"."DMZ"."Entrada_Correo" = Counter64: 25479834
#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsInputByteRate."untrust"."DMZ"."Entrada_Correo" = Gauge32: 0
#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsOutputBytes."untrust"."DMZ"."Entrada_Correo" = Counter64: 25482181
#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsOutputByteRate."untrust"."DMZ"."Entrada_Correo" = Gauge32: 0
#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsInputPackets."untrust"."DMZ"."Entrada_Correo" = Counter32: 216318
#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsInputPacketRate."untrust"."DMZ"."Entrada_Correo" = Gauge32: 0
#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsOutputPackets."untrust"."DMZ"."Entrada_Correo" = Counter32: 217198
#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsOutputPacketRate."untrust"."DMZ"."Entrada_Correo" = Gauge32: 0
#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsNumSessions."untrust"."DMZ"."Entrada_Correo" = Counter32: 19419
#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsSessionRate."untrust"."DMZ"."Entrada_Correo" = Gauge32: 0
#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsSessionDeleted."untrust"."DMZ"."Entrada_Correo" = Counter32: 19419
#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsLookups."untrust"."DMZ"."Entrada_Correo" = Counter32: 19415
#JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsCountAlarm."untrust"."DMZ"."Entrada_Correo" = Counter32: 0
#JUNIPER-JS-NAT-MIB::jnxJsSrcNatNumOfEntries.0 = Gauge32: 1
#

#JUNIPER-CHASSIS-FWDD-MIB::jnxFwddMicroKernelCPUUsage.0 = Gauge32: 26
#JUNIPER-CHASSIS-FWDD-MIB::jnxFwddRtThreadsCPUUsage.0 = Gauge32: 1
#JUNIPER-CHASSIS-FWDD-MIB::jnxFwddHeapUsage.0 = Gauge32: 61
#JUNIPER-CHASSIS-FWDD-MIB::jnxFwddDmaMemUsage.0 = Gauge32: 1
#JUNIPER-CHASSIS-FWDD-MIB::jnxFwddUpTime.0 = INTEGER: 1664133

#JUNIPER-SMI::jnxMibs.36.1.1.1.0 = Hex-STRING: 0A C4 04 01
#JUNIPER-VPN-MIB::jnxVpnConfiguredVpns.0 = Gauge32: 0
#JUNIPER-VPN-MIB::jnxVpnActiveVpns.0 = Gauge32: 0
#JUNIPER-VPN-MIB::jnxVpnNextIfIndex.0 = Gauge32: 0
#JUNIPER-VPN-MIB::jnxVpnNextPwIndex.0 = Gauge32: 0
#JUNIPER-VPN-MIB::jnxVpnNextRTIndex.0 = Gauge32: 0

#JUNIPER-MIB::jnxOperatingDescr.1.1.0.0 = STRING: midplane
#JUNIPER-MIB::jnxOperatingDescr.2.1.0.0 = STRING: PEM 0
#JUNIPER-MIB::jnxOperatingDescr.4.1.0.0 = STRING: SRX240 PowerSupply fan 1
#JUNIPER-MIB::jnxOperatingDescr.4.2.0.0 = STRING: SRX240 PowerSupply fan 2
#JUNIPER-MIB::jnxOperatingDescr.4.3.0.0 = STRING: SRX240 CPU fan 1
#JUNIPER-MIB::jnxOperatingDescr.4.4.0.0 = STRING: SRX240 CPU fan 2
#JUNIPER-MIB::jnxOperatingDescr.4.5.0.0 = STRING: SRX240 IO  fan 1
#JUNIPER-MIB::jnxOperatingDescr.4.6.0.0 = STRING: SRX240 IO  fan 2
#JUNIPER-MIB::jnxOperatingDescr.7.1.0.0 = STRING: FPC: FPC @ 0/*/*
#JUNIPER-MIB::jnxOperatingDescr.8.1.1.0 = STRING: PIC: 16x GE Base PIC @ 0/0/*
#JUNIPER-MIB::jnxOperatingDescr.9.1.0.0 = STRING: Routing Engine
#JUNIPER-MIB::jnxOperatingDescr.9.1.1.0 = STRING: USB Hub
#JUNIPER-MIB::jnxOperatingState.1.1.0.0 = INTEGER: 2
#JUNIPER-MIB::jnxOperatingState.2.1.0.0 = INTEGER: 2
#JUNIPER-MIB::jnxOperatingState.4.1.0.0 = INTEGER: 2
#JUNIPER-MIB::jnxOperatingState.4.2.0.0 = INTEGER: 2
#JUNIPER-MIB::jnxOperatingState.4.3.0.0 = INTEGER: 2
#JUNIPER-MIB::jnxOperatingState.4.4.0.0 = INTEGER: 2
#JUNIPER-MIB::jnxOperatingState.4.5.0.0 = INTEGER: 2
#JUNIPER-MIB::jnxOperatingState.4.6.0.0 = INTEGER: 2
#JUNIPER-MIB::jnxOperatingState.7.1.0.0 = INTEGER: 2
#JUNIPER-MIB::jnxOperatingState.8.1.1.0 = INTEGER: 2
#JUNIPER-MIB::jnxOperatingState.9.1.0.0 = INTEGER: 2
#JUNIPER-MIB::jnxOperatingState.9.1.1.0 = INTEGER: 2
#
#
#JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringFPCIndex.0 = Gauge32: 0
#JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringSPUIndex.0 = Gauge32: 0
#JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringCPUUsage.0 = Gauge32: 1
#JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringMemoryUsage.0 = Gauge32: 61
#JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringCurrentFlowSession.0 = Gauge32: 58
#JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringMaxFlowSession.0 = Gauge32: 131072
#JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringCurrentCPSession.0 = Gauge32: 0
#JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringMaxCPSession.0 = Gauge32: 0
#JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringNodeIndex.0 = Gauge32: 0
#JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringNodeDescr.0 = STRING: single
#JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringCurrentTotalSession.0 = Gauge32: 0
#JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringMaxTotalSession.0 = Gauge32: 0
#
#JUNIPER-VLAN-MIB::jnxExVlanName.2 = STRING: DMZ-EXT
#JUNIPER-VLAN-MIB::jnxExVlanName.4 = STRING: default
#JUNIPER-VLAN-MIB::jnxExVlanName.5 = STRING: vlan-trust
#JUNIPER-VLAN-MIB::jnxExVlanName.6 = STRING: vlan-untrust
#
#JUNIPER-EX-MAC-NOTIFICATION-MIB::jnxMacGlobalFeatureEnabled.0 = INTEGER: 1
#JUNIPER-EX-MAC-NOTIFICATION-MIB::jnxMacNotificationInterval.0 = Gauge32: 0
#JUNIPER-EX-MAC-NOTIFICATION-MIB::jnxMacAddressesLearnt.0 = Counter64: 802
#JUNIPER-EX-MAC-NOTIFICATION-MIB::jnxMacAddressesRemoved.0 = Counter64: 793
#JUNIPER-EX-MAC-NOTIFICATION-MIB::jnxMacNotificationsEnabled.0 = INTEGER: 2
#JUNIPER-EX-MAC-NOTIFICATION-MIB::jnxMacNotificationsSent.0 = Counter64: 0
#JUNIPER-EX-MAC-NOTIFICATION-MIB::jnxMacHistTableMaxLength.0 = Gauge32: 256
#
#JUNIPER-PFE-MIB::jnxPfeNotifyGlParsed.0 = Counter32: 5160708
#JUNIPER-PFE-MIB::jnxPfeNotifyGlAged.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlCorrupt.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlIllegal.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlSample.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlGiants.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlTtlExceeded.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlTtlExcErrors.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlSvcOptAsp.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlSvcOptRe.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlPostSvcOptOut.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlOptTtlExp.0 = Counter32: 2
#JUNIPER-PFE-MIB::jnxPfeNotifyGlDiscSample.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlRateLimited.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlPktGetFails.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlDmaFails.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlDmaTotals.0 = Counter32: 0
#JUNIPER-PFE-MIB::jnxPfeNotifyGlUnknowns.0 = Counter32: 0
#
#JUNIPER-PFE-MIB::jnxPfeNotifyTypeDescr.0.reject = STRING: Reject
#JUNIPER-PFE-MIB::jnxPfeNotifyTypeParsed.0.illegal = Counter32: 0
#
##---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO GET
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_02636_JUNIPER::GET_APPS =(

  'GET_INFO' => {

		items => [

						{  'name'=> 'TIPO DE HARDWARE',   'oid'=>'JUNIPER-MIB::jnxBoxClass.0', 'esp'=>'' },
						{  'name'=> 'TIPO DE HARDWARE',   'oid'=>'JUNIPER-MIB::jnxBoxDescr.0', 'esp'=>'' },
						{  'name'=> 'NUMERO DE SERIE',   'oid'=>'JUNIPER-MIB::jnxBoxSerialNo.0', 'esp'=>'' },
		],

		'oid_cols' => 'jnxBoxClass_jnxBoxDescr_jnxBoxSerialNo',		
     	'name' => 'INFORMACION DEL EQUIPO',
     	'descr' => 'Muestra informacion basica sobre el equipo',
     	'xml_file' => '02636_JUNIPER-get_info.xml',
     	'params' => '[-n;IP;]',
     	'ipparam' => '[-n;IP;]',
     	'subtype'=>'JUNIPER',		'apptype'=>'NET.JUNIPER',
     	'aname'=>'app_juniper_get_info',
	  	'range' => 'JUNIPER-MIB::jnxBoxClass.0',
     	'enterprise' => '02636',  #5 CIFRAS !!!!
     	'cmd' => '/opt/crawler/bin/libexec/snmptable -f 02636_JUNIPER-get_info.xml -w xml ',
  },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
# CREADA APLICACION TIPO GET:
#		00000-ENT_02636_JUNIPER-get_info.xml
#---------------------------------------------------------------------------
@ENT_02636_JUNIPER::METRICS=(

# El campo items solo se pone si va a ser distinto de oid
#JUNIPER-CHASSIS-FWDD-MIB::jnxFwddMicroKernelCPUUsage.0 = Gauge32: 26
#JUNIPER-CHASSIS-FWDD-MIB::jnxFwddRtThreadsCPUUsage.0 = Gauge32: 1
#JUNIPER-CHASSIS-FWDD-MIB::jnxFwddHeapUsage.0 = Gauge32: 61
#JUNIPER-CHASSIS-FWDD-MIB::jnxFwddDmaMemUsage.0 = Gauge32: 1


	{  'name'=> 'USO DE CPU DEL FWDD',   'oid'=>'JUNIPER-CHASSIS-FWDD-MIB::jnxFwddMicroKernelCPUUsage.0|JUNIPER-CHASSIS-FWDD-MIB::jnxFwddRtThreadsCPUUsage.0', 'subtype'=>'jun_fwdd_cpu', 'class'=>'JUNIPER', 'vlabel'=>'%', 'include'=>1, 'esp'=>'', 'itil_type'=>1, 'apptype'=>'NET.JUNIPER' },
	{  'name'=> 'USO DE HEAP DEL FWDD',   'oid'=>'JUNIPER-CHASSIS-FWDD-MIB::jnxFwddHeapUsage.0', 'subtype'=>'jun_fwdd_heap', 'class'=>'JUNIPER', 'vlabel'=>'%', 'include'=>1, 'esp'=>'', 'itil_type'=>1, 'apptype'=>'NET.JUNIPER' },
	{  'name'=> 'USO DE DMA DEL FWDD',   'oid'=>'JUNIPER-CHASSIS-FWDD-MIB::jnxFwddDmaMemUsage.0', 'subtype'=>'jun_fwdd_dma', 'class'=>'JUNIPER', 'vlabel'=>'%', 'include'=>1, 'esp'=>'', 'itil_type'=>1, 'apptype'=>'NET.JUNIPER' },
	

#	{  'name'=> 'LATENCIA DEL DNS (Non-AA)',   'oid'=>'IB-PLATFORMONE-MIB::ibNetworkMonitorDNSNonAAT5AvgLatency.0', 'subtype'=>'ib_dns_nonaa_lat', 'class'=>'INFOBLOX', 'vlabel'=>'microseconds', 'include'=>1, 'esp'=>'' },
#	{  'name'=> 'CONSULTAS AL DNS (Non-AA)',   'oid'=>'IB-PLATFORMONE-MIB::ibNetworkMonitorDNSNonAAT5Count.0', 'subtype'=>'ib_dns_nonaa_cnt', 'class'=>'INFOBLOX', 'vlabel'=>'num. queries', 'include'=>1,  'esp'=>'' },
#
#   {  'name'=> 'ESTADO SERVICIO DHCP',   'oid'=>'IB-PLATFORMONE-MIB::ibServiceStatus.1', 'subtype'=>'ib_status_dhcp', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID' },
	#{	'name'=> 'MEMORIA ASIGNADA',	'oid'=>'WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0|WINDOWS-NT-PERFORMANCE::memoryCommitLimit.0', 'subtype'=>'winnt_memory_committed_bytes', 'class'=>'WINDOWS-NT'},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_02636_JUNIPER::METRICS_TAB=(

   {  'name'=> 'USO DE CPU EN SPU',  'oid'=>'JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringCPUUsage', 'subtype'=>'jun_spu_cpu', 'class'=>'JUNIPER', 'range'=>'JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringObjectsTable', 'get_iid'=>'JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringIndex', 'itil_type'=>1, 'apptype'=>'NET.JUNIPER' },
   {  'name'=> 'USO DE MEMORIA EN SPU',  'oid'=>'JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringMemoryUsage', 'subtype'=>'jun_spu_mem', 'class'=>'JUNIPER', 'range'=>'JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringObjectsTable', 'get_iid'=>'JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringIndex', 'itil_type'=>1, 'apptype'=>'NET.JUNIPER' },
   {  'name'=> 'SESIONES EN SPU',  'oid'=>'JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringCurrentFlowSession', 'subtype'=>'jun_spu_ses', 'class'=>'JUNIPER', 'range'=>'JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringObjectsTable', 'get_iid'=>'JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringIndex', 'itil_type'=>1, 'apptype'=>'NET.JUNIPER' },
   {  'name'=> 'SESIONES CP EN SPU',  'oid'=>'JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringCurrentCPSession', 'subtype'=>'jun_spu_cp_ses', 'class'=>'JUNIPER', 'range'=>'JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringObjectsTable', 'get_iid'=>'JUNIPER-SRX5000-SPU-MONITORING-MIB::jnxJsSPUMonitoringIndex', 'itil_type'=>1, 'apptype'=>'NET.JUNIPER' },


#   {  'name'=> 'TRAFICO EN POLICY (BYTES)',  'oid'=>'JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsInputBytes|JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsOutputBytes', 'subtype'=>'jun_policy_traf_bytes', 'class'=>'JUNIPER', 'range'=>'JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsTable', 'get_iid'=>'' },
#   {  'name'=> 'TRAFICO EN POLICY (PACKETS)',  'oid'=>'JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsInputPackets|JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsOutputPackets', 'subtype'=>'jun_policy_traf_pkts', 'class'=>'JUNIPER', 'range'=>'JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsTable', 'get_iid'=>'' },
#   {  'name'=> 'SESIONES EN POLICY',  'oid'=>'JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsNumSessions', 'subtype'=>'jun_policy_num_ses', 'class'=>'JUNIPER', 'range'=>'JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsTable', 'get_iid'=>'' },


#	{	'name'=> 'FALLOS AL ACTUALIZAR',  'oid'=>'updateFailures', 'subtype'=>'ironport_update_fail', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
#	{	'name'=> 'TASA DE ACTUALIZACIONES',  'oid'=>'updates', 'subtype'=>'ironport_update_rate', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
# 	{	'name'=> '',  'oid'=>'', 'subtype'=>'ironport_temperature', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::', 'get_iid'=>'ASYNCOS-MAIL-MIB::' },

);


1;
__END__
