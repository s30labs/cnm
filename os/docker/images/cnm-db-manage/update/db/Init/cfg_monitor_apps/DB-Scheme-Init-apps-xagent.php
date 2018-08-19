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

// fml. Falta definir el campo myrange si se quieren provisionar de forma automatica estas aplicaciones.
// Se requiere script que haga el chequeo sobre si responde. Valorar el incluirlas en SP.

		// XAGENT ---------------------------------------------------------------------
//win32-app-wmi-process-list-running.vbs
      $CFG_MONITOR_APPS[]=array(
         'type' => 'xagent', 'subtype'=>'WIN32-OS', 'itil_type'=>'2',  'name'=>'LISTA PROCESOS EN CURSO',
			'descr' => 'Muestra los procesos en curso con el usuario que lo ejecuta',
         'cmd' => '/opt/crawler/bin/libexec/mon_xagent -s /opt/data/xagent/base/apps/win32_app_wmi_process_list_running.vbs ',
         'params' => '[-i;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => '',   'enterprise'=>'0',
         'cfg' => '0',  'platform' => 'win32',   'script' => 'win32_app_wmi_process_list_running.vbs',   'format'=>0,
         'custom' => '0', 'aname'=> 'app_win32_processesrunning', 'res'=>1, 'ipparam'=>'[-i;IP;]',
			'apptype' => 'SO.WINDOWS',	'itil_type' => '1',
      );

//linux-app-os-open-files-per-process.sh
      $CFG_MONITOR_APPS[]=array(
         'type' => 'xagent', 'subtype'=>'LINUX', 'itil_type'=>'2',  'name'=>'LISTA DE FICHEROS ABIERTOS POR PID',
			'descr' => 'Muestra el numero de ficheros abiertos por cada uno de los procesos en curso (PIDS)',
         'cmd' => '/opt/crawler/bin/libexec/mon_xagent -s /opt/data/xagent/base/apps/linux_app_os_open_files_per_process.sh ',
         'params' => '[-i;IP;]',			'iptab'=>'1',	'ready'=>1,
         'myrange' => '',   'enterprise'=>'0',
         'cfg' => '0',  'platform' => 'linux',   'script' => 'linux_app_os_open_files_per_process.sh',   'format'=>0,
         'custom' => '0', 'aname'=> 'app_linux_filesopenpid', 'res'=>1, 'ipparam'=>'[-i;IP;]',
			'apptype' => 'SO.UNIX',	'itil_type' => '1',
		);

?>
