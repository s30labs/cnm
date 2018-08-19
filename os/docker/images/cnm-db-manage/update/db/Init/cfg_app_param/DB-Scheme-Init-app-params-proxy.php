<?php

// VALORES IMPORTANTES
// aname
// hparam
// script
// enable
// value
// type ¿?

//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
//linux_app_get_conf_telnet_comtrend_router.pl
//OBTIENE CONFIGURACION ROUTER COMTREND POR TELNET
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_gconf_telnet_comtrend', 'hparam' => '40000000', 'type' => 'cnm', 'enable' => '1', 'value' => '',
      'script' => 'linux_app_get_conf_telnet_comtrend_router.pl',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_gconf_telnet_comtrend', 'hparam' => '40000001', 'type' => 'cnm', 'enable' => '1', 'value' => '$sec.telnet.user',
      'script' => 'linux_app_get_conf_telnet_comtrend_router.pl',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_gconf_telnet_comtrend', 'hparam' => '40000002', 'type' => 'cnm', 'enable' => '1', 'value' => '$sec.telnet.pwd',
      'script' => 'linux_app_get_conf_telnet_comtrend_router.pl',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_gconf_telnet_comtrend', 'hparam' => '40000003', 'type' => 'cnm', 'enable' => '1', 'value' => '10',
      'script' => 'linux_app_get_conf_telnet_comtrend_router.pl',
   );

//linux_app_get_conf_telnet_cisco_router.pl
//OBTIENE CONFIGURACION CISCO IOS POR TELNET
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_gconf_telnet_cisco', 'hparam' => '40000010', 'type' => 'cnm', 'enable' => '1', 'value' => '',
      'script' => 'linux_app_get_conf_telnet_cisco_router.pl',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_gconf_telnet_cisco', 'hparam' => '40000011', 'type' => 'cnm', 'enable' => '1', 'value' => '$sec.telnet.user',
      'script' => 'linux_app_get_conf_telnet_cisco_router.pl',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_gconf_telnet_cisco', 'hparam' => '40000012', 'type' => 'cnm', 'enable' => '1', 'value' => '$sec.telnet.pwd',
      'script' => 'linux_app_get_conf_telnet_cisco_router.pl',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_gconf_telnet_cisco', 'hparam' => '40000013', 'type' => 'cnm', 'enable' => '1', 'value' => '',
      'script' => 'linux_app_get_conf_telnet_cisco_router.pl',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_gconf_telnet_cisco', 'hparam' => '40000014', 'type' => 'cnm', 'enable' => '1', 'value' => '10',
      'script' => 'linux_app_get_conf_telnet_cisco_router.pl',
   );

//linux_app_check_remote_cfgs.pl
//OBTIENE LOS CAMBIOS DE CONFIGURACION ALMACENADOS
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_gconf_check', 'hparam' => '40000020', 'type' => 'cnm', 'enable' => '1', 'value' => '',
      'script' => 'linux_app_check_remote_cfgs.pl',
   );

?>
