#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# CNM_base_exec_script.t
#-------------------------------------------------------------------------------------------
use strict;
use lib '/opt/cnm/crawler/bin';
use Getopt::Long;
use Data::Dumper;
use JSON;
use IO::CaptureOutput qw/capture/;

my ($stdout,$stderr,$rc)=('','',0);
my $cmd='/opt/cnm-areas/scripts/app-get-certificate-data.pl -cfg /cfg/crawler-app/app-333333001043-certificate-data.json';
capture sub { $rc=system($cmd); } => \$stdout, \$stderr;
print "$stdout\n";
print '='x80,"\n";
print "$stderr\n";
