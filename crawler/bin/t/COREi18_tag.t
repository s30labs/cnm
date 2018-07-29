#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# test_store1
#-------------------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
use Getopt::Long;
use Data::Dumper;
use ONMConfig;
use Crawler::Store;

#-------------------------------------------------------------------------------------------
my $VERSION='1.0';
#-------------------------------------------------------------------------------------------
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
my $dbh=$store->open_db();

#-------------------------------------------------------------------------------------------
my $tag='_docdevicesummary';
my $tag_value = $store->core_i18n_tag($tag);
print "$tag\t$tag_value\n";

#-------------------------------------------------------------------------------------------
$store->close_db($dbh);

