package linux_metric_event_counter;
# /opt/cnm/designer/gconf-proxy -m linux_metric_event_counter -p event-counter
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_event_counter::CFG = 0;
$linux_metric_event_counter::SCRIPT_NAME = 'linux_metric_event_counter.pl';

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
%linux_metric_event_counter::SCRIPT = (

	'__SCRIPT__' => $linux_metric_event_counter::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_event_counter::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

#./linux_metric_event_counter.pl -host 192.168.62.127 -db IMODB -user ldapuserp -pwd ld4p1serp -sqlcmd "SET NOCOUNT ON;SELECT COUNT([UserAccount]) AS '001' FROM [IMODB].[dbo].[vwLDAPAcces] FOR JSON AUTO" -tag '001' -label 'Numero de usuarios'

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-host', '__PARAM_DESCR__' => 'Host', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_event_counter::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-app', '__PARAM_DESCR__' => 'APP ID', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_event_counter::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-syslog', '__PARAM_DESCR__' => 'Remote Host', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_event_counter::SCRIPT_NAME },
		'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-trap', '__PARAM_DESCR__' => 'Remote Host', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_event_counter::SCRIPT_NAME },
		'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-lapse', '__PARAM_DESCR__' => 'Lapse (min.)', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_event_counter::SCRIPT_NAME },
		'p06' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-pattern', '__PARAM_DESCR__' => 'Pattern', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_event_counter::SCRIPT_NAME },

		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Provides the number of events received.
The script returns the number of events received from a specific APP or a specific host by syslog or traps during the interval specified in lapse with the pattern specified in pattern.

It provides one metric:

 <001> Event Counter = 6

The parameters are:

 linux_metric_event_counter.pl -app 333333000006 -lapse 120 -pattern "key":"val" [-v]
 linux_metric_event_counter.pl -syslog ip -lapse 120 -pattern "FTP.Login.Failed" [-v]
 linux_metric_event_counter.pl -trap ip|id_dev|name.domain -lapse 120 -pattern "FTP.Login.Failed" [-v]
 linux_metric_event_counter.pl -h  : Help

 -app        : ID de la app.
 -syslog     : IP del equipo que envia por syslog.
 -trap       : IP|id_dev|name.domain del equipo que envia el trap.
 -lapse      : Intervalo seleccionado referenciado desde el instante actual (now-lapse). Se especifica en minutos. Por defecto 60.
 -pattern    : Patron de busqueda. Por defecto se cuentan todos los eventos.
 -v/-verbose : Verbose output (debug)
 -h/-help    : Help
',
		'__ID_REF__' => $linux_metric_event_counter::SCRIPT_NAME
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
@linux_metric_event_counter::METRICS = (


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_event_counter::APPS = (


);



1;
__END__
