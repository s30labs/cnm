#####################################################################################################
# Fichero: (Metrics::IPServ.pm)   $Id$
# Descripcion: Metrics::IPServ.pm
#----------------------------------------------------------------------------------------------------
# . Este modulo contiene las funciones que generan los descriptores txml de las metricas de tipo IP.
# Para incorporar nuevas metricas se deben seguir los siguientes pasos:
# 1. Debe existir el modulo capaz de obtenerla (en Monitor.pm, mon_xxx)
# 2. Se debe validar con la aplicacion correspondiente en libexec/mon_xxx
# 3. Se debe definir el generador de txml en este fichero
# 4. Se debe registrar en base de datos (cfg_monitor)
#####################################################################################################
package Metrics::IPServ;
$VERSION='1.00';
use strict;
#use Digest::MD5 qw(md5_hex);

#----------------------------------------------------------------------------
# Metricas de: DISP_xxx
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# disp_icmp
#----------------------------------------------------------------------------
sub disp_icmp {
my ($device,$rcfg,$subtype)=@_;


   #---------------------------------------------------------------
	my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : 'Disponibilidad basada en ICMP';
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='H0_SOLID';
   $Metrics::Base::METRIC{vlabel}='estado';
   $Metrics::Base::METRIC{module}='mod_monitor_ext:ext_dispo_base';
   $Metrics::Base::METRIC{values}='Disponible|No computable|No Disponible|Desconocido';
   $Metrics::Base::METRIC{monitor}='mon_icmp';
   $Metrics::Base::METRIC{params}='0';
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;
}



#----------------------------------------------------------------------------
# Metricas de: LATENCY_xxx
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
#sql INSERT INTO cfg_monitor (monitor,description,info,port,shtml) values ('mon_icmp', 'SERVICIO ICMP (ping)', 'Efectua 8 pings (icmp) de 64 bytes. Si pierde mas de 2 genera un error.', NULL, 'mon_icmp.shtml');

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
sub latency_icmp {
my ($device,$rcfg,$subtype)=@_;

   #---------------------------------------------------------------
	my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : 'Latencia ICMP';
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='STD_BASEIP1';
   $Metrics::Base::METRIC{vlabel}='segs';
   $Metrics::Base::METRIC{module}='mod_monitor';
   $Metrics::Base::METRIC{values}='Tiempo respuesta ICMP';
   $Metrics::Base::METRIC{monitor}='mon_icmp';
   $Metrics::Base::METRIC{params}='0';
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;
}

#----------------------------------------------------------------------------
#sql INSERT INTO cfg_monitor (monitor,description,info,port,shtml) values ('mon_dns', 'SERVICIO DNS (53)', 'Efectua un query DNS (registro A).', 53, 'mon_dns.shtml');
#----------------------------------------------------------------------------
sub latency_dns {
my ($device,$rcfg,$subtype)=@_;

	#params='rr=--RR--|port=--PORT--';
	my @params=();
   my $rr = (defined $rcfg->{'rr'}->[0]) ? $rcfg->{'rr'}->[0] : 'www.terra.es'; 	push @params, "rr=$rr";
   my $port = (defined $rcfg->{'port'}->[0]) ? $rcfg->{'port'}->[0] : '53';	push @params, "port=$port";

	#my $h=md5_hex("$rr$port");
	#$rcfg->{'metric_name'}= [ $subtype .'-'. substr $h,0,8 ];

   #---------------------------------------------------------------
	my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : 'Respuesta del DNS';
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='STD_BASEIP1';
   $Metrics::Base::METRIC{vlabel}='segs';
   $Metrics::Base::METRIC{module}='mod_monitor';
   $Metrics::Base::METRIC{values}='Tiempo respuesta DNS';
   $Metrics::Base::METRIC{monitor}='mon_dns';
   $Metrics::Base::METRIC{params}=join('|',@params);;
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;


}

#----------------------------------------------------------------------------
#sql insert into cfg_monitor (monitor,description,info,port,shtml) values ('mon_smtp', 'SERVICIO SMTP (25)', 'Efectua un HELO SMTP.', 25, 'mon_smtp.shtml');
#----------------------------------------------------------------------------
sub latency_smtp {
my ($device,$rcfg,$subtype)=@_;

   #params='port=--PORT--';
   my @params=();
   my $port = (defined $rcfg->{'port'}->[0]) ? $rcfg->{'port'}->[0] : '25'; push @params, "port=$port";

   #my $h=md5_hex("$port");
   #$rcfg->{'metric_name'}= [ $subtype .'-'. substr $h,0,8 ];

   #---------------------------------------------------------------
	my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : 'Respuesta del correo SMTP';
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='STD_BASEIP1';
   $Metrics::Base::METRIC{vlabel}='segs';
   $Metrics::Base::METRIC{module}='mod_monitor';
   $Metrics::Base::METRIC{values}='Tiempo respuesta SMTP';
   $Metrics::Base::METRIC{monitor}='mon_smtp';
   $Metrics::Base::METRIC{params}=join('|',@params);;
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;
}

#----------------------------------------------------------------------------
# insert into cfg_monitor (monitor,description,info,port,shtml) values ('mon_pop3', 'SERVICIO POP3 (110)', 'Efectua un login POP3. Requiere usuario y password.', 110, 'mon_pop3.shtml');
#----------------------------------------------------------------------------
sub latency_pop3 {
my ($device,$rcfg,$subtype)=@_;

   #params='user=--USER--|pwd=--PWD--|port=--PORT--';
   my @params=();
	my $user = (defined $rcfg->{'user'}->[0]) ? $rcfg->{'user'}->[0] : 'user'; push @params, "user=$user";
	my $pwd = (defined $rcfg->{'pwd'}->[0]) ? $rcfg->{'pwd'}->[0] : 'user'; push @params, "pwd=$pwd";
   my $port = (defined $rcfg->{'port'}->[0]) ? $rcfg->{'port'}->[0] : '110'; push @params, "port=$port";

   #my $h=md5_hex("$user$pwd$port");
   #$rcfg->{'metric_name'}= [ $subtype .'-'. substr $h,0,8 ];

   #---------------------------------------------------------------
	my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : 'Respuesta del correo POP3';
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='STD_BASEIP1';
   $Metrics::Base::METRIC{vlabel}='segs';
   $Metrics::Base::METRIC{module}='mod_monitor';
   $Metrics::Base::METRIC{values}='Tiempo respuesta POP3';
   $Metrics::Base::METRIC{monitor}='mon_pop3';
   $Metrics::Base::METRIC{params}=join('|',@params);;
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;
}


#----------------------------------------------------------------------------
#sql insert into cfg_monitor (monitor,description,info,port,shtml) values ('mon_imap', 'SERVICIO IMAP (143)', 'Efectua un login IMAP4. Requiere usuario y password', 143, 'mon_imap.shtml');
#----------------------------------------------------------------------------
sub latency_imap {
my ($device,$rcfg,$subtype)=@_;

   #params='user=--USER--|pwd=--PWD--|port=--PORT--';
   my @params=();
   my $user = (defined $rcfg->{'user'}->[0]) ? $rcfg->{'user'}->[0] : 'user'; push @params, "user=$user";
   my $pwd = (defined $rcfg->{'pwd'}->[0]) ? $rcfg->{'pwd'}->[0] : 'user'; push @params, "pwd=$pwd";
   my $port = (defined $rcfg->{'port'}->[0]) ? $rcfg->{'port'}->[0] : '143'; push @params, "port=$port";

   #my $h=md5_hex("$user$pwd$port");
   #$rcfg->{'metric_name'}= [ $subtype .'-'. substr $h,0,8 ];

   #---------------------------------------------------------------
	my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : 'Respuesta del correo IMAP';
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='STD_BASEIP1';
   $Metrics::Base::METRIC{vlabel}='segs';
   $Metrics::Base::METRIC{module}='mod_monitor';
   $Metrics::Base::METRIC{values}='Tiempo respuesta IMAP';
   $Metrics::Base::METRIC{monitor}='mon_imap';
   $Metrics::Base::METRIC{params}=join('|',@params);;
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;
}

#----------------------------------------------------------------------------
#sql insert into cfg_monitor (monitor,description,info,port,shtml) values ('mon_http', 'SERVICIO HTTP (80)', 'Hace una peticion HTTP (GET/POST). Genera un error si no hay respuesta.', 80, 'mon_http.shtml');
#----------------------------------------------------------------------------
sub latency_http {
my ($device,$rcfg,$subtype)=@_;

   #params='url=--URL--|url_type=--TYPE--|port=--PORT--|params=--PARAMS--';
   my @params=();
   my $n=$device->{name} || $device->{ip};
   my $url = (defined $rcfg->{'url'}->[0]) ? $rcfg->{'url'}->[0] : "http://$n"; push @params, "url=$url";
	my $url_type = (defined $rcfg->{'url_type'}->[0]) ? $rcfg->{'url_type'}->[0] : 'GET'; push @params, "url_type=$url_type";
	my $p= (defined $rcfg->{'params'}->[0]) ? $rcfg->{'params'}->[0] : ''; push @params, "params=$p";
   my $port = (defined $rcfg->{'port'}->[0]) ? $rcfg->{'port'}->[0] : '80'; push @params, "port=$port";

   #my $h=md5_hex("$n$url$url_type$p$port");
   #$rcfg->{'metric_name'}= [ $subtype .'-'. substr $h,0,8 ];

   #---------------------------------------------------------------
	my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : "Latencia del servidor WEB ($url)";
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='STD_BASEIP1';
   $Metrics::Base::METRIC{vlabel}='segs';
   $Metrics::Base::METRIC{module}='mod_monitor';
   $Metrics::Base::METRIC{values}='Tiempo respuesta WWW';
   $Metrics::Base::METRIC{monitor}='mon_http';
   $Metrics::Base::METRIC{params}=join('|',@params);;
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;
}



#----------------------------------------------------------------------------
#sql insert into cfg_monitor (monitor,description,info,port,shtml) values ('mon_httprc', 'SERVICIO HTTP - RESPUESTA DEL SERVIDOR (80)', 'Hace una peticion HTTP (GET/POST). Devuelve el codigo de respuesta del servidor segun el siguiente criterio: 1xx=>1, 2xx=>2, 3xx=>3 , 4xx=>4, 5xx=>5.', 80, 'mon_http.shtml');
#----------------------------------------------------------------------------
sub latency_httprc {
my ($device,$rcfg,$subtype)=@_;

   #params='url=--URL--|url_type=--TYPE--|port=--PORT--|params=--PARAMS--';
   my @params=();
   my $n=$device->{name} || $device->{ip};
   my $url = (defined $rcfg->{'url'}->[0]) ? $rcfg->{'url'}->[0] : "http://$n"; push @params, "url=$url";
   my $url_type = (defined $rcfg->{'url_type'}->[0]) ? $rcfg->{'url_type'}->[0] : 'GET'; push @params, "url_type=$url_type";
   my $p= (defined $rcfg->{'params'}->[0]) ? $rcfg->{'params'}->[0] : ''; push @params, "params=$p";
   my $port = (defined $rcfg->{'port'}->[0]) ? $rcfg->{'port'}->[0] : '80'; push @params, "port=$port";

   #my $h=md5_hex("$n$url$url_type$p$port");
   #$rcfg->{'metric_name'}= [ $subtype .'-'. substr $h,0,8 ];

   #---------------------------------------------------------------
   my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : "Respuesta HTTP del servidor WEB ($url)";
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='STD_BASEIP1';
   $Metrics::Base::METRIC{vlabel}='grupo';
   $Metrics::Base::METRIC{module}='mod_monitor';
   $Metrics::Base::METRIC{values}='Respuesta HTTP';
   $Metrics::Base::METRIC{monitor}='mon_httprc';
   $Metrics::Base::METRIC{params}=join('|',@params);;
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;
}


#----------------------------------------------------------------------------
#sql insert into cfg_monitor (monitor,description,info,port,shtml) values ('mon_httplinks', 'SERVICIO HTTP - RESPUESTA DEL SERVIDOR (80)', 'Hace una peticion HTTP (GET/POST). Devuelve el codigo de respuesta del servidor segun el siguiente criterio: 1xx=>1, 2xx=>2, 3xx=>3 , 4xx=>4, 5xx=>5.', 80, 'mon_httplinks.shtml');
#----------------------------------------------------------------------------
sub latency_httplinks {
my ($device,$rcfg,$subtype)=@_;

   #params='url=--URL--|url_type=--TYPE--|port=--PORT--|params=--PARAMS--';
   my @params=();
   my $n=$device->{name} || $device->{ip};
   my $url = (defined $rcfg->{'url'}->[0]) ? $rcfg->{'url'}->[0] : "http://$n"; push @params, "url=$url";
   my $url_type = (defined $rcfg->{'url_type'}->[0]) ? $rcfg->{'url_type'}->[0] : 'GET'; push @params, "url_type=$url_type";
   my $p= (defined $rcfg->{'params'}->[0]) ? $rcfg->{'params'}->[0] : ''; push @params, "params=$p";
   my $port = (defined $rcfg->{'port'}->[0]) ? $rcfg->{'port'}->[0] : '80'; push @params, "port=$port";

   #my $h=md5_hex("$n$url$url_type$p$port");
   #$rcfg->{'metric_name'}= [ $subtype .'-'. substr $h,0,8 ];

   #---------------------------------------------------------------
   my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : "Respuesta HTTP del servidor WEB ($url)";
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='STD_BASEIP1';
   $Metrics::Base::METRIC{vlabel}='num';
   $Metrics::Base::METRIC{module}='mod_monitor';
   $Metrics::Base::METRIC{values}='Respuesta HTTP';
   $Metrics::Base::METRIC{monitor}='mon_httplinks';
   $Metrics::Base::METRIC{params}=join('|',@params);;
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;
}

#----------------------------------------------------------------------------
#sql insert into cfg_monitor (monitor,description,info,port,shtml) values ('mon_httppage', 'SERVICIO HTTP - RESPUESTA DEL SERVIDOR (80)', 'Hace una peticion HTTP (GET/POST). Devuelve el codigo de respuesta del servidor segun el siguiente criterio: 1xx=>1, 2xx=>2, 3xx=>3 , 4xx=>4, 5xx=>5.', 80, 'mon_httppage.shtml');
#----------------------------------------------------------------------------
sub latency_httppage {
my ($device,$rcfg,$subtype)=@_;

   #params='url=--URL--|url_type=--TYPE--|port=--PORT--|params=--PARAMS--';
   my @params=();
   my $n=$device->{name} || $device->{ip};
   my $url = (defined $rcfg->{'url'}->[0]) ? $rcfg->{'url'}->[0] : "http://$n"; push @params, "url=$url";
   my $url_type = (defined $rcfg->{'url_type'}->[0]) ? $rcfg->{'url_type'}->[0] : 'GET'; push @params, "url_type=$url_type";
   my $p= (defined $rcfg->{'params'}->[0]) ? $rcfg->{'params'}->[0] : ''; push @params, "params=$p";
   my $port = (defined $rcfg->{'port'}->[0]) ? $rcfg->{'port'}->[0] : '80'; push @params, "port=$port";

   #my $h=md5_hex("$n$url$url_type$p$port");
   #$rcfg->{'metric_name'}= [ $subtype .'-'. substr $h,0,8 ];

   #---------------------------------------------------------------
   my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : "Respuesta HTTP del servidor WEB ($url)";
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='STD_BASEIP1';
   $Metrics::Base::METRIC{vlabel}='diffs';
   $Metrics::Base::METRIC{module}='mod_monitor';
   $Metrics::Base::METRIC{values}='Respuesta HTTP';
   $Metrics::Base::METRIC{monitor}='mon_httppage';
   $Metrics::Base::METRIC{params}=join('|',@params);;
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;
}

#----------------------------------------------------------------------------
#sql insert into cfg_monitor (monitor,description,info,port,shtml) values ('mon_ssh', 'SERVICIO SSH (22)', 'Obtiene el banner inicial de una sesion SSH', 22, 'mon_ssh.shtml');
#----------------------------------------------------------------------------
sub latency_ssh {
my ($device,$rcfg,$subtype)=@_;

   #params='port=--PORT--';
   my @params=();
   my $port = (defined $rcfg->{'port'}->[0]) ? $rcfg->{'port'}->[0] : '22'; push @params, "port=$port";

   #my $h=md5_hex("$port");
   #$rcfg->{'metric_name'}= [ $subtype .'-'. substr $h,0,8 ];

   #---------------------------------------------------------------
	my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : 'Respuesta del servicio SSH';
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='STD_BASEIP1';
   $Metrics::Base::METRIC{vlabel}='segs';
   $Metrics::Base::METRIC{module}='mod_monitor';
   $Metrics::Base::METRIC{values}='Tiempo respuesta SSH';
   $Metrics::Base::METRIC{monitor}='mon_ssh';
   $Metrics::Base::METRIC{params}=join('|',@params);;
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;
}


#----------------------------------------------------------------------------
#sql insert into cfg_monitor (monitor,description,info,port,shtml) values ('mon_tcp', 'SERVICIO TCP', 'Envia un TCP SYN al puerto servidor especificado.', NULL, 'mon_tcp.shtml');
#----------------------------------------------------------------------------
sub latency_tcp {
my ($device,$rcfg,$subtype)=@_;

   #params='port=--PORT--';
   my @params=();
   my $port = (defined $rcfg->{'port'}->[0]) ? $rcfg->{'port'}->[0] : '22'; push @params, "port=$port";

   #my $h=md5_hex("$port");
   #$rcfg->{'metric_name'}= [ $subtype .'-'. substr $h,0,8 ];

   #---------------------------------------------------------------
	my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : "Respuesta del puerto TCP $port";
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='STD_BASEIP1';
   $Metrics::Base::METRIC{vlabel}='segs';
   $Metrics::Base::METRIC{module}='mod_monitor';
   $Metrics::Base::METRIC{values}="Tiempo respuesta puerto TCP $port";
   $Metrics::Base::METRIC{monitor}='mon_tcp';
   $Metrics::Base::METRIC{params}=join('|',@params);;
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;
}


#----------------------------------------------------------------------------
#sql INSERT INTO cfg_monitor (monitor,description,info,port,shtml) VALUES  ('mon_smb', 'ACCESO A FICHERO POR SMB/CIFS', 'Comprueba la existencia de un fichero compartido por SMB/CIFS. Reporta el tamano  mismo', 135, 'mon_smb.shtml');
#----------------------------------------------------------------------------
sub latency_smb {
my ($device,$rcfg,$subtype)=@_;

   #params='user=--USER--|pwd=--PWD--|share=--SHARE--|f=--FILE--';
   my @params=();
   my $user = (defined $rcfg->{'user'}->[0]) ? $rcfg->{'user'}->[0] : 'user'; push @params, "user=$user";
   my $pwd = (defined $rcfg->{'pwd'}->[0]) ? $rcfg->{'pwd'}->[0] : 'user'; push @params, "pwd=$pwd";
   my $share = (defined $rcfg->{'share'}->[0]) ? $rcfg->{'share'}->[0] : ''; push @params, "share=$share";
   my $f = (defined $rcfg->{'f'}->[0]) ? $rcfg->{'f'}->[0] : ''; push @params, "f=$f";

   #my $h=md5_hex("$user$pwd$share$f");
   #$rcfg->{'metric_name'}= [ $subtype .'-'. substr $h,0,8 ];

   #---------------------------------------------------------------
	my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : 'Acceso a fichero por SMB/CIFS';
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='STD_BASEIP1';
   $Metrics::Base::METRIC{vlabel}='bytes';
   $Metrics::Base::METRIC{module}='mod_monitor';
   $Metrics::Base::METRIC{values}='Tiempo de acceso';
   $Metrics::Base::METRIC{monitor}='mon_smb';
   $Metrics::Base::METRIC{params}=join('|',@params);;
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;
}

#----------------------------------------------------------------------------
#sql INSERT INTO cfg_monitor (monitor,description,info,port,shtml) VALUES  ('mon_ntp', 'SERVICIO NTP (123)', 'Hace una peticion NTP', 123, 'mon_ntp.shtml');
#----------------------------------------------------------------------------
sub latency_ntp {
my ($device,$rcfg,$subtype)=@_;

   #params='port=--PORT--';
   my @params=();
   my $port = (defined $rcfg->{'port'}->[0]) ? $rcfg->{'port'}->[0] : '123'; push @params, "port=$port";

   #my $h=md5_hex("$port");
   #$rcfg->{'metric_name'}= [ $subtype .'-'. substr $h,0,8 ];

   #---------------------------------------------------------------
	my $label = (defined $rcfg->{'label'}->[0]) ? $rcfg->{'label'}->[0] : 'Respuesta del servicio NTP';
   $Metrics::Base::METRIC{label}=$label;
   $Metrics::Base::METRIC{mtype}='STD_BASEIP1';
   $Metrics::Base::METRIC{vlabel}='segs';
   $Metrics::Base::METRIC{module}='mod_monitor';
   $Metrics::Base::METRIC{values}='Tiempo respuesta NTP';
   $Metrics::Base::METRIC{monitor}='mon_ntp';
   $Metrics::Base::METRIC{params}=join('|',@params);;
   $Metrics::Base::METRIC{mode}='GAUGE';
   $Metrics::Base::METRIC{top_value}=1;
   #---------------------------------------------------------------
   my $m=&Metrics::Base::m2txml_ipserv($device,$rcfg,$subtype);
   return $m;
}



1;
__END__
