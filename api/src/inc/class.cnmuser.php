<?php


	class cnmuser {
		public $cid = 'default';

		// Campos que deben existir, sino hay un error
      private $a_must_fields = array('login','firstname','lastname','email');

		private $a_meta_fields = array(
			'change_passwd' => 0,
		);

		// ///////////////// //
		// Campos de sistema //
		// ///////////////// //
		private $a_system_fields = array(
			'id'        => '',
			'login'     => '',
			'passwd'    => '',
			'token'     => '',
			'descr'     => '',
			'profile'   => '',
			'timeout'   => 1440,
			'params'    => '',
			'firstname' => '',
			'lastname'  => '',
			'email'     => '',
			'otrstype'  => 0,
			'language'  => 'es_ES',
			'role'      => '',
		);


		// //////////////////////////////////////////////////////////////////////
		// Funcion constructor
		// Input:
		//    id_user o vacio => En caso de introducir un id_user, se utilizara para modificar u obtener datos de dicho usuario. En caso de no
		//                       introducir id_user será para crear un usuario
		// Output:
		//    $a_res['rc']    = 0:OK | otros valores error
		//    $a_res['rcstr'] = '' | descripcion del error
		// Descr:
		// //////////////////////////////////////////////////////////////////////
		public function __construct($id_user=0){
			global $dbc;

			$a_res = array(
				'rc'    => 0,
				'rcstr' => '',
			);

			if(!is_numeric($id_user) or $id_user<0){
				$a_res['rc']    = 1;
            $a_res['rcstr'] = "ID $id_user is not correct (must be int or empty)";
				return $a_res;
			}

			$this->set_field('id',$id_user);	
			if($this->get_field('id')==0){
			}
			else{
				// Obtener los campos del usuario
				$data = array('__ID_USER__'=>$this->get_field('id'));
				$result = doQuery('info_cfg_users',$data);
				if($result['cont']==0){
					$a_res['rc']    = 1;	
					$a_res['rcstr'] = "User ".$this->get_field('id')." doesn't exist";	
					return $a_res;
				}
				else{
					$r = $result['obj'][0];
					$a_aux = array(
			         'login'     => $r['login_name'],
			         'token'     => $r['token'],
			         'descr'     => $r['descr'],
			         'timeout'   => $r['timeout'],
			         'params'    => $r['descr'],
			         'firstname' => $r['firstname'],
			         'lastname'  => $r['lastname'],
			         'email'     => $r['email'],
			         'otrstype'  => $r['otrs_type'],
			         'language'  => $r['language'],
					);
					$this->set_fields($a_aux);

					// /// //
					// Rol //
					// /// //
					$a_roles = array();
					$data = array();
					$result2 = doQuery('get_operational_profile',$data);
					foreach($result2['obj'] as $r2) $a_roles[$r2['id_operational_profile']] = $r2['name'];
					$this->set_field('role',$a_roles[$r['perfil']]);


					// //////// //
					// Perfiles //
					// //////// //
					$data_p = array('__ID_USER__'=>$this->get_field('id'));
					$result_p = doQuery('profiles_cfg_user',$data_p);
					$profile = '';
					$comma = '';
					foreach($result_p['obj'] as $r_p){
						$profile.= $comma.$r_p['descr'];
						$comma = ',';	
					}
					$this->set_field('profile',$profile);
				}
			}
			return $a_res;
		}
		
		public function set_field($key,$value){
			$rc = 0;

			if(array_key_exists($key,$this->a_system_fields)){
				$this->a_system_fields[$key] = $value;

				if($key == 'token') {
               $this->a_meta_fields['change_passwd'] = 1;
				}
				elseif($key == 'passwd'){
					$this->generateToken();
					$this->a_meta_fields['change_passwd'] = 1;	
				}
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
			$a_res = array('rc'=>0,'rcstr'=>'','id'=>'');

	      // //////////// //
	      // VALIDACIONES //
	      // //////////// //
			
			// /////// //
			// TIMEOUT //
			// /////// //
			if(!is_numeric($this->get_field('timeout')) or $this->get_field('timeout')<0){
				$a_res['rc']    = 1;
            $a_res['rcstr'] = "FIELD timeout MUST BE AN INTEGER";
            return $a_res;
			}
			if($this->get_field('timeout')<300){
				$this->set_field('timeout',300);
			}
			
			// /// //
			// ROL //
			// /// //
			if($this->get_field('role')==''){
				$a_res['rc']    = 1;
            $a_res['rcstr'] = "FIELD role IS NECESSARY";
            return $a_res;	
			}
			else{
            $a_roles = array();
            $data = array();
            $result2 = doQuery('get_operational_profile',$data);
            foreach($result2['obj'] as $r2) $a_roles[$r2['name']] = $r2['id_operational_profile'];
				if(!array_key_exists($this->get_field('role'),$a_roles)){
	            $a_res['rc']    = 1;
	            $a_res['rcstr'] = "FIELD role ".$this->get_field('role')." IS NOT A VALID VALUE";
	            return $a_res;
				}
				else{
					$role = $a_roles[$this->get_field('role')];
				}
			}

			// ///// //
			// LOGIN //
			// ///// //
         if($this->get_field('login')==''){
            $a_res['rc']    = 1;
            $a_res['rcstr'] = "FIELD login IS NECESSARY";
            return $a_res;
         }

			// ///// //
			// DESCR //
			// ///// //
         if($this->get_field('descr')==''){
            $a_res['rc']    = 1;
            $a_res['rcstr'] = "FIELD descr IS NECESSARY";
            return $a_res;
         }

			// ///////// //
			// FIRSTNAME //
			// ///////// //
         if($this->get_field('firstname')==''){
            $a_res['rc']    = 1;
            $a_res['rcstr'] = "FIELD firstname IS NECESSARY";
            return $a_res;
         }

			// //////// //
			// LASTNAME //
			// //////// //
         if($this->get_field('lastname')==''){
            $a_res['rc']    = 1;
            $a_res['rcstr'] = "FIELD lastname IS NECESSARY";
            return $a_res;
         }

			// ///// //
			// EMAIL //
			// ///// //
         if($this->get_field('email')==''){
            $a_res['rc']    = 1;
            $a_res['rcstr'] = "FIELD email IS NECESSARY";
            return $a_res;
         }
			if(!filter_var($this->get_field('email'), FILTER_VALIDATE_EMAIL)) {
            $a_res['rc']    = 1;
            $a_res['rcstr'] = "FIELD email (".$this->get_field('email').") IS NOT A VALID EMAIL";
            return $a_res;
			}
			

			// ////// //
			// PASSWD //
			// ////// //
			if($this->get_field('login')=='admin' AND $this->a_meta_fields['change_passwd']==1){
				$a_res['rc']    = 1;
            $a_res['rcstr'] = "admin USER PASSWORD MUST BE SET USING password FIELD NOT TOKEN FIELD";
            return $a_res;
			}
			
			if($this->get_field('id')==1 AND ($this->get_field('passwd')=='' OR $this->get_field('token')=='')){

			}



/*	
         'id'        => '',
         'login'     => '',
         'passwd'    => '',
         'token'     => '',
         'descr'     => '',
         'profile'   => '',
         'timeout'   => 1440,
         'params'    => '',
         'firstname' => '',
         'lastname'  => '',
         'email'     => '',
         'otrstype'  => 0,
         'language'  => 'es_ES',
         'role'      => '',
         'profile'   => '',
*/





			$data = array(
				'__ID_USER__'    => $this->get_field('id'),
				'__LOGIN_NAME__' => $this->get_field('login'),
				'__PASSWD__'     => $this->get_field('token'),
				'__DESCR__'      => $this->get_field('descr'),
				'__PERFIL__'     => $role,
				'__TIMEOUT__'    => $this->get_field('timeout'),
				'__FIRSTNAME__'  => $this->get_field('firstname'),
				'__LASTNAME__'   => $this->get_field('lastname'),
				'__EMAIL__'      => $this->get_field('email'),
				'__OTRS_TYPE__'  => 1,
			);

			// ///////////// //
			// CREAR USUARIO //
			// ///////////// //
			if($this->get_field('id')==0){
	      	$result = doQuery('create_user_enc',$data);
		      if ($result['rc']!=0) {
		         $a_res['rc']    = 1;
		         $a_res['rcstr'] = "ERROR CREATING USER (STEP 1):{$result['rcstr']}";
		         return $a_res;
		      }

				// ////////////////// //
				// OBTENER EL ID_USER //
				// ////////////////// //
      	   $result = doQuery('last_id_inserted', $data);
				$this->set_field('id',$result['obj'][0]['last']);

			}

			// ///////////////// //
			// MODIFICAR USUARIO //
			// ///////////////// //
			else{
				if($this->a_meta_fields['change_passwd'] == 1){
		         if($this->get_field('login')=='admin'){
		            $datac = array('__PWD__'=>$this->get_field('passwd'),'__USER__'=>$this->get_field('login'));
		            $result_c = doQuery('mod_api_pass_credential',$datac);
		         }
		         $result   = doQuery('mod_user_enc', $data);

				}
				else{
					$result = doQuery('mod_user_enc_no_pass', $data);
				}
			}

         $this->a_meta_fields['change_passwd'] = 0;


			// //////////////// //
			// ASOCIAR A PERFIL //
			// //////////////// //
         $a_defined_profiles = array();
         $data = array();
/*
mysql> SELECT * FROM cfg_organizational_profile;
+-----------+--------------+------------+
| id_cfg_op | descr        | user_group |
+-----------+--------------+------------+
|         1 | Global       | ,1,        |
|         2 | s30labs      | ,2,        |
|         3 | avance       | ,3,        |
|         4 | yosoynuclear | ,4,        |
|         5 | amazon       | ,5,        |
+-----------+--------------+------------+
*/
         $result2 = doQuery('get_organizational_profile',$data);
         foreach($result2['obj'] as $r2){
				$a_defined_profiles[$r2['descr']] = array('id_cfg_op'=>$r2['id_cfg_op'],'user_group'=>$r2['user_group']);
			}

         // Metemos las entradas
         $a_profiles = explode(',',$this->get_field('profile'));

			// Metemos y limpiamos todas las entradas en cfg_organizational_profile
			foreach($a_defined_profiles as $kk=>$a_info){
				$a_user_group = explode(',',$a_info['user_group']);
				$a_user_group = array_filter($a_user_group);

				if(($findpos = array_search($this->get_field('id'), $a_user_group)) !== false) {
    				unset($a_user_group[$findpos]);
				}
//				$a_user_group = array_diff( $a_user_group, $this->get_field('id'));

				if(in_array($kk,$a_profiles)) $a_user_group[] = $this->get_field('id');
				
				$user_group = (count($a_user_group)>0)?',':'';
				$user_group.= implode(',',$a_user_group);	
				$user_group.= (count($a_user_group)>0)?',':'';

				$data = array('__USER_GROUP__'=>$user_group,'__ID_CFG_OP__'=>$a_info['id_cfg_op']);
				$result = doQuery('mod_user_add_organizational_profile',$data);
			}


			// Limpiamos y metemos las entradas en cfg_users2organizational_profile
			foreach($a_defined_profiles as $kk=>$a_info){
				$data = array('__ID_USER__'=>$this->get_field('id'),'__ID_CFG_OP__'=>$a_info['id_cfg_op']);
            $result = doQuery('delete_users2organizational_profile',$data);
			}
			foreach($a_profiles as $profile){
				$id_cfg_op = $a_defined_profiles[$profile]['id_cfg_op'];
				$data = array('__ID_USER__'=>$this->get_field('id'),'__ID_CFG_OP__'=>$id_cfg_op,'__LOGIN_NAME__'=>$this->get_field('login'));
				$result = doQuery('set_users2organizational_profile',$data);
			}


			$a_res['id'] = $this->get_field('id');
			return $a_res;
      }


		private function generateToken(){
		   $salt_length=32;
		   $salt = substr(md5(uniqid(rand(), true)), 0, $salt_length);
			$this->set_field('token',$salt . sha1($salt . $this->get_field('passwd')));
		}
	}
?>
