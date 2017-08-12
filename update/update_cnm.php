<?php
require_once 'VersionControl/SVN.php';
putenv('LANG=en_US.UTF-8');

if (get_param1('rev')=='') {
	die ("USO: php update_cnm.php rev=xxx\n");
}elseif(is_int(get_param1('rev')==false)){
	die ("USO: php update_cnm.php rev=xxx\n");
}else{
	$rev_final=get_param1('rev');
}


debug("*********** COMIENZA LA ACTUALIZACION ***********",__LINE__,'INF','main');
debug("*********** COMIENZA LA ACTUALIZACION ***********",__LINE__,'PRN','main');


$directorios_a_actualizar=array(
	// ruta_repositorio => ruta_local
	'/repos/cnm/www/html/onm'     => '/var/www/html/onm',
	'/repos/cnm/www/cgi-bin/onm'  => '/var/www/cgi-bin/onm',
	'/repos/cnm/crawler/bin'      => '/opt/crawler/bin',
	'/repos/cnm/mibs'             => '/opt/data/mibs',
	'/repos/cnm/os'               => '/os',
	'/repos/cnm/base'             => '/opt/data/xagent/base',
);
$cfg    = read_cfg_file1();
$server = ($cfg['UPDATE_SERVER_TYPE']=='custom')?$cfg['UPDATE_SERVER_NAME']:$cfg['UPDATE_SERVER_DEFAULT'];


relocate();
update($rev_final);
backup_bbdd();
update_bbdd($rev_final);
update_system($rev_final);
chk_cnm($rev_final);


debug("*********** FINALIZA LA ACTUALIZACION ***********\n\n",__LINE__,'INF','main');
debug("*********** FINALIZA LA ACTUALIZACION ***********",__LINE__,'PRN','main');
$pid = getmypid();
debug("Consulte el fichero /tmp/update.log para mayor informacion buscando el pid $pid",__LINE__,'PRN','main');
debug("Reiniciando procesos ...",__LINE__,'PRN','main');
exec("/etc/init.d/cnmd stop");
exec("/etc/init.d/cnmd kill");
debug("*********** VALORE SI ES NECESARIO EJECUTAR: php /update/db/update/oids_update.php",__LINE__,'PRN','main');

$salida=array();
exec("/opt/crawler/bin/support/cnm-subs",$salida);
foreach ($salida as $line) { print "$line\n"; }

return;



// ---------------------------------------------------------------------------------------------------- 
// Funcion: read_cfg_file1() 
// Input:
// Output:
// Descripcion: Funcion encargada de leer los parametros que estan en el hash $data del fichero /cfg/onm.conf
// y rellenarlos con los datos que tenga el fichero
// ---------------------------------------------------------------------------------------------------- 
function read_cfg_file1(){

	$file='/cfg/onm.conf';
	$data=array(
		'UPDATE_SERVER_TYPE'    => '',
		'UPDATE_SERVER_NAME'    => '',
		'UPDATE_PROXY_USE'      => '',
		'UPDATE_PROXY_VALUE'    => '',
		'UPDATE_PROXY_PORT'     => '',
		'UPDATE_PROXY_USER'     => '',
		'UPDATE_PROXY_KEY'      => '',
		'UPDATE_SERVER_DEFAULT' => '',
	);
   $lines = file($file);
   if (! $lines) {
		debug("Lectura del fichero de configuracion $file [NOOK]",__LINE__,'ERR','read_cfg_file1');	
		exit;
	}
   foreach ($data as $clave => $valor){
      $not_found=1;
      foreach ($lines as $l){
         if (preg_match("/^#/", $l))      continue;
         if (!preg_match("/$clave/", $l)) continue;

         $words=preg_split('/\s*\=\s*/',$l);
         if (($words[0] == $clave)&& ($not_found)) {
            $data[$clave] = rtrim($words[1]," \n");
            $not_found=0;
         }
      }
   }
   if ($data['UPDATE_SERVER_DEFAULT']==''){
      $data['UPDATE_SERVER_DEFAULT']='http://software.s30labs.com';
      write_cfg_file1($file,$data);
   }
	debug("Lectura del fichero de configuracion $file [OK]",__LINE__,'INF','read_cfg_file1');
	return $data;
}





// ---------------------------------------------------------------------------------------------------- 
// Funcion: write_cfg_file1() 
// Input: $file=> ruta del fichero de configuracion|$data=> hash con los datos
// Output:
// Descripcion: Funcion encargada de escribir en el fichero /cfg/onm.conf el hash $data
// ---------------------------------------------------------------------------------------------------- 
function write_cfg_file1($file,&$data){

   $rcstr='';
   $lines = file($file);
   if (! $lines){
		debug("Lectura del fichero de configuracion $file [NOOK]",__LINE__,'ERR','write_cfg_file1');	
		exit;
   }
   $data_bis=$data;
   foreach ($data_bis as $key => $value){$data_bis[$key] = "0"; }
   $new_data=array();
   foreach ($lines as $l){
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
		debug("Escritura del fichero de configuracion $file [NOOK]",__LINE__,'ERR','write_cfg_file1');	
		exit;
   }
   foreach ($new_data as $l2) {fwrite($tmp_file,$l2);}
   foreach ($data_bis as $key2 => $value2) {
      if (!$value2){fwrite($tmp_file,"$key2 = $data[$key2]\n");}
   }
   fclose($tmp_file);
	debug("Escritura del fichero de configuracion $file [OK]",__LINE__,'INF','write_cfg_file1');	
}





// ---------------------------------------------------------------------------------------------------- 
// Funcion: relocate() 
// Input:
// Output:
// Descripcion: Funcion encargada de cambiar la url, en caso de hacer falta, de los directorios que hay 
// que tener sincronizados con el repositorio
// ---------------------------------------------------------------------------------------------------- 
function relocate(){
global $directorios_a_actualizar, $server;

	debug("INICIO",__LINE__,'INF','relocate');	
	debug("INICIO",__LINE__,'PRN','relocate');	
	$rc = 0;
	foreach ($directorios_a_actualizar as $dir_remoto => $dir_local){
		// Se obtiene la informacion del directorio que estamos analizando
		$info_dir=dir_info($dir_local);
		// Caso en el que el directorio no existe o se ha creado localmente
		//	print "AQUI ==> {$info_dir['URL']} $server$dir_remoto \n"; 
		if($info_dir['URL']==''){
			// Si la ruta existe la borramos
			if (file_exists($dir_local)){rm($dir_local);	}
			// Setup error handling -- always a good idea!
		   $svnstack = &PEAR_ErrorStack::singleton('VersionControl_SVN');
		   // Set up runtime options.
			$svnpath=(file_exists('/usr/bin/svn'))?'/usr/bin/svn':'/usr/local/bin/svn';
		   $options = array('fetchmode' => VERSIONCONTROL_SVN_FETCHMODE_RAW, 'svn_path' => $svnpath,);
		   // Request list class from factory
		   $svn = VersionControl_SVN::factory(array('checkout'), $options);
		   // Define any switches and aguments we may need
		   $switches = array('username' => 'update', 'password' => 'update');
			$args = array("$server$dir_remoto",$dir_local);
				debug("El directorio $dir_local no existe o ha sido creado localmente. Se procede a actualizarlo",__LINE__,'INF','relocate');	
			if ($output = $svn->checkout->run($args, $switches)) {
				debug("Actualizacion de $dir_local [OK]",__LINE__,'INF','relocate');	
			}else{
				$rc = 1;
				debug("Actualizacion de $dir_local [NOOK]",__LINE__,'PRN','relocate');	
				debug("Actualizacion de $dir_local [NOOK]",__LINE__,'ERR','relocate');	
				if (count($errs = $svnstack->getErrors())) {
		      	foreach ($errs as $err) {
						debug("MSG=>{$err['message']}|CMD=>{$err['params']['cmd']}",__LINE__,'ERR','relocate');	
		         }
		    	}
			}
		}else{
			// Setup error handling -- always a good idea!
		   $svnstack = &PEAR_ErrorStack::singleton('VersionControl_SVN');
		   // Set up runtime options.
			$svnpath=(file_exists('/usr/bin/svn'))?'/usr/bin/svn':'/usr/local/bin/svn';
		   $options = array('fetchmode' => VERSIONCONTROL_SVN_FETCHMODE_RAW, 'svn_path' => $svnpath,);
		   // Request list class from factory
		   $svn = VersionControl_SVN::factory(array('switch'), $options);
		   // Define any switches and aguments we may need
		   $switches = array('username' => 'update', 'password' => 'update', 'relocate' => true);

			// En caso de no estar correctamente configurado el directorio se corrige
			if ($info_dir['URL']!="$server$dir_remoto"){
				$args = array($info_dir['URL'],"$server$dir_remoto",$dir_local);
				$svn->switch->run($args, $switches);
				if (count($errs = $svnstack->getErrors())) {
					debug("El directorio $dir_local no esta enlazado correctamente con el servidor y no se ha podido enlazar",__LINE__,'PRN','relocate');	
					debug("El directorio $dir_local no esta enlazado correctamente con el servidor y no se ha podido enlazar",__LINE__,'ERR','relocate');	
			   	foreach ($errs as $err) {
						debug("MSG=>{$err['message']}|CMD=>{$err['params']['cmd']}",__LINE__,'ERR','relocate');	
			     	}
				}else{
					debug("El directorio $dir_local no esta enlazado correctamente con el servidor y se ha enlazado OK",__LINE__,'INF','relocate');	
				}
			}
		}
	}
	if ($rc==0){debug("Todo OK",__LINE__,'PRN','relocate');}
	debug("FIN",__LINE__,'PRN','relocate');	
	debug("FIN",__LINE__,'INF','relocate');	
}





// ---------------------------------------------------------------------------------------------------- 
// Funcion: update() 
// Input:
// Output:
// Descripcion: Funcion encargada de hacer un svn update de los directorios que tener sincronizados con el repositorio
// ---------------------------------------------------------------------------------------------------- 
function update($rev){
global $directorios_a_actualizar;

   debug("INICIO",__LINE__,'PRN','update');
	debug("INICIO",__LINE__,'INF','update');
   $rc = 0;

	$svnstack = &PEAR_ErrorStack::singleton('VersionControl_SVN');
	$svnpath=(file_exists('/usr/bin/svn'))?'/usr/bin/svn':'/usr/local/bin/svn';
	$options = array('fetchmode' => VERSIONCONTROL_SVN_FETCHMODE_RAW, 'svn_path' => $svnpath,);
	$svn = VersionControl_SVN::factory(array('update'), $options);
	$switches = array('username' => 'update', 'password' => 'update', 'r' => $rev);
   foreach ($directorios_a_actualizar as $dir_remoto => $dir_local){
		$args = array($dir_local);
      if ($output = $svn->update->run($args, $switches)) {
	      debug("Actualizacion de $dir_local [OK]",__LINE__,'INF','update');
      }else{
   		debug("Actualizacion de $dir_local [NOOK]",__LINE__,'PRN','update');
         debug("Actualizacion de $dir_local [NOOK]",__LINE__,'ERR','update');
         if (count($errs = $svnstack->getErrors())) {
            foreach ($errs as $err) {
               debug("MSG=>{$err['message']}|CMD=>{$err['params']['cmd']}",__LINE__,'ERR','update');
            }
         }
      }
	}
	if ($rc==0){debug("Todo OK",__LINE__,'PRN','update');}
	debug("FIN",__LINE__,'PRN','update');
	debug("FIN",__LINE__,'INF','update');
}





function backup_bbdd(){
   debug("INICIO",__LINE__,'PRN','backup_bbdd');
   debug("INICIO",__LINE__,'INF','backup_bbdd');

   // SSV NOTA: SI SE PONE UN ESPACIO DESPUES DE -P, NO FUNCIONA, TIENE QUE SER ASI
	$pwd = chop(`cat /cfg/onm.conf | grep DB_PWD|cut -d "=" -f2 | tr -d ' '`);
   $exec=`/usr/bin/mysqldump -u onm -p$pwd onm>/tmp/backup_bbdd`;

   debug("Backup de la BBDD realizado en /tmp/backup_bbdd",__LINE__,'PRN','backup_bbdd');
   debug("Backup de la BBDD realizado en /tmp/backup_bbdd",__LINE__,'INF','backup_bbdd');
   debug("FIN",__LINE__,'PRN','backup_bbdd');
   debug("FIN",__LINE__,'INF','backup_bbdd');

}
// ---------------------------------------------------------------------------------------------------- 
// Funcion: update_bbdd() 
// Input:
// Output:
// Descripcion: Funcion encargada de actualizar la base de datos
// ---------------------------------------------------------------------------------------------------- 
function update_bbdd($rev){
	debug("INICIO",__LINE__,'PRN','update_bbdd');
	debug("INICIO",__LINE__,'INF','update_bbdd');
	$rc_str=`/usr/bin/php /update/db/db-manage.php -r $rev 2>&1`;
	debug($rc_str,__LINE__,'PRN','update_bbdd');
	debug($rc_str,__LINE__,'INF','update_bbdd');
	debug("FIN",__LINE__,'PRN','update_bbdd');
	debug("FIN",__LINE__,'INF','update_bbdd');
}





// ---------------------------------------------------------------------------------------------------- 
// Funcion: update_system() 
// Input:
// Output:
// Descripcion: Funcion encargada de actualizar el sistema
// ---------------------------------------------------------------------------------------------------- 
function update_system($rev){

	debug("INICIO",__LINE__,'PRN','update_system');
	debug("INICIO",__LINE__,'INF','update_system');
	$rc = 0;

	$path = '/os/update';
   $dir=opendir($path);
   $directorios=array();
   // Se obtienen los directorios que interesan, es decir los que son enteros
   while ($elemento = readdir($dir)){
      $int_elemento=(int)$elemento;
      if (($int_elemento<=$rev_ini)or($int_elemento>$revision)){continue;}
      if (strcmp($int_elemento,$elemento)){continue;}
      if (!is_dir("$path/$elemento")){continue;}
      array_push($directorios,$elemento);
   }
   //Cerramos el directorio
   closedir($dir);
   // Se ordenan los directorios por orden de revision
   $rc_sort=sort($directorios,SORT_NUMERIC);
   // Para cada directorio que haya y que no sea el .svn ejecutar install
   foreach($directorios as $directorio){
      $install_path="$path/$directorio/install";
      if (file_exists($install_path)){
         $install_cmd="cd $path/$directorio;./install";
         $cmd_rcstr=shell_exec($install_cmd);
			debug("Se ejecuta $install_cmd y el resultado es=>$cmd_rcstr",__LINE__,'INF','update_system');
      }else{
			debug("No se ha podido instalar el contenido de $path/$directorio",__LINE__,'PRN','update_system');
			debug("No se ha podido instalar el contenido de $path/$directorio",__LINE__,'ERR','update_system');
      }
	}
	if ($rc==0){debug("Todo OK",__LINE__,'PRN','update_system');}
	debug("FIN",__LINE__,'PRN','update_system');
	debug("FIN",__LINE__,'INF','update_system');
}


// ---------------------------------------------------------------------------------------------------- 
// Funcion: chk_cnm() 
// Input:
// Output:
// Descripcion: Funcion encargada de hacer un chk_cnm
// ---------------------------------------------------------------------------------------------------- 
function chk_cnm($rev){

	debug("INICIO",__LINE__,'PRN','chk_cnm');
	debug("INICIO",__LINE__,'INF','chk_cnm');
   $path_chk_cnm="/opt/crawler/bin/support/chk-cnm -u $rev > /tmp/update1.log";
   $cmd_str="/usr/bin/sudo $path_chk_cnm";
   $rc_str=shell_exec($cmd_str);
	debug("Se ejecuta $cmd_str. Mirar el fichero /tmp/update1.log para ver su resultado",__LINE__,'PRN','chk_cnm');
	debug("Se ejecuta $cmd_str. Mirar el fichero /tmp/update1.log para ver su resultado",__LINE__,'DBG','chk_cnm');
	debug("FIN",__LINE__,'PRN','chk_cnm');
	debug("FIN",__LINE__,'INF','chk_cnm');
}





// ----------------------------------------------------------------------------------------------
// Funcion: dir_info()
// Input: $dir=>Directorio local del que queremos obtener informacion de SVN
//	Output: $info=>hash que contiene el resultado de hacer un svn info del directorio de entrada 
// Descripcion: Funcion que devuelve en forma de hash la informacion de un directorio al hacerle
// un svn info
// ----------------------------------------------------------------------------------------------
function dir_info($dir){

	// Setup error handling -- always a good idea!
	$svnstack = &PEAR_ErrorStack::singleton('VersionControl_SVN');
	// Set up runtime options.
	


	$svnpath=(file_exists('/usr/bin/svn'))?'/usr/bin/svn':'/usr/local/bin/svn';
	$options = array('fetchmode' => VERSIONCONTROL_SVN_FETCHMODE_ARRAY, 'svn_path' => $svnpath,);
	// Request list class from factory
	$svn = VersionControl_SVN::factory(array('info'), $options);
   $args = array($dir);
   if ($output =explode("\n",chop($svn->info->run($args)))){
      foreach ($output as $_){
         // $data=split(": ",$_);
         $data=preg_split("/: /",$_);
			//print"DATA == $data\n";
			//print_r($data);
			//print("\n");
         $info[$data[0]]=$data[1];
      }
      // print_r($info);
		return $info;
	}else{
      // print_r($svnstack);
      if (count($errs = $svnstack->getErrors())) {
         foreach ($errs as $err) {
            echo "ERROR:{$err['message']}\n";
            echo "Command used: {$err['params']['cmd']}\n";
         }
      }
		return;	
   }
}





// ---------------------------------------------------------------------------------------------------- 
// Funcion: rm() 
// Input:$fileglob=>Ruta del directorio a borrar
// Output:
// Descripcion: Funcion encargada de borrar el directorio que se le pase como parametro
// ---------------------------------------------------------------------------------------------------- 
function rm($fileglob) { 
   if (is_string($fileglob)) { 
       if (is_file($fileglob)) { 
           return unlink($fileglob); 
       } else if (is_dir($fileglob)) { 
           $ok = rm("$fileglob/*"); 
           if (! $ok) { 
               return false; 
           } 
           return rmdir($fileglob); 
       } else { 
           $matching = glob($fileglob); 
           if ($matching === false) { 
               trigger_error(sprintf('No files match supplied glob %s', $fileglob), E_USER_WARNING); 
               return false; 
           }       
           $rcs = array_map('rm', $matching); 
           if (in_array(false, $rcs)) { 
               return false; 
           } 
       }       
   } else if (is_array($fileglob)) { 
       $rcs = array_map('rm', $fileglob); 
       if (in_array(false, $rcs)) { 
           return false; 
       } 
   } else { 
       trigger_error('Param #1 must be filename or glob pattern, or array of filenames or glob patterns', E_USER_ERROR); 
       return false; 
   } 
   return true; 
} 





// ---------------------------------------------------------------------------------------------------- 
// Funcion: get_param1() 
// Input:$p=>parametro a leer
// Output:
// Descripcion: Funcion encargada de leer el parametro $p de linea de comandos, $_POST o $_GET
// ---------------------------------------------------------------------------------------------------- 
function get_param1($p){
   if (isset($_POST[$p]))    return $_POST[$p];
   elseif (isset($_GET[$p])) return $_GET[$p];
   // SSV: El siguiente elseif sirve para poder ejecutar por linea de comandos los phps que nos interesen
   // poniendo php fichero.php var1=valor1 var2=valor2
   // En caso de notar algun malfuncionamiento, comentarlo
   elseif (count($GLOBALS['argv'])>0){
      for ($i=1;$i<count($GLOBALS['argv']);$i++){
         $datos=explode('=',$GLOBALS['argv'][$i]);
         if ($datos[0]==$p) return $datos[1];
      }
   }
   return '';
}





// ---------------------------------------------------------------------------------------------------- 
// Funcion: debug() 
// Input:$msg=>Mensaje a escribir|$linea=>linea donde se ha generado el mensaje|$sev=>Severidad del mensaje
// |$func=>Funcion que genera el mensaje
// Output:
// Descripcion: Funcion encargada de hacer un log
// ---------------------------------------------------------------------------------------------------- 
function debug($msg,$linea,$sev,$func){
$debug_file='/tmp/update.log';

if ($sev=='DBG'){return;}
if ($sev=='PRN'){
   $fecha=date("Y-m-d H:m:s");
	echo("$fecha::$func::LINEA $linea::$msg\n");
	return;
}
if ($sev=='ERR'){
   $fecha=date("Y-m-d H:m:s");
   echo("$fecha::$func::LINEA $linea::$msg\n");
}

   $fecha=date("Y-m-d H:m:s");
	$pid=getmypid();
   $fd=fopen($debug_file,'a+');
   fwrite($fd,"[$sev][$pid]$fecha::update_cnm.php::$func::LINEA $linea::$msg\n");
   fclose($fd);
}
?>
