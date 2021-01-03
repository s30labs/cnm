#!/usr/bin/perl
use strict;

my $mname = $ARGV[0];

my ($version,$found)=('',0);

eval "require $mname";
if ($@) { $found=0; print STDERR "ERROR $@\n"; }
else {

   eval {
      $found=1;
      if ($mname eq 'Crypt::IDEA') { $version=eval '$IDEA::VERSION'; }
      else {$version=eval '$'.$mname.'::VERSION'; }
#print "****FML***** eval de $ $mname ::VERSION >>>>>> V=$version\n";
   };
   if ($@) {   $version='NO'; }

}

print "MNAME=$mname FOUND=$found version=$version\n";

