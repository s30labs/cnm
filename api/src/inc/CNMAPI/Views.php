<?php

// ------------------------------------------------------------------------------
// inc/CNMAPI/Views.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_views
// ------------------------------------------------------------------------------
// IN: 	id (Id de la vista. Opcional)
//			Query string
// OUT:	Array con el resultado
// ------------------------------------------------------------------------------
// Obtener información de una vista o el listado de vistas
// ------------------------------------------------------------------------------
// Para obtener todos las vistas:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/views.json"
// Para obtener una vista concreta:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/views/12.json"
// ------------------------------------------------------------------------------
function api_get_views($id) {
   $params  = array();
   foreach($_GET as $key => $val){
      if($key=='endpoint' or $key=='content_type') continue;
      $params[$key]=$val;
   }
	// Obtener una vista concreta
	if($id>0){
		$params['id'] = $id;
	}
	// Obtener todos las vistas
	else{
	}
/*
   $params = array(
      'type' => CNMUtils::get_param('type'),
      'sev'  => CNMUtils::get_param('sev'),
      'id'  => $id,
   );
*/

   CNMUtils::info_log(__FILE__, __LINE__, "[API10] api_get_views >> ID=$id");

   $table  = common_views_get_table(3,$params);
   $return = grid2array($table,1);
   return $return;
//   echo json_encode($return);
}



// ------------------------------------------------------------------------------
// api_get_views_metrics
// ------------------------------------------------------------------------------
// IN:   id (Id de la vista. Opcional)
//       Query string
// OUT:  Array con el resultado
// ------------------------------------------------------------------------------
// Obtener las métricas de una vista
// ------------------------------------------------------------------------------
// Para obtener una vista concreta:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/views/27/metrics.json"
// Para obtener una vista concreta con parámetros de filtrado de los elementos:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/views/27/metrics.json?type=snmp"
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/views/27/metrics.json?type=latency&count=10"
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/views/27/metrics.json?id=>2"
// ------------------------------------------------------------------------------
// Campos de filtrado:
//   - metricid         => id de la métrica
//   - metricname       => nombre de la métrica
//   - metrictype       => tipo de la métrica
//   - metricitems      => items de la métrica
//   - metricstatus     => estado de la métrica

//   - devicename       => nombre del dispositivo
//   - devicedomain     => dominio del dispositivo
//   - devicestatus     => estado del dispositivo
//   - devicetype       => tipo del dispositivo
//   - deviceid         => id del dispositivo
//   - deviceip         => ip del dispositivo

//   - monitorid        => id del monitor
//   - monitorname      => nombre del monitor
//   - monitorsevred    => condición del monitor para que la métrica produzca una alerta roja
//   - monitorsevorange => condición del monitor para que la métrica produzca una alerta naranja
//   - monitorsevyellow => condición del monitor para que la métrica produzca una alerta amarilla

//   - viewname         => nombre de la vista
//   - viewid           => id de la vista
//   - viewtype         => tipo de la vista


// ------------------------------------------------------------------------------
function api_get_views_metrics($id) {
   CNMUtils::info_log(__FILE__, __LINE__, "[API10] api_get_views_metrics >> ID=$id");

   $extra_params = array();
   $extra_params['posStart']    = (CNMUtils::get_param('posStart')!='')?CNMUtils::get_param('posStart'):0;
   $extra_params['count']       = (CNMUtils::get_param('count')!='')?CNMUtils::get_param('count'):1000000;
   $extra_params['orderby']     = CNMUtils::get_param('orderby');
   $extra_params['direct']      = CNMUtils::get_param('direct');

   // Filtros que ha puesto el usuario
   $params  = array();
   foreach($_GET as $key => $val){
      if($key=='endpoint' or $key=='content_type' or $key=='posStart' or $key=='count' or $key=='orderby' or $key=='direct') continue;
      $params[$key]=$val;
   }
/*
	// Obtener una vista concreta
   if ($id>0) {
		$params['id'] = $id; 
	}
	// Obtener todos las vistas
	else{

	}
*/

   $table = common_views_get_metrics(3,$id,$params,$extra_params);
   $return = grid2array($table,1);
   return $return;
//   echo json_encode($return);
}


// ------------------------------------------------------------------------------
// api_get_views_remote_alerts
// ------------------------------------------------------------------------------
// IN:   id (Id de la vista)
//       Query string
// OUT:  Array con el resultado
// ------------------------------------------------------------------------------
// Obtener las alertas remotas de una vista
// ------------------------------------------------------------------------------
// Para obtener una vista concreta:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/views/27/remote.json"
// Para obtener una vista concreta con parámetros de filtrado de los elementos:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/views/27/remote.json?type=email"
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/views/27/remote.json?id=>1300"
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/views/27/remote.json?deviceid=1&count=5"
// ------------------------------------------------------------------------------
// Campos de filtrado:
//   - id
//   - name
//   - type
//   - deviceid
//   - deviceip
// ------------------------------------------------------------------------------
function api_get_views_remote_alerts($id) {

   CNMUtils::info_log(__FILE__, __LINE__, "[API10] api_get_views_remote_alerts >> ID=$id");

   $extra_params = array();
   $extra_params['posStart']    = (CNMUtils::get_param('posStart')!='')?CNMUtils::get_param('posStart'):0;
   $extra_params['count']       = (CNMUtils::get_param('count')!='')?CNMUtils::get_param('count'):1000000;
   $extra_params['orderby']     = CNMUtils::get_param('orderby');
   $extra_params['direct']      = CNMUtils::get_param('direct');

   // Filtros que ha puesto el usuario
   $params  = array();
   foreach($_GET as $key => $val){
      if($key=='endpoint' or $key=='content_type' or $key=='posStart' or $key=='count' or $key=='orderby' or $key=='direct') continue;
      $params[$key]=$val;
   }

   $table = common_views_get_remote_alerts(3,$id,$params,$extra_params);
   $return = grid2array($table,1);
   return $return;
//   echo json_encode($return);
}


// ------------------------------------------------------------------------------
// api_get_views_searchitems
// ------------------------------------------------------------------------------
// IN: id de la vista
//     id de la busqueda almacenada
// ------------------------------------------------------------------------------
// OUT: Array con el resultado
// ------------------------------------------------------------------------------
// Obtiene los elementos asociados a una búsqueda almacenada de una vista
// ------------------------------------------------------------------------------
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/views/12/search/23.json"
// ------------------------------------------------------------------------------
function api_get_views_searchitems($id_cfg_view,$id_search_store) {

   CNMUtils::info_log(__FILE__, __LINE__, "[API10] api_get_views_searchitems >> IDView=$id_cfg_view IDSearch=$id_search_store");

   $return = get_elements_search_store_view($id_cfg_view,$id_search_store);
   return $return;
// echo json_encode($return);
}


// ------------------------------------------------------------------------------
// api_put_views_search
// ------------------------------------------------------------------------------
// IN: id de la vista dinámica (dejar vacio para todas las vistas dinámicas)
// ------------------------------------------------------------------------------
// OUT: 
// ------------------------------------------------------------------------------
// Regenera los elementos (métricas y alertas remotas) asociados a todas las vistas dinámicas o a la vista dinámica que indiquemos
// ------------------------------------------------------------------------------
// Regenerar los elementos asociados a todas las vistas dinámicas:
// curl -ki  -H "Authorization: e4f25e3120bee35b411e3af29a088d02" -X PUT "https://10.2.254.222/onm/api/1.0/views/search.json"
// Regenerar los elementos asociados a una vista dinámica en concreto:
// curl -ki  -H "Authorization: e4f25e3120bee35b411e3af29a088d02" -X PUT "https://10.2.254.222/onm/api/1.0/views/12/search.json"
// ------------------------------------------------------------------------------
function api_put_views_search($id='') {
   $a_id_cfg_view = array();
   if($id!='') $a_id_cfg_view = explode(',',$id);

   CNMUtils::info_log(__FILE__, __LINE__, "[API10] api_put_views_search >> ID=$id");

   $return = common_views_update_live($a_id_cfg_view);
   return $return;
//   echo json_encode($return);
}



// ------------------------------------------------------------------------------
// api_put_views_renew
// ------------------------------------------------------------------------------
// IN: 
// ------------------------------------------------------------------------------
// OUT: 
// ------------------------------------------------------------------------------
// Regenera los elementos (métricas y alertas remotas) asociados a todas las vistas
// ------------------------------------------------------------------------------
// Regenerar los elementos asociados a todas las vistas:
// curl -ki  -H "Authorization: e4f25e3120bee35b411e3af29a088d02" -X PUT "https://10.2.254.222/onm/api/1.0/views/all.json"
// ------------------------------------------------------------------------------
function api_put_views_renew() {
   CNMUtils::info_log(__FILE__, __LINE__, "[API10] api_put_views_renew");
   $return = common_views_renew();
   return $return;
}

?>
