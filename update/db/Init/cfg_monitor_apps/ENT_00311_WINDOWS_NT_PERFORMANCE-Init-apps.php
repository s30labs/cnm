<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'WINDOWS-NT', 'itil_type'=>'1',  'name'=>'TABLA DE USO DE CPU',
         'descr' => 'Muestra la tabla de uso de CPU de un Windows NT 4.0',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00311-MICROSOFT-WINDOWS-NT-CPU_TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'WINDOWS-NT-PERFORMANCE::cpuprocessorTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00311',
			'custom' => '0', 'aname'=>'app_winnt_cpu_usage', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'SO.WINDOWS', 
      );


?>
