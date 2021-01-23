package linux_metric_event_window;
# /opt/cnm/designer/gconf-proxy -m linux_metric_event_window -p event-window
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_event_window::CFG = 0;
$linux_metric_event_window::SCRIPT_NAME = 'linux_metric_event_window.pl';

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
%linux_metric_event_window::SCRIPT = (

	'__SCRIPT__' => $linux_metric_event_window::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_event_window::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

#./linux_metric_event_window.pl -host 192.168.62.127 -db IMODB -user ldapuserp -pwd ld4p1serp -sqlcmd "SET NOCOUNT ON;SELECT COUNT([UserAccount]) AS '001' FROM [IMODB].[dbo].[vwLDAPAcces] FOR JSON AUTO" -tag '001' -label 'Numero de usuarios'

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-host', '__PARAM_DESCR__' => 'Host', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_event_window::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-app', '__PARAM_DESCR__' => 'APP ID', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_event_window::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-wt', '__PARAM_DESCR__' => 'Window Time', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_event_window::SCRIPT_NAME },
		'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-ws', '__PARAM_DESCR__' => 'Window Size', '__PARAM_VALUE__' => '60', '__SCRIPT__' => $linux_metric_event_window::SCRIPT_NAME },
		'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-pattern', '__PARAM_DESCR__' => 'Pattern', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_event_window::SCRIPT_NAME },
		'p06' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-lapse', '__PARAM_DESCR__' => 'Query Lapse', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_event_window::SCRIPT_NAME },

		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Provides the values for monitoring if a specific event happens in a temporal window specified by parameters.

It provides the following metric data: 
<001> Monitoring Window = 0
 <002> Error Window = 0
 <003> Number of Items = U
 <004> Received Status Time Lapse (min) = 0
 <005> Wait Status Time Lapse (min) = 0

The parameters are:

 -host       : Host for metric association.
 -app        : APP Id.
 -wt         : Window Time for positioning the center of the window. (several values specified by comma)
               Valid formats are: "8" "8,15" "8:30,15:30"
 -ws         : Window size (in minutes). Default is 60.
 -lapse      : APP ID table querying lapse from current time. (minutes)
 -pattern    : APP ID table querying pattern. E
 -v/-verbose : Verbose output (debug)
 -h/-help    : Help
',
		'__ID_REF__' => $linux_metric_event_window::SCRIPT_NAME
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
@linux_metric_event_window::METRICS = (


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_event_window::APPS = (


);



1;
__END__
