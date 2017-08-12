#####################################################################################################
# Fichero: ProvisionLite::traffic_mibii_if_hc.pm
# DESCRIPTION:
#	Obtiene los valores de trafico exclusivamente de los Hig Counters (HC)
# Set Tab=3
#####################################################################################################
package ProvisionLite::traffic_mibii_if_hc;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('traffic_mibii_if_hc', 'MIB-II', 300, 'TRAFICO EN INTERFAZ ', 'Bits RX|Bits TX','.1.3.6.1.2.1.2.2.1.10.IID|.1.3.6.1.2.1.2.2.1.16.IID','./support/iid_mibii_if');
#----------------------------------------------------------------------------
=head1 traffic_mibii_if_hc 

 OIDs: .1.3.6.1.2.1.2.2.1.10.IID/.1.3.6.1.2.1.2.2.1.16.IID
 TIPO: STD_TRAFFIC (bits=bytes*8)
 VALUES: RX | TX
 VLABEL: bits/sg
 DESCR: Numero Total de octetos rx/tx por el interfaz incluyendo cabeceras.

=cut

#ifHCInOctets  .1.3.6.1.2.1.31.1.1.1.6.--METRIC_IID--
#ifHCOutOctets .1.3.6.1.2.1.31.1.1.1.10.--METRIC_IID--
#----------------------------------------------------------------------------
sub traffic_mibii_if_hc {
my ($device,$snmp,$data_global)=@_;
my %snmpcfg=();


	#----------------------------------------------------------
   $snmpcfg{'host_ip'}=$device->{'ip'};
   $snmpcfg{'community'}=$device->{'community'} || 'public';
   $snmpcfg{'version'}= $device->{'version'} || '1';
   $snmpcfg{'auth_proto'}= $device->{'auth_proto'};
   $snmpcfg{'auth_pass'}= $device->{'auth_pass'};
   $snmpcfg{'priv_proto'}= $device->{'priv_proto'};
   $snmpcfg{'priv_pass'}= $device->{'priv_pass'};
   $snmpcfg{'sec_name'}= $device->{'sec_name'};
   $snmpcfg{'sec_level'}= $device->{'sec_level'};

   $snmpcfg{'oid'}='ifDescr_ifType_ifSpeed';
   #OJO!! ifPhysAddress no siempre existe
   $snmpcfg{'last'}='ifAdminStatus';

   $res=$snmp->core_snmp_table(\%snmpcfg);
   #------------------------------------------------------

   if (! defined $res) { return undef; }

	#my @mdata=();
	my %mdata=();
   my $metric_label = $data_global->{'label'};
   my $metric_items = $data_global->{'items'};

	for my $l ( @$res ) {

#		my %data=();
		my ($id,$descr1,$type,$speed)=split(':@:',$l);

		if (exists $IFNAME{$id}) { $descr1 = $IFNAME{$id}; }

		my $descr=$snmp->hex2ascii($descr1);

#      $data_global->{'label'}="Trafico HC $descr (".$device->{'full_name'}.')' ;
#      $data_global->{'items'}="Bits rx ($id)|Bits tx ($id)";
      $data_global->{'label'}="$metric_label $descr (".$device->{'full_name'}.')' ;
      #$data_global->{'items'}=$metric_items .' ('.$id.')';
      my @vmiid=();
      my @vmi=split(/\|/,$metric_items);
      foreach my $x (@vmi) { push @vmiid, $x .' ('.$id.')'; }
      $data_global->{'items'}=join('|', @vmiid);

      $data_global->{'name'}=$data_global->{'subtype'}.'-'.$id;
		ProvisionLite::_set_iid_data($id,$data_global,\%mdata);

	}

	#return \@mdata;
	return \%mdata;
}


1;
__END__

