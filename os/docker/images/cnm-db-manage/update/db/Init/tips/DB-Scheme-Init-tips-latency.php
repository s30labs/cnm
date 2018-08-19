<?php
//---------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------
// tip_class=0 => De usuario tip_class=1 => De sistema (no se edita ni se borra)
//---------------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------------- 
// Metrica de tipo TCP/IP ('tip_type' => 'latency',)
// El id_ref coincide con el subtype de la metrica de tipo latency
//---------------------------------------------------------------------------------------------------------


      $TIPS[]=array(
         'id_ref' => 'disp_icmp',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Envia varios paquetes de tipo ping (icmp request) de 64 bytes al equipo remoto y si pierde mas del 30% genera un error.Monitoriza la disponibilidad cada minuto',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_icmp',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Envia varios paquetes de tipo ping (icmp request) de 64 bytes al equipo remoto y si pierde mas del 30% genera un error.Monitoriza el tiempo de respuesta',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_ip_icmp2',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Envia varios paquetes de tipo ping (icmp request) de 64 bytes al equipo remoto y si pierde mas del 30% genera un error.Monitoriza el tiempo de respuesta',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_ip_icmp3',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Envia varios paquetes de tipo ping (icmp request) de 64 bytes al equipo remoto y si pierde mas del 30% genera un error.Monitoriza el tiempo de respuesta',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_http',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Hace una peticion HTTP/HTTPS (GET/POST) y monitoriza el tiempo de respuesta del servidor WEB.'
      );
      $TIPS[]=array(
         'id_ref' => 'mon_httprc',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Hace una peticion HTTP/HTTPS (GET/POST). Devuelve el codigo de respuesta del servidor segun el siguiente criterio: 1xx=>1, 2xx=>2, 3xx=>3 , 4xx=>4, 5xx=>5.',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_httplinks',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Hace una peticion HTTP/HTTPS (GET/POST). Obtiene el numero de enlaces de una pagina WEB.',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_httppage',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Hace una peticion HTTP/HTTPS (GET/POST). Comprueba el contenido de la pagina obtenida con una que tiene como referencia y obtiene el nuero de diferencias.',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_pop3',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Metrica TCP/IP que hace login a un buzon POP3 y devuelve el tiempo de respuesta',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_imap',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Efectua un login IMAP4, para ello requiere usuario y password.Monitoriza el tiempo de respuesta',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_smtp',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Efectua un HELO SMTP. Monitoriza el tiempo de respuesta',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_dns',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Efectua un query DNS a un registro de tipo A.Monitoriza el tiempo de respuesta',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_tcp',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Envia un TCP SYN al puerto servidor especificado. Monitoriza el tiempo de respuesta',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_ssh',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Obtiene el banner inicial de una sesion SSH. Monitoriza el tiempo de respuesta',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_smb',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Comprueba la existencia de un fichero compartido por SMB/CIFS.',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_ntp',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Hace una peticion NTP. Monitoriza el tiempo de respuesta',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_ldap',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Accede a los elementos especificados del directorio LDAP. Obtiene el tiempo de respuesta.',
      );

      $TIPS[]=array(
         'id_ref' => 'mon_ldap_attr',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Comprueba si el valor del atributo especificado del directorio LDAP coincide con el valor suministrado.',
      );

      $TIPS[]=array(
         'id_ref' => 'mon_ldap_val',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Obtiene el valor de un atributo concreto del arbol LDAP.',
      );
      $TIPS[]=array(
         'id_ref' => 'mon_smtp_ext',                 'tip_type' => 'latency',
         'url' => '',      'date' => '',     'tip_class' => 1,
         'name' => 'Descripcion',
         'descr' => 'Obtiene la respuesta de un servidor SMTP.',
      );

?>
