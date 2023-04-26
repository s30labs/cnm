#!/usr/bin/perl -w
#-------------------------------------------------------------------------------------------
# test_store1
#-------------------------------------------------------------------------------------------
use lib "/opt/crawler/bin";
use strict;
use Getopt::Long;
use Data::Dumper;
use ONMConfig;
use Crawler::Store;
use libSQL;

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
my $id_dev = $ARGV[0] || 14;
# Local prototype
#check_dyn_names_wins($store,$dbh);
$store->check_dyn_names_wins($dbh);

#-------------------------------------------------------------------------------------------
$store->close_db($dbh);


#-------------------------------------------------------------------------------------------
# Para provisionar en bloque:
# 1. Se dan de alta desde un CSV en provision (con los atributos necesarios y su IP actual)
# 2. Se transforman en dinamicos con dyn=2 (dyn=0->Static|dyn=1->dns dyn|dyn=2->wins dyn)
sub check_dyn_names_wins {
my ($self,$dbh) = @_;

print "**LOCAL***\n";
   my $file_dyn_names='/cfg/names.dyn.wins';
	my $file_cfg_wins='/cfg/onm.wins';

	my @hosts=();
	my %host2ip=();
   my $db_dyn_stored=$self->get_device($dbh,{'dyn'=>2},'id_dev,name,ip');

	if (scalar(@$db_dyn_stored)==0) { return; }

   open (F,">$file_dyn_names");
   foreach my $x (@$db_dyn_stored) {
		push @hosts, $x->[1];
		$host2ip{$x->[1]} = $x->[2];
		print F join (';', $x->[1], $x->[2])."\n";
   }
   close F;

	if (! -f $file_cfg_wins) {
		$self->log('error',"check_dyn_names_wins:: Can't access file $file_cfg_wins");
		return;
	}

	my $wins_server = '';
	open (F, "<$file_cfg_wins");
	while (<F>) {
		chomp;
		$wins_server = $_;
	}
	close F;

	if ($wins_server eq '') {
      $self->log('error',"check_dyn_names_wins:: Bad data in file $file_cfg_wins");
      return;
   }

	my $all_names = join (' ', @hosts);
	my $cmd = "nmblookup -U $wins_server -R $all_names | grep -v $wins_server";
	my @res = `$cmd`;
	my @changes = (); # ip,name
	foreach my $l (@res) {
		chomp $l;
		#1.1.1.1 PCHOST1<00>
		if ($l !~ /(\d+\.\d+\.\d+\.\d+) (\w+)\<00\>/) { next; }
		my ($new_ip,$name) = ($1,$2);
		if ($host2ip{$name} eq $new_ip) { next; }

		$self->log('info',"check_dyn_names_wins:: Host $name changed IP to $new_ip");
		push @changes, [$new_ip,$name];
	}


	if (scalar(@changes)>0) {
		my $sql="UPDATE devices SET ip=? WHERE name=? AND dyn=2";
   	my $rv=sqlCmd_fast($dbh,\@changes,$sql);
		if ($libSQL::err) {
			$self->log('error',"check_dyn_names_wins:: Error updating devices [$libSQL::err] >> $libSQL::errstr ");
		}
	}

}
