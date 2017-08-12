#---------------------------------------------------------------------------
package ENT_37568_COMMEND;

#---------------------------------------------------------------------------
#/opt/custom_pro/conf/gconf -m ENT_37568_COMMEND
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_37568_COMMEND::ENTERPRISE_PREFIX='37568';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_37568_COMMEND::TABLE_APPS =(

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
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_37568_COMMEND::METRICS=(

#COMMEND-IOIP-MIB::commendStationConnectivityIPPrimaryState.0
#	{  'name'=> 'ESTADO DE CONECTIVIDAD IP',   'oid'=>'COMMEND-IOIP-MIB::commendStationConnectivityIPPrimaryState.0|COMMEND-IOIP-MIB::commendStationConnectivityIPSecondaryState.0|COMMEND-IOIP-MIB::commendStationConnectivityIPTertiaryState.0', 'subtype'=>'commend_conect_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
#'esp'=>'MAPS("ACTIVE")(1,0)|MAPS("*")(0,1)', 'mtype'=>'STD_SOLID' },

#COMMEND-IOIP-MIB::commendServerNetworkGEPSlot0-01-State.0
   {  'name'=> 'ESTADO GEPSlot0-01',   'oid'=>'COMMEND-IOIP-MIB::commendServerNetworkGEPSlot0-01-State.0', 'subtype'=>'commend_gepslot001_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'connected(2)|not-configured(0)|disconnected(1)|connected-fallback(3)', 'esp'=>'MAP(2)(1,0,0,0)|MAP(0)(0,1,0,0)|MAP(1)(0,0,1,0)|MAP(3)(0,0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO GEPSlot0-02',   'oid'=>'COMMEND-IOIP-MIB::commendServerNetworkGEPSlot0-02-State.0', 'subtype'=>'commend_gepslot002_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'connected(2)|not-configured(0)|disconnected(1)|connected-fallback(3)', 'esp'=>'MAP(2)(1,0,0,0)|MAP(0)(0,1,0,0)|MAP(1)(0,0,1,0)|MAP(3)(0,0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO GEPSlot0-03',   'oid'=>'COMMEND-IOIP-MIB::commendServerNetworkGEPSlot0-03-State.0', 'subtype'=>'commend_gepslot003_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'connected(2)|not-configured(0)|disconnected(1)|connected-fallback(3)', 'esp'=>'MAP(2)(1,0,0,0)|MAP(0)(0,1,0,0)|MAP(1)(0,0,1,0)|MAP(3)(0,0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO GEPSlot0-04',   'oid'=>'COMMEND-IOIP-MIB::commendServerNetworkGEPSlot0-04-State.0', 'subtype'=>'commend_gepslot004_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'connected(2)|not-configured(0)|disconnected(1)|connected-fallback(3)', 'esp'=>'MAP(2)(1,0,0,0)|MAP(0)(0,1,0,0)|MAP(1)(0,0,1,0)|MAP(3)(0,0,0,1)', 'mtype'=>'STD_SOLID' },

#  SYNTAX Integer {
#    not-configured(0),
#    disconnected(1),
#    connected(2),
#    connected-fallback(3)
#    }
#

#verde,azul,rojo,naranja
#1 -> 15
#COMMEND-IOIP-MIB::commendServerCardsSlot1State
   {  'name'=> 'ESTADO PLACA SLOT 01',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot1State.0', 'subtype'=>'commend_card_slot1_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 02',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot2State.0', 'subtype'=>'commend_card_slot2_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 03',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot3State.0', 'subtype'=>'commend_card_slot3_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 04',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot4State.0', 'subtype'=>'commend_card_slot4_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 05',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot5State.0', 'subtype'=>'commend_card_slot5_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 06',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot6State.0', 'subtype'=>'commend_card_slot6_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 07',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot7State.0', 'subtype'=>'commend_card_slot7_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 08',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot8State.0', 'subtype'=>'commend_card_slot8_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 09',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot9State.0', 'subtype'=>'commend_card_slot9_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 10',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot10State.0', 'subtype'=>'commend_card_slot10_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 11',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot11State.0', 'subtype'=>'commend_card_slot11_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 12',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot12State.0', 'subtype'=>'commend_card_slot12_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 13',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot13State.0', 'subtype'=>'commend_card_slot13_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 14',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot14State.0', 'subtype'=>'commend_card_slot14_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO PLACA SLOT 15',   'oid'=>'COMMEND-IOIP-MIB::commendServerCardsSlot15State.0', 'subtype'=>'commend_card_slot15_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'WORKING|NOT INITIALIZED|RESTO', 'esp'=>'MAPS("WORKING.")(1,0,0)|MAPS("NOT INITIALIZED.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },





#COMMEND-IOIP-MIB::commendServerSubscriber1State
#1->112
   {  'name'=> 'ESTADO SUBSCRIBER 001',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber1State.0', 'subtype'=>'commend_subs1_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 002',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber2State.0', 'subtype'=>'commend_subs2_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 003',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber3State.0', 'subtype'=>'commend_subs3_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 004',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber4State.0', 'subtype'=>'commend_subs4_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 005',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber5State.0', 'subtype'=>'commend_subs5_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 006',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber6State.0', 'subtype'=>'commend_subs6_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 007',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber7State.0', 'subtype'=>'commend_subs7_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 008',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber8State.0', 'subtype'=>'commend_subs8_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 009',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber9State.0', 'subtype'=>'commend_subs9_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 010',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber10State.0', 'subtype'=>'commend_subs10_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 011',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber11State.0', 'subtype'=>'commend_subs11_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 012',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber12State.0', 'subtype'=>'commend_subs12_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 013',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber13State.0', 'subtype'=>'commend_subs13_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 014',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber14State.0', 'subtype'=>'commend_subs14_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 015',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber15State.0', 'subtype'=>'commend_subs15_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 016',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber16State.0', 'subtype'=>'commend_subs16_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 017',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber17State.0', 'subtype'=>'commend_subs17_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 018',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber18State.0', 'subtype'=>'commend_subs18_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 019',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber19State.0', 'subtype'=>'commend_subs19_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 020',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber20State.0', 'subtype'=>'commend_subs20_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 021',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber21State.0', 'subtype'=>'commend_subs21_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 022',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber22State.0', 'subtype'=>'commend_subs22_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 023',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber23State.0', 'subtype'=>'commend_subs23_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 024',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber24State.0', 'subtype'=>'commend_subs24_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 025',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber25State.0', 'subtype'=>'commend_subs25_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 026',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber26State.0', 'subtype'=>'commend_subs26_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 027',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber27State.0', 'subtype'=>'commend_subs27_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 028',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber28State.0', 'subtype'=>'commend_subs28_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 029',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber29State.0', 'subtype'=>'commend_subs29_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 030',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber30State.0', 'subtype'=>'commend_subs30_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },

   {  'name'=> 'ESTADO SUBSCRIBER 031',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber31State.0', 'subtype'=>'commend_subs31_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 032',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber32State.0', 'subtype'=>'commend_subs32_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 033',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber33State.0', 'subtype'=>'commend_subs33_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 034',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber34State.0', 'subtype'=>'commend_subs34_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 035',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber35State.0', 'subtype'=>'commend_subs35_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 036',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber36State.0', 'subtype'=>'commend_subs36_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 037',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber37State.0', 'subtype'=>'commend_subs37_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 038',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber38State.0', 'subtype'=>'commend_subs38_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 039',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber39State.0', 'subtype'=>'commend_subs39_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 040',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber40State.0', 'subtype'=>'commend_subs40_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 041',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber41State.0', 'subtype'=>'commend_subs41_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 042',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber42State.0', 'subtype'=>'commend_subs42_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 043',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber43State.0', 'subtype'=>'commend_subs43_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 044',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber44State.0', 'subtype'=>'commend_subs44_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 045',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber45State.0', 'subtype'=>'commend_subs45_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 046',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber46State.0', 'subtype'=>'commend_subs46_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 047',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber47State.0', 'subtype'=>'commend_subs47_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 048',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber48State.0', 'subtype'=>'commend_subs48_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 049',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber49State.0', 'subtype'=>'commend_subs49_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 050',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber50State.0', 'subtype'=>'commend_subs50_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 051',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber51State.0', 'subtype'=>'commend_subs51_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 052',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber52State.0', 'subtype'=>'commend_subs52_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 053',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber53State.0', 'subtype'=>'commend_subs53_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 054',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber54State.0', 'subtype'=>'commend_subs54_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 055',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber55State.0', 'subtype'=>'commend_subs55_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 056',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber56State.0', 'subtype'=>'commend_subs56_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 057',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber57State.0', 'subtype'=>'commend_subs57_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 058',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber58State.0', 'subtype'=>'commend_subs58_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 059',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber59State.0', 'subtype'=>'commend_subs59_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 060',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber60State.0', 'subtype'=>'commend_subs60_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 061',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber61State.0', 'subtype'=>'commend_subs61_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 062',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber62State.0', 'subtype'=>'commend_subs62_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 063',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber63State.0', 'subtype'=>'commend_subs63_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 064',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber64State.0', 'subtype'=>'commend_subs64_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 065',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber65State.0', 'subtype'=>'commend_subs65_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 066',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber66State.0', 'subtype'=>'commend_subs66_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 067',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber67State.0', 'subtype'=>'commend_subs67_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 068',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber68State.0', 'subtype'=>'commend_subs68_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 069',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber69State.0', 'subtype'=>'commend_subs69_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 070',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber70State.0', 'subtype'=>'commend_subs70_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 071',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber71State.0', 'subtype'=>'commend_subs71_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 072',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber72State.0', 'subtype'=>'commend_subs72_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 073',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber73State.0', 'subtype'=>'commend_subs73_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 074',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber74State.0', 'subtype'=>'commend_subs74_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 075',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber75State.0', 'subtype'=>'commend_subs75_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 076',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber76State.0', 'subtype'=>'commend_subs76_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 077',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber77State.0', 'subtype'=>'commend_subs77_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 078',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber78State.0', 'subtype'=>'commend_subs78_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 079',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber79State.0', 'subtype'=>'commend_subs79_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 080',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber80State.0', 'subtype'=>'commend_subs80_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 081',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber81State.0', 'subtype'=>'commend_subs81_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 082',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber82State.0', 'subtype'=>'commend_subs82_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 083',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber83State.0', 'subtype'=>'commend_subs83_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 084',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber84State.0', 'subtype'=>'commend_subs84_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 085',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber85State.0', 'subtype'=>'commend_subs85_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 086',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber86State.0', 'subtype'=>'commend_subs86_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 087',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber87State.0', 'subtype'=>'commend_subs87_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 088',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber88State.0', 'subtype'=>'commend_subs88_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 089',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber89State.0', 'subtype'=>'commend_subs89_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 090',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber90State.0', 'subtype'=>'commend_subs90_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 091',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber91State.0', 'subtype'=>'commend_subs91_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 092',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber92State.0', 'subtype'=>'commend_subs92_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 093',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber93State.0', 'subtype'=>'commend_subs93_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 094',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber94State.0', 'subtype'=>'commend_subs94_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 095',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber95State.0', 'subtype'=>'commend_subs95_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 096',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber96State.0', 'subtype'=>'commend_subs96_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 097',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber97State.0', 'subtype'=>'commend_subs97_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 098',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber98State.0', 'subtype'=>'commend_subs98_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 099',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber99State.0', 'subtype'=>'commend_subs99_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 100',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber100State.0', 'subtype'=>'commend_subs100_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 101',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber101State.0', 'subtype'=>'commend_subs101_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 102',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber102State.0', 'subtype'=>'commend_subs102_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 103',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber103State.0', 'subtype'=>'commend_subs103_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 104',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber104State.0', 'subtype'=>'commend_subs104_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 105',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber105State.0', 'subtype'=>'commend_subs105_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 106',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber106State.0', 'subtype'=>'commend_subs106_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 107',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber107State.0', 'subtype'=>'commend_subs107_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 108',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber108State.0', 'subtype'=>'commend_subs108_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 109',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber109State.0', 'subtype'=>'commend_subs109_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 110',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber110State.0', 'subtype'=>'commend_subs110_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 111',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber111State.0', 'subtype'=>'commend_subs111_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },
   {  'name'=> 'ESTADO SUBSCRIBER 112',   'oid'=>'COMMEND-IOIP-MIB::commendServerSubscriber112State.0', 'subtype'=>'commend_subs112_state', 'class'=>'COMMEND', 'itil_type' => 1, 'apptype'=>'NET.COMMEND',
'items'=>'Online|Offline|Resto', 'esp'=>'MAPS("Online.")(1,0,0)|MAPS("Offline.")(0,1,0)|MAPS("*")(0,0,1)', 'mtype'=>'STD_SOLID' },


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_37568_COMMEND::METRICS_TAB=(

#	{	'name'=> 'ALERTAS POR PROTOCOLO',  'oid'=>'TPT-POLICY::protocolAlertCount', 'subtype'=>'tip_alerts_proto', 'class'=>'TIPPING-POINT', 'range'=>'TPT-POLICY::alertsByProtocolTable', 'get_iid'=>'alertProtocol' },

#	{	'name'=> 'FALLOS AL ACTUALIZAR',  'oid'=>'updateFailures', 'subtype'=>'ironport_update_fail', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
#	{	'name'=> 'TASA DE ACTUALIZACIONES',  'oid'=>'updates', 'subtype'=>'ironport_update_rate', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
# 	{	'name'=> '',  'oid'=>'', 'subtype'=>'ironport_temperature', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::', 'get_iid'=>'ASYNCOS-MAIL-MIB::' },

);


1;
__END__
