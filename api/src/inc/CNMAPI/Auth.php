<?php

// ------------------------------------------------------------------------------
// inc/CNMAPI/Auth.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_auth_token
// ------------------------------------------------------------------------------
// IN:	Query string. 'u'=>Usuario, 'p'=>Clave
// OUT:	Array con el resultado ('status'=>0, 'sessionid=>'5cbe57d976f99dc436f82653ce6d1314')'
// DESCR: Si la peticion se realiza a 127.0.0.1 o a localhost no hace falta poner la contraseña
// ------------------------------------------------------------------------------
// Para obtener sid de acceso:
// curl -ki "https://10.2.254.222/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
function api_get_auth_token() {
   global $dbc;

   $LOGIN_NAME  = CNMUtils::get_param('u');
   $PASSWD      = CNMUtils::get_param('p');
	$local_query = ($_SERVER['REMOTE_ADDR']=='127.0.0.1' || $_SERVER['REMOTE_ADDR']=='localhost')?1:0; // 1: peticion local | 0: peticion remota

	if( (($LOGIN_NAME=='' or $PASSWD=='') and 0==$local_query) OR ($LOGIN_NAME=='' AND 1==$local_query)){
      $response = array(
         'errors' => array(
             'com.cnm.api.rest.UsernameAndPasswordRequired',
         ),
         'success'=>false
      );
      $httpHeaderCode = 400;
      CNMAPI::jsonResponseHeader($response,$httpHeaderCode);
      exit;
	}

   $return = array('status'=>1);

   // SE OBTIENEN LOS DATOS DEL USUARIO QUE INTENTA ENTRAR EN CNM
   $info   = array('__LOGIN_NAME__'=>$LOGIN_NAME,'__PASSWD__'=>$PASSWD);
   $result = doQuery('datos_usuario_enc',$info);
   $r = $result['obj'][0];
   $plugin_auth = $r['plugin_auth'];

   ///////////////////
   // Autenticacion //
   ///////////////////
   // En caso de existir un usuario en la BBDD con el usuario dado
   if($result['cont']>0){
		// En caso de ser una petición local
		if(1==$local_query){
			$return['status']=0;
		}
      // Autenticación local
      elseif($plugin_auth=='local'){
         if($r['token']==generateHash($PASSWD,$r['token'])) $return['status']=0;
      }
      // Autenticación a través de plugin
      else{
         $data2=array('__TYPE__'=>$plugin_auth);
         $result2 = doQuery('get_plugin_auth_by_type',$data2);
         if($result2['cont']>0){
            include_once("custom/inc/{$result2['obj'][0]['lib_auth']}");
            if(0==plugin_validate_user($LOGIN_NAME,$PASSWD)) $return['status']=0;
         }
      }
   }

   // En caso de ser válido el usuario y contraseña (o el usuario u siendo una petición local)
   if($return['status'] == 0){
      mysql_session_garbage_collect();
      // session_set_save_handler('mysql_session_open','mysql_session_close','mysql_session_select','mysql_session_write','mysql_session_destroy','mysql_session_garbage_collect');
      session_set_save_handler('mysql_session_open','mysql_session_close','mysql_session_select','mysql_session_write_login','mysql_session_destroy','mysql_session_garbage_collect');
      session_start();
      $data = array('__USER__'=>$LOGIN_NAME);
      $result = doquery('check_session_user_api',$data);
      // Hay otra sesión activa => Se le pasa ese SID
      if($result['cont']!= 0){
         $sid = $result['obj'][0]['SID'];
         //fmldeb11  session_id($sid);
      }
      // mysql_session_garbage_collect();
      define('SESIONPHP',session_id());
   }


CNMUtils::info_log(__FILE__, __LINE__, "[API10] LOGIN_NAME=$LOGIN_NAME PASSWD=$PASSWD LOCAL=$local_query status={$return['status']}");

   ////////////////////////////
   // Autenticación correcta //
   ////////////////////////////
   if($return['status']==0){

      $_SESSION['PERFIL']      = $r['perfil'];
      $_SESSION['NUSER']       = $r['id_user'];
      $_SESSION['TIMEOUT']     = $r['timeout'];
      $_SESSION['DBC']         = $dbc;
      $_SESSION['count']       = 4;
      $_SESSION['LUSER']       = $LOGIN_NAME;
      $_SESSION['local_cid']   = 'default';
      $_SESSION['STAT']        = 'OK';
      $_SESSION['A_HIDX']      = 1;
      $_SESSION['REMOTE_ADDR'] = get_remote_address();

      // OBTENEMOS LOS GRUPOS ORGANIZATIVOS A LOS QUE PERTENECE EL USUARIO Y LOS GUARDAMOS EN LA
      // SESION PARA POSTERIORES COMPROBACIONES
      $_SESSION['ORGPRO'] = '0';
      $info   = array('__ID_USER__'=>$_SESSION['NUSER']);
      $result = doQuery('grupos_organizativos',$info);
      foreach ($result['obj'] as $r) $_SESSION['ORGPRO'].=','.$r['id_cfg_op'];

      // COMPROBAMOS SI EL USUARIO ES ADMINISTRADOR GLOBAL O NO
      // COMPROBAMOS QUE EL USUARIO ACTUAL PERTENECE A GLOBAL O NO
      $info   = array('__ID_USER__'=>$_SESSION['NUSER']);
      $result = doQuery('es_admin_global',$info);
      $_SESSION['GLOBAL'] = $result['obj'][0]['cuantos'];

      $httpHeaderCode      = 200;
      $return['sessionid'] = SESIONPHP;

		// Se define en session.php
		global $timeout;
      $return['expires_in'] = $timeout;
		
   }
   //////////////////////////////
   // Autenticación incorrecta //
   //////////////////////////////
   else{
      $response = array(
         'errors' => array(
             'com.cnm.api.rest.UsernameOrPasswordIncorrect',
         ),
         'success'=>false
      );
      $httpHeaderCode = 400;
      CNMAPI::jsonResponseHeader($response,$httpHeaderCode);
      exit;

      // $httpHeaderCode = 400;
   }

//   CNMAPI::jsonResponseHeader($return,$httpHeaderCode);
   return $return;
}



?>
