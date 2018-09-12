package cnm_backup_put;

# /opt/cnm/designer/gconf-proxy -m cnm_backup_put -p cnm-backup-put
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS @APPS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#---------------------------------------------------------------------------
# $CFG >> 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$cnm_backup_put::CFG = 1;
$cnm_backup_put::SCRIPT_NAME = 'cnm_backup_put.pl';

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
%cnm_backup_put::SCRIPT = (

	'__SCRIPT__' => $cnm_backup_put::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $cnm_backup_put::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 3600,

   # ----------------------------
   '__SCRIPT_PARAMS__' => {

#      'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-ip', '__PARAM_DESCR__' => 'Direccion IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_backup_put::SCRIPT_NAME },

      'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-file', '__PARAM_DESCR__' => 'Credentials file', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_backup_put::SCRIPT_NAME },
      'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-mode', '__PARAM_DESCR__' => 'Transfer mode', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_backup_put::SCRIPT_NAME },

      },

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este escript permite copiar el backup de CNM a un host remoto via ftp/sftp.Sus parametros de ejecución son:<b

cnm@cnm:/opt/cnm/xagent/base# ./cnm_backup_put.pl -help
cnm_backup_put.pl v1.0
(c)Fernando Marin <fmarin@s30labs.com> 27/01/2015

 cnm_backup_put.pl
 cnm_backup_put.pl [-file file_path] [-mode ftp|sftp]
 cnm_backup_put.pl -help

 -help : Help
 -file : Remote credentials file
 -mode : Transfer mode (ftp|sftp). By default is sftp.

 cat /cfg/ftpremote.conf
 host
 user
 pwd
',
		'__ID_REF__' => $cnm_backup_put::SCRIPT_NAME
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
@cnm_backup_put::METRICS = (

);

1;
__END__
