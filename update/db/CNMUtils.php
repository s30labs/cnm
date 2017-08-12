<?php

define("LOG_PREFIX", "cnm");

/**
 * keeps the utilities used in DSProcessor
 */
class CNMUtils {


	function CNMUtils() {

		return;
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

	//--------------------------------------------------------------------------
	// get_param
	// Obtiene un parametro, ya sea por GET, POST o linea de comandos.
	// Por linea de comandos: php fichero.php var1=valor1 var2=valor2
	// NOTA: Se eliminan las comillas simples hasta que se mire qué se hace
	//--------------------------------------------------------------------------
    public static function get_param($p) {

   	if (isset($_POST[$p])){
			// return $_POST[$p];
			return str_replace("'","",$_POST[$p]);
		}
   	elseif (isset($_GET[$p])){
			// return $_GET[$p];
			return str_replace("'","",$_GET[$p]);
		}	
   	elseif (isset($GLOBALS['argv']) && count($GLOBALS['argv'])>0){
      	for ($i=1;$i<count($GLOBALS['argv']);$i++){
         	$datos=explode('=',$GLOBALS['argv'][$i]);
         	if ($datos[0]==$p){
					// return $datos[1];
					return str_replace("'","",$datos[1]);
				}
      	}
   	}
   	return '';
	}

   //--------------------------------------------------------------------------
	// get_json
   // Obtiene un parametro json, ya sea por GET o POST.
   //--------------------------------------------------------------------------
	public static function get_json($p){
		$aux = '';
		if(isset($_POST[$p]))    $aux=$_POST[$p];
		elseif(isset($_GET[$p])) $aux=$_GET[$p];

		// Sustituyo \ por \\ porque sino json_decode no decodifica bien la cadena.
		// EJ: [{"id_dev":"3","name":"HP 100\20"}]
		// $aux = str_replace("\\", "\\\\",$aux); 

		return json_decode($aux,true);
	}
}

?>
