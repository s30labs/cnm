use DataBox;
package DataBox::Metric;
@ISA=qw(DataBox);

#------------------------------------------------------------------------
use strict;
use Data::Dumper;
#------------------------------------------------------------------------
use Date::Calc qw( Week_of_Year );
use JSON;
use Data::Dumper;


#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo ExportExcel::Report
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_filter_by_date} = $arg{filter_by_date} || 0;

   return $self;
}

#----------------------------------------------------------------------------
# filter_by_date
#----------------------------------------------------------------------------
sub filter_by_date {
my ($self,$filter_by_date) = @_;
   if (defined $filter_by_date) {
      $self->{_filter_by_date}=$filter_by_date;
   }
   else { return $self->{_filter_by_date}; }
}


#-----------------------------------------------------------------------
# refactor (Hacia arriba ej. metrica -> host)
#-----------------------------------------------------------------------
# Consolida los datos de entrada en series diarias, semanales, mensuales ...
# IN. Parametros de entrada:
#  El atributo series_data
#  El atributo series_metadata. Hash k=>v
#     'key_tag' => 'Nombre',
#     'timeframe_tag'=>'Fecha_Hora',
#     'metric_tag'=>'Metrica',
#     'avg_tag'=>'v1',
#     'attribute_tags'=>['Nombre','Tipo']}
#
# $DATA{'device'}->$DATA{'metric'}->{'timeframe'}->{atrib}->{sum_rows}
# $DATA{'device'}->$DATA{'metric'}->{'timeframe'}->{atrib}->{sum_cnt}
# $DATA{'device'}->$DATA{'metric'}->{'timeframe'}->{atrib}->{sum_avg}
#
# OUT.
# {'by_day'=>{}, 'by_week'=>{}, 'by_month'=>{}, 'by_quarter'=>{}, 'by_year'=>{} }
# Por ejemplo:
#   'by_month' => {
#      'metrica001' => {
#               'data' => {
#                     '03' => {
#                           'sum_avg' => '51664125952',
#                           'avg' => '3229007872',
#                           'sum_cnt' => 16,
#                           'sum_rows' => 16
#                      },
#                      '04' => {
#                           'sum_avg' => '71038173184',
#                           'avg' => '3229007872',
#                           'sum_cnt' => 22,
#                           'sum_rows' => 22
#                      }
#                },
#                'metadata' => {
#                      'Nombre' => 'host03',
#                      'Tipo' => 'Servidor Virtual'
#                }
#      },
#      'metrica002' => { ... },
#      'metrica003' => { ... },
#      .....,
#      'metrica00N' => { ... },
#   }
#-----------------------------------------------------------------------
sub refactor {
my ($self)=@_;

   my $data = $self->series_data();
   my $metadata = $self->series_metadata();


#          {
#              'Nombre' => 'lincesqlitsip03',
#              'v1' => '1.7179344896e+10',
#              'Fecha_Hora' => '2017/04/18 02:00:00',
#              'Tipo' => 'Servidor Virtual'
#          },

   my %OUTDATA = ( 'by_hour'=>{}, 'by_day'=>{}, 'by_week'=>{}, 'by_month'=>{}, 'by_3m'=>{},  'by_4m'=>{}, 'by_year'=>{} );
   my $key_tag = $metadata->{'key_tag'};                 # Debe ser 'Nombre'
   my $timeframe_tag = $metadata->{'timeframe_tag'};     # Debe ser 'Fecha_Hora'
   my $metric_tag = $metadata->{'metric_tag'};           # Debe ser 'USO DE DISCO ....'
   my $avg_tag = $metadata->{'avg_tag'};                 # Debe ser 'v1'
   my $cnt_tag = (exists $metadata->{'cnt_tag'}) ? $metadata->{'cnt_tag'} : 1;                  # Solo si existe un campo con el contador de ocurrencias en linea.
   my $attribute_tags = $metadata->{'attribute_tags'};   # Array con los atributos a considerar. En este caso ['Tipo']


   # FASE 2 -> Se consolida
   # -----------------------------------------------------------------
   my %BY_HOUR=('data'=>{}, 'metadata'=>{});
   my %BY_DAY=('data'=>{}, 'metadata'=>{});
   my %BY_WEEK=('data'=>{}, 'metadata'=>{});
   my %BY_MONTH=('data'=>{}, 'metadata'=>{});
   my %BY_QUARTER=('data'=>{}, 'metadata'=>{});
   my %BY_YEAR=('data'=>{}, 'metadata'=>{});

   my %ATTR = ();
   foreach my $x (@$data) {


      my $key = $x->{$key_tag};
      my $metric = $x->{$metric_tag};
      my $avg = $x->{$avg_tag};
      my $cnt = (exists $x->{$cnt_tag}) ? $x->{$cnt_tag} : 1 ;

      # Se pasa a timeframe excel => "$y-$m-$d".'T'
      my ($d,$m,$y,$timeframe) = $self->normalize_timeframe($x->{$timeframe_tag});


print "$timeframe-$key -$metric-$avg-$cnt---($m,$d,$y)\n";

      foreach my $a (@$attribute_tags) {
         $BY_HOUR{$metric}->{'metadata'}->{$a} = $x->{$a};
         $BY_DAY{$metric}->{'metadata'}->{$a} = $x->{$a};
         $BY_WEEK{$metric}->{'metadata'}->{$a} = $x->{$a};
         $BY_MONTH{$metric}->{'metadata'}->{$a} = $x->{$a};
         $BY_QUARTER{$metric}->{'metadata'}->{$a} = $x->{$a};
         $BY_YEAR{$metric}->{'metadata'}->{$a} = $x->{$a};
      }

      #-----------------------------------------------------------------
      #$BY_HOUR{'device'}->{'metric'}->{'timeframe'}->{atrib}->{sum_cnt}
      if (exists $BY_HOUR{$metric}->{'data'}->{$timeframe}) {
         $BY_HOUR{$metric}->{'data'}->{$timeframe}->{sum_rows} += 1;
         $BY_HOUR{$metric}->{'data'}->{$timeframe}->{sum_cnt} += $cnt;
         $BY_HOUR{$metric}->{'data'}->{$timeframe}->{sum_avg} += $avg;
      }
      else {
         $BY_HOUR{$metric}->{'data'}->{$timeframe}->{sum_rows} = 1;
         $BY_HOUR{$metric}->{'data'}->{$timeframe}->{sum_cnt} = $cnt;
         $BY_HOUR{$metric}->{'data'}->{$timeframe}->{sum_avg} = $avg;
      }


      #-----------------------------------------------------------------
      #$BY_DAY{'device'}->{'metric'}->{'timeframe'}->{atrib}->{sum_cnt}
		my $day = "$y-$m-$d".'T';
      if (exists $BY_DAY{$metric}->{'data'}->{$day}) {
         $BY_DAY{$metric}->{'data'}->{$day}->{sum_rows} += 1;
         $BY_DAY{$metric}->{'data'}->{$day}->{sum_cnt} += $cnt;
         $BY_DAY{$metric}->{'data'}->{$day}->{sum_avg} += $avg;
      }
      else {
         $BY_DAY{$metric}->{'data'}->{$day}->{sum_rows} = 1;
         $BY_DAY{$metric}->{'data'}->{$day}->{sum_cnt} = $cnt;
         $BY_DAY{$metric}->{'data'}->{$day}->{sum_avg} = $avg;
      }

      #-----------------------------------------------------------------
      my $week = Week_of_Year($y,$m,$d);
      if (exists $BY_WEEK{$metric}->{'data'}->{$week}) {
         $BY_WEEK{$metric}->{'data'}->{$week}->{sum_rows} += 1;
         $BY_WEEK{$metric}->{'data'}->{$week}->{sum_cnt} += $cnt;
         $BY_WEEK{$metric}->{'data'}->{$week}->{sum_avg} += $avg;
      }
      else {
         $BY_WEEK{$metric}->{'data'}->{$week}->{sum_rows} = 1;
         $BY_WEEK{$metric}->{'data'}->{$week}->{sum_cnt} = $cnt;
         $BY_WEEK{$metric}->{'data'}->{$week}->{sum_avg} = $avg;
      }

      #-----------------------------------------------------------------
      if (exists $BY_MONTH{$metric}->{'data'}->{$m}) {
         $BY_MONTH{$metric}->{'data'}->{$m}->{sum_rows} += 1;
         $BY_MONTH{$metric}->{'data'}->{$m}->{sum_cnt} += $cnt;
         $BY_MONTH{$metric}->{'data'}->{$m}->{sum_avg} += $avg;
      }
      else {
         $BY_MONTH{$metric}->{'data'}->{$m}->{sum_rows} = 1;
         $BY_MONTH{$metric}->{'data'}->{$m}->{sum_cnt} = $cnt;
         $BY_MONTH{$metric}->{'data'}->{$m}->{sum_avg} = $avg;
      }

      #-----------------------------------------------------------------
      my $q=$self->get_quarter($y,$m);
      if (exists $BY_QUARTER{$metric}->{'data'}->{$q}) {
         $BY_QUARTER{$metric}->{'data'}->{$q}->{sum_rows} += 1;
         $BY_QUARTER{$metric}->{'data'}->{$q}->{sum_cnt} += $cnt;
         $BY_QUARTER{$metric}->{'data'}->{$q}->{sum_avg} += $avg;
      }
      else {
         $BY_QUARTER{$metric}->{'data'}->{$q}->{sum_rows} = 1;
         $BY_QUARTER{$metric}->{'data'}->{$q}->{sum_cnt} = $cnt;
         $BY_QUARTER{$metric}->{'data'}->{$q}->{sum_avg} = $avg;
      }

      #-----------------------------------------------------------------
      if (exists $BY_YEAR{$metric}->{'data'}->{$q}) {
         $BY_YEAR{$metric}->{'data'}->{$y}->{sum_rows} += 1;
         $BY_YEAR{$metric}->{'data'}->{$y}->{sum_cnt} += $cnt;
         $BY_YEAR{$metric}->{'data'}->{$y}->{sum_avg} += $avg;
      }
      else {
         $BY_YEAR{$metric}->{'data'}->{$y}->{sum_rows} = 1;
         $BY_YEAR{$metric}->{'data'}->{$y}->{sum_cnt} = $cnt;
         $BY_YEAR{$metric}->{'data'}->{$y}->{sum_avg} = $avg;
      }

   }

   #-----------------------------------------------------------------
   # FASE 3 -> Se calculan medias
   #-----------------------------------------------------------------
   foreach my $metric (keys %BY_DAY) {
      foreach my $d (keys %{$BY_DAY{$metric}->{'data'}}) {

         if (  ($BY_DAY{$metric}->{'data'}->{$d}->{'sum_cnt'} =~ /\d+/) &&
               ($BY_DAY{$metric}->{'data'}->{$d}->{'sum_cnt'}>0) ) {
                  $BY_DAY{$metric}->{'data'}->{$d}->{'avg'} = $BY_DAY{$metric}->{'data'}->{$d}->{'sum_avg'}/$BY_DAY{$metric}->{'data'}->{$d}->{'sum_cnt'};
         }
      }
   }

   foreach my $metric (keys %BY_WEEK) {
      foreach my $w (keys %{$BY_WEEK{$metric}->{'data'}}) {

         if (  ($BY_WEEK{$metric}->{'data'}->{$w}->{'sum_cnt'} =~ /\d+/) &&
               ($BY_WEEK{$metric}->{'data'}->{$w}->{'sum_cnt'}>0) ) {
                  $BY_WEEK{$metric}->{'data'}->{$w}->{'avg'} = $BY_WEEK{$metric}->{'data'}->{$w}->{'sum_avg'}/$BY_WEEK{$metric}->{'data'}->{$w}->{'sum_cnt'};
         }
      }
   }


   foreach my $metric (keys %BY_MONTH) {
      foreach my $m (keys %{$BY_MONTH{$metric}->{'data'}}) {

         if (  ($BY_MONTH{$metric}->{'data'}->{$m}->{'sum_cnt'} =~ /\d+/) &&
               ($BY_MONTH{$metric}->{'data'}->{$m}->{'sum_cnt'}>0) ) {
                  $BY_MONTH{$metric}->{'data'}->{$m}->{'avg'} = $BY_MONTH{$metric}->{'data'}->{$m}->{'sum_avg'}/$BY_MONTH{$metric}->{'data'}->{$m}->{'sum_cnt'};
         }
      }
   }


   foreach my $metric (keys %BY_QUARTER) {
      foreach my $q (keys %{$BY_QUARTER{$metric}->{'data'}}) {

        	if (  ($BY_QUARTER{$metric}->{'data'}->{$q}->{'sum_cnt'} =~ /\d+/) &&
               ($BY_QUARTER{$metric}->{'data'}->{$q}->{'sum_cnt'}>0) ) {
                  $BY_QUARTER{$metric}->{'data'}->{$q}->{'avg'} = $BY_QUARTER{$metric}->{'data'}->{$q}->{'sum_avg'}/$BY_QUARTER{$metric}->{'data'}->{$q}->{'sum_cnt'};
         }
      }
   }

   foreach my $metric (keys %BY_YEAR) {
      foreach my $y (keys %{$BY_YEAR{$metric}->{'data'}}) {

         if (  ($BY_YEAR{$metric}->{'data'}->{$y}->{'sum_cnt'} =~ /\d+/) &&
               ($BY_YEAR{$metric}->{'data'}->{$y}->{'sum_cnt'}>0) ) {
                  $BY_YEAR{$metric}->{'data'}->{$y}->{'avg'} = $BY_YEAR{$metric}->{'data'}->{$y}->{'sum_avg'}/$BY_YEAR{$metric}->{'data'}->{$y}->{'sum_cnt'};
       	}
      }
   }


   return {'by_day'=>\%BY_DAY, 'by_week'=>\%BY_WEEK, 'by_month'=>\%BY_MONTH, 'by_quarter'=>\%BY_QUARTER, 'by_year'=>\%BY_YEAR };

}




#-----------------------------------------------------------------------
# pivot_table
# IN : Estructura procedente de refactor.
#
#		metric => 'data' -> timeframe -> avg
#		metric => 'data' -> timeframe -> sum_avg
#		metric => 'data' -> timeframe -> sum_cnt
#		metric => 'data' -> timeframe -> sum_rows
#
#		metric => 'metadata' -> attrib 
#
# OUT : Genera una estructura que puede ser representada en Excel
#
# {'cols' => { '001' => { 'title' => 'Fecha', 'field'=>'timeframe' },
#					'002' => { 'title' => 'W7AVG', 'field'=>'w7avg' },
#					..... },
#  'data' => {
#              #'20/03/2017' => {
#              'Nombre de Metrica' => {
#  	                         	'w7avg' => '9,06253277320213',
#                                'Fecha' => '20/03/2017'
#                              },
#					...... }
# }
#-----------------------------------------------------------------------
sub pivot_table {
my ($self,$in)=@_;

	# Se obtienen las columnas
	my $i = 0;
	my %cols = ();
	my %data = ();
	foreach my $metric (keys %$in) {
		$i++;
		my $col_idx = sprintf "%03d", $i;
		$cols{$col_idx} = {'title' => 'Metrica', 'field'=>'Metrica'};
		$data{$metric}->{'Metrica'} = $metric; 
		foreach my $k (keys %{$in->{$metric}->{'metadata'}}) {
			$i++;
			$col_idx = sprintf "%03d", $i;
			$cols{$col_idx} = {'title' => $k, 'field'=>$k};
			$data{$metric}->{$k} = $in->{$metric}->{'metadata'}->{$k}; 
		}
		foreach my $k (sort keys %{$in->{$metric}->{'data'}}) {
         $i++;
			$col_idx = sprintf "%03d", $i;
         $cols{$col_idx} = {'title' => $k, 'field'=>$k};
			$data{$metric}->{$k} = $in->{$metric}->{'data'}->{$k}->{'avg'}; 
      }
		$i=0;
	}


	return {'cols'=>\%cols, 'data'=>\%data};

#$VAR1 = {
#          'USO DE DISCO Virtual Memory (lincesqlsid03.adsi.intranet.local)' => {
#                                                                                 'data' => {
#                                                                                             '03' => {
#                                                                                                       'sum_avg' => '158898465152.1',
#                                                                                                       'avg' => '9931154072.00625',
#                                                                                                       'sum_cnt' => 16,
#                                                                                                       'sum_rows' => 16
#                                                                                                     },
#                                                                                             '04' => {
#                                                                                                       'sum_avg' => '218494926848',
#                                                                                                       'avg' => '9931587584',
#                                                                                                       'sum_cnt' => 22,
#                                                                                                       'sum_rows' => 22
#                                                                                                     }
#                                                                                           },
#                                                                                 'metadata' => {
#                                                                                                 'Nombre' => 'lincesqlsid03',
#                                                                                                 'Tipo' => 'Servidor Virtual'
#                                                                                               }
#                                                                               },
#

}






#-----------------------------------------------------------------------
sub pivot_table_by_month {
my ($self,$in)=@_;

   # Se obtienen las columnas
   my $i = 0;
   my %cols = ();
   my %data = ();
   foreach my $metric (keys %$in) {
      $i++;
      my $col_idx = sprintf "%03d", $i;
      $cols{$col_idx} = {'title' => 'Metrica', 'field'=>'Metrica'};
      $data{$metric}->{'Metrica'} = $metric;
      foreach my $k (keys %{$in->{$metric}->{'metadata'}}) {
         $i++;
         $col_idx = sprintf "%03d", $i;
         $cols{$col_idx} = {'title' => $k, 'field'=>$k};
         $data{$metric}->{$k} = $in->{$metric}->{'metadata'}->{$k};
      }
      foreach my $k (sort keys %{$in->{$metric}->{'data'}}) {
         $i++;
         $col_idx = sprintf "%03d", $i;
         $cols{$col_idx} = {'title' => $k, 'field'=>$k};
         $data{$metric}->{$k} = $in->{$metric}->{'data'}->{$k}->{'avg'};
      }
      $i=0;
   }


   return {'cols'=>\%cols, 'data'=>\%data};

}

1;
 

