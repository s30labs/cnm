#####################################################################################################
# Fichero: Crawler::Transport.pm
#####################################################################################################
use Crawler;
package Crawler::Transport;
@ISA=qw(Crawler);
$VERSION='1.00';
use strict;

use Carp 'croak','cluck';
use Cwd;
use Net::SMTP;
use Net::SMTP::TLS;
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
use Crawler::LogManager::Email;
use WWW::Telegram::BotAPI;

#----------------------------------------------------------------------------
# notify_by_transport
# 		do_notif_email
#			tx_email
# 		do_notif_sms
#			tx_sms (return $err_num)
# 		do_notif_trap
#			tx_trap
#
#----------------------------------------------------------------------------
$Crawler::Transport::NOTIF_EMAIL = 1;
$Crawler::Transport::NOTIF_SMS = 2;
$Crawler::Transport::NOTIF_TRAP = 3;
$Crawler::Transport::NOTIF_TELEGRAM = 4;


#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Transport
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

	my $self=$class->SUPER::new(%arg);

   $self->{_snmp} = $arg{snmp} || undef;

   # Atributos globales -------------------------
   $self->{_lapse} = $arg{lapse} || 60;				# Intervalo de testeo para el envio de avisos
   $self->{_cfg} = $arg{cfg} || '';						# Referencia a un hash con los parametros de configuracion.

   # Atributos para envio de e-mails  -----------
   $self->{_mx} = $arg{mx} || 'localhost';			# MX para el envio de e-mails
   $self->{_from} = $arg{from} || '';					# Direccion de correo del remitente
   $self->{_from_name} = $arg{from_name} || '';		# Nombre del remitente
   $self->{_subject} = $arg{subject} || '';			# Asunto del correo

   # Atributos para envio de SMSs  -----------
   $self->{_serial_port} = $arg{serial_port} || '/dev/ttyS0';	# Puerto serie al que esta conectado el modem
   $self->{_pin} = $arg{pin} || '';						# PIN del terminal GSM

   # Atributos para envio por Telegram  -----------
   $self->{_token} = $arg{token} || '';        		# Telegram token
   $self->{_chat_id} = $arg{chat_id} || '';        # Telegram chat id
   $self->{_first_name} = $arg{first_name} || '';  # Telegram first name
   $self->{_last_name} = $arg{last_name} || '';    # Telegram last name


   $self->{_version1} = $arg{version1} || '3.23.54';
   $self->{_version2} = $arg{version2} || '1.0.40';
   $self->{_time_ref} = $arg{time_ref} || 0;

   return $self;

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
# token
#----------------------------------------------------------------------------
sub token {
my ($self,$token) = @_;
   if (defined $token) {
      $self->{_token}=$token;
   }
   else { return $self->{_token}; }
}

#----------------------------------------------------------------------------
# chat_id
#----------------------------------------------------------------------------
sub chat_id {
my ($self,$chat_id) = @_;
   if (defined $chat_id) {
      $self->{_chat_id}=$chat_id;
   }
   else { return $self->{_chat_id}; }
}

#----------------------------------------------------------------------------
# first_name
#----------------------------------------------------------------------------
sub first_name {
my ($self,$first_name) = @_;
   if (defined $first_name) {
      $self->{_first_name}=$first_name;
   }
   else { return $self->{_first_name}; }
}

#----------------------------------------------------------------------------
# last_name
#----------------------------------------------------------------------------
sub last_name {
my ($self,$last_name) = @_;
   if (defined $last_name) {
      $self->{_last_name}=$last_name;
   }
   else { return $self->{_last_name}; }
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
# init
#----------------------------------------------------------------------------
sub init  {
my ($self)=@_;

   my $rcfgbase=$self->cfg();
   my $MX=$rcfgbase->{notif_mx}->[0]; $self->mx($MX);
   my $FROM=$rcfgbase->{notif_from}->[0];  $self->from($FROM);
   my $FROM_NAME=$rcfgbase->{notif_from_name}->[0];  $self->from_name($FROM_NAME);
   my $SUBJECT=$rcfgbase->{notif_subject}->[0];  $self->subject($SUBJECT);
   my $SERIAL_PORT=$rcfgbase->{notif_serial_port}->[0];  $self->serial_port($SERIAL_PORT);
   my $PIN=$rcfgbase->{notif_pin}->[0];  $self->pin($PIN);
	my $TOKEN=$rcfgbase->{notif_tg_bot_token}->[0]; $self->token($TOKEN);

}

#----------------------------------------------------------------------------
# notify_by_transport
#----------------------------------------------------------------------------
# Genera el aviso correspondiente segun el transporte especificado
# Parametros:
#		$transport_type -> Tipo de transporte (NOTIF_EMAIL|NOTIF_SMS|NOTIF_TRAP)
#		$transport_data -> Hash con los datos asociados al mensaje
# returns 0->OK | >0->NOK
#----------------------------------------------------------------------------
sub notify_by_transport  {
my ($self,$transport_type,$transport_data)=@_;

	$self->err_num(0);
	$self->err_str('');

	#1
	if ($transport_type == $Crawler::Transport::NOTIF_EMAIL) {

		if (exists $transport_data->{'subject'}) { 
			$self->subject($transport_data->{'subject'}); 
		}
      $self->do_notif_email($transport_data);
	}
	#2
	elsif ($transport_type == $Crawler::Transport::NOTIF_SMS) {

		# OJO: do_notif_sms envia lo que hay en subject
      if (exists $transport_data->{'txt'}) {
         $self->subject($transport_data->{'txt'});
      }
      $self->do_notif_sms($transport_data);
	}
	#3
	elsif ($transport_type == $Crawler::Transport::NOTIF_TRAP) {
      $self->do_notif_trap($transport_data);
	}
   #4
   elsif ($transport_type == $Crawler::Transport::NOTIF_TELEGRAM) {
      $self->do_notif_telegram($transport_data);
   }

	my $rc=$self->err_num();
	return $rc;
}


#----------------------------------------------------------------------------
# do_notif_email
#----------------------------------------------------------------------------
# returns 0->OK | >0->NOK
# Almacena rc,rcstr
#----------------------------------------------------------------------------
sub do_notif_email  {
my ($self,$tdata)=@_;

	my ($dest,$txt) = ($tdata->{'dest'}, $tdata->{'txt'});

	my $mx=$self->mx();
	my $from=$self->from();
	my $rcstr='';
	my $err_num=0;

   my @d=split(/\;/,$dest);
   foreach my $dest1 (@d) {
		$err_num=$self->tx_email({mxhost=>$mx, from=>$from, to=>$dest1, txt=>$txt});
		if ($err_num==0) {	
			$rcstr.="OK ($dest1)<br>";
			$self->log('info',"do_notif_email::[OK] To:$dest1 rcstr=$rcstr");
		}
		else {
         my $err_str = $self->err_str();
			$self->log('info',"do_notif_email::[ERROR] To:$dest1 err_num=$err_num rcstr=$err_str");
			$rcstr.="ERROR ($dest1) >> $err_str<br>";
		}
	}
	$self->err_str($rcstr);
	$self->err_num($err_num);
	return $err_num;
}


#----------------------------------------------------------------------------
# do_nofif_sms
#----------------------------------------------------------------------------
# returns 0->OK | >0->NOK
# Almacena rc,rcstr
#----------------------------------------------------------------------------
sub do_notif_sms  {
my ($self,$tdata)=@_;

	my ($dest,$txt) = ($tdata->{'dest'}, $tdata->{'txt'});

	my $serial_port=$self->serial_port();
	my $rcstr='';
	my $err_num=0;

	my @d=split(/\;/,$dest);
	foreach my $dest1 (@d) {
	   $err_num=$self->tx_sms({serial_port=>$serial_port, to=>$dest1});
   	if ($err_num==0) {
      	$self->log('info',"do_notif_sms::[OK] To:$dest1");
			$rcstr.="OK ($dest1)<br>";
   	}
      else {
			my $err_str = $self->err_str();
         $self->log('info',"do_notif_sms::[ERROR] To:$dest1 err_num=$err_num err_str=$err_str");
         $rcstr.="ERROR ($dest1) >> $err_str<br>";
      }

	}
	$self->err_str($rcstr);
	$self->err_num($err_num);
	return $err_num;
}


#----------------------------------------------------------------------------
# do_nofif_trap
#----------------------------------------------------------------------------
sub do_notif_trap  {
my ($self,$tdata)=@_;

   my $rcstr='';
   my $err_num=0;
	my ($dest,$txt) = ($tdata->{'dest'}, $tdata->{'txt'});
	my $SNMP=$self->snmp();

	if (! defined $SNMP) {
		$err_num=2;
		$rcstr='SNMP no definido';
		$self->log('warn',"do_notif_trap::[ERROR] $rcstr (To:$dest)");
	   $self->err_str($rcstr);
  	 	$self->err_num($err_num);
   	return $err_num;
	}

	my %params=(host_ip=>$dest, comunity=>'public');

   my @d=split(/\;/,$dest);
   foreach my $dest1 (@d) {
		my $r=$SNMP->core_snmp_trap(\%params);
		if ($r==0) {
			$self->log('info',"do_notif_trap::[OK] To:$dest1");
			$rcstr.="OK ($dest1)<br>";

		}
		else {
   	   $self->log('info',"do_notif_trap::[ERROR] To:$dest1");
			$rcstr.="ERROR ($dest1) >> ".$self->err_str().'<br>';
			$err_num=1;
		}
	}
	$self->err_str($rcstr);
   $self->err_num($err_num);
   return $err_num;
}

#----------------------------------------------------------------------------
# do_nofif_telegram
#----------------------------------------------------------------------------
sub do_notif_telegram  {
my ($self,$tdata)=@_;

   my $rcstr='';
   my $err_num=0;
   #my $txt = '<b>'.$tdata->{'subject'}.'</b>'.$tdata->{'txt'};
   my $txt = $tdata->{'txt'};
	$txt =~ s/\n/ /g;

   # token = 313221326:AAEHM8Inzl5chz7LRLKx3borVvCqWMGdMz8
   my $token = $self->token();
   my $api = WWW::Telegram::BotAPI->new ( token => $token );

   my @d=split(/\;/, $tdata->{'dest'});
   foreach my $chat_id (@d) {

		# chat_id = 172873709
		my $response = eval { 
				$api->api_request ('sendMessage', { chat_id => $chat_id, parse_mode => 'html', text => $txt});
		};
		if ($@) {
         $self->log('info',"do_notif_telegram::[ERROR] sending to $chat_id ($@) ($txt)");
         $self->log('info',"do_notif_telegram::[ERROR] txt=$txt");
         $rcstr.="ERROR sending to $chat_id ($@) <br> ";
         $err_num=1;
      }
		else {
         $self->log('info',"do_notif_telegram::[OK] sent message to $chat_id ($txt)");
      }
   }
   $self->err_str($rcstr);
   $self->err_num($err_num);
   return $err_num;
}


#----------------------------------------------------------------------------
# tx_email
#----------------------------------------------------------------------------
# returns 0->OK | >0->NOK
# Almacena rcstr
#----------------------------------------------------------------------------
sub tx_email  {
my ($self,$rdata)=@_;

	my $mxhost = (defined $rdata->{mxhost}) ? $rdata->{mxhost} : '127.0.0.1';
	my $from = (defined $rdata->{from}) ? $rdata->{from} : 'cnm@localhost.localdomain';
	my $to = (defined $rdata->{to}) ? $rdata->{to} : 'cnm@localhost.localdomain';
	my $txt = $rdata->{txt};
	my $cfg=$self->cfg();
	my $port = $cfg->{'notif_mx_port'}->[0];
   my $from_name=$self->from_name();
   my $subject=$self->subject();
	
	# CON TLS -------------------------------------------------------------------
	if ($cfg->{'notif_mx_tls'}->[0]) {

		my $user = $cfg->{'notif_mx_auth_user'}->[0];
		my $pwd = $cfg->{'notif_mx_auth_pwd'}->[0];
      $self->log('info',"tx_email::[INFO] SMTP-TLS mxhost=$mxhost port=$port user=$user pwd=$pwd");

		eval {
			my $smtp = new Net::SMTP::TLS( $mxhost, Hello => '', Port => $port, User => $user, Password => $pwd );

		   if (!defined $smtp) {
   		   $self->log('warning',"tx_email::[ERROR] al crear objeto SMTP $mxhost");
      		$self->err_str("ERROR DE CONEXION: Al establecer sesion con $mxhost");
      		return 1;
   		}

			$smtp->mail($from);
			$self->log('info',"tx_email::[INFO] SMTP-TLS MAIL FROM:$from");
			$smtp->to($to);
			$self->log('info',"tx_email::[INFO] SMTP-TLS RCPT TO:$to");

      	my %info=('from'=>$from, 'to'=>$to, 'subject'=>$subject, 'txt'=>$txt );
      	my $mime=$self->mime_composer(\%info);
      	$smtp->data;
			$smtp->datasend($mime);
			$smtp->dataend;

			$self->log('info',"tx_email::[INFO] SMTP-TLS ($subject) DATA");

			$smtp->quit;
   	   $self->log('info',"tx_email::[INFO] SMTP-TLS to MX $mxhost :DONE");

		};
		if ($@) {
			my $err_str=$@;
			$err_str=~s/\n/ /g;
			$self->err_str("ERROR DE MTA: ($err_str)");
			$self->log('warning',"tx_email::ERROR EN SMTP-TLS ($err_str)");
			return 2;
		}
	}

	# SIN TLS -------------------------------------------------------------------
	else {
	   my $smtp = Net::SMTP->new($mxhost, Timeout => 60);
	
	   if (!defined $smtp) {
   	   $self->log('warning',"tx_email::[ERROR] al crear objeto SMTP $mxhost ($@)");
      	$self->err_str("ERROR DE CONEXION: Al establecer sesion con $mxhost ($@)");
			return 3;
   	}

      if ($cfg->{'notif_mx_auth'}->[0]) {
         my $user = $cfg->{'notif_mx_auth_user'}->[0];
         my $pwd = $cfg->{'notif_mx_auth_pwd'}->[0];

         my $ok=$smtp->auth($user,$pwd);
         if (!$ok) {
            my $msg=$smtp->message();
            $msg=~s/[\n|\>|\<]/ /g;
            $self->err_str("ERROR DE MTA: @{[$smtp->code()]} ($msg)");
            $smtp->quit;
            return 4;
         }
      }

	   $smtp->mail($from);
	   $self->log('info',"tx_email::[INFO] SMTP MAIL FROM:$from (RESP: @{[$smtp->code()]}:@{[$smtp->message()]})");
		if ($smtp->code() > 500) {
  	    	my $msg=$smtp->message();
      	$msg=~s/[\n|\>|\<]/ /g;
			$self->err_str("ERROR DE MTA: @{[$smtp->code()]} ($msg)");
			$smtp->quit;
			return 5;
		}

	   $smtp->to($to);
   	$self->log('info',"tx_email::[INFO] SMTP RCPT TO:$to (RESP: @{[$smtp->code()]}:@{[$smtp->message()]})");
		if ($smtp->code() > 500) {
			my $msg=$smtp->message();
			$msg=~s/[\n|\>|\<]/ /g;
			$self->err_str("ERROR DE MTA: @{[$smtp->code()]} ($msg)");
			$smtp->quit;
			return 6;
		}

		my %info=('from'=>$from, 'to'=>$to, 'subject'=>$subject, 'txt'=>$txt );
		my $mime=$self->mime_composer(\%info);
   	$smtp->data([$mime]);

	   $self->log('info',"tx_email::[INFO] SMTP ($subject) DATA (RESP: @{[$smtp->code()]}:@{[$smtp->message()]})");
		if ($smtp->code() > 500) {
      	my $msg=$smtp->message();
			$msg=~s/[\n|\>|\<]/ /g;
			$self->err_str("ERROR DE MTA: @{[$smtp->code()]} ($msg)");
   	   $smtp->quit;
      	return 7;
		}

	   $smtp->quit;
   	$self->log('info',"tx_email::[INFO] SMTP QUIT (RESP: @{[$smtp->code()]}:@{[$smtp->message()]})");
   	$self->log('info',"tx_email::[INFO] SMTP to MX $mxhost :DONE");
	}
	return 0;

}



#----------------------------------------------------------------------------
# mime_composer
#----------------------------------------------------------------------------
sub mime_composer  {
my ($self,$rdata)=@_;
my ($res,$cmd);

	my $from = $rdata->{'from'};
	my $to = $rdata->{'to'};
	my $subject = $rdata->{'subject'};
	my $txt = $rdata->{'txt'};

  	my $top = MIME::Entity->build( 	From    => $from,
                               		To      => $to,
                               		Subject => $subject,
                               		Data    => $txt);

#	if (defined $rrd) {
#
#	   $top->attach(	Path     => $rrd,
#   	         		Type     => "image/png",
#      	           	Encoding => "base64");
#	}


	

	return $top->as_string();

}

#----------------------------------------------------------------------------
# tx_sms_old
#----------------------------------------------------------------------------
sub tx_sms_old  {
my ($self,$rdata)=@_;
my ($res,$cmd);

   if (! defined $rdata->{to}) {
      $self->log('info',"tx_sms::[ERROR] No definido destino (to)");
      $self->err_str("ERROR (No definido destino)");
      return;
   }

	my $serial_port = (defined $rdata->{serial_port}) ? $rdata->{serial_port} : '/dev/ttyS0';
	my $pin = (defined $rdata->{pin}) ? $rdata->{pin} : '';
	my $ttySx = Device::SerialPort->new ($serial_port);
   if (! $ttySx) {
      $self->log('info',"tx_sms::[ERROR] No se puede conectar al puerto $serial_port");
      $self->err_str("ERROR (No se puede conectar al puerto $serial_port)");
      return;
   }


   my $to = $rdata->{to};

	my $subject_raw=$self->subject();
	my $subject = encode('iso-8859-1', $subject_raw);

   if ($to =~ /^34/) { $to='+'.$to; }
   if ($to !~ /^\+34/) { $to='+34'.$to; }


	# Confuguracion del puerto serie -------------------------------------------
	my $rcfgbase=$self->cfg();
	my $baudrate = (defined $rcfgbase->{'serial_port_baudrate'}) ? $rcfgbase->{'serial_port_baudrate'}->[0] : '9600';
	my $parity = (defined $rcfgbase->{'serial_port_parity'}) ? $rcfgbase->{'serial_port_parity'}->[0] : 'none';
	my $databits = (defined $rcfgbase->{'serial_port_databits'}) ? $rcfgbase->{'serial_port_databits'}->[0] : '8';
	my $stopbits = (defined $rcfgbase->{'serial_port_stopbits'}) ? $rcfgbase->{'serial_port_stopbits'}->[0] : '1';
	my $handshake = (defined $rcfgbase->{'serial_port_handshake'}) ? $rcfgbase->{'serial_port_handshake'}->[0] : 'xoff';

	$ttySx->user_msg(1);
	$ttySx->error_msg(1);

	#$ttySx->baudrate(9600);
	#$ttySx->parity("none");
	#$ttySx->databits(8);
	#$ttySx->stopbits(1);
	#$ttySx->handshake('xoff');

   $ttySx->baudrate($baudrate);
   $ttySx->parity($parity);
   $ttySx->databits($databits);
   $ttySx->stopbits($stopbits);
   $ttySx->handshake($handshake);


	$self->log('info',"tx_sms::[DEBUG] Uso $serial_port RATE=$baudrate|PARITY=$parity|DATA=$databits|STOP=$stopbits|HANDSHAKE=$handshake");


	# Dialogo con el modem -----------------------------------------------------
	$cmd="AT";
	$res=to_modem($ttySx,$cmd);
	if ($res !~ /OK/s) {
      $self->log('info',"tx_sms::[ERROR] NO responde a cmd=$cmd ($serial_port) [To:$to MSG=$subject]");
      $self->err_str("ERROR (NO responde a cmd=$cmd)");
      return;
   }
$self->log('debug',"tx_sms::[DEBUG] tx> $cmd rx> $res");

	if ($pin) {
	   $cmd="AT+CPIN=\"$pin\"";
   	$res=to_modem($ttySx,$cmd);
$self->log('debug',"tx_sms::[DEBUG] tx> $cmd rx> $res");
	}


	$cmd="AT+CMGF=1";
	$res=to_modem($ttySx,$cmd);
	if ($res !~ /OK/s) {
      $self->log('info',"tx_sms::[ERROR] No responde a cmd=$cmd ($serial_port) [To:$to MSG=$subject]");
      $self->err_str("ERROR (NO responde a cmd=$cmd)");
      return;
   }
$self->log('debug',"tx_sms::[DEBUG] tx> $cmd rx> $res");

   $cmd='AT+CMGS="'.$to.'"';
	$res=to_modem($ttySx,$cmd);
   if ($res !~ />/s) {
      $self->log('info',"tx_sms::[ERROR] No responde a cmd=$cmd ($serial_port) [To:$to MSG=$subject]");
      $self->err_str("ERROR (NO responde a cmd=$cmd)");
      return;
   }

$self->log('debug',"tx_sms::[DEBUG] tx> $cmd rx> $res");

	$res=to_modem($ttySx,$subject);
$self->log('debug',"tx_sms::[DEBUG] tx> $subject rx> $res");
	$res=to_modem($ttySx,"\cZ");

$self->log('debug',"tx_sms::[DEBUG] tx> <CTRL-Z> rx> $res");

   # Capturo el codigo de retorno del modem GSM
   $cmd="AT";
   $res=to_modem($ttySx,$cmd);
$self->log('debug',"tx_sms::[DEBUG] tx> $cmd rx> $res");

	undef $ttySx;

	$self->err_str("OK");
	$self->log('info',"tx_sms::[OK] To:$to MSG=$subject (RC=$res)");
	return 1;

}

#--------------------------------------------------------
sub to_modem {
my ($ob,$cmd)=@_;

   $ob->write("$cmd\r");
   select (undef, undef, undef, 1);
   my $result = $ob->input;
   return $result;

}



#----------------------------------------------------------------------------
# tx_sms
#----------------------------------------------------------------------------
# returns 0->OK | >0->NOK
# Almacena rcstr
#----------------------------------------------------------------------------
sub tx_sms  {
my ($self,$rdata)=@_;
my ($res,$cmd);

   if (! defined $rdata->{to}) {
      $self->log('info',"tx_sms::[ERROR] No definido destino (to)");
      $self->err_str("ERROR (No definido destino)");
      return 1;
   }

   my $serial_port = (defined $rdata->{serial_port}) ? $rdata->{serial_port} : '/dev/ttyS0';
   my $pin = (defined $rdata->{pin}) ? $rdata->{pin} : '';

	my $file_debug='/tmp/chk_notificationsd.log';
	if (-f $file_debug) { unlink $file_debug; }


   # Confuguracion del puerto serie -------------------------------------------
   my $rcfgbase=$self->cfg();
   my $baudrate = (defined $rcfgbase->{'serial_port_baudrate'}) ? $rcfgbase->{'serial_port_baudrate'}->[0] : '9600';
   my $parity = (defined $rcfgbase->{'serial_port_parity'}) ? $rcfgbase->{'serial_port_parity'}->[0] : 'none';
   my $databits = (defined $rcfgbase->{'serial_port_databits'}) ? $rcfgbase->{'serial_port_databits'}->[0] : '8';
   my $stopbits = (defined $rcfgbase->{'serial_port_stopbits'}) ? $rcfgbase->{'serial_port_stopbits'}->[0] : '1';
   my $handshake = (defined $rcfgbase->{'serial_port_handshake'}) ? $rcfgbase->{'serial_port_handshake'}->[0] : 'xoff';


	my $gsm = new Device::Gsm( port => $serial_port, pin => $pin ,log => "file,$file_debug",
   	     loglevel => 'info',  # default is 'warning'
	);

   if (! $gsm) {
      $self->log('info',"tx_sms::[ERROR] No se puede conectar al puerto $serial_port");
      $self->err_str("ERROR (No se puede conectar al puerto $serial_port)");
      return 2;
   }

	my $con=$gsm->connect();
	my $reg=$gsm->register();
	if (!defined $reg) { 
      $self->log('info',"tx_sms::[ERROR] No se puede registrar en la red");
      $self->err_str("ERROR (No se puede registrar en la red)");
      return 3;
	}



   my $to = $rdata->{to};
   my $subject_raw=$self->subject();
   my $subject = encode('iso-8859-1', $subject_raw);
#   my $subject1 = encode('iso-8859-1', $subject_raw);
#	my $subject = substr($subject1,0,160);

#   if ($to =~ /^34/) { $to='+'.$to; }
#   if ($to !~ /^\+34/) { $to='+34'.$to; }


  	$res= $gsm->send_sms(
      recipient => $to,
      content   => $subject,
      class => 'normal'
  );



   $self->log('info',"tx_sms::[DEBUG] Uso $serial_port RATE=$baudrate|PARITY=$parity|DATA=$databits|STOP=$stopbits|HANDSHAKE=$handshake");

	if ($res) { 
   	$self->err_str("OK");
   	$self->log('info',"tx_sms::[OK] To:$to MSG=$subject (RC=$res)");
	}
	else {
      $self->err_str("ERR");
      $self->log('warning',"tx_sms::[ERROR] To:$to MSG=$subject (RC=$res)");
   }

   return 0;


}


1;
__END__

