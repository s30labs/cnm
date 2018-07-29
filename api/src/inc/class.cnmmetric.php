<?php

	class cnmmetric {

   	public static $cid = 'default';
		
		public static function del($IDM,$do_workset=1){

			global $dbc;
         $a_res = array(
            'rc'    => 0,
            'rcstr' => '',
         );

		   if (! $IDM) {
    	  		$a_res['rc']=1;
      		$a_res['msg']='No se ha borrado ninguna metrica (sin ID)';
      		return $a_res;
   		}

   		CNMUtils::info_log(__FILE__, __LINE__, "api_delete_metrics (delete_metrics): ID=$IDM");

  			$cid_ip   = self::_local_ip();

   		//Elimina la metrica (o metricas separadas por comas)
			//Actualiza su estado a 3 para que sea eliminada por notificationsd
  			$sql="Update metrics set status=3, refresh=1 where id_metric in ($IDM)";
   		$result = $dbc->query($sql);
   		if (@PEAR::isError($result)){
      		$a_res['msg']=$result->getMessage();
      		$a_res['rc']=$result->getCode();
      		CNMUtils::error_log(__FILE__, __LINE__, "api_delete_metrics: error={$a_res['msg']} rc={$a_res['rc']} ($sql)");
   		}


		   //Elimina las relaciones con las vistas de la metrica en cuestion
   		$sql="delete from cfg_views2metrics where id_metric in ($IDM)";
   		$result = $dbc->query($sql);
   		if (@PEAR::isError($result)) {
      		$a_res['msg']=$result->getMessage();
      		$a_res['rc']=$result->getCode();
      		CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$a_res['msg']} rc={$a_res['rc']} ($sql)");
   		}


			// REVISAR !!!!!!
		   // Se buscan las vistas en las que están dichas métricas y se actualiza el campo nmetrics
/*		   $sql="SELECT DISTINCT(id_cfg_view) AS id_cfg_view FROM cfg_views2metrics WHERE id_metric IN ($IDM)";
   		$result = $dbc->query($sql);
   		while ($result->fetchInto($r)) view_update_nmetrics($r['id_cfg_view'],$cid);
*/

   		//Elimina de otras tablas .......
   		$sql="select m.id_dev,m.name,m.type,m.subtype,d.ip,m.file,m.id_metric,m.label,d.name as dev_name,d.domain from metrics m, devices d where m.id_dev=d.id_dev and id_metric in ($IDM)";
   		$result1 = $dbc->query($sql);
   		if (@PEAR::isError($result1)) {
      		$a_res['msg']=$result->getMessage();
      		$a_res['rc']=$result->getCode();
      		CNMUtils::error_log(__FILE__, __LINE__, "api_delete_metrics: error={$a_res['msg']} rc={$a_res['rc']} ($sql)");
   		}

		   while ($result1->fetchInto($r)){
      		$id_dev=$r['id_dev'];
      		$mname=$r['name'];
      		$type=$r['type'];
		      $subtype=$r['subtype'];
      		$ip=$r['ip'];
		      $frrd='/opt/data/rrd/elements/'.$r['file'];
      		$id_metric=$r['id_metric'];

		      self::_info_qactions('Borrar métrica',$_SESSION['LUSER'],0,"El usuario {$_SESSION['LUSER']} desde la ip {$_SESSION['REMOTE_ADDR']} ha borrado la métrica {$r['label']} del dispositivo {$r['dev_name']}.{$r['domain']} ({$r['ip']}) ID=$id_metric");

      		//print " IDDEV=$id_dev  MNAME=$mname  TYPE=$type  SUBTYPE=$subtype  IP=$ip  FRRD=$frrd  <br>";
		      CNMUtils::info_log(__FILE__, __LINE__, "api_delete_metrics: id_metric=$id_metric id_dev=$id_dev mname=$mname type=$type subtype=$subtype");

      		//Elimina de prov_template_metrics2iid, alerts y alerts_store (Los datos del alerts_store ya no son consistentes)
      		if (($id_dev) && ($mname)) {

		         // Desactiva la metrica de la plantilla del dispositivo
      		   $sql="UPDATE prov_template_metrics2iid SET status=1 WHERE id_dev=$id_dev AND mname='$mname'";
         		$result = $dbc->query($sql);
		         if (@PEAR::isError($result)){
      		      $a_res['msg']=$result->getMessage();
            		$a_res['rc']=$result->getCode();
            		CNMUtils::error_log(__FILE__, __LINE__, "api_delete_metrics: error={$a_res['msg']} rc={$a_res['rc']} ($sql)");
         	}

		         $sql="delete from alerts where id_device=$id_dev and mname='$mname'";
      		   $result = $dbc->query($sql);
         		if (@PEAR::isError($result)) {
		            $a_res['msg']=$result->getMessage();
      		      $a_res['rc']=$result->getCode();
            		CNMUtils::error_log(__FILE__, __LINE__, "api_delete_metrics: error={$a_res['msg']} rc={$a_res['rc']} ($sql)");
         		}
         		$sql="delete from alerts_store where id_device=$id_dev and mname='$mname'";
		         $result = $dbc->query($sql);
      		   if (@PEAR::isError($result)) {
            		$a_res['msg']=$result->getMessage();
		            $a_res['rc']=$result->getCode();
      		      CNMUtils::error_log(__FILE__, __LINE__, "api_delete_metrics: error={$a_res['msg']} rc={$a_res['rc']} ($sql)");
         		}

		         if ($id_metric) {
      		      $sql="delete from alerts_read where id_metric=$id_metric";
            		$result = $dbc->query($sql);
            		if (@PEAR::isError($result)) {
               		$a_res['msg']=$result->getMessage();
		               $a_res['rc']=$result->getCode();
      		         CNMUtils::error_log(__FILE__, __LINE__, "api_delete_metrics: error={$a_res['msg']} rc={$a_res['rc']} ($sql)");
            		}
         		}
      		}

		      // ----------------------------------------------------------------------
      		// Elimina la info de metric2snmp
      		if ($type == 'snmp'){
	      	   # Si el dispositivo en cuestion tiene una alerta de sin respuesta snmp, se borra
   	      	# porque si estuviera causada por esta metrica se quedaria colgada y si fuera
      	   	# otra metrica la causante, ya se vlveria a producir.
	   	      $sql="delete from alerts where id_device=$id_dev and mname='mon_snmp'";
   	   	   $result = $dbc->query($sql);
         		if (@PEAR::isError($result)){
		            $a_res['msg']=$result->getMessage();
      		      $a_res['rc']=$result->getCode();
            		CNMUtils::error_log(__FILE__, __LINE__, "api_delete_metrics: error={$a_res['msg']} rc={$a_res['rc']} ($sql)");
         		}

		         $sql="delete from metric2snmp where id_metric in ($IDM)";
      		   $result = $dbc->query($sql);
         		if (@PEAR::isError($result)) {
		            $a_res['msg']=$result->getMessage();
      		      $a_res['rc']=$result->getCode();
            		CNMUtils::error_log(__FILE__, __LINE__, "api_delete_metrics: error={$a_res['msg']} rc={$a_res['rc']} ($sql)");
         		}
		         //fml REVISAR !!
      		   //Elimina una posible preasignacion de la metrica al dispositivo
         		//delete_assigned_metrics($ip,$subtype);


		         if (($id_dev) && ($mname)) {
      		      $sql="delete from cnm.work_snmp where cid='$cid' and id_dev=$id_dev and mname='$mname'";
            		$result = $dbc->query($sql);
            		if (@PEAR::isError($result)) {
		               $a_res['msg']=$result->getMessage();
      		         $a_res['rc']=$result->getCode();
            		   CNMUtils::error_log(__FILE__, __LINE__, "api_delete_metrics: error={$a_res['msg']} rc={$a_res['rc']} ($sql)");
            		}
         		}
      		}

		      // ----------------------------------------------------------------------
      		// Elimina la info de metric2latency
      		elseif ($type == 'latency'){
		         $sql="delete from metric2latency where id_metric in ($ID)";
      		   $result = $dbc->query($sql);
         		if (@PEAR::isError($result)) {
		            $a_res['msg']=$result->getMessage();
      		      $a_res['rc']=$result->getCode();
            		CNMUtils::error_log(__FILE__, __LINE__, "api_delete_metrics: error={$a_res['msg']} rc={$a_res['rc']} ($sql)");
         		}

         //Elimina una posible preasignacion de la metrica al dispositivo
         //delete_assigned_metrics($ip,$mname);


		         if (($id_dev) && ($mname)) {
      		      $sql="delete from cnm.work_latency where cid='$cid' and id_dev=$id_dev and mname='$mname'";
            		$result = $dbc->query($sql);
		            if (@PEAR::isError($result)) {
      		         $a_res['msg']=$result->getMessage();
            		   $a_res['rc']=$result->getCode();
               		CNMUtils::error_log(__FILE__, __LINE__, "api_delete_metrics: error={$a_res['msg']} rc={$a_res['rc']} ($sql)");
           	 		}
         		}
      		}

		      // ----------------------------------------------------------------------
      		elseif ($type == 'xagent'){
         		if (($id_dev) && ($mname)) {
		            $sql="delete from cnm.work_xagent where cid='$cid' and id_dev=$id_dev and mname='$mname'";
      		      $result = $dbc->query($sql);
            		if (@PEAR::isError($result)) {
		               $a_res['msg']=$result->getMessage();
      		         $a_res['rc']=$result->getCode();
            		   CNMUtils::error_log(__FILE__, __LINE__, "api_delete_metrics: error={$a_res['msg']} rc={$a_res['rc']} ($sql)");
            		}
        	 		}
      		}

      		//Borra el fichero con los datos rrd
		      if (is_file($frrd)) {
      		   $rc=unlink ($frrd);
         		if (! $rc) {   CNMUtils::error_log(__FILE__, __LINE__, "api_delete_metrics: ERROR al borrar rrd ($frrd)");   }
      		}

   		}

		   // Se hace el workset para replicar  el contenido de las tablas work_xxx en mdata
		   // Por defecto do_workset=1. Si se procesa un bloque de metricas puede ser mejor ponerlo
		   // a 0 y hacer el workset fuera sobre el bloque como proceso externo.
		   if ($do_workset) {
      		$outputfile='/dev/null';
		      $pidfile='/tmp/pid';
      		$cmd="/usr/bin/sudo /opt/crawler/bin/workset -c $cid -f  2>&1";
		      $user=$_SESSION['LUSER'];
      		CNMUtils::info_log(__FILE__, __LINE__, "api_delete_metrics: user=$user STATUS=$status CMD=$cmd");
      		exec(sprintf("%s > %s 2>&1 & echo $! >> %s", $cmd, $outputfile, $pidfile));
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

/*
// Función encargada de actualizar el campo nmetrics de cfg_view
function view_update_nmetrics($id_cfg_view,$cid){
   global $dbc;

   $cid_ip = local_ip();

         'cnm_view_get_num_metrics'=>"SELECT count(DISTINCT a.id_metric) as cuantos FROM cfg_views2metrics a,devices b WHERE a.id_device=b.id_dev AND id_cfg_view=__ID_CFG_VIEW__",
         'cnm_view_update_nmetrics'=>"UPDATE cfg_views SET nmetrics=__NMETRICS__ WHERE id_cfg_view=__ID_CFG_VIEW__ AND cid='__CID__' AND cid_ip='__CID_IP__'",

   // nmetrics
   $data = array('__ID_CFG_VIEW__'=>$id_cfg_view,'__CID__'=>$cid,'__CID_IP__'=>$cid_ip);
   $result = doQuery('cnm_view_get_num_metrics',$data);
   $cuantos = $result['obj'][0]['cuantos'];

   $data = array('__ID_CFG_VIEW__'=>$id_cfg_view,'__CID__'=>$cid,'__CID_IP__'=>$cid_ip,'__NMETRICS__'=>$cuantos);
   $result = doQuery('cnm_view_update_nmetrics',$data);

   // nremote
   $data = array('__ID_CFG_VIEW__'=>$id_cfg_view,'__CID__'=>$cid,'__CID_IP__'=>$cid_ip);
   $result = doQuery('cnm_view_get_num_remote',$data);
   $cuantos = $result['obj'][0]['cuantos'];

   $data = array('__ID_CFG_VIEW__'=>$id_cfg_view,'__CID__'=>$cid,'__CID_IP__'=>$cid_ip,'__NREMOTE__'=>$cuantos);
   $result = doQuery('cnm_view_update_nremote',$data);

   // nsubviews
      $data = array('__ID_CFG_VIEW__'=>$id_cfg_view,'__CID__'=>$cid,'__CID_IP__'=>$cid_ip);
   $result = doQuery('cnm_view_get_num_subviews',$data);
   $cuantos = $result['obj'][0]['cuantos'];

   $data = array('__ID_CFG_VIEW__'=>$id_cfg_view,'__CID__'=>$cid,'__CID_IP__'=>$cid_ip,'__NSUBVIEWS__'=>$cuantos);
   $result = doQuery('cnm_view_update_nsubviews',$data);
}
*/

?>
