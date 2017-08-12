#####################################################################################################
# Fichero: ProvisionLite::pkts_discard_mibii_if.pm
# Set Tab=3
#####################################################################################################
package ProvisionLite::pkts_discard_mibii_if;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('pkts_discard_mibii_if', 'MIB-II', 300, 'PAQUETES DESCARTADOS EN INTERFAZ', 'pkts descartados in|pkts descartados out','.1.3.6.1.2.1.2.2.1.13.IID|.1.3.6.1.2.1.2.2.1.19.IID','./support/iid_mibii_if');

#----------------------------------------------------------------------------
sub pkts_discard_mibii_if {
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
   $snmpcfg{'oid'}='ifDescr_ifType_ifInDiscards_ifOutDiscards';
   $snmpcfg{'last'}='ifOutErrors';

   my $res=$snmp->core_snmp_table(\%snmpcfg);
   #------------------------------------------------------

   if (! defined $res) { return undef; }

	my %mdata=();
   my $metric_label = $data_global->{'label'};
   my $metric_items = $data_global->{'items'};

   for my $l ( @$res ) {

#		my %data=();
      my ($id,$descr1,$type,$discard_in,$discard_out)=split(':@:',$l);
      my $descr=$snmp->hex2ascii($descr1);

#      $data{'label'}="Paquetes descartados en $descr (".$device->{'full_name'}.')' ;
#      $data{'items'}="Pkts descartados IN ($id)|Pkts descartados OUT ($id)";
#      $data{'oid'}=$data_global->{'oid'};
#      $data{'oid'}=~s/IID/$id/g;
#      $data{'name'}=$data_global->{'subtype'}.'-'.$id;
#
#      $data{'mtype'}=$data_global->{'mtype'};
#      $data{'vlabel'}=$data_global->{'vlabel'};
#      $data{'mode'}=$data_global->{'mode'};
#      $data{'top_value'}=$data_global->{'top_value'};
#      $data{'get_iid'}=$data_global->{'get_iid'};
#      $data{'module'}=$data_global->{'module'};
#		$data{'iid'}=$id;
#      push (@mdata, \%data);



#      $data_global->{'label'}="Paquetes descartados en $descr (".$device->{'full_name'}.')' ;
#      $data_global->{'items'}="Pkts descartados IN ($id)|Pkts descartados OUT ($id)";
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

