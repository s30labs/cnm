use DataBox;
package DataBox::Global;
@ISA=qw(DataBox);

#------------------------------------------------------------------------
use strict;
use Data::Dumper;
#------------------------------------------------------------------------
use Date::Calc qw( Week_of_Year Monday_of_Week );
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
# refactor (Hacia abajo ej. activity -> host)
#-----------------------------------------------------------------------
# Consolida los datos de entrada en series diarias, semanales, mensuales ...
# IN. Parametros de entrada:
#	El atributo series_data
# 	El atributo series_metadata. Hash k=>v
#		'key_tag' => 'Nombre', 
#		'timeframe_tag'=>'Fecha_Hora',
#		'metric_tag'=>'Metrica',
#		'avg_tag'=>'v1',
#		'attribute_tags'=>['Nombre','Tipo']}
#
# $DATA{'device'}->$DATA{'metric'}->{'timeframe'}->{atrib}->{sum_rows}
# $DATA{'device'}->$DATA{'metric'}->{'timeframe'}->{atrib}->{sum_cnt}
# $DATA{'device'}->$DATA{'metric'}->{'timeframe'}->{atrib}->{sum_avg}
#
# OUT.
# {'by_hour'=>{},  'by_day'=>{}, 'by_week'=>{}, 'by_month'=>{}, 'by_quarter'=>{}, 'by_year'=>{} }
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

	my $filter_by_date=$self->filter_by_date();
	my $data = $self->series_data();
	my $metadata = $self->series_metadata();


#          {
#            	'Nombre' => 'lincesqlitsip03',
#            	'v1' => '1.7179344896e+10',
#					'Fecha_Hora' => '2017/04/18 02:00:00',
#            	'Tipo' => 'Servidor Virtual'
#          },

	my %OUTDATA = ( 'by_hour'=>{}, 'by_day'=>{}, 'by_week'=>{}, 'by_month'=>{}, 'by_3m'=>{},  'by_4m'=>{}, 'by_year'=>{} );
	my $key_tag = $metadata->{'key_tag'};  					# Debe ser 'Nombre'
	my $timeframe_tag = $metadata->{'timeframe_tag'}; 		# Debe ser 'Fecha_Hora'
	my $metric_tag = $metadata->{'metric_tag'}; 				# Debe ser 'USO DE DISCO ....'
	my $avg_tag = $metadata->{'avg_tag'}; 						# Debe ser 'v1'
	my $cnt_tag = (exists $metadata->{'cnt_tag'}) ? $metadata->{'cnt_tag'} : 1; 						# Solo si existe un campo con el contador de ocurrencias en linea.
	my $attribute_tags = $metadata->{'attribute_tags'}; 	# Array con los atributos a considerar. En este caso ['Tipo'] 

	# FASE 2 -> Se consolida
	# -----------------------------------------------------------------
	my %BY_HOUR=();

	my %ATTR = ();
   foreach my $x (@$data) {
	
		my $key = $x->{$key_tag};
		my $metric = $x->{$metric_tag};
		my $avg = $x->{$avg_tag};
		my $cnt = (exists $x->{$cnt_tag}) ? $x->{$cnt_tag} : 1 ;

		# Se pasa a timeframe excel => "$y-$m-$d".'T'
		my ($d,$m,$y,$timeframe) = $self->normalize_timeframe($x->{$timeframe_tag});
		if ( ($filter_by_date) && (! $self->ok_day($y,$m,$d))) { next; }

#print "$timeframe-$key -$metric-$avg-$cnt---($m,$d,$y) original=$x->{$timeframe_tag}\n";

      foreach my $a (@$attribute_tags) {
			$BY_HOUR{$metric}->{'metadata'}->{$a} = $x->{$a};
		}


      foreach my $a (@$attribute_tags) {

			my $attval=$x->{$a};
			$ATTR{$attval}=1;

         #-----------------------------------------------------------------
         #$BY_HOUR{'device'}->{'metric'}->{'timeframe'}->{atrib}->{sum_cnt}
         if (exists $BY_HOUR{$metric}->{'data'}->{$timeframe}->{$attval}) {
            $BY_HOUR{$metric}->{'data'}->{$timeframe}->{$attval}->{sum_rows} += 1;
            $BY_HOUR{$metric}->{'data'}->{$timeframe}->{$attval}->{sum_cnt} += $cnt;
            $BY_HOUR{$metric}->{'data'}->{$timeframe}->{$attval}->{sum_avg} += $avg*$cnt;
         }
         else {
            $BY_HOUR{$metric}->{'data'}->{$timeframe}->{$attval}->{sum_rows} = 1;
            $BY_HOUR{$metric}->{'data'}->{$timeframe}->{$attval}->{sum_cnt} = $cnt;
            $BY_HOUR{$metric}->{'data'}->{$timeframe}->{$attval}->{sum_avg} = $avg*$cnt;
         }
		}	
	}

   #-----------------------------------------------------------------
	# FASE 3 -> Se calculan medias	
   #-----------------------------------------------------------------
   foreach my $metric (keys %BY_HOUR) {
      foreach my $d (keys %{$BY_HOUR{$metric}->{'data'}}) {

      	foreach my $attval (keys %ATTR) {

				if (! exists $BY_HOUR{$metric}->{'data'}->{$d}->{$attval}) { next; }
				if (! exists $BY_HOUR{$metric}->{'data'}->{$d}->{$attval}->{'sum_cnt'}) { next; }
				if (! exists $BY_HOUR{$metric}->{'data'}->{$d}->{$attval}->{'sum_avg'}) { next; }
				if (  ($BY_HOUR{$metric}->{'data'}->{$d}->{$attval}->{'sum_cnt'} =~ /\d+/) &&
   	            ($BY_HOUR{$metric}->{'data'}->{$d}->{$attval}->{'sum_cnt'}>0) ) {
      	            $BY_HOUR{$metric}->{'data'}->{$d}->{$attval}->{'avg'} = $BY_HOUR{$metric}->{'data'}->{$d}->{$attval}->{'sum_avg'}/$BY_HOUR{$metric}->{'data'}->{$d}->{$attval}->{'sum_cnt'};
         	}
			}
		}
	}

	return {'by_hour'=>\%BY_HOUR};



#          {
#            'IP' => '10.196.12.20',
#            'Sistema Operativo' => '-',
#            'Soporte' => '24x7',
#            'v2' => '1.9802985419e+09',
#            'v3' => undef,
#            'Empresa Mantenimiento' => '-',
#            'v1' => '1.7179344896e+10',
#            'Fecha_Hora' => '2017/04/16 02:00:00',
#            'Ubicacion' => 'Cloud Telefonica',
#            'Fabricante' => '-',
#            'Modelo' => '-',
#            'Servicio' => '-',
#            'Nombre' => 'lincesqlitsip03',
#            'Grupo Responsable' => '',
#            'Metrica' => 'USO DE DISCO Physical Memory (lincesqlitsip03.adsi.intranet.local)',
#            'Tipo' => 'Servidor Virtual',
#            'Dominio' => 'adsi.intranet.local'
#          },
}


# -------------------------------------------------------------------------------------
# IN
# -------------------------------------------------------------------------------------
#          'FichaCliente' => {
#                              'data' => {
#                                          '2017-04-08T' => {
#                                                             'Microsoft Windows 7 Enterprise' => {
#                                                                                                   'sum_avg' => '99.8490833333',
#                                                                                                   'avg' => '12.4811354166625',
#                                                                                                   'sum_cnt' => 8,
#                                                                                                   'sum_rows' => 8
#                                                                                                 },
#                                                             'Microsoft Windows 10 Enterprise' => {
#                                                                                                    'sum_avg' => '75.0326166',
#                                                                                                    'avg' => '5.35947261428571',
#                                                                                                    'sum_cnt' => 14,
#                                                                                                    'sum_rows' => 14
#                                                                                                  }
#                                                           },
#
#										}
#
#                              'metadata' => {
#                                              'OS' => 'Microsoft Windows 7 Enterprise'
#                                            }
#										}
#

# -------------------------------------------------------------------------------------
# OUT
# -------------------------------------------------------------------------------------
#          'data' => {
#                      'FichaCliente' => {
#                                          '2017-04-08T' => {
#				                                                   'Microsoft Windows 7 Enterprise-avg' => '12.4811354166625',
#				                                                   'Microsoft Windows 7 Enterprise-sum_cnt' => '8',
#				                                                   'Microsoft Windows 10 Enterprise-avg' => '5.35947261428571',
#				                                                   'Microsoft Windows 10 Enterprise-sum_cnt' => '14',
#																				}
#
#                           ............
#                    },
#          'cols' => {
#                      '003' => {
#                                 'title' => 'Windows 7 - Valor Medio',
#                                 'field' => 'Microsoft Windows 7 Enterprise-avg'
#                               },
#                      '002' => {
#                                 'title' => 'Fecha',
#                                 'field' => 'Fecha'
#                               },
#                      '004' => {
#                                 'title' => 'Windows 7 - Num. Ocurrencias',
#                                 'field' => 'Microsoft Windows 7 Enterprise-sum_cnt'
#                               },
#                      '005' => {
#                                 'title' => 'Windows 10 - Valor Medio',
#                                 'field' => 'Microsoft Windows 10 Enterprise-avg'
#                               },
#                      '006' => {
#                                 'title' => 'Windows 10 - Num. Ocurrencias',
#                                 'field' => 'Microsoft Windows 10 Enterprise-sum_cnt'
#                               },
#                      '001' => {
#                                 'title' => 'Metrica',
#                                 'field' => 'Metrica'
#                               }
#                    }
#        };


# -------------------------------------------------------------------------------------
# IN
# -------------------------------------------------------------------------------------
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
#

# -------------------------------------------------------------------------------------
# OUT 
# -------------------------------------------------------------------------------------
#          'data' => {
#                      'USO DE DISCO Virtual Memory (lincesqlsid03.adsi.intranet.local)' => {
#                                                                                             '03' => '9931154072.00625',
#                                                                                             'Nombre' => 'lincesqlsid03',
#                                                                                             '04' => '9931587584',
#                                                                                             'Metrica' => 'USO DE DISCO Virtual Memory (lincesqlsid03.adsi.intranet.local)',
#                                                                                             'Tipo' => 'Servidor Virtual'
#                                                                                           },
#                      'USO DE DISCO G:\\ Label:SQLTemp-Logs (lincetstsqlolap.adsi.intranet.local)' => {
#                                                                                                        '03' => '53683941376',
#                                                                                                        'Nombre' => 'lincetstsqlolap',
#                                                                                                        '04' => '53683941376',
#                                                                                                        'Metrica' => 'USO DE DISCO G:\\ Label:SQLTemp-Logs (lincetstsqlolap.adsi.intranet.local)',
#                                                                                                        'Tipo' => 'IP Virtual'
#                                                                                                      },
#
#									 ............
#                    },
#          'cols' => {
#                      '003' => {
#                                 'title' => 'Tipo',
#                                 'field' => 'Tipo'
#                               },
#                      '002' => {
#                                 'title' => 'Nombre',
#                                 'field' => 'Nombre'
#                               },
#                      '004' => {
#                                 'title' => '03',
#                                 'field' => '03'
#                               },
#                      '005' => {
#                                 'title' => '04',
#                                 'field' => '04'
#                               },
#                      '001' => {
#                                 'title' => 'Metrica',
#                                 'field' => 'Metrica'
#                               }
#                    }
#        };
#

#-----------------------------------------------------------------------
# pivot_table
# IN : Estructura procedente de refactor.
#
#		metric => 'data' -> timeframe -> attval -> avg
#		metric => 'data' -> timeframe -> attval -> sum_avg
#		metric => 'data' -> timeframe -> attval -> sum_cnt
#		metric => 'data' -> timeframe -> attval -> sum_rows
#
#		metric => 'metadata' -> attrib 
#
#		$selector => permite especificar listas de inclusion o de exclusion.
#		$selector ->  { 'mode'=>'include', 'values'=>{'mivalor1'=>1, 'mivalor2'=>1}}
#		$selector ->  { 'mode'=>'exclude', 'values'=>{'UNKNOWN'=>1}}
#
# OUT : Genera una estructura que puede ser representada en Excel
#
# {'cols' => { '001' => { 'title' => 'Metrica', 'field'=>'metric' },
#              '002' => { 'title' => 'Fecha', 'field'=>'timeframe' },
#              '003' => { 'title' => 'attval -> avg', 'field'=>'avg' },
#              '004' => { 'title' => 'attval -> cnt', 'field'=>'sum_cnt' },
#              ..... },
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
my ($self,$in,$selector)=@_;

	# Se obtienen las columnas
	my $col_idx;
   my %h = ('title' => 'Metrica', 'field'=>'Metrica');
   my %cols = ( '001' => \%h );
	$cols{'002'} = {'title' => 'Fecha', 'field'=>'Fecha'};
	my %data = ();

	foreach my $metric (keys %$in) {

      foreach my $fecha (sort keys %{$in->{$metric}->{'data'}}) {

			my $i=2;
			my $key = $metric.'-'.$fecha;

			$data{$key}->{'Metrica'} = $metric;
			$data{$key}->{'Fecha'} = $fecha;

			foreach my $attval (sort keys %{$in->{$metric}->{'data'}->{$fecha}}) {

				if ((defined $selector) && (exists $selector->{'mode'})) {
					if (($selector->{'mode'} eq 'exclude') && (exists $selector->{'values'}->{$attval})) { next; }
					if (($selector->{'mode'} eq 'include') && (!exists $selector->{'values'}->{$attval})) { next; }
				}


				my $column = $attval.' - Valor medio';
				$i++;
		      $col_idx = sprintf "%03d", $i;
      		$cols{$col_idx} = {'title' => $column, 'field'=>$column};
				$data{$key}->{$column} = $in->{$metric}->{'data'}->{$fecha}->{$attval}->{'avg'};
				$column = $attval.' - Volumen';
            $i++;
            $col_idx = sprintf "%03d", $i;
      		$cols{$col_idx} = {'title' => $column, 'field'=>$column};
				$data{$key}->{$column} = $in->{$metric}->{'data'}->{$fecha}->{$attval}->{'sum_cnt'};
			}
		}
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



1;
 

