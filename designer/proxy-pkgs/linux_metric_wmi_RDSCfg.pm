package linux_metric_wmi_RDSCfg;
# /opt/cnm/designer/gconf-proxy -m linux_metric_wmi_RDSCfg -p wmi-RDSCfg
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_wmi_RDSCfg::CFG = 0;
$linux_metric_wmi_RDSCfg::SCRIPT_NAME = 'linux_metric_wmi_RDSCfg.pl';

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
%linux_metric_wmi_RDSCfg::SCRIPT = (

	'__SCRIPT__' => $linux_metric_wmi_RDSCfg::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_wmi_RDSCfg::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_RDSCfg::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-u', '__PARAM_DESCR__' => 'User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_RDSCfg::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Clave', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_RDSCfg::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener metricas relativas a RDS en un equipo con SO Windows a partir de diferentes clases WMI (Win32_TerminalService). Sus parámetros de ejecución son:
root@cnm-devel:/opt/cnm/xagent/base# ./linux_metric_wmi_RDSCfg.pl -h
linux_metric_wmi_RDSCfg.pl 1.0

linux_metric_wmi_RDSCfg.pl -n IP -u user -p pwd [-d domain]
linux_metric_wmi_RDSCfg.pl -n IP -u domain/user -p pwd
linux_metric_wmi_RDSCfg.pl -h  : Ayuda

-n    IP remota
-u    user
-p    pwd
-d    Dominio
',
		'__ID_REF__' => $linux_metric_wmi_RDSCfg::SCRIPT_NAME
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
@linux_metric_wmi_RDSCfg::METRICS = (

	#------------------------------------------------------------------------
	{ 
		#defSUBTYPE=xagt_004515
		'__SUBTYPE__'=> 'xagt_004515', '__CLASS__'=> 'proxy-linux',  	
		'__DESCRIPTION__'=> 'WMI - SESIONES REMOTAS',
		'__APPTYPE__'=> 'SO.WINDOWS', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> 'TotalSessions|DisconnectedSessions', 	'__ESP__'=> 'o1|o2',
		'__IPTAB__'=> '1', '__ITEMS__'=> 'TotalSessions|DisconnectedSessions', 	'__VLABEL__'=> 'Num',
		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_AREA',	
		'__NPARAMS__'=> '3', 	'__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]', 	
		'__PARAMS_DESCR__'=> '',
		'__SCRIPT__'=> $linux_metric_wmi_RDSCfg::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '1',
		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '1',
		'__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

		# ----------------------------
	   '__METRIC_PARAMS__' => {

   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_RDSCfg::SCRIPT_NAME },
   	   'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_RDSCfg::SCRIPT_NAME },
   	   'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_RDSCfg::SCRIPT_NAME },
      },
		# ----------------------------
	   '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el númertotal ds esiones remotas y las desconectadas partir de los atributos <strong>TotalSessions, DisconnectedSessions</strong> de la clase WMI <strong>Win32_TerminalSevice</strong>.
Es válida para sistemas Windows.',
   	},


      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux'  },
#      },


	},


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_wmi_RDSCfg::APPS = (

);



1;
__END__
