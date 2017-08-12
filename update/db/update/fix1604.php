<?php
// --------------------------------------------------------------------------
// Programa para arreglar el campo id_dest en la tabla prov_template_metrics.
// Obtiene los valores con id_dest=0 y los actualiza a id_dev.
// Los casos que no pueda actualizar porque ya exista id_dest=id_dev los registra.
// Esos casos hay que resolverlos teniendo en cuenta que:
// 1. Hay que respetar los monitores ya asociados en prov_template_metrics2iid
// 2. 
// --------------------------------------------------------------------------

// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");


// PROGRAMA PRINCIPAL
global $enlace;
if (connectDB()==1){
   exit;
}
$rc_alerts_store=update_prov_template_metrics();


// FUNCION QUE MODIFICA LA TABLA ALERTS_STORE_
function update_prov_template_metrics(){
	global $enlace;
	
	$sql="SELECT id_template_metric,id_dev,lapse,type,subtype,id_dest from prov_template_metrics where id_dest=0";
	$result = $enlace->query($sql);
   if (@PEAR::isError($result)) {
		return 1;
   }
	$rc=0;
	while ($result->fetchInto($r)){
		$sql_update="UPDATE prov_template_metrics SET id_dest={$r['id_dev']} WHERE id_template_metric={$r['id_template_metric']}";
		//print $sql_update."\n";
		$result_update=$enlace->query($sql_update);
		if (@PEAR::isError($result_update)) {
			print "**ERROR** {$r['id_template_metric']};{$r['id_dev']};{$r['lapse']};{$r['type']};{$r['subtype']};{$r['id_dest']}\n";
    	  $rc=1;

			fix1($r['id_template_metric'],$r['id_dev'],$r['subtype']);
	   }
		else {
			print "**  OK ** {$r['id_template_metric']};{$r['id_dev']};{$r['lapse']};{$r['type']};{$r['subtype']};{$r['id_dest']}\n";
		}
	}	

	return $rc;
}



function fix1($id_template_metric,$id_dev,$subtype){
   global $enlace;

	$sql="SELECT id_template_metric from prov_template_metrics where id_dev=$id_dev and subtype='$subtype'";
   $result = $enlace->query($sql);
   if (@PEAR::isError($result)) {
      print "**ERROR**  en SQL=$sql\n";
   }
   $rc=0;
   while ($result->fetchInto($r)){
		if ($id_template_metric == $r['id_template_metric']) { next; }
		$sql="SELECT count(*) as c from prov_template_metrics2iid where id_template_metric={$r['id_template_metric']}";
		$result->fetchInto($r);
		if ($r['c'] == 0) {
			print "\t** SOLUCION** BORRAR id_template_metric={$r['id_template_metric']} de prov_template_metrics\n";
		}
		else { print "\t **REVISAR** id_template_metric={$r['id_template_metric']} de prov_template_metrics\n"; }
	}
}


?>
