<?php
// --------------------------------------------------------------------------------------------
// api10.php
//
//	Requiere la siguiente configuracion del apache:
// 
//      <IfModule mod_rewrite.c>
//         RewriteEngine On
//         RewriteBase /onm/api/
//         RewriteRule 1.0/(.+)\.(xml|json|atom) api10.php?endpoint=$1&content_type=$2&%{QUERY_STRING} [NC,L]
//      </IfModule>
//
//	Ejemplos de uso:
//		curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// 	curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" "https://localhost/onm/api/1.0/views.json"
//
// NOTA: si queremos obtener el resultado JSON formateado debemos incluir al final del comando lo siguiente => |python -mjson.tool
// NOTA: si queremos ocultar las cabeceras en la respuesta debemos quitar la opción i
// NOTA: si queremos ocultar las estadísticas de curl debemos añadir las opciones S y s (-Ss)
// --------------------------------------------------------------------------------------------

                                                           /////////////////
                                                           //// /////// ////
                                                           //// DEVICES ////
                                                           //// /////// ////
                                                           /////////////////

// //////////// //
// Devices: GET //
// //////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
// 
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
//
// "https://localhost/onm/api/1.0/devices.json"                       => Información de todos los dispositivos
// "https://localhost/onm/api/1.0/devices/12.json"                    => Información del dispositivo 12
// "https://localhost/onm/api/1.0/devices.json?id=12"                 => Información del dispositivo 12 (utilizando criterios de búsqueda)
// "https://localhost/onm/api/1.0/devices/10.2.254.223.json"          => Información del dispositivo con ip 10.2.254.223
// "https://localhost/onm/api/1.0/devices.json?ip=10.2.254.223"       => Información del dispositivo con ip 10.2.254.223 (utilizando criterios de búsqueda)
//
// "`echo "https://cnm002.s30labs.com/onm/api/1.0/devices.json?form[IP Secundaria]=1.1.1.1" | sed "s/[[:space:]]/%20/g"`"  => Información de los dispositivos con el campo de usuario IP Secundaria 1.1.1.1 (utilizando criterios de búsqueda)
// 
// token=$(curl -k "https://cnm002.s30labs.com/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6);curl -ki -g -H "Authorization: $token" -X GET "`echo "https://cnm002.s30labs.com/onm/api/1.0/devices.json" | sed "s/[[:space:]]/%20/g"`"
// token=$(curl -k "https://cnm002.s30labs.com/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6);curl -ki -g -H "Authorization: $token" -X GET "`echo "https://cnm002.s30labs.com/onm/api/1.0/devices.json?cnm_fields=id,name,domain&cnm_sort=-id" | sed "s/[[:space:]]/%20/g"`"
// 
// NOTA: Cuando tenemos espacios debemos sustituirlos por %20 (url_encode)
// NOTA: Cuando tenemos variables con espacios debemos utilizar form[] además de la sustitución previa
//
// Campos de busqueda:
// - id              => id del dispositivo
// - name            => nombre
// - domain          => dominio
// - ip              => direccion ip
// - type            => tipo de dispositivo
// - snmpversion     => 0:sin SNMP | 1:version 1 | 2:version 2 | 3:version 3 (0 si no se indica)
// - snmpcommunity   => comunidad snmp (versiones 1 y 2)
// - entity          => 0:dispositivo físico | 1:servicio web (0 si no se indica)
// - geo             => geolocalizacion en formato Google Maps
// - critic          => 25:criticidad baja | 50:criticidad media | 75:criticidad alta | 100:criticidad mazima (50 si no se indica)
// - correlated      => ID del dispositivo del que depende
// - status          => 0:activo | 1:inactivo | 2:mantenimiento (0 si no se indica)
// - profile         => perfil al que pertenece el dispositivo
// - redalerts       => alertas rojas
// - orangealerts    => alertas naranjas
// - yellowalerts    => alertas amarillas
// - bluealerts      => alertas azules
// - network         => red del dispositivo
// - mac             => direccion mac
// - macvendor       => fabricante a partir de la mac
// - snmpsysclass    => sysclass snmp
// - snmpsysdesc     => descripcion snmp
// - snmpsyslocation => localizacion snmp
// - switch          => switch al que esta conectado el dispositivo
// - xagentversion   => version del agente cnm
// - metrics         => numero de metricas activas
//
// NOTA: En caso de querer hacer un OR en un mismo campo, meter una coma. 
//       Ejemplo: name=cnm,www
//
// 
// NOTA: Los campos de búsqueda pueden usar los siguientes operadores aritméticos:
//
// - CNMGT    => >
// - CNMGTE   => >=
// - CNMLT    => <
// - CNMLTE   => <=
// - CNMLIKE  => LIKE
// - CNMNLIKE => NOT LIKE
// - CNMEQ    => =
// - CNMNEQ   => !=
//
//
// Campos auxiliares:
// - cnm_page_size => Numero de elementos por página
// - cnm_page      => Numero de página
// - cnm_fields    => Campos que queremos que devuelva separados por comas
// - cnm_sort      => Campo por el que queremos que ordene (ponerle un - en caso de querer ordenar de forma descendente por dicho campo)
//                    En caso de querer ordenar por varios campos, dichos campos deben ir separados por comas
//
//

// ///////////// //
// Devices: POST //
// ///////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X POST => BASE
// 
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X POST => BASE
//
// "https://localhost/onm/api/1.0/devices.json" -F "CAMPO1=valor1" -F "CAMPO2=valor2" -F "form[CAMPO3]=valor3"  => Se crea un dispositivo
//
// Campos disponibles:
// - name           => nombre
// - domain         => dominio
// - ip             => direccion ip
// - type           => tipo de dispositivo
// - snmpversion    => 0:sin SNMP | 1:version 1 | 2:version 2 | 3:version 3 (0 si no se indica)
// - snmpcommunity  => comunidad snmp (versiones 1 y 2)
// - snmpcredential => credencial snmp (version 3)
// - entity         => 0:dispositivo físico | 1:servicio web (0 si no se indica)
// - geo            => geolocalizacion en formato Google Maps
// - critic         => 25:criticidad baja | 50:criticidad media | 75:criticidad alta | 100:criticidad mazima (50 si no se indica)
// - correlated     => ID del dispositivo del que depende
// - status         => 0:activo | 1:inactivo | 2:mantenimiento (0 si no se indica)
// - profile        => perfil al que pertenece el dispositivo
// 
// Campos obligatorios:
// - name
// - domain
// - ip
//
// Campos de usuario:
// Los campos que se aporten y no sean de sistema se consideraran de usuario. Dichos valores se asociaran al dispositivo siempre y cuando
// los campos de usuario se hayan dado de alta previamente en CNM.
// Los campos de usuario que tengan espacios hay que indicarlos de la siguiente forma: -F "form[Usuario de acceso]=pepito"

// //////////// //
// Devices: PUT //
// //////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X PUT => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X PUT => BASE
// 
// "https://localhost/onm/api/1.0/devices/12.json?campo=valor"          => Se actualiza el campo del dispositivo con id 12
// "https://localhost/onm/api/1.0/devices/12.json" -d "campo=valor"     => Se actualiza el campo del dispositivo con id 12
// "https://localhost/onm/api/1.0/devices/12.json" -d "form[campo con espacios]=valor" => Se actualiza el campo con espacios del dispositivo con id 12
// "https://localhost/onm/api/1.0/devices/10.2.254.223.json" -d "campo=valor" => Se actualiza el campo del dispositivo con ip 10.2.254.223
//
// Campos que se pueden modificar:
// - name           => nombre
// - domain         => dominio
// - ip             => direccion ip
// - type           => tipo de dispositivo
// - snmpversion    => 0:sin SNMP | 1:version 1 | 2:version 2 | 3:version 3 (0 si no se indica)
// - snmpcommunity  => comunidad snmp (versiones 1 y 2)
// - snmpcredential => credencial snmp (version 3)
// - entity         => 0:dispositivo físico | 1:servicio web (0 si no se indica)
// - geo            => geolocalizacion en formato Google Maps
// - critic         => 25:criticidad baja | 50:criticidad media | 75:criticidad alta | 100:criticidad maxima (50 si no se indica)
// - correlated     => ID del dispositivo del que depende
// - status         => 0:activo | 1:inactivo | 2:mantenimiento (0 si no se indica)
// - profile        => perfil al que pertenece el dispositivo
// - Cualquier campo de usuario

                                                           /////////////////
                                                           //// /////// ////
                                                           //// METRICS ////
                                                           //// /////// ////
                                                           /////////////////

// /////////// //
// Metrics:GET //
// /////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
//
// "https://localhost/onm/api/1.0/metrics/info.json"                  => Información de todas las métricas
// "https://localhost/onm/api/1.0/metrics/info/12.json"               => Información de la métrica 12
// "https://localhost/onm/api/1.0/metrics/info.json?metricid=12"      => Información de la métrica 12 (utilizando criterios de búsqueda)
// "https://localhost/onm/api/1.0/metrics/info.json?devicetype=linux" => Información de todas las métricas de dispositivos de tipo linux
// 
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6);curl -ki -g -H "Authorization: $token" -X GET "`echo "https://localhost/onm/api/1.0/metrics/info.json?cnm_fields=id,name,domain&cnm_sort=-id" | sed "s/[[:space:]]/%20/g"`"
// 
// NOTA: Cuando tenemos espacios debemos sustituirlos por %20 (url_encode)
// NOTA: Cuando tenemos variables con espacios debemos utilizar form[] además de la sustitución previa
//
// Campos de busqueda:
// - metricid         => id de la metrica
// - metricname       => nombre de la métrica
// - metrictype       => tipo de la métrica
// - metricitems      => items de la métrica
// - metricstatus     => estado de la métrica
// - metricmname      => mname de la métrica
// - metricsubtype    => subtype de la métrica
// - devicename       => nombre del dispositivo
// - devicedomain     => dominio del dispositivo
// - devicestatus     => estado del dispositivo
// - devicetype       => tipo del dispositivo
// - deviceid         => id del dispositivo
// - deviceip         => ip del dispositivo
// - monitorid        => id del monitor
// - monitorname      => nombre del monitor
// - monitorsevred    => condición del monitor para que la métrica produzca una alerta roja
// - monitorsevorange => condición del monitor para que la métrica produzca una alerta naranja
// - monitorsevyellow => condición del monitor para que la métrica produzca una alerta amarilla
//




//
// "https://localhost/onm/api/1.0/metrics/data/12.json"               => Valores de la métrica 12
// "https://localhost/onm/api/1.0/metrics/data.json?id=12"            => Valores de la métrica 12 (utilizando criterios de búsqueda)
// "https://localhost/onm/api/1.0/metrics/data.json"                  => Valores de todas las métricas
// "https://localhost/onm/api/1.0/metrics/data.json?lapse=week"       => Valores de todas las métricas de la última semana
// "https://localhost/onm/api/1.0/metrics/data/12.json?lapse=week_0"  => Valores de la métrica 12 de la última semana
// "https://localhost/onm/api/1.0/metrics/data/12.json?lapse=week_1"  => Valores de la métrica 12 de la semana pasada
// "https://localhost/onm/api/1.0/metrics/data/12.json?lapse=week_5"  => Valores de la métrica 12 de hace cinco semanas
// "https://localhost/onm/api/1.0/metrics/data/12.json?lapse=day_0"   => Valores de la métrica 12 de hoy
// "https://localhost/onm/api/1.0/metrics/data/12.json?lapse=year_0"  => Valores de la métrica 12 de este año

                                                           ///////////////
                                                           //// ///// ////
                                                           //// VIEWS ////
                                                           //// ///// ////
                                                           ///////////////

// ////////// //
// Views: GET //
// ////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
//
// "https://localhost/onm/api/1.0/views.json"
// "https://localhost/onm/api/1.0/views/12.json"
// "https://localhost/onm/api/1.0/views/searchitems.json"
//
// "https://localhost/onm/api/1.0/views/metrics.json"
// "https://localhost/onm/api/1.0/views/12/metrics.json"
// Campos de busqueda:
//   - metricid         => id de la métrica
//   - metricname       => nombre de la métrica
//   - metrictype       => tipo de la métrica
//   - metricitems      => items de la métrica
//   - metricstatus     => estado de la métrica

//   - devicename       => nombre del dispositivo
//   - devicedomain     => dominio del dispositivo
//   - devicestatus     => estado del dispositivo
//   - devicetype       => tipo del dispositivo
//   - deviceid         => id del dispositivo
//   - deviceip         => ip del dispositivo

//   - monitorid        => id del monitor
//   - monitorname      => nombre del monitor
//   - monitorsevred    => condición del monitor para que la métrica produzca una alerta roja
//   - monitorsevorange => condición del monitor para que la métrica produzca una alerta naranja
//   - monitorsevyellow => condición del monitor para que la métrica produzca una alerta amarilla

//   - viewname         => nombre de la vista
//   - viewid           => id de la vista
//   - viewtype         => tipo de la vista

// ////////// //
// Views: PUT //
// ////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X PUT => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X PUT => BASE
//
// Modificar 
// "https://localhost/onm/api/1.0/views/renew.json" => Se actualizan todas las vistas. Se utiliza como tarea de mantenimiento (actualizar nmetrics,nremote, etc de todas las vistas)
// 



                                                           ////////////////
                                                           //// ////// ////
                                                           //// ALERTS //// 
                                                           //// ////// ////
                                                           ////////////////

// /////////// //
// Alerts: GET //
// /////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
//
// "https://localhost/onm/api/1.0/alerts.json"
// "https://localhost/onm/api/1.0/alerts/12.json"
//
// curl -ks -g -H "Authorization: $token" -X GET "https://localhost/onm/api/1.0/alerts.json?cnm_fields=id,event_data,name,domain,type&cnm_sort=id&type=latency"|jq '.'
// 
// Campos de busqueda:
// 	- ack          => Indica si tiene ack la alerta (0:no | 1:verde | 2:azul | 3:rojo | 4:naranja 5:amarillo).
//		- cause        => Causa de la alerta.
//		- counter      => Número fallos seguidos que se ha dado la alerta.
//		- critic       => Criticidad del dispositivo sobre el que se da la alerta.
//		- date         => Fecha en formato timestamp desde que ocurre la alerta.
//		- devicedomain => Dominio del dispositivo sobre el que se da la alerta.
//		- deviceip     => Dirección IP del dispositivo sobre el que se da la alerta.
//		- devicename   => Nombre del dispositivo sobre el que se da la alerta.
//		- event        => Evento de la alerta.
//		- id           => Identificador de la alerta.
//		- lastupdate   => Fecha en formato humano de la última verificación realizada sobre la alerta.
//		- severity     => Severidad de la alerta (1:roja | 2:naranja | 3:amarilla | 4:azul).
//		- ticket       => Identificador del ticket asociado a la alerta (0:sin ticket).  
//		- type         => Tipo de la alerta (snmp | latency | xagent | snmp-trap | syslog | email | api).
//
// 
// NOTA: En caso de querer hacer un OR en un mismo campo, meter una coma. 
//       Ejemplo: name=cnm,www
//
// 
// NOTA: Los campos de búsqueda pueden usar los siguientes operadores aritméticos:
//
// - CNMGT    => >
// - CNMGTE   => >=
// - CNMLT    => <
// - CNMLTE   => <=
// - CNMLIKE  => LIKE
// - CNMNLIKE => NOT LIKE
// - CNMEQ    => =
// - CNMNEQ   => !=
//
//
// Campos auxiliares:
// - cnm_page_size => Numero de elementos por página
// - cnm_page      => Numero de página
// - cnm_fields    => Campos que queremos que devuelva separados por comas
// - cnm_sort      => Campo por el que queremos que ordene (ponerle un - en caso de querer ordenar de forma descendente por dicho campo)
//                    En caso de querer ordenar por varios campos, dichos campos deben ir separados por comas

//
// ////////////// //
// Alerts: DELETE //
// ////////////// //
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X DELETE => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X DELETE => BASE
//
// "https://localhost/onm/api/1.0/alerts/12.json"
// 

                                                           //////////////////////
                                                           //// //////////// ////
                                                           //// ALERTS STORE //// 
                                                           //// //////////// ////
                                                           //////////////////////

// ///////////////// //
// Alerts_store: GET //
// ///////////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
//
// "https://localhost/onm/api/1.0/alerts_store.json"
// "https://localhost/onm/api/1.0/alerts_store/12.json"
//
// curl -ks -g -H "Authorization: $token" -X GET "https://localhost/onm/api/1.0/alerts_store.json?cnm_fields=id,event_data,name,domain,type&cnm_sort=id&type=latency"|jq '.'
// 
// Campos de busqueda:
// 	- ack          => Indica si tiene ack la alerta (0:no | 1:verde | 2:azul | 3:rojo | 4:naranja 5:amarillo).
//		- cause        => Causa de la alerta.
//		- critic       => Criticidad del dispositivo sobre el que se da la alerta.
//		- duration     => Duración en segundos de la alerta
//		- date         => Fecha en formato timestamp desde que ocurre la alerta.
//		- devicedomain => Dominio del dispositivo sobre el que se da la alerta.
//		- deviceip     => Dirección IP del dispositivo sobre el que se da la alerta.
//		- devicename   => Nombre del dispositivo sobre el que se da la alerta.
//		- event        => Evento de la alerta.
//		- id           => Identificador de la alerta.
//		- severity     => Severidad de la alerta (1:roja | 2:naranja | 3:amarilla | 4:azul).
//		- ticket       => Identificador del ticket asociado a la alerta (0:sin ticket).  
//		- type         => Tipo de la alerta (snmp | latency | xagent | snmp-trap | syslog | email | api).
//
//

// NOTA: En caso de querer hacer un OR en un mismo campo, meter una coma. 
//       Ejemplo: name=cnm,www
//
// 
// NOTA: Los campos de búsqueda pueden usar los siguientes operadores aritméticos:
//
// - CNMGT    => >
// - CNMGTE   => >=
// - CNMLT    => <
// - CNMLTE   => <=
// - CNMLIKE  => LIKE
// - CNMNLIKE => NOT LIKE
// - CNMEQ    => =
// - CNMNEQ   => !=
//
//
// Campos auxiliares:
// - cnm_page_size => Numero de elementos por página
// - cnm_page      => Numero de página
// - cnm_fields    => Campos que queremos que devuelva separados por comas
// - cnm_sort      => Campo por el que queremos que ordene (ponerle un - en caso de querer ordenar de forma descendente por dicho campo)
//                    En caso de querer ordenar por varios campos, dichos campos deben ir separados por comas


// //////////////////// //
// Alerts_store: DELETE //
// //////////////////// //
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X DELETE => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X DELETE => BASE
//
// "https://localhost/onm/api/1.0/alerts_store/12.json"
// 





                                                           /////////////////
                                                           //// /////// ////
                                                           //// TICKETS ////
                                                           //// /////// ////
                                                           /////////////////

//	//////////// //
// Tickets: GET //
//	//////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
//
// "https://localhost/onm/api/1.0/tickets.json"
// "https://localhost/onm/api/1.0/tickets/12.json"
// 
// Campos disponibles:
//  - id                       => id del ticket
//  - alert                    => id de la alerta
//  - category                 => categoría del ticket
//  - description              => descripción del ticket
//  - ticket                   => id externo del ticket introducido por el usuario
//  - user                     => usuario que ha generado el ticket
//  - type                     => alerts si el ticket está asociado a una alerta activa | store si el ticket está asociado a una alerta del histórico
//  - devicename               => nombre del dispositivo
//  - deviceip                 => ip del dispositivo
//  - devicedomain             => dominio del dispositivo
//  - alertdatelast_human      => fecha de la ultima actualización de la alerta
//  - alertdatelast_timestamp  => timestamp de la última actualización de la alerta
//  - alertdatefirst_human     => fecha de la creación de la alerta
//  - alertdatefirst_timestamp => timestamp de la creación de la alerta
//  - alertcounter             => contador de la alerta
//  - alerttype                => tipo de la alerta
//  - alertack                 => 0: no tiene ack | 1: ack verde | 2: ack azul | 3: ack rojo | 4: ack naranja | 5: ack amarillo
//  - alertseverity            => severidad de la alerta (1: alerta roja | 2: alerta naranja | 3: alerta amarilla)
//  - alertcause               => causa de la alerta

                                                           ////////////////
                                                           //// ////// ////
                                                           //// EVENTS ////
                                                           //// ////// ////
                                                           ////////////////

// //////////// //
// Events: POST //
// //////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X POST => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X POST => BASE
//
// "https://localhost/onm/api/1.0/events.json" -F "deviceid=1" -F "msg=TEST" -F "evkey=0001"
// "https://localhost/onm/api/1.0/events.json" -F "deviceip=10.2.254.223" -F "msg=TEST" -F "evkey=0001"
// "https://localhost/onm/api/1.0/events.json" -F "devicename=cnm-devel2" -F "devicedomain=s30labsi.com" -F "msg=TEST" -F "evkey=0001"
// "https://localhost/onm/api/1.0/events.json" -F "msg=TEST" -F "evkey=0001"
// "https://localhost/onm/api/1.0/events.json" -F "msg=TEST"
// "https://localhost/onm/api/1.0/events.json" -F "msg=TEST" -F "form[campo1]=valor1" -F "form[campo2]=valor2"
//
// Campos disponibles:
// - deviceid: id del dispositivo sobre el que se genera el evento
// - deviceip: direccion ip del dispositivo sobre el que se genera el evento
// - devicename: nombre con el que esta dado de alta en CNM el dispositivo sobre el que se genera el evento
// - devicedomain: dominio del dispositivo sobre el que se genera el evento
// - msg: mensaje del evento.
// - evkey: clave del evento. En caso de no indicarlos se genera uno internamente
// - Campos de usuario: añade una estructura json con los campos de usuario en el campo mensaje
//
// Campos necesarios:
// - deviceid | deviceip | devicename + devicedomain | nada (en caso de no poner datos del dispositivo, se asocia a la dirección ip de la que se
//   ejecuta la llamada al API)
// - msg | campos de usuario
// 
// Nota: Los campos de usuario NO hay que darlos previamente de alta en CNM.
//
// Descripcion: Crea un evento en CNM. 
//

                                                           //////////////////
                                                           //// //////// ////
                                                           //// PROFILES ////
                                                           //// //////// ////
                                                           //////////////////

// ///////////// //
// Profiles: GET //
// ///////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
// 
// "https://localhost/onm/api/1.0/profiles.json"                  => Información de todos los perfiles
// "https://localhost/onm/api/1.0/profiles/12.json"               => Información del perfil con id 12
// "https://localhost/onm/api/1.0/profiles.json?id=12"            => Información del perfil con id 12 (utilizando criterios de búsqueda)
// "https://localhost/onm/api/1.0/profiles.json?name=usuario web" => Información del perfil con nombre usuario web
// "https://localhost/onm/api/1.0/profiles.json?user=22"          => Información del perfil del usuario con id 22
// "https://localhost/onm/api/1.0/profiles.json?user=SSV"         => Información del perfil del usuario con name SSV
// "https://localhost/onm/api/1.0/profiles.json?device=44"        => Información del perfil del dispositivo con id 44
// "https://localhost/onm/api/1.0/profiles.json?device=1.1.1.1"   => Información del perfil del dispositivo con ip 1.1.1.1
// 
// Campos de busqueda:
// - name   => Nombre del perfil
// - id     => ID del perfil
// - user   => Usuario
// - device => Dispositivo

// ////////////// //
// Profiles: POST //
// ////////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X POST => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X POST => BASE
//
// "https://localhost/onm/api/1.0/profiles.json" -F "name=NAME" => Crea un perfil con nombre NAME
//

// ///////////// //
// Profiles: PUT //
// ///////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X PUT => BASE
//
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X PUT => BASE
//
// Modificar 
// "https://localhost/onm/api/1.0/profiles/12.json?name=web"           => Se cambia el nombre del perfil con id 12
//
// Asociar elementos
// "https://localhost/onm/api/1.0/profiles/12.json?user=22"            => Se asocia el usuario con id 22 al perfil con id 22
// "https://localhost/onm/api/1.0/profiles/12.json?user=SSV"           => Se asocia el usuario con name SSV al perfil con id 22
// "https://localhost/onm/api/1.0/profiles/12.json?device=44"          => Se asocia el dispositivo con id 44 al perfil con id 
// "https://localhost/onm/api/1.0/profiles/12.json?device=1.1.1.1"     => Se asocia el dispositivo con ip 1.1.1.1 al perfil con id 12
// "https://localhost/onm/api/1.0/profiles/12.json" -d "user=USER"     => Se asocia el usuario con id USER al perfil con id 12
// "https://localhost/onm/api/1.0/profiles/12.json" -d "device=DEVICE" => Se asocia el dispositivo con id DEVICE al perfil con id 12
//
// Campos que se pueden modificar:
// - name           => se cambia el nombre del perfil
//
// Elementos que se pueden asociar:
// - user           => id o name del usuario a asociar a dicho perfil
// - device         => id o ip del dispositivo a asociar a dicho perfil
// 

                                                           ///////////////
                                                           //// ///// ////
                                                           //// USERS ////
                                                           //// ///// ////
                                                           ///////////////

// ////////// //
// Users: GET //
// ////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET" => BASE
// 
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
//
//
// "https://localhost/onm/api/1.0/users.json"                  => Información de todos los usuarios
// "https://localhost/onm/api/1.0/users/12.json"               => Información del usuario con id 12
// "https://localhost/onm/api/1.0/users.json?id=12"            => Información del usuario con id 12 (utilizando criterios de búsqueda)
// "https://localhost/onm/api/1.0/users.json?form[role]=Administrador maestro" => Información de todos los usuarios cuyo rol sea usuario web

//
// "`echo "https://cnm002.s30labs.com/onm/api/1.0/users.json?form[role]=Administrador maestro" | sed "s/[[:space:]]/%20/g"`"
// 
// token=$(curl -k "https://cnm002.s30labs.com/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6);curl -ki -g -H "Authorization: $token" -X GET "`echo "https://cnm002.s30labs.com/onm/api/1.0/users.json" | sed "s/[[:space:]]/%20/g"`"
// token=$(curl -k "https://cnm002.s30labs.com/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6);curl -ki -g -H "Authorization: $token" -X GET "`echo "https://cnm002.s30labs.com/onm/api/1.0/users.json?cnm_fields=id,login,descr&cnm_sort=-id" | sed "s/[[:space:]]/%20/g"`"
// 
// NOTA: Cuando tenemos espacios debemos sustituirlos por %20 (url_encode)
// NOTA: Cuando tenemos variables con espacios debemos utilizar form[] además de la sustitución previa
//
// Campos de busqueda:
// - id        => id del usuario
// - login     => login del usuario
// - descr     => descripcion
// - timeout   => valor de timeout
// - firstname => nombre
// - lastname  => apellidos
// - email     => correo electronico
// - language  => idioma
// - role      => rol
//
// NOTA: En caso de querer hacer un OR en un mismo campo, meter una coma. 
//       Ejemplo: login=admin,oper
// 
// NOTA: Los campos de búsqueda pueden usar los siguientes operadores aritméticos:
//
// - CNMGT    => >
// - CNMGTE   => >=
// - CNMLT    => <
// - CNMLTE   => <=
// - CNMLIKE  => LIKE
// - CNMNLIKE => NOT LIKE
// - CNMEQ    => =
// - CNMNEQ   => !=
//
//
// Campos auxiliares:
// - cnm_page_size => Numero de elementos por página
// - cnm_page      => Numero de página
// - cnm_fields    => Campos que queremos que devuelva separados por comas
// - cnm_sort      => Campo por el que queremos que ordene (ponerle un - en caso de querer ordenar de forma descendente por dicho campo)
//                    En caso de querer ordenar por varios campos, dichos campos deben ir separados por comas
//
//


// /////////// //
// Users: POST //
// /////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X POST" => BASE
// 
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X POST => BASE
//
// "https://localhost/onm/api/1.0/users.json" -F "CAMPO1=valor1" -F "CAMPO2=valor2" -F "form[CAMPO3]=valor3"  => Se crea un usuario
//
// Campos disponibles:
// - login     => nombre de usuario
// - passwd    => contraseña en claro
// - token     => contraseña encriptada
// - descr     => descripción
// - timeout   => tiempo de la sesión (valor minimo 300)
// - firstname => nombre
// - lastname  => apellidos
// - email     => correo electrónico
// - language  => idioma de la interfaz (es_ES | en_US)
// - profile   => Perfil/perfiles (separado por ,) a los que pertenece el usuario
// - role      => Rol del usuario
// 
// Campos obligatorios:
// - login
// - passwd o token
// - firstname
// - lastname
// - email
// - profile
// - role
//

// ////////// //
// Users: PUT //
// ////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X PUT => BASE
// 
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X PUT => BASE
//
// "https://localhost/onm/api/1.0/users/12.json?password=NEWPASSWORD"            => Se actualiza la contraseña del usuario con id 12
// "https://localhost/onm/api/1.0/users/12.json" -d "token=TOKENGENERADO"        => Se actualiza la contraseña del usuario con id 12 basándonos en el token
// "https://localhost/onm/api/1.0/users/12.json" -d "form[password]=NEWPASSWORD" => Se actualiza los campos del usuario con id 12
//
// Campos que se pueden modificar:
// - login     => nombre de usuario
// - passwd    => contraseña en claro
// - token     => contraseña encriptada
// - descr     => descripción
// - timeout   => tiempo de la sesión (valor minimo 300)
// - firstname => nombre
// - lastname  => apellidos
// - email     => correo electrónico
// - language  => idioma de la interfaz (es_ES | en_US)
// - profile   => Perfil/perfiles (separado por ,) a los que pertenece el usuario
// - role      => Rol del usuario


                                                           ////////////////
                                                           //// ////// ////
                                                           //// BACKUP //// 
                                                           //// ////// ////
                                                           ////////////////

// /////////// //
// Backup: GET //
// /////////// //
//
// Descripción: Descargar el último backup del sistema
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -k -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
// 
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
//
// "https://localhost/onm/api/1.0/backup.json" > cnm_backup.tar => Descarga el ultimo backup
//
//
// Descripción: Obtener información del último backup
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -k -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
// 
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
//
// "https://localhost/onm/api/1.0/backup/info.json" => Devuelve información del último backup
//
//

// //////////// //
// Backup: POST //
// //////////// //
// 
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X POST => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X POST => BASE
//
// "https://localhost/onm/api/1.0/backup.json" -F "file=@/tmp/cnm_backup.tar" => Sube el backup

// /////////// //
// Backup: PUT //
// /////////// //
// 
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X PUT => BASE
// 
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X PUT => BASE
//
// "https://localhost/onm/api/1.0/backup.json" => Realiza un backup del sistema

                                                           ////////////////
                                                           //// ////// ////
                                                           //// ASSETS ////
                                                           //// ////// ////
                                                           ////////////////

// /////////// //
// Assets: GET //
// /////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
// 
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -g -H "Authorization: $token" -X GET => BASE
//
// "https://localhost/onm/api/1.0/assets.json"                       => Información de todos los assets
// "https://localhost/onm/api/1.0/assets/6c3cf49f.json"              => Información del asset 6c3cf49f
// "https://localhost/onm/api/1.0/assets.json?id=6c3cf49f"           => Información del asset 6c3cf49f (utilizando criterios de búsqueda)
// "https://localhost/onm/api/1.0/assets.json?subtype=MySQL"         => Información de los assets del subtipo MySQL(categoría MySQL)
// "https://localhost/onm/api/1.0/assets.json?type=DDBB"             => Información de los assets del tipo DDBB
//
// "`echo "https://cnm002.s30labs.com/onm/api/1.0/assets.json?form[Usa gafas]=Si" | sed "s/[[:space:]]/%20/g"`"  => Información de los assets cuyo campo de usuario Usa gafas tenga el valor Si (utilizando criterios de búsqueda)
//
// token=$(curl -k "https://cnm002.s30labs.com/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6);curl -ki -g -H "Authorization: $token" -X GET "`echo "https://cnm002.s30labs.com/onm/api/1.0/assets.json" | sed "s/[[:space:]]/%20/g"`"
// token=$(curl -k "https://cnm002.s30labs.com/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6);curl -ki -g -H "Authorization: $token" -X GET "`echo "https://cnm002.s30labs.com/onm/api/1.0/assets.json?cnm_fields=id,type,subtype,descr&cnm_sort=-id" | sed "s/[[:space:]]/%20/g"`"
// 
// NOTA: Cuando tenemos espacios debemos sustituirlos por %20 (url_encode)
// NOTA: Cuando tenemos variables con espacios debemos utilizar form[] además de la sustitución previa
// 
// Campos de busqueda:
// - id              => id del asset
// - name            => nombre
// - type            => tipo del asset
// - subtype         => subtipo o categoría del asset
// - status          => estado
// - critic          => 25:criticidad baja | 50:criticidad media | 75:criticidad alta | 100:criticidad mazima (50 si no se indica)
// - owner           => propietario
// - Cualquier campo de usuario
//
// NOTA: En caso de querer hacer un OR en un mismo campo, meter una coma. 
//       Ejemplo: name=cnm,www
//
// 
// NOTA: Los campos de búsqueda pueden usar los siguientes operadores aritméticos:
//
// - CNMGT    => >
// - CNMGTE   => >=
// - CNMLT    => <
// - CNMLTE   => <=
// - CNMLIKE  => LIKE
// - CNMNLIKE => NOT LIKE
// - CNMEQ    => =
// - CNMNEQ   => !=
//
//
// Campos auxiliares:
// - cnm_page_size => Numero de elementos por página
// - cnm_page      => Numero de página
// - cnm_fields    => Campos que queremos que devuelva separados por comas
// - cnm_sort      => Campo por el que queremos que ordene (ponerle un - en caso de querer ordenar de forma descendente por dicho campo)
//                    En caso de querer ordenar por varios campos, dichos campos deben ir separados por comas
//
//

// //////////// //
// Assets: POST //
// //////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X POST => BASE
// 
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X POST => BASE
//
// "https://localhost/onm/api/1.0/assets.json" -F "CAMPO1=valor1" -F "CAMPO2=valor2 con espacios" -F "form[CAMPO3]=valor3"  => Se crea un elemento TI
//
// Campos disponibles:
// - name            => nombre
// - type            => tipo del asset
// - subtype         => subtipo o categoría del asset
// - status          => estado
// - critic          => 25:criticidad baja | 50:criticidad media | 75:criticidad alta | 100:criticidad máxima (50 si no se indica)
// - owner           => propietario
// - Cualquier campo de usuario
// 
// Campos obligatorios:
// - name
// - type
// - subtype
// - owner
//
// Campos de usuario:
// Los campos que se aporten y no sean de sistema se consideraran de usuario. Dichos valores se asociaran al elemento TI siempre y cuando
// los campos de usuario se hayan dado de alta previamente en CNM.
// Los campos de usuario que tengan espacios hay que indicarlos de la siguiente forma: -F "form[Usuario de acceso]=pepito"
// Los campos de usuario que tengan espacios en el valor hay que indicarlos de la siguiente forma: -F "CAMPO2=valor2 con espacios"

// /////////// //
// Assets: PUT //
// /////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X PUT => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -ki -H "Authorization: $token" -X PUT => BASE
// 
// "https://localhost/onm/api/1.0/assets/6c3cf49f.json?campo=valor"          => Se actualiza el campo del elemento TI con id 6c3cf49f
// "https://localhost/onm/api/1.0/assets/6c3cf49f.json" -d "campo=valor"     => Se actualiza el campo del elemento TI con id 6c3cf49f
// "https://localhost/onm/api/1.0/assets/6c3cf49f.json" -d "form[campo con espacios]=valor" => Se actualiza el campo con espacios del elemento TI con id 6c3cf49f
//
// Campos que se pueden modificar:
// - name            => nombre
// - subtype         => subtipo o categoría del asset
// - status          => Estado
// - critic          => 25:criticidad baja | 50:criticidad media | 75:criticidad alta | 100:criticidad máxima (50 si no se indica)
// - owner           => propietario
// - Cualquier campo de usuario




                                                           ///////////////
                                                           //// ///// ////
                                                           //// MULTI ////
                                                           //// ///// ////
                                                           ///////////////

// ////////// //
// Multi: GET //
// ////////// //
//
// curl -k -g "https://localhost/onm/api/1.0/multi.json"  => Información del multi
//
// 
// ////////// //
// Multi: PUT //
// ////////// //
//
// curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -s -S -k -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X PUT => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -s -S -k -H "Authorization: $token" -X PUT "https://localhost/onm/api/1.0/multi.json"          => Actualiza la BBDD con los datos de los CNMs remotos




                                                           ////////////////
                                                           //// ////// ////
                                                           //// REPORTS////
                                                           //// ////// ////
                                                           ////////////////

// /////////// //
// Reports: GET //
// /////////// //
//
// curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
// curl -ki -g -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X GET => BASE
//
// token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
// curl -k -g -H "Authorization: $token" -X GET => BASE
//
// "https://localhost/onm/api/1.0/reports/capacity/34.json"    => Descargar el informe de capacidad de la vista 1
//



// --------------------------------------------------------------------------------------------
require_once('inc/session.php');
include_once('inc/CNMUtils.php');
include_once('inc/CNMAPI.php');
include_once('inc/CNMAPI/Alerts.php');
include_once('inc/CNMAPI/Alerts_store.php');
include_once('inc/CNMAPI/Auth.php');
include_once('inc/CNMAPI/Devices.php');
include_once('inc/CNMAPI/Embed.php');
include_once('inc/CNMAPI/Metrics.php');
include_once('inc/CNMAPI/Tickets.php');
include_once('inc/CNMAPI/Views.php');
include_once('inc/CNMAPI/Events.php');
include_once('inc/CNMAPI/Profiles.php');
include_once('inc/CNMAPI/Users.php');
include_once('inc/CNMAPI/Backup.php');
include_once('inc/CNMAPI/Assets.php');
include_once('inc/CNMAPI/Multi.php');
include_once('inc/CNMAPI/Reports.php');
//include_once('inc/flot.php');
include_once('inc/class_table.php');
include_once('inc/format.php');
include_once('inc/mod_common.php');
include_once('/var/www/html/tphp/class.TemplatePower.inc.php');
// --------------------------------------------------------------------------------------------

$content_type = CNMUtils::get_param('content_type');
$parts = CNMUtils::get_param('endpoint');
$endpoint_parts = explode('/', $parts);
$endpoint = strtolower($endpoint_parts[0]);
$nparts = count($endpoint_parts);

// Endpoints que no necesitan token para funcionar
$a_endpoint_nosession = array('embed','auth');

// Petición sin sesión
if (in_array($endpoint,$a_endpoint_nosession) OR ($endpoint=='multi' AND $_SERVER["REQUEST_METHOD"]=='GET')){
   $dbc=CNMAPI::connectDB();
}
// Petición con sesión
else {
   session_set_save_handler('mysql_session_open','mysql_session_close','mysql_session_select','mysql_session_write','mysql_session_destroy','mysql_session_garbage_collect');
   session_start();
   $headers = apache_request_headers();
   $sid = (array_key_exists('Authorization',$headers))?$headers['Authorization']:'';
   showTime($sid);
   session_id($sid);
}

// --------------------------------------------------------------------------------------------
$output = array ('errors' => array(), 'success'=>true);
//$output = json_encode($response);

CNMUtils::info_log(__FILE__, __LINE__, "[API10] REQUEST={$_SERVER["REQUEST_METHOD"]} ENDPOINT=$endpoint NPARTS=$nparts PARTS=$parts sid=$sid ctype=$content_type");

// --------------------------------------------------------------------------------------------
// GET - Used for basic read requests to the server
// PUT- Used to modify an existing object on the server
// POST- Used to create a new object on the server
// DELETE - Used to remove an object on the server


switch ($_SERVER["REQUEST_METHOD"]) {
   case "POST":
      // Create action
		$output = POST($nparts,$endpoint,$endpoint_parts);
      break;
		
   case "GET":
     	// Retrieve action
		$output = GET($nparts,$endpoint,$endpoint_parts);
      break;

   case "PUT":
      // Update action
		$output = PUT($nparts,$endpoint,$endpoint_parts);
      break;

   case "DELETE":
      // Delete action
      $output = DEL($nparts,$endpoint,$endpoint_parts);
      break;
}

switch($content_type) {
   case 'json':
        	//echo json_encode($output);
			if($output['rc']==1){
			// if($output['status']==1){
				CNMAPI::jsonResponseHeader($output,400);
			}
			else{
				CNMAPI::jsonResponseHeader($output);
			}
    		break;
	case 'html':
         echo $output;
         break;
	
    default:
        echo $output;
}

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------

// ------------------------------------------------------------------------------
// GET
// ------------------------------------------------------------------------------
function GET($nparts,$endpoint,$endpoint_parts) {

	switch ($endpoint) {

    	case "devices":
			//(1) GET /devices.json
			if ($nparts==1) { 
				$output = api_get_devices(0); 
			}
			//(2) GET /devices/12.json
			elseif ($nparts==2){
				if(is_numeric($endpoint_parts[1])) { 
					$output = api_get_devices($endpoint_parts[1]); 
				}
				elseif(filter_var($endpoint_parts[1], FILTER_VALIDATE_IP)) {
					$_GET['ip']=$endpoint_parts[1];
					$output = api_get_devices(0);
				}
			}
        	break;

      case "metrics":
			// metrics/info.json
			// metrics/data.json
			if ($nparts==2) { 
				if($endpoint_parts[1]=='info')     $output = api_get_metrics(0); 
				// Esto hay que verlo bien porque es mucha información
				elseif($endpoint_parts[1]=='data') $output = api_get_metric_rrd('all');
         }
			// metrics/info/12.json
			// metrics/data/12.json
			// metrics/data/12.json?lapse=week
			elseif ($nparts==3) {
				if($endpoint_parts[1]=='info' AND is_numeric($endpoint_parts[2]))     $output = api_get_metrics($endpoint_parts[2]); 
            elseif($endpoint_parts[1]=='data' AND is_numeric($endpoint_parts[2])) $output = api_get_metric_rrd($endpoint_parts[2]);
			}
         break;

    	case "alerts":
         //(1) GET /alerts.json
         if ($nparts==1) { 
				$output = api_get_alerts(0); 
			}
         //(2) GET /alerts/12.json
         elseif ($nparts==2 AND is_numeric($endpoint_parts[1])) {
				$output = api_get_alerts($endpoint_parts[1]);
         }
         break;

    	case "alerts_store":
         //(1) GET /alerts_store.json
         if ($nparts==1) { 
				$output = api_get_alerts_store(0); 
			}
         //(2) GET /alerts_store/12.json
         elseif ($nparts==2 AND is_numeric($endpoint_parts[1])) {
				$output = api_get_alerts_store($endpoint_parts[1]);
         }
         break;

    	case "views":

			//(1) GET /views.json
			if ($nparts==1) { $output = api_get_views(0); }
			//(2) GET /views/12.json
			elseif ($nparts==2) {
				if (is_numeric($endpoint_parts[1]))  { 
					$output = api_get_views($endpoint_parts[1]); 
				}
				// SSV: La opción inferior no tiene sentido => Se elimina
				// (2) GET /views/metrics.json
				else { 
					$output = api_get_views_metrics(0); 
				}
			}
			//(3) GET /views/12/metrics.json
			//(3) GET /views/12/remote.json
			elseif ($nparts==3) {
				if (is_numeric($endpoint_parts[1]))  {
					if (strtolower($endpoint_parts[2]) == "metrics")     { $output = api_get_views_metrics($endpoint_parts[1]); }
					elseif (strtolower($endpoint_parts[2]) == "remote")  { $output = api_get_views_remote_alerts($endpoint_parts[1]); }
				}
			}
			//(4) GET /views/12/search/23.json
         elseif ($nparts==4) {
            if ( (is_numeric($endpoint_parts[1])) && (is_numeric($endpoint_parts[3]))) {
               if (strtolower($endpoint_parts[2]) == "search")  { $output = api_get_views_searchitems($endpoint_parts[1], $endpoint_parts[3]); }
            }
         }
        	break;

    	case "tickets":
         //(1) GET /tickets.json
         if ($nparts==1) { $output = api_get_tickets(); }
         //(2) GET /tickets/12.json
         elseif ($nparts==2) {
            if (is_numeric($endpoint_parts[1])) { $output = api_get_tickets($endpoint_parts[1]); }
         }
      	break;

      case "auth":
         //(2) GET /auth/token.json
         if ($nparts==2) {
            if (strtolower($endpoint_parts[1]) == "token") { $output = api_get_auth_token(); }
         }
         break;

      case "embed":
         //(3) GET /embed/metrics/12.html
         if ($nparts==3) {
CNMUtils::info_log(__FILE__, __LINE__, "[API10] $endpoint_parts[1] -- $endpoint_parts[2]");
				if ( (strtolower($endpoint_parts[1]) == "metrics") && (is_numeric($endpoint_parts[2])) ) {
CNMUtils::info_log(__FILE__, __LINE__, "[API10] $endpoint_parts[1] -- $endpoint_parts[2]");
					api_get_metric_graph($endpoint_parts[2]);
				}
			}
         break;

      case "profiles":

			// profiles.json
			// profiles.json?id=12
			// profiles.json?name=12
			if ($nparts==1) $output = api_get_profiles(0);

			// /profiles/12.json
			elseif ($nparts==2) {
				if (is_numeric($endpoint_parts[1])) $output = api_get_profiles($endpoint_parts[1]);
			}
         break;


      case "backup":

         // backup.json
         if($nparts==1) $output = api_get_backup();

			if($nparts==2){
				// backup/info.json
				if('info' == $endpoint_parts[1]) $output = api_info_backup();
			}
         break;

      case "users":

			// users.json
			// users.json?id=12
			// users.json?role=usuario web
			if ($nparts==1) $output = api_get_users(0);

			// /users/12.json
			elseif ($nparts==2) {
				if (is_numeric($endpoint_parts[1])) $output = api_get_users($endpoint_parts[1]);
			}
         break;

      case "assets":
         //(1) GET /assets.json
         if ($nparts==1) {
            $output = api_get_assets(0);
         }
         //(2) GET /assets/6c3cf49f.json
         elseif ($nparts==2){
            $output = api_get_assets($endpoint_parts[1]);
         }
         break;

      case "multi":

         // multi.json
         if($nparts==1) $output = api_get_multi();

         break;

      case "reports":
			// GET reports/capacity/1.json
         if ($nparts==3 AND is_numeric($endpoint_parts[2])) {
            $output = api_get_reports($endpoint_parts[1],$endpoint_parts[2]);
         }
         break;



		default:
   		$response = array ('errors' => array('Undefined endpoint'), 'success'=>false);
   		//header(':',true,'403');
   		$output = json_encode($response);

	}


	return $output;
}


// ------------------------------------------------------------------------------
// POST 
// ------------------------------------------------------------------------------
function POST($nparts,$endpoint,$endpoint_parts) {

	switch ($endpoint) {

      case "devices":
         //(1) POST /devices.json
         if ($nparts==1) {
            $output = api_post_devices();
         }
         break;

      case "profiles":
         //(1) POST /profiles.json
         if ($nparts==1) {
            $output = api_post_profiles();
         }
         break;

      case "users":
         //(1) POST /users.json
         if ($nparts==1) {
            $output = api_post_users();
         }
         break;


      case "backup":

         // backup.json
         $output = api_post_backup();

         break;


    	case "events":
			//(1) POST /events.json
			if ($nparts==1) { 
				$output = api_post_events(); 
			}
        	break;

      case "assets":
         //(1) POST /assets.json
         if ($nparts==1) {
            $output = api_post_assets();
         }
         break;

		default:
   		$response = array ('errors' => array('Undefined endpoint'), 'success'=>false);
   		$output = json_encode($response);
	}
	return $output;
}

// ------------------------------------------------------------------------------
// PUT
// ------------------------------------------------------------------------------
function PUT($nparts,$endpoint,$endpoint_parts){

   switch ($endpoint) {
      case "views":

         //(2) PUT /views/search.json
         //(2) PUT /views/renew.json
         if ($nparts==2) {
				if($endpoint_parts[1]=='search')    $output = api_put_views_search();
				elseif($endpoint_parts[1]=='renew') $output = api_put_views_renew();
         }
         //(3) PUT /views/12/search.json
         elseif ($nparts==3) {
            if (is_numeric($endpoint_parts[1]))  {
					$output = api_put_views_search($endpoint_parts[1]);
            }
         }
         break;

		case "devices":

			//PUT /devices/12.json?campo=valor                => Se actualiza el campo del dispositivo con id 12
			//PUT /devices/10.2.254.223.json?campo=valor      => Se actualiza el campo del dispositivo con ip 10.2.254.223
			//PUT /devices/10.2.254.223.json -F "campo=valor" => Se actualiza el campo del dispositivo con ip 10.2.254.223
         if ($nparts==2){
            if(is_numeric($endpoint_parts[1])) {
               //$output = api_put_devices_custom_data(array('deviceid'=>$endpoint_parts[1]));
					$output = api_put_devices($endpoint_parts[1]);
            }
            elseif(filter_var($endpoint_parts[1], FILTER_VALIDATE_IP)) {
					$output = api_put_devices($endpoint_parts[1]);
               // $output = api_put_devices_custom_data(array('deviceip'=>$endpoint_parts[1]));
            }
         }
			break;


		case "profiles":
			//PUT /profiles/12.json?name=NAME
			//PUT /profiles/12.json?user=USER
			//PUT /profiles/12.json?device=DEVICE
         if ($nparts==2){
            if(is_numeric($endpoint_parts[1])) {
               $output = api_put_profiles($endpoint_parts[1]);
            }
         }
			break;

		case "users":
			//PUT /users/12.json?password=NEWPASSWORD
         if ($nparts==2){
            if(is_numeric($endpoint_parts[1])) {
               $output = api_put_users($endpoint_parts[1]);
            }
         }
			break;

      case "backup":
         //PUT /backup.json
         $output = api_put_backup();
         break;

		case "assets":

			//PUT /assets/6c3cf49f.json?campo=valor      => Se actualiza el campo del elemento TI con id 6c3cf49f
			//PUT /assets/6c3cf49f.json -F "campo=valor" => Se actualiza el campo del elemento TI con id 6c3cf49f
         if ($nparts==2){
				$output = api_put_assets($endpoint_parts[1]);
         }
			break;

      case "multi":
         //PUT /multi.json
         $output = api_put_multi();
         break;

      default:
         $output = array ('errors' => array('Undefined endpoint'), 'success'=>false);
         //header(':',true,'403');
         //$output = json_encode($response);
   }
   return $output;
}


// ------------------------------------------------------------------------------
// DEL
// ------------------------------------------------------------------------------
function DEL($nparts,$endpoint,$endpoint_parts){

   switch ($endpoint) {
		case "alerts":

			//DELETE /alerts/12.json => Se borra la alerta con id 12
         if ($nparts==2){
            if(is_numeric($endpoint_parts[1])) {
					$output = api_delete_alerts($endpoint_parts[1]);
            }
         }
			break;

      case "alerts_store":

         //DELETE /alerts_store/12.json => Se borra la alerta con id 12
         if ($nparts==2){
            if(is_numeric($endpoint_parts[1])) {
               $output = api_delete_alerts_store($endpoint_parts[1]);
            }
         }
         break;


      default:
         $output = array ('errors' => array('Undefined endpoint'), 'success'=>false);
         //header(':',true,'403');
         //$output = json_encode($response);
   }
   return $output;
}



// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------

?>
