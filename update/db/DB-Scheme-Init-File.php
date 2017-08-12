<?php
// require_once("/var/www/html/onm/tmp/elem_prov.php");

// Tablas que deben inicializar otras tablas. 
// cfg_remote_alerts2expr se rellena en base al id_remote_alert que se obtenga al insertar
// en cfg_remote_alert
// $DBDataESP = array(
   //'cfg_remote_alerts'       => $CFG_REMOTE_ALERTS,
// );

$DBDataCNM = array(
	'cfg_cnms'                => Array(),
);


$DBData = array(
   'cfg_users'                        => $export_data['CFG_USERS'],
//   'cfg_assigned_apps'                => $CFG_ASSIGNED_APPS,
   'cfg_monitor_apps'                 => $export_data['CFG_MONITOR_APPS'],
   'cfg_events_data'                  => $export_data['CFG_EVENTS_DATA'],
   'oid_enterprises'                  => $export_data['OID_ENTERPRISES'],
   'oid_info'                         => $export_data['OID_INFO'],
   'gui_custom_fields'                => $export_data['GUI_CUSTOM_FIELDS'],
   'cfg_remote_alerts'                => $export_data['CFG_REMOTE_ALERTS'],
   'cfg_monitor_snmp'                 => $export_data['CFG_MONITOR_SNMP'],
   'cfg_monitor_agent'                => $export_data['CFG_MONITOR_AGENT'],
   'cfg_monitor_agent_app'            => $export_data['CFG_MONITOR_AGENT_APPS'],
   'cfg_monitor'                      => $export_data['CFG_MONITOR'],
// Nota: La tabla cfg_task_configured tiene como clave id_cfg_task_configured y si se incluye aquí
// se añaden de nuevo en la tabla los elementos. Hay que pensar en modificar la tabla para que el 
// campo subtype sea clave y así no se inserten de nuevo las entradas. Aparte, este cambio vendría
// bien en la parte de tips, por si se pone documentación en las tareas, para que en el campo
// id_ref de tips se metiera el subtype de la tarea.

   'cfg_task_configured'              => $export_data['CFG_TASK_CONFIGURED'],
   'notification_type'                => $export_data['NOTIFICATION_TYPE'],
   'note_types'                       => $export_data['NOTE_TYPES'],
   'cfg_monitor_snmp_esp'             => $export_data['CFG_MONITOR_SNMP_ESP'],
   'cfg_monitor_wbem'                 => $export_data['CFG_MONITOR_WBEM'],
   'cfg_operational_profile'          => $export_data['CFG_ORGANIZATIONAL_PROFILES'],
   'cfg_report'                       => $export_data['CFG_REPORT'],
   'cfg_report2item'                  => $export_data['CFG_REPORT2ITEM'],
//	'cnm_config'				           => $export_data['CNM_CONFIG'],
	'tips'                             => $export_data['TIPS'],
	'cfg_users2organizational_profile' => $export_data['CFG_USERS2ORGANIZATIONALPROFILE'],
	'cfg_script_param'                 => $export_data['CFG_SCRIPT_PARAM'],
	'cfg_monitor_agent_script'         => $export_data['CFG_MONITOR_AGENT_SCRIPT'],
   'cfg_monitor_param'                => $export_data['CFG_MONITOR_PARAM'],
	'cfg_app_param'						  => $export_data['CFG_APP_PARAM'],
	'plugin_base'                      => $export_data['PLUGIN_BASE'],
	'proxy_list'							  => $export_data['PROXY_LIST'],
	'proxy_types'							  => $export_data['PROXY_TYPES'],
	'alert_type'                       => $export_data['ALERT_TYPE'],
	'attr2db'                          => $export_data['ATTR2DB'],

	'tech_group'                       => $export_data['TECH_GROUP'],
	'support_pack'                     => $export_data['SUPPORT_PACK'],
	'support_pack2tech_group'          => $export_data['SUPPORT_PACK2TECH_GROUP'],
);


$DBDataCNM = array(
	'cfg_cnms'                => $export_data['CFG_CNMS'],
);


$DBData2 = array(
	'tips' => Array(),
);

// Datos que deben ser modificados y no insertados
//require_once('/update/db/Init/DB-Scheme-Init-tips.php');
$DBModData = array(
	'tips' => array('data'=>$export_data['TIPS'], 'key'=>array('id_ref','tip_type'),'condition'=>'tip_class=1'),
	'cnm_config' => array('data'=>$export_data['CNM_CONFIG'], 'key'=>array('cnm_key'),'condition'=>"cnm_value=''"),
);

$DBModDataCNM = array();
?>
