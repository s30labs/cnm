<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'mon_snmp',
		'descr' => 'NO SNMP RESPONSE',
		'items' => '',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'disk_mibhost',
		'descr' => 'DISK USAGE',
		'items' => 'Total Disk|Used Disk',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'disk_mibhostp',
		'descr' => 'DISK USAGE (%)',
		'items' => 'Disk Usage (%)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'proc_cnt_mibhost',
		'descr' => 'PROCESS COUNT',
		'items' => 'Process Count',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'users_cnt_mibhost',
		'descr' => 'USER COUNT',
		'items' => 'User Count',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'esp_cpu_mibhost',
		'descr' => 'CPU USAGE',
		'items' => 'items_fx(cpu)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'esp_cpu_avg_mibhost',
		'descr' => 'AVERAGE CPU USAGE',
		'items' => 'Average CPU',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'traffic_mibii_if',
		'descr' => 'TRAFFIC IN INTERFACE',
		'items' => 'RX Bits|TX Bits',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'traffic_mibii_if_perc',
		'descr' => 'BANDWIDTH USAGE',
		'items' => 'Use Porcentage',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'traffic_mibii_if_hc',
		'descr' => 'TRAFFIC IN INTERFACE (HC)',
		'items' => 'RX Bits|TX Bits',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkts_type_mibii_if',
		'descr' => 'TRAFFIC TYPE IN INTERFACE (UCAST/NUCAST)',
		'items' => 'Ucast PKTS in|NUcast PKTS in|Ucast PKTS out|NUcast PKTS out',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkts_type_mibii_if_ext',
		'descr' => 'TRAFFIC TYPE IN INTERFACE (UCAST/MUCAST/BCAST)',
		'items' => 'Ucast pkts in|MUcast pkts in|Bcast pkts in|Ucast pkts out|Mcast pkts out|Bcast pkts out',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkts_type_mibrmon',
		'descr' => 'TRAFFIC TYPE IN INTERFACE (RMON)',
		'items' => 'Total pkts|Broadcast pkts|Multicast pkts',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ip_pkts_discard',
		'descr' => 'IP PACKETS DISCARDED',
		'items' => 'Pkts in|Pkts out',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tcp_estab',
		'descr' => 'TCP ESTABLISHED SESSIONS',
		'items' => 'TCP sessions',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'tcp_ap',
		'descr' => 'TCP ACTIVE/PASSIVE SESSIONS',
		'items' => 'TCP Active Sessions|TCP Passive Sessions',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'udp_pkts',
		'descr' => 'UDP PACKETS',
		'items' => 'UDP In datagrams|UDP Out datagrams',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'arp_mibii_cnt',
		'descr' => 'LAN NEIGHBORS - ARP',
		'items' => 'ARP entries',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'esp_arp_mibii_cnt',
		'descr' => 'LAN NEIGHBORS - ARP',
		'items' => 'ARP entries',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'pkts_discard_mibii_if',
		'descr' => 'DISCARDED PACKETS IN INTERFACE',
		'items' => 'Discarded Pkts in|Discarded Pkts out',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'errors_mibii_if',
		'descr' => 'ERRORS IN INTERFACE',
		'items' => 'Errors in|Errors out',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'status_mibii_if',
		'descr' => 'INTERFACE STATUS',
		'items' => 'Up|Admin Down|Down|Unk',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'nortel_memory',
		'descr' => 'MEMORY USAGE',
		'items' => 'Free Bytes|Total Bytes',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'nortel_cpu',
		'descr' => 'CPU USAGE',
		'items' => 'CPU usage percentage',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_memory',
		'descr' => 'MEMORY USAGE',
		'items' => 'Used Bytes|Free Bytes',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_cpu',
		'descr' => 'CPU USAGE',
		'items' => 'CPU usage percentage',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_buffer_usage',
		'descr' => 'MEMORY BUFFERS USAGE',
		'items' => 'bufferSmallTotal|bufferMiddleTotal|bufferBigTotal|bufferLargeTotal|bufferHugeTotal',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_buffer_errors',
		'descr' => 'MEMORY BUFFERS ERRORS',
		'items' => 'Buffer Failures|No Free Memory',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_ds0_usage',
		'descr' => 'ISDN BRI OCUPATION',
		'items' => 'DS0s in use|Total DS0s',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_ds0_errors',
		'descr' => 'ISDN BRI ERRORS',
		'items' => 'RDSI rejects|No RDSI resources',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_modem_usage',
		'descr' => 'ANALOGIC MODEM OCUPATION',
		'items' => 'Busy modems|Free modems',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_modem_errors',
		'descr' => 'ANALOGIC MODEM ERRORS',
		'items' => 'Modem rejects|No modem resources',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'cisco_wap_users',
		'descr' => 'ACCESS POINT ACTIVE USERS',
		'items' => 'Users',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'enterasys_cpu_usage',
		'descr' => 'CPU USAGE',
		'items' => 'CPU Usage',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'enterasys_flow3',
		'descr' => 'LEVEL 3 FLOWS',
		'items' => 'Learned level 3 flows|Expired level 3 flows',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'enterasys_flow2',
		'descr' => 'LEVEL 2 FLOWS',
		'items' => 'Learned level 2 flows|Expired level 2 flows',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'brocade_frames_port',
		'descr' => 'TRAFFIC IN FIBER-CHANNEL PORT',
		'items' => 'Tx Frames|Rx Frames',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'brocade_status_port',
		'descr' => 'FIBER-CHANNEL PORT STATUS',
		'items' => 'Up|Down|Unk',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'novell_nw_fs_read_write',
		'descr' => 'FILE SYSTEM ACTIVITY',
		'items' => 'Number of reads|Number of writes',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'novell_nw_fs_cache',
		'descr' => 'CACHE USAGE',
		'items' => 'Cache Checks|Cache Hits',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'novell_nw_open_files',
		'descr' => 'FILES IN USE',
		'items' => 'Number of open files',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'novell_nw_disk_usage',
		'descr' => 'DISK USAGE',
		'items' => 'Total disk|Free disk|Freeable disk',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'novell_nw_disk_dir',
		'descr' => 'DIRECTORY USAGE',
		'items' => 'Total directories|Used directories',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'checkpoint_numconex',
		'descr' => 'NUMBER OF CONNECTIONS',
		'items' => 'fwNumConn',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'checkpoint_peakconex',
		'descr' => 'MAXIMUM PEAK OF CONNECTIONS',
		'items' => 'fwPeakNumConn',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucdavis_interrupts',
		'descr' => 'INTERRUPT USAGE',
		'items' => 'Interrupts|Context switches',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'ucdavis_cpu',
		'descr' => 'CPU USAGE',
		'items' => 'User|System|Idle',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_files_sent',
		'descr' => 'NUMBER OF SENT FILES',
		'items' => 'Number of files',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_current_users',
		'descr' => 'CURRENT CONNECTED USERS',
		'items' => 'Anonymous|Non Anonymous',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_total_users',
		'descr' => 'TOTAL CONNECTED USERS',
		'items' => 'Anonymous|Non Anonymous',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_max_users',
		'descr' => 'MAXIMUM NUMBER OF CONNECTED USERS',
		'items' => 'Anonymous|Non Anonymous',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_current_connections',
		'descr' => 'NUMBER OF CONNECTIONS',
		'items' => 'Connex',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_connections',
		'descr' => 'CONNECTION ATTEMPTS',
		'items' => 'connectionAttempts|logonAttempts',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_request_type1',
		'descr' => 'GET/POST/HEAD/Oher REQUESTS',
		'items' => 'totalGets|totalPosts|totalHeads|totalOthers',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_request_type2',
		'descr' => 'CGI/BGI REQUESTS',
		'items' => 'totalCGIRequests.0|totalBGIRequests.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'httpserver_error_notfound',
		'descr' => 'PAGE NOT FOUND - ERROR 404',
		'items' => 'totalNotFoundErrors.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'squid_cache_memory',
		'descr' => 'CACHE MEMORY USAGE',
		'items' => 'Kb',
	);

?>
