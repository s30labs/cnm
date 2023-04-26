package linux_metric_wmi_services;

#/opt/cnm/designer/gconf-proxy -m linux_metric_wmi_services -p wmi-services
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_wmi_services::CFG = 0;
$linux_metric_wmi_services::SCRIPT_NAME = 'linux_metric_wmi_services.pl';

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
%linux_metric_wmi_services::SCRIPT = (

	'__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_wmi_services::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	# Tipos: 0->Normal, 1->Sec, 2->IP
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-u', '__PARAM_DESCR__' => 'User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Clave', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
		'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-i', '__PARAM_DESCR__' => 'Indice', '__PARAM_VALUE__' => 'Name', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
		'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-f', '__PARAM_DESCR__' => 'Filtro', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener los procesos y servicios arrancados en el equipo. Un ejemplo de ejecución es:
cnm@cnm:/opt/cnm/xagent/base# ./linux_metric_wmi_services.pl -h
linux_metric_wmi_services.pl 1.0

linux_metric_wmi_services.pl -n IP -u user -p pwd [-d domain] [-i Name]
linux_metric_wmi_services.pl -n IP -u domain/user -p pwd [-i Name]
linux_metric_wmi_services.pl -h  : Ayuda

-n    IP remota
-u    user
-p    pwd
-d    Dominio
-i    Index Propiedad para indexar las instancias. Por defecto es Name.
-f    Filtro sobre la consulta WSQL aplicado sobre el indice
-h    Ayuda

linux_metric_wmi_services.pl -n 1.1.1.1 -u user -p xxx
linux_metric_wmi_services.pl -n 1.1.1.1 -u user -p xxx -d miDominio
linux_metric_wmi_services.pl -n 1.1.1.1 -u user -p xxx -i Name -f TermService
',
		'__ID_REF__' => $linux_metric_wmi_services::SCRIPT_NAME
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
@linux_metric_wmi_services::METRICS = (


#   {  'name'=> 'ESTADO DEL VENTILADOR',  'oid'=>'ciscoEnvMonFanState', 'subtype'=>'cisco_fan_state', 'class'=>'CISCO', 'range'=>'CISCO-ENVMON-MIB::ciscoEnvMonFanStatusTable', 'get_iid'=>'ciscoEnvMonFanStatusDescr',  'esp'=>'MAP(1)(1,0,0,0,0,0)|MAP(2)(0,1,0,0,0,0)|MAP(3)(0,0,1,0,0,0)|MAP(4)(0,0,0,1,0,0)|MAP(5)(0,0,0,0,1,0)|MAP(6)(0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'items'=>'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)', 'itil_type' => 4, 'apptype'=>'NET.CISCO' },

#   {  'name'=> 'ESTADO SERVICIO DHCP',   'oid'=>'IB-PLATFORMONE-MIB::ibServiceStatus.1', 'subtype'=>'ib_status_dhcp', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },

	#------------------------------------------------------------------------
	# SIN INSTANCIAS
	{ 
		#defSUBTYPE=xagt_004511
		'__SUBTYPE__'=> 'xagt_004511', '__CLASS__'=> 'proxy-linux',  	
		'__DESCRIPTION__'=> 'WMI - SERVICIO SNMP',
		'__APPTYPE__'=> 'SO.WINDOWS', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> '200.SNMP',
		'__IPTAB__'=> '1', 	'__VLABEL__'=> 'Num',
		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_SOLID',	
		'__NPARAMS__'=> '4', 	'__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]:[-i;Indice;Name;1]',
		'__ESP__'=>'MAP(1)(1,0,0,0,0,0,0,0)|MAP(2)(0,1,0,0,0,0,0,0)|MAP(3)(0,0,1,0,0,0,0,0)|MAP(4)(0,0,0,1,0,0,0,0)|MAP(5)(0,0,0,0,1,0,0,0)|MAP(6)(0,0,0,0,0,1,0,0)|MAP(7)(0,0,0,0,0,0,1,0)|MAP(8)(0,0,0,0,0,0,0,1)',
		'__ITEMS__'=>'Running(1)|Unknown(2)|Stopped(3)|Start Pending(4)|Stop Pending(5)|Continue Pending(6)|Pause Pending(7)|Paused(8)',
		'__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',
	
		'__PARAMS_DESCR__'=> '',
		'__SCRIPT__'=> $linux_metric_wmi_services::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '1',
		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '1',
		# ----------------------------
	   '__METRIC_PARAMS__' => {

   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
   	   'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
   	   'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
   	   'p04' => { '__ENABLE__' => '1', '__VALUE__' => 'Name', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
   	   'p05' => { '__ENABLE__' => '1', '__VALUE__' => 'Filter', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
      },
		# ----------------------------
	   '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el estado de los servicios de un equipo Windows a partir del atributo <strong>State</strong> definido en la clase WMI <a target="_blank" title="Win32_Service" href="http://msdn.microsoft.com/en-us/library/aa394418(v=vs.85).aspx"><strong>Win32_Service</strong></a>, válida para sistemas Windows.
Se trata de una métrica sin instancias, esto significa que hay que especificar la instancia a monitorizar que en este caso es el nombre del servicio (SNMP).',
   	},


      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux'  },
#      },


	},



   #------------------------------------------------------------------------
	# CON INSTANCIAS
   {
		#defSUBTYPE=xagt_004510
      '__SUBTYPE__'=> 'xagt_004510', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - SERVICIO',
      '__APPTYPE__'=> 'SO.WINDOWS',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '200',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_SOLID',
      '__NPARAMS__'=> '4',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]:[-i;Indice;Name;1]',
      '__ESP__'=>'MAP(1)(1,0,0,0,0,0,0,0)|MAP(2)(0,1,0,0,0,0,0,0)|MAP(3)(0,0,1,0,0,0,0,0)|MAP(4)(0,0,0,1,0,0,0,0)|MAP(5)(0,0,0,0,1,0,0,0)|MAP(6)(0,0,0,0,0,1,0,0)|MAP(7)(0,0,0,0,0,0,1,0)|MAP(8)(0,0,0,0,0,0,0,1)',
      '__ITEMS__'=>'Running(1)|Unknown(2)|Stopped(3)|Start Pending(4)|Stop Pending(5)|Continue Pending(6)|Pause Pending(7)|Paused(8)',
		'__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_services::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => 'Name', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '1', '__VALUE__' => 'Filter', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el estado de los servicios de un equipo Windows a partir del atributo <strong>State</strong> definido en la clase WMI <a target="_blank" title="Win32_Service" href="http://msdn.microsoft.com/en-us/library/aa394418(v=vs.85).aspx"><strong>Win32_Service</strong></a>, válida para sistemas Windows.
Se trata de una métrica con instancias, esto permite que el sistema identifique las instancias disponibles (en este caso los servicios) del equipo amonitorizar.',

      },

      # ----------------------------
      '__MONITORS__' => {
         'm01' => { '__MONITOR__' => 's_xagt_004510-fe72798a', '__CAUSE__' => 'SERVICIO PARADO', '__EXPR__' => 'v3=1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004510', '__SUBTYPE__' => 'xagt_004510', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - SERVICIO xxx" que genera una alerta de severidad ROJA cuando se cumple la expresión: v3=1 que equivale a Stopped(3)=1'  },
      },


   },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_wmi_services::APPS = (

);



1;
__END__
