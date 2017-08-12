#######################################################################################################
# Fichero: MCNM.pm
########################################################################################################
package MCNM;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;
use libSQL;
use JSON;
use LWP::Curl;
use Data::Dumper;

@EXPORT_OK = qw(set_cfg_cnms store_key mcnm_session_keepalive);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#-------------------------------------------------------------------------------------------
%MCNM::DB = (
        DRIVERNAME => "mysql",
        SERVER => "localhost",
        PORT => 3306,
        USER => "onm",
        PASSWORD => '',
        TABLE => '',
);

#-------------------------------------------------------------------------------------------
# Actualiza la tabla set_cfg_cnms
#-------------------------------------------------------------------------------------------
sub set_cfg_cnms  {
my ($ip)=@_;

	if ($ip !~ /\d+\.\d+\.\d+\.+/) {
		print "[ **ERROR** ] set_cfg_cnms >> host_ip no tiene formato valido\n";
		return;
	}

	$MCNM::DB{'DATABASE'}='cnm';
	$MCNM::DB{'PASSWORD'} = get_db_credentials();

	my $dbh=sqlConnect(\%MCNM::DB);

	if (defined $dbh) {

		my $txt=`/usr/bin/php /opt/cnm/update/db/update/update_scheme_ip.php ip=$ip`;
		print "$txt\n";

		my %data=();
		$data{'host_ip'}=$ip;
   	my $rv=sqlUpdate($dbh,'cfg_cnms',\%data,'hidx=1');

		$dbh->disconnect();
		print "[ DONE ] set_cfg_cnms >> host_ip=$ip\n";
	}
	else { print "[ **ERROR** ] set_cfg_cnms >> host_ip=$ip\n"; }
}

#-------------------------------------------------------------------------------------------
# Almacena key
#-------------------------------------------------------------------------------------------
sub store_key {
my ($key)=@_;

	my $file_key='/cfg/key';

   if ((defined $key) && ($key =~ /\w{4}\.\w{4}\.\w{4}\.\w{4}\.\w{4}\.\w{4}\.\w{4}\.\w{4}/)) {
      open (F,">$file_key");
      print F $key."\n";
      close F;
	}


	if ((!defined $key) || ($key eq '')) {
		if (! -f $file_key) { $key = ''; }
		else {
			open (F,"<$file_key");
			$key=<F>;
			close F;
			chomp $key;
		}
	}

   $MCNM::DB{'DATABASE'}='onm';
	$MCNM::DB{'PASSWORD'} = get_db_credentials();

   my $dbh=sqlConnect(\%MCNM::DB);

   if (defined $dbh) {
		my %data=('type'=>'cfgkey');
		$data{'value'}=$key;
		$data{'date_store'}=time();
		my $rv=sqlInsertUpdate4x($dbh,'cnm_services',\%data,\%data,0); 

      $dbh->disconnect();
      print "[ DONE ] store_key >> key=$key\n";
   }
   else { print "[ **ERROR** ] store_key >> key=$key\n"; }
}

#----------------------------------------------------------------------------
# get_db_credentials
#----------------------------------------------------------------------------
sub get_db_credentials {

   my $file='/cfg/onm.conf';
   my $pwd='';
   open (F,"<$file");
   while (<F>) {

      chomp;
      if (/^#/) {next;}

      if (/\bDB_PWD\s*\=\s*(.*)$/) {
         $pwd=$1;
         last;
      }
   }
   return $pwd;
}




#-------------------------------------------------------------------------------------------
# Actualiza las sesiones de un dominio MCNM
#Datos que hay en BBDD en la tabla sessions_table:
#mysql> select SID,expiration,multi from sessions_table\G
#*************************** 2. row ***************************
#SID: cb85393a91a2ef501ac9e7df0ad6ab66
#expiration: 1375413619
#multi:
#[{"cid_ip":"178.33.211.248","cid":"default","hidx":15},{"cid_ip":"1.1.1.1","
#cid":"default","hidx":16}]
#
#SID: cb85393a91a2ef501ac9e7df0ad6ab55
#expiration: 1375413600
#multi:
#[{"cid_ip":"178.33.211.248","cid":"default","hidx":15},{"cid_ip":"1.1.1.1","
#cid":"default","hidx":16}]
#
#Para el tema del keepalive, se debe hacer una peticióomo la siguiente:
#
#https://178.33.211.248/onm/login.php?PHPSESSID=cb85393a91a2ef501ac9e7df0ad6a
#b66&accion=keepalive&sessid=[{"sid":"cb85393a91a2ef501ac9e7df0ad6ab66","expi
#ration":"1375413619"},{"sid":"cb85393a91a2ef501ac9e7df0ad6ab55","expiration"
#:"1375413600"}]
#
#Y otra así
#https://1.1.1.1/onm/login.php?PHPSESSID=cb85393a91a2ef501ac9e7df0ad6ab66&acc
#ion=keepalive&sessid=[{"sid":"cb85393a91a2ef501ac9e7df0ad6ab66","expiration"
#:"1375413619"},{"sid":"cb85393a91a2ef501ac9e7df0ad6ab55","expiration":"13754
#13600"}]
#
#
#Los datos son:
#- ip del servidor: sale de los campos cid_ip del array que hay en el campo multi de la BBDD
#- PHPSESSID: es el campo SID de la BBDD
#- campo json sessid: contiene los SIDs que vayan a actualizarse y los expirations
#
#mysql> desc sessions_table;
#+------------+----------------+------+-----+---------+-------+
#| Field      | Type           | Null | Key | Default | Extra |
#+------------+----------------+------+-----+---------+-------+
#| SID        | varchar(32)    | NO   | PRI |         |       |
#| expiration | int(11)        | YES  |     | 0       |       |
#| value      | text           | YES  |     | NULL    |       |
#| user       | varchar(50)    | YES  |     | NULL    |       |
#| multi      | varchar(16000) | NO   |     |         |       |
#+------------+----------------+------+-----+---------+-------+
#
#mysql> select hidx,cid,host_ip from cnm.cfg_cnms;
#+------+---------+------------------------+
#| hidx | cid     | host_ip                |
#+------+---------+------------------------+
#|    1 | default | 10.2.254.222           |
#|   15 | default | 178.33.211.248         |
#|    6 | default | 10.2.254.221           |
#|   16 | default | bucraa.dyndns.org:4443 |
#+------+---------+------------------------+
#4 rows in set (0.00 sec)
#
#
#-------------------------------------------------------------------------------------------
sub mcnm_session_keepalive  {
my ($ip)=@_;

   $MCNM::DB{'DATABASE'}='onm';
   $MCNM::DB{'PASSWORD'} = get_db_credentials();

   my $dbh=sqlConnect(\%MCNM::DB);

   if (! defined $dbh) {
		print "mcnm_session_keepalive :: [ **ERROR** ] EN CONEXION A BBDD\n";
		return;
	}


	my %remote_cnms=();
	my %remote_sid=();
  	my $rres=sqlSelectAll($dbh,'SID,expiration,multi','sessions_table');
  	foreach my $r (@$rres) {
		my ($sid,$expiration,$multi)=($r->[0],$r->[1],$r->[2]);

		# En multi estan los datos de los remotos que forman el dominio (cid_ip,cid,hidx)
		# '[{"cid_ip":"178.33.211.248","cid":"default","hidx":15},{"cid_ip":"1.1.1.1","cid":"default","hidx":16}]';

		if ($multi eq '') { next; }
		my $cnms = [];

		eval {
			$cnms=decode_json($multi);
			#print Dumper($cnms);
		};
		if ($@) {
			print "mcnm_session_keepalive :: [ **ERROR** ] EN DECODE de -$multi- ($@)\n";
		}
		my $lifetime = $expiration - time();

		foreach my $r (@$cnms) {

			my $cid_ip=$r->{'cid_ip'};
			if (! exists $remote_cnms{$cid_ip}) { $remote_cnms{$cid_ip}=[]; }
			push @{$remote_cnms{$cid_ip}}, {'sid'=>$sid, 'lifetime'=>$lifetime};
			$remote_sid{$cid_ip}=$sid;
		}				
#https://178.33.211.248/onm/login.php?PHPSESSID=cb85393a91a2ef501ac9e7df0ad6ab66&accion=keepalive&sessid=[{"sid":"cb85393a91a2ef501ac9e7df0ad6ab66","expiration":"1375413619"},{"sid":"cb85393a91a2ef501ac9e7df0ad6ab55","lifetime":"600"}]
	}


   $dbh->disconnect();

  	my $lwpcurl = LWP::Curl->new( timeout=> 3 );
	foreach my $ip (keys %remote_cnms) {
		my $sessid=encode_json($remote_cnms{$ip});
		my $url='https://'.$ip.'/onm/mod_login.php?PHPSESSID='.$remote_sid{$ip}.'&accion=keepalive&sessid='.$sessid;

   	my ($referer,$content,$status,$rc,$rcstr)=(undef,'','200 OK',0,0);
   	eval {
      	$content = $lwpcurl->get($url, $referer);
			print "url=$url\nres=$content\n";
   	};
   	if ($@) { print "mcnm_session_keepalive :: [ **ERROR** ] EN GET url=$url ($@)\n"; }

	}

}

1;
__END__

