<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'winnt_memory_avail_bytes',
		'descr' => 'AVAILABLE MEMORY',
		'items' => 'memoryAvailableBytes.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'winnt_memory_committed_bytes',
		'descr' => 'ASSIGNED MEMORY',
		'items' => 'memoryCommittedBytes.0|memoryCommitLimit.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'winnt_memory_faults',
		'descr' => 'MEMORY ERRORS',
		'items' => 'memoryPageFaultsPerSec.0|memoryTransitionFaultsPerSec.0|memoryDemandZeroFaultsPerSec.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'winnt_memory_page_rw',
		'descr' => 'MEMORY PAGINATION',
		'items' => 'memoryPageReadsPerSec.0|memoryPageWritesPerSec.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'winnt_ldisk_free_perc',
		'descr' => 'FREE DISK SPACE (%)',
		'items' => 'ldiskPercentFreeSpace',
	);

?>
