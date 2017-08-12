<?php

	$CFG_INSIDE_CORRELATION_RULES[] = array(
		'rule_subtype'=>'00000000',
		'rule_expr'=>'[{"orig":"","dest":""}]',
		'rule_name'=>'COMPORTAMIENTO ESTANDAR',
		// 'rule_descr'=>'Si el dispositivo no responde a ping (icmp) no se muestra ninguna alerta de tipo tcp/ip. Si el dispositivo no responde a snmp no se muestra ninguna alerta de tipo snmp',
		'rule_descr'=>'Sin correlación de alertas',
	);

   $CFG_INSIDE_CORRELATION_RULES[] = array(
      'rule_subtype'=>'00000001',
      'rule_expr'=>'[{"orig":{"subtype":["mon_icmp"]},"dest":{"type":["latency"]}}]',
		'rule_name'=>'ICMP CORRELA TCP/IP',
      'rule_descr'=>'Si el dispositivo no responde a ping (icmp) no se muestra ninguna alerta de tipo tcp/ip',
   );

   $CFG_INSIDE_CORRELATION_RULES[] = array(
      'rule_subtype'=>'00000002',
      'rule_expr'=>'[{"orig":{"subtype":["mon_icmp"]},"dest":{"type":["latency","snmp","xagent"]}}]',
		'rule_name'=>'ICMP CORRELA TCP/IP, SNMP y PROXY',
      'rule_descr'=>'Si el dispositivo no responde a ping (icmp) no se muestra ninguna alerta de tipo tcp/ip, snmp o proxy',
   );

   $CFG_INSIDE_CORRELATION_RULES[] = array(
      'rule_subtype'=>'00000003',
      'rule_expr'=>'[{"orig":{"subtype":["mon_icmp"]},"dest":{"type":["latency","snmp","xagent","snmp-trap","syslog","email","api"]}}]',
		'rule_name'=>'ICMP CORRELA TCP/IP, SNMP, PROXY y ALERTA REMOTA',
      'rule_descr'=>'Si el dispositivo no responde a ping (icmp) no se muestra ninguna alerta de tipo tcp/ip, snmp, proxy o alertas remotas',
   );
?>
