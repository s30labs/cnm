<?php
	class remoteAlert{
		public $id_remote_alert=-1;
		private $rc=array();
		private $item=array(
			'descr'       => "Nueva alerta remota",
			'type'        => "syslog",
			'mode'        => 'INC',
			'action'      => 'SET',
			'sev'         => 3,
			'logfile'     => '',
			'clear_id'    => '',
			'class'       => 'CUSTOM',		
			'apptype'     => '',
			//'fx'          => '',
			//'expr'        => '',
			'total_expr'  => array(),
			'id_dev'      => '',
			'subtype'     => '',
			'hiid'        => '',
         'set_type'    => '',
         'set_subtype' => '',
         'set_hiid'    => 'ea1c3c284d',
         'set_id'      => 0,
			'origin_id'   => 0,
		);

	   function __construct($id_remote_alert=-1){
			if($id_remote_alert!=-1){
				$this->id_remote_alert = $id_remote_alert;
				$data = array('__ID_REMOTE_ALERT__'=>$this->id_remote_alert);
				$result = doQuery('cnm_cfg_remote_info_by_id',$data);
				$r = $result['obj'][0];
				$a_set_item = array(
					'descr'       => $r['descr'],
					'type'        => $r['type'],
					'mode'        => $r['mode'],
					'action'      => $r['action'],
					'sev'         => $r['severity'],
					'logfile'     => $r['logfile'],
         		// 'total_expr'  => $r['total_expr'],
         		'clear_id'    => $r['clear_id'],
         		'class'       => $r['class'],
         		'apptype'     => $r['apptype'],
         		// 'fx'          => $r['fx'],
         		// 'expr'        => $r['expr'],
         		// 'id_dev'      => $r['id_dev'],
         		'subtype'     => $r['subtype'],
         		'hiid'        => $r['hiid'],
		         'set_type'    => $r['set_type'],
		         'set_subtype' => $r['set_subtype'],
		         'set_hiid'    => $r['set_hiid'],
		         'set_id'      => $r['set_id'],
				);
				$this->item($a_set_item);
			}
	   }

		public function del(){
			$this->rc['method'] = __METHOD__;

			if($this->id_remote_alert==-1){
				$this->rc['step']   = 0;
				$this->rc['rc']     = 1;
				$this->rc['rcstr']  = 'ERR:id_remote_alert == -1';
				return;
			}

   		$data = array(':__ID_REMOTE_ALERT__'=>$this->id_remote_alert);
   		$result = doQuery('cnm_cfg_remote_delete1',$data);
			if($result['rc']!=0){
				$this->rc['step']       = 1;
            $this->rc['rc']         = 1;
            $this->rc['rcstr']      = 'Ha habido algun problema al borrar la alerta remota.';
            $this->rc['rcquery']    = $result['rc'];
            $this->rc['rcstrquery'] = $result['rcstr'];
            $this->rc['sqlquery']   = $result['query'];
            return;
			}

      	$data = array(':__ID_REMOTE_ALERT__'=>$this->id_remote_alert);
      	$result = doQuery('cnm_cfg_remote_delete2',$data);
			if($result['rc']!=0){
            $this->rc['step']       = 2;
            $this->rc['rc']         = 1;
            $this->rc['rcstr']      = 'Ha habido algun problema al borrar la alerta remota.';
            $this->rc['rcquery']    = $result['rc'];
            $this->rc['rcstrquery'] = $result['rcstr'];
            $this->rc['sqlquery']   = $result['query'];
            return;
         }

			// Hay que eliminar documentación
			// Hay que eliminar asociaciones de alerta remota -> dispositivo
			// Hay que eliminar las expresiones de dicha alerta remota

         $this->rc['rc']     = 0;
         $this->rc['rcstr']  = 'Se ha borrado la alerta remota correctamente.';
      }

		public function save(){
			$this->rc['method'] = __METHOD__;

			$mode = ''; // update|create

			////////////
			// UPDATE //
			////////////
			if($this->id_remote_alert>0){
				$mode = 'update';
			}
			////////////
			// CREATE //
			////////////
			else{
				$mode = 'create';

				// Se calcula el subtype
				if($this->item('type')=='syslog'){
					$this->item('subtype','log_'.substr(md5(uniqid(rand(),true)),0,8));
				}
				elseif($this->item('type')=='snmp' or $this->item('type')=='api'){
					// Subtype ya se ha puesto el usuario en la interfaz. Es un oid
				}
				elseif($this->item('type')=='email'){
					$this->item('subtype','mail_'.substr(md5(uniqid(rand(),true)),0,8));
				}
			}
			
			// Se recalcula el hiid
			$expr_str = '';
			$a_total_expr = $this->item('total_expr');
			foreach($a_total_expr as $ex) $expr_str.=$ex['id'].$ex['fx'].$ex['expr'];
   		$this->item('hiid',substr(md5($expr_str),0,10));


			if ($this->item('action')=='CLR') {
				$this->item('sev','0');

		      $cdata = array('__ID_REMOTE_ALERT__'=>$this->item('clear_id'));
		      $result=doQuery('cnm_cfg_remote_get_clr_data_id',$cdata);

		      if ($result['rc']==0){
					$this->item(array(
						'set_type'    => $result['obj'][0]['type'],
						'set_subtype' => $result['obj'][0]['subtype'],
						'set_hiid'    => $result['obj'][0]['hiid'],
						'set_id'      => $this->item('clear_id'),
					));
		      }
				else{
            	$this->rc['step']       = 0;
	            $this->rc['rc']         = 1;
	            $this->rc['rcstr']      = 'Ha habido algun problema al obtener datos de la alerta remota que se borra.';
	            $this->rc['rcquery']    = $result['rc'];
	            $this->rc['rcstrquery'] = $result['rcstr'];
	            $this->rc['sqlquery']   = $result['query'];
	            return;
				}
		   }

			$data =  array(
				'__ID_REMOTE_ALERT__' => $this->id_remote_alert,
				'__TYPE__'            => $this->item('type'),
				'__SUBTYPE__'         => $this->item('subtype'),
				'__DESCR__'           => $this->item('descr'),
				'__MODE__'            => $this->item('mode'),
				'__ACTION__'          => $this->item('action'),
				'__EXPR__'            => 'AND',
				'__HIID__'            => $this->item('hiid'),
				'__CLASS__'           => $this->item('class'),
				'__APPTYPE__'         => $this->item('apptype'),
				'__SET_TYPE__'        => $this->item('set_type'), 
				'__SET_SUBTYPE__'     => $this->item('set_subtype'),
				'__SET_HIID__'        => $this->item('set_hiid'),
				'__SET_ID__'          => $this->item('set_id'),
				'__VDATA__'           => '',
				'__LOGFILE__'         => $this->item('logfile'),
				'__SEVERITY__'        => $this->item('sev'),
			);

			////////////
			// UPDATE //	
			////////////
			if($mode=='update'){
				// Aunque ponga syslog es válido para las de tipo snmp y email. Es por tema de nombres ya usados
		      // $result=doQuery('cnm_cfg_remote_store_update_syslog',$data);
		      $result=doQuery('cnm_cfg_remote_store_update',$data);
      		if ($result['rc']!=0){
               $this->rc['step']       = 1;
               $this->rc['rc']         = 1;
               $this->rc['rcstr']      = 'Ha habido algun problema al actualizar la alerta remota.';
               $this->rc['rcquery']    = $result['rc'];
               $this->rc['rcstrquery'] = $result['rcstr'];
               $this->rc['sqlquery']   = $result['query'];
               return;
      		}
			}

			////////////
			// CREATE //
			////////////
			else{
      		// $result=doQuery('cnm_cfg_remote_store_create_syslog',$data);
      		$result=doQuery('cnm_cfg_remote_store_create',$data);
     			 if ($result['rc']!=0){
               $this->rc['step']       = 2;
               $this->rc['rc']         = 1;
               $this->rc['rcstr']      = 'Ha habido algun problema al crear la alerta remota.';
               $this->rc['rcquery']    = $result['rc'];
               $this->rc['rcstrquery'] = $result['rcstr'];
               $this->rc['sqlquery']   = $result['query'];
               return;
      		}

	         $data = array();
   	      // Se obtiene el ultimo id
	         $result = doQuery('last_id_inserted', $data);
				$this->id_remote_alert = $result['obj'][0]['last'];


				// Hay que asociarlo a los mismos dispositivos que la alerta remota inicial
				if($this->item('origin_id')!='' AND $this->item('origin_id')!=0){
					$data = array('__ORIGIN_ID__'=>$this->item('origin_id'),'__ID_REMOTE_ALERT__'=>$this->id_remote_alert);
					$result = doQuery('cnm_asoc_devices_remote_new',$data);
				}
			}

         $result=doQuery('cnm_cfg_remote_expr_remove',$data);
			foreach($a_total_expr as $ex){
				$expr_str.=$ex['id'].$ex['fx'].$ex['expr'];
	         $data_expr = array('__V__'=>$ex['id'], '__DESCR__'=>$ex['descr'], '__FX__'=>$ex['fx'], '__EXPR__'=>$ex['expr'], '__ID_REMOTE_ALERT__'=>$this->id_remote_alert);
	         $result=doQuery('cnm_cfg_remote_expr_store',$data_expr);
	         if ($result['rc']!=0){
	            $this->rc['step']       = 3;
   	         $this->rc['rc']         = 1;
	            $this->rc['rcstr']      = 'Ha habido algun problema al actualizar la alerta remota.';
	            $this->rc['rcquery']    = $result['rc'];
	            $this->rc['rcstrquery'] = $result['rcstr'];
	            $this->rc['sqlquery']   = $result['query'];
	            return;
	         }
			}

         // ------------------------------------------------------
         // Genero documentacion
         // ------------------------------------------------------
			$tip = '';
			if($this->item('type')=='syslog'){
				if($a_total_expr[0]['fx']=='MATCH'){
					$tip.= 'Alerta generada por mensaje de <strong>syslog</strong> al coincidir con la cadena "'.$a_total_expr[0]['expr'].'"';
				}else{
					$tip.= 'Alerta generada por mensaje de <strong>syslog</strong> al no coincidir con la cadena "'.$a_total_expr[0]['expr'].'"';
				}
			}
         elseif($this->item('type')=='api'){
            if($a_total_expr[0]['fx']=='MATCH'){
               $tip.= 'Alerta generada por mensaje de <strong>api</strong> al coincidir con la cadena "'.$a_total_expr[0]['expr'].'"';
            }else{
               $tip.= 'Alerta generada por mensaje de <strong>api</strong> al no coincidir con la cadena "'.$a_total_expr[0]['expr'].'"';
            }
         }
			elseif($this->item('type')=='snmp'){
		     //UCD-SNMP-MIB::ucdExperimental.990:6..17
		      $oid=$subtype;
		      if (preg_match("/(\S+)\:6\.\.*/",$this->item('subtype'),$match)) $oid=$match[1];
		      $cmd="export MIBS='ALL'; /usr/local/bin/snmptranslate -Td $oid";
		      exec($cmd,$cmd_out);
		      // CNMUtils::debug_log(__FILE__, __LINE__, "guardar_alerta: CMD=$cmd");
		      // CNMUtils::debug_log(__FILE__, __LINE__, "guardar_alerta: OUT=$cmd_out[1]");
		      list($oid_translate,$mib,$type1,$desc,$range,$enterprise) = SNMPUtils::parse_mib_info($cmd_out);

		      $class=$enterprise;

		      $tip.="Alerta generada por <strong>trap SNMP</strong>";
		      if ($mib)  $tip.=" definido en la mib <strong>$oid_translate</strong>";
		      if ($desc) $tip.=" de la siguiente forma:<br>$desc";
			}
			elseif($this->item('type')=='email'){
				$flag = 0;
				foreach($a_total_expr as $ex){
					// Asunto del correo
					if($ex['id']=='v1'){
						if($ex['fx']=='MATCH' AND $flag==0){
							$tip.="Alerta generada por un <strong>email</strong> al coincidir el titulo con la cadena \"{$ex['expr']}\"";
						}
						elseif($ex['fx']=='MATCH' AND $flag==1){
                     $tip.=" y al coincidir el titulo con la cadena \"{$ex['expr']}\"";
                  }
						elseif($ex['fx']=='NOMATCH' AND $flag==0){
                     $tip.="Alerta generada por un <strong>email</strong> al no coincidir el titulo con la cadena \"{$ex['expr']}\"";
                  }
						else{
							$tip.=" y al no coincidir el titulo con la cadena \"{$ex['expr']}\"";
						}
						$flag = 1;
					}
					// Cuerpo del correo
					elseif($ex['id']=='v2'){
						if($ex['fx']=='MATCH' AND $flag==0){
                     $tip.="Alerta generada por un <strong>email</strong> al coincidir el cuerpo con la cadena \"{$ex['expr']}\"";
                  }
						elseif($ex['fx']=='MATCH' AND $flag==1){
                     $tip.=" y al coincidir el cuerpo con la cadena \"{$ex['expr']}\"";
                  }
						elseif($ex['fx']=='NOMATCH' AND $flag==0){
                     $tip.="Alerta generada por un <strong>email</strong> al no coincidir el cuerpo con la cadena \"{$ex['expr']}\"";
                  }
						else{
                     $tip.=" y al no coincidir el cuerpo con la cadena \"{$ex['expr']}\"";
                  }
						$flag = 1;
					}

				}
			}

         $data_tip=array(
            '__ID_REF__'    => $this->item('subtype'),
            '__TIP_TYPE__'  => 'remote', 
            '__NAME__'      => 'CNM-Info',
            '__TIP_CLASS__' => '1', 
            '__DESCR__'     => $tip,
            '__DATE__'      => time(),
            '__ID_REFN__'   => $this->id_remote_alert,
				'__HIID__'      => $this->item('hiid'),
         );

			if($mode=='update'){
				$has_docu = 0; // 0: no tiene documentacion || 1: si tiene documentacion
				$data_check_docu = array('__ID_REFN__'=>$this->id_remote_alert,'__TIP_TYPE__'=>'remote');
				$result_check_docu = doQuery('cnm_cfg_tips_get_ro_info_by_typeidrefn',$data_check_docu);
				if($result_check_docu['cont']>0) $has_docu=1;
				
				// En caso de tener una documentación previa y ser un trap-snmp no se modifica
				if($has_docu==0 OR $this->item('type')!='snmp'){
					$result = doQuery('cnm_cfg_tips_store_update_idrefn',$data_tip);
				}else{
					$tip = $result_check_docu['obj'][0]['descr'];
				}
			}
			// $mode=='create'
			else{
				// Estamos creando a partir de una alerta remota que tiene documentación y no hemos cambiado el subtype, por lo que directamente la copiamos
				if($this->item('origin_id')!=0){
					$dataAUX=array('__ID_REMOTE_ALERT__'=>$this->item('origin_id'));
	            $resultAUX=doQuery('cnm_cfg_remote_get_alert_info_by_id',$dataAUX);
   	         $rAUX = $resultAUX['obj'][0];

					$data_check_docu = array('__ID_REFN__'=>$this->item('origin_id'),'__TIP_TYPE__'=>'remote');
   	         $result_check_docu = doQuery('cnm_cfg_tips_get_ro_info_by_typeidrefn',$data_check_docu);
	            if($result_check_docu['cont']>0) $has_docu=1;

	            // En caso de que el padre tenga documentación previa, sea un trap snmp y coincida el subtype se le pone la misma documentacion
	            // if($has_docu==1 AND $this->item('type')=='snmp' AND $rAUX['subtype']==$this->item('subtype')){
	            if($has_docu==1 AND $this->item('type')=='snmp'){
	               $data_tip['__DESCR__'] = $result_check_docu['obj'][0]['descr'];
						$tip = $result_check_docu['obj'][0]['descr'];;
	            }
				}
				$result = doQuery('cnm_cfg_tips_store_create_idrefn',$data_tip);
			}

		   // ------------------------------------------------------
		   // Asocio a dispositivo
		   // ------------------------------------------------------
		   // Para cada id_dev asociado habria que localizar todas sus posibles ips y asociarlas
		   // en el campo target. En una primera aproximacion utilizamos solo la ip principal
			if($this->item('id_dev')!=''){
			   $data = array('__ID_DEV__' => $this->item('id_dev'));
			   $result = doQuery('cnm_cfg_devices_get_ip_list',$data);
			   $ip = $result['obj'][0]['ip'];

			   $data = array('__ID_REMOTE_ALERT__' => $this->id_remote_alert, '__TARGET__' => $ip);
			   $result = doQuery('cnm_cfg_remote_include_device',$data);
			}

	      // ES NECESARIO CREAR EL FICHERO PARA QUE CNM SEPA INTERNAMENTE QUE HAY CAMBIOS Y DEBE BUSCARLOS
	      reload_trap_manager();

		   $this->rc['rc']  = 0;
			$this->rc['idp'] = $this->id_remote_alert;
			$this->rc['tip'] = $tip;
			
			if($this->id_remote_alert>0){
            $this->rc['rcstr'] = 'Se ha modificado correctamente la alerta remota.';
			}else{
            $this->rc['rcstr'] = 'Se ha creado correctamente la alerta remota.';
			}
		}

		public function get_rc(){
			return $this->rc;
		}

		public function print_rc(){
			print "METHOD == {$this->rc['method']} || RC == {$$this->rc['rc']} RCSTR == {$$this->rc['rcstr']}";
		}
	
		public function item($key,$val=null){
			if($val==null and $this->is_hash($key)){
				foreach($key as $k=>$v)	$this->item[$k]=$v;
			}
			elseif($val==null and is_array($key)){
				$ret = array();
            foreach($key as $k) $ret[$k]=$this->item[$k];
				return $ret;
         }
			elseif($val==null){
				return $this->item[$key];
			}else{
				$this->item[$key]=$val;
			}
		}

		private function is_hash($elem){
			return is_array($elem) AND array_values($elem) !== $elem;
		}
	}
?>
