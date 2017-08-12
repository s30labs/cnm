#!/usr/bin/perl -w
use lib "/opt/crawler/bin";
use strict;
use Getopt::Long;
use Net::SMTP;
#use Crawler::CNMAPI::Functions;
use CNMScripts::CNMAPI;
use Data::Dumper;
use JSON;

#------------------------------------------------------------------------------
my $host_ip='127.0.0.1';
my $cnm='localhost';
my $msg = 'TEST API EVENT - SET';

#------------------------------------------------------------------------------
my @fpth = split ('/',$0,10);
my @fname = split ('\.',$fpth[$#fpth],10);
my $USAGE = <<USAGE;
REMOTE_send_api_event v1.0 (c) s30labs

$fpth[$#fpth] -cnm 1.1.1.1 -deviceip 1.1.1.2 -set
$fpth[$#fpth] -cnm 1.1.1.1 -deviceip 1.1.1.2 -clr
$fpth[$#fpth] -help|-h

-cnm      : IP|host del CNM al que se envia el evento.
-deviceip : IP|host que genera el evento.
-set      : Genera alerta de tipo SET
-clr      : Genera alerta de tipo CLR
-help     : Ayuda
-h        : Ayuda
USAGE

#------------------------------------------------------------------------------
my %OPTS = ();
GetOptions (\%OPTS,  'h','help','v','verbose','cnm=s','deviceip=s','hostname=s','set','clr')
            or die "$0:[ERROR] en el paso de parametros. Si necesita ayuda ejecute $0 -help\n";

if ( ($OPTS{'help'}) || ($OPTS{'h'}) ) { die $USAGE; }

if ($OPTS{'cnm'}) { $cnm = $OPTS{'cnm'}; }

if (defined $OPTS{'set'}) { 
	$msg = 'TEST API EVENT - SET'; 
}
elsif (defined $OPTS{'clr'}) {
   $msg = 'TEST API EVENT - CLR';
}

my $evkey = 'evtestremoteapi';
my %params=('txt'=>$msg, 'evkey'=>$evkey);
if ($OPTS{'deviceip'}) { $params{'deviceip'} = $OPTS{'deviceip'}; }
else { die $USAGE; }



my $log_level= 'info';
my $api=CNMScripts::CNMAPI->new( 'host'=>$cnm, 'timeout'=>10, 'log_level'=>$log_level );
my ($user,$pwd)=('admin','cnm123');
my $sid = $api->ws_get_token($user,$pwd);
print "sid=$sid\n";

my $class='';
my $endpoint='events.json';
my $response = $api->ws_post($class,$endpoint,\%params);

#'rc' => 0,
#'id' => '2',
#'rcstr' => ''
if ($response->{'rc'}!=0) {
   print '**ERROR** al crear el evento ['.$response->{'rc'}.'] - '.$response->{'rcstr'}."\n";
   exit $response->{'rc'};
}
else { 
	Dumper($response);
}


