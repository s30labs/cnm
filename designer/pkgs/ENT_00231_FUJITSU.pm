#---------------------------------------------------------------------------
package ENT_00231_FUJITSU;

#---------------------------------------------------------------------------
#/opt/custom_pro/conf/gconf -m ENT_00231_FUJITSU
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_00231_FUJITSU::ENTERPRISE_PREFIX='00231';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_00231_FUJITSU::TABLE_APPS =(

#	'TOP TEN' => {
#
#		'oid_cols' => 'policyHitCount_tppolicyName_policyUUID',
#		'oid_last' => 'TPT-POLICY::topTenHitsByPolicyTable',
#		'name' => 'TABLA DE VULNERABILIDADES - TOP TEN',
#		'descr' => 'Muestra las 10 vulnerabilidades con mayor numero de ocurrencias',
#		'xml_file' => '10734-TIPPINGPOINT-MIB_TOP_TEN_HITS.xml',
#		'params' => '[-n;IP;]',
#		'ipparam' => '[-n;IP;]',
#		'subtype'=>'TIPPING-POINT',
#		'aname'=>'app_tip_top_ten_table',
#		'range' => 'TPT-POLICY::topTenHitsByPolicyTable',
#		'enterprise' => '10734',  #5 CIFRAS !!!!
#		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 10734-TIPPINGPOINT-MIB_TOP_TEN_HITS.xml -w xml ',
#	},



  'RAID - DISPOSITIVOS FISICOS' => {

     'oid_cols' => 'svrPhysicalDeviceCtrlNr_svrPhysicalDeviceChannel_svrPhysicalDeviceTarget_svrPhysicalDeviceLUN_svrPhysicalDeviceModelName_svrPhysicalDeviceVendorName_svrPhysicalDeviceCapacity_svrPhysicalDeviceMaxTransferRate_svrPhysicalDeviceType_svrPhysicalDeviceConfiguredDisk_svrPhysicalDeviceInterface_svrPhysicalDeviceErrors_svrPhysicalDeviceNrBadBlocks_svrPhysicalDeviceSmartStatus_svrPhysicalDeviceStatus_svrPhysicalDeviceFirmwareRevision_svrPhysicalDeviceSerialNumber_svrPhysicalDeviceForeignConfig_svrPhysicalDeviceIdx_svrPhysicalDeviceStatusEx_svrPhysicalDeviceCapacityMB',
     'oid_last' => 'FSC-RAID-MIB::svrPhysicalDeviceTable',
     'name' => 'RAID - DISPOSITIVOS FISICOS',
     'descr' => 'Muestra las 10 vulnerabilidades con mayor numero de ocurrencias',
     'xml_file' => '00231-RAID_SERVERVIEW-PHYS-DEV.xml',
     'params' => '[-n;IP;]',
     'ipparam' => '[-n;IP;]',
     'subtype'=>'RAID-SERVERVIEW',
     'aname'=>'app_raid_sview_phys_dev',
     'range' => 'FSC-RAID-MIB::svrPhysicalDeviceTable',
     'enterprise' => '00231',  #5 CIFRAS !!!!
     'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00231-RAID_SERVERVIEW-PHYS-DEV.xml -w xml ',
  },


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00231_FUJITSU::METRICS=(

#FSC-RAID-MIB::svrStatusLogicalDrives
#svrStatusLogicalDrives OBJECT-TYPE
#  -- FROM       FSC-RAID-MIB
#  -- TEXTUAL CONVENTION CompStatus
#  SYNTAX        INTEGER {ok(1), prefailure(2), failure(3)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "Logical drive status (summary status of all logical drives at all controllers)"
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) sni(231) sniProductMibs(2) fscRAIDMIB(49) svrObjects(1) svrStatus(3) 1 }
#
   {  'name'=> 'RAID - ESTADO DISCOS LOGICOS',   'oid'=>'FSC-RAID-MIB::svrStatusLogicalDrives.0', 'subtype'=>'raid_sv_ldisk_gstat', 'class'=>'RAID', 'itil_type' => 1, 'apptype'=>'HW.RAID',
'items'=>'ok(1)|unk(4)|failure(3)|prefailure(2)', 'esp'=>'MAP(1)(1,0,0,0)|MAP(4)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(2)(0,0,0,1)', 'mtype'=>'STD_SOLID' },

#FSC-RAID-MIB::svrStatusPhysicalDevices.0
#svrStatusPhysicalDevices OBJECT-TYPE
#  -- FROM       FSC-RAID-MIB
#  -- TEXTUAL CONVENTION CompStatus
#  SYNTAX        INTEGER {ok(1), prefailure(2), failure(3)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "Device status (summary status of all devices at all controllers)"
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) sni(231) sniProductMibs(2) fscRAIDMIB(49) svrObjects(1) svrStatus(3) svrStatusPhysicalDevices(2) 0 }

   {  'name'=> 'RAID - ESTADO DISPOSITIVOS FISICOS',   'oid'=>'FSC-RAID-MIB::svrStatusPhysicalDevices.0', 'subtype'=>'raid_sv_dev_gstat', 'class'=>'RAID', 'itil_type' => 1, 'apptype'=>'HW.RAID',
'items'=>'ok(1)|unk(4)|failure(3)|prefailure(2)', 'esp'=>'MAP(1)(1,0,0,0)|MAP(4)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(2)(0,0,0,1)', 'mtype'=>'STD_SOLID' },

#FSC-RAID-MIB::svrStatusControllers.0
#svrStatusControllers OBJECT-TYPE
#  -- FROM       FSC-RAID-MIB
#  -- TEXTUAL CONVENTION CompStatus
#  SYNTAX        INTEGER {ok(1), prefailure(2), failure(3)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "Controller status (summary status of all controllers, including status
#                  of all devices and logical drives of this controller)"
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) sni(231) sniProductMibs(2) fscRAIDMIB(49) svrObjects(1) svrStatus(3) svrStatusControllers(3) 0 }

   {  'name'=> 'RAID - ESTADO CONTROLADORES',   'oid'=>'FSC-RAID-MIB::svrStatusPhysicalDevices.0', 'subtype'=>'raid_sv_cont_gstat', 'class'=>'RAID', 'itil_type' => 1, 'apptype'=>'HW.RAID',
'items'=>'ok(1)|unk(4)|failure(3)|prefailure(2)', 'esp'=>'MAP(1)(1,0,0,0)|MAP(4)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(2)(0,0,0,1)', 'mtype'=>'STD_SOLID' },

#FSC-RAID-MIB::svrStatusOverall.0
#svrStatusOverall OBJECT-TYPE
#  -- FROM       FSC-RAID-MIB
#  -- TEXTUAL CONVENTION CompStatus
#  SYNTAX        INTEGER {ok(1), prefailure(2), failure(3)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "Overall status (overall summary status)"
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) sni(231) sniProductMibs(2) fscRAIDMIB(49) svrObjects(1) svrStatus(3) svrStatusOverall(4) 0 }

   {  'name'=> 'RAID - ESTADO GLOBAL',   'oid'=>'FSC-RAID-MIB::svrStatusOverall.0', 'subtype'=>'raid_sv_gstat', 'class'=>'RAID', 'itil_type' => 1, 'apptype'=>'HW.RAID',
'items'=>'ok(1)|unk(4)|failure(3)|prefailure(2)', 'esp'=>'MAP(1)(1,0,0,0)|MAP(4)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(2)(0,0,0,1)', 'mtype'=>'STD_SOLID' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_00231_FUJITSU::METRICS_TAB=(

#FSC-RAID-MIB::svrCtrlStatus.1 = INTEGER: 2
#FSC-RAID-MIB::svrPhysicalDeviceSmartStatus.1.1.0.0 = INTEGER: 1
#FSC-RAID-MIB::svrPhysicalDeviceSmartStatus.1.2.1.0 = INTEGER: 1
#FSC-RAID-MIB::svrPhysicalDeviceSmartStatus.1.3.2.0 = INTEGER: 1
#FSC-RAID-MIB::svrPhysicalDeviceSmartStatus.1.4.3.0 = INTEGER: 1
#FSC-RAID-MIB::svrPhysicalDeviceSmartStatus.1.5.4.0 = INTEGER: 1

#FSC-RAID-MIB::svrCtrlBBUStatusEx
#svrCtrlBBUStatusEx OBJECT-TYPE
#  -- FROM       FSC-RAID-MIB
#  SYNTAX        INTEGER {unknown(1), notInstalled(2), normal(3), charging(4), discharging(5), warning(6), failed(7)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "Status of onboard battery backup unit"
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) sni(231) sniProductMibs(2) fscRAIDMIB(49) svrObjects(1) svrControllerInfo(4) svrCtrlTable(2) svrCtrlEntry(1) 24 }

   {  'name'=> 'RAID - ESTADO BATERIA DE BACKUP',   'oid'=>'FSC-RAID-MIB::svrCtrlBBUStatusEx', 'subtype'=>'raid_sv_bb_stat', 'class'=>'RAID', 'range'=>'FSC-RAID-MIB::svrLogicalDriveTable', 'vlabel'=>'estado', 'get_iid'=>'svrCtrlBusLocationText', 'include'=>'1', 'items'=>'normal(3)|unknown(1)|failed(7)| warning(6)|notInstalled(2)|charging(4)|discharging(5)',
'esp'=>'MAP(3)(1,0,0,0,0,0,0)|MAP(1)(0,1,0,0,0,0,0)|MAP(7)(0,0,1,0,0,0,0)|MAP(6)(0,0,0,1,0,0,0)|MAP(2)(0,0,0,0,1,0,0)|MAP(4)(0,0,0,0,0,1,0)|MAP(5)(0,0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 1, 'apptype'=>'HW.RAID' },


#FSC-RAID-MIB::svrPhysicalDeviceStatusEx
#svrPhysicalDeviceStatusEx OBJECT-TYPE
#  -- FROM       FSC-RAID-MIB
#  SYNTAX        INTEGER {unknown(1), noDisk(2), available(3), operational(4), failed(5), rebuilding(6), globalHotSpare(7), dedicatedHotSpare(8), offline(9), unconfiguredFailed(10), failedMissing(11), copyBack(12), redundantCopy(13), waiting(14), preparing(15), migrating(16)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "Device status:
#                    noDisk(2):                device is not a hard disk
#                    available(3):             device is unconfigured and working properly
#                    operational(4):           device is configured and working properly
#                    failed(5):                device is configured but is no longer working
#                    rebuilding(6):            device is restoring fault tolerance
#                    globalHotSpare(7):        device is a hot spare device for use in any array
#                    dedicatedHotSpare(8):     device is a hot spare device for use in a dedicated array
#                    offline(9):               device is set to non-working state
#                    unconfiguredFailed(10):   device is not configured but is no longer working
#                    failedMissing(11):        device is not available anymore
#                    copyBack(12):             device is target for copyback operation
#                    redundantCopy(13):        device is target for redundant copy operation
#                    waiting(14):              device is waiting for copyback to start
#                    preparing(15):            device is starting up
#                    migrating(16):            device is part of migration process"
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) sni(231) sniProductMibs(2) fscRAIDMIB(49) svrObjects(1) svrPhysicalDeviceInfo(5) svrPhysicalDeviceTable(2) svrPhysicalDeviceEntry(1) 20 }

   {  'name'=> 'RAID - ESTADO DISCO FISICO',   'oid'=>'FSC-RAID-MIB::svrPhysicalDeviceStatusEx', 'subtype'=>'raid_sv_pdisk_stat', 'class'=>'RAID', 'range'=>'FSC-RAID-MIB::svrPhysicalDeviceTable', 'vlabel'=>'estado', 'get_iid'=>'svrPhysicalDeviceSerialNumber', 'include'=>'1', 'items'=>'
operational(4)|available(3)|failed(5)|offline(9)|noDisk(2)|rebuilding(6)|globalHotSpare(7)|dedicatedHotSpare(8)|unconfiguredFailed(10)|failedMissing(11)|copyBack(12)|redundantCopy(13)|waiting(14)|preparing(15)|migrating(16)', 
'esp'=>'MAP(4)(1,0,0,0,0,0,0,0,0,0,0,0,0,0,0)|MAP(3)(0,1,0,0,0,0,0,0,0,0,0,0,0,0,0)|MAP(5)(0,0,1,0,0,0,0,0,0,0,0,0,0,0,0)|MAP(9)(0,0,0,1,0,0,0,0,0,0,0,0,0,0,0)|MAP(2)(0,0,0,0,1,0,0,0,0,0,0,0,0,0,0)|MAP(6)(0,0,0,0,0,1,0,0,0,0,0,0,0,0,0)|MAP(7)(0,0,0,0,0,0,1,0,0,0,0,0,0,0,0)|MAP(8)(0,0,0,0,0,0,0,1,0,0,0,0,0,0,0)|MAP(10)(0,0,0,0,0,0,0,0,1,0,0,0,0,0,0)|MAP(11)(0,0,0,0,0,0,0,0,0,1,0,0,0,0,0)|MAP(12)(0,0,0,0,0,0,0,0,0,0,1,0,0,0,0)|MAP(13)(0,0,0,0,0,0,0,0,0,0,0,1,0,0,0)|MAP(14)(0,0,0,0,0,0,0,0,0,0,0,0,1,0,0)|MAP(15)(0,0,0,0,0,0,0,0,0,0,0,0,0,1,0)|MAP(16)(0,0,0,0,0,0,0,0,0,0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 1, 'apptype'=>'HW.RAID' },


#FSC-RAID-MIB::svrLogicalDriveStatusEx
#svrLogicalDriveStatusEx OBJECT-TYPE
#  -- FROM       FSC-RAID-MIB
#  SYNTAX        INTEGER {unknown(1), operational(2), partiallyDegraded(3), degraded(4), failed(5), rebuilding(6), checking(7), mdcing(8), initializing(9), backgroundInitializing(10), migrating(11), copying(12), offline(13), spareInUse(14)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "Status of the logical drive:
#                    operational(2):   drive is OK, all disks working properly
#                    partiallyDegraded(3): one disk in this array failed, reduced redundancy still available
#                    degraded(4):      one disk in this array failed, redundancy lost
#                    failed(5):        too many disks in this array failed, drive no longer available
#                    rebuilding(6):    drive is currently rebuilding
#                    checking(7):      drive is currently executing a consistency check
#                    mdcing(8):        drive is currently executing a consistency check and fixes inconsistencies
#                    initializing(9):  drive is currently being initialized
#                    backgroundInitializing(10): drive is currently being initialized in background
#                    migrating(11):    drive is currently being modified (online RAID extension)
#                    copying(12):      drive is currently executing a copyback or redundant copy operation
#                    offline(13):      drive is temporarily not operational"
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) sni(231) sniProductMibs(2) fscRAIDMIB(49) svrObjects(1) svrLogicalDriveInfo(6) svrLogicalDriveTable(2) svrLogicalDriveEntry(1) 19 }

   {  'name'=> 'RAID - ESTADO DISCO LOGICO',   'oid'=>'FSC-RAID-MIB::svrLogicalDriveStatusEx', 'subtype'=>'raid_sv_ldisk_stat', 'class'=>'RAID', 'range'=>'FSC-RAID-MIB::svrLogicalDriveTable', 'vlabel'=>'estado', 'get_iid'=>'svrLogicalDriveName', 'include'=>'1', 'items'=>'
operational(2)|partiallyDegraded(3)|failed(5)|degraded(4)|offline(13)|rebuilding(6)|checking(7)|mdcing(8)|initializing(9)|backgroundInitializing(10)|migrating(11)|copying(12)', 
'esp'=>'MAP(2)(1,0,0,0,0,0,0,0,0,0,0,0)|MAP(3)(0,1,0,0,0,0,0,0,0,0,0,0)|MAP(5)(0,0,1,0,0,0,0,0,0,0,0,0)|MAP(4)(0,0,0,1,0,0,0,0,0,0,0,0)|MAP(13)(0,0,0,0,1,0,0,0,0,0,0,0)|MAP(6)(0,0,0,0,0,1,0,0,0,0,0,0)|MAP(7)(0,0,0,0,0,0,1,0,0,0,0,0)|MAP(8)(0,0,0,0,0,0,0,1,0,0,0,0)|MAP(9)(0,0,0,0,0,0,0,0,1,0,0,0)|MAP(10)(0,0,0,0,0,0,0,0,0,1,0,0)|MAP(11)(0,0,0,0,0,0,0,0,0,0,1,0)|MAP(12)(0,0,0,0,0,0,0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 1, 'apptype'=>'HW.RAID' },

#FSC-RAID-MIB::svrLogicalDriveInitStatus
#svrLogicalDriveInitStatus OBJECT-TYPE
#  -- FROM       FSC-RAID-MIB
#  SYNTAX        INTEGER {unknown(1), initialized(2), notInitialized(3)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "Logical drive initialization status"
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) sni(231) sniProductMibs(2) fscRAIDMIB(49) svrObjects(1) svrLogicalDriveInfo(6) svrLogicalDriveTable(2) svrLogicalDriveEntry(1) 18 }

   {  'name'=> 'RAID - ESTADO INIT DISCO LOGICO',   'oid'=>'FSC-RAID-MIB::svrLogicalDriveInitStatus', 'subtype'=>'raid_sv_ldisk_istat', 'class'=>'RAID', 'range'=>'FSC-RAID-MIB::svrLogicalDriveTable', 'vlabel'=>'estado', 'get_iid'=>'svrLogicalDriveName', 'include'=>'1', 'items'=>'initialized(2)|unknown(1)|notInitialized(3)|other', 'esp'=>'MAP(2)(1,0,0,0)|MAP(1)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(*)(0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 1, 'apptype'=>'HW.RAID' },


);


1;
__END__
