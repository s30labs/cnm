#---------------------------------------------------------------------------
package ENT_25359_ZFS_NYMNETWORKS;

#Incluye LM-SENSORS-MIB
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_25359_ZFS_NYMNETWORKS::ENTERPRISE_PREFIX='25359';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_25359_ZFS_NYMNETWORKS::TABLE_APPS =(

#	'TABLA DE CARACTERISTICAS DE LA FUENTE DE ALIMENTACION' => {
#		'oid_cols' => 'cpqHeFltTolPowerSupplyChassis_cpqHeFltTolPowerSupplyBay_cpqHeFltTolPowerSupplyPresent_cpqHeFltTolPowerSupplyCondition_cpqHeFltTolPowerSupplyStatus_cpqHeFltTolPowerSupplyMainVoltage_cpqHeFltTolPowerSupplyCapacityUsed_cpqHeFltTolPowerSupplyCapacityMaximum_cpqHeFltTolPowerSupplyRedundant_cpqHeFltTolPowerSupplyModel_cpqHeFltTolPowerSupplySerialNumber_cpqHeFltTolPowerSupplyAutoRev_cpqHeFltTolPowerSupplyHotPlug_cpqHeFltTolPowerSupplyFirmwareRev',
#
#			'oid_last' => 'CPQHLTH-MIB::cpqHeFltTolPowerSupplyTable',
#			'name' => 'COMPAQ - CARACTERISTICAS DE LA FUENTE DE ALIMENTACION',
#			'descr' => 'Muestra la tabla de caracteristicas de las fuentes de alimentacion del servidor',
#			'xml_file' => '00232-COMPAQ-MIB_CPQHLTH_POWER_SUPPLY_TABLE.xml',
#			'params' => '[-n;IP;]',
#			'ipparam' => '[-n;IP;]',
#			'subtype'=>'COMPAQ',
#			'aname'=>'app_compaq_power_supply_table',
#			'range' => 'CPQHLTH-MIB::cpqHeFltTolPowerSupplyTable',
#			'enterprise' => '00232',  #5 CIFRAS !!!!
#			'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00232-COMPAQ-MIB_CPQHLTH_POWER_SUPPLY_TABLE.xml -w xml ',
#	},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_25359_ZFS_NYMNETWORKS::METRICS=(

	{  'name'=> 'ZFS - ESPACIO DE CACHE',   'oid'=>'NYMNETWORKS-MIB::zfsARCSizeKB.0|NYMNETWORKS-MIB::zfsARCMetadataSizeKB.0|NYMNETWORKS-MIB::zfsARCDataSizeKB.0', 'subtype'=>'zfs_cache_size', 'class'=>'ZFS', 'include'=>1, 'apptype'=>'HW.ZFS' },
	{  'name'=> 'ZFS - ACCESOS A CACHE ARC',   'oid'=>'NYMNETWORKS-MIB::zfsARCHits.0|NYMNETWORKS-MIB::zfsARCMisses.0', 'subtype'=>'zfs_cache_hits_Arc', 'class'=>'ZFS', 'include'=>1, 'apptype'=>'HW.ZFS' },
	{  'name'=> 'ZFS - ACCESOS A CACHE L2ARC',   'oid'=>'NYMNETWORKS-MIB::zfsL2ARCHits.0|NYMNETWORKS-MIB::zfsL2ARCMisses.0', 'subtype'=>'zfs_cache_hits_l2arc', 'class'=>'ZFS', 'include'=>1, 'apptype'=>'HW.ZFS' },
	{  'name'=> 'ZFS - ACTIVIDAD EN CACHE L2ARC',   'oid'=>'NYMNETWORKS-MIB::zfsL2ARCReads.0|NYMNETWORKS-MIB::zfsL2ARCWrites.0', 'subtype'=>'zfs_cache_l2arc_rw', 'class'=>'ZFS', 'include'=>1, 'apptype'=>'HW.ZFS' },
	{  'name'=> 'ZFS - LECTURAS/ESCRITURAS',   'oid'=>'NYMNETWORKS-MIB::zfsReadKB.0|NYMNETWORKS-MIB::zfsReaddirKB.0|NYMNETWORKS-MIB::zfsWriteKB.0', 'subtype'=>'zfs_cache_rw', 'class'=>'ZFS', 'include'=>1, 'apptype'=>'HW.ZFS' },


#	{  'name'=> 'USO DE CPU raw-1cpu (%)',   'oid'=>'UCD-SNMP-MIB::ssCpuRawIdle.0|UCD-SNMP-MIB::ssCpuRawUser.0|UCD-SNMP-MIB::ssCpuRawSystem.0', 'subtype'=>'ucd_cpu_raw_usage', 'class'=>'UCDAVIS', 'include'=>0,
#'esp'=>'1*o1|1*o2|1*o3', 'items'=>'Idle|User|System', 'apptype'=>'SO.UCDAVIS'
# },

   {  'name'=> 'ZFS - USO DE DISCO VOL1',  'oid'=>'NYMNETWORKS-MIB::zfsFilesystemAvailableMB.1|NYMNETWORKS-MIB::zfsFilesystemUsedMB.1', 'subtype'=>'zfs_disk_usage_vol1', 'class'=>'ZFS', 'include'=>1, 'apptype'=>'HW.ZFS' },
   {  'name'=> 'ZFS - USO DE DISCO VOL2',  'oid'=>'NYMNETWORKS-MIB::zfsFilesystemAvailableMB.2|NYMNETWORKS-MIB::zfsFilesystemUsedMB.2', 'subtype'=>'zfs_disk_usage_vol2', 'class'=>'ZFS', 'include'=>1, 'apptype'=>'HW.ZFS' },
   {  'name'=> 'ZFS - USO DE DISCO VOL3',  'oid'=>'NYMNETWORKS-MIB::zfsFilesystemAvailableMB.3|NYMNETWORKS-MIB::zfsFilesystemUsedMB.3', 'subtype'=>'zfs_disk_usage_vol3', 'class'=>'ZFS', 'include'=>1, 'apptype'=>'HW.ZFS' },
   {  'name'=> 'ZFS - USO DE DISCO VOL4',  'oid'=>'NYMNETWORKS-MIB::zfsFilesystemAvailableMB.4|NYMNETWORKS-MIB::zfsFilesystemUsedMB.4', 'subtype'=>'zfs_disk_usage_vol4', 'class'=>'ZFS', 'include'=>1, 'apptype'=>'HW.ZFS' },

# El orden en itms => verde|azul|rojo|naranja  (0,0,0,0)=>(v,a,r,n)
   {  'name'=> 'ZFS - ESTADO DEL POOL VOL1',   'oid'=>'NYMNETWORKS-MIB::zfsPoolHealth.1', 'subtype'=>'zfs_pool_health_vol1', 'class'=>'ZFS', 'vlabel'=>'estado', 'include'=>'1', 'items'=>'online(1)|unknown(4)|faulted(3)|degraded(2)', 'esp'=>'MAP(1)(1,0,0,0)|MAP(4)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(2)(0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.ZFS' },

   {  'name'=> 'ZFS - ESTADO DEL POOL VOL2',   'oid'=>'NYMNETWORKS-MIB::zfsPoolHealth.2', 'subtype'=>'zfs_pool_health_vol2', 'class'=>'ZFS', 'vlabel'=>'estado', 'include'=>'1', 'items'=>'online(1)|unknown(4)|faulted(3)|degraded(2)', 'esp'=>'MAP(1)(1,0,0,0)|MAP(4)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(2)(0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.ZFS' },

   {  'name'=> 'ZFS - ESTADO DEL POOL VOL3',   'oid'=>'NYMNETWORKS-MIB::zfsPoolHealth.3', 'subtype'=>'zfs_pool_health_vol3', 'class'=>'ZFS', 'vlabel'=>'estado', 'include'=>'1', 'items'=>'online(1)|unknown(4)|faulted(3)|degraded(2)', 'esp'=>'MAP(1)(1,0,0,0)|MAP(4)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(2)(0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.ZFS' },

   {  'name'=> 'ZFS - ESTADO DEL POOL VOL4',   'oid'=>'NYMNETWORKS-MIB::zfsPoolHealth.4', 'subtype'=>'zfs_pool_health_vol4', 'class'=>'ZFS', 'vlabel'=>'estado', 'include'=>'1', 'items'=>'online(1)|unknown(4)|faulted(3)|degraded(2)', 'esp'=>'MAP(1)(1,0,0,0)|MAP(4)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(2)(0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.ZFS' },


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid NO DEBE IR CUALIFICADO !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_25359_ZFS_NYMNETWORKS::METRICS_TAB=(

#	{	'name'=> 'ZFS - USO DE DISCO (KB)',  'oid'=>'zfsFilesystemAvailableKB|zfsFilesystemUsedKB', 'subtype'=>'zfs_disk_usage_kb', 'class'=>'ZFS', 'range'=>'NYMNETWORKS-MIB::fs', 'get_iid'=>'zfsFilesystemName', 'itil_type'=>1, 'include'=>1, 'apptype'=>'HW.ZFS' },
#	{	'name'=> 'ZFS - USO DE DISCO (MB)',  'oid'=>'zfsFilesystemAvailableMB|zfsFilesystemUsedMB', 'subtype'=>'zfs_disk_usage_kb', 'class'=>'ZFS', 'range'=>'NYMNETWORKS-MIB::fs', 'get_iid'=>'zfsFilesystemName', 'itil_type'=>1, 'include'=>1, 'apptype'=>'HW.ZFS' },
#	{	'name'=> 'USO DE DISCO ZFS (MB)',  'oid'=>'zfsFilesystemAvailableMB|zfsFilesystemUsedMB', 'subtype'=>'zfs_disk_usage_kb', 'class'=>'ZFS', 'range'=>'NYMNETWORKS-MIB::fs', 'get_iid'=>'zfsFilesystemName', 'itil_type'=>1, 'include'=>1, 'apptype'=>'HW.ZFS' },

#root@plzfcnmsip01:/opt/custom_pro/conf# snmptranslate -Td NYMNETWORKS-MIB::zfsPoolHealth
#NYMNETWORKS-MIB::zfsPoolHealth
#zfsPoolHealth OBJECT-TYPE
#  -- FROM       NYMNETWORKS-MIB
#  SYNTAX        INTEGER {online(1), degraded(2), faulted(3), unknown(4)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "The current health of the containing pool, as reported
#                 by zpool status."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) nymnetworks(25359) zfs(1) fs(1) 4 }
# El orden en itms => verde|azul|rojo|naranja

#	{  'name'=> 'ZFS - ESTADO DEL POOL',   'oid'=>'NYMNETWORKS-MIB::zfsPoolHealth', 'subtype'=>'zfs_pool_health', 'class'=>'ZFS', 'range'=>'NYMNETWORKS-MIB::fs', 'vlabel'=>'estado', 'get_iid'=>'zfsFilesystemName', 'include'=>'1', 'items'=>'online(1)|unknown(4)|faulted(3)|degraded(2)', 'esp'=>'MAP(1)(0,0,0,1)|MAP(4)(0,0,1,0)|MAP(3)(0,1,0,0)|MAP(2)(1,0,0,0)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'HW.ZFS' },
);


1;
__END__
