#!/usr/bin/perl -w

# wget http://standards.iee.org/develop/regauth/oui/oui.txt

#  00-00-00   (hex)      XEROX CORPORATION
#  000000     (base 16)     XEROX CORPORATION

my $HEADER='package IEEEData;
%IEEEData::MAC_TABLE = (
';
my $FOOTER='
);


1;
__END__
';

#    '192.168.13.65:25001' => "SSORO021-OIE",



my $forig='/opt/custom_pro/conf/oui/oui.txt';
open (F, "<$forig");

print "$HEADER\n";
while (<F>) {
   chomp;
   if ($_=~/^\s*(\w{2}\-\w{2}\-\w{2})\s+\(hex\)\s+(.*)$/) {
      my ($mac,$info)=($1,$2);
      $mac=~s/\-/\:/g;
      $info=~s/'/ /g;
      print "\t'$mac' => '$info',\n";
      #print "$1\t$2\n";
      #print "$_\n";
   }
}
print "$FOOTER\n";
close F;

