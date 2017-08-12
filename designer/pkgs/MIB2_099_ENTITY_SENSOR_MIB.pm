#---------------------------------------------------------------------------
package MIB2_099_ENTITY_SENSOR_MIB;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$MIB2_099_ENTITY_SENSOR_MIB::ENTERPRISE_PREFIX='00000';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%MIB2_099_ENTITY_SENSOR_MIB::TABLE_APPS =(

#	'TABLA DE INTERFACES OSPF' => {
#
#      'col_filters' => '#text_filter.#text_filter.#select_filter.#select_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter.#text_filter',
#      'col_widths' => '20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20.20',
#      'col_sorting' => 'str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str.str',
#
#		'oid_cols' => 'ospfIfIpAddress_ospfAddressLessIf_ospfIfAreaId_ospfIfType_ospfIfAdminStat_ospfIfRtrPriority_ospfIfTransitDelay_ospfIfRetransInterval_ospfIfHelloInterval_ospfIfRtrDeadInterval_ospfIfPollInterval_ospfIfState_ospfIfDesignatedRouter_ospfIfBackupDesignatedRouter_ospfIfEvents_ospfIfAuthKey_ospfIfStatus_ospfIfMulticastForwarding_ospfIfDemand_ospfIfAuthType',
#		'oid_last' => 'OSPF-MIB::ospfIfTable',
#		'name' => 'OSPF - TABLA DE INTERFACES',
#		'descr' => 'Muestra la tabla de interfaces de desde el punto de vista del protocolo OSPF',
#		'xml_file' => '00000-OSPF-MIB_INTERFACES_TABLE.xml',
#		'params' => '[-n;IP;]',
#		'ipparam' => '[-n;IP;]',
#		'subtype'=>'MIB2-OSPF',
#		'aname'=>'app_mib2_ospf_interfaces_table',
#		'range' => 'OSPF-MIB::ospfIfTable',
#		'enterprise' => '00000',  #5 CIFRAS !!!!
#		'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-OSPF-MIB_INTERFACES_TABLE.xml -w xml ',
#		'itil_type' => 1,		'apptype'=>'NET.OSPF-MIB', 
#	},

);

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_099_ENTITY_SENSOR_MIB::METRICS=(

   {  'name'=> 'CAMBIOS DE TOPOLOGIA SPANNING TREE',      'oid'=>'BRIDGE-MIB::dot1dStpTopChanges.0', 'subtype'=>'mib2_stp_top_change', 'class'=>'BRIDGE-MIB', 'include'=>'0', 'itil_type' => 1, 'apptype'=>'NET.BRIDGE-MIB' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_099_ENTITY_SENSOR_MIB::METRICS_TAB=(

#ENTITY-SENSOR-MIB::entPhySensorOperStatus
#entPhySensorOperStatus OBJECT-TYPE
#  -- FROM       ENTITY-SENSOR-MIB
#  -- TEXTUAL CONVENTION EntitySensorStatus
#  SYNTAX        INTEGER { ok(1), unavailable(2), nonoperational(3) }
#  MAX-ACCESS    read-only
#  STATUS        current
#  DESCRIPTION   "The operational status of the sensor."
#::= { iso(1) org(3) dod(6) internet(1) mgmt(2) mib-2(1) entitySensorMIB(99) entitySensorObjects(1) entPhySensorTable(1) entPhySensorEntry(1) 5 }

# verde|azul|rojo|naranja
# Si ok = 1 tiene que ser verde ==> MAP(1)(1,0,0)
#----------------------------------------------------------------------------
   {  'name'=> 'ESTADO DE SENSOR',   'oid'=>'ENTITY-SENSOR-MIB::entPhySensorOperStatus', 'subtype'=>'entity_sensor_stat', 'class'=>'ENTITY-SENSOR-MIB', 'range'=>'ENTITY-SENSOR-MIB::entPhySensorTable', 'vlabel'=>'estado', 'get_iid'=>'', 'include'=>'0', 'items'=>'ok(1)|unavailable(2)|nonoperational(3)   forwarding(5)|disabled(1)|blocking(2)|broken(6)|listening(3)|learning(4)', 'esp'=>'MAP(1)(1,0,0)|MAP(2)(0,1,0)|MAP(3)(0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.ENT_SENSOR-MIB' },

);



#---------------------------------------------------------------------------
@MIB2_099_ENTITY_SENSOR_MIB::REMOTE_ALERTS=(

);

1;
__END__
