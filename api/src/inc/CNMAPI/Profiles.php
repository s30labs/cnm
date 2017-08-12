<?php

// ------------------------------------------------------------------------------
// inc/CNMAPI/Profiles.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_profiles
// ------------------------------------------------------------------------------
// IN: 	id (Id del dispositivo. Opcional)
//			Query string
// OUT:	Array con el resultado
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
// "https://localhost/onm/api/1.0/profiles.json"                       => Información de todos los dispositivos
// "https://localhost/onm/api/1.0/profiles/12.json"                    => Información del dispositivo 12
// "https://localhost/onm/api/1.0/profiles.json?id=12"                 => Información del dispositivo 12 (utilizando criterios de búsqueda)
// "https://localhost/onm/api/1.0/profiles/10.2.254.223.json"          => Información del dispositivo con ip 10.2.254.223
// "https://localhost/onm/api/1.0/profiles.json?deviceip=10.2.254.223" => Información del dispositivo con ip 10.2.254.223 (utilizando criterios de búsqueda)
// SSV: PENDIENTE => "https://localhost/onm/api/1.0/profiles.json?form[IP Secundaria]=1.1.1.1" => Información de los dispositivos con el campo de usuario IP Secundaria 1.1.1.1 (utilizando criterios de búsqueda)
// 
// Campos de busqueda:
// - id
// - redalerts
// - orangealerts
// - yellowalerts
// - bluealerts
// - nmetrics
// - critic
// - devicestatus
// - devicename
// - devicedomain
// - deviceip
// - devicenetwork
// - devicetype
// - devicemac
// - snmpsysclass
// - snmpsysdesc
// - snmpsyslocation
// - SSV: PENDIENTE => Campos de usuario

// ------------------------------------------------------------------------------
function api_get_profiles($id=0) {

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
// api_put_profiles
// ------------------------------------------------------------------------------
// IN:   
//       id del perfil que hay que modificar
//       Como parámetros del GET o del PUT están los campos y valores
// OUT:  
//       Array con el resultado
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X PUT => BASE
//
// Modificar
// "https://localhost/onm/api/1.0/profiles/12.json?name=web"           => Se cambia el nombre del perfil con id 12
//
// Asociar elementos
// "https://localhost/onm/api/1.0/profiles/12.json?user=22"            => Se asocia el usuario con id 22 al perfil con id 22
// "https://localhost/onm/api/1.0/profiles/12.json?user=SSV"           => Se asocia el usuario con name SSV al perfil con id 22
// "https://localhost/onm/api/1.0/profiles/12.json?device=44"          => Se asocia el dispositivo con id 44 al perfil con id 
// "https://localhost/onm/api/1.0/profiles/12.json?device=1.1.1.1"     => Se asocia el dispositivo con ip 1.1.1.1 al perfil con id 12
// "https://localhost/onm/api/1.0/profiles/12.json" -d "user=USER"     => Se asocia el usuario con id USER al perfil con id 12
// "https://localhost/onm/api/1.0/profiles/12.json" -d "device=DEVICE" => Se asocia el dispositivo con id DEVICE al perfil con id 12
//
// Campos que se pueden modificar:
// - name           => se cambia el nombre del perfil

// Elementos que se pueden asociar:
// - user           => id o name del usuario a asociar a dicho perfil
// - device         => id o ip del dispositivo a asociar a dicho perfil
// ------------------------------------------------------------------------------
function api_put_profiles($id){

   include_once('inc/class.cnmprofile.php');
   $profile = new cnmprofile($id);

   // /// //
   // PUT //
   // //////////////// //
   // -d "campo=valor" //
   // //////////////// //
   parse_str(file_get_contents("php://input"),$_PUT);
   foreach($_PUT as $key => $value){
      // En caso de tener espacios el nombre se maneja
      if($key=='form' and is_array($value)){
         foreach($value as $k=>$v) $profile->set_field($k,$v);
      }
      else{
         $profile->set_field($key,$value);
      }
   }


   // /// //
   // GET //
   // /// //
   foreach($_GET as $key => $value){
      if($key=='endpoint' or $key=='content_type') continue;
      $key=preg_replace("/__s__/"," ",$key);
      $profile->set_field($key,$value);
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

   $a_res = $profile->save();
   return $a_res;
}


// ------------------------------------------------------------------------------
// api_post_profiles
// ------------------------------------------------------------------------------
// IN:   
//       Como parámetros del GET están los campos y valores
// OUT:  
//			Array con el resultado
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X POST => BASE
// "https://localhost/onm/api/1.0/profiles.json" -F "CAMPO1=valor1""  => Se crea un perfil
//
// Campos disponibles:
// - name           => nombre
// 
// Campos obligatorios:
// - name
// ------------------------------------------------------------------------------
function api_post_profiles(){
	include_once('inc/class.cnmprofile.php');
	$profile = new cnmprofile();


/*
   // /// //
   // GET //
   // /// //
   foreach($_GET as $key => $value){
      if($key=='endpoint' or $key=='content_type') continue;
      $key=preg_replace("/__s__/"," ",$key);
      $profile->set_field($key,$value);
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
			foreach($value as $k=>$v) $profile->set_field($k,$v);	
		}
		else{
			$profile->set_field($key,$value);	
		}
	}

	$a_res = $profile->save();	
	return $a_res;
}
?>
