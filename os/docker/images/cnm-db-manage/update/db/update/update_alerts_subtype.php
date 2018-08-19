<?php
// Programa que actualiza el campo subtype de las tablas alerts/alerts_store


// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");
// CLASE NECESARIA PARA GENERAR EL TOKEN
//require_once("/var/www/html/onm/inc/Store.php");

function update_subtype(){
	global $enlace;

	$sqlUpdate="UPDATE alerts_store SET subtype=mname WHERE subtype=''";
	$resultUpdate = $enlace->query($sqlUpdate);

	$sqlUpdate="UPDATE alerts SET subtype=mname WHERE subtype=''";
	$resultUpdate = $enlace->query($sqlUpdate);
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
update_subtype();
?>
