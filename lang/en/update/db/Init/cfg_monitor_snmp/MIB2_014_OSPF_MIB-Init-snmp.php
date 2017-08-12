<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mib2_ospfExternLsaCksumSum',
		'descr' => 'OSPF EXTERNAL LSA CHECKSUM',
		'items' => 'ospfExternLsaCksumSum.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ospf_SpfRuns',
		'descr' => 'OSPF SPF RUNS',
		'items' => 'ospfSpfRuns',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ospf_AreaLsaCksumSum',
		'descr' => 'OSPF LSA CHECKSUM',
		'items' => 'ospfAreaLsaCksumSum',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ospf_NbrEvents',
		'descr' => 'OSPF EVENTS',
		'items' => 'ospfNbrEvents',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ospf_NbrState',
		'descr' => 'OSPF STATUS',
		'items' => 'Full(8)|Loading(7)|Down(1)|Attempt(2)|Init(3)|2W(4)|ExchSt(5)|Exch(6)',
	);

?>
