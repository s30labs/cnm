<?php

	class cnmalert {

   	public static $cid = 'default';

		public static function del($id_alert){
         $a_res = array(
            'rc'    => 0,
            'rcstr' => '',
         );

  			$cid_ip   = self::_local_ip();


			// Validar que existe la alerta
         $data   = array('__ID_ALERT__'=>$id_alert,'__CID__'=>self::$cid,'__CID_IP__'=>$cid_ip);
         $result = doQuery('alert_info',$data);
			CNMUtils::debug_log(__FILE__, __LINE__, "SQL={$result['query']}");
			if($result['cont']==0){
            $a_res['rc']      = 1;
            $a_res['rcstr']   = "ALERT WITH ID $id_alert DOESNT EXIST";
         	return $a_res;
			}
         $r2 = $result['obj'][0];
			

		   $data    = array('__ID_ALERT__'=>$id_alert,'__CID__'=>self::$cid,'__CID_IP__'=>$cid_ip);
		   $result  = doQuery('insert_alert_into_alerts_store',$data);
			// No se ha podido mover la alerta al histórico de alertas
		   if ($result['rc']!='0'){
		      $a_res['rc']      = 1;
		      $a_res['rcstr']   = 'ERROR SAVING ALERT INTO ALERT STORE (STEP 1)';
				CNMUtils::info_log(__FILE__, __LINE__, "RC={$result['rc']} RCSTR={$result['rcstr']} {$a_res['rcstr']} SQL={$result['query']}");
         	return $a_res;
		   }
	

			// Se ha movido correctamente la alerta al histórico de alertas
	      // Informamos en auditoria de que se ha borrado la alerta
	      self::_info_qactions('Borrar alerta',$_SESSION['LUSER'],0,"El usuario {$_SESSION['LUSER']} desde la ip {$_SESSION['REMOTE_ADDR']} ha borrado la alerta con los siguientes datos:<br>id=$id_alert<br>label={$r2['label']}<br>ip={$r2['ip']}<br>fecha de la alerta={$r2['date']}");

	      $data   = array('__ID_ALERT__'=>$id_alert,'__CID__'=>self::$cid,'__CID_IP__'=>$cid_ip);
	      $result = doQuery('delete_alert',$data);
	      if ($result['rc']!='0'){
				$a_res['rc']      = 1;
           	$a_res['rcstr']   = 'ERROR DELETING ALERT (STEP 2)';
	      }
			else{
	         $cmd="/usr/bin/sudo /opt/crawler/bin/sync_alerts_clr -c ".self::$cid." -i $cid_ip -a $id_alert 2>&1";
	         exec($cmd,$results);
     		}

         return $a_res;
		}

		private static function _local_ip(){
		   $iface = 'eth0';
		   $file = '/cfg/onm.if';
		   if(file_exists($file) and false!=file_get_contents($file)) $iface = chop(file_get_contents($file));
		   $local_ip = chop(`/sbin/ifconfig $iface|grep 'inet addr'|cut -d ":" -f2|cut -d " " -f1`);
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
