<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_bytes',
		'descr' => 'ACTIVIDAD (BYTES) EN EL LINK',
		'items' => 'linkByteCount',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_pkts',
		'descr' => 'ACTIVIDAD (PAQUETES POR TIPO) EN EL LINK',
		'items' => 'linkPkts|linkDataPkts',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_ret_bytes',
		'descr' => 'RETRANSMISIONES (BYTES) TCP EN EL LINK',
		'items' => 'linkReTxByteCount',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_ret_pkts',
		'descr' => 'RETRANSMISIONES (PAQUETES) TCP EN EL LINK',
		'items' => 'linkReTxs|linkReTxTosses',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_tcp_peak',
		'descr' => 'CONEXIONES TCP MAXIMAS EN EL LINK',
		'items' => 'linkPeakTcpConns',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_tcp',
		'descr' => 'CONEXIONES TCP EN EL LINK',
		'items' => 'linkTcpConnInits|linkTcpConnRefuses|linkTcpConnIgnores|linkTcpConnAborts',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_pkts_tot',
		'descr' => 'ACTIVIDAD (PAQUETES TOTALES) EN EL LINK',
		'items' => 'linkTotalRxPkts|linkTotalTxPkts',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_pkts_drop',
		'descr' => 'PAQUETES PERDIDOS EN EL LINK',
		'items' => 'linkRxPktDrops|linkTxPktDrops',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_link_pkts_err',
		'descr' => 'ERRORES EN EL LINK',
		'items' => 'linkRxErrors|linkTxErrors',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_bytes',
		'descr' => 'ACTIVIDAD (BYTES) EN LA CLASE',
		'items' => 'classByteCount',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_pkts',
		'descr' => 'ACTIVIDAD (PAQUETES) EN LA CLASE',
		'items' => 'classPkts|classDataPkts',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_ret_bytes',
		'descr' => 'RETRANSMISIONES (BYTES) TCP EN LA CLASE',
		'items' => 'classReTxByteCount',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_ret_pkts',
		'descr' => 'RETRANSMISIONES (PAQUETES) TCP EN LA CLASE',
		'items' => 'classReTxs|classReTxTosses',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_tcp',
		'descr' => 'CONEXIONES TCP EN LA CLASE',
		'items' => 'classTcpConnInits|classTcpConnRefuses|classTcpConnIgnores|classTcpConnAborts',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_rate',
		'descr' => 'TASA (bps) LA CLASE',
		'items' => 'classCurrentRate',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkteer_class_exchtime',
		'descr' => 'DURACION DE LAS CONEXIONES EN LA CLASE',
		'items' => 'classPktExchangeTime',
	);

?>
