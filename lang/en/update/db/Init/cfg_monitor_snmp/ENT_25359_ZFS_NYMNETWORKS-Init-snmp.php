<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_cache_size',
		'descr' => 'ZFS - CACHE SPACE',
		'items' => 'zfsARCSizeKB.0|zfsARCMetadataSizeKB.0|zfsARCDataSizeKB.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_cache_hits_Arc',
		'descr' => 'ZFS - ARC CACHE ACCESS',
		'items' => 'zfsARCHits.0|zfsARCMisses.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_cache_hits_l2arc',
		'descr' => 'ZFS - L2ARC CACHE ACCESS',
		'items' => 'zfsL2ARCHits.0|zfsL2ARCMisses.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_cache_l2arc_rw',
		'descr' => 'ZFS - L2ARC CACHE ACTIVITY',
		'items' => 'zfsL2ARCReads.0|zfsL2ARCWrites.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_cache_rw',
		'descr' => 'ZFS - READS/WRITES',
		'items' => 'zfsReadKB.0|zfsReaddirKB.0|zfsWriteKB.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_disk_usage_vol1',
		'descr' => 'ZFS - VOL1 DISK USAGE',
		'items' => 'zfsFilesystemAvailableMB.1|zfsFilesystemUsedMB.1',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_disk_usage_vol2',
		'descr' => 'ZFS - VOL2 DISK USAGE',
		'items' => 'zfsFilesystemAvailableMB.2|zfsFilesystemUsedMB.2',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_disk_usage_vol3',
		'descr' => 'ZFS - VOL3 DISK USAGE',
		'items' => 'zfsFilesystemAvailableMB.3|zfsFilesystemUsedMB.3',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_disk_usage_vol4',
		'descr' => 'ZFS - VOL4 DISK USAGE',
		'items' => 'zfsFilesystemAvailableMB.4|zfsFilesystemUsedMB.4',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_pool_health_vol1',
		'descr' => 'ZFS - VOL1 POOL STATUS',
		'items' => 'online(1)|unknown(4)|faulted(3)|degraded(2)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_pool_health_vol2',
		'descr' => 'ZFS - VOL2 POOL STATUS',
		'items' => 'online(1)|unknown(4)|faulted(3)|degraded(2)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_pool_health_vol3',
		'descr' => 'ZFS - VOL3 POOL STATUS',
		'items' => 'online(1)|unknown(4)|faulted(3)|degraded(2)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_pool_health_vol4',
		'descr' => 'ZFS - VOL4 POOL STATUS',
		'items' => 'online(1)|unknown(4)|faulted(3)|degraded(2)',
	);

?>
