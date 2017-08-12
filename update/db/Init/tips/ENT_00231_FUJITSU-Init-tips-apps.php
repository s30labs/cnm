<?php
      $TIPS[]=array(
         'id_ref' => 'app_raid_sview_phys_dev',  'tip_type' => 'app', 'url' => '',
         'date' => 1430851546,     'tip_class' => 1, 'name' => 'Descripcion',
         'descr' => '<strong>Muestra las 10 vulnerabilidades con mayor numero de ocurrencias</strong><br>Utiliza la tabla SNMP FSC-RAID-MIB::svrPhysicalDeviceTable (Enterprise=00231)<br><br><strong>FSC-RAID-MIB::svrPhysicalDeviceCtrlNr (GAUGE):</strong><br>"Controller number (same as index in svrCtrlTable)"
<strong>FSC-RAID-MIB::svrPhysicalDeviceChannel (GAUGE):</strong><br>"Channel/Port number (index, depends on interface)
                     SCSI: bus (channel) number
                     IDE:  0 = controller 1 primary, 1 = controller 1 secondary...
                     SATA: port number"
<strong>FSC-RAID-MIB::svrPhysicalDeviceTarget (GAUGE):</strong><br>"Device target number (index)
                     SCSI: Device target number (SCSI ID)
                     IDE:  0 = master, 1 = slave
                     SATA: not used (0)"
<strong>FSC-RAID-MIB::svrPhysicalDeviceLUN (GAUGE):</strong><br>"Device logical unit number (index)
                     SCSI: Device unit number (SCSI LUN)
                     IDE:  not used (0)
                     SATA: not used (0)"
<strong>FSC-RAID-MIB::svrPhysicalDeviceModelName (GAUGE):</strong><br>"Device model name"
<strong>FSC-RAID-MIB::svrPhysicalDeviceVendorName (GAUGE):</strong><br>"Device vendor (manufacturer) name"
<strong>FSC-RAID-MIB::svrPhysicalDeviceCapacity (GAUGE):</strong><br>"Disk capacity (GBytes)"
<strong>FSC-RAID-MIB::svrPhysicalDeviceMaxTransferRate (GAUGE):</strong><br>"Maximum transfer rate (MBytes/second) of the disk interface"
<strong>FSC-RAID-MIB::svrPhysicalDeviceType (GAUGE):</strong><br>"Device type"
<strong>FSC-RAID-MIB::svrPhysicalDeviceConfiguredDisk (GAUGE):</strong><br>"This disk is a configured part of RAID array"
<strong>FSC-RAID-MIB::svrPhysicalDeviceInterface (GAUGE):</strong><br>"Disk connection interface"
<strong>FSC-RAID-MIB::svrPhysicalDeviceErrors (COUNTER):</strong><br>"Number of read/write/seek or other errors (summary of all error counters)"
<strong>FSC-RAID-MIB::svrPhysicalDeviceNrBadBlocks (COUNTER):</strong><br>"Number of detected bad blocks (0 = unknown or no bad blocks)"
<strong>FSC-RAID-MIB::svrPhysicalDeviceSmartStatus (GAUGE):</strong><br>"S.M.A.R.T. status"
<strong>FSC-RAID-MIB::svrPhysicalDeviceStatus (GAUGE):</strong><br>"Device status (deprecated):
                     noDisk(2):               device is not a hard disk
                     online(3):               device is available and working properly
                     ready(4):                device can be used for new configuration
                     failed(5):               device is available but no longer working
                     rebuilding(6):           device is restoring fault tolerance
                     hotspareGlobal(7):       device is a hot spare device for use in any array
                     hotspareDedicated(8):    device is a hot spare device for use in a dedicated array
                     offline(9):              device is set to non-working state
                     unconfiguredFailed(10):  device is not configured but a failure has occured
                     formatting(15):          device is currently being formatted
                     dead(12):                device is not available or not responding"
<strong>FSC-RAID-MIB::svrPhysicalDeviceFirmwareRevision (GAUGE):</strong><br>"Device firmware version/revision"
<strong>FSC-RAID-MIB::svrPhysicalDeviceSerialNumber (GAUGE):</strong><br>"Device serial number"
<strong>FSC-RAID-MIB::svrPhysicalDeviceForeignConfig (GAUGE):</strong><br>"This device has a foreign configuration"
<strong>FSC-RAID-MIB::svrPhysicalDeviceIdx (GAUGE):</strong><br>"Device SVRAID object index"
<strong>FSC-RAID-MIB::svrPhysicalDeviceStatusEx (GAUGE):</strong><br>"Device status:
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
<strong>FSC-RAID-MIB::svrPhysicalDeviceCapacityMB (GAUGE):</strong><br>"Disk capacity (MBytes)"
',
      );


?>
