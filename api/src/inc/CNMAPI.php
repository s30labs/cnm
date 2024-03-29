<?php

include_once('inc/Store.php');
include_once('inc/CNMUtils.php');
require_once('/usr/share/pear/DB.php');

//define("LOG_PREFIX", "cnm-api");

class CNMAPI {

	private $dbc='';


	//--------------------------------------------------------------------------
	// connectDB
	// Se conecta a la BBDD y devuelve el handke correspondiente.
	//--------------------------------------------------------------------------
	public static function connectDB(){

		try {
			// RUTA DEL FICHERO DE CONFIGURACION DE CNM
			$cfg_file='/cfg/onm.conf';
			// HASH CON LOS DATOS NECESARIOS PARA USAR LA BBDD
			$db_data=array('DB_NAME'=>'','DB_USER'=>'','DB_PWD'=>'','DB_SERVER'=>'');

   		// RELLENAMOS LOS DATOS DEL HASH ANTERIOR
	   	read_cfg_file($cfg_file,$db_data);
   		$data = array(
      		'phptype'  => 'mysqli',
      		'username' => $db_data['DB_USER'],
	      	'password' => $db_data['DB_PWD'],
   	   	'hostspec' => $db_data['DB_SERVER'],
      		'database' => $db_data['DB_NAME'],
   		);
	   	// NOS CONECTAMOS A LA BBDD
   		$dbc = @DB::Connect($data,TRUE);
   		if (@PEAR::isError($dbc)) {
				throw new Exception("ERROR DE CONEXION"); 
   		}else {
      		$dbc->setFetchMode(DB_FETCHMODE_ASSOC);
   		}
			//$this->dbc = $dbc;
     		return $dbc;
		}
		catch (Exception $e) {
    		throw $e->getMessage();
  		}
	}

	//--------------------------------------------------------------------------
	// jsonResponseHeader
	// Devuelve al cliente una respuesta HTTP con el código indicado con el dato en formato json
	//--------------------------------------------------------------------------
	public static function jsonResponseHeader($data,$httpCode='200'){
		header('Max-Forwards: 10',true,$httpCode); 
		echo json_encode($data);
	}


   //--------------------------------------------------------------------------
   // error_log
   //--------------------------------------------------------------------------
    public static function error_log($file, $line, $message) {
        error_log(LOG_PREFIX. " {$file}:{$line} : {$message}");
    }


   //--------------------------------------------------------------------------
   // info_log
   //--------------------------------------------------------------------------
    public static function info_log($file, $line, $message) {

      $dbgTrace = debug_backtrace();
      $fx=$dbgTrace[1]['function'];
      $datetime = date("D M d H:i:s Y");
      $data = "[$datetime] [info] ".LOG_PREFIX. " {$file}:{$line}:$fx : {$message} \n";
      file_put_contents('/var/log/apache2/cnm_gui.log', $data, FILE_APPEND);
   }

   //--------------------------------------------------------------------------
   // debug_log
   //--------------------------------------------------------------------------
    public static function debug_log($file, $line, $message) {

      if (is_file('/var/log/apache2/cnm_debug_active')) {

         $dbgTrace = debug_backtrace();

         /*$dbgMsg='';
         foreach($dbgTrace as $dbgIndex => $dbgInfo) {
            $dbgMsg .= "$dbgIndex  ".$dbgInfo['file']." (line {$dbgInfo['line']}) -> {$dbgInfo['function']}";
            $dbgMsg .= " I=$dbgIndex  ".$dbgInfo['file']." (line {$dbgInfo['line']}) -> {$dbgInfo['function']}";
         }*/

         $fx=$dbgTrace[1]['function'];

         $datetime = date("D M d H:i:s Y");
         $data = "[$datetime] [debug] ".LOG_PREFIX. " {$file}:{$line}:$fx : {$message} \n";
         file_put_contents('/var/log/apache2/cnm_gui.log', $data, FILE_APPEND);
      }
   }

}

?>
