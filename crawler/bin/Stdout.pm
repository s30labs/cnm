#####################################################################################################
# Fichero: (Stdout.pm) $Id$
# Fecha: 15/08/2001
# Revision: Ver $VERSION
# Descripcion: Formatea de diferentes formas la salida standard
#####################################################################################################
package Stdout;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);

require Exporter;

@EXPORT_OK = qw( dumph2xml dumph2json dump2xml json2xml);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);
$VERSION = '1.00';

use JSON;

#------------------------------------------------------------------------------
# FORMATO JSON -----------------------------------------------------------------
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# $all_data:	HASH de hashes con los datos (clave=>valor)
# $col_map:    ARRAY de hashes con la info de formato
#
#	my @COL_MAP = (
#   	{'label'=>'ID', 'width'=>'4' , 'name_col'=>'id_dev',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter', ,'hidden'=>'true' },
#   	{'label'=>'NOMBRE', 'width'=>'10' , 'name_col'=>'name',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
#   	{'label'=>'DOMINIO', 'width'=>'10' , 'name_col'=>'domain',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
#   	{'label'=>'IP', 'width'=>'10' , 'name_col'=>'ip',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
#	);
#
#------------------------------------------------------------------------------
sub json2xml {
my ($all_data,$jcol_map,$timedate)=@_;


	my $col_map = decode_json($jcol_map);

   my $rows='';
   my $H1='<?xml version="1.0" ?>'."\n".'<rows>'."\n";
   my $id=0;
   foreach my $ip (keys %$all_data) {

      my $lines=decode_json($all_data->{$ip});

#[{"id_dev":"10","name":"'a'b'c\\'","domain":"?a?b?c&a&b&c","ip":"1.1.1.1","sysloc":"Valor no obtenido","sysdesc":"Valor no obtenido","sysoid":"Valor no obtenido","type":"Embebido","status":"2","pass":"-","usuario":"-"},  { }]
		foreach my $hline (@$lines) {

	      $rows.="<row id=\"$id\"><cell>$timedate</cell><cell>$ip</cell>";
   	   foreach my $col (@$col_map) {
				my $name_col = $col->{'name_col'};
				my $value = '-';
      	   if (exists $hline->{$name_col}) {  $value = $hline->{$name_col}; }
         	$rows.='<cell><![CDATA['. $value . ']]></cell>';
      	}
      	$rows.="</row>\n";
      	$id+=1;
		}
   }

   my $HEAD="<head>\n<column type=\"ro\" width=\"20\" sort=\"text\" align=\"left\">Fecha</column><column type=\"ro\" width=\"15\" sort=\"ipaddr\" align=\"left\">IP</column>\n";

   foreach my $col (@$col_map) {
      $HEAD .= '<column type="ro" width="'.$col->{'width'}.'" sort="'.$col->{'sort'}.'" align="'.$col->{'align'}.'">'.$col->{'label'}.'</column>'."\n";
   }
   $HEAD .= '<settings><colwidth>%</colwidth></settings><beforeInit><call command="setSkin"><param>light</param></call><call command="enableMultiline"><param>true</param></call></beforeInit><afterInit><call command="attachHeader"><param>#text_filter,#text_filter,';
   my @filters=();
   foreach my $col (@$col_map) { push @filters, $col->{'filter'}; }
   $HEAD .= join (',', @filters);
   $HEAD .= "</param></call></afterInit>\n</head>\n</rows>\n";

	return $H1.$rows.$HEAD;
}

#------------------------------------------------------------------------------
#         my @COL_KEYS = (
#            {'name_col'=>'descr', 'width'=>'60', 'sort'=>'str', 'align'=>'left', 'filter'=>'#text_filter'},
#         );
#
#         my %COL_MAP=('descr'=>'Description');
#
#
#         my $ts=time;
#         my $TIMEDATE=$self->time2date($ts);
#
#         my %results_vector=();
#         my %line=('descr'=>$stdout);
#         $results_vector{$ip}=[\%line];
#
#         my $xml = dumph2xml(\@COL_KEYS, \%COL_MAP, \%results_vector, $TIMEDATE);
#         print "$xml\n";
#[{"admin":"1","lastc":"0:0:00:00.00","trape":"-","promisc":"-","physadd":"\"\"","descr":"\"lo\"","conn":"-","oper":"1","speed":"10000000","id":"1","type":"24","mtu":"16436"},{"admin":"1","lastc":"0:0:00:00.00","trape":"-","promisc":"-","physadd":"\"C6 8A 28 D0 8D 30 \"","descr":"\"eth0\"","conn":"-","oper":"1","speed":"1000000000","id":"2","type":"6","mtu":"1500"}]
#
#[{"width":"8","sort":"str","align":"left","name_col":"id","filter":"#text_filter","label":"Idx"},{"width":"15","sort":"str","align":"left","name_col":"descr","filter":"#text_filter","label":"Description"},{"width":"5","sort":"str","align":"left","name_col":"type","filter":"#select_filter","label":"Type"},{"width":"8","sort":"str","align":"left","name_col":"mtu","filter":"#text_filter","label":"MTU"},{"width":"10","sort":"str","align":"left","name_col":"speed","filter":"#select_filter","label":"Speed"},{"width":"20","sort":"str","align":"left","name_col":"physadd","filter":"#select_filter","label":"PhysAddress"},{"width":"10","sort":"str","align":"left","name_col":"admin","filter":"#text_filter","label":"AdminStatus"},{"width":"10","sort":"str","align":"left","name_col":"oper","filter":"#text_filter","label":"OperStatus"},{"width":"10","sort":"str","align":"left","name_col":"lastc","filter":"#text_filter","label":"LastChange"},{"width":"15","sort":"str","align":"left","name_col":"trape","filter":"#text_filter","label":"LinkUpDownTrapEnable"},{"width":"15","sort":"str","align":"left","name_col":"promisc","filter":"#text_filter","label":"PromiscuousMode"},{"width":"15","sort":"str","align":"left","name_col":"conn","filter":"#text_filter","label":"ConnectorPresent"}]
#
sub dumph2json {
my ($col_keys,$col_map,$line_data,$timedate)=@_;


   my $json =encode_json($line_data)."\n";

	$json .= encode_json($col_keys)."\n";

   return $json;
   #print encode('utf8', $xml);
}



#------------------------------------------------------------------------------
# FORMATO XML -----------------------------------------------------------------
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# $col_keys: 	ARRAY con las claves que representan las columnas. Tiene el orden de las mismas.
# $col_map: 	HASH con el mapeo clave -> titulo de columna (tema idioma)
#OLD $line_data:	ARRAY con los datos. Cada elemento es un HASH con los valores de los datos
#OLD $ip:			Valor de la IP que genera la linea
# $line_data:  ref a HASH cuya clave es la ip que genera los datos y el valor son los propios datos.
# $timedata:	Fecha/hora de la linea
# IMP !!! Si $timedata=0 ==> No se ponen las columnas de fecha,ip que van al principio
sub dumph2xml {
my ($col_keys,$col_map,$line_data,$timedate)=@_;


   my $start_counter=0;
   my $crow=0;

   my $xml ='<?xml version="1.0" ?>'."\n";

   # Se ponen las filas de datos
   $xml.='<rows>'."\n";

   # +1 del idx
   my $NCOLS=scalar(@$col_keys) + 1;

	# Filas de datos --------------------------------------------
	my @ips=keys(%$line_data);

  # for my $line ( @$line_data ) {
  	foreach my $ip (@ips) {
	   for my $line ( @{$line_data->{$ip}} ) {

	      $xml.="<row id=\"$crow\">";
   	   $crow+=1;

			if ($timedate ne '') {
	      	$xml.="<cell><![CDATA[$timedate]]></cell>";
		      $xml.="<cell><![CDATA[$ip]]></cell>";
			}

			foreach my $k (@$col_keys) {

				my $key=$k->{'name_col'};

				if (exists $line->{$key}) {
	         	$xml.="<cell><![CDATA[$line->{$key}]]></cell>";
				}
				else {
					$xml.="<cell>-</cell>";
      	   }
      	}

	      $xml.='</row>';
   	   $xml.="\n";
		}
   }

   # Se ponen las columnas de los titulos
   $xml.="\n";
   $xml.='<head>';
   $xml.="\n";
#fml poner 17/13 en width y rehacer todos los xmls

	if ($timedate ne '') {
   	$xml.="<column type=\"ro\" width=\"20\" sort=\"text\" align=\"left\">Fecha</column>";
   	$xml.="<column type=\"ro\" width=\"15\" sort=\"text\" align=\"left\">IP</column>";
   	$xml.="\n";
	}

   #for (my $i=$start_counter; $i<$NCOLS; $i++) {
   foreach my $key (@$col_keys) {

      #my $w=$col_map->{$key}->{'width'};
      #my $name=$col_map->{$key}->{'name_col'};
      #my $sort=$col_map->{$key}->{'sort'};
      #my $align=$col_map->{$key}->{'align'};
      my $w=$key->{'width'};
      my $name_key=$key->{'name_col'};
		my $name=$col_map->{$name_key};
      my $sort=$key->{'sort'};
      my $align=$key->{'align'};

      $w=~s/%//;
      $xml.="<column type=\"ro\" width=\"$w\" sort=\"$sort\" align=\"$align\">$name</column>";
      $xml.="\n";
   }

   # Resto de parametros de la tabla
   #Se indica que el tamano de las columnas viene dado en %
   $xml.='<settings>';
   $xml.='<colwidth>%</colwidth>';
   $xml.='</settings>';

   $xml.='<beforeInit>';
   #No se puede redimensionar la tabla
   #$xml.='<call command="enableResizing">';
   #$xml.='<param>false,false</param>';
   #$xml.='</call>';

   #Indicamos el estilo que va a tener la tabla
   $xml.='<call command="setSkin">';
   $xml.='<param>light</param>';
   $xml.='</call>';
	$xml.='<call command="enableMultiline"><param>true</param></call>';
   $xml.='</beforeInit>';

   $xml.='<afterInit>';
   $xml.='<call command="attachHeader">';
   my @filter=();
	if ($timedate ne '') {
	   push @filter,'#text_filter'; # Corresponde a la Fecha
   	push @filter,'#select_filter'; # Corresponde a la IP
	}
   #foreach my $h (@$col_map) {
   #   push @filter,$h->{filter};
	#}

   foreach my $key (@$col_keys) {
       #push @filter,$col_map->{$key}->{'width'};
       push @filter,$key->{'filter'};
	}

   $xml.='<param>'. join(',', @filter) .'</param>';
   $xml.='</call>';
   $xml.='</afterInit>';
   $xml.="\n";

   $xml.='</head>';
   $xml.="\n";

   $xml.='</rows>';

   return $xml;
   #print encode('utf8', $xml);
}


#------------------------------------------------------------------------------
# FORMATO XML -----------------------------------------------------------------
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# $columns: ARRAY con los nombre de las columnas
# $data:    ARRAY con los valores de los datos
# $ip:      Valor de la IP que genera la linea
# $timedata:   Fecha/hora de la linea
sub dump2xml {
my ($cols,$vector,$ip,$timedate)=@_;


   my $start_counter=0;
   my $crow=0;

   my $xml ='<?xml version="1.0" ?>'."\n";

   # Se ponen las filas de datos
   $xml.='<rows>'."\n";

   # +1 del idx
   my $NCOLS=scalar(@$cols) + 1;

   for my $line ( @$vector ) {

      #$xml.="<row id=\"$crow\" style='color:red'>";
      $xml.="<row id=\"$crow\">";
      $crow+=1;
      $xml.="<cell><![CDATA[$timedate]]></cell>";
      $xml.="<cell><![CDATA[$ip]]></cell>";
      for (my $i=$start_counter; $i<$NCOLS; $i++) {
         if ( (! defined $line->[$i]) || ($line->[$i] eq '') )  { $line->[$i] ='-';}
         $xml.="<cell><![CDATA[$line->[$i]]]></cell>";
      }
      $xml.='</row>';
      $xml.="\n";
   }

   # Se ponen las columnas de los titulos
   $xml.="\n";
   $xml.='<head>';
   $xml.="\n";
#fml poner 17/13 en width y rehacer todos los xmls
   $xml.="<column type=\"ro\" width=\"17\" sort=\"text\" align=\"left\">Fecha</column>";
   $xml.="<column type=\"ro\" width=\"13\" sort=\"text\" align=\"left\">IP</column>";
   $xml.="\n";

   #for (my $i=$start_counter; $i<$NCOLS; $i++) {
   foreach my $h (@$cols) {

      my $w=$h->{width};
      my $name=$h->{name_col};
      my $sort=$h->{sort};
      my $align=$h->{align};

      $w=~s/%//;
      $xml.="<column type=\"ro\" width=\"$w\" sort=\"$sort\" align=\"$align\">$name</column>";
      $xml.="\n";
   }


   # Resto de parametros de la tabla
   #Se indica que el tamano de las columnas viene dado en %
   $xml.='<settings>';
   $xml.='<colwidth>%</colwidth>';
   $xml.='</settings>';

   $xml.='<beforeInit>';
   #No se puede redimensionar la tabla
   #$xml.='<call command="enableResizing">';
   #$xml.='<param>false,false</param>';
   #$xml.='</call>';

   #Indicamos el estilo que va a tener la tabla
   $xml.='<call command="setSkin">';
   $xml.='<param>light</param>';
   $xml.='</call>';
   $xml.='<call command="enableMultiline"><param>true</param></call>';
   $xml.='</beforeInit>';

   $xml.='<afterInit>';
   $xml.='<call command="attachHeader">';
   my @filter=();
   push @filter,'#text_filter'; # Corresponde a la Fecha
   push @filter,'#select_filter'; # Corresponde a la IP
   foreach my $h (@$cols) {
      push @filter,$h->{filter};
   }

   $xml.='<param>'. join(',', @filter) .'</param>';
   $xml.='</call>';
   $xml.='</afterInit>';
   $xml.="\n";

   $xml.='</head>';
   $xml.="\n";

   $xml.='</rows>';

   return $xml;
   #print encode('utf8', $xml);
}



1;
__END__


