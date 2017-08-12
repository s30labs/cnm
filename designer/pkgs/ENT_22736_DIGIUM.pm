#---------------------------------------------------------------------------
package ENT_22736_DIGIUM;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_22736_DIGIUM::ENTERPRISE_PREFIX='22736';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_22736_DIGIUM::TABLE_APPS =(

   'CHANNEL_TYPES' => {

      'col_filters' => '#text_filter,#text_filter,#select_filter,#select_filter,#select_filter,#select_filter',
      'col_widths' => '20.30.18.18.18.18',
      'col_sorting' => 'str.str.int.int.str',

      'oid_cols' => 'astChanTypeName_astChanTypeDesc_astChanTypeDeviceState_astChanTypeIndications_astChanTypeTransfer_astChanTypeChannels',
      'oid_last' => 'ASTERISK-MIB::astChanTypeTable',
      'name' => 'TIPOS DE CANALES',
      'descr' => 'Muestra informacion sobre los diferentes tipos de canales soportados',
      'xml_file' => '22736-ASTERISK-CHANNEL-TYPES.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'ASTERISK',
      'aname'=>'app_asterisk_chan_type',
      'range' => 'ASTERISK-MIB::astChanTypeTable',
      'enterprise' => '22736',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 22736-ASTERISK-CHANNEL-TYPES.xml -w xml ',
		'itil_type' => 1,	 'apptype'=>'NET.ASTERISK',
	
		'map' => {
						'astChanTypeDeviceState' => { '1'=>'true', '2'=>'false' },
						'astChanTypeIndications' => { '1'=>'true', '2'=>'false' },
						'astChanTypeTransfer' => { '1'=>'true', '2'=>'false' },
					},
   },


);

#astChanTable
#
#AstChanEntry ::= SEQUENCE {
#   astChanIndex      Integer32,
#   astChanName    DisplayString,
#   astChanLanguage      DisplayString,
#   astChanType    DisplayString,
#   astChanMusicClass DisplayString,
#   astChanBridge     DisplayString,
#   astChanMasq    DisplayString,
#   astChanMasqr      DisplayString,
#   astChanWhenHangup TimeTicks,
#   astChanApp     DisplayString,
#   astChanData    DisplayString,
#   astChanContext    DisplayString,
#   astChanMacroContext  DisplayString,
#   astChanMacroExten DisplayString,
#   astChanMacroPri      Integer32,
#   astChanExten      DisplayString,
#   astChanPri     Integer32,
#   astChanAccountCode   DisplayString,
#   astChanForwardTo  DisplayString,
#   astChanUniqueId      DisplayString,
#   astChanCallGroup  Unsigned32,
#   astChanPickupGroup   Unsigned32,
#   astChanState      INTEGER,
#   astChanMuted      TruthValue,
#   astChanRings      Integer32,
#   astChanCidDNID    DisplayString,
#   astChanCidNum     DisplayString,
#   astChanCidName    DisplayString,
#   astChanCidANI     DisplayString,
#   astChanCidRDNIS      DisplayString,
#   astChanCidPresentation  DisplayString,
#   astChanCidANI2    Integer32,
#   astChanCidTON     Integer32,
#   astChanCidTNS     Integer32,
#   astChanAMAFlags      INTEGER,
#   astChanADSI    INTEGER,
#   astChanToneZone      DisplayString,
#   astChanHangupCause   INTEGER,
#   astChanVariables  DisplayString,
#   astChanFlags      BITS,
#   astChanTransferCap   INTEGER



#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO GET
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_22736_DIGIUM::GET_APPS =(

  'GET_INFO' => {

		items => [

						{  'name'=> 'VERSION DE SOFTWARE',   'oid'=>'ASTERISK-MIB::astVersionString.0', 'esp'=>'' },
						{  'name'=> 'PID',   'oid'=>'ASTERISK-MIB::astConfigPid.0', 'esp'=>'' },
						{  'name'=> 'SOCKET',   'oid'=>'ASTERISK-MIB::astConfigSocket.0', 'esp'=>'' },
						{  'name'=> 'NUMERO DE MODULOS',   'oid'=>'ASTERISK-MIB::astNumModules.0', 'esp'=>'' },
						{  'name'=> 'CONFIG UP TIME',   'oid'=>'ASTERISK-MIB::astConfigUpTime.0', 'esp'=>'' },
						{  'name'=> 'CONFIG RELOAD TIME',   'oid'=>'ASTERISK-MIB::astConfigReloadTime.0', 'esp'=>'' },
		],

		'oid_cols' => 'astVersionString_astConfigPid_astConfigSocket_astNumModules_astConfigUpTime_astConfigReloadTime',		
     	'name' => 'INFORMACION DEL EQUIPO',
     	'descr' => 'Muestra informacion basica sobre el equipo',
     	'xml_file' => '22736_ASTERISK-get_info.xml',
     	'params' => '[-n;IP;]',
     	'ipparam' => '[-n;IP;]',
     	'subtype'=>'ASTERISK', 'apptype'=>'NET.ASTERISK',
     	'aname'=>'app_asterisk_get_info',
	  	'range' => 'ASTERISK-MIB::astVersionString.0',
     	'enterprise' => '22736',  #5 CIFRAS !!!!
     	'cmd' => '/opt/crawler/bin/libexec/snmptable -f 22736_ASTERISK-get_info.xml -w xml ',
		'itil_type' => 1,
  },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
# CREADA APLICACION TIPO GET:
#		00000-ENT_22736_DIGIUM-get_info.xml
#---------------------------------------------------------------------------
@ENT_22736_DIGIUM::METRICS=(

#ASTERISK-MIB::astConfigPid.0 = INTEGER: 32356
#ASTERISK-MIB::astNumChannels.0 = Gauge32: 0

# El campo items solo se pone si va a ser distinto de oid
#	{  'name'=> 'NUMERO DE CANALES',   'oid'=>'ASTERISK-MIB::astNumChannels.0', 'subtype'=>'ast_num_channels', 'class'=>'ASTERISK', 'vlabel'=>'num', 'include'=>1, 'esp'=>'' },
#	{  'name'=> 'ASTERISK PID',   'oid'=>'ASTERISK-MIB::astConfigPid.0', 'subtype'=>'ast_pid', 'class'=>'ASTERISK', 'vlabel'=>'pid', 'include'=>1,  'esp'=>'' },
	


#   {  'name'=> 'ESTADO SERVICIO ETH-HA',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.14', 'subtype'=>'ib_status_lan_ha', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID' },
   


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_22736_DIGIUM::METRICS_TAB=(

#	{	'name'=> 'ALERTAS POR PROTOCOLO',  'oid'=>'TPT-POLICY::protocolAlertCount', 'subtype'=>'tip_alerts_proto', 'class'=>'TIPPING-POINT', 'range'=>'TPT-POLICY::alertsByProtocolTable', 'get_iid'=>'alertProtocol' },

#	{	'name'=> 'FALLOS AL ACTUALIZAR',  'oid'=>'updateFailures', 'subtype'=>'ironport_update_fail', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
#	{	'name'=> 'TASA DE ACTUALIZACIONES',  'oid'=>'updates', 'subtype'=>'ironport_update_rate', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
# 	{	'name'=> '',  'oid'=>'', 'subtype'=>'ironport_temperature', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::', 'get_iid'=>'ASYNCOS-MAIL-MIB::' },

);


1;
__END__
