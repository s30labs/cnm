package linux_metric_ssl_certs;
# /opt/cnm/designer/gconf-proxy -m linux_metric_ssl_certs -p ssl-certs
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_ssl_certs::CFG = 0;
$linux_metric_ssl_certs::SCRIPT_NAME = 'linux_metric_ssl_certs.pl';

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
%linux_metric_ssl_certs::SCRIPT = (

	'__SCRIPT__' => $linux_metric_ssl_certs::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_ssl_certs::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssl_certs::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Puerto', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssl_certs::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-t', '__PARAM_DESCR__' => 'Protocolo', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssl_certs::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener el tiempo restante para la caducidad de un certificado digital. Sus parámetros de ejecución son:

cnm@cnm:/opt/cnm-sp/ssl-certs/xagent/base# ./linux_metric_ssl_certs.pl
linux_metric_ssl_certs.pl. 1.0

linux_metric_ssl_certs.pl -n IP -p port -t type [-v]
linux_metric_ssl_certs.pl -h  : Ayuda

-n    IP/Host 
-p    Port
-t    Protocol type (https|smtp|pop3|imap|ftp)
-v    Verbose
',
		'__ID_REF__' => $linux_metric_ssl_certs::SCRIPT_NAME
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
@linux_metric_ssl_certs::METRICS = (

	#------------------------------------------------------------------------
	{ 
		#defSUBTYPE=xagt_004000
		'__SUBTYPE__'=> 'xagt_004000', '__CLASS__'=> 'proxy-linux',  	
		'__DESCRIPTION__'=> 'CADUCIDAD DE CERTIFICADO SSL HTTPS/443 (sgs)',
		'__APPTYPE__'=> 'IPSERV.SSL', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> '001', 	'__ESP__'=> 'o1',
		'__IPTAB__'=> '1', '__ITEMS__'=> 'T (segs)', 	'__VLABEL__'=> 'T(segs)',
		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_AREA',	
		'__NPARAMS__'=> '3', 	'__PARAMS__'=> '[-n;IP;;2]:[-p;Puerto;443;0]:[-t;Protocolo;https;0]', 	
		'__PARAMS_DESCR__'=> '',
		'__SCRIPT__'=> $linux_metric_ssl_certs::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '1',
		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '0',
		'__MYRANGE__'=>'ssl-check,[-n;IP;;2]:[-p;Puerto;443;0]:[-t;Protocolo;https;0]',

		# ----------------------------
	   '__METRIC_PARAMS__' => {

   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ssl_certs::SCRIPT_NAME },
   	   'p02' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_ssl_certs::SCRIPT_NAME },
   	   'p03' => { '__ENABLE__' => '1', '__VALUE__' => 'https', '__SCRIPT__' => $linux_metric_ssl_certs::SCRIPT_NAME },
      },
		# ----------------------------
	   '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el tiempo que falta en segundos para que caduque el certificado digital del equipo monitorizado.',
   	},

#+---------------+----------------------------------+----------------------------+-----------+--------+----------+-----------------+--------+-----------------+-------+--------------------+
#| id_alert_type | cause                            | monitor                    | expr      | params | severity | mname           | type   | subtype         | wsize | class              |
#+---------------+----------------------------------+----------------------------+-----------+--------+----------+-----------------+--------+-----------------+-------+--------------------+
#|            18 | EXCESO DE EVENTOS                | s_xagt_647cba-d30a2710     | v1>1000   | NULL   |        2 | xagt_647cba     | xagent | xagt_647cba     |     0 | proxy-linux        |


      # ----------------------------
      '__MONITORS__' => {

#         'm01' => { '__MONITOR__' => 's_xagt_647cba-0062f99a', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000',  '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - NUMERO DE EVENTOS ALMACENADOS" que genera una alerta de severidad NARANJA cuando se cumple la expresión: v1>1000 siendo v1 el número de eventos'  },
      },


	},


	#------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004001
      '__SUBTYPE__'=> 'xagt_004001', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'CADUCIDAD DE CERTIFICADO SSL HTTPS/443 (d)',
      '__APPTYPE__'=> 'IPSERV.SSL',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '002',   '__ESP__'=> 'o1',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'T (days)',  '__VLABEL__'=> 'T(days)',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]:[-p;Puerto;443;0]:[-t;Protocolo;https;0]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_ssl_certs::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'ssl-check,[-n;IP;;2]:[-p;Puerto;443;0]:[-t;Protocolo;https;0]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ssl_certs::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_ssl_certs::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => 'https', '__SCRIPT__' => $linux_metric_ssl_certs::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el tiempo que falta en horas para que caduque el certificado digital del equipo monitorizado.',
      }
   }

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_ssl_certs::APPS = (


);



1;
__END__
