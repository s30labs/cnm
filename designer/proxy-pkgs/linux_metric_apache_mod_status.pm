package linux_metric_apache_mod_status;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_apache_mod_status::CFG = 0;
$linux_metric_apache_mod_status::SCRIPT_NAME = 'linux_metric_apache_mod_status.pl';

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
%linux_metric_apache_mod_status::SCRIPT = (

	'__SCRIPT__' => $linux_metric_apache_mod_status::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_apache_mod_status::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_apache_mod_status::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener los datos de rendimiento de un servidor Apache proporcionados por el modulo mod_status.<br>Para que funcione correctamente, debe estar habilitado el modulo mod_status en el servidor de Apache (http://httpd.apache.org/docs/2.2/mod/mod_status.html).<br>Para configurar el módulo en Apache 2.x se deben seguir las siguientes instrucciones:<br>Confirmar que mod_info está corriendo:<br>a2enmod info<br>Incluir en el fichero de configuraión:<br><Location /server-status>
    SetHandler server-status
    Order deny,allow
    Deny from all
    Allow from .your_domain.com
</Location><br>Si se habilita el modo extendido mediante la directiva:<br>ExtendedStatus On<br>se obtienen más datos.',
		'__ID_REF__' => $linux_metric_apache_mod_status::SCRIPT_NAME
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
@linux_metric_apache_mod_status::METRICS = (

	#------------------------------------------------------------------------
	{ 
		'__SUBTYPE__'=> 'xagt_667d22', '__CLASS__'=> 'proxy-linux',  	
		'__DESCRIPTION__'=> 'APACHE - PETICIONES',
		'__APPTYPE__'=> 'WWW.APACHE', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> '002', 	'__ESP__'=> 'o1',
		'__IPTAB__'=> '1', '__ITEMS__'=> 'Num. Peticiones', 	'__VLABEL__'=> 'Num',
		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_AREA',	
		'__NPARAMS__'=> '3', 	'__PARAMS__'=> '[-n;IP;;2]', 	
		'__PARAMS_DESCR__'=> '',
		'__SCRIPT__'=> $linux_metric_apache_mod_status::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '1',
		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '1',
		'__MYRANGE__'=> 'apache_mod_status-check,[-n;IP;;2]',

		# ----------------------------
	   '__METRIC_PARAMS__' => {

   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_apache_mod_status::SCRIPT_NAME },
      },
		# ----------------------------
	   '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el numero de peticiones (requests) que tiene el servidor Apache a partir de los datos reportados por el módulo <strong>mod_status</strong>.',
   	},

      # ----------------------------
      '__MONITORS__' => {

         'm01' => { '__MONITOR__' => 's_xagt_667d22-7bb36e58', '__CAUSE__' => 'EXCESIVAS PETICIONES EN SERVIDOR WEB', '__EXPR__' => 'v1>1000',  '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_667d22', '__SUBTYPE__' => 'xagt_667d22', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "APACHE - PETICIONES" que genera una alerta de severidad NARANJA cuando se cumple la expresión: v1>1000 siendo v1 el número de conexiones'  },
      },


	},


	#------------------------------------------------------------------------
   {
      '__SUBTYPE__'=> 'xagt_c0d09a', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'APACHE - WORKERS',
      '__APPTYPE__'=> 'WWW.APACHE',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '003|004|006|007|009',   '__ESP__'=> 'o1|o2|o3|o4|o5',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'Idle|Waiting|Request|Reply|DNSLookup',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_apache_mod_status::SCRIPT_NAME,   '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
		'__MYRANGE__'=> 'apache_mod_status-check,[-n;IP;;2]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_apache_mod_status::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el numero de procesos (workers) del servidor Apache y su estado a partir de los datos reportados por el módulo <strong>mod_status</strong>.',
      },

      # ----------------------------

   },

   #------------------------------------------------------------------------
   {
      '__SUBTYPE__'=> 'xagt_4ebd09', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'APACHE - ACCESOS TOTALES',
      '__APPTYPE__'=> 'WWW.APACHE',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '015',   '__ESP__'=> 'o1',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'Accesos',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'COUNTER',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_apache_mod_status::SCRIPT_NAME,   '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
		'__MYRANGE__'=> 'apache_mod_status-check,[-n;IP;;2]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_apache_mod_status::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el numero de accesos totales al servidor Apache a partir de los datos reportados por el módulo <strong>mod_status</strong>.',
      },

      # ----------------------------

   },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_apache_mod_status::APPS = (


);



1;
__END__
