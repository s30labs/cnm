<?php
// Programa que modifica la estructura de la BBDD de CNM


// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");

// FUNCION QUE MODIFICA LA TABLA ALERTS_STORE_
function update_alerts_store(){
	global $enlace;
	
	// Se rellena el campo id_ticket de alerts_store
	$sql="SELECT id_ticket,id_alert,id_dev from ticket";
	$result = $enlace->query($sql);
   if (@PEAR::isError($result)) {
		return 1;
   }
	$rc=0;
	while ($result->fetchInto($r)){
		$sql_update="UPDATE alerts_store SET id_ticket={$r['id_ticket']} WHERE id_alert={$r['id_alert']} and id_device={$r['id_dev']}";
		print $sql_update."\n";
		$result_update=$enlace->query($sql_update);
		if (@PEAR::isError($result_update)) {
    	  $rc=1;
	   }
	}	

   // Se rellena el campo label de alerts_store (nos basamos en metricas)
   $sql="SELECT name,label,id_dev from metrics";
   $result = $enlace->query($sql);
   if (@PEAR::isError($result)) {
      return 1;
   }
   $rc=0;
   while ($result->fetchInto($r)){
      $sql_update="UPDATE alerts_store SET label='{$r['label']}' WHERE mname='{$r['name']}' and id_device={$r['id_dev']}";
      print $sql_update."\n";
      $result_update=$enlace->query($sql_update);
      if (@PEAR::isError($result_update)) {
        $rc=1;
      }
   }

   // Se rellena el campo label de alerts_store (nos basamos en alertas remotas)
   $sql="SELECT subtype,label from cfg_remote_alerts";
   $result = $enlace->query($sql);
   if (@PEAR::isError($result)) {
      return 1;
   }
   $rc=0;
   while ($result->fetchInto($r)){
      $sql_update="UPDATE alerts_store SET label='{$r['label']}' WHERE mname='{$r['subtype']}'";
      print $sql_update."\n";
      $result_update=$enlace->query($sql_update);
      if (@PEAR::isError($result_update)) {
        $rc=1;
      }
   }


	// Se limpian las alertas del historico de alertas que no tienen metrica asociada
	$sql2="SELECT id_alert FROM alerts_store WHERE mname NOT IN (SELECT name FROM metrics) AND mname NOT IN (SELECT subtype FROM cfg_remote_alerts)";
	// Se limpian las alertas del historico de alertas que no tienen dispositivo asociado
	$sql3="SELECT id_alert FROM alerts_store WHERE id_device NOT IN (SELECT id_dev FROM devices)";






	return $rc;
}

// PROGRAMA PRINCIPAL
global $enlace;
if (connectDB()==1){
	exit;
}
$rc_alerts_store=update_alerts_store();



?>
