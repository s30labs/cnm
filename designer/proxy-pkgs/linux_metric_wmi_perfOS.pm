package linux_metric_wmi_perfOS;

#---------------------------------------------------------------------------
# /opt/cnm/designer/gconf-proxy -m linux_metric_wmi_perfOS -p wmi-perfOS

use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_wmi_perfOS::CFG = 0;
$linux_metric_wmi_perfOS::SCRIPT_NAME = 'linux_metric_wmi_perfOS.pl';

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
%linux_metric_wmi_perfOS::SCRIPT = (

	'__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_wmi_perfOS::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-u', '__PARAM_DESCR__' => 'User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Clave', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener valores de performance de un equipo con SO Windows a partir de diferentes clases WMI (Win32_PerfFormattedData_PerfOS_Cache, Win32_PerfFormattedData_PerfOS_Memory, Win32_PerfFormattedData_PerfOS_Processor, Win32_PerfFormattedData_PerfOS_PagingFile o Win32_PerfFormattedData_PerfOS_System).Sus parámetros de ejecución son:
root@cnm-devel:/opt/cnm/xagent/base# ./linux_metric_wmi_perfOS.pl -h
linux_metric_wmi_perfOS.pl 1.0

linux_metric_wmi_perfOS.pl -n IP -u user -p pwd [-d domain]
linux_metric_wmi_perfOS.pl -n IP -u domain/user -p pwd
linux_metric_wmi_perfOS.pl -h  : Ayuda

-n    IP remota
-u    user
-p    pwd
-d    Dominio
',
		'__ID_REF__' => $linux_metric_wmi_perfOS::SCRIPT_NAME
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
@linux_metric_wmi_perfOS::METRICS = (

	#------------------------------------------------------------------------
	{ 
		#defSUBTYPE=xagt_004500
		'__SUBTYPE__'=> 'xagt_004500', '__CLASS__'=> 'proxy-linux',  	
		'__DESCRIPTION__'=> 'WMI - PROCESOS',
		'__APPTYPE__'=> 'SO.WINDOWS', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> 'Processes', 	'__ESP__'=> 'o1',
		'__IPTAB__'=> '1', '__ITEMS__'=> 'Processes', 	'__VLABEL__'=> 'Num',
		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_AREA',	
		'__NPARAMS__'=> '3', 	'__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]', 	
		'__PARAMS_DESCR__'=> '',
		'__SCRIPT__'=> $linux_metric_wmi_perfOS::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '1',
		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '1',
		'__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

		# ----------------------------
	   '__METRIC_PARAMS__' => {

   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
   	   'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
   	   'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
      },
		# ----------------------------
	   '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el número de procesos corriendo en un equipo a partir del atributo <strong>Processes</strong> de la clase WMI <strong>Win32_PerfFormattedData_PerfOS_System</strong>.
Es válida para sistemas Windows.',
   	},


      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux'  },
#      },


	},


	#------------------------------------------------------------------------
   {
		#defSUBTYPE=xagt_004501
      '__SUBTYPE__'=> 'xagt_004501', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - THREADS',
      '__APPTYPE__'=> 'SO.WINDOWS',  '__ITIL_TYPE__'=> '1',  '__TAG__'=> 'Threads',   '__ESP__'=> 'o1',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'Threads',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_perfOS::SCRIPT_NAME,    '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
		'__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el número de threads arrancados en un equipo a partir del atributo <strong>Threads</strong> de la clase WMI <strong>Win32_PerfFormattedData_PerfOS_System</strong>.
Es válida para sistemas Windows.',
		}
   },

   #------------------------------------------------------------------------
   {
		#defSUBTYPE=xagt_004502
      '__SUBTYPE__'=> 'xagt_004502', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - LLAMADAS AL SO',
      '__APPTYPE__'=> 'SO.WINDOWS',  '__ITIL_TYPE__'=> '1',  '__TAG__'=> 'SystemCallsPersec',   '__ESP__'=> 'o1',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'SystemCallsPersec',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_perfOS::SCRIPT_NAME,    '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
		'__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el número de llamadas al sistema operativo a partir del atributo <strong>SystemCallsPersec<strong> de la clase WMI <strong>Win32_PerfFormattedData_PerfOS_System<strong>.
Es válida para sistemas Windows.',
		}
   },

   #------------------------------------------------------------------------
   {
		#defSUBTYPE=xagt_004503
      '__SUBTYPE__'=> 'xagt_004503', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - CAMBIOS DE CONTEXTO',
      '__APPTYPE__'=> 'SO.WINDOWS',  '__ITIL_TYPE__'=> '1',  '__TAG__'=> 'ContextSwitchesPersec',   '__ESP__'=> 'o1',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'ContextSwitchesPersec',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_perfOS::SCRIPT_NAME,    '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
		'__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el número de cambios de contexto producidos en el sistema operativo a partir del atributo <strong>ContextSwitchesPersec</strong> de la clase WMI <strong>Win32_PerfFormattedData_PerfOS_System</strong>.
Es válida para sistemas Windows.',
		}
   },

   #------------------------------------------------------------------------
   {
		#defSUBTYPE=xagt_004504
      '__SUBTYPE__'=> 'xagt_004504', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - COLA DE PROCESO',
      '__APPTYPE__'=> 'SO.WINDOWS',  '__ITIL_TYPE__'=> '1',  '__TAG__'=> 'ProcessorQueueLength',   '__ESP__'=> 'o1',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'ProcessorQueueLength',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_perfOS::SCRIPT_NAME,    '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
		'__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza la longitud de la cola de procesos del sistema operativo a partir del atributo <strong>ProcessorQueueLength</strong> de la clase WMI <strong>Win32_PerfFormattedData_PerfOS_System</strong>.
Es válida para sistemas Windows.',
      }
   },

   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004505
      '__SUBTYPE__'=> 'xagt_004505', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - USO DE CPU',
      '__APPTYPE__'=> 'SO.WINDOWS',  '__ITIL_TYPE__'=> '1',  '__TAG__'=> 'PercentProcessorTime',   '__ESP__'=> 'o1',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'PercentProcessorTime',   '__VLABEL__'=> 'Perc',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_perfOS::SCRIPT_NAME,    '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriz e�l porcentaje de tiempo en que el procesador esta ejecutando un hilo. Es un indicador de la actividad del procesador. Se obtiene a partir del atributo <strong>PercentProcessorTime</strong> de la clase WMI <strong>Win32_PerfFormattedData_PerfOS_System</strong>.
Es válida para sistemas Windows.',
      }
   },

#Percentage of time that the processor is executing a non-idle thread. This property was designed as a primary indicator of processor activity. It is calculated by measuring the time that the processor spends executing the thread of the idle process in each sample interval and subtracting that value from 100%. Each processor has an idle thread which consumes cycles when no other threads are ready to run. It can be viewed as the percentage of the sample interval spent doing useful work. This property displays the average percentage of busy time observed during the sample interval. It is calculated by monitoring the time the service was inactive, and then subtracing that value from 100%.

   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004506
      '__SUBTYPE__'=> 'xagt_004506', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - PAGINACION DE MEMORIA',
      '__APPTYPE__'=> 'SO.WINDOWS',  '__ITIL_TYPE__'=> '1',  '__TAG__'=> 'PagesPersec|PageFaultsPersec',   '__ESP__'=> 'o1|o2',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'PagesPersec|PageFaultsPersec',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_perfOS::SCRIPT_NAME,    '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Pages/sec is the rate at which pages are read from or written to disk to resolve hard page faults. This counter is a primary indicator of the kinds of faults that cause system-wide delays and Page Faults/sec is the average number of pages faulted per second. It is measured in number of pages faulted per second because only one page is faulted in each fault operation, hence this is also equal to the number of page fault operations. Captured from <strong>PagesPersec, PageFaultsPersec</strong> counters of the WMI class<strong>Win32_PerfFormattedData_PerfOS_System</strong>.
This metric is valid only on Windows Systems.',
      }
   },

   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004508
      '__SUBTYPE__'=> 'xagt_004508', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - USO DE MEMORIA',
      '__APPTYPE__'=> 'SO.WINDOWS',  '__ITIL_TYPE__'=> '1',  '__TAG__'=> 'TotalPhysicalMemory|AvailableBytes',   '__ESP__'=> 'o1|o2',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'TotalPhysicalMemory (Bytes)|AvailableBytes (Bytes)',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '3',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_perfOS::SCRIPT_NAME,    '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_perfOS::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'AvailableBytes is the amount of physical memory, in bytes, immediately available for allocation to a process or for system use. It is equal to the sum of memory assigned to the standby (cached), free and zero page lists, is captured from <strong>AvailableBytes</strong> counters of the WMI class <strong>Win32_PerfFormattedData_PerfOS_Memory</strong>. MemoryCapacity is the physical memory size in bytes is captured from <strong>AvailableBytes</strong> counters of the WMI class <strong>Win32_PhysicalMemory</strong>.
This metric is valid only on Windows Systems.',
      }
   },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_wmi_perfOS::APPS = (

);



1;
__END__
