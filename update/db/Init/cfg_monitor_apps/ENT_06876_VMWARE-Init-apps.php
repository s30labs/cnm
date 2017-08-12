<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'VMWARE', 'itil_type'=>'1',  'name'=>'MAQUINAS VIRTUALES CONFIGURADAS EN EL SISTEMA',
         'descr' => 'Muestra las maquinas virtuales configuradas en el sistema',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 06876-VMWARE-VMINFO-MIB.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'VMWARE-VMINFO-MIB::vmTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'06876',
			'custom' => '0', 'aname'=>'app_vmware_vminfo_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'VIRTUAL.VMWARE', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'VMWARE', 'itil_type'=>'1',  'name'=>'INFORMACION BASICA VMWARE',
         'descr' => 'Muestra informacion basica sobre el equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 06876-VMWARE-get-info.xml -w xml  ',
         'params' => '[-n;IP;]',        'iptab'=>'1',	'ready'=>1,
         'myrange' => 'VMWARE-SYSTEM-MIB::vmwProdName.0',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'06876',
         'custom' => '0', 'aname'=>'app_vmware_get_info', 'res'=>1, 'ipparam'=>'[-n;IP;]', 'apptype'=>'VIRTUAL.VMWARE',
      );


?>
