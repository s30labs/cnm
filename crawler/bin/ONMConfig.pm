#######################################################################################################
# Fichero: ONMConfig.pm  $Id: ONMConfig.pm,v 1.3 2004/10/04 10:38:21 fml Exp $
# Revision: Ver $VERSION
# Descripcion:
########################################################################################################
package ONMConfig;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;

@EXPORT_OK = qw(%CFG $FILE_CONF conf_base get_role_info set_role_info get_env_from_file find_file my_ip get_rrd_path check_version my_ip my_if is_lxc);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);
$VERSION = '1.00';

#--------------------------------------------------------------------------
$ONMConfig::FILE_CONF='/cfg/onm.conf'; 

#--------------------------------------------------------------------------
my %CFG = (

	'txml_path' => ['/opt/crawler/conf/'],
	'conf_path' => ['/opt/crawler/conf/'],
	'xml_path' => ['/opt/crawler/conf/txml/'],
	'app_path' => ['/opt/crawler/conf/apps/'],
	'dev_path' => ['/opt/crawler/conf/devices/'],
	'store_path' => [],
	'data_path' => [],

	'host_idx' => ['0'],
	'host_ip' => ['127.0.0.1'],
	'host_name' => [],
	'host_list' => [],
	'max_idx_per_host' => [],
	'disk' => [],

	'max_60' => ['40'],
	'max_300' => ['400'],
	'max_3600' => ['4000'],
	'max_86400' => ['10000'],

	'real_lapse_300' => ['300'],

   'factor_iid' => ['0.1'],
   'factor_snmp' => ['2'],
   'factor_latency' => ['0.8'],
   'factor_xagent' => ['2'],

	'db_server' => ['localhost'],
	'db_name' => ['onm'],
	'db_user' => ['root'],
	'db_pwd'=> ['root'],

	'mserver'=> ['mserver'],
	'pserver'=> ['pserver'],

	'proc_syslog'=> ['yes'],
	'proc_syslog_cmd'=> ['/etc/init.d/syslog-ng'],
   'proc_www'=> ['yes'],
   'proc_www_cmd'=> ['/etc/init.d/httpd'],
   'proc_db'=> ['yes'],
   'proc_db_cmd'=> ['/etc/init.d/mysqld'],
   'proc_crawler'=> ['yes'],
   'proc_crawler_cmd'=> ['/etc/init.d/crawlerd'],
   'proc_notifications'=> ['yes'],
   'proc_notifications_cmd'=> ['/etc/init.d/notificationsd'],

	'www_server_url' => [],
	'mode_db' => ['0'],
	'mode_rrd' => ['1'],
	'mode_alert' => ['1'],

	'mth_snmp' => ['0'],
	'mth_latency' => ['0'],
	'mth_xagent' => ['0'],

	'notif_lapse' => [],
	'notif_mx' => [],
	'notif_mx_port' => ['25'],
	'notif_mx_tls' => ['0'],
	'notif_mx_auth' => ['0'],
	'notif_mx_auth_user' => [],
	'notif_mx_auth_pwd' => [],
	'notif_from' => [],
	'notif_from_name' => [],
	'notif_subject' => [],

	'notif_serial_port' => [],
	'notif_pin' => [],

);


#-------------------------------------------------------------------------------------------------------
sub conf_base {
my $file=shift;


	open (F,"<$file");
	while (<F>) {

		chomp;
		if (/^#/) {next;}

		# Arquitectura CNM
		if (/\bHOST_IDX\s*\=\s*(.*)$/) {$CFG{'host_idx'}->[0]=$1;}
		if (/\bHOST_IP\s*\=\s*(.*)$/) {$CFG{'host_ip'}->[0]=$1;}
		if (/\bHOST_NAME\s*\=\s*(.*)$/) {$CFG{'host_name'}->[0]=lc $1;}
		if (/\bHOST_TYPE\s*\=\s*(.*)$/) {$CFG{'host_type'}->[0]=lc $1;}    #master/pooler
		if (/\bHOST_LIST\s*\=\s*(.*)$/) {$CFG{'host_list'}->[0]=$1;}
		#if (/\bMAX_IDX_PER_HOST\s*\=\s*(.*)$/) {$CFG{'max_idx_per_host'}->[0]=$1;}
		if (/\bDISK\s*\=\s*(.*)$/) {push @{$CFG{'disk'}}, $1;}

		# Base de Datos
		if (/\bDB_SERVER\s*\=\s*(.*)$/) {$CFG{'db_server'}->[0]=$1;}
		if (/\bDB_NAME\s*\=\s*(.*)$/) {$CFG{'db_name'}->[0]=$1;}
		if (/\bDB_USER\s*\=\s*(.*)$/) {$CFG{'db_user'}->[0]=$1;}
		if (/\bDB_PWD\s*\=\s*(.*)$/) {$CFG{'db_pwd'}->[0]=$1;}

      # mode_flag
      if (/\bMODE_DB\s*\=\s*(.*)$/) {$CFG{'mode_db'}->[0]=$1;}
      if (/\bMODE_RRD\s*\=\s*(.*)$/) {$CFG{'mode_rrd'}->[0]=$1;}
      if (/\bMODE_ALERT\s*\=\s*(.*)$/) {$CFG{'mode_alert'}->[0]=$1;}

		# Thread mode 
      if (/\bMTH_SNMP\s*\=\s*(.*)$/) {$CFG{'mth_snmp'}->[0]=$1;}
      if (/\bMTH_LATENCY\s*\=\s*(.*)$/) {$CFG{'mth_latency'}->[0]=$1;}
      if (/\bMTH_XAGENT\s*\=\s*(.*)$/) {$CFG{'mth_xagent'}->[0]=$1;}

		# Entorno distribuido
		if (/\bMSERVER\s*\=\s*(.*)$/) {
         my $values=$1;
         my @v=split(/\;/,$values);
         $CFG{'mserver'}=\@v;
      }

      if (/\bBSERVER\s*\=\s*(.*)$/) {
         my $values=$1;
         my @v=split(/\;/,$values);
         $CFG{'bserver'}=\@v;
      }

		if (/\bPSERVER\s*\=\s*(.*)$/) {
         my $values=$1;
         my @v=split(/\;/,$values);
         $CFG{'pserver'}=\@v;
      }

		# Ajuste de crawlers
		# Ojo primero lomas restrictivo por el match de caracteres.
      if (/\bMAX_60_SNMP\s*\=\s*(.*)$/) {$CFG{'max_60_snmp'}->[0]=$1;}
      if (/\bMAX_300_SNMP\s*\=\s*(.*)$/) {$CFG{'max_300_snmp'}->[0]=$1;}
      if (/\bMAX_3600_SNMP\s*\=\s*(.*)$/) {$CFG{'max_3600_snmp'}->[0]=$1;}
      if (/\bMAX_86400_SNMP\s*\=\s*(.*)$/) {$CFG{'max_86400_snmp'}->[0]=$1;}

      if (/\bMAX_60_LATENCY\s*\=\s*(.*)$/) {$CFG{'max_60_latency'}->[0]=$1;}
      if (/\bMAX_300_LATENCY\s*\=\s*(.*)$/) {$CFG{'max_300_latency'}->[0]=$1;}
      if (/\bMAX_3600_LATENCY\s*\=\s*(.*)$/) {$CFG{'max_3600_latency'}->[0]=$1;}
      if (/\bMAX_86400_LATENCY\s*\=\s*(.*)$/) {$CFG{'max_86400_latency'}->[0]=$1;}

      if (/\bMAX_60_WBEM\s*\=\s*(.*)$/) {$CFG{'max_60_wbem'}->[0]=$1;}
      if (/\bMAX_300_WBEM\s*\=\s*(.*)$/) {$CFG{'max_300_wbem'}->[0]=$1;}
      if (/\bMAX_3600_WBEM\s*\=\s*(.*)$/) {$CFG{'max_3600_wbem'}->[0]=$1;}
      if (/\bMAX_86400_WBEM\s*\=\s*(.*)$/) {$CFG{'max_86400_wbem'}->[0]=$1;}

      if (/\bMAX_60_XAGENT\s*\=\s*(.*)$/) {$CFG{'max_60_xagent'}->[0]=$1;}
      if (/\bMAX_300_XAGENT\s*\=\s*(.*)$/) {$CFG{'max_300_xagent'}->[0]=$1;}
      if (/\bMAX_3600_XAGENT\s*\=\s*(.*)$/) {$CFG{'max_3600_xagent'}->[0]=$1;}
      if (/\bMAX_86400_XAGENT\s*\=\s*(.*)$/) {$CFG{'max_86400_xagent'}->[0]=$1;}

      if (/\bMAX_60\s*\=\s*(.*)$/) {$CFG{'max_60'}->[0]=$1;}
      if (/\bMAX_300\s*\=\s*(.*)$/) {$CFG{'max_300'}->[0]=$1;}
      if (/\bMAX_3600\s*\=\s*(.*)$/) {$CFG{'max_3600'}->[0]=$1;}
      if (/\bMAX_86400\s*\=\s*(.*)$/) {$CFG{'max_86400'}->[0]=$1;}

      if (/\bREAL_LAPSE_300\s*\=\s*(.*)$/) {$CFG{'real_lapse_300'}->[0]=$1;}

      if (/\bFACTOR_IID\s*\=\s*(.*)$/) {$CFG{'factor_iid'}->[0]=$1;}
      if (/\bFACTOR_SNMP\s*\=\s*(.*)$/) {$CFG{'factor_snmp'}->[0]=$1;}
      if (/\bFACTOR_LATENCY\s*\=\s*(.*)$/) {$CFG{'factor_latency'}->[0]=$1;}
      if (/\bFACTOR_XAGENT\s*\=\s*(.*)$/) {$CFG{'factor_xagent'}->[0]=$1;}

		if (/\bMAX_CRAWLERS\s*\=\s*(.*)$/) {$CFG{'max_crawlers'}->[0]=$1;}

		if (/\bMAX_DEVICES_PER_FILE\s*\=\s*(.*)$/) {$CFG{'max_devices_per_file'}->[0]=$1;}
	

		# Rutas de archivos	
		if (/\bDEV_PATH\s*\=\s*(.*)$/) {
			my $p=$1;
			if ($p !~ /.*?\//) {$p .= '/'; }
			$CFG{'dev_path'}->[0]=$p;
		}
		if (/\bXML_PATH\s*\=\s*(.*)$/) {
			my $p=$1;
			if ($p !~ /.*?\//) {$p .= '/'; }
			$CFG{'xml_path'}->[0]=$p;
		}
		if (/\bTXML_PATH\s*\=\s*(.*)$/) {
			my $p=$1;
			if ($p !~ /.*?\//) {$p .= '/'; }
			$CFG{'txml_path'}->[0]=$p;
		}
		if (/\bSTORE_PATH\s*\=\s*(.*)$/) {
			my $p=$1;
			if ($p !~ /.*?\//) {$p .= '/'; }
			$CFG{'store_path'}->[0]=$p;
		}
      if (/\bCONF_PATH\s*\=\s*(.*)$/) {
         my $p=$1;
         if ($p !~ /.*?\//) {$p .= '/'; }
         $CFG{'conf_path'}->[0]=$p;
      }
      if (/\bAPP_PATH\s*\=\s*(.*)$/) {
         my $p=$1;
         if ($p !~ /.*?\//) {$p .= '/'; }
         $CFG{'app_path'}->[0]=$p;
      }
      if (/\bDATA_PATH\s*\=\s*(.*)$/) {
         my $p=$1;
         if ($p !~ /.*?\//) {$p .= '/'; }
         $CFG{'data_path'}->[0]=$p;
      }

		# Parametros de monitores
      #if (/\bRR\s*\=\s*(.*)$/) { $CFG{'rr'}->[0]=$1; }
      #if (/\bUSER_POP3\s*\=\s*(.*)$/) { $CFG{'user_pop3'}->[0]=$1; }
      #if (/\bPWD_POP3\s*\=\s*(.*)$/) { $CFG{'pwd_pop3'}->[0]=$1; }
      #if (/\bUSER_IMAP\s*\=\s*(.*)$/) { $CFG{'user_imap'}->[0]=$1; }
      #if (/\bPWD_IMAP\s*\=\s*(.*)$/) { $CFG{'pwd_imap'}->[0]=$1; }

		# Procesos
		if (/\bPROC_SYSLOG\s*\=\s*(.*)$/) { $CFG{'proc_syslog'}->[0]=$1; }
		if (/\bPROC_SYSLOG_CMD\s*\=\s*(.*)$/) { $CFG{'proc_syslog_cmd'}->[0]=$1; }
      if (/\bPROC_WWW\s*\=\s*(.*)$/) { $CFG{'proc_www'}->[0]=$1; }
      if (/\bPROC_WWW_CMD\s*\=\s*(.*)$/) { $CFG{'proc_www_cmd'}->[0]=$1; }
      if (/\bPROC_DB\s*\=\s*(.*)$/) { $CFG{'proc_db'}->[0]=$1; }
      if (/\bPROC_DB_CMD\s*\=\s*(.*)$/) { $CFG{'proc_db_cmd'}->[0]=$1; }
      if (/\bPROC_CRAWLER\s*\=\s*(.*)$/) { $CFG{'proc_crawler'}->[0]=$1; }
      if (/\bPROC_CRAWLER_CMD\s*\=\s*(.*)$/) { $CFG{'proc_crawler_cmd'}->[0]=$1; }
      if (/\bPROC_NOTIFICATIONS\s*\=\s*(.*)$/) { $CFG{'proc_notifications'}->[0]=$1; }
      if (/\bPROC_NOTIFICATIONS_CMD\s*\=\s*(.*)$/) { $CFG{'proc_notifications_cmd'}->[0]=$1; }
		
		if (/\bWWW_SERVER_URL\s*\=\s*(.*)$/) {
			my $values=$1;
			my @v=split(/\,/,$values);
			$CFG{'www_server_url'}=\@v;
		}

		# Parametros de los avisos
		if (/\bNOTIF_LAPSE\s*\=\s*(.*)$/) {$CFG{'notif_lapse'}->[0]=$1;}
		if (/\bNOTIF_MX\s*\=\s*(.*)$/) {$CFG{'notif_mx'}->[0]=$1;}

		if (/\bNOTIF_MX_PORT\s*\=\s*(.*)$/) {$CFG{'notif_mx_port'}->[0]=$1;}
		if (/\bNOTIF_MX_TLS\s*\=\s*([0|1])$/) {$CFG{'notif_mx_tls'}->[0]=$1;}
		if (/\bNOTIF_MX_AUTH\s*\=\s*([0|1])$/) {$CFG{'notif_mx_auth'}->[0]=$1;}
		if (/\bNOTIF_MX_AUTH_USER\s*\=\s*(.*)$/) {$CFG{'notif_mx_auth_user'}->[0]=$1;}
		if (/\bNOTIF_MX_AUTH_PWD\s*\=\s*(.*)$/) {$CFG{'notif_mx_auth_pwd'}->[0]=$1;}

		if (/\bNOTIF_FROM\s*\=\s*(.*)$/) {$CFG{'notif_from'}->[0]=$1;}
		if (/\bNOTIF_FROM_NAME\s*\=\s*(.*)$/) {$CFG{'notif_from_name'}->[0]=$1;}
		if (/\bNOTIF_SUBJECT\s*\=\s*(.*)$/) {$CFG{'notif_subject'}->[0]=$1;}
		if (/\bNOTIF_SERIAL_PORT\s*\=\s*(.*)$/) {$CFG{'notif_serial_port'}->[0]=$1;}
		if (/\bNOTIF_PIN\s*\=\s*(.*)$/) {$CFG{'notif_pin'}->[0]=$1;}

		if (/\bNOTIF_TG_BOT_TOKEN\s*\=\s*(.*)$/) {$CFG{'notif_tg_bot_token'}->[0]=$1;}
		if (/\bNOTIF_TG_BOT_URL\s*\=\s*(.*)$/) {$CFG{'notif_tg_bot_url'}->[0]=$1;}


      # Parametros del puerto serie
      if (/\bSERIAL_PORT_BAUDRATE\s*\=\s*(.*)$/) {$CFG{'serial_port_baudrate'}->[0]=$1;}
      if (/\bSERIAL_PORT_PARITY\s*\=\s*(.*)$/) {$CFG{'serial_port_parity'}->[0]=$1;}
      if (/\bSERIAL_PORT_DATABITS\s*\=\s*(.*)$/) {$CFG{'serial_port_databits'}->[0]=$1;}
      if (/\bSERIAL_PORT_STOPBITS\s*\=\s*(.*)$/) {$CFG{'serial_port_stopbits'}->[0]=$1;}
      if (/\bSERIAL_PORT_HANDSHAKE\s*\=\s*(.*)$/) {$CFG{'serial_port_handshake'}->[0]=$1;}

		# Parametros del proxy
      if (/\bproxy_host\s*\=\s*(.*)$/) {$CFG{'proxy_host'}->[0]=$1;}
      if (/\bproxy_port\s*\=\s*(.*)$/) {$CFG{'proxy_port'}->[0]=$1;}
      if (/\bproxy_user\s*\=\s*(.*)$/) {$CFG{'proxy_user'}->[0]=$1;}
      if (/\bproxy_passwd\s*\=\s*(.*)$/) {$CFG{'proxy_passwd'}->[0]=$1;}
      if (/\bproxy_enable\s*\=\s*(.*)$/) {$CFG{'proxy_enable'}->[0]=$1;}
	

	}
	close F;

   if (! defined $CFG{'host_name'}) {
   	my $HOST=`/bin/hostname`;
      $HOST=~s/(.*)\n/$1/;
      $CFG{'host_name'}->[0]=lc $HOST;
   }
	return \%CFG;
	#while (my ($k,$v)=each %CFG) {print "$k ";foreach (@$v) {print "$_ ";} print "\n";}

}


#-------------------------------------------------------------------------------------------------------
sub get_env_from_file {
my $file=shift;

   if (! $file) { $file='/cfg/cnm-env.conf'; }
   if (! -f $file) { return; }

   open (F,"<$file");
   while (<F>) {
      chomp;
      if (/^#/) {next;}
      if (/\s*(\S+)\s*\=\s*(.*?)\s*$/) {$ENV{$1}=$2;}
   }
}

#-------------------------------------------------------------------------------------------------------
sub get_role_info {

   my %cfg=();
   my $file_role='/cfg/onm.role';

	if (! -f $file_role) { return \%cfg; }

   open (F,"<$file_role");
   while (<F>) {

      chomp;
      if (/^#/) {next;}
      if (/^\s*(\S+)\s*\=\s*(.*?)\s*$/) { $cfg{$1}=$2; }
   }
	close F;
   return \%cfg;
}

#-------------------------------------------------------------------------------------------------------
#ROLE = passive
#ACTIVE_ADDRESS = 1.1.1.1
#DRBD = yes

sub set_role_info {
my ($role,$active,$drbd)=@_;

   my $file_role='/cfg/onm.role';

   open (F,">$file_role");
	print F "ROLE = $role\n";
	print F "ACTIVE_ADDRESS = $active\n";
	if (! defined $drbd) { $drbd='yes'; }
	print F "DRBD = $drbd\n";
	close F;
}

#-------------------------------------------------------------------------------------------------------
sub find_file {
my ($file,$path)=@_;


   if (-e $file) {return $file;}
   else {
      foreach my $p (@{$path}) {
         my $file_path=$p.$file;
         if (-e $file_path) {return $file_path;}
		}
	}
	return undef;

}

#-------------------------------------------------------------------------------------------------------
sub my_ip {

	my $if=my_if();
	my $os=_os_version();
	my $r=`/sbin/ifconfig $if`;

	my $ip='';
	if ( $os->{'Release'} !~ /10/ ) {
		$r=~/inet\s+addr\:(\d+\.\d+\.\d+\.\d+)\s+/;
		$ip=$1;
	}
	else { 
		$r=~/inet\s+(\d+\.\d+\.\d+\.\d+)\s+/; 
		$ip=$1;
	}

 	return $ip; 
}

#-------------------------------------------------------------------------------------------------------
sub my_if {

   my $if='eth0';
   my $file_if='/cfg/onm.if';

   if (-f $file_if) {
      open (F,"<$file_if");
      $if=<F>;
      chomp $if;
      close F;
   }
   return $if;
}

#----------------------------------------------------------------------------
sub _os_version {

   my %os_info=();
   my @out=`lsb_release -ir`;
   foreach my $l (@out) {
      chomp $l;
      my ($k,$v)=split(/\:\s+/,$l);
      $os_info{$k}=$v;
   }

   return \%os_info;

}

#-------------------------------------------------------------------------------------------------------
sub get_rrd_path {
my ($disk,$host,$host_disks)=@_;


my $fdep="/tmp/depura1";
open (F,">>$fdep");

#	  my @host_disks = grep { /$host/ } @$rcfgdisks;
#	  # host_name:host_idx:disk:path remoto:path montado en master
#	  # host1:0:0:/opt/data/rrd/:/opt/data/rrd/

print F "d=$disk h=$host HD=@$host_disks\n";
	my $rrd_path='/opt/data/rrd/elements/';
	my $ok=0;
	#foreach my $l (@host_disks) {
	foreach my $l (@$host_disks) {

print F "L=$l  ==> $host,$disk\n";


   	my @d=split (':',$l);
	   if (($host eq $d[0]) && ($disk == $d[2])) {
   	   $rrd_path= $d[4];
      	if ($rrd_path !~ /\/$/) { $rrd_path .= '/'; }
	      $rrd_path .= 'elements/';
   	   $ok=1;
      	last;
   	}
	}

close F;
	return $rrd_path;
}

#----------------------------------------------------------------------------
sub is_lxc {

	my $rc=0;
	my $x=`grep 'lxc' /proc/1/cgroup|wc -l`;
	chomp $x;
	if ($x>0) { $rc=1; }
	return $rc;
}

#----------------------------------------------------------------------------
sub check_version {

	my $version=`cd /opt/cnm ; /usr/bin/git describe --tags`;
	chomp $version;

my $LEGEND = <<LEGEND;
-------------------------------------------------------------------------
Custom Network Manager (CNM) version $version.
Copyright (c) 2008-2022 by s30labs. http://www.s30labs.com
This module is part of the CNM Engine and it is released under the GPLv2 license
If you have a commercial subscription, plase check the terms of service before doing any software modification.
-------------------------------------------------------------------------
LEGEND

	return $LEGEND;

}





1;
__END__
