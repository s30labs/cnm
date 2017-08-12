#---------------------------------------------------------------------------
package ENT_15497_IRONPORT;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( %TABLE_APPS @METRICS @METRICS_TAB);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
$ENT_15497_IRONPORT::ENTERPRISE_PREFIX='15497';

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO TABLA
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_15497_IRONPORT::TABLE_APPS =(

	'CADUCIDAD DE LICENCIAS' => {
			'oid_cols' => 'keyDescription_keyIsPerpetual_keySecondsUntilExpire',
			'oid_last' => 'ASYNCOS-MAIL-MIB::keyExpirationTable',
			'name' => 'CADUCIDAD DE LICENCIAS IRONPORT',
			'descr' => 'Muestra la caducidad de las licencias de los diferentes componentes del Ironport',
			'xml_file' => '15497-IRONPORT-KEYS.xml',
			'params' => '[-n;IP;]',
			'ipparam' => '[-n;IP;]',
			'subtype'=>'IRONPORT',
			'aname'=>'app_ironport_keys',
			'range' => 'ASYNCOS-MAIL-MIB::keyExpirationTable',
			'enterprise' => '15497',  #5 CIFRAS !!!!
			'cmd' => '/opt/crawler/bin/libexec/snmptable -f 15497-IRONPORT-KEYS.xml -w xml ',
			'itil_type' => 1,		'apptype'=>'NET.IRONPORT',
	},

   'UPDATES' => {
         'oid_cols' => 'updateServiceName_updates_updateFailures',
         'oid_last' => 'ASYNCOS-MAIL-MIB::updateTable',
         'name' => 'IRONPORT - ACTUALIZACION DE SOTWARE',
         'descr' => 'Muestra info sobre la actualizacion de los diferentes servicios del appliance',
         'xml_file' => '15497-IRONPORT-UPDATES.xml',
         'params' => '[-n;IP;]',
         'ipparam' => '[-n;IP;]',
         'subtype'=>'IRONPORT',
         'aname'=>'app_ironport_updates',
         'range' => 'ASYNCOS-MAIL-MIB::updateTable',
         'enterprise' => '15497',  #5 CIFRAS !!!!
         'cmd' => '/opt/crawler/bin/libexec/snmptable -f 15497-IRONPORT-UPDATES.xml -w xml ',
			'itil_type' => 1,		'apptype'=>'NET.IRONPORT',
   },

);


#
#ASYNCOS-MAIL-MIB::keyExpirationIndex.1 = INTEGER: 1
#ASYNCOS-MAIL-MIB::keyDescription.1 = STRING: Bounce Verification
#ASYNCOS-MAIL-MIB::keyIsPerpetual.1 = INTEGER: 1
#ASYNCOS-MAIL-MIB::keySecondsUntilExpire.1 = Gauge32: 0
#

#---------------------------------------------------------------------------
# APLICACIONES SNMP DE TIPO GET
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%ENT_15497_IRONPORT::GET_APPS =(

  'PERFORMANCE' => {

      items => [

                  {  'name'=> 'Uso de CPU (%)',   'oid'=>'ASYNCOS-MAIL-MIB::perCentCPUUtilization.0', 'esp'=>'' },
                  {  'name'=> 'Uso de Memoria (%)',   'oid'=>'ASYNCOS-MAIL-MIB::perCentMemoryUtilization.0', 'esp'=>'' },
                  {  'name'=> 'Uso de Disco (%)',   'oid'=>'ASYNCOS-MAIL-MIB::perCentDiskIOUtilization.0', 'esp'=>'' },
                  {  'name'=> 'Uso de la cola (%)',   'oid'=>'ASYNCOS-MAIL-MIB::perCentQueueUtilization.0', 'esp'=>'' },
                  {  'name'=> 'Ficheros abiertos o sockets',   'oid'=>'ASYNCOS-MAIL-MIB::openFilesOrSockets.0', 'esp'=>'' },
                  {  'name'=> 'Threads de correo',   'oid'=>'ASYNCOS-MAIL-MIB::mailTransferThreads.0', 'esp'=>'' },
                  {  'name'=> 'Peticiones DNS sin respuesta',   'oid'=>'ASYNCOS-MAIL-MIB::outstandingDNSRequests.0', 'esp'=>'' },
                  {  'name'=> 'Peticiones DNS pendientes',   'oid'=>'ASYNCOS-MAIL-MIB::pendingDNSRequests.0', 'esp'=>'' },
                  {  'name'=> 'Mensajes en la cola de trabajo',   'oid'=>'ASYNCOS-MAIL-MIB::workQueueMessages.0', 'esp'=>'' },
                  {  'name'=> 'Tiempo en la cola del mensaje mas antiguo',   'oid'=>'ASYNCOS-MAIL-MIB::oldestMessageAge.0', 'esp'=>'' },
      ],

		'oid_cols' => 'perCentCPUUtilization_perCentMemoryUtilization_perCentDiskIOUtilization_perCentQueueUtilization_openFilesOrSockets_mailTransferThreads_outstandingDNSRequests_pendingDNSRequests_workQueueMessages_oldestMessageAge',
     	'name' => 'IRONPORT - RENDIMIENTO',
     	'descr' => 'Muestra informacion basica sobre diferentes parametros de rendimiento del equipo',
     	'xml_file' => '15497_IRONPORT-performance.xml',
     	'params' => '[-n;IP;]',
     	'ipparam' => '[-n;IP;]',
     	'subtype'=>'IRONPORT',
     	'aname'=>'app_ironport_performance',
		'range' => 'ASYNCOS-MAIL-MIB::perCentCPUUtilization.0',
     	'enterprise' => '15497',  #5 CIFRAS !!!!
     	'cmd' => '/opt/crawler/bin/libexec/snmptable -f 15497_IRONPORT-performance.xml -w xml ',
		'itil_type' => 1,	'apptype'=>'NET.IRONPORT',
  },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO GET (cfg=1)
# (TAMBIEN GENERA LA APLICACION DE TIPO GET)
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_15497_IRONPORT::METRICS=(

	{  'name'=> 'USO DE CPU (%)',   'oid'=>'ASYNCOS-MAIL-MIB::perCentCPUUtilization.0', 'subtype'=>'ironport_cpu_usage', 'class'=>'IRONPORT', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
	{  'name'=> 'USO DE MEMORIA (%)',  'oid'=>'ASYNCOS-MAIL-MIB::perCentMemoryUtilization.0', 'subtype'=>'ironport_memory_usage', 'class'=>'IRONPORT', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
	{  'name'=> 'USO DE DISCO (%)',   'oid'=>'ASYNCOS-MAIL-MIB::perCentDiskIOUtilization.0', 'subtype'=>'ironport_disk_usage', 'class'=>'IRONPORT', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
	{  'name'=> 'USO DE LA COLA (%)',   'oid'=>'ASYNCOS-MAIL-MIB::perCentQueueUtilization.0', 'subtype'=>'ironport_queue_usage', 'class'=>'IRONPORT', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
	{  'name'=> 'FICHEROS/SOCKETS ABIERTOS',   'oid'=>'ASYNCOS-MAIL-MIB::openFilesOrSockets.0', 'subtype'=>'ironport_open_files', 'class'=>'IRONPORT', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
	{  'name'=> 'THREADS DE CORREO',   'oid'=>'ASYNCOS-MAIL-MIB::mailTransferThreads.0', 'subtype'=>'ironport_mail_threads', 'class'=>'IRONPORT', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
	{  'name'=> 'FALLOS EN DNS',   'oid'=>'ASYNCOS-MAIL-MIB::outstandingDNSRequests.0|ASYNCOS-MAIL-MIB::pendingDNSRequests.0', 'subtype'=>'ironport_dns_failures', 'class'=>'IRONPORT', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
	{  'name'=> 'MENSAJES EN LA COLA DE TRABAJO',   'oid'=>'ASYNCOS-MAIL-MIB::workQueueMessages.0', 'subtype'=>'ironport_queue_messages', 'class'=>'IRONPORT', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
	{  'name'=> 'TIEMPO EN COLA DEL MENSAJE MAS ANTIGUO',   'oid'=>'ASYNCOS-MAIL-MIB::oldestMessageAge.0', 'subtype'=>'ironport_oldest_message', 'class'=>'IRONPORT', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
	{  'name'=> 'VELOCIDAD VENTILADOR (FAN 1)',   'oid'=>'ASYNCOS-MAIL-MIB::fanRPMs.1', 'subtype'=>'ironport_fanrpms1', 'class'=>'IRONPORT', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
	{  'name'=> 'VELOCIDAD VENTILADOR (FAN 2)',   'oid'=>'ASYNCOS-MAIL-MIB::fanRPMs.2', 'subtype'=>'ironport_fanrpms2', 'class'=>'IRONPORT', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
	{  'name'=> 'TEMPERATURA',   'oid'=>'ASYNCOS-MAIL-MIB::degreesCelsius.1', 'subtype'=>'ironport_temperature1', 'class'=>'IRONPORT', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
# METRICAS SNMP DE TIPO TABLA (cfg=2)
#
# INSTRUCCIONES !!
#		oid no debe ir cualificado 'oid'=>'keySecondsUntilExpire'
#		range si debe ir cualificado 'range'=>'ASYNCOS-MAIL-MIB::keyExpirationTable'
#		get_iid no debe ir cualificado 'get_iid'=>'keyDescription'
#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@ENT_15497_IRONPORT::METRICS_TAB=(

	{	'name'=> 'CADUCIDAD DE LICENCIAS',  'oid'=>'keySecondsUntilExpire', 'subtype'=>'ironport_keyexpiration', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::keyExpirationTable', 'get_iid'=>'keyDescription', 'vlabel'=>'Dias', 'items'=>'Dias hasta la caducidad', 'include'=>1,  'esp'=>'o1/86400', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
	{	'name'=> 'FALLOS AL ACTUALIZAR',  'oid'=>'updateFailures', 'subtype'=>'ironport_update_fail', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'updateServiceName', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
	{	'name'=> 'TASA DE ACTUALIZACIONES',  'oid'=>'updates', 'subtype'=>'ironport_update_rate', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::updateTable', 'get_iid'=>'updateServiceName', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },
# 	{	'name'=> '',  'oid'=>'', 'subtype'=>'ironport_temperature', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::', 'get_iid'=>'ASYNCOS-MAIL-MIB::' },

#ASYNCOS-MAIL-MIB::raidStatus
#raidStatus OBJECT-TYPE
#  -- FROM       ASYNCOS-MAIL-MIB
#  SYNTAX        INTEGER {driveHealthy(1), driveFailure(2), driveRebuild(3)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "Status reported by RAID controller."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) ironPort(15497) asyncOSAppliances(1) asyncOSMail(1) asyncOSMailObjects(1) raidTable(18) raidEntry(1) 2 }

   {  'name'=> 'ESTADO DEL RAID',   'oid'=>'ASYNCOS-MAIL-MIB::raidStatus', 'subtype'=>'ironport_raid_status', 'class'=>'IRONPORT', 'range'=>'ASYNCOS-MAIL-MIB::raidTable', 'vlabel'=>'estado', 'get_iid'=>'raidID', 'include'=>'1', 'items'=>'driveHealthy(1)|driveRebuild(3)|driveFailure(2)|unk', 'esp'=>'MAP(1)(1,0,0,0)|MAP(3)(0,1,0,0)|MAP(2)(0,0,1,0)|MAP(4)(0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 1, 'apptype'=>'NET.IRONPORT' },


);


#---------------------------------------------------------------------------
@ENT_15497_IRONPORT::REMOTE_ALERTS=(

	{	'type'=>'snmp', 'subtype'=>'ASYNCOS-MAIL-MIB::resourceConservationMode', 'class'=>'IRONPORT',
		'descr'=>'IRONPORT - RECURSO EN MODO CONSERVACION', 'severity'=>'2',
		'vardata'=>'resourceConservationReason', 'enterprise'=>'ent.15497',
		'remote2expr'=>[ {'v'=>'v1', 'descr'=>'resourceConservationReason', 'fx'=>'MATCH', 'expr'=>''} ],
		'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'', 
		'action'=>'SET', 'script'=>'', 	'apptype'=>'NET.IRONPORT', 'itil_type'=>'1'  },

	{	'type'=>'snmp', 'subtype'=>'ASYNCOS-MAIL-MIB::powerSupplyStatusChange', 'class'=>'IRONPORT',
		'descr'=>'IRONPORT - CAMBIO DE ESTADO DE LA FUENTE DE ALIMENTACION', 'severity'=>'2',
		'vardata'=>'powerSupplyStatus', 'enterprise'=>'ent.15497',
		'remote2expr'=>[ {'v'=>'v1', 'descr'=>'powerSupplyStatus', 'fx'=>'MATCH', 'expr'=>''} ],
		'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'', 
		'action'=>'SET', 'script'=>'', 	'apptype'=>'NET.IRONPORT', 'itil_type'=>'1'  },

	{	'type'=>'snmp', 'subtype'=>'ASYNCOS-MAIL-MIB::highTemperature', 'class'=>'IRONPORT',
		'descr'=>'IRONPORT - TEMPERATURA EXCESIVA', 'severity'=>'2',
		'vardata'=>'temperatureName', 'enterprise'=>'ent.15497',
		'remote2expr'=>[ {'v'=>'v1', 'descr'=>'temperatureName', 'fx'=>'MATCH', 'expr'=>''} ],
		'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'', 
		'action'=>'SET', 'script'=>'', 	'apptype'=>'NET.IRONPORT', 'itil_type'=>'1'  },

	{	'type'=>'snmp', 'subtype'=>'ASYNCOS-MAIL-MIB::fanFailure', 'class'=>'IRONPORT',
		'descr'=>'IRONPORT - FALLO DEL VENTILADOR', 'severity'=>'2',
		'vardata'=>'fanName', 'enterprise'=>'ent.15497',
		'remote2expr'=>[ {'v'=>'v1', 'descr'=>'fanName', 'fx'=>'MATCH', 'expr'=>''} ],
		'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'', 
		'action'=>'SET', 'script'=>'', 	'apptype'=>'NET.IRONPORT', 'itil_type'=>'1'  },

	{	'type'=>'snmp', 'subtype'=>'ASYNCOS-MAIL-MIB::keyExpiration', 'class'=>'IRONPORT',
		'descr'=>'IRONPORT - CLAVE CADUCADA', 'severity'=>'2',
		'vardata'=>'keyDescription', 'enterprise'=>'ent.15497',
		'remote2expr'=>[ {'v'=>'v1', 'descr'=>'keyDescription', 'fx'=>'MATCH', 'expr'=>''} ],
		'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'', 
		'action'=>'SET', 'script'=>'', 	'apptype'=>'NET.IRONPORT', 'itil_type'=>'1'  },

	{	'type'=>'snmp', 'subtype'=>'ASYNCOS-MAIL-MIB::updateFailure', 'class'=>'IRONPORT',
		'descr'=>'IRONPORT - FALLO DE ACTUALIZACION', 'severity'=>'2',
		'vardata'=>'updateServiceName', 'enterprise'=>'ent.15497',
		'remote2expr'=>[ {'v'=>'v1', 'descr'=>'updateServiceName', 'fx'=>'MATCH', 'expr'=>''} ],
		'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'', 
		'action'=>'SET', 'script'=>'', 	'apptype'=>'NET.IRONPORT', 'itil_type'=>'1'  },

	{	'type'=>'snmp', 'subtype'=>'ASYNCOS-MAIL-MIB::raidStatusChange', 'class'=>'IRONPORT',
		'descr'=>'IRONPORT - CAMBIO DE ESTADO DEL RAID', 'severity'=>'2',
		'vardata'=>'raidID', 'enterprise'=>'ent.15497',
		'remote2expr'=>[ {'v'=>'v1', 'descr'=>'raidID', 'fx'=>'MATCH', 'expr'=>''} ],
		'mode'=>'INC', 'expr'=>'AND', 'monitor'=>'', 'vdata'=>'', 
		'action'=>'SET', 'script'=>'', 	'apptype'=>'NET.IRONPORT', 'itil_type'=>'1'  },

);
#array ( 'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>'')
#cnm-devel1:/opt/crawler/bin# snmptranslate -Td .1.3.6.1.4.1.15497.1.1.2.0.1
#ASYNCOS-MAIL-MIB::resourceConservationMode
#
#---------------------------------------------------------------------------

1;
__END__
