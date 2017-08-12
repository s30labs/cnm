#!/usr/bin/perl -w
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
#use Test::More tests => 10;
use Crawler::SNMP;

#------------------------------------------------------------------------------
my $log_level='debug';
#my $expr='v1 contains(picor)';
my $expr='INT(o1)';
my @values=('+3.5 mWat',1);
my $file='0000000002/mib2_ent_phy_parts-STD.rrd';
my $crawler=Crawler->new('log_level'=>$log_level);


my ($condition,$lval,$oper,$rval)=$crawler->watch_eval($expr,\@values,$file,{});

print "RESULTADO=$condition\t$lval $oper $rval\n";



#IP-MIB::ipNetToPhysicalPhysAddress.2.ipv4."10.2.254.72" = STRING: ee:8b:81:ad:82:c

#my $txt='0:c:29:dc:a5:c1';
#ok( $snmp->hex2ascii($txt) eq $txt, "hex2ascii($txt)");


