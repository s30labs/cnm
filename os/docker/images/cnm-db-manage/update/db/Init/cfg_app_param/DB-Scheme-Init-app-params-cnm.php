<?php

//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
//linux_app_restore_passive_from_active.pl
//RESTAURA DATOS DESDE BACKUP REMOTO SI ES UN EQUIPO PASIVO
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_cnm_restore', 'hparam' => '10000010', 'type' => 'cnm', 'enable' => '1', 'value' => '',
      'script' => 'linux_app_restore_passive_from_active.pl',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_cnm_restore', 'hparam' => '10000012', 'type' => 'cnm', 'enable' => '1', 'value' => 'cnm',
      'script' => 'linux_app_restore_passive_from_active.pl',
   );
   $CFG_APP_PARAM[]=array(
      'aname' => 'app_cnm_restore', 'hparam' => '10000013', 'type' => 'cnm', 'enable' => '1', 'value' => 'cnm123',
      'script' => 'linux_app_restore_passive_from_active.pl',
   );

?>
