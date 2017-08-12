<?php
include_once('inc/Store.php');

// ------------------------------------------------------------------------------
// inc/CNMAPI/Embed.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_metric_graph
// ------------------------------------------------------------------------------
// IN: 	id (Id de la alerta. Opcional)
//			Query string
// OUT:	Array con el resultado
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// http://10.2.254.222/onm/api/embed/metric_graph.php?id=12&sizex=200&sizey=200
// ------------------------------------------------------------------------------
// curl -ki "https://10.2.254.222/onm/api/1.0/embed/metric/12.json?sizex=400&sizey=200"
// ------------------------------------------------------------------------------
function api_get_metric_graph($id) {
   include_once('/var/www/html/tphp/class.TemplatePower.inc.php');

   $size_x    = (CNMUtils::get_param('sizex')!='')?CNMUtils::get_param('sizex')-20:'';
   if($size_x!='' AND $size_x<180) $size_x='400';

   $size_y    = (CNMUtils::get_param('sizey')!='')?CNMUtils::get_param('sizey')-52:'';
   if($size_y!='' AND $size_y<58) $size_y='130';

CNMUtils::info_log(__FILE__, __LINE__, "[API10] id=$id size_x=$size_x size_y=$size_y");

   $data = array('__ID_METRIC__'=>$id);
   $result = doQuery('metric',$data);
   $r = $result['obj'][0];
   $rrd_params = array(
      'subtype' => $r['subtype'],
      'type'    => $r['type'],
      'id_dev'  => $r['id_dev'],
      'label'   => $r['label'],
      'size_x'  => $size_x,
      'size_y'  => $size_y,
   );

   $info = array(
      'graph_type'     => 'metric',
      'last_timestamp' => 0,
      'id'             => $id,
      'lapse'          => 'custom',
      'lapse_start'    => time()-86400,
      'lapse_end'      => time(),
   );
   $rrd_data['base'] = flot($info);
   $rrd = array(
      'data'   => $rrd_data,
      'params' => $rrd_params
   );
   $json_data = json_encode($rrd);

   $array_tpl = array('json_data'=>$json_data);
   new template('embed/metric_graph.shtml',$array_tpl);
}



?>
