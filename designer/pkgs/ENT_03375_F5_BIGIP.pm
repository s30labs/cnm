#---------------------------------------------------------------------------
package ENT_03375_F5_BIGIP;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_03375_F5_BIGIP::ENTERPRISE_PREFIX='03375';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_03375_F5_BIGIP::TABLE_APPS =(

	'POOL INFO' => {

      'col_filters' => '#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#select_filter',
      'col_widths' => '25.25.25.25.25.25',
      'col_sorting' => 'str.str.str.str.str.int',

		'oid_cols' => 'ltmPoolName_ltmPoolLbMode_ltmPoolActiveMemberCnt_ltmPoolMonitorRule_ltmPoolMemberCnt_ltmPoolEnabledState',
		'oid_last' => 'F5-BIGIP-LOCAL-MIB::ltmPoolTable',
		'name' => 'INFORMACION SOBRE LOS POOLS DEFINIDOS',
		'descr' => 'Muestra informacion relevante sobre los pools definidos en el equipo',
		'xml_file' => '03375_F5BIGIP_POOL_INFO.xml',
		'params' => '[-n;IP;]',
		'ipparam' => '[-n;IP;]',
		'subtype'=>'F5NETWORKS',
		'aname'=>'app_f5bigip_pool_info',
		'range' => 'F5-BIGIP-LOCAL-MIB::ltmPoolTable',
		'enterprise' => '03375',  #5 CIFRAS !!!!
		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 03375_F5BIGIP_POOL_INFO.xml -w xml ',
		'itil_type' => 1, 	'apptype'=>'NET.F5NETWORKS',
	},

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_03375_F5_BIGIP::METRICS=(

	{  'name'=> 'CONEXIONES TCP ACTIVAS',   'oid'=>'F5-BIGIP-SYSTEM-MIB::sysTcpStatOpen.0', 'subtype'=>'f5big_tcp_active', 'class'=>'F5-BIGIP', 'itil_type' => 1, 'apptype'=>'NET.F5NETWORKS' },
	{  'name'=> 'CONEXIONES TCP INACTIVAS',   'oid'=>'F5-BIGIP-SYSTEM-MIB::sysTcpStatCloseWait|F5-BIGIP-SYSTEM-MIB::sysTcpStatFinWait|F5-BIGIP-SYSTEM-MIB::sysTcpStatTimeWait', 'subtype'=>'f5big_tcp_inactive', 'class'=>'F5-BIGIP', 'itil_type' => 1, 'apptype'=>'NET.F5NETWORKS' },
	{  'name'=> 'MIEMBROS TOTALES EN POOLS',   'oid'=>'F5-BIGIP-LOCAL-MIB::ltmPoolMemberNumber.0', 'subtype'=>'f5big_pools_tot_mem', 'class'=>'F5-BIGIP', 'itil_type' => 1, 'apptype'=>'NET.F5NETWORKS' },
);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid NO DEBE IR CUALIFICADO !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_03375_F5_BIGIP::METRICS_TAB=(

	{	'name'=> 'CPU - TEMPERATURA',  'oid'=>'sysCpuTemperature', 'subtype'=>'f5big_cpu_temp', 'class'=>'F5-BIGIP', 'range'=>'F5-BIGIP-SYSTEM-MIB::sysCpuTable', 'get_iid'=>'sysCpuIndex', 'itil_type' => 1 , 'apptype'=>'NET.F5NETWORKS'},
	{	'name'=> 'CPU - VELOCIDAD VENTILADORES',  'oid'=>'sysCpuFanSpeed', 'subtype'=>'f5big_cpu_fans', 'class'=>'F5-BIGIP', 'range'=>'F5-BIGIP-SYSTEM-MIB::sysCpuTable', 'get_iid'=>'sysCpuIndex', 'itil_type' => 1, 'apptype'=>'NET.F5NETWORKS' },
	{	'name'=> 'CHASIS - VELOCIDAD VENTILADORES',  'oid'=>'sysChassisFanSpeed', 'subtype'=>'f5big_chas_fans', 'class'=>'F5-BIGIP', 'range'=>'F5-BIGIP-SYSTEM-MIB::sysChassisFanTable', 'get_iid'=>'sysChassisFanIndex', 'itil_type' => 1, 'apptype'=>'NET.F5NETWORKS' },
	{	'name'=> 'CHASIS - ESTADO DE LOS VENTILADORES',  'oid'=>'sysChassisFanStatus', 'subtype'=>'f5big_chas_fan_stat', 'class'=>'F5-BIGIP', 'range'=>'F5-BIGIP-SYSTEM-MIB::sysChassisFanTable', 'get_iid'=>'sysChassisFanIndex', 'itil_type' => 1, 'apptype'=>'NET.F5NETWORKS' },
	{	'name'=> 'CHASIS - ESTADO DE LA FUENTE ALIMENTACION',  'oid'=>'sysChassisPowerSupplyStatus', 'subtype'=>'f5big_chas_power_stat', 'class'=>'F5-BIGIP', 'range'=>'F5-BIGIP-SYSTEM-MIB::sysChassisPowerSupplyTable', 'get_iid'=>'sysChassisPowerSupplyIndex', 'itil_type' => 1, 'apptype'=>'NET.F5NETWORKS' },
	{	'name'=> 'CHASIS - TEMPERATURA DE SENSOR',  'oid'=>'sysChassisTempTemperature', 'subtype'=>'f5big_chas_temp', 'class'=>'F5-BIGIP', 'range'=>'F5-BIGIP-SYSTEM-MIB::sysChassisTempTable', 'get_iid'=>'sysChassisTempIndex', 'itil_type' => 1, 'apptype'=>'NET.F5NETWORKS' },

	{	'name'=> 'MIEMBROS ACTIVOS EN POOL',  'oid'=>'ltmPoolActiveMemberCnt|ltmPoolMemberCnt', 'subtype'=>'f5big_pool_active', 'class'=>'F5-BIGIP', 'range'=>'F5-BIGIP-LOCAL-MIB::ltmPoolTable', 'get_iid'=>'ltmPoolName', 'itil_type' => 1, 'apptype'=>'NET.F5NETWORKS' },
	{	'name'=> 'ESTADO DEL POOL',  'oid'=>'ltmPoolStatusAvailState|ltmPoolStatusEnabledState', 'subtype'=>'f5big_pool_avail_stat', 'class'=>'F5-BIGIP', 'range'=>'F5-BIGIP-LOCAL-MIB::ltmPoolStatusTable', 'get_iid'=>'ltmPoolStatusName', 'itil_type' => 1, 'apptype'=>'NET.F5NETWORKS' },

);


1;
__END__
