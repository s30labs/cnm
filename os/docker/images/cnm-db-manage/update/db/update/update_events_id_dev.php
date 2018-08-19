<?php
// Programa que actualiza el campo id_dev de la tabla events


// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");

function update_events_id_dev(){
   global $enlace;

	$a_ip_id_dev = array();
   $sql1="SELECT id_dev,ip FROM devices";
   $result1 = $enlace->query($sql1);
	while ($result1->fetchInto($r1)) $a_ip_id_dev[$r1['ip']]=$r1['id_dev'];

	foreach($a_ip_id_dev as $ip=>$id_dev){
   	$sqlUpdate="UPDATE events SET id_dev=$id_dev WHERE ip='$ip'";
   	$resultUpdate = $enlace->query($sqlUpdate);
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
update_events_id_dev();
?>
