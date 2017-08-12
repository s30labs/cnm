<?php

//---------------------------------------------------------------------------------------------------------
// itil_type: operacion 1, configuracion 2, capacidad 3, disponibilidad 4, seguridad 5
// cfg: 0-> No instanciada, 1-> Instanciada

/*
Falta params,  params_descr, script, info
Quizas sea necesario platfform

*/

      // CASO ESPECIAL ---------------------------------------------------------------------
      $CFG_MONITOR_AGENT[]=array(
            'subtype' => 'mon_xagent',   'class' => 'cnm',  'description' => 'SIN RESPUESTA DEL AGENTE REMOTO',
            'apptype' => 'SO.LINUX',   'itil_type' => '1',
            'items' => '',        'vlabel' => '',      'mode' => '',
            'mtype' => 'STD_AREA',        'top_value' => '1',     'module' => 'mod_xagent_get',    'nparams' => '2',
            'params' => '[;Directorio;]:[;Patron;]',               'params_descr' => '',
            'script' => 'linux_metric_num_files_in_dir.sh',         'severity' => '1',
            'cfg' => '-1',  'custom' => '0',  'get_iid' => '0', 'proxy'=>0, 'proxy_type'=>'',
            'info' => '',  'lapse' => 300,   'include'=>1,
      );


//---------------------------------------------------------------------------------------------------------
// linux-os
// xagt_001000-xagt_001499
// cfg=1 => No configurado, cfg=2 => Si configurado
//---------------------------------------------------------------------------------------------------------
      $CFG_MONITOR_AGENT[]=array(
            'subtype' => 'xagt_001000',   'class' => 'linux-os',  'description' => 'NUMERO DE FICHEROS EN DIRECTORIO',
				'apptype' => 'SO.LINUX',	'itil_type' => '1',
            'items' => 'Num Ficheros',        'vlabel' => 'Num',      'mode' => 'GAUGE',
            'mtype' => 'STD_AREA',        'top_value' => '1',     'module' => 'mod_xagent_get',    'nparams' => '2',
            'params' => '[;Directorio;]:[;Patron;]',               'params_descr' => '',
            'script' => 'linux_metric_num_files_in_dir.sh',         'severity' => '1',
            'cfg' => '1',  'custom' => '0',  'get_iid' => '0', 'proxy'=>0, 'proxy_type'=>'',
				'info' => '',  'lapse' => 300,   'include'=>1,
      );


?>
