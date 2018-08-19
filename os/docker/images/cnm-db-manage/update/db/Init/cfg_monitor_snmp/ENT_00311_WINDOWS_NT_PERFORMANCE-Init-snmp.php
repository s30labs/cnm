<?php

		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'winnt_memory_avail_bytes',
            'class' => 'WINDOWS-NT',
            'lapse' => '300',
            'descr' => 'MEMORIA DISPONIBLE',
            'items' => 'memoryAvailableBytes.0',
            'oid' => '.1.3.6.1.4.1.311.1.1.3.1.1.1.1.0',
            'get_iid' => '',
            'oidn' => 'WINDOWS-NT-PERFORMANCE::memoryAvailableBytes.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'WINDOWS-NT-PERFORMANCE::memoryAvailableBytes.0',
            'enterprise' => '311',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'SO.WINDOWS',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'winnt_memory_committed_bytes',
            'class' => 'WINDOWS-NT',
            'lapse' => '300',
            'descr' => 'MEMORIA ASIGNADA',
            'items' => 'memoryCommittedBytes.0|memoryCommitLimit.0',
            'oid' => '.1.3.6.1.4.1.311.1.1.3.1.1.1.2.0|.1.3.6.1.4.1.311.1.1.3.1.1.1.3.0',
            'get_iid' => '',
            'oidn' => 'WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0|WINDOWS-NT-PERFORMANCE::memoryCommitLimit.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0',
            'enterprise' => '311',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'SO.WINDOWS',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'winnt_memory_faults',
            'class' => 'WINDOWS-NT',
            'lapse' => '300',
            'descr' => 'MEMORIA - ERRORES',
            'items' => 'memoryPageFaultsPerSec.0|memoryTransitionFaultsPerSec.0|memoryDemandZeroFaultsPerSec.0',
            'oid' => '.1.3.6.1.4.1.311.1.1.3.1.1.1.4.0|.1.3.6.1.4.1.311.1.1.3.1.1.1.6.0|.1.3.6.1.4.1.311.1.1.3.1.1.1.8.0',
            'get_iid' => '',
            'oidn' => 'WINDOWS-NT-PERFORMANCE::memoryPageFaultsPerSec.0|WINDOWS-NT-PERFORMANCE::memoryTransitionFaultsPerSec.0|WINDOWS-NT-PERFORMANCE::memoryDemandZeroFaultsPerSec.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'WINDOWS-NT-PERFORMANCE::memoryPageFaultsPerSec.0',
            'enterprise' => '311',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'SO.WINDOWS',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'winnt_memory_page_rw',
            'class' => 'WINDOWS-NT',
            'lapse' => '300',
            'descr' => 'MEMORIA - PAGINACION',
            'items' => 'memoryPageReadsPerSec.0|memoryPageWritesPerSec.0',
            'oid' => '.1.3.6.1.4.1.311.1.1.3.1.1.1.11.0|.1.3.6.1.4.1.311.1.1.3.1.1.1.13.0',
            'get_iid' => '',
            'oidn' => 'WINDOWS-NT-PERFORMANCE::memoryPageReadsPerSec.0|WINDOWS-NT-PERFORMANCE::memoryPageWritesPerSec.0',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '1',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'WINDOWS-NT-PERFORMANCE::memoryPageReadsPerSec.0',
            'enterprise' => '311',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'SO.WINDOWS',
      );



		$CFG_MONITOR_SNMP[]=array(
            'subtype' => 'winnt_ldisk_free_perc',
            'class' => 'WINDOWS-NT',
            'lapse' => '300',
            'descr' => 'DISCO LIBRE (%)',
            'items' => 'ldiskPercentFreeSpace',
            'oid' => '.1.3.6.1.4.1.311.1.1.3.1.1.5.1.3.IID',
            'get_iid' => 'ldisklogicalDiskInstance',
            'oidn' => 'ldiskPercentFreeSpace.IID',
            'oid_info' => '',
            'module' => 'mod_snmp_get',
            'mtype' => 'STD_BASE',
            'vlabel' => 'num',
            'mode' => 'GAUGE',
            'top_value' => '1',
            'cfg' => '2',
            'custom' => '0',
            'include' => '1',
            'myrange' => 'WINDOWS-NT-PERFORMANCE::ldisklogicalDiskTable',
            'enterprise' => '311',
            'esp' => '',
            'params' => '',
            'itil_type' => '1',
            'apptype' => 'SO.WINDOWS',
      );


?>
