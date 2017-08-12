<?php
// Programa que modifica la estructura de la tabla cfg_remote_alerts de la BBDD de CNM

// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");




// Funcion: hiid_cfg_remote_alerts
// Input:
// Output:
// Descripcion:
function hiid_cfg_remote_alerts(){
global $enlace;

   // Se rellena el campo hiid
   $sql="SELECT id_remote_alert FROM cfg_remote_alerts";
   $result = $enlace->query($sql);
   if (@PEAR::isError($result)) {
      print"ERROR AL RELLENAR EL CAMPO hiid : ".$result->getMessage()."\n";
      exit;
   }
   while ($result->fetchInto($r)){
      $id_remote_alert = $r['id_remote_alert'];
      $expr_str = '';
      $sql2 = "SELECT v,descr,fx,expr FROM cfg_remote_alerts2expr WHERE id_remote_alert=$id_remote_alert";
      $result2 = $enlace->query($sql2);
      while ($result2->fetchInto($r2)) $expr_str.=$r2['v'].$r2['fx'].$r2['expr'];
      $hiid=substr(md5($expr_str),0,10);
		//print "EXPR_STR = $expr_str\n";
		//print "HIID = $hiid\n";
      $sql3="UPDATE id_remote_alert SET hiid='$hiid' WHERE id_remote_alert=$id_remote_alert";
      $result3 = $enlace->query($sql3);
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
hiid_cfg_remote_alerts();
?>
