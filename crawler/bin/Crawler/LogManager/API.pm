#-------------------------------------------------------------------------------------------
# Fichero: Crawler/LogManager/API.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
package Crawler::LogManager::API;
use Crawler::LogManager;
@ISA=qw(Crawler::LogManager);
use strict;
use Digest::MD5 qw(md5_hex);
use Data::Dumper;


#------------------------------------------------------------------------------------------
# init
# Prepara el objeto store y se conecta a la  B.D
#------------------------------------------------------------------------------------------
sub init {
my ($self)=@_;

	$self->create_store();
	$self->connect();

#   my $store=$self->store();
#   my $dbh=$store->open_db();
#   $self->dbh($dbh);
#   $store->dbh($dbh);
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


   my $event2alert=$store->get_cfg_api_remote_alerts($dbh);
   $self->event2alert($event2alert);

   #----------------------------------------------------------------------------------
   # EXPR en alertas remotas por api
   #----------------------------------------------------------------------------------
#SELECT a.id_remote_alert,a.expr as expr_logic, b.v,b.descr,b.fx,b.expr FROM cfg_remote_alerts a, cfg_remote_alerts2expr b WHERE a.id_remote_alert=b.id_remote_alert and a.type='api';

   my $alert2expr=$store->get_remote_alert_expr_by_type($dbh,'api');
   $self->alert2expr($alert2expr);

   # Mapeo IP a nombre
   my $ip2name=$store->get_ip2name_vector($dbh);
   $self->ip2name($ip2name);
}


#------------------------------------------------------------------------------------------
# check_alert
# Comprueba si el evento recibido por el api debe generar una alerta.
#------------------------------------------------------------------------------------------
sub check_alert {
my ($self)=@_;

   my $store=$self->store();
   my $dbh=$self->dbh();
	my $event=$self->event();

	my $alert2expr=$self->alert2expr();
	my $event2alert=$self->event2alert();
	my $ip2name=$self->ip2name();

#my $kk1=Dumper($event2alert);
#$kk1=~s/\n/ /g;
#$self->log('debug',"check_alert:: Las alertas remotas tipo api definidas (api2alert) son: $kk1");


   if (scalar(keys %$event2alert) ==  0) {
      $self->log('debug',"check_alert:: SIN ALERTAS REMOTAS TIPO API DEFINIDAS...");
      return;
   }

	my $ip = $event->{'ip'};
#	my $id_device = $event->{'id_dev'};
	my $msg = $event->{'msg'};
	my $evkey = $event->{'evkey'};
	my @vals=($msg);
	my $expr_logic='AND'; # REVISAR!!! FML
	my $critic = (exists $ip2name->{$ip}->{'critic'}) ? $ip2name->{ip}->{'critic'} : 50;
	my ($alert_id,$alert_date)=(0,0);

   #Si es una alerta de un dispositivo dado de alta pero no activo => No se genera la alerta
   if ((exists $ip2name->{$ip}) && ($ip2name->{$ip}->{'status'} !=0)) {
      $self->log('info',"check_alert::[INFO] ip=$ip evkey=$evkey **SALTO DISPOSITIVO NO ACTIVO**");
      return;
   }

   my $id_device = (exists $ip2name->{$ip}->{'id_dev'}) ? $ip2name->{$ip}->{'id_dev'} : $event->{'id_dev'};


   #Se itera sobre las alertas de tipo API configuradas y asociadas a algun dispositivo.
   #Si el evento cumple sus expresiones se genera alerta.
#      push @{$api2alert{$ev}}, {'subtype'=>$i->[0], 'target'=>$i->[1], 'monitor'=>$i->[2], 'vdata'=>$i->[3], 'action'=>$i->[4], 'severity'=>$i->[5], 'script'=>$i->[6], 'descr'=>$i->[7], 'id_remote_alert'=>$i->[8], 'expr'=>$i->[9], 'mode'=>$i->[10], 'ip'=>$i->[11], 'name'=>$i->[12], 'domain'=>$i->[13], 'set_id'=>$i->[15], 'set_type'=>$i->[16], 'set_subtype'=>$i->[17], 'set_hiid'=>$i->[18] };



   foreach my $ev  (@{$event2alert->{$evkey}->{$ip}}) {

		my $subtype=$ev->{'subtype'};
      my $target=$ev->{'target'};
      my $monitor=$ev->{'monitor'};
      my $vdata=$ev->{'vdata'};
      my $action=$ev->{'action'};
      my $severity=$ev->{'severity'};
      my $script=$ev->{'script'};
      my $descr=$ev->{'descr'};
      my $id_remote_alert=$ev->{'id_remote_alert'};
      my $expr=$ev->{'expr'};
      my $mode=$ev->{'mode'};
      my $name=$ev->{'name'};
      my $domain=$ev->{'domain'};
      my $mname=$subtype;
      my $type='api';
      my $label=$descr;
      my $id_metric=$id_remote_alert;

      my $set_id=$ev->{'set_id'};
      my $set_subtype=$ev->{'set_subtype'};
      my $set_hiid=$ev->{'set_hiid'};


		if (exists $event->{'iid'}) { $mname.='.'.$event->{'iid'}; }

		if (exists $alert2expr->{$id_remote_alert}) {

			$self->log('debug',"check_alert::[INFO] WATCH EVAL START id_remote_alert=$id_remote_alert expr_logic=$expr_logic");
my $kk=Dumper($alert2expr->{$id_remote_alert});
$kk=~s/\n/ /g;
$self->log('debug',"check_alert:: id_remote_alert=$id_remote_alert alert2expr=$kk");

	      my $condition_ok=$self->watch_eval_ext($alert2expr->{$id_remote_alert},$expr_logic,\@vals);

			$self->log('debug',"check_alert::[INFO] WATCH EVAL END id_remote_alert=$id_remote_alert watch_eval_ext RES=$condition_ok expr_logic=$expr_logic vals=@vals");

   	   if (! $condition_ok) {next; }
		}

		my $date_last=time();

      my $msg_log=substr $msg,0,250;
      $msg_log=~s/\n/\. /g;

      #Alertas nuevas
      my $cfg_mode=$mode;
      $mode=$id_remote_alert;
      my $ts=time();
      if ($cfg_mode ne 'INC') { $mode .= '.'.$ts; }

$self->log('info',"check_alert::[INFO] ***FML*** action=$action subtype=$subtype ip=$ip name=$name domain=$domain mname=$mname severity=$severity mode=$mode evkey=$evkey");


      # Procesado de alertas. SET ---------------------------------------------------------------
      # store_mode: 0->Insert 1->Update
      if ( $action =~ /SET/i ) {
 			($alert_id,$alert_date)=$store->store_alert($dbh,$monitor,{ 'ip'=>$ip, 'name'=>$name, 'domain'=>$domain, 'mname'=>$mname, 'severity'=>$severity, 'event_data'=>$msg, 'label'=>$label, 'cause'=>$label, 'type'=>$type, 'id_alert_type'=>20, 'id_metric'=>$id_metric, 'mode'=>$mode, 'subtype'=>$subtype, 'critic'=>$critic, 'date_last'=>$date_last, 'id_device'=>$id_device }, 1);
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

			$self->log('notice',"check_alert::[INFO] $monitor [SET-ALERT: $alert_id IP=$ip | cfg_mode=$cfg_mode | mode=$mode | EV=$evkey | MSG=$msg] response=$response");


      }

      # Procesado de alertas. CLEAR -------------------------------------------------------------
      elsif ( $action =~ /CLR/ ) {

#         $self->log('notice',"check_alert::[INFO] $monitor [CLEAR-ALERT: IP=$ip | EV=$ev | MSG=$msg]");
#         $store->clear_alert($dbh,{ 'ip'=>$ip, 'mname'=>$1 });

         my $id_metric_clr=0;
         # Se borra la original a partir del set_id.  Si no existe set_id, lo busco a partir de subtype + hiid
         if (($set_id =~ /^\d+$/) && ($set_id>0)) { $id_metric_clr=$set_id; }
         elsif ($set_subtype ne '') {
            my $cond = 'subtype="'.$set_subtype.'" && hiid="'.$set_hiid.'"';
            my $rv=$store->get_from_db($dbh,'id_remote_alert','cfg_remote_alerts',$cond);
            $id_metric_clr=$rv->[0][0];
         }

         $self->log('notice',"check_alert::[INFO] $monitor [CLEAR-ALERT: IP=$ip id_metric=$id_metric_clr| EV=$evkey | MSG=$msg_log] set_id=$set_id set_subtype=$set_subtype");
         $alert_id=$store->clear_alert($dbh,{ 'ip'=>$ip, 'id_metric'=>$id_metric_clr, 'type'=>'api' });

         #Se actualiza notif_alert_clear (notificationsd evalua si hay que enviar aviso)
         $store->store_notif_alert($dbh, 'clr', { 'id_alert'=>$alert_id, 'id_device'=>$id_device, 'id_alert_type'=>20, 'cause'=>$label, 'name'=>$name, 'domain'=>$domain, 'ip'=>$ip, 'notif'=>0, 'mname'=>$mname, 'watch'=>'', 'id_metric'=>$id_metric_clr, 'type'=>$type, 'severity'=>$severity, 'event_data'=>$msg, 'date'=>$date_last  });

         # Se actualizan las tablas del interfaz
         $store->store_alerts_read_local_clr($dbh,$alert_id);
         my $vk=$id_remote_alert.'.'.$ip;
         #if (exists $alert2views->{$vk}) { $store->analize_views_ruleset($dbh,$cid);  }
      }

      else {
         $self->log('warning',"check_alert::[WARN] $monitor [SIN ACCION (A=$action): IP=$ip | EV=$evkey | MSG=$msg]");
       }
   }


	return $alert_id;
}


1;
__END__
