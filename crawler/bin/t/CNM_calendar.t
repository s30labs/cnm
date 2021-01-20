#!/usr/bin/perl -w
use lib "/opt/crawler/bin";
use strict;
use Data::Dumper;
use JSON;
use Crawler;

#-----------------------------------------------------------------------------------------
my $log_level = 'debug';
my $log_mode = 2; # 2 => stdout

#-----------------------------------------------------------------------------------------
my $crawler = Crawler->new(log_level=>$log_level, log_mode=>$log_mode);
my $FILE_CALENDAR = $ARGV[0] || '/opt/cnm/crawler/bin/t/calendar.json';
my $jconf = $crawler->slurp_file($FILE_CALENDAR);
my $json = JSON->new();
my $CAL = $json->decode($jconf);

#print Dumper($CAL);

my $inrange = $crawler->check_calendar($CAL->{'maintenance'});
print "INRANGE=$inrange\n";

#-----------------------------------------------------------------------------------------
#     {"name":"inmonth-12", "month":"12", "mday":"1,28", "hhmm_start":"18h0m", "hhmm_end":"19h0m" },
#
#     {"name":"inday-year-0", "month_start":"1", "month_end":"1", "mday_start":"2", "mday_end":"2", "hhmm_start":"18h0m", "hhmm_end":"19h0m" },
#     {"name":"inday-day_period-1", "hhmm_start":"02h00m", "hhmm_end":"06h00m", "weekday":"*" },
#     {"name":"inday-2", "hhmm_start":"19h00m", "hhmm_end":"20h00m", "weekday":"TUE,WED,THU,FRY,SAT" },
#     {"name":"inday-3", "hhmm_start":"17h45m", "hhmm_end":"18h45m", "weekday":"SUN" },


