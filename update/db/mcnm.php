#!/usr/bin/php -q
<?php
require_once('/usr/share/pear/DB.php');
require_once('/update/db/DB-Scheme-Lib.php');

// Funciones adicionales
$in         = fopen("php://stdin","r");
$err        = fopen("php://stderr","w");
$dbc        = null;
$a_cnm      = array('hidx'=>'','ip'=>'','name'=>'','descr'=>'');
$a_domain   = array('id_domain'=>'','name'=>'');
$a_asoc     = array('name_domain'=>'','ip_cnm'=>'');

$show = 'menu';
//Procesado infinito loops
while (1) {
	if($show=='menu')               menu();
	elseif($show=='menu_asoc')      menu();
	elseif($show=='menu_deasoc')    menu();
	elseif($show=='cnm')            cnm();
	elseif($show=='cnm_add')        cnm();
	elseif($show=='cnm_edit')       cnm();
   elseif($show=='cnm_delete')     cnm();
   elseif($show=='domain')         domain();
   elseif($show=='domain_add')     domain();
   elseif($show=='domain_delete')  domain();
   elseif($show=='domain_change')  domain();
}

//------------------------------------------------------------------------------------
function menu(){
	global $show,$in,$err,$dbc,$a_asoc;

   cls();
   text_color('red');
   echo "Administración de Multi-CNM (menú principal)\n";
   text_color('normal');
/*
   echo "c) CNMs\n";
   echo "d) Dominios\n";
   echo "a) Asociar CNM a dominio\n";
   echo "u) Desasociar CNM de dominio\n";
   echo "q) Salir Programa\n\n";
*/

	echo "c) CNMs | d) Dominios | a) Asociar CNM a dominio | u) Desasociar CNM de dominio \nr) Recargar datos | q) Salir\n";



   if ($show=='menu_asoc'){
      echo "Rellene los campos o una opción:\n";
      echo "CNM IP : {$a_asoc['ip_cnm']}\n";
      echo "NAME DOMAIN : {$a_asoc['name_domain']}\n";
      if($a_asoc['name_domain']!='') echo "Está seguro de los datos?(y/n)\n\n";
   }
   elseif ($show=='menu_deasoc'){
      echo "Rellene los campos o una opción:\n";
      echo "CNM IP : {$a_asoc['ip_cnm']}\n";
      echo "NAME DOMAIN : {$a_asoc['name_domain']}\n";
      if($a_asoc['name_domain']!='') echo "Está seguro de los datos?(y/n)\n\n";
   }else{
   	echo "Escoja una opción:\n\n";
	}




   echo"                       DOMINIOS<------->CNMs\n";
   echo"------------------------------------------------------------------------\n";
   echo"CNM IP                         DOMAIN NAME\n";
   echo"------------------------------------------------------------------------\n";
   _DB();
   $query  = "SELECT b.host_ip,c.name from cfg_cnms2domains a, cfg_cnms b, cfg_domains c WHERE a.hidx=b.hidx AND a.id_domain=c.id_domain";
   $result = $dbc->query($query);
   while ($result->fetchInto($r)) printf("%-30s %s\n",$r['host_ip'],$r['name']);


   echo"\n                        CNMS\n";
   echo"-----------------------------------------------------------------\n";
   echo"IP                             DESCR\n";
   echo"-----------------------------------------------------------------\n";
   _DB();
   $query  = "SELECT * FROM cfg_cnms";
   $result = $dbc->query($query);
   while ($result->fetchInto($r)) printf("%-30s %s\n",$r['host_ip'],$r['descr']);


   echo"\n        DOMINIOS\n";
   echo"-----------------------\n";
   echo"NAME  \n";
   echo"-----------------------\n";
   _DB();
   $query  = "SELECT * FROM cfg_domains";
   $result = $dbc->query($query);
   while ($result->fetchInto($r)) printf("%s\n",$r['name']);


   if ($show=='menu_asoc'){
      if($a_asoc['ip_cnm']=='')           pos_cursor(10,5);
      elseif($a_asoc['name_domain']=='')  pos_cursor(15,6);
      else                                pos_cursor(31,7);
   }
   elseif($show=='menu_deasoc'){
      if($a_asoc['ip_cnm']=='')           pos_cursor(10,5);
      elseif($a_asoc['name_domain']=='')  pos_cursor(15,6);
      else                                pos_cursor(31,7);
   }
   else{
      pos_cursor(19,4);
   }


   // Eliminar blancos de la entrada
   $input=trim(fgets($in,255));

	if($input=='q'){
		quit();
	}
	elseif($input=='r'){
		$a_asoc = array('name_domain'=>'','ip_cnm'=>'');
		$show='menu';
	}
	elseif($input=='c'){
		$show='cnm';
	}
	elseif($input=='d'){
		$show='domain';
	}
	elseif($input=='a'){
		$a_asoc = array('name_domain'=>'','ip_cnm'=>'');
		$show='menu_asoc';
	}
	elseif($show=='menu_asoc'){
      if(!$a_asoc['ip_cnm'])           $a_asoc['ip_cnm'] = $input;
      elseif(!$a_asoc['name_domain'])  $a_asoc['name_domain'] = $input;
      elseif($input=='n'){
			$a_asoc = array('name_domain'=>'','ip_cnm'=>'');
         $show='menu';
      }
      elseif($input=='y'){
         asoc_CNM_DOMAIN($a_asoc);
			$a_asoc = array('name_domain'=>'','ip_cnm'=>'');
         $show='menu';
      }
   }
	elseif($input=='u'){
		$a_asoc = array('name_domain'=>'','ip_cnm'=>'');
		$show='menu_deasoc';
	}
   elseif($show=='menu_deasoc'){
      if(!$a_asoc['ip_cnm'])           $a_asoc['ip_cnm'] = $input;
      elseif(!$a_asoc['name_domain'])  $a_asoc['name_domain'] = $input;
      elseif($input=='n'){
         $a_asoc = array('name_domain'=>'','ip_cnm'=>'');
         $show='menu';
      }
      elseif($input=='y'){
         deasoc_CNM_DOMAIN($a_asoc);
         $a_asoc = array('name_domain'=>'','ip_cnm'=>'');
         $show='menu';
      }
   }
	else{
		echo chr(7); // beep en caso de entrada incorrecta
	}
}
//------------------------------------------------------------------------------------
function domain(){
   global $show,$in,$err,$dbc,$a_domain;

   cls();
   text_color('red');
   echo "Administración de Multi-CNM (Listado de dominios)\n";
   text_color('normal');
/*
   echo "r) Recargar listado de dominios\n";
   echo "b) Eliminar dominio\n";
   echo "a) Añadir dominio\n";
   echo "c) Cambiar nombre al dominio\n";
   echo "m) Menú principal\n";
   echo "q) Salir Programa\n\n";
*/

	echo "r) Recargar listado de dominios | b) Eliminar dominio | a) Añadir dominio \nc) Cambiar nombre al dominio | m) Menú principal | q) Salir\n";
	
   if ($show=='domain_delete'){
      echo "Rellene los campos o una opción:\n";
      echo "DOMAIN ID : {$a_domain['id_domain']}\n";
      if($a_domain['id_domain']!='') echo "Está seguro de los datos?(y/n)\n\n";
   }
   elseif($show=='domain_add'){
      echo "Rellene los campos o una opción:\n";
      echo "Nombre del dominio : {$a_domain['name']}\n";
      if($a_domain['name']!='') echo "Está seguro de los datos?(y/n)\n\n";
   }
	elseif($show=='domain_change'){
      echo "Rellene los campos o una opción:\n";
      echo "DOMAIN ID: {$a_domain['id_domain']}\n";
      echo "Nuevo nombre del dominio: {$a_domain['name']}\n";
      if($a_domain['name']!='') echo "Está seguro de los datos?(y/n)\n\n";
   }
   else{
     echo "Escoja una opción:\n\n";
   }

   echo"\n                        DOMINIOS\n";
   echo"------------------------------------------------\n";
   echo"DOMAIN ID   NOMBRE  \n";
   echo"------------------------------------------------\n";
   _DB();
   $query  = "SELECT * FROM cfg_domains";
   $result = $dbc->query($query);
   while ($result->fetchInto($r)) printf("%-11s %s\n",$r['id_domain'],$r['name']);

   if ($show=='domain_delete'){
      if($a_domain['id_domain']=='')  pos_cursor(13,5);
      else                            pos_cursor(31,6);
   }
   elseif($show=='domain_add'){
      if($a_domain['name']=='')       pos_cursor(22,5);
      else                            pos_cursor(31,6);
   }
   elseif($show=='domain_change'){
      if($a_domain['id_domain']=='')  pos_cursor(12,5);
      elseif($a_domain['name']=='')   pos_cursor(27,6);
      else                            pos_cursor(31,7);
   }
	else{
      pos_cursor(19,4);
   }

   // Eliminar blancos e entrada
   $input=trim(fgets($in,255));

   if ($input=='r'){
      $a_domain = array('name'=>'','id_domain'=>'');
      $show='domain';
   }elseif($input=='m'){
      $a_domain = array('name'=>'','id_domain'=>'');
      $show='menu';
   }elseif($input=='b'){
      $a_cnm = array('name'=>'','id_domain'=>'');
      $show='domain_delete';
   }elseif($input=='q'){
      cls();
      exit(0);
   }elseif($show=='domain_delete'){
      if(!$a_domain['id_domain']) $a_domain['id_domain']    = $input;
      elseif($input=='n'){
         $a_domain = array('name'=>'','id_domain'=>'');
         $show='domain';
      }
      elseif($input=='y'){
         delete_DOMAIN($a_domain);
         $a_domain = array('name'=>'','id_domain'=>'');
         $show='domain';
      }
   }elseif($input=='a'){
      $a_domain = array('name'=>'','id_domain'=>'-');
      $show='domain_add';
   }elseif($show=='domain_add'){
      if(!$a_domain['name'])  $a_domain['name'] = $input;
      elseif($input=='n'){
         $a_domain = array('name'=>'','id_domain'=>'');
         $show='domain';
      }
      elseif($input=='y'){
         add_DOMAIN($a_domain);
         $a_domain = array('name'=>'','id_domain'=>'');
         $show='domain';
      }
   }elseif($input=='c'){
      $a_domain = array('name'=>'','id_domain'=>'');
      $show='domain_change';
   }elseif($show=='domain_change'){
      if(!$a_domain['id_domain'])  $a_domain['id_domain'] = $input;
      elseif(!$a_domain['name'])   $a_domain['name']      = $input;
      elseif($input=='n'){
         $a_domain = array('name'=>'','id_domain'=>'');
         $show='domain';
      }
      elseif($input=='y'){
         add_DOMAIN($a_domain);
         $a_domain = array('name'=>'','id_domain'=>'');
         $show='domain';
      }
   }else{
      // beep en caso de entrada incorrecta
      echo chr(7);
   }
}
//------------------------------------------------------------------------------------
function cnm(){
   global $show,$in,$err,$dbc,$a_cnm;

   cls();
   text_color('red');
   echo "Administración de Multi-CNM (Listado de CNMs)\n";
   text_color('normal');
/*
   echo "r) Recargar listado de CNMs\n";
	echo "b) Eliminar CNM\n";
   echo "a) Añadir CNM\n";
   echo "e) Editar CNM\n";
   echo "m) Menú principal\n";
   echo "q) Salir Programa\n\n";
*/
   echo "r) Recargar listado de CNMs | b) Eliminar CNM | a) Añadir CNM \ne) Editar CNM | m) Menú principal | q) Salir\n";

	if ($show=='cnm_delete'){
		echo "Rellene los campos o una opción:\n";
		echo "CNM ID : {$a_cnm['hidx']}\n";
		if($a_cnm['hidx']!='') echo "Está seguro de los datos?(y/n)\n\n";	
   }
	elseif($show=='cnm_add'){
		echo "Rellene los campos o una opción:\n";
		echo "IP : {$a_cnm['ip']}\n";
		echo "DESCRIPCIÓN : {$a_cnm['descr']}\n";
		if($a_cnm['descr']!='') echo "Está seguro de los datos?(y/n)\n\n";
	}
   elseif($show=='cnm_edit'){
      echo "Rellene los campos o una opción:\n";
      echo "CNM ID a modificar: {$a_cnm['hidx']}\n";
      echo "IP : {$a_cnm['ip']}\n";
      echo "DESCRIPCIÓN : {$a_cnm['descr']}\n";
      if($a_cnm['descr']!='') echo "Está seguro de los datos?(y/n)\n\n";
   }
	else{
	  echo "Escoja una opción:\n\n";
	}

	echo"\nCNM ID   IP                             DESCR\n";
	echo"----------------------------------------------------------------\n";
	_DB();
   $query  = "SELECT * FROM cfg_cnms";
   $result = $dbc->query($query);
   while ($result->fetchInto($r)) printf("%-8s %-30s %s\n",$r['hidx'],$r['host_ip'],$r['descr']);

   if ($show=='cnm_delete'){
      if($a_cnm['hidx']=='') pos_cursor(10,5);
      else                   pos_cursor(31,6);
	}
	elseif($show=='cnm_add'){
		if($a_cnm['ip']=='')        pos_cursor(6,5);
		elseif($a_cnm['descr']=='') pos_cursor(15,6);
		else                        pos_cursor(31,7);
	}
   elseif($show=='cnm_edit'){
      if($a_cnm['hidx']=='')      pos_cursor(21,5);
      elseif($a_cnm['ip']=='')    pos_cursor(6,6);
      elseif($a_cnm['descr']=='') pos_cursor(15,7);
      else                        pos_cursor(31,8);
	}else{
	   pos_cursor(19,4);
	}

   // Eliminar blancos e entrada
   $input=trim(fgets($in,255));

	if ($input=='r'){
      $a_cnm = array('ip'=>'','cid'=>'','descr'=>'','hidx'=>'');
      $show='cnm';
	}elseif($input=='m'){
      $a_cnm = array('ip'=>'','cid'=>'','descr'=>'','hidx'=>'');
      $show='menu';
   }elseif($input=='b'){
      $a_cnm = array('ip'=>'','cid'=>'','descr'=>'','hidx'=>'');
      $show='cnm_delete';
	}elseif($input=='q'){
      cls();
      exit(0);
	}elseif($show=='cnm_delete'){
      if(!$a_cnm['hidx']) $a_cnm['hidx']   = $input;
      elseif($input=='n'){
         $a_cnm = array('ip'=>'','cid'=>'','descr'=>'','hidx'=>'');
         $show='cnm';
      }
      elseif($input=='y'){
         delete_CNM($a_cnm);
         $a_cnm = array('ip'=>'','cid'=>'','descr'=>'','hidx'=>'');
         $show='cnm';
      }
	}elseif($input=='a'){
      $a_cnm = array('ip'=>'','cid'=>'','descr'=>'','hidx'=>'-');
      $show='cnm_add';
	}elseif($show=='cnm_add'){
      if(!$a_cnm['ip'])          $a_cnm['ip']          = $input;
      elseif(!$a_cnm['descr'])       $a_cnm['descr']       = $input;
		elseif($input=='n'){
			$a_cnm = array('ip'=>'','cid'=>'','descr'=>'','hidx'=>'');
	      $show='cnm';
		}
		elseif($input=='y'){
			add_CNM($a_cnm);	
			$a_cnm = array('ip'=>'','cid'=>'','descr'=>'','hidx'=>'');
	      $show='cnm';
		}
   }elseif($input=='e'){
      $a_cnm = array('ip'=>'','cid'=>'','descr'=>'','hidx'=>'');
      $show='cnm_edit';
   }elseif($show=='cnm_edit'){
      if(!$a_cnm['hidx'])            $a_cnm['hidx']        = $input;
      elseif(!$a_cnm['ip'])          $a_cnm['ip']          = $input;
      elseif(!$a_cnm['descr'])       $a_cnm['descr']       = $input;
      elseif($input=='n'){
         $a_cnm = array('ip'=>'','cid'=>'','descr'=>'','hidx'=>'');
         $show='cnm';
      }
      elseif($input=='y'){
         add_CNM($a_cnm);
         $a_cnm = array('ip'=>'','cid'=>'','descr'=>'','hidx'=>'');
         $show='cnm';
      }
   }
	else{
      // beep en caso de entrada incorrecta
      echo chr(7);
	}
}
//------------------------------------------------------------------------------------
function local_ip(){
	if (getenv("CNM_LOCAL_IP") !== false) { $local_ip = getenv("CNM_LOCAL_IP"); }
	else {
	   $iface = local_iface();
   	$local_ip = chop(`/sbin/ifconfig $iface|grep 'inet addr'|cut -d ":" -f2|cut -d " " -f1`);
	}
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

//------------------------------------------------------------------------------------
function _DB(){
	global $dbc;
   // $dsn = array('phptype'=>'mysql','username'=>'root','password'=>'s30labs1234','hostspec'=>'localhost','database'=>'cnm');

	$cred = get_db_credentials();
   $dsn = array('phptype'=>'mysqli','username'=>'onm','hostspec'=>'localhost','database'=>'cnm');
	$dsn['password'] = $cred["CNM_DB_PASSWORD"];
	$dsn['hostspec'] = $cred["CNM_DB_SERVER"];
	$dbc = @DB::Connect($dsn,TRUE);
	if (@PEAR::isError($dbc)){
		echo "PROBLEMAS AL CONECTARSE A LA BBDD\n";
	}else{
		$dbc->setFetchMode(DB_FETCHMODE_ASSOC);
	}
   $query  = "SET CHARACTER SET 'utf8'";
   $result = $dbc->query($query);
}
//------------------------------------------------------------------------------------
function add_CNM($a_cnm){
	global $dbc;

	// Añadir
	if($a_cnm['hidx']=='-'){
		if($a_cnm['ip']==local_ip()){
	      $hash       = substr (md5(uniqid()), 0, 8);
	      $db1_name   = "onm_$hash";
	      $db1_user   = substr (md5(uniqid()), 1, 8);
			$db1_server = 'localhost';
			$db1_pwd    = 'cnm123';
		}else{
	      $db1_name   = '';
	      $db1_user   = '';
			$db1_server = '';
			$db1_pwd    = '';
		}
	
		// SSV (2012-09-05): Hay que manejar la situación de tener varios cids en la misma máquina local. Para lo cual habría que crear
		// el fichero de configuración adecuado en /cfg. Esto hay que hablarlo con Fernando pero basicamente sería un fichero llamado
		// /cfg/onm_$hash.conf y que debería contener (con los datos bien puestos):
		/*
	         DB_SERVER = localhost
	         DB_NAME = onm_$hash
	         DB_USER = onm
	         DB_PWD = cnm123
	         DB_TYPE = mysql
		*/
		$cid = 'default';
	   $query  = "INSERT INTO cfg_cnms (cid,descr,db1_name,host_ip) VALUES ('$cid','{$a_cnm['descr']}','$db1_name','{$a_cnm['ip']}')";
	   $result = $dbc->query($query);
	}
	// Modificar
	else{
	   $query  = "UPDATE cfg_cnms SET descr='{$a_cnm['descr']}',host_ip='{$a_cnm['ip']}' WHERE hidx='{$a_cnm['hidx']}'";
	   $result = $dbc->query($query);
	}
}
//------------------------------------------------------------------------------------
function delete_CNM($a_cnm){
   global $dbc;

	// Se elimina de los dominios en los que esté el cnm
	$query_2 = "DELETE FROM cfg_cnms2domains WHERE hidx={$a_cnm['hidx']}";
	$result_2 = $dbc->query($query_2);
	// Se elimina el cnm
   $query_3 =  "DELETE FROM cfg_cnms WHERE hidx={$a_cnm['hidx']}";
   $result_3 = $dbc->query($query_3);
}

//------------------------------------------------------------------------------------
function asoc_CNM_DOMAIN($a_asoc){
   global $dbc;

   $query_1 = "SELECT hidx FROM cfg_cnms WHERE host_ip='{$a_asoc['ip_cnm']}' AND cid='default'";
   $result_1 = $dbc->query($query_1);
   while ($result_1->fetchInto($r1)) $hidx = $r1['hidx'];
   if($hidx=='') return;

   $query_2 = "SELECT id_domain FROM cfg_domains WHERE name='{$a_asoc['name_domain']}'";
   $result_2 = $dbc->query($query_2);
   while ($result_2->fetchInto($r2)) $id_domain = $r2['id_domain'];
   if($id_domain=='') return;

   $query  = "INSERT INTO cfg_cnms2domains (hidx,id_domain) VALUES ($hidx,$id_domain)";
   $result = $dbc->query($query);
}

//------------------------------------------------------------------------------------
function deasoc_CNM_DOMAIN($a_asoc){
   global $dbc;

   $query_1 = "SELECT hidx FROM cfg_cnms WHERE host_ip='{$a_asoc['ip_cnm']}' AND cid='default'";
   $result_1 = $dbc->query($query_1);
	while ($result_1->fetchInto($r1)) $hidx = $r1['hidx'];
   if($hidx=='') return;

   $query_2 = "SELECT id_domain FROM cfg_domains WHERE name='{$a_asoc['name_domain']}'";
   $result_2 = $dbc->query($query_2);
	while ($result_2->fetchInto($r2)) $id_domain = $r2['id_domain'];
   if($id_domain=='') return;

   $query  = "DELETE FROM cfg_cnms2domains WHERE hidx=$hidx  AND id_domain=$id_domain";
   $result = $dbc->query($query);
}

//------------------------------------------------------------------------------------
function add_DOMAIN($a_domain){
   global $dbc;

	// Añadir
	if($a_domain['id_domain']=='-'){
		$query  = "INSERT INTO cfg_domains (name) VALUES ('{$a_domain['name']}')";
		$result = $dbc->query($query);
	}
	// Modificar
	else{
		$query  = "UPDATE cfg_domains SET name='{$a_domain['name']}' WHERE id_domain='{$a_domain['id_domain']}'";
      $result = $dbc->query($query);
	}
}
//------------------------------------------------------------------------------------
function delete_DOMAIN($a_domain){
   global $dbc;

   $query  = "DELETE FROM cfg_cnms2domains WHERE id_domain='{$a_domain['id_domain']}'";
   $result = $dbc->query($query);

   $query  = "DELETE FROM cfg_domains WHERE id_domain='{$a_domain['id_domain']}'";
   $result = $dbc->query($query);
}

//------------------------------------------------------------------------------------
function text_color($color){
   $colors = array(
      'light_red'  => "[1;31m", 'light_green' => "[1;32m", 'yellow'     => "[1;33m",
      'light_blue' => "[1;34m", 'magenta'     => "[1;35m", 'light_cyan' => "[1;36m",
      'white'      => "[1;37m", 'normal'      => "[0m",    'black'      => "[0;30m",
      'red'        => "[0;31m", 'green'       => "[0;32m", 'brown'      => "[0;33m",
      'blue'       => "[0;34m", 'cyan'        => "[0;36m", 'bold'       => "[1m",
      'underscore' => "[4m",    'reverse'     => "[7m" );
   if (!array_key_exists($color,$colors)) $color = 'normal';
   echo"\033{$colors[$color]}";
}
//------------------------------------------------------------------------------------
function cls(){
   echo "\033[2J"; // Borrar pantalla
   echo "\033[0;0H"; // Cursor to 0,0
}
//------------------------------------------------------------------------------------
function pos_cursor($x,$y){
   echo "\033[$y;{$x}H";
}
//------------------------------------------------------------------------------------
function quit(){
	cls();
	exit(0);
}
//------------------------------------------------------------------------------------
/*function get_db_credentials(){

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
*/

?>
