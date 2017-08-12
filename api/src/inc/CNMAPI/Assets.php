<?php

// ------------------------------------------------------------------------------
// inc/CNMAPI/Assets.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_assets
// ------------------------------------------------------------------------------
// IN: 	id (Id del asset. Opcional)
//			Query string
// OUT:	Array con el resultado
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
//

// "https://localhost/onm/api/1.0/assets.json"                       => Información de todos los assets
// "https://localhost/onm/api/1.0/assets/6c3cf49f.json"              => Información del asset 6c3cf49f
// "https://localhost/onm/api/1.0/assets.json?id=6c3cf49f"           => Información del asset 6c3cf49f (utilizando criterios de búsqueda)
// "https://localhost/onm/api/1.0/assets.json?subtype=MySQL"         => Información de los assets del subtipo MySQL(categoría MySQL)
// "https://localhost/onm/api/1.0/assets.json?type=DDBB"             => Información de los assets del tipo DDBB

//
// "`echo "https://cnm002.s30labs.com/onm/api/1.0/assets.json?form[Usa gafas]=Si" | sed "s/[[:space:]]/%20/g"`"  => Información de los assets cuyo campo de usuario Usa gafas tenga el valor Si (utilizando criterios de búsqueda)
//
// token=$(curl -k "https://cnm002.s30labs.com/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6);curl -ki -g -H "Authorization: $token" -X GET "`echo "https://cnm002.s30labs.com/onm/api/1.0/assets.json" | sed "s/[[:space:]]/%20/g"`"
// token=$(curl -k "https://cnm002.s30labs.com/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6);curl -ki -g -H "Authorization: $token" -X GET "`echo "https://cnm002.s30labs.com/onm/api/1.0/assets.json?cnm_fields=id,type,subtype,descr&cnm_sort=-id" | sed "s/[[:space:]]/%20/g"`"
// 
// NOTA: Cuando tenemos espacios debemos sustituirlos por %20 (url_encode)
// NOTA: Cuando tenemos variables con espacios debemos utilizar form[] además de la sustitución previa
// 
// Campos de busqueda:
// - id              => id del asset
// - name            => nombre
// - type            => tipo del asset
// - subtype         => subtipo o categoría del asset
// - status          => estado
// - critic          => 25:criticidad baja | 50:criticidad media | 75:criticidad alta | 100:criticidad mazima (50 si no se indica)
// - owner           => propietario
// - Cualquier campo de usuario
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
function api_get_assets($id='all') {
   include_once('inc/class.cnmlist.php');

	$list = New cnmlist('assets');

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

   if ($id!='all') $list->set_field('id',$id);

   $return = $list->show('array');
   return $return;
}


// ------------------------------------------------------------------------------
// api_put_assets
// ------------------------------------------------------------------------------
// IN:   
//       id del element TI que hay que modificar
//       Como parámetros del GET o del PUT están los campos y valores
// OUT:  
//       Array con el resultado
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X PUT => BASE
// "https://localhost/onm/api/1.0/assets/6c3cf49f.json?campo=valor"          => Se actualiza el campo del elemento TI con id 6c3cf49f
// "https://localhost/onm/api/1.0/assets/6c3cf49f.json" -d "campo=valor"     => Se actualiza el campo del elemento TI con id 6c3cf49f
// "https://localhost/onm/api/1.0/assets/6c3cf49f.json" -d "form[campo con espacios]=valor" => Se actualiza el campo con espacios del elemento TI con id 6c3cf49f
//
// Campos que se pueden modificar:
// - name            => nombre
// - subtype         => subtipo o categoría del asset
// - status          => estado
// - critic          => 25:criticidad baja | 50:criticidad media | 75:criticidad alta | 100:criticidad mazima (50 si no se indica)
// - owner           => propietario
// - Cualquier campo de usuario
// ------------------------------------------------------------------------------
function api_put_assets($id){

   include_once('inc/class.cnmasset.php');
   $asset = new cnmasset($id);

   // /// //
   // PUT //
   // //////////////// //
   // -d "campo=valor" //
   // //////////////// //
   parse_str(file_get_contents("php://input"),$_PUT);
   foreach($_PUT as $key => $value){
      // En caso de tener espacios el nombre se maneja
      if($key=='form' and is_array($value)){
         foreach($value as $k=>$v) $asset->set_field($k,$v);
      }
      else{
         $asset->set_field($key,$value);
      }
   }


   // /// //
   // GET //
   // /// //
   foreach($_GET as $key => $value){
      if($key=='endpoint' or $key=='content_type') continue;
      $key=preg_replace("/__s__/"," ",$key);
      $asset->set_field($key,$value);
   }

   $a_res = $asset->save();
   return $a_res;
}


// ------------------------------------------------------------------------------
// api_post_assets
// ------------------------------------------------------------------------------
// IN:   
//       Como parámetros del GET están los campos y valores
// OUT:  
//			Array con el resultado
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X POST => BASE
// "https://localhost/onm/api/1.0/assets.json" -F "CAMPO1=valor1" -F "CAMPO2=valor2" -F "form[CAMPO3]=valor3"  => Se crea un elemento TI
//
// Campos disponibles:
// - name            => nombre
// - type            => tipo del asset
// - subtype         => subtipo o categoría del asset
// - status          => 0:activo | 1:inactivo | 2:mantenimiento (0 si no se indica)
// - critic          => 25:criticidad baja | 50:criticidad media | 75:criticidad alta | 100:criticidad máxima (50 si no se indica)
// - owner           => propietario
// - Cualquier campo de usuario
// 
// Campos obligatorios:
// - name
// - type
// - subtype
// 
// Campos de usuario:
// Los campos que se aporten y no sean de sistema se consideraran de usuario. Dichos valores se asociaran al elemento TI siempre y cuando
// los campos de usuario se hayan dado de alta previamente en CNM.
// Los campos de usuario que tengan espacios hay que indicarlos de la siguiente forma: -F "form[Usuario de acceso]=pepito"
// ------------------------------------------------------------------------------
function api_post_assets(){
	include_once('inc/class.cnmasset.php');
	$asset = new cnmasset();

	// //// //
   // POST //
   // //////////////// //
   // -F "campo=valor" //
   // //////////////// //
	foreach($_POST as $key => $value){
		// En caso de tener espacios el nombre se maneja
		if($key=='form' and is_array($value)){
			foreach($value as $k=>$v) $asset->set_field($k,$v);	
		}
		else{
			$asset->set_field($key,$value);	
		}
	}

	$a_res = $asset->save();	
	return $a_res;
}
?>
