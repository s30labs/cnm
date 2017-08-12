<?
	$TIPS[]=array(
		'id_ref' => 'ib_dns_nonaa_lat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ibNetworkMonitorDNSNonAAT5AvgLatency.0</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNetworkMonitorDNSNonAAT5AvgLatency.0 (GAUGE):</strong> "Average Latencies (in microseconds) for incoming DNS
 		 queries during the last 5 minutes where the reply was
 		 non authoritative"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_dns_nonaa_cnt',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ibNetworkMonitorDNSNonAAT5Count.0</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNetworkMonitorDNSNonAAT5Count.0 (GAUGE):</strong> "Number of queries used to calculate the average latencies
 		 during the last 5 minutes where the reply was non
 		 authoritative"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_dns_aa_lat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ibNetworkMonitorDNSAAT5AvgLatency.0</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNetworkMonitorDNSAAT5AvgLatency.0 (GAUGE):</strong> "Average Latencies (in microseconds) for incoming DNS
 		 queries during the last 5 minutes where the reply was
 		 authoritative"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_dns_aa_cnt',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ibNetworkMonitorDNSAAT5Count.0</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNetworkMonitorDNSAAT5Count.0 (GAUGE):</strong> "Number of queries used to calculate the average latencies
 		 during the last 5 minutes where the reply was
 		 authoritative"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_cpu_temperature',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ibCPUTemperature.0</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibCPUTemperature.0 (GAUGE):</strong> "Infoblox One CPU temperature."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_cpu_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ibSystemMonitorCpuUsage.0</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibSystemMonitorCpuUsage.0 (GAUGE):</strong> "Current average CPU usage"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_mem_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ibSystemMonitorMemUsage.0</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibSystemMonitorMemUsage.0 (GAUGE):</strong> "Current Memory usage"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_dns_monitor',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Activo(1)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNetworkMonitorDNSActive.0 (GAUGE):</strong> "Equal to 1 if monitoring is active. No other data is
 		likely to be correct if not active"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_dhcp_disc_req',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ibDhcpTotalNoOfDiscovers.0|ibDhcpTotalNoOfRequests.0</strong> a partir de los siguientes atributos de la mib IB-DHCPONE-MIB:<br><br><strong>IB-DHCPONE-MIB::ibDhcpTotalNoOfDiscovers.0 (COUNTER):</strong> "This variable indicates the number of
 		 discovery messages received"
<strong>IB-DHCPONE-MIB::ibDhcpTotalNoOfRequests.0 (COUNTER):</strong> "This variable indicates the number of
 		 requests received"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_dhcp_rel_off',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ibDhcpTotalNoOfReleases.0|ibDhcpTotalNoOfOffers.0</strong> a partir de los siguientes atributos de la mib IB-DHCPONE-MIB:<br><br><strong>IB-DHCPONE-MIB::ibDhcpTotalNoOfReleases.0 (COUNTER):</strong> "This variable indicates the number of
 		 releases received"
<strong>IB-DHCPONE-MIB::ibDhcpTotalNoOfOffers.0 (COUNTER):</strong> "This variable indicates the number of
 		 offers sent"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_dhcp_ack_nack',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ibDhcpTotalNoOfAcks.0|ibDhcpTotalNoOfNacks.0</strong> a partir de los siguientes atributos de la mib IB-DHCPONE-MIB:<br><br><strong>IB-DHCPONE-MIB::ibDhcpTotalNoOfAcks.0 (COUNTER):</strong> "This variable indicates the number of
 		 acks sent"
<strong>IB-DHCPONE-MIB::ibDhcpTotalNoOfNacks.0 (COUNTER):</strong> "This variable indicates the number of
 		 nacks sent"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_dhcp_other',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ibDhcpTotalNoOfDeclines.0|ibDhcpTotalNoOfInforms.0|ibDhcpTotalNoOfOthers.0</strong> a partir de los siguientes atributos de la mib IB-DHCPONE-MIB:<br><br><strong>IB-DHCPONE-MIB::ibDhcpTotalNoOfDeclines.0 (COUNTER):</strong> "This variable indicates the number of
 		 declines received"
<strong>IB-DHCPONE-MIB::ibDhcpTotalNoOfInforms.0 (COUNTER):</strong> "This variable indicates the number of
 		 informs received"
<strong>IB-DHCPONE-MIB::ibDhcpTotalNoOfOthers.0 (COUNTER):</strong> "This variable indicates the number of
 		 other messages received"
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_dhcp',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibServiceStatus.1 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_dns',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibServiceStatus.2 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_ntp',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibServiceStatus.3 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_radius',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibServiceStatus.4 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_tftp',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibServiceStatus.5 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_httpf',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibServiceStatus.6 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_ftp',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibServiceStatus.7 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_btools_move',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibServiceStatus.8 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_btools',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibServiceStatus.9 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_node',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.10 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_disk',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.11 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_lan1',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.12 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_lan2',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.13 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_lan_ha',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.14 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_lan_mgmt',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.15 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_lcd',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.16 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_mem',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.17 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_repli',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.18 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_dbobj',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.19 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_raid_sum',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.20 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_raid_disk1',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.21 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_raid_disk2',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.22 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_raid_disk3',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.23 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_raid_disk4',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.24 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_fan1',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.25 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_fan2',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.26 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_fan3',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.27 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_power',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.28 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_ntp_sync',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.29 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_cpu1_temp',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.30 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_cpu2_temp',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.31 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_sys_temp',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.32 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_raid_bat',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.33 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_cpu_usage',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.34 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_ospf',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.35 (GAUGE):</strong> "Service Status."
',
	);

	$TIPS[]=array(
		'id_ref' => 'ib_status_bgp',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)</strong> a partir de los siguientes atributos de la mib IB-PLATFORMONE-MIB:<br><br><strong>IB-PLATFORMONE-MIB::ibNode1ServiceStatus.36 (GAUGE):</strong> "Service Status."
',
	);

?>
