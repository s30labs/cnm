package cnm_app_api_device;

#/opt/cnm/designer/gconf-proxy -m cnm_app_api_device -p api-device
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS @APPS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$cnm_app_api_device::CFG = 1;
$cnm_app_api_device::SCRIPT_NAME = 'cnm_app_api_device.pl';

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
%cnm_app_api_device::SCRIPT = (

	'__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $cnm_app_api_device::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 3600,

   # ----------------------------
   '__SCRIPT_PARAMS__' => {

      'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-ip', '__PARAM_DESCR__' => 'Direccion IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },

      'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-id', '__PARAM_DESCR__' => 'ID', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
      'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-name', '__PARAM_DESCR__' => 'Nombre', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
      'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-domain', '__PARAM_DESCR__' => 'Dominio', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
      'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-type', '__PARAM_DESCR__' => 'Tipo', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
      'p06' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-status', '__PARAM_DESCR__' => 'Estado', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
      'p07' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-geo', '__PARAM_DESCR__' => 'Geolocalizacion', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
      'p08' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-critic', '__PARAM_DESCR__' => 'Criticidad', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
      'p09' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-correlated', '__PARAM_DESCR__' => 'ID del correlador', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
      'p10' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-profile', '__PARAM_DESCR__' => 'Perfil', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
      'p11' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-user', '__PARAM_DESCR__' => 'Campos de usuario', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },

      },

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este escript permite modificar campos de los dispositivos definidos en CNM mediante el API. Sus parámetros de ejecución son:<b
cnm@cnm:/opt/cnm/xagent/base# ./cnm_app_api_device.pl -h
cnm_app_api_device.pl 1.0

cnm_app_api_device.pl [-d] [-cid default] -ip=1.1.1.1 -status 0 -domain nuevo.com
cnm_app_api_device.pl [-d] [-cid default] -id=1 -status 0 -domain nuevo.com
cnm_app_api_device.pl -h  : Ayuda

id:          Id del dispositivo cuyo campo/campos se van a actualizar.
ip:          IP del dispositivo cuyo campo/campos se van a actualizar.
name:        Nombre del dispositivo
domain:      Dominio del dispositivo
type:        Tipo del dispositivo
geo:         Coordenadas de Geolocalizacion del dispositivo
critic:      Criticidad del dispositivo
correlated:  ID del dispositivo del que depende
status:      Estado del dispositivo (0:activo | 1:inactivo | 2:mantenimiento)
profile:     Perfil al que pertenece el dispositivo
user:        Permite especificar valores para campos de usuario. P. ej: Precio=1000,Proveedor=s30labs
',
		'__ID_REF__' => $cnm_app_api_device::SCRIPT_NAME
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
@cnm_app_api_device::METRICS = (

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
@cnm_app_api_device::APPS = (

   #------------------------------------------------------------------------
   {
      '__SUBTYPE__'=> 'CNM-Admin', '__ANAME__'=> 'app_cnm_dev_baja',
      '__NAME__'=> 'DAR DE BAJA DISPOSITIVO',
      '__DESCR__'=> '',
		'__CMD__'=> '',
		'__IPTAB__'=> '1', '__READY__'=> '1',
		'__MYRANGE__'=> 'cnm', '__CFG__'=> '0', '__PLATFORM__'=> '*',
		'__SCRIPT__'=> $cnm_app_api_device::SCRIPT_NAME,
		'__FORMAT__'=> '1', 
      '__RES__'=> '1', '__IPPARAM__'=> '', '__APPTYPE__'=> 'CNM',  '__ITIL_TYPE__'=> '1',  
		'__MYRANGE__'=>'', # Mejor que no se asocie. Que se haga desde rama de logs

      # ----------------------------
      '__APP_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p06' => { '__ENABLE__' => '1', '__VALUE__' => '1', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p07' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p08' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p09' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p10' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p11' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },

      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Permite dar de baja un dispositivo',
      },

   },

   #------------------------------------------------------------------------
   {
      '__SUBTYPE__'=> 'CNM-Admin', '__ANAME__'=> 'app_cnm_dev_alta',
      '__NAME__'=> 'ACTIVAR DISPOSITIVO',
      '__DESCR__'=> '',
      '__CMD__'=> '',
      '__IPTAB__'=> '1', '__READY__'=> '1',
      '__MYRANGE__'=> 'cnm', '__CFG__'=> '0', '__PLATFORM__'=> '*',
      '__SCRIPT__'=> $cnm_app_api_device::SCRIPT_NAME,
      '__FORMAT__'=> '1',
      '__RES__'=> '1', '__IPPARAM__'=> '', '__APPTYPE__'=> 'CNM',  '__ITIL_TYPE__'=> '1',
      '__MYRANGE__'=>'', # Mejor que no se asocie. Que se haga desde rama de logs

      # ----------------------------
      '__APP_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p06' => { '__ENABLE__' => '1', '__VALUE__' => '0', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p07' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p08' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p09' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p10' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p11' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },

      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Permite activar un dispositivo',
      },

   },


   #------------------------------------------------------------------------
   {
      '__SUBTYPE__'=> 'CNM-Admin', '__ANAME__'=> 'app_cnm_dev_mant',
      '__NAME__'=> 'PONER EN MANTENIMIENTO DISPOSITIVO',
      '__DESCR__'=> '',
      '__CMD__'=> '',
      '__IPTAB__'=> '1', '__READY__'=> '1',
      '__MYRANGE__'=> 'cnm', '__CFG__'=> '0', '__PLATFORM__'=> '*',
      '__SCRIPT__'=> $cnm_app_api_device::SCRIPT_NAME,
      '__FORMAT__'=> '1',
      '__RES__'=> '1', '__IPPARAM__'=> '', '__APPTYPE__'=> 'CNM',  '__ITIL_TYPE__'=> '1',
      '__MYRANGE__'=>'', # Mejor que no se asocie. Que se haga desde rama de logs

      # ----------------------------
      '__APP_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p06' => { '__ENABLE__' => '1', '__VALUE__' => '2', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p07' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p08' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p09' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p10' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },
         'p11' => { '__ENABLE__' => '0', '__VALUE__' => '', '__SCRIPT__' => $cnm_app_api_device::SCRIPT_NAME },

      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Permite poner en mantenimiento un dispositivo',
      },

   },


);



1;
__END__
