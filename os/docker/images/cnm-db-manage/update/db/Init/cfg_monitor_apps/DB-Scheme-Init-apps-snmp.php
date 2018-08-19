<?php

//OJO con el campo script

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'MIB2', 'itil_type'=>'1',  'name'=>'LISTA DE INTERFACES',
         'descr' => 'Obtiene la lista de interfaces del dispositivo utilizando los datos de ifTable e ifXTable',
         'cmd' => '/opt/crawler/bin/libexec/mib2_if -w json  ',  'params' => '[-n;IP;]',    'iptab'=>'1', 'ready'=>1,
         'myrange' => 'RFC1213-MIB::ifTable', 'apptype' => 'NET.BASE',
         'cfg' => '0',  'platform' => '*',   'script' => 'mib2_if',   'format'=>1,   'enterprise'=>'0',
         'custom' => '0', 'aname'=>'app_mib2_listinterfaces', 'res'=>1, 'ipparam'=>'[-n;IP;]',
      );


      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'MIB2-HOST', 'itil_type'=>'1',  'name'=>'USO DE DISCO(%)',
         'descr' => 'Muestra el porcentaje de uso de disco y las particiones definidas',
         'cmd' => '/opt/crawler/bin/libexec/mibhost_disk -w json  ',  'params' => '[-n;IP;]',    'iptab'=>'1',	'ready'=>1,
         'myrange' => 'HOST-RESOURCES-MIB::hrStorageTable',	'apptype' => 'SO.MIBHOST',
         'cfg' => '0',  'platform' => '*',   'script' => 'mibhost_disk',   'format'=>1,   'enterprise'=>'0',
         'custom' => '0', 'aname'=>'app_mibhost_diskp', 'res'=>1, 'ipparam'=>'[-n;IP;]',
      );


      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'REGISTRO DE VECINOS POR CDP',
         'descr' => 'Obtiene y registra los vecinos por CDP (Cisco Discovery Protocol).',
         'cmd' => '/opt/crawler/bin/libexec/get_cdp -w json  ', 	'params' => '[-n;IP;]',	'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-CDP-MIB::cdpCacheTable', 'apptype' => 'NET.BASE',
         'cfg' => '0',  'platform' => '*',   'script' => 'get_cdp',   'format'=>1,   'enterprise'=>'9',
			'custom' => '0', 'aname'=>'app_cisco_cdptable', 'res'=>1, 'ipparam'=>'[-n;IP;]',
      );


      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO-VOIP', 'itil_type'=>'1',  'name'=>'DEVICE POOLS DEFINIDOS',
         'descr' => 'Muestra los device pools definids junto con la informacion de region, zona horaria y grupo.',
         'cmd' => '/opt/crawler/bin/libexec/cisco_ccm_device_pools -w json  ', 	'params' => '[-n;IP;]',	'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-CCM-MIB::ccmDevicePoolTable', 'apptype' => 'NET.CISCO',
         'cfg' => '0',  'platform' => '*',   'script' => 'cisco_ccm_device_pools',   'format'=>1,   'enterprise'=>'9',
			'custom' => '0', 'aname'=>'app_cisco_ccm_dev_pool', 'res'=>1, 'ipparam'=>'[-n;IP;]',
      );


?>
