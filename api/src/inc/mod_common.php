<?php
/*
 * Fichero: mod_common.php
 * Descr: Fichero con una serie de funciones comunes en varios sitios.
 *
*/
// En caso de no venir de la parte del API
if (!class_exists('CNMAPI')) {
	include_once('include_basic.php');

	define('_hidx',CNMUtils::get_param('hidx'));
	define('SESIONPHP',session_id());
}
// En caso de venir de la parte del API solo se garantiza que _hidx="" para que cid(_hidx) sea "default"
else{

	define('_hidx','');

//	/*
//	 * Function: cond2query()
//	 * Input:
//	 *    $k_cond => nombre del campo (ej: counter)
//	 *    $v_cond => valor del campo  (ej: >50)
//	 *    $a_table_descr => array( campo1=>tipo_campo1, campo2=>tipo_campo2, ...) Define el tipo de los campos de la BBDD de la tabla utilizada
//	 *
//	 * Output:
//	 *    $cond  => Cadena SQL que corresponde a la busqueda del campo indicado
//	 * Descr: Función que compone la condicion en formato SQL que debe utilizarse al realizar una busqueda en un grid
//	*/
//	function cond2query($k_cond,$v_cond,$a_table_descr=array()){
//	   $aux_cuantos = $v_cond;
//	   $a_simbol    = array('<','>','=','!');
//	   $aux_cuantos = str_replace($a_simbol,'',$aux_cuantos);
//	
//	
//	   // El campo existe en $a_table_descr
//	   if(array_key_exists($k_cond,$a_table_descr)){
//	      // El campo está definido como un entero
//	      if($a_table_descr[$k_cond]=='int'){
//	         if ((strpos($v_cond,'=')===false) AND (strpos($v_cond,'>')===false) AND (strpos($v_cond,'<')===false) AND (strpos($v_cond,'!')===false)){
//	            $v_cond="=$v_cond";
//	         }
//	         elseif(strpos($v_cond,'!')!==false){
//	            $v_cond=str_replace('!','!=',$v_cond);
//	         }
//	         $cond = " AND $k_cond $v_cond ";
//	      }
//	      // El campo esta definido como una cadena
//	      else{
//	         /*
//	          * Tenemos en cuenta:
//	          * !   : NOT LIKE %%
//	          * =   : EQUAL
//	          * 
//	         */
//				if(is_array($v_cond)){
//               if(strpos($v_cond,'=')!==false)     $cond = " AND $k_cond IN (";
//               elseif(strpos($v_cond,'!')!==false) $cond = " AND $k_cond NOT IN (";
//               else                                $cond = " AND $k_cond IN (";
//					
//					$sep = '';
//					foreach($v_cond as $foo => $_){
//						if($_=='') continue;
//						$cond.=$sep."'".str_replace(array('=','!'),'',$_)."'";
//						$sep = ',';
//					}
//					$cond.=')';
//				}else{
//		         if(strpos($v_cond,'=')!==false)     $cond = " AND $k_cond LIKE '".str_replace('=','',$v_cond)."' ";
//		         elseif(strpos($v_cond,'!')!==false) $cond = " AND $k_cond NOT LIKE '%".str_replace('!','',$v_cond)."%' ";
//		         else                                $cond = " AND $k_cond LIKE '%$v_cond%' ";
//				}
//	      }
//	   }
//	   // En caso de no estar ese campo en $a_table_descr
//	   else{
//	      // En caso de ser un campo numérico 
//	      if(is_numeric($aux_cuantos)){
//	         if ((strpos($v_cond,'=')===false) AND (strpos($v_cond,'>')===false) AND (strpos($v_cond,'<')===false) AND (strpos($v_cond,'!')===false)){
//	            $v_cond="=$v_cond";
//	         }
//	         elseif(strpos($v_cond,'!')!==false){
//	            $v_cond=str_replace('!','!=',$v_cond);
//	         }
//	         $cond = " AND $k_cond $v_cond ";
//	      }
//	      // En caso de ser un campo de texto
//	      else{
//	         /*
//	          * Tenemos en cuenta:
//	          * !   : NOT LIKE %%
//	          * =   : EQUAL
//	          * 
//	         */
//	         if(strpos($v_cond,'=')!==false)     $cond = " AND $k_cond LIKE '".str_replace('=','',$v_cond)."' ";
//	         elseif(strpos($v_cond,'!')!==false) $cond = " AND $k_cond NOT LIKE '%".str_replace('!','',$v_cond)."%' ";
//	         else                                $cond = " AND $k_cond LIKE '%$v_cond%' ";
//	      }
//	   }
//	   return $cond;
//	}
//
//	// Función que obtiene la descripción de los campos de una tabla
//	function DDBB_Table_Info($id_table){
//	   global $dbc;
//	   $return=array();
//	   $result = $dbc->query("SHOW FIELDS FROM $id_table");
//	   if (!@PEAR::isError($result)){
//	      if(is_object($result)){
//	         while ($result->fetchInto($r)){
//	            $type = 'int';
//	            if(strpos($r['Type'],'char')!==false)     $type = 'string';
//	            elseif(strpos($r['Type'],'text')!==false) $type = 'string';
//	            elseif(strpos($r['Type'],'blob')!==false) $type = 'string';
//	
//	            $return[$r['Field']] = $type;
//	         }
//	         $result->free();
//	      }
//	   }
//	   return $return;
//	}



}

$a_action_open = array();
$a_action_ajax = array('common_devices_get_table_structure','common_devices_get_table','common_devices_get_combo_device_types','common_devices_get_combo_device_critic','common_get_combo_network','common_search_store_get_table','common_views_get_table','common_metrics_get_table','common_views_get_metrics','common_alerts_get_table','common_alerts_store_get_table','common_tickets_get_table','common_views_get_remote_alerts','common_views_update_live','common_create_event','common_set_custom_data','common_create_device','common_views_renew');

// Aquí deben cargarse las funciones de los ficheros php externos y añadirse a $a_action_open y $a_action_ajax

$accion = CNMUtils::get_param('accion') != '' ? CNMUtils::get_param('accion') : 'open';

if(in_array($accion,$a_action_open))     action($accion,'open');
elseif(in_array($accion,$a_action_ajax)) action($accion);
else{
   // Error, acción no definida
}


	/*
	 * Función: common_devices_get_table_structure()
	 * Input:
	 *        $mode:0
	 *             :1
	 *             :2 => Cuando se va a imprimir el csv
	 *        $in_params{
	 *        	'include' => true:Muestra la columna INC|false o no se incluye:No muestra la columna INC
	 *          'id'      => Indica el id de dónde se va a crear la tabla ('mod_dispositivos_layout',etc)
	 *        }
	 * Output:
	 * Descr: Devuelve la estructura DHTMLX para mostrar la estructura de la tabla de dispositivos.
	 *        Tiene en cuenta los campos de usuario.
	 *        Sólo muestra las columnas visibles.
	 *
	 * Lugares: 
	 *         mod_dispositivo_layout.php
	*/
	function common_devices_get_table_structure($mode=0,$in_params=array()){
	   $tabla = new Table();
	   if($mode==0 or $mode==1){
	      $data = array('__ID_USER__'=>$_SESSION['NUSER']);
	      $result = doQuery('info_cfg_users',$data);
	      $json_stored_params = json_decode($result['obj'][0]['params'],true);

			if(array_key_exists('set_hidden',$in_params)){
				$tabla->setUserHidden($in_params['set_hidden']);
			}else{
		      $tabla->setUserHidden($json_stored_params[$in_params['id']]);
			}

	      $a_enableHeaderMenu = ''; // true => La columna aparece al dar al botón derecho || false => La columna no aparece al dar al botón derecho
	      $a_columnMove = array(); // true => La columna se puede mover || falso => La columna no puede moverse
	
	      $tabla->addCol(array('id'=>'system_checkbox','type'=>'ch','width'=>'25,25,false','sort'=>'server','align'=>'center'),'#master_checkbox','&nbsp;');
	      $a_enableHeaderMenu[] = 'false';
	      $a_columnMove[]       = 'false';
	
			if(array_key_exists('include',$in_params) AND $in_params['include']==true){
				$tabla->addCol(array('id'=>'system_asoc','type'=>'ro','width'=>'48,48,false','sort'=>'server','align'=>'center'),"<center><div id='combo_asoc' style='width:38px; height:22px;'></div></center>",i18('_INC'));
	         $a_enableHeaderMenu[] = 'false';
	         $a_columnMove[]       = 'true';
			}

	      //$tabla->addCol(array('id'=>'system_red','type'=>'ro','width'=>'30,30,false','sort'=>'server','align'=>'center'),'#text_filter',"<img src='images/alarm_ro.gif' title='".i18('_alertasrojas')."'>");
	      $tabla->addCol(array('id'=>'system_red','type'=>'ro','width'=>'30,30,false','sort'=>'server','align'=>'center'),'#text_filter',i18('_toolt_dispalertasrojas'));
   	   $a_enableHeaderMenu[] = 'false';
	      $a_columnMove[]       = 'true';
	
	      // $tabla->addCol(array('id'=>'system_orange','type'=>'ro','width'=>'30,30,false','sort'=>'server','align'=>'center'),'#text_filter',"<img src='images/alarm_na.gif' title='".i18('_alertasnaranjas')."'>");
	      $tabla->addCol(array('id'=>'system_orange','type'=>'ro','width'=>'30,30,false','sort'=>'server','align'=>'center'),'#text_filter',i18('_toolt_dispalertasnaranjas'));
	      $a_enableHeaderMenu[] = 'false';
	      $a_columnMove[]       = 'true';

	      // $tabla->addCol(array('id'=>'system_yellow','type'=>'ro','width'=>'30,30,false','sort'=>'server','align'=>'center'),'#text_filter',"<img src='images/alarm_am.gif' title='".i18('_alertasamarillas')."'>");
	      $tabla->addCol(array('id'=>'system_yellow','type'=>'ro','width'=>'30,30,false','sort'=>'server','align'=>'center'),'#text_filter',i18('_toolt_dispalertasamarillas'));
	      $a_enableHeaderMenu[] = 'false';
	      $a_columnMove[]       = 'true';

	      // $tabla->addCol(array('id'=>'system_blue','type'=>'ro','width'=>'30,30,false','sort'=>'server','align'=>'center'),'#text_filter',"<img src='images/alarm_az.gif' title='".i18('_alertasazules')."'>");
	      $tabla->addCol(array('id'=>'system_blue','type'=>'ro','width'=>'30,30,false','sort'=>'server','align'=>'center'),'#text_filter',i18('_toolt_dispalertasazules'));
	      $a_enableHeaderMenu[] = 'false';
	      $a_columnMove[]       = 'true';

	      // $tabla->addCol(array('id'=>'system_cuantos','type'=>'ro','width'=>'30,30,false','sort'=>'server','align'=>'center'),'#text_filter',"<img src='images/ico_graf_tab_off.gif' title='".i18('_metricascurso')."'>");
	      $tabla->addCol(array('id'=>'system_cuantos','type'=>'ro','width'=>'30,30,false','sort'=>'server','align'=>'center'),'#text_filter',i18('_toolt_dispmetricascurso'));
	      $a_enableHeaderMenu[] = 'false';
	      $a_columnMove[]       = 'true';

	      $tabla->addCol(array('id'=>'system_critic','type'=>'ro','width'=>'48,48,false','sort'=>'server','align'=>'center'),"<center><div id='div_combo_critic' style='width:38px; height:22px;'></div></center>",i18('_toolt_dispcriticidad'));
	      $a_enableHeaderMenu[] = 'false';
	      $a_columnMove[]       = 'true';

	      // $tabla->addCol(array('id'=>'system_status','type'=>'ro','width'=>'48,48,false','sort'=>'server','align'=>'center'),"<center><div id='div_status' style='width:38px; height:22px;'></div></center>","<img src='images/ico_disp_status_grey_2.gif' title='".i18('_estadodispositivo')."'>");
	      $tabla->addCol(array('id'=>'system_status','type'=>'ro','width'=>'48,48,false','sort'=>'server','align'=>'center'),"<center><div id='div_status' style='width:38px; height:22px;'></div></center>",i18('_toolt_dispestado'));
	      $a_enableHeaderMenu[] = 'false';
	      $a_columnMove[]       = 'true';

	      $tabla->addCol(array('id'=>'system_name','type'=>'ro','width'=>'150,120,true','sort'=>'server','align'=>'left'),'#text_filter',i18('_NOMBRE'));
	      $a_enableHeaderMenu[] = 'false';
	      $a_columnMove[]       = 'true';

	      $tabla->addCol(array('id'=>'system_domain','type'=>'ro','width'=>'100,100,true','sort'=>'server','align'=>'center'),'#text_filter',i18('_DOMINIO'));
	      $a_enableHeaderMenu[] = 'true';
	      $a_columnMove[]       = 'true';

	      $tabla->addCol(array('id'=>'system_ip','type'=>'ro','width'=>'*,100,true','sort'=>'server','align'=>'left'),'#text_filter',i18('_IP'));
	      $a_enableHeaderMenu[] = 'false';
	      $a_columnMove[]       = 'true';

         $tabla->addCol(array('id'=>'system_network','type'=>'ro','width'=>'100,100,true','sort'=>'server','align'=>'left'),"<center><div id='div_combo_network' style='width:90px; height:22px;'></div></center>",i18('_RED'));
         $a_enableHeaderMenu[] = 'true';
         $a_columnMove[]       = 'true';



	      $tabla->addCol(array('id'=>'system_type','type'=>'ro','width'=>'100,100,false','sort'=>'server','align'=>'left'),"<center><div id='div_combo_type' style='width:90px; height:22px;'></div></center>",i18('_TIPO'));
	      $a_enableHeaderMenu[] = 'true';
	      $a_columnMove[]       = 'true';

	      $tabla->addCol(array('id'=>'system_mac','type'=>'ro','width'=>'100,100,true','sort'=>'server','align'=>'center'),'#text_filter',i18('_MAC'));
	      $a_enableHeaderMenu[] = 'true';
	      $a_columnMove[]       = 'true';

	      $tabla->addCol(array('id'=>'system_sysoid','type'=>'ro','width'=>'100,100,true','sort'=>'server','align'=>'left','hidden'=>true),'#text_filter',i18('_clasedispositivosnmp'));
	      $a_enableHeaderMenu[] = 'true';
	      $a_columnMove[]       = 'true';

	      $tabla->addCol(array('id'=>'system_sysdesc','type'=>'ro','width'=>'100,100,true','sort'=>'server','align'=>'left','hidden'=>true),'#text_filter',i18('_descripcionsnmp'));
	      $a_enableHeaderMenu[] = 'true';
	      $a_columnMove[]       = 'true';

	      $tabla->addCol(array('id'=>'system_sysloc','type'=>'ro','width'=>'100,100,true','sort'=>'server','align'=>'left','hidden'=>true),'#text_filter',i18('_ubicacionsnmp'));
	      $a_enableHeaderMenu[] = 'true';
	      $a_columnMove[]       = 'true';

	      $data = array();
	      $result = doQuery('get_user_fields',$data);
	      foreach ($result['obj'] as $r){
   	      $tabla->addCol(array('id'=>"custom_{$r['descr']}",'type'=>'ro','width'=>'80,80,true','sort'=>'server','align'=>'left'),'#text_filter',$r['descr']);
	         $a_enableHeaderMenu[] = 'true';
	         $a_columnMove[]       = 'true';
	      }
	      $tabla->afterInit('enableHeaderMenu',implode(',',$a_enableHeaderMenu));
	      $tabla->afterInit('enableColumnMove','true',implode(',',$a_columnMove));
	   }
		elseif($mode==2){
         if(array_key_exists('include',$in_params) AND $in_params['include']==true){
				$tabla->addCol(array(),'',i18('_asociado'));
         }
	      $tabla->addCol(array(),'',i18('_alertasrojas'));
	      $tabla->addCol(array(),'',i18('_alertasnaranjas'));
	      $tabla->addCol(array(),'',i18('_alertasamarillas'));
	      $tabla->addCol(array(),'',i18('_alertasazules'));
	      $tabla->addCol(array(),'',i18('_metricascurso'));
	      $tabla->addCol(array(),'',i18('_criticidad'));
	      $tabla->addCol(array(),'',i18('_estadodispositivo'));
	      $tabla->addCol(array(),'',i18('_nombre'));
	      $tabla->addCol(array(),'',i18('_dominio'));
	      $tabla->addCol(array(),'',i18('_direccionip'));
	      $tabla->addCol(array(),'',i18('_red'));
	      $tabla->addCol(array(),'',i18('_tipo'));
	      $tabla->addCol(array(),'',i18('_MAC'));
	      $tabla->addCol(array(),'',i18('_clasedispositivosnmp'));
	      $tabla->addCol(array(),'',i18('_descripcionsnmp'));
	      $tabla->addCol(array(),'',i18('_ubicacionsnmp'));
	      $data = array();
	      $result = doQuery('get_user_fields',$data);
	      foreach ($result['obj'] as $r) $tabla->addCol(array(),'',$r['descr']);
	   }
		// API
      elseif($mode==3){
         $tabla->addCol(array(),'','id');
         $tabla->addCol(array(),'','redalerts');
         $tabla->addCol(array(),'','orangealerts');
         $tabla->addCol(array(),'','yellowalerts');
         $tabla->addCol(array(),'','bluealerts');
         $tabla->addCol(array(),'','nmetrics');
         $tabla->addCol(array(),'','critic');
         $tabla->addCol(array(),'','devicestatus');
         $tabla->addCol(array(),'','devicename');
         $tabla->addCol(array(),'','devicedomain');
         $tabla->addCol(array(),'','deviceip');
         $tabla->addCol(array(),'','devicenetwork');
         $tabla->addCol(array(),'','devicetype');
         $tabla->addCol(array(),'','devicemac');
         $tabla->addCol(array(),'','snmpsysclass');
         $tabla->addCol(array(),'','snmpsysdesc');
         $tabla->addCol(array(),'','snmpsyslocation');
         $data = array();
         $result = doQuery('get_user_fields',$data);
         foreach ($result['obj'] as $r) $tabla->addCol(array(),'',$r['descr']);
      }

	   if($mode==0)            $tabla->show();
	   elseif($mode==1) return $tabla->xml();
	   elseif($mode==2 or $mode==3) return $tabla;
	}

   /*
    * Función: common_devices_get_combo_device_types()
    * Input:
    *        $mode:0
    *             :1
    *        $type:
    *        }
    * Output:
    * Descr: Devuelve la estructura DHTMLX para mostrar el combo de los tipos de dispositivos definidos en CNM.
    *
    * Lugares: 
	 *          mod_dispositivo_layout.php
   */
	function common_devices_get_combo_device_types($mode=0,$type=''){
   	$array_option = array();
	   $selected = false;
	   $data = array();
	   $result = doQuery('device_types',$data);
	   foreach ($result['obj'] as $r){
	      if ($type==$r['id_host_type']){
	         $array_option[]=array(array('value'=>$r['id_host_type'],'selected'=>'true'),$r['descr']);
	         $selected = true;
	      }else{
	         $array_option[]=array(array('value'=>$r['id_host_type']),$r['descr']);
	      }
	   }
	
	   if ($selected==true){
	      array_unshift ($array_option ,array(array('value'=>'none'),i18('_sintipo')) );
	      array_unshift ($array_option ,array(array('value'=>'all'),'-') );
	   }
	   elseif($type=='none'){
	      array_unshift ($array_option ,array(array('value'=>'none','selected'=>'true'),i18('_sintipo')) );
	      array_unshift ($array_option ,array(array('value'=>'all'),'-') );
	   }
	   else{
	      array_unshift ($array_option ,array(array('value'=>'none'),i18('_sintipo')) );
	      array_unshift ($array_option ,array(array('value'=>'all','selected'=>'true'),'-') );
	   }

	   $option = new Option($array_option);
	
	   if($mode==0) $option->show();
	   else return($option->xml());
	}

   /*
    * Función: common_devices_get_combo_device_critic()
    * Input:
    *        $mode:0
    *             :1
    *        $type:
    *        }
    * Output:
    * Descr: Devuelve la estructura DHTMLX para mostrar el combo de la criticidad de dispositivos definidos en CNM.
    *
    * Lugares: 
    *          mod_dispositivo_layout.php
   */
	function common_devices_get_combo_device_critic($mode=0){
	   $array_option = array();
	   $array_option[]=array(array('value'=>'all','selected'=>'true','img_src'=>'images/guion.gif'),'');
	   $array_option[]=array(array('value'=>'high','img_src'=>'images/mod_critic_very_high_and_med16x16.png'),'');
	   $array_option[]=array(array('value'=>'medhigh','img_src'=>'images/mod_critic_very_high_high_and_med16x16.png'),'');
	   $array_option[]=array(array('value'=>100,'img_src'=>'images/mod_critic_very_high16x16.png'),'');
	   $array_option[]=array(array('value'=>75,'img_src'=>'images/mod_critic_high16x16.png'),'');
	   $array_option[]=array(array('value'=>50,'img_src'=>'images/mod_critic_med16x16.png'),'');
	   $array_option[]=array(array('value'=>25,'img_src'=>'images/mod_critic_low16x16.png'),'');
	
	   $option = new Option($array_option);
	
	   if($mode==0) $option->show();
	   else return  $option->xml();
	}
   /*
    * Función: common_get_combo_network()
    * Input:
    *        $mode:0
    *             :1
    * Output:
    * Descr: Devuelve la estructura DHTMLX para mostrar el combo con las redes definidas en CNM.
    *
    * Lugares: 
    *          mod_dispositivo_layout.php
   */
	function common_get_combo_network($mode=0){
	   $array_option = array();
	   $array_option[]=array(array('value'=>'all','selected'=>'true'),'-');
      $data = array();
      $result = doQuery('get_networks',$data);
      foreach ($result['obj'] as $r) $array_option[]=array(array('value'=>$r['network']),$r['network']);
	
	   $option = new Option($array_option);
	
	   if($mode==0) $option->show();
	   else return  $option->xml();
	}
	
   /*
    * Función: common_devices_get_table()
    * Input:
    *        $mode:0
    *             :1
    *             :2 => Cuando se va a imprimir el csv
    *        $input_params
    *        $extra_params
    *        $input_tabla
	 *			 $input_a_ss_params
    * Output:
    * Descr: Devuelve la estructura DHTMLX para mostrar los datos de la tabla de dispositivos.
    *        Tiene en cuenta los campos de usuario.
    *
    * Lugares: 
    *         mod_dispositivo_layout.php
   */
	function common_devices_get_table($mode=0,$input_params=array(),$extra_params=array(),$input_tabla='',$input_a_ss_params=array()){
	   if($mode==0){
	      $tabla       = new Table();
			$posStart    = $extra_params['posStart'];
	      $count       = $extra_params['count'];
	      $orderby     = $extra_params['orderby'];
	      $orderdirect = $extra_params['direct'];
	      $strict_type = $extra_params['strict_type'];
	      $sev         = $extra_params['sev'];

			// Filtros que ha puesto el usuario
      	$params      = $input_params;
      	// Filtros de las búsquedas almacenadas seleccionadas
      	$a_ss_params = $input_a_ss_params;

	   }else{
	      $tabla       = $input_tabla;
	      $posStart    = $extra_params['posStart'];
	      $count       = $extra_params['count'];
         // Filtros que ha puesto el usuario
         $params      = $input_params;
         // Filtros de las búsquedas almacenadas seleccionadas
         $a_ss_params = $input_a_ss_params;
	   }
	
	
		// API: Se parsean los campos que introduce el usuario por los que entiende el sistema
		if($mode==3){
			$params = array();
			// Campos de sistema
			$a_parse = array(
				'id'              => 'system_id_dev',
         	'redalerts'       => 'system_red',
         	'orangealerts'    => 'system_orange',
         	'yellowalerts'    => 'system_yellow',
         	'bluealerts'      => 'system_blue',
         	'nmetrics'        => 'system_cuantos',
         	'critic'          => 'critic',
         	'devicestatus'    => 'status',
         	'devicename'      => 'system_name',
         	'devicedomain'    => 'system_domain',
         	'deviceip'        => 'system_ip',
         	'devicenetwork'   => 'network',
         	'devicetype'      => 'type',
         	'devicemac'       => 'system_mac',
         	'snmpsysclass'    => 'system_sysoid',
         	'snmpsysdesc'     => 'system_sysdesc',
         	'snmpsyslocation' => 'system_sysloc',
			);

	      // Campos de usuario
	      $result = doQuery('get_user_fields',$data);
	      foreach ($result['obj'] as $r) $a_parse[$r['descr']]="custom_{$r['descr']}";

			if(!empty($input_params)){
				foreach($input_params as $key=>$value){
					if(array_key_exists($key,$a_parse)) $params[$a_parse[$key]] = $value;
					else $params[$key] = $value;
				}
			}
		}

	   $cid   = cid(_hidx);

	   // /////////////////////////////////////////////////// //
	   // Paso 1 START: Crear la tabla temporal con los datos //
	   // /////////////////////////////////////////////////// //
		
	   // Se obtienen los campos de usuario que hay definidos en el sistema
		$data = array();
	   $result = doQuery('get_user_fields',$data);
	   $user_fields = '';
	   $array_user_fields = array();
	   $a_user_fields_types = array();
	   foreach ($result['obj'] as $r){
	      $user_fields.=",c.columna{$r['id']}";
	      $array_user_fields[]="columna{$r['id']}";
	      $a_user_fields_types["columna{$r['id']}"]=$r['type'];
	   }
		
/*
	   // Se borra la tabla temporal t1,t2
		$data = array();
	   $result = doQuery('cnm_get_devices_layout_delete_temp',$data);

	   // Se crea la tabla temporal con los dispositivos visibles. Se ponen por defecto con red,orange,yellow y cuantos=0
		$data = array();
	   $result = doQuery('cnm_get_devices_layout_create_temp1',$data);

		$data = array('__USER_FIELDS__'=>$user_fields,'__ID_CFG_OP__'=>$_SESSION['ORGPRO'],'__CID__'=>$cid);
	   $result = doQuery('cnm_get_devices_layout_create_temp2',$data);

		// En caso de existir $extra_params['asoc'] y tener datos actualizamos el campo asoc de los id_dev que hay en el array definido por el campo asoc
		if(array_key_exists('asoc',$extra_params) AND is_array($extra_params['asoc'])){
			$dataAsoc = array('__ID_DEV__'=>implode(',',$extra_params['asoc']));
			$result = doQuery('update_asoc',$dataAsoc);
		}
	
	   // Se obtienen los id_dev y las alertas
	   $dispositivos_alarmados = dispositivos_alarmados();
	   foreach($dispositivos_alarmados as $id_dev=>$disp){
	      if ($disp['red']==0 and $disp['orange']==0 and $disp['yellow']==0 and $disp['blue']==0) continue;
	      $data2=array('__ID_DEV__'=>$id_dev,'__RED__'=>$disp['red'],'__ORANGE__'=>$disp['orange'],'__YELLOW__'=>$disp['yellow'],'__BLUE__'=>$disp['blue']);
	      $result2=doQuery('cnm_get_devices_layout_update_temp',$data2);
	   }
*/

		// Se borran las tablas temporales
      $data = array();
      $result = doQuery('cnm_get_devices_layout_delete_temp_all',$data);

      // Se crea la tabla temporal con los dispositivos y su numero de metricas
      $data = array();
      $result = doQuery('cnm_get_devices_layout_create_temp_metrics',$data);

      // Se crea la tabla temporal con los dispositivos con alertas rojas y el número de las mismas
      $data = array(); 
      $result = doQuery('cnm_get_devices_layout_create_temp_red',$data);

      // Se crea la tabla temporal con los dispositivos con alertas naranjas y el número de las mismas
      $data = array(); 
      $result = doQuery('cnm_get_devices_layout_create_temp_orange',$data);

      // Se crea la tabla temporal con los dispositivos con alertas amarillas y el número de las mismas
      $data = array(); 
      $result = doQuery('cnm_get_devices_layout_create_temp_yellow',$data);

      // Se crea la tabla temporal con los dispositivos con alertas azules y el número de las mismas
      $data = array(); 
      $result = doQuery('cnm_get_devices_layout_create_temp_blue',$data);

		// Se crea la tabla temporal con los dispositivos y todos sus campos
      $data = array('__USER_FIELDS__'=>$user_fields,'__ID_CFG_OP__'=>$_SESSION['ORGPRO'],'__CID__'=>$cid);
      $result = doQuery('cnm_get_devices_layout_create_temp_t1',$data);

      // En caso de existir $extra_params['asoc'] y tener datos actualizamos el campo asoc de los id_dev que hay en el array definido por el campo asoc
      if(array_key_exists('asoc',$extra_params) AND is_array($extra_params['asoc'])){
         $dataAsoc = array('__ID_DEV__'=>implode(',',$extra_params['asoc']));
         $result = doQuery('update_asoc',$dataAsoc);
      }


		
	   // Obtener los tipos de los campos de la tabla t1
	   $a_table_descr = DDBB_Table_Info('t1');
	
	   // ///////////////////////////////////////////////// //
	   // Paso 1 END: Crear la tabla temporal con los datos //
	   // ///////////////////////////////////////////////// //
	
	   // /////////////////////////////////////////// //
	   // Paso 2 START: Componer la query de búsqueda //
	   // /////////////////////////////////////////// //
	   $cond = "(''=''";
	   $order = ' name ASC';
	
		////////////////////////
	   // Parte de búsquedas //
   	////////////////////////
		if(! empty($params)){
		   foreach($params as $key=>$value) $params[$key]=mysql_real_escape_string($value);
		
		   foreach($params as $k_cond => $v_cond){
		      if($v_cond=='') continue;

	         if($k_cond=='status'){
	            if($v_cond=='all')        continue;
	            elseif($v_cond=='activ')  $cond.= " AND status=0 ";
	            elseif($v_cond=='desact') $cond.= " AND status=1 ";
	  	         elseif($v_cond=='mant')   $cond.= " AND status=2 ";
					else                      $cond.= " AND status=$v_cond ";
	         }
	         elseif($k_cond=='asoc'){
					if($v_cond=='all') continue;
					else $cond.= " AND asoc=$v_cond ";
	         }
				elseif($k_cond=='type'){
	            if($v_cond=='none')       $cond.= " AND (type='' OR isnull(type)) ";
	            elseif($v_cond!='all'){
	               $data2=array('__ID_HOST_TYPE__'=>$v_cond);
	               $result2=doQuery('device_types_by_id',$data2);
	               $cond.= " AND type='{$result2['obj'][0]['descr']}' ";
	            }
	         }
	         elseif($k_cond=='critic'){
	            if($v_cond=='all')         continue;
	            elseif($v_cond=='high')    $cond.= " AND $k_cond IN (75,100) ";
	            elseif($v_cond=='medhigh') $cond.= " AND $k_cond IN (50,75,100) ";
	            else                       $cond.= " AND $k_cond=$v_cond";
	         }
	         elseif($k_cond=='network'){
	            if($v_cond=='all') continue;
					else $cond.= " AND $k_cond='$v_cond' ";
	         }
	
	         elseif($k_cond=='system_red' or $k_cond=='system_orange' or $k_cond=='system_yellow' or $k_cond=='system_blue' or $k_cond=='system_cuantos' or $k_cond=='system_id_dev'){
					$cond.=cond2query(str_replace('system_','',$k_cond),$v_cond,$a_table_descr);
	         }
	         elseif(strpos( $k_cond,'system_')!==false){
					$cond.=cond2query(str_replace('system_','',$k_cond),$v_cond,$a_table_descr);
	         }
	         elseif(strpos( $k_cond,'custom_')!==false){
	            $data2=array('__DESCR__'=>str_replace('custom_','',$k_cond));
	            $result2=doQuery('get_devices_custom_type_by_descr',$data2);
					$cond.=cond2query("columna".$result2['obj'][0]['id'],$v_cond,$a_table_descr);
	         }
      	}
		}
      $cond.=')';
	   if(count($a_ss_params)>0) $cond.=' AND (';
	
	   ////////////////////////////////////
	   // Parte de búsquedas almacenadas //
	   ////////////////////////////////////
	   $sep_params = '';
		if(! empty($a_ss_params)){
		   foreach($a_ss_params as $params){
		      $cond.=$sep_params."( ''='' ";
		      $sep_params = ' OR ';
	
		      foreach($params as $key=>$value) $params[$key]=mysql_real_escape_string($value);
		
		      foreach($params as $k_cond => $v_cond){
			      if($v_cond=='') continue;

		         if($k_cond=='status'){
		            if($v_cond=='all')        continue;
		            elseif($v_cond=='activ')  $cond.= " AND status=0 ";
		            elseif($v_cond=='desact') $cond.= " AND status=1 ";
		  	         elseif($v_cond=='mant')   $cond.= " AND status=2 ";
		         }
		         elseif($k_cond=='asoc'){
						if($v_cond=='all') continue;
						else $cond.= " AND asoc=$v_cond ";
		         }
					elseif($k_cond=='type'){
		            if($v_cond=='none')       $cond.= " AND (type='' OR isnull(type)) ";
		            elseif($v_cond!='all'){
		               $data2=array('__ID_HOST_TYPE__'=>$v_cond);
		               $result2=doQuery('device_types_by_id',$data2);
		               $cond.= " AND type='{$result2['obj'][0]['descr']}' ";
		            }
		         }
		         elseif($k_cond=='critic'){
		            if($v_cond=='all')         continue;
		            elseif($v_cond=='high')    $cond.= " AND $k_cond IN (75,100) ";
		            elseif($v_cond=='medhigh') $cond.= " AND $k_cond IN (50,75,100) ";
		            else                       $cond.= " AND $k_cond=$v_cond";
		         }
		         elseif($k_cond=='network'){
		            if($v_cond=='all') continue;
						else $cond.= " AND $k_cond='$v_cond' ";
		         }
		
		         elseif($k_cond=='system_red' or $k_cond=='system_orange' or $k_cond=='system_yellow' or $k_cond=='system_blue' or $k_cond=='system_cuantos'){
						$cond.=cond2query(str_replace('system_','',$k_cond),$v_cond,$a_table_descr);
		         }
		         elseif(strpos( $k_cond,'system_')!==false){
						$cond.=cond2query(str_replace('system_','',$k_cond),$v_cond,$a_table_descr);
		         }
		         elseif(strpos( $k_cond,'custom_')!==false){
		            $data2=array('__DESCR__'=>str_replace('custom_','',$k_cond));
		            $result2=doQuery('get_devices_custom_type_by_descr',$data2);
						$cond.=cond2query("columna".$result2['obj'][0]['id'],$v_cond,$a_table_descr);
		         }
				}
				$cond.=')';
		   }
		}
	   if(count($a_ss_params)>0) $cond.=')';

      if($sev=='all')        $cond.='AND (red>0 OR orange>0 OR yellow>0)';
	
	   if($orderby!=''){
	      if ($orderdirect=='des') $orderdirect = "DESC";
	      else $orderdirect = "ASC";
		
	      if($orderby=='system_checkbox'){
	         $order = " name $orderdirect";
			}elseif($orderby=='system_ip'){
				$order = "INET_ATON(ip) $orderdirect";
	      }elseif(strpos( $orderby,'system_')!==false){
	         $order = str_replace('system_','',$orderby)." $orderdirect";
	      }elseif(strpos( $orderby,'custom_')!==false){
	         $data2=array('__DESCR__'=>str_replace('custom_','',$orderby));
	         $result2=doQuery('get_devices_custom_type_by_descr',$data2);
	         $order = "columna{$result2['obj'][0]['id']} $orderdirect";
	      }
	   }
		
	   // ///////////////////////////////////////// //
	   // Paso 2 END: Componer la query de búsqueda //
	   // ///////////////////////////////////////// //
	
	   // //////////////////////////////// //
	   // Paso 3 START: Devolver los datos //
	   // //////////////////////////////// //
		$data  = array('__POSSTART__'=>$posStart,'__COUNT__'=>$count,'__CONDITION__'=>$cond,'__ORDERBY__'=>$order);
	   $result = doQuery('cnm_get_devices_layout_lista',$data);
	   foreach ($result['obj'] as $r){
	      if($dispositivos_alarmados[$r['id_dev']]['red']>0 || $dispositivos_alarmados[$r['id_dev']]['orange']>0 || $dispositivos_alarmados[$r['id_dev']]['yellow']>0){
	         $row_style='color:red';
	      }else{
	         $row_style='';
	      }
	
	      $bgClassRed=($r['red']>0)?'cell_red':'';
	      $bgClassOrange=($r['orange']>0)?'cell_orange':'';
	      $bgClassYellow=($r['yellow']>0)?'cell_yellow':'';
	      $bgClassBlue=($r['blue']>0)?'cell_blue':'';
	
	      $row_user = array('ip'=>$r['ip'],'version'=>$r['version'],'id_dev'=>$r['id_dev'],'name'=>$r['name'],'entity'=>$r['entity']);
	      $row_meta = array('id'=>$r['id_dev'],'style'=>$row_style);
	      if($mode==0){
	     		if(array_key_exists('asoc',$extra_params) AND is_array($extra_params['asoc'])){
			      $asoc =$r['asoc']==1?'<img src="images/mod_incluir16x16.png">':'<img src="images/mod_excluir16x16.png">';
	            $row_data = array(
	               array('value'=>0),
	               array('value'=>$asoc),
	               array('value'=>$r['red'],    'class'=>$bgClassRed,    'style'=>'color:black'),
	               array('value'=>$r['orange'], 'class'=>$bgClassOrange, 'style'=>'color:black'),
	               array('value'=>$r['yellow'], 'class'=>$bgClassYellow, 'style'=>'color:black'),
	               array('value'=>$r['blue'],   'class'=>$bgClassBlue,   'style'=>'color:black'),
	               array('value'=>$r['cuantos'],'style'=>'color:black'),
	               array('value'=>get_critic_image($r['critic'])),
	               array('value'=>deviceStatus2string($r['status'])),
	               array('value'=>"<A HREF='do.php?hidx="._hidx."&do=mod_dispositivo_graficas&accion=open_layout_flot&id_dev={$r['id_dev']}&metrics=all&PHPSESSID=".SESIONPHP."' TARGET='_blank' onClick=\"winopen(this.href,this.target,900,600,1); return false;\"><img src='images/ico_graf_tab_off.gif' style='width:10px; border-width:0'></A>&nbsp;<A HREF='do.php?hidx="._hidx."&do=mod_dispositivo_documentacion&accion=open&id_dev={$r['id_dev']}&PHPSESSID=".SESIONPHP."' TARGET='_blank' onClick=\"winopen(this.href,this.target,900,600,1); return false;\"><img src='images/ico_pq_note.png' style='width:13px; border-width:0'></A>&nbsp;{$r['name']}"),
	               array('value'=>$r['domain']),
	               array('value'=>$r['ip']),
	               array('value'=>$r['network']),
	               array('value'=>($r['type']!='')?$r['type']:i18('_sintipo')),
	               array('value'=>$r['mac']),
	               array('value'=>$r['sysoid']),
	               array('value'=>$r['sysdesc']),
	               array('value'=>$r['sysloc']),
	            );
				}
				else{
	         	$row_data = array(
		            array('value'=>0),
		            array('value'=>$r['red'],    'class'=>$bgClassRed,    'style'=>'color:black'),
		            array('value'=>$r['orange'], 'class'=>$bgClassOrange, 'style'=>'color:black'),
		            array('value'=>$r['yellow'], 'class'=>$bgClassYellow, 'style'=>'color:black'),
		            array('value'=>$r['blue'],   'class'=>$bgClassBlue,   'style'=>'color:black'),
		            array('value'=>$r['cuantos'],'style'=>'color:black'),
		            array('value'=>get_critic_image($r['critic'])),
		            array('value'=>deviceStatus2string($r['status'])),
		            array('value'=>"<A HREF='do.php?hidx="._hidx."&do=mod_dispositivo_graficas&accion=open_layout_flot&id_dev={$r['id_dev']}&metrics=all&PHPSESSID=".SESIONPHP."' TARGET='_blank' onClick=\"winopen(this.href,this.target,900,600,1); return false;\"><img src='images/ico_graf_tab_off.gif' style='width:10px; border-width:0'></A>&nbsp;<A HREF='do.php?hidx="._hidx."&do=mod_dispositivo_documentacion&accion=open&id_dev={$r['id_dev']}&PHPSESSID=".SESIONPHP."' TARGET='_blank' onClick=\"winopen(this.href,this.target,900,600,1); return false;\"><img src='images/ico_pq_note.png' style='width:13px; border-width:0'></A>&nbsp;{$r['name']}"),
		            array('value'=>$r['domain']),
		            array('value'=>$r['ip']),
		            array('value'=>$r['network']),
		            array('value'=>($r['type']!='')?$r['type']:i18('_sintipo')),
		            array('value'=>$r['mac']),
		            array('value'=>$r['sysoid']),
		            array('value'=>$r['sysdesc']),
		            array('value'=>$r['sysloc']),
		         );
				}
	         /*
	            mysql> SELECT id,descr,tipo FROM devices_custom_types order by descr;
	            +----+----------------------+------+
	            | id | descr                | tipo |
	            +----+----------------------+------+
	            | 49 | link                 |    2 |
	            | 51 | Notas                |    1 |
	            | 50 | Telefono responsable |    0 |
	            +----+----------------------+------+
	            3 rows in set (0.00 sec)
	         */
	         $nav = ObtenerNavegador($_SERVER['HTTP_USER_AGENT']);
	         foreach ($array_user_fields as $field){
	            if($a_user_fields_types[$field]==2 && $r[$field]!='-'){
	               $uri=URINavegator($r[$field],$nav);
	               $row_data[]=array('value'=>"<a href='$uri' target='_blank'>link<a>");
	            }
					elseif($a_user_fields_types[$field]==3){
						$aux_json_kk = json_decode($r[$field]);
						// $row_data[]=array('value'=>implode("<br>",$aux_json_kk));
						$aux_val = '';
						if(count($aux_json_kk)>0){
							$aux_val.= '<ul style="padding-left: 15px;">';
							foreach($aux_json_kk as $_) $aux_val.="<li>$_</li>";
							$aux_val.='</ul>';
						}
						$row_data[]=array('value'=>$aux_val);
					}
					else{
	               $row_data[]=array('value'=>$r[$field]);
	            }
	         }
	         $tabla->addRow2($row_meta,$row_data,$row_user);
	      }
			elseif($mode==1 or $mode==2){
	         $type = ($r['type']!='')?$r['type']:'Sin tipo';
				if(array_key_exists('asoc',$extra_params) AND is_array($extra_params['asoc'])){
					$asoc =$r['asoc']==1?'Si':'No';
		         $row_data = array($asoc,$r['red'],$r['orange'],$r['yellow'],$r['blue'],$r['cuantos'],"{$r['critic']} ".i18('_sobre100'),deviceStatus2stringCSV($r['status']),$r['name'],$r['domain'],$r['ip'],$r['network'],$type,$r['mac'],$r['sysoid'],$r['sysdesc'],$r['sysloc']);
	
				}else{
		         $row_data = array($r['red'],$r['orange'],$r['yellow'],$r['blue'],$r['cuantos'],"{$r['critic']} ".i18('_sobre100'),deviceStatus2stringCSV($r['status']),$r['name'],$r['domain'],$r['ip'],$r['network'],$type,$r['mac'],$r['sysoid'],$r['sysdesc'],$r['sysloc']);
				}

            foreach ($array_user_fields as $field) $row_data[]=$r[$field];
	         $tabla->addRow($row_meta,$row_data,$row_user);
	      }
			// API
			elseif($mode==3){
            $row_data = array($r['id_dev'],$r['red'],$r['orange'],$r['yellow'],$r['blue'],$r['cuantos'],$r['critic'],$r['status'],$r['name'],$r['domain'],$r['ip'],$r['network'],$r['type'],$r['mac'],$r['sysoid'],$r['sysdesc'],$r['sysloc']);
            foreach ($array_user_fields as $field) $row_data[]=$r[$field];
            $tabla->addRow($row_meta,$row_data,$row_user);
         }
	   }

      $data  = array('__CONDITION__'=>$cond);
	   $result = doQuery('cnm_get_devices_layout_count',$data);
	   $cuantos = $result['obj'][0]['cuantos'];

	   if($mode==0) $tabla->showData($cuantos,$posStart);
	   else return  $tabla->xml();
	}

   /*
    * Función: common_search_store_get_table()
    * Input:
    *        $scope
	 *        $in_checked: array con los id_search_store que están asociados (eso aporta en tareas>dispositivos)
	 *        $mode: entero que indica cómo debe aparecer el grid (0=con checkbox,1=sin checkbox)
    * Output:
    * Descr: Devuelve en formato DHTMLX el grid con las búsquedas almacenadas para el scope indicado
    *
    * Lugares: 
    *          mod_dispositivo_layout.php
    *          mod_vistas_detalle.php (con in_checked con datos y mode=1)
   */
	function common_search_store_get_table($scope,$in_checked=0,$mode=0){ 

		$a_struct2name = array(
			'view_remote'=>array(
				'rtype'=>array(
					'text'=>i18('_TIPO'),
               'icon'=>array(
                  'snmp'=>"<img src=images/mod_ico_trap.png style='vertical-align: baseline;'>",
                  'email'=>"<img src=images/mod_ico_email.png style='vertical-align: baseline;'>",
                  'syslog'=>"<img src=images/mod_ico_syslog.png style='vertical-align: baseline;'>",
               ),
				),
				'system_rlabel'=>array(
               'text'=>'ALERTA',
            ),
				'critic'=>array(
               'text'=>i18('_CRIT'),
               'icon'=>array(
                  'high'=>"<img src=images/mod_critic_very_high_and_med16x16.png style='vertical-align: baseline; width:9px;'>",
                  'medhigh'=>"<img src=images/mod_critic_very_high_high_and_med16x16.png style='vertical-align: baseline; width:9px;'>",
                  '100'=>"<img src=images/mod_critic_very_high16x16.png style='vertical-align: baseline; width:9px;'>",
                  '75' =>"<img src=images/mod_critic_high16x16.png style='vertical-align: baseline; width:9px;'>",
                  '50' =>"<img src=images/mod_critic_med16x16.png style='vertical-align: baseline; width:9px;'>",
                  '25' =>"<img src=images/mod_critic_low16x16.png style='vertical-align: baseline; width:9px;'>",
               ),
            ),
				'status'=>array(
               'text'=>"<img src='images/ico_disp_status_grey_2.gif' style='vertical-align: baseline; width:9px;'>",
               'icon'=>array(
                  "activ"=>"<img src=images/ico_activ_tr_20.gif style='vertical-align: baseline; width:9px;'>",
                  "desact"=>"<img src=images/ico_desact_tr_20.gif style='vertical-align: baseline; width:9px;'>",
                  "mant"=>"<img src=images/ico_mant_tr_20.gif style='vertical-align: baseline; width:9px;'>",
               ),
            ),
            'asoc'=>array(
               'text'=>i18('_INC'),
               'icon'=>array(
                  "0"=>"<img src=images/mod_excluir16x16.png style='vertical-align: baseline;'>",
                  "1"=>"<img src=images/mod_incluir16x16.png style='vertical-align: baseline;'>",
               ),
            ),
				'system_name'=>array(
               'text'=>i18('_NOMBRE'),
            ),
				'system_domain'=>array(
               'text'=>i18('_DOMINIO'),
            ),
				'system_ip'=>array(
               'text'=>i18('_IP'),
            ),
				'network'=>array(
               'text'=>i18('_RED'),
            ),
				'type'=>array(
               'text'=>i18('_TIPO'),
            ),
				'system_mac'=>array(
               'text'=>i18('_MAC'),
            ),
				'system_sysoid'=>array(
               'text'=>i18('_clasedispositivosnmp'),
            ),
				'system_sysdesc'=>array(
               'text'=>i18('_descripcionsnmp'),
            ),
				'system_sysloc'=>array(
               'text'=>i18('_ubicacionsnmp'),
            ),

			),
			'view_metric'=>array(
				'mtype'=>array(
					'text'=>i18('_TIPO'),
               'icon'=>array(
                  'snmp'=>"<img src=images/mod_ico_snmp.png style='vertical-align: baseline;'>",
                  'latency'=>"<img src=images/mod_ico_tcpip.png style='vertical-align: baseline;'>",
                  'xagent'=>"<img src=images/mod_ico_xagent.png style='vertical-align: baseline;'>",
                  'email'=>"<img src=images/mod_ico_email.png style='vertical-align: baseline;'>",
                  'syslog'=>"<img src=images/mod_ico_syslog.png style='vertical-align: baseline;'>",
                  'snmp-trap'=>"<img src=images/mod_ico_trap.png style='vertical-align: baseline;'>",
                  'cnm'=>"<img src=images/mod_ico_cnm.png style='vertical-align: baseline;'>",
               ),
				),
				'system_mlabel'=>array(
               'text'=>i18('_METRICA'),
            ),
				'critic'=>array(
               'text'=>i18('_CRIT'),
               'icon'=>array(
                  'high'=>"<img src=images/mod_critic_very_high_and_med16x16.png style='vertical-align: baseline; width:9px;'>",
                  'medhigh'=>"<img src=images/mod_critic_very_high_high_and_med16x16.png style='vertical-align: baseline; width:9px;'>",
                  '100'=>"<img src=images/mod_critic_very_high16x16.png style='vertical-align: baseline; width:9px;'>",
                  '75' =>"<img src=images/mod_critic_high16x16.png style='vertical-align: baseline; width:9px;'>",
                  '50' =>"<img src=images/mod_critic_med16x16.png style='vertical-align: baseline; width:9px;'>",
                  '25' =>"<img src=images/mod_critic_low16x16.png style='vertical-align: baseline; width:9px;'>",
               ),
            ),
				'status'=>array(
               'text'=>"<img src='images/ico_disp_status_grey_2.gif' style='vertical-align: baseline; width:9px;'>",
               'icon'=>array(
                  "activ"=>"<img src=images/ico_activ_tr_20.gif style='vertical-align: baseline; width:9px;'>",
                  "desact"=>"<img src=images/ico_desact_tr_20.gif style='vertical-align: baseline; width:9px;'>",
                  "mant"=>"<img src=images/ico_mant_tr_20.gif style='vertical-align: baseline; width:9px;'>",
               ),
            ),
            'asoc'=>array(
               'text'=>i18('_INC'),
               'icon'=>array(
                  "0"=>"<img src=images/mod_excluir16x16.png style='vertical-align: baseline;'>",
                  "1"=>"<img src=images/mod_incluir16x16.png style='vertical-align: baseline;'>",
               ),
            ),
				'system_name'=>array(
               'text'=>i18('_NOMBRE'),
            ),
				'system_domain'=>array(
               'text'=>i18('_DOMINIO'),
            ),
				'system_ip'=>array(
               'text'=>i18('_IP'),
            ),
				'network'=>array(
               'text'=>i18('_RED'),
            ),
				'type'=>array(
               'text'=>i18('_TIPO'),
            ),
				'system_mac'=>array(
               'text'=>i18('_MAC'),
            ),
				'system_sysoid'=>array(
               'text'=>i18('_clasedispositivosnmp'),
            ),
				'system_sysdesc'=>array(
               'text'=>i18('_descripcionsnmp'),
            ),
				'system_sysloc'=>array(
               'text'=>i18('_ubicacionsnmp'),
            ),
			),
			'device'=>array(
				'system_red'=>array(
					'text'=>"<img src='images/alarm_ro.gif' style='vertical-align: baseline; width:9px;'>",
				),
				'system_orange'=>array(
               'text'=>"<img src='images/alarm_na.gif' style='vertical-align: baseline; width:9px;'>",
            ),
				'system_yellow'=>array(
               'text'=>"<img src='images/alarm_am.gif' style='vertical-align: baseline; width:9px;'>",
            ),
				'system_blue'=>array(
               'text'=>"<img src='images/alarm_az.gif' style='vertical-align: baseline; width:9px;'>",
            ),
				'system_cuantos'=>array(
               'text'=>"<img src='images/ico_graf_tab_off.gif' style='vertical-align: baseline; width:9px;'>",
            ),
				'critic'=>array(
               'text'=>i18('_CRIT'),
               'icon'=>array(
      				'high'=>"<img src=images/mod_critic_very_high_and_med16x16.png style='vertical-align: baseline; width:9px;'>",
      				'medhigh'=>"<img src=images/mod_critic_very_high_high_and_med16x16.png style='vertical-align: baseline; width:9px;'>",
                  '100'=>"<img src=images/mod_critic_very_high16x16.png style='vertical-align: baseline; width:9px;'>",
                  '75' =>"<img src=images/mod_critic_high16x16.png style='vertical-align: baseline; width:9px;'>",
                  '50' =>"<img src=images/mod_critic_med16x16.png style='vertical-align: baseline; width:9px;'>",
                  '25' =>"<img src=images/mod_critic_low16x16.png style='vertical-align: baseline; width:9px;'>",
               ),
            ),
				'status'=>array(
               'text'=>"<img src='images/ico_disp_status_grey_2.gif' style='vertical-align: baseline; width:9px;'>",
					'icon'=>array(
						"activ"=>"<img src=images/ico_activ_tr_20.gif style='vertical-align: baseline; width:9px;'>",
						"desact"=>"<img src=images/ico_desact_tr_20.gif style='vertical-align: baseline; width:9px;'>",
						"mant"=>"<img src=images/ico_mant_tr_20.gif style='vertical-align: baseline; width:9px;'>",
					),
            ),
				'system_name'=>array(
               'text'=>i18('_NOMBRE'),
            ),
				'system_domain'=>array(
               'text'=>i18('_DOMINIO'),
            ),
				'system_ip'=>array(
               'text'=>i18('_IP'),
            ),
				'system_network'=>array(
               'text'=>i18('_RED'),
            ),
				'type'=>array(
               'text'=>i18('_TIPO'),
            ),
				'system_mac'=>array(
               'text'=>i18('_MAC'),
            ),
				'system_sysoid'=>array(
               'text'=>i18('_clasedispositivosnmp'),
            ),
				'system_sysdesc'=>array(
               'text'=>i18('_descripcionsnmp'),
            ),
				'system_sysloc'=>array(
               'text'=>i18('_ubicacionsnmp'),
            ),
			),
			'alerts'=>array(
				'ack'=>array(
               'text'=>i18('_ACK'),
					'icon'=>array(
		            '0'=>'<img src="images/ack_gr.gif">',
		            '1'=>'<img src="images/ack_ve.gif">',
		            '2'=>'<img src="images/ack_az.gif">',
		            '3'=>'<img src="images/ack_ro.gif">',
		            '4'=>'<img src="images/ack_na.gif">',
		            '5'=>'<img src="images/ack_am.gif">',
					),
            ),
            'ticket'=>array(
               'text'=>i18('_TIC'),
               'icon'=>array(
		            '0'=>'<img src="images/ico_pq_ticket_gr.gif">',
      		      '1'=>'<img src="images/ico_pq_ticket.gif">',
					),
				),
				'severity'=>array(
               'text'=>i18('_SEV'),
               'icon'=>array(
						'rna'=>"<img src=images/alarm_rna.gif style='vertical-align: baseline; width:9px;'>",
		            '0'  =>"<img src=images/alarm_tr.gif style='vertical-align: baseline; width:9px;'>",
		            '1'  =>"<img src=images/alarm_ro.gif style='vertical-align: baseline; width:9px;'>",
		            '2'  =>"<img src=images/alarm_na.gif style='vertical-align: baseline; width:9px;'>",
		            '3'  =>"<img src=images/alarm_am.gif style='vertical-align: baseline; width:9px;'>",
		            '4'  =>"<img src=images/alarm_az.gif style='vertical-align: baseline; width:9px;'>",
		            '5'  =>"<img src=images/alarm_gr.gif style='vertical-align: baseline; width:9px;'>",
		            '6'  =>"<img src=images/alarm_ve.gif style='vertical-align: baseline; width:9px;'>",
					),
				),
            'critic'=>array(
               'text'=>i18('_CRIT'),
               'icon'=>array(
      				'high'=>"<img src=images/mod_critic_very_high_and_med16x16.png style='vertical-align: baseline; width:9px;'>",
      				'medhigh'=>"<img src=images/mod_critic_very_high_high_and_med16x16.png style='vertical-align: baseline; width:9px;'>",
		            '100'=>"<img src=images/mod_critic_very_high16x16.png style='vertical-align: baseline; width:9px;'>",
		            '75' =>"<img src=images/mod_critic_high16x16.png style='vertical-align: baseline; width:9px;'>",
		            '50' =>"<img src=images/mod_critic_med16x16.png style='vertical-align: baseline; width:9px;'>",
		            '25' =>"<img src=images/mod_critic_low16x16.png style='vertical-align: baseline; width:9px;'>",
					),
				),
            'type'=>array(
               'text'=>i18('_TIPO'),
               'icon'=>array(
		            'snmp'=>"<img src=images/mod_ico_snmp.png style='vertical-align: baseline;'>",
		            'latency'=>"<img src=images/mod_ico_tcpip.png style='vertical-align: baseline;'>",
		            'xagent'=>"<img src=images/mod_ico_xagent.png style='vertical-align: baseline;'>",
		            'email'=>"<img src=images/mod_ico_email.png style='vertical-align: baseline;'>",
		            'syslog'=>"<img src=images/mod_ico_syslog.png style='vertical-align: baseline;'>",
		            'snmp-trap'=>"<img src=images/mod_ico_trap.png style='vertical-align: baseline;'>",
		            'cnm'=>"<img src=images/mod_ico_cnm.png style='vertical-align: baseline;'>",
               ),
            ),
            'date'=>array(
               'text'=>i18('_FECHA'),
            ),
            'name'=>array(
               'text'=>i18('_NOMBRE'),
            ),
            'domain'=>array(
               'text'=>i18('_DOMINIO'),
            ),
				'ip'=>array(
					'text'=>i18('_IP'),
				),
				'label'=>array(
               'text'=>i18('_CAUSA'),
            ),
				'counter'=>array(
               'text'=>i18('_CNT'),
            ),
				'event_data'=>array(
               'text'=>i18('_EVENTO'),
            ),
			),
			'halerts'=>array(
				'ack'=>array(
               'text'=>i18('_ACK'),
					'icon'=>array(
		            '0'=>'<img src="images/ack_gr.gif">',
		            '1'=>'<img src="images/ack_ve.gif">',
		            '2'=>'<img src="images/ack_az.gif">',
		            '3'=>'<img src="images/ack_ro.gif">',
		            '4'=>'<img src="images/ack_na.gif">',
		            '5'=>'<img src="images/ack_am.gif">',
					),
            ),
            'ticket'=>array(
               'text'=>i18('_TIC'),
               'icon'=>array(
		            '0'=>'<img src="images/ico_pq_ticket_gr.gif">',
      		      '1'=>'<img src="images/ico_pq_ticket.gif">',
					),
				),
				'severity'=>array(
               'text'=>i18('_SEV'),
               'icon'=>array(
						'rna'=>"<img src=images/alarm_rna.gif style='vertical-align: baseline; width:9px;'>",
		            '0'  =>"<img src=images/alarm_tr.gif style='vertical-align: baseline; width:9px;'>",
		            '1'  =>"<img src=images/alarm_ro.gif style='vertical-align: baseline; width:9px;'>",
		            '2'  =>"<img src=images/alarm_na.gif style='vertical-align: baseline; width:9px;'>",
		            '3'  =>"<img src=images/alarm_am.gif style='vertical-align: baseline; width:9px;'>",
		            '4'  =>"<img src=images/alarm_az.gif style='vertical-align: baseline; width:9px;'>",
		            '5'  =>"<img src=images/alarm_gr.gif style='vertical-align: baseline; width:9px;'>",
		            '6'  =>"<img src=images/alarm_ve.gif style='vertical-align: baseline; width:9px;'>",
					),
				),
            'critic'=>array(
               'text'=>i18('_CRIT'),
               'icon'=>array(
		            '100'=>'<img src=images/mod_critic_very_high16x16.png>',
		            '75' =>'<img src=images/mod_critic_high16x16.png>',
		            '50' =>'<img src=images/mod_critic_med16x16.png>',
		            '25' =>'<img src=images/mod_critic_low16x16.png>',
					),
				),
            'type'=>array(
               'text'=>i18('_TIPO'),
               'icon'=>array(
		            'snmp'=>"<img src=images/mod_ico_snmp.png style='vertical-align: baseline;'>",
		            'latency'=>"<img src=images/mod_ico_tcpip.png style='vertical-align: baseline;'>",
		            'xagent'=>"<img src=images/mod_ico_xagent.png style='vertical-align: baseline;'>",
		            'email'=>"<img src=images/mod_ico_email.png style='vertical-align: baseline;'>",
		            'syslog'=>"<img src=images/mod_ico_syslog.png style='vertical-align: baseline;'>",
		            'snmp-trap'=>"<img src=images/mod_ico_trap.png style='vertical-align: baseline;'>",
		            'cnm'=>"<img src=images/mod_ico_cnm.png style='vertical-align: baseline;'>",
               ),
            ),
            'date'=>array(
               'text'=>i18('_FECHA'),
            ),
            'name'=>array(
               'text'=>i18('_NOMBRE'),
            ),
            'domain'=>array(
               'text'=>i18('_DOMINIO'),
            ),
				'ip'=>array(
					'text'=>i18('_IP'),
				),
				'label'=>array(
               'text'=>i18('_CAUSA'),
            ),
				'event_data'=>array(
               'text'=>i18('_EVENTO'),
            ),
			),
		);


		// Tipos de dispositivo en dispositivo
		if($scope=='device'){
			$data = array();
			$result = doQuery('device_types',$data);
			foreach($result['obj'] as $r) $a_struct2name[$scope]['type']['icon'][$r['id_host_type']]=$r['descr'];
		}
		// Tipos de dispositivo en métricas de vista
      if($scope=='view_metric'){
         $data = array();
         $result = doQuery('device_types',$data);
         foreach($result['obj'] as $r) $a_struct2name[$scope]['type']['icon'][$r['id_host_type']]=$r['descr'];
      }
      // Tipos de dispositivo en alertas remotas de vista
      if($scope=='view_remote'){
         $data = array();
         $result = doQuery('device_types',$data);
         foreach($result['obj'] as $r) $a_struct2name[$scope]['type']['icon'][$r['id_host_type']]=$r['descr'];
      }



	   $tabla = new Table();
		$tabla->no_limit_words();
	
		if($mode==1){
         $tabla->addCol(array('id'=>'name','type'=>'ro','width'=>'120','sort'=>'str','align'=>'left'),'#text_filter',i18('_nombre'));
         $tabla->addCol(array('id'=>'data','type'=>'ro','width'=>'*','sort'=>'str','align'=>'left'),'#text_filter','
Condición de búsqueda');
		}
		elseif($in_checked==0){   
		   $tabla->addCol(array('id'=>'checkbox','type'=>'ch','width'=>'25','sort'=>'int','align'=>'center'),'#master_checkbox','&nbsp;');
		   $tabla->addCol(array('id'=>'name','type'=>'ro','width'=>'300','sort'=>'str','align'=>'left'),'#text_filter',i18('_nombre'));
		   $tabla->addCol(array('id'=>'data','type'=>'ro','width'=>'*','sort'=>'str','align'=>'left'),'#text_filter',i18('_condicionbusqueda'));
		}
		else{
		   $tabla->addCol(array('id'=>'checkbox','type'=>'ch','width'=>'25','sort'=>'int','align'=>'center'),'#master_checkbox','&nbsp;');
		   $tabla->addCol(array('id'=>'inc','type'=>'ro','width'=>'48,48,false','sort'=>'str','align'=>'center'),'&nbsp;',i18('_INC'));
		   $tabla->addCol(array('id'=>'name','type'=>'ro','width'=>'300','sort'=>'str','align'=>'left'),'#text_filter',i18('_nombre'));
		   $tabla->addCol(array('id'=>'data','type'=>'ro','width'=>'*','sort'=>'str','align'=>'left'),'#text_filter','
Condición de búsqueda');
		}

	   $data = array('__SCOPE__'=>$scope);
	   $result = doQuery('info_search_store',$data);
	   foreach($result['obj'] as $r){
	      $row_user = array('value'=>$r['value'],'name'=>$r['name']);
	      $row_meta = array('id'=>$r['id_search_store']);

			// Tratar la búsqueda almacenada para mostrarla por la interfaz
			$data_search = '<br>';
			$sep = '';
			$cnt = 0;
			$json_value = json_decode($r['value'],true);

			// Campos de usuario
			if($scope=='device' or $scope=='view_metric' or $scope=='view_remote'){
				foreach($json_value as $key=>$val){
					if(strpos($key,'custom_')===0)$a_struct2name[$scope][$key] = array('text'=>str_replace('custom_','',$key));
				}
			}

			foreach($json_value as $key=>$val){
				if($val['value']=='') continue;
				if($val['type'] == 'combo' AND strtoupper($val['value'])=='ALL') continue;
				
				if(array_key_exists($scope,$a_struct2name) AND array_key_exists($key,$a_struct2name[$scope]) AND array_key_exists($val['value'],$a_struct2name[$scope][$key]) AND array_key_exists('icon',$a_struct2name[$scope][$key]) AND array_key_exists($val['value'],$a_struct2name[$scope][$key]['icon']) ){
					$val['value'] = $a_struct2name[$scope][$key]['icon'][$val['value']];
				}else{
					$val['value'] = htmlspecialchars($val['value']);
				}
				if(array_key_exists($scope,$a_struct2name) AND array_key_exists($key,$a_struct2name[$scope]) ) $key = $a_struct2name[$scope][$key]['text'];


				// $data_search.=$sep.'<strong>'.$key.'</strong>:'.$val['value'];
				// $data_search.=$sep.$key.':<strong>'.$val['value'].'</strong>';
				$data_search.=$key.'=<strong>'.$val['value'].'</strong><br>';

/*
				if($val['type'] == 'combo' AND strtoupper($val['value'])=='ALL'){
					$data_search.=$sep.$key.':Todos';
				}else{
					$data_search.=$sep.$key.':'.$val['value'];
				}
*/
/*
				$cnt++;	
				if($cnt<3){
					$sep='   &   ';
				}else{
					$sep='   &<br>   ';
					$cnt = 0;
				}
*/
				$sep='   <br>   ';
			}
			$data_search.='<br>';
//print_r($data_search);
//exit;
			if($mode==1){
				if(!in_array($r['id_search_store'],$in_checked)) continue;
				$row_data = array($r['name'],$data_search);
			}
			elseif($in_checked==0){
		      $row_data = array(0,$r['name'],$data_search);
			}
			else{
            $asoc = (in_array($r['id_search_store'],$in_checked))?'<img src="images/mod_incluir16x16.png">':'<img src="images/mod_excluir16x16.png">';
		      $row_data = array(0,$asoc,$r['name'],$data_search);
			}
	      $tabla->addRow($row_meta,$row_data,$row_user);
	   }
	   $tabla->show();
	}

   /*
    * Función: common_search_store_delete()
    * Input:
    *        $id_search_store
    * Output:
    * Descr: Borra las búsquedas almacenadas indicadas
    *
    * Lugares: 
    *          mod_dispositivo_layout.php
   */
	function common_search_store_delete($id_search_store){
		$data = array('__ID_SEARCH_STORE__'=>$id_search_store);
	   $result = doQuery('delete_search_store',$data);
	   $dataXML['rc']  = $result['rc'];
		$dataXML['msg'] = ($result['rc']==0)?i18('_labusquedasehaeliminadocorrectamente'):i18('_hahabidoalgunproblemaaleliminarlabusqueda');
	   responseXML($dataXML);
	}

   /*
    * Función: common_search_store_save()
    * Input:
	 *        $name
	 *        $value
	 *        $scope
    *        $id_search_store
	 *		 	 $response: json|xml
    * Output:
    * Descr: Crea o modifica una búsqueda almacenada
    *
    * Lugares: 
    *          mod_dispositivo_layout.php
   */
	function common_search_store_save($name,$value,$scope,$id_search_store='',$response='xml'){
		$data = array('__ID_SEARCH_STORE__'=>$id_search_store,'__NAME__'=>$name,'__VALUE__'=>$value,'__SCOPE__'=>$scope,'__ID_USER__'=>$_SESSION['NUSER']);

	   // Crear una búsqueda
	   if($id_search_store=='' or $id_search_store=='-1'){
	      $result = doQuery('create_search_store',$data);
			$dataResponse['rc']  = $result['rc'];
			if($result['rc']==0) $dataResponse['msg'] = i18('_labusquedasehacreadocorrectamente');
			elseif($dataResponse['rc']==-5) $dataResponse['msg'] = i18('_existeotrabusqueda');
			else $dataResponse['msg'] = i18('_hahabidoalgunproblemaalcrearlabusqueda');
			// $dataResponse['msg'] = ($result['rc']==0)?i18('_labusquedasehacreadocorrectamente'):i18('_hahabidoalgunproblemaalcrearlabusqueda');
   	}
	   // Modificar una búsqueda
	   else{
   	   $result = doQuery('modify_search_store',$data);
			$dataResponse['rc']  = $result['rc'];
			$dataResponse['msg'] = ($result['rc']==0)?i18('_sehamodificadolabusquedacorrectamente'):i18('_hahabidoalgunproblemaalmodificarlabusqueda');
   	}
		if($response=='json') responseJSON($dataResponse);
		else responseXML($dataResponse);
	}

   /*
    * Función: common_conf_save()
    * Input:
    *        $id_user
    *        $params => Estructura json
    *        $scope => _do de la página (ej:mod_dispositivo_layout)
    * Output:
    * Descr: Almacena la configuración de visibilidad de la página indicada (almacena los elementos que se tienen que mostrar en el campo params de cfg_users)
    *
    * Lugares: 
    *          mod_dispositivo_layout.php
   */
	function common_conf_save($id_user,$params,$scope){
		$data = array('__ID_USER__'=>$id_user);
	   $result = doQuery('info_cfg_users',$data);
	   $r = $result['obj'][0];
	   $json_stored_params = json_decode($r['params'],true);
	   $json_stored_params[$scope] = $params;
	   $data = array('__PARAMS__'=>json_encode($json_stored_params),'__ID_USER__'=>$id_user);
	   $result = doQuery('update_params_cfg_users',$data);
	
	   $dataJSON['rc']  = 0;
	   $dataJSON['msg'] = i18('_okalmacenarconfiguracion');
	   responseJSON($dataJSON);
	}

   /*
    * Función: common_get_search_store()
    * Input:
	 *        $id_search_store
    * Output:
    * Descr: Devuelve la estructura que representa una búsqueda almacenada
    *
    * Lugares: 
    *          mod_dispositivo_layout.php
   */
	function common_get_search_store($id_search_store){
   	$data = array('__ID_SEARCH_STORE__'=>$id_search_store);
	   $result = doQuery('info_search_store_by_id',$data);
	   $r = $result['obj'][0];
	   echo $r['value'];
	}

	/*
	 * Función: common_get_devices_from_search_store()
	 * Input:
	 *        $a_id_search_store => array con id_search_store
	 * Output: 
	 *        $a_id_dev => array con los id_dev asociados
	 * Descr:
	 * Lugares:
	 *          mod_tareas_dispositivo.php
	*/
	function common_get_devices_from_search_store($a_id_search_store){
		$a_id_dev = array();

	   $posStart   = 0;
	   $count      = 1000000;
	   $order      = 'name ASC';
	   $cond       = '';
	   $sep_params = '';
	   $cid        = cid(_hidx);
	
		if(count($a_id_search_store)==0 OR (count($a_id_search_store)==1 AND $a_id_search_store[0]=='')){
		}
		else{

		   // /////////////////////////////////////////////////// //
		   // Paso 1 START: Crear la tabla temporal con los datos //
		   // /////////////////////////////////////////////////// //

         // Se tiene en cuenta el perfil de usuario
         $data  = array('__POSSTART__'=>$posStart,'__COUNT__'=>$count,'__CONDITION__'=>$cond,'__ORDERBY__'=>$order, '__ID_CFG_OP__'=>$_SESSION['ORGPRO'],'__CID__'=>$cid);

         // Se obtienen los campos de usuario que hay definidos en el sistema
			$data = array();
         $result = doQuery('get_user_fields',$data);
         $user_fields = '';
         $array_user_fields = array();
         $a_user_fields_types = array();
         foreach ($result['obj'] as $r){
            $user_fields.=",c.columna{$r['id']}";
            $array_user_fields[]="columna{$r['id']}";
            $a_user_fields_types["columna{$r['id']}"]=$r['type'];
         }

         // Se borra la tabla temporal t1
			$data = array();
         $result = doQuery('cnm_get_devices_layout_delete_temp',$data);

         // Se crea la tabla temporal con los dispositivos visibles. Se ponen por defecto con red,orange,yellow y cuantos=0
			$data = array();
         $result = doQuery('cnm_get_devices_layout_create_temp1',$data);

			$data = array('__USER_FIELDS__'=>$user_fields,'__ID_CFG_OP__'=>$_SESSION['ORGPRO'],'__CID__'=>$cid);
         $result = doQuery('cnm_get_devices_layout_create_temp2',$data);

         // Se obtienen los id_dev y las alertas
         $dispositivos_alarmados = dispositivos_alarmados();
         foreach($dispositivos_alarmados as $id_dev=>$disp){
            if ($disp['red']==0 and $disp['orange']==0 and $disp['yellow']==0 and $disp['blue']==0) continue;
            $data2=array('__ID_DEV__'=>$id_dev,'__RED__'=>$disp['red'],'__ORANGE__'=>$disp['orange'],'__YELLOW__'=>$disp['yellow'],'__BLUE__'=>$disp['blue']);
            $result2=doQuery('cnm_get_devices_layout_update_temp',$data2);
         }
	
		   // Obtener los tipos de los campos de la tabla t1
		   $a_table_descr = DDBB_Table_Info('t1');
		
		   // ///////////////////////////////////////////////// //
		   // Paso 1 END: Crear la tabla temporal con los datos //
		   // ///////////////////////////////////////////////// //
		
		   // /////////////////////////////////////////// //
		   // Paso 2 START: Componer la query de búsqueda //
		   // /////////////////////////////////////////// //
		   foreach($a_id_search_store as $i){
		      $data = array('__ID_SEARCH_STORE__'=>$i);
		      $result = doQuery('info_search_store_by_id',$data);
		      $r = $result['obj'][0];
		      $a_params = json_decode($r['value'],true);
		      $cond.=$sep_params."( ''='' ";
		      $sep_params = ' OR ';
		
		      foreach($a_params as $k_cond => $foo){
		         $v_cond = $foo['value'];
					if($v_cond=='') continue;

		         if($k_cond=='status'){
		            if($v_cond=='activ')      $cond.= " AND status=0 ";
		            elseif($v_cond=='desact') $cond.= " AND status=1 ";
		            elseif($v_cond=='mant')   $cond.= " AND status=2 ";
		         }
		         elseif($k_cond=='asoc'){
		            if($v_cond=='all') continue;
		            else $cond.= " AND asoc=$v_cond ";
		         }
		         elseif($k_cond=='type'){
		            if($v_cond=='none')       $cond.= " AND (type='' OR isnull(type)) ";
		            elseif($v_cond!='all'){
		               $data2=array('__ID_HOST_TYPE__'=>$v_cond);
		               $result2=doQuery('device_types_by_id',$data2);
		               $cond.= " AND type='{$result2['obj'][0]['descr']}' ";
		            }
		         }
		         elseif($k_cond=='critic'){
		            if($v_cond=='all')         continue;
		            elseif($v_cond=='high')    $cond.= " AND $k_cond IN (75,100) ";
		            elseif($v_cond=='medhigh') $cond.= " AND $k_cond IN (50,75,100) ";
		            else                       $cond.= " AND $k_cond=$v_cond";
		         }
		         elseif($k_cond=='system_red' or $k_cond=='system_orange' or $k_cond=='system_yellow' or $k_cond=='system_blue' or $k_cond=='system_cuantos'){
						$cond.=cond2query(str_replace('system_','',$k_cond),$v_cond,$a_table_descr);
		         }
		         elseif(strpos( $k_cond,'system_')!==false){
						$cond.=cond2query(str_replace('system_','',$k_cond),$v_cond,$a_table_descr);
		         }
		         elseif(strpos( $k_cond,'custom_')!==false){
		            $data2=array('__DESCR__'=>str_replace('custom_','',$k_cond));
		            $result2=doQuery('get_devices_custom_type_by_descr',$data2);
						$cond.=cond2query("columna".$result2['obj'][0]['id'],$v_cond,$a_table_descr);
		         }
		      }
		      $cond.=')';
		   }

		   // ///////////////////////////////////////// //
		   // Paso 2 END: Componer la query de búsqueda //
		   // ///////////////////////////////////////// //

		   // //////////////////////////////// //
		   // Paso 3 START: Devolver los datos //
		   // //////////////////////////////// //
			$data  = array('__POSSTART__'=>$posStart,'__COUNT__'=>$count,'__CONDITION__'=>$cond,'__ORDERBY__'=>$order);			
         $result = doQuery('cnm_get_devices_layout_lista',$data);
         foreach ($result['obj'] as $r)$a_id_dev[]=$r['id_dev'];
      }
      return $a_id_dev;
	}


	function common_views_get_table($mode=0,$input_params=array()){
      $tabla = new Table();
      $posStart    = 0;
      $count       = 1000000;
      // Filtros que ha puesto el usuario
      $params      = $input_params;

		if($mode==0){
		   $tabla->addCol(array('id'=>'checkbox','type'=>'ch','width'=>'25,25,false','sort'=>'int','align'=>'center'),'&nbsp;','&nbsp;');
		   $tabla->addCol(array('id'=>'red_alert','type'=>'ro','width'=>'22,22,true','sort'=>'int','align'=>'center'),'&nbsp;','<img src=images/alarm_ro.gif>');
		   $tabla->addCol(array('id'=>'orange_alert','type'=>'ro','width'=>'22,22,true','sort'=>'int','align'=>'center'),'&nbsp;','<img src=images/alarm_na.gif>');
		   $tabla->addCol(array('id'=>'yellow_alert','type'=>'ro','width'=>'22,22,true','sort'=>'int','align'=>'center'),'&nbsp;','<img src=images/alarm_am.gif>');
		   $tabla->addCol(array('id'=>'blue_alert','type'=>'ro','width'=>'22,22,true','sort'=>'int','align'=>'center'),'&nbsp;','<img src=images/alarm_az.gif>');
		   $tabla->addCol(array('id'=>'nmetric','type'=>'ro','width'=>'30,30,true','sort'=>'int','align'=>'center'),'&nbsp;','<img src="images/ico_graf_tab_off.gif" title="'.i18('_metricascurso').'">');
		   $tabla->addCol(array('id'=>'nremote','type'=>'ro','width'=>'30,30,true','sort'=>'int','align'=>'center'),'&nbsp;','<img src="images/ico_pq_remote.gif" title="'.i18('_alertasremotas').'">');
		   $tabla->addCol(array('id'=>'sev','type'=>'ro','width'=>'25,25,true','sort'=>'int','align'=>'center'),'&nbsp;',i18('_SEV'));
		   $tabla->addCol(array('id'=>'desc','type'=>'ro','width'=>'*,100,true','sort'=>'str','align'=>'left'),'#text_filter',i18('_DESCRIPCION'));
		   $tabla->addCol(array('id'=>'itil','type'=>'ro','width'=>'75,75,true','sort'=>'str','align'=>'left'),'#select_filter',i18('_ITIL'));
		   $tabla->addCol(array('id'=>'type','type'=>'ro','width'=>'150,150,true','sort'=>'str','align'=>'left'),'#select_filter_strict',i18('_TIPO'));
		}
		// API
		elseif($mode==3){
         $tabla->addCol(array(),'','id');
         $tabla->addCol(array(),'','redalerts');
         $tabla->addCol(array(),'','orangealerts');
         $tabla->addCol(array(),'','yellowalerts');
         $tabla->addCol(array(),'','bluealerts');
         $tabla->addCol(array(),'','nmetrics');
         $tabla->addCol(array(),'','nremote');
         $tabla->addCol(array(),'','sev');
         $tabla->addCol(array(),'','name');
         $tabla->addCol(array(),'','itil');
         $tabla->addCol(array(),'','type');
         $tabla->addCol(array(),'','livemetric');
         $tabla->addCol(array(),'','liveremote');
		}	
	

      // API: Se parsean los campos que introduce el usuario por los que entiende el sistema
      if($mode==3){
         $params = array();
         $a_parse = array(
            'id'              => 'id_cfg_view',
            'redalerts'       => 'red',
            'orangealerts'    => 'orange',
            'yellowalerts'    => 'yellow',
            'bluealerts'      => 'blue',
            'nmetrics'        => 'nmetrics',
            'nremote'         => 'nremote',
            'sev'             => 'severity',
            'name'            => 'name',
            'itil'            => 'itil_type',
            'type'            => 'type',
            'livemetric'      => 'live_metric',
            'liveremote'      => 'live_remote',
         );

         if(!empty($input_params)){
            foreach($input_params as $key=>$value){
               if(array_key_exists($key,$a_parse)) $params[$a_parse[$key]] = $value;
               else $params[$key] = $value;
            }
         }
      }

	   $cid    = 'default';
	   $cid_ip = local_ip();

	   // /////////////////////////////////////////////////// //
	   // Paso 1 START: Crear la tabla temporal con los datos //
	   // /////////////////////////////////////////////////// //

	   // Obtener los tipos de los campos de la tabla t1
	   $a_table_descr = DDBB_Table_Info('cfg_views');

	   // ///////////////////////////////////////////////// //
	   // Paso 1 END: Crear la tabla temporal con los datos //
	   // ///////////////////////////////////////////////// //
	
	   // /////////////////////////////////////////// //
	   // Paso 2 START: Componer la query de búsqueda //
	   // /////////////////////////////////////////// //
	   $cond  = '';
	   $order = ' name ASC';
	
		////////////////////////
	   // Parte de búsquedas //
   	////////////////////////
		if(! empty($params)){
		   foreach($params as $key=>$value) $params[$key]=mysql_real_escape_string($value);
		
		   foreach($params as $k_cond => $v_cond){
		      if($v_cond=='') continue;

	         if($k_cond=='severity'){
					if($v_cond=='')           continue;
     				elseif($v_cond=='red')    $cond.=' AND red>0 ';
			      elseif($v_cond=='orange') $cond.=' AND orange>0 ';
			      elseif($v_cond=='yellow') $cond.=' AND yellow>0 ';
			      elseif($v_cond=='blue')   $cond.=' AND blue>0 ';
			      elseif($v_cond=='all')    $cond.=' AND (red>0 OR orange>0 OR yellow>0) ';
					else                      $cond.=" AND severity=$v_cond ";
	         }
				elseif($k_cond=='type'){
					if($v_cond=='all' or $v_cond=='') continue;
					else               $cond.= " AND $k_cond='$v_cond'";
	         }
	         elseif($k_cond=='red' or $k_cond=='orange' or $k_cond=='yellow' or $k_cond=='blue' or $k_cond=='nmetrics' or $k_cond=='nremote' or $k_cond=='id_cfg_view'){
					if($k_cond=='id_cfg_view' AND $v_cond==0){
						continue;
					}
					$cond.=cond2query($k_cond,$v_cond,$a_table_descr);
	         }
	         else{
					$cond.=cond2query($k_cond,$v_cond,$a_table_descr);
	         }
      	}
		}

	   // ///////////////////////////////////////// //
	   // Paso 2 END: Componer la query de búsqueda //
	   // ///////////////////////////////////////// //

	   // //////////////////////////////// //
	   // Paso 3 START: Devolver los datos //
	   // //////////////////////////////// //
	
	   // En caso de ser administrador global vemos todas las vistas
	   $esAdministradorGlobal=$_SESSION['GLOBAL'];
	   $id_query=($esAdministradorGlobal)?'vistas_admin':'vistas_noadmin';

	   $data = array('__ID_USER__'=>$_SESSION['NUSER'],'__CONDITION__'=>$cond,'__CID__'=>$cid,'__LOGIN_NAME__'=>$_SESSION['LUSER'],'__CID_IP__'=>$cid_ip);
	   $result = doQuery($id_query,$data);
	
	   foreach ($result['obj'] as $r){
	      $row_meta = array('id'=>$r['id_cfg_view'].'-'.substr(md5(uniqid(rand(),true)),5));
	
	      if ($r['red']+$r['orange']+$r['yellow']>0) $row_meta['style']='color:red';
	
	      $bgClassRed=($r['red']>0)?'cell_red':'';
	      $bgClassOrange=($r['orange']>0)?'cell_orange':'';
	      $bgClassYellow=($r['yellow']>0)?'cell_yellow':'';
	      $bgClassBlue=($r['blue']>0)?'cell_blue':'';
	
	      $num_metrics  = $r['nmetrics'];
	      $num_remote   = $r['nremote'];
	
	
	      // Si es una vista global añadimos un icono que lo indique
	      $global = ($r['global']==0)?'':"&nbsp;<img src='images/ico_pq_global.png' style='width:13px; border-width:0'>";
	
	      if ($r['ruled']==1){
	         $ruled = "<A HREF='do.php?hidx="._hidx."&do=mod_vistas_graficas&accion=open_layout_flot&id_cfg_view={$r['id_cfg_view']}&PHPSESSID=".SESIONPHP."' TARGET='_blank' onClick=\"winopen(this.href,this.target,1020,600); return false;\"><img src='images/ico_graf_tab_off.gif' style='width:10px; border-width:0'></A>&nbsp;<A HREF='do.php?hidx="._hidx."&do=mod_vistas_documentacion&accion=open&id_cfg_view={$r['id_cfg_view']}&PHPSESSID=".SESIONPHP."' TARGET='_blank' onClick=\"winopen(this.href,this.target,900,600,1); return false;\"><img src='images/ico_pq_note.png' style='width:13px; border-width:0'></A>&nbsp;{$r['name']}&nbsp; <A HREF='do.php?hidx="._hidx."&do=mod_vistas_reglas&accion=open&id_cfg_view={$r['id_cfg_view']}&PHPSESSID=".SESIONPHP."' TARGET='_blank' onClick=\"winopen(this.href,this.target,1020,600); return false;\"><img src='images/mod_ruled16x16.png' style='width:13px; border-width:0'></A>&nbsp;$global";
	      }else{
	         $ruled = "<A HREF='do.php?hidx="._hidx."&do=mod_vistas_graficas&accion=open_layout_flot&id_cfg_view={$r['id_cfg_view']}&PHPSESSID=".SESIONPHP."' TARGET='_blank' onClick=\"winopen(this.href,this.target,1020,600); return false;\"><img src='images/ico_graf_tab_off.gif' style='width:10px; border-width:0'></A>&nbsp;<A HREF='do.php?hidx="._hidx."&do=mod_vistas_documentacion&accion=open&id_cfg_view={$r['id_cfg_view']}&PHPSESSID=".SESIONPHP."' TARGET='_blank' onClick=\"winopen(this.href,this.target,900,600,1); return false;\"><img src='images/ico_pq_note.png' style='width:13px; border-width:0'></A>&nbsp;{$r['name']}&nbsp;$global";
	      }
	
	      $row_user = array('id_cfg_view'=>$r['id_cfg_view']);
			if($mode==0){
		      $row_data = array(
		         array('value'=>0),
		         array('value'=>$r['red'],'class'=>$bgClassRed,'style'=>'color:black'),
		         array('value'=>$r['orange'],'class'=>$bgClassOrange,'style'=>'color:black'),
		         array('value'=>$r['yellow'],'class'=>$bgClassYellow,'style'=>'color:black'),
		         array('value'=>$r['blue'],'class'=>$bgClassBlue,'style'=>'color:black'),
		         array('value'=>$num_metrics,'style'=>'color:black'),
		
		         array('value'=>$num_remote,'style'=>'color:black'),
		
		         array('value'=>severity2string($r['severity'])),
		         array('value'=>$ruled),
		         array('value'=>_itil_str($r['itil_type'])),
		         array('value'=>($r['type']!='')?$r['type']:i18('_sintipo')),
		      );
		      $tabla->addRow2($row_meta,$row_data,$row_user);
			}

			elseif($mode==3){
				$row_data = array($r['id_cfg_view'],$r['red'],$r['orange'],$r['yellow'],$r['blue'],$num_metrics,$num_remote,$r['severity'],$r['name'],$r['itil_type'],$r['type'],$r['live_metric'],$r['live_remote']);
            $tabla->addRow($row_meta,$row_data,$row_user);
			}
	   }
	   if($mode==0) $tabla->show();
	   elseif($mode==3) return $tabla->xml();
	}

	function common_metrics_get_table($mode=0,$input_params=array(),$extra_params=array()){
		$tabla = new Table();
		/////////////
		// Titulos //
		/////////////
		// API
      if($mode==3){
         $tabla->addCol(array(),'','metricid');
         $tabla->addCol(array(),'','metricname');
         $tabla->addCol(array(),'','metrictype');
         $tabla->addCol(array(),'','metricitems');
         $tabla->addCol(array(),'','metricstatus');
         $tabla->addCol(array(),'','metricmname');
         $tabla->addCol(array(),'','metricsubtype');
         $tabla->addCol(array(),'','metriclevel1');
         $tabla->addCol(array(),'','metriclevel2');

         $tabla->addCol(array(),'','devicename');
         $tabla->addCol(array(),'','devicedomain');
         $tabla->addCol(array(),'','devicestatus');
         $tabla->addCol(array(),'','devicetype');
         $tabla->addCol(array(),'','deviceid');
         $tabla->addCol(array(),'','deviceip');

         $tabla->addCol(array(),'','monitorid');
         $tabla->addCol(array(),'','monitorname');
         $tabla->addCol(array(),'','monitorsevred');
         $tabla->addCol(array(),'','monitorsevorange');
         $tabla->addCol(array(),'','monitorsevyellow');
      }

		///////////
		// Datos //
		///////////
	   if($mode==3){
			$posStart    = $extra_params['posStart'];
	      $count       = $extra_params['count'];
	      $orderby     = $extra_params['orderby'];
	      $orderdirect = $extra_params['direct'];

			// Filtros que ha puesto el usuario
      	$params      = $input_params;
	   }

		$cid   = cid(_hidx);
	
	   // /////////////////////////////////////////////////// //
	   // Paso 1 START: Crear la tabla temporal con los datos //
	   // /////////////////////////////////////////////////// //

      // Se borra la tabla temporal t1
		$data = array();
      $result = doQuery('get_all_metrics_delete_temp',$data);


      // Se crea la tabla temporal con las métricas y los datos visibles
		$data = array('__ID_CFG_OP__'=>$_SESSION['ORGPRO'],'__CID__'=>$cid);
      $result = doQuery('get_all_metrics_create_temp1',$data);

		// Se actualizan los campos severityred,severityorange y severityyellow
      $cond = " ";
      ////////////////////////
      // Parte de búsquedas //
      ////////////////////////
      if(! empty($params)){
         foreach($params as $key=>$value) $params[$key]=mysql_real_escape_string($value);

         foreach($params as $k_cond => $v_cond){
            if($v_cond=='') continue;
            $cond.=cond2query($k_cond,$v_cond,$a_table_descr);
         }
      }


      $data = array('__CONDITION__'=>$cond);

		$data = array();
		$result = doQuery('get_all_metrics_create_lista_all',$data);
		foreach($result['obj'] as $r){
			if($r['expr']!=''){

				$a_expr = explode(':',$r['expr']);
            if(count($a_expr)>1){
					$data2 = array('__METRICID__'=>$r['metricid'],'__MONITORSEVRED__'=>$a_expr[0],'__MONITORSEVORANGE__'=>$a_expr[1],'__MONITORSEVYELLOW__'=>$a_expr[2]);
					$result2 = doQuery('get_all_metrics_create_temp1_update_all_severity',$data2);
            }
				else{
               if($r['severity']==1){
						$data2 = array('__METRICID__'=>$r['metricid'],'__MONITORSEVRED__'=>$r['expr'],'__MONITORSEVORANGE__'=>'','__MONITORSEVYELLOW__'=>'');
						$result2 = doQuery('get_all_metrics_create_temp1_update_all_severity',$data2);
					}
               elseif($r['severity']==2){
						$data2 = array('__METRICID__'=>$r['metricid'],'__MONITORSEVRED__'=>'','__MONITORSEVORANGE__'=>$r['expr'],'__MONITORSEVYELLOW__'=>'');
						$result2 = doQuery('get_all_metrics_create_temp1_update_all_severity',$data2);
					}
               elseif($r['severity']==3){
						$data2 = array('__METRICID__'=>$r['metricid'],'__MONITORSEVRED__'=>'','__MONITORSEVORANGE__'=>'','__MONITORSEVYELLOW__'=>$r['expr']);
						$result2 = doQuery('get_all_metrics_create_temp1_update_all_severity',$data2);
					}
            }
			}
		}
	
	   // Obtener los tipos de los campos de la tabla t1
	   $a_table_descr = DDBB_Table_Info('t1');
	
	   // ///////////////////////////////////////////////// //
	   // Paso 1 END: Crear la tabla temporal con los datos //
	   // ///////////////////////////////////////////////// //
	
	   // /////////////////////////////////////////// //
	   // Paso 2 START: Componer la query de búsqueda //
	   // /////////////////////////////////////////// //
	   $cond = " ";
	   $order = ' metricid ASC';
	
		////////////////////////
	   // Parte de búsquedas //
   	////////////////////////
		if(! empty($params)){
		   foreach($params as $key=>$value) $params[$key]=mysql_real_escape_string($value);
		
		   foreach($params as $k_cond => $v_cond){
		      if($v_cond=='') continue;
				$cond.=cond2query($k_cond,$v_cond,$a_table_descr);
      	}
		}
	
	   if($orderby!=''){
	      if ($orderdirect=='des') $orderdirect = "DESC";
	      else                     $orderdirect = "ASC";
		
			if($orderby=='deviceip') $order = "INET_ATON(deviceip) $orderdirect";
			else                     $order = "$orderby $orderdirect";
	   }
	
	   // ///////////////////////////////////////// //
	   // Paso 2 END: Componer la query de búsqueda //
	   // ///////////////////////////////////////// //
	
	   // //////////////////////////////// //
	   // Paso 3 START: Devolver los datos //
	   // //////////////////////////////// //

      // Se obtienen las métricas
		$data  = array('__POSSTART__'=>$posStart,'__COUNT__'=>$count,'__CONDITION__'=>$cond,'__ORDERBY__'=>$order);
      $result = doQuery('get_all_metrics_create_lista',$data);
      foreach ($result['obj'] as $r){
         $row_user = array();
         $row_meta = array('id'=>$r['metricid']);

         // API
         if($mode==3){
            $row_data = array($r['metricid'],$r['metricname'],$r['metrictype'],$r['metricitems'],$r['metricstatus'],$r['metricmname'],$r['metricsubtype'],$r['metriclevel1'],$r['metriclevel2'],$r['devicename'],$r['devicedomain'],$r['devicestatus'],$r['devicetype'],$r['deviceid'],$r['deviceip'],$r['monitorid'],$r['monitorname'],$r['monitorsevred'],$r['monitorsevorange'],$r['monitorsevyellow']);
            if(!empty($array_user_fields)){
               foreach ($array_user_fields as $field) $row_data[]=$r[$field];
            }
            $tabla->addRow($row_meta,$row_data,$row_user);
         }
      }
	
		$data  = array('__CONDITION__'=>$cond);
      $result = doQuery('get_all_metrics_create_count',$data);
      $cuantos = $result['obj'][0]['cuantos'];

      if($mode==0) $tabla->showData($cuantos,$posStart);
      elseif($mode==3) return $tabla->xml();
      else return  $tabla->xml();
	}

	function common_views_get_metrics($mode,$id_cfg_view,$input_params,$extra_params){
		$tabla = new Table();

      $cid    = cid(_hidx);
      $cid_ip = local_ip();

		/////////////
		// Titulos //
		/////////////
		// API
      if($mode==3){
         $tabla->addCol(array(),'','metricid');
         $tabla->addCol(array(),'','metricname');
         $tabla->addCol(array(),'','metrictype');
         $tabla->addCol(array(),'','metricitems');
         $tabla->addCol(array(),'','metricstatus');
         $tabla->addCol(array(),'','metricmname');
         $tabla->addCol(array(),'','metricsubtype');
         $tabla->addCol(array(),'','metriclevel1');
         $tabla->addCol(array(),'','metriclevel2');

         $tabla->addCol(array(),'','devicename');
         $tabla->addCol(array(),'','devicedomain');
         $tabla->addCol(array(),'','devicestatus');
         $tabla->addCol(array(),'','devicetype');
         $tabla->addCol(array(),'','deviceid');
         $tabla->addCol(array(),'','deviceip');

         $tabla->addCol(array(),'','monitorid');
         $tabla->addCol(array(),'','monitorname');
         $tabla->addCol(array(),'','monitorsevred');
         $tabla->addCol(array(),'','monitorsevorange');
         $tabla->addCol(array(),'','monitorsevyellow');

         $tabla->addCol(array(),'','viewname');
         $tabla->addCol(array(),'','viewid');
         $tabla->addCol(array(),'','viewtype');
      }

		///////////
		// Datos //
		///////////
	   if($mode==3){
			$posStart    = $extra_params['posStart'];
	      $count       = $extra_params['count'];
	      $orderby     = $extra_params['orderby'];
	      $orderdirect = $extra_params['direct'];

			// Filtros que ha puesto el usuario
      	$params      = $input_params;
	   }

	
	   // /////////////////////////////////////////////////// //
	   // Paso 1 START: Crear la tabla temporal con los datos //
	   // /////////////////////////////////////////////////// //

      // Se borra la tabla temporal t1
		$data = array();
      $result = doQuery('get_view_metrics_delete_temp',$data);

		// Obtener las métricas de todas las vistas
		if($id_cfg_view==0){
      	// Se crea la tabla temporal con las métricas y los datos visibles
			$data = array('__CID__'=>$cid,'__CID_IP__'=>$cid_ip);
	      $result = doQuery('get_all_view_metrics_create_temp1',$data);
		}
		// Obtener las métricas de la vista indicada
		else{
      	// Se crea la tabla temporal con las métricas y los datos visibles
			$data = array('__ID_CFG_VIEW__'=>$id_cfg_view,'__CID__'=>$cid,'__CID_IP__'=>$cid_ip);
	      $result = doQuery('get_view_metrics_create_temp1',$data);
		}
	
      // Se actualizan los campos monitorsevred,monitorsevorange y monitorsevyellow
      $data = array();
      $result = doQuery('get_view_metrics_create_lista_all',$data);
      foreach($result['obj'] as $r){
         if($r['expr']!=''){

            $a_expr = explode(':',$r['expr']);
            if(count($a_expr)>1){
               $data2 = array('__METRICID__'=>$r['metricid'],'__MONITORSEVRED__'=>$a_expr[0],'__MONITORSEVORANGE__'=>$a_expr[1],'__MONITORSEVYELLOW__'=>$a_expr[2]);
               $result2 = doQuery('get_all_metrics_create_temp1_update_all_severity',$data2);
            }
            else{
               if($r['severity']==1){
                  $data2 = array('__METRICID__'=>$r['metricid'],'__MONITORSEVRED__'=>$r['expr'],'__MONITORSEVORANGE__'=>'','__MONITORSEVYELLOW__'=>'');
                  $result2 = doQuery('get_all_metrics_create_temp1_update_all_severity',$data2);
               }
               elseif($r['severity']==2){
                  $data2 = array('__METRICID__'=>$r['metricid'],'__MONITORSEVRED__'=>'','__MONITORSEVORANGE__'=>$r['expr'],'__MONITORSEVYELLOW__'=>'');
                  $result2 = doQuery('get_all_metrics_create_temp1_update_all_severity',$data2);
               }
               elseif($r['severity']==3){
                  $data2 = array('__METRICID__'=>$r['metricid'],'__MONITORSEVRED__'=>'','__MONITORSEVORANGE__'=>'','__MONITORSEVYELLOW__'=>$r['expr']);
                  $result2 = doQuery('get_all_metrics_create_temp1_update_all_severity',$data2);
               }
            }
         }
      }

	   // Obtener los tipos de los campos de la tabla t1
	   $a_table_descr = DDBB_Table_Info('t1');
	
	   // ///////////////////////////////////////////////// //
	   // Paso 1 END: Crear la tabla temporal con los datos //
	   // ///////////////////////////////////////////////// //
	
	   // /////////////////////////////////////////// //
	   // Paso 2 START: Componer la query de búsqueda //
	   // /////////////////////////////////////////// //
      $cond = " ";
      $order = ' metricid ASC';

      ////////////////////////
      // Parte de búsquedas //
      ////////////////////////
      if(! empty($params)){
         foreach($params as $key=>$value) $params[$key]=mysql_real_escape_string($value);

         foreach($params as $k_cond => $v_cond){
            if($v_cond=='') continue;
            $cond.=cond2query($k_cond,$v_cond,$a_table_descr);
         }
      }

      if($orderby!=''){
         if ($orderdirect=='des') $orderdirect = "DESC";
         else                     $orderdirect = "ASC";

         if($orderby=='deviceip') $order = "INET_ATON(deviceip) $orderdirect";
         else                     $order = "$orderby $orderdirect";
      }
	
	   // ///////////////////////////////////////// //
	   // Paso 2 END: Componer la query de búsqueda //
	   // ///////////////////////////////////////// //
	
	   // //////////////////////////////// //
	   // Paso 3 START: Devolver los datos //
	   // //////////////////////////////// //
      // Se obtienen las métricas
		$data  = array('__POSSTART__'=>$posStart,'__COUNT__'=>$count,'__CONDITION__'=>$cond,'__ORDERBY__'=>$order);		
      $result = doQuery('get_view_metrics_create_lista',$data);

      foreach ($result['obj'] as $r){
         $row_user = array();
         $row_meta = array('id'=>$r['metricid']);

         // API
         if($mode==3){
            $row_data = array($r['metricid'],$r['metricname'],$r['metrictype'],$r['metricitems'],$r['metricstatus'],$r['metricmname'],$r['metricsubtype'],$r['metriclevel1'],$r['metriclevel2'],$r['devicename'],$r['devicedomain'],$r['devicestatus'],$r['devicetype'],$r['deviceid'],$r['deviceip'],$r['monitorid'],$r['monitorname'],$r['monitorsevred'],$r['monitorsevorange'],$r['monitorsevyellow'],$r['viewname'],$r['viewid'],$r['viewtype']);
            foreach ($array_user_fields as $field) $row_data[]=$r[$field];
            $tabla->addRow($row_meta,$row_data,$row_user);
         }
      }

		$data  = array('__CONDITION__'=>$cond);		
      $result = doQuery('get_view_metrics_create_count',$data);
      $cuantos = $result['obj'][0]['cuantos'];
      if($mode==0) $tabla->showData($cuantos,$posStart);
      else         return($tabla->xml());
	}



	function common_views_get_remote_alerts($mode,$id_cfg_view,$input_params,$extra_params){
		$tabla = new Table();
		/////////////
		// Titulos //
		/////////////
		// API
      if($mode==3){
         $tabla->addCol(array(),'','id');
         $tabla->addCol(array(),'','name');
         $tabla->addCol(array(),'','type');
         $tabla->addCol(array(),'','deviceid');
         $tabla->addCol(array(),'','deviceip');
      }

		///////////
		// Datos //
		///////////
	   if($mode==3){
			$posStart    = $extra_params['posStart'];
	      $count       = $extra_params['count'];
	      $orderby     = $extra_params['orderby'];
	      $orderdirect = $extra_params['direct'];

			// Filtros que ha puesto el usuario
      	$params      = $input_params;
	   }


	   // /////////////////////////////////////////////////// //
	   // Paso 1 START: Crear la tabla temporal con los datos //
	   // /////////////////////////////////////////////////// //

		$data = array();
      $result = doQuery('get_view_remotealerts_delete_temp',$data);

		$data = array('__ID_CFG_VIEW__'=>$id_cfg_view);
      $result = doQuery('get_view_remotealerts_create_temp1',$data);

	   // Obtener los tipos de los campos de la tabla t1
	   $a_table_descr = DDBB_Table_Info('t1');
	
	   // ///////////////////////////////////////////////// //
	   // Paso 1 END: Crear la tabla temporal con los datos //
	   // ///////////////////////////////////////////////// //
	
	   // /////////////////////////////////////////// //
	   // Paso 2 START: Componer la query de búsqueda //
	   // /////////////////////////////////////////// //
	   $cond = " ";
	   $order = ' name ASC';
	
		////////////////////////
	   // Parte de búsquedas //
   	////////////////////////
		if(! empty($params)){
		   foreach($params as $key=>$value) $params[$key]=mysql_real_escape_string($value);
		
		   foreach($params as $k_cond => $v_cond){
		      if($v_cond=='') continue;
				$cond.=cond2query($k_cond,$v_cond,$a_table_descr);
      	}
		}
	
	   if($orderby!=''){
	      if ($orderdirect=='des') $orderdirect = "DESC";
	      else                     $orderdirect = "ASC";
		
			if($orderby=='deviceip') $order = "INET_ATON(deviceip) $orderdirect";
			else                     $order = "$orderby $orderdirect";
	   }
	   // ///////////////////////////////////////// //
	   // Paso 2 END: Componer la query de búsqueda //
	   // ///////////////////////////////////////// //
	
	   // //////////////////////////////// //
	   // Paso 3 START: Devolver los datos //
	   // //////////////////////////////// //
    	$data  = array('__POSSTART__'=>$posStart,'__COUNT__'=>$count,'__CONDITION__'=>$cond,'__ORDERBY__'=>$order);
      $result = doQuery('get_view_remotealerts_create_lista',$data);
      foreach ($result['obj'] as $r){
         $row_user = array();
         $row_meta = array('id'=>$r['id']);

         // API
         if($mode==3){
            $row_data = array($r['id'],$r['name'],$r['type'],$r['deviceid'],$r['deviceip']);
            foreach ($array_user_fields as $field) $row_data[]=$r[$field];
            $tabla->addRow($row_meta,$row_data,$row_user);
         }
      }

    	$data  = array('__CONDITION__'=>$cond);
      $result = doQuery('get_view_remotealerts_create_count',$data);
      $cuantos = $result['obj'][0]['cuantos'];

      if($mode==0) $tabla->showData($cuantos,$posStart);
      else         return($tabla->xml());
	}


	function common_alerts_get_table($mode,$input_params,$extra_params){
		$tabla = new Table();
		/////////////
		// Titulos //
		/////////////
		// API
      if($mode==3){
         $tabla->addCol(array(),'','id');
	      $tabla->addCol(array(),'','ack');
	      $tabla->addCol(array(),'','ticket');
	      $tabla->addCol(array(),'','severity');
	      $tabla->addCol(array(),'','critic');
	      $tabla->addCol(array(),'','type');
	      $tabla->addCol(array(),'','date');
	      $tabla->addCol(array(),'','devicename');
	      $tabla->addCol(array(),'','devicedomain');
	      $tabla->addCol(array(),'','deviceip');
	      $tabla->addCol(array(),'','cause');
	      $tabla->addCol(array(),'','counter');
	      $tabla->addCol(array(),'','event');
	      $tabla->addCol(array(),'','lastupdate');
      }

		///////////
		// Datos //
		///////////
	   if($mode==3){
			$posStart    = $extra_params['posStart'];
	      $count       = $extra_params['count'];
	      $orderby     = $extra_params['orderby'];
	      $orderdirect = $extra_params['direct'];

			// Filtros que ha puesto el usuario
      	$params      = $input_params;
	   }

      // API: Se parsean los campos que introduce el usuario por los que entiende el sistema
      if($mode==3){
         $params = array();
         // Campos de sistema
         $a_parse = array(
            'id'           => 'id_alert',
            'ack'          => 'ack',
            'ticket'       => 'ticket',
            'severity'     => 'severity',
            'critic'       => 'critic',
            'type'         => 'type',
            'devicename'   => 'name',
            'devicedomain' => 'domain',
            'deviceip'     => 'ip',
            'cause'        => 'cause',
            'counter'      => 'counter',
            'event'        => 'event',
            'lastupdate'   => 'last_update',
         );

         if(!empty($input_params)){
	         foreach($input_params as $key=>$value){
	            if(array_key_exists($key,$a_parse)) $params[$a_parse[$key]] = $value;
	            else $params[$key] = $value;
	         }
			}
      }


	   $cid    = 'default';
	   $cid_ip = local_ip();


	   // /////////////////////////////////////////////////// //
	   // Paso 1 START: Crear la tabla temporal con los datos //
	   // /////////////////////////////////////////////////// //
		$data = array();
      $result = doQuery('cnm_alerts_delete_temp',$data);

		$data = array('__LOGIN_NAME__'=>$_SESSION['LUSER'],'__CID__'=>$cid,'__CID_IP__'=>$cid_ip);
      $result = doQuery('cnm_alerts_create_temp',$data);

	   // Obtener los tipos de los campos de la tabla t1
	   $a_table_descr = DDBB_Table_Info('t1');
	
	   // ///////////////////////////////////////////////// //
	   // Paso 1 END: Crear la tabla temporal con los datos //
	   // ///////////////////////////////////////////////// //
	
	   // /////////////////////////////////////////// //
	   // Paso 2 START: Componer la query de búsqueda //
	   // /////////////////////////////////////////// //
	   $cond = "(''=''";
	   $order = ' date DESC';
	
	   ////////////////////////
	   // Parte de búsquedas //
	   ////////////////////////
	   foreach($params as $key=>$value) $params[$key]=mysql_real_escape_string($value);

	   foreach($params as $k_cond => $v_cond){
	      if($v_cond=='') continue;

	      if ($k_cond=='type'){
	         if(strtolower($v_cond)!='all')$cond.= " AND $k_cond='$v_cond'";
	         else continue;
	      }
	      else{
            $cond.=cond2query($k_cond,$v_cond,$a_table_descr);
	      }
	   }
	   $cond.=')';

	   if($orderby!=''){
	      if ($orderdirect=='des') $orderdirect = "DESC";
	      else $orderdirect = "ASC";

	      if($orderby=='checkbox') $order = " label $orderdirect";
	      elseif($orderby=='ip')   $order = " INET_ATON(ip) $orderdirect";
	      else $order = " $orderby $orderdirect";
	   }

	   // ///////////////////////////////////////// //
	   // Paso 2 END: Componer la query de búsqueda //
	   // ///////////////////////////////////////// //
	
	   // //////////////////////////////// //
	   // Paso 3 START: Devolver los datos //
	   // //////////////////////////////// //
	   $data   = array('__POSSTART__'=>$posStart,'__COUNT__'=>$count,'__CONDITION__'=>$cond,'__ORDERBY__'=>$order);
      $result = doQuery('cnm_alerts_get_list',$data);

      // Se obtienen las alertas
      foreach ($result['obj'] as $r){
         $row_meta = array('id'=>$r['id_alert']);
         $row_data = array($r['id_alert'],$r['ack'],$r['ticket'],$r['severity'],$r['critic'],$r['type'],$r['date'],$r['name'],$r['domain'],$r['ip'],$r['label'],$r['counter'],$r['event_data'],$r['date_last']);
         $row_user = array();
         $tabla->addRow($row_meta,$row_data,$row_user);
      }

		$data   = array('__CONDITION__'=>$cond);
      $result = doQuery('cnm_alerts_count',$data);
      $cuantos = $result['obj'][0]['cuantos'];

      if($mode==0) $tabla->showData($cuantos,$posStart);
      else return  $tabla->xml();
	}

	/*
	* Function: common_alerts_store_get_table()
	* Input:
	*    $mode
	*    $input_params
	*    $extra_params
	* Output:
	* Descr:
	*/
	function common_alerts_store_get_table($mode,$input_params,$extra_params){
		$tabla = new Table();
		/////////////
		// Titulos //
		/////////////
		// API
      if($mode==3){
         $tabla->addCol(array(),'','id');
	      $tabla->addCol(array(),'','ack');
	      $tabla->addCol(array(),'','ticket');
	      $tabla->addCol(array(),'','severity');
	      $tabla->addCol(array(),'','critic');
	      $tabla->addCol(array(),'','type');
	      $tabla->addCol(array(),'','date');
	      $tabla->addCol(array(),'','devicename');
	      $tabla->addCol(array(),'','devicedomain');
	      $tabla->addCol(array(),'','deviceip');
	      $tabla->addCol(array(),'','cause');
	      $tabla->addCol(array(),'','duration');
	      $tabla->addCol(array(),'','event');
      }

		///////////
		// Datos //
		///////////
	   if($mode==3){
			$posStart    = $extra_params['posStart'];
	      $count       = $extra_params['count'];
	      $orderby     = $extra_params['orderby'];
	      $orderdirect = $extra_params['direct'];

			// Filtros que ha puesto el usuario
      	$params      = $input_params;
	   }

      // API: Se parsean los campos que introduce el usuario por los que entiende el sistema
      if($mode==3){
         $params = array();
         // Campos de sistema
         $a_parse = array(
            'id'           => 'id_alert',
            'ack'          => 'ack',
            'ticket'       => 'ticket',
            'severity'     => 'severity',
            'critic'       => 'critic',
            'type'         => 'type',
				'date'         => 'date',
            'devicename'   => 'name',
            'devicedomain' => 'domain',
            'deviceip'     => 'ip',
            'cause'        => 'cause',
            'duration'     => 'duration',
            'event'        => 'event',
         );

         if(!empty($input_params)){
	         foreach($input_params as $key=>$value){
	            if(array_key_exists($key,$a_parse)) $params[$a_parse[$key]] = $value;
	            else $params[$key] = $value;
	         }
			}
      }


	   $cid    = 'default';
	   $cid_ip = local_ip();


	   // /////////////////////////////////////////////////// //
	   // Paso 1 START: Crear la tabla temporal con los datos //
	   // /////////////////////////////////////////////////// //
		$data = array();
      $result = doQuery('cnm_halerts_delete_temp',$data);

	   $data = array('__USER_FIELDS__'=>$user_fields,'__ID_CFG_OP__'=>$_SESSION['ORGPRO']);
	   $result = doQuery('cnm_halerts_create_temp_new',$data);

	   // Obtener los tipos de los campos de la tabla t1
	   $a_table_descr = DDBB_Table_Info('t1');
	
	   // ///////////////////////////////////////////////// //
	   // Paso 1 END: Crear la tabla temporal con los datos //
	   // ///////////////////////////////////////////////// //
	
	   // /////////////////////////////////////////// //
	   // Paso 2 START: Componer la query de búsqueda //
	   // /////////////////////////////////////////// //
	   $cond = "(''=''";
	   $order = ' date DESC';
	
	   ////////////////////////
	   // Parte de búsquedas //
	   ////////////////////////
	   foreach($params as $key=>$value) $params[$key]=mysql_real_escape_string($value);

	   foreach($params as $k_cond => $v_cond){
	      if($v_cond=='') continue;

	      if ($k_cond=='type'){
	         if(strtolower($v_cond)!='all')$cond.= " AND $k_cond='$v_cond'";
	         else continue;
	      }
	      else{
            $cond.=cond2query($k_cond,$v_cond,$a_table_descr);
	      }
	   }
	   $cond.=')';

	   if($orderby!=''){
	      if ($orderdirect=='des') $orderdirect = "DESC";
	      else $orderdirect = "ASC";

	      if($orderby=='checkbox') $order = " label $orderdirect";
	      elseif($orderby=='ip')   $order = " INET_ATON(ip) $orderdirect";
	      else $order = " $orderby $orderdirect";
	   }

	   // ///////////////////////////////////////// //
	   // Paso 2 END: Componer la query de búsqueda //
	   // ///////////////////////////////////////// //
	
	   // //////////////////////////////// //
	   // Paso 3 START: Devolver los datos //
	   // //////////////////////////////// //
	   $data   = array('__POSSTART__'=>$posStart,'__COUNT__'=>$count,'__CONDITION__'=>$cond,'__ORDERBY__'=>$order);
      $result = doQuery('cnm_alerts_get_list',$data);

      // Se obtienen las alertas
      foreach ($result['obj'] as $r){
         $row_meta = array('id'=>$r['id_alert']);
         $row_data = array($r['id_alert'],$r['ack'],$r['ticket'],$r['severity'],$r['critic'],$r['type'],$r['date'],$r['name'],$r['domain'],$r['ip'],$r['label'],$r['duration'],$r['event_data']);
         $row_user = array();
         $tabla->addRow($row_meta,$row_data,$row_user);
      }

		$data   = array('__CONDITION__'=>$cond);
      $result = doQuery('cnm_alerts_count',$data);
      $cuantos = $result['obj'][0]['cuantos'];

      if($mode==0) $tabla->showData($cuantos,$posStart);
      else return  $tabla->xml();
	}


	function common_tickets_get_table($mode,$input_params,$extra_params){
		$tabla = new Table();
		$tabla->no_limit_words();
		/////////////
		// Titulos //
		/////////////
		// API
      if($mode==3){
         $tabla->addCol(array(),'','id');
	      $tabla->addCol(array(),'','alert');
	      $tabla->addCol(array(),'','devicename');
	      $tabla->addCol(array(),'','deviceip');
	      $tabla->addCol(array(),'','category');
	      $tabla->addCol(array(),'','description');
	      $tabla->addCol(array(),'','ticket');
	      $tabla->addCol(array(),'','user');
	      $tabla->addCol(array(),'','type');
			
         $tabla->addCol(array(),'','devicedomain');
         $tabla->addCol(array(),'','alertdatelast_human');
         $tabla->addCol(array(),'','alertdatelast_timestamp');
         $tabla->addCol(array(),'','alertdatefirst_human');
         $tabla->addCol(array(),'','alertdatefirst_timestamp');
         $tabla->addCol(array(),'','alertcounter');
         $tabla->addCol(array(),'','alerttype');
         $tabla->addCol(array(),'','alertack');
         $tabla->addCol(array(),'','alertseverity');
         $tabla->addCol(array(),'','alertcause');

      }

		///////////
		// Datos //
		///////////
	   if($mode==3){
			$posStart    = $extra_params['posStart'];
	      $count       = $extra_params['count'];
	      $orderby     = $extra_params['orderby'];
	      $orderdirect = $extra_params['direct'];

			// Filtros que ha puesto el usuario
      	$params      = $input_params;
	   }

      // API: Se parsean los campos que introduce el usuario por los que entiende el sistema
      if($mode==3){
         $params = array();
         // Campos de sistema
         $a_parse = array(
            'id'          => 'id_ticket',
            'alert'       => 'id_alert',
         	'devicename'  => 'devicename',
	         'deviceip'    => 'deviceip',
	         'category'    => 'category',
	         'description' => 'descr',
            'ticket'      => 'ref',
            'user'        => 'login_name',
            'type'        => 'type',

				'devicedomain'              => 'devicedomain',
				'alertdatelast_human'       => 'alertdatelast_human',
				'alertdatelast_timestamp'   => 'alertdatelast_timestamp',
				'alertdatefirst_human'      => 'alertdatefirst_human',
				'alertdatefirst_timestamp'  => 'alertdatefirst_timestamp',
				'alertcounter'              => 'alertcounter',
				'alerttype'                 => 'alerttype',
				'alertack'                  => 'alertack',
				'alertseverity'             => 'alertseverity',
				'alertcause'                => 'alertcause',
         );

         foreach($input_params as $key=>$value){
            if(array_key_exists($key,$a_parse)) $params[$a_parse[$key]] = $value;
            else $params[$key] = $value;
         }
      }

      $cid   = cid(_hidx);

	   // /////////////////////////////////////////////////// //
	   // Paso 1 START: Crear la tabla temporal con los datos //
	   // /////////////////////////////////////////////////// //
		$data = array();
      $result = doQuery('get_tickets_delete_temp',$data);

		$data = array('__ID_CFG_OP__'=>$_SESSION['ORGPRO'],'__CID__'=>$cid);
      $result = doQuery('get_tickets_create_temp1',$data);
      // $result = doQuery('get_tickets_create_temp2',$data);

	   // Obtener los tipos de los campos de la tabla t1
	   $a_table_descr = DDBB_Table_Info('t1');

	   // ///////////////////////////////////////////////// //
	   // Paso 1 END: Crear la tabla temporal con los datos //
	   // ///////////////////////////////////////////////// //
	
	   // /////////////////////////////////////////// //
	   // Paso 2 START: Componer la query de búsqueda //
	   // /////////////////////////////////////////// //
	   $cond = " ";
	   $order = ' id_ticket DESC';
	
	   ////////////////////////
	   // Parte de búsquedas //
	   ////////////////////////
	   foreach($params as $key=>$value) {
			if(is_array($value)){
				foreach($value as $k => $v){
					$params[$key][$k]=mysql_real_escape_string($v);
				}
			}
			else{
				$params[$key]=mysql_real_escape_string($value);
			}
		}

	   foreach($params as $k_cond => $v_cond){
	      if($v_cond=='') continue;
			$cond.=cond2query($k_cond,$v_cond,$a_table_descr);
	   }
	   if($orderby!=''){
	      if ($orderdirect=='des') $orderdirect = "DESC";
	      else $orderdirect = "ASC";

	      if($orderby=='deviceip') $order = " INET_ATON(ip) $orderdirect";
	      else $order = " $orderby $orderdirect";
	   }

	   // ///////////////////////////////////////// //
	   // Paso 2 END: Componer la query de búsqueda //
	   // ///////////////////////////////////////// //
	
	   // //////////////////////////////// //
	   // Paso 3 START: Devolver los datos //
	   // //////////////////////////////// //
	   $data   = array('__POSSTART__'=>$posStart,'__COUNT__'=>$count,'__CONDITION__'=>$cond,'__ORDERBY__'=>$order);
      $result = doQuery('get_tickets_create_lista',$data);

      // Se obtienen los tickets
      foreach ($result['obj'] as $r){
         $row_meta = array('id'=>$r['id_alert']);
         // $row_data = array($r['id_ticket'],$r['id_alert'],$r['devicename'],$r['deviceip'],$r['category'],$r['descr'],$r['ref'],$r['login_name'],$r['type']);


         $row_data = array($r['id_ticket'],$r['id_alert'],$r['devicename'],$r['deviceip'],$r['category'],$r['descr'],$r['ref'],$r['login_name'],$r['type'],$r['devicedomain'],$r['alertdatelast_human'],$r['alertdatelast_timestamp'],$r['alertdatefirst_human'],$r['alertdatefirst_timestamp'],$r['alertcounter'],$r['alerttype'],$r['alertack'],$r['alertseverity'],$r['alertcause']);
         $row_user = array();
         $tabla->addRow($row_meta,$row_data,$row_user);
      }

	   $data   = array('__CONDITION__'=>$cond);
      $result = doQuery('get_tickets_create_count',$data);
      $cuantos = $result['obj'][0]['cuantos'];

      if($mode==0) $tabla->showData($cuantos,$posStart);
      else return  $tabla->xml();
	}

	/*
	* Function: common_views_update_live()
	* Input: 
	* 	$a_id_cfg_view: ids de las vistas dinámicas que se quieren actualizar
	* Output: 
	* 	0 = OK
	* 	1 = NOOK
	* Descr: 
	* 	Función que actualiza los elementos (métricas y alertas remotas) asociadas a vistas dinámicas. En caso de pasar un array vacio
	* 	como parámetro se actualizan todas las vistas.
	*/
	function common_views_update_live($a_id_cfg_view=array()){
		// En caso de no pasar ningun id_cfg_view se aplica sobre todas las vistas
		if(empty($a_id_cfg_view)){
			$data = array('__CID__'=>'default','__CID_IP__'=>local_ip());
			$result = doQuery('all_view',$data);
			foreach($result['obj'] as $r) $a_id_cfg_view[]=$r['id_cfg_view'];
		}

		// Almacenamos en $a_info_view las vistas indicando si son dinamicas con métricas o alertas remotas
		$a_info_view = array();
		$data = array('__CID__'=>'default','__CID_IP__'=>local_ip());
      $result = doQuery('all_view',$data);
      foreach($result['obj'] as $r) $a_info_view[$r['id_cfg_view']] = array('live_metric'=>$r['live_metric'],'live_remote'=>$r['live_remote']);
		foreach($a_id_cfg_view as $id_cfg_view){
			///////////////////////
			// Parte de métricas //
			///////////////////////
			if($a_info_view[$id_cfg_view]['live_metric'] == 1){
		   	$a_id_search_store = array();
			   $data = array('__ID_CFG_VIEW__'=>$id_cfg_view);
			   $result = doQuery('get_search_store_from_view_metric',$data);
			   foreach($result['obj'] as $r) $a_id_search_store[]=$r['id_search_store'];
			   // Se obtienen las metricas|dispositivos asociados a las búsquedas almacenadas
			   $a_info = common_views_get_metrics_devices_from_search_store($a_id_search_store);

			   // Se borran las métricas asociadas a la vista
			   $data = array('__ID_CFG_VIEW__'=>$id_cfg_view);
			   $result = doQuery('delete_all_metric_from_view',$data);
	
			   // Se asocia cada metrica|id_dev a la vista
			   foreach ($a_info as $metrica){
			      $data = array('__ID_METRIC__'=>$metrica['id_metric'],'__ID_CFG_VIEW__'=>$id_cfg_view);
			      $result = doQuery('vista_asociar_metrica',$data);
			   }
			}

			//////////////////////////////
			// Parte de alertas remotas //
			//////////////////////////////
         if($a_info_view[$id_cfg_view]['live_remote'] == 1){
			   $a_id_search_store = array();
			   $data = array('__ID_CFG_VIEW__'=>$id_cfg_view);
			   $result = doQuery('get_search_store_from_view_remote',$data);
			   foreach($result['obj'] as $r) $a_id_search_store[]=$r['id_search_store'];
			   // Se obtienen las alertas remotas|dispositivos asociados a las búsquedas almacenadas
			   $a_info = common_remotealerts_devices_from_search_store($a_id_search_store);

			   // Se borran las alertas remotas asociadas a la vista
			   $data = array('__ID_CFG_VIEW__'=>$id_cfg_view);
			   $result = doQuery('delete_all_remote_from_view',$data);

			   // Se asocia cada alerta remota|id_dev a la vista
			   foreach ($a_info as $alerta_remota){
			      $data = array('__ID_REMOTE_ALERT__'=>$alerta_remota['id_remote_alert'],'__ID_DEV__'=>$alerta_remota['id_dev'],'__ID_CFG_VIEW__'=>$id_cfg_view);
			      $result = doQuery('vista_asociar_alerta_remota',$data);
			   }
			}
		}
		$return = array(
			'rc'=>0,
			'rcstr'=>'OK'
		);
		return $return;
	}


	/*
	* Function: common_views_renew()
	* Input: 
	* Output: 
	* 	0 = OK
	* 	1 = NOOK
	* Descr: 
	* 	Función que actualiza los elementos (métricas y alertas remotas) asociadas a todas las vistas.
	*/
	function common_views_renew(){
		include_once('inc/class.cnmview.php');
		$data = array('__CID__'=>'default','__CID_IP__'=>local_ip());
		$result = doQuery('all_view',$data);
		foreach($result['obj'] as $r){
			$a_id_cfg_view[]=$r['id_cfg_view'];
			$view = new cnmview('default',local_ip(),$r['id_cfg_view']);
			$view->renew();
		}
		$return = array(
			'rc'    => 0,
			'rcstr' => 'OK'
		);
		return $return;
	}

	function common_views_get_metrics_devices_from_search_store($a_id_search_store){
	   $a_info = array();

	   $posStart   = 0;
	   $count      = 1000000;
	   $order      = 'name ASC';
	   $cond       = '';
	   $sep_params = '';
	   $cid        = 'default';
	
	   if(count($a_id_search_store)==0 OR (count($a_id_search_store)==1 AND $a_id_search_store[0]=='')){
	   }
	   else{

		   // /////////////////////////////////////////////////// //
		   // Paso 1 START: Crear la tabla temporal con los datos //
		   // /////////////////////////////////////////////////// //
         // Se tiene en cuenta el perfil de usuario
         $data  = array('__POSSTART__'=>$posStart,'__COUNT__'=>$count,'__CONDITION__'=>$cond,'__ORDERBY__'=>$order, '__ID_CFG_OP__'=>$_SESSION['ORGPRO'],'__CID__'=>$cid);
         // Se obtienen los campos de usuario que hay definidos en el sistema
			$data = array();
         $result = doQuery('get_user_fields',$data);
         $user_fields = '';
         $array_user_fields = array();
         $a_user_fields_types = array();
         foreach ($result['obj'] as $r){
            $user_fields.=",c.columna{$r['id']}";
            $array_user_fields[]="columna{$r['id']}";
            $a_user_fields_types["columna{$r['id']}"]=$r['type'];
         }

         // Se borra la tabla temporal t1,t2,t3 y t4
			$data = array();
         $result = doQuery('cnm_get_view_metrics_delete_temp',$data);

         // Se crea la tabla temporal
			$data = array();
         $result = doQuery('cnm_get_view_metrics_create_temp2',$data);

			$data = array('__USER_FIELDS__'=>$user_fields);
         $result = doQuery('cnm_get_view_metrics_create_temp3bis',$data);

		   // Obtener los tipos de los campos de la tabla t1
		   $a_table_descr = DDBB_Table_Info('t1');
		
		   // ///////////////////////////////////////////////// //
		   // Paso 1 END: Crear la tabla temporal con los datos //
		   // ///////////////////////////////////////////////// //
		
		   // /////////////////////////////////////////// //
		   // Paso 2 START: Componer la query de búsqueda //
		   // /////////////////////////////////////////// //
	      foreach($a_id_search_store as $i){
	         $data = array('__ID_SEARCH_STORE__'=>$i);
	         $result = doQuery('info_search_store_by_id',$data);
	         $r = $result['obj'][0];
	         $a_params = json_decode($r['value'],true);
	         $cond.=$sep_params."( ''='' ";
	         $sep_params = ' OR ';
	
	         foreach($a_params as $k_cond => $foo){
	            $v_cond = $foo['value'];

			      if($v_cond=='') continue;

	            if($k_cond=='status'){
	               if($v_cond=='activ')      $cond.= " AND status=0 ";
	               elseif($v_cond=='desact') $cond.= " AND status=1 ";
	               elseif($v_cond=='mant')   $cond.= " AND status=2 ";
	            }
					elseif($k_cond=='mtype'){
                  if($v_cond=='all') continue;
                  else $cond.= " AND mtype='$v_cond' ";
               }
	            elseif($k_cond=='asoc'){
	               if($v_cond=='all') continue;
	               else $cond.= " AND asoc=$v_cond ";
	            }
	            elseif($k_cond=='type'){
	               if($v_cond=='none')       $cond.= " AND (type='' OR isnull(type)) ";
	               elseif($v_cond!='all'){
	                  $data2=array('__ID_HOST_TYPE__'=>$v_cond);
	                  $result2=doQuery('device_types_by_id',$data2);
	                  $cond.= " AND type='{$result2['obj'][0]['descr']}' ";
	               }
	            }
	            elseif($k_cond=='critic'){
	               if($v_cond=='all')         continue;
	               elseif($v_cond=='high')    $cond.= " AND $k_cond IN (75,100) ";
	               elseif($v_cond=='medhigh') $cond.= " AND $k_cond IN (50,75,100) ";
	               else                       $cond.= " AND $k_cond=$v_cond";
	            }
   		      elseif($k_cond=='network'){
		            if($v_cond=='all') continue;
		            else $cond.= " AND $k_cond='$v_cond' ";
		         }
	            elseif($k_cond=='system_red' or $k_cond=='system_orange' or $k_cond=='system_yellow' or $k_cond=='system_blue' or $k_cond=='system_cuantos'){
						$cond.=cond2query(str_replace('system_','',$k_cond),$v_cond,$a_table_descr);
	            }
	            elseif(strpos( $k_cond,'system_')!==false){
						$cond.=cond2query(str_replace('system_','',$k_cond),$v_cond,$a_table_descr);
	            }
	            elseif(strpos( $k_cond,'custom_')!==false){
	               $data2=array('__DESCR__'=>str_replace('custom_','',$k_cond));
	               $result2=doQuery('get_devices_custom_type_by_descr',$data2);
						$cond.=cond2query("columna".$result2['obj'][0]['id'],$v_cond,$a_table_descr);
	            }
	         }
	         $cond.=')';
	      }
	
		   // ///////////////////////////////////////// //
		   // Paso 2 END: Componer la query de búsqueda //
		   // ///////////////////////////////////////// //
		
		   // //////////////////////////////// //
		   // Paso 3 START: Devolver los datos //
		   // //////////////////////////////// //
			$data  = array('__POSSTART__'=>$posStart,'__COUNT__'=>$count,'__CONDITION__'=>$cond,'__ORDERBY__'=>$order);
         $result = doQuery('cnm_get_view_metrics_lista',$data);
         foreach ($result['obj'] as $r){
            $a_info[] = array('id_dev'=>$r['id_dev'],'id_metric'=>$r['id_metric']);
         }
      }
      return $a_info;
	}

	function common_remotealerts_devices_from_search_store($a_id_search_store){
	   $a_info = array();

	   $posStart   = 0;
	   $count      = 1000000;
	   $order      = 'name ASC';
	   $cond       = '';
	   $sep_params = '';
	   $cid        = 'default';
	
	   if(count($a_id_search_store)==0 OR (count($a_id_search_store)==1 AND $a_id_search_store[0]=='')){
	   }
	   else{

		   // /////////////////////////////////////////////////// //
		   // Paso 1 START: Crear la tabla temporal con los datos //
		   // /////////////////////////////////////////////////// //

         // Se obtienen los campos de usuario que hay definidos en el sistema
			$data = array();
         $result = doQuery('get_user_fields',$data);
         $user_fields = '';
         $array_user_fields = array();
         $a_user_fields_types = array();
         foreach ($result['obj'] as $r){
            $user_fields.=",c.columna{$r['id']}";
            $array_user_fields[]="columna{$r['id']}";
            $a_user_fields_types["columna{$r['id']}"]=$r['type'];
         }

         // Se borra la tabla temporal t1,t2,t3 y t4
			$data = array();
         $result = doQuery('cnm_get_view_remote_delete_temp',$data);

			$data = array();
         $result = doQuery('cnm_get_view_remote_create_temp2',$data);

			$data = array('__USER_FIELDS__'=>$user_fields);
         $result = doQuery('cnm_get_view_remote_create_temp3bis',$data);


		   // Obtener los tipos de los campos de la tabla t1
		   $a_table_descr = DDBB_Table_Info('t1');
		
		   // ///////////////////////////////////////////////// //
		   // Paso 1 END: Crear la tabla temporal con los datos //
		   // ///////////////////////////////////////////////// //
		
		   // /////////////////////////////////////////// //
		   // Paso 2 START: Componer la query de búsqueda //
		   // /////////////////////////////////////////// //
	      foreach($a_id_search_store as $i){
	         $data = array('__ID_SEARCH_STORE__'=>$i);
	         $result = doQuery('info_search_store_by_id',$data);
	         $r = $result['obj'][0];
	         $a_params = json_decode($r['value'],true);
	         $cond.=$sep_params."( ''='' ";
	         $sep_params = ' OR ';
	
	         foreach($a_params as $k_cond => $foo){
	            $v_cond = $foo['value'];

			      if($v_cond=='') continue;

	            if($k_cond=='status'){
	               if($v_cond=='activ')      $cond.= " AND status=0 ";
	               elseif($v_cond=='desact') $cond.= " AND status=1 ";
	               elseif($v_cond=='mant')   $cond.= " AND status=2 ";
	            }
			      elseif($k_cond=='rtype'){
			         if(strtolower($v_cond)=='all') continue;
			         else $cond.= " AND rtype='$v_cond' ";
			      }
	            elseif($k_cond=='asoc'){
	               if($v_cond=='all') continue;
	               else $cond.= " AND asoc=$v_cond ";
	            }
   	         elseif($k_cond=='type'){
	               if($v_cond=='none')       $cond.= " AND (type='' OR isnull(type)) ";
	               elseif($v_cond!='all'){
	                  $data2=array('__ID_HOST_TYPE__'=>$v_cond);
	                  $result2=doQuery('device_types_by_id',$data2);
	                  $cond.= " AND type='{$result2['obj'][0]['descr']}' ";
	               }
	            }
	            elseif($k_cond=='critic'){
	               if($v_cond=='all')         continue;
	               elseif($v_cond=='high')    $cond.= " AND $k_cond IN (75,100) ";
	               elseif($v_cond=='medhigh') $cond.= " AND $k_cond IN (50,75,100) ";
	               else                       $cond.= " AND $k_cond=$v_cond";
	            }
			      elseif($k_cond=='network'){
			         if($v_cond=='all') continue;
			         else $cond.= " AND $k_cond='$v_cond' ";
			      }
	            elseif($k_cond=='system_red' or $k_cond=='system_orange' or $k_cond=='system_yellow' or $k_cond=='system_blue' or $k_cond=='system_cuantos'){
						$cond.=cond2query(str_replace('system_','',$k_cond),$v_cond,$a_table_descr);
	            }
	            elseif(strpos( $k_cond,'system_')!==false){
						$cond.=cond2query(str_replace('system_','',$k_cond),$v_cond,$a_table_descr);
	            }
	            elseif(strpos( $k_cond,'custom_')!==false){
	               $data2=array('__DESCR__'=>str_replace('custom_','',$k_cond));
	               $result2=doQuery('get_devices_custom_type_by_descr',$data2);
						$cond.=cond2query("columna".$result2['obj'][0]['id'],$v_cond,$a_table_descr);
	            }
	         }
	         $cond.=')';
	      }

		   // ///////////////////////////////////////// //
		   // Paso 2 END: Componer la query de búsqueda //
		   // ///////////////////////////////////////// //
		
		   // //////////////////////////////// //
		   // Paso 3 START: Devolver los datos //
		   // //////////////////////////////// //
			$data  = array('__POSSTART__'=>$posStart,'__COUNT__'=>$count,'__CONDITION__'=>$cond,'__ORDERBY__'=>$order);
         $result = doQuery('cnm_get_view_remote_lista',$data);
         foreach ($result['obj'] as $r){
            $a_info[] = array('id_dev'=>$r['id_dev'],'id_remote_alert'=>$r['id_remote_alert']);
         }
      }
	}

	function common_create_event($input_data){
		$status = 1;

		// Cuando se introduce un deviceip no dado de alta en el sistema se sustituye deviceip por el $input_data['REMOTE_ADDR'] y 
		// se almacena en $aux_deviceip el parámetro deviceip original para mostrarlo después
		$aux_deviceip     = '';
		// Esto mismo puede pasar con devicename + devicedomain y deviceid
		$aux_devicename   = '';
		$aux_devicedomain = '';
		$aux_deviceid     = '';

		if(array_key_exists('devicename',$input_data) AND (array_key_exists('devicedomain',$input_data))){
			$data = array('__NAME__'=>$input_data['devicename'],'__DOMAIN__'=>$input_data['devicedomain']);
			$result = doQuery('device_info_basic_by_name_domain',$data);
			if($result['cont']>0){
				$r = $result['obj'][0];
				$input_data['deviceip'] = $r['ip'];
				$input_data['deviceid'] = $r['id_dev'];
				$status = 0;
			}
			else{
				$aux_devicename   = $input_data['devicename'];
				$aux_devicedomain = $input_data['devicedomain'];

            $input_data['deviceip'] = $input_data['REMOTE_ADDR'];

            $data = array('__IP__'=>$input_data['deviceip']);
            $result = doQuery('device_info_basic_by_ip',$data);
            if($result['cont']>0){
               $r = $result['obj'][0];
               $input_data['devicename']   = $r['name'];
               $input_data['devicedomain'] = $r['domain'];
               $input_data['deviceid']     = $r['id_dev'];
               $status = 0;
            }
            else{
					$msg = 'No device with these devicename and devicedomain';
            }
			}
		}

		elseif(array_key_exists('deviceip',$input_data)){
         $data = array('__IP__'=>$input_data['deviceip']);
         $result = doQuery('device_info_basic_by_ip',$data);
         if($result['cont']>0){
            $r = $result['obj'][0];
            $input_data['devicename']   = $r['name'];
            $input_data['devicedomain'] = $r['domain'];
            $input_data['deviceid']     = $r['id_dev'];
            $status = 0;
         }
			// En caso de no existir el deviceip en el CNM, utilizamos la IP de origen del evento API
         else{
				$aux_deviceip = $input_data['deviceip'];
				$input_data['deviceip'] = $input_data['REMOTE_ADDR'];

	         $data = array('__IP__'=>$input_data['deviceip']);
	         $result = doQuery('device_info_basic_by_ip',$data);
	         if($result['cont']>0){
	            $r = $result['obj'][0];
	            $input_data['devicename']   = $r['name'];
	            $input_data['devicedomain'] = $r['domain'];
	            $input_data['deviceid']     = $r['id_dev'];
	            $status = 0;
   	      }
				else{
					$msg = 'No device with this deviceip';
				}
         }
		}

      elseif(array_key_exists('deviceid',$input_data)){
         $data = array('__ID_DEV__'=>$input_data['deviceid']);
         $result = doQuery('device_info_basic',$data);
         if($result['cont']>0){
            $r = $result['obj'][0];
            $input_data['devicename']   = $r['name'];
            $input_data['devicedomain'] = $r['domain'];
            $input_data['deviceip']     = $r['ip'];
            $status = 0;
         }
			else{
				$aux_deviceid = $input_data['deviceid'];

            $input_data['deviceip'] = $input_data['REMOTE_ADDR'];

            $data = array('__IP__'=>$input_data['deviceip']);
            $result = doQuery('device_info_basic_by_ip',$data);
            if($result['cont']>0){
               $r = $result['obj'][0];
               $input_data['devicename']   = $r['name'];
               $input_data['devicedomain'] = $r['domain'];
               $input_data['deviceid']     = $r['id_dev'];
               $status = 0;
            }
            else{
					$msg = 'No device with this deviceid';
            }
			}
		}
		// En caso de no haber ip,nombre+dominio o id de dispositivo se mira la ip de origen de la llamada al API
      else{
	      $data = array('__IP__'=>$input_data['REMOTE_ADDR']);
	      $result = doQuery('device_info_basic_by_ip',$data);
	      if($result['cont']>0){
	         $r = $result['obj'][0];
	         $input_data['devicename']   = $r['name'];
	         $input_data['devicedomain'] = $r['domain'];
	         $input_data['deviceid']     = $r['id_dev'];
         	$input_data['deviceip']     = $input_data['REMOTE_ADDR'];
	         $status = 0;
	      }
	      else{
	         $msg = 'No device with this source ip';
	      }
      }

		if($status==1){
	      return array(
	         'rc'    => $status,
	         'rcstr' => $msg
	      );
		}


		// Si el usuario ha introducido campos que no son los principales, se meten en una estructura json en el mensaje
		$a_exclude = array('devicename','devicedomain','deviceip','deviceid','msg','evkey','proccess');
		$a_json    = array();
		foreach($input_data as $key => $value){
			if(!in_array($key,$a_exclude)) $a_json[$key] = $value;
		}


		// Cuando se introduce un deviceip no dado de alta en el sistema se sustituye deviceip por el $input_data['REMOTE_ADDR'] y 
      // se almacena en $aux_deviceip el parámetro deviceip original para mostrarlo después
		if($aux_deviceip!='') $a_json['deviceip']=$aux_deviceip;

      // Esto mismo puede pasar con devicename + devicedomain y deviceid
      if($aux_devicename!='')   $a_json['devicename']=$aux_devicename;
      if($aux_devicedomain!='') $a_json['devicedomain']=$aux_devicedomain;
      if($aux_deviceid!='')     $a_json['deviceid']=$aux_deviceid;



		// Se compone el mensaje que se va a insertar en la BBDD
		if(count($a_json)>0){
			if(array_key_exists('msg',$input_data)){
				$aux_msg=$input_data['msg']."\n".json_encode($a_json);
			}else{
				$aux_msg=json_encode($a_json);
			}
		}
		else{
         if(array_key_exists('msg',$input_data)){
            $aux_msg=$input_data['msg'];
         }else{
            $aux_msg='';
         }
		}

		// En caso de no haber indicado el evkey se genera uno
		if(array_key_exists('evkey',$input_data)){
			$evkey = $input_data['evkey'];
		}else{
			$evkey = substr( md5($aux_msg),0,8);
		}

		// Se inserta en la BBDD
      $data  = array('__NAME__'=>$input_data['devicename'],'__DOMAIN__'=>$input_data['devicedomain'],'__IP__'=>$input_data['deviceip'],'__DATE__'=>time(),'__CODE__'=>1,'__PROCCESS__'=>$input_data['proccess'],'__MSG__'=>$aux_msg,'__MSG_CUSTOM__'=>'','__EVKEY__'=>$evkey,'__ID_DEV__'=>$input_data['deviceid']);
      $result = doQuery('create_event_api',$data);

      // Se obtiene el ultimo id
      $result = doQuery('last_id_inserted', $data);
      $return_id = $result['obj'][0]['last'];

      return array(
         'rc'=>0,
         'rcstr'=>'Event successfully created',
			'eventid'=>$return_id,
			'deviceip'=>$input_data['deviceip'],
			'msg'=>$aux_msg,
			'evkey'=>$evkey,
      );
	}

	function common_set_custom_data($input_data,$a_custom_data){
		$msg    = 'No device found';
		$status = 5;
     	if(array_key_exists('deviceip',$input_data)){
         $data = array('__IP__'=>$input_data['deviceip']);
         $result = doQuery('device_info_basic_by_ip',$data);
         if($result['cont']>0){
            $r = $result['obj'][0];
            $input_data['devicename']   = $r['name'];
            $input_data['devicedomain'] = $r['domain'];
            $input_data['deviceid']     = $r['id_dev'];
            $status = 0;
         }
         else{
				$status = 3;
            $msg = 'No device with this deviceip';
         }
      }
      elseif(array_key_exists('deviceid',$input_data)){
         $data = array('__ID_DEV__'=>$input_data['deviceid']);
         $result = doQuery('device_info_basic',$data);
         if($result['cont']>0){
            $r = $result['obj'][0];
            $input_data['devicename']   = $r['name'];
            $input_data['devicedomain'] = $r['domain'];
            $input_data['deviceip']     = $r['ip'];
            $status = 0;
         }
         else{
				$status = 4;
            $msg = 'No device with this deviceid';
         }
      }
		if($status!=0){
         return array(
            'rc'    => $status,
            'rcstr' => $msg
         );
		}

		$stat = 0;
      foreach($a_custom_data as $descr => $value){
			$data = array('__ID_DEV__'=>$input_data['deviceid'],'__DESCR__'=>$descr,'__COL_VALUE__'=>$value);
			$result = doQuery('insert_device_custom_data',$data);
			
			$result = doQuery('select_id_custom_type_by_descr',$data);
			if($result['cont']>0){
				$columnid = $result['obj'][0]['id'];
				$data['__COL_ID__'] = 'columna'.$columnid;	
				$result = doQuery('update_device_custom_data',$data);
				if($result['rc']!=0) $stat++;
			}else{
				$stat++;
			}
      }
		if($stat == 0){
	      return array(
	         'rc'    => 0,
	         'rcstr' => 'Data correctly modified',
	      );
		}
		elseif(count($a_custom_data)==$stat){
			return array(
            'rc'    => 2,
            'rcstr' => 'There was a problem modifying ALL fields',
         );
		}
		else{
         return array(
            'rc'    => 1,
            'rcstr' => 'There was a problem modifying SOME fields',
         );
		}
	}
	
	function common_create_device($a_input_data){
		$a_return = array('rc'=>0,'rcstr'=>'');
		$cid = cid(1);

		// Campos que deben existir, sino hay un error
		$a_must_fields = array('name','domain','snmpversion');

		// Metacampos
		$a_meta_fields = array(
		);

		// Campos de sistema
		$a_system_fields = array(
			'id'             => '',
			'name'           => '',
			'domain'         => '',
			'ip'             => '',
			'type'           => '',
			'snmpversion'    => '',
			'snmpcommunity'  => '',
			'snmpcredential' => '',
			'snmpsysdesc'    => '',
			'snmpsysoid'     => '',
			'snmpsysloc'     => '',
			'enterprise'     => '',
			'mac'            => '',
			'macvendor'      => '',
			'netmask'        => '',
			'network'        => '',
			'switch'         => '',
			'xagentversion'  => '',
			'entity'         => 0, // 0:dispositivo físico || 1:servicio web
			'geo'            => '',
			'critic'         => 50,
			'correlated'     => '',
			'status'         => 0,
			'profile'        => '',
		);

		// Campos de usuario
		$a_user_fields = array();

		// Se comprueba que estén todos los campos de sistema
		foreach($a_must_fields as $key){
			if(!array_key_exists($key,$a_input_data)){
				$a_return['rc'] = 1;
				$a_return['rcstr'] = "FIELD $key IS REQUIRED";
				return $a_return;
			}
		}

		// Se rellenan los metacampos, campos de sistema y de usuario
		foreach($a_input_data as $key => $value){
			if(array_key_exists($key,$a_meta_fields))       $a_meta_fields[$key] = $value;
			elseif(array_key_exists($key,$a_system_fields)) $a_system_fields[$key] = $value;
			else $a_user_fields[$key] = $value;
		}
/*
print_r($a_system_fields);
print"\n------------\n";
print_r($a_user_fields);
exit;
*/

		// //////////// //
		// VALIDACIONES //
		// //////////// //
      // if($a_system_fields['entity']==0 AND $a_system_fields['ip']==''){
      if($a_system_fields['ip']==''){
			$a_system_fields['ip'] = gethostbyname("{$a_system_fields['name']}.{$a_system_fields['domain']}");
			if (! preg_match('/\d+\.\d+\.\d+\.\d+/',$a_system_fields['ip']) ){
				$a_return['rc']    = 1;
	         $a_return['rcstr'] = "FIELD ip COULDN'T BE RESOLVED ({$a_system_fields['name']}.{$a_system_fields['domain']})";
         	return $a_return;
			}
      }
		if(($a_system_fields['snmpversion']==1 OR $a_system_fields['snmpversion']==2) AND $a_system_fields['snmpcommunity']==''){
			$a_return['rc']    = 1;
         $a_return['rcstr'] = "FIELD snmpcommunity IS REQUIRED WHEN snmpversion == {$a_system_fields['snmpversion']}";
         return $a_return;
		}	
		if($a_system_fields['snmpversion']==3 AND $a_system_fields['snmpcredential']==''){
         $a_return['rc']    = 1;
         $a_return['rcstr'] = "FIELD snmpcredential IS REQUIRED WHEN snmpversion == {$a_system_fields['snmpversion']}";
         return $a_return;
      }
		
		// //////////////////////////////////////////// //
	   // Obtención de datos: Es un dispositivo físico //
		// //////////////////////////////////////////// //
	   if($a_system_fields['entity']==0){
	      //Actualiza por snmp los parametros del dispositivo
	      list($a_system_fields['snmpsysdesc'],$a_system_fields['snmpsysoid'],$a_system_fields['snmpsysloc'],$a_system_fields['enterprise'],$a_system_fields['mac'],$a_system_fields['macvendor'],$a_system_fields['netmask'],$a_system_fields['network'],$a_system_fields['switch'])=_do_mib2_system($a_system_fields['ip'],$a_system_fields['snmpversion'],$a_system_fields['snmpcommunity'],$a_system_fields['snmpcredential']);
	
	      //Obtiene la version del agente remoto en caso de tenerla
	      $cmd="/opt/crawler/bin/libexec/mon_xagent -v -i {$a_system_fields['ip']}";
	      exec($cmd,$results);
			$a_system_fields['xagentversion']=$results[0]==''?'-':$results[0];
	      $aux_dev_ip = $a_system_fields['ip'];
	   }

		// ////////////////////////////////////// //
	   // Obtención de datos: Es un servicio web //
		// ////////////////////////////////////// //
	   elseif($a_system_fields['entity']==1){
	      $a_system_fields['snmpsysdesc']   = '';
	      $a_system_fields['snmpsysoid']    = '';
	      $a_system_fields['snmpsysloc']    = '';
	      $a_system_fields['enterprise']    = '';
	      $a_system_fields['mac']           = '';
	      $a_system_fields['macvendor']     = '';
	      $a_system_fields['netmask']       = '';
	      $a_system_fields['network']       = '';
	      $a_system_fields['switch']        = '';
	      $a_system_fields['xagentversion'] = '';
	      $aux_dev_ip = "{$a_system_fields['ip']}-".substr(md5($a_system_fields['name'].$a_system_fields['domain']),0,4);
	   }

/*
print_r($a_system_fields);
print"\n------------\n";
print_r($a_user_fields);
exit;
*/


	   ///////////////////////////
	   // INSERTAR CAMPOS FIJOS //
	   ///////////////////////////
	   $aux_community = $a_system_fields['snmpversion'] == 3?$a_system_fields['snmpcredential']:$a_system_fields['snmpcommunity'];
   	$data=array(
			'__NAME__'           => $a_system_fields['name'],
			'__DOMAIN__'         => $a_system_fields['domain'],
			'__STATUS__'         => $a_system_fields['status'],
			'__IP__'             => $aux_dev_ip,
			'__WBEM_USER__'      => '',
			'__WBEM_PWD__'       => '',
			'__SYSDESC__'        => $a_system_fields['snmpsysdesc'],
			'__SYSOID__'         => $a_system_fields['snmpsysoid'],
			'__SYSLOC__'         => $a_system_fields['snmpsysloc'],
			'__TYPE__'           => $a_system_fields['type'],
			'__VERSION__'        => $a_system_fields['snmpversion'],
			'__COMMUNITY__'      => $aux_community, 
			'__XAGENT_VERSION__' => $a_system_fields['xagentversion'],
			'__ENTERPRISE__'     => $a_system_fields['enterprise'],
			'__CORRELATED_BY__'  => $a_system_fields['correlated'], 
			'__MAC__'            => $a_system_fields['mac'], 
			'__MAC_VENDOR__'     => $a_system_fields['macvendor'], 
			'__CRITIC__'         => $a_system_fields['critic'],
			'__GEODATA__'        => $a_system_fields['geo'],
			'__NETWORK__'        => $a_system_fields['network'],
			'__SWITCH__'         => $a_system_fields['switch'],
			'__ENTITY__'         => $a_system_fields['entity'],
			'__ASSET_CONTAINER__'=>0
		);
	   $result = doQuery('create_device',$data);
	   if ($result['rc']!=0) {
         $a_return['rc']    = 1;
         $a_return['rcstr'] = "ERROR CREATING DEVICE (STEP 1):{$result['rcstr']}";
         return $a_return;
	   }

	   // Crea la red en cfg_networks. Si ya existe da error, por eso no e preocupa gestionar el error.
	   if($a_system_fields['network']!=''){
	      $data_net = array('__NETWORK__' => $a_system_fields['network']);
	      $result = doQuery('create_network', $data_net);
	   }

	   // ES NECESARIO CREAR EL FICHERO PARA QUE SE RECARGUE EL trap_manager (tiene un cache de nombre/ip/status).
	   $cmd="/usr/bin/sudo /etc/init.d/syslog-ng reload 2>&1";
  		exec($cmd,$results);

	   ///////////////////////
	   // OBTENER EL ID_DEV //
	   ///////////////////////
	   $result = doQuery('get_id_dev',$data);
	   $a_system_fields['id'] = $result['obj'][0]['id_dev'];

	   ////////////////////////////////////
	   // INSERTAR CAMPOS PERSONALIZADOS //
	   ////////////////////////////////////
	   $a_res=dispositivo_modificar_campos_personalizados($a_system_fields['id'],$a_user_fields);
	   if ($a_res['rc']>1){
         $a_return['rc']    = $a_res['rc'];
         $a_return['rcstr'] = "ERROR CREATING DEVICE (STEP 2):{$a_res['rcstr']}";
         return $a_return;
	   }

/*
	   //////////////////////////////////////////////////////////////////////////////////////////////
	   // INSERTAR EL DISPOSITIVO EN EL PERFIL ORGANIZATIVO GLOBAL Y EN LOS QUE INDIQUE EL USUARIO //
	   //////////////////////////////////////////////////////////////////////////////////////////////
	   $data = array('__ID_DEV__'=>$a_system_fields['id'],'__CID__'=>$cid);
	   $result = doQuery('insert_device_into_global_organizational_profile',$data);
*/	
	   //////////////////////////////////////////////////////////////////////////////////////////////
	   // INSERTAR EL DISPOSITIVO EN EL PERFIL ORGANIZATIVO GLOBAL Y EN LOS QUE INDIQUE EL USUARIO //
	   //////////////////////////////////////////////////////////////////////////////////////////////
		if($a_system_fields['profile']!=''){
			$a_profile = explode(',',$a_system_fields['profile']);
			$a_profile[]='Global';
			$a_res=dispositivo_asociar_perfiles($a_system_fields['id'],$a_profile,$cid);
	      if ($a_res['rc']>1){
	         $a_return['rc']    = $a_res['rc'];
	         $a_return['rcstr'] = "ERROR CREATING DEVICE (STEP 3):{$a_res['rcstr']}";
	         return $a_return;
	      }
		}

	   // Se prepara la accion de sincronizar el mapeo dispositivo->rol
	   $result=_store_qactions('domain_sync','sync_mode=devices2profile','','SYNC DOMAIN (PERFIL DE DISPOSITIVOS)',ATYPE_MCNM_DOMAIN_SYNC);
	
	   // MODIFICAMOS LA FICHA DE DISPOSITIVO
	   set_device_record($aux_dev_ip);
	
	   // Se crean las aplicaciones y metricas del asistente
	   $outputfile='/dev/null';
	   $pidfile='/tmp/pid';
	   $cmd="/usr/bin/sudo /opt/crawler/bin/prov_device_app_metrics -i {$a_system_fields['id']} -c $cid";
	   CNMUtils::debug_log(__FILE__, __LINE__, "crear_dispositivo: START CMD=$cmd");
	   exec(sprintf("%s > %s 2>&1 & echo $! >> %s", $cmd, $outputfile, $pidfile));
	   CNMUtils::debug_log(__FILE__, __LINE__, "crear_dispositivo: END CMD=$cmd");
	
      $a_return['rc']            = 0;
      $a_return['rcstr']         = "OK";
      $a_return['id']            = $a_system_fields['id'];
      $a_return['ip']            = $a_system_fields['ip'];
      $a_return['mac']           = $a_system_fields['mac'];
      $a_return['macvendor']     = $a_system_fields['macvendor'];
		$a_return['snmpsysdesc']   = $a_system_fields['snmpsysdesc'];
		$a_return['snmpsysloc']    = $a_system_fields['snmpsysloc'];
		$a_return['snmpsysoid']    = $a_system_fields['snmpsysoid'];
		$a_return['xagentversion'] = $a_system_fields['xagentversion'];
      return $a_return;
	}

//-----------------------------------------------------------------
// Funcion que obtiene la clase de dispositivo, descripcion y ubicacion por snmp
function _do_mib2_system($dev_ip,$dev_snmp_version,$dev_community,$dev_snmp_credenciales){

   if ((! $dev_ip) || ($dev_snmp_version==0) ) {
      return array('VALUE NOT OBTAINED','VALUE NOT OBTAINED','VALUE NOT OBTAINED',0,'0','','','','0');
   }
   if ($dev_snmp_version == 3) {
      $data = array('__ID_PROFILE__'=> $dev_snmp_credenciales);
      $result = doQuery('snmp3_profile_info',$data);

      if ($result['obj'][0]['priv_pass'] != '') {
         $cmd="/opt/crawler/bin/libexec/mib2_system -v $dev_snmp_version -u {$result['obj'][0]['sec_name']} -l {$result['obj'][0]['sec_level']} -a {$result['obj'][0]['auth_proto']} -A {$result['obj'][0]['auth_pass']} -x {$result['obj'][0]['priv_proto']} -X {$result['obj'][0]['priv_pass']} -n $dev_ip";
      }
      else{
         $cmd="/opt/crawler/bin/libexec/mib2_system -v $dev_snmp_version -u {$result['obj'][0]['sec_name']} -l {$result['obj'][0]['sec_level']} -a {$result['obj'][0]['auth_proto']} -A {$result['obj'][0]['auth_pass']} -n $dev_ip";
      }
   }
   else {
      $cmd="/opt/crawler/bin/libexec/mib2_system -v $dev_snmp_version -c $dev_community -n $dev_ip";
   }


   $results=Array();
   exec($cmd,$results);
   $dev_sysdesc=$results[0]==''?'VALUE NOT OBTAINED':$results[0];
   $dev_sysoid=$results[1]==''?'VALUE NOT OBTAINED':$results[1];
   $dev_sysloc=$results[3]==''?'VALUE NOT OBTAINED':$results[3];
   $dev_enterprise=$results[4]==''?'0':$results[4];
   $dev_mac=$results[5]==''?'0':$results[5];
   $dev_mac_vendor=$results[6]==''?'':$results[6];
   $dev_netmask=$results[7]==''?'':$results[7];
   $dev_network=$results[8]==''?'':$results[8];
   $dev_switch=$results[9]==''?'0':$results[9];

   return array($dev_sysdesc,$dev_sysoid,$dev_sysloc,$dev_enterprise,$dev_mac,$dev_mac_vendor,$dev_netmask,$dev_network,$dev_switch);
}

function _store_qactions($action,$elems,$cmd,$descr,$atype){
global $dbc;

   // ESTAMOS ASOCIANDO METRICAS A DISPOSITIVOS
   // $elems SON IPS SEPARADAS POR COMAS
   if (($action=='setmetric')or($action=='audit')or($action=='clone')or($action=='domain_sync') or($action=='delmetricdata')){
      $params=$elems;
   }
   if (! $atype) { $atype=0; }

   // print "<br>++++++++++++++++++++++++++++++++<br>";
   // print $params;
   // print "<br>++++++++++++++++++++++++++++++++<br>";
   $time=time();
   $aux_time=$time;

   $h=md5("$time$action$elems");
   $hh=substr($h,1,8);

   $user=$_SESSION['LUSER'];
   $sql="INSERT INTO qactions (name,descr,action,cmd,params,auser,date_store,date_start,status,task,atype)
         values ('$hh','$descr','$action','$cmd','$params','$user',$time,$aux_time,0,'$action',$atype)";
   // print "SQL ES == $sql";

   $result = $dbc->query($sql);
   if (@PEAR::isError($result)) {
      $msg_error=$result->getMessage();
      CNMUtils::error_log(__FILE__, __LINE__, "**DBERROR** $msg_error ($sql)");
      return 1;
   }
   else{
      CNMUtils::debug_log(__FILE__, __LINE__, "STORE OK atype=$atype action=$action elems=$elems cmd=$cmd descr=$descr");
      return 0;
   }
}

?>
