<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-AIRONET', 'itil_type'=>'1',  'name'=>'INFO SOBRE LOS INTERFACES DE LOS APS CONECTADOS',
         'descr' => 'Muestra informacion relevante sobre los interfaces de los APs que dependen de este equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 14179-AIRSPACE-APIFINFO-MIB.xml -M 1 -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'AIRESPACE-WIRELESS-MIB::bsnAPIfTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'14179',
			'custom' => '0', 'aname'=>'app_airspace_apifinfo_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-WIRELESS', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-AIRONET', 'itil_type'=>'1',  'name'=>'INFO SOBRE LOS APS CONECTADOS',
         'descr' => 'Muestra informacion relevante sobre los APs que dependen de este equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 14179-AIRSPACE-APINFO-MIB.xml -M 1 -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'AIRESPACE-WIRELESS-MIB::bsnAPTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'14179',
			'custom' => '0', 'aname'=>'app_airspace_apinfo_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-WIRELESS', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-AIRONET', 'itil_type'=>'1',  'name'=>'CARGA DE LOS APS CONECTADOS',
         'descr' => 'Muestra informacion relevante sobre la carga que tienen los APs que dependen de este equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 14179-AIRSPACE-APLOAD-MIB.xml  -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'AIRESPACE-WIRELESS-MIB::bsnAPIfLoadParametersTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'14179',
			'custom' => '0', 'aname'=>'app_airspace_apload_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-WIRELESS', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-AIRONET', 'itil_type'=>'1',  'name'=>'ESTADO DE LOS PERFILES DE LOS APS CONECTADOS',
         'descr' => 'Muestra informacion relevante sobre los perfiles de carga, interferencia, cobertura y ruido de los APs que dependen de este equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 14179-AIRSPACE-APPROFILE-MIB.xml -M 1 -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'AIRESPACE-WIRELESS-MIB::bsnAPIfProfileStateTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'14179',
			'custom' => '0', 'aname'=>'app_airspace_approfiles_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-WIRELESS', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-AIRONET', 'itil_type'=>'1',  'name'=>'INFO SOBRE LAS ESTACIONES MOVILES CONECTADAS',
         'descr' => 'Muestra informacion relevante las estaciones moviles cnectadas a este equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 14179-AIRSPACE-MOBINFO-MIB.xml -M 1 -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'AIRESPACE-WIRELESS-MIB::bsnMobileStationTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'14179',
			'custom' => '0', 'aname'=>'app_airspace_mobinfo_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-WIRELESS', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-AIRONET', 'itil_type'=>'1',  'name'=>'INFO SOBRE LOS ROGUE APS CONECTADOS',
         'descr' => 'Muestra informacion relevante sobre los Rogue APs que dependen de este equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 14179-AIRSPACE-ROGUEINFO-MIB.xml -M 1 -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'AIRESPACE-WIRELESS-MIB::bsnRogueAPTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'14179',
			'custom' => '0', 'aname'=>'app_airspace_rogueinfo_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO-WIRELESS', 
      );


?>
