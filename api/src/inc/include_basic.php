<?php
                               // VAL     DIR       WHO
define('APP_IP_ONLINE',0);     //   0     APP-IP    ACTIONS             
define('APP_IP_DEFERRED',10);  //  10     APP_IP    ACTIONSD             
define('APP_DEFERRED',11);     //  11     APP       ACTIONSD
define('TASK_SCHEDULED',12);   //  12     TASK      ACTIONSD
define('TASK_EVENT',13);       //  13     TASK      ACTIONSD

include_once('inc/MC.php');
include_once('inc/session.php');
session_set_save_handler('mysql_session_open','mysql_session_close','mysql_session_select','mysql_session_write','mysql_session_destroy','mysql_session_garbage_collect');
session_start();
include_once('/var/www/html/tphp/class.TemplatePower.inc.php');
// include_once('../tphp/class.TemplatePower.inc.php');
include_once('inc/Metrics.php');
include_once('inc/Store.php');
include_once('inc/format.php');
include_once('inc/Permissions.php');
include_once('inc/CNMUtils.php');
include_once('inc/SNMPUtils.php');
include_once('sql/mod_Configure.sql');
include_once('inc/class_tabbar.php');
include_once('inc/class_table.php');
include_once('inc/class_toolbar.php');
include_once('inc/class_menu.php');
include_once('inc/class_option.php');
include_once('inc/class_tree.php');
include_once('inc/class_background.php');
include_once('inc/class_link.php');
include_once('inc/class_remote_alert.php');


define('REGISTER','REGISTER');
define('NOREGISTER','NOREGISTER');
define('TIMEOUT','TIMEOUT');


// ----------------------------------------------------------
// TIPOS DE ACCIONES PARA qactions (log_qactions)
// ----------------------------------------------------------

define('ATYPE_USER_LOGIN',											'1');
define('ATYPE_DB_MANT_TABLE_LIMIT',                   	'2');
																				
define('ATYPE_SET_METRICS_FROM_ASISTANT',                '10');
define('ATYPE_SET_METRICS_FROM_TEMPLATE',                '11');
define('ATYPE_SET_TEMPLATE_FROM_ASISTANT',               '12');
define('ATYPE_RESET_METRICS',                            '13');
define('ATYPE_SET_METRICS_FROM_TEMPLATE_CHANGE_DEVICE',  '14');
define('ATYPE_SET_METRICS_FROM_TEMPLATE_CHANGE_METRIC',  '15');

define('ATYPE_SET_METRICS_FROM_ASISTANT_BLOCK',          '16');
define('ATYPE_SET_METRICS_FROM_TEMPLATE_BLOCK',          '17');
define('ATYPE_SET_TEMPLATE_FROM_ASISTANT_BLOCK',         '18');

define('ATYPE_CLONE_METRICS',                            '19');

define('ATYPE_IIDS_MODIFIED',                            '20');
define('ATYPE_IIDS_ERASED',                              '21');

define('ATYPE_PROVISION_DEVICES',         					'22');
define('ATYPE_MODIFY_DEVICE',		         					'23');

define('ATYPE_DEVICE2INACTIVE',           '30');
define('ATYPE_DEVICE2ACTIVE',             '31');
define('ATYPE_DEVICE2MAINTENANCE',        '32');

define('ATYPE_GET_CSV_DEVICES',           '40');
define('ATYPE_GET_CSV_METRICS',           '41');
define('ATYPE_GET_CSV_VIEWS',             '42');

define('ATYPE_NETWORK_AUDIT',             '50');
define('ATYPE_APP_EXECUTED',              '51');


define('ATYPE_MCNM_DOMAIN_SYNC',          '200');

define('ATYPE_NOTIF_BY_EMAIL',            '1001');
define('ATYPE_NOTIF_BY_SMS',              '1002');
define('ATYPE_NOTIF_BY_TRAP',             '1003');


/////////////////////////
// Parte de components //
/////////////////////////
if(defined('_do')){
	showTime(session_id());
	if(isset($_SESSION['COMPONENTS'][_do])){
		$cnm_components = array();
		$base_path = '/var/www/html/onm/';

		// inc
		foreach($_SESSION['COMPONENTS'][_do]['inc'] as $i){
			if(file_exists($base_path.$i)){
				include_once($i);
				$cnm_components['inc'][]=$i;
			}
		}
		// lib
		foreach($_SESSION['COMPONENTS'][_do]['lib'] as $i){
         if(file_exists($base_path.$i)){
				$cnm_components['lib'][]=$i;
         }
      }
	}
}
?>
