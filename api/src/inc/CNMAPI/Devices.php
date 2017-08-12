<?php

// ------------------------------------------------------------------------------
// inc/CNMAPI/Devices.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_devices
// ------------------------------------------------------------------------------
// IN: 	id (Id del dispositivo. Opcional)
//			Query string
// OUT:	Array con el resultado
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
//
// "https://localhost/onm/api/1.0/devices.json"                       => Información de todos los dispositivos
// "https://localhost/onm/api/1.0/devices/12.json"                    => Información del dispositivo 12
// "https://localhost/onm/api/1.0/devices.json?id=12"                 => Información del dispositivo 12 (utilizando criterios de búsqueda)
// "https://localhost/onm/api/1.0/devices/10.2.254.223.json"          => Información del dispositivo con ip 10.2.254.223
// "https://localhost/onm/api/1.0/devices.json?ip=10.2.254.223"       => Información del dispositivo con ip 10.2.254.223 (utilizando criterios de búsqueda)
//
// "`echo "https://cnm002.s30labs.com/onm/api/1.0/devices.json?form[IP Secundaria]=1.1.1.1" | sed "s/[[:space:]]/%20/g"`"  => Información de los dispositivos con el campo de usuario IP Secundaria 1.1.1.1 (utilizando criterios de búsqueda)
//
// token=$(curl -k "https://cnm002.s30labs.com/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6);curl -ki -g -H "Authorization: $token" -X GET "`echo "https://cnm002.s30labs.com/onm/api/1.0/devices.json" | sed "s/[[:space:]]/%20/g"`"
// token=$(curl -k "https://cnm002.s30labs.com/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6);curl -ki -g -H "Authorization: $token" -X GET "`echo "https://cnm002.s30labs.com/onm/api/1.0/devices.json?cnm_fields=id,name,domain&cnm_sort=-id" | sed "s/[[:space:]]/%20/g"`"
// 
// NOTA: Cuando tenemos espacios debemos sustituirlos por %20 (url_encode)
// NOTA: Cuando tenemos variables con espacios debemos utilizar form[] además de la sustitución previa
// 
// Campos de busqueda:
// - id              => id del dispositivo
// - name            => nombre
// - domain          => dominio
// - ip              => direccion ip
// - type            => tipo de dispositivo
// - snmpversion     => 0:sin SNMP | 1:version 1 | 2:version 2 | 3:version 3 (0 si no se indica)
// - snmpcommunity   => comunidad snmp (versiones 1 y 2)
// - entity          => 0:dispositivo físico | 1:servicio web (0 si no se indica)
// - geo             => geolocalizacion en formato Google Maps
// - critic          => 25:criticidad baja | 50:criticidad media | 75:criticidad alta | 100:criticidad mazima (50 si no se indica)
// - correlated      => ID del dispositivo del que depende
// - status          => 0:activo | 1:inactivo | 2:mantenimiento (0 si no se indica)
// - profile         => perfil al que pertenece el dispositivo
// - redalerts       => alertas rojas
// - orangealerts    => alertas naranjas
// - yellowalerts    => alertas amarillas
// - bluealerts      => alertas azules
// - network         => red del dispositivo
// - mac             => direccion mac
// - macvendor       => fabricante a partir de la mac
// - snmpsysclass    => sysclass snmp
// - snmpsysdesc     => descripcion snmp
// - snmpsyslocation => localizacion snmp
// - switch          => switch al que esta conectado el dispositivo
// - xagentversion   => version del agente cnm
// - metrics         => numero de metricas activas
// 
// NOTA: En caso de querer hacer un OR en un mismo campo, meter una coma. 
//       Ejemplo: name=cnm,www
// 
// NOTA: Los campos de búsqueda pueden usar los siguientes operadores aritméticos:
//
// - CNMGT    => >
// - CNMGTE   => >=
// - CNMLT    => <
// - CNMLTE   => <=
// - CNMLIKE  => LIKE
// - CNMNLIKE => NOT LIKE
// - CNMEQ    => =
// - CNMNEQ   => !=
//
//
// Campos auxiliares:
// - cnm_page_size => Numero de elementos por página
// - cnm_page      => Numero de página
// - cnm_fields    => Campos que queremos que devuelva separados por comas
// - cnm_sort      => Campo por el que queremos que ordene (ponerle un - en caso de querer ordenar de forma descendente por dicho campo)
//                    En caso de querer ordenar por varios campos, dichos campos deben ir separados por comas
//
// 



// ------------------------------------------------------------------------------
function api_get_devices($id=0) {
   include_once('inc/class.cnmlist.php');

	$list = New cnmlist('devices');

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


// ------------------------------------------------------------------------------
function api_get_devices2($id=0) {

   $extra_params = array();
   $extra_params['posStart']    = (CNMUtils::get_param('posStart')!='')?CNMUtils::get_param('posStart'):0;
   $extra_params['count']       = (CNMUtils::get_param('count')!='')?CNMUtils::get_param('count'):1000000;
   $extra_params['orderby']     = CNMUtils::get_param('orderby');
   $extra_params['direct']      = CNMUtils::get_param('direct');

	// /// //
	// GET //
	// /// //
   $params  = array();
   foreach($_GET as $key => $value){
      if($key=='endpoint' or $key=='content_type') continue;
		// En caso de tener espacios el nombre se maneja
      if($key=='form' and is_array($value)){
         foreach($value as $k=>$v) $params[$k]=$v;
      }
      else{
			$params[$key]=$value;
      }
   }

   if ($id>0) $params['id'] = $id;


   // Filtros de las búsquedas almacenadas seleccionadas (NO SE USA);
   $a_ss_params   = CNMUtils::get_json('ss_params');

   $tabla      = common_devices_get_table_structure(3,array('include' => false,'id'=>'mod_dispositivo_layout'));
   $table_data = common_devices_get_table(3,$params,$extra_params,$tabla,$a_ss_params);
   // SSV: PROXY INVERSO
   $table_data=str_replace('____PROXY____', '', $table_data);

   $return = grid2array($table_data,1);
   return $return;
}






// ------------------------------------------------------------------------------
// api_put_devices_custom_data
// ------------------------------------------------------------------------------
// IN:   
//			input_array => Array con la ip o el id_dev del dispositivo al que hay que modificar
//       Como parámetros del GET están los campos y valores
// OUT:  
//			Array con el resultado
// ------------------------------------------------------------------------------
//curl -ki  -H "Authorization: e4f25e3120bee35b411e3af29a088d02" -X PUT "https://localhost/onm/api/1.0/devices/12.json?campo1=valor1&campo2=valor2"          => Se actualizan los campos de usuario campo1 y campo2 del dispositivo con id 12
//curl -ki  -H "Authorization: e4f25e3120bee35b411e3af29a088d02" -X PUT "https://localhost/onm/api/1.0/devices/10.2.254.223.json?campo1=valor1&campo2=valor2" => Se actualizan los campos de usuario campo1 y campo2 del dispositivo con ip 10.2.254.223
// ------------------------------------------------------------------------------
function api_put_devices_custom_data($input_array){
  	$a_custom_data = array();
   foreach($_GET as $key => $val){
		if($key=='endpoint' or $key=='content_type') continue;
		$key=preg_replace("/__s__/"," ",$key);
		$a_custom_data[$key]=$val;
	}
	
	$return = common_set_custom_data($input_array,$a_custom_data);
	return $return;
}

// ------------------------------------------------------------------------------
// api_put_devices
// ------------------------------------------------------------------------------
// IN:   
//       id o ip del dispositivo al que hay que modificar
//       Como parámetros del GET o del PUT están los campos y valores
// OUT:  
//       Array con el resultado
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X PUT => BASE
// "https://localhost/onm/api/1.0/devices/12.json?campo=valor"          => Se actualiza el campo del dispositivo con id 12
// "https://localhost/onm/api/1.0/devices/12.json" -d "campo=valor"     => Se actualiza el campo del dispositivo con id 12
// "https://localhost/onm/api/1.0/devices/12.json" -d "form[campo con espacios]=valor" => Se actualiza el campo con espacios del dispositivo con id 12
// "https://localhost/onm/api/1.0/devices/10.2.254.223.json" -d "campo=valor" => Se actualiza el campo del dispositivo con ip 10.2.254.223
//
// Campos que se pueden modificar:
// - name           => nombre
// - domain         => dominio
// - ip             => direccion ip
// - type           => tipo de dispositivo
// - snmpversion    => 0:sin SNMP | 1:version 1 | 2:version 2 | 3:version 3 (0 si no se indica)
// - snmpcommunity  => comunidad snmp (versiones 1 y 2)
// - snmpcredential => credencial snmp (version 3)
// - entity         => 0:dispositivo físico | 1:servicio web (0 si no se indica)
// - geo            => geolocalizacion en formato Google Maps
// - critic         => 25:criticidad baja | 50:criticidad media | 75:criticidad alta | 100:criticidad mazima (50 si no se indica)
// - correlated     => ID del dispositivo del que depende
// - status         => 0:activo | 1:inactivo | 2:mantenimiento (0 si no se indica)
// - profile        => perfil al que pertenece el dispositivo
// - Cualquier campo de usuario
// ------------------------------------------------------------------------------
function api_put_devices($id){

   include_once('inc/class.cnmdevice.php');
   $device = new cnmdevice($id);

   // /// //
   // PUT //
   // //////////////// //
   // -d "campo=valor" //
   // //////////////// //
   parse_str(file_get_contents("php://input"),$_PUT);
   foreach($_PUT as $key => $value){
      // En caso de tener espacios el nombre se maneja
      if($key=='form' and is_array($value)){
         foreach($value as $k=>$v) $device->set_field($k,$v);
      }
      else{
         $device->set_field($key,$value);
      }
   }


   // /// //
   // GET //
   // /// //
   foreach($_GET as $key => $value){
      if($key=='endpoint' or $key=='content_type') continue;
      $key=preg_replace("/__s__/"," ",$key);
      $device->set_field($key,$value);
   }
/*
   // //// //
   // POST //
   // //////////////// //
   // -F "campo=valor" //
   // //////////////// //
   foreach($_POST as $key => $value){
      // En caso de tener espacios el nombre se maneja
      if($key=='form' and is_array($value)){
         foreach($value as $k=>$v) $device->set_field($k,$v);
      }
      else{
         $device->set_field($key,$value);
      }
   }
*/

   $a_res = $device->save();
   return $a_res;
}


// ------------------------------------------------------------------------------
// api_post_devices
// ------------------------------------------------------------------------------
// IN:   
//       Como parámetros del GET están los campos y valores
// OUT:  
//			Array con el resultado
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X POST => BASE
// "https://localhost/onm/api/1.0/devices.json" -F "CAMPO1=valor1" -F "CAMPO2=valor2" -F "form[CAMPO3]=valor3"  => Se crea un dispositivo
//
// Campos disponibles:
// - name           => nombre
// - domain         => dominio
// - ip             => direccion ip
// - type           => tipo de dispositivo
// - snmpversion    => 0:sin SNMP | 1:version 1 | 2:version 2 | 3:version 3 (0 si no se indica)
// - snmpcommunity  => comunidad snmp (versiones 1 y 2)
// - snmpcredential => credencial snmp (version 3)
// - entity         => 0:dispositivo físico | 1:servicio web (0 si no se indica)
// - geo            => geolocalizacion en formato Google Maps
// - critic         => 25:criticidad baja | 50:criticidad media | 75:criticidad alta | 100:criticidad mazima (50 si no se indica)
// - correlated     => ID del dispositivo del que depende
// - status         => 0:activo | 1:inactivo | 2:mantenimiento (0 si no se indica)
// - profile        => perfil al que pertenece el dispositivo
// 
// Campos obligatorios:
// - name
// - domain
// - ip
//
// Campos de usuario:
// Los campos que se aporten y no sean de sistema se consideraran de usuario. Dichos valores se asociaran al dispositivo siempre y cuando
// los campos de usuario se hayan dado de alta previamente en CNM.
// Los campos de usuario que tengan espacios hay que indicarlos de la siguiente forma: -F "form[Usuario de acceso]=pepito"
// ------------------------------------------------------------------------------
function api_post_devices(){
/*
   $data = array();
   foreach($_POST as $key => $value) $data[$key] = $value;
   $return = common_create_device($data);
   return $return;
*/
	include_once('inc/class.cnmdevice.php');
	$device = new cnmdevice();

/*
   // /// //
   // PUT //
   // //////////////// //
   // -d "campo=valor" //
   // //////////////// //
   parse_str(file_get_contents("php://input"),$_PUT);
   foreach($_PUT as $key => $value){
      // En caso de tener espacios el nombre se maneja
      if($key=='form' and is_array($value)){
         foreach($value as $k=>$v) $device->set_field($k,$v);
      }
      else{
         $device->set_field($key,$value);
      }
   }
*/

/*
   // /// //
   // GET //
   // /// //
   foreach($_GET as $key => $value){
      if($key=='endpoint' or $key=='content_type') continue;
      $key=preg_replace("/__s__/"," ",$key);
      $device->set_field($key,$value);
   }
*/

	// //// //
   // POST //
   // //////////////// //
   // -F "campo=valor" //
   // //////////////// //
	foreach($_POST as $key => $value){
		// En caso de tener espacios el nombre se maneja
		if($key=='form' and is_array($value)){
			foreach($value as $k=>$v) $device->set_field($k,$v);	
		}
		else{
			$device->set_field($key,$value);	
		}
	}

	$a_res = $device->save();	
	return $a_res;
}
?>
