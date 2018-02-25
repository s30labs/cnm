package linux_metric_ldap_auth;
# /opt/cnm/designer/gconf-proxy -m linux_metric_ldap_auth -p ldap-auth
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_ldap_auth::CFG = 0;
$linux_metric_ldap_auth::SCRIPT_NAME = 'linux_metric_ldap_auth.pl';

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
%linux_metric_ldap_auth::SCRIPT = (

	'__SCRIPT__' => $linux_metric_ldap_auth::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_ldap_auth::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

#./linux_metric_ldap_auth.pl -host 192.168.62.127 -db IMODB -user ldapuserp -pwd ld4p1serp -sqlcmd "SET NOCOUNT ON;SELECT COUNT([UserAccount]) AS '001' FROM [IMODB].[dbo].[vwLDAPAcces] FOR JSON AUTO" -tag '001' -label 'Numero de usuarios'

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-host', '__PARAM_DESCR__' => 'LDAP Host', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ldap_auth::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-port', '__PARAM_DESCR__' => 'LDAP port', '__PARAM_VALUE__' => '1433', '__SCRIPT__' => $linux_metric_ldap_auth::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-user', '__PARAM_DESCR__' => 'LDAP User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ldap_auth::SCRIPT_NAME },
		'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-pwd', '__PARAM_DESCR__' => 'LDAP password', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ldap_auth::SCRIPT_NAME },
		'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-version', '__PARAM_DESCR__' => 'LDAP version', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ldap_auth::SCRIPT_NAME },
		'p06' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-secure', '__PARAM_DESCR__' => 'Uses ldaps', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ldap_auth::SCRIPT_NAME },

		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Checks for LDAP Authentication

The parameters are:

 linux_metric_ldap_auth.pl -host 1.1.1.1 -user user1 -pwd mysecret
 linux_metric_ldap_auth.pl -host 1.1.1.1 [-port 1111] -user user1 -pwd mysecret -version 1
 linux_metric_ldap_auth.pl -host 1.1.1.1 [-port 1111] -secure -user user1 -pwd mysecret
 linux_metric_ldap_auth.pl -h  : Help

 -host       : Database Server Host
 -port       : Port (default 389)
 -user       : LDAP User
 -pwd        : LDAP User Password
 -version    : LDAP Version (default 3)
 -secure     : LDAP/LDAPS
 -v/-verbose : Verbose output (debug)
 -h/-help    : Help
',
		'__ID_REF__' => $linux_metric_ldap_auth::SCRIPT_NAME
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
@linux_metric_ldap_auth::METRICS = (


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_ldap_auth::APPS = (


);



1;
__END__
