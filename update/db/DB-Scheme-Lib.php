<?php
/*
DESCRIPCION: Modulo que contiene las funciones necesarias para poder aplicar las plantillas
definidas en el fichero DB-Scheme-Create.php a la BBDD de CNM
*/

// CLASE NECESARIA PARA MANEJAR LA COMUNICACION CON LA BBDD
require_once('/usr/share/pear/DB.php');
// CLASE CON LA FUNCIÓN DE DEPURACIÓN
require_once('/update/db/CNMUtils.php');



// --------------------------------------------------------------------------------
// Funcion: update_db ()
// Input: $DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure,$db_params
//        - $force: true=>Debe machacar los datos de las tablas (cfg_remote_alerts) | false=>Sólo inserta datos nuevos en las tablas (cfg_remote_alerts)
// Output:
// Funcion que aglutina todas las tareas de actualizacion de la base de datos.
// --------------------------------------------------------------------------------
function update_db($DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure,$db_params,$rev,$force=false){
   $last=time();
   connectDB($db_params);
   $tiempo=time()-$last;
   _debug("Funcion:connectDB||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');

	if($db_params['database']=='cnm'){

	   $last=time();
	   SchemeInit($DBScheme,$DBExcepcion);
	   $tiempo=time()-$last;
	   _debug("Funcion:SchemeInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');
	
	   $last=time();
	   DataInit($DBData,$force);
	   $tiempo=time()-$last;
	   _debug("Funcion:DataInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');

      $last=time();
      DataModInit($DBModData);
      $tiempo=time()-$last;
      _debug("Funcion:DataModInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');


	}else{

		// print "BBDD:{$db_params['database']}\n";
	   $last=time();
	   SchemeInit($DBScheme,$DBExcepcion);
	   $tiempo=time()-$last;
	   _debug("Funcion:SchemeInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');
	
//		$last=time();
//      pre_cfg_monitor_agent_script($DBData);
//      $tiempo=time()-$last;
//     _debug("Funcion:pre_cfg_monitor_agent_script||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');

      $last=time();
      pre_data($DBData);
      $tiempo=time()-$last;
      _debug("Funcion:pre_data||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');
		
	   $last=time();
	   DataInit($DBData);
	   $tiempo=time()-$last;
	   _debug("Funcion:DataInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');
	
		// _limpiar_tips();
	
	   $last=time();
	   DataModInit($DBModData);
	   $tiempo=time()-$last;
	   _debug("Funcion:DataModInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');
	
		$last=time();
      DataInit($DBData);
      $tiempo=time()-$last;
      _debug("Funcion:DataInitEsp||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');

	   $last=time();
	   _cfg_devices2organizational_profile_init($db_params['cid']);
	   $tiempo=time()-$last;
	   _debug("Funcion:_cfg_devices2organizational_profile_init||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');
	
	   $last=time();
	   _cfg_organizational_profile_init();
	   $tiempo=time()-$last;
	   _debug("Funcion:_cfg_organizational_profile_init||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');
	
	   $last=time();
	   ProcedureInit($DBProcedure);
	   $tiempo=time()-$last;
   	_debug("Funcion:ProcedureInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');

		$last=time();
      cfg_monitor_agent_script_update();
      $tiempo=time()-$last;
      _debug("Funcion:cfg_monitor_agent_script_update||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');

		$last=time();
      cfg_remote_alerts_update();
      $tiempo=time()-$last;
      _debug("Funcion:cfg_remote_alerts_update||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');

		$last=time();
		store_rev($rev);
      $tiempo=time()-$last;
      _debug("Funcion:store_rev||rev=$rev {$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');

      $last=time();
      tips_update();
      $tiempo=time()-$last;
      _debug("Funcion:tips_update||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db');
	}
}


// --------------------------------------------------------------------------------
// Funcion: update_db_plugin ()
// Input: $DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure,$db_params
//        - $force: true=>Debe machacar los datos de las tablas (cfg_remote_alerts) | false=>Sólo inserta datos nuevos en las tablas (cfg_remote_alerts)
// Output:
// Funcion que aglutina todas las tareas de actualizacion de la base de datos al instalar un plugin
// --------------------------------------------------------------------------------
function update_db_plugin($DBScheme,$DBExcepcion,$DBData,$DBModData,$DBProcedure,$db_params,$force,$plug_dir){

   $last=time();
   connectDB($db_params);
   $tiempo=time()-$last;
   _debug("Funcion:connectDB||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db_plugin');

   $last=time();
   SchemeInit($DBScheme,$DBExcepcion);
   $tiempo=time()-$last;
   _debug("Funcion:SchemeInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db_plugin');


   $last=time();
	if(is_dir($plug_dir."/xagent/base")) {
		cfg_monitor_agent_script_update($plug_dir);
   	$tiempo=time()-$last;
   	_debug("Funcion:cfg_monitor_agent_script_update||$plug_dir||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db_plugin');
	}

	
   $last=time();
   DataInit($DBData,$force);
   $tiempo=time()-$last;
   _debug("Funcion:DataInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db_plugin');

   $last=time();
   DataModInit($DBModData);
   $tiempo=time()-$last;
   _debug("Funcion:DataModInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db_plugin');

   $last=time();
   ProcedureInit($DBProcedure);
   $tiempo=time()-$last;
  	_debug("Funcion:ProcedureInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db_plugin');

   $last=time();
   tips_update(1);
   $tiempo=time()-$last;
   _debug("Funcion:tips_update||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_db_plugin');
}



/*
 *	Funcion: update_table()
 *	Input:
 *       $tableScheme    => Definición de la estructura de las tablas
 *       $tableData      => Nombre de la tabla a inicializar
 *       $db_params      => Parámetros para la conexión a la BBDD que contiene la tabla a inicializar
 *	Output:
 *	Descr: Función que inicializa (no modifica su estructura) los valores de una tabla
*/
function update_table($tableScheme,$tableData,$db_params){
   $last=time();
   connectDB($db_params);
   $tiempo=time()-$last;
   _debug("Funcion:connectDB||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_table');

   $last=time();
   SchemeInit($tableScheme,$tableExcepcion);
   $tiempo=time()-$last;
   _debug("Funcion:SchemeInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_table');

   $last=time();
   DataInit($tableData);
   $tiempo=time()-$last;
   _debug("Funcion:DataInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','update_table');
}

/* Function: delete_from_table()
 * Input: 
 * 		$tableName => Nombre de la tabla en la que se van a borrar datos
 * 		$tableData => Datos que deben borrarse de la tabla
 *       $db_params => Parámetros para la conexión a la BBDD que contiene la tabla a inicializar
 * Output:
 * Descr: Elimina de las tablas indicadas por las claves de $tableData las entradas que hay en los valores de dichas claves
*/
function delete_from_table($tableName,$tableData,$db_params){
global $enlace;

   $last=time();
   connectDB($db_params);
   $tiempo=time()-$last;
   _debug("Funcion:connectDB||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','delete_from_table');

	foreach($tableData as $tableEntryToDelete){
		$sqlDel = "DELETE FROM $tableName WHERE";
		$AND = '';
		foreach($tableEntryToDelete as $fieldName => $fieldValue){
			$sqlDel.=" $AND $fieldName='$fieldValue'";
			$AND = 'AND';
		}
      $resultQueryDel=$enlace->query($sqlDel);
      if (@PEAR::isError($resultQueryDel)) {
         // _debug("No se ha podido borrar la entrada en la tabla $tableName.||QUERY=>$sqlDel",__LINE__,'ERR','delete_from_table');
      }
      else{
         _debug("Se ha borrado la entrada en la tabla $tableName.",__LINE__,'DBG','delete_from_table');
      }
	}
}

/* Function: clear_plugin_base()
 * Input: 
 *       $plugin_id => plugin_id del plugin a eliminar
 *       $db_params => Parámetros para la conexión a la BBDD que contiene la tabla plugin_base
 * Output:
 * Descr: Elimina de la tabla plugin_base todas las entradas con el plugin_id indicado
 *        Se utiliza al desinstalar un plugin para que elimine todas las características del mismo.
*/
function clear_plugin_base($plugin_id,$db_params){
	global $enlace;

	// if($plugin_id=='' or $plugin_id=='-1'){
	if($plugin_id==''){
		 _debug("Funcion:clear_plugin_base||{$db_params['database']}||No se puede eliminar de plugin_base el plugin_id=$plugin_id",__LINE__,'ERR','clear_plugin_base');
		return;
	}

   $last=time();
   connectDB($db_params);
   $tiempo=time()-$last;
   _debug("Funcion:connectDB||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','clear_plugin_base');

   $query = "DELETE FROM plugin_base WHERE plugin_id='$plugin_id'";
   $result=$enlace->query($query);
}

function create_update_table($tableScheme,$tableData,$db_params,$tableExcepcion){
   $last=time();
   connectDB($db_params);
   $tiempo=time()-$last;
   _debug("Funcion:connectDB||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','create_update_table');

	if(isset($tableScheme)){
	   $last=time();
	   SchemeInit($tableScheme,$tableExcepcion);
	   $tiempo=time()-$last;
	   _debug("Funcion:SchemeInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','create_update_table');
	}

	if(isset($tableData)){
	   $last=time();
	   DataInit($tableData);
	   $tiempo=time()-$last;
	   _debug("Funcion:DataInit||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','create_update_table');
	}
}

/*
 * Funcion: _debug()
 * Input: 
 *		   $msg   => mensaje que deseamos almacenar
 *       $linea => linea del fichero en la que aparece el mensaje
 *       $sev   => severidad del mensaje (DBG|INF|ERR)
 *       $func  => función en la que se ha generado el mensaje
 * Output:
 * Descr: Funcion encargada de escribir en la ruta /tmp/db-debug el resultado de aplicar la plantilla a la BBDD
*/
function _debug($msg,$linea,$sev,$func){
	$pid=getmypid();
	if ($sev=='DBG'){
		CNMUtils::debug_log(__FILE__, $linea, "$func [$pid]::$msg");
	}else{
		if($sev=='ERR') print "Fichero:".__FILE__." linea :$linea - $func [$pid]::$msg\n";
		CNMUtils::info_log(__FILE__, $linea, "$func [$pid]::$msg"); 
	}
}

/*
 * Funcion: connectDB()
 * Input:
 *        $db_params => Parámetros para la conexión a la BBDD
 * Output: 
 *        1 En caso de haber problemas
 *			 0 En caso de funcionar correctamente
 * Descr: Funcion encargada de realizar la conexion con la BBDD e inicializar la variable global $enlace
*/
function connectDB($db_params){
// Variable que contendra la conexion con la BBDD una vez realizada
global $enlace;

   // NOS CONECTAMOS A LA BBDD
   $enlace = @DB::Connect($db_params,TRUE);
	if (@PEAR::isError($enlace)) {
		_debug("Conexion BBDD [NOOK] phptype=>{$db_params['phptype']} username=>{$db_params['username']} password=>{$db_params['password']} hostspec=>{$db_params['hostspec']} database=>{$db_params['database']} || USERINFO = ".$enlace->getUserInfo(),__LINE__,'ERR','connectDB');
		exit;
   }else {
   	// LOS DATOS DEVUELTOS POR LAS CONSULTAS A LA BBDD VIENEN EN FORMA DE HASH
	   $enlace->setFetchMode(DB_FETCHMODE_ASSOC);
		if(! array_key_exists('database',$db_params)) $db_params['database']='';
		_debug("Conexion BBDD [OK] phptype=>{$db_params['phptype']} username=>{$db_params['username']} password=>{$db_params['password']} hostspec=>{$db_params['hostspec']} database=>{$db_params['database']}",__LINE__,'DBG','connectDB');

		// SE MANEJAN LOS DATOS CON CODIFICACION UTF-8
	   $query  = "SET CHARACTER SET 'utf8'";
	   $result = $enlace->query($query);
	}
}

// --------------------------------------------------------------------------------
// Funcion: DataInit($DBData)
// Input: Hash que tiene como clave el nombre de las tablas y como valor un array 
// de elementos a insertar en dicha tabla
// Output:
// Funcion encargada de inicializar valores en las tablas de la BBDD
// --------------------------------------------------------------------------------
function DataInit($DBData,$force=false){
global $enlace;

	$sqlTablas="SHOW TABLES";
	$resultTablas=$enlace->query($sqlTablas);
   if (@PEAR::isError($resultTablas)) {
      _debug("No se ha podido obtener la informacion de las tablas de la BBDD || USERINFO = ".$resultTablas->getUserInfo(),__LINE__,'ERR','DataInit');
		exit;
   }else{
      _debug("Se ha obtenido la informacion de las tablas de la BBDD",__LINE__,'DBG','DataInit');
   }

   $tablasBBDD=array();
   while($resultTablas->fetchInto($rTablas)){
      foreach($rTablas as $key=>$value) $tablasBBDD[]=$value;
      // $tablasBBDD[]=$rTablas['Tables_in_onm'];
   }
   //while($resultTablas->fetchInto($rTablas)){$tablasBBDD[]=$rTablas['Tables_in_onm']; }

	foreach ($DBData as $nombreTabla => $valores){
		// CASO EN EL QUE LA TABLA NO EXISTE
		if (!in_array($nombreTabla,$tablasBBDD)){
      	_debug("La tabla $nombreTabla no existe en la BBDD",__LINE__,'ERR','DataInit');
		// CASO EN EL QUE LA TABLA EXISTE
		}else{
			_DataInitTable($nombreTabla,$valores,$force);
		}
	}
}

function ProcedureInit($DBProcedure){
global $enlace;
	
	if(!is_array($DBProcedure))return;
	foreach ($DBProcedure as $id => $queryCreate){
		// Se borra el procedimiento
		$queryDrop = "DROP PROCEDURE IF EXISTS $id";
		$resultQueryDrop=$enlace->query($queryDrop);
      if (@PEAR::isError($resultQueryDrop)) {
			_debug("No se ha podido borrar el procedimiento $id||CMD=>$queryDrop || USERINFO = ".$resultQueryDrop->getUserInfo(),__LINE__,'ERR','ProcedureInit');
		}
		else{
			_debug("Se ha borrado el procedimiento $id",__LINE__,'DBG','ProcedureInit');
			// Se crea el procedimiento	
			$resultQueryCreate=$enlace->query($queryCreate);
      	if (@PEAR::isError($resultQueryCreate)){
				_debug("No se ha podido crear el procedimiento $id||CMD=>$queryCreate || USERINFO = ".$resultQueryCreate->getUserInfo(),__LINE__,'ERR','ProcedureInit');
			}
			else{
				_debug("Se ha creado el procedimiento $id",__LINE__,'DBG','ProcedureInit');
			}
		}
	}

	// Invocamos los procedimientos que nos interesen
	// $queryProcedure = "CALL $procedure('','')";
	$procedure = 'sp_alerts_read';
	$local_ip = chop(`/sbin/ifconfig eth0|grep 'inet addr'|cut -d ":" -f2|cut -d " " -f1`);
	
	$queryProcedure = "CALL $procedure('default','$local_ip')";
	$resultQueryProcedure=$enlace->query($queryProcedure);
	if (@PEAR::isError($resultQueryProcedure)) {
        _debug("No se ha podido ejecutar el procedimiento $procedure||CMD=>$queryProcedure || USERINFO = ".$resultQueryProcedure->getUserInfo(),__LINE__,'ERR','ProcedureInit');
     }else{
		_debug("Se ha ejecutado el procedimiento $procedure",__LINE__,'DBG','ProcedureInit');
	}
}


//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
function cfg_monitor_agent_script_update($plugin = ''){
global $enlace;

	//-----
	// Hay que especificr un plugin. Los scripts originales de /opt/data/xagent/base se han movido 
	// a /opt/cnm-sp/t/xagent/base 
	// El directorio /opt/data/xagent desaparece
	
	if ($plugin == '') { return; }
	$dirBase="$plugin/xagent/base";

	$all_scripts = array();	
   $cmd="find $dirBase/* -type f";
  	$script_path = Array();
   $fp = popen($cmd, "r");
  	while( !feof( $fp )){
		///opt/cnm-sp/wmi-disk/xagent/base/linux_metric_wmi_disk.pl
      $filepath1 = fgets( $fp );
  	   $filepath = rtrim($filepath1);
		if (!file_exists($filepath)){ continue; }
     	$parts = pathinfo($filepath);
     	$script_path[$parts['basename']] = $filepath;
		array_push($all_scripts,$parts['basename']);

		_debug("Script incluido: $filepath",__LINE__,'DBG','cfg_monitor_agent_script_update');
  	}
	//-----

	
	// Los scripts a provisionar estan en $plugin/xagent/base 
	foreach ($all_scripts as $file) {

		// Solo se procesan los scripts del plugin en curso
		if (!array_key_exists($file,$script_path)) { continue; }

		$fileFullPath = "$dirBase/$file";

		_debug("clear_script:: $file",__LINE__,'DBG','cfg_monitor_agent_script_update');
		clear_script($r['script']);

      $fsize = filesize($fileFullPath);
      $fdate = filemtime($fileFullPath);

		_debug("update_script:: $fileFullPath | size=$fsize | date=$fdate",__LINE__,'DBG','cfg_monitor_agent_script_update');

      $fdata = mysql_real_escape_string(file_get_contents($fileFullPath));
      $queryInsert="INSERT INTO cfg_monitor_agent_script (script,size,date,script_data,custom) VALUES ('$file',$fsize,$fdate,'$fdata',0) ON DUPLICATE KEY UPDATE size=$fsize,date=$fdate,script_data='$fdata'";
		$resultInsert=$enlace->query($queryInsert);
      if (@PEAR::isError($resultInsert)) {
         _debug("No se ha podido insertar los datos del script $file ||CMD=>$queryInsert || USERINFO = ".$resultInsert->getUserInfo(),__LINE__,'ERR','cfg_monitor_agent_script_update');
      }else{
         _debug("Se ha almacenado/modificado correctamente el script $file",__LINE__,'DBG','cfg_monitor_agent_script_update');
      }
   }

	// Actualizar el campo signature
	$query_1 = "SELECT id_cfg_monitor_agent_script,script_data,script FROM cfg_monitor_agent_script";
	$result_1=$enlace->query($query_1);
	while($result_1->fetchInto($r_1)){
		$id_cfg_monitor_agent_script = $r_1['id_cfg_monitor_agent_script'];
		$script_data                 = $r_1['script_data'];
		$script                      = $r_1['script'];
		$signature                   = sha1($script_data);
		$query_2 = "UPDATE cfg_monitor_agent_script SET signature='$signature' WHERE id_cfg_monitor_agent_script=$id_cfg_monitor_agent_script";
		$result_2=$enlace->query($query_2);
		if (@PEAR::isError($result_2)) {
         _debug("No se ha podido actualizar el campo signature del script $script||CMD=>$query_2 || USERINFO = ".$result_2->getUserInfo(),__LINE__,'ERR','cfg_monitor_agent_script_update');
      }else{
         _debug("Se ha actualizado el campo signature del script $script",__LINE__,'DBG','cfg_monitor_agent_script_update');
      }
	}
	exec('rm -f /opt/data/mdata/scripts/*',$rcstr,$rc);
}

//------------------------------------------------------------------------------------
function cfg_remote_alerts_update(){
global $enlace;

	$query_1 = "CREATE temporary table t1(SELECT a.id_remote_alert,b.id_remote_alert AS id FROM cfg_remote_alerts a LEFT JOIN cfg_remote_alerts b ON a.set_type=b.type AND a.set_subtype=b.subtype AND a.set_hiid=b.hiid WHERE a.action='CLR' AND b.id_remote_alert IS NOT NULL)";
   $result_1 = $enlace->query($query_1);
	// $query_2 = "UPDATE cfg_remote_alerts a,t1 b SET a.set_id=b.id, a.vdata=CONCAT('id=',b.id) WHERE a.id_remote_alert=b.id_remote_alert";
	$query_2 = "UPDATE cfg_remote_alerts a,t1 b SET a.set_id=b.id WHERE a.id_remote_alert=b.id_remote_alert";
	$result_2 = $enlace->query($query_2);
	$query_3 = "DROP TEMPORARY TABLE t1";
	$result_3 = $enlace->query($query_3);
/*
	// También se puede hacer así
   $query_1  = "SELECT id_remote_alert,set_type,set_subtype,set_hiid FROM cfg_remote_alerts WHERE action='CLR'";
   $result_1 = $enlace->query($query_1);
   while($result_1->fetchInto($r_1)){
		$query_2 = "SELECT id_remote_alert FROM cfg_remote_alerts WHERE type='{$r_1['set_type']}' AND subtype='{$r_1['set_subtype']}' AND hiid='{$r_1['set_hiid']}'";
		$result_2 = $enlace->query($query_2);
		while($result_2->fetchInto($r_2)){
			$query_3 = "UPDATE cfg_remote_alerts SET set_id='{$r_2['id_remote_alert']}' WHERE id_remote_alert='{$r_1['id_remote_alert']}'";
			$result_3 = $enlace->query($query_3);
		}
	}
*/
}

/* Function: tips_update()
*  Input: 
*		$mode = 0: Actualiza todas las entradas de tips
*		$mode = 1: Actualiza solo las entradas con id_refn=0 de tips
*  Output:
*  Descr: Función que rellena el campo id_refn en la tabla tips
*/
function tips_update($mode=0){
global $enlace;

	// Alertas remotas
   $query_0 = "DROP TEMPORARY TABLE t1";
   $result_0 = $enlace->query($query_0);
   // $query_1 = "CREATE temporary table t1(SELECT id_remote_alert,subtype FROM cfg_remote_alerts)";
   $query_1 = "CREATE temporary table t1(SELECT id_remote_alert,subtype,hiid FROM cfg_remote_alerts)";
   $result_1 = $enlace->query($query_1);
	if($mode=0){
	   // $query_2 = "UPDATE tips a,t1 b SET a.id_refn=b.id_remote_alert WHERE a.id_ref=b.subtype AND a.tip_type='remote'";
	   $query_2 = "UPDATE tips a,t1 b SET a.id_refn=b.id_remote_alert WHERE a.id_ref=b.subtype AND a.hiid=b.hiid AND a.tip_type='remote'";
   	$result_2 = $enlace->query($query_2);
	}
	else{
		// PASO 1: Comprobar si hay entradas en tips a actualizar
		$cont = 0;
		$query_aux = "SELECT COUNT(a.id_tip) AS cuantos from tips a, cfg_remote_alerts b where a.id_ref=b.subtype AND a.hiid=b.hiid AND a.tip_type='remote' AND a.id_refn=0";
		$result_aux = $enlace->query($query_aux);
   	while($result_aux->fetchInto($r)){
			$cont = $r['cuantos'];
   	}

		// Si hay entradas en tips a actualizar...
		if($cont!=0){
		   // $query_2 = "UPDATE tips a,t1 b SET a.id_refn=b.id_remote_alert WHERE a.id_ref=b.subtype AND a.tip_type='remote' AND a.id_refn=0";
		   $query_2 = "UPDATE tips a,t1 b SET a.id_refn=b.id_remote_alert WHERE a.id_ref=b.subtype AND a.hiid=b.hiid AND a.tip_type='remote' AND a.id_refn=0";
	   	$result_2 = $enlace->query($query_2);
		}
	}
	$query_3 = "DROP TEMPORARY TABLE t1";
	$result_3 = $enlace->query($query_3);
}

/* Function: tips_update_aux()
*  Input: 
*  Output:
*  Descr: Función que rellena el campo id_refn en la tabla tips
*/
function tips_update_aux($db_params){
global $enlace;

   $last=time();
   connectDB($db_params);
   $tiempo=time()-$last;
   _debug("Funcion:connectDB||{$db_params['database']}||Tiempo:$tiempo",__LINE__,'INF','tips_update_aux');

   // Alertas remotas
   $query_0 = "DROP TEMPORARY TABLE t1";
   $result_0 = $enlace->query($query_0);
   // $query_1 = "CREATE temporary table t1(SELECT id_remote_alert,subtype FROM cfg_remote_alerts)";
   $query_1 = "CREATE temporary table t1(SELECT id_remote_alert,subtype,hiid FROM cfg_remote_alerts)";
   $result_1 = $enlace->query($query_1);
   // $query_2 = "UPDATE tips a,t1 b SET a.id_refn=b.id_remote_alert WHERE a.id_ref=b.subtype AND a.tip_type='remote'";
   $query_2 = "UPDATE tips a,t1 b SET a.id_refn=b.id_remote_alert WHERE a.id_ref=b.subtype AND a.hiid=b.hiid AND a.tip_type='remote'";
   $result_2 = $enlace->query($query_2);
   $query_3 = "DROP TEMPORARY TABLE t1";
   $result_3 = $enlace->query($query_3);
}

/* Function: pre_cfg_monitor_agent_script()
*  Input: $DBData => Estructura con todos los datos de cada tabla
*  Output:
*  Descr: Función que hace el postprocesado de los datos relacionados con la tabla cfg_monitor_agent_script.
*         Ahora mismo hace:
* 				- Borrar scripts de sistema que no aparezcan en el fichero de configuracion
*         	- Borrar parámetros de la base de datos de scripts de sistema cuyos parámetros no aparezcan en el fichero de configuración.
*/

// ************** FUNCION OBSOLETA **************************
function pre_cfg_monitor_agent_script($DBData){
global $enlace;



/*
mysql> select count(*) as cuantos from cfg_monitor_agent_script;
+---------+
| cuantos |
+---------+
|      26 |
+---------+
1 row in set (0.00 sec)

*/
/*
mysql> select script,cfg,custom from cfg_monitor_agent_script;
+---------------------------------------------+-----+--------+
| script                                      | cfg | custom |
+---------------------------------------------+-----+--------+
| ws_set_device                               |   1 |      0 |
| ws_get_csv_devices                          |   1 |      0 |
| ws_get_csv_metrics                          |   1 |      0 |
| ws_get_csv_views                            |   1 |      0 |
| audit                                       |   1 |      0 |
| generate_report.php                         |   1 |      0 |
| cnm_backup.php                              |   1 |      0 |
| mib2_if                                     |   1 |      0 |
| mibhost_disk                                |   1 |      0 |
| get_cdp                                     |   1 |      0 |
| cisco_ccm_device_pools                      |   1 |      0 |
| snmptable                                   |   1 |      0 |
| cnm-ping                                    |   1 |      0 |
| cnm-traceroute                              |   1 |      0 |
| cnm-nmap                                    |   1 |      0 |
| mon_tcp                                     |   1 |      0 |
| cnm-sslcerts                                |   1 |      0 |
| linux_metric_certificate_expiration_time.pl |   0 |      0 |
| linux_metric_mysql_var.pl                   |   0 |      0 |
| linux_metric_mail_loop.pl                   |   0 |      0 |
| linux_metric_ssh_files_per_proccess.pl      |   0 |      0 |
| linux_metric_ssh_files_in_dir.pl            |   0 |      0 |
| linux_metric_route_tag.pl                   |   0 |      0 |
| win32_metric_wmi_core.vbs                   |   0 |      0 |
| mon_smtp_ext                                |   1 |      0 |
| snmp_metric_count_proc_multiple_devices     |   0 |      0 |
+---------------------------------------------+-----+--------+
26 rows in set (0.00 sec)
*/

/*
mysql> select * from cfg_script_param;
+---------------------+----------+---------------------------------------------+----------+-----------+----------------------------+-------+------------+
| id_cfg_script_param | hparam   | script                                      | position | prefix    | descr                      | value | param_type |
+---------------------+----------+---------------------------------------------+----------+-----------+----------------------------+-------+------------+
|                   1 | 10000000 | ws_set_device                               |        0 | -p        | Campos                     |       |          0 |
|                   2 | 10000001 | ws_set_device                               |        1 | -a        | IP                         |       |          2 |
|                   3 | 10000002 | audit                                       |        0 | -a        | Rango                      |       |          0 |
|                   4 | 10000003 | generate_report.php                         |        0 | -e        | Fecha fin (timestamp)      |       |          0 |
|                   5 | 10000004 | generate_report.php                         |        1 | -s        | Fecha inicio (timestamp)   |       |          0 |
|                   6 | 10000005 | generate_report.php                         |        2 | -n        | Nombre del informe         |       |          0 |
|                   7 | 10000006 | generate_report.php                         |        3 | -i        | Identificador              |       |          0 |
|                   8 | 10000007 | generate_report.php                         |        4 | -h        | Ayuda                      |       |          0 |
|                   9 | 20000000 | mib2_if                                     |        0 | -n        | IP                         |       |          2 |
|                  10 | 20000001 | mib2_if                                     |        1 | -w        | Formato de salida          | json  |          0 |
|                  11 | 20000002 | mibhost_disk                                |        0 | -n        | IP                         |       |          2 |
|                  12 | 20000003 | mibhost_disk                                |        1 | -w        | Formato de salida          | json  |          0 |
|                  13 | 20000004 | get_cdp                                     |        0 | -n        | IP                         |       |          2 |
|                  14 | 20000005 | get_cdp                                     |        1 | -w        | Formato de salida          | json  |          0 |
|                  15 | 20000006 | cisco_ccm_device_pools                      |        0 | -n        | IP                         |       |          2 |
|                  16 | 20000007 | cisco_ccm_device_pools                      |        1 | -w        | Formato de salida          | json  |          0 |
|                  17 | 20000008 | snmptable                                   |        0 | -f        | Descriptor                 |       |          0 |
|                  18 | 20000009 | snmptable                                   |        1 | -w        | Formato de salida          | json  |          0 |
|                  19 | 2000000a | snmptable                                   |        2 | -n        | IP                         |       |          2 |
|                  20 | 30000000 | cnm-ping                                    |        0 | -n        | IP                         |       |          2 |
|                  21 | 30000001 | cnm-ping                                    |        1 | -o        | Opciones del comando       |       |          0 |
|                  22 | 30000003 | cnm-traceroute                              |        0 | -n        | IP                         |       |          2 |
|                  23 | 30000004 | cnm-traceroute                              |        1 | -o        | Opciones del comando       |       |          0 |
|                  24 | 30000006 | cnm-nmap                                    |        0 | -n        | IP                         |       |          2 |
|                  25 | 30000007 | cnm-nmap                                    |        1 | -o        | Opciones del comando       |       |          0 |
|                  26 | 30000009 | mon_tcp                                     |        0 | -n        | IP                         |       |          2 |
|                  27 | 30000010 | cnm-sslcerts                                |        0 | -n        | IP                         |       |          2 |
|                  28 | 30000011 | cnm-sslcerts                                |        1 | -p        | Puerto                     | 443   |          0 |
|                  29 | 00000000 | linux_metric_certificate_expiration_time.pl |        0 |           | IP                         |       |          2 |
|                  30 | 00000001 | linux_metric_certificate_expiration_time.pl |        1 |           | Puerto                     | 443   |          0 |
|                  31 | 00000010 | linux_metric_mail_loop.pl                   |        0 | -mxhost   | Host SMTP                  |       |          0 |
|                  32 | 00000011 | linux_metric_mail_loop.pl                   |        1 | -to       | Destinatario del correo    |       |          0 |
|                  33 | 00000012 | linux_metric_mail_loop.pl                   |        2 | -from     | Origen del correo          |       |          0 |
|                  34 | 00000013 | linux_metric_mail_loop.pl                   |        3 | -pop3host | Host POP3                  |       |          0 |
|                  35 | 00000014 | linux_metric_mail_loop.pl                   |        4 | -user     | Usuario POP3               |       |          1 |
|                  36 | 00000015 | linux_metric_mail_loop.pl                   |        5 | -pwd      | Clave POP3                 |       |          1 |
|                  37 | 00000016 | linux_metric_mail_loop.pl                   |        6 | -n        | Numero de correos a enviar | 3     |          0 |
|                  38 | 00000020 | linux_metric_mysql_var.pl                   |        0 | -host     | Host con MySQL             |       |          2 |
|                  39 | 00000021 | linux_metric_mysql_var.pl                   |        1 | -user     | Usuario de acceso          |       |          1 |
|                  40 | 00000022 | linux_metric_mysql_var.pl                   |        2 | -pwd      | Clave del usuario          |       |          1 |
|                  41 | 00000030 | linux_metric_ssh_files_in_dir.pl            |        0 | -n        | Host                       |       |          2 |
|                  42 | 00000031 | linux_metric_ssh_files_in_dir.pl            |        1 | -u        | User                       |       |          1 |
|                  43 | 00000032 | linux_metric_ssh_files_in_dir.pl            |        2 | -p        | Password                   |       |          1 |
|                  44 | 00000033 | linux_metric_ssh_files_in_dir.pl            |        3 | -d        | Directorio                 |       |          0 |
|                  45 | 00000034 | linux_metric_ssh_files_in_dir.pl            |        4 | -a        | Patron                     |       |          0 |
|                  46 | 00000040 | linux_metric_ssh_files_per_proccess.pl      |        0 | -n        | Host                       |       |          2 |
|                  47 | 00000041 | linux_metric_ssh_files_per_proccess.pl      |        1 | -u        | User                       |       |          1 |
|                  48 | 00000042 | linux_metric_ssh_files_per_proccess.pl      |        2 | -p        | Password                   |       |          1 |
|                  49 | 00000043 | linux_metric_ssh_files_per_proccess.pl      |        3 | -a        | Proceso                    |       |          0 |
|                  50 | 00000050 | linux_metric_route_tag.pl                   |        0 | -host     | Host                       |       |          2 |
|                  51 | 30000012 | mon_smtp_ext                                |        0 | -n        | IP                         |       |          2 |
|                  52 | 30000013 | mon_smtp_ext                                |        1 | -p        | Puerto                     | 25    |          0 |
|                  53 | 3000000a | mon_tcp                                     |        1 | -p        | Puerto                     |       |          0 |
|                  57 | 00000055 | snmp_metric_count_proc_multiple_devices     |        0 | -n        | Host                       |       |          2 |
|                  58 | 00000056 | snmp_metric_count_proc_multiple_devices     |        1 | -r        | Resto de equipos           |       |          0 |
|                  59 | 00000057 | snmp_metric_count_proc_multiple_devices     |        2 | -p        | Proceso                    |       |          0 |
+---------------------+----------+---------------------------------------------+----------+-----------+----------------------------+-------+------------+
56 rows in set (0.00 sec)

mysql>
*/


/*
mysql> select b.* from cfg_monitor_agent_script a, cfg_script_param b WHERE a.script=b.script AND a.custom=0;
+---------------------+----------+---------------------------------------------+----------+-----------+----------------------------+-------+------------+
| id_cfg_script_param | hparam   | script                                      | position | prefix    | descr                      | value | param_type |
+---------------------+----------+---------------------------------------------+----------+-----------+----------------------------+-------+------------+
|                   1 | 10000000 | ws_set_device                               |        0 | -p        | Campos                     |       |          0 |
|                   2 | 10000001 | ws_set_device                               |        1 | -a        | IP                         |       |          2 |
|                   3 | 10000002 | audit                                       |        0 | -a        | Rango                      |       |          0 |
|                   4 | 10000003 | generate_report.php                         |        0 | -e        | Fecha fin (timestamp)      |       |          0 |
|                   5 | 10000004 | generate_report.php                         |        1 | -s        | Fecha inicio (timestamp)   |       |          0 |
|                   6 | 10000005 | generate_report.php                         |        2 | -n        | Nombre del informe         |       |          0 |
|                   7 | 10000006 | generate_report.php                         |        3 | -i        | Identificador              |       |          0 |
|                   8 | 10000007 | generate_report.php                         |        4 | -h        | Ayuda                      |       |          0 |
|                   9 | 20000000 | mib2_if                                     |        0 | -n        | IP                         |       |          2 |
|                  10 | 20000001 | mib2_if                                     |        1 | -w        | Formato de salida          | json  |          0 |
|                  11 | 20000002 | mibhost_disk                                |        0 | -n        | IP                         |       |          2 |
|                  12 | 20000003 | mibhost_disk                                |        1 | -w        | Formato de salida          | json  |          0 |
|                  13 | 20000004 | get_cdp                                     |        0 | -n        | IP                         |       |          2 |
|                  14 | 20000005 | get_cdp                                     |        1 | -w        | Formato de salida          | json  |          0 |
|                  15 | 20000006 | cisco_ccm_device_pools                      |        0 | -n        | IP                         |       |          2 |
|                  16 | 20000007 | cisco_ccm_device_pools                      |        1 | -w        | Formato de salida          | json  |          0 |
|                  17 | 20000008 | snmptable                                   |        0 | -f        | Descriptor                 |       |          0 |
|                  18 | 20000009 | snmptable                                   |        1 | -w        | Formato de salida          | json  |          0 |
|                  19 | 2000000a | snmptable                                   |        2 | -n        | IP                         |       |          2 |
|                  20 | 30000000 | cnm-ping                                    |        0 | -n        | IP                         |       |          2 |
|                  21 | 30000001 | cnm-ping                                    |        1 | -o        | Opciones del comando       |       |          0 |
|                  22 | 30000003 | cnm-traceroute                              |        0 | -n        | IP                         |       |          2 |
|                  23 | 30000004 | cnm-traceroute                              |        1 | -o        | Opciones del comando       |       |          0 |
|                  24 | 30000006 | cnm-nmap                                    |        0 | -n        | IP                         |       |          2 |
|                  25 | 30000007 | cnm-nmap                                    |        1 | -o        | Opciones del comando       |       |          0 |
|                  26 | 30000009 | mon_tcp                                     |        0 | -n        | IP                         |       |          2 |
|                  53 | 3000000a | mon_tcp                                     |        1 | -p        | Puerto                     |       |          0 |
|                  27 | 30000010 | cnm-sslcerts                                |        0 | -n        | IP                         |       |          2 |
|                  28 | 30000011 | cnm-sslcerts                                |        1 | -p        | Puerto                     | 443   |          0 |
|                  29 | 00000000 | linux_metric_certificate_expiration_time.pl |        0 |           | IP                         |       |          2 |
|                  30 | 00000001 | linux_metric_certificate_expiration_time.pl |        1 |           | Puerto                     | 443   |          0 |
|                  38 | 00000020 | linux_metric_mysql_var.pl                   |        0 | -host     | Host con MySQL             |       |          2 |
|                  39 | 00000021 | linux_metric_mysql_var.pl                   |        1 | -user     | Usuario de acceso          |       |          1 |
|                  40 | 00000022 | linux_metric_mysql_var.pl                   |        2 | -pwd      | Clave del usuario          |       |          1 |
|                  31 | 00000010 | linux_metric_mail_loop.pl                   |        0 | -mxhost   | Host SMTP                  |       |          0 |
|                  32 | 00000011 | linux_metric_mail_loop.pl                   |        1 | -to       | Destinatario del correo    |       |          0 |
|                  33 | 00000012 | linux_metric_mail_loop.pl                   |        2 | -from     | Origen del correo          |       |          0 |
|                  34 | 00000013 | linux_metric_mail_loop.pl                   |        3 | -pop3host | Host POP3                  |       |          0 |
|                  35 | 00000014 | linux_metric_mail_loop.pl                   |        4 | -user     | Usuario POP3               |       |          1 |
|                  36 | 00000015 | linux_metric_mail_loop.pl                   |        5 | -pwd      | Clave POP3                 |       |          1 |
|                  37 | 00000016 | linux_metric_mail_loop.pl                   |        6 | -n        | Numero de correos a enviar | 3     |          0 |
|                  46 | 00000040 | linux_metric_ssh_files_per_proccess.pl      |        0 | -n        | Host                       |       |          2 |
|                  47 | 00000041 | linux_metric_ssh_files_per_proccess.pl      |        1 | -u        | User                       |       |          1 |
|                  48 | 00000042 | linux_metric_ssh_files_per_proccess.pl      |        2 | -p        | Password                   |       |          1 |
|                  49 | 00000043 | linux_metric_ssh_files_per_proccess.pl      |        3 | -a        | Proceso                    |       |          0 |
|                  41 | 00000030 | linux_metric_ssh_files_in_dir.pl            |        0 | -n        | Host                       |       |          2 |
|                  42 | 00000031 | linux_metric_ssh_files_in_dir.pl            |        1 | -u        | User                       |       |          1 |
|                  43 | 00000032 | linux_metric_ssh_files_in_dir.pl            |        2 | -p        | Password                   |       |          1 |
|                  44 | 00000033 | linux_metric_ssh_files_in_dir.pl            |        3 | -d        | Directorio                 |       |          0 |
|                  45 | 00000034 | linux_metric_ssh_files_in_dir.pl            |        4 | -a        | Patron                     |       |          0 |
|                  50 | 00000050 | linux_metric_route_tag.pl                   |        0 | -host     | Host                       |       |          2 |
|                  51 | 30000012 | mon_smtp_ext                                |        0 | -n        | IP                         |       |          2 |
|                  52 | 30000013 | mon_smtp_ext                                |        1 | -p        | Puerto                     | 25    |          0 |
|                  57 | 00000055 | snmp_metric_count_proc_multiple_devices     |        0 | -n        | Host                       |       |          2 |
|                  58 | 00000056 | snmp_metric_count_proc_multiple_devices     |        1 | -r        | Resto de equipos           |       |          0 |
|                  59 | 00000057 | snmp_metric_count_proc_multiple_devices     |        2 | -p        | Proceso                    |       |          0 |
+---------------------+----------+---------------------------------------------+----------+-----------+----------------------------+-------+------------+
56 rows in set (0.00 sec)

mysql>
*/

	// Borrar scripts de sistema que no aparezcan en el fichero de configuracion
   $in_bbdd_a = array();
   $query_1_a = "select a.* from cfg_monitor_agent_script a WHERE a.custom=0";
   $result_1_a = $enlace->query($query_1_a);
   while($result_1_a->fetchInto($r_1_a)){
      $in_bbdd_a[$r_1_a['script']] = 1;
   }

   $in_file_a = array();
	if (array_key_exists('cfg_monitor_agent_script', $DBData)) {
   	foreach($DBData['cfg_monitor_agent_script'] as $a_a){
      	$in_file_a[$a_a['script']] = 1;
   	}
	}

   foreach($in_bbdd_a as $script => $kk){
      if (!array_key_exists($script, $in_file_a)) {
         $query_2_a = "DELETE FROM cfg_monitor_agent_script WHERE script='$script'";

			//print "QUERY_2_A == $query_2_a\n";
         $result_2_a = $enlace->query($query_2_a);
			$query_3_a = "SELECT hparam FROM cfg_script_param WHERE script='$script'";
			//print "QUERY_3_A == $query_3_a\n";
			$result_3_a = $enlace->query($query_3_a);
			while($result_3_a->fetchInto($r_3_a)){
				$hparam = $r_3_a['hparam'];
		      $query_4_a = "DELETE FROM cfg_script_param WHERE hparam='$hparam'";
				//print "QUERY_4_A == $query_4_a\n";
		      $result_4_a = $enlace->query($query_4_a);
		      $query_5_a = "DELETE FROM cfg_monitor_param WHERE hparam='$hparam'";
				//print "QUERY_5_A == $query_5_a\n";
		      $result_5_a = $enlace->query($query_5_a);
		      $query_6_a = "DELETE FROM cfg_app_param WHERE hparam='$hparam'";
				//print "QUERY_6_A == $query_6_a\n";
		      $result_6_a = $enlace->query($query_6_a);
		   }

         $query_7_a = "DELETE FROM cfg_script_param WHERE script='$script'";
         //print "QUERY_7_A == $query_7_a\n";
         $result_7_a = $enlace->query($query_7_a);
      }
   }



   // Borrar parámetros de la base de datos de scripts de sistema cuyos parámetros no aparezcan en el fichero de configuración.
	$in_bbdd_b = array();
   $query_1_b = "select b.* from cfg_monitor_agent_script a, cfg_script_param b WHERE a.script=b.script AND a.custom=0";
   $result_1_b = $enlace->query($query_1_b);
   while($result_1_b->fetchInto($r_1_b)){
		$in_bbdd_b[$r_1_b['hparam']] = array(
			'id_cfg_script_param' => $r_1_b['id_cfg_script_param'],
			'hparam'              => $r_1_b['hparam'],
			'script'              => $r_1_b['script'],
			'position'            => $r_1_b['position'],
			'prefix'              => $r_1_b['prefix'],
			'descr'               => $r_1_b['descr'],
			'value'               => $r_1_b['value'],
			'param_type'          => $r_1_b['param_type'],
		);
   }
//print_r($in_bbdd_b);
//print "\n--------AAA---------------------\n";

	$in_file_b = array();
	if (array_key_exists('cfg_script_param', $DBData)) {
		foreach($DBData['cfg_script_param'] as $a_b){
			// SSV:2012-06-21
			$in_file_b[$a_b['hparam']] = 1;
			/*
			$in_file_b[$a_b['hparam']] = array(
				'id_cfg_script_param' => $a_b['id_cfg_script_param'],
         	'hparam'              => $a_b['hparam'],
         	'script'              => $a_b['script'],
	         'position'            => $a_b['position'],
   	      'prefix'              => $a_b['prefix'],
      	   'descr'               => $a_b['descr'],
         	'value'               => $a_b['value'],
         	'param_type'          => $a_b['param_type'],
			);
			*/
		}
	}

	foreach($in_bbdd_b as $hparam => $param_data){
		if (!array_key_exists($hparam, $in_file_b)) {
			$query_2_b = "DELETE FROM cfg_script_param WHERE hparam='$hparam'";
			$result_2_b = $enlace->query($query_2_b);
			$query_3_b = "DELETE FROM cfg_monitor_param WHERE hparam='$hparam'";
			$result_3_b = $enlace->query($query_3_b);
			$query_4_b = "DELETE FROM cfg_app_param WHERE hparam='$hparam'";
			$result_4_b = $enlace->query($query_4_b);
			//print "QUERY_2_B == $query_2_b\nQUERY_3_B == $query_3_b\nQUERY_4_B == $query_4_b";
		}
	}
}


/* Function: clear_script()
 *  Input:
 *         $script => Nombre del script a eliminar
 *  Output:
 *  Descr: Elimina un script de todas las tablas de la BBDD
*/
function clear_script($script){
global $enlace;

    $query_2_a = "DELETE FROM cfg_monitor_agent_script WHERE script='$script'";

   //print "QUERY_2_A == $query_2_a\n";
   $result_2_a = $enlace->query($query_2_a);
   $query_3_a = "SELECT hparam FROM cfg_script_param WHERE script='$script'";
   //print "QUERY_3_A == $query_3_a\n";
   $result_3_a = $enlace->query($query_3_a);
   while($result_3_a->fetchInto($r_3_a)){
      $hparam = $r_3_a['hparam'];

      $query_4_a = "DELETE FROM cfg_script_param WHERE hparam='$hparam'";
      //print "QUERY_4_A == $query_4_a\n";
      $result_4_a = $enlace->query($query_4_a);

      $query_5_a = "DELETE FROM cfg_monitor_param WHERE hparam='$hparam'";
      //print "QUERY_5_A == $query_5_a\n";
      $result_5_a = $enlace->query($query_5_a);

      $query_6_a = "DELETE FROM cfg_app_param WHERE hparam='$hparam'";
      //print "QUERY_6_A == $query_6_a\n";
      $result_6_a = $enlace->query($query_6_a);
   }

   $query_7_a = "DELETE FROM cfg_script_param WHERE script='$script'";
   //print "QUERY_7_A == $query_7_a\n";
   $result_7_a = $enlace->query($query_7_a);
}

/* Function: pre_data()
 *  Input: 
 *         $DBData => Estructura con todos los datos de cada tabla
 *  Output:
 *  Descr: Función que hace un preprocesado de los datos de diferentes tablas.
 *         Ahora mismo hace:
 *           - Limpiar los elementos de cfg_report2item que pertenezcan al report con subtype_cfg_report='00000002'
 *           - Limpiar los elementos de support_pack2tech_group
*/
function pre_data($DBData){
global $enlace;

	// Se limpian los elementos del report de sistemas porque el plugin pro y gpl contienen diferentes elementos
	$query_1_a  = "DELETE FROM cfg_report2item WHERE subtype_cfg_report='00000002'";
	$result_1_a = $enlace->query($query_1_a);
	$query_2_a  = "DELETE FROM support_pack2tech_group";
	$result_2_a = $enlace->query($query_2_a);
}

// --------------------------------------------------------------------------------
// Funcion: _DataInitTable($nombreTabla,$valores)
// Input: nombre de la tabla a la que queremos inicializarle los datos
//			 datos a aplicar a la BBDD
//        - $force: true=>Debe machacar los datos de las tablas (cfg_remote_alerts) | false=>Sólo inserta datos nuevos en las tablas (cfg_remote_alerts)
//			 
//	Funcion encargada de aplicar datos a una tabla
// --------------------------------------------------------------------------------
function _DataInitTable($nombreTabla,$datos,$force=false){
global $enlace;
 
/*
	print ">>>>>>>>>NOMBRETABLA<<<<<<<<\n";
	print("$nombreTabla\n");
	print ">>>>>>>>>datos<<<<<<<<\n";
	print_r($datos);
*/

	if (!is_array($datos)){
		print "La tabla $nombreTabla no tiene datos\n";
		return;
	}


	// Obtener la estructura de la tabla
   $sqlShowCreate="SHOW CREATE TABLE $nombreTabla";
   $resultShowCreate=$enlace->query($sqlShowCreate);
   if (@PEAR::isError($resultShowCreate)) {
      _debug("No se ha podido obtener informacion de la tabla $nombreTabla || USERINFO = ".$resultShowCreate->getUserInfo(),__LINE__,'ERR','_checkTable');
      return;
   }else{
      _debug("Se ha obtenido la informacion de la tabla $nombreTabla",__LINE__,'DBG','_checkTable');
   }
   $resultShowCreate->fetchInto($rShowCreate);

   // AHORA TENEMOS QUE DIVIDIR LAS LINEAS DENTRO DE UN ARRAY
   $columnasEnTablaBBDD = array();
   $columnasEnTablaBBDD = explode( "\n", $rShowCreate['Create Table']);

	// $a_pk es un array que contiene todos los campos que forman la clave primaria
   $a_pk=array();
   for ($i=1;$i<(count($columnasEnTablaBBDD)-1);$i++){
      // EN CASO DE TENER UNA COMA AL FINAL LA ELIMINAMOS
      $ultimoCaracter=substr($columnasEnTablaBBDD[$i],-1,1);
      if ($ultimoCaracter==',') $columnasEnTablaBBDD[$i]=substr($columnasEnTablaBBDD[$i],1,-1);
      // ELIMINAMOS ESPACIOS AL COMIENZO Y AL FINAL DE LA CADENA
      $columnasEnTablaBBDD[$i]=trim($columnasEnTablaBBDD[$i]);

      if(strpos($columnasEnTablaBBDD[$i],'PRIMARY KEY')!==false){
         preg_match("/PRIMARY KEY\s*\((.+)\)/",$columnasEnTablaBBDD[$i],$match);
			$aux=explode('`',$match['1']);
         foreach ($aux as $aux_pk){
            $aux_pk=trim($aux_pk);
            if (($aux_pk!=',')and($aux_pk!='(')and($aux_pk!=')') and ($aux_pk!='') and(strpos($aux_pk,'PRIMARY KEY')===false)){
               $a_pk[]=$aux_pk;
            }
         }
      }
   }
/*
print "\nTABLA == $nombreTabla";
print_r($columnasEnTablaBBDD);
print "\nPK == ".implode(',',$a_pk)."\n------------------------------\n";
return;
*/

   foreach ($datos as $tupla){
/*
      $sqlCuantos="SELECT COUNT(*) AS C FROM $nombreTabla WHERE (";
      $sqlCuantos_sep = '';
      foreach ($a_pk as $pk){
			$sqlCuantos.=$sqlCuantos_sep.$pk."='".$tupla[$pk]."'";
			$sqlCuantos_sep = " AND ";
      }
      $sqlCuantos.=")";
      $resultCuantos=$enlace->query($sqlCuantos);
      $resultCuantos->fetchInto($rCuantos);
*/
/*
      print ">>>>>>>>>$sqlCuantos<<<<<<<<<<\n";
		print_r($rCuantos);
		print "\n--------------------------------\n";
*/


      $a_Cols = array();
      $a_Vals = array();

      $struct = array();

      $sqlBusqueda    = "";
      $sqlBusquedaSep = "";


      foreach($tupla as $columna => $valor){
         if(is_array($valor)){
            $struct['cascade_table'] = $columna;
            $struct['key']           = $valor['id'];
            unset($valor['id']);
            foreach($valor as $a_cascade) $struct['data'][]=$a_cascade;
         }else{
            $a_Cols[]=$columna;
            $a_Vals[]="'".mysql_real_escape_string($valor)."'";

            $sqlBusqueda.=$sqlBusquedaSep.$columna.'='."'".mysql_real_escape_string($valor)."'";
            $sqlBusquedaSep = "AND ";
         }
      }

		if(count($a_Cols)==0)return; // Tablas que no tienen valores en la parte de Init (ej: cfg_task_configured)

		//$sqlTot = "INSERT INTO $nombreTabla (".implode(',',$a_Cols).') VALUES ('.implode(',',$a_Vals).')';

      $sqlUpdate=" ON DUPLICATE KEY UPDATE ";
      $sqlUpdate_sep="";
      foreach ($tupla as $columna => $valor){
         if(in_array($columna,$a_pk)) continue;
         if(is_array($valor)) continue; // Tabla cfg_remote_alerts
         $sqlUpdate.=$sqlUpdate_sep.$columna."='".mysql_real_escape_string($valor)."'";
         $sqlUpdate_sep=',';
      }

      // En caso de tablas en las que todos los campos son clave (support_pack2tech_group,note_types) se pasa a la siguiente entrada
		// Fichero:/opt/cnm/update/db/DB-Scheme-Lib.php linea :940 - _DataInitTable [32242]::Error al ejecutar INSERT INTO support_pack2tech_group (subtype,name) VALUES ('www_base','WWW.HTTP-MIB') (RCERR=-5 || RCSTRERR=DB Error: already exists)


      if($sqlUpdate_sep=='' or ($nombreTabla=='cfg_remote_alerts' AND $force==false)){
			$sqlTot = "INSERT IGNORE INTO $nombreTabla (".implode(',',$a_Cols).') VALUES ('.implode(',',$a_Vals).')';
		}
		else{
			$sqlTot = "INSERT INTO $nombreTabla (".implode(',',$a_Cols).') VALUES ('.implode(',',$a_Vals).')'.$sqlUpdate;
		}

/*	



      // SI NO EXISTE EL ELEMENTO => SE INTRODUCE
      if ($rCuantos['C']==0){
	      $sqlInsert = '('.implode(',',$a_Cols).') VALUES ('.implode(',',$a_Vals).')';
	      $sqlTot = "INSERT INTO $nombreTabla $sqlInsert";
      }
      // SI EXISTE EL ELEMENTO => SE MODIFICA
		else{
         $sqlInsert="UPDATE $nombreTabla SET ";
         $sqlInsert_sep="";
         foreach ($tupla as $columna => $valor){
				if(in_array($columna,$a_pk)) continue;
				if(is_array($valor)) continue; // Tabla cfg_remote_alerts
				$sqlInsert.=$sqlInsert_sep.$columna."='".mysql_real_escape_string($valor)."'";
				$sqlInsert_sep=',';
         }

			// En caso de tablas en las que todos los campos son clave (support_pack2tech_group) se pasa a la siguiente entrada
			if($sqlInsert_sep=='')continue;

			$sqlInsert.=" WHERE (";
         $sqlInsert_sep="";
			foreach ($tupla as $columna => $valor){
            if(!in_array($columna,$a_pk)) continue;
				if(is_array($valor)) continue; // Tabla cfg_remote_alerts
            $sqlInsert.=$sqlInsert_sep.$columna."='".mysql_real_escape_string($valor)."'";
            $sqlInsert_sep=' AND ';
         }
			$sqlInsert.=")";
			$sqlTot = $sqlInsert;
		}
*/
      // print "$sqlTot\n";
      $resultModificarTupla=$enlace->query($sqlTot);
		if (@PEAR::isError($resultModificarTupla)){
         _debug("Error al ejecutar $sqlTot (USERINFO = ".$resultModificarTupla->getUserInfo().")",__LINE__,'ERR','_DataInitTable');
      }


		// Aqui se entra en tablas como cfg_remote_alerts
      if (array_key_exists('key', $struct)) {
         $sqlGetId = "SELECT {$struct['key']} AS id FROM $nombreTabla WHERE ($sqlBusqueda)";
         // print"$sqlGetId\n";
         $resultGetId=$enlace->query($sqlGetId);
         $resultGetId->fetchInto($rGetId);
         $last_id = $rGetId['id'];

         foreach ($struct['data'] as $b){
            $sql_cascade_key = array($struct['key']);
            $sql_cascade_val = array($last_id);

            foreach($b as $b_key=>$b_val){
               $sql_cascade_key[]=$b_key;
               $sql_cascade_val[]="'$b_val'";
            }
            $sql_cascade_insert = "(".implode(',',$sql_cascade_key).") VALUES (".implode(',',$sql_cascade_val).")";
            $sql_cascade_update = "";
            $sep = '';
            for ($i=0;$i<count($sql_cascade_key);$i++){
               $sql_cascade_update.="$sep{$sql_cascade_key[$i]}={$sql_cascade_val[$i]} ";
               $sep=',';
            }

            $sqlCascade = "INSERT INTO {$struct['cascade_table']} $sql_cascade_insert ON DUPLICATE KEY UPDATE $sql_cascade_update";
            // print "$sqlCascade\n";
            $resultSqlCascade=$enlace->query($sqlCascade);
		      if (@PEAR::isError($resultSqlCascade AND $nombreTabla!='cfg_remote_alerts')){
		         _debug("Error al ejecutar $sqlCascade (USERINFO = ".$resultSqlCascade->getUserInfo().")",__LINE__,'ERR','_DataInitTable');
		      }
         }
      }
	}
}

// --------------------------------------------------------------------------------
// Funcion: _cfg_devices2organizational_profile_init()
// Funcion que actualiza los datos que debe haber en la tabla _cfg_devices2organizational_profile_init
// Input: $cid => CID del CNM con ID=1
//
// --------------------------------------------------------------------------------
function _cfg_devices2organizational_profile_init($cid){
global $enlace;

   // Se obtiene el id_cfg_op del perfil 'Global'
   $sql2="SELECT id_cfg_op FROM cfg_organizational_profile WHERE descr='Global'";
   $result2=$enlace->query($sql2);
   $result2->fetchInto($r2);
   $id_cfg_op=$r2['id_cfg_op'];

	_debug("cid=$cid id_cfg_op=$id_cfg_op",__LINE__,'DBG','DataInit');


	$sql1="INSERT INTO cfg_devices2organizational_profile (id_dev,id_cfg_op,cid) SELECT id_dev,$id_cfg_op,'$cid' FROM devices";
	$enlace->query($sql1);

//	$sql2="UPDATE cfg_devices2organizational_profile SET id_cfg_op=(SELECT id_cfg_op FROM cfg_organizational_profile WHERE descr='Global')";
//	$enlace->query($sql2);

//	$sql3="DELETE FROM cfg_devices2organizational_profile WHERE id_cfg_op=0";
//	$enlace->query($sql3);

}


// --------------------------------------------------------------------------------
// Funcion: _cfg_organizational_profile_init()
// Funcion que actualiza los datos que debe haber en la tabla cfg_organizational_profile
// Input:
//
// --------------------------------------------------------------------------------

function _cfg_organizational_profile_init(){
global $enlace;
	
   $sql1="select count(*) as cuantos from cfg_organizational_profile where descr='Global'";
   $result1=$enlace->query($sql1);
	$result1->fetchInto($r1);
	// CASO EN EL QUE NO EXISTE EL GRUPO => LO CREAMOS
	if ($r1['cuantos']==0){
		$sql2="INSERT INTO cfg_organizational_profile (descr,user_group) values ('Global',',1,')";
   	$enlace->query($sql2);	
	// EXISTE EL GRUPO => SEGUIMOS CON LAS COMPROBACIONES	
   }else{
		$sql3="SELECT count(*) as cuantos FROM cfg_organizational_profile WHERE user_group REGEXP ',1,'";	

		$result3=$enlace->query($sql3);
	   $result3->fetchInto($r3);
		// CASO EN EL QUE NO ESTA EL USUARIO ADMIN EN EL GRUPO => LO CREAMOS
	   if ($r3['cuantos']==0){
	      $sql4="INSERT INTO cfg_organizational_profile (descr,user_group) values ('Global',',1,') ON DUPLICATE KEY UPDATE descr='Global',user_group=',1,'";
	      $enlace->query($sql4);
		}
   }
}





// --------------------------------------------------------------------------------
// Funcion: SchemeInit()
// INPUT: $DBScheme,$DBException
// OUTPUT: 0 En caso de ejecutarse correctamente
//			  1 En caso de haber problemas graves
// Funcion que aplica la plantilla $DBScheme a la BBDD de CNM salvo a las tablas que esten en $DBException
// que solamente se comprobaran los campos que se le indiquen y el resto no los borra
// --------------------------------------------------------------------------------
function SchemeInit($DBScheme,$DBException){
global $enlace;

	if(!is_array($DBScheme)) return;
	// OBTENEMOS LAS TABLAS QUE HAY EN LA BBDD
	$sqlTablas="SHOW TABLES";
	$resultTablas=$enlace->query($sqlTablas);
	if (@PEAR::isError($resultTablas)) {
		_debug("No se ha podido obtener informacion de las tablas en la BBDD || USERINFO = ".$resultTablas->getUserInfo(),__LINE__,'ERR','SchemeInit');
		exit;
   }else{
		_debug("Se ha obtenido informacion de las tablas en la BBDD",__LINE__,'DBG','SchemeInit');
   }

	// Array que contiene todas las tablas que hay en la BBDD
	$tablasBBDD=array();
	// Array que contiene todas las tablas que hay en la estructura
	$tablasEst=array();

   while($resultTablas->fetchInto($rTablas)){
		foreach($rTablas as $key=>$value) $tablasBBDD[]=$value;
		//	$tablasBBDD[]=$rTablas['Tables_in_onm']; 
	}

	foreach ($DBScheme as $nombreTablaEst => $contenidoTablaEst){
		$tablasEst[]=$nombreTablaEst;
		// CASO 1: $nombreTabla no esta en la BBDD => Hay que anadir $nombreTabla a la BBDD
		if (!in_array($nombreTablaEst,$tablasBBDD)){
			_addTable($nombreTablaEst,$contenidoTablaEst);
		// CASO 2: $nombreTabla esta en la BBDD => Hay que comprobar que los campos son iguales
		}else{
			_checkTable($nombreTablaEst,$contenidoTablaEst,$DBException);
		}
	}

	// A PARTIR DE AQUI LAS TABLAS QUE HAY EN LA ESTRUCTURA ESTAN PUESTAS EN LA BBDD CON LA MISMA DEFINICION
/*
	// AHORA VAMOS A VER LAS TABLAS QUE HAY EN BBDD QUE NO DEBEN ESTAR
	$tablasAEliminar=array_diff($tablasBBDD,$tablasEst);
   foreach($tablasAEliminar as $TblAEliminar){

		
		//	Con ciertos clientes hay que manejar ciertas tablas que no deben borrarse.
		//	Dichas tablas se empezaran por extra_
		if (substr($TblAEliminar,0,6)=='extra_'){	continue;}
		$sqlDelTabla="DROP TABLE $TblAEliminar";
		$resultDelTabla=$enlace->query($sqlDelTabla);
	   if (@PEAR::isError($resultDelTabla)) {
			_debug("No se ha podido borrar la tabla $TblAEliminar||CMD=>$sqlDelTabla",__LINE__,'ERR','SchemeInit');
	   }else{
			_debug("Se ha borrado la tabla $TblAEliminar",__LINE__,'DBG','SchemeInit');
	   }
   }
*/
}




// --------------------------------------------------------------------------------
// Funcion: _checkTable($nombreTabla,$contenidoTabla,$DBException)
// Input: nombre de la tabla dentro de la estructura a comprobar en la BBDD
//			 contenido de la tabla dentro de la estructura a comprobar en la BBDD
// 		 tablas que SOLO se miraran los campos que se indiquen en $contenidoTabla, dejando el resto intactos
//
// Funcion que comprueba si la tabla $nombreTabla tiene la estructura $contenidoTabla
// en la BBDD
// --------------------------------------------------------------------------------

function _checkTable($nombreTabla,$contenidoTabla,$DBException){
global $enlace;

	$sqlShowCreate="SHOW CREATE TABLE $nombreTabla";
	$resultShowCreate=$enlace->query($sqlShowCreate);
   if (@PEAR::isError($resultShowCreate)) {
		_debug("No se ha podido obtener informacion de la tabla $nombreTabla || USERINFO = ".$resultShowCreate->getUserInfo(),__LINE__,'ERR','_checkTable');
		return;
	}else{
		_debug("Se ha obtenido la informacion de la tabla $nombreTabla",__LINE__,'DBG','_checkTable');
	}
   $resultShowCreate->fetchInto($rShowCreate);

   // AHORA TENEMOS QUE DIVIDIR LAS LINEAS DENTRO DE UN ARRAY
   $columnasEnTablaBBDD = array();
   $columnasEnTablaBBDD = explode( "\n", $rShowCreate['Create Table']);

	// $arrayColumnasTablaBBDD contiene las columnas de la tabla segun la BBDD
	$arrayColumnasTablaBBDD=array();
	// $arrayColumnasTablaEst contiene las columnas de la tabla segun la estructura
   $arrayColumnasTablaEst=array();

	// Hash en el que esta el contenido de la tabla que estamos mirando en la BBDD
	$contenidoTablaBBDD=Array();
	for ($i=1;$i<(count($columnasEnTablaBBDD)-1);$i++){
		// EN CASO DE TENER UNA COMA AL FINAL LA ELIMINAMOS
		$ultimoCaracter=substr($columnasEnTablaBBDD[$i],-1,1);
		if ($ultimoCaracter==','){$columnasEnTablaBBDD[$i]=substr($columnasEnTablaBBDD[$i],1,-1);}
		// ELIMINAMOS ESPACIOS AL COMIENZO Y AL FINAL DE LA CADENA
		$columnasEnTablaBBDD[$i]=trim($columnasEnTablaBBDD[$i]);

		if(strpos($columnasEnTablaBBDD[$i],'PRIMARY KEY')!==false){
			preg_match("/PRIMARY KEY\s*\((.+)\)/",$columnasEnTablaBBDD[$i],$match);
         $nombreColumnaEnBBDD      = "PRIMARY KEY  ({$match['1']})";
         $descripcionColumnaEnBBDD = '';
      }elseif(strpos($columnasEnTablaBBDD[$i],'KEY')!==false){
			$nombreColumnaEnBBDD      = $columnasEnTablaBBDD[$i];
			$descripcionColumnaEnBBDD = '';
		}else{
			$aux=explode('`',$columnasEnTablaBBDD[$i]);
			$nombreColumnaEnBBDD      = $aux[1];
			$descripcionColumnaEnBBDD = $aux[2];
		}
		$contenidoTablaBBDD[$nombreColumnaEnBBDD]=trim($descripcionColumnaEnBBDD);
		$arrayColumnasTablaBBDD[]=$nombreColumnaEnBBDD;
	}

 	// print_r($arrayColumnasTablaBBDD);
	
	// HACEMOS LAS COMPROBACIONES PERTINENTES DE CADA COLUMNA

	foreach ($contenidoTabla as $nombreColumnaEst => $descripcionColumnaEst){
		$arrayColumnasTablaEst[]=$nombreColumnaEst;
		//CASO 1. LA COLUMNA NO EXISTE EN LA TABLA DE LA BBDD
		if (!array_key_exists($nombreColumnaEst,$contenidoTablaBBDD)){
			// print "NO EXISTE EN BBDD $nombreColumnaEst\n";
			// print_r($contenidoTablaBBDD);
			// print("----------------\n");
			_addColumn($nombreColumnaEst,$descripcionColumnaEst,$nombreTabla);
			continue;
		}
		
		// CASO 2. LA COLUMNA EXISTE EN LA TABLA DE LA BBDD
		
		// CASO 2.1. LA COLUMNA ES DIFERENTE
		if (strtoupper($contenidoTablaBBDD[$nombreColumnaEst])!=strtoupper($descripcionColumnaEst)){
/*
			print(strtoupper($descripcionColumnaEst)."\n");
			print"-------------------------\n";
			print("$nombreColumnaEst=>".strtoupper($contenidoTablaBBDD[$nombreColumnaEst])."\n");
			print"-------------------------\n";
			print"-------------------------\n";
			print"-------------------------\n";
*/
			_alterColumn($nombreColumnaEst,$descripcionColumnaEst,$nombreTabla);
			continue;
		}
		// CASO 2.2. LA COLUMNA ES SIMILAR => NO HACEMOS NADA
	}


	// PROCEDEMOS A ELIMINAR LAS COLUMNAS QUE NO DEBEN ESTAR EN LA TABLA DE LA BBDD 
	$sqlShowCreate="SHOW CREATE TABLE $nombreTabla";
	$resultShowCreate=$enlace->query($sqlShowCreate);
   if (@PEAR::isError($resultShowCreate)) {
		_debug("No se ha podido obtener informacion de la tabla $nombreTabla || USERINFO = ".$resultShowCreate->getUserInfo(),__LINE__,'ERR','_checkTable');
		return;
	}else{
		_debug("Se ha obtenido la informacion de la tabla $nombreTabla",__LINE__,'DBG','_checkTable');
	}
   $resultShowCreate->fetchInto($rShowCreate);

   // AHORA TENEMOS QUE DIVIDIR LAS LINEAS DENTRO DE UN ARRAY
   $columnasEnTablaBBDD = array();
   $columnasEnTablaBBDD = explode( "\n", $rShowCreate['Create Table']);

	// $arrayColumnasTablaBBDD contiene las columnas de la tabla segun la BBDD
	$arrayColumnasTablaBBDD=array();
	// $arrayColumnasTablaEst contiene las columnas de la tabla segun la estructura
   $arrayColumnasTablaEst=array();

	// Hash en el que esta el contenido de la tabla que estamos mirando en la BBDD
	$contenidoTablaBBDD=Array();
	for ($i=1;$i<(count($columnasEnTablaBBDD)-1);$i++){
		// EN CASO DE TENER UNA COMA AL FINAL LA ELIMINAMOS
		$ultimoCaracter=substr($columnasEnTablaBBDD[$i],-1,1);
		if ($ultimoCaracter==','){$columnasEnTablaBBDD[$i]=substr($columnasEnTablaBBDD[$i],1,-1);}
		// ELIMINAMOS ESPACIOS AL COMIENZO Y AL FINAL DE LA CADENA
		$columnasEnTablaBBDD[$i]=trim($columnasEnTablaBBDD[$i]);

		if(strpos($columnasEnTablaBBDD[$i],'PRIMARY KEY')!==false){
			preg_match("/PRIMARY KEY\s*\((.+)\)/",$columnasEnTablaBBDD[$i],$match);
         $nombreColumnaEnBBDD      = "PRIMARY KEY  ({$match['1']})";
         $descripcionColumnaEnBBDD = '';
      }elseif(strpos($columnasEnTablaBBDD[$i],'KEY')!==false){
			$nombreColumnaEnBBDD      = $columnasEnTablaBBDD[$i];
			$descripcionColumnaEnBBDD = '';
		}else{
			$aux=explode('`',$columnasEnTablaBBDD[$i]);
			$nombreColumnaEnBBDD      = $aux[1];
			$descripcionColumnaEnBBDD = $aux[2];
		}
		$contenidoTablaBBDD[$nombreColumnaEnBBDD]=trim($descripcionColumnaEnBBDD);
		$arrayColumnasTablaBBDD[]=$nombreColumnaEnBBDD;
	}

 	// print_r($arrayColumnasTablaBBDD);
	
	// HACEMOS LAS COMPROBACIONES PERTINENTES DE CADA COLUMNA

	foreach ($contenidoTabla as $nombreColumnaEst => $descripcionColumnaEst){
		$arrayColumnasTablaEst[]=$nombreColumnaEst;
	}
	
	if (!in_array($nombreTabla,$DBException)){
		$ColumnasAEliminar=array_diff($arrayColumnasTablaBBDD,$arrayColumnasTablaEst);
		foreach($ColumnasAEliminar as $ColAEliminar){
			_dropColumn($ColAEliminar,$nombreTabla);
		}
	}
}



// --------------------------------------------------------------------------------
// Funcion: _dropColumn($ColAEliminar,$nombreTabla)
// Input: nombre de la columna a comprobar de la BBDD
//        nombre de la tabla a la que queremos eliminar la columna de la BBDD
//
// Funcion que elimina la columna $ColAEliminar de la tabla $nombreTabla 
// --------------------------------------------------------------------------------


function _dropColumn($ColAEliminar,$nombreTabla){
global $enlace;

#PRIMARY KEY  (`id_dev`,`mtype`,`subtype`,`pattern`)
	// if (ereg("PRIMARY KEY", $ColAEliminar)){
   if (strpos($ColAEliminar,'PRIMARY KEY')!==false){
		$sqlDelCol="ALTER TABLE $nombreTabla drop PRIMARY KEY";
	}
	// elseif(ereg("KEY", $ColAEliminar)){
	elseif(strpos($ColAEliminar,'KEY')!==false){
		$aux=explode('`',$ColAEliminar);
      $nombreKey=$aux[1];
      // 1. Tenemos que deshacer la clave
      $sqlDelCol="ALTER TABLE $nombreTabla drop index $nombreKey";
   }
	else{
		$sqlDelCol="ALTER TABLE $nombreTabla drop $ColAEliminar";
	}

	$resultDelCol=$enlace->query($sqlDelCol);
   if (@PEAR::isError($resultDelCol)) {
		_debug("No se ha podido eliminar la columna $ColAEliminar de la tabla $nombreTabla||CMD=>$sqlDelCol || USERINFO = ".$resultDelCol->getUserInfo(),__LINE__,'ERR','_dropColumn');
   }else{
		_debug("Se ha eliminado correctamente la columna $ColAEliminar de la tabla $nombreTabla",__LINE__,'DBG','_dropColumn');
   }
}




// --------------------------------------------------------------------------------
// Funcion: _alterColumn($nombreColumnaEst,$descripcionColumnaEst,$nombreTabla)
// Input: nombre de la columna que se tiene que modificar en la BBDD 
//        descripcion de la columna que debe tomar en la BBDD
//			 nombre de la tabla que contiene la columna en la BBDD
//
// --------------------------------------------------------------------------------

function _alterColumn($nombreColumnaEst,$descripcionColumnaEst,$nombreTabla){
global $enlace;

	$sqlModify="ALTER TABLE $nombreTabla CHANGE $nombreColumnaEst $nombreColumnaEst $descripcionColumnaEst";
	$resultModify=$enlace->query($sqlModify);
   if (@PEAR::isError($resultModify)) {
		_debug("No se ha podido modificar la columna $nombreColumnaEst de la tabla $nombreTabla||CMD=>$sqlModify || USERINFO = ".$resultModify->getUserInfo(),__LINE__,'ERR','_alterColumn');
   }else{
		_debug("Se ha modificado la columna $nombreColumnaEst de la tabla $nombreTabla",__LINE__,'DBG','_alterColumn');
   }
}




// --------------------------------------------------------------------------------
// Funcion: _addColumn($nombreColumnaEst,$descripcionColumnaEst,$nombreTabla)
// Input: nombre de la columna que se tiene que anadir a la tabla de la BBDD 
//        descripcion de la columna que debe tomar en la BBDD
//        nombre de la tabla que contiene la columna en la BBDD
//
// --------------------------------------------------------------------------------

function _addColumn($nombreColumnaEst,$descripcionColumnaEst,$nombreTabla){
global $enlace;

	// if (ereg("PRIMARY KEY", $nombreColumnaEst)){
	if (strpos($nombreColumnaEst,'PRIMARY KEY')!==false){
		// 1. Tenemos que deshacer la clave primaria
		$sqlDelCol="ALTER TABLE $nombreTabla drop PRIMARY KEY";
		$resultDelCol=$enlace->query($sqlDelCol);
	// }elseif (ereg("KEY", $nombreColumnaEst)){
	}elseif (strpos($nombreColumnaEst,'KEY')!==false){
		$aux=explode('`',$nombreColumnaEst);
		$nombreKey=$aux[1];
		// 1. Tenemos que deshacer la clave
		$sqlDelCol="ALTER TABLE $nombreTabla drop index $nombreKey";
		$resultDelCol=$enlace->query($sqlDelCol);
	}
	$sqlAddCol="ALTER TABLE $nombreTabla ADD $nombreColumnaEst $descripcionColumnaEst";

	$resultAddCol=$enlace->query($sqlAddCol);
   if (@PEAR::isError($resultAddCol)) {
		_debug("No se ha podido crear la columna $nombreColumnaEst de la tabla $nombreTabla||CMD=>$sqlAddCol || USERINFO = ".$resultAddCol->getUserInfo(),__LINE__,'ERR','_addColumn');
   }else{
		_debug("Se ha creado la columna $nombreColumnaEst de la tabla $nombreTabla",__LINE__,'DBG','_addColumn');
   }
}


// --------------------------------------------------------------------------------
// Funcion: _dropTable($input_table,$db_params)
// Input: 
// 		$input_table => nombre de la tabla a eliminar de la BBDD
// 		$db_params => datos de la BBDD en la que hay que eliminar la tabla
//
// Funcion que elimina de la BBDD la tabla $nombreTabla 
// --------------------------------------------------------------------------------

function _dropTable($input_table,$db_params){
global $enlace;

	connectDB($db_params);
	if(gettype($input_table)=='string'){
		$nombreTabla = $input_table;
		if(strpos($nombreTabla,'extra_')!==0){
			_debug("No se ha podido eliminar la tabla $nombreTabla porque el nombre no comienza por extra_",__LINE__,'ERR','_dropTable');
		}
		else{
	      $sqlDrop="DROP TABLE $nombreTabla";
	      $resultDrop=$enlace->query($sqlDrop);
	      if (@PEAR::isError($resultDrop)) {
	         _debug("No se ha podido eliminar la tabla $nombreTabla||CMD=>$sqlDrop || USERINFO = ".$resultDrop->getUserInfo(),__LINE__,'ERR','_dropTable');
	      }
			else{
	         _debug("Se ha eliminado tabla $nombreTabla",__LINE__,'DBG','_dropTable');
	      }
		}
	}
	elseif(gettype($input_table)=='array'){
      foreach($input_table as $nombreTabla){
	      if(strpos($nombreTabla,'extra_')!==0){
	         _debug("No se ha podido eliminar la tabla $nombreTabla porque el nombre no comienza por extra_",__LINE__,'ERR','_dropTable');
	      }
	      else{
	         $sqlDrop="DROP TABLE $nombreTabla";
	         $resultDrop=$enlace->query($sqlDrop);
	         if (@PEAR::isError($resultDrop)) {
	            _debug("No se ha podido eliminar la tabla $nombreTabla||CMD=>$sqlDrop || USERINFO = ".$resultDrop->getUserInfo(),__LINE__,'ERR','_dropTable');
	         }
	         else{
	            _debug("Se ha eliminado tabla $nombreTabla",__LINE__,'DBG','_dropTable');
	         }
	      }
      }
	}
	else{
		_debug('El tipo de la variable $input_table no es string ni array.',__LINE__,'ERR','_dropTable');
	}
}



// --------------------------------------------------------------------------------
// Funcion: _addTable($nombreTabla,$contenidoTabla)
// Input: nombre de la tabla a comprobar en la BBDD
//        contenido de la tabla a comprobar en la BBDD
//
// Funcion que inserta en la BBDD la tabla $nombreTabla con la definicion dada en 
// $contenidoTabla
// --------------------------------------------------------------------------------

function _addTable($nombreTabla,$contenidoTabla){
global $enlace;

	$sqlAdd="CREATE TABLE $nombreTabla (";

	// $contador comprueba si es el primer string que se pone en $sqlAdd y no poner una , delante
	$contador=0;
	foreach ($contenidoTabla as $nombreCampo => $descripcionCampo){
		// if(ereg("KEY", $nombreCampo)){
		if(strpos($nombreCampo,'KEY')!==false){
			if ($contador==0){$sqlAdd.=" $nombreCampo";}
			else{$sqlAdd.=" ,$nombreCampo";}
		}else{
			if ($contador==0){$sqlAdd.=" $nombreCampo $descripcionCampo";}
			else{$sqlAdd.=" ,$nombreCampo $descripcionCampo";}
		}
	$contador++;
	} 

	$sqlAdd.=')';

	//print $sqlAdd;	
	$resultAdd=$enlace->query($sqlAdd);
   if (@PEAR::isError($resultAdd)) {
		_debug("No se ha podido crear la tabla $nombreTabla||CMD=>$sqlAdd || USERINFO = ".$resultAdd->getUserInfo(),__LINE__,'ERR','_addTable');
   }else{
		_debug("Se ha creado la tabla $nombreTabla",__LINE__,'DBG','_addTable');
   }
}

// ----------------------------------------------------------
// FUNCION get_db()
// INPUT:
// OUTPUT: 0 => OK
// 		  1 => NO OK
// Funcion que almacena en fichero el contenido de la tabla cfg_monitor_snmp con el formato
// indicado para poder ser utilizado en otro equipo
// ----------------------------------------------------------

function get_db_snmp_cfg_metrics($filepath){
global $enlace;

	$sql1="SELECT subtype,class,lapse,descr,items,oid,oidn,oid_info,lapse,get_iid,label,module,mtype,vlabel,mode,top_value FROM cfg_monitor_snmp WHERE subtype like 'custom%'";	
	$result1=$enlace->query($sql1);
	if (@PEAR::isError($result1)){
		return 1;
   }
	$contenidoTabla.="<?\n";
	//$contenidoTabla.='$CFG_MONITOR_SNMP=array('."\n";
		
	while ($result1->fetchInto($r1)){
		$contenidoTabla.="\t".'$CFG_MONITOR_SNMP[]=array('."\n";
			foreach ($r1 as $key => $value){
				$contenidoTabla.="\t\t'".$key."' => '".$value."',\n";
			}
		$contenidoTabla.="\t".');'."\n";
	}

	//$contenidoTabla.=');'."\n";
	$contenidoTabla.="?>";
	
	$DescriptorFichero = fopen("$filepath","w");
	fputs($DescriptorFichero,$contenidoTabla); 
	fclose($DescriptorFichero);


	return 0;
}


function DataModInit($datos){
global $enlace;
/*
// Datos que deben ser modificados y no insertados
$DBModData = array(
   'tips'       => array('data'=>$TIPS, 'key'=>array('id_ref','tip_type'),'condition'=>'tip_class=1'),
	                UPDATE IGNORE tips SET name='Nueva entrada',descr='Linea 1<br>Linea 2<br>Linea 3<br>',url='',date='1359711701',tip_class='0',position='0',id_refn='0' WHERE id_ref='cpq_os_context' AND tip_type='cfg'       AND 'tip_class=1';
						 INSERT IGNORE INTO tips (id_ref,tip_type,name,descr,url,date,tip_class,position,id_refn) VALUES ('cpq_os_context','cfg','Nueva entrada','Linea 1<br>Linea 2<br>Linea 3<br>','','1359711701','0','0','0');

   'cnm_config' => array('data'=>$CNM_CONFIG, 'key'=>array('cnm_key'),'condition'=>"cnm_value=''"),
						 UPDATE IGNORE cnm_config SET cnm_value='90',cnm_descr='Profundidad en días del histórico de eventos' WHERE cnm_key='max_days_event'      AND cnm_value='';
						 INSERT IGNORE INTO cnm_config (max_key,cnm_value,cnm_descr) VALUES ('max_days_event','90','Profundidad en días del histórico de eventos');


   'cfg_users'  => array('data'=>$CFG_USERS, 'key'=>array('login_name'),'condition'=>"token=''"),
						 UPDATE IGNORE cfg_users SET passwd='',token='7c50ce209c4045816b1e7449525709a0c5f68cf865da06c7b6dd0313e448f54233ce8327', descr='Usuario Administrador',perfil='1',timeout='1440',params='' WHERE login_name='admin'   AND token='';
						 INSERT IGNORE INTO cfg_users (login_name,passwd,token,descr,perfil,timeout,params) VALUES ('admin','','7c50ce209c4045816b1e7449525709a0c5f68cf865da06c7b6dd0313e448f54233ce8327','Usuario Administrador','1','1440','');
);

$DBModDataCNM = array(
   'cfg_cnms' => array('data'=>$CFG_CNMS, 'key'=>array('cid','host_ip'),'condition'=>"hidx=-1"),
						UPDATE IGNORE cfg_cnms SET descr='Default client',db1_name='onm',host_name='cnm-devel2',host_descr='localhost',id_client='1',status='0' WHERE cid='default' AND host_ip='10.2.254.223'      AND hidx=-1;
						INSERT IGNORE INTO cfg_cnms (hidx,cid,descr,db1_name,host_ip,host_name,host_descr,id_client,status) VALUES ('1','default','Default client','onm','10.2.254.223','cnm-devel2','localhost','1','0');
);
*/
	if(!is_array($datos))return;

	foreach ($datos as $nombreTabla => $infoTabla){
		if (!array_key_exists('data',$infoTabla)) continue;
		if (!is_array($infoTabla['data'])) continue;
		foreach($infoTabla['data'] as $tupla){
			$sqlTot = "UPDATE IGNORE $nombreTabla SET ";

			$sep = '';
			foreach ($tupla as $columna => $valor){
				if(in_array($columna,$infoTabla['key'])) continue;
            $sqlTot.=$sep.$columna."='".mysql_real_escape_string($valor)."'";
            $sep=',';
         }
			$sqlTot.=" WHERE ";

			$sep = '';
         foreach ($tupla as $columna => $valor){
            if(!in_array($columna,$infoTabla['key'])) continue;
            $sqlTot.=$sep.$columna."="."'".$valor."'";
            $sep=' AND ';
         }
			if($infoTabla['condition']!='') $sqlTot.=" AND {$infoTabla['condition']}";
	      // print "$sqlTot\n";
         $resultModificarTupla=$enlace->query($sqlTot);
			if (@PEAR::isError($resultModificarTupla)){
	         _debug("Error al ejecutar $sqlTot (USERINFO = ".$resultModificarTupla->getUserInfo().")",__LINE__,'ERR','DataModInit');
	      }
		}
	}

   foreach ($datos as $nombreTabla => $infoTabla){
      if (!array_key_exists('data',$infoTabla)) continue;
      if (!is_array($infoTabla['data'])) continue;
      foreach($infoTabla['data'] as $tupla){
         $sqlTot = "INSERT IGNORE INTO $nombreTabla (";

         $sep = '';
         foreach ($tupla as $columna => $valor){
            $sqlTot.=$sep.$columna;
            $sep=',';
         }
			$sqlTot.=") VALUES (";

         $sep = '';
         foreach ($tupla as $columna => $valor){
            $sqlTot.=$sep."'".mysql_real_escape_string($valor)."'";
				$sep=',';
         }
			$sqlTot.=")";
         // print "$sqlTot\n";
         $resultModificarTupla=$enlace->query($sqlTot);
			if (@PEAR::isError($resultModificarTupla)){
	         _debug("Error al ejecutar $sqlTot (USERINFO = ".$resultModificarTupla->getUserInfo().")",__LINE__,'ERR','DataModInit');
	      }
      }
   }
}

function _limpiar_tips(){
global $enlace;
	$array_limpieza=array(
			"DELETE FROM tips WHERE tip_type='xapp' AND tip_class=1",
			"DELETE FROM tips WHERE tip_type='cfg' AND tip_class=1",
			"DELETE FROM tips WHERE tip_type='cfg_task' AND tip_class=1",
			"DELETE FROM tips WHERE tip_type='latency' AND tip_class=1",
			"DELETE FROM tips WHERE tip_type='wbem' AND tip_class=1",
			"DELETE FROM tips WHERE tip_type='id_alert_type' AND tip_class=1",
			"DELETE FROM tips WHERE tip_type='id_cfg_view' AND tip_class=1",
		);
	foreach ($array_limpieza as $sql){
	   $result=$enlace->query($sql);
	   if (@PEAR::isError($result)) {
	      _debug("No se ha podido limpiar la tabla tips al ejecutar $sql || USERINFO = ".$result->getUserInfo(),__LINE__,'ERR','_limpiar_tips');
	      exit;
	   }else{
	      _debug("Se ha limpiado la tabla tips al ejecutar $sql",__LINE__,'DBG','_limpiar_tips');
	   }
	}
}

function table_charset_latin1($db_params){
global $enlace;

   connectDB($db_params);

   $sqlTablas="SHOW TABLES";
   $resultTablas=$enlace->query($sqlTablas);
   if (@PEAR::isError($resultTablas)) {
      _debug("No se ha podido obtener la informacion de las tablas de la BBDD || USERINFO = ".$resultTablas->getUserInfo(),__LINE__,'ERR','table_charset_latin1');
      exit;
   }else{
      _debug("Se ha obtenido la informacion de las tablas de la BBDD",__LINE__,'DBG','table_charset_latin1');
   }

   $tablasEst=array();
   while($resultTablas->fetchInto($rTablas)){
      foreach($rTablas as $key=>$value) $tablasEst[]=$value;
   }
   // Ponemos todas las tablas con charset latin1
   foreach($tablasEst as $tabla){
		// Mirar si tiene ya charset latin1
		$sqlCheckCharset="SHOW CREATE TABLE $tabla";
	   $resultCheckCharset=$enlace->query($sqlCheckCharset);
   	if (@PEAR::isError($resultCheckCharset)) {
      	// _debug("No se ha podido obtener informacion de la tabla $tabla",__LINE__,'ERR','table_charset_latin1');
      	continue;
   	}else{
      	// _debug("Se ha obtenido la informacion de la tabla $tabla",__LINE__,'DBG','table_charset_latin1');
   	}
   	$resultCheckCharset->fetchInto($rCheckCharset);
	   // AHORA TENEMOS QUE DIVIDIR LAS LINEAS DENTRO DE UN ARRAY
	   $a_aux = array();
	   $a_aux = explode( "\n", $rCheckCharset['Create Table']);
		$charset = '';
		foreach($a_aux as $line){
			$line = strtoupper($line);
			if(false===strpos($line,'CHARSET')) continue;
			if (preg_match("/ENGINE=.*CHARSET=(.+)/",$line,$match))$charset=$match[1]; 
		}

		if($charset=='LATIN1'){
         _debug("La tabla $tabla de la BBDD {$db_params['database']} ya tiene charset latin1",__LINE__,'DBG','table_charset_latin1');
			continue;
		}

      $sqlAlterTabla="ALTER TABLE $tabla charset=latin1";
      $resultAlterTabla=$enlace->query($sqlAlterTabla);
      if (@PEAR::isError($resultAlterTabla)) {
			if($resultAlterTabla->getCode()=='-18'){
			}else{
	         _debug("No se ha podido cambiar el charset a latin1 de la tabla $tabla de la BBDD {$db_params['database']} || USERINFO = ".$resultAlterTabla->getUserInfo(),__LINE__,'ERR','table_charset_latin1');
			}
      }else{
         _debug("Se ha cambiado el charset de la tabla $tabla de la BBDD {$db_params['database']}",__LINE__,'DBG','table_charset_latin1');
      }
   }
}

function _cnms($db_params){
global $enlace;

   $a_client=array();

   connectDB($db_params);

   $iface = 'eth0';
   $file = '/cfg/onm.if';
   if(file_exists($file) and false!=file_get_contents($file)) $iface = chop(file_get_contents($file));
   $local_ip = chop(`/sbin/ifconfig $iface|grep 'inet addr'|cut -d ":" -f2|cut -d " " -f1`);

	#$local_ip = chop(`/sbin/ifconfig eth0|grep 'inet addr'|cut -d ":" -f2|cut -d " " -f1`);
	// $result=$enlace->query("SELECT hidx,cid,descr,db1_name,db1_server,db1_pwd,db1_user,db2_name,db2_server,db2_pwd,db2_user FROM cfg_cnms WHERE host_ip='$local_ip'");
	$result=$enlace->query("SELECT * FROM cfg_cnms WHERE host_ip='$local_ip'");
   if (@PEAR::isError($result)) {
      // _debug("No se ha podido obtener la informacion de los cnms en la BBDD cnm",__LINE__,'ERR','_cnms');
      // exit;
   }else{
      _debug("Se ha obtenido la informacion de los cnms de la BBDD cnm",__LINE__,'DBG','_cnms');
   	while($result->fetchInto($r)){

	      /*
         DB_SERVER = localhost
         DB_NAME = onm
         DB_USER = onm
         DB_PWD = pwd
         DB_TYPE = mysql
	      */
         $fileCfg = '/cfg/'.$r['db1_name'].'.conf';
         $aData = array('DB_SERVER'=>'', 'DB_USER'=>'', 'DB_PWD'=>'', 'DB_TYPE'=>'');
         $rcstrReadFile=read_cfg_file($fileCfg,$aData);
/*
			// OLD
			$a_client[]=$r; 
*/
			$a_client[]=array('hidx'=>$r['hidx'],'db1_user'=>$aData['DB_USER'],'db1_pwd'=>$aData['DB_PWD'],'db1_server'=>$aData['DB_SERVER'],'db1_name'=>$r['db1_name'],'cid'=>$r['cid'],'descr'=>$r['descr']); 
		}
   }

	return $a_client;
}

function _create_cnm_database($db_params){
global $enlace;

	$dbi_params=array(
		'phptype' =>  $db_params['phptype'],
      'username' => $db_params['username'],
      'password' => $db_params['password'],
      'hostspec' => $db_params['hostspec'],
	);
	connectDB($dbi_params);
   $result=$enlace->query('CREATE DATABASE IF NOT EXISTS cnm');
   if (@PEAR::isError($result)) {
      _debug("No se ha podido crear la BBDD cnm || USERINFO = ".$result->getUserInfo(),__LINE__,'ERR','_create_cnm_database');
      exit;
   }else{
      _debug("Se ha creado la BBDD cnm correctamente",__LINE__,'INF','_create_cnm_database');
   }

   $result=$enlace->query('CREATE DATABASE IF NOT EXISTS onmgraph');
   if (@PEAR::isError($result)) {
      _debug("No se ha podido crear la BBDD onmgraph || USERINFO = ".$result->getUserInfo(),__LINE__,'ERR','_create_onmgraph_database');
      exit;
   }else{
      _debug("Se ha creado la BBDD onmgraph correctamente",__LINE__,'INF','_create_onmgraph_database');
   }

}

/*
 * Funcion: _create_clients_databases
 * Input:
 *        $a_client  => Datos de las BBDD cliente que deben estar creadas en BBDD
 *        $db_params => Parámetros para la conexión a la BBDD
 * Output: 
 * Descr: Funcion encargada de crear las BBDD ONM (en caso de no existir) partiendo de los datos que hay en cnm.cfg_cnms
*/
function _create_clients_databases($a_client,$db_params){
global $enlace;

   connectDB($db_params);
	foreach ($a_client as $client){
      $db1_name = $client['db1_name'];
      $db1_user = $client['db1_user'];
      $db1_pass = $client['db1_pwd'];
      $db1_host = $client['db1_server'];
	
	   $qCreate = "CREATE DATABASE IF NOT EXISTS $db1_name";
	   $rqCreate=$enlace->query($qCreate);
	   if (@PEAR::isError($rqCreate)) {
	      _debug("No se ha podido crear la BBDD $db1_name || USERINFO = ".$rqCreate->getUserInfo(),__LINE__,'ERR','_create_clients_databases');
	      exit;
	   }else{
	      _debug("Se ha creado la BBDD $db1_name",__LINE__,'INF','_create_clients_databases');
		}

      $qPrivileges= "GRANT ALL PRIVILEGES ON `$db1_name`.* TO '$db1_user'@'$db1_host' IDENTIFIED BY '$db1_pass' WITH GRANT OPTION";
	   $rqPrivileges=$enlace->query($qPrivileges);
	   if (@PEAR::isError($rqPrivileges)){
	      _debug("No se ha podido dar los privilegios al usuario $db1_user en la BBDD $db1_name ($qPrivileges) || USERINFO = ".$rqPrivileges->getUserInfo(),__LINE__,'ERR','_create_clients_databases');
	      exit;
	   }else{
	      _debug("Se han dado los privilegios al usuario $db1_user en la BBDD $db1_name correctamente ($qPrivileges)",__LINE__,'INF','_create_clients_databases');
			//$rqFlush=$enlace->query('FLUSH PRIVILEGES');
	   }
   }
}

//------------------------------------------------------------------------------------
function store_rev($rev){
global $enlace;

	if ($rev==0) { return; }
	$date_store=time();
   $query = "INSERT INTO cnm_services (type,value,date_store) VALUES ('rev','$rev',$date_store) ON DUPLICATE KEY UPDATE type='rev',value='$rev',date_store=$date_store";
   $result = $enlace->query($query);
}

//------------------------------------------------------------------------------------
function include_dir($dir){
	if(is_dir($dir)){
   	$a_files = glob("$dir/*.php");
	   foreach ($a_files as $file) require_once($file);
	}
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
function read_cfg_file($file,&$data){
   $rcstr='';
   $lines = file($file);
   if (! $lines) {
      $rc="Error al abrir fichero $file en modo lectura";
      return $rc;
   }
   foreach ($data as $clave => $valor) {
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
}
function is_assoc($var){
	return is_array($var) && array_diff_key($var,array_keys(array_keys($var)));
}
?>
