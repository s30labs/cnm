<?php

// ------------------------------------------------------------------------------
// inc/CNMAPI/Metrics.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_metrics
// ------------------------------------------------------------------------------
// IN: 	id (Id de la metrica. Opcional)
//			Query string
// OUT:	Array con el resultado
// ------------------------------------------------------------------------------
// Para obtener todos las metricas:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/info/metrics.json"
// Para obtener una metrica concreta:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/info/metrics/2332.json"
// ------------------------------------------------------------------------------
function api_get_metrics($id=0) {

   $extra_params = array();
   $extra_params['posStart']    = (CNMUtils::get_param('posStart')!='')?CNMUtils::get_param('posStart'):0;
   $extra_params['count']       = (CNMUtils::get_param('count')!='')?CNMUtils::get_param('count'):1000000;
   $extra_params['orderby']     = CNMUtils::get_param('orderby');
   $extra_params['direct']      = CNMUtils::get_param('direct');

   // Filtros que ha puesto el usuario
   $params  = array();
   foreach($_GET as $key => $val){
      if($key=='endpoint' or $key=='content_type') continue;
      $params[$key]=$val;
   }
   if ($id>0) { $params['id'] = "=$id"; }
/*
Campos:
	// - id              => id de la metrica
	// - name            => nombre de la métrica
	// - type            => tipo de la métrica
	// - items           => items de la métrica
	// - deviceid        => id del dispositivo
	// - deviceip        => ip del dispositivo
	// - devicename      => nombre del dispositivo
	// - devicedomain    => dominio del dispositivo
	// - devicestatus    => estado del dispositivo
	// - devicetype      => tipo del dispositivo
	// - monitorid       => id del monitor
	// - monitorname     => nombre del monitor
	// - severityred     => condición del monitor para que la métrica produzca una alerta roja
	// - severityorange  => condición del monitor para que la métrica produzca una alerta naranja
	// - severityyellow  => condición del monitor para que la métrica produzca una alerta amarilla

Comando: curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "http://localhost/onm/api/1.0/info/metrics.json?monitorname=SERVICIO"
*/

   $table  = common_metrics_get_table(3,$params,$extra_params);
   $return = grid2array($table,1);
   return $return;
//   echo json_encode($return);
}


// ------------------------------------------------------------------------------
// api_get_metric_rrd
// ------------------------------------------------------------------------------
// IN:   id_metric (Id de la metrica)
//			Por GET: lapse (periodo del que se quiere obtener valores)
// OUT:  Array con el resultado
// ------------------------------------------------------------------------------
// Para obtener valores de una metrica:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/metrics/2332/week.json"
// Lapses validos:
// - year
// - month
// - week
// - today
// - hour
// - minute
// - day_[n] siendo n un valor entero mayor que 0 e indica los valores de hace n días (y 24 horas)
// - hour_[n] siendo n un valor entero mayor que 0 e indica los valores de hace n horas (y 60 minutos)
// - minute_[n] siendo n un valor entero mayor que 0 e indica los valores de hace n minutos (y 60 segundos)
// ------------------------------------------------------------------------------
// curl -ki -H "Authorization: 008de81a28fbf801120c99a1abfb271d" "https://localhost/onm/api/1.0/metrics/12/today.json"
// ------------------------------------------------------------------------------
function api_get_metric_rrd($id_metric){
	$lapse = 'all';
	if(array_key_exists('lapse',$_GET)) $lapse = $_GET['lapse'];
	$params = array('graph_type'=>'metric','lapse'=>$lapse,'id'=>$id_metric);
	$return = flot($params);
	return $return;
}
?>
