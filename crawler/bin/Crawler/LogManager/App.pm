#----------------------------------------------------------------------------
# Fichero: Crawler/LogManager/App.pm
# Descripcion:
#----------------------------------------------------------------------------
package Crawler::LogManager::App;
use Crawler::LogManager;
use lib '/cfg/modules/';
@ISA=qw(Crawler::LogManager);
$VERSION='1.00';
use strict;
use POSIX ":sys_wait_h";
use Digest::MD5 qw(md5_hex);
use ONMConfig;
use MODINFO;
use Data::Dumper;
use Time::HiRes;
use File::Basename;
use JSON;
use YAML;
use Time::Local;
use Schedule::Cron;
use IO::CaptureOutput qw/capture/;
use Crawler::LogManager::App::SAP;
use Crawler::LogManager::App::Email;

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
use constant STAT_BAJA => 1;
use constant STAT_MANT => 2;
use constant STAT_ERASE => 3;

#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::App
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_cfg} = $arg{cfg} || {};
   $self->{_tasks} = $arg{tasks} || [];
   $self->{_tasks_cfg} = $arg{tasks_cfg} || [];
   $self->{_app} = $arg{app} || {};
   $self->{_daemon} = $arg{daemon} || 1;		# daemon mode
   $self->{_crontab} = $arg{crontab} || '';	# crontab entry (optional) 
   $self->{_config_path} = $arg{config_path} || '/cfg/crawler-app-runner.json';

   $self->{_timeout} = $arg{timeout} || 70;
   $self->{_retries} = $arg{retries} || 2;

   $self->{_script_dir} = $arg{script_dir} || $Crawler::App::XAGENT_METRICS_BASE_PATH;

   $self->{_exec_vector} = $arg{exec_vector} || { 'host_ip'=>undef,
														'file_script'=>undef,
														'params'=>undef,
														'proxy_host'=>undef,
														'proxy_port'=>undef,
														'proxy_type'=>undef,
														'proxy_user'=>undef,
														'proxy_pwd'=>undef  };

   $self->{_proxies} = $arg{proxies} || {};

   $self->{_stdout} = $arg{stdout} || '';
   $self->{_stderr} = $arg{stderr} || '';
   $self->{_exit_code} = $arg{exit_code} || 0;
	$self->{_time_ref} = $arg{time_ref} || 0;
   return $self;

}


#----------------------------------------------------------------------------
# cfg
#----------------------------------------------------------------------------
sub cfg {
my ($self,$cfg) = @_;
   if (defined $cfg) {
      $self->{_cfg}=$cfg;
   }
   else { return $self->{_cfg}; }
}

#----------------------------------------------------------------------------
# tasks
#----------------------------------------------------------------------------
sub tasks {
my ($self,$tasks) = @_;
   if (defined $tasks) {
      $self->{_tasks}=$tasks;
   }
   else { return $self->{_tasks}; }
}

#----------------------------------------------------------------------------
# tasks_cfg
#----------------------------------------------------------------------------
sub tasks_cfg {
my ($self,$tasks_cfg) = @_;
   if (defined $tasks_cfg) {
      $self->{_tasks_cfg}=$tasks_cfg;
   }
   else { return $self->{_tasks_cfg}; }
}

#----------------------------------------------------------------------------
# app
#----------------------------------------------------------------------------
sub app {
my ($self,$app) = @_;
   if (defined $app) {
      $self->{_app}=$app;
   }
   else { return $self->{_app}; }
}

#----------------------------------------------------------------------------
# daemon
#----------------------------------------------------------------------------
sub daemon {
my ($self,$daemon) = @_;
   if (defined $daemon) {
      $self->{_daemon}=$daemon;
   }
   else { return $self->{_daemon}; }
}

#----------------------------------------------------------------------------
# crontab
#----------------------------------------------------------------------------
sub crontab {
my ($self,$crontab) = @_;
   if (defined $crontab) {
      $self->{_crontab}=$crontab;
   }
   else { return $self->{_crontab}; }
}

#----------------------------------------------------------------------------
# config_path
#----------------------------------------------------------------------------
sub config_path {
my ($self,$config_path) = @_;
   if (defined $config_path) {
      $self->{_config_path}=$config_path;
   }
   else { return $self->{_config_path}; }
}

#----------------------------------------------------------------------------
# timeout
#----------------------------------------------------------------------------
sub timeout {
my ($self,$timeout) = @_;
   if (defined $timeout) {
      $self->{_timeout}=$timeout;
   }
   else { return $self->{_timeout}; }
}

#----------------------------------------------------------------------------
# retries
#----------------------------------------------------------------------------
sub retries {
my ($self,$retries) = @_;
   if (defined $retries) {
      $self->{_retries}=$retries;
   }
   else { return $self->{_retries}; }
}


#----------------------------------------------------------------------------
# script_dir
#----------------------------------------------------------------------------
sub script_dir {
my ($self,$script_dir) = @_;
   if (defined $script_dir) {
      $self->{_script_dir}=$script_dir;
   }
   else { return $self->{_script_dir}; }
}


#----------------------------------------------------------------------------
# exec_vector
#----------------------------------------------------------------------------
sub exec_vector {
my ($self,$exec_vector) = @_;
   if (defined $exec_vector) {
      $self->{_exec_vector}=$exec_vector;
   }
   else { return $self->{_exec_vector}; }
}

#----------------------------------------------------------------------------
# proxies
#----------------------------------------------------------------------------
sub proxies {
my ($self,$proxies) = @_;
   if (defined $proxies) {
      $self->{_proxies}=$proxies;
   }
   else { return $self->{_proxies}; }
}

#----------------------------------------------------------------------------
# stdout
#----------------------------------------------------------------------------
sub stdout {
my ($self,$stdout) = @_;
   if (defined $stdout) {
      $self->{_stdout}=$stdout;
   }
   else { return $self->{_stdout}; }
}

#----------------------------------------------------------------------------
# stderr
#----------------------------------------------------------------------------
sub stderr {
my ($self,$stderr) = @_;
   if (defined $stderr) {
      $self->{_stderr}=$stderr;
   }
   else { return $self->{_stderr}; }
}

#----------------------------------------------------------------------------
# exit_code
#----------------------------------------------------------------------------
sub exit_code {
my ($self,$exit_code) = @_;
   if (defined $exit_code) {
      $self->{_exit_code}=$exit_code;
   }
   else { return $self->{_exit_code}; }
}

#----------------------------------------------------------------------------
# time_ref
#----------------------------------------------------------------------------
sub time_ref {
my ($self,$time_ref) = @_;
   if (defined $time_ref) {
      $self->{_time_ref}=$time_ref;
   }
   else { return $self->{_time_ref}; }
}

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# sanity_check
#----------------------------------------------------------------------------
sub sanity_check  {
my ($self,$ts,$range,$sanity_lapse)=@_;

   local $SIG{CHLD}='';

   my $ts0=$self->log_tmark();
   if ($ts-$ts0>$sanity_lapse) {
      $self->init_tmark();
      my $rc=system ("/opt/crawler/bin/crawler -s -c $range");
      if ($rc==0) {
         $self->log('info',"do_task::[INFO] SANITY ($rc)");
      }
      else {
         $self->log('warning',"do_task::**WARN** SANITY ($rc) ($!)");
      }
      exit(0);
   }
}


#----------------------------------------------------------------------------
sub idle_time {
my ($self,$lapse)=@_;


   #----------------------------------------------------
   if ($Crawler::TERMINATE == 1) {
      $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
      exit 0;
   }

   #----------------------------------------------------
	my $tnow = time;
   my $tstart=$self->time_ref();
   my $wait_for_lapse = ($tstart + $lapse) - $tnow;


	my $wait_for_cron=$lapse;
	my $crontab = $self->crontab();
	my $n = scalar(split(/\s+/,$crontab));
	if ($n==5) {	
      $self->log('info',"do_task::[INFO] ***DEBUG CRONTAB*** $crontab");
		my $cron = new Schedule::Cron(sub {});
   	my $next_cron_time = $cron->get_next_execution_time($crontab);
   	$wait_for_cron = $next_cron_time - $tnow;
      $self->log('info',"do_task::[INFO] ***DEBUG CRONTAB*** next_cron_time=$next_cron_time tnow=$tnow wait_for_cron=$wait_for_cron | wait_for_lapse=$wait_for_lapse lapse=$lapse");
	}
	else {
		$self->log('info',"do_task::[INFO] ***DEBUG*** wait_for_lapse=$wait_for_lapse lapse=$lapse");
   }

   #----------------------------------------------------
	my $wait = $wait_for_lapse;
	if ($wait_for_cron < $wait) { $wait=$wait_for_cron; } 

   if ($wait < 0) {
      $self->log('warning',"do_task::[WARN] *S* [WAIT=$wait] time_ref=$tstart lapse=$lapse");  
      sleep 5;
   }
   else {
      $self->log('info',"do_task::[INFO] -W- [WAIT=$wait]");
      sleep $wait;
   }

   #----------------------------------------------------
   if ($Crawler::TERMINATE == 1) {
      $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
      exit 0;
   }

}


#----------------------------------------------------------------------------
# stop
#----------------------------------------------------------------------------
sub stop {
my  $self = shift;

   my $store=$self->create_store();
   my $dbh=$store->open_db();
   $self->dbh($dbh);
   my $cfg=$self->cfg();

   my $file_runner = $self->config_path();
   my $x=$self->get_json_config($file_runner);
   my $runner = $x->[0]->{'runner'};

   my $range_param = $self->range();

	my %app_running=();
   my @r=`/bin/ps -eo pid,bsdtime,etime,cmd | /bin/grep crawler-app | /bin/grep -v grep`;
   foreach my $v (@r) {
      chomp $v;
      $v=~s/^\s+//;
      my ($pid,$bsdtime,$etime,$cmd)=split (/\s+/,$v);
      #[crawler-app.8000.app.300]
      if ($cmd=~/crawler-app\.(\d+)\.app\.(\d+)/) { $app_running{$1}=$pid; }

	}


   foreach my $h (@$runner) {

		if (! $h->{'range'}) { next; }
		if (($range_param ne 'all') && ($range_param ne $h->{'range'})) {
print "range_param=$range_param -> SALTO $h->{'range'} ----\n";
next; }

		my $rc=kill 9, $app_running{$h->{'range'}};
		$self->log('notice',"stop:: crawler $h->{'range'} [RC=$rc]");
   }

}


#----------------------------------------------------------------------------
# run
#----------------------------------------------------------------------------
sub run {
my ($self,$file) = @_;
my $pid;

   my $store=$self->create_store();
   my $dbh=$store->open_db();
   $self->dbh($dbh);
   my $range=$self->range();
   my $spath=$self->store_path();
   my $dpath=$self->data_path();

   my $cfg=$self->cfg();

	my $file_runner = $self->config_path();
	my $x=$self->get_json_config($file_runner);
	my $runner = $x->[0]->{'runner'};

#print Dumper($runner);
#'runner' = [
#          {
#            'lapse' => '300',
#            'tasks' => {
#                            '333333000xxx' => {
#                                                'cfg' => '/cfg/crawler-app/app-333333000xxx-mail-imap4.json',
#                                                'tag' => 'mail-imap4'
#                                              }
#                          },
#            'range' => '8000',
#            'type' => 'app'
#          }
#        ];


	my $range_param = $self->range();
	
	my $i = 0;
   foreach my $h (@$runner) {

		if ((! exists $h->{'run'}) || ( $h->{'run'} != 1)) { next; }

      my $range = $h->{'range'};
		if (($range_param ne 'all') && ($range ne $range_param)) { next; }

      my $lapse = $h->{'lapse'};
      my $type = $h->{'type'};
      my $crontab = (exists $h->{'crontab'}) ? $h->{'crontab'} : '';

      if ( (! $type) || (! $range) || (! $lapse)) {
         $self->log('warning',"run::[WARN] NO definido tipo|rango|lapse");
         next;
      }

		my @tasks=();
		my @tasks_cfg=();
		# Itera sobre las tareas de cada runner
		foreach my $k (keys %{$h->{'tasks'}}) {

			if (! -f $h->{'tasks'}->{$k}->{'cfg'}) {
				$self->log('warning',"run::[WARN] NO EXISTE FICHERO $h->{'tasks'}->{$k}->{'cfg'}");
   	      next;
	      }

			print "CFG FILE: $h->{'tasks'}->{$k}->{'cfg'}\n";
			my $x=$self->get_json_config($h->{'tasks'}->{$k}->{'cfg'});

			push @tasks, $x->[0];
			push @tasks_cfg, $h->{'tasks'}->{$k}->{'cfg'};
		}

#print Dumper (\@tasks);
#next;

		$i++;
		
      $pid=$self->procreate($type,$range,$lapse);

		print "\t>>>START $i: crawler-app.$range.$type.$lapse\n";

		# child do the task
      if ($pid == 0) {
         $self->start_flag(1);

         my $log_level=$self->log_level();
			my $x = $self->daemon();
			my $cp = $self->config_path();

         my $app=Crawler::LogManager::App->new( store => $store, dbh => $dbh, store_path=>$spath, data_path=>$dpath, range=>$range, log_level=>$log_level, 'cfg'=>$cfg, 'config_path'=>$file_runner, 'app'=>$h, 'daemon'=>$x );

			# Necesario. No basta con ponerlo en el constructor
			$app->daemon($x);
			$app->crontab($crontab);
			$app->config_path($cp);
			$app->tasks(\@tasks);
			$app->tasks_cfg(\@tasks_cfg);
         $app->do_task($lapse,$range);
      }
      sleep 3;
   }
}

#----------------------------------------------------------------------------
# do_task
#----------------------------------------------------------------------------
sub do_task  {
my ($self,$lapse,$task)=@_;

   $self->log('info',"do_task::START [lapse=$lapse]");
   my $cid=$self->cid();
   my $cid_ip=$self->cid_ip();
   my $dbh=$self->dbh();

   #$self->init_objects();

   my $cfg = $self->cfg();
   #my $app = $self->app();
	my $tasks = $self->tasks();

   my $ok=1;
   my $RELOAD_FILE='/var/www/html/onm/tmp/syslog.reload';
	$self->check_configuration();
   my $log_level=$self->log_level();

   while (1) {
		
      eval {

         my $t=time;
         $self->time_ref($t);

	      # Reviso si hay que recargar la tabla de syslog -> alertas --------------------------------
   	   my $reload_file=$self->reload_file();
      	if (-f $reload_file) {
         	$self->check_configuration();
      	}


         #----------------------------------------------------------------------
         # Si $lapse es alto, lo mas probable es que se haya perdido la conexion a la BBDD.
         # Por eso fuerzo directamente una reconexion
         my $store=$self->store();
         if ($lapse > 600) {
            if (defined $dbh) { $store->close_db($dbh); }
            $dbh=$store->open_db(); $self->dbh($dbh); $store->dbh($dbh);
         }
         ($dbh,$ok)=$self->chk_conex($dbh,$store,'alerts');
         if ($ok) {

				$self->log_tmark();
				my $x=0;
				my $tasks_cfg = $self->tasks_cfg();
				foreach my $app (@$tasks) {

					$self->app($app);
					my $lines = $self->get_app_data($tasks_cfg->[$x]);

					$x++;
					my $i=0;
					my $total=scalar(@$lines);

      			foreach my $ev (@$lines) {

						$i++;
						$self->log('info',"do_task:: CHECK ALERT [$i|$total] >> $ev->{'source_line'}");

   	      		# Gestiono la posible alerta
      	   		$self->check_alert($ev);
      			}
				}
         }

         # ----------------------------------------------------------------------
         # Gestion de tiempo
			if ($self->daemon() ==  0) { 
				$self->log('info',"do_task::**TERMINATE daemon=0**");
				exit; 
			}
         $self->idle_time($lapse);
      };
		
      if ($@) {
         my $kk=ref($dbh);
         $self->log('warning',"do_task::EXCEPTION (dbh=>$kk) $@");
         $self->idle_time();
      }
   }
}


#----------------------------------------------------------------------------
# get_app_host_info
#----------------------------------------------------------------------------
sub get_app_host_info {
my ($self,$app_id,$host)=@_;

	my $app = $self->app();

	my @d = split(/\./, $host);
	my $condition='name="'.$d[0].'"';
	my ($name,$domain)=($d[0],'');
	if (scalar(@d)>1){
		shift @d;
		$domain=join('.',@d);
		$condition.=' AND domain="'.$domain.'"';
	}
	$app->{'host_name'} = $name;
	$app->{'host_domain'} = $domain;
	$self->log('debug',"get_app_host_info:: **DEBUG** host=$host condition=$condition");

	my $store = $self->store();
	my $dbh = $self->dbh();
   my $rv=$store->get_from_db($dbh,'id_dev,ip','devices',$condition);
   if ((defined $rv) && exists ($rv->[0][0])){
		$app->{'id_dev'}=$rv->[0][0];
		$app->{'host_ip'}=$rv->[0][1];
	}
	else {
		$self->log('warning',"get_app_host_info:: **ERROR** HOST NO APARECE EN BBDD ($condition)");
	}

	$self->log('info',"get_app_host_info:: ---APP: $app_id--- name=$name|domain=$domain|host_ip=$app->{'host_ip'}|id_dev=$app->{'id_dev'}");

	$self->app($app);
	return $app;	
}


#----------------------------------------------------------------------------
# get_app_data
#----------------------------------------------------------------------------
# En funcion del descriptor de la APP (json) captura los datos de la APP
# Puede hacer dos cosas:
# 1. Ejecutar el comando cmd configurado en el decriptor.
# 2. Ejecutar un modulo core interno (imap4)
# A partir estos datos (vector con 4 valores separados por ','):
# timestamp,app-id,app-name,json-msg-hash
# Los convierte en eventos que almacena en logp_xxxx
# La salida es un vector de eventos nuevos para hacer luego el check_alert
#----------------------------------------------------------------------------
sub get_app_data {
my ($self,$task_cfg_file)=@_;

   #$|=1;
   my $host = $self->host();
	my $app = $self->app();
	$app->{'file_temp'}=[];


my $xx = Dumper($app);
$xx =~ s/\n/ /g;
$self->log('debug',"get_app_data:: app=$xx");

   my ($rc,$stdout,$stderr)=(0,'','');
   $self->err_str('[OK]');
   $self->err_num(0);

   my $cmd = $app->{'cmd'};
   $self->log('info',"get_app_data:: CAPTURE by $cmd");

	my $data=[];
   my $store=$self->store();
   my $dbh=$self->dbh();

	#--------------------------------------------
	# 1. CAPTURE DATA
	# Se obtiene un vector [data] cuyas filas contienen:
	# ts,$app_id,$app_name,source_line
	# source_line -> datos recibidos codificados en JSON
	#--------------------------------------------
	# Internal cmd capture
	if ($cmd eq 'core-imap') {
		my $app_imap = Crawler::LogManager::App::Email->new(log_level=>'info');
		$app_imap->save_mail(1);
		$data = $app_imap->core_imap_get_app_data($task_cfg_file); 

		#TEST
		#my $FILE_MSG='/home/cnm/correos/1548861072.msg';
		#$data = $app_imap->test_msg_flow($task_cfg_file,$FILE_MSG);

	}
   elsif ($cmd eq 'core-sap') {
		my $app_sap = Crawler::LogManager::App::SAP->new(log_level=>'info');
		$data = $app_sap->core_sap_get_app_data($task_cfg_file);
   }

	# External cmd captura 
	else {
	   capture sub { $rc=system($cmd); } => \$stdout, \$stderr;

   	if ($stderr ne '') {

      	# Para evitar salidas espureas
	      $stderr=~s/\n/ /g;
   	   $self->err_str($stderr);
      	$self->err_num(10);
      	$self->log('error',"get_app_data:: **ERROR** stderr=$stderr (cmd=$cmd)");
   	}

		my @lines = split (/\n/, $stdout);
		$data = [@lines];
	}


   #--------------------------------------------
   my %app_flush=();
   foreach my $h (@{$app->{'mapper'}}) {
      my @k = keys %$h;
      my $app_id = $k[0]; # module = app_id
      if ( (exists $h->{$app_id}->{'capture_mode'}) && ($h->{$app_id}->{'capture_mode'} eq 'flush') ) {
			#$app_flush{$app_id}=$h->{$app_id}->{'app_name'};

			$app_flush{$app_id} = $h->{$app_id}->{'app_name'}.'-'.$app->{'source'};
			my $logfile_temp = $app_flush{$app_id}.'_temp';
         $store->clear_app_data($dbh,$logfile_temp,$app_id);
      }
   }

   #--------------------------------------------
	# Si no hay datos, termina
	my $n=scalar(@$data);
	$self->log('info',"get_app_data:: CAPTURED >> $n LINES");
	if ($n==0) { 

	   foreach my $aid (keys %app_flush) {
      	$store->flush_app_data($dbh,$aid,$app_flush{$aid});
   	}
		return $data; 
	}

   #--------------------------------------------
   # 2. TRANSFORM DATA (line by line) -> custom_line_parser
   #--------------------------------------------
	# a. Carga los modulos de las app_ids definidas en mapper
   #--------------------------------------------
	my %LOADED=();
   #foreach my $h (@{$app->[0]->{'mapper'}}) {
   foreach my $h (@{$app->{'mapper'}}) {
      my @k = keys %$h;
      my $app_id = $k[0]; # module = app_id
		my $host = (exists $h->{$app_id}->{'host'}) ? $h->{$app_id}->{'host'} : $app->{'host'};
      my $app = $self->get_app_host_info($app_id,$host);

		my $module = 'MOD'.$app_id;
#$self->log('warning',"app_parser:: **DEBUG** module=$module");

		if (-f '/cfg/modules/'.$module.'.pm') {

#$self->log('warning',"app_parser:: **DEBUG** module=$module EXISTE fichero");
	  		eval {
   	     	(my $file = $module) =~ s|::|/|g;
     			require $file . '.pm';
        		$module->import();
  			};
	  		if ($@) {
   	  		$self->log('warning',"app_parser:: **ERROR** AL CARGAR MODULO ($module) ($@)");
  			}
			else {
				$LOADED{$app_id}=1;
				$self->log('info',"app_parser:: LOAD MODULE  ($module)");
			}
		}
	}


   #--------------------------------------------
	# b. Data Transformation -> custom_line_parser
   #--------------------------------------------
	# Aplica sobre la app_id si hay modulo cargados la funcion custom_line_parser
	# que convierte [data] en [newdata]
	# Cada fila sigue siendo:
	# timestamp,app-id,app-name,json-msg-hash
	if (scalar(keys %LOADED) != 0) { 

		$self->log('info',"app_parser:: ------- LINE DATA TRANSFORMATION ---------");
		my @new_data=();
		foreach my $l (@$data) {
			
$self->log('debug',"app_parser:: **DEBUG** LINE-PARSER 1 >>>>>>$l<<<<<<<<<<");

      	chomp $l;
			my %line_parts=();
			my $skip_line=1;
			if ($l=~/^(\d+?),(\d+?),(\S+?),(.+?)\:\:\:(\w{16})$/) {
            $line_parts{'ts'} = $1;
            $line_parts{'app_id'} = $2;
            $line_parts{'app_name'} = $3;
            $line_parts{'source_line'} = $4;
            $line_parts{'md5'} = $5;
				$skip_line=0;
			}
      	elsif ($l=~/^(\d+?),(\d+?),(\S+?),(.+)$/) {
				$line_parts{'ts'} = $1;
				$line_parts{'app_id'} = $2;
				$line_parts{'app_name'} = $3; 
				$line_parts{'source_line'} = $4;
            $line_parts{'md5'} = '';
				$skip_line=0;
			}	
			if ($skip_line) { next; }

			my $module='MOD'.$line_parts{'app_id'};
$self->log('debug',"app_parser:: **DEBUG** LINE-PARSER 2");
			if (! exists $LOADED{$line_parts{'app_id'}}) { push @new_data,$l; }
			elsif ( 	(exists $MODINFO::custom_line_parser{$line_parts{'app_id'}}) &&
						(ref($MODINFO::custom_line_parser{$line_parts{'app_id'}}) eq 'CODE') ) {

$self->log('debug',"app_parser:: **DEBUG** LINE-PARSER 3");

				my $expanded = $MODINFO::custom_line_parser{$line_parts{'app_id'}}->($app,\%line_parts);
  				#my $expanded = custom_line_parser($app,\%line_parts);
  				my $n = scalar(@$expanded);
				if ($n == 0) { next; }

				push @new_data,@$expanded;
  	  			$self->log('info',"app_parser:: $line_parts{'app_id'} >> $n lines **xx=$xx***");
  			}
		}
		$data = [@new_data];
	}

   #--------------------------------------------
   # 3. TRANSFORM DATA (block transform) -> custom_block_parser
   #--------------------------------------------
   # Solo aplica si hay modulos cargados
	my $custom_block_id = (exists $app->{'custom_block_parser'}) ? $app->{'custom_block_parser'} : '0';
   if ( 	(exists $LOADED{$custom_block_id}) && 
			(exists $MODINFO::custom_block_parser{$custom_block_id}) && 
			(ref($MODINFO::custom_block_parser{$custom_block_id}) eq 'CODE') ){

      $self->log('info',"app_parser:: ------- BLOCK DATA TRANSFORMATION ($custom_block_id) ---------");
		my $data2 = $MODINFO::custom_block_parser{$custom_block_id}->($app,$data);
		$data = $data2;
   }


   #--------------------------------------------
   # 4. PREPARE LINES csv -> hash
   #--------------------------------------------
   #timestamp,app-id,app-name,json info hash
   #timestamp,app-id,app-name,json info hash:::md5_line
   my @lines=();
	my ($cnt_ok,$cnt_nok) = (0,0);
	my $cnt_tot = scalar (@$data);
   foreach my $l (@$data) {
		
      chomp $l;

      my %MSG = ();
      $MSG{'name'} = $app->{'host_name'};
      $MSG{'domain'} = $app->{'host_domain'};
      $MSG{'ip'} = $app->{'host_ip'};
      $MSG{'id_dev'} = $app->{'id_dev'};
      $MSG{'source_line'} = '';
      $MSG{'date'} = '';
		$MSG{'md5'} = '';

#$self->log('info',"app_parser:: ***DEBUG*** l=$l-----");
#$self->log('info',"app_parser:: ***DEBUG*** $MSG{'name'}-$MSG{'domain'}-$MSG{'ip'}-$MSG{'id_dev'}");

		# Incluye hash md5 de cada linea -> Util para cuando no se aplica sobre toda la linea
		# Permite actualizar valores
		# timestamp,app-id,app-name,json info hash:::md5_line
      if ($l=~/^(\d+?),(\d+?),(\S+?),(.+?)\:\:\:(\w{16})$/) {
         $MSG{'ts'} = $1;
         $MSG{'app_id'} = $2;
         $MSG{'app_name'} = $3;
         $MSG{'source_line'} = $4;
			$MSG{'md5'} = $5;
      }
		# El hash  md5 se calcula internamente al almacenarse el evento
		# timestamp,app-id,app-name,json info hash
		elsif ($l=~/^(\d+?),(\d+?),(\S+?),(.+)$/) {
         $MSG{'ts'} = $1;
         $MSG{'app_id'} = $2;
         $MSG{'app_name'} = $3;
         $MSG{'source_line'} = $4;
      }
      else {
         $MSG{'source_line'} = $l;
      }


		if (! exists $MSG{'app_id'}) {
			$self->log('info',"**NO EXISTE APP_ID** $l");
		}
		else {
			$self->log('debug',"app_parser:: ts=$MSG{'ts'} app_id=$MSG{'app_id'} app_name=$MSG{'app_name'} source_line=$MSG{'source_line'} md5=$MSG{'md5'}");
		}

		#-------------------
	   $MSG{'msg_custom'}='';
   	my @msgdata=();
	   push @msgdata,'Line::'.$MSG{'source_line'};
   	my @vdata = ();
   	my %vardata = ();
   	push @vdata,$MSG{'source_line'};
	   my $msg_fields = {};
   	eval { $msg_fields = decode_json($MSG{'source_line'}); };
   	if (! $@) {
      	my $i=2;
      	foreach my $k (sort keys %$msg_fields) {
         	push @msgdata,$k.'::'.$msg_fields->{$k};
	         push @vdata, $msg_fields->{$k};
   	      $vardata{$k} = $msg_fields->{$k};
      	   $i++;
      	}
   	}
	   $MSG{'vdata'} = \@vdata;
   	$MSG{'vardata'} = \%vardata;
   	$MSG{'msg'} = join ('|',@msgdata);

	   my $logfile = (defined $app->{'source'}) ? $app->{'source'} : 'log-app';

   	if (exists $MSG{'app_name'}) { $logfile = $MSG{'app_name'}.'-'.$logfile; }

   	# Almaceno el evento ---------------------------------------------------------------------
   	my $t = (exists $MSG{'ts'}) ? $MSG{'ts'} : time;

   	# Las tablas de APPS se identifican por su $app_id, no por la direccion IP.
   	my $app_id = (exists $MSG{'app_id'}) ? $MSG{'app_id'} : '000000000000';

		# Si es modo de captura flush -> Se inserta en tabla temp
		if (exists $app_flush{$app_id}) { $logfile .= '_temp'; }

   	# Almaceno en la tabla de log correspondiente
   	my ($table,$cnt_lines) = $store->set_log_rx_lines($dbh,$MSG{'ip'},$MSG{'id_dev'},$logfile,$app_id,[{'ts'=>$t, 'line'=>$MSG{'source_line'}, 'md5'=>$MSG{'md5'}}]);

   	if ($cnt_lines == 0) {
			$cnt_nok += 1;
      	$self->log('debug',"check_event:: STORE LOG [$cnt_ok|$cnt_nok|$cnt_tot] SKIPPED - event exists no alert checking [$app_id] logfile=$logfile");
   	}
   	else {
			$cnt_ok += 1;
      	$self->log('debug',"check_event:: STORE LOG [$cnt_ok|$cnt_nok|$cnt_tot] [$app_id] source=$app->{'source'} | logfile=$logfile ($table) date=>$t, code=>1, msg=>$MSG{'msg'}, name=>$MSG{'name'}, domain=>$MSG{'domain'}, ip=>$MSG{'ip'}");

			push @lines, \%MSG;
		}

   }

   foreach my $aid (keys %app_flush) { 
		#logp_tmp -> logp
		#my $tabx_tmp = 'logp_'.$aid.'_'.$app_flush{$aid}.'_temp';
		#my $tabx = 'logp_'.$aid.'_'.$app_flush{$aid};
		#$self->log('info',"check_event:: FLUSH DATA $tabx_tmp -> $tabx");

		$store->flush_app_data($dbh,$aid,$app_flush{$aid});
	}


   return \@lines;
}


#------------------------------------------------------------------------------------------
# check_configuration
# Actualiza configuracion de B.D
#------------------------------------------------------------------------------------------
sub check_configuration {
my ($self)=@_;

   my $reload_file = $self->reload_file();
   if (-f $reload_file) { unlink $reload_file; }
   $self->log('debug',"check_configuration::[DEBUG] RELEO CONFIG ($reload_file)");

   my $store=$self->store();
   my $dbh=$self->dbh();


   my $event2alert=$store->get_cfg_syslog_remote_alerts($dbh);
   $self->event2alert($event2alert);

   #----------------------------------------------------------------------------------
   # EXPR en alertas remotas por syslog
   #----------------------------------------------------------------------------------
#SELECT a.id_remote_alert,a.expr as expr_logic, b.v,b.descr,b.fx,b.expr FROM cfg_remote_alerts a, cfg_remote_alerts2expr b WHERE a.id_remote_alert=b.id_remote_alert and a.type='snmp';

   my $alert2expr=$store->get_remote_alert_expr_by_type($dbh,'syslog');
   $self->alert2expr($alert2expr);

   # Mapeo IP a nombre
   my $ip2name=$store->get_ip2name_vector($dbh);
   $self->ip2name($ip2name);

   my $acls=$store->get_cfg_syslog_acls($dbh);
   $self->acls($acls);

}

#------------------------------------------------------------------------------------------
# check_alert
# Comprueba si el evento recibido por syslog debe generar una alerta.
#------------------------------------------------------------------------------------------
sub check_alert {
my ($self,$event)=@_;

   my $store=$self->store();
   my $dbh=$self->dbh();
   $self->event($event);

   my $alert2expr=$self->alert2expr();
   my $event2alert=$self->event2alert();

   my $num_alerts = scalar(keys %$event2alert);
   if ($num_alerts ==  0) {
      $self->log('info',"check_alert:: SIN ALERTAS REMOTAS POR SYSLOG DEFINIDAS...");
      return;
   }
   else {
      $self->log('info',"check_alert:: DEFINIDAS $num_alerts ALERTAS REMOTAS POR SYSLOG");
      foreach my $evd  (keys %$event2alert) {
         my $ips = join ' : ', sort keys %{$event2alert->{$evd}};
         $self->log('debug',"check_alert:: SYSLOG_ALERTS $evd >> $ips");
      }
   }

   my $ip = $event->{'ip'};
   my $id_device = $event->{'id_dev'};
   my $msg = $event->{'msg'};
   my @vals=($msg);

   my $expr_logic='AND'; # REVISAR!!! FML

   #Si es una alerta de un dispositivo dado de alta pero no activo => No se genera la alerta
   my $ip2name=$self->ip2name();
   if ((exists $ip2name->{$ip}) && ($ip2name->{$ip}->{'status'} !=0)) {
      $self->log('info',"check_alert::[INFO] ip=$ip msg=$msg **SALTO DISPOSITIVO NO ACTIVO**");
      return;
   }


   #Para cada alerta de tipo app (syslog) configurada (y asociada a algun dispositivo)
   #chequeo si el evento cumple sus expresiones ($ev -> subtype)
   foreach my $ev  (keys %$event2alert) {


      if (! exists $event2alert->{$ev}->{$ip}) {
         $self->log('debug',"check_alert:: ALERTA $ev: NO DEFINIDA PARA $ip...");
         next;
      }

      $self->log('info',"check_alert:: ALERTA $ev: **DEFINIDA** PARA $ip...");

      my $subtype=$event2alert->{$ev}->{$ip}->{'subtype'};
      my $target=$event2alert->{$ev}->{$ip}->{'target'};
      my $monitor=$event2alert->{$ev}->{$ip}->{'monitor'};
      my $vdata=$event2alert->{$ev}->{$ip}->{'vdata'};
      my $action=$event2alert->{$ev}->{$ip}->{'action'};
      my $severity=$event2alert->{$ev}->{$ip}->{'severity'};
      my $script=$event2alert->{$ev}->{$ip}->{'script'};
      my $descr=$event2alert->{$ev}->{$ip}->{'descr'};
      my $id_remote_alert=$event2alert->{$ev}->{$ip}->{'id_remote_alert'};
      my $expr=$event2alert->{$ev}->{$ip}->{'expr'};
      my $mode=$event2alert->{$ev}->{$ip}->{'mode'};
      my $name=$event2alert->{$ev}->{$ip}->{'name'};
      my $domain=$event2alert->{$ev}->{$ip}->{'domain'};
      my $mname=$subtype;
      my $type='syslog';
      my $label=$descr;
      my $id_metric=$id_remote_alert;

      my $set_id=$event2alert->{$ev}->{$ip}->{'set_id'};
      my $set_subtype=$event2alert->{$ev}->{$ip}->{'set_subtype'};
      my $set_hiid=$event2alert->{$ev}->{$ip}->{'set_hiid'};

      $self->log('info',"check_alert:: ALERTA $ev: **DEFINIDA** PARA $ip >> action=$action id_remote_alert=$id_remote_alert subtype=$subtype");
my $kk=Dumper($alert2expr->{$id_remote_alert});
$kk=~s/\n/ /g;
$self->log('debug',"check_alert:: id_remote_alert=$id_remote_alert DUMPER=$kk");
$self->log('debug',"check_alert:: id_remote_alert=$id_remote_alert VALS=@vals");
$kk = join(' - ', @{$event->{'vdata'}});
$self->log('debug',"check_alert:: id_remote_alert=$id_remote_alert VDATA=$kk");

      #my $condition_ok=$self->watch_eval_ext($alert2expr->{$id_remote_alert},$expr_logic,\@vals);
      my $condition_ok=$self->watch_eval_ext($alert2expr->{$id_remote_alert},$expr_logic,$event->{'vdata'});
      $self->log('info',"check_alert:: ALERTA $ev: **DEFINIDA** PARA $ip >> WATCH_EVAL_EXT=$condition_ok");

      if (! $condition_ok) {next; }

      my $date_last=time();
      my $critic=$event->{'critic'};

      my $msg_log=substr $msg,0,250;
      $msg_log=~s/\n/\. /g;

      #Alertas nuevas
      my $cfg_mode=$mode;
      $mode=$id_remote_alert;
      if ($cfg_mode ne 'INC') { $mode .= '.'.int(100000000*rand()); }

      # Procesado de alertas. SET ---------------------------------------------------------------
      # store_mode: 0->Insert 1->Update
      if ( $action =~ /SET/i ) {
         my ($alert_id,$alert_date)=$store->store_alert($dbh,$monitor,{ 'ip'=>$ip, 'name'=>$name, 'domain'=>$domain, 'mname'=>$mname, 'severity'=>$severity, 'event_data'=>$msg, 'label'=>$label, 'cause'=>$label, 'type'=>$type, 'id_alert_type'=>20, 'id_metric'=>$id_metric, 'mode'=>$mode, 'subtype'=>$subtype, 'critic'=>$critic, 'date_last'=>$date_last, 'id_device'=>$id_device }, 1);
         my $response = $store->response();

         ## Se actualizan las tablas del interfaz
         #$store->store_alerts_read_local_set($dbh,$alert_id);
         #my $vk=$id_remote_alert.'.'.$ip;
         #if (exists $alert2views->{$vk}) { $store->analize_views_ruleset($dbh,$cid);  }

         # Se actualiza notif_alert_set (notificationsd evalua si hay que enviar aviso)
         # a. SET de alerta que no incrementa contador
         # b. SET de alerta que incrementa contador solo la primera vez (insert)
         if (($cfg_mode ne 'INC') || ($response =~ /insert/)){
            $store->store_notif_alert($dbh, 'set', { 'id_alert'=>$alert_id, 'id_device'=>$id_device, 'id_alert_type'=>20, 'cause'=>$label, 'name'=>$name, 'domain'=>$domain, 'ip'=>$ip, 'notif'=>0, 'mname'=>$mname, 'watch'=>'', 'id_metric'=>$id_metric, 'type'=>$type, 'severity'=>$severity, 'event_data'=>$msg, 'date'=>$date_last  });

         }

         # Se actualizan las tablas del interfaz
         $store->store_alerts_read_local_set($dbh,$alert_id);

         $self->log('notice',"check_alert::[INFO] $monitor [SET-ALERT: $alert_id IP=$ip | cfg_mode=$cfg_mode | mode=$mode | EV=$ev | MSG=$msg] response=$response");

      }

      # Procesado de alertas. CLEAR -------------------------------------------------------------
      elsif ( $action =~ /CLR/ ) {

#         $self->log('notice',"event2alert::[INFO] $monitor [CLEAR-ALERT: IP=$ip | EV=$ev | MSG=$msg]");
#         $store->clear_alert($dbh,{ 'ip'=>$ip, 'mname'=>$1 });

			my ($match_set_clear,$id_metric_clr,$id_alert_clr)=(1,0,0);
         # Se borra la original a partir del set_id.  Si no existe set_id, lo busco a partir de subtype + hiid
         if (($set_id =~ /^\d+$/) && ($set_id>0)) { $id_metric_clr=$set_id; }
         elsif ($set_subtype ne '') {
            my $cond = 'subtype="'.$set_subtype.'" && hiid="'.$set_hiid.'"';
            my $rv=$store->get_from_db($dbh,'id_remote_alert','cfg_remote_alerts',$cond);
            $id_metric_clr=$rv->[0][0];
         }


         if ($vdata ne '') {
            $match_set_clear = 0;
            my $rv=$store->get_from_db($dbh,'id_alert,event_data','alerts',"id_metric=$id_metric_clr");
				foreach my $x (@$rv) {
            	#my $event_data=$rv->[0][0];
            	$id_alert_clr=$x->[0];
            	my $event_data=$x->[1];
            	if ((defined $event_data) && ($event_data ne '')) {
						#v1 (Line):  {"CNM_Flag":"SET", "FechaDoc-BEDAT":"20180510", "NumPedido-EBELN":"4800036220", "extrafile2":"extrafile2"}v2 (CNM_Flag):  SETv3 (FechaDoc-BEDAT):  20180510v4 (NumPedido-EBELN):  4800036220v5 (extrafile2):  extrafile2
            	   #RFC1213-MIB::ifIndex = INTEGER: 22|RFC1213-MIB::ifAdminStatus = INTEGER: 0|RFC1213-MIB::ifOperStatus = INTEGER: 0
         	      my @set_vals_raw=split(/\|/,$event_data);
      	         my %set_vals=();
   	            $self->log('info',"check_alert::[INFO] match_set_clear >> id_metric=$id_metric_clr event_data=$event_data");
	               foreach my $v (@set_vals_raw) {
               		$self->log('info',"check_alert::[INFO] match_set_clear >> v=$v");
               	   if ($v=~ /^(.+)\s*\:\:\s*(.+)$/) {
            	         $set_vals{$1}= $2;
         	         }
      	         }

   	            my @match_vals = split(',', $vdata);
	               my $num_ok = scalar(@match_vals);
						my $nok=0;
            	   foreach my $vm (@match_vals) {
							if ($set_vals{$vm} ne $event->{'vardata'}->{$vm}) { $nok=1; }
$self->log('info',"check_alert::[INFO] match_set_clear >> vm=$vm COMPARO $set_vals{$vm} CON $event->{'vardata'}->{$vm} (nok=$nok) id_alert_clr=$id_alert_clr");
     		         }
   	            if (!$nok) { 
							$match_set_clear = 1; 
							last;
						}
	            }
				}
         }

			if ($match_set_clear) {
	         my $alert_id=$store->clear_alert($dbh,{ 'id_alert'=>$id_alert_clr, 'ip'=>$ip, 'id_metric'=>$id_metric_clr, 'type'=>'syslog' });
   	      $self->log('notice',"check_alert::[INFO] $monitor [CLEAR-ALERT: alert_id=$alert_id IP=$ip id_metric=$id_metric_clr| EV=$ev | MSG=$msg_log]");

      	   #Se actualiza notif_alert_clear (notificationsd evalua si hay que enviar aviso)
         	$store->store_notif_alert($dbh, 'clr', { 'id_alert'=>$alert_id, 'id_device'=>$id_device, 'id_alert_type'=>20, 'cause'=>$label, 'name'=>$name, 'domain'=>$domain, 'ip'=>$ip, 'notif'=>0, 'mname'=>$mname, 'watch'=>'', 'id_metric'=>$id_metric_clr, 'type'=>$type, 'severity'=>$severity, 'event_data'=>$msg, 'date'=>$date_last  });

	         # Se actualizan las tablas del interfaz
   	      $store->store_alerts_read_local_clr($dbh,$alert_id);
      	   my $vk=$id_remote_alert.'.'.$ip;
         	#if (exists $alert2views->{$vk}) { $store->analize_views_ruleset($dbh,$cid);  }

			}
      }

      else {
         $self->log('warning',"check_alert::[WARN] $monitor [SIN ACCION (A=$action): IP=$ip | EV=$ev | MSG=$msg]");
       }
   }

}


#------------------------------------------------------------------------------------------
# set_app_lock
#------------------------------------------------------------------------------------------
sub set_app_lock {
my ($self,$app_id)=@_;

	my $file='/var/run/'.$app_id.'.lock';
	my $rc = open (F,">$file");
	if ($rc) {
		print F "$$\n";
		close F;
	}
	$self->log('info',"set_app_lock:: $file");
}

#------------------------------------------------------------------------------------------
# clear_app_lock
#------------------------------------------------------------------------------------------
sub clear_app_lock {
my ($self,$app_id)=@_;

   my $file='/var/run/'.$app_id.'.lock';
	my $rc = unlink $file;
	$self->log('info',"clear_app_lock:: $file");
}


1;
__END__


