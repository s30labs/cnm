<?php
//----------------------------------------------------------------------------------------
// subtype_cfg_report: Campo que permite cruzar con la tabla cfg_report
// id: Del item (debe ser unico para un mismo report)
// title: Titulo del item
// col,row: Numero de columnas,filas ocupadas
// type: Del item >>> 0:grid | 1: graph_line | 2: graph_bar | 3: graph_pie | 4: graph_rrd
// params: Parámetros adicionales del item:
//    type 0 
//       param:item_subtype => 0: grid sin ninguna cabecera
//       param:item_subtype => 1: grid con titulo
//    type 2 
//       param:item_subtype => 0: barras básico
//       param:item_subtype => 1: barras apiladas
//       param:item_subtype => 2: multibarras
//    type 3  
//       param:item_subtype => 0: quesos básico
//    type 4
//       param:item_subtype => metric: gráfica de métrica
//       param:item_subtype => subtype: gráfica de subvista
   
//    param:expand => 0: El item no se expande al imprimir la página
//    param:expand => 1: El item se expande al imprimir la página
// posX,posY: Posicion del item en el lienzo
// data_fx: Funcion que permite obtener los datos del item.
//----------------------------------------------------------------------------------------

/*
$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000100',
   'id' => 'd_1',
   'title' => 'Dispositivos por tipo',
   'col' => '1',
   'row' => '2',
   'type' => '0',
   'draggable' => '0',
   'posX' => '1',
   'posY' => '1',
   'data_fx' => 'get_devices_by_type',
   'params'=> 'item_subtype=0;expand=none',
);

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000100',
   'id' => 'd_2',
   'title' => 'Dispositivos por estado',
   'col' => '1',
   'row' => '2',
   'type' => '3',
   'draggable' => '0',
   'posX' => '2',
   'posY' => '1',
   'data_fx' => 'get_devices_by_status_pie',
	'params'=> 'item_subtype=0;expand=none',
);

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000100',
   'id' => 'd_3',
   'title' => 'Métricas por tipo',
   'col' => '1',
   'row' => '2',
   'type' => '0',
   'draggable' => '0',
   'posX' => '3',
   'posY' => '1',
   'data_fx' => 'get_metrics_by_type',
   'params'=> 'item_subtype=0;expand=none',
);

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000100',
   'id' => 'd_4',
   'title' => 'Métricas por estado',
   'col' => '1',
   'row' => '2',
   'type' => '0',
   'draggable' => '0',
   'posX' => '4',
   'posY' => '1',
   'data_fx' => 'get_metrics_by_status',
   'params'=> 'item_subtype=0;expand=none',
);
*/

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000100',
   'id' => 'd_1',
   'title' => 'Aplicaciones en curso',
   'col' => '4',
   'row' => '2',
   'type' => '0',
   'draggable' => '0',
   'posX' => '1',
   'posY' => '1',
   // 'data_fx' => 'get_cnm_version',
   'data_fx' => 'get_cnm_running_tasks',
   'params'=> 'item_subtype=0;expand=none',
);
$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000100',
   'id' => 'd_2',
   'title' => 'Procesos en curso',
   'col' => '4',
   'row' => '2',
   'type' => '0',
   'draggable' => '0',
   'posX' => '1',
   'posY' => '2',
   // 'data_fx' => 'get_cnm_version',
   'data_fx' => 'get_cnm_running_procs',
   'params'=> 'item_subtype=0;expand=none',
);

?>
