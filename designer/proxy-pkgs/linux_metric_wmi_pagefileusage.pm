

#/opt/cnm/designer/gconf-proxy -m linux_metric_wmi_pagefileusage -p wmi-pagefileusage
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0=>METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_wmi_pagefileusage::CFG = 0;
$linux_metric_wmi_pagefileusage::SCRIPT_NAME = 'linux_metric_wmi_pagefileusage.pl';

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
%linux_metric_wmi_pagefileusage::SCRIPT = (

	'__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_wmi_pagefileusage::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

	# ----------------------------
	# Tipos: 0->Normal, 1->Sec, 2->IP
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-u', '__PARAM_DESCR__' => 'User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-p', '__PARAM_DESCR__' => 'Clave', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
		'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-i', '__PARAM_DESCR__' => 'Indice', '__PARAM_VALUE__' => 'Name', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
      'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-f', '__PARAM_DESCR__' => 'Filtro', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },


		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Obtiene el uso del fichero de paginacion de WIndows. Concreatamente los valores de AllocatedBaseSize (MB, CurrentUsage (MB) y PeakUsage (MB). Un ejemplo de ejecución es:
cnm@cnm:/opt/cnm/xagent/base# ./linux_metric_wmi_pagefileusage.pl -h
linux_metric_wmi_pagefileusage.pl 1.0

linux_metric_wmi_pagefileusage.pl -n IP -u user -p pwd [-d domain] [-i Name]
linux_metric_wmi_pagefileusage.pl -n IP -u domain/user -p pwd [-i Name]
linux_metric_wmi_pagefileusage.pl -h  : Ayuda

-n    IP remota
-u    user
-p    pwd
-d    Dominio
-i    Index Propiedad para indexar las instancias. Por defecto es Name.
-f    Filtro sobre la consulta WSQL aplicado sobre el indice
-h    Ayuda

Si no se especifican Index y Filtro. Devuelve todas las instancias:
<AllocatedBaseSize.C> AllocatedBaseSize = 512
<AllocatedBaseSize.E> AllocatedBaseSize = 13312
<CurrentUsage.C> CurrentUsage = 134
<CurrentUsage.E> CurrentUsage = 968
<PeakUsage.C> PeakUsage = 235
<PeakUsage.E> PeakUsage = 2260
Si se especifican (-i Name -f "C:\pagefile.sys"), devuelve s�lo la especificada:
<AllocatedBaseSize.C> AllocatedBaseSize = 512
<CurrentUsage.C> CurrentUsage = 134
<PeakUsage.C> PeakUsage = 235

',
		'__ID_REF__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME
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
@linux_metric_wmi_pagefileusage::METRICS = (


	#------------------------------------------------------------------------
	# SIN INSTANCIAS C:\PAGEFILE.SYS
	{ 
      #defSUBTYPE=xagt_004507
      '__SUBTYPE__'=> 'xagt_004507', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - USO DE C:\PAGEFILE.SYS',
      '__APPTYPE__'=> 'SO.WINDOWS',  '__ITIL_TYPE__'=> '1',  '__TAG__'=> 'AllocatedBaseSize.C|CurrentUsage.C|PeakUsage.C',   '__ESP__'=> 'o1|o2|o3',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'AllocatedBaseSize (MB)|CurrentUsage (MB)|PeakUsage (MB)',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]:[-i;Indice;Name;1]:[-f;Filter;C:\pagefile.sys;1]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_pagefileusage::SCRIPT_NAME,    '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
   	   'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
   	   'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
   	   'p04' => { '__ENABLE__' => '1', '__VALUE__' => 'Name', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
   	   'p05' => { '__ENABLE__' => '1', '__VALUE__' => 'C:\pagefile.sys', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'AllocatedBaseSize is the actual amount of disk space allocated for use with the page file, CurrentUsage is the amount of disk space currently used by the page file and PeakUsage is the highest use page file. All three are measured in MBytes and captured from <strong>AllocatedBaseSize, CurrentUsage, PeakUsage</strong> counters of the WMI class<strong>Win32_PageFileUsage</strong>.
This metric is valid only on Windows Systems.',
      }

      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux'  },
#      },

	},

   #------------------------------------------------------------------------
   # SIN INSTANCIAS D:\PAGEFILE.SYS
   {
      #defSUBTYPE=xagt_004516
      '__SUBTYPE__'=> 'xagt_004516', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - USO DE D:\PAGEFILE.SYS',
      '__APPTYPE__'=> 'SO.WINDOWS',  '__ITIL_TYPE__'=> '1',  '__TAG__'=> 'AllocatedBaseSize.D|CurrentUsage.D|PeakUsage.D',   '__ESP__'=> 'o1|o2|o3',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'AllocatedBaseSize (MB)|CurrentUsage (MB)|PeakUsage (MB)',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]:[-i;Indice;Name;1]:[-f;Filter;D:\pagefile.sys;1]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_pagefileusage::SCRIPT_NAME,    '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => 'Name', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '1', '__VALUE__' => 'D:\pagefile.sys', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'AllocatedBaseSize is the actual amount of disk space allocated for use with the page file, CurrentUsage is the amount of disk space currently used by the page file and PeakUsage is the highest use page file. All three are measured in MBytes and captured from <strong>AllocatedBaseSize, CurrentUsage, PeakUsage</strong> counters of the WMI class<strong>Win32_PageFileUsage</strong>.
This metric is valid only on Windows Systems.',
      }

      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux'  },
#      },

   },

   #------------------------------------------------------------------------
   # SIN INSTANCIAS E:\PAGEFILE.SYS
   {
      #defSUBTYPE=xagt_004517
      '__SUBTYPE__'=> 'xagt_004517', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - USO DE E:\PAGEFILE.SYS',
      '__APPTYPE__'=> 'SO.WINDOWS',  '__ITIL_TYPE__'=> '1',  '__TAG__'=> 'AllocatedBaseSize.E|CurrentUsage.E|PeakUsage.E',   '__ESP__'=> 'o1|o2|o3',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'AllocatedBaseSize (MB)|CurrentUsage (MB)|PeakUsage (MB)',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]:[-i;Indice;Name;1]:[-f;Filter;E:\pagefile.sys;1]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_pagefileusage::SCRIPT_NAME,    '__SEVERITY__'=> '1',   '__CFG__'=> '1',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '1', '__VALUE__' => 'Name', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '1', '__VALUE__' => 'E:\pagefile.sys', '__SCRIPT__' => $linux_metric_wmi_pagefileusage::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'AllocatedBaseSize is the actual amount of disk space allocated for use with the page file, CurrentUsage is the amount of disk space currently used by the page file and PeakUsage is the highest use page file. All three are measured in MBytes and captured from <strong>AllocatedBaseSize, CurrentUsage, PeakUsage</strong> counters of the WMI class<strong>Win32_PageFileUsage</strong>.
This metric is valid only on Windows Systems.',
      }

      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux'  },
#      },

   },

   #------------------------------------------------------------------------
   # CON INSTANCIAS
   {
      #defSUBTYPE=xagt_004514
      '__SUBTYPE__'=> 'xagt_004514', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WMI - FICHERO DE PAGINACION',
      '__APPTYPE__'=> 'SO.WINDOWS',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> 'AllocatedBaseSize|CurrentUsage|PeakUsage', '__ESP__'=> 'o1|o2|o3',
		'__IPTAB__'=> '1', '__ITEMS__'=> 'AllocatedBaseSize (MB)|CurrentUsage (MB)|PeakUsage (MB)',   '__VLABEL__'=> 'Num',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREAD',
      '__NPARAMS__'=> '5',    '__PARAMS__'=> '[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]:[-i;Indice;Name;1][-f;Filter;;1]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_wmi_pagefileusage::SCRIPT_NAME,    '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '1',
      '__MYRANGE__'=>'wmi-check,[-n;IP;;2]:[-u;Usuario;$sec.wmi.user;1]:[-p;Clave;$sec.wmi.pwd;1]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
         'p02' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.user', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
         'p03' => { '__ENABLE__' => '1', '__VALUE__' => '$sec.wmi.pwd', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
         'p04' => { '__ENABLE__' => '0', '__VALUE__' => 'Name', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
         'p05' => { '__ENABLE__' => '0', '__VALUE__' => 'Filter', '__SCRIPT__' => $linux_metric_wmi_services::SCRIPT_NAME },
      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'AllocatedBaseSize is the actual amount of disk space allocated for use with the page file, CurrentUsage is the amount of disk space currently used by the page file and PeakUsage is the highest use page file. All three are measured in MBytes and captured from <strong>AllocatedBaseSize, CurrentUsage, PeakUsage</strong> counters of the WMI class<strong>Win32_PageFileUsage</strong>.
This metric is valid only on Windows Systems.',
      },

      # ----------------------------
#      '__MONITORS__' => {
#         'm01' => { '__MONITOR__' => '', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000', '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux'  },
#      },
	},
);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_wmi_pagefileusage::APPS = (

);



1;
__END__
