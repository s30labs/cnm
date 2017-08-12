<?
	$TIPS[]=array(
		'id_ref' => 'winnt_memory_avail_bytes',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>memoryAvailableBytes.0</strong> a partir de los siguientes atributos de la mib WINDOWS-NT-PERFORMANCE:<br><br><strong>WINDOWS-NT-PERFORMANCE::memoryAvailableBytes.0 (GAUGE):</strong> "Adjacent MTA Associations is the number of open associations this MTA has to other MTAs."
',
	);

	$TIPS[]=array(
		'id_ref' => 'winnt_memory_committed_bytes',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>memoryCommittedBytes.0|memoryCommitLimit.0</strong> a partir de los siguientes atributos de la mib WINDOWS-NT-PERFORMANCE:<br><br><strong>WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0 (COUNTER):</strong> "Messages/sec is the rate that messages are processed."
<strong>WINDOWS-NT-PERFORMANCE::memoryCommitLimit.0 (COUNTER):</strong> "Message Bytes/sec is the rate that message bytes are processed."
',
	);

	$TIPS[]=array(
		'id_ref' => 'winnt_memory_faults',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>memoryPageFaultsPerSec.0|memoryTransitionFaultsPerSec.0|memoryDemandZeroFaultsPerSec.0</strong> a partir de los siguientes atributos de la mib WINDOWS-NT-PERFORMANCE:<br><br><strong>WINDOWS-NT-PERFORMANCE::memoryPageFaultsPerSec.0 (GAUGE):</strong> "Free Elements is the number of free buffer elements in the MTA pool."
<strong>WINDOWS-NT-PERFORMANCE::memoryTransitionFaultsPerSec.0 (GAUGE):</strong> "Admin Connections is the number of Microsoft Exchange Administrator programs connected to this MTA."
<strong>WINDOWS-NT-PERFORMANCE::memoryDemandZeroFaultsPerSec.0 (GAUGE):</strong> "Work Queue Length is the number of outstanding messages in the Work Queue, which indicates the number of messages not yet processed to completion by the MTA."
',
	);

	$TIPS[]=array(
		'id_ref' => 'winnt_memory_page_rw',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>memoryPageReadsPerSec.0|memoryPageWritesPerSec.0</strong> a partir de los siguientes atributos de la mib WINDOWS-NT-PERFORMANCE:<br><br><strong>WINDOWS-NT-PERFORMANCE::memoryPageReadsPerSec.0 (COUNTER):</strong> "Disk File Deletes/sec is the rate of disk file delete operations."
<strong>WINDOWS-NT-PERFORMANCE::memoryPageWritesPerSec.0 (COUNTER):</strong> "Disk File Opens/sec is the rate of disk file open operations."
',
	);

	$TIPS[]=array(
		'id_ref' => 'winnt_ldisk_free_perc',
		'tip_type' => 'cfg',
		'name' => 'Descripcion',
		'descr' => 'Mide: <strong>ldiskPercentFreeSpace</strong> a partir de los siguientes atributos de la mib WINDOWS-NT-PERFORMANCE:<br><br><strong>WINDOWS-NT-PERFORMANCE::ldiskPercentFreeSpace (GAUGE):</strong> "Percent Free Space is the ratio of the free space available on the logical disk unit to the total usable space provided by the selected logical disk drive"
',
	);

?>
