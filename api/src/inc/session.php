<?php
/**
 * session.php — Gestión de sesiones del API (motor interno)
 *
 * MIGRACIÓN: Debian 11 / PHP 7 / PEAR::DB  →  Debian 13 / PHP 8 / PDO
 *
 * CAMBIOS RESPECTO A LA VERSIÓN ORIGINAL
 * ---------------------------------------
 * 1. require_once('/usr/share/pear/DB.php')  → ELIMINADO
 *    CNM_DB.php se carga transitivamente:
 *      session.php → CNMAPI.php → Store.php → CNM_DB.php
 *
 * 2. CNM_DB::Connect($data, TRUE)  →  CNM_DB::Connect($data, true)
 *    En abreBD() (1 ocurrencia).
 *
 * 3. CNM_isError($x)  →  CNM_isError($x)
 *    9 ocurrencias en todo el fichero.
 *
 * 4. $_SESSION['DBC'] — CAMBIO CRÍTICO (PDO no es serializable)
 *    PDO no puede almacenarse en $_SESSION. Se sustituye por
 *    $_SESSION['DBC_PARAMS'] (parámetros de conexión) y reconexión
 *    en cada request.
 *
 *    Puntos de lectura (4) gestionados por _reconnect_from_session():
 *      mysql_session_open()        línea ~107
 *      mysql_session_write()       línea ~171
 *      mysql_session_write_login() línea ~212
 *    Punto de comprobación isset() en mysql_session_open() línea ~107.
 *
 *    Punto de escritura (1) en Auth.php línea 97:
 *      $_SESSION['DBC'] = $dbc  →  $_SESSION['DBC_PARAMS'] = get_dbc_params()
 *
 * 5. Funciones nuevas:
 *    - get_dbc_params(): construye el array de parámetros leyendo de
 *      /cfg/onm.conf con read_cfg_file() (NO de globales $DB_*, que en
 *      este subsistema API no se pueblan — a diferencia del backend web).
 *    - _reconnect_from_session(): centraliza la reconexión desde sesión.
 *
 * DIFERENCIA CLAVE CON mysql_session.inc DEL BACKEND WEB
 * -------------------------------------------------------
 * En el backend web, get_dbc_params() leía las globales $DB_SERVER, etc.
 * En el API esas globales NO se pueblan: connectDB() y abreBD() usan
 * variables locales y leen de /cfg/onm.conf directamente. Por eso aquí
 * get_dbc_params() lee también del fichero de configuración.
 *
 * DEUDA TÉCNICA (no corregir en la migración)
 * -------------------------------------------
 * - mysql_session_write() y mysql_session_write_login() son casi idénticas
 *   (la segunda tiene activo el bloque UPDATE que la primera tiene comentado).
 *   Código duplicado. Candidato a refactor en fase posterior.
 */

// ANTES: require_once('/usr/share/pear/DB.php');  ← ELIMINADO (carga transitiva)
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
	   $fp = fopen ('/var/log/debug_session.log','a');
		$msgf=sprintf("%s >>>> %s\n",$idx,$msg);
		fwrite($fp,$msgf);
		fclose($fp);
	}
}

//--------------------------------------------------------------------------
// Function: get_dbc_params()
// NUEVA — Construye el array de parámetros de conexión serializable.
//
// Reemplaza el almacenamiento del objeto $dbc en $_SESSION['DBC'].
// PDO no es serializable en PHP 8.
//
// A diferencia del backend web, en el API la configuración NO está en
// globales $DB_*, sino en /cfg/onm.conf. Por eso leemos del fichero con
// read_cfg_file() (definida en Store.php, cargada vía CNMAPI.php).
//
// Uso en Auth.php (sustituye $_SESSION['DBC'] = $dbc):
//   $_SESSION['DBC_PARAMS'] = get_dbc_params();
//--------------------------------------------------------------------------
function get_dbc_params(){
   $cfg_file = '/cfg/onm.conf';
   $db_data  = array('DB_NAME'=>'','DB_USER'=>'','DB_PWD'=>'','DB_SERVER'=>'');
   read_cfg_file($cfg_file,$db_data);

   return array(
      'username' => $db_data['DB_USER'],
      'password' => $db_data['DB_PWD'],
      'hostspec' => $db_data['DB_SERVER'],
      'database' => $db_data['DB_NAME'],
   );
}

//--------------------------------------------------------------------------
// Function: _reconnect_from_session()
// NUEVA — Reconecta usando los parámetros guardados en sesión.
//
// Centraliza la lógica de reconexión repetida en mysql_session_open(),
// mysql_session_write() y mysql_session_write_login().
//
// Devuelve true si la reconexión fue exitosa (y deja $dbc global listo),
// false en caso contrario.
//--------------------------------------------------------------------------
function _reconnect_from_session(){
global $dbc;

   if (!isset($_SESSION['DBC_PARAMS']) || !is_array($_SESSION['DBC_PARAMS'])) {
      depura('_reconnect_from_session:','DBC_PARAMS no disponible en sesion');
      return false;
   }

   $dbc = CNM_DB::Connect($_SESSION['DBC_PARAMS'], true);

   if (CNM_isError($dbc)) {
      depura('_reconnect_from_session: ERROR', $dbc->getMessage());
      $dbc = '';
      return false;
   }

   $dbc->setFetchMode(DB_FETCHMODE_ASSOC);
   depura('_reconnect_from_session:','reconexion OK');
   return true;
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
   // ANTES: 'phptype' => 'mysqli'  → eliminado (CNM_DB siempre usa mysql/mariadb)
   $data = array(
      'username' => $db_data['DB_USER'],
      'password' => $db_data['DB_PWD'],
      'hostspec' => $db_data['DB_SERVER'],
      'database' => $db_data['DB_NAME'],
   );
   // NOS CONECTAMOS A LA BBDD
   // ANTES: $dbc = CNM_DB::Connect($data,TRUE);
   $dbc = CNM_DB::Connect($data,true);
   // ANTES: if (CNM_isError($dbc))
   if (CNM_isError($dbc)) {
		depura('mysql_session_abreBD error:',$dbc->getMessage());
   }else {
		$dbc->setFetchMode(DB_FETCHMODE_ASSOC);
		$dbc->query("SET CHARACTER SET UTF8");
		$dbc->query("SET NAMES UTF8");
		depura('mysql_session_abreBD:'," OK");
   }
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

	// ANTES: if (CNM_isError($result))
	if (CNM_isError($result)) {depura('mysql_session_ShowTime: ',$result->getMessage());}
	while ($result->fetchInto($r)){$sess_Time=$r['expiration'];}

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
	// ANTES:
	//   if(!isset($_SESSION['DBC'])){ abreBD(); }
	//   else { $dbc=$_SESSION['DBC']; }
	// DESPUÉS: PDO no serializable — reconectar desde DBC_PARAMS.
	if(!isset($_SESSION['DBC_PARAMS'])){
      abreBD();
   }else{
		if (!_reconnect_from_session()) {
			depura('mysql_session_open:','fallo DBC_PARAMS — fallback a abreBD()');
			abreBD();
		}
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

//function mysql_session_select($SID) {
//global $dbc;
//
//	$query  = "SELECT value FROM sessions_table WHERE SID = '$SID' AND expiration > ". time();
//	depura('mysql_session_select:',"IN | $query");
//	$result = $dbc->query($query);
//
//	// ANTES: if (CNM_isError($result))
//	if (CNM_isError($result)) {
//		depura('mysql_session_select: ',$result->getMessage());
//		return '';
//	}
//	if (($result->fetchInto($r)) && ($r['value']) ) {
//		depura('SSV',"**SSV 2** QUERY == $query || VALUE == {$r['value']}");
//		session_decode($r['value']);
//	}
//
//	return $SID;
//
//} // end mysql_session_select()


function mysql_session_select($SID) {
global $dbc;

    $query  = "SELECT value FROM sessions_table WHERE SID = '$SID' AND expiration > " . time();
    depura('mysql_session_select:', "IN | $query");
    $result = $dbc->query($query);

    if (CNM_isError($result)) {
        depura('mysql_session_select: ', $result->getMessage());
        return '';                      // contrato read: string vacío si error
    }

    if (($result->fetchInto($r)) && ($r['value'])) {
        depura('SSV', "**SSV 2** QUERY == $query || VALUE encontrado");
        return $r['value'];             // ← DEVOLVER el blob; PHP lo decodifica
    }

    return '';                          // ← sin datos: string vacío, NO $SID

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
	$LIFETIME   = isset($_SESSION['TIMEOUT']) ? $_SESSION['TIMEOUT'] : 0;
	$LOGIN_NAME = isset($_SESSION['LUSER'])   ? $_SESSION['LUSER']   : '';
	$t          = time();
	// $expiration = $t + $LIFETIME;
	$expiration = $t + $timeout;
	$value2     = session_encode();
	$value1     = $value2;
	// ANTES:
	//   $dbc = $_SESSION['DBC'];
	//   if (! $dbc) { abreBD(); }
	// DESPUÉS: reconectar desde DBC_PARAMS con fallback a abreBD().
	if (!_reconnect_from_session()) {
		depura('mysql_session_write: ',"RECONNECT fallback abreBD()");
		abreBD();
	}

	if($LOGIN_NAME==''){return true;}
	$query = "INSERT INTO sessions_table (SID,expiration,value,user,origin) VALUES ('$SID', $expiration, '$value1','$LOGIN_NAME','api')";
	depura('SSV',"**SSV** QUERY == $query");
	depura('mysql_session_write: ',"SID => $SID");
	$result=$dbc->query($query);
/*
	// Descomentar esto si queremos que el timeout de la sesión se actualice por cada petición
	// En caso de existir el SID, lo actualizamos
	// ANTES: if (CNM_isError($result))
	if (CNM_isError($result)) {
		$query = "UPDATE sessions_table set expiration=$expiration,value='$value1', user='$LOGIN_NAME' WHERE SID='$SID'";
depura('SSV',"**SSV** QUERY == $query");
		$result=$dbc->query($query);
		// ANTES: if (CNM_isError($result))
		if (CNM_isError($result)){depura('mysql_session_write: ',$result->getMessage()); }
	}
*/

	return true;
} // end mysql_session_write()

//--------------------------------------------------------------------------
// Function: mysql_session_write_login()
// Descripcion: Writes the session data to the database. If that SID already
// exists, then the existing data will be updated.
//--------------------------------------------------------------------------
function mysql_session_write_login($SID, $value) {
global $dbc,$timeout;

	depura('mysql_session_write:','IN');
	// TENEMOS EN CUENTA EL VALOR INTRODUCIDO EN LA CONFIGURACION DE USUARIO
	$LIFETIME   = $_SESSION['TIMEOUT'];
	$LOGIN_NAME = $_SESSION['LUSER'];
	$t          = time();
	$expiration = $t + $timeout;
	$value2     = session_encode();
	$value1     = $value2;
	// ANTES:
	//   $dbc = $_SESSION['DBC'];
	//   if (! $dbc) { abreBD(); }
	// DESPUÉS: reconectar desde DBC_PARAMS con fallback a abreBD().
	if (!_reconnect_from_session()) {
		depura('mysql_session_write: ',"RECONNECT fallback abreBD()");
		abreBD();
	}

	if($LOGIN_NAME==''){return true;}
	$query = "INSERT INTO sessions_table (SID,expiration,value,user,origin) VALUES ('$SID', $expiration, '$value1','$LOGIN_NAME','api')";
	depura('SSV',"**SSV** QUERY == $query");
	depura('mysql_session_write: ',"SID => $SID");
	$result=$dbc->query($query);

	// Descomentar esto si queremos que el timeout de la sesión se actualice por cada petición
	// En caso de existir el SID, lo actualizamos
	// ANTES: if (CNM_isError($result))
	if (CNM_isError($result)) {
		$query = "UPDATE sessions_table set expiration=$expiration,value='$value1', user='$LOGIN_NAME' WHERE SID='$SID'";
		depura('SSV',"**SSV** QUERY == $query");
		$result=$dbc->query($query);
		// ANTES: if (CNM_isError($result))
		if (CNM_isError($result)){depura('mysql_session_write: ',$result->getMessage()); }
	}

	return true;
} // end mysql_session_write_login()

//--------------------------------------------------------------------------
// Function: mysql_session_destroy()
// Descripcion: Deletes all session information having input SID (only one row).
//--------------------------------------------------------------------------
function mysql_session_destroy($SID) {
global $dbc;

	depura('mysql_session_destroy:','IN');
	$query  = "DELETE FROM sessions_table WHERE SID = '$SID'";
	$result = $dbc->query($query);
	// ANTES: if (CNM_isError($result))
	if (CNM_isError($result)) { depura ('mysql_session_destroy error:',$result->getMessage());	}
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
	// ANTES: if (CNM_isError($result))
	if (CNM_isError($result)) {
		depura ('mysql_session_garbage_collect error: ',$result->getMessage());
		return;
	}
	return $dbc->affectedRows();
} // end mysql_session_garbage_collect()
?>
