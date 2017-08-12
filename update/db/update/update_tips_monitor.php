<?php
// Programa que actualiza el campo id_ref de la tabla tips para las entradas de monitores. Hasta ahora en este campo se metía el id_alert_type del monitor pero ahora se va a meter el campo monitor.


// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");

/*
mysql> select id_tip,id_ref from tips WHERE tip_type='id_alert_type';
+--------+--------+
| id_tip | id_ref |
+--------+--------+
|   1673 | 1      |
|   1711 | 2      |
|   1712 | 3      |
|   1713 | 4      |
|   1720 | 5      |
|   1772 | 9      |
|   1737 | 6      |
|   1738 | 7      |
|   1765 | 8      |
|   1773 | 10     |
|   1774 | 11     |
|   1775 | 12     |
|   1776 | 13     |
|   1777 | 14     |
|   1778 | 15     |
|   1779 | 16     |
|   1780 | 17     |
|   1945 | 18     |
+--------+--------+
18 rows in set (0.00 sec)
*/
function update_tips_monitor(){
	global $enlace;

	$sql="SELECT id_alert_type,monitor FROM alert_type";
	$result = $enlace->query($sql);
 	while ($result->fetchInto($r)){
		$id_alert_type = $r['id_alert_type'];
		$monitor       = $r['monitor'];

		$sql1 = "UPDATE tips SET id_ref='$monitor' WHERE id_ref='$id_alert_type' AND tip_type='id_alert_type'";
		$result1 = $enlace->query($sql1);
		if (@PEAR::isError($result1)){
			print"ERROR: ".$result->getMessage()."\n";
		}
	}

   if (@PEAR::isError($result)) {
      print"ERROR: ".$result->getMessage()."\n";
      exit;
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
update_tips_monitor();
?>
