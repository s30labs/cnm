<?php

// ------------------------------------------------------------------------------
// inc/CNMAPI/users.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_users
// ------------------------------------------------------------------------------
// IN: 	id (Id del usuario. Opcional)
//			Query string
// OUT:	Array con el resultado
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET" => BASE
// 
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
//
//
// "https://localhost/onm/api/1.0/users.json"                  => Información de todos los usuarios
// "https://localhost/onm/api/1.0/users/12.json"               => Información del usuario con id 12
// "https://localhost/onm/api/1.0/users.json?id=12"            => Información del usuario con id 12 (utilizando criterios de búsqueda)
// "https://localhost/onm/api/1.0/users.json?form[role]=Administrador maestro" => Información de todos los usuarios cuyo rol sea usuario web

//
// "`echo "https://cnm002.s30labs.com/onm/api/1.0/users.json?form[role]=Administrador maestro" | sed "s/[[:space:]]/%20/g"`"
// 
// token=$(curl -k "https://cnm002.s30labs.com/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6);curl -ki -g -H "Authorization: $token" -X GET "`echo "https://cnm002.s30labs.com/onm/api/1.0/users.json" | sed "s/[[:space:]]/%20/g"`"
// token=$(curl -k "https://cnm002.s30labs.com/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6);curl -ki -g -H "Authorization: $token" -X GET "`echo "https://cnm002.s30labs.com/onm/api/1.0/users.json?cnm_fields=id,login,descr&cnm_sort=-id" | sed "s/[[:space:]]/%20/g"`"
// 
// NOTA: Cuando tenemos espacios debemos sustituirlos por %20 (url_encode)
// NOTA: Cuando tenemos variables con espacios debemos utilizar form[] además de la sustitución previa
//
// Campos de busqueda:
// - id        => id del usuario
// - login     => login del usuario
// - descr     => descripcion
// - timeout   => valor de timeout
// - firstname => nombre
// - lastname  => apellidos
// - email     => correo electronico
// - language  => idioma
// - role      => rol
//
// NOTA: En caso de querer hacer un OR en un mismo campo, meter una coma. 
//       Ejemplo: login=admin,oper
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
// ------------------------------------------------------------------------------
function api_get_users($id=0) {
   include_once('inc/class.cnmlist.php');

   $list = New cnmlist('users');

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
// api_put_users
// ------------------------------------------------------------------------------
// IN:   
//			id del usuario que hay que modificar
//       Como parámetros del GET o del PUT están los campos y valores
// OUT:  
//			Array con el resultado
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X PUT => BASE
// "https://localhost/onm/api/1.0/users/12.json?campo=valor"            => Se actualiza el campo del usuario con id 12
// "https://localhost/onm/api/1.0/users/12.json" -d "campo=valor"       => Se actualiza el campo del usuario con id 12
// "https://localhost/onm/api/1.0/users/12.json" -d "form[campo con espacios]=valor" => Se actualiza el campo con espacios del usuario con id 12
//
// Campos que se pueden modificar:
// - login     => nombre de usuario
// - passwd    => contraseña en claro
// - token     => contraseña encriptada
// - descr     => descripción
// - timeout   => tiempo de la sesión (valor minimo 300)
// - firstname => nombre
// - lastname  => apellidos
// - email     => correo electrónico
// - language  => idioma de la interfaz (es_ES | en_US)
// - profile   => Perfil/perfiles (separado por ,) a los que pertenece el usuario
// - role      => Rol del usuario

// ------------------------------------------------------------------------------
function api_put_users($id){

   include_once('inc/class.cnmuser.php');
   $user = new cnmuser($id);

	// /// //
	// PUT //
	// //////////////// //
	// -d "campo=valor" //
	// //////////////// //
	parse_str(file_get_contents("php://input"),$_PUT);
   foreach($_PUT as $key => $value){
      // En caso de tener espacios el nombre se maneja
      if($key=='form' and is_array($value)){
         foreach($value as $k=>$v) $user->set_field($k,$v);
      }
      else{
         $user->set_field($key,$value);
      }
   }


	//	/// //
	// GET //
	//	/// //
   foreach($_GET as $key => $value){
		if($key=='endpoint' or $key=='content_type') continue;
		$key=preg_replace("/__s__/"," ",$key);
		$user->set_field($key,$value);
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
         foreach($value as $k=>$v) $user->set_field($k,$v);
      }
      else{
         $user->set_field($key,$value);
      }
   }
*/

   $a_res = $user->save();
   return $a_res;
}


// ------------------------------------------------------------------------------
// api_post_users
// ------------------------------------------------------------------------------
// IN:   
//       Como parámetros del GET están los campos y valores
// OUT:  
//			Array con el resultado
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X POST => BASE
// "https://localhost/onm/api/1.0/users.json" -F "CAMPO1=valor1" -F "CAMPO2=valor2" -F "form[CAMPO3]=valor3"  => Se crea un usuario
//
// Campos disponibles:
// - login     => nombre de usuario
// - passwd    => contraseña en claro
// - token     => contraseña encriptada
// - descr     => descripción
// - timeout   => tiempo de la sesión (valor minimo 300)
// - firstname => nombre
// - lastname  => apellidos
// - email     => correo electrónico
// - language  => idioma de la interfaz (es_ES | en_US)
// - profile   => Perfil/perfiles (separado por ,) a los que pertenece el usuario
// - role      => Rol del usuario
// 
// Campos obligatorios:
// - login
// - passwd o token
// - firstname
// - lastname
// - email
// - profile
// - role
//
// ------------------------------------------------------------------------------
function api_post_users(){

   include_once('inc/class.cnmuser.php');
   $user = new cnmuser();

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
         foreach($value as $k=>$v) $user->set_field($k,$v);
      }
      else{
         $user->set_field($key,$value);
      }
   }
*/

/*
	//	/// //
	// GET //
	//	/// //
   foreach($_GET as $key => $value){
		if($key=='endpoint' or $key=='content_type') continue;
		$key=preg_replace("/__s__/"," ",$key);
		$user->set_field($key,$value);
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
         foreach($value as $k=>$v) $user->set_field($k,$v);
      }
      else{
         $user->set_field($key,$value);
      }
   }

   $a_res = $user->save();
   return $a_res;
}
?>
