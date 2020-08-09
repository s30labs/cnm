#!/usr/bin/perl -w
use lib "/opt/crawler/bin";
use strict;
use Data::Dumper;
use JSON;
#use Crawler::Store;
use Crawler;
use Crawler::LogManager::App;
use ONMConfig;

#-----------------------------------------------------------------------------------------
my $log_level = 'info';
my $log_mode = 1; # 2 => stdout
my $FILE_CONF='/cfg/onm.conf';
my $USER='root';
my $GROUP='root';
my $ip=my_ip();
my $cid='default';

#-------------------------------------------------------------------------------------------
my $rCFG=conf_base($FILE_CONF);
my $conf_path=$rCFG->{'conf_path'}->[0];
my $txml_path=$rCFG->{'txml_path'}->[0];
my $app_path=$rCFG->{'app_path'}->[0];
my $dev_path=$rCFG->{'dev_path'}->[0];
my $data_path=$rCFG->{'data_path'}->[0];
my $store_path=$rCFG->{'store_path'}->[0];
my $host_idx=$rCFG->{'host_idx'}->[0];
my $host=$rCFG->{'host_name'}->[0];

my $db_server=$rCFG->{db_server}->[0];
my $db_name=$rCFG->{db_name}->[0];
my $db_user=$rCFG->{db_user}->[0];
my $db_pwd=$rCFG->{db_pwd}->[0];


#-------------------------------------------------------------------------------------------
my $crawler=Crawler::LogManager::App->new(user=>$USER, group=>$GROUP, name=>"crawler-app-runner", store_path=>$store_path, host_idx=>$host_idx, host=>$host, cfg=>$rCFG, log_level=>$log_level, cid=>$cid, cid_ip=>$ip, data_path=>$data_path, 'log_mode'=>$log_mode );

$crawler->config_path('/cfg/crawler-app-runner-all.json');
$crawler->daemon(1);
my $pid=$crawler->run_all();




#my $store=Crawler::Store->new(db_server=>$db_server,db_name=>$db_name,db_user=>$db_user,db_pwd=>$db_pwd,'log_mode'=>$log_mode, 'log_level'=>$log_level);
#$store->store_path($store_path);
#my $dbh=$store->open_db();
##-------------------------------------------------------------------------------------------
###my $file_runner = '/cfg/crawler-app-runner.json';
#if (-f $file_runner){
#   my $x=$store->get_json_config($file_runner);
#   my $runner = $x->[0]->{'runner'};
#   foreach my $h (@$runner) {
#      if ((! exists $h->{'run'}) || ( $h->{'run'} != 1)) { next; }
#      my $range = $h->{'range'};
#      if (! $range) { next; }
#
#		print Dumper($h);
#   }
#}



