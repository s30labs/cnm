#######################################################################################################
# Fichero: Audit.pm $Id$
# Contiene las funciones necesarias para los procesos de auditoria
########################################################################################################
package Audit;
use strict;
use NetAddr::IP;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;
use ONMConfig;

@EXPORT_OK = qw( audit_init audit_general audit_printers validate_range end_tmp_log do_audit);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);
$VERSION = '1.00';

#-------------------------------------------------------------------------------------------
my %DATA_LOG=( clave=>'p', date=>'', status=>0, separador=>'|', data=>'', id=>1 );
my $FILE_CONF='/cfg/onm.conf';
my $CSV_PATH='/var/www/html/onm/files/provision';
my $SEPARATOR='&|&';

#-------------------------------------------------------------------------------------------
my $SCAN_PROG='/usr/local/bin/nmap';
my $SCAN_OPTIONS='-A -T4 -p 21,22,111,135,139,445,35879';
#my $SCAN_OPTIONS='/usr/local/bin/nmap -A -T4 -p 21,22,111,135,139,445,35879  $ip  | grep -e 445 -e Running';
my $HOST_PROG='/usr/bin/host';
my $TIMEOUT_ICMP=1;

my %OID_ENTERPRISES=();
my %OID_INFO=();

my $DMAP='/opt/crawler/bin/dmap';

my $oPING='';
my $oSNMP='';
my $oSTORE='';
my $COMMUNITY='public';
my $SNMP_VERSION=0;
my $TYPE='descubiertos';

#-------------------------------------------------------------------------------------------
# audit_init
#-------------------------------------------------------------------------------------------
sub audit_init {
my ($p,$snmp,$store,$c,$t,$clave)=@_;

	$oPING = $p;
	$oSNMP = $snmp;
	$oSTORE=$store;
	$COMMUNITY=$c;
	$TYPE=$t;
#	$DATA_LOG{'clave'}=$clave;
#	$DATA_LOG{'id'}=1;
}

#-------------------------------------------------------------------------------------------
# do_audit
#-------------------------------------------------------------------------------------------
sub do_audit {
my ($params)=@_;

#file=2007-07-29_00:10.csv;tipo=General;rango=10.1.254.252-254;comunidad=public;version=1
	my ($RC,$RCSTR,$rres);
	
	my $rango = $params->{'rango'};
print "RANGO=$rango\n";
	#----------------------------------------------------------------
	my $ip_range=validate_range($rango);
	if (! defined $ip_range) {
   	$RC=1;
   	$RCSTR="RANGO NO VALIDO ($rango)";
  # 	my %params=(rc=>$RC,rc_str=>$RCSTR,logs=>[$RCSTR], title=>'Auditoria');
		return 1;
	}

	#----------------------------------------------------------------
	$COMMUNITY = (exists $params->{'comunidad'}) ? $params->{'comunidad'} : 'public';
	$SNMP_VERSION = (exists $params->{'version'}) ? $params->{'version'} : 0;
	my $AUDIT_TYPE = (exists $params->{'tipo'}) ? $params->{'tipo'} : 'general';
	my $FILE_CSV = (exists $params->{'file'}) ? $params->{'file'} : 'default.csv';
	my $PATH_TMP='/var/www/html/onm/tmp';

	my $p='';

	#----------------------------------------------------------------
	my $rcfgbase=conf_base($FILE_CONF);
	my $db_server=$rcfgbase->{db_server}->[0];
	my $db_name=$rcfgbase->{db_name}->[0];
	my $db_user=$rcfgbase->{db_user}->[0];
	my $db_pwd=$rcfgbase->{db_pwd}->[0];
	my $HOST=$rcfgbase->{host_name}->[0];
	my $STORE_PATH=$rcfgbase->{store_path}->[0];
	my $snmp=Crawler::SNMP->new( cfg=>$rcfgbase );
	my $store=Crawler::Store->new(store_path=>$STORE_PATH,
  		                           db_server=>$db_server,
      	                        db_name=>$db_name,
         	                     db_user=>$db_user,
            	                  db_pwd=>$db_pwd,
               	               db_debug=>1);

	audit_init($p,$snmp,$store,$COMMUNITY,'descubiertos');

	#----------------------------------------------------------------
	my $dbh=$store->open_db();
	$rres=$store->get_from_db ($dbh,'oid,device','oid_enterprises');
	foreach my $l (@$rres) { $OID_ENTERPRISES{$l->[0]}=$l->[1]; }
	$rres=$store->get_from_db ($dbh,'oid,device','oid_info');
	foreach my $l (@$rres) { $OID_INFO{$l->[0]}=$l->[1]; }
	$store->close_db ($dbh);

	#----------------------------------------------------------------
	#FML Habria que robustecerse contra el caso en que se generen demasiados forks
	# notar que un usuario capullo puede dar muchas veces al boton.

	$SIG{CHLD} = 'IGNORE';
	my $child=fork;
	if ($child==0) {

		my $clave='discover';
   	my $file_pid=$PATH_TMP.'/'.$clave;
   	open (P,">$file_pid");
   	print P $$;
   	close P;

print "file_pid=$file_pid\n";

   	my $res='-';
      my $file_csv=$CSV_PATH.'/'.$FILE_CSV;
      if (-f $file_csv) { unlink $file_csv; }
		if (open (CSV,">>$file_csv")) {

			my $file_ip=$file_csv.'.ip';
			my $header = join ($SEPARATOR, qw(snmp ping ip sysoid sysname dnsname) );
			print CSV "$header\n";
   		foreach my $ip (@$ip_range) {
      		if ( $ip=~s/(\d+\.\d+\.\d+\.\d+)\/32/$1/) {
         		if ($AUDIT_TYPE eq 'general') {  $res=audit_general($ip,*CSV,0);  }
         		elsif ($AUDIT_TYPE eq 'impresoras') {  $res=audit_printers($ip,*CSV,0);  }
					#Almacena el estado de la auditoria
					if ( open (S,">$file_ip") ) {
						print S $ip; 
						close S; 
					}
      		}
   		}
			# Termina el fichero de datos para info del interfaz
			print CSV "EOF\n";
         close CSV;

			# Borra el fichero de estado para informar al interfaz de que ha terminado
			unlink $file_ip;
		}
      else {
     		$oSNMP->log('warning',"audit_general:: ERROR AL ABRIR EL FICHERO: $file_csv ");
      }

   	unlink $file_pid;
		exit;
	}
}

#-------------------------------------------------------------------------------------------
# audit_general
#-------------------------------------------------------------------------------------------
sub audit_general {
my ($ip,$fh,$to_db)=@_;

	my ($dnsname,$sysname,$ping,$uptime,$community,$oid,$oidstr,$snmp_data,$rc,$rcstr,$res) =
		 ('-'    ,'-'     ,'NO' ,0      ,''        ,''  ,'-'     ,'',		,'0', 'OK',  '' );

   #---------------------------------------------------
   $dnsname=`$HOST_PROG $ip`;
   if ($dnsname=~/domain name pointer (\S+)/) { $dnsname=$1;}
   else { $dnsname='NO'; }

	$oSNMP->log('info',"audit_general:: IP=$ip dnsname=$dnsname");
   #---------------------------------------------------
   #my $rc=$oPING->ping($ip, $TIMEOUT_ICMP);
   #if (! $rc) { $ping='NO'; }
	#else { $ping='SI'; }

	#fml PRBLEMAS DE SUID
	$rcstr=`/usr/bin/sudo /bin/ping -c 2 -i 0.5 -w 1 -q $ip`;
	if ($rcstr =~ /rtt min\/avg\/max\/mdev/) { $ping='SI';  }
	else { $ping='NO'; }

	$oSNMP->log('info',"audit_general:: IP=$ip PING=$ping");

   #---------------------------------------------------
   my @C = split(/\,/,$COMMUNITY);
   if (scalar @C == 0) { @C=( 'public' ); }
   foreach my $c (@C) {
      if (! $c) { next; }

		my %snmp_info=();
		#$oSNMP->timeout(1000000);
		if (! $SNMP_VERSION) {
$oSNMP->log('info',"audit_general:: IP=$ip *******>C=$c ---> V=$SNMP_VERSION");
			$SNMP_VERSION=$oSNMP->snmp_get_version($ip,$c,\%snmp_info);
			$sysname=$snmp_info{'sysname'};
		}
		else {
$oSNMP->log('info',"audit_general:: IP=$ip *******>C=$c ---> V=$SNMP_VERSION");
		   $snmp_info{'host_ip'} = $ip;
   		$snmp_info{'community'} = $c;
   		$snmp_info{'version'} = $SNMP_VERSION;

   		#sysDescr_sysObjectID_sysName_sysLocation
   		my ($rc, $rcstr, $res)=$oSNMP->verify_snmp_data(\%snmp_info);
			if ($rc==0) {
	      	foreach my $l (@$res) {
   	      	my @rd=split(':@:', $l);
	   	      #$rdata->{'sysdesc'} = $rd[1];
   	   	   #$rdata->{'sysoid'} = $rd[2];
      	   	$sysname =$rd[3] ;
	         	#$rdata->{'sysloc'} = $rd[4];
   	  		}
      	}
			elsif ($rc==2) { $sysname ='U'; }
			else { $sysname=undef; }
		}
		if ( (defined $sysname) && ($sysname ne 'U') ){ $community=$c; last; }


#		$oSNMP->timeout(1000000);
#      $uptime=$oSNMP->snmp_get_uptime($ip,$c,$SNMP_VERSION);
#      if ($uptime ne 'U') {
#         $sysname=$oSNMP->snmp_get_name($ip,$c,$SNMP_VERSION);
#         if ( (defined $uptime) && ($sysname ne 'U') ){ $community=$c; last; }
#      }


   }
   if (!defined $sysname){ $community=''; }

	$oSNMP->log('info',"audit_general:: IP=$ip C=$community");


	if ( ($dnsname eq 'NO') && ($ping eq 'NO') && ($community eq '') )  { return undef;  }


   if ($community) {
      if ($sysname ne 'U') {
         $oid=$oSNMP->snmp_get_oid($ip,$community,$SNMP_VERSION);
			if (! defined $oid) {
				$oSNMP->log('info',"audit_general:: No definido oid (sysoid)");
				$snmp_data='NO'; 
			}
			else {
	         $oidstr=$oid;
   	      my ($o1,$o2)=split_oid($oid);
      	   if ( $OID_INFO{$oid} ) { $oidstr=$OID_INFO{$oid}; }
         	elsif ( $OID_ENTERPRISES{$o1} ) {
            	$oidstr=$OID_ENTERPRISES{$o1}." ($o2)";
         	}
				$snmp_data="v$SNMP_VERSION C=$community";
			}
      }
      else { 
			$snmp_data='C=DESCONOCIDA'; 
		}
   }
   else { $snmp_data='NO'; }

	#------------------------------------------------------------------
	#my $DATA="$snmp_data;$ping;$ip;$oidstr;$sysname;$dnsname";
	my $DATA= join ($SEPARATOR, ($snmp_data,$ping,$ip,$oidstr,$sysname,$dnsname) );
	print $fh "$DATA\n";
	$oSNMP->log('info',"audit_general:: RES=$DATA");

	# Si hay que almacenar el dato se mete en DB.
   if ( $to_db ) {
      my $name = ($dnsname) ? $dnsname : $sysname ;
      if (! $name) { $name='desconocido'; }
     	#my ($rcstr1,$rcstr2) = set_device_metrics($ip,$name,$TYPE,$oid,$community);


   # -----------------------------------------------------------------------------------------
   	my $dbh=$oSTORE->open_db();
   	my $rres=$oSTORE->get_from_db($dbh,'id_dev','devices',"ip=\'$ip\'");
   	#if ($rres->[0][0]) { return ("YA EXISTE $rres->[0][0]",''); }
   	my $rcfgbase=conf_base($FILE_CONF);

	   my $provision=ProvisionLite->new(log_level=>'debug', log_mode=>3, cfg=>$rcfgbase);
   	$provision->init();
   	$provision->prov_do_set_device_metric({'name'=>$name, 'ip'=>$ip, 'type'=>$TYPE, 'init'=>0});


#      if ($rcstr1 =~ /ID\=(\d+)/) { print "STORE_SI (ID=$1) "; }
#      elsif ($rcstr1 =~ /YA EXISTE (\d+)/) { print "STORE_NO (ID=$1) "; }
#      if ($rcstr2) { print " METRICAS GENERADAS "; }
		print " PROVISIONADO ";
   }

	return $DATA;
}


#-------------------------------------------------------------------------------------------
# audit_printers
#-------------------------------------------------------------------------------------------
my %PRT_OIDS = (

	#HP
	'.1.3.6.1.4.1.11.2.3.9.1' => {

	   'device' => '.1.3.6.1.2.1.25.3.2.1.3.1', # Device Descr HOST-RESOURCES-MIB::hrDeviceDescr.1
   	'lcd' => '.1.3.6.1.2.1.43.16.5.1.2.1.1', # LCD Printer-MIB::prtConsoleDisplayBufferText.1.1
	   'lifec'  => '.1.3.6.1.2.1.43.10.2.1.4.1.1', # Life Count Printer-MIB::prtMarkerLifeCount.1.1
   	'status' => '.1.3.6.1.2.1.25.3.5.1.2.1', # Status HOST-RESOURCES-MIB::hrPrinterDetectedErrorState.1
	},
);

my %HP_PRT=(

	'device' => '.1.3.6.1.2.1.25.3.2.1.3.1', # Device Descr HOST-RESOURCES-MIB::hrDeviceDescr.1
	'lcd' => '.1.3.6.1.2.1.43.16.5.1.2.1.1', # LCD Printer-MIB::prtConsoleDisplayBufferText.1.1
	'lifec'	=> '.1.3.6.1.2.1.43.10.2.1.4.1.1', # Life Count Printer-MIB::prtMarkerLifeCount.1.1
	'status' => '.1.3.6.1.2.1.25.3.5.1.2.1', # Status HOST-RESOURCES-MIB::hrPrinterDetectedErrorState.1
);

#-------------------------------------------------------------------------------------------
sub audit_printers {
my ($ip,$fh,$to_db)=@_;

	my %params=();
   my ($sysname,$ping,$uptime,$community,$oid,$oidstr,$snmp_data) =
       ('-'     ,'NO' ,0     ,''        ,''  ,'-'     ,'' );

   $oSNMP->log('info',"audit_printers:: IP=$ip");
   #---------------------------------------------------
   #fml PRBLEMAS DE SUID
   my $rc=`/usr/bin/sudo /bin/ping -c 2 -i 0.5 -w 1 -q $ip`;
   if ($rc =~ /rtt min\/avg\/max\/mdev/) { $ping='SI';  }
   else { $ping='NO'; }

$oSNMP->log('info',"audit_printers:: IP=$ip PING=$ping");

   #---------------------------------------------------
   my @C = split(/\,/,$COMMUNITY);
   if (scalar @C == 0) { @C=( 'public' ); }
   foreach my $c (@C) {
      if (! $c) { next; }
      $oSNMP->timeout(1000000);
		my $SNMP_VERSION=$oSNMP->snmp_get_version($ip,$c);
		if ($SNMP_VERSION>0) {
			$params{community}=$c;
			last;
		}
   }

	if ($params{community} eq '') { return undef;  }

  	$oid=$oSNMP->snmp_get_oid($ip,$community,$SNMP_VERSION);
	if (! defined $oid) { return undef;  }
	if (! defined $PRT_OIDS{$oid} ) {	return undef; }

	$params{host_ip}=$ip;
	$oSNMP->log('info',"audit_printers:: IP=$ip C=$params{community}");

	my %results=( 'device' =>'-', 'lcd' =>'-', 'lifec'  => '-', 'status' => '-');
	foreach my $item (keys %{$PRT_OIDS{$oid}} ) {

		#$params{'oid'}=$HP_PRT{$item};
		$params{'oid'}=$PRT_OIDS{$oid}->{$item};
		my $r=$oSNMP->core_snmp_get(\%params);
	   my $rc=$oSNMP->err_num();
   	if ($rc == 0) { $results{$item} = $r->[0]; }
   }

#   $DATA_LOG{'data'}="IP=$ip|PING=$ping|DISPOSITIVO=$results{'device'}|ESTADO=$results{'status'}|DISPLAY=$results{'lcd'}|COUNTER=$results{'lifec'}";
#   write_tmp_log(\%DATA_LOG);
#   $oSNMP->log('info',"audit_printers:: $DATA_LOG{'data'}");

#   $DATA_LOG{'id'} += 1;

#print "RES>> $DATA_LOG{'data'}\n";

   # Si hay que almacenar el dato se mete en DB.
   if ( $to_db ) {
      #my $name = ($dnsname) ? $dnsname : $sysname ;
      my $name = $sysname ;
      if (! $name) { $name='desconocido'; }
      #my ($rcstr1,$rcstr2) = set_device_metrics($ip,$name,$TYPE,$oid,$community);


      my $dbh=$oSTORE->open_db();
      my $rres=$oSTORE->get_from_db($dbh,'id_dev','devices',"ip=\'$ip\'");
      #if ($rres->[0][0]) { return ("YA EXISTE $rres->[0][0]",''); }
      my $rcfgbase=conf_base($FILE_CONF);

      my $provision=ProvisionLite->new(log_level=>'debug', log_mode=>3, cfg=>$rcfgbase);
      $provision->init();
      $provision->prov_do_set_device_metric({'name'=>$name, 'ip'=>$ip, 'type'=>$TYPE, 'init'=>0});

#      if ($rcstr1 =~ /ID\=(\d+)/) { print "STORE_SI (ID=$1) "; }
#      elsif ($rcstr1 =~ /YA EXISTE (\d+)/) { print "STORE_NO (ID=$1) "; }
#      if ($rcstr2) { print " METRICAS GENERADAS "; }
      print " PROVISIONADO ";

   }

   return $DATA_LOG{'data'};
}




#-------------------------------------------------------------------------------------------
# validate_range
#-------------------------------------------------------------------------------------------
sub validate_range {
my $r=shift;
my $range=undef;

	#a.b.c.d./r
	if ($r=~/\d+\.\d+\.\d+\.\d+\/\d+/) {
		$range = new NetAddr::IP($r);
	}
	#a.b.c.x-y
   elsif ($r=~/(\d+\.\d+\.\d+)\.(\d+)\-(\d+)/) {
      my $base=$1;
		my $start=$2;
		my $end=$3;
		my @v=();
		for my $i ($start..$end){ push @v, "$base.$i\/32"; }
		$range=\@v;
   }
	#a.b.c.d
	elsif ($r=~/\d+\.\d+\.\d+\.\d+/) {
		$r.='/32'; 
		$range = new NetAddr::IP($r);
	}
	#a.b.c.*
	elsif ($r=~/(\d+\.\d+\.\d+)\.\*/) { 
		$r=$1.'.0/24';
		$range = new NetAddr::IP($r);
	}
	#a.b.*.*
	elsif ($r=~/(\d+\.\d+)\.\*\.\*/) { 
		$r=$1.'.0.0/16'; 
		$range = new NetAddr::IP($r);
	}
	#a.*.*.*
	elsif ($r=~/(\d+)\.\*\.\*\.\*/) { 
		$r=$1.'.0.0.0/8'; 
		$range = new NetAddr::IP($r);
	}
	return $range;

}

#-------------------------------------------------------------------------------------------
# split_oid
#-------------------------------------------------------------------------------------------
sub split_oid {
my $oid=shift;

   if ($oid=~/(\.1\.3\.6\.1\.4\.1\.\d+)(.*)/) { return ($1,$2); }
	else { return undef; }
}

#-------------------------------------------------------------------------------------------
# write_tmp_log
#-------------------------------------------------------------------------------------------
sub write_tmp_log {
my $data=shift;

   # -----------------------------------------------------------------------------------------
	#mysql> desc tmp_log;
	#+-----------+-------------+------+-----+---------+----------------+
	#| Field     | Type        | Null | Key | Default | Extra          |
	#+-----------+-------------+------+-----+---------+----------------+
	#| clave     | varchar(20) |      |     |         |                |
	#| date      | int(11)     |      |     | 0       |                |
	#| id        | int(11)     |      | PRI | NULL    | auto_increment |
	#| status    | int(1)      |      |     | 0       |                |
	##| separador | char(1)     |      |     |         |                |
	#| data      | text        | YES  |     | NULL    |                |
	#+-----------+-------------+------+-----+---------+----------------+

   my $dbh=$oSTORE->open_db();
	my $table='tmp_log';
	if (! $data->{'date'}) { $data->{'date'}=time; }
	if (! $data->{'clave'}) { $data->{'clave'}='key'; }
	if (! $data->{'status'}) { $data->{'status'}=0; }
	if (! $data->{'separador'}) { $data->{'separador'}='|'; }
	$data->{'pid'}=$$;
	$oSTORE->insert_to_db ($dbh,$table,$data);

}

#-------------------------------------------------------------------------------------------
# end_tmp_log
#-------------------------------------------------------------------------------------------
sub end_tmp_log {
my $clave=shift;

   my $dbh=$oSTORE->open_db();
   my $table='tmp_log';
   $DATA_LOG{'date'}=time;
   #$DATA_LOG{'data'}='';
	$DATA_LOG{'clave'}=$clave;
	$DATA_LOG{'status'}=1;
	$DATA_LOG{'pid'}=$$;
   $oSTORE->insert_to_db ($dbh,$table,\%DATA_LOG);
}

##-------------------------------------------------------------------------------------------
## set_device_metrics
##-------------------------------------------------------------------------------------------
#sub set_device_metrics {
#my ($ip,$name,$type,$oid,$community)=@_;
#my ($rc1,$rc2);
#
#
#   # -----------------------------------------------------------------------------------------
#   my $dbh=$oSTORE->open_db();
#	my $rres=$oSTORE->get_from_db($dbh,'id_dev','devices',"ip=\'$ip\'");
#	if ($rres->[0][0]) { return ("YA EXISTE $rres->[0][0]",''); }
#	my $rcfgbase=conf_base($FILE_CONF);
#	my $log_level='debug';
#	my $log_mode=3;
#
#	my $provision=ProvisionLite->new(log_level=>$log_level, log_mode=>$log_mode, cfg=>$rcfgbase);
#	$provision->init();
#	$provision->prov_do_set_device_metric({'name'=>$name, 'ip'=>$ip, 'type'=>$type, 'init'=>0});
#
#
#	#my $id=`$DMAP -get -ip=$ip -values=id_dev`;
#	#if ($id =~ /GET\:\s*\d+/) { return ("YA EXISTE $id",''); }
#
#	if ($community) {	
#		$rc1=`$DMAP -v -set -ip=$ip -name=$name -type=$type`;
#	}
#	#else {
#   #   $rc1=`$DMAP -v -set -ip=$ip -name=$name -type=$type -oid=$oid -c=$community`;
#   #}
#
#	$rc2='';	
#	#if ($name eq 'U' ) { return ($rc1,$rc2); }
#
#	if ($community) {
#		$rc2=`$DMAP -v -set -metric -txmlgen -ip=$ip -c=$community`; 
#	}
#	else { $rc2=`$DMAP -v -set -metric -txmlgen -ip=$ip`; }
#
#	return ($rc1,$rc2);
#
#}


1;
__END__
