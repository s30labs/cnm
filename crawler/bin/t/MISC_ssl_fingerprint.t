#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# t/MISC_ssl_fingerprint.t
#-------------------------------------------------------------------------------------------
use strict;
use warnings;
use IO::Socket::SSL 1.980;
use LWP::UserAgent;

#my $dst = 'bad-cert.example.com';
my $dst = $ARGV[0] || die "Uso: $0 host:port\n";

my $cl = IO::Socket::SSL->new(
    PeerAddr => $dst,
    PeerPort => 443,
    # certificate cannot be validated the normal way, so we need to
    # disable validation this one time in the hope that there is
    # currently no man in the middle attack
    SSL_verify_mode => 0,
) or die "connect failed";
my $fp = $cl->get_fingerprint;
print "fingerprint: $fp\n";

my $ua = LWP::UserAgent->new(ssl_opts => { SSL_fingerprint => $fp });
my $resp = $ua->get("https://$dst");
print $resp->code,"\n";

