package linux_metric_www_perf;
#/opt/cnm/designer/gconf-proxy -m linux_metric_www_perf -p www-perf
#---------------------------------------------------------------------------
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

@EXPORT_OK = qw( $CFG %SCRIPT @METRICS);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);


#---------------------------------------------------------------------------
# 0 METRICA  1=>APP
#---------------------------------------------------------------------------
$linux_metric_www_perf::CFG = 0;
$linux_metric_www_perf::SCRIPT_NAME = 'linux_metric_www_perf.pl';

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
%linux_metric_www_perf::SCRIPT = (

	'__SCRIPT__' => $linux_metric_www_perf::SCRIPT_NAME,
   '__EXEC_MODE__' => 1,
   '__SCRIPT_DESCRIPTION__' => '',  # creo que sobra ¿?
   '__PROXY_TYPE__' => 'linux',
   '__CFG__' => $linux_metric_www_perf::CFG,
   '__PROXY_USER__' => 'www-data',
   '__PROXY_PWD__' => 'cnm123',
   '__TIMEOUT__' => 30,
   '__OUT_FILES__' => 'har,png',

	# ----------------------------
	'__SCRIPT_PARAMS__' => {

		'p01' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '2', '__PARAM_PREFIX__' => '-n', '__PARAM_DESCR__' => 'IP', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_www_perf::SCRIPT_NAME },
		'p02' => { '__HPARAM__' => '', '__PARAM_TYPE__' => '0', '__PARAM_PREFIX__' => '-u', '__PARAM_DESCR__' => 'URL', '__PARAM_VALUE__' => '', '__SCRIPT__' => $linux_metric_www_perf::SCRIPT_NAME },
		},

	# ----------------------------
	'__TIP__'  => {
		'__DESCR_TIP__' => 'Este script permite obtener las siguientes métricas al acceder a una determinada URL:

<001.http://www.s30labs.com> Total Time (sg) <002.http://www.s30labs.com> Wait Time (sg) <003.http://www.s30labs.com> Receive Time (sg) <004.http://www.s30labs.com> Connect Time (sg) <005.http://www.s30labs.com> Blocked Time (sg) <006.http://www.s30labs.com> DNS Time (sg) <007.http://www.s30labs.com> Send Time (sg) <008.http://www.s30labs.com> SSL Time (sg) <009.http://www.s30labs.com> Other Time (sg) <010.http://www.s30labs.com> Responses with code 200 <011.http://www.s30labs.com> Responses with codes 4x <012.http://www.s30labs.com> Responses with codes 5x <013.http://www.s30labs.com> Response with other codes <020.http://www.s30labs.com> Total Requests Counter <021.http://www.s30labs.com> Html Requests Counter <022.http://www.s30labs.com> Javascript Requests Counter <023.http://www.s30labs.com> CSS Requests Counter <024.http://www.s30labs.com> Image Requests Counter <025.http://www.s30labs.com> Text Requests Counter <026.http://www.s30labs.com> Other Requests Counter <030.http://www.s30labs.com> Total Requests Size (bytes) <031.http://www.s30labs.com> Html Requests Size (bytes) <032.http://www.s30labs.com> Javascript Requests Size (bytes) <033.http://www.s30labs.com> CSS Requests Size (bytes) <034.http://www.s30labs.com> Image Requests Size (bytes) <035.http://www.s30labs.com> Text Requests Size (bytes) <036.http://www.s30labs.com> Other Requests Size (bytes)
 
Sus parámetros de ejecución son:

 linux_metric_www_perf.pl [-n 1.1.1.1] -u http://www.s30labs.com
 linux_metric_www_perf.pl -l  : List metrics
 linux_metric_www_perf.pl -h  : Ayuda

 -n          : IP remota
 -u          : URL
 -v/-verbose : Muestra informacion extra(debug)
 -h/-help    : Ayuda
 -l          : Lista las metricas que obtiene
',
		'__ID_REF__' => $linux_metric_www_perf::SCRIPT_NAME
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
@linux_metric_www_perf::METRICS = (

	#------------------------------------------------------------------------
	{ 
		#defSUBTYPE=xagt_004600
		'__SUBTYPE__'=> 'xagt_004600', '__CLASS__'=> 'proxy-linux',  	
		'__DESCRIPTION__'=> 'WEB PAGE LOAD TIME',
		'__APPTYPE__'=> 'IPSERV.WWW', 	'__ITIL_TYPE__'=> '1', 	'__TAG__'=> '041|042', 	'__ESP__'=> 'o1|o2',
		'__IPTAB__'=> '1', '__ITEMS__'=> 'onLoad Time|onContentLoad Time', 	'__VLABEL__'=> 'Segs',
		'__MODE__'=> 'GAUGE', 	'__MTYPE__'=> 'STD_AREA',	
		'__NPARAMS__'=> '1', 	'__PARAMS__'=> '[-n;IP;;2]', 	
		'__PARAMS_DESCR__'=> '',
		'__SCRIPT__'=> $linux_metric_www_perf::SCRIPT_NAME, 	'__SEVERITY__'=> '1', 	'__CFG__'=> '2',
		'__GET_IID__'=> '0', 	'__PROXY_TYPE__'=> 'linux', 	'__INCLUDE__'=> '0',
		'__MYRANGE__'=>'www-check,[-n;IP;;2]',

		# ----------------------------
	   '__METRIC_PARAMS__' => {

			# El resto de parametros se obtiene de la tabla credentials
   	   'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_www_perf::SCRIPT_NAME },

      },
		# ----------------------------
	   '__TIP__'  => {
   	   '__DESCR_TIP__' => 'Métrica que monitoriza el tiempo de carga de la URL especificada.',
   	},

#+---------------+----------------------------------+----------------------------+-----------+--------+----------+-----------------+--------+-----------------+-------+--------------------+
#| id_alert_type | cause                            | monitor                    | expr      | params | severity | mname           | type   | subtype         | wsize | class              |
#+---------------+----------------------------------+----------------------------+-----------+--------+----------+-----------------+--------+-----------------+-------+--------------------+
#|            18 | EXCESO DE EVENTOS                | s_xagt_647cba-d30a2710     | v1>1000   | NULL   |        2 | xagt_647cba     | xagent | xagt_647cba     |     0 | proxy-linux        |


      # ----------------------------
      '__MONITORS__' => {

         'm01' => { '__MONITOR__' => 's_xagt_004600-bf8b6871', '__CAUSE__' => 'TIEMPO DE CARGA EXCESIVO', '__EXPR__' => 'v1>5',  '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_004600', '__SUBTYPE__' => 'xagt_004600', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WEB PAGE LOAD TIME" que genera una alerta de severidad NARANJA cuando se cumple la expresión: v1>5 siendo v1 el tiempo de carga de la pagina.'  },
      },


	},



   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004601
      '__SUBTYPE__'=> 'xagt_004601', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WEB PAGE RESPONSE CODES',
      '__APPTYPE__'=> 'IPSERV.WWW',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '010|011|012|013',    '__ESP__'=> 'o1|o2|o3|o4',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'Code 200|Code 4xx|Code 5xx|Other Codes',   '__VLABEL__'=> 'Number',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      #'__NPARAMS__'=> '1',    '__PARAMS__'=> '[-n;IP;;2]:[-u;URL;;1]',
      '__NPARAMS__'=> '1',    '__PARAMS__'=> '[-n;IP;;2]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_www_perf::SCRIPT_NAME,   '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '0',
      '__MYRANGE__'=>'www-check,[-n;IP;;2]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         # El resto de parametros se obtiene de la tabla credentials
         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_www_perf::SCRIPT_NAME },

      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza los codigos obtenidos en las respuestas HTTP de los recursos de una determinada URL.',
      },

      # ----------------------------
      '__MONITORS__' => {

         'm01' => { '__MONITOR__' => 's_xagt_004601-e32744b5', '__CAUSE__' => 'ERROR DE SERVIDOR (5xx)', '__EXPR__' => 'v3>1',  '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '1', '__MNAME__' => 'xagt_004601', '__SUBTYPE__' => 'xagt_004601', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WEB PAGE RESPONSE CODES" que genera una alerta de severidad ROJA cuando se cumple la expresión: v3>1 siendo v3 el número de errores HTTP con codigo >= 500'  },
      },
   },

   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004602
      '__SUBTYPE__'=> 'xagt_004602', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WEB PAGE RESOURCES',
      '__APPTYPE__'=> 'IPSERV.WWW',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '020|021|022|023|024|025|026',    '__ESP__'=> 'o1|o2|o3|o4|o5|o6|o7',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'Total|HTML|Javascript|CSS|Image|Text|Other',   '__VLABEL__'=> 'Number',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '1',    '__PARAMS__'=> '[-n;IP;;2]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_www_perf::SCRIPT_NAME,   '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '0',
      '__MYRANGE__'=>'www-check,[-n;IP;;2]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         # El resto de parametros se obtiene de la tabla credentials
         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_www_perf::SCRIPT_NAME },

      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el numero de peticiones realizadas al acceder a una determinada URL.',
      },

      # ----------------------------
      '__MONITORS__' => {

#         'm01' => { '__MONITOR__' => 's_xagt_647cba-0062f99a', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000',  '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - NUMERO DE EVENTOS ALMACENADOS" que genera una alerta de severidad NARANJA cuando se cumple la expresión: v1>1000 siendo v1 el número de eventos'  },
      },
   },

   #------------------------------------------------------------------------
   {
      #defSUBTYPE=xagt_004603
      '__SUBTYPE__'=> 'xagt_004603', '__CLASS__'=> 'proxy-linux',
      '__DESCRIPTION__'=> 'WEB PAGE SIZE',
      '__APPTYPE__'=> 'IPSERV.WWW',    '__ITIL_TYPE__'=> '1',  '__TAG__'=> '030|031|032|033|034|035|036',    '__ESP__'=> 'o1|o2|o3|o4|o5|o6|o7',
      '__IPTAB__'=> '1', '__ITEMS__'=> 'Total|HTML|Javascript|CSS|Image|Text|Other',   '__VLABEL__'=> 'Number',
      '__MODE__'=> 'GAUGE',   '__MTYPE__'=> 'STD_AREA',
      '__NPARAMS__'=> '1',    '__PARAMS__'=> '[-n;IP;;2]',
      '__PARAMS_DESCR__'=> '',
      '__SCRIPT__'=> $linux_metric_www_perf::SCRIPT_NAME,   '__SEVERITY__'=> '1',   '__CFG__'=> '2',
      '__GET_IID__'=> '0',    '__PROXY_TYPE__'=> 'linux',   '__INCLUDE__'=> '0',
      '__MYRANGE__'=>'www-check,[-n;IP;;2]',

      # ----------------------------
      '__METRIC_PARAMS__' => {

         # El resto de parametros se obtiene de la tabla credentials
         'p01' => { '__ENABLE__' => '1', '__VALUE__' => '', '__SCRIPT__' => $linux_metric_www_perf::SCRIPT_NAME },

      },
      # ----------------------------
      '__TIP__'  => {
         '__DESCR_TIP__' => 'Métrica que monitoriza el numero de peticiones realizadas al acceder a una determinada URL.',
      },

      # ----------------------------
      '__MONITORS__' => {

#         'm01' => { '__MONITOR__' => 's_xagt_647cba-0062f99a', '__CAUSE__' => 'EXCESO DE EVENTOS', '__EXPR__' => 'v1>1000',  '__HIDE__' => '0', '__PARAMS__' => '', '__SEVERITY__' => '2', '__MNAME__' => 'xagt_647cba', '__SUBTYPE__' => 'xagt_647cba', '__WSIZE__' => '0', '__CLASS__' => 'proxy-linux', '__DESCR_TIP__' => 'Monitor para la métrica "WMI - NUMERO DE EVENTOS ALMACENADOS" que genera una alerta de severidad NARANJA cuando se cumple la expresión: v1>1000 siendo v1 el número de eventos'  },
      },
   },




);


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
%linux_metric_www_perf::APPS = (


);



1;
__END__
