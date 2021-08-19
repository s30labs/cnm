#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# fix_log_views.pl
#-------------------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
use Getopt::Long;
use Data::Dumper;
use ONMConfig;
use Crawler::Store;

#-------------------------------------------------------------------------------------------
my $VERSION='1.0';
#-------------------------------------------------------------------------------------------
my $FILE_CONF='/cfg/onm.conf';

#-------------------------------------------------------------------------------------------
my $rCFG=conf_base($FILE_CONF);
my $conf_path=$rCFG->{'conf_path'}->[0];
my $txml_path=$rCFG->{'txml_path'}->[0];
my $app_path=$rCFG->{'app_path'}->[0];
my $dev_path=$rCFG->{'dev_path'}->[0];
my $store_path=$rCFG->{'store_path'}->[0];

my $db_server=$rCFG->{db_server}->[0];
my $db_name=$rCFG->{db_name}->[0];
my $db_user=$rCFG->{db_user}->[0];
my $db_pwd=$rCFG->{db_pwd}->[0];

my $store=Crawler::Store->new(db_server=>$db_server,db_name=>$db_name,db_user=>$db_user,db_pwd=>$db_pwd);
$store->store_path($store_path);
my $dbh=$store->open_db();
#-------------------------------------------------------------------------------------------
my $SQL_CREATE = "CREATE VIEW v__TABLE__ AS SELECT id_log,hash,ts,line,'__LOGFILE__' as logfile,__ID_DEV2LOG__ as id_device2log,'__NAME__' as name,__ID_DEV__ as id_dev FROM __TABLE__";

my $sql='SELECT l.id_device2log,l.id_dev,l.logfile,l.tabname,d.name,l.last_access FROM devices d, device2log l WHERE d.id_dev=l.id_dev ORDER BY l.tabname';
my $rres=$store->get_from_db_cmd($dbh,$sql,'');
foreach my $r (@$rres) {
        #CREATE VIEW vlogr_010200010024_syslog_filters AS SELECT id_log,hash,ts,line,'syslog-filters' as logfile,7 as id_device2log,'an_cmv_pipl' as name,515 as id_dev FROM logr_010200010024_syslog_filters;
        my ($id_device2log, $id_dev, $logfile,$tabname,$name,$last_access) = ($r->[0], $r->[1], $r->[2], $r->[3], $r->[4], $r->[5]);

        my $create = $SQL_CREATE;
        $create=~s/__TABLE__/$tabname/g;
        $create=~s/__LOGFILE__/$logfile/g;
        $create=~s/__ID_DEV2LOG__/$id_device2log/g;
        $create=~s/__NAME__/$name/g;
        $create=~s/__ID_DEV__/$id_dev/g;
        print "$create\n";

   my $sql1="SHOW tables LIKE '$tabname'";
   my $rres1=$store->get_from_db_cmd($dbh,$sql1,'');
        if (! exists $rres1->[0][0]) {
                print "****NO EXISTE $tabname-----\n";
                next;
        }

        if ($last_access==0) {
      print "****SE DEBE BORRAR $id_device2log-----\n";
      next;
   }

        #print Dumper ($rres1),"\n";
        $store->db_cmd($dbh,$create);

}
#-------------------------------------------------------------------------------------------
$store->close_db($dbh);


