#---------------------------------------------------------------------------
package MIB2_017_BRIDGE_MIB;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$MIB2_017_BRIDGE_MIB::ENTERPRISE_PREFIX='00000';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%MIB2_017_BRIDGE_MIB::TABLE_APPS =(

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
@MIB2_017_BRIDGE_MIB::METRICS=(

   {  'name'=> 'CAMBIOS DE TOPOLOGIA SPANNING TREE',      'oid'=>'BRIDGE-MIB::dot1dStpTopChanges.0', 'subtype'=>'mib2_stp_top_change', 'class'=>'BRIDGE-MIB', 'include'=>'0', 'itil_type' => 1, 'apptype'=>'NET.BRIDGE-MIB' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_017_BRIDGE_MIB::METRICS_TAB=(

#{disabled(1), blocking(2), listening(3), learning(4), forwarding(5), broken(6)
# verde|azul|rojo|naranja
# Si forwarding = 5 tiene que ser verde ==> MAP(5)(1,0,0,0,0,0)
# Se define ProvisionLite/stp_port_status.pm para identificar los puertos segun ifIndex
#----------------------------------------------------------------------------
	{  'name'=> 'ESTADO STP DEL PUERTO',   'oid'=>'BRIDGE-MIB::dot1dStpPortState', 'subtype'=>'stp_port_status', 'class'=>'BRIDGE-MIB', 'range'=>'BRIDGE-MIB::dot1dStpPortTable', 'vlabel'=>'estado', 'get_iid'=>'dot1dStpPort', 'include'=>'0', 'items'=>'forwarding(5)|disabled(1)|blocking(2)|broken(6)|listening(3)|learning(4)', 'esp'=>'MAP(5)(1,0,0,0,0,0)|MAP(1)(0,1,0,0,0,0)|MAP(2)(0,0,1,0,0,0)|MAP(6)(0,0,0,1,0,0)|MAP(3)(0,0,0,0,1,0)|MAP(4)(0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.BRIDGE-MIB' },

);



#---------------------------------------------------------------------------
@MIB2_017_BRIDGE_MIB::REMOTE_ALERTS=(

   {  'type'=>'snmp', 'subtype'=>'BRIDGE-MIB::newRoot', 'class'=>'BRIDGE-MIB',
      'descr'=>'NUEVO ROOT DE SPANNING TREE', 'severity'=>'3', 'enterprise'=>'mib-2.17',
      'vardata' =>'',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.BASE', 'itil_type'=>'1'  },

   {  'type'=>'snmp', 'subtype'=>'BRIDGE-MIB::topologyChange', 'class'=>'BRIDGE-MIB',
      'descr'=>'CAMBIO DE TOPOLOGIA DE SPANNING TREE', 'severity'=>'3', 'enterprise'=>'mib-2.17',
      'vardata' =>'',
      'remote2expr'=>[  {'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''} ],
      'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'',
      'action'=>'SET', 'script'=>'',   'apptype'=>'NET.BASE', 'itil_type'=>'1'  },

#May 31 20:04:39 cnm-pro snmptrapd[2209]: DATE>>2013531 20:04:39; HOST>>0.0.0.0; IPv1>>0.0.0.0; NAMEv1>>0.0.0.0; IPv2>>UDP: [192.168.0.254]:49206->[192.168.0.75]:162; NAMEv2>><UNKNOWN>; OID>>.; TRAP>>0.0; DESC>>Cold Start; VDATA>>DISMAN-EXPRESSION-MIB::sysUpTimeInstance = Timeticks: (381273098) 44 days, 3:05:30.98|SNMPv2-MIB::snmpTrapOID.0 = OID: BRIDGE-MIB::topologyChange

);

1;
__END__
