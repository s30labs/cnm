use ExportExcel;
package ExportExcel::Report;
@ISA=qw(ExportExcel);

#------------------------------------------------------------------------
use strict;
use Data::Dumper;


#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo ExportExcel::Report
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

	my $self=$class->SUPER::new(%arg);
   $self->{_type} = $arg{type} || '';

   return $self;
}

#----------------------------------------------------------------------------
# type
#----------------------------------------------------------------------------
sub type {
my ($self,$type) = @_;
   if (defined $type) {
      $self->{_type}=$type;
   }
   else { return $self->{_type}; }
}


#----------------------------------------------------------------------------
# report010
#----------------------------------------------------------------------------
sub report010 {
my ($self,$params) = @_;

   my $file = $self->filename();
   print "Generando report010 ($file) ...\n";

   my $xlsx = ExportExcel->new('filename'=>$file);


   my $sheet = $params->{'sheet'} || 'Data';
   my $chart_title = $params->{'chart_title'};
   my $chart_data = $params->{'chart_data'};
	my $alert_threshold = (exists $params->{'alert_threshold'}) ? $params->{'alert_threshold'} : undef;

	#/opt/cnm/crawler/bin/ExportExcel/cnm_logo_report.gif
   my $image_header='';
   if ((exists $params->{'image_header'}) && (-f $params->{'image_header'})) { $image_header=$params->{'image_header'}; }

   $xlsx->create_workbook();
   my $series = $xlsx->data_sheet(	
			$params->{'table'},
			{ 'sheet'=>$sheet, 'image_header'=>$image_header, 'col0_width'=>50, 'col1n_width'=>6, 'hide_gridlines'=>'2', 'landscape'=>'1', 'alert_threshold'=>$alert_threshold }
	);

#print "****SERIES*****\n";
#print Dumper($series);

	# area, bar, column, line, pie, doughnut, scatter, stock, radar
   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series,
      'tpl' =>  [ {'position'=>'B1', 'chart_type'=>'bar', 'chart_width'=>'800', 'chart_height'=>'800',  'landscape'=>'1', 'chart_title'=>$params->{'chart_title'},  'xname'=>$params->{'xname'}, 'yname'=>$params->{'yname'}, 'chart_data'=>$params->{'chart_data'}} ]
   });

   $xlsx->close_workbook();

}



#----------------------------------------------------------------------------
# report001
#----------------------------------------------------------------------------
sub report001 {
my ($self,$table) = @_;

   print "Generando report001 (xlsx) ...\n";

   my $file = $self->filename();
   my $xlsx = ExportExcel->new('filename'=>$file);

   $xlsx->create_workbook();
   my $series = $xlsx->data_sheet($table,{'sheet'=>'MisDatos'});

print "****SERIES*****\n";
print Dumper($series);

   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series,
      'tpl' =>  [ {'position'=>'B1', 'chart_type'=>'bar', 'chart_width'=>'800', 'chart_height'=>'800',  'chart_title'=>'Meses 3 y 4', 'chart_data'=>['03','04']} ]
   });

   $xlsx->close_workbook();
}




#----------------------------------------------------------------------------
# report002
# Nombre/s del libro/s con los datos
# Nombre/s del libro/s con los datos
# Por grafico:
# 	position
#	chart_type line,column,bar 
#----------------------------------------------------------------------------
sub report002 {
my ($self,$table_by_day,$table_by_week) = @_;

   print "Generando report002 (xlsx) ...\n";

   my $file = $self->filename();
   my $xlsx = ExportExcel->new('filename'=>$file);

   $xlsx->create_workbook();

   my $series_day = $xlsx->data_sheet($table_by_day,{'sheet'=>'Datos por Dia'});

print "****SERIES Datos por Dia*****\n";
print Dumper($series_day);

   my $series_week = $xlsx->data_sheet($table_by_week,{'sheet'=>'Datos por Semana'});

print "****SERIES Datos por Semana*****\n";
print Dumper($series_week);

   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series_day,
      'tpl' =>  [ 
				{'position'=>'B2', 'chart_type'=>'line', 'chart_width'=>'800', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios diarios por SO', 'chart_data'=>['Microsoft Windows 7 Enterprise-avg','Microsoft Windows 10 Enterprise-avg']} ,
				{'position'=>'B18', 'chart_type'=>'column', 'chart_width'=>'800', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen diario por SO', 'chart_data'=>['Microsoft Windows 7 Enterprise-sum_cnt','Microsoft Windows 10 Enterprise-sum_cnt']} 
			]
   });

   $xlsx->dashboard_create ({
      'sheet' => 'Report1',
      'series' => $series_week,
      'tpl' =>  [
            {'position'=>'B2', 'chart_type'=>'line', 'chart_width'=>'800', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios semanales  por SO', 'chart_data'=>['Microsoft Windows 7 Enterprise-avg','Microsoft Windows 10 Enterprise-avg']} ,
            {'position'=>'B18', 'chart_type'=>'column', 'chart_width'=>'800', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen semanalpor SO', 'chart_data'=>['Microsoft Windows 7 Enterprise-sum_cnt','Microsoft Windows 10 Enterprise-sum_cnt']}
         ]
   });


   $xlsx->close_workbook();

}


#----------------------------------------------------------------------------
# report003
# Nombre/s del libro/s con los datos
# Nombre/s del libro/s con los datos
# Por grafico:
#  position
#  chart_type line,column,bar
#  {'hour'=>{'data'=>$TABLE_BY_HOUR, 'sheet'=>'FichaCliente-PorHora' } , 'day'=>{'data'=>$TABLE_BY_DAY, 'sheet'=>'FichaCliente-PorDia' }, 'week'=>{'data'=> $TABLE_BY_WEEK, 'sheet'=>'FichaCliente-PorSemana' }}
#----------------------------------------------------------------------------
sub report003 {
my ($self,$params) = @_;

   my $file = $self->filename();
   print "Generando report003 ($file) ...\n";
   my $xlsx = ExportExcel->new('filename'=>$file);

   $xlsx->create_workbook();

   my $series_hour = $xlsx->data_sheet($params->{'hour'}->{'data'},{'sheet'=>$params->{'hour'}->{'sheet'}});
   my $series_day = $xlsx->data_sheet($params->{'day'}->{'data'},{'sheet'=>$params->{'day'}->{'sheet'}});
   my $series_week = $xlsx->data_sheet($params->{'week'}->{'data'},{'sheet'=>$params->{'week'}->{'sheet'}});

print "****SERIES Datos por Hora*****\n";
print Dumper($series_hour);
print "****SERIES Datos por Dia*****\n";
print Dumper($series_day);
print "****SERIES Datos por Semana*****\n";
print Dumper($series_week);



   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series_day,
      'tpl' =>  [
            {'position'=>'B2', 'chart_type'=>'line', 'chart_width'=>'650', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios diarios por SO', 'chart_data'=>['Microsoft Windows 7 Enterprise - Valor medio','Microsoft Windows 10 Enterprise - Valor medio']} ,
            {'position'=>'B18', 'chart_type'=>'column', 'chart_width'=>'650', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen diario por SO', 'chart_data'=>['Microsoft Windows 7 Enterprise - Volumen','Microsoft Windows 10 Enterprise - Volumen']}
         ]
   });


   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series_week,
      'tpl' =>  [
            {'position'=>'M2', 'chart_type'=>'line', 'chart_width'=>'400', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios semanales por SO', 'chart_data'=>['Microsoft Windows 7 Enterprise - Valor medio','Microsoft Windows 10 Enterprise - Valor medio']} ,
            {'position'=>'M18', 'chart_type'=>'column', 'chart_width'=>'400', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen semanal por SO', 'chart_data'=>['Microsoft Windows 7 Enterprise - Volumen','Microsoft Windows 10 Enterprise - Volumen']}
         ]
   });


   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series_hour,
      'tpl' =>  [
            {'position'=>'B34', 'chart_type'=>'line', 'chart_width'=>'1100', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios por hora por SO', 'chart_data'=>['Microsoft Windows 7 Enterprise - Valor medio','Microsoft Windows 10 Enterprise - Valor medio']} ,
            {'position'=>'B50', 'chart_type'=>'column', 'chart_width'=>'1100', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen por hora por SO', 'chart_data'=>['Microsoft Windows 7 Enterprise - Volumen','Microsoft Windows 10 Enterprise - Volumen']}
         ]
   });


   $xlsx->close_workbook();

}


#----------------------------------------------------------------------------
# report004
# Nombre/s del libro/s con los datos
# Nombre/s del libro/s con los datos
# Por grafico:
#  position
#  chart_type line,column,bar
#----------------------------------------------------------------------------
sub report004 {
my ($self,$params) = @_;

   my $file = $self->filename();
   print "Generando report004 ($file) ...\n";
   my $xlsx = ExportExcel->new('filename'=>$file);

   $xlsx->create_workbook();

   my $series_hour = $xlsx->data_sheet($params->{'hour'}->{'data'},{'sheet'=>$params->{'hour'}->{'sheet'}});
   my $series_day = $xlsx->data_sheet($params->{'day'}->{'data'},{'sheet'=>$params->{'day'}->{'sheet'}});
   my $series_week = $xlsx->data_sheet($params->{'week'}->{'data'},{'sheet'=>$params->{'week'}->{'sheet'}});

print "****SERIES Datos por Hora*****\n";
print Dumper($series_hour);
print "****SERIES Datos por Dia*****\n";
print Dumper($series_day);
print "****SERIES Datos por Semana*****\n";
print Dumper($series_week);



   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series_day,
      'tpl' =>  [
            {'position'=>'B2', 'chart_type'=>'line', 'chart_width'=>'650', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios diarios por Region', 'chart_data'=>[ 'Cantabria - Valor medio', 'Islas Baleares - Valor medio', 'Islas Canarias - Valor medio', 'Aragon - Valor medio', 'La Rioja - Valor medio', 'Catalu?a - Valor medio', 'Asturias - Valor medio', 'Pais Vasco - Valor medio', 'Murcia - Valor medio', 'Castilla Leon - Valor medio', 'Castilla La Mancha - Valor medio', 'Comunidad Valenciana - Valor medio', 'Extremadura - Valor medio', 'Madrid - Valor medio', 'Navarra - Valor medio', 'Galicia - Valor medio', 'Andalucia - Valor medio', 'Ceuta - Valor medio' ]} ,
            {'position'=>'B18', 'chart_type'=>'column', 'chart_width'=>'650', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen diario por Region', 'chart_data'=>[ 'Cantabria - Volumen', 'Islas Baleares - Volumen', 'Islas Canarias - Volumen', 'Aragon - Volumen', 'La Rioja - Volumen', 'Catalu?a - Volumen', 'Asturias - Volumen', 'Pais Vasco - Volumen', 'Murcia - Volumen', 'Castilla Leon - Volumen', 'Castilla La Mancha - Volumen', 'Comunidad Valenciana - Volumen', 'Extremadura - Volumen', 'Madrid - Volumen', 'Navarra - Volumen', 'Galicia - Volumen', 'Andalucia - Volumen', 'Ceuta - Volumen' ]}
         ]
   });


   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series_week,
      'tpl' =>  [
            {'position'=>'M2', 'chart_type'=>'line', 'chart_width'=>'400', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios semanales por Region', 'chart_data'=>[ 'Cantabria - Valor medio', 'Islas Baleares - Valor medio', 'Islas Canarias - Valor medio', 'Aragon - Valor medio', 'La Rioja - Valor medio', 'Catalu?a - Valor medio', 'Asturias - Valor medio', 'Pais Vasco - Valor medio', 'Murcia - Valor medio', 'Castilla Leon - Valor medio', 'Castilla La Mancha - Valor medio', 'Comunidad Valenciana - Valor medio', 'Extremadura - Valor medio', 'Madrid - Valor medio', 'Navarra - Valor medio', 'Galicia - Valor medio', 'Andalucia - Valor medio', 'Ceuta - Valor medio' ]} ,
            {'position'=>'M18', 'chart_type'=>'column', 'chart_width'=>'400', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen semanal por Region', 'chart_data'=>[ 'Cantabria - Volumen', 'Islas Baleares - Volumen', 'Islas Canarias - Volumen', 'Aragon - Volumen', 'La Rioja - Volumen', 'Catalu?a - Volumen', 'Asturias - Volumen', 'Pais Vasco - Volumen', 'Murcia - Volumen', 'Castilla Leon - Volumen', 'Castilla La Mancha - Volumen', 'Comunidad Valenciana - Volumen', 'Extremadura - Volumen', 'Madrid - Volumen', 'Navarra - Volumen', 'Galicia - Volumen', 'Andalucia - Volumen', 'Ceuta - Volumen' ]}
			]
   });


   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series_hour,
      'tpl' =>  [
            {'position'=>'B34', 'chart_type'=>'line', 'chart_width'=>'1100', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios por hora por Region', 'chart_data'=>[ 'Cantabria - Valor medio', 'Islas Baleares - Valor medio', 'Islas Canarias - Valor medio', 'Aragon - Valor medio', 'La Rioja - Valor medio', 'Catalu?a - Valor medio', 'Asturias - Valor medio', 'Pais Vasco - Valor medio', 'Murcia - Valor medio', 'Castilla Leon - Valor medio', 'Castilla La Mancha - Valor medio', 'Comunidad Valenciana - Valor medio', 'Extremadura - Valor medio', 'Madrid - Valor medio', 'Navarra - Valor medio', 'Galicia - Valor medio', 'Andalucia - Valor medio', 'Ceuta - Valor medio' ]} ,
            {'position'=>'B50', 'chart_type'=>'column', 'chart_width'=>'1100', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen por hora por Region', 'chart_data'=>[ 'Cantabria - Volumen', 'Islas Baleares - Volumen', 'Islas Canarias - Volumen', 'Aragon - Volumen', 'La Rioja - Volumen', 'Catalu?a - Volumen', 'Asturias - Volumen', 'Pais Vasco - Volumen', 'Murcia - Volumen', 'Castilla Leon - Volumen', 'Castilla La Mancha - Volumen', 'Comunidad Valenciana - Volumen', 'Extremadura - Volumen', 'Madrid - Volumen', 'Navarra - Volumen', 'Galicia - Volumen', 'Andalucia - Volumen', 'Ceuta - Volumen' ]}




         ]
   });


   $xlsx->close_workbook();

}


#----------------------------------------------------------------------------
# report005
# Nombre/s del libro/s con los datos
# Nombre/s del libro/s con los datos
# Por grafico:
#  position
#  chart_type line,column,bar
#----------------------------------------------------------------------------
sub report005 {
my ($self,$params) = @_;

   my $file = $self->filename();
   print "Generando report005 ($file) ...\n";
   my $xlsx = ExportExcel->new('filename'=>$file);

   $xlsx->create_workbook();

   my $series_hour = $xlsx->data_sheet($params->{'hour'}->{'data'},{'sheet'=>$params->{'hour'}->{'sheet'}});
   my $series_day = $xlsx->data_sheet($params->{'day'}->{'data'},{'sheet'=>$params->{'day'}->{'sheet'}});
   my $series_week = $xlsx->data_sheet($params->{'week'}->{'data'},{'sheet'=>$params->{'week'}->{'sheet'}});

print "****SERIES Datos por Hora*****\n";
print Dumper($series_hour);
print "****SERIES Datos por Dia*****\n";
print Dumper($series_day);
print "****SERIES Datos por Semana*****\n";
print Dumper($series_week);


   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series_day,
      'tpl' =>  [
            {'position'=>'B2', 'chart_type'=>'line', 'chart_width'=>'650', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios diarios por Modelo', 'chart_data'=>[ 'HP Elite x2 1012 G1 - Valor medio', '10A8S3UN00 - Valor medio', '10A8S0PX00 - Valor medio', 'HP ProBook 640 G1 - Valor medio', 'HP Compaq Elite 8300 SFF - Valor medio' ]} ,
            {'position'=>'B18', 'chart_type'=>'column', 'chart_width'=>'650', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen diario por Modelo', 'chart_data'=>[ 'HP Elite x2 1012 G1 - Volumen', '10A8S3UN00 - Volumen', '10A8S0PX00 - Volumen', 'HP ProBook 640 G1 - Volumen', 'HP Compaq Elite 8300 SFF - Volumen' ]}
         ]
   });


   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series_week,
      'tpl' =>  [
            {'position'=>'M2', 'chart_type'=>'line', 'chart_width'=>'400', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios semanales por Modelo', 'chart_data'=>[ 'HP Elite x2 1012 G1 - Valor medio', '10A8S3UN00 - Valor medio', '10A8S0PX00 - Valor medio', 'HP ProBook 640 G1 - Valor medio', 'HP Compaq Elite 8300 SFF - Valor medio' ]} ,
            {'position'=>'M18', 'chart_type'=>'column', 'chart_width'=>'400', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen semanal por Modelo', 'chart_data'=>[ 'HP Elite x2 1012 G1 - Volumen', '10A8S3UN00 - Volumen', '10A8S0PX00 - Volumen', 'HP ProBook 640 G1 - Volumen', 'HP Compaq Elite 8300 SFF - Volumen' ]}
         ]
   });


   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series_hour,
      'tpl' =>  [
            {'position'=>'B34', 'chart_type'=>'line', 'chart_width'=>'1100', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios por hora por Modelo', 'chart_data'=>[ 'HP Elite x2 1012 G1 - Valor medio', '10A8S3UN00 - Valor medio', '10A8S0PX00 - Valor medio', 'HP ProBook 640 G1 - Valor medio', 'HP Compaq Elite 8300 SFF - Valor medio' ]} ,
            {'position'=>'B50', 'chart_type'=>'column', 'chart_width'=>'1100', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen por hora por Modelo', 'chart_data'=>[ 'HP Elite x2 1012 G1 - Volumen', '10A8S3UN00 - Volumen', '10A8S0PX00 - Volumen', 'HP ProBook 640 G1 - Volumen', 'HP Compaq Elite 8300 SFF - Volumen' ]}

         ]
   });


   $xlsx->close_workbook();

}



#----------------------------------------------------------------------------
# report006
# Nombre/s del libro/s con los datos
# Nombre/s del libro/s con los datos
# Por grafico:
#  position
#  chart_type line,column,bar
#----------------------------------------------------------------------------
sub report006 {
my ($self,$params) = @_;

   my $file = $self->filename();
   print "Generando report006 ($file) ...\n";
   my $xlsx = ExportExcel->new('filename'=>$file);

   $xlsx->create_workbook();

   my $series_hour = $xlsx->data_sheet($params->{'hour'}->{'data'},{'sheet'=>$params->{'hour'}->{'sheet'}});
   my $series_day = $xlsx->data_sheet($params->{'day'}->{'data'},{'sheet'=>$params->{'day'}->{'sheet'}});
   my $series_week = $xlsx->data_sheet($params->{'week'}->{'data'},{'sheet'=>$params->{'week'}->{'sheet'}});

print "****SERIES Datos por Hora*****\n";
print Dumper($series_hour);
print "****SERIES Datos por Dia*****\n";
print Dumper($series_day);
print "****SERIES Datos por Semana*****\n";
print Dumper($series_week);


   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series_day,
      'tpl' =>  [
            {'position'=>'B2', 'chart_type'=>'line', 'chart_width'=>'650', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios diarios por Linea de Comunicaciones', 'chart_data'=>[ 'FTTH - Valor medio', 'ADSL - Valor medio', 'MACROLAN - Valor medio' ]} ,
            {'position'=>'B18', 'chart_type'=>'column', 'chart_width'=>'650', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen diario por Linea de Comunicaciones', 'chart_data'=>[ 'FTTH - Volumen', 'ADSL - Volumen', 'MACROLAN - Volumen' ]}
         ]
   });


   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series_week,
      'tpl' =>  [
            {'position'=>'M2', 'chart_type'=>'line', 'chart_width'=>'400', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios semanales por Linea de Comunicaciones', 'chart_data'=>[ 'FTTH - Valor medio', 'ADSL - Valor medio', 'MACROLAN - Valor medio' ]} ,
            {'position'=>'M18', 'chart_type'=>'column', 'chart_width'=>'400', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen semanal por Linea de Comunicaciones', 'chart_data'=>[ 'FTTH - Volumen', 'ADSL - Volumen', 'MACROLAN - Volumen' ]}

         ]
   });


   $xlsx->dashboard_create ({
      'sheet' => 'Report',
      'series' => $series_hour,
      'tpl' =>  [
            {'position'=>'B34', 'chart_type'=>'line', 'chart_width'=>'1100', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Tiempos medios por hora por Linea de Comunicaciones', 'chart_data'=>[ 'FTTH - Valor medio', 'ADSL - Valor medio', 'MACROLAN - Valor medio' ]} ,
            {'position'=>'B50', 'chart_type'=>'column', 'chart_width'=>'1100', 'chart_height'=>'300',  'chart_title'=>'Actividad Ficha Cliente - Volumen por hora por Linea de Comunicaciones', 'chart_data'=>[ 'FTTH - Volumen', 'ADSL - Volumen', 'MACROLAN - Volumen' ]}
         ]
   });


   $xlsx->close_workbook();

}





1;
__END__


