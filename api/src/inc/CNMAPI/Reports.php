<?php

// ------------------------------------------------------------------------------
// inc/CNMAPI/Reports.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_report
// ------------------------------------------------------------------------------
// IN: 	type ->  tipo del report
//       view ->  id de la vista
//       label -> nombre de la vista
// OUT:	Fichero excel
// ------------------------------------------------------------------------------
// Para obtener el report de capidad de la vista con id 1
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/reports/capacity/1.json"
// ------------------------------------------------------------------------------
function api_get_report($type,$id,$label) {
//   include_once('inc/class.cnmlist.php');

   // /// //
   // GET //
   // /// //
/*   $params  = array();
   foreach($_GET as $key => $value){
      if($key=='endpoint' or $key=='content_type') continue;
      // En caso de tener espacios el nombre se maneja
      if($key=='form' and is_array($value)){
         foreach($value as $k=>$v) $list->set_field($k,$v);
      }
      else{
         $list->set_field($key,$value);
         $params[$key]=$value;
      }
   }

   if ($id>0) $list->set_field('id',$id);

   $return = $list->show('array');
*/

	if($type=='capacity'){

  	 	$fichero = 'CNM-CapacityReport-'.$label.'-'.date("Y-m-d").'.xlsx';
  	 	$cmd     = "/opt/cnm/crawler/bin/get-capacity-report -view $id -file \"$fichero\"";
		CNMUtils::info_log(__FILE__, __LINE__, "cmd=$cmd");
		exec($cmd);
	
		if (file_exists($fichero)) {
		    header('Content-Description: File Transfer');
		    header('Content-Type: application/octet-stream');
		    header('Content-Disposition: attachment; filename="'.basename($fichero).'"');
		    header('Expires: 0');
		    header('Cache-Control: must-revalidate');
		    header('Pragma: public');
		    header('Content-Length: ' . filesize($fichero));
		    readfile($fichero);
			 unlink($fichero);
		    return;
		}

	}
}


?>
