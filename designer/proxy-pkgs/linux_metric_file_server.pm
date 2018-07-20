package linux_metric_file_server;
# /opt/cnm/designer/gconf-proxy -m linux_metric_file_server -p file-server
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_file_server::CFG = 0;
$linux_metric_file_server::SCRIPT_NAME = 'linux_metric_file_server.pl';

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
%linux_metric_file_server::SCRIPT = (

	'__SCRIPT__' => $linux_metric_file_server::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_file_server::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,

#./linux_metric_file_server.pl -host 192.168.62.127 -db IMODB -user ldapuserp -pwd ld4p1serp -sqlcmd "SET NOCOUNT ON;SELECT COUNT([UserAccount]) AS '001' FROM [IMODB].[dbo].[vwLDAPAcces] FOR JSON AUTO" -tag '001' -label 'Numero de usuarios'

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-host', '__PARAM_DESCR__' => 'Server Host', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_file_server::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-port', '__PARAM_DESCR__' => 'Server port', '__PARAM_VALUE__' => '22', '__SCRIPT__' => $linux_metric_file_server::SCRIPT_NAME },
		'p03' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-user', '__PARAM_DESCR__' => 'Server User', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_file_server::SCRIPT_NAME },
		'p04' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '1', '__PARAM_PREFIX__' => '-pwd', '__PARAM_DESCR__' => 'Server Password', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_file_server::SCRIPT_NAME },
		'p05' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-proto', '__PARAM_DESCR__' => 'Server Protocol', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_file_server::SCRIPT_NAME },
		'p06' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-action', '__PARAM_DESCR__' => 'Script Action', '__PARAM_VALUE__' => 'test', '__SCRIPT__' => $linux_metric_file_server::SCRIPT_NAME },
		'p07' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-files', '__PARAM_DESCR__' => 'Num Files', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_file_server::SCRIPT_NAME },
		'p08' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-size', '__PARAM_DESCR__' => 'Files Total Size', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_file_server::SCRIPT_NAME },
		'p09' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-lapse', '__PARAM_DESCR__' => 'Time offset', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_file_server::SCRIPT_NAME },
		'p10' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-remotedir', '__PARAM_DESCR__' => 'Remote directory', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_file_server::SCRIPT_NAME },
		'p11' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-pattern', '__PARAM_DESCR__' => 'Count Group Pattern', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_file_server::SCRIPT_NAME },
		'p12' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-timeout', '__PARAM_DESCR__' => 'Timeout', '__PARAM_VALUE__' => '20', '__SCRIPT__' => $linux_metric_file_server::SCRIPT_NAME },

		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Checks File Server Operation 
The script copies the number of files (text files) specified (default is 10) to the server and then copies back from the server checking the integrity of the received files.

It provides several metrics depending on the action value:

action=test
<001> File Transfer Latency (sg) = 7.350022
<001RC> STATUS - File Transfer Latency (sg) = 0
<002> File Transfer Success (%) = 100
<002RC> STATUS - File Transfer Success (%) = 0

action=count
<003> Total Files = 8587
<003.CM_> Total Files (CM_) = 1454
<003.MP_> Total Files (MP_) = 2565
<003.SS_> Total Files (SS_) = 1988
<003.ST_> Total Files (ST_) = 2580
<003RC> STATUS - Total Files = 0
<004> Latest File Modification Time = 1532026296
<004RC> STATUS - Latest File Modification Time = 0
<005> Oldest File Modification Time = 1529624299
<005RC> STATUS - Oldest File Modification Time = 0
<006> Total Files before lapse = 8559
<006.CM_> Total Files before lapse (CM_) = 1449
<006.MP_> Total Files before lapse (MP_) = 2557
<006.SS_> Total Files before lapse (SS_) = 1981
<006.ST_> Total Files before lapse (ST_) = 2572
<006RC> STATUS - Total Files before lapse = 0
<007> Total Files after lapse = 28
<007.CM_> Total Files after lapse (CM_) = 5
<007.MP_> Total Files after lapse (MP_) = 8
<007.SS_> Total Files after lapse (SS_) = 7
<007.ST_> Total Files after lapse (ST_) = 8
<007RC> STATUS - Total Files after lapse = 0

File Transfer Latency show the time consumed in the test overall operation.
File Transfer Success show the percent of success in the test file transfers.
Total Files counts the number of files in directory
Latest File Modification Time shows the most recent file time in directory
Oldest File Modification Time shows the oldest file time in directory
Total Files before lapse counts the number of files in directory before the specified lapse
Total Files after lapse counts the number of files in directory after the specified lapse
The parameters are:

 linux_metric_file_server.pl -host 1.1.1.1 -user user1 -pwd xxx [-port 22|...] [-proto sftp|...] [-action test] [-files 10|...] [-size 100000|...] [-v]
 linux_metric_file_server.pl -host 1.1.1.1 -user user1 -pwd xxx [-port 22|...] [-proto sftp|...] -action count [-remotedir /dir1/xx] [-v]
 linux_metric_file_server.pl -host 1.1.1.1 -user user1 -pwd xxx [-port 22|...] [-proto sftp|...] -action count [-remotedir /dir1/xx] [-lapse 3600] [-v]
 linux_metric_file_server.pl -host 1.1.1.1 -user user1 -pwd xxx [-port 22|...] [-proto sftp|...] -action count [-remotedir /dir1/xx] [-lapse 3600]  [-pattern a,b,c] [-v]
 linux_metric_file_server.pl -h  : Help

 -host       : File Server Host
 -port       : Port (default 22)
 -user       : Server User
 -pwd        : Server User Password
 -proto      : Protocol (default sftp)
 -action     : test|count
 -files      : Number of files used (tx/rx). Default is 10. (mode=test)
 -size       : Aggregated size. Default is 300KB. (mode=test)
 -remotedir  : Remote directory  (mode=count|test)
 -lapse      : Defines a time reference (tRef) = Tnow-lapse in mode=count.
 -pattern    : Text pattern (or patterns) for file classification in mode count
 -timeout    : Max. Timeout [Default 20 sg]
 -v/-verbose : Verbose output (debug)
 -h/-help    : Help
',
		'__ID_REF__' => $linux_metric_file_server::SCRIPT_NAME
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
@linux_metric_file_server::METRICS = (


);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_file_server::APPS = (


);



1;
__END__
