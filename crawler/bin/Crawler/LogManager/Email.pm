#-------------------------------------------------------------------------------------------
# Fichero: Crawler/LogManager/Email.pm  
# Descripcion:
#-------------------------------------------------------------------------------------------
package Crawler::LogManager::Email;
use Crawler::LogManager;
@ISA=qw(Crawler::LogManager);
use strict;
use Net::IMAP::Simple;
use Digest::MD5 qw(md5_hex);
use Data::Dumper;

#------------------------------------------------------------------------------------------
my $MAIL_INBOX='/opt/data/buzones/cnmnotifier/new/';
%Crawler::LogManager::Email::EMAIL2DEV=();
#------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------
# check_configuration
# Actualiza la informacion de confiruracion almacenada en BBDD
#------------------------------------------------------------------------------------------
sub check_configuration {
my ($self)=@_;

	my $reload_file = $self->reload_file();
   if (-f $reload_file) { unlink $reload_file; }

   my $store=$self->store();
   my $dbh=$self->dbh();


   my $event2alert=$store->get_cfg_email_remote_alerts($dbh);
   $self->event2alert($event2alert);

#my $kk1=Dumper($event2alert);
#$self->log('debug',"check_configuration:: event2alert: $kk1");

   #----------------------------------------------------------------------------------
   # EXPR en traps
   #----------------------------------------------------------------------------------
#SELECT a.id_remote_alert,a.expr as expr_logic, b.v,b.descr,b.fx,b.expr FROM cfg_remote_alerts a, cfg_remote_alerts2expr b WHERE a.id_remote_alert=b.id_remote_alert and a.type='snmp';

   my $alert2expr=$store->get_remote_alert_expr_by_type($dbh,'email');
   $self->alert2expr($alert2expr);

#my $kk2=Dumper($alert2expr);
#$self->log('debug',"check_configuration:: alert2expr: $kk2");

   #----------------------------------------------------------------------
	# MAPEO email -> dispositivo (name,domain,ip)
   #my $emails=$store->get_from_db( $dbh, 'email,name,domain,ip', 'devices', 'email != ""', '' );
   my $emails=$store->get_from_db( $dbh, 'name,name,domain,ip,id_dev,critic', 'devices', '', '' );
   %Crawler::LogManager::Email::EMAIL2DEV = map { uc $_->[0] => [$_->[1], $_->[2], $_->[3], $_->[4], $_->[5]] } @$emails;

#my $kk3=Dumper(\%Crawler::LogManager::Email::EMAIL2DEV);
#$self->log('debug',"check_configuration:: EMAIL2DEV: $kk3");

   # Mapeo IP a nombre
   my $ip2name=$store->get_ip2name_vector($dbh);
   $self->ip2name($ip2name);

}

#------------------------------------------------------------------------------------------
# bulk_processor
#------------------------------------------------------------------------------------------
# Procesa los eventos generados a partir de correos. 
# Tiene dos modos de funcionamiento (mta|imap)
# a. mta: En este caso el CNM recibe directamente el correo en un buzón previamente definido:
#		/opt/data/buzones/cnmnotifier/new/  (El CNM es un servidor de correo)
# b. imap: En este caso el CNM es un cliente de correo y descarga los correos de un servidor remoto.
#
# Notar que Los eventos se pueden procesar de dos formas:
# 1 a 1 o en bloque. Los procesos arrancados por el syslog-ng lo hacen uno a uno.
# Para el caso de email es preferible hacerlo en bloque chequeando el buzon de entrade de
# cnmnotifier. (En el caso mta se podria lanzar desde el exim, pero es menos eficiente).
#------------------------------------------------------------------------------------------
sub bulk_processor {
my ($self)=@_;


	$self->check_configuration();


	# a. Modo mta 
	# ---------------------------------------------------
   #my $MAIL_INBOX='/opt/data/buzones/cnmnotifier/new/';
   opendir (DIR,$MAIL_INBOX);
   my @mail_files = readdir(DIR);
   closedir(DIR);

   foreach my $file (sort @mail_files) {

      if (! $self->check_event({'file'=>$file})) { next; }
		$self->check_alert();
	}

   # a. Modo imap
   # ---------------------------------------------------
	my $x=$self->get_json_config('/cfg/mail-manager');
	foreach my $h (@$x) {

	   if (! exists $h->{'imap_host'}) { next; }
   	if (! exists $h->{'imap_user'}) { next; }
   	if (! exists $h->{'imap_pwd'}) { next; }
   	my $port = (exists $h->{'imap_port'}) ? $h->{'imap_port'} : 143;
   	my $timeout = (exists $h->{'imap_timeout'}) ? $h->{'imap_timeout'} : 2;
  	 	my $use_ssl = (exists $h->{'imap_secure'}) ? $h->{'imap_secure'} : 0;
   	my $mailbox = (exists $h->{'imap_mailbox'}) ? $h->{'imap_mailbox'} : 'INBOX';

   	my $imap = new Net::IMAP::Simple($h->{'imap_host'}, Timeout=>$timeout , ResvPort=>$port, use_ssl=>$use_ssl);

   	if (!defined $imap) { 
			$self->log('info',"bulk_processor::[**ERROR**] en conexion IMAP Host=$h->{'imap_host'} Port=$port use_ssl=$use_ssl");
			next;
		}

   	my $r=$imap->login($h->{'imap_user'},$h->{'imap_pwd'});

   	if (! defined $r) { 
         $self->log('info',"bulk_processor::[**ERROR**] en login IMAP Host=$h->{'imap_host'} Port=$port use_ssl=$use_ssl user=$h->{'imap_user'}|pwd=$h->{'imap_pwd'}");
         next;
      }

	   my $nm=$imap->select($mailbox);
   	for(my $i = 1; $i <= $nm; $i++){
      	my $seen = $imap->seen($i);
      	my $msize  = $imap->list($i);
			$self->log('info',"bulk_processor:: IMAP MSG [$i|$nm] size=$msize leido=$seen - Host=$h->{'imap_host'} mailbox=$mailbox");

      	#my $header = $imap->top( $i ); print for @{$header};
      	my $msg = $imap->get($i);
			if (! $msg) {
				my $errstr = $imap->errstr;
				$self->log('info',"bulk_processor::[**ERROR**] en GET IMAP MSG=$i ($errstr)");
	         next;
   	   }

			my $fmsg=int(10000000000*rand());
			open (F,">$MAIL_INBOX$fmsg");
			print F $msg;
			close F;
$self->log('info',"bulk_processor::[*DEBUG**] Creado fichero $MAIL_INBOX$fmsg");

	      if (! $self->check_event({'file'=>$fmsg})) { next; }
   	   $self->check_alert();
			$imap->delete($i);
   	}
		if ($nm>0) {
			my $expunged = $imap->expunge_mailbox($mailbox);
			$self->log('info',"bulk_processor:: IMAP expunged=$expunged");
		}
   	$imap->quit();
   	undef $imap;
	}
}

#------------------------------------------------------------------------------------------
# check_event
# 1. Parsea la linea de syslog
# 2. Almacena el evento correspondiente 
# OUT:
# 0 -> No se ha almacenado evento, 1 -> Si se ha almacenado evento
#------------------------------------------------------------------------------------------
sub check_event {
#my ($self,$file) = @_;
my ($self,$params) = @_;

   my %MSG=( 'Subject'=>'', 'Body'=>'' );
	$self->event(\%MSG);
   my $store=$self->store();
   my $dbh=$self->dbh();

	my $ent;
	my $file_path='';

	my $parser = new MIME::Parser;
   $parser->output_to_core(1);
   $parser->decode_headers(1);
   $parser->ignore_errors(1);

	if (exists $params->{'file'}) {

	   $file_path=$MAIL_INBOX.$params->{'file'};
  	 	if (! -f $file_path) { return 0; }
   	$self->log('debug',"check_event::[DEBUG] START file_path=$file_path");

	   $ent = $parser->parse_open($file_path);
   	if (! $ent) {
      	$self->log('info',"check_event::[**ERROR**] parse_open de $file_path");
      	# Se borra el correo
      	unlink $file_path;
      	return 0;
   	}
	}
	elsif (exists $params->{'msg'}) {
		my $msg=$params->{'msg'};
		$ent = $parser->parse_data(\$msg);
      if (! $ent) {
         $self->log('info',"check_event::[**ERROR**] parse_open de MSG");
         return 0;
      }
   }
	else { 
      $self->log('info',"check_event::[**ERROR**] en params");
		return 0; 
	}



   $self->_mime_dump($ent);
	my $event=$self->event();


my $kk1=Dumper($event);
$self->log('debug',"check_event:: event: $kk1");



   #my $evkey1=md5_hex($MAIL_DATA{'Subject'});
   my $evkey1=md5_hex($event->{'Subject'});
   my $evkey=substr $evkey1,0,16;

   #my $msg=$ent->body_as_string;
   my $msg = '<b>v1 (Subject):</b>&nbsp;'. $event->{'Subject'} .'<br><b>v2 (Body):</b>&nbsp;'.  $event->{'Body'};
	$event->{'msg'}=$msg;	
   my $proccess = 'EMAIL';
   my $from = $event->{'From'};
   $from =~ s/<\s*(\S+)\s*>/$1/;
	$event->{'From'}=$from;
   my $ip='0.0.0.0';
	my $id_dev=0;
	my $critic=50;

	# Se supone que el From es del tipo:
	# nombre_dispositivo@dominio
   my $name=$from;
	if ($from =~ /^(.+)\@/) { $name = uc $1; }

   my $domain='';


$self->log('info',"check_event:: **FML** ...... name=$name");

   if (exists $Crawler::LogManager::Email::EMAIL2DEV{$name}) {
      $ip=$Crawler::LogManager::Email::EMAIL2DEV{$name}->[2];
      $domain=$Crawler::LogManager::Email::EMAIL2DEV{$name}->[1];
      $name=$Crawler::LogManager::Email::EMAIL2DEV{$name}->[0];
      $id_dev=$Crawler::LogManager::Email::EMAIL2DEV{$name}->[3];
      $critic=$Crawler::LogManager::Email::EMAIL2DEV{$name}->[4];

$self->log('info',"check_event:: **FML** EXISTE name=$name ip=$ip domain=$domain");

	}
	
	$event->{'ip'}=$ip;
	$event->{'name'}=$name;
	$event->{'domain'}=$domain;
	$event->{'id_dev'}=$id_dev;
	$event->{'critic'}=$critic;
	$self->event($event);

   # Almaceno el evento ---------------------------------------------------------------------
   my $t=time;
   $store->store_event($dbh, { date=>$t, code=>1, proccess=>$proccess, msg=>$msg, ip=>$ip, name=>$name, domain=>$domain, evkey=>$evkey, msg_custom=>'', 'id_dev'=>$id_dev });

	$self->log('debug',"check_event:: STORE EVENT date=>$t, code=>1, proccess=>$proccess, ip=>$ip, name=>$name, domain=>$domain, evkey=>$evkey, msg_custom=>'' ");

#parche FML
#`/bin/cp $file_path /home/cnm/correos/`;

   # Se borra el correo
   unlink $file_path;

   return 1;

}


#----------------------------------------------------------------------------
# _mime_dump
#----------------------------------------------------------------------------
sub _mime_dump {
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
#      $MAIL_DATA{'Subject'} = $entity->head->get('Subject');
#      $MAIL_DATA{'From'} = $entity->head->get('From');
#      $MAIL_DATA{'To'} = $entity->head->get('To');
#
#      chomp $MAIL_DATA{'Subject'};
#      chomp $MAIL_DATA{'From'};
#      chomp $MAIL_DATA{'To'};

		my $event=$self->event();
      $event->{'Subject'} = $entity->head->get('Subject');
      $event->{'From'} = $entity->head->get('From');
      $event->{'To'} = $entity->head->get('To');
      chomp $event->{'Subject'};
      chomp $event->{'From'};
      chomp $event->{'To'};
		$event->{'From'} =~ s/^.*?(\S+\@\S+)$/$1/;
		$self->event($event);

      #my $subject=$entity->head->get('Subject');
      #print "***FML*** S=$subject\n";
   }
   # Output the body:
   my @parts = $entity->parts;
   if (@parts) {                     # multipart...
      my $i;
      foreach $i (0 .. $#parts) {       # dump each part...
         #dump_entity($parts[$i], ("$name, part ".(1+$i)));
         $self->_mime_dump($parts[$i], ("$name.".(1+$i)));
      }
    }
    else {                            # single part...
#$self->log('info',"_mime_dump::[**DEBUG**] NAME=$name");

      #if ($name !~ /1\.1\.1/) {return; }
      if ($name ne '1') {return; }
      # Get MIME type, and display accordingly...
      my ($type, $subtype) = split('/', $entity->head->mime_type);
      my $body = $entity->bodyhandle;
      if ($type =~ /^(text|message)$/) {     # text: display it...
         #$MAIL_DATA{'Body'}='';
			my $event=$self->event();
			$event->{'Body'}='';
         if ($IO = $body->open("r")) {
            #print $_ while (defined($_ = $IO->getline));
            while (defined($_ = $IO->getline)) { 
					#$MAIL_DATA{'Body'} .= $_; 
					$event->{'Body'} .= $_;
				};
            $IO->close;
         }
         else {       # d'oh!
            print "$0: couldn't find/open '$name': $!";
         }
			$self->event($event);
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

my $kk1=Dumper($event2alert);
$kk1=~s/\n/\. /g;
$self->log('debug',"check_alert:: Las alertas remotas tipo email definidas (email2alert) son: $kk1");


   if (scalar(keys %$event2alert) ==  0) {
      $self->log('debug',"check_alert:: SIN ALERTAS REMOTAS POR EMAIL DEFINIDAS...");
      return;
   }

   my @vals=($event->{'Subject'}, $event->{'Body'} );
   my $expr_logic='AND'; # REVISAR!!! FML
	my $ip = $event->{'ip'};
	my $name = $event->{'name'};
	my $ucname = uc $event->{'name'};
	my $domain = $event->{'domain'};
	my $from = $event->{'From'};
	my $msg=$event->{'msg'};
	#my $id_dev = $event->{'id_dev'};
	my $critic = $event->{'critic'};

   #Si es una alerta de un dispositivo dado de alta pero no activo => No se genera la alerta
	my $ip2name=$self->ip2name();
   if ((exists $ip2name->{$ip}) && ($ip2name->{$ip}->{'status'} !=0)) {
      $self->log('info',"check_alert::[INFO] ip=$ip msg=$msg **SALTO DISPOSITIVO NO ACTIVO**");
      return;
   }

	my $id_dev = (exists $ip2name->{$ip}->{'id_dev'}) ? $ip2name->{$ip}->{'id_dev'} : $event->{'id_dev'};


   #Para cada alerta de tipo email configurada (y asociada a algun dispositivo)
   #chequeo si el evento (amil) cumple sus expresiones
   foreach my $ev  (keys %$event2alert) {


      if (! exists $event2alert->{$ev}->{$ucname}) {
         $self->log('debug',"check_alert:: ALERTA $ev **NO DEFINIDA** PARA ucname=$ucname (from=$from) ...");
         next;
      }

		my $email=$event2alert->{$ev}->{$ucname}->{'email'};
      my $subtype=$event2alert->{$ev}->{$ucname}->{'subtype'};
      my $target=$event2alert->{$ev}->{$ucname}->{'target'};
      my $monitor=$event2alert->{$ev}->{$ucname}->{'monitor'};
      my $vdata=$event2alert->{$ev}->{$ucname}->{'vdata'};
      my $action=$event2alert->{$ev}->{$ucname}->{'action'};
      my $severity=$event2alert->{$ev}->{$ucname}->{'severity'};
      my $script=$event2alert->{$ev}->{$ucname}->{'script'};
      my $cause=$event2alert->{$ev}->{$ucname}->{'descr'};
      my $id_remote_alert=$event2alert->{$ev}->{$ucname}->{'id_remote_alert'};
      my $expr=$event2alert->{$ev}->{$ucname}->{'expr'};
      my $mode=$event2alert->{$ev}->{$ucname}->{'mode'};
     	my $mname=$subtype;
      my $type='email';
      my $label=$cause;
      my $id_metric=$id_remote_alert;
		my $cid=$self->cid();

		my $set_id=$event2alert->{$ev}->{$ucname}->{'set_id'};
		my $set_subtype=$event2alert->{$ev}->{$ucname}->{'set_subtype'};
		my $set_hiid=$event2alert->{$ev}->{$ucname}->{'set_hiid'};
		
$self->log('debug',"check_alert:: ALERTA $ev: +++DEFINIDA PARA $ucname ($from) ...");
my $kk=Dumper($alert2expr->{$id_remote_alert});
$kk=~s/\n/\. /g;
$self->log('info',"check_alert:: id_remote_alert=$id_remote_alert DUMPER=$kk");

      my $condition_ok=$self->watch_eval_ext($alert2expr->{$id_remote_alert},$expr_logic,\@vals);
$self->log('info',"check_alert:: id_remote_alert=$id_remote_alert watch_eval_ext RES=$condition_ok");

      if (! $condition_ok) {next; }

		my $date_last=time();

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

 			my ($alert_id,$alert_date)=$store->store_alert($dbh,$monitor,{ 'ip'=>$ip, 'mname'=>$mname, 'severity'=>$severity, 'event_data'=>$msg, 'label'=>$label, 'cause'=>$cause, 'type'=>$type, 'id_alert_type'=>20, 'id_metric'=>$id_metric, 'mode'=>$mode, 'cid'=>$cid, 'name'=>$name, 'domain'=>$domain, 'subtype'=>$subtype, 'id_device'=>$id_dev, 'critic'=>$critic, 'date_last'=>$date_last }, 1);
			my $response = $store->response();

         ## Se actualizan las tablas del interfaz
         #$store->store_alerts_read_local_set($dbh,$alert_id);

         #my $vk=$id_remote_alert.'.'.$ip;
         #if (exists $alert2views->{$vk}) { $store->analize_views_ruleset($dbh,$cid);  }

         # Se actualiza notif_alert_set (notificationsd evalua si hay que enviar aviso)
			# a. SET de alerta que no incrementa contador
			# b. SET de alerta que incrementa contador solo la primera vez (insert)
			if (($cfg_mode ne 'INC') || ($response =~ /insert/)){
	         $store->store_notif_alert($dbh, 'set', { 'id_alert'=>$alert_id, 'id_device'=>$id_dev, 'id_alert_type'=>20, 'cause'=>$cause, 'name'=>$name, 'domain'=>$domain, 'ip'=>$ip, 'notif'=>0, 'mname'=>$mname, 'watch'=>'', 'id_metric'=>$id_metric, 'type'=>$type, 'severity'=>$severity, 'event_data'=>$msg, 'date'=>$date_last  });
			}

         # Se actualizan las tablas del interfaz
         $store->store_alerts_read_local_set($dbh,$alert_id);

         $self->log('notice',"check_alert::[INFO] $monitor [SET-ALERT: $alert_id IP=$ip/$name/$from | cfg_mode=$cfg_mode | mode=$mode | EV=$ev | MSG=$msg_log] response=$response");

      }

      # Procesado de alertas. CLEAR -------------------------------------------------------------
      elsif ( $action =~ /CLR/ ) {

#			if ($vdata =~ /id=(\d+)/) {
#				my $cond = 'id_remote_alert='.$1;
#				my $r=$store->get_from_db( $dbh, 'subtype', 'cfg_remote_alerts', $cond, '' );
#				my $mname_set = $r->[0][0]; 
#	         $self->log('notice',"check_alert::[INFO] $monitor [CLEAR-ALERT: IP=$ip mname=$mname_set  (cond=$cond) | EV=$ev | MSG=$msg]");
#   	      $store->clear_alert($dbh,{ 'ip'=>$ip, 'mname'=>$mname_set });
#			}
#			else { $self->log('warning',"check_alert::[WARN] $monitor [CLR SIN ID (vdata vdata): IP=$ip/$name | EV=$ev | MSG=$msg]"); }
#

         my $id_metric_clr=0;
         # Se borra la original a partir del set_id.  Si no existe set_id, lo busco a partir de subtype + hiid
         if (($set_id =~ /^\d+$/) && ($set_id>0)) { $id_metric_clr=$set_id; }
         elsif ($set_subtype ne '') {
            my $cond = 'subtype="'.$set_subtype.'" && hiid="'.$set_hiid.'"';
            my $rv=$store->get_from_db($dbh,'id_remote_alert','cfg_remote_alerts',$cond);
            $id_metric_clr=$rv->[0][0];
         }

         $self->log('notice',"check_alert::[INFO] $monitor [CLEAR-ALERT: IP=$ip id_metric=$id_metric_clr| EV=$ev | MSG=$msg_log]");
         my $alert_id=$store->clear_alert($dbh,{ 'ip'=>$ip, 'id_metric'=>$id_metric_clr, 'type'=>'email' });


			#Se actualiza notif_alert_clear (notificationsd evalua si hay que enviar aviso)
			$store->store_notif_alert($dbh, 'clr', { 'id_alert'=>$alert_id, 'id_device'=>$id_dev, 'id_alert_type'=>20, 'cause'=>$cause, 'name'=>$name, 'domain'=>$domain, 'ip'=>$ip, 'notif'=>0, 'mname'=>$mname, 'watch'=>'', 'id_metric'=>$id_metric_clr, 'type'=>$type, 'severity'=>$severity, 'event_data'=>$msg, 'date'=>$date_last  });


         # Se actualizan las tablas del interfaz
         $store->store_alerts_read_local_clr($dbh,$alert_id);
         my $vk=$id_remote_alert.'.'.$ip;
         #if (exists $alert2views->{$vk}) { $store->analize_views_ruleset($dbh,$cid);  }
      }

      else {
         $self->log('warning',"check_alert::[WARN] $monitor [SIN ACCION (A=$action): IP=$ip/$name | EV=$ev | MSG=$msg_log]");
       }
   }


}


1;
__END__
