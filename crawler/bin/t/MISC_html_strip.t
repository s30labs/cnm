#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# test_store1
#-------------------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
use Data::Dumper;
use Crawler;
use HTML::Strip;

my $file_html=$ARGV[0] || '/tmp/kk.html';
#-------------------------------------------------------------------------------------------
my $crawler=Crawler->new();
my $raw_html = $crawler->slurp_file($file_html);

my $hs = HTML::Strip->new();
my $clean_text = $hs->parse( $raw_html );
$hs->eof;

print "$clean_text\n";


