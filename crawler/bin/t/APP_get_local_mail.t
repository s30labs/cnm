#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# test_store1
#-------------------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
use Getopt::Long;
use Data::Dumper;
use ONMConfig;
use Crawler;
use Crawler::LogManager::App::Email;

#-------------------------------------------------------------------------------------------
my $FILE_MSG=$ARGV[0] || '';
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

#-------------------------------------------------------------------------------------------
my $RANGE='8000';
#-------------------------------------------------------------------------------------------
my $app_from_email = Crawler::LogManager::App::Email->new(log_level=>'info');

my $file_runner = $app_from_email->config_path();
my $x=$app_from_email->get_json_config($file_runner);
#print Dumper($x);
# $runner es el array de runner em /cfg/crawler-app-runner.json
my $runner = $x->[0]->{'runner'};
#print Dumper($runner);

my @tasks=();
my @tasks_cfg=();

foreach my $h (@$runner) {
	if ($h->{'range'} ne $RANGE) { next; }

   # Itera sobre las tareas de cada runner
   foreach my $k (keys %{$h->{'tasks'}}) {
	
      if (! -f $h->{'tasks'}->{$k}->{'cfg'}) {
         print "NO EXISTE FICHERO $h->{'tasks'}->{$k}->{'cfg'}\n";
         next;
      }

      print "CFG FILE: $h->{'tasks'}->{$k}->{'cfg'}\n";
      my $x=$app_from_email->get_json_config($h->{'tasks'}->{$k}->{'cfg'});
#print Dumper($x);

      push @tasks, $x->[0];
      push @tasks_cfg, $h->{'tasks'}->{$k}->{'cfg'};
   }
}

$app_from_email->tasks(\@tasks);
$app_from_email->tasks_cfg(\@tasks_cfg);

foreach my $app (@tasks) {

	print Dumper($app);

   $app_from_email->app($app);
  	my $lines = $app_from_email->test_msg_flow($tasks_cfg[0],$FILE_MSG);

	print Dumper($lines);
}

#         my $app=Crawler::LogManager::App->new( store => $store, dbh => $dbh, store_path=>$spath, data_path=>$dpath, range=>$range, log_level=>$log_level, 'cfg'=>$cfg, 'config_path'=>$file_runner, 'app'=>$h, 'daemon'=>$x );

#$app_from_email->save_mail(1);
#$data = $app_from_email->core_imap_get_app_data($task_cfg_file);

