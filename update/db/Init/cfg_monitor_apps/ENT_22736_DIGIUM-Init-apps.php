<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'ASTERISK', 'itil_type'=>'1',  'name'=>'TIPOS DE CANALES',
         'descr' => 'Muestra informacion sobre los diferentes tipos de canales soportados',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 22736-ASTERISK-CHANNEL-TYPES.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'ASTERISK-MIB::astChanTypeTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'22736',
			'custom' => '0', 'aname'=>'app_asterisk_chan_type', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.ASTERISK', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'ASTERISK', 'itil_type'=>'1',  'name'=>'INFORMACION DEL EQUIPO',
         'descr' => 'Muestra informacion basica sobre el equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 22736_ASTERISK-get_info.xml -w xml  ',
         'params' => '[-n;IP;]',        'iptab'=>'1',	'ready'=>1,
         'myrange' => 'ASTERISK-MIB::astVersionString.0',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'22736',
         'custom' => '0', 'aname'=>'app_asterisk_get_info', 'res'=>1, 'ipparam'=>'[-n;IP;]', 'apptype'=>'NET.ASTERISK',
      );


?>
