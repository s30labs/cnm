package linux_metric_mail_mbox;
# /opt/cnm/designer/gconf-proxy -m linux_metric_mail_mbox -p mail-mbox
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_mail_mbox::CFG = 0;
$linux_metric_mail_mbox::SCRIPT_NAME = 'linux_metric_mail_mbox.pl';

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
%linux_metric_mail_mbox::SCRIPT = (

	'__SCRIPT__' => $linux_metric_mail_mbox::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_mail_mbox::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-host', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_mail_mbox::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-proto', '__PARAM_DESCR__' => 'Protocol', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_mail_mbox::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-port', '__PARAM_DESCR__' => 'Port', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_mail_mbox::SCRIPT_NAME },
      'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-user', '__PARAM_DESCR__' => 'User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_mail_mbox::SCRIPT_NAME },
      'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-pwd', '__PARAM_DESCR__' => 'Password', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_mail_mbox::SCRIPT_NAME },
      'p06' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-ssl', '__PARAM_DESCR__' => 'SSL active', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_mail_mbox::SCRIPT_NAME },
      'p07' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-mailbox', '__PARAM_DESCR__' => 'Mailbox', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_mail_mbox::SCRIPT_NAME },
      'p08' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-timeout', '__PARAM_DESCR__' => 'Timeout', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_mail_mbox::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite validar el acceso a un buzon de correo por PO o IMAP. Sus parámetros de ejecución son:

cnm@cnm:/opt/cnm-sp/tcp_check/xagent/base# ./linux_metric_mail_mbox.pl
linux_metric_mail_mbox.pl. 1.0

linux_metric_mail_mbox.pl -host outlook.office365.com -port 995 -proto imap -ssl -user user\@domain.com -pwd xxx
linux_metric_mail_mbox.pl -host outlook.office365.com -port 993 -proto pop -ssl -user user\@domain.com -pwd xxx
linux_metric_mail_mbox.pl -h  : Ayuda

-host       : POP/IMAP Server Host
-proto      : imap/pop protocol (default imap)
-port       : Port (default 993 - imaps)
-user       : User
-pwd        : Password
-ssl        : If set uses SSL protocol
-mailbox    : User mailbox (default INBOX)
-timeout    : Connection timeout (default 2)
-v/-verbose : Verbose output (debug)
-h/-help    : Help
',
		'__ID_REF__' => $linux_metric_mail_mbox::SCRIPT_NAME
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
@linux_metric_event_counter::METRICS = (


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_event_counter::APPS = (


);



1;
__END__
