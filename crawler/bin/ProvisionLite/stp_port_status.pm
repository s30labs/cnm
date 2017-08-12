#####################################################################################################
# Fichero: ProvisionLite::stp_port_status
# Set Tab=3
#####################################################################################################
package ProvisionLite::stp_port_status;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('stp_port_status', 'BRIDGE-MIB', 300, 'ESTADO STP DE PUERTO', 'DISAB|BLOCK|LISTEN|LEARN|FORW|BROKEN','.1.3.6.1.2.1.17.2.15.1.3.IID','./support/iid_mibii_if');

#{disabled(1), blocking(2), listening(3), learning(4), forwarding(5), broken(6)
#----------------------------------------------------------------------------
sub stp_port_status {
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

   #------------------------------------------------------
   # Obtengo el mapeo ifIndex <-> Port Index
   my %PORT2IFINDEX=();
   $snmpcfg{'oid'}='dot1dBasePort_dot1dBasePortIfIndex';
   $snmpcfg{'last'}='dot1dBasePortCircuit';


   my $res=$snmp->core_snmp_table(\%snmpcfg);
   for my $l ( @$res ) {
      my ($id,$base_port,$if_index)=split(':@:',$l);
      $PORT2IFINDEX{$base_port}=$if_index;
   }


   #------------------------------------------------------
   # Obtengo ifName o ifDescr
   my %IFNAME=();
   $snmpcfg{'oid'}='ifName';
   $snmpcfg{'last'}='ifInMulticastPkts';

   $res=$snmp->core_snmp_table(\%snmpcfg);
   for my $l ( @$res ) {
      my ($id,$name)=split(':@:',$l);
      $IFNAME{$id}=$name;
   }

   #--------------------------------------------------------------------------------
   # PARCHE: Valido que el ifName es adecuado.
   # Hay casos en los que todos los valores del ifName son iguales (VH)
   my @N=values %IFNAME;
   my $ni=scalar @N;
   my $iguales=1;
   for my $i (1..$ni-1) {
      if ($N[$i] eq $N[$i-1]) { $iguales+=1; }
   }
   if ($iguales==$ni) { %IFNAME=(); }

   #----------------------------------------------------------
   $snmpcfg{'oid'}='ifDescr';
   $snmpcfg{'last'}='ifType';
   $res=$snmp->core_snmp_table(\%snmpcfg);
   for my $l ( @$res ) {
      my ($id,$descr1)=split(':@:',$l);

      if (!exists $IFNAME{$id}) { $IFNAME{$id} = $descr1; }
      else { $descr1 = $IFNAME{$id}; }
      $IFNAME{$id} = $snmp->hex2ascii($descr1);
   }


   #----------------------------------------------------------
   $snmpcfg{'oid'}='dot1dStpPortState';
   $snmpcfg{'last'}='dot1dStpPortPriority';
   $res=$snmp->core_snmp_table(\%snmpcfg);

   my %mdata=();
   my $metric_label = $data_global->{'label'};
   my $metric_items = $data_global->{'items'};

   for my $l ( @$res ) {

      my ($id,$state)=split(':@:',$l);

      #$data_global->{'label'}="Estado STP en $IFNAME{$PORT2IFINDEX{$id}} (".$device->{'full_name'}.')' ;

      $data_global->{'label'}="$metric_label $IFNAME{$PORT2IFINDEX{$id}} (".$device->{'full_name'}.')' ;
      $data_global->{'items'}=$metric_items .' ('.$id.')';

      $data_global->{'name'}=$data_global->{'subtype'}.'-'.$id;

      ProvisionLite::_set_iid_data($id,$data_global,\%mdata);
   }

   return \%mdata;
}


1;
__END__

