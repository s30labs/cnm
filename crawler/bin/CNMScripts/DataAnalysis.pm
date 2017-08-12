#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/DataAnalysis.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::DataAnalysis;
@ISA=qw(CNMScripts);

use lib '/opt/crawler/bin';
use strict;
use Digest::MD5 qw(md5_hex);
use Text::Diff;
use JSON;
use RRDs;
use Crawler;

my $VERSION = '1.00';

#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::StoreConfig
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_store_dir} = $arg{store_dir} || '/opt/data/app-data/remote_cfgs';
   $self->{_store_limit} = $arg{store_limit} || 10;

   return $self;
}

#----------------------------------------------------------------------------
# do_analysis
# 1. Obtiene las actividades de analisis definidas en cfg_monitor_analysis 
# 2. Para los dispositivos mapeados obtiene los datos de analisis y los 
# almacena en cfg_monitor_analysis_store
# 3. Genera una tabla con los resultados
#----------------------------------------------------------------------------
sub do_analysis {
my ($self,$dbh)=@_;


	#my $sql ="SELECT asubtype,type,subtype,monitor FROM cfg_monitor_analysis";
	my $sql ="SELECT c.asubtype,c.type,c.subtype,c.monitor,a.expr FROM cfg_monitor_analysis c, alert_type a WHERE c.monitor=a.monitor";
	my $activities = $self->dbSelectAll($dbh, $sql, ['asubtype']);

use Data::Dumper;
#print Dumper($activities)."---\n";
#          'ana_1234' => {
#                          'subtype' => 'status_mibii_if',
#                          'monitor' => 's_status_mibii_if-23f569ba',
#                          'type' => 'snmp',
#                          'asubtype' => 'ana_1234'
#                        }
#        };



	foreach my $k (sort keys %$activities) {

		my $subtype=$activities->{$k}->{'subtype'};
		my $monitor=$activities->{$k}->{'monitor'};
		my $expr=$activities->{$k}->{'expr'};

		print "ACTIVITY = $k\t($subtype : $monitor) ...\n";
	   my $sql ="SELECT id_dev FROM cfg_monitor_analysis2device LIMIT 1";
   	my $devices = $self->dbSelectAll($dbh, $sql,'');
		foreach my $x (@$devices) {
			my $id_dev=$x->[0];
		
			$self->metric_analysis($dbh,$id_dev,$subtype,$expr);

		}

	}
}


#----------------------------------------------------------------------------
# metric_analysis
# 1. Obtiene la info de la metrica definida
# 2. Obtiene los datos del rrd correspondiente
# 3. Almacena en cfg_monitor_analysis_store
# 3. Genera una tabla con los resultados
#----------------------------------------------------------------------------
sub metric_analysis {
my ($self,$dbh,$id_dev,$subtype,$expr)=@_;

   my $sql ="SELECT items,file,top_value from metrics WHERE subtype='$subtype' AND id_dev=$id_dev";
   my $rres = $self->dbSelectAll($dbh, $sql, '');
	
	my $crawler=Crawler->new();
   foreach my $l (@$rres) {
      my ($sitems,$file,$top_value)=($l->[0], $l->[1],  $l->[2]);
      print "METRICA $subtype (id_dev=$id_dev) items=$sitems\texpr=$expr\t$file\n";
		my @items=split(/\|/,$sitems);	
		my $nitems=scalar(@items);

		my $stime='now';
		my $svalue='';
		my $rrd_data = $self->get_from_rrd($file,$svalue,$stime);

#use Data::Dumper;
#print Dumper($rrd_data);
	
		foreach my $t (sort keys %$rrd_data) {
			my ($condition,$lval,$oper,$rval)=$crawler->watch_eval($expr,$rrd_data->{$t},$file,{'top_value'=>$top_value});
			#debug
			print localtime($t)."  $t: condition=$condition ($lval,$oper,$rval) VALUES=";
			foreach my $v (@{$rrd_data->{$t}}) { print "$v ";}
			print "\n";

			# Debe almacenar los datos en cfg_monitor_analysis_store

		}

#		for my $i (1..$nitems) {
#			my $svalue='v'.$i;
#			my $stime='now';
#		 	$self->get_from_rrd($file,$svalue,$stime);
#		}



   }
}


#----------------------------------------------------------------------------
# Funcion: get_from_rrd
# Descripcion:
#----------------------------------------------------------------------------
sub get_from_rrd  {
my ($self,$rrd,$svalue,$stime)=@_;
my $rc=undef;


   my %DATA=();
   my $BASE_DIR = '/opt/data/rrd/elements';
   my $rrd_file = $BASE_DIR .'/'.$rrd;
   my ($start,$step,$names,$data) = RRDs::fetch $rrd_file, "AVERAGE";

   my $error = RRDs::error;

   if ($error) {
      $self->err_str($error);
      print STDERR $error."\n";
      return;
   }

   print "start=".$self->time2date($start)." ($start), step=$step\n";


   print "                    ";
   map {printf("%12s",$_)} @$names ;
   print "\n";

   #--------------------------------------------
   foreach my $line (@$data){
      $start += $step;
      $DATA{$start} = $line;
      $start += $step;

#     foreach my $val (@$line) {
#        if (! defined $val) { next; }
#        printf "%12.1f", $val;
#        }
#        print "\n";

   }

   return \%DATA;
}


1;
__END__


