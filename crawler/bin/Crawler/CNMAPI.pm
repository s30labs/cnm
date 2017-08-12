#----------------------------------------------------------------------------
use Crawler;
package Crawler::CNMAPI;
@ISA=qw(Crawler);
$VERSION='1.00';
#----------------------------------------------------------------------------
use strict;
use JSON;
#use LWP::Curl;
use Data::Dumper;
use Encode;
use LWP::UserAgent;
use ONMConfig;
#use MIME::Base64;
#use JSON::XS;

#----------------------------------------------------------------------------

$Crawler::CNMAPI::APIVERSION = '1.0';
#----------------------------------------------------------------------------

my $FILE_CONF='/cfg/onm.conf';
#----------------------------------------------------------------------------


#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::CNMAPI
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_timeout} = $arg{timeout} || 5;
   $self->{_host} = $arg{host} || 'localhost';
   $self->{_sid} = $arg{sid} || '';

	$self->{_cfg} = conf_base($FILE_CONF);

   return $self;
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
# host
#----------------------------------------------------------------------------
sub host {
my ($self,$host) = @_;
   if (defined $host) {
      $self->{_host}=$host;
   }
   else { return $self->{_host}; }
}

#----------------------------------------------------------------------------
# sid
#----------------------------------------------------------------------------
sub sid {
my ($self,$sid) = @_;
   if (defined $sid) {
      $self->{_sid}=$sid;
   }
   else { return $self->{_sid}; }
}


#----------------------------------------------------------------------------
# ws_get_token
#----------------------------------------------------------------------------
# Metodo para obtener un token valido para el API REST.
# curl -ki "https://10.2.254.222/onm/api/1.0/auth/token.json?u=admin&p=cnm123"
#----------------------------------------------------------------------------
sub ws_get_token  {
my ($self,$user,$pwd)=@_;

	my $rc = 0;
	$self->err_num($rc);
	$self->err_str('');

	my $sid='';
	my %params = ();
	
	if ((defined $user) && (defined $pwd)) {

      $params{'u'} = $user;
      $params{'p'} = $pwd;
	}
	else {
		my $store=$self->create_store();
		my $dbh=$store->open_db();
		$self->store($store);
		$self->dbh($dbh);

		my $c = $store->get_credential_info($dbh,{'type'=>'api'});

		if (ref($c) ne 'HASH') {
			$rc=1;
			$self->err_num($rc);
			$self->err_str('ERROR AL OBTENER TOKEN - SIN CREDENCIAL VALIDA');
			$self->log('warning',"ws_get_token:: **ERROR** SIN CREDENCIAL VALIDA");
			return $sid;
		}
	
		my @k = keys %$c;

		$params{'u'} = $c->{$k[0]}->{'user'};
		$params{'p'} = $c->{$k[0]}->{'pwd'};
	}

	my $results = $self->ws_get('auth','token.json',\%params);

	#{"status":0,"sessionid":"3ae54914ce28e263e89012f0dbd745f7"}
	if ($results->{'status'} == 0) { $sid=$results->{'sessionid'}; }
	else {
      $rc=2;
		$self->err_num($rc);
      $self->err_str('ERROR AL OBTENER TOKEN - SIN TOKEN');
		$self->log('warning',"ws_get_token:: **ERROR** AL OBTENER TOKEN");
	}

	$self->sid($sid);
   return $sid;

}


#----------------------------------------------------------------------------
# ws_get
#----------------------------------------------------------------------------
#
#  Metodo GET para el API REST.
#
#----------------------------------------------------------------------------
sub ws_get  {
my ($self,$class,$endpoint,$params)=@_;

   $self->err_num(0);
   $self->err_str('');

   my $timeout=$self->timeout();
	my $host=$self->host();
	my $url='https://'.$host.'/onm/api/'.$Crawler::CNMAPI::APIVERSION.'/'.$class;
	if ((defined $endpoint) && ($endpoint ne '')) {$url .= '/'.$endpoint; }
	my @extra=();
	foreach my $k (keys %$params) {
		push @extra, $k.'='.$params->{$k};
	}
	if (scalar (@extra)>0) { $url .= '?'.join('&',@extra); }

   $self->log('info',"ws_get:: url=$url");

	my ($err_num,$err_str,$results)=(0,'UNK',[]);
  	my ($referer,$content,$status,$rc,$rcstr)=(undef,'','200 OK',0,0);

	my $sid=$self->sid();

   eval {

	   my $ua = LWP::UserAgent->new(ssl_opts => { SSL_verify_mode => 0, verify_hostname => 0, SSL_version=>'TLSv1'});
   	$ua->default_header(Authorization => $sid);
   	my $response = $ua->get($url);

		if ( $response->is_success ) { $content = $response->content(); }
		else { 
			$err_num=1000;
			$err_str = $response->status_line;
			if ($err_str =~ /401 Authorization Required/) { $err_str .= " (sid=$sid)"; }
			$self->log('warning',"ws_get:: **ERROR** EN GET url=$url ($err_str)");
			$self->err_str("ERROR EN GET url=$url ($err_str)");
		}
   	$self->log('info',"ws_get:: res=$content");
   };
   if ($@) {
		$err_num=1001;
		$err_str=$@;
		$err_str=~s/\n/ \./g;
      $self->log('warning',"ws_get:: **ERROR** EN GET url=$url ($err_str)");
      $self->err_str("ERROR EN GET url=$url ($err_str)");
   }
	elsif ($err_num==0) {

		# Se decodifica $content
		eval {
	   	my $json=JSON->new();
   		$json->ascii(1);
			$results=$json->decode($content);
   	};
	   if ($@) {
   	   $err_num=1002;
      	$err_str=$@;
	      $err_str=~s/\n/ \./g;
   	   $self->log('warning',"ws_get:: **ERROR** EN DECODE DATA url=$url ($err_str) DATA=$content---");
   	   $self->err_str("ERROR EN DECODE DATA url=$url ($err_str) DATA=$content---");
   	}
	}

   $self->err_num($err_num);

	return $results;

}



#----------------------------------------------------------------------------
# ws_put
#----------------------------------------------------------------------------
#
#  Metodo PUT para el API REST.
#
#----------------------------------------------------------------------------
sub ws_put  {
my ($self,$class,$endpoint,$params)=@_;

   $self->err_num(0);
   $self->err_str('');

   my $timeout=$self->timeout();
   my $host=$self->host();
   my $url='https://'.$host.'/onm/api/'.$Crawler::CNMAPI::APIVERSION.'/'.$class;
   if ((defined $endpoint) && ($endpoint ne '')) {$url .= '/'.$endpoint; }
   my @extra=();
   foreach my $k (keys %$params) {
      push @extra, $k.'='.$params->{$k};
   }
   if (scalar (@extra)>0) { $url .= '?'.join('&',@extra); }

   $self->log('info',"ws_put:: url=$url");

   my ($err_num,$err_str,$results)=(0,'UNK',[]);
   my ($referer,$content,$status,$rc,$rcstr)=(undef,'','200 OK',0,0);

   my $sid=$self->sid();

   eval {

      #my $ua = LWP::UserAgent->new;
		my $ua = LWP::UserAgent->new(ssl_opts => { SSL_verify_mode => 0, verify_hostname => 0, SSL_version=>'TLSv1'});
      $ua->default_header(Authorization => $sid);
      my $response = $ua->put($url, {});

      if ( $response->is_success ) { $content = $response->content(); }

      $self->log('info',"ws_put:: res=$content");
   };
   if ($@) {
      $err_num=1000;
      $err_str=$@;
      $err_str=~s/\n/ \./g;
      $self->log('warning',"ws_put:: **ERROR** EN PUT url=$url ($err_str)");
		$self->err_str("ERROR EN PUT url=$url ($err_str)");
   }

   else {

      # Se decodifica $content
      eval {
         my $json=JSON->new();
         $json->ascii(1);
         $results=$json->decode($content);
      };
      if ($@) {
         $err_num=1001;
         $err_str=$@;
         $err_str=~s/\n/ \./g;
         $self->log('warning',"ws_put:: **ERROR** EN DECODE url=$url ($err_str)");
			$self->err_str("ERROR EN DECODE DATA url=$url ($err_str)");
      }
   }

   $self->err_num($err_num);

   return $results;

}



#----------------------------------------------------------------------------
# ws_post
#----------------------------------------------------------------------------
#
#  Metodo POST para el API REST.
#
#----------------------------------------------------------------------------
sub ws_post  {
my ($self,$class,$endpoint,$params)=@_;

   $self->err_num(0);
   $self->err_str('');

   my $timeout=$self->timeout();
   my $host=$self->host();
   my $url='https://'.$host.'/onm/api/'.$Crawler::CNMAPI::APIVERSION;
	if ((defined $class) && ($class ne '')) {$url .= '/'.$class; }
   if ((defined $endpoint) && ($endpoint ne '')) {$url .= '/'.$endpoint; }
   my @extra=();

   foreach my $k (keys %$params) {
      push @extra, $k.'='.$params->{$k};
   }
#   if (scalar (@extra)>0) { $url .= '?'.join('&',@extra); }

	my $p=join('; ',@extra);
   $self->log('info',"ws_post:: url=$url params=$p");

   my ($err_num,$err_str,$results)=(0,'UNK',{});
   my ($referer,$content,$status,$rc,$rcstr)=(undef,'','200 OK',0,0);

   my $sid=$self->sid();

   eval {

      #my $ua = LWP::UserAgent->new;
		my $ua = LWP::UserAgent->new(ssl_opts => { SSL_verify_mode => 0, verify_hostname => 0, SSL_version=>'TLSv1'});
      $ua->default_header(Authorization => $sid);
      my $response = $ua->post($url, $params);
		$content = $response->content();

		# Miro si hay algun error
		if ( ! $response->is_success ) {

			my ($err_num,$err_str) = $self->_decode_error($response->status_line);

         $self->log('warning',"ws_post:: **ERROR** EN POST url=$url ($err_str) sid=$sid");
         $self->err_str("ERROR EN POST url=$url ($err_str)");
      }

      $self->log('info',"ws_post:: res=$content");
   };
   if ($@) {
      $err_num=1001;
      $err_str=$@;
      $err_str=~s/\n/ \./g;
      $self->log('warning',"ws_post:: **ERROR** EN POST url=$url ($err_str)");
      $self->err_str("ERROR EN POST url=$url ($err_str)");
   }

   else {

      # Se decodifica $content
      eval {
         my $json=JSON->new();
         $json->ascii(1);
         $results=$json->decode($content);
      };
      if ($@) {
			# Solo si no ha habido un error anterior capturo este error.
			if ($err_num == 0){
	         $err_num=1002;
   	      $err_str=$@;
      	   $err_str=~s/\n/ \./g;
         	$self->log('warning',"ws_post:: **ERROR** EN DECODE url=$url ($err_str)");
         	$self->err_str("ERROR EN DECODE DATA url=$url ($err_str)");
			}
      }
   }

   $self->err_num($err_num);

   return $results;

}


#----------------------------------------------------------------------------
# ws_del
#----------------------------------------------------------------------------
#
#  Metodo DELETE para el API REST.
#
#----------------------------------------------------------------------------
sub ws_del  {
my ($self,$class,$endpoint,$params)=@_;

   $self->err_num(0);
   $self->err_str('');

   my $timeout=$self->timeout();
   my $host=$self->host();
   my $url='https://'.$host.'/onm/api/'.$Crawler::CNMAPI::APIVERSION;
   if ((defined $class) && ($class ne '')) {$url .= '/'.$class; }
   if ((defined $endpoint) && ($endpoint ne '')) {$url .= '/'.$endpoint; }
   my @extra=();

   foreach my $k (keys %$params) {
      push @extra, $k.'='.$params->{$k};
   }
#   if (scalar (@extra)>0) { $url .= '?'.join('&',@extra); }

   my $p=join('; ',@extra);
   $self->log('info',"ws_del:: url=$url params=$p");

   my ($err_num,$err_str,$results)=(0,'UNK',[]);
   my ($referer,$content,$status,$rc,$rcstr)=(undef,'','200 OK',0,0);

   my $sid=$self->sid();

   eval {

      #my $ua = LWP::UserAgent->new;
		my $ua = LWP::UserAgent->new(ssl_opts => { SSL_verify_mode => 0, verify_hostname => 0, SSL_version=>'TLSv1'});
      $ua->default_header(Authorization => $sid);
      my $response = $ua->delete($url, $params);
      $content = $response->content();

      # Miro si hay algun error
      if ( ! $response->is_success ) {

         my ($err_num,$err_str) = $self->_decode_error($response->status_line);

         $self->log('warning',"ws_del:: **ERROR** EN DELETE url=$url ($err_str)");
         $self->err_str("ERROR EN DELETE url=$url ($err_str)");
      }

      $self->log('info',"ws_del:: res=$content");
   };
   if ($@) {
      $err_num=1001;
      $err_str=$@;
      $err_str=~s/\n/ \./g;
      $self->log('warning',"ws_del:: **ERROR** EN DELETE url=$url ($err_str)");
      $self->err_str("ERROR EN DELETE url=$url ($err_str)");
   }

   else {

      # Se decodifica $content
      eval {
         my $json=JSON->new();
         $json->ascii(1);
         $results=$json->decode($content);
      };
      if ($@) {
         # Solo si no ha habido un error anterior capturo este error.
         if ($err_num == 0){
            $err_num=1002;
            $err_str=$@;
            $err_str=~s/\n/ \./g;
            $self->log('warning',"ws_del:: **ERROR** EN DECODE url=$url ($err_str)");
            $self->err_str("ERROR EN DECODE DATA url=$url ($err_str)");
         }
      }
   }
   $self->err_num($err_num);

   return $results;

}


#----------------------------------------------------------------------------
sub _decode_error  {
my ($self,$msg)=@_;

	my ($err_num,$err_str) = (1000,$msg);
   if ($msg =~ /401 Authorization Required/) {
      $err_num=401;
		my $sid=$self->sid();
      $err_str .= " (sid=$sid)";
   }
   elsif ($msg =~ /400 Bad Request/) {
      $err_num=400;
   }
   elsif ($msg =~ /^(\d+)\s+.*$/) {
      $err_num=$1;
   }

	return ($err_num,$err_str);
}

1;
