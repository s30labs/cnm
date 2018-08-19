<?php
// Programa que modifica la estructura de la tabla devices_custom_data de la BBDD de CNM

// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");




// Funcion: update_devices_custom_data()
// Input:
// Output:
// Descripcion: Funcion que cambia el tipo de los campos de devices_custom_data a varchar(255)
function update_devices_custom_data(){
global $enlace;

	$a_field = array();

   print"SE VAN A OBTENER LOS CAMPOS DE devices_custom_data\n";
	$sql="SHOW columns FROM devices_custom_data WHERE Field like '%columna%'";
   $result = $enlace->query($sql);
   if (@PEAR::isError($result)) {
      print"ERROR AL OBTENER LOS CAMPOS DE devices_custom_data: ".$result->getMessage()."\n";
      exit;
   }
   print"SE HAN OBTENIDO LOS CAMPOS DE devices_custom_data CORRECTAMENTE\n";
   while ($result->fetchInto($r)) $a_field[]=$r['Field'];
	// print_r($a_field);

   print"SE VA A ACTUALIZAR LA TABLA devices_custom_data\n";

	foreach($a_field as $field){
		$sql = "ALTER TABLE devices_custom_data change $field $field varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default '-'";
   	$result = $enlace->query($sql);
   	if (@PEAR::isError($result)) {
	      print"ERROR AL ACTUALIZAR EL CAMPO $field. SQL = $sql. FALLO: ".$result->getMessage()."\n";
	   }
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
if (connectDB($db_params)==1)exit;
update_devices_custom_data();
?>
