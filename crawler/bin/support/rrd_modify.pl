#!/usr/bin/perl -w
#use Date::Manip;

#
# This simple script scans a directory of RRD files and changes the data
# type from $fromtype to $totype
#
# It writes the changes to $output_dir after making a backup in $backup_dir
# 

my $data_element = "/opt/data/rrd/elements/";
my $restore_cmd = "/opt/rrdtool/bin/rrdtool restore";
my $parse_cmd = "/opt/rrdtool/bin/rrdtool dump";

my $fromtype = "COUNTER";
my $totype = "DERIVE";



opendir(DD,$data_element);
my @directories=readdir(DD);
closedir DD;
foreach $directorio (@directories){
	if (($directorio eq ".")or($directorio eq "..")){next};
	my $data_dir=$data_element.$directorio;
	foreach $rrd (`ls -1 $data_dir`)
	{
		my $maxctr = 0;
	
		chop $rrd;
		print "Transformando $data_dir/$rrd:\n";
	
		open (OUTFILE, ">/tmp/$rrd.xml");
		open (PARSE, "$parse_cmd $data_dir/$rrd |");
	
		while (<PARSE>){
			my $newline = $_;
			if ( $newline =~ /$fromtype/ ){
				$newline =~ s/$fromtype/$totype/g;
			}
			print OUTFILE "$newline";
		}
	
		close PARSE;
		close OUTFILE;
	
		`mv $data_dir/$rrd /tmp`;
		`$restore_cmd /tmp/$rrd.xml $data_dir/$rrd`;
		`rm -f /tmp/$rrd.xml`;
	}
}
exit 0;



