#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# cnm-update-metric-label.pl
#-------------------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
use Getopt::Long;
use Data::Dumper;
use ONMConfig;
use Crawler::Store;

#-------------------------------------------------------------------------------------------
my $FILE_CONF='/cfg/onm.conf';
my $USAGE = "Usage: $0 -file my-file.csv >> Updata c_label field in metrics (id_metric,label,c_label)\n";

#-------------------------------------------------------------------------------------------
my ($HELP,$VERBOSE,$FILE)=(0,0,'');
GetOptions( "help" => \$HELP, "h" => \$HELP, "file=s"=>\$FILE, "v"=>\$VERBOSE)
  or die("$USAGE\n");

if ($HELP) { die("$USAGE\n"); }
if (! -f $FILE) { die("$USAGE\n"); }

#-------------------------------------------------------------------------------------------
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

my $store=Crawler::Store->new(db_server=>$db_server,db_name=>$db_name,db_user=>$db_user,db_pwd=>$db_pwd,log_level=>3,log_mode=>'debug');
$store->store_path($store_path);
my $dbh=$store->open_db();

#-------------------------------------------------------------------------------------------
open (F, "<$FILE");
while (<F>) {
	chomp;
	my ($id_metric, $label, $c_label) = split(';', $_);
	if ($id_metric !~ /^\d+$/) { next; }
	my %data = ('label'=>$label, 'c_label'=>$c_label);

	my $rres = $store->update_db($dbh,'metrics',\%data,"id_metric=$id_metric");

	my $error = $store->error();
	my $errorstr = $store->errorstr();
	my $lastcmd = $store->lastcmd();

	if ($error !=0 ) {
        print "***ERROR*** $error >> $errorstr ($id_metric|$c_label)\n";
	}
	else {
        print "OK >> MODIFICADO $rres DATO >> $id_metric|$c_label\n";
	}
}

#-------------------------------------------------------------------------------------------
$store->close_db($dbh);
