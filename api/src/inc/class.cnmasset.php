<?php
	include_once('inc/CNMUtils.php');

	class cnmasset {
		// Funciones publicas
		public $public_functions = array('set_field','get_field','save','set_asset_record','asoc_metric');

		// cid del CNM
		public $cid = 'default';

		// Campos que deben existir, sino hay un error
      private $a_must_fields = array('name','type','subtype');

		private $a_meta_fields = array();

		// Campos de sistema
		private $a_system_fields = array(
         'id'                 => '',
         'name'               => '',
         'type'               => '',
         'subtype'            => '',
         'critic'             => 50,
         'status'             => '',
         'owner'              => '',
			'hash_asset_type'    => '',
			'hash_asset_subtype' => '',
			'id_dev'             => 0,
		);

      // Campos de usuario
      private $a_custom_fields = array();

		//////////////////////
		// PUBLIC FUNCTIONS //
		//////////////////////

		/*
		* Funcion constructor
		* Input:
		*    hash_asset o vacio =>	En caso de introducir un id_asset, se utilizara para modificar u obtener datos de dicho elemento TI
      * 		 						   En caso de no introducir nada será para crear un elemento TI
		* Output:
      *  - array(
      *     'rc'    => 0 => OK | 1 => NOOK
      *     'rcstr' => Mensaje de error en caso de ser rc=1
      *  )
		* Visibility: public
		* Descr:
		*/
		public function __construct($hash_asset=''){
			global $dbc;

			$a_res = array(
				'rc'    => 0,
				'rcstr' => '',
			);


         // ///////////////////////////////////////////////////// //
         // Obtener los campos de usuario definidos en el sistema //
         // ///////////////////////////////////////////////////// //
         $a_aux = array();
         $result = doQuery('asset_all_custom_field',$data);
         foreach($result['obj'] as $r) $this->a_custom_fields[$r['descr']] = null;

			$this->set_field('id',$hash_asset);	

			if($this->get_field('id')==''){}
			else{
				// Obtener los campos de sistema del elemento TI
				$data = array('__HASH_ASSET__'=>$this->get_field('id'));
				$result = doQuery('asset_info',$data);
				if($result['cont']==0){
					$a_res['rc']    = 1;	
					$a_res['rcstr'] = "Asset ".$this->get_field('id')." doesn't exist";	
	            CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->__construct() >> Asset ".$this->get_field('id')." doesn't exist");
					return $a_res;
				}
				else{
               // ///////////////////////////////////////////////////////// //
               // Insertamos los campos de sistema que tenga el elemento TI //
               // ///////////////////////////////////////////////////////// //
					$r = $result['obj'][0];
					$a_aux = array(
						'name'               => $r['name'],
			         'hash_asset_type'    => $r['hash_asset_type'],            
			         'type'               => $r['descr'],            
			         'status'             => $r['status'],            
			         'critic'             => $r['critic'],            
			         'owner'              => $r['owner'],
			         'hash_asset_subtype' => $r['hash_asset_subtype'],
			         'subtype'            => $r['subtype'],
					);
					$this->set_field($a_aux);

					// ///////////////////////////////////////////////////////// //
					// Insertamos los campos de usuario que tenga el elemento TI //
					// ///////////////////////////////////////////////////////// //
					$data = array('__HASH_ASSET__'=>$this->get_field('id'));
					$result = doQuery('get_asset_custom_data',$data);
					foreach($result['obj'] as $r) $this->set_field($r['descr'],$r['data']);
				}
			}
			return $a_res;
		}

		/*
		* Function: set_field()
		* Input: 
		* 	- clave y valor
		*	- array con claves y valores
		* Output:
		*	- 0 => La operación ha sido correcta
		*	- 1 => Ha habido algún fallo
		* Visibility: public
		* Descr: Modifica en el asset el campo/los campos indicados. 
		* Una vez hecho hay que invocar el método save para almacenar los cambios 
		*/
		public function set_field(){
	      $rc = 0;

			if(func_num_args()==1){
				if(is_array(func_get_arg(0))){
					foreach(func_get_arg(0) as $key => $value){
						if(0!=$this->set_field($key,$value)) $rc = 1;
					}
					if($rc==1){
						// error: no se han modificado todos los campos
						// CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->set_field() >> couldn't modify all fields");
					}
				}
				else{
					// error: un parámetro y no es array
					CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->set_field() >> 1 param and not array");
					$rc = 1;
				}
			}
			elseif(func_num_args()==2){
	         if(array_key_exists(func_get_arg(0),$this->a_system_fields))     $rc = $this->set_system_field(func_get_arg(0),func_get_arg(1));
	         elseif(array_key_exists(func_get_arg(0),$this->a_custom_fields)) $rc = $this->set_custom_field(func_get_arg(0),func_get_arg(1));
				else{
					// error: el parámetro no existe
					$rc = 1;
					CNMUtils::debug_log(__FILE__, __LINE__, "cnmasset->set_field() >> param doesn't exist");
				}
			}
			else{
				// error: ni uno ni dos parámetros
				$rc = 1;
				CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->set_field() >> not 1 or 2 params");
			}
	      return $rc;
		}

      /*
      * Function: get_field()
      * Input: 
      *  - clave
      * Output:
		*	- Valor del campo con dicha clave
      * Visibility: public
      * Descr: Devuelve el valor del campo con la clave indicada
      */
		public function get_field($field){
			$rc = false;
			if(array_key_exists($field,$this->a_system_fields))     $rc = $this->get_system_field($field);
			elseif(array_key_exists($field,$this->a_custom_fields)) $rc = $this->get_custom_field($field);
			return $rc;
		}

      /*
      * Function: save()
      * Input: 
      * Output:
      *  - array(
		*		'rc'    => 0 => OK | 1 => NOOK
		*		'rcstr' => Mensaje de erroe en caso de ser rc=1
		*		'id'    => identificador del asset en caso de crearse
		*	)
      * Visibility: public
      * Descr: Crea o modifica el asset con los campos indicados
      */
		public function save(){
			$a_res = array('rc'=>0,'rcstr'=>'','id'=>'');


			// print_r($this->a_system_fields);
			// print_r($this->a_custom_fields);
			// print_r($this->a_asset_types);

	      // /////////////////// //
	      // VALIDACIONES:INICIO //
	      // /////////////////// //
					
         // Obtener los tipos,propietarios,estados de asset definidos
			$a_asset_types = array();
			$a_asset_owners = array();
			$a_asset_status = array();
         $data = array();
         $result=doQuery('asset_types',$data);
         foreach($result['obj'] as $r){
				$a_asset_types[$r['hash_asset_type']] = $r['descr'];
				$a_asset_owners[$r['hash_asset_type']] = ($this->isJson($r['available_owner']))?json_decode($r['available_owner'],true):$r['available_owner'];
				$a_asset_status[$r['hash_asset_type']] = ($this->isJson($r['available_status']))?json_decode($r['available_status'],true):$r['available_status'];
			}

			// El tipo es válido
			if($this->get_field('type')=='' or !in_array($this->get_field('type'),$a_asset_types)){
            $a_res['rc']    = 1;
            $a_res['rcstr'] = "TYPE ".$this->get_field('type')." ISN'T DEFINED";
            CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->save() >> TYPE ".$this->get_field('type')." ISN'T DEFINED");
            return $a_res;
			}	
			else{
				$this->set_field('hash_asset_type',array_search($this->get_field('type'),$a_asset_types));
			}


			// Obtener los subtipos del tipo
			$a_asset_subtypes = array();
			$data = array('__HASH_ASSET_TYPE__'=>$this->get_field('hash_asset_type'));
			$result = doQuery('asset_subtypes',$data);			
			foreach($result['obj'] as $r) $a_asset_subtypes[$r['hash_asset_subtype']] = $r['descr']; 

			// El subtipo no es válido
         if(!in_array($this->get_field('subtype'),$a_asset_subtypes)){
            $a_res['rc']    = 1;
            $a_res['rcstr'] = "SUBTYPE ".$this->get_field('subtype')." ISN'T DEFINED";
				CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->save() >> SUBTYPE ".$this->get_field('subtype')." ISN'T DEFINED");
            return $a_res;
         }
			else{
            $this->set_field('hash_asset_subtype',array_search($this->get_field('subtype'),$a_asset_subtypes));
			}

			// El propietario esta vacio
			if($this->get_field('owner')==''){
				$this->set_field('owner',$a_asset_owners[$this->get_field('hash_asset_type')][0]);	
			}
			// El propietario no es válido
         elseif(!in_array($this->get_field('owner'),$a_asset_owners[$this->get_field('hash_asset_type')])){
            $a_res['rc']    = 1;
            $a_res['rcstr'] = "OWNER ".$this->get_field('owner')." ISN'T DEFINED";
				CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->save() >> OWNER ".$this->get_field('owner')." ISN'T DEFINED");
            return $a_res;
         }

         // El estado esta vacio válido
         if($this->get_field('status')==''){
            $this->set_field('status',$a_asset_status[$this->get_field('hash_asset_type')][0]);
         }
			// El estado es no válido
         elseif(!in_array($this->get_field('status'),$a_asset_status[$this->get_field('hash_asset_type')])){
            $a_res['rc']    = 1;
            $a_res['rcstr'] = "STATUS ".$this->get_field('status')." ISN'T DEFINED";
				CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->save() >> STATUS ".$this->get_field('status')." ISN'T DEFINED");
            return $a_res;
         }
	


			// Campos de usuario de tipo 4 (enumerado);
			$data = array('__HASH_ASSET_TYPE__'=>$this->get_field('hash_asset_type'));
			$result = doQuery('get_assets_custom_typesenumerate',$data);
			foreach($result['obj'] as $r){
				if($this->get_field($r['descr'])==''){
					// Se asigna el primer valor disponible
					$a_possible_values = json_decode($r['available_values'],true);
					$this->set_field($r['descr'],$a_possible_values[0]);
/*
					$a_res['rc']    = 1;
               $a_res['rcstr'] = "EMPTY VALUE ISN'T ALLOWED IN ".$r['descr'];
               return $a_res;
*/
				}
				elseif(!in_array($this->get_field($r['descr']),json_decode($r['available_values'],true))){
					$a_res['rc']    = 1;
	            $a_res['rcstr'] = $this->get_field($r['descr'])." ISN'T DEFINED IN ".$r['descr'];
					CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->save() >> ".$this->get_field($r['descr'])." ISN'T DEFINED IN ".$r['descr']);
	            return $a_res;
				}
			}






	      ///////////////////////////
	      // INSERTAR CAMPOS FIJOS //
	      ///////////////////////////
	      $data=array(
				'__HASH_ASSET__'         => $this->get_field('id'),
	         '__NAME__'               => $this->get_field('name'),
	         '__STATUS__'             => $this->get_field('status'),
	         '__CRITIC__'             => $this->get_field('critic'),
	         '__OWNER__'              => $this->get_field('owner'),
	         '__HASH_ASSET_TYPE__'    => $this->get_field('hash_asset_type'),
	         '__HASH_ASSET_SUBTYPE__' => $this->get_field('hash_asset_subtype'),
				'__ID_DEV__'             => $this->get_field('id_dev'),
	      );

			$action = 'create';
			// En caso de tener id = 0 hay que crear
			if($this->get_field('id')==''){
			   $hash_asset = substr( md5(uniqid(rand(),true)),0,8);
	         $this->set_field('id',$hash_asset);
				$data['__HASH_ASSET__'] = $this->get_field('id');

	      	$result = doQuery('create_asset',$data);
		      if ($result['rc']!=0) {
		         $a_res['rc']    = 1;
		         $a_res['rcstr'] = "ERROR CREATING ASSET (STEP 1):{$result['rcstr']}";
					CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->save() >> ERROR CREATING ASSET (STEP 1):{$result['rcstr']}");
		         return $a_res;
		      }
				$action = 'create';
			}
			// En otro caso hay que modificar
			else{
   			$result = doQuery('update_asset',$data);
	         if ($result['rc']!=0) {
	            $a_res['rc']    = 1;
	            $a_res['rcstr'] = "ERROR UPDATING ASSET (STEP 1):{$result['rcstr']}";
					CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->save() >> ERROR UPDATING ASSET (STEP 1):{$result['rcstr']}");
	            return $a_res;
	         }

				$action = 'update';
			}

	      ////////////////////////////////////
	      // INSERTAR CAMPOS PERSONALIZADOS //
	      ////////////////////////////////////
	      $a_local_res=$this->save_custom_fields();
	      if ($a_local_res['rc']!=0){
	         $a_res['rc']    = 1;
	         $a_res['rcstr'] = "ERROR SAVING DEVICE (STEP 2): {$a_local_res['rc']} || {$a_local_res['rcstr']}";
				CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->save() >> ERROR SAVING DEVICE (STEP 2): {$a_local_res['rc']} || {$a_local_res['rcstr']}");
	         return $a_res;
	      }

			// //////////////////////////////////// //
		   // MODIFICAMOS LA FICHA DEL ELEMENTO TI // 
			// //////////////////////////////////// //
         $a_local_res=$this->set_asset_record();
         if ($a_local_res['rc']!=0){
            $a_res['rc']    = 1;
            $a_res['rcstr'] = "ERROR SAVING ASSET (STEP 3): {$a_local_res['rc']} || {$a_local_res['rcstr']}";
				CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->save() >> ERROR SAVING ASSET (STEP 3): {$a_local_res['rc']} || {$a_local_res['rcstr']}");
            return $a_res;
         }

			$a_res['id'] = $this->get_field('id');
			return $a_res;
      }


      /*
      * Function: set_asset_record()
      * Input: 
      * Output:
      *  - array(
      *     'rc'    => 0 => OK | 1 => NOOK
      *     'rcstr' => Mensaje de erroe en caso de ser rc=1
      *     'id'    => identificador del asset en caso de crearse
      *  )
      * Visibility: public
      * Descr: Genera la ficha de documentación del asset
      */
		public function set_asset_record(){
			global $dbc;

		   // 0.Obtener el subtype
		   $data = array('__HASH_ASSET__'=>$this->get_field('id'));
		   $result = doQuery('asset_subtype_from_asset',$data);
		   $categoria = $result['obj'][0]['descr'];

		   // 1. Obtener los campos basicos del elemento TI
		   $data = array('__HASH_ASSET__'=>$this->get_field('id'));
		   $result = doQuery('asset_info',$data);
		   $r = $result['obj'][0];
		
		   $descripcion.="NAME: {$r['name']}\n";
		   $descripcion.="STATUS: {$r['status']}\n";
		   $descripcion.="CRITIC: {$r['critic']} OVER 100\n";
		   $descripcion.="TYPE: {$r['descr']}\n";
		   $descripcion.="CATEGORY: $categoria\n";
		   $descripcion.="OWNER: {$r['owner']}\n";
		
		   // 2. Obtener los campos definidos por el usuario
		   $data = array('__HASH_ASSET__'=>$this->get_field('id'));
		   $result = doQuery('get_asset_custom_data',$data);
		   foreach($result['obj'] as $r){
		      $descripcion.=$r['descr'];
		      if (($r['tipo']==2)and($r['data']!='-')){
		         $descripcion.=": <a href='{$r['data']}' target='_blank' style='color=#0000CC;text-decoration=underline'> {$r['data']} </a>\n";
		      }
		      elseif($r['tipo']==3){
		         $aux_json_kk = json_decode($r['data']);
		         $aux_val = '';
		         if(count($aux_json_kk)>0){
		            foreach($aux_json_kk as $_){
		               $aux_val.="\n&nbsp;&nbsp;&#8226;&nbsp;".$_;
		            }
		         }
		         $descripcion.=": $aux_val\n";
		      }
		      else{
     		    	$descripcion.=": {$r['data']}\n";
		      }
		   }

		   // Insertar los datos en una nota del elemento TI
		   $date=time();
		   $sqlExist="SELECT id_tip from tips where tip_class=1 and id_ref='".$this->get_field('id')."' AND tip_type='asset'";
		   $resultExist=$dbc->query($sqlExist);
		   $resultExist->fetchInto($rExist);
		   if ($rExist['id_tip']==''){
		      $sqlTip="INSERT INTO tips (id_ref,tip_type,name,date,tip_class,descr)
		               VALUES ('".$this->get_field('id')."','asset','ASSET SUMMARY','$date',1,'".$this->str2jsQM($descripcion)."')";
		   }else{
		      $sqlTip="UPDATE tips set date=$date,descr='".$this->str2jsQM($descripcion)."',name='ASSET SUMMARY' WHERE id_tip={$rExist['id_tip']} AND id_ref='".$this->get_field('id')."' AND tip_type='asset'";
		   }
		   $dbc->query($sqlTip);
		}

		/*
		* Function: asoc_metric()
		* Input:
		* - $id_metric => id de la métrica a asociar
		* Output:
		* - $rc => 0 OK | 1 NOOK
		* Visibility: public
		* Descr: Asocia la métrica al elemento TI
		*/
		public function asoc_metric($id_metric){

		}

		///////////////////////
		// PRIVATE FUNCTIONS //
		///////////////////////

      /*
      * Function: set_system_field()
      * Input: 
      *  - clave y valor
      *  - array con claves y valores
      * Output:
      *  - 0 => La operación ha sido correcta
      *  - 1 => Ha habido algún fallo
      * Visibility: private
      * Descr: Modifica en el asset el campo/los campos de sistema indicados. 
      * Una vez hecho hay que invocar el método save para almacenar los cambios 
      */
		private function set_system_field(){
			$rc = 0;

         if(func_num_args()==1){
            if(is_array(func_get_arg(0))){
               foreach(func_get_arg(0) as $key => $value){
                  if(0!=$this->set_system_field($key,$value)) $rc = 1;
               }
               if($rc==1){
                  // error: no se han modificado todos los campos
                  CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->set_system_field() >> couldn't modify all fields");
               }
            }
            else{
               // error: un parámetro y no es array
               CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->set_system_field() >> 1 param and not array");
               $rc = 1;
            }
         }
         elseif(func_num_args()==2){

            if(array_key_exists(func_get_arg(0),$this->a_system_fields)){
					$this->a_system_fields[func_get_arg(0)] = func_get_arg(1);
				}
            else{
               // error: el parámetro no existe
               $rc = 1;
               CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->set_system_field() >> param doesn't exist");
            }
         }
         else{
            // error: ni uno ni dos parámetros
            $rc = 1;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->set_system_field() >> not 1 or 2 params");
         }
         return $rc;
		}

      /*
      * Function: set_custom_field()
      * Input: 
      *  - clave y valor
      *  - array con claves y valores
      * Output:
      *  - 0 => La operación ha sido correcta
      *  - 1 => Ha habido algún fallo
      * Visibility: private
      * Descr: Modifica en el asset el campo/los campos de usuario indicados. 
      * Una vez hecho hay que invocar el método save para almacenar los cambios 
      */
		private function set_custom_field(){
			$rc = 0;

         if(func_num_args()==1){
            if(is_array(func_get_arg(0))){
               foreach(func_get_arg(0) as $key => $value){
                  if(0!=$this->set_custom_field($key,$value)) $rc = 1;
               }
               if($rc==1){
                  // error: no se han modificado todos los campos
                  CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->set_custom_field() >> couldn't modify all fields");
               }
            }
            else{
               // error: un parámetro y no es array
               CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->set_custom_field() >> 1 param and not array");
               $rc = 1;
            }
         }
         elseif(func_num_args()==2){

            if(array_key_exists(func_get_arg(0),$this->a_custom_fields)){
					$this->a_custom_fields[func_get_arg(0)] = func_get_arg(1);
				}
            else{
               // error: el parámetro no existe
               $rc = 1;
               CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->set_custom_field() >> param doesn't exist");
            }
         }
         else{
            // error: ni uno ni dos parámetros
            $rc = 1;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmasset->set_custom_field() >> not 1 or 2 params");
         }
         return $rc;
		}

		private function get_system_field($field){
			$rc = false;
			if(array_key_exists($field,$this->a_system_fields)) $rc = $this->a_system_fields[$field];
			return $rc;
      }

		private function get_custom_field($field){
			$rc = false;
         if(array_key_exists($field,$this->a_custom_fields)) $rc = $this->a_custom_fields[$field];
         return $rc;
      }

		// ////////////////////////////////////////////////////////////////// //
		// Función que almacena en BBDD los campos de usuario del dispositivo //
		// ////////////////////////////////////////////////////////////////// //
		private function save_custom_fields(){
			global $dbc;
	
	   	$a_res = array('rc'=>0,'rcstr'=>'');
	
			$data = array('__HASH_ASSET_TYPE__'=>$this->get_field('hash_asset_type'));
			$result = doQuery('get_asset_custom_fields_from_type',$data);		
			foreach($result['obj'] as $r){
			   $sql_insertar="INSERT IGNORE INTO assets_custom_data (hash_asset,hash_asset_custom_field,data) VALUES ('".$this->get_field('id')."','".$r['hash_asset_custom_field']."','".$this->get_field($r['descr'])."')";
		   	$result_insertar = $dbc->query($sql_insertar);

				$sql_update="UPDATE assets_custom_data SET data='".$this->get_field($r['descr'])."' WHERE hash_asset='".$this->get_field('id')."' AND hash_asset_custom_field='".$r['hash_asset_custom_field']."'";
				$result_update = $dbc->query($sql_update);
			}
	   	return $a_res;
		}
		

		// Function: str2jsQM
		// Descripcion: Funcion auxiliar. Parsea un string y elimina aquellos caracteres
		// que pueden hacer que al incluir el string dentro de un array de javascript
		// se produzca un error.
		private function str2jsQM($str){
   		$str=str_replace("\\", "\\\\",$str); // Substituyo /
		   $str=str_replace("'", "\'",$str); // Substituyo '
		   return $str;
		}
		/*
		 * Function: isJson()
		 * Input:
		 *        $string: Cadena de texto
		 * Output: true | false
		 * Descr: indica si $string es json o no
		 */
		private function isJson($string) {
		   json_decode($string);
		   return (json_last_error() == JSON_ERROR_NONE);
		}
	}
?>
