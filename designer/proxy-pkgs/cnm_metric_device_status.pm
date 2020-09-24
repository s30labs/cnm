package cnm_metric_device_status;
# /opt/cnm/designer/gconf-proxy -m cnm_metric_device_status -p cnm-metric-device-status
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$cnm_metric_device_status::CFG = 0;
$cnm_metric_device_status::SCRIPT_NAME = 'cnm_metric_device_status.pl';

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
%cnm_metric_device_status::SCRIPT = (

	'__SCRIPT__' => $cnm_metric_device_status::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $cnm_metric_device_status::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-id', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $cnm_metric_device_status::SCRIPT_NAME },

		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener el estado de un dispositivo en CNM. Los estado posibles son: Activo(0), Baja(1) o Mantenimiento(2).

cnm_metric_device_status.pl [-v] [-id id_dev|name|ip]
cnm_metric_device_status.pl -h  : Ayuda

Donde -id puede ser id_dev, ip o host_name (name+domain)
',
		'__ID_REF__' => $cnm_metric_device_status::SCRIPT_NAME
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
@cnm_metric_device_status::METRICS = (

   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_002000
      '__SUBTYPE__'=> 'xagt_002000', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'MONITORIZACION DEL DISPOSITIVO',
      '__APPTYPE__'=> 'CNM',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '001',
      '__IPTAB__'=> '1',  '__VLABEL__'=> 'Status',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_SOLID',
      '__NPARAMS__'=> '1',    '__PARAMS__'=> '[-id;IP;;2]',

      '__ESP__'=>'MAP(0)(1,0,0,0)|MAP(2)(0,1,0,0)|MAP(1)(0,0,1,0)|MAP(3)(0,0,0,1)',
      '__ITEMS__'=>'Active(0)|Maintenance(2)|Inactive(1)|Unknown(3)',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $cnm_metric_device_status::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '0',
      '__MYRANGE__'=>'',


      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $cnm_metric_device_status::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitorizaestado del puerto 80/TCP. Puede tener tres valores: Ok(1), Unknown(2) y Nok(3).',
      },

   },



);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%cnm_metric_device_status::APPS = (

);



1;
__END__
