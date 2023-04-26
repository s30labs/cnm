package linux_app_snmp_linuxOS;
# /opt/cnm/designer/gconf-proxy -m linux_app_snmp_linuxOS -p snmp-linuxOS
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS @APPS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_app_snmp_linuxOS::CFG = 1;
$linux_app_snmp_linuxOS::SCRIPT_NAME = 'linux_app_snmp_linuxOS.pl';

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
%linux_app_snmp_linuxOS::SCRIPT = (

	'__SCRIPT__' => $linux_app_snmp_linuxOS::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_app_snmp_linuxOS::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 3600,

   # ----------------------------
   '__SCRIPT_PARAMS__' => {

      'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_app_snmp_linuxOS::SCRIPT_NAME },


      },

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este escript obtiene informacion de un Host por SNMP (Uptime,CPU). Las credenciales SNMP se obtienen del CNM y sus parámetros de ejecución son:<b
cnm@cnm:/opt/cnm/xagent/base# ./linux_app_snmp_linuxOS.pl -h
linux_app_snmp_linuxOS.pl 1.0

linux_app_snmp_linuxOS.pl -n IP  [-f verbose]
linux_app_snmp_linuxOS.pl -h  : Ayuda

-n    IP/Host
-f verbose
',
		'__ID_REF__' => $linux_app_snmp_linuxOS::SCRIPT_NAME
	}
);


#---------------------------------------------------------------------------
%linux_app_snmp_linuxOS::ATTR = (

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
@linux_app_snmp_linuxOS::METRICS = (

);


#---------------------------------------------------------------------------
# Posibles valores de myrange
# * -> Patra todo el mundo
# EN SNMP     >> HOST-RESOURCES-MIB::hrStorageTable
# EN LATENCY  >> comando a chequear
# EN XAGENT   >> win32::wmi::cimv2::Win32_Process
#                linux::lsof
# ip:localhost Para la ip especificada
# oid:.1.2.1.2... Para el oid especificado
#
# __SUBTYPE__
# __ANAME__
# __NAME__
# __CMD__
# __IPTAB__
# __READY__
# __PLATFORM__
# __SCRIPT__
# __APPTYPE__
# __ITIL_TYPE__	operacion 1, configuracion 2, capacidad 3, disponibilidad 4, seguridad 5
# __CFG__		0-> No instanciada, 1-> Instanciada
# __FORMAT__ 	0 => La aplicacion no genera formato | 1 => La aplicacion genera JSON
# __RES__		1 => Tiene resultados (hay solapa) | 0 => No tiene resultados (no hay solapa)
#
# enterprise es necesario para optimizar el chequeo de las snmp. En el resto de casos por
# ahora no tiene uso
#---------------------------------------------------------------------------
@linux_app_snmp_linuxOS::APPS = (

   #------------------------------------------------------------------------
   {
      '__SUBTYPE__'=> 'Win', '__ANAME__'=> 'app_snmp_linuxos',
      '__NAME__'=> 'INFO DEL SISTEMA OPERATIVO (SNMP)',
      '__DESCR__'=> '',
		'__CMD__'=> '',
		'__IPTAB__'=> '1', '__READY__'=> '1',
		'__MYRANGE__'=> '1', '__CFG__'=> '0', '__PLATFORM__'=> 'linux',
		'__SCRIPT__'=> $linux_app_snmp_linuxOS::SCRIPT_NAME,
		'__FORMAT__'=> '1', 
      '__RES__'=> '1', '__IPPARAM__'=> '', '__APPTYPE__'=> 'SO.LINUX',  '__ITIL_TYPE__'=> '1',  
		'__MYRANGE__'=>'', # Mejor que no se asocie. Que se haga desde rama de logs

      # ----------------------------
      '__APP_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_app_snmp_linuxOS::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Obtiene datos relevantes del sistema operativo (Uptime, CPU)',
      },

   },


);



1;
__END__
