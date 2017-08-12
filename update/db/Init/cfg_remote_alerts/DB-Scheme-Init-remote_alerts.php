<?php
	$CFG_REMOTE_ALERTS = array();
	// CASOS ESPECIALES ---------------------------------------------------------------------

/*
   'cfg_remote_alerts'=>array( //Tabla cfg_remote_alerts
      'mode'=>"varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default 'INC'",
      'expr' => "varchar(200) character set utf8 collate utf8_spanish_ci NOT NULL default 'AND'",
      'PRIMARY KEY  (`id_remote_alert`)'=>''
   ),
*/

/*

	La clave principal esta formada por  type-subtype-hiid
	hiid es el md5 de la concatenacion de los valors v+expr en el caso de las alertas que contengan expresiones
	Si la alerta no tiene expresiones es el md5(v1+"")	

*/
	$CFG_REMOTE_ALERTS[]=array(
		'type' => 'cnm',		'subtype' => 'mon_snmp',		'hiid' => 'ea1c3c284d',
      'descr' => 'SIN RESPUESTA SNMP',		'mode'=>'INC', 	'expr'=>'AND',
		'vardata' => '',
      'monitor' => '',		'vdata' => '',	'severity' => '1',	'action' => 'SET',	'script' => '',
		'apptype' => 'RED', 'itil_type' => '1', 'class'=>'CNM',
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
            array ( 'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>'')
      )
	);

	$CFG_REMOTE_ALERTS[]=array(
      'type' => 'cnm',		'subtype' => 'mon_xagent',		'hiid' => 'ea1c3c284d',
      'descr' => 'SIN RESPUESTA DEL AGENTE REMOTO',		'mode'=>'INC',    'expr'=>'AND',
		'vardata' => '',
      'monitor' => '',		'vdata' => '',	'severity' => '1',	'action' => 'SET',	'script' => '',
		'apptype' => 'RED', 'itil_type' => '1', 'class'=>'CNM',
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
            array ( 'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>'')
      )
   );
	
	$CFG_REMOTE_ALERTS[]=array(
      'type' => 'cnm',		'subtype' => 'mon_wbem',		'hiid' => 'ea1c3c284d',
      'descr' => 'SIN RESPUESTA WMI (WBEM)',					'mode'=>'INC',    'expr'=>'AND',
		'vardata' => '',
      'monitor' => '',		'vdata' => '',	'severity' => '1',	'action' => 'SET',	'script' => '',
		'apptype' => 'RED', 'itil_type' => '1', 'class'=>'CNM',
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
            array ( 'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>'')
      )
   );


	// TRAPS STANDARD -----------------------------------------------------------------------
	$CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',		'subtype' => 'SNMPv2-MIB::coldStart',		'hiid' => 'ea1c3c284d',
      'descr' => 'INICIO DE EQUIPO (Cold Start)',			'mode'=>'INC',    'expr'=>'AND',
		'vardata' => '',
      'monitor' => '',		'vdata' => '',	'severity' => '1',	'action' => 'SET',	'script' => '',
		'apptype' => 'NET.BASE', 'itil_type' => '1', 'class'=>'MIB-2',
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
            array ( 'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>'')
      )

   );

	$CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',		'subtype' => 'SNMPv2-MIB::warmStart',		'hiid' => 'ea1c3c284d',
      'descr' => 'INICIO DE EQUIPO (Warm Start)',			'mode'=>'INC',    'expr'=>'AND',
		'vardata' => '',
      'monitor' => '',		'vdata' => '',	'severity' => '1',	'action' => 'SET',	'script' => '',
		'apptype' => 'NET.BASE', 'itil_type' => '1', 'class'=>'MIB-2',
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
            array ( 'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>'')
      )
   );

	$CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',		'subtype' => 'IF-MIB::linkDown',		'hiid' => 'ea1c3c284d',
      'descr' => 'INTERFAZ CAIDO (Link Down)',				'mode'=>'INC',    'expr'=>'AND',
		'vardata' => '',
      'monitor' => '',		'vdata' => '',	'severity' => '1',	'action' => 'SET',	'script' => '',
		'apptype' => 'NET.BASE', 'itil_type' => '1', 'class'=>'MIB-2',
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
            array ( 'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>'')
      )
   );

//vdata en el caso de alertas tipo CLR se utiliza en el caso de que haya que matchear algun campo del 
//varbind data para asociar la alerta SET y CLR. P. ej linkup/linkdown que deben de referirse el mismo
//interfaz para que una borre a la otra.
	$CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',		'subtype' => 'IF-MIB::linkUp',		'hiid' => 'ea1c3c284d',
      'descr' => 'INTERFAZ ACTIVO (Link Up)',				'mode'=>'INC',    'expr'=>'AND',
		'vardata' => '',
      'monitor' => '',		'vdata' => 'v1',	'severity' => '1',	'action' => 'CLR',	'script' => '',
		'apptype' => 'NET.BASE', 'itil_type' => '1', 'class'=>'MIB-2',
		'set_type'=>'snmp', 'set_subtype'=>'IF-MIB::linkDown', 'set_hiid'=>'ea1c3c284d' ,  //El set_id se podria rellenar en base a estos datos
	
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
            array ( 'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>'')
      )
   );


	$CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',		'subtype' => 'SNMPv2-MIB::authenticationFailure',		'hiid' => 'ea1c3c284d',
      'descr' => 'ERROR EN AUTENTICACION (Authentication Failure)',		'mode'=>'INC',    'expr'=>'AND',
		'vardata' => '',
      'monitor' => '',		'vdata' => '',	'severity' => '1',	'action' => 'SET',	'script' => '',
		'apptype' => 'NET.BASE', 'itil_type' => '1', 'class'=>'MIB-2',
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
            array ( 'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''),
      )
   );

	// TRAPS DE TEST  -----------------------------------------------------------------------

   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',    'subtype' => 'NOTIFICATION-TEST-MIB::demo-notif',     'hiid' => 'ea1c3c284d',
      'descr' => 'TRAP DE TEST V2',     'mode'=>'INC',    'expr'=>'AND',
		'vardata' => 'sysLocation',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '',
      'apptype' => 'RED', 'itil_type' => '1', 'class'=>'MIB-2',
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
            array ( 'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''),
      )
   );

   $CFG_REMOTE_ALERTS[]=array(
      'type' => 'snmp',    'subtype' => 'TRAP-TEST-MIB::demo-trap',     'hiid' => 'ea1c3c284d',
      'descr' => 'TRAP DE TEST V1',     'mode'=>'INC',    'expr'=>'AND',
		'vardata' => 'sysLocation',
      'monitor' => '',     'vdata' => '', 'severity' => '3',   'action' => 'SET',   'script' => '',
      'apptype' => 'RED', 'itil_type' => '1', 'class'=>'MIB-2',
      'cfg_remote_alerts2expr' => array ( 'id'=>'id_remote_alert',
            array ( 'v'=>'v1', 'descr'=>'Cualquier valor', 'fx'=>'MATCH', 'expr'=>''),
      )
   );


# ----------------------------------------------------------------
# snmptrap  -c public  -v 1 localhost  TRAP-TEST-MIB::demotraps localhost 6 17 '' SNMPv2-MIB::sysLocation.0 s "TRAP V1"
# ----------------------------------------------------------------
# Sep 18 19:54:48 cnm-devel2 snmptrapd[21752]: DATE>>2009918 19:54:48; HOST>>cnm-devel2; IPv1>>127.0.0.1; NAMEv1>>cnm-devel2; IPv2>>UDP: [127.0.0.1]:43442; NAMEv2>>cnm-devel2; OID>>UCD-SNMP-MIB::ucdExperimental.990; TRAP>>6..17; DESC>>Enterprise Specific; VDATA>>SNMPv2-MIB::sysLocation.0 = STRING: TRAP V1
# ----------------------------------------------------------------
# ----------------------------------------------------------------
# snmptrap -v 2c -c public localhost '' NOTIFICATION-TEST-MIB::demo-notif SNMPv2-MIB::sysLocation.0 s "TRAP V2"


?>
