<?
	$TIPS[]=array(
		'id_ref' => 'fortigate_cpu_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fgSysCpuUsage.0</strong> a partir de los siguientes atributos de la mib FORTINET-FORTIGATE-MIB:<br><br><strong>FORTINET-FORTIGATE-MIB::fgSysCpuUsage.0 (GAUGE):</strong> "Current CPU usage (percentage)"
',
	);

	$TIPS[]=array(
		'id_ref' => 'fortigate_mem_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fgSysMemUsage.0</strong> a partir de los siguientes atributos de la mib FORTINET-FORTIGATE-MIB:<br><br><strong>FORTINET-FORTIGATE-MIB::fgSysMemUsage.0 (GAUGE):</strong> "Current memory utilization (percentage)"
',
	);

	$TIPS[]=array(
		'id_ref' => 'fortigate_lowmem_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fgSysLowMemUsage.0</strong> a partir de los siguientes atributos de la mib FORTINET-FORTIGATE-MIB:<br><br><strong>FORTINET-FORTIGATE-MIB::fgSysLowMemUsage.0 (GAUGE):</strong> "Current lowmem utilization (percentage). Lowmem is memory available
          for the kernels own data structures and kernel specific tables. The
          system can get into a bad state if it runs out of lowmem."
',
	);

	$TIPS[]=array(
		'id_ref' => 'fortigate_disk_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>::FORTINET-FORTIGATE-MIB:fgSysDiskUsage.0|fgSysDiskCapacity.0</strong> a partir de los siguientes atributos de la mib FORTINET-FORTIGATE-MIB:<br><br><strong>::::FORTINET-FORTIGATE-MIB:fgSysDiskUsage.0 (GAUGE):</strong> <strong>FORTINET-FORTIGATE-MIB::fgSysDiskCapacity.0 (GAUGE):</strong> "Total hard disk capacity (MB), if disk is present"
',
	);

	$TIPS[]=array(
		'id_ref' => 'fortigate_ses_count',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fgSysSesCount.0</strong> a partir de los siguientes atributos de la mib FORTINET-FORTIGATE-MIB:<br><br><strong>FORTINET-FORTIGATE-MIB::fgSysSesCount.0 (GAUGE):</strong> "Number of active sessions on the device"
',
	);

	$TIPS[]=array(
		'id_ref' => 'fortigate_pol_traffic',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fgFwPolPktCount|fgFwPolByteCount</strong> a partir de los siguientes atributos de la mib FORTINET-FORTIGATE-MIB:<br><br><strong>FORTINET-FORTIGATE-MIB::fgFwPolPktCount (COUNTER):</strong> "Number of packets matched to policy (passed or blocked, depending on policy action). Count is from the time the policy became active."
<strong>FORTINET-FORTIGATE-MIB::fgFwPolByteCount (COUNTER):</strong> "Number of bytes in packets matching the policy. See fgFwPolPktCount."
',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_cpu_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fnHaStatsCpuUsage</strong> a partir de los siguientes atributos de la mib FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsCpuUsage (GAUGE):</strong> "CPU Usage of HA Clusters unit"
',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_memory_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fnHaStatsMemUsage</strong> a partir de los siguientes atributos de la mib FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsMemUsage (GAUGE):</strong> "Memory Usage of HA Clusters unit"
',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_net_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fnHaStatsNetUsage</strong> a partir de los siguientes atributos de la mib FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsNetUsage (GAUGE):</strong> "Network Usage of HA Clusters unit"
',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_active_sessions',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fnHaStatsSesCount</strong> a partir de los siguientes atributos de la mib FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsSesCount (GAUGE):</strong> "Sessions Counter of HA Clusters unit"
',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_packets',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fnHaStatsPktCount</strong> a partir de los siguientes atributos de la mib FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsPktCount (COUNTER):</strong> "Packets Counter of HA Clusters unit"
',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_bytes',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fnHaStatsByteCount</strong> a partir de los siguientes atributos de la mib FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsByteCount (COUNTER):</strong> "Bytes Counter of HA Clusters unit"
',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_attacks',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fnHaStatsIdsCount</strong> a partir de los siguientes atributos de la mib FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsIdsCount (COUNTER):</strong> "IDS Counter of HA Clusters unit"
',
	);

	$TIPS[]=array(
		'id_ref' => 'fortinet_virus',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>fnHaStatsAvCount</strong> a partir de los siguientes atributos de la mib FORTINET-MIB-280:<br><br><strong>FORTINET-MIB-280::fnHaStatsAvCount (COUNTER):</strong> "AV Counter of HA Clusters unit"
',
	);

?>
