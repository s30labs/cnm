#---------------------------------------------------------------------------
package MIB2_105_POE_MIB;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$MIB2_105_POE_MIB::ENTERPRISE_PREFIX='00000';


#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------

%MIB2_105_POE_MIB::TABLE_APPS =(

#POWER-ETHERNET-MIB::pethMainPsePower.1 = Gauge32: 370
#POWER-ETHERNET-MIB::pethMainPsePower.2 = Gauge32: 370
#POWER-ETHERNET-MIB::pethMainPseOperStatus.1 = INTEGER: 1
#POWER-ETHERNET-MIB::pethMainPseOperStatus.2 = INTEGER: 1
#POWER-ETHERNET-MIB::pethMainPseConsumptionPower.1 = Gauge32: 37
#POWER-ETHERNET-MIB::pethMainPseConsumptionPower.2 = Gauge32: 295
#POWER-ETHERNET-MIB::pethMainPseUsageThreshold.1 = INTEGER: 0
#POWER-ETHERNET-MIB::pethMainPseUsageThreshold.2 = INTEGER: 0
#POWER-ETHERNET-MIB::pethNotificationControlEnable.1 = INTEGER: 1
#POWER-ETHERNET-MIB::pethNotificationControlEnable.2 = INTEGER: 1

	'FUENTES DE POTENCIA' => {

      'col_filters' => '#text_filter.#select_filter.#text_filter.#text_filter.#select_filter',
      'col_widths' => '20.20.20.20.20',
      'col_sorting' => 'str.str.str.str.str',

		'oid_cols' => 'pethMainPsePower_pethMainPseOperStatus_pethMainPseConsumptionPower_pethMainPseUsageThreshold_pethNotificationControlEnable',
		'oid_last' => 'POWER-ETHERNET-MIB::pethMainPseTable',
		'name' => 'FUENTES DE POTENCIA',
		'descr' => 'Muestra el consumo de las fuentes de potencia del equipo',
		'xml_file' => '00000-105-POE_PSE_POWER.xml',
		'params' => '[-n;IP;]',
		'ipparam' => '[-n;IP;]',
		'subtype'=>'POWER-ETHERNET-MIB',
		'aname'=>'app_poe_psu_usage',
		'range' => 'POWER-ETHERNET-MIB::pethMainPseTable',
		'enterprise' => '00000',  #5 CIFRAS !!!!
		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-105-POE_PSE_POWER.xml -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.MIB2',
	},


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_105_POE_MIB::METRICS=(

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
@MIB2_105_POE_MIB::METRICS_TAB=(

#POWER-ETHERNET-MIB::pethMainPsePower.1 = Gauge32: 370
#POWER-ETHERNET-MIB::pethMainPsePower.2 = Gauge32: 370
#POWER-ETHERNET-MIB::pethMainPseOperStatus.1 = INTEGER: 1
#POWER-ETHERNET-MIB::pethMainPseOperStatus.2 = INTEGER: 1
#POWER-ETHERNET-MIB::pethMainPseConsumptionPower.1 = Gauge32: 37
#POWER-ETHERNET-MIB::pethMainPseConsumptionPower.2 = Gauge32: 295
#POWER-ETHERNET-MIB::pethMainPseUsageThreshold.1 = INTEGER: 0
#POWER-ETHERNET-MIB::pethMainPseUsageThreshold.2 = INTEGER: 0
#POWER-ETHERNET-MIB::pethNotificationControlEnable.1 = INTEGER: 1
#POWER-ETHERNET-MIB::pethNotificationControlEnable.2 = INTEGER: 1

#     pethMainPseOperStatus OBJECT-TYPE
#       SYNTAX INTEGER   {
#               on(1),
#               off(2),
#               faulty(3)
#          }
#       MAX-ACCESS  read-only
#       STATUS      current
#       DESCRIPTION
#               "The operational status of the main PSE."
#       ::= { pethMainPseEntry 3 }

   {  'name'=> 'ESTADO DE LA FUENTE',   'oid'=>'POWER-ETHERNET-MIB::pethMainPseOperStatus', 'subtype'=>'poe_pse_status', 'class'=>'MIB2', 'range'=>'POWER-ETHERNET-MIB::pethMainPseTable', 'vlabel'=>'estado', 'get_iid'=>'pethMainPseGroupIndex', 'include'=>'1', 'items'=>'on(1)|off(2)|faulty(3)|unk', 'esp'=>'MAP(1)(1,0,0,0)|MAP(2)(0,1,0,0)|MAP(3)(0,0,1,0)|MAP(4)(0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 1, 'apptype'=>'NET.MIB2' },

   {  'name'=> 'CONSUMO DE LA FUENTE',   'oid'=>'POWER-ETHERNET-MIB::pethMainPseConsumptionPower|POWER-ETHERNET-MIB::pethMainPsePower', 'subtype'=>'poe_pse_usage', 'class'=>'MIB2', 'range'=>'POWER-ETHERNET-MIB::pethMainPseTable', 'vlabel'=>'Watt', 'get_iid'=>'pethMainPseGroupIndex', 'include'=>'1', 'items'=>'pethMainPseConsumptionPower|pethMainPsePower', 'esp'=>'', 'mtype'=>'STD_SOLID', 'itil_type' => 1, 'apptype'=>'NET.MIB2' },
   {  'name'=> 'CONSUMO DE LA FUENTE (%)',   'oid'=>'POWER-ETHERNET-MIB::pethMainPsePower|POWER-ETHERNET-MIB::pethMainPseConsumptionPower', 'subtype'=>'poe_pse_usagep', 'class'=>'MIB2', 'range'=>'POWER-ETHERNET-MIB::pethMainPseTable', 'vlabel'=>'Watt', 'get_iid'=>'pethMainPseGroupIndex', 'include'=>'1', 'items'=>'pethMainPsePower|pethMainPseConsumptionPower', 'esp'=>'100*o2/o1', 'mtype'=>'STD_SOLID', 'itil_type' => 1, 'apptype'=>'NET.MIB2' },


#POWER-ETHERNET-MIB::pethPsePortPowerClassifications
#pethPsePortPowerClassifications OBJECT-TYPE
#  -- FROM       POWER-ETHERNET-MIB
#  SYNTAX        INTEGER {class0(1), class1(2), class2(3), class3(4), class4(5)}
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   "Classification is a way to tag different terminals on the
#        Power over LAN network according to their power consumption.
#        Devices such as IP telephones, WLAN access points and others,
#        will be classified according to their power requirements.
#
#        The meaning of the classification labels is defined in the
#        IEEE specification.
#
#       This variable is valid only while a PD is being powered,
#        that is, while the attribute pethPsePortDetectionStatus
#        is reporting the enumeration deliveringPower."
#::= { iso(1) org(3) dod(6) internet(1) mgmt(2) mib-2(1) powerEthernetMIB(105) pethObjects(1) pethPsePortTable(1) pethPsePortEntry(1) 10 }
#
   {  'name'=> 'CLASES DE POTENCIA CONECTADAS',  'oid'=>'pethPsePortPowerClassifications', 'subtype'=>'poe_class_types', 'class'=>'MIB2', 'range'=>'POWER-ETHERNET-MIB::pethPsePortTable', 'get_iid'=>'pethPsePortIndex', 'itil_type'=>1, 'mtype'=>'STD_BASE',
'esp'=>'TABLE(MATCH)(1)|TABLE(MATCH)(2)|TABLE(MATCH)(3)|TABLE(MATCH)(4)|TABLE(MATCH)(5)', 'items'=>'class0(1)|class1(2)|class2(3)|class3(4)|class4(5)', 'apptype'=>'NET.MIB2' },

#POWER-ETHERNET-MIB::pethPsePortOverLoadCounter
#pethPsePortOverLoadCounter OBJECT-TYPE
#  -- FROM       POWER-ETHERNET-MIB
#  SYNTAX        Counter32
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   "This counter is incremented when the PSE state diagram
#             enters the state ERROR_DELAY_OVER."
#::= { iso(1) org(3) dod(6) internet(1) mgmt(2) mib-2(1) powerEthernetMIB(105) pethObjects(1) pethPsePortTable(1) pethPsePortEntry(1) 13 }
#

);


1;
__END__
