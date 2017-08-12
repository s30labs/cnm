#---------------------------------------------------------------------------
package ENT_00009_CISCO_CCM;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_00009_CISCO_CCM::ENTERPRISE_PREFIX='00009';


#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_00009_CISCO_CCM::TABLE_APPS =(

	'CLUSTER INFO' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#select_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '25.25.25.25.25.25.25',
      'col_sorting' => 'str.str.str.str.str.str.str',

		'oid_cols' => 'ccmName_ccmDescription_ccmVersion_ccmStatus_ccmInetAddressType_ccmInetAddress_ccmClusterId',
		'oid_last' => 'CISCO-CCM-MIB::ccmTable',
		'name' => 'INFORMACION SOBRE EL CLUSTER',
		'descr' => 'Muestra informacion relevante sobre el cluster de Call Managers',
		'xml_file' => '00009_CISCO_CCM_CLUSTER_INFO.xml',
		'params' => '[-n;IP;]',
		'ipparam' => '[-n;IP;]',
		'subtype'=>'CISCO-VOIP',
		'aname'=>'app_cisco_ccm_cluster_info',
		'range' => 'CISCO-CCM-MIB::ccmTable',
		'enterprise' => '00009',  #5 CIFRAS !!!!
		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_CLUSTER_INFO.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO-VOIP',
	},

   'PHONE INFO' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#select_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '25.25.25.25.25.25.25.25.25',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str',

      'oid_cols' => 'ccmPhonePhysicalAddress_ccmPhoneType_ccmPhoneDescription_ccmPhoneUserName_ccmPhoneIpAddress_ccmPhoneStatus_ccmPhoneTimeLastRegistered_ccmPhoneE911Location_ccmPhoneLoadID_ccmPhoneLastError_ccmPhoneTimeLastError_ccmPhoneDevicePoolIndex_ccmPhoneInetAddressType_ccmPhoneInetAddress_ccmPhoneStatusReason_ccmPhoneTimeLastStatusUpdt',
      'oid_last' => 'CISCO-CCM-MIB::ccmPhoneTable',

      'name' => 'TELEFONOS DEFINIDOS',
      'descr' => 'Muestra informacion relevante sobre los telefonos definidos en el Call Manager',
      'xml_file' => '00009_CISCO_CCM_PHONE_INFO.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-VOIP',
      'aname'=>'app_cisco_ccm_phone_info',
      'range' => 'CISCO-CCM-MIB::ccmPhoneTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_PHONE_INFO.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO-VOIP',
   },


   'TIMEZONE_INFO' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter',
      'col_widths' => '25.25.25',
      'col_sorting' => 'str.str.str',

      'oid_cols' => 'ccmTimeZoneName_ccmTimeZoneOffsetHours_ccmTimeZoneOffsetMinutes',
      'oid_last' => 'CISCO-CCM-MIB::ccmTimeZoneTable',

      'name' => 'ZONAS HORARIAS',
      'descr' => 'Muestra informacion relevante sobre las zonas horarias definidas en el Call Manager',
      'xml_file' => '00009_CISCO_CCM_TIMEZONE_INFO.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-VOIP',
      'aname'=>'app_cisco_ccm_timezone_info',
      'range' => 'CISCO-CCM-MIB::ccmTimeZoneTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_TIMEZONE_INFO.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO-VOIP',
   },

   'GATEWAY INFO' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#select_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '25.25.25.25.25.25.25.25.25.25',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str.str',

      'oid_cols' => 'ccmGatewayName_ccmGatewayType_ccmGatewayDescription_ccmGatewayStatus_ccmGatewayDevicePoolIndex_ccmGatewayInetAddress_ccmGatewayProductId_ccmGatewayStatusReason_ccmGatewayTimeLastStatusUpdt_ccmGatewayTimeLastRegistered',
      'oid_last' => 'CISCO-CCM-MIB::ccmGatewayTable',

      'name' => 'GATEWAYS DEFINIDOS',
      'descr' => 'Muestra informacion relevante sobre los gateways definidos en el Call Manager',
      'xml_file' => '00009_CISCO_CCM_GATEWAY_INFO.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-VOIP',
      'aname'=>'app_cisco_ccm_gateway_info',
      'range' => 'CISCO-CCM-MIB::ccmGatewayTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_GATEWAY_INFO.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO-VOIP',
   },

   'MEDIA DEVICE INFO' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#select_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '25.25.25.25.25.25.25.25.25.25',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str.str',

      'oid_cols' => 'ccmMediaDeviceName_ccmMediaDeviceType_ccmMediaDeviceDescription_ccmMediaDeviceStatus_ccmMediaDeviceDevicePoolIndex_ccmMediaDeviceInetAddressType_ccmMediaDeviceInetAddress_ccmMediaDeviceStatusReason_ccmMediaDeviceTimeLastStatusUpdt_ccmMediaDeviceTimeLastRegistered',
      'oid_last' => 'CISCO-CCM-MIB::ccmMediaDeviceTable',

      'name' => 'MEDIA DEVICES DEFINIDOS',
      'descr' => 'Muestra informacion relevante sobre los media devices definidos en el Call Manager',
      'xml_file' => '00009_CISCO_CCM_MEDIA_DEVICES_INFO.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-VOIP',
      'aname'=>'app_cisco_ccm_media_dev_info',
      'range' => 'CISCO-CCM-MIB::ccmMediaDeviceTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_MEDIA_DEVICES_INFO.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO-VOIP',
   },

   'GATEKEEPER INFO' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '25.25.25.25.25.25.25',
      'col_sorting' => 'str.str.str.str.str.str.str',

      'oid_cols' => 'ccmGatekeeperName_ccmGatekeeperType_ccmGatekeeperDescription_ccmGatekeeperStatus_ccmGatekeeperDevicePoolIndex_ccmGatekeeperInetAddressType_ccmGatekeeperInetAddress',
      'oid_last' => 'CISCO-CCM-MIB::ccmGatekeeperTable',

      'name' => 'GATEKEEPERS DEFINIDOS',
      'descr' => 'Muestra informacion relevante sobre los Gatekeepers definidos en el Call Manager',
      'xml_file' => '00009_CISCO_CCM_GATEKEEPER_INFO.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-VOIP',
      'aname'=>'app_cisco_ccm_gatekeeper_info',
      'range' => 'CISCO-CCM-MIB::ccmGatekeeperTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_GATEKEEPER_INFO.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO-VOIP',
   },

   'CTI DEVICES INFO' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#select_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '25.25.25.25.25.25.25.25.25.25.25',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str.str.str',

      'oid_cols' => 'ccmCTIDeviceName_ccmCTIDeviceType_ccmCTIDeviceDescription_ccmCTIDeviceStatus_ccmCTIDevicePoolIndex_ccmCTIDeviceInetAddressType_ccmCTIDeviceInetAddress_ccmCTIDeviceAppInfo_ccmCTIDeviceStatusReason_ccmCTIDeviceTimeLastStatusUpdt_ccmCTIDeviceTimeLastRegistered',
      'oid_last' => 'CISCO-CCM-MIB::ccmCTIDeviceTable',

      'name' => 'DISPOSITIVOS CTI DEFINIDOS',
      'descr' => 'Muestra informacion relevante sobre los dispositivos CTI registrados en el Call Manager',
      'xml_file' => '00009_CISCO_CCM_CTI_DEVICES_INFO.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-VOIP',
      'aname'=>'app_cisco_ccm_cti_dev_info',
      'range' => 'CISCO-CCM-MIB::ccmCTIDeviceTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_CTI_DEVICES_INFO.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO-VOIP',
   },

   'H323 DEVICES INFO' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#select_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '25.25.25.25.25.25.25.25.25.25.25',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str.str.str',

      'oid_cols' => 'ccmH323DevName_ccmH323DevProductId_ccmH323DevDescription_ccmH323DevInetAddressType_ccmH323DevInetAddress_ccmH323DevCnfgGKInetAddressType_ccmH323DevCnfgGKInetAddress_ccmH323DevStatus_ccmH323DevStatusReason_ccmH323DevTimeLastStatusUpdt_ccmH323DevTimeLastRegistered',
      'oid_last' => 'CISCO-CCM-MIB::ccmH323DeviceTable',

      'name' => 'DISPOSITIVOS H323 DEFINIDOS',
      'descr' => 'Muestra informacion relevante sobre los dispositivos H323 registraods en el Call Manager',
      'xml_file' => '00009_CISCO_CCM_H323_DEVICES_INFO.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-VOIP',
      'aname'=>'app_cisco_ccm_h323_dev_info',
      'range' => 'CISCO-CCM-MIB::ccmH323DeviceTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_H323_DEVICES_INFO.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO-VOIP',
   },

   'VOICE MAIL DEVICES INFO' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#select_filter.#text_filter.#text_filter.#text_filter.#text_filter',
      'col_widths' => '25.25.25.25.25.25.25.25.25',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str',

      'oid_cols' => 'ccmVMailDevName_ccmVMailDevProductId_ccmVMailDevDescription_ccmVMailDevStatus_ccmVMailDevInetAddressType_ccmVMailDevInetAddress_ccmVMailDevStatusReason_ccmVMailDevTimeLastStatusUpdt_ccmVMailDevTimeLastRegistered',
      'oid_last' => 'CISCO-CCM-MIB::ccmVoiceMailDeviceTable',

      'name' => 'DISPOSITIVOS DE BUZON DE VOZ DEFINIDOS',
      'descr' => 'Muestra informacion relevante sobre los dispositivos de buzon de voz registraods en el Call Manager',
      'xml_file' => '00009_CISCO_CCM_VOICE_MAIL_DEVICES_INFO.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'CISCO-VOIP',
      'aname'=>'app_cisco_ccm_vmail_dev_info',
      'range' => 'CISCO-CCM-MIB::ccmVoiceMailDeviceTable',
      'enterprise' => '00009',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_VOICE_MAIL_DEVICES_INFO.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.CISCO-VOIP',
   },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00009_CISCO_CCM::METRICS=(

	{  'name'=> 'TELEFONOS REGISTRADOS',   'oid'=>'CISCO-CCM-MIB::ccmRegisteredPhones.0|CISCO-CCM-MIB::ccmUnregisteredPhones.0|CISCO-CCM-MIB::ccmRejectedPhones.0', 'subtype'=>'ciscocm_reg_phones', 'class'=>'CISCO-VOIP', 'itil_type' => 1, 'apptype'=>'NET.CISCO-VOIP' },
	{  'name'=> 'GATEWAYS REGISTRADOS',   'oid'=>'CISCO-CCM-MIB::ccmRegisteredGateways.0|CISCO-CCM-MIB::ccmUnregisteredGateways.0|CISCO-CCM-MIB::ccmRejectedGateways.0', 'subtype'=>'ciscocm_reg_gws', 'class'=>'CISCO-VOIP', 'itil_type' => 1, 'apptype'=>'NET.CISCO-VOIP' },
	{  'name'=> 'DISPOSITIVOS REGISTRADOS',   'oid'=>'CISCO-CCM-MIB::ccmRegisteredMediaDevices.0|CISCO-CCM-MIB::ccmUnregisteredMediaDevices.0|CISCO-CCM-MIB::ccmRejectedMediaDevices.0', 'subtype'=>'ciscocm_reg_mdev', 'class'=>'CISCO-VOIP', 'itil_type' => 1, 'apptype'=>'NET.CISCO-VOIP' },
	{  'name'=> 'DISPOSITIVOS CTI REGISTRADOS',   'oid'=>'CISCO-CCM-MIB::ccmRegisteredCTIDevices.0|CISCO-CCM-MIB::ccmUnregisteredCTIDevices.0|CISCO-CCM-MIB::ccmRejectedCTIDevices.0', 'subtype'=>'ciscocm_reg_ctis', 'class'=>'CISCO-VOIP', 'itil_type' => 1, 'apptype'=>'NET.CISCO-VOIP' },
	{  'name'=> 'DISPOSITIVOS VOICE MAIL REGISTRADOS',   'oid'=>'CISCO-CCM-MIB::ccmRegisteredVoiceMailDevices.0|CISCO-CCM-MIB::ccmUnregisteredVoiceMailDevices.0|CISCO-CCM-MIB::ccmRejectedVoiceMailDevices.0', 'subtype'=>'ciscocm_reg_vmail', 'class'=>'CISCO-VOIP', 'itil_type' => 1, 'apptype'=>'NET.CISCO-VOIP' },
#	{  'name'=> 'USO DE CPU (%)',   'oid'=>'', 'subtype'=>'cpq_cpu_status', 'class'=>'COMPAQ' },
	#{  'name'=> 'FALLOS EN DNS',   'oid'=>'ASYNCOS-MAIL-MIB::outstandingDNSRequests.0|ASYNCOS-MAIL-MIB::pendingDNSRequests.0', 'subtype'=>'ironport_dns_failures', 'class'=>'IRONPORT' },
	#{	'name'=> 'MEMORIA ASIGNADA',	'oid'=>'WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0|WINDOWS-NT-PERFORMANCE::memoryCommitLimit.0', 'subtype'=>'winnt_memory_committed_bytes', 'class'=>'WINDOWS-NT'},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid NO DEBE IR CUALIFICADO !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00009_CISCO_CCM::METRICS_TAB=(

#	{	'name'=> 'ALERTAS POR PROTOCOLO',  'oid'=>'protocolAlertCount', 'subtype'=>'tip_alerts_proto', 'class'=>'TIPPING-POINT', 'range'=>'TPT-POLICY::alertsByProtocolTable', 'get_iid'=>'TPT-POLICY::alertProtocol' },

#	{	'name'=> 'FALLOS AL ACTUALIZAR',  'oid'=>'updateFailures', 'subtype'=>'ironport_update_fail', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
#	{	'name'=> 'TASA DE ACTUALIZACIONES',  'oid'=>'updates', 'subtype'=>'ironport_update_rate', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
# 	{	'name'=> '',  'oid'=>'', 'subtype'=>'ironport_temperature', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::', 'get_iid'=>'ASYNCOS-MAIL-MIB::' },

);

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00009_CISCO_CCM::REMOTE_ALERTS=(


#00009-cisco-CISCO-CCM-MIB.my
#ccmCallManagerFailed NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'CISCO-CCM-MIB::ccmCallManagerFailed', 'class'=>'CISCO',
      'descr'=>'FALLO EN CALL MANAGER', 'severity'=>'2', 'enterprise'=>'ent.9.156',
      'vardata' =>'ccmAlarmSeverity;ccmFailCauseCode',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'ccmFailCauseCode', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.CISCO-VOIP', 'itil_type'=>'1'  },

#	   ccmAlarmSeverity               1.3.6.1.4.1.9.9.156.1.10.1     INTEGER                        
#		{
#		   emergency(1)
#		   alert(2)
#		   critical(3)
#		   error(4)
#		   warning(5)
#		   notice(6)
#		   informational(7)
#		}
#	   ccmFailCauseCode               1.3.6.1.4.1.9.9.156.1.10.2     INTEGER                        
#		{
#		   unknown(1)
#		   heartBeatStopped(2)
#		   routerThreadDied(3)
#		   timerThreadDied(4)
#		   criticalThreadDied(5)
#		   deviceMgrInitFailed(6)
#		   digitAnalysisInitFailed(7)
#		   callControlInitFailed(8)
#		   linkMgrInitFailed(9)
#		   dbMgrInitFailed(10)
#		   msgTranslatorInitFailed(11)
#		   suppServicesInitFailed(12)
#		}
#	}

#ccmPhoneFailed NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'CISCO-CCM-MIB::ccmPhoneFailed', 'class'=>'CISCO',
      'descr'=>'FALLO EN TELEFONO', 'severity'=>'2', 'enterprise'=>'ent.9.156',
      'vardata' =>'ccmAlarmSeverity;ccmPhoneFailures',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'ccmPhoneFailures', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.CISCO-VOIP', 'itil_type'=>'1'  },

#ccmPhoneStatusUpdate NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'CISCO-CCM-MIB::ccmPhoneStatusUpdate', 'class'=>'CISCO',
      'descr'=>'ACTUALIZACION DE TELEFONO', 'severity'=>'2', 'enterprise'=>'ent.9.156',
      'vardata' =>'ccmAlarmSeverity;ccmPhoneUpdates',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'ccmPhoneUpdates', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.CISCO-VOIP', 'itil_type'=>'1'  },

#ccmGatewayFailed NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'CISCO-CCM-MIB::ccmGatewayFailed', 'class'=>'CISCO',
      'descr'=>'FALLO DE GATEWAY', 'severity'=>'2', 'enterprise'=>'ent.9.156',
      'vardata' =>'ccmAlarmSeverity;ccmGatewayName;ccmGatewayInetAddressType;ccmGatewayInetAddress;ccmGatewayFailCauseCode',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'ccmGatewayName', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'ccmGatewayInetAddressType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v4', 'descr'=>'ccmGatewayInetAddress', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v5', 'descr'=>'ccmGatewayFailCauseCode', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.CISCO-VOIP', 'itil_type'=>'1'  },

#ccmMediaResourceListExhausted NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'CISCO-CCM-MIB::ccmMediaResourceListExhausted', 'class'=>'CISCO',
      'descr'=>'AGOTADA LISTA DE RECURSOS', 'severity'=>'2', 'enterprise'=>'ent.9.156',
      'vardata' =>'ccmAlarmSeverity;ccmMediaResourceType;ccmMediaResourceListName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'ccmMediaResourceType', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v3', 'descr'=>'ccmMediaResourceListName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.CISCO-VOIP', 'itil_type'=>'1'  },

#ccmRouteListExhausted NOTIFICATION-TYPE
   {  'type'=>'snmp', 'subtype'=>'CISCO-CCM-MIB::ccmRouteListExhausted', 'class'=>'CISCO',
      'descr'=>'AGOTADA LISTA DE RUTAS DE TELEFONIA', 'severity'=>'2', 'enterprise'=>'ent.9.156',
      'vardata' =>'ccmAlarmSeverity;ccmRouteListName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'ccmRouteListName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.CISCO-VOIP', 'itil_type'=>'1'  },

#ccmGatewayLayer2Change NOTIFICATION-TYPE
  {  'type'=>'snmp', 'subtype'=>'CISCO-CCM-MIB::ccmGatewayLayer2Change', 'class'=>'CISCO',
      'descr'=>'CAMBIO EN NIVEL 2', 'severity'=>'2', 'enterprise'=>'ent.9.156',
      'vardata' =>'ccmAlarmSeverity;ccmRouteListName',
      'remote2expr'=>[ {'v'=>'v1', 'descr'=>'ccmAlarmSeverity', 'fx'=>'MATCH', 'expr'=>''},
                       {'v'=>'v2', 'descr'=>'ccmRouteListName', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'NEW', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.CISCO-VOIP', 'itil_type'=>'1'  },

#ccmNotificationsGroup NOTIFICATION-GROUP

#00009-cisco-CISCO-CCME-MIB.my
#ccmeStatusChangeNotif NOTIFICATION-TYPE
#ccmeEphoneUnRegThresholdExceed NOTIFICATION-TYPE
#ccmeEPhoneDeceased NOTIFICATION-TYPE
#ccmeEPhoneRegFailed NOTIFICATION-TYPE
#ccmeEphoneLoginFailed NOTIFICATION-TYPE
#ccmeNightServiceChangeNotif NOTIFICATION-TYPE
#ccmeLivefeedMohFailedNotif NOTIFICATION-TYPE
#ccmeMaxConferenceNotif NOTIFICATION-TYPE
#ccmeKeyEphoneRegChangeNotif NOTIFICATION-TYPE
#ccmeNotifGroup NOTIFICATION-GROUP


);


1;
__END__
