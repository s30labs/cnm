package linux_app_ssl_certs;
# /opt/cnm-designer/gconf-proxy -m linux_app_ssl_certs -p ssl-certs
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS @APPS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_app_ssl_certs::CFG = 1;
$linux_app_ssl_certs::SCRIPT_NAME = 'linux_app_ssl_certs.pl';

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
%linux_app_ssl_certs::SCRIPT = (

	'__SCRIPT__' => $linux_app_ssl_certs::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_app_ssl_certs::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 3600,

   # ----------------------------
   '__SCRIPT_PARAMS__' => {

      'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_app_ssl_certs::SCRIPT_NAME },
      'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Puerto', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_app_ssl_certs::SCRIPT_NAME },
      'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-t', '__PARAM_DESCR__' => 'Protocolo', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_app_ssl_certs::SCRIPT_NAME },


      },

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este escript permite obtener informacion relevante sobre el certificado digital instalado en el equipo. Sus parámetros de ejecución son:<b
cnm@cnm:/opt/cnm/xagent/base# ./linux_app_ssl_certs.pl -h
linux_app_ssl_certs.pl 1.0

linux_app_ssl_certs.pl -n IP -p port -t type [-v]
linux_app_ssl_certs.pl -h  : Ayuda

-n    IP/Host
-p    Port
-t    Protocol type (https|smtp|pop3|imap|ftp)
-u 	Actualiza campos de usuario
-v    Verbose
',
		'__ID_REF__' => $linux_app_ssl_certs::SCRIPT_NAME
	}
);


#---------------------------------------------------------------------------
%linux_app_ssl_certs::ATTR = (

	'devices' => [

			'ssl_cert_start_date',  
			'ssl_cert_end_date',  
			'ssl_cert_issuer',  
			'ssl_cert_version',  
			'ssl_cert_url',  
		],
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
@linux_app_ssl_certs::METRICS = (

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
@linux_app_ssl_certs::APPS = (

   #------------------------------------------------------------------------
   {
      '__SUBTYPE__'=> 'Win', '__ANAME__'=> 'app_ssl_certs',
      '__NAME__'=> 'OBTENER INFORMACION DE LOS CERTIFICADOS DIGITALES',
      '__DESCR__'=> '',
		'__CMD__'=> '',
		'__IPTAB__'=> '1', '__READY__'=> '1',
		'__MYRANGE__'=> '1', '__CFG__'=> '0', '__PLATFORM__'=> 'win',
		'__SCRIPT__'=> $linux_app_ssl_certs::SCRIPT_NAME,
		'__FORMAT__'=> '1', 
      '__RES__'=> '1', '__IPPARAM__'=> '', '__APPTYPE__'=> 'IPSERV.SSL',  '__ITIL_TYPE__'=> '1',  
		'__MYRANGE__'=>'', # Mejor que no se asocie. Que se haga desde rama de logs

      # ----------------------------
      '__APP_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_app_ssl_certs::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_app_ssl_certs::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => 'https', '__SCRIPT__' => $linux_app_ssl_certs::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Obtiene los datos relevantes a los certificados digitales instalados en el equipo',
      },

   },


);



1;
__END__
