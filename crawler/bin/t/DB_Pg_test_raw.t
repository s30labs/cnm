#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# DB_Pg_test.t
#-------------------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
use Getopt::Long;
use Data::Dumper;
use ONMConfig;
use Crawler::Store;
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
my $driver  = "Pg"; 
my $database = "metrics";
my $dsn = "DBI:$driver:dbname = $database;host = $host;port = $port";
my $userid = "postgres";
my $password = "cnmManag3r";
my $dbh = DBI->connect($dsn, $userid, $password, { RaiseError => 1 }) 
   or die $DBI::errstr;

print "Opened database successfully ($dsn)\n";


#-------------------------------------------------------------------------------------------
# CREATE TABLE
#-------------------------------------------------------------------------------------------
if ($OPTS{'create'}) {
	my $stmt = qq(CREATE TABLE metrics4 (
  		time        TIMESTAMP       NOT NULL,
  		mname       TEXT              NOT NULL,
  		v1 	DOUBLE PRECISION  NULL,
  		v2 	DOUBLE PRECISION  NULL,
  		v3 	DOUBLE PRECISION  NULL,
  		v4 	DOUBLE PRECISION  NULL
	););
	my $rv = $dbh->do($stmt);
	if($rv < 0) {
   	print $DBI::errstr;
	} else {
   	print "Table created successfully\n";
	}

	$stmt = qq(SELECT create_hypertable('metrics4', 'time'););

	$rv = $dbh->do($stmt);
	if($rv < 0) {
   	print $DBI::errstr;
	} else {
   	print "Hypertable created successfully\n";
	}

}


#-------------------------------------------------------------------------------------------
# SELECT
#-------------------------------------------------------------------------------------------
if ($OPTS{'select'}) {

	my $stmt = qq(SELECT time,mname,v1,v2,v3,v4  from metrics4;);
	my $sth = $dbh->prepare( $stmt );
	my $rv = $sth->execute() or die $DBI::errstr;
	if($rv < 0) {
   	print $DBI::errstr;
	}
	while(my @row = $sth->fetchrow_array()) {
      print "TIME = ". $row[0] . "\n";
      print "MNAME = ". $row[1] ."\n";
      print "v1 = ". $row[2] ."\n";
      print "v2 =  ". $row[3] ."\n\n";
      print "v3 =  ". $row[4] ."\n\n";
      print "v4 =  ". $row[5] ."\n\n";
	}
	print "Operation done successfully\n";

}

#-------------------------------------------------------------------------------------------
# INSERT
#-------------------------------------------------------------------------------------------
if ($OPTS{'insert'}) {

	my $ts = time;
	#1999-01-08 04:05:06
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($ts);
	$year += 1900;
	$mon += 1;
	my $data_time = sprintf("%04d-%02d-%02d %02d:%02d:%02d",$year,$mon,$mday,$hour,$min,$sec);
	my $subtype = 'test_metric';
	my $v1=int(100*rand);
	my $v2=int(100*rand);
	my $v3=int(100*rand);
	my $v4=int(100*rand);


	my $stmt = qq(INSERT INTO metrics4 (time,mname,v1,v2,v3,v4)
   VALUES ('$data_time', '$subtype', $v1,$v2,$v3,$v4));
	my $rv = $dbh->do($stmt) or die $DBI::errstr;

	print "OK insert -> $data_time,$subtype,$v1,$v2,$v3,$v4\n";
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

