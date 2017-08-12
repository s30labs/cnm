#---------------------------------------------------------------------------
package ENT_21796_HWGROUP;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_21796_HWGROUP::ENTERPRISE_PREFIX='21796';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_21796_HWGROUP::TABLE_APPS =(

   'STE_SENSOR_TABLE' => {

      'col_filters' => '#text_filter,#select_filter,#text_filter,#numeric_filter,#text_filter,#numeric_filter,#numeric_filter',
      'col_widths' => '20.12.12.12.20.12.10',
      'col_sorting' => 'str.int.str.int.str.int.int',

      'oid_cols' => 'sensName_sensState_sensString_sensValue_sensSN_sensUnit_sensID',
      'oid_last' => 'STE-MIB::sensTable',
      'name' => 'VALORES DEL SENSOR',
      'descr' => 'Muestra la tablacon lainformacion reportada por el sensor',
      'xml_file' => '21796-STE-MIB-SENSOR-TABLE.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'HWGROUP',
      'aname'=>'app_hwg_ste_table',
      'range' => 'STE-MIB::sensTable',
      'enterprise' => '21796',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 21796-STE-MIB-SENSOR-TABLE.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.HWGROUP',
   },

);


#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO GET
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_21796_HWGROUP::GET_APPS =(

#  'GET_INFO' => {
#
#		items => [
#
#						{  'name'=> 'TIPO DE HARDWARE',   'oid'=>'IB-PLATFORMONE-MIB::ibHardwareType.0', 'esp'=>'' },
#						{  'name'=> 'NUMERO DE SERIE',   'oid'=>'IB-PLATFORMONE-MIB::ibSerialNumber.0', 'esp'=>'' },
#						{  'name'=> 'VERSION DE SOFTWARE',   'oid'=>'IB-PLATFORMONE-MIB::ibNiosVersion.0', 'esp'=>'' },
#		],
#		
#     	'name' => 'INFORMACION DEL EQUIPO',
#     	'descr' => 'Muestra informacion basica sobre el equipo',
#     	'xml_file' => '07779_INFOBLOX-get_info.xml',
#     	'params' => '[-n;IP;]',
#     	'ipparam' => '[-n;IP;]',
#     	'subtype'=>'INFOBLOX',
#     	'aname'=>'app_infoblox_get_info',
#	  	'range' => 'IB-PLATFORMONE-MIB::ibHardwareType.0',
#     	'enterprise' => '07779',  #5 CIFRAS !!!!
#     	'cmd' => '/opt/crawler/bin/libexec/snmptable -f 07779_INFOBLOX-get_info.xml -w xml ',
#  },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
# CREADA APLICACION TIPO GET:
#		00000-ENT_21796_HWGROUP-get_info.xml
#---------------------------------------------------------------------------
@ENT_21796_HWGROUP::METRICS=(

# El campo items solo se pone si va a ser distinto de oid


#   {  'name'=> 'ESTADO SERVICIO BGP',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.36', 'subtype'=>'ib_status_bgp', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID' },


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_21796_HWGROUP::METRICS_TAB=(

	{	'name'=> 'ESTADO DEL SENSOR',  'oid'=>'STE-MIB::sensState', 'subtype'=>'hwg_ste_status', 'class'=>'HWGROUP', 'range'=>'STE-MIB::sensTable', 'get_iid'=>'sensName', 'items'=>'Ok(1)|OutLo(2)|OutHi(3)|AlarmLo(4)|AlarmHi(5)|Inv(0)', 'esp'=>'MAP(1)(1,0,0,0,0,0)|MAP(2)(0,1,0,0,0,0)|MAP(3)(0,0,1,0,0,0)|MAP(4)(0,0,0,1,0,0)|MAP(5)(0,0,0,0,1,0)|MAP(0)(0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', , 'itil_type' => 3, 'apptype'=>'NET.HWGROUP' },

	{	'name'=> 'VALOR DEL SENSOR HWG',  'oid'=>'STE-MIB::sensValue', 'subtype'=>'hwg_ste_temp', 'class'=>'HWGROUP', 'range'=>'STE-MIB::sensTable', 'get_iid'=>'sensName', 'items'=>'Valor', 'esp'=>'o1/10', 'itil_type' => 1, 'apptype'=>'NET.HWGROUP' },

);


1;
__END__
