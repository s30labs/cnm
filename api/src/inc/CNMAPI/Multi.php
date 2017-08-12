<?php
   include_once('inc/class.cnmmulti.php');

// ------------------------------------------------------------------------------
// inc/CNMAPI/Multi.php
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// api_get_multi
// ------------------------------------------------------------------------------
// IN: 	
// OUT:	
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -k -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
// "https://localhost/onm/api/1.0/multi.json" => Obtiene los datos Descarga el ultimo backup
// ------------------------------------------------------------------------------
function api_get_multi() {
   $a_res  = cnmmulti::get();
   return $a_res;
}

// ------------------------------------------------------------------------------
// api_put_multi
// ------------------------------------------------------------------------------
// IN:   
// OUT:  
// ------------------------------------------------------------------------------
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X PUT => BASE
// "https://localhost/onm/api/1.0/multi.json" => Sincroniza el multi CNM
function api_put_multi(){
   $a_res = cnmmulti::put();
   return $a_res;
}
?>
