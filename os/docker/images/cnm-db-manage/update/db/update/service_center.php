#!/usr/bin/php
<?php
// Programa que inserta en BBDD las tablas extra_sc_level y extra_sc_contact para usarse en el service center

// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");
// MODULO QUE CONTIENE LOS DATOS DE LAS TABLAS
require_once('/update/db/Init/DB-Scheme-Init-custom_servicecenter.php');

$DBScheme = array(
   'extra_sc_level'=>array( //Tabla extra_sc_level
      'id_sc_level'=>"int(11) NOT NULL auto_increment",
      'field1'=>"varchar(255) collate utf8_spanish_ci NOT NULL default ''",
      'field2'=>"varchar(255) collate utf8_spanish_ci NOT NULL default ''",
      'field3'=>"varchar(255) collate utf8_spanish_ci NOT NULL default ''",
      'field4'=>"varchar(255) collate utf8_spanish_ci NOT NULL default ''",
      'PRIMARY KEY  (`id_sc_level`)'=>'',
   ),
   'extra_sc_contact'=>array( //Tabla extra_sc_contact
      'id_sc_contact'=>"varchar(255) collate utf8_spanish_ci NOT NULL",
      'contact'=>"varchar(255) collate utf8_spanish_ci NOT NULL",
      'PRIMARY KEY  (`id_sc_contact`)'=>'',
   ),
);

$DBExcepcion = array(
   'devices_custom_data',
);

$DBData = array(
   'extra_sc_level'=>$CFG_SERVICECENTER,
   'extra_sc_contact'=>$CFG_SERVICECENTER_CONTACT,
);


   $db_params=array(
      'phptype'  => 'mysql',
      'username' => 'onm',
      'hostspec' => 'localhost',
      'database' => 'onm',
   );
	$db_params['password'] = chop(`cat /cfg/onm.conf | grep DB_PWD|cut -d "=" -f2 | tr -d ' '`);
	// 1. Se crean las tablas
	$rc_connectDB=connectDB($db_params);
   foreach ($DBScheme as $nombreTablaEst => $contenidoTablaEst){
      _addTable($nombreTablaEst,$contenidoTablaEst);
   }

	// 2. Se cargan los datos en las tablas
   foreach ($DBData as $nombreTabla => $valores){
   	// CASO EN EL QUE LA TABLA NO EXISTE
      $PK=array();
      foreach ($DBScheme[$nombreTabla] as $nombreCampo => $definicionCampo){
         // if (ereg('PRIMARY KEY',$nombreCampo)){
			if (strpos($nombreCampo,'PRIMARY KEY')!==false){		
				$aux=explode('`',$nombreCampo);
            foreach ($aux as $aux_pk){
               // if (($aux_pk!=',')and($aux_pk!='(')and($aux_pk!=')')and(!ereg('PRIMARY KEY',$aux_pk))){
					if (($aux_pk!=',')and($aux_pk!='(')and($aux_pk!=')')and(strpos($aux_pk,'PRIMARY KEY')===false)){
                  $PK[]=$aux_pk;
               }
            }
         }
      }
      _DataInitTable($nombreTabla,$valores,$PK,'');
   }
?>
