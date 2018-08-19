<?php
require_once('inc/CNMAPI.php');

//--------------------------------------------------------------------------
// Variables globales
//--------------------------------------------------------------------------
$dbc        = '';
$DEPURA     = 1;
$LIFETIME   = ini_get('session.gc_maxlifetime');
$timeout    = 180;

//--------------------------------------------------------------------------
function depura($idx,$msg){
global $DEPURA;

 	if ($DEPURA){
	   //$fp = fopen ('/var/log/debug_session.log','a');
	   $fp = fopen ('/tmp/debug_session.log','a');
		$msgf=sprintf("%s >>>> %s\n",$idx,$msg);
		fwrite($fp,$msgf);
		fclose($fp);
	}
}

//--------------------------------------------------------------------------
// Function: abreBD()
// Descripcion: selects the database.
//--------------------------------------------------------------------------
function abreBD(){
global $dbc;

   depura('mysql_session_abreBD:'," IN");

   // RUTA DEL FICHERO DE CONFIGURACION DE CNM
   $cfg_file='/cfg/onm.conf';
   // HASH CON LOS DATOS NECESARIOS PARA USAR LA BBDD
   $db_data=array('DB_NAME'=>'','DB_USER'=>'','DB_PWD'=>'','DB_SERVER'=>'');

   // RELLENAMOS LOS DATOS DEL HASH ANTERIOR
   read_cfg_file($cfg_file,$db_data);
   $data = array(
      'phptype'  => 'mysql',
      'username' => $db_data['DB_USER'],
      'password' => $db_data['DB_PWD'],
      'hostspec' => $db_data['DB_SERVER'],
      'database' => $db_data['DB_NAME'],
   );

   // NOS CONECTAMOS A LA BBDD
	$timeout = 2;
	$dbc = mysqli_init();
	$dbc->options( MYSQLI_OPT_CONNECT_TIMEOUT, $timeout ) ||
		depura('mysqli_options error:',$dbc->error);
 
	$dbc->real_connect($data['hostspec'], $data['username'], $data['password'], $data['database']);
 
	if ($dbc->connect_errno) {
  		$err_str = '('.$dbc->connect_errno.'): '.$dbc->connect_error;
 		depura('mysql_session_abreBD error:',$err_str);
	}
	else {
      $dbc->query("SET CHARACTER SET UTF8");
      $dbc->query("SET NAMES UTF8");
		$dbc->autocommit(true);
	}

	return true;

}


//--------------------------------------------------------------------------
// Function: showTime()
// Descripcion: sessions end. Load page. 
//--------------------------------------------------------------------------
function showTime($SID,$mode='open'){
global $dbc;
	
	$sess_Time = 0;

	// Limpiar las sesiones inactivas
	mysql_session_garbage_collect();

	depura('mysql_session_showTime:','IN');
	$query  = "SELECT expiration FROM sessions_table WHERE SID = '$SID'";
	depura('mysql_session_showTime:',"QUERY == SELECT expiration FROM sessions_table WHERE SID = '$SID'");
	$result = $dbc->query($query);
	
	if ($dbc->errno != 0) {
   	$err_str = '('.$dbc->errno.'): '.$dbc->sqlstate.' - '.$dbc->error;
		depura('mysql_session_ShowTime: ',$err_str);
	}

	while ($r = $result->fetch_assoc()) { $sess_Time=$r['expiration']; }
	
	$t=time();

	if ($sess_Time<$t){
		$response = array(
         'errors' => array(
             'com.cnm.api.rest.InvalidSession',
         ),
         'success'=>false
      );
		// $httpHeaderCode = 403;
		$httpHeaderCode = 401;
	   CNMAPI::jsonResponseHeader($response,$httpHeaderCode);
		exit;
	}

	mysql_session_select($SID);
}
//--------------------------------------------------------------------------
// Function: mysql_session_open()
// Descripcion: Opens a persistent server connection 
//--------------------------------------------------------------------------
function mysql_session_open($session_path, $session_name) {
global $dbc;

   // print "mysql_session_open SESSION ID == $session_name\n";
	depura('mysql_session_open:','IN');
	if(!isset($_SESSION['DBC'])){
      abreBD();
      depura('mysql_session_open: ','abreBD');
   }else{
		$dbc=$_SESSION['DBC'];
      depura('mysql_session_open: ','usa $_SESSION');
	}

	return true;
} // end mysql_session_open()


//--------------------------------------------------------------------------
// Function: mysql_session_close()
// Descripcion: Doesn't actually do anything since the server connection is
// persistent. Keep in mind that although this function doesn't do anything
// in my particular implementation, I still must define it.
//--------------------------------------------------------------------------
function mysql_session_close() {

	depura('mysql_session_close:','IN');
	return true;
} // end mysql_session_close()


//--------------------------------------------------------------------------
// Function: mysql_session_select()
// Descripcion: Reads the session data from the database.
//--------------------------------------------------------------------------
function mysql_session_select($SID) {
global $dbc;

	$rc='';
	depura('mysql_session_select:','IN');
	$query  = "SELECT value FROM sessions_table WHERE SID = '$SID' AND expiration > ". time();
	$result = $dbc->query($query);

   if ($dbc->errno != 0) {
      $err_str = '('.$dbc->errno.'): '.$dbc->sqlstate.' - '.$dbc->error;
      depura('mysql_session_select: ',$err_str);
   }

	if (($r = $result->fetch_assoc()) && ($r['value']) ) { 
		depura('mysql_session_select QUERY: ',"$query || VALUE == {$r['value']}");
		session_decode($r['value']);
		$rc=$r['value'];
	}

	return $rc;

} // end mysql_session_select()


//--------------------------------------------------------------------------
// Function: mysql_session_write()
// Descripcion: Writes the session data to the database. If that SID already
// exists, then the existing data will be updated.
//--------------------------------------------------------------------------
function mysql_session_write($SID, $value) {
global $dbc,$timeout;
  
	depura('mysql_session_write:','IN');
	// TENEMOS EN CUENTA EL VALOR INTRODUCIDO EN LA CONFIGURACION DE USUARIO 
	$LIFETIME   = $_SESSION['TIMEOUT'];
	$LOGIN_NAME = $_SESSION['LUSER'];
	$t          = time();
	// $expiration = $t + $LIFETIME;
	$expiration = $t + $timeout;
	$value2     = session_encode();
	$value1     = $value2;
	$dbc        = $_SESSION['DBC'];

	if ((! isset($dbc)) and (!($dbc instanceof mysqli))) {
	//if (! $dbc) { 
		depura('mysql_session_write: ',"RECONNECT");
		abreBD();  
	}

	// SI O SE RECONECTA A BBDD. NO FUNCION !!
	abreBD();
	
	if($LOGIN_NAME=='') {return;}

	depura('mysql_session_write: ',"SID => $SID new expiration=$expiration");
	$query = "SELECT expiration FROM sessions_table WHERE SID='$SID'";
	$result=$dbc->query($query);
	if ($r = $result->fetch_assoc()) { 
		$exp=$r['expiration']; 
		depura('mysql_session_write: ',"previous expiration=$exp");
		$query = "UPDATE sessions_table set expiration=$expiration,value='$value1', user='$LOGIN_NAME' WHERE SID='$SID'";
		$result=$dbc->query($query);
		depura('mysql_session_write QUERY: ',$query);
		if ($dbc->errno != 0) {
         $err_str = '('.$dbc->errno.'): '.$dbc->sqlstate.' - '.$dbc->error;
         depura('mysql_session_write: ',$err_str);
      }
	}
	else {	
		$query = "INSERT INTO sessions_table (SID,expiration,value,user,origin) VALUES ('$SID', $expiration, '$value1','$LOGIN_NAME','api')";
		depura('mysql_session_write QUERY: ',$query);
		$result=$dbc->query($query);
      if ($dbc->errno != 0) {
         $err_str = '('.$dbc->errno.'): '.$dbc->sqlstate.' - '.$dbc->error;
         depura('mysql_session_write: ',$err_str);
      }
	}

	return true;
/*
	// Descomentar esto si queremos que el timeout de la sesión se actualice por cada petición
	// En caso de existir el SID, lo actualizamos
   if ($dbc->errno != 0) {
      //$err_str = '('.$dbc->errno.'): '.$dbc->sqlstate.' - '.$dbc->error;
      //depura('mysql_session_ShowTime: ',$err_str);
		$query = "UPDATE sessions_table set expiration=$expiration,value='$value1', user='$LOGIN_NAME' WHERE SID='$SID'";
depura('SSV',"**SSV** QUERY == $query");
		$result=$dbc->query($query); 
	   if ($dbc->errno != 0) {
  	    	$err_str = '('.$dbc->errno.'): '.$dbc->sqlstate.' - '.$dbc->error;
      	depura('mysql_session_write: ',$err_str);
		}
	}
*/
} // end mysql_session_write()
	
//--------------------------------------------------------------------------
// Function: mysql_session_write_login()
// Descripcion: Writes the session data to the database. If that SID already
// exists, then the existing data will be updated.
//--------------------------------------------------------------------------
function mysql_session_write_login($SID, $value) {
global $dbc,$timeout;
  
	depura('mysql_session_write_login:','IN');
	// TENEMOS EN CUENTA EL VALOR INTRODUCIDO EN LA CONFIGURACION DE USUARIO 
	$LIFETIME   = $_SESSION['TIMEOUT'];
	$LOGIN_NAME = $_SESSION['LUSER'];
	$t          = time();
	$expiration = $t + $timeout;
	$value2     = session_encode();
	$value1     = $value2;
	$dbc        = $_SESSION['DBC'];
	if (! $dbc) { 
		depura('mysql_session_write_login: ',"RECONNECT");
		abreBD();  
	}
	
	if($LOGIN_NAME==''){return;}
	$query = "INSERT INTO sessions_table (SID,expiration,value,user,origin) VALUES ('$SID', $expiration, '$value1','$LOGIN_NAME','api')";
	depura('SSV',"**SSV** QUERY == $query");
	depura('mysql_session_write_login: ',"SID => $SID");
	$result=$dbc->query($query);

	// Descomentar esto si queremos que el timeout de la sesión se actualice por cada petición
	// En caso de existir el SID, lo actualizamos
   if ($dbc->errno != 0) {
		$query = "UPDATE sessions_table set expiration=$expiration,value='$value1', user='$LOGIN_NAME' WHERE SID='$SID'";
		depura('SSV',"**SSV** QUERY == $query");
		$result=$dbc->query($query); 
      if ($dbc->errno != 0) {
     	  	$err_str = '('.$dbc->errno.'): '.$dbc->sqlstate.' - '.$dbc->error;
         depura('mysql_session_write_login_login: ',$err_str);
		}
	}

	return true;
} // end mysql_session_write()
	
//--------------------------------------------------------------------------
// Function: mysql_session_destroy()
// Descripcion: Deletes all session information having input SID (only one row).
//--------------------------------------------------------------------------
function mysql_session_destroy($SID) {
global $dbc;

	depura('mysql_session_destroy:','IN');
	$query  = "DELETE FROM sessions_table WHERE SID = '$SID'";
	$result = $dbc->query($query);
   if ($dbc->errno != 0) {
      $err_str = '('.$dbc->errno.'): '.$dbc->sqlstate.' - '.$dbc->error;
      depura('mysql_session_destroy error: ',$err_str);
		return false;
	}
	return true;

} // end mysql_session_destroy()

//--------------------------------------------------------------------------
// Function: mysql_session_garbage_collect()
// Descripcion: Deletes all sessions that have expired.
//--------------------------------------------------------------------------
function mysql_session_garbage_collect() {
GLOBAL $dbc,$LIFETIME;

	depura('mysql_session_garbage_collect:','IN');
	// $query = "DELETE FROM sessions_table WHERE expiration < " . (time() - $LIFETIME);
	$query = "DELETE FROM sessions_table WHERE expiration < ". time(). " AND origin='api'";
	$result = $dbc->query($query);
   if ($dbc->errno != 0) {
      $err_str = '('.$dbc->errno.'): '.$dbc->sqlstate.' - '.$dbc->error;
      depura('mysql_session_garbage_collect error: ',$err_str);
		return false;
	}
	return $dbc->affected_rows;
} // end mysql_session_garbage_collect()
?>
