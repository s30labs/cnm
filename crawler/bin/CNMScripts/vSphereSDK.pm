#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/vSphereSDK.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use lib '/opt/cnm-sp/vmware-vsphere-cli-distrib-5.5.0/lib/libwww-perl-5.805/lib/';

use CNMScripts;
package CNMScripts::vSphereSDK;
@ISA=qw(CNMScripts);

use strict;
use warnings;
use Digest::MD5 qw(md5_hex);
use Text::Diff;
use JSON;
use Time::Local;
use IO::CaptureOutput qw/capture/;
use Data::Dumper;

use VMware::VIRuntime;

my $VERSION = '1.00';

use constant STORAGE_MULTIPLIER => 1073741824;  # 1024*1024*1024 (to convert to GB)

#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::vSphereSDK
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_server} = $arg{server} || 'localhost';
   $self->{_port} = $arg{port} || '443';
   $self->{_user} = $arg{user} || '';
   $self->{_pwd} = $arg{pwd} || '';
   $self->{_host} = $arg{host} || '';
   $self->{_samples} = $arg{samples} || 15;

   return $self;
}

#----------------------------------------------------------------------------
# server
#----------------------------------------------------------------------------
sub server {
my ($self,$server) = @_;
   if (defined $server) {
      $self->{_server}=$server;
   }
   else { return $self->{_server}; }
}

#----------------------------------------------------------------------------
# port
#----------------------------------------------------------------------------
sub port {
my ($self,$port) = @_;
   if (defined $port) {
      $self->{_port}=$port;
   }
   else { return $self->{_port}; }
}

#----------------------------------------------------------------------------
# user
#----------------------------------------------------------------------------
sub user {
my ($self,$user) = @_;
   if (defined $user) {
      $self->{_user}=$user;
   }
   else { return $self->{_user}; }
}

#----------------------------------------------------------------------------
# pwd
#----------------------------------------------------------------------------
sub pwd {
my ($self,$pwd) = @_;
   if (defined $pwd) {
      $self->{_pwd}=$pwd;
   }
   else { return $self->{_pwd}; }
}

#----------------------------------------------------------------------------
# host
#----------------------------------------------------------------------------
sub host {
my ($self,$host) = @_;
   if (defined $host) {
      $self->{_host}=$host;
   }
   else { return $self->{_host}; }
}

#----------------------------------------------------------------------------
# samples
#----------------------------------------------------------------------------
sub samples {
my ($self,$samples) = @_;
   if (defined $samples) {
      $self->{_samples}=$samples;
   }
   else { return $self->{_samples}; }
}

#----------------------------------------------------------------------------
# check_remote_port
#----------------------------------------------------------------------------
sub check_remote_port {
my ($self,$ip)=@_;

my $REMOTE_PORT='443';
my $TIMEOUT=3;

	my ($rc,$lapse) = $self->check_tcp_port($ip,$REMOTE_PORT,$TIMEOUT);
	if (! $rc) {
      $self->err_str('VSPHERE_REMOTE_TIMEOUT');
      $self->err_num(1);
	}
	return ($rc,$lapse);
}

#----------------------------------------------------------------------------
# check_remote
#----------------------------------------------------------------------------
sub check_remote {
my ($self,$ip)=@_;

	my $obj = $self->connect();

	my $rc=1;
   if (ref($obj) ne 'Vim') {
		my $stderr=$self->err_str();

      $self->log('info',"check_remote >> **ERROR** [$rc] >> $stderr");
      $self->err_str("[ERR] $stderr");
      $self->err_num(1);
      $rc=0;
   }
	else {
	   $self->err_str('[OK]');
   	$self->err_num(0);
	}
   return $rc;



}


#----------------------------------------------------------------------------
# connect
#----------------------------------------------------------------------------
sub connect {
my ($self)=@_;

   # --------------------------------------
   my $server=$self->server();
   my $port=$self->port();
   my $user=$self->user();
   my $pwd=$self->pwd();
   my $host=$self->host();

	my $retval='';
   if ( ($user eq '') || ($pwd eq '')) {
      $self->err_num(10);
      $self->err_str("ERROR con las credenciales (user=$user pwd=$pwd)");
      $self->log('error',"ERROR con las credenciales (user=$user pwd=$pwd)");
      return $retval;
   }

	my $url='https://'.$server.':'.$port.'/sdk/vimService';
   eval {
      $retval = Vim::login(service_url => $url, user_name => $user, password => $pwd);
   };

   if ($@) {
		chomp $@;
      my $error = "ERROR en acceso a '$url' ($@)";
		if ($@ =~ /(.*?)\s+at\s+/) { $error = "ERROR en acceso a '$url' ($1)"; }
      $self->err_num(1);
      $self->err_str($error);
      $self->log('error',"$error");
   }
   else {
      $self->err_num(0);
      $self->err_str("Acceso a $url >> OK");
      #`$LOGGER actionsd >> Acceso a $host  OK`;
      $self->log('info',"Acceso a url OK");
   }


   return $retval;
}


#----------------------------------------------------------------------------
# connect
#----------------------------------------------------------------------------
sub disconnect {
my ($self)=@_;

   Vim::get_vim()->disconnect if Vim::get_vim();
   return;
}



#----------------------------------------------------------------------------
# get_performance_counters
#----------------------------------------------------------------------------
sub get_performance_counters() {
my ($self)=@_;

	my %ALL_COUNTERS=();
	my %COUNTERS=();
	my $H=$self->host();
	my $samples=$self->samples();
   my $host = Vim::find_entity_view(view_type => "HostSystem", filter => {'name' => $H});
   if (!defined($host)) {
		$self->log('info',"get_performance_counters:: No encontrado host $H");
      return;
   }

   my $perfmgr_view = Vim::get_view(mo_ref => Vim::get_service_content()->perfManager);

   #-----------------------------------------------------
   my $historical_intervals = $perfmgr_view->historicalInterval;
   my $provider_summary = $perfmgr_view->QueryPerfProviderSummary(entity => $host);
   my @intervals = ();
   if ($provider_summary->refreshRate) {
      push @intervals, $provider_summary->refreshRate;
   }
   foreach my $h (@$historical_intervals) {
      push @intervals, $h->samplingPeriod;
   }

	
	#-----------------------------------------------------
	my @perf_metric_ids = ();
   my $perfCounterInfo = $perfmgr_view->perfCounter;
   my $availmetricid = $perfmgr_view->QueryAvailablePerfMetric(entity => $host);

	my %VALUES=();
   #my @CTYPES = qw(cpu mem net disk sys);
   my @CTYPES = qw(cpu mem net disk);
  # my $countertype=$CTYPES[0];
	foreach my $countertype (@CTYPES) {

		%ALL_COUNTERS=();
		%COUNTERS=();
	   foreach my $o (@$perfCounterInfo) {
   	   my $key = $o->key;
      	$ALL_COUNTERS{ $key } = $o;
	      my $group_info = $o->groupInfo;
   	   if ($group_info->key eq $countertype) { $COUNTERS{ $key } = $o; }
   	}

   	foreach my $m (@$availmetricid) {
      	if (exists $COUNTERS{$m->counterId}) {
         	#my $metric = PerfMetricId->new (counterId => $m->counterId, instance => (Opts::get_option('instance') || ''));
         	my $metric = PerfMetricId->new (counterId => $m->counterId, instance => '*');
         	push @perf_metric_ids, $metric;
      	}
   	}
															
		#-----------------------------------------------------
   	my $perf_query_spec = PerfQuerySpec->new(	entity => $host,
      	                                   		metricId => [@perf_metric_ids],
         	                                		'format' => 'csv',
            	                             		intervalId => shift @intervals,
               	                         	 	maxSample => $samples);

	   my $perf_data;
   	eval {
      	 $perf_data = $perfmgr_view->QueryPerf( querySpec => $perf_query_spec);
   	};
	   if ($@) {
			my $detail = $@->detail;
			$self->log('error',"get_performance_counters:: ERROR $@ ($detail)");
      	return;
   	}

   	foreach my $p (@$perf_data) {
      	my $time_stamps = $p->sampleInfoCSV;
      	my $values = $p->value;
      	foreach my $v (@$values) {
				my $counter_id=$v->id->counterId;
				my $instance = $v->id->instance;
				if ($instance eq '') { $instance = 'ALL'; }
				my $label = $ALL_COUNTERS{$counter_id}->nameInfo->label;
				my @vx = split(',',$v->value);
				my $c = scalar(@vx);
				my $valm=0;
				foreach my $i (@vx) { $valm += $i; }
			#	$valm /= $c;
				$valm = sprintf("%.3f", $valm/$c);
				$VALUES{$countertype}->{$label}->{$instance} = $valm;
				#print "$countertype: ".$label. " - $instance >> ".$v->value." ($time_stamps)\n";
      	}
   	}
	
	}

	#------------------------------------------------------------
   my $dc = Vim::find_entity_views(view_type => 'Datacenter');
   my @ds_array = ();

   foreach(@$dc) {
      if(defined $_->datastore) {
         @ds_array = (@ds_array, @{$_->datastore});
      }
   }
   my $datastores = Vim::get_views(mo_ref_array => \@ds_array);

   foreach my $datastore (@$datastores) {

      if  (! $datastore->summary->accessible) { next; }

		my $countertype = 'ds';
		my $instance = $datastore->summary->name;
		#my $usage = (($datastore->summary->freeSpace)/($datastore->summary->capacity))*100;
      my $usage = (($datastore->summary->capacity - $datastore->summary->freeSpace)/($datastore->summary->capacity))*100;
		$VALUES{$countertype}->{'Maximum Capacity'}->{$instance} = sprintf("%.3f", $datastore->summary->capacity);
		$VALUES{$countertype}->{'Maximum Capacity (MB)'}->{$instance} = sprintf("%.3f", (($datastore->summary->capacity)/STORAGE_MULTIPLIER));
      #print "$countertype: Maximum Capacity - $instance >> ".$VALUES{$countertype}->{'Maximum Capacity'}->{$instance}."\n";

      $VALUES{$countertype}->{'Available space'}->{$instance} = sprintf("%.3f",$datastore->summary->freeSpace);
      $VALUES{$countertype}->{'Available space (MB)'}->{$instance} = sprintf("%.3f",(($datastore->summary->freeSpace)/STORAGE_MULTIPLIER));

		$VALUES{$countertype}->{'Usage (%)'}->{$instance} = sprintf("%.2f", $usage);
		
      #print "$countertype: Available space - $instance >> ".$VALUES{$countertype}->{'Available space'}->{$instance}."\n";

	}

	return \%VALUES;
}



#----------------------------------------------------------------------------
# get_datastores_info
#----------------------------------------------------------------------------
sub get_datastores_info {
my ($self)=@_;

   my $dc = Vim::find_entity_views(view_type => 'Datacenter');
   my @ds_array = ();

   foreach(@$dc) {
      if(defined $_->datastore) {
         @ds_array = (@ds_array, @{$_->datastore});
      }
   }
   my $datastores = Vim::get_views(mo_ref_array => \@ds_array);

#	return $datastores;

   foreach my $datastore (@$datastores) {

	   if  (! $datastore->summary->accessible) { next; }

		print "Datastore: ".$datastore->summary->name . "\n";

		print "\tLocation: ".$datastore->info->url . "\n";
		print "\tFile system: ".$datastore->summary->type . "\n";
		print "\tMaximum Capacity: ".(($datastore->summary->capacity)/STORAGE_MULTIPLIER) . "\n";
		print "\tAvailable space: ".(($datastore->summary->freeSpace)/STORAGE_MULTIPLIER) . "\n";
	
		my @host_array = ();
	   if(defined $datastore->host) {
     		foreach(@{$datastore->host}) {
	         #@host_array = (@host_array, $_->key);
	         @host_array = (@host_array, $_->key);
     		   my $host_views = Vim::get_views(mo_ref_array => \@host_array);
			  	foreach(@$host_views) {
      	      print "\tAsociado host: ".$_->name."\n";
         	}
     		}
   	}


	   my $vm_views = Vim::get_views(mo_ref_array => $datastore->vm);
   	foreach(@$vm_views) {
     		if(!($_->config->template)) {
				print "\tMaquinas virtuales: ".$_->name."\n";
     		}
			else {
				print "\tTemplates: ".$_->name."\n";
			}
   	}


	   my $host_data_browser = Vim::get_view(mo_ref => $datastore->browser);
		my $path = '[' . $datastore->summary->name . ']';

  		eval {
     		my $browse_task = $host_data_browser->SearchDatastoreSubFolders(datastorePath=>$path);
			foreach(@$browse_task) {
				print "Folder Path: ".$_->folderPath."\n";
				if(defined $_->file) {
					foreach my $x (@{$_->file}) {
						print "\tFile: ".$x->path."\n";
  		  	 		}
				}
			}
   	};
   	if ($@) {
			print "**ERROR**($@)\n";
  		}
   }
}



#----------------------------------------------------------------------------
# get_host_info
#----------------------------------------------------------------------------
sub get_host_info {
my ($self,$lite)=@_;


	my @begin = Vim::get_service_content()->rootFolder;

   my $host_views = Vim::find_entity_views (view_type => 'HostSystem',
                                             begin_entity => @begin);


	if (!defined $lite) { $lite=0; }

	my %HINFO=();
	foreach my $h (@$host_views) {

		if (! defined $h->name) { next; }

		my $host_name=$h->name;
		$HINFO{$host_name}->{'hostName'} = $h->name;
		if ($lite) { next; }

		if (defined $h->runtime->bootTime) {
			$HINFO{$host_name}->{'bootTime'} = $h->runtime->bootTime;
		}
		if (defined $h->summary->hardware->cpuModel) { 
			$HINFO{$host_name}->{'cpuModel'} = $h->summary->hardware->cpuModel; 
		}
      if (defined $h->hardware->cpuInfo->hz) {
         $HINFO{$host_name}->{'Hz'} = $h->hardware->cpuInfo->hz;
      }
      if (defined $h->hardware->cpuInfo->numCpuCores) {
         $HINFO{$host_name}->{'numCpuCores'} = $h->hardware->cpuInfo->numCpuCores;
      }
      if (defined $h->summary->quickStats->overallCpuUsage) {
         $HINFO{$host_name}->{'overallCpuUsage'} = $h->summary->quickStats->overallCpuUsage;
      }
      if (defined $h->summary->quickStats->uptime) {
         $HINFO{$host_name}->{'uptime'} = $h->summary->quickStats->uptime;
      }
      if (defined $h->runtime->inMaintenanceMode) {
         $HINFO{$host_name}->{'inMaintenanceMode'} = $h->runtime->inMaintenanceMode;
      }
      if (defined $h->summary->hardware->memorySize) {
         $HINFO{$host_name}->{'memorySize'} = $h->summary->hardware->memorySize;
      }
      if (defined $h->summary->quickStats->overallMemoryUsage) {
         $HINFO{$host_name}->{'overallMemoryUsage'} = $h->summary->quickStats->overallMemoryUsage;
      }
      if (defined $h->summary->hardware->numNics) {
         $HINFO{$host_name}->{'numNics'} = $h->summary->hardware->numNics;
      }
      if (defined $h->summary->config->port) {
         $HINFO{$host_name}->{'Port'} = $h->summary->config->port;
      }
      if (defined $h->summary->rebootRequired) {
         $HINFO{$host_name}->{'rebootRequired'} = $h->summary->rebootRequired;
      }
      if (defined $h->summary->config->product->fullName) {
         $HINFO{$host_name}->{'product Name'} = $h->summary->config->product->fullName;
      }
      if (defined $h->summary->config->vmotionEnabled) {
         $HINFO{$host_name}->{'vmotionEnabled'} = $h->summary->config->vmotionEnabled;
      }
#      if (defined $h->summary->overallStatus->val) {
#         $HINFO{$host_name}->{'overallStatus'} = $h->summary->config->overallStatus->val;
#      }
      if (defined $h->runtime->connectionState) {
         $HINFO{$host_name}->{'connectionState'} = $h->runtime->connectionState;
      }

      #if (defined $h->) {
      #   $HINFO{$host_name}->{''} = $h->;
      #}

#print Dumper($h->summary);
	}
	
	return \%HINFO;

}


#poweredOff The virtual machine is currently powered off. 
#poweredOn The virtual machine is currently powered on. 
#suspended The virtual machine is currently suspended. 
#https://www.vmware.com/support/developer/vc-sdk/visdk41pubs/ApiReference/vim.VirtualMachine.html#field_detail

#----------------------------------------------------------------------------
# get_vm_info
#----------------------------------------------------------------------------
sub get_vm_info {
my ($self,$lite)=@_;


#   my $vm_views = Vim::find_entity_views (view_type => 'VirtualMachine');
#	my $vm_views = Vim::find_entity_views (view_type => 'VirtualMachine', filter => {name =>'sbox-server'},);
#my $vm_views = Vim::find_entity_views(view_type => 'VirtualMachine', filter => {name => 'sbox-server'}, properties => [ 'name', 'runtime.powerState' ]);
my $vm_views = Vim::find_entity_views(view_type => 'VirtualMachine', properties => [ 'name', 'runtime' ]);

   if (!defined $lite) { $lite=0; }

   my %VMINFO=();
   foreach my $vm (@$vm_views) {

#print "*************************_VM**************************\n";
#print Dumper($vm);

      if (! defined $vm->name) { next; }
		my %d=(	'powerState'=>'U', 'numMksConnections'=>'U', 'cleanPowerOff'=>'U', 'maxMemoryUsage'=>'U',
					'maxCpuUsage'=>'U', 'toolsInstallerMounted'=>'U', 'connectionState'=>'U', 'faultToleranceState'=>'U');
		if (exists $vm->{'runtime'}->{'powerState'}->{'val'}) {
			$d{'powerState'} = $vm->{'runtime'}->{'powerState'}->{'val'};
		}
		if (exists $vm->{'runtime'}->{'numMksConnections'}) {
			$d{'numMksConnections'} = $vm->{'runtime'}->{'numMksConnections'};
		}
		if (exists $vm->{'runtime'}->{'cleanPowerOff'}) {
			$d{'cleanPowerOff'} = $vm->{'runtime'}->{'cleanPowerOff'};
		}
		if (exists $vm->{'runtime'}->{'maxMemoryUsage'}) {
			$d{'maxMemoryUsage'} = $vm->{'runtime'}->{'maxMemoryUsage'};
		}
		if (exists $vm->{'runtime'}->{'maxCpuUsage'}) {
			$d{'maxCpuUsage'} = $vm->{'runtime'}->{'maxCpuUsage'};
		}
		if (exists $vm->{'runtime'}->{'toolsInstallerMounted'}) {
			$d{'toolsInstallerMounted'} = $vm->{'runtime'}->{'toolsInstallerMounted'};
		}
		if (exists $vm->{'runtime'}->{'connectionState'}->{'val'}) {
			$d{'connectionState'} = $vm->{'runtime'}->{'connectionState'}->{'val'};
		}
		if (exists $vm->{'runtime'}->{'faultToleranceState'}->{'val'}) {
			$d{'faultToleranceState'} = $vm->{'runtime'}->{'faultToleranceState'}->{'val'};
		}
#		$d{'runtime.'} = $vm->{'runtime.'}->{'val'};
		$VMINFO{$vm->name} = \%d;

#guestHeartbeatStatus
#guest -> toolsRunningStatus*
	}

	return \%VMINFO;
}

#--------------------------------------------------------------------------------------
sub print_counter_value {
my ($self,$data, $map_table) = @_;

	my $tag = $data->{'tag'};	
	my $iid = (exists $data->{'iid'}) ? $data->{'iid'} : '';	
	my $descr = $data->{'descr'};	
	my $value = $data->{'value'};	

	$descr =~ s/\=//g;
	
	my $newvalue = (exists $map_table->{$value}) ? $map_table->{$value} : $value;

	if ($iid ne '') {
		$iid =~ s/\<//g;
		$iid =~ s/\>//g;
		$iid =~ s/\.//g;
		print "<$tag.$iid> $descr = $newvalue\n";
	}
	else { print "<$tag> $descr = $newvalue\n"; }

}

1;
__END__

