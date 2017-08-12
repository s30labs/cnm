<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'ENTITY-MIB', 'itil_type'=>'1',  'name'=>'TABLA DE COMPONENTES FISICOS',
         'descr' => 'Muestra los componentes fisicos del equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-47-ENTITY_PHYS_TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'ENTITY-MIB::entPhysicalTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00000',
			'custom' => '0', 'aname'=>'app_ent_phys_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.MIB2', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'ENTITY-MIB', 'itil_type'=>'1',  'name'=>'TABLA DE COMPONENTES LOGICOS',
         'descr' => 'Muestra los componentes logicos del equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-47-ENTITY_LOGIC_TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'ENTITY-MIB::entLogicalTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00000',
			'custom' => '0', 'aname'=>'app_ent_logic_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.MIB2', 
      );


?>
