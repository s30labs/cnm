#---------------------------------------------------------------------------
package MIB2_000_BASE;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#---------------------------------------------------------------------------
$MIB2_000_BASE::ENTERPRISE_PREFIX='00000';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
# Opciones de filtrado: 
# 		#text_filter, #select_filter, #select_filter_strict, #numeric_filter
#---------------------------------------------------------------------------
%MIB2_000_BASE::TABLE_APPS =(

# fml 7/5/2011. Se migra a mib2_if para dotarla de mayor funcionalidad
#	'IFINFO' => {
#
#		'tune' => 'ascii',
#      'col_filters' => '#text_filter.#select_filter.#select_filter.#select_filter.#text_filter.#select_filter.#select_filter',
#		'col_widths' => '30.10.10.10.20.10.10',
#		'col_sorting' => 'str.str.str.str.str.str.str',
#
#      'oid_cols' => 'ifDescr_ifType_ifMtu_ifSpeed_ifPhysAddress_ifAdminStatus_ifOperStatus',
#      'oid_last' => 'RFC1213-MIB::ifTable',
#      'name' => 'LISTA DE INTERFACES',
#      'descr' => 'Lista los interfaces definidos en el dispositivo',
#      'xml_file' => '00000-MIB2-IF.xml',
#      'params' => '[-n;IP;]',
#      'ipparam' => '[-n;IP;]',
#      'subtype'=>'MIB2',
#      'aname'=>'app_mib2_listinterfaces',
#      'range' => 'RFC1213-MIB::ifTable',
#      'enterprise' => '00000',  #5 CIFRAS !!!!
#      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-MIB2-IF.xml -w xml ',
#	},


   'ARPTABLE' => {

      'col_filters' => '#text_filter.#text_filter.#select_filter',
      'col_widths' => '25.25.20',
      'col_sorting' => 'str.str.str',

      'oid_cols' => 'ipNetToMediaPhysAddress_ipNetToMediaNetAddress_ipNetToMediaType',
      'oid_last' => 'IP-MIB::ipNetToMediaTable',
      'name' => 'TABLA DE ARP',
      'descr' => 'Muestra la tabla de ARP del dispositivo (IP/direccion MAC)',
      'xml_file' => '00000-MIB2-IP-ARP.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'MIB2',
      'aname'=>'app_mib2_arptable',
      'range' => 'IP-MIB::ipNetToMediaTable',
      'enterprise' => '00000',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-MIB2-IP-ARP.xml -w xml ',
		'itil_type' => 1,	'apptype'=>'NET.MIB2',
   },


   'ROUTETABLE' => {

      'col_filters' => '#numeric_filter,#text_filter,#select_filter,#select_filter,#text_filter',
      'col_widths' => '15.20.15.15.20',
      'col_sorting' => 'int.str.int.int.str',

      'oid_cols' => 'ipRouteMetric1_ipRouteNextHop_ipRouteType_ipRouteProto_ipRouteMask',
      'oid_last' => 'RFC1213-MIB::ipRouteTable',
      'name' => 'TABLA DE RUTAS',
      'descr' => 'Muestra la tabla derutas del dispositivo. Conviene tener precaucion con aquellos dispositivos con gran numero de rutas porque puede aumentar la carga del equipo',
      'xml_file' => '00000-MIB2-RFC1213-ROUTES.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'MIB2',
      'aname'=>'app_mib2_routetable',
      'range' => 'RFC1213-MIB::ipRouteTable',
      'enterprise' => '00000',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-MIB2-RFC1213-ROUTES.xml  -w xml ',
		'itil_type' => 1,	'apptype'=>'NET.MIB2',
   },


   'TCPTABLE' => {

      'col_filters' => '#select_filter,#text_filter,#text_filter,#text_filter,#text_filter',
      'col_widths' => '15.20.20.20.20',
      'col_sorting' => 'int.str.int.str.int',

      'oid_cols' => 'tcpConnState_tcpConnLocalAddress_tcpConnLocalPort_tcpConnRemAddress_tcpConnRemPort',
      'oid_last' => 'TCP-MIB::tcpConnTable',
      'name' => 'SESIONES TCP',
      'descr' => 'Muestra las sesiones TCP del dispositivo',
      'xml_file' => '00000-MIB2-TCP-CONNECTIONS.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'MIB2',
      'aname'=>'app_mib2_tcpsessions',
      'range' => 'TCP-MIB::tcpConnTable',
      'enterprise' => '00000',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-MIB2-TCP-CONNECTIONS.xml  -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.MIB2',

   },

   'UDPTABLE' => {

      'col_filters' => '#text_filter,#text_filter',
      'col_widths' => '25.25',
      'col_sorting' => 'str.int',

      'oid_cols' => 'udpLocalAddress_udpLocalPort',
      'oid_last' => 'UDP-MIB::udpTable',
      'name' => 'PUERTOS UDP',
      'descr' => 'Muestra los puertos UDP utilizados por el dispositivo',
      'xml_file' => '00000-MIB2-UDP-PORTS.xml',
      'params' => '[-n;IP;]',
      'ipparam' => '[-n;IP;]',
      'subtype'=>'MIB2',
      'aname'=>'app_mib2_udpports',
      'range' => 'UDP-MIB::udpTable',
      'enterprise' => '00000',  #5 CIFRAS !!!!
      'cmd' => '/opt/crawler/bin/libexec/snmptable -f 00000-MIB2-UDP-PORTS.xml  -w xml ',
		'itil_type' => 1,		'apptype'=>'NET.MIB2',

   }

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_000_BASE::METRICS=(


   {  'name'=> 'DATAGRAMAS DE ENTRADA DESCARTADOS',   'oid'=>'RFC1213-MIB::ipInAddrErrors.0', 'subtype'=>'mib2_ipInAddrErrors', 'class'=>'MIB2', 'include'=>'0', 'itil_type' => 1, 'apptype'=>'NET.MIB2' },
   {  'name'=> 'DESCARTES POR ROUTING',      'oid'=>'RFC1213-MIB::ipRoutingDiscards.0', 'subtype'=>'mib2_ipRoutingDiscards', 'class'=>'MIB2', 'include'=>'0', 'itil_type' => 1, 'apptype'=>'NET.MIB2' },
   {  'name'=> 'DATAGRAMAS SIN RUTA',      'oid'=>'RFC1213-MIB::ipOutNoRoutes.0', 'subtype'=>'mib2_ipOutNoRoutes', 'class'=>'MIB2', 'include'=>'0', 'itil_type' => 1, 'apptype'=>'NET.MIB2' },

	# OJO!!! No se puede definir como DISMAN-EVENT-MIB::sysUpTimeInstance porque las metricas escalares deben terminar en un valor numerico. Si no el chequeo dela provision no funciona.
   {  'name'=> 'TIEMPO EN FUNCIONAMIENTO',    'oid'=>'SNMPv2-MIB::sysUpTime.0', 'subtype'=>'mib2_uptime', 'class'=>'MIB2', 'include'=>'1', 'itil_type' => 1, 'apptype'=>'NET.MIB2' },


#root@cnm-ingelan:/opt/custom_pro# snmptranslate -Td .1.3.6.1.2.1.1.3.00i
#DISMAN-EVENT-MIB::sysUpTimeInstance
#sysUpTimeInstance OBJECT-TYPE
#  -- FROM       DISMAN-EVENT-MIB, EXPRESSION-MIB, DISMAN-EXPRESSION-MIB
#::= { iso(1) org(3) dod(6) internet(1) mgmt(2) mib-2(1) system(1) sysUpTime(3) 0 }
#

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@MIB2_000_BASE::METRICS_TAB=(

   {  'name'=> 'RESUMEN ESTADO DE INTERFACES',  'oid'=>'ifAdminStatus|ifOperStatus', 'subtype'=>'mib2_glob_ifstat', 'class'=>'MIB2', 'range'=>'RFC1213-MIB::ifTable', 'get_iid'=>'ifDescr', 'itil_type'=>1, 'mtype'=>'STD_BASE',
'esp'=>'TABLE(MATCH)(up,up)|TABLE(MATCH)(down,*)|TABLE(MATCH)(up,down)', 'items'=>'up|admin down|down|unk', 'apptype'=>'NET.MIB2'
},


#	{	'name'=> 'ESTADO DE PERFILES DEL AP',  'oid'=>'bsnAPIfLoadProfileState|bsnAPIfInterferenceProfileState|bsnAPIfNoiseProfileState|bsnAPIfCoverageProfileState', 'subtype'=>'airspace_ap_profiles', 'class'=>'CISCO-AIRONET', 'range'=>'AIRESPACE-WIRELESS-MIB::bsnAPIfProfileStateTable', 'get_iid'=>'bsnAPDot3MacAddress' },


);


1;
__END__
