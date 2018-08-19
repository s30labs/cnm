<?php
// Programa que modifica la estructura de la BBDD de CNM


// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");

function update_id_dest(){
	global $enlace;

	$sql="SELECT id_template_metric,id_dev FROM prov_template_metrics";
	$result = $enlace->query($sql);
   while ($result->fetchInto($r)){
		$sqlUpdate="UPDATE prov_template_metrics SET id_dest={$r['id_dev']} WHERE id_template_metric={$r['id_template_metric']}";
		$resultUpdate = $enlace->query($sqlUpdate);
	}
}

// PROGRAMA PRINCIPAL
global $enlace;
if (connectDB()==1){
	exit;
}
update_id_dest();
?>
