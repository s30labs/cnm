#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
use Getopt::Std;
use ONMConfig;
use Crawler::Transport;
use Data::Dumper;

#-------------------------------------------------------------------------------------------
my %opts=();
getopts("hvs:p:t:m:f:",\%opts);

if ($opts{h}) { my $USAGE = usage(); die $USAGE;}

#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
my $FILE_CONF='/cfg/onm.conf'; 
my $rcfgbase=conf_base($FILE_CONF);
my $MX=$rcfgbase->{'notif_mx'}->[0];
my $FROM=$rcfgbase->{'notif_from'}->[0];
my $FROM_NAME=$rcfgbase->{'notif_from_name'}->[0];
my $SUBJECT=$rcfgbase->{'notif_subject'}->[0];

if (! exists $opts{t}) { my $USAGE = usage(); die $USAGE; }
my $param_to = $opts{t};
my @DEST_VECTOR=split(/\;/,$param_to);
$SUBJECT = $opts{s} || 'AVISO-CNM';

my $log_level='debug';

my $log_mode=1;
if ($opts{v}) { $log_mode=3; }

#-------------------------------------------------------------------------------------------
my $transport=Crawler::Transport->new('cfg'=>$rcfgbase, log_level=>$log_level, log_mode=>$log_mode);
$transport->init();

my $text = 'CNM :: TEST';
# m -> Mensaje. Puede ser un texto o un fichero.
if ($opts{m}) {
   if (-f $opts{m}) { $text=$transport->slurp_file($opts{m}); }
   else { $text = $opts{m}; }
}
# f -> Fichero adjunto
my %FILES = ('/tmp/test.csv'=>'text/csv');
if ((exists $opts{f}) && (-f $opts{f})) { $FILES{$opts{f}} = 'text/csv'; }

foreach my $to (@DEST_VECTOR) { 
	my $err_num = $transport->tx_email({mxhost=>$MX, from=>$FROM, to=>$to, subject=>$SUBJECT, txt=>$text, 'files'=>\%FILES});
   if ($err_num==0) {
		print "[OK] To:$to\n";
   }
   else {
      my $err_str = $transport->err_str();
		print "[ERROR] To:$to err_num=$err_num rcstr=$err_str\n";
   }
}

#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
sub usage {
   my @fpth = split ('/',$0,10);
   my @fname = split ('\.',$fpth[$#fpth],10);
   my $USAGE = <<USAGE;
Envio de notificaciones

fpth[$#fpth] -h : Ayuda
$fpth[$#fpth] -t to [-s subject]  -m texto  [-v verbose]
$fpth[$#fpth] -t to [-s subject]  -m fichero_con_el_texto  [-v verbose]
$fpth[$#fpth] -t to [-s subject]  -m texto  -f ruta_fichero_adjunto (csv)  [-v verbose]
$fpth[$#fpth] -t pepe\@gmail.com -s 'test de envio' -m "abc ..."

Se puede enviar el mensaje a varios destinatarios se separan por ';'

USAGE

   return $USAGE;

}

