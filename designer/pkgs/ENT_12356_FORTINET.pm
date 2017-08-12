#--------------------------------------------------------------------------- 
package ENT_12356_FORTINET;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_12356_FORTINET::ENTERPRISE_PREFIX='02636';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_12356_FORTINET::TABLE_APPS =(

#   'CHASSIS-INFO' => {
#
#      'col_filters' => '#select_filter,#select_filter,#select_filter,#select_filter,#text_filter,#numeric_filter',
#      'col_widths' => '20.20.20.15.25.15',
#      'col_sorting' => 'int.int.int.int.str.int',
#
#      'oid_cols' => 'jnxContainersView_jnxContainersLevel_jnxContainersWithin_jnxContainersType_jnxContainersDescr_jnxContainersCount',
#      'oid_last' => 'JUNIPER-MIB::jnxContainersTable',
#      'name' => 'INFORMACION SOBRE EL CHASIS',
#      'descr' => 'Muestra informacion sobre los elementos que componen el chasis del equipo',
#      'xml_file' => '02636-JUNIPER-CHASSIS-INFO.xml',
#      'params' => '[-n;IP;]',
#      'ipparam' => '[-n;IP;]',
#      'subtype'=>'JUNIPER',
#      'aname'=>'app_jun_chassis_info',
#      'range' => 'JUNIPER-MIB::jnxContainersTable',
#      'enterprise' => '02636',  #5 CIFRAS !!!!
#      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 02636-JUNIPER-CHASSIS-INFO.xml -w xml ',
#		'itil_type' => '1',		'apptype'=>'NET.JUNIPER',
#   },
#

#   'POLICY-STATS' => {
#
#      'col_filters' => '#text_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter,#numeric_filter',
#      'col_widths' => '20.20.20.15.25.25.15.15.20.20.20.20.20.20',
#      'col_sorting' => 'str.int.int.int.int.int.int.int.int.int.int.int.int.int',
#
#      'oid_cols' => 'jnxJsPolicyStatsCreationTime_jnxJsPolicyStatsInputBytes_jnxJsPolicyStatsInputByteRate_jnxJsPolicyStatsOutputBytes_jnxJsPolicyStatsOutputByteRate_jnxJsPolicyStatsInputPackets_jnxJsPolicyStatsInputPacketRate_jnxJsPolicyStatsOutputPackets_jnxJsPolicyStatsOutputPacketRate_jnxJsPolicyStatsNumSessions_jnxJsPolicyStatsSessionRate_jnxJsPolicyStatsSessionDeleted_jnxJsPolicyStatsLookups_jnxJsPolicyStatsCountAlarm',
#      'oid_last' => 'JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsTable',
#      'name' => 'ESTADO',
#      'descr' => '',
#      'xml_file' => '',
#      'params' => '[-n;IP;]',
#      'ipparam' => '[-n;IP;]',
#      'subtype'=>'JUNIPER',
#      'aname'=>'app_jun_',
#      'range' => 'JUNIPER-JS-POLICY-MIB::jnxJsPolicyStatsTable',
#      'enterprise' => '02636',  #5 CIFRAS !!!!
#      'cmd' => '/opt/crawler/bin/libexec/snmptable -f  -w xml ',
#   },


);

##---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO GET
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_12356_FORTINET::GET_APPS =(

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_12356_FORTINET::METRICS=(

#FORTINET-FORTIGATE-MIB::fgSysCpuUsage.0 = Gauge32: 1
#FORTINET-FORTIGATE-MIB::fgSysMemUsage.0 = Gauge32: 55
#FORTINET-FORTIGATE-MIB::fgSysMemCapacity.0 = Gauge32: 454088
#FORTINET-FORTIGATE-MIB::fgSysDiskUsage.0 = Gauge32: 67
#FORTINET-FORTIGATE-MIB::fgSysDiskCapacity.0 = Gauge32: 3502
#FORTINET-FORTIGATE-MIB::fgSysSesCount.0 = Gauge32: 143
#FORTINET-FORTIGATE-MIB::fgSysLowMemUsage.0 = Gauge32: 59
#FORTINET-FORTIGATE-MIB::fgSysLowMemCapacity.0 = Gauge32: 454088


	{  'name'=> 'USO DE CPU (%)',   'oid'=>'FORTINET-FORTIGATE-MIB::fgSysCpuUsage.0', 'subtype'=>'fortigate_cpu_usage', 'class'=>'FORTINET', 'vlabel'=>'%', 'include'=>1, 'esp'=>'', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },
	{  'name'=> 'USO DE MEMORIA (%)',   'oid'=>'FORTINET-FORTIGATE-MIB::fgSysMemUsage.0', 'subtype'=>'fortigate_mem_usage', 'class'=>'FORTINET', 'vlabel'=>'%', 'include'=>1, 'esp'=>'', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },
	{  'name'=> 'USO DE MEMORIA BAJA (%)',   'oid'=>'FORTINET-FORTIGATE-MIB::fgSysLowMemUsage.0', 'subtype'=>'fortigate_lowmem_usage', 'class'=>'FORTINET', 'vlabel'=>'%', 'include'=>1, 'esp'=>'', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },
	{  'name'=> 'USO DE DISCO',   'oid'=>'FORTINET-FORTIGATE-MIB:fgSysDiskUsage.0|FORTINET-FORTIGATE-MIB::fgSysDiskCapacity.0', 'subtype'=>'fortigate_disk_usage', 'class'=>'FORTINET', 'vlabel'=>'MB', 'include'=>1, 'esp'=>'', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },
	{  'name'=> 'NUMERO DE SESIONES ACTIVAS',   'oid'=>'FORTINET-FORTIGATE-MIB::fgSysSesCount.0', 'subtype'=>'fortigate_ses_count', 'class'=>'FORTINET', 'vlabel'=>'num', 'include'=>1, 'esp'=>'', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_12356_FORTINET::METRICS_TAB=(

#FORTINET-FORTIGATE-MIB::fgFwPolID.1.8 = INTEGER: 8
#FORTINET-FORTIGATE-MIB::fgFwPolPktCount.1.8 = Counter32: 0
#FORTINET-FORTIGATE-MIB::fgFwPolByteCount.1.8 = Counter32: 0

   {  'name'=> 'TRAFICO EN POLICY',  'oid'=>'FORTINET-FORTIGATE-MIB::fgFwPolPktCount|FORTINET-FORTIGATE-MIB::fgFwPolByteCount', 'subtype'=>'fortigate_pol_traffic', 'class'=>'FORTINET', 'range'=>'FORTINET-FORTIGATE-MIB::fgFwPolStatsTable', 'get_iid'=>'fgFwPolID', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },


#FORTINET-MIB-280
   {  'name'=> 'USO DE CPU',  'oid'=>'FORTINET-MIB-280::fnHaStatsCpuUsage', 'subtype'=>'fortinet_cpu_usage', 'class'=>'FORTINET', 'range'=>'FORTINET-MIB-280::fnHaStatsTable', 'get_iid'=>'fnHaStatsSerial', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },
   {  'name'=> 'USO DE MEMORIA',  'oid'=>'FORTINET-MIB-280::fnHaStatsMemUsage', 'subtype'=>'fortinet_memory_usage', 'class'=>'FORTINET', 'range'=>'FORTINET-MIB-280::fnHaStatsTable', 'get_iid'=>'fnHaStatsSerial', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },
   {  'name'=> 'TRAFICO DE RED',  'oid'=>'FORTINET-MIB-280::fnHaStatsNetUsage', 'subtype'=>'fortinet_net_usage', 'class'=>'FORTINET', 'range'=>'FORTINET-MIB-280::fnHaStatsTable', 'get_iid'=>'fnHaStatsSerial', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },
   {  'name'=> 'SESIONES ACTIVAS',  'oid'=>'FORTINET-MIB-280::fnHaStatsSesCount', 'subtype'=>'fortinet_active_sessions', 'class'=>'FORTINET', 'range'=>'FORTINET-MIB-280::fnHaStatsTable', 'get_iid'=>'fnHaStatsSerial', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },
   {  'name'=> 'PAQUETES PROCESADOS',  'oid'=>'FORTINET-MIB-280::fnHaStatsPktCount', 'subtype'=>'fortinet_packets', 'class'=>'FORTINET', 'range'=>'FORTINET-MIB-280::fnHaStatsTable', 'get_iid'=>'fnHaStatsSerial', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },
   {  'name'=> 'BYTES PROCESADOS',  'oid'=>'FORTINET-MIB-280::fnHaStatsByteCount', 'subtype'=>'fortinet_bytes', 'class'=>'FORTINET', 'range'=>'FORTINET-MIB-280::fnHaStatsTable', 'get_iid'=>'fnHaStatsSerial', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },
   {  'name'=> 'ATAQUES EN 20 HORAS',  'oid'=>'FORTINET-MIB-280::fnHaStatsIdsCount', 'subtype'=>'fortinet_attacks', 'class'=>'FORTINET', 'range'=>'FORTINET-MIB-280::fnHaStatsTable', 'get_iid'=>'fnHaStatsSerial', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },
   {  'name'=> 'VIRUS EN 20 HORAS',  'oid'=>'FORTINET-MIB-280::fnHaStatsAvCount', 'subtype'=>'fortinet_virus', 'class'=>'FORTINET', 'range'=>'FORTINET-MIB-280::fnHaStatsTable', 'get_iid'=>'fnHaStatsSerial', 'itil_type'=>1, 'apptype'=>'NET.FORTINET' },

);


1;
__END__
