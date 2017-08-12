<?php

//---------------------------------------------------------------------------------------------------------
// PARAMETROS DE SCRIPTS PROXY-LINUX
// xagt_004000-xagt_004999
//---------------------------------------------------------------------------------------------------------

//linux_metric_certificate_expiration_time.pl
//[;Puerto;443]
   $CFG_MONITOR_PARAM[]=array(
		'subtype' => 'xagt_004000', 'hparam' => '00000000', 'type' => 'xagent', 'enable' => '1', 'value' => '',
		'script' => 'linux_metric_certificate_expiration_time.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004000', 'hparam' => '00000001', 'type' => 'xagent', 'enable' => '1', 'value' => '443',
      'script' => 'linux_metric_certificate_expiration_time.pl',
   );


   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004001', 'hparam' => '00000000', 'type' => 'xagent', 'enable' => '1', 'value' => '',
      'script' => 'linux_metric_certificate_expiration_time.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004001', 'hparam' => '00000001', 'type' => 'xagent', 'enable' => '1', 'value' => '443',
      'script' => 'linux_metric_certificate_expiration_time.pl',
   );

//linux_metric_mail_loop.pl
//[-mxhost;Host SMTP;]:[-to;Destinatario del correo;]:[-from;Origen del correo;]:[-pop3host;Host POP3;]:[-user;Usuario POP3;]:[-pwd;Clave POP3;]:[-n;Numero de correos a enviar;3]
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004010', 'hparam' => '00000010', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mail_loop.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004010', 'hparam' => '00000011', 'type' => 'xagent', 'enable' => '1', 'value'=>'25',
      'script' => 'linux_metric_mail_loop.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004010', 'hparam' => '00000012', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mail_loop.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004010', 'hparam' => '00000013', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mail_loop.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004010', 'hparam' => '00000014', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mail_loop.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004010', 'hparam' => '00000015', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mail_loop.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004010', 'hparam' => '00000016', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mail_loop.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004010', 'hparam' => '00000017', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mail_loop.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004010', 'hparam' => '00000018', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mail_loop.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004010', 'hparam' => '00000019', 'type' => 'xagent', 'enable' => '1', 'value'=>'110',
      'script' => 'linux_metric_mail_loop.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004010', 'hparam' => '0000001a', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mail_loop.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004010', 'hparam' => '0000001b', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mail_loop.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004010', 'hparam' => '0000001c', 'type' => 'xagent', 'enable' => '1', 'value'=>'3',
      'script' => 'linux_metric_mail_loop.pl',
   );


//linux_metric_mysql_var.pl
//[-host;Host con MySQL;]:[-user;Usuario de acceso;]:[-pwd;Clave del usuario;]
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004100', 'hparam' => '00000020', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mysql_var.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004100', 'hparam' => '00000021', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mysql_var.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004100', 'hparam' => '00000022', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mysql_var.pl',
   );



   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004101', 'hparam' => '00000020', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mysql_var.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004101', 'hparam' => '00000021', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mysql_var.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004101', 'hparam' => '00000022', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mysql_var.pl',
   );


   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004102', 'hparam' => '00000020', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mysql_var.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004102', 'hparam' => '00000021', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mysql_var.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004102', 'hparam' => '00000022', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_mysql_var.pl',
   );


//linux_metric_ssh_files_in_dir.pl
//[-n;Host;]:[-u;User;]:[-p;Password;]:[-d;Directorio;]:[-a;Patron;]
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004200', 'hparam' => '00000030', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_ssh_files_in_dir.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004200', 'hparam' => '00000031', 'type' => 'xagent', 'enable' => '1', 'value'=>'$sec.ssh.user',
      'script' => 'linux_metric_ssh_files_in_dir.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004200', 'hparam' => '00000032', 'type' => 'xagent', 'enable' => '1', 'value'=>'$sec.ssh.pwd',
      'script' => 'linux_metric_ssh_files_in_dir.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004200', 'hparam' => '00000033', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_ssh_files_in_dir.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004200', 'hparam' => '00000034', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_ssh_files_in_dir.pl',
   );

//linux_metric_ssh_files_per_proccess.pl
//[-n;Host;]:[-u;User;]:[-p;Password;]
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004201', 'hparam' => '00000040', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_ssh_files_per_proccess.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004201', 'hparam' => '00000041', 'type' => 'xagent', 'enable' => '1', 'value'=>'$sec.ssh.user',
      'script' => 'linux_metric_ssh_files_per_proccess.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004201', 'hparam' => '00000042', 'type' => 'xagent', 'enable' => '1', 'value'=>'$sec.ssh.pwd',
      'script' => 'linux_metric_ssh_files_per_proccess.pl',
   );

//linux_metric_route_tag.pl (MULTIMETRICA)
//[-host;Host;]
//<001> Route Tag = 317488
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004202', 'hparam' => '00000050', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_route_tag.pl',
   );
//<002> Number of Hops = 1
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004203', 'hparam' => '00000050', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_route_tag.pl',
   );


//linux_metric_snmp_count_proc_multiple_devices.pl (MULTIMETRICA)
//[-host;Host;]
//<xxxx> Num. procesos [xxxx] = 3
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004300', 'hparam' => '00000055', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_snmp_count_proc_multiple_devices.pl',
   );
   $CFG_MONITOR_PARAM[]=array(
      'subtype' => 'xagt_004300', 'hparam' => '00000056', 'type' => 'xagent', 'enable' => '1', 'value'=>'',
      'script' => 'linux_metric_snmp_count_proc_multiple_devices.pl',
   );


?>
