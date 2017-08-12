#!/usr/bin/perl -w
#-------------------------------------------------------
# mon_smtp
#-------------------------------------------------------
use lib "/opt/crawler/bin";
use Getopt::Std;
use Monitor;

# Informacion ------------------------------------------------------
my @fpth = split ('/',$0,10);
my @fname = split ('\.',$fpth[$#fpth],10);
my $USAGE = <<USAGE;
(c) fml

$fpth[$#fpth] -h : Ayuda
$fpth[$#fpth] -n host [-p port] : Chequea smtp

USAGE

# Parametros de entrada ---------------------------------------------
my %DESC=();
my %opts=();
getopts("hn:p:",\%opts);

if ($opts{h}) { die $USAGE;}
elsif ($opts{n}) {
        $DESC{host_ip}=$opts{n};
        $DESC{port}=$opts{p};
}
else { die $USAGE;}

#--------------------------------------------------------------------
my $r=mon_smtp(\%DESC);
#foreach (@$r) {
#	print "$_\n";
#}

if ( ($opts{'v'}) || ($opts{'verbose'}) ) {
   if ($DESC{'rc'}) { print "RC=$DESC{rc}\n";  }
   if ($DESC{'rcstr'}) { print "RCSTR=$DESC{rcstr}\n";  }
   if ($DESC{'rcdata'}) { print "RCDATA=$DESC{rcdata}\n";  }
   if ($DESC{'elapsed'}) { print "ELAPSED=$DESC{elapsed}\n";  }
}

my $rc_class='U';
if ($DESC{'rc'} ne 'U') { $rc_class=int ($DESC{'rc'}/100); }


print '<001> Tiempo de respuesta = '.$DESC{elapsed}."\n";
print '<002> Codigo de error = '.$DESC{rc}."\n";
print '<003> Clase de codigo de error = '.$rc_class."\n";

