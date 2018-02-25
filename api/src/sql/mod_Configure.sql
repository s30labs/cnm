<?php

$sql_pool=array(

   //---------------------------------------------------------------------------------------
   //Domain cmds
   'cnm_flush_domain_alerts'=>"DELETE FROM alerts where cid=:__CID__",
	'cnm_store_domain_alerts'=>"INSERT INTO alerts (cid,id_device,id_alert_type,cause,name,domain,ip,notif,id_alert,mname,watch,event_data,ack,id_ticket,severity,type,date,label,counter) VALUES (:__CID__,:__ID_DEVICE__,:__ID_ALERT_TYPE__,:__CAUSE__,:__NAME__,:__DOMAIN__,:__IP__,:__NOTIF__,:__ID_ALERT__,:__MNAME__,:__WATCH__,:__EVENT_DATA__,  :__ACK__,:__ID_TICKET__,:__SEVERITY__,:__TYPE__,:__DATE__,:__LABEL__,:__COUNTER__)",

   'cnm_flush_domain_views'=>"DELETE FROM cfg_views where cid=:__CID__",
	'cnm_store_domain_views'=>"INSERT INTO cfg_views (id_cfg_view,name,type,function,weight,background,red,orange,yellow,itil_type,blue,ruled,severity,cid) VALUES (:__ID_CFG_VIEW__,:__NAME__,:__TYPE__,:__FUNCTION__,:__WEIGHT__,:__BACKGROUND__,:__RED__,:__ORANGE__,:__YELLOW__,:__ITIL_TYPE__,:__BLUE__,:__RULED__,:__SEVERITY__,:__CID__)",

	'cnm_flush_domain_devices2profile'=>"DELETE FROM cfg_devices2organizational_profile where cid=:__CID__",
	'cnm_store_domain_devices2profile'=>"INSERT INTO cfg_devices2organizational_profile (id_dev,id_cfg_op,cid) VALUES (:__ID_DEV__,:__ID_CFG_OP__,:__CID__)",

   'cnm_flush_domain_user2view'=>"DELETE FROM cfg_user2view where cid=:__CID__",
   'cnm_store_domain_user2view'=>"INSERT INTO cfg_user2view (id_user,id_cfg_view,cid) VALUES (:__ID_USER__,:__ID_CFG_VIEW__,:__CID__)",



 /**
   * **************************************************************** *
   * Modulo: login.sql
   * Descripcion: Modulo que contiene las consultas que se van a usar
   * en el modulo login.php
   * **************************************************************** *
   */

   //---------------------------------------------------------------------------------------
	// Comprobar si el usuario tiene password encriptado
	'chk_enc_password'=>"SELECT if(token is null,0,1) AS enc FROM cfg_users WHERE binary login_name='__LOGIN_NAME__'",
	'update_enc_password'=>"UPDATE cfg_users SET token='__TOKEN__' WHERE binary login_name='__LOGIN_NAME__'",
   //Datos de usuario
   'datos_usuario'=>"SELECT a.id_user,a.login_name,a.passwd,a.descr,a.perfil,a.timeout,b.template,b.custom FROM cfg_users a,cfg_operational_profile b WHERE a.perfil=b.id_operational_profile AND binary a.login_name='__LOGIN_NAME__' AND binary a.passwd='__PASSWD__'",
   'datos_usuario_enc'=>"SELECT a.id_user,a.login_name,a.token,a.descr,a.perfil,a.timeout,b.template,b.custom,a.language,a.plugin_auth FROM cfg_users a,cfg_operational_profile b WHERE a.perfil=b.id_operational_profile AND binary a.login_name='__LOGIN_NAME__'",
   //Grupos organizativos
   'grupos_organizativos'=>"SELECT id_cfg_op FROM cfg_organizational_profile WHERE user_group REGEXP ',__ID_USER__,'",
   //Es administrador global
   // 'es_admin_global'=>"SELECT COUNT(*) AS cuantos FROM cfg_organizational_profile WHERE descr='Global' AND user_group REGEXP ',__ID_USER__,';",
   'es_admin_global'=>"SELECT COUNT(*) AS cuantos FROM cfg_users WHERE perfil=1 AND id_user='__ID_USER__'",
	

 /**
   * **************************************************************** *
   * Modulo: mod_dispositivo.sql
   * **************************************************************** *
   */

	'all_device_custom_data'=>"SELECT * FROM devices_custom_data WHERE id_dev IN (__ID_DEV__)",
	// 'device_custom_data'=>"SELECT a.*__USER_FIELDS__ FROM devices a LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev IN (__ID_DEV__)",
	'device_custom_data'=>"SELECT DISTINCT(a.id_dev),c.*__USER_FIELDS__ FROM devices a LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev IN (__ID_DEV__)",
	'all_devices_mod_dispositivo_lista_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
	'all_devices_mod_dispositivo_lista_create_temp'=>"create temporary table t1 (SELECT a.*,ifnull((select count(distinct b.id_alert) from alerts b WHERE b.severity=1 AND b.id_device=a.id_dev AND b.counter>0 group by b.id_device),0) as red,ifnull((select count(distinct b.id_alert) from alerts b WHERE b.severity=2 AND b.id_device=a.id_dev AND b.counter>0 group by b.id_device),0) as orange,ifnull((select count(distinct b.id_alert) from alerts b WHERE b.severity=3 AND b.id_device=a.id_dev AND b.counter>0 group by b.id_device),0) as yellow,ifnull((select count(distinct b.id_alert) from alerts b WHERE b.severity=4 AND b.id_device=a.id_dev AND b.counter>0 group by b.id_device),0) as blue,ifnull((select count(distinct c.id_metric) from metrics c WHERE c.status=0 AND c.id_dev=a.id_dev),0) as num_metricas__USER_FIELDS__ FROM devices a LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev)",
	'all_devices_mod_dispositivo_lista'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
	'all_devices_count_mod_dispositivo_lista'=>"SELECT COUNT(DISTINCT id_dev) AS cuantos FROM t1 WHERE ''='' __CONDITION__ GROUP BY id_dev",
	'get_metric_out_files'=>"SELECT a.iid,b.script,c.out_files FROM metrics a,cfg_monitor_agent b,cfg_monitor_agent_script c WHERE a.id_metric IN (__ID_METRIC__) AND a.subtype=b.subtype AND b.script=c.script AND c.out_files IS NOT NULL",

   // Clonar
   'cnm_dispositivo_clonar_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
   'cnm_dispositivo_clonar_create_temp'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_dev,a.status,a.name,a.domain,a.ip,a.type,a.sysoid,a.sysdesc,a.mac,a.sysloc__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile b) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev=b.id_dev AND b.id_cfg_op IN (__ID_CFG_OP__))",
   'cnm_dispositivo_clonar_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'cnm_dispositivo_clonar_count' => "SELECT COUNT(DISTINCT id_dev) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

	// Alertas ----
	'cnm_alerts_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",

	// Multi - CNM
	'cnm_alerts_create_temp'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_alert,a.id_device,a.ack,a.id_ticket as ticket,a.critic,from_unixtime(a.date_last) AS date_last,a.ticket_descr,a.severity,a.type,a.dtype,from_unixtime(a.date) as date_str, a.date,a.name,a.domain,a.ip,label,ifnull(event_data,'')as event_data,a.counter FROM alerts_read a,alert2user b, cnm.cfg_cnms c WHERE a.counter>0 AND a.cid=b.cid AND a.cid_ip=b.cid_ip AND a.id_alert=b.id_alert AND b.login_name='__LOGIN_NAME__' AND a.cid_ip=c.host_ip AND a.cid=c.cid AND a.cid_ip='__CID_IP__' AND a.cid='__CID__')",

	'cnm_alerts_create_temp_new'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_alert,a.id_device,a.ack,a.correlated,a.id_ticket as ticket,a.critic,from_unixtime(a.date_last) AS date_last,a.ticket_descr,a.severity,a.type,a.dtype,from_unixtime(a.date) as date_str, a.date,a.name,a.domain,a.ip,label,ifnull(event_data,'')as event_data,a.counter__USER_FIELDS__ FROM (alerts_read a,alert2user b, cnm.cfg_cnms c) LEFT JOIN devices_custom_data d ON a.id_device=d.id_dev WHERE a.counter>0 AND a.cid=b.cid AND a.cid_ip=b.cid_ip AND a.id_alert=b.id_alert AND b.login_name='__LOGIN_NAME__' AND a.cid_ip=c.host_ip AND a.cid=c.cid AND a.cid_ip='__CID_IP__' AND a.cid='__CID__')",
         //'cnm_get_devices_layout_create_temp2' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,0 AS asoc,a.name,a.critic,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.network,a.sysdesc,a.version,a.entity,a.sysloc,IF(a.mac_vendor='-',a.mac,IF(a.mac='',a.mac_vendor,CONCAT(a.mac_vendor,'<br> ',a.mac))) AS mac,0 AS yellow,0 AS orange,0 AS red,0 AS blue,IFNULL(num_metricas,0) as cuantos__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev LEFT JOIN t2 ON a.id_dev=t2.id_dev WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__'",


	// Alertas de vistas -----
	'cnm_alerts_view_delete_temp' => "DROP TEMPORARY TABLE IF EXISTS t1",
	'cnm_alerts_view_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_alert,d.id_cfg_view,a.ack,a.id_ticket as ticket,a.critic,from_unixtime(a.date_last) AS date_last,a.ticket_descr,a.severity,a.type,a.dtype,from_unixtime(a.date) as date_str, a.date,a.name,a.domain,a.ip,label,ifnull(event_data,'')as event_data,a.counter FROM alerts_read a,alert2user b, cnm.cfg_cnms c, cfg_views2metrics d WHERE a.counter>0 AND a.cid=b.cid AND a.cid_ip=b.cid_ip AND a.id_alert=b.id_alert AND b.login_name='__LOGIN_NAME__' AND a.cid_ip=c.host_ip AND a.cid=c.cid AND a.cid_ip='__CID_IP__' AND a.cid='__CID__' AND d.id_metric=a.id_metric)",

	'cnm_alerts_delete_alerts_read'=>"DELETE FROM alerts_read WHERE cid='__CID__' AND cid_ip='__CID_IP__' AND id_alert IN (__ID_ALERT__)",
	'cnm_alerts_delete_alerts_remote'=>"DELETE FROM alerts_remote WHERE cid='__CID__' AND cid_ip='__CID_IP__' AND id_alert IN (__ID_ALERT__)",
	// 'cnm_alerts_get_list'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
	'cnm_alerts_get_list'=>"SELECT * FROM t1 WHERE __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   // 'cnm_alerts_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
   'cnm_alerts_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE __CONDITION__",


	
	'cnm_alerts_ack_alerts_read'=>"UPDATE alerts_read SET ack=__ACK__ WHERE cid='__CID__' AND cid_ip='__CID_IP__' AND id_alert IN (__ID_ALERT__)",
	'cnm_alerts_ack_alerts_remote'=>"UPDATE alerts_remote SET ack=__ACK__ WHERE cid='__CID__' AND cid_ip='__CID_IP__' AND id_alert IN (__ID_ALERT__)",

	'cnm_alerts_alerts_read_info'=>"SELECT id_device FROM alerts_read WHERE cid='__CID__' AND cid_ip='__CID_IP__' AND id_alert IN (__ID_ALERT__)",
	'cnm_alerts_delete_alerts_read_by_id_device'=>"DELETE FROM alerts_read WHERE cid='__CID__' AND cid_ip='__CID_IP__' AND id_device IN (__ID_DEVICE__)",
	'cnm_alerts_delete_alerts_remote_by_id_device'=>"DELETE FROM alerts_remote WHERE cid='__CID__' AND cid_ip='__CID_IP__' AND id_device IN (__ID_DEVICE__)",


	'cnm_refresh_alerts_read'=>"CALL sp_alerts_read()",

   // Alertas globales ----
   'cnm_global_alerts_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",

	// Multi - OK
   // 'cnm_global_alerts_create_temp'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_alert,a.ack,a.id_ticket as ticket,from_unixtime(a.date_last) AS date_last,a.severity,a.type,from_unixtime(a.date) as date_str, a.date,a.name,a.domain,a.ip,label,ifnull(event_data,'')as event_data,a.counter,c.descr as cnm_descr,c.hidx,a.ticket_descr,a.critic,a.cid,a.cid_ip,a.id_device FROM alerts_read a,alert2user b, cnm.cfg_cnms c WHERE a.counter>0 AND a.cid=b.cid AND a.cid_ip=b.cid_ip AND a.id_alert=b.id_alert AND b.login_name='__LOGIN_NAME__' AND a.cid_ip=c.host_ip AND a.cid=c.cid AND c.hidx IN (__HIDX__))",
   'cnm_global_alerts_create_temp'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_alert,a.ack,a.id_ticket as ticket,from_unixtime(a.date_last) AS date_last,a.severity,a.type,from_unixtime(a.date) as date_str, a.date,a.name,a.domain,a.ip,label,ifnull(event_data,'')as event_data,a.counter,c.descr as cnm_descr,c.hidx,a.ticket_descr,a.critic,a.cid,a.cid_ip,a.id_device__USER_FIELDS__ FROM (alerts_read a,alert2user b, cnm.cfg_cnms c) LEFT JOIN mem_global_devices_custom_data d ON a.id_device=d.id_dev AND a.cid=d.cid AND a.cid_ip=d.cid_ip  WHERE a.counter>0 AND a.cid=b.cid AND a.cid_ip=b.cid_ip AND a.id_alert=b.id_alert AND b.login_name='__LOGIN_NAME__' AND a.cid_ip=c.host_ip AND a.cid=c.cid AND c.hidx IN (__HIDX__))",

   'cnm_global_alerts_get_list'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'cnm_global_alerts_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",


   // Histórico de alertas ----
   'cnm_halerts_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
   // 'cnm_halerts_create_temp'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_alert,a.ack,a.id_ticket as ticket,a.critic,from_unixtime(a.date_last) AS date_last,a.severity,a.type,from_unixtime(a.date) as date_str, a.date,b.status,b.name,b.domain,b.ip,label,event_data,counter,duration,b.id_dev FROM alerts_store a,devices b,cfg_devices2organizational_profile e WHERE a.id_device=b.id_dev AND b.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='default')",
   'cnm_halerts_create_temp'=>"CREATE TEMPORARY TABLE t1 (SELECT DISTINCT(a.id_alert) AS id_alert,a.ack,a.id_ticket as ticket,a.critic,from_unixtime(a.date_last) AS date_last,a.severity,a.type,from_unixtime(a.date) as date_str, a.date,b.status,b.name,b.domain,b.ip,label,event_data,counter,duration,b.id_dev FROM alerts_store a,devices b,cfg_devices2organizational_profile e WHERE a.id_device=b.id_dev AND b.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='default')",
   // 'cnm_halerts_create_temp_new'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_alert,a.ack,a.id_ticket as ticket,a.critic,from_unixtime(a.date_last) AS date_last,a.severity,a.type,from_unixtime(a.date) as date_str, a.date,b.status,b.name,b.domain,b.ip,label,event_data,counter,duration,b.id_dev__USER_FIELDS__ FROM (alerts_store a,devices b,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data d ON a.id_device=d.id_dev WHERE a.id_device=b.id_dev AND b.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='default')",
   // 'cnm_halerts_create_temp_new'=>"CREATE TEMPORARY TABLE t1 (SELECT DISTINCT(a.id_alert) AS id_alert,a.ack,a.correlated,a.id_ticket as ticket,a.critic,from_unixtime(a.date_last) AS date_last,a.severity,a.type,from_unixtime(a.date) as date_str, a.date,b.status,b.name,b.domain,b.ip,label,event_data,counter,duration,b.id_dev__USER_FIELDS__ FROM (alerts_store a,devices b,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data d ON a.id_device=d.id_dev WHERE a.id_device=b.id_dev AND b.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='default')",
   'cnm_halerts_create_temp_new'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_alert,a.ack,a.correlated,a.id_ticket as ticket,a.critic,from_unixtime(a.date_last) AS date_last,a.severity,a.type,from_unixtime(a.date) as date_str, a.date,b.status,b.name,b.domain,b.ip,label,event_data,counter,duration,b.id_dev__USER_FIELDS__ FROM (alerts_store a,devices b,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data d ON a.id_device=d.id_dev WHERE a.id_device=b.id_dev AND b.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='default')",
   // 'cnm_halerts_get_list'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'cnm_halerts_get_list'=>"SELECT * FROM t1 WHERE __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   // 'cnm_halerts_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
   'cnm_halerts_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE __CONDITION__",


	// ---------------------------------------------------------------------------------------
	// Nueva tabla que mapea usuarios a perfiles organizativos
   'set_users2organizational_profile'=>"INSERT INTO cfg_users2organizational_profile (id_user,id_cfg_op,login_name) VALUES ('__ID_USER__','__ID_CFG_OP__','__LOGIN_NAME__') ON DUPLICATE KEY UPDATE id_user='__ID_USER__', id_cfg_op='__ID_CFG_OP__', login_name='__LOGIN_NAME__' ",
   'delete_users2organizational_profile'=>"DELETE FROM cfg_users2organizational_profile WHERE id_user='__ID_USER__' and id_cfg_op='__ID_CFG_OP__'",


   // ---------------------------------------------------------------------------------------
   // Nueva tabla que mapea usuarios a perfiles organizativos
   'set_users2organizational_profile'=>"INSERT INTO cfg_users2organizational_profile (id_user,id_cfg_op,login_name) VALUES ('__ID_USER__','__ID_CFG_OP__','__LOGIN_NAME__') ON DUPLICATE KEY UPDATE id_user='__ID_USER__', id_cfg_op='__ID_CFG_OP__', login_name='__LOGIN_NAME__' ",
   'delete_users2organizational_profile'=>"DELETE FROM cfg_users2organizational_profile WHERE id_user='__ID_USER__' and id_cfg_op='__ID_CFG_OP__'",


   // ---------------------------------------------------------------------------------------
   // cnm_data_device_get_info  >> Informacion de dispositivo
	// mod_dispositivo_dispositivo.php, mod_dispositivo_asistente_metricas.php
   'device_info_basic'=>"SELECT id_dev,name,domain,ip,type,status,version,community,geodata,entity FROM devices WHERE id_dev IN (__ID_DEV__)",
   'device_info_basic_by_ip'=>"SELECT * FROM devices WHERE ip='__IP__'",
   'device_info_basic_by_name_domain'=>"SELECT * FROM devices WHERE name='__NAME__' AND domain='__DOMAIN__'",
   //'device_info'=>"SELECT name,domain,ip,type,status,host_idx,wbem_user,wbem_pwd,sysoid,sysdesc,sysloc,version,community,xagent_version,background,mac,mac_vendor,critic,id_dev,geodata,network,enterprise,correlated_by,switch,entity FROM devices WHERE id_dev IN (__ID_DEV__)",
   'device_info'=>"SELECT a.name,a.domain,a.ip,a.type,a.status,a.host_idx,a.wbem_user,a.wbem_pwd,a.sysoid,a.sysdesc,a.sysloc,a.version,a.community,a.xagent_version,a.background,a.mac,a.mac_vendor,a.critic,a.id_dev,a.geodata,a.network,a.enterprise,a.correlated_by,a.switch,a.entity,a.wsize,b.rule_name,a.asset_container,a.dyn FROM devices a LEFT JOIN cfg_inside_correlation_rules b ON a.rule_subtype=b.rule_subtype WHERE a.id_dev IN (__ID_DEV__)",
   'cnm_data_device_get_info_by_id'=>"SELECT name,domain,ip,type,status,host_idx,wbem_user,wbem_pwd,sysoid,sysdesc,sysloc,version,community,xagent_version,background__USER_FIELDS__ FROM devices a LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev IN (__ID_DEV__)",
	'update_device_background'=>"UPDATE devices SET background='__BACKGROUND__' WHERE id_dev IN (__ID_DEV__)",

	// Tipos de dispositivo disponibles diferentes al tipo del dispositivo
	// mod_dispositivo_dispositivo.php
	'device_types_not_device'=>"SELECT DISTINCT type FROM devices WHERE type NOT IN (SELECT type FROM devices WHERE id_dev in (__ID_DEV__)) ORDER BY type",
	// mod_dispositivo_dispositivo.php
	// Tipo del dispositivo
	'device_types_device'=>"SELECT DISTINCT type FROM devices WHERE id_dev IN (__ID_DEV__) ORDER BY type",
	// Estado del dispositivo
	// mod_dispositivo_dispositivo.php
	'device_status'=>"SELECT status FROM devices WHERE id_dev IN (__ID_DEV__)",

	// Informacion de los perfiles organizativos a los que puede acceder el usuario si este es un usuario no administrador global
	// mod_dispositivo_dispositivo.php
	'info_user_organizational_profile'=>"SELECT descr,id_cfg_op,user_group FROM cfg_organizational_profile WHERE id_cfg_op IN (__USER_ORG_PRO__) AND descr<>'Global'",

	// Informacion de los perfiles organizativos a los que puede acceder el usuario si este es un usuario administrador global
	// mod_dispositivo_dispositivo.php
	'info_global_user_organizational_profile'=>"SELECT descr,id_cfg_op,user_group FROM cfg_organizational_profile WHERE descr<>'Global'",

	// Saber si el dispositivo esta asociado o no a un perfil organizativo
	// mod_dispositivo_dispositivo.php
	'profile_device'=>"SELECT COUNT(*) as c FROM cfg_devices2organizational_profile WHERE id_cfg_op=__ID_CFG_OP__ AND id_dev IN (__ID_DEV__)",

	// Perfiles SNMPv3 disponibles
	// mod_dispositivo_dispositivo.php
	'snmp3_profiles'=>"SELECT id_profile,profile_name FROM profiles_snmpv3 WHERE id_profile NOT IN (SELECT community FROM devices WHERE id_dev=__ID_DEV__ AND version=3) ORDER BY profile_name",

	// Perfil SNMPv3 del dispositivo
	// mod_dispositivo_dispositivo.php
	'snmp3_profile_device'=>"SELECT id_profile,profile_name FROM profiles_snmpv3 WHERE id_profile IN (SELECT community FROM devices WHERE id_dev=__ID_DEV__ AND version=3) ORDER BY profile_name",

	// Informacion de perfil snmpV3
	// mod_dispositivo_dispositivo.php, mod_dispositivo_aplicaciones.php
	'snmp3_profile_info'=>"SELECT sec_name,sec_level,auth_proto,auth_pass,priv_proto,priv_pass FROM profiles_snmpv3 WHERE id_profile=__ID_PROFILE__",

	// Actualizar dispositivo
	// mod_dispositivo_dispositivo.php
	'update_device'=>"UPDATE devices SET name='__NAME__', status='__STATUS__', domain='__DOMAIN__', ip='__IP__', wbem_user='__WBEM_USER__', wbem_pwd='__WBEM_PWD__', sysdesc='__SYSDESC__', sysoid='__SYSOID__', sysloc='__SYSLOC__', type='__TYPE__', version='__VERSION__', community='__COMMUNITY__',xagent_version='__XAGENT_VERSION__',enterprise='__ENTERPRISE__',correlated_by='__CORRELATED_BY__',mac='__MAC__', mac_vendor='__MAC_VENDOR__', critic='__CRITIC__',geodata='__GEODATA__',network='__NETWORK__', switch='__SWITCH__', wsize='__WSIZE__',asset_container='__ASSET_CONTAINER__',dyn='__DYN__' WHERE id_dev IN (__ID_DEV__)",
	
   // Actualizar campo critic en alerts y alerts_read cuando se modifica dispositivo
   // mod_dispositivo_dispositivo.php
   'update_critic_in_alerts'=>"UPDATE alerts SET critic='__CRITIC__' WHERE id_device IN (__ID_DEV__)",
   'update_critic_in_alerts_read'=>"UPDATE alerts_read SET critic='__CRITIC__' WHERE id_device IN (__ID_DEV__)",

	//ws
	'ws_update_device'=>"UPDATE devices SET __KEY_VALUE__ WHERE id_dev IN (:__ID_DEV__)",

	// Insertar dispositivo en perfil organizativo
	// mod_dispositivo_dispositivo.php
	'insert_device_organizational_profile'=>"INSERT INTO cfg_devices2organizational_profile (id_dev,id_cfg_op,cid) VALUES (__ID_DEV__,__ID_CFG_OP__,'__CID__')",

	// Borrar dispositivo de perfil organizativo
	// mod_dispositivo_dispositivo.php
	'delete_device_organizational_profile'=>"DELETE FROM cfg_devices2organizational_profile WHERE id_dev IN (__ID_DEV__) AND id_cfg_op=__ID_CFG_OP__ AND CID='__CID__'",

	// Crear dispositivo
	// mod_dispositivo_dispositivo.php
	'create_device'=>"INSERT INTO devices (name,status,domain,ip,type,version,community,wbem_user,wbem_pwd,sysdesc,sysoid,sysloc,xagent_version,enterprise,correlated_by,mac,mac_vendor,critic,network,switch,entity,wsize,asset_container,dyn) VALUES ('__NAME__','__STATUS__','__DOMAIN__','__IP__','__TYPE__','__VERSION__','__COMMUNITY__','__WBEM_USER__','__WBEM_PWD__','__SYSDESC__','__SYSOID__','__SYSLOC__','__XAGENT_VERSION__','__ENTERPRISE__','__CORRELATED_BY__','__MAC__','__MAC_VENDOR__','__CRITIC__','__NETWORK__','__SWITCH__',__ENTITY__,__WSIZE__,'__ASSET_CONTAINER__','__DYN__')",

	'ws_create_device'=>"INSERT INTO devices (name,status,domain,ip,type,version,community,wbem_user,wbem_pwd,sysdesc,sysoid,sysloc,xagent_version,enterprise,correlated_by) VALUES (':__NAME__',':__STATUS__',':__DOMAIN__',':__IP__',':__TYPE__',':__VERSION__',':__COMMUNITY__',':__WBEM_USER__',':__WBEM_PWD__',':__SYSDESC__',':__SYSOID__',':__SYSLOC__',':__XAGENT_VERSION__',':__ENTERPRISE__',':__CORRELATED_BY__')",


	'ws_create_device'=>"INSERT INTO devices (__NAMES__) VALUES (__VALUES__)",

   'add_device'=>"INSERT INTO devices (name,status,domain,ip,type,version,community,wbem_user,wbem_pwd,sysdesc,sysoid,sysloc,xagent_version,enterprise,correlated_by) VALUES (':__NAME__',':__STATUS__',':__DOMAIN__',':__IP__',':__TYPE__',':__VERSION__',':__COMMUNITY__',':__WBEM_USER__',':__WBEM_PWD__',':__SYSDESC__',':__SYSOID__',':__SYSLOC__',':__XAGENT_VERSION__',':__ENTERPRISE__',':__CORRELATED_BY__') ON DUPLICATE KEY UPDATE name=':__NAME__', status=':__STATUS__',domain=':__DOMAIN__',ip=':__IP__',type=':__TYPE__',version=':__VERSION__',community=':__COMMUNITY__',wbem_user=':__WBEM_USER__',wbem_pwd=':__WBEM_PWD__',sysdesc=':__SYSDESC__',sysoid=':__SYSOID__',sysloc=':__SYSLOC__',xagent_version=':__XAGENT_VERSION__',enterprise=':__ENTERPRISE__',correlated_by=':__CORRELATED_BY__'",

	// Crea la red en cfg_networks
	'create_network'=>"INSERT INTO cfg_networks (network) VALUES ('__NETWORK__')",


	// Obtener id_dev del dispositivo insertado
	// mod_dispositivo_dispositivo.php
	'get_id_dev'=>"SELECT id_dev FROM devices WHERE name='__NAME__' AND domain='__DOMAIN__' AND ip='__IP__'",
	'get_id_dev_by_name'=>"SELECT id_dev FROM devices WHERE name='__NAME__'",


	// Insertar dispositivo en perfil organizativo global
	// mod_dispositivo_dispositivo.php
	'insert_device_into_global_organizational_profile'=>"INSERT INTO cfg_devices2organizational_profile (id_dev,id_cfg_op,cid) VALUES (__ID_DEV__,(SELECT id_cfg_op FROM cfg_organizational_profile WHERE descr='Global'),'__CID__')",
   // Aplicaciones disponibles
	// mod_dispositivo_aplicaciones.php
   'apps_all'=>"SELECT c.id_monitor_app,c.type,c.name,c.descr,c.params,c.subtype FROM cfg_monitor_apps c, prov_default_apps2device p WHERE p.id_monitor_app=c.id_monitor_app AND p.id_dev=__ID_DEV__ order by c.descr",
	'apps_from_device'=>"SELECT * from cfg_app2device a,cfg_monitor_apps b WHERE a.aname=b.aname AND a.ip IN (SELECT ip FROM devices WHERE id_dev IN(__ID_DEV__))",
   'apps_from_device_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
   'apps_from_device_create_temp1'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_monitor_app,a.type,a.subtype,a.itil_type,a.apptype,a.name,a.descr,a.cmd,a.params,a.myrange,a.cfg,a.platform,a.script,a.format,a.enterprise,a.custom,a.aname,a.res,a.ipparam,a.iptab,a.ready,b.who FROM cfg_monitor_apps a,cfg_app2device b WHERE a.aname=b.aname AND b.ip IN (SELECT ip FROM devices WHERE id_dev IN(__ID_DEV__)))",
	//'apps_from_device_create_temp2'=>"INSERT INTO t1 (SELECT a.id_monitor_app,a.type,a.subtype,a.itil_type,a.apptype,a.name,a.descr,a.cmd,a.params,a.myrange,a.cfg,a.platform,a.script,a.format,a.enterprise,'2' AS custom,a.aname,a.res,a.ipparam,a.iptab FROM cfg_monitor_apps a, prov_default_apps2device b WHERE b.id_monitor_app=a.id_monitor_app AND b.id_dev=__ID_DEV__)",
   'apps_from_device_get_list'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
	'apps_from_device_apptypes' => "SELECT DISTINCT(apptype) FROM t1 ORDER BY apptype",
   'apps_from_device_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

   // Tipo de una aplicacion disponible
	// mod_dispositivo_aplicaciones.php
   'app_info'=>"SELECT type,subtype,itil_type,apptype,name,descr,cmd,params,myrange,cfg,platform,script,format,enterprise,custom,aname,res,ipparam,iptab,ready FROM cfg_monitor_apps WHERE id_monitor_app IN (__ID_MONITOR_APP__)",
	'app_script_info'=>"SELECT b.* FROM cfg_monitor_apps a,cfg_monitor_agent_script b WHERE a.script=b.script AND a.id_monitor_app IN ('__ID_MONITOR_APP__')",
	'aplicacion_asociar_dispositivo'=>"INSERT IGNORE INTO cfg_app2device (aname,ip,id_dev,who) VALUES ('__ANAME__',(SELECT ip FROM devices WHERE id_dev IN (__ID_DEV__)),__ID_DEV__,1)",
	'aplicacion_desasociar_dispositivo'=>"DELETE FROM cfg_app2device WHERE aname='__ANAME__' AND id_dev IN (__ID_DEV__)",
   // mod_dispositivo_asistente_metricas.php
	'dispositivo_asistente_delete_temp' => "DROP TEMPORARY TABLE t1",
	'dispositivo_asistente_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT p.id_default_metric as id_metric,p.include,p.lapse,p.type,p.subtype,p.descr as label,c.class,c.apptype FROM prov_default_metrics2device p, cfg_monitor_snmp c  WHERE p.subtype=c.subtype and p.type='snmp' and p.id_dev=__ID_DEV__) UNION (SELECT p.id_default_metric as id_metric,p.include,p.lapse,p.type,p.subtype,p.descr as label,c.subtype as class,c.apptype FROM prov_default_metrics2device p, cfg_monitor c  WHERE p.subtype=c.monitor and p.type='latency' and p.id_dev=__ID_DEV__) UNION (SELECT p.id_default_metric as id_metric,p.include,p.lapse,p.type,p.subtype,p.descr as label,c.class,c.apptype FROM prov_default_metrics2device p, cfg_monitor_agent c  WHERE p.subtype=c.subtype and p.type='xagent' and p.id_dev=__ID_DEV__)",
	'dispositivo_asistente_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
	'dispositivo_asistente_apptypes' => "SELECT DISTINCT(apptype) FROM t1 ORDER BY apptype",
	'dispositivo_asistente_count' => "SELECT COUNT(DISTINCT id_metric) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
   'dispositivo_asistente_getdata'=>"(SELECT p.id_default_metric as id_metric,p.include,p.lapse,p.type,p.subtype,p.descr as label,c.class FROM prov_default_metrics2device p, cfg_monitor_snmp c  WHERE p.subtype=c.subtype and p.type='snmp' and p.id_dev=__ID_DEV__) UNION (SELECT p.id_default_metric as id_metric,p.include,p.lapse,p.type,p.subtype,p.descr as label,c.subtype as class FROM prov_default_metrics2device p, cfg_monitor c  WHERE p.subtype=c.monitor and p.type='latency' and p.id_dev=__ID_DEV__) UNION (SELECT p.id_default_metric as id_metric,p.include,p.lapse,p.type,p.subtype,p.descr as label,c.class FROM prov_default_metrics2device p, cfg_monitor_agent c  WHERE p.subtype=c.subtype and p.type='xagent' and p.id_dev=__ID_DEV__) order by label",
	'dispositivo_asistente_clases'=>"SELECT IFNULL(b.class,'') AS class_snmp,IFNULL(c.subtype,'') AS class_latency,IFNULL(d.class,'') AS class_xagent FROM prov_default_metrics2device a LEFT JOIN cfg_monitor_snmp b ON a.subtype=b.subtype LEFT JOIN cfg_monitor c ON a.subtype=c.monitor LEFT JOIN cfg_monitor_agent d ON a.subtype=d.subtype WHERE a.id_dev IN (__ID_DEV__)",
	// mod_dispositivo_asistente_metricas.php
   'dispositivo_asistente_asignar'=>"SELECT lapse,type,subtype FROM prov_default_metrics2device WHERE id_default_metric IN (__ID_DEFAULT_METRIC__)",
	// Obtener informacion de una tarea por su id_ref
	// mod_dispositivo_documentacion.php
	'get_info_tip'=>"SELECT id_tip,id_ref,name,descr,url,from_unixtime(date)as date,date AS cnm_date FROM tips WHERE id_ref like '__ID_REF__' AND tip_type like '__TIP_TYPE__' AND tip_class=__TIP_CLASS__ ORDER BY date DESC",
	'get_info_tip_all'=>"SELECT id_tip,id_ref,name,descr,url,tip_class,tip_type,from_unixtime(date)as date,date AS cnm_date FROM tips WHERE id_ref like '__ID_REF__' AND tip_type like '__TIP_TYPE__' ORDER BY date DESC",
	// Borrar una entrada de la documentacion a partir de su id_tip
	// mod_dispositivo_documentacion.php
   'delete_tip'=>"DELETE FROM tips WHERE id_tip IN (__ID_TIP__)",
	'delete_doc_idref'=>"DELETE FROM tips WHERE id_ref='__ID_REF__' AND tip_type='__TIP_TYPE__'",
   // Insertar una entrada en la documentacion
	// mod_dispositivo_documentacion.php
   'insert_tip'=>"INSERT INTO tips (descr,id_ref,tip_type,date,name) VALUES ('__DESCR__','__ID_REF__','__TIP_TYPE__',__DATE__,'__NAME__')",
   // Actualizar una entrada de la documentacion
	// mod_dispositivo_documentacion.php
   'edit_tip'=>"UPDATE tips SET descr='__DESCR__',date=__DATE__,name='__NAME__' WHERE id_tip=__ID_TIP__",
   // Obtener informacion de los tickets asociados a un dispositivo
	// mod_dispositivo_documentacion.php
  	'cnm_ticket_get_device_tickets_by_id'=>"SELECT distinct t.descr,from_unixtime(t.date_store)as date,t.ticket_type as id_note_type,t.id_alert,t.event_data,n.name,t.ref FROM ticket t, note_types n  WHERE t.id_dev=__ID_DEV__ AND t.ticket_type<>0 AND n.id_note_type=t.ticket_type ORDER BY t.date_store",
	// ------
	// Métricas de una vista
	'metrics_device_views'=>"SELECT a.id_metric,a.label,a.type as mtype,b.status as dstatus,b.domain,b.ip,b.type as dtype__USER_FIELDS__ FROM metrics a,devices b LEFT JOIN devices_custom_data c ON b.id_dev=c.id_dev WHERE a.id_dev=b.id_dev AND b.id_dev IN (__ID_DEV__)",
	// Numero de metricas en curso por dispositivo
	// mod_dispositivo_all.php
   'metrics_devices'=>"SELECT count(a.id_metric) as cuantos,a.id_dev,b.status from metrics a, devices b WHERE a.id_dev=b.id_dev GROUP BY a.id_dev",
	'active_metrics_devices_by_id'=>"SELECT ifnull(count(a.id_metric),0) as cuantos from metrics a, devices b WHERE a.status=0 AND a.id_dev=b.id_dev AND b.id_dev IN (__ID_DEV__) GROUP BY a.id_dev",
   // Informacion de los dispositivos
	// mod_dispositivo_all.php
   //'all_devices'=>"SELECT * FROM devices a WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__ ",
   //'all_devices1'=>"SELECT id_dev,name,domain,ip,sysloc,sysdesc,sysoid,txml,type,app,status,mode,community,version,wbem_user,wbem_pwd,refresh,aping,aping_date,id_cfg_op,host_idx,background,xagent_version,enterprise,email,correlated_by FROM devices a WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__ ",
   'all_devices1'=>"SELECT id_dev,name,domain,ip,sysloc,sysdesc,sysoid,txml,type,app,status,mode,community,version,wbem_user,wbem_pwd,refresh,aping,aping_date,id_cfg_op,host_idx,background,xagent_version,enterprise,email,correlated_by FROM devices WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__ ",
	// Store.php
   //'all_devices_no_condition'=>"SELECT * FROM devices",
   'all_devices_no_condition'=>"SELECT id_dev,name,domain,ip,sysloc,sysdesc,sysoid,txml,type,app,status,mode,community,version,wbem_user,wbem_pwd,refresh,aping,aping_date,geodata,id_cfg_op,host_idx,background,xagent_version,enterprise,email,correlated_by FROM devices",
   'all_devices_count'=>"SELECT COUNT(DISTINCT a.id_alert) AS cuantos FROM devices a WHERE ''='' __CONDITION__ ",
   // mod_dispositivo_metricas_curso.php
   'get_alerts_from_device'=>"SELECT a.id_device,a.mname,a.id_alert_type,b.expr,b.cause,b.severity FROM alerts a LEFT JOIN alert_type b ON a.id_alert_type=b.id_alert_type WHERE a.counter>0 and a.id_device=__ID_DEV__",

			// Obtener las métricas en curso de un dispositivo
			'metricas_encurso_delete_temp'=>"DROP TABLE IF EXISTS t1",
			'metricas_encurso_create_temp'=>"CREATE TEMPORARY TABLE t1(SELECT a.watch,a.subtype,a.id_dev,a.name AS mname,a.correlate,a.label,a.id_metric,a.status,a.type,if(id_alert,1,0) as alarmada,ifnull(c.severity,0) AS alert_severity,c.counter as alert_counter,b.status AS device_status,d.severity,ifnull(d.cause,'-')as monitor,ifnull(d.id_alert_type,'') AS id_alert_type,' ' AS motivo,0 AS in_view FROM (metrics a,devices b) LEFT JOIN alerts c ON (a.name=c.mname AND a.id_dev=c.id_device) LEFT JOIN alert_type d ON a.watch=d.monitor WHERE a.id_dev=b.id_dev AND a.id_dev in (__ID_DEV__) AND a.status<4)",
			'metricas_encurso_update_temp1'=>"UPDATE t1 SET alert_severity=0 WHERE alert_counter<1",
			'metricas_encurso_update_temp2'=>"UPDATE t1 SET alert_severity=5 WHERE status<>0",
			'metricas_encurso_update_temp3'=>"UPDATE t1 SET motivo='__MOTIVO__' WHERE id_metric IN (__ID_METRIC__);",
			'metricas_encurso_update_snmp'=>"UPDATE t1 SET alert_severity=5 WHERE type='snmp'",
			'metricas_encurso_update_xagent'=>"UPDATE t1 SET alert_severity=5 WHERE type='xagent'",
			'metricas_encurso_update_wbem'=>"UPDATE t1 SET alert_severity=5 WHERE type='wbem'",
			'metricas_encurso_update_icmp'=>"UPDATE t1 SET alert_severity=1 WHERE mname='disp_icmp' or mname='mon_icmp'",
			'metricas_encurso_update_temp5'=>"UPDATE t1 SET alert_severity=1 WHERE subype like '%icmp'",
			'metricas_encurso_update_temp_view'=>"UPDATE t1 SET in_view=1 WHERE id_metric IN (SELECT id_metric FROM cfg_views2metrics)",
         'metricas_encurso_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'metricas_encurso_lista_no_limit' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__",
         'metricas_encurso_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
			'metricas_encurso_monitores' => "SELECT DISTINCT(monitor) AS monitor,id_alert_type,severity FROM t1 GROUP BY id_alert_type",
			'metricas_encurso_update_motivo'=>"UPDATE t1 SET motivo='__MOTIVO__' WHERE id_dev='__ID_DEV__' AND mname='__MNAME__'",

				


         // mod_dispositivo_metricas_curso.php
         'dispositivo_encurso_getdata_1'=>"DROP TABLE IF EXISTS t1",
         // mod_dispositivo_metricas_curso.php
         'dispositivo_encurso_getdata_2'=>"CREATE TEMPORARY TABLE t1(SELECT m.watch,m.subtype,m.id_dev,m.name,m.label,m.id_metric,m.status,m.type,if(id_alert,1,0) as alarmada FROM metrics m LEFT JOIN alerts a on a.mname=m.name WHERE m.id_dev in (__ID_DEV__) group by id_metric)",
         // mod_dispositivo_metricas_curso.php
         'dispositivo_encurso_getdata_3'=>"SELECT a.severity,m.label,m.id_metric,m.status,m.type,m.alarmada,ifnull(a.cause,'-')as monitor, m.name as mname FROM t1 m LEFT JOIN alert_type a on m.watch=a.monitor WHERE m.id_dev in (__ID_DEV__)and(m.status<3) order by m.subtype",
         // mod_dispositivo_metricas_curso.php
			'dispositivo_encurso_getdata_4'=>"SELECT status FROM devices WHERE id_dev=__ID_DEV__",
         // mod_dispositivo_metricas_curso.php
         'dispositivo_encurso_activar'=>"UPDATE metrics SET status=0 WHERE id_metric in (__ID_METRIC__)",
         // mod_dispositivo_metricas_curso.php
         'dispositivo_encurso_desactivar'=>"UPDATE metrics SET status=1 WHERE id_metric in (__ID_METRIC__)",

			'dispositivo_mes_status'=>"UPDATE metrics SET status=__STATUS__ WHERE id_metric in (__ID_METRIC__)",
			'dispositivo_mes_delete'=>"UPDATE prov_template_metrics2iid SET status=1 WHERE id_dev=__ID_DEV__ AND mname in (SELECT name FROM metrics WHERE id_metric in (__ID_METRIC__))",


         // mod_dispositivo_metricas_curso.php
         'dispositivo_encurso_borrar'=>"UPDATE prov_template_metrics2iid SET status=1 WHERE id_dev=__ID_DEV__ AND mname in (SELECT name FROM metrics WHERE id_metric in (__ID_METRIC__))",
			// mod_dispositivo_plantilla_metricas.php
			'dispositivo_plantilla_delete_temp'=>"DROP TABLE IF EXISTS t1",
			'dispositivo_plantilla_create_temp'=>"CREATE TEMPORARY TABLE t1(SELECT a.type,b.id_tm2iid as id_metric,b.id_template_metric,b.iid,b.label,b.status,b.mname,b.watch as monitor,c.cause as desc_monitor,c.severity as sev_monitor,c.id_alert_type FROM prov_template_metrics a, prov_template_metrics2iid b LEFT JOIN alert_type c ON b.watch=c.monitor WHERE a.id_dev=__ID_DEV__ AND b.id_template_metric=a.id_template_metric)",
         'dispositivo_plantilla_getdata'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
			'dispositivo_plantilla_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
			// mod_dispositivo_plantilla_metricas.php
         'plantilla_borrar'=> "DELETE FROM prov_template_metrics2iid WHERE id_tm2iid IN(__ID_TM2IID__)",
			// mod_dispositivo_plantilla_metricas.php
         'plantilla_asignar'=> "UPDATE prov_template_metrics2iid SET status=__STATUS__ WHERE id_tm2iid IN(__ID_TM2IID__)",
			// mod_dispositivo_plantilla_metricas.php
         'dispositivo_encurso_getdata_monitores'=>'SELECT monitor,cause,severity FROM alert_type order by cause',
			// mod_dispositivo_plantilla_metricas.php
         'check_monitors'=>" SELECT count(distinct subtype) as cuantos FROM prov_template_metrics a, prov_template_metrics2iid b WHERE a.id_template_metric=b.id_template_metric AND b.id_tm2iid IN (__ID_METRIC__)",
			// mod_dispositivo_plantilla_metricas.php
         'monitors_to_metric'=>"SELECT a.id_alert_type, a.cause, a.expr, a.severity, a.monitor FROM alert_type a, prov_template_metrics b, prov_template_metrics2iid c WHERE a.subtype=b.subtype AND b.id_template_metric=c.id_template_metric AND c.id_tm2iid IN (__ID_METRIC__) group by monitor",
			// mod_dispositivo_plantilla_metricas.php
         'dispositivo_plantilla_monitor_prov'=>"UPDATE prov_template_metrics2iid SET watch='__MONITOR__' WHERE  id_dev=__ID_DEV__ and id_tm2iid IN (__ID_METRIC__)",
			// mod_dispositivo_plantilla_metricas.php
         'dispositivo_plantilla_monitor'=>"UPDATE metrics SET watch='__MONITOR__' WHERE id_dev=__ID_DEV__ AND name IN (SELECT mname FROM prov_template_metrics2iid WHERE id_tm2iid IN (__ID_METRIC__))",
			'plantilla_monitores'=>"SELECT DISTINCT(b.id_alert_type),b.cause,b.monitor,b.severity FROM prov_template_metrics2iid a, alert_type b WHERE a.watch=b.monitor AND a.id_dev='__ID_DEV__'",
			// mod_dispositivo_lista.php
			'dispositivo_activar'=>"UPDATE devices SET status=0 WHERE id_dev IN (__ID_DEV__)",	
			// mod_dispositivo_lista.php
			'dispositivo_baja'=>"UPDATE devices SET status=1 WHERE id_dev IN (__ID_DEV__)",	
			// mod_dispositivo_lista.php
			'dispositivo_mantenimiento'=>"UPDATE devices SET status=2 WHERE id_dev IN (__ID_DEV__)",	
			// Obtener los dispositivos con alarmas
			// mod_dispositivo_lista.php
			'dispositivos_alarmados'=>"SELECT id_device,severity FROM alerts WHERE counter>0",


			//Obtiene los dispositivos dados de alta con agente
         'cnm_device_get_list_with_agent' => "SELECT id_dev,name,domain,ip FROM devices WHERE xagent_version LIKE 'CNMAgent%'",
			// Obtiene los tipos de agente dados de alta
			'cnm_device_get_list_of_agents' => "SELECT DISTINCT(xagent_version) AS xagent_version FROM devices WHERE xagent_version LIKE 'CNMAgent%'",
			//Obtiene los dispositivos dados de alta con agente windows
         'cnm_device_get_list_with_agent_win' => "SELECT id_dev,name,domain,ip FROM devices WHERE xagent_version LIKE '%win32%'",
			//Obtiene los dispositivos dados de alta con agente linux
         'cnm_device_get_list_with_agent_linux' => "SELECT id_dev,name,domain,ip FROM devices WHERE xagent_version LIKE '%linux%'",

 /**
	* **************************************************************** *
	* Modulo: vistas.sql
	* Descripcion: Modulo que contiene las consultas que se van a usar
	* en el modulo vistas.php
	* **************************************************************** *
	*/


			// mod_vistas_lista.php
			// Listar todas las vistas disponibles (administrador)
			'vistas_admin'=>"SELECT DISTINCT a.id_cfg_view, a.name, a.type, a.red, a.orange, a.yellow, a.blue, a.nmetrics, a.nsubviews, a.nremote, a.severity, a.itil_type,a.ruled,b.descr as cnm_descr,b.hidx,a.global,a.live_metric,a.live_remote FROM cfg_views a,cnm.cfg_cnms b WHERE a.cid_ip=b.host_ip AND a.global IN (0,1) AND a.cid=b.cid AND a.cid_ip='__CID_IP__' AND a.cid='__CID__'  __CONDITION__",
			// Obtener las métricas asociadas a vistas
			'vistas_num_metrics_remote_subview'=>"SELECT nmetrics,nremote,nsubviews,id_cfg_view,cid_ip,cid FROM cfg_views WHERE cid='__CID__' AND cid_ip='__CID_IP__'",
			'vistas_num_metrics'=>"SELECT count(id_metric) AS cuantos,id_cfg_view FROM cfg_views2metrics GROUP BY id_cfg_view",
			// Obtener las alertas remotas asociadas a vistas
			'vistas_num_remote'=>"SELECT count(*) AS cuantos,id_cfg_view FROM cfg_views2remote_alerts a, cfg_remote_alerts b, devices c WHERE a.id_remote_alert=b.id_remote_alert AND a.id_dev=c.id_dev GROUP BY id_cfg_view",
			// Obtener las subvistas asociadas a vistas
			'vistas_num_subview'=>"SELECT count(*) AS cuantos,id_cfg_view FROM cfg_views2views GROUP BY id_cfg_view",

			// Listar todas las vistas globales disponibles (administrador)
			'vistas_global_admin'=>"SELECT DISTINCT a.id_cfg_view, a.name, a.type, a.red, a.orange, a.yellow, a.blue, a.severity, a.itil_type,a.ruled,b.descr as cnm_descr,b.hidx,a.global,a.nmetrics,a.nremote,a.nsubviews FROM cfg_views a,cnm.cfg_cnms b WHERE a.cid_ip=b.host_ip AND a.cid=b.cid AND a.global IN (1,2) AND b.hidx IN (__HIDX__) __CONDITION__",

			// mod_vistas_lista.php
			// Listar todas las vistas disponibles (usuario no administrador)
			'vistas_noadmin'=>"SELECT DISTINCT a.id_cfg_view, a.name, a.type, a.red, a.orange, a.yellow, a.blue, a.nmetrics, a.nsubviews, a.nremote, a.itil_type,a.severity,a.ruled,c.descr as cnm_descr,c.hidx,a.global,a.live_metric,a.live_remote FROM cfg_views a, cfg_user2view b,cnm.cfg_cnms c WHERE a.cid=b.cid AND a.global IN (0,1) AND a.cid_ip=b.cid_ip AND a.id_cfg_view=b.id_cfg_view AND b.login_name='__LOGIN_NAME__' AND a.cid_ip=c.host_ip AND a.cid=c.cid AND a.cid_ip='__CID_IP__' AND a.cid='__CID__' __CONDITION__",

			// Listar todas las vistas globales disponibles (usuario no administrador)
			'vistas_global_noadmin'=>"SELECT DISTINCT a.id_cfg_view, a.name, a.type, a.red, a.orange, a.yellow, a.blue, a.itil_type,a.severity,a.ruled,c.descr as cnm_descr,c.hidx,a.global,a.nmetrics,a.nremote,a.nsubviews,a.global FROM cfg_views a, cfg_user2view b,cnm.cfg_cnms c WHERE a.cid=b.cid AND a.cid_ip=b.cid_ip AND a.id_cfg_view=b.id_cfg_view AND b.login_name='__LOGIN_NAME__' AND b.cid_ip=c.host_ip AND b.cid=c.cid AND a.global IN (1,2) AND c.hidx IN (__HIDX__) __CONDITION__",
         // mod_vistas_lista.php
         // Contar las subvistas que contiene la vista dada
         'count_subviews_in_view'=>"SELECT count(*) AS cuantos FROM cfg_views2views WHERE id_cfg_view IN (__ID_CFG_VIEW__)",
			// mod_vistas_detalle.php
         // Listar la informacion de una vista
         'vista_info'=>"SELECT * FROM cfg_views WHERE id_cfg_view IN (__ID_CFG_VIEW__)",
         'global_vista_info'=>"SELECT a.*,b.hidx FROM cfg_views a,cnm.cfg_cnms b WHERE a.cid=b.cid AND a.cid_ip=b.host_ip AND a.id_cfg_view IN (__ID_CFG_VIEW__) AND a.cid='__CID__' AND a.cid_ip='__CID_IP__'",
			'update_view_background'=>"UPDATE cfg_views SET background='__BACKGROUND__' WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND cid='__CID__' AND cid_ip='__CID_IP__'",
			// mod_vistas_metricas.php
         // Listar todos los dispositivos
         'all_devices'=>"SELECT * FROM devices",
         // mod_vistas_metricas.php
         // Listar todos los dispositivos alarmados
         'devices_alarmed_view'=>"SELECT a.id_device FROM cfg_views2metrics a, alerts b WHERE a.id_metric=b.id_metric AND a.id_cfg_view IN (__ID_CFG_VIEW__)",
         // mod_vistas_metricas.php
         // Listar las metricas alarmadas de una vista
         'metrics_alarmed_view'=>"SELECT a.id_metric FROM cfg_views2metrics a, alerts b WHERE a.id_metric=b.id_metric AND a.id_cfg_view IN (__ID_CFG_VIEW__)",
         // mod_vistas_metricas.php
         // Listar las metricas de un dispositivo
         'metrics_device'=>"SELECT * FROM metrics WHERE id_dev IN ('__ID_DEV__')",
         // mod_vistas_metricas.php
         // Listar las metricas de una vista
         'metrics_view'=>"SELECT id_metric FROM cfg_views2metrics WHERE id_cfg_view IN ('__ID_CFG_VIEW__') AND id_device IN ('__ID_DEV__')",
         // mod_vistas_detalle.php
         // Tipos de vistas disponibles diferentes al tipo de la vista
         'view_types_not_view'=>"SELECT DISTINCT type FROM cfg_views WHERE type NOT IN (SELECT type FROM cfg_views WHERE id_cfg_view in (__ID_CFG_VIEW__)) ORDER BY type",
         // mod_vistas_detalle.php
         // El tipo itil de la vista
         'view_itil_view'=>"SELECT itil_type FROM cfg_views WHERE id_cfg_view IN (__ID_CFG_VIEW__)",

         // mod_vistas_detalle.php
         // Usuarios a los que esta asociada una vista
         'view2user'=>"SELECT id_user FROM cfg_user2view WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND cid='__CID__' AND cid_ip='__CID_IP__'",
         'report2user'=>"SELECT id_user FROM cfg_user2report WHERE id_cfg_report IN (__ID_CFG_REPORT__)",
			'clear_report2user'=>"DELETE FROM cfg_user2report WHERE id_cfg_report IN (__ID_CFG_REPORT__)",
			'add_report2user'=>"INSERT INTO cfg_user2report (id_user,id_cfg_report) VALUES ('__ID_USER__','__ID_CFG_REPORT__')",
         // mod_vistas_detalle.php
         // Todos los usuarios del sistema
         'all_user'=>"SELECT * from cfg_users",
         // mod_vistas_detalle.php
         // Tipo de la vista
         'view_types_view'=>"SELECT DISTINCT type FROM cfg_views WHERE id_cfg_view IN (__ID_CFG_VIEW__) ORDER BY type",
			// mod_vistas_detalle.php
         // Modificar una vista
         'update_view'=>"UPDATE cfg_views SET name='__NAME__',type='__TYPE__',itil_type='__ITIL__',ruled=__RULED__,global=__GLOBAL__,internal=__INTERNAL__,live_metric=__LIVE_METRIC__,live_remote=__LIVE_REMOTE__,sla=__SLA__,sla_red_typea='__SLA_RED_TYPEA__',sla_orange_typea='__SLA_ORANGE_TYPEA__',sla_yellow_typea='__SLA_YELLOW_TYPEA__',sla_red_typeb='__SLA_RED_TYPEB__',sla_orange_typeb='__SLA_ORANGE_TYPEB__',sla_yellow_typeb='__SLA_YELLOW_TYPEB__',sla_red_typec='__SLA_RED_TYPEC__',sla_orange_typec='__SLA_ORANGE_TYPEC__',sla_yellow_typec='__SLA_YELLOW_TYPEC__',subtype_cfg_report_typea='__SUBTYPE_CFG_REPORT_TYPEA__',subtype_cfg_report_typeb='__SUBTYPE_CFG_REPORT_TYPEB__',subtype_cfg_report_typec='__SUBTYPE_CFG_REPORT_TYPEC__',label_report_typea='__LABEL_REPORT_TYPEA__',label_report_typeb='__LABEL_REPORT_TYPEB__',label_report_typec='__LABEL_REPORT_TYPEC__' WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND cid='__CID__' AND cid_ip='__CID_IP__'",
         // mod_vistas_detalle.php
         // Asociar usuarios a una vista
         'asoc_user'=>"INSERT IGNORE INTO cfg_user2view (id_cfg_view,id_user,cid,cid_ip,login_name) VALUES ('__ID_CFG_VIEW__','__ID_USER__','__CID__','__CID_IP__',(SELECT login_name FROM cfg_users WHERE id_user=__ID_USER__))",
			// mod_vistas_detalle.php
         // Desasociar usuarios a una vista
         'unasoc_user'=>"DELETE FROM cfg_user2view WHERE id_cfg_view='__ID_CFG_VIEW__' AND cid='__CID__' AND cid_ip='__CID_IP__' AND id_user IN (__ID_USER__)",
			'unasoc_all_user' =>"DELETE FROM cfg_user2view WHERE id_cfg_view='__ID_CFG_VIEW__' AND cid='__CID__' AND cid_ip='__CID_IP__'",
         // mod_vistas_detalle.php
         // Crear una vista
         'create_view'=>"INSERT INTO cfg_views (name,type,itil_type,ruled,global,cid,cid_ip,internal,live_metric,live_remote,sla,sla_red_typea,sla_orange_typea,sla_yellow_typea,sla_red_typeb,sla_orange_typeb,sla_yellow_typeb,sla_red_typec,sla_orange_typec,sla_yellow_typec,subtype_cfg_report_typea,subtype_cfg_report_typeb,subtype_cfg_report_typec,label_report_typea,label_report_typeb,label_report_typec) VALUES ('__NAME__','__TYPE__','__ITIL__',__RULED__,__GLOBAL__,'__CID__','__CID_IP__',__INTERNAL__,__LIVE_METRIC__,__LIVE_REMOTE__,__SLA__,'__SLA_RED_TYPEA__','__SLA_ORANGE_TYPEA__','__SLA_YELLOW_TYPEA__','__SLA_RED_TYPEB__','__SLA_ORANGE_TYPEB__','__SLA_YELLOW_TYPEB__','__SLA_RED_TYPEC__','__SLA_ORANGE_TYPEC__','__SLA_YELLOW_TYPEC__','__SUBTYPE_CFG_REPORT_TYPEA__','__SUBTYPE_CFG_REPORT_TYPEB__','__SUBTYPE_CFG_REPORT_TYPEC__','__LABEL_REPORT_TYPEA__','__LABEL_REPORT_TYPEB__','__LABEL_REPORT_TYPEC__')",
			// mod_vistas_detalle.php
			// Obtener el id_cfg_view de la vista creada
			'get_id_cfg_view'=>"select id_cfg_view from cfg_views order by id_cfg_view desc limit 1",
         // mod_vistas_metricas.php
         'count_metrics_device'=>"SELECT count(DISTINCT id_metric) as cuantos FROM metrics WHERE id_dev IN (__ID_DEVICE__)",
			// mod_vistas_metricas.php
			'metricas_vista_devices'=>"SELECT count(DISTINCT id_metric) as cuantos FROM cfg_views2metrics WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND id_device IN (__ID_DEVICE__)",
			// mod_vistas_metricas.php
			'vista_asociar_metrica'=>"INSERT INTO cfg_views2metrics (id_cfg_view,id_metric,id_device) VALUES ('__ID_CFG_VIEW__','__ID_METRIC__',(SELECT id_dev FROM metrics WHERE id_metric='__ID_METRIC__'))",
         // mod_vistas_metricas.php
         'vista_desasociar_metrica'=>"DELETE FROM cfg_views2metrics WHERE id_cfg_view='__ID_CFG_VIEW__' AND id_metric='__ID_METRIC__'",
         // mod_vistas_subvistas.php
         // Listar todas las subvistas de una vista
/*
mysql> desc cfg_views2views;
+----------------+-------------+------+-----+---------+-------+
| Field          | Type        | Null | Key | Default | Extra |
+----------------+-------------+------+-----+---------+-------+
| id_cfg_view    | int(11)     | NO   | PRI | 0       |       |
| id_cfg_subview | int(11)     | NO   | PRI | 0       |       |
| graph          | bigint(20)  | YES  |     | NULL    |       |
| size           | varchar(20) | NO   |     | 350x100 |       |
+----------------+-------------+------+-----+---------+-------+

*/
			'subvistas_de_vista'=>"SELECT id_cfg_subview FROM cfg_views2views WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND cid_view='__CID__' AND cid_subview='__CID__' AND cid_ip_view='__CID_IP__' AND cid_ip_subview='__CID_IP__'",
			'subvistas_de_vistas_admin'=>"SELECT id_cfg_subview,id_cfg_view FROM cfg_views2views WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND cid_view='__CID__' AND cid_subview='__CID__' AND cid_ip_view='__CID_IP__' AND cid_ip_subview='__CID_IP__'",

			'subvistas_de_vistas_noadmin'=>"SELECT a.id_cfg_subview,a.id_cfg_view FROM cfg_views2views a, cfg_user2view b WHERE a.cid_view=b.cid AND a.cid_ip_view=b.cid_ip AND a.id_cfg_view=b.id_cfg_view AND a.id_cfg_view=b.id_cfg_view AND b.cid_ip='__CID_IP__' AND b.cid='__CID__' AND b.id_user IN (__ID_USER__) AND b.id_cfg_view IN (__ID_CFG_VIEW__)",

			// 'list_subviews_no_admin'=>"SELECT a.id_cfg_subview,a.id_cfg_view FROM cfg_views2views a, cfg_user2view b WHERE a.cid_view=b.cid AND a.cid_ip_view=b.cid_ip AND a.id_cfg_subview=b.id_cfg_view AND a.cid_subview=b.cid AND a.cid_ip_subview=b.cid_ip AND b.cid_ip='__CID_IP__' AND b.cid='__CID__' AND b.id_user IN (__ID_USER__)",



	//'list_subviews_no_admin'=>"SELECT DISTINCT a.id_cfg_subview FROM cfg_views2views a, cfg_user2view b WHERE a.cid_view=b.cid AND a.cid_ip_view=b.cid_ip AND a.id_cfg_view=b.id_cfg_view AND a.id_cfg_view=b.id_cfg_view AND b.cid_ip='__CID_IP__' AND b.cid='__CID__' AND b.id_user IN (__ID_USER__)",

			'global_subvistas_de_vista'=>"SELECT a.id_cfg_subview,a.cid_subview,a.cid_ip_subview,a.graph,a.size,b.hidx FROM cfg_views2views a,cnm.cfg_cnms b WHERE a.id_cfg_view IN (__ID_CFG_VIEW__) AND a.cid_view='__CID__' AND a.cid_ip_view='__CID_IP__' AND a.cid_subview=b.cid AND a.cid_ip_subview=b.host_ip",

         'global_subvistas_de_vista_delete_temp'=>"DROP table t1,t2",
			'global_subvistas_de_vista_create_temp1'=>"CREATE TEMPORARY TABLE t2 (SELECT id_cfg_subview,cid_subview,cid_ip_subview FROM cfg_views2views WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND cid_view='__CID__' AND cid_ip_view='__CID_IP__')",
			'global_subvistas_de_vista_create_temp2'=>"CREATE TEMPORARY TABLE t1 (SELECT b.hidx, b.descr as cnm_desc, c.name, c.id_cfg_view, c.global FROM t2 a,cnm.cfg_cnms b, cfg_views c WHERE a.id_cfg_subview=c.id_cfg_view AND a.cid_subview=b.cid AND a.cid_ip_subview=b.host_ip AND b.cid=c.cid AND b.host_ip=c.cid_ip)",
         'global_subvistas_de_vista_select'=> "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'global_subvistas_de_vista_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",


         // mod_vistas_subvistas.php
         // Listar todas las vistas a las que pertenece una subvista
         'parentvistas_de_vista'=>"SELECT id_cfg_view FROM cfg_views2views WHERE id_cfg_subview IN (__ID_CFG_SUBVIEW__)",
         'global_parentvistas_de_vista'=>"SELECT id_cfg_view,cid_view,cid_ip_view FROM cfg_views2views WHERE id_cfg_subview IN (__ID_CFG_SUBVIEW__) AND cid_subview='__CID__' AND cid_ip_subview='__CID_IP__'",

			'global_subvistas_admin'=>"SELECT DISTINCT a.id_cfg_view, a.name, a.type,a.red,a.orange,a.yellow,a.cid_ip,a.cid,b.hidx,b.descr AS cnm_descr FROM cfg_views a, cnm.cfg_cnms b WHERE a.id_cfg_view NOT IN (__ID_CFG_VIEW__) AND a.cid_ip=b.host_ip AND a.cid=b.cid AND a.global IN (1,2)",
			'global_count_subvistas_admin'=>"SELECT COUNT(DISTINCT(id_cfg_subview)) AS cuantos FROM cfg_views2views a, cfg_user2view b, cfg_views c WHERE a.id_cfg_view=b.id_cfg_view AND a.id_cfg_view=c.id_cfg_view AND a.cid_view=b.cid AND a.cid_view=c.cid AND a.cid_ip_view=b.cid_ip AND a.cid_ip_view=c.cid_ip AND c.global IN (1,2) AND a.id_cfg_view IN (__ID_CFG_VIEW__) AND a.cid_view='__CID__' AND a.cid_ip_view='__CID_IP__'",
			'global_count_subvistas'=>"SELECT COUNT(DISTINCT(id_cfg_subview)) AS cuantos FROM cfg_views2views a, cfg_views c WHERE a.id_cfg_view=c.id_cfg_view AND a.cid_view=c.cid AND a.cid_ip_view=c.cid_ip AND c.global IN (1,2) AND a.id_cfg_view IN (__ID_CFG_VIEW__) AND a.cid_view='__CID__' AND a.cid_ip_view='__CID_IP__'",
			'global_update_count_subvistas'=>"UPDATE cfg_views SET nsubviews=__NSUBVIEWS__ WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND cid='__CID__' AND cid_ip='__CID_IP__'",
			'global_subvistas_noadmin'=>"SELECT DISTINCT a.id_cfg_view,a.name,a.type,a.red,a.orange,a.yellow,a.cid_ip,a.cid,c.hidx,c.descr AS cnm_descr FROM cfg_views a, cfg_user2view b, cnm.cfg_cnms c WHERE a.id_cfg_view=b.id_cfg_view AND b.login_name='__LOGIN_NAME__' AND a.id_cfg_view NOT IN (__ID_CFG_VIEW__) AND a.cid_ip=c.host_ip AND a.cid=c.cid AND a.global IN (1,2)",
			'global_count_subvistas_noadmin'=>"SELECT COUNT(DISTINCT(id_cfg_subview)) AS cuantos FROM cfg_views2views a, cfg_user2view b, cfg_views c WHERE a.id_cfg_view=b.id_cfg_view AND a.id_cfg_view=c.id_cfg_view AND a.cid_view=b.cid AND a.cid_view=c.cid AND a.cid_ip_view=b.cid_ip AND a.cid_ip_view=c.cid_ip AND c.global IN (1,2) AND a.id_cfg_view IN (__ID_CFG_VIEW__) AND a.login_name='__LOGIN_NAME__' AND a.cid_view='__CID__' AND a.cid_ip_view='__CID_IP__'",


			// mod_vistas_subvistas.php
         // Listar todas las subvistas disponibles (administrador)
         'subvistas_admin'=>"SELECT DISTINCT a.id_cfg_view, a.name, a.type,a.red,a.orange,a.yellow,a.cid_ip,a.cid,b.hidx,b.descr AS cnm_descr FROM cfg_views a, cnm.cfg_cnms b WHERE a.id_cfg_view NOT IN (__ID_CFG_VIEW__) AND a.cid_ip=b.host_ip AND a.cid=b.cid AND a.cid='__CID__' AND a.cid_ip='__CID_IP__'",
         // mod_vistas_lista.php
         // Listar todas las subvistas disponibles (usuario no administrador)
         'subvistas_noadmin'=>"SELECT DISTINCT a.id_cfg_view,a.name,a.type,a.red,a.orange,a.yellow,a.cid_ip,a.cid,c.hidx,c.descr AS cnm_descr FROM cfg_views a, cfg_user2view b, cnm.cfg_cnms c WHERE a.id_cfg_view=b.id_cfg_view AND b.login_name='__LOGIN_NAME__' AND a.id_cfg_view NOT IN (__ID_CFG_VIEW__) AND a.cid_ip=c.host_ip AND a.cid=c.cid AND a.cid='__CID__' AND a.cid_ip='__CID_IP__'",
         // mod_vistas_subvistas.php
			'vista_asociar_subvista'=>"INSERT INTO cfg_views2views (id_cfg_view,id_cfg_subview,cid_view,cid_ip_view,cid_subview,cid_ip_subview) VALUES ('__ID_CFG_VIEW__','__ID_CFG_SUBVIEW__','__CID__','__CID_IP__','__CID__','__CID_IP__')",
			'global_vista_asociar_subvista'=>"INSERT INTO cfg_views2views (id_cfg_view,id_cfg_subview,cid_view,cid_ip_view,cid_subview,cid_ip_subview) VALUES ('__ID_CFG_VIEW__','__ID_CFG_SUBVIEW__','__CID__','__CID_IP__','__CID_SUBVIEW__','__CID_IP_SUBVIEW__')",
         // mod_vistas_subvistas.php
			'vista_desasociar_subvista'=>"DELETE FROM cfg_views2views WHERE id_cfg_view='__ID_CFG_VIEW__' AND id_cfg_subview='__ID_CFG_SUBVIEW__' AND cid_view='__CID__' AND cid_subview='__CID__' AND cid_ip_view='__CID_IP__' AND cid_ip_subview='__CID_IP__'",
			'global_vista_desasociar_subvista'=>"DELETE FROM cfg_views2views WHERE id_cfg_view=__ID_CFG_VIEW__ AND id_cfg_subview=__ID_CFG_SUBVIEW__ AND cid_view='__CID__' AND cid_ip_view='__CID_IP__' AND cid_subview='__CID_SUBVIEW__' AND cid_ip_subview='__CID_IP_SUBVIEW__'",
			// mod_vistas_alertas_remotas.php
			// 'alertas_remotas_vista_devices'=>"SELECT count(DISTINCT a.id_remote_alert) as cuantos FROM cfg_remote_alerts2device a,devices b WHERE a.target=b.ip AND b.id_dev IN (__ID_DEV__)",
			'alertas_remotas_vista_devices'=>"SELECT count(DISTINCT id_remote_alert) as cuantos FROM cfg_views2remote_alerts WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND id_dev IN (__ID_DEV__)",
         // mod_vistas_alertas_remotas.php
         // Listar las alertas remotas de una vista
         'remote_alerts_view'=>"SELECT id_remote_alert FROM cfg_views2remote_alerts WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND id_dev IN (__ID_DEV__)",
         // mod_vistas_alertas_remotas.php
         // Listar las alertas remotas de un dispositivo
         'remote_alerts_device'=>"SELECT d.*,b.status as dstatus,b.domain,b.ip,b.type as dtype__USER_FIELDS__ FROM (cfg_remote_alerts2device a,devices b,cfg_remote_alerts d) LEFT JOIN devices_custom_data c ON b.id_dev=c.id_dev WHERE a.target=b.ip AND a.id_remote_alert=d.id_remote_alert AND b.id_dev IN (__ID_DEV__)",
         // 'remote_alerts_device'=>"SELECT c.* FROM cfg_remote_alerts2device a,devices b,cfg_remote_alerts c WHERE a.target=b.ip AND b.id_dev IN (__ID_DEV__) AND a.id_remote_alert=c.id_remote_alert",
//'metrics_device_views'=>"SELECT a.id_metric,a.label,a.type as mtype,b.status as dstatus,b.domain,b.ip,b.type as dtype__USER_FIELDS__ FROM metrics a,devices b LEFT JOIN devices_custom_data c ON b.id_dev=c.id_dev WHERE a.id_dev=b.id_dev AND b.id_dev IN (__ID_DEV__)",
         // mod_vistas_alertas_remotas.php
         // Contar las alertas remotas de un dispositivo
         'count_remote_alerts_device'=>"SELECT count(c.id_remote_alert) as cuantos FROM cfg_remote_alerts2device a,devices b,cfg_remote_alerts c WHERE a.target=b.ip AND b.id_dev IN (__ID_DEV__) AND a.id_remote_alert=c.id_remote_alert",
			'all_count_remote_alerts_device'=>"SELECT id_remote_alert, count(target) AS cuantos FROM cfg_remote_alerts2device GROUP BY id_remote_alert",
         // mod_vistas_alertas_remotas.php
         'vista_asociar_alerta_remota'=>"INSERT INTO cfg_views2remote_alerts (id_cfg_view,id_remote_alert,id_dev) VALUES ('__ID_CFG_VIEW__','__ID_REMOTE_ALERT__','__ID_DEV__')",
         // mod_vistas_alertas_remotas.php
         'vista_desasociar_alerta_remota'=>"DELETE FROM cfg_views2remote_alerts WHERE id_cfg_view='__ID_CFG_VIEW__' AND id_remote_alert='__ID_REMOTE_ALERT__' AND id_dev='__ID_DEV__'",
         // Borrar una entrada de la documentacion a partir de su id_tip
         // mod_vistas_documentacion.php
         'delete_tip'=>"DELETE FROM tips WHERE id_tip IN (__ID_TIP__)",
         // Insertar una entrada en la documentacion
         // mod_vistas_documentacion.php
         'insert_tip'=>"INSERT INTO tips (descr,id_ref,tip_type,date,name) VALUES ('__DESCR__','__ID_REF__','__TIP_TYPE__',__DATE__,'__NAME__')",
			'duplicate_tip'=>"INSERT INTO tips (descr,id_ref,tip_type,date,name,tip_class) (SELECT descr,'__NEW_ID_REF__' AS id_ref,tip_type,__DATE__,name,tip_class FROM tips WHERE id_ref='__ID_REF__' AND tip_class=1)",
			'insert_tip_system'=>"INSERT INTO tips (descr,id_ref,tip_type,date,name,tip_class) VALUES ('__DESCR__','__ID_REF__','__TIP_TYPE__','__DATE__','__NAME__',1) ON DUPLICATE KEY UPDATE descr='__DESCR__'",

         // Actualizar una entrada de la documentacion
         // mod_vistas_documentacion.php
         'edit_tip'=>"UPDATE tips SET descr='__DESCR__',date=__DATE__,name='__NAME__' WHERE id_tip=__ID_TIP__",






 /**
	* **************************************************************** *
	* Modulo: mod_alertas.sql
	* **************************************************************** *
	*/


         // ---------------------------------------------------------------------------------------
         // Todas las alertas activas en el sistema CNM
			// mod_alertas_lista.php
			// 'cnm_data_alerts_get_all'=>"SELECT a.ack,b.name,b.domain,b.ip,b.status,a.id_alert,a.severity,from_unixtime(a.date) as date,a.counter,a.type,a.label,a.event_data,a.id_ticket FROM alerts a,devices b WHERE a.id_device=b.id_dev AND b.status=0 AND a.counter>0 __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
			'cnm_data_alerts_get_all'=>"SELECT a.ack,b.name,b.domain,b.ip,b.status,a.id_alert,a.severity,from_unixtime(a.date) as date,a.counter,a.type,a.label,a.event_data,ifnull(c.id_ticket,0) as id_ticket FROM (alerts a,devices b) LEFT JOIN ticket c ON a.id_alert=c.id_alert WHERE a.id_device=b.id_dev AND b.status=0 AND a.counter>0 __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
			'cnm_data_alerts_get_all_count'=>"SELECT COUNT(DISTINCT a.id_alert) AS cuantos FROM alerts a,devices b WHERE a.id_device=b.id_dev AND b.status=0  __CONDITION__ ",
         // id_device de una alerta activa
         // mod_alertas_layout.php
         'alert_info'=>"SELECT a.id_device,a.id_metric,a.ack,a.id_alert_type,a.type,a.subtype,a.mname,a.label,a.event_data,a.cause,a.severity,a.counter,from_unixtime(a.date) AS date,a.date as date_unixtime,a.name,a.domain,a.ip,IFNULL(b.ref,'') AS ref,a.id_alert,a.id_ticket,a.bdata FROM alerts a LEFT JOIN ticket b ON a.id_alert=b.id_alert WHERE a.id_alert IN (__ID_ALERT__)",
			// mod_alertas_lista.php
			'alerta_quitar_ack'=>"UPDATE alerts SET ack=0 WHERE id_alert IN (__ID_ALERT__)",
			'alerta_poner_ack'=>"UPDATE alerts SET ack=1 WHERE id_alert IN (__ID_ALERT__)",
			'alerta_ack'=>"UPDATE alerts SET ack=__ACK__ WHERE id_alert IN (__ID_ALERT__) AND cid='__CID__' AND cid_ip='__CID_IP__'",
			'alerts_read_ack'=>"UPDATE alerts_read SET ack=__ACK__ WHERE id_alert IN (__ID_ALERT__) AND cid='__CID__' AND cid_ip='__CID_IP__'",
			'halerta_ack'=>"UPDATE alerts_store SET ack=__ACK__ WHERE id_alert IN (__ID_ALERT__)",

			'insert_alert_into_alerts_store'=>"INSERT INTO alerts_store (id_alert,id_device,id_alert_type,watch,severity,date,ack,counter,event_data,notif,mname,id_store,date_store,duration,id_ticket,type,label,id_metric,subtype,cid,cid_ip,name,domain,ip,cause,critic,date_last) (SELECT id_alert,id_device,id_alert_type,watch,severity,date,ack,counter,event_data,notif,mname,10,unix_timestamp(NOW()),unix_timestamp(NOW())-date,id_ticket,type,label,id_metric,subtype,cid,cid_ip,name,domain,ip,cause,critic,date_last FROM alerts WHERE id_alert IN (__ID_ALERT__))",

			'delete_alert'=>"DELETE FROM alerts WHERE id_alert IN (__ID_ALERT__)",

			// mod_alertas_lista.php
			// Poner dispositivos en mantenimiento dado el id_alert en alerts
			'mantenimiento_dispositivo'=>"UPDATE devices SET status=2 WHERE id_dev IN (SELECT id_device FROM alerts WHERE id_alert IN(__ID_ALERT__))",
         // mod_alertas_lista.php
         // Dar de baja dispositivos dado el id_alert en alerts
         'baja_dispositivo'=>"UPDATE devices SET status=1 WHERE id_dev IN (SELECT id_device FROM alerts WHERE id_alert IN(__ID_ALERT__))",
			'metric_validate'=>"SELECT a.ip,b.type,b.name,a.domain AS device_domain,a.name AS device_name FROM devices a,metrics b WHERE a.id_dev=b.id_dev AND b.id_metric IN (__ID_METRIC__)",
			'metric_info'=>"SELECT * FROM metrics WHERE name='__MNAME__' AND id_dev IN (__ID_DEV__)",
			//'doc_metricas_alerta'=>"SELECT id_tip,name,descr,url,from_unixtime(date) as date FROM tips WHERE (id_ref='__MNAME__' or id_ref='__ID_REF__') AND tip_type!='id_dev' ORDER BY name",
			'doc_metricas_alerta'=>"SELECT id_tip,name,descr,url,from_unixtime(date) as date FROM tips WHERE (id_ref='__MNAME__' or id_ref='__ID_REF__') AND tip_type in ('latency','agent','wbem','cfg') ORDER BY name",
			'doc_remote_alerta'=>"SELECT id_tip,name,descr,url,from_unixtime(date) as date FROM tips WHERE (id_ref='__MNAME__' or id_ref='__ID_REF__') AND tip_type in ('remote') ORDER BY name",
			'doc_dispositivo_alerta'=>"SELECT id_tip,name,descr,url,from_unixtime(date) as date FROM tips WHERE (tip_type='id_dev' and id_ref=__ID_REF__)",
			'doc_monitor'=>"SELECT id_tip,name,descr,url,from_unixtime(date) as date FROM tips WHERE (tip_type='id_alert_type' and id_ref=__ID_REF__)",
			'doc_script'=>"SELECT id_tip,name,descr,url,from_unixtime(date) as date FROM tips WHERE (tip_type='script' and id_ref='__ID_REF__')",
			'doc_app'=>"SELECT id_tip,name,descr,url,from_unixtime(date) as date FROM tips WHERE (tip_type='app' and id_ref='__ID_REF__')",
			'info_device'=>"SELECT * FROM devices WHERE id_dev IN (__ID_DEV__)",
			'cnm_data_devices_get_info_by_id'=>"SELECT name,domain,ip,sysloc,sysdesc,sysoid,type,status,mode,community,version,wbem_user,wbem_pwd,background,xagent_version,enterprise FROM devices WHERE id_dev IN (__ID_DEV__)",


			'note_types'=>"SELECT name,id_note_type FROM note_types",
			'create_ticket_types'=>"INSERT INTO note_types (name) VALUES ('__NAME__')",
			'mod_ticket_types'=>"UPDATE note_types SET name='__NAME__' WHERE id_note_type IN (__ID_NOTE_TYPE__)",
			'del_ticket_types'=>"DELETE FROM note_types WHERE id_note_type IN (__ID_NOTE_TYPE__)",
			'doc_ticket_dispositivo'=>"SELECT distinct descr,from_unixtime(date_store) as date,ticket_type,id_alert,event_data,ref FROM ticket WHERE id_dev=__ID_DEV__ and ticket_type<>0 ORDER BY date_store",
			'info_ticket'=>"SELECT a.id_ticket,a.id_dev,a.id_alert,a.ticket_type,a.id_problem,a.descr,a.ref,a.date_store,a.event_data,a.login_name,from_unixtime(a.date_store) as date_str, b.name AS cat_name FROM ticket a, note_types b WHERE a.id_alert=__ID_ALERT__ AND a.ticket_type=b.id_note_type",
			'all_ticket_type'=>"select id_note_type,name from note_types",
			// 'modify_ticket'=>"INSERT INTO ticket (id_dev,event_data,id_alert,ticket_type,descr,ref,id_problem) VALUES (__ID_DEV__,'__EVENT_DATA__',__ID_ALERT__,__TICKET_TYPE__,'__DESCR__','__REF__',0) ON DUPLICATE KEY UPDATE ticket_type=__TICKET_TYPE__,descr='__DESCR__',ref='__REF__'",
			'modify_ticket'=>"UPDATE ticket set ticket_type=__TICKET_TYPE__,descr='__DESCR__',ref='__REF__' WHERE id_ticket=__ID_TICKET__",
			'create_ticket'=>"INSERT INTO ticket (id_dev,event_data,id_alert,ticket_type,descr,ref,date_store,id_problem,login_name) VALUES (__ID_DEV__,'__EVENT_DATA__',__ID_ALERT__,__TICKET_TYPE__,'__DESCR__','__REF__',unix_timestamp(NOW()),0,'__LOGIN_NAME__')",
			'modify_ticket2'=>"UPDATE alerts set id_ticket=__ID_TICKET__,id_note_type=__ID_NOTE_TYPE__,ticket_descr='__TICKET_DESCR__'  WHERE id_alert=__ID_ALERT__",
			'modify_ticket3'=>"UPDATE alerts_read set id_ticket=__ID_TICKET__,ticket_descr='__TICKET_DESCR__' WHERE id_alert=__ID_ALERT__ AND cid='__CID__' AND cid_ip='__CID_IP__'",
			'modify_ticket_history'=>"UPDATE alerts_store set id_ticket=__ID_TICKET__,id_note_type=__ID_NOTE_TYPE__ WHERE id_alert=__ID_ALERT__",
			'get_tickets_from_alerts'=>"SELECT  a.id_alert,a.id_ticket,t.descr,from_unixtime(t.date_store) as date_str,t.login_name,n.name FROM alerts a, ticket t, note_types n WHERE a.id_ticket=t.id_ticket and n.id_note_type=t.ticket_type",
			'get_tickets_from_halerts'=>"SELECT  a.id_alert,a.id_ticket,t.descr,from_unixtime(t.date_store) as date_str,t.login_name,n.name FROM alerts_store a, ticket t, note_types n WHERE a.id_ticket=t.id_ticket and n.id_note_type=t.ticket_type",
			// mod_alertas_layout.php
			// Se comprueba si existe la tabla extra_sc_level y si está abre la ventana de ticket con service cente
			'check_service_center'=>"SELECT * FROM extra_sc_level",



 /**
	* **************************************************************** *
	* Modulo: mod_halerts.sql
	* **************************************************************** *
	*/


         // ---------------------------------------------------------------------------------------
         // Todas las alertas del historico del sistema CNM
			// mod_alertas_lista.php
			'cnm_data_halerts_get_all'=>"SELECT b.name,b.domain,b.ip,b.status,a.id_alert,a.severity,from_unixtime(a.date) as date,a.counter,a.type,a.label,a.event_data,a.id_ticket FROM alerts_store a,devices b WHERE a.id_device=b.id_dev __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
			'cnm_data_halerts_get_all_count'=>"SELECT COUNT(DISTINCT a.id_alert) AS cuantos FROM alerts_store a,devices b WHERE a.id_device=b.id_dev  __CONDITION__ ",
			// id_device de una alerta del historico
			// mod_halertas_layout.php
			'halert_info'=>"SELECT a.id_device,a.id_metric,a.id_alert_type,a.type,a.subtype,a.mname,a.counter,a.duration,a.label,a.event_data,a.date as date_timestamp,from_unixtime(a.date) AS date,from_unixtime(a.date_store) AS date_end,a.date_store,a.severity,IFNULL(b.ref,'') AS ref,a.id_alert,a.id_ticket,a.ip,a.name,a.domain,a.bdata FROM alerts_store a LEFT JOIN ticket b ON a.id_alert=b.id_alert WHERE a.id_alert IN (__ID_ALERT__)",
			// Borrar alertas de alerts_store
			// mod_halertas_lista.php
			'delete_halert'=>"DELETE FROM alerts_store WHERE id_alert IN (__ID_ALERT__)",
         //'doc_metricas_alerta'=>"SELECT id_tip,name,descr,url,from_unixtime(date) as date FROM tips WHERE (id_ref='__MNAME__' or id_ref='__ID_REF__') AND tip_type!='id_dev' ORDER BY name",



 /**
	* **************************************************************** *
	* Modulo: mod_heventos.sql
	* **************************************************************** *
	*/


         // ---------------------------------------------------------------------------------------
         // Todas los eventos almacenados en el sistema CNM
			// mod_heventos_lista.php
			'cnm_get_events_layout_delete_temp'	=> "DROP TEMPORARY TABLE t1",
			'cnm_get_events_layout_create_temp_user' => "CREATE TEMPORARY TABLE t1 SELECT a.id_event,a.name,a.domain,a.ip,a.code,a.proccess,a.msg,a.evkey,from_unixtime(a.date) AS date_str,a.date,a.msg_custom FROM events a,cfg_devices2organizational_profile b WHERE a.id_dev=b.id_dev AND b.id_cfg_op IN (__ID_CFG_OP__) AND b.cid='__CID__'",
			'cnm_get_events_layout_create_temp_admin' => "CREATE TEMPORARY TABLE t1 SELECT a.id_event,a.name,a.domain,a.ip,a.code,a.proccess,a.msg,a.evkey,from_unixtime(a.date) AS date_str,a.date,a.msg_custom FROM events a",
         'cnm_get_events_layout_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_get_events_layout_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
			'cnm_delete_events_by_condition' => "DELETE FROM events WHERE ''='' __CONDITION__",


			'all_events'=>"SELECT DISTINCT a.id_event,a.name,a.domain,a.ip,a.code,a.proccess,a.msg,a.evkey,from_unixtime(a.date) AS date,a.msg_custom FROM events a WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
			'all_events_count'=>"SELECT COUNT(DISTINCT a.id_event) AS cuantos FROM events a WHERE ''='' __CONDITION__",

			'info_event'=>"SELECT id_event,proccess,evkey,msg_custom,msg,name,domain,ip,code,from_unixtime(date) AS date FROM events WHERE id_event IN (__ID_EVENT__)",
			'delete_event'=>"DELETE FROM events WHERE id_event IN (__ID_EVENT__)",
			'info_cfg_events_data'=>"SELECT txt_custom FROM cfg_events_data WHERE evkey='__EV_KEY__' AND process='__PROCCESS__'",
			'update_txt_custom'=>"INSERT INTO cfg_events_data (process,evkey,txt_custom) VALUES ('__PROCCESS__','__EVKEY__','__TXT_CUSTOM__') ON DUPLICATE KEY UPDATE txt_custom='__TXT_CUSTOM__' ",


 /**
	* **************************************************************** *
	* Modulo: mod_auditoria.sql
	* **************************************************************** *
	*/


         // ---------------------------------------------------------------------------------------
         // Todas los eventos almacenados en el sistema CNM
         // mod_heventos_lista.php
         'all_qactions'=>"SELECT DISTINCT id_qactions,from_unixtime(date_store) AS date_store,descr,auser,status,rc,rcstr,file FROM qactions WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'all_qactions_count'=>"SELECT COUNT(DISTINCT id_qactions) AS cuantos FROM qactions WHERE ''='' __CONDITION__",
			'delete_qactions'=>"DELETE FROM qactions WHERE id_qactions IN (__ID_QACTIONS__)",
			'cnm_delete_qactions_by_condition' => "DELETE FROM qactions WHERE ''='' __CONDITION__",
			'qactions_by_id'=>"SELECT * FROM qactions WHERE id_qactions IN (__ID_QACTIONS__)",


         // ---------------------------------------------------------------------------------------
			// Todas los eventos almacenados en el sistema CNM
			// mod_heventos_lista.php
			//'all_notifications'=>"(SELECT DISTINCT n.id_notif,d.name,d.domain,from_unixtime(n.date) as date ,t.name as type,c.destino as dest,n.rc,n.msg FROM notifications n, cfg_notifications c,alert_type a, devices d,notification_type t WHERE n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev and c.id_notification_type=t.id_notification_type __CONDITION__) UNION (SELECT DISTINCT n.id_notif,d.name,d.domain,from_unixtime(n.date) as date ,t.name as type,c.destino as dest,n.rc,n.msg FROM notifications n, cfg_notifications c,cfg_monitor a, devices d,notification_type t WHERE n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev and c.id_notification_type=t.id_notification_type __CONDITION__) UNION (SELECT DISTINCT n.id_notif,d.name,d.domain,from_unixtime(n.date) as date ,t.name as type,c.destino as dest,n.rc,n.msg FROM notifications n, cfg_notifications c,cfg_remote_alerts a, devices d,notification_type t WHERE n.id_cfg_notification=c.id_cfg_notification and a.subtype=c.monitor and n.id_dev=d.id_dev and c.id_notification_type=t.id_notification_type __CONDITION__) ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
			'all_notifications'=>"(SELECT DISTINCT n.id_notif,d.name,d.domain,from_unixtime(n.date) as date ,'-' as type,c.destino as dest,n.rc,n.msg FROM notifications n, cfg_notifications c,alert_type a, devices d WHERE n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev __CONDITION__) UNION (SELECT DISTINCT n.id_notif,d.name,d.domain,from_unixtime(n.date) as date ,'-' as type,c.destino as dest,n.rc,n.msg FROM notifications n, cfg_notifications c,cfg_monitor a, devices d WHERE n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev  __CONDITION__) UNION (SELECT DISTINCT n.id_notif,d.name,d.domain,from_unixtime(n.date) as date ,'-' as type,c.destino as dest,n.rc,n.msg FROM notifications n, cfg_notifications c,cfg_remote_alerts a, devices d WHERE n.id_cfg_notification=c.id_cfg_notification and a.subtype=c.monitor and n.id_dev=d.id_dev __CONDITION__) ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
			 //'all_notifications_count'=>"SELECT( (SELECT COUNT(DISTINCT n.id_notif) AS cuantos FROM notifications n, cfg_notifications c,alert_type a, devices d,notification_type t WHERE n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev and c.id_notification_type=t.id_notification_type __CONDITION__)+ (SELECT COUNT(DISTINCT n.id_notif) FROM notifications n, cfg_notifications c,cfg_monitor a, devices d,notification_type t WHERE n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev and c.id_notification_type=t.id_notification_type __CONDITION__)+ (SELECT COUNT(DISTINCT n.id_notif) FROM notifications n, cfg_notifications c,cfg_remote_alerts a, devices d,notification_type t WHERE n.id_cfg_notification=c.id_cfg_notification and a.subtype=c.monitor and n.id_dev=d.id_dev and c.id_notification_type=t.id_notification_type __CONDITION__))",
			 'all_notifications_count'=>"SELECT( (SELECT COUNT(DISTINCT n.id_notif) AS cuantos FROM notifications n, cfg_notifications c,alert_type a, devices d WHERE n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev __CONDITION__)+ (SELECT COUNT(DISTINCT n.id_notif) FROM notifications n, cfg_notifications c,cfg_monitor a, devices d WHERE n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev __CONDITION__)+ (SELECT COUNT(DISTINCT n.id_notif) FROM notifications n, cfg_notifications c,cfg_remote_alerts a, devices d WHERE n.id_cfg_notification=c.id_cfg_notification and a.subtype=c.monitor and n.id_dev=d.id_dev __CONDITION__))",


 /**
	* **************************************************************** *
	* Modulo: mod_avisos.sql
	* **************************************************************** *
	*/

// ---------------------------------------------------------------------------------------
// mod_avisos_lista.php
// ---------------------------------------------------------------------------------------

			// ---------------------------------------------------------------------------------------
			// Listado de avisos definidos
			'listado_avisos1'=>"DROP table temp1",

			'listado_avisos2'=>"CREATE table temp1 SELECT count(DISTINCT c.id_device) AS cta, id_cfg_notification FROM cfg_notification2device c, devices d, cfg_devices2organizational_profile o WHERE c.id_device=d.id_dev AND d.id_dev=o.id_dev AND o.id_cfg_op IN (__ORGPRO__) GROUP BY c.id_cfg_notification",
			'listado_avisos3'=>"
(SELECT a.id_cfg_notification, ifnull(cta,0) as cuantos, a.destino, a.name as aviso,b.cause FROM (cfg_notifications a, alert_type b) LEFT JOIN  temp1 on  a.id_cfg_notification=temp1.id_cfg_notification WHERE  a.monitor=b.monitor)

UNION
(SELECT a.id_cfg_notification, ifnull(cta,0) as cuantos, a.destino, a.name as aviso,b.description as cause  FROM (cfg_notifications a, cfg_monitor b)  LEFT JOIN  temp1 on  a.id_cfg_notification=temp1.id_cfg_notification  WHERE  a.monitor=b.monitor)
UNION
(SELECT a.id_cfg_notification, ifnull(cta,0) as cuantos, a.destino, a.name as aviso,b.descr as cause FROM (cfg_notifications a, cfg_remote_alerts b) LEFT JOIN  temp1 on  a.id_cfg_notification=temp1.id_cfg_notification WHERE  a.monitor=b.subtype)
",
         // ---------------------------------------------------------------------------------------
         // Borrar la asociacion entre dispositivo y aviso para el id_cfg_notification especificado
         'delete_devices_notification'=>"DELETE FROM cfg_notification2device WHERE id_cfg_notification IN (__ID_CFG_NOTIFICATION__)",
         // ---------------------------------------------------------------------------------------
         // Borrar los avisos especificados por su id_cfg_notification
         'delete_notification'=>"DELETE FROM cfg_notifications WHERE id_cfg_notification IN (__ID_CFG_NOTIFICATION__)",



// ---------------------------------------------------------------------------------------
// mod_avisos_detalle.php
// ---------------------------------------------------------------------------------------

			// ---------------------------------------------------------------------------------------
         // Listado de avisos definidos
         'get_alert_type_all'=>"(SELECT monitor,description as cause,'icmp_metric' AS type FROM cfg_monitor WHERE monitor like 'w_%') UNION (SELECT monitor,description as cause,'icmp_agent' AS type FROM cfg_monitor WHERE  monitor='mon_icmp') UNION (SELECT monitor,description as cause,'snmp_agent' AS type FROM cfg_monitor WHERE monitor='mon_snmp') UNION (SELECT monitor ,cause, 'monitor' AS type FROM alert_type WHERE monitor like 's_%') UNION (SELECT subtype as monitor,descr as cause,'remote_alert' AS type FROM cfg_remote_alerts ORDER BY cause)",

			// ---------------------------------------------------------------------------------------
         // Obtener el id_alert_type de un monitor en base a su campo monitor
         'idalerttype_monitor'=>"select id_alert_type from alert_type where monitor='__MONITOR__'",

         // ---------------------------------------------------------------------------------------
         // Crear un aviso
         'create_notification'=>"INSERT INTO cfg_notifications (monitor,type,name,id_alert_type) VALUES ('__MONITOR__','__TYPE__','__NAME__','__ID_ALERT_TYPE__')",

			// ---------------------------------------------------------------------------------------
         // Modificar un aviso
         'update_notification'=>"UPDATE cfg_notifications SET monitor='__MONITOR__', type='__TYPE__', name='__NAME__', id_alert_type='__ID_ALERT_TYPE__' WHERE id_cfg_notification='__ID_CFG_NOTIFICATION__'",

         // ---------------------------------------------------------------------------------------
         // Obtener el id_cfg_notification del ultimo aviso creado
         'get_last_id_cfg_notification'=>"select max(id_cfg_notification) as id_cfg_notification from cfg_notifications",

         // ---------------------------------------------------------------------------------------
         // Obtener informacion de un aviso en base a su id_cfg_notification
         'notification_info'=>"SELECT id_cfg_notification,id_alert_type,type,id_notification_type,name,destino,status,monitor FROM cfg_notifications WHERE id_cfg_notification='__ID_CFG_NOTIFICATION__'",


// ---------------------------------------------------------------------------------------
// mod_avisos_dispositivo.php
// ---------------------------------------------------------------------------------------

			// ---------------------------------------------------------------------------------------
         // Dispositivos asociados a un aviso
         'devices_notification'=>"SELECT d.id_dev,d.name,d.ip,'1' as asoc,type,status FROM devices d WHERE d.id_dev IN (SELECT id_device FROM cfg_notification2device WHERE id_cfg_notification LIKE '__ID_CFG_NOTIFICATION__') UNION SELECT d.id_dev,d.name,d.ip,'0',d.type,d.status as asoc FROM devices d WHERE d.id_dev NOT IN (SELECT id_device FROM cfg_notification2device WHERE id_cfg_notification LIKE '__ID_CFG_NOTIFICATION__')",
         // ---------------------------------------------------------------------------------------
         // Asociar un dispositivo a un aviso
         'notification_asoc'=>"INSERT IGNORE INTO cfg_notification2device (id_cfg_notification,id_device,status) SELECT '__ID_CFG_NOTIFICATION__','__ID_DEV__',status FROM devices WHERE id_dev=__ID_DEV__",

         // ---------------------------------------------------------------------------------------
         // Desasociar un dispositivo de una tarea configurada
         'notification_unasoc'=>"DELETE FROM cfg_notification2device WHERE id_cfg_notification='__ID_CFG_NOTIFICATION__' AND id_device=__ID_DEV__",


         // ---------------------------------------------------------------------------------------
         // mod_avisos_documentacion.php
         // ---------------------------------------------------------------------------------------

         // ---------------------------------------------------------------------------------------
         // Borrar una entrada de la documentacion a partir de su id_tip
         'delete_tip'=>"DELETE FROM tips WHERE id_tip IN (__ID_TIP__)",

         // ---------------------------------------------------------------------------------------
         // Insertar una entrada en la documentacion
         'insert_tip'=>"INSERT INTO tips (descr,id_ref,tip_type,date,name) VALUES ('__DESCR__','__ID_REF__','__TIP_TYPE__',__DATE__,'__NAME__')",

         // ---------------------------------------------------------------------------------------
         // Actualizar una entrada de la documentacion
         'edit_tip'=>"UPDATE tips SET descr='__DESCR__',date=__DATE__,name='__NAME__' WHERE id_tip=__ID_TIP__",


// ---------------------------------------------------------------------------------------
// mod_avisos_transporte.php
// ---------------------------------------------------------------------------------------

			// ---------------------------------------------------------------------------------------
         // Obtener la alerta asociada a un determinado aviso
			'get_asociated_alert' => "SELECT monitor FROM cfg_notifications WHERE id_cfg_notification=__ID_CFG_NOTIFICATION__",

			// ---------------------------------------------------------------------------------------
         // Obtener los transportes registrados en el sistema
			'get_registered_transports' => "SELECT a.id_register_transport,b.name as tipo,a.name,a.value FROM cfg_register_transports a, notification_type b WHERE a.id_notification_type=b.id_notification_type",

         // ---------------------------------------------------------------------------------------
         // Obtener los transportes SMTP registrados en el sistema
         'get_registered_transports_smtp' => "SELECT a.id_register_transport,a.name,a.value FROM cfg_register_transports a WHERE a.id_notification_type=1",

         // ---------------------------------------------------------------------------------------
         // Obtener los transportes SMS registrados en el sistema
         'get_registered_transports_sms' => "SELECT a.id_register_transport,a.name,a.value FROM cfg_register_transports a WHERE a.id_notification_type=2",

         // ---------------------------------------------------------------------------------------
         // Obtener los transportes SNMP-TRAP registrados en el sistema
         'get_registered_transports_trap' => "SELECT a.id_register_transport,a.name,a.value FROM cfg_register_transports a WHERE a.id_notification_type=3",

         // ---------------------------------------------------------------------------------------
         // Actualizar los transportes registrados en el sistema
         'update_registered_transport' => "UPDATE cfg_register_transports SET name='__NAME__', value='__VALUE__' WHERE id_register_transport='__ID_REGISTER_TRANSPORT__'",

         // ---------------------------------------------------------------------------------------
         // Crear un nuevo transporte registrado en el sistema
			'create_registered_transport' => "INSERT INTO cfg_register_transports (name,value,id_notification_type) VALUES ('__NAME__','__VALUE__','__ID_NOTIFICATION_TYPE__')",

			// ---------------------------------------------------------------------------------------
         // Obtener los transportes asociados  una determinado aviso
			'get_notification2transport' => "SELECT id_register_transport FROM cfg_notification2transport WHERE id_cfg_notification=__ID_CFG_NOTIFICATION__",
			// ---------------------------------------------------------------------------------------
         // Asociar los transportes asociados  una determinado aviso
			'asoc_notification2transport' => "INSERT INTO cfg_notification2transport (id_cfg_notification,id_register_transport) VALUES (__ID_CFG_NOTIFICATION__,__ID_REGISTER_TRANSPORT__)",
         // ---------------------------------------------------------------------------------------
         // Desasociar los transportes asociados  una determinado aviso
         'unasoc_notification2transport' => "DELETE FROM cfg_notification2transport WHERE id_cfg_notification=__ID_CFG_NOTIFICATION__ AND id_register_transport=__ID_REGISTER_TRANSPORT__",
			'unasoc_notification2transport_by_id_cfg_notification'=>"DELETE FROM cfg_notification2transport WHERE id_cfg_notification IN (__ID_CFG_NOTIFICATION__)",

			// Asociar las aplicaciones a un determinado aviso
			'asoc_notification2app'=>"INSERT INTO cfg_notification2app (id_cfg_notification,id_monitor_app) VALUES (__ID_CFG_NOTIFICATION__,__ID_MONITOR_APP__)",
			// Desasociar las aplicaciones de un determinado aviso
			'unasoc_notification2app'=>"DELETE FROM cfg_notification2app WHERE  id_cfg_notification=__ID_CFG_NOTIFICATION__ AND id_monitor_app=__ID_MONITOR_APP__",
			'unasoc_notification2app_by_id_cfg_notification'=>"DELETE FROM cfg_notification2app WHERE  id_cfg_notification IN (__ID_CFG_NOTIFICATION__)",
			// ---------------------------------------------------------------------------------------
         // Obtener la alerta asociada a un aviso
			'get_asociated_alerts' => "(SELECT b.descr as cause FROM cfg_notifications a, cfg_remote_alerts b WHERE  a.id_cfg_notification=__ID_CFG_NOTIFICATION__ and a.monitor=b.subtype)  UNION (SELECT b.cause FROM cfg_notifications a, alert_type b WHERE  a.id_cfg_notification=__ID_CFG_NOTIFICATION__ and a.monitor=b.monitor)",

         // ---------------------------------------------------------------------------------------
         // Obtener los dispositivos asociados a un aviso
			'get_asociated_devices' =>"SELECT d.status,d.name,d.ip,d.type FROM devices d, cfg_notification2device c WHERE d.id_dev=c.id_device and id_cfg_notification=__ID_CFG_NOTIFICATION__",


         // ---------------------------------------------------------------------------------------
         // Borrar transportes registrados
				'delete_transports' =>"DELETE FROM cfg_register_transports WHERE id_register_transport in (__ID_REGISTER_TRANSPORT__)",

			'all_devices_notifications' => "SELECT id_device as id_dev FROM cfg_notification2device WHERE id_cfg_notification IN (__ID_CFG_NOTIFICATION__)",



 /**
	* **************************************************************** *
	* Modulo: mod_graficas.sql
	* **************************************************************** *
	*/


		// mod_graficas.php
		// Obtener todos los campos de un dispositivo
		'device'=>"SELECT * FROM devices WHERE id_dev IN (__ID_DEV__)",
		// mod_graficas.php
		// Obtener todos los campos de una vista
		'view'=>"SELECT * FROM cfg_views WHERE id_cfg_view=__ID_CFG_VIEW__",
		'all_view'=>"SELECT * FROM cfg_views WHERE cid='__CID__' AND cid_ip='__CID_IP__'",
		// Obtener los datos de las metricas de una vista
		'cfg_views2metrics'=>"SELECT * FROM cfg_views2metrics WHERE id_cfg_view=__ID_CFG_VIEW__ AND id_metric=__ID_METRIC__",

		// id_metric e id_dev de las metricas asociadas a una vista
		'metric_view' => "SELECT id_metric,id_cfg_view,id_device as id_dev FROM cfg_views2metrics WHERE id_cfg_view IN (__ID_CFG_VIEW__)",
		'metric_view_by_id' => "SELECT id_metric,id_cfg_view,id_device as id_dev FROM cfg_views2metrics WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND id_metric IN (__ID_METRIC__)",
		// metricas y alertas remotas asociadas a una vista
		'metric_remote_view' => "(SELECT id_metric,id_cfg_view,id_device as id_dev,'metric' AS type FROM cfg_views2metrics WHERE id_cfg_view IN (__ID_CFG_VIEW__)) UNION (SELECT id_remote_alert as id_metric,id_cfg_view,id_dev,'remote' AS type FROM cfg_views2remote_alerts WHERE id_cfg_view IN (__ID_CFG_VIEW__))",
		

		'alarmed_trap_view'=>"SELECT mname,event_data,severity,id_device,id_metric FROM alerts WHERE type IN ('snmp-trap','api','email','syslog')",
		'trap_view'=>"SELECT a.id_remote_alert,a.id_dev,b.type,b.descr,b.action,b.subtype,c.name,c.domain FROM cfg_views2remote_alerts a,cfg_remote_alerts b,devices c WHERE a.id_remote_alert=b.id_remote_alert AND a.id_dev=c.id_dev AND a.id_cfg_view IN (__ID_CFG_VIEW__)",
		'trap_view_severity'=>"SELECT ifnull(MAX(c.severity),0) as severity from cfg_views2remote_alerts a,cfg_remote_alerts b,alerts c WHERE a.id_remote_alert=b.id_remote_alert AND b.subtype=c.mname AND a.id_dev=c.id_device AND a.id_cfg_view IN (__ID_CFG_VIEW__)",

		// Obtener los dispositivos asociados a una vista
		'devices_view' => "SELECT DISTINCT(b.id_dev),b.name,b.domain FROM cfg_views2metrics a,devices b WHERE a.id_cfg_view IN (__ID_CFG_VIEW__) AND a.id_device=b.id_dev",

		'view_alerts' =>"SELECT from_unixtime(a.date) as date ,a.id_metric,a.mname,b.domain,b.name,b.ip,b.sysloc,b.id_dev,a.ack,a.label as cause,a.severity,a.event_data, a.id_alert,a.id_alert_type,a.mname,a.id_ticket,a.type as tipo,a.watch,a.counter FROM alerts a,devices b  WHERE b.id_dev=a.id_device and a.counter>0  AND a.id_device IN (__ID_DEV__) AND (a.id_metric IN (__ID_METRIC__) OR a.mname='mon_icmp' OR a.mname='mon_snmp' OR a.mname='mon_xagent') __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",

		'view_alerts_count' =>"SELECT COUNT(DISTINCT a.id_alert) FROM alerts a,devices b  WHERE b.id_dev=a.id_device and a.counter>0  AND a.id_device IN (__ID_DEV__) AND (a.id_metric IN (__ID_METRIC__) OR a.mname='mon_icmp' OR a.mname='mon_snmp' OR a.mname='mon_xagent') __CONDITION__",
		'view_history' => "SELECT from_unixtime(a.date) as date ,a.mname,b.domain,b.name,b.ip,b.sysloc,b.id_dev,a.ack,a.duration,a.label as cause,a.severity,a.event_data, a.id_alert,a.id_alert_type,a.mname,a.id_ticket,a.type as tipo,a.watch FROM alerts_store a,devices b  WHERE b.id_dev=a.id_device and a.counter>0  AND a.id_device IN (__ID_DEV__) AND (a.id_metric IN (__ID_METRIC__) OR a.mname='mon_icmp' OR a.mname='mon_snmp' OR a.mname='mon_xagent')  __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
		'view_history_count' => "SELECT COUNT(DISTINCT a.id_alert) AS cuantos FROM alerts_store a,devices b  WHERE b.id_dev=a.id_device and a.counter>0  AND a.id_device IN (__ID_DEV__) AND (a.id_metric IN (__ID_METRIC__) OR a.mname='mon_icmp' OR a.mname='mon_snmp' OR a.mname='mon_xagent')  __CONDITION__",

      // mod_graficas.php
      // Obtener las metricas de un dispostivo
      'metrics_device'=>"SELECT * FROM metrics WHERE id_dev=__ID_DEV__",
      // mod_graficas.php
      // Obtener las metricas de una vista
      'metrics_view'=>"SELECT * FROM cfg_views2metrics WHERE id_cfg_view=__ID_CFG_VIEW__",
      // mod_graficas.php
      // Obtener todos las subvistas de una vista
      'subviews_view'=>"SELECT a.graph,a.size,a.id_cfg_subview,b.name from cfg_views2views a,cfg_views b WHERE a.id_cfg_view=__ID_CFG_VIEW__ AND a.id_cfg_subview=b.id_cfg_view",
		'subviews_view_by_id'=>"SELECT a.graph,a.size,a.id_cfg_subview,b.name from cfg_views2views a,cfg_views b WHERE a.id_cfg_view=__ID_CFG_VIEW__ AND a.id_cfg_subview=b.id_cfg_view AND a.id_cfg_subview IN (__ID_CFG_SUBVIEW__) AND b.cid='__CID__' AND b.cid_ip='__CID_IP__' AND b.cid=a.cid_view AND b.cid=a.cid_subview AND b.cid_ip=a.cid_ip_view AND b.cid_ip=a.cid_ip_subview",

      // mod_graficas.php
      // Obtener la informacion de una metrica
      'metric'=>"SELECT * FROM metrics WHERE id_metric IN (__ID_METRIC__)",
      'metric_by_name'=>"SELECT * FROM metrics WHERE name='__NAME__'",
      // mod_graficas.php
      // Obtener la informacion de una metrica y si esta alarmada
      'metric_alert'=>"SELECT a.subtype,a.type,a.id_metric,a.file,a.label,a.status,a.name as mname,a.mtype,a.type,a.items,a.id_dev,a.watch,a.vlabel,a.size,a.file,a.graph,a.c_label,a.lapse,a.c_items,b.severity,ifnull(b.id_metric,0) as alerted,a.iid,IFNULL(a.top_value,'') AS top_value FROM metrics a LEFT JOIN alerts b ON a.id_metric=b.id_metric AND a.type=b.type WHERE a.id_metric IN (__ID_METRIC__) AND a.type IN ('snmp','latency','xagent')",
		'summary_info'=>"SELECT graph,size FROM cfg_devices2items WHERE id_dev=__ID_DEV__ AND item='summary'",	
	
		// mod_graficas_validar.php
		// mod_graficas_dispositivo_alertas.ph
		// Obtener las alertas de un dispositivo
		'device_alerts'=>"SELECT from_unixtime(a.date) as date ,a.mname,d.domain,d.name,d.ip,d.sysloc,d.id_dev,a.ack,a.counter,a.label as cause,a.severity,a.event_data, a.id_alert,a.id_alert_type,a.mname,a.id_ticket,a.type as tipo,a.watch,a.id_alert FROM alerts a,devices d  WHERE d.id_dev=a.id_device and a.counter>0  AND d.id_dev IN (__ID_DEV__) ORDER BY a.severity",
      // mod_graficas_dispositivo_historico.ph
      // Obtener el historico de alertas de un dispositivo
      // 'device_history'=>"SELECT from_unixtime(a.date) as date ,a.mname,d.domain,d.name,d.ip,d.sysloc,d.id_dev,a.ack,a.duration,a.label as cause,a.severity,a.event_data, a.id_alert,a.id_alert_type,a.mname,a.id_ticket,a.type as tipo,a.watch FROM alerts_store a,devices d  WHERE d.id_dev=a.id_device and a.counter>0  AND d.id_dev IN (__ID_DEV__)",
		'device_history'=>"SELECT b.name,b.domain,b.ip,b.status,a.id_alert,a.severity,from_unixtime(a.date) as date,a.counter,a.type,a.label,a.event_data,a.watch  FROM alerts_store a,devices b WHERE a.id_device=b.id_dev AND a.counter>0 AND b.id_dev IN (__ID_DEV__) __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
		'device_history_count'=> "SELECT COUNT(DISTINCT a.id_alert) AS cuantos FROM alerts_store a,devices b WHERE a.id_device=b.id_dev AND a.counter>0 AND a.id_device IN (__ID_DEV__)  __CONDITION__ ",
      // mod_graficas.php
		'all_alerts'=>"SELECT id_device,mname,id_alert_type,type FROM alerts WHERE counter>0",
		// mod_graficas.php
		// Almacenar la posicion y el tamaño de las graficas de metricas de dispositivo
		'save_metric_pos_size'=>"UPDATE metrics SET graph='__GRAPH__',size='__SIZE__' WHERE id_metric=__ID_METRIC__",
		'reset_metric_pos_size'=>"UPDATE metrics SET graph=NULL,size=NULL WHERE id_metric=__ID_METRIC__",
      'save_summary_pos_size'=>"INSERT INTO cfg_devices2items (id_dev,item,graph,size) VALUES (__ID_DEV__,'summary',__GRAPH__,'__SIZE__') ON DUPLICATE KEY UPDATE graph=__GRAPH__,size='__SIZE__'",



		//mod_graficas_modificar.php
		// Modificar los items y el titulo de una metrica
		'modify_metric_custom_fields'=>"UPDATE metrics SET c_label='__C_LABEL__', c_items='__C_ITEMS__' WHERE id_metric=__ID_METRIC__",
		// mod_graficas_dispositivo_avisos.php
		// Obtener todos los avisos de un dispositivo
/*
		'device_warnings'=>"SELECT DISTINCT n.id_notif,d.name,d.domain,from_unixtime(n.date) as date ,t.name as type,c.destino as dest,n.rc,n.msg
                			  FROM notifications n, cfg_notifications c,alert_type a, devices d,notification_type t
                 			  WHERE n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev and c.id_notification_type=t.id_notification_type AND d.id_dev IN (__ID_DEV__)
								  UNION
								  SELECT DISTINCT n.id_notif,d.name,d.domain,from_unixtime(n.date) as date ,t.name as type,c.destino as dest,n.rc,n.msg
                			  FROM notifications n, cfg_notifications c,cfg_monitor a, devices d,notification_type t
                			  WHERE n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev and c.id_notification_type=t.id_notification_type AND d.id_dev IN (__ID_DEV__)
								  UNION
								  SELECT DISTINCT n.id_notif,d.name,d.domain,from_unixtime(n.date) as date ,t.name as type,c.destino as dest,n.rc,n.msg
               			  FROM notifications n, cfg_notifications c,cfg_remote_alerts a, devices d,notification_type t
               			  WHERE n.id_cfg_notification=c.id_cfg_notification and a.subtype=c.monitor and n.id_dev=d.id_dev and c.id_notification_type=t.id_notification_type AND d.id_dev IN (__ID_DEV__)",
*/

      'device_warnings'=>"SELECT DISTINCT n.id_notif,d.name,d.domain,from_unixtime(n.date) as date ,w.name as type,v.name as dest,n.rc,n.msg
                          FROM notifications n, cfg_notifications c,alert_type a, devices d,cfg_notification2transport t,cfg_register_transports v,notification_type w
                          WHERE n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev and c.id_cfg_notification=t.id_cfg_notification AND t.id_register_transport=v.id_register_transport AND v.id_notification_type=w.id_notification_type AND d.id_dev IN (__ID_DEV__)
                          UNION
                          SELECT DISTINCT n.id_notif,d.name,d.domain,from_unixtime(n.date) as date ,w.name as type,v.name as dest,n.rc,n.msg
                          FROM notifications n, cfg_notifications c,cfg_monitor a, devices d,cfg_notification2transport t,cfg_register_transports v,notification_type w
                          WHERE n.id_cfg_notification=c.id_cfg_notification and a.monitor=c.monitor and n.id_dev=d.id_dev and c.id_cfg_notification=t.id_cfg_notification AND t.id_register_transport=v.id_register_transport AND v.id_notification_type=w.id_notification_type AND d.id_dev IN (__ID_DEV__)
                          UNION
                          SELECT DISTINCT n.id_notif,d.name,d.domain,from_unixtime(n.date) as date ,w.name as type,v.name as dest,n.rc,n.msg
                          FROM notifications n, cfg_notifications c,cfg_remote_alerts a, devices d,cfg_notification2transport t,cfg_register_transports v,notification_type w
                          WHERE n.id_cfg_notification=c.id_cfg_notification and a.subtype=c.monitor and n.id_dev=d.id_dev and c.id_cfg_notification=t.id_cfg_notification AND t.id_register_transport=v.id_register_transport AND v.id_notification_type=w.id_notification_type AND d.id_dev IN (__ID_DEV__)",
		'device_notifications'=>"SELECT a.descr,a.rcstr,a.atype,a.status,a.rc,FROM_UNIXTIME(a.date_store) AS date FROM qactions a WHERE a.atype IN (1001,1002,1003) AND a.id_dev IN (__ID_DEV__) ORDER BY a.date_store DESC",

		// mod_graficas_dispositivo_eventos.php
      // Obtener todos los eventos de un dispositivo
		'device_events'=>"SELECT DISTINCT a.id_event,a.name,a.domain,a.ip,a.code,a.proccess,a.msg,a.evkey,from_unixtime(date) as date,a.msg_custom FROM events a, devices b WHERE a.ip=b.ip AND b.id_dev IN (__ID_DEV__)  __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
		'device_events_count'=>"SELECT COUNT(DISTINCT a.id_event) AS cuantos FROM events a,devices b WHERE a.ip=b.ip AND b.id_dev IN (__ID_DEV__) __CONDITION__ ",
		'alerts_view' =>"SELECT DISTINCT id_cfg_view, name, type, red, orange, yellow,itil_type FROM cfg_views WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND cid='__CID__' AND cid_ip='__CID_IP__'",
      // mod_vistas_graficas.php
      // Almacenar la posicion y el tamaño de las graficas de metricas de vistas
      'save_view_metric_pos_size'=>"UPDATE cfg_views2metrics SET graph='__GRAPH__',size='__SIZE__' WHERE id_metric=__ID_METRIC__ AND id_cfg_view=__ID_CFG_VIEW__",
		'reset_view_metric_pos_size'=>"UPDATE cfg_views2metrics SET graph=NULL,size=NULL WHERE id_metric=__ID_METRIC__ AND id_cfg_view=__ID_CFG_VIEW__",
      // Almacenar la posicion y el tamaño de las graficas de subvistas de vistas
      'save_view_subview_pos_size'=>"UPDATE cfg_views2views SET graph='__GRAPH__',size='__SIZE__' WHERE id_cfg_subview=__ID_CFG_SUBVIEW__ AND id_cfg_view=__ID_CFG_VIEW__",
		// Multi
		'global_save_view_subview_pos_size'=>"UPDATE cfg_views2views SET graph='__GRAPH__',size='__SIZE__' WHERE id_cfg_view=__ID_CFG_VIEW__ AND id_cfg_subview=__ID_CFG_SUBVIEW__ AND cid_view='__CID_VIEW__' AND cid_subview='__CID_SUBVIEW__' AND cid_ip_view='__CID_IP_VIEW__' AND cid_ip_subview='__CID_IP_SUBVIEW__'",
      'reset_view_subview_pos_size'=>"UPDATE cfg_views2views SET graph=NULL,size=NULL WHERE id_cfg_subview=__ID_CFG_SUBVIEW__ AND id_cfg_view=__ID_CFG_VIEW__",
		// Multi
      'global_reset_view_subview_pos_size'=>"UPDATE cfg_views2views SET graph=NULL,size=NULL WHERE id_cfg_view=__ID_CFG_VIEW__ AND id_cfg_subview=__ID_CFG_SUBVIEW__ AND cid_view='__CID_VIEW__' AND cid_subview='__CID_SUBVIEW__' AND cid_ip_view='__CID_IP_VIEW__' AND cid_ip_subview='__CID_IP_SUBVIEW__'",
		// Almacenar la posicion y el tamaño de los items de una vista
		'save_view_item_pos_size'=>"INSERT INTO cfg_views2items (id_cfg_view,item,graph,size) VALUES (__ID_CFG_VIEW__,'__ITEM__',__GRAPH__,'__SIZE__') ON DUPLICATE KEY UPDATE graph=__GRAPH__,size='__SIZE__'",
      // Almacenar la posicion y el tamaño de los items de un dispositivo
      'save_device_item_pos_size'=>"INSERT INTO cfg_devices2items (id_dev,item,graph,size) VALUES (__ID_DEV__,'__ITEM__',__GRAPH__,'__SIZE__') ON DUPLICATE KEY UPDATE graph=__GRAPH__,size='__SIZE__'",


 /**
   * **************************************************************** *
   * Modulo: global.sql
   * **************************************************************** *
   */

		// 'device_types'=>"SELECT DISTINCT(type) FROM devices",
		'device_types'=>"SELECT id_host_type,descr FROM cfg_host_types order by descr",
		'device_types_count'=>"SELECT a.id_host_type,a.descr,COUNT(DISTINCT b.id_dev) AS cuantos FROM cfg_host_types a, devices b,cfg_devices2organizational_profile e WHERE a.descr=b.type AND b.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__' GROUP BY a.descr",
		'device_types_count_delete_temp'=>"DROP TEMPORARY TABLE t1,t2",
		'device_types_count_1'=>"CREATE TEMPORARY TABLE t1 (SELECT COUNT(a.id_dev) AS cuantos,a.type FROM devices a, cfg_devices2organizational_profile b WHERE a.id_dev=b.id_dev AND b.id_cfg_op IN (__ID_CFG_OP__) AND b.cid='__CID__' GROUP BY a.type)",
		'device_types_count_2'=>"SELECT a.id_host_type,a.descr,IFNULL(b.cuantos,0) AS cuantos FROM cfg_host_types a LEFT JOIN t1 b ON a.descr=b.type ORDER BY a.descr",
		'device_no_types_count'=>"SELECT COUNT(DISTINCT a.id_dev) AS cuantos FROM devices a,cfg_devices2organizational_profile e WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__' AND (a.type IS NULL OR a.type='')",
		'device_types_by_id'=>"SELECT descr FROM cfg_host_types WHERE id_host_type IN (__ID_HOST_TYPE__)",
		'device_types_by_descr'=>"SELECT * FROM cfg_host_types WHERE descr='__DESCR__'",
      'create_cfg_host_types'=>"INSERT INTO cfg_host_types (descr) VALUES ('__DESCR__')",
      'mod_cfg_host_types'=>"UPDATE cfg_host_types SET descr='__DESCR__' WHERE id_host_type IN (__ID_HOST_TYPE__)",
      'update_type_in_devices'=>"UPDATE devices SET type='__TYPE_NEW__' WHERE type='__TYPE_OLD__'",
      'del_cfg_host_types'=>"DELETE FROM cfg_host_types WHERE id_host_type IN (__ID_HOST_TYPE__)",

		'view_types'=>"SELECT id_view_type,name FROM cfg_views_types",
		'view_types_aux'=>"SELECT DISTINCT(type) AS type FROM cfg_views WHERE type!='' AND type IS NOT NULL",
		'admin_view_types_count'=>"SELECT a.id_view_type,a.name,COUNT(DISTINCT b.id_cfg_view) AS cuantos FROM cfg_views_types a, cfg_views b WHERE a.name=b.type AND b.cid='__CID__' AND b.cid_ip='__CID_IP__' AND b.global!=2 GROUP BY a.name",
		'admin_count_all_view'=>"SELECT COUNT(DISTINCT id_cfg_view) AS cuantos FROM cfg_views WHERE cid='__CID__' AND cid_ip='__CID_IP__' AND global!=2",
		'no_admin_count_all_view'=>"SELECT COUNT(DISTINCT b.id_cfg_view) AS cuantos FROM cfg_views_types a, cfg_views b,cfg_user2view c WHERE a.name=b.type AND b.cid='__CID__' AND b.cid_ip='__CID_IP__' AND b.id_cfg_view=c.id_cfg_view AND c.id_user in (__IDUSER__) AND b.global!=2",
		'admin_view_no_types_count'=>"SELECT COUNT(DISTINCT id_cfg_view) AS cuantos FROM cfg_views WHERE cid='__CID__' AND cid_ip='__CID_IP__' AND (type IS NULL OR type='') AND global!=2",
		'view_types_count'=>"SELECT a.id_view_type,a.name,COUNT(DISTINCT b.id_cfg_view) AS cuantos FROM cfg_views_types a, cfg_views b,cfg_user2view c WHERE a.name=b.type AND b.cid='__CID__' AND b.cid_ip='__CID_IP__' AND b.id_cfg_view=c.id_cfg_view AND c.id_user in (__IDUSER__) AND b.global!=2 GROUP BY a.name",
		'view_no_types_count'=>"SELECT COUNT(DISTINCT b.id_cfg_view) AS cuantos FROM cfg_views b,cfg_user2view c WHERE b.id_cfg_view=c.id_cfg_view AND b.cid='__CID__' AND b.cid_ip='__CID_IP__' AND c.id_user in (__IDUSER__) AND (b.type IS NULL OR b.type='') AND b.global!=2",
		'view_types_by_id'=>"SELECT name FROM cfg_views_types WHERE id_view_type IN (__ID_VIEW_TYPE__)",
		'create_view_types'=>"INSERT INTO cfg_views_types (name) VALUES ('__NAME__')",
		'mod_view_types'=>"UPDATE cfg_views_types SET name='__NAME__' WHERE id_view_type IN (__ID_VIEW_TYPE__)",
		'update_type_in_views'=>"UPDATE cfg_views SET type='__TYPE_NEW__' WHERE type='__TYPE_OLD__'",
		'del_view_types'=>"DELETE FROM cfg_views_types WHERE id_view_type IN (__ID_VIEW_TYPE__)",
		


 /**
	* **************************************************************** *
	* Modulo: summary.sql
	* Descripcion: Modulo que contiene las consultas que se van a usar
	* en el modulo summary.php
	* **************************************************************** *
	*/


		// Obtener las alertas, dispositivos, eventos y avisos que deben aparecer en la barra de resumen
      // 'summary_alerts'=>"SELECT red_alerts,orange_alerts,yellow_alerts,blue_alerts,grey_alerts,devices,red_devices,orange_devices,yellow_devices,blue_devices,events,notices FROM alerts_summary_op WHERE id_cfg_op in (__ORGPRO__)",
      'summary_alerts'=>"SELECT COUNT(DISTINCT a.id_alert) AS cuantos,a.severity,c.hidx FROM alerts_read a,alert2user b, cnm.cfg_cnms c WHERE a.counter>0 AND a.cid=b.cid AND a.cid_ip=b.cid_ip AND a.id_alert=b.id_alert AND b.login_name='__LOGIN_NAME__' AND a.cid_ip=c.host_ip AND a.cid=c.cid GROUP BY c.hidx,a.severity",
      'get_alerts_from_device_type'=>"SELECT COUNT(a.id_alert) AS cuantos,a.severity from alerts_read a,cfg_devices2organizational_profile b,devices c WHERE a.id_device=b.id_dev AND b.id_dev=c.id_dev AND b.id_cfg_op IN (__ID_CFG_OP__) AND c.type='__TYPE__' GROUP BY a.severity",
		// Obtener las vistas que deben aparecer en la barra de resumen
		'summary_views'=>"SELECT red_views,orange_views,yellow_views,blue_views,grey_views FROM alerts_summary_user WHERE id_user in (__IDUSER__)",


 /**
	* **************************************************************** *
	* Modulo: mod_config.sql
	* **************************************************************** *
	*/
         //---------------------------------------------------------------------------------------
			'all_profiles'=>"SELECT id_profile,profile_name,sec_name,sec_level,auth_proto,auth_pass,priv_proto,priv_pass FROM profiles_snmpv3",
         //---------------------------------------------------------------------------------------
			'delete_profile'=>"DELETE FROM profiles_snmpv3 WHERE id_profile IN (__ID_PROFILE__)",
         //---------------------------------------------------------------------------------------
			// 'save_profile'=>"INSERT INTO profiles_snmpv3 (profile_name,sec_name,sec_level,auth_proto,auth_pass,priv_proto,priv_pass) VALUES ('__PROFILE_NAME__','__SEC_NAME__','__SEC_LEVEL__','__AUTH_PROTO__','__AUTH_PASS__','__PRIV_PROTO__','__PRIV_PASS__') ON DUPLICATE KEY UPDATE profile_name='__PROFILE_NAME__',sec_name='__SEC_NAME__',sec_level='__SEC_NAME__',sec_level='__SEC_LEVEL__',auth_proto='__AUTH_PROTO__',auth_pass='__AUTH_PASS__',priv_proto='__PRIV_PROTO__',priv_pass='__PRIV_PASS__'",
         //---------------------------------------------------------------------------------------
			'insert_profile'=>"INSERT INTO profiles_snmpv3 (profile_name,sec_name,sec_level,auth_proto,auth_pass,priv_proto,priv_pass) VALUES ('__PROFILE_NAME__','__SEC_NAME__','__SEC_LEVEL__','__AUTH_PROTO__','__AUTH_PASS__','__PRIV_PROTO__','__PRIV_PASS__')",
         //---------------------------------------------------------------------------------------
			'update_profile'=>"UPDATE profiles_snmpv3 SET profile_name='__PROFILE_NAME__',sec_name='__SEC_NAME__',sec_level='__SEC_NAME__',sec_level='__SEC_LEVEL__',auth_proto='__AUTH_PROTO__',auth_pass='__AUTH_PASS__',priv_proto='__PRIV_PROTO__',priv_pass='__PRIV_PASS__' WHERE id_profile='__ID_PROFILE__'",


         //---------------------------------------------------------------------------------------
/*
mysql> select * from credentials;
+---------------+--------+-------------+------+------+--------+--------+------+
| id_credential | name   | descr       | type | user | pwd    | scheme | port |
+---------------+--------+-------------+------+------+--------+--------+------+
|             1 | wmilan | WMI-Red Lan | wmi  | s30  | s30    |        | NULL |
|             2 | sshcnm | SSH cnm     | ssh  | cnm  | cnm123 |        | NULL |
+---------------+--------+-------------+------+------+--------+--------+------+
2 rows in set (0.00 sec)
*/
			'all_credentials'=> "SELECT id_credential,pwd,descr,type,user,port,name,scheme,passphrase,key_file FROM credentials",
			'all_credentials_real'=> "SELECT id_credential,pwd,descr,type,user,port,name FROM credentials where type IN ('ssh','telnet','wmi','cifs','vmware','syslog-local2','syslog-local3','syslog-local4','syslog-filters','ipmi','api','mssql','ldap','app1','app2','app3','app4','app5')",
			'all_credentials_webservice'=> "SELECT id_credential,pwd,descr,type,user,port,name FROM credentials where type IN ('http','https')",
			'get_credentials_by_id'=> "SELECT id_credential,pwd,descr,type,user,port,name FROM credentials WHERE id_credential IN (__ID_CREDENTIAL__)",
			'update_credential_no_passwd'=>"UPDATE credentials SET name='__NAME__',type='__TYPE__',user='__USER__',port='__PORT__',scheme='__SCHEME__',passphrase='__PASSPHRASE__',key_file='__KEY_FILE__' WHERE id_credential=__ID_CREDENTIAL__",
			'update_credential_passwd'=>"UPDATE credentials SET name='__NAME__',type='__TYPE__',user='__USER__',pwd='__PWD__',port='__PORT__',scheme='__SCHEME__',passphrase='__PASSPHRASE__',key_file='__KEY_FILE__' WHERE id_credential=__ID_CREDENTIAL__",
			'create_credential'=>"INSERT INTO credentials (name,type,user,pwd,port,scheme,passphrase,key_file) VALUES ('__NAME__','__TYPE__','__USER__','__PWD__','__PORT__','__SCHEME__','__PASSPHRASE__','__KEY_FILE__')",
			'delete_credential'=>"DELETE FROM credentials WHERE id_credential=__ID_CREDENTIAL__",
/*
mysql> select * from device2credential;
+--------+---------------+
| id_dev | id_credential |
+--------+---------------+
|      1 |             1 |
|     18 |             1 |
|     43 |             1 |
+--------+---------------+
3 rows in set (0.00 sec)
*/
		'credential_from_device'=>"SELECT id_credential FROM device2credential WHERE id_dev=__ID_DEV__",
		'info_wmi_credential_from_device'=>"SELECT b.name,b.descr,b.user,b.pwd FROM device2credential a,credentials b WHERE a.id_credential=b.id_credential AND b.type='wmi' AND a.id_dev IN (__ID_DEV__)",
		'insert_device_credential'=>"INSERT INTO device2credential (id_dev,id_credential) VALUES (__ID_DEV__,__ID_CREDENTIAL__)",
		'delete_device_credential'=>"DELETE FROM device2credential WHERE id_dev=__ID_DEV__ AND id_credential=__ID_CREDENTIAL__",


 /**
	* **************************************************************** *
	* Modulo: mod_provision.sql
	* **************************************************************** *
	*/


			// ---------------------------------------------------------------------------	
			// Obtener el listado de campos de usuario disponibles
			// mod_provision_lista.php
			'get_user_fields' => "SELECT id,descr,tipo AS type FROM devices_custom_types order by descr",
			// ---------------------------------------------------------------------------	
			// Obtener todos los datos (incluido los de usuario) de los dispositivos reales (entity=0)
			// mod_provision_lista.php
			'get_device_info' => "SELECT d.id_dev,name,domain,ip,sysloc,sysdesc,sysoid,type,status,community,version,host_idx,wbem_user,mac,critic,wbem_pwd,geodata __CUSTOM_FIELDS__ FROM devices d left join devices_custom_data c on d.id_dev=c.id_dev WHERE d.entity=0 ORDER BY name",
         // ---------------------------------------------------------------------------
         // Obtener los perfiles organizativos a los que pertenece un dispositivo
         // mod_provision_lista.php
			'get_organizational_profile_from_device' => "SELECT descr,d.id_cfg_op FROM cfg_organizational_profile c, cfg_devices2organizational_profile d WHERE c.id_cfg_op=d.id_cfg_op AND d.id_dev=__ID_DEV__ AND descr<>'Global'",
         // ---------------------------------------------------------------------------
         // Obtener los perfiles snmp V3 del sistema
         // mod_provision_lista.php
			'get_profiles_snmpv3' => "SELECT id_profile,profile_name FROM profiles_snmpv3",

 /**
	* **************************************************************** *
	* Modulo: mod_tareas.sql
	* **************************************************************** *
	*/


         // ---------------------------------------------------------------------------------------
			// Listado de tareas
			// mod_tareas_lista.php
			'tasks_delete'=>"DROP TEMPORARY TABLE IF EXISTS t1,t2",
			'tasks_create_temp1'=>"CREATE TEMPORARY TABLE t2 (SELECT action,0 AS 'end' FROM qactions WHERE status<3)", // Accion sin acabar
			// 'tasks_create_temp2'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_cfg_task_configured,a.name,a.descr,a.frec,FROM_UNIXTIME(a.date) AS human_date,a.date,a.cron,a.task,a.done,a.exec,a.subtype,a.params,a.atype,IFNULL(t2.end,1) AS end,ifnull(b.descr,'') as docu FROM cfg_task_configured a LEFT JOIN tips b on a.subtype=b.id_ref AND b.position=0 and b.tip_type='cfg_task' LEFT JOIN t2 ON a.subtype=t2.action WHERE a.atype IN (12,13))",
			'tasks_create_temp2'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_cfg_task_configured,a.name,a.descr,a.frec,FROM_UNIXTIME(a.date) AS human_date,a.date,a.cron,a.task,a.done,a.exec,a.subtype,a.params,a.atype,IFNULL(t2.end,1) AS end,ifnull(b.descr,'') as docu,IFNULL(c.id_search_store,'') AS id_search_store FROM cfg_task_configured a LEFT JOIN tips b on a.subtype=b.id_ref AND b.position=0 and b.tip_type='cfg_task' LEFT JOIN t2 ON a.subtype=t2.action LEFT JOIN search_store2cfg_task c ON a.id_cfg_task_configured=c.id_cfg_task_configured WHERE a.atype IN (12,13))",
			'tasks_all'=>"SELECT * FROM t1",
			'tasks_update'=>"UPDATE t1 set cron='__CRON__' WHERE id='__ID__'",
			'tasks_select'=> "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'tasks_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

			'tasks_all_subtype'=>"SELECT DISTINCT(subtype) AS subtype FROM cfg_monitor_apps",
			'tasks_all_apptype'=>"SELECT DISTINCT(apptype) AS apptype FROM cfg_monitor_apps",
         // ---------------------------------------------------------------------------------------
			// Nombre de una tarea configurada
			// mod_tareas_layout.php
			'task_name'=>"SELECT * FROM cfg_task_configured WHERE id_cfg_task_configured=__ID_CFG_TASK_CONFIGURED__",
         // ---------------------------------------------------------------------------------------
			// Informacion de una tarea configurada en base a su subtype
			// mod_tareas_detalle.php
			'task_info'=>"SELECT * from cfg_task_configured WHERE subtype='__SUBTYPE__'",
			'task_info_by_id'=>"SELECT a.id_cfg_task_configured,a.name,a.descr,a.frec,a.date,a.cron,a.task,a.done,a.exec,a.subtype,a.params,a.atype,b.iptab FROM cfg_task_configured a,cfg_monitor_apps b WHERE a.id_cfg_task_configured IN (__ID_CFG_TASK_CONFIGURED__) AND a.task=b.aname",
			'cnm_cfg_task_app_list'=>"SELECT id_monitor_app,type,subtype,itil_type,apptype,name,descr,cmd,params,myrange,cfg,platform,script,format,enterprise,custom,aname,res,ipparam,iptab,ready FROM cfg_monitor_apps ",
         // ---------------------------------------------------------------------------------------
         // Informacion de una tarea configurada en base a su subtype
         // mod_tareas_detalle.php
         'task_info_ipparam'=>"SELECT a.params, b.ipparam from cfg_task_configured a, cfg_monitor_apps b WHERE a.subtype='__SUBTYPE__' AND a.task=b.aname",

         // ---------------------------------------------------------------------------------------
			// Informacion de los dispositivos asociados a una tarea configurada
			// mod_tareas_dispositivo.php
			'devices_task'=>"SELECT d.id_dev,d.name,d.ip,'1' as asoc,type,status FROM devices d WHERE d.id_dev IN (SELECT id_dev FROM task2device WHERE name LIKE '__SUBTYPE__' AND type='device') UNION SELECT d.id_dev,d.name,d.ip,'0',d.type,d.status as asoc FROM devices d WHERE d.id_dev NOT IN (SELECT id_dev FROM task2device WHERE name LIKE '__SUBTYPE__' AND type='device')",
			'all_devices_task'=>"SELECT id_dev FROM task2device WHERE name LIKE '__SUBTYPE__' AND type='device'",
         // ---------------------------------------------------------------------------------------
         // Asociar un dispositivo a una tarea configurada
         // mod_tareas_dispositivo.php
         'task_asoc'=>"INSERT IGNORE INTO task2device (name,id_dev,ip) SELECT '__SUBTYPE__',id_dev,ip FROM devices WHERE id_dev IN(__ID_DEV__)",
         // ---------------------------------------------------------------------------------------
         // Desasociar un dispositivo de una tarea configurada
         // mod_tareas_dispositivo.php
         'task_unasoc'=>"DELETE FROM task2device WHERE name='__SUBTYPE__' AND id_dev=__ID_DEV__ AND type='device'",
         // ---------------------------------------------------------------------------------------
         // ---------------------------------------------------------------------------------------
         // Borrar una entrada de la documentacion a partir de su id_tip
         // mod_dispositivo_documentacion.php
         'delete_tip'=>"DELETE FROM tips WHERE id_tip IN (__ID_TIP__)",
         // ---------------------------------------------------------------------------------------
         // Insertar una entrada en la documentacion
         // mod_dispositivo_documentacion.php
         'insert_tip'=>"INSERT INTO tips (descr,id_ref,tip_type,date,name) VALUES ('__DESCR__','__ID_REF__','__TIP_TYPE__',__DATE__,'__NAME__')",
         // ---------------------------------------------------------------------------------------
         // Actualizar una entrada de la documentacion
         // mod_dispositivo_documentacion.php
         'edit_tip'=>"UPDATE tips SET descr='__DESCR__',date=__DATE__,name='__NAME__' WHERE id_tip=__ID_TIP__",
         // ---------------------------------------------------------------------------------------
			// Eliminar tareas configuradas del sistema
			// mod_tareas_lista.php
			'delete_task'=>"DELETE FROM cfg_task_configured WHERE id_cfg_task_configured IN (__ID_CFG_TASK_CONFIGURED__)",
			'devices_task_by_id'=>"SELECT id_dev FROM task2device a,cfg_task_configured b WHERE b.subtype=a.name AND b.id_cfg_task_configured IN (__ID_CFG_TASK_CONFIGURED__) AND a.type='device'",
			'exec_task'=>"UPDATE cfg_task_configured SET exec=1 WHERE id_cfg_task_configured IN (__ID_CFG_TASK_CONFIGURED__)",
         // ---------------------------------------------------------------------------------------
         // Crear una aplicación en el sistema
         // mod_tareas_nueva.php
         'create_app'=>"INSERT INTO cfg_monitor_apps (type,subtype,name,descr,cmd,platform,script,itil_type,custom,params,aname,ipparam,iptab,ready,id_proxy,apptype,format) values ('__TYPE__','__SUBTYPE__','__NAME__','__DESCR__','__CMD__','__PLATFORM__','__SCRIPT__','__ITIL_TYPE__',1,'__PARAMS__','__ANAME__','__IPPARAM__',__IPTAB__,1,__ID_PROXY__,'__APPTYPE__','__FORMAT__')",
         'create_app_aux'=>"INSERT INTO cfg_monitor_apps (type,subtype,name,descr,cmd,platform,script,itil_type,custom,params,aname,ipparam,iptab,ready,apptype,myrange,format) values ('__TYPE__','__SUBTYPE__','__NAME__','__DESCR__','__CMD__','__PLATFORM__','__SCRIPT__','__ITIL_TYPE__',1,'__PARAMS__','__ANAME__','__IPPARAM__',__IPTAB__,1,'__APPTYPE__','__MYRANGE__','__FORMAT__')",
         // ---------------------------------------------------------------------------------------
         // Modificar una tarea en el sistema
         // mod_tareas_nueva.php
         'mod_app'=>"UPDATE cfg_monitor_apps SET type='__TYPE__',subtype='__SUBTYPE__',name='__NAME__',descr='__DESCR__',cmd='__CMD__',platform='__PLATFORM__',script='__SCRIPT__',itil_type='__ITIL_TYPE__',custom=1,params='__PARAMS__',ipparam='__IPPARAM__',iptab=__IPTAB__,id_proxy=__ID_PROXY__,apptype='__APPTYPE__',ready=1,format='__FORMAT__' WHERE id_monitor_app=__ID_MONITOR_APP__",
			// ---------------------------------------------------------------------------------------
         // Obtener el listado de aplicaciones disponibles
         // mod_tareas_nueva.php
			'get_apps'=>"SELECT * FROM cfg_monitor_apps ORDER BY name",
			'get_apps_by_script'=>"SELECT * FROM cfg_monitor_apps WHERE script='__SCRIPT__'",
			'get_tasks_by_script'=>"SELECT b.* FROM cfg_monitor_apps a,cfg_task_configured b WHERE a.aname=b.task AND a.script='__SCRIPT__'",
         // ---------------------------------------------------------------------------------------
			'get_apps_audit'=>"SELECT * FROM cfg_monitor_apps WHERE format=3",
			'get_tasks_apps_audit'=>"SELECT b.* FROM cfg_monitor_apps a,cfg_task_configured b WHERE a.aname=b.task AND a.format=3",

			// ---------------------------------------------------------------------------------------
	      // Crear nueva tarea soportada
			// mod_tareas_nueva.php
   	   'new_task_supported'=>"INSERT INTO cfg_task_supported (name,type,descr,script,sep,dev,res,custom) VALUES ('__NAME__','__TYPE__','__DESCRIPTION__','__SCRIPT__','__SEP__',__DISP_ASOC__,1,1)",
			// ---------------------------------------------------------------------------------------
         // Obtener informacion de una tarea dada
         // mod_tareas_lista.php mod_tareas_app.php
			'get_info_app'=>"SELECT * FROM cfg_monitor_apps WHERE aname='__ANAME__'",
			// ---------------------------------------------------------------------------------------
         // Borrar una aplicacion a partir de su id_monitor_app
         // mod_tareas_lista.php
			'delete_app'=>"DELETE FROM cfg_monitor_apps WHERE aname='__ANAME__'",
         // ---------------------------------------------------------------------------------------
         // Crear nueva tarea
         // mod_tareas_detalle.php
         'new_task_configured'=>"INSERT INTO cfg_task_configured (name,frec,date,cron,subtype,atype,task,role,user) VALUES ('__NAME__','__FREC__','__DATE__','__CRON__','__SUBTYPE__',12,'__TASK__','__ROLE__','__USER__')",
         // ---------------------------------------------------------------------------------------
         // Modificar una tarea
         // mod_tareas_detalle.php
         'mod_task_configured'=>"UPDATE cfg_task_configured SET name='__NAME__',frec='__FREC__',date='__DATE__',cron='__CRON__',task='__TASK__' WHERE id_cfg_task_configured=__ID_CFG_TASK_CONFIGURED__",
			'exec_app'=>"INSERT INTO cfg_task_configured (name,descr,frec,date,task,subtype,params,atype,exec,user) VALUES ('__NAME__','__DESCR__','__FREC__','__DATE__','__TASK__','__SUBTYPE__','__PARAMS__',__ATYPE__,__EXEC__,'__USER__')",
         // ---------------------------------------------------------------------------------------
         // Comprobar si una tarea tiene resultados
         // mod_tareas_layout.php
         'task_result'=>"SELECT a.res FROM cfg_monitor_apps a, cfg_task_configured b WHERE a.aname=b.task AND b.subtype='__SUBTYPE__'",
         // ---------------------------------------------------------------------------------------
         // Obtener el listado de resultados de una tarea
         // mod_tareas_resultado.php
         'list_res_task'=>"SELECT a.name,c.descr,c.task,c.done,a.rcstr,c.subtype,from_unixtime(a.date_end)as date,a.status FROM cfg_task_configured c, qactions a WHERE a.action=c.subtype AND c.subtype='__SUBTYPE__' order by a.date_end desc",
         // ---------------------------------------------------------------------------------------
         // Obtener los datos de una entrada de la tabla qactions a partir de su name
         // mod_tareas_resultado.php
			'qactions_info'=>"SELECT * FROM qactions WHERE name='__NAME__'",
         // ---------------------------------------------------------------------------------------
         // Borrar de qactions la entrada del resultado de una tarea
         // mod_tareas_resultado.php
			'task_res_delete'=>"DELETE FROM qactions WHERE name='__NAME__'",
// ---------------------------------------------------------------------------------------
         // Ejecutar ahora una tarea
         // mod_tareas_detalle.php
         'task_exec_now'=>"UPDATE cfg_task_configured SET exec=1 WHERE subtype='__SUBTYPE__'",
	
 /**
	* **************************************************************** *
	* Modulo: mod_snmp.sql
	* **************************************************************** *
	*/

/**
   * **************************************************************** *
   Modulo: mod_snmp.sql

   mod_snmp_layout.php        shtml/mod_snmp_layout.shtml
   mod_snmp_detalle.php       shtml/mod_snmp_detalle_ro_con_iids.shtml
										shtml/mod_snmp_detalle_ro_especial.shtml	
										shtml/mod_snmp_detalle_ro_sin_iids.shtml
										shtml/mod_snmp_detalle_rw_con_iids.shtml
										shtml/mod_snmp_detalle_rw_especial.shtml
										shtml/mod_snmp_detalle_rw_sin_iids.shtml

   mod_snmp_dispositivo.php    shtml/mod_snmp_dispositivo.shtml
   mod_snmp_documentacion.php  shtml/mod_snmp_documentacion.shtml
   * **************************************************************** *
*/

         'cnm_cfg_snmp_get_class'=>"SELECT DISTINCT(class) AS class FROM cfg_monitor_snmp order by class",
         'cnm_cfg_snmp_get_apptype'=>"SELECT DISTINCT(apptype) AS apptype FROM cfg_monitor_snmp order by apptype",

         'cnm_cfg_snmp_delete_temp'=>"DROP TEMPORARY TABLE t1,t2",
         'cnm_cfg_snmp_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_cfg_monitor_snmp,a.subtype,a.descr as name,a.cfg,a.severity,a.custom,a.class,a.lapse,ifnull(c.descr,'') as descr,(SELECT ifnull(count(d.id_tm2iid),0) FROM prov_template_metrics2iid d,prov_template_metrics e WHERE e.subtype=a.subtype AND d.id_template_metric=e.id_template_metric and d.status=0)as cuantos,ifnull(c.descr,'') as docu FROM cfg_monitor_snmp a LEFT JOIN tips c on a.subtype=c.id_ref and c.tip_type='cfg' and c.tip_class=1)",
         'cnm_cfg_snmp_create_temp1' => "CREATE TEMPORARY TABLE t2 (SELECT count(id_tm2iid) AS cuantos,subtype FROM prov_template_metrics a, prov_template_metrics2iid b WHERE a.id_template_metric=b.id_template_metric AND b.status=0 GROUP BY subtype)",
         'cnm_cfg_snmp_create_temp2' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_cfg_monitor_snmp,a.subtype,a.descr as name,a.cfg,a.severity,a.custom,a.class,a.apptype,a.lapse,ifnull(b.descr,'') as descr,ifnull(t2.cuantos,0) AS cuantos,ifnull(b.descr,'') as docu,a.esp FROM cfg_monitor_snmp a LEFT JOIN tips b on a.subtype=b.id_ref AND b.tip_type='cfg' AND b.position=0 LEFT JOIN t2 ON a.subtype=t2.subtype)",
// OJO cfg>0 porque existen metricas dadas de alta como sin respuesta snmp que no deben ser visibles. 
// Solo estan por consistencia de datos.
         'cnm_cfg_snmp_get_list' => "SELECT id_cfg_monitor_snmp,subtype,name,cfg,severity,custom,class,lapse,descr,cuantos,docu,esp,apptype FROM t1 WHERE ''='' AND cfg>0 __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_cfg_snmp_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' AND cfg>0 __CONDITION__",




         // ---------------------------------------------------------------------------------------
         // Informacion de una metrica en base a su id_cfg_monitor_snmp
         // mod_snmp_layout.php
         'info_snmp'=>"SELECT * FROM cfg_monitor_snmp WHERE id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__",
         'info_snmp1'=>"SELECT  subtype,class,descr,items,vlabel,oid,mode,oidn,get_iid FROM cfg_monitor_snmp WHERE id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__",
         //'info_snmp2'=>"SELECT mode FROM cfg_monitor_snmp WHERE id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__",

			
         'cnm_cfg_snmp_get_info_by_id'=>"SELECT subtype,class,descr,descr as description,items,vlabel,oid,oid_info,module,mode,oidn,get_iid,mode,params,esp,lapse,mtype,apptype,top_value,cfg,custom,myrange,enterprise,include,itil_type,apptype FROM cfg_monitor_snmp WHERE id_cfg_monitor_snmp IN (__ID_CFG_MONITOR_SNMP__)",
         'cnm_cfg_snmp_get_info_by_subtype'=>"SELECT id_cfg_monitor_snmp,subtype,class,descr,descr as description,items,vlabel,oid,oid_info,module,mode,oidn,get_iid,mode,params,esp,lapse,mtype,apptype,top_value,cfg,custom,myrange,enterprise,include,itil_type,apptype FROM cfg_monitor_snmp WHERE subtype='__SUBTYPE__'",
			'cnm_cfg_snmp_get_all_id'=>"SELECT id_cfg_monitor_snmp FROM cfg_monitor_snmp",


			// ---------------------------------------------------------------------------------------
			// Modificar el subtype de una metrica que esta en plantilla. Esto se hace cuando se regenera una metrica
			// snmp y no se quieren perder las asociaciones
			// mod_snmp_detalle.php
			'cnm_cfg_snmp_change_subtype'=>"UPDATE prov_template_metrics SET subtype='__SUBTYPE_NEW__' WHERE subtype='__SUBTYPE_OLD__'",

         // ---------------------------------------------------------------------------------------
         // Obtener el subtype de un listado de metricas snmp por su id_cfg_monitor_snmp
         // mod_snmp_lista.php
         'subtype_from_id'=>"SELECT subtype FROM cfg_monitor_snmp WHERE id_cfg_monitor_snmp IN (__ID_CFG_MONITOR_SNMP__)",

         // ---------------------------------------------------------------------------------------
         // Listado de metricas snmp
         // mod_snmp_lista.php
			'snmp_all'=>"SELECT a.id_cfg_monitor_snmp,a.subtype,a.descr as name,a.cfg,a.severity,a.custom,a.class,a.lapse,ifnull(c.descr,'') as descr FROM cfg_monitor_snmp a left join tips c on a.subtype=c.id_ref and c.tip_type='cfg' and c.tip_class=1",
			'snmp_all_instancias'=>"SELECT count(a.id_tm2iid) as cuantos FROM prov_template_metrics2iid a,prov_template_metrics b WHERE b.subtype='__SUBTYPE__' AND a.id_template_metric=b.id_template_metric and a.status=0",

			//'cnm_cfg_snmp_get_list'=>"SELECT a.id_cfg_monitor_snmp,a.subtype,a.descr as name,a.cfg,a.severity,a.custom,a.class,a.lapse,ifnull(c.descr,'') as descr FROM cfg_monitor_snmp a left join tips c on a.subtype=c.id_ref and c.tip_type='cfg' and c.tip_class=1",
			//'cnm_cfg_snmp_get_iid_count_by_subtype'=>"SELECT count(a.id_tm2iid) as cuantos FROM prov_template_metrics2iid a,prov_template_metrics b WHERE b.subtype='__SUBTYPE__' AND a.id_template_metric=b.id_template_metric and a.status=0",


         // ---------------------------------------------------------------------------------------
         // ---------------------------------------------------------------------------------------
			'cnm_cfg_snmp_get_esp_info'=>"SELECT name,description,oid,class,module,fx,items,vlabel,mode,label,mtype,get_iid,info,iparams,myrange from cfg_monitor_snmp_esp where name='__NAME__'",

			'cnm_cfg_snmp_esp_store_update'=>"UPDATE cfg_monitor_snmp SET subtype='__SUBTYPE__', descr='__DESCRIPTION__', class='__CLASS__', oid='__OID__', oidn='__OIDN__', items='__ITEMS__', label='__LABEL__', vlabel='__VLABEL__' ,mode='__MODE__', get_iid='__GET_IID__', mtype='__MTYPE__', module='__MODULE_EXT__', oid_info='__OID_INFO__', cfg=3, myrange='__RANGE__', esp='__ESP__', custom=1, params='__PARAMS__', lapse=__LAPSE__,apptype='__APPTYPE__' WHERE id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__",

			'cnm_cfg_snmp_esp_store_insert'=>"INSERT INTO cfg_monitor_snmp (subtype,lapse,descr,class,oid,oidn,items,label,vlabel,mode,get_iid,mtype,module,oid_info,cfg,myrange,esp,custom,params,apptype) VALUES ('__SUBTYPE__',__LAPSE__,'__DESCRIPTION__','__CLASS__','__OID__','__OIDN__','__ITEMS__','__LABEL__','__VLABEL__','__MODE__','__GET_IID__','__MTYPE__','__MODULE_EXT__', '__OID_INFO__', 3, '__RANGE__','__ESP__',1,'__PARAMS__','__APPTYPE__')",







         // ---------------------------------------------------------------------------------------
         // Obtener los dispositivos asociados a un metrica de tipo snmp sin instancias
         // mod_snmp_dispositivo_no_instancias.php
         'devices_snmp_no_instancias'=>"SELECT d.id_dev,d.name,d.ip,'1' as asoc,type,status FROM devices d WHERE id_dev in (SELECT id_dev FROM prov_template_metrics2iid a,cfg_monitor_snmp b WHERE a.mname=b.subtype AND a.status=0 AND b.id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__) UNION SELECT d.id_dev,d.name,d.ip,'0' as asoc,type,status FROM devices d WHERE id_dev NOT in (SELECT id_dev FROM prov_template_metrics2iid a,cfg_monitor_snmp b WHERE a.mname=b.subtype AND a.status=0 AND b.id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__)",
         // ---------------------------------------------------------------------------------------
         // Obtener los dispositivos asociados a una metrica snmp con instancias
         // mod_snmp_dispositivo_si_instancias.php
			'all_devices'=>"SELECT * FROM devices",
         'devices_snmp_si_instancias'=>"SELECT count(DISTINCT id_tm2iid) as cuantos FROM cfg_monitor_snmp a, prov_template_metrics b, prov_template_metrics2iid c WHERE a.id_cfg_monitor_snmp='__ID_CFG_MONITOR_SNMP__' AND a.subtype=b.subtype AND b.id_dev=__ID_DEV__ AND b.id_template_metric=c.id_template_metric AND c.status=0 group by b.id_dev",
         // ---------------------------------------------------------------------------------------
         // Desasociar dispositivos a una metrica snmp sin instancias
         // mod_snmp_dispositivo_no_instancias.php
			'snmp_unasoc_no_instancias'=>"DELETE FROM prov_template_metrics2iid WHERE id_dev=__ID_DEV__ AND mname=(SELECT subtype FROM cfg_monitor_snmp WHERE id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__) AND id_dev=__ID_DEV__",
         // ---------------------------------------------------------------------------------------
         // Desasociar dispositivos a una metrica snmp con instancias
         // mod_snmp_dispositivo_si_instancias.php
			'snmp_unasoc_si_instancias'=>"UPDATE prov_template_metrics2iid SET status=1 WHERE id_dev=__ID_DEV__ AND iid='__IID__' AND id_template_metric=(SELECT id_template_metric FROM prov_template_metrics a, cfg_monitor_snmp b WHERE b.id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__ AND a.subtype=b.subtype AND a.id_dev=__ID_DEV__)",
			'xagent_unasoc_si_instancias'=>"UPDATE prov_template_metrics2iid SET status=1 WHERE id_dev=__ID_DEV__ AND iid='__IID__' AND id_template_metric=(SELECT id_template_metric FROM prov_template_metrics a, cfg_monitor_agent b WHERE b.id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__ AND a.subtype=b.subtype AND a.id_dev=__ID_DEV__)",
			'snmp_get_id_metric_from_cfg_metric_sin_iids'=>"SELECT id_metric FROM  metrics m, cfg_monitor_snmp c WHERE c.subtype=m.subtype and c.id_cfg_monitor_snmp IN (__ID_CFG_MONITOR_SNMP__) and m.id_dev IN (__ID_DEV__) and m.iid IN ('ALL','TABLE')",
			'snmp_get_id_metric_from_cfg_metric'=>"SELECT id_metric FROM  metrics m, cfg_monitor_snmp c WHERE c.subtype=m.subtype and c.id_cfg_monitor_snmp IN (__ID_CFG_MONITOR_SNMP__) and m.id_dev IN (__ID_DEV__) and m.iid='__IID__'",
			'xagent_get_id_metric_from_cfg_metric'=>"SELECT id_metric FROM metrics m, cfg_monitor_agent c WHERE c.subtype=m.subtype and c.id_cfg_monitor_agent IN (__ID_CFG_MONITOR_AGENT__) and m.id_dev IN (__ID_DEV__) and m.iid='__IID__'",
// 0 es activa||1 es desactivada
			// ---------------------------------------------------------------------------------------
         // Obtener la ip de un dispositivo
         // mod_snmp_dispositivo_no_instancias.php
			// ---------------------------------------------------------------------------------------
			// Obtener los mnames de las instancias de una metrica snmp con instancias en base a un id_cfg_monitor_snmp y un id_dev
			// mod_snmp_dispositivo_si_instancias.php
			'instances_metric_device'=>"SELECT a.iid FROM prov_template_metrics2iid a, prov_template_metrics b,cfg_monitor_snmp c WHERE a.id_dev=__ID_DEV__ AND a.id_template_metric=b.id_template_metric AND b.type='snmp' and c.subtype=b.subtype and c.id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__ AND a.status=0",
			'cnm_cfg_snmp_get_metric_instances_by_device'=>"SELECT a.iid,a.hiid,a.id_dev,a.label FROM prov_template_metrics2iid a, prov_template_metrics b,cfg_monitor_snmp c WHERE a.id_dev IN (__ID_DEV__) AND a.id_template_metric=b.id_template_metric AND b.type='snmp' and c.subtype=b.subtype and c.id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__ AND a.status=0",
			'cnm_cfg_xagent_get_metric_instances_by_device'=>"SELECT a.iid,a.hiid,a.id_dev,a.label FROM prov_template_metrics2iid a, prov_template_metrics b,cfg_monitor_agent c WHERE a.id_dev IN (__ID_DEV__) AND a.id_template_metric=b.id_template_metric AND b.type='xagent' and c.subtype=b.subtype and c.id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__ AND a.status=0",
			'cnm_cfg_snmp_get_metric_instances_by_device_and_status'=>"SELECT a.iid,a.id_dev,a.label,a.status FROM prov_template_metrics2iid a, prov_template_metrics b,cfg_monitor_snmp c WHERE a.id_dev IN (__ID_DEV__) AND a.id_template_metric=b.id_template_metric AND b.type='snmp' and c.subtype=b.subtype and c.id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__",
			'cnm_cfg_xagent_get_metric_instances_by_device_and_status'=>"SELECT a.iid,a.id_dev,a.label,a.status FROM prov_template_metrics2iid a, prov_template_metrics b,cfg_monitor_agent c WHERE a.id_dev IN (__ID_DEV__) AND a.id_template_metric=b.id_template_metric AND b.type='xagent' and c.subtype=b.subtype and c.id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__ ORDER BY a.label",
         // ---------------------------------------------------------------------------------------
         // Borrar una entrada de la documentacion a partir de su id_tip
         // mod_snmp_documentacion.php
         'delete_tip'=>"DELETE FROM tips WHERE id_tip IN (__ID_TIP__)",
         // ---------------------------------------------------------------------------------------
         // Insertar una entrada en la documentacion
         // mod_snmp_documentacion.php
         'insert_tip'=>"INSERT INTO tips (descr,id_ref,tip_type,date,name) VALUES ('__DESCR__','__ID_REF__','__TIP_TYPE__',__DATE__,'__NAME__')",
         // ---------------------------------------------------------------------------------------
         // Actualizar una entrada de la documentacion
         // mod_snmp_documentacion.php
         'edit_tip'=>"UPDATE tips SET descr='__DESCR__',date=__DATE__,name='__NAME__' WHERE id_tip=__ID_TIP__",
         // ---------------------------------------------------------------------------------------
         // Listado de monitores de una metrica de tipo snmp
         // mod_snmp_monitor.php
         'all_monitor'=>"SELECT b.id_alert_type,b.cause,b.expr,b.severity FROM cfg_monitor_snmp a, alert_type b WHERE a.id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__ AND a.subtype=b.mname",
			// ---------------------------------------------------------------------------------------
         // Información de un monitor
         // mod_snmp_monitor.php
         'info_monitor'=>"SELECT b.id_alert_type,b.cause,b.expr,b.severity,a.items FROM cfg_monitor_snmp a, alert_type b WHERE a.subtype=b.mname AND b.id_alert_type=__ID_ALERT_TYPE__",
			// ---------------------------------------------------------------------------------------
         // Obtener el id_alert_type de un monitor
         // mod_snmp_monitor.php
			// ---------------------------------------------------------------------------------------
			'get_id_monitor'=>"SELECT id_alert_type FROM alert_type WHERE monitor='__MONITOR__'",
			'get_all_monitor'=>"SELECT * FROM alert_type WHERE monitor='__MONITOR__'",
			// ---------------------------------------------------------------------------------------
         // Crear un monitor
         // mod_snmp_monitor.php
			'create_monitor'=>"INSERT INTO alert_type (cause,monitor,expr,severity,mname,type,subtype) values ('__CAUSE__','__MONITOR__','__EXPR__',__SEVERITY__,'__MNAME__','__TYPE__','__SUBTYPE__')",
			// ---------------------------------------------------------------------------------------
         // Modificar un monitor
         // mod_snmp_monitor.php
			'modify_monitor'=>"UPDATE alert_type SET cause='__CAUSE__',expr='__EXPR__',severity=__SEVERITY__ WHERE id_alert_type='__ID_ALERT_TYPE__'",
			// ---------------------------------------------------------------------------------------
         // Borrar un monitor
         // mod_snmp_monitor.php
			'delete_monitor'=>"DELETE FROM alert_type WHERE id_alert_type='__ID_ALERT_TYPE__'",
			// ---------------------------------------------------------------------------------------
         // Obtener los diferentes tipos dentro de las metricas de tipo especial
         // mod_snmp_detalle_especial.php
			'all_snmp_esp'=>"SELECT * from cfg_monitor_snmp_esp",
			'info_snmp_esp'=>"SELECT name,description,info from cfg_monitor_snmp_esp",
			'cnm_cfg_snmp_get_esp_repository'=>"SELECT name,description,info from cfg_monitor_snmp_esp",
			
			
			// ---------------------------------------------------------------------------------------
         // Obtener las diferentes clases definidas en la tabla cfg_monitor_snmp
			//'get_snmp_clases'=>"SELECT distinct class FROM cfg_monitor_snmp",
			'cnm_cfg_snmp_get_all_classes'=>"SELECT distinct class FROM cfg_monitor_snmp",

			// ---------------------------------------------------------------------------------------
         // Obtener los valores que se parametrizan en una metrica snmp de la tabla cfg_monitor_snmp
			//'get_snmp_params'=>"SELECT oid,items,oidn,get_iid FROM cfg_monitor_snmp WHERE id_cfg_monitor_snmp='__ID_CFG_MONITOR_SNMP__'",


			// ---------------------------------------------------------------------------------------
         // Crea metrica (de usuario)  en tabla cfg_monitor_snmp
			//'create_snmp_metric'=>"INSERT INTO cfg_monitor_snmp (subtype,lapse,descr,class,oid,oidn,items,label,vlabel,mode,get_iid,mtype,oid_info,cfg,custom,myrange,enterprise) VALUES ('__SUBTYPE__',__LAPSE__,'__DESCR__','__CLASS__','__OID__','__OIDN__','__ITEMS__','__LABEL__','__VLABEL__','__MODE__','__GET_IID__','__MTYPE__','__INFO__',__CFG__,1,'__RANGE__',__ENTERPRISE__)",
			'cnm_cfg_snmp_store_create'=>"INSERT INTO cfg_monitor_snmp (subtype,lapse,descr,class,oid,oidn,items,label,vlabel,mode,get_iid,mtype,oid_info,cfg,custom,myrange,enterprise,esp,apptype,params) VALUES ('__SUBTYPE__',__LAPSE__,'__DESCR__','__CLASS__','__OID__','__OIDN__','__ITEMS__','__LABEL__','__VLABEL__','__MODE__','__GET_IID__','__MTYPE__','__INFO__',__CFG__,1,'__RANGE__',__ENTERPRISE__,'__ESP__','__APPTYPE__','__PARAMS__')",


			// ---------------------------------------------------------------------------------------
         // Actualiza metrica (de usuario)  en tabla cfg_monitor_snmp
         //'update_snmp_metric'=>"UPDATE cfg_monitor_snmp SET subtype='__SUBTYPE__', descr='__DESCR__', class='__CLASS__', oid='__OID__', oidn='__OIDN__', items='__ITEMS__', vlabel='__VLABEL__' ,mode='__MODE__', get_iid='__GET_IID__', mtype='__MTYPE__', oid_info='__INFO__', cfg=__CFG__, myrange='__RANGE__', enterprise=__ENTERPRISE__ WHERE id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__",
         'cnm_cfg_snmp_store_update'=>"UPDATE cfg_monitor_snmp SET subtype='__SUBTYPE__', descr='__DESCR__', class='__CLASS__', oid='__OID__', oidn='__OIDN__', items='__ITEMS__', vlabel='__VLABEL__' ,mode='__MODE__', get_iid='__GET_IID__', mtype='__MTYPE__', oid_info='__INFO__', cfg=__CFG__, myrange='__RANGE__', enterprise=__ENTERPRISE__, esp='__ESP__', apptype='__APPTYPE__', params='__PARAMS__' WHERE id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__",
         // ---------------------------------------------------------------------------------------
         // Actualiza tip base de documentacion
         'update_snmp_base_tip'=>"INSERT INTO tips (id_ref,tip_type,url,date,tip_class,name,descr) VALUES ('__SUBTYPE__', 'cfg', '__URL__', '__DATE__', '__TIP_CLASS__', '__NAME__', '__DESCR__') ON DUPLICATE KEY UPDATE id_ref='__SUBTYPE__', tip_type='cfg', url='__URL__', date='__DATE__', tip_class='__TIP_CLASS__', name='__NAME__', descr='__DESCR__'",


         // ---------------------------------------------------------------------------------------
         // ---------------------------------------------------------------------------------------
         'cnm_cfg_snmp_get_included_devices_by_id'=>"SELECT id_dev FROM prov_template_metrics2iid a,cfg_monitor_snmp b WHERE a.mname=b.subtype AND b.id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__",

         // ---------------------------------------------------------------------------------------
         // ---------------------------------------------------------------------------------------
         // 'cnm_cfg_snmp_get_metric_count_by_device_and_subtype'=>"SELECT count(*) as counter from metrics where type='snmp' and status=0 and id_dev=__ID_DEV__ and subtype=(SELECT subtype FROM cfg_monitor_snmp WHERE id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__)",
         'cnm_cfg_snmp_get_metric_count_by_device_and_subtype'=>"SELECT count(*) as counter from prov_template_metrics2iid a, prov_template_metrics b,cfg_monitor_snmp c WHERE a.id_dev=__ID_DEV__ AND a.id_template_metric=b.id_template_metric AND b.type='snmp' and c.subtype=b.subtype and c.id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__ AND a.status=0",


/**
   * **************************************************************** *
   Modulo: mod_latency.sql

   mod_latency_layout.php         shtml/mod_latency_layout.shtml
   mod_latency_lista.php

   mod_latency_detalle.php        shtml/mod_latency_detalle.shtml
   mod_latency_dispositivo.php    shtml/mod_latency_dispositivo.shtml
   mod_latency_documentacion.php  shtml/mod_latency_documentacion.shtml
   * **************************************************************** *
*/

// ---------------------------------------------------------------------------------------
// mod_latency_layout.php
// ---------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------
// mod_latency_lista.php
// ---------------------------------------------------------------------------------------
	
   // ---------------------------------------------------------------------------------------
   // Listado de metricas tcp/ip
   // mod_tcpip_lista.php
   'get_latency_metrics_configured_list'=>"SELECT a.id_cfg_monitor,a.monitor,a.description,a.severity,ifnull(c.descr,'') as descr,a.subtype,a.cfg,a.custom FROM cfg_monitor a LEFT JOIN tips c on a.monitor=c.id_ref and c.tip_type='latency' and c.tip_class=1 WHERE a.cfg=1 and a.monitor NOT IN ('mon_snmp','mon_xagent') order by a.cfg desc,a.description",
   'get_latency_metrics_repository'=>"SELECT a.id_cfg_monitor,a.monitor,a.description,ifnull(c.descr,'') as descr,a.subtype FROM cfg_monitor a LEFT JOIN tips c on a.monitor=c.id_ref and c.tip_type='latency' and c.tip_class=1 WHERE a.cfg=0 and a.monitor NOT IN ('mon_snmp','mon_xagent') order by a.cfg desc,a.description",
   'get_latency_metrics_in_use_by_subtype'=>"SELECT count(a.id_tm2iid) as cuantos FROM prov_template_metrics2iid a,prov_template_metrics b WHERE b.subtype='__SUBTYPE__' AND a.id_template_metric=b.id_template_metric and a.status=0",


   'cnm_cfg_latency_get_repository'=>"SELECT a.id_cfg_monitor,a.monitor,a.description,ifnull(c.descr,'') as descr,a.subtype,a.apptype FROM cfg_monitor a LEFT JOIN tips c on a.monitor=c.id_ref and c.tip_type='latency' and c.tip_class=1 WHERE a.cfg=0 and a.monitor NOT IN ('mon_snmp','mon_xagent') order by a.cfg desc,a.description",

// ---------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------

         // ---------------------------------------------------------------------------------------
         // Informacion de una metrica en base a su id_cfg_monitor
         'info_latency1'=>"SELECT id_cfg_monitor,monitor,description,info,severity,cfg,subtype,apptype FROM cfg_monitor WHERE id_cfg_monitor=__ID_CFG_MONITOR__",

         'info_latency2'=>"SELECT id_cfg_monitor,monitor,port,items,mtype,vlabel,module,itil_type,lapse,include,top_value,mode FROM cfg_monitor WHERE id_cfg_monitor=__ID_CFG_MONITOR__",

         'info_latency_base'=>"(SELECT description FROM cfg_monitor WHERE subtype='__SUBTYPE__' AND cfg=0) UNION (SELECT description FROM cfg_monitor WHERE description like '%SERVICIO ICMP%' AND subtype='__SUBTYPE__')",

         'get_cfg_monitor_items'=>"SELECT items FROM cfg_monitor WHERE id_cfg_monitor=__ID_CFG_MONITOR__",
			'get_all_latency'=>"SELECT * FROM cfg_monitor WHERE subtype='__SUBTYPE__'",
			'get_all_snmp'=>"SELECT * FROM cfg_monitor_snmp WHERE subtype='__SUBTYPE__'",
			'get_all_agent'=>"SELECT * FROM cfg_monitor_agent WHERE subtype='__SUBTYPE__'",


         'cnm_cfg_latency_get_info_by_id'=>"SELECT id_cfg_monitor,monitor,description,info,severity,shtml,cfg,subtype,apptype,custom,port,items,mtype,vlabel,module,itil_type,lapse,include,top_value,mode,params,subtype AS class FROM cfg_monitor WHERE id_cfg_monitor IN (__ID_CFG_MONITOR__)",
			'cnm_cfg_latency_get_all_id'=>"SELECT id_cfg_monitor FROM cfg_monitor",
         'cnm_cfg_latency_get_info_by_monitor'=>"SELECT id_cfg_monitor,monitor,description,info,severity,shtml,cfg,subtype,apptype,port,items,mtype,vlabel,module,itil_type,lapse,include,top_value,mode,params,custom,subtype AS class FROM cfg_monitor WHERE monitor='__MONITOR__'",
         'cnm_cfg_latency_get_base_metric_of_configured'=>"(SELECT description,info FROM cfg_monitor WHERE subtype='__SUBTYPE__' AND cfg=0) UNION (SELECT description,info FROM cfg_monitor WHERE description like '%SERVICIO ICMP%' AND subtype='__SUBTYPE__')",

         // ---------------------------------------------------------------------------------------
         //Parametros configurables de la metrica definida por su id_cfg_monitor
         // mod_latency_layout.php
         'get_metric_params'=>"SELECT params FROM cfg_monitor WHERE id_cfg_monitor=__ID_CFG_MONITOR__",

			'cnm_cfg_latency_get_types'=>"SELECT DISTINCT(subtype) AS subtype FROM cfg_monitor WHERE cfg=1",
			'cnm_cfg_latency_get_apptypes'=>"SELECT DISTINCT(apptype) AS apptype FROM cfg_monitor WHERE cfg=1",
         'cnm_cfg_latency_delete_temp' => "DROP TEMPORARY TABLE t1,t2",
			'cnm_cfg_latency_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_cfg_monitor,a.monitor,a.description,a.severity,(SELECT ifnull(count(d.id_tm2iid),0) FROM prov_template_metrics2iid d,prov_template_metrics e WHERE d.mname=a.monitor AND d.id_template_metric=e.id_template_metric and d.status=0)as cuantos,ifnull(c.descr,'') as docu,a.subtype,a.cfg,a.custom FROM cfg_monitor a LEFT JOIN tips c on a.monitor=c.id_ref and c.tip_type='latency' and c.tip_class=1 WHERE a.cfg=1 and a.monitor NOT IN ('mon_snmp','mon_xagent'))",
			'cnm_cfg_latency_create_temp1' => "CREATE TEMPORARY TABLE t2 (SELECT count(a.id_tm2iid) AS cuantos,a.mname,b.type FROM prov_template_metrics2iid a,prov_template_metrics b WHERE a.id_template_metric=b.id_template_metric AND b.type='latency' AND a.status=0 GROUP BY a.mname)",
			'cnm_cfg_latency_create_temp2' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_cfg_monitor,a.monitor,a.description,a.severity,ifnull(b.cuantos,0) AS cuantos,ifnull(c.descr,'') as docu,a.subtype,a.apptype,a.cfg,a.custom FROM cfg_monitor a LEFT JOIN t2 b on a.monitor=b.mname LEFT JOIN tips c on a.monitor=c.id_ref and c.tip_type='latency' and c.position=0 WHERE a.cfg=1 and a.monitor NOT IN ('mon_snmp','mon_xagent'))",
         'cnm_cfg_latency_get_list' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_cfg_latency_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",


         // ---------------------------------------------------------------------------------------
			'latency_get_id_metric_from_cfg_metric'=>"SELECT id_metric FROM  metrics m, cfg_monitor c WHERE c.monitor=m.subtype and c.id_cfg_monitor IN (__ID_CFG_MONITOR__) and m.id_dev IN (__ID_DEV__)",

         // ---------------------------------------------------------------------------------------
         // Listado de metricas tcp/ip
         // mod_tcpip_lista.php
			'tcpip_all'=>"SELECT a.id_cfg_monitor,a.monitor,a.description,a.cfg,a.severity,ifnull(c.descr,'') as descr,a.subtype FROM cfg_monitor a LEFT JOIN tips c on a.monitor=c.id_ref and c.tip_type='latency' and c.tip_class=1 WHERE a.monitor NOT IN ('mon_snmp','mon_xagent') order by a.cfg desc,a.description",
			'tcpip_all_instancias'=>"SELECT count(a.id_tm2iid) as cuantos FROM prov_template_metrics2iid a,prov_template_metrics b WHERE b.subtype='__SUBTYPE__' AND a.id_template_metric=b.id_template_metric and a.status=0",
         // ---------------------------------------------------------------------------------------
         // Crear una metrica tcp/ip
         // mod_latency_detalle.php
         'create_metric'=>"INSERT INTO cfg_monitor (monitor,description,port,subtype,params,severity,items,mtype,vlabel,module,top_value,mode,cfg,custom,itil_type,lapse,include) VALUES ('__MONITOR__','__DESCRIPTION__','__PORT__','__SUBTYPE__','__PARAMS__',__SEVERITY__,'__ITEMS__','__MTYPE__','__VLABEL__','__MODULE__','__TOP_VALUE__','__MODE__',1,0,'__ITIL_TYPE__',__LAPSE__,__INCLUSE__) ",
         'cnm_cfg_latency_store_create'=>"INSERT INTO cfg_monitor (monitor,description,port,subtype,params,severity,items,mtype,vlabel,module,top_value,mode,cfg,custom,itil_type,lapse,include,apptype) VALUES ('__MONITOR__','__DESCRIPTION__','__PORT__','__SUBTYPE__','__PARAMS__',__SEVERITY__,'__ITEMS__','__MTYPE__','__VLABEL__','__MODULE__','__TOP_VALUE__','__MODE__',1,1,'__ITIL_TYPE__',__LAPSE__,__INCLUDE__,'__APPTYPE__')",
         // ---------------------------------------------------------------------------------------
         // Modificar una metrica tcp/ip
         // mod_latency_detalle.php
         'modify_metric'=>"UPDATE cfg_monitor SET description='__DESCRIPTION__',info='__INFO__',severity=__SEVERITY__,params='__PARAMS__' WHERE id_cfg_monitor=__ID_CFG_MONITOR__",
         'cnm_cfg_latency_store_update'=>"UPDATE cfg_monitor SET description='__DESCRIPTION__',info='__INFO__',severity=__SEVERITY__,params='__PARAMS__',apptype='__APPTYPE__' WHERE id_cfg_monitor=__ID_CFG_MONITOR__",
         // ---------------------------------------------------------------------------------------
         // Obtener los dispositivos asociados a una metrica de tipo latency
         // mod_latency_dispositivo.php
         // 'all_devices_latency'=>"(SELECT d.id_dev,d.name,d.domain,d.ip,'1' as asoc,type,status FROM devices d WHERE id_dev in (SELECT id_dev FROM prov_template_metrics2iid a,cfg_monitor b WHERE a.mname=b.monitor AND b.id_cfg_monitor=__ID_CFG_MONITOR__) __CONDITION__) UNION (SELECT d.id_dev,d.name,d.domain,d.ip,'0' as asoc,type,status FROM devices d WHERE id_dev NOT in (SELECT id_dev FROM prov_template_metrics2iid a,cfg_monitor b WHERE a.mname=b.monitor AND b.id_cfg_monitor=__ID_CFG_MONITOR__) __CONDITION__) ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'all_devices_latency'=>"SELECT id_dev FROM prov_template_metrics2iid a,cfg_monitor b WHERE a.mname=b.monitor AND b.id_cfg_monitor=__ID_CFG_MONITOR__",
         // ---------------------------------------------------------------------------------------
         // Desasociar dispositivos a una metrica
         // mod_latency_dispositivo.php
			// 'latency_unasoc'=>"DELETE FROM metrics WHERE subtype=(SELECT monitor FROM cfg_monitor WHERE id_cfg_monitor=__ID_CFG_MONITOR__) AND id_dev=__ID_DEV__",
			// 'latency_unasoc'=>"DELETE FROM prov_template_metrics2iid WHERE mname=(SELECT monitor FROM cfg_monitor WHERE id_cfg_monitor=__ID_CFG_MONITOR__) AND id_dev=__ID_DEV__",
			//'latency_unasoc'=>"DELETE FROM prov_template_metrics2iid WHERE mname=(SELECT monitor FROM cfg_monitor WHERE id_cfg_monitor=__ID_CFG_MONITOR__) AND id_dev IN (__ID_DEV__)",
			'latency_unasoc'=>"UPDATE prov_template_metrics2iid SET status=1 WHERE mname=(SELECT monitor FROM cfg_monitor WHERE id_cfg_monitor=__ID_CFG_MONITOR__) AND id_dev IN (__ID_DEV__)",

			// ---------------------------------------------------------------------------------------
         // Obtener la IP de un dispositivo
         // mod_latency_dispositivo.php
         'ip_from_device'=>"SELECT ip FROM devices WHERE id_dev=__ID_DEV__",
         // ---------------------------------------------------------------------------------------
         // Borrar una entrada de la documentacion a partir de su id_tip
         // mod_latency_documentacion.php
         'delete_tip'=>"DELETE FROM tips WHERE id_tip IN (__ID_TIP__)",
         // ---------------------------------------------------------------------------------------
         // Insertar una entrada en la documentacion
         // mod_latency_documentacion.php
         'insert_tip'=>"INSERT INTO tips (descr,id_ref,tip_type,date,name) VALUES ('__DESCR__','__ID_REF__','__TIP_TYPE__',__DATE__,'__NAME__')",
         'duplicate_report_tip'=>"INSERT INTO tips (descr,id_ref,tip_type,date,name,tip_class) VALUES ('__DESCR__','__ID_REF__','__TIP_TYPE__',__DATE__,'__NAME__',1)",
         // ---------------------------------------------------------------------------------------
         // Actualizar una entrada de la documentacion
         // mod_latency_documentacion.php
         'edit_tip'=>"UPDATE tips SET descr='__DESCR__',date=__DATE__,name='__NAME__' WHERE id_tip=__ID_TIP__",
         // ---------------------------------------------------------------------------------------
         // Listado de monitores de una metrica de tipo latency
         // mod_latency_monitor.php
         'all_monitor'=>"SELECT b.id_alert_type,b.cause,b.expr,b.severity FROM cfg_monitor a, alert_type b WHERE a.id_cfg_monitor=__ID_CFG_MONITOR__ AND a.monitor=b.mname",
			// ---------------------------------------------------------------------------------------
         // Información de un monitor
         // mod_latency_monitor.php
         'info_monitor'=>"SELECT b.id_alert_type,b.cause,b.expr,b.severity,a.items FROM cfg_monitor a, alert_type b WHERE a.monitor=b.mname AND b.id_alert_type=__ID_ALERT_TYPE__",
			// ---------------------------------------------------------------------------------------
         // Obtener el id_alert_type de un monitor
         // mod_latency_monitor.php
			// ---------------------------------------------------------------------------------------
			'get_id_monitor'=>"SELECT id_alert_type FROM alert_type WHERE monitor='__MONITOR__'",
			// ---------------------------------------------------------------------------------------
         // Crear un monitor
         // mod_latency_monitor.php
			'create_monitor'=>"INSERT INTO alert_type (cause,monitor,expr,severity,mname,type,subtype) values ('__CAUSE__','__MONITOR__','__EXPR__',__SEVERITY__,'__MNAME__','__TYPE__','__SUBTYPE__')",
			// ---------------------------------------------------------------------------------------
         // Modificar un monitor
         // mod_latency_monitor.php
			'modify_monitor'=>"UPDATE alert_type SET cause='__CAUSE__',expr='__EXPR__',severity=__SEVERITY__ WHERE id_alert_type='__ID_ALERT_TYPE__'",
			// ---------------------------------------------------------------------------------------
         // Borrar un monitor
         // mod_latency_monitor.php
			'delete_monitor'=>"DELETE FROM alert_type WHERE id_alert_type='__ID_ALERT_TYPE__'",

/**
   * **************************************************************** *
   Modulo: mod_proxy.sql

   mod_proxy_layout.php         shtml/mod_proxy_layout.shtml
   mod_proxy_detalle.php        shtml/mod_proxy_detalle.shtml
   mod_proxy_dispositivo.php    shtml/mod_proxy_dispositivo.shtml
   mod_proxy_documentacion.php  shtml/mod_proxy_documentacion.shtml
   * **************************************************************** *
*/

         'cnm_cfg_app_delete_temp'=>"DROP TEMPORARY TABLE t1",
         'cnm_cfg_app_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_monitor_app,a.type,a.subtype,a.itil_type,a.apptype,a.name,a.descr,a.cmd,a.params,a.myrange,a.cfg,a.platform,a.script,a.ready,a.format,a.enterprise,a.custom,a.aname,a.res,a.ipparam,a.iptab,ifnull(b.descr,'') as docu FROM cfg_monitor_apps a LEFT JOIN tips b on a.aname=b.id_ref AND b.position=0 and b.tip_type='app')",
         'cnm_cfg_app_get_list' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_cfg_app_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",


// ---------------------------------------------------------------------------------------
// mod_proxy_layout.php
// ---------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------
// mod_proxy_lista.php
// ---------------------------------------------------------------------------------------
			'cnm_cfg_proxy_get_class'=>"SELECT DISTINCT(class) AS class FROM cfg_monitor_agent WHERE proxy=1 order by class",
         'cnm_cfg_proxy_delete_temp'=>"DROP TEMPORARY TABLE t1",
			'cnm_cfg_proxy_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_cfg_monitor_agent,a.subtype,a.class,a.description as descr,a.apptype as enviroment,a.apptype,a.cfg,a.custom,a.esp,(SELECT ifnull(count(d.id_tm2iid),0) FROM prov_template_metrics2iid d,prov_template_metrics e WHERE e.subtype=a.subtype AND d.id_template_metric=e.id_template_metric and d.status=0) as cuantos,ifnull(c.descr,'') as docu,IFNULL((SELECT name from devices f WHERE f.id_dev=a.id_proxy),'') as proxy,iptab FROM cfg_monitor_agent a LEFT JOIN tips c on a.subtype=c.id_ref AND c.position=0 WHERE a.proxy=1 AND (a.class='proxy-imacros' OR a.class='proxy-linux'))",
         'cnm_cfg_proxy_get_list' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_cfg_proxy_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",


         // ---------------------------------------------------------------------------------------
         // Almacena (crea/modifica) la metrica de tipo proxy especificada
         'cnm_cfg_proxy_store_create'=>"INSERT INTO cfg_monitor_agent (subtype,description,id_proxy,vlabel,items,params,proxy,cfg,custom,script,class,mode,mtype,top_value,module,nparams,get_iid,apptype,proxy_type,tag,esp,iptab) VALUES ('__SUBTYPE__', '__DESCR__',__ID_PROXY__,'__VLABEL__','__ITEMS__','__PARAMS__',1,'__CFG__',1,'__SCRIPT__','__CLASS__','__MODE__','__MTYPE__',1,'mod_xagent_get',__NPARAMS__,0,'__APPTYPE__','__PROXY_TYPE__','__TAG__','__ESP__','__IPTAB__')",

         'cnm_cfg_proxy_store_update'=>"UPDATE cfg_monitor_agent SET class='__CLASS__', apptype='__APPTYPE__', description='__DESCR__', id_proxy=__ID_PROXY__, vlabel='__VLABEL__', items='__ITEMS__', params='__PARAMS__',proxy=1,cfg=__CFG__,custom=1,mode='__MODE__',apptype='__APPTYPE__',nparams=__NPARAMS__,script='__SCRIPT__',proxy_type='__PROXY_TYPE__',tag='__TAG__',esp='__ESP__',iptab='__IPTAB__',mtype='__MTYPE__' WHERE id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__",

			'cnm_cfg_proxy_store_unasoc'=>"DELETE FROM prov_template_metrics2iid WHERE mname=(SELECT subtype FROM cfg_monitor_agent WHERE id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__) AND id_dev IN (__ID_DEV__)",

			'update_proxy' => "UPDATE cfg_monitor_agent SET id_proxy=__ID_PROXY__ WHERE id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__",


         // ---------------------------------------------------------------------------------------
         // Duplicar una entrada de la lista de métricas de tipo agente
         // wsf: cnm_cfg_xagent_duplicate_metric (2Q)
         'cnm_cfg_proxy_duplicate_metric1'=>"INSERT INTO cfg_monitor_agent (subtype,class,description,items,vlabel,mode,mtype,top_value,module,nparams,params,params_descr,script,severity,info,cfg,custom,itil_type,get_iid,lapse,include,apptype,id_proxy,proxy,proxy_type,tag,esp,iptab) SELECT '__SUBTYPE__',class,CONCAT(description,' - COPIA'),items,vlabel,mode,mtype,top_value,module,nparams,params,params_descr,script,severity,info,cfg,1,itil_type,get_iid,lapse,include,apptype,id_proxy,proxy,proxy_type,tag,esp,iptab FROM cfg_monitor_agent WHERE id_cfg_monitor_agent IN (__ID_CFG_MONITOR_AGENT__)",
			'cnm_cfg_proxy_duplicate_metric2'=>"INSERT INTO cfg_monitor_param (hparam,script,subtype,type,enable,value) SELECT hparam,script,'__SUBTYPE__',type,enable,value FROM cfg_monitor_param WHERE subtype='__INIT_SUBTYPE__'",
         'cnm_cfg_app_duplicate1'=>"INSERT INTO cfg_monitor_apps (type,subtype,itil_type,apptype,name,descr,cmd,params,myrange,cfg,platform,script,format,enterprise,custom,aname,res,ipparam,iptab,ready) SELECT type,subtype,itil_type,apptype,CONCAT(name,' - COPIA'),descr,cmd,params,myrange,cfg,platform,script,format,enterprise,1 AS custom,'__ANAME__' AS aname,res,ipparam,iptab,1 AS ready FROM cfg_monitor_apps WHERE id_monitor_app IN (__ID_MONITOR_APP__)",
			'cnm_cfg_app_duplicate2'=>"INSERT INTO cfg_app_param (hparam,script,aname,type,enable,value) SELECT hparam,script,'__ANAME__',type,enable,value FROM cfg_app_param WHERE aname='__INIT_ANAME__'",


// ---------------------------------------------------------------------------------------
// mod_wmi_lista.php
// ---------------------------------------------------------------------------------------
         'cnm_cfg_wmi_get_class'=>"SELECT DISTINCT(class) AS class FROM cfg_monitor_agent WHERE proxy=1 order by class",
         'cnm_cfg_wmi_delete_temp'=>"DROP TEMPORARY TABLE t1",
         // 'cnm_cfg_wmi_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_cfg_monitor_agent,a.subtype,a.class,a.description as descr,a.apptype as enviroment,a.cfg,a.custom,(SELECT ifnull(count(d.id_tm2iid),0) FROM prov_template_metrics2iid d,prov_template_metrics e WHERE e.subtype=a.subtype AND d.id_template_metric=e.id_template_metric and d.status=0) as cuantos,ifnull(c.descr,'') as docu,IFNULL((SELECT name from devices f WHERE f.id_dev=a.id_proxy),'') as proxy FROM cfg_monitor_agent a LEFT JOIN tips c on a.subtype=c.id_ref WHERE a.proxy=1 AND a.class='proxy-wmi')",
         'cnm_cfg_wmi_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_cfg_monitor_agent,a.subtype,a.class,a.description as descr,a.apptype as enviroment,a.cfg,a.custom,(SELECT ifnull(count(d.id_tm2iid),0) FROM prov_template_metrics2iid d,prov_template_metrics e WHERE e.subtype=a.subtype AND d.id_template_metric=e.id_template_metric and d.status=0) as cuantos,IFNULL((SELECT c.descr FROM tips c WHERE c.id_ref=a.subtype AND c.position=0),'') as docu,IFNULL((SELECT name from devices f WHERE f.id_dev=a.id_proxy),'') as proxy FROM cfg_monitor_agent a WHERE a.proxy=1 AND a.class='proxy-wmi')",
         'cnm_cfg_wmi_get_list' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_cfg_wmi_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

			// Almacena (crea/modifica) la metrica de tipo wmi especificada
         'cnm_cfg_wmi_store_create'=>"INSERT INTO cfg_monitor_agent (subtype,description,id_proxy,vlabel,items,params,proxy,cfg,custom,script,class,mode,mtype,top_value,module,nparams,get_iid,apptype,proxy_type) VALUES ('__SUBTYPE__', '__DESCR__',__ID_PROXY__,'__VLABEL__','__ITEMS__','__PARAMS__',1,__CFG__,1,'__SCRIPT__','proxy-wmi','__MODE__','STD_AREA',1,'mod_xagent_get',__NPARAMS__,'__GET_IID__','__APPTYPE__','__PROXY_TYPE__')",

         'cnm_cfg_wmi_store_update'=>"UPDATE cfg_monitor_agent SET class='proxy-wmi', apptype='__APPTYPE__', description='__DESCR__', id_proxy=__ID_PROXY__, vlabel='__VLABEL__', items='__ITEMS__', params='__PARAMS__',proxy=1,cfg=__CFG__,custom=1,mode='__MODE__',apptype='__APPTYPE__',nparams=__NPARAMS__,script='__SCRIPT__',proxy_type='__PROXY_TYPE__',get_iid='__GET_IID__' WHERE id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__",

         'cnm_cfg_wmi_store_unasoc'=>"DELETE FROM prov_template_metrics2iid WHERE mname=(SELECT subtype FROM cfg_monitor_agent WHERE id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__) AND id_dev IN (__ID_DEV__)",

			// Desasociar dispositivos a una metrica snmp con instancias
         // mod_snmp_dispositivo_si_instancias.php
         'xagent_unasoc'=>"UPDATE prov_template_metrics2iid SET status=1 WHERE id_dev=__ID_DEV__ AND iid='__IID__' AND id_template_metric=(SELECT id_template_metric FROM prov_template_metrics a, cfg_monitor_agent b WHERE b.id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__ AND a.subtype=b.subtype AND a.id_dev=__ID_DEV__)",
         'xagent_unasoc_all'=>"UPDATE prov_template_metrics2iid SET status=1 WHERE id_dev=__ID_DEV__ AND id_template_metric=(SELECT id_template_metric FROM prov_template_metrics a, cfg_monitor_agent b WHERE b.id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__ AND a.subtype=b.subtype AND a.id_dev=__ID_DEV__)",




/**
	* **************************************************************** *
	Modulo: mod_xagent.sql

	mod_xagent_layout.php			shtml/mod_xagent_layout.shtml
	mod_xagent_detalle.php			shtml/mod_xagent_detalle.shtml
	mod_xagent_dispositivo.php		shtml/mod_xagent_dispositivo.shtml
	mod_xagent_documentacion.php	shtml/mod_xagent_documentacion.shtml
	* **************************************************************** *
*/

// ---------------------------------------------------------------------------------------
// mod_xagent_layout.php
// ---------------------------------------------------------------------------------------

// ---------------------------------------------------------------------------------------
// mod_xagent_lista.php
// ---------------------------------------------------------------------------------------

         // ---------------------------------------------------------------------------------------
         // Obtiene la lista de metricas de tipo xagente con el contador de uso
			// Requiere dos pasos
			// wsf: cnm_cfg_xagent_get_list_with_use_count_and_tip (2Q)
			'cnm_cfg_xagent_get_class'=>"SELECT DISTINCT(class) AS class FROM cfg_monitor_agent WHERE proxy=0 order by class",
			'cnm_cfg_xagent_get_enviroment'=>"SELECT DISTINCT(apptype) AS enviroment FROM cfg_monitor_agent order by enviroment",
			'cnm_cfg_xagent_get_apptype'=>"SELECT DISTINCT(apptype) AS apptype FROM cfg_monitor_agent order by apptype",

			'cnm_cfg_xagent_delete_temp'=>"DROP TEMPORARY TABLE t1",
			'cnm_cfg_xagent_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_cfg_monitor_agent,a.subtype,a.class,a.description as descr,a.apptype as enviroment,a.cfg,a.custom,(SELECT ifnull(count(d.id_tm2iid),0) FROM prov_template_metrics2iid d,prov_template_metrics e WHERE e.subtype=a.subtype AND d.id_template_metric=e.id_template_metric and d.status=0) as cuantos,ifnull(c.descr,'') as docu,IFNULL((SELECT name from devices f WHERE f.id_dev=a.id_proxy),'') as proxy FROM cfg_monitor_agent a LEFT JOIN tips c on a.subtype=c.id_ref WHERE a.proxy=0)",
// OJO cfg>0 porque hay metricas no visibles como SIN RESPUESTA DE AGENTE REMOTO.
// Esta definida por compatibilidad de datos.
         'cnm_cfg_xagent_get_list' => "SELECT * FROM t1 WHERE ''='' AND cfg>0 __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_cfg_xagent_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' AND cfg>0 __CONDITION__",


			'cnm_cfg_xagent_get_list_with_use_count_and_tip1'=>"CREATE TEMPORARY TABLE t4 SELECT COUNT(id_metric) AS cuantos,subtype FROM metrics WHERE subtype IN (SELECT subtype FROM cfg_monitor_agent) AND id_dev IN (SELECT id_dev FROM cfg_devices2organizational_profile where id_cfg_op in (__ORGPRO__)) AND status=0 GROUP BY subtype",
			'cnm_cfg_xagent_get_list_with_use_count_and_tip2'=>"SELECT cfg_monitor_agent.subtype,id_cfg_monitor_agent,class as clase,description,script,custom,cfg,apptype,ifnull(cuantos,0) as cuantos,c.descr FROM (cfg_monitor_agent  LEFT JOIN t4 on cfg_monitor_agent.subtype=t4.subtype) LEFT JOIN tips c on cfg_monitor_agent.subtype=c.id_ref and c.tip_type='agent' and c.tip_class=1",

			//
			'cnm_cfg_xagent_get_metric_instances_by_device'=>"SELECT a.iid FROM prov_template_metrics2iid a, prov_template_metrics b,cfg_monitor_agent c WHERE a.id_dev=__ID_DEV__ AND a.id_template_metric=b.id_template_metric AND b.type='xagent' and c.subtype=b.subtype and c.id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__ AND a.status=0",

         // ---------------------------------------------------------------------------------------
			// Duplicar una entrada de la lista de métricas de tipo agente
			// wsf: cnm_cfg_xagent_duplicate_metric (2Q)
			'cnm_cfg_xagent_duplicate_metric1'=>"INSERT INTO cfg_monitor_agent (subtype,class,description,items,vlabel,mode,mtype,top_value,module,nparams,params,params_descr,script,severity,info,cfg,custom,itil_type,get_iid,lapse,include,apptype,id_proxy,proxy) SELECT '__SUBTYPE__',class,CONCAT(description,' - COPIA'),items,vlabel,mode,mtype,top_value,module,nparams,params,params_descr,script,severity,info,cfg,1,itil_type,get_iid,lapse,include,apptype,id_proxy,proxy FROM cfg_monitor_agent WHERE id_cfg_monitor_agent IN (__ID_CFG_MONITOR_AGENT__)",
			'cnm_cfg_xagent_duplicate_metric2'=>"INSERT INTO tips (id_ref,tip_type,tip_class,url,name,descr) SELECT '__SUBTYPE__',tip_type,tip_class,url,name,descr FROM tips WHERE id_ref IN ('__SUBTYPE_ORIG__')",

	
         // ---------------------------------------------------------------------------------------
         // Elimina la/las metricas especificadas por su subtype
			// (Interesa que sea el subtype porque es comun en las diferentes tablas implicadas)
			// Se borra del repositorio
			// Se borra de prov_template_metrics
			// Se borra de metrics
         'delete_xagent_metric_by_id'=>"DELETE FROM cfg_monitor_agent WHERE id_cfg_monitor_agent in (__ID_CFG_MONITOR_AGENT__) AND custom=1",
         'cnm_cfg_xagent_delete_metric_by_subtype'=>"DELETE FROM cfg_monitor_agent WHERE subtype='__SUBTYPE__' AND custom=1",
         'cnm_cfg_xagent_delete_metric_from_template_by_subtype'=>"DELETE FROM prov_template_metrics WHERE subtype='__SUBTYPE__'",
			'cnm_cfg_xagent_delete_metric_params'=>"DELETE FROM cfg_monitor_param WHERE subtype='__SUBTYPE__' AND type='__TYPE__'",

			'cnm_metrics_get_in_use_by_subtype'=>"SELECT id_metric FROM metrics WHERE subtype='__SUBTYPE__'",
	
         // ---------------------------------------------------------------------------------------
			'cnm_cfg_xagent_get_defined_classes'=>"SELECT distinct class FROM cfg_monitor_agent",
			'cnm_cfg_xagent_get_defined_apptypes'=>"SELECT distinct apptype FROM cfg_monitor_agent",
			'cnm_cfg_xagent_get_info_by_id'=>"SELECT id_cfg_monitor_agent,subtype,nparams,description,vlabel,top_value,module,lapse,mtype,script,class,items,itil_type,params,params_descr,get_iid,cfg,custom,id_proxy,proxy_type,severity,apptype,mode,tag,esp,iptab,info,include,proxy FROM cfg_monitor_agent WHERE id_cfg_monitor_agent in (__ID_CFG_MONITOR_AGENT__)",
			'cnm_cfg_xagent_get_info_by_subtype2'=>"SELECT id_cfg_monitor_agent,subtype,nparams,description,vlabel,top_value,module,lapse,mtype,script,class,items,itil_type,params,params_descr,get_iid,cfg,custom,id_proxy,proxy_type,severity,apptype,mode,tag,esp,iptab,info,include,proxy FROM cfg_monitor_agent WHERE subtype='__SUBTYPE__'",
			'cnm_cfg_xagent_get_all_id' => "SELECT id_cfg_monitor_agent FROM cfg_monitor_agent",
			'cnm_cfg_app_get_all_id' => "SELECT id_monitor_app FROM cfg_monitor_apps",
			'cnm_cfg_task_get_all_id' => "SELECT * FROM cfg_task_configured",
			'cnm_cfg_app_get_info_by_id'=>"SELECT id_monitor_app,type,subtype,ready,itil_type,apptype,name,descr,cmd,params,myrange,cfg,platform,script,format,enterprise,custom,aname,res,ipparam,iptab,id_proxy FROM cfg_monitor_apps WHERE id_monitor_app in (__ID_MONITOR_APP__)",
			'cnm_cfg_task_get_info_by_id'=>"SELECT id_cfg_task_configured,name,descr,frec,date,cron,task,done,exec,atype,subtype,params FROM cfg_task_configured WHERE id_cfg_task_configured in (__ID_CFG_TASK_CONFIGURED__)",
			'cnm_cfg_app_get_info_by_aname2'=>"SELECT id_monitor_app,type,subtype,ready,itil_type,apptype,name,descr,cmd,params,myrange,cfg,platform,script,format,enterprise,custom,aname,res,ipparam,iptab,id_proxy FROM cfg_monitor_apps WHERE aname='__ANAME__'",
			'cnm_cfg_xagent_get_info_by_subtype'=>"SELECT a.id_cfg_monitor_agent,a.subtype,a.description,a.vlabel,a.lapse,a.script,a.class,a.items,a.params,a.get_iid,a.cfg,a.custom,a.id_proxy,a.severity,a.apptype,a.mode,a.tag,a.iptab,IFNULL(b.descr,'') AS docu FROM cfg_monitor_agent a LEFT JOIN tips b ON (a.subtype=b.id_ref AND b.tip_class=1) WHERE subtype='__SUBTYPE__'",
			'cnm_cfg_app_get_info_by_aname'=>"SELECT a.id_monitor_app,a.type,a.subtype,a.itil_type,a.apptype,a.name,a.descr,a.cmd,a.params,a.myrange,a.cfg,a.platform,a.script,a.format,a.enterprise,a.custom,a.aname,a.res,a.ipparam,a.iptab,IFNULL(b.descr,'') AS docu FROM cfg_monitor_apps a LEFT JOIN tips b ON (a.aname=b.id_ref AND b.tip_class=1) WHERE aname='__ANAME__'",
			'cnm_cfg_xagent_get_proxy_by_id'=>"SELECT id_dev,name,domain,xagent_version FROM devices WHERE id_dev=(SELECT id_proxy FROM cfg_monitor_agent WHERE id_cfg_monitor_agent in (__ID_CFG_MONITOR_AGENT__))",
			'cnm_cfg_xagent_get_params'=>"SELECT a.id_cfg_script_param,a.hparam,a.script,a.position,a.prefix,a.descr,a.value AS init_val,a.param_type,IFNULL(b.id_cfg_monitor_param,-1) AS id_cfg_monitor_param,b.enable,b.value FROM cfg_script_param a LEFT JOIN cfg_monitor_param b ON a.hparam=b.hparam AND a.script=b.script AND b.subtype='__SUBTYPE__' WHERE a.script='__SCRIPT__' ORDER BY a.position",
			'cnm_cfg_xagent_set_params'=>"UPDATE cfg_monitor_agent SET params='__PARAMS__' WHERE id_cfg_monitor_agent='__ID_CFG_MONITOR_AGENT__'",
			'cnm_cfg_app_get_params'=>"SELECT a.id_cfg_script_param,a.hparam,a.script,a.position,a.prefix,a.descr,a.value AS init_val,a.param_type,IFNULL(b.id_cfg_app_param,-1) AS id_cfg_app_param,b.enable,b.value FROM cfg_script_param a LEFT JOIN cfg_app_param b ON a.hparam=b.hparam AND a.script=b.script AND b.aname='__ANAME__' WHERE a.script='__SCRIPT__' ORDER BY a.position",
			'cnm_cfg_app_param_info'=>"SELECT * FROM cfg_app_param WHERE id_cfg_app_param IN (__ID_CFG_APP_PARAM__)",
			'cnm_cfg_script_param'=>"SELECT id_cfg_script_param,hparam,script,position,prefix,descr,value,param_type FROM cfg_script_param WHERE script='__SCRIPT__'",
			'cnm_cfg_all_script_param_ip'=>"SELECT script FROM cfg_script_param WHERE param_type=2",
			'cnm_cfg_metric_insert_param'=>"INSERT INTO cfg_monitor_param (hparam,script,subtype,type,enable,value) VALUES ('__HPARAM__','__SCRIPT__','__SUBTYPE__','__TYPE__','__ENABLE__','__VALUE__')",
			'cnm_cfg_metric_update_param'=>"UPDATE cfg_monitor_param SET value='__VALUE__',enable='__ENABLE__' WHERE id_cfg_monitor_param=__ID_CFG_MONITOR_PARAM__",
			'cnm_cfg_metric_update_param_sec'=>"UPDATE cfg_monitor_param SET enable=__ENABLE__  WHERE id_cfg_monitor_param=__ID_CFG_MONITOR_PARAM__",
			'cnm_cfg_params_delete'=>"DELETE FROM cfg_monitor_param WHERE subtype='__SUBTYPE__' AND type='__TYPE__' AND id_cfg_monitor_param NOT IN (__ID_CFG_MONITOR_PARAM__)",
			'cnm_cfg_params_get_max_id_param'=>"SELECT MAX(id_param) AS max_id_param FROM cfg_script_param WHERE subtype='__SUBTYPE__' AND type='__TYPE__'",
			'cnm_cfg_app_params_delete'=>"DELETE FROM cfg_app_param WHERE aname='__ANAME__' AND id_cfg_app_param NOT IN (__ID_CFG_APP_PARAM__)",
			'app_params_delete'=>"DELETE FROM cfg_app_param WHERE aname='__ANAME__' AND type='__TYPE__'",
			'cnm_cfg_app_insert_param'=>"INSERT INTO cfg_app_param (hparam,script,aname,type,enable,value) VALUES ('__HPARAM__','__SCRIPT__','__ANAME__','__TYPE__','__ENABLE__','__VALUE__')",
			'cnm_cfg_app_update_param'=>"UPDATE cfg_app_param SET value='__VALUE__',enable='__ENABLE__' WHERE id_cfg_app_param=__ID_CFG_APP_PARAM__",
			'cnm_cfg_app_update_param_sec'=>"UPDATE cfg_app_param SET enable=__ENABLE__  WHERE id_cfg_app_param=__ID_CFG_APP_PARAM__",
         // ---------------------------------------------------------------------------------------
			'cnm_cfg_script_params_delete'=>"DELETE FROM cfg_script_param WHERE script='__SCRIPT__' AND id_cfg_script_param NOT IN (__ID_CFG_SCRIPT_PARAM__)",
			'cnm_cfg_script_params_delete_all'=>"DELETE FROM cfg_script_param WHERE script='__SCRIPT__'",
			'cnm_cfg_script_params_add'=>"INSERT INTO cfg_script_param (hparam,script,position,prefix,descr,value,param_type) VALUES ('__HPARAM__','__SCRIPT__',__POSITION__,'__PREFIX__','__DESCR__','__VALUE__',__PARAM_TYPE__)",
			'cnm_cfg_script_params_modify'=>"UPDATE cfg_script_param SET position=__POSITION__,prefix='__PREFIX__',descr='__DESCR__',value='__VALUE__',param_type=__PARAM_TYPE__ WHERE id_cfg_script_param=__ID_CFG_SCRIPT_PARAM__",
			'cnm_cfg_script_params_sec_modify'=>"UPDATE cfg_script_param SET position=__POSITION__,prefix='__PREFIX__',descr='__DESCR__',param_type=__PARAM_TYPE__ WHERE id_cfg_script_param=__ID_CFG_SCRIPT_PARAM__",

			'cnm_cfg_monitor_agent_script_list'=>"SELECT id_cfg_monitor_agent_script,script,description,proxy_type,proxy_user,proxy_pwd,cfg,custom,size,FROM_UNIXTIME(date) AS date FROM cfg_monitor_agent_script WHERE cfg=0",
			'cnm_cfg_app_script_list'=>"SELECT id_cfg_monitor_agent_script,script,description,proxy_type,proxy_user,proxy_pwd,cfg,custom,size,FROM_UNIXTIME(date) AS date FROM cfg_monitor_agent_script WHERE cfg=1",
			'cnm_cfg_app_script_user_list'=>"SELECT id_cfg_monitor_agent_script,script,description,proxy_type,proxy_user,proxy_pwd,cfg,exec_mode,custom,size,FROM_UNIXTIME(date) AS date FROM cfg_monitor_agent_script WHERE exec_mode IN (1,2) and cfg=1",
			'cnm_cfg_app_script_user_type_list'=>"SELECT id_cfg_monitor_agent_script,script,description,proxy_type,proxy_user,proxy_pwd,cfg,exec_mode,custom,size,FROM_UNIXTIME(date) AS date FROM cfg_monitor_agent_script WHERE exec_mode IN (1,2) AND proxy_type='__PROXY_TYPE__'",
			'cnm_cfg_monitor_agent_script_get_script_data'=>"SELECT id_cfg_monitor_agent_script,cfg,custom,script,timeout,script_data,FROM_UNIXTIME(date) as date,proxy_type,proxy_user,size,signature,exec_mode FROM cfg_monitor_agent_script WHERE id_cfg_monitor_agent_script IN (__ID_CFG_MONITOR_AGENT_SCRIPT__)",
			'cnm_cfg_monitor_agent_script_get_script_data_by_script'=>"SELECT id_cfg_monitor_agent_script,script,description,proxy_type,proxy_user,proxy_pwd,cfg,custom,size,date,script_data,signature,id_proxy,exec_mode FROM cfg_monitor_agent_script WHERE script='__SCRIPT__'",
			'cnm_cfg_monitor_agent_script_get_script_params_by_subtype'=>"SELECT hparam,script,subtype,type,enable,value FROM cfg_monitor_param WHERE subtype='__SUBTYPE__'",
			'cnm_cfg_monitor_app_get_script_params_by_aname'=>"SELECT hparam,script,aname,type,enable,value FROM cfg_app_param WHERE aname='__ANAME__'",
			'cnm_cfg_monitor_agent_script_duplicate'=>"INSERT INTO cfg_monitor_agent_script (script,description,proxy_type,proxy_user,proxy_pwd,cfg,custom,size,date,script_data,signature) SELECT FROM cfg_monitor_agent_script WHERE id_cfg_monitor_agent_script IN (__ID_CFG_MONITOR_AGENT_SCRIPT__)",
			'cnm_cfg_monitor_agent_script_delete'=>"DELETE FROM cfg_monitor_agent_script WHERE id_cfg_monitor_agent_script IN (__ID_CFG_MONITOR_AGENT_SCRIPT__)",
			'cnm_cfg_monitor_param_delete'=>"DELETE FROM cfg_monitor_param WHERE script='__SCRIPT__'",
			'cnm_cfg_monitor_agent_user_script_list'=>"SELECT id_cfg_monitor_agent_script,script,description,proxy_type,proxy_user,proxy_pwd,cfg,custom,size,FROM_UNIXTIME(date) AS date FROM cfg_monitor_agent_script WHERE custom=1",
			'cnm_cfg_monitor_agent_get_info_by_script'=>"SELECT id_cfg_monitor_agent_script,script,description,proxy_type,proxy_user,proxy_pwd,cfg,custom,size,FROM_UNIXTIME(date) AS date,script_data,id_proxy,timeout FROM cfg_monitor_agent_script WHERE script='__SCRIPT__'",
			'cnm_cfg_monitor_agent_get_info_by_id'=>"SELECT id_cfg_monitor_agent_script,script,description,proxy_type,proxy_user,proxy_pwd,cfg,custom,size,FROM_UNIXTIME(date) AS date FROM cfg_monitor_agent_script WHERE  id_cfg_monitor_agent_script IN (__ID_CFG_MONITOR_AGENT_SCRIPT__)",
			'cnm_cfg_monitor_agent_create'=>"INSERT INTO cfg_monitor_agent_script (script,description,proxy_type,proxy_user,proxy_pwd,cfg,custom,size,date,script_data,signature,exec_mode,timeout) VALUES ('__SCRIPT__','','__PROXY_TYPE__','cnm','',__CFG__,1,__SIZE__,__DATE__,'__SCRIPT_DATA__','__SIGNATURE__',2,__TIMEOUT__)",
		'cnm_cfg_monitor_agent_modify'=>"UPDATE cfg_monitor_agent_script SET size=__SIZE__, date=__DATE__, script_data='__SCRIPT_DATA__',proxy_type='__PROXY_TYPE__',cfg=__CFG__,signature='__SIGNATURE__',exec_mode=2,timeout=__TIMEOUT__ WHERE script='__SCRIPT__'",
         'cnm_cfg_script_delete_temp'=>"DROP TEMPORARY TABLE t1,t2",
			'cnm_cfg_script_create_temp1' => "CREATE TEMPORARY TABLE t2 (SELECT count(id_cfg_monitor_agent) AS cuantos,script FROM cfg_monitor_agent GROUP BY script)",
			'cnm_cfg_script_create_temp2' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_cfg_monitor_agent_script,a.script,a.proxy_type,a.custom,a.cfg,a.size,a.date,a.exec_mode,FROM_UNIXTIME(a.date) AS human_date,IFNULL(b.descr,'') AS docu,ifnull(t2.cuantos,0) AS cuantos FROM cfg_monitor_agent_script a LEFT JOIN tips b on a.script=b.id_ref AND b.tip_type='script' AND b.position=0 LEFT JOIN t2 ON a.script=t2.script WHERE a.exec_mode>0)",
			'cnm_cfg_script_get_list' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_cfg_script_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
// ---------------------------------------------------------------------------------------
// **FALTA**  mod_xagent_detalle.php
// ---------------------------------------------------------------------------------------

         // ---------------------------------------------------------------------------------------
         // Almacena (crea/modifica) la metrica de tipo agente especificada
			// 'cnm_cfg_proxy_store_create'=>"INSERT INTO cfg_monitor_agent (subtype,description,vlabel,items,params,proxy,cfg,custom,script,mode,mtype,top_value,module,nparams,get_iid,apptype) VALUES ('__SUBTYPE__', '__DESCR__','__VLABEL__','__ITEMS__','__PARAMS__',0,1,1,'__SCRIPT__','__MODE__','__MTYPE__',1,'mod_xagent_get',__NPARAMS__,0,'__APPTYPE__')",

			'cnm_cfg_xagent_store_update'=>"UPDATE cfg_monitor_agent SET apptype='__APPTYPE__', description='__DESCR__', vlabel='__VLABEL__', items='__ITEMS__', params='__PARAMS__', proxy=0, cfg=2, custom=1, mode='__MODE__', nparams=__NPARAMS__, script='__SCRIPT__' WHERE id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__",


// ---------------------------------------------------------------------------------------
// mod_xagent_dispositivo.php
// ---------------------------------------------------------------------------------------

         // ---------------------------------------------------------------------------------------
			// Obtiene la lista de dispositivos incluyendo un campo que indica si tiene o no asociada una alerta remota.
			'get_devices_by_xagent_metrics'=>"SELECT d.id_dev,d.name,d.domain,d.ip,'1' as asoc,type,status FROM devices d WHERE id_dev in (SELECT id_dev FROM prov_template_metrics2iid a,cfg_monitor_agent b WHERE a.mname=b.subtype AND a.status=0 AND b.id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__)  UNION  SELECT d.id_dev,d.name,d.domain,d.ip,'0' as asoc,type,status FROM devices d WHERE id_dev NOT in (SELECT id_dev FROM prov_template_metrics2iid a,cfg_monitor_agent b WHERE a.mname=b.subtype AND a.status=0 AND b.id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__)",



         // ---------------------------------------------------------------------------------------
         // Asocia la alerta remota a la lista de dispositivos especificada
			// wsf: cnm_cfg_xagent_include_device
// FML FALTA
// store_prov_template_metrics
// store_qactions


         // ---------------------------------------------------------------------------------------
         // Excluye la metrica de tipo agente de la lista de dispositivos especificada (desasocia)
         // wsf: cnm_cfg_xagent_exclude_device
         // ---------------------------------------------------------------------------------------
         // ---------------------------------------------------------------------------------------
			'cnm_cfg_xagent_unasoc_si_instancias'=>"UPDATE prov_template_metrics2iid SET status=1 WHERE id_dev=__ID_DEV__ AND iid='__IID__' AND id_template_metric=(SELECT id_template_metric FROM prov_template_metrics a, cfg_monitor_agent b WHERE b.id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__ AND a.subtype=b.subtype AND a.id_dev=__ID_DEV__)",
         'cnm_cfg_xagent_exclude_device1'=>"DELETE FROM prov_template_metrics2iid WHERE id_dev=__ID_DEV__ AND mname=(SELECT subtype FROM cfg_monitor_agent WHERE id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__)",
         'cnm_cfg_xagent_exclude_device2'=>"DELETE FROM prov_template_metrics WHERE id_dev=__ID_DEV__ AND subtype=(SELECT subtype FROM cfg_monitor_agent WHERE id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__) AND type='xagent'",
// FML FALTA
//faltaria un delete_metric ?????

         // ---------------------------------------------------------------------------------------
         // ---------------------------------------------------------------------------------------
         'cnm_cfg_xagent_get_included_devices_by_id'=>"SELECT id_dev FROM prov_template_metrics2iid a,cfg_monitor_agent b WHERE a.mname=b.subtype AND b.id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__",


         // ---------------------------------------------------------------------------------------
         // Obtiene el numero de dispositivos que tienen incluida una metrica de agente
         // wsf: cnm_cfg_xagent_get_included_devices_count (1Q)
			// OJO obtiene el valor de la plantilla no el de la tabla metrics (que se instanciara posteriormente)
         // ---------------------------------------------------------------------------------------
         //'cnm_cfg_xagent_get_included_devices_count'=>"SELECT count(*) as counter FROM prov_template_metrics WHERE subtype='__MNAME__'",
         'cnm_cfg_xagent_get_included_devices_count'=>"SELECT count(*) as counter FROM prov_template_metrics WHERE subtype=(SELECT subtype FROM cfg_monitor_agent WHERE id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__)",


 /**
	* **************************************************************** *
	* Modulo: mod_monitor.sql
   shtml/mod_monitor_layout.shtml          mod_monitor_layout.php
   shtml/mod_monitor_detalle.shtml         mod_monitor_detalle.php
   shtml/mod_monitor_dispositivo.shtml     mod_monitor_dispositivo.php
   shtml/mod_monitor_documentacion.shtml   mod_monitor_documentacion.php

	* **************************************************************** *
	*/


         // ---------------------------------------------------------------------------------------
         // Información de un monitor a partir de su alert_type
         // mod_monitores_detalle.php
			//info_monitor
			"cnm_cfg_monitor_get_info_by_id"=>'(SELECT a.cause,a.expr,a.severity,a.type,b.description,b.info,b.items,b.id_cfg_monitor,a.wsize,a.class FROM alert_type a,cfg_monitor b WHERE a.id_alert_type=__ID_ALERT_TYPE__ AND b.monitor=a.mname) UNION (SELECT a.cause,a.expr,a.severity,a.type,b.descr as description,b.oid_info as info,b.items,b.id_cfg_monitor_snmp as id_cfg_monitor,a.wsize,a.class FROM alert_type a,cfg_monitor_snmp b WHERE a.id_alert_type=__ID_ALERT_TYPE__ AND b.subtype=a.mname) UNION (SELECT a.cause,a.expr,a.severity,a.type,b.description,b.info,b.items,b.id_cfg_monitor_agent as id_cfg_monitor,a.wsize,a.class FROM alert_type a,cfg_monitor_agent b WHERE a.id_alert_type=__ID_ALERT_TYPE__ AND b.subtype=a.mname)',
			"cnm_cfg_monitor_get_all_by_id"=>"SELECT * FROM alert_type WHERE id_alert_type IN (__ID_ALERT_TYPE__)",
			"cnm_cfg_monitor_get_all_id"=>"SELECT id_alert_type FROM alert_type",
			"cnm_cfg_monitor_agent_script_get_all_id"=>"SELECT id_cfg_monitor_agent_script FROM cfg_monitor_agent_script",
			"cnm_cfg_monitor_agent_script_get_info_by_id"=>"SELECT * FROM cfg_monitor_agent_script WHERE id_cfg_monitor_agent_script IN (__ID_CFG_MONITOR_AGENT_SCRIPT__)",


         // ---------------------------------------------------------------------------------------
         // Listado de monitores
         // mod_monitores_lista.php
			// 'cnm_cfg_monitor_get_list'=>"(SELECT COUNT(DISTINCT b.id_tm2iid) AS cuantos,a.id_alert_type,a.type,a.severity,a.cause,a.expr,c.descr as descr from alert_type a,prov_template_metrics2iid b,tips c WHERE a.monitor=b.watch AND b.status=0 AND c.tip_type='id_alert_type' AND c.id_ref=a.id_alert_type GROUP BY a.monitor) UNION (SELECT 0 as cuantos, a.id_alert_type,a.type,a.severity,a.cause,a.expr,'' as descr from alert_type a where a.id_alert_type NOT IN (SELECT a.id_alert_type from alert_type a,prov_template_metrics2iid b WHERE a.monitor=b.watch AND b.status=0 GROUP BY a.monitor))",
			// 'cnm_cfg_monitor_get_list'=>"SELECT (SELECT COUNT(DISTINCT b.id_tm2iid) FROM prov_template_metrics2iid b WHERE a.monitor=b.watch AND b.status=0) AS cuantos,a.id_alert_type,a.type,a.severity,a.cause,a.expr,(SELECT descr FROM tips c WHERE c.id_ref=a.id_alert_type AND c.tip_type='id_alert_type') as descr from alert_type a GROUP BY a.monitor",
         'cnm_cfg_monitor_delete_temp' => "DROP TEMPORARY TABLE t1,t2",
			'cnm_cfg_monitor_create_temp_1' => "CREATE TEMPORARY TABLE t2 (SELECT COUNT(distinct(id_tm2iid))AS cuantos,watch FROM prov_template_metrics2iid where status=0 GROUP BY watch)",
			'cnm_cfg_monitor_create_temp_2' => "CREATE TEMPORARY TABLE t1(SELECT IFNULL(b.cuantos,0) AS cuantos,a.id_alert_type,a.type,a.apptype,a.severity,a.cause,a.expr,a.class,a.monitor,IFNULL(c.descr,'') AS docu,a.hide FROM alert_type a LEFT JOIN t2 b ON a.monitor=b.watch LEFT JOIN tips c ON c.id_ref=a.monitor AND c.tip_type='id_alert_type' AND c.position=0)",
         'cnm_cfg_monitor_get_list' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_cfg_monitor_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
			'cnm_cfg_monitor_types' => "SELECT DISTINCT(class) AS class FROM alert_type",
			'cnm_cfg_monitor_apptype' => "SELECT DISTINCT(apptype) AS apptype FROM alert_type ORDER BY apptype",
			

         // ---------------------------------------------------------------------------------------
         // Crear/Modificar un monitor
         // mod_monitor_detalle.php
         'cnm_cfg_monitor_store_create'=>"INSERT INTO alert_type (cause,monitor,expr,severity,mname,type,subtype,wsize,class,apptype) values ('__CAUSE__','__MONITOR__','__EXPR__',__SEVERITY__,'__MNAME__','__TYPE__','__SUBTYPE__','__WSIZE__','__CLASS__','__APPTYPE__')",
         'cnm_cfg_monitor_store_update'=>"UPDATE alert_type SET cause='__CAUSE__',expr='__EXPR__',severity=__SEVERITY__,wsize='__WSIZE__',class='__CLASS__',apptype='__APPTYPE__' WHERE id_alert_type='__ID_ALERT_TYPE__'",


         // ---------------------------------------------------------------------------------------
         // Lista los otros monitores definidos y asociados a una metrica concreta
         // mod_monitor_detalle.php
         'cnm_cfg_monitor_get_all_by_snmp_metric'=>"SELECT b.id_alert_type,b.cause,b.expr,b.severity,b.wsize FROM cfg_monitor_snmp a, alert_type b WHERE a.id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__ AND a.subtype=b.mname",
         'cnm_cfg_monitor_get_all_by_latency_metric'=>"SELECT b.id_alert_type,b.cause,b.expr,b.severity,b.wsize FROM cfg_monitor a, alert_type b WHERE a.id_cfg_monitor=__ID_CFG_MONITOR__ AND a.monitor=b.mname",
         'cnm_cfg_monitor_get_all_by_xagent_metric'=>"SELECT b.id_alert_type,b.cause,b.expr,b.severity,b.wsize FROM cfg_monitor_agent a, alert_type b WHERE a.id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__ AND a.subtype=b.mname",



         // ---------------------------------------------------------------------------------------
			// Obtener los dispositivos que pueden estar asociados a un monitor
			// mod_monitor_dispositivo.php
			//'devices_monitor'=>"select c.id_dev,c.status,c.name,c.ip,c.type,(a.monitor=b.watch)as asoc from alert_type a, prov_template_metrics2iid b,devices c where a.id_alert_type=__ID_ALERT_TYPE__ AND a.mname=b.mname and b.status=0 and b.id_dev=c.id_dev",
			'devices_monitor'=>"SELECT c.id_tm2iid,c.iid,c.label,d.id_dev,d.status,d.name,d.ip,d.type,(a.monitor=c.watch)AS asoc,a.id_alert_type,a.cause,a.mname,a.monitor FROM alert_type a, prov_template_metrics b, prov_template_metrics2iid c, devices d where a.id_alert_type=__ID_ALERT_TYPE__ AND a.mname=b.subtype AND b.id_template_metric=c.id_template_metric and c.status=0 AND b.id_dev=d.id_dev AND c.id_dev=d.id_dev",

         // ---------------------------------------------------------------------------------------
			// Asociar un monitor a una metrica
			// mod_monitor_dispositivo.php
			'cnm_cfg_monitor_include_metric'=>"UPDATE prov_template_metrics2iid SET watch=(SELECT monitor FROM alert_type WHERE id_alert_type=__ID_ALERT_TYPE__) WHERE id_tm2iid IN (__ID_TM2IID__)",
         // ---------------------------------------------------------------------------------------
			// Desasociar un monitor de una metrica
			// mod_monitor_dispositivo.php
			'cnm_cfg_monitor_exclude_metric'=>"UPDATE prov_template_metrics2iid SET watch=0 WHERE id_tm2iid IN (__ID_TM2IID__)",
			'cnm_cfg_monitor_get_count_by_id'=>"SELECT COUNT(DISTINCT b.id_tm2iid) AS cuantos FROM prov_template_metrics2iid b, alert_type a WHERE a.monitor=b.watch AND b.status=0 AND id_alert_type=__ID_ALERT_TYPE__",

			// ---------------------------------------------------------------------------------------
         // Crear un monitor
         // mod_latency_monitor.php
			'create_monitor'=>"INSERT INTO alert_type (cause,monitor,expr,severity,mname,type,subtype) values ('__CAUSE__','__MONITOR__','__EXPR__',__SEVERITY__,'__MNAME__','__TYPE__','__SUBTYPE__')",
			// ---------------------------------------------------------------------------------------
         // Modificar un monitor
         // mod_latency_monitor.php
			'modify_monitor'=>"UPDATE alert_type SET cause='__CAUSE__',expr='__EXPR__',severity=__SEVERITY__ WHERE id_alert_type='__ID_ALERT_TYPE__'",


			// ---------------------------------------------------------------------------------------
         // Borrar un monitor
         // mod_latency_monitor.php
			'delete_monitor'=>"DELETE FROM alert_type WHERE id_alert_type='__ID_ALERT_TYPE__'",

			

         // ---------------------------------------------------------------------------------------
         // Elimina el/los monitores  especificadas por su id
         // (Obtiene monitor a partir del id + Borra monitor de la provision de metricas +
			// Borra de metricas en curso + Borra de alertas)
			// Despues de borrar los monitores hay que borrar los avisos
         // wsf: cnm_cfg_monitor_delete_by_id (2Q)
         'cnm_cfg_monitor_get_monitor_by_id'=>"SELECT * FROM alert_type WHERE id_alert_type in (:__ID_ALERT_TYPE__)",
         'a_cnm_cfg_monitor_get_monitor_by_id'=>"SELECT * FROM alert_type WHERE id_alert_type in (__ID_ALERT_TYPE__)",

			// Elimina el monitor de la provision de  metricas
         'cnm_cfg_monitor_delete_from_template_metrics2iid'=>"UPDATE prov_template_metrics2iid SET  watch='0' WHERE watch=':__MONITOR__'",
         'a_cnm_cfg_monitor_delete_from_template_metrics2iid'=>"UPDATE prov_template_metrics2iid SET  watch='0' WHERE watch='__MONITOR__'",
			// Elimina el monitor de las metricas sobre las que estuviera instanciado
			 'cnm_cfg_monitor_delete_from_metrics'=>"UPDATE metrics SET watch='0' WHERE watch=':__MONITOR__'",
			 'a_cnm_cfg_monitor_delete_from_metrics'=>"UPDATE metrics SET watch='0' WHERE watch='__MONITOR__'",
			// Elimina las alertas causadas por el monitor (watch) eliminado.
			'cnm_cfg_monitor_delete_from_alerts'=>"DELETE FROM alerts WHERE watch=':__MONITOR__'",
			'a_cnm_cfg_monitor_delete_from_alerts'=>"DELETE FROM alerts WHERE watch='__MONITOR__'",

			// Elimina el/los monitor/es
			'cnm_cfg_monitor_delete_from_alert_type'=>"DELETE FROM alert_type WHERE id_alert_type in (:__ID_ALERT_TYPE__)",
			'a_cnm_cfg_monitor_delete_from_alert_type'=>"DELETE FROM alert_type WHERE id_alert_type in (__ID_ALERT_TYPE__)",

			


/**
	* **************************************************************** *
	Modulo: mod_remote.sql

	shtml/mod_remote_layout.shtml				mod_remote_layout.php
	shtml/mod_remote_detalle.shtml			mod_remote_detalle.php
	shtml/mod_remote_dispositivo.shtml		mod_remote_dispositivo.php
	shtml/mod_remote_documentacion.shtml	mod_remote_documentacion.php

	* **************************************************************** *
*/

// ---------------------------------------------------------------------------------------
// mod_remote_layout.php
// ---------------------------------------------------------------------------------------

         // ---------------------------------------------------------------------------------------
         // Lista de alertas remotas definidas en el sistema
			// wsf: cnm_cfg_remote_get_list (2Q)
			//'cnm_cfg_remote_get_list'=>"SELECT a.id_remote_alert,a.type,a.subtype,a.action,a.descr,a.severity,ifnull(c.descr,'') as docu FROM cfg_remote_alerts a LEFT JOIN tips c on a.subtype=c.id_ref and c.tip_type='remote' and c.tip_class=1 WHERE type != 'cnm' order by a.descr",
			// 'cnm_cfg_remote_get_list'=>"SELECT a.id_remote_alert,a.type,a.subtype,a.action,a.descr,a.severity,ifnull(c.descr,'') as docu FROM cfg_remote_alerts a LEFT JOIN tips c on a.subtype=c.id_ref and c.tip_type='remote' WHERE type != 'cnm' order by a.descr",

         'cnm_cfg_remote_delete_temp' => "DROP TEMPORARY TABLE t1,t2",
			'cnm_cfg_remote_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_remote_alert,a.type,a.subtype,a.action,a.descr,a.severity,a.class,(SELECT ifnull(count(b.target),0) FROM cfg_remote_alerts2device b WHERE b.id_remote_alert=a.id_remote_alert)as cuantos,ifnull(c.descr,'') as docu FROM cfg_remote_alerts a LEFT JOIN tips c on a.subtype=c.id_ref and c.tip_type='remote' WHERE type != 'cnm' GROUP BY id_remote_alert)",

			'cnm_cfg_remote_create_temp_1' => "CREATE TEMPORARY TABLE t2 (SELECT a.id_remote_alert,ifnull(count(a.target),0) AS cuantos FROM cfg_remote_alerts2device a,devices b WHERE a.target=b.ip GROUP BY a.id_remote_alert)",
			// 'cnm_cfg_remote_create_temp_2' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_remote_alert,a.type,a.apptype,a.subtype,a.action,a.descr,a.severity,a.class,ifnull(b.cuantos,0) AS cuantos ,ifnull(c.descr,'') as docu FROM cfg_remote_alerts a LEFT JOIN t2 b ON a.id_remote_alert=b.id_remote_alert LEFT JOIN tips c on c.tip_type='remote' AND a.subtype=c.id_ref AND c.position=0 WHERE type != 'cnm')",
			'cnm_cfg_remote_create_temp_2' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_remote_alert,a.type,a.apptype,a.subtype,a.include,a.action,a.descr,a.severity,a.class,ifnull(b.cuantos,0) AS cuantos ,ifnull(c.descr,'') as docu FROM cfg_remote_alerts a LEFT JOIN t2 b ON a.id_remote_alert=b.id_remote_alert LEFT JOIN tips c on c.tip_type='remote' AND a.id_remote_alert=c.id_refn AND c.position=0 WHERE type != 'cnm' AND include=1)",
			'cnm_cfg_remote_create_temp_parkings' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_remote_alert,a.type,a.apptype,a.subtype,a.include,a.action,a.descr,a.severity,a.class,ifnull(b.cuantos,0) AS cuantos ,ifnull(c.descr,'') as docu FROM cfg_remote_alerts a LEFT JOIN t2 b ON a.id_remote_alert=b.id_remote_alert LEFT JOIN tips c on c.tip_type='remote' AND a.id_remote_alert=c.id_refn AND c.position=0 WHERE type != 'cnm')",
			'cnm_cfg_remote_get_list' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
		   'cnm_cfg_remote_count' => "SELECT COUNT(DISTINCT id_remote_alert) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

         'cnm_device_remote_delete_temp' => "DROP TEMPORARY TABLE t1,t2",
         'cnm_device_remote_create_temp_1' => "CREATE TEMPORARY TABLE t2 (SELECT 1 as asoc, a.id_remote_alert FROM cfg_remote_alerts2device a,devices b WHERE a.target=b.ip AND b.id_dev='__ID_DEV__')",
         'cnm_device_remote_create_temp_2' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_remote_alert,a.type,a.subtype,a.action,a.descr,a.severity,a.class,a.apptype,ifnull(b.asoc,0) AS asoc FROM cfg_remote_alerts a LEFT JOIN t2 b ON a.id_remote_alert=b.id_remote_alert WHERE type != 'cnm')",
         'cnm_device_remote_get_list' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
			'cnm_device_remote_apptypes' => "SELECT DISTINCT(apptype) FROM t1 ORDER BY apptype",
         'cnm_device_remote_count' => "SELECT COUNT(DISTINCT id_remote_alert) AS cuantos FROM t1 WHERE ''='' __CONDITION__",


			'cnm_cfg_remote_get_types'=>"SELECT DISTINCT(type) as type FROM cfg_remote_alerts WHERE type != 'cnm'",
			'cnm_cfg_remote_get_class'=>"SELECT DISTINCT(class) as class FROM cfg_remote_alerts WHERE type != 'cnm'",
			'cnm_cfg_remote_get_apptype'=>"SELECT DISTINCT(apptype) as apptype FROM cfg_remote_alerts ORDER BY apptype",
			'cnm_cfg_remote_info_by_subtype'=>"SELECT id_remote_alert,type,subtype,descr,monitor,vdata,severity,action,script,expr,mode,class,apptype FROM cfg_remote_alerts WHERE subtype='__SUBTYPE__'",
			'cnm_cfg_remote_info_email'=>"SELECT id_remote_alert,type,subtype,descr,monitor,vdata,severity,action,script,expr,mode,class,apptype FROM cfg_remote_alerts WHERE type='email'",
			'cnm_cfg_remote_info_by_logfile'=>"SELECT id_remote_alert,type,subtype,descr,monitor,vdata,severity,action,script,expr,mode,class,apptype FROM cfg_remote_alerts WHERE logfile='__LOGFILE__'",
			'cnm_cfg_remote_info_by_id'=>"SELECT id_remote_alert,type,subtype,descr,monitor,vdata,severity,action,script,expr,mode,apptype,hiid,vardata,itil_type,class,set_subtype FROM cfg_remote_alerts WHERE id_remote_alert IN (__ID_REMOTE_ALERT__)",
			"cnm_cfg_remote_get_all_id"=>"SELECT id_remote_alert FROM cfg_remote_alerts",
         // Obtiene el numero de alertas mapeadas a una determinada IP para el perfil organizativo definido
         'cnm_cfg_remote_get_count_by_id' => "SELECT count(DISTINCT c.target) AS cnt  FROM cfg_remote_alerts2device c,devices d,cfg_devices2organizational_profile o  WHERE (c.id_remote_alert=__ID_REMOTE_ALERT__ AND c.target=d.ip AND o.id_dev=d.id_dev AND o.id_cfg_op IN (__ORGPRO__) or (c.target='*' and c.id_remote_alert=__ID_REMOTE_ALERT__)) GROUP BY c.id_remote_alert",


         // ---------------------------------------------------------------------------------------
			// Se  usa para presentar la lista de alertas definidas cuando se configura una alerta como CLR
			// Es la lista de los nombres de alertas para ver cual hay que borrar
			// wsf: cnm_cfg_remote_get_list_lite (1Q)
			'cnm_cfg_remote_get_list_lite'=>"SELECT id_remote_alert,descr,subtype FROM cfg_remote_alerts WHERE type != 'cnm' AND action='SET' order by descr",

         // ---------------------------------------------------------------------------------------
         // Obtiene los datos de las alertas mapeadas a una determinada IP para el perfil organizativo definido
			// wsf: cnm_cfg_remote_get_alert_detail_by_id (1Q)
			'cnm_cfg_remote_get_alert_info_by_id'=>"SELECT type,subtype,action,descr,severity,vdata,mode,expr,class,set_id,hiid FROM cfg_remote_alerts WHERE id_remote_alert=__ID_REMOTE_ALERT__",

         // ---------------------------------------------------------------------------------------
         // Obtiene los datos de las expresiones asociadas a una determinada alerta remota
         // wsf: cnm_cfg_remote_get_expr_by_id (1Q)
         'cnm_cfg_remote_get_expr_by_id'=>"SELECT v,descr,fx,expr FROM cfg_remote_alerts2expr WHERE id_remote_alert=__ID_REMOTE_ALERT__",

	
         // ---------------------------------------------------------------------------------------
         // Obtiene los datos necesarios para calcular el subtype de la alerta por email.
         // wsf: cnm_cfg_remote_get_last_email_alert (1Q)
        	// 'cnm_cfg_remote_get_last_email_alert'=>"SELECT id_remote_alert,subtype FROM cfg_remote_alerts WHERE type='email' order by id_remote_alert desc limit 1",

         // ---------------------------------------------------------------------------------------
         // Obtiene los parametros del CLEAR correspondientes a una determinada alerta remota (SET)
         //'get_remote_alert_vdata_by_id'=>"SELECT action,vdata FROM cfg_remote_alerts WHERE id_remote_alert=__ID_REMOTE_ALERT__",

	
         // ---------------------------------------------------------------------------------------
         // Elimina la/las alertas remotas especificadas por su id
 			// (Borra alerta + Borra mapeo a dispositivos)
			// wsf: cnm_cfg_remote_delete (2Q)
         'cnm_cfg_remote_delete1'=>"DELETE FROM cfg_remote_alerts WHERE id_remote_alert in (:__ID_REMOTE_ALERT__)",
         'cnm_cfg_remote_delete2'=>"DELETE FROM cfg_remote_alerts2device WHERE id_remote_alert in (:__ID_REMOTE_ALERT__)",

	
// ---------------------------------------------------------------------------------------
// mod_remote_detalle.php
// ---------------------------------------------------------------------------------------

         // ---------------------------------------------------------------------------------------
         // Almacena (crea/modifica) la alerta remota
         // wsf: cnm_cfg_remote_store (4Q)
         // ---------------------------------------------------------------------------------------
         'cnm_cfg_remote_store_create'=>"INSERT INTO cfg_remote_alerts (type,subtype,descr,severity,action,expr,vdata,mode,hiid,class,apptype,set_id,set_type,set_subtype,set_hiid,logfile) VALUES ('__TYPE__', '__SUBTYPE__', '__DESCR__', '__SEVERITY__', '__ACTION__', '__EXPR__', '__VDATA__', '__MODE__','__HIID__','__CLASS__','__APPTYPE__','__SET_ID__','__SET_TYPE__','__SET_SUBTYPE__','__SET_HIID__','__LOGFILE__')",
         'cnm_cfg_remote_store_create_syslog'=>"INSERT INTO cfg_remote_alerts (type,subtype,descr,severity,action,expr,vdata,mode,hiid,class,apptype,set_id,set_type,set_subtype,set_hiid,logfile) VALUES ('__TYPE__', '__SUBTYPE__', '__DESCR__', '__SEVERITY__', '__ACTION__', '__EXPR__', '__VDATA__', '__MODE__','__HIID__','__CLASS__','__APPTYPE__','__SET_ID__','__SET_TYPE__','__SET_SUBTYPE__','__SET_HIID__','__LOGFILE__')",
         'cnm_cfg_remote_expr_store_create'=>"INSERT INTO cfg_remote_alerts2expr (v,descr,fx,expr) VALUES ('__V__', '__DESCR__', '__FX__', '__EXPR__')",

         'cnm_cfg_remote_store_update'=>"UPDATE cfg_remote_alerts SET type='__TYPE__', subtype='__SUBTYPE__', descr='__DESCR__', severity='__SEVERITY__', action='__ACTION__', expr='__EXPR__', vdata='__VDATA__', mode='__MODE__', class='__CLASS__', hiid='__HIID__',apptype='__APPTYPE__',set_id='__SET_ID__',set_type='__SET_TYPE__',set_subtype='__SET_SUBTYPE__',set_hiid='__SET_HIID__' WHERE id_remote_alert=__ID_REMOTE_ALERT__",
         'cnm_cfg_remote_store_update_syslog'=>"UPDATE cfg_remote_alerts SET descr='__DESCR__', severity='__SEVERITY__', action='__ACTION__', expr='__EXPR__', vdata='__VDATA__', mode='__MODE__', class='__CLASS__', hiid='__HIID__',apptype='__APPTYPE__',set_id='__SET_ID__',set_type='__SET_TYPE__',set_subtype='__SET_SUBTYPE__',set_hiid='__SET_HIID__' WHERE id_remote_alert=__ID_REMOTE_ALERT__",

         'cnm_cfg_remote_expr_store_update'=>"UPDATE cfg_remote_alerts2expr SET v='__V__', descr='__DESCR__', fx='__FX__', expr='__EXPR__' WHERE id_remote_alert=__ID_REMOTE_ALERT__",

			//Se hace de esta forma para no volver a crear las alertas existentes.
         'cnm_cfg_remote_expr_store'=>"INSERT INTO cfg_remote_alerts2expr (id_remote_alert,v,descr,fx,expr) VALUES (__ID_REMOTE_ALERT__,'__V__', '__DESCR__', '__FX__', '__EXPR__') ON DUPLICATE KEY UPDATE v='__V__', descr='__DESCR__', fx='__FX__', expr='__EXPR__', id_remote_alert=__ID_REMOTE_ALERT__",

			// Borrar todas las asociaciones entre una alerta remota y sus expresiones
			'cnm_cfg_remote_expr_remove'=>"DELETE FROM cfg_remote_alerts2expr WHERE id_remote_alert=__ID_REMOTE_ALERT__",

         // ---------------------------------------------------------------------------------------
         // Obtiene los datos de la alerta que se tiene que borrar en el caso CLR
         'cnm_cfg_remote_get_clr_data_id'=>"SELECT type,subtype,hiid FROM cfg_remote_alerts WHERE id_remote_alert=__ID_REMOTE_ALERT__",


// ---------------------------------------------------------------------------------------
// mod_remote_dispositivo.php
// ---------------------------------------------------------------------------------------

         // ---------------------------------------------------------------------------------------
         // Dispositivos asociados a una alerta remota
         // wsf: cnm_cfg_remote_get_devices (1Q)
         // ---------------------------------------------------------------------------------------
         // Obtiene la lista de dispositivos incluyendo un campo que indica si tiene o no asociada una alerta remota.
 //        'get_devices_by_remote_alerts'=>"SELECT d.id_dev,d.name,d.domain,d.ip,'1' as asoc,type,status FROM devices d WHERE ip IN (SELECT target FROM cfg_remote_alerts2device a, cfg_remote_alerts b WHERE a.id_remote_alert=b.id_remote_alert AND b.id_remote_alert=__ID_REMOTE_ALERT__)   UNION   SELECT d.id_dev,d.name,d.domain,d.ip,'0' as asoc,type,status FROM devices d WHERE ip NOT IN (SELECT target FROM cfg_remote_alerts2device a, cfg_remote_alerts b WHERE a.id_remote_alert=b.id_remote_alert AND b.id_remote_alert=__ID_REMOTE_ALERT__)",

         // wsf: cnm_cfg_remote_get_included_devices(1Q)
         'cnm_cfg_remote_get_included_devices'=>"SELECT id_dev FROM devices WHERE ip IN (SELECT target FROM cfg_remote_alerts2device a, cfg_remote_alerts b WHERE a.id_remote_alert=b.id_remote_alert AND b.id_remote_alert=__ID_REMOTE_ALERT__)",


         // ---------------------------------------------------------------------------------------
         // Incluye un dispositivo a una alerta remota (asocia)
         // wsf: cnm_cfg_remote_include_device (1Q)
         // ---------------------------------------------------------------------------------------
         'cnm_cfg_remote_include_device'=>"INSERT INTO cfg_remote_alerts2device (id_remote_alert,target) VALUES (__ID_REMOTE_ALERT__, '__TARGET__') ON DUPLICATE KEY UPDATE id_remote_alert=__ID_REMOTE_ALERT__, target='__TARGET__'",

         // ---------------------------------------------------------------------------------------
         // Excluye un dispositivo de una alerta remota (desasocia)
         // wsf: cnm_cfg_remote_exclude_device (1Q)
         // ---------------------------------------------------------------------------------------
         'cnm_cfg_remote_exclude_device'=>"DELETE FROM cfg_remote_alerts2device WHERE id_remote_alert=__ID_REMOTE_ALERT__ and target='__TARGET__'",


         // ---------------------------------------------------------------------------------------
         // Funcion auxiliar para include/exclude que obtiene la lista de ips posibles del dispositivo
         'cnm_cfg_devices_get_ip_list'=>"SELECT ip FROM devices WHERE id_dev=__ID_DEV__",

 /**
	* **************************************************************** *
	* Modulo: mod_avisos.sql

shtml/mod_avisos_layout.shtml  			->	mod_avisos_layout.php
shtml/mod_avisos_detalle.shtml			->	mod_avisos_detalle.php
shtml/mod_avisos_dispositivo.shtml		->	mod_avisos_dispositivo.php
shtml/mod_avisos_transporte.shtml		-> mod_avisos_transporte.php
shtml/mod_avisos_documentacion.shtml	->	mod_avisos_documentacion.php

	* **************************************************************** *
	*/

// ---------------------------------------------------------------------------------------
// mod_avisos_lista.php
// ---------------------------------------------------------------------------------------

			// ---------------------------------------------------------------------------------------
			// Listado de avisos definidos
			// wsf: cnm_cfg_notification_get_list (3Q)
			// ---------------------------------------------------------------------------------------
			'cnm_cfg_notification_delete_temp'=>"DROP TEMPORARY TABLE t1,t2,t3,t4,t5,t6,t7",

			'cnm_cfg_notification_create_temp1'=>"CREATE TEMPORARY TABLE t2 SELECT count(DISTINCT a.id_device) AS cuantos, id_cfg_notification FROM cfg_notification2device a, devices b, cfg_devices2organizational_profile c WHERE a.id_device=b.id_dev AND b.id_dev=c.id_dev AND c.id_cfg_op IN (__ORGPRO__) GROUP BY a.id_cfg_notification",
         'cnm_cfg_notification_create_temp2'=>"CREATE TEMPORARY TABLE t3(SELECT a.id_cfg_notification, a.destino, a.name as aviso,b.cause,'monitor' AS type FROM (cfg_notifications a, alert_type b) WHERE a.monitor=b.monitor) UNION (SELECT a.id_cfg_notification, a.destino, a.name as aviso,b.description as cause,'metric' AS type FROM (cfg_notifications a, cfg_monitor b) WHERE a.monitor=b.monitor) UNION (SELECT a.id_cfg_notification,a.destino, a.name as aviso,b.descr as cause,'remote' AS type FROM (cfg_notifications a, cfg_remote_alerts b) WHERE a.monitor=b.id_remote_alert)",
         'cnm_cfg_notification_create_temp3'=>"CREATE TEMPORARY TABLE t4(SELECT id_cfg_notification,GROUP_CONCAT(CONCAT('EMAIL: ',b.name) SEPARATOR '<hr color=\"#89A5B1\" style=\"border-top-width: 0;\"/>') as mail FROM cfg_notification2transport a LEFT JOIN cfg_register_transports b ON a.id_register_transport=b.id_register_transport WHERE b.id_notification_type=1 group by id_cfg_notification,id_notification_type)",
         'cnm_cfg_notification_create_temp4'=>"CREATE TEMPORARY TABLE t5(SELECT id_cfg_notification,GROUP_CONCAT(CONCAT('SMS: ',b.name) SEPARATOR '<hr color=\"#89A5B1\" style=\"border-top-width: 0;\"/>') as sms FROM cfg_notification2transport a LEFT JOIN cfg_register_transports b ON a.id_register_transport=b.id_register_transport WHERE b.id_notification_type=2 group by id_cfg_notification,id_notification_type)",
         'cnm_cfg_notification_create_temp5'=>"CREATE TEMPORARY TABLE t6(SELECT id_cfg_notification,GROUP_CONCAT(CONCAT('TRAP: ',b.name) SEPARATOR '<hr color=\"#89A5B1\" style=\"border-top-width: 0;\"/>') as trap FROM cfg_notification2transport a LEFT JOIN cfg_register_transports b ON a.id_register_transport=b.id_register_transport WHERE b.id_notification_type=3 group by id_cfg_notification,id_notification_type)",
			// 'cnm_cfg_notification_create_temp6'=>"CREATE TEMPORARY TABLE t7(SELECT GROUP_CONCAT(CONCAT('- ',a.name) SEPARATOR '<br>') AS name,b.id_cfg_notification FROM cfg_monitor_apps a,cfg_notification2app b WHERE a.id_monitor_app=b.id_monitor_app) ",
			'cnm_cfg_notification_create_temp6'=>"CREATE TEMPORARY TABLE t7(SELECT GROUP_CONCAT(a.name SEPARATOR '<hr color=\"#89A5B1\" style=\"border-top-width: 0;\"/>') AS name,b.id_cfg_notification FROM cfg_monitor_apps a,cfg_notification2app b WHERE a.id_monitor_app=b.id_monitor_app group by id_cfg_notification)",
         'cnm_cfg_notification_create_temp7'=>"CREATE TEMPORARY TABLE t1(SELECT t3.*,mail,sms,trap,CONCAT(IFNULL(mail,''),'<br>',IFNULL(sms,''),'<br>',IFNULL(trap,'')) as transport,ifnull(cuantos,0) as cuantos,t7.name AS app FROM t3 LEFT JOIN t2 ON t3.id_cfg_notification=t2.id_cfg_notification LEFT JOIN t4 ON t3.id_cfg_notification=t4.id_cfg_notification LEFT JOIN t5 ON t3.id_cfg_notification=t5.id_cfg_notification LEFT JOIN t6 ON t3.id_cfg_notification=t6.id_cfg_notification LEFT JOIN t7 ON t3.id_cfg_notification=t7.id_cfg_notification)",
         'cnm_cfg_notification_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_cfg_notification_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

			'cnm_cfg_notification_get_transport' =>"SELECT id_cfg_notification,b.id_notification_type,GROUP_CONCAT(b.name SEPARATOR '<br>') as name FROM cfg_notification2transport a LEFT JOIN cfg_register_transports b ON a.id_register_transport=b.id_register_transport group by id_cfg_notification,id_notification_type",
         'cnm_cfg_notification_update'=>"UPDATE t1 SET mail='__MAIL__',sms='__SMS__',trap='__TRAP__' WHERE id_cfg_notification IN (__ID_CFG_NOTIFICATION__)",
         // ---------------------------------------------------------------------------------------
         // Borrar los avisos especificados por su id_cfg_notification
			// wsf: cnm_cfg_notification_delete (3Q)
			// ---------------------------------------------------------------------------------------
         // Obtener el id_alert_type de un monitor en base a su campo monitor
         'cnm_cfg_notification_delete_get_id_cfg_notification'=>"SELECT id_cfg_notification FROM cfg_notifications WHERE id_alert_type in (:__ID_ALERT_TYPE__)",
         'a_cnm_cfg_notification_delete_get_id_cfg_notification'=>"SELECT id_cfg_notification FROM cfg_notifications WHERE id_alert_type in (__ID_ALERT_TYPE__)",

         // Borrar la asociacion entre todos los dispositivos donde exista y el aviso para los id_cfg_notification especificados
         'cnm_cfg_notification_delete1'=>"DELETE FROM cfg_notification2device WHERE id_cfg_notification IN (:__ID_CFG_NOTIFICATION__)",
         'a_cnm_cfg_notification_delete1'=>"DELETE FROM cfg_notification2device WHERE id_cfg_notification IN (__ID_CFG_NOTIFICATION__)",

         // Borrar los avisos especificados por su id_cfg_notification
         'cnm_cfg_notification_delete2'=>"DELETE FROM cfg_notifications WHERE id_cfg_notification IN (:__ID_CFG_NOTIFICATION__)",
         'a_cnm_cfg_notification_delete2'=>"DELETE FROM cfg_notifications WHERE id_cfg_notification IN (__ID_CFG_NOTIFICATION__)",

         // Borrar los avisos producidos por su id_cfg_notification
         'cnm_cfg_notification_delete3'=>"DELETE FROM notifications WHERE id_cfg_notification IN (:__ID_CFG_NOTIFICATION__)",
         'a_cnm_cfg_notification_delete3'=>"DELETE FROM notifications WHERE id_cfg_notification IN (__ID_CFG_NOTIFICATION__)",



// ---------------------------------------------------------------------------------------
// mod_avisos_detalle.php
// ---------------------------------------------------------------------------------------

			// ---------------------------------------------------------------------------------------
         // Obtiene todas las alertas definidas en el sistema.
			// Necesario para poder asignarles un aviso.
			// wsf: cnm_cfg_notification_get_source_alerts (1Q)
			// ---------------------------------------------------------------------------------------
         'cnm_cfg_notification_get_source_alerts_delete_temp'=>"DROP TEMPORARY TABLE t1",
			'cnm_cfg_notification_get_source_alerts_create_temp_1'=>"CREATE TEMPORARY TABLE t1 (SELECT 0 AS radio,monitor,description as cause,'icmp_metric' AS type,severity,'' AS expr FROM cfg_monitor WHERE monitor like 'w_%') UNION (SELECT 0 AS radio,monitor,description as cause,'icmp_agent' AS type,severity,'' AS expr FROM cfg_monitor WHERE  monitor IN ('mon_icmp','disp_icmp')) UNION (SELECT 0 AS radio,monitor,description as cause,'snmp_agent' AS type,severity,'' AS expr FROM cfg_monitor WHERE monitor='mon_snmp') UNION (SELECT 0 AS radio,monitor ,cause, 'monitor' AS type,severity,expr FROM alert_type WHERE monitor like 's_%' AND hide=0) UNION (SELECT 0 AS radio, id_remote_alert as monitor,descr as cause,'remote_alert' AS type,severity,'' AS expr FROM cfg_remote_alerts WHERE type !='cnm' ORDER BY cause)",
         'cnm_cfg_notification_get_source_alerts_create_temp_2'=>"UPDATE t1 SET radio=1 WHERE monitor='__MONITOR__'",
         'cnm_cfg_notification_get_source_alerts_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_cfg_notification_get_all' => "SELECT * FROM t1",
         'cnm_cfg_notification_get_source_alerts_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

         'cnm_cfg_notification_get_source_alerts'=>"(SELECT monitor,description as cause,'icmp_metric' AS type FROM cfg_monitor WHERE monitor like 'w_%') UNION (SELECT monitor,description as cause,'icmp_agent' AS type FROM cfg_monitor WHERE  monitor='mon_icmp') UNION (SELECT monitor,description as cause,'snmp_agent' AS type FROM cfg_monitor WHERE monitor='mon_snmp') UNION (SELECT monitor ,cause, 'monitor' AS type FROM alert_type WHERE monitor like 's_%') UNION (SELECT subtype as monitor,descr as cause,'remote_alert' AS type FROM cfg_remote_alerts ORDER BY cause)",


			// ---------------------------------------------------------------------------------------
			// Guardar aviso (crear/modificar)
			// wsf: cnm_cfg_notification_store (4Q)
			// ---------------------------------------------------------------------------------------

         // Obtener el id_alert_type de un monitor en base a su campo monitor
         'cnm_cfg_notification_store_get_id_alert'=>"select id_alert_type from alert_type where monitor='__MONITOR__'",

         // ---------------------------------------------------------------------------------------
         // Crear un aviso
			'cnm_cfg_notification_store_create'=>"INSERT INTO cfg_notifications (monitor,type,type_app,type_run,name,id_alert_type,severity) VALUES ('__MONITOR__','__TYPE__','__TYPE_APP__','__TYPE_RUN__','__NAME__','__ID_ALERT_TYPE__','__SEVERITY__')",
			// ---------------------------------------------------------------------------------------
         // Modificar un aviso
			'cnm_cfg_notification_store_update'=>"UPDATE cfg_notifications SET monitor='__MONITOR__', type='__TYPE__', type_app='__TYPE_APP__', type_run='__TYPE_RUN__', name='__NAME__', id_alert_type='__ID_ALERT_TYPE__',severity='__SEVERITY__' WHERE id_cfg_notification='__ID_CFG_NOTIFICATION__'",
			'cnm_cfg_notification2device_update_mname'=>"UPDATE cfg_notification2device SET mname='__MNAME__' WHERE id_cfg_notification='__ID_CFG_NOTIFICATION__'",

         // ---------------------------------------------------------------------------------------
         // Obtener el id_cfg_notification del ultimo aviso creado
         'cnm_cfg_notification_store_get_id'=>"select max(id_cfg_notification) as id_cfg_notification from cfg_notifications",



         // ---------------------------------------------------------------------------------------
         // Obtener informacion de un aviso en base a su id_cfg_notification
			// wsf: cnm_cfg_notification_get_info (1Q)
         // ---------------------------------------------------------------------------------------
			'cnm_cfg_notification_store_get_info1'=>"SELECT a.id_cfg_notification,a.id_alert_type,a.type,a.type_app,a.type_run,a.id_notification_type,a.name,a.destino,a.status,a.monitor,a.severity FROM cfg_notifications a WHERE a.id_cfg_notification='__ID_CFG_NOTIFICATION__'",
         // ---------------------------------------------------------------------------------------
         // Obtener la descripcion (causa) de la alerta asociada a un determinado aviso
         'cnm_cfg_notification_store_get_info2' => "(SELECT b.descr as cause FROM cfg_notifications a, cfg_remote_alerts b WHERE  a.id_cfg_notification=__ID_CFG_NOTIFICATION__ and a.monitor=b.id_remote_alert) UNION (SELECT b.cause FROM cfg_notifications a, alert_type b WHERE  a.id_cfg_notification=__ID_CFG_NOTIFICATION__ and a.monitor=b.monitor) UNION (SELECT b.description as cause FROM cfg_notifications a, cfg_monitor b WHERE a.id_cfg_notification=__ID_CFG_NOTIFICATION__ and a.monitor=b.monitor)",

         // ---------------------------------------------------------------------------------------
         // Obtener los transportes asociados  una determinado aviso
         'cnm_cfg_notification_store_get_registered_transports_by_id' => "SELECT id_register_transport FROM cfg_notification2transport WHERE id_cfg_notification=__ID_CFG_NOTIFICATION__",
			// Obtener las aplicaciones asociadas a un determinado aviso
			'cnm_cfg_notification_store_get_app_by_id'=>"SELECT id_monitor_app FROM cfg_notification2app WHERE id_cfg_notification=__ID_CFG_NOTIFICATION__",
         // ---------------------------------------------------------------------------------------
         // Obtener los transportes asociados a una tarea
         'cnm_cfg_task_transports_by_id' => "SELECT id_register_transport FROM cfg_task2transport WHERE id_cfg_task_configured=__ID_CFG_TASK_CONFIGURED__",
         'cnm_cfg_task_transports_by_id_count' => "SELECT COUNT(*) AS cuantos FROM cfg_task2transport WHERE id_cfg_task_configured=__ID_CFG_TASK_CONFIGURED__",
			'cnm_cfg_task_transports_delete' => "DELETE FROM cfg_task2transport WHERE id_cfg_task_configured=__ID_CFG_TASK_CONFIGURED__",
			'cnm_cfg_task_transports_insert' => "INSERT INTO cfg_task2transport (id_cfg_task_configured,id_register_transport) VALUES (__ID_CFG_TASK_CONFIGURED__,__ID_REGISTER_TRANSPORT__)",

         // ---------------------------------------------------------------------------------------
         // Obtener el id (monitor) de la alerta asociada a un determinado aviso
         'cnm_cfg_notification_store_get_alert_monitor' => "SELECT monitor,severity FROM cfg_notifications WHERE id_cfg_notification=__ID_CFG_NOTIFICATION__",


			'cnm_cfg_notification_store_get_alert_transports_telegram' => "SELECT a.id_register_transport,b.name as tipo,a.name,a.value FROM cfg_register_transports a, notification_type b WHERE a.id_notification_type=b.id_notification_type AND a.id_notification_type IN (4)",
			'cnm_cfg_notification_store_get_alert_transports_sms' => "SELECT a.id_register_transport,b.name as tipo,a.name,a.value FROM cfg_register_transports a, notification_type b WHERE a.id_notification_type=b.id_notification_type AND a.id_notification_type IN (2)",
			'cnm_cfg_notification_store_get_alert_transports_mail' => "SELECT a.id_register_transport,b.name as tipo,a.name,a.value FROM cfg_register_transports a, notification_type b WHERE a.id_notification_type=b.id_notification_type AND a.id_notification_type IN (1)",
			'cnm_cfg_notification_store_get_alert_transports' => "SELECT a.id_register_transport,b.name as tipo,a.name,a.value FROM cfg_register_transports a, notification_type b WHERE a.id_notification_type=b.id_notification_type AND a.id_notification_type IN (1,2)",
			'cnm_cfg_notification_store_get_info_transport'=>"SELECT id_register_transport,id_notification_type,value,name FROM cfg_register_transports WHERE id_register_transport IN (__ID_REGISTER_TRANSPORT__)",
			
         // ---------------------------------------------------------------------------------------
         // Obtener los transportes registrados en el sistema
         'cnm_cfg_notification_store_get_all_registered_transports' => "SELECT a.id_register_transport,b.name as tipo,a.name,a.value,a.id_notification_type as idnotif FROM cfg_register_transports a, notification_type b WHERE a.id_notification_type=b.id_notification_type",

         // Obtener las aplicaciones registradas en el sistema
         'cnm_cfg_notification_store_get_all_app' => "SELECT id_monitor_app,type,subtype,name FROM cfg_monitor_apps WHERE ready=1",

         // ---------------------------------------------------------------------------------------
         // Obtener los dispositivos asociados a un aviso
         'cnm_cfg_notification_store_get_asociated_devices_by_id' =>"SELECT d.status,d.name,d.ip,d.type FROM devices d, cfg_notification2device c WHERE d.id_dev=c.id_device and id_cfg_notification=__ID_CFG_NOTIFICATION__",



// ---------------------------------------------------------------------------------------
// mod_avisos_dispositivo.php
// ---------------------------------------------------------------------------------------

			// ---------------------------------------------------------------------------------------
         // Dispositivos asociados a un aviso
			// wsf: cnm_cfg_notification_get_devices (1Q)
         // ---------------------------------------------------------------------------------------
         'cnm_cfg_notification_get_included_devices' => "SELECT id_device as id_dev FROM cfg_notification2device WHERE id_cfg_notification IN (__ID_CFG_NOTIFICATION__)",
			'cnm_common_get_devices_delete_temp' => "DROP TEMPORARY TABLE t1",
			'cnm_cfg_notification_get_devices_visible' => "(SELECT id_dev FROM metrics a,cfg_notifications b WHERE a.name=b.monitor AND b.id_cfg_notification=__ID_CFG_NOTIFICATION__) UNION (SELECT id_dev FROM metrics a,cfg_notifications b WHERE a.watch=b.monitor AND b.id_cfg_notification=__ID_CFG_NOTIFICATION__)",
			'cnm_cfg_notification_get_devices_asoc' => "SELECT a.id_device as id_dev FROM cfg_notification2device a WHERE a.id_cfg_notification=__ID_CFG_NOTIFICATION__",
			// 'cnm_get_devices_common_create_temp' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,a.name,a.domain,a.ip,a.type,a.status,xagent_version,a.sysoid,a.sysdesc,a.sysloc,a.mac,0 as asoc__USER_FIELDS__ FROM devices a LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev IN (__ID_DEV_VISIBLE__)",
			'cnm_get_devices_common_create_temp' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,a.name,a.domain,a.ip,a.type,a.status,xagent_version,a.sysoid,a.sysdesc,a.sysloc,IF(a.mac_vendor='-',a.mac,IF(a.mac='',a.mac_vendor,CONCAT(a.mac_vendor,'<br> ',a.mac))) AS mac ,0 as asoc__USER_FIELDS__ FROM devices a LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev IN (__ID_DEV_VISIBLE__)",
			// 'cnm_get_devices_common_create_temp' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,a.name,a.domain,a.ip,a.type,a.status,0 as asoc FROM devices a WHERE a.id_dev IN (__ID_DEV_VISIBLE__)",
			'cnm_get_devices_common_update_temp' => "UPDATE t1 SET asoc=1 WHERE id_dev IN (__ID_DEV_ASOC__)",
			// 'cnm_get_devices_common_lista' => "SELECT id_dev,name,domain,ip,type,status,asoc FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
			'cnm_get_devices_common_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
			'cnm_get_devices_common_count' => "SELECT COUNT(DISTINCT id_dev) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
         // ---------------------------------------------------------------------------------------
         // Dispositivos asociados a una alerta remota
         // ---------------------------------------------------------------------------------------
         // 'cnm_cfg_remote_get_devices_visible' => 'SELECT a.id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)',
         'cnm_cfg_remote_get_devices_visible' => 'SELECT DISTINCT(a.id_dev) AS id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)',
         'cnm_cfg_remote_get_devices_asoc' => "SELECT id_dev FROM devices WHERE ip IN (SELECT target FROM cfg_remote_alerts2device a, cfg_remote_alerts b WHERE a.id_remote_alert=b.id_remote_alert AND b.id_remote_alert=__ID_REMOTE_ALERT__)",
         // ---------------------------------------------------------------------------------------
         // Dispositivos asociados a una métrica de tipo latency
         // ---------------------------------------------------------------------------------------
         // 'cnm_cfg_latency_get_devices_visible' => 'SELECT a.id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)',
         'cnm_cfg_latency_get_devices_visible' => 'SELECT DISTINCT(a.id_dev) AS id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)',
         'cnm_cfg_latency_get_devices_asoc' => "SELECT id_dev FROM prov_template_metrics2iid a,cfg_monitor b WHERE a.mname=b.monitor AND b.id_cfg_monitor=__ID_CFG_MONITOR__ AND a.status=0",
			// ---------------------------------------------------------------------------------------
         // Dispositivos asociados a una métrica de tipo snmp
         // ---------------------------------------------------------------------------------------
         // 'cnm_cfg_snmp_get_devices_visible' => 'SELECT a.id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.version!=0 AND a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)',
         'cnm_cfg_snmp_get_devices_visible' => 'SELECT DISTINCT(a.id_dev) AS id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.version!=0 AND a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)',
         'cnm_cfg_snmp_get_devices_asoc' => "SELECT id_dev FROM prov_template_metrics2iid a,cfg_monitor_snmp b WHERE a.mname=b.subtype AND b.id_cfg_monitor_snmp=__ID_CFG_MONITOR_SNMP__ AND a.status=0",
         // ---------------------------------------------------------------------------------------
         // Dispositivos asociados a una tarea
         // ---------------------------------------------------------------------------------------
         'cnm_cfg_task_get_devices_visible' => "SELECT id_dev FROM devices",
         'cnm_cfg_task_get_devices_asoc' => "SELECT id_dev FROM task2device WHERE name LIKE '__SUBTYPE__' AND type='device'",
         // ---------------------------------------------------------------------------------------
         // Dispositivos asociados a una metrica de tipo agente
         // ---------------------------------------------------------------------------------------
         // 'cnm_cfg_xagt_proxy_get_devices_visible' => "SELECT a.id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
         'cnm_cfg_xagt_proxy_get_devices_visible' => "SELECT DISTINCT(a.id_dev) AS id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
         // 'cnm_cfg_xagt_get_devices_visible' => "SELECT a.id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.xagent_version LIKE 'CNMAgent%' AND a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
         'cnm_cfg_xagt_get_devices_visible' => "SELECT DISTINCT(a.id_dev) AS id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.xagent_version LIKE 'CNMAgent%' AND a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
         'cnm_cfg_xagt_get_devices_asoc' => "SELECT id_dev FROM prov_template_metrics2iid a,cfg_monitor_agent b WHERE a.mname=b.subtype AND b.id_cfg_monitor_agent=__ID_CFG_MONITOR_AGENT__ AND a.status=0",

         // ---------------------------------------------------------------------------------------
         // Obtiene el numero de dispositivos incluidos en un aviso
         // wsf: cnm_cfg_notification_get_included_devices_count (1Q)
         // ---------------------------------------------------------------------------------------
         'cnm_cfg_notification_get_included_devices_count'=>"SELECT count(*) as counter FROM cfg_notification2device WHERE id_cfg_notification='__ID_CFG_NOTIFICATION__'",


// -----
         'cnm_get_devices_tree_common_delete_temp' => "DROP TEMPORARY TABLE t1",
			// 'cnm_get_devices_tree_common_create_temp' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,a.name,a.domain,a.ip,a.type,a.xagent_version,a.sysoid,a.sysdesc,a.sysloc,a.status,a.mac,0 as cuantos__USER_FIELDS__ FROM devices a LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev IN (__ID_DEV_VISIBLE__)",
			'cnm_get_devices_tree_common_create_temp' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,a.name,a.domain,a.ip,a.type,a.xagent_version,a.sysoid,a.sysdesc,a.sysloc,a.status,IF(a.mac_vendor='-',a.mac,IF(a.mac='',a.mac_vendor,CONCAT(a.mac_vendor,'<br> ',a.mac))) AS mac,0 as cuantos__USER_FIELDS__ FROM devices a LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev IN (__ID_DEV_VISIBLE__)",
         'cnm_get_devices_tree_common_update_temp' => "UPDATE t1 SET cuantos=__CUANTOS__ WHERE id_dev IN (__ID_DEV__)",
         'cnm_get_devices_tree_common_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_get_devices_tree_common_count' => "SELECT COUNT(DISTINCT id_dev) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

// -----
         'cnm_get_devices_layout_delete_temp' => "DROP TEMPORARY TABLE t1,t2",
         // 'cnm_get_devices_layout_create_temp' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,a.name,a.domain,a.ip,a.type,a.xagent_version,a.status,0 AS yellow,0 AS orange,0 AS red,0 AS blue,0 as cuantos__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
         'cnm_get_devices_layout_create_temp' => "CREATE TEMPORARY TABLE t1 SELECT DISTINCT(a.id_dev) AS id_dev,a.name,a.domain,a.ip,a.type,a.xagent_version,a.status,0 AS yellow,0 AS orange,0 AS red,0 AS blue,0 as cuantos__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",


         'cnm_get_devices_layout_delete_temp_all' => "DROP TEMPORARY TABLE t1,t_metrics,t_red,t_orange,t_yellow,t_blue",
         'cnm_get_devices_layout_create_temp_metrics' => "CREATE TEMPORARY TABLE t_metrics (INDEX (id_dev)) SELECT count(*) AS cuantos,id_dev FROM metrics GROUP BY id_dev",
			'cnm_get_devices_layout_create_temp_red' => "CREATE TEMPORARY TABLE t_red (UNIQUE KEY (id_device)) SELECT id_device,severity,count(id_alert) as cuantos FROM alerts WHERE counter>0 and severity=1 GROUP BY id_device",
			'cnm_get_devices_layout_create_temp_orange' => "CREATE TEMPORARY TABLE t_orange (UNIQUE KEY (id_device)) SELECT id_device,severity,count(id_alert) as cuantos FROM alerts WHERE counter>0 and severity=2 GROUP BY id_device",
			'cnm_get_devices_layout_create_temp_yellow' => "CREATE TEMPORARY TABLE t_yellow (UNIQUE KEY (id_device)) SELECT id_device,severity,count(id_alert) as cuantos FROM alerts WHERE counter>0 and severity=3 GROUP BY id_device",
			'cnm_get_devices_layout_create_temp_blue' => "CREATE TEMPORARY TABLE t_blue (UNIQUE KEY (id_device)) SELECT id_device,severity,count(id_alert) as cuantos FROM alerts WHERE counter>0 and severity=4 GROUP BY id_device",
         'cnm_get_devices_layout_create_temp_t1' => "CREATE TEMPORARY TABLE t1 SELECT DISTINCT(a.id_dev) AS id_dev,0 AS asoc,a.name,a.critic,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.network,a.sysdesc,a.version,a.entity,a.sysloc,IF(a.mac_vendor='-',a.mac,IF(a.mac='',a.mac_vendor,CONCAT(a.mac_vendor,'<br> ',a.mac))) AS mac,IFNULL(t_yellow.cuantos,0) AS yellow,IFNULL(t_orange.cuantos,0) AS orange,IFNULL(t_red.cuantos,0) AS red,IFNULL(t_blue.cuantos,0) AS blue,IFNULL(t_metrics.cuantos,0) as cuantos__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev LEFT JOIN t_metrics ON a.id_dev=t_metrics.id_dev LEFT JOIN t_red ON a.id_dev=t_red.id_device LEFT JOIN t_orange ON a.id_dev=t_orange.id_device LEFT JOIN t_yellow ON a.id_dev=t_yellow.id_device LEFT JOIN t_blue ON a.id_dev=t_blue.id_device WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__'",




         // 'cnm_get_devices_layout_create_temp1' => "CREATE TEMPORARY TABLE t2 SELECT count(*) AS num_metricas,id_dev FROM metrics GROUP BY id_dev",
         'cnm_get_devices_layout_create_temp1' => "CREATE TEMPORARY TABLE t2 (INDEX (id_dev)) SELECT count(*) AS num_metricas,id_dev FROM metrics GROUP BY id_dev",
         // 'cnm_get_devices_layout_create_temp2' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,0 AS asoc,a.name,a.critic,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.network,a.sysdesc,a.version,a.entity,a.sysloc,IF(a.mac_vendor='-',a.mac,IF(a.mac='',a.mac_vendor,CONCAT(a.mac_vendor,'<br> ',a.mac))) AS mac,0 AS yellow,0 AS orange,0 AS red,0 AS blue,IFNULL(num_metricas,0) as cuantos__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev LEFT JOIN t2 ON a.id_dev=t2.id_dev WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__'",
         'cnm_get_devices_layout_create_temp2' => "CREATE TEMPORARY TABLE t1 SELECT DISTINCT(a.id_dev) AS id_dev,0 AS asoc,a.name,a.critic,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.network,a.sysdesc,a.version,a.entity,a.sysloc,IF(a.mac_vendor='-',a.mac,IF(a.mac='',a.mac_vendor,CONCAT(a.mac_vendor,'<br> ',a.mac))) AS mac,0 AS yellow,0 AS orange,0 AS red,0 AS blue,IFNULL(num_metricas,0) as cuantos__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev LEFT JOIN t2 ON a.id_dev=t2.id_dev WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__'",
         'cnm_get_devices_layout_broupby' => "SELECT COUNT(DISTINCT id_dev) AS cuantos,__FIELD__,GROUP_CONCAT(id_dev) AS id_dev FROM t1 GROUP BY __FIELD__",
         'cnm_get_devices_layout_get_by_field' => "SELECT * FROM t1 WHERE __FIELD__='__FIELD_VALUE__' ORDER BY name",
         'cnm_get_devices_layout_update_temp' => "UPDATE t1 SET red=__RED__,orange=__ORANGE__,yellow=__YELLOW__,blue=__BLUE__ WHERE id_dev IN (__ID_DEV__)",
         'cnm_get_devices_layout_get_cuantos' => "SELECT COUNT(id_metric) AS cuantos,id_dev FROM metrics WHERE status=0 GROUP BY id_dev;",
         'cnm_get_devices_layout_update_temp_cuantos' => "UPDATE t1 SET cuantos=__CUANTOS__ WHERE id_dev IN (__ID_DEV__)",
         // 'cnm_get_devices_layout_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_get_devices_layout_lista' => "SELECT * FROM t1 WHERE __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_get_devices_layout_count' => "SELECT COUNT(DISTINCT id_dev) AS cuantos FROM t1 WHERE __CONDITION__",
			'cnm_get_devices_layout_get_all' => "SELECT * FROM t1 ORDER BY name",
// -----
         'cnm_get_devices_report_delete_temp' => "DROP TEMPORARY TABLE t1,t2",
         'cnm_get_devices_report_create_temp1' => "CREATE TEMPORARY TABLE t2 SELECT value AS id_dev,1 AS asoc FROM cfg_report2config WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__' AND cfg_table='device' AND field='id_dev' AND type=0",
         // 'cnm_get_devices_report_create_temp2' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,a.name,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.sysdesc,a.version,a.sysloc,a.mac,0 AS yellow,0 AS orange,0 AS red,0 AS blue,IFNULL(asoc,0) as asoc__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev LEFT JOIN t2 ON a.id_dev=t2.id_dev WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__'",
         'cnm_get_devices_report_create_temp2' => "CREATE TEMPORARY TABLE t1 SELECT DISTINCT(a.id_dev) AS id_dev,a.name,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.sysdesc,a.version,a.sysloc,a.mac,0 AS yellow,0 AS orange,0 AS red,0 AS blue,IFNULL(asoc,0) as asoc__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev LEFT JOIN t2 ON a.id_dev=t2.id_dev WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__'",
			'update_asoc'=>"UPDATE t1 SET asoc=1 WHERE id_dev IN (__ID_DEV__)",
         'cnm_get_devices_report_update_temp' => "UPDATE t1 SET red=__RED__,orange=__ORANGE__,yellow=__YELLOW__,blue=__BLUE__ WHERE id_dev IN (__ID_DEV__)",
         'cnm_get_devices_report_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_get_devices_report_count' => "SELECT COUNT(DISTINCT id_dev) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
// -----
// Solapa de métricas en el report de capacidad de disco
// -----
         'cnm_get_capacity_disk_report_delete_temp' => "DROP TEMPORARY TABLE IF EXISTS t1,t2",
         'cnm_get_capacity_disk_report_create_temp1' => "CREATE TEMPORARY TABLE t2 SELECT value AS id_metric,1 AS asoc FROM cfg_report2config WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__' AND cfg_table='metric' AND field='id_metric' AND type=0",
         'cnm_get_capacity_disk_report_create_temp2' => "CREATE TEMPORARY TABLE t1 SELECT DISTINCT(b.id_metric) AS id_metric,b.label,a.id_dev,a.name,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.sysdesc,a.version,a.sysloc,a.mac,0 AS yellow,0 AS orange,0 AS red,0 AS blue,IFNULL(asoc,0) as asoc__USER_FIELDS__ FROM (devices a,metrics b,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev LEFT JOIN t2 ON b.id_metric=t2.id_metric WHERE a.id_dev=b.id_dev AND a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__' AND b.subtype='disk_mibhost'",
         'cnm_get_capacity_disk_report_update_asoc'=>"UPDATE t1 SET asoc=1 WHERE id_metric IN (__ID_METRIC__)",
         'cnm_get_capacity_disk_report_update_temp' => "UPDATE t1 SET red=__RED__,orange=__ORANGE__,yellow=__YELLOW__,blue=__BLUE__ WHERE id_dev IN (__ID_DEV__)",
         'cnm_get_capacity_disk_report_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_get_capacity_disk_report_count' => "SELECT COUNT(DISTINCT id_metric) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

// -----
			'duplicate_report' => "INSERT INTO cfg_report (subtype_cfg_report,title,description,custom,itil_type,apptype,store,logic) (SELECT '__NEW_SUBTYPE_CFG_REPORT__',(CONCAT(title,' - COPIA')),description,1,itil_type,apptype,store,logic FROM cfg_report WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__')",
			'duplicate_report_config' => "INSERT INTO cfg_report2config (subtype_cfg_report,cfg_table,field,value,type,logic) (SELECT'__NEW_SUBTYPE_CFG_REPORT__',cfg_table,field,value,type,logic FROM cfg_report2config WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__')",
			'duplicate_report_item' => "INSERT INTO cfg_report2item (subtype_cfg_report,id,title,col,row,type,draggable,posX,posY,data_fx,params,item_order,mobile) (SELECT'__NEW_SUBTYPE_CFG_REPORT__',id,title,col,row,type,draggable,posX,posY,data_fx,params,item_order,mobile FROM cfg_report2item WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__')",
			'update_title_report_item'=>"UPDATE cfg_report2item SET title='__TITLE__' WHERE id_cfg_report2item IN (__ID_CFG_REPORT2ITEM__)",
// -----
         'delete_report' => "DELETE FROM cfg_report WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__' AND custom=1",
         'delete_report_config' => "DELETE FROM cfg_report2config WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__'",
         'delete_report_item' => "DELETE FROM cfg_report2item WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__'",
// -----
         'cnm_get_views_report_delete_temp' => "DROP TEMPORARY TABLE t1,t2",
         'cnm_get_views_report_create_temp1' => "CREATE TEMPORARY TABLE t2 SELECT value AS id_cfg_view,1 AS asoc FROM cfg_report2config WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__' AND cfg_table='view' AND field='id_cfg_view' AND type=0",
         'cnm_get_views_report_create_temp2' => "CREATE TEMPORARY TABLE t1 SELECT a.id_cfg_view,a.name,a.type,IFNULL(asoc,0) as asoc FROM cfg_views a LEFT JOIN t2 ON a.id_cfg_view=t2.id_cfg_view",
         'cnm_get_views_report_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_get_views_report_count' => "SELECT COUNT(DISTINCT id_dev) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
// -----
         'cnm_get_devices_view_delete_temp' => "DROP TEMPORARY TABLE t1,t2",
         // 'cnm_get_devices_view_create_temp' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,a.name,a.domain,a.ip,a.type,a.xagent_version,a.status__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
         'cnm_get_devices_view_create_temp' => "CREATE TEMPORARY TABLE t1 SELECT DISTINCT(a.id_dev) AS id_dev,a.name,a.domain,a.ip,a.type,a.xagent_version,a.status__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
         'cnm_get_devices_view_create_temp1' => "CREATE TEMPORARY TABLE t2 SELECT count(DISTINCT id_metric) AS num_metricas,id_device AS id_dev FROM cfg_views2metrics WHERE id_cfg_view=__ID_CFG_VIEW__ GROUP BY id_device",
         'cnm_get_devices_view_remote_alerts_create_temp' => "CREATE TEMPORARY TABLE t2 SELECT count(DISTINCT id_remote_alert) AS num_metricas,id_dev FROM cfg_views2remote_alerts WHERE id_cfg_view=__ID_CFG_VIEW__ GROUP BY id_dev",
         // 'cnm_get_devices_view_create_temp2' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,a.name,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.sysdesc,a.sysloc,a.mac,IFNULL(num_metricas,0) as cuantos__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev LEFT JOIN t2 ON a.id_dev=t2.id_dev WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
         'cnm_get_devices_view_create_temp2' => "CREATE TEMPORARY TABLE t1 SELECT DISTINCT(a.id_dev) AS id_dev,a.name,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.sysdesc,a.sysloc,a.mac,IFNULL(num_metricas,0) as cuantos__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev LEFT JOIN t2 ON a.id_dev=t2.id_dev WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
         'cnm_get_devices_view_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_get_devices_view_count' => "SELECT COUNT(DISTINCT id_dev) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
// -----
         'cnm_get_metrics_view_delete_temp' => "DROP TEMPORARY TABLE t1",
         'cnm_get_metrics_view_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT 0 AS asoc,a.id_metric,a.type,a.label,a.id_dev,b.name,b.domain FROM metrics a,devices b WHERE a.id_dev=b.id_dev AND b.id_dev IN (__ID_DEV__))",
         'cnm_get_metrics_view_update_temp' => "UPDATE t1 SET asoc=1 WHERE id_metric IN (__ID_METRIC__)",
         'cnm_get_metrics_view_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_get_metrics_view_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
// -----
         'cnm_get_remote_alert_view_delete_temp' => "DROP TEMPORARY TABLE t1",
         'cnm_get_remote_alert_view_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT 0 AS asoc,a.id_remote_alert,a.type,a.descr,c.id_dev,c.name,c.domain FROM cfg_remote_alerts a,cfg_remote_alerts2device b,devices c WHERE a.id_remote_alert=b.id_remote_alert AND b.target=c.ip AND c.id_dev IN (__ID_DEV__))",
         'cnm_get_remote_alert_view_update_temp' => "UPDATE t1 SET asoc=1 WHERE id_remote_alert IN (__ID_REMOTE_ALERT__)",
         'cnm_get_remote_alert_view_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_get_remote_alert_view_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",





			// 'cnm_cfg_snmp_get_devices_tree_visible'=>'SELECT a.id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.version!=0 AND a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)',
			'cnm_cfg_snmp_get_devices_tree_visible'=>'SELECT DISTINCT(a.id_dev) AS id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.version!=0 AND a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)',
			'cnm_cfg_snmp_get_devices_tree_count'=>"SELECT count(DISTINCT id_tm2iid) as cuantos,b.id_dev FROM cfg_monitor_snmp a, prov_template_metrics b, prov_template_metrics2iid c WHERE a.id_cfg_monitor_snmp='__ID_CFG_MONITOR_SNMP__' AND a.subtype=b.subtype AND  b.id_template_metric=c.id_template_metric AND c.status=0 group by b.id_dev",
			'cnm_cfg_snmp_get_devices_count'=>"SELECT count(DISTINCT id_tm2iid) as cuantos FROM cfg_monitor_snmp a, prov_template_metrics b, prov_template_metrics2iid c WHERE a.id_cfg_monitor_snmp='__ID_CFG_MONITOR_SNMP__' AND a.subtype=b.subtype AND  b.id_template_metric=c.id_template_metric AND c.status=0",
			'cnm_cfg_xagent_get_devices_count'=>"SELECT count(DISTINCT id_tm2iid) as cuantos FROM cfg_monitor_agent a, prov_template_metrics b, prov_template_metrics2iid c WHERE a.id_cfg_monitor_agent='__ID_CFG_MONITOR_AGENT__' AND a.subtype=b.subtype AND  b.id_template_metric=c.id_template_metric AND c.status=0",
// -----
			// 'cnm_cfg_xagt_get_devices_tree_visible'=>"SELECT a.id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
			'cnm_cfg_xagt_get_devices_tree_visible'=>"SELECT DISTINCT(a.id_dev) AS id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
			// 'cnm_cfg_xagt_proxy_get_devices_tree_visible'=>"SELECT a.id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
			'cnm_cfg_xagt_proxy_get_devices_tree_visible'=>"SELECT DISTINCT(a.id_dev) AS id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
			'cnm_cfg_xagt_get_devices_tree_count'=>"SELECT count(DISTINCT id_tm2iid) as cuantos,b.id_dev FROM cfg_monitor_agent a, prov_template_metrics b, prov_template_metrics2iid c WHERE a.id_cfg_monitor_agent='__ID_CFG_MONITOR_AGENT__' AND a.subtype=b.subtype AND  b.id_template_metric=c.id_template_metric AND c.status=0 group by b.id_dev",
			'cnm_cfg_xagt_get_devices_count'=>"SELECT count(DISTINCT id_tm2iid) as cuantos FROM cfg_monitor_agent a, prov_template_metrics b, prov_template_metrics2iid c WHERE a.id_cfg_monitor_agent='__ID_CFG_MONITOR_AGENT__' AND a.subtype=b.subtype AND  b.id_template_metric=c.id_template_metric AND c.status=0",

// -----
			// 'cnm_cfg_wmi_no_get_devices_tree_visible'=>"SELECT a.id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",
			'cnm_cfg_wmi_no_get_devices_tree_visible'=>"SELECT DISTINCT(a.id_dev) AS id_dev FROM devices a,cfg_devices2organizational_profile e WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__)",



// -----
         'cnm_view_get_devices_tree_visible'=>"SELECT DISTINCT(id_dev) as id_dev FROM metrics",
         'cnm_view_get_devices_tree_count'=>"SELECT count(DISTINCT id_metric) as cuantos,id_device as id_dev FROM cfg_views2metrics WHERE id_cfg_view=__ID_CFG_VIEW__ GROUP BY id_device",
			'cnm_view_get_num_metrics'=>"SELECT count(DISTINCT a.id_metric) as cuantos FROM cfg_views2metrics a,devices b WHERE a.id_device=b.id_dev AND id_cfg_view=__ID_CFG_VIEW__",
			'cnm_view_update_nmetrics'=>"UPDATE cfg_views SET nmetrics=__NMETRICS__ WHERE id_cfg_view=__ID_CFG_VIEW__ AND cid='__CID__' AND cid_ip='__CID_IP__'",

			'cnm_view_get_num_remote'=>"SELECT count(DISTINCT a.id_remote_alert,a.id_dev) as cuantos FROM cfg_views2remote_alerts a,devices b WHERE a.id_dev=b.id_dev AND id_cfg_view=__ID_CFG_VIEW__",
         'cnm_view_update_nremote'=>"UPDATE cfg_views SET nremote=__NREMOTE__ WHERE id_cfg_view=__ID_CFG_VIEW__ AND cid='__CID__' AND cid_ip='__CID_IP__'",

			'cnm_view_get_num_subviews'=>"SELECT count(DISTINCT a.id_cfg_subview) as cuantos FROM cfg_views2views a WHERE a.id_cfg_view=__ID_CFG_VIEW__",
         'cnm_view_update_nsubviews'=>"UPDATE cfg_views SET nsubviews=__NSUBVIEWS__ WHERE id_cfg_view=__ID_CFG_VIEW__ AND cid='__CID__' AND cid_ip='__CID_IP__'",

// -----
         'cnm_view_remote_get_devices_tree_visible'=>"SELECT DISTINCT(id_dev) as id_dev FROM metrics",
         'cnm_view_remote_get_devices_tree_count'=>"SELECT count(DISTINCT id_remote_alert) as cuantos,id_dev FROM cfg_views2remote_alerts WHERE id_cfg_view=__ID_CFG_VIEW__ GROUP BY id_dev",

         // ---------------------------------------------------------------------------------------
         // Incluir un dispositivo a un aviso
			// wsf: cnm_cfg_notification_include_device (1Q)
         // ---------------------------------------------------------------------------------------
         // 'cnm_cfg_notification_include_device'=>"INSERT IGNORE INTO cfg_notification2device (id_cfg_notification,id_device,status) SELECT '__ID_CFG_NOTIFICATION__','__ID_DEV__',status FROM devices WHERE id_dev=__ID_DEV__",
         //'cnm_cfg_notification_include_device'=>"INSERT IGNORE INTO cfg_notification2device (id_cfg_notification,id_device,status,iid,hiid,mname) SELECT '__ID_CFG_NOTIFICATION__','__ID_DEV__',status FROM devices WHERE id_dev=__ID_DEV__",
         'cnm_cfg_notification_include_device'=>"INSERT IGNORE INTO cfg_notification2device (id_cfg_notification,id_device,status,iid,hiid,mname) values (__ID_CFG_NOTIFICATION__,__ID_DEV__,__STATUS__,'__IID__','__HIID__','__MNAME__')",

         // ---------------------------------------------------------------------------------------
         // Excluir un dispositivo de un aviso
			// wsf: cnm_cfg_notification_exclude_device (1Q)
         // ---------------------------------------------------------------------------------------
         'cnm_cfg_notification_exclude_device'=>"DELETE FROM cfg_notification2device WHERE id_cfg_notification='__ID_CFG_NOTIFICATION__' AND id_device=__ID_DEV__ AND iid='__IID__' AND hiid='__HIID__' AND mname='__MNAME__'",


// ---------------------------------------------------------------------------------------
// mod_avisos_documentacion.php
// ESTO ES GLOBAL A TODOS
// ---------------------------------------------------------------------------------------


         // ---------------------------------------------------------------------------------------
         // Notas de una tarea determinada
			// wsf: cnm_cfg_tips_get_ro_info_by_typeid (1Q)
			// wsf: cnm_cfg_tips_get_rw_info_by_typeid (1Q)
         // ---------------------------------------------------------------------------------------
         //'get_info_tip'=>"SELECT id_tip,id_ref,name,descr,url,from_unixtime(date)as date FROM tips WHERE id_ref like '__ID_REF__' AND tip_type like '__TIP_TYPE__' AND tip_class=__TIP_CLASS__ ORDER BY date DESC",
         'cnm_cfg_tips_get_info_by_typeid'=>"SELECT id_tip,id_ref,name,descr,url,from_unixtime(date)as date FROM tips WHERE id_ref like '__ID_REF__' AND tip_type like '__TIP_TYPE__' AND tip_class=__TIP_CLASS__ ORDER BY date DESC",

//realmente id es id+tipo porque cada id esta sujeto al tipo al que pertenezca (id_ref+tip_type)
//otra opcion es mediante id_tip
         'cnm_cfg_tips_get_ro_info_by_typeid'=>"SELECT id_tip,id_ref,name,descr,url,from_unixtime(date)as date,position FROM tips WHERE id_ref like '__ID_REF__' AND tip_type like '__TIP_TYPE__' AND tip_class=1 ORDER BY date DESC",
         'cnm_cfg_tips_get_ro_info_by_typeidrefn'=>"SELECT id_tip,id_ref,name,descr,url,from_unixtime(date)as date,position FROM tips WHERE id_refn=__ID_REFN__ AND tip_type like '__TIP_TYPE__' AND tip_class=1 ORDER BY date DESC",
         'cnm_cfg_tips_get_rw_info_by_typeid'=>"SELECT id_tip,id_ref,name,descr,url,from_unixtime(date)as date,position FROM tips WHERE id_ref like '__ID_REF__' AND tip_type like '__TIP_TYPE__' AND tip_class=0 ORDER BY date DESC",
         'cnm_cfg_tips_get_rw_info_by_typeidrefn'=>"SELECT id_tip,id_ref,name,descr,url,from_unixtime(date)as date,position FROM tips WHERE id_refn=__ID_REFN__ AND tip_type like '__TIP_TYPE__' AND tip_class=0 ORDER BY date DESC",

         // ---------------------------------------------------------------------------------------
         // Borrar una entrada de la documentacion a partir de su id_tip
			// wsf: cnm_cfg_tips_delete_by_id (1Q)
         // ---------------------------------------------------------------------------------------
         //'delete_tip'=>"DELETE FROM tips WHERE id_tip IN (__ID_TIP__)",
         'cnm_cfg_tips_delete_by_id'=>"DELETE FROM tips WHERE id_tip IN (__ID_TIP__)",

         // ---------------------------------------------------------------------------------------
         // Insertar una entrada en la documentacion
			// wsf: cnm_cfg_tips_store (2Q)
         // ---------------------------------------------------------------------------------------
         'cnm_cfg_tips_store_create'=>"INSERT INTO tips (descr,id_ref,tip_type,date,name,id_refn) VALUES ('__DESCR__','__ID_REF__','__TIP_TYPE__',__DATE__,'__NAME__','__ID_REFN__')",
			'cnm_cfg_tips_update_pos'=>"UPDATE tips SET position=__POSITION__ WHERE id_tip=__ID_TIP__",

			'cnm_cfg_tips_update_idrefn'=>"UPDATE tips SET id_refn=__ID_REFN__ WHERE id_tip=__ID_TIP__",
         // ---------------------------------------------------------------------------------------
         // Actualizar una entrada de la documentacion
         //'edit_tip'=>"UPDATE tips SET descr='__DESCR__',date=__DATE__,name='__NAME__' WHERE id_tip=__ID_TIP__",
         'cnm_cfg_tips_store_update'=>"UPDATE tips SET descr='__DESCR__',date=__DATE__,name='__NAME__' WHERE id_tip=__ID_TIP__ AND id_ref='__ID_REF__' AND tip_type='__TIP_TYPE__'",
         'cnm_cfg_tips_store_update_by_id_ref'=>"UPDATE tips SET descr='__DESCR__',date=__DATE__,name='__NAME__' WHERE id_ref='__ID_REF__' AND tip_type='__TIP_TYPE__'",

         'cnm_cfg_tips_store_create_update'=>"INSERT INTO tips (descr,id_ref,tip_type,date,name,tip_class) VALUES ('__DESCR__','__ID_REF__','__TIP_TYPE__',__DATE__,'__NAME__','__TIP_CLASS__') ON DUPLICATE KEY UPDATE descr='__DESCR__', date=__DATE__, tip_class='__TIP_CLASS__', id_ref='__ID_REF__', tip_type='__TIP_TYPE__', name='__NAME__'",
         'cnm_cfg_tips_store_create_update_idrefn'=>"INSERT INTO tips (descr,id_ref,tip_type,date,name,tip_class,id_refn) VALUES ('__DESCR__','__ID_REF__','__TIP_TYPE__',__DATE__,'__NAME__','__TIP_CLASS__',__ID_REFN__) ON DUPLICATE KEY UPDATE descr='__DESCR__', date=__DATE__, tip_class='__TIP_CLASS__', id_ref='__ID_REF__', tip_type='__TIP_TYPE__', name='__NAME__'",
         'cnm_cfg_tips_store_create_idrefn'=>"INSERT INTO tips (descr,id_ref,tip_type,date,name,tip_class,id_refn,hiid) VALUES ('__DESCR__','__ID_REF__','__TIP_TYPE__',__DATE__,'__NAME__','__TIP_CLASS__',__ID_REFN__,'__HIID__')",
         'cnm_cfg_tips_store_update_idrefn'=>"UPDATE tips SET descr='__DESCR__', date=__DATE__, tip_class='__TIP_CLASS__', id_ref='__ID_REF__', tip_type='__TIP_TYPE__', name='__NAME__',hiid='__HIID__' WHERE id_refn IN (__ID_REFN__) AND tip_class='__TIP_CLASS__'",
// La clave es `id_ref`,`tip_type`,`name`


// ---------------------------------------------------------------------------------------
// mod_avisos_transporte.php
// ---------------------------------------------------------------------------------------

			// ---------------------------------------------------------------------------------------
         // Obtener la alerta asociada a un determinado aviso
			'get_asociated_alert' => "SELECT monitor FROM cfg_notifications WHERE id_cfg_notification=__ID_CFG_NOTIFICATION__",

			// ---------------------------------------------------------------------------------------
         // Obtener los transportes registrados en el sistema
			// wsf: cnm_cfg_notification_get_registered_transports (1Q)
			'get_registered_transports' => "SELECT a.id_register_transport,b.name as tipo,a.name,a.value FROM cfg_register_transports a, notification_type b WHERE a.id_notification_type=b.id_notification_type",

         // ---------------------------------------------------------------------------------------
         // Obtener los transportes SMTP registrados en el sistema
			// wsf: cnm_cfg_notification_get_registered_transports_smtp (1Q)
         'get_registered_transports_smtp' => "SELECT a.id_register_transport,a.name,a.value FROM cfg_register_transports a WHERE a.id_notification_type=1",

         // ---------------------------------------------------------------------------------------
         // Obtener los transportes SMS registrados en el sistema
			// wsf: cnm_cfg_notification_get_registered_transports_sms (1Q)
         'get_registered_transports_sms' => "SELECT a.id_register_transport,a.name,a.value FROM cfg_register_transports a WHERE a.id_notification_type=2",

         // ---------------------------------------------------------------------------------------
         // Obtener los transportes SNMP-TRAP registrados en el sistema
			// wsf: cnm_cfg_notification_get_registered_transports_trap (1Q)
         'get_registered_transports_trap' => "SELECT a.id_register_transport,a.name,a.value FROM cfg_register_transports a WHERE a.id_notification_type=3",

         // ---------------------------------------------------------------------------------------
         // Obtener los transportes Telegram registrados en el sistema
         'get_registered_transports_telegram' => "SELECT a.id_register_transport,a.name,a.value FROM cfg_register_transports a WHERE a.id_notification_type=4",

         // ---------------------------------------------------------------------------------------
         // Actualizar los transportes registrados en el sistema
			// wsf: cnm_cfg_notification_store_registered_transport (2Q)
         'update_registered_transport' => "UPDATE cfg_register_transports SET name='__NAME__', value='__VALUE__' WHERE id_register_transport='__ID_REGISTER_TRANSPORT__'",

         // ---------------------------------------------------------------------------------------
         // Crear un nuevo transporte registrado en el sistema
			'create_registered_transport' => "INSERT INTO cfg_register_transports (name,value,id_notification_type) VALUES ('__NAME__','__VALUE__','__ID_NOTIFICATION_TYPE__')",



			// ---------------------------------------------------------------------------------------
         // Obtener los transportes asociados  una determinado aviso
			'get_notification2transport' => " SELECT id_register_transport FROM cfg_notification2transport WHERE id_cfg_notification=__ID_CFG_NOTIFICATION__",

         // ---------------------------------------------------------------------------------------
         // Obtener los dispositivos asociados a un aviso
			'get_asociated_devices' =>"SELECT d.status,d.name,d.ip,d.type FROM devices d, cfg_notification2device c WHERE d.id_dev=c.id_device and id_cfg_notification=__ID_CFG_NOTIFICATION__",


         // ---------------------------------------------------------------------------------------
         // Borrar transportes registrados
			'delete_transports' =>"DELETE FROM cfg_register_transports WHERE id_register_transport in (__ID_REGISTER_TRANSPORT__)",
			'all_devices_notifications' => "SELECT id_device as id_dev FROM cfg_notification2device WHERE id_cfg_notification IN (__ID_CFG_NOTIFICATION__)",

         // ---------------------------------------------------------------------------------------
         // Obtener el listado de dispositivos
			'get_device_list'=>"SELECT id_dev,name,domain,ip,sysloc,sysdesc,sysoid,type,app,status,mode,community,version,wbem_user,wbem_pwd,id_cfg_op,host_idx,xagent_version,enterprise FROM devices WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
			'get_device_list_count'=>"SELECT COUNT(DISTINCT id_dev) AS cuantos FROM devices WHERE ''='' __CONDITION__",

			'get_device_list_alarmed'=>"SELECT DISTINCT(id_device) FROM alerts WHERE counter>0",
			'cnm_alerts_get_devices_in_alert'=>"SELECT DISTINCT(id_device) FROM alerts WHERE counter>0",

         // ---------------------------------------------------------------------------------------
         // Obtener las metricas que tienen asociadas un monitor
			'get_monitor_metrics_asoc'=>"SELECT id_metric FROM metrics a,alert_type b WHERE a.watch=b.monitor AND id_alert_type=__ID_ALERT_TYPE__",
			'cnm_cfg_monitor_get_metrics_in_use_by_id'=>"SELECT id_metric FROM metrics a,alert_type b WHERE a.watch=b.monitor AND id_alert_type=__ID_ALERT_TYPE__",


         // ---------------------------------------------------------------------------------------
         // Obtener el listado de metricas de un monitor
         'get_monitor_metrics_list'=>"SELECT c.id_tm2iid,c.iid,c.label,d.id_dev,d.status,d.name,d.domain,d.ip,d.type,(a.monitor=c.watch)AS asoc,a.id_alert_type,a.cause,a.mname,a.monitor FROM alert_type a, prov_template_metrics b, prov_template_metrics2iid c, devices d WHERE a.id_alert_type=__ID_ALERT_TYPE__ AND a.mname=b.subtype AND b.id_template_metric=c.id_template_metric and c.status=0 AND b.id_dev=d.id_dev AND c.id_dev=d.id_dev __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'get_monitor_metrics_list_count'=>"SELECT COUNT(DISTINCT c.id_tm2iid) AS cuantos FROM alert_type a, prov_template_metrics b, prov_template_metrics2iid c, devices d WHERE a.id_alert_type=__ID_ALERT_TYPE__ AND a.mname=b.subtype AND b.id_template_metric=c.id_template_metric and c.status=0 AND b.id_dev=d.id_dev AND c.id_dev=d.id_dev __CONDITION__",

			// Obtener el listado de metricas de un monitor especificado por su id_alert_type
         'cnm_cfg_monitor_get_metric_list_by_id'=>"SELECT c.id_tm2iid,c.iid,c.label,d.id_dev,d.status,d.name,d.domain,d.ip,d.type,(a.monitor=c.watch)AS asoc,a.id_alert_type,a.cause,a.mname,a.monitor FROM alert_type a, prov_template_metrics b, prov_template_metrics2iid c, devices d WHERE a.id_alert_type=__ID_ALERT_TYPE__ AND a.mname=b.subtype AND b.id_template_metric=c.id_template_metric and c.status=0 AND b.id_dev=d.id_dev AND c.id_dev=d.id_dev __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_cfg_monitor_get_metric_list_count_by_id'=>"SELECT COUNT(DISTINCT c.id_tm2iid) AS cuantos FROM alert_type a, prov_template_metrics b, prov_template_metrics2iid c, devices d WHERE a.id_alert_type=__ID_ALERT_TYPE__ AND a.mname=b.subtype AND b.id_template_metric=c.id_template_metric and c.status=0 AND b.id_dev=d.id_dev AND c.id_dev=d.id_dev __CONDITION__",

         'cnm_monitor_metrics_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
			'cnm_monitor_metrics_create_temp'=>"CREATE TEMPORARY TABLE t1 (SELECT c.id_tm2iid,c.iid,c.label,d.id_dev,d.status,d.name,d.domain,d.ip,d.type,(a.monitor=c.watch)AS asoc,a.id_alert_type,a.cause,a.mname,a.monitor__USER_FIELDS__ FROM (alert_type a, prov_template_metrics b, prov_template_metrics2iid c, devices d,cfg_devices2organizational_profile f) LEFT JOIN devices_custom_data e ON d.id_dev=e.id_dev WHERE a.id_alert_type=__ID_ALERT_TYPE__ AND a.mname=b.subtype AND b.id_template_metric=c.id_template_metric and c.status=0 AND b.id_dev=d.id_dev AND c.id_dev=d.id_dev AND d.id_dev=f.id_dev AND f.id_cfg_op IN (__ID_CFG_OP__))",
			'cnm_monitor_metrics_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
			//'cnm_monitor_metrics_count' => "SELECT COUNT(DISTINCT id_dev) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
			'cnm_monitor_metrics_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

			// Obtener el listado de metricas de un aviso especificado
			'cnm_aviso_metrics_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
			'cnm_aviso_metrics_create_temp'=>"CREATE TEMPORARY TABLE t1 (SELECT c.id_tm2iid,c.iid,c.mname,c.hiid,c.label,d.id_dev,d.status,d.name,d.domain,d.ip,d.type,d.mac,0 AS asoc__USER_FIELDS__ FROM (cfg_notifications a, prov_template_metrics b, prov_template_metrics2iid c, devices d,cfg_devices2organizational_profile f) LEFT JOIN devices_custom_data e ON d.id_dev=e.id_dev WHERE a.id_cfg_notification=__ID_CFG_NOTIFICATION__ AND (a.monitor=c.watch OR a.monitor=b.subtype) AND b.id_template_metric=c.id_template_metric and c.status=0 AND b.id_dev=d.id_dev AND c.id_dev=d.id_dev AND d.id_dev=f.id_dev AND f.id_cfg_op IN (__ID_CFG_OP__) AND f.cid='__CID__')",
			'cnm_aviso_metrics_update_temp'=>"UPDATE t1 set asoc=1 WHERE (id_dev,iid,hiid,mname) IN (SELECT id_device as id_dev,iid,hiid,mname FROM cfg_notification2device WHERE id_cfg_notification=__ID_CFG_NOTIFICATION__)",
         'cnm_aviso_metrics_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_aviso_metrics_count' => "SELECT COUNT(DISTINCT id_dev) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

			// Obtener el listado de dispositivos con alerta remota de un aviso especificado
			'cnm_aviso_remote_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
			'cnm_aviso_remote_create_temp'=>"CREATE TEMPORARY TABLE t1 (SELECT DISTINCT(d.id_dev) AS id_tm2iid,'ALL' AS iid,b.id_remote_alert AS mname,b.hiid,b.descr AS label,d.id_dev,d.status,d.name,d.domain,d.ip,d.type,d.mac,0 AS asoc__USER_FIELDS__ FROM (cfg_notifications a, cfg_remote_alerts b, cfg_remote_alerts2device c, devices d,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data f ON d.id_dev=f.id_dev WHERE a.id_cfg_notification=__ID_CFG_NOTIFICATION__ AND a.monitor=b.id_remote_alert AND b.id_remote_alert=c.id_remote_alert AND c.target=d.ip AND d.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__')",
			'cnm_aviso_remote_update_temp'=>"UPDATE t1 set asoc=1 WHERE (id_dev) IN (SELECT id_device as id_dev FROM cfg_notification2device WHERE id_cfg_notification=__ID_CFG_NOTIFICATION__)",
         'cnm_aviso_remote_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_aviso_remote_count' => "SELECT COUNT(DISTINCT id_dev) AS cuantos FROM t1 WHERE ''='' __CONDITION__",


         // Obtener el listado de dispositivos con snmp
         'cnm_aviso_snmp_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
			'cnm_aviso_snmp_create_temp'=>"CREATE TEMPORARY TABLE t1 (SELECT DISTINCT(d.id_dev) AS id_tm2iid,'ALL' AS iid,'mon_snmp' AS mname,c.hiid,'Monitor de variable snmp' AS label,d.id_dev,d.status,d.name,d.domain,d.ip,d.type,d.mac,0 AS asoc__USER_FIELDS__ FROM (prov_template_metrics b, prov_template_metrics2iid c, devices d,cfg_devices2organizational_profile f) LEFT JOIN devices_custom_data e ON d.id_dev=e.id_dev WHERE b.type='snmp' AND b.id_template_metric=c.id_template_metric and c.status=0 AND b.id_dev=d.id_dev AND c.id_dev=d.id_dev AND d.id_dev=f.id_dev AND f.id_cfg_op IN (__ID_CFG_OP__) AND f.cid='__CID__' GROUP BY d.id_dev)",

         'cnm_aviso_snmp_update_temp'=>"UPDATE t1 set asoc=1 WHERE (id_dev) IN (SELECT id_device as id_dev FROM cfg_notification2device WHERE id_cfg_notification=__ID_CFG_NOTIFICATION__)",
         'cnm_aviso_snmp_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
         'cnm_aviso_snmp_count' => "SELECT COUNT(DISTINCT id_dev) AS cuantos FROM t1 WHERE ''='' __CONDITION__",


         // ---------------------------------------------------------------------------------------
         // Obtener el listado de usuarios
			//'get_cfg_users'=>"SELECT a.id_user,a.login_name,a.passwd,a.descr,a.perfil,a.timeout,ifnull(b.name,'') AS role,a.firstname,a.lastname,a.email,a.otrs_type FROM cfg_users a LEFT JOIN cfg_operational_profile b ON a.perfil=b.id_operational_profile WHERE a.login_name!='beta'",
			'get_cfg_users'=>"SELECT a.id_user,a.login_name,a.passwd,a.descr,a.perfil,a.timeout,ifnull(b.name,'') AS role,a.firstname,a.lastname,a.email,a.plugin_auth FROM cfg_users a LEFT JOIN cfg_operational_profile b ON a.perfil=b.id_operational_profile WHERE a.login_name!='beta'",
			'cfg_users_delete_temp' => "DROP TEMPORARY TABLE IF EXISTS t1",
			'cfg_users_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.login_name,a.descr,a.timeout,a.firstname,a.lastname,a.email,a.language FROM cfg_users a,)",


			// Obtener información de un usuario
			'info_cfg_users'=>"SELECT id_user,login_name,passwd,descr,perfil,timeout,params,firstname,lastname,email,otrs_type,language,token FROM cfg_users WHERE id_user IN (__ID_USER__)",
			'update_params_cfg_users'=>"UPDATE cfg_users SET params = '__PARAMS__' WHERE id_user IN (__ID_USER__)",
			// Obtener los perfiles de un usuario
			'profiles_cfg_user'=>"SELECT id_cfg_op,descr,user_group FROM cfg_organizational_profile WHERE user_group REGEXP ',__ID_USER__,'",
			// Obtener información de un perfil organizativo
			'info_organizational_profile'=>"SELECT descr,user_group FROM cfg_organizational_profile WHERE id_cfg_op IN (__ID_CFG_OP__)",
			// Asociar un usuario a un perfil organizativo
			'mod_user_add_organizational_profile'=>"UPDATE cfg_organizational_profile SET user_group='__USER_GROUP__' WHERE id_cfg_op IN (__ID_CFG_OP__)",
         // ---------------------------------------------------------------------------------------
         // Obtener el listado de perfiles operativos
         'get_operational_profile'=>"SELECT id_operational_profile,name,template,custom FROM cfg_operational_profile",
			// Crear un perfil operativo
			'create_operational_profile'=>"INSERT INTO cfg_operational_profile (name,custom,template) VALUES ('__NAME__',1,'__TEMPLATE__')",
			'last_id_inserted'=>"SELECT LAST_INSERT_ID() AS last",
			'create_operational_profile2'=>"UPDATE cfg_operational_profile SET template='__TEMPLATE__' WHERE id_operational_profile=__ID_OPERATIONAL_PROFILE__",
			// Modificar un perfil operativo
			'mod_operational_profile'=>"UPDATE cfg_operational_profile SET name='__NAME__',template='__TEMPLATE__' WHERE id_operational_profile IN (__ID_OPERATIONAL_PROFILE__)",
			// Eliminar un perfil operativo
			'delete_operational_profile'=>"DELETE FROM cfg_operational_profile WHERE id_operational_profile IN (__ID_OPERATIONAL_PROFILE__) AND custom=1",
			// Información de un perfil operativo
			'info_operational_profile'=>"SELECT id_operational_profile,name,template,custom FROM cfg_operational_profile WHERE id_operational_profile IN (__ID_OPERATIONAL_PROFILE__)",

			// ---------------------------------------------------------------------------------------
         // Obtener el listado de perfiles organizativos
			'get_organizational_profile'=>"SELECT id_cfg_op,descr,user_group FROM cfg_organizational_profile",
			// Borrar un perfil organizativo
			'delete_organizational_profile'=>"DELETE FROM cfg_organizational_profile WHERE id_cfg_op IN (__ID_CFG_OP__)",
			// Crear un perfil organizativo
			'create_organizational_profile'=>"INSERT INTO cfg_organizational_profile (descr) VALUES ('__DESCR__')",
			// Modificar un perfil organizativo
			'mod_organizational_profile'=>"UPDATE cfg_organizational_profile SET descr='__DESCR__' WHERE id_cfg_op IN (__ID_CFG_OP__)",
			// Obtener los datos de un perfil organizativo por su descripcion
			'get_organizational_profile_by_descr' => "SELECT id_cfg_op,descr,user_group FROM cfg_organizational_profile WHERE id_cfg_op IN (__ID_CFG_OP__)",

         // ---------------------------------------------------------------------------------------
			// Crear un usuario
			'create_user'=>"INSERT INTO cfg_users (login_name,passwd,descr,perfil,timeout) VALUES ('__LOGIN_NAME__','__PASSWD__','__DESCR__',__PERFIL__,__TIMEOUT__)",
			'create_user_enc'=>"INSERT INTO cfg_users (login_name,token,descr,perfil,timeout,firstname,lastname,email,plugin_auth) VALUES ('__LOGIN_NAME__','__PASSWD__','__DESCR__',__PERFIL__,__TIMEOUT__,'__FIRSTNAME__','__LASTNAME__','__EMAIL__','__PLUGIN_AUTH__')",
			// 'create_user_enc'=>"INSERT INTO cfg_users (login_name,token,descr,perfil,timeout,firstname,lastname,email,otrs_type) VALUES ('__LOGIN_NAME__','__PASSWD__','__DESCR__',__PERFIL__,__TIMEOUT__,'__FIRSTNAME__','__LASTNAME__','__EMAIL__',__OTRS_TYPE__)",
			// Modificar un usuario
			'mod_user'=>"UPDATE cfg_users SET login_name='__LOGIN_NAME__',passwd='__PASSWD__',descr='__DESCR__',perfil=__PERFIL__,timeout=__TIMEOUT__ WHERE id_user=__ID_USER__",
			'mod_user_enc'=>"UPDATE cfg_users SET login_name='__LOGIN_NAME__',token='__PASSWD__',descr='__DESCR__',perfil=__PERFIL__,timeout=__TIMEOUT__,firstname='__FIRSTNAME__',lastname='__LASTNAME__',email='__EMAIL__',plugin_auth='__PLUGIN_AUTH__' WHERE id_user=__ID_USER__",
			'mod_user_enc_no_pass'=>"UPDATE cfg_users SET login_name='__LOGIN_NAME__',descr='__DESCR__',perfil=__PERFIL__,timeout=__TIMEOUT__,firstname='__FIRSTNAME__',lastname='__LASTNAME__',email='__EMAIL__',plugin_auth='__PLUGIN_AUTH__' WHERE id_user=__ID_USER__",
			// Borrar un usuario
			'delete_user'=>"DELETE FROM cfg_users WHERE id_user IN (__ID_USER__)",

			// Obtener el id de un tipo de dispositivo en base a la descripcion
			'get_devices_custom_type_by_descr'=>"SELECT id FROM devices_custom_types WHERE descr LIKE '__DESCR__'",
			// Obtener los tipos de dispositivos definidos por el usuario
			'get_devices_custom_types'=>"SELECT id,descr,tipo FROM devices_custom_types",
			'get_devices_custom_typeslist'=>"SELECT a.id,a.descr FROM devices_custom_types a WHERE a.tipo=3 ORDER BY a.descr",
			'get_devices_custom_data_value'=>"SELECT __FIELD__ from devices_custom_data WHERE id_dev IN (__ID_DEV__)",
			// Crear un nuevo tipo de dispositivo
			'create_devices_custom_types'=>"INSERT INTO devices_custom_types (descr,tipo) VALUES ('__DESCR__',__TIPO__)",
			'create_devices_custom_data'=>"ALTER TABLE devices_custom_data ADD COLUMN __COLUMNA__ varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default '-'",
			'create_devices_custom_datatext'=>"ALTER TABLE devices_custom_data ADD COLUMN __COLUMNA__ text character set utf8 collate utf8_spanish_ci NOT NULL",
			// Modificar un tipo de dispositivo
			'mod_devices_custom_types'=>"UPDATE devices_custom_types SET descr='__DESCR__',tipo=__TIPO__ WHERE id=__ID__",
			// Borrar un tipo de dispositivo
			'del_devices_custom_types'=>"DELETE FROM devices_custom_types WHERE id IN (__ID__)",
			'del_devices_custom_data'=>"ALTER TABLE devices_custom_data DROP COLUMN __COLUMNA__",
			'get_devices_custom_data'=>"show columns from devices_custom_data where Field like '%columna%'",

         // ---------------------------------------------------------------------------------------
			// Obtener información de la ventana de resumen de una vista
			'summary_view_info'=>"SELECT graph,size FROM cfg_views2items WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND item LIKE 'summary'",
			// Obtener información de la ventana de traps de una vista
         'traps_view_info'=>"SELECT graph,size FROM cfg_views2items WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND item LIKE 'trap'",
         // ---------------------------------------------------------------------------------------
         // Obtener información de la ventana de resumen de un dispositivo
         'summary_device_info'=>"SELECT graph,size FROM cfg_devices2items WHERE id_dev IN (__ID_DEV__) AND item LIKE 'summary'",
         // ---------------------------------------------------------------------------------------
         // Obtener información general de CNM
         'total_devices'=>"SELECT COUNT(*) AS cuantos FROM devices",
         'total_devices_by_type'=>"SELECT count(DISTINCT id_dev) AS cuantos,type from devices GROUP BY type order by cuantos desc",
			'total_devices_by_status'=>"SELECT count(DISTINCT id_dev) AS cuantos,status from devices GROUP BY status order by cuantos desc",
			'total_metrics'=>"SELECT COUNT(*) AS cuantos FROM metrics",
			'total_metrics_by_type'=>"SELECT count(DISTINCT id_metric) AS cuantos,type FROM metrics GROUP BY type order by cuantos desc",
			'total_metrics_by_status'=>"SELECT count(DISTINCT id_metric) AS cuantos,status from metrics GROUP BY status order by cuantos desc",

			// ---------------------------------------------------------------------------------------
			// Obtener los items de un oid
			'get_oid_kids' =>"SELECT oid_n,oid_s FROM oid_tree WHERE oid_n_parent='__OIDN__'",
			// Obtener los items de un oid
			'get_count_oid_kids' =>"SELECT COUNT(*) AS cuantos FROM oid_tree WHERE oid_n_parent='__OIDN__'",

			// ----------------------------------------------
			// Obtiene el número de alertas a una hora determinada
			'count_alerts_timestamp'=>"SELECT COUNT(*) AS cuantos,__DATE__ AS date FROM alerts WHERE counter>1 AND date<__DATE__",

	// ----------------------------------------------
	'view_remote_remote_alerts'=>"SELECT a.id_remote_alert,b.subtype,b.descr FROM cfg_views2remote_alerts a,cfg_remote_alerts b WHERE a.id_remote_alert=b.id_remote_alert AND a.id_cfg_view=__ID_CFG_VIEW__",
	// Obtener las metricas asociadas a una vista
	'view_en_curso_delete_temp'=>	"DROP TEMPORARY TABLE IF EXISTS t1",

	'view_en_curso_metrics' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_metric AS id,b.label,c.name AS device_name,c.id_dev as device_id,'metric' AS type FROM cfg_views2metrics a,metrics b,devices c WHERE a.id_metric=b.id_metric AND a.id_device=c.id_dev AND a.id_cfg_view=__ID_CFG_VIEW__)",

	'view_en_curso_remote_alerts'=> "INSERT INTO t1 (SELECT a.id_remote_alert AS id,b.descr as label,c.name AS device_name,c.id_dev as device_id,'remote_alert' AS type FROM cfg_views2remote_alerts a,cfg_remote_alerts b,devices c WHERE a.id_remote_alert=b.id_remote_alert AND a.id_dev=c.id_dev AND a.id_cfg_view=__ID_CFG_VIEW__)",

	'view_en_curso_subviews' => "INSERT INTO t1 (SELECT a.id_cfg_subview AS id,b.name as label,'' AS device_name,'-' as device_id,'view' AS type FROM cfg_views2views a,cfg_views b WHERE a.id_cfg_subview=b.id_cfg_view AND a.id_cfg_view=__ID_CFG_VIEW__ AND a.cid_view=b.cid AND a.cid_view=a.cid_subview AND a.cid_ip_view=b.cid_ip AND a.cid_ip_view=a.cid_ip_subview AND a.cid_view='__CID__' AND a.cid_ip_view='__CID_IP__')",

	'list_subviews_admin'=>"SELECT b.id_cfg_subview,b.id_cfg_view FROM cfg_views a, cfg_views2views b, cfg_views c WHERE a.cid='__CID__' AND a.cid_ip='__CID_IP__' AND a.global IN (0,1) AND a.cid=b.cid_view AND a.cid_ip=b.cid_ip_view AND a.id_cfg_view=b.id_cfg_view AND     c.cid='__CID__' AND c.cid_ip='__CID_IP__' AND c.global IN (0,1) AND c.cid=b.cid_subview AND c.cid_ip=b.cid_ip_subview AND c.id_cfg_view=b.id_cfg_subview",

	'list_subviews_no_admin'=>"SELECT c.id_cfg_view,c.id_cfg_subview FROM cfg_views a, cfg_user2view b, cfg_views2views c, cfg_views d, cfg_user2view e WHERE a.cid='__CID__' AND a.cid_ip='__CID_IP__' AND a.global IN (0,1) AND a.cid=b.cid AND a.cid_ip=b.cid_ip AND a.id_cfg_view=b.id_cfg_view AND b.id_user IN (__ID_USER__) AND a.cid=c.cid_view AND a.cid_ip=c.cid_ip_view AND a.id_cfg_view=c.id_cfg_view AND d.cid='__CID__' AND d.cid_ip='__CID_IP__' AND d.global IN (0,1) AND d.cid=e.cid AND d.cid_ip=e.cid_ip AND d.id_cfg_view=e.id_cfg_view AND e.id_user IN (__ID_USER__) AND d.cid=c.cid_subview AND d.cid_ip=c.cid_ip_subview AND d.id_cfg_view=c.id_cfg_subview",






	'list_global_subviews_admin'=>"SELECT c.id_cfg_view,b.hidx AS hidx_view,c.id_cfg_subview,e.hidx AS hidx_subview FROM cfg_views a, cnm.cfg_cnms b, cfg_views2views c, cfg_views d, cnm.cfg_cnms e WHERE a.cid=c.cid_view AND a.cid_ip=c.cid_ip_view AND a.id_cfg_view=c.id_cfg_view AND a.global IN (1,2) AND b.cid=c.cid_view AND b.host_ip=c.cid_ip_view AND b.hidx IN (__HIDX__) AND d.cid=c.cid_subview AND d.cid_ip=c.cid_ip_subview AND d.id_cfg_view=c.id_cfg_subview AND d.global IN (1,2) AND e.cid=c.cid_subview AND e.host_ip=c.cid_ip_subview AND e.hidx IN (__HIDX__)",
	'list_global_subviews_no_admin'=>"SELECT d.id_cfg_view,b.hidx AS hidx_view,d.id_cfg_subview,f.hidx AS hidx_subview FROM cfg_views a, cnm.cfg_cnms b, cfg_user2view c, cfg_views2views d, cfg_views e, cnm.cfg_cnms f, cfg_user2view g WHERE a.cid=b.cid AND a.cid_ip=b.host_ip AND a.global IN (1,2) AND b.hidx IN (__HIDX__) AND a.cid=c.cid AND a.cid_ip=c.cid_ip AND a.id_cfg_view=c.id_cfg_view AND c.login_name='__LOGIN_NAME__' AND a.cid=d.cid_view AND a.cid_ip=d.cid_ip_view AND a.id_cfg_view=d.id_cfg_view AND e.cid=f.cid AND e.cid_ip=f.host_ip AND e.global IN (1,2) AND f.hidx IN (__HIDX__) AND e.cid=g.cid AND e.cid_ip=g.cid_ip AND e.id_cfg_view=g.id_cfg_view AND g.login_name='__LOGIN_NAME__' AND e.cid=d.cid_subview AND e.cid_ip=d.cid_ip_subview AND e.id_cfg_view=d.id_cfg_subview;",

	// 'view_reglas_metrics' => "SELECT a.id_metric AS id,b.label,c.name AS device_name,b.type,b.severity as met_severity,d.cause,d.severity as mon_severity,d.expr FROM (cfg_views2metrics a,metrics b,devices c) LEFT JOIN alert_type d ON b.name=d.mname  WHERE a.id_metric=b.id_metric AND a.id_device=c.id_dev AND a.id_cfg_view=__ID_CFG_VIEW__",
	'view_reglas_metrics' => "SELECT a.id_metric AS id,b.label,c.name AS device_name,b.type,b.severity as met_severity,d.cause,d.severity as mon_severity,d.expr FROM (cfg_views2metrics a,metrics b,devices c) LEFT JOIN alert_type d ON b.watch=d.monitor WHERE a.id_metric=b.id_metric AND a.id_device=c.id_dev AND a.id_cfg_view=__ID_CFG_VIEW__",

	'view_reglas_remote_alerts'=> "SELECT a.id_remote_alert AS id,b.descr as label,c.name AS device_name,'remote_alert' AS type,b.severity,c.id_dev FROM cfg_views2remote_alerts a,cfg_remote_alerts b,devices c WHERE a.id_remote_alert=b.id_remote_alert AND a.id_dev=c.id_dev AND a.id_cfg_view=__ID_CFG_VIEW__",

	'view_reglas_subviews' => "SELECT a.id_cfg_subview AS id,b.name as label,'' AS device_name,'view' AS type FROM cfg_views2views a,cfg_views b WHERE a.id_cfg_subview=b.id_cfg_view AND a.id_cfg_view=__ID_CFG_VIEW__ AND a.cid_view='__CID__' AND a.cid_subview='__CID__' AND a.cid_view=b.cid AND a.cid_ip_view='__CID_IP__' AND a.cid_ip_subview='__CID_IP__' AND a.cid_ip_view=b.cid_ip",


	'view_en_curso_all' => "SELECT * FROM t1",
	'view_en_curso_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'view_en_curso_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
	'view_en_curso_device_name' => "SELECT DISTINCT(device_name) as device_name, device_id FROM t1 where device_id!=0 ORDER BY device_name",

   // ----------------------------------------------
   'save_report'=>"INSERT INTO report (type,date,report) VALUES ('__TYPE__','__DATE__','__REPORT__')",
   'get_report'=>"SELECT report FROM report WHERE type='__TYPE__' AND date='__DATE__'",
   'get_cfg_report'=>"SELECT * FROM cfg_report WHERE subtype_cfg_report = '__SUBTYPE_CFG_REPORT__'",
	'count_mobile_items_report'=>"SELECT COUNT(*) AS cuantos FROM cfg_report2item WHERE subtype_cfg_report = '__SUBTYPE_CFG_REPORT__' AND mobile=1",
   'get_cfg_report_mobile'=>"SELECT * FROM cfg_report WHERE subtype_cfg_report like '__SUBTYPE_CFG_REPORT__' AND mobile=1",
   'get_cfg_report_byid'=>"SELECT * FROM cfg_report WHERE id_cfg_report IN (__ID_CFG_REPORT__)",
   'get_plugin_base_bysize'=>"SELECT * FROM plugin_base WHERE size='__SIZE__' AND item_type='__ITEM_TYPE__'",
	'save_cfg_report'=>"UPDATE cfg_report SET title='__TITLE__', logic='__LOGIC__',mobile='__MOBILE__' WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__'",
	'delete_cfg_report2config'=>"DELETE FROM cfg_report2config WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__'",
	'select_cfg_report2config'=>"SELECT * FROM cfg_report2config WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__'",
	'insert_cfg_report2config'=>"INSERT INTO cfg_report2config (subtype_cfg_report,cfg_table,field,value,type,logic) VALUES ('__SUBTYPE_CFG_REPORT__','__CFG_TABLE__','__FIELD__','__VALUE__',__TYPE__,'__LOGIC__')",
   'get_cfg_report2item'=>"SELECT * FROM cfg_report2item WHERE subtype_cfg_report = '__SUBTYPE_CFG_REPORT__' AND mobile = '__MOBILE__' ORDER BY item_order",
   'get_cfg_report2itembyid'=>"SELECT * FROM cfg_report2item WHERE subtype_cfg_report = '__SUBTYPE_CFG_REPORT__' AND id = '__ID__'",
   //'report_pie_alert_severity'=>"SELECT a.severity,count(*) AS cuantos FROM alerts_store a,devices b,cfg_devices2organizational_profile e WHERE a.id_device=b.id_dev AND b.id_dev=e.id_dev AND e.id_cfg_op in (__ID_CFG_OP__) AND e.cid='default' AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY a.severity ORDER BY cuantos DESC",

   //'report_pie_alert_severity'=>"SELECT a.severity,count(*) AS cuantos FROM alerts_store a,devices b WHERE a.id_device=b.id_dev AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY a.severity ORDER BY cuantos DESC",
   'report_pie_alert_severity'=>"SELECT severity,count(*) AS cuantos FROM temp_report GROUP BY severity ORDER BY cuantos DESC",


   // 'report_pie_alert_ack'=>"SELECT a.ack,count(*) AS cuantos FROM alerts_store a,devices b,cfg_devices2organizational_profile e WHERE a.id_device=b.id_dev AND b.id_dev=e.id_dev AND e.id_cfg_op in (__ID_CFG_OP__) AND e.cid='default' AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY a.ack ORDER BY cuantos DESC",
   //'report_pie_alert_ack'=>"SELECT a.ack,count(*) AS cuantos FROM alerts_store a,devices b WHERE a.id_device=b.id_dev AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY a.ack ORDER BY cuantos DESC",
   'report_pie_alert_ack'=>"SELECT ack,count(*) AS cuantos FROM temp_report GROUP BY ack ORDER BY cuantos DESC",


   // 'report_pie_alert_mtype'=>"SELECT a.type,count(*) AS cuantos FROM alerts_store a,cfg_devices2organizational_profile e WHERE a.id_device=e.id_dev AND e.id_cfg_op in (__ID_CFG_OP__) AND e.cid='default' AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY a.type ORDER BY cuantos DESC",
   //'report_pie_alert_mtype'=>"SELECT a.type,count(*) AS cuantos FROM alerts_store a WHERE a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY a.type ORDER BY cuantos DESC",
   'report_pie_alert_mtype'=>"SELECT mtype AS type ,count(*) AS cuantos FROM temp_report GROUP BY type ORDER BY cuantos DESC",

   // 'report_pie_alert_ticket'=>"SELECT n.name,count(*) AS cuantos FROM alerts_store a,cfg_devices2organizational_profile e,ticket t, note_types n WHERE a.id_device=e.id_dev AND  a.id_alert=t.id_alert AND t.ticket_type=n.id_note_type AND e.id_cfg_op in (__ID_CFG_OP__) AND e.cid='default' AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY a.type ORDER BY cuantos DESC",
   //'report_pie_alert_ticket'=>"SELECT n.name,count(*) AS cuantos FROM alerts_store a,ticket t, note_types n WHERE a.id_alert=t.id_alert AND t.ticket_type=n.id_note_type AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY a.type ORDER BY cuantos DESC",
   //'report_pie_alert_ticket'=>"SELECT IF(a.id_ticket>0,1,0) as tic,count(*) AS cuantos FROM alerts_store a,cfg_devices2organizational_profile e WHERE a.id_device=e.id_dev AND e.id_cfg_op in (__ID_CFG_OP__) AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ GROUP BY tic ORDER BY cuantos DESC",

   //'report_pie_alert_ticket'=>"SELECT IF(a.id_ticket>0,1,0) as tic,count(*) AS cuantos FROM alerts_store a,devices b WHERE a.id_device=b.id_dev AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY tic ORDER BY cuantos DESC",
   'report_pie_alert_ticket'=>"SELECT IF(id_ticket>0,1,0) as tic,count(*) AS cuantos FROM temp_report GROUP BY tic ORDER BY cuantos DESC",

   //'report_grid_alert_device'=>"SELECT b.type,count(*) AS cuantos,sum(a.duration) AS duration_total FROM alerts_store a,devices b,cfg_devices2organizational_profile e WHERE a.id_device=b.id_dev AND b.id_dev=e.id_dev AND e.id_cfg_op in (__ID_CFG_OP__) AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ GROUP BY b.type ORDER BY cuantos DESC",
   // 'report_grid_alert_device'=>"SELECT b.name,b.domain,b.ip,b.type,count(*) AS cuantos FROM alerts_store a,devices b,cfg_devices2organizational_profile e WHERE a.id_device=b.id_dev AND b.id_dev=e.id_dev AND e.id_cfg_op in (__ID_CFG_OP__) AND e.cid='default' AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY b.ip ORDER BY cuantos DESC",

//   'report_grid_alert_device'=>"SELECT b.name,b.domain,b.ip,b.type,count(*) AS cuantos FROM alerts_store a,devices b WHERE a.id_device=b.id_dev AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY b.ip ORDER BY cuantos DESC",

	'report_grid_alert_device'=>"SELECT severity,name,domain,ip,type,label,sum(dur) AS duration,count(*) AS cuantos FROM temp_report GROUP BY ip,label,severity ORDER BY cuantos DESC",

   // 'report_grid_alert_device_type'=>"SELECT b.type,a.severity,count(*) AS cuantos,sum(a.duration) AS duration_total FROM alerts_store a,devices b,cfg_devices2organizational_profile e WHERE a.id_device=b.id_dev AND b.id_dev=e.id_dev AND e.id_cfg_op in (__ID_CFG_OP__) AND e.cid='default' AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY b.type,a.severity ORDER BY type,severity",

//   'report_grid_alert_device_type_in'=>"SELECT b.type,a.severity,count(*) AS cuantos,sum(a.duration) AS duration_total FROM alerts_store a,devices b WHERE a.id_device=b.id_dev AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY b.type,a.severity ORDER BY type,severity",
//   'report_grid_alert_device_type_out'=>"SELECT b.type,a.severity,count(*) AS cuantos,sum(a.duration) AS duration_total FROM alerts_store a,devices b WHERE a.id_device=b.id_dev AND a.date<__DATE_START__ AND a.date_store>__DATE_START__ __COND__ GROUP BY b.type,a.severity ORDER BY type,severity",

   'report_grid_alert_device_type_in'=>"SELECT type,severity,count(*) AS cuantos,sum(dur) AS duration_total FROM temp_report  WHERE in_out='IN' GROUP BY type,severity ORDER BY type,severity",
   'report_grid_alert_device_type_out'=>"SELECT type,severity,count(*) AS cuantos,sum(dur) AS duration_total FROM temp_report  WHERE in_out='OUT' GROUP BY type,severity ORDER BY type,severity",


   'report_grid_alert_cause_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS cfg_all_metrics",
   'report_grid_alert_cause_create_temp'=>"CREATE TEMPORARY TABLE cfg_all_metrics (SELECT 'latency' as type,monitor as subtype,description as descr FROM cfg_monitor WHERE cfg=1) UNION (SELECT 'snmp' as type,subtype,descr FROM cfg_monitor_snmp) UNION (SELECT 'xagent' as type ,subtype,description as descr FROM cfg_monitor_agent) UNION (SELECT 'remote' as type,subtype,descr FROM cfg_remote_alerts)",
	// Parche debido a que la metrica de SIN RESPUESTA SNMP esta definida como SNMP y como REMOTE
	'report_grid_alert_cause_create_temp_post'=>"DELETE FROM cfg_all_metrics WHERE type='snmp' AND subtype='mon_snmp'",
   // 'report_grid_alert_cause'=>"SELECT c.descr,a.severity,sum(a.duration) AS duration_total,count(*) AS cuantos  FROM alerts_store a,devices b,cfg_devices2organizational_profile e, cfg_all_metrics c WHERE a.id_device=b.id_dev AND b.id_dev=e.id_dev AND e.id_cfg_op in (__ID_CFG_OP__) AND e.cid='default' AND c.subtype=a.subtype AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY c.descr ORDER BY duration_total DESC",

//   'report_grid_alert_cause'=>"SELECT c.descr,a.severity,sum(a.duration) AS duration_total,count(*) AS cuantos  FROM alerts_store a,devices b, cfg_all_metrics c WHERE a.id_device=b.id_dev AND c.subtype=a.subtype AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ __COND__ GROUP BY c.descr ORDER BY duration_total DESC",


	'report_grid_alert_cause_in'=>"SELECT c.descr,a.severity,sum(a.dur) AS duration_total,count(*) AS cuantos  FROM temp_report a, cfg_all_metrics c WHERE c.subtype=a.subtype AND in_out='IN' GROUP BY c.descr ORDER BY duration_total DESC",
	'report_grid_alert_cause_out'=>"SELECT c.descr,a.severity,sum(a.dur) AS duration_total,count(*) AS cuantos  FROM temp_report a, cfg_all_metrics c WHERE c.subtype=a.subtype AND in_out='OUT' GROUP BY c.descr ORDER BY duration_total DESC",

   'report_grid_alert_date_in'=>"SELECT a.id_alert,a.ack,a.id_ticket as ticket,a.severity,a.type,a.date,a.date_store,from_unixtime(a.date) AS date_str, b.status,b.name,b.domain,b.ip,label,event_data,duration,b.type as dev_type,IF(a.type='latency',a.mname,a.subtype) as subtype,a.id_ticket,a.id_metric FROM alerts_store a,devices b WHERE a.id_device=b.id_dev AND __COND__ AND a.date>=__DATE_START__ AND a.date<=__DATE_END__ ORDER BY ip,date",
   'report_grid_alert_date_out'=>"SELECT a.id_alert,a.ack,a.id_ticket as ticket,a.severity,a.type,a.date,a.date_store,from_unixtime(a.date) AS date_str, b.status,b.name,b.domain,b.ip,label,event_data,duration,b.type as dev_type,IF(a.type='latency',a.mname,a.subtype) as subtype,a.id_ticket,a.id_metric FROM alerts_store a,devices b WHERE a.id_device=b.id_dev AND __COND__ AND a.date<__DATE_START__ AND a.date_store>__DATE_START__ ORDER BY ip,date",

	'delete_temp_report' => "DROP TABLE IF EXISTS temp_report",
   'create_temp_report_00000001'=>"CREATE  TABLE temp_report (SELECT * FROM temp_report_00000001)",
	'store_temp_report_00000001' => "INSERT INTO temp_report (id_alert,severity,ack,event_data,date,date_store,duration,dur,dur_extra,in_out,label,cause,name,domain,ip,type,subtype,id_ticket,mtype,id_metric) VALUES (__ID_ALERT__,__SEVERITY__,__ACK__,'__EVENT_DATA__',__DATE__,__DATE_STORE__,__DURATION__,__DUR__,__DUR_EXTRA__,'__IN_OUT__','__LABEL__','__CAUSE__','__NAME__','__DOMAIN__','__IP__','__TYPE__','__SUBTYPE__',__ID_TICKET__,'__MTYPE__',__ID_METRIC__ ) ",
	'update1_temp_report_00000001' => "update temp_report set subtype='mon_snmp' WHERE label='SIN RESPUESTA SNMP'",
	'update2_temp_report_00000001' => "UPDATE temp_report t, metrics m SET t.label=CONCAT(t.label,' ',m.label) WHERE t.id_metric=m.id_metric AND m.iid != 'ALL'",

	'get_temp_report_first_date' => "SELECT date FROM temp_report ORDER BY date ASC LIMIT 1",
	'get_temp_report_last_date' => "SELECT date FROM temp_report ORDER BY date DESC LIMIT 1",



	'report_grid_device_alert_previous'=>"SELECT from_unixtime(a.date) as date_store,a.duration,ifnull(n.name,'-') as name,ifnull(t.descr,'-') as descr from alerts_store a LEFT JOIN ticket t  ON  a.id_ticket=t.id_ticket LEFT JOIN note_types n ON n.id_note_type=t.ticket_type WHERE id_device=__ID_DEV__ and mname='__MNAME__' AND a.date_store<__DATE_STORE__ order by a.date_store desc limit 15",
	'report_grid_device_alert_previous_ticket'=>"SELECT from_unixtime(a.date) as date_store,a.duration,u.descr as user,ifnull(t.ref,'-') as ref,  ifnull(n.name,'-') as name,ifnull(t.descr,'-') as descr FROM alerts_store a, ticket t, note_types n, cfg_users u WHERE id_device=__ID_DEV__ and mname='__MNAME__' AND a.date_store<__DATE_STORE__ AND u.login_name=t.login_name AND a.id_ticket=t.id_ticket AND n.id_note_type=t.ticket_type order by a.date_store desc limit 15",

	'report_grid_same_alert_previous'=>"SELECT from_unixtime(a.date) as date_store,a.duration,concat(d.name,'.',d.domain) as name_domain,ifnull(n.name,'-') as name,ifnull(t.descr,'-') as descr from devices d, alerts_store a LEFT JOIN ticket t  ON  a.id_ticket=t.id_ticket LEFT JOIN note_types n ON n.id_note_type=t.ticket_type WHERE a.id_device=d.id_dev AND id_device!=__ID_DEV__ and mname='__MNAME__' AND a.date_store<__DATE_STORE__ order by a.date_store desc limit 15",

	'report_grid_same_alert_previous_ticket'=>"SELECT from_unixtime(a.date) as date_store,a.duration,concat(d.name,'.',d.domain) as name_domain,u.descr as user,ifnull(t.ref,'-') as ref, ifnull(n.name,'-') as name,ifnull(t.descr,'-') as descr FROM alerts_store a, devices d, ticket t, note_types n, cfg_users u WHERE  id_device!=__ID_DEV__ and mname='__MNAME__' AND a.date_store<__DATE_STORE__ AND d.id_dev=a.id_device AND u.login_name=t.login_name AND a.id_ticket=t.id_ticket AND n.id_note_type=t.ticket_type order by a.date_store desc limit 15",

	'report_grid_alert_response'=>'SELECT id_alert,type,descr,rc,rcstr,info,from_unixtime(date) AS date FROM alert2response WHERE id_alert IN (__ID_ALERT__)',
	'report_total_devices'=>"SELECT count(*) as cuantos FROM devices",
	'report_licensed_devices'=>"SELECT IFNULL(value,0) as cuantos,date_store FROM cnm_services WHERE type='num'",
	'report_timeout_license'=>"SELECT from_unixtime(value) as human_timeout,value as timeout,date_store FROM cnm_services WHERE type='tlast'",
   'save_report_store'=>"INSERT INTO report_store (subtype_cfg_report,date_start,date_end,data,name,type) VALUES ('__SUBTYPE_CFG_REPORT__','__DATE_START__','__DATE_END__','__DATA__','__NAME__','__TYPE__')",
   'read_report_store'=>"SELECT data FROM report_store WHERE id_report=__ID_REPORT__",

	'report_support_id'=>"SELECT IFNULL(value,'') as support,date_store FROM cnm_services WHERE type='support'",
	'report_revision'=>"SELECT IFNULL(value,'') as rev FROM cnm_services WHERE type='rev'",
	'report_total_metrics_active'=>"SELECT count(*) as cuantos from devices d, metrics m WHERE d.id_dev=m.id_dev AND d.status=0 and m.status=0",
	'report_total_views_cfg'=>"SELECT count(*) as cuantos FROM cfg_views",
	'report_total_metrics_snmp_cfg'=>"SELECT count(*) as cuantos FROM cfg_monitor_snmp",
	'report_total_metrics_tcp_cfg'=>"SELECT count(*) as cuantos FROM cfg_monitor",
	'report_total_metrics_xagent_cfg'=>"SELECT count(*) as cuantos FROM cfg_monitor_agent",
	'report_total_monitors_cfg'=>"SELECT count(*) as cuantos FROM alert_type",
	'report_total_remote_alerts'=>"SELECT count(*) as cuantos FROM cfg_remote_alerts",
	'report_total_events'=>"SELECT count(*) as cuantos FROM events",

   //----------------------------------------------------
   'app_devices_asoc_lista'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'app_devices_asoc_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

   'cnm_cfg_report_delete'=>"DROP TEMPORARY TABLE IF EXISTS t1,t2",
   'cnm_cfg_report_temp1'=>"CREATE TEMPORARY TABLE t2 (SELECT COUNT(*) AS cuantos,subtype_cfg_report from report_store group by (subtype_cfg_report))",
   'cnm_cfg_report_temp2_admin'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_cfg_report,a.subtype_cfg_report,a.title,a.description,a.custom,IFNULL(t2.cuantos,0) AS cuantos FROM cfg_report a LEFT JOIN t2 ON a.subtype_cfg_report=t2.subtype_cfg_report WHERE a.store=1 AND a.custom=1)",
   'cnm_cfg_report_temp2_user'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_cfg_report,a.subtype_cfg_report,a.title,a.description,a.custom,IFNULL(t2.cuantos,0) AS cuantos FROM (cfg_report a,cfg_user2report b)LEFT JOIN t2 ON a.subtype_cfg_report=t2.subtype_cfg_report WHERE a.store=1 AND a.custom=1 AND a.id_cfg_report=b.id_cfg_report AND b.id_user IN (__ID_USER__))",
   'cnm_cfg_report_get_list'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'cnm_cfg_report_get_list_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
   'get_report_store_delete'=>"DROP TEMPORARY TABLE IF EXISTS t1",
   'get_report_store_temp1'=>"CREATE TEMPORARY TABLE t1(SELECT id_report,name,subtype_cfg_report,type,from_unixtime(date_start) as date_start,from_unixtime(date_end) as date_end,CONCAT(CONCAT(from_unixtime(date_start),'<br>'),from_unixtime(date_end)) AS date FROM report_store WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__')",
   'get_report_store_list'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'get_report_store_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
   'get_report_store_all'=>"SELECT id_report,from_unixtime(date_start) as date_start,from_unixtime(date_end) as date_end,name,type FROM report_store WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__'",
   'get_report_store_count'=>"SELECT COUNT(*) AS cuantos FROM report_store WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__'",
   'get_info_report_store'=>"SELECT id_report,subtype_cfg_report,from_unixtime(date_start) as date_start,from_unixtime(date_end) as date_end,date_start AS date_start_unixtime,date_end AS date_end_unixtime,name FROM report_store WHERE id_report IN (__ID_REPORT__)",
   'get_info_report'=>"SELECT id_cfg_report,title,description,custom,itil_type,apptype,store FROM cfg_report WHERE subtype_cfg_report = '__SUBTYPE_CFG_REPORT__'",
	'delete_report_store'=>"DELETE FROM report_store WHERE id_report IN (__ID_REPORT__)",
	//'report_last_week_alerts_bar'=>"SELECT count(*) AS cuantos,severity FROM alerts_store WHERE date>__DATE_START__ AND date<__DATE_END__ __COND__ GROUP BY severity",
	'report_last_week_alerts_bar'=>"SELECT count(*) AS cuantos,severity FROM temp_report WHERE date>__DATE_START__ AND date<__DATE_END__ GROUP BY severity",

   //----------------------------------------------------
	// 'flot_sql'=>"SELECT * FROM __TABLE__ WHERE id_dev IN (__ID_DEV__) AND ts_line>__DATE_START__ AND ts_line<__DATE_END__",
	'flot_sql'=>"SELECT * FROM __TABLE__ WHERE id_dev IN (__ID_DEV__) AND ts_line>__DATE_START__ AND ts_line<__DATE_END__ AND hiid='__HIID__'",

   //----------------------------------------------------
	'get_cnm_config'=>"SELECT * FROM cnm_config WHERE cnm_key='__CNM_KEY__'",	
	'update_cnm_config'=>"UPDATE cnm_config SET cnm_value='__CNM_VALUE__' WHERE cnm_key='__CNM_KEY__'",
	//----------------------------------------------------
	'get_device_from_alert'=>"SELECT DISTINCT(id_device) AS id_dev FROM alerts WHERE id_alert IN (__ID_ALERT__)",
	'get_device_from_halert'=>"SELECT DISTINCT(id_device) AS id_dev FROM alerts_store WHERE id_alert IN (__ID_ALERT__)",
	'get_device_data'=>"SELECT ip,status,name,domain FROM devices WHERE id_dev IN (__ID_DEV__)",	
	'set_device_status'=>"UPDATE devices SET status='__STATUS__' WHERE id_dev IN (__ID_DEV__)",
	'set_device_ip'=>"UPDATE devices SET ip='__IP__' WHERE id_dev IN (__ID_DEV__)",
   //----------------------------------------------------
	// 'cnm_local_hidx'=>"SELECT hidx,host_ip,host_name,host_descr FROM cnm.cfg_cnms WHERE host_ip='__IP__' AND cid='default'",
	'cnm_local_hidx'=>"SELECT hidx,host_ip,host_name,host_descr,cid FROM cnm.cfg_cnms WHERE cid='__CID__' AND host_ip='__IP__'",
	// 'cnm_local_hidx'=>"SELECT hidx,host_ip,host_name,host_descr FROM cnm.cfg_cnms WHERE host_ip='__IP__'",
	'cnm_id_domain'=>"SELECT id_domain FROM cnm.cfg_cnms2domains WHERE hidx=__HIDX__",
	'cnm_id_client'=>"SELECT id_client FROM cnm.cfg_clients WHERE cid='__CID__'",
	'cnm_cfg_hosts'=>"SELECT a.host_ip, a.host_name, a.descr, a.hidx,a.cid FROM cnm.cfg_cnms a, cnm.cfg_cnms2domains b, cnm.cfg_domains c WHERE a.hidx=b.hidx AND b.id_domain=c.id_domain AND c.name='__NAME_DOMAIN__' ORDER BY a.cid",
	'cnm_info_host'=>"SELECT hidx,host_ip,host_name, host_descr,cid FROM cnm.cfg_cnms WHERE hidx IN (__HIDX__)",

   //----------------------------------------------------
	'get_view_rule'=>"SELECT id_cfg_viewsruleset,descr,severity,weight,rule_int,logic FROM cfg_viewsruleset WHERE id_cfg_view IN (__ID_CFG_VIEW__) ORDER BY severity,weight",
	'del_view_rule'=>"DELETE FROM cfg_viewsruleset WHERE id_cfg_viewsruleset IN (__ID_CFG_VIEWSRULESET__)",
	'get_view_rule_by_id'=>"SELECT id_cfg_viewsruleset,id_cfg_view,descr,severity,weight,rule_int,logic FROM cfg_viewsruleset WHERE id_cfg_viewsruleset IN (__ID_CFG_VIEWSRULESET__)",
	'get_view_rule_by_severity'=>"SELECT id_cfg_viewsruleset,descr,severity,weight,rule_int,logic FROM cfg_viewsruleset WHERE id_cfg_view IN (__ID_CFG_VIEW__) AND severity IN (__SEVERITY__) ORDER BY severity,weight",
	'new_view_rule'=>"INSERT INTO cfg_viewsruleset (id_cfg_view,descr,severity,weight,rule_int,logic) VALUES (__ID_CFG_VIEW__,'__DESCR__',__SEVERITY__,__WEIGHT__,'__RULE_INT__','__LOGIC__')",
	'modify_view_rule'=>"UPDATE cfg_viewsruleset SET severity=__SEVERITY__,logic='__LOGIC__',weight=__WEIGHT__,rule_int='__RULE_INT__',descr='__DESCR__' WHERE id_cfg_viewsruleset IN (__ID_CFG_VIEWSRULESET__)",

	'get_alerts_view_rule'=>"SELECT a.*,b.descr FROM view_alerts a, cfg_viewsruleset b WHERE a.id_cfg_viewsruleset=b.id_cfg_viewsruleset AND a.id_cfg_viewsruleset IN (__ID_CFG_VIEWSRULESET__) AND date<=__DATE__ AND a.severity IN (__SEVERITY__)",
	'get_alerts_store_view_rule'=>"SELECT a.*,b.descr FROM view_alerts_store a, cfg_viewsruleset b WHERE a.id_cfg_viewsruleset=b.id_cfg_viewsruleset AND a.id_cfg_viewsruleset IN (__ID_CFG_VIEWSRULESET__) AND ( (date_store>__DATE_STORE__) AND (date<__DATE__) ) AND a.severity IN (__SEVERITY__)",
   //----------------------------------------------------
	'correlated_by'=>"SELECT b.id_dev, b.name, b.ip ,b.domain from devices a, devices b WHERE a.id_dev=__ID_DEV__ AND a.correlated_by=b.id_dev",
	'dispositivo_mes_correlate_1'=>"UPDATE metrics SET correlate=0 WHERE id_dev IN (__ID_DEV__)",
	'dispositivo_mes_correlate_2'=>"UPDATE metrics SET correlate=1 WHERE id_metric IN (__ID_METRIC__)",
	'dispositivo_mes_correlate_3'=>"UPDATE cfg_outside_correlation_rules SET mname=(SELECT name FROM metrics WHERE id_metric IN (__ID_METRIC__)) WHERE id_dev IN (__ID_DEV__)",
// 'insert_cfg_outside_correlation_rules'=>"INSERT IGNORE INTO cfg_outside_correlation_rules (mname,id_dev,id_dev_correlated) VALUES ('__MNAME__',__ID_DEV__,__ID_DEV_CORRELATED__)",
	'get_cfg_task_audit'=>"SELECT name,subtype FROM cfg_task_configured WHERE task='app_cnm_audit'",
	'get_cfg_task_audit_result'=>"SELECT id_qactions,rcstr,from_unixtime(date_end) as date_end FROM qactions where action='__ACTION__' ORDER BY date_end DESC",
   //----------------------------------------------------
	// Service center
   // Datos de una alerta
   'sc_info_alert'=>"SELECT id_device,event_data FROM __TABLE__ WHERE id_alert=__ID_ALERT__",
   // Datos de un ticket
   'sc_info_ticket'=>"SELECT id_ticket,ticket_type as id_note_type,ref as note_id,descr as notes FROM ticket WHERE id_alert=__ID_ALERT__",
   // Todos los id_note_type y name de note_types
   'sc_all_note_types'=>"SELECT id_note_type,name FROM note_types",
   // Todos los field de extra_sc_level del nivel __FIELD__
   'sc_all_field'=>"SELECT DISTINCT(__FIELD__) AS field FROM extra_sc_level WHERE ''='' __CONDITION__ ORDER BY __FIELD__",
   'sc_all_ticket_type'=>"select id_note_type,name from note_types",
   // Todos los contactos
   'sc_all_contact'=>"SELECT id_sc_contact as id,contact FROM extra_sc_contact ORDER BY contact",
    // Obtener el contact a partir de su id
   'sc_contact_by_id'=>"SELECT contact FROM extra_sc_contact WHERE id_sc_contact LIKE '__ID_SC_CONTACT__'",
   // Crear una nota de una vista
   'sc_insert_tip_view'=>"INSERT INTO tips (id_ref,tip_type,name,descr,url,date) VALUES (__ID_REF__,'__TIP_TYPE__','__NAME__','__DESCR__','__URL__',__DATE__)",
   // Actualizar un ticket con el numero de ticket devuelto por el service center
   'sc_insert_ticket'=>"UPDATE ticket SET ref='__TICKET__',descr='__DESCR__' WHERE id_alert =__ID_ALERT__",
   'sc_insert_ticket2'=>"UPDATE alerts SET ticket_descr='__DESCR__' WHERE id_alert =__ID_ALERT__",
   'sc_insert_ticket3'=>"UPDATE alerts_read SET ticket_descr='__DESCR__' WHERE id_alert =__ID_ALERT__ AND cid='__CID__' AND cid_ip='__CID_IP__'",
   // Informacion de una alerta para pasarla por SC
   'sc_ticket_info'=>"SELECT d.name as hostname, t.event_data as causa_evento, t.descr FROM ticket t, devices d WHERE d.id_dev=t.id_dev AND t.id_alert=__ID_ALERT__",

   //----------------------------------------------------
   // Service Manager
   // Datos de una alerta
   'sm_info_alert'=>"SELECT id_device,event_data FROM __TABLE__ WHERE id_alert=__ID_ALERT__",
   // Datos de un ticket

   'sm_info_ticket'=>"SELECT a.id_ticket,b.categoria,b.area,b.subarea,b.ref,b.severidad,b.usuario,b.global,b.ref FROM ticket a,extra_sm_ticket b WHERE a.id_alert=__ID_ALERT__ AND a.id_ticket=b.id_ticket",
	'sm_clear_auto_ticket'=>"DELETE FROM extra_sm_ticket where (id_ticket not in (SELECT id_ticket from alerts_store)) AND (id_ticket NOT IN (SELECT id_ticket from alerts))",
   // Todos los id_note_type y name de note_types
   'sm_all_note_types'=>"SELECT id_note_type,name FROM note_types",
   // Todos los field de extra_sc_level del nivel __FIELD__
   'sm_all_field'=>"SELECT DISTINCT(__FIELD__) AS field FROM extra_sm_level WHERE ''='' __CONDITION__ ORDER BY __FIELD__",
   'sm_all_ticket_type'=>"select id_note_type,name from note_types",
   // Todos los contactos
   'sm_all_contact'=>"SELECT id_sm_contact as id,contact FROM extra_sm_contact ORDER BY contact",
    // Obtener el contact a partir de su id
   'sm_contact_by_id'=>"SELECT contact FROM extra_sm_contact WHERE id_sm_contact LIKE '__ID_SM_CONTACT__'",
   // Crear una nota de una vista
   'sm_insert_tip_view'=>"INSERT INTO tips (id_ref,tip_type,name,descr,url,date) VALUES (__ID_REF__,'__TIP_TYPE__','__NAME__','__DESCR__','__URL__',__DATE__)",
   // Actualizar un ticket con el numero de ticket devuelto por el service center
   'sm_insert_ticket'=>"UPDATE ticket SET ref='__TICKET__',descr='__DESCR__' WHERE id_alert =__ID_ALERT__",
   'sm_insert_ticket2'=>"UPDATE alerts SET ticket_descr='__DESCR__' WHERE id_alert =__ID_ALERT__",
   'sm_insert_ticket3'=>"UPDATE alerts_read SET ticket_descr='__DESCR__' WHERE id_alert =__ID_ALERT__ AND cid='__CID__' AND cid_ip='__CID_IP__'",
   // Informacion de una alerta para pasarla por SM
   'sm_ticket_info'=>"SELECT d.name as hostname, t.event_data as causa_evento, t.descr,t.id_ticket FROM ticket t, devices d WHERE d.id_dev=t.id_dev AND t.id_alert=__ID_ALERT__",
   'sm_extra_sm_ticket_info'=>"SELECT * FROM extra_sm_ticket WHERE id_ticket=__ID_TICKET__",

/*
  `id_sm_ticket` int(11) NOT NULL AUTO_INCREMENT,
  `id_ticket` int(11) NOT NULL,
  `categoria` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT '',
  `area` varchar(80) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT '',
  `subarea` varchar(120) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT '',
  `ref` varchar(120) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT '',
  `severidad` varchar(120) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT '',
  `usuario` varchar(120) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT '',
  `global` int(11) NOT NULL DEFAULT '0',

*/
	'sm_insert_extra_sm_ticket'=>"INSERT INTO extra_sm_ticket (id_ticket,categoria,area,subarea,ref,severidad,usuario,global) VALUES (__ID_TICKET__,'__CATEGORIA__','__AREA__','__SUBAREA__','__REF__','__SEVERIDAD__','__USUARIO__',__GLOBAL__)",
	'sm_update_extra_sm_ticket'=>"UPDATE extra_sm_ticket SET categoria='__CATEGORIA__',area='__AREA__',subarea='__SUBAREA__',ref='__REF__',severidad='__SEVERIDAD__',usuario='__USUARIO__',global='__GLOBAL__' WHERE id_sm_ticket=__ID_SM_TICKET__",




	// Obtener búsquedas de usuario almacenadas
	// 'info_search_store'=>"SELECT id_search_store,scope,name,value,id_user FROM search_store WHERE scope='__SCOPE__' AND id_user IN (__ID_USER__) ORDER BY name",
	'info_search_store'=>"SELECT id_search_store,scope,name,value,id_user FROM search_store WHERE scope='__SCOPE__'",
	'info_search_store_by_id_search_scope'=>"SELECT id_search_store,scope,name,value,id_user FROM search_store WHERE scope='__SCOPE__' AND id_search_store IN (__ID_SEARCH_STORE__)",
	// Obtener búsquedas de usuario almacenadas por ID
	'info_search_store_by_id'=>"SELECT id_search_store,scope,name,value,id_user FROM search_store WHERE id_search_store IN (__ID_SEARCH_STORE__)",
	// Crear una búsqueda de usuario
	'create_search_store'=>"INSERT INTO search_store (scope,name,value,id_user) VALUES ('__SCOPE__','__NAME__','__VALUE__',__ID_USER__)",
	// Modificar una búsqueda de usuario
	'modify_search_store'=>"UPDATE search_store SET scope='__SCOPE__',name='__NAME__',value='__VALUE__',id_user=__ID_USER__ WHERE id_search_store IN (__ID_SEARCH_STORE__)",
	// Borrar una búsqueda de usuario
	'delete_search_store'=>"DELETE FROM search_store WHERE id_search_store IN (__ID_SEARCH_STORE__)",

	// Informacion de alerts_read
	'info_alerts_read'=>"SELECT a.* FROM alerts_read a, cnm.cfg_cnms b WHERE a.cid=b.cid AND a.cid_ip=b.host_ip AND a.id_alert IN (__ID_ALERT__) AND b.hidx IN (__HIDX__)",

	'app_devices_delete'=>"DROP TEMPORARY TABLE IF EXISTS t1,t2",
	'app_devices_asoc_temp1'=>"CREATE TEMPORARY TABLE t2 (SELECT a.id_dev,1 AS asoc FROM cfg_app2device a, cfg_monitor_apps b WHERE a.aname=b.aname AND b.id_monitor_app IN (__ID_MONITOR_APP__))",
	'app_devices_asoc_temp2'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_dev,a.status,a.name,a.domain,a.ip,a.type,a.mac,a.sysoid,a.sysdesc,a.sysloc,IFNULL(t2.asoc,0) AS asoc__USER_FIELDS__ FROM devices a LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev LEFT JOIN t2 ON a.id_dev=t2.id_dev)",
   'app_devices_asoc_lista'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'app_devices_asoc_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
   'task_devices_delete'=>"DROP TEMPORARY TABLE IF EXISTS t1,t2",
   'task_devices_asoc_temp1'=>"CREATE TEMPORARY TABLE t2 (SELECT a.id_dev,1 AS asoc FROM task2device a,cfg_task_configured b WHERE b.subtype=a.name AND b.id_cfg_task_configured IN (__ID_CFG_TASK_CONFIGURED__) AND a.type='device')",
   'task_devices_asoc_temp2'=>"CREATE TEMPORARY TABLE t1 (SELECT a.id_dev,a.status,a.name,a.domain,a.ip,a.type,a.mac,IFNULL(t2.asoc,0) AS asoc FROM devices a LEFT JOIN t2 ON a.id_dev=t2.id_dev)",
   'task_devices_asoc_lista'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'task_devices_asoc_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
	'task_asociar_dispositivo'=>"INSERT IGNORE INTO task2device (name,id_dev,ip) (SELECT '__NAME__',id_dev,ip FROM devices WHERE id_dev IN (__ID_DEV__))",
   'task_desasociar_dispositivo'=>"DELETE FROM task2device WHERE name='__NAME__' AND id_dev IN (__ID_DEV__) AND type='device'",
	'cnm_graph_last_week_alerts'=>"SELECT date_store,IF(date<__LAST_WEEK__,__LAST_WEEK__,date) AS date FROM alerts_store WHERE id_metric=__ID_METRIC__ AND id_device=__ID_DEVICE__ AND ((__LAST_WEEK__ BETWEEN date AND date_store) OR (date>__LAST_WEEK__) )order by date_store desc",
	'cnm_graph_active_alert'=>"SELECT IF(date<__LAST_WEEK__,__LAST_WEEK__,date) AS date FROM alerts WHERE id_metric=__ID_METRIC__ AND id_device=__ID_DEVICE__",
	// Tabla plugin_name
	'get_all_plugin_name_by_id_type_parent_1'=>"DROP TEMPORARY TABLE IF EXISTS t1",
	'get_all_plugin_name_by_id_type_parent_2'=>"CREATE TEMPORARY TABLE t1 (SELECT html_id,html_type,label,item_id,MAX(plugin_id) AS plugin_id,position from plugin_base WHERE html_id='__HTML_ID__' AND html_type='__HTML_TYPE__' AND parent='__PARENT__' GROUP BY item_id ORDER BY position)",
	'get_all_plugin_name_by_id_type_parent_3'=>"SELECT * FROM plugin_base WHERE (html_id,html_type,label,plugin_id,item_id) IN (SELECT html_id,html_type,label,plugin_id,item_id FROM t1) ORDER BY position",
	'get_num_device_types'=>"SELECT count(*) AS cuantos from cfg_host_types",
	'get_num_view_types'=>"SELECT count(*) AS cuantos from cfg_views_types",
   'get_all_plugin_name_by_id_type_1'=>"DROP TEMPORARY TABLE IF EXISTS t1",
   'get_all_plugin_name_by_id_type_2'=>"CREATE TEMPORARY TABLE t1 (SELECT html_id,html_type,label,MAX(plugin_id) AS plugin_id,position from plugin_base WHERE html_id='__HTML_ID__' AND html_type='__HTML_TYPE__' GROUP BY label ORDER BY position)",
   'get_all_plugin_name_by_id_type_3'=>"SELECT * FROM plugin_base WHERE (html_id,html_type,label,plugin_id) IN (SELECT html_id,html_type,label,plugin_id FROM t1) ORDER BY position",
	'get_info_plugin_by_item_id_item_type'=>"SELECT * FROM plugin_base WHERE item_type='__ITEM_TYPE__' AND item_id='__ITEM_ID__'",
	'get_info_plugin_include'=>"SELECT * FROM plugin_base WHERE html_type='include'",

	// Tabla proxy_list
	'proxy_cnm_list_all'=>"SELECT * FROM proxy_list",
	'proxy_cnm_list_by_type'=>"SELECT * FROM proxy_list WHERE proxy_type = '__PROXY_TYPE__'",
	'proxy_cnm_list_by_id'=>"SELECT * FROM proxy_list WHERE id_proxy IN (__ID_PROXY__)",
	'del_cfg_proxy'=>"DELETE FROM proxy_list WHERE id_proxy IN (__ID_PROXY__)",
	'create_cfg_proxy'=>"INSERT INTO proxy_list (proxy_host,proxy_user,proxy_pwd,proxy_port,proxy_type) VALUES ('__IP__','__USER__','__PASS__','__PORT__','__PROXY_TYPE__')",
	'mod_cfg_proxy_nopasswd'=>"UPDATE proxy_list SET proxy_user='__USER__',proxy_port='__PORT__',proxy_type='__PROXY_TYPE__',proxy_host='__IP__' WHERE id_proxy IN (__ID_PROXY__)",
	'mod_cfg_proxy'=>"UPDATE proxy_list SET proxy_user='__USER__',proxy_pwd='__PASS__',proxy_host='__IP__',proxy_port='__PORT__',proxy_type='__PROXY_TYPE__' WHERE id_proxy IN (__ID_PROXY__)",
	'get_proxy_type_list'=>"SELECT * FROM proxy_types",

	// Tabla tech_group
	'tech_group_list_all'=>"SELECT * FROM tech_group ORDER BY name",

	// Tabla support_pack
	'support_pack_list_all'=>"SELECT * FROM support_pack ORDER BY name",
	'support_pack2tech_group_list_all'=>"SELECT * FROM support_pack2tech_group",
	'support_pack2tech_group_list_all_concat_name'=>"SELECT a.id_support_pack,a.subtype,a.name,IFNULL(GROUP_CONCAT(b.name),'') AS apptype_concat FROM support_pack a LEFT JOIN support_pack2tech_group b ON a.subtype=b.subtype GROUP BY a.subtype ORDER BY a.name",
	'support_pack2tech_group_by_subtype'=>"SELECT * FROM support_pack2tech_group WHERE subtype='__SUBTYPE__'",
	'support_pack2tech_group_concat_by_subtype'=>"SELECT GROUP_CONCAT(name) AS name_concat,subtype from support_pack2tech_group WHERE subtype='__SUBTYPE__' GROUP BY subtype",
	// ------------------------------------------------------------------
	'support_pack_metrics_snmp'=>"SELECT a.descr AS description,a.apptype,a.id_cfg_monitor_snmp,a.custom FROM cfg_monitor_snmp a,support_pack2tech_group b WHERE b.subtype='__SUBTYPE__' AND b.name=a.apptype ORDER BY a.descr",
	'support_pack_metrics_latency'=>"SELECT a.description,a.apptype,a.id_cfg_monitor,a.custom FROM cfg_monitor a,support_pack2tech_group b WHERE b.subtype='__SUBTYPE__' AND b.name=a.apptype ORDER BY a.description",
	'support_pack_metrics_agent'=>"SELECT a.description,a.apptype,a.id_cfg_monitor_agent,a.custom,a.class FROM cfg_monitor_agent a,support_pack2tech_group b WHERE b.subtype='__SUBTYPE__' AND b.name=a.apptype ORDER BY a.description",
	'support_pack_monitor'=>"SELECT a.cause AS description,a.apptype,a.monitor FROM alert_type a,support_pack2tech_group b WHERE b.subtype='__SUBTYPE__' AND b.name=a.apptype ORDER BY a.cause",
	'support_pack_app'=>"SELECT a.name AS description,a.apptype,a.id_monitor_app,a.custom FROM cfg_monitor_apps a,support_pack2tech_group b WHERE b.subtype='__SUBTYPE__' AND b.name=a.apptype ORDER BY a.name",
	'support_pack_remote'=>"SELECT a.descr AS description,a.apptype,a.id_remote_alert FROM cfg_remote_alerts a,support_pack2tech_group b WHERE b.subtype='__SUBTYPE__' AND b.name=a.apptype ORDER BY a.descr",


   'support_pack_num_metrics_snmp'=>"SELECT COUNT(*) AS cuantos FROM cfg_monitor_snmp WHERE apptype='__APPTYPE__'",
   'support_pack_num_metrics_latency'=>"SELECT COUNT(*) AS cuantos FROM cfg_monitor WHERE apptype='__APPTYPE__'",
   'support_pack_num_metrics_agent'=>"SELECT COUNT(*) AS cuantos FROM cfg_monitor_agent WHERE apptype='__APPTYPE__'",
   'support_pack_num_monitor'=>"SELECT COUNT(*) AS cuantos FROM alert_type WHERE apptype='__APPTYPE__'",
   'support_pack_num_app'=>"SELECT COUNT(*) AS cuantos FROM cfg_monitor_apps WHERE apptype='__APPTYPE__'",
   'support_pack_num_remote'=>"SELECT COUNT(*) AS cuantos FROM cfg_remote_alerts WHERE apptype='__APPTYPE__'",


	'device2log_from_device'=>"SELECT a.*,b.name,b.descr FROM device2log a, credentials b WHERE a.id_dev IN (__ID_DEV__) AND a.id_credential=b.id_credential",
	'device2log_deleteall_from_device'=>"DELETE FROM device2log WHERE id_dev IN (__ID_DEV__)",
	'device2log_update_status_from_device'=>"UPDATE device2log SET status=__STATUS__ WHERE id_dev IN (__ID_DEV__)",
	'device2log_insert'=>"INSERT INTO device2log (id_dev,id_credential,logfile,todb,status,parser,tabname) VALUES (__ID_DEV__,__ID_CREDENTIAL__,'__LOGFILE__',__TODB__,__STATUS__,'__PARSER__','__TABNAME__')",
	'device2log_update'=>"UPDATE device2log SET id_credential=__ID_CREDENTIAL__,logfile='__LOGFILE__',todb=__TODB__,status=__STATUS__,parser='__PARSER__' WHERE id_device2log=__ID_DEVICE2LOG__",
	
	'device2log_all'=>"SELECT a.id_device2log,a.id_dev,a.id_credential,a.logfile,a.todb,a.script,a.status,a.rcstr,a.parser,IF(a.last_access=0,'-',FROM_UNIXTIME(a.last_access)) AS last_access,b.name,b.domain,b.ip,c.name AS cred_name,c.descr AS cred_descr FROM device2log a, devices b,credentials c WHERE a.id_dev=b.id_dev AND a.id_credential=c.id_credential ORDER BY b.name",
	'device2log_delete_from_device'=>"DELETE FROM device2log WHERE id_dev IN (__ID_DEV__) AND logfile='__LOGFILE__'",
	'device2log_activate'=>"UPDATE device2log SET status=0 WHERE id_device2log IN (__ID_DEVICE2LOG__)",
	'device2log_deactivate'=>"UPDATE device2log SET status=1 WHERE id_device2log IN (__ID_DEVICE2LOG__)",
	'device2log_delete'=>"DELETE FROM device2log WHERE id_device2log IN (__ID_DEVICE2LOG__)",

	'get_device2log_by_id'=>"SELECT a.id_device2log,a.logfile,a.tabname,b.name,b.domain,b.ip,a.id_dev FROM device2log a, devices b WHERE a.id_dev=b.id_dev AND a.id_device2log IN (__ID_DEVICE2LOG__)",
	'exists_table'=>"SHOW TABLES LIKE '__TABLE_NAME__'",
	'create_temp_like'=>"CREATE TEMPORARY TABLE t1 LIKE __TABLE_NAME__",
	'drop_table_t1'=>"DROP TEMPORARY TABLE IF EXISTS t1",
	// 'device2log_add_temporary_table'=>"INSERT INTO t1 (hash,ts,line,logfile,id_device2log,name) SELECT hash,ts,CONCAT('__INIT_LINE__',line) AS line,'__LOGFILE__',__ID_DEVICE2LOG__,'__NAME__' FROM __TABLE_NAME__ WHERE ''='' __CONDITION__",
	'device2log_add_temporary_table'=>"INSERT INTO t1 (hash,ts,line,logfile,id_device2log,name) SELECT hash,ts,line,'__LOGFILE__',__ID_DEVICE2LOG__,'__NAME__' FROM __TABLE_NAME__ WHERE ''='' __CONDITION__",
	'device2log_get_all'=>"SELECT id_log,hash,ts,FROM_UNIXTIME(ts) AS human_ts,line,logfile,id_device2log,name FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'count_all_from_t1' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
	'get_line_from_table'=>"SELECT * FROM __TABLE_NAME__",
	'get_line_from_table_hash'=>"SELECT * FROM __TABNAME__ WHERE hash='__HASH__'",


	'update_multi_sessions_table' => "UPDATE sessions_table SET multi='__MULTI__' WHERE SID='__SID__'",
	'update_session' => "UPDATE sessions_table SET expiration=__EXPIRATION__ WHERE SID='__SID__'",
	'check_session'=> "SELECT COUNT(*) AS cuantos FROM sessions_table WHERE expiration=__EXPIRATION__ AND SID='__SID__'",
	'check_session_user_api'=> "SELECT * FROM sessions_table WHERE user='__USER__' AND origin='api'",

	'cnm_status' => "SELECT * FROM cnm_status",
	'drop_table' => "DROP TABLE __TABLE__",

	// 'gmaps_devices_alarmed'=>"select MAX(severity) AS severity,id_device,cid,cid_ip from alerts_read where cid='__CID__' AND cid_ip='__CID_IP__' AND severity<4 GROUP BY (id_device)",
	'gmaps_devices_alarmed'=>"select MIN(severity) AS severity,id_device,cid,cid_ip from alerts_read where cid='__CID__' AND cid_ip='__CID_IP__' AND severity<4 AND severity>0 GROUP BY (id_device)",
	'syslog_filters'=>"SELECT * FROM syslog_filters ORDER BY valor",
   'create_syslog_filters'=>"INSERT INTO syslog_filters (valor) VALUES ('__VALOR__')",
   'mod_syslog_filters'=>"UPDATE syslog_filters SET valor='__VALOR__' WHERE id IN (__ID__)",
   'del_syslog_filters'=>"DELETE FROM syslog_filters WHERE id IN (__ID__)",
	'get_search_store_from_task'=>"SELECT id_cfg_task_configured,id_search_store FROM search_store2cfg_task WHERE id_cfg_task_configured IN (__ID_CFG_TASK_CONFIGURED__)",
	'get_search_store_from_view_remote'=>"SELECT id_cfg_view,id_search_store FROM search_store2cfg_views2remote_alerts WHERE id_cfg_view IN (__ID_CFG_VIEW__)",
	'get_search_store_from_view_metric'=>"SELECT id_cfg_view,id_search_store FROM search_store2cfg_views2metrics WHERE id_cfg_view IN (__ID_CFG_VIEW__)",
	'get_num_search_store_from_task'=>"SELECT COUNT(id_search_store) AS cuantos FROM search_store2cfg_task WHERE id_cfg_task_configured IN (__ID_CFG_TASK_CONFIGURED__)",
	'get_num_search_store_from_view_remote'=>"SELECT COUNT(id_search_store) AS cuantos FROM search_store2cfg_views2remote_alerts WHERE id_cfg_view IN (__ID_CFG_VIEW__)",
	'get_num_search_store_from_view_metric'=>"SELECT COUNT(id_search_store) AS cuantos FROM search_store2cfg_views2metrics WHERE id_cfg_view IN (__ID_CFG_VIEW__)",
	'delete_all_search_store_from_task'=>"DELETE FROM search_store2cfg_task WHERE id_cfg_task_configured IN (__ID_CFG_TASK_CONFIGURED__)",
	'delete_all_search_store_from_view_remote'=>"DELETE FROM search_store2cfg_views2remote_alerts WHERE id_cfg_view IN (__ID_CFG_VIEW__)",
	'delete_all_search_store_from_view_metric'=>"DELETE FROM search_store2cfg_views2metrics WHERE id_cfg_view IN (__ID_CFG_VIEW__)",
	'insert_search_store_to_task'=>"INSERT INTO search_store2cfg_task (id_cfg_task_configured,id_search_store) VALUES (__ID_CFG_TASK_CONFIGURED__,__ID_SEARCH_STORE__)",
	'delete_search_store_from_task'=>"DELETE FROM search_store2cfg_task WHERE id_cfg_task_configured=__ID_CFG_TASK_CONFIGURED__ AND id_search_store=__ID_SEARCH_STORE__",
	'delete_search_store_from_view_metric'=>"DELETE FROM search_store2cfg_views2metrics WHERE id_cfg_view=__ID_CFG_VIEW__ AND id_search_store=__ID_SEARCH_STORE__",
	'delete_search_store_from_view_remote'=>"DELETE FROM search_store2cfg_views2remote_alerts WHERE id_cfg_view=__ID_CFG_VIEW__ AND id_search_store=__ID_SEARCH_STORE__",
	'insert_search_store_to_view_remote'=>"INSERT INTO search_store2cfg_views2remote_alerts (id_cfg_view,id_search_store) VALUES (__ID_CFG_VIEW__,__ID_SEARCH_STORE__)",
	'insert_search_store_to_view_metric'=>"INSERT INTO search_store2cfg_views2metrics (id_cfg_view,id_search_store) VALUES (__ID_CFG_VIEW__,__ID_SEARCH_STORE__)",
	'delete_all_device_from_task'=>"DELETE FROM task2device WHERE name='__NAME__' AND type='device'",
	'delete_all_remote_from_view'=>"DELETE FROM cfg_views2remote_alerts WHERE id_cfg_view IN (__ID_CFG_VIEW__)",
	'delete_all_metric_from_view'=>"DELETE FROM cfg_views2metrics WHERE id_cfg_view IN (__ID_CFG_VIEW__)",
	'get_networks'=>"SELECT * FROM cfg_networks ORDER BY network",
   'create_cfg_networks'=>"INSERT INTO cfg_networks (network,descr) VALUES ('__NETWORK__','__DESCR__')",
	'get_networks_by_id'=>"SELECT * FROM cfg_networks WHERE id_cfg_networks IN (__ID_CFG_NETWORKS__)",
   'mod_cfg_networks'=>"UPDATE cfg_networks SET network='__NETWORK__',descr='__DESCR__' WHERE id_cfg_networks IN (__ID_CFG_NETWORKS__)",
   'delete_cfg_networks'=>"DELETE FROM cfg_networks WHERE id_cfg_networks IN (__ID_CFG_NETWORKS__)",
   'update_network_in_devices'=>"UPDATE devices SET network='__NETWORK_NEW__' WHERE network='__NETWORK_OLD__'",



   'cnm_get_view_remote_delete_temp' => "DROP TEMPORARY TABLE IF EXISTS t1,t2,t3",
   'cnm_get_view_remote_create_temp1' => "CREATE TEMPORARY TABLE t2 SELECT count(*) AS num_metricas,id_dev FROM metrics GROUP BY id_dev",
   'cnm_get_view_remote_create_temp2' => "CREATE TEMPORARY TABLE t3 SELECT c.id_dev,a.id_remote_alert,b.descr AS rlabel,b.action,b.type AS rtype FROM cfg_remote_alerts2device a, cfg_remote_alerts b, devices c WHERE a.id_remote_alert=b.id_remote_alert AND a.target=c.ip AND b.type!='cnm'",
	'//cnm_get_view_remote_create_temp3' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,t3.id_remote_alert,0 AS asoc,a.name,a.critic,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.network,a.sysdesc,a.version,a.sysloc,IF(a.mac_vendor='-',a.mac,IF(a.mac='',a.mac_vendor,CONCAT(a.mac_vendor,'<br> ',a.mac))) AS mac,0 AS yellow,0 AS orange,0 AS red,0 AS blue,t3.rlabel,t3.rtype,IFNULL(num_metricas,0) as cuantos__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e,t3) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev LEFT JOIN t2 ON a.id_dev=t2.id_dev WHERE a.id_dev=e.id_dev AND a.id_dev=t3.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__'",
	
	// 'cnm_get_view_remote_create_temp3' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,t3.id_remote_alert,0 AS asoc,a.name,a.critic,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.network,a.sysdesc,a.version,a.sysloc,IF(a.mac_vendor='-',a.mac,IF(a.mac='',a.mac_vendor,CONCAT(a.mac_vendor,'<br> ',a.mac))) AS mac,0 AS yellow,0 AS orange,0 AS red,0 AS blue,t3.rlabel,t3.rtype__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e,t3) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev=e.id_dev AND a.id_dev=t3.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__'",
	'cnm_get_view_remote_create_temp3' => "CREATE TEMPORARY TABLE t1 SELECT DISTINCT(a.id_dev) AS id_dev,t3.id_remote_alert,t3.action,0 AS asoc,a.name,a.critic,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.network,a.sysdesc,a.version,a.sysloc,IF(a.mac_vendor='-',a.mac,IF(a.mac='',a.mac_vendor,CONCAT(a.mac_vendor,'<br> ',a.mac))) AS mac,0 AS yellow,0 AS orange,0 AS red,0 AS blue,t3.rlabel,t3.rtype__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e,t3) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev=e.id_dev AND a.id_dev=t3.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__'",


	'cnm_get_view_remote_create_temp3bis' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,t3.id_remote_alert,0 AS asoc,a.name,a.critic,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.network,a.sysdesc,a.version,a.sysloc,IF(a.mac_vendor='-',a.mac,IF(a.mac='',a.mac_vendor,CONCAT(a.mac_vendor,'<br> ',a.mac))) AS mac,0 AS yellow,0 AS orange,0 AS red,0 AS blue,t3.rlabel,t3.rtype__USER_FIELDS__ FROM (devices a,t3) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev=t3.id_dev",
	// 'cnm_get_view_remote_update'=> "UPDATE t1 SET asoc=1 WHERE id_remote_alert IN (SELECT id_remote_alert FROM cfg_views2remote_alerts WHERE id_cfg_view IN (__ID_CFG_VIEW__))",
	'cnm_get_view_remote_update'=> "UPDATE t1 SET asoc=1 WHERE (id_remote_alert,id_dev) IN (SELECT id_remote_alert,id_dev FROM cfg_views2remote_alerts WHERE id_cfg_view IN (__ID_CFG_VIEW__))",
	'cnm_get_view_remote_update_temp' => "UPDATE t1 SET red=__RED__,orange=__ORANGE__,yellow=__YELLOW__,blue=__BLUE__ WHERE id_dev IN (__ID_DEV__)",
   // 'cnm_get_view_remote_count' => "SELECT COUNT(DISTINCT id_remote_alert) AS cuantos FROM t1 WHERE __CONDITION__",
   'cnm_get_view_remote_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE __CONDITION__",
   'cnm_get_view_remote_lista' => "SELECT * FROM t1 WHERE __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",


	'cnm_get_view_metrics_delete_temp' => "DROP TEMPORARY TABLE IF EXISTS t1,t2,t3",
   'cnm_get_view_metrics_create_temp1' => "CREATE TEMPORARY TABLE t2 SELECT count(*) AS num_metricas,id_dev FROM metrics GROUP BY id_dev",
   'cnm_get_view_metrics_create_temp2' => "CREATE TEMPORARY TABLE t3 SELECT id_dev,id_metric,label AS mlabel,type AS mtype FROM metrics",

   // 'cnm_get_view_metrics_create_temp3' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,t3.id_metric,0 AS asoc,a.name,a.critic,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.network,a.sysdesc,a.version,a.sysloc,IF(a.mac_vendor='-',a.mac,IF(a.mac='',a.mac_vendor,CONCAT(a.mac_vendor,'<br> ',a.mac))) AS mac,0 AS yellow,0 AS orange,0 AS red,0 AS blue,t3.mlabel,t3.mtype__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e,t3) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev=e.id_dev AND a.id_dev=t3.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__'",
   'cnm_get_view_metrics_create_temp3' => "CREATE TEMPORARY TABLE t1 SELECT DISTINCT(a.id_dev) AS id_dev,t3.id_metric,0 AS asoc,a.name,a.critic,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.network,a.sysdesc,a.version,a.sysloc,IF(a.mac_vendor='-',a.mac,IF(a.mac='',a.mac_vendor,CONCAT(a.mac_vendor,'<br> ',a.mac))) AS mac,0 AS yellow,0 AS orange,0 AS red,0 AS blue,t3.mlabel,t3.mtype__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e,t3) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev=e.id_dev AND a.id_dev=t3.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__'",
   'cnm_get_view_metrics_create_temp3bis' => "CREATE TEMPORARY TABLE t1 SELECT a.id_dev,t3.id_metric,0 AS asoc,a.name,a.critic,a.domain,a.ip,a.type,a.xagent_version,a.status,a.sysoid,a.network,a.sysdesc,a.version,a.sysloc,IF(a.mac_vendor='-',a.mac,IF(a.mac='',a.mac_vendor,CONCAT(a.mac_vendor,'<br> ',a.mac))) AS mac,0 AS yellow,0 AS orange,0 AS red,0 AS blue,t3.mlabel,t3.mtype__USER_FIELDS__ FROM (devices a,t3) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev=t3.id_dev",
	'cnm_get_view_metrics_update'=> "UPDATE t1 SET asoc=1 WHERE id_metric IN (SELECT id_metric FROM cfg_views2metrics WHERE id_cfg_view IN (__ID_CFG_VIEW__))",
   'cnm_get_view_metrics_update_temp' => "UPDATE t1 SET red=__RED__,orange=__ORANGE__,yellow=__YELLOW__,blue=__BLUE__ WHERE id_dev IN (__ID_DEV__)",
   'cnm_get_view_metrics_count' => "SELECT COUNT(DISTINCT id_metric) AS cuantos FROM t1 WHERE __CONDITION__",
   'cnm_get_view_metrics_lista' => "SELECT * FROM t1 WHERE __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'cnm_get_devices_layout_get_cuantos' => "SELECT COUNT(id_metric) AS cuantos,id_dev FROM metrics WHERE status=0 GROUP BY id_dev",
	'get_params_from_report'=> "SELECT id_cfg_report2config,subtype_cfg_report,cfg_table,field,value FROM cfg_report2config WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__' AND cfg_table='param'",
	'cnm_get_plugin_auth_all_enable'=>"SELECT * FROM plugin_auth WHERE enable=1",
	'cnm_get_plugin_auth_all'=>"SELECT * FROM plugin_auth",
	'enable_plugin_auth'=>"UPDATE plugin_auth SET enable=1 WHERE id_plugin_auth IN (__ID_PLUGIN_AUTH__)",
	'disable_plugin_auth'=>"UPDATE plugin_auth SET enable=0 WHERE id_plugin_auth IN (__ID_PLUGIN_AUTH__)",
	'get_plugin_auth_by_type'=>"SELECT * FROM plugin_auth WHERE type='__TYPE__'",
	'get_all_halerts_from_devices_time'=>"SELECT *,FROM_UNIXTIME(date) AS human_time FROM alerts_store WHERE __CONDITION__ ORDER BY id_device,date",
	'get_all_alerts_from_devices_time'=>"SELECT *,FROM_UNIXTIME(date) AS human_time FROM alerts WHERE __CONDITION__ ORDER BY id_device,date",
	'get_all_metrics_from_devices_monitor'=>"SELECT * FROM metrics WHERE __CONDITION__",
	'get_count_qactions_by_id_alert'=>"SELECT COUNT(*) AS cuantos FROM qactions WHERE (descr like '%EMAIL%' OR descr like '%SMS%') AND id_alert IN (__ID_ALERT__)",
	'get_all_metrics_from_condition'=>"SELECT * FROM metrics WHERE __CONDITION__",

	'get_all_view_alerts_store_from_time'=>"SELECT a.*,FROM_UNIXTIME(a.date) AS human_time,b.descr,b.rule_int FROM view_alerts_store a,cfg_viewsruleset b WHERE a.id_cfg_viewsruleset=b.id_cfg_viewsruleset __CONDITION__ ORDER BY date",
	'get_all_view_alerts_from_time'=>"SELECT a.*,FROM_UNIXTIME(a.date) AS human_time,b.descr,b.rule_int FROM view_alerts a, cfg_viewsruleset b WHERE a.id_cfg_viewsruleset=b.id_cfg_viewsruleset __CONDITION__ ORDER BY date",
	// OTRS
	'otrs_all_severity'=>"SELECT * FROM extra_otrs_severity ORDER BY descr",
	'otrs_all_user'=>"SELECT * FROM cfg_users WHERE id_user!=1",
	'otrs_all_type'=>"SELECT * FROM extra_otrs_type ORDER BY descr",
	'otrs_all_element'=>"SELECT * FROM extra_otrs_element WHERE ticket_type='__TICKET_TYPE__' ORDER BY descr",
   'otrs_ticket_info'=>"SELECT d.name as hostname, t.event_data as causa_evento, t.descr,t.id_ticket FROM ticket t, devices d WHERE d.id_dev=t.id_dev AND t.id_alert=__ID_ALERT__",
	'otrs_get_type'=>"SELECT * FROM extra_otrs_type WHERE id_otrs_type IN (__ID_OTRS_TYPE__)",
	'otrs_get_element'=>"SELECT * FROM extra_otrs_element WHERE id_otrs_element IN (__ID_OTRS_ELEMENT__)",
	'otrs_get_severity'=>"SELECT * FROM extra_otrs_severity WHERE id_otrs_severity IN (__ID_OTRS_SEVERITY__)",

   'otrs_insert_ticket'=>"UPDATE ticket SET ref='__TICKET__',descr='__DESCR__' WHERE id_alert =__ID_ALERT__",
   'otrs_extra_otrs_ticket_info'=>"SELECT * FROM extra_otrs_ticket WHERE id_ticket=__ID_TICKET__",

	'otrs_insert_extra_otrs_ticket'=>"INSERT INTO extra_otrs_ticket (id_ticket,type,category,element,severity,user,global,ref,ref_id) VALUES (__ID_TICKET__,__TYPE__,'__CATEGORY__',__ELEMENT__,__SEVERITY__,__USER__,__GLOBAL__,__REF__,__REF_ID__)",
	'otrs_update_extra_otrs_ticket'=>"UPDATE extra_otrs_ticket SET type=__TYPE__,category='__CATEGORY__',element=__ELEMENT__,severity=__SEVERITY__,user=__USER__,global=__GLOBAL__,ref=__REF__,ref_id=__REF_ID__ WHERE id_otrs_ticket=__ID_OTRS_TICKET__",
   'otrs_info_ticket'=>"SELECT a.id_ticket,b.type,b.category,b.element,b.severity,b.user,b.global,b.ref,b.ref_id FROM ticket a,extra_otrs_ticket b WHERE a.id_alert=__ID_ALERT__ AND a.id_ticket=b.id_ticket",

   'otrs_get_user_count'=>"SELECT count(*) AS cuantos,id FROM otrs.users WHERE login='__LOGIN__'",
   'otrs_update_user1' => "UPDATE otrs.users SET first_name='__FIRSTNAME__',last_name='__LASTNAME__' WHERE id=__ID__",
   'otrs_update_user2' => "UPDATE otrs.user_preferences SET preferences_value='__EMAIL__' WHERE user_id=__ID__ AND preferences_key='UserEmail'",
	'otrs_set_user_invalid' => "UPDATE otrs.users SET valid_id=2 WHERE id=__ID__",

	'clear_search_store2cfg_views2metrics1'=>"DELETE FROM search_store2cfg_views2metrics WHERE id_cfg_view IN (__ID_CFG_VIEW__)",
	'clear_search_store2cfg_views2remote_alerts1'=>"DELETE FROM search_store2cfg_views2remote_alerts WHERE id_cfg_view IN (__ID_CFG_VIEW__)",

	'get_all_metrics_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
	// 'get_all_metrics_create_temp1'=>"CREATE TEMPORARY TABLE t1(SELECT a.id_metric AS id,a.id_dev AS deviceid,a.type,a.label AS name,a.items,b.id_alert_type AS monitorid,b.cause AS monitorname,b.expr,b.severity,c.name AS devicename,c.ip AS deviceip FROM (metrics a,devices c) LEFT JOIN alert_type b ON a.watch=b.monitor WHERE a.id_dev=c.id_dev)",
	// 'get_all_metrics_create_temp1'=>"CREATE TEMPORARY TABLE t1(SELECT a.id_metric AS id,a.id_dev AS deviceid,a.type,a.label AS name,a.items,b.id_alert_type AS monitorid,b.cause AS monitorname,b.expr,b.severity,c.name AS devicename,c.ip AS deviceip FROM (metrics a,devices c,cfg_devices2organizational_profile e) LEFT JOIN alert_type b ON a.watch=b.monitor WHERE a.id_dev=c.id_dev AND a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__')",
	// 'get_all_metrics_create_temp1'=>"CREATE TEMPORARY TABLE t1(SELECT a.id_metric AS id,DISTINCT(a.id_dev) AS deviceid,a.type,a.label AS name,a.items,b.id_alert_type AS monitorid,b.cause AS monitorname,b.expr,b.severity,c.name AS devicename,c.ip AS deviceip FROM (metrics a,devices c,cfg_devices2organizational_profile e) LEFT JOIN alert_type b ON a.watch=b.monitor WHERE a.id_dev=c.id_dev AND a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__')",
	// 'get_all_metrics_create_temp1'=>"CREATE TEMPORARY TABLE t1(SELECT a.id_metric AS id,a.id_dev AS deviceid,a.type,a.label AS name,a.items,b.id_alert_type AS monitorid,b.cause AS monitorname,b.expr,b.severity,c.name AS devicename,c.ip AS deviceip,c.domain AS devicedomain,c.status as devicestatus,c.type as devicetype FROM (metrics a,devices c,cfg_devices2organizational_profile e) LEFT JOIN alert_type b ON a.watch=b.monitor WHERE a.id_dev=c.id_dev AND a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__')",
	'get_all_metrics_create_temp1'=>"CREATE TEMPORARY TABLE t1(SELECT DISTINCT(a.id_metric) AS metricid,a.label AS metricname,a.type AS metrictype,a.items AS metricitems,a.status AS metricstatus,a.name AS metricmname,a.subtype AS metricsubtype,,  REPLACE(SUBSTRING(SUBSTRING_INDEX(a.top_value,'|', 1),LENGTH(SUBSTRING_INDEX(a.top_value,'|',0)) + 1),'|', '') as metriclevel1, REPLACE(SUBSTRING(SUBSTRING_INDEX(a.top_value,'|', 2),LENGTH(SUBSTRING_INDEX(a.top_value,'|',1)) + 1),'|', '') as metriclevel2,        c.name AS devicename,c.domain AS devicedomain,c.status AS devicestatus,c.type AS devicetype,c.id_dev AS deviceid,c.ip AS deviceip,b.id_alert_type AS monitorid,b.cause AS monitorname,b.expr AS monitorsevred,b.expr AS monitorsevorange,b.expr AS monitorsevyellow,b.expr,b.severity FROM (metrics a,devices c,cfg_devices2organizational_profile e) LEFT JOIN alert_type b ON a.watch=b.monitor WHERE a.id_dev=c.id_dev AND a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__')",
	'get_all_metrics_create_temp1_update_all_severity'=>"UPDATE t1 SET monitorsevred='__MONITORSEVRED__', monitorsevorange='__MONITORSEVORANGE__', monitorsevyellow='__MONITORSEVYELLOW__' WHERE metricid IN (__METRICID__)",
	'get_all_metrics_create_lista_all'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__",
	'get_all_metrics_create_lista'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
	'get_all_metrics_create_count'=>"SELECT COUNT(DISTINCT id) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

	'get_view_metrics_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
   'get_view_metrics_create_temp1'=>"CREATE TEMPORARY TABLE t1(SELECT a.id_metric AS metricid,a.label AS metricname,a.type AS metrictype,a.items AS metricitems,a.status AS metricstatus,a.name AS metricmname,a.subtype AS metricsubtype,  REPLACE(SUBSTRING(SUBSTRING_INDEX(a.top_value,'|', 1),LENGTH(SUBSTRING_INDEX(a.top_value,'|',0)) + 1),'|', '') as metriclevel1, REPLACE(SUBSTRING(SUBSTRING_INDEX(a.top_value,'|', 2),LENGTH(SUBSTRING_INDEX(a.top_value,'|',1)) + 1),'|', '') as metriclevel2,      c.name AS devicename,c.domain AS devicedomain,c.status AS devicestatus,c.type AS devicetype,c.id_dev AS deviceid,c.ip AS deviceip,b.id_alert_type AS monitorid,b.cause AS monitorname,b.expr AS monitorsevred,b.expr AS monitorsevorange,b.expr AS monitorsevyellow,e.name AS viewname,e.id_cfg_view AS viewid,e.type as viewtype,b.expr,b.severity FROM (metrics a,devices c,cfg_views2metrics d,cfg_views e) LEFT JOIN alert_type b ON a.watch=b.monitor WHERE d.id_cfg_view IN (__ID_CFG_VIEW__) AND d.id_metric=a.id_metric AND a.id_dev=c.id_dev AND d.id_cfg_view=e.id_cfg_view AND e.cid='__CID__' AND e.cid_ip='__CID_IP__')",
   'get_all_view_metrics_create_temp1'=>"CREATE TEMPORARY TABLE t1(SELECT a.id_metric AS metricid,a.label AS metricname,a.type AS metrictype,a.items AS metricitems,a.status AS metricstatus,a.name AS metricmname,a.subtype AS metricsubtype,c.name AS devicename,c.domain AS devicedomain,c.status AS devicestatus,c.type AS devicetype,c.id_dev AS deviceid,c.ip AS deviceip,b.id_alert_type AS monitorid,b.cause AS monitorname,b.expr AS monitorsevred,b.expr AS monitorsevorange,b.expr AS monitorsevyellow,e.name AS viewname,e.id_cfg_view AS viewid,e.type as viewtype,b.expr,b.severity FROM (metrics a,devices c,cfg_views2metrics d,cfg_views e) LEFT JOIN alert_type b ON a.watch=b.monitor WHERE d.id_metric=a.id_metric AND a.id_dev=c.id_dev AND d.id_cfg_view=e.id_cfg_view AND e.cid='__CID__' AND e.cid_ip='__CID_IP__')",
	'get_view_metrics_create_lista_all'=>"SELECT * FROM t1",
	'get_view_metrics_create_temp1_update_all_severity'=>"UPDATE t1 SET monitorsevred='__MONITORSEVRED__', monitorsevorange='__MONITORSEVORANGE__', monitorsevyellow='__MONITORSEVYELLOW__' WHERE metricid IN (__METRICID__)",
   'get_view_metrics_create_lista'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'get_view_metrics_create_count'=>"SELECT COUNT(DISTINCT id) AS cuantos FROM t1 WHERE ''='' __CONDITION__",


	'get_view_remotealerts_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
	'get_view_remotealerts_create_temp1' => "CREATE TEMPORARY TABLE t1 SELECT a.id_remote_alert AS id,c.type,c.descr AS name,b.ip as deviceip,b.id_dev as deviceid FROM (cfg_views2remote_alerts a,devices b,cfg_remote_alerts c) WHERE a.id_cfg_view IN (__ID_CFG_VIEW__) AND a.id_dev=b.id_dev AND a.id_remote_alert=c.id_remote_alert",
   'get_view_remotealerts_create_lista'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'get_view_remotealerts_create_count'=>"SELECT COUNT(DISTINCT id) AS cuantos FROM t1 WHERE ''='' __CONDITION__",



   'get_tickets_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
   // 'get_tickets_create_temp1'=>"CREATE TEMPORARY TABLE t1(SELECT a.id_ticket, a.id_alert,c.name AS category,b.name AS devicename,b.ip AS deviceip,a.descr,a.ref,a.login_name FROM (ticket a,devices b,note_types c) WHERE a.id_dev=b.id_dev AND a.ticket_type=c.id_note_type)",
   // 'get_tickets_create_temp1'=>"CREATE TEMPORARY TABLE t1(SELECT a.id_ticket, a.id_alert,c.name AS category,b.name AS devicename,b.ip AS deviceip,a.descr,a.ref,a.login_name FROM (ticket a,devices b,note_types c,cfg_devices2organizational_profile e) WHERE a.id_dev=b.id_dev AND a.ticket_type=c.id_note_type AND b.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__')",
   'get_tickets_create_temp1'=>"CREATE TEMPORARY TABLE t1(SELECT DISTINCT(b.id_dev) AS id_dev,a.id_ticket, a.id_alert,c.name AS category,b.name AS devicename,b.domain AS devicedomain,b.ip AS deviceip,a.descr,a.ref,a.login_name,'alerts' AS type,d.type AS alerttype,d.counter AS alertcounter,d.date_last AS alertdatelast_timestamp,FROM_UNIXTIME(d.date_last) AS alertdatelast_human,d.date AS alertdatefirst_timestamp,FROM_UNIXTIME(d.date) AS alertdatefirst_human,d.ack AS alertack,d.severity AS alertseverity,d.cause AS alertcause FROM (ticket a,devices b,note_types c,alerts d,cfg_devices2organizational_profile e) WHERE a.id_dev=b.id_dev AND a.id_alert=d.id_alert AND a.ticket_type=c.id_note_type AND b.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__') UNION (SELECT DISTINCT(b.id_dev) AS id_dev,a.id_ticket, a.id_alert,c.name AS category,b.name AS devicename,b.domain AS devicedomain,b.ip AS deviceip,a.descr,a.ref,a.login_name,'store' AS type,d.type AS alerttype,d.counter AS alertcounter,d.date_store AS alertdatelast_timestamp,FROM_UNIXTIME(d.date_store) AS alertdatelast_human,d.date AS alertdatefirst_timestamp,FROM_UNIXTIME(d.date) AS alertdatefirst_human,d.ack AS alertack,d.severity AS alertseverity,d.cause AS alertcause FROM (ticket a,devices b,note_types c,alerts_store d,cfg_devices2organizational_profile e) WHERE a.id_dev=b.id_dev AND a.id_alert=d.id_alert AND a.ticket_type=c.id_note_type AND b.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__')",

   'get_tickets_create_temp2'=>"UPDATE t1 SET type='alerts' WHERE id_alert IN (SELECT id_alert FROM alerts)",
   'get_tickets_create_lista'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'get_tickets_create_count'=>"SELECT COUNT(DISTINCT id) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

	'get_helpdesk_active'=>"SELECT * FROM plugin_helpdesk WHERE enable=1",
	'get_helpdesk_all'=>"SELECT * FROM plugin_helpdesk",
	'update_plugin_helpdesk'=>"UPDATE plugin_helpdesk SET enable=__ENABLE__ WHERE id_plugin_helpdesk IN (__ID_PLUGIN_HELPDESK__)",


	'get_view_graph_alert_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
	'get_view_graph_alert_create_temp1'=>"CREATE TEMPORARY TABLE t1 (SELECT a.severity,a.type,a.date,FROM_UNIXTIME(a.date) AS date_human,a.name,a.ip,c.name AS view,a.cause,a.label,a.counter,a.event_data,a.watch FROM alerts a, cfg_views2metrics b, cfg_views c WHERE a.counter>1 AND a.type NOT IN ('snmp-trap','syslog','email','api') AND a.id_metric=b.id_metric AND a.id_device=b.id_device AND b.id_cfg_view=c.id_cfg_view AND c.id_cfg_view IN (__ID_CFG_VIEW__) AND c.cid='__CID__' AND c.cid_ip='__CID_IP__') UNION (SELECT a.severity,a.type,a.date,FROM_UNIXTIME(a.date) AS date_human,a.name,a.ip,c.name AS view,a.cause,a.label,a.counter,a.event_data,a.watch FROM alerts a, cfg_views2metrics b, cfg_views c WHERE a.counter>1 AND a.mname IN ('mon_snmp','mon_xagent') AND a.id_device=b.id_device AND b.id_cfg_view=c.id_cfg_view AND c.id_cfg_view IN (__ID_CFG_VIEW__) AND c.cid='__CID__' AND c.cid_ip='__CID_IP__') UNION (SELECT a.severity,a.type,a.date,FROM_UNIXTIME(a.date) AS date_human,a.name,a.ip,c.name AS view,a.cause,a.label,a.counter,a.event_data,a.watch FROM alerts a, cfg_views2remote_alerts b, cfg_views c WHERE a.type IN ('snmp-trap','syslog','email','api') AND a.id_metric=b.id_remote_alert AND a.id_device=b.id_dev AND b.id_cfg_view=c.id_cfg_view AND c.id_cfg_view IN (__ID_CFG_VIEW__) AND c.cid='__CID__' AND c.cid_ip='__CID_IP__')",
	'get_view_graph_alert_create_lista'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
	'get_view_graph_alert_create_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",


   'get_view_graph_halert_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
   'get_view_graph_halert_create_temp1'=>"CREATE TEMPORARY TABLE t1 (SELECT a.severity,a.type,a.date,FROM_UNIXTIME(a.date) AS date_human,a.name,a.ip,c.name AS view,a.cause,a.label,a.duration,a.event_data,a.watch FROM alerts_store a, cfg_views2metrics b, cfg_views c WHERE a.type NOT IN ('snmp-trap','syslog','email','api') AND a.id_metric=b.id_metric AND a.id_device=b.id_device AND b.id_cfg_view=c.id_cfg_view AND c.id_cfg_view IN (__ID_CFG_VIEW__) AND c.cid='__CID__' AND c.cid_ip='__CID_IP__') UNION (SELECT a.severity,a.type,a.date,FROM_UNIXTIME(a.date) AS date_human,a.name,a.ip,c.name AS view,a.cause,a.label,a.duration,a.event_data,a.watch FROM alerts_store a, cfg_views2metrics b, cfg_views c WHERE a.mname IN ('mon_snmp','mon_xagent') AND a.id_device=b.id_device AND b.id_cfg_view=c.id_cfg_view AND c.id_cfg_view IN (__ID_CFG_VIEW__) AND c.cid='__CID__' AND c.cid_ip='__CID_IP__') UNION (SELECT a.severity,a.type,a.date,FROM_UNIXTIME(a.date) AS date_human,a.name,a.ip,c.name AS view,a.cause,a.label,a.duration,a.event_data,a.watch FROM alerts_store a, cfg_views2remote_alerts b, cfg_views c, cfg_remote_alerts d WHERE a.type IN ('snmp-trap','syslog','email','api') AND a.id_metric=b.id_remote_alert AND a.id_device=b.id_dev AND b.id_cfg_view=c.id_cfg_view AND b.id_remote_alert=d.id_remote_alert AND d.action='SET' AND c.id_cfg_view IN (__ID_CFG_VIEW__) AND c.cid='__CID__' AND c.cid_ip='__CID_IP__')",
   'get_view_graph_halert_create_lista'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'get_view_graph_halert_create_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",


	'get_device_graph_alert_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
   'get_device_graph_alert_create_temp1'=>"CREATE TEMPORARY TABLE t1 (SELECT a.severity,a.type,a.date,FROM_UNIXTIME(a.date) AS date_human,a.name,a.ip,a.cause,a.label,a.counter,a.event_data,a.watch FROM alerts a WHERE a.counter>1 AND a.type NOT IN ('snmp-trap','syslog','email','api') AND a.id_device IN (__ID_DEV__)) UNION (SELECT a.severity,a.type,a.date,FROM_UNIXTIME(a.date) AS date_human,a.name,a.ip,a.cause,a.label,a.counter,a.event_data,a.watch FROM alerts a WHERE a.counter>1 AND a.mname IN ('mon_snmp','mon_xagent') AND a.id_device IN (__ID_DEV__)) UNION (SELECT a.severity,a.type,a.date,FROM_UNIXTIME(a.date) AS date_human,a.name,a.ip,a.cause,a.label,a.counter,a.event_data,a.watch FROM alerts a WHERE a.type IN ('snmp-trap','syslog','email','api') AND a.id_device IN (__ID_DEV__))",
   'get_device_graph_alert_create_lista'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'get_device_graph_alert_create_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",


	'create_event_api'=>"INSERT INTO events (name,domain,ip,date,code,proccess,msg,msg_custom,evkey,id_dev) VALUES ('__NAME__','__DOMAIN__','__IP__',__DATE__,__CODE__,'__PROCCESS__','__MSG__','__MSG_CUSTOM__','__EVKEY__',__ID_DEV__)",
	'get_all_metrics_api'=>"SELECT id_metric FROM metrics",
   'insert_device_custom_data'=>"INSERT INTO devices_custom_data (id_dev) VALUES (__ID_DEV__)",
   'select_id_custom_type_by_descr'=>"SELECT id FROM devices_custom_types WHERE descr='__DESCR__'",
   'update_device_custom_data'=>"UPDATE devices_custom_data SET __COL_ID__='__COL_VALUE__' WHERE id_dev IN (__ID_DEV__)",
	'mod_api_pass_credential' => "UPDATE credentials SET pwd='__PWD__' WHERE type='api' AND user='__USER__'",

	'get_monitor_by_subtype'=>"SELECT * FROM alert_type WHERE SUBTYPE='__SUBTYPE__'",
	'get_devices_by_idtype'=>"SELECT a.* FROM devices a,cfg_host_types b WHERE a.type=b.descr AND b.id_host_type IN (__ID_HOST_TYPE__) ORDER BY a.name",
	'get_count_devices_by_type'=>"SELECT COUNT(*) AS count FROM devices WHERE type='__TYPE__'",
	'get_count_all_devices'=>"SELECT COUNT(*) AS count FROM devices",
	'get_all_devices' => "SELECT * FROM devices ORDER BY name",
	'get_all_devices_organizational_profile' => "SELECT a.* FROM (devices a,cfg_devices2organizational_profile b) WHERE a.id_dev=b.id_dev AND b.id_cfg_op IN (__ID_CFG_OP__) AND b.cid='__CID__'  ORDER BY a.name",
	'get_count_all_devices_organizational_profile'=>"SELECT COUNT(a.*) AS count FROM (devices a,cfg_devices2organizational_profile b) WHERE a.id_dev=b.id_dev AND b.id_cfg_op IN (__ID_CFG_OP__) AND b.cid='__CID__'",
	'get_devices_by_idtype_organizational_profile'=>"SELECT a.* FROM devices a,cfg_host_types b,cfg_devices2organizational_profile c WHERE a.type=b.descr AND b.id_host_type IN (__ID_HOST_TYPE__) AND a.id_dev=c.id_dev AND c.id_cfg_op IN (__ID_CFG_OP__) AND c.cid='__CID__' ORDER BY a.name",
	'get_mobile_report_from_user'=>"SELECT b.subtype_cfg_report FROM cfg_user2report a,cfg_report b WHERE a.id_cfg_report=b.id_cfg_report AND b.mobile=1 AND a.id_user='__ID_USER__'",
	'info_xagent_metric'=>'SELECT b.* from metrics a, cfg_monitor_agent b WHERE a.subtype=b.subtype AND a.id_metric IN (__ID_METRIC__)',

	'alerts_from_remotealert' => 'SELECT * FROM alerts WHERE (type="snmp-trap" or type="syslog" or type="email" or type="api") AND id_alert_type IN (__ID_ALERT_TYPE__)',

	// ---------------------------------------------
   'api_get_devices_layout_delete_temp' => "DROP TEMPORARY TABLE IF EXISTS t1,t2",
   'api_get_devices_layout_create_temp1' => "CREATE TEMPORARY TABLE t2 SELECT count(*) AS num_metricas,id_dev FROM metrics GROUP BY id_dev",
   'api_get_devices_layout_create_temp2' => "CREATE TEMPORARY TABLE t1 SELECT DISTINCT(a.id_dev) AS id,GROUP_CONCAT(f.descr) AS profile,a.name,a.sysloc AS snmpsyslocation,a.switch,a.sysoid AS snmpsysclass,a.critic,a.domain,a.ip,a.type,a.xagent_version AS xagentversion,a.status,a.sysoid AS snmpsysoid,a.network,a.sysdesc AS snmpsysdesc,a.geodata AS geo,a.correlated_by AS correlated,a.community AS snmpcommunity,a.version AS snmpversion,a.entity,a.sysloc,a.mac,a.mac_vendor AS macvendor,0 AS yellowalerts,0 AS orangealerts,0 AS redalerts,0 AS bluealerts,IFNULL(num_metricas,0) as metrics__USER_FIELDS__ FROM (devices a,cfg_devices2organizational_profile e,cfg_organizational_profile f) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev LEFT JOIN t2 ON a.id_dev=t2.id_dev WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__' AND e.id_cfg_op IN (__PROFILE__) AND e.id_cfg_op=f.id_cfg_op GROUP BY id",
   'api_get_devices_layout_update_temp' => "UPDATE t1 SET redalerts=__REDALERTS__,orangealerts=__ORANGEALERTS__,yellowalerts=__YELLOWALERTS__,bluealerts=__BLUEALERTS__ WHERE id IN (__ID_DEV__)",
   'api_get_devices_layout_lista' => "SELECT __OUTPUT_FIELDS__ FROM t1 WHERE __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'api_get_organizational_profile_all_devices' => "SELECT id_dev, descr FROM cfg_organizational_profile c, cfg_devices2organizational_profile d WHERE c.id_cfg_op=d.id_cfg_op",
	// ---------------------------------------------
   'api_get_alerts_store_layout_delete_temp' => "DROP TEMPORARY TABLE IF EXISTS t1",
   'api_get_alerts_store_layout_create_temp' => "CREATE TEMPORARY TABLE t1 SELECT DISTINCT(b.id_alert) AS id,GROUP_CONCAT(f.descr) AS profile,b.ack,b.id_ticket,b.severity,a.critic,b.type,b.date,a.name,a.domain,a.ip,b.label,b.duration,(b.event_data) AS event,b.cause__USER_FIELDS__ FROM (devices a,alerts_store b,cfg_devices2organizational_profile e,cfg_organizational_profile f) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev=b.id_device AND a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__' AND e.id_cfg_op IN (__PROFILE__) AND e.id_cfg_op=f.id_cfg_op GROUP BY id",
   'api_get_alerts_store_layout_lista' => "SELECT __OUTPUT_FIELDS__ FROM t1 WHERE __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
	// ---------------------------------------------
   'api_get_alerts_layout_delete_temp' => "DROP TEMPORARY TABLE IF EXISTS t1",
   'api_get_alerts_layout_create_temp' => "CREATE TEMPORARY TABLE t1 SELECT DISTINCT(b.id_alert) AS id,GROUP_CONCAT(f.descr) AS profile,b.ack,b.id_ticket,b.severity,a.critic,b.type,b.date,a.name,a.domain,a.ip,b.label,FROM_UNIXTIME(b.date_last) AS lastupdate,b.counter,(b.event_data) AS event,b.cause__USER_FIELDS__ FROM (devices a,alerts b,cfg_devices2organizational_profile e,cfg_organizational_profile f) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev WHERE a.id_dev=b.id_device AND a.id_dev=e.id_dev AND e.id_cfg_op IN (__ID_CFG_OP__) AND e.cid='__CID__' AND e.id_cfg_op IN (__PROFILE__) AND e.id_cfg_op=f.id_cfg_op GROUP BY id",
   'api_get_alerts_layout_lista' => "SELECT __OUTPUT_FIELDS__ FROM t1 WHERE __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
	// ---------------------------------------------
   'api_get_users_delete_temp' => "DROP TEMPORARY TABLE IF EXISTS t1",
   // 'api_get_users_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_user AS id,a.login_name AS login,a.descr,a.timeout,a.firstname,a.lastname,a.email,a.language,b.name AS role FROM cfg_users a,cfg_operational_profile b WHERE a.perfil=b.id_operational_profile)",
   'api_get_users_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_user AS id,a.login_name AS login,a.descr,a.timeout,a.firstname,a.lastname,a.email,a.language,b.name AS role FROM cfg_users a,cfg_operational_profile b WHERE a.perfil=b.id_operational_profile AND a.id_user IN (__ID_USER__))",
	'get_users_from_organizational_profile'=>'SELECT * FROM cfg_organizational_profile WHERE id_cfg_op IN (__ID_CFG_OP__)',
   'api_get_users_lista' => "SELECT __OUTPUT_FIELDS__ FROM t1 WHERE __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
	// ---------------------------------------------

	// 'get_cfg_inside_correlation_rules'=>"SELECT * FROM cfg_inside_correlation_rules",
	'get_cfg_inside_correlation_rules'=>"SELECT a.*,COUNT(DISTINCT b.id_dev) AS cuantos FROM cfg_inside_correlation_rules a LEFT JOIN devices b ON a.rule_subtype=b.rule_subtype GROUP BY a.rule_subtype",
	'get_devices_by_rule_subtype'=>"SELECT id_dev FROM devices WHERE rule_subtype='__RULE_SUBTYPE__'",
	'update_device_rule_subtype'=>"UPDATE devices SET rule_subtype='__RULE_SUBTYPE__' WHERE id_dev IN (__ID_DEV__)",

	// ---------------------------------------------
	'get_all_correlate_metrics_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1,t2",
	'get_all_correlate_metrics_create_temp1'=>"CREATE TEMPORARY TABLE t2(SELECT id_dev,mname,COUNT(DISTINCT id_dev_correlated) AS cuantos FROM cfg_outside_correlation_rules GROUP BY id_dev,mname)",
	'get_all_correlate_metrics_create_temp2'=>"CREATE TEMPORARY TABLE t1(SELECT a.watch,a.subtype,a.id_dev,a.name AS mname,a.correlate,a.label,a.id_metric,a.type,b.status AS device_status,d.severity,ifnull(d.cause,'-')as monitor,ifnull(d.id_alert_type,'') AS id_alert_type,b.name AS device_name,b.ip AS device_ip,b.domain AS device_domain,IFNULL(t2.cuantos,0) AS cuantos FROM (metrics a,devices b) LEFT JOIN alert_type d ON a.watch=d.monitor LEFT JOIN t2 ON a.name=t2.mname AND a.id_dev=t2.id_dev WHERE a.id_dev=b.id_dev AND a.status=0 AND b.status=0 AND a.correlate=1)",
	'get_all_correlate_metrics_lista'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
	'get_all_correlate_metrics_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

	'get_all_correlate_metrics_alert_type'=>"SELECT b.id_alert_type,b.cause,b.monitor,b.severity FROM metrics a,alert_type b WHERE a.correlate=1 AND a.watch=b.monitor",
	// ---------------------------------------------
	'insert_cfg_outside_correlation_rules'=>"INSERT IGNORE INTO cfg_outside_correlation_rules (mname,id_dev,id_dev_correlated) VALUES ('__MNAME__',__ID_DEV__,__ID_DEV_CORRELATED__)",
	'delete_cfg_outside_correlation_rules'=>"DELETE FROM cfg_outside_correlation_rules WHERE mname='__MNAME__' AND id_dev=__ID_DEV__ AND id_dev_correlated IN (__ID_DEV_CORRELATED__)",
	'get_cfg_outside_correlation_rules_devices_correlated'=>"SELECT id_dev_correlated FROM cfg_outside_correlation_rules WHERE mname='__MNAME__' AND id_dev=__ID_DEV__",
	'get_correlate_metrics_count'=>"SELECT COUNT(DISTINCT id_dev_correlated) AS cuantos FROM cfg_outside_correlation_rules WHERE id_dev=__ID_DEV__ AND mname='__MNAME__'",
	'get_all_cfg_outside_correlation_rules'=>"SELECT a.id_dev,a.id_dev_correlated,b.name,c.name AS name_correlated FROM cfg_outside_correlation_rules a LEFT JOIN devices b ON a.id_dev=b.id_dev LEFT JOIN devices c ON a.id_dev_correlated=c.id_dev",

	'get_all_cfg_device_wsize'=>"SELECT * FROM cfg_device_wsize ORDER BY wsize",
	'get_cfg_device_wsize_by_wsize'=>"SELECT * FROM cfg_device_wsize WHERE wsize IN (__WSIZE__)",

	'get_device_tech_group'=>"SELECT apptype FROM cfg_apptype2device WHERE id_dev IN (__ID_DEV__)",
	'insert_device_tech_group'=>"INSERT INTO cfg_apptype2device (id_dev,apptype) VALUES (__ID_DEV__,'__APPTYPE__')",
	'clear_device_tech_group'=>"DELETE FROM cfg_apptype2device WHERE id_dev IN (__ID_DEV__)",

	'get_docu_from_device' => "SELECT * FROM tips WHERE tip_type='id_dev' AND id_ref IN (__ID_REF__) ORDER BY tip_class desc LIMIT 1",

   // ---------------------------------------------
	'get_all_threshold_metrics_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
	'get_all_threshold_metrics_create_temp1'=>"CREATE TEMPORARY TABLE t1(SELECT a.id_metric,a.label,a.id_dev,a.type,b.name AS device_name,b.ip AS device_ip,b.domain AS device_domain,a.top_value,a.vlabel FROM metrics a,devices b WHERE a.id_dev=b.id_dev AND a.status=0 AND b.status=0 AND mtype!='STD_SOLID')",
	'get_all_threshold_metrics_lista'=>"SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'get_all_threshold_metrics_count'=>"SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

	'update_top_value_metric' => "UPDATE metrics SET top_value='__TOP_VALUE__' WHERE id_metric IN (__ID_METRIC__)",

	'get_metric_info' => "SELECT * FROM metrics WHERE id_metric IN (__ID_METRIC__)",

	// ---------------------------------------------
   'all_asset_types'=>"SELECT hash_asset_type,id_asset_type,descr FROM assets_types ORDER BY descr",
   'asset_types'=>"SELECT id_asset_type,hash_asset_type,descr,available_status,available_owner,manage,icon FROM assets_types WHERE id_asset_type!=0 ORDER BY descr",
   'asset_types_by_manage'=>"SELECT id_asset_type,hash_asset_type,descr,available_status,available_owner,manage,icon FROM assets_types WHERE id_asset_type!=0 AND manage IN (__MANAGE__) ORDER BY descr",
   'new_asset_type'=>"INSERT INTO assets_types (descr,available_status,available_owner,hash_asset_type,manage,id_host_type) VALUES ('__DESCR__','__AVAILABLE_STATUS__','__AVAILABLE_OWNER__','__HASH_ASSET_TYPE__','__MANAGE__','__ID_HOST_TYPE__')",
   'mod_asset_type_descr'=>"UPDATE assets_types SET descr='__DESCR__' WHERE hash_asset_type='__HASH_ASSET_TYPE__'",
   'mod_asset_type_available_status'=>"UPDATE assets_types SET available_status='__AVAILABLE_STATUS__' WHERE hash_asset_type='__HASH_ASSET_TYPE__'",
   'mod_asset_type_available_owner'=>"UPDATE assets_types SET available_owner='__AVAILABLE_OWNER__' WHERE hash_asset_type='__HASH_ASSET_TYPE__'",
	'del_asset_type_1' => "DELETE FROM assets_types WHERE hash_asset_type='__HASH_ASSET_TYPE__'",
	'del_asset_type_2' => "UPDATE assets SET hash_asset_type='' WHERE hash_asset_type='__HASH_ASSET_TYPE__'",
	'del_asset_type_3' => "DELETE FROM assets_subtypes WHERE hash_asset_type='__HASH_ASSET_TYPE__'",
	'del_asset_type_4' => "DELETE FROM assets_custom_data WHERE hash_asset_custom_field IN (SELECT hash_asset_custom_field FROM asset_custom_field WHERE hash_asset_type='__HASH_ASSET_TYPE__')",
	'del_asset_type_5' => "DELETE FROM assets_custom_field WHERE hash_asset_type='__HASH_ASSET_TYPE__'",
	'get_asset_custom_fields_from_type'=> "SELECT * FROM assets_custom_field WHERE hash_asset_type='__HASH_ASSET_TYPE__' ORDER BY descr",
	'new_asset_custom_field' => "INSERT INTO assets_custom_field (descr,tipo,hash_asset_type,hash_asset_custom_field) VALUES ('__DESCR__',__TIPO__,'__HASH_ASSET_TYPE__','__HASH_ASSET_CUSTOM_FIELD__')",
	'mod_asset_custom_field' => "UPDATE assets_custom_field SET descr='__DESCR__',tipo=__TIPO__ WHERE hash_asset_custom_field='__HASH_ASSET_CUSTOM_FIELD__'",
	'mod_asset_custom_field_available_values' => "UPDATE assets_custom_field SET available_values='__AVAILABLE_VALUES__' WHERE hash_asset_custom_field='__HASH_ASSET_CUSTOM_FIELD__'",
	'del_asset_custom_field1' => "DELETE FROM assets_custom_field WHERE hash_asset_custom_field='__HASH_ASSET_CUSTOM_FIELD__'",
	'del_asset_custom_field2' => "DELETE FROM assets_custom_data WHERE hash_asset_custom_field='__HASH_ASSET_CUSTOM_FIELD__'",
	'all_asset_types_count'=>"SELECT a.hash_asset_type,a.descr,COUNT(b.id_asset) AS cuantos,a.icon,a.manage,a.id_host_type FROM assets_types a LEFT JOIN assets b ON a.hash_asset_type=b.hash_asset_type GROUP BY a.hash_asset_type ORDER BY a.descr",
	'get_num_assets_types' => "SELECT COUNT(*) AS cuantos FROM assets_types",

	'get_num_assets_types_by_manage' => "SELECT COUNT(*) AS cuantos FROM assets_types WHERE manage IN (__MANAGE__) AND id_host_type=0",
	'get_asset_types_by_descr'=>"SELECT * FROM assets_types WHERE descr='__DESCR__'",
	'get_asset_subtypes_by_type_subtype'=>"SELECT * FROM assets_subtypes WHERE hash_asset_subtype='__HASH_ASSET_SUBTYPE__' AND hash_asset_type='__HASH_ASSET_TYPE__'",
	'get_asset_info_by_id_dev' => "SELECT a.*,b.descr,c.descr as subtype FROM (assets a,assets_types b) LEFT JOIN assets_subtypes c ON a.hash_asset_subtype=c.hash_asset_subtype WHERE a.hash_asset_type=b.hash_asset_type AND a.id_dev IN (__ID_DEV__)",

   'cnm_asset_delete_temp'=>"DROP TEMPORARY TABLE IF EXISTS t1",
   // 'cnm_asset_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.id_asset,a.name,a.owner,a.status,a.critic,ifnull(b.descr,'') as docu,a.id_asset_subtype FROM assets a LEFT JOIN tips b on a.id_asset=b.id_ref AND b.position=0 and b.tip_type='asset' WHERE a.id_asset_type IN (__ID_ASSET_TYPE__))",
   'cnm_asset_create_temp' => "CREATE TEMPORARY TABLE t1 (SELECT a.hash_asset,a.name,a.owner,a.status,a.critic,ifnull(b.descr,'') as docu,a.hash_asset_subtype,(SELECT count(*) FROM asset2metric c WHERE c.hash_asset=a.hash_asset) AS cuantos FROM assets a LEFT JOIN tips b on a.hash_asset=b.id_ref AND b.position=0 and b.tip_type='asset' WHERE a.hash_asset_type='__HASH_ASSET_TYPE__')",
	'cnm_asset_alter_temp'=>"ALTER TABLE t1 ADD COLUMN __COLUMNA__ varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default '-'",
	'cnm_asset_get_data_from_asset_type'=>"SELECT b.hash_asset_custom_field,b.hash_asset,b.data from assets_custom_field a, assets_custom_data b WHERE a.hash_asset_custom_field=b.hash_asset_custom_field AND a.hash_asset_type='__HASH_ASSET_TYPE__'",
	'cnm_asset_insert_temp'=>"UPDATE t1 set __COLUMNA__='__VALUE__' WHERE hash_asset='__HASH_ASSET__'",
   'cnm_asset_get_list' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'cnm_asset_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",

	'delete_asset' => "DELETE FROM assets WHERE hash_asset='__HASH_ASSET__'",
	'delete_asset_custom_data' => "DELETE FROM assets_custom_data WHERE hash_asset='__HASH_ASSET__'",
	// 'asset_info' => "SELECT * FROM assets WHERE id_asset IN (__ID_ASSET__)",
	'asset_info' => "SELECT a.*,b.descr,c.descr as subtype FROM (assets a,assets_types b) LEFT JOIN assets_subtypes c ON a.hash_asset_subtype=c.hash_asset_subtype WHERE a.hash_asset_type=b.hash_asset_type AND a.hash_asset='__HASH_ASSET__'",
   'get_assets_custom_typeslist'=>"SELECT a.hash_asset_custom_field,a.descr,a.tipo,a.available_values FROM assets_custom_field a WHERE a.tipo IN (3) AND a.hash_asset_type='__HASH_ASSET_TYPE__' ORDER BY a.descr",
   'get_assets_custom_typesenumerate'=>"SELECT a.hash_asset_custom_field,a.descr,a.tipo,a.available_values FROM assets_custom_field a WHERE a.tipo IN (4) AND a.hash_asset_type='__HASH_ASSET_TYPE__' ORDER BY a.descr",
   'get_assets_custom_data_value'=>"SELECT data from assets_custom_data WHERE hash_asset='__HASH_ASSET__' AND hash_asset_custom_field='__HASH_ASSET_CUSTOM_FIELD__'",
	'get_info_custom_field'=>"SELECT * FROM assets_custom_field WHERE hash_asset_custom_field='__HASH_ASSET_CUSTOM_FIELD__'",

	'update_asset'=>"UPDATE assets SET name='__NAME__',status='__STATUS__',critic='__CRITIC__',owner='__OWNER__',hash_asset_subtype='__HASH_ASSET_SUBTYPE__' WHERE hash_asset='__HASH_ASSET__'",
	'create_asset'=>"INSERT INTO assets (name,status,critic,hash_asset_type,owner,hash_asset_subtype,hash_asset,id_dev) VALUES ('__NAME__','__STATUS__','__CRITIC__','__HASH_ASSET_TYPE__','__OWNER__','__HASH_ASSET_SUBTYPE__','__HASH_ASSET__','__ID_DEV__')",
	'get_asset_type_info'=>"SELECT * FROM assets_types WHERE hash_asset_type='__HASH_ASSET_TYPE__'",
	'get_asset_type_info_by_id_host_type'=>"SELECT * FROM assets_types WHERE id_host_type IN (__ID_HOST_TYPE__)",
	'get_asset_custom_data'=>"SELECT b.descr,a.data,a.hash_asset_custom_data,b.tipo,b.hash_asset_custom_field FROM assets_custom_data a,assets_custom_field b WHERE a.hash_asset_custom_field=b.hash_asset_custom_field AND a.hash_asset='__HASH_ASSET__'",


	'asset_subtypes' => "SELECT * FROM assets_subtypes WHERE hash_asset_type='__HASH_ASSET_TYPE__' ORDER BY descr",
	'asset_subtypes_group_count' => "SELECT hash_asset_type,COUNT(*) AS cuantos FROM assets_subtypes GROUP BY hash_asset_type",
	// 'asset_subtypes_count_assets' => "SELECT COUNT(*) AS cuantos,b.hash_asset_subtype from assets_subtypes a, assets b WHERE a.hash_asset_subtype=b.hash_asset_subtype GROUP BY b.hash_asset_subtype",
	'asset_subtypes_count_assets' => "SELECT COUNT(*) AS cuantos,b.hash_asset_subtype,b.hash_asset_type from assets_subtypes a, assets b WHERE a.hash_asset_subtype=b.hash_asset_subtype AND a.hash_asset_type=b.hash_asset_type AND b.hash_asset_type='__HASH_ASSET_TYPE__' GROUP BY b.hash_asset_subtype",
	'del_asset_subtype' => "DELETE FROM assets_subtypes WHERE hash_asset_subtype='__HASH_ASSET_SUBTYPE__'",
	'new_asset_subtype' => "INSERT INTO assets_subtypes (hash_asset_type,hash_asset_subtype,descr) VALUES ('__HASH_ASSET_TYPE__','__HASH_ASSET_SUBTYPE__','__DESCR__')",
	'mod_asset_subtype' => "UPDATE assets_subtypes SET descr='__DESCR__' WHERE hash_asset_subtype='__HASH_ASSET_SUBTYPE__'",
	'asset_subtype_from_asset'=>"SELECT b.descr FROM assets a, assets_subtypes b WHERE a.hash_asset='__HASH_ASSET__' AND a.hash_asset_subtype=b.hash_asset_subtype",

	// --------------------------------------------------------------------------
	'asset_all_custom_field' => "SELECT * FROM assets_custom_field ORDER BY descr",
   'api_get_assets_layout_delete_temp' => "DROP TEMPORARY TABLE IF EXISTS t1,t2",
   'api_get_assets_layout_create_temp1' => "CREATE TEMPORARY TABLE t1(SELECT a.hash_asset AS id,a.name,a.status,a.critic,a.owner,b.descr AS type,IFNULL(c.descr,'') AS subtype FROM (assets a,assets_types b) LEFT JOIN assets_subtypes c ON a.hash_asset_subtype=c.hash_asset_subtype WHERE a.hash_asset_type=b.hash_asset_type)",
	'api_get_assets_layout_alter_temp1'=>"ALTER TABLE t1 ADD COLUMN __COLUMNA__ varchar(255) character set utf8 collate utf8_spanish_ci default NULL",
	'api_get_assets_layout_alter_temp2'=>"UPDATE t1,(SELECT hash_asset,data FROM assets_custom_data WHERE hash_asset_custom_field='__HASH_ASSET_CUSTOM_FIELD__') src SET t1.__COLUMNA__=src.data WHERE t1.id=src.hash_asset",
   'api_get_assets_layout_lista' => "SELECT __OUTPUT_FIELDS__ FROM t1 WHERE __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
    'task_asoc_asset'=>"INSERT IGNORE INTO task2device (name,id_dev,ip,type) values ('__SUBTYPE__','__ID_ASSET__','__HASH_ASSET__','asset')",

	'get_assets_proxys'=>"SELECT id_dev,name,domain,ip,sysloc,sysdesc,sysoid,txml,type,app,status,mode,community,version,wbem_user,wbem_pwd,refresh,aping,aping_date,geodata,id_cfg_op,host_idx,background,xagent_version,enterprise,email,correlated_by FROM devices WHERE asset_container=1",
	// --------------------------------------------------------------------------
	'delete_assets_types2app'=>"DELETE FROM assets_types2app WHERE hash_asset_type='__HASH_ASSET_TYPE__'",
	'insert_assets_types2app'=>"INSERT INTO assets_types2app (hash_asset_type,aname,type) VALUES ('__HASH_ASSET_TYPE__','__ANAME__',__TYPE__)",
	'get_assets_types2app'=>"SELECT a.*,b.name FROM assets_types2app a,cfg_monitor_apps b WHERE a.aname=b.aname AND hash_asset_type='__HASH_ASSET_TYPE__' AND a.type='__TYPE__'",

	'get_devices_types2app'=>"SELECT a.*,b.name FROM devices_types2app a,cfg_monitor_apps b WHERE a.aname=b.aname AND id_host_type=__ID_HOST_TYPE__ AND a.type='__TYPE__' ORDER BY b.name",
	'delete_devices_types2app'=>"DELETE FROM devices_types2app WHERE id_host_type=__ID_HOST_TYPE__",
	'insert_devices_types2app'=>"INSERT INTO devices_types2app (id_host_type,aname,type) VALUES (__ID_HOST_TYPE__,'__ANAME__',__TYPE__)",
   // --------------------------------------------------------------------------
   'credential_from_asset'=>"SELECT id_credential FROM asset2credential WHERE hash_asset='__HASH_ASSET__'",
   'insert_asset_credential'=>"INSERT INTO asset2credential (hash_asset,id_credential) VALUES ('__HASH_ASSET__',__ID_CREDENTIAL__)",
   'delete_asset_credential'=>"DELETE FROM asset2credential WHERE hash_asset='__HASH_ASSET__' AND id_credential=__ID_CREDENTIAL__",

	'proxy_from_asset'=>"SELECT id_dev FROM asset2proxy WHERE hash_asset='__HASH_ASSET__'",
	'delete_all_proxy_from_asset'=>"DELETE FROM asset2proxy WHERE hash_asset='__HASH_ASSET__'",
	'asoc_proxy_to_asset'=>"INSERT INTO asset2proxy (id_dev,hash_asset) VALUES (__ID_DEV__,'__HASH_ASSET__')",
	'get_alerts_from_asset'=>"SELECT a.id_device,a.mname,a.id_alert_type,b.expr,b.cause,b.severity,a.id_metric FROM (alerts a,asset2metric c) LEFT JOIN alert_type b ON a.id_alert_type=b.id_alert_type WHERE a.counter>0 AND a.id_metric=c.id_metric AND c.hash_asset='__HASH_ASSET__'",
	'asset_metricas_encurso_delete_temp'=>"DROP TABLE IF EXISTS t1",
   'asset_metricas_encurso_create_temp1'=>"CREATE TEMPORARY TABLE t1(SELECT a.id_metric,a.watch,a.subtype,a.id_dev,a.name AS mname,a.correlate,a.label,a.status,a.type,if(id_alert,1,0) as alarmada,ifnull(c.severity,0) AS alert_severity,c.counter as alert_counter,b.status AS device_status,d.severity,ifnull(d.cause,'-')as monitor,ifnull(d.id_alert_type,'') AS id_alert_type,' ' AS motivo,0 AS in_view ,0 AS asoc,b.name AS proxy FROM (metrics a,devices b) LEFT JOIN alerts c ON (a.name=c.mname AND a.id_dev=c.id_device) LEFT JOIN alert_type d ON a.watch=d.monitor WHERE a.id_dev=b.id_dev AND a.id_dev in (__ID_DEV__) AND a.status<4)",
   'asset_metricas_encurso_create_temp2'=>"UPDATE t1 SET asoc=1 WHERE id_metric IN (SELECT id_metric FROM asset2metric WHERE hash_asset='__HASH_ASSET__')",
   'asset_metricas_encurso_lista' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__ LIMIT __POSSTART__,__COUNT__",
   'asset_metricas_encurso_lista_no_limit' => "SELECT * FROM t1 WHERE ''='' __CONDITION__ ORDER BY __ORDERBY__",
   'asset_metricas_encurso_count' => "SELECT COUNT(*) AS cuantos FROM t1 WHERE ''='' __CONDITION__",
	'asoc_metric_to_asset'=>"INSERT IGNORE INTO asset2metric (hash_asset,id_metric) VALUES ('__HASH_ASSET__',__ID_METRIC__)",
	'deasoc_metric_to_asset'=>"DELETE FROM asset2metric WHERE hash_asset='__HASH_ASSET__' AND id_metric IN (__ID_METRIC__)",
	'get_metric_from_asset'=>"SELECT id_metric FROM asset2metric WHERE hash_asset='__HASH_ASSET__'",
	'metric_asset_by_id' => "SELECT a.*,b.id_dev FROM asset2metric a, metrics b WHERE hash_asset='__HASH_ASSET__' AND a.id_metric IN (__ID_METRIC__) AND a.id_metric=b.id_metric",
   'update_asset_background'=>"UPDATE assets SET background='__BACKGROUND__' WHERE hash_asset='__HASH_ASSET__'",
   'save_asset_metric_pos_size'=>"UPDATE asset2metric SET graph='__GRAPH__',size='__SIZE__' WHERE id_metric=__ID_METRIC__ AND hash_asset='__HASH_ASSET__'",
   'reset_asset_metric_pos_size'=>"UPDATE asset2metric SET graph=NULL,size=NULL WHERE id_metric=__ID_METRIC__ AND hash_asset='__HASH_ASSET__'",






   // --------------------------------------------------------------------------
	'get_finished_tasks'=>"SELECT FROM_UNIXTIME(a.date_store) AS human_date_store,FROM_UNIXTIME(a.date_end) AS human_date_end,b.name,CONCAT(c.ip) FROM qactions a LEFT JOIN cfg_monitor_apps b ON a.task=b.aname LEFT JOIN task2device c ON a.action=c.name WHERE a.descr LIKE '%usuario' AND c.type='device' ORDER BY date_end",
   'get_running_tasks' => "SELECT a.*,b.status,FROM_UNIXTIME(b.date_store) AS human_date,(UNIX_TIMESTAMP()-b.date_store) AS duration FROM cfg_task_configured a,qactions b WHERE a.subtype=b.action AND status!=3 ORDER BY id_qactions DESC",

   'get_running_actions' => "SELECT a.name AS app_name,FROM_UNIXTIME(b.date_store) AS human_date,(UNIX_TIMESTAMP()-b.date_store) AS duration,b.action,b.pid,b.id_qactions FROM cfg_monitor_apps a,qactions b WHERE a.aname=b.task AND b.status!=3 ORDER BY id_qactions DESC",
   'get_scheduled_actions' => "SELECT a.*,FROM_UNIXTIME(a.date) AS human_date,0 AS duration,b.name AS app_name FROM cfg_task_configured a,cfg_monitor_apps b WHERE a.exec=1 AND a.task=b.aname AND a.subtype NOT IN (SELECT action FROM qactions)",

   // --------------------------------------------------------------------------
	'get_multi_local_alerts'=>"SELECT id_alert,id_metric,id_device,severity,counter,mname,watch,ack,id_ticket,type,date,name,domain,ip,label,cause,event_data,correlated,correlated_by,cid,cid_ip,ticket_descr,mode,critic FROM alerts ORDER BY date ASC",
	'get_multi_local_alert2user'=>"SELECT id_alert,login_name,cid,cid_ip FROM alert2user WHERE cid='__CID__' AND cid_ip='__CID_IP__' ORDER BY login_name DESC",
	'get_multi_local_cfg_views'=>"SELECT id_cfg_view,name,type,itil_type,function,weight,background,ruled,severity,red,orange,yellow,blue,cid,cid_ip,global,nmetrics,nremote,nsubviews FROM cfg_views WHERE cid='__CID__' AND cid_ip='__CID_IP__' AND internal=1 ORDER BY name ASC",
	'get_multi_local_cfg_user2view'=>"SELECT id_user,id_cfg_view,cid,login_name,cid_ip FROM cfg_user2view WHERE cid='__CID__' AND cid_ip='__CID_IP__' ORDER BY id_user ASC",
	'get_multi_cnm_list'=>"SELECT hidx,cid,descr,host_ip,mode FROM cnm.cfg_cnms ORDER BY hidx",
	'clear_cnm_status'=>"DELETE FROM cnm_status WHERE hidx NOT IN (SELECT hidx FROM cnm.cfg_cnms)",
	'delete_multi_alerts_remote'=>"DELETE FROM alerts_remote WHERE cid='__CID__' AND cid_ip='__CID_IP__'",
	'insert_multi_alerts_remote'=>"INSERT INTO alerts_remote (id_alert,id_metric,id_device,severity,counter,mname,watch,ack,id_ticket,type,date,name,domain,ip,label,cause,event_data,correlated,correlated_by,cid,cid_ip,ticket_descr,mode,critic) VALUES __VALUES__",
	'delete_multi_alert2user_remote'=>"DELETE FROM alert2user_remote WHERE cid='__CID__' AND cid_ip='__CID_IP__'",
	'insert_multi_alert2user_remote'=>"REPLACE INTO alert2user_remote (id_alert,login_name,cid,cid_ip) VALUES __VALUES__",
	'delete_multi_cfg_views'=>"DELETE FROM cfg_views WHERE cid='__CID__' AND cid_ip='__CID_IP__'",
	'insert_multi_cfg_views'=>"REPLACE INTO cfg_views (id_cfg_view,name,type,itil_type,function,weight,background,ruled,severity,red,orange,yellow,blue,cid,cid_ip,global,nmetrics,nremote,nsubviews,internal) VALUES __VALUES__",
	'delete_multi_cfg_user2view'=>"DELETE FROM cfg_user2view WHERE cid='__CID__' AND cid_ip='__CID_IP__'",
	'insert_multi_cfg_user2view'=>"REPLACE INTO cfg_user2view (id_user,id_cfg_view,login_name,cid,cid_ip) VALUES __VALUES__",
	// 'update_multi_cnm_status_nook'=>"UPDATE cnm_status SET counter=counter+1,tlast='__TLAST__',status='__STATUS__' WHERE cid='__CID__' AND cid_ip='__CID_IP__'",
	'update_multi_cnm_status_nook'=>"INSERT INTO cnm_status (hidx,cid,cid_ip,tlast,status,counter) VALUES (__HIDX__,'__CID__','__CID_IP__','__TLAST__','__STATUS__',-1) ON DUPLICATE KEY UPDATE counter=counter+1,tlast='__TLAST__',status='__STATUS__'",
	// 'update_multi_cnm_status_ok'=>"UPDATE cnm_status SET counter='-1',tlast='__TLAST__',status='__STATUS__' WHERE cid='__CID__' AND cid_ip='__CID_IP__'",
	'update_multi_cnm_status_ok'=>"INSERT INTO cnm_status (hidx,cid,cid_ip,tlast,status,counter) VALUES (__HIDX__,'__CID__','__CID_IP__','__TLAST__','__STATUS__',-1) ON DUPLICATE KEY UPDATE counter='-1',tlast='__TLAST__',status='__STATUS__'",

	'get_multi_local_devices_custom_types'=>"SELECT id,UPPER(descr) AS descr,tipo FROM devices_custom_types",
	'get_multi_local_devices_custom_data'=>"SELECT b.* FROM alerts a,devices_custom_data b WHERE a.id_device=b.id_dev GROUP BY b.id_dev",
	'delete_multi_global_devices_custom_data'=>"DELETE FROM global_devices_custom_data WHERE cid='__CID__' AND cid_ip='__CID_IP__'",
	'insert_multi_global_devices_custom_data'=>"REPLACE INTO global_devices_custom_data (id_dev,field_name,field_name_hash,field_type,field_value,cid,cid_ip) VALUES __VALUES__",

   // 'global_get_user_fields' => "SELECT field_name,field_name_hash FROM global_devices_custom_data GROUP BY field_name_hash ORDER BY field_name",
   'global_get_user_fields' => "SELECT * FROM mem_global_devices_custom_types ORDER BY field_descr",
   'global_get_user_all_values' => "SELECT * FROM global_devices_custom_data ORDER BY field_name",
	'global_get_device_by_values'=> "SELECT id_dev,cid,cid_ip FROM global_devices_custom_data WHERE field_name_hash='__FIELD_NAME_HASH__' __CONDITION__",

	'drop_mem_global_devices_custom_types'=>"DROP TABLE mem_global_devices_custom_types",
	'create_mem_global_devices_custom_types'=>"CREATE TABLE mem_global_devices_custom_types (`field_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT '',`field_descr` varchar(255) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT '',`field_type` int(11) DEFAULT NULL, PRIMARY KEY (`field_id`)) ENGINE=MEMORY",
	'insert_mem_global_devices_custom_types'=>"REPLACE INTO mem_global_devices_custom_types (field_id,field_descr,field_type) VALUES __VALUES__",

	'get_all_mem_global_devices_custom_types'=>"SELECT field_name,field_name_hash FROM mem_global_devices_custom_types ORDER BY field_name",
	'drop_mem_global_devices_custom_data'=>"DROP TABLE mem_global_devices_custom_data",
	'create_mem_global_devices_custom_data'=>"CREATE TABLE mem_global_devices_custom_data (`id_dev` int(11) NOT NULL DEFAULT '0', `cid` varchar(20) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT '', `cid_ip` varchar(50) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT '' __CONDITION__ ,PRIMARY KEY (`id_dev`,`cid`,`cid_ip`)) ENGINE=MEMORY",
	'insert_multi_mem_global_devices_custom_data'=>"REPLACE INTO mem_global_devices_custom_data (cid,cid_ip,id_dev__FIELDS__) VALUES __VALUES__",

	// --------------------------------------------------------------------------
	'get_alerts2app'=>"SELECT a.*,b.name FROM alerts2app a,cfg_monitor_apps b WHERE a.aname=b.aname AND a.type='__TYPE__'",
	'delete_alerts2app'=>"DELETE FROM alerts2app",
	'insert_alerts2app'=>"INSERT INTO alerts2app (aname,type) VALUES ('__ANAME__',__TYPE__)",
	// --------------------------------------------------------------------------
	'task_asoc_alert'=>"INSERT IGNORE INTO task2device (name,id_dev,type) values ('__SUBTYPE__','__ID_ALERT__','alert')",
	// --------------------------------------------------------------------------
	'get_all_apps_with_globals'=>"SELECT a.id_monitor_app,a.aname,a.name,a.cmd FROM cfg_monitor_apps a,cfg_app_param b WHERE a.aname=b.aname AND b.value LIKE '\$global%' GROUP BY a.aname",
	'get_all_apps_with_globals_from_param'=>"SELECT a.id_monitor_app,a.aname,a.name,a.cmd FROM cfg_monitor_apps a,cfg_app_param b WHERE a.aname=b.aname AND b.id_cfg_app_param IN (__ID_CFG_APP_PARAM__) AND b.value LIKE '\$global%' GROUP BY a.aname",
	// 'get_all_global_params_from_app'=>"SELECT a.id_cfg_app_param,a.hparam,a.value,IFNULL(b.param_value,'') AS param_value FROM cfg_app_param a LEFT JOIN cnm_global_params b ON a.value=b.param_name WHERE aname='__ANAME__' AND value LIKE '\$global%'",
	'get_all_global_params_from_app'=>"SELECT a.id_cfg_app_param,a.hparam,a.value,IFNULL(b.param_value,'') AS param_value,c.descr AS param_descr FROM (cfg_app_param a,cfg_script_param c) LEFT JOIN cnm_global_params b ON a.value=b.param_name WHERE aname='__ANAME__' AND a.hparam=c.hparam AND a.value LIKE '\$global%'",
	// 'get_all_global_params'=>"SELECT a.id_cfg_app_param,a.hparam,a.value,IFNULL(b.param_value,'') AS param_value FROM cfg_app_param a LEFT JOIN cnm_global_params b ON a.value=b.param_name WHERE value LIKE '\$global%'",
	'get_all_global_params'=>"SELECT a.id_cfg_app_param,a.hparam,a.value,IFNULL(b.param_value,'') AS param_value,c.descr AS param_descr FROM (cfg_app_param a,cfg_script_param c) LEFT JOIN cnm_global_params b ON a.value=b.param_name WHERE a.hparam=c.hparam AND a.value LIKE '\$global%'",
	'save_global_param'=>"INSERT INTO cnm_global_params (param_name,param_value) VALUES ('__PARAM_NAME__','__PARAM_VALUE__') ON DUPLICATE KEY UPDATE param_value='__PARAM_VALUE__'",

	'cnm_asoc_devices_remote_new' => "INSERT INTO cfg_remote_alerts2device (id_remote_alert,target) (SELECT '__ID_REMOTE_ALERT__',target FROM cfg_remote_alerts2device WHERE id_remote_alert IN (__ORIGIN_ID__))",

	// --------------------------------------------------------------------------
	'delete_device'=>"DELETE FROM devices WHERE id_dev IN (__ID_DEV__)",
	'delete_notifications_of_device'=>"DELETE FROM cfg_notification2device WHERE id_device IN (__ID_DEV__)",
	'delete_custom_data_of_device'=>"DELETE FROM devices_custom_data WHERE id_dev IN (__ID_DEV__)",
	'delete_organizational_profile_of_device'=>"DELETE FROM cfg_devices2organizational_profile WHERE id_dev IN (__ID_DEV__)",
	'delete_tips_of_device'=>"DELETE FROM tips WHERE id_ref IN (__ID_DEV__) AND tip_type='id_dev'",
	'delete_remote_alerts_of_device'=>"DELETE FROM cfg_remote_alerts2device WHERE target='__TARGET__'",
	'delete_alerts_of_device'=>"DELETE FROM alerts WHERE id_device IN (__ID_DEVICE__)",
	'delete_alerts_store_of_device'=>"elete from alerts_store where id_device in (__ID_DEVICE__)",
	'get_all_from_prov_template_metrics_by_id_dev'=>"SELECT * FROM prov_template_metrics WHERE id_dev IN (__ID_DEV__)",
	'delete_prov_template_metrics'=>"DELETE FROM prov_template_metrics WHERE id_template_metric IN (__ID_TEMPLATE_METRIC__)",
	'delete_prov_template_metrics2iid'=>"DELETE FROM prov_template_metrics2iid WHERE id_template_metric IN (__ID_TEMPLATE_METRIC__)",
	'delete_device_of_device2features'=>"DELETE FROM device2features WHERE id_dev IN (__ID_DEV__)",
	'delete_ticket_of_device'=>"DELETE FROM ticket WHERE id_dev IN (__ID_DEV__)",
	'delete_metrics2device_of_device'=>"DELETE FROM prov_default_metrics2device WHERE id_dev IN (__ID_DEV__)",
	'delete_prov_default_apps2device_of_device'=>"DELETE FROM prov_default_apps2device WHERE id_dev IN (__ID_DEV__)",
	'delete_cfg_app2device_of_device'=>"DELETE FROM cfg_app2device WHERE id_dev IN (__ID_DEV__)",
	// --------------------------------------------------------------------------
	'get_remote_alerts_from_view'=>"SELECT b.id_remote_alert, b.descr,a.id_dev FROM cfg_views2remote_alerts a, cfg_remote_alerts b WHERE a.id_remote_alert=b.id_remote_alert AND b.type!='cnm' AND a.id_cfg_view IN (__ID_CFG_VIEW__) ORDER BY b.descr",
	'get_mon_icmp_from_device'=>"SELECT subtype,name,label from metrics where subtype='mon_icmp' AND id_dev IN (__ID_DEV__)",
	'get_mon_snmp_from_device'=>"SELECT subtype,name,label from metrics where subtype='mon_snmp' AND id_dev IN (__ID_DEV__)",
	'get_watch_from_view'=>"SELECT b.watch,a.id_device,c.severity,b.name,b.id_metric FROM cfg_views2metrics a,metrics b,alert_type c WHERE a.id_metric=b.id_metric AND b.watch!='0' AND b.watch=c.monitor AND id_cfg_view IN (__ID_CFG_VIEW__)",
	// 'get_latency_metrics_from_view'=>"SELECT b.name,a.id_device,b.severity FROM cfg_views2metrics a,metrics b WHERE a.id_metric=b.id_metric AND type='latency' AND subtype!='mon_icmp' AND b.watch='0' AND id_cfg_view IN (__ID_CFG_VIEW__)",
	'get_latency_metrics_from_view'=>"SELECT b.id_metric,b.name,a.id_device,b.severity FROM cfg_views2metrics a,metrics b WHERE a.id_metric=b.id_metric AND type='latency' AND b.watch='0' AND id_cfg_view IN (__ID_CFG_VIEW__)",
	// --------------------------------------------------------------------------
	'delete_report_view'=>"UPDATE cfg_views SET subtype_cfg_report='' WHERE subtype_cfg_report='__SUBTYPE_CFG_REPORT__'",
	'get_cause_from_alert_type_and_metrics' => "SELECT b.cause,b.severity FROM metrics a,alert_type b WHERE a.watch=b.monitor AND a.id_dev IN (__ID_DEV__) and a.watch!='0' AND a.watch='__WATCH__'",
	'get_label_from_metrics' => "SELECT label,severity FROM metrics WHERE name='__NAME__' AND id_dev IN (__ID_DEV__)",
);
?>
