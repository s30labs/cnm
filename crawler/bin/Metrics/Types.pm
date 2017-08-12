#####################################################################################################
# Fichero: (Metrics::Types.pm) $Id: Types.pm,v 1.3 2004/10/04 10:29:53 fml Exp $
# Revision: Ver $VERSION
# Descripción: Móodulo que define las metricas soportadas
#####################################################################################################
package Metrics::Types;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
use Exporter;
@ISA = qw(Exporter);
$VERSION = '1.00';
@EXPORT_OK = qw( %GRAPH %CREATE %PERIOD );
@EXPORT=@EXPORT_OK;

#----------------------------------------------------------------------------
# Colores disponibles para las lineas de los graficos
use constant AZUL => '0000FF';
use constant VERDE => '00FF00';
use constant ROJO => 'FF0000';
use constant AMARILLO => 'FFFF00';
use constant FUXIA => 'FF00FF';
use constant NARANJA => 'FF9900';
use constant OCRE => 'FFCC00';
use constant GRIS => '555555';

#----------------------------------------------------------------------------
# Periodos de tiempo soportados en los graficos
%Metrics::Types::PERIOD =( 

   # Poll = 1  minuto
   day_6h => [-21600,-1], day_12h => [-43200,-21600], day_18h => [-64800,-43200],
   day_24h => [-86400,-64800], day_1_6h => [-108000,-86400], day_1_12h => [-129600,-108000],
   day_1_18h => [-151200,-129600], day_1_24h => [-172800,-151200],
	
	# Poll = 5 minutos
	#today => [-93600,-1], day_1 => [-180000,-86400], day_2 => [-266400,-172800], 
	#day_3 => [-352800,-259200], day_4 => [-439200,-345600], day_5 => [-525600,-432000], 
	#day_6 => [-612000,-518400], day_7 => [-698400,-604800],
	#week => [-604800,-1], week_1 => [-1209600,-604800], 
	#month => [-2592000,-1], year => [-31536000,-1] 

   today => [-120001,-1], day_1 => [-206400,-86400], day_2 => [-292800,-172800],
   day_3 => [-379200,-259200], day_4 => [-465600,-345600], day_5 => [-552000,-432000],
   day_6 => [-638400,-518400], day_7 => [-724800,-604800],
   week => [-604800,-1], week_1 => [-1209600,-604800],
   month => [-2592000,-1], year => [-31536000,-1]

);
						
#----------------------------------------------------------------------------
# _start_ -> $PERIOD{$period}->[0]
# _end_ -> $PERIOD{$period}->[1]
# _title_
# _vlabel_
# _rrd_file_
# _item_
# _color_

#----------------------------------------------------------------------------
my $graph_cmd='/opt/rrdtool/bin/rrdtool graph';

#----------------------------------------------------------------------------
# Creación de RRDs
# NOTA: los mtypes son combinación de CREATE_GRAPH ej. STD_TRAFFIC, 
%Metrics::Types::CREATE=(

	#------------------------------------------------------------------------
	# width por defecto del grafico=400 muestras
	# ==> Cada 6 horas aprox	
   # Diario con 2 dias. Factor=1 => Poll cada 60 segs. => 1440*2=2880
   # Semanal con 2 semanas. Factor=15 => Poll cada 15 min. => 672*2=1344
   # Mensual con 2 meses. Factor=60 => Poll cada  hora => 744*2=1488
   # Anual con 2 anos. Factor=1440 => Poll cada dia => 365*2=730
   H0   =>        [  "RRA:AVERAGE:0.5:1:3000",
                     "RRA:AVERAGE:0.5:15:1400",
                     "RRA:AVERAGE:0.5:60:1500",
                     "RRA:AVERAGE:0.5:1440:800",
                     "RRA:MAX:0.5:1:3000",
                     "RRA:MAX:0.5:15:1400",
                     "RRA:MAX:0.5:60:1500",
                     "RRA:MAX:0.5:1440:800"],

   # Diario con 8 dias. Factor=1 => Poll cada 60 segs. => 1440*8=11520
   # Semanal con 1 semana. Factor=15 => Poll cada 15 min. => 672*1=672
   # Mensual con 1 mes. Factor=60 => Poll cada  hora => 744*1=744
   # Anual con 1 ano. Factor=1440 => Poll cada dia => 365*1=365
   H1   =>        [  "RRA:AVERAGE:0.5:1:12000",
                     "RRA:AVERAGE:0.5:15:700",
                     "RRA:AVERAGE:0.5:60:800",
                     "RRA:AVERAGE:0.5:1440:400",
                     "RRA:MAX:0.5:1:12000",
                     "RRA:MAX:0.5:15:700",
                     "RRA:MAX:0.5:60:800",
                     "RRA:MAX:0.5:1440:400"],

	# Para rrds de vistas
   # Diario con 8 dias. Factor=1 => Poll cada 60 segs. => 1440*8=11520
   # Semanal con 3 semanas. Factor=5 => Poll cada 5 min. => 2016*3=6048
   # Mensual con 5 meses. Factor=15 => Poll cada  15 min. => 2976*5=14880
   # Anual con 1 ano. Factor=1440 => Poll cada hora => 8760*1=8760
   H2   =>        [  "RRA:AVERAGE:0.5:1:12000",
                     "RRA:AVERAGE:0.5:5:6050",
                     "RRA:AVERAGE:0.5:15:14900",
                     "RRA:AVERAGE:0.5:60:8800",
                     "RRA:MAX:0.5:1:12000",
                     "RRA:MAX:0.5:15:6050",
                     "RRA:MAX:0.5:60:14900",
                     "RRA:MAX:0.5:1440:8800"],

	#------------------------------------------------------------------------
	# Diario con 8 dias. Factor=1 => Poll cada 5 min. => 288*8=2304
	# Semanal con 2 semanas. Factor=6 => Poll cada 30 min. => 336*2=672
	# Mensual con 2 meses. Factor=24 => Poll cada 2 horas => 372*2=744
	# Anual con 2 anos. Factor=288 => Poll cada dia => 365*2=730
	STD  => 			[	"RRA:AVERAGE:0.5:1:2350", 
							"RRA:AVERAGE:0.5:6:700", 
							"RRA:AVERAGE:0.5:24:775", 
							"RRA:AVERAGE:0.5:288:797",
							"RRA:MAX:0.5:1:2350",
               		"RRA:MAX:0.5:6:700",
               		"RRA:MAX:0.5:24:775",
               		"RRA:MAX:0.5:288:797"],

   STDMM =>        [  "RRA:MIN:0.5:1:2350",
                     "RRA:MIN:0.5:6:700",
                     "RRA:MIN:0.5:24:775",
                     "RRA:MIN:0.5:288:797",
                     "RRA:MAX:0.5:1:2350",
                     "RRA:MAX:0.5:6:700",
                     "RRA:MAX:0.5:24:775",
                     "RRA:MAX:0.5:288:797"],

  
   D0  => 			[	"RRA:AVERAGE:0.5:1:2350", 
							"RRA:AVERAGE:0.5:6:700", 
							"RRA:AVERAGE:0.5:24:775", 
							"RRA:AVERAGE:0.5:288:797",
							"RRA:MAX:0.5:1:2350",
               		"RRA:MAX:0.5:6:700",
               		"RRA:MAX:0.5:24:775",
               		"RRA:MAX:0.5:288:797"],

	#Igual que STD pero con 31 dias de profundidad 
  	D1  => 			[	"RRA:AVERAGE:0.5:1:9300", 
							"RRA:AVERAGE:0.5:6:700", 
							"RRA:AVERAGE:0.5:24:775", 
							"RRA:AVERAGE:0.5:288:797",
							"RRA:MAX:0.5:1:9300",
               		"RRA:MAX:0.5:6:700",
               		"RRA:MAX:0.5:24:775",
               		"RRA:MAX:0.5:288:797"],

	#------------------------------------------------------------------------
   # Diario con 31 dias. Factor=1 => Poll cada hora. => 24*31=744
   # Anual con 1 ano. Factor=6 => Poll cada dia => 4*365=1460
  	M0  => 			[	"RRA:AVERAGE:0.5:1:750", 
							"RRA:AVERAGE:0.5:6:1500", 
							"RRA:MAX:0.5:1:750",
               		"RRA:MAX:0.5:6:1500" ],
    
   # Diario con 31 dias. Factor=1 => Poll cada hora. => 24*31=744
   # Anual con 1 ano. Factor=6 => Poll cada dia => 4*365=1460
   # Anual con 5 anos. Factor=24 => Poll cada dia => 5*365=1825
  	M1  => 			[	"RRA:AVERAGE:0.5:1:750", 
							"RRA:AVERAGE:0.5:6:1500", 
							"RRA:AVERAGE:0.5:24:1900", 
							"RRA:MAX:0.5:1:750",
               		"RRA:MAX:0.5:6:1500",
               		"RRA:MAX:0.5:24:1900" ],

);

#----------------------------------------------------------------------------
# Presentación de los RRDs
# NOTA: los mtypes son combinación de CREATE_GRAPH ej. STD_TRAFFIC, 
$Metrics::FONT_TITLE='TITLE:8:/usr/share/fonts/ttf/Comicbd.ttf';
$Metrics::FONT_LEGEND='LEGEND:7:/usr/share/fonts/ttf/Arial.ttf';
$Metrics::FONT_AXIS='AXIS:7:/usr/share/fonts/ttf/couri.ttf';
$Metrics::FONT_UNIT='UNIT:7:/usr/share/fonts/ttf/couri.ttf';

$Metrics::WIDTH='350';
%Metrics::Types::GRAPH=(

	#*8
	TRAFFIC  => { 
		
		base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_  -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS --font $Metrics::FONT_UNIT  --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0", 
		def=>" DEF:VAL_N_=_rrd_file_:value_N_:MAX",
		cdef=>" CDEF:VALM_N_=VAL_N_,8,*", 
		line_first=>" AREA:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.1lf%s \\n\"", 
		line_rest=>" LINE1:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.1lf%s \\n\"" ,
		comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

	colors => [VERDE, AZUL, ROJO, NARANJA, OCRE, GRIS]
	},

	#*1024
   DISK => {

      base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_  -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0",
      def=>" DEF:VAL_N_=_rrd_file_:value_N_:AVERAGE",
      cdef=>" CDEF:VALM_N_=VAL_N_,1024,*",
      line_first=>" AREA:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.1lf%s \\n\"",
      line_rest=>" AREA:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.1lf%s \\n\"",
		comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

      colors => [VERDE, AZUL, FUXIA, NARANJA, OCRE, GRIS]
   },

   OPER  => {

      base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_  -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS  --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0",
      def=>" DEF:VAL_N_=_rrd_file_:value_N_:MAX",
      cdef=>" CDEF:VALM_N_=VAL_N_,_OPER_",
      line_first=>" AREA:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.1lf%s \\n\"",
      line_rest=>" LINE1:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.1lf%s \\n\"",
		comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

		colors => [VERDE, AZUL, FUXIA, NARANJA, OCRE, GRIS]
   },


	BASE => { 
		
		base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_  -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS  --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0", 
		def=>" DEF:VAL_N_=_rrd_file_:value_N_:AVERAGE", 
		cdef=>" CDEF:VALM_N_=VAL_N_", 
		line_first=>" LINE2:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.1lf%s \\n\" ", 
		line_rest=>" LINE2:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.1lf%s \\n\" ",
		comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

		colors => [VERDE, AZUL, FUXIA, NARANJA, OCRE, GRIS]
	},

   VIEW => {

      base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_  -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS  --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0",
      def=>" DEF:VAL_N_=_rrd_file_:value_N_:AVERAGE",
      cdef=>" CDEF:VALM_N_=VAL_N_",
      line_first=>" AREA:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.1lf%s \\n\" ",
      line_rest=>" STACK:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.1lf%s \\n\" ",
      comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

      colors => [ROJO, NARANJA, AMARILLO, AZUL, GRIS]
   },


	# Igual que la anterior pero permite valores negativos (util para metricas con memoria y analisis)
   ANAL => {

      base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_  -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS  --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\"",
      def=>" DEF:VAL_N_=_rrd_file_:value_N_:AVERAGE",
      cdef=>" CDEF:VALM_N_=VAL_N_",
      line_first=>" LINE2:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.1lf%s \\n\" ",
      line_rest=>" LINE2:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.1lf%s \\n\" ",
      comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

      colors => [VERDE, AZUL, FUXIA, NARANJA, OCRE, GRIS]
   },


   BASEIP1 => {

      base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_ -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0",
      def=>" DEF:VAL_N_=_rrd_file_:value_N_:AVERAGE",
      cdef=>" CDEF:VALM_N_=VAL_N_",
      line_first=>" AREA:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.1lf%s \\n\"",
      line_rest=>" AREA:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.1lf%s \\n\"",
		comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

      colors => [NARANJA, AZUL, VERDE, FUXIA, GRIS, OCRE]
   },

	#Para valores enteros (MIN/MAX)
   BASEI => {

      #base=>"$graph_cmd -  --start _start_ --end _end_ -h 60  -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS  --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0",
      base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_  -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS  --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0",
      def=>" DEF:VAL_N_=_rrd_file_:value_N_:MIN",
      cdef=>" CDEF:VALM_N_=VAL_N_",
      line_first=>" AREA:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.1lf%s \\n\"",
      line_rest=>" AREA:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.1lf%s \\n\"",
		comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

      colors => [NARANJA, AZUL, VERDE, FUXIA, GRIS, OCRE]
   },


   SOLID => {

      #base=>"$graph_cmd -  --start _start_ --end _end_ -h 20 -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0",
      base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_ -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0",
      def=>" DEF:VAL_N_=_rrd_file_:value_N_:AVERAGE",
      cdef=>" CDEF:VALM_N_=VAL_N_",
      #line_first=>" AREA:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.2lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.2lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.2lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.2lf%s \l\"",
      #line_rest=>" AREA:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.2lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.2lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.2lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.2lf%s \l\""
      line_first=>" AREA:VALM1#00FF00:\'_item_\' ",
      line_rest=>" AREA:VALM_N_#_color_:\'_item_\' ",
		comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

		colors => [VERDE, AZUL, ROJO, NARANJA, OCRE, GRIS]
   },


	AREA => { 
		
		base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_  -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS  --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0" , 
		def=>" DEF:VAL_N_=_rrd_file_:value_N_:AVERAGE", 
		cdef=>" CDEF:VALM_N_=VAL_N_", 
		line_first=>" AREA:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.1lf%s \\n\"", 
		line_rest=>" AREA:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.1lf%s \\n\"",
		comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

		colors => [VERDE, AZUL, FUXIA, NARANJA, OCRE, GRIS]
	},

	AREA1 => { 
		
		base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_  -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0", 
		def=>" DEF:VAL_N_=_rrd_file_:value_N_:AVERAGE", 
		cdef=>" CDEF:VALM_N_=VAL_N_", 
		line_first=>" AREA:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.1lf%s \\n\"", 
		line_rest=>" LINE1:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.1lf%s \\n\"",
		comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

		colors => [VERDE, AZUL, FUXIA, NARANJA, OCRE, GRIS]
	},

	AREA2 => { 
		
		base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_  -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0", 
		def=>" DEF:VAL_N_=_rrd_file_:value_N_:AVERAGE", 
		cdef=>" CDEF:VALM_N_=VAL_N_", 
		line_first=>" AREA:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.1lf%s \\n\"", 
		line_rest=>" LINE2:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.1lf%s \\n\"",
		comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

		colors => [VERDE, AZUL, FUXIA, NARANJA, OCRE, GRIS]

	},

	AREA3 => { 
		
		base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_  -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS --font $Metrics::FONT_UNIT --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0", 
		def=>" DEF:VAL_N_=_rrd_file_:value_N_:AVERAGE", 
		cdef=>" CDEF:VALM_N_=VAL_N_", 
		line_first=>" AREA:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.1lf%s \\n\"", 
		line_rest=>" LINE3:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.1lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.1lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.1lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.1lf%s \\n\"",
		comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

		colors => [VERDE, AZUL, ROJO, NARANJA, OCRE, GRIS]

	},


	STACK => { 
		
		base=>"$graph_cmd -  --start _start_ --end _end_ -h _heigth_  -w _width_ --interlaced --font $Metrics::FONT_TITLE --font $Metrics::FONT_LEGEND --font $Metrics::FONT_AXIS --font $Metrics::FONT_UNIT  --title \"_title_\"  --vertical-label \"_vlabel_\" --lower-limit 0", 
		def=>" DEF:VAL_N_=_rrd_file_:value_N_:AVERAGE", 
		cdef=>" CDEF:VALM_N_=VAL_N_", 
		line_first=>" AREA:VALM1#_color_:\'_item_\' GPRINT:VALM1:MAX:\"MAX=%3.2lf%s\" GPRINT:VALM1:MIN:\"MIN=%3.2lf%s\" GPRINT:VALM1:AVERAGE:\"AVG=%3.2lf%s\" GPRINT:VALM1:LAST:\"LAST=%3.2lf%s \l\"", 
		line_rest=>" STACK:VALM_N_#_color_:\'_item_\' GPRINT:VALM_N_:MAX:\"MAX=%3.2lf%s\" GPRINT:VALM_N_:MIN:\"MIN=%3.2lf%s\" GPRINT:VALM_N_:AVERAGE:\"AVG=%3.2lf%s\" GPRINT:VALM_N_:LAST:\"LAST=%3.2lf%s \l\"",
		comment=>" COMMENT:\"\\n\"  COMMENT:\"_COMMENT_ \\c\"",

		colors => [VERDE, AZUL, FUXIA, NARANJA, OCRE, GRIS]
	},




   #RAD_USERS => { vlabel=>'%', base=>$BASE, base_extra=>$BASE_EXTRA_1, def=>$DEF_BASE, cdef=>$CDEF_NONE, line_first=>$AREA_FIRST, line_rest=>$LINE1_REST },

);
#----------------------------------------------------------------------------


1;
__END__


