<?php

// ------------------------------------------------------------------------------
// inc/CNMAPI/Alerts.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_alerts
// ------------------------------------------------------------------------------
// IN: 	id (Id de la alerta. Opcional)
//			Query string
// OUT:	Array con el resultado
// ------------------------------------------------------------------------------
// Para obtener todas las alertas:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/alerts.json"
// Para obtener una alerta concreta:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api.0/alerts/17645.json"
// ------------------------------------------------------------------------------
function api_get_alerts($id) {
   include_once('inc/class.cnmlist.php');

   $list = New cnmlist('alerts');

   // /// //
   // GET //
   // /// //
   $params  = array();
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
   return $return;
}

/*
function api_get_alerts($id) {
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
   if ($id>0) { $params['id'] = $id; }


Campos:
   - id
   - ack
   - ticket
   - severity
   - critic
   - type
   - date
   - devicename
   - devicedomain
   - deviceip
   - cause
   - counter
   - event
   - lastupdate

URL: http://10.2.254.222/onm/api/alerts/get.php?PHPSESSID=56eadf6d5ad2f270035576447466a555&params={"devicename":"cnm-devel"}
     http://10.2.254.222/onm/api/alerts/get.php?PHPSESSID=56eadf6d5ad2f270035576447466a555&params={"id":"<2"}
     http://10.2.254.222/onm/api/alerts/get.php?PHPSESSID=56eadf6d5ad2f270035576447466a555&params={"id":1}
     http://10.2.254.222/onm/api/alerts/get.php?PHPSESSID=56eadf6d5ad2f270035576447466a555&params={"id":">183297"}

   $table  = common_alerts_get_table(3,$params,$extra_params);
   $return = grid2array($table,1);
   return $return;
//   echo json_encode($return);
}
*/

// ------------------------------------------------------------------------------
// api_delete_alerts
// ------------------------------------------------------------------------------
// IN: 	id (Id de la alerta)
// OUT:	Array con el resultado
// ------------------------------------------------------------------------------
// Para obtener una alerta concreta:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" -X DELETE "https://localhost/onm/api.0/alerts/12.json"
// ------------------------------------------------------------------------------
function api_delete_alerts($id) {
   include_once('inc/class.cnmalert.php');

   $a_res = cnmalert::del($id);
   return $a_res;
}
?>
