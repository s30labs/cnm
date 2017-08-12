<?php
      $TIPS[]=array(
         'id_ref' => 'winnt_memory_avail_bytes',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>memoryAvailableBytes.0</strong> a partir de los siguientes atributos de la mib WINDOWS-NT-PERFORMANCE:<br><br><strong>WINDOWS-NT-PERFORMANCE::memoryAvailableBytes.0 (GAUGE):</strong> "Available Bytes displays the size of the virtual memory currently on the Zeroed, Free, and Standby lists.  Zeroed and Free memory is ready for use, with Zeroed memory cleared to zeros.  Standby memory is memory removed from a processs Working Set but still available.  Notice that this is an instantaneous count, not an average over the time interval."
',
      );


      $TIPS[]=array(
         'id_ref' => 'winnt_memory_committed_bytes',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>memoryCommittedBytes.0|memoryCommitLimit.0</strong> a partir de los siguientes atributos de la mib WINDOWS-NT-PERFORMANCE:<br><br><strong>WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0 (GAUGE):</strong> "Committed Bytes displays the size of virtual memory (in bytes) that has been Committed (as opposed to simply reserved).  Committed memory must have backing (i.e., disk) storage available, or must be assured never to need disk storage (because main memory is large enough to hold it.)  Notice that this is an instantaneous count, not an average over the time interval."
<strong>WINDOWS-NT-PERFORMANCE::memoryCommitLimit.0 (GAUGE):</strong> "Commit Limit is the size (in bytes) of virtual memory that can be committed without having to extend the paging file(s).  If the paging file(s) can be extended, this is a soft limit."
',
      );


      $TIPS[]=array(
         'id_ref' => 'winnt_memory_faults',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>memoryPageFaultsPerSec.0|memoryTransitionFaultsPerSec.0|memoryDemandZeroFaultsPerSec.0</strong> a partir de los siguientes atributos de la mib WINDOWS-NT-PERFORMANCE:<br><br><strong>WINDOWS-NT-PERFORMANCE::memoryPageFaultsPerSec.0 (GAUGE):</strong> "Page Faults/sec is a count of the Page Faults in the processor.  A page fault occurs when a process refers to a virtual memory page that is not in its Working Set in main memory.  A Page Fault will not cause the page to be fetched from disk if that page is on the standby list, and hence already in main memory, or if it is in use by another process with whom the page is shared."
<strong>WINDOWS-NT-PERFORMANCE::memoryTransitionFaultsPerSec.0 (GAUGE):</strong> "Transition Faults/sec is the number of page faults resolved by recovering pages that were in transition, i.e., being written to disk at the time of the page fault.  The pages were recovered without additional disk activity."
<strong>WINDOWS-NT-PERFORMANCE::memoryDemandZeroFaultsPerSec.0 (GAUGE):</strong> "Demand Zero Faults are the number of page faults for pages that must be filled with zeros before the fault is satisfied.  If the Zeroed list is not empty, the fault can be resolved by removing a page from the Zeroed list."
',
      );


      $TIPS[]=array(
         'id_ref' => 'winnt_memory_page_rw',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>memoryPageReadsPerSec.0|memoryPageWritesPerSec.0</strong> a partir de los siguientes atributos de la mib WINDOWS-NT-PERFORMANCE:<br><br><strong>WINDOWS-NT-PERFORMANCE::memoryPageReadsPerSec.0 (GAUGE):</strong> "Page Reads/sec is the number of times the disk was read to retrieve pages of virtual memory necessary to resolve page faults.  Multiple pages can be read during a disk read operation."
<strong>WINDOWS-NT-PERFORMANCE::memoryPageWritesPerSec.0 (GAUGE):</strong> "Page Writes/sec is a count of the number of times pages have been written to the disk because they were changed since last retrieved.  Each such write operation may transfer a number of pages."
',
      );


      $TIPS[]=array(
         'id_ref' => 'winnt_ldisk_free_perc',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>ldiskPercentFreeSpace</strong> a partir de los siguientes atributos de la mib WINDOWS-NT-PERFORMANCE:<br><br><strong>WINDOWS-NT-PERFORMANCE::ldiskPercentFreeSpace (GAUGE):</strong> "Percent Free Space is the ratio of the free space available on the logical disk unit to the total usable space provided by the selected logical disk drive"
',
      );


?>
