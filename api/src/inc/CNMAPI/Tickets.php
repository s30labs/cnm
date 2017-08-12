<?php

// ------------------------------------------------------------------------------
// inc/CNMAPI/Tickets.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_tickets
// ------------------------------------------------------------------------------
// IN: 	id (Id del ticket. Opcional)
//			Query string
// OUT:	Array con el resultado
// ------------------------------------------------------------------------------
// Para obtener todos los tickets:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api/1.0/tickets.json"
// Para obtener un dispositivo:
// curl -ki -H "Authorization: 5cbe57d976f99dc436f82653ce6d1314" "https://localhost/onm/api.0/tickets/2.json"
// ------------------------------------------------------------------------------
function api_get_tickets($id) {


   $extra_params = array();
   $extra_params['posStart']    = (CNMUtils::get_param('posStart')!='')?CNMUtils::get_param('posStart'):0;
   $extra_params['count']       = (CNMUtils::get_param('count')!='')?CNMUtils::get_param('count'):1000000;
   $extra_params['orderby']     = CNMUtils::get_param('orderby');
   $extra_params['direct']      = CNMUtils::get_param('direct');

   // Filtros que ha puesto el usuario
   $params  = array();
   foreach($_GET as $key => $val){
      if($key=='endpoint' or $key=='content_type') continue;
		$params[$key]=(strpos($val,',')===false)?$val:explode(',',$val);
   }
   if ($id>0) { $params['id'] = $id; }

/*
Campos:
   - id                       => id del ticket
   - alert                    => id de la alerta
   - category                 => categoría del ticket
   - description              => descripción del ticket
   - ticket                   => id externo del ticket introducido por el usuario
   - user                     => usuario que ha generado el ticket
   - type                     => alerts si el ticket está asociado a una alerta activa | store si el ticket está asociado a una alerta del histórico
   - devicename               => nombre del dispositivo
   - deviceip                 => ip del dispositivo
   - devicedomain             => dominio del dispositivo
   - alertdatelast_human      => fecha de la ultima actualización de la alerta
   - alertdatelast_timestamp  => timestamp de la última actualización de la alerta
   - alertdatefirst_human     => fecha de la creación de la alerta
   - alertdatefirst_timestamp => timestamp de la creación de la alerta
   - alertcounter             => contador de la alerta
   - alerttype                => tipo de la alerta
   - alertack                 => 0: no tiene ack | 1: ack verde | 2: ack azul | 3: ack rojo | 4: ack naranja | 5: ack amarillo
   - alertseverity            => severidad de la alerta (1: alerta roja | 2: alerta naranja | 3: alerta amarilla)
   - alertcause               => causa de la alerta


URL: http://10.2.254.222/onm/api/tickets/get.php?PHPSESSID=56eadf6d5ad2f270035576447466a555&params={"devicename":"cnm-devel"}
     http://10.2.254.222/onm/api/tickets/get.php?PHPSESSID=56eadf6d5ad2f270035576447466a555&params={"id":"<2"}
     http://10.2.254.222/onm/api/tickets/get.php?PHPSESSID=56eadf6d5ad2f270035576447466a555&params={"id":1}
     http://10.2.254.222/onm/api/tickets/get.php?PHPSESSID=56eadf6d5ad2f270035576447466a555&params={"user":"admin"}
*/


   $table  = common_tickets_get_table(3,$params,$extra_params);
   $return = grid2array($table,1);
   return $return;
}



?>
