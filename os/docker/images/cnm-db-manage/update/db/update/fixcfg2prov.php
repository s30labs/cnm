<?php
// Programa que modifica la estructura de la BBDD de CNM


// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");
require_once("/var/www/html/onm/inc/Store.php");



#mysql> select range,type,subtype,monitor,active_iids  from cfg_assigned_metrics where (range not like '.%' and range not like '*');;
#+-----------------+---------+---------------------+---------------------+-------------+
#| range           | type    | subtype             | monitor             | active_iids |
#+-----------------+---------+---------------------+---------------------+-------------+
#| 10.1.254.252    | snmp    | cisco_wap_users     | NULL                | all         |
#| 10.1.254.252    | snmp    | cisco_wap_users     | s_cisco_wap_users_1 | all         |
#| 195.77.15.133   | latency | w_mon_ssh-f1282942  | NULL                | all         |
#| 62.22.38.24     | latency | w_mon_ssh-f1282942  | NULL                | all         |
#| 212.9.92.110    | latency | w_mon_ssh-f1282942  | NULL                | all         |
#| 194.140.160.227 | latency | w_mon_ssh-f1282942  | NULL                | all         |
#| 10.1.254.232    | latency | w_mon_http-9c7f4a4b | NULL                | all         |
#| 10.1.254.228    | latency | w_mon_http-06c58efa | NULL                | all         |
#| 10.1.254.229    | latency | w_mon_http-dcfceb00 | NULL                | all         |
#| 10.1.254.228    | latency | w_mon_dns-a2b0317f  | NULL                | all         |
#| 10.1.254.200    | latency | w_mon_http-4c7030a8 | NULL                | all         |
#| 10.1.254.228    | snmp    | disk_mibhost        | s_disk_mibhost_2    | 4           |
#+-----------------+---------+---------------------+---------------------+-------------+


global $enlace;
if (connectDB()==1){
	print "ERROR en acceso a DB\n";
  	exit;
}
global $dbc;
$dbc=$enlace;

$sql="SELECT range,type,subtype,monitor,active_iids FROM cfg_assigned_metrics
		WHERE (range not like '.%' and range not like '*')";
$result = $enlace->query($sql);
while ($result->fetchInto($r)){

	$DATA=Array();
	# range es la ip del dispositivo
	# campo range de cfg_assigned_metrics
   $DATA['range']=$r['range'];
	if ($DATA['range'] == '') { 
		print "ERROR. NO TENGO IP\n";
		continue;
	}
	$n=strstr($r['range'],",");
	if ($n!==FALSE) {
      print "ERROR. TENGO VARIAS IP\n";
      continue;
   }
	
   $DATA['lapse']=300;
   $DATA['type']=$r['type'];
   if ($DATA['type'] == '') {
      print "ERROR. NO TENGO TIPO\n";
      continue;
   }

   $DATA['subtype']=$r['subtype'];
	# es el watch o monitor
   $DATA['monitor']=$r['monitor'];
	// SSV: Se hace el siguiente cambio ya que $DATA['active_iids'] contiene un array con todos los iids
	// $DATA['active_iids']=$r['active_iids'];
	$DATA['active_iids']=explode(',',$r['active_iids']);
;
   //$DATA['active_iids_str'];

print ">>prov ".$DATA['range']."\n";
print_r($DATA);
	store_prov_template_metrics($DATA);

}


//----------------------------------------------


#$sql="SELECT id_dev FROM devices";
#$result = $enlace->query($sql);
#$DATA=Array();
#while ($result->fetchInto($r)){
#	array_push($DATA,$r['id_dev']);
#}
#print "\n".'/opt/crawler/bin/plite '.implode (',', $DATA)."\n" ;

