<?php
/*
 * $a_not_update_data : Tablas que deben tratarse de una forma diferente a la estandar
 *
*/
$a_not_update_data = array('cnm_config','tips','cfg_users');

/*
 * $DBData: Tablas con los datos que se van a inicializar en la BBDD ONM 
 * NOTAS: 
 *        Deben estar en /update/db/Init/[tabla]/ficheros.php
 *        Cada tabla contendrá ficheros que inicializan una variable global llamada igual que la tabla pero en mayusculas
 *        A $DBData se le va a aplicar la función DataInit()
 *
*/
$DBData = array();
$dh  = opendir("/update/db/Init/");
while (false !== ($tabla = readdir($dh))) {
   if( (!is_dir("/update/db/Init/$tabla")) or ($tabla=='.') or ($tabla=='..') ) continue;
	// print "**** TABLA == $tabla ****\n";
   $a_files = glob("/update/db/Init/$tabla/*.php");
   foreach ($a_files as $file){
		// print "$file\n";
		require_once($file);
	}
   $DBData[$tabla] = (in_array($tabla,$a_not_update_data))?array():${strtoupper($tabla)};
}
closedir($dh);

/*
 * Datos que deben ser actualizados con cierto criterio en la BBDD ONM
 * NOTAS: A $DBModData se le va a aplicar la función DataModInit()
*/
$DBModData = array(
   'tips'       => array('data'=>$TIPS, 'key'=>array('id_ref','tip_type'),'condition'=>'tip_class=1'),
   'cnm_config' => array('data'=>$CNM_CONFIG, 'key'=>array('cnm_key'),'condition'=>"cnm_value=''"),
	'cfg_users'  => array('data'=>$CFG_USERS, 'key'=>array('login_name'),'condition'=>"token=''"),
);


/*
 * $a_not_update_data_cnm : Tablas que deben tratarse de una forma diferente a la estandar
 *
*/
$a_not_update_data_cnm = array('cfg_cnms');

/*
 * $DBDataCNM: Tablas con los datos que se van a inicializar en la BBDD CNM
 * NOTAS: 
 *        Deben estar en /update/db/Init-cnm/[tabla]/ficheros.php
 *        Cada tabla contendrá ficheros que inicializan una variable global llamada igual que la tabla pero en mayusculas
 *        A $DBDataCNM se le va a aplicar la función DataInit()
 *
*/
$DBDataCNM = array();
$dh  = opendir("/update/db/Init-cnm/");
while (false !== ($tabla = readdir($dh))) {
   if( (!is_dir("/update/db/Init-cnm/$tabla")) or ($tabla=='.') or ($tabla=='..') ) continue;
   // print "**** TABLA == $tabla ****\n";
   $a_files = glob("/update/db/Init-cnm/$tabla/*.php");
   foreach ($a_files as $file){
      // print "$file\n";
      require_once($file);
   }
   $DBDataCNM[$tabla] = (in_array($tabla,$a_not_update_data_cnm))?array():${strtoupper($tabla)};
}

/*
 * Datos que deben ser actualizados con cierto criterio en la BBDD CNM
 * NOTAS: A $DBModDataCNM se le va a aplicar la función DataModInit()
          Se pone hidx=-1 para que no actualice nunca (se tiene que cumplir que hidx=-1) y que solo inserte
*/
$DBModDataCNM = array(
	'cfg_cnms' => array('data'=>$CFG_CNMS, 'key'=>array('cid','host_ip'),'condition'=>"hidx=-1"),
);
?>
