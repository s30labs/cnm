<?php

	class cnmlist{

		public $cid = 'default';
		// Tipo de lista
		private $type = '';
		// Listas implementadas actualmente
		private $a_valid_types = array('profiles','devices','users','assets','alerts','alerts_store');

/*
		private $a_meta_data = array(
			'mode'     => 'json', // json|array
			'id'       => '', // profiles|devices|users|assets|alerts|alerts_store
			'a_search' => '',
			'posstart' => 0,
			'count'    => 100,
			'orderby'  => '',
			'direct'   => 'asc', // asc | desc
			// Campos que queremos mostrar
			'fields'   => 'all',
		);
*/
		// Aquí se almacenan todos los datos de entrada por parte del usuario
		private $a_input_data = array();	

		// $type => 
		//           'profiles'
		//           'devices'
		//           'users'
		//           'assets'
		//           'alerts'
		//           'alerts_store'
		public function __construct($type=''){
			$this->type=$type;
		}

		// $mode =>
		//          array
		//          json
		public function show($mode='array'){
			$a_res = array('rc'=>0,'rcstr'=>'','id'=>'');

			// //////////// //
			// Validaciones //
			// //////////// //
		
			if(!in_array($this->type,$this->a_valid_types)){
				$a_res['rc']    = 1;
            $a_res['rcstr'] = "ID ".$this->get_field('id')." IS NOT VALID";
            return $a_res;
			}

			// ///////////////////////////////// //
			// Invocar al método correspondiente //
			// ///////////////////////////////// //
			if($this->type=='profiles')          $a_res = $this->show_profiles();
			elseif($this->type=='devices')       $a_res = $this->show_devices();
			elseif($this->type=='users')         $a_res = $this->show_users();
			elseif($this->type=='assets')        $a_res = $this->show_assets();
			elseif($this->type=='alerts')        $a_res = $this->show_alerts();
			elseif($this->type=='alerts_store')  $a_res = $this->show_alerts_store();




			if($mode=='array'){
				return $a_res;
			}
			elseif($mode=='json'){
				return json_encode($a_res);
			}
		}


		private function show_profiles(){

		}

		private function show_devices(){
			$a_res = array();

			// ///////////////////////////////// //
			// Campos de sistema de dispositivos //
			// ///////////////////////////////// //
			$a_system_fields = array(
				'id'              => '',
				'name'            => '',
				'domain'          => '',
				'ip'              => '',
				'type'            => '',
				'snmpversion'     => '',
				'snmpcommunity'   => '',
				'entity'          => '',
				'geo'             => '',
				'critic'          => '',
				'correlated'      => '',
				'status'          => '',
				'profile'         => '',
				'redalerts'       => '',
				'orangealerts'    => '',
				'yellowalerts'    => '',
				'bluealerts'      => '',
				'network'         => '',
				'mac'             => '',
				'macvendor'       => '',
				'snmpsysclass'    => '',
				'snmpsysdesc'     => '',
				'snmpsyslocation' => '',
	         'switch'          => '',
         	'xagentversion'   => '',
				'metrics'         => '',
         );
         foreach($this->a_input_data as $key => $value){
            if(array_key_exists($key,$a_system_fields)){
               $a_system_fields[$key] = $value;
            }
         }

			// /////////////////////////////////// //
			// Campos de ordenación, paginado, etc //
			// /////////////////////////////////// //
			// - cnm_page_size => Numero de elementos por página
			// - cnm_page      => Numero de página
			// - cnm_fields    => Campos que queremos que devuelva separados por comas
			// - cnm_sort    
			$a_meta_fields = array(
				'cnm_page_size' => 100,
				'cnm_page'      => 1,
				'cnm_fields'    => '',
				'cnm_sort'      => 'id',
			);
			foreach($this->a_input_data as $key => $value){
				if(array_key_exists($key,$a_meta_fields)){
					$a_meta_fields[$key] = $value;
				}
			}

			// ///////////////////////////////////////////////////// //
         // Obtener los campos de usuario definidos en el sistema //
         // ///////////////////////////////////////////////////// //
			$a_custom_fields = array();
			$a_custom_fields_descr2name = array();
			$a_custom_fields_name2descr = array();
			$user_fields = '';
			$comma = ',';
			$data = array();
         $result = doQuery('get_user_fields',$data);
         foreach($result['obj'] as $r){
				if(array_key_exists($r['descr'],$this->a_input_data)) $a_custom_fields[$r['descr']] = $this->a_input_data[$r['descr']];
				else $a_custom_fields[$r['descr']] = '';

				$a_custom_fields_descr2name[$r['descr']]        = $r['id'];
				$a_custom_fields_name2descr["columna".$r['id']] = $r['descr'];
				$user_fields.=$comma."columna".$r['id'];
			}

/*
$a_custom_fields = 
Array
(
    [Contraseña] => 
    [Fabricante] => 
    [Responsable] => 
    [Usuario de acceso] => 
)

$a_custom_fields_descr2name =
Array
(
    [Contraseña] => 4
    [Fabricante] => 1
    [Responsable] => 2
    [Usuario de acceso] => 3
)

$a_custom_fields_name2descr = 
Array
(
    [columna4] => Contraseña
    [columna1] => Fabricante
    [columna2] => Responsable
    [columna3] => Usuario de acceso
)
*/
			// Campos de tipo texto que hay que meter entre comillas
			$a_scape_fields = array(
				'name',
				'domain',
				'ip',
				'type',
				'snmpcommunity',
				'geo',
				'profile',
				'network',
				'mac',
				'macvendor',
				'snmpsysclass',
				'snmpsysdesc',
				'snmpsyslocation',
				'switch',
				'xagentversion'
			);

			// ////////////////////////////////////////////// //
			// Calcular la condicion de los campos de sistema //
			// ////////////////////////////////////////////// //
			$cond = "( ''='' ";
			$and = 'AND ';
			foreach($a_system_fields as $key => $value){
				if (''==$value)      continue;
				if ('profile'==$key) continue;
				$cond.=$and;
				// status=0,1
				if(strpos($value,',')!==false){
					$oper = '=';
					$or = '';
					$cond.='(';
					$a_value = split(',',$value);
					$a_value = array_unique($a_value);	
					foreach($a_value as $v){
						$cond.=$or;
	               if(in_array($key,$a_scape_fields)) $cond.=$key.$oper."'".$v."'";
	               else $cond.=$key.$oper.$v;
						$or = ' OR ';
					}
					$cond.=')';
				}
				// status=0
				else{
					list($oper,$value) = $this->parsevalue($value);
					if(in_array($key,$a_scape_fields)) $cond.=$key.$oper."'".$value."'";
					else $cond.=$key.$oper.$value;
				}
				
				$and = ' AND ';
			}


			// ///////////////////// //
			// Calcular los perfiles //
			// ///////////////////// //
/*
+-----------+--------------+------------+
| id_cfg_op | descr        | user_group |
+-----------+--------------+------------+
|         1 | Global       | ,1,6,      |
|         2 | s30labs      | ,2,6,      |
|         3 | avance       | ,3,        |
|         4 | yosoynuclear | ,4,        |
|         5 | amazon       | ,5,        |
|         6 | test3        | ,2,3,      |
+-----------+--------------+------------+
*/
			$a_organizational_profile = array();
			$data = array();
			$result = doQuery('get_organizational_profile',$data);
			foreach($result['obj'] as $r){
				$a_organizational_profile[$r['descr']] = $r['id_cfg_op'];
			}

			// En caso de pertenecer al perfil global, se le asocian todos los perfiles
			if ($_SESSION['GLOBAL']==1){
				$_SESSION['ORGPRO'] = '';
				$comma = '';
				foreach($a_organizational_profile as $k=>$v) {
					$_SESSION['ORGPRO'].=$comma.$v;
					$comma = ',';
				}
			}


			// /////////////////////////////////////////////////// //
			// Calcular los perfiles que ha introducido el usuario //
			// /////////////////////////////////////////////////// //
			if($a_system_fields['profile']!=''){
				// $a_input_profile = array('Global');
	         if(strpos($a_system_fields['profile'],',')!==false){
					$a_value = split(',',$a_meta_fields['cnm_sort']);
	            foreach($a_value as $v){
						if(array_key_exists($v,$a_organizational_profile)){
	               	$a_input_profile[] = $v;
	            	}
	            }
	         }
	         else{
					if(array_key_exists($a_system_fields['profile'],$a_organizational_profile)){
						$a_input_profile[] = $a_system_fields['profile'];
					}
	         }
	
				$a_input_profile = array_unique($a_input_profile);
				$a_id_input_profile = array();
				foreach($a_input_profile as $k){
					$a_id_input_profile[] = $a_organizational_profile[$k];
				}
			}
			else{
				$a_id_input_profile = explode(',',$_SESSION['ORGPRO']);	
			}
			$a_id_input_profile = array_unique($a_id_input_profile);		

			// $cond.=' profile IN ('.implode(',',$a_input_profile).')';

			// ////////////////////////////////////////////// //
         // Calcular la condicion de los campos de usuario //
         // ////////////////////////////////////////////// //
         foreach($a_custom_fields as $key => $value){
            if (''==$value) continue;
            $cond.=$and;
            // customstatus=0,1
            if(strpos($value,',')!==false){
               $oper = '=';
               $or = '';
               $cond.='(';
               $a_value = split(',',$value);
               $a_value = array_unique($a_value);          
               foreach($a_value as $v){
                  $cond.=$or;
                  $cond.="columna".$a_custom_fields_descr2name[$key].$oper."'".$v."'";
                  $or = ' OR ';
               }
               $cond.=')';
            }
            // customstatus=0
            else{
               list($oper,$value) = $this->parsevalue($value);
               $cond.="columna".$a_custom_fields_descr2name[$key].$oper."'".$value."'";
            }

            $and = ' AND ';
         }

			$cond.= ')';


			// ////////////////////// //
			// Calcular la ordenacion //
			// ////////////////////// //
			$orderby = '';	
			// name,-domain,+ip
         if(strpos($a_meta_fields['cnm_sort'],',')!==false){
				$comma = '';
            $a_value = split(',',$a_meta_fields['cnm_sort']);
            $a_value = array_unique($a_value);
            foreach($a_value as $v){
					if(strpos($v,'-')!==false) $orderby.=$comma.str_replace('-','',$v).' ASC';
					else   						   $orderby.=$comma.str_replace('+','',$v).' DESC';
               $comma = ',';
            }
         }
         // name
         else{
            if(strpos($a_meta_fields['cnm_sort'],'-')!==false) $orderby.=str_replace('-','',$a_meta_fields['cnm_sort']).' ASC';
            else                                               $orderby.=str_replace('+','',$a_meta_fields['cnm_sort']).' DESC';
         }


			// ///////////////////////////////////////////////// //
			// Calcular los campos que quiere obtener el usuario //
			// ///////////////////////////////////////////////// //
			$output_fields = '';
			if($a_meta_fields['cnm_fields'] == ''){
				$output_fields = '*';
			}
			else{
				$a_cnm_fields = split(',',$a_meta_fields['cnm_fields']);
				$a_cnm_fields = array_unique($a_cnm_fields);
				$comma = '';	
				foreach($a_cnm_fields as $f){
					if(array_key_exists($f,$a_system_fields)){
						$output_fields.=$comma.$f;
						$comma = ',';
					} 
					elseif(array_key_exists($f,$a_custom_fields)){
						$output_fields.=$comma."columna".$a_custom_fields_descr2name[$f];	
						$comma = ',';
					}
				}	
			}

			// //////////////////////////////////////// //
			// Calcular las alertas de cada dispositivo //
			// //////////////////////////////////////// //
	      $da = array();
	      $data = array();
	      $result = doQuery('all_devices_no_condition',$data);
	      foreach ($result['obj'] as $r){
	         $da[$r['id_dev']]['red']=0;
	         $da[$r['id_dev']]['orange']=0;
	         $da[$r['id_dev']]['yellow']=0;
	         $da[$r['id_dev']]['blue']=0;
	      }
	      $data = array();
	      $result = doQuery('dispositivos_alarmados',$data);
	      foreach ($result['obj'] as $r){
	         if($r['severity']=='1'){$da[$r['id_device']]['red']++;}
	         if($r['severity']=='2'){$da[$r['id_device']]['orange']++;}
	         if($r['severity']=='3'){$da[$r['id_device']]['yellow']++;}
	         if($r['severity']=='4'){$da[$r['id_device']]['blue']++;}
   	   }


			///////////
			// ///// //
			// Query //
			// ///// //
			///////////
			$data  = array('__POSSTART__'=>($a_meta_fields['cnm_page']-1)*$a_meta_fields['cnm_page_size'],'__COUNT__'=>$a_meta_fields['cnm_page_size'],'__CONDITION__'=>$cond,'__ORDERBY__'=>$orderby, '__ID_CFG_OP__'=>$_SESSION['ORGPRO'],'__CID__'=>$this->cid,'__OUTPUT_FIELDS__'=>$output_fields,'__USER_FIELDS__'=>$user_fields,'__PROFILE__'=>implode(',',$a_id_input_profile));

	     	// Se borra las tablas temporales t1 y t2
			$result = doQuery('api_get_devices_layout_delete_temp',$data);
			// Se crea la tabla temporal t2 con los dispositivos y el numero de metricas
	      $result = doQuery('api_get_devices_layout_create_temp1',$data);
	      // Se crea la tabla temporal t1 con los dispositivos visibles. Se ponen por defecto con redalerts,orangealerts,yellowalerts y metrics=0
	      $result = doQuery('api_get_devices_layout_create_temp2',$data);
			// print_r($result);exit;

			// Se actualiza el numero de alertas por dispositivo
	      foreach($da as $id_dev=>$disp){
	         if ($disp['red']==0 and $disp['orange']==0 and $disp['yellow']==0 and $disp['blue']==0) continue;
	         $data2=array('__ID_DEV__'=>$id_dev,'__REDALERTS__'=>$disp['red'],'__ORANGEALERTS__'=>$disp['orange'],'__YELLOWALERTS__'=>$disp['yellow'],'__BLUEALERTS__'=>$disp['blue']);
	         $result2=doQuery('api_get_devices_layout_update_temp',$data2);
	      }

	      // Se obtienen los dispositivos
	      $result = doQuery('api_get_devices_layout_lista',$data);
			foreach($result['obj'] as $r){
				$a_row = array();
				foreach($r as $k=>$v){
					if(array_key_exists($k,$a_custom_fields_name2descr)) $a_row[$a_custom_fields_name2descr[$k]] = $v;
					else $a_row[$k] = $v;
				}
				$a_res[] = $a_row;
			}	
			return $a_res;
      }


//
		/*
		* Function: show_alerts_store()
		* Input:
		* Output:
		* Descr:
		*
		*/
		private function show_alerts_store(){
			$a_res = array();

			// ////////////////////////////////////////// //
			// Campos de sistema del histórico de alertas //
			// ////////////////////////////////////////// //
			$a_system_fields = array(
				'id'         => '',
				'ack'        => '',
				'cause'      => '',
				'ticket'     => '',
				'severity'   => '',
				'critic'     => '',
				'type'       => '',
				'date'       => '',
				'name'       => '',
				'domain'     => '',
				'ip'         => '',
				'label'      => '',
				'duration'   => '',
				'event'      => '',
         );
			// Contemplamos los campos de sistema que ha incluido el usuario en la búsqueda
         foreach($this->a_input_data as $key => $value){
            if(array_key_exists($key,$a_system_fields)){
               $a_system_fields[$key] = $value;
            }
         }





			// /////////////////////////////////// //
			// Campos de ordenación, paginado, etc //
			// /////////////////////////////////// //
			// - cnm_page_size => Numero de elementos por página
			// - cnm_page      => Numero de página
			// - cnm_fields    => Campos que queremos que devuelva separados por comas
			// - cnm_sort    
			$a_meta_fields = array(
				'cnm_page_size' => 100,
				'cnm_page'      => 1,
				'cnm_fields'    => '',
				'cnm_sort'      => 'id',
			);
			// Contemplamos los campos de ordenación, paginado, etc que ha incluido el usuario en la búsqueda
			foreach($this->a_input_data as $key => $value){
				if(array_key_exists($key,$a_meta_fields)){
					$a_meta_fields[$key] = $value;
				}
			}

			// ///////////////////////////////////////////////////// //
         // Obtener los campos de usuario definidos en el sistema //
         // ///////////////////////////////////////////////////// //
			$a_custom_fields = array();
			$a_custom_fields_descr2name = array();
			$a_custom_fields_name2descr = array();
			$user_fields = '';
			$comma = ',';
			$data = array();
         $result = doQuery('get_user_fields',$data);
         foreach($result['obj'] as $r){
				if(array_key_exists($r['descr'],$this->a_input_data)) $a_custom_fields[$r['descr']] = $this->a_input_data[$r['descr']];
				else $a_custom_fields[$r['descr']] = '';

				$a_custom_fields_descr2name[$r['descr']]        = $r['id'];
				$a_custom_fields_name2descr["columna".$r['id']] = $r['descr'];
				$user_fields.=$comma."columna".$r['id'];
			}

/*
$a_custom_fields = 
Array
(
    [Contraseña] => 
    [Fabricante] => 
    [Responsable] => 
    [Usuario de acceso] => 
)

$a_custom_fields_descr2name =
Array
(
    [Contraseña] => 4
    [Fabricante] => 1
    [Responsable] => 2
    [Usuario de acceso] => 3
)

$a_custom_fields_name2descr = 
Array
(
    [columna4] => Contraseña
    [columna1] => Fabricante
    [columna2] => Responsable
    [columna3] => Usuario de acceso
)
*/
			// Campos de sistema de tipo texto que hay que meter entre comillas
			$a_scape_fields = array(
				'type',
				'name',
				'domain',
				'ip',
				'label',
				'cause',
				'event',
			);

			// ////////////////////////////////////////////// //
			// Calcular la condicion de los campos de sistema //
			// ////////////////////////////////////////////// //
			$cond = "( ''='' ";
			$and = 'AND ';
			foreach($a_system_fields as $key => $value){
				if (''==$value)      continue;
				if ('profile'==$key) continue;
				$cond.=$and;
				// status=0,1
				if(strpos($value,',')!==false){
					$oper = '=';
					$or = '';
					$cond.='(';
					$a_value = split(',',$value);
					$a_value = array_unique($a_value);	
					foreach($a_value as $v){
						$cond.=$or;
	               if(in_array($key,$a_scape_fields)) $cond.=$key.$oper."'".$v."'";
	               else $cond.=$key.$oper.$v;
						$or = ' OR ';
					}
					$cond.=')';
				}
				// status=0
				else{
					list($oper,$value) = $this->parsevalue($value);
					if(in_array($key,$a_scape_fields)) $cond.=$key.$oper."'".$value."'";
					else $cond.=$key.$oper.$value;
				}
				
				$and = ' AND ';
			}


			// ///////////////////// //
			// Calcular los perfiles //
			// ///////////////////// //
/*
+-----------+--------------+------------+
| id_cfg_op | descr        | user_group |
+-----------+--------------+------------+
|         1 | Global       | ,1,6,      |
|         2 | s30labs      | ,2,6,      |
|         3 | avance       | ,3,        |
|         4 | yosoynuclear | ,4,        |
|         5 | amazon       | ,5,        |
|         6 | test3        | ,2,3,      |
+-----------+--------------+------------+
*/
			$a_organizational_profile = array();
			$data = array();
			$result = doQuery('get_organizational_profile',$data);
			foreach($result['obj'] as $r){
				$a_organizational_profile[$r['descr']] = $r['id_cfg_op'];
			}

			// En caso de pertenecer al perfil global, se le asocian todos los perfiles
			if ($_SESSION['GLOBAL']==1){
				$_SESSION['ORGPRO'] = '';
				$comma = '';
				foreach($a_organizational_profile as $k=>$v) {
					$_SESSION['ORGPRO'].=$comma.$v;
					$comma = ',';
				}
			}


			// /////////////////////////////////////////////////// //
			// Calcular los perfiles que ha introducido el usuario //
			// /////////////////////////////////////////////////// //
			if($a_system_fields['profile']!=''){
				// $a_input_profile = array('Global');
	         if(strpos($a_system_fields['profile'],',')!==false){
					$a_value = split(',',$a_meta_fields['cnm_sort']);
	            foreach($a_value as $v){
						if(array_key_exists($v,$a_organizational_profile)){
	               	$a_input_profile[] = $v;
	            	}
	            }
	         }
	         else{
					if(array_key_exists($a_system_fields['profile'],$a_organizational_profile)){
						$a_input_profile[] = $a_system_fields['profile'];
					}
	         }
	
				$a_input_profile = array_unique($a_input_profile);
				$a_id_input_profile = array();
				foreach($a_input_profile as $k){
					$a_id_input_profile[] = $a_organizational_profile[$k];
				}
			}
			else{
				$a_id_input_profile = explode(',',$_SESSION['ORGPRO']);	
			}
			$a_id_input_profile = array_unique($a_id_input_profile);		

			// ////////////////////////////////////////////// //
         // Calcular la condicion de los campos de usuario //
         // ////////////////////////////////////////////// //
         foreach($a_custom_fields as $key => $value){
            if (''==$value) continue;
            $cond.=$and;
            // customstatus=0,1
            if(strpos($value,',')!==false){
               $oper = '=';
               $or = '';
               $cond.='(';
               $a_value = split(',',$value);
               $a_value = array_unique($a_value);          
               foreach($a_value as $v){
                  $cond.=$or;
                  $cond.="columna".$a_custom_fields_descr2name[$key].$oper."'".$v."'";
                  $or = ' OR ';
               }
               $cond.=')';
            }
            // customstatus=0
            else{
               list($oper,$value) = $this->parsevalue($value);
               $cond.="columna".$a_custom_fields_descr2name[$key].$oper."'".$value."'";
            }

            $and = ' AND ';
         }

			$cond.= ')';


			// ////////////////////// //
			// Calcular la ordenacion //
			// ////////////////////// //
			$orderby = '';	
			// name,-domain,+ip
         if(strpos($a_meta_fields['cnm_sort'],',')!==false){
				$comma = '';
            $a_value = split(',',$a_meta_fields['cnm_sort']);
            $a_value = array_unique($a_value);
            foreach($a_value as $v){
					if(strpos($v,'-')!==false) $orderby.=$comma.str_replace('-','',$v).' ASC';
					else   						   $orderby.=$comma.str_replace('+','',$v).' DESC';
               $comma = ',';
            }
         }
         // name
         else{
            if(strpos($a_meta_fields['cnm_sort'],'-')!==false) $orderby.=str_replace('-','',$a_meta_fields['cnm_sort']).' ASC';
            else                                               $orderby.=str_replace('+','',$a_meta_fields['cnm_sort']).' DESC';
         }


			// ///////////////////////////////////////////////// //
			// Calcular los campos que quiere obtener el usuario //
			// ///////////////////////////////////////////////// //
			$output_fields = '';
			if($a_meta_fields['cnm_fields'] == ''){
				$output_fields = '*';
			}
			else{
				$a_cnm_fields = split(',',$a_meta_fields['cnm_fields']);
				$a_cnm_fields = array_unique($a_cnm_fields);
				$comma = '';	
				foreach($a_cnm_fields as $f){
					if(array_key_exists($f,$a_system_fields)){
						$output_fields.=$comma.$f;
						$comma = ',';
					} 
					elseif(array_key_exists($f,$a_custom_fields)){
						$output_fields.=$comma."columna".$a_custom_fields_descr2name[$f];	
						$comma = ',';
					}
				}	
			}


			///////////
			// ///// //
			// Query //
			// ///// //
			///////////
			$data  = array('__POSSTART__'=>($a_meta_fields['cnm_page']-1)*$a_meta_fields['cnm_page_size'],'__COUNT__'=>$a_meta_fields['cnm_page_size'],'__CONDITION__'=>$cond,'__ORDERBY__'=>$orderby, '__ID_CFG_OP__'=>$_SESSION['ORGPRO'],'__CID__'=>$this->cid,'__OUTPUT_FIELDS__'=>$output_fields,'__USER_FIELDS__'=>$user_fields,'__PROFILE__'=>implode(',',$a_id_input_profile));

         // Se borra la tabla temporal t1
         $result = doQuery('api_get_alerts_store_layout_delete_temp',$data);
         // Se crea la tabla temporal t1 con las alertas visibles
         $result = doQuery('api_get_alerts_store_layout_create_temp',$data);
         // Se obtienen las alertas del histórico
         $result = doQuery('api_get_alerts_store_layout_lista',$data);
			foreach($result['obj'] as $r){
				$a_row = array();
				foreach($r as $k=>$v){
					if(array_key_exists($k,$a_custom_fields_name2descr)) $a_row[$a_custom_fields_name2descr[$k]] = $v;
					else $a_row[$k] = $v;
				}
				$a_res[] = $a_row;
			}	
			return $a_res;
      }

//
//
		/*
		* Function: show_alerts()
		* Input:
		* Output:
		* Descr:
		*
		*/
		private function show_alerts(){
			$a_res = array();

			// //////////////////////////// //
			// Campos de sistema de alertas //
			// //////////////////////////// //
			$a_system_fields = array(
				'id'         => '',
				'ack'        => '',
				'ticket'     => '',
				'severity'   => '',
				'critic'     => '',
				'type'       => '',
				'date'       => '',
				'name'       => '',
				'domain'     => '',
				'ip'         => '',
				'label'      => '',
				'counter'    => '',
				'event'      => '',
				'cause'      => '',
				'lastupdate' => '',
         );
			// Contemplamos los campos de sistema que ha incluido el usuario en la búsqueda
         foreach($this->a_input_data as $key => $value){
            if(array_key_exists($key,$a_system_fields)){
               $a_system_fields[$key] = $value;
            }
         }





			// /////////////////////////////////// //
			// Campos de ordenación, paginado, etc //
			// /////////////////////////////////// //
			// - cnm_page_size => Numero de elementos por página
			// - cnm_page      => Numero de página
			// - cnm_fields    => Campos que queremos que devuelva separados por comas
			// - cnm_sort    
			$a_meta_fields = array(
				'cnm_page_size' => 100,
				'cnm_page'      => 1,
				'cnm_fields'    => '',
				'cnm_sort'      => 'id',
			);
			// Contemplamos los campos de ordenación, paginado, etc que ha incluido el usuario en la búsqueda
			foreach($this->a_input_data as $key => $value){
				if(array_key_exists($key,$a_meta_fields)){
					$a_meta_fields[$key] = $value;
				}
			}

			// ///////////////////////////////////////////////////// //
         // Obtener los campos de usuario definidos en el sistema //
         // ///////////////////////////////////////////////////// //
			$a_custom_fields = array();
			$a_custom_fields_descr2name = array();
			$a_custom_fields_name2descr = array();
			$user_fields = '';
			$comma = ',';
			$data = array();
         $result = doQuery('get_user_fields',$data);
         foreach($result['obj'] as $r){
				if(array_key_exists($r['descr'],$this->a_input_data)) $a_custom_fields[$r['descr']] = $this->a_input_data[$r['descr']];
				else $a_custom_fields[$r['descr']] = '';

				$a_custom_fields_descr2name[$r['descr']]        = $r['id'];
				$a_custom_fields_name2descr["columna".$r['id']] = $r['descr'];
				$user_fields.=$comma."columna".$r['id'];
			}

/*
$a_custom_fields = 
Array
(
    [Contraseña] => 
    [Fabricante] => 
    [Responsable] => 
    [Usuario de acceso] => 
)

$a_custom_fields_descr2name =
Array
(
    [Contraseña] => 4
    [Fabricante] => 1
    [Responsable] => 2
    [Usuario de acceso] => 3
)

$a_custom_fields_name2descr = 
Array
(
    [columna4] => Contraseña
    [columna1] => Fabricante
    [columna2] => Responsable
    [columna3] => Usuario de acceso
)
*/
			// Campos de sistema de tipo texto que hay que meter entre comillas
			$a_scape_fields = array(
				'type',
				'name',
				'domain',
				'ip',
				'label',
				'event',
				'lastupdate',
			);

			// ////////////////////////////////////////////// //
			// Calcular la condicion de los campos de sistema //
			// ////////////////////////////////////////////// //
			$cond = "( ''='' ";
			$and = 'AND ';
			foreach($a_system_fields as $key => $value){
				if (''==$value)      continue;
				if ('profile'==$key) continue;
				$cond.=$and;
				// status=0,1
				if(strpos($value,',')!==false){
					$oper = '=';
					$or = '';
					$cond.='(';
					$a_value = split(',',$value);
					$a_value = array_unique($a_value);	
					foreach($a_value as $v){
						$cond.=$or;
	               if(in_array($key,$a_scape_fields)) $cond.=$key.$oper."'".$v."'";
	               else $cond.=$key.$oper.$v;
						$or = ' OR ';
					}
					$cond.=')';
				}
				// status=0
				else{
					list($oper,$value) = $this->parsevalue($value);
					if(in_array($key,$a_scape_fields)) $cond.=$key.$oper."'".$value."'";
					else $cond.=$key.$oper.$value;
				}
				
				$and = ' AND ';
			}


			// ///////////////////// //
			// Calcular los perfiles //
			// ///////////////////// //
/*
+-----------+--------------+------------+
| id_cfg_op | descr        | user_group |
+-----------+--------------+------------+
|         1 | Global       | ,1,6,      |
|         2 | s30labs      | ,2,6,      |
|         3 | avance       | ,3,        |
|         4 | yosoynuclear | ,4,        |
|         5 | amazon       | ,5,        |
|         6 | test3        | ,2,3,      |
+-----------+--------------+------------+
*/
			$a_organizational_profile = array();
			$data = array();
			$result = doQuery('get_organizational_profile',$data);
			foreach($result['obj'] as $r){
				$a_organizational_profile[$r['descr']] = $r['id_cfg_op'];
			}

			// En caso de pertenecer al perfil global, se le asocian todos los perfiles
			if ($_SESSION['GLOBAL']==1){
				$_SESSION['ORGPRO'] = '';
				$comma = '';
				foreach($a_organizational_profile as $k=>$v) {
					$_SESSION['ORGPRO'].=$comma.$v;
					$comma = ',';
				}
			}


			// /////////////////////////////////////////////////// //
			// Calcular los perfiles que ha introducido el usuario //
			// /////////////////////////////////////////////////// //
			if($a_system_fields['profile']!=''){
				// $a_input_profile = array('Global');
	         if(strpos($a_system_fields['profile'],',')!==false){
					$a_value = split(',',$a_meta_fields['cnm_sort']);
	            foreach($a_value as $v){
						if(array_key_exists($v,$a_organizational_profile)){
	               	$a_input_profile[] = $v;
	            	}
	            }
	         }
	         else{
					if(array_key_exists($a_system_fields['profile'],$a_organizational_profile)){
						$a_input_profile[] = $a_system_fields['profile'];
					}
	         }
	
				$a_input_profile = array_unique($a_input_profile);
				$a_id_input_profile = array();
				foreach($a_input_profile as $k){
					$a_id_input_profile[] = $a_organizational_profile[$k];
				}
			}
			else{
				$a_id_input_profile = explode(',',$_SESSION['ORGPRO']);	
			}
			$a_id_input_profile = array_unique($a_id_input_profile);		

			// ////////////////////////////////////////////// //
         // Calcular la condicion de los campos de usuario //
         // ////////////////////////////////////////////// //
         foreach($a_custom_fields as $key => $value){
            if (''==$value) continue;
            $cond.=$and;
            // customstatus=0,1
            if(strpos($value,',')!==false){
               $oper = '=';
               $or = '';
               $cond.='(';
               $a_value = split(',',$value);
               $a_value = array_unique($a_value);          
               foreach($a_value as $v){
                  $cond.=$or;
                  $cond.="columna".$a_custom_fields_descr2name[$key].$oper."'".$v."'";
                  $or = ' OR ';
               }
               $cond.=')';
            }
            // customstatus=0
            else{
               list($oper,$value) = $this->parsevalue($value);
               $cond.="columna".$a_custom_fields_descr2name[$key].$oper."'".$value."'";
            }

            $and = ' AND ';
         }

			$cond.= ')';


			// ////////////////////// //
			// Calcular la ordenacion //
			// ////////////////////// //
			$orderby = '';	
			// name,-domain,+ip
         if(strpos($a_meta_fields['cnm_sort'],',')!==false){
				$comma = '';
            $a_value = split(',',$a_meta_fields['cnm_sort']);
            $a_value = array_unique($a_value);
            foreach($a_value as $v){
					if(strpos($v,'-')!==false) $orderby.=$comma.str_replace('-','',$v).' ASC';
					else   						   $orderby.=$comma.str_replace('+','',$v).' DESC';
               $comma = ',';
            }
         }
         // name
         else{
            if(strpos($a_meta_fields['cnm_sort'],'-')!==false) $orderby.=str_replace('-','',$a_meta_fields['cnm_sort']).' ASC';
            else                                               $orderby.=str_replace('+','',$a_meta_fields['cnm_sort']).' DESC';
         }


			// ///////////////////////////////////////////////// //
			// Calcular los campos que quiere obtener el usuario //
			// ///////////////////////////////////////////////// //
			$output_fields = '';
			if($a_meta_fields['cnm_fields'] == ''){
				$output_fields = '*';
			}
			else{
				$a_cnm_fields = split(',',$a_meta_fields['cnm_fields']);
				$a_cnm_fields = array_unique($a_cnm_fields);
				$comma = '';	
				foreach($a_cnm_fields as $f){
					if(array_key_exists($f,$a_system_fields)){
						$output_fields.=$comma.$f;
						$comma = ',';
					} 
					elseif(array_key_exists($f,$a_custom_fields)){
						$output_fields.=$comma."columna".$a_custom_fields_descr2name[$f];	
						$comma = ',';
					}
				}	
			}


			///////////
			// ///// //
			// Query //
			// ///// //
			///////////
			$data  = array('__POSSTART__'=>($a_meta_fields['cnm_page']-1)*$a_meta_fields['cnm_page_size'],'__COUNT__'=>$a_meta_fields['cnm_page_size'],'__CONDITION__'=>$cond,'__ORDERBY__'=>$orderby, '__ID_CFG_OP__'=>$_SESSION['ORGPRO'],'__CID__'=>$this->cid,'__OUTPUT_FIELDS__'=>$output_fields,'__USER_FIELDS__'=>$user_fields,'__PROFILE__'=>implode(',',$a_id_input_profile));

         // Se borra la tabla temporal t1
         $result = doQuery('api_get_alerts_layout_delete_temp',$data);
         // Se crea la tabla temporal t1 con las alertas visibles
         $result = doQuery('api_get_alerts_layout_create_temp',$data);
         // Se obtienen las alertas
         $result = doQuery('api_get_alerts_layout_lista',$data);
			foreach($result['obj'] as $r){
				$a_row = array();
				foreach($r as $k=>$v){
					if(array_key_exists($k,$a_custom_fields_name2descr)) $a_row[$a_custom_fields_name2descr[$k]] = $v;
					else $a_row[$k] = $v;
				}
				$a_res[] = $a_row;
			}	
			return $a_res;
      }

//











		private function show_users(){
         $a_res = array();

         // ///////////////////////////// //
         // Campos de sistema de usuarios //
         // ///////////////////////////// //
         $a_system_fields = array(
				'id'        => '',
				'login'     => '',
				'descr'     => '',
				// 'profile'   => '',
				'timeout'   => '',
				'firstname' => '',
				'lastname'  => '',
				'email'     => '',
				'language'  => '',
				'role'      => '',
			);
         foreach($this->a_input_data as $key => $value){
            if(array_key_exists($key,$a_system_fields)){
               $a_system_fields[$key] = $value;
            }
         }

         // /////////////////////////////////// //
         // Campos de ordenación, paginado, etc //
         // /////////////////////////////////// //
         // - cnm_page_size => Numero de elementos por página
         // - cnm_page      => Numero de página
         // - cnm_fields    => Campos que queremos que devuelva separados por comas
         // - cnm_sort    
         $a_meta_fields = array(
            'cnm_page_size' => 100,
            'cnm_page'      => 1,
            'cnm_fields'    => '',
            'cnm_sort'      => 'id',
         );
         foreach($this->a_input_data as $key => $value){
            if(array_key_exists($key,$a_meta_fields)){
               $a_meta_fields[$key] = $value;
            }
         }


         // Campos de tipo texto que hay que meter entre comillas
         $a_scape_fields = array(
            'login',
            'descr',
            'profile',
            'firstname',
            'lastname',
            'email',
            'language',
            'role',
         );


         // ////////////////////////////////////////////// //
         // Calcular la condicion de los campos de sistema //
         // ////////////////////////////////////////////// //
         $cond = "( ''='' ";
         $and = 'AND ';
         foreach($a_system_fields as $key => $value){
            if (''==$value)      continue;
            $cond.=$and;
            // status=0,1
            if(strpos($value,',')!==false){
               $oper = '=';
               $or = '';
               $cond.='(';
               $a_value = split(',',$value);
               $a_value = array_unique($a_value);
               foreach($a_value as $v){
                  $cond.=$or;
                  if(in_array($key,$a_scape_fields)) $cond.=$key.$oper."'".$v."'";
                  else $cond.=$key.$oper.$v;
                  $or = ' OR ';
               }
               $cond.=')';
            }
            // status=0
            else{
               list($oper,$value) = $this->parsevalue($value);
               if(in_array($key,$a_scape_fields)) $cond.=$key.$oper."'".$value."'";
               else $cond.=$key.$oper.$value;
            }

            $and = ' AND ';
         }

         $cond.= ')';


         // ////////////////////// //
         // Calcular la ordenacion //
         // ////////////////////// //
         $orderby = '';
         // name,-domain,+ip
         if(strpos($a_meta_fields['cnm_sort'],',')!==false){
            $comma = '';
            $a_value = split(',',$a_meta_fields['cnm_sort']);
            $a_value = array_unique($a_value);
            foreach($a_value as $v){
               if(strpos($v,'-')!==false) $orderby.=$comma.str_replace('-','',$v).' ASC';
               else                       $orderby.=$comma.str_replace('+','',$v).' DESC';
               $comma = ',';
            }
         }
         // name
         else{
            if(strpos($a_meta_fields['cnm_sort'],'-')!==false) $orderby.=str_replace('-','',$a_meta_fields['cnm_sort']).' ASC';
            else                                               $orderby.=str_replace('+','',$a_meta_fields['cnm_sort']).' DESC';
         }

			
         // ///////////////////////////////////////////////// //
         // Calcular los campos que quiere obtener el usuario //
         // ///////////////////////////////////////////////// //
         $output_fields = '';
         if($a_meta_fields['cnm_fields'] == ''){
            $output_fields = '*';
         }
         else{
            $a_cnm_fields = split(',',$a_meta_fields['cnm_fields']);
            $a_cnm_fields = array_unique($a_cnm_fields);
            $comma = '';
            foreach($a_cnm_fields as $f){
               if(array_key_exists($f,$a_system_fields)){
                  $output_fields.=$comma.$f;
                  $comma = ',';
               }
            }
         }


         ///////////
         // ///// //
         // Query //
         // ///// //
         ///////////
			// Obtener los id_users que puede ver el usuario (pertenecen a los mismos perfiles)
			$a_id_user = array('0');
         $data  = array('__ID_CFG_OP__'=>$_SESSION['ORGPRO'],'__CID__'=>$this->cid);
			$result = doQuery('get_users_from_organizational_profile',$data);
			foreach($result['obj'] as $r){
				$a_aux_id_user = explode(',',$r['user_group']);
				foreach($a_aux_id_user as $i){
					if($i!='') $a_id_user[] = $i;
				}
			}
			$id_user_visible = implode(',',array_unique ($a_id_user));


         $data  = array('__POSSTART__'=>($a_meta_fields['cnm_page']-1)*$a_meta_fields['cnm_page_size'],'__COUNT__'=>$a_meta_fields['cnm_page_size'],'__CONDITION__'=>$cond,'__ORDERBY__'=>$orderby, '__OUTPUT_FIELDS__'=>$output_fields,'__USER_FIELDS__'=>$user_fields,'__ID_USER__'=>$id_user_visible);
         // Se borra las tablas temporales t1 
         $result = doQuery('api_get_users_delete_temp',$data);
         // Se crea la tabla temporal t2 con los dispositivos y el numero de metricas
         $result = doQuery('api_get_users_create_temp',$data);
         // print_r($result);exit;

         // Se obtienen los usuarios
         $result = doQuery('api_get_users_lista',$data);
         // print_r($result);exit;
         foreach($result['obj'] as $r){
            $a_row = array();
            foreach($r as $k=>$v){
					// if(array_key_exists($k,$a_custom_fields_name2descr)) $a_row[$a_custom_fields_name2descr[$k]] = $v;
               // else $a_row[$k] = $v;
					$a_row[$k] = $v;
            }
            $a_res[] = $a_row;
         }
         return $a_res;
      }


		private function show_assets(){
			$a_res = array();

			// /////////////////////////// //
			// Campos de sistema de assets //
			// /////////////////////////// //

			$a_system_fields = array(
				'id'              => null,
				'name'            => null,
				'type'            => null,
				'subtype'         => null,
				'critic'          => null,
				'status'          => null,
				'owner'           => null,
         );
         foreach($this->a_input_data as $key => $value){
            if(array_key_exists($key,$a_system_fields)){
               $a_system_fields[$key] = $value;
            }
         }

			// /////////////////////////////////// //
			// Campos de ordenación, paginado, etc //
			// /////////////////////////////////// //
			// - cnm_page_size => Numero de elementos por página
			// - cnm_page      => Numero de página
			// - cnm_fields    => Campos que queremos que devuelva separados por comas
			// - cnm_sort    
			$a_meta_fields = array(
				'cnm_page_size' => 100,
				'cnm_page'      => 1,
				'cnm_fields'    => '',
				'cnm_sort'      => 'id',
			);
			foreach($this->a_input_data as $key => $value){
				if(array_key_exists($key,$a_meta_fields)){
					$a_meta_fields[$key] = $value;
				}
			}

			// ///////////////////////////////////////////////////// //
         // Obtener los campos de usuario definidos en el sistema //
         // ///////////////////////////////////////////////////// //
			$a_custom_fields = array();
			$a_custom_fields_descr2name = array();
			$a_custom_fields_name2descr = array();
			$a_custom_fields_name2type  = array();
			$user_fields = '';
			$comma = ',';
			$data = array();
         $result = doQuery('asset_all_custom_field',$data);
         foreach($result['obj'] as $r){
				if(array_key_exists($r['descr'],$this->a_input_data)) $a_custom_fields[$r['descr']] = $this->a_input_data[$r['descr']];
				else $a_custom_fields[$r['descr']] = '';

				$a_custom_fields_descr2name[$r['descr']] = $r['hash_asset_custom_field'];
				$a_custom_fields_name2descr["columna".$r['hash_asset_custom_field']] = $r['descr'];
				$a_custom_fields_name2type["columna".$r['hash_asset_custom_field']] = $r['tipo'];
				$user_fields.=$comma."columna".$r['hash_asset_custom_field'];
			}

/*
$a_custom_fields = 
Array
(
    [Ancho de banda] => 
    [Apellidos] => 
    [Móvil] => 
)

$a_custom_fields_descr2name =
Array
(
    [Ancho de banda] => 1
    [Apellidos] => 5
    [Móvil] => 6
)

$a_custom_fields_name2descr = 
Array
(
    [columna1] => Ancho de banda
    [columna5] => Apellidos
    [columna6] => Móvil
)
*/

			// Campos de tipo texto que hay que meter entre comillas
			$a_scape_fields = array(
				'id',
				'name',
				'type',
            'subtype',
            'status',
            'owner',
			);

			// ////////////////////////////////////////////// //
			// Calcular la condicion de los campos de sistema //
			// ////////////////////////////////////////////// //
			$cond = "( ''='' ";
			$and = 'AND ';
			foreach($a_system_fields as $key => $value){
				// if (''==$value)      continue;
				if (is_null($value))      continue;
				$cond.=$and;
				// status=0,1
				if(strpos($value,',')!==false){
					$oper = '=';
					$or = '';
					$cond.='(';
					$a_value = split(',',$value);
					$a_value = array_unique($a_value);	
					foreach($a_value as $v){
						$cond.=$or;
	               if(in_array($key,$a_scape_fields)) $cond.=$key.$oper."'".$v."'";
	               else $cond.=$key.$oper.$v;
						$or = ' OR ';
					}
					$cond.=')';
				}
				// status=0
				else{
					list($oper,$value) = $this->parsevalue($value);
					if(in_array($key,$a_scape_fields)) $cond.=$key.$oper."'".$value."'";
					else $cond.=$key.$oper.$value;
				}
				
				$and = ' AND ';
			}

			// ///////////////////// //
			// Calcular los perfiles //
			// ///////////////////// //
/*
+-----------+--------------+------------+
| id_cfg_op | descr        | user_group |
+-----------+--------------+------------+
|         1 | Global       | ,1,6,      |
|         2 | s30labs      | ,2,6,      |
|         3 | avance       | ,3,        |
|         4 | yosoynuclear | ,4,        |
|         5 | amazon       | ,5,        |
|         6 | test3        | ,2,3,      |
+-----------+--------------+------------+
*/
/*
			$a_organizational_profile = array();
			$data = array();
			$result = doQuery('get_organizational_profile',$data);
			foreach($result['obj'] as $r){
				$a_organizational_profile[$r['descr']] = $r['id_cfg_op'];
			}

			// En caso de pertenecer al perfil global, se le asocian todos los perfiles
			if ($_SESSION['GLOBAL']==1){
				$_SESSION['ORGPRO'] = '';
				$comma = '';
				foreach($a_organizational_profile as $k=>$v) {
					$_SESSION['ORGPRO'].=$comma.$v;
					$comma = ',';
				}
			}


			// /////////////////////////////////////////////////// //
			// Calcular los perfiles que ha introducido el usuario //
			// /////////////////////////////////////////////////// //
			if($a_system_fields['profile']!=''){
				// $a_input_profile = array('Global');
	         if(strpos($a_system_fields['profile'],',')!==false){
					$a_value = split(',',$a_meta_fields['cnm_sort']);
	            foreach($a_value as $v){
						if(array_key_exists($v,$a_organizational_profile)){
	               	$a_input_profile[] = $v;
	            	}
	            }
	         }
	         else{
					if(array_key_exists($a_system_fields['profile'],$a_organizational_profile)){
						$a_input_profile[] = $a_system_fields['profile'];
					}
	         }
	
				$a_input_profile = array_unique($a_input_profile);
				$a_id_input_profile = array();
				foreach($a_input_profile as $k){
					$a_id_input_profile[] = $a_organizational_profile[$k];
				}
			}
			else{
				$a_id_input_profile = explode(',',$_SESSION['ORGPRO']);	
			}
			$a_id_input_profile = array_unique($a_id_input_profile);		

			// $cond.=' profile IN ('.implode(',',$a_input_profile).')';
*/

			// ////////////////////////////////////////////// //
         // Calcular la condicion de los campos de usuario //
         // ////////////////////////////////////////////// //
         foreach($a_custom_fields as $key => $value){
            if (''==$value) continue;
            $cond.=$and;
            // customstatus=0,1
            if(strpos($value,',')!==false){
               $oper = '=';
               $or = '';
               $cond.='(';
               $a_value = split(',',$value);
               $a_value = array_unique($a_value);          
               foreach($a_value as $v){
                  $cond.=$or;
                  $cond.="columna".$a_custom_fields_descr2name[$key].$oper."'".$v."'";
                  $or = ' OR ';
               }
               $cond.=')';
            }
            // customstatus=0
            else{
               list($oper,$value) = $this->parsevalue($value);
               $cond.="columna".$a_custom_fields_descr2name[$key].$oper."'".$value."'";
            }

            $and = ' AND ';
         }

			$cond.= ')';


			// ////////////////////// //
			// Calcular la ordenacion //
			// ////////////////////// //
			$orderby = '';	
			// name,-domain,+ip
         if(strpos($a_meta_fields['cnm_sort'],',')!==false){
				$comma = '';
            $a_value = split(',',$a_meta_fields['cnm_sort']);
            $a_value = array_unique($a_value);
            foreach($a_value as $v){
					if(strpos($v,'-')!==false) $orderby.=$comma.str_replace('-','',$v).' ASC';
					else   						   $orderby.=$comma.str_replace('+','',$v).' DESC';
               $comma = ',';
            }
         }
         // name
         else{
            if(strpos($a_meta_fields['cnm_sort'],'-')!==false) $orderby.=str_replace('-','',$a_meta_fields['cnm_sort']).' ASC';
            else                                               $orderby.=str_replace('+','',$a_meta_fields['cnm_sort']).' DESC';
         }


			// ///////////////////////////////////////////////// //
			// Calcular los campos que quiere obtener el usuario //
			// ///////////////////////////////////////////////// //
			$output_fields = '';
			if($a_meta_fields['cnm_fields'] == ''){
				$output_fields = '*';
			}
			else{
				$a_cnm_fields = split(',',$a_meta_fields['cnm_fields']);
				$a_cnm_fields = array_unique($a_cnm_fields);
				$comma = '';	
				foreach($a_cnm_fields as $f){
					if(array_key_exists($f,$a_system_fields)){
						$output_fields.=$comma.$f;
						$comma = ',';
					} 
					elseif(array_key_exists($f,$a_custom_fields)){
						$output_fields.=$comma."columna".$a_custom_fields_descr2name[$f];	
						$comma = ',';
					}
				}	
			}


	     	// Se borra la tabla temporal t1
   		$data = array();
			$result = doQuery('api_get_assets_layout_delete_temp',$data);
/*
mysql> select a.id_asset,a.name,a.status,a.critic,a.owner,b.descr AS type,IFNULL(c.descr,'') AS subtype FROM (assets a,assets_types b) LEFT JOIN assets_subtypes c ON a.id_asset_subtype=c.id_asset_subtype WHERE a.id_asset_type=b.id_asset_type;
+----------+-------------------------------+------------------------+--------+---------------+----------------+---------+
| id_asset | name                          | status                 | critic | owner         | type           | subtype |
+----------+-------------------------------+------------------------+--------+---------------+----------------+---------+
|       17 | S30                           | Activo                 |     50 | Administrador | Linea de datos | WAN     |
|        1 | aaSergio                      | Baja médica asdasdasd  |     75 | Uno           | Personal       |         |
|        2 | Fernando                      | Baja médica asdasdasd  |     50 | aaa           | Personal       |         |
|        5 | Jorgito                       | 0                      |     50 |               | Personal       |         |
|        6 | Jaimito                       | 0                      |     50 |               | Personal       |         |
|       20 | www.s30labs.com               | Activo                 |     50 |               | Servicio WEB   |         |
|       21 | www.centroavance.com          | Activo                 |     50 |               | Servicio WEB   |         |
|       22 | www.foronuclear.org           | Activo                 |     50 |               | Servicio WEB   |         |
|       23 | www.s30labs.com/otrs/index.pl | Activo                 |     50 |               | Servicio WEB   |         |
|       24 | aa                            | Inactivo               |     50 | Alberto       | Base de Datos  | MariaDB |
+----------+-------------------------------+------------------------+--------+---------------+----------------+---------+
*/
	      // Se crea la tabla temporal t1 con los assets visibles.
   		$data = array();
	      $result = doQuery('api_get_assets_layout_create_temp1',$data);

			// Se incorporan todos los campos de usuario a t1. Los elementos que no utilicen dicho campo tendran el valor a null
   		$data = array();
   		$result = doQuery('asset_all_custom_field',$data);
   		$user_fields = '';
		   $array_user_fields = array();
		   $a_user_fields_types = array();
		   foreach ($result['obj'] as $r){
		      $user_fields.=",columna{$r['hash_asset_custom_field']}";
		      $array_user_fields[]="columna{$r['hash_asset_custom_field']}";
		      $a_user_fields_types["columna{$r['hash_asset_custom_field']}"]=$r['tipo'];

		      // Se añade la columna a la tabla temporal t1
		      $data2 = array('__COLUMNA__'=>"columna{$r['hash_asset_custom_field']}");
		      $result2 = doQuery('api_get_assets_layout_alter_temp1',$data2);

				// Se añaden los datos a t1
				$data3=array('__COLUMNA__'=>"columna{$r['hash_asset_custom_field']}",'__HASH_ASSET_CUSTOM_FIELD__'=>$r['hash_asset_custom_field']);
				$result3=doQuery('api_get_assets_layout_alter_temp2',$data3);	
		   }

			///////////
			// ///// //
			// Query //
			// ///// //
			///////////
			$data  = array(
				'__POSSTART__'      => ($a_meta_fields['cnm_page']-1)*$a_meta_fields['cnm_page_size'],
				'__COUNT__'         => $a_meta_fields['cnm_page_size'],
				'__CONDITION__'     => $cond,
				'__ORDERBY__'       => $orderby, 
				'__ID_CFG_OP__'     => $_SESSION['ORGPRO'],
				'__CID__'           => $this->cid,
				'__OUTPUT_FIELDS__' => $output_fields,
				'__USER_FIELDS__'   => $user_fields,
				'__PROFILE__'       => implode(',',$a_id_input_profile)
			);

	      // Se obtienen los assets
	      $result = doQuery('api_get_assets_layout_lista',$data);
			foreach($result['obj'] as $r){
				$a_row = array();
				foreach($r as $k=>$v){
					if(is_null($v)) continue;
					elseif($a_custom_fields_name2type[$k]==3) $v = json_decode($v,true);

					if(array_key_exists($k,$a_custom_fields_name2descr)) $a_row[$a_custom_fields_name2descr[$k]] = $v;
					else $a_row[$k] = $v;
				}
				$a_res[] = $a_row;
			}	
			return $a_res;
      }



		public function set_field($key,$val){
			global $dbc;

			$rc = 0;
			$this->a_input_data[$key] = $dbc->real_escape_string($val);
			return $rc;
		}

      public function get_field($field){
         $rc = false;
         if(array_key_exists($field,$this->a_input_data)) $rc = $this->a_input_data[$field];
         return $rc;
      }


		/*
		* Function: parsevalue()
		* Input:
		* Output:
		* Descr:
// - CNMGT    => >
// - CNMGTE   => >=
// - CNMLT    => <
// - CNMLTE   => <=
// - CNMLIKE  => LIKE
// - CNMNLIKE => NOT LIKE
// - CNMEQ    => =
// - CNMNEQ   => !=

		*/
		private function parsevalue($input_value){
			$oper = '=';
			$value = $input_value;
         if(strpos($input_value,'CNMGTE')!==false){
            $oper='>=';
            $value = str_replace('CNMGTE','',$input_value);
         }
         elseif(strpos($input_value,'CNMGT')!==false){
            $oper='>';
            $value = str_replace('CNMGT','',$input_value);
         }
         elseif(strpos($input_value,'CNMLTE')!==false){
            $oper='<=';
            $value = str_replace('CNMLTE','',$input_value);
         }
         elseif(strpos($input_value,'CNMLT')!==false){
            $oper='<';
            $value = str_replace('CNMLT','',$input_value);
         }
         elseif(strpos($input_value,'CNMNLIKE')!==false){
            $oper=' NOT LIKE ';
            $value = str_replace('CNMNLIKE','',$input_value);
         }
         elseif(strpos($input_value,'CNMLIKE')!==false){
            $oper=' LIKE ';
            $value = str_replace('CNMLIKE','',$input_value);
         }
         elseif(strpos($input_value,'CNMNEQ')!==false){
            $oper='!=';
            $value = str_replace('CNMNEQ','',$input_value);
         }
         elseif(strpos($input_value,'CNMEQ')!==false){
            $oper='=';
            $value = str_replace('CNMEQ','',$input_value);
         }

			return array($oper,$value);
		}
		
	}
?>
