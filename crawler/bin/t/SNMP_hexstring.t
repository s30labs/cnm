#!/usr/bin/perl -w
#------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
use Test::More tests => 10;
use Crawler::SNMP;

#------------------------------------------------------------------------------
my $snmp=Crawler::SNMP->new();

#IP-MIB::ipNetToPhysicalPhysAddress.2.ipv4."10.2.254.72" = STRING: ee:8b:81:ad:82:c

#$txt="00: 0C: 29: DC: A5: C1 ";
#my $newtxt=$snmp->hex2ascii($txt);

my $txt='0:c:29:dc:a5:c1';
ok( $snmp->hex2ascii($txt) eq $txt, "hex2ascii($txt)");

$txt='00: 0C: 29: DC: A5: C1 ';
ok( $snmp->hex2ascii($txt) eq $txt, "hex2ascii($txt)");

$txt='00 0C 29 DC A5 C1 ';
ok( $snmp->hex2ascii($txt) eq $txt, "hex2ascii($txt)");

#ok( $snmp->hex2ascii('00 0C 29 DC A5 C1 ') eq '0:c:29:dc:a5:c1');
#ok( $snmp->hex2ascii('iii') eq '0:c:29:dc:a5:c1');


#sub hex2ascii2 {
#my ($self,$data)=@_;
#
#   if ($data !~ /(\w{2}\s{1}){4}/) { return $data;}
#   $data =~ s/\"//g;
#   $data =~ s/^(.*)\s+00\s*$/$1 2E/g;
#   my @l=split(/\s+/,$data);
#
#   #El ultimo valor suele estar mal en w2k
##  pop @l;
#
#   my $newdata=pack("C*",map(hex,@l));
#   return $newdata;
#
#}
#
