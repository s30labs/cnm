#!/usr/bin/perl -w
#--------------------------------------------------------------------------------------
# NAME:  log_pull.pl
#
# DESCRIPTION:
# Obtiene las lineas de log del fichero especificado almacenado en CNM
#
# Uso: crawler/bin/libexec/log_pull.pl [-n ip] [-f file] [-m pattern] [-l lapse]
#
# CALLING SAMPLE:
#
# log_pull.pl -n 1.1.1.1 -f /var/log/messages -l 300
#
# INPUT (PARAMS):
#
# OUTPUT (STDOUT):
#<001> Parents = 0
#
# OUTPUT (STDERR):
# Error info, warnings etc... If verbose also debug info.
#
# EXIT CODE:
#  0: OK
# -1: System error
# >0: Script error
#--------------------------------------------------------------------------------------
use lib '/opt/crawler/bin/';
use Getopt::Std;
use Time::Local;
use CNMScripts::LogAnalysis;
use Data::Dumper;

#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
my %opts=();
my $USAGE="Uso: $0 [-n ip] [-f file] [-m pattern] [-l lapse] [-z]";
# -user=aaaa -pwd=bbb 

getopts("hzn:f:m:l:",\%opts);

#-------------------------------------------------------------------------------------------
my %info=();
if (exists $opts{h}) { die "$USAGE\n"; }
if (! exists $opts{n}) { die "$USAGE\n"; }
$info{'ip'} = $opts{n};

if (! exists $opts{f}) { die "$USAGE\n"; }
$info{'file'} = $opts{f};

$info{'pattern'} = (exists $opts{m}) ? $opts{m} : '';
$info{'lapse'} = (exists $opts{l}) ? $opts{l} : 300;	#300 segs = 5 min
#my $limit = time() - $lapse;

my $only_metric = (exists $opts{z}) ? $opts{z} : 0;

#-------------------------------------------------------------------------------------------
my $la = CNMScripts::LogAnalysis->new();
$la->get_data_lines(\%info);

#if ($only_metric) { print '<001> Lineas = '.$nlines."\n"; } 

#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------

