<?
	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'winnt_memory_avail_bytes',
		'descr' => 'MEMORIA DISPONIBLE',
		'items' => 'memoryAvailableBytes.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'winnt_memory_committed_bytes',
		'descr' => 'MEMORIA ASIGNADA',
		'items' => 'memoryCommittedBytes.0|memoryCommitLimit.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'winnt_memory_faults',
		'descr' => 'MEMORIA - ERRORES',
		'items' => 'memoryPageFaultsPerSec.0|memoryTransitionFaultsPerSec.0|memoryDemandZeroFaultsPerSec.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'winnt_memory_page_rw',
		'descr' => 'MEMORIA - PAGINACION',
		'items' => 'memoryPageReadsPerSec.0|memoryPageWritesPerSec.0',
	);

	$CFG_MONITOR_SNMP[]=array(
		'subtype' => 'winnt_ldisk_free_perc',
		'descr' => 'DISCO LIBRE (%)',
		'items' => 'ldiskPercentFreeSpace',
	);

?>
