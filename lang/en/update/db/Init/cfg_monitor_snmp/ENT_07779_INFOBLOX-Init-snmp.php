<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dns_nonaa_lat',
		'descr' => 'DNS LATENCY (Non-AA)',
		'items' => 'ibNetworkMonitorDNSNonAAT5AvgLatency.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dns_nonaa_cnt',
		'descr' => 'DNS REQUESTS(Non-AA)',
		'items' => 'ibNetworkMonitorDNSNonAAT5Count.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dns_aa_lat',
		'descr' => 'DNS LATENCY (AA)',
		'items' => 'ibNetworkMonitorDNSAAT5AvgLatency.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dns_aa_cnt',
		'descr' => 'DNS REQUESTS (AA)',
		'items' => 'ibNetworkMonitorDNSAAT5Count.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_cpu_temperature',
		'descr' => 'CPU TEMPERATURE',
		'items' => 'ibCPUTemperature.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_cpu_usage',
		'descr' => 'CPU USAGE',
		'items' => 'ibSystemMonitorCpuUsage.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_mem_usage',
		'descr' => 'MEMORY USAGE',
		'items' => 'ibSystemMonitorMemUsage.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dns_monitor',
		'descr' => 'DNS MONITOR STATUS',
		'items' => 'Activo(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dhcp_disc_req',
		'descr' => 'DNS DISCOVER/REQUEST MESSAGES',
		'items' => 'ibDhcpTotalNoOfDiscovers.0|ibDhcpTotalNoOfRequests.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dhcp_rel_off',
		'descr' => 'DNS RELEASE/OFFER MESSAGES',
		'items' => 'ibDhcpTotalNoOfReleases.0|ibDhcpTotalNoOfOffers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dhcp_ack_nack',
		'descr' => 'DNS ACK/NACK MESSAGES',
		'items' => 'ibDhcpTotalNoOfAcks.0|ibDhcpTotalNoOfNacks.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dhcp_other',
		'descr' => 'DNS DECLINE/INFORM/OTHER MESSAGES',
		'items' => 'ibDhcpTotalNoOfDeclines.0|ibDhcpTotalNoOfInforms.0|ibDhcpTotalNoOfOthers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_dhcp',
		'descr' => 'DHCP SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_dns',
		'descr' => 'DNS SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_ntp',
		'descr' => 'NTP SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_radius',
		'descr' => 'RADIUS SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_tftp',
		'descr' => 'TFTP SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_httpf',
		'descr' => 'HTTP-FILE-DIST SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_ftp',
		'descr' => 'FTP SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_btools_move',
		'descr' => 'BLOXTOOLS-MOVE SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_btools',
		'descr' => 'BLOXTOOLS SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_node',
		'descr' => 'NODE SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_disk',
		'descr' => 'DISK SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_lan1',
		'descr' => 'ETH-LAN1 SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_lan2',
		'descr' => 'ETH-LAN2 SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_lan_ha',
		'descr' => 'ETH-HA SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_lan_mgmt',
		'descr' => 'ETH-MGMT SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_lcd',
		'descr' => 'LCD SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_mem',
		'descr' => 'MEMORY SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_repli',
		'descr' => 'REPLICATION SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_dbobj',
		'descr' => 'DB_OBJECT SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_raid_sum',
		'descr' => 'RAID-SUMMARY SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_raid_disk1',
		'descr' => 'RAID-DISK1 SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_raid_disk2',
		'descr' => 'RAID-DISK2 SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_raid_disk3',
		'descr' => 'RAID-DISK3 SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_raid_disk4',
		'descr' => 'RAID-DISK4 SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_fan1',
		'descr' => 'FAN1 SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_fan2',
		'descr' => 'FAN2 SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_fan3',
		'descr' => 'FAN3 SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_power',
		'descr' => 'POWER-SUPPLY SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_ntp_sync',
		'descr' => 'NTP-SYNC SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_cpu1_temp',
		'descr' => 'CPU1-TEMP SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_cpu2_temp',
		'descr' => 'CPU2-TEMP SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_sys_temp',
		'descr' => 'SYS-TEMP SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_raid_bat',
		'descr' => 'RAID-BATTERY SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_cpu_usage',
		'descr' => 'CPU-USAGE SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_ospf',
		'descr' => 'OSPF SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_bgp',
		'descr' => 'BGP SERVICE STATUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

?>
