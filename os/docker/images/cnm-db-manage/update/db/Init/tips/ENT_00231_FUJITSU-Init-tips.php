<?php
      $TIPS[]=array(
         'id_ref' => 'raid_sv_ldisk_gstat',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>ok(1)|unk(4)|failure(3)|prefailure(2)</strong> a partir de los siguientes atributos de la mib FSC-RAID-MIB:<br><br><strong>FSC-RAID-MIB::svrStatusLogicalDrives.0 (GAUGE):</strong> "Logical drive status (summary status of all logical drives at all controllers)"
',
      );


      $TIPS[]=array(
         'id_ref' => 'raid_sv_dev_gstat',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>ok(1)|unk(4)|failure(3)|prefailure(2)</strong> a partir de los siguientes atributos de la mib FSC-RAID-MIB:<br><br><strong>FSC-RAID-MIB::svrStatusPhysicalDevices.0 (GAUGE):</strong> "Device status (summary status of all devices at all controllers)"
',
      );


      $TIPS[]=array(
         'id_ref' => 'raid_sv_cont_gstat',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>ok(1)|unk(4)|failure(3)|prefailure(2)</strong> a partir de los siguientes atributos de la mib FSC-RAID-MIB:<br><br><strong>FSC-RAID-MIB::svrStatusPhysicalDevices.0 (GAUGE):</strong> "Device status (summary status of all devices at all controllers)"
',
      );


      $TIPS[]=array(
         'id_ref' => 'raid_sv_gstat',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>ok(1)|unk(4)|failure(3)|prefailure(2)</strong> a partir de los siguientes atributos de la mib FSC-RAID-MIB:<br><br><strong>FSC-RAID-MIB::svrStatusOverall.0 (GAUGE):</strong> "Overall status (overall summary status)"
',
      );


      $TIPS[]=array(
         'id_ref' => 'raid_sv_bb_stat',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>normal(3)|unknown(1)|failed(7)| warning(6)|notInstalled(2)|charging(4)|discharging(5)</strong> a partir de los siguientes atributos de la mib FSC-RAID-MIB:<br><br><strong>FSC-RAID-MIB::svrCtrlBBUStatusEx (GAUGE):</strong> "Status of onboard battery backup unit"
',
      );


      $TIPS[]=array(
         'id_ref' => 'raid_sv_pdisk_stat',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>
operational(4)|available(3)|failed(5)|offline(9)|noDisk(2)|rebuilding(6)|globalHotSpare(7)|dedicatedHotSpare(8)|unconfiguredFailed(10)|failedMissing(11)|copyBack(12)|redundantCopy(13)|waiting(14)|preparing(15)|migrating(16)</strong> a partir de los siguientes atributos de la mib FSC-RAID-MIB:<br><br><strong>FSC-RAID-MIB::svrPhysicalDeviceStatusEx (GAUGE):</strong> "Device status:
                     noDisk(2):                device is not a hard disk
                     available(3):             device is unconfigured and working properly
                     operational(4):           device is configured and working properly
                     failed(5):                device is configured but is no longer working
                     rebuilding(6):            device is restoring fault tolerance
                     globalHotSpare(7):        device is a hot spare device for use in any array
                     dedicatedHotSpare(8):     device is a hot spare device for use in a dedicated array
                     offline(9):               device is set to non-working state
                     unconfiguredFailed(10):   device is not configured but is no longer working
                     failedMissing(11):        device is not available anymore
                     copyBack(12):             device is target for copyback operation
                     redundantCopy(13):        device is target for redundant copy operation
                     waiting(14):              device is waiting for copyback to start
                     preparing(15):            device is starting up
                     migrating(16):            device is part of migration process"
',
      );


      $TIPS[]=array(
         'id_ref' => 'raid_sv_ldisk_stat',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>
operational(2)|partiallyDegraded(3)|failed(5)|degraded(4)|offline(13)|rebuilding(6)|checking(7)|mdcing(8)|initializing(9)|backgroundInitializing(10)|migrating(11)|copying(12)</strong> a partir de los siguientes atributos de la mib FSC-RAID-MIB:<br><br><strong>FSC-RAID-MIB::svrLogicalDriveStatusEx (GAUGE):</strong> "Status of the logical drive:
                     operational(2):   drive is OK, all disks working properly
                     partiallyDegraded(3): one disk in this array failed, reduced redundancy still available
                     degraded(4):      one disk in this array failed, redundancy lost
                     failed(5):        too many disks in this array failed, drive no longer available
                     rebuilding(6):    drive is currently rebuilding
                     checking(7):      drive is currently executing a consistency check
                     mdcing(8):        drive is currently executing a consistency check and fixes inconsistencies
                     initializing(9):  drive is currently being initialized
                     backgroundInitializing(10): drive is currently being initialized in background
                     migrating(11):    drive is currently being modified (online RAID extension)
                     copying(12):      drive is currently executing a copyback or redundant copy operation
                     offline(13):      drive is temporarily not operational"
',
      );


      $TIPS[]=array(
         'id_ref' => 'raid_sv_ldisk_istat',	'tip_type' => 'cfg',	'url' => '',
         'date' => '',     'tip_class' => 1,	'name' => 'Descripcion',
         'descr' => 'Mide: <strong>initialized(2)|unknown(1)|notInitialized(3)|other</strong> a partir de los siguientes atributos de la mib FSC-RAID-MIB:<br><br><strong>FSC-RAID-MIB::svrLogicalDriveInitStatus (GAUGE):</strong> "Logical drive initialization status"
',
      );


?>
