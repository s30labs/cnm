<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_stp_top_change',
		'descr' => 'CAMBIOS DE TOPOLOGIA SPANNING TREE',
		'items' => 'dot1dStpTopChanges.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'stp_port_status',
		'descr' => 'ESTADO STP DEL PUERTO',
		'items' => 'forwarding(5)|disabled(1)|blocking(2)|broken(6)|listening(3)|learning(4)',
	);

?>
