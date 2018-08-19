<?php
 /**
	* *****************************************************************************
	* Modulo: test_db_mysqli.php
	* Descripcion: Test de acceso a BBDD con mysqli
	* *****************************************************************************
	*/
 /**
	* *****************************************************************************
	* Conexion a la BBDD
	* *****************************************************************************
	*/
    $dbsystem='mysql';
    $host='127.0.0.1';
    $dbname='onm';
    $username='onm';
    $passwd=chop(`cat /cfg/onm.conf | grep DB_PWD|cut -d "=" -f2 | tr -d ' '`);
	 echo "Conexión a la base de datos: $dbname ($dbsystem:$host)\n";
    $connection = mysqli_connect($host, $username, $passwd, $dbname);             
    if ($connection){
        echo '**OK** '.mysqli_get_host_info($connection)."\n";
    }else{                
        echo 'Error al establecer la conexión  ('.mysqli_connect_errno().'): '.mysqli_connect_error()."\n";    
        exit();
    }

	$query="SET CHARACTER SET 'utf8'";
   $result = mysqli_query($connection, $query);
	if (mysqli_error($connection) != 0) {
   	echo '**ERROR**SET CHARACTER SET -> utf8 ('.mysqli_sqlstate($connection).'):'.mysqli_error($connection)."\n";
	}

 /**
	* *****************************************************************************
	*/

   $tablas = array('cfg_monitor_snmp','devices');
   foreach ($tablas as $tabla){
   	$query="SELECT COUNT(*) AS cnt FROM $tabla";
      $result = mysqli_query($connection, $query);
      if ($result){
      	while($row = mysqli_fetch_assoc($result)){
				print "$tabla\t{$row['cnt']}\n";
      	}
		}
      else {
      	echo 'Error al hacer la consulta ('.mysqli_sqlstate($connection).'):'.mysqli_error($connection)."\n";         
      }
	}

?>
