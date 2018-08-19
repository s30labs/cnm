<?php
// Programa que actualiza el campo apptype de la tabla alert_type

// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");

global $enlace;
$db_params=array(
   'phptype'  => 'mysql',
   'username' => 'onm',
   'hostspec' => 'localhost',
   'database' => 'onm',
);
$db_params['password'] = chop(`cat /cfg/onm.conf | grep DB_PWD|cut -d "=" -f2 | tr -d ' '`);
if (connectDB($db_params)==1){ exit;}


update_apptype_monitor();
update_apptype_latency();
update_apptype_xagent();
update_apptype_apps();



/*
mysql> select id_alert_type,mname,type,apptype from alert_type;
+---------------+-----------------+--------+---------+
| id_alert_type | mname           | type   | apptype |
+---------------+-----------------+--------+---------+
|             1 | disk_mibhost    | snmp   |         |
|             2 | custom_5499e245 | snmp   |         |
|             3 | custom_b027887d | snmp   |         |
|             4 | custom_b578e0d2 | snmp   |         |
|             9 | status_mibii_if | snmp   |         |
|             7 | custom_a1c2bd29 | xagent |         |
|             8 | status_mibii_if | snmp   |         |
|            15 | custom_8c61e792 | xagent |         |
|            17 | status_mibii_if | snmp   |         |
|            18 | xagt_647cba     | xagent |         |
|            19 | xagt_647cba     | xagent |         |
+---------------+-----------------+--------+---------+

select subtype,apptype from cfg_monitor_snmp;
select monitor,apptype from cfg_monitor;
select subtype,apptype from cfg_monitor_agent;
*/
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
function update_apptype_monitor(){
	global $enlace;

	$sql="SELECT id_alert_type,mname,type,apptype from alert_type";
	$result = $enlace->query($sql);
 	while ($result->fetchInto($r)){
		$id_alert_type = $r['id_alert_type'];
		$type          = $r['type'];
		$mname         = $r['mname'];
		
		if($type=='snmp'){
			$sqlu="UPDATE alert_type SET apptype=(SELECT apptype FROM cfg_monitor_snmp WHERE subtype='$mname') WHERE id_alert_type=$id_alert_type";
		}
		elseif($type=='xagent'){
			$sqlu="UPDATE alert_type SET apptype=(SELECT apptype FROM cfg_monitor_agent WHERE subtype='$mname') WHERE id_alert_type=$id_alert_type";
		}
		elseif($type=='latency'){
         $sqlu="UPDATE alert_type SET apptype=(SELECT apptype FROM cfg_monitor WHERE monitor='$mname') WHERE id_alert_type=$id_alert_type";
      }
		$resultu = $enlace->query($sqlu);
		if (@PEAR::isError($resultu)){
			print"ERROR: ".$resultu->getMessage()."\n";
		}
	}

   if (@PEAR::isError($result)) {
      print"ERROR: ".$result->getMessage()."\n";
      exit;
   }
}


//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
function update_apptype_latency(){
   global $enlace;


	$sqlu="UPDATE cfg_monitor SET apptype='IPSERV.WWW' WHERE subtype='mon_http'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }
   
	$sqlu="UPDATE cfg_monitor SET apptype='IPSERV.POP3' WHERE subtype='mon_pop3'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }
   
	$sqlu="UPDATE cfg_monitor SET apptype='IPSERV.IMAP4' WHERE subtype='mon_imap'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }
   
	$sqlu="UPDATE cfg_monitor SET apptype='IPSERV.SMTP' WHERE subtype='mon_smtp'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }
   
	$sqlu="UPDATE cfg_monitor SET apptype='IPSERV.DNS' WHERE subtype='mon_dns'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }
   
	$sqlu="UPDATE cfg_monitor SET apptype='IPSERV.TCP' WHERE subtype='mon_tcp'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }
   
	$sqlu="UPDATE cfg_monitor SET apptype='IPSERV.SSH' WHERE subtype='mon_ssh'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }
   
	$sqlu="UPDATE cfg_monitor SET apptype='IPSERV.SNMP' WHERE subtype='mon_snmp'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }
   
   $sqlu="UPDATE cfg_monitor SET apptype='IPSERV.SMB' WHERE subtype='mon_smb'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }

   $sqlu="UPDATE cfg_monitor SET apptype='IPSERV.NTP' WHERE subtype='mon_ntp'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }

   $sqlu="UPDATE cfg_monitor SET apptype='IPSERV.LDAP' WHERE subtype='mon_ldap'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }
}

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
function update_apptype_xagent(){
   global $enlace;


   $sqlu="UPDATE cfg_monitor_agent SET apptype='BBDD.MYSQL' WHERE apptype='BBDD-Mysql'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }

   $sqlu="UPDATE cfg_monitor_agent SET apptype='SO.WINDOWS' WHERE apptype='SO-Win'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }

   $sqlu="UPDATE cfg_monitor_agent SET apptype='SO.LINUX' WHERE apptype='SO-Linux'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }

   $sqlu="UPDATE cfg_monitor_agent SET apptype='IPSERV.POP3' WHERE apptype='APP-Correo'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }

   $sqlu="UPDATE cfg_monitor_agent SET apptype='NET.BASE' WHERE apptype='RED'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }
}


//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
function update_apptype_apps(){
   global $enlace;


   $sqlu="UPDATE cfg_monitor_apps SET apptype='NET.BASE' WHERE apptype='RED'";
   $resultu = $enlace->query($sqlu);
   if (@PEAR::isError($resultu)){
      print"ERROR: ".$resultu->getMessage()."\n";
   }



}
?>
