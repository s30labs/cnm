<?php
require_once('/usr/share/pear/DB.php');
include_once('inc/session.php');
include_once('/var/www/html/tphp/class.TemplatePower.inc.php');
include_once('inc/CNMUtils.php');

$Store_RC=0;
$Store_RCSTR='ok';
$Store_RC_PARAMS=array();

/*
 * $a_global_sql_error => Errores sql y su descripción
 * NOTAS: Se obtiene de /usr/share/pear/DB.php
 *        Se aplica en responseJSON y responseXML
*/
$a_global_sql_error = array(
	'-1'  => 'DB_ERROR',
   '-2'  => 'DB_ERROR_SYNTAX',
   '-3'  => 'DB_ERROR_CONSTRAINT',
   '-4'  => 'DB_ERROR_NOT_FOUND',
   '-5'  => 'DB_ERROR_ALREADY_EXISTS',
   '-6'  => 'DB_ERROR_UNSUPPORTED',
   '-7'  => 'DB_ERROR_MISMATCH',
	'-8'  => 'DB_ERROR_INVALID',
	'-9'  => 'DB_ERROR_NOT_CAPABLE',
	'-10' => 'DB_ERROR_TRUNCATED',
	'-11' => 'DB_ERROR_INVALID_NUMBER',
	'-12' => 'DB_ERROR_INVALID_DATE',
	'-13' => 'DB_ERROR_DIVZERO',
	'-14' => 'DB_ERROR_NODBSELECTED',
	'-15' => 'DB_ERROR_CANNOT_CREATE',
	'-17' => 'DB_ERROR_CANNOT_DROP',
	'-18' => 'DB_ERROR_NOSUCHTABLE',
	'-19' => 'DB_ERROR_NOSUCHFIELD',
	'-20' => 'DB_ERROR_NEED_MORE_DATA',
	'-21' => 'DB_ERROR_NOT_LOCKED',
	'-22' => 'DB_ERROR_VALUE_COUNT_ON_ROW',
	'-23' => 'DB_ERROR_INVALID_DSN',
	'-24' => 'DB_ERROR_CONNECT_FAILED',
	'-25' => 'DB_ERROR_EXTENSION_NOT_FOUND',
	'-26' => 'DB_ERROR_ACCESS_VIOLATION',
	'-27' => 'DB_ERROR_NOSUCHDB',
	'-29' => 'DB_ERROR_CONSTRAINT_NOT_NULL',
);



//--------------------------------------------------------------------------
// Function: str2js
// Descripcion: Funcion auxiliar. Parsea un string y elimina aquellos caracteres
// que pueden hacer que al incluir el string dentro de un array de javascript
// se produzca un error.
//--------------------------------------------------------------------------
function str2js($str){
global $dbc;

   $str=str_replace("\\", "\\\\",$str); // Substituyo /
   $str=str_replace("\n", " ",$str); // Substituyo /
	$str=str_replace('"', '\"',$str); // Substituyo "
	$str=str_replace("'", "\'",$str); // Substituyo '
   return $str;
}
//--------------------------------------------------------------------------
// Function: str2jsUnique
// Descripcion: Funcion auxiliar. Parsea un string y elimina aquellos caracteres
// que pueden hacer que al incluir el string dentro de un array de javascript
// se produzca un error.
//--------------------------------------------------------------------------
function str2jsUnique($str){
global $dbc;

   $str=str_replace("\\", "\\\\",$str); // Substituyo /
   $str=str_replace("\n", " ",$str); // Substituyo /
   // $str=str_replace('"', '\"',$str); // Substituyo "
   // $str=str_replace("'", "\'",$str); // Substituyo '
   return $str;
}


//--------------------------------------------------------------------------
// Function: str2jsQM
// Descripcion: Funcion auxiliar. Parsea un string y elimina aquellos caracteres
// que pueden hacer que al incluir el string dentro de un array de javascript
// se produzca un error.
//--------------------------------------------------------------------------
function str2jsQM($str){
global $dbc;
   $str=str_replace("\\", "\\\\",$str); // Substituyo /
   $str=str_replace("'", "\'",$str); // Substituyo '
   return $str;
}



//--------------------------------------------------------------------------
// Function: get_param
// Descripcion: Funcion auxiliar. Obtiene un parametro, ya sea por GET o por POST.
//--------------------------------------------------------------------------


function get_param($p,$strip=true,$del_quote=true){
global $dbc;
	if     (isset($_POST[$p]) AND $strip==true){
		// return stripslashes($_POST[$p]);
		return stripslashes(str_replace("'","",$_POST[$p]));
	}
	elseif (isset($_GET[$p]) AND $strip==true){
		return stripslashes(str_replace("'","",$_GET[$p]));
	}
	elseif (isset($_POST[$p]) AND $strip==false){
		if($del_quote==true){
			return str_replace("'","",$_POST[$p]);
		}else{
			return $_POST[$p];
		}
	}
	elseif (isset($_GET[$p]) AND $strip==false){
		if($del_quote==true){
			return str_replace("'","",$_GET[$p]);
		}else{
			return $_GET[$p];
		}
	}
	// SSV: El siguiente elseif sirve para poder ejecutar por linea de comandos los phps que nos interesen
	// poniendo php fichero.php var1=valor1 var2=valor2
	// En caso de notar algun malfuncionamiento, comentarlo
	elseif (isset($GLOBALS['argv']) and count($GLOBALS['argv'])>0){
	   for ($i=1;$i<count($GLOBALS['argv']);$i++){
   	   $datos=explode('=',$GLOBALS['argv'][$i]);
			if ($datos[0]==$p){
				return str_replace("'","",$datos[1]);
			}
	   }
	}
	return '';
}

//--------------------------------------------------------------------------
// Function: xmlgrid2array
// Descripcion: Convierte los datos de un grid serializado a un array
//--------------------------------------------------------------------------
function xmlgrid2array ($xml){

	$res = simplexml_load_string($xml);
	$vector=array();
	foreach($res->row as $r) {
   	foreach($r->attributes() as $a => $b) {
			if ($a != 'id') { continue; }
      	$id=(string)$b;
      	$idx=0;
      	foreach ($r->children() as $k=>$v) {
         	$vector[$id][$idx]=(string) $v;
         	$idx+=1;
      	}
   	}
	}
	return $vector;
}

//--------------------------------------------------------------------------
// Function: xmlfile2array
// Descripcion: Convierte los datos de un fichero xml a un array
//--------------------------------------------------------------------------
function xmlfile2array ($file){
   $res = @simplexml_load_file($file);
   $vector=array();
   foreach($res->row as $r) {
      foreach($r->attributes() as $a => $b) {
         if ($a != 'id') { continue; }
         $id=(string)$b;
         $idx=0;
         foreach ($r->children() as $k=>$v) {
            $vector[$id][$idx]=(string) $v;
            $idx+=1;
         }
      }
   }
   return $vector;
}

//--------------------------------------------------------------------------
// Function: fullxmlfile2array
// Descripcion: Convierte los datos de un fichero xml a un array incluyendo los titulos
//--------------------------------------------------------------------------
function fullxmlfile2array ($file){
   $res = @simplexml_load_file($file);
   $vector=array();

	$has_head = 0;
   foreach ($res->head as $head) {
		$a_head = array();
      foreach($head->column as $col_name){
			$a_head[]=(string) $col_name;
			$has_head = 1;
      }
		$vector[]=$a_head;	
   }

   foreach($res->row as $r) {
      foreach($r->attributes() as $a => $b) {
         if ($a != 'id') { continue; }
         $id=($has_head==0)?(string)$b:((string)$b)+1;
         $idx=0;
         foreach ($r->children() as $k=>$v) {
            $vector[$id][$idx]=(string) $v;
            $idx+=1;
         }
      }
   }
   return $vector;
}


//--------------------------------------------------------------------------
// Function: read_cfg_file
// Descripcion: Funcion auxiliar. Permite leer el fichero de configuracion
// /cfg/onm.conf cuya sintaxis es del tipo clave=valor.
// Parametros de entrada:
// a. Nombre del fichero.
// b. Hash cuyas claves son las cadenas a leer.
//--------------------------------------------------------------------------

function read_cfg_file($file,&$data){
global $dbc;

	if (!file_exists($file)){
		$rc="No existe el fichero $file";
		CNMUtils::info_log(__FILE__, __LINE__, "read_cfg_file:: $rc");
      return $rc;
	}
	$rcstr='';
   $lines = file($file);
	if (! $lines) {
		$rc="Error al abrir fichero $file en modo lectura";
		return $rc;
	}
   foreach ($data as $clave => $valor) {
      $not_found=1;

      # 1. Check if environmental variable exists
      if (getenv($clave) !== false){
			$data[$clave] = getenv($clave);
			$not_found=0;
		}
      # 2. If not exists we search it in the config file
		else{
      	foreach ($lines as $l){
	
	         if (preg_match("/^#/", $l))      continue;
	         if (!preg_match("/$clave/", $l)) continue; 
	
	         $words=preg_split('/\s*\=\s*/',$l);
	         if (($words[0] == $clave)&& ($not_found)) {
	            $data[$clave] = rtrim($words[1]," \n");
	            $not_found=0;
	         }
	
	//         if(preg_match("/^$clave=(.*)(#.*)?$/", $l, $match)){
	//            $data[$clave] = $match[1];
	//         }
	
	      }
		}
   }
}

//--------------------------------------------------------------------------
// Function: read_cfg_servers
// Descripcion: Funcion auxiliar. Permite leer el fichero de configuracion
// de subversion pra la configuracion de proxy cuya sintaxis es del tipo clave=valor.
// Parametros de entrada:
// Hash cuyas claves son las cadenas a leer.
//--------------------------------------------------------------------------

function read_cfg_servers(&$data){
global $dbc;

$file='/root/.subversion/servers';

   $rcstr='';
   $lines = file($file);
   if (! $lines){
      $rc="Error al abrir fichero $file en modo lectura";
      return $rc;
   }
   foreach ($data as $clave => $valor) {
      $not_found=1;
      foreach ($lines as $l){
         if (!preg_match($clave, $l)) {
				continue;
			}
         $words=preg_split('/\s*\=\s*/',$l);
			$words[0]=str_replace('#','', $words[0]);
         if (($words[0] == $clave)&& ($not_found)){
            $data[$clave] = rtrim($words[1]," \n");
            $not_found=0;
         }
      }
   }
}

//--------------------------------------------------------------------------
// Function: write_cfg_servers_
// Descripcion: Funcion auxiliar. Permite modificar el fichero de configuracion
// de subversion /root/.subversion/servers cuya sintaxis es del tipo clave=valor.
// Parametros de entrada:
// a. modo: 0 => Comentado 1=> Descomentado
// b. Hash cuyas claves son las cadenas a leer y sus valores los valores a escribir.
//--------------------------------------------------------------------------

function write_cfg_servers($mode,&$data){
global $dbc;

$file='/root/.subversion/servers';
   $rcstr='';
   $lines = file($file);
   if (! $lines) {
      $rc="Error al abrir fichero $file en modo lectura";
      return $rc;
   }

   $data_bis=$data;

   $new_data=array();
	$tmp_file=fopen($file,'w+');
   if (! $tmp_file) {
      $rc="Error al abrir fichero $file en modo escritura";
      return $rc;
   }
	fwrite($tmp_file,"[global]\n");

   foreach ($data as $clave => $valor) {
		//if (preg_match("^#", $l)) { continue; }
		// print "words[0] vale ".$words[0]."<br>";
		// print "valor vale $valor<br>";
		if ($mode==0){
			fwrite($tmp_file,"#$clave = $valor\n");
		}else{
         fwrite($tmp_file,"$clave = $valor\n");
		}
   }
   fclose($tmp_file);
}






//--------------------------------------------------------------------------
// Function: configure_NTP
// Descripcion: Funcion auxiliar. Permite leer o modificar el fichero de configuracion
// del ntp.
// Parametros de entrada:
// a. Booleano que nos dice si es lectura o escritura del fichero.
//		0 => Lectura
//		1 => Escritura
// b. String que contiene el dato del servidor NTP.
//--------------------------------------------------------------------------

function configure_NTP($mode,&$data){
global $dbc;
   $rcstr='';
	$file="/etc/cron.hourly/ntpdate";	
	$patron="/usr/sbin/ntpdate";

	// En caso de ser lectura del dato
	if ($mode==0){
	   $open=fopen($file,"r");
	   if (!$open) {
	      $rc="Error al abrir fichero $file en modo lectura";
	      return $rc;
	   }
	   fclose($open);

	   $lines = file($file);
		foreach ($lines as $l){
			$l = trim($l);
			if (  (!preg_match("/^\s*#/", $l)) && (strpos($l,$patron)!==false)  ) {
				preg_match('/^\s*\/usr\/sbin\/ntpdate\s*(\S+).*$/', $l, $coincidencias);
				$data = $coincidencias[1];
				break;
			} 	
      }
   }
	// En caso de ser escritura del dato
	else{
//		$new_data = array();
//		if ($data) $new_data[]="#!/bin/bash\n$patron $data >/dev/null 2>&1\n";
//		
//		$tmp_file=fopen($file,'w+');
//   	if (! $tmp_file) {
//      	$rc="Error al abrir fichero $file en modo escritura";
//	      return $rc;
//   	}
//
//   	foreach ($new_data as $l2) fwrite($tmp_file,$l2);
//		fclose($tmp_file);

		// Se modifica /etc/cron.hourly/ntpdate segun la plantilla de /os
		// Por eso se utiliza /opt/cnm/crawler/bin/support/chk-host-file !!
		$cmd="/usr/bin/sudo /opt/cnm/crawler/bin/support/chk-host-file -f /etc/cron.hourly/ntpdate.base -p 'NTPHOST=$data' 2>&1";
		exec($cmd,$results);
		if ($results[0] != 1) {
			$rc="Error al modificar /etc/cron.hourly/ntpdate";
			CNMUtils::error_log(__FILE__, __LINE__, "**ERROR** ($rc) [/usr/bin/sudo /opt/cnm/crawler/bin/support/chk-host-file -f /etc/cron.hourly/ntpdate.base -p 'NTPHOST=pool.ntp.org' 2>&1]");
			return $rc;
		}
	}
}

//--------------------------------------------------------------------------
// Function: write_cfg_file
// Descripcion: Funcion auxiliar. Permite modificar el fichero de configuracion
// /cfg/onm.conf cuya sintaxis es del tipo clave=valor.
// Parametros de entrada:
// a. Nombre del fichero.
// b. Hash cuyas claves son las cadenas a leer y sus valores los valores a escribir.
//--------------------------------------------------------------------------

function write_cfg_file($file,&$data){
global $dbc;	
	$rcstr='';
   $lines = file($file);
/*
	if (! $lines) {
      $rc="Error al abrir fichero $file en modo lectura";
      return $rc;
   }
*/

	$data_bis=$data;
	foreach ($data_bis as $key => $value){
		$data_bis[$key] = "0";
	}
   $new_data=array();
   foreach ($lines as $l)
      {
      $escrito=0;
      $words=preg_split('/\s*\=\s*/',$l);
      $newline=$l;

      foreach ($data as $clave => $valor) {
         if ($words[0] == $clave) {
            $newline= "$words[0] = $valor\n";
				$data_bis[$clave]="1";
	         break;
         }
      }
      array_push ($new_data,$newline);
   }
   $tmp_file=fopen($file,'w+');
   if (! $tmp_file) {
      $rc="Error al abrir fichero $file en modo escritura";
      return $rc;
   }

	foreach ($new_data as $l2) {
      fwrite($tmp_file,$l2);
   }
	
	foreach ($data_bis as $key2 => $value2) {
		if (!$value2){
			fwrite($tmp_file,"$key2 = $data[$key2]\n");
		}
	}
	
   fclose($tmp_file);

}



//--------------------------------------------------------------------------
// Function: configure_DNS
// Descripcion: Funcion auxiliar. Permite modificar el fichero de configuracion
// del DNS.
// a. Booleano que nos dice si es lectura o escritura del fichero.
//    0 => Lectura
//    1 => Escritura
// b. Array que contiene los datos de los servidores DNS.
// Valores devueltos:
// $Store_RC valor numerico con el error 0-> ok/ 1-> error,
// $Store_RCSTR clave modo texto del hash de localizacion (MC).
//--------------------------------------------------------------------------

function configure_DNS($mode,&$data){
global $Store_RC,$Store_RCSTR;
global $dbc;
	$Store_RC    = 0;
	$Store_RCSTR = 'ok';
	$file        = "/etc/resolv.conf";
	$patron      = "nameserver";

   // En caso de ser lectura del dato
   if ($mode==0){
	   $open=fopen($file,"r");
	   if ( !$open) {
	      $Store_RCSTR="error_al_abrir_fichero_en_modo_lectura";
	      $Store_RC=1;
	      return $Store_RC;
	   }
	   fclose($open);

   	$lines = file($file);

      foreach ($lines as $l){
			$l = trim($l);
         if (  (!preg_match("/^\s*#/", $l)) && (strpos($l,$patron)!==false)  ) $data[] =str_replace("$patron ",'',$l);
      }
   }
   // En caso de ser escritura del dato
   else{
      $new_data=array();

      $open=fopen($file,"r");
      if ( !$open) {
         $Store_RCSTR="error_al_abrir_fichero_en_modo_lectura";
         $Store_RC=1;
         return $Store_RC;
      }
      fclose($open);

      $lines = file($file);

      foreach ($lines as $l){
         $l = trim($l);
         if (  (!preg_match("/^\s*#/", $l)) && (strpos($l,$patron)!==false)  ) {
            continue;
         }
         $new_data[]="$l\n";
      }


		foreach ($data as $l){
			if ($l){
				$l=chop($l);
				array_push($new_data,"$patron $l\n");
			}
		}
		$tmp_file=fopen($file,'w+');

   	if (! $tmp_file) {
      	$Store_RCSTR="error_al_abrir_fichero_en_modo_escritura";
			$Store_RC=1;
      	return $Store_RC;
   	}

  		foreach ($new_data as $l2) fwrite($tmp_file,$l2);
	   fclose($tmp_file);
	}
	return $Store_RC;
}


//--------------------------------------------------------------------------
// Function: configure_search_domain()
// Descripcion: Funcion auxiliar. Permite modificar el fichero de configuracion
// del DNS.
// a. Booleano que nos dice si es lectura o escritura del fichero.
//    0 => Lectura
//    1 => Escritura
// b. Array que contiene los datos de los dominios de búsqueda.
// Valores devueltos:
// $Store_RC valor numerico con el error 0-> ok/ 1-> error,
// $Store_RCSTR clave modo texto del hash de localizacion (MC).
//--------------------------------------------------------------------------

function configure_search_domain($mode,&$data){
global $Store_RC,$Store_RCSTR;
global $dbc;
	$Store_RC    = 0;
	$Store_RCSTR = 'ok';
	$file        = "/etc/resolv.conf";
	$patron      = "search";

   // En caso de ser lectura del dato
   if ($mode==0){
	   $open=fopen($file,"r");
	   if ( !$open) {
	      $Store_RCSTR="error_al_abrir_fichero_en_modo_lectura";
	      $Store_RC=1;
	      return $Store_RC;
	   }
	   fclose($open);

   	$lines = file($file);

      foreach ($lines as $l){
			$l = trim($l);
         if (  (!preg_match("/^\s*#/", $l)) && (strpos($l,$patron)!==false)  ) $data[] =str_replace("$patron ",'',$l);
      }
   }
   // En caso de ser escritura del dato
   else{
      $new_data=array();

      $open=fopen($file,"r");
      if ( !$open) {
         $Store_RCSTR="error_al_abrir_fichero_en_modo_lectura";
         $Store_RC=1;
         return $Store_RC;
      }
      fclose($open);

      $lines = file($file);

      foreach ($lines as $l){
         $l = trim($l);
         if (  (!preg_match("/^\s*#/", $l)) && (strpos($l,$patron)!==false)  ) {
				continue;	
			}
			$new_data[]="$l\n";
      }

		foreach ($data as $l){
			if ($l){
				$l=chop($l);
				$new_data[]="$patron $l\n";
			}
		}
		$tmp_file=fopen($file,'w+');

   	if (! $tmp_file) {
      	$Store_RCSTR="error_al_abrir_fichero_en_modo_escritura";
			$Store_RC=1;
      	return $Store_RC;
   	}

  		foreach ($new_data as $l2) fwrite($tmp_file,$l2);
	   fclose($tmp_file);
	}
	return $Store_RC;
}

//--------------------------------------------------------------------------
// Function: compose_search_condition
// Descripcion:
// 	Compone la condicion de busqueda en base a las claves del hash pasado
//		como parametro y del operador
//	IN: Hash con los campos numericos + hash con campos de texto + operador logico (and/or)
//--------------------------------------------------------------------------

function compose_search_condition($fieldsn,$fieldsq,$operator) {

	$condition=Array();
	$keys=array_keys($fieldsn);
	foreach ($keys as $k) {
		$c=$k.' like '.str_replace ( "*", "%", $fieldsn[$k]);
		array_push ($condition, $c);
	}
   $keys=array_keys($fieldsq);
   foreach ($keys as $k) {
		if ($fieldsq[$k] === '') { continue; }
      $c=$k." like '".str_replace ( "*", "%", $fieldsq[$k])."'";
      array_push ($condition, $c);
   }

	return implode(" $operator ", $condition);
}


//--------------------------------------------------------------------------
// Function: get_device_data
// Descripcion:
//--------------------------------------------------------------------------
function get_device_data($IP){
global $dbc;

   $sql="SELECT id_dev,name,domain,type,community,status
         FROM devices
         WHERE ip='$IP'";
   // print "******* $sql *****\n";
   $result = $dbc->query($sql);
   $result->fetchInto($r);
	return $r;
}


//--------------------------------------------------------------------------
// Function: get_monitor_data
// Descripcion:
//--------------------------------------------------------------------------
function get_monitor_data($cause){
global $dbc;

   $sql="SELECT monitor,expr,params,severity,mname,type,subtype
         FROM alert_type
         WHERE cause='$cause'";
   // print "******* $sql *****\n";
   $result = $dbc->query($sql);
   $result->fetchInto($r);
   return $r;
}


//--------------------------------------------------------------------------
// Function: delete_device
// Descripcion: Borra los dispositivos, y los registros asociados
//--------------------------------------------------------------------------

function delete_device($ID,$cid){
global $dbc;
//	//Elimina el dispositivo de la tabla
//	$sql="delete from devices where id_dev in ($ID)";
//	$result = mysql_query($sql);
//
//	// Notifica a los crawlers que se deben eliminar las metricas
//	$sql="Update metrics set status=3, refresh=1 where id_dev in ($ID)";
//	$result = mysql_query($sql);
//
//	// Elimina las alertas asociadas de ese dispositivo
//	$sql="delete from alerts where id_device in  ($ID)";
//	$result = mysql_query($sql);
//
//   // Elimina las alertas asociadas de ese dispositivo
//   $sql="delete from alerts_store where id_device in  ($ID)";
//   $result = mysql_query($sql);

//   // Elimina los avisos asociadas de ese dispositivo
//   $sql="delete from cfg_notification2device where id_device in  ($ID)";
//   $result = mysql_query($sql);


   if (! $ID) {
		$msg = 'delete_device::No se ha pasado ID';
      $response['rc']  = 1;
      $response['msg'] = $msg;
		CNMUtils::error_log(__FILE__, __LINE__, $msg);
      return $response;
   }
   if (! $cid){
      $msg = 'delete_device::No se ha pasado cid';
      $response['rc']  = 1;
      $response['msg'] = $msg;
		CNMUtils::error_log(__FILE__, __LINE__, $msg);
      return $response;
   }

	// Busco las metricas asociadas al dispositivo y las elimino
   $sql="SELECT id_metric FROM metrics WHERE id_dev IN ($ID)";
	$result = $dbc->query($sql);
	if (@PEAR::isError($result)){echo 'Store: '.$result->getMessage()."$sql <BR>";  }
	$IDM=array();
	while ($result->fetchInto($r)){array_push ($IDM,$r['id_metric']);}
	$id_metrics= join(',', $IDM);

	delete_metrics($id_metrics,$cid);

   $sql="SELECT id_dev,name,ip,domain FROM devices WHERE id_dev IN ($ID)";
   $result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      info_qactions('Borrar dispositivo',$_SESSION['LUSER'],0,"El usuario {$_SESSION['LUSER']} desde la ip {$_SESSION['REMOTE_ADDR']} ha borrado el dispositivo {$r['name']}.{$r['domain']} ({$r['ip']}) ID={$r['id_dev']}");
   }

   //Elimina el dispositivo de la tabla
   $sql="DELETE FROM devices WHERE id_dev IN ($ID)";
	$result = $dbc->query($sql);

   // Elimina los avisos asociadas de ese dispositivo
   $sql="delete from cfg_notification2device where id_device in ($ID)";
	$result = $dbc->query($sql);

	// Elimina los datos introducidos por el usuario en dicho dispositivo
	$sql="delete from devices_custom_data where id_dev in ($ID)";
	$result = $dbc->query($sql);
	
	// Elimina el dispositivo de cfg_devices2organizational_profile
	$sql="delete from cfg_devices2organizational_profile where id_dev in ($ID)";
   $result = $dbc->query($sql);

	// Elimina los tips asociados al dispositivo		
	$sql="delete from tips where id_ref in ($ID) and tip_type='id_dev'";
   $result = $dbc->query($sql);

	// Elimina las entradas en cfg_remote_alerts2device asociados al dispositivo
	$sql="delete from cfg_remote_alerts2device where target=(Select ip from devices where id_dev in($ID))";
   $result = $dbc->query($sql);

	// Elimina las alertas asociadas al dispositivo de la tabla alerts
	$sql="delete from alerts where id_device in($ID)";
   $result = $dbc->query($sql);

	// Elimina las alertas asociadas al dispositivo de la tabla alerts_store
   $sql="delete from alerts_store where id_device in($ID)";
   $result = $dbc->query($sql);

	// Elimina las entradas en app2device asociados al dispositivo
//   $sql="delete from app2device where id_dev in($ID)";
//   $result = $dbc->query($sql);

//	// Elimina las entradas en cfg_assigned_metrics asociados al dispositivo
//   $sql="delete from cfg_assigned_metrics where range=(SELECT ip from devices where id_dev in($ID))";
//   $result = $dbc->query($sql);


   // Elimina las entradas en prov_template_metrics asociados al dispositivo
   $sql="select id_template_metric from prov_template_metrics where id_dev in($ID)";
   $result = $dbc->query($sql);
	$ids_tm=Array();
   while ($result->fetchInto($r)){ array_push($ids_tm, $r['id_template_metric']);  }
	$IDS=implode (',', $ids_tm);

   // Se borra de prov_template_metric2iid
   $sql="delete from prov_template_metrics2iid where id_template_metric in ($IDS)";
   $result = $dbc->query($sql);

   // Se borra de prov_template_metrics
   $sql="delete from prov_template_metrics where id_template_metric in ($IDS)";
   $result = $dbc->query($sql);


	
	// Elimina las entradas en device2features asociados al dispositivo
   $sql="delete from device2features where id_dev in($ID)";
   $result = $dbc->query($sql);

/*
	// Elimina las entradas en metrics asociados al dispositivo
	$sql="select id_metric from metrics where id_dev in($ID)";
	$result = $dbc->query($sql);
	while ($result->fetchInto($r)){
		$sqlDel="delete from metric2latency where id_metric=".$r['id_metric'];
		$dbc->query($sqlDel);
		$sqlDel="delete from metric2snmp where id_metric=".$r['id_metric'];
      $dbc->query($sqlDel);
		$sqlDel="delete from metric2agent where id_metric=".$r['id_metric'];
      $dbc->query($sqlDel);
	}
   $sql="delete from metrics where id_dev in($ID)";
   $result = $dbc->query($sql);
*/

	// Elimina los tickets del dispositivo
	$sql="DELETE FROM ticket WHERE id_dev IN($ID)";
   $result = $dbc->query($sql);

	// Elimina de prov_default_metrics2device
	$sql="DELETE FROM prov_default_metrics2device WHERE id_dev IN($ID)";
   $result = $dbc->query($sql);

   // Elimina de prov_default_apps2device 
   $sql="DELETE FROM prov_default_apps2device WHERE id_dev IN($ID)";
   $result = $dbc->query($sql);

   // Elimina de cfg_app2device 
   $sql="DELETE FROM cfg_app2device WHERE id_dev IN($ID)";
   $result = $dbc->query($sql);
}

//--------------------------------------------------------------------------
// Function: delete_cfg_notification
// Descripcion: Borra los avisos configurados y los producidos de un determinado tipo.
//--------------------------------------------------------------------------

function delete_cfg_notification($ID){
global $dbc;
   if (! $ID) { return; }

	$sql="delete from cfg_notification2device where id_cfg_notification in ($ID)";
	$result = $dbc->query($sql);
   $sql="delete from cfg_notifications where id_cfg_notification in ($ID)";
	$result = $dbc->query($sql);
	$sql="delete from notifications where id_cfg_notification in ($ID)";
	$result = $dbc->query($sql);
}

//--------------------------------------------------------------------------
// Function: delete_cfg_tasks
// Descripcion: Borra las tareas indicadas
//--------------------------------------------------------------------------
function delete_cfg_tasks($ID){
global $dbc;

	// Se borra la asociacion entre dispositivo y tarea configurada
	$sql="SELECT name FROM cfg_task_configured WHERE id_cfg_task_configured IN ($ID)";
	$result = $dbc->query($sql);

	while ($result->fetchInto($r)){
		$sql="DELETE FROM task2device WHERE name LIKE '{$r['name']}'";
		$dbc->query($sql);

		// Se borra el directorio
		if (file_exists($path)){
			$path="/var/www/html/onm/files/tasks/{$r['name']}/";
			$handle = opendir($path);
	
			for (;false !== ($file = readdir($handle));) if($file != "." && $file != "..") unlink($path.$file);
			closedir($handle);
			rmdir($path);
		}
	}
	// Se borra la tarea configurada de la BBDD
	$sql="DELETE FROM cfg_task_configured WHERE id_cfg_task_configured IN ($ID)";
   $dbc->query($sql);

}

//--------------------------------------------------------------------------
// Function: delete_custom_tasks
// Descripcion: Borra las tareas definidas por usuario indicadas
//--------------------------------------------------------------------------
function delete_custom_tasks($name){
global $dbc;

   // Se borra la asociacion entre dispositivo y tarea configurada
   $sql="SELECT name FROM cfg_task_configured WHERE task LIKE '$name'";
   $result = $dbc->query($sql);

   while ($result->fetchInto($r)){
      $sql="DELETE FROM task2device WHERE name LIKE '{$r['name']}'";
      $dbc->query($sql);

		if (file_exists($path)){
	      // Se borra el directorio
	      $path="/var/www/html/onm/files/tasks/{$r['name']}/";
	      $handle = opendir($path);
	
	      for (;false !== ($file = readdir($handle));) if($file != "." && $file != "..") unlink($path.$file);
	      closedir($handle);
	      rmdir($path);
		}
   }

	// Se borran las tareas configuradas que dependan de la tarea definida
	$sql="DELETE FROM cfg_task_configured WHERE task LIKE '$name'";
   $dbc->query($sql);

	// Se borra el template asociado a la tarea definida
	$sql="SELECT template FROM cfg_task_supported WHERE name LIKE '$name'";
   $result = $dbc->query($sql);
	$result->fetchInto($r);
	unlink($r['template']);
	
   // Se borra la tarea definida por el usuario de la BBDD
   $sql="DELETE FROM cfg_task_supported WHERE name LIKE '$name'";
   $dbc->query($sql);

}

//--------------------------------------------------------------------------
// Function: delete_app
// Descripcion: Borra la aplicacion de la tabla de aplicaciones.
// Solo aplica a xagt_custom
//--------------------------------------------------------------------------
function delete_app ($name){
global $dbc;
   //Elimina la metrica del repositorio
   $sql="delete from cfg_register_apps where name='$name'";
	$result = $dbc->query($sql);
	if (@PEAR::isError($result)){echo 'Store: '.$result->getMessage()."$sql <BR>";  }	
}



//--------------------------------------------------------------------------
// Function: delete_metric_from_repository
// Descripcion: Borra metrica del repositorio de metricas.
// Solo aplica al tipo xagent y subtype=xagt_custom
//--------------------------------------------------------------------------
function delete_metric_from_repository($name,$cid){
global $dbc;

   if (! $name) {
      $msg = 'delete_metric_from_repository::No se ha pasado name';
      $response['rc']  = 1;
      $response['msg'] = $msg;
      CNMUtils::error_log(__FILE__, __LINE__, $msg);
      return $response;
   }
   if (! $cid){
      $msg = 'delete_metric_from_repository::No se ha pasado cid';
      $response['rc']  = 1;
      $response['msg'] = $msg;
      CNMUtils::error_log(__FILE__, __LINE__, $msg);
      return $response;
   }

   //Elimina la metrica del repositorio
   $sql="delete from cfg_monitor_agent where name='$name'";
	$result = $dbc->query($sql);
	if (@PEAR::isError($result)){echo 'Store: '.$result->getMessage()."$sql <BR>";  }

   //Elimina de otras tablas .......
   $sql="select id_metric from metrics where name='$name'";
	$result = $dbc->query($sql);
	if (@PEAR::isError($result)){echo 'Store: '.$result->getMessage()."$sql <BR>";  }
	while ($result->fetchInto($r)){
      $id_metric=$r['id_metric'];
		delete_metrics($id_metric,$cid);
	}
}

//--------------------------------------------------------------------------
// Function: delete_metrics
// Descripcion: Borra las metricas definidas
//--------------------------------------------------------------------------

function delete_metrics($ID,$cid,$do_workset=1){
global $dbc;

   $response  = array('rc'=>'0','msg'=>'Se ha borrado correctamente la métrica','query'=>'');
            //$return['rc']    = 1;
            //$return['msg']   = 'No se ha podido borrar la métrica';
            //$return['query'] = $result['query'];

//RC={$result['rc']}

	if (! $ID) { 
		$response['rc']=1;
		$response['msg']='No se ha borrado ninguna metrica (sin ID)';
		return $response; 
	}
	if (! $cid){
      $response['rc']=1;
      $response['msg']='No se ha borrado ninguna metrica (sin cid)';
      return $response;
	}

	CNMUtils::info_log(__FILE__, __LINE__, "delete_metrics: **1** ID=$ID || CID = $cid");
	
	//Elimina la metrica en cuestion. Actualiza su estado a 3 para que sea eliminada 
	//por notificationsd
	$sql="Update metrics set status=3, refresh=1 where id_metric in ($ID)";
	$result = $dbc->query($sql);
	if (@PEAR::isError($result)){
		$response['msg']=$result->getMessage();
		$response['rc']=$result->getCode();
		CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
	}

   //Elimina las relaciones con las vistas de la metrica en cuestion
   $sql="delete from cfg_views2metrics where id_metric in ($ID)";
	$result = $dbc->query($sql);
	if (@PEAR::isError($result)) {
      $response['msg']=$result->getMessage();
		$response['rc']=$result->getCode();
      CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
   }

   // Se buscan las vistas en las que están dichas métricas y se actualiza el campo nmetrics
   $sql="SELECT DISTINCT(id_cfg_view) AS id_cfg_view FROM cfg_views2metrics WHERE id_metric IN ($ID)";
	$result = $dbc->query($sql);
   while ($result->fetchInto($r)) view_update_nmetrics($r['id_cfg_view'],$cid);

   //Elimina de otras tablas .......
   $sql="select m.id_dev,m.name,m.type,m.subtype,d.ip,m.file,m.id_metric,m.label,d.name as dev_name,d.domain from metrics m, devices d where m.id_dev=d.id_dev and id_metric in ($ID)";
	$result1 = $dbc->query($sql);
   if (@PEAR::isError($result1)) {
      $response['msg']=$result->getMessage();
		$response['rc']=$result->getCode();
      CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
   }

CNMUtils::info_log(__FILE__, __LINE__, "delete_metrics: **2** ID=$ID");

	while ($result1->fetchInto($r)){
		$id_dev=$r['id_dev'];
		$mname=$r['name'];
		$type=$r['type'];
		$subtype=$r['subtype'];
		$ip=$r['ip'];
		$frrd='/opt/data/rrd/elements/'.$r['file'];
		$id_metric=$r['id_metric'];

	   info_qactions('Borrar métrica',$_SESSION['LUSER'],0,"El usuario {$_SESSION['LUSER']} desde la ip {$_SESSION['REMOTE_ADDR']} ha borrado la métrica {$r['label']} del dispositivo {$r['dev_name']}.{$r['domain']} ({$r['ip']}) ID=$ID");

		//print " IDDEV=$id_dev  MNAME=$mname  TYPE=$type  SUBTYPE=$subtype  IP=$ip  FRRD=$frrd  <br>";
      CNMUtils::info_log(__FILE__, __LINE__, "delete_metrics: **DEBUG** id_metric=$id_metric id_dev=$id_dev mname=$mname type=$type subtype=$subtype");
	
		//Elimina de alerts y alerts_store (Los datos del alerts_store ya no son consistentes)
		if (($id_dev) && ($mname)) {

			// Desactiva la metrica de la plantilla del dispositivo
         $sql="UPDATE prov_template_metrics2iid SET status=1 WHERE id_dev=$id_dev AND mname='$mname'";
         $result = $dbc->query($sql);
         if (@PEAR::isError($result)){
            $response['msg']=$result->getMessage();
				$response['rc']=$result->getCode();
            CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
         }

			$sql="delete from alerts where id_device=$id_dev and mname='$mname'";
			$result = $dbc->query($sql);
		   if (@PEAR::isError($result)) {
		      $response['msg']=$result->getMessage();
				$response['rc']=$result->getCode();
      		CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
   		}
			$sql="delete from alerts_store where id_device=$id_dev and mname='$mname'";
			$result = $dbc->query($sql);
         if (@PEAR::isError($result)) {
		      $response['msg']=$result->getMessage();
				$response['rc']=$result->getCode();
      		CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
   		}

			if ($id_metric) {
	         $sql="delete from alerts_read where id_metric=$id_metric";
   	      $result = $dbc->query($sql);
      	   if (@PEAR::isError($result)) {
			      $response['msg']=$result->getMessage();
					$response['rc']=$result->getCode();
      			CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
   			}
			}
		}

//CNMUtils::info_log(__FILE__, __LINE__, "delete_metrics: **3** ID=$ID");

		// ----------------------------------------------------------------------
		// Elimina la info de metric2snmp
		if ($type == 'snmp'){
			# Si el dispositivo en cuestion tiene una alerta de sin respuesta snmp, se borra
			# porque si estuviera causada por esta metrica se quedaria colgada y si fuera
			# otra metrica la causante, ya se vlveria a producir.
         $sql="delete from alerts where id_device=$id_dev and mname='mon_snmp'";
         $result = $dbc->query($sql);
         if (@PEAR::isError($result)){
		      $response['msg']=$result->getMessage();
				$response['rc']=$result->getCode();
      		CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
   		}

			$sql="delete from metric2snmp where id_metric in ($ID)";
			$result = $dbc->query($sql);
         if (@PEAR::isError($result)) {
		      $response['msg']=$result->getMessage();
				$response['rc']=$result->getCode();
      		CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
   		}

			//fml REVISAR !!
	      //Elimina una posible preasignacion de la metrica al dispositivo
	      //delete_assigned_metrics($ip,$subtype);


			if (($id_dev) && ($mname)) {
         	$sql="delete from cnm.work_snmp where cid='$cid' and id_dev=$id_dev and mname='$mname'";
         	$result = $dbc->query($sql);
         	if (@PEAR::isError($result)) {
            	$response['msg']=$result->getMessage();
					$response['rc']=$result->getCode();
            	CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
         	}
			}
		}

		// ----------------------------------------------------------------------
		// Elimina la info de metric2latency
		elseif ($type == 'latency'){
         $sql="delete from metric2latency where id_metric in ($ID)";
			$result = $dbc->query($sql);
         if (@PEAR::isError($result)) {
		      $response['msg']=$result->getMessage();
				$response['rc']=$result->getCode();
      		CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
   		}

	      //Elimina una posible preasignacion de la metrica al dispositivo
   	   //delete_assigned_metrics($ip,$mname);


         if (($id_dev) && ($mname)) {
            $sql="delete from cnm.work_latency where cid='$cid' and id_dev=$id_dev and mname='$mname'";
            $result = $dbc->query($sql);
            if (@PEAR::isError($result)) {
               $response['msg']=$result->getMessage();
					$response['rc']=$result->getCode();
               CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
            }
         }



		}
		// ----------------------------------------------------------------------
      elseif ($type == 'wbem'){
         # Si el dispositivo en cuestion tiene una alerta de sin respuesta snmp, se borra
         # porque si estuviera causada por esta metrica se quedaria colgada y si fuera
         # otra metrica la causante, ya se vlveria a producir.
         $sql="delete from alerts where id_device=$id_dev and mname='mon_wbem'";
         $result = $dbc->query($sql);
         if (@PEAR::isError($result)) {
		      $response['msg']=$result->getMessage();
				$response['rc']=$result->getCode();
      		CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
   		}

		}




		// ----------------------------------------------------------------------
		elseif ($type == 'xagent'){
         if (($id_dev) && ($mname)) {
            $sql="delete from cnm.work_xagent where cid='$cid' and id_dev=$id_dev and mname='$mname'";
            $result = $dbc->query($sql);
            if (@PEAR::isError($result)) {
               $response['msg']=$result->getMessage();
               $response['rc']=$result->getCode();
               CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: error={$response['msg']} rc={$response['rc']} ($sql)");
            }
         }
		}




		//Borra el fichero con los datos rrd
		if (is_file($frrd)) {
			$rc=unlink ($frrd);
			if (! $rc) {   CNMUtils::error_log(__FILE__, __LINE__, "delete_metrics: ERROR al borrar rrd ($frrd)");   }
		}

	}

CNMUtils::info_log(__FILE__, __LINE__, "delete_metrics: **antes de workset** ID=$ID");

   // Se hace el workset para replicar  el contenido de las tablas work_xxx en mdata
	// Por defecto do_workset=1. Si se procesa un bloque de metricas puede ser mejor ponerlo 
	// a 0 y hacer el workset fuera sobre el bloque como proceso externo.
	if ($do_workset) {
      $outputfile='/dev/null';
      $pidfile='/tmp/pid';
  	 	$cmd="/usr/bin/sudo /opt/crawler/bin/workset -c $cid -f  2>&1";
      $user=$_SESSION['LUSER'];
      CNMUtils::debug_log(__FILE__, __LINE__, "delete_metrics: user=$user STATUS=$status CMD=$cmd");
      exec(sprintf("%s > %s 2>&1 & echo $! >> %s", $cmd, $outputfile, $pidfile));
	}

	return $response;
}

//--------------------------------------------------------------------------
// Function: delete_assigned_metrics
// Descripcion: Borra las metricas definidas
//--------------------------------------------------------------------------
function delete_assigned_metrics($ip,$subtype){
global $dbc;
   $sql="delete from cfg_assigned_metrics where id_type='ip' and myrange='$ip' and subtype='$subtype'";

	$result = $dbc->query($sql);
   if (@PEAR::isError($result)){echo 'Store: '.$result->getMessage()."$sql <BR>";  }

}


//--------------------------------------------------------------------------
// Function: delete_views
// Descripcion: Borra las metricas definidas
//--------------------------------------------------------------------------

function delete_views($ID,$cid,$cid_ip){
global $dbc;

   if ((!$ID) or (!$cid) or (!$cid_ip)) {
		return; 
	}


   $sql="SELECT id_cfg_view,name,cid,cid_ip FROM cfg_views WHERE id_cfg_view IN ($ID) AND cid='$cid' AND cid_ip='$cid_ip'";
   $result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      info_qactions('Borrar vista',$_SESSION['LUSER'],0,"El usuario {$_SESSION['LUSER']} desde la ip {$_SESSION['REMOTE_ADDR']} ha borrado la vista {$r['name']} ID={$r['id_cfg_view']} CID=$cid CID_IP=$cid_ip");
   }


   $sql="DELETE FROM cfg_views WHERE id_cfg_view IN ($ID) AND cid='$cid' AND cid_ip='$cid_ip'";
	$result = $dbc->query($sql);
   $sql="DELETE FROM cfg_views2metrics WHERE id_cfg_view IN ($ID)";
	$result = $dbc->query($sql);
   $sql="DELETE FROM cfg_views2views WHERE (id_cfg_view IN ($ID)) OR (id_cfg_subview IN ($ID))";
	$result = $dbc->query($sql);
   $sql="DELETE FROM cfg_user2view WHERE id_cfg_view IN ($ID) AND cid='$cid' AND cid_ip='$cid_ip'";
	$result = $dbc->query($sql);
}

//--------------------------------------------------------------------------
// Function: delete_alert_IP_cfg
// Descripcion: Borra las metricas TC/IP configuradas
// Debe hacer lo siguiente:
//
//	1. Borra la metrica de cfg_monitor
//	2. Borra la metrica de la plantilla de dispositivos
//		(prov_template_metric2iid, prov_template_metrics --> subtype)
//	3. Borra la metrica de los avisos configurados (cfg_notifications-->monitor)
// 4.	Borra las metricas en curso de dicho tipo (metrics)
//		(delete_metrics)
//
//--------------------------------------------------------------------------
function delete_alert_IP_cfg($ID,$cid){
global $dbc;
// Es mejor modificar el parametro y pasar el mname en lugar del id_cfg_monitor
// en datos.php para evitar queries auxiliares

   if (! $ID) {
      $response['rc']=1;
      $response['msg']='delete_alert_IP_cfg::No se ha pasado ID';
      return $response;
   }
   if (! $cid){
      $response['rc']=1;
      $response['msg']='delete_alert_IP_cfg::No se ha pasado cid';
      return $response;
   }


   $sql="SELECT id_cfg_monitor,description from cfg_monitor where id_cfg_monitor in ($ID) and monitor not in ('mon_icmp','disp_icmp')";
   $result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      info_qactions('Borrar métrica(latency)',$_SESSION['LUSER'],0,"El usuario {$_SESSION['LUSER']} desde la ip {$_SESSION['REMOTE_ADDR']} ha borrado la métrica {$r['description']} ID={$r['id_cfg_monitor']}");
   }


   // Obtengo monitor a partir de id_cfg_monitor
	// Nos protegemos de borrar las metricas de disponibilidad ICMP y servicio ICMP
   $sql="select monitor from cfg_monitor where id_cfg_monitor in ($ID) and monitor not in ('mon_icmp','disp_icmp')";
	$result = $dbc->query($sql);
	$monitor=Array();
	while ($result->fetchInto($r)){ 	array_push($monitor,"'".$r['monitor']."'");  }
	if (count($monitor) == 0) { return; }

	$MON = implode(",", $monitor);

//print "MON=$MON  ID=$ID";

	// MON contiene una lista separada por comas del mname de las metricas seleccionadas
	// w_mon_smb-3737576b,w_mon_smb-d563ea3....

	// Se elimina la metrica TCP/IP Configurada de su tabla (cfg_monitor)
	// Nos protegemos de borrar las metricas de disponibilidad ICMP y servicio ICMP
	$sql="delete from cfg_monitor where id_cfg_monitor in ($ID) and monitor not in ('mon_icmp','disp_icmp')";
	$result = $dbc->query($sql);


	// Se borra de prov_template_metric2iid
	$sql="delete from prov_template_metrics2iid where id_template_metric in ( select id_template_metric from prov_template_metrics where subtype in ($MON))";
	$result = $dbc->query($sql);

   // Se borra de prov_template_metrics
   $sql="delete from prov_template_metrics where subtype in ($MON)";
   $result = $dbc->query($sql);

   // Obtengo id_cfg_notification a partir de monitor para eliminarla de los avisos.
   $sql="select id_cfg_notification from cfg_notifications where monitor in ($MON)";
	$result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      $id=$r['id_cfg_notification'];
      delete_cfg_notification($id);
   }


   // Obtengo id_metric a partir del mname ($MON)
   $sql="select id_metric from metrics where name in ($MON)";
   $result = $dbc->query($sql);
   $ids=Array();
   while ($result->fetchInto($r)){  array_push($ids,$r['id_metric']);  }
   $IDMETR = implode(",", $ids);

   delete_metrics($IDMETR,$cid);
}

//--------------------------------------------------------------------------
// Function: delete_monitor
// Descripcion: Borra los monitores configuradas
//--------------------------------------------------------------------------

function delete_monitor($ID){
global $dbc;
   if (! $ID) { return; }

	// Obtengo la clave monitor relativa a los id_alert_types y con ella
	// borro las preasignaciones de monitores a dispositivos concretos
	$sql="select monitor from alert_type where id_alert_type in ($ID)";
	$result1 = $dbc->query($sql);
   while ($result1->fetchInto($r)){
		$monitor=$r['monitor'];

		// Elimina el monitor de la provision de  metricas
		$sql="update prov_template_metrics2iid set watch='0' where watch='$monitor'";
      $result = $dbc->query($sql);

		// Elimina el monitor de las metricas sobre las que estuviera instanciado
		$sql="update metrics set watch='0' where watch='$monitor'";
		$result = $dbc->query($sql);

	   // Elimina las alertas causadas por el monitor (watch) eliminado.
   	$sql="delete from alerts where watch='$monitor%'";
   	$result = $dbc->query($sql);

   }

	// Borro el monitor en cuestion
	$sql="delete from alert_type where id_alert_type in ($ID)";
	$result = $dbc->query($sql);

   // Obtengo id_cfg_notification a partir de id_alert_type
   $sql="select id_cfg_notification from cfg_notifications where id_alert_type in ($ID)";
	$result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      $id=$r['id_cfg_notification'];
      delete_cfg_notification($id);
   }

}


//--------------------------------------------------------------------------
// Function: delete_metrics_wmi
// Descripcion: Borra las metricas WMI definidas por el usuario
//--------------------------------------------------------------------------
function delete_metrics_wmi($ID,$cid){
global $dbc;
   if (! $ID) {
      $response['rc']=1;
      $response['msg']='delete_metrics_wmi::No se ha pasado ID';
      return $response;
   }
   if (! $cid){
      $response['rc']=1;
      $response['msg']='delete_metrics_wmi::No se ha pasado cid';
      return $response;
   }


	$ID_array=explode(',',$ID);
	$ID=implode("','",$ID_array);
	$ID="'$ID'";

   // Borra del repositorio de metricas SNMP la metrica creada por usuario
   $sql="DELETE FROM cfg_monitor_wbem WHERE subtype in ($ID)";
   $result = $dbc->query($sql);

   // Borra las preasignaciones de dicha metrica a dispositivos o familias de dispositivos.
   $sql="DELETE FROM prov_template_metrics WHERE subtype IN ($ID)";
   $result = $dbc->query($sql);

   // Obtengo id_metric a partir de subtype
   $sql="SELECT id_metric FROM metrics WHERE subtype IN ($ID)";
   $result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      $id_metric=$r['id_metric'];
      delete_metrics($id_metric,$cid);
   }
}

//--------------------------------------------------------------------------
// Function: delete_metrics_agent
// Descripcion: Borra las metricas de AGENTE definidas por el usuario
//--------------------------------------------------------------------------
function delete_metrics_agent($ID,$cid){
global $dbc;
   if (! $ID) {
      $response['rc']=1;
      $response['msg']='delete_metrics_agent::No se ha pasado ID';
      return $response;
   }
   if (! $cid){
      $response['rc']=1;
      $response['msg']='delete_metrics_agent::No se ha pasado cid';
      return $response;
   }


	$separador='';
   $ID_array=explode(',',$ID);
   $ID=implode("','",$ID_array);
   $ID="'$ID'";
   // Borra del repositorio de metricas SNMP la metrica creada por usuario
   $sql="DELETE FROM cfg_monitor_agent WHERE subtype in ($ID)";
   $result = $dbc->query($sql);

   // Borra las preasignaciones de dicha metrica a dispositivos o familias de dispositivos.
   $sql="DELETE FROM prov_template_metrics WHERE subtype IN ($ID)";
   $result = $dbc->query($sql);

   // Obtengo id_metric a partir de subtype
   $sql="SELECT id_metric FROM metrics WHERE subtype IN ($ID)";
   $result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      $id_metric=$r['id_metric'];
      delete_metrics($id_metric,$cid);
   }
}

function delete_apps_agent($input){
	global $dbc;
   if (! $input) { return; }
   $array_names=explode(',',$input);
   foreach ($array_names as $name){
		$sql="DELETE FROM cfg_monitor_agent_app WHERE name='$name'";
   	$result = $dbc->query($sql);
		// print $sql;
	}
}

//--------------------------------------------------------------------------
// Function: delete_custom_metrics_snmp()
// Input: subtype de las metricas a borrar, separadas por comas
// Output:
// Descripcion: Borra las metricas SNMP definidas por el usuario
//--------------------------------------------------------------------------
function delete_custom_metrics_snmp($input,$cid){
global $dbc;

   if (! $input) {
      $response['rc']=1;
      $response['msg']='delete_custom_metrics_snmp::No se ha pasado input';
      return $response;
   }
   if (! $cid){
      $response['rc']=1;
      $response['msg']='delete_custom_metrics_snmp::No se ha pasado cid';
      return $response;
   }

	$array_subtypes=array();
	$array_subtypes=explode(',',$input);
	foreach ($array_subtypes as $subtype){


		$sql = "SELECT id_cfg_monitor_snmp,descr AS description FROM cfg_monitor_snmp WHERE subtype='$subtype'";
		$result = $dbc->query($sql);
		while ($result->fetchInto($r)){
			info_qactions('Borrar metrica(snmp)',$_SESSION['LUSER'],0,"El usuario {$_SESSION['LUSER']} desde la ip {$_SESSION['REMOTE_ADDR']} ha borrado la métrica {$r['description']} ID={$r['id_cfg_monitor_snmp']}");
		}


		// Borra del repositorio de metricas SNMP la metrica creada por usuario
		$sql="delete from cfg_monitor_snmp where subtype='$subtype'";
      $result = $dbc->query($sql);



	   $sql="select id_template_metric from prov_template_metrics where subtype='$subtype'";
   	$result = $dbc->query($sql);
   	$ids=Array();
   	while ($result->fetchInto($r)){  array_push($ids,$r['id_template_metric']);  }
   	if (count($ids) != 0) {

	   	$id_template_metric = implode(",", $ids);

			// Borra las preasignaciones de dicha metrica a dispositivos o familias de dispositivos.
   	   //$sql="delete from prov_template_metrics where subtype='$subtype'";
   	   $sql="delete from prov_template_metrics where id_template_metric in ($id_template_metric)";
      	$result = $dbc->query($sql);

         $sql="delete from prov_template_metrics2iid where id_template_metric in ($id_template_metric)";
         $result = $dbc->query($sql);

		}

		// Obtengo id_metric a partir de subtype
      $sql="select id_metric from metrics where subtype='$subtype'";
      $result = $dbc->query($sql);
      while ($result->fetchInto($r)){
         $id_metric=$r['id_metric'];
			// Borra las metricas en curso asociadas a la metrica snmp
         delete_metrics($id_metric,$cid);
      }

      // Borra los posibles monitores asociados a dicha metrica. Notar que solo tiene sentido
      // borrar monitores de metricas que se eliminan del repositorio (son las metricas creadas
      // por el usuario) cuando son metricas definidas por el usuario.
      // Las metricas predefinidas no se pueden eliminar.
      $sql="select id_alert_type from alert_type where subtype='$subtype'";
      $result1 = $dbc->query($sql);
      if ($result1->fetchInto($r)){
         delete_monitor($r['id_alert_type']);
      }
	}
}


//--------------------------------------------------------------------------
// Function: create_custom_metric_snmp_esp
// Descripcion: Crea metricas SNMP especiales (proceso concreto ...)
// definidas por el usuario
// Parametros de entrada
// $NAME: Campo name de la tabla cfg_monitor_snmp_esp (esp_proc_mibhost...)
// $CAD: Cadena que particulariza la metrica (httpd.exe ...)
//--------------------------------------------------------------------------

function create_custom_metric_snmp_esp($NAME,$CAD){
global $dbc;

   $sql="SELECT name,description,oid,class,module,fx,items,vlabel,mode,label,mtype,get_iid,info,iparams,range from cfg_monitor_snmp_esp where name='$NAME'";
   $result = $dbc->query($sql);
   if ($result->fetchInto($r)){
      $name=$r['name'];
      $description=strtoupper($r['description']);
      $oidc=$r['oid'];
      $class=$r['class'];
      $module=$r['module'];
      $fx=$r['fx'];
      $items=$r['items'];
      $vlabel=$r['vlabel'];
      $mode=$r['mode'];
      $label=$r['label'];
      $mtype=$r['mtype'];
      $get_iid=$r['get_iid'];
      $info=$r['info'];
      $iparams=$r['iparams'];
      $range=$r['range'];
   }

	
	$key=$oidc.$CAD.$fx.$iparams;

   $subtype='custom_'. substr (md5($key), 0, 8);

   $label .=" $CAD";
   $description=strtoupper($label);

   // Por ahora solo metricas de lapse=300 sgs.
   $lapse=300;


	// $oidc puede tener diferentes grupos de oids separados por &
	// para el caso de metricas mas complejas.
	$o=explode("&",$oidc);
	// $oid es el primer oid de $oidc. El resto serian parametros de la funcion.
	$oid=array_shift($o);


   // Por ahora module solo es del tipo
   // module:match($COND)
   // Aqui falta la logica que componga expresiones mas complejas.

   // Proteccion para el pattern-matching de las RE
   $cad_ok=str_replace(".","\\\\.",$CAD);
   $cad_ok=str_replace("(","\\\\(",$cad_ok);
   $cad_ok=str_replace(")","\\\\)",$cad_ok);
   $cad_ok=preg_replace("\040+","\\\\s+",$cad_ok);

	array_unshift($o,$cad_ok);	
	$params=implode(";",$o);

   // El primer parametro es la cadena de texto introducida por el usuario
	//	Los restantes parametros por ahora es un nuevo oid para recorrer una segunda tabla.
   $mylogic=$fx.'('.$params.')'.'('.$iparams.')';
   $module_ext=$module.':'.$mylogic;
	$cfg=3;

   $sql="INSERT INTO cfg_monitor_snmp (subtype,lapse,descr,class,oid,oidn,items,label,vlabel,mode,get_iid,mtype,module,oid_info,cfg,range,esp,custom,params)
         VALUES ('$subtype',$lapse,'$description','$class','$oid','$oid','$items','$label','$vlabel','$mode','$get_iid','$mtype','$module_ext', '$info', $cfg, '$range','$NAME',1,'$CAD')
         ON DUPLICATE KEY UPDATE subtype='$subtype', descr='$description', class='$class',
                                 oid='$oid', oidn='$oid', items='$items', label='$label', vlabel='$vlabel' ,mode='$mode',
                                 get_iid='$get_iid', mtype='$mtype', module='$module_ext', oid_info='$info',
											cfg=$cfg, range='$range', esp='$NAME', custom=1, params='$CAD'";


   $result = $dbc->query($sql);
   $rows=$dbc->affectedRows();
   $rc=mysql_errno();
	$rcstr=mysql_error();
	str_replace("\"", "\\\"",$rcstr);
	str_replace("\'", "\\\'",$rcstr);

	return array('rows'=>$rows, 'rc'=>$rc, 'rcstr'=>$rcstr, 'subtype'=>$subtype);

}
function update_custom_metric_snmp_esp($NAME,$CAD,$id_cfg_monitor_snmp){
global $dbc;

   $sql="SELECT name,description,oid,class,module,fx,items,vlabel,mode,label,mtype,get_iid,info,iparams,range from cfg_monitor_snmp_esp where name='$NAME'";
   $result = $dbc->query($sql);
   if ($result->fetchInto($r)){
      $name=$r['name'];
      $description=strtoupper($r['description']);
      $oidc=$r['oid'];
      $class=$r['class'];
      $module=$r['module'];
      $fx=$r['fx'];
      $items=$r['items'];
      $vlabel=$r['vlabel'];
      $mode=$r['mode'];
      $label=$r['label'];
      $mtype=$r['mtype'];
      $get_iid=$r['get_iid'];
      $info=$r['info'];
      $iparams=$r['iparams'];
      $range=$r['range'];
   }


   $key=$oidc.$CAD.$fx.$iparams;

   $subtype='custom_'. substr (md5($key), 0, 8);

   $label .=" $CAD";
   $description=strtoupper($label);

   // Por ahora solo metricas de lapse=300 sgs.
   $lapse=300;


   // $oidc puede tener diferentes grupos de oids separados por &
   // para el caso de metricas mas complejas.
   $o=explode("&",$oidc);
   // $oid es el primer oid de $oidc. El resto serian parametros de la funcion.
   $oid=array_shift($o);


   // Por ahora module solo es del tipo
   // module:match($COND)
   // Aqui falta la logica que componga expresiones mas complejas.

   // Proteccion para el pattern-matching de las RE
   $cad_ok=str_replace(".","\\\\.",$CAD);
   $cad_ok=str_replace("(","\\\\(",$cad_ok);
   $cad_ok=str_replace(")","\\\\)",$cad_ok);
   $cad_ok=preg_replace("\040+","\\\\s+",$cad_ok);

   array_unshift($o,$cad_ok);
   $params=implode(";",$o);

   // El primer parametro es la cadena de texto introducida por el usuario
   // Los restantes parametros por ahora es un nuevo oid para recorrer una segunda tabla.
   $mylogic=$fx.'('.$params.')'.'('.$iparams.')';
   $module_ext=$module.':'.$mylogic;
   $cfg=3;

   $sql="UPDATE cfg_monitor_snmp SET subtype='$subtype', descr='$description', class='$class',
         oid='$oid', oidn='$oid', items='$items', label='$label', vlabel='$vlabel' ,mode='$mode',
         get_iid='$get_iid', mtype='$mtype', module='$module_ext', oid_info='$info',
         cfg=$cfg, range='$range', esp='$NAME', custom=1, params='$CAD' WHERE id_cfg_monitor_snmp=$id_cfg_monitor_snmp";

depura_datos("STORE.PHP-LINEA ".__LINE__," update_custom_metric_snmp_esp $sql");

   $result = $dbc->query($sql);
   $rows=$dbc->affectedRows();
   $rc=mysql_errno();
   $rcstr=mysql_error();
   str_replace("\"", "\\\"",$rcstr);
   str_replace("\'", "\\\'",$rcstr);

   return array('rows'=>$rows, 'rc'=>$rc, 'rcstr'=>$rcstr, 'subtype'=>$subtype);

}

//--------------------------------------------------------------------------
// Function: store_rule_prov2device
// Descripcion:
//    Almacena el xml con las reglas de provision para el dispositivo especificado
// Parametros de entrada:
// $id_dev: El id_dev del dispositivo
// $xml:  	El xml con las reglas. Con un formato de tipo:
// <ruleset>
// 	<rule id="01" field="label" pattern="VoiceEncapPeer" mode="match" action="skip"  />
// 	<rule id="default" action="skip"  />
// </ruleset>
//
//--------------------------------------------------------------------------
function store_rule_prov2device($id_dev,$xml){
global $dbc;

	$RC=0;
   $sql="INSERT INTO rule_prov2device (id_dev,rules)
         VALUES ($id_dev,'$xml')
         ON DUPLICATE KEY UPDATE id_dev=$id_dev, rules='$xml'";

   print $sql."\n";
   $result = $dbc->query($sql);
   if ( (@PEAR::isError($result)) || ( $dbc->affectedRows() == 0) ){ $RC=10; }

   return $RC;

}

//--------------------------------------------------------------------------
// Function: store_prov_watch
// Descripcion: 	
//		Provisiona el watch adecuado sobre el dispositivo especificado en la
//		tabla prov_template_metrics2iid
// Parametros de entrada:
// $watch:	El nombre del monitor
// $id_dev:	El id_dev del dispositivo
//	$label:	El texto (o parte del mismo) que especifica el label de la metrica
//				sobre la que se va a asociar el watch.
//
// IMPORTANTE!!
//	1. Es necesario que la metrica este correctamente provisionada
// 2. Si label es ambiguo puede haber errores
//--------------------------------------------------------------------------
function store_prov_watch($watch,$id_dev,$label){
global $dbc;

	$RC=1000;
	$sql="UPDATE prov_template_metrics2iid
         SET watch='$watch'
         WHERE id_dev=$id_dev and label like '%$label%'";
   print $sql."\n";
	$result = $dbc->query($sql);
   if ( (@PEAR::isError($result)) || ( $dbc->affectedRows() == 0) ){ $RC+=10; }

	// Puede ser que la metrica no este en plantilla. Aplico el monitor
	// directamente sobre la metrica en curso
	if ($RC==1010) {

   	$sql="SELECT id_metric 	FROM metrics WHERE id_dev=$id_dev and label like '%$label%'";
	   // print "$sql";
   	$result = $dbc->query($sql);
   	$result->fetchInto($r);
	   $id_metric=$r['id_metric'];

	   $sql="UPDATE metrics
   	      SET watch='$watch'
      	   WHERE id_metric=$id_metric";
	   //print $sql."\n";
   	$result = $dbc->query($sql);
   	if ( (@PEAR::isError($result)) || ( $dbc->affectedRows() == 0) ){ $RC+=10; }

	}
	return $RC;

}




//--------------------------------------------------------------------------
// Function: store_prov_template_metrics
// Descripcion: Almacena en las tablas de provision:
//		prov_template_metrics  y  prov_template_metrics2iid
//		Permite asociar metricas y monitores (watches) a los diferentes dispositivos.
// Parametros de entrada
// $DATA: Vector con los datos de entrada
//			 (range,id_type,include,lapse,type,subtype,monitor,active_iids)
//
// Array(
//   	[id_type] => 0,  [include] => 1,  [lapse] => 300,  [range] => 10.2.254.71,
//   	[type] => xagent, [subtype] => xagt_000000, [monitor] =>    ,  [id_dest] => 20
// 	[active_iids] => Array ( [1] =>  )
// 	[iids_status] => Array ( [1] => 0 )
// 	[active_iids_str] => Array (  [1] => C:  )
// Para xagent, el indice es hiid
//    [active_iids] => Array ( [c4ca4238a0b923820dcc] =>  )
//    [iids_status] => Array ( [c4ca4238a0b923820dcc] => 0 )
//    [active_iids_str] => Array (  [c4ca4238a0b923820dcc] => C:  )
//--------------------------------------------------------------------------
function store_prov_template_metrics($DATA){
global $dbc;

	$range=$DATA['range'];
	//$id_type=$DATA['id_type'];
	$include=$DATA['include'];
	$lapse=$DATA['lapse'];
	$type=$DATA['type'];
	$subtype=$DATA['subtype'];
	$monitor=$DATA['monitor'];
	$watch=$DATA['monitor'];
	$active_iids=$DATA['active_iids'];
	$active_iids_str=$DATA['active_iids_str'];
	$iids_status=$DATA['iids_status'];
	$id_dest=$DATA['id_dest'];
	/*
   $sql="INSERT INTO cfg_assigned_metrics (range,id_type,include,lapse,type,subtype,monitor,active_iids)
         VALUES ('$range',$id_type,$include,$lapse,'$type','$subtype','$monitor','$active_iids')
         ON DUPLICATE KEY UPDATE range='$range',id_type =$id_type,include =$include, lapse=$lapse,
			type='$type', subtype='$subtype', monitor='$monitor', active_iids='$active_iids'";

	*/

	// OBTENEMOS EL ID_DEV DEL RANGE PROPORCIONADO
	$sql1="SELECT id_dev,name,domain FROM devices WHERE ip='$range'";
	// print "$sql1";
	$result1 = $dbc->query($sql1);
	$result1->fetchInto($r1);

	$sql_12="SELECT name,domain FROM devices WHERE id_dev=$id_dest";
depura_datos("STORE.PHP-LINEA ".__LINE__," $sql_12");

	$result_12 = $dbc->query($sql_12);
   $result_12->fetchInto($r_12);

	$id_dev=$r1['id_dev'];
	// $full_name=$r1['name'];
	// if ($r1['domain']) { $full_name = $r1['name'].'.'.$r1['domain'];  }
	$full_name=$r_12['name'];
	if ($r_12['domain']) { $full_name = $r_12['name'].'.'.$r_12['domain'];  }

	// INSERTAMOS EN prov_template_metrics EL REGISTRO
	$sql2="INSERT INTO prov_template_metrics ( id_dev,lapse,type,subtype,id_dest) VALUES($id_dev,300,'$type','$subtype',$id_dest)";
	$result2 = $dbc->query($sql2);
	// print_r($result2);
	// print $sql2;
   if (@PEAR::isError($result2)) {
	   $sql2="UPDATE prov_template_metrics SET id_dev=$id_dev,lapse=300,type='$type',subtype='$subtype',id_dest=$id_dest WHERE id_dev=$id_dev and subtype='$subtype'";
	 	// print "$sql2";
   	$result2 = $dbc->query($sql2);
   }

	
	// ALMACENAMOS EL id_template_metric que nos interesa
	$sql3="SELECT id_template_metric FROM prov_template_metrics WHERE id_dev=$id_dev and subtype='$subtype' and id_dest=$id_dest";
	//print $sql3;
	$result3 = $dbc->query($sql3);
	if ($result3->fetchInto($r3)){
		$id_template_metric=$r3['id_template_metric'];	
	}else{
		print "ERROR get id_template_metric";
	}
	//print "id_template_metric == $id_template_metric";

	// print "**************$type****************";
	//Se obtienen los datos para generar el label de la metrica
	if ($type=='snmp'){
		$sql4="SELECT descr as label,esp FROM cfg_monitor_snmp WHERE subtype='$subtype'";
	}
	elseif ($type=='latency'){
		$sql4="SELECT description as label FROM cfg_monitor WHERE monitor='$subtype'";
   }
	elseif ($type=='xagent' or $type=='proxy_xagent'){
      $sql4="SELECT description as label FROM cfg_monitor_agent WHERE subtype='$subtype'";
   }
	elseif ($type=='wbem'){
      $sql4="SELECT descr as label FROM cfg_monitor_wbem WHERE subtype='$subtype'";
   }else{
		print "ERROR Tipo no soportado";
	}

	// print $sql4."<br>";
	$result4 = $dbc->query($sql4);
	$result4->fetchInto($r4);
	$label1=$r4['label'];
	$esp=$r4['esp'];

CNMUtils::info_log(__FILE__, __LINE__, "**DEBUG TABLE** esp=$esp label1=$label1");

	// -------------------------------------------------------------
	// Caso TABLE
	// Si se aplica una funcion TABLE, se provisiona una unica metrica, no una por IID
	// ya que su calculo se aplica sobre el conjunto de todos los IIDs
	// -------------------------------------------------------------
	$pos = strpos($esp, 'TABLE');
	if (($pos !== false) && ($pos == 0)) {
      $iid='TABLE';
		$mname=$subtype;
		$label=$label1;
		$hiid=substr(md5($iid), 0, 20);

		// FML. Pensar en los monitores !!! y en el status !!!!!
      //$watch = $active_iids[$n];
      //if ($watch == '') { $watch = 0; }
		$watch = 0;
      //$status = $iids_status[$n];
		$status = 0;

      $label .= " ($full_name)";


      $sql5="INSERT INTO prov_template_metrics2iid ( id_template_metric,iid,label,status,mname,watch,id_dev,id_dest,hiid) VALUES($id_template_metric,'$iid','$label',$status,'$mname','$watch',$id_dev,$id_dest,'$hiid')";
      $result5 = $dbc->query($sql5);
// print_r($result5);
CNMUtils::info_log(__FILE__, __LINE__, "**DB_DEBUG** SQL=$sql5");

      if (@PEAR::isError($result5)) {
         if ($watch != '0') {
            $sql6="UPDATE prov_template_metrics2iid SET id_template_metric=$id_template_metric,iid='$iid',label='$label',status=$status,mname='$mname', watch='$watch', id_dev=$id_dev, id_dest=$id_dest, hiid='$hiid' WHERE id_template_metric=$id_template_metric and iid='$n'";
            $result6 = $dbc->query($sql6);
CNMUtils::info_log(__FILE__, __LINE__, "**DB_DEBUG** SQL=$sql6");
//print_r($dbc);
         }
         else {
            $sql6="UPDATE prov_template_metrics2iid SET id_template_metric=$id_template_metric,iid='$iid',label='$label',status=$status,mname='$mname', id_dev=$id_dev, id_dest=$id_dest, hiid='$hiid' WHERE id_template_metric=$id_template_metric and iid='$n'";
            $result6 = $dbc->query($sql6);
CNMUtils::info_log(__FILE__, __LINE__, "**DB_DEBUG** SQL=$sql6");
//print_r($dbc);
         }
      }


	}
	// -------------------------------------------------------------
	// Caso estandar. Con IIDs
	// -------------------------------------------------------------
	else {	
	 	while (list($n, $txt) = each($active_iids)) {

		// print "N=$n TXT=$txt<br>";	
			if ($type=='snmp') {
				$iid=$n;
				if ($n == 'ALL') {
					$mname=$subtype;
					$label=$label1;
				}
				else {
   	         $mname=$subtype.'-'.$n;
      	      $label=$label1.' '.$active_iids_str[$n];
					// print "MNAME == $mname<br>LABEL == $label";
CNMUtils::info_log(__FILE__, __LINE__, "store_prov_template_metrics:: MNAME = $mname ++ LABEL == $label");
         	}
				$hiid=substr(md5($iid), 0, 20);

	      }
			elseif ($type=='xagent') {
      	   // En este caso hay que utilizar el texto de la instancia, los indices
         	// numericos solo son orientativos.
         	// $h=md5($active_iids_str[$n]);
	         // $hh=substr($h,0,8);
   	      // $mname=$subtype.'-'.$hh;
      	   if ($n == 'ALL') {
         	   $label = $label1;
            	$iid   = 'ALL';
					$mname = $subtype;
	         }
   	      else {
      	      $label = $label1.' '.$active_iids_str[$n];
         	   $iid   = $active_iids_str[$n];
					$mname = $subtype.'-'.substr(md5($active_iids_str[$n]),0,8);
	         }
				// $hiid=$n;
				$hiid=substr(md5($iid), 0, 20);
/*	
      	   // En este caso hay que utilizar el texto de la instancia, los indices
         	// numericos solo son orientativos.
	         // $h=md5($active_iids_str[$n]);

   	      $h=$n;
      	   $hh=substr($h,0,8);
         	$mname=$subtype.'-'.$hh;
	         //if ($n == 'ALL') {
   	      if ($n == substr(md5('ALL'),0,20)) {
      	      $label=$label1;
         	   $iid='ALL';
         	}
	         else {
   	         $label=$label1.' '.$active_iids_str[$n];
      	      $iid=$active_iids_str[$n];
         	}
	         $hiid=$n;
*/
			}
			elseif ($type=='wbem') {
				// En este caso hay que utilizar el texto de la instancia, los indices
				// numericos solo son orientativos.
   			$h=md5($active_iids_str[$n]);
  	 			$hh=substr($h,0,8);
         	$mname=$subtype.'-'.$hh;
				if ($n == 'ALL') {
					$label=$label1;
					$iid=$n;
				}
				else {
					$label=$label1.' '.$active_iids_str[$n];
					$iid=$active_iids_str[$n];
				}
				$hiid=substr(md5($iid), 0, 20);
   	   }
			else {
				$mname=$subtype;
				$label=$label1;
				$iid='ALL';
				$hiid=substr(md5($iid), 0, 20);
			}
			$watch = $active_iids[$n];
			if ($watch == '') { $watch = 0; }
			// print "n==$n<br>";
			//print_r($iids_status);
			$status = $iids_status[$n];
			//print "<br>n==$n status==$status<br>";
			$label .= " ($full_name)";


if ($type=='xagent') $n = $iid;

      	$sql5="INSERT INTO prov_template_metrics2iid ( id_template_metric,iid,label,status,mname,watch,id_dev,id_dest,hiid) VALUES($id_template_metric,'$iid','$label',$status,'$mname','$watch',$id_dev,$id_dest,'$hiid')";
      	$result5 = $dbc->query($sql5);
// print_r($result5);

	      if (@PEAR::isError($result5)) {
				if ($watch != '0') {
	   	      $sql6="UPDATE prov_template_metrics2iid SET id_template_metric=$id_template_metric,iid='$iid',label='$label',status=$status,mname='$mname', watch='$watch', id_dev=$id_dev, id_dest=$id_dest, hiid='$hiid' WHERE id_template_metric=$id_template_metric and iid='$n'";
					$result6 = $dbc->query($sql6);
//print_r($dbc);
				}
				else {
      	      $sql6="UPDATE prov_template_metrics2iid SET id_template_metric=$id_template_metric,iid='$iid',label='$label',status=$status,mname='$mname', id_dev=$id_dev, id_dest=$id_dest, hiid='$hiid' WHERE id_template_metric=$id_template_metric and iid='$n'";
					$result6 = $dbc->query($sql6);
//print_r($dbc);
         	}
      	}
	 		//print "(W=$watch)  $sql5<br><br><br>";
   	}
	}

   $rows=$dbc->affectedRows();
   $rc=mysql_errno();
   $rcstr=mysql_error();
   str_replace("\"", "\\\"",$rcstr);
   str_replace("\'", "\\\'",$rcstr);

   return array('rows'=>$rows,'rc'=>$rc,'rcstr'=>$rcstr);

}


//--------------------------------------------------------------------------
// Function: get_monitor
// Descripcion: Crea o actualiza un monitor
// Parametros de entrada
// $DATA: Vector con los datos de entrada
//        (expr,mname o id_alert_type)
// OUT:
//    RC	=	0	=> Existe
//    RC != 0 	=> No existe
//--------------------------------------------------------------------------
function get_monitor($DATA){
global $dbc;

	$RES=Array();
   $sql="SELECT id_alert_type,cause,monitor,expr,params,severity,mname,type,subtype FROM alert_type WHERE mname = '$DATA[mname]' AND expr = '$DATA[expr]'";
   $result = $dbc->query($sql);
   if ($result->fetchInto($r)) {
      $RES['id_alert_type']=$r['id_alert_type'];
      $RES['cause']=$r['cause'];
      $RES['monitor']=$r['monitor'];
      $RES['expr']=$r['expr'];
      $RES['params']=$r['params'];
      $RES['severity']=$r['severity'];
      $RES['mname']=$r['mname'];
      $RES['type']=$r['type'];
      $RES['subtype']=$r['subtype'];
   }

	return $RES;

}



//--------------------------------------------------------------------------
// Function: store_monitor
// Descripcion: Crea o actualiza un monitor
// Parametros de entrada
// $DATA: Vector con los datos de entrada
//        (cause,monitor,expr,mname,mtype,subtype,severity)
//		Si en los datos de entrada existe $DATA['monitor'] ==> Modificamos
//		monitor. En caso contrario se actualiza.
// OUT:
// 	RC=1 => OK (Creado)
//		RC=2 => OK (Modificado)
//		RC=3 => NOK (Al modificar)
//--------------------------------------------------------------------------
function store_monitor($DATA,&$monitor,&$id){
global $dbc;

//   $cause=$DATA['cause'];
//   $monitor=$DATA['monitor'];
//   $expr=$DATA['expr'];
//   $mname=$DATA['mname'];
//   $metric_type=$DATA['mtype'];
//   $subtype=$DATA['subtype'];
//   $severity=$DATA['severity'];


	// Se genera un nombre unico para el monitor al crearlo. Al modificarlo se
	// mantiene el nombre por evitar problemas una vez asociado dicho monitor.

	// Si existe el valor de $DATA['monitor'] ==> Modifico el valor/es de dicho monitor
	if ($DATA['monitor']) {

      $sql="UPDATE alert_type set  cause='$DATA[cause]',
                                   expr='$DATA[expr]',
                                   mname='$DATA[mname]',
                                   type='$DATA[mtype]',
                                   subtype='$DATA[subtype]',
                                   severity='$DATA[severity]'
                                   where monitor = '$DATA[monitor]'";

      // print ("SQL UPDATE =>$sql<br>");
      $result = $dbc->query($sql);
      if (@PEAR::isError($result)) { $RC=3; }
      else{ $RC=2; }
	}
	// Estoy creando un nuevo monitor
	else {
	   $h=md5(time());
   	$hh=substr($h,1,8);
   	$DATA['monitor']='s_'.$DATA['mname']."-$hh";

   	$sql="INSERT INTO alert_type (cause,monitor,expr,mname,type,subtype,severity)";
   	$sql.=" Values (  '".$DATA['cause']."',
      	               '".$DATA['monitor']."',
         	            '".$DATA['expr']."',
            	         '".$DATA['mname']."',
               	      '".$DATA['mtype']."',
                  	   '".$DATA['subtype']."',
                     	 ".$DATA['severity'].')';

	   // print ("SQL INSERT =>$sql<br>");
   	$result = $dbc->query($sql);
//   	if (@PEAR::isError($result)) {
//
//      	$sql="UPDATE alert_type set  cause='$DATA[cause]',
//         	                          expr='$DATA[expr]',
//            	                       mname='$DATA[mname]',
//               	                    type='$DATA[mtype]',
//                  	                 subtype='$DATA[subtype]',
//                     	              severity='$DATA[severity]'
//                        	           where mname = '$DATA[mname]' AND expr = '$DATA[expr]'";
//	      // print ("SQL UPDATE =>$sql<br>");
//   	   $result = $dbc->query($sql);
//      	if (@PEAR::isError($result)) { $RC=3; }
//      	else{ $RC=2; }
//  		}

		if (@PEAR::isError($result)) { $RC=4; }
		else{ $RC=1; }
	}

	$RES=get_monitor($DATA,$monitor,$id);
	$monitor=$RES['monitor'];
	$id=$RES['id_alert_type'];

	return $RC;


}


//--------------------------------------------------------------------------
// Function: store_device
// Descripcion: Almacena un dispositivo
// Parametros de entrada
// $DATA: Vector con los datos de entrada
// (id_dev,name,domain,ip,sysloc,sysdesc,sysoid,txml,type,app,status,mode,community,version)
// + campos de usuario
// El id_dev es un valor de retorno.
//--------------------------------------------------------------------------
function store_device($DATA){
global $dbc;

   $name=$DATA['name'];
   $domain=$DATA['domain'];
   $ip=$DATA['ip'];
   $sysloc=$DATA['sysloc'];
   $sysdesc=$DATA['sysdesc'];
   $sysoid=$DATA['sysoid'];
   $type=$DATA['type'];
   $community=$DATA['community'];
   $version=$DATA['version'];
			
   $sql="INSERT INTO devices (name,domain,ip,sysloc,sysdesc,sysoid,type,community,version)
         VALUES ('$name','$domain','$ip','$sysloc','$sysdesc','$sysoid','$type','$community','$version')
         ON DUPLICATE KEY UPDATE name='$name', domain='$domain',ip='$ip',sysloc='$sysloc',sysdesc='$sysdesc',sysoid='$sysoid',type='$type',community='$community',version='$version'";
			
   $sql2="SELECT id_dev FROM devices WHERE name='$name' and domain='$domain' and ip='$ip'";

   $result = $dbc->query($sql);
   $rows=$dbc->affectedRows();
   $rc=mysql_errno();
   $rcstr=mysql_error();
   str_replace("\"", "\\\"",$rcstr);
   str_replace("\'", "\\\'",$rcstr);

   $response=array('rows'=>$rows,'rc'=>$rc,'rcstr'=>$rcstr);

   $result2 = $dbc->query($sql2);
   while ($result2->fetchInto($r)){ $response['id_dev']=$r['id_dev']; }

   //Hay que asignarlo por defecto al perfil organizativo global
	$sql="SELECT id_cfg_op FROM cfg_organizational_profile WHERE descr='Global'";
   $result = $dbc->query($sql);
   while ($result->fetchInto($r)){ $id_cfg_op=$r['id_cfg_op']; }

	$id_dev=$response['id_dev'];
   $sql="INSERT INTO cfg_devices2organizational_profile (id_dev,id_cfg_op)
         VALUES ($id_dev,$id_cfg_op)
         ON DUPLICATE KEY UPDATE id_cfg_op=$id_cfg_op, id_dev=$id_dev";
	$result = $dbc->query($sql);
//print "SQL=$sql\n";
   return $response;
}

//--------------------------------------------------------------------------
// Function: store_device_custom
// Descripcion: Almacena los datos de usuario de n dispositivo
// Parametros de entrada
// $DATA: Vector con los datos de entrada
// campos de usuario para poner en columna0, columnax .....
//--------------------------------------------------------------------------
function store_device_custom($id_dev,$DATA){
global $dbc;

   $name=$DATA['name'];
   $version=$DATA['version'];

	$f=array();
	$v=array();
	$fv=array();
	foreach($DATA as $key => $value) {
		array_push($f, $key);
		array_push($v, "'$value'");
		array_push($fv, "$key='$value'");
	}

	$campos = implode(",", $f);
	$valores= implode(",", $v);
	$campos_valores = implode(",", $fv);

   $sql="INSERT INTO devices_custom_data (id_dev,$campos)
         VALUES ($id_dev,$valores)
         ON DUPLICATE KEY UPDATE id_dev=$id_dev,$campos_valores";

//print "SQL=$sql\n";

   $result = $dbc->query($sql);
   $rows=$dbc->affectedRows();
   $rc=mysql_errno();
   $rcstr=mysql_error();
   str_replace("\"", "\\\"",$rcstr);
   str_replace("\'", "\\\'",$rcstr);

   $response=array('rows'=>$rows,'rc'=>$rc,'rcstr'=>$rcstr);

   return $response;
}

//--------------------------------------------------------------------------
// Function: store_cfg_metric_latency
// Descripcion: Almacena una metrica TCP/IP configurada
// Parametros de entrada
// $DATA: Vector con los datos de entrada
//        (description,monitor,params,severity,subtype)
//        OJO: params depende del tipo de metrica (subtype) p1=v1|p2=v2...
//  		 monitor se genera internamente en base al subtype + params
//--------------------------------------------------------------------------
function store_cfg_metric_latency($DATA){
global $dbc;

   $description=$DATA['description'];
   $params=$DATA['params'];
   $severity=$DATA['severity'];
   $subtype=$DATA['subtype'];
   $info=$DATA['info'];


	//w_mon_ssh-f1282942
   $monitor='w_'.$subtype.'-'.substr (md5($params), 1, 8);


   $sql="INSERT INTO cfg_monitor (description,monitor,params,severity,subtype,info)
         VALUES ('$description','$monitor','$params',$severity,'$subtype','$info')";


//print "$sql\n";


   $result = $dbc->query($sql);
   $rows=$dbc->affectedRows();
   $rc=mysql_errno();
   $rcstr=mysql_error();
   str_replace("\"", "\\\"",$rcstr);
   str_replace("\'", "\\\'",$rcstr);

   $response=array('rows'=>$rows,'rc'=>$rc,'rcstr'=>$rcstr,'monitor'=>$monitor);

	return $response;

}

//--------------------------------------------------------------------------
// Function: store_metric_snmp_custom
// Descripcion: Almacena una metrica SNMP creada por usuario
// Parametros de entrada
// $DATA: Vector con los datos de entrada
//        (range,id_type,include,lapse,type,subtype,monitor,active_iids)
// $RESULT: Vector con la salida
//--------------------------------------------------------------------------
function store_metric_snmp_custom ($DATA) {
global $dbc;

	$RESULT = array('rc'=>0 , 'rcstr'=>'OK' );
   $subtype='custom_'. substr (md5($DATA['oid']), 0, 8);
	// Por ahora solo metricas de lapse=300 sgs.
   $lapse=300;
   $oid=preg_replace("/\s*\n/", "|" ,$DATA['oid']);
   $items=preg_replace("/\s*\n/", "|" , $DATA['items']);
   $oidn=$oid;

   $descr=strtoupper($DATA['descr']);
   $class=$DATA['class'];
   $label=$DATA['label'];
   $vlabel=$DATA['vlabel'];
   $mode=$DATA['mode'];
   $mtype='STD_BASE';
   $info='-|-|OID creado por el usuario|';
	$get_iid=$DATA['get_iid'];

   $sql="INSERT INTO cfg_monitor_snmp (subtype,lapse,descr,class,oid,oidn,items,label,vlabel,mode,get_iid,mtype,oid_info)
         VALUES ('$subtype',$lapse,'$descr','$class','$oid','$oidn','$items','$label','$vlabel','$mode','$get_iid','$mtype','$info')
         ON DUPLICATE KEY UPDATE subtype='$subtype', descr='$descr', class='$class',
                                 oid='$oid', oidn='$oidn', items='$items', label='$label',
                                 vlabel='$vlabel' ,mode='$mode', get_iid='$get_iid', mtype='$mtype', oid_info='$info'";
   $result = $dbc->query($sql);
   $rows = $dbc->affectedRows();
   $RESULT['rc']=mysql_errno();

   if ($RESULT['rc']) {
      $rcstr=mysql_error();
      $RESULT['rcstr']=$rcstr;
 	}
   elseif ($rows == 1){ $RESULT['rcstr']="Nueva M&eacute;trica SNMP generada."; }
   elseif ($rows == 2){ $RESULT['rcstr']="M&eacute;trica SNMP actualizada."; }

	return $RESULT;
}


//--------------------------------------------------------------------------
// Function: store_view
// Descripcion: Almacena una vista
// Parametros de entrada
// $DATA: Vector con los datos de entrada
//        (name)
// $RESULT: Vector con la salida
//--------------------------------------------------------------------------
function store_view ($DATA) {
global $dbc;

   $RESULT = array('rc'=>0 , 'rcstr'=>'OK' );

   $name=$DATA['name'];
   $sql="INSERT INTO cfg_views (name)
         VALUES ('$name')
         ON DUPLICATE KEY UPDATE name='$name'";

   $result = $dbc->query($sql);
   $rows = $dbc->affectedRows();
   $RESULT['rc']=mysql_errno();

   if ($RESULT['rc']) {
      $rcstr=mysql_error();
      $RESULT['rcstr']=$rcstr;
   }
   elseif ($rows == 1){ $RESULT['rcstr']="Nueva Vista  generada."; }
   elseif ($rows == 2){ $RESULT['rcstr']="Vista actualizada."; }

   $sql="SELECT id_cfg_view FROM cfg_views WHERE name='$name'";
   $result = $dbc->query($sql);
   while ($result->fetchInto($r)){ $RESULT['id_cfg_view'] = $r['id_cfg_view']; }

   return $RESULT;
}



//--------------------------------------------------------------------------
// Function: store_view2metrics
// Descripcion: Almacena las metricas asociadas a una vista
// Parametros de entrada
// $DATA: Vector con los datos de entrada
//        (id_device,id_metric,id_cfg_view)
// $RESULT: Vector con la salida
//--------------------------------------------------------------------------
function store_view2metrics($DATA) {
global $dbc;

   $RESULT = array('rc'=>0 , 'rcstr'=>'OK' );

   $id_cfg_view=$DATA['id_cfg_view'];
   $id_metric=$DATA['id_metric'];
   $id_device=$DATA['id_device'];
   $sql="INSERT INTO cfg_views2metrics (id_cfg_view,id_metric,id_device)
         VALUES ($id_cfg_view,$id_metric,$id_device)
         ON DUPLICATE KEY UPDATE id_cfg_view=$id_cfg_view, id_metric=$id_metric, id_device=$id_device";

//print "SQL=$sql\n";
   $result = $dbc->query($sql);
   $rows = $dbc->affectedRows();
   $RESULT['rc']=mysql_errno();

   if ($RESULT['rc']) {
      $rcstr=mysql_error();
      $RESULT['rcstr']=$rcstr;
   }
   elseif ($rows == 1){ $RESULT['rcstr']="Metrica en vista generada."; }
   elseif ($rows == 2){ $RESULT['rcstr']="Metrica en vista actualizada."; }

   return $RESULT;
}


//--------------------------------------------------------------------------
// Function: get_devices
// Descripcion: Busca los dispositivos que cumplan los criterios fijados por
// nombre, ip, dominio, tipo o por id_dev
//--------------------------------------------------------------------------

function get_devices($Name,$Dominio,$IP,$Tipo,$ID, &$res_id, &$res_name, &$res_ip, &$res_type,$ORGPRO) {
global $dbc;

	if ( (! $Name) && (! $Dominio) && (! $IP) && (! $Tipo) && (! $ID) ) { return; }

	$cont=0;
	$aCOND=array();
	if ($Name) { array_push ($aCOND, "d.name like '".str_replace ( "*", "%", $Name)."'");  }
	if ($Dominio) { array_push ($aCOND, "d.domain like '".str_replace ( "*", "%", $Dominio)."'");  }
	if ($IP) { array_push ($aCOND, "d.ip like '".str_replace ( "*", "%", $IP)."'");  }
	if ($Tipo) { array_push ($aCOND, "d.type like '".str_replace ( "*", "%", $Tipo)."'");  }
	if ($ID) { array_push ($aCOND, "d.id_dev in ($ID)");  }

	$where= "WHERE ".join (' or ', $aCOND);

	// INTRODUCIMOS LA FUNCIONALIDAD DE GRUPOS ORGANIZATIVOS
   // $where.=" AND d.id_dev=o.id_dev AND o.id_cfg_op IN (".$_SESSION['ORGPRO'].")";
	$where.=" AND d.id_dev=o.id_dev AND o.id_cfg_op IN ($ORGPRO)";
	$where.=" GROUP BY d.id_dev";
   //$sql="select count(*) as cuantos from devices $where";
	
	// SE OBTIENE EL NUMERO DE DISPOSITIVOS ENCONTRADOS
	/*
	$sql="SELECT count(DISTINCT d.id_dev) AS cuantos
         FROM devices d,cfg_devices2organizational_profile o ".$where;
	
	// print "sql es $sql<br>";

	
	$result = $dbc->query($sql);
	if ($result->fetchInto($r)){
		$cont=$r['cuantos'];
	}
	*/

	$aID=array();
	$aNAME_FULL=array();
	$aIP=array();
	$aTYPE=array();
//   $sql="select id_dev as indice,name as dispo,domain,type,ip from devices $where";

   $sql="SELECT d.id_dev as indice,d.name as dispo,d.domain,d.type,d.ip, d.community
         FROM devices d,cfg_devices2organizational_profile o $where order by d.name";

	$result = $dbc->query($sql);
   while ($result->fetchInto($r)){
		array_push ($aID, "'".$r['indice']."'");
		array_push ($aNAME_FULL, "'".$r['dispo'].".".$r['domain']."'");
		array_push ($aIP, "'".$r['ip']."'");
		array_push ($aTYPE, "'".$r['type']."'");
	}

	$res_id = join (",", $aID);
	$res_name = join (",", $aNAME_FULL);
	$res_ip = join (",", $aIP);
	$res_type = join (",", $aTYPE);
}



//--------------------------------------------------------------------------
// Function: get_devices_in_red
// Descripcion: Obtiene todos los dispositivos con alerta.
//--------------------------------------------------------------------------
function get_devices_in_red(){
global $dbc;
	$devices_in_red=array();
	$sql="SELECT DISTINCT id_device
			FROM alerts
			WHERE counter>0";
	$total=0;
	$result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      $devices_in_red[$r['id_device']]=1;
   }

	return $devices_in_red;
}
//--------------------------------------------------------------------------
// Function: get_devices_in_red_by_host_idx
// Descripcion: Obtiene todos los dispositivos con alerta agrupados por host_idx.
//--------------------------------------------------------------------------
function get_devices_in_red_by_host_idx(){
global $dbc;
   $devices_in_red=array();
   $sql="SELECT d.host_idx,count(distinct a.id_device) as cuantos
			FROM alerts a,devices d
			WHERE a.id_device=d.id_dev and a.counter>0
			GROUP by d.host_idx";
   $total=0;
   $result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      $devices_in_red[$r['host_idx']]=$r['cuantos'];
   }

   return $devices_in_red;
}
//--------------------------------------------------------------------------
// Function: get_devices_in_red_by_domain
// Descripcion: Obtiene todos los dispositivos con alerta agrupados por dominio
//--------------------------------------------------------------------------
function get_devices_in_red_by_domain(){
global $dbc;
   $devices_in_red=array();
   $sql="SELECT d.domain,count(distinct a.id_device) as cuantos
         FROM alerts a,devices d
         WHERE a.id_device=d.id_dev and a.counter>0
         GROUP by d.domain";
   $total=0;
   $result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      $devices_in_red[$r['domain']]=$r['cuantos'];
   }

   return $devices_in_red;
}

//--------------------------------------------------------------------------
// Function: get_devices_in_red_by_org_pro
// Descripcion: Obtiene todos los dispositivos con alerta agrupados por perfil organizativo
//--------------------------------------------------------------------------
function get_devices_in_red_by_org_pro(){
global $dbc;
   $devices_in_red=array();
   $sql="SELECT c.id_cfg_op,count(distinct c.id_dev) as cuantos
         FROM alerts a,devices d,cfg_devices2organizational_profile c
         WHERE a.id_device=d.id_dev and a.counter>0 and c.id_dev=a.id_device
         GROUP by c.id_cfg_op";

   $total=0;
   $result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      $devices_in_red[$r['id_cfg_op']]=$r['cuantos'];
   }
	return $devices_in_red;
}

//--------------------------------------------------------------------------
// Function: get_devices_in_red_by_type
// Descripcion: Obtiene todos los dispositivos con alerta agrupados por tipo.
//--------------------------------------------------------------------------
function get_devices_in_red_by_type(){
global $dbc;
   $devices_in_red=array();
   $sql="select d.type,count(distinct a.id_device) as cuantos from alerts a,devices d where a.id_device=d.id_dev and a.counter>0 group by d.type";
	$total=0;
	$result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      $devices_in_red[$r['type']]=$r['cuantos'];
   }

   return $devices_in_red;
}

//--------------------------------------------------------------------------
// Function: get_devices_in_red_by_status
// Descripcion: Obtiene todos los dispositivos con alerta agrupados por status.
//--------------------------------------------------------------------------
function get_devices_in_red_by_status(){
global $dbc;
   $devices_in_red=array();
   $sql="select d.status,count(distinct a.id_device) as cuantos from alerts a,devices d where a.id_device=d.id_dev and a.counter>0 group by d.status";
	$total=0;
	$result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      $devices_in_red[$r['status']]=$r['cuantos'];
   }

   return $devices_in_red;
}


//--------------------------------------------------------------------------
// Function: get_devices_in_red_by_model
// Descripcion: Obtiene todos los dispositivos con alerta agrupados por modelo.
//--------------------------------------------------------------------------
function get_devices_in_red_by_model(){
global $dbc;
   $devices_in_red=array();
   $sql="select d.sysoid,count(distinct a.id_device) as cuantos from alerts a,devices d where a.id_device=d.id_dev and a.counter>0 group by d.sysoid";
	$total=0;
	$result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      $devices_in_red[$r['sysoid']]=$r['cuantos'];
   }

   return $devices_in_red;
}



//-------------------------------------------------------------------------------------
// Function: get_devices_in_red_by_defined_field
// Descripcion: Obtiene todos los $fields con alerta agrupados por el campo de usuario.
//-------------------------------------------------------------------------------------
function get_devices_in_red_by_defined_field($field){
global $dbc;
   $devices_in_red=array();
//	$sql="SELECT $field AS in_red
//			FROM alerts a,devices_custom_data c
//			WHERE a.id_device=c.id_dev and a.counter>0 group by $field";

	$sql="SELECT d.$field as col, count(distinct a.id_device) as cuantos
			FROM alerts a,devices_custom_data d
			WHERE a.id_device=d.id_dev and a.counter>0 group by $field";

	// print "$sql<br>";
   $total=0;
   $result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      $devices_in_red[$r['col']]=$r['cuantos'];
   }

   return $devices_in_red;
}

//--------------------------------------------------------------------------
// Function: get_views_in_red
// Descripcion: Obtiene todas las vistas con alerta.
// OUT: Es un hash con Keys=id_cfg_view  Values=Severity
//--------------------------------------------------------------------------
//function get_views_in_red(){
function get_views_in_red($ID){
global $dbc;


   $views_in_red=array();

	//-----------------------------------------------------------------------
   //MNAME con relacion 1 a 1
   $views_in_red=array();
   //$sql="select distinct id_cfg_view from cfg_views2metrics where id_metric in (select m.id_metric from alerts a, metrics m where a.id_device=m.id_dev and a.mname=m.name and a.counter>1)";

	//MUCHO+ EFICIENTE !!!!
	$result = $dbc->query("DROP table tv");
	$result = $dbc->query("CREATE temporary table tv select m.id_metric,a.severity from alerts a, metrics m where a.id_device=m.id_dev and a.mname=m.name and a.counter>1");
// $sql="select distinct c.id_cfg_view,t.severity from cfg_views2metrics c, tv t where c.id_metric=t.id_metric";
	//if ($ID==1){
	//A los usuarios de perfil aministrador, les dejamos ver todas las vistas
	if ( ($_SESSION['PERFIL']==1) || ($_SESSION['PERFIL']==16))  {
		$sql="select distinct c.id_cfg_view,t.severity from cfg_views2metrics c, tv t where c.id_metric=t.id_metric";
	}else{
		$sql="select distinct c.id_cfg_view,t.severity from cfg_views2metrics c, cfg_user2view u, tv t where c.id_metric=t.id_metric and u.id_cfg_view=c.id_cfg_view and u.id_user=$ID";
	}
	$total=0;
	$result = $dbc->query($sql);
//print $sql;
	while ($result->fetchInto($r)){
      $id=$r['id_cfg_view'];
		if (array_key_exists($id, $views_in_red)) {
			if ( $views_in_red["$id"] > $r['severity']) { $views_in_red["$id"]=$r['severity']; }
		}
		else { $views_in_red["$id"]=$r['severity']; }
   }

   //-----------------------------------------------------------------------
   // MNAME=mon_snmp, mon_wbem, mon_icmp/disp_icmp. (relacion 1 a N).
   // mon_snmp y mon_wbem  no son nombres de metrica en metrics por lo que no existe y no acumula.
   // mon_icmp si es nombre de metrica en metrics por lo que si existe y si acumula ==> uso hash


	// Esta query se hace aparte porque es mucho mas eficiente que utilizar
	// el subselect.
   $sql="select m.id_metric from alerts a, metrics m where a.id_device = m.id_dev and m.name=a.mname and counter>1 and (mname='mon_snmp' or mname='mon_wbem' or  name like '%_icmp' )";
   $result = $dbc->query($sql);

	$idm=Array();
   while ($result->fetchInto($r)){ array_push ($idm, $r['id_metric']); }
	$idm_comma = join(",", $idm);

	// Si no hay ningun valor en esta situacion uso id_metric=0.
	if (count($idm) == 0) {  $idm_comma1=0;  }	
	else {

		// Este subselect es necesario porque puede ocurrir que exista la alerta asociada a una metrica de
		// servicio icmp pero en la vista lo que se se haya incluido sea una metrica de disponibilidad icmp.
	   $sql="select id_metric from metrics where name like '%_icmp' and id_dev in (select id_dev from metrics where id_metric in ($idm_comma))";
   	$result = $dbc->query($sql);
   	$idm1=Array();
   	while ($result->fetchInto($r)){ array_push ($idm1, $r['id_metric']); }
   	$idm_comma1 = join(",", $idm1);
		if (count($idm1) == 0) {  $idm_comma1=0;  }
	}

   //if ($ID==1) {
	//A los usuarios de perfil aministrador, les dejamos ver todas las vistas
	if ( ($_SESSION['PERFIL']==1) || ($_SESSION['PERFIL']==16))  {
      $sql=" select distinct c.id_cfg_view from cfg_views2metrics c where id_metric in ($idm_comma1) ";
   }

   else {
      $sql=" select distinct c.id_cfg_view from cfg_views2metrics c, cfg_user2view u where u.id_cfg_view=c.id_cfg_view and u.id_user=$ID and id_metric in ($idm_comma1)";
   }

	//print "SQL=$sql";
   $result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      $id=$r['id_cfg_view'];
      $views_in_red["$id"]=1;
   }

	return $views_in_red;

}


//--------------------------------------------------------------------------
// Function: get_devices_custom_info
// Descripcion: Obtiene los datos relativos a los campos de dispositivos
// definidos por el usuario
// Parametros de IN/OUT (3 arrays):
//   1. Contiene el nombre de las columnas incorporadas a la tabla devices
//		  (colummna1, columna2 .....)
//   2. Contiene la descripcion de dichas columnas
//   3. Contiene el id + la descripcion de dichas columnas (Necesario para
//			provisionar en bloque
//--------------------------------------------------------------------------
function get_devices_custom_info(&$label_in_select,&$label_in_title,&$label_in_title_id){
global $dbc;
   // Miro los campos definidos por el usuario
   $sql="select id,descr from devices_custom_types";
   $label_in_select=array();
   $label_in_title=array();
	$result = $dbc->query($sql);
   while ($result->fetchInto($r)){
      array_push($label_in_select,'columna'.$r['id']);
      array_push($label_in_title,strtoupper($r['descr']));
      //array_push($label_in_title_id,$r['id'].'.'.strtoupper($r['descr']));
      array_push($label_in_title_id,'_'.strtoupper($r['descr']));
   }
}


//--------------------------------------------------------------------------
// Function: get_from_db
// Descripcion: Realiza una consulta a la BD
//--------------------------------------------------------------------------
function get_from_db($sql){
global $dbc;

//print "SQL=$sql\n";
   $result = $dbc->query($sql);
	$result->fetchInto($r);
	//return $r;
	$data=Array();
   while ($result->fetchInto($r)) { array_push($data,$r['id_dev']);  }
   return $data;
}



//--------------------------------------------------------------------------
// Funcion que escribe en el fichero que permite el reload de trap_manager
//--------------------------------------------------------------------------
function reload_trap_manager(){

	$RELOAD_FILE='/var/www/html/onm/tmp/syslog.reload';
   $fp = fopen ($RELOAD_FILE,"a");
   fwrite($fp,'1');
   fclose($fp);
	return 0;

//fml parche
//AL ejecutar en paralelo se come la cpu
//return 0;

	$rc=0;
   $results=Array();
   $cmd="/usr/bin/sudo /etc/init.d/syslog-ng reload 2>&1";
   exec($cmd,$results);

	//OK si devuelve ==> Reload system logging: syslog-ng.
	$pattern = '/Reload system logging: syslog-ng/';
	if (! preg_match($pattern, $results[0])) {
		foreach ($results as $res){
			CNMUtils::error_log(__FILE__, __LINE__, "**ERROR** $res");
		}
		$rc=1;
	}

	CNMUtils::info_log(__FILE__, __LINE__, "(RC=$rc) $results[0]");
	return $rc;
}


/////////////////////////////////////////////////////////////////////
// Function set_device_record ()                                   //
// INPUT: $ip                                                      //
// OUTPUT: 0 => OK                                                 //
//         1 => NO OK                                              //
//Function que inserta en BBDD la ficha del dispositivo con IP $ip //
/////////////////////////////////////////////////////////////////////

function set_device_record ($ip){
global $dbc;

$descripcion='';
   // 1. Obtener los campos basicos del dispositivo
   $sql1="SELECT id_dev,name,domain,type,community,status,mac,mac_vendor,critic,wsize FROM devices WHERE ip='$ip'";
	// print "******* $sql1 *****\n";
   $result1 = $dbc->query($sql1);
   $result1->fetchInto($r1);

   $descripcion.=i18('_nombre').": {$r1['name']}\n";
   $descripcion.=i18('_dominio').": {$r1['domain']}\n";
   $descripcion.=i18('_direccionip').": $ip\n";
   $descripcion.=i18('_comunidadsnmp').": {$r1['community']}\n";
   $descripcion.=i18('_direccionmac').": {$r1['mac']} ({$r1['mac_vendor']})\n";
   $descripcion.=i18('_criticidad').": {$r1['critic']} ".i18('_sobre100')."\n";
   $descripcion.=i18('_tipo').": {$r1['type']}\n";
   $descripcion.=i18('_estado').": ";
   if ($r1['status']==0)     $descripcion.=i18('_activo')."\n";
   elseif ($r1['status']==1) $descripcion.=i18('_baja')."\n";
   elseif ($r1['status']==2) $descripcion.=i18('_mantenimiento')."\n";

	$descripcion.=i18('_Sensibilidad').": ";
	$data = array('__WSIZE__'=>$r1['wsize']);
	$result = doQuery('get_cfg_device_wsize_by_wsize',$data);
	$descripcion.=$result['obj'][0]['label']."\n";

   // 2. Obtener los campos definidos por el usuario
   $sql2="SELECT id,descr,tipo FROM devices_custom_types";
   $result2 = $dbc->query($sql2);
   while ($result2->fetchInto($r2)){
      $descripcion.=$r2['descr'];
      $sql3="SELECT columna{$r2['id']} as dato FROM devices_custom_data WHERE id_dev={$r1['id_dev']}";
      $result3 = $dbc->query($sql3);
      $result3->fetchInto($r3);
		if (($r2['tipo']==2)and($r3['dato']!='-')){
			$descripcion.=": <a href='{$r3['dato']}' target='_blank' style='color=#0000CC;text-decoration=underline'> {$r3['dato']} </a>\n";
			// <a target="_blank ref="paginaweb.htm">Texto del hipervíulo</a>
		}
		


      elseif($r2['tipo']==3){
         $aux_json_kk = json_decode($r3['dato']);
         // $row_data[]=array('value'=>implode("<br>",$aux_json_kk));
         $aux_val = '';
         if(count($aux_json_kk)>0){
/*
            $aux_val.= '<ul>';
            foreach($aux_json_kk as $_) $aux_val.="<li>$_</li>";
            $aux_val.='</ul>';
*/
				foreach($aux_json_kk as $_){
					$aux_val.="\n&nbsp;&nbsp;&#8226;&nbsp;".$_;
				}
         }
         $descripcion.=": $aux_val\n";
      }

		else{
      	$descripcion.=": {$r3['dato']}\n";
		}
   }

   // 3. Obtener los perfiles organizativos a los que pertenece el dispositivo
   $sql4="SELECT descr
         FROM cfg_organizational_profile
         WHERE id_cfg_op IN (
                              SELECT id_cfg_op
                              FROM cfg_devices2organizational_profile
                              WHERE id_dev=".$r1['id_dev'].")";
   $result4 = $dbc->query($sql4);
   $descripcion.=i18('_perfilesorganizativos').": ";
   while ($result4->fetchInto($r4)){
      $descripcion.=$r4['descr'].',';
   }
	$descripcion = substr_replace($descripcion,'',-1);
	// print "***** DESCR == $descripcion *****\n";

   // 4. Insertar los datos en una nota del dispositivo
   $date=time();
   $sqlExist="SELECT id_tip from tips where tip_class=1 and id_ref='{$r1['id_dev']}' AND tip_type='id_dev'";
   $resultExist=$dbc->query($sqlExist);
   $resultExist->fetchInto($rExist);
   if ($rExist['id_tip']==''){
      $sqlTip="INSERT INTO tips (id_ref,tip_type,name,date,tip_class,descr)
               VALUES ('{$r1['id_dev']}','id_dev','".i18('_fichadedispositivo')."','$date',1,'".str2jsQM($descripcion)."')";
   }else{
      $sqlTip="UPDATE tips set date=$date,descr='".str2jsQM($descripcion)."',name='".i18('_fichadedispositivo')."' WHERE id_tip={$rExist['id_tip']} AND id_ref='{$r1['id_dev']}' AND tip_type='id_dev'";
   }
   $dbc->query($sqlTip);
}

///////////////////////////////////////////////////////////////////////
// Function set_asset_record ()                                      //
// INPUT: $hash_asset                                                //
// OUTPUT: 0 => OK                                                   //
//         1 => NO OK                                                //
//Function que inserta en BBDD la ficha del elemento TI id $id_asset //
///////////////////////////////////////////////////////////////////////

function set_asset_record ($hash_asset){
global $dbc;

	$descripcion='';

	// 0.Obtener el subtype
	$data = array('__HASH_ASSET__'=>$hash_asset);
	$result = doQuery('asset_subtype_from_asset',$data);
	$categoria = $result['obj'][0]['descr'];

   // 1. Obtener los campos basicos del elemento TI
	$data = array('__HASH_ASSET__'=>$hash_asset);
	$result = doQuery('asset_info',$data);
	$r = $result['obj'][0];

   $descripcion.=i18('_nombre').": {$r['name']}\n";
   $descripcion.=i18('_estado').": {$r['status']}\n";
   $descripcion.=i18('_criticidad').": {$r['critic']} ".i18('_sobre100')."\n";
   $descripcion.=i18('_tipo').": {$r['descr']}\n";

   $descripcion.=i18('_categoria').": $categoria\n";
   $descripcion.=i18('_Propietario').": {$r['owner']}\n";

   // 2. Obtener los campos definidos por el usuario
   $data = array('__HASH_ASSET__'=>$hash_asset);
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
   $sqlExist="SELECT id_tip from tips where tip_class=1 and id_ref='$hash_asset' AND tip_type='asset'";
   $resultExist=$dbc->query($sqlExist);
   $resultExist->fetchInto($rExist);
   if ($rExist['id_tip']==''){
      $sqlTip="INSERT INTO tips (id_ref,tip_type,name,date,tip_class,descr)
               VALUES ('$hash_asset','asset','".i18('_fichadeelementoti')."','$date',1,'".str2jsQM($descripcion)."')";
   }else{
      $sqlTip="UPDATE tips set date=$date,descr='".str2jsQM($descripcion)."',name='".i18('_fichadeelementoti')."' WHERE id_tip={$rExist['id_tip']} AND id_ref='$hash_asset' AND tip_type='asset'";
   }
   $dbc->query($sqlTip);
}







 /**
	* **********************************************************************
	* Funcion: info_qactions()
	* Input:
	*		$descr: Lo que va a aparecer en el campo descripcion de auditoria
	*		$user: Usuario que ha provocado el registro
	*		$rc: 0 => Correcto|1 => NO OK
	*		$rcstr: Contenido del campo RCSTR de auditoria
	* Output: 0 => CORRECTO|1 => PROBLEMAS
	* Descripcion: Funcion encargada de insertar en qactions entradas con
	* informacion sin que deba tratarse
	* **********************************************************************
	*/

	function info_qactions($descr,$user,$rc,$rcstr){
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



// ------------------------------------------------------------------
// FUNCION: store_qactions()
// INPUT:
//			$action  => define el tipo de elemento a insertar en qactions
// 		$elems   => elementos a insertar en la tabla separados por comas
// 		$cmd     => comandos externos que hay que ejecutar
// 		$descr   => descripcion de la inserccion
// 		$atype   => Tipo de la accion
// OUTPUT: 0 => CORRECTO
// 		  1 => PROBLEMAS
// Funcion encargada de hacer el insert en la tabla qactions
// ------------------------------------------------------------------

function store_qactions($action,$elems,$cmd,$descr,$atype){
global $dbc;

	// ESTAMOS ASOCIANDO METRICAS A DISPOSITIVOS
	// $elems SON IPS SEPARADAS POR COMAS
	if (($action=='setmetric')or($action=='audit')or($action=='clone')or($action=='domain_sync') or($action=='delmetricdata')){
		$params=$elems;
	}
	if (! $atype) { $atype=0; }

	// print "<br>++++++++++++++++++++++++++++++++<br>";
   // print $params;
   // print "<br>++++++++++++++++++++++++++++++++<br>";
   $time=time();
   $aux_time=$time;

	$h=md5("$time$action$elems");
   $hh=substr($h,1,8);

   $user=$_SESSION['LUSER'];
   $sql="INSERT INTO qactions (name,descr,action,cmd,params,auser,date_store,date_start,status,task,atype)
         values ('$hh','$descr','$action','$cmd','$params','$user',$time,$aux_time,0,'$action',$atype)";
   // print "SQL ES == $sql";
	
   $result = $dbc->query($sql);
	if (@PEAR::isError($result)) {
      $msg_error=$result->getMessage();
		CNMUtils::error_log(__FILE__, __LINE__, "**DBERROR** $msg_error ($sql)");
		return 1;
   }
	else{
		CNMUtils::debug_log(__FILE__, __LINE__, "STORE OK atype=$atype action=$action elems=$elems cmd=$cmd descr=$descr");
		return 0;
	}
}
/*
function store_qactions2($action,$params,$cmd,$descr,$task){
global $dbc;

   $time=time();
   $aux_time=$time;

   $h=md5("$time$action$params");
   $hh=substr($h,1,8);

   $user=$_SESSION['LUSER'];
   $sql="INSERT INTO qactions (name,descr,action,atype,cmd,params,auser,date_store,date_start,status,task)
         values ('$hh','$descr','$action',0,'$cmd','$params','$user',$time,$aux_time,0,'$task')";
   // print "SQL ES == $sql";

   $result = $dbc->query($sql);
   if (@PEAR::isError($result)) {
      $msg_error=$result->getMessage();
      depura_datos("STORE.PHP-LINEA ".__LINE__,"$msg_error $sql");
      return 1;
   }else{
      return 0;
   }
}
*/

////////////////////////////////////////////////////////////////////////////////////////
// Funcion que escribe en el fichero /tmp/depura-datos-php cuando ha habido problemas //
// en una consulta en datos.php                                                       //
////////////////////////////////////////////////////////////////////////////////////////

function depura_datos($idx,$msg){

	$date=date("Y-d-d");
   $fp = fopen ('/tmp/depura-datos-php',"a");
   $msgf=sprintf("%s >>>> %s\n",$idx,$msg);
   fwrite($fp,$msgf);
   fclose($fp);
}

//--------------------------------------------------------------------------
// Function: store_devices_from_csv
// Input: Fichero CSV
// Output:
// Descripcion: Inserta en BBDD los dispositivos introducidos
// POSICION 0=name,1=domain,2=ip,3=sysloc,4=sysdesc,5=sysoid,6=type,7=status,8=community,9=version,10=po
//--------------------------------------------------------------------------
function store_devices_from_csv($csv_file) {
global $dbc;
   $campos_device=array();
   $campos_usuario=array();
	// 0 => Es la primera linea, es decir, la linea que contiene los titulos
	// 1 => Es el resto de lineas, es decir, las lineas que contienen informacion	
	$es_titulo=0;
   $titulos='';
   $array_titulos_usuario=array();
   $titulos_usuario='';
   $contador=0;
	$separador=10;
	$array_return_ids=array();
	$perfiles_organizativos='';

	$lineas=file($csv_file);
	foreach ($lineas as $linea){	
		$linea=chop($linea);	
		// NOTA: Se hace la conversion a UTF-8
		$data=explode(';',utf8_encode($linea));
		//if ($es_titulo==0){
		//	$es_titulo=1;
		//}
		if ($es_titulo == 0) {
         foreach ($data as $campo){
				// ANTES DE PO SON CAMPOS DE USUARIO
				if ($contador<$separador){
					array_push($campos_device,$campo);
				}
				// AQUI TENEMOS PO
				if ($contador==$separador){
					$perfiles_organizativos=$campo;
				}
				// CAMPOS DE USUARIO
				if ($contador>$separador){
               array_push($campos_usuario,(substr($campo,1)));
            }
				$contador++;	
         }
			$es_titulo=1;
         $titulos=implode(',',$campos_device);
		
			
			// print_r($campos_device);
			// print_r($campos_usuario);
	      // OBTENGO LOS CAMPOS EN devices_custom_data
         foreach ($campos_usuario as $campo){
            $sql0="SELECT id
						 FROM devices_custom_types
						 WHERE descr='$campo'";
				//  print ("SQL= == $sql0\n");
            $result0 = $dbc->query($sql0);
            // EN CASO DE HABER ERROR EN LA CONSULTA
            if (@PEAR::isError($result0)) {
               print "ERROR: No se ha podido obtener los campos de devices_custom_data\n";
               $msg_error=$result0->getMessage();
               depura_datos("import_devices.php-LINEA ".__LINE__,"$msg_error $sql0");
            }
            $result0->fetchInto($r0);
            array_push($array_titulos_usuario,'columna'.$r0['id']);
         }
         $titulos_usuario=implode(',',$array_titulos_usuario);
      }
      else{
			
         $valores=implode('","',array_slice($data,0,$separador));
         $valores='"'.$valores.'"';

			// 0. COMPROBAMOS SI EXISTE EL DISPOSITIVO
			$sqlIDDEV="SELECT id_dev FROM devices WHERE ip='".$data[2]."'";
			$resultIDDEV = $dbc->query($sqlIDDEV);
			$resultIDDEV->fetchInto($rIDDEV);
			// EXISTE EL DISPOSITIVO
			if($rIDDEV['id_dev']){
				$sql="UPDATE devices SET ";
				for ($i=0;$i<count($campos_device);$i++){
         	   if ($campos_device[$i]){
	               $sql.=$campos_device[$i].' = "'.$data[$i].'",';
			      }
         	}
				$sql=substr($sql,0,-1);
				$sql.=" WHERE id_dev=".$rIDDEV['id_dev'];
			}
			// NO EXISTE EL DISPOSITIVO
			else{
				$sql="INSERT INTO devices ($titulos)values($valores) ON DUPLICATE KEY UPDATE ";
				for ($i=0;$i<count($campos_device);$i++){
          	  if ($campos_device[$i]){
	               $sql.=$campos_device[$i].' = "'.$data[$i].'",';
	            }
	         }
				$sql=substr($sql,0,-1);
			}
			/*
         // 1. INSERTAMOS EL DISPOSITIVO
         // $sql="INSERT INTO devices ($titulos)values($valores) ON DUPLICATE KEY UPDATE ";
			for ($i=0;$i<count($campos_device);$i++){
				if ($campos_device[$i]){
					$sql.=$campos_device[$i].' = "'.$data[$i].'",';
				}
			}
			*/
         // print "SQL == $sql\n";
         $result = $dbc->query($sql);
         // EN CASO DE HABER ERROR EN LA CONSULTA
         if (@PEAR::isError($result)) {
				
			//	print_r($data);	
            print "ERROR: No se ha insertar el dispositivo en devices el dispositivo ".$data[2]."\n";
            $msg_error=$result->getMessage();
            depura_datos("import_devices.php-LINEA ".__LINE__,"$msg_error $sql");
            continue;
         }else{
				print "INFO: Se ha insertado correctamente en la BBDD el dispositivo ".$data[2]."\n";
			}
         // 2. OBTENEMOS EL ID_DEV DEL DISPOSITIVO INTRODUCIDO
         $sql2="SELECT id_dev AS ultimo
					 FROM devices
					 WHERE ip='".$data[2]."'";
         // print "SQL2 == $sql2\n";
         $result2 = $dbc->query($sql2);
			$result2->fetchInto($r2);	

         if (@PEAR::isError($result2)) {
            print "ERROR: No se ha podido obtener el id_dev del dispositivo ".$data[2]."\n";
            $msg_error=$result2->getMessage();
            depura_datos("import_devices.php-LINEA ".__LINE__,"$msg_error $sql2");
         }else{
				print "INFO: Se ha obtenido el id_dev del dispositivo ".$data[2]." == ".$r2['ultimo']."\n";
			}
         $id_dev=$r2['ultimo'];
		
         // 3. INSERTAMOS EN devices_custom_data LA INFORMACION
         $valores_usuario=implode('","',array_slice($data,$separador+1));
         $valores_usuario='"'.$valores_usuario.'"';
         $sql3="INSERT INTO devices_custom_data (id_dev,$titulos_usuario)values($id_dev,$valores_usuario) ON DUPLICATE KEY UPDATE id_dev=$id_dev,";
			for ($i=0;$i<count($campos_usuario);$i++){
            $sql3.=$array_titulos_usuario[$i].' = "'.$data[$i+$separador+1].'",';
         }
         $sql3=substr($sql3,0,-1);
         // print "SQL3 == $sql3\n";
         $result3 = $dbc->query($sql3);
         if (@PEAR::isError($result3)) {
            print "ERROR: No se ha podido insertar en devices_custom_data los datos del dispositivo ".$data[2]."\n";
            $msg_error=$result3->getMessage();
            depura_datos("import_devices.php-LINEA ".__LINE__,"$msg_error $sql3");
         }else{
				print "INFO: Se ha insertado correctamente en en devices_custom_data los datos del dispositivo ".$data[2]."\n";
			}


			//Hay que asignarlo por defecto al perfil organizativo global
		   $sql4="SELECT id_cfg_op FROM cfg_organizational_profile WHERE descr='Global'";
			// print "SQL4 == $sql4\n";
		   $result4 = $dbc->query($sql4);
		   $result4->fetchInto($r4);
			$id_cfg_op=$r4['id_cfg_op'];

		   $sql5="INSERT INTO cfg_devices2organizational_profile (id_dev,id_cfg_op)
		         VALUES ($id_dev,$id_cfg_op)
		         ON DUPLICATE KEY UPDATE id_cfg_op=$id_cfg_op, id_dev=$id_dev";
		   $result5 = $dbc->query($sql5);
			// print "SQL5=$sql5\n";


			// 4. SE ASIGNA A LOS PERFILES ORGANIZATIVOS INDICADOS
         $perfiles_organizativos=explode(',',$data[10]);
			foreach ($perfiles_organizativos as $perfil){
				$sql6="SELECT id_cfg_op FROM cfg_organizational_profile WHERE descr='$perfil'";
				// print $sql6;
				$result6 = $dbc->query($sql6);
        		$result6->fetchInto($r6);
				$id_cfg_op=$r6['id_cfg_op'];
				$sql7="INSERT INTO cfg_devices2organizational_profile (id_dev,id_cfg_op)
						 VALUES ($id_dev,$id_cfg_op)
						 ON DUPLICATE KEY UPDATE id_dev=$id_dev, id_cfg_op=$id_cfg_op";
				$result6 = $dbc->query($sql7);
				// print $sql7;
			}
		

			// CREAMOS LA FICHA DEL DISPOSITIVO
			set_device_record($data[2]);

			array_push($array_return_ids,$id_dev);
      }
		
   }
	return (implode(',',$array_return_ids));
}

//--------------------------------------------------------------------------
// Function: get_remote_address
// Input:
// Output: Direccion IP del cliente
// Descripcion: Funcion utilizada para conocer la direccion IP del cliente
//--------------------------------------------------------------------------
function get_remote_address() {
	$result='';
	isset($_SERVER['REMOTE_ADDR']) ? ($result=$_SERVER['REMOTE_ADDR']) : ($result='Direccion IP no definida');
	return $result;
}

//--------------------------------------------------------------------------
// Function: get_remote_client
// Input:
// Output: Tipo de cliente utilizado
// Descripcion: Funcion utilizada para conocer el cliente web usado para acceder a CNM
//--------------------------------------------------------------------------
function get_remote_client() {
   $result='';
	if (strpos($_SERVER['HTTP_USER_AGENT'],'MSIE')){
		$result='MSIE';
	}else{
		$result='OTRO';
	}
   return $result;
}


 /** **********************************************************************
   * Funcion: getQuery()
   * Input:
   *        $id => identificador que indica la query a realizar
   *        $data => hash que contiene los elementos a parsear y su valor
   * Output: query a ejecutar
   * Descripcion: Funcion encargada de generar la query adecuada
   * **********************************************************************
   */
	function getQuery($id,$data){
		global $sql_pool;
		include_once('sql/mod_Configure.sql');
		$sql=$sql_pool[$id];
		if (count($data)>0) {
	      foreach ($data as $key => $value){
				if($key!='__CONDITION__' and $key!='__VALUES__') $value = mysql_real_escape_string($value);
				// $value = addslashes($value);
				// $value = str_replace("'","\'",$value);
      	   $sql=str_replace($key,$value,$sql);
      	}
		}
		//CNMUtils::info_log(__FILE__, __LINE__, "*getQuery* SQL=$sql");
		return $sql;
	}

	function doQueryProcedure($procedure_name,$a_params){
		global $dbc;
      $return=array(
			'rc'    =>0,
			'rcstr' =>'',
			'id'    => $procedure_name,
		);

		$sql = "CALL $procedure_name (";
		$comma = '';
		foreach($a_params as $param){
			if(is_int($param))          $sql.=$comma.$param;
			elseif(is_string($param))   $sql.=$comma.'"'.mysql_real_escape_string($param).'"';
			$comma = ',';
		}
		$sql.=")";

		$return['sql'] = $sql;

      $result = $dbc->query($sql);
      if (@PEAR::isError($result)){
         $return['rcstr']=$result->getMessage();
         $return['rc']=$result->getCode();
      }
      return $return;
	}

 /** **********************************************************************
   * Funcion: doQuery()
   * Input:
   *        $id => identificador que indica la query a realizar
   *        $data => hash que contiene los elementos a parsear y su valor
   * Output: hash compuesto por:
	* 			 rc    => 0 ok|valor_error en otro caso
	* 			 rcstr => rcstr devuelto por la query
	* 			 msg   => Mensaje que se le da al usuario
	* 			 obj   => Array que contiene el resultado de la query
	*			 ico   => Icono a mostrar
   * Descripcion: Funcion encargada de ejecutar
   * **********************************************************************
   */
   function doQuery($id,$data,$file=''){
		$sql    = getQuery($id,$data);
		if(isset($_SESSION) AND array_key_exists('debug',$_SESSION) AND $_SESSION['debug'] == 1) list($start, $foo) = explode(" ", microtime());
   	$return = Query($sql,$id,$file);
		if(isset($_SESSION) AND array_key_exists('debug',$_SESSION) AND $_SESSION['debug'] == 1){
			$msg = '';
			list($end, $foo) = explode(" ", microtime());
			$time_ms = round(($end-$start)*1000);
			$time_normal = 1000;
			$time_slow   = 2000;
			$time_vslow  = 4000;
			if($time_ms < $time_normal)    $msg.='NORMAL_QUERY ';
			elseif($time_ms < $time_slow)  $msg.='SLOW_QUERY ';
         elseif($time_ms < $time_vslow) $msg.='SLOWER_QUERY ';
			else    				             $msg.='SLOWEST_QUERY ';

			$file = '';
			$line = '';
			$a_res_backtrace = debug_backtrace();
			foreach($a_res_backtrace as $a_item){
				if(array_key_exists('function',$a_item) AND $a_item['function'] == 'doQuery'){
					$file = $a_item['file'];
					$line = $a_item['line'];
					continue;
				}
			}

		   $unit=array('b','kb','mb','gb','tb','pb');
			$size = memory_get_usage(true);
    		$mem=@round($size/pow(1024,($i=floor(log($size,1024)))),2).$unit[$i];
			
			$msg.='TIME='.$time_ms.'ms MEM='.$mem.' FILE='.$file.' ID='.$id.' LINE='.$line.' SQL='.$sql;
			CNMUtils::info_log(__FILE__, __LINE__, $msg);
		}
		return $return;
	}
	// Función que ejecuta la query $sql
	function Query($sql,$id='manual',$file=''){
		global $dbc;
      $return=array('rc'=>'0','rcstr'=>'','msg'=>'','obj'=>array(),'cont'=>0);
      $result = $dbc->query($sql);
      if (@PEAR::isError($result)){
         $return['rcstr']=$result->getMessage();
         $return['rc']=$result->getCode();
         $return['msg']="Ha habido algun problema al realizar los cambios en la base de datos<br>Error SQL {$return['rc']} => {$return['rcstr']}";
         $return['ico']="ico_alarm";
         $return['query']=$sql;
         $return['id']=$id;
         $aux="FILE = $file || ID_SQL = $id || SQL = $sql || NOOK || RCSTR = {$return['rcstr']}";
      }
      else{
			if(is_object($result)){
            while ($result->fetchInto($r)){
               $return['obj'][]=$r;
               $return['cont']++;
            }
            $result->free();
         }
         $return['msg']="Los cambios se han realizado correctamente";
         $return['ico']="ico_info";
         $return['query']=$sql;
         $return['id']=$id;
         $aux="FILE = $file || ID_SQL = $id || SQL = $sql || OK";
      }
		if($file) debugFile($aux,1);

      return $return;
	}
   // Función que ejecuta la query $sql
   function QueryNoGlobal($dbc,$sql){
      $return=array('rc'=>'0','rcstr'=>'','msg'=>'','obj'=>array(),'cont'=>0);
      $result = $dbc->query($sql);
      if (@PEAR::isError($result)){
         $return['rcstr'] = $result->getMessage();
         $return['rc']    = $result->getCode();
         $return['msg']   = "Ha habido algun problema al realizar los cambios en la base de datos<br>Error SQL {$return['rc']} => {$return['rcstr']}";
         $return['ico']   = "ico_alarm";
      }
      else{
         if(is_object($result)){
            while ($result->fetchInto($r)){
               $return['obj'][]=$r;
               $return['cont']++;
            }
            $result->free();
         }
         $return['msg']   = "Los cambios se han realizado correctamente";
         $return['ico']   = "ico_info";
      }
      $return['query'] = $sql;
      $return['id']    = $id;
      return $return;
   }

   function doQuery2($id,$data){
      global $dbc;

      $return=array('rc'=>'0','msg'=>'','obj'=>array());

      $sql=getQuery($id,$data);
      //print $sql;
      $result = $dbc->query($sql);
      // $return['obj']=$result;
      if (@PEAR::isError($result)){
         $return['rcstr']=$result->getMessage();
         $return['rc']=$result->getCode();
         $return['msg']="Ha habido algun problema al realizar los cambios en la base de datos<br>Error SQL {$return['rc']} => {$return['rcstr']}";
         $return['ico']="ico_alarm";
         $aux="Error en la query *** $sql ***<br>ID = $id<br>";
      }
      else{
			$return['obj']=$result;
         $return['msg']="Los cambios se han realizado correctamente";
         $return['ico']="ico_info";
         $aux="OK";
      }
      debugFile("ID == $id");
      debugFile($sql);
      debugFile($aux);
      debugFile($result);

      return $return;
	}
 /** **********************************************************************
   * Funcion: parsea()
   * Input:
   *        $id => identificador que indica donde parsear los datos dentro de la variable $sql_search
   *        $data => hash que contiene los elementos a parsear y su valor
   * Output: texto sustituido
   * Descripcion:
   * **********************************************************************
   */
   function parsea($id,$option_selected,$data){
      global $sql_search;


		debugFile("ID == $id");
		debugFile("option_selected == $option_selected");

      $sql=$sql_search[$id][$option_selected][1];
      foreach ($data as $key => $value){
         $sql=str_replace($key,$value,$sql);
      }
      return $sql;
   }

 /** **********************************************************************
   * Funcion: parsea_avanzado()
   * Input:
   *        $id => identificador que indica donde parsear los datos dentro de la variable $sql_search
   * Output: texto sustituido
   * Descripcion:
   * **********************************************************************
   */
	// parsea_avanzado ('asistente')
   function parsea_avanzado($id){
      global $sql_search_advanced;

		$sql='';
      $data=$sql_search_advanced[$id];
		$cont=0;	
	
		// $key => name||type
      foreach ($data as $key => $value){
			if (get_param($key)){
				if ($cont==0){
					$sql.=' AND ('.str_replace('__QTEXT__',str_replace('*','%',get_param($key)),$value[1]);
				}else{
					$sql.=get_param('andor').str_replace('__QTEXT__',str_replace('*','%',get_param($key)),$value[1]);
				}
				$cont++;
			}
      }
		if ($sql!=''){
			$sql.=')';
		}
		debugFile('parsea_avanzado');
		debugFile("SQL == $sql");
      return $sql;
   }


 /** **********************************************************************
   * Funcion: debugFile()
   * Input:
   * Output:
   * Descripcion: Funcion utilizada para hacer debug en doQuery
   * **********************************************************************
   */
   function debugFile($input,$debug=0){
      if (!$debug) return;

      $fd=fopen('/tmp/debug.txt','a');
      fwrite($fd,"$input\n");
      fclose($fd);
   }

 /** **********************************************************************
   * Funcion: cron2text()
   * Input: $crondata: Texto en formato cron a traducir
	*			$type: Tipo de tarea (unica, diaria, semanal, mensual)
   * Output: Texto traducido
   * Descripcion: Funcion utilizada para traducir un texto en formato cron en
	* un texto entendible
   * **********************************************************************
   */
   function cron2text($crondata,$type){
	if ($crondata=='-' or $type=='-'){return '-';}

	$meses=array('01'=>'Enero','02'=>'Febrero','03'=>'Marzo','04'=>'Abril','05'=>'Mayo','06'=>'Junio','07'=>'Julio','08'=>'Agosto','09'=>'Septiembre','10'=>'Octubre','11'=>'Noviembre','12'=>'Diciembre');
   $dias_semana = array('Mon'=>'Lunes','Tue'=>'Martes','Wed'=>'Miercoles','Thu'=>'Jueves','Fri'=>'Viernes','Sat'=>'Sábados','Sun'=>'Domingos');

	$result='';
		list($minute,$hour,$mday,$month,$wday)=explode(' ',$crondata);
		if ($type=='U'){
			list($minute,$hour,$mday,$month,$wday,$ano)=explode(' ',$crondata);
	      // $result="En el a&ntilde;o $ano en el mes de {$meses[$month]} el dia $mday a las $hour:$minute horas";
	      $result="En el año $ano, el mes de {$meses[$month]} el dia $mday a las $hour:$minute horas";
      }
      if ($type=='D'){
			list($minute,$hour,$mday,$month,$wday)=explode(' ',$crondata);
         $result="Todos los dias a las $hour:$minute horas";
      }
      if ($type=='S'){
			list($minute,$hour,$mday,$month,$wday)=explode(' ',$crondata);
         $result="Todos los {$dias_semana[$wday]} a las $hour:$minute horas";
      }
      if ($type=='M'){
			list($minute,$hour,$mday,$month,$wday)=explode(' ',$crondata);
         $result="Todos los $mday de cada mes a las $hour:$minute horas";
      }
      if ($type=='A'){
         list($minute,$hour,$mday,$month,$wday)=explode(' ',$crondata);
         $result="Todos los $mday de cada mes a las $hour:$minute horas";
      }
		return $result;
   }

	function pintaColor($tipo){
	   if ($tipo=='snmp'){   $str='<font color="#990000">snmp</font>';}
	   if ($tipo=='xagent'){ $str='<font color="#006699">xgent</font>';}
	   if ($tipo=='latency'){$str='<font color="#559d48">tcp/ip</font>';}
	   if ($tipo=='wbem'){   $str='<font color="#559d48">wmi</font>';}
	   return $str;
	}
	function responseXML($data,$isSql=1){
	global $a_global_sql_error;

      if ( stristr($_SERVER["HTTP_ACCEPT"],"application/xhtml+xml") ) {
         header("Content-type: application/xhtml+xml"); } else {
         header("Content-type: text/xml");
      }
      $xml= '<?xml version="1.0" ?>';
      $xml.='<data>';
		foreach ($data as $key => $value){
			if ($key=='msg'){
				if ($data['rc']==0){
					$xml.="<$key><![CDATA[<img src='images/status_ok.gif'> $value]]></$key>";
				}else{
					if($isSql==1) $value.=" (RC = {$data['rc']} || {$a_global_sql_error[$data['rc']]})";
					$xml.="<$key><![CDATA[<img src='images/status_nook.gif'> $value]]></$key>";
				}
			}else{
				$xml.="<$key><![CDATA[$value]]></$key>";
			}
		}
      $xml.='</data>';
      echo $xml;
      return;
	}

	function responseJSON($data,$isSql=1){
	global $a_global_sql_error;

		if(isset($data['rc']) AND isset($data['msg'])){
			$data['msg_noico'] = $data['msg'];
			if($isSql==1 AND $data['rc']!=0) $data['msg'].=" (RC = {$data['rc']} || {$a_global_sql_error[$data['rc']]})";
			$msg = ($data['rc']==0)?"<img src=images/status_ok.gif> {$data['msg']}":"<img src=images/status_nook.gif> {$data['msg']}";
			$data['msg'] = $msg;
		}
		echo json_encode($data);
	}
   function severity2stringstyle($sev){
      if($sev=='0')    $str="<img src=images/alarm_tr.gif style='vertical-align: baseline; width:9px;'>";
      elseif($sev=='1')$str="<img src=images/alarm_ro.gif style='vertical-align: baseline; width:9px;'>";
      elseif($sev=='2')$str="<img src=images/alarm_na.gif style='vertical-align: baseline; width:9px;'>";
      elseif($sev=='3')$str="<img src=images/alarm_am.gif style='vertical-align: baseline; width:9px;'>";
      elseif($sev=='4')$str="<img src=images/alarm_az.gif style='vertical-align: baseline; width:9px;'>";
      elseif($sev=='5')$str="<img src=images/alarm_gr.gif style='vertical-align: baseline; width:9px;'>";
      elseif($sev=='6')$str="<img src=images/alarm_ve.gif style='vertical-align: baseline; width:9px;'>";
      else             $str=$sev;
      return $str;
   }
	function severity2string($sev){
		if($sev=='0')    $str="<img src=images/alarm_tr.gif>";
		elseif($sev=='1')$str="<img src=images/alarm_ro.gif>";
      elseif($sev=='2')$str="<img src=images/alarm_na.gif>";
      elseif($sev=='3')$str="<img src=images/alarm_am.gif>";
      elseif($sev=='4')$str="<img src=images/alarm_az.gif>";
      elseif($sev=='5')$str="<img src=images/alarm_gr.gif>";
      elseif($sev=='6')$str="<img src=images/alarm_ve.gif>";
      else             $str=$sev;
		return $str;
	}
	function metricType2image($type){
		if($type=='snmp')          $img='<img src=images/mod_ico_snmp.png>';
		elseif($type=='latency')   $img='<img src=images/mod_ico_tcpip.png>';
		elseif($type=='xagent')    $img='<img src=images/mod_ico_xagent.png>';
		elseif($type=='email')     $img='<img src=images/mod_ico_email.png>';
		elseif($type=='syslog')    $img='<img src=images/mod_ico_syslog.png>';
		elseif($type=='snmp-trap') $img='<img src=images/mod_ico_trap.png>';
      elseif($type=='cnm')       $img='<img src=images/mod_ico_cnm.png>';
      elseif($type=='api')       $img='<img src=images/mod_ico_api.png>';
		else                       $img=$type;
		return $img;
	}
   function metricType2string($type){
      if($type=='snmp')          $str='SNMP';
      elseif($type=='latency')   $str='TCP/IP';
      elseif($type=='xagent')    $str='AGENTE CNM';
      elseif($type=='email')     $str='EMAIL';
      elseif($type=='syslog')    $str='SYSLOG';
      elseif($type=='snmp-trap') $str='TRAP SNMP';
      elseif($type=='cnm')       $str='CNM';
      else                       $str=$type;
      return $str;
   }
	function deviceStatus2string($status){
	   if($status==0)     $str='<img src=images/ico_activ_tr_20.gif>';
      elseif($status==1) $str='<img src=images/ico_desact_tr_20.gif>';
      elseif($status==2) $str='<img src=images/ico_mant_tr_20.gif>';
		else               $str=$status;
		return $str;
	}
	function deviceStatus2stringCSV($status){
      if($status==0)     $str='Activo';
      elseif($status==1) $str='De baja';
      elseif($status==2) $str='Mantenimiento';
      else               $str=$status;
      return $str;
   }
	// mod_dispositivo_lista.php
	// Devuelve un hash que contiene los dispositivos alarmados y su severidad
	function dispositivos_alarmados(){
		$da = array();
		$data = array();
      $result = doQuery('all_devices_no_condition',$data);
      foreach ($result['obj'] as $r){
         $da[$r['id_dev']]['red']=0;
         $da[$r['id_dev']]['orange']=0;
         $da[$r['id_dev']]['yellow']=0;
         $da[$r['id_dev']]['blue']=0;
		}
		$data = array();
      $result = doQuery('dispositivos_alarmados',$data);
      foreach ($result['obj'] as $r){
			if($r['severity']=='1'){$da[$r['id_device']]['red']++;}
			if($r['severity']=='2'){$da[$r['id_device']]['orange']++;}
			if($r['severity']=='3'){$da[$r['id_device']]['yellow']++;}
			if($r['severity']=='4'){$da[$r['id_device']]['blue']++;}
      }
		return $da;	
	}
	// Devuelve un hash que contiene los dispositivos y el número de métricas que tienen asociadas
	function dispositivos_metricas(){
		$da = array();
		$data = array();
		$result = doQuery('metrics_devices',$data);
      foreach ($result['obj'] as $r) $da[$r['id_dev']] = $r['cuantos'];
		return $da;
	}

	// Funcion que devuelve una tabla con todos los dispositivos.
	// Se usa en las solapas de dispositivo de toda la parte de configuración
	function dispositivos_tabla($posStart,$count,$condition,$orderby,$orderdirect,$total){
		global $dbc;
		$dispositivos = array('data'=>array(),'cuantos'=>0);
		$dispositivo_alarmado = array();
      $cond = '';
		$order = ' name asc';

      if ($condition!=''){
         list($nombre,$dominio,$ip,$tipo,$other) = explode('|',$condition);
         $cond.= " AND name LIKE '%$nombre%' ";
         $cond.= " AND domain LIKE '%$dominio%' ";
         $cond.= " AND ip LIKE '%$ip%' ";
         $cond.= " AND type LIKE '%$tipo%' ";
			$cond.= " $other ";
      }
      if($orderby!=''){
         $columns = array("name","name","name","name","domain","INET_ATON(ip)","type");
         if ($orderdirect=='des')$orderdirect = "DESC";
         else $orderdirect = "ASC";
         $order = " {$columns[$orderby]} $orderdirect";
      }

      $data = array('__CONDITION__'=>$cond, '__ORDERBY__'=>$order, '__POSSTART__'=>$posStart, '__COUNT__'=>$count);
      $result = doQuery('get_device_list',$data);
		$resultCount = doQuery('get_device_list_count',$data);
		$resultAlarmed = doQuery('get_device_list_alarmed',$data);

		// foreach($resultAlarmed['obj'] as $r){$dispositivo_alarmado[]=$r['id_device'];}

		foreach($result['obj'] as $r){
			$r['status_icon']=$r['status']==0?'<img src=images/ico_activ_tr_20.gif>':'<img src=images/ico_desact_tr_20.gif>';
			$r['alarmed']=(in_array($r['id_dev'],$dispositivo_alarmado))?1:0;
			$r['row_style']=($r['alarmed']==1)?'color:red':'';
			$dispositivos['data'][]=$r;
		}
		$dispositivos['cuantos']=$resultCount['obj'][0]['cuantos'];

		return $dispositivos;
	}

/*
   // Funcion que devuelve una tabla con todos los dispositivos.
   // Se usa en las solapas de dispositivo de toda la parte de configuración
   function monitor_metricas_tabla($posStart,$count,$condition,$orderby,$orderdirect,$total,$id_alert_type){
      global $dbc;
      $metricas = array('data'=>array(),'cuantos'=>0);
      $dispositivo_alarmado = array();
      $cond = '';
      $order = ' name asc';

      if ($condition!=''){
         list($nombre,$dominio,$ip,$tipo,$label) = explode('|',$condition);
         $cond.= " AND name LIKE '%$nombre%' ";
         $cond.= " AND domain LIKE '%$dominio%' ";
         $cond.= " AND ip LIKE '%$ip%' ";
         $cond.= " AND d.type LIKE '%$tipo%' ";
         $cond.= " AND label LIKE '%$label%' ";
      }
      if($orderby!=''){
         $columns = array("name","name","name","name","domain","ip","d.type","label");
         if ($orderdirect=='des'){$orderdirect = "DESC";}
         else{$orderdirect = "ASC";}
         $order = " {$columns[$orderby]} $orderdirect";
      }

      $data = array('__CONDITION__'=>$cond, '__ORDERBY__'=>$order, '__POSSTART__'=>$posStart, '__COUNT__'=>$count,'__ID_ALERT_TYPE__'=>$id_alert_type);
      $result = doQuery('get_monitor_metrics_list',$data);
      $resultCount = doQuery('get_monitor_metrics_list_count',$data);
      $resultAlarmed = doQuery('get_device_list_alarmed',$data);

      foreach($resultAlarmed['obj'] as $r){$dispositivo_alarmado[]=$r['id_device'];}

      foreach($result['obj'] as $r){
         $r['status_icon']=$r['status']==0?'<img src=images/ico_activ_tr_20.gif>':'<img src=images/ico_desact_tr_20.gif>';
         $r['alarmed']=(in_array($r['id_dev'],$dispositivo_alarmado))?1:0;
         $r['row_style']=($r['alarmed']==1)?'background-color:#F9D5D5':'';
         $metricas['data'][]=$r;
      }
      $metricas['cuantos']=$resultCount['obj'][0]['cuantos'];

      return $metricas;
   }
*/
   /*
      Función que devuelve la estructura de la tabla de dispositivos de cada solapa
   */
	function gen_devices_structure($tabla){
      $tabla->addCol(array('id'=>'system_checkbox','type'=>'ch','width'=>'25,25,false','sort'=>'server','align'=>'center'),'#master_checkbox','&nbsp;');
      $tabla->addCol(array('id'=>'system_status','type'=>'ro','width'=>'50,50,false','sort'=>'server','align'=>'center'),'<center><div id="combo_zone2" style="width:40px; height:22px;"></div></center>','<img src="images/ico_disp_status_grey_2.gif" title="Estado del dispositivo">');
      $tabla->addCol(array('id'=>'system_asoc','type'=>'ro','width'=>'50,50,false','sort'=>'server','align'=>'center'),'<center><div id="combo_zone3" style="width:40px; height:22px;"></div></center>','INC');
      $tabla->addCol(array('id'=>'system_name','type'=>'ro','width'=>'*,350,false','sort'=>'server','align'=>'left'),'#text_filter','NOMBRE');
      $tabla->addCol(array('id'=>'system_domain','type'=>'ro','width'=>'100,100,false','sort'=>'server','align'=>'left'),'#text_filter','DOMINIO');
      $tabla->addCol(array('id'=>'system_ip','type'=>'ro','width'=>'100,100,false','sort'=>'server','align'=>'center'),'#text_filter','IP');
      $tabla->addCol(array('id'=>'system_type','type'=>'ro','width'=>'100,100,true','sort'=>'server','align'=>'left'),'#text_filter','TIPO');
      $tabla->addCol(array('id'=>'system_mac','type'=>'ro','width'=>'100,100,true','sort'=>'server','align'=>'left'),'#text_filter','MAC');

      $data = array();
      $result = doQuery('get_user_fields',$data);
      foreach ($result['obj'] as $r){
         $tabla->addCol(array('id'=>"custom_{$r['descr']}",'type'=>'ro','width'=>'80,80,true','sort'=>'server','align'=>'left'),'#text_filter',$r['descr']);
      }
      $tabla->show();
	}
   /*
      Función que devuelve la estructura de la tabla de dispositivos de la solapa de asignar en bloque
   */
	function gen_devices_structure_b($tabla){
      $tabla->addCol(array('id'=>'system_checkbox','type'=>'ch','width'=>'25,25,false','sort'=>'server','align'=>'center'),'#master_checkbox','&nbsp;');
      $tabla->addCol(array('id'=>'system_status','type'=>'ro','width'=>'50,50,false','sort'=>'server','align'=>'center'),'<center><div id="combo_zone2" style="width:40px; height:22px;"></div></center>','<img src="images/ico_disp_status_grey_2.gif" title="Estado del dispositivo">');
      $tabla->addCol(array('id'=>'system_name','type'=>'ro','width'=>'100,100,false','sort'=>'server','align'=>'center'),'#text_filter','NOMBRE');
      $tabla->addCol(array('id'=>'system_domain','type'=>'ro','width'=>'100,100,false','sort'=>'server','align'=>'center'),'#text_filter','DOMINIO');
      $tabla->addCol(array('id'=>'system_ip','type'=>'ro','width'=>'100,100,false','sort'=>'server','align'=>'center'),'#text_filter','IP');
      $tabla->addCol(array('id'=>'system_type','type'=>'ro','width'=>'*,100,true','sort'=>'server','align'=>'left'),'#text_filter','TIPO');

      $data = array();
      $result = doQuery('get_user_fields',$data);
      foreach ($result['obj'] as $r){
         $tabla->addCol(array('id'=>"custom_{$r['descr']}",'type'=>'ro','width'=>'80,80,true','sort'=>'server','align'=>'center'),'#text_filter',$r['descr']);
      }
      $tabla->show();
   }
	/*
		Función que hace las consultas adecuadas para obtener la tabla de dispositivos de cada solapa
	*/
	function gen_devices_table($id_tab,$data,$tabla){
		global $dbc;
		$devices_visible_id_query = '';
		$devices_asoc_id_query = '';

		$posStart = $data['__POSSTART__'];

		// $dispositivos_alarmados = dispositivos_alarmados();
		$dispositivos_alarmados = array();

      // Se obtienen los campos de usuario que hay definidos en el sistema
      $result = doQuery('get_user_fields',$data);
      $user_fields = '';
      $array_user_fields = array();
      $a_user_fields_types = array();
      foreach ($result['obj'] as $r){
         $user_fields.=",c.columna{$r['id']}";
         $array_user_fields[]="columna{$r['id']}";
         $a_user_fields_types["columna{$r['id']}"]=$r['type'];
      }
		$data['__USER_FIELDS__']=$user_fields;


      // Se borra la tabla temporal t1
      $result = doQuery('cnm_common_get_devices_delete_temp',$data);

		// Dispositivos de avisos
		if ($id_tab=='avisos'){
			$devices_visible_id_query='cnm_cfg_notification_get_devices_visible';
			$devices_asoc_id_query='cnm_cfg_notification_get_devices_asoc';
		}
		// Dispositivos de alertas remotas
      elseif ($id_tab=='remote'){
         $devices_visible_id_query='cnm_cfg_remote_get_devices_visible';
         $devices_asoc_id_query='cnm_cfg_remote_get_devices_asoc';
      }
		// Bloque de alertas remotas
      elseif ($id_tab=='bloque_remote'){
         $devices_visible_id_query='cnm_cfg_remote_get_devices_visible';
         $devices_asoc_id_query='cnm_cfg_remote_get_devices_asoc';
		}
      // Dispositivos de metricas latency
      elseif ($id_tab=='latency'){
         $devices_visible_id_query='cnm_cfg_latency_get_devices_visible';
         $devices_asoc_id_query='cnm_cfg_latency_get_devices_asoc';
      }
      // Dispositivos de metricas snmp sin instancias
      elseif ($id_tab=='snmp_no'){
         $devices_visible_id_query='cnm_cfg_snmp_get_devices_visible';
         $devices_asoc_id_query='cnm_cfg_snmp_get_devices_asoc';
      }
      elseif ($id_tab=='proxy'){
         $devices_visible_id_query='cnm_cfg_xagt_proxy_get_devices_tree_visible';
         $devices_asoc_id_query='cnm_cfg_xagt_get_devices_asoc';
      }
      elseif ($id_tab=='wmi_no'){
         $devices_visible_id_query='cnm_cfg_wmi_no_get_devices_tree_visible';
         $devices_asoc_id_query='cnm_cfg_xagt_get_devices_asoc';
      }
      elseif ($id_tab=='proxy_bulk'){
         $devices_visible_id_query='cnm_cfg_xagt_proxy_get_devices_tree_visible';
         $devices_asoc_id_query='cnm_cfg_xagt_get_devices_bulk';
      }
		// Dispositivos de metricas snmp (bloque)
      elseif ($id_tab=='snmp_bulk'){
         $devices_visible_id_query='cnm_cfg_snmp_get_devices_visible';
         $devices_asoc_id_query='cnm_cfg_snmp_get_devices_bulk';
      }
      // Dispositivos de metricas latency (bloque)
      elseif ($id_tab=='latency_bulk'){
         $devices_visible_id_query='cnm_cfg_latency_get_devices_visible';
         $devices_asoc_id_query='cnm_cfg_latency_get_devices_bulk';
      }
      // Dispositivos de metricas xagent (bloque)
      elseif ($id_tab=='xagent_bulk'){
         $devices_visible_id_query='cnm_cfg_xagt_get_devices_visible';
         $devices_asoc_id_query='cnm_cfg_xagt_get_devices_bulk';
      }
      // Dispositivos de metricas xagt sin instancias
      elseif ($id_tab=='xagt_no'){
         $devices_visible_id_query='cnm_cfg_xagt_get_devices_visible';
         $devices_asoc_id_query='cnm_cfg_xagt_get_devices_asoc';
      }
      // Dispositivos de metricas xagt sin instancias como proxy
      elseif ($id_tab=='xagt_no_proxy'){
         $devices_visible_id_query='cnm_cfg_xagt_proxy_get_devices_visible';
         $devices_asoc_id_query='cnm_cfg_xagt_get_devices_asoc';
      }
      // Dispositivos de tareas
      elseif ($id_tab=='tareas'){
         $devices_visible_id_query='cnm_cfg_task_get_devices_visible';
         $devices_asoc_id_query='cnm_cfg_task_get_devices_asoc';
      }


	   // Se obtienen los id_dev que van a ser visibles
	   $result = doQuery($devices_visible_id_query,$data);
CNMUtils::info_log(__FILE__, __LINE__, "devices_visible_id_query: error={$result['rcstr']} rc={$result['rc']} {$result['query']}");

	   $a_id_dev_visible = array();
	   foreach ($result['obj'] as $r){$a_id_dev_visible[]=$r['id_dev'];}
	   $data['__ID_DEV_VISIBLE__']=implode(',',$a_id_dev_visible);

      // Se obtienen los id_device que están asociados
      $result = doQuery($devices_asoc_id_query,$data);
CNMUtils::info_log(__FILE__, __LINE__, "devices_asoc_id_query: error={$result['rcstr']} rc={$result['rc']} {$result['query']}");

		// print_r($result);
      $a_id_dev_asoc = array();
      foreach ($result['obj'] as $r){$a_id_dev_asoc[]=$r['id_dev'];}
      $data['__ID_DEV_ASOC__']=implode(',',$a_id_dev_asoc);

      // Se crea la tabla temporal con los dispositivos visibles. Se ponen por defecto como no asociados
      $result = doQuery('cnm_get_devices_common_create_temp',$data);
//print_r($result['query']);

CNMUtils::info_log(__FILE__, __LINE__, "cnm_get_devices_common_create_temp: error={$result['rcstr']} rc={$result['rc']} {$result['query']}");

      // Se actualiza el campo asoc de la tabla temporal
      $result = doQuery('cnm_get_devices_common_update_temp',$data);
CNMUtils::info_log(__FILE__, __LINE__, "cnm_get_devices_common_update_temp: error={$result['rcstr']} rc={$result['rc']} {$result['query']}");

      $result = doQuery('cnm_get_devices_common_lista',$data);
CNMUtils::info_log(__FILE__, __LINE__, "gen_devices_table: error={$result['rcstr']} rc={$result['rc']} {$result['query']}");

      // Se obtienen los dispositivos
      foreach ($result['obj'] as $r){
         $status=deviceStatus2string($r['status']);
         $asoc =$r['asoc']==1?'<img src="images/mod_incluir16x16.png">':'<img src="images/mod_excluir16x16.png">';
			if($dispositivos_alarmados[$r['id_dev']]['red']>0 || $dispositivos_alarmados[$r['id_dev']]['orange']>0 || $dispositivos_alarmados[$r['id_dev']]['yellow']>0){
            $row_style='color:red';
         }else{
            $row_style='';
			}

         $row_meta = array('id'=>$r['id_dev'],'style'=>$row_style);
			if($id_tab=='xagt_no' or $id_tab=='xagt_no_proxy' or $id_tab=='xagt_bulk'){
	         $version='win32';
		      if (strpos($r['xagent_version'],'linux')) { $version='linux'; }
	         // $row_data = array(0,$status,$asoc,$version,$r['name'],$r['domain'],$r['ip'],$r['type'],$r['sysoid'],$r['sysdesc'],$r['sysloc']);
	         $row_data = array(0,$status,$asoc,$version,$r['name'],$r['domain'],$r['ip'],$r['type'],$r['mac']);
			}
			elseif($id_tab=='bloque_remote'){
            // $row_data = array(0,$status,$r['name'],$r['domain'],$r['ip'],$r['type'],$r['sysoid'],$r['sysdesc'],$r['sysloc']);
            $row_data = array(0,$status,$r['name'],$r['domain'],$r['ip'],$r['type'],$r['mac']);
			}
			elseif($id_tab=='snmp_no'){
            $row_data = array(0,$status,$asoc,$r['name'],$r['domain'],$r['ip'],$r['type'],$r['mac'],$r['sysoid'],$r['sysdesc'],$r['sysloc']);
         }
			else{
	         // $row_data = array(0,$status,$asoc,$r['name'],$r['domain'],$r['ip'],$r['type'],$r['sysoid'],$r['sysdesc'],$r['sysloc']);
	         $row_data = array(0,$status,$asoc,$r['name'],$r['domain'],$r['ip'],$r['type'],$r['mac']);
			}



         $nav = ObtenerNavegador($_SERVER['HTTP_USER_AGENT']);
         foreach ($array_user_fields as $field){
            if($a_user_fields_types[$field]==2 && $r[$field]!='-'){
               $uri=URINavegator($r[$field],$nav);
               $row_data[]="<a href='$uri' target='_blank'>link<a>";
            }
            elseif($a_user_fields_types[$field]==3){
               $aux_json_kk = json_decode($r[$field]);
               // $row_data[]=array('value'=>implode("<br>",$aux_json_kk));
               $aux_val = '';
               if(count($aux_json_kk)>0){
                  $aux_val.= '<ul style="padding-left: 15px;">';
                  foreach($aux_json_kk as $_) $aux_val.="<li>$_</li>";
                  $aux_val.='</ul>';
               }
               $row_data[]=$aux_val;
            }
            else{
               $row_data[]=$r[$field];
            }
         }
/*
         foreach ($array_user_fields as $field){
            $row_data[]=$r[$field];
         }
*/
         $row_user = array('ip'=>$r['ip'],'id_dev'=>$r['id_dev'],'idd'=>'ALL','name'=>$r['name']);

         $tabla->addRow($row_meta,$row_data,$row_user);
      }
      $result = doQuery('cnm_get_devices_common_count',$data);
      $cuantos = $result['obj'][0]['cuantos'];
//print "CUANTOS == $cuantos || POSSTART == $posStart\n";

      $tabla->showData($cuantos,$posStart);
	}
   /*
      Función que devuelve la estructura de la tabla de dispositivos de cada solapa
   */
   function gen_devices_tree_structure($tabla,$mode){
		// MODE == 0 => Métrica SNMP o vista con instancias	
		// MODE == 1 => Métrica SNMP o vista sin instancias	
		// MODE == 2 => Métrica XAGENT con instancias	
		// MODE == 3 => Métrica XAGENT sin instancias	
		// MODE == 4 => Alertas remotas de vistas
		// MODE == 5 => Métrica PROXY (sin instancias)
      $tabla->addCol(array('id'=>'system_checkbox','type'=>'ch','width'=>'25,25,false','sort'=>'str','align'=>'center'),'#master_checkbox','&nbsp;');
		if($mode==0 or $mode==2 or $mode==4 or $mode==5){
	      $tabla->addCol(array('id'=>'system_cuantos','type'=>'ro','width'=>'30,30,false','sort'=>'str','align'=>'center'),'&nbsp;','<img src="images/ico_graf_tab_off.gif" title="">');
		}
      $tabla->addCol(array('id'=>'system_status','type'=>'ro','width'=>'38,38,false','sort'=>'str','align'=>'center'),'<center><div id="combo_zone2" style="width:28px; height:22px;"></div></center>','<img src="images/ico_disp_status_grey_2.gif" title="Estado del dispositivo">');
	   $tabla->addCol(array('id'=>'system_asoc','type'=>'ro','width'=>'38,38,false','sort'=>'str','align'=>'center'),'<center><div id="combo_zone3" style="width:28px; height:22px;"></div></center>','INC');
		if($mode==2 or $mode==3){
			$tabla->addCol(array('id'=>'system_xagent_version','type'=>'ro','width'=>'50,50,false','sort'=>'str','align'=>'center'),'<center><div id="combo_so" style="width:40px; height:22px;"></div></center>','S.O');
		}
		if($mode==0 or $mode==2){
	      $tabla->addCol(array('id'=>'system_name','type'=>'tree','width'=>'*,350,false','sort'=>'str','align'=>'left'),"#text_filter",'DISPOSITIVO / METRICA');
		}
		elseif($mode==1 or $mode==3 or $mode==5){
	      $tabla->addCol(array('id'=>'system_name','type'=>'ro','width'=>'*,350,false','sort'=>'str','align'=>'left'),"#text_filter",'DISPOSITIVO');
		}elseif($mode==4){
         $tabla->addCol(array('id'=>'system_name','type'=>'tree','width'=>'*,350,false','sort'=>'str','align'=>'left'),"#text_filter",'DISPOSITIVO / ALERTA REMOTA');
      }
      $tabla->addCol(array('id'=>'system_domain','type'=>'ro','width'=>'100,100,false','sort'=>'str','align'=>'center'),'#text_filter','DOMINIO');
      $tabla->addCol(array('id'=>'system_ip','type'=>'ro','width'=>'100,100,false','sort'=>'str','align'=>'center'),'#text_filter','IP');
      $tabla->addCol(array('id'=>'system_type','type'=>'ro','width'=>'100,100,true','sort'=>'str','align'=>'left'),'#text_filter','TIPO');
      $tabla->addCol(array('id'=>'system_mac','type'=>'ro','width'=>'100,100,true','sort'=>'str','align'=>'left'),'#text_filter','MAC');

      $data = array();
      $result = doQuery('get_user_fields',$data);
      foreach ($result['obj'] as $r){
         $tabla->addCol(array('id'=>"custom_{$r['descr']}",'type'=>'ro','width'=>'80,80,true','sort'=>'str','align'=>'left'),'#text_filter',$r['descr']);
      }
      $tabla->show();
   }

   /*
      Función que hace las consultas adecuadas para obtener la tabla de dispositivos de tipo árbol de cada solapa
   */
   function gen_devices_tree_table($id_tab,$data,$tabla){
      global $dbc;
      $devices_visible_id_query = '';
      $devices_asoc_id_query = '';

		$posStart = $data['__POSSTART__'];

      // $dispositivos_alarmados = dispositivos_alarmados();
      $dispositivos_alarmados = array();

      // Se obtienen los campos de usuario que hay definidos en el sistema
      $result = doQuery('get_user_fields',$data);
      $user_fields = '';
      $array_user_fields = array();
      $a_user_fields_types = array();
      foreach ($result['obj'] as $r){
         $user_fields.=",c.columna{$r['id']}";
         $array_user_fields[]="columna{$r['id']}";
         $a_user_fields_types["columna{$r['id']}"]=$r['type'];
      }
      $data['__USER_FIELDS__']=$user_fields;


      // Se borra la tabla temporal t1
      $result = doQuery('cnm_get_devices_tree_common_delete_temp',$data);
      // Dispositivos de metricas snmp con instancias
      if ($id_tab=='snmp_si'){
         $devices_visible_id_query='cnm_cfg_snmp_get_devices_tree_visible';
         $devices_count_id_query='cnm_cfg_snmp_get_devices_tree_count';
      }
		// Dispositivos de métricas xagt con instancias
      elseif ($id_tab=='xagt_si'){
         $devices_visible_id_query='cnm_cfg_xagt_get_devices_tree_visible';
         $devices_count_id_query='cnm_cfg_xagt_get_devices_tree_count';
		}
		// Dispositivos de métrica proxy
      elseif ($id_tab=='proxy'){
         $devices_visible_id_query='cnm_cfg_xagt_proxy_get_devices_tree_visible';
         $devices_count_id_query='cnm_cfg_xagt_get_devices_tree_count';
		}
      // Dispositivos de wmi con instancias
      elseif ($id_tab=='wmi_si'){
         $devices_visible_id_query='cnm_cfg_xagt_proxy_get_devices_tree_visible';
         $devices_count_id_query='cnm_cfg_xagt_get_devices_tree_count';
      }
      // Dispositivos de métricas de vistas
      elseif ($id_tab=='view_si'){
         $devices_visible_id_query='cnm_view_get_devices_tree_visible';
         $devices_count_id_query='cnm_view_get_devices_tree_count';
      }
      // Dispositivos de alertas remotas de vistas
      elseif ($id_tab=='view_remote_si'){
         $devices_visible_id_query='cnm_view_remote_get_devices_tree_visible';
         $devices_count_id_query='cnm_view_remote_get_devices_tree_count';
      }
      // Se obtienen los id_dev que van a ser visibles
      $result = doQuery($devices_visible_id_query,$data);
      $a_id_dev_visible = array();
      foreach ($result['obj'] as $r){$a_id_dev_visible[]=$r['id_dev'];}
      $data['__ID_DEV_VISIBLE__']=implode(',',$a_id_dev_visible);

		

		// Se obtienen los id_dev y cuantos
		$result = doQuery($devices_count_id_query,$data);
		$a_id_dev_cuantos = array();
		foreach ($result['obj'] as $r){$a_id_dev_cuantos[$r['id_dev']]=$r['cuantos'];}

      // Se crea la tabla temporal con los dispositivos visibles. Se ponen por defecto con cuantos=0
      $result = doQuery('cnm_get_devices_tree_common_create_temp',$data);
      // Se actualiza el campo cuantos de la tabla temporal
		foreach ($a_id_dev_cuantos as $id_dev=>$cuantos){
			$data2 = array('__ID_DEV__'=>$id_dev,'__CUANTOS__'=>$cuantos);
			$result2 = doQuery('cnm_get_devices_tree_common_update_temp',$data2);
		}	
      $result = doQuery('cnm_get_devices_tree_common_lista',$data);

      // Se obtienen los dispositivos
      foreach ($result['obj'] as $r){
         $status=deviceStatus2string($r['status']);
         if($dispositivos_alarmados[$r['id_dev']]['red']>0 || $dispositivos_alarmados[$r['id_dev']]['orange']>0 || $dispositivos_alarmados[$r['id_dev']]['yellow']>0){
            $row_style='color:red';
         }else{
            $row_style='';
         }

         $row_meta = array('id'=>$r['id_dev'],'xmlkids'=>1,'style'=>$row_style);

			if ($id_tab=='snmp_si' or $id_tab=='xagt_si'){
            $row_data = array(0,$r['cuantos'],$status,$r['name'],$r['domain'],$r['ip'],$r['type'],$r['mac'],$r['sysoid'],$r['sysdesc'],$r['sysloc']);
			}
			else{
            $row_data = array(0,$r['cuantos'],$status,'-',$r['name'],$r['domain'],$r['ip'],$r['type'],$r['mac'],$r['sysoid'],$r['sysdesc'],$r['sysloc']);
         }

/*
         foreach ($array_user_fields as $field){
            $row_data[]=$r[$field];
         }
*/

         $nav = ObtenerNavegador($_SERVER['HTTP_USER_AGENT']);
         foreach ($array_user_fields as $field){
            if($a_user_fields_types[$field]==2 && $r[$field]!='-'){
               $uri=URINavegator($r[$field],$nav);
               $row_data[]="<a href='$uri' target='_blank'>link<a>";
            }
            elseif($a_user_fields_types[$field]==3){
               $aux_json_kk = json_decode($r[$field]);
               // $row_data[]=array('value'=>implode("<br>",$aux_json_kk));
               $aux_val = '';
               if(count($aux_json_kk)>0){
                  $aux_val.= '<ul style="padding-left: 15px;">';
                  foreach($aux_json_kk as $_) $aux_val.="<li>$_</li>";
                  $aux_val.='</ul>';
               }
               $row_data[]=$aux_val;
            }
            else{
               $row_data[]=$r[$field];
            }
         }

         $row_user = array('ip'=>$r['ip'],'id_dev'=>$r['id_dev'],'idd'=>'ALL','name'=>$r['name']);
         $tabla->addRow($row_meta,$row_data,$row_user);
      }
      $result = doQuery('cnm_get_devices_tree_common_count',$data);
      $cuantos = $result['obj'][0]['cuantos'];

      $tabla->showData($cuantos,$posStart);
   }
   function isGlobalAdmin($SESION){
      global $dbc;
		if ($SESION['GLOBAL']==0) return 0;
		else return 1;
	}

	
   function set_devices_status ($cid,$status,$id_devs) {

      $a_id_dev = explode(',',$id_devs);

      foreach($a_id_dev as $id_dev){
         $o_dev = new device($id_dev);
         $h_return=$o_dev->status($status,$cid);
         $dataXML = $h_return;
         if($h_return['rc']==1) break;
      }

      // Se hace el workset para replicar en las tablas work_xxx
	   $outputfile='/dev/null';
   	$pidfile='/tmp/pid';
      $cmd="/usr/bin/sudo /opt/crawler/bin/workset -i $id_devs -c $cid 2>&1";
		$user=$_SESSION['LUSER'];
      CNMUtils::debug_log(__FILE__, __LINE__, "set_devices_status: user=$user STATUS=$status CMD=$cmd");
   	exec(sprintf("%s > %s 2>&1 & echo $! >> %s", $cmd, $outputfile, $pidfile));

		return $dataXML;
   }


	class template{
		public $href;
		public $a_tpl;
		public $tpl;
		public function __construct($href,$a_tpl,$a_block=null){
			$this->href=$href;
			$this->a_tpl=$a_tpl;
			$this->tpl = new TemplatePower($this->href=$href);
   		$this->tpl->prepare();
   		$this->tpl->assign($this->a_tpl);

			//print_r($a_block);
			if(!is_null($a_block)){
				foreach($a_block as $id_block=>$a_value_block){
					// print "$id_block<br>";
					foreach($a_value_block as $value_block){
						// print "$value_block<br>";
						$this->tpl->newBlock($id_block);
						$this->tpl->assign($value_block);
					}
				}
			}
   		$this->tpl->printToScreen();
		}
	}

	class device{
		private $_data = array(
			'id_dev'=>0,
			'ip'=>null,
			'status'=>null,
			'name'=>null,
			'domain'=>null,
		);
      public function __construct($id_dev=0){
         $this->_data['id_dev']=$id_dev;

			if ($this->_data['id_dev']!=0){
				$data   = array('__ID_DEV__'=>$this->_data['id_dev']);
	         $result = doQuery('get_device_data',$data);
				$r = $result['obj'][0];
				$this->_data['ip']     = $r['ip'];
				$this->_data['status'] = $r['status'];
				$this->_data['name']   = $r['name'];
				$this->_data['domain'] = $r['domain'];
			}
      }
		public function id_dev(){
			return $this->_data['id_dev'];
		}
		public function ip($ip=-1){
         // GET
         if($ip=='-a') return $this->_data['ip'];
         // SET
         else{
				$this->_data['ip'] = $ip;
            $data = array('__ID_DEV__'=>$this->_data['id_dev'],'__IP__'=>$this->_data['ip']);
            $result = doQuery('set_device_ip',$data);
			}
		}


//		public function status_devices($cid,$status,$id_devs) {
//
//			$a_id_dev = explode(',',$id_devs);
//
//   		foreach($a_id_dev as $id_dev){
//      		$o_dev = new device($id_dev);
//      		$h_return=$o_dev->status($status,$cid);
//      		$dataXML = $h_return;
//      		if($h_return['rc']==1) break;
//   		}
//
//	      // Se hace el workset para replicar en las tablas work_xxx
//   	   $results=Array();
//      	$cmd="/usr/bin/sudo /opt/crawler/bin/workset -i $id_devs -c $cid 2>&1";
//			$user=$_SESSION['LUSER'];
//      	CNMUtils::debug_log(__FILE__, __LINE__, "status_devices: USER=$user changed STATUS=$status CMD=$cmd");
//      	exec($cmd,$results);
//
//   		responseXML($dataXML);
//		}




		public function status($status=-1,$cid='default'){
			// 0 => Activo
			// 1 => Baja
			// 2 => Mantenimiento
			$a_status = array('0'=>'Activo', '1'=>'Baja', '2'=>'Mantenimiento');
			$a_msg = array(
				'0'=>array(
					'ok'=>'Se han activado los dispositivos correctamente',
					'nook'=>'Ha habido algún problema al activar los dispositivos',
				),
				'1'=>array(
					'ok'=>'Se han dado de baja los dispositivos correctamente',
					'nook'=>'Ha habido algún problema al dar de baja los dispositivos',
				),
				'2'=>array(
					'ok'=>'Se han puesto en mantenimiento los dispositivos correctamente',
					'nook'=>'Ha habido algún problema al poner en mantenimiento los dispositivos',
				),
			);
			$return = array('rc'=>'','msg'=>'','query'=>'');
			// GET
			if($status=='-1') return $this->_data['status'];
			// SET
			else{
				$this->_data['status'] = $status;
				$data = array('__ID_DEV__'=>$this->_data['id_dev'],'__STATUS__'=>$this->_data['status']);
				$result = doQuery('set_device_status',$data);
			   if ($result['rc']!='0'){
					$return['rc']    = 1;
					$return['msg']   = $a_msg[$this->_data['status']]['nook'];
					$return['query'] = $result['query'];
				}else{
					$return['rc']  = 0;
					$return['msg'] = $a_msg[$this->_data['status']]['ok'];
					info_qactions('Estado dispositivo',$_SESSION['LUSER'],0,"El usuario {$_SESSION['LUSER']} ha cambiado el estado del dispositivo:<br>Id={$this->_data['id_dev']}<br>Nombre={$this->_data['name']}.{$this->_data['domain']}<br>ip={$this->_data['ip']}<br>Estado={$a_status[$this->_data['status']]}");	
					// Se lanza una generacion de metricas. Necesaria para que:
				   // 1. Los crawlers detecten la situacion de baja/mantenimiento.
			   // 2. Arreglar el nombre/dominio si se cambia en los label de las metricas.
				//   store_qactions('setmetric',"id_dev=".$this->_data['id_dev'].";cid=".$cid,'',"GENERAR METRICAS DESDE PLANTILLA (MODIFICADO DISPOSITIVO: ".$this->_data['ip']."  [".$this->_data['id_dev']."])");

				}
				return $return;
			}
		}



		public function mod(){
			$data = array('__ID_DEV__'=>$this->_data['id_dev']);
			$sub_query = '';
			$concat = '';
			foreach ($this->_data as $key=>$value){
				if($key=='id_dev') continue;
				if(!is_null($this->_data[$key])){
               $subquery.="$key=$value".$concat;
               $concat = ',';
				}	
			}
		}
		public function create(){
		}
		// mes == metrica_en_curso
		public function mes_status($status,$id_metric){
         $a_status = array('0'=>'Activar', '1'=>'Desactivar');
         $a_msg = array(
            '0'=>array(
               'ok'=>'Se han activado las métricas correctamente',
               'nook'=>'Ha habido algún problema al activar las métricas',
            ),
            '1'=>array(
               'ok'=>'Se han desactivado las métricas correctamente',
               'nook'=>'Ha habido algún problema al desactivar las métricas',
            ),
         );
         $return = array('rc'=>'','msg'=>'','query'=>'');
		   $data    = array('__STATUS__'=>$status,'__ID_METRIC__'=>$id_metric,'__ID_DEV__'=>$this->_data['id_dev']);
		   $result  = doQuery('dispositivo_mes_status',$data);

         if ($result['rc']!='0'){
            $return['rc']    = 1;
            $return['msg']   = $a_msg[$this->_data['status']]['nook'];
            $return['query'] = $result['query'];
         }else{
            $return['rc']  = 0;
            $return['msg'] = $a_msg[$this->_data['status']]['ok'];
         }
         return $return;
		}
      public function mes_delete($id_metric,$cid){
			$return=delete_metrics($id_metric,$cid);

//         $return  = array('rc'=>'','msg'=>'','query'=>'');
//         $data    = array('__ID_METRIC__'=>$id_metric,'__ID_DEV__'=>$this->_data['id_dev']);
//         $result  = doQuery('dispositivo_mes_delete',$data);
//         if ($result['rc']!='0'){
//            $return['rc']    = 1;
//            $return['msg']   = 'No se ha podido borrar la métrica';
//            $return['query'] = $result['query'];
//        }else{
//            $return['rc']  = 0;
//            $return['msg'] = 'Se ha borrado correctamente la métrica';
//         }
         return $return;
      }
      public function mes_correlate($id_metric){
         $return  = array('rc'=>'','msg'=>'','query'=>'');
         $data    = array('__ID_METRIC__'=>$id_metric,'__ID_DEV__'=>$this->_data['id_dev']);
         $result  = doQuery('dispositivo_mes_correlate_1',$data);
         if ($result['rc']!='0'){
            $return['rc']    = 1;
            $return['msg']   = 'No se ha podido modificar la métrica';
            $return['query'] = $result['query'];
         }else{
         	$result  = doQuery('dispositivo_mes_correlate_2',$data);
         	$result  = doQuery('dispositivo_mes_correlate_3',$data);
            $return['rc']  = 0;
            $return['msg'] = 'Se ha modificado correctamente la métrica';
         }
         return $return;
      }
		public function mes_counter(){
			$data    = array('__ID_DEV__'=>$this->_data['id_dev']);
			$result  = doQuery('active_metrics_devices_by_id',$data);
			return $result['obj'][0]['cuantos'];
		}
	}
function flot_sql($input){
   $graph_type     = $input['graph_type']; // metric|subview
   $id             = $input['id'];
   $lapse          = $input['lapse'];
   $lapse_start    = isset($input['lapse_start'])?$input['lapse_start']:'';
   $lapse_end      = isset($input['lapse_end'])?$input['lapse_end']:'';
   $last_timestamp = $input['last_timestamp'];
   $lapse_rrd      = 300;
   $null           = '';
	
	$sec_offset = date('Z');

   if($graph_type=='metric'){
      $id_metric = $id;
      $dataq     = array('__ID_METRIC__'=>$id_metric);
      $result    = doQuery('metric_alert',$dataq);
      $type      = $result['obj'][0]['type'];
      $subtype   = $result['obj'][0]['subtype'];
      $mtype     = $result['obj'][0]['mtype'];
      $file      = $result['obj'][0]['file'];
      $lapse_rrd = $result['obj'][0]['lapse'];
      $id_dev    = $result['obj'][0]['id_dev'];
      $iid       = $result['obj'][0]['iid'];
      $items     = explode('|',$result['obj'][0]['items']);
      $num_items = count($items);
      $c_items   = explode('|',$result['obj'][0]['c_items']);


		$dataq         = array('__ID_METRIC__'=>$id_metric);
		$result        = doQuery('metric',$dataq);
		$aux_subtable  = $result['obj'][0]['subtable'];
		if($aux_subtable<0){
         CNMUtils::error_log(__FILE__, __LINE__, "FLOT_SQL::AUX_SUBTABLE<0::ID=$id::GRAPH_TYPE=$graph_type::LAPSE=$lapse::LAPSE_START=$lapse_start::LAPSE_END=$lapse_end::LAST_TIMESTAMP=$last_timestamp");
			return;
		}
		$subtable = str_pad($aux_subtable, 3, "0", STR_PAD_LEFT);
		$mode_store = ($lapse=='year')?'store':'raw';
			
      $table     = str_replace('-','_',"onmgraph.__{$mode_store}__{$subtable}__{$num_items}__{$type}__{$subtype}");
      #$table     = str_replace('-','_',"onmgraph.__raw__000__{$num_items}__{$type}__{$subtype}");
		#print "TABLE == $table<br>";
		#print "FLOT_SQL::AUX_SUBTABLE<0::ID=$id::GRAPH_TYPE=$graph_type::LAPSE=$lapse::LAPSE_START=$lapse_start::LAPSE_END=$lapse_end::LAST_TIMESTAMP=$last_timestamp<br>";
   }elseif($graph_type=='subview'){
      $id_cfg_subview = $id;
      $subtype        = 'subview';
      $file           = str_pad($id_cfg_subview, 6, "0", STR_PAD_LEFT).'.rrd';
      $items          = array('Rojas','Naranjas','Amarillas');
      $dir_rrd        = '/opt/data/rrd/views';
   }

   $data = array();
   $num_fields = $num_items;
   for ($i=0;$i<$num_fields;$i++){
      $data['flot']['label'][$i]=($c_items[$i]!='')?$c_items[$i]:$items[$i];
      $data['flot']['lines'][$i]=array('show'=>true,'fill'=>true);
   }
	if($lapse=='custom'){
		$date_start=$lapse_start;
		$date_end=$lapse_end;
   }
	// Últimas 24 horas
	elseif ($lapse=='today'){
      $aux = lapse_flot(0);
		$date_start = ($last_timestamp==0)?time()-86400:$last_timestamp;
      $date_end   = time();
	}
	elseif ($lapse=='hour'){
      $date_end   = time();
      $date_start = $date_end-3600;
  	}
	elseif ($lapse=='minute'){
      $date_end   = time();
      $date_start = $date_end-60;
   }
	elseif ($lapse=='year'){
      $res = 86400; // 60*60*24
      $date_end = (floor(time()/$res)*$res);
      $date_start = $date_end-(365*86400);
   }
	elseif ($lapse=='month'){
		$res = ($lapse_rrd == 300)?7200:3600;
      $date_end = (floor(time()/$res)*$res);
      $date_start = $end-(30*86400);
   }
	elseif ($lapse=='week'){
		$res = ($lapse_rrd == 300)?1800:900;
      $date_end = (floor(time()/$res)*$res);
      $date_start = $end-(7*86400);
   }
	// Hace X dias (dia completo)
	elseif(strpos($lapse,'day_')!==false){
      $n = str_replace('day_','',$lapse);
		$date_start = strtotime(date('Y-m-d', strtotime("-$n days")). '00:00:00');
		$date_end   = strtotime(date('Y-m-d', strtotime("-$n days")). '23:59:59');
      // $aux = lapse_flot(86400*$n);
      // $date_start = $aux[0];
      // $date_end   = $aux[1];
   }
	elseif(strpos($lapse,'hour_')!==false){
      $n = str_replace('hour_','',$lapse);
      $date_end   = $time()-(($n-1)*3600);
      $date_start = $date_end-3600;
	}
	elseif(strpos($lapse,'minute_')!==false){
      $n = str_replace('minute_','',$lapse);
      $date_end   = $time()-(($n-1)*60);
      $date_start = $date_end-60;
   }

else return;


$date_start = $date_start-1800;
CNMUtils::info_log(__FILE__, __LINE__, "**flot_sql** START=$date_start START_AUX=".date('r',$date_start)." END=$date_end END_AUX=".date('r',$date_end));


	$dataq = array('__TABLE__'=>$table,'__ID_DEV__'=>$id_dev,'__DATE_START__'=>$date_start,'__DATE_END__'=>$date_end+3600,'__HIID__'=>$iid);
   $result = doQuery('flot_sql',$dataq);
   CNMUtils::info_log(__FILE__, __LINE__, "**flot_sql** SQL={$result['query']}");
   // print_r($result);

	if ($lapse=='year'){
      $aux_data = array();
      $a_timestamp = array();
      foreach ($result['obj'] as $r){
         for($i=1;$i<=$num_items;$i++){
            $v         = "v{$i}";
				$n_val     = "v{$i}avg";
				$timestamp = $r['ts_line'];
				$val       = $r["$n_val"];
				$aux_data[$v][$timestamp]=$val;
            $a_timestamp[$timestamp]=0;
         }
      }
	}
	elseif($lapse=='month'){
      $aux_data = array();
      $a_timestamp = array();
      foreach ($result['obj'] as $r){
         for($i=1;$i<=$num_items;$i++){
            $v         = "v{$i}";
				$n_val     = "v{$i}avg";
            $timestamp = $r['ts_line'];
            $val       = $r["$n_val"];
            $aux_data[$v][$timestamp]=$val;
            $a_timestamp[$timestamp]=0;
         }
      }
	}
	else{
		$aux_data = array();
		$a_timestamp = array();
	   foreach ($result['obj'] as $r){
			for($i=1;$i<=$num_items;$i++){
				$v="v{$i}";
				$a_val=explode(';',$r[$v]);
				foreach($a_val as $raw_val){
					list($timestamp,$val)=explode(':',$raw_val);
					//	$val=($val==='U')?'':$val;
					$aux_data[$v][$timestamp]=$val;
					$a_timestamp[$timestamp]=0;
				}
			}
		}
	}
	//	print_r($aux_data);
	foreach ($a_timestamp as $timestamp => $kk){
		$a_value = array();
		for($i=1;$i<=$num_items;$i++){
         $v="v{$i}";

			$value = $aux_data[$v][$timestamp];
         if ($subtype=='disp_icmp' or $subtype=='status_mibii_if'){
            if ($value == 0) $value = 'nan';
            elseif ($value == 1) $value=(int)$value;
            // $value=($value==='nan')?$null:$value;
				$value=(strpos($value,'nan')!==false)?$null:$value;
            $a_value[]=(string)$value;
         }elseif($subtype=='traffic_mibii_if'){
            // En el fichero rrd la unidad es B/s y nosotros lo pasamos a b/s
            if ($value == 0 or $value == 1) $value=(int)$value;
            // $value=($value==='nan')?$null:$value*8;
				$value=(strpos($value,'nan')!==false)?$null:$value*8;
            $a_value[]=(string)$value;
         }
         elseif($mtype=='STD_SOLID'){
            if ($value == 0) $value = 'nan';
         	elseif ($value == 1) $value=(int)$value;
            // $value=($value==='nan')?$null:$value;
				$value=(strpos($value,'nan')!==false)?$null:$value;
            $a_value[]=(string)$value;
         }
         else{
            if ($value == 0 or $value == 1) $value=(int)$value;
            // $value=($value==='nan')?$null:$value;
				$value=(strpos($value,'nan')!==false)?$null:$value;
            $a_value[]=(string)$value;
         }
/*
         if ($subtype=='disp_icmp' or $subtype=='status_mibii_if'){
               if ($value == 0) $value = 'nan';
               elseif ($value == 1) $value=(int)$value;
               $value=($value==='nan')?$null:$value;
               $a_value[]=(string)$value;
            }
         }elseif($subtype=='traffic_mibii_if'){
            for ($i=0;$i<$num_fields;$i++){
               // En el fichero rrd la unidad es B/s y nosotros lo pasamos a b/s
               $value=$c[$i+1];
               if ($value == 0 or $value == 1) $value=(int)$value;
               $value=($value==='nan')?$null:$value*8;
               $a_value[]=(string)$value;
            }
         }
         else{
            for ($i=0;$i<$num_fields;$i++){
               $value=$c[$i+1];
               if ($value == 0 or $value == 1) $value=(int)$value;
               $value=($value==='nan')?$null:$value;
               $a_value[]=(string)$value;
            }
         }
*/





/*
			$a_value[]=$aux_data[$v][$timestamp];
*/
		}
		$timestamp_js = ($timestamp+$sec_offset);
     	$data['flot']['data'][]=array('t'=>$timestamp_js/10,'v'=>$a_value);
	}
	//print_r($data);
	// Nos protegemos del caso de que no haya datos de la métrica
   if(!is_array($data['flot']['data']))  $data['flot']['data'][]=array('t'=>'','v'=>'');
   $data['meta']['num_items']=$num_items;
   return($data);

/*
		$aux_data[][	

      $c = preg_split ("[[:space:]]+",chop(fgets($fp)));
      $campos=array();
      if ($c[0] == 'timestamp' or $c[0]=='') continue;
      else {
         $timestamp = str_replace(':','',$c[0]);
         $a_last_timestamp[]=$timestamp;
         // $timestamp_js = ($timestamp+7200)*1000;
         $timestamp_js = ($timestamp+7200);

         $a_value = array();
         if ($subtype=='disp_icmp' or $subtype=='status_mibii_if'){
            for ($i=0;$i<$num_fields;$i++){
               $value=$c[$i+1];
               if ($value == 0) $value = 'nan';
               elseif ($value == 1) $value=(int)$value;
               $value=($value==='nan')?$null:$value;
               $a_value[]=(string)$value;
            }
         }elseif($subtype=='traffic_mibii_if'){
            for ($i=0;$i<$num_fields;$i++){
               // En el fichero rrd la unidad es B/s y nosotros lo pasamos a b/s
               $value=$c[$i+1];
               if ($value == 0 or $value == 1) $value=(int)$value;
               $value=($value==='nan')?$null:$value*8;
               $a_value[]=(string)$value;
            }
         }
         else{
            for ($i=0;$i<$num_fields;$i++){
               $value=$c[$i+1];
               if ($value == 0 or $value == 1) $value=(int)$value;
               $value=($value==='nan')?$null:$value;
               $a_value[]=(string)$value;
            }
         }
      }
      $data['flot']['data'][]=array('t'=>$timestamp_js/10,'v'=>$a_value);
   }




   array_pop($a_last_timestamp);
   array_pop($a_last_timestamp);
   if(count($a_last_timestamp)!=0) $data['meta']['last_timestamp']=end($a_last_timestamp);
   else $data['meta']['last_timestamp']=$last_timestamp;

   $data['meta']['num_items']=$num_items;

   return($data);
*/
}

function flot($input){
	$graph_type     = $input['graph_type']; // metric|subview
	$id             = $input['id'];
	$lapse          = $input['lapse'];
   $lapse_start    = isset($input['lapse_start'])?$input['lapse_start']:'';
   $lapse_end      = isset($input['lapse_end'])?$input['lapse_end']:'';
	$last_timestamp = $input['last_timestamp'];
   $lapse_rrd      = 300;
   $null           = '';

	$sec_offset = date('Z');
	// Array con los valores máximos definidos en la métrica/vista
	$a_top_value = array();

   if($graph_type=='metric'){
      $id_metric = $id;
      $dataq     = array('__ID_METRIC__'=>$id_metric);
      $result    = doQuery('metric_alert',$dataq);
      // SSV: En caos de no existir la métrica se sale
      if($result['cont'] == 0) {
			metric_error($id_metric);
			return;
		}
      $subtype   = $result['obj'][0]['subtype'];
      $file      = $result['obj'][0]['file'];
      $lapse_rrd = $result['obj'][0]['lapse'];
		$mtype     = $result['obj'][0]['mtype'];
      $items     = explode('|',$result['obj'][0]['items']);
      $c_items   = explode('|',$result['obj'][0]['c_items']);
		$top_value = ($result['obj'][0]['top_value']=='')?'':$result['obj'][0]['top_value'];

		// Valores máximos
		if($top_value!=''){
			$aux_top_cont=1;
			$aux_top_value = explode('|',$top_value);
			foreach ($aux_top_value as $_){
				if($_=='') continue;
				//$a_top_value[$aux_top_tag] = $_;
				$a_top_value[] = $_;

				$aux_top_tag = "LEVEL".$aux_top_cont;
				if($result['obj'][0]['c_items']!='')$c_items[] = $aux_top_tag;
	         $items[]   = $aux_top_tag;

	         $aux_top_cont++;
			}
		}		
      $dir_rrd   = '/opt/data/rrd/elements';
   }
	elseif($graph_type=='subview'){
      $id_cfg_subview = $id;
      $subtype        = 'subview';
      $file           = str_pad($id_cfg_subview, 6, "0", STR_PAD_LEFT).'.rrd';
      $items          = array('Rojas','Naranjas','Amarillas');
      $dir_rrd        = '/opt/data/rrd/views';
   }
   $data = array();
   $num_fields = count($items);

	// ///////////////////////////////////////////////// //
	// START: Manejo del tipo de linea (rellena o hueca) //
	// ///////////////////////////////////////////////// //

	// ITEMS NORMALES
   for ($i=0;$i<$num_fields-count($a_top_value);$i++){
      $data['flot']['label'][$i]=(isset($c_items[$i]) and $c_items[$i]!='')?$c_items[$i]:$items[$i];
		$data['flot']['checked'][$i] = 'true';
		$data['flot']['type'][$i] = 'normal';
		// SSV: Aquí se indica si debe estar rellena la gráfica o no
		if (preg_match('/SOLID/',$mtype)) {
			$data['flot']['lines'][$i]=array('show'=>true,'fill'=>true);
		}
		elseif ($num_fields-count($a_top_value)>=4) {
	      $data['flot']['lines'][$i]=array('show'=>true);
		}
		else{
	      $data['flot']['lines'][$i]=array('show'=>true,'fill'=>true);
		}
   }

	// ITEMS LEVEL o TOP
	for ($j=0;$j<count($a_top_value);$j++){
      $data['flot']['label'][]=(isset($c_items[$num_fields-count($a_top_value)+$j]) and $c_items[$num_fields-count($a_top_value)+$j]!='')?$c_items[$num_fields-count($a_top_value)+$j]:$items[$num_fields-count($a_top_value)+$j];
		$data['flot']['checked'][] = 'false';
		$data['flot']['type'][] = 'top';
		$data['flot']['lines'][] = array('show'=>true);
	}

	// /////////////////////////////////////////////// //
	// END: Manejo del tipo de linea (rellena o hueca) //
	// /////////////////////////////////////////////// //


	if($lapse=='custom'){
      $start = $lapse_start;
      $end   = $lapse_end;
   }
	// Último día
	elseif ($lapse=='today'){
/*
      $aux = lapse_flot(0);
		$start = ($last_timestamp==0)?time()-86400:$last_timestamp;
      $end   = 'now';
*/
		$start = ($last_timestamp==0)?strtotime(date("Y-m-d H:i:s",strtotime("-1 days"))):$last_timestamp;
		$end   = strtotime(date("Y-m-d H:i:s"));
   }
	// Último año
	elseif ($lapse=='year'){
      $res = 86400; // 60*60*24
/*
      $end = (floor(time()/$res)*$res);
      $start = $end-(365*86400);
*/
      $start = strtotime(date("Y-m-d H:i:s",strtotime("-1 years")));
      $end   = strtotime(date("Y-m-d H:i:s"));
   }
	// Último mes
	elseif ($lapse=='month'){
		$res = ($lapse_rrd == 300)?7200:3600;
/*
      $end = (floor(time()/$res)*$res);
      $start = $end-(30*86400);
*/
      $start = strtotime(date("Y-m-d H:i:s",strtotime("-1 months")));
      $end   = strtotime(date("Y-m-d H:i:s"));
   }
	// Última semana
	elseif ($lapse=='week'){
		$res = ($lapse_rrd == 300)?1800:900;
/*
      $end = (floor(time()/$res)*$res);
      $start = $end-(7*86400);
*/
      $start = strtotime(date("Y-m-d H:i:s",strtotime("-1 weeks")));
      $end   = strtotime(date("Y-m-d H:i:s"));
   }
	// Hace X días, el día completo
	elseif(strpos($lapse,'day_')!==false){
      $n = str_replace('day_','',$lapse);
      $start = strtotime(date('Y-m-d', strtotime("-$n days")). '00:00:00');
      $end   = strtotime(date('Y-m-d', strtotime("-$n days")). '23:59:59');
/*
      $n = str_replace('day_','',$lapse);
      $aux = lapse_flot(86400*$n);
      $start = $aux[0];
      $end   = $aux[1];
*/
   }
   // Hace X meses, el mes completo
   elseif(strpos($lapse,'month_')!==false){
      $n = str_replace('month_','',$lapse);
      $start = strtotime(date('Y-m-01', strtotime("-$n months")). '00:00:00');
      $end   = strtotime(date('Y-m-t',  strtotime("-$n months")). '23:59:59');
   }
/*
   // Hace X semanas, la semana completa
   elseif(strpos($lapse,'week_')!==false){
      $n = str_replace('week_','',$lapse);
      $start = strtotime(date('Y-m-d', strtotime("-$n weeks")). '00:00:00');
      $end   = strtotime(date('Y-m-d', strtotime("-$n weeks")). '23:59:59');

	//$fstSunday = date("d-F-Y", strtotime("first Sunday of ".date('M')." ".date('Y')."")); $weekArray = getfstlastdayOfWeekofmonth($fstSunday); 
   }
*/
	elseif($lapse=='other'){
      $start = $input['start'];
      $end   = $input['end'];
   }
	else return;

	CNMUtils::info_log(__FILE__, __LINE__, "**flot** START=$start END=$end");
	$cf = (strpos($file,'STDMM')!==false)?'MAX':'AVERAGE';
   $a_last_timestamp = array();

   if ($lapse == 'year' or $lapse == 'month' or $lapse == 'week') $cmd="/opt/rrdtool/bin/rrdtool fetch $dir_rrd/$file $cf -r $res -s $start -e $end";
   else $cmd="/opt/rrdtool/bin/rrdtool fetch $dir_rrd/$file $cf -s $start -e $end";
	
	// print_r($cmd);
	CNMUtils::info_log(__FILE__, __LINE__, "**flot** CMD=$cmd");

	$flag = 0;
	if (file_exists("$dir_rrd/$file")){
	   $fp = popen($cmd, "r");
	   while( !feof( $fp )){
	      // $c = preg_split ("[[:space:]]+",chop(fgets($fp)));
	      $c = preg_split ("/\s+/",chop(fgets($fp)));
	      $campos=array();
	      if ($c[0] == 'timestamp' or $c[0]=='') continue;
	      else {

	         $timestamp = str_replace(':','',$c[0]);
	         $a_last_timestamp[]=$timestamp;
	         $timestamp_js = ($timestamp+$sec_offset);
	
	         $a_value = array();
				// DISPONIBILIDAD O ESTADO DE INTERFACES
	         if ($subtype=='disp_icmp' or $subtype=='status_mibii_if'){
	            for ($i=0;$i<$num_fields-count($a_top_value);$i++){
	               $value=$c[$i+1];
						if ($value == '0') $value = 'nan';
	               elseif ($value == '1') $value=(int)$value;
						$value=(strpos($value,'nan')!==false)?$null:$value;
	               $a_value[]=(string)$value;
	            }
               for($j=0;$j<count($a_top_value);$j++){
                  $a_value[]=(string)$a_top_value[$j];
               }
	         }
				// TRÁFICO DE INTERFAZ
				elseif($subtype=='traffic_mibii_if'){
	            for ($i=0;$i<$num_fields-count($a_top_value);$i++){
		            // En el fichero rrd la unidad es B/s y nosotros lo pasamos a b/s
		            $value=$c[$i+1];
		            if ($value == '0' or $value == '1') $value=(int)$value;
						$value=(strpos($value,'nan')!==false)?$null:$value*8;
		            $a_value[]=(string)$value;
	            }
					for($j=0;$j<count($a_top_value);$j++){
                  $a_value[]=(string)$a_top_value[$j];
               }
	         }
				// 
				elseif($mtype=='STD_SOLID'){
               for ($i=0;$i<$num_fields-count($a_top_value);$i++){
                  $value=$c[$i+1];
                  if ($value == '0') $value = 'nan';
	               elseif ($value == '1') $value=(int)$value;
						$value=(strpos($value,'nan')!==false)?$null:$value;
                  $a_value[]=(string)$value;
               }
               for($j=0;$j<count($a_top_value);$j++){
                  $a_value[]=(string)$a_top_value[$j];
               }
				}
				// RESTO DE MÉTRICAS
	         else{
               for ($i=0;$i<$num_fields-count($a_top_value);$i++){
                  $value=$c[$i+1];
                  if ($value == '0' or $value == '1') $value=(int)$value;
                  $value=(strpos($value,'nan')!==false)?$null:$value;
                  $a_value[]=(string)$value;
               }
               for($j=0;$j<count($a_top_value);$j++){
                  $a_value[]=(string)$a_top_value[$j];
               }
	         }
				
	      }
			// Parche para que, en caso de que solo haya un valor en el fichero rrd aparezca algo en la gráfica porque hacen falta dos valores para que pinte flot
			// if($flag==0)$data['flot']['data'][]=array('t'=>($timestamp_js-10)/10,'v'=>$a_value);
			if($flag==0)$data['flot']['data'][]=array('t'=>($timestamp_js-1),'v'=>$a_value);
			$flag = 1;

	      // $data['flot']['data'][]=array('t'=>$timestamp_js/10,'v'=>$a_value);
	      $data['flot']['data'][]=array('t'=>$timestamp_js,'v'=>$a_value);
		}
   }else{
     $data['flot']['data'][]=array('t'=>'','v'=>'');
     $data['flot']['data'][]=array('t'=>'','v'=>'');
     $data['flot']['data'][]=array('t'=>'','v'=>'');
     $data['flot']['data'][]=array('t'=>'','v'=>'');
	}


   array_pop($a_last_timestamp);
   array_pop($a_last_timestamp);
   if(count($a_last_timestamp)!=0) $data['meta']['last_timestamp']=end($a_last_timestamp);
   else $data['meta']['last_timestamp']=$last_timestamp;

   $data['meta']['num_items']=$num_fields;





   array_pop($data['flot']['data']);
   array_pop($data['flot']['data']);

/*
 print_r($data);
 print("<br>");
*/

   return($data);
}
function lapse_flot($input){
   $tnow    = time();
   $dnow    = date("d/m/Y",$tnow);
   $dmy     = explode( "/", $dnow,3);
   $tnow0h  = time(0,0,0,$dmy[1],$dmy[0],$dmy[2]);
   $tday0h  = $tnow0h-$input;
   $tday24h = $tday0h+86400;
   return array($tday0h,$tday24h);
}
function subviewsFromView($id_cfg_view,$cid,$cid_ip){
	global $dbc;
	$a_id_cfg_subview = array();
	$data = array('__ID_CFG_VIEW__'=>$id_cfg_view,'__CID__'=>$cid,'__CID_IP__'=>$cid_ip);
	$result = doQuery('subvistas_de_vista',$data);
	foreach($result['obj'] as $r){
		$a_aux = subviewsFromView($r['id_cfg_subview'],$cid,$cid_ip);
		$a_id_cfg_subview[]=$r['id_cfg_subview'];
		$a_id_cfg_subview=array_merge($a_id_cfg_subview,$a_aux); 
   }
	return $a_id_cfg_subview;
}
/**
* aux_do3 => Funcion antigua de aux_do, se mantiene por si acaso
*/
function aux_do3($do,$hidx,$a_params){
	$data   = array('__HIDX__'=>$hidx);
   $result = doQuery('cnm_info_host',$data);
	$hip    = $result['obj'][0]['ip'];

   $sep      = "?";
   $params   = "";
   foreach($a_params as $key=>$value){
      $params.="$sep$key=$value";
      $sep='&';
   }

	$res = file_get_contents("http://$hip/onm/$do.php$params");
	CNMUtils::info_log(__FILE__, __LINE__, "**aux_do3** get=http://$hip/onm/$do.php$params");
	return $res;
}
function aux_do2($do,$hidx,$a_params){
   $data   = array('__HIDX__'=>$hidx);
   $result = doQuery('cnm_info_host',$data);
   $hip    = $result['obj'][0]['ip'];

	$postdata = http_build_query($a_params);
	$opts = array('http' =>
   	array(
      	'method'  => 'POST',
        	'header'  => 'Content-type: application/x-www-form-urlencoded',
        	'content' => $postdata
    	)
	);

	$context  = stream_context_create($opts);

   $res = file_get_contents("http://$hip/onm/$do.php",false,$context);

	$post = print_r($a_params,true);
   CNMUtils::info_log(__FILE__, __LINE__, "**aux_do2** get=http://$hip/onm/$do.php || post=$post");
   return $res;
}
function aux_do($do,$hip,$a_params,$a_header=array()){
	global $response_header;
   $postdata = http_build_query($a_params);

	$header='Content-type: application/x-www-form-urlencoded';
	foreach ($a_header as $header_key => $header_val) $header.="\r\n$header_key: $header_val";

   $opts = array(
		'http'=>array(
         'method'  => 'POST',
         // 'header'  => 'Content-type: application/x-www-form-urlencoded',
         'header'  => $header,
         'content' => $postdata,
      ),
      "ssl"=>array(
         "verify_peer"=>false,
         "verify_peer_name"=>false,
      ),
   );

   $context  = stream_context_create($opts);

	// $protocol = (isset($_SERVER['HTTPS']))?'https':'http';
	$protocol = 'https';
	// 0 => Devuelve datos | 1 => Devuelve un fichero (un fichero de backup por ejemplo)
	$is_file = 0;

	$do = rawurlencode($do);
	$do = str_replace('%2F','/',$do);
	// En caso de que el elemento contenga un punto, no dejamos que abra phps
	if(false!==strpos($do,'cgi-bin')){
		$url = "$protocol://$hip/onm/$do";
	}elseif(false!==strpos($do,'.') AND false===strpos($do,'php')){
		$url = "$protocol://$hip/onm/$do";
		$is_file = 1;
	}elseif($do=='thumbs_creator'){
		$url = "$protocol://$hip/onm/$do.php";
		$is_file = 2;
	}else{
		$url = "$protocol://$hip/onm/$do.php";
	}

   $res = file_get_contents($url,false,$context);
	if(1==$is_file){
		$http_response_header[] = "Content-Disposition: attachment; filename=".basename($do); 
	}elseif(2==$is_file){
		$http_response_header[] = "Content-Disposition: attachment; filename=thumb.png"; 
	}
//   $post = print_r($a_params,true);
//	$deb_post=preg_replace("/\s*\n/", " " , $post);
//	$deb_http_response_header = print_r($http_response_header,true);
//   CNMUtils::info_log(__FILE__, __LINE__, "**aux_do** get=$url || post=$deb_post || http_response_header=$http_response_header[0]");	
   CNMUtils::info_log(__FILE__, __LINE__, "**aux_do** get=$url || PHPSESSID=$a_params[PHPSESSID] hidx=$a_params[hidx] accion=$a_params[accion] || http_response_header=$http_response_header[0]");	
	if(!empty($res)){
		// Almacenamos en la variable $response_header los datos devueltos (tamaño,tipo de fichero, etc) para que 
		// la función aux_do_complete() ponga el header adecuado
		foreach($http_response_header as $response){
			@list($key,$value)=explode(':',$response);
			$response_header[$key]=$value;
		}
	   return $res;
	}else{
   	CNMUtils::error_log(__FILE__, __LINE__, "**aux_do** TIMEOUT get=$url || PHPSESSID=$a_params[PHPSESSID] hidx=$a_params[hidx] accion=$a_params[accion] || http_response_header=$http_response_header[0]");	
		return 'TIMEOUT';
	}
}
function aux_do_complete($post,$get=array(),$global=array(),$echo=1){
	global $response_header;
   $a_params = array();
   foreach($post as $key=>$value) $a_params[$key]=$value;
   foreach($get as $key=>$value)  $a_params[$key]=$value;
   $flag = 0;
	if (isset($global['argv']) and is_array($global['argv'])){
	   foreach($global['argv'] as $item){
	      if ($flag==0) $flag=1;
	      else{
	         list($key,$value)=explode('=',$item);
	         $a_params[$key]=$value;
	      }
	   }
	}

/*
	global $dbc;
	include_once('mysql_session.inc');
	mysql_session_open('',$a_params['PHPSESSID']);
	session_start();
*/
// 	print_r($_SESSION);


   $do   = $a_params['do'];
   $hidx = $a_params['hidx'];
   unset($a_params['do']);
   $hip = HIDX_Base::ip($hidx);
	
	$a_header = array(
		'User-Agent' => $_SERVER['HTTP_USER_AGENT'],
	);

/*
	// Keep-alive
	$a_keep_alive = array();
	foreach($_SESSION['A_HIDX'] as $id_hidx=>$k_hidx){
		if($k_hidx['status']=='TIMEOUT' or $k_hidx['status']=='NOREGISTER') continue;
		$k_do = 'mod_login';
		$k_hip = $k_hidx['ip'];
		$k_a_params = array('accion'=>'keepalive','PHPSESSID'=>$a_params['PHPSESSID']);
		$k_a_header = $a_header;
		$keep_alive_rcstr = aux_do($k_do,$k_hip,$k_a_params,$k_a_header);
		$a_keep_alive[$id_hidx]=$keep_alive_rcstr;
		CNMUtils::info_log(__FILE__, __LINE__, "**keep_alive_rcstr** ip=$k_hip|keep_alive_rcstr=$keep_alive_rcstr");
	}
	if ($a_keep_alive[$hidx]=='TIMEOUT'){
		header ("Location: ./fin_sesion.html");
		exit;
	}
*/

	// Petición
   $res = aux_do($do,$hip,$a_params,$a_header);

//   $deb_http_response_header = print_r($response_header,true);
//   CNMUtils::info_log(__FILE__, __LINE__, "**aux_do_complete** http_response_header=$deb_http_response_header");

//   $deb_http_response_header = print_r($response_header,true);
//   $deb1_http_response_header=preg_replace("/\s*\n/", " " , $deb_http_response_header);
//   CNMUtils::info_log(__FILE__, __LINE__, "**aux_do_complete** http_response_header=$deb1_http_response_header");

//   CNMUtils::info_log(__FILE__, __LINE__, "**aux_do_complete** res=$res");

	Header( "Content-type: {$response_header['Content-Type']}");

	// En caso de ser la descarga de un fichero, se le pone el nombre correcto
	if(isset($response_header['Content-Disposition'])){
		Header( "Content-Disposition: {$response_header['Content-Disposition']}");
	}
	// En caso de no descargar nada, de ser el resultado de una busqueda o una pagina, se quitan caracteres que pueden dar problemas
	else{
		// Se quitan caracteres de control =>
      //     http://www.w3schools.com/TAGS/ref_urlencode.asp
      //     http://stackoverflow.com/questions/1497885/remove-control-characters-from-php-string
      $res = preg_replace('/[\x00-\x09\x0B\x0C\x0E-\x1F\x7F]/','',$res);
      $res = str_replace(chr(127), "", $res);


		// Parte de proxy inverso
		if($hidx==1){
			if( array_key_exists('HTTPS',$_SERVER) && $_SERVER['HTTPS']=='on'){
				$res = str_replace('____PROXY____[proxy]', "https://".$_SERVER['SERVER_ADDR'].':'.$_SERVER['SERVER_PORT'], $res);
			}else{
				$res = str_replace('____PROXY____[proxy]', "http://".$_SERVER['SERVER_ADDR'].':'.$_SERVER['SERVER_PORT'], $res);
			}
		}else{
			$res = str_replace('____PROXY____[proxy]', "https://".$hip."/", $res);
		}
	}
	if ($echo==1) echo $res;
}
/**
 * Función para obtener las entradas no editables de la documentación
*/
function block_no_editable(&$a_block,$id_ref,$tip_type,$doc_title_block,$id_refn=''){
	// Entradas de sistema NO editables
	if($id_refn==''){
	   $datosQuery = array ('__ID_REF__'=>$id_ref,'__TIP_TYPE__'=>$tip_type);
	   $result     = doQuery('cnm_cfg_tips_get_ro_info_by_typeid',$datosQuery);
	}else{
	   $datosQuery = array ('__ID_REFN__'=>$id_refn,'__TIP_TYPE__'=>$tip_type);
	   $result     = doQuery('cnm_cfg_tips_get_ro_info_by_typeidrefn',$datosQuery);
	}
   foreach ($result['obj'] as $r){
      $aux_array = array(
         'id_tip'          => $r['id_tip'],
         'descr'           => str_replace("\n",'<BR>',$r['descr']),
         'name'            => str_replace("\n",'<BR>',$r['name']),
         'date'            => ($r['date']=='1970-01-01 01:00:00')?'':'<tr><td class="doc_date" colspan="3"><img src="images/mod_date16x16.png" style="width:14px;vertical-align:text-bottom;margin-right:2px">'.$r['date'].'</td></tr>',
			// 'date'         => $r['date'],
         'doc_title_block' => $doc_title_block,
         'position'        => $r['position'],
      );
      
      // $aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

      $a_block['entrada_documentacion_no_editable'][]=$aux_array;
	}
	/////////////////
	// GOOGLE MAPS //
	/////////////////
	if($tip_type=='id_dev'){
   	//$data   = array('__CNM_KEY__'=>'gmaps_key_id');
	   //$result = doQuery('get_cnm_config',$data);
		//if($result['obj'][0]['cnm_value']!=''){
		if(true){
			// $gmaps_key_id = $result['obj'][0]['cnm_value'];
			$gmaps_key_id = '';
			$data = array('__ID_DEV__'=>$id_ref);
			$result = doQuery('device_info_basic',$data);
			foreach($result['obj'] as $r){	
				if($r['geodata']=='') continue;
		      $aux_array = array(
		         'id_tip'          => 'gmaps',
		         'name'            => 'Localización',
		         'doc_title_block' => $doc_title_block,
					'geodata'         => $r['geodata'],
					'name'            => $r['name'],
					'gmaps_key_id'    => $gmaps_key_id
		      );
				$all_geodata = array();
				$data2 = array();
				$result2 = doQuery('all_devices_no_condition',$data2);
				foreach ($result2['obj'] as $r2){
					if($r2['geodata']=='') continue;
					$all_geodata[]=array('id_dev'=>$r2['id_dev'],'geodata'=>explode(',',$r2['geodata']),'name'=>$r2['name']);	
				};
				$aux_array['all_geodata'] = json_encode($all_geodata);
				$a_block['entrada_documentacion_no_editable_gmaps'][]=$aux_array;
			}
		}
	}
}
/**
 * Función para obtener las entradas editables de la documentación
*/
function block_editable(&$a_block,$id_ref,$tip_type,$doc_title_block,$id_refn=''){
   // Entradas de usuario SI editables
   if($id_refn==''){
	   $datosQuery = array ('__ID_REF__'=>$id_ref,'__TIP_TYPE__'=>$tip_type);
	   $result     = doQuery('cnm_cfg_tips_get_rw_info_by_typeid',$datosQuery);
	}else{
	   $datosQuery = array ('__ID_REFN__'=>$id_refn,'__TIP_TYPE__'=>$tip_type);
	   $result     = doQuery('cnm_cfg_tips_get_rw_info_by_typeidrefn',$datosQuery);
	}
   foreach ($result['obj'] as $r){
		$aux_array = array(
         'id_tip'          => $r['id_tip'],
         'descr'           => str_replace("\n",'<BR>',$r['descr']),
         'name'            => str_replace("\n",'<BR>',$r['name']),
         'date'            => $r['date'],
         'doc_title_block' => $doc_title_block,
         'editar'          => i18('_editar'),
         'guardar'         => i18('_guardar'),
         'borrar'          => i18('_borrar'),
         'subirfichero'    => i18('_subirfichero'),
         'verficheros'     => i18('_verficheros'),
         'hidx'            => _hidx,
         'do'              => _do,
         'SESIONPHP'       => SESIONPHP,
         'position'        => $r['position'],
      );

		$aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

		$a_block['entrada_documentacion_si_editable'][]=$aux_array;
   }
}

/**
 * Función para que aparezca la zona para añadir entradas a la documentación.
*/
function block_nueva_entrada(&$a_block){

	$aux_array = array(
      'hidx'            => _hidx,
      'SESIONPHP'       => SESIONPHP,
   );

   $aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

   $a_block['entrada_documentacion_nueva_entrada'][]=$aux_array;
}
/**
 * Función para obtener las entradas no editables correspondientes con los tickets de un dispositivo de la documentación
*/
function block_device_ticket(&$a_block,$id_dev){
   $datosQuery = array ('__ID_DEV__'=>$id_dev);
   $result     = doQuery('cnm_ticket_get_device_tickets_by_id',$datosQuery);
   foreach ($result['obj'] as $r){
		$ref = ($r['ref']=='')?$r['ref']:"[{$r['ref']}]";
		$aux_array = array(
         'descr'  => str_replace("\n",'<BR>',"{$r['descr']}"),
         'name'   => str_replace("\n",'<BR>',"{$r['name']} <font style='font-size: 11pt;'>$ref</font>"),
         'date'   => $r['date'],
      );

		// $aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

		$a_block['entrada_documentacion_ticket_no_editable'][]= $aux_array;
   }
}
/**
 * Función para obtener las entradas no editables correspondientes con los tickets de una alerta de la documentación
*/
function block_alert_ticket(&$a_block,$id_alert){
   $datosQuery = array ('__ID_ALERT__'=>$id_alert);
   $result     = doQuery('info_ticket',$datosQuery);
   foreach ($result['obj'] as $r){
		$ref = ($r['ref']=='')?$r['ref']:"[{$r['ref']}]";
		$aux_array = array(
         'descr'  => str_replace("\n",'<BR>',$r['descr']),
         'name'   => str_replace("\n",'<BR>',"{$r['cat_name']} <font style='font-size: 11pt;'>$ref</font>"),
         'date'   => $r['date_str'],
      );

		// $aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

		$a_block['entrada_documentacion_ticket_no_editable'][]=$aux_array;
   }
}
/**
 * Función para obtener TODAS las entradas de un dispositivo y las pone como no editables. Se utiliza en la documentación de vistas, alertas e histórico de alertas
*/
function block_device_doc(&$a_block,$id,$mode){
	$tip_type = 'id_dev';
	$doc_title_block = 'doc_title_block_device';
	$a_device = array();

	if($mode=='view'){
		$id_cfg_view = $id;
		// Se obtienen los id_dev de los dispositivos
		$datosQuery = array ('__ID_CFG_VIEW__'=>$id_cfg_view);
	   $result     = doQuery('metric_view',$datosQuery);
	   foreach ($result['obj'] as $r) $a_device[$r['id_dev']]=1;
	}elseif($mode=='alert'){
      $id_alert = $id;
      // Se obtienen los id_dev de los dispositivos
      $datosQuery = array ('__ID_ALERT__'=>$id_alert);
      $result     = doQuery('alert_info',$datosQuery);
      foreach ($result['obj'] as $r){
			$a_device[$r['id_device']]=1;


	   	/////////////////
	   	// GOOGLE MAPS //
	   	/////////////////
	      //$data2   = array('__CNM_KEY__'=>'gmaps_key_id');
	      //$result2 = doQuery('get_cnm_config',$data2);
	      //if($result2['obj'][0]['cnm_value']!=''){
			if(true){
	         // $gmaps_key_id = $result2['obj'][0]['cnm_value'];
	         $gmaps_key_id = '';
	         $data2 = array('__ID_DEV__'=>$r['id_device']);
	         $result2 = doQuery('device_info_basic',$data2);
	         foreach($result2['obj'] as $r2){
	            if($r2['geodata']=='') continue;
	            $aux_array = array(
	               'id_tip'          => 'gmaps',
	               'name'            => 'Localización',
	               'doc_title_block' => $doc_title_block,
	               'geodata'         => $r2['geodata'],
	               'name'            => $r2['name'],
	               'gmaps_key_id'    => $gmaps_key_id
	            );
	            $all_geodata = array();
	            $data3 = array();
	            $result3 = doQuery('all_devices_no_condition',$data3);
	            foreach ($result3['obj'] as $r3){
	               if($r3['geodata']=='') continue;
	               $all_geodata[]=array('id_dev'=>$r3['id_dev'],'geodata'=>explode(',',$r3['geodata']),'name'=>$r3['name']);
	            };
	            $aux_array['all_geodata'] = json_encode($all_geodata);
					$a_block['entrada_documentacion_no_editable_last_gmaps'][]=$aux_array;
	         }
	      }
		}
	}elseif($mode=='halert'){
      $id_alert = $id;
      // Se obtienen los id_dev de los dispositivos
      $datosQuery = array ('__ID_ALERT__'=>$id_alert);
      $result     = doQuery('halert_info',$datosQuery);
      foreach ($result['obj'] as $r){
			$a_device[$r['id_device']]=1;



         /////////////////
         // GOOGLE MAPS //
         /////////////////
         //$data2   = array('__CNM_KEY__'=>'gmaps_key_id');
         //$result2 = doQuery('get_cnm_config',$data2);
         //if($result2['obj'][0]['cnm_value']!=''){
			if(true){
            // $gmaps_key_id = $result2['obj'][0]['cnm_value'];
            $gmaps_key_id = '';
            $data2 = array('__ID_DEV__'=>$r['id_device']);
            $result2 = doQuery('device_info_basic',$data2);
            foreach($result2['obj'] as $r2){
               if($r2['geodata']=='') continue;
               $aux_array = array(
                  'id_tip'          => 'gmaps',
                  'name'            => 'Localización',
                  'doc_title_block' => $doc_title_block,
                  'geodata'         => $r2['geodata'],
                  'name'            => $r2['name'],
                  'gmaps_key_id'    => $gmaps_key_id
               );
               $all_geodata = array();
               $data3 = array();
               $result3 = doQuery('all_devices_no_condition',$data3);
               foreach ($result3['obj'] as $r3){
                  if($r3['geodata']=='') continue;
                  $all_geodata[]=array('id_dev'=>$r3['id_dev'],'geodata'=>explode(',',$r3['geodata']),'name'=>$r3['name']);
               };
               $aux_array['all_geodata'] = json_encode($all_geodata);
               $a_block['entrada_documentacion_no_editable_last_gmaps'][]=$aux_array;
            }
         }

		}
   }

	foreach ($a_device as $id_dev=>$trash){
		$id_ref=$id_dev;	

	   // Entradas de sistema NO editables
	   $datosQuery = array ('__ID_REF__'=>$id_ref,'__TIP_TYPE__'=>$tip_type);
	   $result     = doQuery('cnm_cfg_tips_get_ro_info_by_typeid',$datosQuery);
	   foreach ($result['obj'] as $r){


      	$aux_array = array(
            'id_tip' => $r['id_tip'],
            'descr'  => str_replace("\n",'<BR>',$r['descr']),
            'name'   => str_replace("\n",'<BR>',$r['name']),
            'date'   => $r['date'],
            'doc_title_block' => $doc_title_block,
         );

      	$aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

			$a_block['entrada_documentacion_no_editable_last'][]=$aux_array;
	   }

	   // Entradas de usuario SI editables
	   $datosQuery = array ('__ID_REF__'=>$id_ref,'__TIP_TYPE__'=>$tip_type);
	   $result     = doQuery('cnm_cfg_tips_get_rw_info_by_typeid',$datosQuery);
	   foreach ($result['obj'] as $r){

			$aux_array = array(
            'id_tip' => $r['id_tip'],
            'descr'  => str_replace("\n",'<BR>',$r['descr']),
            'name'   => str_replace("\n",'<BR>',$r['name']),
            'date'   => $r['date'],
            'doc_title_block' => $doc_title_block,
         );
	
			$aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

			$a_block['entrada_documentacion_no_editable_last'][]=$aux_array;
	   }
	}
}

/**
 * Función para obtener la documentación de las subvistas de una vista. Se usa para ver la documentación desde vistas.
*/
function block_subview_doc(&$a_block,$id_cfg_view){
   $tip_type = 'id_cfg_view';
   $doc_title_block = 'doc_title_block_device';

   // Se obtienen los id_cfg_view de las subvistas
	$esAdministradorGlobal=$_SESSION['GLOBAL'];
	$id_query=($esAdministradorGlobal)?'list_subviews_admin':'list_subviews_no_admin';

   $cid    = cid(_hidx);
   $cid_ip = local_ip();

	$data = array('__ID_USER__'=>$_SESSION['NUSER'],'__CID__'=>$cid,'__LOGIN_NAME__'=>$_SESSION['LUSER'],'__CID_IP__'=>$cid_ip);
   $result = doQuery($id_query,$data);
   foreach ($result['obj'] as $r){
		if($r['id_cfg_view']==$id_cfg_view){
		   // Entradas de sistema NO editables
			$data1 = array('__ID_CFG_VIEW__'=>$r['id_cfg_subview']);
			$result1 = doQuery('view',$data1);
			$subview_name = $result1['obj'][0]['name'];


		   $data1 = array ('__ID_REF__'=>$r['id_cfg_subview'],'__TIP_TYPE__'=>$tip_type);
		   $result1     = doQuery('cnm_cfg_tips_get_ro_info_by_typeid',$data1);
		   foreach ($result1['obj'] as $r1){
		      $aux_array = array(
		         'id_tip'          => $r1['id_tip'],
		         'descr'           => str_replace("\n",'<BR>',$r1['descr']),
		         'name'            => "Vista ($subview_name): ".str_replace("\n",'<BR>',$r1['name']),
		         'date'            => $r1['date'],
		         'doc_title_block' => $doc_title_block,
		         'position'        => $r1['position'],
		      );
		      
		      $aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());
		
		      $a_block['entrada_documentacion_no_editable_last'][]=$aux_array;
		   }
			$result1     = doQuery('cnm_cfg_tips_get_rw_info_by_typeid',$data1);
         foreach ($result1['obj'] as $r1){
            $aux_array = array(
               'id_tip'          => $r1['id_tip'],
               'descr'           => str_replace("\n",'<BR>',$r1['descr']),
		         'name'            => "Vista ($subview_name): ".str_replace("\n",'<BR>',$r1['name']),
               'date'            => $r1['date'],
               'doc_title_block' => $doc_title_block,
               'position'        => $r1['position'],
            );

            $aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

            $a_block['entrada_documentacion_no_editable_last'][]=$aux_array;
         }
		}
	}
}

/**
 * Función para obtener la documentación de las alertas remotas de una vista. Se usa para ver la documentación desde vistas.
*/
function block_viewremote_doc(&$a_block,$id_cfg_view){
   $tip_type = 'remote';
   $doc_title_block = 'doc_title_block_device';

   $data = array('__ID_CFG_VIEW__'=>$id_cfg_view);
   $result = doQuery('view_remote_remote_alerts',$data);
   foreach ($result['obj'] as $r){
      // Entradas de sistema NO editables
      $data1 = array ('__ID_REF__'=>$r['subtype'],'__TIP_TYPE__'=>$tip_type);
      $result1     = doQuery('cnm_cfg_tips_get_ro_info_by_typeid',$data1);
      foreach ($result1['obj'] as $r1){
         $aux_array = array(
            'id_tip'          => $r1['id_tip'],
            'descr'           => str_replace("\n",'<BR>',$r1['descr']),
            'name'            => "Alerta remota ({$r['descr']}): ".str_replace("\n",'<BR>',$r1['name']),
            'date'            => $r1['date'],
            'doc_title_block' => $doc_title_block,
            'position'        => $r1['position'],
         );

         $aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

         $a_block['entrada_documentacion_no_editable_last'][]=$aux_array;
      }
      $result1     = doQuery('cnm_cfg_tips_get_rw_info_by_typeid',$data1);
      foreach ($result1['obj'] as $r1){
         $aux_array = array(
            'id_tip'          => $r1['id_tip'],
            'descr'           => str_replace("\n",'<BR>',$r1['descr']),
            'name'            => "Alerta remota ({$r['descr']}): ".str_replace("\n",'<BR>',$r1['name']),
            'date'            => $r1['date'],
            'doc_title_block' => $doc_title_block,
            'position'        => $r1['position'],
         );

         $aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

         $a_block['entrada_documentacion_no_editable_last'][]=$aux_array;
      }
   }
}



/**
 * Función para obtener la documentación de una métrica. Se usa para ver la documentación desde alertas o histórico de alertas
*/
function block_metric_doc(&$a_block,$mname,$id_dev){
	$doc_title_block = 'doc_title_block_config';
   $datosQuery = array('__MNAME__'=>$mname,'__ID_DEV__'=>$id_dev);
	$result = doQuery('metric_info',$datosQuery);
	$mlabel = $result['obj'][0]['label'];

   $result = doQuery('doc_metricas_alerta',$datosQuery);
   foreach ($result['obj'] as $r){

		$aux_array = array(
         'descr' => str_replace("\n",'<BR>',$r['descr']),
         'name'  => str_replace("\n",'<BR>',"$mlabel: {$r['name']}"),
         'date'            => ($r['date']=='1970-01-01 01:00:00')?'':'<tr><td class="doc_date" colspan="3"><img src="images/mod_date16x16.png" style="width:14px;vertical-align:text-bottom;margin-right:2px">'.$r['date'].'</td></tr>',
         //'date'  => $r['date'],
         'url'   => str_replace("\n",'<BR>',$r['url']),
         'info'  => ($r['url']!='')?'[+info]':'',
         'doc_title_block' => $doc_title_block,
      );

		$aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

		$a_block['entrada_documentacion_no_editable'][]=$aux_array;
   }
}

/**
 * Función para obtener la documentación de una alerta remota. Se usa para ver la documentación desde alertas o histórico de alertas
*/
function block_remote_doc(&$a_block,$subtype,$id_dev){
   $doc_title_block = 'doc_title_block_config';
   $datosQuery = array('__SUBTYPE__'=>$subtype,'__ID_DEV__'=>$id_dev,'__MNAME__'=>$subtype);
   $result = doQuery('cnm_cfg_remote_info_by_subtype',$datosQuery);
   $descr = $result['obj'][0]['descr'];

   $result = doQuery('doc_remote_alerta',$datosQuery);
   foreach ($result['obj'] as $r){
      $aux_array = array(
         'descr' => str_replace("\n",'<BR>',$r['descr']),
         'name'  => str_replace("\n",'<BR>',"$descr: {$r['name']}"),
         'date'            => ($r['date']=='1970-01-01 01:00:00')?'':'<tr><td class="doc_date" colspan="3"><img src="images/mod_date16x16.png" style="width:14px;vertical-align:text-bottom;margin-right:2px">'.$r['date'].'</td></tr>',
         //'date'  => $r['date'],
         'url'   => str_replace("\n",'<BR>',$r['url']),
         'info'  => ($r['url']!='')?'[+info]':'',
         'doc_title_block' => $doc_title_block,
      );

      $aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

      $a_block['entrada_documentacion_no_editable'][]=$aux_array;
   }
}

/**
 * Función para obtener la documentación de una métrica. Se usa para ver la documentación desde monitores
*/
function block_metric_doc2(&$a_block,$monitor){
   $doc_title_block = 'doc_title_block_config';
   $datosQuery = array('__MONITOR__'=>$monitor);
   $result = doQuery('get_all_monitor',$datosQuery);
	$mname = $result['obj'][0]['mname'];
	$subtype = $result['obj'][0]['subtype'];
	$type = $result['obj'][0]['type'];

	if($type=='latency'){
		$data = array('__SUBTYPE__'=>$subtype);
		$result = doQuery('get_all_latency',$data);
   	$mlabel = $result['obj'][0]['description'];
	}
	elseif($type=='snmp'){
		$data = array('__SUBTYPE__'=>$subtype);
      $result = doQuery('get_all_snmp',$data);
   	$mlabel = $result['obj'][0]['descr'];
   }
   elseif($type=='xagent'){
		$data = array('__SUBTYPE__'=>$subtype);
      $result = doQuery('get_all_agent',$data);
   	$mlabel = $result['obj'][0]['description'];
   }

	$data = array('__MNAME__'=>$mname);
   $result = doQuery('doc_metricas_alerta',$data);
   foreach ($result['obj'] as $r){

      $aux_array = array(
         'descr' => str_replace("\n",'<BR>',$r['descr']),
         'name'  => str_replace("\n",'<BR>',"$mlabel: {$r['name']}"),
         'date'  => $r['date'],
         'url'   => str_replace("\n",'<BR>',$r['url']),
         'info'  => ($r['url']!='')?'[+info]':'',
         'doc_title_block' => $doc_title_block,
      );

      $aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

      $a_block['entrada_documentacion_no_editable_last'][]=$aux_array;
   }
}

/**
 * Función para obtener la documentación de un monitor. Se usa para ver la documentación desde alertas o histórico de alerta
s
*/
function block_monitor_doc(&$a_block,$id_alert_type){
	$doc_title_block = 'doc_title_block_monitor';
   $datosQuery = array('__ID_ALERT_TYPE__'=>$id_alert_type);
   $result = doQuery('a_cnm_cfg_monitor_get_monitor_by_id',$datosQuery);
   $mlabel = $result['obj'][0]['cause'];

	$data = array('__ID_ALERT_TYPE__'=>$id_alert_type);
	$result = doQuery('a_cnm_cfg_monitor_get_monitor_by_id',$data);
	$monitor = $result['obj'][0]['monitor'];

   //$datosQuery = array('__ID_REF__'=>$id_alert_type);
   $datosQuery = array('__ID_REF__'=>$monitor);
   $result = doQuery('doc_monitor',$datosQuery);
   foreach ($result['obj'] as $r){

		$aux_array = array(
         'descr' => str_replace("\n",'<BR>',$r['descr']),
         'name'  => str_replace("\n",'<BR>',"$mlabel: {$r['name']}"),
         'date'  => $r['date'],
         'url'   => str_replace("\n",'<BR>',$r['url']),
         'info'  => ($r['url']!='')?'[+info]':'',
         'doc_title_block' => $doc_title_block,
      );

		$aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

		$a_block['entrada_documentacion_no_editable_last'][]=$aux_array;

/*
      $a_block['entrada_documentacion_no_editable'][]=array(
         'descr' => str_replace("\n",'<BR>',$r['descr']),
         'name'  => str_replace("\n",'<BR>',"$mlabel: {$r['name']}"),
         'date'  => $r['date'],
         'url'   => str_replace("\n",'<BR>',$r['url']),
         'info'  => ($r['url']!='')?'[+info]':'',
	      'doc_title_block' => $doc_title_block,
      );
*/
   }
}

function block_script_doc(&$a_block,$script){
   $doc_title_block = 'doc_title_block_script';
	$mlabel=$script;
   $datosQuery = array('__ID_REF__'=>$script);
   $result = doQuery('doc_script',$datosQuery);
   foreach ($result['obj'] as $r){

		$aux_array = array(
         'descr' => str_replace("\n",'<BR>',$r['descr']),
         'name'  => str_replace("\n",'<BR>',"$mlabel: {$r['name']}"),
         'date'  => $r['date'],
         'url'   => str_replace("\n",'<BR>',$r['url']),
         'info'  => ($r['url']!='')?'[+info]':'',
         'doc_title_block' => $doc_title_block,
      );

		$aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

		$a_block['entrada_documentacion_no_editable_last'][]=$aux_array;
   }
}

function block_app_doc(&$a_block,$aname){
   $doc_title_block = 'doc_title_block_app';
   $datosQuery = array('__ANAME__'=>$aname);
   $result = doQuery('get_info_app',$datosQuery);
   $mlabel = $result['obj'][0]['name'];
   $datosQuery = array('__ID_REF__'=>$aname);
   $result = doQuery('doc_app',$datosQuery);
   foreach ($result['obj'] as $r){

		$aux_array = array(
         'descr' => str_replace("\n",'<BR>',$r['descr']),
         'name'  => str_replace("\n",'<BR>',"$mlabel: {$r['name']}"),
         'date'  => $r['date'],
         'url'   => str_replace("\n",'<BR>',$r['url']),
         'info'  => ($r['url']!='')?'[+info]':'',
         'doc_title_block' => $doc_title_block,
      );

		$aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

		$a_block['entrada_documentacion_no_editable_last'][]=$aux_array;
   }
}


/**
 * Función para obtener las notas de un dispositivo
*/
function block_device_notes(&$a_block,$id_dev){
   $data = array('__ID_DEV__'=>$id_dev);
   $result = doQuery('info_device',$data);
   $dname = $result['obj'][0]['name'];

   $data = array('__ID_REF__'=>$id_dev);
   $result = doQuery('doc_dispositivo_alerta',$data);
   foreach ($result['obj'] as $r){

		$aux_array = array(
         'descr' => str_replace("\n",'<BR>',$r['descr']),
         'name'  => str_replace("\n",'<BR>',"$dname: {$r['name']}"),
         'date'  => $r['date'],
         'url'   => str_replace("\n",'<BR>',$r['url']),
         'info'  => ($r['url']!='')?'[+info]':'',
      );

		$aux_array = array_merge($aux_array,$GLOBALS['mc']->msg());

		$a_block['entrada_documentacion_dispositivo'][]=$aux_array;
   }
}
/**
 * Función para borrar una entrada de la documentación
 */
function delete_doc($id_tip){
   $datosQuery = array ('__ID_TIP__'=>$id_tip);
   $result     = doQuery('cnm_cfg_tips_delete_by_id',$datosQuery);
   if ($result['rc']!=0) $a_response = array('rc'=>$result['rc'],'msg'=>"Ha habido algún problema al eliminar la entrada en documentación ({$result['rcstr']})");
   else $a_response = array('rc'=>0,'msg'=>'La documentacion se ha eliminado correctamente');
   echo json_encode($a_response);
}
/**
 * Función para guardar una entrada de la documentación
 */
function save_doc($id_tip,$id_ref,$title,$descr,$id_refn=0){
	$date   = time();
   // Insertar documentación
   if($id_tip==0){
		// SSV: Se quita mysql_real_escape_string porque ya se hace en doQuery() y en caso de dejarlos aquí también lo que pasa es que
		// una comilla doble se mete como \" en la BBDD
      // $datosQuery = array ('__DESCR__'=>mysql_real_escape_string($descr),'__ID_REF__'=>$id_ref,'__TIP_TYPE__'=>tip_type,'__DATE__'=>$date,'__NAME__'=>mysql_real_escape_string($title));
      $datosQuery = array ('__DESCR__'=>$descr,'__ID_REF__'=>$id_ref,'__TIP_TYPE__'=>tip_type,'__DATE__'=>$date,'__NAME__'=>$title,'__ID_REFN__'=>$id_refn);
      $result=doQuery('cnm_cfg_tips_store_create',$datosQuery);
	   if ($result['rc']!=0) $a_response = array('rc'=>$result['rc'],'msg'=>"Ha habido algún problema al crear la entrada en documentación ({$result['rcstr']})");
		else $a_response = array('rc'=>0,'msg'=>'La documentacion se ha almacenado correctamente'); 
   }
   // Modificar documentación
   else{
      // $datosQuery = array ('__ID_TIP__'=>$id_tip,'__ID_REF__'=>$id_ref,'__TIP_TYPE__'=>tip_type,'__DESCR__'=>mysql_real_escape_string($descr),'__DATE__'=>$date,'__NAME__'=>mysql_real_escape_string($title));
      $datosQuery = array ('__ID_TIP__'=>$id_tip,'__ID_REF__'=>$id_ref,'__TIP_TYPE__'=>tip_type,'__DESCR__'=>$descr,'__DATE__'=>$date,'__NAME__'=>$title);
      $result=doQuery('cnm_cfg_tips_store_update',$datosQuery);
		if ($result['rc']!=0) $a_response = array('rc'=>$result['rc'],'msg'=>"Ha habido algún problema al modificar la entrada en documentación ({$result['rcstr']})");
      else $a_response = array('rc'=>0,'msg'=>'La documentacion se ha modificado correctamente');
   }
   echo json_encode($a_response);
}
/**
 * Función que guarda la posición de los elementos de la documentación
 */
function save_doc_pos($id_ref,$a_pos){
	$position=0;
	foreach($a_pos as $id_tip){
		$data = array('__POSITION__'=>$position,'__ID_TIP__'=>$id_tip);
		$result=doQuery('cnm_cfg_tips_update_pos',$data);
		$position++;
	}
}
/**
 * Función para ejecutar lo que nos digan en todos los phps
 * $function = función a ejecutar
 * $mode = ajax|open
 */
function action($function,$mode='ajax'){
   showTime(session_id(),$mode);
	call_user_func($function);
}

/**
 * Función usada en la clase Tree (inc/class_tree.php) para saber si los elementos
 * del árbol deben aparecer o no. Sustituye a in_array porque ahora se manejan los 
 * hids.
 *
 * Ej: in_array_like('devices_1',array('devices','vistas'))
 * debe devolver true
 */
function in_array_like($referencia,$array){ 
	$s_array = print_r($array,true);
	CNMUtils::info_log(__FILE__, __LINE__, "IN_ARRAY_LIKE::REFERENCIA==$referencia||ARRAY==$s_array");
   foreach($array as $ref){ 
     if (strstr($referencia,$ref)) return true; 
   } 
   return false; 
}

function cid($hidx){
   // Es un CNM remoto
   if ('register' == $_SESSION['open_mode']) $cid = $_SESSION['HIDX']['cid'];
   // Hace de proxy en multi o es mono
   else $cid = $_SESSION['A_HIDX'][$hidx]['cid'];
	
	if($hidx=='')$cid='default';

	return $cid;
}
function descr($hidx){
   // Es un CNM remoto
   if ('register' == $_SESSION['open_mode']) $descr = $_SESSION['HIDX']['name'];
   // Hace de proxy en multi o es mono
   else $descr = $_SESSION['A_HIDX'][$hidx]['name'];
   return $descr;
}
function cid_ip($hidx){
   // Es un CNM remoto
   if ('register' == $_SESSION['open_mode']) $cid_ip = $_SESSION['HIDX']['ip'];
   // Hace de proxy en multi o es mono
   else $cid_ip = $_SESSION['A_HIDX'][$hidx]['ip'];
   return $cid_ip;
}
function _frec($input){
   $res = null;
   switch ($input){
      case 'U': $res = 'Unico';
                break;
      case 'D': $res = 'Diario';
                break;
      case 'S': $res = 'Semanal';
                break;
      case 'M': $res = 'Mensual';
                break;
      case 'A': $res = 'Anual';
                break;
      // default:  $res = 'Desconocido';
      default:  $res = '';
   }
   return $res;
}

function _itil_type($input){
   $res = null;
   switch($input){
      case 'oper':
      case '1':    $res = 'Operaci&oacute;n';
                   break;
      case 'cfg':
      case '2':    $res = 'Configuraci&oacute;n';
                   break;
      case 'cap':
      case '3':    $res = 'Capacidad';
                   break;
      case 'disp':
      case '4':    $res = 'Disponibilidad';
                   break;
      case 'sec':
      case '5':    $res = 'Seguridad';
                   break;
      default:     $res = '';
   }
   return $res;
}
function ObtenerNavegador($u_agent) { 
   if(preg_match('/MSIE/i',$u_agent) && !preg_match('/Opera/i',$u_agent)) $ub = "MSIE";
   elseif(preg_match('/Firefox/i',$u_agent))                              $ub = "Firefox";
   elseif(preg_match('/Chrome/i',$u_agent))                               $ub = "Chrome";
   elseif(preg_match('/Safari/i',$u_agent))                               $ub = "Safari";
   elseif(preg_match('/Opera/i',$u_agent))                                $ub = "Opera";
   elseif(preg_match('/Netscape/i',$u_agent))                             $ub = "Netscape"; 
	else                                                                   $ub = "Desconocido";
	return $ub;
}
function ObtenerNavegador2($user_agent) {  
//function ObtenerNavegador() {  
//	$user_agent = $_SERVER['HTTP_USER_AGENT'];
	$navegadores = array(  
		'Opera' => 'Opera',  
      'Mozilla Firefox'=> '(Firebird)|(Firefox)',  
      'Galeon' => 'Galeon',  
      'Mozilla'=>'Gecko',  
      'MyIE'=>'MyIE',  
      'Lynx' => 'Lynx',  
      'Netscape' => '(Mozilla/4\.75)|(Netscape6)|(Mozilla/4\.08)|(Mozilla/4\.5)|(Mozilla/4\.6)|(Mozilla/4\.79)',  
      'Konqueror'=>'Konqueror',  
		'Internet Explorer' => 'MSIE',
//      'Internet Explorer 7' => '(MSIE 7\.[0-9]+)',  
//      'Internet Explorer 6' => '(MSIE 6\.[0-9]+)',  
//      'Internet Explorer 5' => '(MSIE 5\.[0-9]+)',  
//      'Internet Explorer 4' => '(MSIE 4\.[0-9]+)',  
	);  
	foreach($navegadores as $navegador=>$pattern){  
		if (preg_match("/$pattern/i",$user_agent)) return $navegador;
      //if (eregi($pattern, $user_agent)) return $navegador;  
   }  
	return 'Desconocido';  
}  
// Funcion que modifica la url para que pueda ser descargada por los distintos navegadores
// Se usa en la parte de links de dispositivo
/*
 for safari: file:////hostname/foldername/file
 for ie: \\hostname\foldername\file
 for google chrome: file://hostname/foldername/file => Hay que instalar  el plugin LocalLinks
 for firefox: file://///hostname/foldername/file => Hay que instalar el plugin noscript y hacer en las opciones de noscript ("Advanced -> Trusted -> "Allow local links").
 for opera: file://hostname/foldername/file
*/
function URINavegator($uri,$nav){
   if(strpos($uri,'file:')===0){
      // Firefox
      // if($nav=='Mozilla Firefox') $uri=str_replace('file://','file://///',$uri);
      if($nav=='Firefox') $uri=str_replace('file://','file://///',$uri);
      // Safari - Chrome
      // elseif($nav=='Mozilla')     $uri=str_replace('file://','file:////',$uri);
      elseif($nav=='Chrome') $uri=str_replace('file://','file:////',$uri);
      // Opera
      // elseif($nav=='Opera')    $uri=str_replace('file://','file://',$uri);
   }elseif(strpos($uri,'\\\\')===0){
      // Firefox
      // if($nav=='Mozilla Firefox') $uri=str_replace('\\\\','file://///',$uri);
      if($nav=='Firefox') $uri=str_replace('\\\\','file://///',$uri);
      // Safari - Chrome
      // elseif($nav=='Mozilla')     $uri=str_replace('\\\\','file:////',$uri);
      elseif($nav=='Chrome')     $uri=str_replace('\\\\','file:////',$uri);
      // Opera
      elseif($nav=='Opera')       $uri=str_replace('\\\\','file://',$uri);
   }
	// if($nav!='Internet Explorer') $uri=str_replace('\\','/',$uri);
	if($nav!='MSIE') $uri=str_replace('\\','/',$uri);
	return $uri;
}
function cnm_test_sms($dest_msg,$dest_num){
   $a_cfg = array('NOTIF_SERIAL_PORT'=>'','NOTIF_PIN'=>'');
   read_cfg_file('/cfg/onm.conf',$a_cfg);

	$nofif_pin = ($a_cfg['NOTIF_PIN']!='')?"-p {$a_cfg['NOTIF_PIN']}":'';
	$notif_serial_port = ($a_cfg['NOTIF_SERIAL_PORT']!='')?"-s {$a_cfg['NOTIF_SERIAL_PORT']}":'-s /dev/ttyS0';

   $cmd="/usr/bin/sudo /opt/crawler/bin/libexec/chk_notif_sms $notif_serial_port $nofif_pin -t '$dest_num' -m '$dest_msg'";
	CNMUtils::info_log(__FILE__, __LINE__, "cnm_test_sms:: CMD=$cmd");
   $fp= popen("$cmd", "r");
   if (!$fp){
      $a_rc['rc'] = 1;
      $a_rc['msg'] = 'Error al abrir el fichero';
   }
   else{
      $rc=1;
      while (!feof($fp)){
         $buffer = fgets($fp, 1024); //OJO posible fuente de problemas
         // flush();
         if (strpos($buffer,"ENVIADO")!==false){
            // ENVIO CORRECTO
            $rc=0;
            break;
         }
      }
      pclose($fp);
      if ($rc==0){
         $a_rc['rc']  = 0;
         $a_rc['msg'] = 'Envio OK';
      }else{
         $a_rc['rc']  = 1;
         $a_rc['msg'] = 'Envio NOOK';
      }
   }
   return $a_rc;
}

function cnm_test_modem(){
   $a_rc = array('rc'=>'','msg'=>'','data'=>array());
   $a_cfg = array('NOTIF_SERIAL_PORT'=>'','NOTIF_PIN'=>'');
   read_cfg_file('/cfg/onm.conf',$a_cfg);

	$notif_serial_port = ($a_cfg['NOTIF_SERIAL_PORT']!='')?"-s {$a_cfg['NOTIF_SERIAL_PORT']}":'-s /dev/ttyS0';
   // $cmd = "/usr/bin/sudo /opt/crawler/bin/libexec/chk_notif_modem $notif_serial_port";
   $cmd = "/usr/bin/sudo /opt/crawler/bin/libexec/chk_notif_modem $notif_serial_port -p {$a_cfg['NOTIF_PIN']} 2>/dev/null";
	CNMUtils::info_log(__FILE__, __LINE__, "cnm_test_modem:: CMD=$cmd");

   $fp= popen("$cmd", "r");
   if (!$fp){
      $a_rc['rc'] = 1;
      $a_rc['msg'] = 'Error al abrir el fichero';
   }
   else{
      $a_rc['rc'] = 0;
      while (!feof($fp)) $a_rc['data'][]=fgets($fp, 1024);
      pclose($fp);
   }
   return $a_rc;
}

function cnm_test_mail($msg='',$dest=''){
   $a_rc = array('rc'=>'','data'=>array());

   $cmd = "/usr/bin/sudo /opt/crawler/bin/informer -i email -t $dest -m \"$msg\" -v 2>/dev/null";
   CNMUtils::info_log(__FILE__, __LINE__, "cnm_test_mail:: CMD=$cmd");

	$a_exec_output = array();
	$exec_rc = 0;
	exec($cmd,$a_exec_output,$exec_rc);
	if($exec_rc!=0){
      $a_rc['rc'] = 1;
	}
	$a_rc['data'] = $a_exec_output;
   return $a_rc;
}


function local_ip(){
	#$local_ip = chop(`/sbin/ifconfig eth0|grep 'inet addr'|cut -d ":" -f2|cut -d " " -f1`);
	$iface = local_iface();
	$local_ip = chop(`/sbin/ifconfig $iface|grep 'inet addr'|cut -d ":" -f2|cut -d " " -f1`);
	return $local_ip;
}

function local_iface(){
	$iface = 'eth0';
	$file = '/cfg/onm.if';
	if(file_exists($file) and false!=file_get_contents($file)){
		$iface = chop(file_get_contents($file));
	}
	return $iface;
}

function generateHash($plainText, $salt = null){
	$SALT_LENGTH=32;

   if ($salt === null) $salt = substr(md5(uniqid(rand(), true)), 0, $SALT_LENGTH);
   else $salt = substr($salt, 0, $SALT_LENGTH);
   return $salt . sha1($salt . $plainText);
}

// Función que devuelve los elementos que deben mostrarse en un grid con las búsquedas almacenadas
function search_store($scope,$id_user){
	$res = array();
	$cont = 0;
	$data = array('__SCOPE__'=>$scope, '__ID_USER__'=>$id_user);
	$result = doQuery('info_search_store',$data);
	foreach($result['obj'] as $r) $res[]=array('id'=>"search_store_{$r['id_search_store']}",'type'=>'button','text'=>$r['name']);		
	return $res;
}
// Función encargada de actualizar el campo nmetrics de cfg_view
function view_update_nmetrics($id_cfg_view,$cid){
   global $dbc;

   $cid_ip = local_ip();

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

function read_xml_file($file){
	$filename = "/var/www/html/onm/$file";
   $content  = '';
   if (file_exists($filename) && is_readable ($filename)){
		$content = file_get_contents($filename);
   	$a_ini = array('"',"\n");
	   $a_end = array('\"','');
   	$content = str_replace($a_ini,$a_end,$content);
	}
   return $content;
}

// Function: view_update_count()
// Desc: Actualiza los campos nmetrics,nremote,nsubviews de una vista
// a_rc=[rc,nmetrics,nremote,nsubviews] 
// rc:0=ok|1,2,3=error
function view_update_count($id_cfg_view,$cid,$cid_ip){
	$a_rc = array();
	$rc = 0;
	// nmetrics
	if ($rc==0){
		$data = array('__ID_CFG_VIEW__'=>$id_cfg_view,'__CID__'=>$cid,'__CID_IP__'=>$cid_ip);
		$result = doQuery('cnm_view_get_num_metrics',$data);
		$cuantos = $result['obj'][0]['cuantos'];
		$data['__NMETRICS__']=$cuantos;
		$a_rc['nmetrics']=$cuantos;
		$result = doQuery('cnm_view_update_nmetrics',$data);
		if ($result['rc']!=0){
			$rc = 1;
			$a_rc['rc'] = 1;
		}
	}
	// nremote
	if ($rc==0){
		$data = array('__ID_CFG_VIEW__'=>$id_cfg_view,'__CID__'=>$cid,'__CID_IP__'=>$cid_ip);
		$result = doQuery('cnm_view_get_num_remote',$data);
		$cuantos = $result['obj'][0]['cuantos'];
      $data['__NREMOTE__']=$cuantos;
		$a_rc['nremote']=$cuantos;
      $result = doQuery('cnm_view_update_nremote',$data);
		if ($result['rc']!=0){
			$rc = 2;
			$a_rc['rc'] = 2;
		}
	}
	// nsubviews
	if ($rc==0){
		$data = array('__ID_CFG_VIEW__'=>$id_cfg_view,'__CID__'=>$cid,'__CID_IP__'=>$cid_ip);
		$result = doQuery('cnm_view_get_num_subviews',$data);
		$cuantos = $result['obj'][0]['cuantos'];
      $data['__NSUBVIEWS__']=$cuantos;
		$a_rc['nsubviews']=$cuantos;
      $result = doQuery('cnm_view_update_nsubviews',$data);
		if ($result['rc']!=0){
			$rc = 3;
			$a_rc['rc'] = 3;
		}
	}
	return $a_rc;
}

function get_critic_image($critic){
	$return = $critic;
	if($critic==100)     $return = '<img src=images/mod_critic_very_high16x16.png>';
	elseif ($critic==75) $return = '<img src=images/mod_critic_high16x16.png>';
	elseif ($critic==50) $return = '<img src=images/mod_critic_med16x16.png>';
	elseif ($critic==25) $return = '<img src=images/mod_critic_low16x16.png>';
	return $return;
}

/*
*  Function: emulate_diff()
*  Input:    
*     $fichero => Fichero XML que contiene una tabla dhtmlx
*     $col     => Columna que queremos poner en formato diff
*  Output:   XML con el contenido de la tabla
*  Descr:    Función que manipula la columna $col del código XML que hay en el fichero $fichero de forma que quede con
*            colores en base a hacer el diff
*
*/
function emulate_diff($fichero,$col=1){
   $tabla = new Table();
   $tabla->no_limit_words();
   $tabla->set_width_mode('%');
   $a_vector = simplexml_load_file($fichero);

   $a_col_attachHeader = array();
   foreach ($a_vector->head as $head) {
      foreach($head->afterInit->call as $col_call){
         if('attachHeader'=="{$col_call['command']}"){
            $a_col_attachHeader=explode(',',"$col_call->param");
         }
      }
      $cont = 0;
      foreach($head->column as $col_name){
         $tabla->addCol(array('type'=>$col_name['type'],'width'=>$col_name['width'],'sort'=>$col_name['sort'],'align'=>$col_name['align']),$a_col_attachHeader[$cont],"$col_name");
         $cont++;
      }
   }

   foreach ($a_vector->row as $row) {
      $row_data = array();
		$cont = 1;
      foreach($row->cell as $cell){
         $aux_cell = "$cell";
			if($cont!=$col){
				$my_cell=$aux_cell;
			}else{
	         //$aux_cell=str_replace(' ', '&nbsp;',$aux_cell);
	         $aux_cell=str_replace('<','&lt;',$aux_cell);
	         $aux_cell=str_replace('>','&gt;',$aux_cell);
	         $a_line = explode("\n",$aux_cell);
	         //$a_line = explode(chr(10),$aux_cell);
	         $sep = '';
	         $my_cell = '';

	         foreach($a_line as $line){
	            if(strpos($line,'--- ')===false AND strpos($line,'-')===0){
	               $my_cell.=$sep.'<span style="color:red">'.$line.'</span>';
	            }
	            elseif(strpos($line,'+++ ')===false AND strpos($line,'+')===0){
	               $my_cell.=$sep.'<span style="color:green">'.$line.'</span>';
	            }
	            else{
	               $my_cell.=$sep.$line;
	            }
	            $sep='<br>';
	         }
			}
			$cont++;
         $row_data[]=$my_cell;
      }
      $row_meta = array('id'=>$row['id']);
      $row_user = array();
      $tabla->addRow($row_meta,$row_data,$row_user);
   }
   $tabla->beforeInit('enableMultiline','true');
   return $tabla->xml();
}
//------------------------------------------------------------------------------------
function get_db_credentials(){

   $FILE_CFG='/cfg/onm.conf';
   $fp = fopen ($FILE_CFG,"r");
   $pwd='';
   while (!feof($fp)) {
      $line = fgets($fp, 1024);
      if(strpos($line,'=')!==false){
         list($name,$value) = explode('=',$line);
         $name  = trim($name);
         $value = trim($value);
         if ($name=='DB_PWD') { $pwd=$value; break; }
      }
   }
   fclose($fp);
   return $pwd;
}

function ip_is_private($ip){
	$pri_addrs = array(
		'10.0.0.0|10.255.255.255',
		'172.16.0.0|172.31.255.255',
		'192.168.0.0|192.168.255.255',
		'169.254.0.0|169.254.255.255',
		'127.0.0.0|127.255.255.255'
	);

	$long_ip = ip2long($ip);
	if($long_ip != -1) {
		foreach($pri_addrs AS $pri_addr){
			list($start, $end) = explode('|', $pri_addr);

			// IF IS PRIVATE
			if($long_ip >= ip2long($start) && $long_ip <= ip2long($end)) return (TRUE);
		}
	}
	return (FALSE);
}
function time2dhms($n){
//1d=86400
//1h=3600
//1m=60
//1s=1
	$D=intval($n/86400);
	$resto=$n%86400;

   $H=intval($resto/3600);
   $resto=$resto%3600;

   $M=intval($resto/60);
   $S=$resto%60;

	$res = '';
	if($D>0) $res.="$D d ";
	if($H>0) $res.="$H h ";
	if($M>0) $res.="$M m ";
	if($S>0) $res.="$S s ";
   return $res;
}
/*
*	Function: cnm_version();
*	Input:
*	Output: array(
					rc    => 0(unk)|1(gpl)|2(pro)|3(NPL)
					rcstr => texto
*	Desc: Función que indica si la versión de cnm es gpl, pro o unk
*/
function cnm_version(){
	$filename = '/cfg/onm.version';
	// $mc = new MC_Base();

	$a_return = array(
		'rc'    => 0,
		'rcstr' => i18('_versiondesconocida'),
	);
	
	if(file_exists($filename)){	
		$version = strtoupper(rtrim(file_get_contents($filename)));
		if($version=='GPL'){
			$a_return = array(
				'rc'    => 1,
				'rcstr' => i18('_versiongpl'),
			);
		}
		elseif($version=='PRO'){
	      $a_return = array(
	         'rc'    => 2,
	         'rcstr' => i18('_versionpro'),
	      );
		}
		elseif($version=='NFR'){
         $a_return = array(
            'rc'    => 3,
            'rcstr' => i18('_versionnfr'),
         );
		}
	}

	return $a_return;
	/*
		$rc = 0;
	$gpl_dir  = '/var/www/html/onm/libs/dhtmlx_gpl';
	$pro_dir  = '/var/www/html/onm/libs/dhtmlx_pro';
	$lib_link = '/var/www/html/onm/libs/dhtmlx';
	$lib_file = '/var/www/html/onm/libs/dhtmlx/dhtmlx.js';
	if (is_dir($lib_link)){
		$lib_dir  = readlink($lib_link);
		
		if($lib_dir==$pro_dir AND is_file($lib_file))     $rc=2;
		elseif($lib_dir==$gpl_dir AND is_file($lib_file)) $rc=1;
	}
	return $rc;
*/
}

/*
*  Function: include_dir();
*  Input: 
*		$dir=> String|Ruta del directorio que contiene las librerías php
*	Output:
*	Desc: Función que carga las librerías de la ruta que se le indique en $dir
*/
function include_dir($dir){
	if(!is_dir($dir)){
		CNMUtils::error_log(__FILE__, __LINE__, "include_dir: error=$dir is not a dir");	
		return 1;
	}
 	$a_files = glob("$dir/*.php");
  	foreach ($a_files as $file){
		require_once($file);
	}
	return 0;
}
function isLocked($LOCK_FILE,$PID){
    # If lock file exists, check if stale.  If exists and is not stale, return TRUE
    # Else, create lock file and return FALSE.

    if( file_exists($LOCK_FILE) ){
        # check if it's stale
        $lockingPID = trim(file_get_contents($LOCK_FILE));

       # Get all active PIDs.
        $pids = explode( "\n", trim( `ps -e | awk '{print $1}'` ) );

        # If PID is still active, return true
        if( in_array( $lockingPID, $pids ) )  return true;

        # Lock-file is stale, so kill it.  Then move on to re-creating it.
        echo "Removing stale lock file.\n";
        unlink($LOCK_FILE );
    }
   
    file_put_contents($LOCK_FILE,$PID."\n" );
    return false;
}


function listdir_by_date($path){
    $dir = opendir($path);
    $list = array();
    while($file = readdir($dir)){
        if ($file != '.' and $file != '..'){
            // add the filename, to be sure not to
            // overwrite a array key
            $ctime = filectime($path . $file) . ',' . $file;
            $list[$ctime] = $file;
        }
    }
    closedir($dir);
    krsort($list);
    return $list;
}

/*
	Elimina los caracteres de control
	Fuente: http://stackoverflow.com/questions/1497885/remove-control-characters-from-php-string
*/
function clear_string($str_in){
	$str_out=preg_replace('/[\x00-\x1F\x7F]/', '', $str_in);
	return $str_out;
}

function get_cnm_role(){
	$file  = '/cfg/onm.role';
	$rcstr = '';

   $entrada=array('ROLE'=>'','ACTIVE_ADDRESS'=>'');
   read_cfg_file($file,$entrada);

	if(strtolower($entrada['ROLE']) == 'active')    $rcstr = '<font color="black">'.i18('_activo').'</font>';		
	elseif(strtolower($entrada['ROLE']) == 'passive') $rcstr = '<font color="red">'.i18('_pasivo').'</font>';		

	return $rcstr;
}


function displayArray($array) {
     $newline = "";
     foreach($array as $key => $value) {    //cycle through each item in the array as key => value pairs
         if (is_array($value) || is_object($value)) {        //if the VALUE is an array, then
            //call it out as such, surround with brackets, and recursively call displayTree.
             $value = "Array()" . $newline . "(". displayArray($value) . ")" . $newline;
         }
        //if value isn't an array, it must be a string. output its' key and value.
        $output .= "[$key] => " . $value . $newline;
     }
     return $output;
}

function combo_apptype($apptype){
	$flag = 0;
	$data = array();
	$result = doQuery('tech_group_list_all',$data);
	foreach($result['obj'] as $r){
		if($r['name']==$apptype) $flag = 1;
	}

   $array_option = array();
	if($flag==0){
		$cont = 0;
		foreach($result['obj'] as $r){
			// $array_option[]=($cont==0)?array(array('value'=>$r['name'],'selected'=>'true'),$r['name']):array(array('value'=>$r['name']),$r['name']);
			// $cont=1;
			$array_option[]=($r['name']=='USER')?array(array('value'=>$r['name'],'selected'=>'true'),$r['name']):array(array('value'=>$r['name']),$r['name']);
   	}
	}
	else{
		foreach($result['obj'] as $r){
         $array_option[]=($r['name']==$apptype)?array(array('value'=>$r['name'],'selected'=>'true'),$r['name']):array(array('value'=>$r['name']),$r['name']);
      }
	}
   $option = new Option($array_option);
	return $option;
}
function table_support_pack(){
   $tabla = new Table();

   $tabla->addCol(array('id'=>'checkbox','type'=>'ch','width'=>'25','sort'=>'int','align'=>'center'),'#master_checkbox','&nbsp;');
   $tabla->addCol(array('id'=>'name','type'=>'ro','width'=>'*','sort'=>'str','align'=>'left'),"#text_filter",'NOMBRE');

   $data = array();
   $result = doQuery('support_pack2tech_group_list_all_concat_name',$data);
   foreach($result['obj'] as $r){
      $row_meta=array('id'=>$r['id_support_pack']);
      $row_data=array(0,$r['name']);
      $row_user=array('apptype'=>$r['apptype_concat']);
      $tabla->addRow($row_meta,$row_data,$row_user);
   }
   return $tabla;
}
function combo_checkbox_apptype(){
   $a_option = array();
   $flag = 0;
   $result = doQuery('tech_group_list_all',$data);
   foreach ($result['obj'] as $r){
      if($flag==0){
         $a_option[]=array(array('value'=>$r['name'],'selected'=>'true'),$r['name']);
      }
      else{
         $a_option[]=array(array('value'=>$r['name']),$r['name']);
      }
      $flag=1;
   }
   $option = new Option($a_option);
	return $option;
}

/*
*	This is a function to sort an indexed 2D array by a specified sub array key, either ascending or descending.
*	It is usefull for sorting query results from a database by a particular field after the query has been returned
*	This function can be quite greedy. It recreates the array as a hash to use ksort() then back again
*	By default it will sort ascending but if you specify $reverse as true it will return the records sorted descending
*
*	src: http://www.php.net/manual/en/function.asort.php
*	use: 
*		$airports = array
*		(
*		    array( "code" => "LHR", "name" => "Heathrow" ),
*		    array( "code" => "LGW", "name" => "Gatwick" ),
*		);
*
*		printf("Before: <pre>%s</pre>", print_r($airports, true));
*
*		$airports = record_sort($airports, "name");
*
*		printf("After: <pre>%s</pre>", print_r($airports, true));
*
*	Example Outputs:
*		Before: Array
*		(
*		    [0] => Array ( [code] => LHR, [name] => Heathrow )
*		    [1] => Array ( [code] => LGW, [name] => Gatwick )
*		)
*
*		After: Array
*		(
*		    [0] => Array ( [code] => LGW, [name] => Gatwick )
*		    [1] => Array ( [code] => LHR, [name] => Heathrow )
*		)
*/
function record_sort($records, $field, $reverse=false){
/*
    $hash = array();
    foreach($records as $record) $hash[$record[$field]] = $record;
    ($reverse)? krsort($hash) : ksort($hash);
    $records = array();
    foreach($hash as $record) $records []= $record;
    return $records;
*/
    $hash = array();
    foreach($records as $record) $hash[$record[$field]][] = $record;
    ($reverse)? krsort($hash) : ksort($hash);
    $records = array();
    foreach($hash as $kk=>$a_records){
    	foreach($a_records as $record){
			$records []= $record;
		}
	}
    return $records;
}

/*
* Function: get_cnm_lang()
* Input: 
*       $mode = 0 : Read from file
*       $mode = 1 : Read from BBDD
*
* Output:
* Descr:
*/
function get_cnm_lang($mode=0){
	$lang = 'es_ES';
	// Mirar en /cfg/onm.lang
	if($mode==0){
		$file_path = '/cfg/onm.lang';
		if (file_exists($file_path)) {	
			$file_content = file_get_contents($file_path, FILE_USE_INCLUDE_PATH);
			if($file_content!==false){
				$lang = $file_content; 
			}
		}
	}
	// Mirar en BBDD
	else{
	   $data = array('__CNM_KEY__'=>'cnm_language');
	   $result = doQuery('get_cnm_config',$data);
		if($result['cont']>0 AND $result['obj'][0]['cnm_value']!=''){
			$lang = $result['obj'][0]['cnm_value'];
		}
	}
	return $lang;
}

/*
	Function: get_elements_search_store_view()
	Input:
		$input_id_cfg_view     => id_cfg_view de la vista
		$input_id_search_store => id_search_store de la búsqueda almacenada
   Casos:
      $input_id_cfg_view con valor y $input_id_search_store con valor => Devuelve los elementos de las vistas aplicandoles las busquedas
      $input_id_cfg_view con valor y $input_id_search_store sin valor => Devuelve los elementos de las vistas aplicandoles las busquedas asociadas
      $input_id_cfg_view sin valor y $input_id_search_store con valor => Devuelve las vistas aplicandoles las busquedas
*/
function get_elements_search_store_view($input_id_cfg_view,$input_id_search_store){
   $input_id_cfg_view     = preg_replace('/\s+/', '', $input_id_cfg_view);
   $input_id_search_store = preg_replace('/\s+/', '', $input_id_search_store);

   // Obtener las vistas de una búsqueda almacenada sobre todas las vistas
   if($input_id_cfg_view=='' AND $input_id_search_store!=''){
      $return = array('id_cfg_view'=>array());
   }
   // Elementos asociados a la vista que se pase como parámetro -i
   else{
      $return = array('metric'=>array(),'remote'=>array());

      // Obtenemos las búsquedas almacenadas que tiene asociadas la vista
      if($input_id_search_store==''){
         $data = array('__ID_CFG_VIEW__'=>$input_id_cfg_view);
         $result = doQuery('get_search_store_from_view_metric',$data);
         foreach($result['obj'] as $r) $a_id_search_store[] = $r['id_search_store'];
         $result = doQuery('get_search_store_from_view_remote',$data);
         foreach($result['obj'] as $r) $a_id_search_store[] = $r['id_search_store'];
      }
      // En caso de indicarnos las búsquedas almacenadas que se quieren aplicar a la vista no hay que calcularlas
      else{
         $a_id_search_store=array_unique(explode(',',$input_id_search_store));
      }

      ///////////////////////
      // PARTE DE MÉTRICAS //
      ///////////////////////
      $cond = '';
      $sep_params = '';
      $data = array('__SCOPE__'=>'view_metric','__ID_SEARCH_STORE__'=>implode(',',$a_id_search_store));
      $result = doQuery('info_search_store_by_id_search_scope',$data);
      foreach($result['obj'] as $r){
         $a_params = json_decode($r['value'],true);
         $cond.=$sep_params."( ''='' ";
         $sep_params = ' OR ';

         foreach($a_params as $k_cond => $foo){
            $v_cond = $foo['value'];
            if($k_cond=='status'){
               if($v_cond=='activ')      $cond.= " AND status=0 ";
               elseif($v_cond=='desact') $cond.= " AND status=1 ";
               elseif($v_cond=='mant')   $cond.= " AND status=2 ";
            }
            elseif($k_cond=='asoc'){
               if(strtolower($v_cond=='all')) continue;
               else $cond.= " AND asoc=$v_cond ";
            }
            elseif($k_cond=='mtype'){
               if(strtolower($v_cond=='all')) continue;
               else $cond.= " AND $k_cond='$v_cond' ";
            }
            elseif($k_cond=='network'){
               if(strtolower($v_cond=='all')) continue;
               else $cond.= " AND $k_cond='$v_cond' ";
            }
            elseif($k_cond=='type'){
               if($v_cond=='none')       $cond.= " AND (type='' OR isnull(type)) ";
               elseif(strtolower($v_cond!='all')){
                  $data2=array('__ID_HOST_TYPE__'=>$v_cond);
                  $result2=doQuery('device_types_by_id',$data2);
                  $cond.= " AND type='{$result2['obj'][0]['descr']}' ";
               }
            }
            elseif($k_cond=='critic'){
               if(strtolower($v_cond=='all'))         continue;
               elseif($v_cond=='high')    $cond.= " AND $k_cond IN (75,100) ";
               elseif($v_cond=='medhigh') $cond.= " AND $k_cond IN (50,75,100) ";
               else                       $cond.= " AND $k_cond=$v_cond";
            }
            elseif($k_cond=='system_red' or $k_cond=='system_orange' or $k_cond=='system_yellow' or $k_cond=='system_blue' or $k_cond=='system_cuantos'){
               $aux_cuantos = $v_cond;
               $a_simbol    = array('<','>','=','!');
               $aux_cuantos = str_replace($a_simbol,'',$aux_cuantos);
               if(!is_numeric($aux_cuantos)) continue;
               if ((strpos($v_cond,'=')===false) AND (strpos($v_cond,'>')===false) AND (strpos($v_cond,'<')===false) AND (strpos($v_cond,'!')===false)){
                  $v_cond="=$v_cond";
               }
               elseif(strpos($v_cond,'!')!==false){
                  $v_cond=str_replace('!','!=',$v_cond);
               }
               $cond.=" AND ".str_replace('system_','',$k_cond)." $v_cond";
            }
            elseif(strpos( $k_cond,'system_')!==false){
               /*
                * Tenemos en cuenta:
                * !   : NOT LIKE %%
                * =   : EQUAL
                * 
               */
               if(strpos($v_cond,'=')!==false){
                  $v_cond=str_replace('=','',$v_cond);
                  $cond.=" AND ".str_replace('system_','',$k_cond)." LIKE '$v_cond'";
               }
               elseif(strpos($v_cond,'!')!==false){
                  $v_cond=str_replace('!','',$v_cond);
                  $cond.=" AND ".str_replace('system_','',$k_cond)." NOT LIKE '%$v_cond%'";
               }
               else{
                  $cond.=" AND ".str_replace('system_','',$k_cond)." LIKE '%$v_cond%'";
               }
            }
            elseif(strpos( $k_cond,'custom_')!==false){
               $data2=array('__DESCR__'=>str_replace('custom_','',$k_cond));
               $result2=doQuery('get_devices_custom_type_by_descr',$data2);
               /*
                * Tenemos en cuenta:
                * !   : NOT LIKE %%
                * =   : EQUAL
                * 
                */
               if(strpos($v_cond,'=')!==false){
                  $v_cond=str_replace('=','',$v_cond);
                  $cond.=" AND columna".$result2['obj'][0]['id']." LIKE '$v_cond'";
               }
               elseif(strpos($v_cond,'!')!==false){
                  $v_cond=str_replace('!','',$v_cond);
                  $cond.=" AND columna".$result2['obj'][0]['id']." NOT LIKE '%$v_cond%'";
               }
               else{
                  $cond.=" AND columna".$result2['obj'][0]['id']." LIKE '%$v_cond%'";
               }
            }
         }
         $cond.=')';
      }
      $data  = array('__POSSTART__'=>0,'__COUNT__'=>1000000,'__CONDITION__'=>$cond,'__ORDERBY__'=>' name ASC ');

      // Se obtienen los campos de usuario que hay definidos en el sistema
      $result = doQuery('get_user_fields',$data);
      $user_fields = '';
      $array_user_fields = array();
      $a_user_fields_types = array();
      foreach ($result['obj'] as $r){
         $user_fields.=",c.columna{$r['id']}";
         $array_user_fields[]="columna{$r['id']}";
         $a_user_fields_types["columna{$r['id']}"]=$r['type'];
      }
      $data['__USER_FIELDS__']=$user_fields;

      $result = doQuery('cnm_get_view_metrics_delete_temp',$data);
      $result = doQuery('cnm_get_view_metrics_create_temp2',$data);
      $result = doQuery('cnm_get_view_metrics_create_temp3bis',$data);

      // Se obtienen las métricas
      $result = doQuery('cnm_get_view_metrics_lista',$data);
      foreach ($result['obj'] as $r) $return['metric'][]=(int)$r['id_metric'];
      $return['metric']=array_unique($return['metric']);


      //////////////////////////////
      // PARTE DE ALERTAS REMOTAS //
      //////////////////////////////
      $cond = '';
      $sep_params = '';
      $data = array('__SCOPE__'=>'view_remote','__ID_SEARCH_STORE__'=>implode(',',$a_id_search_store));
      $result = doQuery('info_search_store_by_id_search_scope',$data);
      foreach($result['obj'] as $r){
         $a_params = json_decode($r['value'],true);
         $cond.=$sep_params."( ''='' ";
         $sep_params = ' OR ';

         foreach($a_params as $k_cond => $foo){
            $v_cond = $foo['value'];
            if($k_cond=='status'){
               if($v_cond=='activ')      $cond.= " AND status=0 ";
               elseif($v_cond=='desact') $cond.= " AND status=1 ";
               elseif($v_cond=='mant')   $cond.= " AND status=2 ";
            }
            elseif($k_cond=='asoc'){
               if(strtolower($v_cond=='all')) continue;
               else $cond.= " AND asoc=$v_cond ";
            }
            elseif($k_cond=='rtype'){
               if(strtolower($v_cond)=='all') continue;
               else $cond.= " AND $k_cond='$v_cond' ";
            }
            elseif($k_cond=='network'){
               if(strtolower($v_cond=='all')) continue;
               else $cond.= " AND $k_cond='$v_cond' ";
            }
            elseif($k_cond=='type'){
               if($v_cond=='none')       $cond.= " AND (type='' OR isnull(type)) ";
               elseif(strtolower($v_cond)!='all'){
                  $data2=array('__ID_HOST_TYPE__'=>$v_cond);
                  $result2=doQuery('device_types_by_id',$data2);
                  $cond.= " AND type='{$result2['obj'][0]['descr']}' ";
               }
            }
            elseif($k_cond=='critic'){
               if(strtolower($v_cond)=='all')         continue;
               elseif($v_cond=='high')    $cond.= " AND $k_cond IN (75,100) ";
               elseif($v_cond=='medhigh') $cond.= " AND $k_cond IN (50,75,100) ";
               else                       $cond.= " AND $k_cond=$v_cond";
            }
            elseif($k_cond=='system_red' or $k_cond=='system_orange' or $k_cond=='system_yellow' or $k_cond=='system_blue' or $k_cond=='system_cuantos'){
               $aux_cuantos = $v_cond;
               $a_simbol    = array('<','>','=','!');
               $aux_cuantos = str_replace($a_simbol,'',$aux_cuantos);
               if(!is_numeric($aux_cuantos)) continue;
               if ((strpos($v_cond,'=')===false) AND (strpos($v_cond,'>')===false) AND (strpos($v_cond,'<')===false) AND (strpos($v_cond,'!')===false)){
                  $v_cond="=$v_cond";
               }
               elseif(strpos($v_cond,'!')!==false){
                  $v_cond=str_replace('!','!=',$v_cond);
               }
               $cond.=" AND ".str_replace('system_','',$k_cond)." $v_cond";
            }
            elseif(strpos( $k_cond,'system_')!==false){
               /*
                * Tenemos en cuenta:
                * !   : NOT LIKE %%
                * =   : EQUAL
                * 
               */
               if(strpos($v_cond,'=')!==false){
                  $v_cond=str_replace('=','',$v_cond);
                  $cond.=" AND ".str_replace('system_','',$k_cond)." LIKE '$v_cond'";
               }
               elseif(strpos($v_cond,'!')!==false){
                  $v_cond=str_replace('!','',$v_cond);
                  $cond.=" AND ".str_replace('system_','',$k_cond)." NOT LIKE '%$v_cond%'";
               }
               else{
                  $cond.=" AND ".str_replace('system_','',$k_cond)." LIKE '%$v_cond%'";
               }
            }
            elseif(strpos( $k_cond,'custom_')!==false){
               $data2=array('__DESCR__'=>str_replace('custom_','',$k_cond));
               $result2=doQuery('get_devices_custom_type_by_descr',$data2);
               /*
                * Tenemos en cuenta:
                * !   : NOT LIKE %%
                * =   : EQUAL
                * 
                */
               if(strpos($v_cond,'=')!==false){
                  $v_cond=str_replace('=','',$v_cond);
                  $cond.=" AND columna".$result2['obj'][0]['id']." LIKE '$v_cond'";
               }
               elseif(strpos($v_cond,'!')!==false){
                  $v_cond=str_replace('!','',$v_cond);
                  $cond.=" AND columna".$result2['obj'][0]['id']." NOT LIKE '%$v_cond%'";
               }
               else{
                  $cond.=" AND columna".$result2['obj'][0]['id']." LIKE '%$v_cond%'";
               }
            }
         }
         $cond.=')';
      }
      $data  = array('__POSSTART__'=>0,'__COUNT__'=>1000000,'__CONDITION__'=>$cond,'__ORDERBY__'=>' name ASC ');

      // Se obtienen los campos de usuario que hay definidos en el sistema
      $result = doQuery('get_user_fields',$data);
      $user_fields = '';
      $array_user_fields = array();
      $a_user_fields_types = array();
      foreach ($result['obj'] as $r){
         $user_fields.=",c.columna{$r['id']}";
         $array_user_fields[]="columna{$r['id']}";
         $a_user_fields_types["columna{$r['id']}"]=$r['type'];
      }
      $data['__USER_FIELDS__']=$user_fields;

      // Se borra la tabla temporal t1,t2,t3 y t4
      $result = doQuery('cnm_get_view_remote_delete_temp',$data);
      $result = doQuery('cnm_get_view_remote_create_temp2',$data);
      $result = doQuery('cnm_get_view_remote_create_temp3bis',$data);

      // Se obtienen las alertas remotas
      $result = doQuery('cnm_get_view_remote_lista',$data);
      foreach ($result['obj'] as $r) $return['remote'][]=(int)$r['id_remote_alert'];
      $return['remote']=array_unique($return['remote']);
   }
	return $return;
}
/*
* Function: get_cmd_proxy()
* Input:
* Output:
* Descr: Función que devuelve la cadena que debe añadirse al ejecutar un exec en caso de haberse definido un proxy HTTP
*
*/
function get_cmd_proxy(){
	$return = '';
   $entrada=array('http_proxy'=>'', 'https_proxy'=>'', 'proxy_enable'=>'');
   $mensaje=read_cfg_file('/cfg/onm.proxy',$entrada);
	if($mensaje['proxy_enable'] == 1){
		if($entrada['http_proxy']!='')  $return.=$entrada['http_proxy'].';';
		if($entrada['https_proxy']!='') $return.=$entrada['https_proxy'].';';
	}
	return $return;
}

/*
* Function: getXMLfromURL()
* Input: $url
* Output: Objeto XML
* Descr: Función que lee el contenido de una URL en formato XML teniendo en cuenta si el sistema CNM utiliza o no proxy HTTP
*/
function getXMLfromURL($url) {
	$entrada=array('proxy_host'=>'','proxy_port'=>'','proxy_user'=>'','proxy_passwd'=>'','proxy_enable'=>'');
	$mensaje=read_cfg_file('/cfg/onm.proxy',$entrada);
   if($entrada['proxy_enable'] == 1){
      $auth = base64_encode("{$entrada['proxy_user']}:{$entrada['proxy_passwd']}");
      $r_default_context = stream_context_get_default ( array
                 ('http' => array(
                     'proxy' => "tcp://{$entrada['proxy_host']}:{$entrada['proxy_port']}",
                     'request_fulluri' => True,
                     'header' => "Proxy-Authorization: Basic $auth",
                 ),
             )
       );
       libxml_set_streams_context($r_default_context);
   }
	$daten = simplexml_load_file($url);
	return $daten;
} 

/*
 * Function: cond2query()
 * Input:
 *    $k_cond => nombre del campo (ej: counter)
 *    $v_cond => valor del campo  (ej: >50)
 *    $a_table_descr => array( campo1=>tipo_campo1, campo2=>tipo_campo2, ...) Define el tipo de los campos de la BBDD de la tabla utilizada
 *
 * Output:
 *    $cond  => Cadena SQL que corresponde a la busqueda del campo indicado
 * Descr: Función que compone la condicion en formato SQL que debe utilizarse al realizar una busqueda en un grid
*/
function cond2query($k_cond,$v_cond,$a_table_descr=array()){
   $aux_cuantos = $v_cond;
   $a_simbol    = array('<','>','=','!');
   $aux_cuantos = str_replace($a_simbol,'',$aux_cuantos);


   // El campo existe en $a_table_descr
   if(array_key_exists($k_cond,$a_table_descr)){
      // El campo está definido como un entero
      if($a_table_descr[$k_cond]=='int'){
         if ((strpos($v_cond,'=')===false) AND (strpos($v_cond,'>')===false) AND (strpos($v_cond,'<')===false) AND (strpos($v_cond,'!')===false)){
            $v_cond="=$v_cond";
         }
         elseif(strpos($v_cond,'!')!==false){
            $v_cond=str_replace('!','!=',$v_cond);
         }
         $cond = " AND $k_cond $v_cond ";
      }
      // El campo esta definido como una cadena
      else{

         // El campo es un array de strings
         if(is_array($v_cond)) {
            $v_cond_quoted=Array();
            foreach ($v_cond as $v) { array_push($v_cond_quoted,"'$v'"); }
            $cond = " AND $k_cond IN (".implode(',',$v_cond_quoted). ") ";
         }
         else {
	         /*
   	       * Tenemos en cuenta:
      	    * !   : NOT LIKE %%
         	 * =   : EQUAL
	          * 
   	      */
      	   if(strpos($v_cond,'=')!==false)     $cond = " AND $k_cond LIKE '".str_replace('=','',$v_cond)."' ";
         	elseif(strpos($v_cond,'!')!==false) $cond = " AND $k_cond NOT LIKE '%".str_replace('!','',$v_cond)."%' ";
         	else                                $cond = " AND $k_cond LIKE '%$v_cond%' ";
      	}
		}
   }
   // En caso de no estar ese campo en $a_table_descr
   else{
      // En caso de ser un campo numérico 
      if(is_numeric($aux_cuantos)){
         if ((strpos($v_cond,'=')===false) AND (strpos($v_cond,'>')===false) AND (strpos($v_cond,'<')===false) AND (strpos($v_cond,'!')===false)){
            $v_cond="=$v_cond";
         }
         elseif(strpos($v_cond,'!')!==false){
            $v_cond=str_replace('!','!=',$v_cond);
         }
         $cond = " AND $k_cond $v_cond ";
      }
      // En caso de ser un campo de texto
      else{
         /*
          * Tenemos en cuenta:
          * !   : NOT LIKE %%
          * =   : EQUAL
          * 
         */
         if(strpos($v_cond,'=')!==false)     $cond = " AND $k_cond LIKE '".str_replace('=','',$v_cond)."' ";
         elseif(strpos($v_cond,'!')!==false) $cond = " AND $k_cond NOT LIKE '%".str_replace('!','',$v_cond)."%' ";
         else                                $cond = " AND $k_cond LIKE '%$v_cond%' ";
      }
   }
	return $cond;

/*
	$cond = ' AND (';

	// En caso de ser un campo de texto
   // * Tenemos en cuenta:
   // * !   : NOT LIKE %%
   // * =   : EQUAL
   // * 
   if(strpos($v_cond,'=')!==false)     $cond.= "$k_cond LIKE '".str_replace('=','',$v_cond)."'";
   elseif(strpos($v_cond,'!')!==false) $cond.= "$k_cond NOT LIKE '%".str_replace('!','',$v_cond)."%'";
   else                                $cond.= "$k_cond LIKE '%$v_cond%'";


   // En caso de ser un campo numérico 
   if(is_numeric($aux_cuantos)){
      if ((strpos($v_cond,'=')===false) AND (strpos($v_cond,'>')===false) AND (strpos($v_cond,'<')===false) AND (strpos($v_cond,'!')===false)){
         $v_cond="=$v_cond";
      }
      elseif(strpos($v_cond,'!')!==false){
         $v_cond=str_replace('!','!=',$v_cond);
      }
      $cond.=" OR $k_cond $v_cond";
   }

	$cond.=") ";
	return $cond;
*/
}

/*
 * Function: metric_error()
 * Input: 
 *    $id_metric
 * Output:
 * Descr: Escribe en /var/log/apache2/cnm_log/metric_error-[$ip_source]-[$id_metric] el número de veces que la métrica ha fallado
*/
function metric_error($id_metric){
	$dir = '/var/log/apache2/cnm_log/';	
	$ip_source = $_SESSION['REMOTE_ADDR'];
	$file = $dir.'metric_error-'.$ip_source.'-'.$id_metric;
	$cont = 0;

	if(!is_dir($dir))	mkdir($dir);

	if(file_exists($file)) 	$cont = (is_numeric(file_get_contents($file)))?file_get_contents($file):0;

	$cont++;
	file_put_contents($file,$cont);
}


/*
 * Function: isJson()
 * Input:
 *        $string: Cadena de texto
 * Output: true | false
 * Descr: indica si $string es json o no
 */ 
function isJson($string) {
	json_decode($string);
	return (json_last_error() == JSON_ERROR_NONE);
}

// Función que obtiene la descripción de los campos de una tabla
function DDBB_Table_Info($id_table){
   global $dbc;
   $return=array();
   $result = $dbc->query("SHOW FIELDS FROM $id_table");
   if (!@PEAR::isError($result)){
      if(is_object($result)){
         while ($result->fetchInto($r)){
				$type = 'int';
				if(strpos($r['Type'],'char')!==false)     $type = 'string';
				elseif(strpos($r['Type'],'text')!==false) $type = 'string';
				elseif(strpos($r['Type'],'blob')!==false) $type = 'string';

				$return[$r['Field']] = $type;
			}
         $result->free();
      }
   }
   return $return;
}

/*
*  Function: paramIsCNMVariable()
*  Input: 
*         $input => Nombre del campo a comprobar
*  Output:
*         (bool) True en caso de ser una variable de CNM | False en caso de no serlo
*  Descr: Función que comprueba si el campo que recibe como parámetro es una variable de CNM en la parte de scripts, aplicaciones y métricas proxy.
*/
function paramIsCNMVariable($input){
	$return = false;
	
/*
	// Obtener todos los tipos de credenciales en CNM
	$data = array();
	$result = doQuery('all_credentials',$data);
	foreach($result['obj'] as $r){
		if($input=='$sec.'.$r['type'].'.user' OR $input=='$sec.'.$r['type'].'.pwd'){
			$return = true;
			break;
		}
	}
*/
   if(preg_match('/\$sec\.\w*\.(user|pwd)/',$input)){
		$return = true;
   }

	return $return;
}







/*
 * Function: dispositivo_modificar_campos_personalizados()
 * Input: 
 *    $id_dev   => Id del dispositivo al que le queremos modificar los campos de usuario
 *    $a_campos => array con N entradas descr => Valor (array('Proveedor' => 'OKI', 'Precio' => 1000))
 * Output: 
 *    rc    => 0:OK | 1: Error no fatal | 2: Error fatal
 *    rcstr => Descripción del error en caso de existir
 *    data  => array con la descripción de la actualización cada campo
 *
*/
function dispositivo_modificar_campos_personalizados($id_dev,$a_campos){
global $dbc;

   $a_return = array('rc'=>0,'rcstr'=>'','data'=>array());



   $sql_insertar="INSERT INTO devices_custom_data (id_dev) VALUES ($id_dev)";
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
   $a_asoc = array();
   $sql2="SELECT id,descr FROM devices_custom_types";
   $result2 = $dbc->query($sql2);
   while ($result2->fetchInto($r2)) $a_asoc[$r2['descr']] = $r2['id'];

   foreach($a_campos as $key=>$value){
      // El campo de usuario que ha metido el usuario no existe en la BBDD
      if(!array_key_exists($key,$a_asoc)){
         $a_return['rc'] = 1;
         $a_return['data'][]=array('key'=>$key,'descr'=>'The field doesnt exist in the CNM database');
         continue;
      }
      $dato=mysql_real_escape_string($value);
      // SSV: PROXY INVERSO
      $dato=str_replace('[proxy]', '____PROXY____[proxy]', $dato);

      $sql4="UPDATE devices_custom_data SET columna{$a_asoc[$key]}='$dato' WHERE id_dev=$id_dev";
      $result4 = $dbc->query($sql4);

      /////////////////////////////////////////////////////////////////
      // MYSQL NO ADMITE PONER DEFAULT VALUE EN CAMPOS TEXT          //
      // SOLUCION: ACTUALIZAMOS A - LAS COLUMNAS QUE NO TENGAN DATOS //
      /////////////////////////////////////////////////////////////////
      $sql5="UPDATE devices_custom_data SET columna{$a_asoc[$key]} ='-' WHERE columna{$a_asoc[$key]} ='' or columna{$a_asoc[$key]} IS NULL";
      $result5 = $dbc->query($sql5);
   }
   return $a_return;
}

/*
 * Function: dispositivo_asociar_perfiles()
 * Input: 
 *    $id_dev     => Id del dispositivo al que le queremos modificar los campos de usuario
 *    $a_profiles => array con los perfiles a los que queremos asociar el dispositivo => array('Global','Coca cola','Pepsico')
 * Output: 
 *    rc    => 0:OK | 1: Error no fatal | 2: Error fatal
 *    rcstr => Descripción del error en caso de existir
 *    data  => array con 
 *
*/
function dispositivo_asociar_perfiles($id_dev,$a_profiles,$cid='default'){
global $dbc;

   $a_profiles = array_unique($a_profiles); // Eliminamos perfiles duplicados
   $a_profiles = array_filter($a_profiles); // Eliminamos perfiles vacios

   $a_return = array('rc'=>0,'rcstr'=>'','data'=>array());



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
         $sql3 = "INSERT IGNORE INTO cfg_devices2organizational_profile (id_dev,id_cfg_op,cid) VALUES ($id_dev,$id_cfg_op,'$cid')";
      }
      // Se borra
      else{
         $sql3 = "DELETE FROM cfg_devices2organizational_profile WHERE id_dev=$id_dev AND id_cfg_op=$id_cfg_op AND cid='$cid'";
      }
      $result3 = $dbc->query($sql3);
   }
   foreach($a_profiles as $profile){
      // El campo de usuario que ha metido el usuario no existe en la BBDD
      if(!array_key_exists($profile,$a_asoc)){
         $a_return['rc'] = 1;
         $a_return['data'][]=array('profile'=>$field,'descr'=>'The profile doesnt exist in the CNM database');
         continue;
      }
   }
   return $a_return;

}

?>
