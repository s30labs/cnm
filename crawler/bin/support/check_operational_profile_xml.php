<?php
/*
	Programa que comprueba que las entradas referentes a toolbar están en el fichero que se usa para el perfil operativo



*/
	$xml = leer_fichero_completo('/var/www/html/onm/cnm_operational_profile.xml');

	$path1 = '/var/www/html/onm';
	$a_ignore_file1 = array(
		'mod_alertas_notificar_mail.php',
		'mod_dispositivo_graficas_resumen_eventos.php',
		'mod_dispositivo_graficas_resumen_historico.php',
		'mod_app_resultado.php',
		'mod_alertas_dashboard_simple.php',
		'mod_documentacion_files.php',
		'mod_vistas_graficas_validar.php',
		'mod_dispositivo_graficas_validar.php',
		'mod_alertas_notificar_sms.php',
		'mod_alertas_dashboard.php',
		'mod_halertas_dashboard.php',
		'mod_vistas_graficas.php',
		'mod_dispositivo_graficas.php',
		'mod_conf_misc_global_capturalogs.php',
	);

	$path2 = '/var/www/html/onm/custom';
   $a_ignore_file2 = array(
		'mod_analisis.php',
		'mod_global_vistas_graficas.php',
		'mod_halertas_ticket.php',
		'mod_alertas_ticket.php',
		'mod_analisis_detalle.php',
   );

	// check_operational_profile($path1,$a_ignore_file1,$xml);
	// check_operational_profile($path2,$a_ignore_file2,$xml);
	// check_file_xml();

	function check_operational_profile($path,$a_ignore_file,$xml){
		$a_file = array();
		$dir_handle = @opendir($path) or die("No se pudo abrir $path");
		while ($file = readdir($dir_handle)) {
			if(! is_file($path.'/'.$file)) continue;
			if (preg_match("/^mod_.*\.php/", $file)) {
				$a_file[]=$file;
			}
		}
		closedir($dir_handle);
	
	
		foreach($a_file as $f){
			if(in_array($f,$a_ignore_file))continue;
	

			$file = fopen($path.'/'.$f, "r") or exit("Unable to open file!");
			//Output a line of the file until the end is reached
				while(!feof($file)){
				$line = fgets($file);
				if(preg_match("/addCol/i",$line))   continue;
				if(preg_match("/row_meta/i",$line)) continue;
				// if(preg_match("/array('id'=>'/", $line)){
				if(preg_match("/^.*array.*\(\s*'id'\s*=>'(\w*)'.*$/", $line,$res)){
					// print "LINE == $line\n";
					// print_r($res);
					// print"{$res[1]} ";
					$id = $res[1];
					// if(preg_match("/^\s*<item\s*id=\"$id\"\s*text.*$/",$xml)){
					if(preg_match("/\"$id\"/",$xml)){
						// print "OK\n";
					}
					else{
						print "NOOK\n";
						print "FILE == $f\n";
						print "LINE == $id\n";
						print "----------------------------\n";
					}
	
				}
			}
			fclose($file);
		}
	}
	
function check_file_xml(){
   $file = fopen('/var/www/html/onm/cnm_operational_profile.xml', "r") or exit("Unable to open file!");
 	//Output a line of the file until the end is reached
   while(!feof($file)){
   $line = fgets($file);
   if(!preg_match("/__/",$line))   continue;

   if(preg_match("/^.*item\s*id\s*=\"(\w*)\".*__(\w*)__/", $line,$res)){
		if(strtoupper($res[1])!=strtoupper($res[2])){
			print "{$res[1]} != {$res[2]}\n";
		}
   }else{
		print "MAL\n";
		print "$line\n";
	}
}
   fclose($file);
}
function leer_fichero_completo($nombre_fichero){
   //abrimos el archivo de texto y obtenemos el identificador
   $fichero_texto = fopen ($nombre_fichero, "r");
   //obtenemos de una sola vez todo el contenido del fichero
   //OJO! Debido a filesize(), sólo funcionará con archivos de texto
   $contenido_fichero = fread($fichero_texto, filesize($nombre_fichero));
   return $contenido_fichero;
}
?>
