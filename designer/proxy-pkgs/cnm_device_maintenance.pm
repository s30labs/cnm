package cnm_device_maintenance;

# /opt/cnm/designer/gconf-proxy -m cnm_device_maintenance -p cnm-device-maintenance
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS @APPS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#---------------------------------------------------------------------------
# $CFG >> 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$cnm_device_maintenance::CFG = 1;
$cnm_device_maintenance::SCRIPT_NAME = 'cnm_device_maintenance.pl';

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
%cnm_device_maintenance::SCRIPT = (

	'__SCRIPT__' => $cnm_device_maintenance::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $cnm_device_maintenance::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 3600,

   # ----------------------------
   '__SCRIPT_PARAMS__' => {

      'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-dir-base', '__PARAM_DESCR__' => 'Base dir for calendar files', '__PARAM_VALUE__' => '/cfg', '__SCRIPT__' => $cnm_device_maintenance::SCRIPT_NAME },
      'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-custom-field', '__PARAM_DESCR__' => 'Device custom field name', '__PARAM_VALUE__' => 'CNM-MAINTENANCE', '__SCRIPT__' => $cnm_device_maintenance::SCRIPT_NAME },

      },

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Para definir periodos complejos de mantenimiento, se pueden definir ficheros de calendario en formato JSON para cada dispositvo. Este script comprueba para cada uno de ellos si el dispositivo esta en el estado correcto.

 cnm-device-maintenance.pl [-log-level info|debug] [-log-mode 1|2|3] [-dir-base /cfg] [-custom-field CNM-MAINTENANCE] [-v]
 cnm-device-maintenance.pl -dir-base /cfg/1234 -custom-field my_custom_field
 cnm-device-maintenance.pl -help

 -help : Help
 -v    : Verbose mode
 -log-level : info|debug
 -log-mode : 1 => syslog | 2 => stdout | 3 => both
 -dir-base : /cfg (default)
 -custom-field : CNM-MAINTENANCE (default)
',
		'__ID_REF__' => $cnm_device_maintenance::SCRIPT_NAME
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
@cnm_device_maintenance::METRICS = (

);

1;
__END__
