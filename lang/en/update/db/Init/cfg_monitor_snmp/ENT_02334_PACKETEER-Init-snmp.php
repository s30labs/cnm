<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_bytes',
		'descr' => 'LINK ACTIVITY IN BYTES',
		'items' => 'linkByteCount',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_pkts',
		'descr' => 'LINK ACTIVITY IN PACKETS',
		'items' => 'linkPkts|linkDataPkts',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_ret_bytes',
		'descr' => 'LINK TCP RETRANSMISSIONS IN BYTES',
		'items' => 'linkReTxByteCount',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_ret_pkts',
		'descr' => 'LINK TCP RETRANSMISSIONS IN PACKETS',
		'items' => 'linkReTxs|linkReTxTosses',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_tcp_peak',
		'descr' => 'LINK PEAK TCP CONNECTIONS',
		'items' => 'linkPeakTcpConns',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_tcp',
		'descr' => 'LINK TCP CONNECTIONS',
		'items' => 'linkTcpConnInits|linkTcpConnRefuses|linkTcpConnIgnores|linkTcpConnAborts',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_pkts_tot',
		'descr' => 'LINK PACKETS ACTIVITY',
		'items' => 'linkTotalRxPkts|linkTotalTxPkts',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_pkts_drop',
		'descr' => 'LINK LOST PACKETS',
		'items' => 'linkRxPktDrops|linkTxPktDrops',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_pkts_err',
		'descr' => 'LINK ERRORS',
		'items' => 'linkRxErrors|linkTxErrors',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_bytes',
		'descr' => 'CLASS ACTIVITY IN BYTES',
		'items' => 'classByteCount',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_pkts',
		'descr' => 'CLASS ACTIVITY IN PACKETS',
		'items' => 'classPkts|classDataPkts',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_ret_bytes',
		'descr' => 'CLASS TCP RETRANSMISSIONS IN BYTES',
		'items' => 'classReTxByteCount',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_ret_pkts',
		'descr' => 'CLASS TCP RETRANSMISSIONS IN PACKETS',
		'items' => 'classReTxs|classReTxTosses',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_tcp',
		'descr' => 'CLASS TCP CONNECTIONS',
		'items' => 'classTcpConnInits|classTcpConnRefuses|classTcpConnIgnores|classTcpConnAborts',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_rate',
		'descr' => 'CLASS RATE',
		'items' => 'classCurrentRate',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_exchtime',
		'descr' => 'CLASS PACKET EXCHANGE TIME',
		'items' => 'classPktExchangeTime',
	);

?>
