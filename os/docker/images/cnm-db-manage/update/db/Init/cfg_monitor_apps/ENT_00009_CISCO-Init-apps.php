<?php

      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'INFORMACION DEL CHASIS',
         'descr' => 'Muestra Informacion sobre el chasis del dispositivo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-CHASIS.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'OLD-CISCO-CHASSIS-MIB::cardTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_chasisinfo', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'USO DE CPU',
         'descr' => 'Muestra Informacion en detalle sobre el uso de CPU del dispositivo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-CPU.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-PROCESS-MIB::cpmCPUTotalTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_cpuuse', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'TUNELES IPSEC',
         'descr' => 'Muestra Informacion sobre los tuneles IPSEC configurados en el dispositivo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-CRYPTOMAP-TUNNEL.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-IPSEC-MIB::cipsStaticCryptomapTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_cryptotunnels', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'ESTADO DEL EQUIPO - VENTILADORES',
         'descr' => 'Muestra Informacion sobre el estado de los ventiladores del dispositivo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-ENVMON-FAN.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-ENVMON-MIB::ciscoEnvMonFanStatusTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_fan', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'ESTADO DE LAS CONEXIONES DEL FIREWALL',
         'descr' => 'Muestra informacion sobre los valores de estado de las conexiones del firewall interno',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-FIREWALL-CON-STATUS.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-FIREWALL-MIB::cfwConnectionStatTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_fw_con_status', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'ESTADO DEL HARDWARE DEL FIREWALL',
         'descr' => 'Muestra informacion sobre los valores de estado del firewall interno',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-FIREWALL-HW-STATUS.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-FIREWALL-MIB::cfwHardwareStatusTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_fw_hw_status', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'CONTENIDO DE LA MEMORIA FLASH',
         'descr' => 'Muestra Informacion sobre el uso de la memoria Flash del dispositivo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-FLASH.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'OLD-CISCO-FLASH-MIB::lflashFileDirTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_flashuse', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'TUNELES IPSEC',
         'descr' => 'Muestra Informacion sobre los tuneles IPSEC establecidos del dispositivo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-IPSEC-TUNNEL.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-IPSEC-FLOW-MONITOR-MIB::cikeTunnelTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_ipsectunnels', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'USO DE MEMORIA',
         'descr' => 'Muestra Informacion en detalle sobre el uso de memoria del dispositivo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-MEMORY.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-MEMORY-POOL-MIB::ciscoMemoryPoolTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_memoryused', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'ESTADISTICAS DE NAT',
         'descr' => 'Muestra informacion sobre las estadisticas de NAT del dispositivo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-NAT-EXT-STATUS.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-NAT-EXT-MIB::cneAddrTranslationStatsTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_nat_ext_status', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'ESTADO DEL EQUIPO - FUENTES DE ALIMENTACION',
         'descr' => 'Muestra Informacion sobre el estado de las fuentes de alimentacion del dispositivo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-ENVMON-SUPPLY.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_powersupply', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'TABLA DE PROCESOS',
         'descr' => 'Muestra Informacion en detalle sobre los procesos en curso del dispositivo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-PROCESS.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-PROCESS-MIB::cpmProcessTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_processestable', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'ESTADO DEL EQUIPO - TEMPERATURA',
         'descr' => 'Muestra Informacion sobre el estado de las temperaturas del dispositivo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-ENVMON-TEMPERATURE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_temperature', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'TABLA DE VLANs',
         'descr' => 'Muestra Informacion sobre las VLANs definidas en el equipo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-VLAN-TABLE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-VTP-MIB::vtpVlanTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_vlans', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );



      $CFG_MONITOR_APPS[]=array(
         'type' => 'snmp', 'subtype'=>'CISCO', 'itil_type'=>'1',  'name'=>'ESTADO DEL EQUIPO - VOLTAJE',
         'descr' => 'Muestra Informacion sobre el estado de los voltajes del dispositivo',
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00009-CISCO-ENVMON-VOLTAGE.xml -w xml  ',
         'params' => '[-n;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => 'CISCO-ENVMON-MIB::ciscoEnvMonVoltageStatusTable',
         'cfg' => '0',  'platform' => '*',   'script' => 'snmptable',   'format'=>1,   'enterprise'=>'00009',
			'custom' => '0', 'aname'=>'app_cisco_voltage', 'res'=>1, 'ipparam'=>'[-n;IP;]',  'apptype'=>'NET.CISCO', 
      );


?>
