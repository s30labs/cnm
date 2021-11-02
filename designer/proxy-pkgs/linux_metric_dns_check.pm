package linux_metric_dns_check;
#/opt/cnm/designer/gconf-proxy -m linux_metric_dns_check -p dns-check
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_dns_check::CFG = 0;
$linux_metric_dns_check::SCRIPT_NAME = 'linux_metric_dns_check.pl';

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
%linux_metric_dns_check::SCRIPT = (

	'__SCRIPT__' => $linux_metric_dns_check::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_dns_check::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_dns_check::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-s', '__PARAM_DESCR__' => 'Servidor/es DNS', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_dns_check::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-t', '__PARAM_DESCR__' => 'Timeout', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_dns_check::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener la latencia de los servidores DNS especificados a lahora de resolver el nombre asociado al dispositivo. Sus parámetros de ejecución son:

cnm@cnm:/opt/cnm-sp/dns_check/xagent/base# ./linux_metrisc_dns_check.pl
linux_metric_dns_check.pl. 1.0

linux_metric_dns_check.pl -n Nombre/IP [-s DNS Servers] [-t timeout]
linux_metric_dns_check.pl -h  : Ayuda

-n    IP/Host 
-s    Servidor DNS utilizado. Se pueden especificar varios separados por ","
-t    Timeout
',
		'__ID_REF__' => $linux_metric_dns_check::SCRIPT_NAME
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
@linux_metric_dns_check::METRICS = (

	#------------------------------------------------------------------------
	{ 
		#defSUBTYPE=xagt_004018
		'__SUBTYPE__'=> 'xagt_004018', '__CLASS__'=> 'proxy-linux',  	
		'__DESCRIPTION__'=> 'TIEMPO DE RESPUESTA DEL DNS (Google)',
		'__APPTYPE__'=> 'IPSERV.WWW', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> '001|002', 	'__ESP__'=> 'o1|o2',
		'__IPTAB__'=> '1', '__ITEMS__'=> 'DNS1 Latency (seg)|DNS2 Latency (seg)', 	'__VLABEL__'=> 'T(segs)',
		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_AREA',	
		'__NPARAMS__'=> '3', 	'__PARAMS__'=> '[-n;IP;;2]:[-s;DNS Servers;8.8.8.8,8.8.4.4;0]:[-t;Timeout;2;0]', 	
		'__PARAMS_DESCR__'=> '',
		'__SCRIPT__'=> $linux_metric_dns_check::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '1',
		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '1',
		'__MYRANGE__'=>'dns-check,[-n;IP;;2]:[-s;DNS Servers;8.8.8.8,8.8.4.4;0]:[-t;Timeout;2;0]',

		# ----------------------------
	   '__METRIC_PARAMS__' => {

   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_dns_check::SCRIPT_NAME },
   	   'p02' => { '__ENABLE__' => '1', '__VALUE__' => '8.8.8.8,8.8.4.4', '__SCRIPT__' => $linux_metric_dns_check::SCRIPT_NAME },
   	   'p03' => { '__ENABLE__' => '1', '__VALUE__' => '2', '__SCRIPT__' => $linux_metric_dns_check::SCRIPT_NAME },
      },
		# ----------------------------
	   '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el tiempode respuesta del DNS ala hora de resolver el nombre del dispositivo. Se utilizan los servidores DNS publicos de Google (8.8.8.8 y 8.8.4.4)',
   	},

#+---------------+----------------------------------+----------------------------+-----------+--------+----------+-----------------+--------+-----------------+-------+--------------------+
#| id_alert_type | cause                            | monitor                    | expr      | params | severity | mname           | type   | subtype         | wsize | class              |
#+---------------+----------------------------------+----------------------------+-----------+--------+----------+-----------------+--------+-----------------+-------+--------------------+
#|            18 | EXCESO DE EVENTOS                | s_xagt_647cba-d30a2710     | v1>1000   | NULL   |        2 | xagt_647cba     | xagent | xagt_647cba     |     0 | proxy-linux        |

#/opt/cnm/designer/get_monitor_id -s xagt_004018
      # ----------------------------
      '__MONITORS__' => {

         'm01' => { '__MONITOR__' => 's_xagt_004018-d5cc402f', '__CAUSE__' => 'RESPUESTA LENTA DEL SERVIDOR DNS (Google)', '__EXPR__' => 'v1>1',  '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '3', '__MNAME__' => 'xagt_004018', '__SUBTYPE__' => 'xagt_004018', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor que genera una alerta si el tiempo de respuesta de alguno de los servidores DNS de Google superan 1 segundo.'  },
      },


	},


);

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_dns_check::APPS = (


);



1;
__END__
