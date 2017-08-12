<?php
// Programa que modifica la estructura de la tabla cfg_register_transports de la BBDD de CNM

// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");




// Funcion: update_cfg_register_transports()
// Input:
// Output:
// Descripcion: Funcion que:
function update_cfg_register_transports(){
global $enlace;

	$a_transport = array();

   print"SE VAN A OBTENER LOS DATOS DE cfg_notifications\n";
	// 1. Se obtienen todos los destinos definidos en la BBDD en el formato antiguo
	$sql="SELECT destino,id_notification_type FROM cfg_notifications";
   $result = $enlace->query($sql);
   if (@PEAR::isError($result)) {
      print"ERROR AL OBTENER LOS DATOS DE cfg_notifications: ".$result->getMessage()."\n";
      exit;
   }
   print"SE HAN OBTENIDO LOS DATOS DE cfg_notifications CORRECTAMENTE\n";
   while ($result->fetchInto($r)){
		$aux_destino = $r['destino'];
		$id_notification_type = $r['id_notification_type'];

		if(strpos($aux_destino,';')===false AND $aux_destino!=''){
			$destino = trim($aux_destino);
         if($destino=='') continue;
         $a_transport[$destino]=$id_notification_type;
		}
		else{
			$a_aux_destino = explode(';',$aux_destino);
			foreach($a_aux_destino as $destino){
				$destino = trim($destino);
				if($destino=='') continue;
				$a_transport[$destino]=$id_notification_type;
			}
		}
   }
	// print_r($a_transport);

   print"SE VA A ACTUALIZAR LA TABLA cfg_register_transports\n";

	foreach($a_transport as $dest=>$type){
		$sql = "INSERT INTO cfg_register_transports (id_notification_type,name,value) VALUES ($type,'$dest','$dest')";
   	$result = $enlace->query($sql);
	}
}

function	update_cfg_notification2transport(){
global $enlace;

	$a_register_transports = array();
	$a_cfg_notification2transport = array();

	// $sql = "SELECT id_register_transport,name FROM cfg_register_transports";
	$sql = "SELECT id_register_transport,value as name FROM cfg_register_transports";
  	$result = $enlace->query($sql);
   while ($result->fetchInto($r)) $a_register_transports[$r['name']] = $r['id_register_transport'];
	
	foreach ($a_register_transports as $name=>$id){
		$sql = "SELECT id_cfg_notification FROM cfg_notifications WHERE destino LIKE '%$name%'";
   	$result = $enlace->query($sql);
		while ($result->fetchInto($r)) $a_cfg_notification2transport[$id][]=$r['id_cfg_notification'];
	}
	// print_r($a_cfg_notification2transport);
	foreach ($a_cfg_notification2transport as $id_register_transport => $a_id_cfg_notification){
		foreach ($a_id_cfg_notification as $id_cfg_notification){
			// print "ID_REGISTER_TRANSPORT == $id_register_transport || ID_CFG_NOTIFICATION == $id_cfg_notification\n";
			$sql = "INSERT INTO cfg_notification2transport (id_register_transport,id_cfg_notification) VALUES ($id_register_transport,$id_cfg_notification)";
   		$result = $enlace->query($sql);
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
if (connectDB($db_params)==1){	exit;}
update_cfg_register_transports();
update_cfg_notification2transport();
?>
