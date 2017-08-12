#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# get_proxy_data
#-------------------------------------------------------------------------------------------
use strict;
use Getopt::Std;
use libSQL;
use Data::Dumper;
#-------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------

# Informacion ------------------------------------------------------
my @fpth = split ('/',$0,10);
my @fname = split ('\.',$fpth[$#fpth],10);
my $VERSION="1.0";
my $USAGE = <<USAGE;
Demonio recolector de datos. $VERSION
(c) fml

$fpth[$#fpth] -d	: Fija el nivel de depuracion 
$fpth[$#fpth] -h	: Ayuda
$fpth[$#fpth] -i	: Inicializa Registro
$fpth[$#fpth] -l	: Lista informacion
$fpth[$#fpth] -s	: Start all
$fpth[$#fpth] -s -c 1	: Start crawler 1
$fpth[$#fpth] -k	: Kill all
$fpth[$#fpth] -k -c 1	: Kill crawler 1
$fpth[$#fpth] -r	: Restart all
$fpth[$#fpth] -r -c 1	: Restart crawler 1

USAGE

#-------------------------------------------------------------------------------------------
my %opts=();
getopts("hilskrc:d:",\%opts);
#my $range = (defined $opts{c}) ? $opts{c} : 0;
#my $log_level= (defined $opts{d}) ? $opts{d} : 'info';
#
#my $range= $opts{'c'} || die "Uso: $0 -c id\n";


#-------------------------------------------------------------------------------------------
my %DB = ('DRIVERNAME'=>'SQLite', 'DATABASE'=>'/opt/data/proxy/out/store.db');
my $dbh=sqlConnect(\%DB);

my $table='results001';

my $rres=sqlSelectAll($dbh,'ts,data,rc,rcstr',$table);
foreach my $r (@$rres) {
   my $ts = $r->[0];
   my $data = $r->[1];
   my $rc = $r->[2];
   my $rcstr = $r->[3];

	print "$ts: $data\t($rc)\t($rcstr)\n";
}

my $os = $^O;
    print "Running in: $os\n";

