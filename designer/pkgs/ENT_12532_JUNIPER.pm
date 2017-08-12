#---------------------------------------------------------------------------
package ENT_12532_JUNIPER;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_12532_JUNIPER::ENTERPRISE_PREFIX='12532';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_12532_JUNIPER::TABLE_APPS =(

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

);


#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO GET
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_12532_JUNIPER::GET_APPS =(

  'GET_INFO' => {

		items => [

						{  'name'=> 'TIPO DE HARDWARE',   'oid'=>'JUNIPER-IVE-MIB::productName.0', 'esp'=>'' },
						{  'name'=> 'VERSION DE SOFTWARE',   'oid'=>'JUNIPER-IVE-MIB::productVersion.0', 'esp'=>'' },
		],

		'oid_cols' => 'productName_productVersion',		
     	'name' => 'INFORMACION DEL EQUIPO',
     	'descr' => 'Muestra informacion basica sobre el equipo',
     	'xml_file' => '12532_JUNIPER-get_info.xml',
     	'params' => '[-n;IP;]',
     	'ipparam' => '[-n;IP;]',
     	'subtype'=>'JUNIPER',
     	'aname'=>'app_juniper_get_info',
	  	'range' => 'JUNIPER-IVE-MIB::productName.0',
     	'enterprise' => '12532',  #5 CIFRAS !!!!
     	'cmd' => '/opt/crawler/bin/libexec/snmptable -f 12532_JUNIPER-get_info.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.JUNIPER',
  },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
# CREADA APLICACION TIPO GET:
#		00000-ENT_12532_JUNIPER-get_info.xml
# El campo items solo se pone si va a ser distinto de oid
#---------------------------------------------------------------------------
@ENT_12532_JUNIPER::METRICS=(

#JUNIPER-IVE-MIB::logFullPercent.0 = Gauge32: 6
#JUNIPER-IVE-MIB::signedInWebUsers.0 = Gauge32: 61
#JUNIPER-IVE-MIB::signedInMailUsers.0 = Gauge32: 0
#
#JUNIPER-IVE-MIB::iveCpuUtil.0 = Gauge32: 2
#JUNIPER-IVE-MIB::iveMemoryUtil.0 = Gauge32: 54
#JUNIPER-IVE-MIB::iveConcurrentUsers.0 = Gauge32: 0
#JUNIPER-IVE-MIB::clusterConcurrentUsers.0 = Gauge32: 61
#JUNIPER-IVE-MIB::iveSwapUtil.0 = Gauge32: 0
#JUNIPER-IVE-MIB::diskFullPercent.0 = Gauge32: 15



	{  'name'=> 'OCUPACION DEL LOG',   'oid'=>'JUNIPER-IVE-MIB::logFullPercent.0', 'subtype'=>'juniper_log_file', 'class'=>'JUNIPER', 'vlabel'=>'%', 'include'=>1, 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.JUNIPER' },

	{  'name'=> 'USUARIOS DE WEB FIRMADOS',   'oid'=>'JUNIPER-IVE-MIB::signedInWebUsers.0', 'subtype'=>'juniper_sign_webu', 'class'=>'JUNIPER', 'vlabel'=>'usuarios', 'include'=>1, 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.JUNIPER' },
	{  'name'=> 'USUARIOS DE CORREO FIRMADOS',   'oid'=>'JUNIPER-IVE-MIB::signedInMailUsers.0', 'subtype'=>'juniper_sign_mailu', 'class'=>'JUNIPER', 'vlabel'=>'usuarios', 'include'=>1, 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.JUNIPER' },


	{  'name'=> 'USO DE CPU',   'oid'=>'JUNIPER-IVE-MIB::iveCpuUtil.0', 'subtype'=>'juniper_cpu_usage', 'class'=>'JUNIPER', 'vlabel'=>'num', 'include'=>1, 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.JUNIPER' },
	{  'name'=> 'USO DE MEMORIA',   'oid'=>'JUNIPER-IVE-MIB::iveMemoryUtil.0', 'subtype'=>'juniper_mem_usage', 'class'=>'JUNIPER', 'vlabel'=>'num', 'include'=>1, 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.JUNIPER' },

	{  'name'=> 'USUARIOS CONCURRENTES',   'oid'=>'JUNIPER-IVE-MIB::iveConcurrentUsers.0', 'subtype'=>'juniper_users', 'class'=>'JUNIPER', 'vlabel'=>'num', 'include'=>1, 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.JUNIPER' },
	{  'name'=> 'USUARIOS CONCURRENTES DEL CLUSTER',   'oid'=>'JUNIPER-IVE-MIB::clusterConcurrentUsers.0', 'subtype'=>'juniper_cluster_users', 'class'=>'JUNIPER', 'vlabel'=>'num', 'include'=>1, 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.JUNIPER' },
	{  'name'=> 'USO DE SWAP',   'oid'=>'JUNIPER-IVE-MIB::iveSwapUtil.0', 'subtype'=>'juniper_swap_usage', 'class'=>'JUNIPER', 'vlabel'=>'num', 'include'=>1, 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.JUNIPER' },
	{  'name'=> 'USO DE DISCO',   'oid'=>'JUNIPER-IVE-MIB::diskFullPercent.0', 'subtype'=>'juniper_disk_usage', 'class'=>'JUNIPER', 'vlabel'=>'num', 'include'=>1, 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.JUNIPER' },


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_12532_JUNIPER::METRICS_TAB=(

#	{	'name'=> 'ALERTAS POR PROTOCOLO',  'oid'=>'TPT-POLICY::protocolAlertCount', 'subtype'=>'tip_alerts_proto', 'class'=>'TIPPING-POINT', 'range'=>'TPT-POLICY::alertsByProtocolTable', 'get_iid'=>'alertProtocol' },

#	{	'name'=> 'FALLOS AL ACTUALIZAR',  'oid'=>'updateFailures', 'subtype'=>'ironport_update_fail', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
#	{	'name'=> 'TASA DE ACTUALIZACIONES',  'oid'=>'updates', 'subtype'=>'ironport_update_rate', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
# 	{	'name'=> '',  'oid'=>'', 'subtype'=>'ironport_temperature', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::', 'get_iid'=>'ASYNCOS-MAIL-MIB::' },

);


1;
__END__
