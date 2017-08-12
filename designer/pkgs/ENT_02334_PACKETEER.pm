#---------------------------------------------------------------------------
package ENT_02334_PACKETEER;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_02334_PACKETEER::ENTERPRISE_PREFIX='02334';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_02334_PACKETEER::TABLE_APPS =(

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
@ENT_02334_PACKETEER::METRICS=(

#	{  'name'=> 'CONEXIONES TCP ACTIVAS',   'oid'=>'F5-BIGIP-SYSTEM-MIB::sysTcpStatOpen.0', 'subtype'=>'f5big_tcp_active', 'class'=>'F5-BIGIP' },
#	{  'name'=> 'CONEXIONES TCP INACTIVAS',   'oid'=>'F5-BIGIP-SYSTEM-MIB::sysTcpStatCloseWait|F5-BIGIP-SYSTEM-MIB::sysTcpStatFinWait|F5-BIGIP-SYSTEM-MIB::sysTcpStatTimeWait', 'subtype'=>'f5big_tcp_inactive', 'class'=>'F5-BIGIP' },
#	{  'name'=> 'MIEMBROS TOTALES EN POOLS',   'oid'=>'F5-BIGIP-LOCAL-MIB::ltmPoolMemberNumber.0', 'subtype'=>'f5big_pools_tot_mem', 'class'=>'F5-BIGIP' },


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! ni oid ni get_iid DEBEN IR CUALIFICADOS !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_02334_PACKETEER::METRICS_TAB=(


#Habria que contemplar linkByteCountHi ==> Metrica ad-hoc ???
   {  'name'=> 'ACTIVIDAD (BYTES) EN EL LINK',  'oid'=>'PACKETEER-MIB::linkByteCount', 'subtype'=>'pkteer_link_bytes', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::linkTable', 'get_iid'=>'linkName', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },
   {  'name'=> 'ACTIVIDAD (PAQUETES POR TIPO) EN EL LINK',  'oid'=>'PACKETEER-MIB::linkPkts|PACKETEER-MIB::linkDataPkts', 'subtype'=>'pkteer_link_pkts', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::linkTable', 'get_iid'=>'linkName', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },

#Habria que contemplar linkReTxByteCountHi ==> Metrica ad-hoc ???
   {  'name'=> 'RETRANSMISIONES (BYTES) TCP EN EL LINK',  'oid'=>'PACKETEER-MIB::linkReTxByteCount', 'subtype'=>'pkteer_link_ret_bytes', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::linkTable', 'get_iid'=>'linkName', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },
   {  'name'=> 'RETRANSMISIONES (PAQUETES) TCP EN EL LINK',  'oid'=>'PACKETEER-MIB::linkReTxs|PACKETEER-MIB::linkReTxTosses', 'subtype'=>'pkteer_link_ret_pkts', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::linkTable', 'get_iid'=>'linkName', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },
   {  'name'=> 'CONEXIONES TCP MAXIMAS EN EL LINK',  'oid'=>'PACKETEER-MIB::linkPeakTcpConns', 'subtype'=>'pkteer_link_tcp_peak', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::linkTable', 'get_iid'=>'linkName', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },
   {  'name'=> 'CONEXIONES TCP EN EL LINK',  'oid'=>'PACKETEER-MIB::linkTcpConnInits|PACKETEER-MIB::linkTcpConnRefuses|PACKETEER-MIB::linkTcpConnIgnores|PACKETEER-MIB::linkTcpConnAborts', 'subtype'=>'pkteer_link_tcp', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::linkTable', 'get_iid'=>'linkName', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },

   {  'name'=> 'ACTIVIDAD (PAQUETES TOTALES) EN EL LINK',  'oid'=>'PACKETEER-MIB::linkTotalRxPkts|PACKETEER-MIB::linkTotalTxPkts', 'subtype'=>'pkteer_link_pkts_tot', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::linkTable', 'get_iid'=>'linkName', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },
   {  'name'=> 'PAQUETES PERDIDOS EN EL LINK',  'oid'=>'PACKETEER-MIB::linkRxPktDrops|PACKETEER-MIB::linkTxPktDrops', 'subtype'=>'pkteer_link_pkts_drop', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::linkTable', 'get_iid'=>'linkName', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },
   {  'name'=> 'ERRORES EN EL LINK',  'oid'=>'PACKETEER-MIB::linkRxErrors|PACKETEER-MIB::linkTxErrors', 'subtype'=>'pkteer_link_pkts_err', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::linkTable', 'get_iid'=>'linkName', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },



#Habria que contemplar classByteCountHi ==> Metrica ad-hoc ???
	{	'name'=> 'ACTIVIDAD (BYTES) EN LA CLASE',  'oid'=>'PACKETEER-MIB::classByteCount', 'subtype'=>'pkteer_class_bytes', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::classTable', 'get_iid'=>'className', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },
	{	'name'=> 'ACTIVIDAD (PAQUETES) EN LA CLASE',  'oid'=>'PACKETEER-MIB::classPkts|PACKETEER-MIB::classDataPkts', 'subtype'=>'pkteer_class_pkts', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::classTable', 'get_iid'=>'className', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },

#Habria que contemplar classReTxByteCountHi ==> Metrica ad-hoc ???
	{	'name'=> 'RETRANSMISIONES (BYTES) TCP EN LA CLASE',  'oid'=>'PACKETEER-MIB::classReTxByteCount', 'subtype'=>'pkteer_class_ret_bytes', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::classTable', 'get_iid'=>'className', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },
	{	'name'=> 'RETRANSMISIONES (PAQUETES) TCP EN LA CLASE',  'oid'=>'PACKETEER-MIB::classReTxs|PACKETEER-MIB::classReTxTosses', 'subtype'=>'pkteer_class_ret_pkts', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::classTable', 'get_iid'=>'className', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },
	{	'name'=> 'CONEXIONES TCP EN LA CLASE',  'oid'=>'PACKETEER-MIB::classTcpConnInits|PACKETEER-MIB::classTcpConnRefuses|PACKETEER-MIB::classTcpConnIgnores|PACKETEER-MIB::classTcpConnAborts', 'subtype'=>'pkteer_class_tcp', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::classTable', 'get_iid'=>'className', 'apptype'=>'NET.PACKETEER' },

	{	'name'=> 'TASA (bps) LA CLASE',  'oid'=>'PACKETEER-MIB::classCurrentRate', 'subtype'=>'pkteer_class_rate', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::classTable', 'get_iid'=>'className', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },
	{	'name'=> 'DURACION DE LAS CONEXIONES EN LA CLASE',  'oid'=>'PACKETEER-MIB::classPktExchangeTime', 'subtype'=>'pkteer_class_exchtime', 'class'=>'PACKETEER', 'range'=>'PACKETEER-MIB::classTable', 'get_iid'=>'className', 'itil_type'=>1, 'apptype'=>'NET.PACKETEER' },

);


1;
__END__
