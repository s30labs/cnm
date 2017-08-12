<?
	$TIPS[]=array(
		'id_ref' => 'ns_cpu_usage_perc',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>nsResCpuAvg.0|nsResCpuLast1Min.0|nsResCpuLast5Min.0|nsResCpuLast15Min.0</strong> a partir de los siguientes atributos de la mib NETSCREEN-RESOURCE-MIB:<br><br><strong>NETSCREEN-RESOURCE-MIB::nsResCpuAvg.0 (GAUGE):</strong> "Average System CPU utilization in percentage."
<strong>NETSCREEN-RESOURCE-MIB::nsResCpuLast1Min.0 (GAUGE):</strong> "Last one minute CPU utilization in percentage."
<strong>NETSCREEN-RESOURCE-MIB::nsResCpuLast5Min.0 (GAUGE):</strong> "Last five minutes CPU utilization in percentage."
<strong>NETSCREEN-RESOURCE-MIB::nsResCpuLast15Min.0 (GAUGE):</strong> "Last fifteen minutes CPU utilization in percentage."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ns_mem_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>nsResMemAllocate.0|nsResMemLeft.0|nsResMemFrag.0</strong> a partir de los siguientes atributos de la mib NETSCREEN-RESOURCE-MIB:<br><br><strong>NETSCREEN-RESOURCE-MIB::nsResMemAllocate.0 (GAUGE):</strong> "Memory allocated."
<strong>NETSCREEN-RESOURCE-MIB::nsResMemLeft.0 (GAUGE):</strong> "Memory left."
<strong>NETSCREEN-RESOURCE-MIB::nsResMemFrag.0 (GAUGE):</strong> "Memory fragment."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ns_session_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>nsResSessAllocate.0|nsResSessFailed.0|nsResSessMaxium.0</strong> a partir de los siguientes atributos de la mib NETSCREEN-RESOURCE-MIB:<br><br><strong>NETSCREEN-RESOURCE-MIB::nsResSessAllocate.0 (GAUGE):</strong> "Allocate session number."
<strong>NETSCREEN-RESOURCE-MIB::nsResSessFailed.0 (GAUGE):</strong> "Failed session allocation counters."
<strong>NETSCREEN-RESOURCE-MIB::nsResSessMaxium.0 (GAUGE):</strong> "Maxium session number system can afford."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ns_active_users',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>nsUACActiveUsers.0</strong> a partir de los siguientes atributos de la mib NETSCREEN-UAC-MIB:<br><br><strong>NETSCREEN-UAC-MIB::nsUACActiveUsers.0 (GAUGE):</strong> "Active users on this box, base on auth entry from UAC controler"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ns_url_filter_stat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>running(1)|N/A(2)|Down(3)</strong> a partir de los siguientes atributos de la mib NETSCREEN-SET-URL-FILTER-MIB:<br><br><strong>NETSCREEN-SET-URL-FILTER-MIB::nsSetUrlServerStatus.0 (GAUGE):</strong> "Current server status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ns_power_status',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Good(1)|Fail(0)|Not Installed(2)</strong> a partir de los siguientes atributos de la mib NETSCREEN-CHASSIS-MIB:<br><br><strong>NETSCREEN-CHASSIS-MIB::nsPowerStatus (GAUGE):</strong> "A  32-bit  integer uniquely identifying the
            power supply modules status:
            		0. Fail
            		1. Good
 				2. Not installed"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ns_slot_status',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Good(1)|Fail(0)|Not Installed(2)</strong> a partir de los siguientes atributos de la mib NETSCREEN-CHASSIS-MIB:<br><br><strong>NETSCREEN-CHASSIS-MIB::nsSlotStatus (GAUGE):</strong> "Slot status"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ns_tunnel_status',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Up(1)|Unk(2)|Down(0)</strong> a partir de los siguientes atributos de la mib NETSCREEN-VPN-MON-MIB:<br><br><strong>NETSCREEN-VPN-MON-MIB::nsVpnMonTunnelState (GAUGE):</strong> "The current tunnel status determined by the icmp ping  if The
          monitoring status is on."
',
	);

?>
