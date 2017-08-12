package linux_metric_icmp_dual;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_icmp_dual::CFG = 0;
$linux_metric_icmp_dual::SCRIPT_NAME = 'linux_metric_icmp_dual.pl';

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
%linux_metric_icmp_dual::SCRIPT = (

	'__SCRIPT__' => $linux_metric_icmp_dual::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_icmp_dual::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_icmp_dual::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-s', '__PARAM_DESCR__' => 'Campo de usuario con IP2', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_icmp_dual::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script monitoriza la conectividad de dos direcciones IP diferentes. En función de los resultados obtenidos devuelve un valor numérico.
La IP principal es la del dispositivo sobre el que se aplica el script. La IP secundaria se almacena en un campo de usuario de dispositivo que tiene que definir el administrador. El nombre de dicho campo es el segundo parámetro del script, como vemos a continuación:

cnm@cnm-devel:/opt/cnm-sp/icmp-dual# xagent/base/linux_metric_icmp_dual.pl
mon_icmp_dual 1.0

Monitoriza si hay conectividad con dos direcciones IP diferentes.
Devuelve un valor numerico que representa un estado en funcion los resultados.
La tabla de decision es:

IP1   IP2   VALOR DEVUELTO
0     0     3  (No se accede ninguna de las dos)
0     1     2  (Se accede a IP2, No se accede a IP1)
1     0     1  (Se accede a IP1, No se accede a IP2)
1     1     0  (Se accede a las dos)
            4  (Desconocido)

linux_metric_icmp_dual.pl -h : Ayuda
linux_metric_icmp_dual.pl -n host -s Campo_de_Usuario_con_IP2 : Chequea servicio ICMP

-n   IP (IP1)
-s   Nombre del campo de usuario que contiene (IP2)
-h   Help
',
		'__ID_REF__' => $linux_metric_icmp_dual::SCRIPT_NAME
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
@linux_metric_icmp_dual::METRICS = (

	#------------------------------------------------------------------------
	{ 
		#defSUBTYPE=xagt_004020
		'__SUBTYPE__'=> 'xagt_004020', '__CLASS__'=> 'proxy-linux',  	
		'__DESCRIPTION__'=> 'DISPONIBILIDAD ICMP DUAL (sample)',
		'__APPTYPE__'=> 'IPSERV.BASE', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> '003', 	

      '__ESP__'=>'MAP(0)(1,0,0,0,0)|MAP(4)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(2)(0,0,0,1,0)|MAP(1)(0,0,0,0,1)',
      '__ITEMS__'=>'ip1=ip2=ok(1)|unk(4)|ip1=ip2=nok(3)|ip1=nok ip2=ok(2)|ip1=ok ip2=nok(1)',

		'__IPTAB__'=> '0', '__VLABEL__'=> '',
		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_SOLID',	
		'__NPARAMS__'=> '2', 	'__PARAMS__'=> '[-n;IP;;2]:[-s;Campo con IP2;;0]', 	
		'__PARAMS_DESCR__'=> '',
		'__SCRIPT__'=> $linux_metric_icmp_dual::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '1',
		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '1',
		'__MYRANGE__'=>'icmp_dual-check,[-n;IP;;2]:[-s;Campo con IP2;;0]',
		# ----------------------------
	   '__METRIC_PARAMS__' => {

   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_icmp_dual::SCRIPT_NAME },
   	   'p02' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_icmp_dual::SCRIPT_NAME },
      },
		# ----------------------------
	   '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que representa el estado reportado por el script linux_metric_icmp_dual.pl. Para usarla, se debe duplicar y crear una métrica de usuario donde se especifique el valor del segundo parámetro del script, que indica el nombre del campo de usuario que contiene la IP secundaria o de backup (IP2)',
   	},

      # ----------------------------
      '__MONITORS__' => {

         'm01' => { '__MONITOR__' => 's_xagt_004020-148b349b', '__CAUSE__' => 'ERROR EN ACCESO ICMP DUAL', '__EXPR__' => 'v3=1:v4=1:v5=1', '__HIDE__' => '1',  '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004020', '__SUBTYPE__' => 'xagt_004020', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "DISPONIBILIDAD ICMP DUAL" que genera una alerta de severidad ROJA no se accede ni a IP1, ni a IP2. Una alerta de severidad NARANJA cuando no se accede a IP1 pero si a IP2 y una alerta de severidad AMARILLA cuando no se accede a IP2 pero si a IP1'  },
      },


	},

   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004021
      '__SUBTYPE__'=> 'xagt_004021', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'SERVICIO ICMP DUAL (sample)',
      '__APPTYPE__'=> 'IPSERV.BASE',   '__ITIL_TYPE__'=> '1',  '__TAG__'=> '001.ip1|001.ip2',

      '__ESP__'=>'o1|o2',
      '__ITEMS__'=>'Tiempo de Respuesta IP1|Tiempo de Respuesta IP2',

      '__IPTAB__'=> '0', '__VLABEL__'=> '',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_BASE',
      '__NPARAMS__'=> '2',    '__PARAMS__'=> '[-n;IP;;2]:[-s;Campo con IP2;;0]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_icmp_dual::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'icmp_dual-check,[-n;IP;;2]:[-s;Campo con IP2;;0]',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_icmp_dual::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_icmp_dual::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que representa la latencia reportada por el script linux_metric_icmp_dual.pl de dos interfaces distintos asociados a un equipo. Para usarla, se debe duplicar y crear una métrica de usuario donde se especifique el valor del segundo parámetro del script, que indica el nombre del campo de usuarioque contiene la IP secundaria o de backup (IP2)',
      },

	},
	#------------------------------------------------------------------------

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_icmp_dual::APPS = (


);



1;
__END__
