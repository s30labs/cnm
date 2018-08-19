<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-VOIP', 'itil_type'=>'1',  'name'=>'INFORMACION SOBRE EL CLUSTER',
         'descr' => 'Muestra informacion relevante sobre el cluster de Call Managers',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_CLUSTER_INFO.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-CCM-MIB::ccmTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_ccm_cluster_info', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-VOIP', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-VOIP', 'itil_type'=>'1',  'name'=>'DISPOSITIVOS CTI DEFINIDOS',
         'descr' => 'Muestra informacion relevante sobre los dispositivos CTI registrados en el Call Manager',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_CTI_DEVICES_INFO.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-CCM-MIB::ccmCTIDeviceTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_ccm_cti_dev_info', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-VOIP', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-VOIP', 'itil_type'=>'1',  'name'=>'GATEKEEPERS DEFINIDOS',
         'descr' => 'Muestra informacion relevante sobre los Gatekeepers definidos en el Call Manager',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_GATEKEEPER_INFO.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-CCM-MIB::ccmGatekeeperTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_ccm_gatekeeper_info', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-VOIP', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-VOIP', 'itil_type'=>'1',  'name'=>'GATEWAYS DEFINIDOS',
         'descr' => 'Muestra informacion relevante sobre los gateways definidos en el Call Manager',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_GATEWAY_INFO.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-CCM-MIB::ccmGatewayTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_ccm_gateway_info', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-VOIP', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-VOIP', 'itil_type'=>'1',  'name'=>'DISPOSITIVOS H323 DEFINIDOS',
         'descr' => 'Muestra informacion relevante sobre los dispositivos H323 registraods en el Call Manager',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_H323_DEVICES_INFO.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-CCM-MIB::ccmH323DeviceTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_ccm_h323_dev_info', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-VOIP', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-VOIP', 'itil_type'=>'1',  'name'=>'MEDIA DEVICES DEFINIDOS',
         'descr' => 'Muestra informacion relevante sobre los media devices definidos en el Call Manager',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_MEDIA_DEVICES_INFO.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-CCM-MIB::ccmMediaDeviceTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_ccm_media_dev_info', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-VOIP', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-VOIP', 'itil_type'=>'1',  'name'=>'TELEFONOS DEFINIDOS',
         'descr' => 'Muestra informacion relevante sobre los telefonos definidos en el Call Manager',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_PHONE_INFO.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-CCM-MIB::ccmPhoneTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_ccm_phone_info', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-VOIP', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-VOIP', 'itil_type'=>'1',  'name'=>'ZONAS HORARIAS',
         'descr' => 'Muestra informacion relevante sobre las zonas horarias definidas en el Call Manager',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_TIMEZONE_INFO.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-CCM-MIB::ccmTimeZoneTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_ccm_timezone_info', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-VOIP', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-VOIP', 'itil_type'=>'1',  'name'=>'DISPOSITIVOS DE BUZON DE VOZ DEFINIDOS',
         'descr' => 'Muestra informacion relevante sobre los dispositivos de buzon de voz registraods en el Call Manager',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009_CISCO_CCM_VOICE_MAIL_DEVICES_INFO.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-CCM-MIB::ccmVoiceMailDeviceTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_ccm_vmail_dev_info', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-VOIP', 
      );


?>
