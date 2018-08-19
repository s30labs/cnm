<?php
//----------------------------------------------------------------------------------------
// subtype_cfg_report: Campo que permite cruzar con la tabla cfg_report
// id: Del item (debe ser unico para un mismo report)
// title: Titulo del item
// col,row: Numero de columnas,filas ocupadas
// type: Del item >>> 0:grid | 1: graph_line | 2: graph_bar | 3: graph_pie
// params: Parámetros adicionales del item:
// 	type 0 (grid)
//       param:item_subtype => 0: grid sin ninguna cabecera
//       param:item_subtype => 1: grid con titulo
// 	type 2 (graph_bar)
//       param:item_subtype => 0: barras básico
//       param:item_subtype => 1: barras apiladas
//       param:item_subtype => 2: multibarras
//
//			param:xaxis => 24h : leyenda del eje x poniendo las horas del día
//			param:xaxis => 7d  : leyenda del eje x poniendo los dias de la semana
//			param:xaxis => 12m : leyenda del eje x poniendo los meses del año
//    type 3 (graph_pie)
//       param:item_subtype => 0: quesos básico

//		param:expand => none: El item no se expande
//		param:expand => print: El item se expande al imprimir la página
//		param:expand => screen_print: El item se expande al mostrar e imprimir la página
//		param:min_height => En caso de utilizarlo será la altura mínima que tendrá el grid:
//		para row1 28mm
//		     row2 68mm
// posX,posY: 	Posicion del item en el lienzo
// 				posX: 15	200 400 600	
// 				posY: 90 375 675 975 1275
// data_fx: Funcion que permite obtener los datos del item.
//----------------------------------------------------------------------------------------


/*
$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000001',
   'id' => 'r1',
   'title' => 'Distribución de alertas a lo largo del periodo',
   'col' => '4',
   'row' => '2',
   'type' => '2',
   'draggable' => '0',
   'posX' => '1',
   'posY' => '1',
   'data_fx' => 'get_alerts_bar',
	'params'=> 'item_subtype=1;expand=none;xaxis=24h',
);

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000001',
   'id' => 'r2',
   'title' => 'Alertas por severidad',
   'col' => '1',
   'row' => '2',
   'type' => '3', 
   'draggable' => '0',
   'posX' => '3',
   'posY' => '2',
   'data_fx' => 'pie_alert_severity',
	'params'=> 'item_subtype=0;expand=none',
);

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000001',
   'id' => 'r3',
   'title' => 'Alertas por ACK',
   'col' => '1',
   'row' => '2',
   'type' => '3', 
   'draggable' => '0',
   'posX' => '4',
   'posY' => '2',
   'data_fx' => 'pie_alert_ack',
	'params'=> 'item_subtype=0;expand=none',
);

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000001',
   'id' => 'r4',
   'title' => 'Alertas agrupadas por dispositivo',
   'col' => '4',
   'row' => '1',
   'type' => '0', 
   'draggable' => '0',
   'posX' => '1',
   'posY' => '5',
   'data_fx' => 'grid_alert_device',
   'params'=> 'item_subtype=1;expand=screen_print',
);


$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000001',
   'id' => 'r5',
   'title' => 'Alertas agrupadas por tipo de dispositivo',
   'col' => '4',
   'row' => '1',
   'type' => '0', 
   'draggable' => '0',
   'posX' => '1',
   'posY' => '4',
   'data_fx' => 'grid_alert_device_type',
   'params'=> 'item_subtype=1;expand=screen_print',
);

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000001',
   'id' => 'r6',
   'title' => 'Alertas por tipo de métrica',
   'col' => '1',
   'row' => '2',
   'type' => '3',
   'draggable' => '0',
   'posX' => '1',
   'posY' => '2',
   'data_fx' => 'pie_alert_mtype',
   'params'=> 'item_subtype=0;expand=none',
);

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000001',
   'id' => 'r7',
   'title' => 'Alertas por ticket',
   'col' => '1',
   'row' => '2',
   'type' => '3',
   'draggable' => '0',
   'posX' => '2',
   'posY' => '2',
   'data_fx' => 'pie_alert_ticket',
   'params'=> 'item_subtype=0;expand=none',
);

$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000001',
   'id' => 'r8',
   'title' => 'Alertas agrupadas por causa',
   'col' => '4',
   'row' => '1',
   'type' => '0', 
   'draggable' => '0',
   'posX' => '1',
   'posY' => '3',
   'data_fx' => 'grid_alert_cause',
	'params'=> 'item_subtype=1;expand=screen_print',
);

*/

/*
$CFG_REPORT2ITEM[]=array(
   'subtype_cfg_report' => '00000001',
   'id' => 'r9',
   'title' => 'Detalle de alertas',
   'col' => '4',
   'row' => '1',
   // 'type' => '4', // 0:grid | 1: graph_line | 2: graph_bar | 3: graph_pie | 4: grid_title
   'type' => '0', // 0:grid | 1: graph_line | 2: graph_bar | 3: graph_pie | 4: grid_title
   'draggable' => '0',
   'posX' => '15',
   // 'posY' => '675',
   'posY' => '1275',
   'data_fx' => 'grid_alert_date',
	'params'=> 'item_subtype=1;expand=screen_print',
	// 'params'=> 'item_subtype=1;expand=none',
	// 'params'=> 'item_subtype=1;expand=screen',
);
*/

?>
