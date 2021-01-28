<?php

//--------------------------------------------------------------------------
// Function: read_cfg_file
// Descripcion: Funcion auxiliar. Permite leer el fichero de configuracion
// /cfg/onm.conf cuya sintaxis es del tipo clave=valor.
// Parametros de entrada:
// a. Nombre del fichero.
// b. Hash cuyas claves son las cadenas a leer.
//--------------------------------------------------------------------------

function read_cfg_file($file,&$data){
   $rcstr='';
   $lines = file($file);
   if (! $lines) {
      $rc="Error al abrir fichero $file en modo lectura";
      return $rc;
   }
   foreach ($data as $clave => $valor) {
      $not_found=1;
      foreach ($lines as $l){
         if (preg_match("/^#/", $l))      continue;
         if (!preg_match("/$clave/", $l)) continue;

         $words=preg_split('/\s*\=\s*/',$l);
         if (($words[0] == $clave)&& ($not_found)) {
            $data[$clave] = rtrim($words[1]," \n");
            $not_found=0;
         }
      }
   }
}

/** **********************************************************************
* Funcion: getQuery()
* Input:
*        $id => identificador que indica la query a realizar
*        $data => hash que contiene los elementos a parsear y su valor
* Output: query a ejecutar
* Descripcion: Funcion encargada de generar la query adecuada
* **********************************************************************
*/
function getQuery($id,$data){
   global $sql_pool;
	global $dbc;
	include_once('sql/mod_Configure.sql');

   $sql=$sql_pool[$id];
   if (count($data)>0) {
      foreach ($data as $key => $value){
         if($key!='__CONDITION__' AND $key!='__VALUES__') $value = $dbc->escapeSimple($value);
         $sql=str_replace($key,$value,$sql);
      }
   }
   return $sql;
}
/** **********************************************************************
* Funcion: doQuery()
* Input:
*        $id => identificador que indica la query a realizar
*        $data => hash que contiene los elementos a parsear y su valor
* Output: hash compuesto por:
*         rc    => 0 ok|valor_error en otro caso
*         rcstr => rcstr devuelto por la query
*         msg   => Mensaje que se le da al usuario
*         obj   => Array que contiene el resultado de la query
*         ico   => Icono a mostrar
* Descripcion: Funcion encargada de ejecutar
* **********************************************************************
*/
function doQuery($id,$data,$file=''){
   $sql    = getQuery($id,$data);
   $return = Query($sql,$id,$file);
   return $return;
}
// Función que ejecuta la query $sql
function Query($sql,$id='manual',$file=''){
   global $dbc;
   $return=array('rc'=>'0','rcstr'=>'','msg'=>'','obj'=>array(),'cont'=>0);
   $result = $dbc->query($sql);
   if (@PEAR::isError($result)){
      $return['rcstr']=$result->getMessage();
      $return['rc']=$result->getCode();
      $return['msg']="Ha habido algun problema al realizar los cambios en la base de datos<br>Error SQL {$return['rc']} => {$return['rcstr']}";
      $return['ico']="ico_alarm";
      $return['query']=$sql;
      $return['id']=$id;
      $aux="FILE = $file || ID_SQL = $id || SQL = $sql || NOOK || RCSTR = {$return['rcstr']}";
   }
   else{
      if(is_object($result)){
         while ($result->fetchInto($r)){
            $return['obj'][]=$r;
            $return['cont']++;
         }
         $result->free();
      }
      $return['msg']="Los cambios se han realizado correctamente";
      $return['ico']="ico_info";
      $return['query']=$sql;
      $return['id']=$id;
      $aux="FILE = $file || ID_SQL = $id || SQL = $sql || OK";
   }
   return $return;
}

function generateHash($plainText, $salt = null){
   $SALT_LENGTH=32;

   if ($salt === null) $salt = substr(md5(uniqid(rand(), true)), 0, $SALT_LENGTH);
   else $salt = substr($salt, 0, $SALT_LENGTH);
   return $salt . sha1($salt . $plainText);
}

//--------------------------------------------------------------------------
// Function: get_remote_address
// Input:
// Output: Direccion IP del cliente
// Descripcion: Funcion utilizada para conocer la direccion IP del cliente
//--------------------------------------------------------------------------
function get_remote_address() {
   $result='';
   isset($_SERVER['REMOTE_ADDR']) ? ($result=$_SERVER['REMOTE_ADDR']) : ($result='Direccion IP no definida');
   return $result;
}

function cid($hidx){
   $cid='default';
   return $cid;
}

function dispositivos_alarmados(){
   $da = array();
   $data = array();
   $result = doQuery('all_devices_no_condition',$data);
   foreach ($result['obj'] as $r){
      $da[$r['id_dev']]['red']=0;
      $da[$r['id_dev']]['orange']=0;
      $da[$r['id_dev']]['yellow']=0;
      $da[$r['id_dev']]['blue']=0;
   }
   $data = array();
   $result = doQuery('dispositivos_alarmados',$data);
   foreach ($result['obj'] as $r){
      if($r['severity']=='1'){$da[$r['id_device']]['red']++;}
      if($r['severity']=='2'){$da[$r['id_device']]['orange']++;}
      if($r['severity']=='3'){$da[$r['id_device']]['yellow']++;}
      if($r['severity']=='4'){$da[$r['id_device']]['blue']++;}
   }
   return $da;
}
function local_ip(){
   #$local_ip = chop(`/sbin/ifconfig eth0|grep 'inet addr'|cut -d ":" -f2|cut -d " " -f1`);
   $iface = local_iface();
   $local_ip = chop(`/sbin/ifconfig $iface|grep 'inet addr'|cut -d ":" -f2|cut -d " " -f1`);
   return $local_ip;
}

function local_iface(){
   $iface = 'eth0';
   $file = '/cfg/onm.if';
   if(file_exists($file) and false!=file_get_contents($file)){
      $iface = chop(file_get_contents($file));
   }
   return $iface;
}

/*
 * Function: dispositivo_modificar_campos_personalizados()
 * Input: 
 *    $id_dev   => Id del dispositivo al que le queremos modificar los campos de usuario
 *    $a_campos => array con N entradas descr => Valor (array('Proveedor' => 'OKI', 'Precio' => 1000))
 * Output: 
 *    rc    => 0:OK | 1: Error no fatal | 2: Error fatal
 *    rcstr => Descripción del error en caso de existir
 *    data  => array con la descripción de la actualización cada campo
 *
*/
function dispositivo_modificar_campos_personalizados($id_dev,$a_campos){
global $dbc;

	$a_return = array('rc'=>0,'rcstr'=>'','data'=>array());



   $sql_insertar="INSERT INTO devices_custom_data (id_dev) VALUES ($id_dev)";
   $result_insertar = $dbc->query($sql_insertar);

/*
+----+---------------------+------+
| id | descr               | tipo |
+----+---------------------+------+
|  1 | Proveedor           |    0 |
|  2 | Fabricante          |    0 |
|  3 | Responsable interno |    0 |
|  4 | Descripcion         |    1 |
|  5 | Precio              |    0 |
|  6 | Link                |    2 |
|  7 | IP Secundaria       |    0 |
+----+---------------------+------+
*/
	$a_asoc = array();
   $sql2="SELECT id,descr FROM devices_custom_types";
   $result2 = $dbc->query($sql2);
   while ($result2->fetchInto($r2))	$a_asoc[$r2['descr']] = $r2['id'];

	foreach($a_campos as $key=>$value){
		// El campo de usuario que ha metido el usuario no existe en la BBDD
		if(!array_key_exists($key,$a_asoc)){
			$a_return['rc'] = 1;
			$a_return['data'][]=array('key'=>$key,'descr'=>'The field doesnt exist in the CNM database');
			continue;
		}
      $dato=$dbc->escapeSimple($value);

      // SSV: PROXY INVERSO
      $dato=str_replace('[proxy]', '____PROXY____[proxy]', $dato);

      $sql4="UPDATE devices_custom_data SET columna{$a_asoc[$key]}='$dato' WHERE id_dev=$id_dev";
      $result4 = $dbc->query($sql4);

      /////////////////////////////////////////////////////////////////
      // MYSQL NO ADMITE PONER DEFAULT VALUE EN CAMPOS TEXT          //
      // SOLUCION: ACTUALIZAMOS A - LAS COLUMNAS QUE NO TENGAN DATOS //
      /////////////////////////////////////////////////////////////////
      $sql5="UPDATE devices_custom_data SET columna{$a_asoc[$key]} ='-' WHERE columna{$a_asoc[$key]} ='' or columna{$a_asoc[$key]} IS NULL";
      $result5 = $dbc->query($sql5);
   }
   return $a_return;
}

/*
 * Function: dispositivo_asociar_perfiles()
 * Input: 
 *    $id_dev     => Id del dispositivo al que le queremos modificar los campos de usuario
 *    $a_profiles => array con los perfiles a los que queremos asociar el dispositivo => array('Global','Coca cola','Pepsico')
 * Output: 
 *    rc    => 0:OK | 1: Error no fatal | 2: Error fatal
 *    rcstr => Descripción del error en caso de existir
 *    data  => array con 
 *
*/
function dispositivo_asociar_perfiles($id_dev,$a_profiles,$cid='default'){
global $dbc;

	$a_profiles = array_unique($a_profiles); // Eliminamos perfiles duplicados
	$a_profiles = array_filter($a_profiles); // Eliminamos perfiles vacios

	$a_return = array('rc'=>0,'rcstr'=>'','data'=>array());



/*
mysql> select * from cfg_devices2organizational_profile;
+--------+-----------+---------+
| id_dev | id_cfg_op | cid     |
+--------+-----------+---------+
|      0 |         1 | default |
|      1 |         1 |         |
|      1 |         1 | default |
|      1 |         2 | default |
|      1 |         3 | default |
|      3 |         1 | default |
|      4 |         1 | default |
|      9 |         1 | default |
|     10 |         1 | default |
|     11 |         1 | default |
+--------+-----------+---------+

mysql> select * from cfg_organizational_profile;
+-----------+----------------+------------+
| id_cfg_op | descr          | user_group |
+-----------+----------------+------------+
|         1 | Global         | ,3,1,      |
|         2 | s30            | ,5,        |
|         3 | Sistemas       | ,4,        |
|         4 | Comunicaciones |            |
|         5 | Impresoras     | ,5,        |
+-----------+----------------+------------+
5 rows in set (0.00 sec)
*/
	$a_asoc = array();
   $sql2="SELECT id_cfg_op,descr FROM cfg_organizational_profile";
   $result2 = $dbc->query($sql2);
   while ($result2->fetchInto($r2))$a_asoc[$r2['descr']] = $r2['id_cfg_op'];

	foreach($a_asoc as $descr => $id_cfg_op){
		// Se inserta
		if(in_array($descr,$a_profiles)){
			$sql3 = "INSERT IGNORE INTO cfg_devices2organizational_profile (id_dev,id_cfg_op,cid) VALUES ($id_dev,$id_cfg_op,'$cid')";
		}
		// Se borra
		else{
			$sql3 = "DELETE FROM cfg_devices2organizational_profile WHERE id_dev=$id_dev AND id_cfg_op=$id_cfg_op AND cid='$cid'";
		}
		$result3 = $dbc->query($sql3);
	}


	foreach($a_profiles as $profile){
		// El campo de usuario que ha metido el usuario no existe en la BBDD
		if(!array_key_exists($profile,$a_asoc)){
			$a_return['rc'] = 1;
			$a_return['data'][]=array('profile'=>$field,'descr'=>'The profile doesnt exist in the CNM database');
			continue;
		}
   }
   return $a_return;

}
?>
