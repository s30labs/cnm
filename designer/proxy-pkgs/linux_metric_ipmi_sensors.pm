package linux_metric_ipmi_sensors;
# /opt/custom_pro/conf/gconf-proxy -m linux_metric_ipmi_sensors -p ipmi-sensors
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_ipmi_sensors::CFG = 0;
$linux_metric_ipmi_sensors::SCRIPT_NAME = 'linux_metric_ipmi_sensors.pl';

#---------------------------------------------------------------------------
# DEFINICION DEL SCRIPT
# __SCRIPT__               => Nombre del script
# __EXEC_MODE__            =>
# __SCRIPT_DESCRIPTION__   => Descripcion del cript
# __PROXY_TYPE__           =>
# __CFG__                  => 0 METRICA  1=>APP
# __PROXY_USER__           =>
# __PROXY_PWD__            =>
#
# __PARAM_TYPE__           => 0:normal 1:clave 2:ip
#---------------------------------------------------------------------------
# Si no se especifica valor para hparam, se generan internamente a partir de
# __SCRIPT__ (xagt_(md5(script.position))).

#---------------------------------------------------------------------------
%linux_metric_ipmi_sensors::SCRIPT = (

   '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_ipmi_sensors::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

   # ----------------------------
   '__SCRIPT_PARAMS__' => {

      'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
      'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-u', '__PARAM_DESCR__' => 'Usuario', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
      'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Clave', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
      'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-t', '__PARAM_DESCR__' => 'Timeout en segundos', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
      'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-s', '__PARAM_DESCR__' => 'Tipo de sensor', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
      'p06' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-r', '__PARAM_DESCR__' => 'Versión IPMI', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
      },

   # ----------------------------
   '__TIP__'  => {
      '__DESCR_TIP__' => 'Este script obtiene la información que reporta un equipo a través de IPMI.

linux_metric_ipmi_sensors.pl v1.0

linux_metric_ipmi_sensors.pl -n IP/Host -u Usuario -p Clave [-t timeout] [-r revision] [-s tipo de sensor]
linux_metric_ipmi_sensors.pl -h

-n    Host (Nombre a resolver)
-t 	Timeout (opcional)
-b		Genera alerta azul
-r    Versión IPMI. Las opciones posibles son 1.5 y 2.0. Por defecto se hace con 1.5
-u    Nombre de usuario
-p    Clave
-h    Ayuda
-s    Tipo de sensor. En caso de no indicarlo devuelve todos. Los sensores disponibles son:
      - temperature
      - voltage
      - current
      - fan
      - physical_security
      - platform_security_violation_attempt
      - processor
      - power_supply
      - power_unit
      - memory
      - drive_slot
      - system_firmware_progress
      - event_logging_disabled
      - system_event
      - critical_interrupt
      - module_board
      - slot_connector
      - watchdog2
      - entity_presence
      - management_subsystem_health
      - battery
      - fru_state
      - cable_interconnect
      - boot_error
      - button_switch
      - system_acpi_power_state
',
      '__ID_REF__' => $linux_metric_ipmi_sensors::SCRIPT_NAME
   }
);

#---------------------------------------------------------------------------
# __CLASS__       => proxy-linux
# __APPTYPE__     =>
# __ITIL_TYPE__   => operacion 1, configuracion 2, capacidad 3, disponibilidad 4, seguridad 5
# __TAG__
# __ESP__
# __IPTAB__
# __ITEMS__
# __VLABEL__
# __MODE__
# __MTYPE__
# __NPARAMS__
# __PARAMS__      => [prefix;Nombre;default value;tipo] tipo ==> 0:normal 1:clave 2:ip
# __SEVERITY__
# __CFG__      => 1 -> Sin instancias, 2 -> Con Instancias
# __GET_IID__
# __PROXY_TYPE__
# __INCLUDE__
#---------------------------------------------------------------------------
# ojo !!! Si no se especifica subtype, se genera internamente a partir de
#  __DESCRIPTION__ (xagt_(md5(descr))).
# Si se quiere fijar el subtype hay que especificarlo. (ej. si se decide cambiar
# el texto con la descripcion)
# Lo mismo pasa con hparam. Si no se especifican, se generan internamente a partir de
# __DESCRIPTION__ (xagt_(md5(descr.paramx))).
@linux_metric_ipmi_sensors::METRICS = (

   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004030
      '__SUBTYPE__'=> 'xagt_004030', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'IPMI - TEMPERATURA',
      '__APPTYPE__'=> 'HW.IPMI',   '__ITIL_TYPE__'=> '1',  '__TAG__'=> '001',

      '__ESP__'=>'o1',
      '__ITEMS__'=>'Temperatura',

      '__IPTAB__'=> '1', '__VLABEL__'=> 'ºC',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '6',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.ipmi.user;0]:[-p;Clave;$sec.ipmi.pwd;1]:[-t;Timeout;2;0]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_ipmi_sensors::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'ipmi_sensors-check,[-n;IP;;2]:[-u;Usuario;$sec.ipmi.user;0]:[-p;Clave;$sec.ipmi.pwd;1]',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.ipmi.user', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.ipmi.pwd', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '2', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p06' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que representa la temperatura del equipo reportada por IPMI',
      },

      # ----------------------------
#      '__MONITORS__' => {
#
#         'm01' => { '__MONITOR__' => 's_xagt_004020-148b349b', '__CAUSE__' => 'ERROR EN ACCESO ICMP DUAL', '__EXPR__' => 'v3=1:v4=1:v5=1', '__HIDE__' => '1',  '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004020', '__SUBTYPE__' => 'xagt_004020', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la méica "DISPONIBILIDAD ICMP DUAL" que genera una alerta de severidad ROJA no se accede ni a IP1, ni a IP2. Una alerta de severidad NARANJA cuando no se accede a IP1 pero si a IP2 y una alerta de severidad AMARILLA cuando no se accede a IP2 pero si a IP1'  },
#      },


   },


   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004031
      '__SUBTYPE__'=> 'xagt_004031', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'IPMI - ESTADO DE LA CAJA',
      '__APPTYPE__'=> 'HW.IPMI',   '__ITIL_TYPE__'=> '1',  '__TAG__'=> '005',

      '__ESP__'=>"MAPS(\\'ok\\')(1,0)|MAPS(\\'general chassis intrusion\\')(0,1)",
      '__ITEMS__'=>'Cerrado|Abierto',

      '__IPTAB__'=> '0', '__VLABEL__'=> 'Estado',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_SOLID',
      '__NPARAMS__'=> '6',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.ipmi.user;0]:[-p;Clave;$sec.ipmi.pwd;1]:[-t;Timeout;2;0]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_ipmi_sensors::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'ipmi_sensors-check,[-n;IP;;2]:[-u;Usuario;$sec.ipmi.user;0]:[-p;Clave;$sec.ipmi.pwd;1]',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.ipmi.user', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.ipmi.pwd', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '2', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p06' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que representa si la caja del equipo ha sido abierta o no',
      },

      # ----------------------------
      '__MONITORS__' => {

         'm01' => { '__MONITOR__' => 'monitor=s_xagt_004031-64b4e1fc', '__CAUSE__' => 'INTRUSIÓN DE EQUIPO', '__EXPR__' => 'v2=1', '__HIDE__' => '1',  '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004031', '__SUBTYPE__' => 'xagt_004031', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "ESTADO DE LA CAJA" que genera una alerta de severidad ROJA cuando la caja ha sido abierta'  },
      },


   },

   #------------------------------------------------------------------------
	{
      #defSUBTYPE=xagt_004032
      '__SUBTYPE__'=> 'xagt_004032', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'IPMI - VENTILADOR',
      '__APPTYPE__'=> 'HW.IPMI',   '__ITIL_TYPE__'=> '1',  '__TAG__'=> '004',

      '__ESP__'=>'o1',
      '__ITEMS__'=>'RPM',

      '__IPTAB__'=> '1', '__VLABEL__'=> 'RPM',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '6',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.ipmi.user;0]:[-p;Clave;$sec.ipmi.pwd;1]:[-t;Timeout;2;0]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_ipmi_sensors::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'ipmi_sensors-check,[-n;IP;;2]:[-u;Usuario;$sec.ipmi.user;0]:[-p;Clave;$sec.ipmi.pwd;1]',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.ipmi.user', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.ipmi.pwd', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '2', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p06' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que representa la velocidad de los ventiladores del equipo reportada por IPMI',
      },

      # ----------------------------
#      '__MONITORS__' => {
#
#         'm01' => { '__MONITOR__' => 's_xagt_004020-148b349b', '__CAUSE__' => 'ERROR EN ACCESO ICMP DUAL', '__EXPR__' => 'v3=1:v4=1:v5=1', '__HIDE__' => '1',  '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004020', '__SUBTYPE__' => 'xagt_004020', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la méica "DISPONIBILIDAD ICMP DUAL" que genera una alerta de severidad ROJA no se accede ni a IP1, ni a IP2. Una alerta de severidad NARANJA cuando no se accede a IP1 pero si a IP2 y una alerta de severidad AMARILLA cuando no se accede a IP2 pero si a IP1'  },
#      },


   },
   #------------------------------------------------------------------------
	{
      #defSUBTYPE=xagt_004033
      '__SUBTYPE__'=> 'xagt_004033', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'IPMI - VOLTAJE',
      '__APPTYPE__'=> 'HW.IPMI',   '__ITIL_TYPE__'=> '1',  '__TAG__'=> '002',

      '__ESP__'=>'o1',
      '__ITEMS__'=>'V',

      '__IPTAB__'=> '1', '__VLABEL__'=> 'V',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '6',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.ipmi.user;0]:[-p;Clave;$sec.ipmi.pwd;1]:[-t;Timeout;2;0]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_ipmi_sensors::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'ipmi_sensors-check,[-n;IP;;2]:[-u;Usuario;$sec.ipmi.user;0]:[-p;Clave;$sec.ipmi.pwd;1]',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.ipmi.user', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.ipmi.pwd', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '2', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p06' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que representa los voltajes del equipo reportada por IPMI',
      },

      # ----------------------------
#      '__MONITORS__' => {
#
#         'm01' => { '__MONITOR__' => 's_xagt_004020-148b349b', '__CAUSE__' => 'ERROR EN ACCESO ICMP DUAL', '__EXPR__' => 'v3=1:v4=1:v5=1', '__HIDE__' => '1',  '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004020', '__SUBTYPE__' => 'xagt_004020', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la méica "DISPONIBILIDAD ICMP DUAL" que genera una alerta de severidad ROJA no se accede ni a IP1, ni a IP2. Una alerta de severidad NARANJA cuando no se accede a IP1 pero si a IP2 y una alerta de severidad AMARILLA cuando no se accede a IP2 pero si a IP1'  },
#      },


   },
   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004034
      '__SUBTYPE__'=> 'xagt_004034', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'IPMI - ESTADO DEL SERVICIO',
      '__APPTYPE__'=> 'HW.IPMI',   '__ITIL_TYPE__'=> '1',  '__TAG__'=> '100',

      '__ESP__'=>"MAP(1)(1,0)|MAP(0)(0,1)",
      '__ITEMS__'=>'Ok|Nook',

      '__IPTAB__'=> '0', '__VLABEL__'=> 'Estado',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_SOLID',
      '__NPARAMS__'=> '6',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.ipmi.user;0]:[-p;Clave;$sec.ipmi.pwd;1]:[-t;Timeout;2;0]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_ipmi_sensors::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'ipmi_sensors-check,[-n;IP;;2]:[-u;Usuario;$sec.ipmi.user;0]:[-p;Clave;$sec.ipmi.pwd;1]',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.ipmi.user', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.ipmi.pwd', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '2', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p06' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que representa si el servicio IPMI funciona en el equipo',
      },

      # ----------------------------
      '__MONITORS__' => {

         'm01' => { '__MONITOR__' => 'monitor=s_xagt_004034-64b4e1fc', '__CAUSE__' => 'EQUIPO NO RESPONDE A IPMI', '__EXPR__' => 'v2=1', '__HIDE__' => '1',  '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004034', '__SUBTYPE__' => 'xagt_004034', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "ESTADO DEL SERVICIO" que genera una alerta de severidad ROJA cuando el servicio IPMI no responde'  },
      },
   },
   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004035
      '__SUBTYPE__'=> 'xagt_004035', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'IPMI - ESTADO DEL DISPOSITIVO',
      '__APPTYPE__'=> 'HW.IPMI',   '__ITIL_TYPE__'=> '1',  '__TAG__'=> '200',

#verde|azul|rojo|naranja
      '__ESP__'=>"MAP(1)(0,0,1)|MAP(2)(0,1,0)|MAP(0)(1,0,0)",
      '__ITEMS__'=>'Encendido|Desconocido|Apagado',

      '__IPTAB__'=> '0', '__VLABEL__'=> '',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_SOLID',
      '__NPARAMS__'=> '6',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.ipmi.user;0]:[-p;Clave;$sec.ipmi.pwd;1]:[-t;Timeout;2;0]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_ipmi_sensors::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'ipmi_sensors-check,[-n;IP;;2]:[-u;Usuario;$sec.ipmi.user;0]:[-p;Clave;$sec.ipmi.pwd;1]',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.ipmi.user', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.ipmi.pwd', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '2', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
         'p06' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ipmi_sensors::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que representa si la máquina está encendida a través de IPMI',
      },

      # ----------------------------
      '__MONITORS__' => {

         'm01' => { '__MONITOR__' => 'monitor=s_xagt_004035-64b4e1fc', '__CAUSE__' => 'EQUIPO APAGADO', '__EXPR__' => 'v2=1', '__HIDE__' => '1',  '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004035', '__SUBTYPE__' => 'xagt_004035', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "ESTADO DEL DISPOSITIVO" que genera una alerta de severidad ROJA cuando el equipo indique por IPMI que está apagado'  },
      },
   },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_ipmi_sensors::APPS = (


);



1;
__END__

