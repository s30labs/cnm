<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'F5NETWORKS', 'itil_type'=>'1',  'name'=>'INFORMACION SOBRE LOS POOLS DEFINIDOS',
         'descr' => 'Muestra informacion relevante sobre los pools definidos en el equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 03375_F5BIGIP_POOL_INFO.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'F5-BIGIP-LOCAL-MIB::ltmPoolTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'03375',
			'custom' => '0', 'aname'=>'app_f5bigip_pool_info', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.F5NETWORKS', 
      );


?>
