package linux_metric_ssh_linuxSysstats;
# /opt/cnm/designer/gconf-proxy -m linux_metric_ssh_linuxSysstats -p ssh-linuxSysstats
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_ssh_linuxSysstats::CFG = 0;
$linux_metric_ssh_linuxSysstats::SCRIPT_NAME = 'linux_metric_ssh_linuxSysstats.pl';

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
%linux_metric_ssh_linuxSysstats::SCRIPT = (

	'__SCRIPT__' => $linux_metric_ssh_linuxSysstats::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_ssh_linuxSysstats::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxSysstats::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-port', '__PARAM_DESCR__' => 'Puerto', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxSysstats::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-user', '__PARAM_DESCR__' => 'Usuario', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxSysstats::SCRIPT_NAME },
		'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-pwd', '__PARAM_DESCR__' => 'Clave', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxSysstats::SCRIPT_NAME },
		'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-passphrase', '__PARAM_DESCR__' => 'Passphrase', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxSysstats::SCRIPT_NAME },
		'p06' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-key_file', '__PARAM_DESCR__' => 'Fichero de clave privada', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxSysstats::SCRIPT_NAME },

		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener los datos proporcionados por los contadores de rendimiento syssyats para un SO unix/Linux.

Sus parámetros de ejecución son:

 linux_metric_ssh_linuxSysstats.pl -n 1.1.1.1 [-port 2322]
 linux_metric_ssh_linuxSysstats.pl -n 1.1.1.1 -user=aaa -pwd=bbb
 linux_metric_ssh_linuxSysstats.pl -n 1.1.1.1 -user=aaa -key_file=/etc/ssh/id_rsa
 linux_metric_ssh_linuxSysstats.pl -n 1.1.1.1 -user=aaa -key_file=1
 linux_metric_ssh_linuxSysstats.pl -h  : Ayuda

 -n          : IP remota
 -port       : Puerto
 -user       : Usuario
 -pwd        : Clave
 -passphrase : Passphrase SSH
 -key_file   : Fichero con la clave publica (Si vale 1 indica que ua el ficheo estandar de CNM)
 -v/-verbose : Muestra informacion extra(debug)
 -h/-help    : Ayuda
 -l          : Lista las metricas que obtiene
',
		'__ID_REF__' => $linux_metric_ssh_linuxSysstats::SCRIPT_NAME
	}
);

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
@linux_metric_ssh_linuxSysstats::METRICS = (


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_ssh_linuxSysstats::APPS = (


);



1;
__END__
