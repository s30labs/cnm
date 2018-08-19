<?php
// Programa que rellena el campo type de alert_type

// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");




// Funcion: update_alert_type_type()
// Input:
// Output:
// Descripcion: Funcion que rellena el campo class de la tabla alert_type
function update_alert_type_type(){
global $enlace;

	$a_snmp = array();
   print "SE VAN A ACTUALIZAR LOS MONITORES DE TIPO SNMP\n";
	$sql="SELECT a.subtype,b.class FROM alert_type a, cfg_monitor_snmp b WHERE a.type='snmp' AND a.subtype=b.subtype";
	$result = $enlace->query($sql);
   if (@PEAR::isError($result)) {
      print"ERROR AL OBTENER LOS DATOS DE MONITORES SNMP: ".$result->getMessage()."\n";
      exit;
   }
   while ($result->fetchInto($r)) $a_snmp[$r['subtype']]=$r['class'];

	foreach($a_snmp as $subtype=>$class){
		$sql="UPDATE alert_type SET class='$class' WHERE subtype='$subtype'";
	   $result = $enlace->query($sql);
		// print "$sql\n";
	}
	
	$a_icmp = array();
   print"SE VAN A ACTUALIZAR LOS MONITORES DE TIPO LATENCY\n";
   $sql="SELECT a.subtype,b.subtype AS class FROM alert_type a, cfg_monitor b WHERE a.type='latency' AND a.subtype=b.monitor";
   $result = $enlace->query($sql);
   if (@PEAR::isError($result)) {
      print"ERROR AL OBTENER LOS DATOS DE MONITORES LATENCY: ".$result->getMessage()."\n";
      exit;
   }
   while ($result->fetchInto($r)) $a_icmp[$r['subtype']]=$r['class'];

   foreach($a_icmp as $subtype=>$class){
      $sql="UPDATE alert_type SET class='$class' WHERE subtype='$subtype'";
      $result = $enlace->query($sql);
		// print "$sql\n";
   }

   print"SE VAN A ACTUALIZAR LOS MONITORES DE TIPO XAGENT\n";
	$sql="UPDATE alert_type SET class='-' WHERE type='xagent'";
	// print "$sql\n";
	$result = $enlace->query($sql);
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
if (connectDB($db_params)==1){exit;}
update_alert_type_type();
?>
