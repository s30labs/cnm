#####################################################################################################
# Fichero: ProvisionLite::arp_mibii_cnt.pm
# Set Tab=3
#####################################################################################################
package ProvisionLite::arp_mibii_cnt;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
#insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('arp_mibii_cnt', 'MIB-II', 3600, 'VECINOS EN LAN - ARP', 'Entradas en la tabla ARP','ipNetToMediaNetAddress_ipNetToMediaPhysAddress','');


#----------------------------------------------------------------------------
sub arp_mibii_cnt {
my ($device,$snmp,$data_global)=@_;
my %snmpcfg=();

	# El chequeo de la metrica se hace con get_snmp_vector porque es una tabla
   # Los parametros de entrada y la forma de detectar si hay error cambian
	# respecto de check_snmp_oid !!!!!
   #my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);

   #------------------------------------------------------
   $snmpcfg{'host_ip'}=$device->{'ip'};
   $snmpcfg{'community'}=$device->{'community'} || 'public';
   $snmpcfg{'version'}= $device->{'version'} || '1';
   $snmpcfg{'auth_proto'}= $device->{'auth_proto'};
   $snmpcfg{'auth_pass'}= $device->{'auth_pass'};
   $snmpcfg{'priv_proto'}= $device->{'priv_proto'};
   $snmpcfg{'priv_pass'}= $device->{'priv_pass'};
   $snmpcfg{'sec_name'}= $device->{'sec_name'};
   $snmpcfg{'sec_level'}= $device->{'sec_level'};

   $snmpcfg{'oid'}='ipNetToMediaNetAddress_ipNetToMediaPhysAddress';
   $snmpcfg{'last'}='ipNetToMediaType';
   my $res=$snmp->core_snmp_table(\%snmpcfg);
   #------------------------------------------------------

	if (! defined $res) { return undef; }

	my @mdata=();
	my %data=();
   my $metric_label = $data_global->{'label'};
   my $metric_items = $data_global->{'items'};

#   $data{'label'}='Vecinos en LAN ('.$device->{'full_name'}.')' ;
#   $data{'items'}="Entradas en la tabla de ARP";

   $data{'label'}="$metric_label (".$device->{'full_name'}.')' ;
   $data{'items'}=$metric_items;

   $data{'oid'}=$data_global->{'oid'};
   #$data{'oid'}=~s/IID/$id/g;
   $data{'name'}=$data_global->{'subtype'};

   $data{'mtype'}=$data_global->{'mtype'};
   $data{'vlabel'}=$data_global->{'vlabel'};
   $data{'mode'}=$data_global->{'mode'};
   $data{'top_value'}=$data_global->{'top_value'};
   $data{'get_iid'}=$data_global->{'get_iid'};
   $data{'module'}=$data_global->{'module'};
	$data{'iid'}='ALL';
   push (@mdata, \%data);

	return \@mdata;

}

1;
__END__
