<?php


	class cnmprofile {
		public $cid = 'default';

		// Campos que deben existir, sino hay un error
      private $a_must_fields = array('name');

		private $a_meta_fields = array(
			'user'   => '',
			'device' => '',
			'change_name' => '',
		);

		// ///////////////// //
		// Campos de sistema //
		// ///////////////// //
		private $a_system_fields = array(
			'id'         => '',
			'name'       => '',
			'user_group' => '',
		);


		// //////////////////////////////////////////////////////////////////////
		// Funcion constructor
		// Input:
		//    id_cfg_op, name o vacio => En caso de introducir un id_cfg_op, se utilizara para modificar u obtener datos de dicho perfil. 
		//                               En caso de introcucir un name, se utilizara para modificar u obtener datos de dicho perfil.
		//                               En caso de no introducir nada será para crear un perfil.
		// Output:
		//    $a_res['rc']    = 0:OK | otros valores error
		//    $a_res['rcstr'] = '' | descripcion del error
		// Descr:
		// //////////////////////////////////////////////////////////////////////
		public function __construct($id=0){
			global $dbc;

			$a_res = array(
				'rc'    => 0,
				'rcstr' => '',
			);

			if(is_numeric($id)){
				$id_cfg_op = $id;
			}
			else{
				$data = array('__DESCR__'=>$id);
				$result = doQuery('get_organizational_profile_by_descr',$data);
            if($result['cont']==0){
               $a_res['rc']    = 1;
               $a_res['rcstr'] = "Profile $id doesn't exist";
               return $a_res;
            }
				else{
					$id_cfg_op = $result['obj'][0]['id_cfg_op'];
				}
			}


			$this->set_field('id',$id_cfg_op);	
			if($this->get_field('id')==0){
			}
			else{
				$data = array('__ID_CFG_OP__'=>$this->get_field('id'));
				$result = doQuery('info_organizational_profile',$data);
				if($result['cont']==0){
					$a_res['rc']    = 1;	
					$a_res['rcstr'] = "Profile ".$this->get_field('id')." doesn't exist";	
					return $a_res;
				}
				else{
					$r = $result['obj'][0];
					$this->set_field('name',$r['descr']);
					$this->set_field('user_group',$r['user_group']);
				}
			}
			return $a_res;
		}
		
		public function set_field($key,$value){
			$rc = 0;

			if(array_key_exists($key,$this->a_meta_fields)){
				$this->a_meta_fields[$key] = $value;
			}
			elseif(array_key_exists($key,$this->a_system_fields)){
				$this->a_system_fields[$key] = $value;

				if($key == 'name') {
               $this->a_meta_fields['change_name'] = 1;
				}
/*
				elseif($key == 'passwd'){
					$this->generateToken();
					$this->a_meta_fields['change_passwd'] = 1;	
				}
*/
			}

			else $rc = 1;
			return $rc;
		}
		public function set_fields($a_input){
			foreach($a_input as $key => $value)	$this->set_field($key,$value);	
		}
		public function get_field($field){
			$rc = false;
			if(array_key_exists($field,$this->a_system_fields)) $rc = $this->a_system_fields[$field];
			return $rc;
      }

		public function save(){
			global $dbc;

			$a_res = array('rc'=>0,'rcstr'=>'','id'=>'');

	      // //////////// //
	      // VALIDACIONES //
	      // //////////// //
			if($this->get_field('name')==''){
            $a_res['rc']    = 1;
            $a_res['rcstr'] = "FIELD name IS NECESSARY";
            return $a_res;
			}
			
			$data = array(
				'__ID_CFG_OP__' => $this->get_field('id'),
				'__DESCR__'     => $this->get_field('name'),
			);

			// //////////// //
			// CREAR PERFIL //
			// //////////// //
			if($this->get_field('id')==0){
		      $data=array('__DESCR__'=>$this->get_field('name'));
		      $result = doQuery('create_organizational_profile', $data);
				if($result['rc']!=0){
					$a_res['rc'] = $result['rc'];
					$a_res['rcstr'] = $result['rcstr'];
					return $a_res;
				}
	
				// /////////////////////// //
		      // Se obtiene el ID_CFG_OP //
				// /////////////////////// //
		      $result = doQuery('last_id_inserted', $data);
		      $this->set_field('id',$result['obj'][0]['last']);
			}

			// //////////////// //
			// MODIFICAR PERFIL //
			// //////////////// //
			elseif($this->a_meta_fields['change_name']!=0){
		      $data=array('__DESCR__'=>$this->get_field('name'),'__ID_CFG_OP__'=>$this->get_field('id'));
		      $result = doQuery('mod_organizational_profile', $data);
            if($result['rc']!=0){
               $a_res['rc'] = $result['rc'];
               $a_res['rcstr'] = $result['rcstr'];
               return $a_res;
            }
			}
			$this->set_field('change_name',0);

			// /////////////// //
			// ASOCIAR USUARIO //
			// /////////////// //
			if($this->a_meta_fields['user']!=''){
				if(! is_numeric($this->a_meta_fields['user'])){
					$data = array('__LOGIN_NAME__',$this->a_meta_fields['user']);
					$result = doQuery('datos_usuario_enc',$data);
					if($result['cont']==0){
   	            $a_res['rc'] = 1;
	               $a_res['rcstr'] = "USER ".$this->a_meta_fields['user']." DOES NOT EXIST";
	               return $a_res;
	            }
					else{
						$id_user = $result['obj'][0]['id_user'];
						$name_user = $this->a_meta_fields['user'];
					}
				}
				else{
	            $data = array('__ID_USER__'=>$this->a_meta_fields['user']);
	            $result = doQuery('info_cfg_users',$data);
	            if($result['cont']==0){
	               $a_res['rc'] = 1;
	               $a_res['rcstr'] = "USER ".$this->a_meta_fields['user']." DOES NOT EXIST";
	               return $a_res;
					}
					else{
						$id_user = $this->a_meta_fields['user'];
						$name_user = $result['obj'][0]['login_name'];
					}
				}
				

         	// Metemos en cfg_organizational_profile
            $a_user_group = explode(',',$this->get_field('user_group'));
            $a_user_group = array_filter($a_user_group);

            if(($findpos = array_search($id_user, $a_user_group)) !== false) {
               unset($a_user_group[$findpos]);
            }

            $a_user_group[] = $id_user;

            $user_group = (count($a_user_group)>0)?',':'';
            $user_group.= implode(',',$a_user_group);
            $user_group.= (count($a_user_group)>0)?',':'';

            $data = array('__USER_GROUP__'=>$user_group,'__ID_CFG_OP__'=>$this->get_field('id'));
            $result = doQuery('mod_user_add_organizational_profile',$data);


	         // Metemos en cfg_users2organizational_profile
	         $data = array('__ID_USER__'=>$id_user,'__ID_CFG_OP__'=>$this->get_field('id'));
	         $result = doQuery('delete_users2organizational_profile',$data);

            $data = array('__ID_USER__'=>$id_user,'__ID_CFG_OP__'=>$this->get_field('id'),'__LOGIN_NAME__'=>$name_user);
            $result = doQuery('set_users2organizational_profile',$data);
			}

			$this->set_field('user','');

			// /////////////////// //
			// ASOCIAR DISPOSITIVO //
			// /////////////////// //
         if($this->a_meta_fields['device']!=''){

	         if (filter_var($this->a_meta_fields['device'], FILTER_VALIDATE_IP)) {
	            $data = array('__IP__'=>$this->a_meta_fields['device']);
	            $result = doQuery('device_info_basic_by_ip',$data);
	            if($result['cont']==0){
	               $a_res['rc']    = 1;
	               $a_res['rcstr'] = "Device with ip ".$this->a_meta_fields['device']." doesn't exist";
	               return $a_res;
	            }
	            else{
	               $id_dev = $result['obj'][0]['id_dev'];
	            }
				}
				elseif(is_numeric($this->a_meta_fields['device'])){
					$data = array('__ID_DEV__'=>$this->a_meta_fields['device']);
					$result = doQuery('device_info_basic',$data);
					if($result['cont']==0){
						$a_res['rc']    = 1;
	               $a_res['rcstr'] = "Device with id ".$this->a_meta_fields['device']." doesn't exist";
	               return $a_res;
					}
					else{
						$id_dev = $this->a_meta_fields['device'];
					}
				}	
				else{
					$a_res['rc']    = 1;
               $a_res['rcstr'] = "Device ".$this->a_meta_fields['device']." doesn't exist";
               return $a_res;
				}
				$sql = "INSERT IGNORE INTO cfg_devices2organizational_profile (id_dev,id_cfg_op,cid) VALUES ($id_dev,".$this->get_field('id').",'".$this->cid."')";
				$result = $dbc->query($sql);

         }
			$this->set_field('device','');

			$a_res['id'] = $this->get_field('id');
			return $a_res;
      }
	}
?>
