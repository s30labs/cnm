<?php
   include_once('inc/class.cnmbackup.php');

// ------------------------------------------------------------------------------
// inc/CNMAPI/Backup.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_backup
// ------------------------------------------------------------------------------
// IN: 	
// OUT:	
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -k -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
// "https://localhost/onm/api/1.0/backup.json" > cnm_backup.tar => Descarga el ultimo backup
// ------------------------------------------------------------------------------
function api_get_backup() {
	cnmbackup::download();
}

// ------------------------------------------------------------------------------
// api_post_backup
// ------------------------------------------------------------------------------
// IN:   
// OUT:  
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X POST => BASE
// "https://localhost/onm/api/1.0/backup.json" -F "file=@/tmp/cnm_backup.tar" => Sube el backup
function api_post_backup(){
	$a_res = cnmbackup::upload($_FILES['file']);
   return $a_res;
}

// ------------------------------------------------------------------------------
// api_info_backup
// ------------------------------------------------------------------------------
// IN:   
// OUT:  
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
// "https://localhost/onm/api/1.0/backup/info.json" => Devuelve información del último backup
function api_info_backup(){
   $a_res = cnmbackup::info();
   return $a_res;
}

// ------------------------------------------------------------------------------
// api_put_backup
// ------------------------------------------------------------------------------
// IN:   
// OUT:  
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X PUT => BASE
// "https://localhost/onm/api/1.0/backup.json" => Realiza un backup del sistema
function api_put_backup(){
   $a_res = cnmbackup::backup();
   return $a_res;
}
?>
