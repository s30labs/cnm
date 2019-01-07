#!/usr/bin/perl -w
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
#use Test::More tests => 10;
use Crawler;
use JSON;
use Data::Dumper;

#------------------------------------------------------------------------------
# MONITORES DEFINIDOS
#------------------------------------------------------------------------------
my %ALERT2EXPR = (
          '951' => [
                     {
                       'descr' => 'Cualquier valor',
                       'expr' => '"Subject":"ASAPRO - ALERT : Error in VTOM',
                       'fx' => 'MATCH',
                       'expr_logic' => 'AND',
                       'v' => 'v1'
                     }
                   ],
          '925' => [
                     {
                       'descr' => 'Cualquier valor',
                       'expr_logic' => 'AND',
                       'fx' => 'MATCH',
                       'v' => 'v1',
                       'expr' => '"CNM_Flag":"SET"'
                     }
                   ],
          '926' => [
                     {
                       'v' => 'v1',
                       'expr' => '"CNM_Flag":"CLR"',
                       'expr_logic' => 'AND',
                       'fx' => 'MATCH',
                       'descr' => 'Linea'
                     }
                   ],

);

#------------------------------------------------------------------------------
# TESTS 'id_remote_alert' => line de test
#------------------------------------------------------------------------------
my %TEST = (
	'951' => '{"Subject":"ASAPRO - ALERT : Error in VTOM - JOFAARBKPLOGQERP - BkpLog2S3Cln_ERP","S1":"","extrafile1":"extrafile1","B1":"JOFAARBKPLOGQERP","From":"elior.com VTOM-PRODUCTION@elior.com","Date":"Mon, 3 Dec 2018 19:21:34 +0000","body":"Email sent because of Application : JOFAARBKPLOGQERP Environment : ASAPRO Step : BkpLog2S3Cln_ERP Description : Copier fichiers log HANAWS S3 + Cleanup suivant strae ELIOR If available, job log is attached. Automatic email - do not answer ","ts":"1543865182"}',

	'925' => '{"CNM_Flag":"SET", "FechaDoc-BEDAT":"20181202", "NumPedido-EBELN":"4500319559", "extrafile2":"<html><a href=user/files/mambo-supply-EKKO-EKPO/4500319559.txt target=&quot;popup&quot;>extrafile2</a></html>"}',

);

#------------------------------------------------------------------------------
my @vdata=();
my $expr_logic='AND';
my $log_level='debug';
my $crawler=Crawler->new('log_level'=>$log_level);

#------------------------------------------------------------------------------
my $id_remote_alert = $ARGV[0] || '925';

#------------------------------------------------------------------------------
my $line = $TEST{$id_remote_alert};
push @vdata,$line;
my $msg_fields;

eval { $msg_fields = decode_json($line); };
if (! $@) {
   foreach my $k (sort keys %$msg_fields) {
      push @vdata, $msg_fields->{$k};
   }
}
else { print "**ERROR EN DECODE JSON** ($@)"; }

my $condition_ok=$crawler->watch_eval_ext($ALERT2EXPR{$id_remote_alert},$expr_logic,\@vdata);
print "RESULTADO=$condition_ok----\n";




#IP-MIB::ipNetToPhysicalPhysAddress.2.ipv4."10.2.254.72" = STRING: ee:8b:81:ad:82:c

#my $txt='0:c:29:dc:a5:c1';
#ok( $snmp->hex2ascii($txt) eq $txt, "hex2ascii($txt)");


