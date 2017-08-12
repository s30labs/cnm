package linux_metric_wmi_disk;

#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_wmi_disk::CFG = 0;
$linux_metric_wmi_disk::SCRIPT_NAME = 'linux_metric_wmi_disk.pl';

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
%linux_metric_wmi_disk::SCRIPT = (

	'__SCRIPT__' => $linux_metric_wmi_disk::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_wmi_disk::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	# Tipos: 0->Normal, 1->Sec, 2->IP
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_disk::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-u', '__PARAM_DESCR__' => 'User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_disk::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Clave', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_disk::SCRIPT_NAME },
		'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-i', '__PARAM_DESCR__' => 'Indice', '__PARAM_VALUE__' => 'Name', '__SCRIPT__' => $linux_metric_wmi_disk::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener datos sobre los discos lógicos del equipo como el tamaño, espacio libre, estado etc. Un ejemplo de ejecución es:
linux_metric_wmi_disk.pl -n 1.1.1.1 -u user -p xxx
<200.C:> FreeSpace = 61972226048
<201.C:> Size = 85792387072
<202.C:> DiskUsage = 23820161024
<203.C:> DiskUsage(%) = 27.76
<204.C:> Availability = 0
<205.C:> Status = (null)
<206.C:> DriveType = Local Disk
<207.C:> VolumeDirty = False
',
		'__ID_REF__' => $linux_metric_wmi_disk::SCRIPT_NAME
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
@linux_metric_wmi_disk::METRICS = (


#   {  'name'=> 'ESTADO DEL VENTILADOR',  'oid'=>'ciscoEnvMonFanState', 'subtype'=>'cisco_fan_state', 'class'=>'CISCO', 'range'=>'CISCO-ENVMON-MIB::ciscoEnvMonFanStatusTable', 'get_iid'=>'ciscoEnvMonFanStatusDescr',  'esp'=>'MAP(1)(1,0,0,0,0,0)|MAP(2)(0,1,0,0,0,0)|MAP(3)(0,0,1,0,0,0)|MAP(4)(0,0,0,1,0,0)|MAP(5)(0,0,0,0,1,0)|MAP(6)(0,0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'items'=>'Ok(1)|Warn(2)|Crit(3)|Shut(4)|NotP(5)|NotF(6)', 'itil_type' => 4, 'apptype'=>'NET.CISCO' },

#   {  'name'=> 'ESTADO SERVICIO DHCP',   'oid'=>'IB-PLATFORMONE-MIB::ibServiceStatus.1', 'subtype'=>'ib_status_dhcp', 'class'=>'INFOBLOX', , 'vlabel'=>'estado', 'include'=>1, 'items'=>'Ok(1)|Warn(2)|Failed(3)|Inactive(4)|Unk(5)', 'esp'=>'MAP(1)(1,0,0,0,0)|MAP(2)(0,1,0,0,0)|MAP(3)(0,0,1,0,0)|MAP(4)(0,0,0,1,0)|MAP(5)(0,0,0,0,1)', 'mtype'=>'STD_SOLID', 'itil_type' => 4, 'apptype'=>'NET.INFOBLOX' },

	#------------------------------------------------------------------------
	# SIN INSTANCIAS
	{ 
		#defSUBTYPE=xagt_004513
		'__SUBTYPE__'=> 'xagt_004513', '__CLASS__'=> 'proxy-linux',  	
		'__DESCRIPTION__'=> 'WMI - DISCO C:',
		'__APPTYPE__'=> 'SO.WINDOWS', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> '201.C:|202.C:|200.C:|203.C:',
		'__IPTAB__'=> '1', 	'__VLABEL__'=> 'Num',
		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_AREA',	
		'__NPARAMS__'=> '4', 	'__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]:[-i;Indice;Name;1]',
		'__ESP__'=>'o1|o2|o3|o4',
		'__ITEMS__'=>'Espacio Total|Espacio Usado|Espacio Libre|Usado(%)',
		'__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

		'__PARAMS_DESCR__'=> '',
		'__SCRIPT__'=> $linux_metric_wmi_disk::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '1',
		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '1',
		# ----------------------------
	   '__METRIC_PARAMS__' => {

   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_disk::SCRIPT_NAME },
   	   'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_disk::SCRIPT_NAME },
   	   'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_disk::SCRIPT_NAME },
   	   'p04' => { '__ENABLE__' => '1', '__VALUE__' => 'Name', '__SCRIPT__' => $linux_metric_wmi_disk::SCRIPT_NAME },
      },
		# ----------------------------
	   '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el uso del disco C: de un equipo Windows a partir de los atributos <strong>Size y FreeSpace</strong> de la clase WMI <strong>Win32_LogicalDisk</strong>.
Es válida para sistemas Windows. (http://msdn.microsoft.com/en-us/library/aa394173(v=vs.85).aspx)',
   	},


      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux'  },
#      },


	},



   #------------------------------------------------------------------------
	# CON INSTANCIAS
   {
		#defSUBTYPE=xagt_004512
      '__SUBTYPE__'=> 'xagt_004512', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - DISCO',
      '__APPTYPE__'=> 'SO.WINDOWS',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '201|202|200|203',
      '__IPTAB__'=> '1',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '4',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]:[-i;Indice;Name;1]',
      '__ESP__'=>'o1|o2|o3|o4',
      '__ITEMS__'=>'Espacio Total|Espacio Usado|Espacio Libre|Usado(%)',
		'__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_disk::SCRIPT_NAME,  '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_disk::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_disk::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_disk::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => 'Name', '__SCRIPT__' => $linux_metric_wmi_disk::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el uso de los discos de un equipo Windows a partir de los atributos <strong>Size y FreeSpace</strong> de la clase WMI <strong>Win32_LogicalDisk</strong>.
Es válida para sistemas Windows. (http://msdn.microsoft.com/en-us/library/aa394173(v=vs.85).aspx)',
      },

      # ----------------------------
#      '__MONITORS__' => {
#        'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'SERVICIO PARADO', '__EXPR__' => 'v3=1', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004510', '__SUBTYPE__' => 'xagt_004510', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - SERVICIO xxx" que genera una alerta de severidad ROJA cuando se cumple la expresión: v3=1 que equivale a Stopped(3)=1'  },
#      },


   },

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_wmi_disk::APPS = (

);



1;
__END__
