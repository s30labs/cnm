<?php
// Programa que modifica la estructura de la BBDD de CNM


// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE NECESARIA PARA REALIZAR LA CONEXION CON LA BBDD
require_once("/update/db/DB-Scheme-Lib.php");

function debugger($msg,$lvl){
// debug==-1 => No se escribe || $debug==0 y posteriores=> Escribe en fichero
$max_level=3;
$debug_file='/tmp/update.log';

   if($max_level>=$lvl){
      $fecha=date("Y-m-d H:m:s");
      $fd=fopen($debug_file,'a+');
      fwrite($fd,$fecha."::change-DB.php::".$msg."\n");
      fclose($fd);
   }
}


// FUNCION QUE MODIFICA LA TABLA ALERT_TYPE
function update_alert_type(){
	global $enlace;
	
	// 1.- CAMBIO PARA INDICAR DE QUE TIPO ES CADA MONITOR
	// 1.1.- PONEMOS TODOS LOS MONITORES DE TIPO SNMP
	$sqlsnmp="UPDATE alert_type
	          SET type='snmp'";
	debugger("change-DB.php::sqlsnmp == $sqlsnmp",2);
	
	$resultsnmp = $enlace->query($sqlsnmp);
   if (@PEAR::isError($resultsnmp)) {
	   $msg_error=$resultsnmp->getMessage();
	   debugger("update_alert_type::ERROR-LINEA ".__LINE__.":: $msg_error::$sqlsnmp",1);
		return 1;
   }
	
	// 1.2.- PONEMOS LOS MONITORES XAGENT
   $sqlagent="UPDATE alert_type
              SET type='xagent'
              WHERE mname like 'xagt_%'";

	debugger("update_alert_type::sqlagent == $sqlagent",1);
	$resultagent = $enlace->query($sqlagent);
	if (@PEAR::isError($resultagent)){
  		$msg_error=$resultagent->getMessage();
	   debugger("update_alert_type::ERROR-LINEA ".__LINE__.":: $msg_error::$sqlagent",1);
      return 1;
	}   
	// 1.3.- PONEMOS LOS MONITORES LATENCY
   $sqllatency="UPDATE alert_type
             	 SET type='latency'
	             WHERE mname like '%mon_%'";

   debugger("update_alert_type::sqllatency == $sqllatency",1);
   $resultlatency = $enlace->query($sqllatency);
   if (@PEAR::isError($resultlatency)){
      $msg_error=$resultlatenc->getMessage();
      debugger("update_alert_type::ERROR-LINEA ".__LINE__.":: $msg_error::$sqllatency",1);
      return 1;
   }



	// 2.- PONEMOS EL SUBTYPE A CADA MONITOR BASANDONOS EN EL NAME DE LA METRICA
	$sql="SELECT monitor
			FROM alert_type";

	$result = $enlace->query($sql);
   if (@PEAR::isError($result)){
      $msg_error=$result->getMessage();
      debugger("update_alert_type::ERROR-LINEA ".__LINE__.":: $msg_error::$sql",1);
      return 1;
   }

	while ($result->fetchInto($r)){
		$monitor=$r['monitor'];
		$mname=$r['monitor'];
		// EN CASO DE SER UN MONITOR CON NAME DEL TIPO s_ o w_ LES QUITAMOS EL COMIENZO
		// s_xxxxx_2021  s_w_xxxxx-num-num

		//s_w_mon_tcp-f1a6fa8a-2715ace6
      if (substr($mname,0,4)=='s_w_') { 
			
			$mname=substr($mname,4); 
			$parts=split('-',$mname);
			$subtype=$parts[0].'-'.$parts[1];
		}
		// s_disk_mibhost_2010
		elseif (substr($mname,0,2)=='s_') {  	
			$mname=substr($mname,2);  
			$parts=split('_',$mname);
			array_pop($parts);
			$subtype=implode('_',$parts);
		}

		$sqlsubtype="UPDATE alert_type
						 SET subtype='$subtype', mname='$subtype'
						 WHERE monitor='$monitor'";
		$resultsubtype = $enlace->query($sqlsubtype);
	   if (@PEAR::isError($resultsubtype)){
	      $msg_error=$result->getMessage();
	      debugger("update_alert_type::ERROR-LINEA ".__LINE__.":: $msg_error::$sqlsubtype",1);
	      return 1;
	   }
   }
	return 0;
}




// FUNCION QUE MODIFICA LA TABLA CFG_MONITOR
function update_cfg_monitor(){
   global $enlace;

   $sql="SELECT subtype,shtml 
         FROM cfg_monitor";
   debugger("update_cfg_monitor::sql == $sql",1);
   $result = $enlace->query($sql);
   while ($result->fetchInto($r)){


		// 1.- RELLENAMOS EL CAMPO SHTML DE LOS CAMPOS QUE NO LO TENGAN DEFINIDO
		if ($r['subtype']==''){
         debugger("update_cfg_monitor::ERROR-LINEA ".__LINE__.":: HAY UN SUBTIPO VACIO",1);
         continue;
      }
		$subtype=$r['subtype'];
      $sqlupdate="UPDATE cfg_monitor 
                 SET shtml='$subtype.shtml'
                 WHERE subtype='$subtype'";
      debugger("update_cfg_monitor::sqlagent == $sqlupdate",1);
      $resultupdate = $enlace->query($sqlupdate);
      if (@PEAR::isError($resultupdate)){
         $msg_error=$resultupdate->getMessage();
         debugger("update_cfg_monitor::ERROR-LINEA ".__LINE__.":: $msg_error::$sqlupdate",1);
         return 1;
      }


		// 2.- RELLENAMOS EL CAMPO ITEMS
		$sqlitems="SELECT subtype, items
					  FROM cfg_monitor
					  WHERE items IS NOT NULL AND items!=''";
		$resultitems = $enlace->query($sqlitems);
		$items=array();
		while ($resultitems->fetchInto($ritems)){
			$items[$ritems['subtype']]=$ritems['items'];
		}
		$items['mon_icmp']=$items['mon_tcp'];
		$items['disp_icmp']='Disponible|No computable|No Disponible|Desconocido';

		$sqlupdate="UPDATE cfg_monitor
                 SET items='".$items[$subtype]."'
                 WHERE subtype='$subtype'";
      debugger("update_cfg_monitor::sqlagent == $sqlupdate",1);
      $resultupdate = $enlace->query($sqlupdate);
      if (@PEAR::isError($resultupdate)){
         $msg_error=$resultupdate->getMessage();
         debugger("update_cfg_monitor::ERROR-LINEA ".__LINE__.":: $msg_error::$sqlupdate",1);
         return 1;
      }


      // 3.- RELLENAMOS EL CAMPO CFG
      $sqlcfg1="SELECT id_cfg_monitor
                 FROM cfg_monitor
                 WHERE monitor like 'w_%' or monitor in ('mon_icmp', 'disp_icmp')";
      $resultcfg1 = $enlace->query($sqlcfg1);
      $ids=array();
      while ($resultcfg1->fetchInto($rcfg1)){
         array_push($ids,$rcfg1['id_cfg_monitor']);
      }
      $list_ids=implode(',',$ids);

      $sqlupdate="UPDATE cfg_monitor
                 SET cfg=1
                 WHERE id_cfg_monitor in ($list_ids)";
      debugger("update_cfg_monitor::sqlagent == $sqlupdate",1);
      $resultupdate = $enlace->query($sqlupdate);
      if (@PEAR::isError($resultupdate)){
         $msg_error=$resultupdate->getMessage();
         debugger("update_cfg_monitor::ERROR-LINEA ".__LINE__.":: $msg_error::$sqlupdate",1);
         return 1;
      }

   }

	// ACTUALIZAMOS EL RESTO DE CAMPOS
	$sqlupdate="UPDATE cfg_monitor
               SET mtype='STD_BASEIP1',module='mod_monitor',top_value=0,mode='GAUGE',cfg=1
               WHERE monitor like='w_%'";
	debugger("update_cfg_monitor::sqlagent == $sqlupdate",1);
   $resultupdate = $enlace->query($sqlupdate);
   if (@PEAR::isError($resultupdate)){
      $msg_error=$resultupdate->getMessage();
      debugger("update_cfg_monitor::ERROR-LINEA ".__LINE__.":: $msg_error::$sqlupdate",1);
      return 1;
   }

	return 0;
}



// PROGRAMA PRINCIPAL
global $enlace;
if (connectDB()==1){
	exit;
}
$rc_update_alert_type=update_alert_type();
$rc_update_cfg_monitor=update_cfg_monitor();



?>
