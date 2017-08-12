<?php

// ------------------------------------------------------------------------------
// inc/CNMAPI/Events.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_post_events
// ------------------------------------------------------------------------------
// IN: 	
// OUT
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X POST => BASE
// "https://localhost/onm/api/1.0/events.json" -F "deviceid=1" -F "msg=TEST" -F "evkey=0001"
// "https://localhost/onm/api/1.0/events.json" -F "deviceip=10.2.254.223" -F "msg=TEST" -F "evkey=0001"
// "https://localhost/onm/api/1.0/events.json" -F "devicename=cnm-devel2" -F "devicedomain=s30labsi.com" -F "msg=TEST" -F "evkey=0001"
// "https://localhost/onm/api/1.0/events.json" -F "msg=TEST" -F "evkey=0001"
// "https://localhost/onm/api/1.0/events.json" -F "msg=TEST"
// "https://localhost/onm/api/1.0/events.json" -F "msg=TEST" -F "form[campo1]=valor1" -F "form[campo2]=valor2"
//
// Campos disponibles:
// - deviceid: id del dispositivo sobre el que se genera el evento
// - deviceip: direccion ip del dispositivo sobre el que se genera el evento
// - devicename: nombre con el que esta dado de alta en CNM el dispositivo sobre el que se genera el evento
// - devicedomain: dominio del dispositivo sobre el que se genera el evento
// - msg: mensaje del evento.
// - evkey: clave del evento. En caso de no indicarlos se genera uno internamente
// - Campos de usuario: añade una estructura json con los campos de usuario en el campo mensaje
//
// Campos necesarios:
// - deviceid | deviceip | devicename + devicedomain | nada (en caso de no poner datos del dispositivo, se asocia a la dirección ip de la que se
//   ejecuta la llamada al API)
// - msg | campos de usuario
// 
// Nota: Los campos de usuario NO hay que darlos previamente de alta en CNM.
//
// Descripcion: Crea un evento en CNM. 

/*
mysql> select * from events limit 1\G
*************************** 1. row ***************************
  id_event: 1322309
  name: cnm-devel                                          => entrada
  domain: s30labsi.com                                     => entrada
  ip: 10.2.254.222                                         => entrada
  date: 1390602684
  code: 1
  proccess: TRAP-SNMP                                      => Será API siempre
  msg:                                                     => entrada 
CNM-NOTIFICATIONS-MIB::cnmNotifCode.1 = INTEGER:
1|CNM-NOTIFICATIONS-MIB::cnmNotifMsg.2 = STRING:
"NT_STATUS_HOST_UNREACHABLE - NT_STATUS_HOST_UNREACHABLE "
msg_custom:                                                => Se ignora
  evkey: CNM-NOTIFICATIONS-MIB::cnmNotifLogFileGetErrorSet => entrada o se calcula en caso de no introducirse (un hash)
 id_dev: 1                                                 => entrada.Se calcula en base a la ip.
1 row in set (0.02 sec)

opción1: solo ip, se calcula nombre, dominio e id_dev
opción2: solo id_dev, se calcula nombre, dominio e ip
opción3: tanto nombre como dominio, se calcula ip e id_dev
opción4: en caso de no exista ningún dato de los anteriores se utiliza la ip del que llama al API

*/
// ------------------------------------------------------------------------------
function api_post_events() {
	$data = array(
		'proccess'    => 'API',
		'REMOTE_ADDR' => $_SERVER['REMOTE_ADDR'],
	);


   // //// //
   // POST //
   // //////////////// //
   // -F "campo=valor" //
   // //////////////// //
   foreach($_POST as $key => $value){
      // En caso de tener espacios el nombre se maneja
      if($key=='form' and is_array($value)){
         foreach($value as $k=>$v) $data[$k] = $v;
      }
      else{
			$data[$key] = $value;
      }
   }

   $return = common_create_event($data);

// $return
//         'rc'=>0,
//         'rcstr'=>'Event successfully created',
//         'eventid'=>$return_id,
//         'deviceip'=>$input_data['deviceip'],
//         'msg'=>$aux_msg,
//         'evkey'=>$evkey,

// 	/opt/cnm/crawler/bin/api_alert_manager -n ip -m "texto ...." -k evkey


	// Si se ha creado el evento comprobamos si hay que generar alerta.
	if ($return['rc'] == 0) {
	   $cmd="/opt/cnm/crawler/bin/api_alert_manager -n {$return['deviceip']} -m '{$return['msg']}' -k {$return['evkey']}";

		if (array_key_exists('iid',$data)) { 
			$cmd="/opt/cnm/crawler/bin/api_alert_manager -n {$return['deviceip']} -m '{$return['msg']}' -k {$return['evkey']} -i {$data['iid']}";
		}

   	exec($cmd,$results);
		$return['alertid']=$results[0];

		CNMAPI::info_log(__FILE__, __LINE__, "api_post_events [alertid={$return['alertid']}]  cmd=$cmd");
	}

   return $return;
}
?>
