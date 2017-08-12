<?php


	abstract class cnmbackup {

		private static $path = '/home/cnm/backup/cnm_backup.tar';

		static function upload($file){
			$a_res = array('rc'=>0,'rcstr'=>'');
			/*
			$file = Array (
				[name]     => pid
			   [type]     => application/octet-stream
			   [tmp_name] => /tmp/phpXwJ0MS
			   [error]    => 0
			   [size]     => 108
			)
			*/

			// Si el usuario no es admin devolvemos error
			if($_SESSION['LUSER']!='admin'){
				$a_res['rc']    = 1;
            $a_res['rcstr'] = "ONLY admin USER IS ALLOWED TO UPLOAD BACKUP";
            return $a_res;
			}
			// //////////// //
			// Validaciones //
			// //////////// //
			if(!array_key_exists('error',$file)){
				$a_res['rc']    = 1;
				$a_res['rcstr'] = 'ERROR UPLOADING FILE'; 				
				return $a_res;
			}
			if($file['error']!=0){
				$a_res['rc']    = $file['error'];
				$a_res['rcstr'] = 'ERROR UPLOADING FILE';
				return $a_res;
			}
			if($file['size']==0){
				$a_res['rc']    = 1;
				$a_res['rcstr'] = 'FILE SIZE = 0';
				return $a_res;
			}

			move_uploaded_file($file["tmp_name"],self::$path);
			self::restore();

			return $a_res;	
		}

		static function download(){
         // Si el usuario no es admin devolvemos error
         if($_SESSION['LUSER']!='admin'){
            $a_res['rc']    = 1;
            $a_res['rcstr'] = "ONLY admin USER IS ALLOWED TO DOWNLOAD BACKUP";
            return $a_res;
         }

			header("X-Sendfile: ".self::$path);
			header("Content-type: application/octet-stream");
			header('Content-Disposition: attachment; filename="' . basename(self::$path) . '"');
			readfile(self::$path);
			exit;
		}

		static function restore(){
			$a_res = array('rc'=>0,'rcstr'=>'');

			// Validaciones
			if(!is_file(self::$path)){
            $a_res['rc']    = 1;
            $a_res['rcstr'] = 'FILE '.self::$path.' DOES NOT EXIST';
            return $a_res;
			}

			exec('/usr/bin/php /var/www/html/onm/inc/Backup.php action=restore');
			return $a_res;
		}

		/*
		* Function: backup()
		* Input:
		* Output:
		* Description: Hace un backup completo del sistema
		*/
      static function backup(){
         $a_res = array('rc'=>0,'rcstr'=>'');
         exec('sudo /usr/bin/php /var/www/html/onm/inc/Backup.php action=backup');
         return $a_res;
      }

      /*
      * Function: info()
      * Input:
      * Output: 
		*         a_res['status']: 0 acabado | 1 en curso
		*         a_res['date']:   fecha de creación
		*         a_res['size']:   tamaño en megas
      * Description: Devuelve información del backup
      */
      static function info(){
			$flag_file = '/var/run/cnm_backup.pid';
			$backup_file = '/home/cnm/backup/cnm_backup.tar';

			$a_res = array('status'=>0,'date'=>'');

			if(file_exists($flag_file)) $a_res['status'] = 1;

			$intfilemtime = filemtime($backup_file);
			$a_res['date'] = date ("Y-m-d H:i:s",$intfilemtime);

			$intfilesize = filesize($backup_file);
			$a_res['size'] = round($intfilesize/1048576,2);
			return $a_res;
      }
	}
?>
