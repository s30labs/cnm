<?php

/*
 * $DBExcepcion => Array que va a contener las tablas que deben crearse pero no se debe actualizar su estructura en caso de existir
 * NOTA: Es muy importante que, en caso de existir la tabla devices_custom_data en $DBScheme esté también aquí porque esta tabla
 *       cambia su estructura según se definan campos de usuario de dispositivo.
*/
$DBExcepcion = array(
	'devices_custom_data',
);

// NOTA:
// itil_type: operacion 1, configuracion 2, capacidad 3, disponibilidad 4, seguridad 5
// apptype: hw.xxx app.xxx os.xxx net.xxx serv.xxx user.xxx

//OJO: Hay que poner 2 espacios a la hora de definir las primay keys
// entre KEY y el parentesis.
// 'PRIMARY KEY  (`name`,`time_start`)' =>'',

/*
 * $DBScheme => Array que va a contener la estructura que define la BBDD ONM
*/
$DBScheme = array(
/*	'actions'=>array( //Tabla actions
		'id_action' => "int(11) NOT NULL auto_increment",
		'name' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'descr' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'status' => "int(11) NOT NULL default '0'",
		'time_start' => "int(11) NOT NULL default '0'",
		'time_end' => "int(11) NOT NULL default '0'",
		'cmd' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'id_dev' => "text character set utf8 collate utf8_spanish_ci NOT NULL",
		'params' => "text character set utf8 collate utf8_spanish_ci NOT NULL",
		'rc' => "int(11) NOT NULL default '0'",
		'rcstr' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'mode' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'date_cmd' => "varchar(150) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`name`,`time_start`)' =>'',
		'KEY `id_action` (`id_action`)' =>''
	),

*/
	// format indica el formato del resultado de la accion (0->txt 1->xml)
   'qactions'=>array( //Tabla qactions
      'id_qactions' => "int(11) NOT NULL auto_increment",
      'name' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'descr' => "varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'action' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'task'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'atype' => "int(11) NOT NULL default '0'",
      'cmd' => "varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'params' => "text character set utf8 collate utf8_spanish_ci",
      'auser' => "varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'date_store' => "int(11) default NULL",
      'date_start' => "int(11) NOT NULL default '0'",
      'date_end' => "int(11) default NULL",
      'status' => "int(11) NOT NULL default '0'",
      'rc' => "int(11) NOT NULL default '0'",
      'rcstr' => "text character set utf8 collate utf8_spanish_ci",
      'file' => "varchar(255) character set utf8 collate utf8_spanish_ci DEFAULT NULL",
      'format'=>"int(11) NOT NULL default '0'",
      'id_dev'=>"int(11) NOT NULL default '0'",
      'id_metric'=>"int(11) NOT NULL default '0'",
		'id_proxy'=>"int(11) NOT NULL default '1'",
		'id_alert'=>"int(11) NOT NULL default '0'",
		'pid'=>"int(11) default NULL",
      'PRIMARY KEY  (`name`)' =>'',
      'KEY `id_action` (`id_qactions`)' =>''
   ),
   'qactions_store'=>array( //Tabla qactions_store
      'id_qactions' => "int(11) NOT NULL auto_increment",
      'name' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'descr' => "varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'action' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'atype' => "int(11) NOT NULL default '0'",
      'cmd' => "varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'params' => "varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'auser' => "varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'date_store' => "int(11) default NULL",
      'date_start' => "int(11) NOT NULL default '0'",
      'date_end' => "int(11) default NULL",
      'status' => "int(11) NOT NULL default '0'",
      'rc' => "int(11) NOT NULL default '0'",
      'rcstr' => "text character set utf8 collate utf8_spanish_ci",
      'PRIMARY KEY  (`name`)' =>'',
      'KEY `id_action` (`id_qactions`)' =>''
   ),
	'alert_type'=>array( //Tabla alert_type
		'id_alert_type' => "int(11) NOT NULL auto_increment",
		'cause' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'monitor' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'expr' => "varchar(400) character set utf8 collate utf8_spanish_ci default NULL",
		'params' => "varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'severity' => "int(11) default NULL",
		'mname' => "varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
		'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'wsize' => "int(11) NOT NULL default '0'",
		'class'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'apptype'=>"varchar(100) character set utf8 collate utf8_spanish_ci default ''",
		'hide' => "int(11) NOT NULL default '0'",  //Indica si el monitor es visible o no. Por defecto todos visibles menos los asociados a metricas con iptab=0. hide=0 =>VISIBLE, hide=1=>NO SE MUESTRA
		'PRIMARY KEY  (`monitor`)' => '',
		'KEY `id_alert_type` (`id_alert_type`)' => ''
	),
	'alerts_remote'=>array( //Tabla alerts_remote
		'id_alert'=>"int(11) NOT NULL auto_increment",
		'id_device'=>"int(11) NOT NULL default '0'",
		'id_metric'=>"int(11) NOT NULL default '0'",
		'id_alert_type'=>"int(11) NOT NULL default '0'",
		'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
		'severity'=>"int(11) NOT NULL default '0'",
		'date'=>"int(11) default NULL",
		'ack'=>"int(11) default '0'",
		'counter'=>"int(11) default '-1'",
		'event_data'=>"varchar(2048) character set utf8 collate utf8_spanish_ci default NULL",
		'notif'=>"int(11) default '0'",
		'mname'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'id_note_type'=>"int(11) NOT NULL default '0'",
		'notes'=>"text character set utf8 collate utf8_spanish_ci",
		'note_id'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
		'id_ticket'=>"int(11) NOT NULL default '0'",
		'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'mode'=>"varchar(25) NOT NULL default '0'",
		'correlated'=>"int(11) default '0'",
		'correlated_by'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'domain'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'cid' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cid_ip'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'cause' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		//'ticket_descr'=>"text character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'ticket_descr'=>"varchar(4096) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'date_last'=>"int(11) default NULL",
      'critic'=>"int(11) NOT NULL default '50'",
		'PRIMARY KEY  (`id_device`,`mname`,`mode`,`cid`,`cid_ip`)'=>'',
		'KEY `id_alert_cid` (`id_alert`,`cid`,`cid_ip`)'=>''
	),

   'alerts'=>array( //Tabla alerts
      'id_alert'=>"int(11) NOT NULL auto_increment",
      'id_device'=>"int(11) NOT NULL default '0'",
      'id_metric'=>"int(11) NOT NULL default '0'",
      'id_alert_type'=>"int(11) NOT NULL default '0'",
      'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
      'severity'=>"int(11) NOT NULL default '0'",
      'date'=>"int(11) default NULL",
      'ack'=>"int(11) default '0'",
      'counter'=>"int(11) default '-1'",
      'event_data'=>"varchar(2048) character set utf8 collate utf8_spanish_ci default NULL",
      'notif'=>"int(11) default '0'",
      'mname'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'id_note_type'=>"int(11) NOT NULL default '0'",
      'notes'=>"text character set utf8 collate utf8_spanish_ci",
      'note_id'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
      'id_ticket'=>"int(11) NOT NULL default '0'",
      'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'mode'=>"varchar(25) NOT NULL default '0'",
      'correlated'=>"int(11) default '0'",
      'correlated_by'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'domain'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cid' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cid_ip'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cause' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//		'ticket_descr'=>"text character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'ticket_descr'=>"varchar(4096) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'date_last'=>"int(11) default NULL",
      'critic'=>"int(11) NOT NULL default '50'",
		'bdata'=>"mediumblob",
      'PRIMARY KEY  (`id_device`,`mname`,`mode`,`cid`)'=>'',
      'KEY `id_alert_cid` (`id_alert`,`cid`)'=>''
   ),

	'alerts_store'=>array( //Tabla alerts_store
		'id_alert'=>"int(11) NOT NULL auto_increment",
		'id_device'=>"int(11) NOT NULL default '0'",
		'id_metric'=>"int(11) NOT NULL default '0'",
		'id_alert_type'=>"int(11) NOT NULL default '0'",
		'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
		'severity'=>"int(11) NOT NULL default '0'",
		'date'=>"int(11) default NULL",
		'ack'=>"int(11) default '0'",
		'counter'=>"int(11) default '0'",
		'event_data'=>"text character set utf8 collate utf8_spanish_ci",
		'notif'=>"int(11) default '0'",
		'mname'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'date_store'=>"int(11) default NULL",
		'duration'=>"int(11) default '0'",
		'mnt'=>"int(11) default '0'",
		'id_note_type'=>"int(11) NOT NULL default '0'",
		'id_store'=>"int(11) NOT NULL default '0'",
		'notes'=>"text character set utf8 collate utf8_spanish_ci",
		'note_id'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
		'id_ticket'=>"int(11) NOT NULL default '0'",
		'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'mode'=>"int(11) NOT NULL default '0'",
      'correlated'=>"int(11) default '0'",
      'correlated_by'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'domain'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'cid' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'cid_ip'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'cause' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'date_last'=>"int(11) default NULL",
      'critic'=>"int(11) NOT NULL default '50'",
      'bdata'=>"mediumblob",
		'PRIMARY KEY  (`id_alert`)'=>''
	),
   'alert2response'=>array( //Tabla alert2response
      'id_alert'=>"int(11) NOT NULL default '0'",
      'type'=>"int(11) NOT NULL default '1'",
      'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'date'=>"int(11) default NULL",
      'rc'=>"int(11) NOT NULL default '1'",
      'rcstr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'info'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_alert`,`type`,`descr`)'=>''
   ),

// Se crea en memoria con el procedimiento almacenado.
//   'alert2user'=>array( //Tabla alert2user
//      'id_alert'=>"int(11) NOT NULL default '0'",
//      'login_name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//      'cid' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//      'cid_ip'=>"varchar(15) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//      'PRIMARY KEY  (`id_alert`,`login_name`,`cid`,`cid_ip`)'=>''
//   ),
   'alert2user_remote'=>array( //Tabla alert2user_remote
      'id_alert'=>"int(11) NOT NULL default '0'",
      'login_name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cid' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cid_ip'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_alert`,`login_name`,`cid`,`cid_ip`)'=>''
   ),
	'alerts_summary_op'=>array( //Tabla alerts_summary
		'id_cfg_op'=>"int(11) NOT NULL default '0'",
		'red_alerts'=>"int(11) NOT NULL default '0'",
		'orange_alerts'=>"int(11) NOT NULL default '0'",
		'yellow_alerts'=>"int(11) NOT NULL default '0'",
		'blue_alerts'=>"int(11) NOT NULL default '0'",
		'grey_alerts'=>"int(11) NOT NULL default '0'",
		'devices'=>"int(11) NOT NULL default '0'",
		'red_devices'=>"int(11) NOT NULL default '0'",
		'orange_devices'=>"int(11) NOT NULL default '0'",
		'yellow_devices'=>"int(11) NOT NULL default '0'",
		'blue_devices'=>"int(11) NOT NULL default '0'",
		'events'=>"int(11) NOT NULL default '0'",
		'notices'=>"int(11) NOT NULL default '0'",
		'PRIMARY KEY  (`id_cfg_op`)'=>''
	),

   'alerts_summary_user'=>array( //Tabla alerts_summary
      'id_user'=>"int(11) NOT NULL default '0'",
      'red_views'=>"int(11) NOT NULL default '0'",
      'orange_views'=>"int(11) NOT NULL default '0'",
      'yellow_views'=>"int(11) NOT NULL default '0'",
      'blue_views'=>"int(11) NOT NULL default '0'",
      'grey_views'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_user`)'=>''
   ),

   'notif_alerts_set'=>array( //Tabla notif_alerts_set
      'id_device'=>"int(11) NOT NULL default '0'",
      'id_alert_type'=>"int(11) NOT NULL default '0'",
      'cause' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'domain'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'notif'=>"int(11) default '0'",
		'id_alert'=>"int(11) NOT NULL",
      'mname'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
		'event_data'=>"varchar(2048) character set utf8 collate utf8_spanish_ci default NULL",
		'ack'=>"int(11) default '0'",
      'id_ticket'=>"int(11) NOT NULL default '0'",
		'severity'=>"int(11) NOT NULL default '0'",
      'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
      'date'=>"int(11) default NULL",
      'counter'=>"int(11) default '-1'",
		'id_metric'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_alert`)'=>''
   ),

   'notif_alerts_clear'=>array( //Tabla notif_alerts_clear (antigua alerts_cleared)
      'id_device'=>"int(11) NOT NULL default '0'",
      'id_alert_type'=>"int(11) NOT NULL default '0'",
      'cause' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'domain'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'notif'=>"int(11) default '0'",
      'id_alert'=>"int(11) NOT NULL",
      'mname'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
      'event_data'=>"varchar(2048) character set utf8 collate utf8_spanish_ci default NULL",
      'ack'=>"int(11) default '0'",
      'id_ticket'=>"int(11) NOT NULL default '0'",
      'severity'=>"int(11) NOT NULL default '0'",
      'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
      'date'=>"int(11) default NULL",
      'counter'=>"int(11) default '-1'",
      'id_metric'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_alert`)'=>''
   ),

   'alerts_fifo'=>array( //Tabla alerts_fifo
      'id_dev'=>"int(11) NOT NULL",
      'mname'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL",
      'value'=>"varchar(60) character set utf8 collate utf8_spanish_ci NOT NULL",
      'value_name'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL",
      'ts'=>"int(11) NOT NULL default '0'",
      'mode'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL",
		'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
      'watch_eval'=>"int(11) default '0'",
      'PRIMARY KEY  (`id_dev`,`mname`,`ts`)'=>''
   ),

   'view_alerts'=>array( //Tabla view_alerts
      'id_alert'=>"int(11) NOT NULL auto_increment",
      'id_cfg_view'=>"int(11) NOT NULL default '0'",
      'id_cfg_viewsruleset'=>"int(11) NOT NULL default '0'",
      'severity'=>"int(11) NOT NULL default '0'",
      'date'=>"int(11) default NULL",
      'ack'=>"int(11) default '0'",
      'counter'=>"int(11) default '-1'",
      'event_data'=>"varchar(2048) character set utf8 collate utf8_spanish_ci default NULL",
      'date_last'=>"int(11) default NULL",
      'PRIMARY KEY  (`id_cfg_view`,`id_cfg_viewsruleset`)'=>'',
      'UNIQUE KEY `id_alert` (`id_alert`)'=>''
   ),

   'view_alerts_store'=>array( //Tabla view_alerts_store
      'id_alert'=>"int(11) NOT NULL",
      'id_cfg_view'=>"int(11) NOT NULL default '0'",
      'id_cfg_viewsruleset'=>"int(11) NOT NULL default '0'",
      'severity'=>"int(11) NOT NULL default '0'",
      'date'=>"int(11) default NULL",
      'date_store'=>"int(11) default NULL",
      'duration'=>"int(11) default '0'",
      'ack'=>"int(11) default '0'",
      'counter'=>"int(11) default '-1'",
      'event_data'=>"varchar(2048) character set utf8 collate utf8_spanish_ci default NULL",
      'date_last'=>"int(11) default NULL",
      'PRIMARY KEY  (`id_cfg_view`,`id_cfg_viewsruleset`,`severity`,`date`)'=>'',
      'UNIQUE KEY `id_alert` (`id_alert`)'=>''
   ),

	'cfg_actions'=>array( //Tabla cfg_actions
		'id_cfg_action'=>"int(11) NOT NULL auto_increment",
		'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'type'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'cmd'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'params'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`name`)'=>'',
		'KEY `id_cfg_action` (`id_cfg_action`)'=>''
	),
	'cfg_alerts'=>array( //Tabla cfg_alerts
		'id_cfg_alert'=>"int(11) NOT NULL auto_increment",
		'id_metric'=>"int(11) NOT NULL default '0'",
		'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'PRIMARY KEY  (`id_metric`,`watch`)'=>'',
		'KEY `id_cfg_alert` (`id_cfg_alert`)'=>''
	),
	'cfg_assigned_apps'=>array( //Tabla cfg_assigned_apps
		'id_assigned_app'=>"int(11) NOT NULL auto_increment",
		'myrange'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'id_type'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'include'=>"int(11) NOT NULL default '1'",
		'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'cmd'=>"varchar(200) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`myrange`,`cmd`)'=>'',
		'KEY `id_assigned_app` (`id_assigned_app`)'=>''
	),
	'cfg_assigned_metrics'=>array( //Tabla cfg_assigned_metrics
		'id_assigned_metric'=>"int(11) NOT NULL auto_increment",
		'myrange'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'id_type'=>"int(11) NOT NULL default '0'",
		'include'=>"int(11) NOT NULL default '1'",
		'lapse'=>"int(11) NOT NULL default '0'",
		'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'monitor'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'active_iids'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'PRIMARY KEY  (`myrange`,`id_type`,`type`,`subtype`)'=>'',
		'KEY `id_assigned_metric` (`id_assigned_metric`)'=>''
   ),

   'cfg_monitor_apps'=>array( //Tabla cfg_monitor_apps
      'id_monitor_app'=>"int(11) NOT NULL auto_increment",
      'type'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'itil_type'=>"int(11) NOT NULL default '1'",
		'apptype'=>"varchar(100) character set utf8 collate utf8_spanish_ci default 'app.generic'",
      'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cmd'=>"varchar(160) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'params'=>"varchar(1024) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'myrange'=>"varchar(1024) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cfg'=>"int(11) NOT NULL default '0'",
      'platform'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default '*'",
      'script'=>"varchar(100) character set utf8 collate utf8_spanish_ci default NULL",
      'format'=>"int(11) NOT NULL default '0'",
      'audit'=>"int(11) NOT NULL default '0'",
      'enterprise'=>"int(11) NOT NULL default '0'",
		'custom'=>"int(11) NOT NULL default '0'",
		'aname'=>"varchar(60) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'res'=>"int(11) default '1'",
      'ipparam'=>"varchar(50) default '[;IP;]'",
      'iptab'=>"int(11) default '1'",
		'ready'=>"int(11) NOT NULL default '1'", // 0:not ready|1:ready (indica si aparece el boton de ejecutar)
      'id_proxy'=>"int(11) NOT NULL default '1'",
		'audit'=>"int(11) NOT NULL default '0'", // 0:No es visible en provision|1:Si es visible en provision
      'PRIMARY KEY  (`aname`)'=>'',
      'KEY `id_monitor_app` (`id_monitor_app`)'=>''
   ),

	// Tabla prov_default_apps2device. Relaciona aplicaciones con diospositivos.
   'prov_default_apps2device'=>array( //Tabla prov_default_apps
     	'id_dev'=>"int(11) NOT NULL default '0'",
		'id_monitor_app'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_dev`,`id_monitor_app`)'=>''
   ),

	// Tabla prov_default_metrics2device. Relaciona metricas con dispositivos
	// No es del tipo id_dev/id_metric_xxx porque hay varias tablas de metricas
	// (snmp, latency, xagent ...)
	// A partir de la provision del dispositivo se rellena esta tabla
	// El campo descr no es indispensale pero si es conveniente porque hay diferentes tablas
	// cfg_monitor_xxx y obtenerlo exige hacer uniones.
	// id_default_metric es auxiliar y viene bien para manejar los checkboxes y facilitar las queries
	// El campo include sirve para tener en cuenta si por defecto aparece chequeada la metrica o no
	// en el asistente
   'prov_default_metrics2device'=>array(
      'id_default_metric'=>"int(11) NOT NULL auto_increment",
      'id_dev'=>"int(11) NOT NULL",
      'include'=>"int(11) NOT NULL default '1'",
      'lapse'=>"int(11) NOT NULL default '300'",
      'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_dev`,`type`,`subtype`)'=>'',
      'KEY `id_default_metric` (`id_default_metric`)'=>''
   ),

//   'prov_default_metrics'=>array( //Tabla prov_default_metrics OBSOLETA !!!
//      'id_default_metric'=>"int(11) NOT NULL auto_increment",
//      'myrange'=>"varchar(150) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//      'range_type'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//      'include'=>"int(11) NOT NULL default '1'",
//      'lapse'=>"int(11) NOT NULL default '300'",
//      'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//      'PRIMARY KEY  (`myrange`,`range_type`,`type`,`subtype`)'=>'',
//      'KEY `id_default_metric` (`id_default_metric`)'=>''
//  ),

   'prov_template_metrics'=>array( //Tabla prov_template_metrics
      'id_template_metric'=>"int(11) NOT NULL auto_increment",
      'id_dev'=>"int(11) NOT NULL",
      'id_dest'=>"int(11) NOT NULL",
      'lapse'=>"int(11) NOT NULL default '300'",
      'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_dev`,`subtype`,`id_dest`)'=>'',
      'KEY `id_template_metric` (`id_template_metric`)'=>''
   ),
   'prov_template_metrics2iid'=>array( //Tabla prov_template_metrics2iid
      'id_tm2iid'=>"int(11) NOT NULL auto_increment",
      'id_template_metric'=>"int(11) NOT NULL",
      'id_dev'=>"int(11) NOT NULL",
      'id_dest'=>"int(11) NOT NULL",
      'iid'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
      'hiid'=>"varchar(32) character set utf8 collate utf8_spanish_ci NOT NULL default 'none'",
      'mname'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
      'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'status'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_template_metric`,`hiid`)'=>'',
      'KEY `id_dev` (`id_dev`)'=>'',
      'KEY `id_tm2iid` (`id_tm2iid`)'=>''
   ),

	'cfg_devices2organizational_profile'=>array( //Tabla cfg_devices2organizational_profile
		'id_dev'=>"int(11) NOT NULL default '0'",
		'id_cfg_op'=>"int(11) NOT NULL default '0'",
		'cid' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`id_dev`,`id_cfg_op`,`cid`)'=>''
   ),
	'cfg_events2alerts'=>array( //Tabla cfg_events2alerts
		'id_cfg_event2alert'=>"int(11) NOT NULL auto_increment",
		'id_dev'=>"int(11) NOT NULL default '0'",
		'txt'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'action'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'severity'=>"int(11) default NULL",
		'monitor'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'process'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'PRIMARY KEY  (`id_cfg_event2alert`)'=>''
	),
	'cfg_events_data'=>array( //Tabla cfg_events_data
		'id_cfg_events_data'=>"int(11) NOT NULL auto_increment",
		'process'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'evkey'=>"varchar(180) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'txt_custom'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
		'PRIMARY KEY  (`process`,`evkey`)'=>'',
		'KEY `id_cfg_events_data` (`id_cfg_events_data`)'=>''
   ),

//--------------------------
   'cfg_monitor_analysis'=>array( //Tabla cfg_monitor_analysis
      'id_cfg_monitor_analysis'=>"int(11) NOT NULL auto_increment",
      'asubtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",

      'type'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'monitor'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",

      'PRIMARY KEY  (`asubtype`)'=>'',
      'KEY `id_cfg_monitor_analysis` (`id_cfg_monitor_analysis`)'=>''
   ),

   'cfg_monitor_analysis2device'=>array( //Tabla cfg_monitor_analysis2device
      'asubtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'id_dev'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`asubtype`,`id_dev`)'=>''
   ),

   'cfg_monitor_analysis_store'=>array( //Tabla cfg_monitor_analysis_store
      'asubtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'id_dev'=>"int(11) NOT NULL default '0'",
		'date'=>"int(11) NOT NULL default '0'",
		'data'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`asubtype`,`id_dev`,`date`)'=>''
   ),

//--------------------------


	'cfg_monitor'=>array( //Tabla cfg_monitor
		'id_cfg_monitor'=>"int(11) NOT NULL auto_increment",
		'monitor'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'description'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'info'=>"text character set utf8 collate utf8_spanish_ci",
		'port'=>"int(11) default NULL",
		'shtml'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'params'=>"varchar(1024) character set utf8 collate utf8_spanish_ci default NULL",
		'severity'=>"int(11) default '1'",
		'items'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'mtype'=>"varchar(40) character set utf8 collate utf8_spanish_ci default 'STD_BASEIP1'",
		'vlabel'=>"varchar(30) character set utf8 collate utf8_spanish_ci default NULL",
		'module'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'mod_monitor'",
		'top_value'=>"float default NULL",
		'mode'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
		'cfg'=>"int(11) NOT NULL default '0'",
		'custom'=>"int(11) NOT NULL default '0'",
      'itil_type'=>"int(11) NOT NULL default '1'",
		'apptype'=>"varchar(100) character set utf8 collate utf8_spanish_ci default 'app.generic'",
		'lapse'=>"int(11) NOT NULL default '300'",
		'include'=>"int(11) NOT NULL default '0'",
		'PRIMARY KEY  (`monitor`)'=>'',
		'KEY `id_cfg_monitor` (`id_cfg_monitor`)'=>''

   ),
	'cfg_monitor_agent'=>array( //Tabla cfg_monitor_agent
		'id_cfg_monitor_agent'=>"int(11) NOT NULL auto_increment",
		'subtype'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL",
		'apptype'=>"varchar(100) character set utf8 collate utf8_spanish_ci default 'app.generic'",
		'class'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'description'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'items'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'vlabel'=>"varchar(30) character set utf8 collate utf8_spanish_ci default NULL",
		'mode'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
		'mtype'=>"varchar(40) character set utf8 collate utf8_spanish_ci default NULL",
		'top_value'=>"float default NULL",
		'module'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'nparams'=>"int(11) default '0'",
		'params'=>"varchar(1024) character set utf8 collate utf8_spanish_ci default NULL",
		'params_descr'=>"text character set utf8 collate utf8_spanish_ci",
		'script'=>"varchar(100) character set utf8 collate utf8_spanish_ci default NULL",
		'severity'=>"int(11) NOT NULL default '1'",
		'info'=>"text character set utf8 collate utf8_spanish_ci",
		'cfg'=>"int(11) NOT NULL default '0'",
		'custom'=>"int(11) NOT NULL default '0'",
		'proxy'=>"int(11) NOT NULL default '1'",   # 1:Requiere proxy para funcionar / 0:No lo necesita
      'itil_type'=>"int(11) NOT NULL default '1'",
		'apptype'=>"varchar(100) character set utf8 collate utf8_spanish_ci default 'app.generic'",
      'get_iid'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'lapse'=>"int(11) NOT NULL default '300'",
		'include'=>"int(11) NOT NULL default '1'",
		'id_proxy'=>"int(11) NOT NULL default '1'",
		'proxy_type'=>"varchar(10) character set utf8 collate utf8_spanish_ci NOT NULL default 'linux'",
		'tag'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '001'",
		'iptab'=>"int(11) default '1'", // Indica si se muestra o no la solapa de dispositivos. Indica si la metrica esta totalmente configurada
		'esp'=>"varchar(1024) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'myrange'=>"varchar(1024) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`subtype`)'=>'',
		'KEY `id_cfg_monitor_agent` (`id_cfg_monitor_agent`)'=>''
   ),
   'cfg_script_param'=>array( //Tabla cfg_script_param
      'id_cfg_script_param'=>"int(11) NOT NULL auto_increment",
		'hparam'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL",
		'script'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL",
      'position'=>"int(11) NOT NULL default '0'",
		'prefix'=>"varchar(20) character set utf8 collate utf8_spanish_ci default ''",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci default ''",
		'value'=>"varchar(255) character set utf8 collate utf8_spanish_ci default ''",
		'param_type'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`script`,`position`)'=>'',
      'KEY `id_cfg_script_param` (`id_cfg_script_param`)'=>'',
		'UNIQUE KEY `hparam_unique` (`hparam`)'=>''
   ),
   'cfg_monitor_param'=>array( //Tabla cfg_monitor_param
      'id_cfg_monitor_param'=>"int(11) NOT NULL auto_increment",
		'hparam'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL",
		'script'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL",
      'subtype'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL",
		'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL",
		'enable'=>"int(11) NOT NULL default '0'",
      'value'=>"varchar(255) character set utf8 collate utf8_spanish_ci default ''",
      'KEY `id_cfg_monitor_param` (`id_cfg_monitor_param`)'=>'',
      'PRIMARY KEY  (`script`,`subtype`,`hparam`)'=>'',
   ),

   'cfg_app_param'=>array( //Tabla cfg_app_param
      'id_cfg_app_param'=>"int(11) NOT NULL auto_increment",
      'hparam'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL",
      'script'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL",
      'aname'=>"varchar(60) character set utf8 collate utf8_spanish_ci NOT NULL",
      'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL",
      'enable'=>"int(11) NOT NULL default '0'",
      'value'=>"varchar(255) character set utf8 collate utf8_spanish_ci default ''",
      'KEY `id_cfg_monitor_param` (`id_cfg_app_param`)'=>'',
      'PRIMARY KEY  (`script`,`aname`,`hparam`)'=>'',
   ),

   'cfg_app2device'=>array( //Tabla cfg_app2device
      'aname'=>"varchar(60) character set utf8 collate utf8_spanish_ci NOT NULL",
		'ip'=>"varchar(27) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'id_dev'=>"int(11) NOT NULL default '0'",
		'who'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`aname`,`id_dev`)'=>'',
   ),


   'cfg_monitor_agent_script'=>array( //Tabla cfg_monitor_agent_script
      'id_cfg_monitor_agent_script'=>"int(11) NOT NULL auto_increment",
      'script'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'description'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'id_proxy'=>"int(11) NOT NULL default '1'",
		'proxy_type'=>"varchar(10) character set utf8 collate utf8_spanish_ci NOT NULL default 'linux'",
		'proxy_user'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default 'www-data'",
		'proxy_pwd'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cfg'=>"int(11) NOT NULL default '0'",
      'custom'=>"int(11) NOT NULL default '0'",
      'exec_mode'=>"int(11) NOT NULL default '2'", //0->No visibles, 1->Se ejecutan en proxy local, 2->Se ejecutan en cualquier proxy (de su tipo)
      'size'=>"int(11) NOT NULL default '0'",
      'date'=>"int(11) NOT NULL default '0'",
		'script_data'=>"text character set utf8 collate utf8_spanish_ci",
		'signature' =>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL",
		'timeout'=>"int(11) NOT NULL default '30'",
		'env'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'out_files'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",

      'PRIMARY KEY  (`script`)'=>'',
      'KEY `id_cfg_monitor_agent_script` (`id_cfg_monitor_agent_script`)'=>''
   ),

   'cfg_monitor_agent_app'=>array( //Tabla cfg_monitor_agent_app
      'id_cfg_monitor_agent_app'=>"int(11) NOT NULL auto_increment",
		'name'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'type'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'platform'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'cfg'=>"int(11) NOT NULL default '0'",
      'script'=>"varchar(100) character set utf8 collate utf8_spanish_ci default NULL",
      'params'=>"varchar(1024) character set utf8 collate utf8_spanish_ci default NULL",
		'nparams'=>"int(11) NOT NULL default '0'",
		'sep'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'ip'=>"varchar(27) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'template'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'dev'=>"int(11) default '1'",
		'res'=>"int(11) default '1'",
		'lapse'=>"int(11) NOT NULL default '300'",
		'include'=>"int(11) NOT NULL default '1'",
      'PRIMARY KEY  (`name`)'=>'',
      'KEY `id_cfg_monitor_agent_app` (`id_cfg_monitor_agent_app`)'=>''
   ),
	'cfg_monitor_snmp'=>array( //Tabla cfg_monitor_snmp
		'id_cfg_monitor_snmp'=>"int(11) NOT NULL auto_increment",
		'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'class'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'lapse'=>"int(11) default '300'",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'items'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'oid'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'get_iid'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'vlabel'=>"varchar(30) character set utf8 collate utf8_spanish_ci default NULL",
		'community'=>"varchar(50) character set utf8 collate utf8_spanish_ci default 'public'",
		'mode'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
		'mtype'=>"varchar(40) character set utf8 collate utf8_spanish_ci default NULL",
		'top_value'=>"float default NULL",
		'module'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'mod_snmp_get'",
		'oidn'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'oid_info'=>"text character set utf8 collate utf8_spanish_ci",
		'severity'=>"int(11) default '1'",
		'cfg'=>"int(11) NOT NULL default '0'",
		'custom'=>"int(11) NOT NULL default '0'",
      'itil_type'=>"int(11) NOT NULL default '1'",
		'apptype'=>"varchar(100) character set utf8 collate utf8_spanish_ci default 'net.generic'",
		'myrange'=>"varchar(1024) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'enterprise'=>"int(11) NOT NULL default '0'",
		'include'=>"int(11) NOT NULL default '1'",
		'esp'=>"varchar(1024) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'params'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`subtype`)'=>'',
		'KEY `subtype` (`id_cfg_monitor_snmp`)'=>''
   ),
	'cfg_monitor_snmp_esp'=>array( //Tabla cfg_monitor_snmp_esp
		'id_cfg_monitor_snmp_esp'=>"int(11) NOT NULL auto_increment",
		'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'description'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'info'=>"text character set utf8 collate utf8_spanish_ci",
		'oid'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'class'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'module'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'fx'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'match'",
		'iparams'=>"varchar(150) character set utf8 collate utf8_spanish_ci default NULL",
		'get_iid'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'items'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'vlabel'=>"varchar(30) character set utf8 collate utf8_spanish_ci default NULL",
		'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'mode'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
		'mtype'=>"varchar(40) character set utf8 collate utf8_spanish_ci default NULL",
      'itil_type'=>"int(11) NOT NULL default '1'",
		'apptype'=>"varchar(100) character set utf8 collate utf8_spanish_ci default 'net.generic'",
		'myrange'=>"varchar(1024) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'enterprise'=>"int(11) NOT NULL default '0'",
		'lapse'=>"int(11) NOT NULL default '300'",
		'include'=>"int(11) NOT NULL default '1'",
		'PRIMARY KEY  (`name`)'=>'',
		'KEY `id_cfg_monitor_snmp_esp` (`id_cfg_monitor_snmp_esp`)'=>''
   ),
   'cfg_monitor_wbem'=>array( //Tabla cfg_monitor_wbem
      'id_cfg_monitor_wbem'=>"int(11) NOT NULL auto_increment",
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'namespace'=>"varchar(150) character set utf8 collate utf8_spanish_ci NOT NULL default '/root/cimv2'",
      'class_label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'class'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'lapse'=>"int(11) default '300'",
      'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'items'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'property'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'get_iid'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'vlabel'=>"varchar(30) character set utf8 collate utf8_spanish_ci default NULL",
      'mode'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
      'mtype'=>"varchar(40) character set utf8 collate utf8_spanish_ci default NULL",
      'top_value'=>"float default NULL",
      'module'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'mod_wbem_get'",
      'property_info'=>"text character set utf8 collate utf8_spanish_ci",
      'severity'=>"int(11) default '1'",
      'cfg'=>"int(11) NOT NULL default '0'",
		'custom'=>"int(11) NOT NULL default '0'",
      'itil_type'=>"int(11) NOT NULL default '1'",
		'include'=>"int(11) NOT NULL default '1'",
      'PRIMARY KEY  (`subtype`)'=>'',
      'KEY `id_cfg_monitor_wbem` (`id_cfg_monitor_wbem`)'=>''
   ),
	'cfg_notification2device'=>array( //Tabla cfg_notification2device
		'id_cfg_notification'=>"int(11) NOT NULL default '0'",
		'id_device'=>"int(11) NOT NULL default '0'",
      'iid'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
      'hiid'=>"varchar(32) character set utf8 collate utf8_spanish_ci NOT NULL default 'none'",
      'mname'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'status'=>"int(11) default '0'",
		// 'PRIMARY KEY  (`id_cfg_notification`,`id_device`,`hiid`)'=>''
		'PRIMARY KEY  (`id_cfg_notification`,`id_device`,`hiid`,`mname`)'=>''
   ),
   'cfg_notification2app'=>array( //Tabla cfg_notification2app
      'id_cfg_notification'=>"int(11) NOT NULL default '0'",
      'id_monitor_app'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_cfg_notification`,`id_monitor_app`)'=>''
   ),
	'cfg_notifications'=>array( //Tabla cfg_notifications
		'id_cfg_notification'=>"int(11) NOT NULL auto_increment",
		'id_alert_type'=>"int(11) NOT NULL default '0'",
		'type'=>"int(11) NOT NULL default '0'",
		'type_app'=>"int(11) NOT NULL default '0'",
		'type_run'=>"int(11) NOT NULL default '0'",
		'id_notification_type'=>"int(11) NOT NULL default '0'",
		'name'=>"varchar(155) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'destino'=>"varchar(250) character set utf8 collate utf8_spanish_ci default NULL",
		'status'=>"int(11) NOT NULL default '0'",
		'monitor'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'severity'=>"int(11) NOT NULL default '1'",
		'PRIMARY KEY  (`monitor`,`id_notification_type`,`name`,`severity`)'=>'',
		'KEY `id_cfg_notification` (`id_cfg_notification`)'=>''
   ),
   'cfg_notifications_new'=>array( //Tabla cfg_notifications_new
      'id_cfg_notification'=>"int(11) NOT NULL auto_increment",
      'id_alert_type'=>"int(11) NOT NULL default '0'",
      'type'=>"int(11) NOT NULL default '0'",
      'id_notification_type'=>"int(11) NOT NULL default '0'",
      'name'=>"varchar(155) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'destino'=>"varchar(250) character set utf8 collate utf8_spanish_ci default NULL",
      'status'=>"int(11) NOT NULL default '0'",
      'monitor'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'mail_addr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'sms_tfn'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'trap_dest'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'class' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_cfg_notification`)'=>''
   ),
   'cfg_register_transports'=>array( //Tabla cfg_register_transports
      'id_register_transport'=>"int(11) NOT NULL auto_increment",
      'id_notification_type'=>"int(11) NOT NULL default '0'",
      'name'=>"varchar(155) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'value'=>"varchar(250) character set utf8 collate utf8_spanish_ci NOT NULL",
      'PRIMARY KEY  (`id_notification_type`,`value`)'=>'',
		'KEY `id_register_transport` (`id_register_transport`)'=>''
   ),
   'cfg_notification2transport'=>array( //Tabla cfg_notification2transport
      'id_cfg_notification'=>"int(11) NOT NULL default '0'",
		'id_register_transport'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_cfg_notification`,`id_register_transport`)'=>''
   ),
   'cfg_task2transport'=>array( //Tabla cfg_task2transport
      'id_cfg_task_configured'=>"int(11) NOT NULL default '0'",
      'id_register_transport'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_cfg_task_configured`,`id_register_transport`)'=>''
   ),
	'search_store2cfg_task'=>array( //Tabla search_store2cfg_task
      'id_cfg_task_configured'=>"int(11) NOT NULL default '0'",
      'id_search_store'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_cfg_task_configured`,`id_search_store`)'=>''
   ),
   'search_store2cfg_views2metrics'=>array( //Tabla search_store2cfg_views2metrics
      'id_cfg_view'=>"int(11) NOT NULL default '0'",
      'id_search_store'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_cfg_view`,`id_search_store`)'=>''
   ),
   'search_store2cfg_views2remote_alerts'=>array( //Tabla search_store2cfg_views2remote_alerts
      'id_cfg_view'=>"int(11) NOT NULL default '0'",
      'id_search_store'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_cfg_view`,`id_search_store`)'=>''
   ),


	'cfg_organizational_profile'=>array( //Tabla cfg_organizational_profile
		'id_cfg_op'=>"int(11) NOT NULL auto_increment",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'user_group'=>"varchar(255) character set utf8 collate utf8_spanish_ci default ''",
		//'PRIMARY KEY  (`id_cfg_op`)'=>'',
      ////////////////////////////////////////////////////////////////////
		'KEY `id_cfg_op` (`id_cfg_op`)'=>'',
      'PRIMARY KEY  (`descr`)'=>'',
   ),
   'cfg_operational_profile'=>array( //Tabla cfg_operational_profile
      'id_operational_profile'=>"int(11) NOT NULL auto_increment",
      'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'template'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
		'custom'=>"int(11) NOT NULL default '0'",
      'otrs_type' => "int(11) NOT NULL default '0'", // 0: Agent || 1: Customer
		'KEY `name` (`name`)'=>'',
      'PRIMARY KEY  (`id_operational_profile`)'=>'',
   ),
	'cfg_register_apps'=>array( //Tabla cfg_register_apps
		'id_register_app'=>"int(11) NOT NULL auto_increment",
		'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'info'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
		'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
		'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'cmd'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'params'=>"varchar(1024) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`name`)'=>'',
		'KEY `id_assigned_app` (`id_register_app`)'=>''
   ),
	'cfg_remote_alerts'=>array( //Tabla cfg_remote_alerts
		'id_remote_alert'=>"int(11) NOT NULL auto_increment",
		'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'subtype'=>"varchar(180) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'hiid'=>"varchar(32) character set utf8 collate utf8_spanish_ci NOT NULL default 'ea1c3c284d'",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'monitor'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'vdata'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'mode'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default 'INC'",
		'severity'=>"int(11) NOT NULL default '1'",
		'action'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'script'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'expr' => "varchar(200) character set utf8 collate utf8_spanish_ci NOT NULL default 'AND'",
      'itil_type'=>"int(11) NOT NULL default '1'",
      'apptype'=>"varchar(100) character set utf8 collate utf8_spanish_ci default 'app.generic'",
      'class'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default 'Sin clase'",
      'logfile'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'vardata'=>"varchar(1024) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'enterprise'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default '0'",
		'include'=>"int(11) NOT NULL default '1'",

		'set_id'=>"int(11) NOT NULL default '0'",
		'set_type'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'set_subtype'=>"varchar(180) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'set_hiid'=>"varchar(32) character set utf8 collate utf8_spanish_ci NOT NULL default 'ea1c3c284d'",

		'PRIMARY KEY  (`type`,`subtype`,`hiid`)'=>'',
		'KEY `id_remote_alert` (`id_remote_alert`)'=>''
   ),
   'cfg_remote_alerts2expr'=>array( //Tabla cfg_remote_alerts2expr
      'id_remote_alert'=>"int(11) NOT NULL default '0'",
      'v'=>"varchar(10) character set utf8 collate utf8_spanish_ci NOT NULL default 'v1'",
      'descr'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'fx'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default 'MATCH'",
      'expr'=>"varchar(200) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_remote_alert`,`v`,`expr`)'=>''
   ),
	'cfg_remote_alerts2device'=>array( //Tabla cfg_remote_alerts2device
		'id_remote_alert'=>"int(11) NOT NULL default '0'",
		'target'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default '*'",
		'PRIMARY KEY  (`id_remote_alert`,`target`)'=>''
   ),
	'cfg_user2view'=>array( //Tabla cfg_user2view
		'id_user'=>"int(11) NOT NULL default '0'",
		'id_cfg_view'=>"int(11) NOT NULL default '0'",
      'login_name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cid' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cid_ip'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`login_name`,`id_cfg_view`,`cid`,`cid_ip`)'=>''
   ),
   'cfg_user2report'=>array( //Tabla cfg_user2report
      'id_user'=>"int(11) NOT NULL default '0'",
      'id_cfg_report'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_user`,`id_cfg_report`)'=>''
   ),
	'cfg_users'=>array( //Tabla cfg_users
		'id_user'=>"int(11) NOT NULL auto_increment",
		'login_name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'passwd'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'token'=>"char(100) character set utf8 collate utf8_spanish_ci default NULL",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'perfil'=>"int(11) NOT NULL default '2'",
		'timeout'=>"int(11) NOT NULL default '1440'",
      'params' => "text character set utf8 collate utf8_spanish_ci NOT NULL", // Estructura json que indica las columnas a mostrar
		'firstname' => "varchar(255) character set utf8 collate utf8_spanish_ci default ''",
		'lastname' => "varchar(255) character set utf8 collate utf8_spanish_ci default ''",
		'email' => "varchar(100) character set utf8 collate utf8_spanish_ci default ''",
      'otrs_type' => "int(11) NOT NULL default '0'", // 0: Agent || 1: Customer
		'language'  => "varchar(50) character set utf8 collate utf8_spanish_ci default 'es_ES'", // es_ES|en_US
      'plugin_auth'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default 'local'", // Campo type de la tabla plugin_auth (ldap|local|etc)
		'PRIMARY KEY  (`login_name`)'=>'',
		'UNIQUE KEY `id_user_unique` (`id_user`)'=>''
   ),
   'cfg_users2organizational_profile'=>array( //Tabla cfg_users2organizational_profile
      'id_user'=>"int(11) NOT NULL",
		'id_cfg_op'=>"int(11) NOT NULL default '0'",
      'login_name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_user`,`id_cfg_op`)'=>''
   ),
	'cfg_views'=>array( //Tabla cfg_views
		'id_cfg_view'=>"int(11) NOT NULL auto_increment",
		'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'type'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'itil_type'=>"int(11) NOT NULL default '1'",
		'function'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'weight'=>"int(11) NOT NULL default '0'",
		'background'=>"varchar(255) character set utf8 collate utf8_spanish_ci default ''",
		'ruled'=>"int(11) NOT NULL default '0'",
		'severity'=>"int(11) NOT NULL default '6'",
		'red'=>"int(11) NOT NULL default '0'",
		'orange'=>"int(11) NOT NULL default '0'",
		'yellow'=>"int(11) NOT NULL default '0'",
		'blue'=>"int(11) NOT NULL default '0'",
		'cid' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'cid_ip'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'global'=>"int(11) NOT NULL default '0'",
      'live_metric'=>"int(11) NOT NULL default '0'",		// 0=>Vista estandar, 1=>Vista dinamica. Usa busq. almacenadas.
      'live_remote'=>"int(11) NOT NULL default '0'",		// 0=>Vista estandar, 1=>Vista dinamica. Usa busq. almacenadas.
		'nmetrics'=>"int(11) NOT NULL default '0'",
		'nremote'=>"int(11) NOT NULL default '0'",
		'nsubviews'=>"int(11) NOT NULL default '0'",
      'internal'=>"int(11) NOT NULL default '1'",
		'sla'=>"int(11) NOT NULL default '0'",
		'sla_red_typea'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'sla_orange_typea'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'sla_yellow_typea'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'sla_red_typeb'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'sla_orange_typeb'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'sla_yellow_typeb'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'sla_red_typec'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'sla_orange_typec'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'sla_yellow_typec'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'subtype_cfg_report_typea'=>"varchar(20) NOT NULL default ''",  // En caso de tener asociado un report de disponibilidad de severidad roja, aqui se pone el subtype_cfg_report
      'subtype_cfg_report_typeb'=>"varchar(20) NOT NULL default ''",  // En caso de tener asociado un report de disponibilidad de severidad naranja, aqui se pone el subtype_cfg_report
      'subtype_cfg_report_typec'=>"varchar(20) NOT NULL default ''",  // En caso de tener asociado un report de disponibilidad de severidad amarilla, aqui se pone el subtype_cfg_report
		'label_report_typea'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'Disponibilidad'",
		'label_report_typeb'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'Degradación'",
		'label_report_typec'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'Continuidad'",

		'PRIMARY KEY  (`name`,`cid`)'=>'',
		'KEY `id_cfg_view_cid_cid_ip` (`id_cfg_view`,`cid`,`cid_ip`)'=>''
   ),
	'cfg_views2metrics'=>array( //Tabla cfg_views2metrics
		'id_cfg_view'=>"int(11) NOT NULL default '0'",
		'id_metric'=>"int(11) NOT NULL default '0'",
		'id_device'=>"int(11) NOT NULL default '0'",
		'graph'=>"bigint(20) default NULL",
		'size'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default '350x100'",
		'PRIMARY KEY  (`id_cfg_view`,`id_metric`)'=>'',
		'KEY `id_device` (`id_device`)'=>''
   ),
   'cfg_views2views'=>array( //Tabla cfg_views2views
      'id_cfg_view'=>"int(11) NOT NULL default '0'",
      'cid_view' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cid_ip_view'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'id_cfg_subview'=>"int(11) NOT NULL default '0'",
      'cid_subview' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cid_ip_subview'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'graph'=>"bigint(20) default NULL",
      'size'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default '350x100'",
      // 'PRIMARY KEY  (`id_cfg_view`,`id_cfg_subview`)'=>''
      'PRIMARY KEY  (`id_cfg_view`,`id_cfg_subview`,`cid_view`,`cid_ip_view`,`cid_subview`,`cid_ip_subview`)'=>''
   ),
   'cfg_views2remote_alerts'=>array( //Tabla cfg_views2remote_alerts
      'id_cfg_view'=>"int(11) NOT NULL default '0'",
		'id_remote_alert'=>"int(11) NOT NULL default '0'",
		'id_dev'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_cfg_view`,`id_remote_alert`,`id_dev`)'=>''
   ),
   'cfg_views2items'=>array( //Tabla cfg_views2items
      'id_cfg_view'=>"int(11) NOT NULL default '0'",
      'item'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'graph'=>"bigint(20) default NULL",
      'size'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default '350x100'",
      'PRIMARY KEY  (`id_cfg_view`,`item`)'=>''
   ),
   'cfg_viewsruleset'=>array( //Tabla cfg_viewruleset
      'id_cfg_viewsruleset'=>"int(11) NOT NULL auto_increment",
      'id_cfg_view'=>"int(11) NOT NULL default '0'",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'severity'=>"int(11) NOT NULL default '1'",
      'weight'=>"int(11) NOT NULL default '0'",
      'logic'=>"varchar(10) NOT NULL default 'AND'",
		'rule_int'=>"text character set utf8 collate utf8_spanish_ci",
		// 'rule_txt'=>"text character set utf8 collate utf8_spanish_ci",
      'PRIMARY KEY  (`id_cfg_viewsruleset`)'=>''
   ),

	'device2features'=>array( //Tabla device2features
		'id_dev'=>"int(11) NOT NULL default '0'",
		'id_feature'=>"int(11) NOT NULL default '0'",
		'feature_type'=>"varchar(40) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`id_dev`,`id_feature`,`feature_type`)'=>''
	),
	'devices'=>array( //Tabla devices
		'id_dev'=>"int(11) NOT NULL auto_increment",
		'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'domain'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'sysloc'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'Desconocido'",
		'sysdesc'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'Desconocido'",
		'sysoid'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'Desconocido'",
			'txml'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'type'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'app'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'status'=>"int(11) NOT NULL default '0'",
		'mode'=>"int(11) default '0'",
		'community'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'public'",
		'version'=>"varchar(2) character set utf8 collate utf8_spanish_ci default '1'",
	      'wbem_user'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
   	   'wbem_pwd'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
			'xagent_version'=>"varchar(255) character set utf8 collate utf8_spanish_ci default ''",
		'refresh'=>"int(11) default '0'",
		'aping'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default '0'",
		'aping_date'=>"int(11) NOT NULL default '0'",
		'id_cfg_op'=>"int(11) NOT NULL default '0'",
		'host_idx'=>"int(11) NOT NULL default '1'",
		'background'=>"varchar(255) character set utf8 collate utf8_spanish_ci default ''",
		'enterprise'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default '0'",
		'email'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'correlated_by'=>"int(11) default '0'",
		'critic'=>"int(11) default '50'",
		'mac'=>"varchar(20) character set utf8 collate utf8_spanish_ci default ''",
		'mac_vendor'=>"varchar(70) character set utf8 collate utf8_spanish_ci default '-'",
		'geodata'=>"varchar(30) character set utf8 collate utf8_spanish_ci default ''",
		'serialn'=>"varchar(70) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'network'=>"varchar(50) NOT NULL default ''",
      'switch'=>"int(11) NOT NULL default '0'",
		'entity'=>"int(11) NOT NULL default '0'", // 0:Dispositivo físico||1:Web
		'rule_subtype'=>"varchar(30) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL default '00000000'",
		'wsize' => "int(11) NOT NULL default '0'",
		'dyn' => "int(11) NOT NULL default '0'", // Indica si su ip es dinamica (0:estatica|1:dinamica)
		'asset_container' => "int(11) NOT NULL default '0'", // Indica si es un contenedor de metricas de assets (0: No|1:Si)
		'PRIMARY KEY  (`ip`,`host_idx`)'=>'',
		'KEY `id_dev` (`id_dev`)'=>''
   ),
   'devices_types2app'=>array( // Tabla devices_types2app: Permite asociar tipos de dispositivos a aplicaciones para importar datos automaticamente
		'id_host_type'=>"int(11) NOT NULL default '0'",
      'aname'=>"varchar(60) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'type'=>"int(11) NOT NULL default '0'", // 0: Sirve para descubrir || 1: Sirve para mantenimiento
      'PRIMARY KEY  (`id_host_type`,`aname`,`type`)'=>'',
   ),

	'devices_custom_data'=>array( //Tabla devices_custom_data
		'id_dev'=>"int(11) NOT NULL default '0'",
		'PRIMARY KEY  (`id_dev`)'=>'',
   ),
	'devices_custom_types'=>array( //Tabla devices_custom_types
		'id'=>"int(11) NOT NULL auto_increment",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'tipo'=>"int(11) default NULL",
		'PRIMARY KEY  (`descr`)'=>'',
		'UNIQUE KEY `id` (`id`)'=>''
   ),
	'devices_ip'=>array( //Tabla devices_ip
		'id_dev'=>"int(11) NOT NULL default '0'",
		'ip'=>"varchar(57) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`id_dev`,`ip`)'=>''
   ),
   'cfg_devices2items'=>array( //Tabla cfg_devices2items
      'id_dev'=>"int(11) NOT NULL default '0'",
      'item'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'graph'=>"bigint(20) default NULL",
      'size'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default '350x100'",
      'PRIMARY KEY  (`id_dev`,`item`)'=>''
   ),
   'profiles_snmpv3'=>array( //Tabla profiles_snmpv3
		'id_profile'=>"int(11) NOT NULL auto_increment",
      'profile_name'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'sec_name'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'sec_level'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'auth_proto'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default 'MD5'",
      'auth_pass'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'priv_proto'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default 'DES'",
      'priv_pass'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_profile`)'=>'',
		'UNIQUE KEY `profile_name` (`profile_name`)'=>''
   ),


   'proxy_list'=>array( //Tabla proxy_list
      'id_proxy'=>"int(11) NOT NULL auto_increment",
      'proxy_host'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'proxy_port'=>"int(11) default '22'",
      'proxy_type'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'proxy_user'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'proxy_pwd'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'proxy_passphrase'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'proxy_key_path'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'proxy_options'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'proxy_exec_prefix'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_proxy`)'=>'',
      'UNIQUE KEY `proxy_host` (`proxy_host`,`proxy_port`)'=>''
   ),

   'proxy_types'=>array( //Tabla proxy_types
      'id_proxy_type'=>"int(11) NOT NULL auto_increment",
		'proxy_type'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'proxy_descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_proxy_type`)'=>'',
		'UNIQUE KEY `proxy_type` (`proxy_type`)'=>''
   ),


	'events'=>array( //Tabla events
		'id_event'=>"int(11) NOT NULL auto_increment",
		'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'domain'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci default NULL",
		'date'=>"int(11) default NULL",
		'code'=>"int(11) default NULL",
		'proccess'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'msg'=>"text character set utf8 collate utf8_spanish_ci",
		'msg_custom'=>"text character set utf8 collate utf8_spanish_ci",
		'evkey'=>"varchar(180) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'id_dev'=>"int(11) NOT NULL default '0'",
		'PRIMARY KEY  (`id_event`)'=>''
   ),
	'gui_custom_fields'=>array( //Tabla gui_custom_fields
		'id'=>"int(11) NOT NULL auto_increment",
		'gtable'=>"varchar(150) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'gfield'=>"varchar(150) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'gsql'=>"varchar(150) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'gtitle'=>"varchar(150) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'position'=>"int(11) NOT NULL default '0'",
		'status'=>"int(11) NOT NULL default '0'",
		'PRIMARY KEY  (`gtable`,`gfield`)'=>'',
		'KEY `id` (`id`)'=>''
   ),
	'lists'=>array( //Tabla lists
		'id_list'=>"int(11) NOT NULL auto_increment",
		'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'members'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
		'PRIMARY KEY  (`name`)'=>'',
		'KEY `id_list` (`id_list`)'=>''
   ),
	'metric2agent'=>array( //Tabla metric2agent
		'id_metric'=>"int(11) NOT NULL default '0'",
		'monitor'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'monitor_data'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'PRIMARY KEY  (`id_metric`,`monitor`)'=>''
   ),
	'metric2latency'=>array( //Tabla metric2latency
		'id_metric'=>"int(11) NOT NULL default '0'",
		'monitor'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'monitor_data'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'PRIMARY KEY  (`id_metric`,`monitor`)'=>''
   ),	
	'metric2snmp'=>array( //Tabla metric2snmp
		'id_metric'=>"int(11) NOT NULL default '0'",
		'community'=>"varchar(50) character set utf8 collate utf8_spanish_ci default 'public'",
		'oid'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'version'=>"varchar(5) character set utf8 collate utf8_spanish_ci default NULL",
		'PRIMARY KEY  (`id_metric`)'=>''
   ),
   'metrics'=>array( //Tabla metrics
		'id_metric'=>"int(11) NOT NULL auto_increment",
		'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'id_dev'=>"int(11) NOT NULL default '0'",
		'id_dest'=>"int(11) NOT NULL default '0'",
		'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
		'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'items'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'lapse'=>"int(11) default NULL",
		'file_path'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'file'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'host'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'vlabel'=>"varchar(30) character set utf8 collate utf8_spanish_ci default NULL",
		'graph'=>"bigint(20) default NULL",
		'top_value'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'mtype'=>"varchar(40) character set utf8 collate utf8_spanish_ci default NULL",
		'mode'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
		'module'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'status'=>"int(11) NOT NULL default '0'",
		'crawler_idx'=>"int(11) default NULL",
		'crawler_pid'=>"int(11) default NULL",
		'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
		'refresh'=>"int(11) default '0'",
		//'disk'=>"int(11) default '0'",
		'subtable'=>"int(11) default '-1'",
		'c_label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'c_items'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'c_vlabel'=>"varchar(30) character set utf8 collate utf8_spanish_ci default NULL",
		'c_mtype'=>"varchar(40) character set utf8 collate utf8_spanish_ci default NULL",
		'severity'=>"int(11) default '1'",
		'size'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default '350x100'",
		'host_idx'=>"int(11) NOT NULL default '1'",
		'iid'=>"varchar(240) character set utf8 collate utf8_spanish_ci default NULL",
		'correlate'=>"int(11) NOT NULL default '0'",
		'PRIMARY KEY  (`name`,`id_dev`,`host_idx`)'=>'',
		'KEY `id_metric` (`id_metric`)'=>''
   ),
   'note_types'=>array( //Tabla note_types
		'id_note_type'=>"int(11) NOT NULL auto_increment",
		'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`name`)'=>'',
		'KEY `id_note_type` (`id_note_type`)'=>''
   ),
   'cfg_views_types'=>array( //Tabla cfg_views_types contiene los tipos de vista definidos por el usuario
      'id_view_type'=>"int(11) NOT NULL auto_increment",
      'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`name`)'=>'',
      'KEY `id_view_type` (`id_view_type`)'=>''
   ),
   'notification_type'=>array( //Tabla notification_type
		'id_notification_type'=>"int(11) NOT NULL auto_increment",
		'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'dest_field'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'PRIMARY KEY  (`id_notification_type`)'=>''
   ),
   'notifications'=>array( //Tabla notifications
		'id_notif'=>"int(11) NOT NULL auto_increment",
		'id_cfg_notification'=>"int(11) NOT NULL default '0'",
		'date'=>"int(11) default NULL",
		'rc'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'msg'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'id_dev'=>"int(11) NOT NULL default '0'",
		'PRIMARY KEY  (`id_notif`)'=>'',
		'KEY `id_cfg_notification` (`id_cfg_notification`)'=>''
   ),
	'oid_enterprises'=>array( //Tabla oid_enterprises
		'oid'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'device'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`oid`)'=>''
   ),
   'oid_info'=>array( //Tabla oid_info
		'oid'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'device'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`oid`)'=>''
   ),
	'sessions_table'=>array( //Tabla sessions_table
		'SID'=>"varchar(32) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'expiration'=>"int(11) default '0'",
		'value'=>"text character set utf8 collate utf8_spanish_ci",
		'user'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'multi'=>"varchar(16000) character set utf8 collate utf8_spanish_ci NOT NULL default ''", //255.255.255.255(15)|cid(20)=35 caracteres por cnm. 100 cnms deben ser como mucho 4000 caracteres y como cada caracter son 4 bytes, 4000x4=16000 bytes
		'origin'=>"varchar(32) character set utf8 collate utf8_spanish_ci NOT NULL default 'gui'", // Indica el origen de la sesion (gui|api)
		'PRIMARY KEY  (`SID`)'=>''
   ),	
	'tips'=>array( //Tabla tips
		'id_tip'=>"int(11) NOT NULL auto_increment",
		'id_ref'=>"varchar(180) NOT NULL default ''",
		'tip_type'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'name'=>"varchar(130) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'descr'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
		'url'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'date'=>"int(11) NOT NULL default '0'",
		'tip_class'=>"int(11) NOT NULL default '0'",
		'hiid'=>"varchar(32) character set utf8 collate utf8_spanish_ci NOT NULL default 'ea1c3c284d'",
		'id_refn'=>"int(11) NOT NULL default '0'",
		//'PRIMARY KEY  (`id_tip`)'=>'',
		//'KEY (`id_ref`,`tip_type`)'=>''
		'position'=>"int(11) NOT NULL default '0'",
		'PRIMARY KEY  (`id_ref`,`tip_type`,`name`,`hiid`)'=>'',
		'KEY `id_tip` (`id_tip`)'=>'',
		'KEY `id_refn` (`id_refn`)'=>''



   ),
   'tmp_log'=>array( //Tabla tmp_log
		'clave'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'date'=>"int(11) NOT NULL default '0'",
		'id'=>"int(11) NOT NULL default '0'",
		'status'=>"int(1) NOT NULL default '0'",
		'separador'=>"char(1) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'pid'=>"int(11) NOT NULL default '0'",
		'data'=>"text character set utf8 collate utf8_spanish_ci",
		'PRIMARY KEY  (`id`)'=>''
   ),
   'ticket'=>array( //Tabla ticket
		'id_ticket'=>"int(11) NOT NULL auto_increment",
  		'id_dev'=>"int(11) NOT NULL",
  		'id_alert'=>"int(11) NOT NULL",
  		'ticket_type'=>"int(11) NOT NULL",
		'id_problem'=>"int(11) NOT NULL",
  		//'descr'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
		'descr'=>"varchar(4096) character set utf8 collate utf8_spanish_ci NOT NULL default ''",

  		'ref'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
  		'date_store'=>"int(11) NOT NULL",
		'login_name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
  		'event_data'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_dev`,`id_alert`)'=>'',
      'KEY `id_ticket` (`id_ticket`)'=>''
   ),
   'cfg_task_configured'=>array( //Tabla cfg_task_configured
      'id_cfg_task_configured'=>"int(11) NOT NULL auto_increment",
      'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'frec'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'date'=>"int(11) NOT NULL default '0'",
		'cron'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'task'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'done'=>"int(11) default '0'",
		'exec'=>"int(11) default '0'",
//atype:	0:online (actions, store en /app-ip) 
//			10:diferido-app-ip (actionsd, store en /app-ip) 
//			11:diferido-app (actionsd, store en /app) 
// 		12:diferido-planificado (actionsd, store en /task) 
//			13:diferido-evento (actionsd, store en /task)
      'atype'=>"int(11) default '0'",
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'params'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
		'role'=>"varchar(10) character set utf8 collate utf8_spanish_ci NOT NULL default 'active'",
      'user' => "varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'UNIQUE KEY `subtype` (`subtype`)'=>'',
      'PRIMARY KEY  (`id_cfg_task_configured`)'=>'',
   ),
//   'cfg_task_supported'=>array( //Tabla cfg_task_supported
//      'id_cfg_task_supported'=>"int(11) NOT NULL auto_increment",
//      'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//      'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//      'type'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//		'sep'=>"varchar(5) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//		'template'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//		'dev'=>"int(11) default '1'",
//		'res'=>"int(11) default '0'",
//		'unit'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//		'custom'=>"int(11) default '0'",
//      'script'=>"varchar(100) character set utf8 collate utf8_spanish_ci default ''",
//      'params'=>"varchar(255) character set utf8 collate utf8_spanish_ci default ''",
//      'ip'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
//      'PRIMARY KEY  (`name`)'=>'',
//		'KEY `id_cfg_task_supported` (`id_cfg_task_supported`)'=>''	
//   ),
   'task2device'=>array( //Tabla task2device
      'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'type'=>"varchar(55) character set utf8 collate utf8_spanish_ci NOT NULL default 'device'",
      'id_dev'=>"int(11) NOT NULL default '0'",
      'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`name`,`type`,`id_dev`)'=>'',
   ),
   'rule_prov2device'=>array( //Tabla rule_prov2device Contiene el xml con las reglas de provision del dispositivo
      'id_dev'=>"int(11) NOT NULL",
      'rules'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
      'PRIMARY KEY  (`id_dev`)'=>'',
   ),
/*
	//OBSOLETA. ESTA TABLA GUARDA EL XML A PELO
   'rule_prov2device'=>array( //Tabla rule_prov2device Contiene el xml con las reglas de provision del dispositivo
      'id_dev'=>"int(11) NOT NULL",
      'rules'=>"text character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_dev`)'=>'',
   ),
*/

	//prov_default_rules2device
	//Contiene las rules de un determinado dispositivo
   'prov_default_rules2device'=>array(
      'id_dev'=>"int(11) NOT NULL",
      'mtype'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'pattern'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'mode'=>"int(11) NOT NULL default '0'",
		'action'=>"int(11) NOT NULL default '0'",
		'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
      'PRIMARY KEY  (`id_dev`,`mtype`,`subtype`,`pattern`)'=>'',
   ),

	//prov_default_rules_templates
	//Contiene las rules de un determinado templates
   'prov_default_rules_templates'=>array(
      'id_rules_template'=>"int(11) NOT NULL",
      'mtype'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'pattern'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'mode'=>"int(11) NOT NULL default '0'",
      'action'=>"int(11) NOT NULL default '0'",
      'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
      'rule_order'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_rules_template`,`mtype`,`subtype`,`pattern`)'=>'',
   ),

   //cfg_rules_template
   //Almacena los templates de rules
   'cfg_rules_template'=>array(
      'id_rules_template'=>"int(11) NOT NULL auto_increment",
      'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_rules_template`)'=>'',
   ),

	//cfg_rules_template2type
	//Asocia template de rules a un determinado tipo de dispositivo
   'cfg_rules_template2type'=>array(
      'id_rules_template'=>"int(11) NOT NULL",
      'id_host_type'=>"int(11) NOT NULL",
      'PRIMARY KEY  (`id_rules_template`,`id_host_type`)'=>'',
   ),

	//cfg_host_types
	//Define los difentes tipos de dispositivo
   'cfg_host_types'=>array(
      'id_host_type'=>"int(11) NOT NULL auto_increment",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`descr`)'=>'',
      'KEY `id_host_type` (`id_host_type`)'=>'',
   ),

	//credentials
   'credentials'=>array( //Tabla credentials
      'id_credential'=>"int(11) NOT NULL auto_increment",
      'name'=>"varchar(32) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'descr'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'type'=>"varchar(25) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'user'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'pwd'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'port'=>"int(11) default NULL",
      'passphrase'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'key_file'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'scheme'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'PRIMARY KEY  (`name`,`type`)'=>'',
      'KEY `id_credential` (`id_credential`)'=>'',
      // 'UNIQUE KEY `name` (`name`,`type`)'=>'',
      // 'PRIMARY KEY  (`id_credential`)'=>'',
   ),

	//device2credential
   'device2credential'=>array( //Tabla device2credential
      'id_dev'=>"int(11) NOT NULL default '0'",
      'id_credential'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_dev`,`id_credential`)'=>''
   ),

   //device2log
   'device2log'=>array( //Tabla device2log
		'id_device2log'=>"int(11) NOT NULL auto_increment",
      'id_dev'=>"int(11) NOT NULL default '0'",
      'id_credential'=>"int(11) NOT NULL default '0'",
		'logfile'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'script'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'linux_log_parser.pl'",
		'parser'=>"varchar(25) character set utf8 collate utf8_spanish_ci default 'syslog'",
		'todb'=>"int(11) NOT NULL default '0'",   //0:captura,1:syslog
		'status'=>"int(11) NOT NULL default '0'", //0:activo,1:inactivo
		'last_access'=>"int(11) NOT NULL default '0'",
		'last_line'=>"int(11) NOT NULL default '0'",
		'rc'=>"int(11) NOT NULL default '0'",
		'rcstr'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'OK'",
		'tabname'=>"varchar(255) character set utf8 collate utf8_spanish_ci default ''",
		'app_id'=>"varchar(20) character set utf8 collate utf8_spanish_ci default '000000000000'",
      'UNIQUE KEY `dev2log` (`id_dev`,`logfile`)'=>'',
		'PRIMARY KEY  (`id_device2log`)'=>'',
   ),

   'syslog_filters'=>array( //Tabla syslog_filters
      'id'=>"int(11) NOT NULL auto_increment",
      'tipo'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default 'netmask'",
      'valor'=>"varchar(200) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`tipo`,`valor`)'=>'',
      'UNIQUE KEY `id` (`id`)'=>''
   ),


   //-----------------------------------------------------------
   //-----------------------------------------------------------
   //cfg_calendars
	//data: Array en JSON con la lista de valores de cron que definen el calendario
   'cfg_calendars'=>array(
      'id_calendar'=>"int(11) NOT NULL auto_increment",
      'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'data'=>"text character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_calendar`)'=>'',
   ),

   //cfg_task2calendar
	//mode: 1=>include | 0=>exclude
   'cfg_task2calendar'=>array(
		'id_cfg_task_configured'=>"int(11) NOT NULL default '0'",
      'id_calendar'=>"int(11) NOT NULL default '0'",
      'mode'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_cfg_task_configured`,`id_calendar`)'=>'',
   ),


	//-----------------------------------------------------------
	//-----------------------------------------------------------
   //kb_arp_global
   'kb_arp_global'=>array(
		'id_arp'=>"int(11) NOT NULL auto_increment",
		'host_ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'mac'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'date'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`host_ip`,`mac`,`ip`)'=>'',
      'KEY `id_arp` (`id_arp`)'=>'',
   ),
   //kb_arp -> La clave es solo la mac y la ip para no tener duplicados
   'kb_arp'=>array(
      'id_arp'=>"int(11) NOT NULL auto_increment",
      'host_ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'mac'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'date'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`mac`,`ip`)'=>'',
      'KEY `id_arp` (`id_arp`)'=>'',
   ),

   //-----------------------------------------------------------
   //-----------------------------------------------------------
   //kb_cam
   'kb_cam'=>array(
      'id_cam'=>"int(11) NOT NULL auto_increment",
      'host_ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'iid'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'mac'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'vlan_id'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'vlan_name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'date'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`host_ip`,`mac`,`vlan_id`)'=>'',
      'KEY `id_cam` (`id_cam`)'=>'',
   ),

   //-----------------------------------------------------------
   //-----------------------------------------------------------
   //kb_cdp
   'kb_cdp'=>array(
      'id_cdp'=>"int(11) NOT NULL auto_increment",
      'host_ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'iid'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'device_id'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'platform'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'device_port'=>"varchar(100) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'version'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'date'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`host_ip`,`iid`,`ip`,`device_id`)'=>'',
      'KEY `id_cdp` (`id_cdp`)'=>'',
   ),

   //-----------------------------------------------------------
   //-----------------------------------------------------------
   //kb_interfaces
   'kb_interfaces'=>array(
      'id_if'=>"int(11) NOT NULL auto_increment",
      'host_ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'iid'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifDescr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifAlias'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifPhysAddress'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifMtu'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifType'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifSpeed'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifOperStatus'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifAdminStatus'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifIp'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'trunk'=>"int(11) NOT NULL default '0'",
      'date'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`host_ip`,`iid`)'=>'',
      'KEY `id_if` (`id_if`)'=>'',
   ),
   //-----------------------------------------------------------
   //-----------------------------------------------------------
   //ipam_switch_info
   'ipam_switch_info'=>array(
      'id_port'=>"int(11) NOT NULL auto_increment",
      'ip_switch'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'iid'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifDescr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifAlias'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'trunk'=>"int(11) NOT NULL default '0'",
      'ifPhysAddress'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifMtu'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifType'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifSpeed'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifOperStatus'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ifAdminStatus'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'mac'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'vlan_id'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'vlan_name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'domain'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'date'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`ip_switch`,`iid`,`mac`,`vlan_id`)'=>'',
      'KEY `id_port` (`id_port`)'=>'',
   ),

	'oid_tree'=>array(
		'oid_n'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'oid_n_parent'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'oid_s'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
		'PRIMARY KEY  (`oid_n`)'=>'',
	),

   //-----------------------------------------------------------
   //-----------------------------------------------------------
   //report
   //
   'cfg_report'=>array( //Tabla cfg_report
      'id_cfg_report'=>"int(11) NOT NULL auto_increment",
      'subtype_cfg_report'=>"varchar(20) NOT NULL default ''",
      'title'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'description'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'custom'=>"int(11) NOT NULL default '0'",
      'itil_type'=>"int(11) NOT NULL default '1'",
      'apptype'=>"varchar(100) character set utf8 collate utf8_spanish_ci default 'app.generic'",
      'store'=>"int(11) NOT NULL default '0'", //0: No se guarda, 1: Se guarda
      'logic'=>"varchar(16) NOT NULL default 'OR'", //OR|AND
		'mobile'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_cfg_report`)'=>'',
      'UNIQUE KEY `subtype_cfg_report` (`subtype_cfg_report`)'=>'',
   ),

   'cfg_report2item'=>array( //Tabla cfg_report2item
      'id_cfg_report2item'=>"int(11) NOT NULL auto_increment",
      'subtype_cfg_report'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'id'=>"varchar(10) character set utf8 collate utf8_spanish_ci NOT NULL",
      'title'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'col'=>"int(11) NOT NULL default '1'",   // col: indica el numero de columnas que va a ocupar (1..4)
      'row'=>"int(11) NOT NULL default '1'",   // row: indica el numero de filas que va a ocupar (1..8)
      'type'=>"int(11) NOT NULL default '0'", // type: 0:grid,1:graph_line, 2:graph_bar, 3:graph_pie
      'draggable'=>"int(11) NOT NULL default '1'", // 1:si draggable, 0:no dragabble
      'posX'=>"int(11) NOT NULL default '15'", // en px
      'posY'=>"int(11) NOT NULL default '15'", // en px
      'data_fx'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL",
		'params'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'item_order'=>"int(11) NOT NULL default '0'", // permite calcular los items de forma ordenada 
		'mobile'=>"int(11) NOT NULL default '0'", // 0:desktop||1:mobile
      'PRIMARY KEY  (`subtype_cfg_report`,`id`,`mobile`)'=>'',
      'KEY `id_cfg_report2item` (`id_cfg_report2item`)'=>'',
   ),

	'cfg_report2config'=>array(
		'id_cfg_report2config'=>"int(11) NOT NULL auto_increment",
		'subtype_cfg_report'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'cfg_table'=>"varchar(32) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'field'=>"varchar(64) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'value'=>"varchar(128) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'type'=>"int(11) NOT NULL default '0'", // 0:campo de sistema|1:campo de usuario
		'logic'=>"varchar(10) character set utf8 collate utf8_spanish_ci NOT NULL default '='",
      'PRIMARY KEY  (`subtype_cfg_report`,`cfg_table`,`field`,`value`)'=>'',
      'KEY `id_cfg_report2config` (`id_cfg_report2config`)'=>'',
	),

   'report_store'=>array(
      'id_report'=>"int(11) NOT NULL auto_increment",
      'subtype_cfg_report'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'type'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default 'fromto'",
		'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'date_start'=>"int(11) NOT NULL default '0'",
      'date_end'=>"int(11) NOT NULL default '0'",
      'data'=>"mediumblob",
      'PRIMARY KEY  (`id_report`)'=>'',
      'KEY `subtype_cfg_report` (`subtype_cfg_report`,`date_start`,`date_end`)'=>'',
   ),

   'capacity_store'=>array(
      'date'=>"int(11) NOT NULL default '0'",
		'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'id_dev'=>"int(11) NOT NULL default '0'",
      'sup70'=>"int(11) NOT NULL default '0'",
      'sup75'=>"int(11) NOT NULL default '0'",
      'sup80'=>"int(11) NOT NULL default '0'",
      'sup85'=>"int(11) NOT NULL default '0'",
      'sup90'=>"int(11) NOT NULL default '0'",
      'sup95'=>"int(11) NOT NULL default '0'",
      'sup96'=>"int(11) NOT NULL default '0'",
      'sup97'=>"int(11) NOT NULL default '0'",
      'sup98'=>"int(11) NOT NULL default '0'",
      'sup99'=>"int(11) NOT NULL default '0'",
      'total'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`date`,`subtype`,`id_dev`)'=>'',
   ),


   'cnm_config'=>array(
      'cnm_key'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL",
      'cnm_value'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cnm_descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`cnm_key`)'=>'',
   ),
	
	'search_store'=>array(
		'id_search_store'=>"int(11) NOT NULL auto_increment",
		'scope'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'id_user'=>"int(11) NOT NULL default '0'",	
		'value'=>"text character set utf8 collate utf8_spanish_ci",
      // 'PRIMARY KEY  (`id_search_store`)'=>'',
      // 'UNIQUE KEY `scope` (`scope`,`name`,`id_user`)'=>''
		'PRIMARY KEY  (`scope`,`name`)'=>'',
	   'KEY `id_search_store` (`id_search_store`)'=>''
	),

   'cnm_status'=>array( //Tabla cnm_status
      'hidx' => "int(11) NOT NULL default '0'",
      'cid' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'cid_ip' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'tlast' => "int(11) NOT NULL default '0'",
      'status' => "int(11) NOT NULL default '0'",
      'counter' => "int(11) NOT NULL default '-1'",
      'PRIMARY KEY  (`cid`,`cid_ip`)' =>''
   ),

   'cnm_services'=>array( //Tabla cnm_services
      'type' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'value' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'date_store' => "int(11) NOT NULL default '0'",
      'status' => "int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`type`)' =>''
   ),

   'temp_report_00000001'=>array( 

		'id_alert'=>"int(11) NOT NULL default '0'",
      'severity'=>"int(11) NOT NULL default '0'",
      'ack'=>"int(11) default '0'",
      'event_data'=>"text character set utf8 collate utf8_spanish_ci",
      'date'=>"int(11) default NULL",
      'date_store'=>"int(11) default NULL",
      'duration'=>"int(11) default '0'",
      'dur'=>"int(11) default '0'",
      'dur_extra'=>"int(11) default '0'",
		'in_out'=>"varchar(10) character set utf8 collate utf8_spanish_ci default NULL",
      'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'cause' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'id_ticket'=>"int(11) NOT NULL default '0'",

      'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'domain'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'type'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'mtype'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
		'id_metric'=>"int(11) NOT NULL default '0'",

      'PRIMARY KEY  (`id_alert`)' =>''
   ),



   'plugin_base'=>array( //Tabla plugin_base
      'id_plugin_base'=>"int(11) NOT NULL auto_increment",
      'html_id'=>"varchar(80) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'html_type'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'label'=>"varchar(150) character set utf8 collate utf8_spanish_ci default NULL",
      'icon'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'size'=>"varchar(10) character set utf8 collate utf8_spanish_ci default '10px'",
      'target'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'position'=>"int(11) NOT NULL default '0'",
      'plugin_id'=>"int(11) NOT NULL default '0'",
		'parent'=>"varchar(80) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'item_id'=>"varchar(80) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'item_type'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'extra'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'components'=>"varchar(255) character set utf8 collate utf8_spanish_ci default ''", // Estructura json con los elementos a cargar
      // 'PRIMARY KEY  (`html_id`,`label`,`plugin_id`)'=>'',
      'PRIMARY KEY  (`html_id`,`item_id`,`plugin_id`)'=>'',
      'KEY `id_plugin_base` (`id_plugin_base`)'=>''
   ),

	'plugin_auth'=>array( //Tabla plugin_auth
      'id_plugin_auth'=>"int(11) NOT NULL auto_increment",
		'lib_auth'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''", // Ruta de la libreria
      'enable'=>"int(11) NOT NULL default '0'", // 0: deshabilitado || 1: habilitado
		'type'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''", // Nombre interno (ldap|
		'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''", // Nombre que se muestra
		'descr'=>"text character set utf8 collate utf8_spanish_ci NOT NULL", // Descripción
		'position'=>"int(11) NOT NULL default '0'", // Posición en la que se recorren los plugins de autenticación
      'PRIMARY KEY  (`type`)'=>'',
      'KEY `id_plugin_auth` (`id_plugin_auth`)'=>''
   ),

   'plugin_helpdesk'=>array( //Tabla plugin_helpdesk
      'id_plugin_helpdesk'=>"int(11) NOT NULL auto_increment",
      'lib_helpdesk'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''", // Ruta de la libreria
      'php_ticket'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''", // Ruta del fichero php que va a tener la lógica de la parte de ticket
      'enable'=>"int(11) NOT NULL default '0'", // 0: deshabilitado || 1: habilitado
      'type'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''", // Nombre interno (otrs|
      'name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''", // Nombre que se muestra
      'descr'=>"text character set utf8 collate utf8_spanish_ci NOT NULL", // Descripción
      'position'=>"int(11) NOT NULL default '0'", // Posición en la que se recorren los plugins de helpdesk
      'PRIMARY KEY  (`type`)'=>'',
      'KEY `id_plugin_helpdesk` (`id_plugin_helpdesk`)'=>''
   ),


/*
   'plugin_files'=>array( //Tabla plugin_files
      'plugin_id'=>"int(11) NOT NULL default '0'",
      'plugin_name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'file'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`plugin_id`,`file`)'=>'',
   ),
*/


   //-----------------------------------------------------------
   //-----------------------------------------------------------
	// Datos para los informes de capacidad
   'capacity_data'=>array( //Tabla capacity_data
      'date'=>"date NOT NULL", // Fecha del dato
      'metricname'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''", // Nombre de la metrica 
      'deviceip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''", // IP del dispositivo
      'full_name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''", // Nombre completo del dispositivo
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''", // subtype de la metrica
      'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''", // Label de la metrica
      'v'=>"double(12,2) default NULL", // valor de capacidad
      'idm'=>"int(11) NOT NULL default '0'", // id de la metrica
      'PRIMARY KEY  (`date`,`metricname`,`deviceip`)'=>'',
   ),

   //-----------------------------------------------------------
   //-----------------------------------------------------------
   //support_pack
   //
   'tech_group'=>array( //tec_group
      'id_tech_group'=>"int(11) NOT NULL auto_increment",
      'name'=>"varchar(50) NOT NULL default 'APP'",
      'description'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'custom'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`name`)'=>'',
      'UNIQUE KEY `tech_group_id` (`id_tech_group`)'=>'',
   ),

   'support_pack'=>array( //support_pack
      'id_support_pack'=>"int(11) NOT NULL auto_increment",
      'subtype'=>"varchar(50) NOT NULL default ''",
      'name'=>"varchar(100) NOT NULL default ''",
      'description'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
		'custom'=>"int(11) NOT NULL default '0'",
      'nsnmp'=>"int(11) NOT NULL default '0'",
      'nlatency'=>"int(11) NOT NULL default '0'",
      'nxagent'=>"int(11) NOT NULL default '0'",
      'nremote'=>"int(11) NOT NULL default '0'",
      'napp'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`subtype`)'=>'',
      'UNIQUE KEY `support_pack_id` (`id_support_pack`)'=>'',
   ),

   //support_pack2tech_group
   'support_pack2tech_group'=>array( //Tabla support_pack2tech_group
		'name'=>"varchar(50) NOT NULL default 'APP'",
		'subtype'=>"varchar(50) NOT NULL default ''",
      'PRIMARY KEY  (`name`,`subtype`)'=>''
   ),

	'cfg_networks'=>array( //Tabla cfg_networks
		'id_cfg_networks'=>"int(11) NOT NULL auto_increment",
      'network'=>"varchar(50) NOT NULL default ''",
		'mode'=>"int(11) NOT NULL default '0'",
      'descr'=>"varchar(255) NOT NULL default ''",
      'PRIMARY KEY  (`network`)'=>'',
		'UNIQUE KEY `cfg_networks_id` (`id_cfg_networks`)'=>'',
   ),

   //-----------------------------------------------------------
   //-----------------------------------------------------------
   //ipc
   //
   'ipc'=>array( //ipc
 		'name'=>"varchar(30) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL",
  		'date_store'=>"int(11) NOT NULL DEFAULT '0'",
  		'status'=>"int(11) NOT NULL DEFAULT '0'",
  		'cid'=>"varchar(20) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT ''",
  		'cid_ip'=>"varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT ''",
      'PRIMARY KEY  (`name`,`cid`,`cid_ip`)'=>'',
   ),


   //-----------------------------------------------------------
	'attr2db'=>array( //Tabla attr2db -> Mapea atributos a campos de la BBDD.
      'script'=>"varchar(100) character set utf8 collate utf8_spanish_ci default ''",
      'attr'=>"varchar(50) character set utf8 collate utf8_spanish_ci default ''",
      'tab'=>"varchar(50) character set utf8 collate utf8_spanish_ci default 'devices'",
      'col'=>"varchar(30) character set utf8 collate utf8_spanish_ci default ''",
      'PRIMARY KEY  (`script`,`attr`)'=>'',
   ),


   //-----------------------------------------------------------
	'cfg_inside_correlation_rules'=>array( //Tabla cfg_inside_correlation_rules
		'rule_subtype'=>"varchar(30) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL",
		'rule_expr'=>"varchar(1024) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL default ''",
		'rule_name'=>"varchar(255) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL default ''",
		'rule_descr'=>"varchar(1024) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`rule_subtype`)'=>'',
	),

   'cfg_outside_correlation_rules'=>array( //Tabla cfg_outside_correlation_rules
      'id_dev'=>"int(11) NOT NULL default '0'",
		'mname'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'id_dev_correlated'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`id_dev`,`mname`,`id_dev_correlated`)'=>'',
   ),

	'cfg_device_wsize'=>array( //Tabla cfg_device_wsize
		'wsize'=>"int(11) NOT NULL DEFAULT '0'",
		'label'=>"varchar(255) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL default ''",
		'PRIMARY KEY  (`wsize`)'=>'',
	),

	// cfg_apptype2device, mapea id_dev con apptype
	'cfg_apptype2device'=>array( //Tabla cfg_apptype2device
      'id_dev'=>"int(11) NOT NULL default '0'",
		'apptype'=>"varchar(100) character set utf8 collate utf8_spanish_ci default 'app.generic'",
		'PRIMARY KEY  (`id_dev`,`apptype`)'=>'',
	),
	// ASSETS
	'assets'=>array( // Tabla assets
		'id_asset'=>"int(11) NOT NULL auto_increment",
		'hash_asset'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'id_dev'=>"int(11) NOT NULL default '0'",
		'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'hash_asset_type'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'hash_asset_subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'status'=>"varchar(255) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL default ''",
		'critic'=>"int(11) default '50'",
		'owner'=>"varchar(255) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL default ''",
      'background'=>"varchar(255) character set utf8 collate utf8_spanish_ci default ''",
		'PRIMARY KEY  (`name`,`hash_asset_type`)'=>'',
		'UNIQUE KEY `id_asset` (`id_asset`)'=>'',
		'UNIQUE KEY `hash_asset` (`hash_asset`)'=>''
   ),
   'assets_types'=>array( // Tabla assets_types: Define los difentes tipos de recursos IT
      'id_asset_type'=>"int(11) NOT NULL auto_increment",
      'hash_asset_type'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'available_status'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
		'available_owner'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
      'icon'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'mod_devices24x24.png'",
		'manage'=>"int(11) NOT NULL default '0'", // Campo que indica si el tipo va a tener métricas o no (0 no == activos | 1 si == elementos ti)
		'id_host_type'=>"int(11) NOT NULL default '0'", // Campo que indica si el tipo esta asociado con un tipo de dispositivos (tabla cfg_host_types)
      'PRIMARY KEY  (`descr`)'=>'',
      'UNIQUE KEY `id_asset_type` (`id_asset_type`)'=>'',
      'UNIQUE KEY `hash_asset_type` (`hash_asset_type`)'=>''
   ),
   'assets_subtypes'=>array( // Tabla assets_subtypes: Define los difentes subtipos de recursos IT
      'id_asset_subtype'=>"int(11) NOT NULL auto_increment",
		'hash_asset_subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'hash_asset_type'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`hash_asset_type`,`hash_asset_subtype`)'=>'',
      'UNIQUE KEY `id_asset_subtype` (`id_asset_subtype`)'=>'',
   ),
	'assets_custom_field'=>array( // Tabla assets_custom_field
		'id_asset_custom_field'=>"int(11) NOT NULL auto_increment",
      'hash_asset_custom_field'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'descr'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'tipo'=>"int(11) default NULL",
      'hash_asset_type'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'available_values'=>"text character set utf8 collate utf8_spanish_ci NOT NULL",
		'PRIMARY KEY  (`descr`,`hash_asset_type`)'=>'',
		'UNIQUE KEY `id` (`id_asset_custom_field`)'=>'',
		'UNIQUE KEY `hash_asset_custom_field` (`hash_asset_custom_field`)'=>''
   ),
	'assets_custom_data'=>array( // Tabla assets_custom_data
		'id_asset_custom_data'=>"int(11) NOT NULL auto_increment",
		'hash_asset_custom_data'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'hash_asset'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'hash_asset_custom_field'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'data'=>"text CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL",
		'PRIMARY KEY  (`hash_asset`,`hash_asset_custom_field`)'=>'',
		'UNIQUE KEY `id` (`id_asset_custom_data`)'=>'',
		'UNIQUE KEY `hash_asset_custom_data` (`hash_asset_custom_data`)'=>''
   ),
   'assets_types2app'=>array( // Tabla assets_types2app: Permite asociar tipos de assets a aplicaciones para importar datos automaticamente
      'hash_asset_type'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'aname'=>"varchar(60) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'type'=>"int(11) NOT NULL default '0'", // 0: Sirve para descubrir || 1: Sirve para mantenimiento
      'PRIMARY KEY  (`hash_asset_type`,`aname`,`type`)'=>'',
   ),
   'asset2credential'=>array( //Tabla asset2credential
      'hash_asset'=>"varchar(50) character set utf8 collate utf8_spanish_ci default ''",
      'id_credential'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`hash_asset`,`id_credential`)'=>''
   ),
	'asset2proxy'=>array( //Tabla asset2proxy: Relaciona assets con dispositivos
      'hash_asset'=>"varchar(50) character set utf8 collate utf8_spanish_ci default ''",
      'id_dev'=>"int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`hash_asset`,`id_dev`)'=>''
   ),
   'asset2metric'=>array( //Tabla asset2metric: Relaciona assets con métricas
      'hash_asset'=>"varchar(50) character set utf8 collate utf8_spanish_ci default ''",
      'id_metric'=>"int(11) NOT NULL default '0'",
      'graph'=>"bigint(20) default NULL",
      'size'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default '350x100'",
      'PRIMARY KEY  (`hash_asset`,`id_metric`)'=>''
   ),


   'alerts2app'=>array( // Tabla alerts2app: Permite asociar aplicaciones a alertas para provisionar o realizar mantenimiento
      'aname'=>"varchar(60) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'type'=>"int(11) NOT NULL default '0'", // 0: Sirve para descubrir || 1: Sirve para mantenimiento
      'PRIMARY KEY  (`aname`,`type`)'=>'',
   ),

   'cnm_global_params'=>array( // Tabla cnm_global_params: Permite definir variables globales con el formato $global.algo1.algo2
      'param_name'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL",
      'param_value'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`param_name`)'=>'',
   ),

)
?>
