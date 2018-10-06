#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# RRD_test_format.pl
#-------------------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use ONMConfig;
use Crawler::Store;
use Metrics::Base;

#-------------------------------------------------------------------------------------------
my $VERSION='1.0';
my $FILE_CONF='/cfg/onm.conf';

#-------------------------------------------------------------------------------------------
my $rCFG=conf_base($FILE_CONF);
my $conf_path=$rCFG->{'conf_path'}->[0];
my $txml_path=$rCFG->{'txml_path'}->[0];
my $app_path=$rCFG->{'app_path'}->[0];
my $dev_path=$rCFG->{'dev_path'}->[0];
my $store_path=$rCFG->{'store_path'}->[0];

my $db_server=$rCFG->{db_server}->[0];
my $db_name=$rCFG->{db_name}->[0];
my $db_user=$rCFG->{db_user}->[0];
my $db_pwd=$rCFG->{db_pwd}->[0];

my $store=Crawler::Store->new(db_server=>$db_server,db_name=>$db_name,db_user=>$db_user,db_pwd=>$db_pwd);
$store->store_path($store_path);


#-----------------------------------------------------------------
my %OPTS = ();
GetOptions (\%OPTS, 'in=s','help','man','get','set','v','noquery','name=s','ip=s','c=s','mode=s') or pod2usage(-exitval => 2, -input => \*DATA);;
if ($OPTS{'man'}) { pod2usage(-exitval => 2, -input => \*DATA); }
if ($OPTS{'help'}) { pod2usage(-exitval => 2, -input => \*DATA); }

my %RRD = ('file'=>'/opt/data/rrd/elements/0000000001/udp_pkts_TEST-H2.rrd', 'mode'=>'GAUGE', 'lapse'=>60, 'type'=>'H2_VIEW');
my @DATA = (

	'1530568800:10:10', #select unix_timestamp ('2018-07-03 00:00:00');
	'1530568860:10:10',
	'1530568920:10:10',
	'1530568980:10:10',
	'1530569040:10:10',
	'1530576240:20:20',
	'1530576300:20:20',
	'1530576360:20:20',
	#'1530569100:10:1',
#	'1530569400:10:1',
#	'1530569700:10:1',
#	'1530570000:10:1',
);

foreach my $data (@DATA) {

   my @vector=split(/\:/,$data);
   my $items=(scalar @vector) - 1;
   my $t=$vector[0];

   if (! -e $RRD{'file'}) {  
		$store->create_rrd($RRD{'file'},$items,$RRD{'mode'},$RRD{'lapse'},$t,$RRD{'type'}); 
	}

   $store->update_rrd($RRD{'file'},$data);
}


__DATA__
#-----------------------------------------------------------------------
=head1 NAME

dmap - Mapea dispositivos en sistema gestor

=head1 SYNOPSIS

dmap [options] 

Options:
	
-set    Inserta/Actualiza dispositivos
		
-in     Fichero con los dispositivos
        Formato: Nombre,IP,txml,cat,[ubicacion,descripcion,oid]

-del    Elimina dispositivos definidos
-get    Obtiene dispositivos definidos

-help   Mensaje de ayuda
-man    Documentacion completa

=head1 OPTIONS

help   Mensaje de ayuda
set    Inserta/Actualiza dispositivos


=over 8


=back

=head1 DESCRIPTION

  B<This program> will read the given input file(s) and do someting
  useful with the contents thereof.

=cut


