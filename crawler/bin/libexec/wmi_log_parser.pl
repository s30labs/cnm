#!/usr/bin/perl -w
#--------------------------------------------------------------------------------------
# NAME:  linux_app_wmi_EventLog.pl
#
# DESCRIPTION:
# Obtiene valores de los contadores WMI de un equipo WIndows remoto
#
# CALLING SAMPLE:
# linux_app_wmi_EventLog.pl -n 1.1.1.1 [-d dominio] -u user -p pwd  [-v]
# linux_app_wmi_EventLog.pl -h  : Ayuda
#
# INPUT (PARAMS):
# a. -n  :  IP remota
# b. -d  :  Dominio
# c. -u  :  Usuario WMI
# d. -p  :  Clave
#
# OUTPUT (STDOUT):
# <001> Number of Files [/opt|.] = 7
#
# OUTPUT (STDERR):
# Error info, warnings etc... If verbose also debug info.
# 1361280825>> Feb 19 14:33:45 cnm-devel sshd[8875]: Accepted password for root from 10.2.254.252 port 60473 ssh2
#
# EXIT CODE:
#  0: OK
# -1: System error
# >0: Script error
#--------------------------------------------------------------------------------------
use lib '/opt/crawler/bin/';
use strict;
use Getopt::Std;
use Data::Dumper;
use Stdout;
use CNMScripts::WMI;
use JSON;

#--------------------------------------------------------------------------------------
my $lines;

#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
my @fpth = split ('/',$0,10);
my @fname = split ('\.',$fpth[$#fpth],10);
my $VERSION="1.0";

my $USAGE = <<USAGE;
ssh2cmd. $VERSION

$fpth[$#fpth] -n IP -u user -p pwd [-d domain] [-v]
$fpth[$#fpth] -n IP -u domain/user -p pwd [-v]
$fpth[$#fpth] -h  : Ayuda

-n    IP remota
-u    user
-p    pwd
-d    Dominio
-v    Verbose
-i 	Indice de busqueda
USAGE

#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
my %opts=();
getopts("hvn:u:p:d:i:t:f:m:l:",\%opts);

if ($opts{h}) { die $USAGE;}
my $ip = $opts{n} || die $USAGE;
my $user = $opts{u} || die $USAGE;
my $pwd = $opts{p} || die $USAGE;

my $condition='';
my $file = (exists $opts{f}) ? $opts{f} : 'System';
$condition= " Logfile = 'System' ";

my $pattern = (exists $opts{m}) ? $opts{m} : '';

my $lapse = (exists $opts{l}) ? $opts{l} : 300; #300 segs = 5 min
my $limit = time() - $lapse;

my $type = (exists $opts{t}) ? $opts{t} : 'syslog';
my $parser = 'parser_'.$type;

my $wmi = CNMScripts::WMI->new('host'=>$ip, 'user'=>$user, 'pwd'=>$pwd);

if (($opts{i}) && ($opts{i}=~/\d+/)) { $condition .= "AND RecordNumber>$opts{i}"; }
else {
	my $last_time = $wmi->time2date($limit);
	$condition .= "AND TimeGenerated>'$last_time'";
#$condition .= "AND TimeGenerated>'20130209071400.000000+060'";

}

print "condition=$condition\n";

#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
my %EVENT_TYPES = ( '1'=>'Error', '2'=>'Warning', '3'=>'Information', '4'=>'Security Audit Success', '5'=>'Security Audit Failure' );
 
#--------------------------------------------------------------------------------------
$lines = $wmi->get_wmi_lines("\"SELECT * from Win32_NTLogEvent Where $condition\"");
#print Dumper ($lines);

#if (ref($lines) eq "ARRAY") {
#	foreach my $l (@$lines) {
#		print '-'x60 . "\n";
#		print 'RecordNumber = '.$l->{'RecordNumber'}."\n";
#		print 'EventCode = '.$l->{'EventCode'}."\n";
#		print 'ComputerName = '.$l->{'ComputerName'}."\n";
#		print 'Type = '.$l->{'Type'}."\n";
#		print 'SourceName = '.$l->{'SourceName'}."\n";
#		print 'Message = '.$l->{'Message'}."\n";
#		print 'EventType = '.$l->{'EventType'}."\n";
#		print 'Logfile = '.$l->{'Logfile'}."\n";
#		#print 'TimeGenerated = '.$l->{'TimeGenerated'}."\n";
#		#print 'TimeWritten = '.$l->{'TimeWritten'}."\n";
#		print 'TimeGenerated = '.$wmi->date_format($l->{'TimeGenerated'})."\n";
#		print 'TimeWritten = '.$wmi->date_format($l->{'TimeWritten'})."\n";
#
#   }
#}

# 1361280825>> Feb 19 14:33:45 cnm-devel sshd[8875]: Accepted password for root from 10.2.254.252 port 60473 ssh2

if (ref($lines) eq "ARRAY") {
  	foreach my $l (@$lines) {
		$l->{'EventType'}=$EVENT_TYPES{$l->{'EventType'}};
		$l->{'TimeGenerated'}=$wmi->date_format($l->{'TimeGenerated'});
		$l->{'TimeWritten'}=$wmi->date_format($l->{'TimeWritten'});

		my $tx=time;
		print $l->{'RecordNumber'}.'>> '.$l->{'TimeGenerated'}.' '.$l->{'ComputerName'}.' '.$l->{'EventType'}.' '.$l->{'Message'}."\n";
	}
}



print @$lines."\n";
#--------------------------------------------------------------------------------------
