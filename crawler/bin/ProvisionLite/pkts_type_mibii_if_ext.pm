#####################################################################################################
# Fichero: ProvisionLite::pkts_type_mibii_if_ext.pm
# Set Tab=3
#####################################################################################################
package ProvisionLite::pkts_type_mibii_if_ext;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('pkts_type_mibii_if_ext', 'MIB-II-ext', 300, 'TIPO DE TRAFICO EN INTERFAZ', 'pkts ucast in|pkts mucast in|pkts bcast in|pkts ucast out|pkts mcast out|pkts bcast out','.1.3.6.1.2.1.2.2.1.11.IID|.1.3.6.1.2.1.31.1.1.1.2.IID|.1.3.6.1.2.1.31.1.1.1.3.IID|.1.3.6.1.2.1.2.2.1.17.IID|.1.3.6.1.2.1.31.1.1.1.4.IID|.1.3.6.1.2.1.31.1.1.1.5.IID','./support/iid_mibii_if');

#----------------------------------------------------------------------------
sub pkts_type_mibii_if_ext {
my ($device,$snmp,$data_global)=@_;
my %snmpcfg=();


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

   $snmpcfg{'oid'}='ifDescr_ifInUcastPkts_ifInMulticastPkts_ifInBroadcastPkts_ifOutUcastPkts_ifOutMulticastPkts_ifOutBroadcastPkts';
   $snmpcfg{'last'}='ifOutDiscards';
   my $res=$snmp->core_snmp_table(\%snmpcfg);
   #------------------------------------------------------

   if (! defined $res) { return undef; }

	my %mdata=();
   my $metric_label = $data_global->{'label'};
   my $metric_items = $data_global->{'items'};

   for my $l ( @$res ) {

      my ($id,$descr1,$ucastin,$nucastin,$ucastout,$nucastout)=split(':@:',$l);
      my $descr=$snmp->hex2ascii($descr1);

#      $data_global->{'label'}="Tipo de trafico U/B/M en $descr (".$device->{'full_name'}.')' ;
#      $data_global->{'items'}="Pkts unicast IN ($id)|Pkts mucast IN ($id)|Pkts bcast IN ($id)|Pkts unicast OUT ($id)|Pkts mucast OUT ($id)|Pkts bcast OUT ($id)";
      $data_global->{'label'}="$metric_label $descr (".$device->{'full_name'}.')' ;
      #$data_global->{'items'}=$metric_items .' ('.$id.')';
      my @vmiid=();
      my @vmi=split(/\|/,$metric_items);
      foreach my $x (@vmi) { push @vmiid, $x .' ('.$id.')'; }
      $data_global->{'items'}=join('|', @vmiid);

      $data_global->{'name'}=$data_global->{'subtype'}.'-'.$id;
		ProvisionLite::_set_iid_data($id,$data_global,\%mdata);

   }

   return \%mdata;
}



1;
__END__

