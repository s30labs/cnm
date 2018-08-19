<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'MIB2-BGP', 'itil_type'=>'1',  'name'=>'TABLA DE PEERS BGP',
         'descr' => 'Muestra la tabla de peers BGP.',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-MIB2-BGP4-PEER_TABLE.xml  -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'BGP4-MIB::bgpPeerTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00000',
			'custom' => '0', 'aname'=>'app_mib2_bgppeers', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.BGP-MIB', 
      );


?>
