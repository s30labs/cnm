<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'SOCOMECUPS-MIB', 'itil_type'=>'1',  'name'=>'TABLA DE V/I EN ENTRADA',
         'descr' => 'Muestra la tabla de Voltaje y corriente de entrada',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 04555-SOCOMECUPS_INPUT_TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'SOCOMECUPS-MIB::upsInputTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'04555',
			'custom' => '0', 'aname'=>'app_socups_input_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'HW.SOCOMEC', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'SOCOMECUPS-MIB', 'itil_type'=>'1',  'name'=>'TABLA DE V/I/CARGA EN SALIDA',
         'descr' => 'Muestra la tabla de Voltaje, corriente y carga en salida',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 04555-SOCOMECUPS-OUTPUT_TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'SOCOMECUPS-MIB::upsOutputTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'04555',
			'custom' => '0', 'aname'=>'app_socups_output_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'HW.SOCOMEC', 
      );


?>
