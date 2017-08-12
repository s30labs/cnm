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
	* Inserccion de datos en la tabla ticket 
	* *****************************************************************************
	*/
	$tablas=array('alerts_store');
	$error=0;
	foreach ($tablas as $tabla){
	   $sql="SELECT id_alert,id_device,id_note_type,notes,date_store,event_data,note_id
				FROM $tabla
				WHERE notes IS NOT NULL";
	   $result = $dbc->query($sql);
	   while ($result->fetchInto($r)){
			$id_alert=$r['id_alert'];
			$id_dev=$r['id_device'];
			$ticket_type=$r['id_note_type'];
			$descr=mysql_real_escape_string ($r['notes']);
			$ref=mysql_real_escape_string ($r['note_id']);
			$date_store=$r['date_store'];
			$event_data=mysql_real_escape_string ($r['event_data']);
	
			$sql2="INSERT INTO ticket 
					(id_dev,id_alert,ticket_type,descr,id_problem,ref,date_store,event_data) values
					($id_dev,$id_alert,$ticket_type,'$descr',0,'$ref',$date_store,'$event_data')";
			// print "$sql2\n";
	   	$result2 = $dbc->query($sql2);
			if (@PEAR::isError($result2)) {
            $msg_error=$result2->getMessage();
            print("ERROR AL HACER *** $sql2 *** MENSAJE DE ERROR *** $msg_error ***\n");
				$error=1;
         }
	   }
	}
	if ($error==1){
		print "**** HA HABIDO PROBLEMAS *****\n";
	}
	if ($error==0){
      print "**** HA FUNCIONADO CORRECTAMENTE *****\n";
   }
?>
