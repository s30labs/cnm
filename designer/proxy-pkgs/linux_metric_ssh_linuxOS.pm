package linux_metric_ssh_linuxOS;
# /opt/custom_pro/conf/gconf-proxy -m linux_metric_ssh_linuxOS -p ssh-linuxOS
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_ssh_linuxOS::CFG = 0;
$linux_metric_ssh_linuxOS::SCRIPT_NAME = 'linux_metric_ssh_linuxOS.pl';

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
%linux_metric_ssh_linuxOS::SCRIPT = (

	'__SCRIPT__' => $linux_metric_ssh_linuxOS::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_ssh_linuxOS::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxOS::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-port', '__PARAM_DESCR__' => 'Puerto', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxOS::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-user', '__PARAM_DESCR__' => 'Usuario', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxOS::SCRIPT_NAME },
		'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-pwd', '__PARAM_DESCR__' => 'Clave', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxOS::SCRIPT_NAME },
		'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-passphrase', '__PARAM_DESCR__' => 'Passphrase', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxOS::SCRIPT_NAME },
		'p06' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-key_file', '__PARAM_DESCR__' => 'Fichero de clave privada', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxOS::SCRIPT_NAME },

		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener las siguientes métricas de un equipo Linux:

<001> Zombie Process <002> Process Uptime (min) <003> System uptime <004> Files opened by process <005> Total Inodes <006> Used Inodes <007> Free Inodes <008> Used Inodes (%) <009> Load 1m <010> Load 5m <011> Load 15m <012> CPU User <013> CPU Nice <014> CPU System <015> CPU IOwait <016> CPU Irq <017> CPU SoftIrq <018> CPU Interrupts <019> CPU Context Switches <020> Processes <021> Processes Run <022> Processes Blocked <023> Rx bytes <024> Rx packets <025> Rx errs <026> Rx drop <027> Rx fifo <028> Rx frame <029> Rx compressed <030> Rx multicast <031> Tx bytes <032> Tx packets <033> Tx errs <034> Tx drop <035> Tx fifo <036> Tx frame <037> Tx compressed <038> Tx multicast <039> Rx bits <040> Tx bits <041> operstate <042> mtu <043> Total 1K-blocks <044> Used <045> Available <046> Used (%)
 
Sus parámetros de ejecución son:

 linux_metric_ssh_linuxOS.pl -n 1.1.1.1 [-port 2322]
 linux_metric_ssh_linuxOS.pl -n 1.1.1.1 -user=aaa -pwd=bbb
 linux_metric_ssh_linuxOS.pl -n 1.1.1.1 -user=aaa -key_file=/etc/ssh/id_rsa
 linux_metric_ssh_linuxOS.pl -n 1.1.1.1 -user=aaa -key_file=1
 linux_metric_ssh_linuxOS.pl -h  : Ayuda

 -n          : IP remota
 -port       : Puerto
 -user       : Usuario
 -pwd        : Clave
 -passphrase : Passphrase SSH
 -key_file   : Fichero con la clave publica (Si vale 1 indica que ua el ficheo estandar de CNM)
 -v/-verbose : Muestra informacion extra(debug)
 -h/-help    : Ayuda
 -l          : Lista las metricas que obtiene
',
		'__ID_REF__' => $linux_metric_ssh_linuxOS::SCRIPT_NAME
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
@linux_metric_ssh_linuxOS::METRICS = (

	#------------------------------------------------------------------------
	{ 
		#defSUBTYPE=xagt_004400
		'__SUBTYPE__'=> 'xagt_004400', '__CLASS__'=> 'proxy-linux',  	
		'__DESCRIPTION__'=> 'PROCESOS ZOMBIE',
		'__APPTYPE__'=> 'SO.LINUX', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> '001', 	'__ESP__'=> 'o1',
		'__IPTAB__'=> '1', '__ITEMS__'=> 'Num. Processes', 	'__VLABEL__'=> 'Num',
		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_AREA',	
		'__NPARAMS__'=> '1', 	'__PARAMS__'=> '[-n;IP;;2]', 	
		'__PARAMS_DESCR__'=> '',
		'__SCRIPT__'=> $linux_metric_ssh_linuxOS::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '1',
		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '0',
		'__MYRANGE__'=>'ssh-check,[-n;IP;;2]',

		# ----------------------------
	   '__METRIC_PARAMS__' => {

			# El resto de parametros se obtiene de la tabla credentials
   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxOS::SCRIPT_NAME },
      },
		# ----------------------------
	   '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el numero de procesos zombies en ejecucion.',
   	},

#+---------------+----------------------------------+----------------------------+-----------+--------+----------+-----------------+--------+-----------------+-------+--------------------+
#| id_alert_type | cause                            | monitor                    | expr      | params | severity | mname           | type   | subtype         | wsize | class              |
#+---------------+----------------------------------+----------------------------+-----------+--------+----------+-----------------+--------+-----------------+-------+--------------------+
#|            18 | EXCESO DE EVENTOS                | s_xagt_647cba-d30a2710     | v1>1000   | NULL   |        2 | xagt_647cba     | xagent | xagt_647cba     |     0 | proxy-linux        |


      # ----------------------------
      '__MONITORS__' => {

#         'm01' => { '__MONITOR__' => 's_xagt_647cba-0062f99a', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000',  '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - NUMERO DE EVENTOS ALMACENADOS" que genera una alerta de severidad NARANJA cuando se cumple la expresión: v1>1000 siendo v1 el número de eventos'  },
      },


	},


	#------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004401
      '__SUBTYPE__'=> 'xagt_004401', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'UPTIME DEL SISTEMA',
      '__APPTYPE__'=> 'SO.LINUX',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '003',   '__ESP__'=> 'o1',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'T (sgs)',  '__VLABEL__'=> 'T(sgs)',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '1',    '__PARAMS__'=> '[-n;IP;;2]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_ssh_linuxOS::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'ssh-check,[-n;IP;;2]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxOS::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el tiempo que lleva arrancado el equipo desde el ultimo arranque.',
      }
   },

#<008./> Used Inodes (%) - / = 8

   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004402
      '__SUBTYPE__'=> 'xagt_004402', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'INODOS USADOS EN DISCO',
      '__APPTYPE__'=> 'SO.LINUX',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '008',   '__ESP__'=> 'o1',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'Inodos usados (%)',  '__VLABEL__'=> 'Num(%)',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '1',    '__PARAMS__'=> '[-n;IP;;2]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_ssh_linuxOS::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'ssh-check,[-n;IP;;2]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxOS::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el numero de inodos utilizados en un determinado punto de montaje.',
      }
   },

   {
      #defSUBTYPE=xagt_004403
      '__SUBTYPE__'=> 'xagt_004403', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'USO DE DISCO',
      '__APPTYPE__'=> 'SO.LINUX',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '008',   '__ESP__'=> 'o1',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'Espacio usado (%)',  '__VLABEL__'=> 'Num(%)',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '1',    '__PARAMS__'=> '[-n;IP;;2]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_ssh_linuxOS::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'ssh-check,[-n;IP;;2]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxOS::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el porcentaje de espacio usado en un disco.',
      }
   },

   {
      #defSUBTYPE=xagt_004404
      '__SUBTYPE__'=> 'xagt_004404', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'TRAFICO EN INTERFAZ',
      '__APPTYPE__'=> 'SO.LINUX',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '039|040',   '__ESP__'=> 'o1|o2',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'Rx bits | Tx bits',  '__VLABEL__'=> 'bps',
      '__MODE__'=> 'COUNTER',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '1',    '__PARAMS__'=> '[-n;IP;;2]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_ssh_linuxOS::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'ssh-check,[-n;IP;;2]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_ssh_linuxOS::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el trafico en un interfaz',
      }
	}

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_ssh_linuxOS::APPS = (


);



1;
__END__
