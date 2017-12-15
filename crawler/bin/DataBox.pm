package DataBox;
#------------------------------------------------------------------------
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;
 
@EXPORT_OK = qw();
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);
 
#------------------------------------------------------------------------
use Date::Calc qw( Week_of_Year Day_of_Week);
use JSON;
use Data::Dumper;
 
 
#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo DataBox
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;
 
bless {
      _base_path => $arg{'base_path'} || '/tmp',
      _date_format => $arg{'date_format'} || 'y/m/d',
      _series_data => $arg{'series_data'} || [],
      _series_metadata => $arg{'series_metadata'} || [],
   }, $class;
 
}
 
#----------------------------------------------------------------------------
# base_path
#----------------------------------------------------------------------------
# GET/SET del atributo con la ruta de los ficheros de trabajo (csv ...)
#----------------------------------------------------------------------------
sub base_path {
my ($self,$base_path) = @_;
   if (defined $base_path) {
      $self->{_base_path}=$base_path;
   }
   else { return $self->{_base_path}; }
}

#----------------------------------------------------------------------------
# date_format
#----------------------------------------------------------------------------
# GET/SET del atributo con el formato usado para las fechas
#----------------------------------------------------------------------------
sub date_format {
my ($self,$date_format) = @_;
   if (defined $date_format) {
      $self->{_date_format}=$date_format;
   }
   else { return $self->{_date_format}; }
}

#----------------------------------------------------------------------------
# series_data
#----------------------------------------------------------------------------
# GET/SET del atributo series_data. Contiene los datos de entrada a procesar.
# El formato es un array de hashes clave=>valor. 
# Ejemplo:
# [ 
#          {
#            'v1' => '1.7179344896e+10',
#            'Fecha_Hora' => '2017/04/17 02:00:00',
#            'Nombre' => 'host03',
#            'Metrica' => 'USO DE DISCO Physical Memory (host03.local)',
#            'Tipo' => 'Servidor Virtual'
#          },
#			........
#          {
#            'v1' => '1.7179344896e+10',
#            'Fecha_Hora' => '2017/04/18 02:00:00',
#            'Nombre' => 'host03',
#            'Metrica' => 'USO DE DISCO Physical Memory (host03.local)',
#            'Tipo' => 'Servidor Virtual'
#          }
#        ];
#
#----------------------------------------------------------------------------
sub series_data {
my ($self,$series_data) = @_;
   if (defined $series_data) {
      $self->{_series_data}=$series_data;
   }
   else { return $self->{_series_data}; }
}
 
#----------------------------------------------------------------------------
# series_metadata
#----------------------------------------------------------------------------
sub series_metadata {
my ($self,$series_metadata) = @_;
   if (defined $series_metadata) {
      $self->{_series_metadata}=$series_metadata;
   }
   else { return $self->{_series_metadata}; }
}
 
 
#-----------------------------------------------------------------------
# import
#-----------------------------------------------------------------------
# Importa los datos desde un fichero y los almacena en el atributo  series_data
# Soporta los siguientes formatos: csv
# IN. Parametros de entrada:
#  $params->{'type'} => csv  (TIpo de fichero)
#  $params->{'file'} => Nombre del fichero
#  $columns : Array con las columnas que se van a procesar del fichero. 
#				  OJO! No tienen porque procesarse todas las columnas del fichero de entrada 
# OUT. 	Devuelve un array de hashes con clave->valor que es lo que se almacena
#			en series_data.
#-----------------------------------------------------------------------
sub import {
my ($self, $params, $columns)=@_;
 
   if (! defined $params) { return []; }
   if (! exists $params->{'type'}) { $params->{'type'} = 'csv'; }
   if (! exists $params->{'file'}) { return []; }

	my $separator = ',';
	if (exists $params->{'separator'}) { $separator = $params->{'separator'}; } 
   my $filepath = $self->base_path().'/'.$params->{'file'};
   my $rc=open (F,"<$filepath");
	if (! $rc) { 
		print "**ERROR** al abrir fichero $filepath ($!)\n";
		return [];
	}


	my @lines=();
	if ($params->{'type'} =~ /csv/i) {

	   my $i=0;
   	my @ckeys=();
   	my %columns_idx = ();
   	while (<F>) {
	      chomp;
   	   if ($i == 0) {
      	   @ckeys=split ($separator, $_);
         	my $x=0;
	         foreach my $k (@ckeys) {
   	         foreach my $c (@$columns) {
      	         if ($c eq $k) { $columns_idx{$x} = $c; }
         	   }
            	$x++;
	         }
   	   }
      	else {
	         my %h=();
   	      my @d = split ($separator, $_);
      	   for my $j (0..scalar(@d)) {
         	   if (exists $columns_idx{$j}) { $h{$ckeys[$j]} = $d[$j]; }
         	}
         	push @lines, \%h;
      	}
      	$i++;
   	}

	}

   close F;
 
   $self->series_data(\@lines);
   return \@lines;
}
 

#-----------------------------------------------------------------------
sub ok_day {
my ($self,$y,$m,$d)=@_;
my @SPECIAL_DAYS =(

	{'d'=>'6', 'm'=>'1', 'y'=>'2017' }, # Dia de Reyes
	{'d'=>'14', 'm'=>'4', 'y'=>'2017' }, # Viernes Santo
	{'d'=>'1', 'm'=>'5', 'y'=>'2017' }, # 1 de Mayo
	{'d'=>'15', 'm'=>'8', 'y'=>'2017' }, # Asuncion de la Virgen
	{'d'=>'12', 'm'=>'10', 'y'=>'2017' }, #
	{'d'=>'1', 'm'=>'11', 'y'=>'2017' }, # Todos los santos
	{'d'=>'6', 'm'=>'12', 'y'=>'2017' }, # Dia de la Constitucion
	{'d'=>'8', 'm'=>'12', 'y'=>'2017' }, # Inmaculada Concepcion
	{'d'=>'25', 'm'=>'12', 'y'=>'2017' }, # Navidad

#	#Autonomicas
#	{'d'=>'20', 'm'=>'3', 'y'=>'2017' }, #San Jose
#	{'d'=>'13', 'm'=>'4', 'y'=>'2017' }, #Jueves Santo
#	{'d'=>'2', 'm'=>'5', 'y'=>'2017' }, #Comunidad de Madrid
#
#	#Locales
#	{'d'=>'15', 'm'=>'5', 'y'=>'2017' }, #
#	{'d'=>'9', 'm'=>'11', 'y'=>'2017' }, #
);


   my $rc=1;
   my $dow = Day_of_Week($y,$m,$d);

   #Sabado
   if ($dow==6) { $rc=0; }

   #Domingo
   if ($dow==7) { $rc=0; }


	foreach my $date (@SPECIAL_DAYS) {
		if (($date->{'d'} == $d) && ($date->{'m'} == $m) && ($date->{'y'} == $y)) { 
			$rc=0; 
			last;
		}
	}

   return $rc;

}


#-----------------------------------------------------------------------
sub get_quarter {
my ($self,$y,$m)=@_;

	my %Q = ('01'=>'Q1', '02'=>'Q1', '03'=>'Q1', '04'=>'Q2', '05'=>'Q2', '06'=>'Q2', 
				'07'=>'Q3', '08'=>'Q3', '09'=>'Q3', '10'=>'Q4', '11'=>'Q4', '12'=>'Q4');

	if (($m<1) && ($m>12)) { return 'unk'; }

   return $Q{$m}.'-'.$y;

}

#-----------------------------------------------------------------------
sub normalize_timeframe {
my ($self,$timeframe)=@_;

	my ($new_timeframe,$m,$d,$y);
   # Procesado de timeframe '2017/04/18 02:00:00' , 05/22/2017
   if (($self->date_format eq 'y/m/d') && ($timeframe =~ /(\d+)\/(\d+)\/(\d+)/)) {
      ($y,$m,$d) = ($1,$2,$3);

		if ($timeframe =~ /\d+\/\d+\/\d+ (\d+)\:(\d+)/) {
			$new_timeframe = "$y-$m-$d".'T '."$1:$2";
		}


   }
   elsif (($self->date_format eq 'm/d/y') && ($timeframe =~ /(\d+)\/(\d+)\/(\d+)/)) {
      ($m,$d,$y) = ($1,$2,$3);
		$new_timeframe = "$y-$m-$d".'T';

      if ($timeframe =~ /\d+\/\d+\/\d+ (\d+)\:(\d+)/) {
         $new_timeframe = "$y-$m-$d".'T '."$1:$2";
      }

   }

	return ($d,$m,$y,$new_timeframe);

}
 
1;
 

