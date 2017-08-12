<?php
// Programa que actualiza el campo token de la tabla cfg_users


// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");
// CLASE NECESARIA PARA GENERAR EL TOKEN
//require_once("/var/www/html/onm/inc/Store.php");

function update_cfg_app2device(){
	global $enlace;

	//$sql="INSERT INTO cfg_app2device (SELECT a.aname,d.ip,d.id_dev,0 FROM prov_default_apps2device p, devices d, cfg_monitor_apps a WHERE p.id_dev=d.id_dev and p.id_monitor_app=a.id_monitor_app)";
	$sql="SELECT a.aname,d.ip,d.id_dev FROM prov_default_apps2device p, devices d, cfg_monitor_apps a WHERE p.id_dev=d.id_dev and p.id_monitor_app=a.id_monitor_app";
	$result = $enlace->query($sql);
 	while ($result->fetchInto($r)){

		$aname=$r['aname'];
		$ip=$r['ip'];
		$id_dev=$r['id_dev'];

		$sql1 = "INSERT INTO cfg_app2device (aname,ip,id_dev,who) VALUES ('$aname','$ip',$id_dev,0) ON DUPLICATE KEY UPDATE aname='$aname', ip='$ip', id_dev=$id_dev, who=0";
		$result1 = $enlace->query($sql1);
		if (@PEAR::isError($result1)){
			print"ERROR: ".$result->getMessage()."\n";
		}
	}

   if (@PEAR::isError($result)) {
      print"ERROR: ".$result->getMessage()."\n";
      exit;
   }

}

// PROGRAMA PRINCIPAL
global $enlace;
$db_params=array(
   'phptype'  => 'mysql',
   'username' => 'onm',
   'hostspec' => 'localhost',
   'database' => 'onm',
);
$db_params['password'] = chop(`cat /cfg/onm.conf | grep DB_PWD|cut -d "=" -f2 | tr -d ' '`);
if (connectDB($db_params)==1){ exit;}
update_cfg_app2device();
?>
