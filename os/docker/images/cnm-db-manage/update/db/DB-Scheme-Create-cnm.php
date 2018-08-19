<?php

$DBExcepcionCNM = array();

//OJO: Hay que poner 2 espacios a la hora de definir las primay keys
// entre KEY y el parentesis.
// 'PRIMARY KEY  (`name`,`time_start`)' =>'',
$DBSchemeCNM = array(

	//Tabla cfg_clients : Tabla administrativa de clientes, para datos de subscripcion, licencias etc ...
   'cfg_clients'=>array(
      'id_client' => "int(11) NOT NULL auto_increment",
      'descr' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_client`)' =>'',
   ),

	//Tabla cfg_cnms : Contiene la lista de sistemas CNM dentro de una vision de infraestructura conjunta
	// (master_domain).
	// hidx : Es el indice da cada uno de los CNMs
	// cid : Es el valor que el cliente debe especificar al hacer login en el multi-cnm
/*
	// OLD
	'cfg_cnms'=>array( //Tabla cfg_cnms
		'hidx' => "int(11) NOT NULL auto_increment",
		'cid' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'descr' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'db1_name' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'db1_server' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default 'localhost'",
		'db1_user' => "varchar(10) character set utf8 collate utf8_spanish_ci NOT NULL",
		'db1_pwd' => "varchar(16) character set utf8 collate utf8_spanish_ci NOT NULL default 'cnm123'",
      'db2_name' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'db2_server' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default 'localhost'",
		'db2_user' => "varchar(10) character set utf8 collate utf8_spanish_ci NOT NULL",
		'db2_pwd' => "varchar(16) character set utf8 collate utf8_spanish_ci NOT NULL default 'cnm123'",
      'host_ip' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'host_name' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'host_descr' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
		'id_client' => "int(11) NOT NULL default '0'",
		'status' => "int(11) NOT NULL default '0'",
		'PRIMARY KEY  (`hidx`)' =>'',
		'UNIQUE KEY `k_cid` (`cid`,`host_ip`)' =>''
	),
*/
   'cfg_cnms'=>array( //Tabla cfg_cnms
      'hidx' => "int(11) NOT NULL auto_increment",
      'cid' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'descr' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'db1_name' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'host_ip' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'host_name' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'host_descr' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'id_client' => "int(11) NOT NULL default '0'",
      'status' => "int(11) NOT NULL default '0'",
		'mode' => "varchar(20) character set utf8 collate utf8_spanish_ci NOT NULL default 'api'", // Forma en la que se sincronizan en el entorno multi: ws | api
      'PRIMARY KEY  (`hidx`)' =>'',
      'UNIQUE KEY `k_cid` (`cid`,`host_ip`)' =>''
   ),
/*
   'cfg_hosts'=>array( //Tabla cfg_hosts
      'hidx' => "int(11) NOT NULL auto_increment",
      'ip' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'name' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'descr' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`hidx`)' =>'',
		'KEY `k_ip` (`ip`)' =>'',
   ),
*/

   'cfg_domains'=>array( //Tabla cfg_domains
      'id_domain' => "int(11) NOT NULL auto_increment",
      'name' => "varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'descr' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_domain`)' =>'',
      'UNIQUE KEY `k_name` (`name`)' =>'',
   ),

   'cfg_cnms2domains'=>array( //Tabla cfg_clients2domains
		'hidx' => "int(11) NOT NULL default '0'",
		'id_domain' => "int(11) NOT NULL default '0'",
      'PRIMARY KEY  (`hidx`,`id_domain`)' =>'',
   ),


	// Tablas de trabajo
   'work_snmp'=>array( //Tabla work_snmp

      'id_work'=>"int(11) NOT NULL auto_increment",
      'cid'=>"varchar(10) character set utf8 collate utf8_spanish_ci NOT NULL default ''",

      'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'domain'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'version'=>"varchar(2) character set utf8 collate utf8_spanish_ci default '1'",
      'credentials'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'public'",

      'id_dev'=>"int(11) NOT NULL default '0'",
      'id_dest'=>"int(11) NOT NULL default '0'",
      'id_metric'=>"int(11) NOT NULL default '0'",
      'mname'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'host'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'top_value'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'file'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'mtype'=>"varchar(40) character set utf8 collate utf8_spanish_ci default NULL",
      'mode'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
      'module'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
      'severity'=>"int(11) default '1'",
      'host_idx'=>"int(11) NOT NULL default '1'",
		'lapse'=>"int(11) NOT NULL default '300'",
      'crawler_idx'=>"int(11) default NULL",
      'crawler_pid'=>"int(11) default NULL",
		'esp'=>"varchar(1024) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'status'=>"int(11) NOT NULL default '0'",

      'cause' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'expr' => "varchar(200) character set utf8 collate utf8_spanish_ci default NULL",
      'params' => "varchar(255) character set utf8 collate utf8_spanish_ci default NULL",

      'iid'=>"varchar(240) character set utf8 collate utf8_spanish_ci default NULL",
      'subtable'=>"int(11) NOT NULL default '1'",

      'oid'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",

      'get_iid'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'cfg'=>"int(11) NOT NULL default '0'",
		'date' => "int(11) NOT NULL default '0'",
		'nitems'=>"int(11) NOT NULL default '1'",

		//temporal mientras existan rrds
		'file'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",

      'PRIMARY KEY  (`mname`,`id_dev`,`cid`)'=>'',
      'KEY `k_id_work` (`id_work`)'=>''
   ),


   'work_latency'=>array( //Tabla work_latency

      'id_work'=>"int(11) NOT NULL auto_increment",
      'cid'=>"varchar(10) character set utf8 collate utf8_spanish_ci NOT NULL default ''",

      'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'domain'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'version'=>"varchar(2) character set utf8 collate utf8_spanish_ci default '1'",
      'credentials'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'public'",

      'id_dev'=>"int(11) NOT NULL default '0'",
      'id_dest'=>"int(11) NOT NULL default '0'",
      'id_metric'=>"int(11) NOT NULL default '0'",
      'mname'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'host'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'top_value'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'file'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'mtype'=>"varchar(40) character set utf8 collate utf8_spanish_ci default NULL",
      'mode'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
      'module'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
      'severity'=>"int(11) default '1'",
      'host_idx'=>"int(11) NOT NULL default '1'",
      'iid'=>"varchar(240) character set utf8 collate utf8_spanish_ci default NULL",
      'subtable'=>"int(11) NOT NULL default '1'",
		'lapse'=>"int(11) NOT NULL default '300'",
      'crawler_idx'=>"int(11) default NULL",
      'crawler_pid'=>"int(11) default NULL",
      'status'=>"int(11) NOT NULL default '0'",

      'cause' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'expr' => "varchar(200) character set utf8 collate utf8_spanish_ci default NULL",
      'params' => "varchar(1024) character set utf8 collate utf8_spanish_ci default NULL",

      'monitor'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'monitor_data'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'date' => "int(11) NOT NULL default '0'",
		'cfg' => "int(11) NOT NULL DEFAULT '0'",
		'nitems'=>"int(11) NOT NULL default '1'",

      //temporal mientras existan rrds
      'file'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",

      'PRIMARY KEY  (`mname`,`id_dev`,`cid`)'=>'',
      'KEY `k_id_work` (`id_work`)'=>''
   ),


   'work_xagent'=>array( //Tabla work_xagent

      'id_work'=>"int(11) NOT NULL auto_increment",
      'cid'=>"varchar(10) character set utf8 collate utf8_spanish_ci NOT NULL default ''",

      'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'domain'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ip'=>"varchar(22) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'version'=>"varchar(2) character set utf8 collate utf8_spanish_ci default '1'",
      'credentials'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'public'",

      'id_dev'=>"int(11) NOT NULL default '0'",
      'id_dest'=>"int(11) NOT NULL default '0'",
      'id_metric'=>"int(11) NOT NULL default '0'",
      'mname'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'host'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
		'top_value'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'file'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'mtype'=>"varchar(40) character set utf8 collate utf8_spanish_ci default NULL",
      'mode'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
      'module'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
      'severity'=>"int(11) default '1'",
      'host_idx'=>"int(11) NOT NULL default '1'",
      'iid'=>"varchar(240) character set utf8 collate utf8_spanish_ci default NULL",
      'subtable'=>"int(11) NOT NULL default '1'",
		'lapse'=>"int(11) NOT NULL default '300'",
      'crawler_idx'=>"int(11) default NULL",
      'crawler_pid'=>"int(11) default NULL",
      'status'=>"int(11) NOT NULL default '0'",

      'cause' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'expr' => "varchar(200) character set utf8 collate utf8_spanish_ci default NULL",
      'params' => "varchar(1024) character set utf8 collate utf8_spanish_ci default NULL",

      'script'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'nparams'=>"int(11) NOT NULL default '0'",
      'class'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'items'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'cfg'=>"int(11) NOT NULL default '0'",
      'custom'=>"int(11) NOT NULL default '0'",
      'get_iid'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'id_proxy'=>"int(11) NOT NULL default '0'",
      'date' => "int(11) NOT NULL default '0'",

		'tag'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '001'",
		'esp'=>"varchar(1024) character set utf8 collate utf8_spanish_ci NOT NULL default ''",

      'proxy_type'=>"varchar(10) character set utf8 collate utf8_spanish_ci NOT NULL default 'linux'",
      'proxy_user'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default 'www-data'",
		'nitems'=>"int(11) NOT NULL default '1'",

      //temporal mientras existan rrds
      'file'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",

		'timeout'=>"int(11) NOT NULL default '30'",

      'PRIMARY KEY  (`mname`,`id_dev`,`cid`)'=>'',
      'KEY `k_id_work` (`id_work`)'=>''
   ),

/*
   'work_xagent_proxy'=>array( //Tabla work_xagent_proxy

      'id_work'=>"int(11) NOT NULL auto_increment",
      'cid'=>"varchar(10) character set utf8 collate utf8_spanish_ci NOT NULL default ''",

      'name'=>"varchar(50) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'domain'=>"varchar(30) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'ip'=>"varchar(15) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'version'=>"varchar(2) character set utf8 collate utf8_spanish_ci default '1'",
      'credentials'=>"varchar(255) character set utf8 collate utf8_spanish_ci default 'public'",

      'id_dev'=>"int(11) NOT NULL default '0'",
      'id_dest'=>"int(11) NOT NULL default '0'",
      'id_metric'=>"int(11) NOT NULL default '0'",
      'mname'=>"varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'type'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
      'subtype'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'label'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'host'=>"varchar(50) character set utf8 collate utf8_spanish_ci default NULL",
      'top_value'=>"float default NULL",
      'file'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'mtype'=>"varchar(40) character set utf8 collate utf8_spanish_ci default NULL",
      'mode'=>"varchar(20) character set utf8 collate utf8_spanish_ci default NULL",
      'module'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'watch'=>"varchar(255) character set utf8 collate utf8_spanish_ci default '0'",
      'severity'=>"int(11) default '1'",
      'host_idx'=>"int(11) NOT NULL default '1'",
      'iid'=>"varchar(240) character set utf8 collate utf8_spanish_ci default NULL",
      'subtable'=>"int(11) NOT NULL default '1'",
		'lapse'=>"int(11) NOT NULL default '300'",
      'crawler_idx'=>"int(11) default NULL",
      'crawler_pid'=>"int(11) default NULL",
      'status'=>"int(11) NOT NULL default '0'",

      'cause' => "varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default ''",
      'expr' => "varchar(200) character set utf8 collate utf8_spanish_ci default NULL",
      'params' => "varchar(255) character set utf8 collate utf8_spanish_ci default NULL",

      'script'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'nparams'=>"int(11) NOT NULL default '0'",
      'params'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'class'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'items'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'cfg'=>"int(11) NOT NULL default '0'",
      'custom'=>"int(11) NOT NULL default '0'",
      'get_iid'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
      'id_proxy'=>"int(11) NOT NULL default '0'",
      'date' => "int(11) NOT NULL default '0'",


      //temporal mientras existan rrds
      'file'=>"varchar(255) character set utf8 collate utf8_spanish_ci default NULL",

      'PRIMARY KEY  (`mname`,`id_dev`,`cid`)'=>'',
      'KEY `k_id_work` (`id_work`)'=>''
   ),

*/
)
?>
