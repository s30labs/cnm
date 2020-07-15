package linux_metric_wmi_process;
# /opt/cnm/designer/gconf-proxy -m linux_metric_wmi_process -p wmi-process
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_wmi_process::CFG = 0;
$linux_metric_wmi_process::SCRIPT_NAME = 'linux_metric_wmi_process.pl';

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
%linux_metric_wmi_process::SCRIPT = (

	'__SCRIPT__' => $linux_metric_wmi_process::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_wmi_process::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	# Tipos: 0->Normal, 1->Sec, 2->IP
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_process::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-u', '__PARAM_DESCR__' => 'User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_process::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Clave', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_process::SCRIPT_NAME },
      'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-i', '__PARAM_DESCR__' => 'Name', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_process::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener el numero de procesos en ejecucion en un equipo Win32. Un ejemplo de ejecución es:
cnm@cnm:/opt/cnm/xagent/base# ./linux_metric_wmi_process.pl -h
linux_metric_wmi_process.pl 1.0

linux_metric_wmi_process.pl -n IP -u user -p pwd [-d domain]
linux_metric_wmi_process.pl -n IP -u domain/user -p pwd
linux_metric_wmi_process.pl -h  : Ayuda

-n    IP remota
-u    user
-p    pwd
-d    Dominio
-i    Nombre del proceso
-h    Ayuda

linux_metric_wmi_process.pl -n 1.1.1.1 -u user -p xxx
linux_metric_wmi_process.pl -n 1.1.1.1 -u user -p xxx -d miDominio
',
		'__ID_REF__' => $linux_metric_wmi_process::SCRIPT_NAME
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
@linux_metric_wmi_process::METRICS = (


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_wmi_process::APPS = (

);



1;
__END__
