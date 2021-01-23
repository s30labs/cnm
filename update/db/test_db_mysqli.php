<?php

require_once('/usr/share/pear/DB.php');

   $db_params=array(
      'phptype' => 'mysqli',
      'username' => 'onm',
      'password' => 'onm1234',
      'hostspec' => 'localhost',
		'database' => 'cnm',
   );



   $enlace = @DB::Connect($db_params,TRUE);
 	print "\n>>>>>>>>>>>>>>>LA BBDD ES: {$db_params['database']}----\n";

   if (@PEAR::isError($enlace)) {
      print("Conexion BBDD [NOOK] phptype=>{$db_params['phptype']} username=>{$db_params['username']} password=>{$db_params['password']} hostspec=>{$db_params['hostspec']} database=>{$db_params['database']} || USERINFO = ".$enlace->getUserInfo()."\n");
      exit;
   }

   // LOS DATOS DEVUELTOS POR LAS CONSULTAS A LA BBDD VIENEN EN FORMA DE HASH
   $enlace->setFetchMode(DB_FETCHMODE_ASSOC);
   if(! array_key_exists('database',$db_params)) $db_params['database']='';
   print("Conexion BBDD [OK] phptype=>{$db_params['phptype']} username=>{$db_params['username']} password=>{$db_params['password']} hostspec=>{$db_params['hostspec']} database=>{$db_params['database']}\n");

   // SE MANEJAN LOS DATOS CON CODIFICACION UTF-8
   $query  = "SET CHARACTER SET 'utf8'";
   $result = $enlace->query($query);

   //mysqli
   $link = $enlace = mysqli_connect($db_params['hostspec'], $db_params['username'], $db_params['password'], $db_params['database']);


   $result=$enlace->query("SELECT * FROM cfg_cnms");
   if (@PEAR::isError($result)) {
		print ("No se ha podido obtener la informacion de los cnms en la BBDD cnm\n");
       exit;
   }else{
      print ("Se ha obtenido la informacion de los cnms de la BBDD cnm\n");
      while($result->fetchInto($r)){

			print_r($r);

      }
   }


?>
