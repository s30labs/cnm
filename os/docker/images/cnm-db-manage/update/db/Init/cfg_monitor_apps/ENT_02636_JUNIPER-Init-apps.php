<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'JUNIPER', 'itil_type'=>'1',  'name'=>'INFORMACION SOBRE EL CHASIS',
         'descr' => 'Muestra informacion sobre los elementos que componen el chasis del equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 02636-JUNIPER-CHASSIS-INFO.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'JUNIPER-MIB::jnxContainersTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'02636',
			'custom' => '0', 'aname'=>'app_jun_chassis_info', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.JUNIPER', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'JUNIPER', 'itil_type'=>'1',  'name'=>'TABLA DE VLANs',
         'descr' => 'Muestra informacion sobre las VLANs definidas en el equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 02636-JUNIPER-VLAN-TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'JUNIPER-VLAN-MIB::jnxExVlanTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'02636',
			'custom' => '0', 'aname'=>'app_jun_vlan_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.JUNIPER', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'JUNIPER', 'itil_type'=>'1',  'name'=>'INFORMACION DEL EQUIPO',
         'descr' => 'Muestra informacion basica sobre el equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 02636_JUNIPER-get_info.xml -w xml  ',
         'params' => '[-n;IP;]',        'iptab'=>'1',	'ready'=>1,
         'myrange' => 'JUNIPER-MIB::jnxBoxClass.0',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'02636',
         'custom' => '0', 'aname'=>'app_juniper_get_info', 'res'=>1, 'ipparam'=>'[-n;IP;]', 'apptype'=>'NET.JUNIPER',
      );


?>
