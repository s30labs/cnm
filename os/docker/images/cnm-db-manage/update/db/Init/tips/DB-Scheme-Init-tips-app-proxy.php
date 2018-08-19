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
         'id_ref' => 'app_gconf_telnet_comtrend',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong>Obtiene la configuracion de routers Comtrend</strong><br>'
      );
      $TIPS[]=array(
         'id_ref' => 'app_gconf_telnet_cisco',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong>Obtiene la configuracion de equipos con CISCO IOS</strong><br>'
      );
      $TIPS[]=array(
         'id_ref' => 'app_gconf_check',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong>Obtiene los cambios entre los diferentes ficheros de configuracion almacenados</strong><br>'
      );

?>
