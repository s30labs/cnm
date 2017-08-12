<?php
//----------------------------------------------------------------------------------------
// subtype_cfg_report: Campo que permite cruzar con la tabla cfg_report
// id: Del item (debe ser unico para un mismo report)
// title: Titulo del item
// col,row: Numero de columnas,filas ocupadas
// type: Del item >>> 0:grid | 1: graph_line | 2: graph_bar | 3: graph_pie
// params: Parámetros adicionales del item:
// 	type 0
//       param:item_subtype => 0: grid sin ninguna cabecera
//       param:item_subtype => 1: grid con titulo
// 	type 2 
//       param:item_subtype => 0: barras básico
//       param:item_subtype => 1: barras apiladas
//       param:item_subtype => 2: multibarras
//
//			param:xaxis => 24h : leyenda del eje x poniendo las horas del día
//			param:xaxis => 7d  : leyenda del eje x poniendo los dias de la semana
//			param:xaxis => 12m : leyenda del eje x poniendo los meses del año
//    type 3 
//       param:item_subtype => 0: quesos básico

//		param:expand => none: El item no se expande
//		param:expand => print: El item se expande al imprimir la página
//		param:expand => screen_print: El item se expande al mostrar e imprimir la página
// posX,posY: 	Posicion del item en el lienzo
// 				posX: 15	200 400 600	
// 				posY: 90 375 675
// data_fx: Funcion que permite obtener los datos del item.
//----------------------------------------------------------------------------------------
$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000007',
   'id' => 'd1',
   'title' => 'Ticket de la alerta',
   'col' => '4',
   'row' => '2',
   'type' => '5',
   'draggable' => 'no',
   'posX' => '1',
   'posY' => '2',
   'data_fx' => 'alert_ticket',
   'params'=> 'item_subtype=0;expand=none;min_height=35mm',
);

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000007',
   'id' => 'd2',
   'title' => 'Métricas en alerta del dispositivo',
   'col' => '4',
   'row' => '2',
   'type' => '0',
   'draggable' => 'no',
   'posX' => '1',
   'posY' => '1',
   'data_fx' => 'grid_device_metrics_in_alert',
   'params'=> 'item_subtype=1;expand=screen_print;min_height=35mm',
);

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000007',
   'id' => 'd3',
   'title' => 'Ultimos tickets registrados de la misma alerta en el mismo dispositivo',
   'col' => '4',
   'row' => '2',
   'type' => '0',
   'draggable' => 'no',
   'posX' => '1',
   'posY' => '3',
   'data_fx' => 'grid_device_alert_previous_ticket',
   'params'=> 'item_subtype=1;expand=screen_print;min_height=35mm',
);

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000007',
   'id' => 'd4',
   'title' => 'Ocurrencias anteriores de la misma alerta en otros dispositivos',
   'col' => '4',
   'row' => '2',
   'type' => '0',
   'draggable' => 'no',
   'posX' => '1',
   'posY' => '4',
   'data_fx' => 'grid_same_alert_previous',
   'params'=> 'item_subtype=1;expand=screen_print;min_height=35mm',
);

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000007',
   'id' => 'd5',
   'title' => 'Respuestas a la alerta',
   'col' => '4',
   'row' => '2',
   'type' => '0',
   'draggable' => 'no',
   'posX' => '1',
   'posY' => '5',
   'data_fx' => 'grid_alert_response',
   'params'=> 'item_subtype=1;expand=screen_print;min_height=35mm',
);

?>
