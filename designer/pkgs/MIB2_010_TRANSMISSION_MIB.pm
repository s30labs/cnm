#---------------------------------------------------------------------------
package MIB2_010_TRANSMISSION_MIB;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$MIB2_010_TRANSMISSION_MIB::ENTERPRISE_PREFIX='00000';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%MIB2_010_TRANSMISSION_MIB::TABLE_APPS =(

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
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_010_TRANSMISSION_MIB::METRICS=(

#	{  'name'=> 'CONEXIONES TCP ACTIVAS',   'oid'=>'F5-BIGIP-SYSTEM-MIB::sysTcpStatOpen.0', 'subtype'=>'f5big_tcp_active', 'class'=>'F5-BIGIP' },
#	{  'name'=> 'CONEXIONES TCP INACTIVAS',   'oid'=>'F5-BIGIP-SYSTEM-MIB::sysTcpStatCloseWait|F5-BIGIP-SYSTEM-MIB::sysTcpStatFinWait|F5-BIGIP-SYSTEM-MIB::sysTcpStatTimeWait', 'subtype'=>'f5big_tcp_inactive', 'class'=>'F5-BIGIP' },
#	{  'name'=> 'MIEMBROS TOTALES EN POOLS',   'oid'=>'F5-BIGIP-LOCAL-MIB::ltmPoolMemberNumber.0', 'subtype'=>'f5big_pools_tot_mem', 'class'=>'F5-BIGIP' },

#	{  'name'=> 'USO DE CPU (%)',   'oid'=>'', 'subtype'=>'cpq_cpu_status', 'class'=>'COMPAQ' },
	#{  'name'=> 'FALLOS EN DNS',   'oid'=>'ASYNCOS-MAIL-MIB::outstandingDNSRequests.0|ASYNCOS-MAIL-MIB::pendingDNSRequests.0', 'subtype'=>'ironport_dns_failures', 'class'=>'IRONPORT' },
	#{	'name'=> 'MEMORIA ASIGNADA',	'oid'=>'WINDOWS-NT-PERFORMANCE::memoryCommittedBytes.0|WINDOWS-NT-PERFORMANCE::memoryCommitLimit.0', 'subtype'=>'winnt_memory_committed_bytes', 'class'=>'WINDOWS-NT'},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid NO DEBE IR CUALIFICADO !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_010_TRANSMISSION_MIB::METRICS_TAB=(

	{	'name'=> 'TIEMPO DE CONEXION EN PEER',  'oid'=>'dialCtlPeerStatsConnectTime', 'subtype'=>'dial_peer_ctime', 'class'=>'DIAL-CONTROL', 'range'=>'DIAL-CONTROL-MIB::dialCtlPeerStatsTable', 'get_iid'=>'dialCtlPeerCfgEntry', 'itil_type' => 1, 'apptype'=>'NET.TRANS-MIB' },
	{	'name'=> 'LLAMADAS EN PEER',  'oid'=>'dialCtlPeerStatsSuccessCalls|dialCtlPeerStatsFailCalls|dialCtlPeerStatsAcceptCalls|dialCtlPeerStatsRefuseCalls', 'subtype'=>'dial_peer_calls', 'class'=>'DIAL-CONTROL', 'range'=>'DIAL-CONTROL-MIB::dialCtlPeerStatsTable', 'get_iid'=>'dialCtlPeerCfgEntry',  'itil_type' => 1, 'apptype'=>'NET.TRANS-MIB' },

#unknown(1), halfDuplex(2), fullDuplex(3)
   {  'name'=> 'RESUMEN DEL MODO DUPLEX DE LOS INTERFACES',  'oid'=>'dot3StatsDuplexStatus', 'subtype'=>'mib2_glob_duplex', 'class'=>'MIB2', 'range'=>'EtherLike-MIB::dot3StatsTable', 'get_iid'=>'dot3StatsIndex', 'itil_type'=>1, 'mtype'=>'STD_BASE',
'esp'=>'TABLE(MATCH)(fullDuplex)|TABLE(MATCH)(unknown)|TABLE(MATCH)(halfDuplex)', 'items'=>'fullDuplex|unknown|halfDuplex', 'apptype'=>'NET.MIB2'
},


#EtherLike-MIB::dot3StatsDuplexStatus

);


1;
__END__
