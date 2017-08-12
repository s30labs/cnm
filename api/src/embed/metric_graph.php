<?php
include_once('inc/Store.php');
include_once('inc/CNMUtils.php');
include_once('sql/mod_Configure.sql');
include_once('inc/CNMAPI.php');

$dbc=CNMAPI::connectDB();
open();

/*
<iframe src=http://10.2.254.222/onm/api/embed/metric_graph.php?id=1424&sizex=200&sizey=130 width="200" height="130" frameBorder="0">
Error: Embedded data could not be displayed.
</iframe>
// sizey: valor mínimo 110. Se recomienda 130
// sizex: valor mínimo 200. Se recomienda 400
*/
function open(){
	$id_metric = CNMUtils::get_param('id');

	$size_x    = (CNMUtils::get_param('sizex')!='')?CNMUtils::get_param('sizex')-20:'';
	if($size_x!='' AND $size_x<180) $size_x='400';

	$size_y    = (CNMUtils::get_param('sizey')!='')?CNMUtils::get_param('sizey')-52:'';
	if($size_y!='' AND $size_y<58) $size_y='130';

	$data = array('__ID_METRIC__'=>$id_metric);
	$result = doQuery('metric',$data);
	$r = $result['obj'][0];
   $rrd_params = array(
      'subtype' => $r['subtype'],
      'type'    => $r['type'],
      'id_dev'  => $r['id_dev'],
		'label'   => $r['label'],
		'size_x'  => $size_x.'px',
		'size_y'  => $size_y.'px',
   );

	$info = array(
      'graph_type'     => 'metric',
      'last_timestamp' => 0,
		'id'             => $id_metric,
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
   new template('metric_graph.shtml',$array_tpl);
}

?>
