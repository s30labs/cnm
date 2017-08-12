package linux_app_wmi_class;
# /opt/cnm-designer/gconf-proxy -m linux_app_wmi_class -p wmi-class
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_app_wmi_class::CFG = 1;
$linux_app_wmi_class::SCRIPT_NAME = 'linux_app_wmi_class.pl';

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
%linux_app_wmi_class::SCRIPT = (

	'__SCRIPT__' => $linux_app_wmi_class::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_app_wmi_class::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 3600,

	# ----------------------------
	# Tipos: 0->Normal, 1->Sec, 2->IP
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_app_wmi_class::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-u', '__PARAM_DESCR__' => 'User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_app_wmi_class::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Clave', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_app_wmi_class::SCRIPT_NAME },
		'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-c', '__PARAM_DESCR__' => 'Clase', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_app_wmi_class::SCRIPT_NAME },
		'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-i', '__PARAM_DESCR__' => 'Indice', '__PARAM_VALUE__' => 'Name', '__SCRIPT__' => $linux_app_wmi_class::SCRIPT_NAME },
		'p06' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-a', '__PARAM_DESCR__' => 'Namespace', '__PARAM_VALUE__' => '"root\CIMV2"', '__SCRIPT__' => $linux_app_wmi_class::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener los valores de las propiedades soportadas por la clase WMI especificada. Un ejemplo de ejecución es:<br>
cnm@cnm:/opt/cnm/xagent/base# ./linux_app_wmi_class.pl -h<br>
linux_app_wmi_class.pl 1.0<br>
<br>
linux_app_wmi_class.pl -n IP -u user -p pwd [-d domain] -c class [-i index] [-a "root\CIMV2"]<br>
linux_app_wmi_class.pl -n IP -u domain/user -p pwd -c class [-i index]<br>
linux_app_wmi_class.pl -h  : Ayuda<br>
<br>
-n    IP remota<br>
-u    user<br>
-p    pwd<br>
-d    Dominio<br>
-v    Verbose<br>
-c    Clase wmi (Win32_Service ...)<br>
-i    Indice (iid) para la Clase wmi (Si aplica)<br>
-a    Namespace (si es distinto de root\CIMV2)<br>
',
		'__ID_REF__' => $linux_app_wmi_class::SCRIPT_NAME
	}
);

1;
__END__
