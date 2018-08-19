<?php
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
// tip_class=0 => De usuario tip_class=1 => De sistema (no se edita ni se borra)
//---------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------
//	Reports (analisis)
// El id_ref es el subtype_cfg_report
//---------------------------------------------------------------------------------------------------------

      $TIPS[]=array(
         'id_ref' => '00000001',          'tip_type' => 'report',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'id = 00000001<br>Informe ejecutivo de alertas producidas<br>'
      );
      $TIPS[]=array(
         'id_ref' => '00000004',          'tip_type' => 'report',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'id = 00000004<br>Informe detallado de las alertas producidas.<br>'
      );
      $TIPS[]=array(
         'id_ref' => '00000005',          'tip_type' => 'report',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'id = 00000005<br>Informe de disponibilidad de las alertas y dispositivos indicados.<br>'
      );
?>
