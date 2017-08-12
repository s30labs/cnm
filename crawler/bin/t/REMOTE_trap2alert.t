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
use Crawler::LogManager::SNMPTrap;

#-------------------------------------------------------------------------------------------
my $VERSION='1.0';
#-------------------------------------------------------------------------------------------
my $FILE_CONF='/cfg/onm.conf'; 

#-------------------------------------------------------------------------------------------
my $ip=my_ip();
my $rCFG=conf_base($FILE_CONF);
my $conf_path=$rCFG->{'conf_path'}->[0];
my $txml_path=$rCFG->{'txml_path'}->[0];
my $app_path=$rCFG->{'app_path'}->[0];
my $dev_path=$rCFG->{'dev_path'}->[0];
my $store_path=$rCFG->{'store_path'}->[0];
my $data_path=$rCFG->{'data_path'}->[0];

my $db_server=$rCFG->{db_server}->[0];
my $db_name=$rCFG->{db_name}->[0];
my $db_user=$rCFG->{db_user}->[0];
my $db_pwd=$rCFG->{db_pwd}->[0];

my $host_idx=$rCFG->{'host_idx'}->[0];
my $host=$rCFG->{'host_name'}->[0];

my $store=Crawler::Store->new(db_server=>$db_server,db_name=>$db_name,db_user=>$db_user,db_pwd=>$db_pwd);
$store->store_path($store_path);
my $dbh=$store->open_db();
#-------------------------------------------------------------------------------------------
my $log_level='debug';
my $cid='default';
my $trap_manager=Crawler::LogManager::SNMPTrap->new(store_path=>$store_path, host_idx=>$host_idx, host=>$host, cfg=>$rCFG, log_level=>$log_level, data_path=>$data_path, cid=>$cid, cid_ip=>$ip );
$trap_manager->create_store();
$trap_manager->connect();
$trap_manager->check_configuration();

my $trap2alert=$trap_manager->event2alert();
my $trap2alert_patterns=$trap_manager->event2alert_patterns();

#my $ev='IF-MIB::linkUp';
#print "ev=$ev\n";
foreach my $k (sort keys %$trap2alert) {
   foreach my $evc (@{$trap2alert->{$k}}) {
      my ($id, $mode, $descr, $target, $action, $sev) =
         ($evc->{'id_remote_alert'}, $evc->{'mode'},$evc->{'descr'},$evc->{'target'},$evc->{'action'},$evc->{'severity'});
      print "$k (id=$id) [$target] $descr ($mode|$action|$sev)\n";
   }
}


#print Dumper($trap2alert);

#-------------------------------------------------------------------------------------------
$store->close_db($dbh);

