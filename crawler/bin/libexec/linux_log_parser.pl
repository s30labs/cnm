#!/usr/bin/perl -w
#--------------------------------------------------------------------------------------
# NAME:  linux_log_parser.pl
#
# DESCRIPTION:
# Obtiene las lineas del fichero de log especificado recorriendo el fichero desde el final.
# Solo considera las lineas que estan dentro de la ventana temporal especificada por lapse.
# Se ejecuta en la maquina que tiene el fichero de log. Para ejecutarlo en una maquina remota
# hay que copiarlo previamente. Esto se hace por eficiencia, para transmitir solo las
# lineas de log nuevas.
#
# Uso: crawler/bin/libexec/linux_log_parser.pl [-t parser_type] [-f file] [-m pattern] [-l lapse]
#
# CALLING SAMPLE:
#
# linux_log_parser.pl -t syslog -f /var/log/messages -l 300
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
use File::Basename;
use Data::Dumper;

#----------------------------------------------------------------------------
# Se cargan los modulos que haya en /opt/crawler/bin/CNMScripts/LogParser
#----------------------------------------------------------------------------
BEGIN {
   my $module='';
   my $path = '/opt/crawler/bin/CNMScripts/LogParser/*.pm';
   my @files = < $path >;
   foreach my $mod (@files){
      my($filename, $directories, $suffix) = fileparse($mod);
      my $m=$filename;
      $m=~s/(\S+)\.pm/$1/;
      $module='CNMScripts::LogParser::'.$m;
print "MODULO=$module\n";

      eval("use $module");
      if ($@) { die "**ERROR** al cargar parser $module ($@)\n"; }
   }
}


#-------------------------------------------------------------------------------------------
my %opts=();
my $USAGE="Uso: $0 [-t parser_type] [-f file] [-m pattern] [-l lapse] [-z]";
# -user=aaaa -pwd=bbb 

getopts("hzt:f:m:l:",\%opts);

#-------------------------------------------------------------------------------------------
if (exists $opts{h}) { die "$USAGE\n"; }

my $file = (exists $opts{f}) ? $opts{f} : '/var/log/messages';
my $pattern = (exists $opts{m}) ? $opts{m} : '';

my $lapse = (exists $opts{l}) ? $opts{l} : 300;	#300 segs = 5 min
my $limit = time() - $lapse;

my $type = (exists $opts{t}) ? $opts{t} : 'syslog';
my $parser = 'CNMScripts::LogParser::parser_syslog::parser_'.$type;

my $only_metric = (exists $opts{z}) ? $opts{z} : 0;
#-------------------------------------------------------------------------------------------
my $tline_last=0;
my $index=0;
my $nlines=0;
my @lines = `grep -n "" $file | sort -r -n | sed 's/^[0-9]*://g'`;
foreach my $l (@lines) {

   chomp $l;
   #my ($tline,$txt) = &{$parser}($l);
   my $hdata = &{$parser}($l);
	my $tline=$hdata->{'timestamp'};
	my $txt=$hdata->{'extra_line'};

#print "tline=$tline limit=$limit\n";
   if ($tline<$limit) { last;}

#print "pattern=$pattern\n";
   if (($pattern ne '') && ($txt !~ /$pattern/)) { next;}

	$nlines+=1;
	# Formato de salida: timestamp.index >> linea original
	# index solo se incrementa si coincide el timestamp
   if ( $tline == $tline_last) {
		$index+=1;
	}
	else { 
		$index=0;
		$tline_last=$tline;
	}

	if (! $only_metric) { print "$tline:$index >> $l\n"; }
}

if ($only_metric) { print '<001> Lineas = '.$nlines."\n"; } 

