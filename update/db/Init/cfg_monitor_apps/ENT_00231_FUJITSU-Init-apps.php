<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'RAID-SERVERVIEW', 'itil_type'=>'1',  'name'=>'RAID - DISPOSITIVOS FISICOS',
         'descr' => 'Muestra las 10 vulnerabilidades con mayor numero de ocurrencias',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00231-RAID_SERVERVIEW-PHYS-DEV.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'FSC-RAID-MIB::svrPhysicalDeviceTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00231',
			'custom' => '0', 'aname'=>'app_raid_sview_phys_dev', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'', 
      );


?>
