<?php

	$GUI_CUSTOM_FIELDS = array(
		array(
			'gtable' => 'dispositivos',
         'gfield' => 'fname',
         'gsql' => 'concat(a.name,".",a.domain) as fname',
         'gtitle' => 'Nombre',
         'position' => '1',
         'status' => '1',
		),
      array(
         'gtable' => 'dispositivos',
         'gfield' => 'ip',
         'gsql' => 'a.ip',
         'gtitle' => 'IP',
         'position' => '2',
         'status' => '1',
      ),
      array(
         'gtable' => 'dispositivos',
         'gfield' => 'sysloc',
         'gsql' => 'a.sysloc',
         'gtitle' => 'Localizacion',
         'position' => '3',
         'status' => '1',
      ),
	);
?>
