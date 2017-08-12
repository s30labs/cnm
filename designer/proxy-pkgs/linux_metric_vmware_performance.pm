package linux_metric_vmware_performance;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#http://www.vmware.com/support/developer/vc-sdk/visdk400pubs/ReferenceGuide/vim.PerformanceManager.html
#---------------------------------------------------------------------------
# 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_vmware_performance::CFG = 0;
$linux_metric_vmware_performance::SCRIPT_NAME = 'linux_metric_vmware_performance.pl';

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
%linux_metric_vmware_performance::SCRIPT = (

	'__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_vmware_performance::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 90,

	# ----------------------------
	# Tipos: 0->Normal, 1->Sec, 2->IP
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-u', '__PARAM_DESCR__' => 'User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Clave', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
		'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-P', '__PARAM_DESCR__' => 'Port', '__PARAM_VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
		'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-H', '__PARAM_DESCR__' => 'Host', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener los valores de los contadores de Performance proporcionados por el API de vsSphere. El significado de sus parámetros es:
cnm@cnm:/opt/cnm/xagent/base# ./linux_metric_vmware_performance.pl -h
linux_metric_vmware_performance.pl 1.0

linux_metric_vmware_performance.pl -n IP -u user -p pwd [-H host_ame] [-P port]
linux_metric_vmware_performance.pl -h  : Ayuda

-n    IP remota (server)
-u    user
-p    pwd
-P    port      (Optional. Defaults 443)
-H    Host Name (Optional)
-s    Number of samples (Optional. Defaults 15)
-h    Ayuda

linux_metric_vmware_performance.pl -n 1.1.1.1 -u user -p xxx
linux_metric_vmware_performance.pl -n 1.1.1.1 -u user -p xxx -H myhost
linux_metric_vmware_performance.pl -n 1.1.1.1 -u user -p xxx -H myhost -P 4443
',
		'__ID_REF__' => $linux_metric_vmware_performance::SCRIPT_NAME
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
@linux_metric_vmware_performance::METRICS = (


	#------------------------------------------------------------------------
	# SIN INSTANCIAS
	{ 
		#defSUBTYPE=xagt_004520
		'__SUBTYPE__'=> 'xagt_004520', '__CLASS__'=> 'proxy-linux',  	
		'__DESCRIPTION__'=> 'VMWARE - USO DE CPU',
		'__APPTYPE__'=> 'VIRTUAL.VMWARE', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> '101',
		'__IPTAB__'=> '1', 	'__VLABEL__'=> 'Num',
		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_AREA',	
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]:[-H;Host;;0]',
      '__ESP__'=>'o1',
      '__ITEMS__'=>'Uso (%)',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

#<100> cpu - Usage in MHz: 46.400
#<101> cpu - Usage: 1.56

#CPU Usage
#CPU usage as a percentage during the interval. 
#◦VM - Amount of actively used virtual CPU, as a percentage of total available CPU. This is the host's view of the CPU usage, not the guest operating system view. It is the average CPU utilization over all available virtual CPUs in the virtual machine. For example, if a virtual machine with one virtual CPU is running on a host that has four physical CPUs and the CPU usage is 100%, the virtual machine is using one physical CPU completely. 
#
#virtual CPU usage = usagemhz / (# of virtual CPUs x core frequency) 
#
#
#◦Host - Actively used CPU of the host, as a percentage of the total available CPU. Active CPU is approximately equal to the ratio of the used CPU to the available CPU. 
#
#available CPU = # of physical CPUs x clock rate 
#
#100% represents all CPUs on the host. For example, if a four-CPU host is running a virtual machine with two CPUs, and the usage is 50%, the host is using two CPUs completely. 
#
#
#◦Cluster - Sum of actively used CPU of all virtual machines in the cluster, as a percentage of the total available CPU. 
#
#CPU Usage = CPU usagemhz / effectivecpu 


	
		'__PARAMS_DESCR__'=> '',
		'__SCRIPT__'=> $linux_metric_vmware_performance::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '1',
		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '1',
		# ----------------------------
	   '__METRIC_PARAMS__' => {

   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
   	   'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
   	   'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
   	   'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
   	   'p05' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
      },
		# ----------------------------
	   '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el porcentaje de uso de CPU en un host ESX/ESXi a partir del API de vSphere. Es una relación entre la CPU usada y la disponible. (CPU disponible = Num. CPUs x frec. de reloj).
El 100% representa todas las CPUs del Host. Si por ejemplo un Host con cuatro CPUs físicas tiene arrancada una máquina virtual con dos CPUs y este valor está al 50% significa que el host está usando las dos CPUs totalmente.',
   	},

      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux'  },
#      },

	},

   {
      #defSUBTYPE=xagt_004521
      '__SUBTYPE__'=> 'xagt_004521', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - USO DETALLADO DE MEMORIA',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',  '__ITIL_TYPE__'=> '1',  '__TAG__'=> '201|202|203|204|205',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'KB',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]:[-H;Host;;0]',
      '__ESP__'=>'o1|o2|o3|o4|o5',
      '__ITEMS__'=>'Consumed (kB)|Overhead (kB)|Shared (kB)|Swap used (kB)|Balloon (kB)',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

#<201> mem - Consumed = 2546342.133
#<202> mem - Overhead = 269213.333
#<203> mem - Shared = 3636.000
#<204> mem - Swap used = 0.000
#<205> mem - Balloon = 0.000
#<206> mem - State = 0.000

#http://www.vmware.com/support/developer/vc-sdk/
#http://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.wssdk.apiref.doc_50%2Fvim.PerformanceManager.html
#
#1.Consumed (Amount of memory consumed by a virtual machine, host, or cluster. )
#---------------------------------------------------------------------------------------
#(kB)
#
#◦Virtual machine:   Amount of guest physical memory consumed by the virtual machine for guest memory. Consumed memory does not include overhead memory. It includes shared memory and memory that might be reserved, but not actually used. Use this metric for charge-back purposes. 
#
#vm consumed memory = memory granted - memory saved due to memory sharing 
#
#
#◦Host:   Amount of machine memory used on the host. 
#        Consumed memory includes Includes memory used by the Service Console, the VMkernel, vSphere services, plus the total consumed metrics for all running virtual machines. 
#
#host consumed memory = total host memory - free host memory 
#
#

#◦Cluster:   Amount of host machine memory used by all powered on virtual machines in the cluster. A cluster's consumed memory consists of virtual machine consumed memory and overhead memory. It does not include host-specific overhead memory, such as memory used by the service console or VMkernel.
#
#
#
#2. Overhead  (Amount of machine memory allocated to a virtual machine beyond its reserved amount. )
#---------------------------------------------------------------------------------------
#(kB)
#
#◦Virtual machine:   Amount of machine memory used by the VMkernel to run the virtual machine. 
#
#◦Host:   Total of all overhead metrics for powered-on virtual machines, plus the overhead of running vSphere services on the host.
#
#
#
#3. Usage (Memory usage as percentage of total configured or available memory, expressed as a hundredth of a percent (1 = 0.01%). A value between 0 and 10,000. )
#---------------------------------------------------------------------------------------
#(%)
#
#◦Virtual machine:   Percentage of configured virtual machine “physical” memory:
#active ÷ virtual machine configured size 
#◦Host:   Percentage of available machine memory:
#consumed ÷ machine-memory-size 
#◦Cluster:  memory usage = memory consumed + memory overhead ÷ effectivemem
#
#
#4.Swapped
#---------------------------------------------------------------------------------------
#(kB)
#
##
#
#5. Balloon (vmmemctl) Amount of memory allocated by the virtual machine memory control driver (vmmemctl), which is installed with VMware Tools. It is a VMware exclusive memory-management driver that controls ballooning. 
#---------------------------------------------------------------------------------------
#(kB)
#
#
#◦Virtual machine:   Amount of guest physical memory that is currently reclaimed from the virtual machine through ballooning. This is the amount of guest physical memory that has been allocated and pinned by the balloon driver. 
#◦Host:   The sum of all vmmemctl values for all powered-on virtual machines, plus vSphere services on the host. If the balloon target value is greater than the balloon value, the VMkernel inflates the balloon, causing more virtual machine memory to be reclaimed. If the balloon target value is less than the balloon value, the VMkernel deflates the balloon, which allows the virtual machine to consume additional memory if needed. 
#Virtual machines initiate memory reallocation. Therefore, it is possible to have a balloon target value of 0 and balloon value greater than 0
#
#
#Current amount of guest physical memory swapped out to the virtual machine's swap file by the VMkernel. Swapped memory stays on disk until the virtual machine needs it. This statistic refers to VMkernel swapping and not to guest OS swapping. 
#
#
#6. Shared (Amount of guest memory that is shared with other virtual machines, relative to a single virtual machine or to all powered-on virtual machines on a host. )
#---------------------------------------------------------------------------------------
#(kB)
#
#
#◦Virtual machine:   Amount of guest “physical” memory shared with other virtual machines (through the VMkernel’s transparent page-sharing mechanism, a RAM de-duplication technique). Includes amount of zero memory area. 
#◦Host:   Sum of all shared metrics for all powered-on virtual machines, plus amount for vSphere services on the host. The host's shared memory may be larger than the amount of machine memory if memory is overcommitted (the aggregate virtual machine configured memory is much greater than machine memory). The value of this statistic reflects how effective transparent page sharing and memory overcommitment are for saving machine memory. 
#
#
#



      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_performance::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el uso detallado de la memoria de un host ESX/ESXi a partir del API de vSphere.
Se obtienen los siguientes valores:
1. Consumida: Cantidad de memoria consumida por una máquina virtual. En el caso del Host incluye la memoria del servicio de consola, de los servicios de vSphere junto con las de todas las maquinas virtuales en ejecución.
2. Overhead: Es la memoria asignada a una máquina virtual por encima de la que tiene reservada. En el caso del host incluye la memoria de todas las máquinas virtuales junto con los servicios de vSphere.
3. Shared: Memoria compartida con otras máquinas virtuales. En el caso del Host se refiere a todas las máquinas virtuales arrancadas.
4. Swap: Memoria usada para swap. En el caso del Host se refiere a todas las máquinas virtuales arrancadas.
5. Balloon: Memoria asignada por el driver de control de la memoria virtual (vmmemctl), que se instala con las herramientas
VMWare Tools y controla el ballooning.
',
      },
   },

   {
      #defSUBTYPE=xagt_004522
      '__SUBTYPE__'=> 'xagt_004522', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - ESTADO DE LA MEMORIA',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',  '__ITIL_TYPE__'=> '1',  '__TAG__'=> '206',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'KB',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]:[-H;Host;;0]',
      '__ESP__'=>'MAP(0)(1,0,0,0)|MAP(1)(0,1,0,0)|MAP(2)(0,0,1,0)|MAP(3)(0,0,0,1)',
      '__ITEMS__'=>'high(0)|soft(1)|hard(2)|low(3)',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

#<206> mem - State = 0.000

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_performance::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza los umbrales que representan el porcentaje de memoria libre en el host ESX/ESXi a partir del API de vSphere. 
Este valor determina el comportamiento en cuanto a "swapping" o "ballooning" del host.
0 = High Indica que el umbral de memoria libre es >= 6% de la memoria de la maquina menos la del servicio de consola.
1 = Soft Indica que el umbral de memoria libre es >= 4%
2 = Hard Indica que el umbral de memoria libre es >= 2%
3 = Low Indica que el umbral de memoria libre es >= 1%
High y Soft indican que hay más swapping que ballooning.
Hard y Low indica que hay más ballooning que swapping.
',
      },
      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux'  },
#      },

   },




   #------------------------------------------------------------------------
	# CON INSTANCIAS
   {
		#defSUBTYPE=xagt_004530
      '__SUBTYPE__'=> 'xagt_004530', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - USO DE DATASTORE',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '500|501|502',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'MB',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]:[-H;Host;;0]',
      '__ESP__'=>'o2|o1|o3',
      '__ITEMS__'=>'Espacio Total|Espacio Libre|Usado(%)',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

#<500.datastore1> ds - Available space (MB): 141.634
#<501.datastore1> ds - Maximum Capacity (MB): 227.750
#<502.datastore1> ds - Usage (%): 62.19

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_performance::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.user', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.pwd', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el uso de los datastores de un host VMWARE (ESX/ESXi) a partir de los datos proporcionados por el API de vSphere.',
      },

      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'SERVICIO PARADO', '__EXPR__' => 'v3=1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004510', '__SUBTYPE__' => 'xagt_004510', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - SERVICIO xxx" que genera una alerta de severidad ROJA cuando se cumple la expresión: v3=1 que equivale a Stopped(3)=1'  },
#      },

   },

   {
      #defSUBTYPE=xagt_004531
      '__SUBTYPE__'=> 'xagt_004531', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - ERRORES EN DISCO',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '300|301',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]:[-H;Host;;0]',
      '__ESP__'=>'o1|o2',
      '__ITEMS__'=>'Commands aborted|Bus resets',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

#<300.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Commands aborted = 0.000
#<301.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Bus resets = 0.000
#<302.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Queue read latency = 0.000
#<303.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Queue write latency = 0.000
#<304.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Queue command latency = 0.000
#<305.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Kernel read latency = 0.000
#<306.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Kernel write latency = 0.000
#<307.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Kernel command latency = 0.000
#<308.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Read latency = 2.267
#<309.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Write latency = 0.000
#<310.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Command latency = 0.000
#<311.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Physical device read latency = 2.267
#<312.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Physical device write latency = 0.000
#<313.t10ATA_____WDC_WD2500JS2D75NCB3__________________________WD2DWCANK8594361> disk - Physical device command latency = 0.000

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_performance::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.user', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.pwd', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza errores de IO en los accesos a los disco de un host VMWARE (ESX/ESXi) a partir de los datos proporcionados por el API de vSphere.',
      },

      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'SERVICIO PARADO', '__EXPR__' => 'v3=1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004510', '__SUBTYPE__' => 'xagt_004510', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - SERVICIO xxx" que genera una alerta de severidad ROJA cuando se cumple la expresión: v3=1 que equivale a Stopped(3)=1'  },
#      },

   },


   {
      #defSUBTYPE=xagt_004532
      '__SUBTYPE__'=> 'xagt_004532', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - LATENCIA EN DISCO',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '308|309|310',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'ms',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]:[-H;Host;;0]',
      '__ESP__'=>'o1|o2|o3',
      '__ITEMS__'=>'Read latency|Write latency|Command latency',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_performance::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.user', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.pwd', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que representa el tiempo de acceso al disco de un host VMWARE (ESX/ESXi) en milisegundos. Se obtiene a partir de los datos proporcionados por el API de vSphere.',
      },
      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'SERVICIO PARADO', '__EXPR__' => 'v3=1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004510', '__SUBTYPE__' => 'xagt_004510', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - SERVICIO xxx" que genera una alerta de severidad ROJA cuando se cumple la epresión: v3=1 que equivale a Stopped(3)=1'  },
#      },
   },

   {
      #defSUBTYPE=xagt_004533
      '__SUBTYPE__'=> 'xagt_004533', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - LATENCIA (Q) EN DISCO',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '302|303|304',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'ms',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]:[-H;Host;;0]',
      '__ESP__'=>'o1|o2|o3',
      '__ITEMS__'=>'Queue read latency|Queue write latency|Queue command latency',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_performance::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.user', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.pwd', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que representa el tiempo consumido en la cola del VMKernel durante el acceso a un disco de un host VMWARE (ESX/ESXi) en milisegundos. Se obtiene a partir de los datos proporcionados por el API de vSphere.',
      },
      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'SERVICIO PARADO', '__EXPR__' => 'v3=1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004510', '__SUBTYPE__' => 'xagt_004510', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - SERVICIO xxx" que genera una alerta de severidad ROJA cuando se cumple la epresión: v3=1 que equivale a Stopped(3)=1'  },
#      },
   },

   {
      #defSUBTYPE=xagt_004534
      '__SUBTYPE__'=> 'xagt_004534', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - LATENCIA (K) EN DISCO',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '305|306|307',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'ms',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]:[-H;Host;;0]',
      '__ESP__'=>'o1|o2|o3',
      '__ITEMS__'=>'Kernel read latency|Kernel write latency|Kernel command latency',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_performance::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.user', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.pwd', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que representa el tiempo consumido por el VMKernel al procesar los comandos SCSI en el acceso a un disco de un host VMWARE (ESX/ESXi) en milisegundos. Se obtiene a partir de los datos proporcionados por el API de vSphere.',
      },
      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'SERVICIO PARADO', '__EXPR__' => 'v3=1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004510', '__SUBTYPE__' => 'xagt_004510', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - SERVICIO xxx" que genera una alerta de severidad ROJA cuando se cumple la epresión: v3=1 que equivale a Stopped(3)=1'  },
#      },
   },

   {
      #defSUBTYPE=xagt_004535
      '__SUBTYPE__'=> 'xagt_004535', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - LATENCIA (Phys) EN DISCO',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '311|312|313',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'ms',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]:[-H;Host;;0]',
      '__ESP__'=>'o1|o2|o3',
      '__ITEMS__'=>'Physical device read latency|Physical device write latency|Physical device  command latency',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_performance::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.user', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.pwd', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que representa el tiempo consumido en el dispositivo fisico (LUN) al ejecutar comandos SCSI en el acceso a un disco de un host VMWARE (ESX/ESXi) en milisegundos. Se obtiene a partir de los datos proporcionados por el API de vSphere.',
      },
      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'SERVICIO PARADO', '__EXPR__' => 'v3=1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004510', '__SUBTYPE__' => 'xagt_004510', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - SERVICIO xxx" que genera una alerta de severidad ROJA cuando se cumple la epresión: v3=1 que equivale a Stopped(3)=1'  },
#      },
   },

#<400.vmnic0> net - Packets transmitted = 514.667
#<401.vmnic0> net - Packets received = 320.800
#<402.vmnic0> net - Broadcast transmits = 0.067
#<403.vmnic0> net - Broadcast receives = 52.600
#<404.vmnic0> net - Multicast transmits = 0.000
#<405.vmnic0> net - Multicast receives = 68.800
#<406.vmnic0> net - Packet transmit errors = 0.000
#<407.vmnic0> net - Packet receive errors = 0.000
#<408.vmnic0> net - Transmit packets dropped = 0.000
#<409.vmnic0> net - Receive packets dropped = 0.000
#<410> net - Latency = 49.867
#http://pubs.vmware.com/vsphere-50/index.jsp?topic=%2Fcom.vmware.wssdk.apiref.doc_50%2Fnetwork_counters.html

   {
      #defSUBTYPE=xagt_004536
      '__SUBTYPE__'=> 'xagt_004536', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - TRAFICO',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '400|401|402|403|404|405',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'pkts',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]:[-H;Host;;0]',
      '__ESP__'=>'o1|o2|o3|o4|o5|o6',
      '__ITEMS__'=>'Packets transmitted|Packets received|Broadcast transmits|Broadcast receives|Multicast transmits|Multicast receives',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_performance::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.user', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.pwd', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Mide en un host VMWARE (ESX/ESXi) el número de paquetes transmitidos y recibidos junto con los de tipo broadcast y multicast. Se obtiene a partir de los datos proporcionados por el API de vSphere.',
      },
      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'SERVICIO PARADO', '__EXPR__' => 'v3=1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004510', '__SUBTYPE__' => 'xagt_004510', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - SERVICIO xxx" que genera una alerta de severidad ROJA cuando se cumple la epresión: v3=1 que equivale a Stopped(3)=1'  },
#      },
   },

   {
      #defSUBTYPE=xagt_004537
      '__SUBTYPE__'=> 'xagt_004537', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - ERRORES DE RED',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '406|407|408|409',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'pkts',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]:[-H;Host;;0]',
      '__ESP__'=>'o1|o2|o3|o4',
      '__ITEMS__'=>'Packet transmit errors|Packet receive errors|Transmit packets dropped|Receive packets dropped',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_performance::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.user', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.pwd', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_performance::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Mide en un host VMWARE (ESX/ESXi) el número de paquetes descartados y con errores. Se obtiene a partir de los datos proporcionados por el API de vSphere.',
      },
      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'SERVICIO PARADO', '__EXPR__' => 'v3=1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004510', '__SUBTYPE__' => 'xagt_004510', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - SERVICIO xxx" que genera una alerta de severidad ROJA cuando se cumple la epresión: v3=1 que equivale a Stopped(3)=1'  },
#      },
   },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_vmware_performance::APPS = (

);



1;
__END__
