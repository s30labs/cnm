#----------------------------------------------------------------------------
# Crawler::Config
# Modulo que contiene la clase Config encargada de implementar las funciones 
# necesarias pas gestionar la configuracion de Apps
#----------------------------------------------------------------------------
use Crawler;
package Crawler::Config;
@ISA=qw(Crawler);
$VERSION='1.00';

#----------------------------------------------------------------------------
use strict;
use Data::Dumper;
use JSON;

#----------------------------------------------------------------------------
# Funcion: Constructor
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_file_cfg_runner} = $arg{file_cfg_runner} || '/cfg/crawler-app-runner.json';

   return $self;
}

#----------------------------------------------------------------------------
# file_cfg_runner
#----------------------------------------------------------------------------
sub file_cfg_runner {
my ($self,$file_cfg_runner) = @_;
   if (defined $file_cfg_runner) {
      $self->{_file_cfg_runner}=$file_cfg_runner;
   }
   else { return $self->{_file_cfg_runner}; }
}




#-------------------------------------------------------------------------------------------
# cfg_runner_remove_task
# Elimina una app definida en la rama de logs.
# a. Eliminar referencias de /cfg/crawler-app-runner.json
# b. Se puede eliminar el fichero: /cfg/crawler-app/app-333333001000-saptodu-devel.json
# c. Reiniciar el crawler-app del runner (en este caso 8001)
#-------------------------------------------------------------------------------------------
sub cfg_runner_remove_task {
my ($self,$task_id)=@_;

	#'/cfg/crawler-app-runner.json'
   my $file = $self->file_cfg_runner();

   my @new_runner=();
   my @stop=();
   my @restart=();
   my @cfg=();

   my $x=$self->slurp_file($file);
   my $json = JSON->new();
	$json = $json->canonical([1]);
   my $info = $json->decode($x);
   foreach my $h (@{$info->{'runner'}}) {
   #print Dumper($info);
      my $num_tasks=scalar(keys(%{$h->{'tasks'}}));
      my $remove_runner=0;
		# Las claves pueden ser la app_id: "333333001001" o un grupo de ellas: "333333000."
		# por eso se usa una regex.
      foreach my $k (keys(%{$h->{'tasks'}})) {

			# Exact matching
         if ($k eq $task_id) {
  	         if ($num_tasks==1) {
     	         push @stop,$h->{'range'};
        	      push @cfg,$h->{'tasks'}->{$task_id}->{'cfg'};
					$self->log('info',"cfg_runner_remove_task:: remove runner $k range=$h->{'range'}");
              	$remove_runner=1;
              	last;
            }
  	         else {
        	      push @restart,$h->{'range'};
     	         push @cfg,$h->{'tasks'}->{$task_id}->{'cfg'};
					$self->log('info',"cfg_runner_remove_task:: remove task $k range=$h->{'range'}");
              	delete($h->{'tasks'}->{$task_id})
           	}
        	}
			# regex matching
			elsif ($task_id=~/$k/) {
				push @restart,$h->{'range'};
				push @cfg,$h->{'tasks'}->{$k}->{'cfg'};
				$self->log('info',"cfg_runner_remove_task:: remove app $task_id ($k) from app-xxx file range=$h->{'range'}");
			}
      }
      if ($remove_runner) { next; }
      push @new_runner,$h;
   }


   my $new_content = $json->pretty->encode({'runner'=>\@new_runner});
#   print Dumper(\@stop);
#   print Dumper(\@restart);
#   print Dumper(\@cfg);

   foreach my $f (@cfg) { $self->cfg_app_remove_task($task_id,$f); }
   foreach my $r (@stop) { $self->stop_crawler_app($r); }
   foreach my $r (@restart) { $self->stop_crawler_app($r); $self->start_crawler_app($r); }

   open (F,">$file");
   print F "$new_content\n";
   close F;

}

#-------------------------------------------------------------------------------------------
# cfg_app_remove_task
# Elimina una app del fichero /cfg/crawler-app/app-3....json
# a. Si mapper solo contiene esta app -> Se elimina el fichero
# b. Si mapper tiene otras apps, solo se elimina esta.
#-------------------------------------------------------------------------------------------
sub cfg_app_remove_task {
my ($self,$app_id,$file)=@_;

   #'/cfg/crawler-app/app-3.....'
   my $x=$self->slurp_file($file);
   my $json = JSON->new();
   $json = $json->canonical([1]);
   my $info = $json->decode($x);

#---------------------------------------------------------------------
#{
#   "cmd": "core-imap",
#   "source": "from_mail",
#   "credentials": "/opt/cnm-areas/cfg/mail-manager/areas_imap_mso365.json",
#   "host": "cloudhub.cloudhub.io",
#   "mapper": [
#      { "333333000004":{"app_name":"VTOM-SalesMDW", "From":"elior.com VTOM-RECETTE@elior.com", "Subject":"Z_YMC_SD" } },
#      { "333333000006":{"app_name":"SalesMDW", "Subject":"Z_ICG_ES_CONVERSION_ISSUE", "host": "app-salesmdw.local" } },
#      { "333333000001":{"app_name":"MULESOFT", "From":"no-reply@mulesoft.com" } },
#      { "333333000002":{"app_name":"VTOM-RECETTE", "From":"elior.com VTOM-RECETTE@elior.com" } },
#      { "333333000003":{"app_name":"VTOM-PRODUCTION", "From":"elior.com VTOM-PRODUCTION@elior.com" } },
#      { "333333000005":{"app_name":"TEST", "From":"fmarin@s30labs.com" } }
#   ],
#   "default":{"app_id":"333333000001", "app_name":"MULESOFT"}
#}
#---------------------------------------------------------------------

	my $num_apps=scalar(@{$info->{'mapper'}});
	if ($num_apps==1) {
		my @mapper_keys = keys(%{$info->{'mapper'}->[0]});
		if ($mapper_keys[0] eq $app_id) {
	      `mv $file /tmp`;
   	   $self->log('info',"cfg_app_remove_task:: REMOVE APP $app_id REMOVE FILE $file");
		}	
	}
	else {
		my $i=0;
		my $ok=0;
	   foreach my $h (@{$info->{'mapper'}}) {
			my @mapper_keys = keys(%{$h});
			if ($mapper_keys[0] eq $app_id) {
				$ok=1;
				last;
			}
			$i++;
		}
		if ($ok) { 
			delete $info->{'mapper'}->[$i]; 
   	   $self->log('info',"cfg_app_remove_task:: REMOVE APP $app_id (i=$i)");

   		my $new_content = $json->pretty->encode($info);
  	 		open (F,">$file");
	   	print F "$new_content\n";
   		close F;
		}
	}
}

#-------------------------------------------------------------------------------------------
# start_crawler_app
#-------------------------------------------------------------------------------------------
sub start_crawler_app {
my ($self,$range)=@_;

   my $rc=system ("/opt/crawler/bin/crawler-app -s -c $range");
   $self->log('info',"start_crawler_app:: $range (RC=$rc)");
}


#-------------------------------------------------------------------------------------------
# stop_crawler_app
#-------------------------------------------------------------------------------------------
sub stop_crawler_app {
my ($self,$range)=@_;

   my @r=`/bin/ps -eo pid,bsdtime,etime,cmd | /bin/grep crawler | /bin/grep -v grep`;
   foreach my $v (@r) {
      chomp $v;
      $v=~s/^\s+//;
      my ($pid,$bsdtime,$etime,$cmd)=split (/\s+/,$v);

      #[crawler-app.8000.app.300]
      if ($cmd=~/crawler-app\.(\d+)\.app\.(\d+)/) {
         if ($1==$range) {
            my $rc = kill 9, $pid;
            $self->log('info',"stop_crawler_app:: $range pid=$pid (RC=$rc)");
            last;
         }
      }
   }

}


1;
