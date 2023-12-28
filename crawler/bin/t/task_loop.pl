#!/usr/bin/perl -w
use strict;
use warnings;

my %PIDS=();
my $current=0;
my $total_checks=0;
my $total_forks=0;
my $max_tasks=36;
while(<STDIN>){
	chomp;

	#Jul  1 21:08:31 cnmprd02 [notificationsd.010.notificationsd.60][79729]: task_loop:: ===>> START_CH_ACTIVE PID=85589 [12|106] 1|12|36 (/opt/crawler/bin/Crawler/Notifications.pm 3518
	if ($_=~/START_CH_ACTIVE PID=(\d+)/) {  	

		if (! exists ($PIDS{$1})) { 
			$PIDS{$1} = {'checks'=>1, 'start'=>1, 'end'=>0} ; 
		}
		else {
			$PIDS{$1}->{'start'} = 1;
			$PIDS{$1}->{'checks'} += 1;
		}
	}
	#Jul  1 21:08:42 cnmprd02 [notificationsd.010.notificationsd.60][79729]: task_loop:: END_CHECK PID=85570 KEY=2089.mon_snmp DONE=105 done_current=11 current_tasks=12 (/opt/crawler/bin/Crawler/Notifications.pm 3561)
	elsif ($_=~/END_CHECK PID=(\d+)/) {
		$PIDS{$1}->{'end'} = 1;
	}

}
foreach my $pid (sort keys %PIDS) { 
	my $start = $PIDS{$pid}->{'start'};
	my $checks = $PIDS{$pid}->{'checks'};
	my $end = $PIDS{$pid}->{'end'};
	$current += $checks;
	$total_checks += $checks;
	$total_forks += 1;
	print "$pid\t$start | $end | $checks\n"; 
	if ($current >= $max_tasks) {
		print "------------------ $current gte $max_tasks\n";
		$current=0;
	}
}

print "TOTAL FORKS = $total_forks | TOTAL CHECKS = $total_checks\n";
