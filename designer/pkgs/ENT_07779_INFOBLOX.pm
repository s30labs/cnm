#---------------------------------------------------------------------------
package ENT_07779_INFOBLOX;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_07779_INFOBLOX::ENTERPRISE_PREFIX='07779';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_07779_INFOBLOX::TABLE_APPS =(

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
# APLICACIONES SNMP DE TIPO GET
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_07779_INFOBLOX::GET_APPS =(

  'GET_INFO' => {

		items => [

						{  'name'=> 'TIPO DE HARDWARE',   'oid'=>'IB-PLATFORMONE-MIB::ibHardwareType.0', 'esp'=>'' },
						{  'name'=> 'NUMERO DE SERIE',   'oid'=>'IB-PLATFORMONE-MIB::ibSerialNumber.0', 'esp'=>'' },
						{  'name'=> 'VERSION DE SOFTWARE',   'oid'=>'IB-PLATFORMONE-MIB::ibNiosVersion.0', 'esp'=>'' },
		],

		'oid_cols' =>'ibHardwareType_ibSerialNumber_ibNiosVersion',		
     	'name' => 'INFORMACION DEL EQUIPO',
     	'descr' => 'Muestra informacion basica sobre el equipo',
     	'xml_file' => '07779_INFOBLOX-get_info.xml',
     	'params' => '[-n;IP;]',
     	'ipparam' => '[-n;IP;]',
     	'subtype'=>'INFOBLOX',		'apptype'=>'NET.INFOBLOX',
     	'aname'=>'app_infoblox_get_info',
	  	'range' => 'IB-PLATFORMONE-MIB::ibHardwareType.0',
     	'enterprise' => '07779',  #5 CIFRAS !!!!
     	'cmd' => '/opt/crawler/bin/libexec/snmptable -f 07779_INFOBLOX-get_info.xml -w xml ',
		'itil_type' => 1,
  },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
# CREADA APLICACION TIPO GET:
#		00000-ENT_07779_INFOBLOX-get_info.xml
#---------------------------------------------------------------------------
@ENT_07779_INFOBLOX::METRICS=(

# El campo items solo se pone si va a ser distinto de oid
	{  'name'=> 'LATENCIA DEL DNS (Non-AA)',   'oid'=>'IB-PLATFORMONE-MIB::ibNetworkMonitorDNSNonAAT5AvgLatency.0', 'subtype'=>'ib_dns_nonaa_lat', 'class'=>'INFOBLOX', 'vlabel'=>'microseconds', 'include'=>1, 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.INFOBLOX' },
	{  'name'=> 'CONSULTAS AL DNS (Non-AA)',   'oid'=>'IB-PLATFORMONE-MIB::ibNetworkMonitorDNSNonAAT5Count.0', 'subtype'=>'ib_dns_nonaa_cnt', 'class'=>'INFOBLOX', 'vlabel'=>'num. queries', 'include'=>1,  'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.INFOBLOX' },
	{  'name'=> 'LATENCIA DEL DNS (AA)',   'oid'=>'IB-PLATFORMONE-MIB::ibNetworkMonitorDNSAAT5AvgLatency.0', 'subtype'=>'ib_dns_aa_lat', 'class'=>'INFOBLOX', 'vlabel'=>'microseconds', 'include'=>1, 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.INFOBLOX' },
	{  'name'=> 'CONSULTAS AL DNS (AA)',   'oid'=>'IB-PLATFORMONE-MIB::ibNetworkMonitorDNSAAT5Count.0', 'subtype'=>'ib_dns_aa_cnt', 'class'=>'INFOBLOX', 'vlabel'=>'num. queries', 'include'=>1, 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.INFOBLOX' },

#	{  'name'=> 'USO DE LA BASE DE DATOS %',   'oid'=>'IB-PLATFORMONE-MIB::ibPlatformModule.10.1.3.19', 'subtype'=>'ib_db_usage', 'class'=>'INFOBLOX' },

	{  'name'=> 'TEMPERATURA DE LA CPU',   'oid'=>'IB-PLATFORMONE-MIB::ibCPUTemperature.0', 'subtype'=>'ib_cpu_temperature', 'class'=>'INFOBLOX', 'vlabel'=>'grados C', 'include'=>1,  'esp'=>'INT(o1)', 'itil_type' => 1, 'apptype'=>'NET.INFOBLOX' },
	{  'name'=> 'USO DE CPU',   'oid'=>'IB-PLATFORMONE-MIB::ibSystemMonitorCpuUsage.0', 'subtype'=>'ib_cpu_usage', 'class'=>'INFOBLOX', 'vlabel'=>'promedio', 'include'=>1,  'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.INFOBLOX' },
	{  'name'=> 'USO DE MEMORIA',   'oid'=>'IB-PLATFORMONE-MIB::ibSystemMonitorMemUsage.0', 'subtype'=>'ib_mem_usage', 'class'=>'INFOBLOX', 'vlabel'=>'promedio', 'include'=>1,  'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.INFOBLOX' },


	{  'name'=> 'ESTADO DNS MONITOR',   'oid'=>'IB-PLATFORMONE-MIB::ibNetworkMonitorDNSActive.0', 'subtype'=>'ib_dns_monitor', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Activo(1)', 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.INFOBLOX' },

	{  'name'=> 'MENSAJES DISCOVER/REQUEST',   'oid'=>'IB-DHCPONE-MIB::ibDhcpTotalNoOfDiscovers.0|IB-DHCPONE-MIB::ibDhcpTotalNoOfRequests.0', 'subtype'=>'ib_dhcp_disc_req', 'class'=>'INFOBLOX', 'vlabel'=>'num. of msgs', 'include'=>1, 'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.INFOBLOX' },
	{  'name'=> 'MENSAJES DE RELEASE/OFFER',   'oid'=>'IB-DHCPONE-MIB::ibDhcpTotalNoOfReleases.0|IB-DHCPONE-MIB::ibDhcpTotalNoOfOffers.0', 'subtype'=>'ib_dhcp_rel_off', 'class'=>'INFOBLOX', 'vlabel'=>'num. of msgs', 'include'=>1,  'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.INFOBLOX' },
	{  'name'=> 'MENSAJES ACK/NACK',   'oid'=>'IB-DHCPONE-MIB::ibDhcpTotalNoOfAcks.0|IB-DHCPONE-MIB::ibDhcpTotalNoOfNacks.0', 'subtype'=>'ib_dhcp_ack_nack', 'class'=>'INFOBLOX', 'vlabel'=>'num. of msgs', 'include'=>1,  'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.INFOBLOX' },
	{  'name'=> 'MENSAJES DECLINE/INFORM/OTHER',   'oid'=>'IB-DHCPONE-MIB::ibDhcpTotalNoOfDeclines.0|IB-DHCPONE-MIB::ibDhcpTotalNoOfInforms.0|IB-DHCPONE-MIB::ibDhcpTotalNoOfOthers.0', 'subtype'=>'ib_dhcp_other', 'class'=>'INFOBLOX', 'vlabel'=>'num. of msgs', 'include'=>1,  'esp'=>'', 'itil_type' => 1, 'apptype'=>'NET.INFOBLOX' },

#IbServiceStates ::= TEXTUAL-CONVENTION
#   STATUS        current
#   DESCRIPTION   "It defines the states for infoblox services
#                  Note: NTP service will always be running on NIOS,
#                  even when disabled in the GUI.This is for internal
#                  grid operations."
#   SYNTAX        INTEGER {
#                   working      (1),
#                   warning      (2),
#                   failed       (3),
#                   inactive     (4),
#                   unknown      (5)
#                 }
#
##  SYNTAX        INTEGER {dhcp(1), dns(2), ntp(3), radius(4), tftp(5), http-file-dist(6), ftp(7), bloxtools-move(8), bloxtools(9), node-status(10), disk-usage(11), enet-lan(12), enet-lan2(13), enet-ha(14), enet-mgmt(15), lcd(16), memory(17), replication(18), db-object(19), raid-summary(20), raid-disk1(21), raid-disk2(22), raid-disk3(23), raid-disk4(24), fan1(25), fan2(26), fan3(27), power-supply(28), ntp-sync(29), cpu1-temp(30), cpu2-temp(31), sys-temp(32), raid-battery(33), cpu-usage(34), ospf(35), bgp(36)}

   {  'name'=> 'ESTADO SERVICIO DHCP',   'oid'=>'IB-PLATFORMONE-MIB::ibServiceStatus.1', 'subtype'=>'ib_status_dhcp', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO DNS',   'oid'=>'IB-PLATFORMONE-MIB::ibServiceStatus.2', 'subtype'=>'ib_status_dns', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO NTP',   'oid'=>'IB-PLATFORMONE-MIB::ibServiceStatus.3', 'subtype'=>'ib_status_ntp', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO RADIUS',   'oid'=>'IB-PLATFORMONE-MIB::ibServiceStatus.4', 'subtype'=>'ib_status_radius', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO TFTP',   'oid'=>'IB-PLATFORMONE-MIB::ibServiceStatus.5', 'subtype'=>'ib_status_tftp', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO HTTP-FILE-DIST',   'oid'=>'IB-PLATFORMONE-MIB::ibServiceStatus.6', 'subtype'=>'ib_status_httpf', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO FTP',   'oid'=>'IB-PLATFORMONE-MIB::ibServiceStatus.7', 'subtype'=>'ib_status_ftp', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO BLOXTOOLS-MOVE',   'oid'=>'IB-PLATFORMONE-MIB::ibServiceStatus.8', 'subtype'=>'ib_status_btools_move', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO BLOXTOOLS',   'oid'=>'IB-PLATFORMONE-MIB::ibServiceStatus.9', 'subtype'=>'ib_status_btools', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },


   {  'name'=> 'ESTADO SERVICIO DEL NODO',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.10', 'subtype'=>'ib_status_node', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO DISCO',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.11', 'subtype'=>'ib_status_disk', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO ETH-LAN1',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.12', 'subtype'=>'ib_status_lan1', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO ETH-LAN2',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.13', 'subtype'=>'ib_status_lan2', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO ETH-HA',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.14', 'subtype'=>'ib_status_lan_ha', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO ETH-MGMT',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.15', 'subtype'=>'ib_status_lan_mgmt', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO LCD',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.16', 'subtype'=>'ib_status_lcd', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO MEMORY',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.17', 'subtype'=>'ib_status_mem', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO REPLICATION',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.18', 'subtype'=>'ib_status_repli', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO DB_OBJECT',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.19', 'subtype'=>'ib_status_dbobj', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO RAID-SUMMARY',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.20', 'subtype'=>'ib_status_raid_sum', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO RAID-DISK1',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.21', 'subtype'=>'ib_status_raid_disk1', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO RAID-DISK2',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.22', 'subtype'=>'ib_status_raid_disk2', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO RAID-DISK3',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.23', 'subtype'=>'ib_status_raid_disk3', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO RAID-DISK4',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.24', 'subtype'=>'ib_status_raid_disk4', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO FAN1',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.25', 'subtype'=>'ib_status_fan1', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO FAN2',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.26', 'subtype'=>'ib_status_fan2', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO FAN3',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.27', 'subtype'=>'ib_status_fan3', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO POWER-SUPPLY',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.28', 'subtype'=>'ib_status_power', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO NTP-SYNC',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.29', 'subtype'=>'ib_status_ntp_sync', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO CPU1-TEMP',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.30', 'subtype'=>'ib_status_cpu1_temp', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO CPU2-TEMP',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.31', 'subtype'=>'ib_status_cpu2_temp', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO SYS-TEMP',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.32', 'subtype'=>'ib_status_sys_temp', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO RAID-BATTERY',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.33', 'subtype'=>'ib_status_raid_bat', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO CPU-USAGE',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.34', 'subtype'=>'ib_status_cpu_usage', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO OSPF',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.35', 'subtype'=>'ib_status_ospf', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },
   {  'name'=> 'ESTADO SERVICIO BGP',   'oid'=>'IB-PLATFORMONE-MIB::ibNode1ServiceStatus.36', 'subtype'=>'ib_status_bgp', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>0, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# OJO!!! oid SI DEBE IR CUALIFICADO AQUI PERO NO AL ALMACENARO EN BBDD !!!!!!
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_07779_INFOBLOX::METRICS_TAB=(

#	{	'name'=> 'ALERTAS POR PROTOCOLO',  'oid'=>'TPT-POLICY::protocolAlertCount', 'subtype'=>'tip_alerts_proto', 'class'=>'TIPPING-POINT', 'range'=>'TPT-POLICY::alertsByProtocolTable', 'get_iid'=>'alertProtocol' },

#	{	'name'=> 'FALLOS AL ACTUALIZAR',  'oid'=>'updateFailures', 'subtype'=>'ironport_update_fail', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
#	{	'name'=> 'TASA DE ACTUALIZACIONES',  'oid'=>'updates', 'subtype'=>'ironport_update_rate', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'ASYNCOS-MAIL-MIB::updateServiceName' },
# 	{	'name'=> '',  'oid'=>'', 'subtype'=>'ironport_temperature', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::', 'get_iid'=>'ASYNCOS-MAIL-MIB::' },

);


1;
__END__
