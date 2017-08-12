<?php
// CAMPOS IMPORTANTES

// name
// script
// type
// subtype
// aname
// itil_type: operacion 1, configuracion 2, capacidad 3, disponibilidad 4, seguridad 5
// cfg: 0-> No instanciada, 1-> Instanciada

// format hace referencia al formato de salida generado por la aplicacion
// 0=> La aplicacion no genera formato
// 1=> La aplicacion compone el xml

// enterprise es necesario para optimizar el chequeo de las snmp. En el resto de casos por
// ahora no tiene uso

// res=1 => Tiene resultados (hay solapa)
// res=0 => No tiene resultados (no hay solapa)


/*
LIMPIEZA:
Sobran los siguientes campos:

ipparam

*/


      $CFG_MONITOR_APPS[]=array(
         'type' => 'xagent', 'subtype'=>'GConf', 'itil_type'=>'2',  'name'=>'OBTENER CONFIGURACION DE ROUTER COMTREND POR TELNET',
         'descr' => 'Obtiene la configuracion de un router comtrend por telnet',
         'cmd' => '',
         'params' => '',      'iptab'=>'1', 'ready'=>'0',
         'myrange' => 'cnm',   'enterprise'=>'0',
         'cfg' => '0',  'platform' => '*',   'script' => 'linux_app_get_conf_telnet_comtrend_router.pl',   'format'=>1,
         'custom' => '0', 'aname'=> 'app_gconf_telnet_comtrend', 'res'=>1, 'ipparam'=>'',
         'apptype' => 'CNM',  'itil_type' => '2',
      );

      $CFG_MONITOR_APPS[]=array(
         'type' => 'xagent', 'subtype'=>'GConf', 'itil_type'=>'2',  'name'=>'OBTENER CONFIGURACION DE UN EQUIPO CISCO CON IOS POR TELNET',
         'descr' => 'Obtiene la configuracion de un router cisco por telnet',
         'cmd' => '',
         'params' => '',      'iptab'=>'1', 'ready'=>'0',
         'myrange' => 'cnm',   'enterprise'=>'0',
         'cfg' => '0',  'platform' => '*',   'script' => 'linux_app_get_conf_telnet_cisco_router.pl',   'format'=>1,
         'custom' => '0', 'aname'=> 'app_gconf_telnet_cisco', 'res'=>1, 'ipparam'=>'',
         'apptype' => 'CNM',  'itil_type' => '2',
      );

      $CFG_MONITOR_APPS[]=array(
         'type' => 'xagent', 'subtype'=>'GConf', 'itil_type'=>'2',  'name'=>'OBTENER LOS CAMBIOS DE CONFIGURACION ALMACENADOS',
         'descr' => '',
         'cmd' => '',
         'params' => '',      'iptab'=>'1', 'ready'=>'0',
         'myrange' => 'cnm',   'enterprise'=>'0',
         'cfg' => '0',  'platform' => '*',   'script' => 'linux_app_check_remote_cfgs.pl',   'format'=>2,
         'custom' => '0', 'aname'=> 'app_gconf_check', 'res'=>1, 'ipparam'=>'',
         'apptype' => 'CNM',  'itil_type' => '2',
      );

?>
