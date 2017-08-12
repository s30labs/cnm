#####################################################################################################
# Fichero: Crawler::Xagent.pm
# Revision: Ver $VERSION
# Descripción: Clase Crawler::Xagent
# Set Tab=3
#
#do_task
#  modules_supported
#     mod_xagent_get
#        core_xagent_get
#            execScript
#
#
#chk_metric						(validate_metric)
#  modules_supported
#    mod_xagent_get
#        core_xagent_get
#            execScript
#
#mod_xagent_get_iids
#  core_xagent_get
#    execScript
#
#
#proxy-exec
#	execScript
#
#####################################################################################################
use Crawler;
package Crawler::Xagent;
@ISA=qw(Crawler);
$VERSION='1.00';
use strict;
use POSIX ":sys_wait_h";
use Digest::MD5 qw(md5_hex);
use MIME::Base64;
use SOAP::Lite;
use Metrics::Base;
use ONMConfig;
use ProxyCNM;
use Data::Dumper;
#use IO::CaptureOutput qw/capture/;
use Capture::Tiny ':all'; 
use Net::OpenSSH;
#use Time::HiRes qw(gettimeofday tv_interval);
use Time::HiRes;
use File::Basename;

#----------------------------------------------------------------------------
# XAGENT_CACHE_VERSION Almacena la version del agente instalado en los diferenets
# equipos. Necesario para saber si el agente responde y tener control sobre la
# arquitectura del equipo win32/linux
# $XAGENT_CACHE_VERSION{$ip}=[$rc,$rcstr,$res]
#
# XAGENT_CACHE_DATA Almacena los datos de las metricas con iids
# $XAGENT_CACHE_DATA{$task_id}=[$rc,$rcstr,$res]
my %XAGENT_CACHE_DATA=();
my %XAGENT_CACHE_ERRORS=();
my %XAGENT_CACHE_RAW=();

my %DATA_DIFF=();

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
my $ETXT='KEY-ERROR';

#----------------------------------------------------------------------------
use constant STAT_BAJA => 1;
use constant STAT_MANT => 2;
use constant STAT_ERASE => 3;

#----------------------------------------------------------------------------
$Crawler::Xagent::XAGENT_METRICS_BASE_PATH='/opt/data/mdata/scripts';

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Xagent
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

#	BEGIN {
#   	$ENV{'HTTPS_CERT_FILE'}='/etc/client.crt';
#   	$ENV{'HTTPS_KEY_FILE'}='/etc/client.key';
#   	$ENV{'HTTPS_CERT_PASS'}='';
#   	$ENV{'HTTPS_DEBUG'}='';
#	};

   my $self=$class->SUPER::new(%arg);
   $self->{_cfg} = $arg{cfg} || '';
   $self->{_timeout} = $arg{timeout} || 70;
   $self->{_retries} = $arg{retries} || 2;
   $self->{_version1} = $arg{version1} || '3.23.54';
   $self->{_version2} = $arg{version2} || '1.0.40';

   $self->{_script_dir} = $arg{script_dir} || $Crawler::Xagent::XAGENT_METRICS_BASE_PATH;

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
# version1
#----------------------------------------------------------------------------
sub version1 {
my ($self,$version) = @_;
   if (defined $version) {
      $self->{_version1}=$version;
   }
   else { return $self->{_version1}; }
}

#----------------------------------------------------------------------------
# version2
#----------------------------------------------------------------------------
sub version2 {
my ($self,$version) = @_;
   if (defined $version) {
      $self->{_version2}=$version;
   }
   else { return $self->{_version2}; }
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


#------------------------------------------------------------------------------
sub clear_cache  {
my $self=shift;

   #%XAGENT_CACHE_VERSION=();
	%XAGENT_CACHE_ERRORS=();
   %XAGENT_CACHE_DATA=();
   %XAGENT_CACHE_RAW=();
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
# do_task
#----------------------------------------------------------------------------
sub do_task  {
my ($self,$lapse,$range)=@_;
my $NM=0; 	#Numero de metricas a procesar
my $NU=0;	#Numero de metricas a con respuesta=U
my $ok=0;

	my $log_level=$self->log_level();
   my $FXM=Crawler::FXM::Plugin->new(log_level=>$log_level, 'xagent'=>$self);
   $self->fxm($FXM);

   $self->init_tmark();
   my $sanity_lapse = $Crawler::SANITY_LAPSE + int(rand(3600));

   #Ajustes de real_lapse
   my $real_lapse = $self->real_lapse($lapse);

   while (1) {

      %DATA_DIFF=();
		$self->clear_cache();

      my $ts=time;
      $self->sanity_check($ts,$range,$sanity_lapse);


		my $store=$self->store();
		my $dbh=$self->dbh();
		($dbh,$ok)=$self->chk_conex($dbh,$store,'proxy_list');
      if (! $ok) {
			sleep 10;
			next;
		}

      # -----------------------------------------------------------------------
		$store->scripts2cache($dbh);

      # -----------------------------------------------------------------------
      # Si no hay link, no se ejecutan las tareas
      my @task=();
      my $link_error=$self->check_if_link('eth0');
      if ($link_error <= 0) {
         my $rx = $store->get_crawler_task_from_work_file($range,'xagent',\@task);
         if (! defined $rx) {
            $self->log('info',"do_task::[INFO] ***TERMINATE*** SIN TAREA PARA $range");
            exit 0;
         }
      }
      else {
         $self->log('warning',"do_task::[WARN] **NO LINK** (error=$link_error)");
      }

      $NM=scalar @task;
      my $mode_flag=$self->mode_flag();
      my ($a,$b,$c)=($mode_flag->{'rrd'}, $mode_flag->{'alert'}, $mode_flag->{'db'});
      $self->log('info',"do_task::[INFO] -R- xagent.$lapse|IDX=$range|NM=$NM [rrd=$a alert=$b db=$c]");

my $dump1=Dumper(\@task);
$dump1 =~ s/\n/ /g;
$self->log('debug',"do_task::[DUMPER] task=$dump1");
$self->log('debug',"do_task::[DUMPER] store=$store dbh=$dbh");

      my $tnext=time+$real_lapse;

		$NU=0;
		my $p = $store->get_proxy_list($dbh);
		$self->proxies($p);

$dump1=Dumper($p);
$dump1 =~ s/\n/ /g;
$self->log('debug',"do_task::[DUMPER] proxies=$dump1");

		my $nt=0;
      foreach my $desc (@task) {

			$desc->{'lapse'}=$lapse;
         my $task_name=$desc->{module};
			# ip_script_md5(params)_tag
			$desc->{'md5par'} = substr(md5_hex($desc->{'params'}),0,8);
			#10.2.254.222-snmp_metric_count_proc_multiple_devices-76e3f849-001.inetd	
			my $task_id=$desc->{'id_proxy'}.'-'.$desc->{host_ip}.'-'.$desc->{'script'}.'-'.$desc->{'md5par'}.'-'.$desc->{'tag'};
			if ($desc->{'cfg'} == 2) { $task_id .= '.'.$desc->{'iid'}; }


			#my $task_id=$desc->{host_ip}.'-'.$desc->{name};
			$self->task_id($task_id);

#DBG--
         $self->log('info',"do_task:: ========== TAREA=$task_id ($task_name)" );
#/DBG--

         if (($desc->{'cfg'} == 2) && ($desc->{'iid'} eq 'U')) {
            $self->log('info',"do_task:: SALTO TAREA=$task_id ($task_name)" );
            next;
         }

         #----------------------------------------------------
         my $idmetric=$desc->{idmetric};
         if (! defined $idmetric) {
            $self->log('info',"do_task::[WARN] desc SIN IDMETRIC @{[$desc->{name}]} $task_name >> @{[$desc->{host_ip}]} @{[$desc->{host_name}]}");
         }

			my $tp1=Time::HiRes::time();
         #----------------------------------------------------
			my ($iids,$rv,$ev)=$self->modules_supported($desc);
			if ((defined $rv->[0]) && ($rv->[0] eq 'U')) {  $NU+=1; 	}

         #----------------------------------------------------
         $nt += 1;
         my $tpdiffx=Time::HiRes::time()-$tp1;
         my $tpdiff=sprintf("%.3f", $tpdiffx);
         $self->log('debug',"do_task::**PROFILE** [$nt|$NM|LAPSE=$tpdiff] TAREA=$task_id [@$rv] WATCH=$desc->{watch}" );

      }


      #----------------------------------------------------
      # 'mon_icmp' => [
      #                 {
      #                   'data' => '1281522011:0.002307',
      #                   'iddev' => '181',
      #                   'iid' => ''
      #                 },

      # Se almacenan datos diferenciales
      $ts=time;

      foreach my $cid_mode_subtype_subtable (keys %DATA_DIFF) {
         my ($cid,$mode_subtype_subtable)=split(/\./,$cid_mode_subtype_subtable);
         my $f=$ts.'-xagent-'.$lapse.'-'.$mode_subtype_subtable.'-'.$range;
         my $ftemp='.'.$f;

         my $output_dir="$Crawler::MDATA_PATH/output/$cid/m";
         if (! -d $output_dir) {
            mkdir "$Crawler::MDATA_PATH/output";
            mkdir "$Crawler::MDATA_PATH/output/$cid";
            mkdir $output_dir;
         }

         open (D, ">$output_dir/$ftemp");
         foreach my $d (@{$DATA_DIFF{$cid_mode_subtype_subtable}}) {
            print D $d->{'iddev'}.';',$d->{'iid'}.';'.$d->{'data'}."\n";
         }
         close D;
         rename "$output_dir/$ftemp","$output_dir/$f";
         $self->log('debug',"do_task::[DEBUG] Creado fichero $output_dir/$f");
      }

      #----------------------------------------------------


      #----------------------------------------------------
      if ($Crawler::TERMINATE == 1) {
         $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
         exit 0;
      }
      my $wait = $tnext - time;
      if ($wait < 0) {
			$self->log('warning',"do_task::[WARN] *S* xagent.$lapse|$real_lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
      }
      else {

         $self->log('info',"do_task::[INFO] -W- xagent.$lapse|$real_lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
         sleep $wait;
      }
      #----------------------------------------------------
      if ($Crawler::TERMINATE == 1) {
         $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
         exit 0;
      }

      #if ($descriptor->{once}) {exit;}

   }
}

#----------------------------------------------------------------------------
# Funcion: modules_supported
#----------------------------------------------------------------------------
# Descripcion:
#	1.	mod_xagent_get
#		1.1 --> core_xagent_get + create/update_rrd + mod_alert
# OUT:
# 	$rv = Referencia a un ARRAY con los datos de la metrica.
#	$ev = Referencia a un ARRAY con los datos del evento.
#
#----------------------------------------------------------------------------
sub modules_supported  {
my ($self,$desc)=@_;
my $rv=undef;
my $iids=undef;
my $ev=undef;


   #----------------------------------------------------
   my $ip=$desc->{'host_ip'};
	my $id_proxy=$desc->{'id_proxy'};
	my $proxies=$self->proxies();

	$rv=$self->get_proxy_credentials($id_proxy,$proxies);

   #----------------------------------------------------
	$self->event_data([]);
	$self->response('OK');
	my $module=$desc->{'module'};

   if ($module =~ /mod_xagent_get/i) {
		($iids,$rv,$ev)=$self->mod_xagent_get($desc);
	}

   else {$self->log('warning',"modules_supported::[WARN] No definido modulo: $module"); }

	return ($iids,$rv,$ev);
}


#-------------------------------------------------------------------------------------------
# Funcion: chk_metric
#-------------------------------------------------------------------------------------------
# Descripcion:
#     Valida una determinada metrica XAGENT, del tipo que sea (en modules_supported)
#     Valida un monitor aplicado sobre una metrica XAGENT
#     Valida el caso especial de sin respuesta xagent (mon_xagent)
#
# IN:
#
#  1. $in es una ref a hash con los datos necesarios para identificar metrica+dispositivo.
#     Hay 2 opciones (mejor la a.):
#        a. $in->{'host_ip'} && $in->{'mname'}. Valida a partir de la ip y el nombre de la metrica en cuestion
#        b. $in->{'id_dev'} && $in->{'id_metric'}. Valida a partir del id del device y del id de la metrica en cuestion.
#     El resto de datos se obtienen de la tbla cfg_monitor_agent
#
# OUT:
#     1. El parametro $results es una ref a un array pare guardar los resultados
#     2. El valor de retorno es 0->Sin alerta/1->Con alerta
#     3. El metodo event_data debe contener el evento que ha generado alerta para que notificationsd
#        acceda a dicha info.
#		4. El metodo severity contiene el valor de la severidad de la alerta si el retorno es 1.
#-------------------------------------------------------------------------------------------
sub chk_metric {
my ($self,$in,$results,$store)=@_;

#   my $store=$self->create_store();
#   my $dbh=$store->open_db();
#   $self->dbh($dbh);

   if (! defined $store) {
      $store=$self->create_store();
      my $dbh=$store->open_db();
      $self->dbh($dbh);
		$store->dbh($dbh);
   }

   my $dbh=$store->dbh();
	$self->watch(0);

	#--------------------------------------------------------------------------------------
#   my $task_id=$in->{host_ip}.'-'.$in->{mname};
#   $self->task_id($task_id);


   my ($ip,$mname)=($in->{'host_ip'}, $in->{'mname'});

	#--------------------------------------------------------------------------------------
	if ( (! defined $ip) && (! defined $mname) ) {

	   if ( (defined $in->{'id_dev'}) && (defined $in->{'id_metric'}) ) {
   	   # Buscamos ip y mname y los metemos en in
      	my $rres=$store->get_from_db( $dbh, 'ip', 'devices', "id_dev=$in->{id_dev}");
	      $ip=$rres->[0][0];
   	   $rres=$store->get_from_db( $dbh, 'name', 'metrics', "id_metric=$in->{id_metric}");
      	$mname=$rres->[0][0];
   	}

   	if ( (! defined $ip) && (! defined $mname) ) {
      	# No podemos hacer el chequeo
      	$results= [ 'ERROR. NO HAY DATOS' ];
     		return;
		}
   }


   my $p = $store->get_proxy_list($dbh);
   $self->proxies($p);

my $dump1=Dumper($p);
$dump1 =~ s/\n/ /g;
$self->log('debug',"chk_metric::[DUMPER] proxies=$dump1");

#	#--------------------------------------------------------------------------------------
#	# El parametro de entrada es mname (metrica instanciada) pero en la consulta de cfg_monitor_agent necesitamos el subtype
#	# Si cfg=1 (sin iids) => subtype = mname
#	# Si cfg=2 (con iids) => subtype	= mname sin la info de iids
#   my $subtype=$mname;
#   my $iid='ALL';
#
#   if ($mname =~ /^(\S+)-\w+$/) {
#      $subtype=$1;
#		my $rres=$store->get_from_db( $dbh, 'iid','metrics',"name=\'$mname\'");
#      $iid=$rres->[0][0];
#   }
#
##print "IP=$ip  MNAME=$mname  IID=$iid";
#
#	#--------------------------------------------------------------------------------------
#	my $log_level=$self->log_level();
#   my $FXM=Crawler::FXM::Plugin->new(log_level=>$log_level, 'xagent'=>$self);
#   $FXM->subtype($subtype);
#   $self->fxm($FXM);


	my $subtype=$mname;
	if ($mname =~ /^(\S+)-\w+$/) { $subtype=$1; }

	#--------------------------------------------------------------------------------------
	# Obtengo los parametros necesarios para poder validar la metrica solicitada.
	# Los datos relevantes de la metrica se obtienen de cfg_monitor_agent
	# Los del dispositivo de devices (datos de acceso)
	# a partir de $ip (clave en devices) y subtype (clave en cfg_monitor_agent)
	# No interesa cruzar esta tabla con metricas porque al chequear una metrica no aplicada no obtendriamos los datos
	# de configuracion de la metrica y no se podria chequear
   my $rres=$store->get_from_db( $dbh, 'c.class,c.description,c.items,c.module,c.nparams,c.params,c.script,c.cfg,c.severity,c.mode,d.id_dev,c.items,c.custom,c.id_proxy,c.get_iid,c.tag,s.proxy_type,s.proxy_user,c.esp,c.mode', 'cfg_monitor_agent c, devices d, cfg_monitor_agent_script s', " c.script=s.script AND d.ip=\'$ip\' AND c.subtype=\'$subtype\'");

   my %desc=();
   $desc{'host_ip'}=$ip;
   $desc{'name'}=$mname;
   $desc{'class'}=$rres->[0][0];
   #my $DESCR=$rres->[0][1];
	$desc{'descr'}=$rres->[0][1];
   my $items=$rres->[0][2];
   $desc{'module'}=$rres->[0][3];
   $desc{'nparams'}=$rres->[0][4];
   $desc{'params'}=$rres->[0][5];
   $desc{'script'}=$rres->[0][6];
	$desc{'cfg'}=$rres->[0][7];
	my $severity=$rres->[0][8];
	my $mode=$rres->[0][9];
   my $id_dev=$rres->[0][10];
   $desc{'items'}=$rres->[0][11];
   $desc{'custom'}=$rres->[0][12];
   $desc{'id_proxy'}=$rres->[0][13];		#Es el id_dev del proxy
	$desc{'ip_proxy'}=$ip;
	$desc{'subtype'}=$subtype;
   $desc{'get_iid'}=$rres->[0][14];
   $desc{'tag'}=$rres->[0][15];
   $desc{'proxy_type'}=$rres->[0][16];
   $desc{'proxy_user'}=$rres->[0][17];
   $desc{'esp'}=$rres->[0][18];
   $desc{'mode'}=$rres->[0][19];

	
   $desc{'md5par'} = substr(md5_hex($desc{'params'}),0,8);
  	#10.2.254.222-snmp_metric_count_proc_multiple_devices-76e3f849-001.inetd
   my $task_id=$desc{host_ip}.'-'.$desc{'script'}.'-'.$desc{'md5par'}.'-'.$desc{'tag'};
   #if ($desc{'cfg'} == 2) { $task_id .= '.'.$desc{'iid'}; }
   $self->task_id($task_id);



#	my $rres1=$store->get_from_db( $dbh, 'm.iid,m.file', 'metrics m, devices d', "m.id_dev=d.id_dev and  d.ip=\'$ip\' and  m.name=\'$mname\'");
#	$iid=$rres1->[0][0];
#	my $file=$rres1->[0][1] || '';
#
#	if ($desc{'get_iid'}) {
#	#if ($desc{'nparams'} > 0) {
#		$DESCR.= " $iid";
#		$desc{'iid'}=$iid;
#	}
#	else { $desc{'iid'}='ALL'; }
#
#	if ($desc{'id_proxy'} > 0) {
#		$rres1=$store->get_from_db( $dbh, 'ip', 'devices', "id_dev=$desc{'id_proxy'}");
#   	$desc{'ip_proxy'}=$rres1->[0][0];
#	}


	#----------------------------------------------------------------------

   #--------------------------------------------------------------------------------------
   # El parametro de entrada es mname (metrica instanciada) pero en la consulta de cfg_monitor_agent necesitamos el subtype
   # Si cfg=1 (sin iids) => subtype = mname
   # Si cfg=2 (con iids) => subtype = mname sin la info de iids
	$rres=$store->get_from_db( $dbh, 'iid,file', 'metrics', "name=\'$mname\'");
	my ($iid,$file)=('ALL','');
	if (scalar @$rres > 0) {
		$iid=$rres->[0][0];
		$file=$rres->[0][1];
	}

	$desc{'iid'}=$iid;

#print "IP=$ip  MNAME=$mname  IID=$iid";
$self->log('warning',"chk_metric::[**FML**] ++++++++ cfg=$desc{'cfg'} iid=$iid file=$file mname=$mname");

   #--------------------------------------------------------------------------------------
   my $log_level=$self->log_level();
   my $FXM=Crawler::FXM::Plugin->new(log_level=>$log_level, 'xagent'=>$self);
   $FXM->subtype($subtype);
   $self->fxm($FXM);





	#----------------------------------------------------------------------
	#----------------------------------------------------------------------


$self->log('warning',"chk_metric::[**FML**] VALIDANDO [ip=$desc{host_ip} mname=$mname] [class=$desc{class} script=$desc{script} module=$desc{module} IID=$desc{'iid'} id_proxy=$desc{'id_proxy'} ip_proxy=$desc{'ip_proxy'} cfg=$desc{'cfg'}] file=$file DESCR=$desc{'descr'} items=$items params=$desc{params}");

   push @$results, ['Metrica:',$desc{'descr'},''];
   push @$results, ['Valores monitorizados:', $items, ''];
#   push @$results, ['Parametros:', $desc{params}, ''];
   my ($iids,$rv,$ev)=$self->modules_supported(\%desc);
   if (! defined $rv) {
      $self->data_out(['U']);
      return 'U';
   }
   $self->data_out($rv);

$self->log('warning',"chk_metric::[**FML**] VALIDADO [rv=@$rv] ev=@$ev");

#FML. REVISAR !!! (rc,rcstr ...)

   my  $event_data=$ev->[0];
   if (ref($rv) ne 'ARRAY') { $rv=['sin datos']; }
   if (ref($ev) ne 'ARRAY') { $ev=[]; }
	my $data_out="@$rv\n";

	# Metricas sin instancias (cfg=1)
	if ($desc{'cfg'} == 1) {
	   push @$results, ['Datos dispositivo:', $data_out];
	}
	elsif ( $desc{'esp'} =~ /TABLE/) { push @$results, ['Datos dispositivo:', $data_out ]; }
	# Para metricas con instancias (cfg=2) hay 2 situaciones:
	# a. Se pregunta por una instancia concreta (una metrica ya instanciada) mname=custom_b56d08e1-f9fcb06a
	# b. Se pregunta portodas las instancias mname=custom_b56d08e1-f9fcb06a
   elsif ($iid eq 'ALL') {
		my $x=0;
      foreach my $r (@$rv) {
			my $right = $iids->[$x].' = '.$r;
			push @$results, [ "Datos dispositivo [$x]: ", $right ];
			$x+=1;
      }
   }
   else {
		my @items=split(/\|/,$desc{'items'});
		my $c=0;
		foreach my $r (@$rv) {
			push @$results, ["Datos dispositivo11 ($items[$c]):", $r];
			$c+=1;
		}
   }

   if (scalar @$ev > 0) { push @$results, ["Datos dispositivo [Ev]:","@$ev",'']; }


   #--------------------------------------------------------------------------------------
   # Hay que contemplar el caso de las metricas diferenciales (counter), porque el watch hay
   # que evaluarlo sobre la diferencia, no sobre el valor absoluto
   my $fpath='/opt/data/rrd/elements/'.$file;
   if (($mode eq 'COUNTER') && ($file) && (-f $fpath)) {
      my $rvd=$store->fetch_rrd_last($file);
      if (!defined $rvd) {
         $self->log('warning',"chk_metric::[WARN] **$desc{host_ip}:$mname MODE=COUNTER RV=UNDEF F=$file**");
      }
#DBG--
      else { $self->log('debug',"chk_metric::[DEBUG] **$desc{host_ip}:$mname MODE=COUNTER [@$rvd] F=$file**"); }
#/DBG--
      push @$results, ['Datos diferenciales:', "@$rvd"];
      #Para evaluar el watch
      $rv=$rvd;
   }


   #--------------------------------------------------------------------------------------
   # Miro si es necesario chequear un monitor asociado a dicha metrica. Solo en el caso en que:
   #  1. La metrica tenga monitor asociado (en alert_type)
   #  2. El monitor este asociado al dispositivo que se esta chequeando
   my $watch=$store->get_from_db( $dbh, 'a.cause,a.severity,a.expr,a.monitor,m.items,m.top_value', 'alert_type a, metrics m,devices d', "m.name=\'$mname\' and m.watch=a.monitor and m.id_dev=d.id_dev and d.ip=\'$ip\'");

   foreach my $w (@$watch) {

      my $cause=$w->[0];
      my $severity=$w->[1];
      my $expr_long=$w->[2];
      my $watch_name=$w->[3];
      my @items = split (/\|/, $w->[4]);
		my $top_value=$w->[5];
	
		#my $rvj = join (', ',@$rv);

		my $rvj = '';
		foreach my $i (0..scalar(@items)-1) {
			my $x=$i+1;
			#$rvj.='v'.$x.':  '.$items[$i].' = '.$rv->[$i]."\n";
			$rvj=' | v'.$x.':  '.$items[$i].' = '.$rv->[$i];
			push @$ev,$rvj;
		}

      my %expresions=();
      if ($expr_long =~ /\:/ )  {
         my @aux=split(/:/,$expr_long);
         my $s=1;
         foreach my $e (@aux) {
            if ($e ne '') {$expresions{$s} = $e;}
            $s +=1;
         }
      }
      else { %expresions=( $severity => $expr_long); }

      foreach my $sev (sort keys %expresions) {

         my $expr=$expresions{$sev};

#DBG--
	      $self->log('debug',"chk_metric::[DEBUG ID=$task_id] **TEST WATCH (2) => $watch_name => $cause|$expr|$sev** expr_long=$expr_long");
#/DBG--

	      my ($condition,$lval,$oper,$rval)=$self->watch_eval($expr,$rv,$file,{'top_value'=>$top_value});

			push @$results, ['Monitor:', "$cause ($expr) ($lval $oper $rval)",''];
      	if ($condition) {
         	#print "ALERTA POR MONITOR: $cause $expr (@$rv)\n";
	         push @$results, ['Resultado:',"**ALERTA** (@$rv)",''];
				my $ev=$self->event_data();
				#push @$ev,"RESULTADO=$rvj **ALERTA ($expr) ($lval $oper $rval)**";
				push @$ev," | **ALERTA ($expr) ($lval $oper $rval)**";
				$self->event_data($ev);
				$self->severity($sev);
				$self->watch($watch_name);
				$self->log('debug',"chk_metric::[DEBUG] ALERTA POR MONITOR: $cause $expr (@$rv) EV=$ev ");
				return 1;
      	}
		}
		push @$results, ['Resultado:',"NO CUMPLE MONITOR/ES",''];
   }

	return 0;
}






#----------------------------------------------------------------------------
# Funcion: mod_xagent_get
#----------------------------------------------------------------------------
# Descripcion:
#  core_xagent_get + rrd + mod_alert
#----------------------------------------------------------------------------
sub mod_xagent_get  {
my ($self,$desc)=@_;
my ($data,$t);

   my $task_id=$self->task_id();
   my $mode_flag=$self->mode_flag();

   #-------------------------------------------------------------------
	my ($iids,$values) = $self->core_xagent_get($desc);

   my $ev=$self->event_data();

   # Este chequeo es por precaucion, pero core_xagent_get no debe devolver nunca undef.
   if (!defined $values) {
      $self->log('warning',"mod_xagent_get:: TAREA=$task_id [$desc->{'name'}] **WARN** VAL=UNDEF class=$desc->{class} script=$desc->{script} items=$desc->{items} EV=@$ev");
   }
		
   else {
#DBG--
$self->log('info',"mod_xagent_get:: TAREA=$task_id [$desc->{'name'}] class=$desc->{class} script=$desc->{script} items=$desc->{items} VAL=@$values** EV=@$ev");
#/DBG--

		if (scalar (@$values) ==0) {
			$self->log('info',"mod_xagent_get:: TAREA=$task_id [$desc->{'name'}] VALUES NO TIENE DATOS class=$desc->{class} script=$desc->{script} items=$desc->{items}** EV=@$ev");
		}

      # Caso de sin respuesta del agente remoto. Obsoleto ???
      if ($values->[0] eq 'NOXAGENT') { return ['NOXAGENT']; }

#      if ( ($desc->{cfg}==2) && ($desc->{iid}eq 'ALL') ) {
#         return ($values,$ev);
#      }


      $t=time;

      my $fxm=$self->fxm();
      my $fx=$desc->{'esp'};
		my $store=$self->store();
		my $mode = (exists $desc->{mode}) ? $desc->{mode} : 'gauge' ;

		# o1|o2|o3....
		my @fxparts=split(/\|/,$fx);
		my $calculate_fx=0;	
		foreach my $x (@fxparts) {
			if ($x !~ /^o\d+$/) { $calculate_fx=1; last; }
		}
	
      if ($calculate_fx) {

			# Si es de tipo counter y lleva asociada una funcion de postprocesado se trata como si fuera de modo gauge 
			# y las diferencias se salculan por fuera del rrd
         if ($mode=~/counter/i) {

            $values=$store->get_delta_from_file($t,$values,$desc->{file});
            $mode='GAUGE';
            #deltas=1357897426:4:9:13467
$self->log('info',"mod_xagent_get::  TAREA=$task_id [$desc->{'name'}] COUNTER ****store_previous**** t=$t deltas=@$values (fx=$fx)");
         }

         $fxm->subtype($desc->{'subtype'});
			$self->log('debug',"mod_xagent_get:: TAREA=$task_id [$desc->{'name'}] fx=$fx fxm=$fxm");
         if ($fx =~ /^TABLE/) {

				my $key=$desc->{host_ip}.'-'.$desc->{'script'}.'-'.$desc->{'md5par'}.'-'.$desc->{'tag'};
				$self->log('debug',"mod_xagent_get:: TAREA=$task_id [$desc->{'name'}] fx=$fx fxm=$fxm (key=$key)");
#values=$VAR1 = [           '1248:@:"notRunning"',           '1376:@:"notRunning"',

				my @raw_values=();
            foreach my $i (sort keys %{$XAGENT_CACHE_RAW{$key}}) {
					my $v = $XAGENT_CACHE_RAW{$key}->{$i}->{'v'};
					push @raw_values, $i.':@:'.$v;
				}	
				$self->log('debug',"mod_xagent_get:: TAREA=$task_id [$desc->{'name'}] ****raw_values=@raw_values**** ");
            $values=$fxm->parse_fx($fx,\@raw_values,$desc);
         }
         else {
            $values=$fxm->parse_fx($fx,$values,$desc);
         }
      }

		my $lapse = (exists $desc->{lapse}) ? $desc->{lapse} : 300 ;
      if ($mode=~/gauge/i) {
         if ($lapse !~ /\d+/) { $lapse=300; }
         my $t1 = $t - ($t % $lapse);
         $t=$t1;
      }

      my $items = scalar @$values;
      $data=join(':',$t,@$values);

		$self->log('info',"mod_xagent_get:: ++++++++++ TAREA=$task_id [$desc->{'name'}] RESULTADO = $data [cfg=$desc->{'cfg'}|custom=$desc->{'custom'}|EV=@$ev]");

      if ( $mode_flag->{rrd} ) {

         # Almacenamiento RRD --------------------------
         #my $rrd=$desc->{file_path}.$desc->{file};
         my $rrd=$self->data_path().$desc->{file};
         my $store=$self->store();

         if ($store) {
            #my $mode=$desc->{mode};
            #my $lapse=$desc->{lapse};
            my $type=$desc->{mtype};
            if (! -e $rrd) { 
					$store->create_rrd($rrd,$items,$mode,$lapse,$t-600,$type); 
	            my $d600=join(':',$t-600,@$values);
   	         $store->update_rrd($rrd,$d600);
      	      my $d300=join(':',$t-300,@$values);
         	   $store->update_rrd($rrd,$d300);
				}
            my $r = $store->update_rrd($rrd,$data);
            if ($r) {
               my $ru = unlink $rrd;
               $self->log('info',"mod_xagent_get::[DEBUG ID=$task_id] Elimino $rrd  ($ru)");
               $store->create_rrd($rrd,$items,$mode,$lapse,$t-600,$type);
               my $d600=join(':',$t-600,@$values);
               $store->update_rrd($rrd,$d600);
               my $d300=join(':',$t-300,@$values);
               $store->update_rrd($rrd,$d300);

               $store->update_rrd($rrd,$data);
            }
         }
      }
      if ( $mode_flag->{'db'} ) {
         my $cid='default';
         if (exists $desc->{'cid'}) { $cid=$desc->{'cid'}; }
         if ( ($cid eq "") || ($desc->{mode} eq "") | ($desc->{'subtype'} eq "") ){
            $self->log('info',"mod_xagent_get:: VALORES NO VALIDOS $desc->{iddev}.$desc->{subtype} cid=$cid mode=$desc->{mode} subtype=$desc->{subtype}");
         }
         else {
	         my $cid_mode_subtype_subtable=$cid.'.'.$desc->{mode}.'-'.$desc->{'subtype'}.'-'.$desc->{'subtable'};
   	      push @{$DATA_DIFF{$cid_mode_subtype_subtable}}, {'iddev'=>$desc->{'iddev'}, 'iid'=>$desc->{'iid'}, 'data'=>$data};
			}
      }
   }

   # Control de alertas --------------------------
   $ev=$self->event_data();
	if ( ($mode_flag->{'alert'}) && ($desc->{'status'}==0) ) {
      my $idmetric=$desc->{idmetric};
      my $monitor=$desc->{module}.'&&'.$desc->{class};
$self->log('debug',"mod_xagent_get::[DEBUG ID=$task_id] ***FML*** monitor=$monitor idmetric=$idmetric data=$data");
      $self->mod_alert($monitor,$data,$desc,$ev);
   }

   return ($iids,$values,$ev);
}




#----------------------------------------------------------------------------
# Funcion: mod_xagent_get_iids
#----------------------------------------------------------------------------
# Descripcion:
#  IN: $desc con los siguientes campos:
#  custom	:	De usuario / De base. Permite seleccionar el path adecuado
#	host_ip	:	IP del equipo
#	script	:	Script a ejecutar
#	params	:	Parametros del script
#----------------------------------------------------------------------------
sub mod_xagent_get_iids  {
my ($self,$desc)=@_;
my ($data,$t);

   #-------------------------------------------------------------------
	my $store = $self->store();
	my $dbh=$self->dbh();
   my $proxies = $store->get_proxy_list($dbh);
   $self->proxies($proxies);

my $dump1=Dumper($proxies);
$dump1 =~ s/\n/ /g;
$self->log('info',"chk_metric::[DUMPER] DBH=$dbh *****proxies=$dump1");

   my $ip=$desc->{'host_ip'};
   my $id_proxy=$desc->{'id_proxy'};

#print "id_proxy=$id_proxy\n";
#print Dumper($proxies);

	my $rv=$self->get_proxy_credentials($id_proxy,$proxies);

   my $exec_vector=$self->exec_vector();

   #proxy_host
   if (! exists $proxies->{$id_proxy}->{'proxy_host'}) {
      $self->log('warning',"mod_xagent_get_iids::[WARN] id_proxy=$id_proxy no tiene proxy_host");
   }
   else { $exec_vector->{'proxy_host'}=$proxies->{$id_proxy}->{'proxy_host'}; }

   #proxy_port
   if (! exists $proxies->{$id_proxy}->{'proxy_port'}) {
      $self->log('warning',"mod_xagent_get_iids::[WARN] id_proxy=$id_proxy no tiene proxy_port");
   }
   else { $exec_vector->{'proxy_port'}=$proxies->{$id_proxy}->{'proxy_port'}; }


   #proxy_type
   if (! exists $proxies->{$id_proxy}->{'proxy_type'}) {
      $self->log('warning',"mod_xagent_get_iids::[WARN] id_proxy=$id_proxy no tiene proxy_type");
   }
   else { $exec_vector->{'proxy_type'}=$proxies->{$id_proxy}->{'proxy_type'}; }

   #proxy_user
   if (! exists $proxies->{$id_proxy}->{'proxy_user'}) {
      $self->log('warning',"mod_xagent_get_iids::[WARN] id_proxy=$id_proxy no tiene proxy_user");
   }
   else { $exec_vector->{'proxy_user'}=$proxies->{$id_proxy}->{'proxy_user'}; }

   #proxy_pwd
   if (! exists $proxies->{$id_proxy}->{'proxy_pwd'}) {
      $self->log('warning',"mod_xagent_get_iids::[WARN] id_proxy=$id_proxy no tiene proxy_pwd");
   }
   else { $exec_vector->{'proxy_pwd'}=$proxies->{$id_proxy}->{'proxy_pwd'}; }

	#my $exec_vector=$self->exec_vector();
   $exec_vector->{'host_ip'}=$ip;
	$self->exec_vector($exec_vector);

#print Dumper($exec_vector);

   #-------------------------------------------------------------------
	$desc->{'iid'}='ALL';
   my ($iids,$values) = $self->core_xagent_get($desc);

$self->log('warning',"mod_xagent_get_iids::*********** values=@$values iids=@$iids");



   # Este chequeo es por precaucion, pero core_xagent_get no debe devolver nunca undef.
   if (!defined $values) {
      $self->log('warning',"mod_xagent_get_iids::[WARN] VAL=UNDEF custom=$desc->{custom} script=$desc->{script} params=$desc->{params}");
		return;
   }

#DBG--
$self->log('debug',"mod_xagent_get_iids::[DEBUG] custom=$desc->{custom} script=$desc->{script} params=$desc->{params} VAL=@$values** IIDS=@$iids");
#/DBG--

   # Caso de sin respuesta del agente remoto
   if ($values->[0] eq 'NOXAGENT') { return ['NOXAGENT']; }


#1:      <001.acpid> Num. procesos [acpid] = 1
#2:      <001.actionsd> Num. procesos [actionsd] = 1

#	my @iids=();
#	foreach my $l (@$values) {
#		if ($l =~ /<(\S+\.\S+)>/) { push @iids, $1; }
#		elsif ($l =~ /<(\S+)>/) { push @iids, $1; }
#		else { $self->log('warning',"mod_xagent_get_iids:: NO DETECTO IID EN: $l");}
#	}

	#return \@iids;
	return $iids;

}



#----------------------------------------------------------------------------
# Funcion: core_xagent_get
# Descripcion
#  Ejecuta los comandos especificados en el fichero $desc->{'monitor'} en el 
#  equipo local y obtiene los resultados correspondientes.
#	En este caso no hay comunicacion con ningun agente remoto.
#
#  Devuelve una referencia a un array con dichos valores
#  IN: $desc >>>> referencia a hash con los datos necesarios
#     $desc->{'monitor'} : Fichero con el programa a ejecutar
#
#  OUT:
#  Devuelve una referencia a un array ($values) con los valores obtenidos.
#  En los metodos $self->err_str() y $self->err_num() almacena el codigo
#  y el mensaje de error obtenido.
#  Si todo ha sido correcto err_num=0 y err_str=OK
#
#----------------------------------------------------------------------------
sub core_xagent_get  {
my ($self,$desc)=@_;

   my $task_id=$self->task_id();

   $self->err_str('[OK]');
   $self->err_num(0);
   my @values=();
   my @iids=();
   my @items=();
   my $out_cmd=[];
   my @ev=();
   if (exists $desc->{'items'}) {
      @items=split(/\|/,$desc->{'items'});
   }
   my $num_values=scalar (@items);
   $self->event_data([]);
   my $server=$desc->{'host_ip'};

  	my $file_script=$self->script_dir().'/'.$desc->{'script'};

	# ---------------------------------------------------------------
   # Obtengo el contenido del script a ejecutar
	if (! exists $desc->{'script'}) {
		$self->log('warning',"core_xagent_get::[WARN] La metrica no tiene script asociado ($file_script)");
		my ($rc,$rcstr)=(111,'[ERROR]');
      $self->err_str($rcstr);
      $self->err_num($rc);
      for my $i (0..$num_values-1) { push @values, 'U';  push @iids, 'U'; }
      $self->event_data(["Metrica sin script asociado RC=$rc ($rcstr)"]);
      return (\@iids,\@values);
   }


	my $store=$self->store();
	my $dbh=$self->dbh();
   if (! -f $file_script) {
      $store->script2file($dbh,$desc->{'script'});
   }


   if (!-f $file_script) {
		$self->log('warning',"core_xagent_get::[WARN] No existe el script $file_script");
		my ($rc,$rcstr)=(110,'[ERROR]');
      $self->err_str($rcstr);
      $self->err_num($rc);
      for my $i (0..$num_values-1) { push @values, 'U'; push @iids, 'U'; }
      $self->event_data(["Metrica sin script asociado RC=$rc ($rcstr)"]);
		return (\@iids,\@values);
   }


	# ---------------------------------------------------------------
   my $exec_vector=$self->exec_vector();
   $exec_vector->{'file_script'}=$file_script;
	my $credentials = $store->get_device_credentials($dbh,{'ip'=>$server});

   $exec_vector->{'params'}=$self->_compose_params($desc->{'params'},$desc->{'host_ip'},$credentials);
	$exec_vector->{'task_id'}=$task_id;
	$exec_vector->{'host_ip'}=$desc->{'host_ip'};
	$exec_vector->{'timeout'} = (exists $desc->{'timeout'}) ? $desc->{'timeout'} : $self->timeout();

	# Para el caso de metricas con lapse=3600, se sube el timeout
	if ( (exists $desc->{'lapse'}) && ($desc->{'lapse'}==3600)) { $exec_vector->{'timeout'} *=5; }

#fml revisar
#	$exec_vector->{'proxy_type'}=$desc->{'proxy_type'};
#	$exec_vector->{'proxy_user'}=$desc->{'proxy_user'};


	#$exec_vector->{'proxy_type'}=$desc->{'class'};
   $self->exec_vector($exec_vector);

	my $iidx=$desc->{'iid'};
	my $tag=$desc->{'tag'};
	my @all_metric_tags=split(/\|/,$tag);

   if (! exists $desc->{'md5par'}) {
      $desc->{'md5par'} = substr(md5_hex($desc->{'params'}),0,8);
   }
   my $task_id_base=$desc->{host_ip}.'-'.$desc->{'script'}.'-'.$desc->{'md5par'};

   #-------------------------------------------------------------------
   # METRICAS SIN IIDS
   #-------------------------------------------------------------------
   if ($desc->{'cfg'} == 1) {
   #-------------------------------------------------------------------

	   my $INCACHE=1;
   	# Si hay 1 item $tag es un valor tipo: 501
		# task_id >> 1-10.2.254.231-linux_metric_vmware_performance.pl-b1a408b9-101
		# Si hay N items $tag es del tipo 501|500|502 (elementos separados por "|")
		# task_id >> 1-10.2.254.231-linux_metric_vmware_performance.pl-b1a408b9-201|202|203|204|205|206
   	foreach my $tagx (@all_metric_tags) {
      	my $task_id_searched = $task_id_base .'-'.$tagx;
      	if (! exists $XAGENT_CACHE_DATA{$task_id_searched}) { $INCACHE=0; }
   	}

$self->log('info',"core_xagent_get:: cfg=1 INCACHE=$INCACHE task_id=$task_id");

		# no lo vuelvo a ejecutar hasta el proximo ciclo de poolling.
		if ( exists $XAGENT_CACHE_ERRORS{$task_id_base}) {
         $ev[0]="No se ejecuta script: $desc->{'script'} - ERROR PREVIO";
         $self->event_data(\@ev);
			$self->log('info',"core_xagent_get::TASK_ID=$task_id **ERROR PREVIO. NO EJECUTO SCRIPT**");
		}
		# Si el valor no esta en CACHE ejecuto el script
		#elsif (! exists $XAGENT_CACHE_DATA{$task_id_searched}) { 
		elsif (! $INCACHE) { 

			$out_cmd=$self->execScript();
   	   my $rcstr=$self->err_str();
      	my $rc=$self->err_num();
      	$ev[0] = "Ejecutado script: $desc->{'script'} (RC=$rc) RCSTR=$rcstr";
         if (exists $desc->{'descr'}) { $ev[1] = 'Metrica: '.$desc->{'descr'}; }

			$self->event_data(\@ev);

			if ($rc>0) {
				$XAGENT_CACHE_ERRORS{$task_id_base}=[$rc, $rcstr, \@ev];
			}

			#Necesario para evitar volver a ejecutar el script si cambian las instancias.
			$XAGENT_CACHE_DATA{$task_id_base}=1;

         foreach my $l (@$out_cmd) {

				my ($prefix,$parsed_line)=('','');
            if ($l =~ /^<(.*?)>.*?\=\s*(.*?)\s*$/) { 
					($prefix,$parsed_line)=($1,$2);  
					if ($parsed_line eq '') { $parsed_line='U'; }
				}
            else { $parsed_line=$l; }

            my @parsed_out_cmd=split(':', $parsed_line);
            my $key = $task_id_base .'-'.$prefix;
				$self->log('info',"core_xagent_get:: [task_id=$task_id] cfg=1 CACHEFILL KEY=$key VAL=@parsed_out_cmd");

				my $ip = $desc->{host_ip};
				$XAGENT_CACHE_ERRORS{$ip} = [$rc, $rcstr, \@parsed_out_cmd];

            $XAGENT_CACHE_DATA{$key}=[$rc, $rcstr, \@parsed_out_cmd];
         }
		}
		else {
			$ev[0]="No se ejecuta script: $desc->{'script'} - CACHEGET";
			$self->event_data(\@ev);
			$self->log('info',"core_xagent_get:: [task_id=$task_id] cfg=1 CACHEGET");
		}

     	#$self->log('info',"core_xagent_get::[INFO ID=$task_id] PARAMS=$exec_vector->{'params'} RES=@$out_cmd tag=$tag EV=$ev");

	   foreach my $tagi (@all_metric_tags) {
   	   my $task_idx = $task_id_base.'-'.$tagi;
      	$self->log('debug',"core_xagent_get::[INFO ID=$task_id] OBTENGO VALOR DE $task_idx");
      	foreach my $r (@{$XAGENT_CACHE_DATA{$task_idx}->[2]}) { push @values,$r; push @iids,'ALL'; }
   	}

   }
	
   #-------------------------------------------------------------------
   # METRICAS CON IIDS
   #-------------------------------------------------------------------
   elsif ($desc->{'cfg'} == 2) {
   #-------------------------------------------------------------------

      my $INCACHE=1;
      # Si hay 1 item $tag es un valor tipo: 100
		# task_id >> 1-10.2.254.231-linux_metric_vmware_vminfo.pl-1dadedcc-100.CNM-DEVEL
      # Si hay N items $tag es del tipo 501|500|502 (elementos separados por "|")
		# task_id >> 1-10.2.254.231-linux_metric_vmware_performance.pl-b1a408b9-500|501|502.datastore1
		# En cache la clave es $task_id_base-tag.iid
      foreach my $tagx (@all_metric_tags) {
         my $task_id_searched = $task_id_base .'-'.$tagx.'.'.$desc->{'iid'};
$self->log('info',"core_xagent_get:: cfg=2 BUSCO task_id_searched=$task_id_searched");

         # Para el cache de la provision
         if ($desc->{'iid'} eq 'ALL') {
            my $key_raw=$task_id_base .'-'.$tagx;
            my @iids = keys %{$XAGENT_CACHE_RAW{$key_raw}};
            #Con buscar el primer valor me vale
            if (scalar(@iids)>0) {
               $task_id_searched = $task_id_base .'-'.$tagx.'.'.$iids[0];
$self->log('info',"core_xagent_get:: cfg=2 BUSCO task_id_searched=$task_id_searched");
            }
         }

         if (! exists $XAGENT_CACHE_DATA{$task_id_searched}) { 
				# Si el $task_id_searched no esta en la cache pero se ha ejecutado el script sobre el equipo con 
				# sus parametros, se supone que la instancia ha sido eliminada. 
				# No es necesario volver a ejecutar el script.
				if ($XAGENT_CACHE_DATA{$task_id_base}) { $XAGENT_CACHE_DATA{$task_id_searched} = [0, '', ['U']]; }
				else { $INCACHE=0; } 
			}
      }

$self->log('info',"core_xagent_get:: cfg=2 INCACHE=$INCACHE task_id=$task_id");

      # Si script+params ha dado error al ejecutarlo contra un dispositivo concreto
      # no lo vuelvo a ejecutar hasta el proximo ciclo de poolling.
      if ( exists $XAGENT_CACHE_ERRORS{$task_id_base}) {
         $ev[0]="No se ejecuta script: $desc->{'script'} - ERROR PREVIO";
         $self->event_data(\@ev);
         $self->log('info',"core_xagent_get::TASK_ID=$task_id **ERROR PREVIO. NO EJECUTO SCRIPT**");
      }
      # Si el valor no esta en CACHE ejecuto el script
#      if (! exists  $XAGENT_CACHE_DATA{$task_id}) {
		elsif (! $INCACHE) {
				
         #10.2.254.71-xagt_000000-d7aa32b0
			$out_cmd=$self->execScript();
         my $rcstr=$self->err_str();
         my $rc=$self->err_num();
         $ev[0] = "Ejecutado script: $desc->{'script'} (RC=$rc) RCSTR=$rcstr";
			if (exists $desc->{'descr'}) { $ev[1] = 'Metrica: '.$desc->{'descr'}.' '.$iidx; }
         else { $ev[1] = 'Instancia: '.$iidx;}

			$self->event_data(\@ev);

         if ($rc>0) {
            my $ip = $desc->{host_ip};
            $XAGENT_CACHE_ERRORS{$ip} = [$rc, $rcstr, \@ev];

            $XAGENT_CACHE_ERRORS{$task_id_base}=[$rc, $rcstr, \@ev];
         }

         #Necesario para evitar volver a ejecutar el script si cambian las instancias.
         $XAGENT_CACHE_DATA{$task_id_base}=1;

         $self->log('info',"core_xagent_get::************tag=$tag iid=$iidx out_cmd=@$out_cmd*** rc=$rc rcstr=$rcstr******");
         # out_cmd=C::6599 D::61521 E::79744 _Total:147864
         # out_cmd=U
			# <001.acpid> Num. procesos [acpid] = 1 
         foreach my $line (@$out_cmd) {

            my @data=();
				# <104.CNM-DEVEL> connectionState = 1 
				#if ($line=~/<(\S+)\.(\S+)>.*?=\s*(\d+\.*\d*)\s*$/) {
				if ($line=~/<(\S+?)\.(.+?)>.*?=\s*(\d+\.*\d*)\s*$/) {
               my ($rtag,$iid,$v) = ($1,$2,$3);
               push @data, $v;

#$VAR1 = [           '1248:@:"notRunning"',           '1376:@:"notRunning"' ]

					my $key_raw = $task_id_base .'-'.$rtag;
					$XAGENT_CACHE_RAW{$key_raw}->{$iid} = {'line'=>$line, 'v'=>$v }; 

					my $key = $task_id_base .'-'.$rtag.'.'.$iid;
   	         $XAGENT_CACHE_DATA{$key}=[$rc, $rcstr, \@data];

      	      $self->log('info',"core_xagent_get::[INFO ID=$task_id] cfg=2 CACHEFILL KEY=$key ----- iid=$iid DATA=@data");
				}
         }
      }
		else {
         $ev[0]="No se ejecuta script: $desc->{'script'} - CACHEGET";
         $self->event_data(\@ev);
			$self->log('info',"core_xagent_get:: [task_id=$task_id] cfg=2 CACHEGET");
		}

my $cdump1=Dumper(\%XAGENT_CACHE_DATA);
#open (F,'>/tmp/XAGENT_CACHE_DATA');
#print F $cdump1;
#close F;
$cdump1 =~ s/\n/ \./g;
$self->log('debug',"do_task::[DUMPER] XAGENT_CACHE_DATA=$cdump1");


      foreach my $tagi (@all_metric_tags) {
         my $task_idx = $task_id_base.'-'.$tagi;
$self->log('debug',"do_task::[****] BUCLE tagi=$tagi (task_idx=$task_idx)");
			if ($iidx ne 'ALL') { 
				$task_idx .= '.'.$iidx; 
         	foreach my $r (@{$XAGENT_CACHE_DATA{$task_idx}->[2]}) { 
					push @values,$r; 
					push @iids, $iidx; 
				}
			}
			else {
				foreach my $i (sort keys %{$XAGENT_CACHE_RAW{$task_idx}}) { 
					my $v = $XAGENT_CACHE_RAW{$task_idx}->{$i}->{'v'};
         		$self->log('debug',"core_xagent_get::[INFO ID=$task_id] ***FML*** $i->$v ($task_idx) ");
					push @values, $v; 
					push @iids, $i; 
				}
			}

         $self->log('debug',"core_xagent_get::[INFO ID=$task_id] (iid=$iidx) OBTENGO VALUES DE $task_idx (@values)");
      }


	}

	# Si el script falla y no devuelve valores se consideran todos nulos
	if (scalar (@values)==0) {
		foreach my $tagi (@all_metric_tags) { push @values,'U';  push @iids, 'U'; }
	}

   $self->log('info',"core_xagent_get::[INFO ID=$task_id] VALUES=@values IIDS=@iids");

   return (\@iids,\@values);
}



#----------------------------------------------------------------------------
# Funcion: _compose_params
# Descripcion:
#  Formatea los parametroa especificados del script que calcula la metrica.
#  Los parametros se obtendrán de los ficheros idx que a su vez se componen con 
#	los datos de la BBDD.
#  El formato es del tipo: 
#	"params":"[-n;Host;;2]:[-r;Resto de equipos;10.2.254.221;0]:[-p;Proceso;apache2;0]"
#
#  OUT:
#
#  Cadena de texto con los parametros formateados para el script
#----------------------------------------------------------------------------
sub _compose_params  {
my ($self,$dbparams,$host_ip,$credentials)=@_;

	my $exec_vector=$self->exec_vector();
	my $params='';

#	#  $dbparams es del estilo: [;Clase;Win32_PerfRawData_PerfOS_System]:[;Atributo;Processes]
#	# [;Clase;Win32_PerfRawData_PerfOS_Memory]:[;Atributo;CacheFaultsPersec:PageFaultsPersec]
#	# No se puede hacer split(/\:/, $dbparams) porque hay ':' para separar items
#	my @class=();
#	my @attr=();
#	my @generic=();

	$host_ip=$self->untag_ip($host_ip);
	my @params2cmd=();
	$self->log('info',"_compose_params exec:: host_ip=$host_ip dbparams=$dbparams");

my $dump1=Dumper($credentials);
$dump1 =~ s/\n/ /g;
$self->log('info',"_compose_params exec ::[DUMPER] credentials=$dump1");


	while ($dbparams =~/\[(.*?);(.*?);(.*?);(.*?)\]/g) {
		my ($prefix,$descr,$value,$param_type)=($1,$2,$3,$4);

		$self->log('debug',"_compose_params:: prefix=$prefix,descr=$descr,value=$value,param_type=$param_type");

		# Si esta definido en el almacen de credenciales se utiliza el valor almacenado
		if (exists $credentials->{$host_ip}->{$value}) { 
			$value = $credentials->{$host_ip}->{$value}; 
		}

      $value =~ s/^"(.*)"$/$1/g;
      if (($value =~ /\S+\s+\S+/) || ($value =~ /\\/)) { $value = '"'.$value.'"'; }

		# Si el parametro es de tipo IP se obtiene de: $desc->{'host_ip'}	
		if ($param_type==2) { $value=$host_ip; }
		push @params2cmd, "$prefix $value";	
	
   }

	$params = join(' ', @params2cmd);

	return $params;
}

#----------------------------------------------------------------------------
# Valida que en los parametros del script no haya credenciales sin sustituir
#----------------------------------------------------------------------------
sub _params_ok  {
my ($self,$params)=@_;

	my $ok=1;
	my @all_tags = ( '\$sec.ssh.user', '\$sec.ssh.pwd', '\$sec.telnet.user', '\$sec.telnet.pwd', '\$sec.wmi.user', '\$sec.wmi.pwd', '\$sec.cifs.user', '\$sec.cifs.pwd', '\$sec.vmware.user', '\$sec.vmware.pwd', '\$sec.http.user', '\$sec.http.pwd', '\$sec.https.user', '\$sec.https.pwd', '\$sec.api.user', '\$sec.api.pwd', '\$sec.webmon.user', '\$sec.webmon.pwd', '\$sec.ipmi.user', '\$sec.ipmi.pwd');

	foreach my $tag (@all_tags) {
#print "tag=$tag params=$params\n";
		if ($params=~/$tag/) { $ok=0; last;}
	}

	return $ok;
}

#-----------------------------------------------------------------------------
# get_proxy_credentials
# Obtiene los parametros de conexion del proxy especificado (por id_proxy)
# y actualiza exec_vector
# La lista de proxies definidos se puede pasar como parametro o en caso 
# contrario se calcula
# Devuelve OK(0) o error(1)
# La info sobre el error se almacena en  err_num y err_str
#-----------------------------------------------------------------------------
sub get_proxy_credentials {
my ($self,$id_proxy,$proxies)=@_;

	if ((!defined $proxies) || (ref($proxies) ne 'HASH')) {
	   my $store=$self->store();
   	my $dbh=$self->dbh();
		$proxies = $store->get_proxy_list($dbh);
	}

	my $err_num=0;
	my $err_str='[OK]';
	my $exec_vector=$self->exec_vector();

   #esta definido el proxy ?
   if (! exists $proxies->{$id_proxy}) {
      $err_num=1;
      $err_str="[ERROR] en definicion de PROXY. id_proxy=$id_proxy NO DEFINIDO";
      $self->err_num($err_num);
      $self->err_str($err_str);
		return $err_num;
   }

	#proxy_host
	if (! exists $proxies->{$id_proxy}->{'proxy_host'}) {
		$err_num=1;
		$err_str="[ERROR] en definicion de PROXY. id_proxy=$id_proxy no tiene proxy_host";
		$self->err_num($err_num);
		$self->err_str($err_str);
	}
	else { $exec_vector->{'proxy_host'}=$proxies->{$id_proxy}->{'proxy_host'}; }

	#proxy_port
	if (! exists $proxies->{$id_proxy}->{'proxy_port'}) {
      $err_num=1;
      $err_str="[ERROR] en definicion de PROXY. id_proxy=$id_proxy no tiene proxy_port";
      $self->err_num($err_num);
      $self->err_str($err_str);
	}
	else { $exec_vector->{'proxy_port'}=$proxies->{$id_proxy}->{'proxy_port'}; }

	#proxy_type
	if (! exists $proxies->{$id_proxy}->{'proxy_type'}) {
      $err_num=1;
      $err_str="[ERROR] en definicion de PROXY. id_proxy=$id_proxy no tiene proxy_type";
      $self->err_num($err_num);
      $self->err_str($err_str);
	}
	else { $exec_vector->{'proxy_type'}=$proxies->{$id_proxy}->{'proxy_type'}; }

	#proxy_user
	if (! exists $proxies->{$id_proxy}->{'proxy_user'}) {
      $err_num=1;
      $err_str="[ERROR] en definicion de PROXY. id_proxy=$id_proxy no tiene proxy_user";
      $self->err_num($err_num);
      $self->err_str($err_str);
	}
	else { $exec_vector->{'proxy_user'}=$proxies->{$id_proxy}->{'proxy_user'}; }

	#proxy_pwd
	if (! exists $proxies->{$id_proxy}->{'proxy_pwd'}) {
      $err_num=1;
      $err_str="[ERROR] en definicion de PROXY. id_proxy=$id_proxy no tiene proxy_pwd";
      $self->err_num($err_num);
      $self->err_str($err_str);
	}
	else { $exec_vector->{'proxy_pwd'}=$proxies->{$id_proxy}->{'proxy_pwd'}; }

	$self->exec_vector($exec_vector);
	return $err_num;

}

#-----------------------------------------------------------------------------
# execScript
#-----------------------------------------------------------------------------
sub execScript   {
my ($self,$myenv)=@_;

   my @response=();
   my @errors=();
	my $cmd='';
   my ($rc,$stdout, $stderr);

   $self->err_str('[OK]');
   $self->err_num(0);

   my $exec_vector=$self->exec_vector();
   my $file_script=$exec_vector->{'file_script'};
   my $params=$exec_vector->{'params'};
   my $proxy_type=$exec_vector->{'proxy_type'};
   my $proxy_user=$exec_vector->{'proxy_user'};
   my $proxy_pwd=$exec_vector->{'proxy_pwd'};
   my $proxy_passphrase=$exec_vector->{'proxy_passphrase'};
   my $proxy_host=$exec_vector->{'proxy_host'};
   my $proxy_port=$exec_vector->{'proxy_port'};
	my $task_id=$exec_vector->{'task_id'} || '';
	my $host_ip=$exec_vector->{'host_ip'};

	local %ENV=();
	$ENV{'CNM_TAG_IP'} = $host_ip;
	if ((defined $myenv) && (ref($myenv) eq 'HASH')) {
		foreach my $k (keys %$myenv) { $ENV{$k} = $myenv->{$k}; }
	}


#	local $SIG{CHLD} = 'IGNORE';
#	local $SIG{CHLD}=sub { my $rc=wait(); $self->log('info',"execScript [$proxy_host]:: **end child** rc=$rc ($?)");};

   local $SIG{CHLD} = sub {

      while ((my $rc = waitpid(-1, &WNOHANG)) > 0) {
         $self->log('info',"execScript [$proxy_host]:: **end child** rc=$rc ($?)");
      }
   };

	$SIG{ALRM} = sub { die "Timeout" };
	my $timeout = (exists $exec_vector->{'timeout'}) ? $exec_vector->{'timeout'} : $self->timeout();

   eval {

		alarm($timeout);


		# ------------------------------------------------------------------
		# PROXY LOCAL
		# ------------------------------------------------------------------
		if ($proxy_host eq 'localhost') {
			$cmd = "/usr/bin/sudo -E -u $proxy_user  $file_script $params";

	      $self->log('info',"execScript [$proxy_host]:: **START** $task_id proxy=$proxy_type Timeout=$timeout CMD=$cmd CNM_TAG_IP=$ENV{'CNM_TAG_IP'}");

			if ($self->_params_ok($params)) {
				$ENV{'PERL_CAPTURE_TINY_TIMEOUT'}=$timeout-5;
				$Capture::Tiny::TIMEOUT=$timeout-5;
				($stdout, $stderr, $rc) = capture {  system( $cmd ); }; 
			}
			else { ($stdout, $stderr, $rc) = ('', "***ERROR DE CREDENCIALES** ($params)",20); }

	      $self->log('debug',"execScript [$proxy_host]:: **END** $task_id proxy=$proxy_type Timeout=$timeout CMD=$cmd CNM_TAG_IP=$ENV{'CNM_TAG_IP'}");

			$self->stdout($stdout);
			$self->stderr($stderr);
			$self->exit_code($rc);

	      @response = split (/\n/, $stdout);
   	   @errors = split (/\n/, $stderr);

		}

      # ------------------------------------------------------------------
      # PROXY REMOTO linux
      # ------------------------------------------------------------------
		elsif (($proxy_type eq 'proxy-linux') || ($proxy_type eq 'linux')) {

         my %SSH_OPTS =( 'port' => $proxy_port, 'user' => $proxy_user, 'password' => $proxy_pwd,
            'master_opts' => [-o => "StrictHostKeyChecking=no"],
            #'passphrase'   =>'',
            #'key_path'  => ''
         );
			my $file_path_remote='/tmp';


         my $ssh = Net::OpenSSH->new($proxy_host, %SSH_OPTS);
         if ($ssh->error) {
            $self->log('info',"execScript [$proxy_host]:: $task_id [ERROR] EN conex a $proxy_host ($ssh->error)");
         }

         my $rc = $ssh->scp_put($file_script,$file_path_remote);
			$self->log('info',"execScript [$proxy_host]:: SCP($rc) $file_script -> $file_path_remote");

			my ($filename, $directories, $suffix) = fileparse($file_script);
			$cmd = "$file_path_remote/$filename $params";

	      $self->log('info',"execScript [$proxy_host]:: $task_id proxy=$proxy_type Tmeout=$timeout CMD=$cmd");

         ($stdout, $stderr) = $ssh->capture2($cmd);

         @response = split (/\n/, $stdout);
         @errors = split (/\n/, $stderr);

      }

      # ------------------------------------------------------------------
		# PROXY REMOTO windows
      # ------------------------------------------------------------------
      elsif ( ($proxy_type eq 'windows') || ($proxy_type eq 'win32')) {

         my %SSH_OPTS =( 'port' => $proxy_port, 'user' => $proxy_user, 'password' => $proxy_pwd,
            'master_opts' => [-o => "StrictHostKeyChecking=no"],
            #'passphrase'   =>'',
            #'key_path'  => ''
         );
			my $proxy_exec_prefix='cscript //NoLogo';

		   my $ssh = Net::OpenSSH->new($proxy_host, %SSH_OPTS);
			if ($ssh->error) { 
				$self->log('info',"execScript [$proxy_host]:: $task_id [ERROR] EN conex a $proxy_host ($ssh->error) ($proxy_port|$proxy_user|$proxy_pwd)"); 
			}

         my ($filename, $directories, $suffix) = fileparse($file_script);

			my $filename_remote = $filename;
			$filename_remote =~ s/^(.*?\.vbs)-\w+$/$1/i;
         my $rc = $ssh->scp_put($file_script,$filename_remote);
			if (! $rc) {
				my $error=$ssh->error();
         	$self->log('warning',"execScript [$proxy_host]:: $task_id **ERROR** SCP ($error) $file_script -> home (filename_remote=$filename_remote)");
			}
			else {
         	$self->log('info',"execScript [$proxy_host]:: $task_id SCP($rc) $file_script -> home (filename_remote=$filename_remote)");
			}
         #$cmd = "$file_path_remote/$filename $params";
         $cmd = "$proxy_exec_prefix $filename_remote $params";

         $self->log('info',"execScript [$proxy_host]:: $task_id proxy=$proxy_type Tmeout=$timeout CMD=$cmd");

         ($stdout, $stderr) = $ssh->capture2($cmd);
		   $stdout =~ s/\r//g;
		   $stderr =~ s/\r//g;




#			my @cmd=('cscript //NoLogo win32_proc.vbs');
#   		($stdout, $stderr) = $ssh->capture2(@cmd);

         @response = split (/\n/, $stdout);
         @errors = split (/\n/, $stderr);

		}

      # ------------------------------------------------------------------
      # ------------------------------------------------------------------
		else {
			$self->log('warning',"execScript [$proxy_host]:: $task_id proxy=$proxy_type **ERROR** TIPO DE PROXY NO CONTEMPLADO");
		}

		alarm(0);
   };

   if ($@) {
      my $err_string=$@;
      $self->log('warning',"execScript [$proxy_host]:: $task_id [ERROR EN EXECSCRIPT] (file_script=$file_script PARAMS=$params) RC=$err_string");
      $self->err_str("[ERROR] en execScript [$proxy_host] RC=$err_string");
      $self->err_num(1);

		$stderr = "**TIMEOUT AL EJECUTAR SCRIPT** Timeout=$timeout ($file_script $params)";
      $self->stderr($stderr);
      $self->exit_code(1);


		# Al terminar, elimino todos los hijos
		# --------------------------------------
		my $child_pids=$self->get_all_child_pids();
		kill 9,@$child_pids;

		return \@response;
   }



	#debug
	$stdout =~ s/\n/\./g;
	$self->log('info',"execScript [$proxy_host]:: **RESULT** $task_id RESPONSE=$stdout");


	if (scalar(@errors)>0) {
		my $err_string = join (' ', @errors);
      $self->err_str("[ERROR] en execScript [$proxy_host] $task_id por STDERR RC=$err_string");
      $self->err_num(100);
 
		$self->log('info',"execScript [$proxy_host]:: $task_id EN STDERR >> $err_string");
	}

   # Al terminar, elimino todos los hijos
   # --------------------------------------
   my $child_pids=$self->get_all_child_pids();
   kill 9,@$child_pids;

   return \@response;

}


#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# FUNCIONES AUXILIARES
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
sub file2var {
my ($self,$file)=@_;

	my $content='';
   my $rc = open INPUT, "<$file";
	if (! $rc) { $self->log('debug',"file2var::[WARN] Error al abrir $file ($!)"); }
	else {
	   local undef $/;
   	$content = <INPUT>;
   	close INPUT;
	}
   return $content;

}


1;
__END__

