#-------------------------------------------------------------------------------------------
# Fichero: Crawler/LogManager/Syslog.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
package Crawler::LogManager::Syslog;
use Crawler::LogManager;
@ISA=qw(Crawler::LogManager);
use strict;
use Digest::MD5 qw(md5_hex);
use Data::Dumper;


#------------------------------------------------------------------------------------------
# line_processor
# Hace un procesado completo de una linea de syslog
#------------------------------------------------------------------------------------------
sub line_processor {
my ($self,$line)=@_;

   eval {

      my $store=$self->store();
      $self->connect();

      # Reviso si hay que recargar la tabla de syslog -> alertas --------------------------------
      my $reload_file=$self->reload_file();
      if (-f $reload_file) {
         $self->check_configuration();
      }

      chomp $line;
      if (! $self->check_event($line)) { next; }

      # Gestiono la posible alerta --------------------------------------------------------------
      $self->check_alert();

      $self->disconnect();
   };

   if ($@) { $self->log('warning',"[ERROR] EN BUCLE DE CONTROL ($@)");  }
}


#------------------------------------------------------------------------------------------
# line_processor_vector
# Hace un procesado completo de un bloque de lineas de syslog
# La carga de la configuracion es externa al bucle
#------------------------------------------------------------------------------------------
sub line_processor_vector {
my ($self,$line_vector,$msg)=@_;

   eval {

      my $store=$self->store();
      $self->connect();

		foreach my $line (@$line_vector) {

	      chomp $line;
   	   #if (! $self->check_event($line,$ip)) { next; }

			#------------------------------------------------
			# Incluyo la linea en los datos del evento 
			#------------------------------------------------
			$msg->{'msg'}=$line;
   		$self->event($msg);

      	# Gestiono la posible alerta 
      	$self->check_alert();
		}

     	$self->disconnect();

   };

   if ($@) { $self->log('warning',"[ERROR] EN BUCLE DE CONTROL ($@)");  }
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
# check_event
# 1. Parsea la linea de syslog
# 2. Almacena el evento correspondiente
# OUT: 1 (Ha almacenado evento) | 0 (No ha almacenado evento)
#------------------------------------------------------------------------------------------
sub check_event {
my ($self,$line,$ip) = @_;

   my %MSG=();
	$self->event(\%MSG);
   my $store=$self->store();
   my $dbh=$self->dbh();
	my $tag=$self->tag();

#Apr 16 19:50:22 10.2.254.71 TermServDevices: 1111: No se conoce el controlador Bullzip PDF Printer requerido para la impresora Bullzip PDF Printer. P▒ngase en contacto con el administrador para instalar el controlador antes de volver a iniciar.
#Apr 18 13:20:02 cnm-devel2 CRON[6165]: (pam_unix) session opened for user root by (uid=0)
#Apr 18 05:28:29 cnm-devel2 [crawler.4000.snmp.300][2710]: do_task::[DEBUG] *** TAREA=10.2.254.69-pkts_type_mibii_if-1 (mod_snmp_get) public 2 ifInUcastPkts_ifInNUcastPkts_ifOutUcastPkts_ifOutNUcastPkts WATCH=0 (/opt/crawler/bin/Crawler/SNMP.pm 579)

   $self->log('info',"check_event::[DEBUG] START tag=$tag line=$line");

	$MSG{'source_line'}=$line;

	# Viene de syslog remoto (via syslog-ng) y lo recibe log_manager
	# R[10.64.100.42] Jun 14 10:30:27 sliromrtg1 probando
	# --------------------------------------------------------------------------------------
	if ($line =~ /^R\[(\d+\.\d+\.\d+\.\d+)\]\s+(\S+\s+\d+\s+\d+\:\d+\:\d+)\s+(\S+)\s+(.+)$/) {
      $MSG{'ip'}=$1;
      $MSG{'date'}=$2;
      $MSG{'host'}=$3;
      $MSG{'daemon'}='-';
      #$MSG{'source_line'} = substr $line,1;
      $MSG{'source_line'} = "$2 $3 $4";

   $self->log('info',"check_event::[DEBUG] START $MSG{'ip'} - $MSG{'date'} - $MSG{'host'}");
      my $condition='ip="'.$MSG{'ip'}.'"';
      my $rv=$store->get_from_db($dbh,'name,domain','devices',$condition);
      if ((defined $rv) && exists ($rv->[0][0])){
         $MSG{'name'}=$rv->[0][0];
         $MSG{'domain'}=$rv->[0][1];
      }
      else {
         my $all_ips = $store->get_all_stored_device_ips($dbh);
         if (exists $all_ips->{$MSG{'ip'}}) {
            #Cambio la ip recibida por la ip definida en BBDD
            $MSG{'ip'} = $all_ips->{$MSG{'ip'}};
            $condition='ip="'.$MSG{'ip'}.'"';
            $rv=$store->get_from_db($dbh,'name,domain','devices',$condition);
            if ((defined $rv) && exists ($rv->[0][0])){
               $MSG{'name'}=$rv->[0][0];
               $MSG{'domain'}=$rv->[0][1];
            }
         }
      }
   }

	# log_pull
	# --------------------------------------------------------------------------------------
	else {
	# win32 eventviewer
#	if ($line =~ /^(\w+\s+\d+\s+\d+\:\d+\:\d+)\s+(\S+)\s+(\S+\:\s+\d+)\:\s+(.+)$/) {
		if ($line =~ /^(\S+\s+\d+\:\d+\:\d+)\s+(\S+)\s+\[(.+)\]\s+(.+)$/) {

			$MSG{'date'}=$1;
			$MSG{'host'}=$2;
			$MSG{'daemon'}=$3;
			#$MSG{'msg'}=$line;
		}
		# Unix like
   	elsif ($line =~ /^(\w+\s+\d+\s+\d+\:\d+\:\d+)\s+(\S+)\s+(\S+)\:\s+(.+)$/) {
      	$MSG{'date'}=$1;
      	$MSG{'host'}=$2;
      	$MSG{'daemon'}=$3;
      	#$MSG{'msg'}=$line;
   	}


#   	my $ip2name=$self->ip2name();

#          '10.2.254.223' => {
#                              'domain' => 's30labs.local',
#                              'status' => '0',
#                              'ip' => '10.2.254.223',
#                              'id_dev' => '5',
#                              'name' => 'cnm-devel2',
#                              'critic' => '25'
#                            },

		# IP, name, domain
		if (defined $ip) { $MSG{'host'} = $ip; }

		if ($MSG{'host'} =~ /\d+\.\d+\.\d+\.\d+/) {
			$MSG{'ip'}=$MSG{'host'};
	      $MSG{'name'}='';
   	   $MSG{'domain'}='';

			my $condition='ip="'.$MSG{'ip'}.'"';
   		my $rv=$store->get_from_db($dbh,'name,domain','devices',$condition);
   		if (defined $rv) {
   			$MSG{'name'}=$rv->[0][0];
	   		$MSG{'domain'}=$rv->[0][1];
			}
		}
		else {
			$MSG{'name'}=$MSG{'host'};
			$MSG{'domain'}='';
			$MSG{'ip'}='';

	      my $condition='name="'.$MSG{'name'}.'"';
   	   my $rv=$store->get_from_db($dbh,'ip,domain','devices',$condition);
      	if (scalar(@$rv) > 0) {
	         $MSG{'ip'}=$rv->[0][0];
   	      $MSG{'domain'}=$rv->[0][1];
      	}
		}
	}

	$MSG{'proccess'}='SYSLOG';
	my $ip2name=$self->ip2name();
   $MSG{'id_dev'} = (exists $ip2name->{$MSG{'ip'}}->{'id_dev'}) ? $ip2name->{$MSG{'ip'}}->{'id_dev'} : 0;
   $MSG{'critic'} = (exists $ip2name->{$MSG{'ip'}}->{'critic'}) ? $ip2name->{$MSG{'ip'}}->{'critic'} : 50;

	# evkey
	my $m1=$MSG{'daemon'}.$MSG{'source_line'};
   my $evkey1=md5_hex($m1);
   #my $evkey=substr $evkey1,0,16;


   my $evkey = 'log_' . substr $evkey1,0,8;

	
	$MSG{'msg_custom'}='';
	$MSG{'msg'}='<b>v1 (Line):</b>&nbsp;&nbsp;'.$line;


	# Si no esta configurado, no guardo nada
	my $acls = $store->get_cfg_syslog_acls($dbh);
	my $logfile='syslog-'.$tag;
	my $k=$MSG{'ip'}.'.'.$logfile;

   if ((! exists $acls->{$k}) || (! $acls->{$k})) {
      $self->log('debug',"check_event:: NO HAGO STORE LOG NO CONFIGURADO $k >> IP=$MSG{'ip'}, msg=>$MSG{'msg'}, evkey=>$evkey");
      return 0;
   }

   # Almaceno el evento ---------------------------------------------------------------------
   my $t=time;
	# Almaceno en la tabla de log correspondiente
	my ($table,$cnt_lines) = $store->set_log_rx_lines($dbh,$MSG{'ip'},$MSG{'id_dev'},$logfile,'syslog',[{'ts'=>$t, 'line'=>$MSG{'source_line'}}]);

   if ($cnt_lines == 0) {
      $self->log('info',"check_event:: event exists - no alert checking - evkey=>$evkey");
      return 0;
   }
   else {
   	$self->log('info',"check_event:: STORE LOG ($table) date=>$t, code=>1, proccess=>$MSG{'proccess'}, msg=>$MSG{'msg'}, name=>$MSG{'name'}, domain=>$MSG{'domain'}, ip=>$MSG{'ip'}, evkey=>$evkey");
	}

	$self->event(\%MSG);

   return 1;

}


#------------------------------------------------------------------------------------------
# check_alert
# Comprueba si el evento recibido por syslog debe generar una alerta.
#------------------------------------------------------------------------------------------
sub check_alert {
my ($self)=@_;

   my $store=$self->store();
   my $dbh=$self->dbh();
	my $event=$self->event();

   #my $alert2expr=$store->get_remote_alert_expr_by_type($dbh,'syslog');
   #my $event2alert=$store->get_cfg_syslog_remote_alerts($dbh);

	my $alert2expr=$self->alert2expr();
	my $event2alert=$self->event2alert();

#my $kk1=Dumper($event2alert);
#$kk1=~s/\n/ /g;
#$self->log('debug',"event2alert:: Las alertas remotas tipo syslog definidas (email2alert) son: $kk1");

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


   #Para cada alerta de tipo email configurada (y asociada a algun dispositivo)
   #chequeo si el evento (amil) cumple sus expresiones
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
$self->log('info',"check_alert:: id_remote_alert=$id_remote_alert DUMPER=$kk");

      my $condition_ok=$self->watch_eval_ext($alert2expr->{$id_remote_alert},$expr_logic,\@vals);
		$self->log('info',"check_alert:: ALERTA $ev: **DEFINIDA** PARA $ip >> WATCH_EVAL_EXT=$condition_ok");

      if (! $condition_ok) {next; }

		my $date_last=time();
      my $critic=$event->{'critic'};

      my $msg_log=substr $msg,0,250;
      $msg_log=~s/\n/\. /g;

      #Alertas nuevas
      my $cfg_mode=$mode;
      $mode=$id_remote_alert;
      my $ts=time();
      if ($cfg_mode ne 'INC') { $mode .= '.'.$ts; }

      # Procesado de alertas. SET ---------------------------------------------------------------
      # store_mode: 0->Insert 1->Update
      if ( $action =~ /SET/i ) {
 			#my $alert_id=$store->store_alert($dbh,$monitor,{ 'ip'=>$ip, 'name'=>$name, 'domain'=>$domain, 'mname'=>$mname, 'severity'=>$severity, 'event_data'=>$msg, 'label'=>$label, 'cause'=>$label, 'type'=>$type, 'id_alert_type'=>20, 'id_metric'=>$id_metric, 'mode'=>$mode, 'subtype'=>$subtype, 'critic'=>$critic, 'date_last'=>$date_last, 'id_device'=>$id_device, 'notif'=>0 }, 1);
 			my $alert_id=$store->store_alert($dbh,$monitor,{ 'ip'=>$ip, 'name'=>$name, 'domain'=>$domain, 'mname'=>$mname, 'severity'=>$severity, 'event_data'=>$msg, 'label'=>$label, 'cause'=>$label, 'type'=>$type, 'id_alert_type'=>20, 'id_metric'=>$id_metric, 'mode'=>$mode, 'subtype'=>$subtype, 'critic'=>$critic, 'date_last'=>$date_last, 'id_device'=>$id_device }, 1);
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

         my $id_metric_clr=0;
         # Se borra la original a partir del set_id.  Si no existe set_id, lo busco a partir de subtype + hiid
         if (($set_id =~ /^\d+$/) && ($set_id>0)) { $id_metric_clr=$set_id; }
         elsif ($set_subtype ne '') {
            my $cond = 'subtype="'.$set_subtype.'" && hiid="'.$set_hiid.'"';
            my $rv=$store->get_from_db($dbh,'id_remote_alert','cfg_remote_alerts',$cond);
            $id_metric_clr=$rv->[0][0];
         }

         $self->log('notice',"check_alert::[INFO] $monitor [CLEAR-ALERT: IP=$ip id_metric=$id_metric_clr| EV=$ev | MSG=$msg_log]");
         my $alert_id=$store->clear_alert($dbh,{ 'ip'=>$ip, 'id_metric'=>$id_metric_clr, 'type'=>'syslog' });

         #Se actualiza notif_alert_clear (notificationsd evalua si hay que enviar aviso)
         $store->store_notif_alert($dbh, 'clr', { 'id_alert'=>$alert_id, 'id_device'=>$id_device, 'id_alert_type'=>20, 'cause'=>$label, 'name'=>$name, 'domain'=>$domain, 'ip'=>$ip, 'notif'=>0, 'mname'=>$mname, 'watch'=>'', 'id_metric'=>$id_metric_clr, 'type'=>$type, 'severity'=>$severity, 'event_data'=>$msg, 'date'=>$date_last  });

         # Se actualizan las tablas del interfaz
         $store->store_alerts_read_local_clr($dbh,$alert_id);
         my $vk=$id_remote_alert.'.'.$ip;
         #if (exists $alert2views->{$vk}) { $store->analize_views_ruleset($dbh,$cid);  }
      }

      else {
         $self->log('warning',"check_alert::[WARN] $monitor [SIN ACCION (A=$action): IP=$ip | EV=$ev | MSG=$msg]");
       }
   }


}


1;
__END__
