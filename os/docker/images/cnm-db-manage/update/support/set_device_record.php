#!/usr/bin/php
<?php
  /*
	* **********************************************************************************
	* Script que permite actualizar la ficha de dispositivo de uno o todos los equipos.
	* Si se le pasa una IP como parametro actualiza dicha ip, en caso contrario actualiza todos
	* USO: update_pass.php [ip] 
	* **********************************************************************************
	*/

// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA LEER DATOS DE CONFIGURACION DE CNM
require ("/var/www/html/onm/inc/Store.php");



// --------------------------------------------------------------------------------
connectDB();

$IPS=Array();
if ($argc==2){ 
	array_push ($IPS, $argv[1]);
}
else {

	$sql="SELECT ip from devices";

	$result = $dbc->query($sql);
	if (@PEAR::isError($result)){
		print $result->getMessage()."\n";
		print $result->getCode()."\n";
		exit;
	}

	if(is_object($result)){
   	while ($result->fetchInto($r)){ 
			array_push ($IPS, $r['ip']); 
		}
	}
}

foreach ($IPS as $ip) {
	print 'Actualizando: ' . $ip . "\n";
	set_device_record($ip);
}
exit;


// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------
// --------------------------------------------------------------------------------

// --------------------------------------------------------------------------------
// Funcion: connectDB()
// Input:
// Output: 1 En caso de haber problemas
//         0 En caso de funcionar correctamente
// Funcion encargada de realizar la conexion con la BBDD e inicializar la variable
// global $dbc
// --------------------------------------------------------------------------------
function connectDB(){

// Variable que contendra la conexion con la BBDD una vez realizada
global $dbc;

// RUTA DEL FICHERO DE CONFIGURACION DE CNM
$cfg_file='/cfg/onm.conf';
// HASH CON LOS DATOS NECESARIOS PARA USAR LA BBDD
$db_data=array('DB_NAME'=>'','DB_USER'=>'','DB_PWD'=>'','DB_SERVER'=>'');

   // RELLENAMOS LOS DATOS DEL HASH ANTERIOR
   read_cfg_file($cfg_file,$db_data);
   $data = array(
      'phptype'  => 'mysql',
      'username' => $db_data['DB_USER'],
      'password' => $db_data['DB_PWD'],
      'hostspec' => $db_data['DB_SERVER'],
      'database' => $db_data['DB_NAME'],
   );
   // NOS CONECTAMOS A LA BBDD
   $dbc = @DB::Connect($data,TRUE);
   if (@PEAR::isError($dbc)) {
      // _debug("connectDB::ERROR.NO SE HA PODIDO REALIZAR LA CONEXION A LA BBDD. SE FINALIZA EL PROGRAMA");
      return 1;
      //exit;
   }else {
      // LOS DATOS DEVUELTOS POR LAS CONSULTAS A LA BBDD VIENEN EN FORMA DE HASH
      $dbc->setFetchMode(DB_FETCHMODE_ASSOC);
      //_debug("connectDB::Se abre la conexion con la BBDD");
      return 0;
   }
}

?>
