<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'INFOBLOX', 'itil_type'=>'1',  'name'=>'INFORMACION DEL EQUIPO',
         'descr' => 'Muestra informacion basica sobre el equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 07779_INFOBLOX-get_info.xml -w xml  ',
         'params' => '[-n;IP;]',        'iptab'=>'1',	'ready'=>1,
         'myrange' => 'IB-PLATFORMONE-MIB::ibHardwareType.0',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'07779',
         'custom' => '0', 'aname'=>'app_infoblox_get_info', 'res'=>1, 'ipparam'=>'[-n;IP;]', 'apptype'=>'NET.INFOBLOX',
      );


?>
