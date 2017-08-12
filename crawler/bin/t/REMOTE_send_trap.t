#!/usr/bin/perl -w
use lib "/opt/crawler/bin";
use strict;
use Getopt::Long;
use Net::SMTP;
use Inline::Files;

#------------------------------------------------------------------------------
my $host='localhost';
my $mode='set';
my $version=2;

#------------------------------------------------------------------------------
my @fpth = split ('/',$0,10);
my @fname = split ('\.',$fpth[$#fpth],10);
my $USAGE = <<USAGE;
REMOTE_send_trap v1.0 (c) s30labs

$fpth[$#fpth] -host 1.1.1.1 -set
$fpth[$#fpth] -host 1.1.1.1 -clr
$fpth[$#fpth] -help|-h

-host : IP|host del CNM al que se envia el trap.
-v1   : Se envia el trap con version 1. (Por defecto es v2)
-set  : Genera alerta de tipo SET
-clr  : Genera alerta de tipo CLR
-help : Ayuda
-h    : Ayuda
USAGE

#------------------------------------------------------------------------------
my %OPTS = ();
GetOptions (\%OPTS,  'h','help','v','verbose','host=s','set','clr','v1','v2')
            or die "$0:[ERROR] en el paso de parametros. Si necesita ayuda ejecute $0 -help\n";

if ( ($OPTS{'help'}) || ($OPTS{'h'}) ) { die $USAGE; }
if ($OPTS{'v1'}) { $version=1; }

if ($OPTS{'host'}) { $host=$OPTS{'host'}; } 	
if ($OPTS{'set'}) { 
	$mode='set'; 
	if ($version==2) {
		`snmptrap -v 2c -c public $host '' NOTIFICATION-TEST-MIB::demo-notif SNMPv2-MIB::sysLocation.0 s "SET"`;
	}
	else {
		`snmptrap -v 1 -c public $host TRAP-TEST-MIB::demotraps $host 6 17 '' SNMPv2-MIB::sysLocation.0 s "SET"`;
	}
}
elsif ($OPTS{'clr'}) { 
	$mode='clr'; 
	if ($version==2) {
		`snmptrap -v 2c -c public $host '' NOTIFICATION-TEST-MIB::demo-notif SNMPv2-MIB::sysLocation.0 s "CLR"`;
	}
	else {
		`snmptrap -v 1 -c public $host TRAP-TEST-MIB::demotraps $host 6 17 '' SNMPv2-MIB::sysLocation.0 s "CLR"`;
	}
}

