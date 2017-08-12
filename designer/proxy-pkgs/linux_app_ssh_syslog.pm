package linux_app_ssh_syslog;

#---------------------------------------------------------------------------
# ./gconf-proxy -m linux_app_ssh_syslog -p ssh-syslog
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS @APPS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_app_ssh_syslog::CFG = 1;
$linux_app_ssh_syslog::SCRIPT_NAME = 'linux_app_ssh_syslog.pl';

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
%linux_app_ssh_syslog::SCRIPT = (

	'__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_app_ssh_syslog::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
	'__TIMEOUT__' => 3600,

   # ----------------------------
   '__SCRIPT_PARAMS__' => {

      'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
      'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-c', '__PARAM_DESCR__' => 'Credencial', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
      'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-x', '__PARAM_DESCR__' => 'Credencial', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
      'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-l', '__PARAM_DESCR__' => 'Credencial', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
      'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-w', '__PARAM_DESCR__' => 'Credencial', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
      },

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este escript permite ejecutar uno o varios comandos por ssh y enviar el resultado obtenido por syslog utilizando la facility "local2". Sus parámetros de ejecución son:<br>
cnm@cnm:/opt/cnm/xagent/base# ./linux_app_ssh_syslog.pl -h
linux_app_ssh_syslog.pl 1.0

linux_app_ssh_syslog.pl -n IP -c nombre_credencial
linux_app_ssh_syslog.pl -n IP -c "-user=aaa -pwd=bbb" [-w xml] [-v]
linux_app_ssh_syslog.pl -h  : Ayuda

-n  IP remota/local
-c  Credenciales SSH
-x  Comando a ejecutar. Si hay varios, se pueden separar con &&.
-l  Se genera la salida para el syslog linea a linea. En caso contrario el resultado del comando se mete en una linea de syslog.
-w  Formato de salida (xml|txt)
-h  Ayuda
',
		'__ID_REF__' => $linux_app_ssh_syslog::SCRIPT_NAME
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
@linux_app_ssh_syslog::METRICS = (

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
@linux_app_ssh_syslog::APPS = (

   #------------------------------------------------------------------------
   {
      '__SUBTYPE__'=> 'Linux', '__ANAME__'=> 'app_linux_net_config_to_syslog',
      '__NAME__'=> 'LINUX NET CONFIG A SYSLOG',
      '__DESCR__'=> '',
		'__CMD__'=> '',
		'__IPTAB__'=> '1', '__READY__'=> '1',
		'__MYRANGE__'=> '1', '__CFG__'=> '0', '__PLATFORM__'=> 'Linux',
		'__SCRIPT__'=> $linux_app_ssh_syslog::SCRIPT_NAME,
		'__FORMAT__'=> '1', 
      '__RES__'=> '1', '__IPPARAM__'=> '', '__APPTYPE__'=> 'SO.LINUX',  '__ITIL_TYPE__'=> '1',  
		'__MYRANGE__'=>'', # Mejor que no se asocie. Que se haga desde rama de logs

      # ----------------------------
      '__APP_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '"/bin/netstat -rn && /bin/cat /etc/resolv.conf"', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Ejecuta por SSH los siguientes comandos: netstat -rn y cat /etc/resolv.conf. El resultado lo envia a CNM por syslog.',
      },
   },

   {
      '__SUBTYPE__'=> 'Linux', '__ANAME__'=> 'app_ccm_diag_to_syslog',
      '__NAME__'=> 'CALL MANAGER DIAGNOSE TEST A SYSLOG',
      '__DESCR__'=> '',
      '__CMD__'=> '',
      '__IPTAB__'=> '1', '__READY__'=> '1',
      '__MYRANGE__'=> '1', '__CFG__'=> '0', '__PLATFORM__'=> 'Linux',
      '__SCRIPT__'=> $linux_app_ssh_syslog::SCRIPT_NAME,
      '__FORMAT__'=> '1',
      '__RES__'=> '1', '__IPPARAM__'=> '', '__APPTYPE__'=> 'NET.CISCO',  '__ITIL_TYPE__'=> '1',
      '__MYRANGE__'=>'', # Mejor que no se asocie. Que se haga desde rama de logs

      # ----------------------------
      '__APP_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '"utils diagnose test"', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $linux_app_ssh_syslog::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Ejecuta por SSH el comando "utils diagnose test" en un Call Manager de Cisco. El resultado lo envia a CNM por syslog.',
      },
   },

);



1;
__END__
