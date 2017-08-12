<?php

   $NOTIFICATION_TYPE = array(
      array(
         'id_notification_type' => '1',
         'name' => 'email',
         'dest_field' => 'To',
         'descr' => 'Aviso mediante e-mail',
      ),
      array(
         'id_notification_type' => '2',
         'name' => 'sms',
         'dest_field' => 'Tfno',
         'descr' => 'Aviso mediante SMS',
      ),
      array(
         'id_notification_type' => '3',
         'name' => 'snmp-trap',
         'dest_field' => 'IP',
         'descr' => 'Aviso mediante trap SNMP',
      ),
   );
?>
