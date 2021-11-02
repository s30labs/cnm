package cnm_app_api_inventory;

#/opt/cnm/designer/gconf-proxy -m cnm_app_api_inventory -p api-inventory
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS @APPS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$cnm_app_api_inventory::CFG = 1;
$cnm_app_api_inventory::SCRIPT_NAME = 'cnm_app_api_inventory.pl';

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
%cnm_app_api_inventory::SCRIPT = (

	'__SCRIPT__' => $cnm_app_api_inventory::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $cnm_app_api_inventory::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 3600,

   # ----------------------------
   '__SCRIPT_PARAMS__' => {

      'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-host', '__PARAM_DESCR__' => 'CNM Host', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_inventory::SCRIPT_NAME },
      'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-what', '__PARAM_DESCR__' => 'Tipo de Inventario', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_inventory::SCRIPT_NAME },
      'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-extra', '__PARAM_DESCR__' => 'Parametros extra', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_inventory::SCRIPT_NAME },


      },

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este escript permite obtener datos del CNM mediante el API. Sus parámetros de ejecución son:<b
cnm@cnm:/opt/cnm/xagent/base# ./cnm_app_api_inventory.pl -h
cnm_app_api_inventory.pl 1.0

cnm_app_api_inventory.pl [-d] [-cid default] [-host 1.1.1.1] -what [devices|views|metrics|metrics_in_views]
cnm_app_api_inventory.pl -h  : Ayuda

host:  Direccion IP del CNM al que se interroga, por defecto es localhost.
what:  Tipo de inventario: devices, views, metrics, metrics_in_views
extra: Parametros extra (opcional)
',
		'__ID_REF__' => $cnm_app_api_inventory::SCRIPT_NAME
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
@cnm_app_api_inventory::METRICS = (

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
@cnm_app_api_inventory::APPS = (

   #------------------------------------------------------------------------
   {
      '__SUBTYPE__'=> 'CNM-Admin', '__ANAME__'=> 'app_cnm_csv_devices',
      '__NAME__'=> 'INVENTARIO DE DISPOSITIVOS',
      '__DESCR__'=> '',
		'__CMD__'=> '',
		'__IPTAB__'=> '0', '__READY__'=> '1',
		'__MYRANGE__'=> 'cnm', '__CFG__'=> '0', '__PLATFORM__'=> '*',
		'__SCRIPT__'=> $cnm_app_api_inventory::SCRIPT_NAME,
		'__FORMAT__'=> '1', 
      '__RES__'=> '1', '__IPPARAM__'=> '', '__APPTYPE__'=> 'CNM',  '__ITIL_TYPE__'=> '1',  
		'__MYRANGE__'=>'', # Mejor que no se asocie. Que se haga desde rama de logs

      # ----------------------------
      '__APP_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => 'localhost', '__SCRIPT__' => $cnm_app_api_inventory::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => 'devices', '__SCRIPT__' => $cnm_app_api_inventory::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_inventory::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Obtiene el inventario de los dispositivos dados de alta en el sistema.',
      },

   },


   #------------------------------------------------------------------------
   {
      '__SUBTYPE__'=> 'CNM-Admin', '__ANAME__'=> 'app_cnm_csv_metrics',
      '__NAME__'=> 'INVENTARIO DE METRICAS',
      '__DESCR__'=> '',
      '__CMD__'=> '',
      '__IPTAB__'=> '0', '__READY__'=> '1',
      '__MYRANGE__'=> 'cnm', '__CFG__'=> '0', '__PLATFORM__'=> '*',
      '__SCRIPT__'=> $cnm_app_api_inventory::SCRIPT_NAME,
      '__FORMAT__'=> '1',
      '__RES__'=> '1', '__IPPARAM__'=> '', '__APPTYPE__'=> 'CNM',  '__ITIL_TYPE__'=> '1',
      '__MYRANGE__'=>'', # Mejor que no se asocie. Que se haga desde rama de logs

      # ----------------------------
      '__APP_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => 'localhost', '__SCRIPT__' => $cnm_app_api_inventory::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => 'metrics', '__SCRIPT__' => $cnm_app_api_inventory::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_inventory::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Obtiene el inventario de las metricas definidas en el sistema.',
      },

   },


   #------------------------------------------------------------------------
   {
      '__SUBTYPE__'=> 'CNM-Admin', '__ANAME__'=> 'app_cnm_csv_views',
      '__NAME__'=> 'INVENTARIO DE VISTAS',
      '__DESCR__'=> '',
      '__CMD__'=> '',
      '__IPTAB__'=> '0', '__READY__'=> '1',
      '__MYRANGE__'=> 'cnm', '__CFG__'=> '0', '__PLATFORM__'=> '*',
      '__SCRIPT__'=> $cnm_app_api_inventory::SCRIPT_NAME,
      '__FORMAT__'=> '1',
      '__RES__'=> '1', '__IPPARAM__'=> '', '__APPTYPE__'=> 'CNM',  '__ITIL_TYPE__'=> '1',
      '__MYRANGE__'=>'', # Mejor que no se asocie. Que se haga desde rama de logs

      # ----------------------------
      '__APP_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => 'localhost', '__SCRIPT__' => $cnm_app_api_inventory::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => 'views', '__SCRIPT__' => $cnm_app_api_inventory::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_inventory::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Obtiene el inventario de las metricas definidas en el sistema.',
      },

   },


#Falta:
#'name'=>'INVENTARIO DE METRICAS DEFINIDAS EN VISTAS'
#'aname'=> 'app_cnm_csv_view_metrics'

);



1;
__END__
