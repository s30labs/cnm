<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'MIB2-OSPF', 'itil_type'=>'1',  'name'=>'OSPF - TABLA DE AREAS',
         'descr' => 'Muestra la tabla de areas OSPF del equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-OSPF-MIB_AREAS_TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'OSPF-MIB::ospfAreaTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00000',
			'custom' => '0', 'aname'=>'app_mib2_ospf_areas_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.OSPF-MIB', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'MIB2-OSPF', 'itil_type'=>'1',  'name'=>'OSPF - TABLA DE INTERFACES',
         'descr' => 'Muestra la tabla de interfaces de desde el punto de vista del protocolo OSPF',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-OSPF-MIB_INTERFACES_TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'OSPF-MIB::ospfIfTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00000',
			'custom' => '0', 'aname'=>'app_mib2_ospf_interfaces_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.OSPF-MIB', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'MIB2-OSPF', 'itil_type'=>'1',  'name'=>'OSPF - TABLA DE VECINOS',
         'descr' => 'Muestra la tabla de vecinos del equipo desde el punto de vista del protocolo OSPF',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-OSPF-MIB_NEIGHBOURS_TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'OSPF-MIB::ospfNbrTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00000',
			'custom' => '0', 'aname'=>'app_mib2_ospf_neighbourss_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.OSPF-MIB', 
      );


?>
