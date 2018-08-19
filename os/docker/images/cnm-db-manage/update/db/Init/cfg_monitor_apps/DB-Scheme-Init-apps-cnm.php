<?php

// Posibles valores de myrange
// * -> Patra todo el mundo
// EN SNMP 		>>	HOST-RESOURCES-MIB::hrStorageTable
// EN LATENCY 	>> comando a chequear
// EN XAGENT 	>>	win32::wmi::cimv2::Win32_Process
//						linux::lsof
// ip:localhost Para la ip especificada
// oid:.1.2.1.2... Para el oid especificado


// itil_type: operacion 1, configuracion 2, capacidad 3, disponibilidad 4, seguridad 5
// cfg: 0-> No instanciada, 1-> Instanciada

// format hace referencia al formato de salida generado por la aplicacion
// 0=> La aplicacion no genera formato
// 1=> La aplicacion compone el xml

// enterprise es necesario para optimizar el chequeo de las snmp. En el resto de casos por
// ahora no tiene uso

// res=1 => Tiene resultados (hay solapa)
// res=0 => No tiene resultados (no hay solapa)


/*
LIMPIEZA:
Sobran los siguientes campos:

ipparam

*/

      // CNM ------------------------------------------------------------------------
//      $CFG_MONITOR_APPS[]=array(
//         'type' => 'cnm', 'subtype'=>'CNM-Admin', 'itil_type'=>'2',  'name'=>'INVENTARIO DE METRICAS DEFINIDAS EN VISTAS',
//         'descr' => 'Obtiene el inventario con las metricas asociadas a  una vistas definida en el sistema gestor',
//         'cmd' => '',
//         'params' => '',      'iptab'=>'0', 'ready'=>'1',
//         'myrange' => 'cnm',   'enterprise'=>'0',
//         'cfg' => '0',  'platform' => '*',   'script' => 'ws_get_csv_view_metrics',   'format'=>1,
//         'custom' => '0', 'aname'=> 'app_cnm_csv_view_metrics', 'res'=>1, 'ipparam'=>'',
//         'apptype' => 'CNM',  'itil_type' => '1',
//      );

      $CFG_MONITOR_APPS[]=array(
         'type' => 'cnm', 'subtype'=>'CNM-Admin', 'itil_type'=>'2',  'name'=>'AUDITORIA DE RED',
         'descr' => 'Escanea el rango de red especificado en busca de equipos',
         'cmd' => '',
         'params' => '[;RANGO;]',		'iptab'=>'0', 'ready'=>'0',
         'myrange' => 'cnm',   'enterprise'=>'0',
         'cfg' => '0',  'platform' => '*',   'script' => 'audit',   'format'=>3,
         'custom' => '0', 'aname'=> 'app_cnm_audit', 'res'=>1, 'ipparam'=>'',
			'apptype' => 'CNM',	'itil_type' => '1',
      );

      $CFG_MONITOR_APPS[]=array(
         'type' => 'cnm', 'subtype'=>'CNM-Admin', 'itil_type'=>'2',  'name'=>'BACKUP DE CNM',
         'descr' => 'Realiza el backup del sistema CNM',
         'cmd' => '',
         'params' => '',      'iptab'=>'0', 'ready'=>'1',
         'myrange' => 'cnm',   'enterprise'=>'0',
         'cfg' => '0',  'platform' => '*',   'script' => 'cnm_backup.php',   'format'=>0,
         'custom' => '0', 'aname'=> 'app_cnm_backup', 'res'=>1, 'ipparam'=>'',
         'apptype' => 'CNM',  'itil_type' => '1',
      );

      $CFG_MONITOR_APPS[]=array(
         'type' => 'cnm', 'subtype'=>'CNM-Admin', 'itil_type'=>'2',  'name'=>'RESTAURACION DE DATOS DE UN EQUIPO PASIVO DESDE OTRO ACTIVO',
         'descr' => 'Restaura lopo configurado como PASIVO, retaura los datos desde el backup de un CNM ACTIVO.',
         'cmd' => '',
         'params' => '',      'iptab'=>'0', 'ready'=>'0',
         'myrange' => 'cnm',   'enterprise'=>'0',
         'cfg' => '0',  'platform' => '*',   'script' => 'linux_app_restore_passive_from_active.pl',   'format'=>0,
         'custom' => '0', 'aname'=> 'app_cnm_restore', 'res'=>1, 'ipparam'=>'',
         'apptype' => 'CNM',  'itil_type' => '1',
      );


?>
