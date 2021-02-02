#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use lib "/opt/crawler/bin/support";
use strict;

#-------------------------------------------------------------------------------------------
my %CHECKS = (
#/store/log2/crawler_debug.log.20190416-13:Apr 16 12:51:50 cnm-areas [crawler-app.8000.app.300][14069]: do_task::EXCEPTION (dbh=>DBI::db) Wide character in subroutine entry at /opt/crawler/bin/Crawler/Store.pm line 9460.
#Se arregla con encode_utf8 antes de md5_hex

	'check-00001' => {'cmd'=>'grep "EXCEPTION (dbh=>DBI::db)" /var/log/crawler_debug.log', 'txt'=>'md5 error with rx mail'},

);
#-------------------------------------------------------------------------------------------
my $file_res = '/tmp/improve.out';
print "Details in $file_res ...\n";
open (F, ">$file_res");
foreach my $l (sort keys %CHECKS) {
	my $cmd = $CHECKS{$l}->{'cmd'};
	print "$l\t";
	my @lines = `$cmd`;
	my $num_errors = scalar(@lines);
	print "$num_errors errors\n";
	if ($num_errors>0) {
		foreach my $x (@lines) {
			print F  "$x";
		}
	}
}
close F;
