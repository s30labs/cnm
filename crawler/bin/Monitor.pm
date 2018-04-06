####################################################################################
# Fichero: $Id: Monitor.pm,v 1.2 2004/02/18 13:22:30 fml Exp $ 
# Revision: Ver $VERSION
#-----------------------------------------------------------------------------------
# PASOS A SEGUIR PARA INCLUIR UN NUEVO MONITOR
#
#  1. Codificarlo con un nombre no utilizado y respetando el formato de parametros IN/OUT.
#		Incluirlo en el array @EXPORT_OK.
#		Crear en libexec las rutinas adecuadas: mon_xxx para validar el monitor.
#
#  2. Incluirlo en la tabla cfg_monitor. (en /var/www/html/onm/db/Init/DB-Scheme-Init-tcp.php) 
#
#	      array(
#			 //NOMBRE DEL MONITOR
#         'monitor' => 'mon_httprc',
#			 //DESCRIPCION DEL MONITOR
#         'description' => 'SERVICIO WEB - RESPUESTA DEL SERVIDOR (80)',
#			 //INFO DEL MONITOR
#         'info' => 'Hace una peticion HTTP/HTTPS (GET/POST). Devuelve el codigo de respuesta del servidor segun el siguiente criterio: 1xx=>1, 2xx=>2, 3xx=>3 , 4xx=>4, 5xx=>5.',
#			 //PUERTO DEL MONITOR
#         'port' => '80',
#			 //NOMBRE DEL FORMULARIO ESPECIFICO PARA DICHO MONITOR (debe estar en /var/www/html/onm/conf_latency/)
#         'shtml' => 'mon_httprc.shtml',
#			 //SUBTIPO
#         'subtype' => 'mon_httprc',
#			 //PARAMETROS DEL MONITOR. DEBEN SER ACORDES A LOS DEL FORMULARIO (.shtml)
#         'params' => 'url|url_type|port|url_params|use_proxy|proxy_user|proxy_pwd|proxy_host|proxy_port|use_realm|realm_user|realm_pwd',
#			 //SEVERIDAD DEL MONITOR
#         'severity' => '1',
#      ),
#
#	3. Crear el formulario especifico para poder configurar dicho monitor. 
#		Es el que se ha definido antes en el campo shtml y debe estar en /var/www/html/onm/conf_latency/
#		
#	4. Revisar que funciona validar metrica desde interfaz web.
#
#	5. Crear los generadores para dicha metrica.
#
#		En Metrics/IPServ.pm Incluir la rutina correspondiente a la funcion generadora. (En este 
#		punto se definen los parametros que definen el tipo de grafica, vlabel, xlabel ....)
#
#		Incluir en el hash %Functions la referencia a la funcion generadora del xml
#		p. ej: 'mon_httprc' => \&Metrics::IPServ::latency_httprc,
#
#	NOTA: En muchas partes, las metricas tcp/ip se chequean con una regex del tipo: /w_mon_\w+/
#			Por tanto es muy desaconsejable definirlos con nombres que no cumplan dicha expresion.
#
####################################################################################
# TODO:
#	1. En mon_httppage se utiliza fichero temporal /tmp/new ==> Revisarlo para salvar los
#		problemas de concurrencia.
####################################################################################
#	En $desc->{'debug_data'} Se puede poner la info de debug que sea necesaria
####################################################################################
package Monitor;
use strict;
use LWP;
use WWW::Mechanize;
use Net::Ping;
#use Net::POP3;
use Mail::POP3Client;
use Net::SMTP;
use Net::IMAP::Simple;
use Net::DNS;
use Net::LDAP;
#use Net::Oping;
use IO::Socket;
use Socket;
use Algorithm::Diff qw(diff);
use Time::HiRes qw(gettimeofday tv_interval);
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;

@EXPORT_OK = qw (mon_http mon_httprc mon_httplinks mon_httppage mon_icmp disp_icmp mon_pop3 mon_smtp mon_imap mon_dns mon_tcp mon_ssh mon_smb mon_ntp mon_snmp mon_icmp_system mon_ldap mon_ldap_attr mon_ldap_val mon_ip_icmp2 mon_ip_icmp3);

@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);
$VERSION = '1.00';

#-----------------------------------------------------------------------------------
$Monitor::RESULT='';
$Monitor::RC='';
$Monitor::RCSTR='';
$Monitor::PAGE='';
$Monitor::Agent='cnm-monitor';
$Monitor::PAGES_DIR='/opt/data/httppage';

#-----------------------------------------------------------------------------------
# Funcion de callback para capturar los errores de WWW:Mechanize
sub ferror {
   $Monitor::RC=1;
   $Monitor::RCSTR=join(" ",@_);
   $Monitor::RESULT='U';
}
#---------------------------


#-----------------------------------------------------------------------------------
# Formato de salida de los monitores
# 1047577725:0.369833 [OK: www.dominio.com->17.26.47.03]
#-----------------------------------------------------------------------------------


#-----------------------------------------------------------------------------------
# Rutina auxliar para validar los parametros de los diferentes monitores http
# Parametros:
# 		1. Generales: $desc->{url_type} $desc->{port} $desc->{params} $desc->{url} $desc->{page}
#		2.	Para el proxy: $desc->{use_proxy} $desc->{proxy_user} $desc->{proxy_pwd} $desc->{proxy_host} $desc->{proxy_port}
#		3.	Para el realm: $desc->{use_realm} $desc->{realm_user} $desc->{realm_pwd}
#		4. Particulares para mon_httppage:	$desc->{page}
#
# IN: 1. Hash con los parametros
#		2.	Monitor concreto que hace la llamada. Notar que puede haber parametros particulares de cada monitor.
#		3.	Ref. a array con los resultados (solo en el caso de que los parametros no sean validos)
#
# La llamada a la funcion debe ser del tipo:
#
#	_validate_http_params($desc,$monitor,\@R);
#	if ($desc->{'rc'} eq 'U') { return \@R; }
#  if ($desc->{'rc'} eq 'U') { return \@R; }
#	my $url=$desc->{url};
# 	if ($desc->{use_proxy}) {}
# 	if ($desc->{use_realm}) {}
#
# NOTA: Para https se requiere Crypt::SSLeay
#-----------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------
sub _validate_http_params {
my ($desc,$monitor,$results)=@_;

   my $method = ($desc->{url_type}) ? uc $desc->{url_type}  : "GET";
	$desc->{url_type}=$method;

   #my $port = ($desc->{port}) ? $desc->{port}  : '80';	
	#$desc->{port}=$port;
	#$desc->{params} No se valida

   $desc->{'time'}=time;
	my $t=$desc->{'time'};
   $desc->{'rcstr'}='';
   $desc->{'rc'}='';

   #--------------------------------------------------------------------------------
   if (! defined $desc->{'url'}) {
      my $rcstr='[ERROR: No definida url]';
      $desc->{'rcstr'}=$rcstr;
      $desc->{'rc'}='U';
      push @$results, "$t:U $rcstr";
      return $results;
   }
   elsif ($desc->{'url'} !~ /http(?:s*)\:\/\//) {
      my $rcstr="[ERROR: Mal definida url $desc->{url}]";
      $desc->{'rcstr'}=$rcstr;
      $desc->{'rc'}='U';
      push @$results, "$t:U $rcstr";
      return $results;
   }

   if  (! $desc->{'port'}) {
      if ($desc->{'url'} =~ /https/) { $desc->{'port'}='443'; }
      elsif($desc->{'url'} =~  /http/) { $desc->{'port'}='80'; }
      else { $desc->{'port'}='80'; }
   }
   my $uri = URI->new($desc->{'url'});
   $uri->port($desc->{'port'});
   my $url=$uri->as_string();
   $desc->{url}=$url;
	$desc->{scheme}=$uri->scheme();
	

	#--------------------------------------------------------------------------------
	if ($monitor eq 'mon_httppage') {

     # if ( (!defined $desc->{page}) || (! $desc->{page})) {
     #    my $rcstr='[ERROR: No definida pagina de chequeo]';
     #    $desc->{'rcstr'}=$rcstr;
     #    $desc->{'rc'}='U';
     #    push @$results, "$t:U $rcstr";
     #    return $results;
     # }

		$desc->{'page'}= $desc->{'url'};
		$desc->{'page'} =~ s/\//_/g; 
      my $pfile=$Monitor::PAGES_DIR.'/'.$desc->{'page'};
		if (! -f $pfile ) {

			my $rr=mon_http($desc);

			if (! $Monitor::PAGE) {
      	   my $rcstr='[ERROR: No se obtiene la pagina de chequeo]';
      	  # my $rcstr=$Monitor::PAGE;
         	$desc->{'rcstr'}=$rcstr;
	         $desc->{'rc'}='U';
   	      push @$results, "$t:U $rcstr";
      	   return $results;
			}

			if (! -d $Monitor::PAGES_DIR) { mkdir $Monitor::PAGES_DIR; }

		  	if ( open(FH,">$pfile" ) ) {
				print FH $Monitor::PAGE;
      	   close FH;
	  		}
			else {
	        	my $rcstr="[ERROR: No existe la pagina de chequeo $pfile ($!)]";
   	      $desc->{'rcstr'}=$rcstr;
  	  		   $desc->{'rc'}='U';
      		push @$results, "$t:U $rcstr";
     			return $results;
			}
		}
	}

	#--------------------------------------------------------------------------------
	if ( (defined $desc->{use_proxy}) && ($desc->{use_proxy})) {
		if (! defined $desc->{proxy_user})  {
	      my $rcstr='[ERROR: No definido usuario de proxy]';
   	   $desc->{'rcstr'}=$rcstr;
      	$desc->{'rc'}='U';
      	push @$results, "$t:U $rcstr";
	  	 	return $results;
		}
      if (! defined $desc->{proxy_pwd})  {
         my $rcstr='[ERROR: No definida clave del usuario de proxy]';
         $desc->{'rcstr'}=$rcstr;
         $desc->{'rc'}='U';
         push @$results, "$t:U $rcstr";
         return $results;
      }
      if (! defined $desc->{proxy_host})  {
         my $rcstr='[ERROR: No definida la IP del proxy]';
         $desc->{'rcstr'}=$rcstr;
         $desc->{'rc'}='U';
         push @$results, "$t:U $rcstr";
         return $results;
      }
      if (! defined $desc->{proxy_port})  {
         my $rcstr='[ERROR: No definido el puerto del proxy]';
         $desc->{'rcstr'}=$rcstr;
         $desc->{'rc'}='U';
         push @$results, "$t:U $rcstr";
         return $results;
      }
		$desc->{use_proxy}=1;
		$desc->{proxy_url}=$desc->{scheme}.'://'.$desc->{proxy_user}.':'.$desc->{proxy_pwd}.'@'.$desc->{proxy_host}.':'.$desc->{proxy_port};


   }

	#--------------------------------------------------------------------------------
   if ( (defined $desc->{use_realm}) && ($desc->{use_realm}) ) {
		if (! defined $desc->{realm_user})  {
         my $rcstr='[ERROR: No definido usuario para autenticacion en servidor (realm)]';
         $desc->{'rcstr'}=$rcstr;
         $desc->{'rc'}='U';
         push @$results, "$t:U $rcstr";
         return $results;
      }
      if (! defined $desc->{realm_pwd})  {
         my $rcstr='[ERROR: No definida clave para autenticacion en servidor (realm)]';
         $desc->{'rcstr'}=$rcstr;
         $desc->{'rc'}='U';
         push @$results, "$t:U $rcstr";
         return $results;
      }
		$desc->{'use_realm'}=1;
   }

}

#-----------------------------------------------------------------------------------
# mon_http
# IN :   \%H Referencia a un hash con datos -> $H{url}, $H{port}, $H{url_type}, $H{params}
# OUT:   \@R Referencia a un array que contiene una cadena del tipo: timestamp:timelatency $rcstr
#        $H{rcdata} contiene la pagina solicitada
#        $H{rc} contiene el codigo de retorno del servidor web
#        $H{rcstr} contiene la cadena que indica la respuesta del servidor web
#        $H{elapsed} contiene la duracion de la respuesta (latencia)
#        $H{time} contiene el timestamp en el que se ha generado la medida
#        $H{error} 0->ok y 1->error
# IMPORTANTE:
#        $H{rc},$H{rcstr},$H{time} son necesarios cuando mon_http es llamada por mon_httprc

#-----------------------------------------------------------------------------------
sub mon_http {
my $desc=shift;
my $TIMEOUT=3;
my $t=time;
my $t0 = [gettimeofday];
my $elapsed=0;
my @R=();

	$Monitor::PAGE='';
	$Monitor::RESULT='';
	$Monitor::RC='';
	$Monitor::RCSTR='';

   use Crawler;
   my $LOG=Crawler->new( log_level=>'debug' );

   _validate_http_params($desc,'mon_http',\@R);
   if ($desc->{'rc'} eq 'U') { return \@R; }
   my $url=$desc->{url};

   $desc->{'rcstr'}='[OK]';
   $desc->{'error'}=0;
   $elapsed = tv_interval ( $t0, [gettimeofday]);
   my $elapsed3 = sprintf("%.6f", $elapsed);
   $desc->{'elapsed'}=$elapsed3;

#$LOG->log('debug',"mon_http:: **DEBUG** TIMEOUT=$TIMEOUT (1)");
#print 'METHOD='.$desc->{url_type}.' | PORT='.$desc->{port}.' | PARAMS='.$desc->{params}.' | URL='.$url."\n";
   my $mech = WWW::Mechanize->new( autocheck => 1, ssl_opts => { verify_hostname => 0 }, timeout => $TIMEOUT, keep_alive=>1, agent => $Monitor::Agent, onerror => \&ferror );
	#$mech->agent_alias($Monitor::Agent);

   if ($desc->{use_realm}) {
      my $u=$desc->{realm_user};
      my $p=$desc->{realm_pwd};
		#print "REALM>> U=$u P=$p\n";
      #$mech->credentials( $desc->{realm_user} => $desc->{realm_pwd}  );
		
      my $hh='';
      if ($url=~/^(http|https)+:\/\/(\S+:*\d*)\/.*$/) { $hh=$2; }
      #print "REALM>> url=$url hh=$hh U=$u P=$p\n";
      $mech->credentials( $hh, 'Some Realm', $u, $p  );

   }

	if ($desc->{use_proxy}) { 
		#print 'PROXY>> S='.$desc->{scheme}.' P='.$desc->{proxy_url}."\n";
		$mech->proxy( $desc->{scheme}, $desc->{proxy_url} ); 
		#$mech->proxy( ['http', 'ftp'] => 'user:pwd@proxy.domain:port' );
	}
#$LOG->log('debug',"mon_http:: **DEBUG** TIMEOUT=$TIMEOUT (2)");

	#my $res=$mech->get( $url);

	my $res;
	$SIG{ALRM} = sub { die "timeout" };
	eval {
		alarm($TIMEOUT);
   	$res=$mech->get( $url);
		alarm(0);
   };

   if ($@) { my $rcstr="[ERROR: Timeout]"; }


   $Monitor::PAGE=$res->decoded_content;
	$Monitor::PAGE=~s/\r//g;
#$LOG->log('debug',"mon_http:: **DEBUG** TIMEOUT=$TIMEOUT (3)");

	#Obtiene codigo de retorno
   my $error=$mech->res->status_line;
   $error=~/(\d+)\s+(.*)$/;
   $desc->{'rc'}=$1;
   #$desc->{'rcstr'}=$2;
   #$desc->{'rcdata'}=$mech->res->content;
   $desc->{'rcdata'}=$Monitor::PAGE;

   if ($Monitor::RESULT eq 'U') { 
      $desc->{'error'}=1;
      $desc->{'rcstr'}="[ERROR: $Monitor::RCSTR]";
		#push @R, $desc->{time}.':'.$Monitor::RESULT.' [ERROR: '.$Monitor::RCSTR.']';  
		push @R, $desc->{time}.':'.$Monitor::RESULT.' [ERROR: '.$desc->{'rc'}.' '.$Monitor::RCSTR.']';
	}
   else { 
      $desc->{'rcstr'}='[OK]';
      $desc->{'error'}=0;
      #print $response->content;
      $elapsed = tv_interval ( $t0, [gettimeofday]);
      my $elapsed3 = sprintf("%.6f", $elapsed);
      $desc->{'elapsed'}=$elapsed3;
      push @R, "$t:$elapsed3 ".$desc->{'rcstr'};
      #$desc->{'rcdata'}=$response->content;

   	my @links = $mech->links();
		$desc->{'nlinks'}=scalar @links;
	}
#$LOG->log('debug',"mon_http:: **DEBUG** TIMEOUT=$TIMEOUT (4)");

   return \@R;
}



#-----------------------------------------------------------------------------------
# mon_httprc
# IN :   \%H Referencia a un hash con datos -> $H{url}, $H{port}, $H{url_type}, $H{params}
# OUT:   \@R Referencia a un array que contiene una cadena del tipo: timestamp:timelatency $rcstr
#        $H{rcdata} contiene la pagina solicitada
#        $H{rc} contiene el codigo de retorno del servidor web
#        $H{rcstr} contiene la cadena que indica la respuesta del servidor web
#        $H{elapsed} contiene la duracion de la respuesta (latencia)
#        $H{time} contiene el timestamp en el que se ha generado la medida
#-----------------------------------------------------------------------------------
#Segun indica la RFC 2616
#1xx: Informational 1xx
#This class of status code indicates a provisional response, consisting only of the Status-Line and optional headers, and is terminated by an empty line
#100 Continue
#101 Switching Protocols
#2xx Successful
#This class of status code indicates that the client's request was successfully received, understood, and accepted.
#200 OK
#201 Created
#202 Accepted
#203 Non-Authoritative Information
#204 No Content
#205 Reset Content
#206 Partial Content
#3xx Redirection
#This class of status code indicates that further action needs to be taken by the user agent in order to fulfill the request.
#300 Multiple Choices
#301 Moved Permanently
#302 Found
#303 See Other
#304 Not Modified
#305 Use Proxy
#306 (Unused)
#307 Temporary Redirect
#
#4xx Client Error
#The 4xx class of status code is intended for cases in which the client seems to have erred.
#400 Bad Request
#401 Unauthorized
#402 Payment Required
#403 Forbidden
#404 Not Found
#405 Method Not Allowed
#406 Not Acceptable
#408 Request Timeout
#409 Conflict
#410 Gone
#411 Length Required
#412 Precondition Failed
#413 Request Entity Too Large
#414 Request-URI Too Long
#415 Unsupported Media Type
#416 Requested Range Not Satisfiable
#417 Expectation Failed
#
#10.5 Server Error 5xx
#Response status codes beginning with the digit "5" indicate cases in which the server is aware that it has erred or is incapable of performing the request.
#500 Internal Server Error
#501 Not Implemented
#502 Bad Gateway
#503 Service Unavailable
#504 Gateway Timeout
#505 HTTP Version Not Supported
#-----------------------------------------------------------------------------------
sub mon_httprc {
my $desc=shift;

   mon_http($desc);

   my $rc='U';
   if ($desc->{'rc'} ne 'U') { $rc=int ($desc->{'rc'}/100); }

	my @R=();
   push @R, $desc->{'time'}.':'.$rc.' '.$desc->{'rcstr'};

   return \@R;

}


#-----------------------------------------------------------------------------------
# mon_httplinks
# IN :   \%H Referencia a un hash con los datos.
#				a. Datos necesarios -> $H{url}, $H{port}, $H{url_type}, $H{params}
#				b. Datos particulares (proxy, realm ...)
# OUT:   \@R Referencia a un array que contiene una cadena del tipo: timestamp:timelatency $rcstr
#        $H{rc} contiene el codigo de retorno del servidor web
#        $H{rcstr} contiene la cadena que indica la respuesta del servidor web
#        $H{elapsed} contiene la duracion de la respuesta (latencia)
#        $H{time} contiene el timestamp en el que se ha generado la medida

#-----------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------
sub mon_httplinks {
my $desc=shift;
my $TIMEOUT=3;
my $t=time;
my $t0 = [gettimeofday];
my $elapsed=0;
my @R=();

	$Monitor::PAGE='';
   $Monitor::RESULT='';
   $Monitor::RC='';
   $Monitor::RCSTR='';

	_validate_http_params($desc,'mon_httplinks',\@R);
	if ($desc->{'rc'} eq 'U') { return \@R; }
	my $method = $desc->{url_type};
	my $url=$desc->{url};
	my $port = $desc->{port};
	my $params = $desc->{params};

   $desc->{'rcstr'}='[OK]';
   $desc->{'error'}=0;
   $elapsed = tv_interval ( $t0, [gettimeofday]);
   my $elapsed3 = sprintf("%.6f", $elapsed);
   $desc->{'elapsed'}=$elapsed3;

#print 'METHOD='.$desc->{url_type}.' | PORT='.$desc->{port}.' | PARAMS='.$desc->{params}.' | URL='.$url."\n";
	my $mech = WWW::Mechanize->new( autocheck => 1, ssl_opts => { verify_hostname => 0 }, timeout => $TIMEOUT, keep_alive=>1, agent => $Monitor::Agent, onerror => \&ferror );
	#$mech->agent_alias($Monitor::Agent);

   if ($desc->{use_realm}) {
      my $u=$desc->{realm_user};
      my $p=$desc->{realm_pwd};
      #print "REALM>> U=$u P=$p\n";
      $mech->credentials( $desc->{realm_user} => $desc->{realm_pwd}  );
   }

   if ($desc->{use_proxy}) {
      #print 'PROXY>> S='.$desc->{scheme}.' P='.$desc->{proxy_url}."\n";
      $mech->proxy( $desc->{scheme}, $desc->{proxy_url} );
      #$mech->proxy( ['http', 'ftp'] => 'user:pwd@proxy.domain:port' );
   }

	$mech->get( $url);
   $Monitor::PAGE=$mech->decoded_content;
	$Monitor::PAGE=~s/\r//g;

	my @links = $mech->links();

	my $N=scalar @links;

	if ($Monitor::RESULT eq 'U') { push @R, $desc->{time}.':'.$Monitor::RESULT.' [ERROR: '.$Monitor::RCSTR.']';  }
	else { push @R, $desc->{time}.':'.$N.' [OK]';}

#print "N=$N\n";
   return \@R;

}



#-----------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------
sub mon_httppage {
my $desc=shift;
my $TIMEOUT=3;
my $t=time;
my $t0 = [gettimeofday];
my $elapsed=0;
my @R=();

	$Monitor::PAGE='';
   $Monitor::RESULT='';
   $Monitor::RC='';
   $Monitor::RCSTR='';

   _validate_http_params($desc,'mon_httppage',\@R);
   if ($desc->{'rc'} eq 'U') { return \@R; }
   my $method = $desc->{url_type};
   my $url=$desc->{url};
   my $port = $desc->{port};
   my $params = $desc->{params};
	my $page_file=$desc->{page};

   $desc->{'rcstr'}='[OK]';
   $desc->{'error'}=0;
   $elapsed = tv_interval ( $t0, [gettimeofday]);
   my $elapsed3 = sprintf("%.6f", $elapsed);
   $desc->{'elapsed'}=$elapsed3;

#print 'METHOD='.$desc->{url_type}.' | PORT='.$desc->{port}.' | PARAMS='.$desc->{params}.' | URL='.$url."\n";
   my $mech = WWW::Mechanize->new( autocheck => 1, ssl_opts => { verify_hostname => 0 }, timeout => $TIMEOUT, keep_alive=>1, agent => $Monitor::Agent, onerror => \&ferror );
	#$mech->agent_alias($Monitor::Agent);

   if ($desc->{use_realm}) {
      my $u=$desc->{realm_user};
      my $p=$desc->{realm_pwd};
      #print "REALM>> U=$u P=$p\n";
      $mech->credentials( $desc->{realm_user} => $desc->{realm_pwd}  );
   }
   if ($desc->{use_proxy}) {
      #print 'PROXY>> S='.$desc->{scheme}.' P='.$desc->{proxy_url}."\n";
      $mech->proxy( $desc->{scheme}, $desc->{proxy_url} );
      #$mech->proxy( ['http', 'ftp'] => 'user:pwd@proxy.domain:port' );
   }

   $mech->get( $url);
	my $page2 = $mech->res->decoded_content; 
	$page2=~s/\r//g;

	if ( open(FH,">/tmp/new" ) ) {
		print FH $page2;
		close FH;
	}

   open (P, "</tmp/new");
   my @page_new=<P>;
   close P;


	my $error=$mech->res->status_line;
   $error=~/(\d+)\s+(.*)$/;
   $desc->{'rc'}=$1;
   #$desc->{'rcstr'}=$2;
   $desc->{'rcdata'}=$mech->res->decoded_content;
	$desc->{'rcdata'}=~s/\r//g;

	if ( $mech->success() ) {

		my $pfile=$Monitor::PAGES_DIR.'/'.$desc->{'page'};
		open (P, $pfile);
		my @page_old=<P>;
		close P;
		my $diffs = diff(\@page_old, \@page_new);

#if ( open(FH,">/tmp/new" ) ) {
#print FH @page_new;
#close FH;
#}
#if ( open(FH,">/tmp/old" ) ) {
#print FH @page_old;
#close FH;
#}

		my $c=0;
		foreach my $chunk (@$diffs) {
  			foreach my $line (@$chunk) {
   			 #my ($sign, $lineno, $text) = @$line;
   		 	#printf "%4d$sign %s\n", $lineno+1, $text;
   			$c+=1;
  			}
		}

		push @R, $desc->{time}.':'.$c.' [OK]';
#print 'DIFFS='. scalar @$diffs. "\n";

	}
	else {

      $desc->{'error'}=1;
      #my $error=$response->message;
      $desc->{'rcstr'}="[ERROR: $error]";
      push @R, "$t:U ".$desc->{'rcstr'};
	}

   return \@R;
}


#-----------------------------------------------------------------------------------
# disp_icmp
# Parametros: \%H -> $H{host_ip}
#-----------------------------------------------------------------------------------
sub disp_icmp  {
my $desc=shift;

	mon_icmp($desc);

}

#-----------------------------------------------------------------------------------
# mon_ip_icmp2
# Parametros: \%H -> $H{host_ip}
#-----------------------------------------------------------------------------------
sub mon_ip_icmp2   {
my $desc=shift;

	mon_icmp($desc);
}


#-----------------------------------------------------------------------------------
# mon_ip_icmp3
# Parametros: \%H -> $H{host_ip}
#-----------------------------------------------------------------------------------
sub mon_ip_icmp3   {
my $desc=shift;

   mon_icmp($desc);
}


#-----------------------------------------------------------------------------------
# mon_icmp
# Parametros: \%H -> $H{host_ip}
#-----------------------------------------------------------------------------------
sub mon_icmp  {
my $desc=shift;

my $error;
my @dur=();
my @R=();
my $latency;
my $TIMEOUT=1.5;
my $bytes=64;
my $N=3;
my $N_min_ok=2;
my $N_nok=2;

my $t=time;
my $rcstr='[UNK]';

   my $host=$desc->{host_ip};

   $desc->{'elapsed'} = 'U';

	if (exists $desc->{'timeout'}) { $TIMEOUT=$desc->{'timeout'}; }

   my $p = Net::Ping->new("icmp",$TIMEOUT,$bytes);
	#$p->{bytes} = '64';
   #$p->{port_num} = '23';
   $p->hires(1);
   my $c=0;
   my $cnok=0;
   for (1..$N) {
      my ($rc, $duration, $ip) = $p->ping($host, $TIMEOUT);
      if ($rc) { push @dur,$duration; $c+=1;}
		else { $cnok+=1; }
		if ($cnok >= $N_nok) { last; }
   }
   $p->close();
   undef $p;

   if ($c >= $N_min_ok) {
      foreach (@dur) { $latency += $_; }
      $latency /= $c;
      #push @R,$latency;
      $rcstr="[OK]";

   	my $latency3 = sprintf("%.6f", $latency);
      if ($latency3==0) {
         $latency3='U';
         $rcstr="[ERROR Timeout en ICMP PING*]";
      }
		$desc->{'elapsed'} = $latency3;
	   push @R, "$t:$latency3 $rcstr";
   }
   else { 
		#push @R, 0; 
      $rcstr="[ERROR Timeout en ICMP PING]";
		$desc->{'elapsed'} = 'U';
   	push @R, "$t:U $rcstr";
	}

   return \@R;

}


#-----------------------------------------------------------------------------------
# mon_icmp
# Parametros: \%H -> $H{host_ip}
#-----------------------------------------------------------------------------------
#sub mon_icmp_new  {
#my $desc=shift;
#
#my $TIMEOUT=2;
#my $t=time;
#my $rcstr='[UNK]';
#my @R=();
#
#   my $host=$desc->{host_ip};
#   my $oping = Net::Oping->new ();
#   $oping->timeout($TIMEOUT);
#   $oping->host_add($host);
#
#   my $ret=$oping->ping();
#   foreach my $k (keys %$ret) {
#      my $RR=$ret->{$k};
#      if (! defined $RR) {
#         my $rcstr="[ERROR Timeout en ICMP PING]";
#         push @R, "$t:U $rcstr";
#      }
#      else {
#         my $rcstr="[OK]";
#         $RR /= 1000;
#         push @R, "$t:$RR $rcstr";
#      }
#   }
#   return \@R;
#}

#-----------------------------------------------------------------------------------
# mon_icmp_system
# Utiliza el comando /bin/ping del SO
# Parametros: \%H -> $H{host_ip}
#-----------------------------------------------------------------------------------
sub mon_icmp_system  {
my $desc=shift;

my $N=5;
my $CMD="/usr/bin/sudo /bin/ping -c $N -s 64 -W 1 -q ";
my @R=();
my $t=time;
my $rcstr='UNK';
my $rc='U';

   my $host=$desc->{host_ip};

	my @o=`$CMD $host 2>&1`;

	foreach my $l (@o) {

		chomp $l;
		if ($l =~ /$N packets transmitted/) {
			if ($l =~ /$N received/) { $rcstr='OK: '.$l;  }
			else { $rcstr= 'ERROR: '.$l;  }
		}
		#elsif ($l =~ /rtt min\/avg\/max\/mdev = ([\d+|\.+]+)\/([\d+|\.+]+)\/([\d+|\.+]+)\/([\d+|\.+]+)/) { $rc = $2; }

      elsif ($l =~ /rtt min\/avg\/max\/mdev = ([\d+|\.+]+)\/([\d+|\.+]+)\/([\d+|\.+]+)\/([\d+|\.+]+)\s*(\w*)/) {
			my $div=1;
         if ($5 eq 'ms') { $div=1000; }
         elsif ($5 eq 'us') { $div=1000000; }
         $rc = $2/$div;
      }
	}

	push @R, "$t:$rc [$rcstr]";


# 2 packets transmitted, 2 received, 0% packet loss, time 1001ms
# rtt min/avg/max/mdev = 0.062/0.314/0.567/0.253 ms, pipe 2
# =====>
# 1145663357:0.053 [OK: 2 packets transmitted, 2 received, 0% packet loss, time 1000ms]
   return \@R;

}



#-----------------------------------------------------------------------------------
# mon_pop3
# Parametros: \%H -> $H{host_ip}, $H{port}, $H{user}, $H{pwd}
#-----------------------------------------------------------------------------------
sub mon_pop3 {
my $desc=shift;

my @R=();
my $TIMEOUT=5;
my $t=time;
my $t0 = [gettimeofday];
my $rcstr='[UNK]';
my $elapsed=0;
my $msg='';

   my $ip=$desc->{host_ip};
   my $port=$desc->{port} || '110';
   my $user=$desc->{user};
   my $pwd=$desc->{pwd};

   $desc->{'nmsgs'} = 'U';
   $desc->{'elapsed'} = 'U';


	#my $pop = Net::POP3->new($ip, Timeout => $TIMEOUT, Port=>$port);
	my $pop = Mail::POP3Client->new(HOST => $ip, PORT => $port, USESSL =>1);

	if (!defined $pop) {	
		$rcstr='[ERROR:En conexion POP3]';
		$msg="$t:U $rcstr";
	}
		
	else {
		#my $r=$pop->login($user,$pwd);

	   $pop->User($user);
   	$pop->Pass($pwd);
   	my $r = $pop->Connect();
   	if (! $r) {
      	my $msg1=$pop->Message;
         my $error='Fallo en login';
         $rcstr="[ERROR: $error ($msg1)]";
         $msg="$t:U $rcstr";


   	}
		else {
			$desc->{'nmsgs'}=$pop->Count();

         $rcstr="[OK]";
         $elapsed = tv_interval ( $t0, [gettimeofday]);
         my $elapsed3 = sprintf("%.6f", $elapsed);
         $desc->{'elapsed'}=$elapsed3;
         $msg="$t:$elapsed3 $rcstr";
		}


#   	if (defined $r) {
#
#      	my $m=$pop->message();
#			chomp $m;
#      	$rcstr="[OK: $m]";
#      	$elapsed = tv_interval ( $t0, [gettimeofday]);
#      	my $elapsed3 = sprintf("%.6f", $elapsed);
#			$desc->{'elapsed'}=$elapsed3;
#      	$msg="$t:$elapsed3 $rcstr";
#   	}
#   	else {
#      	#my $error=$pop->message();
#			#chomp $error;
#			my $error='Fallo en login';
#      	$rcstr="[ERROR: $error]";
#      	$msg="$t:U $rcstr";
#   	}
		#$pop->quit();

		$pop->Close();
	}

	undef $pop;
	push @R, $msg;
	return \@R;

}


#-----------------------------------------------------------------------------------
# mon_smtp
# Parametros: \%H -> $H{host_ip}, $H{port}
#-----------------------------------------------------------------------------------
sub mon_smtp {
my $desc=shift;
my $TIMEOUT=3;
my @R=();

my $t=time;
my $t0 = [gettimeofday];
my $rcstr='[UNK]';
my $elapsed=0;

   my $port=$desc->{port_smtp} || '25';
   my $ip=$desc->{host_ip};

	my $smtp = Net::SMTP->new($ip, Timeout=>$TIMEOUT);

   if (defined $smtp) {

		my $banner=$smtp->banner();
		chomp $banner;
      $rcstr="[OK: $banner]";
      $elapsed = tv_interval ( $t0, [gettimeofday]);
      my $elapsed3 = sprintf("%.6f", $elapsed);
	   push @R, "$t:$elapsed3 $rcstr";

		$desc->{'elapsed'} = $elapsed3;
		$desc->{'rc'} = $smtp->code();

   	$smtp->quit();
		undef $smtp;

   }
   else {
      $rcstr="[ERROR en HELO SMTP]";
      push @R, "$t:U $rcstr";
      $desc->{'elapsed'} = 'U';
      $desc->{'rc'} = 'U';

   }

   return \@R;

}

#-----------------------------------------------------------------------------------
# mon_imap
# Parametros: \%H -> $H{host_ip}, $H{port}, $H{user}, $H{pwd}
#-----------------------------------------------------------------------------------
sub mon_imap {
my $desc=shift;

my @R=();
my $msg='';
my $TIMEOUT=3;
my $t=time;
my $t0 = [gettimeofday];
my $rcstr='[UNK]';
my $elapsed=0;

   my $ip=$desc->{host_ip};
   my $port=$desc->{port} || '143';
   my $user=$desc->{user};
   my $pwd=$desc->{pwd};

   $desc->{'mailboxes'} = 'U';
   $desc->{'nmsgs'} = 'U';
   $desc->{'nmsgs_all'} = 'U';
	$desc->{'elapsed'} = 'U';

   my $imap = new Net::IMAP::Simple($ip, Timeout => $TIMEOUT, ResvPort=>$port, use_ssl=>1);

   if (!defined $imap) { 
   	$rcstr='[ERROR:En conexion IMAP]';
   	$msg="$t:U $rcstr";
   }

   else {
      my $r=$imap->login($user,$pwd);

      if (defined $r) {

         $rcstr='[OK]';
         $elapsed = tv_interval ( $t0, [gettimeofday]);
   		my $elapsed3 = sprintf("%.6f", $elapsed);
			$desc->{'elapsed'}=$elapsed3;
   		$msg="$t:$elapsed3 $rcstr";

			my @boxes = $imap->mailboxes;
			$desc->{'mailboxes'} = scalar @boxes;
			$desc->{'nmsgs'}=$imap->select('INBOX');
			$desc->{'nmsgs_all'}=0;
			foreach my $m (@boxes) {
				my $n=$imap->select($m);
				if (defined $n) {
					$desc->{'nmsgs_all'}+=$n;
				}
			}
      }
      else {
         #my $error=$imap->message();
         #chomp $error;
			my $error="Fallo en login ($user/$pwd -> $ip:$port)";
         $rcstr="[ERROR: $error]";
         $msg="$t:U $rcstr";
      }
      $imap->quit();
		undef $imap;
   }

	push @R, $msg;
   return \@R;

}

#-----------------------------------------------------------------------------------
# mon_dns
# Parametros: \%H -> $H{host_ip}, $H{name}
#-----------------------------------------------------------------------------------
#NOERROR (RCODE:0) : DNS Query completed successfully
#FORMERR (RCODE:1) : DNS Query Format Error
#SERVFAIL (RCODE:2) : Server failed to complete the DNS request
#NXDOMAIN (RCODE:3) : Domain name does not exist
#NOTIMP (RCODE:4) : Function not implemented
#REFUSED (RCODE:5) : The server refused to answer for the query
#YXDOMAIN (RCODE:6) : Name that should not exist, does exist
#XRRSET (RCODE:7) : RRset that should not exist, does exist
#NOTAUTH (RCODE:9) : Server not authoritative for the zone
#NOTZONE (RCODE:10) : Name not in zone

sub mon_dns {
my $desc=shift;
my $TIMEOUT=3;
my @R=();

my $t=time;
my $t0 = [gettimeofday];
my $rcstr='[UNK]';
my $elapsed=0;
my $debug=0;
my $res;

   my $name=$desc->{rr} || 'http://www.google.com';
   if ($desc->{debug}) {$debug=1; }

   $desc->{'elapsed'}='U';
   $desc->{'ttl'}='U';
	$desc->{'rcdata'}='';

   if ($desc->{host_ip}) {
      my $nameserver=$desc->{host_ip};
      $res = Net::DNS::Resolver->new( nameservers => [ $nameserver ], debug=>$debug);
   }
   else { $res   = Net::DNS::Resolver->new(); }

   $res->tcp_timeout($TIMEOUT);
   $res->udp_timeout($TIMEOUT);

	my $packet = $res->search($name);

   if (! defined $packet) {
      #En este caso si que no tenemos respuesta
      my $error=$res->errorstring;
      $rcstr="[ERROR: $error]";
      push @R, "$t:U $rcstr";
		$desc->{'rcdata'}=$name.' ('.$res->errorstring.')';
   }

   else {
      my $answer_section=0;
      foreach my $rr ($packet->answer) {
         next unless $rr->type eq "A";
         $answer_section=1;
         my $name_ip=$rr->address;
		  	$rcstr="[OK: $name->$name_ip]";
			$desc->{'rcdata'}="$name->$name_ip (".$res->errorstring.')';
         $elapsed = tv_interval ( $t0, [gettimeofday]);
         my $elapsed3 = sprintf("%.6f", $elapsed);
			$desc->{'elapsed'}=$elapsed3;
			$desc->{'ttl'}=$rr->ttl;
         push @R, "$t:$elapsed3 $rcstr";
      }
      if (! $answer_section) {
         foreach my $a ($packet->authority) {
            my $name=$a->string;
            $rcstr="[OK: AUTH=> $name]";
            $elapsed = tv_interval ( $t0, [gettimeofday]);
            my $elapsed3 = sprintf("%.6f", $elapsed);
				$desc->{'rcdata'}=$name;
				$desc->{'elapsed'}=$elapsed3;
				$desc->{'ttl'}=$a->ttl;;
            push @R, "$t:$elapsed3 $rcstr";

				$desc->{'rcdata'}.=' ('.$res->errorstring.')';

				last;
         }
      }
   }

   undef $res;
   return \@R;
}

#-----------------------------------------------------------------------------------
# mon_tcp
# Parametros: \%H -> $H{host_ip}, $H{port}
#-----------------------------------------------------------------------------------
sub mon_tcp {
my ($desc,$b)=@_;

my @R=();
my $TIMEOUT=3;
my $t=time;
my $t0 = [gettimeofday];
my $rcstr='[UNK]';
my $elapsed=0;

   my $port=$desc->{port};
   my $ip=$desc->{host_ip};

	# 'untaint'
	$ip=~/(\S+)/;
	my $socket = IO::Socket::INET->new(PeerAddr=>$1, PeerPort=>$port, Timeout=>$TIMEOUT);

   if (defined $socket) {

		if ((defined $b) && ($b)) {

			$SIG{ALRM} = sub { die "timeout" };

			eval {
		    	alarm($TIMEOUT);

	      	my $banner=<$socket>;
   	   	chomp $banner;
      		$rcstr="[OK: $banner]";
			
    			alarm(0);
			};

			if ($@) { $rcstr="[ERROR: Timeout]"; }

		}
		else { $rcstr="[OK]"; }

		if ($@) { 
			$rcstr="[ERROR: El equipo no presenta banner]"; 
		}
		
      $elapsed = tv_interval ( $t0, [gettimeofday]);
  	   my $elapsed3 = sprintf("%.6f", $elapsed);
		$desc->{'elapsed'}=$elapsed3;
  		push @R, "$t:$elapsed3 $rcstr";
      $socket->close();
		undef $socket;
   }
   else {
		my $error=$@;
		if ($error =~ /Connection refused/) { $error="Conexion TCP rechazada con $ip:$port"; }

      $rcstr="[ERROR: $error]";
      push @R, "$t:U $rcstr";
   }

   return \@R;

}

#-----------------------------------------------------------------------------------
# mon_smb
# Monitoriza un fichero a traves de un disco de RED SMB/CIFS
# Parametros: \%H -> $H{host_ip}, $H{share}, $H{pwd}, $H{user}, $H{f}
# OJO!!! el parametro fichero no se puede llamar file porque entra en conflicto
# con el parametro file que especifica el fichero rrd Por eso se llama f !!!
#---------------------------------------------------------------------------:x--------
#[root@fc3-devel ~]# /usr/bin/smbclient //PCS23141/DATA "" -c "ls rrd.xls"
#Domain=[PCS23141] OS=[Windows 5.1] Server=[Windows 2000 LAN Manager]
#  rrd.xls                             A    21504  Fri May 16 09:07:33 2003
#
#                38161 blocks of size 1048576. 6370 blocks available
#
#  NT_STATUS_NO_SUCH_FILE => Existe el share pero no el fichero
#  NT_STATUS_BAD_NETWORK_NAME => No existe el share
#  Error connecting to ....   => No hay conexion con el host
# 
#	/usr/bin/smbclient //10.200.102.47/cnm cnm123 -I 10.200.102.47 -U cnm "" -c "ls data.tar.gz"
#-----------------------------------------------------------------------------------
sub mon_smb {
my $desc=shift;

my $SMB_CMD='/usr/bin/smbclient';
my $SMB_ARGS=' __SHARE__ __PWD__ -I __IP__ -U __USER__ "" -c "ls __FILE__" ';
my $TIMEOUT=3;

my @R=();
my $msg='';
my $t=time;
my $t0 = [gettimeofday];
my $rcstr='[UNK]';
my $elapsed=0;
my $basename = '';

   my $share=$desc->{share};  # //PCS23141/DATA
   my $pwd=$desc->{pwd} || 'nopwd';
   my $ip=$desc->{host_ip};
   my $f=$desc->{f};
   my $user=$desc->{user} || 'nouser';		# domain/user

   if (! -e $SMB_CMD) {
      $rcstr='[ERROR:No se encuentra el comando]';
      $msg="$t:U $rcstr";
   }
	elsif ( ($f eq '') || ($share eq '') || ($user eq '') || ($ip eq '') ) {
		$rcstr='[ERROR: En definicion de metrica]';
      $msg="$t:U $rcstr";
	}
   else {

		use File::Basename;

      $SIG{ALRM} = sub { die "timeout en mon_smb (share=$share ip=$ip f=$f user=$user) ($!)" };

		my @r=();
      eval {
         alarm($TIMEOUT);

			$basename = basename($f);
	      my $cmd=$SMB_CMD.$SMB_ARGS;
			# FML. Un tema a considerar seria el usar el nombre netbios en la ruta del share.
			# Eso significa o que el usuario lo ponga en la ruta o hacer resolucion de nombres wins.
			my $share_full='//'.$ip.'/'.$share;
   	   $cmd=~s/__SHARE__/$share_full/;
      	$cmd=~s/__PWD__/$pwd/;
	      $cmd=~s/__IP__/$ip/;
   	   $cmd=~s/__USER__/$user/;
      	$cmd=~s/__FILE__/$f/;

#print "CMD=$cmd\n";
$desc->{'debug_data'}=$cmd;

			@r=`$cmd 2>&1`;

$desc->{'debug_data'} .= @r;

         alarm(0);
      };

      if ($@) { $rcstr="[ERROR: Timeout]"; }

		my $size='U';
		foreach my $l (@r) {
			#rrd.xls                             A    21504  Fri May 16 09:07:33 2003
			chomp $l;
#print "**LINEA=$l\n";

         if ($l =~ /NT_STATUS_NO_SUCH_FILE/) { $rcstr="[ERROR:No se encuentra elfichero $f]"; last; }
         if ($l =~ /NT_STATUS_BAD_NETWORK_NAME/) { $rcstr="[ERROR:No se accede a $share IP=$ip]"; last; }
         if ($l =~ /Error connecting to/) { $rcstr="[ERROR:No hay conectividad con $ip]"; last; }

#  db.gz                                   105031  Sat Apr  1 09:01:47 
#  xagent.exe                          A  3739715  Tue Mar  7 08:28:44
			if ($l =~ /$basename\s+.*?(\d+)\s+\w+\s+\w+\s+\d+\s+\d+\:.*/i) { 
				$size=$1; 
#print "    ***S=$size\n";
				$rcstr='[OK]';
				last; 
			}
		}

      $elapsed = tv_interval ( $t0, [gettimeofday]);
      my $elapsed3 = sprintf("%.6f", $elapsed);
		$desc->{'elapsed'}=$elapsed3;
      $msg="$t:$size $rcstr";
   }

   push @R, $msg;
   return \@R;
}

#-----------------------------------------------------------------------------------
# mon_ssh
# Parametros: \%H -> $H{host_ip}, $H{port}
#-----------------------------------------------------------------------------------
sub mon_ssh {
my $desc=shift;

	if ($desc->{port}) {$desc->{port}=$desc->{port};}
	else {$desc->{port}='22';}

	my $r=mon_tcp($desc,1);

	if ($r->[0] !~ /ssh/i) { $r->[0] =~ s/OK/ERROR/g; }
	return $r;
	
}



#-----------------------------------------------------------------------------------
# mon_ntp
# Parametros: \%H -> $H{host_ip}, $H{port}
#-----------------------------------------------------------------------------------
sub mon_ntp {
my $desc=shift;

my $NTP_CMD='/usr/sbin/ntpdate';
my $NTP_ARGS=' -t 0.6 -q __IP__';
my $TIMEOUT=3;

my @R=();
my $msg='';
my $t=time;
my $t0 = [gettimeofday];
my $rcstr='[UNK]';
my $elapsed=0;

   my $ip=$desc->{host_ip};
   if (! -e $NTP_CMD) {
      $rcstr='[ERROR:No se encuentra el comando]';
      $msg="$t:U $rcstr";
   }

   else {

      $SIG{ALRM} = sub { die "timeout" };

      my @r=();
      my $cmd=$NTP_CMD.$NTP_ARGS;

      eval {
         alarm($TIMEOUT);
         $cmd=~s/__IP__/$ip/;

$desc->{'debug_data'}=$cmd;

         @r=`$cmd 2>&1`;

$desc->{'debug_data'} .= @r;

         alarm(0);
      };

      if ($@) { $rcstr="[ERROR: Timeout ($cmd)]"; }

      foreach my $l (@r) {
         #rrd.xls                             A    21504  Fri May 16 09:07:33 2003
         chomp $l;
#print "**LINEA=$l\n";
 
 # OK:
 # 9 Feb 00:33:47 ntpdate[29488]: adjust time server 172.32.100.40 offset -0.307928 sec
 # ERROR:
 # 9 Feb 00:33:11 ntpdate[29479]: no server suitable for synchronization found
 # 9 Feb 00:37:44 ntpdate[29608]: can't find host ppp
 # 9 Feb 00:37:44 ntpdate[29608]: no servers can be used, exiting
 #

         if ($l =~ /no server suitable for synchronization found/) { $rcstr="[ERROR: No es servidor NTP]"; last; }
         if ($l =~ /no servers can be used/) { $rcstr="[ERROR: No es servidor NTP]"; last; }
         if ($l =~ /can't find host/) { $rcstr="[ERROR: No es servidor NTP. Revisar nombre !!]"; last; }

         if ( ($l =~ /adjust time server/) || ($l =~ /step time server/) ) {
            $rcstr='[OK]';
            last;
         }
      }

      $elapsed = tv_interval ( $t0, [gettimeofday]);
      my $elapsed3 = sprintf("%.6f", $elapsed);
		$desc->{'elapsed'}=$elapsed3;
      $msg="$t:$elapsed3 $rcstr";
   }

   push @R, $msg;
   return \@R;
}


#-----------------------------------------------------------------------------------
# mon_ntp_old
# Parametros: \%H -> $H{host_ip}, $H{port}
#-----------------------------------------------------------------------------------
#sub mon_ntp_old {
#my $desc=shift;
#
#my @R=();
#my $TIMEOUT=3;
#my $t=time;
#my $t0 = [gettimeofday];
#my $rcstr='[UNK]';
#my $elapsed=0;
#my $MAXLEN=1024;			# check our buffers
#
#   my $port=$desc->{port} || 123;
#   my $ip=$desc->{host_ip};
#
#	#we use the system call to open a UDP socket
#	my $rv=socket(SOCKET, PF_INET, SOCK_DGRAM, getprotobyname("udp"));
#	if (! $rv) {
#		$rcstr="[ERROR: $!]";
#		push @R, "$t:U $rcstr";
#		return \@R;
#	}
#
#	#convert hostname to ipaddress if needed
#	my $ipaddr   = inet_aton($ip);
#	my $portaddr = sockaddr_in($port, $ipaddr);
#
#	# build a message.  Our message is all zeros except for a one in the protocol version field
#	# $msg in binary is 00 001 000 00000000 ....  or in C msg[]={010,0,0,0,0,0,0,0,0,...}
#	#it should be a total of 48 bytes long
#	my $MSG="\010"."\0"x47;
#	if (send(SOCKET, $MSG, 0, $portaddr) != length($MSG)) {
#		$rcstr="[ERROR: $!]";
#      push @R, "$t:U $rcstr";
#		return \@R;
#	}
#
#   $SIG{ALRM} = sub { die "timeout" };
#	eval {
#   	alarm($TIMEOUT);
#		$rv=recv(SOCKET, $MSG, $MAXLEN, 0);
#      alarm(0);
#   };
#   if ($@) {
#		chomp $@;
#		if ($@ =~ /timeout/) { $rcstr="[ERROR: Timeout T=$TIMEOUT segs]"; }
#      else { $rcstr="[ERROR: $@]"; }
#      push @R, "$t:U $rcstr";
#      return \@R;
#   }
#
#	#$rv=recv(SOCKET, $MSG, $MAXLEN, 0);
#   #if (! $rv) {
#   #   $rcstr="[ERROR: $!]";
#   #   push @R, "$t:U $rcstr";
#   #   return \@R;
#   #}
#
#	#We get 12 long words back in Network order
#	my @l=unpack("N12",$MSG);
#
#	#The high word of transmit time is the 10th word we get back
#	#tmit is the time in seconds not accounting for network delays which should be
#	#way less than a second if this is a local NTP server
#	my $tmit=$l[10];	# get transmit time
#
#	#convert time to unix standard time
#	#NTP is number of seconds since 0000 UT on 1 January 1900
#	#unix time is seconds since 0000 UT on 1 January 1970
#	#There has been a trend to add a 2 leap seconds every 3 years.  Leap
#	#seconds are only an issue the last second of the month in June and
#	#December if you don't try to set the clock then it can be ignored but
#	#this is importaint to people who coordinate times with GPS clock
#	#sources.
#	$tmit-= 2208988800;	
#
#	$rcstr = scalar localtime ($tmit);
#
#   $elapsed = tv_interval ( $t0, [gettimeofday]);
#   my $elapsed3 = sprintf("%.6f", $elapsed);
#   push @R, "$t:$elapsed3 [OK: $rcstr]";
#	
#	return \@R;
#
#}


#-----------------------------------------------------------------------------------
# mon_snmp
# Parametros: \%H -> $H{host_ip}, $H{community}, $H{version}
#-----------------------------------------------------------------------------------
sub mon_snmp {
my ($desc,$b)=@_;
 
my @R=();
my $TIMEOUT=3;
my $t=time;
my $rcstr='[UNK]';
my $elapsed=0;
 
   use Crawler::SNMP;
   #my $SNMP=Crawler::SNMP->new( name=>"mon_snmp", store_path=>$STORE_PATH, lapse=>300,
   #                             cfg=>$rcfgbase, range=>0, log_level=>$log_level, mode_flag=>{rrd=>0, alert=>0} );
   my $SNMP=Crawler::SNMP->new( name=>"mon_snmp", lapse=>300, range=>0, log_level=>'info', mode_flag=>{rrd=>0, alert=>0} );
   my $t0 = [gettimeofday];
   my $ip=$desc->{host_ip};
   my $community=$desc->{community};
   my $version=$desc->{version};
   my $n=$SNMP->snmp_get_name($ip,$community,$version);
   if (defined $n) { $rcstr="[OK: sysname=$n]"; }
   else { $rcstr="[ERROR: El equipo no responde a sysname]"; }
 
   $elapsed = tv_interval ( $t0, [gettimeofday]);
   my $elapsed3 = sprintf("%.6f", $elapsed);
	$desc->{'elapsed'}=$elapsed3;
   push @R, "$t:$elapsed3 $rcstr";
 
   return \@R;
}



#-----------------------------------------------------------------------------------
# mon_ldap
# Parametros: \%H -> $H{host_ip}, $H{port}
#-----------------------------------------------------------------------------------
sub mon_ldap {
my ($desc)=@_;

my @R=();
my $TIMEOUT=3;
my $t=time;
my $t0 = [gettimeofday];
my $rcstr='[UNK]';
my $elapsed=0;
my $msg='';

   my $port=$desc->{port};		#3268
   my $ip=$desc->{host_ip};

   my $base_dn=$desc->{base_dn};
   my $filter=$desc->{filter} || 'sAMAccountName=*';
   my $user=$desc->{user} || '';
   my $pwd=$desc->{pwd} || 'nopwd';
   my $version=$desc->{version} || 3;


   use Crawler;
   my $LOG=Crawler->new( log_level=>'debug' );
	$LOG->log('debug',"mon_ldap:: base_dn=$base_dn   filter=$filter    user=$user    pwd=$pwd   version=$version    (ip=$ip port=$port)");


#print "($ip, port=> $port, timeout=>$TIMEOUT  )\n";

	my $ldap = Net::LDAP->new ($ip, port=> $port, timeout=>$TIMEOUT  );
  	if (!defined $ldap) {
	   $rcstr='[ERROR:En conexion LDAP]';
     	$msg="$t:U $rcstr";
   	push @R, $msg;
   	return \@R;
   }

#print "($user, password=>$pwd, version => $version )\n";

	my $mesg = $ldap->bind ($user, password=>$pwd, version => $version );
   if (!defined $ldap) {
      $rcstr='[ERROR:En conexion BIND LDAP]';
      $msg="$t:U $rcstr";
      push @R, $msg;
      return \@R;
   }

#print "DEBUG: base   => $base_dn,  filter => $filter\n";

	my $result = $ldap->search( base   => $base_dn,  filter => $filter );

	my $err=$result->code();
	my $errstr=$result->error_name();
	my $cnt = $result->count();

	if ($err==0) {
			
     	$elapsed = tv_interval ( $t0, [gettimeofday]);
      my $elapsed3 = sprintf("%.6f", $elapsed);
		$desc->{'elapsed'}=$elapsed3;
		$rcstr='[OK]';
      $msg="$t:$elapsed3 $rcstr";
	}
	else {
     	$rcstr="[ERROR:En search LDAP($err) ($errstr)]";
      $msg="$t:U $rcstr";
	}

   push @R, $msg;
   return \@R;

}




#-----------------------------------------------------------------------------------
# mon_ldap_attr
# Parametros: \%H -> $H{host_ip}, $H{port}
#-----------------------------------------------------------------------------------
sub mon_ldap_attr {
my ($desc)=@_;

my @R=();
my $TIMEOUT=3;
my $t=time;
my $t0 = [gettimeofday];
my $rcstr='[UNK]';
my $elapsed=0;
my $msg='';

   my $port=$desc->{port};    #3268
   my $ip=$desc->{host_ip};

   my $base_dn=$desc->{base_dn};
   my $filter=$desc->{filter} || 'sAMAccountName=*';
   my $user=$desc->{user} || '';
   my $pwd=$desc->{pwd} || 'nopwd';
   my $version=$desc->{version} || 3;

   my $check_attr=$desc->{attr};
   my $check_value=$desc->{check_value};

   use Crawler;
   my $LOG=Crawler->new( log_level=>'debug' );
   $LOG->log('debug',"mon_ldap_attr:: base_dn=$base_dn   filter=$filter    user=$user    pwd=$pwd   version=$version    (ip=$ip port=$port)");


#print "($ip, port=> $port, timeout=>$TIMEOUT  )\n";

   my $ldap = Net::LDAP->new ($ip, port=> $port, timeout=>$TIMEOUT  );
   if (!defined $ldap) {
      $rcstr='[ERROR:En conexion LDAP]';
      $msg="$t:U $rcstr";
      push @R, $msg;
      return \@R;
   }

#print "($user, password=>$pwd, version => $version )\n";

   my $mesg = $ldap->bind ($user, password=>$pwd, version => $version );
   if (!defined $ldap) {
      $rcstr='[ERROR:En conexion BIND LDAP]';
      $msg="$t:U $rcstr";
      push @R, $msg;
      return \@R;
   }

#print "DEBUG: base   => $base_dn,  filter => $filter\n";

   my $result = $ldap->search( base   => $base_dn,  filter => $filter );

   my $err=$result->code();
   my $errstr=$result->error_name();
   my $cnt = $result->count();

	if ($err) {
	   $rcstr="[ERROR:En search LDAP($err) ($errstr)]";
		$msg="$t:U $rcstr";
	}

	else {
		my $ok=0;
		my $exists=0;
  		my @entries = $result->entries;
  		foreach my $entr ( @entries ) {
   		#print "DN: ", $entr->dn, "\n";
	     	foreach my $attr ( sort $entr->attributes ) {
   	   	# skip binary we can't handle
      	   next if ( $attr =~ /;binary$/ );
				if ($attr eq $check_attr) {
					$exists=1;
					my $val=$entr->get_value($attr);
					if ($check_value eq  $val) { $ok=1; }
				}
        		#print "  $attr : ", $entr->get_value ( $attr ) ,"\n";
     		}
  		}
		if (!$exists) {
      	$rcstr="[ERROR:No existe atributo $check_attr]";
		   $msg="$t:U $rcstr";
		}
		else {
			$rcstr='[OK]';
		   $msg="$t:$ok $rcstr";
		}
	}

   push @R, $msg;
   return \@R;

}




#-----------------------------------------------------------------------------------
# mon_ldap_val
# Parametros: \%H -> $H{host_ip}, $H{port}
#-----------------------------------------------------------------------------------
sub mon_ldap_val {
my ($desc)=@_;

my @R=();
my $TIMEOUT=3;
my $t=time;
my $t0 = [gettimeofday];
my $rcstr='[UNK]';
my $elapsed=0;
my $msg='';

   my $port=$desc->{port};    #3268
   my $ip=$desc->{host_ip};

   my $base_dn=$desc->{base_dn};
   my $filter=$desc->{filter} || 'sAMAccountName=*';
   my $user=$desc->{user} || '';
   my $pwd=$desc->{pwd} || 'nopwd';
   my $version=$desc->{version} || 3;

   my $check_attr=$desc->{attr};

   use Crawler;
   my $LOG=Crawler->new( log_level=>'debug' );
   $LOG->log('debug',"mon_ldap_val:: base_dn=$base_dn   filter=$filter    user=$user    pwd=$pwd   version=$version    (ip=$ip port=$port)");


#print "($ip, port=> $port, timeout=>$TIMEOUT  )\n";

   my $ldap = Net::LDAP->new ($ip, port=> $port, timeout=>$TIMEOUT  );
   if (!defined $ldap) {
      $rcstr='[ERROR:En conexion LDAP]';
      $msg="$t:U $rcstr";
      push @R, $msg;
      return \@R;
   }

#print "($user, password=>$pwd, version => $version )\n";

   my $mesg = $ldap->bind ($user, password=>$pwd, version => $version );
   if (!defined $ldap) {
      $rcstr='[ERROR:En conexion BIND LDAP]';
      $msg="$t:U $rcstr";
      push @R, $msg;
      return \@R;
   }

#print "DEBUG: base   => $base_dn,  filter => $filter\n";

   my $result = $ldap->search( base   => $base_dn,  filter => $filter );

   my $err=$result->code();
   my $errstr=$result->error_name();
   my $cnt = $result->count();
	my $attr;

   if ($err) {
      $rcstr="[ERROR:En search LDAP($err) ($errstr)]";
      $msg="$t:U $rcstr";
   }

   else {
      my $value='U';
      my $exists=0;
      my @entries = $result->entries;
      foreach my $entr ( @entries ) {
         #print "DN: ", $entr->dn, "\n";
         foreach $attr ( sort $entr->attributes ) {
            # skip binary we can't handle
            next if ( $attr =~ /;binary$/ );
            if ($attr eq $check_attr) {
               $exists=1;
               $value=$entr->get_value($attr);
					last;
            }
            #print "  $attr : ", $entr->get_value ( $attr ) ,"\n";
         }
      }
      if (!$exists) {
         $rcstr="[ERROR:No existe atributo $check_attr]";
         $msg="$t:U $rcstr";
      }
		elsif ($value !~ /\d+/ ) {
         $rcstr="[ERROR:EL atributo $attr no es numerico (val=$value)$check_attr]";
         $msg="$t:U $rcstr";
      }
      else {
         $rcstr='[OK]';
         $msg="$t:$value $rcstr";
      }
   }

   push @R, $msg;
   return \@R;

}








1;
__END__
