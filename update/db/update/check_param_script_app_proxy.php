#!/usr/bin/php
<?php
	/*
	* Programa que mira en los ficheros de BBDD de CNM los parámetros de los scripts, aplicaciones y métricas de tipo proxy
	* y muestra aquellos que son de tipo usuario o clave de forma que nos ayude a depurar si hay algún parámetro que deba
	* ser configurado utilizando variables de credenciales ($sec.telnet.user o $sec.telnet.pwd) en vez de estar vacios o
	* con un valor predefinido
	*/
	// $CFG_SCRIPT_PARAM[]
	require_once_dir('/update/db/Init/cfg_script_param');
	
	$a_ordered_script_param = array();

	print "--------------\$CFG_SCRIPT_PARAM (DIR == /update/db/Init/cfg_script_param) --------------\n";
	foreach($CFG_SCRIPT_PARAM as $script_param){
		$a_ordered_script_param[$script_param['hparam']] = $script_param;
		if($script_param['param_type']==2) continue;
		if(!preg_match("/(User|user|Usuario|usuario|Clave|clave|Pass|pass)/",$script_param['descr'])) continue;
		print "TYPE == {$script_param['param_type']} || ID == {$script_param['hparam']} || SCRIPT == {$script_param['script']} || PREFIX == {$script_param['prefix']} || DESCR == {$script_param['descr']} || VALUE == {$script_param['value']}\n";
	
	}

	// $CFG_APP_PARAM[]
	require_once_dir('/update/db/Init/cfg_app_param');

   print "--------------\$CFG_APP_PARAM (DIR == /update/db/Init/cfg_app_param) --------------\n";
	foreach($CFG_APP_PARAM as $app_param){
		if($a_ordered_script_param[$app_param['hparam']]['param_type']==2) continue;
		if(!preg_match("/(User|user|Usuario|usuario|Clave|clave|Pass|pass)/",$a_ordered_script_param[$app_param['hparam']]['descr'])) continue;
		print "TYPE == {$a_ordered_script_param[$app_param['hparam']]['param_type']} || ID == {$app_param['hparam']} || SCRIPT == {$app_param['script']} || PREFIX == {$a_ordered_script_param[$app_param['hparam']]['prefix']} || DESCR == {$a_ordered_script_param[$app_param['hparam']]['descr']} || VALUE == {$app_param['value']}\n";
	}

	// $CFG_MONITOR_PARAM[]
	require_once_dir('/update/db/Init/cfg_monitor_param');

   print "--------------\$CFG_MONITOR_PARAM (DIR == /update/db/Init/cfg_monitor_param) --------------\n";
	foreach($CFG_MONITOR_PARAM as $cfg_monitor_param){
		if($a_ordered_script_param[$cfg_monitor_param['hparam']]['param_type']==2) continue;
		if(!preg_match("/(User|user|Usuario|usuario|Clave|clave|Pass|pass)/",$a_ordered_script_param[$cfg_monitor_param['hparam']]['descr'])) continue;
		print "TYPE == {$a_ordered_script_param[$cfg_monitor_param['hparam']]['param_type']} || ID == {$cfg_monitor_param['hparam']} || SCRIPT == {$cfg_monitor_param['script']} || PREFIX == {$a_ordered_script_param[$cfg_monitor_param['hparam']]['prefix']} || DESCR == {$a_ordered_script_param[$cfg_monitor_param['hparam']]['descr']} || VALUE == {$cfg_monitor_param['value']}\n";
	}


	/////////////////////////////////////////////////////////
	function require_once_dir($path){
		global $CFG_SCRIPT_PARAM,$CFG_MONITOR_PARAM,$CFG_APP_PARAM;

	   $a_files = glob("$path/*.php");
   	foreach ($a_files as $file) require_once($file);
	}
?>
