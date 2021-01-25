<?php
ini_set('memory_limit','1024M');
set_include_path('.:/usr/share/php:/usr/share/pear:/var/www/html/onm/inc:/opt/php-utils');

// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA LEER DATOS DE CONFIGURACION DE CNM
require_once('/update/db/DB-Scheme-Lib.php');
//require_once '/var/www/html/onm/inc/progress_bar/Manager.php';
//require_once '/var/www/html/onm/inc/progress_bar/Registry.php';
require_once 'progress_bar/Manager.php';
require_once 'progress_bar/Registry.php';

/*
CREATE TABLE `oid_tree` (
  `oid_n` varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default '',
  `oid_n_parent` varchar(255) character set utf8 collate utf8_spanish_ci NOT NULL default '',
  `oid_s` text character set utf8 collate utf8_spanish_ci NOT NULL default '',
  PRIMARY KEY  (`oid_n`)
)
*/

	my_connectDB();
	updateOID();

	function my_connectDB(){

		// Variable que contendra la conexion con la BBDD una vez realizada
		global $enlace;

		$cred = get_db_credentials();
//print_r($cred);

	   $data = array(
	      'phptype'  => 'mysqli',
	      'username' => 'onm',
	      'password' => $cred["CNM_DB_PASSWORD"],
	      'hostspec' => $cred["CNM_DB_SERVER"],
	      'database' => 'onm',
	   );


	   // NOS CONECTAMOS A LA BBDD
	   $enlace = @DB::Connect($data,TRUE);
	   if (@PEAR::isError($enlace)) {
	      echo("UPDATE OIDs : CONNECT [ERROR]");
	      exit;
	   }else {
	      // LOS DATOS DEVUELTOS POR LAS CONSULTAS A LA BBDD VIENEN EN FORMA DE HASH
	      $enlace->setFetchMode(DB_FETCHMODE_ASSOC);
	      echo ("UPDATE OIDs : CONNECT [OK]\n");
	
	      // SE MANEJAN LOS DATOS CON CODIFICACION UTF-8
	      $query  = "SET CHARACTER SET 'utf8'";
	      $result = $enlace->query($query);
	   }
	}

	function updateOID(){
		global $enlace;

	   $cmd_n="export MIBS='ALL'; /usr/bin/snmptranslate -To";
	   $cmd_s="export MIBS='ALL'; /usr/bin/snmptranslate -Ts";

	   exec($cmd_n,$a_oid_n);
	   exec($cmd_s,$a_oid_s);

		$num_oids = count($a_oid_n);
		$step = 50;

	   $values = '';
	   $sep_values = '';
		$init_i = 1;
		$progressBar = new \ProgressBar\Manager(0, $num_oids);
	   for ($i=0;$i<$num_oids;$i++){
			if( (($i+1)%$step)!=0 AND $i<count($a_oid_n)){
	         $strrpos = strrpos($a_oid_n[$i],'.');
	         $oid_n_parent = substr($a_oid_n[$i],0,$strrpos);
	
	         $strrpos = strrpos($a_oid_s[$i],'.');
	         $oid_s_last = substr($a_oid_s[$i],$strrpos+1);

	         $values.=$sep_values."('{$a_oid_n[$i]}','$oid_s_last','$oid_n_parent')";
				$sep_values = ',';
			}
			else{
				// print "INSERT DE $init_i a $i de $num_oids\n";
		      $sqlQuery = "INSERT INTO oid_tree (oid_n,oid_s,oid_n_parent) VALUES $values ON DUPLICATE KEY UPDATE oid_s = VALUES(oid_s),oid_n_parent = VALUES(oid_n_parent)";
         	// print "$sqlQuery\n";
		   	$result=$enlace->query($sqlQuery);
	         if (@PEAR::isError($result)) {
	            echo("No se ha podido insertar los datos en la BBDD,MSG==".$result->getMessage().",SQL==$sqlQuery\n");
	            //exit;
	         }

	   		$values = '';
				$sep_values = '';
				$init_i = $i+1;
    			$progressBar->update($i);
			}
		}	
		if($values!=''){
         // print "INSERT DE $init_i a $i de $num_oids\n";
         $sqlQuery = "INSERT INTO oid_tree (oid_n,oid_s,oid_n_parent) VALUES $values ON DUPLICATE KEY UPDATE oid_s = VALUES(oid_s),oid_n_parent = VALUES(oid_n_parent)";
         // print "$sqlQuery\n";
         $result=$enlace->query($sqlQuery);
         if (@PEAR::isError($result)) {
            echo("No se ha podido insertar los datos en la BBDD,MSG==".$result->getMessage().",SQL==$sqlQuery\n");
            //exit;
         }

         $values = '';
         $sep_values = '';
         $init_i = $i+1;
    		$progressBar->update($i);
		}
	   echo("UPDATE OIDs : DONE [OK]\n");

/*
			$strrpos = strrpos($a_oid_n[$i],'.');
			$oid_n_parent = substr($a_oid_n[$i],0,$strrpos);

			$strrpos = strrpos($a_oid_s[$i],'.');
			$oid_s_last = substr($a_oid_s[$i],$strrpos+1);

	      $values=" ('{$a_oid_n[$i]}','$oid_s_last','$oid_n_parent')";
         // $sqlQuery = "INSERT INTO oid_tree (oid_n,oid_s,oid_n_parent) VALUES $values ON DUPLICATE KEY UPDATE oid_n='{$a_oid_n[$i]}', oid_s='$oid_s_last', oid_n_parent='$oid_n_parent'";
         $sqlQuery = "INSERT INTO oid_tree (oid_n,oid_s,oid_n_parent) VALUES $values";

			echo "ELEMENTO: $i\n";
         // print "$sqlQuery\n";
		   $result=$enlace->query($sqlQuery);
			if (@PEAR::isError($result)) {
	      	//echo("No se ha podido insertar los datos en la BBDD,MSG==".$result->getMessage().",SQL==$sqlQuery\n");
		      //exit;
				echo $values."\n";
		   }

		}
		
	   echo("UPDATE OIDs : DONE [OK]\n");
*/

/*
		// Detectar OIDs duplicados
		$a_aux_a_oid_n=array_count_values($a_oid_n);
		foreach($a_aux_a_oid_n as $oid_n => $count){
			if($count>1){
				print $oid_n."\n";
				$a_pos=array_keys($a_oid_n, $oid_n);
				foreach($a_pos as $pos) print $a_oid_s[$pos]."\n";
				print "----------------------------------\n";
			}
		}

      $a_aux_a_oid_s=array_count_values($a_oid_s);
      foreach($a_aux_a_oid_s as $oid_s => $count){
         if($count>1){
				print $oid_s."\n";
            $a_pos=array_keys($a_oid_s, $oid_s);
            foreach($a_pos as $pos) print $a_oid_n[$pos]."\n";
            print "----------------------------------\n";
			}
      }
*/

	}
?>
