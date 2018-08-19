<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'POWER-ETHERNET-MIB', 'itil_type'=>'1',  'name'=>'FUENTES DE POTENCIA',
         'descr' => 'Muestra el consumo de las fuentes de potencia del equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-105-POE_PSE_POWER.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'POWER-ETHERNET-MIB::pethMainPseTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00000',
			'custom' => '0', 'aname'=>'app_poe_psu_usage', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.MIB2', 
      );


?>
