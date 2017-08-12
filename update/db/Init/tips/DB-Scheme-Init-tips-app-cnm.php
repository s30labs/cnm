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
         'id_ref' => 'app_cnm_csv_view_metrics',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong>Obtiene el inventario de las metricas asociadas a vistas definidas en el sistema gestor</strong><br>'
      );
      $TIPS[]=array(
         'id_ref' => 'app_cnm_audit',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong>Escanea el rango de red especificado en busca de equipos</strong><br>'
      );
      $TIPS[]=array(
         'id_ref' => 'app_cnm_backup',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong>Realiza el backup de los datos del sistema CNM</strong><br>'
      );
      $TIPS[]=array(
         'id_ref' => 'app_cnm_restore',          'tip_type' => 'app',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => '<strong>Realiza el restore de datos del sistema CNM. Puede ser desde un backup local o desde un backup remoto de otro CNM. En este caso, primero obtiene el bacup por SSH u posteriormente restaura datos.</strong><br>'
      );

?>
