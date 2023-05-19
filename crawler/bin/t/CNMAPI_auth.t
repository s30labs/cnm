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
CNMAPI_auth.t v1.0 (c) s30labs

$fpth[$#fpth] [-user abc] [-pwd xxxx]
$fpth[$#fpth] -help|-h

-user     : User for token
-pwd      : Password of the user.
-help     : Ayuda
-h        : Ayuda
USAGE

#------------------------------------------------------------------------------
my %OPTS = ();
GetOptions (\%OPTS,  'h','help','v','verbose','user=s','pwd=s')
            or die "$0:[ERROR] en el paso de parametros. Si necesita ayuda ejecute $0 -help\n";

if ( ($OPTS{'help'}) || ($OPTS{'h'}) ) { die $USAGE; }

my $user = (defined $OPTS{'user'}) ? $OPTS{'user'} : 'admin';
my $pwd = (defined $OPTS{'pwd'}) ? $OPTS{'pwd'} : 'cnm123';

my $log_level= 'info';
my $api=CNMScripts::CNMAPI->new( 'host'=>$cnm, 'timeout'=>10, 'log_level'=>$log_level );
my $sid = $api->ws_get_token($user,$pwd);
print "sid=$sid\n";



