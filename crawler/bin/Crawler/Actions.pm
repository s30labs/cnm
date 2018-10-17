#####################################################################################################
# Fichero: (Crawler::Actions.pm)
# Fecha:
# Revision: Ver $VERSION
# Descripcion: Clase Crawler::Actions
# Set Tab=3
#####################################################################################################
use Crawler;
package Crawler::Actions;
@ISA=qw(Crawler);
$VERSION='1.00';
use strict;
use Carp 'croak','cluck';
use Cwd;
use Digest::MD5 qw( md5_hex );
#use Date::Calc qw( Days_in_Month );
use ONMConfig;
use Time::HiRes qw(gettimeofday tv_interval);

use Schedule::Cron;
use LWP::Simple;
use ProvisionLite;
use ProvisionLite::AuditLoop;
use Crawler::Transport;
use Audit;
use Stdout;
use XML::LibXML;
use JSON;
use Data::Dumper;
use IO::CaptureOutput qw/capture/;
use Encode;
use File::Copy;
use File::Basename;
use CNMScripts::SSH;
use CNMScripts::WMI;
use CNMScripts::CIFS;
use Logfile::Rotate;
use Crawler::LogManager::Syslog;
use Crawler::SNMP;

#----------------------------------------------------------------------------
my %ACTION_CODE_INTERNAL = (

	# Internas Ocultas. No aparecen an la interfaz
   'setmetric' => \&int_setmetric,
   'clone' => \&int_clone,
   'delmetricdata' => \&int_delmetricdata,
);

#----------------------------------------------------------------------------
#mysql> select name,type,script from cfg_monitor_apps where custom=0 order by type;
#+-------------------------------------------------------+---------+----------------------------------------+
#| name                                                  | type    | script                                 |
#+-------------------------------------------------------+---------+----------------------------------------+
#| DAR DE BAJA DISPOSITIVO                               | cnm     | ws_set_device                          |
#| ACTIVAR DISPOSITIVO                                   | cnm     | ws_set_device                          |
#| PONER EN MANTENIMIENTO DISPOSITIVO                    | cnm     | ws_set_device                          |
#| INVENTARIO DE DISPOSITIVOS                            | cnm     | ws_get_csv_devices                     |
#| INVENTARIO DE METRICAS                                | cnm     | ws_get_csv_metrics                     |
#| INVENTARIO DE VISTAS                                  | cnm     | ws_get_csv_views                       |
#| AUDITORIA DE RED                                      | cnm     | audit                                  |
#| PING-10                                               | latency | cnm-ping                               |
#| PING-10 (largo)                                       | latency | cnm-ping                               |
#| TRACEROUTE                                            | latency | cnm-traceroute                         |
#| MONITOR TCP                                           | latency | mon_tcp                                |
#| MONITOR SMTP                                          | latency | mon_smtp                               |
#| ESCANEO DE PUERTOS                                    | latency | cnm-nmap                               |
#| ESCANEO DE SISTEMA OPERATIVO                          | latency | cnm-nmap                               |
#| LISTA DE INTERFACES                                   | snmp    | mib2_if                                |
#| USO DE DISCO(%)                                       | snmp    | mibhost_disk                           |
#| REGISTRO DE VECINOS POR CDP                           | snmp    | get_cdp                                |
#| DEVICE POOLS DEFINIDOS                                | snmp    | cisco_ccm_device_pools                 |
#| INFORMACION DEL CHASIS                                | snmp    | snmptable                              |
#| USO DE CPU                                            | snmp    | snmptable                              |
#| ESTADO DEL EQUIPO - VENTILADORES                      | snmp    | snmptable                              |
#| CONTENIDO DE LA MEMORIA FLASH                         | snmp    | snmptable                              |
#| TUNELES IPSEC                                         | snmp    | snmptable                              |
#| USO DE MEMORIA                                        | snmp    | snmptable                              |
#| ESTADO DEL EQUIPO - FUENTES DE ALIMENTACION           | snmp    | snmptable                              |
#| TABLA DE PROCESOS                                     | snmp    | snmptable                              |
#| ESTADO DEL EQUIPO - TEMPERATURA                       | snmp    | snmptable                              |
#| ESTADO DEL EQUIPO - VOLTAJE                           | snmp    | snmptable                              |
#| INFORMACION SOBRE EL CLUSTER                          | snmp    | snmptable                              |
#| DISPOSITIVOS CTI DEFINIDOS                            | snmp    | snmptable                              |
#| GATEKEEPERS DEFINIDOS                                 | snmp    | snmptable                              |
#| GATEWAYS DEFINIDOS                                    | snmp    | snmptable                              |
#| DISPOSITIVOS H323 DEFINIDOS                           | snmp    | snmptable                              |
#| MEDIA DEVICES DEFINIDOS                               | snmp    | snmptable                              |
#| TELEFONOS DEFINIDOS                                   | snmp    | snmptable                              |
#| ZONAS HORARIAS                                        | snmp    | snmptable                              |
#| DISPOSITIVOS DE BUZON DE VOZ DEFINIDOS                | snmp    | snmptable                              |
#| COMPAQ - CARACTERISTICAS DE LA FUENTE DE ALIMENTACION | snmp    | snmptable                              |
#| COMPAQ - TABLA DE PROCESOS                            | snmp    | snmptable                              |
#| COMPAQ - INFORMACION SOBRE LOS SLOTS PCI              | snmp    | snmptable                              |
#| TABLA DE USO DE CPU                                   | snmp    | snmptable                              |
#| INFORMACION SOBRE LOS POOLS DEFINIDOS                 | snmp    | snmptable                              |
#| TABLA DE V/I EN ENTRADA                               | snmp    | snmptable                              |
#| TABLA DE V/I/CARGA EN SALIDA                          | snmp    | snmptable                              |
#| MAQUINAS VIRTUALES CONFIGURADAS EN EL SISTEMA         | snmp    | snmptable                              |
#| INFORMACION DEL PRODUCTO                              | snmp    | snmptable                              |
#| TABLA DE VULNERABILIDADES - TOP TEN                   | snmp    | snmptable                              |
#| INFO SOBRE LOS INTERFACES DE LOS APS CONECTADOS       | snmp    | snmptable                              |
#| INFO SOBRE LOS APS CONECTADOS                         | snmp    | snmptable                              |
#| CARGA DE LOS APS CONECTADOS                           | snmp    | snmptable                              |
#| ESTADO DE LOS PERFILES DE LOS APS CONECTADOS          | snmp    | snmptable                              |
#| TABLA DE ARP                                          | snmp    | snmptable                              |
#| TABLA DE RUTAS                                        | snmp    | snmptable                              |
#| SESIONES TCP                                          | snmp    | snmptable                              |
#| PUERTOS UDP                                           | snmp    | snmptable                              |
#| OSPF - TABLA DE AREAS                                 | snmp    | snmptable                              |
#| OSPF - TABLA DE INTERFACES                            | snmp    | snmptable                              |
#| OSPF - TABLA DE VECINOS                               | snmp    | snmptable                              |
#| TABLA DE PEERS BGP                                    | snmp    | snmptable                              |
#| USO DE DISCO                                          | snmp    | snmptable                              |
#| PROCESOS EN CURSO                                     | snmp    | snmptable                              |
#| SOFTWARE INSTALADO                                    | snmp    | snmptable                              |
#| TABLA DE FREC/V/I EN ENTRADA                          | snmp    | snmptable                              |
#| TABLA DE V/I/POT/CARGA EN SALIDA                      | snmp    | snmptable                              |
#| INFORMACION DEL EQUIPO                                | snmp    | snmptable                              |
#| INFORMACION DEL EQUIPO                                | snmp    | snmptable                              |
#| CADUCIDAD DE LICENCIAS IRONPORT                       | snmp    | snmptable                              |
#| IRONPORT - ACTUALIZACION DE SOTWARE                   | snmp    | snmptable                              |
#| IRONPORT - RENDIMIENTO                                | snmp    | snmptable                              |
#| VALORES DEL SENSOR                                    | snmp    | snmptable                              |
#| TIPOS DE CANALES                                      | snmp    | snmptable                              |
#| INFORMACION DEL EQUIPO                                | snmp    | snmptable                              |
#| LISTA PROCESOS EN CURSO                               | xagent  | win32_app_wmi_process_list_running.vbs |
#| LISTA DE FICHEROS ABIERTOS POR PID                    | xagent  | linux_app_os_open_files_per_process.sh |
#+-------------------------------------------------------+---------+----------------------------------------+
#
#
#----------------------------------------------------------------------------
%Crawler::Actions::TASK2DEVICE=();
%Crawler::Actions::TASK2IP=();



#----------------------------------------------------------------------------
my $ETXT='KEY-ERROR';
my $FILE_CONF='/cfg/onm.conf';
$Crawler::Actions::ROTATE_FILE='/var/run/rotate_logs.flag';
my $RELOAD_FILE='/var/www/html/onm/reload/actionsd.reload';
#my $FILE_PATH_TASKS='/var/www/html/onm/files/tasks';
#my $FILE_PATH_TASKS_URL='files/tasks';
my $CRON;
my $DOMAIN_LIST;

#----------------------------------------------------------------------------
use constant STAT_READY => 0;
use constant STAT_RUN => 1;
use constant STAT_END => 3;

use constant TYPE_DIRECT => 0;
use constant TYPE_PLANNING => 1;

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Actions
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

	my $self=$class->SUPER::new(%arg);

   # Atributos globales -------------------------
   $self->{_provision} = $arg{provision};
   $self->{_transport} = $arg{transport};
   $self->{_xagent} = $arg{xagent};
   $self->{_snmp} = $arg{snmp};
   $self->{_lapse} = $arg{lapse} || 60;		# Intervalo de testeo para el envio de avisos
   $self->{_role} = $arg{role} || 'daemon';	# rol: online (actions) diferido (actionsd)
   $self->{_url_info} = $arg{url_info} || '';
   $self->{_action_descr} = $arg{action_descr} || '';

   $self->{_version1} = $arg{version1} || '3.23.54';
   $self->{_version2} = $arg{version2} || '1.0.40';

   return $self;
}


#----------------------------------------------------------------------------
# provision
#----------------------------------------------------------------------------
sub provision {
my ($self,$provision) = @_;
   if (defined $provision) {
      $self->{_provision}=$provision;
   }
   else { return $self->{_provision}; }
}

#----------------------------------------------------------------------------
# transport
#----------------------------------------------------------------------------
sub transport {
my ($self,$transport) = @_;
   if (defined $transport) {
      $self->{_transport}=$transport;
   }
   else { return $self->{_transport}; }
}

#----------------------------------------------------------------------------
# xagent
#----------------------------------------------------------------------------
sub xagent {
my ($self,$xagent) = @_;
   if (defined $xagent) {
      $self->{_xagent}=$xagent;
   }
   else { return $self->{_xagent}; }
}

#----------------------------------------------------------------------------
# snmp
#----------------------------------------------------------------------------
sub snmp {
my ($self,$snmp) = @_;
   if (defined $snmp) {
      $self->{_snmp}=$snmp;
   }
   else { return $self->{_snmp}; }
}

#----------------------------------------------------------------------------
# lapse
#----------------------------------------------------------------------------
sub lapse {
my ($self,$lapse) = @_;
   if (defined $lapse) {
      $self->{_lapse}=$lapse;
   }
   else { return $self->{_lapse}; }
}


#----------------------------------------------------------------------------
# role
#----------------------------------------------------------------------------
sub role {
my ($self,$role) = @_;
   if (defined $role) {
      $self->{_role}=$role;
   }
   else { return $self->{_role}; }
}

#----------------------------------------------------------------------------
# url_info
#----------------------------------------------------------------------------
sub url_info {
my ($self,$url_info) = @_;
   if (defined $url_info) {
      $self->{_url_info}=$url_info;
   }
   else { return $self->{_url_info}; }
}

#----------------------------------------------------------------------------
# action_descr
#----------------------------------------------------------------------------
sub action_descr {
my ($self,$action_descr) = @_;
   if (defined $action_descr) {
      $self->{_action_descr}=$action_descr;
   }
   else { return $self->{_action_descr}; }
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
# check_cfgsign
#----------------------------------------------------------------------------
sub check_cfgsign {
my ($self,$file_cfg,$file_reload) = @_;

	my $rcfgbase;
   my $cfg_sign=$self->cfgsign();
   undef $/;
   open (F,$file_cfg);
   my $whole_file = <F>;
   close F;
	$/="\n";

   my $cfg_sign_new=md5_hex($whole_file);

   #Recargo file_cfg por no coincidir las firmas (==> Cambio en $file_cfg)
   if ($cfg_sign_new ne $cfg_sign)  {

      $self->log('info',"check_cfgsign_notif:: RELOAD de $file_cfg (OLD=$cfg_sign NEW=$cfg_sign_new)");
      $rcfgbase=conf_base($file_cfg);
      $self->cfg($rcfgbase);
      $self->cfgsign($cfg_sign_new);
   }


   #Recargo file_cfg por detectar que existe fichero de recarga
   elsif (-e $file_reload)  {

      $self->log('info',"check_cfgsign_notif:: RELOAD de $file_cfg (-e $file_reload)");
      $rcfgbase=conf_base($file_cfg);
      $self->cfg($rcfgbase);
      unlink $file_reload;
   }

	else { return; }


	#my $rcfgbase=$self->cfg();
	my $LAPSE=$rcfgbase->{notif_lapse}->[0]; #$self->lapse($LAPSE);
	my $MX=$rcfgbase->{notif_mx}->[0]; #$self->mx($MX);
	my $FROM=$rcfgbase->{notif_from}->[0];  #$self->from($FROM);
	my $FROM_NAME=$rcfgbase->{notif_from_name}->[0];  #$self->from_name($FROM_NAME);
	my $SUBJECT=$rcfgbase->{notif_subject}->[0];  #$self->subject($SUBJECT);
	my $SERIAL_PORT=$rcfgbase->{notif_serial_port}->[0];  #$self->serial_port($SERIAL_PORT);
	my $PIN=$rcfgbase->{notif_pin}->[0];  #$self->pin($PIN);

   my $transport=Crawler::Transport->new('cfg'=>$rcfgbase);
   $transport->init();
   $self->transport($transport);


	#while (my ($k,$v)=each %$rcfgbase) { 		$self->log('info',"check_cfgsign_notif*:: $k --> @$v"); 	}

	$self->log('debug',"check_cfgsign_notif++:: LAPSE=$LAPSE|MX=$MX|FROM=$FROM|FROM_NAME=$FROM_NAME|SUBJECT=$SUBJECT|SERIAL_PORT=$SERIAL_PORT|PIN=$PIN");

}

#----------------------------------------------------------------------------
# run
#----------------------------------------------------------------------------
sub run {
my  $self = shift;
my  ($user,$group);

  #----------------------------------------------------
  croak "Can't fork" unless defined (my $child = fork);
  exit 0 if $child;    # parent dies;
  POSIX::setsid();     # become session leader
  open(STDIN,"</dev/null");
  open(STDOUT,">/dev/null");
  open(STDERR,">&STDOUT");
  my $CWD = getcwd;       # remember working directory
  chdir '/';           # change working directory
  umask(0);            # forget file mode creation mask
  $ENV{PATH} = '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin';
  delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};
  $SIG{CHLD} = \&reap_child;
  $SIG{USR1} = \&show_status;
  #----------------------------------------------------

  	#$self->log('notice',"Arrancando $0 (padre) ....");
  	&Crawler::change_privileges($self->user,$self->group);

  	#$self->start_flag(1);

	my $range=$self->range();
	my $lapse=$self->lapse();
	my $pid=$self->procreate('actionsd',$range,$lapse);
   if ($pid == 0) { $self->do_task($lapse,undef);   }
}

#----------------------------------------------------------------------------
# sanity_check
#----------------------------------------------------------------------------
sub sanity_check  {
my ($self,$ts,$range,$sanity_lapse)=@_;

   local $SIG{CHLD}='';

   my $ts0=$self->log_tmark();
   if ($ts-$ts0>$sanity_lapse) {
      $self->init_tmark();
      $self->log('info',"do_task::[INFO] SANITY");
      exit(0);
   }
}


#----------------------------------------------------------------------------
# do_task
#----------------------------------------------------------------------------
sub do_task  {
my ($self,$lapse,$range)=@_;

	local $SIG{CHLD}='IGNORE';

	$lapse=30;
	my $cfg=$self->cfg();

   my $store=$self->create_store();
	$self->store($store);
	my $spath=$self->store_path();
	my $hidx=$self->hidx();
   $self->log('info',"do_task:: hidx=$hidx lapse=$lapse");

   my $cid=$self->cid();
   $store->cid($cid);
   my $cid_ip=$self->cid_ip();
   $store->cid_ip($cid_ip);

	my $dbh=$store->open_db();
	$self->dbh($dbh);
	$store->dbh($dbh);
	my $log_level=$self->log_level();

	my $provision=ProvisionLite->new(log_level=>$log_level, 'cfg'=>$cfg);
	$provision->init();
	$self->provision($provision);

	my $transport=Crawler::Transport->new('cfg'=>$cfg);
	$transport->init();
	$self->transport($transport);

	my $xagent=Crawler::Xagent->new('cfg'=>$cfg);
   my $p = $store->get_proxy_list($dbh);
   $xagent->proxies($p);
	$xagent->timeout(3600);
	$self->xagent($xagent);

	my $snmp=Crawler::SNMP->new( store=>$store, 'cfg'=>$cfg );
   $snmp->reset_mapping();
	$self->snmp($snmp);

	$CRON = new Schedule::Cron(sub {});

   $DOMAIN_LIST=$store->get_mcnm_domain_cids($dbh,{'cid'=>$cid});

	$self->init_tmark();
	my $sanity_lapse = $Crawler::SANITY_LAPSE + int(rand(3600));

   while (1) {

      my $TNOW=time;
      #$self->sanity_check($TNOW);
		$self->sanity_check($TNOW,$range,$sanity_lapse);
     	$self->time_ref($TNOW);

      my $child=fork;
      if ($child==0) {

         my $child_dbh=$store->fork_db($dbh);
         $self->dbh($child_dbh);
         $store->dbh($child_dbh);

         $self->log_pull($child_dbh);
         $store->close_db($child_dbh);
         exit;
      }
		
		eval {

      	my $time_ref=$self->time_ref();
			# ----------------------------------------------------------------------
      	my $tnext = $TNOW + $lapse;
			$self->check_cfgsign($FILE_CONF,$RELOAD_FILE);

			# ----------------------------------------------------------------------
   	   my $store=$self->store();
      	my ($dbh,$ok)=$self->chk_conex($dbh,$store,'qactions');
      	if ($ok) {

				# Inicializa los vectores:
				# %Crawler::Actions::TASK2DEVICE y %Crawler::Actions::TASK2IP
				$self->register_devices($dbh);

				$self->task2action($dbh,undef);

				$self->actions_manager($dbh);

			}

      	# ----------------------------------------------------------------------
      	# Gestion de tiempo
      	$self->idle_time();

      };

      if ($@) {
         my $kk=ref($dbh);
         $self->log('warning',"do_task::[WARN] ERROR (dbh=>$kk) $@");
         $self->idle_time();
      }

	}
}

#----------------------------------------------------------------------------
sub idle_time {
my ($self)=@_;


   #----------------------------------------------------
   if ($Crawler::TERMINATE == 1) {
      $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
      exit 0;
   }

   #----------------------------------------------------
   #my $wait = $tnext - time;
   my $time_ref=$self->time_ref();
   my $wait = ($time_ref->{'time'} + $self->lapse()) - time;
   if ($wait < 0) {  $self->log('warning',"do_task::[WARN] *S* [$0:$$|WAIT=$wait]");   }
   else {
      $self->log('info',"do_task::[INFO] -W- actionsd|WAIT=$wait");
      sleep $wait;
   }
   #----------------------------------------------------
   if ($Crawler::TERMINATE == 1) {
      $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
      exit 0;
   }
}


#----------------------------------------------------------------------------
# log_pull
#----------------------------------------------------------------------------
# Obtiene datos de ficheros de log remotos
#----------------------------------------------------------------------------
sub log_pull  {
my ($self,$dbh)=@_;

	my $error=0;
   my $store=$self->store();
	my $tnow=time();
	my $PULL_TIME=140;
	my $do_rotate = (-f $Crawler::Actions::ROTATE_FILE) ? 1 : 0;

	# Se instancia el objeto LogManager::Syslog para el caso de inssertar el evento
	# Es mas eficiente hacerlo asi.
   my $rcfg = $self->cfg();
   my $log_level = $self->log_level();
   my $log_manager=Crawler::LogManager::Syslog->new(cfg=>$rcfg,'log_level'=>$log_level );
   #$log_manager->create_store();
   $log_manager->store($store);
   $log_manager->dbh($dbh);
   $log_manager->check_configuration();


   my $rres=$store->get_device2log($dbh);

my $aux=Dumper($rres);
$aux=~s/\n/\. /g;
$self->log('info',"do_task::[INFO] log_pull >>> rres=$aux");
	
	foreach my $l (@$rres) {

		#d.id_dev,d.ip,l.logfile,l.todb,l.script,l.date_store,c.name,c.type,c.user,c.pwd,c.port
		my ($id_dev,$ip,$name,$domain,$critic,$logfile,$todb,$script,$last_access,$last_line,$parser,$cred_name,$cred_type,$cred_user,$cred_pwd,$cred_port,$tabname) = 
				($l->[0], $l->[1], $l->[2], $l->[3], $l->[4], $l->[5], $l->[6], $l->[7], $l->[8], $l->[9], $l->[10], $l->[11], $l->[12],$l->[13],$l->[14],$l->[15],$l->[16]);

		my @vcredentials=();
		if (defined $cred_user) { push @vcredentials, "-user=$cred_user"; }
		if (defined $cred_pwd) { push @vcredentials, "-pwd=$cred_pwd"; }
		if (defined $cred_port) { push @vcredentials, "-port=$cred_port"; }
		my $credentials = join (' ', @vcredentials);

      $self->log('info',"do_task::[INFO] log_pull >>> START_TASK $cred_type-$ip-$logfile (id_dev=$id_dev name=$name todb=$todb script=$script last_access=$last_access last_line=$last_line parser=$parser cred_name=$cred_name credentials=$credentials)");

		#fml por ahora comentado
		#if ($tnow-$last_access <= $PULL_TIME) { next; }

      # Por ahora los scripts son fijos. No se usa un campo de la BBDD
		# Uso: /opt/crawler/bin/libexec/linux_log_parser.pl [-t parser_type] [-f file] [-p pattern] [-l lapse]
		my ($rc,$stdout, $stderr)=(0,'','');
		my @lines=();
		my @new_lines=();
		my $last_new_line=0;
		$error=0;

		#-------------------------------------------------------------------------------------
		# SSH
		#-------------------------------------------------------------------------------------
		if ($cred_type eq 'ssh') { 
	      my $script1 = '/opt/crawler/bin/libexec/linux_log_parser.pl';
   	   my $params = "-f $logfile -t $parser";

      	$self->log('debug',"do_task::[INFO] log_pull >>> ssh:$ip $script1 $params");
      	my $remote = CNMScripts::SSH->new( 'host'=>$ip, 'credentials'=>$credentials );
      	($stdout, $stderr) = $remote->execute($script1,$params);
		   if ($stderr ne '') {
				$stderr =~ s/\n/ /g;
				my $errstr = "ERROR AL OBTENER LOG POR SSH de $ip [$script1 $params] ($stderr)";
      		$self->log('warning',"do_task::[INFO] log_pull >>> END_TASK *ERROR* $cred_type-$ip-$logfile $errstr");
				my $x = md5_hex("$cred_type-$ip-$logfile");
            my $trap_key = substr $x,0,10;

				my $SNMP=$self->snmp();
				my $manager_ip=my_ip();
			   my $r=$SNMP->core_snmp_trap_ext(

         			{'comunity'=>'public', 'version'=>2, 'host_ip'=>$manager_ip, 'agent'=>$ip },
			         {'enterprise'=>'CNM-NOTIFICATIONS-MIB::cnmNotifLogFileGetErrorSet', 'uptime'=>1234,
         			   'vardata'=> [  [ 'cnmNotifCode', 1, 1 ],
                  			         [ 'cnmNotifMsg', 1, $errstr ],
                                    [ 'cnmNotifKey', 1, $trap_key ]  ]
			         }
			   );
				#next;
				$error=1;
				$stdout='';
         }
			
	     	@lines=split(/\n/,$stdout);

		}
      #-------------------------------------------------------------------------------------
		# $logfile debe ser share/fichero
		#-------------------------------------------------------------------------------------
      if ($cred_type eq 'cifs') {

#/bin/mount -t cifs -o username=usersmb1,password=passsmb1 //10.2.254.211/usersmb1 /opt/mnt/chx/0070
         my ($filename, $share, $suffix) = fileparse($logfile);
			$share=~s/\/*(\S+)\/*/$1/;
         my $remote = CNMScripts::CIFS->new( 'host'=>$ip, 'credentials'=>$credentials, 'share'=>$share );
         $self->log('info',"do_task::[INFO] log_pull >>> **DEBUG** cifs: ip=$ip credentials=$credentials logfile=$logfile share=$share remote=$remote");
         my $mount_point = $remote->connect();

         $self->log('info',"do_task::[INFO] log_pull >>> **DEBUG** cifs: ip=$ip mount_point=$mount_point");

         my $script1 = '/opt/crawler/bin/libexec/linux_log_parser.pl';
			my $mounted_file = $mount_point.'/'.$filename;
     	   my $params = "-f $mounted_file -t $parser";

			if ($remote->err_num()!=0) {$stderr = $remote->err_str(); }
			elsif (defined $mount_point) {

         	$self->log('info',"do_task::[INFO] log_pull >>> cifs: $script1 $params");
				my $cmd = `$script1 $params`;
   			capture sub { $rc=system($cmd); } => \$stdout, \$stderr;

				$remote->disconnect($mount_point); 
			}

         if ($stderr ne '') {
            $stderr =~ s/\n/ /g;
            my $errstr = "ERROR AL OBTENER LOG POR CIFS de $ip [$script1 $params] ($stderr)";
            $self->log('warning',"do_task::[INFO] log_pull >>> END_TASK *ERROR* $cred_type-$ip-$logfile $errstr");
				my $x = md5_hex("$cred_type-$ip-$logfile");
            my $trap_key = substr $x,0,10;

            my $SNMP=$self->snmp();
				my $manager_ip=my_ip();
            my $r=$SNMP->core_snmp_trap_ext(

                  {'comunity'=>'public', 'version'=>2, 'host_ip'=>$manager_ip, 'agent'=>$manager_ip },
                  {'enterprise'=>'CNM-NOTIFICATIONS-MIB::cnmNotifLogFileGetErrorSet', 'uptime'=>1234,
                     'vardata'=> [  [ 'cnmNotifCode', 1, 1 ],
                                    [ 'cnmNotifMsg', 1, $errstr ],
                                    [ 'cnmNotifKey', 1, $trap_key ]  ]
                  }
            );
				#next;
				$error=1;
				$stdout='';
         }

         @lines=split(/\n/,$stdout);

      }
		
		#-------------------------------------------------------------------------------------
		# WMI
		#-------------------------------------------------------------------------------------
		elsif ($cred_type eq 'wmi') {

			my ($condition,$evlines)=('',[]);
			my $wmi = CNMScripts::WMI->new('host'=>$ip, 'user'=>$cred_user, 'pwd'=>$cred_pwd);

			my $ok = $wmi->check_remote($ip);
			if ($ok) {
				# En el caso WMI logfile es System, Security ...
				$condition = " Logfile = '$logfile' "; ;
			   my $last_time = $wmi->time2date($last_line);
   			$condition .= "AND TimeGenerated>'$last_time'";
				$self->log('info',"do_task::[INFO] log_pull wmi wmi=$wmi condition=$condition");

				$evlines = $wmi->get_wmi_lines("\"SELECT * from Win32_NTLogEvent Where $condition\"");

				my $nl = scalar(@$evlines);
				$self->log('info',"do_task::[INFO]++++ log_pull LINES=$nl wmi wmi=$wmi condition=$condition");
			}

			if ($wmi->err_num() != 0) {

				$stderr=$wmi->err_str();
            $self->log('warning',"do_task::[INFO] log_pull >>> END_TASK *ERROR* $cred_type-$ip-$logfile $stderr");
				my $x = md5_hex("$cred_type-$ip-$logfile");
				my $trap_key = substr $x,0,10;

            my $SNMP=$self->snmp();
            my $manager_ip=my_ip();
            my $r=$SNMP->core_snmp_trap_ext(

                  {'comunity'=>'public', 'version'=>2, 'host_ip'=>$manager_ip, 'agent'=>$manager_ip },
                  {'enterprise'=>'CNM-NOTIFICATIONS-MIB::cnmNotifLogFileGetErrorSet', 'uptime'=>1234,
                     'vardata'=> [  [ 'cnmNotifCode', 1, 1 ],
                                    [ 'cnmNotifMsg', 1, $stderr ],
                                    [ 'cnmNotifKey', 1, $trap_key ]  ]
                  }
            );
            #next;
				$error=1;
				$evlines=[];

			}
#			$self->log('info',"do_task::[INFO] log_pull ++++ WMI condition=$condition (@$evlines)");

			#my @linesx=();
			@lines=();
			if (ref($evlines) eq "ARRAY") {
   			foreach my $l (@$evlines) {

					if ($l->{'Message'} eq '(null)') {$l->{'Message'} = 'Sin datos del evento'; }

					my $txt = $wmi->date2time($l->{'TimeGenerated'}).':0 >> '.$wmi->date_format($l->{'TimeGenerated'}).' '.$l->{'ComputerName'}.' ['.$logfile.'] '.$wmi->event_type($l->{'EventType'}).' '.$l->{'SourceName'}.' EventID='.$l->{'EventIdentifier'}.' '.$l->{'Message'};

					my $new_txt = $wmi->win_translator($txt);
					push @lines, $new_txt;
					$self->log('debug',"do_task::[INFO] log_pull ++++ WMI txt=$txt");
   			}
			}
			#@lines = reverse @linesx;
		}
		
		#-------------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------------
#		my $logfilename = $logfile;
#		$logfilename =~ s/\//_/g;
#	
#		# Si es necesario se rotan los logs
#		my $file_log='/store/remote_logs/log-'.$ip.'-'.$logfilename;
#		if ( ($do_rotate) && (-f $file_log) ){
#      	$self->log('info',"do_task::[INFO] log_pull >>> **rotate** file_log=$file_log");
#			my $log = new Logfile::Rotate( File => $file_log, Count => 2, Persist => 'yes' );
#   		$log->rotate();
#		}


		#-------------------------------------------------------------------------------------
		# Se obtienen las nuevas lineas del fichero y se almacenan en la tabla correspondiente.
      foreach my $l ( reverse @lines) {
         chomp $l;
$self->log('debug',"do_task::[INFO] log_pull >>> .... line=$l");
#0:0 >> 01/10/2013 16:12:11 37L4247D25-09 [Application] Unknown El servicio Instrumental de administraci__n de Windows (WMI) se inici__ correctamente
			# Las lineas obtenidas siguen el criterio:
			# timestamp:index >> linea_original
         if ($l =~ /^(\d+)\:(\d+)\s*>>\s*(.*)$/) {
            $last_new_line=$1;
$self->log('debug',"do_task::[INFO] log_pull >>> .... last_new_line=$last_new_line last_line=$last_line");
            my $nl=$3;
            if ($last_line < $last_new_line) {
               push @new_lines, $nl;
					$store->set_log_pull_lines($dbh,$ip,$logfile,$tabname,[{'ts'=>$last_new_line, 'line'=>$nl}]);
$self->log('debug',"do_task::[INFO] log_pull STORE LINE >>> $nl");
            }
         }
      }

		#-------------------------------------------------------------------------------------
      # BBDD -> file
      if ($do_rotate) {
			# Almacena los datos de BBDD de ayer a fichero y limpia de BBDD
			$store->rotate_log_pull_lines($dbh,$ip,$logfile);
		}		

      my $n1=scalar @lines;
      my $n2=scalar @new_lines;
     	$self->log('info',"do_task::[INFO] log_pull END_TASK OK $cred_type-$ip-$logfile RESULT=$n1|$n2 ($parser)");

#		# Se almacena en el fichero local de CNM		
#		if ($n2>0) {
#			open (F,">>$file_log");	
#			foreach my $l (@new_lines) { print F "$l\n"; }
#			close F;
#		}

		# Si hay nuevos datos, los almaceno en su tabla correspondiente 
		#if (($todb) && ($n2>0)) {
		if ($n2>0) {

         my $t=time;
         my %msg =('date'=>$t, 'code'=>1, 'proccess'=>'syslog', 'ip'=>$ip, 'name'=>$name, 'domain'=>$domain, 'id_dev'=>$id_dev, 'critic'=>$critic);
			$log_manager->line_processor_vector(\@new_lines,\%msg);
		}

		my %update_data = ('id_dev'=>$id_dev, 'logfile'=>$logfile, 'rc'=>0, 'rcstr'=>'OK');
		if ($tabname ne '') { $update_data{'tabname'} = $tabname }
		if (!$error) { $update_data{'last_access'} = $tnow; }
		else {
			# Hay error en captura de log ....
			my $datef = $self->time2date($tnow);
			$update_data{'rc'} = 1;
			$update_data{'rcstr'} = '**ERROR** ('.$datef.') >> '.$stderr;
		}
		if ($last_new_line != 0) { $update_data{'last_line'} = $last_new_line; }

$aux=Dumper(\%update_data);
$aux=~s/\n/\. /g;
$self->log('info',"do_task::[INFO] ***FML*** log_pull >>> update_data=$aux");

		$store->set_device2log($dbh,\%update_data);

	}

	if (-f $Crawler::Actions::ROTATE_FILE) { unlink $Crawler::Actions::ROTATE_FILE; }

}



#----------------------------------------------------------------------------
# register_devices
#----------------------------------------------------------------------------
# Inicializa los vectores:
# %Crawler::Actions::TASK2DEVICE
# %Crawler::Actions::TASK2IP
#----------------------------------------------------------------------------
sub register_devices  {
my ($self,$dbh)=@_;

   my $store=$self->store();

   %Crawler::Actions::TASK2DEVICE=();
   %Crawler::Actions::TASK2IP=();
   my ($rres0,$c)=([],0);

   # Dispositivos
   $rres0=$store->get_from_db($dbh,'t.name,t.id_dev,t.ip','task2device t, devices d','t.id_dev=d.id_dev');
   foreach my $l (@$rres0) {
      my ($name,$id_dev,$ip) = ($l->[0], $l->[1], $l->[2]);
      $self->log('debug',"register_devices::[DEBUG] TASK=$name DEVICE $name -> $id_dev");

      if ($ip !~ /^\d+\.\d+\.\d+\.\d+$/) {
         $self->log('warning',"register_devices::[WARN] TASK=$name id_dev=$id_dev IP MAL FORMADA (ip=$ip)");
         next;
      }

      push @{$Crawler::Actions::TASK2DEVICE{$name}}, $id_dev;
      push @{$Crawler::Actions::TASK2IP{$name}}, $ip;
      $c+=1;
   }

   # Assets
   $rres0=$store->get_from_db($dbh,'t.name,t.id_dev,t.ip','task2device t, assets a','t.id_dev=a.id_asset');
   foreach my $l (@$rres0) {
      my ($name,$id_dev,$ip) = ($l->[0], $l->[1], $l->[2]);
      $self->log('debug',"register_devices::[DEBUG] TASK=$name ASSET $name -> $id_dev");

      if ($ip !~ /^\w+$/) {
         $self->log('warning',"register_devices::[WARN] TASK=$name id_dev=$id_dev ASSET SUTYPE INVALIDO (valor=$ip)");
         next;
      }

      push @{$Crawler::Actions::TASK2DEVICE{$name}}, $id_dev;
      push @{$Crawler::Actions::TASK2IP{$name}}, $ip;
      $c+=1;
   }

   return $c;




}

#----------------------------------------------------------------------------
# SCRIPT (o interna) => APLICACION => TAREA => ACCION
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# task2action
# Revisa las tareas configuradas (cfg_task_configured) y chequea la periodicidad.
# Si hay que realizar la tarea, actualiza la tabla e inserta una accion en qactions.
# Las tareas pueden ser:
# unicas (U): 00 01 2 04 * 2008
# diaria, semanal, mensual, anual (no incluyen el sexto campo en el cron)
# El campo done de la tabla solo tiene sentido para las tareas unicas.
# Para forzar la ejecucion de una tarea esta el campo exec, que siempre se pone
# a 0 despues de encolar en qactions.
#----------------------------------------------------------------------------
# SELECT c.id_cfg_task_configured,c.name,c.descr,c.frec,c.date,c.cron,c.task,c.done,c.type,c.subtype,c.params,s.cmd,s.ipparam,c.subtype FROM cfg_task_configured c, cfg_monitor_apps s WHERE c.task=s.aname and date<=xxxx;
# SELECT c.id_cfg_task_configured,c.name,c.descr,c.frec,c.date,c.cron,c.task,c.done,c.type,c.subtype,c.params,s.cmd,s.ipparam,c.subtype,s.format,c.task,c.exec FROM cfg_task_configured c, cfg_monitor_apps s WHERE  c.task=s.aname and (date<=1285329024 or exec=1);
#----------------------------------------------------------------------------
sub task2action  {
my ($self,$dbh,$id_task)=@_;

   my $store=$self->store();
	my ($error, $errorstr, $lastcmd);

   # Si atype<10 => EXEC online por actions
   # Si atype>=10 => EXEC diferido por actionsd
	my $role_condition='atype<10';
	if ((defined $id_task) && ($id_task=~/\d+/) && ($id_task>0) ) { $role_condition .= " and c.id_cfg_task_configured=$id_task";}
	if ($self->role() eq 'daemon') { $role_condition='atype>=10'; }

	my $time_ref=$self->time_ref();
	my $TNOW=$time_ref->{'time'};

	my $x=get_role_info();
	my $cnm_role = 'active';
	if ((exists $x->{'ROLE'}) && (lc $x->{'ROLE'} eq 'passive')) { $cnm_role = 'passive'; }

	# ------------------------------------------------------------------------
	# Se obtienen las tareas para ejecutar. Puede ser por:
	# a. Tarea en la que ya se ha cumplido el tiempo de ejecucion date<=$TNOW
	# b. Tarea de ejecucion inmediata (exec=1)
   my $what='c.id_cfg_task_configured,c.name,c.descr,c.frec,c.date,c.cron,c.task,c.done,c.atype,c.subtype,c.params,s.cmd,s.ipparam,c.subtype,s.format,c.exec,s.iptab,s.script,s.id_proxy,c.role,c.user';
   my $table='cfg_task_configured c, cfg_monitor_apps s';
   my $where=" c.task=s.aname and $role_condition and (date<=$TNOW or exec=1)";

   my $rres=$store->get_from_db($dbh,$what,$table,$where);


$self->log('info',"task2action::[**FML**] SELECT $what FROM $table WHERE $where");


   $error=$store->error();
   if ($error) {
      $errorstr = $store->errorstr();
		$lastcmd = $store->lastcmd();
      $self->log('warning',"task2action::[ERROR BD] ($error) $errorstr ($lastcmd)");
   }
	else {
		$lastcmd = $store->lastcmd();
		$self->log('debug',"task2action::[DEBUG] Busco tareas con date<=$TNOW (SQL=$lastcmd)");
	}
	

	# ------------------------------------------------------------------------
	# Si no hay tareas para ejecutar termina
	if (scalar(@$rres) == 0) { return; }

	# ------------------------------------------------------------------------
   foreach my $l (@$rres) {
		my %conf=();
		my %action=();
		$action{'status'}=STAT_READY;

      $conf{'id_cfg_task_configured'}=$l->[0];
      $conf{'name'}=$l->[1];
      $conf{'descr'}=$l->[2];
      $conf{'frec'}=$l->[3];
      my $date=$l->[4];
      my $crontime=$l->[5];
      $conf{'task'}=$l->[6];
		$conf{'done'}=$l->[7];
		$conf{'atype'}=$l->[8];
		$conf{'subtype'}=$l->[9];
		$conf{'params'}=$l->[10];
		my $cmd=$l->[11];
		my $ipparam=$l->[12];
		$conf{'subtype'}=$l->[13];
		my $format=$l->[14];
		$conf{'exec'}=$l->[15];
		my $iptab = $l->[16];
		my $script = $l->[17];
		my $id_proxy=$l->[18];
		my $cnm_role_in_db=$l->[19];
		my $cnm_user=($l->[20]) ? $l->[20] : 'cnmcore';

		$self->log('info',"task2action::[DEBUG] TAREA CONFIGURADA ID=$conf{'id_cfg_task_configured'} N=$conf{'name'} PARAMS=$conf{params} atype=$conf{'atype'} subtype=$conf{'subtype'} task=$conf{'task'} iptab=$iptab role_in_db=$cnm_role_in_db cnm_role=$cnm_role cnm_user=$cnm_user");

		#Si la tarea es unica y ya se ha pasado a qactions (done=1) la salto si exec vale 0
		if ( ($conf{'frec'} eq 'U') && ($conf{'done'}==1) && ($conf{'exec'}==0) ) {
			$self->log('debug',"task2action::[DEBUG] Salto tarea (U+DONE SIN EXEC) $conf{'name'} ($conf{'descr'})");
			next;
		}

		#Si la tarea no corresponde al rol (activo/pasivo) que tiene configurado el sistema la salto.
		if ( $cnm_role ne $cnm_role_in_db ) {
			$self->log('debug',"task2action::[DEBUG] Salto tarea (CNM ROLE=$cnm_role)  $conf{'name'} ($conf{'descr'})");
			next;
		}

		if ($iptab) {

			if (! exists $Crawler::Actions::TASK2DEVICE{$conf{'subtype'}})  {
				$self->log('warning',"task2action::[DEBUG] TAREA $conf{'subtype'} SIN DISPOSITIVOS ASOCIADOS  ($conf{'descr'})");
				# Esta tarea se manda a qactions como terminada.
            $action{'status'}=STAT_END;
				#next;
			}
			else {
				$self->log('info',"task2action::[**FML**] TAREA $conf{'subtype'} CON DISPOSITIVOS ASOCIADOS (@{$Crawler::Actions::TASK2IP{$conf{'subtype'}}}) ($conf{'descr'})");
			}
		}


		my $n=md5_hex("$conf{'name'}.$conf{'task'}.$TNOW.$conf{'params'}");
		$action{'name'}=substr $n,0,8;

		$action{'descr'}=$conf{'descr'};
		$action{'atype'}=$conf{'atype'};
		$action{'format'}=$format;

#		# En cmd guardo el nombre de la tarea configurada. Necesario para crear
#		# el directorio con los ficheros de resultados.
#		$action{'cmd'}=$conf{'name'};
#
		$action{'cmd'}=$cmd;
		$action{'params'}=$self->_params2action($conf{'params'}, $ipparam);

      #$action{'action'}=$conf{'task'};
      #$action{'action'} = (! $cmd) ? $conf{'task'} : $conf{'subtype'};
      $action{'action'} = $conf{'subtype'};
      $action{'task'} = $conf{'task'};

		$action{'auser'}=$cnm_user;
		$action{'date_store'}=$TNOW;
		#$action{'status'}=STAT_READY;
		$action{'cmd'}=$script;
		$action{'id_proxy'}=$id_proxy;

      my $f=$self->_get_results_filepath( \%action);
		$action{'file'}=$f;

$self->log('warning',"task2action::*****FML***** DESCR=$conf{'descr'} file=$f");

		# Si hay un restore en curso no almaceno en qactions
		my $nr = $self->check_running_restore();
		if (($script eq 'linux_app_restore_passive_from_active.pl') && ($nr>0)) {
			$self->log('info',"task2action:: RESTORE EN CURSO");
		}
		# Se almacena la accion en qactions (situacion normal)
		else {
			$store->insert_to_db($dbh,'qactions',\%action);
		}

		$error=$store->error();
      if ($error) {
			$errorstr = $store->errorstr();
			$lastcmd = $store->lastcmd();
         $self->log('warning',"task2action::[ERROR BD] ($error) $errorstr (SQL=$lastcmd)");
      }
      else {
         $lastcmd = $store->lastcmd();
			$lastcmd =~  s/\n/ /g;
			$self->log('info',"task2action::[DEBUG] T->action NAME=$action{'name'} ACTION=$action{'action'} CMD=$action{'cmd'}  PARAMS=$action{'params'} (SQL=$lastcmd)");
      }

		# Es tarea de TEST ==> SE BORRA
		#if ($conf{'frec'} eq 'T') {

		# 0 actions		app-ip	online
		# 10 actionsd  app-ip   app diferida
		# 11 actionsd  app      app diferida
		# 12 actionsd  task     app diferida-planificada
		# 13 actionsd  task     app diferida-evento
		if ( ($conf{'atype'} == 0) || ($conf{'atype'} == 10) || ($conf{'atype'} == 11) ) {
			my $where_del='id_cfg_task_configured='.$conf{'id_cfg_task_configured'};

			$store->delete_from_db($dbh,'cfg_task_configured',$where_del);

			$lastcmd = $store->lastcmd();
			$lastcmd =~  s/\n/ /g;
$self->log('info',"task2action::[DEBUG] BORRO T $action{action} y params=$action{params} (SQL=$lastcmd)");
		}
		# No es tarea de TEST
		else {
			# Si no es una tarea unica, se obtiene la siguiente ejecucion
			if ($conf{'frec'} ne 'U') {
				if ($conf{'exec'}==1) { $conf{'date'}=$date; }
				else { $conf{'date'}=$self->get_next_date($crontime); }
$self->log('info',"task2action:: TAREA PERIODICA - Siguiente ejecucion: $conf{'date'} (exec=$conf{'exec'})");

			}
			# Tarea unica
			else {
				$conf{'date'}=$date;
				$conf{'done'}=1;
			}
	
			# Si get_next_date tiene un error devuelve -1
			if ($conf{'date'}==-1) {
				$self->log('warning',"task2action::[ERROR] en tarea $action{action} params=$action{params}");
				next;
			}

			$conf{'exec'}=0;

      	$store->update_db($dbh,'cfg_task_configured',\%conf,"id_cfg_task_configured=$conf{id_cfg_task_configured}");

	      $error=$store->error();
   	   if ($error) {
      	   $errorstr = $store->errorstr();
				$lastcmd = $store->lastcmd();
	         $self->log('warning',"task2action::[ERROR BD] ($error) $errorstr (SQL=$lastcmd)");
   	   }
			else {
	      	$lastcmd = $store->lastcmd();

				my $log_txt= "Termino tarea $conf{name} (FREC=$conf{frec}) ";
				if ( ($conf{'frec'} ne 'U') && ($conf{'frec'} ne 'T') )	{ $log_txt .= "$date -> $conf{date} "; }
				$log_txt .= "(SQL=$lastcmd)";
   	   	$self->log('debug',"task2action::[DEBUG] $log_txt");
			}
   	}
	}
	
}

#----------------------------------------------------------------------------
# check_running_restore
# Comprueba si hay un proceso de restore en curso.
# Devuelve el numero de procesos en curso
#----------------------------------------------------------------------------
sub check_running_restore  {
my ($self)=@_;

	my $n = `/bin/ps -aef | /bin/grep linux_app_restore_passive_from_active.pl | /bin/grep -v grep|/bin/grep -v vi|/bin/grep -v sudo|/usr/bin/wc -l`;
	chomp $n,
	return $n;
}


#----------------------------------------------------------------------------
# get_next_date
# Obtiene la proxima fecha de ejecucion de la tarea
#
#----------------------------------------------------------------------------
sub get_next_date  {
my ($self,$timeref)=@_;


	# Chequeo casos con 6 campos (00 02 25 03 * 2008)
	# Son tareas anuales
	my @fields=split(/\s+/,$timeref);
	if ( scalar(@fields) > 5) {
		pop @fields;
		$timeref = join (" ",@fields);
	}

	$self->log('debug',"get_next_date::[DEBUG] TIMEREF=$timeref");

	my $lapse_since_1970 = -1;
   my $time_ref=$self->time_ref();
   my $TNOW=$time_ref->{'time'};

	eval {
  	 	$lapse_since_1970 = $CRON->get_next_execution_time($timeref);
   	my $time_left= $lapse_since_1970 - $TNOW;
   	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($lapse_since_1970);
   	$year+=1900;
   	$mon+=1;
   	my $next_date=sprintf("%02d:%02d:%02d %02d/%02d/%02d",$hour,$min,$sec,$mday,$mon,$year);
		$self->log('debug',"get_next_date::[DEBUG] $timeref >> Quedan $time_left segs ($next_date)");
	};
	if ($@) {
		$self->log('warning',"get_next_date::[ERROR] en modulo de Cron con TIMEREF=$timeref");
	}

	return $lapse_since_1970;
}


#----------------------------------------------------------------------------
# actions_manager
# Estado de las acciones:
#
# INSERT into qactions (name,descr,action,atype,cmd,params,auser,date_store,date_start,status) values ('act-1','xxxx','setmetric',0,'','1,2,3','admin',123,0,0);
#
#----------------------------------------------------------------------------
# SELECT id_qactions,name,descr,action,atype,cmd,params FROM qactions WHERE status in (0) and date_start<=xxxx;
#----------------------------------------------------------------------------
sub actions_manager  {
my ($self,$dbh)=@_;

	my $res='';
   my $store=$self->store();
   my $prov=$self->provision();
	$prov->istore($store);
	$prov->dbh($dbh);

	local $SIG{CHLD} = 'IGNORE';
   my $time_ref=$self->time_ref();
   my $TNOW=$time_ref->{'time'};

	my %GLOBALP=();
	my $sql='SELECT param_name,param_value FROM cnm_global_params';
	my $rres=$store->get_from_db_cmd($dbh,$sql,'');
	foreach my $l (@$rres) { $GLOBALP{$l->[0]}=$l->[1]; }

	# ------------------------------------------------------------------------
	# id_qactions
	# name : hash identificativo en qactions de la accion
	# descr : Descripcion de la accion
	# action : equivale al id texto que define la aplicacion (app_tcp_traceroute, custom_xxxx ...). (aname)
	# atype :
	# cmd : Comando
	# params : parametros
	# ------------------------------------------------------------------------

#SELECT q.id_qactions,q.name,q.descr,q.action,q.atype,q.cmd,q.task,IFNULL(a.name,'') FROM qactions q LEFT JOIN cfg_monitor_apps a ON (a.aname=q.task) WHERE (q.task='custom_072d101d' or q.task='setmetric');

	my $num_cpus=$self->num_cpus();

	$sql='SELECT q.id_qactions,q.name,q.descr,q.action,q.atype,q.cmd,q.params,q.format,q.task,q.id_proxy,IFNULL(a.name,"") FROM qactions q LEFT JOIN cfg_monitor_apps a ON (a.aname=q.task) WHERE status in ('.STAT_READY.") and date_start<=$TNOW LIMIT $num_cpus";
	$rres=$store->get_from_db_cmd($dbh,$sql,'');


#	my $what='id_qactions,name,descr,action,atype,cmd,params,format,task,id_proxy';
#	my $table='qactions';
#	my $where='status in ('.STAT_READY.") and date_start<=$TNOW";
#
#	my $rres=$store->get_from_db($dbh,$what,$table,$where);

	my $lastcmd = $store->lastcmd();
	$self->log('debug',"actions_manager::[DEBUG] Busco acciones con date<=$TNOW (SQL=$lastcmd)");

	foreach my $l (@$rres) {


#		eval {

			my %dbdata=( 'id_qactions'=>$l->[0], 'name'=>$l->[1], 'descr'=>$l->[2], 'action'=>$l->[3], 'atype'=>$l->[4], 'cmd'=>$l->[5], 'params'=>$l->[6], 'format'=>$l->[7], 'task'=>$l->[8], 'id_proxy'=>$l->[9], 'app_name'=>$l->[10] );

			$self->log('info',"actions_manager::[INFO] ACTION ID=$dbdata{id_qactions} NAME=$dbdata{name} DESCR=$dbdata{descr} ACTION=$dbdata{action} ATYPE=$dbdata{atype} CMD=$dbdata{cmd} PARAMS=$dbdata{params} FORMAT=$dbdata{format} TASK=$dbdata{task} ID_PROXY=$dbdata{id_proxy} app_name=$dbdata{app_name}");

			$self->set_run_status($dbh,$dbdata{'id_qactions'});
		
      	#-------------------------------------------------------------------------------
			my ($rc,$rcstr)=(undef,undef);
		
			$self->action_descr($dbdata{descr});
	     	my $r=$self->_params2cmd($dbh,$dbdata{task},$dbdata{params},\%GLOBALP);
			my $script=$dbdata{'cmd'};
			my $params=$r->{'args'};
  			my $f=$self->_get_results_filepath(\%dbdata);

			my $tag=$dbdata{action};
									
			# -------------------------------------------------------------	
			# 1. ACCIONES INTERNAS
			# -------------------------------------------------------------	
			if (exists $ACTION_CODE_INTERNAL{$dbdata{'task'}}) {

            $dbdata{'file'}=$f;

            my $child=fork;
            if ($child==0) {

               my $child_dbh=$store->fork_db($dbh);
               $prov->dbh($child_dbh);
               $store->dbh($child_dbh);

               eval {
                  ($rc,$rcstr) = &{$ACTION_CODE_INTERNAL{$dbdata{'task'}}}($self,$prov,$child_dbh,$store,\%dbdata);
               };
               if ($@) {
                   $self->log('warning',"actions_manager::[WARN] [$tag] ERROR EN TASK $dbdata{'task'} ($@)");
               }

					$self->log('info',"actions_manager::[**FML**] ***END INTERNAL PID=$$*** [$tag] TASK=$dbdata{'task'} rc=$rc rcstr=$rcstr");
               $self->_end_action($child_dbh,$dbdata{'id_qactions'},$rc,$rcstr);
               #$store->close_db($dbh);
               exit;
            }

				$self->_update_action_pid($dbh,$dbdata{'id_qactions'},$child);

            $self->log('info',"actions_manager::[INFO] ***START INTERNAL PID=$child*** [$tag] TASK=$dbdata{task} ID=$dbdata{id_qactions} NAME=$dbdata{name} DESCR=$dbdata{descr} ATYPE=$dbdata{atype} CMD=$dbdata{cmd} PARAMS=$dbdata{params} FORMAT=$dbdata{format} FILE=$f");

			}

			# -------------------------------------------------------------	
			# ACCIONES EXTERNAS
			# -------------------------------------------------------------	
			else {

				# Prepara el comando a ejecutar 
				# 1. Con las credenciales que requiera
				# 2. Segun el tipo de proxy
				# 3. Expande las IPs en caso de que sea necesarip 
				#my $vcmd = $self->_preparecmd($dbh,$dbdata{'action'},$dbdata{'task'},$script,$params);

				# -------------------------------------------------------------	
				# 2. EXTERNA (daemon) 
				# -------------------------------------------------------------	
			   if ($self->role() eq 'daemon') {

	            my $child=fork;
  		         if ($child==0) {

     		        	my $child_dbh=$store->fork_db($dbh);
						$res=$self->_start_external_cmd($script,$params,\%dbdata,$f,$tag,$child_dbh);
						$self->log('info',"actions_manager::[**FML**] ***END EXTERNAL PID=$$*** [$tag] TASK=$dbdata{'task'} res=$res");
						exit;
					}

					$self->_update_action_pid($dbh,$dbdata{'id_qactions'},$child);

	            $self->log('info',"actions_manager::[INFO] ***START EXTERNAL PID=$child*** [$tag] TASK=$dbdata{task} ID=$dbdata{id_qactions} NAME=$dbdata{name} DESCR=$dbdata{descr} ATYPE=$dbdata{atype} CMD=$dbdata{cmd} SCRIPT=$script PARAMS=$params FORMAT=$dbdata{format} FILE=$f");

           	}
				# -------------------------------------------------------------	
				# 3. EXTERNA (comando) 
				# -------------------------------------------------------------	
				else {
					my $child=fork;

               if ($child==0) {

				      open(STDOUT,">/dev/null");
      				open(STDERR,">&STDOUT");

						my $child_dbh=$store->fork_db($dbh);
						$res=$self->_start_external_cmd($script,$params,\%dbdata,$f,$tag,$child_dbh);
						$self->log('info',"actions_manager::[**FML**] ***END EXTERNAL PID=$$*** [$tag] TASK=$dbdata{'task'} res=$res");
						exit;
					}
	
					$self->_update_action_pid($dbh,$dbdata{'id_qactions'},$child);

               $self->log('info',"actions_manager::[INFO] ***START EXTERNAL PID=$child*** [$tag] TASK=$dbdata{task} ID=$dbdata{id_qactions} NAME=$dbdata{name} DESCR=$dbdata{descr} ATYPE=$dbdata{atype} CMD=$dbdata{cmd} SCRIPT=$script PARAMS=$params FORMAT=$dbdata{format} FILE=$f");
					return $f;
				}
			} #else
		
#     	};
#     	if ($@) {  $self->log('warning',"actions_manager::[WARN] ***ERROR** ($@)"); }

	}
}



#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
sub dispath_notifications {
my ($self, $dbh, $subtype, $file_path)=@_;

   my $res='';
   my $store=$self->store();
	my $transport=$self->transport();
	my $cfg=$self->cfg();

   # ------------------------------------------------------------------------
	#mysql> SELECT a.id_cfg_task_configured,a.name,c.value,d.name,d.id_notification_type FROM cfg_task_configured a, cfg_task2transport b, cfg_register_transports c, notification_type d  WHERE a.id_cfg_task_configured=b.id_cfg_task_configured AND b.id_register_transport=c.id_register_transport AND c.id_notification_type=d.id_notification_type AND a.subtype='custom_d2da7841-de1ccf9a';
	#+------------------------+------------------------------+--------------------+-------+----------------------+
	#| id_cfg_task_configured | name                         | value              | name  | id_notification_type |
	#+------------------------+------------------------------+--------------------+-------+----------------------+
	#|                      9 | AUDITORIA DE RED - LAN LOCAL | fmarin@s30labs.com | email |                    1 |
	#+------------------------+------------------------------+--------------------+-------+----------------------+
	#1 row in set (0.00 sec)

   my $what='a.id_cfg_task_configured,a.name,c.value,d.name,d.id_notification_type';
   my $table='cfg_task_configured a, cfg_task2transport b, cfg_register_transports c, notification_type d';
   my $where="a.id_cfg_task_configured=b.id_cfg_task_configured AND b.id_register_transport=c.id_register_transport AND c.id_notification_type=d.id_notification_type AND a.subtype='$subtype'";

   my $rres=$store->get_from_db($dbh,$what,$table,$where);

   foreach my $l (@$rres) {

		my ($id_task,$n,$dest,$type,$notif_type) = ($l->[0], $l->[1], $l->[2], $l->[3], $l->[4]);

		my($filename, $directories, $suffix) = fileparse($file_path);
      my $subject = '';
      my $url='';
      foreach my $u (@{$cfg->{'www_server_url'}}) {
         $url .= $u."/mod_tareas_resultado_aviso_simple.php?idp=$id_task&f=$filename\n";
      }
		if ($url eq '') { $url='https://'.$self->cid_ip()."/onm/mod_tareas_resultado_aviso_simple.php?idp=$id_task&f=$filename\n"; }

      my $text = "La tarea '$n' ha finalizado. El resultado se puede consultar en:\n$url";

      if ($notif_type == $Crawler::Transport::NOTIF_EMAIL) { $subject="[Tarea CNM] Finalizada: $n"; }

		$self->log('info',"dispath_notifications:: [$subtype] NOTIFY $type >> $dest");
#https://[ip_cnm]/onm/mod_tareas_resultado_aviso.php?idp=[id_tarea]&file_name=[nombre_fichero_resultado]
#https://10.2.254.222/onm/mod_tareas_resultado_aviso.php?idp=1&file_name=20111122_153030_13496dfd
#$transport->notify_by_transport(1, {'dest'=>'fmarin@s30labs.com', 'subject'=>'TEST CORREO (by Transport)', 'txt'=>'Mi texto'});

		$transport->notify_by_transport($notif_type, {'dest'=>$dest, 'subject'=>$subject, 'txt'=>$text});
	}
}


#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# _preparecmd
# Obtiene el valor de los parametros de la BBDD
#----------------------------------------------------------------------------
sub _preparecmd  {
my ($self,$dbh,$action,$task,$script,$params)=@_;


	my %vcmd=();
	my $store=$self->store();

	my ($cmd,$proxy_type,$proxy_user,$proxy_pwd)=('','','','');
   my $dir_scripts='/opt/data/mdata/scripts';
   if (! -d $dir_scripts) {
      mkdir $dir_scripts,0775;
      system("/bin/chown root:www-data $dir_scripts");
   }

   my $fp_script=$dir_scripts.'/'.$script;
   if (! -f $fp_script) {
      $store->script2file($dbh,$script);
   }

   my $rres=$store->get_from_db($dbh,'proxy_type,proxy_user,proxy_pwd','cfg_monitor_agent_script',"script=\'$script'",'');
	$proxy_type=$rres->[0][0];
	$proxy_user=$rres->[0][1];
	$proxy_pwd=$rres->[0][2];

	if ($proxy_type eq 'linux') {
		$cmd="/usr/bin/sudo -u $proxy_user $fp_script $params";
	}
	else {
		 $cmd="$fp_script $params";
	}

   # Se ejecuta script con iptab=1
   if ($params =~ /__TASK2DEVICE__/) {

      foreach my $ip (@{$Crawler::Actions::TASK2IP{$action}}) {

			my $cmd_ip=$cmd;
			my $untagip=$self->untag_ip($ip);
         $cmd_ip =~ s/__TASK2DEVICE__/$untagip/;

         $vcmd{$ip}=$cmd_ip;
         #$self->log('info',"_preparecmd:: [$tag] ID=$dbdata{id_qactions} PREPARE CMD IP=$ip cmd=$cmd file=$f format=$dbdata{format}");
         $self->log('info',"_preparecmd:: __TASK2DEVICE__ action=$action IP=$ip untagip=$untagip cmd=$cmd_ip");
      }
   }
   else {
      my $ip='noip';
      $vcmd{$ip}=$cmd;
      #$self->log('info',"_preparecmd:: [$tag] ID=$dbdata{id_qactions} PREPARE CMD IP=$ip cmd=$cmd file=$f format=$dbdata{format}");
      $self->log('info',"_preparecmd:: action=$action IP=$ip cmd=$cmd");
   }


	return \%vcmd;

}

#----------------------------------------------------------------------------
# _get_action_globals
# Para aplicaciones externas
# El campo params de qactions puede contener variables globales o de entorno,
# definidas al configurar la tarea (en cfg_task_configured).
# En este caso se utiliza una estructura json del tipo:
# {"var":[{"$gui_text_text1":"campo1"},{"$gui_text_text2":"campo2"},{"$gui_file_file1":"\/opt\/cnm\/onm\/tmp\/skidata.txt"},{"$gui_file_file2":"\/opt\/cnm\/onm\/tmp\/resultado.txt"}]}
#
#----------------------------------------------------------------------------
sub _get_action_globals {
my ($self,$params)=@_;
	
	my $global = {};
	# Lo primero seria ver si es json
	if ($params !~ /^\{/) { return $global; }

   eval {
      my $json=JSON->new();
      $json->ascii(1);
      $global=$json->decode($params);
   };
   if ($@) {
      $self->log('warning',"get_task_params:: **ERROR** EN DECODE JSON de params --$params-- ($@)");
   }

	return $global;
}


#----------------------------------------------------------------------------
# _params2cmd
# Obtiene el valor de los parametros de la BBDD
#----------------------------------------------------------------------------
#mysql> SELECT s.script,s.prefix,a.value,s.param_type FROM cfg_script_param s, cfg_app_param a WHERE s.script=a.script and a.hparam=s.hparam and a.aname='app_cnm_dev_alta' ORDER BY s.position;
#+---------------+--------+----------+------------+
#| script        | prefix | value    | param_type |
#+---------------+--------+----------+------------+
#| ws_set_device | -p     | status=0 |          0 |
#| ws_set_device | -a     |          |          2 |
#+---------------+--------+----------+------------+

sub _params2cmd  {
my ($self,$dbh,$aname,$params,$globalp)=@_;


	my $global = $self->_get_action_globals($params);
	foreach my $k (keys %$globalp) { $global->{'var'}->{$k}=$globalp->{$k}; }

my $aux=Dumper($global);
$aux=~s/\n/\. /g;
$self->log('info',"_params2cmd::[INFO] global>>> $aux");

	my $store=$self->store();
   my $what='s.script,s.prefix,a.value,s.param_type';
   my $table='cfg_script_param s, cfg_app_param a';
   my $where="s.script=a.script and a.hparam=s.hparam and a.aname='$aname' and a.enable=1";
	my $other='order by s.position';
   my $rres=$store->get_from_db($dbh,$what,$table,$where,$other);

	my $script = '';
	my $ip_param = '';
	my @params2cmd=();
   foreach my $l (@$rres) {

		$script = $l->[0];
		my ($prefix,$value,$param_type)=($l->[1],$l->[2],$l->[3]);

   $self->log('info',"_params2cmd::[**FML**] script=$script **PREVIO** value=$value");

		# Si existen variables globales, se sustituyen.
		#if (exists $global->{'var'}->[0]->{$value}) { $value=$global->{'var'}->[0]->{$value}; }
		if (exists $global->{'var'}->{$value}) { $value=$global->{'var'}->{$value}; }

      $value =~ s/^"(.*)"$/$1/g;
      if ($value =~ /\S+\s+\S+/) { $value = '"'.$value.'"';

   $self->log('info',"_params2cmd::[**FML**] script=$script **ESPACIOS** value=$value");
}
else {

$self->log('info',"_params2cmd::[**FML**] script=$script **SIN ESPACIOS** value=$value");
}




		if ($param_type == 2) {
 			push @params2cmd, "$prefix __TASK2DEVICE__"; 
		}
		else { push @params2cmd, "$prefix $value"; }
	}

	my $args = join(' ', @params2cmd);
	$self->log('info',"_params2cmd::[**FML**] script=$script args=$args (aname=$aname)");
	$self->log('info',"_params2cmd::[**FML**] **DEBUG** SELECT s.script,s.prefix,a.value,s.param_type FROM cfg_script_param s, cfg_app_param a WHERE s.script=a.script and a.hparam=s.hparam and a.aname='$aname' and a.enable=1 order by s.position");
 
   return {'script'=>$script, 'args'=>$args};
}

#----------------------------------------------------------------------------
# _params2action
# Obtiene el valor de los parametros a partir del formato almacenado en BBDD
# [-u1;Usuario1;user1]:[-p1;Password1;pass1]:[-i1;IP1;]
#----------------------------------------------------------------------------
sub _params2action  {
my ($self,$params, $ipparam)=@_;

   my @blocks=split(':',$params);
   my %paramsbyname=();
   foreach my $b (@blocks) {
      if ($b =~  /\[(.*?);(.*?);(.*?)\]/) {
         my ($modif,$name,$value) = ($1,$2,$3);
			$paramsbyname{$name} = [$modif, $value];
      }
   }

	my $ipparam_name='';
	if ($ipparam =~  /\[(.*?);(.*?);(.*?)\]/) {
		my ($modif,$name,$value) = ($1,$2,$3);
		$ipparam_name=$name;
	}

	if ( (exists $paramsbyname{$ipparam_name}) && ($paramsbyname{$ipparam_name}->[1] eq '') ) {
		$params =~ s/$ipparam_name;\]/$ipparam_name;__TASK2DEVICE__\]/;
	}

   return $params;
}



#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# _xxxx (funciones auxiliares)
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------


#----------------------------------------------------------------------------
# _get_params
# Devuelve en un hash los parametros de la accion
#----------------------------------------------------------------------------
sub _get_params  {
my ($self,$params)=@_;

	my @p=split(';',$params);
   my %h=();
   for (my $i=0; $i < scalar @p; $i++) {
   	#if ($i == 0) { $h{'id_dev'}=$p[0]; }
      my ($x1,$y1)=split('=',$p[$i]);
      $h{$x1}=$y1;
      $self->log('debug',"_get_params::[DEBUG] PARAMS: $x1 >> $y1");
   }
	return \%h;	
}

#----------------------------------------------------------------------------
# _update_action_pid
# Actualiza el PID de una accion en curso y el date_start.
#----------------------------------------------------------------------------
sub _update_action_pid  {
my ($self,$dbh,$id_qactions,$pid)=@_;

   my $store=$self->store();
	my $tnow=time();
	my $rv=$store->update_db($dbh,'qactions',{'pid'=>$pid, 'date_start'=>$tnow },"id_qactions=$id_qactions");

   if ($libSQL::err) {
      $self->log('info',"_update_action_pid::[ERROR BD] ($libSQL::err) $libSQL::errstr");
   }
}


#----------------------------------------------------------------------------
# _end_action
# Almacena el estado de finalizado de la accion
#----------------------------------------------------------------------------
sub _end_action  {
my ($self,$dbh,$id_qactions,$rc,$rcstr)=@_;

	my $store=$self->store();
	my %d=();
   $d{'status'}=STAT_END;
   $d{'date_end'}=time;
   $d{'rc'}=$rc;
   $d{'rcstr'}=$rcstr;
	# Puede ser normal que a la hora de cerrar la accion haya que reconectarse a la BBDD
	# Hay dos casos muy claros:
	# Si estamos dentro de otro thread se debe abrir otra conexion a la BBDD, esto se indica pasando $dbh como undef
	# Cuando la tarea sea muy larga y haya expirado el timeout (p.ej. una auditoria de red)
	if (! defined $dbh) {
		$dbh=$store->open_db();
		$self->log('info',"_end_action:: id_qactions=$id_qactions RECONNECT DB DBH=$dbh");
	}
   my $rv=$store->update_db($dbh,'qactions',\%d,"id_qactions=$id_qactions");

	# Si la accion fuera muy larga puede ser necesqaria una reconexion a la BBDD por timeout
   if ($libSQL::err) {
		$self->log('info',"_end_action::[ERROR BD] ($libSQL::err) $libSQL::errstr");
      $dbh=$store->open_db();
      $self->dbh($dbh);
      if ($libSQL::err) { $self->log('warning',"_end_action::[ERROR BD] NEW DBH ($libSQL::err) $libSQL::errstr"); }
      else { $self->log('debug',"_end_action::[INFO BD] NEW DBH OK"); }
   	$store->update_db($dbh,'qactions',\%d,"id_qactions=$id_qactions");
   }

	$self->log('info',"_end_action:: id_qactions=$id_qactions rc=$rc rcstr=$rcstr (rv=$rv) cmd=$libSQL::cmd DBH=$dbh");
	my $rx=$store->close_db($dbh);
	$self->log('info',"_end_action:: id_qactions=$id_qactions CLOSE DB (rx=$rx)");
}


#----------------------------------------------------------------------------
# set_run_status
# Almacena el estado de run de la accion
#----------------------------------------------------------------------------
sub set_run_status  {
my ($self,$dbh,$id_qactions)=@_;

   my $store=$self->store();
   my %d=();
   $d{'status'}=STAT_RUN;
   my $rv=$store->update_db($dbh,'qactions',\%d,"id_qactions=$id_qactions");

#	$self->log('debug',"set_run_status::[DEBUG] (rv=$rv) cmd=$libSQL::cmd DBH=$dbh");
}

#----------------------------------------------------------------------------
# _get_results_filepath
# Obtiene el fichero con la ruta completa donde almacenar los resultados
#----------------------------------------------------------------------------
sub _get_results_filepath  {
my ($self,$dbdata)=@_;

# action=app_cnm_dev_alta-e076bf8d 
# task=app_cnm_dev_alta

	my $name_file=$dbdata->{'name'};

	my $FILE_PATH_TASKS='/var/www/html/onm/files/tasks';
   my $subdir = $FILE_PATH_TASKS.'/';
	my $subdir0 = '';

      # 0 actions    app-ip   online
      # 10 actionsd  app-ip   app diferida
      # 11 actionsd  app      app diferida
      # 12 actionsd  task     app diferida-planificada
      # 13 actionsd  task     app diferida-evento

	if ( ($dbdata->{'atype'}==0) || ($dbdata->{'atype'}==10) ) { 
		$subdir0 = $dbdata->{'task'}; 
		my $k = $dbdata->{action};
		my $ip=$Crawler::Actions::TASK2IP{$k}->[0];
		$subdir0 .= '-'.$ip;
	}
	elsif ($dbdata->{'atype'}==11) { $subdir0 = $dbdata->{'task'}; }
	elsif ( ($dbdata->{'atype'}==12) || ($dbdata->{'atype'}==13) ) { $subdir0 = $dbdata->{'action'}; }

	$subdir .= $subdir0;

   #my $url_path="$FILE_PATH_TASKS_URL/".$dbdata->{'action'};
   if ( ! -d $FILE_PATH_TASKS) { mkdir $FILE_PATH_TASKS, 0755; }
   if ( ! -d $subdir) { mkdir $subdir, 0755; }
	system ("/bin/chown -R www-data:www-data $subdir");
	$self->log('debug',"_get_results_filepath::[DEBUG] CMD=/bin/chown -R www-data:www-data $subdir");

   my $time_ref=$self->time_ref();
   my $TNOWstr=$time_ref->{'time_str'};

	#/var/www/html/onm/files/tasks/app_mib2_listinterfaces-10.2.254.222/20120418_103003_3706ea61
	my $fname = $TNOWstr.'_'.$name_file;
   my $url_info='d='.   $subdir0.'&f='.$fname;

	$self->url_info($url_info);
   my $f="$subdir/$fname";
   return $f;

}


#----------------------------------------------------------------------------
# _start_external_cmd
# format:
# 				0: raw (sin formato)
# 				1: json
# 				2: xml-grid
#----------------------------------------------------------------------------
sub _start_external_cmd  {
my ($self,$script,$params,$dbdata,$f,$tag,$dbh)=@_;

	my $action=$dbdata->{'action'};
	my $format=$dbdata->{'format'};
	my $id_qactions=$dbdata->{'id_qactions'};
	my $id_proxy=$dbdata->{'id_proxy'};
	my $app_name = ($dbdata->{'app_name'} ne '') ? $dbdata->{'app_name'} : $dbdata->{'task'};

	my ($rc,$rcstr);
	my $FOUT;


  	my $xagent=$self->xagent();
   my $file_script=$xagent->script_dir().'/'.$script;
   my $store=$self->store();
   if (! -f $file_script) {
      $store->script2file($dbh,$script);
   }

   my $proxies=$xagent->proxies();
   $xagent->get_proxy_credentials($id_proxy,$proxies);

	my $exec_vector=$xagent->exec_vector();

   my($filename, $directories, $suffix) = fileparse($f);
	$directories=~s/^(.+)\/$/$1/;
	my $finuse=$directories.'/_'.$filename;

   open (FOUT, ">$finuse");
   print FOUT '';
   close FOUT;


	if (! exists $Crawler::Actions::TASK2IP{$action}) { 
		push @{$Crawler::Actions::TASK2IP{$action}}, 'localhost'; 
	}

	my $credentials = $store->get_device_credentials($dbh);

	# El resultado viene sin formato
	# -----------------------------------------------------------------------
	if ($format==0) {
			
		my %all_data=();
      #foreach my $ip (keys %$vcmd) {
		foreach my $ip (@{$Crawler::Actions::TASK2IP{$action}}) {

	      my $ts=time;

#		   my $cmd=$vcmd->{$ip};
      	my ($rc,$stdout, $stderr);
#      	capture sub { $rc=system($cmd); } => \$stdout, \$stderr;
#			$self->log('info',"_start_external_cmd:: [$tag] ID=$id_qactions EXEC APP RAW IP=$ip cmd=$cmd file=$f format=$format");

   		$exec_vector->{'file_script'}=$file_script;
		   #$exec_vector->{'params'}=$xagent->_compose_params($params,$ip);
		   $exec_vector->{'params'}=$params;
			my $untagip=$self->untag_ip($ip);
		   $exec_vector->{'params'}=~s/__TASK2DEVICE__/$untagip/;
			$exec_vector->{'host_ip'}=$ip;

			if (exists $credentials->{$ip}) {
				foreach my $v (keys %{$credentials->{$ip}}) {
					my $k="\\".$v;
		   		$exec_vector->{'params'}=~s/$k/$credentials->{$ip}->{$v}/;
				}
			}
   		$xagent->exec_vector($exec_vector);

			$self->log('info',"_start_external_cmd:: [$tag] ID=$id_qactions EXEC APP RAW IP=$ip CMD=$file_script $exec_vector->{'params'} file=$f format=$format");
			my $out_cmd=$xagent->execScript();
			$stdout=join("\n", @$out_cmd);

			my $stdout_utf8 = encode('utf8', $stdout);

			$all_data{$ip}={'data'=>$stdout_utf8, 'ts'=>$ts};
		}

		my $H1='<?xml version="1.0" ?>'."\n".'<rows>'."\n";
		my $H2='<head>'."\n".'<column type="ro" width="10" sort="text" align="left">Fecha</column>'."\n".'<column type="ro" width="10" sort="text" align="left">IP</column>'."\n".'<column type="ro" width="80" sort="text" align="left">Resultado</column>'."\n".'<settings><colwidth>%</colwidth></settings><beforeInit><call command="setSkin"><param>light</param></call><call command="enableMultiline"><param>true</param></call></beforeInit><afterInit><call command="attachHeader"><param>#text_filter,#select_filter,#text_filter</param></call></afterInit>'."\n".'</head>'."\n".'</rows>'."\n";
      open (FOUT, ">$finuse");
      print FOUT $H1;

   	my $cnt=0;
		foreach my $ip (keys %all_data) {
      	$all_data{$ip}->{'data'} =~ s/\n/ <br>/g;

			$all_data{$ip}->{'data'} =~ s/(https*\:\/\/\S+)/<a href=\"$1\" title=\"\" target=\"_blank\">$1<\/a>/g;

			my $timedate=$self->time2date($all_data{$ip}->{'ts'});

$self->log('info',"_start_external_cmd:: [$tag] ID=$id_qactions EXEC APP RAW ip=$ip data=$all_data{$ip}->{'data'}");

			my $R1='<row id="'.$cnt.'"><cell>'.$timedate.'</cell><cell>'.$ip.'</cell><cell style="word-break: break-all"><![CDATA['.$all_data{$ip}->{'data'}.']]></cell></row>'."\n";

         print FOUT $R1;
			$cnt += 1;

		}

      print FOUT $H2;
      close FOUT;

      $rc=move($finuse,$f);
      if (! $rc) {
         $self->log('warning',"_start_external_cmd:: [$tag] **ERROR AL MOVER*** $finuse -> $f ($!) ID=$id_qactions");
      }

	}

	# JSON (1)
	# JSON CON POSTPROCESO PARA ESTILOS (2)
   # -----------------------------------------------------------------------
   elsif ( ($format==1) || ($format==2)   || ($format==3)      ) {

		my ($data, $col_map);
		my %all_data=();
      my $ts=time;
      my $timedate=$self->time2date($ts);

		eval {

			foreach my $ip (@{$Crawler::Actions::TASK2IP{$action}}) {
				
	         my ($rc,$stdout, $stderr);
   	      $exec_vector->{'file_script'}=$file_script;
		   	$exec_vector->{'params'}=$params;
				my $untagip=$self->untag_ip($ip);
		   	$exec_vector->{'params'}=~s/__TASK2DEVICE__/$untagip/;
				$exec_vector->{'host_ip'}=$ip;

	         if (exists $credentials->{$ip}) {
   	         foreach my $v (keys %{$credentials->{$ip}}) {
         	$self->log('warning',"_start_external_cmd:: [$tag] **DEBUG** IP=$ip v=$v VALOR=$credentials->{$ip}->{$v}  ($exec_vector->{'params'})");
						my $k="\\".$v;
      	         $exec_vector->{'params'}=~s/$k/$credentials->{$ip}->{$v}/;
         	   }
         	}
         	$xagent->exec_vector($exec_vector);

         	$self->log('warning',"_start_external_cmd:: [$tag] ID=$id_qactions EXEC APP JSON IP=$ip CMD=$file_script $exec_vector->{'params'}");
	         my $out_cmd=$xagent->execScript();
   	      $stdout=join("\n", @$out_cmd);

         	($data, $col_map) = split (/\n/, $stdout);
				$all_data{$ip}=$data;				

         	$self->log('warning',"_start_external_cmd:: [$tag] ID=$id_qactions EXEC APP JSON data=$data");
         	$self->log('warning',"_start_external_cmd:: [$tag] ID=$id_qactions EXEC APP JSON col_map=$col_map");

			}

			my $xml1 = json2xml(\%all_data,$col_map,$timedate);
			my $xml = encode('utf8', $xml1);

	      my $rc=open (FOUT, ">$finuse");
         if (! $rc) {
            $self->log('warning',"_start_external_cmd:: [$tag] **ERROR AL ABRIR*** finuse=$finuse");
         }
   	   print FOUT $xml;
      	close FOUT;

			$rc=move($finuse,$f);
			if (! $rc) {
				$self->log('warning',"_start_external_cmd:: [$tag] **ERROR AL MOVER*** $finuse -> $f ($!) ID=$id_qactions");
			}
$self->log('warning',"_start_external_cmd:: [$tag] **DEBUG*** $finuse -> $f ($!) ID=$id_qactions");

      };
      if ($@) {
			$@ =~s/\n/\.\./;
         $self->log('warning',"_start_external_cmd:: [$tag] ID=$id_qactions **ERROR** ($@) EXEC APP JSON file=$f data=$data  CMD=$file_script $exec_vector->{'params'} (params=$params)");
			if (-f $finuse) { 
				$rc=move($finuse,$f);
         	if (! $rc) {
            	$self->log('warning',"_start_external_cmd:: [$tag] **ERROR AL MOVER*** $finuse -> $f ($!) ID=$id_qactions");
         	}
			}
      }

   }


	# El resultado viene con formato XML-GRID
	# -----------------------------------------------------------------------
	else {
	
		#foreach my $ip (keys %$vcmd) {
		foreach my $ip (@{$Crawler::Actions::TASK2IP{$action}}) {

			#my $cmd=$vcmd->{$ip};
         my ($rc,$stdout, $stderr);
         #capture sub { $rc=system($cmd); } => \$stdout, \$stderr;
			#$self->log('info',"_start_external_cmd:: [$tag] ID=$id_qactions EXEC APP SIFORMAT IP=$ip cmd=$cmd file=$f format=$format");


         $exec_vector->{'file_script'}=$file_script;
         #$exec_vector->{'params'}=$xagent->_compose_params($params,$ip);
		   $exec_vector->{'params'}=$params;
			my $untagip=$self->untag_ip($ip);
		   $exec_vector->{'params'}=~s/__TASK2DEVICE__/$untagip/;
			$exec_vector->{'host_ip'}=$ip;

         if (exists $credentials->{$ip}) {
            foreach my $v (keys %{$credentials->{$ip}}) {
					my $k="\\".$v;
               $exec_vector->{'params'}=~s/$k/$credentials->{$ip}->{$v}/;
            }
         }

         $xagent->exec_vector($exec_vector);

         $stdout=$xagent->execScript();

         my $res_xml = encode('utf8', $stdout);

			$self->log('info',"_start_external_cmd:: [$tag] ID=$id_qactions EXEC APP SIFORMAT IP=$ip cmd=$file_script $exec_vector->{'params'}  file=$f format=$format");
			
			# Si ya existe el fichero de resultados con datos
			#if ( (-f $f) && (-s $f >0) ) {
			if (-f $f)  {

				my $pre='<?xml version="1.0" ?>'."\n<rows>";
				my $head='<head>';
				my $in_head=0;
				open ($FOUT, "<$finuse");
				$self->lock($FOUT);
				while (<$FOUT>) {
					chomp;
					if (/<head>/) { 
						$in_head=1; 
						if (/<head>(.*)$/) { $head.="$1\n"; }
					}
					elsif (/<\/head>/) { 
						$in_head=0; 
						if (/^(.*?)<\/head>/) { $head.="$1\n"; }
					}
					elsif ($in_head) { $head.="$_\n"; }
				}
				$self->unlock($FOUT);
				close $FOUT;
				$head.="</head>\n</rows>";
			
				#-----------------
				my $id=0;
				my $rows='';
				my $parser = XML::LibXML->new();
				my $xml1 = $parser->parse_file($f);
         	foreach my $row ($xml1->findnodes('/rows/row')) {
            	my $cells1 = $row->findnodes('./cell');
					$rows.="<row id=\"$id\">";
   	         foreach my $cell (@$cells1) {
#<cell><![CDATA[2010/11/26 14:34:22]]></cell>
      	        $rows.='<cell><![CDATA['. $cell->to_literal . ']]></cell>';
         	   }
					$rows.="</row>\n";
					$id+=1;
   	      }
      	   my $xml2 = $parser->parse_string($res_xml);
         	foreach my $row ($xml2->findnodes('/rows/row')) {
            	my $cells2 = $row->findnodes('./cell');
	            $rows.="<row id=\"$id\">";
   	         foreach my $cell (@$cells2) {
      	        $rows.='<cell><![CDATA['. $cell->to_literal . ']]></cell>';
         	   }
            	$rows.="</row>\n";
					$id+=1;
   	      }

				open ($FOUT, ">$finuse");
				$self->lock($FOUT);
				print $FOUT $pre;
				print $FOUT $rows;
				print $FOUT $head;
				$self->unlock($FOUT);
         	close $FOUT;
			}
			#Si no existe el fichero de resultados con datos
			else {

		      open ($FOUT, ">>$finuse");
				$self->lock($FOUT);
				print $FOUT "$res_xml\n";
				$self->unlock($FOUT);
      		close $FOUT;
			}	
		}

      $rc=move($finuse,$f);
      if (! $rc) {
         $self->log('warning',"_start_external_cmd:: [$tag] **ERROR AL MOVER*** $finuse -> $f ($!) ID=$id_qactions");
      }

	}

	system ("/bin/chown -R www-data:www-data $f");
	
  	#($rc,$rcstr)=(0,"file://$f");
  	($rc,$rcstr)=(0,"APLICACION: $app_name");
   $self->_end_action(undef,$id_qactions,$rc,$rcstr);

	$self->log('info',"_start_external_cmd:: ***END EXTERNAL PID=$$*** [$tag] ID=$id_qactions rc=$rc rcstr=$rcstr");

	$self->dispath_notifications($dbh,$tag,$f);

   if ($self->role() eq 'daemon') { exit; }

	return $f;	
}

#<?xml version="1.0" ?>
#<rows>
#<row id="0"><cell><![CDATA[10.2.254.228]]></cell><cell><![CDATA[1]]></cell><cell><![CDATA["lo"]]></cell><cell><![CDATA[softwareLoopback]]></cell><cell><![CDATA[16436]]></cell><cell><![CDATA[10000000]]></cell><cell><![CDATA[""]]></cell><cell><![CDATA[up]]></cell><cell><![CDATA[up]]></cell></row>
#<row id="1"><cell><![CDATA[10.2.254.228]]></cell><cell><![CDATA[2]]></cell><cell><![CDATA["eth0"]]></cell><cell><![CDATA[ethernet-csmacd]]></cell><cell><![CDATA[1500]]></cell><cell><![CDATA[10000000]]></cell><cell><![CDATA["00 0C 29 57 D3 22 "]]></cell><cell><![CDATA[up]]></cell><cell><![CDATA[up]]></cell></row>
#<row id="2"><cell><![CDATA[10.2.254.228]]></cell><cell><![CDATA[3]]></cell><cell><![CDATA["sit0"]]></cell><cell><![CDATA[131]]></cell><cell><![CDATA[1480]]></cell><cell><![CDATA[0]]></cell><cell><![CDATA[""]]></cell><cell><![CDATA[down]]></cell><cell><![CDATA[down]]></cell></row>
#
#<head>
#<column type="ro" width="10" sort="text" align="left">IP</column>
#<column type="ro" width="5" sort="str" align="left">Idx</column>
#<column type="ro" width="15" sort="str" align="left">Descripcion</column>
#<column type="ro" width="10" sort="str" align="left">Type</column>
#<column type="ro" width="10" sort="str" align="left">MTU</column>
#<column type="ro" width="10" sort="str" align="left">Speed</column>
#<column type="ro" width="20" sort="str" align="left">ifPhysAddress</column>
#<column type="ro" width="10" sort="str" align="left">ifAdminStatus</column>
#<column type="ro" width="10" sort="str" align="left">ifOperStatus</column>
#<settings><colwidth>%</colwidth></settings><beforeInit><call command="setSkin"><param>light</param></call></beforeInit><afterInit><call command="attachHeader"><param>#text_filter,#text_filter,#select_filter,#text_filter,#select_filter,#text_filter,#select_filter,#select_filter</param></call></afterInit>
#</head>
#</rows>



#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# ACCIONES INTERNAS OCULTAS (NO APARECEN EN LA INTERFAZ)
#----------------------------------------------------------------------------
# $dbdata->{'params'} contiene un string con los parametros k=v separados por ';'
#----------------------------------------------------------------------------


#----------------------------------------------------------------------------
# int_setmetric
#
#----------------------------------------------------------------------------
sub int_setmetric   {
my ($self,$prov,$dbh,$store,$dbdata)=@_;

	my $p=$dbdata->{'params'};
	my $par=$self->_get_params($p);
	$prov->prov_do_set_device_metric($par);
   my $rc=$prov->rc();
   my $rcstr=$prov->rcstr();
	return ($rc, $rcstr);
	
}

#----------------------------------------------------------------------------
# int_delmetricdata
#
#----------------------------------------------------------------------------
sub int_delmetricdata   {
my ($self,$prov,$dbh,$store,$dbdata)=@_;

   my $p=$dbdata->{'params'};
   my $par=$self->_get_params($p);
   $prov->prov_del_metric_data($par);
   my $rc=$prov->rc();
   my $rcstr=$prov->rcstr();
   return ($rc, $rcstr);

}


#----------------------------------------------------------------------------
# int_clone
#
#----------------------------------------------------------------------------
sub int_clone   {
my ($self,$prov,$dbh,$store,$dbdata)=@_;

   my $p=$dbdata->{'params'};
   my $par=$self->_get_params($p);
   #$prov->prov_do_set_device_metric($par);
	
#$provision->clone_template_metrics({'id_dev_src'=>$id_dev_src, 'id_dev_dst'=>\@id_dev_dst});

	$prov->clone_template_metrics($par);
   my $rc=$prov->rc();
   my $rcstr=$prov->rcstr();
   return ($rc, $rcstr);

}

1;
__END__

