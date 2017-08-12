#-------------------------------------------------------------------------------------------
# Fichero: Crawler/CNMAPI/Functions.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
package Crawler::CNMAPI::Functions;
use Crawler::CNMAPI;
@ISA=qw(Crawler::CNMAPI);
use strict;
use Digest::MD5 qw(md5_hex);
use Data::Dumper;

#-------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   return $self;
}

#------------------------------------------------------------------------------------------
# authenticate
# Realiza la autenticacion
#------------------------------------------------------------------------------------------
sub authenticate {
my ($self,$user,$pwd)=@_;

	my $sid = $self->ws_get_token($user,$pwd);
}

#------------------------------------------------------------------------------------------
# set_event
# Genera un evento
#//
#// curl -ki -H "Authorization: e57a3191d3a323adc0611fe2067e2610" -X POST "https://localhost/onm/api/1.0/events.json" -F "deviceid=1" -F "msg=TEST" -F "evkey=0001"
#//
#// POST /events.json -F "deviceid=1" -F "msg=TEST" -F "evkey=0001" => Crea un evento en el dispositivo con id 1 con mensaje TEST y evkey 0001
#// POST /events.json -F "deviceip=10.2.254.223" -F "msg=TEST" -F "evkey=0001" => Crea un evento en el dispositivo con ip 10.2.254.223 con mensaje TEST y evkey 0001
#// POST /events.json -F "devicename=cnm-devel2" -F "devicedomain=s30labsi.com" -F "msg=TEST" -F "evkey=0001" => Crea un evento en el dispositivo con ip 10.2.254.223 con mensaje TEST y evkey 0001
#// POST /events.json -F "msg=TEST" -F "evkey=0001" => Crea un evento en el dispositivo que ejecuta el API con mensaje TEST y evkey 0001
#// POST /events.json -F "msg=TEST" => Crea un evento en el dispositivo que ejecuta el API con mensaje TEST y el evkey se genera internamente
#// POST /events.json -F "msg=TEST" -F "campo1=valor1" -F "campo2=valor2" => Crea un evento en el dispositivo que ejecuta el API con mensaje TEST más una estructura json con campo1 y campo2 y el evkey se genera internamente
#
#
#------------------------------------------------------------------------------------------
sub set_event_by_ip{
my ($self,$ip,$msg,$evkey,$extra)=@_;

	my $sid = $self->sid();
	my %params = ('deviceip'=>$ip, 'txt'=>$msg, 'evkey'=>$evkey);
	foreach my $k (keys %$extra) {
		$params{$k}=$extra->{$k};
	} 

	my $class='';
 	my $endpoint='events.json';
	my $response = $self->ws_post($class,$endpoint,\%params);

	return $response;

}

#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------
sub get_device_by_id {
my ($self,$id_device)=@_;

   my $sid = $self->sid();

   my $class='devices';
   my $endpoint=$id_device.'.json';
   my $response = $self->ws_get($class,$endpoint);

   return $response;

}


#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------
sub get_views {
my ($self)=@_;

   my $sid = $self->sid();

   my $class='views';
   my $endpoint='search.json';
   my $response = $self->ws_put($class,$endpoint);

   return $response;

}

#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------
# DELETE
#------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------------
# curl -ki "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
# curl -ki -H "Authorization: c555e76fd03d91b5480e6d739c6cbb2e" -X DELETE => BASE
# 
# token=$(curl -k "https://localhost/onm/api/1.0/auth/token.json?u=admin&p=cnm123"|cut -d'"' -f6)
# curl -ki -H "Authorization: $token" -X DELETE => BASE
# 
# "https://localhost/onm/api/1.0/alerts/12.json"

#------------------------------------------------------------------------------------------
sub clear_alert_by_id {
my ($self,$id_alert)=@_;

   my $sid = $self->sid();

   my $class='alerts';
   my $endpoint=$id_alert.'.json';
   my $response = $self->ws_del($class,$endpoint);

   return $response;

}

1;
__END__
