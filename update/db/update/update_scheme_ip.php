<?php
// Programa que actualiza la direccion IP del equipo gestor


// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");
// CLASE NECESARIA PARA GENERAR EL TOKEN
//require_once("/var/www/html/onm/inc/Store.php");

function update_ip($ip){
	global $enlace;

   $sql="SELECT host_ip FROM cnm.cfg_cnms WHERE hidx=1";
   $result = $enlace->query($sql);
   while ($result->fetchInto($r)){
      $ip_old =$r['host_ip'];
	}

	$sqlUpdate="UPDATE alerts_store SET cid_ip='$ip' WHERE cid_ip='$ip_old'";
	$resultUpdate = $enlace->query($sqlUpdate);
	print "$sqlUpdate\n";
	if (@PEAR::isError($resultUpdate)) { print "**ERROR**\n"; }

	$sqlUpdate="UPDATE alerts SET cid_ip='$ip' WHERE cid_ip='$ip_old'";
	$resultUpdate = $enlace->query($sqlUpdate);
	print "$sqlUpdate\n";
	if (@PEAR::isError($resultUpdate)) { print "**ERROR**\n"; }

   $sqlUpdate="UPDATE cfg_views SET cid_ip='$ip' WHERE cid_ip='$ip_old'";
   $resultUpdate = $enlace->query($sqlUpdate);
	print "$sqlUpdate\n";
	if (@PEAR::isError($resultUpdate)) { print "**ERROR**\n"; }


   $sqlUpdate="UPDATE cfg_user2view SET cid_ip='$ip' WHERE cid_ip='$ip_old'";
   $resultUpdate = $enlace->query($sqlUpdate);
	print "$sqlUpdate\n";
	if (@PEAR::isError($resultUpdate)) { print "**ERROR**\n"; }

   $sqlUpdate="UPDATE cfg_views2views SET cid_ip_view='$ip' WHERE cid_ip_view='$ip_old'";
   $resultUpdate = $enlace->query($sqlUpdate);
	print "$sqlUpdate\n";
	if (@PEAR::isError($resultUpdate)) { print "**ERROR**\n"; }

   $sqlUpdate="UPDATE cfg_views2views SET cid_ip_subview='$ip' WHERE cid_ip_subview='$ip_old'";
   $resultUpdate = $enlace->query($sqlUpdate);
	print "$sqlUpdate\n";
	if (@PEAR::isError($resultUpdate)) { print "**ERROR**\n"; }

   $sqlUpdate="UPDATE cnm.cfg_cnms  SET host_ip='$ip' WHERE hidx=1";
   $resultUpdate = $enlace->query($sqlUpdate);
	print "$sqlUpdate\n";
	if (@PEAR::isError($resultUpdate)) { print "**ERROR**\n"; }

   $sqlUpdate="UPDATE alerts_read SET cid_ip='$ip' WHERE cid_ip='$ip_old'";
   $resultUpdate = $enlace->query($sqlUpdate);
	print "$sqlUpdate\n";
	if (@PEAR::isError($resultUpdate)) { print "**ERROR**\n"; }

   $sqlUpdate="UPDATE alert2user SET cid_ip='$ip' WHERE cid_ip='$ip_old'";
   $resultUpdate = $enlace->query($sqlUpdate);
	print "$sqlUpdate\n";
	if (@PEAR::isError($resultUpdate)) { print "**ERROR**\n"; }

}

// PROGRAMA PRINCIPAL
global $enlace;
$db_params=array(
   'phptype'  => 'mysqli',
   'username' => 'onm',
   'hostspec' => 'localhost',
   'database' => 'onm',
);


$ip='';
if (isset($GLOBALS['argv']) && count($GLOBALS['argv'])>0){
   for ($i=1;$i<count($GLOBALS['argv']);$i++){
		$datos=explode('=',$GLOBALS['argv'][$i]);
      if ($datos[0]=='ip'){
         $ip=str_replace("'","",$datos[1]);
      }
   }
}

if ($ip=='') {
	print "USO: $0 ip=a.b.c.d\n";
	exit;
}


print "ip >> $ip\n";
$db_params['password'] = chop(`cat /cfg/onm.conf | grep DB_PWD|cut -d "=" -f2 | tr -d ' '`);
if (connectDB($db_params)==1){ exit;}
update_ip($ip);

?>
