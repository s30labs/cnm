#!/usr/bin/perl -w
use strict;
use Time::Local;

my $ts = time();
#my $cmd = 'docker ps -a --format "{{.ID}};{{.CreatedAt}};{{.Names}};{{.Image}};{{.Status}}"';
my $filter = 'status=created';
my $cmd = "docker ps -a -f $filter --format '{{.ID}};{{.CreatedAt}};{{.Names}};{{.Image}};{{.Status}}'";
my @lines = `$cmd`;
foreach my $l (@lines) {
	chomp $l;
	my ($cid,$created,$name,$image,$status_raw) = split(';', $l);
	#1732d144a038    2023-04-20 16:51:21 +0200 CEST  crawler.6016.920        impacket:debian-11.3-slim       Up Less than a second
	my $tcreated=$ts;
	if ($created=~/(\d{4})-(\d{2})-(\d{2}) (\d{2})\:(\d{2})\:(\d{2})/) {
		my ($year,$mon,$mday,$hour,$min,$sec) = ($1,$2,$3,$4,$5,$6);
		$year -= 1900;
		$mon -= 1;
		$tcreated = timelocal( $sec, $min, $hour, $mday, $mon, $year );
	}

	my $lapse_created = $ts - $tcreated;
	print "$l ($lapse_created sec.)\n";

	my $pid = `docker inspect -f '{{.State.Pid}}' $cid`;
	chomp $pid;

	my $res = `ps -xaf | grep $pid`;

	print "$pid\n$res\n";
}

