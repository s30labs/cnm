package linux_metric_tcp_check;
# /opt/custom_pro/conf/gconf-proxy -m linux_metric_tcp_check -p tcp-check
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_tcp_check::CFG = 0;
$linux_metric_tcp_check::SCRIPT_NAME = 'linux_metric_tcp_check.pl';

#---------------------------------------------------------------------------
# DEFINICION DEL SCRIPT
# __SCRIPT__ 					=> Nombre del script
# __EXEC_MODE__				=>
# __SCRIPT_DESCRIPTION__ 	=> Descripcion del cript
# __PROXY_TYPE__				=>
# __CFG__						=> 0 METRICA  1=>APP
# __PROXY_USER__				=>
# __PROXY_PWD__				=>
#
# __PARAM_TYPE__				=> 0:normal 1:clave 2:ip
#---------------------------------------------------------------------------
# Si no se especifica valor para hparam, se generan internamente a partir de
# __SCRIPT__ (xagt_(md5(script.position))).

#---------------------------------------------------------------------------
%linux_metric_tcp_check::SCRIPT = (

	'__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_tcp_check::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Puerto', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-t', '__PARAM_DESCR__' => 'Timeout', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite validar si hay conectividad con un determinado puerto TCP. Sus parámetros de ejecución son:

cnm@cnm:/opt/cnm-sp/tcp_check/xagent/base# ./linux_metrisc_tcp_check.pl
linux_metric_tcp_check.pl. 1.0

linux_metric_tcp_check.pl -n IP -p port [-t timeout]
linux_metric_tcp_check.pl -h  : Ayuda

-n    IP/Host 
-p    Port
-t    Timeout
',
		'__ID_REF__' => $linux_metric_tcp_check::SCRIPT_NAME
	}
);

#---------------------------------------------------------------------------
# __CLASS__			=> proxy-linux
# __APPTYPE__		=> 
# __ITIL_TYPE__	=> operacion 1, configuracion 2, capacidad 3, disponibilidad 4, seguridad 5
# __TAG__
# __ESP__
# __IPTAB__
# __ITEMS__
# __VLABEL__
# __MODE__
# __MTYPE__
# __NPARAMS__
# __PARAMS__ 		=> [prefix;Nombre;default value;tipo] tipo ==> 0:normal 1:clave 2:ip
# __SEVERITY__
# __CFG__ 		=> 1 -> Sin instancias, 2 -> Con Instancias
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
@linux_metric_tcp_check::METRICS = (

	#------------------------------------------------------------------------
	{ 
		#defSUBTYPE=xagt_004010
		'__SUBTYPE__'=> 'xagt_004010', '__CLASS__'=> 'proxy-linux',  	
		'__DESCRIPTION__'=> 'TIEMPO DE RESPUESTA DEL PUERTO 80/TCP',
		'__APPTYPE__'=> 'IPSERV.WWW', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> '001', 	'__ESP__'=> 'o1',
		'__IPTAB__'=> '1', '__ITEMS__'=> 'T (segs)', 	'__VLABEL__'=> 'T(segs)',
		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_AREA',	
		'__NPARAMS__'=> '3', 	'__PARAMS__'=> '[-n;IP;;2]:[-p;Puerto;80;0]:[-t;Timeout;2;0]', 	
		'__PARAMS_DESCR__'=> '',
		'__SCRIPT__'=> $linux_metric_tcp_check::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '1',
		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '1',
		'__MYRANGE__'=>'tcp-check,[-n;IP;;2]:[-p;Puerto;80;0]:[-t;Timeout;2;0]',

		# ----------------------------
	   '__METRIC_PARAMS__' => {

   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
   	   'p02' => { '__ENABLE__' => '1', '__VALUE__' => '80', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
   	   'p03' => { '__ENABLE__' => '1', '__VALUE__' => '2', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
      },
		# ----------------------------
	   '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el tiempo qde respuesta del  puerto TCP/80',
   	},

#+---------------+----------------------------------+----------------------------+-----------+--------+----------+-----------------+--------+-----------------+-------+--------------------+
#| id_alert_type | cause                            | monitor                    | expr      | params | severity | mname           | type   | subtype         | wsize | class              |
#+---------------+----------------------------------+----------------------------+-----------+--------+----------+-----------------+--------+-----------------+-------+--------------------+
#|            18 | EXCESO DE EVENTOS                | s_xagt_647cba-d30a2710     | v1>1000   | NULL   |        2 | xagt_647cba     | xagent | xagt_647cba     |     0 | proxy-linux        |

#/opt/custom_pro/conf/get_monitor_id -s xagt_004010
      # ----------------------------
      '__MONITORS__' => {

         'm01' => { '__MONITOR__' => 's_xagt_004010-edf8e3ca', '__CAUSE__' => 'RESPUESTA LENTA EN PUERTO 80/TCP', '__EXPR__' => 'v1>1',  '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_004010', '__SUBTYPE__' => 'xagt_004010', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor que genera una alerta si el tiempo de respuesta del puerto 80/TCP es superior a 1 segundo.'  },
      },


	},


	#------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004011
      '__SUBTYPE__'=> 'xagt_004011', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'ESTADO DEL PUERTO 80/TCP',
      '__APPTYPE__'=> 'IPSERV.WWW',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '002',
      '__IPTAB__'=> '1',  '__VLABEL__'=> 'T(hours)',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_SOLID',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]:[-p;Puerto;80;0]:[-t;Timeout;2;0]',

      '__ESP__'=>'MAP(1)(1,0,0)|MAP(2)(0,1,0)|MAP(3)(0,0,1)',
      '__ITEMS__'=>'Ok(1)|Unknown(2)|Nok(3)',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_tcp_check::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'tcp-check,[-n;IP;;2]:[-p;Puerto;80;0]:[-t;Timeout;2;0]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '80', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
   	   'p03' => { '__ENABLE__' => '1', '__VALUE__' => '2', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitorizaestado del puerto 80/TCP. Puede tener tres valores: Ok(1), Unknown(2) y Nok(3).',
      },

		#/opt/custom_pro/conf/get_monitor_id -s xagt_004011
      # ----------------------------
      '__MONITORS__' => {

         'm01' => { '__MONITOR__' => 's_xagt_004011-097d9815', '__CAUSE__' => 'ERROR EN PUERTO 80/TCP', '__EXPR__' => 'v3=1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004011', '__SUBTYPE__' => 'xagt_004011', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor que genera una alerta si el estado del puerto 80/TCP es Nok.'  },
      },

   },


   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004012
      '__SUBTYPE__'=> 'xagt_004012', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'TIEMPO DE RESPUESTA DEL PUERTO 443/TCP',
      '__APPTYPE__'=> 'IPSERV.WWW',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '001',   '__ESP__'=> 'o1',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'T (segs)',  '__VLABEL__'=> 'T(segs)',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]:[-p;Puerto;443;0]:[-t;Timeout;2;0]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_tcp_check::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'tcp-check,[-n;IP;;2]:[-p;Puerto;443;0]:[-t;Timeout;2;0]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '2', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el tiempo qde respuesta del  pueerto 443/TCP',
      },

#/opt/custom_pro/conf/get_monitor_id -s xagt_004012
      # ----------------------------
      '__MONITORS__' => {

         'm01' => { '__MONITOR__' => 's_xagt_004012-edf8e3ca', '__CAUSE__' => 'RESPUESTA LENTA EN PUERTO 443/TCP', '__EXPR__' => 'v1>1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_004012', '__SUBTYPE__' => 'xagt_004012', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor que genera una alerta si el tiempo de respuesta del puerto 443/TCP es superior a 1 segundo.'  },
      },
   },


   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004013
      '__SUBTYPE__'=> 'xagt_004013', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'ESTADO DEL PUERTO 443/TCP',
      '__APPTYPE__'=> 'IPSERV.WWW',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '002',
      '__IPTAB__'=> '1',  '__VLABEL__'=> 'T(hours)',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_SOLID',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]:[-p;Puerto;443;0]:[-t;Timeout;2;0]',

      '__ESP__'=>'MAP(1)(1,0,0)|MAP(2)(0,1,0)|MAP(3)(0,0,1)',
      '__ITEMS__'=>'Ok(1)|Unknown(2)|Nok(3)',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_tcp_check::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'tcp-check,[-n;IP;;2]:[-p;Puerto;443;0]:[-t;Timeout;2;0]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '2', '__SCRIPT__' => $linux_metric_tcp_check::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitorizaastado  del puerto 443/TCP. Puede tener tres valores: Ok(1), Unknown(2) y Nok3).',
      },

#/opt/custom_pro/conf/get_monitor_id -s xagt_004013
      # ----------------------------
      '__MONITORS__' => {

         'm01' => { '__MONITOR__' => 's_xagt_004013-edf8e3ca', '__CAUSE__' => 'ERROR EN PUERTO 443/TCP', '__EXPR__' => 'v3=1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004013', '__SUBTYPE__' => 'xagt_004013', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor que genera una alerta si el estado del puerto 443/TCP es Nok.'  },
      },

   },

);

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_tcp_check::APPS = (


);



1;
__END__
