#####################################################################################################
# Fichero: ProvisionLite::pkts_type_mibrmon_if.pm
# Set Tab=3
#####################################################################################################
package ProvisionLite::pkts_type_mibrmon_if;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('pkts_type_mibrmon', 'MIB-RMON', 300, 'TIPO DE TRAFICO EN INTERFAZ', 'pkts totales |pkt broadcast |pkts multicast','.1.3.6.1.2.1.16.1.1.1.5.IID|.1.3.6.1.2.1.16.1.1.1.6.IID|.1.3.6.1.2.1.16.1.1.1.7.IID','./support/iid_mibii_if');


#----------------------------------------------------------------------------
sub pkts_type_mibrmon_if {
my ($device,$snmp,$data_global)=@_;
my %snmpcfg=();
my %idx2descr=();


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

   $snmpcfg{'oid'}='ifDescr_ifType';
   $snmpcfg{'last'}='ifMtu';

   my $res1=$snmp->core_snmp_table(\%snmpcfg);
   #------------------------------------------------------

   if (! defined $res1) { return undef; }
   
   foreach my $v (@$res1) {
      my ($idx,$descr1,$type)=split(':@:',$v);
      my $descr2=$snmp->hex2ascii($descr1);
      $idx2descr{$idx}={ descr=>$descr2, type=>$type };
   }

   #$snmpcfg{oid}='etherStatsIndex_etherStatsPkts_etherStatsBroadcastPkts_etherStatsMulticastPkts';
   $snmpcfg{'oid'}='etherStatsPkts_etherStatsBroadcastPkts_etherStatsMulticastPkts';
   $snmpcfg{'last'}='etherStatsCRCAlignErrors';
	my $res2=$snmp->core_snmp_table(\%snmpcfg);  
 
   if (! defined $res2) { return undef; }

	my %mdata=();
   my $metric_label = $data_global->{'label'};
   my $metric_items = $data_global->{'items'};

	foreach my $l ( @$res2 ) {

      my ($idx,$total,$broadcast,$multicastt)=split(':@:',$l);

		my $type=$idx2descr{$idx}->{'type'};

      if (!defined $idx2descr{$idx}->{'descr'}) {next;}

      my $descr=$idx2descr{$idx}->{'descr'};

#      $data_global->{'label'}="Tipo de trafico RMON en $descr (".$device->{'full_name'}.')' ;
#      $data_global->{'items'}="Pkts Totales ($idx)|Pkts Broadcast ($idx)|Pkts Multicast ($idx)";
      $data_global->{'label'}="$metric_label $descr (".$device->{'full_name'}.')' ;
      #$data_global->{'items'}=$metric_items .' ('.$idx.')';
      my @vmiid=();
      my @vmi=split(/\|/,$metric_items);
      foreach my $x (@vmi) { push @vmiid, $x .' ('.$idx.')'; }
      $data_global->{'items'}=join('|', @vmiid);

      $data_global->{'name'}=$data_global->{'subtype'}.'-'.$idx;
      ProvisionLite::_set_iid_data($idx,$data_global,\%mdata);

   }

   return \%mdata;
}



1;
__END__

