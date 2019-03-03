#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# DB_Pg_test.t
#-------------------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
use Getopt::Long;
use Data::Dumper;
use ONMConfig;
use libSQL;
use DBD::Pg;

#------------------------------------------------------------------------------
my @fpth = split ('/',$0,10);
my @fname = split ('\.',$fpth[$#fpth],10);
my $USAGE = <<USAGE;
REMOTE_send_log v1.0 (c) s30labs

$fpth[$#fpth] -create
$fpth[$#fpth] -select
$fpth[$#fpth] -help|-h

-create   : Crea tabla
-select   : Hace SELECT
-help|-h  : Ayuda
USAGE

#-------------------------------------------------------------------------------------------
my %OPTS = ();
GetOptions (\%OPTS,  'h','help','v','verbose','create','select','insert')
            or die "$0:[ERROR] en el paso de parametros. Si necesita ayuda ejecute $0 -help\n";

if ( ($OPTS{'help'}) || ($OPTS{'h'}) ) { die $USAGE; }

#-------------------------------------------------------------------------------------------
my $host = `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' cnm-timescaledb`;
chomp $host;
my $port = 5432;

#-------------------------------------------------------------------------------------------
# CONNECT
#-------------------------------------------------------------------------------------------
my %DB = (
        DRIVERNAME => "Pg",
        SERVER => "localhost",
        PORT => 5432,
        DATABASE => "metrics",
        USER => "postgres",
        PASSWORD => "cnmManag3r",
        TABLE => 'metrics2',
);


my $dbh=sqlConnect(\%DB);

if (! defined $dbh) {die "ERROR no definido $dbh"; }
print "Opened database successfully SERVER=$DB{'SERVER'}:$DB{'PORT'} DATABASE=$DB{'DATABASE'} DBH=$dbh\n";


#-------------------------------------------------------------------------------------------
# CREATE TABLE
#-------------------------------------------------------------------------------------------
if ($OPTS{'create'}) {

   my $fields_create='time TIMESTAMP NOT NULL, id_dev INT NOT NULL, mname TEXT NOT NULL, v1 DOUBLE PRECISION  NULL, v2 DOUBLE PRECISION  NULL';
	my $table = $DB{'TABLE'};
   my $rc = sqlCreate($dbh,$table,$fields_create);

	print "CONNECT >> rc=$rc\n"; 
}


#-------------------------------------------------------------------------------------------
# SELECT
#-------------------------------------------------------------------------------------------
if ($OPTS{'select'}) {

   my $rres=sqlSelectAll($dbh,'time,mname,v1,v2',$DB{'TABLE'});
   foreach my $r (@$rres) {
		foreach my $x (@$r) { print "$x\t"; }
		print "\n";
	}

}

#-------------------------------------------------------------------------------------------
# INSERT
#-------------------------------------------------------------------------------------------
if ($OPTS{'insert'}) {

	my $ts = time;
	my $table = $DB{'table'};	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($ts);
	$year += 1900;
	$mon += 1;
	#1999-01-08 04:05:06
	my %data=();
	$data{'time'} = sprintf("%04d-%02d-%02d %02d:%02d:%02d",$year,$mon,$mday,$hour,$min,$sec);
	$data{'mname'} = 'test_metric';
	$data{'v1'} = int(100*rand);
	$data{'v2'} = int(100*rand);

   my $rv=sqlInsert($dbh,$DB{'TABLE'},\%data);

	print "OK insert -> $data{'time'}, $data{'mname'}, $data{'v1'} $data{'v2'}\n";
}

$dbh->disconnect();

##-------------------------------------------------------------------------------------------
#my $store=Crawler::Store->new(db_server=>$db_server,db_name=>$db_name,db_user=>$db_user,db_pwd=>$db_pwd);
#$store->store_path($store_path);
#my $dbh=$store->open_db();
#
#
##-------------------------------------------------------------------------------------------
#$store->close_db($dbh);

