<?php
   include_once('inc/CNMUtils.php');

	class cnmdevice {
      // Funciones publicas
      public $public_functions = array('set_field','get_field','save','convert_to_asset','validate_credential','delete');

		public $cid = 'default';

		// Campos que deben existir, sino hay un error
      private $a_must_fields = array('name','domain','snmpversion');

		// Campos de sistema que no se pueden modificar
		private $a_system_fields_fixed = array('id','snmpsysloc','snmpsysdesc','snmpsysoid','enterprise','mac','macvendor','network','switch','entity','rule_name');

		private $a_meta_fields = array(
			'do_workset'   => 0,
			'change_ip'    => 0,
			'change_label' => 0,
			'old_name'     => '',
			'old_domain'   => '',
			'old_ip'       => '',
		);

		// Campos de sistema 
		private $a_system_fields = array(
         'id'              => '', // id_dev
         'name'            => '', // Nombre del dispositivo
         'domain'          => '', // Dominio 
         'ip'              => '', // Dirección ip sin añadir nada (caso de servicio web)
         'snmpsysloc'      => '', // Syslocation
         'snmpsysdesc'     => '', // Sysdesc
         'snmpsysoid'      => '', // Sysoid
         'type'            => '', // Tipo de dispositivo (se relaciona en la función convert_to_asset con el tipo de asset)
         'status'          => 0,  // Estado del dispositivo (0:activo || 1:  || 2:)

         'snmpversion'     => 0,  // Versión SNMP
         'snmpcommunity'   => '', // Comunidad SNMP
         'snmpcredential'  => '', // Credencial SNMP (v3)
         'enterprise'      => 0,  // SSV: Ver qué es este campo
         'mac'             => '', // MAC del equipo
         'macvendor'       => '', // Fabricante a partir de la MAC
         'network'         => '', // CIDR

         'switch'          => '',
         'xagentversion'   => '',
         'entity'          => 0,  // 0:dispositivo físico || 1:servicio web. A partir de ahora siempre vale 0
         'geo'             => '', // Geolocalización 
         'critic'          => 50, // Severidad (25,50,75,100)
         'correlated'      => '', // Indica si el dispositivo esta correlado o no. El valor aqui es del id_dev del dispositivo correlador
         'profile'         => '',
			'wsize'           => 0,

			'asset_container' => 0, // 0: No se contenedor de metricas para assets | 1: Es contenedor de metricas para assets
			'credential'      => '', // Credenciales marcadas separadas por ,
			'tech_group'      => '', // Grupos tecnologicos separados por ,  
			'background'      => 'magic.gif', // Fondo
			'rule_name'       => '', // Descripción de la regla del dispositivo
			'dyn'             => 0  // IP dinámica
		);


      // Campos de usuario
      private $a_custom_fields = array();


      //////////////////////
      // PUBLIC FUNCTIONS //
      //////////////////////

		/*
		* Funcion constructor
		* Input:
		*    id_dev o $ip o vacio =>	En caso de introducir un id_dev, se utilizara para modificar u obtener datos de dicho dispositivo. 
		*                             En caso de introducir una ip, se utilizara para modificar u obtener datos de dicho dispositivo.
      * 								      En caso de no introducir nada será para crear un dispositivo
      * Output:
      *  - array(
      *     'rc'    => 0 => OK | 1 => NOOK
      *     'rcstr' => Mensaje de error en caso de ser rc=1
      *  )
      * Visibility: public
		* Descr:
		*/
		public function __construct($id=0){
			global $dbc;

			$a_res = array(
				'rc'    => 0,
				'rcstr' => '',
			);

			// Validacion: id es ip
			if (filter_var($id, FILTER_VALIDATE_IP)) {
				$data = array('__IP__'=>$id);
				$result = doQuery('device_info_basic_by_ip',$data);
				if($result['cont']==0){
               $a_res['rc']    = 1;
               $err_msg = "Device with ip $id doesn't exist";
					$a_res['rcstr'] = $err_msg;
	            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ".$err_msg);
               return $a_res;
            }
				else{
					$id_dev = $result['obj'][0]['id_dev'];
				}
			}
			else{
				$id_dev = $id;
			}

			// Validacion: id_dev no numerico o menor que cero
			if(!is_numeric($id_dev) or $id_dev<0){
				$a_res['rc']    = 1;
            $err_msg = "ID $id_dev is not correct (must be int or empty)";
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ".$err_msg);
				return $a_res;
			}
		
			// Validacion: id_dev numerico que no existe
			if($id_dev!=0){
	         $data = array('__ID_DEV__'=>$id_dev);
	         $result = doQuery('device_info',$data);
	         if($result['cont']==0){
	            $a_res['rc']    = 1;
					$err_msg = "Device with id=".$id_dev." doesn't exist";
	            $a_res['rcstr'] = $err_msg;
            	CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ".$err_msg);
	            return $a_res;
	         }
			}

			$this->set_system_field('id',$id_dev);	


         // Obtener los campos de usuario definidos en el sistema
         $a_custom_fields = array();
         $result = doQuery('get_user_fields',$data);
         foreach($result['obj'] as $r){
				$this->a_custom_fields[$r['descr']] = '-';
         	$a_custom_fields[$r['id']] = $r['descr'];
			}

			// En caso de ser un dispositivo ya creado se carga su configuracion
			if($this->get_system_field('id')!=0){
				// Obtener los campos de sistema del dispositivo
				$data = array('__ID_DEV__'=>$this->get_system_field('id'));
				$result = doQuery('device_info',$data);
				$r = $result['obj'][0];
				$a_aux = array(
					'name'            => $r['name'],
					'domain'          => $r['domain'],
		         'ip'              => $r['ip'],
		         'type'            => $r['type'],            
		         'snmpversion'     => $r['version'],            
		         'snmpcommunity'   => ($r['version']==3)?'':$r['community'],            
		         'snmpcredential'  => ($r['version']==3)?$r['community']:'',            
		         'snmpsysdesc'     => $r['sysdesc'],            
		         'snmpsysoid'      => $r['sysoid'],            
		         'snmpsysloc'      => $r['sysloc'],            
		         'enterprise'      => $r['enterprise'],            
		         'mac'             => $r['mac'],            
		         'macvendor'       => $r['mac_vendor'],            
		         'network'         => $r['network'],            
		         'switch'          => $r['switch'],            
		         'xagentversion'   => $r['xagent_version'],            
		         'entity'          => $r['entity'],            
		         'geo'             => $r['geodata'],            
		         'critic'          => $r['critic'],            
		         'correlated'      => $r['correlated_by'],            
		         'status'          => $r['status'],            
					'asset_container' => $r['asset_container'],
					'background'      => $r['background'],
					'rule_name'       => $r['rule_name'],
					'dyn'             => $r['dyn'],
				);
				$this->set_system_field($a_aux);

				// En caso de haber campos de usuario, miramos los valores para dicho dispositivo
            if(count($a_aux)>0){
               $data = array('__ID_DEV__'=>$this->get_system_field('id'));
               $result = doQuery('all_device_custom_data',$data);
               foreach($result['obj'] as $r){
                  foreach($a_custom_fields as $custom_fields_id=>$custom_fields_descr){
                     $this->set_custom_field($custom_fields_descr,$r["columna".$custom_fields_id]);
                  }
               }
				}

            // Perfiles 
            $a_profile = array('0');
            $data = array('__ID_DEV__'=>$this->get_system_field('id'));
            $result = doQuery('get_organizational_profile_from_device',$data);
            foreach($result['obj'] as $r) $a_profile[]=$r['id_cfg_op'];
            $this->set_system_field('profile',implode(',',$a_profile));

				// Credenciales
			   $a_credential = array();
			   $data   = array('__ID_DEV__'=>$this->get_system_field('id'));
			   $result = doQuery('credential_from_device',$data);
			   foreach($result['obj'] as $r)	$a_credential[]=$r['id_credential'];
				$this->set_system_field('credential',implode(',',$a_credential));

				// Grupos tecnológicos
   			$a_tech_group = array();
			   $data   = array('__ID_DEV__'=>$this->get_system_field('id'));
			   $result = doQuery('get_device_tech_group',$data);
			   foreach($result['obj'] as $r) $a_tech_group[]=$r['apptype'];
				$this->set_system_field('tech_group',implode(',',$a_tech_group));


			}

			return $a_res;
		}

		/*
		* Function: convert_to_asset()
		* Input:
		* Output:
		* Visibility: public
		* Descr: Convierte el dispositivo en un elemento TI. En caso de existir como elemento TI, lo actualiza.
		*/
		public function convert_to_asset(){
			// Paso 1: Comprobar si el tipo de dispositivo existe como tipo de asset
			//      1.1 (No existe el tipo) => Crear el tipo de asset
			// Paso 2: Comprobar si la categoría General existe en el tipo de asset
			//      2.1 (No existe la categoría => Crear la categoría General en el tipo de asset
			// Paso 3: Comprobar si el dispositivo existe en el tipo de asset
			//      3.1 (No existe el dispositivo) => Crear el asset
			//      3.2 (Existe el dispositivo) => Modificar el asset
			// Paso 4: Asignar los campos de usuario del dispositivo a los campos de dispositivo del asset

			$res = 0;

			// Paso 1
			$descr = $this->get_field('type');
			$data = array('__DESCR__'=>$descr);
			$result = doQuery('get_asset_types_by_descr',$data);
			// Paso 1.1
			if($result['cont']==0){
				// Obtener el id_host_type
				$data = array('__DESCR__'=>$descr);
				$result = doQuery('device_types_by_descr',$data);
				$id_host_type = $result['obj'][0]['id_host_type'];

   		   $available_status = '["Activo","Inactivo"]';
	      	$available_owner = '["Administrador"]';
		      $hash_asset_type = substr( md5(strtolower($descr)),0,8);
		      $data=array('__DESCR__'=>$descr,'__AVAILABLE_STATUS__'=>$available_status,'__AVAILABLE_OWNER__'=>$available_owner,'__HASH_ASSET_TYPE__'=>$hash_asset_type,'__MANAGE__'=>0,'__ID_HOST_TYPE__'=>$id_host_type);
		      $result = doQuery('new_asset_type', $data);
		      if ($result['rc']!=0){
					return 1;
               CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->__convert_to_asset() >> Can't create asset type");
		      }
			}
			else{
				$hash_asset_type = $result['obj'][0]['hash_asset_type'];
			}

			// Paso 2
			$hash_asset_subtype = substr( md5(strtolower('General')),0,8);
			$data = array('__HASH_ASSET_TYPE__'=>$hash_asset_type,'__HASH_ASSET_SUBTYPE__'=>$hash_asset_subtype);
			$result = doQuery('get_asset_subtypes_by_type_subtype',$data);
			// Paso 2.1
         if($result['cont']==0){
			   $hash_asset_subtype = substr( md5(strtolower('General')),0,8);
            $data=array('__DESCR__'=>'General','__HASH_ASSET_TYPE__'=>$hash_asset_type,'__HASH_ASSET_SUBTYPE__'=>$hash_asset_subtype);
            $result = doQuery('new_asset_subtype', $data);
            if ($result['rc']!=0){
               return 1;
               CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->__convert_to_asset() >> Can't create asset General subtype");
            }
			}
			
			// Paso 3
			$data = array('__ID_DEV__'=>$this->get_field('id'));
			$result = doQuery('get_asset_info_by_id_dev',$data);
			// Paso 3.1
			if($result['cont']==0){
				$hash_asset = '';
				$status     = 'Activo';
				$owner      = 'Administrador';
				$critic     = 50;
				$subtype    = 'General';
			}
			// Paso 3.2
			else{
				$hash_asset = $result['obj'][0]['hash_asset'];
				$status     = $result['obj'][0]['status'];
				$owner      = $result['obj'][0]['owner'];
				$critic     = $result['obj'][0]['critic'];
				$hash_asset_subtype = $result['obj'][0]['hash_asset_subtype'];
				$subtype    = $result['obj'][0]['subtype'];
			}

	   	include_once('inc/class.cnmasset.php');

			// Paso 4
			// Campos de sistema
			$a_field = array(
	         'name'               => $this->get_field('name'),
	         'type'               => $this->get_field('type'),
	         'subtype'            => $subtype,
	         'critic'             => $critic,
	         'status'             => $status,
	         'owner'              => $owner,
	         'hash_asset_type'    => $hash_asset_type,
	         'hash_asset_subtype' => $hash_asset_subtype,
				'id_dev'             => $this->get_field('id'),
			);
	
			// Campos de usuario
         $a_aux = array();
         $result = doQuery('get_user_fields',$data);
         foreach($result['obj'] as $r) $a_field[$r['descr']] = $this->a_custom_fields[$r['descr']];

			$asset = new cnmasset($hash_asset);	
			$asset->set_field($a_field);
			$asset->save();
		}
	
      /*
      * Function: set_field()
      * Input: 
      *  - clave y valor
      *  - array con claves y valores
      * Output:
      *  - 0 => La operación ha sido correcta
      *  - 1 => Ha habido algún fallo
      * Visibility: public
      * Descr: Modifica en el dispositivo el campo/los campos indicados. 
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
                  // CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->set_field() >> couldn't modify all fields");
               }
            }
            else{
               // error: un parámetro y no es array
               CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->set_field() >> 1 param and not array");
               $rc = 1;
            }
         }
         elseif(func_num_args()==2){
            if(array_key_exists(func_get_arg(0),$this->a_system_fields)){
					// error: el campo no es modificable
					if(in_array(func_get_arg(0),$this->a_system_fields_fixed)){
               	// error: el parámetro no existe
	               $rc = 1;
	               CNMUtils::debug_log(__FILE__, __LINE__, "cnmdevice->set_field() >> param ".func_get_arg(0)." is not modifiable");
					}
					else{
						$rc = $this->set_system_field(func_get_arg(0),func_get_arg(1));
					}
				}
            elseif(array_key_exists(func_get_arg(0),$this->a_custom_fields)) $rc = $this->set_custom_field(func_get_arg(0),func_get_arg(1));
            else{
               // error: el parámetro no existe
               $rc = 1;
               CNMUtils::debug_log(__FILE__, __LINE__, "cnmdevice->set_field() >> param doesn't exist");
            }
         }
         else{
            // error: ni uno ni dos parámetros
            $rc = 1;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->set_field() >> not 1 or 2 params");
         }
         return $rc;
      }

		/*
		* Function: get_field()
		* Input:
		* 	- $field:
		* Output:
		* Visibility:
		* Descr:
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
		* Visibility: public
		* Descr: Almacena un dispositivo
		*/
		public function save(){
			$a_res = array(
				'rc'    => 0,
				'rcstr' => '',
				'id'    => ''
			);


			// En caso de ser un dispositivo con ip dinámica se actualiza la dirección ip
			if($this->get_system_field('dyn')==1){
            $this->set_system_field('ip',gethostbyname($this->get_system_field('name').".".$this->get_system_field('domain')));
            if (! filter_var($this->get_system_field('ip'), FILTER_VALIDATE_IP)) {
               $a_res['rc']    = 1;
               $err_msg = "Dynamic IP address: Field ip couldn't be resolved (".$this->get_system_field('name').".".$this->get_system_field('domain').")";
               $a_res['rcstr'] = $err_msg;
               CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ".$err_msg);
               return $a_res;
            }
			}

	      // Validacion: ip no valida
	      if($this->get_system_field('ip')==''){
				$this->set_system_field('ip',gethostbyname($this->get_system_field('name').".".$this->get_system_field('domain')));
	         if (! filter_var($this->get_system_field('ip'), FILTER_VALIDATE_IP)) {
	            $a_res['rc']    = 1;
					$err_msg = "IP address empty: Field ip couldn't be resolved (".$this->get_system_field('name').".".$this->get_system_field('domain').")";
	            $a_res['rcstr'] = $err_msg;
	            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ".$err_msg);
	            return $a_res;
	         }
	      }
			// Validacion: snmp v1 o v2 y sin comunidad
	      if(($this->get_system_field('snmpversion')==1 OR $this->get_system_field('snmpversion')==2) AND $this->get_system_field('snmpcommunity')==''){
	         $a_res['rc']    = 1;
				$err_msg = "Field snmpcommunity is required with snmpversion=".$this->get_system_field('snmpversion');
	         $a_res['rcstr'] = $err_msg;
	         CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ".$err_msg);
	         return $a_res;
	      }
			// Validacion: snmp v3 sin credencial
	      if($this->get_system_field('snmpversion')==3 AND $this->get_system_field('snmpcredential')==''){
	         $a_res['rc']    = 1;
				$err_msg = "Field snmpcredential is required with snmpversion=".$this->get_system_field('snmpversion');
	         $a_res['rcstr'] = $err_msg;
				CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ".$err_msg);
	         return $a_res;
	      }

			// Validacion: sin fondo
         if( $this->get_system_field('background')=='' OR !file_exists("/var/www/html/onm/user/background/".$this->get_system_field('background')) ){
				$this->set_system_field('background','magic.gif');
         }

			
         //Actualizar por snmp los parametros del dispositivo
			$this->do_mib2_system();

	      // Insertar los campos fijos
	      $aux_community = $this->get_system_field('snmpversion') == 3?$this->get_system_field('snmpcredential'):$this->get_system_field('snmpcommunity');
	      $data=array(
				'__ID_DEV__'          => $this->get_system_field('id'),
	         '__NAME__'            => $this->get_system_field('name'),
	         '__DOMAIN__'          => $this->get_system_field('domain'),
	         '__STATUS__'          => $this->get_system_field('status'),
	         '__IP__'              => $this->get_system_field('ip'),
	         '__WBEM_USER__'       => '',
	         '__WBEM_PWD__'        => '',
	         '__SYSDESC__'         => $this->get_system_field('snmpsysdesc'),
	         '__SYSOID__'          => $this->get_system_field('snmpsysoid'),
	         '__SYSLOC__'          => $this->get_system_field('snmpsysloc'),
	         '__TYPE__'            => $this->get_system_field('type'),
	         '__VERSION__'         => $this->get_system_field('snmpversion'),
	         '__COMMUNITY__'       => $aux_community,
	         '__XAGENT_VERSION__'  => $this->get_system_field('xagentversion'),
	         '__ENTERPRISE__'      => $this->get_system_field('enterprise'),
				'__CORRELATED_BY__'   => intval($this->get_system_field('correlated')),
	         '__MAC__'             => $this->get_system_field('mac'),
	         '__MAC_VENDOR__'      => $this->get_system_field('macvendor'),
	         '__CRITIC__'          => $this->get_system_field('critic'),
	         '__GEODATA__'         => $this->get_system_field('geo'),
	         '__NETWORK__'         => $this->get_system_field('network'),
	         '__SWITCH__'          => $this->get_system_field('switch'),
	         '__ENTITY__'          => $this->get_system_field('entity'),
				'__WSIZE__'           => $this->get_system_field('wsize'),
				'__ASSET_CONTAINER__' => $this->get_system_field('asset_container'),
				'__DYN__'             => $this->get_system_field('dyn'),
	      );

			$action = 'create';
			// En caso de tener id = 0 hay que crear
			if($this->get_system_field('id')==0){
	      	$result = doQuery('create_device',$data);
		      if ($result['rc']!=0) {
		         $a_res['rc']    = 1;
	            $err_msg = "Can't create device (step 1):{$result['rcstr']}";
   	         $a_res['rcstr'] = $err_msg;
      	      CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ".$err_msg);
		         return $a_res;
		      }

		      ///////////////////////
		      // OBTENER EL ID_DEV //
		      ///////////////////////
				$data = array();
		      $result = doQuery('last_id_inserted',$data);
				$this->set_system_field('id',$result['obj'][0]['last']);

				$action = 'create';
			}
			// En otro caso hay que modificar
			else{
   			$result = doQuery('update_device',$data);
	         if ($result['rc']!=0) {
	            $a_res['rc']    = 1;
               $err_msg = "Can't update device (step 1):{$result['rcstr']} Query:{$result['query']}";
               $a_res['rcstr'] = $err_msg;
               CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ${result['rc']} ".$err_msg);
	            return $a_res;
	         }

				// Se ha modificado el nombre o el dominio
				if($this->a_meta_fields['change_label'] == 1) $this->change_metric_label();
				
				// Se ha modificado un campo de sistema (ip,snmpcommunity,snmpversion,status)
				if($this->a_meta_fields['do_workset'] == 1) $this->do_workset();

				// Si hay cambio de ip se actualiza el mapeo de alertas remotas y tareas.
				if($this->a_meta_fields['change_ip'] == 1) $this->change_device_ip();
				$action = 'update';
			}

			$this->a_meta_fields['do_workset']   = 0;
			$this->a_meta_fields['change_ip']    = 0;
         $this->a_meta_fields['old_ip']       = '';
         $this->a_meta_fields['old_name']     = '';
         $this->a_meta_fields['old_domain']   = '';
			$this->a_meta_fields['change_label'] = 0;

	      // Insertar campos personalizados
	      $a_local_res=$this->save_custom_fields();
	      if ($a_local_res['rc']!=0){
	         $a_res['rc']    = 1;
            $err_msg = "Can't update device (step 2): {$a_local_res['rc']} || {$a_local_res['rcstr']}";
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ".$err_msg);
	         return $a_res;
	      }

	      // Crear la red en cfg_networks
	      if($this->get_system_field('network')!=''){
	         $data_net = array('__NETWORK__' => $this->get_system_field('network'));
	         $result = doQuery('create_network', $data_net);
	      }

	      // Recargar el trap_manager
			if($action == 'create') $this->reload_trap_manager();

			// Poner el dispositivo en los perfiles organizativos
			$a_local_res=$this->save_profile();
         if ($a_local_res['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't update device (step 3): {$a_local_res['rc']} || {$a_local_res['rcstr']}";
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ".$err_msg);
            return $a_res;
         }

		   // Asociar el dispositivo a las credenciales
			/*
			// PENDIENTE
			$a_local_res=$this->save_credential();
         if ($a_local_res['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't update device (step 4): {$a_local_res['rc']} || {$a_local_res['rcstr']}";
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ".$err_msg);
            return $a_res;
         }
			*/


		   // Sincronizar el mapeo de dispositivo a rol
		   $this->store_qactions('domain_sync','sync_mode=devices2profile','','SYNC DOMAIN (PERFIL DE DISPOSITIVOS)','ATYPE_MCNM_DOMAIN_SYNC');

		   // Modificar la ficha de dispositivo
         $a_local_res=$this->set_device_record();
         if ($a_local_res['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't update device (step 5): {$a_local_res['rc']} || {$a_local_res['rcstr']}";
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ".$err_msg);
            return $a_res;
         }

			// Crear aplicaciones y metricas del asistente
			if($action == 'create'){
	         $a_local_res=$this->create_apps_and_metrics();
	         if ($a_local_res['rc']!=0){
	            $a_res['rc']    = 1;
	            $err_msg = "Can't update device (step 6): {$a_local_res['rc']} || {$a_local_res['rcstr']}";
	            $a_res['rcstr'] = $err_msg;
	            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->save() >> ".$err_msg);
	            return $a_res;
	         }
			}

			$a_res['id'] = $this->get_system_field('id');
			return $a_res;
      }



      /*
      * Function: validate_credential()
      * Input:
      * Output:
      * Visibility: public
      * Descr: Validar si una credencial funciona en un dispositivo
      */
      public function validate_credential($id_credential=null){
			$a_res = array(
				'rc'    => '',
				'rcstr' => ''
			);
		
			// Validacion: Comprobar que el dispositivo no es nuevo
			if($this->get_system_field('id')==0){
				$a_res['rc'] = 1;
            $err_msg = "Device with id ".$this->get_system_field('id')." doesn't exist";
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->validate_credential() >> ".$err_msg);
            return $a_res;
			}

			// Validacion: La credencial no esta vacia
         if($id_credential==null){
            $a_res['rc'] = 1;
            $err_msg = "Credential is not defined";
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->validate_credential() >> ".$err_msg);
            return $a_res;
         }

		   $cmd="/usr/bin/sudo /opt/cnm/crawler/bin/support/chk-credential -c $id_credential -i ".$this->get_system_field('id');
		   exec($cmd,$results);
		   $a_res['rc']  = $results[0];
		   $a_res['msg'] = $results[1];

		   //El resultado ya esta codificadoen JSON
		   CNMUtils::info_log(__FILE__, __LINE__, "cnmdevice->validate_credential() >> CMD=$cmd >> $results[0] $results[1]");
			return $a_res;
		}


      /*
      * Function: delete()
      * Input:
      * Output:
      * Visibility: public
      * Descr: Borrar el dispositivo
      */
      public function delete(){
         // Paso 1:  Borrar las metricas en curso del dispositivo
         // Paso 2:  Informar en auditoria del borrado del dispositivo
         // Paso 3:  Eliminar el dispositivo
         // Paso 4:  Eliminar los avisos asociadas al dispositivo
			// Paso 5:  Eliminar los datos de usuario del dispositivo
			// Paso 6:  Eliminar el dispositivo de los perfiles organizativos
			// Paso 7:  Eliminar los tips asociados al dispositivo    
			// Paso 8:  Eliminar las entradas en cfg_remote_alerts2device asociados al dispositivo
			// Paso 9:  Eliminar las alertas asociadas al dispositivo de la tabla alerts
			// Paso 10: Eliminar las alertas asociadas al dispositivo de la tabla alerts_store
			// Paso 11: Eliminar las entradas en prov_template_metrics asociados al dispositivo
         //      3.1 (No existe el dispositivo) => Crear el asset
         //      3.2 (Existe el dispositivo) => Modificar el asset
         // Paso 4: Asignar los campos de usuario del dispositivo a los campos de dispositivo del asset


         $a_res = array(
            'rc'    => 0,
            'rcstr' => '',
         );

         // Validacion: Comprobar que el dispositivo no es nuevo
         if($this->get_system_field('id')==0){
            $a_res['rc'] = 1;
            $err_msg = "Device with id ".$this->get_system_field('id')." doesn't exist";
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }

			// Paso 1
			$a_id_metric = array();
			$data = array('__ID_DEV__'=>$this->get_field('id'));
			$result = doQuery('metrics_device',$data);
			foreach($result['obj'] as $r) $a_id_metric[]=$r['id_metric'];
			$concat_id_metric = implode(',',$a_id_metric);
		   delete_metrics($id_metrics,$cid);
		
			// Paso 2
			info_qactions('Borrar dispositivo',$_SESSION['LUSER'],0,"El usuario {$_SESSION['LUSER']} desde la ip {$_SESSION['REMOTE_ADDR']} ha borrado el dispositivo ".$this->get_field('name').".".$this->get_field('domain')." (".$this->get_field('ip').") ID=".$this->get_field('id'));

		   // Paso 3
			$data = array('__ID_DEV__'=>$this->get_field('id'));
			$result = doQuery('delete_device',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete delete device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
			}
		
		   // Paso 4
         $data = array('__ID_DEV__'=>$this->get_field('id'));
         $result = doQuery('delete_notifications_of_device',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete delete notifications from device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }

		   // Paso 5
         $data = array('__ID_DEV__'=>$this->get_field('id'));
         $result = doQuery('delete_custom_data_of_device',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete user data from device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }

		   // Paso 6
         $data = array('__ID_DEV__'=>$this->get_field('id'));
         $result = doQuery('delete_organizational_profile_of_device',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete organizational profile from device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }
		
		   // Paso 7
         $data = array('__ID_DEV__'=>$this->get_field('id'));
         $result = doQuery('delete_tips_of_device',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete tips from device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }

		   // Paso 8
         $data = array('__TARGET__'=>$this->get_field('ip'));
         $result = doQuery('delete_remote_alerts_of_device',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete remote alerts from device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }

		   // Paso 9
         $data = array('__ID_DEVICE__'=>$this->get_field('id'));
         $result = doQuery('delete_alerts_of_device',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete alerts from device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }

		   // Paso 10
         $data = array('__ID_DEVICE__'=>$this->get_field('id'));
         $result = doQuery('delete_alerts_store_of_device',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete stored alerts from device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }

			$a_id_template_metric = array();
         $data = array('__ID_DEV__'=>$this->get_field('id'));
			$result = doQuery('get_all_from_prov_template_metrics_by_id_dev',$data);
			foreach($result['obj'] as $r) $a_id_template_metric[]=$r['id_template_metric'];
			$concat_id_template_metric = implode(',',$a_id_template_metric);

		   // Paso 11
         $data = array('__ID_TEMPLATE_METRIC__'=>$concat_id_template_metric);
         $result = doQuery('delete_prov_template_metrics',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete tickets from device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }

		   // Se borra de prov_template_metric2iid
         $data = array('__ID_TEMPLATE_METRIC__'=>$concat_id_template_metric);
         $result = doQuery('delete_prov_template_metrics2iid',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete tickets from device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }

		   // Elimina las entradas en device2features asociados al dispositivo
         $data = array('__ID_DEV__'=>$this->get_field('id'));
         $result = doQuery('delete_device_of_device2features',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete tickets from device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }

		   // Elimina los tickets del dispositivo
         $data = array('__ID_DEV__'=>$this->get_field('id'));
         $result = doQuery('delete_ticket_of_device',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete tickets from device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }

		   // Elimina de prov_default_metrics2device
         $data = array('__ID_DEV__'=>$this->get_field('id'));
         $result = doQuery('delete_metrics2device_of_device',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete prov default metrics from device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }
	
		   // Elimina de prov_default_apps2device 
         $data = array('__ID_DEV__'=>$this->get_field('id'));
         $result = doQuery('delete_prov_default_apps2device_of_device',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete prov default apps from device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }

		   // Elimina de cfg_app2device 
         $data = array('__ID_DEV__'=>$this->get_field('id'));
         $result = doQuery('delete_cfg_app2device_of_device',$data);
         if($result['rc']!=0){
            $a_res['rc']    = 1;
            $err_msg = "Can't delete configured apps device with id=".$this->get_field('id');
            $a_res['rcstr'] = $err_msg;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->delete() >> ".$err_msg);
            return $a_res;
         }


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
      * Descr: Modifica en el dispositivo el campo/los campos de sistema indicados. 
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
                  CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->set_system_field() >> couldn't modify all fields");
               }
            }
            else{
               // error: un parámetro y no es array
               CNMUtils::error_log(__FILE__, __LINE__, "cnmadevice->set_system_field() >> 1 param and not array");
               $rc = 1;
            }
         }
         elseif(func_num_args()==2){
            if(array_key_exists(func_get_arg(0),$this->a_system_fields)){
               $this->a_system_fields[func_get_arg(0)] = func_get_arg(1);


					if(func_get_arg(0) == 'name'){
						$this->a_meta_fields['old_name'] = $this->get_system_field('name');
						$this->a_meta_fields['change_label'] = 1;
					}
					elseif(func_get_arg(0) == 'domain'){
						$this->a_meta_fields['old_domain'] = $this->get_system_field('domain');
						$this->a_meta_fields['change_label'] = 1;
					} 
	            elseif(func_get_arg(0) == 'ip'){
	               $this->a_meta_fields['old_ip'] = $this->get_system_field('ip');
	               $this->a_meta_fields['change_ip'] = 1;
						$this->a_meta_fields['do_workset'] = 1;
	            }
	            elseif(func_get_arg(0) == 'status'){
	               $this->a_meta_fields['do_workset'] = 1;
	            }
					elseif(func_get_arg(0) == 'snmpversion'){
	               $this->a_meta_fields['do_workset'] = 1;
	            }
					elseif(func_get_arg(0) == 'snmpcommunity'){
	               $this->a_meta_fields['do_workset'] = 1;
	            }
            }
            else{
               // error: el parámetro no existe
               $rc = 1;
               CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->set_system_field() >> param ".func_get_arg(0)." doesn't exist");
            }
         }
         else{
            // error: ni uno ni dos parámetros
            $rc = 1;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->set_system_field() >> not 1 or 2 params");
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
      * Descr: Modifica en el dispositivo el campo/los campos de usuario indicados. 
      * Una vez hecho hay que invocar el método save para almacenar los cambios 
      */
      private function set_custom_field($key,$value){
			$rc = 0;

         if(func_num_args()==1){
            if(is_array(func_get_arg(0))){
               foreach(func_get_arg(0) as $key => $value){
                  if(0!=$this->set_custom_field($key,$value)) $rc = 1;
               }
               if($rc==1){
                  // error: no se han modificado todos los campos
                  CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->set_custom_field() >> couldn't modify all fields");
               }
            }
            else{
               // error: un parámetro y no es array
               CNMUtils::error_log(__FILE__, __LINE__, "cnmadevice->set_custom_field() >> 1 param and not array");
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
               CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->set_custom_field() >> param doesn't exist");
            }
         }
         else{
            // error: ni uno ni dos parámetros
            $rc = 1;
            CNMUtils::error_log(__FILE__, __LINE__, "cnmdevice->set_custom_field() >> not 1 or 2 params");
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


		/*
		* Function: save_custom_fields()
		* Input:
		* Output:
		* Visibility: private
		* Descr:
		*/
		// ////////////////////////////////////////////////////////////////// //
		// Función que almacena en BBDD los campos de usuario del dispositivo //
		// ////////////////////////////////////////////////////////////////// //
		private function save_custom_fields(){
			global $dbc;
	
	   	$a_res = array(
				'rc'=>0,
				'rcstr'=>''
			);
	
		   $sql_insertar="INSERT IGNORE INTO devices_custom_data (id_dev) VALUES (".$this->get_system_field('id').")";
		   $result_insertar = $dbc->query($sql_insertar);
	
/*
+----+---------------------+------+
| id | descr               | tipo |
+----+---------------------+------+
|  1 | Proveedor           |    0 |
|  2 | Fabricante          |    0 |
|  3 | Responsable interno |    0 |
|  4 | Descripcion         |    1 |
|  5 | Precio              |    0 |
|  6 | Link                |    2 |
|  7 | IP Secundaria       |    0 |
+----+---------------------+------+
*/
		   $sql2="SELECT id,descr FROM devices_custom_types";
		   $result2 = $dbc->query($sql2);
		   while ($result2->fetchInto($r2)){
				$dato=$dbc->escapeSimple($this->get_custom_field($r2['descr']));
				// ////////////////// //
				// SSV: PROXY INVERSO //
				// ////////////////// //
		      $dato=str_replace('[proxy]', '____PROXY____[proxy]', $dato);
		
				$sql4="UPDATE devices_custom_data SET columna{$r2['id']}='$dato' WHERE id_dev=".$this->get_system_field('id');
		      $result4 = $dbc->query($sql4);


	         // /////////////////////////////////////////////////////////// //
      	   // MYSQL NO ADMITE PONER DEFAULT VALUE EN CAMPOS TEXT          //
	         // SOLUCION: ACTUALIZAMOS A - LAS COLUMNAS QUE NO TENGAN DATOS //
	         // /////////////////////////////////////////////////////////// //
	         $sql5="UPDATE devices_custom_data SET columna{$r2['id']} ='-' WHERE columna{$r2['id']} ='' or columna{$r2['id']} IS NULL";
   	      $result5 = $dbc->query($sql5);
			} 
	   	return $a_res;
		}
		
		// Funcion que hace que se recarque el trap_manager
		private function reload_trap_manager(){
         $cmd="/usr/bin/sudo /etc/init.d/syslog-ng reload 2>&1";
         exec($cmd,$results);
		}

		// Funcion que almacena los perfiles de un dispositivo
		private function save_profile(){
			global $dbc;

			$a_res = array('rc'=>0,'rcstr'=>'');
		
			$a_profiles = explode(',',$this->get_system_field('profile'));

			$a_profiles[] = 'Global';

		   $a_profiles = array_unique($a_profiles); // Eliminamos perfiles duplicados
		   $a_profiles = array_filter($a_profiles); // Eliminamos perfiles vacios

/*
mysql> select * from cfg_devices2organizational_profile;
+--------+-----------+---------+
| id_dev | id_cfg_op | cid     |
+--------+-----------+---------+
|      0 |         1 | default |
|      1 |         1 |         |
|      1 |         1 | default |
|      1 |         2 | default |
|      1 |         3 | default |
|      3 |         1 | default |
|      4 |         1 | default |
|      9 |         1 | default |
|     10 |         1 | default |
|     11 |         1 | default |
+--------+-----------+---------+

mysql> select * from cfg_organizational_profile;
+-----------+----------------+------------+
| id_cfg_op | descr          | user_group |
+-----------+----------------+------------+
|         1 | Global         | ,3,1,      |
|         2 | s30            | ,5,        |
|         3 | Sistemas       | ,4,        |
|         4 | Comunicaciones |            |
|         5 | Impresoras     | ,5,        |
+-----------+----------------+------------+
5 rows in set (0.00 sec)
*/
		   $a_asoc = array();
		   $sql2="SELECT id_cfg_op,descr FROM cfg_organizational_profile";
		   $result2 = $dbc->query($sql2);
		   while ($result2->fetchInto($r2))$a_asoc[$r2['descr']] = $r2['id_cfg_op'];
	
		   foreach($a_asoc as $descr => $id_cfg_op){
		      // Se inserta
		      if(in_array($descr,$a_profiles)){
		         $sql3 = "INSERT IGNORE INTO cfg_devices2organizational_profile (id_dev,id_cfg_op,cid) VALUES (".$this->get_system_field('id').",$id_cfg_op,'".$this->cid."')";
		      }
		      // Se borra
		      else{
		         $sql3 = "DELETE FROM cfg_devices2organizational_profile WHERE id_dev=".$this->get_system_field('id')." AND id_cfg_op=$id_cfg_op AND cid='".$this->cid."'";
		      }
		      $result3 = $dbc->query($sql3);
		   }

			return $a_res;
		}

		private function save_credential(){
			// PENDIENTE DE VER CÓMO HACERLO
		}


		// Funcion que crea las aplicaciones y metricas del asistente
		private function create_apps_and_metrics(){
			$a_res = array('rc'=>0,'rcstr'=>'');
		   $outputfile='/dev/null';
		   $pidfile='/tmp/pid';
		   $cmd="/usr/bin/sudo /opt/crawler/bin/prov_device_app_metrics -i ".$this->get_system_field('id')." -c ".$this->cid;
		   exec(sprintf("%s > %s 2>&1 & echo $! >> %s", $cmd, $outputfile, $pidfile));
			return $a_res;
		}

		// Funcion que genera la ficha de dispositivo
		private function set_device_record(){
			global $dbc;

			$a_status_string = array(
				0=>'ACTIVE',
				1=>'DOWN',
				2=>'MAINTENANCE',
			);

			$all_tags = CNMUtils::core_i18n_global();
			$kk = $all_tags['_name'];
			CNMUtils::info_log(__FILE__, __LINE__, "set_device_record >> DEBUG kk=$kk");
	

			$descripcion='';

			// ///////////////// //
			// CAMPOS DE SISTEMA //
			// ///////////////// //
		   $descripcion.=$all_tags['_name'].': '.$this->get_system_field('name')."\n";
		   $descripcion.=$all_tags['_domain'].': '.$this->get_system_field('domain')."\n";
		   $descripcion.=$all_tags['_ip'].': '.$this->get_system_field('ip')."\n";
		   $descripcion.=$all_tags['_snmpcommunity'].': '.$this->get_system_field('snmpcommunity')."\n";
			$mac_info='-';
			if ($this->get_system_field('mac') != 0) {
				$mac_info = $this->get_system_field('mac').' ('.$this->get_system_field('mac_vendor').')';
			}
		   $descripcion.=$all_tags['_mac'].': '.$mac_info."\n";
		   $descripcion.=$all_tags['_criticity'].': '.$this->get_system_field('critic').' '.$all_tags['_outof100']."\n";
		   $descripcion.=$all_tags['_type'].': '.$this->get_system_field('type')."\n";

		   $descripcion.=$all_tags['_status'].': ';
			$stat = $this->get_system_field('status');
			if ($stat==0) { $descripcion.=$all_tags['_active']."\n"; }
			elseif ($stat==1) { $descripcion.=$all_tags['_unmanaged']."\n"; }
			elseif ($stat==2) { $descripcion.=$all_tags['_maintenance']."\n"; }

			$descripcion.=$all_tags['_alertssensitivity'].': ';
			$sens = $this->get_system_field('sensibility');
         if ($sens==0) { $descripcion.=$all_tags['_normal']."\n"; }
         elseif ($sens==5) { $descripcion.=$all_tags['_low']."\n"; }
         elseif ($sens==10) { $descripcion.=$all_tags['_verylow']."\n"; }
			

			// ///////////////// //
			// CAMPOS DE USUARIO //
			// ///////////////// //
/*
mysql> select * from devices_custom_types;
+----+---------------------+------+
| id | descr               | tipo |
+----+---------------------+------+
|  1 | Proveedor           |    0 |
|  2 | Fabricante          |    0 |
|  3 | Responsable interno |    0 |
|  4 | Descripcion         |    1 |
|  5 | Precio              |    0 |
|  6 | Link                |    2 |
|  7 | IP Secundaria       |    0 |
+----+---------------------+------+
7 rows in set (0.00 sec)

*/

		   $sql2="SELECT id,descr,tipo FROM devices_custom_types";
		   $result2 = $dbc->query($sql2);
		   while ($result2->fetchInto($r2)){
				$descripcion.=$r2['descr'];
				if($r2['tipo']==2 and $this->get_custom_field($r2['descr'])!='-'){
					$descripcion.=": <a href='".$this->get_custom_field($r2['descr'])."' target='_blank' style='color=#0000CC;text-decoration=underline'> ".$this->get_custom_field($r2['descr'])." </a>\n";
				}
				else{
		         $descripcion.=": ".$this->get_custom_field($r2['descr'])."\n";
				}
		   }

			// //////// //
			// PERFILES //
			// //////// //
			$descripcion.=$all_tags['_organizationalprofiles'].': '.$this->get_system_field('profile')."\n";

			// ¿?¿?¿?¿?
		   $descripcion = substr_replace($descripcion,'',-1);
		   // print "***** DESCR == $descripcion *****\n";

			// //////////////////////////// //
			// INSERTAR LA FICHA EN LA BBDD //
			// //////////////////////////// //
		   $date=time();
			$name=$all_tags['_docdevicesummary'];
			$sqlTip = "INSERT INTO tips (id_ref,tip_type,name,date,tip_class,descr) VALUES ('".$this->get_system_field('id')."','id_dev','$name','$date',1,'".$this->str2jsQM($descripcion)."') ON DUPLICATE KEY UPDATE date='$date',descr='".$this->str2jsQM($descripcion)."',name='$name' ";
		   $dbc->query($sqlTip);
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


		private function store_qactions($action,$elems,$cmd,$descr,$atype='DEFAULT'){
			global $dbc;

			$a_atype2string = array(
				'DEFAULT'                                        => '0',
				'ATYPE_USER_LOGIN'                               => '1',
				'ATYPE_DB_MANT_TABLE_LIMIT'                      => '2',
				'ATYPE_CLONE_DEVICES'                            => '5',
				'ATYPE_SET_METRICS_FROM_ASISTANT'                => '10',
				'ATYPE_SET_METRICS_FROM_TEMPLATE'                => '11',
				'ATYPE_SET_TEMPLATE_FROM_ASISTANT'               => '12',
				'ATYPE_RESET_METRICS'                            => '13',
				'ATYPE_SET_METRICS_FROM_TEMPLATE_CHANGE_DEVICE'  => '14',
				'ATYPE_SET_METRICS_FROM_TEMPLATE_CHANGE_METRIC'  => '15',
				'ATYPE_SET_METRICS_FROM_ASISTANT_BLOCK'          => '16',
				'ATYPE_SET_METRICS_FROM_TEMPLATE_BLOCK'          => '17',
				'ATYPE_SET_TEMPLATE_FROM_ASISTANT_BLOCK'         => '18',
				'ATYPE_CLONE_METRICS'                            => '19',
				'ATYPE_IIDS_MODIFIED'                            => '20',
				'ATYPE_IIDS_ERASED'                              => '21',
				'ATYPE_PROVISION_DEVICES'                        => '22',
				'ATYPE_MODIFY_DEVICE'                            => '23',
				'ATYPE_DEVICE2INACTIVE'                          => '30',
				'ATYPE_DEVICE2ACTIVE'                            => '31',
				'ATYPE_DEVICE2MAINTENANCE'                       => '32',
				'ATYPE_GET_CSV_DEVICES'                          => '40',
				'ATYPE_GET_CSV_METRICS'                          => '41',
				'ATYPE_GET_CSV_VIEWS'                            => '42',
				'ATYPE_NETWORK_AUDIT'                            => '50',
				'ATYPE_APP_EXECUTED'                             => '51',
				'ATYPE_MCNM_DOMAIN_SYNC'                         => '200',
				'ATYPE_NOTIF_BY_EMAIL'                           => '1001',
				'ATYPE_NOTIF_BY_SMS'                             => '1002',
				'ATYPE_NOTIF_BY_TRAP'                            => '1003',
			);

		   // ESTAMOS ASOCIANDO METRICAS A DISPOSITIVOS
		   // $elems SON IPS SEPARADAS POR COMAS
		   if (($action=='setmetric')or($action=='audit')or($action=='clone')or($action=='domain_sync') or($action=='delmetricdata')){
		      $params=$elems;
		   }

		   // print "<br>++++++++++++++++++++++++++++++++<br>";
		   // print $params;
		   // print "<br>++++++++++++++++++++++++++++++++<br>";
		   $time=time();
		   $aux_time=$time;
	
		   $h=md5("$time$action$elems");
		   $hh=substr($h,1,8);

		   $user=$_SESSION['LUSER'];
		   $sql="INSERT INTO qactions (name,descr,action,cmd,params,auser,date_store,date_start,status,task,atype)
		         values ('$hh','$descr','$action','$cmd','$params','$user',$time,$aux_time,0,'$action',".$a_atype2string[$atype].")";
		   // print "SQL ES == $sql";

		   $result = $dbc->query($sql);
		   if (@PEAR::isError($result)) {
		      $msg_error=$result->getMessage();
		      $code_error=$result->getCode();
		      CNMUtils::error_log(__FILE__, __LINE__, "**DBERROR** ($code_error) $msg_error ($sql)");
		      return 1;
		   }
		   else{
		      CNMUtils::debug_log(__FILE__, __LINE__, "STORE OK atype=$atype action=$action elems=$elems cmd=$cmd descr=$descr");
		      return 0;
		   }
		}

		// Funcion que cambia el nombre de las métricas al modificar el nombre o dominio de un dispositivo
		private function change_metric_label(){
			global $dbc;

   		$sql="SELECT id_metric,label from metrics WHERE id_dev=".$this->get_system_field('id');
		   $result = $dbc->query($sql);
		   while ($result->fetchInto($r)){
		      $id_metric=$r['id_metric'];
		      $new_label = str_replace($this->a_meta_fields['old_name'].".".$this->a_meta_fields['old_domain'],$this->get_system_field('name').".".$this->get_system_field('domain'),$r['label']);
		      $sql="UPDATE metrics set label='$new_label' WHERE id_metric=$id_metric";
		      $result1 = $dbc->query($sql);
		   }
		}

		// Funcion que cambia las tareas y las alertas remotas al modificar la direccion ip de un dispositivo
		private function change_device_ip(){
			global $dbc;

		   // cfg_remote_alerts2device
		   $sql="UPDATE cfg_remote_alerts2device set target='".$this->get_system_field('ip')."' WHERE target='".$this->a_meta_fields['old_ip']."'";
		   $result = $dbc->query($sql);
		   // task2device
		   $sql="UPDATE task2device set ip='".$this->get_system_field('ip')."' WHERE ip='".$this->a_meta_fields['old_ip']."'";
		   $result = $dbc->query($sql);
		}

		// Funcion que regenera los datos de las metricas 
		private function do_workset(){
      	$outputfile='/dev/null';
	      $pidfile='/tmp/pid';
	      $cmd="/usr/bin/sudo /opt/crawler/bin/workset -c ".$this->cid." -i ".$this->get_system_field('id')." 2>&1";
      	exec(sprintf("%s > %s 2>&1 & echo $! >> %s", $cmd, $outputfile, $pidfile));
		}

		/*
		* Function: do_mib2_system()
		* Input:
		* Output:
		* Visibility: private
		* Descr: Obtiene los campos snmpsysdesc,snmpsysoid,snmpsysloc,enterprise,mac,macvendor,netmask,network y switch por SNMP de un dispositivo.
		* Despues de ejecutarse hay que llamar al metodo save() para que almacene los cambios
		*/
		private function do_mib2_system(){
			// Sin ip o sin snmp
		   if (($this->get_system_field('ip')=='') || ($this->get_system_field('snmpversion')==0) ) {
				$a_field = array(
               'snmpsysdesc' => 'Valor no obtenido',
               'snmpsysoid'  => 'Valor no obtenido',
               'snmpsysloc'  => 'Valor no obtenido',
               'enterprise'  => '0',
               'mac'         => '0',
               'macvendor'   => '',
               // 'netmask'     => '',
               'network'     => '',
               'switch'      => '0',
				);
		   }
			else{
				// snmp v3
			   if ($this->get_system_field('snmpversion')==3) {
			      $data = array('__ID_PROFILE__'=> $this->get_system_field('snmpcredential'));
			      $result = doQuery('snmp3_profile_info',$data);
			      if ($result['obj'][0]['priv_pass'] != '') {
			         $cmd="/opt/crawler/bin/libexec/mib2_system -v ".$this->get_system_field('snmpversion')." -u {$result['obj'][0]['sec_name']} -l {$result['obj'][0]['sec_level']} -a {$result['obj'][0]['auth_proto']} -A {$result['obj'][0]['auth_pass']} -x {$result['obj'][0]['priv_proto']} -X {$result['obj'][0]['priv_pass']} -n ".$this->get_system_field('ip');
			      }
			      else{
			         $cmd="/opt/crawler/bin/libexec/mib2_system -v ".$this->get_system_field('snmpversion')." -u {$result['obj'][0]['sec_name']} -l {$result['obj'][0]['sec_level']} -a {$result['obj'][0]['auth_proto']} -A {$result['obj'][0]['auth_pass']} -n ".$this->get_system_field('ip');
			      }
			   }
				// snmp v1 o v2
			   else {
			      $cmd="/opt/crawler/bin/libexec/mib2_system -v ".$this->get_system_field('snmpversion')." -c ".$this->get_system_field('snmpcommunity')." -n ".$this->get_system_field('ip');
			   }

            CNMUtils::info_log(__FILE__, __LINE__, "cnmdevice->do_mib2_system() >> CMD=$cmd");
		
			   $results=Array();
			   exec($cmd,$results);

            $a_field = array(
               'snmpsysdesc' => ($results[0]=='')?'Valor no obtenido':$results[0],
               'snmpsysoid'  => ($results[1]=='')?'Valor no obtenido':$results[1],
               'snmpsysloc'  => ($results[3]=='')?'Valor no obtenido':$results[3],
               'enterprise'  => ($results[4]=='')?'0':$results[4],
               'mac'         => ($results[5]=='')?'0':$results[5],
               'macvendor'   => ($results[6]=='')?'':$results[6],
               // 'netmask'     => ($results[7]=='')?'':$results[7],
               'network'     => ($results[8]=='')?'':$results[8],
               'switch'      => ($results[9]=='')?'0':$results[9],
            );

			}
			// CNMUtils::info_log(__FILE__, __LINE__, "cnmdevice->do_mib2_system() >> snmpsysdesc:{$a_field['snmpsysdesc']} snmpsysoid:{$a_field['snmpsysoid']} snmpsysloc:{$a_field['snmpsysloc']} enterprise:{$a_field['enterprise']} mac:{$a_field['mac']} macvendor:{$a_field['macvendor']} netmask:{$a_field['netmask']} network:{$a_field['network']} switch:{$a_field['switch']}");
			CNMUtils::info_log(__FILE__, __LINE__, "cnmdevice->do_mib2_system() >> snmpsysdesc:{$a_field['snmpsysdesc']} snmpsysoid:{$a_field['snmpsysoid']} snmpsysloc:{$a_field['snmpsysloc']} enterprise:{$a_field['enterprise']} mac:{$a_field['mac']} macvendor:{$a_field['macvendor']} network:{$a_field['network']} switch:{$a_field['switch']}");
         $this->set_system_field($a_field);
		}

	}

?>
