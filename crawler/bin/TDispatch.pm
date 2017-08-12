#----------------------------------------------------------------------------
# Funciones de apoyo para acceso SQL
#----------------------------------------------------------------------------
package TDispatch;
use strict;
use vars qw($VERSION);
use threads;
use threads::shared;

use Data::Dumper;
use Log::Log4perl qw(get_logger);

my %LOG4PERL_CFG = (
	"log4perl.rootLogger"       				=> "DEBUG, FileApp",
	"log4perl.appender.syslog"					=> "Log::Dispatch::Syslog",
	"log4perl.appender.syslog.socket"		=> "unix",
	"log4perl.appender.syslog.facility"		=> "local0",
	"log4perl.appender.syslog.additivity" 	=> "0",
	"log4perl.appender.syslog.layout"		=> "Log::Log4perl::Layout::SimpleLayout",

	"log4perl.appender.FileApp"				=> "Log::Log4perl::Appender::File",
	"log4perl.appender.FileApp.filename"	=> "/var/log/otro.log",
	"log4perl.appender.FileApp.layout"		=> "PatternLayout",
	"log4perl.appender.FileApp.layout.ConversionPattern"	=> "%d> %m%n",
);


#----------------------------------------------------------------------------
#Hash con los subvectores de datos, troceados a partir del vector global
%TDispatch::SLICES =();
#Maximo numero de threads
$TDispatch::MAX_NUM_THREADS=25;
# Si slice=25 y num threads=10 ====> Cada ciclo soporta 10x25=250 metricas con 
# Tout_max_ciclo = slice*Tout=25x4=100
# Si Tpoll=300 ==> podria tener (Tpoll/Tout_max_ciclo)*Metricas_por_ciclo = (300/100)*250=750 metricas por ciclo

$TDispatch::MAX_THREAD_LAPSE=300;

#Hash con el estado del procesado de los diferentes trabajos en curso (slices)
my %WORK_TABLE_STATUS :shared;
#Hash con el estado de las diferentes threads lanzados
my %THREAD_TABLE_STATUS :shared;


#----------------------------------------------------------------------------
# Funciones de la clase TDispatch
#----------------------------------------------------------------------------
# Constructor
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

	Log::Log4perl->init( \%LOG4PERL_CFG );

	%WORK_TABLE_STATUS=();
	%THREAD_TABLE_STATUS=();
   for my $i (1..$TDispatch::MAX_NUM_THREADS) { 	$THREAD_TABLE_STATUS{$i}=0; }

bless {
         _name => $arg{name} || '',
         _pid => $arg{pid} || '?',
         _cfg =>$arg{cfg} || '',
         _num_threads =>$arg{num_threads} || $TDispatch::MAX_NUM_THREADS,
      }, $class;

}

#----------------------------------------------------------------------------
# cfg
#----------------------------------------------------------------------------
sub cfg {
my ($self,$cfg) = @_;
   if (defined $cfg) {
      $self->{_cfg}=$cfg;
   }
   else {
      return $self->{_cfg};
   }
}

#----------------------------------------------------------------------------
# num_threads
#----------------------------------------------------------------------------
sub num_threads {
my ($self,$num_threads) = @_;
   if (defined $num_threads) {
      $self->{_num_threads}=$num_threads;
   }
   else {
      return $self->{_num_threads};
   }
}


#-------------------------------------------------------------------------------
# set_thread_table_status
# IN: $thid (indice del thread)
#		$value (valor 0/1/2)
#-------------------------------------------------------------------------------
sub set_thread_table_status {
my ($self,$thid,$value)=@_;

	lock(%THREAD_TABLE_STATUS);

   my $logger = get_logger("TDispatch");
   $logger->info("tdispatcher::[$$] **MOD THREAD_TABLE_STATUS** I=$thid V=$value");
	if ($value==0) {sleep 5; }
   $THREAD_TABLE_STATUS{$thid}=$value;
}


#-------------------------------------------------------------------------------
# set_work_table_status
# IN: $slice_id (indice del slice)
#     $value (valor 0/1/2)
#-------------------------------------------------------------------------------
sub set_work_table_status {
my ($self,$slice_id,$value)=@_;

	lock(%WORK_TABLE_STATUS);

   $WORK_TABLE_STATUS{$slice_id}=$value;
}


#-------------------------------------------------------------------------------
# get_thread_table_status
# IN: $thid (indice del thread)
#-------------------------------------------------------------------------------
sub get_thread_table_status {
my ($self,$thid)=@_;

   lock(%THREAD_TABLE_STATUS);

	my $value=$THREAD_TABLE_STATUS{$thid};
	return $value;
}


#-------------------------------------------------------------------------------
# get_work_table_status
# IN: $slice_id (indice del slice)
#-------------------------------------------------------------------------------
sub get_work_table_status {
my ($self,$slice_id)=@_;

   lock(%WORK_TABLE_STATUS);

   my $value=$WORK_TABLE_STATUS{$slice_id};
	return $value;
}


#-------------------------------------------------------------------------------
# slice_vector
# Trocea un vector en una serie de sub-vectores.
# IN:	$vector -> Vector de entrada
#		$n -> 	Longitud minima de cada subvector
#		$key ->  Clave del hash del vector que sirve para validar si se termina el slice 
#					o se siguen rellenando datos.
# Si se quiere que los slices sean de una longitud fija (de n), se debe pasar como 
# parametro en $key una clave del hash cuyo contenido sea cambiante por linea 
# (p. ej idmetric)
#-------------------------------------------------------------------------------
sub slice_vector {
my ($self,$vector,$n,$key)=@_;

	my $logger = get_logger("TDispatch");
	my $previo=0;

	%TDispatch::SLICES=();
   my ($slice,$aux,$kk)=(0,0,0);
   foreach my $o (@$vector) {
		my $actual=$o->{$key};
      if ( ($aux<$n-1) || ($actual==$previo) ) {
         push @{$TDispatch::SLICES{$slice}}, $o;
         $aux+=1;
			$previo=$actual;
      }
      else {
         push @{$TDispatch::SLICES{$slice}}, $o;
         $kk=scalar @{$TDispatch::SLICES{$slice}};
			$logger->debug("slice_vector::[$$] **FML**METO SLICE=$slice (CONT=$kk)");
         $slice+=1;
         $aux=0;
      }
   }
   if ($aux != 0) {
      $kk=scalar @{$TDispatch::SLICES{$slice}};
		$logger->debug("slice_vector::[$$] **FML**METO SLICE=$slice (CONT=$kk)");
   }

	lock(%WORK_TABLE_STATUS);
   foreach my $s (sort keys %TDispatch::SLICES) {

      $WORK_TABLE_STATUS{$s}=0;
   }

   return;
}

#-------------------------------------------------------------------------------
# tdispatcher
#-------------------------------------------------------------------------------
sub tdispatcher {
my ($self,$fx,$obj)=@_;

	my $logger = get_logger("TDispatch");
	$logger->debug("tdispatcher::[$$] **IN** FX=$fx");


eval {

	my $texpired=time() + $TDispatch::MAX_THREAD_LAPSE;
	my $num_threads=$self->num_threads();

   while (1) {

      #foreach my $slice_id (keys %WORK_TABLE_STATUS) {
      foreach my $slice_id (keys %TDispatch::SLICES) {

			#$logger->info("tdispatcher::[$$] SLICE=$slice_id");
			#Si el estado del slice es distinto de cero ==> En curso o terminada
			my $wt_status=$self->get_work_table_status($slice_id);
         if ($wt_status == 1) { 
				#$logger->info("tdispatcher::[$$] ***EN CURSO SLICE $slice_id");
            next;
			}
         elsif ($wt_status == 2) {  
				#$logger->info("tdispatcher::[$$] ***TERMINADO SLICE $slice_id");
            next;
			}
			#Si el estado del slice es 0 ==> Hay que hacer el trabajo
			elsif ($wt_status == 0) {
	         # Recorro la lista de threads en busca de uno disponible
   	      for my $i (1..$num_threads) {
					#Si hay un thread disponible

					my $th_value=$self->get_thread_table_status($i);
					#$logger->info("tdispatcher::[$$] ***DEP** ESTADO DE THREAD $i = $th_value");

         	   if ($th_value==0) {

						$self->set_thread_table_status($i,1);
  	            	my $vector=$TDispatch::SLICES{$slice_id};
	     	         my $num=scalar(@$vector);
						#$logger->info("tdispatcher::[$$] ***ARRANCO THREAD $i de $num_threads SLICE=$slice_id (ITEMS=$num)");
               	my $th=threads->new(\&$fx,$obj,$i,$slice_id,$vector);
	  	            $th->detach;
   	  	         last;
					}
            }

				# Si no quedan disponibles termino
				my $ndisp=0;
				for my $i (1..$num_threads) {
					my $th_value=$self->get_thread_table_status($i);
					if ($th_value==0) { $ndisp++; }
				}
				if ($ndisp==0) { last; }
         }
      }
		
		#Si he terminado todos los trabajos termino la funcion
		my ($total,$in_progress,$terminated)=$self->check_work_table();
		$logger->info("tdispatcher::[$$] ***STATUS*** TOTAL=$total EN CURSO=$in_progress TERMINADAS=$terminated");

		if ($terminated==$total) { last; }
		if (time()>$texpired) { 
			$logger->info("tdispatcher::[$$] ***EXPIRED***");
			last; 
		}

		sleep 1;
	}

};
if ($@) {
	$logger->info("tdispatcher::[$$] ***ERROR TERM*** E=$@");
}


}



#-------------------------------------------------------------------------------
# check_work_table 
# Devuelve el numero de tareas no terminadas
#-------------------------------------------------------------------------------
sub check_work_table {
my ($self)=@_;

	lock(%WORK_TABLE_STATUS);
	
 	my $TOTAL_WORKS=scalar(keys %WORK_TABLE_STATUS);
	my ($in_progress,$terminated)=(0,0);
   foreach my $slice_id (keys %WORK_TABLE_STATUS) {
		if ($WORK_TABLE_STATUS{$slice_id} == 1) { $in_progress++; }
		elsif ($WORK_TABLE_STATUS{$slice_id} == 2) { $terminated++; }
	}
	
	print "***STATUS** TOTAL=$TOTAL_WORKS EN CURSO=$in_progress TERMINADAS=$terminated\n";

	return ($TOTAL_WORKS,$in_progress,$terminated);
}


1;

__END__
