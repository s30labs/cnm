<?php

define("LOG_PREFIX", "cnm");

/**
 * keeps the utilities used in DSProcessor
 */
class CNMUtils {

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
   // core_i18n_global
   // Obtiene todos los tags definidos para el lenguaje configurado en onm.lang
   //--------------------------------------------------------------------------
   public static function core_i18n_global() {

		$data = array();
		$lang = 'en';
		$lang_config_file = '/cfg/onm.lang';
		if (file_exists($lang_config_file)) {
			$x = trim(file_get_contents($lang_config_file));
			list($a, $b) =  explode("_", $x, 2);
			if ($a != '') { $lang = $a; }
		}

		$lang_data_file = '/opt/cnm/lang/'.$lang.'/'.$lang.'.lang';
		if (file_exists($lang_data_file)) {

			$fh = fopen($lang_data_file, 'r');
			$content = fread($fh, filesize($lang_data_file));
			$my_array = explode("\n", $content);
			foreach($my_array as $line) {
    			$tmp = explode('||', $line);
    			$data[$tmp[0]] = $tmp[1];
			}
			fclose($fh);
		}
		return $data;
	}


   //--------------------------------------------------------------------------
   // core_i18n_tag
   // Obtiene la traduccion de un tag concreto que se pasa como parametro.
   //--------------------------------------------------------------------------
   public static function core_i18n_tag($txt) {

		$all_tags = CNMUtils::core_i18n_global();
		if (array_key_exists($txt,$all_tags)) {
			return $all_tags[$txt];
		}
		return "";

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


	/*
	* Function: get_device_status()
	* Input: 
	*	- $mode: array|json|xmlOption
	*	- $id_dev: En caso de existir, devuelve el estado del dispositivo
	* Output:
	* Descr: Devuelve una estructura con los estados de dispositivo existentes en el sistema
	*/
	public static function get_device_status($mode='array',$id_dev=null){

	   $a_data = array(
	      array(array('value'=>'0'),i18('_activo')),
	      array(array('value'=>'1'),i18('_baja')),
	      array(array('value'=>'2'),i18('_mantenimiento')),
	   );
		if($id_dev==null){
			$a_data[0][0]['selected']='true';
   	}
		else{
	      $data = array('__ID_DEV__' => $id_dev);
	      $result = doQuery('device_status',$data);
	      $status = $result['obj'][0]['status'];
	      if($status=='0')     $a_data[0][0]['selected']='true';
	      elseif($status=='1') $a_data[1][0]['selected']='true';
	      elseif($status=='2') $a_data[2][0]['selected']='true';
	   }


		if($mode=='array')         $res = $a_data;
		elseif($mode=='json')      $res = json_encode($a_data);
		elseif($mode=='xmlOption'){
			include_once('inc/class_option.php');
			$option = new Option($a_data);
			$res = $option->xml();
		}
		else{
         CNMUtils::debug_log(__FILE__, __LINE__, "CNMUtils::get_device_status($mode,$id_dev) >> mode $mode isn't supported");
			$res = '';
		}
		return $res;
	}

   /*
   * Function: get_device_types()
   * Input: 
   *  - $mode: array|json|xmlOption
   *  - $id_dev: En caso de existir, devuelve el tipo del dispositivo
   * Output:
   * Descr: Devuelve una estructura con los tipos de dispositivo existentes en el sistema
   */
   public static function get_device_types($mode='array',$id_dev=null){

		$device_type = '';
		$selected = false;
	   $a_data = array();
		if($id_dev!=null){
		   $data = array('__ID_DEV__' => $id_dev);
		   $result = doQuery('device_info',$data);
		   $device_type = $result['obj'][0]['type'];
		}
	
	   // Tipos de dispositivo disponibles
	   $result = doQuery('device_types',$data);
	   foreach ($result['obj'] as $r){
	      if (strtolower($r['descr'])==strtolower($device_type)){
				$a_data[]=array(array('value'=>$r['descr'],'selected'=>'true'),$r['descr']);
				$selected = true;
			}
	      else{
				$a_data[]=array(array('value'=>$r['descr']),$r['descr']);
			}
	   }

		if($selected==false) $a_data[0][0]['selected']='true';

      if($mode=='array')    $res = $a_data;
      elseif($mode=='json') $res = json_encode($a_data);
      elseif($mode=='xmlOption'){
         include_once('inc/class_option.php');
         $option = new Option($a_data);
         $res = $option->xml();
      }
      else{
         CNMUtils::debug_log(__FILE__, __LINE__, "CNMUtils::get_device_types($mode,$id_dev) >> mode $mode isn't supported");
			$res = '';
      }
      return $res;
   }
   /*
   * Function: get_device_wsizes()
   * Input: 
   *  - $mode: array|json|xmlOption
   *  - $id_dev: En caso de existir, devuelve la sensibilidad del dispositivo
   * Output:
   * Descr: Devuelve una estructura con las sensibilidades de dispositivo existentes en el sistema
   */
   public static function get_device_wsizes($mode='array',$id_dev=null){

		$device_wsize = 0;
		$selected = false;
	   $a_data = array();
		if($id_dev!=null){
		   $data = array('__ID_DEV__' => $id_dev);
		   $result = doQuery('device_info',$data);
		   $device_wsize = $result['obj'][0]['wsize'];
		}
	
	   // Obtenemos las sensibilidades soportadas en el sistema
	   $data = array();
	   $result = doQuery('get_all_cfg_device_wsize',$data);
	   foreach ($result['obj'] as $r){
	      if ($r['wsize']==$device_wsize){
				$a_data[]=array(array('value'=>$r['wsize'],'selected'=>'true'),$r['label']);
				$selected = true;
			}
	      else{
				$a_data[]=array(array('value'=>$r['wsize']),$r['label']);
			}
	   }

		if($selected==false) $a_data[0][0]['selected']='true';

      if($mode=='array')    $res = $a_data;
      elseif($mode=='json') $res = json_encode($a_data);
      elseif($mode=='xmlOption'){
         include_once('inc/class_option.php');
         $option = new Option($a_data);
         $res = $option->xml();
      }
      else{
         CNMUtils::debug_log(__FILE__, __LINE__, "CNMUtils::get_device_wsizes($mode,$id_dev) >> mode $mode isn't supported");
			$res = '';
      }
      return $res;
   }
   /*
   * Function: get_device_correlated()
   * Input: 
   *  - $mode: array|json|xmlTable
   *  - $id_dev: En caso de existir, devuelve el dispositivo del que depende
   * Output:
   * Descr: Devuelve una estructura con las dispositivos correladores existentes en el sistema
   */
   public static function get_device_correlated($mode='array',$id_dev=null){

      $a_aux_data = array();
	   $data   = array('__ID_DEV__' => $id_dev);
	   $result = doQuery('correlated_by',$data);
	   $id_dev_correlated = (isset($result['obj'][0]['id_dev']) and $result['obj'][0]['id_dev']!='')?$result['obj'][0]['id_dev']:'';
	
		$data = array();
	   $result = doQuery('all_devices_no_condition',$data);
	   foreach ($result['obj'] as $r){
			$a_aux_data[]=array('value'=>$r['wsize'],'selected'=>'true','label'=>$r['label'],'id'=>$r['id_dev'],'checkbox'=>($id_dev_correlated==$r['id_dev'])?1:0,'device_name'=>$r['name'],'device_domain'=>$r['domain'],'device_ip'=>$r['ip']);
	   }

      if($mode=='array')    $res = $a_aux_data;
      elseif($mode=='json') $res = json_encode($a_aux_data);
      elseif($mode=='xmlTable'){
         include_once('inc/class_table.php');
	      $tabla = new Table();
	      $tabla->addCol(array('type'=>'ra','width'=>'25','sort'=>'int','align'=>'center'),'&nbsp;','');
	      $tabla->addCol(array('type'=>'ro','width'=>'100','sort'=>'str','align'=>'left'),'#text_filter',i18('_NOMBRE'));
	      $tabla->addCol(array('type'=>'ro','width'=>'100','sort'=>'str','align'=>'left'),'#text_filter',i18('_DOMINIO'));
	      $tabla->addCol(array('type'=>'ro','width'=>'*','sort'=>'str','align'=>'left'),'#text_filter',i18('_IP'));

		   $row_meta = array('id'=>0);
		   $checkbox = ($id_dev_correlated=='')?1:0;
		   $row_data = array($checkbox,i18('_ninguno'),'-','-');
		   $row_user = array();
		   $tabla->addRow($row_meta,$row_data,$row_user);
			
			foreach($a_aux_data as $item){
				$row_meta = array('id'=>$item['id_dev']);
		      $row_data = array($item['checkbox'],$item['device_name'],$item['device_domain'],$item['device_ip']);
		      $row_user = array();
		      $tabla->addRow($row_meta,$row_data,$row_user);
			}
			$res = $tabla->xml();
		}
      else{
         CNMUtils::debug_log(__FILE__, __LINE__, "CNMUtils::get_device_correlated($mode,$id_dev) >> mode $mode isn't supported");
			$res = '';
      }
      return $res;
   }
   /*
   * Function: get_device_perfil_organizativo()
   * Input: 
   *  - $mode: array|json|xmlTable
	*	- $orgpro: perfil organizativo
	*	- $global: indica si el usuario es administrador global o no
   *  - $id_dev: En caso de existir, devuelve los perfiles organizativos del dispositivo
   * Output:
   * Descr: Devuelve una estructura con las perfiles organizativos existentes en el sistema
   */
   public static function get_device_perfil_organizativo($mode='array',$orgpro,$global,$id_dev=null){

      $a_aux_data = array();

	   $data   = array('__ID_DEV__' => $id_dev,'__USER_ORG_PRO__'=>$orgpro);
	   if ($global==1){
			$result = doQuery('info_global_user_organizational_profile',$data);
		}
	   else{
			$result = doQuery('info_user_organizational_profile',$data);
		}

	   foreach ($result['obj'] as $r){
	      $data2 = array('__ID_DEV__' => $id_dev,'__ID_CFG_OP__'=>$r['id_cfg_op']);
	      $result2 = doQuery('profile_device',$data2);
			$a_aux_data[] = array('id'=>$r['id_cfg_op'],'checkbox'=>$result2['obj'][0]['c']==0?0:1,'descr'=>$r['descr']);
	   }

      if($mode=='array')    $res = $a_aux_data;
      elseif($mode=='json') $res = json_encode($a_aux_data);
      elseif($mode=='xmlTable'){
         include_once('inc/class_table.php');

		   $tabla = new Table();
		   $tabla->addCol(array('type'=>'ch','width'=>'25','sort'=>'int','align'=>'center'),'','');
		   $tabla->addCol(array('type'=>'ro','width'=>'*','sort'=>'str','align'=>'left'),'',i18('_PERFIL'));

			foreach($a_aux_data as $item){
				$row_meta = array('id'=>$item['id']);
		      $row_data = array($item['checkbox'],$item['descr']);
		      $row_user = array();
		      $tabla->addRow($row_meta,$row_data,$row_user);
			}
			$res = $tabla->xml();
		}
      else{
         CNMUtils::debug_log(__FILE__, __LINE__, "CNMUtils::get_device_perfil_organizativo($mode,$orgpro,$global,$id_dev) >> mode $mode isn't supported");
			$res = '';
      }
      return $res;
   }
   /*
   * Function: get_device_snmp_version()
   * Input: 
   *  - $mode: array|json|xmlOption
   *  - $id_dev: En caso de existir, devuelve la version snmp del dispositivo
   * Output:
   * Descr: Devuelve una estructura con las versiones snmp existentes en el sistema
   */
   public static function get_device_snmp_version($mode='array',$id_dev=null){

	   $a_aux_data = array(
	      array(array('value'=>'0'),i18('_no')),
	      array(array('value'=>'1'),'v1'),
	      array(array('value'=>'2'),'v2'),
	      array(array('value'=>'3'),'v3'),
	   );

   	$data   = array('__ID_DEV__'=>get_param('id_dev'));
	   $result = doQuery('device_info',$data);
	   $version=$result['obj'][0]['version'];

   	if($version==0)    $a_aux_data[0][0]['selected']='true';
	   elseif($version==1)$a_aux_data[1][0]['selected']='true';
	   elseif($version==2)$a_aux_data[2][0]['selected']='true';
	   elseif($version==3)$a_aux_data[3][0]['selected']='true';

      if($mode=='array')    $res = $a_aux_data;
      elseif($mode=='json') $res = json_encode($a_aux_data);
      elseif($mode=='xmlOption'){
         include_once('inc/class_option.php');
         $option = new Option($a_aux_data);
         $res = $option->xml();
      }
      else{
         CNMUtils::debug_log(__FILE__, __LINE__, "CNMUtils::get_device_snmp_version($mode,$id_dev) >> mode $mode isn't supported");
			$res = '';
      }
      return $res;
   }


}

?>
