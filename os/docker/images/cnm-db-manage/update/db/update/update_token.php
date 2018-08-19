<?php
// Programa que actualiza el campo token de la tabla cfg_users


// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");
// CLASE NECESARIA PARA GENERAR EL TOKEN
require_once("/var/www/html/onm/inc/Store.php");

function update_token(){
	global $enlace;

	$sql="SELECT id_user,passwd FROM cfg_users";
	$result = $enlace->query($sql);
   while ($result->fetchInto($r)){
      $token = generateHash($r['passwd']);
		$sqlUpdate="UPDATE cfg_users SET token='$token' WHERE id_user={$r['id_user']}";
		// print $sqlUpdate."\n";
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
update_token();
?>
