<?php
      $TIPS[]=array(
         'id_ref' => 'zfs_cache_size',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>zfsARCSizeKB.0|zfsARCMetadataSizeKB.0|zfsARCDataSizeKB.0</strong> a partir de los siguientes atributos de la mib NYMNETWORKS-MIB:<br><br><strong>NYMNETWORKS-MIB::zfsARCSizeKB.0 (GAUGE):</strong> "The current ARC size in KB."
<strong>NYMNETWORKS-MIB::zfsARCMetadataSizeKB.0 (GAUGE):</strong> "The amount of ARC space used for metadata storage, in KB."
<strong>NYMNETWORKS-MIB::zfsARCDataSizeKB.0 (GAUGE):</strong> "The amount of ARC space used for file data storage, in KB."
',
      );


      $TIPS[]=array(
         'id_ref' => 'zfs_cache_hits_Arc',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>zfsARCHits.0|zfsARCMisses.0</strong> a partir de los siguientes atributos de la mib NYMNETWORKS-MIB:<br><br><strong>NYMNETWORKS-MIB::zfsARCHits.0 (GAUGE):</strong> "The number of ARC accesses that were cache hits."
<strong>NYMNETWORKS-MIB::zfsARCMisses.0 (GAUGE):</strong> "The number of ARC accesses that were cache misses."
',
      );


      $TIPS[]=array(
         'id_ref' => 'zfs_cache_hits_l2arc',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>zfsL2ARCHits.0|zfsL2ARCMisses.0</strong> a partir de los siguientes atributos de la mib NYMNETWORKS-MIB:<br><br><strong>NYMNETWORKS-MIB::zfsL2ARCHits.0 (GAUGE):</strong> "The number of L2ARC accesses that were cache hits."
<strong>NYMNETWORKS-MIB::zfsL2ARCMisses.0 (GAUGE):</strong> "The number of L2ARC accesses that were cache misses."
',
      );


      $TIPS[]=array(
         'id_ref' => 'zfs_cache_l2arc_rw',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>zfsL2ARCReads.0|zfsL2ARCWrites.0</strong> a partir de los siguientes atributos de la mib NYMNETWORKS-MIB:<br><br><strong>NYMNETWORKS-MIB::zfsL2ARCReads.0 (GAUGE):</strong> "The number of reads made from L2ARC devices."
<strong>NYMNETWORKS-MIB::zfsL2ARCWrites.0 (GAUGE):</strong> "The number of writes made to L2ARC devices."
',
      );


      $TIPS[]=array(
         'id_ref' => 'zfs_cache_rw',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>zfsReadKB.0|zfsReaddirKB.0|zfsWriteKB.0</strong> a partir de los siguientes atributos de la mib NYMNETWORKS-MIB:<br><br><strong>NYMNETWORKS-MIB::zfsReadKB.0 (GAUGE):</strong> "The amount of file data read from the ZFS filesystem layer, in KB."
<strong>NYMNETWORKS-MIB::zfsReaddirKB.0 (GAUGE):</strong> "The amount of directory data read from the ZFS filesystem layer, in KB."
<strong>NYMNETWORKS-MIB::zfsWriteKB.0 (GAUGE):</strong> "The amount of file data written to the ZFS filesystem layer, in KB."
',
      );


      $TIPS[]=array(
         'id_ref' => 'zfs_disk_usage_vol1',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>zfsFilesystemAvailableMB.1|zfsFilesystemUsedMB.1</strong> a partir de los siguientes atributos de la mib NYMNETWORKS-MIB:<br><br><strong>NYMNETWORKS-MIB::zfsFilesystemAvailableMB.1 (GAUGE):</strong> "The number of 1 MB blocks that are available for use.
 		 Useful if zfsFilesystemAvailableKB exceeds a 32 bit
 		 integer."
<strong>NYMNETWORKS-MIB::zfsFilesystemUsedMB.1 (GAUGE):</strong> "The number of 1 MB blocks that are in use Useful if
 		 zfsFilesystemUsedKB exceeds a 32 bit integer."
',
      );


      $TIPS[]=array(
         'id_ref' => 'zfs_disk_usage_vol2',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>zfsFilesystemAvailableMB.2|zfsFilesystemUsedMB.2</strong> a partir de los siguientes atributos de la mib NYMNETWORKS-MIB:<br><br><strong>NYMNETWORKS-MIB::zfsFilesystemAvailableMB.2 (GAUGE):</strong> "The number of 1 MB blocks that are available for use.
 		 Useful if zfsFilesystemAvailableKB exceeds a 32 bit
 		 integer."
<strong>NYMNETWORKS-MIB::zfsFilesystemUsedMB.2 (GAUGE):</strong> "The number of 1 MB blocks that are in use Useful if
 		 zfsFilesystemUsedKB exceeds a 32 bit integer."
',
      );


      $TIPS[]=array(
         'id_ref' => 'zfs_disk_usage_vol3',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>zfsFilesystemAvailableMB.3|zfsFilesystemUsedMB.3</strong> a partir de los siguientes atributos de la mib NYMNETWORKS-MIB:<br><br><strong>NYMNETWORKS-MIB::zfsFilesystemAvailableMB.3 (GAUGE):</strong> "The number of 1 MB blocks that are available for use.
 		 Useful if zfsFilesystemAvailableKB exceeds a 32 bit
 		 integer."
<strong>NYMNETWORKS-MIB::zfsFilesystemUsedMB.3 (GAUGE):</strong> "The number of 1 MB blocks that are in use Useful if
 		 zfsFilesystemUsedKB exceeds a 32 bit integer."
',
      );


      $TIPS[]=array(
         'id_ref' => 'zfs_disk_usage_vol4',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>zfsFilesystemAvailableMB.4|zfsFilesystemUsedMB.4</strong> a partir de los siguientes atributos de la mib NYMNETWORKS-MIB:<br><br><strong>NYMNETWORKS-MIB::zfsFilesystemAvailableMB.4 (GAUGE):</strong> "The number of 1 MB blocks that are available for use.
 		 Useful if zfsFilesystemAvailableKB exceeds a 32 bit
 		 integer."
<strong>NYMNETWORKS-MIB::zfsFilesystemUsedMB.4 (GAUGE):</strong> "The number of 1 MB blocks that are in use Useful if
 		 zfsFilesystemUsedKB exceeds a 32 bit integer."
',
      );


      $TIPS[]=array(
         'id_ref' => 'zfs_pool_health_vol1',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>online(1)|unknown(4)|faulted(3)|degraded(2)</strong> a partir de los siguientes atributos de la mib NYMNETWORKS-MIB:<br><br><strong>NYMNETWORKS-MIB::zfsPoolHealth.1 (GAUGE):</strong> "The current health of the containing pool, as reported
 		 by zpool status."
',
      );


      $TIPS[]=array(
         'id_ref' => 'zfs_pool_health_vol2',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>online(1)|unknown(4)|faulted(3)|degraded(2)</strong> a partir de los siguientes atributos de la mib NYMNETWORKS-MIB:<br><br><strong>NYMNETWORKS-MIB::zfsPoolHealth.2 (GAUGE):</strong> "The current health of the containing pool, as reported
 		 by zpool status."
',
      );


      $TIPS[]=array(
         'id_ref' => 'zfs_pool_health_vol3',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>online(1)|unknown(4)|faulted(3)|degraded(2)</strong> a partir de los siguientes atributos de la mib NYMNETWORKS-MIB:<br><br><strong>NYMNETWORKS-MIB::zfsPoolHealth.3 (GAUGE):</strong> "The current health of the containing pool, as reported
 		 by zpool status."
',
      );


      $TIPS[]=array(
         'id_ref' => 'zfs_pool_health_vol4',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>online(1)|unknown(4)|faulted(3)|degraded(2)</strong> a partir de los siguientes atributos de la mib NYMNETWORKS-MIB:<br><br><strong>NYMNETWORKS-MIB::zfsPoolHealth.4 (GAUGE):</strong> "The current health of the containing pool, as reported
 		 by zpool status."
',
      );


?>
