<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'IRONPORT', 'itil_type'=>'1',  'name'=>'CADUCIDAD DE LICENCIAS IRONPORT',
         'descr' => 'Muestra la caducidad de las licencias de los diferentes componentes del Ironport',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 15497-IRONPORT-KEYS.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'ASYNCOS-MAIL-MIB::keyExpirationTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'15497',
			'custom' => '0', 'aname'=>'app_ironport_keys', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.IRONPORT', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'IRONPORT', 'itil_type'=>'1',  'name'=>'IRONPORT - ACTUALIZACION DE SOTWARE',
         'descr' => 'Muestra info sobre la actualizacion de los diferentes servicios del appliance',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 15497-IRONPORT-UPDATES.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'ASYNCOS-MAIL-MIB::updateTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'15497',
			'custom' => '0', 'aname'=>'app_ironport_updates', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.IRONPORT', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'IRONPORT', 'itil_type'=>'1',  'name'=>'IRONPORT - RENDIMIENTO',
         'descr' => 'Muestra informacion basica sobre diferentes parametros de rendimiento del equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 15497_IRONPORT-performance.xml -w xml  ',
         'params' => '[-n;IP;]',        'iptab'=>'1',	'ready'=>1,
         'myrange' => 'ASYNCOS-MAIL-MIB::perCentCPUUtilization.0',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'15497',
         'custom' => '0', 'aname'=>'app_ironport_performance', 'res'=>1, 'ipparam'=>'[-n;IP;]', 'apptype'=>'NET.IRONPORT',
      );


?>
