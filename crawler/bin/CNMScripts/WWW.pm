#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/WWW.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::WWW;
@ISA=qw(CNMScripts);

use strict;
use LWP::UserAgent;
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use Net::Curl::Easy qw(:constants);
use bytes;
use HTML::LinkExtor;
use Time::HiRes qw(gettimeofday tv_interval);
use JSON;

my $VERSION = '1.00';
#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::WWW
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_scheme} = $arg{scheme} || 'http';
   $self->{_host} = $arg{host} || '';
   $self->{_port} = $arg{port} || '22';
   $self->{_credentials} = $arg{credentials} || {};
   $self->{_lwp} = $arg{lwp} || '';
   $self->{_endpoint} = $arg{endpoint} || '';
   $self->{_timeout} = $arg{timeout} || 10;
   $self->{_err_num} = $arg{er_num} || 0;
   $self->{_err_str} = $arg{err_str} || '';

   $self->{_url} = $arg{url} || '';
   $self->{_file_html} = $arg{file_html} || '';
   return $self;
}

#----------------------------------------------------------------------------
# scheme
#----------------------------------------------------------------------------
sub scheme {
my ($self,$scheme) = @_;
   if (defined $scheme) {
      $self->{_scheme}=$scheme;
   }
   else { return $self->{_scheme}; }
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
# port
#----------------------------------------------------------------------------
sub port {
my ($self,$port) = @_;
   if (defined $port) {
      $self->{_port}=$port;
   }
   else { return $self->{_port}; }
}

#----------------------------------------------------------------------------
# credentials
#----------------------------------------------------------------------------
sub credentials {
my ($self,$credentials) = @_;
   if (defined $credentials) {
      $self->{_credentials}=$credentials;
   }
   else { return $self->{_credentials}; }
}

#----------------------------------------------------------------------------
# timeout
#----------------------------------------------------------------------------
sub timeout {
my ($self,$timeout) = @_;
   if (defined $timeout) {
      $self->{_timeout}=$timeout;
   }
   else {
      return $self->{_timeout};
   }
}

#----------------------------------------------------------------------------
# err_str
#----------------------------------------------------------------------------
sub err_str {
my ($self,$err_str) = @_;
   if (defined $err_str) {
      $self->{_err_str}=$err_str;
   }
   else {
      return $self->{_err_str};
   }
}

#----------------------------------------------------------------------------
# err_num
#----------------------------------------------------------------------------
sub err_num {
my ($self,$err_num) = @_;
   if (defined $err_num) {
      $self->{_err_num}=$err_num;
   }
   else {
      return $self->{_err_num};
   }
}

#----------------------------------------------------------------------------
# lwp
#----------------------------------------------------------------------------
sub lwp {
my ($self,$lwp) = @_;
   if (defined $lwp) {
      $self->{_lwp}=$lwp;
   }
   else { return $self->{_lwp}; }
}

#----------------------------------------------------------------------------
# endpoint
#----------------------------------------------------------------------------
sub endpoint {
my ($self,$endpoint) = @_;
   if (defined $endpoint) {
      $self->{_endpoint}=$endpoint;
   }
   else { return $self->{_endpoint}; }
}

#----------------------------------------------------------------------------
# url
#----------------------------------------------------------------------------
sub url {
my ($self,$url) = @_;
   if (defined $url) {
      $self->{_url}=$url;
   }
   else { return $self->{_url}; }
}

#----------------------------------------------------------------------------
# file_html
#----------------------------------------------------------------------------
sub file_html {
my ($self,$file_html) = @_;
   if (defined $file_html) {
      $self->{_file_html}=$file_html;
   }
   else { return $self->{_file_html}; }
}

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# get
# GET HTTP
#----------------------------------------------------------------------------
sub get  {
my ($self,$params)=@_;

   $self->err_num(0);
   $self->err_str('');

   my $timeout=$self->timeout();
   my $scheme=$self->scheme();
   my $host=$self->host();
   my $port=$self->port();
   my $endpoint=$self->endpoint();
   my $credentials=$self->credentials();
	my $realm = (exists $credentials->{'realm'}) ? $credentials->{'realm'} : 'My Realm';

   my $url=$scheme.'://'.$host.':'.$port;
   if ((defined $endpoint) && ($endpoint ne '')) {$url .= '/'.$endpoint; }

   my @extra=();
   foreach my $k (keys %$params) {
      push @extra, $k.'='.$params->{$k};
   }
   if (scalar (@extra)>0) { $url .= '?'.join('&',@extra); }

   #$self->log('info',"ws_get:: url=$url");

   my ($err_num,$err_str,$results)=(0,'UNK',[]);
   my ($referer,$content,$status,$rc,$rcstr)=(undef,'','200 OK',0,0);

   eval {

		$self->log('debug',"get:: url=$url host=$host port=$port");

      my $ua = LWP::UserAgent->new;
		if ((exists $credentials->{'user'}) && (exists $credentials->{'pwd'})) {
			$ua->credentials("$host:$port",$realm, $credentials->{'user'},$credentials->{'pwd'});
			$self->log('debug',"get:: user=$credentials->{'user'} pwd=xxxxxx");
		}
      my $response = $ua->get($url);
		$content = $response->content();

      # Miro si hay algun error
      if ( ! $response->is_success ) {

			($err_num,$err_str) = (1,'ERROR EN GET');
			if ($response->status_line =~ /^(\d+)\s+(.*)$/) {
				($err_num,$err_str) = ($1,$2);
			}
			
         $self->log('warning',"get:: **ERROR** url=$url [$err_num] $err_str");
      }

   };
   if ($@) {
      $err_num=1001;
      $err_str=$@;
      $err_str=~s/\n/ \./g;
      $self->log('warning',"get:: **ERROR** url=$url [$err_num] $err_str");
   }
   elsif ($err_num==0) {

      # Se decodifica $content
      eval {
         my $json=JSON->new();
         $json->ascii(1);
			$content =~ s/\x00/\n/g;
         $results=$json->decode($content);

      };
      if ($@) {
         $err_num=1002;
         $err_str=$@;
         $err_str=~s/\n/ \./g;
         #$self->log('warning',"ws_get:: **ERROR** EN DECODE DATA url=$url ($err_str) DATA=$content---");
         #$self->err_str("ERROR EN DECODE DATA url=$url ($err_str) DATA=$content---");
      }
   }

   $self->err_num($err_num);
   $self->err_str($err_str);

   return $results;

}

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# mon_http_base
# Se usa Net::Curl::Easy
#----------------------------------------------------------------------------
# Para validar:
#curl --output /tmp/kk --silent --write-out '%{http_code};%{time_appconnect};%{time_connect};%{time_namelookup};%{time_pretransfer};%{time_starttransfer};%{time_total}\n' http://www.s30labs.com
#----------------------------------------------------------------------------
sub mon_http_base {
my ($self,$desc)=@_;

   $self->err_num(0);
   $self->err_str('');

	my $timeout= $self->timeout();
   my %results=( 'elapsed'=>'U', 'size'=>0, 'pattern'=>0, 'rctype'=>0, 'nlinks'=>0, 'rc'=>0);
   my $url=$desc->{'url'};
   my $url_mod=$url;

	my $VERBOSE=$desc->{'verbose'};

   my $t0 = [gettimeofday];
   my $elapsed = tv_interval ( $t0, [gettimeofday]);
   my $elapsed3 = sprintf("%.6f", $elapsed);
   $results{'elapsed'}=$elapsed3;

   my $easy = Net::Curl::Easy->new( { body => '', headers => '', all_headers=>[]} );
   my ($referer,$content,$status,$rc,$rcstr)=(undef,'','200 OK',0,0);
   eval {

		alarm($timeout);

      $easy->setopt( CURLOPT_URL, $url_mod);
      $easy->setopt( CURLOPT_VERBOSE, $VERBOSE );
      $easy->setopt( CURLOPT_WRITEHEADER, \$easy->{headers} );
		$easy->setopt( CURLOPT_HEADERFUNCTION, \&cb_header );
      $easy->setopt( CURLOPT_FILE, \$easy->{body} );

		# Cloud Tokens
		my $info_token='';
      if (exists $desc->{'profile'}->{'ProfileType'}) {
         my $access_token=$self->get_access_token($desc);
         my @headers = (
            "Authorization: Bearer $access_token"
         );
         $easy->setopt(CURLOPT_HTTPHEADER, \@headers);
			$info_token='WITH TOKEN';
      }

    	$easy->setopt( CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36' );

#    $easy->setopt( CURLOPT_TIMEOUT, 300 );
    	$easy->setopt( CURLOPT_CONNECTTIMEOUT, $timeout );
#    $easy->setopt( CURLOPT_MAXREDIRS, 20 );
    	$easy->setopt( CURLOPT_FOLLOWLOCATION, 1 );
#    $easy->setopt( CURLOPT_ENCODING, 'gzip,deflate' ) if $has_zlib;
    	$easy->setopt( CURLOPT_SSL_VERIFYPEER, 0 );
#    $easy->setopt( CURLOPT_COOKIEFILE, '' );
#    $easy->setopt( CURLOPT_USERAGENT, 'Irssi + Net::Curl' );

      $easy->perform();

      $self->log('info',"mon_http_base (curl) >> GET URL $info_token = $url_mod");

		alarm(0);
   };

   if ($@) {
      print STDERR "**ERROR** EN GET url=$url ($@)\n";
      $self->log('info',"mon_http_base (curl) >> **ERROR** EN GET url=$url ($@) (timeout=$timeout)");
	   $self->err_num(1);
   	$self->err_str($@);

      return \%results;
   }

	#if ($VERBOSE) { print Dumper($easy->{all_headers}); }

   $elapsed = tv_interval ( $t0, [gettimeofday]);
   $elapsed3 = sprintf("%.6f", $elapsed);
   $results{'elapsed'}=$elapsed3;

   $content = $easy->{'body'};
   my $count=0;
   if ($desc->{'pattern'}) {
      while ($content =~ /$desc->{'pattern'}/g) { $count++ }
      $results{'pattern'} = $count;
   }
   else { $results{'pattern'} = 0; }

   $results{'size'} = bytes::length($content);

#   if ($easy->{'headers'} =~/HTTP\/\d+\.\d+ (\d+) (.+?)\r\n/g) {
#      $results{'rc'} = $1;
#      $results{'rcstr'} = $2;
#      chomp $results{'rcstr'};
#      $results{'rctype'} = int ($results{'rc'}/100);
#   }

	# Iterate over all headers to get return code. 
	# In case of redirection stores last one.
	foreach my $h (@{$easy->{all_headers}}) {
		chomp $h;
		if ($h=~/HTTP\/\d+\.\d+ (\d+) (.+?)/g) {
			$results{'rc'} = $1;
	      $results{'rcstr'} = $2;
			$results{'rctype'} = int ($results{'rc'}/100);
		}
	}
   my $parser = HTML::LinkExtor->new();
   $parser->parse($content);
   my @links = $parser->links();
   $results{'nlinks'} = scalar(@links);

$results{'body'} = $content;
   return \%results;
}


sub cb_header {
my ( $easy, $data, $uservar ) = @_;
	
	push @{$easy->{all_headers}},$data; 
   $$uservar .= $data;
   return length $data;
}

#----------------------------------------------------------------------------
sub mon_http_base_curl {
my ($self,$desc)=@_;

   $self->err_num(0);
   $self->err_str('');
   my $timeout= $self->timeout();

#$timeout=60;

   my %results=( 'elapsed'=>'U', 'size'=>0, 'pattern'=>0, 'rctype'=>0, 'nlinks'=>0, 'rc'=>0);
   my $url=$desc->{'url'};

   my $VERBOSE=$desc->{'verbose'};

   my $k=$url.time();
   my $file_out = '/tmp/www'.substr(md5_hex($k),0,12);
	my $file_debug = $file_out.'-debug';

   my $cmd= "curl -L --output $file_out --connect-timeout $timeout --silent --verbose --write-out '%{http_code};%{time_appconnect};%{time_connect};%{time_namelookup};%{time_pretransfer};%{time_starttransfer};%{time_total}\n' $url 2>$file_debug";
   my $line=`$cmd`;
   chomp $line;
   $self->log('info',"mon_http_base (curlcmd) GET url=$url >> $line");

   #401;0.152;0.046;0.005;0.152;0.202;0.320
   my ($http_code,$time_appconnect,$time_connect,$time_namelookup,$time_pretransfer,$time_starttransfer,$time_total) = split(';', $line);
   $results{'rc'} = $http_code;
   $results{'rctype'} = int ($http_code/100);
   $results{'elapsed'} = $time_total;
#  $results{'rcstr'} = $2;

   local($/) = undef;  # slurp
   open (F,"<$file_out");
   my $content = <F>;
   close F;
	
	if ($http_code>0) {
	   unlink $file_out, $file_debug;
	}

   my $count=0;
   if ($desc->{'pattern'}) {
      while ($content =~ /$desc->{'pattern'}/g) { $count++ }
      $results{'pattern'} = $count;
   }
   else { $results{'pattern'} = 0; }

   $results{'size'} = bytes::length($content);

   my $parser = HTML::LinkExtor->new();
   $parser->parse($content);
   my @links = $parser->links();
   $results{'nlinks'} = scalar(@links);

   return \%results;

}

#----------------------------------------------------------------------------
sub get_access_token {
my ($self,$desc)=@_;

   $self->err_num(0);
   $self->err_str('');
   my $timeout= $self->timeout();
	my $access_token='';

	if (! exists $desc->{'profile'}->{'ProfileType'}) { return $access_token; }

	if ($desc->{'profile'}->{'ProfileType'} =~ /AZURE/i) {

		my $resource = 'https://management.azure.com/';
		if ( 	(! exists $desc->{'profile'}->{'Credentials'}->{'TenantId'}) ||
				(! exists $desc->{'profile'}->{'Credentials'}->{'ClientId'}) ||
				(! exists $desc->{'profile'}->{'Credentials'}->{'ClientSecret'}) ) { return $access_token; }

		my $tenant_id = $desc->{'profile'}->{'Credentials'}->{'TenantId'};
		my $client_id = $desc->{'profile'}->{'Credentials'}->{'ClientId'};
		my $client_secret = $desc->{'profile'}->{'Credentials'}->{'ClientSecret'};

		my $ua = LWP::UserAgent->new;
		my $url = "https://login.microsoftonline.com/$tenant_id/oauth2/token";

		my %form = (
    		grant_type    => 'client_credentials',
    		client_id     => $client_id,
    		client_secret => $client_secret,
    		resource      => $resource,
		);

		my $response = $ua->post($url, \%form);

		if ($response->is_success) {
			my $content = decode_json($response->decoded_content);
		   $access_token = $content->{access_token};
			$self->log('warning',"get_access_token:: TOKEN OK");
		} 
		else {
			my $err_str=$response->status_line;
			$self->err_str($err_str);
			$self->log('warning',"get_access_token:: **ERROR** $err_str");
		}
	}

	return $access_token;
}


1;

__END__

