<?php

include_once('inc/Store.php');

define("LOG_PREFIX", "cnm-api");

class CNMAPI {

	private $dbc='';


	//--------------------------------------------------------------------------
	// connectDB
	// Se conecta a la BBDD y devuelve el handke correspondiente.
	//--------------------------------------------------------------------------
	public static function connectDB(){

		try {

		   //------------------------------------------
   		// cnm-cloud -> Diferente logica
   		//------------------------------------------
   		$FILE_SERVICES = '/cfg/cnm-services.json';
   		if (file_exists($FILE_SERVICES)) {

      		$content = file_get_contents($FILE_SERVICES);
		      $jdata = json_decode($content,true);

				$data = array(
					'phptype'  => 'mysql',
					'username' => $jdata['cnm-data-db']['cnm']['db_user'],
					'password' => $jdata['cnm-data-db']['cnm']['db_pwd'],
					'hostspec' => $jdata['cnm-data-db']['cnm']['db_host'],
					'database' => 'onm',
				);

		      if (! array_key_exists('database', $data)) { $data['database']='cnm'; }
      		if (! array_key_exists('hostspec', $data)) { $data['hostspec']='localhost'; }
		      if (! array_key_exists('username', $data)) { $data['username']='onm'; }
      		if (! array_key_exists('password', $data)) { $data['password']='onm1234'; }
      		if (! array_key_exists('phptype', $data)) { $data['phptype']='mysql'; }

//$data['hostspec']='midb00';

			}
			else {

				// RUTA DEL FICHERO DE CONFIGURACION DE CNM
				$cfg_file='/cfg/onm.conf';

   			// RELLENAMOS LOS DATOS DEL HASH $db_data
				$db_data=array('DB_NAME'=>'','DB_USER'=>'','DB_PWD'=>'','DB_SERVER'=>'');
		   	read_cfg_file($cfg_file,$db_data);
   			$data = array(
      			'phptype'  => 'mysql',
      			'username' => $db_data['DB_USER'],
	      		'password' => $db_data['DB_PWD'],
	   	   	'hostspec' => $db_data['DB_SERVER'],
   	   		'database' => $db_data['DB_NAME'],
   			);
			}

			CNMUtils::info_log(__FILE__, __LINE__, "**DB_DEBUG** {$data['hostspec']} {$data['username']} {$data['password']} {$data['database']}");

		   // NOS CONECTAMOS A LA BBDD
   		$timeout = 2;
   		$dbc = mysqli_init();
   		$dbc->options( MYSQLI_OPT_CONNECT_TIMEOUT, $timeout );
   
			$dbc->real_connect($data['hostspec'], $data['username'], $data['password'], $data['database']);

   		if ($dbc->connect_errno) {
      		$err_str = '('.$dbc->connect_errno.'): '.$dbc->connect_error;
				throw new Exception("ERROR DE CONEXION - $err_str");
   		}
   		else {
      		$dbc->query("SET CHARACTER SET UTF8");
      		$dbc->query("SET NAMES UTF8");
   		}
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
