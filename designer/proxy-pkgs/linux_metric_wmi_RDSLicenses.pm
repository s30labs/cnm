package linux_metric_wmi_RDSLicenses;
# /opt/cnm/designer/gconf-proxy -m linux_metric_wmi_RDSLicenses -p wmi-RDSLicenses
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_wmi_RDSLicenses::CFG = 0;
$linux_metric_wmi_RDSLicenses::SCRIPT_NAME = 'linux_metric_wmi_RDSLicenses.pl';

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
%linux_metric_wmi_RDSLicenses::SCRIPT = (

	'__SCRIPT__' => $linux_metric_wmi_RDSLicenses::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_wmi_RDSLicenses::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_RDSLicenses::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-u', '__PARAM_DESCR__' => 'User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_RDSLicenses::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Clave', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_RDSLicenses::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener metricas relativas a las licencias asignadas por un servidor RDS en un equipo con SO Windows a partir de la clase WMI (Win32_TSIssued_License). Sus parámetros de ejecución son:
root@cnm-devel:/opt/cnm/xagent/base# ./linux_metric_wmi_RDSLicenses.pl -h
linux_metric_wmi_RDSLicenses.pl 1.0

linux_metric_wmi_RDSLicenses.pl -n IP -u user -p pwd [-d domain]
linux_metric_wmi_RDSLicenses.pl -n IP -u domain/user -p pwd
linux_metric_wmi_RDSLicenses.pl -h  : Ayuda

-n    IP remota
-u    user
-p    pwd
-d    Dominio
',
		'__ID_REF__' => $linux_metric_wmi_RDSLicenses::SCRIPT_NAME
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
@linux_metric_wmi_RDSLicenses::METRICS = (

	#------------------------------------------------------------------------
	#<001.ACTIVE> Number of licenses in ACTIVE Status = 62
	#<001.CONCURRENT> Number of licenses in CONCURRENT Status = 0
	#<001.PENDING> Number of licenses in PENDING Status = 0
	#<001.REVOKED> Number of licenses in REVOKED Status = 0
	#<001.TEMP> Number of licenses in TEMP Status = 0
	#<001.UNK> Number of licenses in UNK Status = 0
	#<001.UPGRADE> Number of licenses in UPGRADE Status = 0
	#------------------------------------------------------------------------
	{ 
		#defSUBTYPE=xagt_00451A
		'__SUBTYPE__'=> 'xagt_00451A', '__CLASS__'=> 'proxy-linux',  	
		'__DESCRIPTION__'=> 'WMI - LICENCIAS RDS POR ESTADO',
		'__APPTYPE__'=> 'SO.WINDOWS', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> '001.ACTIVE|001.CONCURRENT|001.PENDING|001.REVOKED|001.TEMP|001.UNK|001.UPGRADE', 	'__ESP__'=> 'o1|o2|o3|o4|o5|o6|o7',
		'__IPTAB__'=> '1', '__ITEMS__'=> 'Active|Concurrent|Pending|Revoked|Temp|Unknown|Upgrade', 	'__VLABEL__'=> 'Num',
		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_AREA',	
		'__NPARAMS__'=> '3', 	'__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]', 	
		'__PARAMS_DESCR__'=> '',
		'__SCRIPT__'=> $linux_metric_wmi_RDSLicenses::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '1',
		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '1',
		'__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

		# ----------------------------
	   '__METRIC_PARAMS__' => {

   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_RDSLicenses::SCRIPT_NAME },
   	   'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_RDSLicenses::SCRIPT_NAME },
   	   'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_RDSLicenses::SCRIPT_NAME },
      },
		# ----------------------------
	   '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el númo de licencias asignadas por estado a partir del atributos <strong>Status</strong> de la clase WMI <strong>Win32_TSIssuedLicense</strong>.
Es válida para sistemas Windows.',
   	},


      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux'  },
#      },


	},

   #------------------------------------------------------------------------
	#<002.sIssuedToComputer> Number of active licenses by type: sIssuedToComputer = 0
	#<002.sIssuedToUser> Number of active licenses by type: sIssuedToUser = 62
	#<002.total> Number of active licenses by type: total = 62

   {
      #defSUBTYPE=xagt_00451B
      '__SUBTYPE__'=> 'xagt_00451B', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - LICENCIAS RDS ACTIVAS',
      '__APPTYPE__'=> 'SO.WINDOWS',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '002.total|002.sIssuedToUser|002.sIssuedToComputer',  '__ESP__'=> 'o1|o2|o3',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'Total|sIssuedToUser|sIssuedToComputer',  '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_RDSLicenses::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_RDSLicenses::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_RDSLicenses::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_RDSLicenses::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza elnumero de licencias activas asignadas usando los atributos <strong>sIssuedToUser, sIssuedToComputer</strong> de la clase WMI <strong>Win32_TSIssuedLicense</strong>.
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
%linux_metric_wmi_RDSLicenses::APPS = (

);



1;
__END__
