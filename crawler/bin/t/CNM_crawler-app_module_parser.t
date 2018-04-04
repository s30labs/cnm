#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use lib "/cfg/modules";
use strict;
use Getopt::Std;
use ONMConfig;
use Crawler;
use Crawler::LogManager::App;
use Data::Dumper;


	my $crawler=Crawler::LogManager::App->new('log_level' => 'debug');
	my $apps=$crawler->get_json_config('/cfg/crawler-app');

	foreach my $app (@$apps) {

		$crawler->app($app);
print Dumper($app);

		my @input = ('1234');

		#custom_parser($app,\@input);


		my $lines = $crawler->appParse(\@input);
		my $module_parser = $app->{'parser'};

#      eval {
#         $crawler->log('info',"appParse:: $module_parser");
#         (my $file = $module_parser) =~ s|::|/|g;
#         require $file . '.pm';
#         $module_parser->import();
#      };
#      if ($@) {
#         $crawler->log('warning',"appParse:: **ERROR** al cargar module_parser ($module_parser)");
#      }
#      else {
#         my $lines = custom_parser($app,\@input);
#      }
#
#
	}
