<?php
// Programa que modifica la estructura de la tabla prov_template_metrics2iid de la BBDD de CNM

// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");




// Funcion: update_prov_template_metrics2iid()
// Input:
// Output:
// Descripcion: Funcion que:
// 				1. introduce el campo hiid
//					2. rellena el campo hiid
//					3. cambia la clave a (id_template_metric,hiid)
// 				4. cambia el tipo del campo iid a text
function update_prov_template_metrics2iid(){
global $enlace;

	// 1. Se introduce el campo hiid
	$sql="ALTER TABLE prov_template_metrics2iid DROP hiid";
   $result = $enlace->query($sql);

	$sql="ALTER TABLE prov_template_metrics2iid ADD hiid varchar(32) collate utf8_spanish_ci NOT NULL default 'none'";
	$result = $enlace->query($sql);
	if (@PEAR::isError($result)) {
		print"ERROR AL INTRODUCIR EL CAMPO hiid: ".$result->getMessage()." (Existe ????)\n";
		//Si en la tabla ya existe el campo hiid puede que nos interese seguir ejecutando el script
		//exit;
	} 
	
	// 2. Se rellena el campo hiid
	$sql="SELECT id_tm2iid,iid FROM prov_template_metrics2iid";
   $result = $enlace->query($sql);
	if (@PEAR::isError($result)) {
      print"ERROR AL RELLENAR EL CAMPO hiid : ".$result->getMessage()."\n";
      exit;
   }
   while ($result->fetchInto($r)){
		$longitud_hash=20;
		$hiid=substr(md5($r['iid']),0,$longitud_hash);
		$id_tm2iid=$r['id_tm2iid'];
      $sqlUpdate="UPDATE prov_template_metrics2iid SET hiid='$hiid' WHERE id_tm2iid=$id_tm2iid";
      $resultUpdate = $enlace->query($sqlUpdate);
   }

	// 3. Se cambia la clave a (id_template_metric,hiid)
   $sql="ALTER TABLE prov_template_metrics2iid drop PRIMARY KEY";
   $result = $enlace->query($sql);
	if (@PEAR::isError($result)) {
      print"ERROR AL QUITAR LA CLAVE PRIMARIA\n";
      // exit;
   }
   $sql="ALTER TABLE prov_template_metrics2iid ADD PRIMARY KEY (id_template_metric,hiid)";
   $result = $enlace->query($sql);
	if (@PEAR::isError($result)) {
      print"ERROR AL PONER LA NUEVA CLAVE PRIMARIA\n";
      // exit;
   }

	// 4. Se cambia el tipo del campo iid a text
	$sql="ALTER TABLE prov_template_metrics2iid CHANGE iid iid text";
   $result = $enlace->query($sql);
	if (@PEAR::isError($result)) {
      print"ERROR AL CAMBIAR DEL TIPO EL CAMPO IID\n";
      exit;
   }
}

// PROGRAMA PRINCIPAL
global $enlace;
if (connectDB()==1){	exit;}
update_prov_template_metrics2iid();
?>
