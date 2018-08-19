#!/usr/bin/php
<?php
/*
 *	DESCRIPCION: Programa que aplica la configuración a la BBDD para que funcione
 *              La salida se guarda en /tmp/update.log
*/ 

// MODULO QUE CONTIENE LAS FUNCIONES
require_once('/update/db/DB-Scheme-Lib.php');

global $enlace;
$opts = getopt("u:r:hafp:d:c:x:n:t");

$force = (isset($opts['f']))?true:false;


/* ---------------------------------------------------------------------------------
 * PARAMETRO: -h
 * DESCR: Mostrar la ayuda
 * NOTAS: 
 * USO: php db-manage.php -h
*/
if(isset($opts['h'])){
	help();
}

/* ---------------------------------------------------------------------------------
 * PARAMETRO: -a
 * DESCR: Actualizar el charset de las tablas a latin1
 * NOTAS: No se usa normalmente, sólo cuando se quiera actualizar el charset, cosa que ya se hace al hacer el db-manage normalmente
 *        Para ver que funciona correctamente hacer: ALTER TABLE cfg_users charset=utf8; y después ejecutar esta opción
 *	USO: php db-manage.php -a
*/
elseif(isset($opts['a'])){
   d_update_charset();
}

/* ---------------------------------------------------------------------------------
 *	PARAMETRO: -u
 * DESCR: Actualizar el contenido la tabla indicada
 * NOTAS: Este tipo de actualización no hace que se reinicien los procedimientos almacenados.
 *        Se basa en los datos definidos en las rutas estandar.
 * USO: php db-manage.php -u [nombre_tabla]
 *	EJ: php db-manage.php -u cfg_users
*/
elseif(isset($opts['u'])){
	d_read_conf_tabla($opts['u']);
	d_update_table();
}

/* ---------------------------------------------------------------------------------
 *	PARAMETRO: -p
 * DESCR: Instalar un plugin que se encuentra en el directorio indicado
 * NOTAS: Inserta tablas y datos (tanto en las tablas nuevas como en tablas de sistema)
 *        Lee los datos del directorio y dentro debe existir una estructura del tipo:
 *        	directorio/
 *        	directorio/update/
 *        	directorio/update/db/
 *        	directorio/update/db/DB-Scheme-Create.php => De aquí se saca la estructura de las tablas
 *        	directorio/update/db/DB-Scheme-Init.php   => Fichero en el que se indica qué datos se van a usar y donde 
 *        	directorio/update/db/Init/
 *        	directorio/update/db/Init/[nombre_tabla1]/
 *        	directorio/update/db/Init/[nombre_tabla1]/[fichero1_datos_tabla1].php
 *        	directorio/update/db/Init/[nombre_tabla1]/[fichero2_datos_tabla1].php
 *        	directorio/update/db/Init/[nombre_tabla1]/[ficheroN_datos_tabla1].php
 *        	directorio/update/db/Init/[nombre_tabla2]/
 *        	directorio/update/db/Init/[nombre_tabla2]/[fichero1_datos_tabla2].php
 *        	directorio/update/db/Init/[nombre_tabla2]/[fichero2_datos_tabla2].php
 *        	directorio/update/db/Init/[nombre_tabla2]/[ficheroN_datos_tabla2].php
 *
 *       Actualmente, en caso de querer introducir valores en una tabla, hay que ponerla en directorio/update/db/DB-Scheme-Create.php
 *       aunque ya exista. Esto cambiará en un futuro porque es fuente de problemas.
 *
 * USO: php db-manage.php -p [directorio]
 * EJ: php db-manage.php -p /opt/custom_pro
*/
elseif(isset($opts['p'])){
	//$opts['p'] contiene el directorio del plugin
	//$plug_name = basename($opts['p']); 
	d_read_conf_install_plugin($opts['p']);
	d_install_plugin($opts['p']);
}

/* ---------------------------------------------------------------------------------
 * PARAMETRO: -c
 * DESCR: Desinstala un plugin que se encuentra en el directorio indicado
 * NOTAS: Elimina los datos ($dir/update/db/DB-Scheme-Init.php) de las tablas indicadas ($dir/update/db/DB-Scheme-Create.php) 
 *        Lee los datos del directorio y dentro debe existir una estructura del tipo:
 *          directorio/
 *          directorio/update/
 *          directorio/update/db/
 *          directorio/update/db/DB-Scheme-Create.php => De aquí se saca la estructura de las tablas
 *          directorio/update/db/DB-Scheme-Init.php   => Fichero en el que se indica qué datos se van a eliminar y donde 
 *
 *        No elimina las tablas que haya creado por si hay alguna otra que la utiliza
 * USO: php db-manage.php -c [directorio]
 * EJ: php db-manage.php -c /opt/custom_pro
*/
elseif(isset($opts['c'])){
	$plug_name = basename($opts['c']);
	d_read_conf_uninstall_plugin($opts['c']);
	d_uninstall_plugin($plug_name);
}

/* ---------------------------------------------------------------------------------
 * PARAMETRO: -d
 * DESCR: Elimina las tablas indicadas
 * NOTAS: Las tablas deben estar separadas por espacios
 * USO: php db-manage.php -d [tablas]
 * EJ: php db-manage.php -d cfg_users devices
*/
elseif(isset($opts['d'])){
	d_drop_table($opts['d']);
}

/* ---------------------------------------------------------------------------------
 * PARAMETRO: -x
 * DESCR: Carga en BBDD los elementos del fichero xml
 * NOTAS: El fichero xml contiene definición de métricas de cualquier tipo. Para obtenerlo hay que ir a la parte de métricas, marcar
 *        las que nos interesan y pulsar en el botón exportar. Cuando se pulsa en el botón importar lo que se ejecuta es esta opción.
 * USO: php db-manage.php -x [fichero]
 * EJ: php db-manage.php -x /tmp/export-snmp-20130823-133833.xml
*/
elseif(isset($opts['x'])){
	d_read_conf_xml($opts['x']);
	d_install_file();
}

/* ---------------------------------------------------------------------------------
 * PARAMETRO: -n
 * DESCR: Elimina las entradas de plugin_base las entradas de un plugin
 * NOTAS: El plugin se identifica por el plugin_id del mismo
 * USO: php db-manage.php -n [plugin_id]
 * EJ: php db-manage.php -n 0
*/
elseif(isset($opts['n'])){
	d_clear_plugin_base($opts['n']);
}

/* ---------------------------------------------------------------------------------
 * PARAMETRO: -t
 * DESCR: Regenera la tabla tips (id_refn)
 * NOTAS: 
 * USO: php db-manage.php -t
*/
elseif(isset($opts['t'])){
   d_update_tips();
}

/* ---------------------------------------------------------------------------------
 * PARAMETRO:
 * DESCR: Creación/actualización de las BBDD, tablas y datos a partir de los datos estandar. 
 * NOTAS: Es el uso normal de db-manage.php
 * USO: db-manage.php
*/
else{
	d_read_conf_standar();
	d_clear_plugin_base('-1');
   d_update_charset();
	$rev = (isset($opts['r']))?$opts['r']:0;
   d_update_db($rev,$force);
}



///////////////
// Funciones //
///////////////

/*
 * Funcion: d_read_conf_install_plugin()
 * Input:
 *        $dir => Directorio que va a contener los ficheros con los datos. Debe existir una estructura del tipo:
 *                   $dir/
 *                   $dir/update/
 *                   $dir/update/db/
 *                   $dir/update/db/DB-Scheme-Create.php => De aquí se saca la estructura de las tablas
 *                   $dir/update/db/Init/
 *                   $dir/update/db/Init/[nombre_tabla1]/
 *                   $dir/update/db/Init/[nombre_tabla1]/[fichero1_datos_tabla1].php
 *                   $dir/update/db/Init/[nombre_tabla1]/[fichero2_datos_tabla1].php
 *                   $dir/update/db/Init/[nombre_tabla1]/[ficheroN_datos_tabla1].php
 *                   $dir/update/db/Init/[nombre_tabla2]/
 *                   $dir/update/db/Init/[nombre_tabla2]/[fichero1_datos_tabla2].php
 *                   $dir/update/db/Init/[nombre_tabla2]/[fichero2_datos_tabla2].php
 *                   $dir/update/db/Init/[nombre_tabla2]/[ficheroN_datos_tabla2].php
 *
 * Output:
 * Descr: Lee los ficheros del plugin en los que se encuentran los datos de la estructura de tablas y los valores de las tablas
 *        que incorpora el plugin.
*/
function d_read_conf_install_plugin($dir){
global $DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure;

   if(!is_dir($dir)){
      print "El directorio $dir no existe\n";
      exit(1);
   }
   require_once("$dir/update/db/DB-Scheme-Create.php");

	/*
	 * $a_not_update_data : Tablas que deben tratarse de una forma diferente a la estandar
	 *
	*/
	$a_not_update_data = array('cnm_config','tips','cfg_users');

	$DBData = array();
	$dh  = opendir("$dir/update/db/Init/");
	while (false !== ($tabla = readdir($dh))) {
      if( (!is_dir("$dir/update/db/Init/$tabla")) or ($tabla=='.') or ($tabla=='..') ) continue;
      $a_files = glob("$dir/update/db/Init/$tabla/*.php");
      foreach ($a_files as $file) require_once($file);
      $DBData[$tabla] = (in_array($tabla,$a_not_update_data))?array():${strtoupper($tabla)};
   }
   closedir($dh);

	
	/*
	 * Datos que deben ser actualizados con cierto criterio
	 * NOTAS: A $DBModData se le va a aplicar la función DataModInit()
	*/
	$DBModData = array(
	   'tips'       => array('data'=>$TIPS, 'key'=>array('id_ref','tip_type'),'condition'=>'tip_class=1'),
	   'cnm_config' => array('data'=>$CNM_CONFIG, 'key'=>array('cnm_key'),'condition'=>"cnm_value=''"),
	   'cfg_users'  => array('data'=>$CFG_USERS, 'key'=>array('login_name'),'condition'=>"token=''"),
	);
}

/*
 * Funcion: d_read_conf_uninstall_plugin()
 * Input:
 *        $dir => Directorio que contiene los datos de las tablas del plugin que van a ser eliminados
 * Output:
 * Descr: Lee los ficheros del plugin en los que se encuentran los datos para desinstalarlo
 *        Elimina los datos ($dir/update/db/DB-Scheme-Init.php) de las tablas indicadas ($dir/update/db/DB-Scheme-Create.php) 
 *        Lee los datos del directorio y dentro debe existir una estructura del tipo:
 *          $dir/
 *          $dir/update/
 *          $dir/update/db/
 *          $dir/update/db/Init/
 *        	$dir/update/db/Init/[nombre_tabla1]/
 *         	$dir/update/db/Init/[nombre_tabla1]/[fichero1_datos_tabla1].php
 *         	$dir/update/db/Init/[nombre_tabla1]/[fichero2_datos_tabla1].php
 *         	$dir/update/db/Init/[nombre_tabla1]/[ficheroN_datos_tabla1].php
 *         	$dir/update/db/Init/[nombre_tabla2]/
 *         	$dir/update/db/Init/[nombre_tabla2]/[fichero1_datos_tabla2].php
 *         	$dir/update/db/Init/[nombre_tabla2]/[fichero2_datos_tabla2].php
 *         	$dir/update/db/Init/[nombre_tabla2]/[ficheroN_datos_tabla2].php
 *
 *        No elimina las tablas que haya creado por si hay alguna otra que la utiliza
*/
function d_read_conf_uninstall_plugin($dir){
global $DBData;

   if(!is_dir($dir)){
      print "El directorio $dir no existe\n";
      exit(1);
   }
   $DBData = array();
   $dh  = opendir("$dir/update/db/Init/");
   while (false !== ($tabla = readdir($dh))) {
      if( (!is_dir("$dir/update/db/Init/$tabla")) or ($tabla=='.') or ($tabla=='..') ) continue;
      $a_files = glob("$dir/update/db/Init/$tabla/*.php");
      foreach ($a_files as $file) require_once($file);
      $DBData[$tabla] = ${strtoupper($tabla)};
   }
   closedir($dh);
}

/*
 *	Funcion: d_read_conf_standar()
 *	Input:
 *	Output:
 *	Descr: Lee los ficheros estandar en los que se encuentran los datos de la estructura de tablas, los valores de las tablas y
 *        los procedimientos de las las BBDD CNM y ONM.
*/
function d_read_conf_standar(){
global $DBSchemeCNM,$DBExcepcionCNM,$DBDataCNM,$DBModDataCNM,$DBProcedureCNM,$DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure;

   require_once('/update/db/DB-Scheme-Create.php');      // $DBExcepcion,$DBScheme
   require_once('/update/db/DB-Scheme-Init.php');        // $DBData,$DBModData,$DBDataCNM,$DBModDataCNM
   require_once('/update/db/DB-Procedure-Init.php');     // $DBProcedure
   require_once('/update/db/DB-Scheme-Create-cnm.php');  // $DBExcepcionCNM,$DBSchemeCNM
   require_once('/update/db/DB-Procedure-Init-cnm.php'); // $DBProcedureCNM
}

function d_read_conf_tabla($table_read){
	global $DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure;

   require_once("/update/db/DB-Scheme-Create.php");
	foreach($DBScheme as $tabla => $foo){
		if($tabla!=$table_read) unset($DBScheme[$tabla]);
	}

   /*
    * $a_not_update_data : Tablas que deben tratarse de una forma diferente a la estandar
    *
   */
   $a_not_update_data = array('cnm_config','tips','cfg_users');

   $DBData = array();
   $dh  = opendir("/update/db/Init/");
   while (false !== ($tabla = readdir($dh))) {
		if($tabla!=$table_read) continue;
      if( (!is_dir("/update/db/Init/$tabla")) or ($tabla=='.') or ($tabla=='..') ) continue;
      $a_files = glob("/update/db/Init/$tabla/*.php");
      foreach ($a_files as $file) require_once($file);
      $DBData[$tabla] = (in_array($tabla,$a_not_update_data))?array():${strtoupper($tabla)};
   }
   closedir($dh);


   /*
    * Datos que deben ser actualizados con cierto criterio
    * NOTAS: A $DBModData se le va a aplicar la función DataModInit()
   */
   $DBModData = array(
      'tips'       => array('data'=>$TIPS, 'key'=>array('id_ref','tip_type'),'condition'=>'tip_class=1'),
      'cnm_config' => array('data'=>$CNM_CONFIG, 'key'=>array('cnm_key'),'condition'=>"cnm_value=''"),
      'cfg_users'  => array('data'=>$CFG_USERS, 'key'=>array('login_name'),'condition'=>"token=''"),
   );
}

/*
 * Funcion: d_read_conf_xml()
 * Input:
 *        $file =>  Ruta del fichero xml
 * Output:
 * Descr: Lee el fichero xml que contiene la definición de una o varias  métricas. Estos ficheros se consiguen desde la interfaz, marcando
 *        las métricas y dando al botón exportar. 
*/
function d_read_conf_xml($file){
global $DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure;

	if (!file_exists($file) || !is_readable($file) ){
      print "El fichero $file no existe\n";
      exit(1);
	}
	$xml         = simplexml_load_file($file,null, LIBXML_NOCDATA);
	$json        = json_encode($xml);
	$array       = json_decode($json,TRUE);
	$export_data = $array['data'];

	// Se limpian los elementos que esten vacios porque aparecen como arrays con 0 elementos
	foreach($export_data as $tabla => $a_elems){

		// 1 elemento en la tabla
		if(is_array($a_elems) and is_assoc($a_elems)){
			// print "TABLA ($tabla ) ES UNICA\n";
			$aux_array = array();
			foreach($a_elems as $key => $value){
				// Los elementos vacios en vez de representarse como un array vacio se pone como una cadena vacia
            if(is_array($value) and count($value)==0) $export_data[$tabla][$key]='';
				if($key=='cfg_remote_alerts2expr'){
					// 1 expresion
					if(is_array($value) and is_assoc($value)){
						$aux_expr_array = array();
						foreach($value as $key_expr => $val_expr){
							// Los elementos vacios en vez de representarse como un array vacio se pone como una cadena vacia
			            if(is_array($val_expr) and count($val_expr)==0) $export_data[$tabla][$key][$key_expr]='';
							$aux_expr_array[$key_expr] = $export_data[$tabla][$key][$key_expr];
							unset($export_data[$tabla][$key][$key_expr]);
						}
						$export_data[$tabla][$key][]=$aux_expr_array;
					}
					// +1 expresion
					else{
						foreach($value as $index_expr => $a_expr){
							foreach($a_expr as $key_expr => $val_expr){
								// Los elementos vacios en vez de representarse como un array vacio se pone como una cadena vacia
	                     if(is_array($val_expr) and count($val_expr)==0) $export_data[$tabla][$key][$index_expr][$key_expr]='';
							}
						}
					}
					$export_data[$tabla][$key]['id'] = 'id_remote_alert';
				}
				$aux_array[$key] = $export_data[$tabla][$key];
				unset($export_data[$tabla][$key]);
			}
			$export_data[$tabla][]=$aux_array;
		}
		// +1 elemento en la tabla
		else{
			// print "TABLA ($tabla ) ES MULTIPLE\n";
			foreach($a_elems as $index_elem => $elem){
				foreach($elem as $key => $value){
					if(is_array($value) and count($value)==0) $export_data[$tabla][$index_elem][$key]='';

	            if($key=='cfg_remote_alerts2expr'){
	               // 1 expresion
	               if(is_array($value) and is_assoc($value)){
	                  $aux_expr_array = array();
	                  foreach($value as $key_expr => $val_expr){
	                     // Los elementos vacios en vez de representarse como un array vacio se pone como una cadena vacia
	                     if(is_array($val_expr) and count($val_expr)==0) $export_data[$tabla][$index_elem][$key][$key_expr]='';
	                     $aux_expr_array[$key_expr] = $export_data[$tabla][$index_elem][$key][$key_expr];
	                     unset($export_data[$tabla][$index_elem][$key][$key_expr]);
   	               }
	                  $export_data[$tabla][$index_elem][$key][]=$aux_expr_array;
	               }
	               // +1 expresion
	               else{
	                  foreach($value as $index_expr => $a_expr){
	                     foreach($a_expr as $key_expr => $val_expr){
	                        // Los elementos vacios en vez de representarse como un array vacio se pone como una cadena vacia
	                        if(is_array($val_expr) and count($val_expr)==0) $export_data[$tabla][$index_elem][$key][$index_expr][$key_expr]='';
	                     }
	                  }
	               }
						$export_data[$tabla][$index_elem][$key]['id'] = 'id_remote_alert';
	            }
				}
			}
		}
	}	


	// require_once('/update/db/DB-Scheme-Create.php');
	// require_once('/opt/cnm/update/db/DB-Scheme-Init-File.php');

   /*
    * $a_not_update_data : Tablas que deben tratarse de una forma diferente a la estandar
    *
   */
   $a_not_update_data = array('cnm_config','tips','cfg_users');

   $DBData = array();
	foreach($export_data as $tablaM => $data){
		$tabla = strtolower($tablaM);
		$DBData[$tabla] = (in_array($tabla,$a_not_update_data))?array():$data;
	}

   /*
    * Datos que deben ser actualizados con cierto criterio
    * NOTAS: A $DBModData se le va a aplicar la función DataModInit()
   */
   $DBModData = array(
      'tips'       => array('data'=>$export_data['TIPS'], 'key'=>array('id_ref','tip_type'),'condition'=>'tip_class=1'),
      'cnm_config' => array('data'=>$export_data['CNM_CONFIG'], 'key'=>array('cnm_key'),'condition'=>"cnm_value=''"),
      'cfg_users'  => array('data'=>$export_data['CFG_USERS'], 'key'=>array('login_name'),'condition'=>"token=''"),
   );
}

/*
 * Funcion: d_install_plugin()
 * Input:
 * Output:
 * Descr: Inserta en BBDD las tablas y datos que se indican en un plugin
*/
function d_install_plugin($plug_dir){
global $DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure,$force;

	$plug_name = basename($plug_dir);
	print "INSTALANDO PLUGIN:\t$plug_name\t";
	$db_params = get_db_credentials_all();

//   $db_params=array(
//		'phptype'  => 'mysql',
//		'username' => 'onm',
//		'hostspec' => 'localhost',
//		'database' => 'cnm',
//		'password' => get_db_credentials(),
//	);

   $a_client = _cnms($db_params); 
   foreach($a_client as $client){
		print " ({$client['db1_name']})\t";

      $db_params = array(
			'phptype'  => 'mysql',
			'username' => $client['db1_user'],
			'password' => $client['db1_pwd'],
			'hostspec' => $client['db1_server'],
			'database' => $client['db1_name'],
			'cid'      => $client['cid'],
		);
/*
      $tableScheme    = array();
      $tableData      = array();
      $tableExcepcion = array('devices_custom_data');
		foreach($DBScheme as $table=>$foo){
         $tableScheme[$table] = $DBScheme[$table];
         $tableData[$table]   = $DBData[$table];
         create_update_table($tableScheme,$tableData,$db_params,$tableExcepcion);
		}
*/
		update_db_plugin($DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure,$db_params,$force,$plug_dir);
		print "[OK]\n";
   }
}

/*
 * Funcion: d_clear_plugin_base()
 * Input:
 *        $plugin_id => plugin_id del plugin que queremos eliminar de plugin_base
 * Output:
 * Descr: Elimina de plugin_base todas las entradas cuyo plugin_id sea igual al indicado
*/
function d_clear_plugin_base($plugin_id=''){
	if($plugin_id=='') return;

	$db_params = get_db_credentials_all();
	
//   $db_params=array(
//		'phptype'  => 'mysql',
//		'username' => 'onm',
//		'hostspec' => 'localhost',
//		'database' => 'cnm',
//		'password' => get_db_credentials(),
//	);



   $a_client = _cnms($db_params);
   foreach($a_client as $client){
		print "Elimino plugin ($plugin_id) de {$client['db1_name']} ...";
      $db_params = array(
			'phptype'  => 'mysql',
			'username' => $client['db1_user'],
			'password' => $client['db1_pwd'],
			'hostspec' => $client['db1_server'],
			'database' => $client['db1_name'],
			'cid'      => $client['cid']
		);
      clear_plugin_base($plugin_id,$db_params);
		print "[OK]\n";
   }
}

/*
 * Funcion: d_update_tips()
 * Input:
 * Output:
 * Descr: Actualiza el campo id_refn de la tabla tips
*/
function d_update_tips(){

   $db_params = get_db_credentials_all();

//   $db_params=array(
//		'phptype'  => 'mysql',
//		'username' => 'onm',
//		'hostspec' => 'localhost',
//		'database' => 'cnm',
//		'password' => get_db_credentials(),
//	);

   $a_client = _cnms($db_params);
   foreach($a_client as $client){
		print "Actualizo la tabla tips de {$client['db1_name']} ...";
      $db_params = array(
			'phptype'  => 'mysql',
			'username' => $client['db1_user'],
			'password' => $client['db1_pwd'],
			'hostspec' => $client['db1_server'],
			'database' => $client['db1_name'],
			'cid'      => $client['cid']
		);
      tips_update_aux($db_params);
		print "[OK]\n";
   }
}




/*
 * Funcion: d_install_file()
 * Input:
 * Output:
 * Descr: Instala en la BBDD los datos leidos anteriormente por la funcion d_read_conf_xml()
*/
function d_install_file(){
global $DBScheme,$DBData,$DBModData,$DBExcepcion,$force;
	
	print "INSTALANDO DATOS DESDE FICHERO ...\n";
   $db_params = get_db_credentials_all();

//   $db_params=array(
//		'phptype'  => 'mysql',
//		'username' => 'onm',
//		'hostspec' => 'localhost',
//		'database' => 'cnm',
//		'password' => get_db_credentials(),
//	);

   $a_client = _cnms($db_params);
   foreach($a_client as $client){
		print "{$client['db1_name']}...";
      $db_params = array(
         'phptype'  => 'mysql',
			'username' => $client['db1_user'],
			'password' => $client['db1_pwd'],
         'hostspec' => $client['db1_server'],
			'database' => $client['db1_name'],
			'cid'      => $client['cid'],
		);

		update_db_plugin($DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure,$db_params,$force);
      print "[OK]\n";
   }




/*
	   connectDB($db_params);

      $tableScheme    = array();
      $tableData      = array();
      $tableExcepcion = array('devices_custom_data');
      foreach($DBScheme as $table=>$foo){
      	if(is_array($DBScheme[$table]) AND is_array($DBData[$table])){
         	$tableScheme[$table] = $DBScheme[$table];
         	$tableData[$table]   = $DBData[$table];
      	}
      }
		DataInit($tableData,$tableScheme);
		print "[OK]\n";
   }
*/
}

/*
 * Funcion: d_uninstall_plugin()
 * Input:
 * Output:
 * Descr: Elimina los datos de las tablas que se han leido previamente en d_read_conf_uninstall_plugin()
 *
 *        No elimina las tablas que haya creado por si hay alguna otra que la utiliza
*/
function d_uninstall_plugin($plug_name){
global $DBData;

	print "DESISTALANDO PLUGIN:\t$plug_name ...\n";
   $db_params = get_db_credentials_all();

//   $db_params=array(
//		'phptype'  => 'mysql',
//		'username' => 'onm',
//		'hostspec' => 'localhost',
//		'database' => 'cnm',
//		'password' => get_db_credentials(),
//	);

   $a_client = _cnms($db_params);
   foreach($a_client as $client){
		print "{$client['db1_name']}...";
      $db_params = array(
         'phptype'  => 'mysql',
			'username' => $client['db1_user'],
			'password' => $client['db1_pwd'],
         'hostspec' => $client['db1_server'],
			'database' => $client['db1_name'],
			'cid'      => $client['cid'],
		);
      foreach($DBData as $tableName=>$tableData) delete_from_table($tableName,$tableData,$db_params);
		print "[OK]\n";
   }
}

/*
 * Funcion: d_update_table()
 * Input:
 * Output:
 * Descr: Actualiza una tabla en concreto (estructura y datos)
*/
function d_update_table(){
   global $DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure,$force;


	print "ACTUALIZANDO TABLAS ...\n";
   $db_params = get_db_credentials_all();

//   $db_params=array(
//      'phptype'  => 'mysql',
//      'username' => 'onm',
//      'hostspec' => 'localhost',
//      'database' => 'cnm',
//		'password' => get_db_credentials(),
//   );

   // Se actualizan las bases de datos de los clientes
   $a_client = _cnms($db_params);
   foreach($a_client as $client){
		print "{$client['db1_name']}...";
      $db_params = array(
         'phptype'  => 'mysql',
         'username' => $client['db1_user'],
         'password' => $client['db1_pwd'],
         'hostspec' => $client['db1_server'],
         'database' => $client['db1_name'],
         'cid'      => $client['cid'],
      );

      update_db_plugin($DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure,$db_params,$force);
		print "[OK]\n";
   }
}

/*
 * Funcion: d_update_charset()
 * Input:
 * Output:
 * Descr: Actualiza a latin1 el charset de las tablas de las BBDD existentes
*/
function d_update_charset(){

   $db_params = get_db_credentials_all();

//   $db_params=array(
//      'phptype'  => 'mysql',
//      'username' => 'onm',
//     'hostspec' => 'localhost',
//      'database' => 'cnm',
//		'password' => get_db_credentials(),
//   );
	print "Update charset cnm ... ";
   table_charset_latin1($db_params);
	print "[OK]\n";

   $a_client = _cnms($db_params);
   foreach($a_client as $client){
      $db_params = array(
         'phptype'  => 'mysql',
         'username' => $client['db1_user'],
         'password' => $client['db1_pwd'],
         'hostspec' => $client['db1_server'],
         'database' => $client['db1_name'],
      );
		print "Update charset {$client['db1_name']} ... ";
      table_charset_latin1($db_params);
		print "[OK]\n";
   }
}

/*
 * Funcion: d_update_db()
 * Input:
 *       $rev => 
 * Output:
 * Descr: Crea la BBDD CNM (en caso de no existir), la inicializa, crea las BBDD ONM (en caso de no existir) y las inicializa.
*/
function d_update_db($rev,$force=false){
global $DBSchemeCNM,$DBExcepcionCNM,$DBDataCNM,$DBModDataCNM,$DBProcedureCNM,$DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure;

   $db_params = get_db_credentials_all();

//   $db_params=array(
//      'phptype'  => 'mysql',
//      'username' => 'onm',
//      'hostspec' => 'localhost',
//      'database' => 'cnm',
//		'password' => get_db_credentials(),
//   );
	print "Creando bbdd cnm ... ";
   _create_cnm_database($db_params);
	print "[OK]\n";

	print "Actualizando bbdd cnm ... ";
   update_db($DBSchemeCNM,$DBExcepcionCNM,$DBDataCNM,$DBModDataCNM,$DBProcedureCNM,$db_params,$rev,$force);
	print "[OK]\n";

   $a_client = _cnms($db_params);
	print "Creando bbdd clientes ... ";
   _create_clients_databases($a_client,$db_params);
	print "[OK]\n";

   foreach($a_client as $client){
		print "Actualizando bbdd {$client['db1_name']} ... ";
      $db_params = array(
         'phptype'  => 'mysql',
         'username' => $client['db1_user'],
         'password' => $client['db1_pwd'],
         'hostspec' => $client['db1_server'],
         'database' => $client['db1_name'],
			'cid'      => $client['cid'],
      );
      update_db($DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure,$db_params,$rev,$force);
		print "[OK]\n";
   }
}

/*
 * Funcion: d_drop_table()
 * Input:
 *        $tables => Nombres separados por espacios de las tablas
 * Output:
 * Descr: Elimina de la BBDD las tablas indicadas
*/
function d_drop_table($tables){

	print "ELIMINANDO TABLAS ...\n";
   $db_params = get_db_credentials_all();

//   $db_params=array(
//		'phptype'  => 'mysql',
//		'username' => 'onm',
//		'hostspec' => 'localhost',
//		'database' => 'cnm',
//		'password' => get_db_credentials(),
//	);


   $a_client = _cnms($db_params);
   foreach($a_client as $client){
		print "{$client['db1_name']}...";
      $db_params = array(
         'phptype'  => 'mysql',
			'username' => $client['db1_user'],
			'password' => $client['db1_pwd'],
         'hostspec' => $client['db1_server'],
			'database' => $client['db1_name'],
			'cid'      => $client['cid'],
		);
	   $a_table=explode(" ",$tables);
		_dropTable($a_table,$db_params);
		print "[OK]\n";
   }
	exit;
}

function help(){
   echo 
"php db-manage.php [-u|-p|-h|-a|-c|-d|-x|-n]
action:
   sin action        => Actualización de la BBDD y actualización del charset de las tablas a latin1
	-u [nombre_tabla] => Actualiza unicamente el contenido de la tabla nombre_tabla a partir de los datos estandar
	-p [dir]          => Actualiza la BBDD con el contenido del plugin que esta en el directorio [dir]
-----------------------------------------------------------------------------------------------------------------
	-h                => Muestra esta ayuda
	-a                => Actualiza el charset de todas las tablas a latin1
	-c [dir]          => Borra de la BBDD el contenido del plugin que esta en el directorio [dir]
	-d [tablas]       => Borra de la BBDD las tablas [tablas] creadas por plugins
	-x [fichero_xml]  => Instala las métricas definidas en el fichero_xml 
	-n [nivel]        => Borra de la BBDD las entradas de plugin_base cuyo nivel sea el indicado
	-t                => Regenrera la tabla TIPS
	-f                => Machaca las tablas cfg_remote_alert (por defecto en estas tablas sólo se insertan valores nuevos y los antiguos se dejan como estan)
";
}
/*
//////////
// INFO //
//////////
   db/DB-Scheme-Create.php   	  // MODULO QUE CONTIENE LA ESTRUCTURA DE LA BBDD ONM => $DBScheme
   db/DB-Scheme-Create-cnm.php  // MODULO QUE CONTIENE LA ESTRUCTURA DE LA BBDD CNM => $DBSchemeCNM
   db/DB-Scheme-Init.php        // MODULO QUE CONTIENE LOS DATOS QUE DEBEN EXISTIR EN LA BBDD CNM y ONM => $DBData, $DBDataCNM y $DBModData
   db/DB-Procedure-Init.php     // MODULO QUE CONTIENE LOS PROCEDIMIENTOS de la BBDD ONM => $DBProcedure
   db/DB-Procedure-Init-cnm.php // MODULO QUE CONTIENE LOS PROCEDIMIENTOS de la BBDD CNM => $DBProcedureCNN
*/
?>
