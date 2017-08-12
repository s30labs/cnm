<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_cache_size',
		'descr' => 'ZFS - ESPACIO DE CACHE',
		'items' => 'zfsARCSizeKB.0|zfsARCMetadataSizeKB.0|zfsARCDataSizeKB.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_cache_hits_Arc',
		'descr' => 'ZFS - ACCESOS A CACHE ARC',
		'items' => 'zfsARCHits.0|zfsARCMisses.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_cache_hits_l2arc',
		'descr' => 'ZFS - ACCESOS A CACHE L2ARC',
		'items' => 'zfsL2ARCHits.0|zfsL2ARCMisses.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_cache_l2arc_rw',
		'descr' => 'ZFS - ACTIVIDAD EN CACHE L2ARC',
		'items' => 'zfsL2ARCReads.0|zfsL2ARCWrites.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_cache_rw',
		'descr' => 'ZFS - LECTURAS/ESCRITURAS',
		'items' => 'zfsReadKB.0|zfsReaddirKB.0|zfsWriteKB.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_disk_usage_vol1',
		'descr' => 'ZFS - USO DE DISCO VOL1',
		'items' => 'zfsFilesystemAvailableMB.1|zfsFilesystemUsedMB.1',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_disk_usage_vol2',
		'descr' => 'ZFS - USO DE DISCO VOL2',
		'items' => 'zfsFilesystemAvailableMB.2|zfsFilesystemUsedMB.2',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_disk_usage_vol3',
		'descr' => 'ZFS - USO DE DISCO VOL3',
		'items' => 'zfsFilesystemAvailableMB.3|zfsFilesystemUsedMB.3',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_disk_usage_vol4',
		'descr' => 'ZFS - USO DE DISCO VOL4',
		'items' => 'zfsFilesystemAvailableMB.4|zfsFilesystemUsedMB.4',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_pool_health_vol1',
		'descr' => 'ZFS - ESTADO DEL POOL VOL1',
		'items' => 'online(1)|unknown(4)|faulted(3)|degraded(2)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_pool_health_vol2',
		'descr' => 'ZFS - ESTADO DEL POOL VOL2',
		'items' => 'online(1)|unknown(4)|faulted(3)|degraded(2)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_pool_health_vol3',
		'descr' => 'ZFS - ESTADO DEL POOL VOL3',
		'items' => 'online(1)|unknown(4)|faulted(3)|degraded(2)',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'zfs_pool_health_vol4',
		'descr' => 'ZFS - ESTADO DEL POOL VOL4',
		'items' => 'online(1)|unknown(4)|faulted(3)|degraded(2)',
	);

?>
