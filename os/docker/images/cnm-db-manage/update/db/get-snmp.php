<?php
/*

DESCRIPCION: PROGRAMA DE TEST PARA OBTENER METRICAS SNMP CONFIGURADAS POR EL USUARIO 

USO: php get-snmp.php 

*/ 

// ----------------------------------------------------------------------
// MODULO QUE CONTIENE LAS FUNCIONES
require_once('/update/db/DB-Scheme-Lib.php');
// RUTA DONDE SE VA A GUARDAR EL FICHERO
$filepath='/tmp/snmp_configured_metrics';

connectDB();
get_db_snmp_cfg_metrics($filepath);

?>
