<?php
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
// tip_class=0 => De usuario tip_class=1 => De sistema (no se edita ni se borra)
//---------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------
//	Aplicacion
// El id_ref coincide con el aname de la aplicacion
//---------------------------------------------------------------------------------------------------------

      $TIPS[]=array(
         'id_ref' => 'app_win32_processesrunning',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong>Muestra los procesos en curso con el usuario que lo ejecuta</strong><br>'
      );
      $TIPS[]=array(
         'id_ref' => 'app_linux_filesopenpid',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong>Muestra el numero de ficheros abiertos por cada uno de los procesos en curso (PIDS)</strong><br>'
      );

/*
      $TIPS[]=array(
         'id_ref' => '',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong></strong><br>'
      );

*/

?>
