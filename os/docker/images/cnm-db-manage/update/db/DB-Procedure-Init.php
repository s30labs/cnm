<?php

$DBProcedure = array(
	//--------------------------------------------------
	'sp_alerts_read'=>'

CREATE PROCEDURE sp_alerts_read(IN pCID VARCHAR(20), IN pCID_IP VARCHAR(16))
	BEGIN
      INSERT INTO ipc (name,status,date_store,cid,cid_ip)  VALUES ("sync_alerts",1,unix_timestamp(),pCID,pCID_IP) ON DUPLICATE KEY UPDATE status=1, date_store=unix_timestamp();

   	DROP TABLE IF EXISTS alerts_read;
      CREATE TABLE alerts_read ENGINE MEMORY (SELECT a.id_alert,a.id_metric,a.id_device,a.severity,a.counter,a.mname,a.watch,a.ack,a.id_ticket,a.type,a.date,a.name,a.domain,a.ip,a.label,a.cause,a.event_data,a.correlated,a.correlated_by,a.cid,a.cid_ip,a.ticket_descr,a.date_last,a.critic,d.type as dtype FROM alerts a, devices d where a.ip=d.ip LIMIT 20000);
		ALTER TABLE alerts_read ADD PRIMARY KEY(`id_alert`,`cid`,`cid_ip`);
		INSERT INTO alerts_read (id_alert,id_metric,id_device,severity,counter,mname,watch,ack,id_ticket,type,date,name,domain,ip,label,cause,event_data,correlated,correlated_by,cid,cid_ip,ticket_descr,date_last,critic) SELECT id_alert,id_metric,id_device,severity,counter,mname,watch,ack,id_ticket,type,date,name,domain,ip,label,cause,event_data,correlated,correlated_by,cid,cid_ip,ticket_descr,date_last,critic FROM alerts_remote;

		DROP TABLE IF EXISTS alert2user;
      CREATE TABLE alert2user ENGINE MEMORY (SELECT a.id_alert,u.login_name,pCID as cid, pCID_IP as cid_ip FROM alerts a, cfg_users2organizational_profile u, cfg_devices2organizational_profile d WHERE u.id_cfg_op=d.id_cfg_op and a.id_device=d.id_dev) UNION (SELECT id_alert,login_name,cid,cid_ip FROM alert2user_remote);
		ALTER TABLE alert2user ADD PRIMARY KEY(`id_alert`,`login_name`,`cid`,`cid_ip`); 

		UPDATE ipc SET status=0, date_store=unix_timestamp() WHERE cid=pCID AND cid_ip=pCID_IP AND name="sync_alerts";

   END',

   //--------------------------------------------------
   'sp_alerts_read_local_set'=>'

CREATE PROCEDURE sp_alerts_read_local_set(IN pCID VARCHAR(20), IN pCID_IP VARCHAR(16), IN pID_ALERT INT(11))
   BEGIN
		INSERT IGNORE INTO alerts_read (SELECT a.id_alert,a.id_metric,a.id_device,a.severity,a.counter,a.mname,a.watch,a.ack,a.id_ticket,a.type,a.date,a.name,a.domain,a.ip,a.label,a.cause,a.event_data,a.correlated,a.correlated_by,a.cid,a.cid_ip,a.ticket_descr,a.date_last,a.critic,d.type as dtype FROM alerts a, devices d where a.ip=d.ip and a.id_alert=pID_ALERT);

		INSERT IGNORE INTO alert2user (SELECT a.id_alert,u.login_name,pCID as cid, pCID_IP as cid_ip FROM alerts a, cfg_users2organizational_profile u, cfg_devices2organizational_profile d WHERE u.id_cfg_op=d.id_cfg_op and a.id_device=d.id_dev and a.id_alert=pID_ALERT);

   END',

   //--------------------------------------------------
   'sp_alerts_read_local_clr'=>'

CREATE PROCEDURE sp_alerts_read_local_clr(IN pCID VARCHAR(20), IN pCID_IP VARCHAR(16), IN pID_ALERT INT(11))
   BEGIN

		DELETE FROM alerts_read WHERE id_alert=pID_ALERT AND cid=pCID AND cid_ip=pCID_IP;
		DELETE FROM alert2user WHERE id_alert=pID_ALERT AND cid=pCID AND cid_ip=pCID_IP;

   END',

   //--------------------------------------------------
//   'sp_alerts_remote'=>'
//
//CREATE PROCEDURE sp_alerts_remote(IN pID_ALERT INT, IN pID_DEVICE INT, IN pID_METRIC INT, IN pID_ALERT_TYPE INT, IN pWATCH VARCHAR(255), IN pSEVERITY INT, IN pDATE INT, IN pACK INT, IN pCOUNTER INT, IN pEVENT_DATA VARCHAR(2048), IN pNOTIF INT, IN pMNAME VARCHAR(255), IN pSUBTYPE VARCHAR(50), IN pID_ID_NOTE_TYPE INT, IN pNOTES TEXT,  IN pNOTE_ID VARCHAR(50), IN pTYPE VARCHAR(20), IN pID_TICKET INT, IN pLABEL VARCHAR(255), IN pMODE VARCHAR(25), IN pCORRELATED INT, IN pCORRELATED_BY VARCHAR(255), IN pNAME VARCHAR(50), IN pDOMAIN VARCHAR(30), IN pIP VARCHAR(15), IN pCID VARCHAR(20), IN pCID_IP VARCHAR(15), IN pCAUSE VARCHAR(255))
//
//   BEGIN
//      DELETE FROM alerts_remote WHERE cid= AND cid_ip=;
//		INSERT INTO alerts_remote (id_alert,id_metric,id_device,severity,counter,mname,watch,ack,id_ticket,type,date,name,domain,ip,label,cause,event_data,correlated,correlated_by,cid,cid_ip) VALUES (pID_ALERT, pID_DEVICE, pID_METRIC, pID_ALERT_TYPE, pWATCH, pSEVERITY, pDATE, pACK, pCOUNTER, pEVENT_DATA, pNOTIF, pMNAME, pSUBTYPE, pID_ID_NOTE_TYPE, pNOTES, pNOTE_ID, pTYPE, pID_TICKET, pLABEL, pMODE, pCORRELATED, pCORRELATED_BY, pNAME, pDOMAIN, pIP, pCID, pCID_IP, IN pCAUSE)
//   END',
//

	//--------------------------------------------------
	'sp_prepare_devices'=>'

CREATE PROCEDURE sp_prepare_devices (IN pCID VARCHAR(20), IN pID_CFG_OP INT(11))
BEGIN

	DECLARE SQLStmt TEXT;

   DROP TABLE IF EXISTS tdev;
   DROP TEMPORARY TABLE IF EXISTS t2;

   CREATE TEMPORARY TABLE t2 (SELECT count(*) AS num_metricas,id_dev FROM metrics GROUP BY id_dev);

   SET @SQLStmt = CONCAT("CREATE TABLE tdev SELECT a.name,a.domain,a.ip,a.type,a.status,a.community,a.version,a.xagent_version,a.sysoid,a.sysdesc,a.sysloc,a.host_idx,a.enterprise,IFNULL(num_metricas,0) as cuantos ,c.* FROM (devices a,cfg_devices2organizational_profile e) LEFT JOIN devices_custom_data c ON a.id_dev=c.id_dev LEFT JOIN t2 ON a.id_dev=t2.id_dev WHERE a.id_dev=e.id_dev AND e.id_cfg_op IN (",pID_CFG_OP,") AND e.cid=\'",pCID,"\'");
 SELECT @SQLStmt;

    PREPARE Stmt FROM @SQLStmt;
    EXECUTE Stmt;
    DEALLOCATE PREPARE Stmt;

END',



	//--------------------------------------------------
	// Borra las alertas remotas de una determinada clase
	//--------------------------------------------------
   'sp_delete_remote_class'=>'

CREATE PROCEDURE sp_delete_remote_class(IN pCLASS VARCHAR(255))
   BEGIN

      DELETE FROM cfg_remote_alerts2device  USING cfg_remote_alerts INNER JOIN cfg_remote_alerts2device WHERE cfg_remote_alerts.class=pCLASS AND cfg_remote_alerts.id_remote_alert=cfg_remote_alerts2device.id_remote_alert;
      DELETE FROM tips  USING cfg_remote_alerts INNER JOIN tips WHERE cfg_remote_alerts.class=pCLASS AND cfg_remote_alerts.id_remote_alert=tips.id_refn;
      DELETE FROM cfg_views2remote_alerts USING cfg_remote_alerts INNER JOIN cfg_views2remote_alerts WHERE cfg_remote_alerts.class=pCLASS AND cfg_remote_alerts.id_remote_alert=cfg_views2remote_alerts.id_remote_alert;
      DELETE FROM cfg_remote_alerts, cfg_remote_alerts2expr USING cfg_remote_alerts INNER JOIN cfg_remote_alerts2expr WHERE cfg_remote_alerts.class=pCLASS AND cfg_remote_alerts.id_remote_alert=cfg_remote_alerts2expr.id_remote_alert;


   END',

   //---------------------------------------
   // Borra una alerta remota en base al ID
   //---------------------------------------
   'sp_delete_remote_alert'=>'

CREATE PROCEDURE sp_delete_remote_alert(IN pID int(11))
   BEGIN
		DELETE FROM cfg_remote_alerts2device WHERE id_remote_alert in (pID);
		DELETE FROM tips WHERE tip_type="remote" AND id_refn IN (pID);
		DELETE FROM cfg_remote_alerts WHERE id_remote_alert in (pID);
		DELETE FROM cfg_remote_alerts2expr WHERE id_remote_alert in (pID);
		DELETE FROM alerts WHERE (type="snmp-trap" or type="syslog" or type="email" or type="api") AND id_alert_type in (pID);
		DELETE FROM alerts_store WHERE (type="snmp-trap" or type="syslog" or type="email" or type="api") AND id_alert_type in (pID);
		DELETE FROM cfg_views2remote_alerts WHERE id_remote_alert in (pID);

   END',

   //--------------------------------------------------
   // Consolida la tabla ipam_switch_info
   //--------------------------------------------------
   'sp_set_ipam_switch_info'=>'

CREATE PROCEDURE sp_set_ipam_switch_info()
   BEGIN

		DELETE FROM ipam_switch_info;
      INSERT INTO ipam_switch_info (ip_switch,iid,ifDescr,ifAlias,trunk,ifPhysAddress,ifMtu,ifType,ifSpeed,ifOperStatus,ifAdminStatus,mac,vlan_name,vlan_id)
         SELECT kb_interfaces.host_ip,kb_interfaces.iid,kb_interfaces.ifDescr,kb_interfaces.ifAlias,kb_interfaces.trunk,kb_interfaces.ifPhysAddress,kb_interfaces.ifMtu,kb_interfaces.ifType,kb_interfaces.ifSpeed,kb_interfaces.ifOperStatus,kb_interfaces.ifAdminStatus,kb_cam.mac,kb_cam.vlan_name,kb_cam.vlan_id
         FROM kb_interfaces, kb_cam, devices  
			WHERE kb_interfaces.host_ip=kb_cam.host_ip AND kb_interfaces.iid=kb_cam.iid AND kb_interfaces.host_ip=devices.ip AND devices.switch=1;

      UPDATE ipam_switch_info dst, (SELECT ip,mac FROM kb_arp) src SET dst.ip=src.ip WHERE dst.mac=src.mac;

      UPDATE ipam_switch_info dst, (SELECT ip,mac FROM devices) src SET dst.ip=src.ip WHERE dst.mac=src.mac;

      UPDATE ipam_switch_info dst, (SELECT ip,name,domain FROM devices) src SET dst.name=src.name,dst.domain=src.domain WHERE dst.ip=src.ip;

   END',


   //---------------------------------------
   // Obtiene la credencial especificada por IP y tipo
   //---------------------------------------
   'sp_cnms_get_credential'=>'

CREATE PROCEDURE sp_cnms_get_credential(IN pIP VARCHAR(30), IN pTYPE VARCHAR(20))
   BEGIN

		SELECT c.id_credential,c.name,c.descr,c.type,c.user,c.pwd,c.scheme,c.port,c.key_file,c.passphrase FROM credentials c, device2credential r, devices d WHERE c.id_credential=r.id_credential AND r.id_dev=d.id_dev AND d.ip=pIP AND c.type=pTYPE;

   END',


   //---------------------------------------
   // Obtiene la credencial SNMP especificada por IP
   //---------------------------------------
   'sp_cnms_get_snmp_credential'=>'

CREATE PROCEDURE sp_cnms_get_snmp_credential(IN pIP VARCHAR(30))
   BEGIN

      SELECT d.ip,d.version,d.community,p.profile_name,p.sec_name,p.sec_level,p.auth_proto,p.auth_pass,p.priv_proto,p.priv_pass FROM devices d  LEFT JOIN profiles_snmpv3 p ON d.community=p.id_profile where d.ip=pIP;

   END',


);
?>
