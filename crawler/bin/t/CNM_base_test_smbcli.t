#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# CNM_base_test_smbcli.t
#-------------------------------------------------------------------------------------------
# smbclient -L 1.1.1.1 -U dominio/user
# smbclient -U dominio/user -W '' -I 1.1.1.1 -d 3 -D subdir "//1.1.1.1/SHARE_NAME"
#-------------------------------------------------------------------------------------------
# Needs a JSON config file (/cfg/t/CNM_base_test_smbcli.json) like this:
#{
#   "host001":  {
#      "host" : "1.1.1.1",
#      "user" : "user",
#      "pwd" : "xxxx",
#      "workgroup" : "WWWW",
#      "dir" : [ "SHARE/DIR" ]
#   },
#	{..}
#}
#-------------------------------------------------------------------------------------------
use strict;
use lib '/opt/cnm/crawler/bin';
use Getopt::Long;
use Data::Dumper;
use JSON;
use POSIX;
use File::Basename;
use Filesys::SmbClient;

#------------------------------------------------------------------------------
my @fpth = split ('/',$0,10);
my @fname = split ('\.',$fpth[$#fpth],10);
my $USAGE = <<USAGE;
CNM_base_test_smbcli.t v1.0 (c) s30labs

$fpth[$#fpth] -check host001
$fpth[$#fpth] -help|-h

-check    : Host credentials in file CNM_base_test_smbcli.json
-help|-h  : Help
USAGE

#------------------------------------------------------------------------------
#$dirname=dirname($FILE_RRD_IN);
#my $basename=basename($0,qr{\.t});
#my $basename=basename($0);
my ($filename, $dirs, $suffix) = fileparse($0, qr{\.t});

my $cfg_file = '/cfg/t/'.$filename.'.json';
if (! -f $cfg_file) { 
	die "**ERROR** This program needs $cfg_file\n";
}

#------------------------------------------------------------------------------
my %OPTS = ();
GetOptions (\%OPTS,  'h','help','v','verbose','check=s')
            or die "$0:[ERROR] en el paso de parametros. Si necesita ayuda ejecute $0 -help\n";

if ( ($OPTS{'help'}) || ($OPTS{'h'}) ) { die $USAGE; }
if (! $OPTS{'check'}) { die $USAGE; }

my $json = JSON->new();
my $config = slurp_file($cfg_file);
my $cfg = $json->decode($config);

if (!exists $cfg->{$OPTS{'check'}}) {
	die "**ERROR** $OPTS{'check'} not defined in $cfg_file\n";
}

my $USER = $cfg->{$OPTS{'check'}}->{'user'};
my $PWD = $cfg->{$OPTS{'check'}}->{'pwd'};
my $WORKGROUP = $cfg->{$OPTS{'check'}}->{'workgroup'};
my $HOST = $cfg->{$OPTS{'check'}}->{'host'};
my $DIRS = $cfg->{$OPTS{'check'}}->{'dir'};


print "FILE CONFIG = $cfg_file\tCHECK = $OPTS{'check'}\n";
print Dumper($cfg->{$OPTS{'check'}}),"\n";


my $smb = new Filesys::SmbClient(username=>$USER, password=>$PWD, workgroup=>$WORKGROUP, debug=>1);
print Dumper($smb),"\n";
foreach my $dir (@$DIRS) {

	#my $samba_dir = "smb://$HOST/$dir";
	my $samba_dir = 'smb://'.$HOST.'/'.$dir;
print "DIR=$samba_dir\n";

   my $fd = $smb->opendir($samba_dir);
	if (! $fd) { print "**ERROR** $!\n"; }

#print Dumper($fd),"\n";

   foreach my $item ($smb->readdir($fd)) {

      if (($item eq '.') || ($item eq '..')) { next; }

      my ($size,$tmod,$traw)=('-','-','-');
      my @tab = $smb->stat("smb://$HOST/$dir/$item");
      my $info='';
      if ($#tab == 0) { $info="**ERROR** in stat: ($!)"; }
      else {
         $size = $tab[7];
         $traw = $tab[11];
         $tmod = localtime($tab[11]);
         #for (10..12) {$tab[$_] = localtime($tab[$_]);}
         #$info=join(', ',@tab);
      }

      print "$dir\t$size\t$tmod ($traw)\t$item\n";
   }
   #close($fd);
}

## Read a file
#my $fd = $smb->open("smb://1.1.1.1/doc/general.css", '0666');
#while (defined(my $l= $smb->read($fd,50))) {print $l; }
#$smb->close(fd);

#-------------------------------------------------------------------------------------------
sub slurp_file {
my ($file)=@_;

   local($/) = undef;  # slurp
	open (F,"<$file");
   my $content = <F>;
	$content =~ s/\r//g;
	$content =~ s/\n//g;
   return $content;
}

