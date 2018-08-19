<?php
 /**
	* *****************************************************************************
	* Modulo: test_db_pdo.php
	* Descripcion: Test de acceso a BBDD con PDO
	* *****************************************************************************
	*/

 /**
	* *****************************************************************************
	* Conexion a la BBDD
	* *****************************************************************************
	*/

	 $dbsystem='mysql';
	 $host=chop(`cat /cfg/onm.conf |  grep -v '#DB_SERVER' | grep DB_SERVER|cut -d "=" -f2 | tr -d ' '`);
    $dbname='onm';
    $dsn=$dbsystem.':host='.$host.';dbname='.$dbname;
    $username='onm';
    $passwd=chop(`cat /cfg/onm.conf | grep DB_PWD|cut -d "=" -f2 | tr -d ' '`);
    $connection = null;
    echo 'Conexión a la base de datos: '.$dsn."\n";
    try {          
        $connection = new PDO($dsn, $username, $passwd);
        echo "**OK**\n";
    } catch (PDOException $pdoExcetion) {
        $connection = null;
        echo "Error al establecer la conexión: $pdoExcetion\n";
    }


	try{
   	$query="SET CHARACTER SET 'utf8';";
      $statement = $connection->prepare($query);
      $result = $statement->execute();
   } catch (PDOException $pdoExcetion) {
   		echo '**ERROR** SET CHARACTER SET -> utf8: '.$pdoExcetion->getMessage();
   }

 /**
	* *****************************************************************************
	*/

	$tablas = array('cfg_monitor_snmp','devices');
   foreach ($tablas as $tabla){
		try{
    		$query="SELECT COUNT(*) AS cnt FROM $tabla;";
    		$statement = $connection->prepare($query);
    		$result = $statement->execute();
    		$rows = $statement->fetchAll(\PDO::FETCH_OBJ);
    		foreach ($rows as $row) {
				print "$tabla\t".$row->cnt."\n";
    		}   
		} catch (PDOException $pdoExcetion) {
    		echo 'Error hacer la consulta: '.$pdoExcetion->getMessage();
		}
	}

?>
