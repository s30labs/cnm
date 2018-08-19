<?php

//---------------------------------------------------------------------------------------------------------
// itil_type: operacion 1, configuracion 2, capacidad 3, disponibilidad 4, seguridad 5
// cfg: 		1 -> Sin instancias, 2 -> Con Instancias
// custom:	0 -> De base (sin cofigurar), 1 -> Configurada por el usuario (Ya se puede asociar a dispositivos)
/*
Falta params,  params_descr, script, info
Quizas sea necesario platfform

Al incluir nuevas metricas hay que rellenar 3 tablas:
cfg_monitor_agent
tips
cfg_script_params

RANGO: xagt_004000-xagt_004999
*/
//---------------------------------------------------------------------------------------------------------
// app: proxy-linux (Sondas linux)
// xagt_004000-xagt_004999
//---------------------------------------------------------------------------------------------------------
//linux_metric_certificate_expiration_time.pl
//<001> Seconds for expiration = 23625802
//<002> Days for expiration = 273
/* PASADO /opt/
      $CFG_MONITOR_AGENT[]=array(
            'subtype' => 'xagt_004000',   'class' => 'proxy-linux',  'description' => 'CADUCIDAD DE CERTIFICADO SSL (sgs)',
            'apptype' => 'IPSERV.WWW',  'itil_type' => '1',		'tag' => '001',	'esp'=>'o1',  'iptab' => '1', 
            'items' => 'Time',        'vlabel' => 'T(segs)',      'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',        'top_value' => '1',     'module' => 'mod_xagent_get',    'nparams' => '2',
            'params' => '[;IP;;2]:[;Puerto;443;0]',               'params_descr' => '',
            'script' => 'linux_metric_certificate_expiration_time.pl',         'severity' => '1',
            'cfg' => '1',  'custom' => '0',  'get_iid' => '0',  'proxy'=>1, 'proxy_type'=>'linux',
            'info' => '',  'lapse' => 300,   'include'=>1,
      );

      $CFG_MONITOR_AGENT[]=array(
            'subtype' => 'xagt_004001',   'class' => 'proxy-linux',  'description' => 'CADUCIDAD DE CERTIFICADO SSL (h)',
            'apptype' => 'IPSERV.WWW',  'itil_type' => '1',    'tag' => '002',   'esp'=>'o1',	'iptab' => '1',
            'items' => 'Time',        'vlabel' => 'T(hours)',      'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',        'top_value' => '1',     'module' => 'mod_xagent_get',    'nparams' => '2',
            'params' => '[;IP;;2]:[;Puerto;443;0]',               'params_descr' => '',
            'script' => 'linux_metric_certificate_expiration_time.pl',         'severity' => '1',
            'cfg' => '1',  'custom' => '0',  'get_iid' => '0',  'proxy'=>1, 'proxy_type'=>'linux',
            'info' => '',  'lapse' => 300,   'include'=>1,
      );
*/
//linux_metric_mail_loop.pl
      $CFG_MONITOR_AGENT[]=array(
            'subtype' => 'xagt_004009',   'class' => 'proxy-linux',  'description' => 'BUCLE DE CORREO EXTERNO POP3',
            'apptype' => 'IPSERV.POP3',  'itil_type' => '1',		'tag' => '001|002|003|004',   'esp'=>'o1|o2|o3|o4',	'iptab' => '0',
            'items' => 'Enviados|Recibidos|Ttx|Trx',        'vlabel' => 'num/segs',      'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',        'top_value' => '1',     'module' => 'mod_xagent_get',    'nparams' => '7',
            'params' => '[-mxhost;Host SMTP;;2]:[-to;Destinatario del correo;;0]:[-from;Origen del correo;;0]:[-pop3host;Host POP3;;0]:[-user;Usuario POP3;;1]:[-pwd;Clave POP3;;1]:[-n;Numero de correos a enviar;3;0]',               'params_descr' => '',
            'script' => 'linux_metric_mail_loop.pl',         'severity' => '1',
            'cfg' => '1', 'custom' => '0',   'get_iid' => '0',  'proxy'=>1, 'proxy_type'=>'linux',
            'info' => '', 'lapse' => 300,   'include'=>1,
      );

//linux_metric_mysql_var.pl
//<001> buffer_used = 0.13
//<002> read_hits = 99.96
//<003> write_hits = 46.27
//<004> connections = 13.33

      $CFG_MONITOR_AGENT[]=array(
            'subtype' => 'xagt_004100',   'class' => 'proxy-linux',  'description' => 'MYSQL - USO DEL BUFFER',
            'apptype' => 'BBDD.MYSQL',  'itil_type' => '1',		'tag' => '001',   'esp'=>'o1',	'iptab' => '0',
            'items' => '%Uso',        'vlabel' => '%uso',      'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',        'top_value' => '1',     'module' => 'mod_xagent_get',    'nparams' => '4',
            'params' => '[-host;Host con MySQL;;2]:[-user;Usuario de acceso;;1]:[-pwd;Clave del usuario;;1]',      'params_descr' => '',
            'script' => 'linux_metric_mysql_var.pl',         'severity' => '1',
            'cfg' => '1', 'custom' => '0',  'get_iid' => '0',  'proxy'=>1, 'proxy_type'=>'linux',
            'info' => '', 'lapse' => 300,   'include'=>1,
      );
      $CFG_MONITOR_AGENT[]=array(
            'subtype' => 'xagt_004101',   'class' => 'proxy-linux',  'description' => 'MYSQL - USO DE LA CACHE',
            'apptype' => 'BBDD.MYSQL',  'itil_type' => '1',     'tag' => '002|003',	   'esp'=>'o1|o2', 'iptab' => '0',
            'items' => '%ReadHits|%WriteHits',        'vlabel' => '%hits',      'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',        'top_value' => '1',     'module' => 'mod_xagent_get',    'nparams' => '4',
            'params' => '[-host;Host con MySQL;;2]:[-user;Usuario de acceso;;1]:[-pwd;Clave del usuario;;1]',        'params_descr' => '',
            'script' => 'linux_metric_mysql_var.pl',         'severity' => '1',
            'cfg' => '1', 'custom' => '0',  'get_iid' => '0',  'proxy'=>1, 'proxy_type'=>'linux',
            'info' => '', 'lapse' => 300,   'include'=>1,
      );
      $CFG_MONITOR_AGENT[]=array(
            'subtype' => 'xagt_004102',   'class' => 'proxy-linux',  'description' => 'MYSQL - CONEXIONES',
            'apptype' => 'BBDD.MYSQL',  'itil_type' => '1',     'tag' => '004',	   'esp'=>'o1', 'iptab' => '0',
            'items' => '%Conexiones',        'vlabel' => '%conex',      'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',        'top_value' => '1',     'module' => 'mod_xagent_get',    'nparams' => '4',
            'params' => '[-host;Host con MySQL;;2]:[-user;Usuario de acceso;;1]:[-pwd;Clave del usuario;;1]',          'params_descr' => '',
            'script' => 'linux_metric_mysql_var.pl',         'severity' => '1',
            'cfg' => '1', 'custom' => '0',  'get_iid' => '0',  'proxy'=>1, 'proxy_type'=>'linux',
            'info' => '', 'lapse' => 300,   'include'=>1,
      );



//linux_metric_ssh_files_in_dir.pl
      $CFG_MONITOR_AGENT[]=array(
            'subtype' => 'xagt_004200',   'class' => 'proxy-linux',  'description' => 'NUMERO DE FICHEROS EN DIRECTORIO',
            'apptype' => 'SO.LINUX',  'itil_type' => '1',		'tag' => '001',   'esp'=>'o1',	'iptab' => '0',
            'items' => 'Num Ficheros',        'vlabel' => 'Num',      'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',        'top_value' => '1',     'module' => 'mod_xagent_get',    'nparams' => '5',
            'params' => '[-n;Host;;2]:[-u;User;;1]:[-p;Password;;1]:[-d;Directorio;;0]:[-a;Patron;;0]',               'params_descr' => '',
            'script' => 'linux_metric_ssh_files_in_dir.pl',         'severity' => '1',
            'cfg' => '1', 'custom' => '0',  'get_iid' => '0',  'proxy'=>1, 'proxy_type'=>'linux',
            'info' => '', 'lapse' => 300,   'include'=>1,
      );

//linux_metric_ssh_files_per_proccess.pl
      $CFG_MONITOR_AGENT[]=array(
            'subtype' => 'xagt_004201',   'class' => 'proxy-linux',  'description' => 'NUMERO DE FICHEROS ABIERTOS POR PROCESO',
            'apptype' => 'SO.LINUX',  'itil_type' => '1',		'tag' => '001',   'esp'=>'o1',	'iptab' => '0',
            'items' => 'Num Ficheros',        'vlabel' => 'Num',      'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',        'top_value' => '1',     'module' => 'mod_xagent_get',    'nparams' => '4',
            'params' => '[-n;Host;;2]:[-u;User;;1]:[-p;Password;;1]:[-a;Proceso;;0]',               'params_descr' => '',
            'script' => 'linux_metric_ssh_files_per_proccess.pl',         'severity' => '1',
            'cfg' => '2', 'custom' => '0',  'get_iid' => '0',  'proxy'=>1, 'proxy_type'=>'linux',
            'info' => '', 'lapse' => 300,   'include'=>1,
      );

//linux_metric_route_tag.pl (MULTIMETRICA)
//<001> Route Tag = 317488
//<002> Number of Hops = 1
      $CFG_MONITOR_AGENT[]=array(
            'subtype' => 'xagt_004202',   'class' => 'proxy-linux',  'description' => 'CAMBIO DE RUTA AL DESTINO',
            'apptype' => 'NET.BASE',  'itil_type' => '1',		'tag' => '001',   'esp'=>'o1',	'iptab' => '1',
            'items' => 'Route Tag',        'vlabel' => 'Num',      'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',        'top_value' => '1',     'module' => 'mod_xagent_get',    'nparams' => '1',
            'params' => '[-host;Host;;2]',               'params_descr' => '',
            'script' => 'linux_metric_route_tag.pl',         'severity' => '1',
            'cfg' => '1', 'custom' => '0',  'get_iid' => '0',  'proxy'=>1, 'proxy_type'=>'linux',
            'info' => '', 'lapse' => 300,   'include'=>1,
      );
      $CFG_MONITOR_AGENT[]=array(
            'subtype' => 'xagt_004203',   'class' => 'proxy-linux',  'description' => 'NUMERO DE SALTOS AL DESTINO',
            'apptype' => 'NET.BASE',  'itil_type' => '1',     'tag' => '002',   'esp'=>'o1',	'iptab' => '1',
            'items' => 'Number of Hops',        'vlabel' => 'Num',      'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',        'top_value' => '1',     'module' => 'mod_xagent_get',    'nparams' => '1',
            'params' => '[-host;Host;;2]',               'params_descr' => '',
            'script' => 'linux_metric_route_tag.pl',         'severity' => '1',
            'cfg' => '1', 'custom' => '0',  'get_iid' => '0',  'proxy'=>1, 'proxy_type'=>'linux',
            'info' => '', 'lapse' => 300,   'include'=>1,
      );



      $CFG_MONITOR_AGENT[]=array(
            'subtype' => 'xagt_004300',   'class' => 'proxy-linux',  'description' => 'NUMERO DE PROCESOS EN VARIOS EQUIPOS',
            'apptype' => 'SO.LINUX',  'itil_type' => '1',     'tag' => '001',	   'esp'=>'o1', 'iptab' => '1',
            'items' => 'Num. Procesos',        'vlabel' => 'Num',      'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',        'top_value' => '1',     'module' => 'mod_xagent_get',    'nparams' => '3',
            'params' => '[-n;Host;;2]:[-r;Otros hosts;;0]:[-p;Proceso;;0]',     'params_descr' => '',
            'script' => 'linux_metric_snmp_count_proc_multiple_devices.pl',         'severity' => '1',
            'cfg' => '2', 'custom' => '0',  'get_iid' => '0',  'proxy'=>1, 'proxy_type'=>'linux',
            'info' => '', 'lapse' => 300,   'include'=>1,
      );


?>
