#!/usr/bin/perl -w
use lib "/opt/crawler/bin";
use strict;
use Getopt::Long;
use Net::SMTP;
use Inline::Files;

#------------------------------------------------------------------------------
my $mxhost='localhost';
my $from='cnm-devel@s30labs.com';
my $to='cnmnotifier@cnm.local';
my $mode='set';

#------------------------------------------------------------------------------
my @fpth = split ('/',$0,10);
my @fname = split ('\.',$fpth[$#fpth],10);
my $USAGE = <<USAGE;
REMOTE_send_mail v1.0 (c) s30labs

$fpth[$#fpth] -mx 1.1.1.1 -from cnm-pro\@s30labs.com -set
$fpth[$#fpth] -mx 1.1.1.1 -from cnm-pro\@s30labs.com -clr
$fpth[$#fpth] -help|-h

-mx   : IP|host del CNM al que se envia el correo.
-from : Origen del correo (dispositivo\@dominio)
-set  : Genera alerta de tipo SET
-clr  : Genera alerta de tipo CLR
-help : Ayuda
-h    : Ayuda
USAGE

#------------------------------------------------------------------------------
my %OPTS = ();
GetOptions (\%OPTS,  'h','help','v','verbose','mx=s','from=s','to=s','set','clr')
            or die "$0:[ERROR] en el paso de parametros. Si necesita ayuda ejecute $0 -help\n";

if ( ($OPTS{'help'}) || ($OPTS{'h'}) ) { die $USAGE; }

if ($OPTS{'mx'}) { $mxhost=$OPTS{'mx'}; } 	
if ($OPTS{'from'}) { $from=$OPTS{'from'}; } 	
if ($OPTS{'to'}) { $to=$OPTS{'to'}; } 	
if ($OPTS{'set'}) { $mode='set'; }
elsif ($OPTS{'clr'}) { $mode='clr'; }


my $smtp = Net::SMTP->new($mxhost, Timeout => 60);

if (!defined $smtp) {
   print "tx_email::[ERROR] al crear objeto SMTP $mxhost\n";
   exit;
}

$smtp->mail($from);
print "tx_email::[INFO] SMTP MAIL FROM:$from (RESP: @{[$smtp->code()]}:@{[$smtp->message()]})";
if ($smtp->code() > 500) {
   my $msg=$smtp->message();
   $msg=~s/[\n|\>|\<]/ /g;
   $smtp->quit;
   exit;
}

$smtp->to($to);
print "tx_email::[INFO] SMTP RCPT TO:$to (RESP: @{[$smtp->code()]}:@{[$smtp->message()]})";
if ($smtp->code() > 500) {
   my $msg=$smtp->message();
   $msg=~s/[\n|\>|\<]/ /g;
   $smtp->quit;
   exit;
}

my $file_mime='/opt/crawler/bin/test/mime_sample';
my $mime='';
if ($mode eq 'clr') {
	while (<CLRMSG>) { $mime .= $_; }
}
else {
	while (<SETMSG>) { $mime .= $_; }
}

$mime=~s/xxxxxxxxxx/$from/g;

$smtp->data([$mime]);

print "tx_email::[INFO] SMTP DATA (RESP: @{[$smtp->code()]}:@{[$smtp->message()]})";
if ($smtp->code() > 500) {
   my $msg=$smtp->message();
   $msg=~s/[\n|\>|\<]/ /g;
   print "ERROR DE MTA: @{[$smtp->code()]} ($msg)\n";
   $smtp->quit;
   exit;
}

$smtp->quit;

__SETMSG__
Return-path: <sistemas@s30labs.com>
Envelope-to: sistemas@s30labs.com
Delivery-date: Tue, 23 Mar 2010 17:23:39 +0100
Received: from [188.18.202.158] (helo=adam.es)
   by ks30588.kimsufi.com with smtp (Exim 4.63)
   (envelope-from <sistemas@s30labs.com>)
   id 1Nu6tD-00075g-EM
   for sistemas@s30labs.com; Tue, 23 Mar 2010 17:23:39 +0100
From:  <xxxxxxxxxx>
Subject: Alerta por correo - TEST SET
To: <sistemas@s30labs.com>
MIME-Version: 1.0
Content-Type: text/html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=Content-Type content="text/html; charset=iso-8859-2">
</HEAD>
<BODY>
ESTO ES UNA PRUEBA DE ALERTA
compra tinta, agarrao
</BODY>
</HTML>


__CLRMSG__
Return-path: <sistemas@s30labs.com>
Envelope-to: sistemas@s30labs.com
Delivery-date: Tue, 23 Mar 2010 17:23:39 +0100
Received: from [188.18.202.158] (helo=adam.es)
   by ks30588.kimsufi.com with smtp (Exim 4.63)
   (envelope-from <sistemas@s30labs.com>)
   id 1Nu6tD-00075g-EM
   for sistemas@s30labs.com; Tue, 23 Mar 2010 17:23:39 +0100
From:  <xxxxxxxxxx>
Subject: Alerta por correo - TEST CLR
To: <sistemas@s30labs.com>
MIME-Version: 1.0
Content-Type: text/html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=Content-Type content="text/html; charset=iso-8859-2">
</HEAD>
<BODY>
ESTO ES UNA PRUEBA DE ALERTA POR MAIL
</BODY>
</HTML>

