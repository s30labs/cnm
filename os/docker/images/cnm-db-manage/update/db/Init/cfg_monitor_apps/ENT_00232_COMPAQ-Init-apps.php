<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'COMPAQ', 'itil_type'=>'1',  'name'=>'COMPAQ - CARACTERISTICAS DE LA FUENTE DE ALIMENTACION',
         'descr' => 'Muestra la tabla de caracteristicas de las fuentes de alimentacion del servidor',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00232-COMPAQ-MIB_CPQHLTH_POWER_SUPPLY_TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CPQHLTH-MIB::cpqHeFltTolPowerSupplyTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00232',
			'custom' => '0', 'aname'=>'app_compaq_power_supply_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'HW.HP', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'COMPAQ', 'itil_type'=>'1',  'name'=>'COMPAQ - TABLA DE PROCESOS',
         'descr' => 'Muestra la tabla de procesos del Sistema Operativo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00232-COMPAQ-MIB_CPQOS_PROCESS_TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CPQOS-MIB::cpqOsProcessTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00232',
			'custom' => '0', 'aname'=>'app_compaq_processes_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'HW.HP', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'COMPAQ', 'itil_type'=>'1',  'name'=>'COMPAQ - INFORMACION SOBRE LOS SLOTS PCI',
         'descr' => 'Muestra informacion sobre el uso de los slots PCI definidos en el sistema',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00232-COMPAQ-MIB_CPQSTDEQ_PCI_TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CPQSTDEQ-MIB::cpqSePciSlotTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00232',
			'custom' => '0', 'aname'=>'app_compaq_pci_table', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'HW.HP', 
      );


?>
