package linux_metric_vmware_vminfo;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#http://www.vmware.com/support/developer/vc-sdk/visdk400pubs/ReferenceGuide/vim.PerformanceManager.html
#---------------------------------------------------------------------------
# 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_vmware_vminfo::CFG = 0;
$linux_metric_vmware_vminfo::SCRIPT_NAME = 'linux_metric_vmware_vminfo.pl';

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
%linux_metric_vmware_vminfo::SCRIPT = (

	'__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_vmware_vminfo::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 60,

	# ----------------------------
	# Tipos: 0->Normal, 1->Sec, 2->IP
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-u', '__PARAM_DESCR__' => 'User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Clave', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
		'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-P', '__PARAM_DESCR__' => 'Port', '__PARAM_VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },

		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener información sobre las máquinas virtuales definidas en el host ESX/ESXi a partir del API de vsSphere. Los parámetros del script son:
cnm@cnm:/opt/cnm/xagent/base# ./linux_metric_vmware_vminfo.pl -h
linux_metric_vmware_vminfo.pl 1.0

linux_metric_vmware_vminfo.pl -n IP -u user -p pwd [-P port]
linux_metric_vmware_vminfo.pl -h  : Ayuda

-n    IP remota (server)
-u    user
-p    pwd
-P    port      (Optional. Defaults 443)
-h    Ayuda

linux_metric_vmware_vminfo.pl -n 1.1.1.1 -u user -p xxx
linux_metric_vmware_vminfo.pl -n 1.1.1.1 -u user -p xxx -P 4443
',
		'__ID_REF__' => $linux_metric_vmware_vminfo::SCRIPT_NAME
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
@linux_metric_vmware_vminfo::METRICS = (

#<100.CNM-DEVEL> powerState = poweredOff
#<101.CNM-DEVEL> connectionState = connected

   #------------------------------------------------------------------------
   # SIN INSTANCIAS
   {
      #defSUBTYPE=xagt_00453f
      '__SUBTYPE__'=> 'xagt_00453f', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - ESTADO DE LA ALIMENTACION DE LAS VMs',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',   '__ITIL_TYPE__'=> '1',  '__TAG__'=> '101|102|103',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]',
      '__ESP__'=>'o1|o2|o3',
      '__ITEMS__'=>'powerOnSummary|suspendedSummary|poweredOffSummary',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_vminfo::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Proporciona el número de máquinas del host ESX/ESXi en estado poweredOn, suspended o poweredOff a partir del API de vSphere.',
      },
	},

   {
      #defSUBTYPE=xagt_00453e
      '__SUBTYPE__'=> 'xagt_00453e', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - ESTADO DE LA CONEXION DE LAS VMs',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',   '__ITIL_TYPE__'=> '1',  '__TAG__'=> '105|106|107',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]',
      '__ESP__'=>'o1|o2|o3',
      '__ITEMS__'=>'connectedSummary|disconnectedSummary|notRespondingSummary',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_vminfo::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Proporciona el número de máquinas del host ESX/ESXi en estado connected, disconnected o notResponding a partir del API de vSphere.',
      },
   },


   #------------------------------------------------------------------------
	# CON INSTANCIAS
   {
		#defSUBTYPE=xagt_004540
      '__SUBTYPE__'=> 'xagt_004540', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - ESTADO (ENERGIA) DE VM',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '100',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_SOLID',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]',
      '__ESP__'=>'MAP(1)(1,0,0)|MAP(2)(0,1,0)|MAP(3)(0,0,1)',
      '__ITEMS__'=>'poweredOn(1)|suspended(2)|poweredOff(3)',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_vminfo::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.user', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.pwd', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el estdo de la alimentación de una máquina virtual de un host ESX/ESXi a partir de los datos proporcionados por el API de vSphere.',
      },

      # ----------------------------
      '__MONITORS__' => {
         'm01' => { '__MONITOR__' => 's_xagt_004540-a6ab545a', '__CAUSE__' => 'MAQUINA VIRTUAL PARADA', '__EXPR__' => 'v1=0', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004540', '__SUBTYPE__' => 'xagt_004540', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "VMWARE - ESTADO DE VM xxx" que genera una alerta de severidad ROJA cuando se cumple la expresión: v1=0 que indica que la máquina no está en estado de poweredOn'  },
      },
   },

   # CON INSTANCIAS
   {
      #defSUBTYPE=xagt_004541
      '__SUBTYPE__'=> 'xagt_004541', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - ESTADO (CONEX) DE VM',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '104',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_SOLID',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]',
      '__ESP__'=>'MAP(1)(1,0,0)|MAP(2)(0,1,0)|MAP(3)(0,0,1)',
      '__ITEMS__'=>'connected(1)|disconnected(2)|notResponding(3)',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_vminfo::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.user', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.pwd', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el estdo de la conexión con el vCenter de una máquina virtual de un host ESX/ESXi a partir de los datoproporcionados por el API de vSphere.',
      },

      # ----------------------------
      '__MONITORS__' => {
         'm01' => { '__MONITOR__' => 's_xagt_004541-beb8e3cd', '__CAUSE__' => 'MAQUINA VIRTUAL NO RESPONDE', '__EXPR__' => 'v3=1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004541', '__SUBTYPE__' => 'xagt_004541', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "VMWARE - ESTADO DE VM xxx" que genera una alerta de severidad ROJA cuand se cumple la expresión: v3=1 que indica que la máquina está en estado de notResponding'  },
      },
   },

   {
      #defSUBTYPE=xagt_004542
      '__SUBTYPE__'=> 'xagt_004542', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'VMWARE - CONEXIONES MKS DE VM',
      '__APPTYPE__'=> 'VIRTUAL.VMWARE',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '110',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_SOLID',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]:[-P;Port;443;0]',
      '__ESP__'=>'o1',
      '__ITEMS__'=>'numMksConnections',
		'__MYRANGE__'=>'vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_vmware_vminfo::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.user', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.vmware.pwd', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => '443', '__SCRIPT__' => $linux_metric_vmware_vminfo::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el número de conexiones MKS de una máquina virtual de un host ESX/ESXi a partir de los datoproporcionados por el API de vSphere.',
      },
   },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_vmware_vminfo::APPS = (

);



1;
__END__
