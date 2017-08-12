<?php
/*

DESCRIPCION: PROGRAMA DE TEST PARA INCLUIR METRICAS SNMP EN EL SISTEMA.
PERMITE VALIDAR EL FUNCIONAMIENTO DE LAS MISMAS ANTES DE PONER EN PRODUCCION.

USO: php db-manage.php [path_relativo]
En caso de querer utilizar un fichero diferente a /opt/crawler/bin/test/db-load/DB-Scheme-test-snmp.php, debemos poner 
la ruta relativa del fichero que contiene los datos
*/ 

// ----------------------------------------------------------------------
// MODULO QUE CONTIENE LAS FUNCIONES
require_once('/update/db/DB-Scheme-Lib.php');
// MODULO QUE CONTIENE LA ESTRUCTURA DE LA BBDD
require_once('/update/db/DB-Scheme-Create.php');

$path=$argv[1];

	if ($path!=''){
		require_once("./$path");
	}else{
		// MODULO QUE CONTIENE LOS DATOS A INSERTAR
		require_once('/opt/crawler/bin/test/db-load/DB-Scheme-test-snmp.php');
	}

$DBData = array(
   'cfg_monitor_snmp'  =>  $CFG_MONITOR_SNMP,
);

load_db($DBScheme,$DBData);

?>
