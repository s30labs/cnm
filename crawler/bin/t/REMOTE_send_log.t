#!/usr/bin/perl -w
use lib "/opt/crawler/bin";
use strict;
use Getopt::Long;
use CNMScripts;

my $host='localhost';
my $mode='set';
my $facility='local4';

#------------------------------------------------------------------------------
my @fpth = split ('/',$0,10);
my @fname = split ('\.',$fpth[$#fpth],10);
my $USAGE = <<USAGE;
REMOTE_send_log v1.0 (c) s30labs

$fpth[$#fpth] -host 1.1.1.1 -set
$fpth[$#fpth] -host 1.1.1.1 -clr
$fpth[$#fpth] -help|-h

-host     : IP|host del CNM al que se envia el syslog.
-facility : Facility usada. Por defecto es local4.
-set      : Genera alerta de tipo SET
-clr      : Genera alerta de tipo CLR
-help     : Ayuda
-h        : Ayuda
USAGE

#------------------------------------------------------------------------------
my %OPTS = ();
GetOptions (\%OPTS,  'h','help','v','verbose','host=s','facility=s','set','clr')
            or die "$0:[ERROR] en el paso de parametros. Si necesita ayuda ejecute $0 -help\n";

if ( ($OPTS{'help'}) || ($OPTS{'h'}) ) { die $USAGE; }

if ($OPTS{'facility'}) { $facility=$OPTS{'facility'}; }
my $script = CNMScripts->new('nologinit'=>1);
$script->init_log($facility);

if ($OPTS{'host'}) { $host=$OPTS{'host'}; } 	
if ($OPTS{'set'}) { 
	$mode='set'; 
	$script->log('info',"TEST ALERTA REMOTA POR SYSLOG - SET");
}
elsif ($OPTS{'clr'}) { 
	$mode='clr'; 
	$script->log('info',"TEST ALERTA REMOTA POR SYSLOG - CLR");
}

