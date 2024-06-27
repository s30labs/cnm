<?php

	class cnmmulti {

   	public static $cid = 'default';
   	public static $timeout = 10;

		/*
		* Function: get()
		* Input:
		* Output:
		* Descr: Devuelve una estructura con los datos LOCALES de la tabla alerts,alert2user,cfg_views,cfg_user2view del CNM 
		*/
		public static function get(){
			$a_res = array(
				'alerts'        => array(),
				'alert2user'    => array(),
				'cfg_views'     => array(),
				'cfg_user2view' => array(),
			);

         $cid_ip   = self::_local_ip();

			// ALERTS
			// SQL => SELECT id_alert,id_metric,id_device,severity,counter,mname,watch,ack,id_ticket,type,date,name,domain,ip,label,cause,event_data,correlated,correlated_by,cid,cid_ip,ticket_descr,mode FROM alerts ORDER BY date ASC LIMIT 0,1000 
         $data   = array();
         $result = doQuery('get_multi_local_alerts',$data);
			$a_res['alerts'] = $result['obj'];

			// ALERT2USER
			// SQL => SELECT id_alert,login_name,cid,cid_ip FROM alert2user WHERE cid='__CID__' AND cid_ip='__CID_IP__' ORDER BY login_name DESC LIMIT 0,1000
			$data   = array('__CID__'=>self::$cid,'__CID_IP__'=>$cid_ip);
         $result = doQuery('get_multi_local_alert2user',$data);
			$a_res['alert2user'] = $result['obj'];

			// CFG_VIEWS
			// SQL => SELECT id_cfg_view,name,type,itil_type,function,weight,background,ruled,severity,red,orange,yellow,blue,cid,cid_ip,global,nmetrics,nremote,nsubviews FROM cfg_views WHERE cid='__CID__' AND cid_ip='__CID_IP__' AND internal=1 ORDER BY name ASC LIMIT 0,1000
         $data   = array('__CID__'=>self::$cid,'__CID_IP__'=>$cid_ip);
         $result = doQuery('get_multi_local_cfg_views',$data);
			$a_res['cfg_views'] = $result['obj'];

			// CFG_USER2VIEW
			// SQL => SELECT id_user,id_cfg_view,cid,login_name,cid_ip FROM cfg_user2view WHERE cid='__CID__' AND cid_ip='__CID_IP__' ORDER BY id_user ASC LIMIT 0,1000
         $data   = array('__CID__'=>self::$cid,'__CID_IP__'=>$cid_ip);
         $result = doQuery('get_multi_local_cfg_user2view',$data);
			$a_res['cfg_user2view'] = $result['obj'];

			
			// DEVICES_CUSTOM_TYPES
			// SQL => SELECT id,descr,tipo FROM devices_custom_types
			$data   = array();
			$result = doQuery('get_multi_local_devices_custom_types',$data);
			$a_res['devices_custom_types'] = $result['obj'];

			// DEVICES_CUSTOM_DATA
			// SQL => SELECT b.* FROM alerts a,devices_custom_data b WHERE a.id_device=b.id_dev GROUP BY b.id_dev
         $data   = array();
         $result = doQuery('get_multi_local_devices_custom_data',$data);
         $a_res['devices_custom_data'] = $result['obj'];

			return $a_res;
		}

      /*
      * Function: put()
      * Input:
      * Output:
      * Descr: Actualiza la BBDD con los datos obtenidos de los CNMs remotos
      */
		public static function put(){
		global $dbc;

         $a_res = array(
            'rc'    => 0,
            'rcstr' => '',
         );

         $cid_ip   = self::_local_ip();

			// Limpiar de cnm_status los CNMs que no estén dados de alta
			$data = array();
			$result = doQuery('clear_cnm_status',$data);

			// Obtener los CNMs remotos
			$data = array();
			$result = doQuery('get_multi_cnm_list',$data);
			$a_remote_cnm = $result['obj'];

//CNMUtils::info_log(__FILE__, __LINE__, "cnmmulti put:: RC={$result['rc']} RCSTR={$result['rcstr']} {$a_res['rcstr']} SQL={$result['query']}");

			// Array que va a contener los campos de usuario globales
			$a_global_devices_custom_data = array();

			// Array que va a contener los nombres de los campos de usuario globales
			$a_global_devices_custom_types = array();

			foreach((array)$a_remote_cnm as $cnm){
				// Los CNMs que se sincronicen por ws se ignoran. Solo se tienen en cuenta los que se sincronicen por api
				if($cnm['mode']!='api') continue;

				// Obtener los datos de dicho CNM
				$a_data_cnm = self::get_data($cnm['host_ip']);

				// Si hay fallo ponerlo en cnm_status
				if($a_data_cnm['rc']!=0){

					// ////////// //
					// CNM_STATUS //
					// ////////// //
					$data = array('__HIDX__'=>$cnm['hidx'],'__CID__'=>$cnm['cid'],'__CID_IP__'=>$cnm['host_ip'],'__TLAST__'=>time(),'__STATUS__'=>'1000');
					$result = doQuery('update_multi_cnm_status_nook',$data);

//CNMUtils::info_log(__FILE__, __LINE__, "cnmmulti put:: **ERROR** ${cnm['host_ip']}");
				}
				// Si ha ido ok ponerlo en cnm_status
				else{

					// ////////// //
					// CNM_STATUS //
					// ////////// //
					$data = array('__HIDX__'=>$cnm['hidx'],'__CID__'=>$cnm['cid'],'__CID_IP__'=>$cnm['host_ip'],'__TLAST__'=>time(),'__STATUS__'=>'0');
					$result = doQuery('update_multi_cnm_status_ok',$data);

//CNMUtils::info_log(__FILE__, __LINE__, "cnmmulti put:: RC={$result['rc']} RCSTR={$result['rcstr']} {$a_res['rcstr']} SQL={$result['query']}");

					// //////////////////////////////////////////////////////////////////////// //
					// DEVICES_CUSTOM_TYPES & DEVICES_CUSTOM_DATA => GLOBAL_DEVICES_CUSTOM_DATA //
					// //////////////////////////////////////////////////////////////////////// //
					if(count($a_data_cnm['data']['devices_custom_types'])>0){
	               foreach($a_data_cnm['data']['devices_custom_types'] as $a){
	                  $md5_name = 'custom_'.substr(md5($a['descr']),0,8);
	
	                  foreach($a_data_cnm['data']['devices_custom_data'] as $b){
								$a_global_devices_custom_data[$cnm['cid']][$cnm['host_ip']][$b['id_dev']][$md5_name]=$b['columna'.$a['id']];
								$a_flobal_devices_custom_types[$md5_name]=array('field_descr'=>$a['descr'],'field_type'=>$a['tipo']);
							}
						}
					}

/*
print_r($a_global_devices_custom_data);
Array
(
    [default] => Array
        (
            [178.33.211.251] => Array
                (
                    [2] => Array
                        (
                            [custom_5255d3da] => 1002
                        )

                    [6] => Array
                        (
                            [custom_5255d3da] => 1001
                        )
                )
        )
)
*/
/*
print_r($a_flobal_devices_custom_types);
Array
(
    [custom_5255d3da] => Array
        (
            [field_descr] => Serial
            [field_type] => 0
        )

)
*/

					if($cnm['cid'] != self::$cid OR $cnm['host_ip'] != $cid_ip){

						// /////////////////////// //
						// ALERTS => ALERTS_REMOTE //
						// /////////////////////// //
						
						// 1. CLEAR 
						// SQL == DELETE FROM alerts_remote WHERE cid='[remote_cid]' AND cid_ip='[remote_cid_ip]'
			         $data   = array('__CID__'=>$cnm['cid'],'__CID_IP__'=>$cnm['host_ip']);
			         $result = doQuery('delete_multi_alerts_remote',$data);

//CNMUtils::info_log(__FILE__, __LINE__, "cnmmulti put:: RC={$result['rc']} RCSTR={$result['rcstr']} {$a_res['rcstr']} SQL={$result['query']}");
			
/*
						// 2. INSERT
						foreach($a_data_cnm['data']['alerts'] as $a){
				         $data   = array(
								'__ID_ALERT__'=>$a['id_alert'],'__ID_METRIC__'=>$a['id_metric'],'__ID_DEVICE__'=>$a['id_device'],'__SEVERITY__'=>$a['severity'],
								'__COUNTER__'=>$a['counter'],'__MNAME__'=>$a['mname'],'__WATCH__'=>$a['watch'],'__ACK__'=>$a['ack'],'__ID_TICKET__'=>$a['id_ticket'],
								'__TYPE__'=>$a['type'],'__DATE__'=>$a['date'],'__NAME__'=>$a['name'],'__DOMAIN__'=>$a['domain'],'__IP__'=>$a['ip'],'__LABEL__'=>$a['label'],
								'__CAUSE__'=>$a['cause'],'__EVENT_DATA__'=>$a['event_data'],'__CORRELATED__'=>$a['correlated'],'__CORRELATED_BY__'=>$a['correlated_by'],
								'__CID__'=>$cnm['cid'],'__CID_IP__'=>$cnm['host_ip'],'__TICKET_DESCR__'=>$a['ticket_descr']);
				         $result = doQuery('insert_multi_local_alerts',$data);
//CNMUtils::info_log(__FILE__, __LINE__, "cnmmulti put:: RC={$result['rc']} RCSTR={$result['rcstr']} {$a_res['rcstr']} SQL={$result['query']}");
						}
*/	
                  // 2. INSERT MULTIPLE
                  $data = array('__VALUES__'=>'');
                  $sep = '';
                  foreach($a_data_cnm['data']['alerts'] as $a){
							foreach($a as $k => $v) $a[$k] = $dbc->escapeSimple($v);
							if ($a['date'] === '') { $a['date']=0; }
                     $data['__VALUES__'].=$sep."('{$a['id_alert']}','{$a['id_metric']}','{$a['id_device']}','{$a['severity']}','{$a['counter']}','{$a['mname']}','{$a['watch']}','{$a['ack']}','{$a['id_ticket']}','{$a['type']}','{$a['date']}','{$a['name']}','{$a['domain']}','{$a['ip']}','{$a['label']}','{$a['cause']}','{$a['event_data']}','{$a['correlated']}','{$a['correlated_by']}','{$cnm['cid']}','{$cnm['host_ip']}','{$a['ticket_descr']}','{$a['mode']}','{$a['critic']}')";
                     $sep=',';
                  }
                  if($data['__VALUES__']!='')$result = doQuery('insert_multi_alerts_remote',$data);
		
//CNMUtils::info_log(__FILE__, __LINE__, "cnmmulti put:: RC={$result['rc']} RCSTR={$result['rcstr']} {$a_res['rcstr']} SQL={$result['query']}");

						// /////////////////////////////// //
						// ALERT2USER => ALERT2USER_REMOTE //
						// /////////////////////////////// //
	
	               // 1. CLEAR
	               // SQL == DELETE FROM alert2user_remote WHERE cid='[remote_cid]' AND cid_ip='[remote_cid_ip]'
	               $data   = array('__CID__'=>$cnm['cid'],'__CID_IP__'=>$cnm['host_ip']);
	               $result = doQuery('delete_multi_alert2user_remote',$data);
	
/*
	               // 2. INSERT
	               foreach($a_data_cnm['data']['alert2user'] as $a){
	                  $data   = array(
								'__ID_ALERT__'=>$a['id_alert'],'__LOGIN_NAME__'=>$a['login_name'],'__CID__'=>$cnm['cid'],'__CID_IP__'=>$cnm['host_ip']
							);
	                  $result = doQuery('insert_multi_alert2user_remote',$data);
	               }
*/
                  // 2. INSERT MULTIPLE
                  $data = array('__VALUES__'=>'');
                  $sep = '';
                  foreach($a_data_cnm['data']['alert2user'] as $a){
							foreach($a as $k => $v) $a[$k] = $dbc->escapeSimple($v);
                     $data['__VALUES__'].=$sep."('{$a['id_alert']}','{$a['login_name']}','{$cnm['cid']}','{$cnm['host_ip']}')";
                     $sep=',';
                  }
                  if($data['__VALUES__']!='')$result = doQuery('insert_multi_alert2user_remote',$data);
	
		
						// ////////////////////// //
						// CFG_VIEWS => CFG_VIEWS //
						// ////////////////////// //
	
	               // 1. CLEAR
	               // SQL == DELETE FROM cfg_views WHERE cid='[remote_cid]' AND cid_ip='[remote_cid_ip]'
	               $data   = array('__CID__'=>$cnm['cid'],'__CID_IP__'=>$cnm['host_ip']);
	               $result = doQuery('delete_multi_cfg_views',$data);
	
/*
	               // 2. INSERT
	               foreach($a_data_cnm['data']['cfg_views'] as $a){
	                  $data   = array(
								'__ID_CFG_VIEW__'=>$a['id_cfg_view'],'__NAME__'=>$a['name'],'__TYPE__'=>$a['type'],'__ITIL_TYPE__'=>$a['itil_type'],
								'__FUNCTION__'=>$a['function'],'__WEIGHT__'=>$a['weight'],'__BACKGROUND__'=>$a['background'],'__RULED__'=>$a['ruled'],
								'__SEVERITY__'=>$a['severity'],'__RED__'=>$a['red'],'__ORANGE__'=>$a['orange'],'__YELLOW__'=>$a['yellow'],'__BLUE__'=>$a['blue'],
								'__CID__'=>$cnm['cid'],'__CID_IP__'=>$cnm['host_ip'],'__GLOBAL__'=>$a['global'],'__NMETRICS__'=>$a['nmetrics'],
								'__NREMOTE__'=>$a['nremote'],'__NSUBVIEWS__'=>$a['nsubviews'],'__INTERNAL__'=>0,
	                  );
	                  $result = doQuery('insert_multi_alert2user_remote',$data);
						}
*/
						// 2. INSERT MULTIPLE
						$data = array('__VALUES__'=>'');
						$sep = '';
						foreach($a_data_cnm['data']['cfg_views'] as $a){
							foreach($a as $k => $v) $a[$k] = $dbc->escapeSimple($v);
							$data['__VALUES__'].=$sep."('{$a['id_cfg_view']}','{$a['name']}','{$a['type']}','{$a['itil_type']}','{$a['function']}','{$a['weight']}','{$a['background']}','{$a['ruled']}','{$a['severity']}','{$a['red']}','{$a['orange']}','{$a['yellow']}','{$a['blue']}','{$cnm['cid']}','{$cnm['host_ip']}','{$a['global']}','{$a['nmetrics']}','{$a['nremote']}','{$a['nsubviews']}','0')";
							$sep=',';
	               }
	               if($data['__VALUES__']!='')$result = doQuery('insert_multi_cfg_views',$data);

				
						// ////////////////////////////// //	
						// CFG_USER2VIEW => CFG_USER2VIEW //
						// ////////////////////////////// //	
	
	               // 1. CLEAR
	               // SQL == DELETE FROM cfg_user2view WHERE cid='[remote_cid]' AND cid_ip='[remote_cid_ip]'
   	            $data   = array('__CID__'=>$cnm['cid'],'__CID_IP__'=>$cnm['host_ip']);
	               $result = doQuery('delete_multi_cfg_user2view',$data);
/*	
	               // 2. INSERT
	               foreach($a_data_cnm['data']['cfg_user2view'] as $a){
	                  $data   = array(
	                     '__ID_USER__'=>$a['id_user'],'__ID_CFG_VIEW__'=>$a['id_cfg_view'],'__LOGIN_NAME__'=>$a['login_name'],
								'__CID__'=>$cnm['cid'],'__CID_IP__'=>$cnm['host_ip']
	                  );
	                  $result = doQuery('insert_multi_cfg_user2view',$data);
	               }
*/
                  // 2. INSERT MULTIPLE
                  $data = array('__VALUES__'=>'');
                  $sep = '';
                  foreach($a_data_cnm['data']['cfg_user2view'] as $a){
							foreach($a as $k => $v) $a[$k] = $dbc->escapeSimple($v);
                     $data['__VALUES__'].=$sep."('{$a['id_user']}','{$a['id_cfg_view']}','{$a['login_name']}','{$cnm['cid']}','{$cnm['host_ip']}')";
                     $sep=',';
                  }
                  if($data['__VALUES__']!='')$result = doQuery('insert_multi_cfg_user2view',$data);

					}	
				}
			}


/*
print_r($a_flobal_devices_custom_types);
Array
(
    [custom_5255d3da] => Array
        (
            [field_descr] => Serial
            [field_type] => 0
        )

)
*/


			// 1. CREAR TABLA TEMPORAL CON LOS NOMBRES DE LOS CAMPOS
			// DROP TABLE mem_global_devices_custom_types;
			$data = array();
			$result = doQuery('drop_mem_global_devices_custom_types',$data);

			// CREATE TABLE mem_global_devices_custom_types (`field_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT '',`field_descr` varchar(255) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT '',`field_type` int(11) DEFAULT NULL, PRIMARY KEY (`field_id`)) ENGINE=MEMORY
			$data = array();
			$result = doQuery('create_mem_global_devices_custom_types',$data);

			$data = array('__VALUES__'=>'');
			$sep = '';
			if (isset($a_flobal_devices_custom_types)) {
				foreach((array)$a_flobal_devices_custom_types as $field_id => $a_field_data){
					$data['__VALUES__'].=$sep."('$field_id','{$a_field_data['field_descr']}',{$a_field_data['field_type']})";
					$sep=',';
				}
			}
			$result = doQuery('insert_mem_global_devices_custom_types',$data);
		


			// 2. CREAR TABLA TEMPORAL PARA ALMACENAR LOS CAMPOS
			// DROP TABLE mem_global_devices_custom_data;
			$data = array();
         $result = doQuery('drop_mem_global_devices_custom_data',$data);

			$data = array('__CONDITION__'=>'');
			if (isset($a_flobal_devices_custom_types)) {
				foreach((array)$a_flobal_devices_custom_types as $field_id => $a_field_data){
					$data['__CONDITION__'].=",`$field_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_spanish_ci NOT NULL DEFAULT '-'";
				}
			}
         $result = doQuery('create_mem_global_devices_custom_data',$data);

/*
print_r($a_global_devices_custom_data);
Array
(
    [default] => Array
        (
            [178.33.211.251] => Array
                (
                    [2] => Array
                        (
                            [custom_5255d3da] => 1002
                        )

                    [6] => Array
                        (
                            [custom_5255d3da] => 1001
                        )
                )
        )
)
*/
			// 3. POBLAR LA TABLA mem_global_devices_custom_data CON DATOS
			$a_field_id = array();
			foreach((array)$a_global_devices_custom_data as $cid => $a_info){
            foreach((array)$a_info as $cid_ip => $a_dev){
               foreach((array)$a_dev as $id_dev => $a_field){
						foreach((array)$a_field as $field_id=>$field_value){
							$a_field_id[]=$field_id;
						}
               }
				}
			}
			$a_field_id = array_unique ($a_field_id);
			$data = array('__FIELDS__'=>'','__VALUES__'=>'');
			foreach((array)$a_field_id as $field_id) $data['__FIELDS__'].=','.$field_id;



         foreach((array)$a_global_devices_custom_data as $cid => $a_info){
            foreach((array)$a_info as $cid_ip => $a_dev){
					foreach((array)$a_dev as $id_dev => $a_field){
						foreach((array)$a_field_id as $field_id){
							if(!array_key_exists($field_id,$a_field))$a_global_devices_custom_data[$cid][$cid_ip][$id_dev][$field_id]='-';
	               }
					}
            }
         }


         $sep = '';
         foreach((array)$a_global_devices_custom_data as $cid => $a_info){
				foreach((array)$a_info as $cid_ip => $a_dev){
					foreach((array)$a_dev as $id_dev => $aux_field){
						$data['__VALUES__'].=$sep."('$cid','$cid_ip',$id_dev";
						foreach((array)$a_field_id as $field_id){
							$field_value = $aux_field[$field_id];
							$data['__VALUES__'].=",'".$dbc->escapeSimple($field_value)."'";
						}
						$data['__VALUES__'].=")";	
	         		$sep = ',';
					}
				}
         }
         if($data['__VALUES__']!='')$result = doQuery('insert_multi_mem_global_devices_custom_data',$data);

			return $a_res;
		}

		private static function get_data($cnm){
			$a_res = array(
				'rc'    => 0,
				'rcstr' => '',
				'data'  => array(),
			);	

			// create a new cURL resource
			$ch = curl_init();

			// set URL and other appropriate options
			curl_setopt($ch, CURLOPT_URL, "https://{$cnm}/onm/api/1.0/multi.json");
			curl_setopt($ch, CURLOPT_HTTPGET, true);
			curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
         curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER,1);
			//curl_setopt($ch, CURLOPT_HEADER, true);
			curl_setopt($ch,CURLOPT_CONNECTTIMEOUT,self::$timeout);
			curl_setopt($ch, CURLOPT_TIMEOUT,self::$timeout); 

			// grab URL and pass it to the browser
			$response=curl_exec($ch);

			// Check for errors and display the error message
			if($errno = curl_errno($ch)) {
				// $error_message = curl_strerror($errno);
				$error_message = curl_error($ch);
				$a_res['rc']    = 1;
				$a_res['rcstr'] = "CURL ERROR ($errno): $error_message";
			}
			else{
				$http_status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
				if($http_status != '200'){
					$a_res['rc']    = 2;
	            $a_res['rcstr'] = "HTTP ERROR ($http_status): ".self::http_codes($http_status);
				}
				else{
					$a_res['data'] = json_decode($response,true);
				}
			}
			// close cURL resource, and free up system resources
			curl_close($ch);

         return $a_res;
		}


		private static function http_codes($code){
			$res = "UNK CODE";

			$a_codes = array(
				// [Informational 1xx]
				100=>"Continue",
				101=>"Switching Protocols",
				
				// [Successful 2xx]
				200=>"OK",
				201=>"Created",
				202=>"Accepted",
				203=>"Non-Authoritative Information",
				204=>"No Content",
				205=>"Reset Content",
				206=>"Partial Content",
				
				// [Redirection 3xx]
				300=>"Multiple Choices",
				301=>"Moved Permanently",
				302=>"Found",
				303=>"See Other",
				304=>"Not Modified",
				305=>"Use Proxy",
				306=>"(Unused)",
				307=>"Temporary Redirect",
				
				// [Client Error 4xx]
				400=>"Bad Request",
				401=>"Unauthorized",
				402=>"Payment Required",
				403=>"Forbidden",
				404=>"Not Found",
				405=>"Method Not Allowed",
				406=>"Not Acceptable",
				407=>"Proxy Authentication Required",
				408=>"Request Timeout",
				409=>"Conflict",
				410=>"Gone",
				411=>"Length Required",
				412=>"Precondition Failed",
				413=>"Request Entity Too Large",
				414=>"Request-URI Too Long",
				415=>"Unsupported Media Type",
				416=>"Requested Range Not Satisfiable",
				417=>"Expectation Failed",
				
				// [Server Error 5xx]
				500=>"Internal Server Error",
				501=>"Not Implemented",
				502=>"Bad Gateway",
				503=>"Service Unavailable",
				504=>"Gateway Timeout",
				505=>"HTTP Version Not Supported",
			);
			if(array_key_exists($code,$a_codes)) $res = $a_codes[$code];

			return $res;
		}

		private static function _local_ip(){
		   $iface = 'eth0';
		   $file = '/cfg/onm.if';
		   if(file_exists($file) and false!=file_get_contents($file)) $iface = chop(file_get_contents($file));
		   $local_ip = chop(`/sbin/ifconfig $iface|/bin/grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | /bin/grep -Eo '([0-9]*\.){3}[0-9]*'`);
		   return $local_ip;
		}

		private static function _info_qactions($descr,$user,$rc,$rcstr){
   		global $dbc;
	      $time=time();

	      $h=md5("$time$user$rc$rcstr");
	      $hh=substr($h,1,8);

	      $sql="INSERT INTO qactions (name,descr,action,atype,cmd,params,auser,date_store,date_start,date_end,rc,status,rcstr)
	         values ('$hh','$descr','info',0,'','','$user',$time,$time,$time,$rc,3,'$rcstr')";
	      // print "SQL ES == $sql";

	      $result = $dbc->query($sql);
	      if (@PEAR::isError($result)) {
	         return 1;
	      }else{
	         return 0;
	      }
		}
	}
?>
