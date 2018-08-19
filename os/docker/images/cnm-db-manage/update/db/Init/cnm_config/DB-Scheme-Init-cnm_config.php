<?php
$CNM_CONFIG[] = array(
   'cnm_key'=>"max_days_event",
   'cnm_value'=>"90",
   'cnm_descr'=>"Profundidad en días del histórico de eventos",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"max_number_event",
   'cnm_value'=>"500000",
   'cnm_descr'=>"Número de eventos máximo",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"max_days_alerts_store",
   'cnm_value'=>"180",
   'cnm_descr'=>"Profundidad en días del histórico de alertas",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"max_number_alerts_store",
   'cnm_value'=>"750000",
   'cnm_descr'=>"Número máximo de alertas en el histórico",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"max_days_audit",
   'cnm_value'=>"370",
   'cnm_descr'=>"Profundidad en días de la auditoria",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"max_number_audit",
   'cnm_value'=>"1000000",
   'cnm_descr'=>"Número máximo de entradas en auditoria",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"notif_lapse",
   'cnm_value'=>"60",
   'cnm_descr'=>"Intervalo para envio de notificaciones",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"notif_mx",
   'cnm_value'=>"",
   'cnm_descr'=>"Servidor SMTP utilizado para el envio de correo",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"notif_from",
   'cnm_value'=>"",
   'cnm_descr'=>"Campo From: del mensaje de correo",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"notif_from_name",
   'cnm_value'=>"",
   'cnm_descr'=>"Nombre que aparece en el From del mensaje de correo",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"notif_subject",
   'cnm_value'=>"",
   'cnm_descr'=>"Asunto del correo",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"notif_serial_port_name",
   'cnm_value'=>"",
   'cnm_descr'=>"Nombre del puerto serie",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"notif_pin",
   'cnm_value'=>"",
   'cnm_descr'=>"PIN del terminal GSM utilizado para el envio de mensajes SMS",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"notif_serial_port_baudrate",
   'cnm_value'=>"",
   'cnm_descr'=>"Parametro de configuracion del puerto serie. Velocidad (baudios)",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"notif_serial_port_parity",
   'cnm_value'=>"",
   'cnm_descr'=>"Parametro de configuracion del puerto serie. Paridad utilizada de los datos",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"notif_serial_port_databits",
   'cnm_value'=>"",
   'cnm_descr'=>"Parametro de configuracion del puerto serie. Numero de bits de los datos",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"notif_serial_port_stopbits",
   'cnm_value'=>"",
   'cnm_descr'=>"Parametro de configuracion del puerto serie. Bit de parada",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"notif_serial_port_handshake",
   'cnm_value'=>"",
   'cnm_descr'=>"Parametro de configuracion del puerto serie. Uso de handshake",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"update_server_type",
   'cnm_value'=>"",
   'cnm_descr'=>"",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"update_server_name",
   'cnm_value'=>"",
   'cnm_descr'=>"",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"update_server_use",
   'cnm_value'=>"",
   'cnm_descr'=>"",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"update_server_value",
   'cnm_value'=>"",
   'cnm_descr'=>"",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"update_server_port",
   'cnm_value'=>"",
   'cnm_descr'=>"",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"update_server_user",
   'cnm_value'=>"",
   'cnm_descr'=>"",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"update_server_key",
   'cnm_value'=>"",
   'cnm_descr'=>"",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"update_server_default",
   'cnm_value'=>"",
   'cnm_descr'=>"",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"snmp_v1v2_communities",
   'cnm_value'=>"public",
   'cnm_descr'=>"Comunidades SNMP v1/v2 para usar por defecto en provision. (Separadas por espacio en blanco)",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"gmaps_key_id",
   'cnm_value'=>"",
   'cnm_descr'=>"KEY ID de Google Maps para mostrar la localización en CNM de dispositivos.",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"gmaps_scale",
   'cnm_value'=>"8",
   'cnm_descr'=>"Escala utilizada al mostrar los mapas de Google Maps.",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"cnm_language",
   'cnm_value'=>"es_ES",
   'cnm_descr'=>"Idioma de CNM.",
);
// PROXY
$CNM_CONFIG[] = array(
   'cnm_key'=>"proxy_host",
   'cnm_value'=>"",
   'cnm_descr'=>"Dirección ip del proxy HTTP",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"proxy_port",
   'cnm_value'=>"",
   'cnm_descr'=>"Puerto del proxy HTTP",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"proxy_user",
   'cnm_value'=>"",
   'cnm_descr'=>"Usuario del proxy HTTP",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"proxy_passwd",
   'cnm_value'=>"",
   'cnm_descr'=>"Contraseña del proxy HTTP",
);
$CNM_CONFIG[] = array(
   'cnm_key'=>"proxy_enable",
   'cnm_value'=>"0",
   'cnm_descr'=>"0 (Deshabilitado) | 1 (Habilitado)",
);
?>
