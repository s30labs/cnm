<?php
$CFG_USERS = array(
      array(
         'id_user' => '1',
         'login_name' => 'admin',
         'passwd' => '',
         'descr' => 'Usuario Administrador',
         'perfil' => '1',
			'timeout' => 1440,
			'token' => '7c50ce209c4045816b1e7449525709a0c5f68cf865da06c7b6dd0313e448f54233ce8327',
      ),
/*
      array(
         'id_user' => '9999',
         'login_name' => 'test',
         'passwd' => '',
         'descr' => 'Usuario de test',
         'perfil' => '1',
         'timeout' => 1440,
         'token' => '7c50ce209c4045816b1e7449525709a0c5f68cf865da06c7b6dd0313e448f54233ce8327',
      ),
		// NOTA: Para ver que la actualización funciona correctamente, descomentar, hacer un db-manage.php -u cfg_users o un db-manage.php a secas, poner a vacio el campo token del usuario test, cambiar la descripción y volver a ejecutar el db-manage.php
*/
);
?>
