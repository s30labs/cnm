<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'JUNIPER', 'itil_type'=>'1',  'name'=>'INFORMACION DEL EQUIPO',
         'descr' => 'Muestra informacion basica sobre el equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 12532_JUNIPER-get_info.xml -w xml  ',
         'params' => '[-n;IP;]',        'iptab'=>'1',	'ready'=>1,
         'myrange' => 'JUNIPER-IVE-MIB::productName.0',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'12532',
         'custom' => '0', 'aname'=>'app_juniper_get_info', 'res'=>1, 'ipparam'=>'[-n;IP;]', 'apptype'=>'NET.JUNIPER',
      );


?>
