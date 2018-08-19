<?php
 /**
	* *****************************************************************************
	* Modulo: ticket.php
	* Descripcion: Ejecutable que inserta en la tabla ticket los datos iniciales
	* *****************************************************************************
	*/
	require_once('/usr/share/pear/DB.php');

 /**
	* *****************************************************************************
	* Comunicacion con la BBDD
	* *****************************************************************************
	*/
   $dsn = array(
      'phptype'  => 'mysql',
      'username' => 'onm',
      'hostspec' => 'localhost',
      'database' => 'onm',
   );
	$dsn['password'] = chop(`cat /cfg/onm.conf | grep DB_PWD|cut -d "=" -f2 | tr -d ' '`);
   // Se realiza la conexion con la base de datos de forma persistente (TRUE)
   $dbc = @DB::Connect($dsn,TRUE);

   if (@PEAR::isError($dbc)) {
      depura('mysql_session_abreBD:: Conexion a onm',$dbc->getMessage());
   }else {
      $dbc->setFetchMode(DB_FETCHMODE_ASSOC);
   }

   $sql="SET CHARACTER SET 'utf8'";
   $result = $dbc->query($sql);


 /**
	* *****************************************************************************
	*/
	$tablas = array('cfg_monitor_snmp','devices');
	foreach ($tablas as $tabla){
		$sql="SELECT COUNT(*) AS cnt FROM $tabla";
      $result = $dbc->query($sql);
		if (@PEAR::isError($result)) {
			$msg_error=$result->getMessage();
         print("ERROR AL HACER *** $sql *** MENSAJE DE ERROR *** $msg_error ***\n");
			continue;
     	}
      while ($result->fetchInto($r)){
			print "$tabla\t{$r['cnt']}\n";
		}
	}
?>
