<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'TIPPING-POINT', 'itil_type'=>'1',  'name'=>'TABLA DE VULNERABILIDADES - TOP TEN',
         'descr' => 'Muestra las 10 vulnerabilidades con mayor numero de ocurrencias',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 10734-TIPPINGPOINT-MIB_TOP_TEN_HITS.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'TPT-POLICY::topTenHitsByPolicyTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'10734',
			'custom' => '0', 'aname'=>'app_tip_top_ten_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.TIPPINGPOINT', 
      );


?>
