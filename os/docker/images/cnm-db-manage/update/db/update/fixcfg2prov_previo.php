<?php
// Programa que modifica la estructura de la BBDD de CNM


// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");
require_once("/var/www/html/onm/inc/Store.php");



global $enlace;
if (connectDB()==1){
	print "ERROR en acceso a DB\n";
  	exit;
}
global $dbc;
$dbc=$enlace;

//----------------------------------------------


$sql="SELECT id_dev FROM devices";
$result = $enlace->query($sql);
$DATA=Array();
while ($result->fetchInto($r)){

	$id_dev=$r['id_dev'];
	array_push($DATA,$id_dev);
   $sql1="INSERT INTO devices_custom_data (id_dev) VALUES ($id_dev)";
   $result1 = $dbc->query($sql1);
}
print "HAY QUE EJECUTAR !!!!:\n".'/opt/crawler/bin/plite '.implode (',', $DATA)."\n" ;

//----------------------------------------------


$sql="SELECT id FROM devices_custom_types";
$result = $enlace->query($sql);
$DATA=Array();
while ($result->fetchInto($r)){
   $id=$r['id'];
   $sql1="UPDATE devices_custom_data SET columna$id = '-' WHERE columna$id = ''";
   $result1 = $dbc->query($sql1);
}

