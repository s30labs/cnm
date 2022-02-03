#!/usr/bin/perl -w
use Authen::SASL;
use Net::SMTP;

my $mxhost = $ARGV[0] || die "Uso: $0 host user pwd\n";
my $user = $ARGV[1] || die "Uso: $0 host user pwd\n";
my $pwd = $ARGV[2] || die "Uso: $0 host user pwd\n";

my $smtp = Net::SMTP->new($mxhost, Timeout => 60);

$smtp->starttls();

      my $ok=$smtp->auth(
         Authen::SASL->new(
            #mechanism => 'PLAIN LOGIN',
            mechanism => 'LOGIN',
            callback  => { user => $user, pass => $pwd }
         )
      );

print "tx_email::[INFO] SMTP AUTH (RESP: @{[$smtp->code()]}:@{[$smtp->message()]})\n";

