<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'UPS-MIB', 'itil_type'=>'1',  'name'=>'TABLA DE FREC/V/I EN ENTRADA',
         'descr' => 'Muestra la tabla de frecuencia, Voltaje y potencia de entrada',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-33-UPS-INPUT_TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'UPS-MIB::upsInputTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00000',
			'custom' => '0', 'aname'=>'app_ups_input_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.UPS-MIB', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'UPS-MIB', 'itil_type'=>'1',  'name'=>'TABLA DE V/I/POT/CARGA EN SALIDA',
         'descr' => 'Muestra la tabla de Voltaje, corriente, potencia y carga en salida',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-33-UPS-OUTPUT_TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'UPS-MIB::upsOutputTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00000',
			'custom' => '0', 'aname'=>'app_ups_output_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.UPS-MIB', 
      );


?>
