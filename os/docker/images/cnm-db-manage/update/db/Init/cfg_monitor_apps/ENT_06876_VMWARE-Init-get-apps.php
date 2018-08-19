<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'VMWARE', 'itil_type'=>'2',  'name'=>'INFORMACION DEL PRODUCTO',
         'descr' => 'Muestra informacion sobre el producto',
         'cmd' => '/opt/crawler/bin/libexec/mibtable -f 06876-VMWARE-get-info.xml -w xml  ',
         'params' => '[-n;IP;]',		'iptab'=>'1',
         'myrange' => 'VMWARE-VMINFO-MIB::vmTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'06876',
			'custom' => '0', 'aname'=>'app_vmware_get_info', 'res'=>1, 'ipparam'=>'[-n;IP;]',
      );


?>
