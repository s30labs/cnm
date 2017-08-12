<?php
//---------------------------------------------------------------------------
// PERFILES
// 1 -> ADMINISTRADOR
// 2 -> INVITADO
// 4 -> OPERADOR
// 8 -> DESARROLLO
// 16-> ADMINISTRADOR DE GRUPO
// 32-> USUARIO WEB
//---------------------------------------------------------------------------
//
//
// Para calcular el valor que debe tener asociado cada boton, debemos sumar los
// valores de los perfiles que vayan a tener acceso a dicho boton
//
// Por ejemplo, si queremos que para un boton determinado tengan acceso el perfil
// ADMINISTRADOR y el perfil OPERADOR, sumaremos 1 (ADMINISTRADOR) y 4 (OPERADOR)
// resultando el valor 5.

	$perm=array();
	// configure_device_tab.php
	$perm['dispositivo_tab_disp']=1+8+16;
	$perm['dispositivo_tab_mtr_asistente']=1+8+16;
	$perm['dispositivo_tab_mtr_plantilla']=1+8+16;
	$perm['dispositivo_tab_mtr_curso']=1+4+8+16+32;
	$perm['dispositivo_tab_doc']=1+2+4+8+16+32;
	$perm['dispositivo_tab_app']=1+2+4+8+16+32;
   function showTab(&$solapas,$solapa,$PERFIL){
	global $perm;
		if (!$perm[$solapa[0]]){return;}
		if ($perm[$solapa[0]] & $PERFIL){$solapas[]=$solapa;}
   }





	$but=array();
	$but['dispositivo_tab_mtr_curso_activar']=array(1+8+16,'<a href="javascript:dispositivo_tab_mtr_curso_activar()"><strong>Activar</strong></a> | ');
	$but['dispositivo_tab_mtr_curso_desactivar']=array(1+8+16,'<a href="javascript:dispositivo_tab_mtr_curso_desactivar()"><strong>Desactivar</strong></a> | ');
	$but['dispositivo_tab_mtr_curso_borrar']=array(1+8+16,'<a href="javascript:dispositivo_tab_mtr_curso_borrar()"><strong>Eliminar</strong></a> | ');
	function showButton($func,$PERFIL){
	global $but;
		if (!$func){return;}
		if ($but[$func][0] & $PERFIL){return $but[$func][1];}
	}

?>
