#----------------------------------------------------------------------------------------------------
# Fichero: Crawler::Notifications.pm
# Fecha: 15/08/2001 - 2016
#----------------------------------------------------------------------------------------------------
# notificationsd -> do_task -> alerts by polling (snmp/latency/xagent) -> manage_app_notifications
# mail_manager -> do_task_mail -> remote email (polling del buzon) 
#----------------------------------------------------------------------------------------------------
use Crawler;
package Crawler::Notifications;
@ISA=qw(Crawler);
$VERSION='1.00';
use strict;
use POSIX ":sys_wait_h";
use Carp 'croak','cluck';
use Cwd;
use Net::SMTP;
use Net::SMTP::TLS;
use Digest::MD5 qw( md5_hex );
use Device::SerialPort;
use Device::Gsm;
use Date::Calc qw( Days_in_Month );
use ONMConfig;
use IO::File;
use MIME::Parser;
use MIME::Entity;
use JSON;
use Data::Dumper;
use SOAP::Lite;
use Encode;
use ATypes;
use Crawler::CNMWS;
use Crawler::Transport;
use Crawler::Actions;
use Crawler::Xagent;
use ProvisionLite;
use Crawler::LogManager::Email;
my $ETXT='KEY-ERROR';
#----------------------------------------------------------------------------
# c.id_cfg_notification,d.id_device,c.id_alert_type,c.id_notification_type,c.destino,c.name,c.monitor,c.type
# a.id_device,a.id_alert_type,t.cause,d.name,d.domain,d.ip,a.notif,a.id_alert,a.mname
use constant nID_CFG_NOTIF => 0;
use constant nDEVICE => 1;
use constant nALERT_TYPE=> 2;
use constant nNOTIF_TYPE=> 3;
use constant nDEST=> 4;
use constant nDESCR=> 5;
use constant nMONITOR=>6 ;
use constant nTYPE=>7 ;	# Tipo de notificacion (0 en SET/ 1 en SET y CLR)

use constant aDEVICE => 0;
use constant aALERT_TYPE=> 1;
use constant aALERT_CAUSE=> 2;
use constant aALERT_DEV_NAME=> 3;
use constant aALERT_DEV_DOMAIN=> 4;
use constant aALERT_DEV_IP=> 5;
use constant aNOTIF=> 6;
use constant aID_ALERT=> 7;
use constant aMNAME=> 8;
use constant aWATCH=> 9;
use constant aEVENT_DATA=> 10;
use constant aACK=> 11;
use constant aID_TICKET=> 12;
use constant aSEVERITY=> 13;
use constant aTYPE=> 14;
use constant aDATE=> 15;
use constant aCOUNTER=> 16;
use constant aID_METRIC=> 17;

#-------------------------------
use constant NOTIF_1 => 1;
use constant NOTIF_2 => 2;
use constant NOTIF_3 => 3;
use constant NOTIF_4 => 4;
use constant NOTIF_LAST => 5;
use constant NOTIF_LAST_CLR => 6;

#id_notification_type-----------
#use constant NOTIF_EMAIL => 1;
#use constant NOTIF_SMS => 2;
#use constant NOTIF_TRAP => 3;

#-------------------------------
use constant TRAP_ALERT_TYPE => 10;

#-------------------------------
use constant TASK_NORMAL => 10;
use constant TASK_NOTIFICATIONS => 20;
use constant TASK_SEV4 => 40;
use constant TASK_ANALYSIS => 100;
use constant TASK_MAIL => 1000;


my $SNMP;
my $LATENCY;
my $XAGENT;
my $WBEM;
my $CNMWS;

my %TASKS =();
#my $ALERTS_SET;		# Referencia a un array con las alertas en curso (SET). Cada elemento del array es:
							# [ a.id_device,a.id_alert_type,t.cause,d.name,d.domain,d.ip,a.notif,a.id_alert,a.mname ]
my @ALERTS_CLR=();	# Referencia a un hash con las alertas en curso (CLEAR).
							# [ aDEVICE, aALERT_TYPE, aALERT_CAUSE, DEV_NAME, DEV_DOMAIN, DEV_IP, aNOTIF, aID_ALERT, aMNAME ]
my $CFG_NOTIF;			# Referencia a un hash con los avisos configurados.
my $CFG_APP;

my $FILE_CONF='/cfg/onm.conf';
my $RELOAD_FILE='/var/www/html/onm/reload/notificationsd.reload';

my %FIFO_FUNCTION = ( 'delta'=>\&delta, 'step'=>\&step, 'step_up'=>\&step_up, 'step_down'=>\&step_down, 'window'=>\&window, );
my %ALERTS_FIFO = ();
my %WATCHES = ();
my %EMAIL2DEV = ();
my %DEV2IRULE = ();
my %DEV2WSIZE = ();
my $IRULES = {};
my $KEY;
my ($SET,$CLR,$CLR0,$SKIP,$AVISOS)=(0,0,0,0,0);

#----------------------------------------------------------------------------
my %WATCH_TYPES=(

   'snmp' => {

      'what'=>'d.ip,d.name,d.domain,a.mname,t.severity,d.status,a.event_data,m.module,m.label,m.mode,m.file,m.status,o.oid,d.community,d.version,c.get_iid,m.watch,t.expr,0,0,c.cfg,m.type',

      'from'=>'alerts a, metrics m, devices d, metric2snmp o, cfg_monitor_snmp c, alert_type t',

		'where'=>'a.mname=m.name and a.id_device=d.id_dev and a.id_device=m.id_dev and m.type=\'snmp\' and m.id_metric=o.id_metric and c.subtype=m.subtype and t.id_alert_type=a.id_alert_type',
      },

   'wbem' => {

      'what'=>'d.ip,d.name,d.domain,a.mname,t.severity,d.status,a.event_data,m.module,m.label,m.mode,m.file,m.status,o.oid,d.wbem_user,d.wbem_pwd,c.get_iid,m.watch,t.expr,0,0,c.cfg,m.type',

      'from'=>'alerts a, metrics m, devices d, metric2snmp o, cfg_monitor_wbem c, alert_type t',

      'where'=>'a.mname=m.name and a.id_device=d.id_dev and a.id_device=m.id_dev and m.type=\'wbem\' and m.id_metric=o.id_metric and c.subtype=m.subtype and t.id_alert_type=a.id_alert_type',
      },


   'latency'=> {

		'what'=>'d.ip,d.name,d.domain,a.mname,t.severity,d.status,a.event_data,m.module,m.label,m.mode,m.file,m.status,0,0,0,0,m.watch,t.expr,o.monitor,o.monitor_data',

      'from'=>'alerts a, metrics m, devices d, metric2latency o, alert_type t',

		'where'=>'t.id_alert_type=a.id_alert_type and a.mname=t.mname and a.id_device=d.id_dev and m.id_dev=d.id_dev and m.name=a.mname and m.id_metric=o.id_metric and m.type=\'latency\'',
      },


   'xagent'=> {

      'what'=>'d.ip,d.name,d.domain,a.mname,t.severity,d.status,a.event_data,m.module,m.label,m.mode,m.file,m.status,0,0,0,0,m.watch,t.expr,o.monitor,o.monitor_data',

      'from'=>'alerts a, metrics m, devices d, metric2agent o, alert_type t',

      'where'=>'a.mname=m.name and a.id_device=d.id_dev and a.id_device=m.id_dev and m.type=\'xagent\' and m.id_metric=o.id_metric and t.id_alert_type=a.id_alert_type',
      },


);

#----------------------------------------------------------------------------
use constant IDLE  => 0;
use constant ACTIVE  => 1;
use constant TERMINATED  => 2;
use constant DONE  => 3;

my $MAX_TASK_ACTIVE_PER_CPU=2;
my $MAX_TASK_TIMEOUT=10;

#----------------------------------------------------------------------------
my %MAIL_DATA=(
   'Subject'=>'',
   'Body'=>''
);

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Notifications
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

	my $self=$class->SUPER::new(%arg);

   # Atributos globales -------------------------
   $self->{_lapse} = $arg{lapse} || 60;				# Intervalo de testeo para el envio de avisos
	$self->{_transport} = $arg{transport};
	$self->{_actions} = $arg{actions};

   # Atributos para envio de e-mails  -----------
   $self->{_mx} = $arg{mx} || 'localhost';			# MX para el envio de e-mails
   $self->{_from} = $arg{from} || '';				# Direccion de correo del remitente
   $self->{_from_name} = $arg{from_name} || '';	# Nombre del remitente
   $self->{_subject} = $arg{subject} || '';		# Asunto del correo

   # Atributos para envio de SMSs  -----------
   $self->{_serial_port} = $arg{serial_port} || '/dev/ttyS0';	# Puerto serie al que esta conectado el modem
   $self->{_pin} = $arg{pin} || '';				# PIN del terminal GSM

   $self->{_version1} = $arg{version1} || '3.23.54';
   $self->{_version2} = $arg{version2} || '1.0.40';
   $self->{_time_ref} = $arg{time_ref} || 0;

   return $self;

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
# mx
#----------------------------------------------------------------------------
sub mx {
my ($self,$mx) = @_;
   if (defined $mx) {
      $self->{_mx}=$mx;
   }
   else { return $self->{_mx}; }
}

#----------------------------------------------------------------------------
# from
#----------------------------------------------------------------------------
sub from {
my ($self,$from) = @_;
   if (defined $from) {
      $self->{_from}=$from;
   }
   else { return $self->{_from}; }
}

#----------------------------------------------------------------------------
# from_name
#----------------------------------------------------------------------------
sub from_name {
my ($self,$from_name) = @_;
   if (defined $from_name) {
      $self->{_from_name}=$from_name;
   }
   else { return $self->{_from_name}; }
}

#----------------------------------------------------------------------------
# subject
#----------------------------------------------------------------------------
sub subject {
my ($self,$subject) = @_;
   if (defined $subject) {
      $self->{_subject}=$subject;
   }
   else { return $self->{_subject}; }
}

#----------------------------------------------------------------------------
# transport
#----------------------------------------------------------------------------
sub transport {
my ($self,$transport) = @_;
   if (defined $transport) {
      $self->{_transport}=$transport;
   }
   else {
      return $self->{_transport};

   }
}

#----------------------------------------------------------------------------
# actions
#----------------------------------------------------------------------------
sub actions {
my ($self,$actions) = @_;
   if (defined $actions) {
      $self->{_actions}=$actions;
   }
   else { return $self->{_actions}; }
}

#----------------------------------------------------------------------------
# serial_port
#----------------------------------------------------------------------------
sub serial_port {
my ($self,$serial_port) = @_;
   if (defined $serial_port) {
      $self->{_serial_port}=$serial_port;
   }
   else { return $self->{_serial_port}; }
}

#----------------------------------------------------------------------------
# pin
#----------------------------------------------------------------------------
sub pin {
my ($self,$pin) = @_;
   if (defined $pin) {
      $self->{_pin}=$pin;
   }
   else { return $self->{_pin}; }
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
# check_cfgsign
#----------------------------------------------------------------------------
# Chequea posibles cambios de configuracion en /cfg/onm.conf
# 1. 	Lee todo el fichero de configuracion y calcula su MD5.
# 2. 	Lo compara con el que tenia almacenado de la iteracion anterior
# 3. 	En caso de que difieran, se relee el fichero de configuracion y el nuevo
#		MD5 se guarda para la siguiente iteracion.
# 4.	La recarga tambien se puede producir por mecanismos externos si existe
#		el fichero $file_reload (/var/www/html/onm/reload/notificationsd.reload)
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

	#----------------------------------------------------------------------------
	# En este caso ha habido cambio de configuracion
	#----------------------------------------------------------------------------
   my $transport=$self->transport();
   $transport->cfg($rcfgbase);
   $transport->init();

	my $LAPSE=$self->lapse();

	my $MX=$rcfgbase->{notif_mx}->[0];
	my $FROM=$rcfgbase->{notif_from}->[0];
	my $FROM_NAME=$rcfgbase->{notif_from_name}->[0];
	my $SUBJECT=$rcfgbase->{notif_subject}->[0];
	my $SERIAL_PORT=$rcfgbase->{notif_serial_port}->[0];
	my $PIN=$rcfgbase->{notif_pin}->[0];

	my $TOKEN = (exists $rcfgbase->{notif_tg_bot_token}->[0]) ? $rcfgbase->{notif_tg_bot_token}->[0] : '';
	#while (my ($k,$v)=each %$rcfgbase) { 		$self->log('info',"check_cfgsign_notif*:: $k --> @$v"); 	}

	$self->log('info',"check_cfgsign:: **CHANGED** LAPSE=$LAPSE|MX=$MX|FROM=$FROM|FROM_NAME=$FROM_NAME|SUBJECT=$SUBJECT|SERIAL_PORT=$SERIAL_PORT|PIN=$PIN|TOKEN=$TOKEN");

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

  	$self->start_flag(1);

	my $range=$self->range();
	my $lapse=$self->lapse();
	my $pid=$self->procreate('notificationsd',$range,$lapse);
   if ($pid == 0) {
		if ($range == TASK_NORMAL) {	$self->do_task($lapse,undef); }
		elsif ($range == TASK_NOTIFICATIONS) {	$self->do_task_notifications($lapse,undef); }
		elsif ($range == TASK_ANALYSIS) {	$self->do_task_analysis($lapse,undef); }
		elsif ($range == TASK_SEV4) {	$self->do_task_sev4($lapse,undef); }
		elsif ($range == TASK_MAIL) {	$self->do_task_mail($lapse,undef); }
	}
}


#----------------------------------------------------------------------------
# init_objects
#----------------------------------------------------------------------------
sub init_objects  {
my ($self)=@_;


   my $store=$self->create_store();
   my $spath=$self->store_path();
   my $rcfgbase=$self->cfg();
   my $dbh=$store->open_db();
   $self->dbh($dbh);
   $store->dbh($dbh);

	# Se actualiza el cid y cid_ip del objeto store para que por defecto disponga de
	# estos datos a la hora de insertar en ciertas tablas
	my $cid=$self->cid();
	$store->cid($cid);
	my $cid_ip=$self->cid_ip();
	$store->cid_ip($cid_ip);

   my $log_level=$self->log_level();
   $SNMP=Crawler::SNMP->new( store => $store, dbh => $dbh, store_path=>$spath, cfg=>$rcfgbase, log_level=>$log_level, mode_flag=>{rrd=>0, alert=>0} );
   $LATENCY=Crawler::Latency->new( store => $store, dbh => $dbh, store_path=>$spath, cfg=>$rcfgbase, log_level=>$log_level, mode_flag=>{rrd=>0, alert=>0} );
   $XAGENT=Crawler::Xagent->new( store => $store, dbh => $dbh, store_path=>$spath, cfg=>$rcfgbase, log_level=>$log_level, mode_flag=>{rrd=>0, alert=>0} );
   $WBEM=Crawler::Wbem->new( store => $store, dbh => $dbh, store_path=>$spath, cfg=>$rcfgbase, log_level=>$log_level, mode_flag=>{rrd=>0, alert=>0} );
	
   $CNMWS=Crawler::CNMWS->new( timeout=>4, log_level=>$log_level );

}

#----------------------------------------------------------------------------
# do_task_mail
#----------------------------------------------------------------------------
sub do_task_mail  {
my ($self,$lapse,$range)=@_;

   $self->log('info',"do_task::START [lapse=$lapse]");
   my $cid=$self->cid();
   my $cid_ip=$self->cid_ip();
   my $dbh=$self->dbh();

   $self->init_objects();

   my $cfg=$self->cfg();
   my $transport=Crawler::Transport->new('cfg'=>$cfg);
   $transport->init();
   $self->transport($transport);

	my $ok=1;
   my $RELOAD_FILE='/var/www/html/onm/tmp/mail_manager.reload';
	my $log_level=$self->log_level();
	my $email_manager=Crawler::LogManager::Email->new('log_level'=>$log_level, 'cid'=>$cid, cid_ip=>$cid_ip, 'reload_file'=>$RELOAD_FILE);

	$self->init_tmark();
	my $sanity_lapse = $Crawler::SANITY_LAPSE + int(rand(3600));

   while (1) {

      eval {

		   my $t=time;
			$self->sanity_check($t,$range,$sanity_lapse,'mail');
   		$self->time_ref($t);

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

				# ----------------------------------------------------------------------
   	      # Inicializa %WATCHES, @ALERTS_CLR, %TASKS =(), time_ref
      	   $self->init_vectors();

         	#----------------------------------------------------------------------------
	         # Se procesan las alertas/eventos por email
   	      #$self->mail_alert_processor();
	
				$email_manager->store($store);
				$email_manager->dbh($dbh);
				$email_manager->check_configuration();
				$email_manager->bulk_processor();
			}

	      # ----------------------------------------------------------------------
   	   # Gestion de tiempo
      	$self->idle_time();

      };

      if ($@) {
			my $kk=ref($dbh);
         $self->log('warning',"do_task::EXCEPTION (dbh=>$kk) $@");
         $self->idle_time();
      }
   }
}


#----------------------------------------------------------------------------
# do_task_notifications
#----------------------------------------------------------------------------
sub do_task_notifications  {
my ($self,$lapse,$range)=@_;

   my $ok=1;
   $self->log('info',"do_task::START [lapse=$lapse]");
	my $log_level=$self->log_level();
   $self->init_objects();
   my $dbh=$self->dbh();
   my $store=$self->store();
   ($dbh,$ok)=$self->chk_conex($dbh,$store,'alerts');

   my $hidx=$self->hidx();
   my $cid=$self->cid();
   my $cid_ip=$self->cid_ip();

   my $cfg=$self->cfg();
   my $transport=Crawler::Transport->new('cfg'=>$cfg, 'log_level'=>$log_level);
   $transport->init();
   $self->transport($transport);

   my $provision=ProvisionLite->new();
   $provision->init();

   #--------------------
   my $actions=Crawler::Actions->new('cfg'=>$cfg, 'log_level'=>$log_level, 'role'=>'cmd');
   $actions->provision($provision);
   $actions->store($store);
   $actions->dbh($dbh);

   my $xagent=Crawler::Xagent->new('cfg'=>$cfg, 'log_level'=>$log_level);
   my $p = $store->get_proxy_list($dbh);
   $xagent->proxies($p);
   $xagent->timeout(3600);
   $actions->xagent($xagent);

   $self->actions($actions);
   #--------------------

   $self->init_tmark();
	my $sanity_lapse = $Crawler::SANITY_LAPSE + int(rand(3600));

   while (1) {

      my $ts=time;
		$self->sanity_check($ts,$range,$sanity_lapse,'notifications');

      eval {

         $self->time_ref($ts);

         #----------------------------------------------------------------------
         # Se valida conexion a BBDD
         my $store=$self->store();
         ($dbh,$ok)=$self->chk_conex($dbh,$store,'alerts');

         # -----------------------------------------------------------------------
         # Si no hay link, no se ejecutan las tareas
         my $if=my_if();
         my $link_error=$self->check_if_link($if);
         if ($link_error > 0) {
            $self->log('warning',"do_task::[WARN] **NO LINK** (error=$link_error)");
         }

         if (($ok) && ($link_error <= 0)) {

   			#----------------------------------------------------------------------
			   # Chequeo si ha habido modificaciones en el fichero de configuracion global (/cfg/onm.conf)
			   # Si hay modificaciones se relee el fichero de configuracion. Tambien se puede forzar
   			# una relectura si existe el fichero $RELOAD_FILE.
   			# En este caso afecta la configuracion de envio de correos o de SMS.
   			$self->check_cfgsign($FILE_CONF,$RELOAD_FILE);

   			#----------------------------------------------------------------------
				# Respuesta a alertas.
            $self->manage_app_notifications($dbh);

         }

         # ----------------------------------------------------------------------
         # Gestion de tiempo
         $self->idle_time();

      };

      if ($@) {
         my $kk=ref($dbh);
         $self->log('warning',"do_task::EXCEPTION (dbh=>$kk) $@");
         $self->idle_time();
      }
   }

}



#----------------------------------------------------------------------------
# sanity_check
#----------------------------------------------------------------------------
sub sanity_check  {
my ($self,$ts,$range,$sanity_lapse,$mode)=@_;

   local $SIG{CHLD}='';

	my $rc=0;
	if (!defined $sanity_lapse) { $sanity_lapse=$Crawler::SANITY_LAPSE; }
	if (!defined $mode) { $mode='normal'; }

   my $ts0=$self->log_tmark();
   #if ($ts-$ts0>$Crawler::SANITY_LAPSE) {
   if ($ts-$ts0>$sanity_lapse) {
      $self->init_tmark();
		if ($mode eq 'mail') {
			$rc=system ("/opt/crawler/bin/mail_manager");
		}
		else {
			$rc=system ("/opt/crawler/bin/notificationsd -t $mode");
		}

      if ($rc==0) {
         $self->log('info',"do_task::[INFO] SANITY $mode ($rc)");
      }
      else {
         $self->log('warning',"do_task::**WARN** SANITY $mode ($rc) ($!)");
      }
      exit(0);
   }
}

##----------------------------------------------------------------------------
## set_mdata_mark
##----------------------------------------------------------------------------
#sub set_mdata_mark  {
#my ($self,$cid,$cid_ip)=@_;
#
#	my $file='/opt/data/mdata/notificationsd-'.$cid.'-'.$cid_ip.'.out';
#	open (F,">$file");
#	print F "DONE\n";
#	close F;
#}


#----------------------------------------------------------------------------
# do_task
#
#	INIT (chk_conex, init_vectors, chk_integrity)
#		||
#		\/
#	get_current_alerts (desde BBDD y desde file en mdata)
#		||	   __
#		\/	  | |
#	task_loop |	(bucle de ejecucion de chequeos)
#		||	  |_|
#		\/
#	alert_processor 	(Procesa los resultados obtenidos en %TASKS. Gestiona 
#		||					alguna severuidad, label, pone SET/CLR o PASS.
#		||					Gestiona la correlacion itra dispositivo e inter dispositivo)
#		\/
#	set_clear_alerts	(Se almacenan las alertas en alerts, se borran o
#		||					se pasan a alerts_store)
#		\/
#	vistas				(analize_views_ruleset, store_views_summary, store_alerts_read)
#		||
#		||
#		\/
#	avisos
#
#----------------------------------------------------------------------------
sub do_task  {
my ($self,$lapse,$range)=@_;

	my $ok=1;
   $self->log('info',"do_task::START [lapse=$lapse]");
	my $log_level=$self->log_level();
	$self->init_objects();
	my $dbh=$self->dbh();
	my $store=$self->store();
	($dbh,$ok)=$self->chk_conex($dbh,$store,'alerts');

	$SNMP->reset_mapping();

	my $last_sev4_check_time=0;

	my $hidx=$self->hidx();
	my $cid=$self->cid();
	my $cid_ip=$self->cid_ip();
	#my $CNMWS=Crawler::CNMWS->new( cid=>$cid, timeout=>3 );

   my $cfg=$self->cfg();
   my $transport=Crawler::Transport->new('cfg'=>$cfg, 'log_level'=>$log_level);
   $transport->init();
   $self->transport($transport);

   my $provision=ProvisionLite->new();
   $provision->init();

	#--------------------	
   my $actions=Crawler::Actions->new('cfg'=>$cfg, 'log_level'=>$log_level, 'role'=>'cmd');
   $actions->provision($provision);
   $actions->store($store);
   $actions->dbh($dbh);

   my $xagent=Crawler::Xagent->new('cfg'=>$cfg, 'log_level'=>$log_level);
   my $p = $store->get_proxy_list($dbh);
   $xagent->proxies($p);
   $xagent->timeout(3600);
	$actions->xagent($xagent);

	$self->actions($actions);
	#--------------------	

	$self->init_tmark();
	my $sanity_lapse = $Crawler::SANITY_LAPSE + int(rand(3600));

   while (1) {
		
      my $ts=time;
		$self->sanity_check($ts,$range,$sanity_lapse,'normal');

		eval {

   		$self->time_ref($ts);

			# Comprueba si es necesario un reload de syslog-ng para actualizar modificaciones
			$self->reload_syslog();

			#----------------------------------------------------------------------
			# Chequeo si ha habido modificaciones en el fichero de configuracion global (/cfg/onm.conf)
			# Si hay modificaciones se relee el fichero de configuracion. Tambien se puede forzar
			# una relectura si existe el fichero $RELOAD_FILE.
			# (Notar que en ese fichero se especifican parametros del envio de correos o de sms.)
			#$self->check_cfgsign($FILE_CONF,$RELOAD_FILE);

			#----------------------------------------------------------------------
			# Si $lapse es alto, lo mas probable es que se haya perdido la conexion a la BBDD.
			# Por eso fuerzo directamente una reconexion
			my $store=$self->store();


         my $kk=ref($dbh);
         my $kk1=ref($store);
         $self->log('info',"do_task::**FML** (dbh=>$kk) (store=>$kk1)");

			#if ($lapse > 600) {
			#	if (defined $dbh) { $store->close_db($dbh); }
			#	$dbh=$store->open_db(); $self->dbh($dbh); $store->dbh($dbh);
			#}
			
			($dbh,$ok)=$self->chk_conex($dbh,$store,'alerts');

	      # -----------------------------------------------------------------------
   	   # Si no hay link, no se ejecutan las tareas
			my $if=my_if();
      	my $link_error=$self->check_if_link($if);
	      if ($link_error > 0) {
   	      $self->log('warning',"do_task::[WARN] **NO LINK** (error=$link_error)");
      	}
			
			if (($ok) && ($link_error <= 0)) {


            # ----------------------------------------------------------------------
            # Si pertenece a algun dominio obtiene las alertas de los otros equipos del dominio
#				my $DOMAIN_LIST=$store->get_mcnm_domain_cids($dbh, {'cid'=>$cid, 'cid_ip'=>$cid_ip} );
#				my $cnm_stat=$store->get_mcnm_status($dbh, {'cid'=>$cid, 'cid_ip'=>$cid_ip} );
#				my @remote_msgs=();
#            foreach my $index (keys %$DOMAIN_LIST) {
#               my $remote_cid=$DOMAIN_LIST->{$index}->{'cid'};
#               my $remote_cid_ip=$DOMAIN_LIST->{$index}->{'host_ip'};
#					my $remote_hidx=$DOMAIN_LIST->{$index}->{'hidx'};
#					my $remote_mode=$DOMAIN_LIST->{$index}->{'mode'};
#
#               $self->log('info',"do_task::[INFO] MCNM cid=$cid cid_ip=$cid_ip remote_cid=$remote_cid remote_cid_ip=$remote_cid_ip remote_mode=$remote_mode");
#					if ($remote_mode=~/api/i) { next; }
#
#               my $rc = $CNMWS->ws_get_domain_data_from_remote($cid,$cid_ip,$remote_cid,$remote_cid_ip);
#
#					my $cnt = ($rc==0) ? -1 : $cnm_stat->{$index}->{'counter'}+1;
#
#               $self->log('info',"do_task::[INFO] MCNM remote_cid=$remote_cid remote_cid_ip=$remote_cid_ip STATUS=$rc tlast=$ts counter=$cnt");
#					$store->insert_to_db($dbh,'cnm_status',{'hidx'=>$remote_hidx, 'cid'=>$remote_cid, 'cid_ip'=>$remote_cid_ip, 'status'=>$rc, 'tlast'=>$ts, 'counter'=>$cnt });
#				
#					if ($rc>0) { 
#						push @remote_msgs,"$remote_cid_ip ($remote_cid - $remote_hidx) err=$rc";
#					}
#            }

				$store->insert_to_db($dbh,'cnm_status',{'hidx'=>$hidx, 'cid'=>$cid, 'cid_ip'=>$cid_ip, 'status'=>0, 'tlast'=>$ts });
				$store->delete_from_db($dbh,'cnm_status',"tlast<$ts");

				my $rc = $CNMWS->api_get_domain_data_from_remote('localhost');
				$self->log('info',"do_task::[INFO] MCNM API SYNC STATUS=$rc");

#				if (scalar(@remote_msgs)>0) {
				if ($rc != 0) {

#					my $msg = join(" ",@remote_msgs);
					my $msg = "Error al sicronizar datos en multi-cnm (rc=$rc)";
	            my $x = md5_hex("$msg");
   	         my $trap_key = substr $x,0,10;

               my $r=$SNMP->core_snmp_trap_ext(

                  {'comunity'=>'public', 'version'=>2, 'host_ip'=>$cid_ip, 'agent'=>$cid_ip },
                  {'enterprise'=>'CNM-NOTIFICATIONS-MIB::cnmNotifMCNMNoAccessToRemote', 'uptime'=>1234,
                     'vardata'=> [  [ 'cnmNotifCode', 1, 1 ],
                                    [ 'cnmNotifMsg', 2, $msg ],
												[ 'cnmNotifKey', 1, $trap_key ]  ]
                  }
               );
					$self->log('info',"do_task::[INFO] MCNM TRAP ($r) a $cid_ip MSG=$msg");
				}

				# ----------------------------------------------------------------------
   	      # Inicializa %WATCHES, @ALERTS_CLR, %TASKS =(), time_ref
      	   $self->init_vectors();
				my $dir_shared=$Crawler::MDATA_PATH.'/shared';
				$self->shared_clean($dir_shared);

				# ----------------------------------------------------------------------
				# GESTION DE ALERTAS DE SEVERIDAD != 4
			   #----------------------------------------------------------------------------
			   $self->chk_integrity($dbh);
		   	#----------------------------------------------------------------------------
			   # Se compone el vector de tareas %TASKS
			   $self->get_current_alerts();
			   #----------------------------------------------------------------------------
				my $num_cpus=$self->num_cpus();
				my $MAX_TASK_ACTIVE=$num_cpus*$MAX_TASK_ACTIVE_PER_CPU;
      		$self->task_loop($MAX_TASK_ACTIVE,$MAX_TASK_TIMEOUT);

			   #----------------------------------------------------------------------------
   			# Se procesan los resultados
			   $self->alert_processor();

		   	#----------------------------------------------------------------------------
	   		# Se procesan las alertas/eventos por email
				#$self->mail_alert_processor();

   			my $tdur=time - $self->time_ref();
   			$self->log('info',"do_task::[INFO] **RES** T=$tdur (num_cpus=$num_cpus)");

				# ----------------------------------------------------------------------
            # Se incluyen las alertas azules
           	my $tnow=time;
           	my $tdiff=$tnow-$last_sev4_check_time;
           	if ($tdiff>300) {

					my $bluetasks = $self->deserialize_tasks();
					#Debug
   				$self->serialize_data ( {'in'=>$bluetasks, 'format'=>'dumper', 'outpath'=>$dir_shared, 'outname'=>'AZULES_SOLO.pm'} );
					$self->log('info',"do_task:: MERGE AZULES");

					# Utilizo bucle para optimizar memoria
					#@TASKS{keys %$bluetasks} = values %$bluetasks;
					while ( my ($k,$v) = each(%$bluetasks) ) { 
						# Solo se incorporan azules si la metrica no tiene una alerta previa. En ese caso, se mantiene la alerta previa
						if (! exists $TASKS{$k}) { $TASKS{$k}=$v; }
					}

					#Debug
            	$self->serialize_data ( {'in'=>\%TASKS, 'format'=>'dumper', 'outpath'=>$dir_shared, 'outname'=>'AZULES_TOTAL.pm'} );

					$last_sev4_check_time=$tnow;
				}	

	   		# ----------------------------------------------------------------------
			   # CONSOLIDACION DE ALERTAS
   			($dbh,$ok)=$self->chk_conex($dbh,$store,'alerts');
		   	$self->set_clear_alerts();

   			# ----------------------------------------------------------------------
				# alerts -> cfg_views	
				my $VIEWS2ALERTS=$store->analize_views_ruleset($dbh,$cid,$cid_ip);
				# alerts -> alerts_read
				$store->store_alerts_read($dbh);
            # views -> graph
            $store->store_views_summary($dbh,$VIEWS2ALERTS);
				$self->set_gui_mark($cid,$cid_ip);	 
	   		# ----------------------------------------------------------------------
				
#				# ----------------------------------------------------------------------
#				# GESTION DE AVISOS Y APLICACIONES
#				#SELECT id_device,id_alert_type,cause,name,domain,ip,notif,id_alert,mname,watch,event_data,ack,id_ticket,severity,type,date,counter,id_metric FROM alerts WHERE counter>0 and cid='$cid'
#				$ALERTS_SET=$store->get_alerts_by_cid($dbh,$cid);
#
#				#Debug
#      		$self->serialize_data ( {'in'=>$ALERTS_SET, 'format'=>'dumper', 'outpath'=>$dir_shared, 'outname'=>'ALERTS_SET.pm'} );
#
#
#				# ----------------------------------------------------------------------
#				# GESTION DE AVISOS Y APLICACIONES
#				$self->manage_app_notifications($dbh);


			} # defined dbh

			# ----------------------------------------------------------------------
			# Gestion de tiempo
			$self->idle_time();

		};

		if ($@) {
			my $kk=ref($dbh);
			$self->log('warning',"do_task::EXCEPTION (dbh=>$kk) $@");
			$self->idle_time();
		}
	}
}


#----------------------------------------------------------------------------
# do_task_sev4
#----------------------------------------------------------------------------
sub do_task_sev4  {
my ($self,$lapse,$range)=@_;

	my $ok=1;
   $self->log('info',"do_task_sev4::START [lapse=$lapse]");
	my $log_level=$self->log_level();
   $self->init_objects();
	my $dbh=$self->dbh();
   my $store=$self->store();
   ($dbh,$ok)=$self->chk_conex($dbh,$store,'alerts');

   $SNMP->reset_mapping();

   my $hidx=$self->hidx();
   my $cid=$self->cid();
   my $cid_ip=$self->cid_ip();

   my $cfg=$self->cfg();
   my $transport=Crawler::Transport->new('cfg'=>$cfg, 'log_level'=>$log_level);
   $transport->init();
   $self->transport($transport);

   my $provision=ProvisionLite->new();
   $provision->init();

   #--------------------
   my $actions=Crawler::Actions->new('cfg'=>$cfg, 'log_level'=>$log_level, 'role'=>'cmd');
   $actions->provision($provision);
   $actions->store($store);
   $actions->dbh($dbh);

   my $xagent=Crawler::Xagent->new('cfg'=>$cfg, 'log_level'=>$log_level);
   my $p = $store->get_proxy_list($dbh);
   $xagent->proxies($p);
   $xagent->timeout(3600);
   $actions->xagent($xagent);

   $self->actions($actions);
   #--------------------

	$self->init_tmark();
   my $sanity_lapse = $Crawler::SANITY_LAPSE + int(rand(3600));

   while (1) {

      eval {

		   my $t=time;
			$self->sanity_check($t,$range,$sanity_lapse,'sev4');
			$self->time_ref($t);

         #----------------------------------------------------------------------
         # Chequeo si ha habido modificaciones en el fichero de configuracion global (/cfg/onm.conf)
         # Si hay modificaciones se relee el fichero de configuracion. Tambien se puede forzar
         # una relectura si existe el fichero $RELOAD_FILE.
         # (Notar que en ese fichero se especifican parametros del envio de correos o de sms.)
         #$self->check_cfgsign($FILE_CONF,$RELOAD_FILE);

         #----------------------------------------------------------------------
         # Si $lapse es alto, lo mas probable es que se haya perdido la conexion a la BBDD.
         # Por eso fuerzo directamente una reconexion
         $store=$self->store();

         my $kk=ref($dbh);
         my $kk1=ref($store);
         $self->log('warning',"do_task_sev4::**FML** (dbh=>$kk) (store=>$kk1)");


         if ($lapse > 600) {
				if (defined $dbh) { $store->close_db($dbh); }
				$dbh=$store->open_db(); $self->dbh($dbh); $store->dbh($dbh);
			}
         ($dbh,$ok)=$self->chk_conex($dbh,$store,'alerts');
			if ($ok) {
			
	         # ----------------------------------------------------------------------
   	      # Inicializa %WATCHES, @ALERTS_CLR, %TASKS =(), time_ref
      	   $self->init_vectors();

         	#----------------------------------------------------------------------------
	         # Se compone el vector de tareas %TASKS
   	      $self->get_current_alerts();

      	   #----------------------------------------------------------------------------
         	# Se ejecuran los chequeos (serie/paralelo)
	         $self->log('warning',"do_task_sev4::[****FML***] ===>> LAPSE=$lapse");
				$self->task_serialize();
      	   $self->alert_processor();

         	my $tdur=time - $self->time_ref();
	         $self->log('info',"do_task_sev4::[INFO] **RES** T=$tdur");

				$self->serialize_tasks();
   	      # ----------------------------------------------------------------------
      	   # CONSOLIDACION DE ALERTAS
#         	($dbh,$ok)=$self->chk_conex($dbh,$store,'alerts');
#	         $self->set_clear_alerts();
			}

  	      # ----------------------------------------------------------------------
     	   # Gestion de tiempo
        	$self->idle_time();
      };

      if ($@) {
			my $kk=ref($dbh);
         $self->log('warning',"do_task_sev4::EXCEPTION (dbh=>$kk) $@");
         $self->idle_time();
      }

   }

}


#----------------------------------------------------------------------------
# do_task_sev4_lite
#----------------------------------------------------------------------------
sub do_task_sev4_lite  {
my ($self,$dbh,$store)=@_;

	my $ok=1;
	if (defined $dbh) {

      # ----------------------------------------------------------------------
      # Inicializa %WATCHES, @ALERTS_CLR, %TASKS =(), time_ref
      $self->init_vectors();

      #----------------------------------------------------------------------------
      # Se compone el vector de tareas %TASKS
      $self->get_current_alerts();

      #----------------------------------------------------------------------------
      # Se ejecuran los chequeos (serie/paralelo)
      $self->task_serialize();
      $self->alert_processor();

      # ----------------------------------------------------------------------
      # CONSOLIDACION DE ALERTAS
      ($dbh,$ok)=$self->chk_conex($dbh,$store,'alerts');
      $self->set_clear_alerts();
   }
}




#----------------------------------------------------------------------------
# do_task_analysis
#----------------------------------------------------------------------------
sub do_task_analysis  {
my ($self,$lapse,$range)=@_;

	my $ok=1;
   $self->log('info',"do_task_analysis::START [lapse=$lapse]");
   $self->init_objects();
	my $dbh=$self->dbh();

   $SNMP->reset_mapping();

   $self->init_tmark();
   my $sanity_lapse = $Crawler::SANITY_LAPSE + int(rand(3600));

   while (1) {

      eval {

		   my $t=time;
			$self->sanity_check($t,$range,$sanity_lapse,'analysis');
   		$self->time_ref($t);

         #----------------------------------------------------------------------
         # Chequeo si ha habido modificaciones en el fichero de configuracion global (/cfg/onm.conf)
         # Si hay modificaciones se relee el fichero de configuracion. Tambien se puede forzar
         # una relectura si existe el fichero $RELOAD_FILE.
         # (Notar que en ese fichero se especifican parametros del envio de correos o de sms.)
         #$self->check_cfgsign($FILE_CONF,$RELOAD_FILE);

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

	         # ----------------------------------------------------------------------
   	      # Inicializa %WATCHES, @ALERTS_CLR, %TASKS =(), time_ref
      	   $self->init_vectors();

         	# ----------------------------------------------------------------------
	         # GESTION DE ALERTAS de ANALISIS
   			$self->init_alerts_fifo();
   			$self->get_analysis_alerts_configured();
   			$self->task_serialize();
	   		$self->alert_processor();
   			$self->set_clear_alerts();
			   $self->store_alerts_fifo();

			}

         # ----------------------------------------------------------------------
         # Gestion de tiempo
         $self->idle_time();
      };

      if ($@) {
			my $kk=ref($dbh);
         $self->log('warning',"do_task_analysis::EXCEPTION (dbh=>$kk) $@");
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
	my $wait = ($self->time_ref() + $self->lapse()) - time;
   if ($wait < 0) {  
		$self->log('warning',"do_task::[WARN] *S* [WAIT=$wait|SET=$SET|CLR=$CLR|CLR0=$CLR0|SKIP=$SKIP|AVISOS=$AVISOS]");   
		sleep 5; 
	}
   else {
      $self->log('info',"do_task::[INFO] -W- [WAIT=$wait|SET=$SET|CLR=$CLR|CLR0=$CLR0|SKIP=$SKIP|AVISOS=$AVISOS]");
      sleep $wait;
   }

   #----------------------------------------------------
   if ($Crawler::TERMINATE == 1) {
      $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
      exit 0;
   }

}

#----------------------------------------------------------------------------
sub serialize_tasks {
my ($self)=@_;

	my $dir_shared=$Crawler::MDATA_PATH.'/shared';
	$self->serialize_data ( {'in'=>\%TASKS, 'format'=>'json', 'outpath'=>$dir_shared, 'outname'=>'SEV4.json'} );
}

#----------------------------------------------------------------------------
sub deserialize_tasks {
my ($self)=@_;

   my $dir_shared=$Crawler::MDATA_PATH.'/shared';
   my $data = $self->deserialize_data ( {'format'=>'json', 'inpath'=>$dir_shared, 'inname'=>'SEV4.json'} );
	return $data;
}
#----------------------------------------------------------------------------
# serialize_data
# Almacena una estructura pm con la info resultado de %TASKS. 
# Permite serializar las alertas.
# format:	Formato del fichero de salida
# in:			Vector de datos de entrada (hash o array)
# outpath:	Path de salida
# outname:	Nombre del fichero de salida
#----------------------------------------------------------------------------
sub serialize_data {
my ($self,$params)=@_;

	if (! exists $params->{'in'}) {
		$self->log('warning',"serialize_data:: **ERROR** No hay estructura para serializar");
		return;
	}
	my $in = $params->{'in'};
	my $format = (exists $params->{'format'}) ? $params->{'format'} : 'dumper';
	my $outpath = (exists $params->{'outpath'}) ? $params->{'outpath'} : '/tmp';
	my $outname= (exists $params->{'outname'}) ? $params->{'outname'} : 'unk';

#   my $dir_shared=$Crawler::MDATA_PATH.'/shared';
#   if (! -d $dir_shared) { mkdir $dir_shared; }
#   my $filepm=$dir_shared.'/'.$outname;

	my $filepm = $outpath.'/'.$outname;

	my $outdata='';
	if ($format eq 'json') { $outdata = encode_json($in);}
	else { $outdata = Dumper($in); }

#   my $pm=Dumper(\%TASKS);
   my $rc=open (F,">$filepm");
   if ($rc) {
      $self->log('info',"serialize_data::GENERO FICHERO $filepm");
      print F $outdata;
      close F;
   }
}


#----------------------------------------------------------------------------
# inpath:  	Path del fichero a deserializar
# inname:  	Nombre del fichero a deserializar
# Devuelve referencia al vector de datos.
#----------------------------------------------------------------------------
sub deserialize_data {
my ($self,$params)=@_;

	my $out = {};
   my $inpath = (exists $params->{'inpath'}) ? $params->{'inpath'} : '/tmp';
   my $inname = (exists $params->{'inname'}) ? $params->{'inname'} : 'unk';
	# Solo se puede deserializar json
	# Dumper no por seguridad
	my $format='json';

	my $filein = $inpath.'/'.$inname;
   if (! -f $filein) {
      $self->log('warning',"deserialize_data:: **ERROR** No existe el fichero $filein para serializar");
      return $out;
   }

   open (F,"<$filein");
   my $indata=<F>;
   close F;
   eval { $out = decode_json($indata); };
	if ($@) {
      $self->log('warning',"deserialize_data:: **ERROR** en decode_json ($@)");
   }
   return $out;


}

#----------------------------------------------------------------------------
# manage_app_notifications 
# Gestiona los posibles avisos o aplicaciones asociadas a las alertas producidas
#----------------------------------------------------------------------------
sub manage_app_notifications {
my ($self,$dbh)=@_;

	my @ID_TASKS=();
	my $store=$self->store();
	my $ts = $self->time_ref();

   my $cid = $self->cid();
   my $notif_dir = "$Crawler::MDATA_PATH/output/$cid/notif";
   if (! -d $notif_dir) { mkdir $notif_dir; }

	# $CFG_POST contiene los avisos y aplicaciones definidas
	my $CFG_POST=$store->get_cfg_post_alert($dbh);

	my ($naviso,$napp,$nrun)=(0,0,0);
	foreach my $id (sort keys %$CFG_POST) {
		if ( exists $CFG_POST->{$id}->{'aviso'}) { 
			$naviso+=1; 
			$self->log('debug',"manage_app_notifications:: aviso $CFG_POST->{$id}->{'nname'} >> $CFG_POST->{$id}->{'dest'}  id_dev=$CFG_POST->{$id}->{'id_dev'} monitor=$CFG_POST->{$id}->{'monitor'}");
		}
		elsif ( exists $CFG_POST->{$id}->{'app'}) { 
			$napp+=1; 
			$self->log('debug',"manage_app_notifications:: app_bg $CFG_POST->{$id}->{'nname'} >> $CFG_POST->{$id}->{'name'} id_dev=$CFG_POST->{$id}->{'id_dev'} monitor=$CFG_POST->{$id}->{'monitor'}");
		}
		elsif ( exists $CFG_POST->{$id}->{'run'}) { 
			$nrun+=1; 
			$self->log('debug',"manage_app_notifications:: app_run $CFG_POST->{$id}->{'nname'} >> $CFG_POST->{$id}->{'script'} id_dev=$CFG_POST->{$id}->{'id_dev'} monitor=$CFG_POST->{$id}->{'monitor'}");
		}
	}
	$self->log('info',"manage_app_notifications:: CHECK >> avisos=$naviso apps_bg=$napp apps_run=$nrun");


	# Se obtienen los monitores que tienen diferentes severidades
	# EJ: 's_esp_cpu_avg_mibhost-174e4020' => 'v1>85:v1>75:' (critical:major:minor)
	my $WATCH_MULTI = $store->get_cfg_watch_multi_severity($dbh);

	#----------------------------------------------------------------------------
   # SET 
	#----------------------------------------------------------------------------
   my $notif_alerts_set=$store->get_notif_alerts_set($dbh);
   foreach my $a (@$notif_alerts_set) {

#id_device,id_alert_type,cause,name,domain,ip,notif,id_alert,mname,watch,event_data, ack,id_ticket,severity,type,date,counter,id_metric

		if ($a->[aNOTIF] == NOTIF_LAST) { next; }
		my $id_alert=$a->[aID_ALERT];
		my $id_dev_alert=$a->[aDEVICE];
		my $ip_alert=$a->[aALERT_DEV_IP];

		my %myENV=();
	   $myENV{'CNM_ALERT_DEVICE_NAME'} = $a->[aALERT_DEV_NAME];
	   $myENV{'CNM_ALERT_DEVICE_DOMAIN'} = $a->[aALERT_DEV_DOMAIN];
	   $myENV{'CNM_ALERT_DEVICE_IP'} = $ip_alert;
	   $myENV{'CNM_ALERT_DEVICE_ID'} = $id_dev_alert;
   	$myENV{'CNM_ALERT_CAUSE'} = $a->[aALERT_CAUSE];
   	$myENV{'CNM_ALERT_EVENT'} = $a->[aEVENT_DATA] || '';
   	$myENV{'CNM_ALERT_ID'} = $id_alert;
   	$myENV{'CNM_ALERT_ACK'} = $a->[aACK];
   	$myENV{'CNM_ALERT_ID_TICKET'} = $a->[aID_TICKET];
   	$myENV{'CNM_ALERT_SEVERITY'} = $a->[aSEVERITY];
   	$myENV{'CNM_ALERT_DATE'} = $a->[aDATE];
   	$myENV{'CNM_ALERT_ID_METRIC'} = $a->[aID_METRIC];


      foreach my $id (sort keys %$CFG_POST) {

         # Si el aviso esta asociado a la metrica de DISPONIBILIDAD ICMP, el monitor (subtype en tcp/ip) debe ser
         # mon_icmp que es el valor que aparece en la alerta
         if ($CFG_POST->{$id}->{'monitor'} eq 'disp_icmp') { $CFG_POST->{$id}->{'monitor'}='mon_icmp'; }

			my ($id_dev,$id_alert_type,$monitor,$severity) = 
				($CFG_POST->{$id}->{'id_dev'}, $CFG_POST->{$id}->{'id_alert_type'}, $CFG_POST->{$id}->{'monitor'},$CFG_POST->{$id}->{'severity'});

			my $do_cause=0;
			if (! $self->is_watch($a,$id_dev,$id_alert_type,$monitor,$WATCH_MULTI,$severity)) {
				if (! $self->is_latency($a,$id_dev,$monitor)) {
					if (! $self->is_remote($a,$id_dev,$monitor)) { 	next; }
					else { $do_cause=3; }
				}
				else { $do_cause=2; }
			}
			else { $do_cause=1; }

			# SI WSIZE>0 ==> HAY DEFINIDA VENTANA DE GUARDA
			if ($CFG_POST->{$id}->{'wsize'}>0) {
				my $delta=$ts-$a->[aDATE];
			 	$self->set_wsize_mark($id,$a->[aDATE]);
			
				if ($delta < $CFG_POST->{$id}->{'wsize'}) {
					$self->log('info',"manage_app_notifications [$id] +++SET WAIT WSIZE+++ ts=$ts alarm_date=$a->[aDATE] delta=$delta wsize=$CFG_POST->{$id}->{'wsize'}");
					next;
				}
			}

			$self->log('info',"manage_app_notifications [$id] do_cause=$do_cause ($id_dev|$id_dev_alert|$id_alert_type|$monitor) ------------");

			# SE GENERA AVISO PARA SET --------------------------------------
			if ( exists $CFG_POST->{$id}->{'aviso'}) { 


				# Si es un monitor de multiples severidades y se ha enviado aviso de una severidad, no se envian mas avisos hasta que se borre
				#my $algun_flag_para_esto=1;
				if (($do_cause==1) && (exists $WATCH_MULTI->{$monitor}) && ($WATCH_MULTI->{$monitor}->{'type_mwatch'}==1)) {
				#if (($do_cause==1) && ($algun_flag_para_esto)) {
				#	if (exists $WATCH_MULTI->{$monitor}) {

						my $idw = 'mwatch-'.$id_dev.'-'.$monitor;
						my $file_watch = "$notif_dir/$idw";
						my $dests = $self->get_mwatch_mark($notif_dir,$idw);
						my $dest = $CFG_POST->{$id}->{'dest'};
						if (exists $dests->{$dest}) { 
							$self->log('info',"manage_app_notifications [$idw] **SALTO AVISO**** (ENVIADO CON OTRA SEVERIDAD A $dest) $file_watch");
							next;
						}
						else {
							$self->set_mwatch_mark($notif_dir,$idw,$id,$dest);
						}
					#}
				}
				#-----------------------------------------------------



            # Si hay CLR asociado registro marca de control
            if ($CFG_POST->{$id}->{'type'}==1) { $self->set_app_notif_mark($notif_dir,$id); }

				$self->log('info',"manage_app_notifications [$id] ($id_dev|$id_dev_alert):: ****AVISO**** (SET)");

# rc = -1 	EN CURSO
# rc = 0 	OK
# rc = >0 	ERROR 
# else(<-1)	DESCONOCIDO

            my %response=( 'id_alert'=>$id_alert,  'type'=>'1',
                           'descr'=>'',
                           'rc'=>0, 'rcstr'=>'',
                           'info'=>''   );
			
	         $self->set_aviso($dbh,$a,$CFG_POST->{$id},'set',\%response);
				$response{'date'} = time();

         	$store->store_alert2response($dbh, \%response);

			}
	
			# SE EJECUTA APP COMO TAREA PARA SET -----------------------------				
			if ( exists $CFG_POST->{$id}->{'app'}) {

            # Si hay CLR asociado registro marca de control
            if ($CFG_POST->{$id}->{'type'}==1) { $self->set_app_notif_mark($notif_dir,$id); }

	         my ($aname,$name)=($CFG_POST->{$id}->{'aname'},$CFG_POST->{$id}->{'name'});
				$self->log('info',"manage_app_notifications [$id] ($id_dev|$id_dev_alert):: ****APP-TASK**** (SET) aname=$aname name=$name");
				# Se almacena en cfg_task_configured 
   	      my $id_task = $store->store_cfg_task_configured($dbh,$aname,$name,$id_dev_alert,$ip_alert);
				push @ID_TASKS, {'id_task'=>$id_task, 'id_alert'=>$id_alert};
			}

			# SE EJECUTA APP INMEDIATAMENTE PARA SET --------------------------				
			elsif ( exists $CFG_POST->{$id}->{'run'}) {

            # Si hay CLR asociado registro marca de control
            if ($CFG_POST->{$id}->{'type'}==1) { $self->set_app_notif_mark($notif_dir,$id); }

            #Solo proxy localhost.
            my $id_proxy=1;

				my $file_script=$XAGENT->script_dir().'/'.$CFG_POST->{$id}->{'script'};
			   if (! -f $file_script) {
  	    			$store->script2file($dbh,$CFG_POST->{$id}->{'script'});
   			}

				my $timeout = $CFG_POST->{$id}->{'timeout'};
				# OJO con los parametros del script
				# Si tiene parametro de tipo IP se utiliza la IP de la alerta
				# Si usa credenciales utiliza tambien las asociadas a la IP de la alerta
				# Esto debe tener sentido con lo que haga el script.
				my $params = $XAGENT->_compose_params($CFG_POST->{$id}->{'params'},$ip_alert);
				$self->log('info',"manage_app_notifications [$id] ($id_dev|$id_dev_alert):: ****APP-RUN**** (SET) $file_script $params (timeout=$timeout)");

				$XAGENT->exec_vector({'file_script'=>$file_script, 'params'=>$params, 'timeout'=>$timeout});
				my $rc=$XAGENT->get_proxy_credentials($id_proxy);
				my $out_cmd=$XAGENT->execScript(\%myENV);

#$rcstr=$pagent->err_str();
#$rc=$pagent->err_num();
			}

			$store->update_alerts($dbh, {'id_alert'=>$id_alert, 'notif'=>NOTIF_LAST});
      }
	}
	    
	#----------------------------------------------------------------------------
  	# CLR
	#----------------------------------------------------------------------------
	my $notif_alerts_clr=$store->get_notif_alerts_clear($dbh);

   foreach my $a (@$notif_alerts_clr) {

      my $id_alert=$a->[aID_ALERT];
      my $id_dev_alert=$a->[aDEVICE];
      my $ip_alert=$a->[aALERT_DEV_IP];

      if ($a->[aNOTIF] == NOTIF_LAST_CLR) { next; }

      my %myENV=();
      $myENV{'CNM_ALERT_DEVICE_NAME'} = $a->[aALERT_DEV_NAME];
      $myENV{'CNM_ALERT_DEVICE_DOMAIN'} = $a->[aALERT_DEV_DOMAIN];
      $myENV{'CNM_ALERT_DEVICE_IP'} = $ip_alert;
      $myENV{'CNM_ALERT_DEVICE_ID'} = $id_dev_alert;
      $myENV{'CNM_ALERT_CAUSE'} = $a->[aALERT_CAUSE];
      $myENV{'CNM_ALERT_EVENT'} = $a->[aEVENT_DATA] || '';
      $myENV{'CNM_ALERT_ID'} = $id_alert;
      $myENV{'CNM_ALERT_ACK'} = $a->[aACK];
      $myENV{'CNM_ALERT_ID_TICKET'} = $a->[aID_TICKET];
      $myENV{'CNM_ALERT_SEVERITY'} = $a->[aSEVERITY];
      $myENV{'CNM_ALERT_DATE'} = $a->[aDATE];
      $myENV{'CNM_ALERT_ID_METRIC'} = $a->[aID_METRIC];


      foreach my $id (sort keys %$CFG_POST) {

			# Salto los avisos y aplicaciones solo de SET
			if ($CFG_POST->{$id}->{'type'}==0) { next; }

         # Si el aviso esta asociado a la metrica de DISPONIBILIDAD ICMP, el monitor (subtype en tcp/ip) debe ser
         # mon_icmp que es el valor que aparece en la alerta
         if ($CFG_POST->{$id}->{'monitor'} eq 'disp_icmp') { $CFG_POST->{$id}->{'monitor'}='mon_icmp'; }

         my ($id_dev,$id_alert_type,$monitor,$severity) =
            ($CFG_POST->{$id}->{'id_dev'}, $CFG_POST->{$id}->{'id_alert_type'}, $CFG_POST->{$id}->{'monitor'},$CFG_POST->{$id}->{'severity'});

         my $do_cause=0;
         if (! $self->is_watch($a,$id_dev,$id_alert_type,$monitor,$WATCH_MULTI,$severity)) {
            if (! $self->is_latency($a,$id_dev,$monitor)) {
               if (! $self->is_remote($a,$id_dev,$monitor)) {  next; }
               else { $do_cause=3; }
            }
            else { $do_cause=2; }
         }
         else { $do_cause=1; }

         # SI WSIZE>0 ==> HAY DEFINIDA VENTANA DE GUARDA
         if ($CFG_POST->{$id}->{'wsize'}>0) {
            my $ts_alert = $self->get_wsize_mark($id);
            my $delta=$ts-$ts_alert;

				$self->clear_wsize_mark($id);
            if ($delta < $CFG_POST->{$id}->{'wsize'}) {
               $self->log('info',"manage_app_notifications [$id] +++CLR WAIT WSIZE+++ ts=$ts alarm_date=$a->[aDATE] delta=$delta wsize=$CFG_POST->{$id}->{'wsize'}");
               next;
            }
         }

			# SE GENERA AVISO PARA CLR --------------------------------------
			if ( exists $CFG_POST->{$id}->{'aviso'}) {

            # Solo se manda el CLR si se ha enviado el SET
				my $file_set = "$notif_dir/$id";
            if (! -f $file_set) { 
					$self->log('info',"manage_app_notifications [$id] do_cause=$do_cause ($id_dev|$id_dev_alert):: ****AVISO**** (NO SE MANDA CLR) NO EXISTE $file_set");
					next; 
				}
            unlink $file_set;

				$self->log('info',"manage_app_notifications [$id] do_cause=$do_cause ($id_dev|$id_dev_alert):: ****AVISO**** (CLR)");

            my %response=( 'id_alert'=>$id_alert,  'type'=>'1',
                           'descr'=>'',
                           'rc'=>0, 'rcstr'=>'',
                           'info'=>''   );

	         $self->set_aviso($dbh,$a,$CFG_POST->{$id},'clr', \%response);
				$response{'date'} = time();

            $store->store_alert2response($dbh, \%response);
			}

			# SE EJECUTA APP PARA CLR --------------------------------------
         if ( exists $CFG_POST->{$id}->{'app'}) {

            # Solo ejecuto en CLR si se ha enviado el SET
            my $file_set = "$notif_dir/$id";
            if (! -f $file_set) {
               $self->log('info',"manage_app_notifications [$id] do_cause=$do_cause ($id_dev|$id_dev_alert):: ****APP-TASK**** (NO SE MANDA CLR) NO EXISTE $file_set");
               next;
            }
            unlink $file_set;

	         my ($aname,$name)=($CFG_POST->{$id}->{'aname'},$CFG_POST->{$id}->{'name'});
				$self->log('info',"manage_app_notifications [$id] do_cause=$do_cause ($id_dev|$id_dev_alert):: ****APP-TASK**** (CLR) aname=$aname name=$name");

            my $id_task = $store->store_cfg_task_configured($dbh,$aname,$name,$id_dev_alert,$ip_alert);
				push @ID_TASKS, {'id_task'=>$id_task, 'id_alert'=>$id_alert};
			}


			# SE EJECUTA APP INMEDIATAMENTE PARA CLR --------------------------				
         elsif ( exists $CFG_POST->{$id}->{'run'}) {

            # Solo ejecuto en CLR si se ha enviado el SET
            my $file_set = "$notif_dir/$id";
            if (! -f $file_set) {
               $self->log('info',"manage_app_notifications [$id] do_cause=$do_cause ($id_dev|$id_dev_alert):: ****APP-RUN**** (NO SE MANDA CLR) NO EXISTE $file_set");
               next;
            }
            unlink $file_set;


            #Solo proxy localhost.
            my $id_proxy=1;

            my $file_script=$XAGENT->script_dir().'/'.$CFG_POST->{$id}->{'script'};
            if (! -f $file_script) {
               $store->script2file($dbh,$CFG_POST->{$id}->{'script'});
            }

            my $timeout = $CFG_POST->{$id}->{'timeout'};
            # OJO con los parametros del script
            # Si tiene parametro de tipo IP se utiliza la IP de la alerta
            # Si usa credenciales utiliza tambien las asociadas a la IP de la alerta
            # Esto debe tener sentido con lo que haga el script.
				my $params = $XAGENT->_compose_params($CFG_POST->{$id}->{'params'},'noip');
            $self->log('info',"manage_app_notifications [$id] ($id_dev|$id_dev_alert):: ****APP-RUN**** (CLR) $file_script $params (timeout=$timeout)");

            $XAGENT->exec_vector({'file_script'=>$file_script, 'params'=>$params});
            my $rc=$XAGENT->get_proxy_credentials($id_proxy);
            my $out_cmd=$XAGENT->execScript();
         }

			$store->update_alerts($dbh, {id_alert=>$id_alert, notif=>NOTIF_LAST_CLR});
      }
   }

	my $actions = $self->actions();
  	$actions->register_devices($dbh);

	foreach my $x (@ID_TASKS) {

		my $id_task = $x->{'id_task'};
		my $id_alert = $x->{'id_alert'};
   	$actions->task2action($dbh,$id_task);
   	my $res=$actions->actions_manager($dbh);
		$self->log('info',"manage_app_notifications:: EJECUTADA id_task=$id_task res=$res ");

      my %response=( 'id_alert'=>$id_alert,  'type'=>'2',
                   	'descr'=>'',
                     'rc'=>0, 'rcstr'=>'',
                     'info'=>''   );
	
		$response{'info'} = $actions->url_info();	
		$response{'descr'} = $actions->action_descr();	
		$response{'date'} = time();
      $store->store_alert2response($dbh, \%response);
	}

}

#----------------------------------------------------------------------------
# set_mwatch_mark
# idwatch tiene el formato: 'mwatch-'.$id_dev.'-'.$monitor
#----------------------------------------------------------------------------
sub set_mwatch_mark {
my ($self,$notif_dir,$idwatch,$idnotif,$dest)=@_;

	my $dests = $self->get_mwatch_mark($notif_dir,$idwatch);
	if (exists $dests->{$dest}) { return; }

   open M,'>',"$notif_dir/$idwatch"; 
	foreach my $dest (sort keys %$dests) {
		print M join(';',$dest,$dests->{$dest}),"\n";
	}
	print M join(';',$dest,$idnotif),"\n";
   close M;
   $self->log('info',"manage_app_notifications [$idwatch] SET MARK FOR CLR ($notif_dir/$idwatch) $dest >> $idnotif");

}

#----------------------------------------------------------------------------
# get_mwatch_mark
# idwatch tiene el formato: 'mwatch-'.$id_dev.'-'.$monitor
# El contenido del fichero es del tipo:
# cnmsupport@s30labs.com;100-14-cnmsupport@s30labs.com;cnmsupport@s30labs.com
# info@s30labs.com;100-14-imo@areas.com;info@s30labs.com
#----------------------------------------------------------------------------
sub get_mwatch_mark {
my ($self,$notif_dir,$idwatch)=@_;

   my %dests=();
   my $file_watch="$notif_dir/$idwatch";
   if (-f $file_watch) {
      #Leo el fichero para ver el aviso concreto
      open (F,"<$file_watch");
      while (<F>) {
         chomp;
         my ($dest,$idf)=split(';',$_);
         $dests{$dest}=$idf;
      }
      close F;
   }
   return \%dests;
}

#----------------------------------------------------------------------------
# set_app_notif_mark
#----------------------------------------------------------------------------
sub set_app_notif_mark {
my ($self,$notif_dir,$id)=@_;

   open M,'>>',"$notif_dir/$id"; #Equivale a `touch $notif_dir/$id`;
   close M;
   $self->log('info',"manage_app_notifications [$id] SET MARK FOR CLR ($notif_dir/$id)");

}

#----------------------------------------------------------------------------
# set_wsize_mark
#----------------------------------------------------------------------------
sub set_wsize_mark {
my ($self,$id,$ts)=@_;

   my $dir_wmark = $Crawler::MDATA_PATH.'/wsize';
   if (! -d $dir_wmark) { mkdir $dir_wmark; }
	my $wfile = $dir_wmark.'/'.$id;
	open (F,">$wfile");
	print F $ts;
	close F;

}

#----------------------------------------------------------------------------
# get_wsize_mark
#----------------------------------------------------------------------------
sub get_wsize_mark {
my ($self,$id)=@_;

   my $dir_wmark = $Crawler::MDATA_PATH.'/wsize';
   if (! -d $dir_wmark) { mkdir $dir_wmark; }
   my $wfile = $dir_wmark.'/'.$id;
   open (F,"<$wfile");
   my $ts = <F>;
   close F;
	chomp $ts;
	return $ts;

}

#----------------------------------------------------------------------------
# clear_wsize_mark
#----------------------------------------------------------------------------
sub clear_wsize_mark {
my ($self,$id)=@_;

   my $dir_wmark = $Crawler::MDATA_PATH.'/wsize';
   my $wfile = $dir_wmark.'/'.$id;
	if (-f $wfile) { unlink $wfile; }

}



#----------------------------------------------------------------------------
# init_alerts_fifo
# Inicializa la FIFO de alertas (tabla alerts_fifo) en el vector %ALERTS_FIFO
# necesario para las alertas que guardan estado (analysis)
#----------------------------------------------------------------------------
sub init_alerts_fifo {
my ($self)=@_;

	my $store = $self->store();
	my $dbh = $self->dbh();

   my $afifo=$store->get_from_db( $dbh,
      'id_dev,mname,ts,value,value_name,mode,watch,watch_eval',
         'alerts_fifo',
         '',
         'order by ts'
   );

   my $e=$store->error();
   if ($e) { $e .= $store->errorstr().'  ('.$store->lastcmd().' )'; }
   $self->log('debug',"init_alerts_fifo::[DEBUG] get from alerts_fifo RESP=$e");

   %ALERTS_FIFO=();
   # 'id_dev.mname' => [ {}, {}, .... {}]
   foreach my $a (@$afifo) {
      #my $k = $a->[0].'.'.$a->[1].'.'.$a->[2];
      my $k = $a->[0].'.'.$a->[1];
      push @{$ALERTS_FIFO{$k}}, { 'id_dev'=>$a->[0], 'mname'=>$a->[1], 'ts'=>$a->[2], 'value'=>$a->[3], 'value_name'=>$a->[4], 'mode'=>$a->[5], 'watch'=>$a->[6], 'watch_eval'=>$a->[7] };
   }
}

#----------------------------------------------------------------------------
# init_vectors
# Inicializa los vectores necesarios para el procesado de las tareas
# 1. Vector de WATCHES definidos (Mejora la eficiencia)
# 2. @ALERTS_CLR, %TASKS
# 3. Cache SNMP y WBEM.
# 4. check_cfgsign
# 5. $SET,$CLR,$CLR0,$SKIP
# 6. time_ref
# 7. Reglas de correlacion interna (%DEV2IRULE, $IRULES)
#----------------------------------------------------------------------------
sub init_vectors {
my ($self)=@_;

   #----------------------------------------------------------------------
   # Chequeo si ha habido modificaciones en el fichero de configuracion global (/cfg/onm.conf)
   # Si hay modificaciones se relee el fichero de configuracion. Tambien se puede forzar
   # una relectura si existe el fichero $RELOAD_FILE.
   # (Notar que en ese fichero se especifican parametros del envio de correos o de sms.)
   $self->check_cfgsign($FILE_CONF,$RELOAD_FILE);
	
   #----------------------------------------------------------------------
   # Se inicializa el cache de las metricas SNMP y WBEM
   $SNMP->clear_cache();
   $WBEM->clear_cache();
   $XAGENT->clear_cache();

   #----------------------------------------------------------------------
#  	my $t=time;
#   $self->time_ref($t);
	($SET,$CLR,$CLR0,$SKIP,$AVISOS)=(0,0,0,0,0);

   #----------------------------------------------------------------------
	@ALERTS_CLR = ();
	%TASKS = ();
   #----------------------------------------------------------------------
   my $store = $self->store();
   my $dbh = $self->dbh();

	$XAGENT->store($store);
	$XAGENT->dbh($dbh);

   #----------------------------------------------------------------------
   my $atypes=$store->get_from_db( $dbh, 'monitor,expr,severity,wsize', 'alert_type', '', '' );
   %WATCHES = map { $_->[0] => [$_->[1], $_->[2], $_->[3]] } @$atypes;

   #----------------------------------------------------------------------
   my $emails=$store->get_from_db( $dbh, 'email,name,domain,ip', 'devices', 'email != ""', '' );
   %EMAIL2DEV = map { $_->[0] => [$_->[1], $_->[2], $_->[3]] } @$emails;

   #----------------------------------------------------------------------
   my $dev_data=$store->get_from_db( $dbh, 'id_dev,rule_subtype,wsize', 'devices', '', '' );
   %DEV2IRULE = map { $_->[0] => $_->[1] } @$dev_data;
   %DEV2WSIZE = map { $_->[0] => $_->[2] } @$dev_data;
   $IRULES=$store->get_inside_correlation_rules($dbh);

	#----------------------------------------------------------------------
	my $transport=$self->transport();
	my $cfg=$self->cfg();
	$transport->cfg($cfg);
	$transport->init();

}


#----------------------------------------------------------------------------
# store_alerts_fifo
# Inicializa la FIFO de alertas (tabla alerts_fifo) en el vector %ALERTS_FIFO
# necesario para las alertas que guardan estado (analysis)
#----------------------------------------------------------------------------
sub store_alerts_fifo {
my ($self)=@_;

   my $store = $self->store();
   my $dbh = $self->dbh();

   #----------------------------------------------------------------------------
   # store alerts_fifo
   $store->delete_from_db( $dbh, 'alerts_fifo', '');
   my $e=$store->error();
   if ($e) { $e .= $store->errorstr().'  ('.$store->lastcmd().' )'; }
   $self->log('debug',"store_alerts_fifo::[DEBUG] delete from alerts_fifo RESP=$e");

   foreach my $k (keys %ALERTS_FIFO) {
      foreach my $i ( @{$ALERTS_FIFO{$k}} ) {
         $store->insert_to_db( $dbh, 'alerts_fifo', $i);
      }
   }
}


#----------------------------------------------------------------------------
# set_clear_alerts
# Almacena en BBDD los resultados de la gestion de alertas.
# mode = 0 >> Inserta la alerta
# mode = 1 >> Actualiza la alerta (update)
# mode = 2 >> Actualiza alerta (insert-update). Concatena event_data
#----------------------------------------------------------------------------
sub set_clear_alerts {
my ($self)=@_;

   my $store = $self->store();
   my $dbh = $self->dbh();
   foreach my $key (keys %TASKS) {
      my $desc=$TASKS{$key};
      my $data_out=$TASKS{$key}->{'DATA_OUT'};

		if ( ref($data_out) ne "ARRAY" ) { $data_out = [ $TASKS{$key}->{'DATA_OUT'} ]; }
		my $dout=join(',',@$data_out);
		#foreach my $d (@$data_out) {
		#   $self->log('debug',"set_clear_alerts::[DEBUG] CONSOLIDO ALERTA **FML** DATA_OUT=$d");
		#}
		my $task_result=$TASKS{$key}->{'result'};
		my $trc=$TASKS{$key}->{'RC'};
		my $tstat=$TASKS{$key}->{'task_status'};
		my $tev=$TASKS{$key}->{'ev'};
		my $correlated=$TASKS{$key}->{'correlated'} || 0;
		$KEY=$TASKS{$key}->{'id_dev'}.'.'.$TASKS{$key}->{'mname'};
      $self->log('debug',"set_clear_alerts::[DEBUG] CONSOLIDO ALERTA $KEY ($task_result) RC=$trc STAT=$tstat EV=$tev KEY=$key  RES=$desc->{result} MNAME=$desc->{mname} CAUSE=$desc->{cause} DATA_OUT=$dout correlated=$correlated");

		#Si por alguna causa el resultado no es valido, no lo considero.
		#Los valores de $tev eq 'UNK' y $dout==0.0 no se muy bien como se producen
		#pero es empirico que ocurren en situaciones de mucho volumen de alertas de incomunicados.
		#OJO: $dout==0.0 hay que chequearlo como $dout=~/\d+/ y $dout==0 porque sino da como valido $dout=U
		#if ( (! defined $trc) || ($trc !~ /\d+/) || ($tev eq 'UNK') || (($dout=~/\d+/) && ($dout==0)) ) {

#		if ( (! defined $trc) || ($trc !~ /\d+/) || ($tev eq 'UNK')  ) {
#			$self->log('warning',"set_clear_alerts::[WARN] RC INDEFINIDO $KEY ($task_result) RC=$trc STAT=$tstat EV=$tev KEY=$key  RES=$desc->{result} MNAME=$desc->{mname} LABEL=$desc->{label} DATA_OUT=$dout");
#		}

      if ( $TASKS{$key}->{'result'} eq 'SET') {
         if ($TASKS{$key}->{'is_post'}) { $self->set_alert_fast($TASKS{$key},2);  }
         else {  $self->set_alert_fast($TASKS{$key},1);  }
      }
      elsif ( $TASKS{$key}->{'result'} eq 'SETMOD') {
			my $extra = ' **CAMBIO DE SEVERIDAD**';
			if ($TASKS{$key}->{'severity0'}<$TASKS{$key}->{'severity'}) { $extra = ' **BAJA LA SEVERIDAD**'; }
			elsif ($TASKS{$key}->{'severity0'}>$TASKS{$key}->{'severity'}) { $extra = ' **SUBE LA SEVERIDAD**'; }

			$self->log('info',"set_clear_alerts:: **SETMOD** $key -> $extra");

			$self->reset_alert($TASKS{$key}, $extra);

         $self->set_alert_fast($TASKS{$key},1);
      }
      elsif ( $TASKS{$key}->{'result'} eq 'CLR') {  
			$self->reset_alert($TASKS{$key}, $TASKS{$key}->{'extra'});  

			my $jfile=$TASKS{$key}->{'jfile'};
			my $x='UNK';
			if (-e $jfile) { $x=unlink $jfile; }
			$self->log('info',"set_clear_alerts:: **CLR** $KEY key=$key jfile=$jfile x=$x");
		}

		# Alertas a eliminar con counter=0
      elsif ( $TASKS{$key}->{'result'} eq 'DEL') {
			# Se trata de alertas con counter=0
         my $mname=$TASKS{$key}->{'mname'};
         my $id_dev=$TASKS{$key}->{'id_dev'};
         my $where="mname=\'$mname\' and id_device=$id_dev";
         $store->delete_from_db($dbh,'alerts',$where);
		   $self->log('info',"set_clear_alerts:: **DEL** $KEY WHERE >> $where");

         my $jfile=$TASKS{$key}->{'jfile'};
         my $x='UNK';
         if (-e $jfile) { $x=unlink $jfile; }
         $self->log('info',"set_clear_alerts:: **DEL** $KEY jfile=$jfile x=$x");
      }

		elsif ( $TASKS{$key}->{'result'} eq 'PASS') {
			$self->set_alert_fast($TASKS{$key},0);
			$self->log('warning',"set_clear_alerts:: **PASS** $KEY ($task_result) RC=$trc STAT=$tstat EV=$tev KEY=$key  RES=$desc->{result} MNAME=$desc->{mname} CAUSE=$desc->{cause} DATA_OUT=$dout");
		}
      else {
			# FML 20190329 - Cambio de comportamiento para result indefinido (UNK)
			# No se hace nada. Antes por defecto se creaba una alerta, pero si hay avisos puede confundir.
			# REVISAR !!!!
         #$self->set_alert_fast($TASKS{$key},1);
         $self->log('warning',"set_clear_alerts::[WARN] RESULT INDEFINIDO $KEY ($task_result) RC=$trc STAT=$tstat EV=$tev KEY=$key  RES=$desc->{result} MNAME=$desc->{mname} CAUSE=$desc->{cause} DATA_OUT=$dout");
      }
   }

}


#----------------------------------------------------------------------------
# alert_processor
# Procesa los resltados obtenidos por las tareas encargadas de chequear las alertas
# (task_loop y task_serialize)
#----------------------------------------------------------------------------
sub alert_processor  {
my ($self)=@_;

   my $store = $self->store();
   my $dbh = $self->dbh();
	my $log_data;
	my $tnow=time();
			
   # Se obtienen los monitores que tienen diferentes severidades
   # EJ: 's_esp_cpu_avg_mibhost-174e4020' => 'v1>85:v1>75:' (critical:major:minor)
   my $WATCH_MULTI = $store->get_cfg_watch_multi_severity($dbh);
	
	#----------------------------------------------------------------------------
   # Se obtienen los resultados
   # $key es del tipo: id_dev.mname  (3.w_mon_tcp-f77f8dbf)
   #----------------------------------------------------------------------------
   foreach my $key (keys %TASKS) {
	
      my $host_name=$TASKS{$key}->{'host_name'};
      my $host_ip=$TASKS{$key}->{'host_ip'};
      my $type=$TASKS{$key}->{'type'};
      my $sev=$TASKS{$key}->{'severity'} || 'unk';
      my $name=$TASKS{$key}->{'name'};
      my $id_alert=$TASKS{$key}->{'id_alert'};
      my $id_dev=$TASKS{$key}->{'id_dev'};
      my $id_ticket=$TASKS{$key}->{'id_ticket'};
      my $cause=$TASKS{$key}->{'cause'};
      my $notif=$TASKS{$key}->{'notif'};
      my $mname = $TASKS{$key}->{'name'};
      my $cond = $TASKS{$key}->{'type'};
      my $counter = $TASKS{$key}->{'counter'};
      my $err_num = $TASKS{$key}->{'err_num'};
      my $err_str = $TASKS{$key}->{'err_str'};
      my $id_alert_type = $TASKS{$key}->{'id_alert_type'};

      my $task_info="HOST=$host_name ($host_ip) MNAME=$mname TIPO=$type SEV=$sev";

      if ($TASKS{$key}->{'task_status'} != TERMINATED) {
         $self->log('warning',"alert_processor::[ERROR] ===>> $key TASK NOT TERMINATED NO COMPUTO $task_info");
         # La elimino para no consolidar alerta
         delete $TASKS{$key};
         next;
      }

      $self->log('debug',"alert_processor::[DEBUG] ===>> $key CHILD ENDED CHECK_ALERT $task_info || err_num=$err_num err_str=$err_str");
      $self->watch($TASKS{$key}->{'watch'});
      $self->event_data([]);
      $self->event_data($TASKS{$key}->{'ev'});
		my $ev=$TASKS{$key}->{'ev'};
      my $RC=$TASKS{$key}->{'RC'};
      my $DATA_OUT=$TASKS{$key}->{'DATA_OUT'};
      if ( ref($DATA_OUT) ne "ARRAY" ) { $DATA_OUT = [ $TASKS{$key}->{'DATA_OUT'} ]; }
      my $is_post=$TASKS{$key}->{'is_post'};
			
      #---------------------------------------------------------------
      # Alerta de analisis (post_alert) >> do_task_analysis
      #---------------------------------------------------------------
      if ($is_post) {

         my $watch_name=$TASKS{$key}->{'watch'};
         my ($rc,$ev) = $self->post_chk_alert($key,$RC,$DATA_OUT);
         if ($rc) {
            $log_data="CHILDRES: $key IS_POST RC=$rc SET ($task_info) DATA_OUT=@$DATA_OUT";
            $self->event_data($ev);
            $TASKS{$key}->{'RC'} = $rc;
            $TASKS{$key}->{'ev'} = $ev;
            $TASKS{$key}->{'result'} = 'SET';
            $TASKS{$key}->{'watch'} = $watch_name;
            $TASKS{$key}->{'severity'} = $WATCHES{$watch_name}->[1];
         }
         # Si no genera alerta la elimino del vector de tareas
         else {
            $log_data="CHILDRES: $key IS_POST RC=$rc CHECK ($task_info) DATA_OUT=@$DATA_OUT";
            delete $TASKS{$key};
         }
      }
		
      #---------------------------------------------------------------
      # Alerta debida a watch >> do_task
      #---------------------------------------------------------------
      elsif ($RC==1) {
         my $watch_name=$self->watch();

			#Compruebo la ventana del watch (wsize) antes de dar por buena la alerta.
			#Si no cumple la condicion de ventana, no la considero alerta.
			#WATCHES watch_name->[expr,sev,wsize]
			my $tdiff=$tnow-$TASKS{$key}->{'date'};
			my $wsize=$WATCHES{$watch_name}->[2];

			$self->log('info',"alert_processor:: $key (W=$watch_name) DEPURA WATCH wsize=$wsize tdiff=$tdiff counter=$counter ev=$ev");

			#Ventana de monitor (wsize del monitor >0)
			if ($wsize>0) {
				if ( ($counter>=0) && ($tdiff >= ($counter+1)*$wsize) ) {
   	         $log_data="CHILDRES: $key WATCH SET (W=$watch_name) ($task_info) (tdiff=$tdiff|wsize=$wsize) DATA_OUT=@$DATA_OUT";
      	      $TASKS{$key}->{'result'} = 'SET';
         	}
				else {
         		$log_data="CHILDRES: $key WATCH PASS (W=$watch_name) ($task_info) (tdiff=$tdiff|wsize=$wsize) DATA_OUT=@$DATA_OUT";
	         	$TASKS{$key}->{'result'} = 'PASS';
				}
			}
			else {
				$log_data="CHILDRES: $key WATCH SET (W=$watch_name) ($task_info) (tdiff=$tdiff|wsize=$wsize) DATA_OUT=@$DATA_OUT";
            $TASKS{$key}->{'result'} = 'SET';
			}
   	   $TASKS{$key}->{'watch'} = $watch_name;

			#Se verifica si ha habido un cambio de severidad (watch con multiples severidades)
			if ( ($TASKS{$key}->{'result'} eq 'SET') && ($TASKS{$key}->{'severity0'} != $TASKS{$key}->{'severity'}) ) {
				$TASKS{$key}->{'result'} = 'SETMOD';
				$log_data .= " **SETMOD** sev0=$TASKS{$key}->{'severity0'} sev=$TASKS{$key}->{'severity'}";
			}
		
			# La severidad hay que calcularla en chk_metric porque puede haber varios monitores asociados a una metrica.
        	#$TASKS{$key}->{'severity'} = $WATCHES{$watch_name}->[1];
        	# $cond es $TASKS{$key}->{'type'};
         
      }
      #---------------------------------------------------------------
      # Alerta Remota
      #---------------------------------------------------------------
      elsif ($DATA_OUT->[0] eq 'REMOTE') {
         $log_data="CHILDRES: $key REMOTE (???) ($task_info) DATA_OUT=@$DATA_OUT";
      }
      #---------------------------------------------------------------
      # Alerta debida a no responde oid o sin respuesta snmp o no responde metrica latency
      #---------------------------------------------------------------
      elsif ($DATA_OUT->[0] eq 'U') {

         my $watch_in_db = $TASKS{$key}->{'watch'};
         # Si tengo un watch asociado => la alerta se genero debida a watch
         # aunque ahora tenga una alerta de oid no responde, mantengo la del watch
         if ($watch_in_db ne '0') {
            if (exists $WATCHES{$watch_in_db}->[0]) {
               $log_data="CHILDRES: $key UNK pero WATCH_IN_DB (W=$watch_in_db) ($task_info) DATA_OUT=@$DATA_OUT";
               # En este caso sobreescribo el valor del evento porque es de sin respuesta oid y en la BBDD
               # tengo un evento asociado a watch que es el que debe permanecer.
               $TASKS{$key}->{'ev'}='Sin datos';
               $TASKS{$key}->{'result'} = 'SET';
               #$TASKS{$key}->{'watch'} = $watch_name;
               $TASKS{$key}->{'severity'} = $WATCHES{$watch_in_db}->[1];
            }
            else { $log_data="CHILDRES: $key UNK WATCH NO EXISTE EN BBDD (W=$watch_in_db) ($task_info) DATA_OUT=@$DATA_OUT";  }
         }
         else {
            $TASKS{$key}->{'watch'} = 0;
            $TASKS{$key}->{'result'}='SET';
            $TASKS{$key}->{'severity'} = 4;  # Alerta azul ==> Para el administrador

            if ($mname eq 'mon_snmp') {
               $TASKS{$key}->{'cause'} = 'SIN RESPUESTA SNMP';
               $TASKS{$key}->{'severity'} = 1;
               $log_data="CHILDRES: $key SIN RESPUESTA SNMP ($task_info) DATA_OUT=@$DATA_OUT";
            }
            elsif ( ($mname eq 'mon_icmp') or ($mname eq 'disp_icmp') )  {
               $TASKS{$key}->{'cause'} = 'DISPOSITIVO INCOMUNICADO (ICMP)';
					$TASKS{$key}->{'severity'} = 1;
               $log_data="CHILDRES: $key DISPOSITIVO INCOMUNICADO ICMP ($task_info) DATA_OUT=@$DATA_OUT";
            }
            elsif ($mname eq 'mon_wbem') {
               $TASKS{$key}->{'cause'} = 'SIN RESPUESTA WMI';
               $TASKS{$key}->{'severity'} = 2;
               $log_data="CHILDRES: $key SIN RESPUESTA WMI ($task_info) DATA_OUT=@$DATA_OUT";
            }
            elsif ($mname eq 'mon_xagent') {
               $TASKS{$key}->{'cause'} = 'SIN RESPUESTA CNM-AGENT' ;
               $TASKS{$key}->{'severity'} = 2;
               $log_data="CHILDRES: $key SIN RESPUESTA CNM-AGENT ($task_info) DATA_OUT=@$DATA_OUT";
            }
            # En este caso se trata de una metrica de sin respuesta a OID (no es watch ni mon_snmp)
            elsif ($type eq 'latency') {
               # Obtengo la severidad de cfg_monitor porque si en un primer momento esta mal en la tabla
               # alerts ya siempre la tendria mal salvo que borrase la alerta.
               #  select severity from cfg_monitor where monitor='w_mon_tcp-f1282942';
               my $r=$store->get_from_db( $dbh, 'severity', 'cfg_monitor', "monitor='$mname'", '' );
               $TASKS{$key}->{'severity'} = $r->[0][0];
               $TASKS{$key}->{'cause'} = $cause;

					#if ( $mname =~ /icmp/ )  { 
				#		$TASKS{$key}->{'label'} = 'DISPOSITIVO INCOMUNICADO (ICMP)'; 
				#	}

               $log_data="CHILDRES: $key LATENCY".$TASKS{$key}->{'cause'}." ($task_info) DATA_OUT=@$DATA_OUT";
            }
            else {
               $log_data="CHILDRES: $key UNK ".$TASKS{$key}->{'cause'}." ($task_info) DATA_OUT=@$DATA_OUT";
            }
         }
      }
			

      #---------------------------------------------------------------
		# ERROR en el resultado de la validacion	
      # Si por alguna causa el resultado no es valido, no lo considero.
      # Los valores de $tev eq 'UNK' y $dout==0.0 no se muy bien como se producen
      # pero es empirico que ocurren en situaciones de mucho volumen de alertas de incomunicados.
      # OJO: $dout==0.0 hay que chequearlo como $dout=~/\d+/ y $dout==0 porque sino da como valido $dout=U
      # if ( (! defined $trc) || ($trc !~ /\d+/) || ($tev eq 'UNK') || (($dout=~/\d+/) && ($dout==0)) ) {
      #---------------------------------------------------------------
      elsif ( (! defined $RC) || ($RC !~ /\d+/) || ($ev eq 'UNK')  ) {
			$log_data="CHILDRES: $key RC INDEFINIDO ".$TASKS{$key}->{'cause'}." ($task_info) DATA_OUT=@$DATA_OUT (RC=$RC EV=$ev)";
         $TASKS{$key}->{'result'} = 'UNK';
      }

      #---------------------------------------------------------------
		# Otro error para el caso xagent.
      elsif ( ($err_num>0) && ($type eq 'xagent')  ) {
         $log_data="CHILDRES: $key ESTUDIAR ERROR err_num=$err_num ".$TASKS{$key}->{'cause'}." ($task_info) DATA_OUT=@$DATA_OUT (RC=$RC EV=$ev) err_str=$err_str";
         $TASKS{$key}->{'result'} = 'UNK';
      }
		

      #---------------------------------------------------------------
      # Alerta a eliminar (No existe la condicion de alerta)
      #---------------------------------------------------------------
      else {

if ( ($type eq 'latency') && ($DATA_OUT->[0] == 0) ) {
my $ev=$TASKS{$key}->{'ev'};
   $self->log('debug',"alert_processor::[DEBUG] CASO RARO E INDEFINIDO KEY=$key IP=$host_ip RC=$RC  EV=$ev");
}

#if ( ($type eq 'xagent')  ) {
#my $ev=$TASKS{$key}->{'ev'};
#   $self->log('info',"alert_processor::[DEBUG] CASO XAGENT A ESTUDIAR***** KEY=$key IP=$host_ip RC=$RC  EV=$ev  DATA_OUT=$DATA_OUT->[0] || err_num=$err_num err_str=$err_str");
#}

         # La borro de alerts y paso a alerts_store si counter > 0
         if ($counter > 0) {
				
				my $watch_name=$self->watch() || '0';
            push @ALERTS_CLR, [ $id_dev, $id_alert_type, $cause, $host_name, '', $host_ip, $notif, $id_alert, $mname, $watch_name ];
            $TASKS{$key}->{'result'}='CLR';
            # Con id_alert bastaria para borrar la alerta

				# Es neceasrio obtener la severidad de la tabla de alertas por si hubiera un watch con
				# multiples severidades. 
				# FIX-20190307
				my $x=$store->get_from_db( $dbh,'severity','alerts',"id_alert=$id_alert");
				$sev = $x->[0][0];

	         #Se actualiza notif_alert_clear (notificationsd evalua si hay que enviar aviso)
   	      $store->store_notif_alert($dbh, 'clr', { 'id_alert'=>$id_alert, 'id_device'=>$id_dev, 'id_alert_type'=>$id_alert_type, 'cause'=>$cause, 'name'=>$host_name, 'domain'=>'', 'ip'=>$host_ip, 'notif'=>$notif, 'mname'=>$mname, 'watch'=>$watch_name, 'id_metric'=>'', 'type'=>$type, 'severity'=>$sev, 'event_data'=>$ev, 'date'=>''  });

            # Si es un monitor de multiples severidades tengo que borrar el fichero de marca.
            # Basta con chequear que exista el fichero.
            #my $algun_flag_para_esto=1;
				#if ($algun_flag_para_esto) {
			
				my $monitor = $TASKS{$key}->{'watch'};	
				if ((exists $WATCH_MULTI->{$monitor}) && ($WATCH_MULTI->{$monitor}->{'type_mwatch'}==1)) {
					my $idw = 'mwatch-'.$id_dev.'-'.$monitor;
					my $cid=$self->cid();
					my $file_watch = "$Crawler::MDATA_PATH/output/$cid/notif/$idw";
               $self->log('info',"manage_app_notifications [$idw] ++CLEAR FILE++ CHECK file_watch=$file_watch");
               if (-f $file_watch) {
                  my $rx = unlink $file_watch;
                  $self->log('info',"alert_processor [$idw] ++CLEAR FILE++ UNLINK ($rx) $file_watch");
               }
				}

         }
         else {
            #my $where="mname=\'$mname\' and id_device=".$id_dev;
            #$store->delete_from_db($dbh,'alerts',$where);
            $CLR0 +=1;
            $TASKS{$key}->{'result'}='DEL';
         }
         $log_data="CHILDRES $key SUPRIMO ALERTA [".$TASKS{$key}->{'result'}.'] '.$TASKS{$key}->{'cause'}." ($task_info) DATA_OUT=@$DATA_OUT (counter=$counter)";
      }
		$self->log('info',"alert_processor:: $log_data");
   }
				

   #----------------------------------------------------------------------------
   # Correlacion de alertas
   #----------------------------------------------------------------------------
	$self->correlate_inside();
	$self->correlate_outside();

   #----------------------------------------------------------------------------
   #----------------------------------------------------------------------------


#	$self->check_analysis_alerts_timeout();

#   #----------------------------------------------------------------------------
#   # Las alertas de tipo analisis se borran si el usuario ha especificado una ventana de validez (en segs)
#   # Esto significa incluir un cuarto campo en la expresion del monitor:
#   #  nombre ; valor ; ventana de computo ; ventana de validez
#   # select a.date,m.expr from alerts a, alert_type m where a.watch=m.monitor and m.expr like '%;%;%';
#   my $alerts_analysis_active=$store->get_from_db( $dbh,
#         'a.date,m.expr,a.id_alert,a.mname,a.watch,a.id_alert_type,m.cause,a.notif,a.id_device,d.name,d.domain,d.ip,a.label',
#         'alerts a, alert_type m, devices d',
#         "a.watch=m.monitor and a.id_device=d.id_dev and m.expr like \'%;%;%\'"
#   );
#
#   foreach my $a (@$alerts_analysis_active) {
#      #STEP;v1;5;300
#      #El ultimo valor ($p[3]) es la ventana de validez de la alerta
#
##FML REVISAR QUE ESTAN TODOS LOS DATOS
#      my ($ename,$epar,$eval,$etimeout) = split (/\s*;\s*/, $a->[1]);
#      my $tdif=time - $a->[0];
#      $self->log('info',"alert_processor::[INFO] CHEQUEO VENTANA ANALISIS=$etimeout TDIF=$tdif");
#
#      if ( ($etimeout>0) && ($tdif> $etimeout) ) {
#
#         my $key=$a->[8].'.'.$a->[3];
#         $TASKS{$key}->{'result'}='CLR';
#         $TASKS{$key}->{'DATA_OUT'}="TIMEOUT EN VENTANA ANALISIS=$etimeout TDIF=$tdif";
#         $TASKS{$key}->{'extra'} = "**ELIMINADA AUTOMATICAMENTE**";
#
#			$TASKS{$key}->{'id_alert'} = $a->[2];
#			$TASKS{$key}->{'host_ip'} = $a->[11];
#			$TASKS{$key}->{'watch'} = $a->[4];
#			$TASKS{$key}->{'mname'} = $a->[3];
#			$TASKS{$key}->{'label'} = $a->[12];
#
#         $self->log('info',"alert_processor::[INFO] TIMEOUT EN VENTANA ANALISIS=$etimeout TDIF=$tdif ELIMINO ALERTA KEY=$key");
#      }
#   }

}


#----------------------------------------------------------------------------
# correlate_inside
# Correla entre las metricas/alertas de un mismo dispositivo.
# %CORRELATE_INTRA_DEVICE_DEFAULT es un hash que incorpora las reglas de correlacion
# que se implementan siempre.
# Las configuradas para el dispositivo se encuentran en el hash %DEV2IRULE.
# Las alertas a correlar se eliminan del hash %TASKS => No se almacenan en BBDD.
#----------------------------------------------------------------------------
sub correlate_inside  {
my ($self)=@_;

   #----------------------------------------------------------------------------
   # OJO!! En este punto ya no existe 'disp_icmp' (se correla previamente)
   my %CORRELATE_INTRA_DEVICE_DEFAULT = (

      'icmp' => [ { 'orig' => {'subtype' => ['mon_icmp']},   'dest' => {'subtype' => ['mon_ip_icmp2','mon_ip_icmp3']} } ],
      'icmp2' => [ { 'orig' => {'subtype' => ['mon_icmp2']},   'dest' => {'subtype' => ['mon_ip_icmp3']} } ],
      'nosnmp' => [ { 'orig' => {'subtype' => ['mon_snmp']},   'dest' => {'type' => ['snmp']} } ],

#      '00000001' => [ { 'orig' => {'subtype' => ['mon_icmp']},  'dest' => {'type' => ['latency']} } ],
   );

   my $orig='';
   my %ALERTS_PER_DEVICE=();
   # Se organizan las alertas por dispositivo
   foreach my $key (keys %TASKS) {
      my $id_dev=$TASKS{$key}->{'id_dev'};
      my $mname = $TASKS{$key}->{'name'};
      my $watch = $TASKS{$key}->{'watch'};
      my $type = $TASKS{$key}->{'type'};
		my $id_alert=$TASKS{$key}->{'id_alert'};
		my $counter = $TASKS{$key}->{'counter'};

		#Esto aplica solo si se quiere rellenar ALERTS_CLR para notificaciones. No es el caso.
		#my $host_name=$TASKS{$key}->{'host_name'};
		#my $host_ip=$TASKS{$key}->{'host_ip'};
		#my $id_alert=$TASKS{$key}->{'id_alert'};
		#my $cause=$TASKS{$key}->{'cause'};
		#my $notif=$TASKS{$key}->{'notif'};
		#my $id_alert_type = $TASKS{$key}->{'id_alert_type'};
		#my $counter = $TASKS{$key}->{'counter'};
      #push @{$ALERTS_PER_DEVICE{$id_dev}}, { 'mname'=>$mname, 'watch'=>$watch, 'type'=>$type, correlated=>0, 'host_name'=>$host_name, 'host_ip'=>$host_ip, 'id_alert'=>$id_alert, 'cause'=>$cause, 'notif'=>$notif, 'id_alert_type'=>$id_alert_type, 'counter'=>$counter };

      push @{$ALERTS_PER_DEVICE{$id_dev}}, { 'mname'=>$mname, 'watch'=>$watch, 'type'=>$type, correlated=>0, 'counter'=>$counter, 'id_alert'=>$id_alert };
   }

	
   #Itero sobre los dispositivos en alerta
   foreach my $id_dev (keys %ALERTS_PER_DEVICE) {

		my %CORRELATE_INTRA_DEVICE = %CORRELATE_INTRA_DEVICE_DEFAULT;
		if ($DEV2IRULE{$id_dev} ne '00000000') {
			my $rule_subtype=$DEV2IRULE{$id_dev};	
			$CORRELATE_INTRA_DEVICE{$rule_subtype} = $IRULES->{$rule_subtype};
			$self->log('info',"correlate_inside:: id_dev=$id_dev INCLUYE RULE $rule_subtype");
		}

      # Recorro las alertas del dispositivo $id_dev
      foreach my $alert (@{$ALERTS_PER_DEVICE{$id_dev}}) {

		   # Compruebo las reglas de correlacion interna.
   		# Indexadas por $rule que es un identificador de ta regla.
   		foreach my $rule (keys %CORRELATE_INTRA_DEVICE) {
			
      		if (exists $CORRELATE_INTRA_DEVICE{$rule}->[0]->{'orig'}->{'subtype'}->[0]) {
         		$orig=$CORRELATE_INTRA_DEVICE{$rule}->[0]->{'orig'}->{'subtype'}->[0];
            	# Si el subtype de la alerta producida no se corresponde con el $orig de correlacion, la salto.
					if ($orig ne $alert->{'mname'}) { next;  }
     	 		}
      		elsif (exists $CORRELATE_INTRA_DEVICE{$rule}->[0]->{'orig'}->{'watch'}->[0]) {
         		$orig=$CORRELATE_INTRA_DEVICE{$rule}->[0]->{'orig'}->{'watch'}->[0];
      		}
      		else { next; }

            # Recorro las metricas que deben ser correladas
            foreach my $mname (@{$CORRELATE_INTRA_DEVICE{$rule}->[0]->{'dest'}->{'subtype'}}) {

$self->log('info',"correlate_inside:: CHEQUEO RULE=$rule EN id_dev=$id_dev orig=$orig dest=$mname << alert_mname: $alert->{'mname'}");
               # Si se correlan todas las metricas de un tipo hay que exceptuar la que origina dicha correlacion
               my $idx=0;
               foreach my $a (@{$ALERTS_PER_DEVICE{$id_dev}}) {
                  # $mname es el subtype a correlar
                  if (($mname eq $a->{'mname'}) && ($orig ne $a->{'mname'})) {

                     if ($a->{'correlated'}) { next; }
                     my $key=$id_dev.'.'.$a->{'mname'};
                     $ALERTS_PER_DEVICE{$id_dev}->[$idx]->{'correlated'}=1;

                     #delete $TASKS{$key};
							my $delete_mode='DEL';
				         if ($a->{'counter'} > 0) { $delete_mode='CLR'; }

							$TASKS{$key}->{'result'}=$delete_mode;
							$self->log('info',"correlate_inside::**CORRELATED [1]** $delete_mode KEY=$key rule=$rule id_dev=$id_dev orig=$orig dest=$mname id_alert=$a->{'id_alert'} counter=$a->{'counter'}");

                  }
                  $idx+=1;
               }

            }
				# Recorro los tipos que deben ser correlados
            foreach my $type (@{$CORRELATE_INTRA_DEVICE{$rule}->[0]->{'dest'}->{'type'}}) {

$self->log('info',"correlate_inside::CHEQUEO RULE=$rule EN id_dev=$id_dev orig=$orig dest=$type << alert_mname: $alert->{'mname'} alert_type: $alert->{'type'}");

               # Si se correlan todas las metricas de un tipo hay que exceptuar la que origina dicha correlacion
               my $idx=0;
               foreach my $a (@{$ALERTS_PER_DEVICE{$id_dev}}) {
                  if (($type eq $a->{'type'}) && ($orig ne $a->{'mname'})) {

                     if ($a->{'correlated'}) { next; }
                     my $key=$id_dev.'.'.$a->{'mname'};
                     $ALERTS_PER_DEVICE{$id_dev}->[$idx]->{'correlated'}=1;

                     #delete $TASKS{$key};
                     my $delete_mode='DEL';
                     if ($a->{'counter'} > 0) { $delete_mode='CLR'; }

                     $TASKS{$key}->{'result'}=$delete_mode;
                     $self->log('info',"correlate_inside::**CORRELATED [2]** $delete_mode KEY=$key rule=$rule id_dev=$id_dev orig=$orig dest=$type id_alert=$a->{'id_alert'} counter=$a->{'counter'}");

                  }
                  $idx+=1;
               }
            }
         } # End rules

      }
   }
}

#----------------------------------------------------------------------------
# correlate_outside
# Correla las alertas entre dispositivos
# %CORRELATE_INTRA_DEVICE_DEFAULT es un hash que incorpora las reglas de correlacion
# que se implementan siempre.
# Las configuradas para el dispositivo se encuentran en el hash %DEV2IRULE.
# Las alertas a correlar se eliminan del hash %TASKS => No se almacenan en BBDD.
#----------------------------------------------------------------------------
sub correlate_outside  {
my ($self)=@_;

   my $store = $self->store();
   my $dbh = $self->dbh();

   #----------------------------------------------------------------------------
   # %CORRELATE_INTER_DEVICE es un hash que permite correlar entre dispositivos.
   # Su funcionamiento es el siguiente.
   # Cada clave es el valor del id_dev del dispositivo correlado.
   # Cada valor es la clave id_dev.mname que indican el dispositivo y la metrica
   # que originan la correlacion.
   # El vector se debe rellenar de la BBDD
   # Las alertas de este tipo se elmacenan en BBDD es estado correlado.
   # my %CORRELATE_INTER_DEVICE = ( '30' => ['3.mon_icmp'] );
   # id_dev (el correlado) => id_dev_correlated.mname_correlated (los que originan la correlacion)
   #----------------------------------------------------------------------------
   my $CORRELATE_INTER_DEVICE_RULES=$store->get_outside_correlation_rules($dbh);
$self->log('info',"correlate_outside:: STEP1");

#$VAR1 = {
#          '18.mon_icmp' => [
#                             '43'
#                           ]
#        };



	my %CORRELATED_TRUE=();
   foreach my $key (keys %TASKS) {
		if (exists $CORRELATE_INTER_DEVICE_RULES->{$key}) {
			foreach my $id_dev (@{$CORRELATE_INTER_DEVICE_RULES->{$key}}) { 
				$CORRELATED_TRUE{$id_dev}=$key; 
			}
		}
	}

	foreach my $id_dev_correlated (keys %CORRELATED_TRUE) {
$self->log('info',"correlate_outside:: id_dev_correlated=$id_dev_correlated");
	   foreach my $key (keys %TASKS) {
#$self->log('info',"correlate_outside:: id_dev_correlated=$id_dev_correlated key=$key");
			if ($id_dev_correlated == $TASKS{$key}->{'id_dev'}) {
			
	         #$TASKS{$key}->{'correlated'}=$key_correlated;
				my $key_orig=$CORRELATED_TRUE{$id_dev_correlated};
	         $TASKS{$key}->{'correlated'}=$key_orig;
   	      $self->log('info',"correlate_outside::**CORRELATED** id_dev_correlated=$id_dev_correlated ($key) BY key=$key_orig");
			}
		}
	}

}



#----------------------------------------------------------------------------
# get_current_alerts
# Obtiene las alertas en curso para incorporarlas al vector %TASKS
# No cosidera las alertas de analisis salvo la funcion window.
# IN: 	BBDD
# OUT:	%TASKS
#----------------------------------------------------------------------------
sub get_current_alerts  {
my ($self)=@_;

   my $store = $self->store();
   my $dbh = $self->dbh();
   my $range=$self->range();
	my $cid=$self->cid();
	my $condition='a.severity!=4';
	if ($range == TASK_SEV4) { 
		$condition='a.severity=4'; 
		my $vres=$store->get_from_db( $dbh,'ip','alerts',"mname=\'mon_snmp\'");
		my @ips=();
		foreach my $a (@$vres) { push @ips,"\'".$a->[0]."\'"; }
		if (scalar(@ips)>0) { $condition = 'a.severity=4 and d.ip not in (' . join (',',@ips) . ')'; }
		$self->log('info',"get_current_alerts4:: condition=$condition");	
	}

	#my $condition = ($cond) ? "and $cond" : '';

	my $m2s=$store->get_from_db( $dbh, 'script,subtype', 'cfg_monitor_agent', '');
	my %key2serialize=();
	foreach my $x (@$m2s) { 
		#subtype=>srcipt
		$key2serialize{$x->[1]} = $x->[0]; 
	}

   my $dir_shared=$Crawler::MDATA_PATH.'/shared';
   if (! -d $dir_shared) { mkdir $dir_shared; }

   #----------------------------------------------------------------------------
   # ALERTAS SIMPLES + window  ==> Las incluyo en el vector de tareas %TASKS
   #----------------------------------------------------------------------------
   my $alerts_set=$store->get_from_db( $dbh,
         'd.name,d.domain,d.ip,a.id_alert_type,a.counter,a.mname as name,a.watch,a.type,a.severity,a.id_alert,d.id_dev,a.id_ticket,a.cause,a.notif,a.id_metric,a.subtype,a.date,d.critic',
         'alerts a, devices d',
         "a.cid=\'$cid\' and a.id_device=d.id_dev and d.status=0 and a.type not in (\'snmp-trap\',\'syslog\',\'email\',\'api\') and $condition  order by type"
   );

   foreach my $a (@$alerts_set) {

      # Si es una alerta producida por un watch de analisis distinto de window paso bola
      my $watch_name=$a->[6];
      if (  (exists $WATCHES{$watch_name}->[0]) &&
            ($WATCHES{$watch_name}->[0] =~ /\S+?;\S+?;\S+?/) &&
            ($WATCHES{$watch_name}->[0] !~ /window;\S+?;\S+?/i) ) { next; }


      my $id_dev=$a->[10];
      my $mname=$a->[5];
      my $id_alert_type = ($a->[3]) ? $a->[3] : 1;
		my $serial='';
		if (exists $key2serialize{$a->[15]}) { $serial=$key2serialize{$a->[15]}; }
		else { $serial=$id_dev.'.'.$a->[15]; }

      if ($mname eq 'disp_icmp') { $mname='mon_icmp'; }
      $KEY=$id_dev.'.'.$mname;

		$self->log('info',"get_current_alerts:: GET $KEY **EN BBDD** IP=$a->[2]");

      my $fout=$dir_shared.'/_ipc_'.$KEY;
      $self->shared_init($fout);
      $TASKS{$KEY} = { 'out'=>$fout, 'task_status'=>IDLE, 'host_ip'=>$a->[2], 'hname'=>$a->[0], 'hdomain'=>$a->[1], 'id_alert_type'=>$id_alert_type, 'counter'=>$a->[4], 'name'=>$mname, 'watch'=>$a->[6], 'type'=>$a->[7], 'severity'=>$a->[8], 'id_alert'=>$a->[9], 'id_dev'=>$a->[10], 'id_ticket'=>$a->[11], 'cause'=>$a->[12], 'notif'=>$a->[13], 'mname'=>$mname, 'result'=>'UNK', 'extra'=>'', 'id_metric'=>$a->[14], 'subtype'=>$a->[15], 'jfile'=>'', 'date'=>$a->[16], 'critic'=>$a->[17], 'serial'=>$serial };

      $TASKS{$KEY}->{'host_name'}=join('.', $a->[0], $a->[1]);
   }

   #----------------------------------------------------------------------------
   # Obtengo las alertas generadas por los crawlers para este cid en los ficheros de MDATA
	# Hay que considerar sólo los dispositivos activos para evitar bucles de salta 
	# y se borra la alerta.
   #----------------------------------------------------------------------------

	# Obtengo la lista de dipostivos no activos.
   #my $not_active=$store->get_from_db( $dbh, 'ip', 'devices', 'status != 0', '' );
   #my %DEVICES_NOT_ACTIVE = map { $_->[0] => 1 } @$not_active;
   my $not_active=$store->get_from_db( $dbh, 'ip,status', 'devices', '', '' );
   my %DEVICES_WITH_STATUS = map { $_->[0] => $_->[1] } @$not_active;

   my @crawler_alerts=`/usr/bin/find $Crawler::MDATA_PATH/output/$cid/a -type f`;

	# Caso de sin respuesta snmp en dispositivo que han desactivado el snmp
	my @mon_snmp=();
	foreach my $f (@crawler_alerts) {
      chomp $f;
		#10.2.254.71.1.snmp.18.mon_snmp
		if ($f =~ /\/(\d+\.\d+\.\d+\.\d+)\.\d+\.snmp\.(\d+)\.mon_snmp$/) { push @mon_snmp,$2; }
	}
	my %DEVICES_NOT_SNMP = ();
	my $not_snmp = [];
	if (scalar (@mon_snmp)>0) {
		my $cond = 'id_dev IN (' . join (',',@mon_snmp) .')';
		$not_snmp=$store->get_from_db( $dbh, 'ip,version', 'devices', $cond, '' );
	}
	%DEVICES_NOT_SNMP = map { $_->[0] => $_->[1] } @$not_snmp;

	my $tnow=time;
	foreach my $f (@crawler_alerts) {
		chomp $f;

		# Si ha pasado mas de 1 hora de la fecha del fichero lo elimino.
		my $tdif = $tnow - (stat($f))[9];
		if ($tdif > 3600) {
			my $rx=unlink $f;
			$self->log('info',"get_current_alerts:: Elimino fichero por timestamp ($tdif) f=$f");
			next;
		}	

		#/opt/data/mdata/output/default/a/10.2.254.211.2.latency.49.w_mon_tcp-c6390dc6
		#/opt/data/mdata/output/default/a/10.129.80.191.2.snmp.1470.custom_1a607cfc-18003.836767
		#/opt/data/mdata/output/default/a/178.33.211.251-3023.2.xagent.53.xagt_004001
		if (	($f !~ /\/(\d+\.\d+\.\d+\.\d+)\.(\d+)\.\w+\.(\d+\.[\w+|\-*|\.*]+)$/) &&
				($f !~ /\/(\d+\.\d+\.\d+\.\d+\-\w+)\.(\d+)\.\w+\.(\d+\.[\w+|\-*|\.*]+)$/) ) { next; }
		my ($ip,$severity,$key)=($1,$2,$3);

		## Si el dispositivo no esta activo, no considero la alerta.
		#if (exists $DEVICES_NOT_ACTIVE{$ip}) { next; }


      # Si el dispositivo no existe ya en BBDD no considero la alerta 
		# El fichero, si no se actualiza, se elimina al cabo de la hora y como no se hace chk_metric, no se actualiza.
      if (! exists $DEVICES_WITH_STATUS{$ip}) { 
        	$self->log('info',"get_current_alerts:: Salto alerta porque ya no existe dispositivo con $ip f=$f");
			next; 
		}
		# Si el dispositivo existe en BBDD pero esta activo, no considero la alerta.
      elsif ($DEVICES_WITH_STATUS{$ip} != 0) { next; }


		# Si el dispositivo no responde por SNMP pero su version es cero, elimino la alerta.
		# ==> Han desactivado el snmp del equipo.
		if ((exists $DEVICES_NOT_SNMP{$ip}) && ($DEVICES_NOT_SNMP{$ip}==0) ) { 
			my $rx=unlink $f;
			$self->log('info',"get_current_alerts:: Elimino fichero por SNMP desactivado en $ip f=$f");
			next; 
		}

		if ($range == TASK_SEV4) {
			if ($severity != 4) { next; }
		}
		else {
         if ($severity == 4) { next; }
      }

		# Si la alerta ya estaba en BBDD la salto	
		if (exists $TASKS{$key}) { next; }

		# Leo la alerta del crawler y la incorporo al vector de tareas
		open (A,"<$f");
		my $adata=<A>;
		close A;
		eval {
			my $calert=decode_json($adata);
#$calert contiene los siguientes campos:
#
#'event_data' => '',
#'id_metric' => '2762',
#'ip' => '10.2.254.211',
#'mname' => 'mon_icmp',
#'subtype' => 'disp_icmp',
#'watch' => 'disp_icmp',
#'label' => 'DISPONIBILIDAD ICMP (ping) (sliow001.s30labs.com)',
#'type' => 'latency',
#'severity' => '2'
#
#y debe contener:
#
#
#out
#task_status
#   host_ip
#   hname
#   hdomain
#      id_alert_type
#   counter
#   name
#   watch
#   type
#   severity
#      id_alert
#   id_dev
#      id_ticket
#   label
#      notif
#    mname
#    result
#    extra
#

	      $calert->{'serial'}='';
   	   if (exists $key2serialize{$calert->{'subtype'}}) { 
				$calert->{'serial'}=$key2serialize{$calert->{'subtype'}}; 
			}
			else { $calert->{'serial'} = $calert->{'id_dev'}.'.'.$calert->{'subtype'}; }

      	my $dir_shared=$Crawler::MDATA_PATH.'/shared';
      	my $fout=$dir_shared.'/_ipc_'.$key;

			$calert->{'out'}=$fout;
			$calert->{'task_status'}=IDLE;
			$calert->{'name'}=$calert->{'mname'};
			$calert->{'result'}='UNK';
			$calert->{'extra'}='';
			$calert->{'counter'}=-1;
			$calert->{'jfile'}=$f;
			$calert->{'date'}=time;
			if ($severity==4) {$calert->{'counter'}=-5;}
			$self->shared_init($fout);
			$TASKS{$key}=$calert; 
			$self->log('info',"get_current_alerts:: GET $key **NEW** IP=$calert->{'ip'} FILE=$f");
         my $kk=Dumper($calert);
         $kk=~s/\n/\./g;
			$self->log('debug',"get_current_alerts:: GET $key **NEW** DATA=$kk");
		};

		if ($@) { 
			$self->log('warning',"get_current_alerts::EXCEPTION AL LEER $f adata=$adata ($@)");
			my $rc=unlink $f;
			$self->log('info',"get_current_alerts:: Borrado $f ($rc)");
		}

	}

	#debug
	if ($range != TASK_SEV4) {
		$self->serialize_data ( {'in'=>\%TASKS, 'format'=>'dumper', 'outpath'=>$dir_shared, 'outname'=>'TASKS.pm'} );
	}

}

#----------------------------------------------------------------------------
# get_analysis_alerts_configured
#----------------------------------------------------------------------------
sub get_analysis_alerts_configured  {
my ($self)=@_;

   my $store = $self->store();
	my $dbh = $self->dbh();

   #----------------------------------------------------------------------------
   # ALERTAS DE ANALISIS ==> Las incluyo en el vector de tareas %TASKS
   # En las alertas de analisis no son los crawlers los que levantan el flag, es el propio notificationsd.
   #----------------------------------------------------------------------------
   my $alerts_analysis=$store->get_from_db( $dbh,
        # 'd.name,d.domain,d.ip,a.id_alert_type,a.counter,a.mname as name,a.watch,a.type,a.severity,a.id_alert,d.id_dev',
         'd.name,d.domain,d.ip,m.name,a.monitor as watch,a.type,a.severity,d.id_dev,a.expr,m.mode,a.cause as label',
         'alert_type a, metrics m, devices d',
         "m.id_dev=d.id_dev and a.monitor=m.watch and m.status=0 and d.status=0 and a.expr like \'%;%;%\'  order by a.type"
   );

   foreach my $a (@$alerts_analysis) {

      my $id_dev=$a->[7];
      my $mname=$a->[3];
      my $key=$id_dev.'.'.$mname;
      #my $fout='/tmp/_ipc_'.$key;
      my $dir_shared=$Crawler::MDATA_PATH.'/shared';
      my $fout=$dir_shared.'/_ipc_'.$key;
      #$notif->shared_init($fout);

      # Pongo severity=4 porque si no es asi task_serialize la salta
      #FML PROVISIONAL !!!!
      #$a->[6]=4;

      if (exists $TASKS{$key}) {

         $TASKS{$key} = { out=>$fout, 'task_status'=>IDLE, 'host_ip'=>$a->[2], 'hname'=>$a->[0], 'hdomain'=>$a->[1], 'name'=>$mname, 'watch'=>$a->[4], 'type'=>$a->[5], 'severity'=>$a->[6], 'id_dev'=>$a->[7], 'expr'=>$a->[8], 'mode'=>$a->[9], 'result'=>'UNK', 'label'=>$a->[10], 'mname'=>$mname,  'extra'=>'' };
      }
      else {

         #FML OJO id_alert_type no debe ser 0
         $TASKS{$key} = { out=>$fout, 'task_status'=>IDLE, 'host_ip'=>$a->[2], 'hname'=>$a->[0], 'hdomain'=>$a->[1], 'name'=>$mname, 'watch'=>$a->[4], 'type'=>$a->[5], 'severity'=>$a->[6], 'id_dev'=>$a->[7], 'expr'=>$a->[8], 'mode'=>$a->[9], 'result'=>'UNK', 'id_alert_type'=>1, 'label'=>$a->[10], 'mname'=>$mname,  'extra'=>'', 'id_alert'=>0, 'counter'=>0, 'id_ticket'=>0, 'notif'=>0 };
      }

      $TASKS{$key}->{'host_name'}=join('.', $a->[0], $a->[1]);
   }

}

#----------------------------------------------------------------------------
# check_analysis_alerts_timeout
#----------------------------------------------------------------------------
sub check_analysis_alerts_timeout  {
my ($self)=@_;

   my $store = $self->store();
   my $dbh = $self->dbh();

   #----------------------------------------------------------------------------
   # Las alertas de tipo analisis se borran si el usuario ha especificado una ventana de validez (en segs)
   # Esto significa incluir un cuarto campo en la expresion del monitor:
   #  nombre ; valor ; ventana de computo ; ventana de validez
   # select a.date,m.expr from alerts a, alert_type m where a.watch=m.monitor and m.expr like '%;%;%';
   my $alerts_analysis_active=$store->get_from_db( $dbh,
         'a.date,m.expr,a.id_alert,a.mname,a.watch,a.id_alert_type,m.cause,a.notif,a.id_device,d.name,d.domain,d.ip,a.label',
         'alerts a, alert_type m, devices d',
         "a.watch=m.monitor and a.id_device=d.id_dev and m.expr like \'%;%;%\'"
   );

   foreach my $a (@$alerts_analysis_active) {
      #STEP;v1;5;300
      #El ultimo valor ($p[3]) es la ventana de validez de la alerta

#FML REVISAR QUE ESTAN TODOS LOS DATOS
      my ($ename,$epar,$eval,$etimeout) = split (/\s*;\s*/, $a->[1]);
      my $tdif=time - $a->[0];
      $self->log('debug',"check_analysis_alerts_timeout::[INFO] CHEQUEO VENTANA ANALISIS=$etimeout TDIF=$tdif");

      if ( ($etimeout>0) && ($tdif>$etimeout) ) {

         my $key=$a->[8].'.'.$a->[3];
         $TASKS{$key}->{'result'}='CLR';
         $TASKS{$key}->{'DATA_OUT'}="TIMEOUT EN VENTANA ANALISIS=$etimeout TDIF=$tdif";
         $TASKS{$key}->{'extra'} = "**ELIMINADA AUTOMATICAMENTE**";

         $TASKS{$key}->{'id_alert'} = $a->[2];
         $TASKS{$key}->{'host_ip'} = $a->[11];
         $TASKS{$key}->{'watch'} = $a->[4];
         $TASKS{$key}->{'mname'} = $a->[3];
         $TASKS{$key}->{'label'} = $a->[12];

         $self->log('info',"check_analysis_alerts_timeout::[INFO] TIMEOUT EN VENTANA ANALISIS=$etimeout TDIF=$tdif ELIMINO ALERTA KEY=$key");
      }
   }
}



#----------------------------------------------------------------------------
# chk_alert
#----------------------------------------------------------------------------
sub chk_alert  {
my ($self,$desc,$store)=@_;

   my @RESULTS=();
   my ($RC,$DATA_OUT,$IS_POST,$ev,$watch_name,$severity,$err_num,$err_str)=(0,['UNK'],0,['UNK'],'',1,0,'[OK]');

	my $type = $desc->{'type'};
	my $mname = $desc ->{'mname'};
	my $id_dev = $desc ->{'id_dev'};
	my $ip = $desc ->{'host_ip'};

eval {	
   #-------------------------------------------------------------------------------------------
   # METRICAS SNMP
   #-------------------------------------------------------------------------------------------
   if ($type eq 'snmp' ) {

      if ( $mname =~ /^s_(.*?)-\w+$/ ) { $mname=$1; }
      $RC=$SNMP->chk_metric( {host_ip=>$ip, mname=>$mname}, \@RESULTS, $store);
      $ev=$SNMP->event_data();
      $DATA_OUT=$SNMP->data_out();
		$watch_name=$SNMP->watch();		
      $self->event_data($ev);
		$self->watch($watch_name);
		$severity=$SNMP->severity();
		$err_num=$SNMP->err_num();
		$err_str=$SNMP->err_str();
   }

   #-------------------------------------------------------------------------------------------
   # METRICAS LATENCY
   #-------------------------------------------------------------------------------------------
   #elsif  ( ($desc{'type'} eq 'latency' )  ||  ( ($mname =~ /w_(mon_\w+)-\w+/) || ($mname =~ /^(mon_\w+)$/) )) {
   elsif  ($type eq 'latency' ) {

      if ( ($mname =~ /^s_w_mon_(.*?)-\d+$/) || ($mname =~ /^s_(mon_\w+)$/) ) { $mname=$1; }
      $RC=$LATENCY->chk_metric( { host_ip=>$ip, mname=>$mname}, \@RESULTS, $store );
      $ev=$LATENCY->event_data();
      $DATA_OUT=$LATENCY->data_out();
		$watch_name=$LATENCY->watch();		
      $self->event_data($ev);
		$self->watch($watch_name);
      #$severity=$self->severity();
		$severity=$LATENCY->severity();
      $err_num=$LATENCY->err_num();
      $err_str=$LATENCY->err_str();
   }

   #-------------------------------------------------------------------------------------------
   # METRICAS WBEM
   #-------------------------------------------------------------------------------------------
#   elsif  ($type eq 'wbem' ) {
#
#      $RC=$WBEM->chk_metric( { host_ip => $ip, mname => $mname }, \@RESULTS, $store );
#      $ev=$WBEM->event_data();
#      $DATA_OUT=$WBEM->data_out();
#		$watch_name=$WBEM->watch();		
#      $self->event_data($ev);
#		$self->watch($watch_name);
#		$severity=$WBEM->severity();
#      $err_num=$WBEM->err_num();
#      $err_str=$WBEM->err_str();
#   }

   #-------------------------------------------------------------------------------------------
   # METRICAS XAGENT
   #-------------------------------------------------------------------------------------------
   #elsif   ( ($desc{'type'} eq 'xagent' )  || (($mname =~ /xagt/) || ($mname eq 'mon_xagent') )) {
   elsif    ($type eq 'xagent' )  {

		my $dbh=$self->dbh();
		$XAGENT->dbh($dbh);
      if ($mname =~ /^s_(xagt_\S+)_\d+$/) { $mname=$1; }
      #En este caso subtype debe ser realmente el nombre de la metrica metrics.name
      $RC=$XAGENT->chk_metric( { host_ip=>$ip, mname=>$mname}, \@RESULTS, $store );
      $ev=$XAGENT->event_data();
      $DATA_OUT=$XAGENT->data_out();
		$watch_name=$XAGENT->watch();		
      $self->event_data($ev);
		$self->watch($watch_name);
		$severity=$XAGENT->severity();
      $err_num=$XAGENT->err_num();
      $err_str=$XAGENT->err_str();
   }

   #-------------------------------------------------------------------------------------------
   # ALERTAS REMOTAS
   #-------------------------------------------------------------------------------------------
   else  {
		$RC=0;
		$DATA_OUT=['REMOTE'];
		$ev=['UNK'];
   }

   #-------------------------------------------------------------------------------------------
   my $info='';
   foreach my $r (@RESULTS) {  $info .= join (' ',@$r) . " ; ";  }

	$KEY=$id_dev.'.'.$mname;

	my $dev=join('. ',@$ev);
   $self->log('info',"chk_alert::[INFO] RES $KEY IP=$ip MNAME=$mname TYPE=$type RC=$RC DATA_OUT=@$DATA_OUT ($info) err_num=$err_num err_str=$err_str | EV=$dev");

   #$IS_POST = $self->is_post_chk_alert($desc,$RC,$DATA_OUT);

};
if ($@) { $self->log('info',"chk_alert::EXCEPTION en chk_alert ($@)");}

	return ($RC,$DATA_OUT,$IS_POST,$severity,$err_num,$err_str);
}



#----------------------------------------------------------------------------
# is_post_chk_alert
# OUT:
#        0 ==> No procesa la alerta
#        1 ==> Si procesa la alerta
#----------------------------------------------------------------------------
sub is_post_chk_alert  {
my ($self,$desc,$RC,$DATA_OUT)=@_;

   #-------------------------------------------------------------------------------------------
   # Las expresiones elaboradas se codifican asi:
   # fx;valor;V  ==>  delta;v1;V  o  STEP;v1;5
   # fx = La funcion de computo (delta, slope...)
   # valor = El valor a chequear (v1, v1+v2/5 ...)
   # V = La ventana de muestreo
#  my $watch = $desc->{'watch'};

   my $expr = $desc->{'expr'};
   my $watch = $desc->{'watch'};
   if (! $expr) { return 0; }

   my ($fx,$val_name,$w) = split (/\s*;\s*/, $expr);

   if (! $w) {
      $self->log('debug',"is_post_chk_alert::[DEBUG] expr=$expr (W=$watch) NO es compuesto");
      return 0;
   }

   my $ts=time;
   $fx=lc $fx;
   if (! exists $FIFO_FUNCTION{$fx}) {
      $self->log('debug',"is_post_chk_alert::[DEBUG] expr=$expr (W=$watch) es compuesto pero no existe funcion de proceso");
      return 0;
   }

   $self->log('debug',"is_post_chk_alert::[DEBUG]  expr=$expr (W=$watch) ES COMPUESTO");
	return 1;
}



#----------------------------------------------------------------------------
# post_chk_alert
# OUT:
#	$ev ==> El valor del evento que produce la alerta (si no hay alerta ev='-')
#	$rc ==> El resultado de evaluar el watch (1/0)
#----------------------------------------------------------------------------
sub post_chk_alert  {
my ($self,$key,$RC,$DATA_OUT)=@_;

   #-------------------------------------------------------------------------------------------
   # Las expresiones elaboradas se codifican asi:
   # fx;valor;V  ==>  delta;v1;V  o  STEP;v1;5
   # fx = La funcion de computo (delta, slope...)
   # valor = El valor a chequear (v1, v1+v2/5 ...)
   # V = La ventana de muestreo
#	my $watch = $desc->{'watch'};

	my $desc = $TASKS{$key};
	my $expr = $desc->{'expr'};
	my $watch = $desc->{'watch'};
   my ($fx,$val_name,$w) = split (/\s*;\s*/, $expr);
   $self->log('debug',"post_chk_alert::[DEBUG] $expr ($watch) ($fx,$val_name,$w) KEY=$key");
	my $ts=time;
	$fx=lc $fx;
	my $ev='-';
	my $rc=0;

	my $is_post = $self->is_post_chk_alert($TASKS{$key},$RC,$DATA_OUT);
	if (! $is_post) { return ($rc,$ev); }

	# Si alguno de los valores es U, no se computa
	foreach my $v (@$DATA_OUT) {
		if ($v eq 'U') { return ($rc,$ev); }
	}

	my $value=join (':',@$DATA_OUT);

   $self->log('debug',"post_chk_alert::[DEBUG] $expr ($watch) >> SI ES COMPUESTO ($fx,$val_name,$w) KEY=$key");
   if ( ref($ALERTS_FIFO{$key}) ne 'ARRAY' ) {
		$self->log('debug',"post_chk_alert::[DEBUG] $expr ($watch) es compuesto pero no hay datos");
   	push @{$ALERTS_FIFO{$key}}, { 'id_dev'=>$desc->{'id_dev'}, 'mname'=>$desc->{'mname'}, 'ts'=>$ts, 'value'=>$value, 'value_name'=>$val_name, 'mode'=>$desc->{'mode'}, 'watch'=>$desc->{'watch'}, 'watch_eval'=>0 };
		return ($rc,$ev);
	}

   # Incorporo el valor actual a la fifo y controlo el numero de muestras
   push @{$ALERTS_FIFO{$key}}, { 'id_dev'=>$desc->{'id_dev'}, 'mname'=>$desc->{'mname'}, 'ts'=>$ts, 'value'=>$value, 'value_name'=>$val_name, 'mode'=>$desc->{'mode'}, 'watch'=>$desc->{'watch'}, 'watch_eval'=>0 };
   my $NM=scalar @{$ALERTS_FIFO{$key}};
   if ($NM > $w) {
      $self->log('debug',"post_chk_alert::[DEBUG] En FIFO $NM muestras, Ventana = $w ==>> ROTACION");
      shift @{$ALERTS_FIFO{$key}};
   }

   # IMP. Los elementos del vector ya deben estar ordenados por ts (order by ts)
   my @values=();
   foreach my $item (@{$ALERTS_FIFO{$key}}) {
#      #$self->log('debug',"post_chk_alert::[DEBUG] ARRAY DE values ITEM=$item VAL=$item->{'value'}");
#		my @v=split(':', $item->{'value'});
#		my $idx=0;
#		if ($val_name =~ /v(\d+)/i) { $idx=$1-1; }
#      #push @values,$item->{'value'};
#      push @values,$v[$idx];



		my @v=split(':', $item->{'value'});
		my @result = $self->watch_eval($item->{'value_name'},\@v,$desc->{'file'},{});
		push @values,$result[0];


   }

	# Si es mode=COUNTER ==> diferencias, tengo que calcular las diferencias del array @values.
	if ($desc->{'mode'} eq 'COUNTER') {
		$w -= 1;
		my $n = scalar @values;
		my @newval=();
		for my $v (0..$n-2) {
			push @newval, $values[$v+1]-$values[$v];
		}
		@values=@newval;
	}

   $self->log('debug',"post_chk_alert::[DEBUG] Evaluo $fx (VALUES = @values) ");

   # Ejecuto la funcion adecuada
   $rc=&{$FIFO_FUNCTION{$fx}}($self,\@values,$w);

   $self->log('debug',"post_chk_alert::[DEBUG] RESULTADO=$rc F=$FIFO_FUNCTION{$fx}  $fx (VALUES = @values) ");

   if ($rc==1) {

	   $ev = $self->time2date($ts).": $fx @values\n";

		# Elimino los datos almacenados en la FIFO para evitar nuevos positivos
		delete $ALERTS_FIFO{$key};

   }

	return ($rc,$ev);
}


#----------------------------------------------------------------------------
# mail_alert_processor
# Recorre el buzon de entrada de cnmnotifier@dominio.xx
#----------------------------------------------------------------------------
sub mail_alert_processor {
my ($self)=@_;


	my $MAIL_INBOX='/opt/data/buzones/cnmnotifier/new/';
   opendir (DIR,$MAIL_INBOX);
   my @mail_files = readdir(DIR);
   closedir(DIR);

	if (scalar(@mail_files)==0) { return; }

   my $store = $self->store();
   my $dbh = $self->dbh();


	# Se obtiene el vector de expresiones definidas para generar alertas
	# en base a eventos de tipo email
	my $alert2expr=$store->get_remote_alert_expr_by_type($dbh,'email');
	my $email2alert=$store->get_cfg_email_remote_alerts($dbh);

my $kk1=Dumper($email2alert);
$self->log('debug',"mail_alert_processor:: Las alertas remotas tipo email definidas (email2alert) son: $kk1");


	my $parser = new MIME::Parser;
	$parser->output_to_core(1);
	$parser->decode_headers(1);
	$parser->ignore_errors(1);
		
   foreach my $file (sort @mail_files) {
		
      my $file_path=$MAIL_INBOX.$file;
		if (! -f $file_path) { next; }
		
#		my $ent = $parser->parse_open($file_path);
#		if (! $ent) {
#			#log
#			next;
#		}

#$self->log('info',"mail_alert_processor::[*************************************] PROCESADO $file_path");
		
	
    #$parser->output_dir("mimedump-tmp");
		$MAIL_DATA{'Subject'}='';
   	$MAIL_DATA{'Body'}='';

    	my $ent = $parser->parse_open($file_path);
      if (! $ent) {
         $self->log('info',"mail_alert_processor::[**ERROR**] parse_open de $file_path");
			# Se borra el correo
			unlink $file_path;
         next;
		}
    	$self->mime_dump($ent);

		my $evkey1=md5_hex($MAIL_DATA{'Subject'});
		my $evkey=substr $evkey1,0,16;

#		if (! $evkey) {
#         $self->log('info',"mail_alert_processor::[**ERROR**] Sin Subject  $file_path");
#			# Se borra el correo
#			unlink $file_path;
#         next;
#      }

		#my $msg=$ent->body_as_string;
		my $msg = '<b>v1 (Subject):</b>&nbsp;'. $MAIL_DATA{'Subject'} .'<br><b>v2 (Body):</b>&nbsp;'.  $MAIL_DATA{'Body'};
		my $proccess = 'EMAIL';
		my $from = $MAIL_DATA{'From'};
		$from =~ s/<\s*(\S+)\s*>/$1/;
      my $ip='0.0.0.0';
      my $name=$from;
      my $domain='';


		if (exists $EMAIL2DEV{$from}) {
			$ip=$EMAIL2DEV{$from}->[2];
			$name=$EMAIL2DEV{$from}->[0];
			$domain=$EMAIL2DEV{$from}->[1];
		}

		my $t=time;
		$store->store_event($dbh, { date=>$t, code=>1, proccess=>$proccess, msg=>$msg, ip=>$ip, name=>$name, domain=>$domain, evkey=>$evkey, msg_custom=>'' });

$self->log('info',"mail_alert_processor:: STORE EVENT date=>$t, code=>1, proccess=>$proccess, ip=>$ip, name=>$name, domain=>$domain, evkey=>$evkey, msg_custom=>'' ");

      # Se borra el correo
      unlink $file_path;


		if (scalar(keys %$email2alert) ==  0) {
			$self->log('debug',"mail_alert_processor:: SIN ALERTAS REMOTAS POR EMAIL DEFINIDAS...");
			next;
		}

		# ----------------------------------------------------------------
		# MAPEO DE ALERTAS
		# Existen alertas remotas de tipo mail aociadas a algun dispositivo.
		# Miro si el evento tiene mapeada alerta (a dicho from)
		# ----------------------------------------------------------------
      my @vals=($MAIL_DATA{'Subject'}, $MAIL_DATA{'Body'} );
		my $expr_logic='AND'; # REVISAR!!! FML

		#Para cada alerta de tipo email configurada (y asociada a algun dispositivo)
		#chequeo si el evento (amil) cumple sus expresiones
		foreach my $ev  (keys %$email2alert) {
		
#      	my $email=$email2alert->{$ev}->{'email'};
			# Valido que sean del dispositivo adecuado a traves del from
#			if ($from ne $email) { next; }

	      if (! exists $email2alert->{$ev}->{$from}) {
   	      $self->log('debug',"mail_alert_processor:: ALERTA $ev: NO DEFINIDA PARA $from...");
      	   next;
      	}


			my $email=$email2alert->{$ev}->{$from}->{'email'};
	      my $subtype=$email2alert->{$ev}->{$from}->{'subtype'};
	      my $target=$email2alert->{$ev}->{$from}->{'target'};
	      my $monitor=$email2alert->{$ev}->{$from}->{'monitor'};
	      my $vdata=$email2alert->{$ev}->{$from}->{'vdata'};
	      my $action=$email2alert->{$ev}->{$from}->{'action'};
	      my $severity=$email2alert->{$ev}->{$from}->{'severity'};
	      my $script=$email2alert->{$ev}->{$from}->{'script'};
	      my $descr=$email2alert->{$ev}->{$from}->{'descr'};
	      my $id_remote_alert=$email2alert->{$ev}->{$from}->{'id_remote_alert'};
	      my $expr=$email2alert->{$ev}->{$from}->{'expr'};
	      my $mode=$email2alert->{$ev}->{$from}->{'mode'};
			my $mname=$subtype;
			my $type='email';
			my $cause=$descr;	
			my $id_metric=$id_remote_alert;

my $kk=Dumper($alert2expr->{$id_remote_alert});
$self->log('info',"mail_alert_processor:: id_remote_alert=$id_remote_alert DUMPER=$kk");

     		my $condition_ok=$self->watch_eval_ext($alert2expr->{$id_remote_alert},$expr_logic,\@vals);
$self->log('info',"mail_alert_processor:: id_remote_alert=$id_remote_alert watch_eval_ext RES=$condition_ok");

			if (! $condition_ok) {next; }

	      # Procesado de alertas. SET ---------------------------------------------------------------
  			# store_mode: 0->Insert 1->Update
  			if ( $action =~ /SET/i ) {
	         $self->log('notice',"mail_alert_processor::[INFO] $monitor [SET-ALERT: IP=$ip/$name/$from | EV=$ev | MSG=$msg]");
  	       	my ($alert_id,$alert_date,$alert_counter)=$store->store_alert($dbh,$monitor,{ 'ip'=>$ip, 'mname'=>$mname, 'severity'=>$severity, 'event_data'=>$msg, 'cause'=>$cause, 'type'=>$type, 'id_alert_type'=>20, 'id_metric'=>$id_metric, 'mode'=>$mode, 'subtype'=>$subtype  }, 1);
     		}

     		# Procesado de alertas. CLEAR -------------------------------------------------------------
     		elsif ( $action =~ /CLR\((\S+)\)/ ) {
   	      $self->log('notice',"mail_alert_processor::[INFO] $monitor [CLEAR-ALERT: IP=$ip/$name | EV=$ev | MSG=$msg]");
  	   	   $store->clear_alert($dbh,{ 'ip'=>$ip, 'mname'=>$1 });
     		}

     		else {
        		$self->log('warning',"mail_alert_processor::[WARN] $monitor [SIN ACCION (A=$action): IP=$ip/$name | EV=$ev | MSG=$msg]");
     		}
		}
						

	} #Itero sobre los correos recibidos
}

#----------------------------------------------------------------------------
# mime_dump
#----------------------------------------------------------------------------
sub mime_dump {
my ($self,$entity, $name) = @_;
   #defined($name) or $name = "'anonymous'";
   my $IO;
#   # Output the head:
#   print "\n", '=' x 60, "\n";
#   print "Message $name: ";
#   print "\n", '=' x 60, "\n\n";
#   #print $entity->head->original_text;
#   print "\n";
   if (! defined $name) {
      $name='1';
		#$results->('Subject')=$entity->head->get('Subject');
		$MAIL_DATA{'Subject'} = $entity->head->get('Subject');
		$MAIL_DATA{'From'} = $entity->head->get('From');
		$MAIL_DATA{'To'} = $entity->head->get('To');

		chomp $MAIL_DATA{'Subject'};
		chomp $MAIL_DATA{'From'};
		chomp $MAIL_DATA{'To'};

      #my $subject=$entity->head->get('Subject');
      #print "***FML*** S=$subject\n";
   }
   # Output the body:
   my @parts = $entity->parts;
   if (@parts) {                     # multipart...
      my $i;
      foreach $i (0 .. $#parts) {       # dump each part...
         #dump_entity($parts[$i], ("$name, part ".(1+$i)));
         $self->mime_dump($parts[$i], ("$name.".(1+$i)));
      }
    }
    else {                            # single part...
$self->log('info',"mime_dump::[**DEBUG**] NAME=$name");

      #if ($name !~ /1\.1\.1/) {return; }
      if ($name ne '1') {return; }
      # Get MIME type, and display accordingly...
      my ($type, $subtype) = split('/', $entity->head->mime_type);
      my $body = $entity->bodyhandle;
      if ($type =~ /^(text|message)$/) {     # text: display it...
			$MAIL_DATA{'Body'}='';
         if ($IO = $body->open("r")) {
            #print $_ while (defined($_ = $IO->getline));
            while (defined($_ = $IO->getline)) { $MAIL_DATA{'Body'} .= $_; };
            $IO->close;
         }
         else {       # d'oh!
            print "$0: couldn't find/open '$name': $!";
         }
      }
#     else {                                 # binary: just summarize it...
#        my $path = $body->path;
#        my $size = ($path ? (-s $path) : '???');
#        print ">>> This is a non-text message, $size bytes long.\n";
#        print ">>> It is stored in ", ($path ? "'$path'" : 'core'),".\n\n";
#     }
   }
   return 0;

}

#----------------------------------------------------------------------------
# task_loop
# IN:
#  $tasks -> Vector de tareas
#  $max_task_active -> Maximo numero de tareas activas de forma concurrente
#  $max_task_timeout -> Maximo timeout para terminar una las tareas
#----------------------------------------------------------------------------
sub task_loop {
my ($self,$max_task_active,$max_task_timeout)=@_;

	my $tasks=\%TASKS;
   my $t0=time;
	my $t=$t0;
   my $done=0;
   my $TOTAL_TASKS = scalar (keys %$tasks);

	my $total_timeout = 600 + (int($TOTAL_TASKS/$max_task_active)+1)*$max_task_timeout;
   my $tlast= $t + $total_timeout;
	#$SIG{CHLD} = 'IGNORE';
	#$SIG{CHLD}=sub { my $rc=wait(); $self->log('info',"task_loop:: **end child** rc=$rc ($?)");};

	$SIG{CHLD}=sub {

	   while ((my $rc = waitpid(-1, &WNOHANG)) > 0) {
   	   $self->log('info',"task_loop:: **end child** rc=$rc ($?)");
   	}
	};
		
   while ($t < $tlast) {

		my $tdif=$tlast-$t;
		$self->log('debug',"task_loop::[DEBUG] DONE = $done TOTAL=$TOTAL_TASKS TIMEOUT en $tdif secs. (TOTAL=$total_timeout secs)");
      if ($done == $TOTAL_TASKS) {
			$self->log('debug',"task_loop::[DEBUG] TERMINO task_loop");
			last;
		}
			
      #------------------------------------
      # Lanzo procesos
      #------------------------------------
      my $current_tasks=0;
		my $num_checks=0;
      my $done_current=0;
      foreach my $key (keys %$tasks) {
			
         if ($tasks->{$key}->{'task_status'} != IDLE) { next; }
         if ($current_tasks >= $max_task_active) { last;}

			# Miro si es una tarea que se puede serializar y actuo en consecuencia
			my @serialized=();
         if ($tasks->{$key}->{'serial'} ne '') {
				foreach my $k (keys %$tasks) {	
					if ($tasks->{$k}->{'serial'} eq $tasks->{$key}->{'serial'}) {  push @serialized, $k; }
				}
			}
			else { push @serialized, $key; }

         my $ns=scalar(@serialized);
         $num_checks+=$ns;

			$self->log('warning',"task_loop::[ERROR] En fork: $!") unless defined (my $child = fork());
			#Child
         if ($child == 0) {

			  	$self->log('info',"task_loop:: ===>> START_CHILD PID=$$ NUM_CHECKS=$ns [$num_checks|$TOTAL_TASKS]");
				
				eval {
					my $store=$self->store();	
					my $dbh=$store->dbh();
      	      my $child_dbh=$store->fork_db($dbh);
         	   $store->dbh($child_dbh);
            	$self->dbh($child_dbh);

					my $n=0;
					foreach my $ks (@serialized) {

						$n+=1;
   	            my $desc=$tasks->{$ks};
	               $self->log('info',"task_loop:: ===>> START_CHECK PID=$$ [$n|$ns] key=$ks HOST=$desc->{host_name} ($desc->{host_ip}) MNAME=$desc->{mname} TIPO=$desc->{type} SEV=$desc->{'severity'} WATCH=$desc->{watch}");
	
						my ($RC,$DATA_OUT,$is_post,$severity,$err_num,$err_str)=$self->chk_alert($tasks->{$ks},$store);
	
						my %results=( 'RC'=>$RC, 'is_post'=>$is_post, 'severity'=>$severity, 'err_num'=>$err_num, 'err_str'=>$err_str);
						if (ref($DATA_OUT) eq "ARRAY") { $results{'DATA_OUT'} = join ("\n", @$DATA_OUT); }
						else { $results{'DATA_OUT'} = $DATA_OUT;  }

						my $ev = $self->event_data();
						if ( ref($ev) eq "ARRAY") { $results{'ev'} = join ("\n", @$ev); }
						else { $results{'ev'} = $ev;  }

						my $w=$tasks->{$ks}->{'watch'};
						if (exists $WATCHES{$w}->[0]) { $results{'watch'} = $w; }
						else { $results{'watch'} = $self->watch(); }
	
						if ($is_post)  { $results{'watch'}=$tasks->{$ks}->{'watch'}; }

						my $fout = $tasks->{$ks}->{'out'};
						$self->shared_write(\%results, $fout);
					}
            };
            if ($@) {
               $self->log('warning',"task_loop:: EXCEPTION en task_loop ($@)");
            }
            exit;
         }

			#Parent
			else {
				foreach my $ks (@serialized) {
		         $tasks->{$ks}->{'task_status'} = ACTIVE;
   		      $current_tasks += 1;
				}
			}
      }
		
      #------------------------------------
      $t=time;
		if ($current_tasks == 0) {
			$self->log('warning',"task_loop::[ERROR] TERMINO POR NO TENER TAREA (DONE = $done)");
			last;
		}
			
      while ($t < $tlast) {
			$self->log('debug',"task_loop::[DEBUG] DONE=$done done_current=$done_current current_tasks=$current_tasks");
         if ($done_current == $current_tasks) { last; }
         if ($done == $TOTAL_TASKS) { last; }
			
         foreach my $key (keys %$tasks) {

            if ($tasks->{$key}->{'task_status'} == TERMINATED) { next; }
            my $fout = $tasks->{$key}->{'out'};
            if (-f $fout) { $tasks->{$key}->{'task_status'} = DONE;  }
            if ($tasks->{$key}->{'task_status'} != DONE) {  next; }
            if ($tasks->{$key}->{'task_status'} == ACTIVE) { next; }
            if ($done_current == $current_tasks) { last; }
            if ($done == $TOTAL_TASKS) { last; }
				$self->log('info',"task_loop:: END_CHECK KEY=$key DONE=$done done_current=$done_current current_tasks=$current_tasks");
            # $tasks->{$key}->{'result'} = $self->shared_read($fout);
            my $result = $self->shared_read($fout);

				# RC, DATA_OUT, is_post, ev, watch
				$tasks->{$key}->{'severity0'} = $tasks->{$key}->{'severity'};
				$tasks->{$key}->{'RC'} = $result->{'RC'};
				$tasks->{$key}->{'DATA_OUT'} = $result->{'DATA_OUT'};
				$tasks->{$key}->{'is_post'} = $result->{'is_post'};
				$tasks->{$key}->{'ev'} = $result->{'ev'};
				$tasks->{$key}->{'watch'} = $result->{'watch'};
				$tasks->{$key}->{'severity'} = $result->{'severity'};
				$tasks->{$key}->{'err_num'} = $result->{'err_num'};
				$tasks->{$key}->{'err_str'} = $result->{'err_str'};
            $tasks->{$key}->{'task_status'} = TERMINATED;
				$self->log('info',"task_loop:: shared_read key=$key fout=$fout ev=$result->{'ev'}");
            $done_current +=1;
            $done +=1;
         }

			#Esta espera el fundamental para no consumir toda la CPU 
         #sleep 2;
			select(undef, undef, undef, 0.5);
         $t=time;
      }

   }

   if ($done < $TOTAL_TASKS) {
		$self->log('warning',"task_loop::[ERROR] TERMINO POR TIEMPO (DONE = $done TOTAL_TASKS=$TOTAL_TASKS)");
	}
	else {
		my $total_time = time - $t0;
		$self->log('info',"task_loop::[INFO] DONE = $done TTASKS=$TOTAL_TASKS TTIMEOUT=$total_timeout TTIME=$total_time secs.");
	}
}


#----------------------------------------------------------------------------
# task_serialize
# IN:
#  $tasks -> Vector de tareas
#----------------------------------------------------------------------------
sub task_serialize {
my ($self)=@_;

	my $tasks=\%TASKS;
   my $TOTAL_TASKS = scalar (keys %$tasks);
   my $current_task=1;
	
      $self->log('info',"task_serialize::[INFO] ===>> TOTAL_TASKS=$TOTAL_TASKS");

   my $store=$self->store();
   #my $dbh=$store->open_db();
  	#$store->dbh($dbh);
	my $dbh=$store->dbh();

   foreach my $key (keys %$tasks) {
	

    	my $ip = $tasks->{$key}->{'ip'};
      #my $fout = $tasks->{$key}->{'out'};
      my $desc=$tasks->{$key};
	
		# Solo se serializan las alertas de severidad 4 (azules)
		# fml if ($desc->{'severity'} != 4) { next; }

		my $t=time;
      my $task_info="HOST=$desc->{host_name} ($desc->{host_ip}) MNAME=$desc->{mname} TIPO=$desc->{type} SEV=$desc->{'severity'} WATCH=$desc->{watch} ($current_task/$TOTAL_TASKS)";
      $self->log('info',"task_serialize::[INFO] ===>> CHECK_ALERT $task_info");

      my ($RC,$DATA_OUT,$is_post,$severity,$err_num,$err_str)=$self->chk_alert($tasks->{$key},$store);

      # RC, DATA_OUT, is_post, ev, watch
      $tasks->{$key}->{'RC'} = $RC;
      $tasks->{$key}->{'DATA_OUT'} = $DATA_OUT;
      $tasks->{$key}->{'is_post'} = $is_post;
      $tasks->{$key}->{'severity'} = $severity;
      $tasks->{$key}->{'err_num'} = $err_num;
      $tasks->{$key}->{'err_str'} = $err_str;

      my $ev = $self->event_data();
      if ( ref($ev) eq "ARRAY") { $ev = join ("\n", @$ev); }
      $tasks->{$key}->{'ev'} = $ev;

		my $watch = $self->watch();
      if ($is_post)  { $watch=$tasks->{$key}->{'watch'}; }
      $tasks->{$key}->{'watch'} = $watch;

      $tasks->{$key}->{'task_status'} = TERMINATED;
   	$current_task += 1;

      my $tdif=time - $t;
		#parche fml. Hay que ver porque puede ser undef
		if (! defined $DATA_OUT) { $DATA_OUT = ['U']; }
		$tasks->{$key}->{'DATA_OUT'} = $DATA_OUT;
      $self->log('info',"task_serialize::[INFO] ===>> RESULT (T=$tdif) >> RC=$RC DATA_OUT=@$DATA_OUT is_post=$is_post EV=$ev WATCH=$watch");
   }
}


#----------------------------------------------------------------------------
# delta
#----------------------------------------------------------------------------
sub delta  {
my ($self,$values,$window)=@_;

   # delta
   # ==> t(n)-(t(n-1)) > 0 && t(n+1)-t(n) < 0

   my ($cnt_up,$cnt_down,$set)=(0,0,0);
   my $MAX_VAL=scalar @$values;
   # Si no tengo suficientes datos termino
   if ($MAX_VAL < $window) { return $set; }

   my $center = int ($window/2);
   for my $i (0..$center-1) {
      #if (($values->[$i] - $values->[$i+1])>0) { $set=1 }
      if (($values->[$i+1] - $values->[$i])>0) { $cnt_up = 1; }
   }

   for my $i ($center..$window-2) {
      #if ($i == $window-1) { last; }
      if (($values->[$i+1] - $values->[$i])<0) { $cnt_down = 1; }
   }

   if (($cnt_up==1) && ($cnt_down==1)) { $set=1; }

   return $set;

}


#----------------------------------------------------------------------------
# step
#----------------------------------------------------------------------------
sub step  {
my ($self,$values,$window)=@_;

   # step
   # ==> t(n)-(t(n-1)) > 0 && t(n+1)-t(n) < 0

   my ($cnt_up,$cnt_down,$set)=(0,0,0);
   my $MAX_VAL=scalar @$values;
   # Si no tengo suficientes datos termino
   if ($MAX_VAL < $window) { return $set; }

   my $center = int ($window/2);
   for my $i (0..$center-1) {
      #if (($values->[$i] - $values->[$i+1])>0) { $set=1 }
      if (($values->[$i+1] - $values->[$i])>0) { $cnt_up = 1; }
   }

   for my $i ($center..$window-2) {
      #if ($i == $window-1) { last; }
      if (($values->[$i+1] - $values->[$i])<0) { $cnt_down = 1; }
   }

   if (($cnt_up==1) || ($cnt_down==1)) { $set=1; }

   return $set;

}


#----------------------------------------------------------------------------
# step_up
#----------------------------------------------------------------------------
sub step_up  {
my ($self,$values,$window)=@_;

   # up_slope
   # ==> t(n)-(t(n-1)) > 0 && t(n+1)-t(n) < 0

   my ($cnt_up,$cnt_down,$set)=(0,0,0);
   my $MAX_VAL=scalar @$values;
   # Si no tengo suficientes datos termino
   if ($MAX_VAL < $window) { return $set; }

   for my $i (0..$window-2) {
      if (($values->[$i+1] - $values->[$i])>0) { $cnt_up = 1; }
   }

   if ($cnt_up==1)  { $set=1; }
   return $set;

}


#----------------------------------------------------------------------------
# step_down
#----------------------------------------------------------------------------
sub step_down  {
my ($self,$values,$window)=@_;

   # up_slope
   # ==> t(n)-(t(n-1)) > 0 && t(n+1)-t(n) < 0

   my ($cnt_up,$cnt_down,$set)=(0,0,0);
   my $MAX_VAL=scalar @$values;
   # Si no tengo suficientes datos termino
   if ($MAX_VAL < $window) { return $set; }

   for my $i (0..$window-2) {
      #if ($i == $window-1) { last; }
      if (($values->[$i+1] - $values->[$i])<0) { $cnt_down = 1; }
   }

   if ($cnt_down==1) { $set=1; }
   return $set;

}



#----------------------------------------------------------------------------
# window
#----------------------------------------------------------------------------
sub window  {
my ($self,$values,$window)=@_;


   my ($cnt_set,$set)=(0,0);
   return $set;
}


#----------------------------------------------------------------------------
# set_alert_fast
# Description: Almacena alerta en alerts mediante store_alert
#  Internamente compone un hash de datos para store_alert (%M)
#
#     ip,watch,type,event_data,severity,mname
#  a partir de:
#     host_ip,$monitor,type,$self->event_data(),severity,name
#
# IN:
#  $desc: Vector de datos
#  $monitor:
#  $severity
#  $cond
#  $mode :  0 ==> Insert (crawler), 1 ==> Update (notificationsd)
#

#----------------------------------------------------------------------------
sub set_alert_fast  {
#my ($self,$desc,$ev,$monitor,$severity,$cond,$mode)=@_;
my ($self,$desc,$mode)=@_;

   #Hash de correlacion de metricas uno a uno. Evita que aparezca duplicada una misma alerta
   #-------------------------------------------------
   #my %correlate=( 'disp_icmp'=>'mon_icmp' );

   $SET +=1;
   #-------------------------------------------------
   my $task_id=$self->task_id();
   my $store=$self->store();
   my $dbh=$self->dbh();

   #-------------------------------------------------
   my %M=();
   $M{'ip'}=$desc->{'host_ip'};
   $M{'name'}=$desc->{'hname'};
   $M{'domain'}=$desc->{'hdomain'};
   $M{'critic'}=$desc->{'critic'};

	$M{'date_last'}=$self->time_ref();

   $M{'watch'}=$desc->{'watch'};
   $M{'type'}=$desc->{'type'};
   $M{'subtype'}=$desc->{'subtype'};
	$M{'id_metric'}=$desc->{'id_metric'};
	$M{'correlated'}=$desc->{'correlated'};


	if ($desc->{'ev'} ne '')  {  $M{'event_data'}=$desc->{'ev'}; }
	my $severity = (defined $desc->{'severity'}) ? $desc->{'severity'} : 1;

   #$M{'severity'} = (defined $severity) ? $severity : 1;
   $M{'severity'} = $severity;

   $M{'id_ticket'}=$desc->{'id_ticket'};
   $M{'cause'}=$desc->{'cause'};
	my $monitor=$desc->{'watch'};
   $M{'mname'}=$desc->{'name'};

	#$M{'hidx'}=$self->hidx();
	$M{'cid'}=$self->cid();
	my $id_dev=$desc->{'id_dev'};
	my $key=$id_dev.'.'.$M{'mname'};
	$M{'wsize'} = (exists $DEV2WSIZE{$id_dev}) ? $DEV2WSIZE{$id_dev} : 0;


 	if (! $monitor) { $M{'id_alert_type'} = 0; }
   else { $M{'id_alert_type'} = $store->get_alert_type($dbh,$monitor); }
	
   my ($alert_id,$alert_date,$alert_counter)=$store->store_alert($dbh,$monitor,\%M,$mode);
	if (! defined $alert_id) { 
		$alert_id='U'; 
   	return $alert_id;
	}

	if ($mode !=0) {

      # Se actualiza notif_alert_set para posible respuesta a alertas
		# Solo se hace si $alert_counter>0 (store_alert ha hecho el paso de 0 a 1)
		# wsize puede definir ounter con valores de -5, -10 en dispositivos con baja/muy baja sensibilidad.
		if ($alert_counter>0) {
	      $store->store_notif_alert($dbh, 'set', { 'id_alert'=>$alert_id, 'id_device'=>$id_dev, 'id_alert_type'=>$M{'id_alert_type'}, 'cause'=>$M{'cause'}, 'name'=>$M{'name'}, 'domain'=>$M{'domain'}, 'ip'=>$M{'ip'}, 'notif'=>'', 'mname'=>$M{'mname'}, 'watch'=>$M{'watch'}, 'id_metric'=>$M{'id_metric'}, 'type'=>$M{'type'}, 'severity'=>$severity, 'event_data'=>$M{'event_data'}, 'date'=>$alert_date  });
		}
   	$self->log('info',"set_alert_fast:: **SET** $key ($mode) $desc->{type} [HOST=$desc->{hname}|DOM=$desc->{hdomain}|IP=$M{ip}|MNAME=$M{mname}|W=$monitor|EV=$M{event_data}|SEV=$severity|CAUSE=$M{cause}|WSIZE=$M{wsize} (IDALERT=$alert_id|IDMETRIC=$desc->{id_metric}) mode=$mode alert_date=$alert_date alert_counter=$alert_counter");

	}
	else {
   	$self->log('info',"set_alert_fast:: **PASS** $key ($mode) $desc->{type} [HOST=$desc->{hname}|DOM=$desc->{hdomain}|IP=$M{ip}|MNAME=$M{mname}|W=$monitor|EV=$M{event_data}|SEV=$severity|CAUSE=$M{cause}|WSIZE=$M{wsize} (IDALERT=$alert_id|IDMETRIC=$desc->{id_metric}) mode=$mode alert_date=$alert_date alert_counter=$alert_counter");
	}

   return $alert_id;
}




#----------------------------------------------------------------------------
# reset_alert
# IN: IP, MNAME, $dbh
#----------------------------------------------------------------------------
sub reset_alert {
my ($self,$desc,$extra)=@_;

	$CLR += 1;
   #-------------------------------------------------
   my $task_id=$self->task_id();
   my $store=$self->store();
   my $dbh=$self->dbh();

   my %M=();
   $M{'id_alert'}=$desc->{'id_alert'};
   $M{'ip'}=$desc->{'host_ip'};
   $M{'watch'}=$desc->{'watch'};
   $M{'mname'}=$desc->{'name'};

   $self->log('info',"reset_alert:: **CLEAR** $desc->{type} [HOST=$desc->{host_name}|IP=$M{ip}|MNAME=$M{mname}|W=$M{watch}] (IDALERT=$M{id_alert})");
   $store->clear_alert($dbh,\%M,$extra);

#	# Hay que borrar el fichero de alerta del crawler	
#	# /opt/data/mdata/output/default/a/10.2.254.211/2.latency.49.w_mon_tcp-c6390dc6
#	my $sev=$desc->{'severity'};
#	my $type=$desc->{'type'};
#	my $id_dev=$desc->{'id_dev'};
# 	my $cid='default';
#	my $f="$Crawler::MDATA_PATH/output/$cid/a/$M{'ip'}/$sev\.$type\.$id_dev\.$M{mname}";
#	my $rc=0;
#	if (-f $f) { $rc=unlink $f; }
#  
	my $key=$desc->{'id_dev'}.'.'.$M{'mname'};
 
	$self->log('info',"reset_alert:: **CLEAR** $key IDALERT=$M{id_alert}");

	#$self->remove_mdata_alert_file($desc);
}


#----------------------------------------------------------------------------
# remove_mdata_alert_file
# IN: $desc
#----------------------------------------------------------------------------
sub remove_mdata_alert_file {
my ($self,$desc)=@_;



my $rrr=Dumper($desc);
$self->log('info',"remove_mdata_alert_file:: **DUMPER** desc=$rrr");


   # Hay que borrar el fichero de alerta del crawler
   # /opt/data/mdata/output/default/a/10.2.254.211/2.latency.49.w_mon_tcp-c6390dc6
   my $sev=$desc->{'severity'};
   my $type=$desc->{'type'};
   my $id_dev=$desc->{'id_dev'};
   my $ip=$desc->{'host_ip'};
   my $mname=$desc->{'name'};
	my $key=$id_dev.'.'.$mname;

	my $cid=$self->cid();
   my $f="$Crawler::MDATA_PATH/output/$cid/a/$ip/$sev\.$type\.$id_dev\.$mname";
   my $rc=0;
   if (-f $f) { $rc=unlink $f; }
	$self->log('info',"remove_mdata_alert_file:: key=$key FILE=$f (RC=$rc)");

}



#----------------------------------------------------------------------------
sub is_watch  {
my ($self,$a,$id_dev,$id_alert_type,$monitor,$watch_multi,$severity)=@_;


   # WATCHES ----------------------------------------------------------------
   # Para determinar si hay que enviar aviso, se debe cumplir lo siguiente
   # 1. El dispositivo en alerta (alerts.id_dev) debe tener el aviso configurado(cfg_notif.id_dev)
   # 2. El alerts.id_alert_type>0 ==> Esto significa que es un watch
   # 3. El alerts.id_alert_type debe coincidir con el cfg_notif.alert_type
   # 4. El aviso no debe estar en estado terminado (NOTIF_LAST). Se chequea en $self->time2send($a,$mode)
	# 5. En el caso de que el watch (monitor) tenga definidas varias severidades, se valida que la
	#	  severidad de la alerta coincide con la del aviso configurado
   if (  ($a->[aDEVICE] eq $id_dev) && ($a->[aWATCH] ne '0') && ($a->[aWATCH] ne '') &&
         ($a->[aALERT_TYPE] eq $id_alert_type) ) {

				if (exists $watch_multi->{$monitor}) {
					if ($a->[aSEVERITY] != $severity) {
						$self->log('info',"is_watch:: WATCH_MULTI - NO ES MONITOR POR SEVERIDAD alerta=$a->[aSEVERITY]|aviso config=$severity monitor=$monitor >> 1.IDDEV=$a->[aDEVICE],$id_dev|2.WATCH=$a->[aWATCH],3.ALERT_TYPE=$a->[aALERT_TYPE],$id_alert_type|4.NOTIF=$a->[aNOTIF]");
						return 0;
					}
				}

            $self->log('info',"is_watch:: **ES MONITOR**=> 1.IDDEV=$a->[aDEVICE],$id_dev|2.WATCH=$a->[aWATCH],3.ALERT_TYPE=$a->[aALERT_TYPE],$id_alert_type|4.NOTIF=$a->[aNOTIF] monitor=$monitor");

            return 1;
   }

	return 0;
}

#----------------------------------------------------------------------------
sub is_latency  {
my ($self,$a,$id_dev,$monitor)=@_;

   # METRICAS TCP/IP -------------------------------------------------------
   # En este caso el campo monitor de cfg_notifications contiene el nombre de la metrica
   # Para determinar si hay que enviar aviso, se debe cumplir lo siguiente
   # 1. El dispositivo en alerta (alerts.id_dev) debe tener el aviso configurado(cfg_notif.id_dev)
   # 2. El alerts.mname (nombre de la metrica) debe coincidir con el cfg_notif.monitor
   # 3. El aviso no debe estar en estado terminado (NOTIF_LAST). Se chequea en $self->time2send($a,$mode)
   if (  ($a->[aDEVICE] eq $id_dev) &&  ($a->[aMNAME] eq $monitor) ) {

            $self->log('info',"is_latency:: **ES TCP/IP** POR METRICA=> DEV=$a->[aDEVICE],$id_dev|MNAME=$a->[aMNAME],$monitor|NOTIF=$a->[aNOTIF]");

            return 1;
   }
	return 0;
}


#----------------------------------------------------------------------------
sub is_remote  {
my ($self,$a,$id_dev,$monitor)=@_;

   if (! exists $a->[aID_METRIC]) { $a->[aID_METRIC]=0; }

   # ALERTAS REMOTAS
   if (  ($a->[aDEVICE] eq $id_dev) && ($a->[aID_METRIC] eq $monitor) ) {

            $self->log('info',"is_remote:: **ES ALERTA_REMOTA**=> DEV=$a->[aDEVICE],$id_dev|ID_METRIC=$a->[aID_METRIC],$monitor|NOTIF=$a->[aNOTIF]");

            return 1;
   }
	return 0;

}



#----------------------------------------------------------------------------
# is_aviso
# 	Esta funcion cheque si la alerta en cueation tiene aviso asociado o no
#	OUT:	1->Hay que enviar aviso  0-> No hay que enviar aviso
#  IN:
#   		$a elemento de @$ALERTS_SET
#        $n elemento de $CFG_NOTIF
#        $mode: set/clr
#
# $a:
#SELECT a.id_device,a.id_alert_type,t.cause,d.name,d.domain,d.ip,a.notif,a.id_alert,a.mname FROM alerts a, alert_type t, devices d, metrics m WHERE a.counter>0 and a.id_device=d.id_dev and a.id_device=m.id_dev and a.mname=m.name and m.watch=t.monitor
#

#id_device,id_alert_type,cause,name,domain,ip,notif,id_alert,mname,watch,event_data,ack,id_ticket,severity,type,date,counter,id_metric
#use constant aDEVICE => 0;
#use constant aALERT_TYPE=> 1;
#use constant aALERT_CAUSE=> 2;
#use constant aALERT_DEV_NAME=> 3;
#use constant aALERT_DEV_DOMAIN=> 4;
#use constant aALERT_DEV_IP=> 5;
#use constant aNOTIF=> 6;
#use constant aID_ALERT=> 7;
#use constant aMNAME=> 8;
#use constant aWATCH=> 9;
#use constant aEVENT_DATA=> 10;
#use constant aID_METRIC=> 17;

#
#SELECT c.id_cfg_notification,d.id_device,c.id_alert_type,c.id_notification_type,c.destino,c.name,c.monitor,c.type FROM cfg_notifications c,  cfg_notification2device d WHERE c.status=0 && c.id_cfg_notification=d.id_cfg_notification
#
# $n:
#SELECT c.id_cfg_notification,d.id_device,c.id_alert_type,r.id_notification_type,r.name,r.value,c.name,c.monitor,c.type from cfg_notifications c,  cfg_notification2device d, cfg_notification2transport t, cfg_register_transports r  where c.status=0 && c.id_cfg_notification=d.id_cfg_notification && c.id_cfg_notification=t.id_cfg_notification && t.id_register_transport=r.id_register_transport;
#use constant nID_CFG_NOTIF => 0;
#use constant nDEVICE => 1;
#use constant nALERT_TYPE=> 2;
#use constant nNOTIF_TYPE=> 3;
#use constant nDEST=> 4;
#use constant nDESCR=> 5;
#use constant nMONITOR=>6 ;
#use constant nTYPE=>7 ; # Tipo de notificacion (0 en SET/ 1 en SET y CLR)
#
#----------------------------------------------------------------------------
sub is_aviso  {
my ($self,$a,$n,$mode)=@_;


	# WATCHES ----------------------------------------------------------------
	# Para determinar si hay que enviar aviso, se debe cumplir lo siguiente
	# 1. El dispositivo en alerta (alerts.id_dev) debe tener el aviso configurado(cfg_notif.id_dev)
	# 2. El alerts.id_alert_type>0 ==> Esto significa que es un watch
	# 3. El alerts.id_alert_type debe coincidir con el cfg_notif.alert_type
	# 4. El aviso no debe estar en estado terminado (NOTIF_LAST). Se chequea en $self->time2send($a,$mode)
	#if (  ($a->[aDEVICE] eq $n->[nDEVICE]) && ($a->[aALERT_TYPE] > 0) &&
	if (  ($a->[aDEVICE] eq $n->[nDEVICE]) && ($a->[aWATCH] ne '0') && ($a->[aWATCH] ne '') &&
         ($a->[aALERT_TYPE] eq $n->[nALERT_TYPE]) && ($self->time2send($a,$n,$mode)) ) {

				$self->log('info',"is_aviso::AVISO POR MONITOR=> 1.IDDEV=$a->[aDEVICE],$n->[nDEVICE]|2.WATCH=$a->[aWATCH],3.ALERT_TYPE=$a->[aALERT_TYPE],$n->[nALERT_TYPE]|4.NOTIF=$a->[aNOTIF] (DEST=$n->[nDEST])");

				return 1;
	}


	# METRICAS TCP/IP -------------------------------------------------------
	# En este caso el campo monitor de cfg_notifications contiene el nombre de la metrica
   # Para determinar si hay que enviar aviso, se debe cumplir lo siguiente
   # 1. El dispositivo en alerta (alerts.id_dev) debe tener el aviso configurado(cfg_notif.id_dev)
   # 2. El alerts.mname (nombre de la metrica) debe coincidir con el cfg_notif.monitor
   # 3. El aviso no debe estar en estado terminado (NOTIF_LAST). Se chequea en $self->time2send($a,$mode)
   elsif (  ($a->[aDEVICE] eq $n->[nDEVICE]) &&
         ($a->[aMNAME] eq $n->[nMONITOR]) && ($self->time2send($a,$n,$mode)) ) {

				$self->log('info',"is_aviso::AVISO POR METRICA=> DEV=$a->[aDEVICE],$n->[nDEVICE]|MNAME=$a->[aMNAME],$n->[nMONITOR]|NOTIF=$a->[aNOTIF] (DEST=$n->[nDEST])");

            return 1;
   }

	# ALERTAS REMOTAS
   elsif (  ($a->[aDEVICE] eq $n->[nDEVICE]) &&
         ($a->[aID_METRIC] eq $n->[nMONITOR]) && ($self->time2send($a,$n,$mode)) ) {

            $self->log('info',"is_aviso::AVISO POR ALERTA_REMOTA=> DEV=$a->[aDEVICE],$n->[nDEVICE]|ID_METRIC=$a->[aID_METRIC],$n->[nMONITOR]|NOTIF=$a->[aNOTIF] (DEST=$n->[nDEST])");

            return 1;
   }


	# Solo para debug
	else {
   	$self->log('debug',"is_aviso::[DEBUG] AVISO POR MONITOR=>NO 1.IDDEV=$a->[aDEVICE],$n->[nDEVICE]|2.WATCH=$a->[aWATCH],3.ALERT_TYPE=$a->[aALERT_TYPE],$n->[nALERT_TYPE]|4.NOTIF=$a->[aNOTIF] (DEST=$n->[nDEST])");
		$self->log('debug',"is_aviso::[DEBUG] AVISO POR METRICA=>NO DEV=$a->[aDEVICE],$n->[nDEVICE]|MNAME=$a->[aMNAME],$n->[nMONITOR]|NOTIF=$a->[aNOTIF] (DEST=$n->[nDEST])");
	}


#$self->log('info',"is_aviso::**DEBUG**AVISO POR ALERTA_REMOTA=> DEV=$a->[aDEVICE],$n->[nDEVICE]|ID_METRIC=$a->[aID_METRIC],$n->[nMONITOR]|NOTIF=$a->[aNOTIF] (DEST=$n->[nDEST])");



	return 0;

}


#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#$self->set_aviso($dbh,$a,$CFG_POST->{$id},'set',\%response);
#----------------------------------------------------------------------------
#GENERADA ALERTA : IDX < 30
#DISPOSITIVO = cnm-areas.localdomain
#IP = 192.168.57.9
#EVENTO = Ejecutado script: linux_metric_ssh_files_in_dir.pl (RC=0) RCSTR=[OK] Metrica: FICHEROS IDX
#v1:  Num. Ficheros = 15
#**ALERTA (v1<30) (15 < 30)**
#
#El informe sobre el incidente esta disponible en:
#
#https://192.168.57.9/onm/mod_alertas_dashboard_simple.php?id=64699
#
#
#(Mensaje generado automaticamente. Por favor no responda)
#
#----------------------------------------------------------------------------
sub compose_notification_body  {
my ($self,$set_clr,$url,$a,$notif_info)=@_;
my $DEFAULT_BODY = '
__SET_CLR_ALERT__ : __ALERT_CAUSE__
DATE = __DATE__
DISPOSITIVO = __DEVICE__
IP = __IP__
EVENTO = __EVENT_DATA__

__URL__

(Mensaje generado automaticamente. Por favor no responda)
';

	my $txt = $DEFAULT_BODY;
	if ($notif_info->{'template'} ne '') { $txt = $notif_info->{'template'}; }

	my $id_dev_alert=$a->[aDEVICE];    #id del device
   my $device=$a->[aALERT_DEV_NAME].'.'.$a->[aALERT_DEV_DOMAIN];
   my $ip=$a->[aALERT_DEV_IP];
   my $alert_cause=$a->[aALERT_CAUSE];	# alert cause
   my $id_alert=$a->[aID_ALERT];			# id de la alerta
   my $event_data=$a->[aEVENT_DATA] || ''; 	# Datos del evento
   if ($event_data ne '') { $event_data=~s/ \| /\n/g; }
	my $ack = $a->[aACK];					# ack 
	my $id_ticket = $a->[aID_TICKET];	# id ticket
	my $severity = $a->[aSEVERITY];		# severity
	my $date_str = $self->time2date($a->[aDATE]);	# alert date
	my $id_metric = $a->[aID_METRIC];	# id de la metrica
	my $alert_type = $a->[aALERT_TYPE];	# alert type
	my $notif = $a->[aNOTIF];				# notif flag
	my $mname = $a->[aMNAME];				# metric name
	my $watch = $a->[aWATCH];				# watch
	my $type = $a->[aTYPE];					# type
	my $counter = $a->[aCOUNTER];			# alert counter

	# ------------------------------------------------------------
	$txt =~s/__EMPTY__//g;
	$txt =~s/__SET_CLR_ALERT__/$set_clr/g;
	$txt =~s/__ALERT_CAUSE__/$alert_cause/g;
	$txt =~s/__DEVICE__/$device/g;
	$txt =~s/__IP__/$ip/g;
	# OJO!! El evento puede tener caracteres html que no sean parseables por Telegram (ej. <br>)
	# Hay que valorar si para este caso $event_data=''
	$txt =~s/__EVENT_DATA__/$event_data/g;

	my $dbh=$self->dbh();
	my $store=$self->store();
	my $attr = $store->get_device_attributes($dbh,$id_dev_alert);
	foreach my $k (keys %{$attr}) {
		my $value = $attr->{$k};
		$txt =~s/$k/$value/g;
	}

	if ($alert_type == TRAP_ALERT_TYPE) { 
		my $x='Alarma generada por un eqipo remoto, no se dispone de grafica asociada.';
		$txt =~s/__URL__/$x/g;
	}
	else {
		$txt =~s/__URL__/$url/g;
	}
	$txt =~s/__DATE__/$date_str/g;
	#$txt =~///;

	return $txt;
}

#----------------------------------------------------------------------------
sub compose_notification_subject  {
my ($self,$mode,$a,$notif_info)=@_;

	my $subject = '';
	my $cfg = $self->cfg();

   my $id_dev_alert=$a->[aDEVICE];    #id del device
   my $device=$a->[aALERT_DEV_NAME].'.'.$a->[aALERT_DEV_DOMAIN];
   my $ip=$a->[aALERT_DEV_IP];
   my $alert_cause=$a->[aALERT_CAUSE]; # alert cause
   my $id_alert=$a->[aID_ALERT];       # id de la alerta
   my $event_data=$a->[aEVENT_DATA] || '';   # Datos del evento
   if ($event_data ne '') { $event_data=~s/ \| /\n/g; }
   my $ack = $a->[aACK];               # ack
   my $id_ticket = $a->[aID_TICKET];   # id ticket
   my $severity = $a->[aSEVERITY];     # severity
   my $date_str = $self->time2date($a->[aDATE]);   # alert date
   my $id_metric = $a->[aID_METRIC];   # id de la metrica
   my $alert_type = $a->[aALERT_TYPE]; # alert type
   my $notif = $a->[aNOTIF];           # notif flag
   my $mname = $a->[aMNAME];           # metric name
   my $watch = $a->[aWATCH];           # watch
   my $type = $a->[aTYPE];             # type
   my $counter = $a->[aCOUNTER];       # alert counter

   # ------------------------------------------------------------
	if ($notif_info->{'title_template'} ne '') { 

	   $subject = 'CNM [SET] ';
   	if ($mode ne 'set') { $subject = 'CNM [CLEAR] '; }

		$subject .= $notif_info->{'title_template'}; 
		$subject =~ s/__ALERT_CAUSE__/$alert_cause/g;
		$subject =~s/__DEVICE__/$device/g;
		$subject =~s/__IP__/$ip/g;
	}
	else {

	   my $set_clr='GENERADA ALERTA';
   	if ($mode ne 'set') { $set_clr='ELIMINADA ALERTA'; }

	   my $msg_full = $notif_info->{'nname'}.' '."[$device - $ip]".' **'.$set_clr.'**';
   	$subject = $cfg->{notif_subject}->[0].' '.$msg_full;
	}
	return $subject;

}

#----------------------------------------------------------------------------
sub set_aviso   {
my ($self,$dbh,$a,$notif_info,$mode,$response)=@_;

   my $store=$self->store();
	my ($rc,$rcstr,$descr)=(0,'UNK','');

	my ($id_dev,$notif_type,$notif_descr, $dest, $id_cfg_notif) = 
		($notif_info->{'id_dev'}, $notif_info->{'id_notification_type'}, $notif_info->{'nname'}, $notif_info->{'dest'}, $notif_info->{'id_cfg_notification'} );

   my $device=$a->[aALERT_DEV_NAME].'.'.$a->[aALERT_DEV_DOMAIN];
   my $ip=$a->[aALERT_DEV_IP];
   my $alert_cause=$a->[aALERT_CAUSE];
   my $event_data=$a->[aEVENT_DATA] || '';
   my $id_alert=$a->[aID_ALERT];

   my $transport=$self->transport();
   my $cfg = $self->cfg();

	my $set_clr='GENERADA ALERTA';
	if ($mode ne 'set') { $set_clr='ELIMINADA ALERTA'; }

   my $msg_full = "$notif_descr [$device - $ip]".' **'.$set_clr.'**';

   my $url='';
   foreach my $u (@{$cfg->{'www_server_url'}}) {
      $url .= $u.'/mod_alertas_dashboard_simple.php?id='.$a->[aID_ALERT]."\n";
   }
   if ($url eq '') { $url='https://'.$self->cid_ip().'/onm/mod_alertas_dashboard_simple.php?id='.$a->[aID_ALERT]."\n"; }

   my $SUBJECT = $self->compose_notification_subject($mode,$a,$notif_info);
   $transport->subject($SUBJECT);

	$self->log('info',"set_aviso:: id_dev=$id_dev, notif_type=$notif_type, notif_descr=$notif_descr, dest=$dest, id_cfg_notif=$id_cfg_notif, url=$url");

	#--------------------------------------------------------------------------------
   if ($notif_type == $Crawler::Transport::NOTIF_EMAIL) {

		my $txt = $self->compose_notification_body($set_clr,$url,$a,$notif_info);
      $transport->notify_by_transport($notif_type, {'dest'=>$dest, 'subject'=>$SUBJECT, 'txt'=>$txt});

		$msg_full.=" $alert_cause";
      $rcstr=$msg_full.'<br>'.$transport->err_str();
      $rc=$transport->err_num();
		$descr="AVISO POR EMAIL a $dest";
      $self->log('info',"set_aviso::AVISO=> **EMAIL** $id_cfg_notif, $rcstr, MSG=$msg_full || $id_alert");
      $store->store_notification($dbh, {id_cfg_notification=>$id_cfg_notif, rc=>$rcstr, msg=>$msg_full, id_dev=>$id_dev });
      $store->log_qactions($dbh, {'descr'=>$descr , 'rc'=>$rc  , 'rcstr'=>$rcstr , 'id_dev'=>$id_dev, 'atype'=>ATYPE_NOTIF_BY_EMAIL });

      $AVISOS +=1;
   }

   #--------------------------------------------------------------------------------
   elsif ($notif_type == $Crawler::Transport::NOTIF_TELEGRAM) {

      my $txt ="**$set_clr** <b>$alert_cause</b> en <b>$device</b> [<b>$ip</b>] ";
		# OJO!! El evento no se debe incluir porque puede tener caracteres html (caso email p.ej) que 
		# no sean parseables por Telegram (ej. <br>)
      $txt .="\nEl informe sobre el incidente esta disponible en:\n\n$url\n\n";


		# dest es del tipo:
		# {"first_name":"Pre","last_name":"Pago","chat_id":300239085}
		# Decodifico el json para obtener el chat_id
		my $tgdata = { 'chat_id'=>'' };
	   eval { $tgdata = decode_json($dest); };
   	if ($@) {
      	$self->log('warning',"set_aviso:: **ERROR** en decode_json ($@) DEST=$dest");
			$rcstr = "ERROR EN DATOS DE DESTINO ($@)";
			$rc=1;
   	}
		else {
	
	      $transport->notify_by_transport($notif_type, {'dest'=>$tgdata->{'chat_id'}, 'subject'=>$SUBJECT, 'txt'=>$txt});

   	   $rcstr=$msg_full.'<br>'.$transport->err_str();
      	$rc=$transport->err_num();
		}

      $descr="AVISO POR TELEGRAM a $dest";
      $self->log('info',"set_aviso::AVISO=> **TELEGRAM** $id_cfg_notif, $rcstr, MSG=$msg_full || $id_alert");
      $store->store_notification($dbh, {id_cfg_notification=>$id_cfg_notif, rc=>$rcstr, msg=>$msg_full, id_dev=>$id_dev });
      $store->log_qactions($dbh, {'descr'=>$descr , 'rc'=>$rc  , 'rcstr'=>$rcstr , 'id_dev'=>$id_dev, 'atype'=>ATYPE_NOTIF_BY_TELEGRAM});
      $AVISOS +=1;
   }


	#--------------------------------------------------------------------------------
   elsif ($notif_type == $Crawler::Transport::NOTIF_SMS) {

		#$SUBJECT .= " $alert_cause - $event_data";

		use bytes;
  		my $octets = length($SUBJECT); 
		if ($octets > 140) { 
			$self->log('warning',"set_aviso:: TRUNCATE SUBJECT ($octets) $SUBJECT");
			$SUBJECT = substr $SUBJECT,0,140; 
		}

      $transport->notify_by_transport($notif_type, {'dest'=>$dest, 'subject'=>$SUBJECT, 'txt'=>$SUBJECT});

      $rcstr=$msg_full.'<br>'.$transport->err_str();
      $rc=$transport->err_num();
		$descr="AVISO POR SMS a $dest";
      $self->log('info',"set_aviso::AVISO=> **SMS** $id_cfg_notif, $rcstr, MSG=$msg_full || $id_alert");
      $store->store_notification($dbh, {id_cfg_notification=>$id_cfg_notif, rc=>$rcstr, msg=>$msg_full, id_dev=>$id_dev });
      $store->log_qactions($dbh, {'descr'=>$descr , 'rc'=>$rc  , 'rcstr'=>$rcstr , 'id_dev'=>$id_dev, 'atype'=>ATYPE_NOTIF_BY_SMS});
      $AVISOS +=1;
   }
	#--------------------------------------------------------------------------------
   elsif ($notif_type == $Crawler::Transport::NOTIF_TRAP) {
      $transport->notify_by_transport($notif_type, {'dest'=>$dest, 'subject'=>$SUBJECT, 'txt'=>$msg_full});

      $rcstr=$msg_full.'<br>'.$transport->err_str();
      $rc=$transport->err_num();
		$descr="AVISO POR SNMP-TRAP a $dest";
      $store->store_notification($dbh, {id_cfg_notification=>$id_cfg_notif, rc=>$rcstr, msg=>$msg_full, id_dev=>$id_dev });
      $store->log_qactions($dbh, {'descr'=>$descr , 'rc'=>$rc  , 'rcstr'=>$rcstr , 'id_dev'=>$id_dev, 'atype'=>ATYPE_NOTIF_BY_TRAP});
      $AVISOS +=1;
   }
   else {
      $self->log('warning',"set_aviso::[WARN] Aviso desconocido ($notif_type) DEV=$device|ALERT=$alert_cause");
   }

	$response->{'rc'} = $rc; 
	$response->{'rcstr'} = $rcstr;
	$response->{'descr'} = $descr;
 
}


#----------------------------------------------------------------------------
# time2send
# RC: 0 => No hay que enviar aviso
#    	NOTIF_1 .... NOTIF_LAST => En caso de que haya que mandar aviso
#----------------------------------------------------------------------------
sub time2send  {
my ($self, $a, $n, $mode)=@_;

	if ( ($mode eq 'set') && ($a->[aNOTIF] != NOTIF_LAST) ) {
		return 1;
	}
	elsif ( ($mode eq 'clr') && ($n->[nTYPE]==1) && ($a->[aNOTIF] != NOTIF_LAST_CLR) ) {
		return 1;
	}

	return 0;
}


#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# chk_integrity
#----------------------------------------------------------------------------
#
# 	Chequea la integridad de la tabla alerts.
#	1. Elimina las alertas de metricas que no existen o dispositivos que no existen.
#
#	SELECT * FROM alerts where id_device not in (SELECT a.id_device from alerts a, devices d, metrics m where d.id_dev = a.id_device and m.name = a.mname);
#	DELETE FROM alerts where id_device not in (SELECT a.id_device from alerts a, devices d, metrics m where d.id_dev = a.id_device and m.name = a.mname);
#
#	2. Elimina las alertas de metricas de  dispositivos no activos (baja/mantenimiento).
#
#  DELETE FROM alerts where id_device in (SELECT id_dev from devices where status != 0);
#
#	3.  Elimina las alertas de metricas no activas
#	DELETE FROM alerts where id_alert in (SELECT a.id_alert from metrics m, alerts a where a.id_device=m.id_dev and a.mname=m.name and   m.status !=0)
#	4. Elimina las alertas azules de dispositivos sin respuesta snmp
#
#	5. Elimina las alertas de dispositivos sin respuesta snmp que no tengan metricas snmp
#----------------------------------------------------------------------------
sub chk_integrity  {
my ($self,$dbh)=@_;

   my $store=$self->store();
	my $table='alerts';
	my $cid=$self->cid();
	my $where;
	my ($c1,$c2,$c3,$c4,$c5,$c6)=(0,0,0,0,0,0);

	#-1----------------------------------------------
	#DISPOSITIVOS ELIMINADOS Y ALERTAS REMOTAS
	#DISPOSITIVOS ELIMINADOS Y SIN RESPUESTA ICMP,SNMP,XAGENT,WBEM
   #-1----------------------------------------------
#mysql> SELECT a.id_device as id1,ifnull(d.id_dev,0) as id2,a.id_alert FROM alerts a, devices d WHERE d.id_dev = a.id_device and (a.mname in ('mon_icmp','mon_snmp','mon_wbem','mon_xagent') or a.type  in ('snmp-trap','email','syslog'));
#+-----+-----+----------+
#| id1 | id2 | id_alert |
#+-----+-----+----------+
#|   3 |   3 |   454118 |
#| 333 |   0 |    69510 |
#+-----------+----+-----+

   my $res=$store->get_from_db( $dbh, 'a.id_device as id1,ifnull(d.id_dev,0) as id2,a.id_alert', 'alerts a, devices d', "a.cid=\'$cid\' and d.id_dev = a.id_device and (a.mname in (\'mon_icmp\',\'mon_snmp\',\'mon_wbem\',\'mon_xagent\') or a.type  in (\'snmp-trap\',\'email\',\'syslog\',\'api\'))", '' );
   my @rnok=();
   foreach my $v (@$res) {
      if ($v->[0] != $v->[1]) { push @rnok, $v->[2]; }
   }

   if (scalar @rnok) {
      my $range = join (',',@rnok);

      $c1=$store->delete_from_db($dbh,$table,"id_alert in ($range)");

	   my $e1=$store->error();
   	if ($e1) {
      	my $e = "ERROR=($e1) ".$store->errorstr().'  ('.$store->lastcmd().' )';
      	$self->log('warning',"chk_integrity::[WARN] $e");
   	}
		else {
			$self->log('info',"chk_integrity:: DISPOSITIVOS ELIMINADOS ($c1) >> **DEL** id_alert in ($range)");
		}
   }

#192.168.55.121.2.latency.307.w_mon_pop3-7cea78fe
#ip.sev.type.id_dev.mname

	$self->log('debug',"chk_integrity:: step1 c1=$c1");

   #-1----------------------------------------------
   #METRICAS ELIMINADAS
   #-1----------------------------------------------
	my @rok=();
	my $num_ok=0;

	#Almaceno en @rok el id_alert de las METRICAS OK con relacion 1->1 alertas-metricas mediante mname
	# SELECT a.id_alert FROM alerts a, metrics m WHERE a.cid='default' and m.id_dev=a.id_device and m.name=a.mname and a.mname != "mon_icmp";
   $res=$store->get_from_db( $dbh, 'a.id_alert', 'alerts a, metrics m', "a.cid=\'$cid\' and m.id_dev=a.id_device and m.name=a.mname and a.mname != \'mon_icmp\'", '' );
	my $e1=$store->error();
	if ($e1) {
		my $e = "ERROR=($e1) ".$store->errorstr().'  ('.$store->lastcmd().' )';
		$self->log('warning',"chk_integrity::[WARN] $e");
	}
   foreach my $v (@$res) { push @rok, $v->[0]; }

	#Almaceno en @rok el id_alert de las METRICAS OK sin relacion 1->1 alertas-metricas (alertas remotas o especiales: mon_snmp, mon_xagent...)
	#Se contempla tambien mon_icmp porque se sumariza disp_icmp y mon_icmp al generar la alerta.
   $res=$store->get_from_db( $dbh, 'distinct(a.id_alert)', 'alerts a, metrics m', "a.cid=\'$cid\' and m.id_dev = a.id_device and a.mname in (\'mon_icmp\',\'mon_snmp\',\'mon_wbem\',\'mon_xagent\')", '' );
   my $e2=$store->error();
   if ($e2) {
      my $e = "ERROR=($e2) ".$store->errorstr().'  ('.$store->lastcmd().' )';
      $self->log('warning',"chk_integrity::[WARN] $e");
   }
   foreach my $v (@$res) { push @rok, $v->[0]; }


   $res=$store->get_from_db( $dbh, 'distinct(a.id_alert)', 'alerts a, metrics m', "a.cid=\'$cid\' and m.id_dev = a.id_device and a.type in (\'snmp-trap\',\'email\',\'syslog\',\'api\')", '' );
   my $e3=$store->error();
   if ($e3) {
      my $e = "ERROR=($e3) ".$store->errorstr().'  ('.$store->lastcmd().' )';
      $self->log('warning',"chk_integrity::[WARN] $e");
   }
   foreach my $v (@$res) { push @rok, $v->[0]; }

	#Se eliminan las alertas de alerts que no esten en @rok
	$num_ok=scalar(@rok);
	if ( (!$e1) && (!$e2) && (!$e3) && ($num_ok>0) ) {
	   my $range = join (',',@rok);

$self->log('info',"chk_integrity::  RANGO OK NUM=$num_ok  cid=$cid");
$self->log('debug',"chk_integrity::  RANGO OK ($range) cid=$cid");

		#  SELECT a.ip,a.severity,a.type,a.id_device,a.mname' FROM alerts a WHERE a.cid='default' and id_alert not in ();
  		$res=$store->get_from_db( $dbh, 'a.ip,a.severity,a.type,a.id_device,a.mname', 'alerts a', "a.cid=\'$cid\' and id_alert not in ($range)");
		#Nombre de los ficheros: ip.sev.type.id_dev.mname
		my @mdata_files=();
		foreach my $v (@$res) { push @mdata_files, join('.',@$v);  }

		$c2=$store->delete_from_db($dbh,$table,"cid=\'$cid\' and id_alert not in ($range)");
		if ($c2>0) {
			$self->log('info',"chk_integrity:: METRICAS ELIMINADAS($c2)  >> **DEL** id_alert not in ($range) cid=$cid");
	      foreach my $f (@mdata_files) {
  			   my $falert="$Crawler::MDATA_PATH/output/$cid/a/$f";
     	   	my $rc=unlink($falert);
        		$self->log('info',"chk_integrity:: FILE METRIC DELETED => falert=$falert rc=$rc");
     		}
		}
	}

	$self->log('debug',"chk_integrity:: step2 c2=$c2");
	#-2----------------------------------------------
	# DISPOSITIVOS EXISTENTES Y NO ACTIVOS
   #-2----------------------------------------------
	#SELECT a.id_device FROM alerts a, devices d WHERE a.id_device=d.id_dev and d.status != 0;
	$res=$store->get_from_db( $dbh,'a.id_device,d.ip','alerts a, devices d',"a.cid=\'$cid\' and a.id_device=d.id_dev and d.status != 0",'');
	my @r=();

	my %disp_not_active=(); #id_dev->ip
	my $do=0;
	foreach my $v (@$res) {
		$disp_not_active{$v->[0]}=$v->[1];
		$do=1;
	}
 	my $range = join (',',keys %disp_not_active);

	if ($do) {
		$c3=$store->delete_from_db($dbh,$table,"id_device in ($range)");
  		$e1=$store->error();
   	if ($e1) {
      	my $e = "ERROR=($e1) ".$store->errorstr().'  ('.$store->lastcmd().' )';
      	$self->log('warning',"chk_integrity::[WARN] $e");
   	}
		else {
			$self->log('info',"chk_integrity:: DISPOSITIVOS NO ACTIVOS ($c3) >> **DEL** id_device in ($range)");
		}
	
  		foreach my $ip (values %disp_not_active) {
			my $falert="$Crawler::MDATA_PATH/output/$cid/a/$ip*";
			my $rc=unlink glob($falert);
     		$self->log('info',"chk_integrity:: FILE DEVICE STATUS NO ACTIVE => ip=$ip falert=$falert rc=$rc");
   	}
	}

	$self->log('debug',"chk_integrity:: step3 c3=$c3");
	#-3----------------------------------------------
	# METRICAS EXISTENTES Y NO ACTIVAS
	#-3----------------------------------------------
	# SELECT a.id_alert,d.ip,a.severity,a.type,a.id_device,m.name FROM metrics m, alerts a, devices d WHERE a.id_device=m.id_dev and a.mname=m.name and d.id_dev=a.id_device and  m.status !=0

   $res=$store->get_from_db( $dbh, 'a.id_alert,d.ip,a.severity,a.type,a.id_device,m.name', 'metrics m, alerts a, devices d', 'a.cid=\'$cid\' and a.id_device=m.id_dev and a.mname=m.name and d.id_dev=a.id_device and  m.status !=0', '' );
   @r=();
   foreach my $v (@$res) { 
		push @r, $v->[0]; 
		#Tambien se elimina el fichero de mdata
		#213.186.47.112.2.latency.34.w_mon_imap-e3c9525b
		#ip.type.id_dev.mname
		my $falert="$Crawler::MDATA_PATH/output/$cid/a/".$v->[1].'.*.'.$v->[3].'.'.$v->[4].'.'.$v->[5];
		my $rc=unlink glob($falert); 
		$self->log('info',"chk_integrity:: METRIC STATUS NO ACTIVE => id_alert=$v->[0] falert=$falert rc=$rc");
	}
   $range = join (',',@r);

	if (scalar @r) {
	   $c4=$store->delete_from_db($dbh,$table,"id_alert in ($range)");
	   my $e1=$store->error();
   	if ($e1) {
      	my $e = "ERROR=($e1) ".$store->errorstr().'  ('.$store->lastcmd().' )';
      	$self->log('warning',"chk_integrity::[WARN] $e");
   	}
		else {
			$self->log('info',"chk_integrity:: METRICAS NO ACTIVAS ($c4) >> **DEL** id_alert in ($range)");
		}
	}


	$self->log('debug',"chk_integrity:: step4 c4=$c4");
	#------------------------------------------------
	# Obtengo datos de las alertas de SIN RESPUESTA SNMP
   $res=$store->get_from_db( $dbh,'ip,id_device,id_alert','alerts',"mname=\'mon_snmp\' and counter>0");
   my @ips=();
   my %iddev2alert=();
   foreach my $a (@$res) {
      push @ips,"\'".$a->[0]."\'";
      $iddev2alert{$a->[1]} = $a->[2];
   }

	$self->log('debug',"chk_integrity:: step5 c5=$c5");
   #-4----------------------------------------------
   # ALERTAS AZULES DE DISPOSITIVOS SIN RESPUESTA SNMP
   #------------------------------------------------
   if (scalar(@ips)>0) {
      my $condition = 'severity=4 and type=' . "\'snmp\'"  . 'and ip in (' . join (',',@ips) . ')';
      $c5=$store->delete_from_db( $dbh,$table,$condition);
		if ($c5>0) {
			$self->log('info',"chk_integrity:: ELIMINADAS ALERTAS AZULES DE DISPOSITIVOS SIN RESPUESTA SNMP ($c5) >> **DEL** $condition");
		}


	   #-5----------------------------------------------
   	# ALERTAS DE SIN RESPUESTA SNMP DE DISPOSITIVOS SIN METRICAS SNMP
   	#------------------------------------------------

      my $iddevs = join ',', keys %iddev2alert;
		# Esta consulta solo devuelve los id_devs de metrics con metricas de tipo snmp 
      $res=$store->get_from_db( $dbh,'id_dev','metrics',"id_dev in ($iddevs) and type=\'snmp\' and status=0 group by id_dev");
		foreach my $a (@$res) { delete $iddev2alert{$a->[0]}; }
		if (scalar(keys %iddev2alert)>0) {
			my $condition = 'id_alert in (' . join (',', values(%iddev2alert)) . ')';
			$c6=$store->delete_from_db( $dbh,$table,$condition);
	      if ($c6>0) {
   	      $self->log('info',"chk_integrity:: ELIMINADAS ALERTAS DE SIN RESPUESTA SNMP DE DISPOSITIVOS SIN METRICAS SNMP ($c6) >> **DEL** $condition");
      	}
		}
	}

	$self->log('info',"chk_integrity:: step6 c1=$c1 c2=$c2 c3=$c3 c4=$c4 c5=$c5 c6=$c6");

}


1;
__END__

