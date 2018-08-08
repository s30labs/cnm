<?php

	class cnmalert_store {

   	public static $cid = 'default';

		public static function del($id_alert){
         $a_res = array(
            'rc'    => 0,
            'rcstr' => '',
         );

  			$cid_ip   = self::_local_ip();

			// Validar que existe la alerta
         $data   = array('__ID_ALERT__'=>$id_alert,'__CID__'=>self::$cid,'__CID_IP__'=>$cid_ip);
         $result = doQuery('halert_info',$data);
			if($result['cont']==0){
            $a_res['rc']      = 1;
            $a_res['rcstr']   = "ALERT WITH ID $id_alert DOESNT EXIST";
         	return $a_res;
			}
         $r2 = $result['obj'][0];

		   $a_sev_string = array(
		      '1'=>i18('_roja'),
		      '2'=>i18('_naranja'),
		      '3'=>i18('_amarilla'),
		      '4'=>i18('_azul'),
		      '5'=>i18('_gris'),
		      '6'=>i18('_verde')
		   );
			
	      // Informamos en auditoria que se ha borrado la alerta
	      self::_info_qactions('Borrar historico',$_SESSION['LUSER'],0,"El usuario {$_SESSION['LUSER']} desde la ip {$_SESSION['REMOTE_ADDR']} ha borrado la alerta con los siguientes datos:<br>id=$id_alert<br>dispositivo=$device_name.$device_domain ($ip)<br>fecha de la alerta=$date<br>duración=".time2hms($duration)."<br>causa=$label<br>evento=$event_data<br>severidad=".$a_sev_string[$severity]);

	      $data   = array('__ID_ALERT__'=>$id_alert,'__CID__'=>self::$cid,'__CID_IP__'=>$cid_ip);
	      $result = doQuery('delete_halert',$data);
	      if ($result['rc']!='0'){
				$a_res['rc']      = 1;
           	$a_res['rcstr']   = 'ERROR DELETING ALERT (STEP 1)';
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
		   if ($dbc->errno != 0) {
  			   $err_str = '('.$dbc->errno.'): '.$dbc->sqlstate.' - '.$dbc->error;
				CNMUtils::error_log(__FILE__, __LINE__, "_info_qactions: $err_str ($sql)");
	         return 1;
	      }else{
	         return 0;
	      }
		}
	}
?>
