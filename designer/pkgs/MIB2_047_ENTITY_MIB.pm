#---------------------------------------------------------------------------
package MIB2_047_ENTITY_MIB;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$MIB2_047_ENTITY_MIB::ENTERPRISE_PREFIX='00000';


#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

%MIB2_047_ENTITY_MIB::TABLE_APPS =(
	'TABLA DE COMPONENTES FISICOS' => {

      'col_filters' => '#text_filter.#text_filter.#select_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#select_filter',
      'col_widths' => '15.35.15.20.17.17.17.20.17',
      'col_sorting' => 'str.str.str.str.str.str.str.str.str',

		'oid_cols' => 'entPhysicalContainedIn_entPhysicalDescr_entPhysicalClass_entPhysicalSerialNum_entPhysicalSoftwareRev_entPhysicalFirmwareRev_entPhysicalModelName_entPhysicalVendorType_entPhysicalIsFRU',
		'oid_last' => 'ENTITY-MIB::entPhysicalTable',
		'name' => 'TABLA DE COMPONENTES FISICOS',
		'descr' => 'Muestra los componentes fisicos del equipo',
		'xml_file' => '00000-47-ENTITY_PHYS_TABLE.xml',
		'params' => '[-n;IP;]',
		'ipparam' => '[-n;IP;]',
		'subtype'=>'ENTITY-MIB',
		'aname'=>'app_ent_phys_table',
		'range' => 'ENTITY-MIB::entPhysicalTable',
		'enterprise' => '00000',  #5 CIFRAS !!!!
		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-47-ENTITY_PHYS_TABLE.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.MIB2',
	},

#                      'entPhysicalHardwareRev' => '',
#                      'entPhysicalIsFRU' => '2',
#                      'entPhysicalAssetID' => '',
#                      'entPhysicalDescr' => 'Switch 2 - WS-C3750-48P - Power Supply 0',
#                      'entPhysicalContainedIn' => '2001',
#                      'entPhysicalSerialNum' => 'DTN1323443D',
#                      'entPhysicalSoftwareRev' => '',
#                      'entPhysicalClass' => '6',
#                      'entPhysicalParentRelPos' => '2',
#                      'entPhysicalAlias' => '',
#                      'entPhysicalMfgName' => '',
#                      'entPhysicalName' => 'Switch 2 - WS-C3750-48P - Power Supply 0',
#                      'entPhysicalVendorType' => '.1.3.6.1.4.1.9.12.3.1.6.95',
#                      'entPhysicalModelName' => '',
#                      'entPhysicalFirmwareRev' => ''


   'TABLA DE COMPONENTES LOGICOS' => {

      'col_filters' => '#text_filter.#select_filter.#text_filter.#text_filter',
      'col_widths' => '25.20.20.20',
      'col_sorting' => 'str.str.str.str',

      'oid_cols' => 'entLogicalDescr_entLogicalType_entLogicalCommunity_entLogicalContextName',

      'oid_last' => 'ENTITY-MIB::entLogicalTable',
      'name' => 'TABLA DE COMPONENTES LOGICOS',
      'descr' => 'Muestra los componentes logicos del equipo',
      'xml_file' => '00000-47-ENTITY_LOGIC_TABLE.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'ENTITY-MIB',
      'aname'=>'app_ent_logic_table',
      'range' => 'ENTITY-MIB::entLogicalTable',
      'enterprise' => '00000',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-47-ENTITY_LOGIC_TABLE.xml -w xml ',
      'itil_type' => 1,    'apptype'=>'NET.MIB2',
   },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_047_ENTITY_MIB::METRICS=(

#upsInputLineBads  Wrong Type (should be Counter32): NULL
#upsOutputFrequency  ??
#upsBypassFrequency  ??
#upsAlarmsPresent Wrong Type (should be Gauge32 or Unsigned32): Counter32: 0

#	{  'name'=> 'TEMPERATURA DE LA BATERIA',     'oid'=>'UPS-MIB::upsBatteryTemperature.0', 'subtype'=>'ups_temperature', 'class'=>'UPS-MIB', 'vlabel'=>'Grados', 'include'=>1 , 'items'=>'Grados Centigrados', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },
#	{  'name'=> 'NUMERO DE LINEAS',     'oid'=>'UPS-MIB::upsInputNumLines.0|UPS-MIB::upsOutputNumLines.0|UPS-MIB::upsBypassNumLines.0', 'subtype'=>'ups_num_lines', 'class'=>'UPS-MIB', 'vlabel'=>'num', 'include'=>0, 'items'=>'Lineas de Entrada|Lineas de Salida|Lineas de Bypass', 'itil_type' => 1, 'apptype'=>'NET.UPS-MIB' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_047_ENTITY_MIB::METRICS_TAB=(

   {  'name'=> 'COMPONENTES FISICOS',  'oid'=>'entPhysicalClass', 'subtype'=>'mib2_ent_phy_parts', 'class'=>'MIB2', 'range'=>'ENTITY-MIB::entPhysicalTable', 'get_iid'=>'entPhysicalName', 'itil_type'=>2, 'mtype'=>'STD_BASE',
'esp'=>'TABLE(MATCH)([3;4])|TABLE(MATCH)(6)|TABLE(MATCH)([1;2])|TABLE(MATCH)(7)|TABLE(MATCH)(12)|TABLE(MATCH)(8)|TABLE(MATCH)(9)|TABLE(MATCH)(10)|TABLE(MATCH)(5)|TABLE(MATCH)(11)|TABLE(MATCH)([1;2;3;4;5;6;7;8;9;10;11;12])', 'items'=>'chassis-bplane|powerSup|unk-other|fan|cpu|sensor|module|port|container|stack|all', 'apptype'=>'NET.MIB2'
},

#    SYNTAX      INTEGER  {
#       other(1),
#       unknown(2),
#       chassis(3),
#       backplane(4),
#       container(5),     -- e.g., chassis slot or daughter-card holder
#       powerSupply(6),
#       fan(7),
#       sensor(8),
#       module(9),        -- e.g., plug-in card or daughter-card
#       port(10),
#       stack(11),        -- e.g., stack of multiple chassis entities
#       cpu(12)
#    }


);


1;
__END__
