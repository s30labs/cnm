<?php

// ------------------------------------------------------------------------------
// inc/CNMAPI/Reports.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_reports
// ------------------------------------------------------------------------------
// IN: 	id (Id del report. Opcional)
//       view -> Id de la vista
//			from y to
// OUT:	Fichero excel
// ------------------------------------------------------------------------------
// Para obtener todas las alertas:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/reports.json"
// Para obtener una alerta concreta:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api.0/reports/17645.json"
// ------------------------------------------------------------------------------
function api_get_reports($id) {
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

//$fichero = '/tmp/metricDisco.xlsx';
$fichero = '/tmp/texto';

if (file_exists($fichero)) {
    header('Content-Description: File Transfer');
    header('Content-Type: application/octet-stream');
    header('Content-Disposition: attachment; filename="'.basename($fichero).'"');
    header('Expires: 0');
    header('Cache-Control: must-revalidate');
    header('Pragma: public');
    header('Content-Length: ' . filesize($fichero));
    readfile($fichero);
    return;
}


}


?>
