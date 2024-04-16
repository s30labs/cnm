package linux_metric_smb_files;
# /opt/cnm/designer/gconf-proxy -m linux_metric_smb_files -p smb-files
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_smb_files::CFG = 0;
$linux_metric_smb_files::SCRIPT_NAME = 'linux_metric_smb_files.pl';

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
%linux_metric_smb_files::SCRIPT = (

	'__SCRIPT__' => $linux_metric_smb_files::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_smb_files::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,
#	'__OUT_FILES__' => 'base',

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

      'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-host', '__PARAM_DESCR__' => 'Host/IP Address', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_smb_files::SCRIPT_NAME },
      'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-user', '__PARAM_DESCR__' => 'SMB User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_smb_files::SCRIPT_NAME },
      'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-pwd', '__PARAM_DESCR__' => 'SMB Password', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_smb_files::SCRIPT_NAME },
      'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-domain', '__PARAM_DESCR__' => 'Domain', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_smb_files::SCRIPT_NAME },
      'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-share', '__PARAM_DESCR__' => 'Share Name', '__PARAM_VALUE__' => 'C$', '__SCRIPT__' => $linux_metric_smb_files::SCRIPT_NAME },
      'p06' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-path', '__PARAM_DESCR__' => 'Path in share', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_smb_files::SCRIPT_NAME },
      'p07' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-pattern', '__PARAM_DESCR__' => 'File pattern', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_smb_files::SCRIPT_NAME },
      'p08' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-proto', '__PARAM_DESCR__' => 'SMB Protocol', '__PARAM_VALUE__' => 'SMB3', '__SCRIPT__' => $linux_metric_smb_files::SCRIPT_NAME },
      'p09' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-timeout', '__PARAM_DESCR__' => 'SMB Timeout', '__PARAM_VALUE__' => '20', '__SCRIPT__' => $linux_metric_smb_files::SCRIPT_NAME },

		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener datos relativos al numero de ficheros de un share remoto accesible por SMB/CIFS

linux_metric_smb_files.pl -host 1.1.1.1 -user myuser -pwd mypwd [-domain C\$] -path dir1/dir2
<001.C/dir1/dir2> Number of Files = 2
<002.C/dir1/dir2> Number of Dirs = 0
<003.C/dir1/dir2> Dir Size = 48620

Sus parámetros de ejecución son:

-host
     Host remoto que comparte el share de red
-user
     Usuario para acceder al share remoto.
-pwd
     Clave para acceder al share remoto.
-domain
     Dominio del usuario que accede al share. Si no se especifica es MYGROUP
-share
     Nombre del share. Si no se especifica es C\$
-path
     Ruta a la que se accede dentro del share
-pattern
     Patron de busqueda de ficheros. Si no se especifica, son todos los ficheros
-proto
     Maximo protocolo SMB utilizado. Puede ser SMB1 o SMB2. Por defecto es SMB3
-timeout
     Timeout en la peticion SMB. Por defefcto son 20 sg.
',
		'__ID_REF__' => $linux_metric_smb_files::SCRIPT_NAME
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
# __ºSEVERITY__
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
@linux_metric_smb_files::METRICS = (

#	#------------------------------------------------------------------------
#	{ 
#		#defSUBTYPE=xagt_004620
#		'__SUBTYPE__'=> 'xagt_004620', '__CLASS__'=> 'proxy-linux', '__LAPSE__'=> '300',
#		'__DESCRIPTION__'=> 'TEXTO SCRIPT EN PAGINA WEB',
#		'__APPTYPE__'=> 'IPSERV.WWW', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> '003', 	'__ESP__'=> 'o1',
#		'__IPTAB__'=> '1', '__ITEMS__'=> 'Number of Ocurrences', 	'__VLABEL__'=> 'Num',
#		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_AREA',	
#		'__NPARAMS__'=> '2', 	'__PARAMS__'=> '[-ip;IP;;2]:[-pattern;PATRON;script;1]', 	
#		'__PARAMS_DESCR__'=> '',
#		'__SCRIPT__'=> $linux_metric_smb_files::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '2',
#		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '0',
#		'__MYRANGE__'=>'www-check,[-ip;IP;;2]',
#
#		# ----------------------------
#	   '__METRIC_PARAMS__' => {
#
#   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_smb_files::SCRIPT_NAME },
#   	   'p02' => { '__ENABLE__' => '1', '__VALUE__' => 'script', '__SCRIPT__' => $linux_metric_smb_files::SCRIPT_NAME },
#
#      },
#		# ----------------------------
#	   '__TIP__'  => {
#   	   '__DESCR_TIP__' => 'Métrica que monitoriza el numero de veces que existe la cadena "script" en la url especificada',
#   	},
#
##+---------------+----------------------------------+----------------------------+-----------+--------+----------+-----------------+--------+-----------------+-------+--------------------+
##| id_alert_type | cause                            | monitor                    | expr      | params | severity | mname           | type   | subtype         | wsize | class              |
##+---------------+----------------------------------+----------------------------+-----------+--------+----------+-----------------+--------+-----------------+-------+--------------------+
##|            18 | EXCESO DE EVENTOS                | s_xagt_647cba-d30a2710     | v1>1000   | NULL   |        2 | xagt_647cba     | xagent | xagt_647cba     |     0 | proxy-linux        |
#
#
#      # ----------------------------
##      '__MONITORS__' => {
##
##         'm01' => { '__MONITOR__' => 's_xagt_004600-bf8b6871', '__CAUSE__' => 'TIEMPO DE CARGA EXCESIVO', '__EXPR__' => 'v1>5',  '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_004600', '__SUBTYPE__' => 'xagt_004600', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WEB PAGE LOAD TIME" que genera una alerta de severidad NARANJA cuando se cumple la expresión: v1>5 siendo v1 el tiempo de carga de la pagina.'  },
##      },
#
#
#	},
#

);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_smb_files::APPS = (


);



1;
__END__
