#---------------------------------------------------------------------------
package ENT_03224_NETSCREEN;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_03224_NETSCREEN::ENTERPRISE_PREFIX='03224';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_03224_NETSCREEN::TABLE_APPS =(

#	'POOL INFO' => {
#
#		'oid_cols' => 'ltmPoolName_ltmPoolLbMode_ltmPoolActiveMemberCnt_ltmPoolMonitorRule_ltmPoolMemberCnt_ltmPoolEnabledState',
#		'oid_last' => 'F5-BIGIP-LOCAL-MIB::ltmPoolTable',
#		'name' => 'INFORMACION SOBRE LOS POOLS DEFINIDOS',
#		'descr' => 'Muestra informacion relevante sobre los pools definidos en el equipo',
#		'xml_file' => '03375_F5BIGIP_POOL_INFO.xml',
#		'params' => '[-n;IP;]',
#		'ipparam' => '[-n;IP;]',
#		'subtype'=>'CISCO-VOIP',
#		'aname'=>'app_f5bigip_pool_info',
#		'range' => 'F5-BIGIP-LOCAL-MIB::ltmPoolTable',
#		'enterprise' => '03375',  #5 CIFRAS !!!!
#		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 03375_F5BIGIP_POOL_INFO.xml -w xml ',
#	},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
# Colores para MAP: Verde, Azul, Rojo, Naranja
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_03224_NETSCREEN::METRICS=(

	{  'name'=> 'USO DE CPU (%)',   'oid'=>'NETSCREEN-RESOURCE-MIB::nsResCpuAvg.0|NETSCREEN-RESOURCE-MIB::nsResCpuLast1Min.0|NETSCREEN-RESOURCE-MIB::nsResCpuLast5Min.0|NETSCREEN-RESOURCE-MIB::nsResCpuLast15Min.0', 'subtype'=>'ns_cpu_usage_perc', 'class'=>'NETSCREEN', 'apptype'=>'NET.NETSCREEN' },

	{  'name'=> 'USO DE MEMORIA',   'oid'=>'NETSCREEN-RESOURCE-MIB::nsResMemAllocate.0|NETSCREEN-RESOURCE-MIB::nsResMemLeft.0|NETSCREEN-RESOURCE-MIB::nsResMemFrag.0', 'subtype'=>'ns_mem_usage', 'class'=>'NETSCREEN', 'apptype'=>'NET.NETSCREEN' },
	{  'name'=> 'USO DE SESIONES',   'oid'=>'NETSCREEN-RESOURCE-MIB::nsResSessAllocate.0|NETSCREEN-RESOURCE-MIB::nsResSessFailed.0|NETSCREEN-RESOURCE-MIB::nsResSessMaxium.0', 'subtype'=>'ns_session_usage', 'class'=>'NETSCREEN', 'apptype'=>'NET.NETSCREEN' },

	{  'name'=> 'USUARIOS ACTIVOS',   'oid'=>'NETSCREEN-UAC-MIB::nsUACActiveUsers.0', 'subtype'=>'ns_active_users', 'class'=>'NETSCREEN', 'apptype'=>'NET.NETSCREEN' },

#NETSCREEN-SET-URL-FILTER-MIB::nsSetUrlServerStatus.0
#nsSetUrlServerStatus OBJECT-TYPE
#  -- FROM       NETSCREEN-SET-URL-FILTER-MIB
#  SYNTAX        INTEGER {not-applicable(0), running(1), down(2)}

	{  'name'=> 'ESTADO DEL FILTRO WEB',   'oid'=>'NETSCREEN-SET-URL-FILTER-MIB::nsSetUrlServerStatus.0', 'subtype'=>'ns_url_filter_stat', 'class'=>'NETSCREEN', 'vlabel'=>'estado', 'include'=>1, 'items'=>'running(1)|N/A(2)|Down(3)', 'esp'=>'MAP(0)(0,1,0)|MAP(1)(1,0,0)|MAP(2)(0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 1, 'apptype'=>'NET.NETSCREEN' },

#	{  'name'=> '',   'oid'=>'', 'subtype'=>'ns_', 'class'=>'NETSCREEN' },



);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! ni oid ni get_iid DEBEN IR CUALIFICADOS !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_03224_NETSCREEN::METRICS_TAB=(

#power supply module's status: 0. Fail   1. Good   2. Not installed"

   {  'name'=> 'ESTADO DE LA FUENTE',  'oid'=>'NETSCREEN-CHASSIS-MIB::nsPowerStatus', 'subtype'=>'ns_power_status', 'class'=>'NETSCREEN', 'range'=>'NETSCREEN-CHASSIS-MIB::nsPowerTable', 'get_iid'=>'nsPowerDesc', 'itil_type'=>1,
'esp'=>'MAP(0)(0,0,1)|MAP(1)(1,0,0)|MAP(2)(0,1,0)', 'mtype'=>'STD_SOLID', 'items'=>'Good(1)|Fail(0)|Not Installed(2)' , 'apptype'=>'NET.NETSCREEN'
},

   {  'name'=> 'ESTADO DEL SLOT',  'oid'=>'NETSCREEN-CHASSIS-MIB::nsSlotStatus', 'subtype'=>'ns_slot_status', 'class'=>'NETSCREEN', 'range'=>'NETSCREEN-CHASSIS-MIB::nsSlotTable', 'get_iid'=>'nsSlotType', 'itil_type'=>1,
'esp'=>'MAP(0)(0,0,1)|MAP(1)(1,0,0)|MAP(2)(0,1,0)', 'mtype'=>'STD_SOLID', 'items'=>'Good(1)|Fail(0)|Not Installed(2)', 'apptype'=>'NET.NETSCREEN'
},
#V,A,R,N
#nsVpnMonTunnelState OBJECT-TYPE
#  -- FROM       NETSCREEN-VPN-MON-MIB
#  SYNTAX        INTEGER {down(0), up(1)}
# El orden en itms => verde|azul|rojo|naranja
# El mapeo v.ogigen -> (0,0,1) => (verde,azul,rojo)

   {  'name'=> 'ESTADO DEL TUNEL',  'oid'=>'NETSCREEN-VPN-MON-MIB::nsVpnMonTunnelState', 'subtype'=>'ns_tunnel_status', 'class'=>'NETSCREEN', 'range'=>'NETSCREEN-VPN-MON-MIB::nsVpnMonTable', 'get_iid'=>'nsVpnMonVpnName', 'itil_type'=>1,
'esp'=>'MAP(0)(0,0,1)|MAP(2)(0,1,0)|MAP(1)(1,0,0)', 'mtype'=>'STD_SOLID', 'items'=>'Up(1)|Unk(2)|Down(0)', 'apptype'=>'NET.NETSCREEN'
},


#   {  'name'=> '',  'oid'=>'', 'subtype'=>'', 'class'=>'NETSCREEN', 'range'=>'', 'get_iid'=>'', 'itil_type'=>1 },
);


1;
__END__
