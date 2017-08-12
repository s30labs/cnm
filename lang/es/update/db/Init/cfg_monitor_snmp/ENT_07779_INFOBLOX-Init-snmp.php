<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dns_nonaa_lat',
		'descr' => 'LATENCIA DEL DNS (Non-AA)',
		'items' => 'ibNetworkMonitorDNSNonAAT5AvgLatency.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dns_nonaa_cnt',
		'descr' => 'CONSULTAS AL DNS (Non-AA)',
		'items' => 'ibNetworkMonitorDNSNonAAT5Count.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dns_aa_lat',
		'descr' => 'LATENCIA DEL DNS (AA)',
		'items' => 'ibNetworkMonitorDNSAAT5AvgLatency.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dns_aa_cnt',
		'descr' => 'CONSULTAS AL DNS (AA)',
		'items' => 'ibNetworkMonitorDNSAAT5Count.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_cpu_temperature',
		'descr' => 'TEMPERATURA DE LA CPU',
		'items' => 'ibCPUTemperature.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_cpu_usage',
		'descr' => 'USO DE CPU',
		'items' => 'ibSystemMonitorCpuUsage.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_mem_usage',
		'descr' => 'USO DE MEMORIA',
		'items' => 'ibSystemMonitorMemUsage.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dns_monitor',
		'descr' => 'ESTADO DNS MONITOR',
		'items' => 'Activo(1)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dhcp_disc_req',
		'descr' => 'MENSAJES DISCOVER/REQUEST',
		'items' => 'ibDhcpTotalNoOfDiscovers.0|ibDhcpTotalNoOfRequests.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dhcp_rel_off',
		'descr' => 'MENSAJES DE RELEASE/OFFER',
		'items' => 'ibDhcpTotalNoOfReleases.0|ibDhcpTotalNoOfOffers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dhcp_ack_nack',
		'descr' => 'MENSAJES ACK/NACK',
		'items' => 'ibDhcpTotalNoOfAcks.0|ibDhcpTotalNoOfNacks.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_dhcp_other',
		'descr' => 'MENSAJES DECLINE/INFORM/OTHER',
		'items' => 'ibDhcpTotalNoOfDeclines.0|ibDhcpTotalNoOfInforms.0|ibDhcpTotalNoOfOthers.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_dhcp',
		'descr' => 'ESTADO SERVICIO DHCP',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_dns',
		'descr' => 'ESTADO SERVICIO DNS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_ntp',
		'descr' => 'ESTADO SERVICIO NTP',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_radius',
		'descr' => 'ESTADO SERVICIO RADIUS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_tftp',
		'descr' => 'ESTADO SERVICIO TFTP',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_httpf',
		'descr' => 'ESTADO SERVICIO HTTP-FILE-DIST',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_ftp',
		'descr' => 'ESTADO SERVICIO FTP',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_btools_move',
		'descr' => 'ESTADO SERVICIO BLOXTOOLS-MOVE',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_btools',
		'descr' => 'ESTADO SERVICIO BLOXTOOLS',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_node',
		'descr' => 'ESTADO SERVICIO DEL NODO',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_disk',
		'descr' => 'ESTADO SERVICIO DISCO',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_lan1',
		'descr' => 'ESTADO SERVICIO ETH-LAN1',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_lan2',
		'descr' => 'ESTADO SERVICIO ETH-LAN2',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_lan_ha',
		'descr' => 'ESTADO SERVICIO ETH-HA',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_lan_mgmt',
		'descr' => 'ESTADO SERVICIO ETH-MGMT',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_lcd',
		'descr' => 'ESTADO SERVICIO LCD',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_mem',
		'descr' => 'ESTADO SERVICIO MEMORY',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_repli',
		'descr' => 'ESTADO SERVICIO REPLICATION',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_dbobj',
		'descr' => 'ESTADO SERVICIO DB_OBJECT',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_raid_sum',
		'descr' => 'ESTADO SERVICIO RAID-SUMMARY',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_raid_disk1',
		'descr' => 'ESTADO SERVICIO RAID-DISK1',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_raid_disk2',
		'descr' => 'ESTADO SERVICIO RAID-DISK2',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_raid_disk3',
		'descr' => 'ESTADO SERVICIO RAID-DISK3',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_raid_disk4',
		'descr' => 'ESTADO SERVICIO RAID-DISK4',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_fan1',
		'descr' => 'ESTADO SERVICIO FAN1',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_fan2',
		'descr' => 'ESTADO SERVICIO FAN2',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_fan3',
		'descr' => 'ESTADO SERVICIO FAN3',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_power',
		'descr' => 'ESTADO SERVICIO POWER-SUPPLY',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_ntp_sync',
		'descr' => 'ESTADO SERVICIO NTP-SYNC',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_cpu1_temp',
		'descr' => 'ESTADO SERVICIO CPU1-TEMP',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_cpu2_temp',
		'descr' => 'ESTADO SERVICIO CPU2-TEMP',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_sys_temp',
		'descr' => 'ESTADO SERVICIO SYS-TEMP',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_raid_bat',
		'descr' => 'ESTADO SERVICIO RAID-BATTERY',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_cpu_usage',
		'descr' => 'ESTADO SERVICIO CPU-USAGE',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_ospf',
		'descr' => 'ESTADO SERVICIO OSPF',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ib_status_bgp',
		'descr' => 'ESTADO SERVICIO BGP',
		'items' => 'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)',
	);

?>
