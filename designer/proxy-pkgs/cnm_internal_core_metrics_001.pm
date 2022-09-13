package cnm_internal_core_metrics_001;
# /opt/cnm/designer/gconf-proxy -m cnm_internal_core_metrics_001 -p cnm-internal-core-metrics-001
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$cnm_internal_core_metrics_001::CFG = 0;
$cnm_internal_core_metrics_001::SCRIPT_NAME = 'cnm_internal_core_metrics_001.pl';

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
%cnm_internal_core_metrics_001::SCRIPT = (

	'__SCRIPT__' => $cnm_internal_core_metrics_001::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $cnm_internal_core_metrics_001::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-host', '__PARAM_DESCR__' => 'Host', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_internal_core_metrics_001::SCRIPT_NAME },
      'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-lapse', '__PARAM_DESCR__' => 'Lapse', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_internal_core_metrics_001::SCRIPT_NAME },
		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script obtiene metricas internas de CNM a partir de datos de syslog.

cnm_internal_core_metrics_001.pl -host id_dev|name|ip] -lapse 300 [-v]
cnm_internal_core_metrics_001.pl -h  : Ayuda

Donde -host puede ser id_dev, ip o host_name (name+domain)
',
		'__ID_REF__' => $cnm_internal_core_metrics_001::SCRIPT_NAME
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
@cnm_internal_core_metrics_001::METRICS = (

   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_003000
      '__SUBTYPE__'=> 'xagt_003000', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'MENSAJES EN BUZON IMAP4 - INBOX',
      '__APPTYPE__'=> 'CNM',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '001',
      '__IPTAB__'=> '1',  '__VLABEL__'=> 'Num Msgs',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '2',    '__PARAMS__'=> '[-host;Host;;2]:[-lapse;Lapse;300;0]',

      '__ESP__'=>'o1',
      '__ITEMS__'=>'Num mails in INBOX',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $cnm_internal_core_metrics_001::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '0',
      '__MYRANGE__'=>'',


      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $cnm_internal_core_metrics_001::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '300', '__SCRIPT__' => $cnm_internal_core_metrics_001::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métria interna de CNM que monitoiza el numero de correos en el buzon INBOX antes de su descarga por core-imap.',
      },

   },

   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_003001
      '__SUBTYPE__'=> 'xagt_003001', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'CONECTIVIDAD AL BUZON IMAP4 - INBOX',
      '__APPTYPE__'=> 'CNM',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '002',
      '__IPTAB__'=> '1',  '__VLABEL__'=> 'Status',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_SOLID',
      '__NPARAMS__'=> '2',    '__PARAMS__'=> '[-host;Host;;2]:[-lapse;Lapse;300;0]',

      '__ESP__'=>'MAP(0)(1,0,0,0,0)|MAP(1)(0,1,0,0,0)|MAP(2)(0,0,1,0,0)|MAP(3)(0,0,0,1,0)|MAP(4)(0,0,0,0,1)',
      '__ITEMS__'=>'OK(0)|Login(1)|Connect(2)|Credentials(3)|Config(4)',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $cnm_internal_core_metrics_001::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '0',
      '__MYRANGE__'=>'',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $cnm_internal_core_metrics_001::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '300', '__SCRIPT__' => $cnm_internal_core_metrics_001::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrca interna de CNM que reporta el estado de la conectividad con el buzon INBOX antes de su descarga por core-imap.',
      },

   },


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%cnm_internal_core_metrics_001::APPS = (

);



1;
__END__
