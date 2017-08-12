#####################################################################################################
# Fichero: ProvisionLite::status_mibii_if.pm
# Set Tab=3
#####################################################################################################
package ProvisionLite::status_mibii_if;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('status_mibii_if', 'MIB-II', 300, 'ESTADO DE INTERFAZ', 'UNK|DOWN|ADMIN DOWN|UP','.1.3.6.1.2.1.2.2.1.7.IID|.1.3.6.1.2.1.2.2.1.8.IID','./support/iid_mibii_if');

#----------------------------------------------------------------------------
sub status_mibii_if {
my ($device,$snmp,$data_global)=@_;
my %snmpcfg=();


   # Miro si existe ifName -----------------------------------
   my %IFNAME=();
   
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

   $snmpcfg{'oid'}='ifName';
   $snmpcfg{'last'}='ifInMulticastPkts';

   my $res=$snmp->core_snmp_table(\%snmpcfg);
   #------------------------------------------------------

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

   $snmpcfg{'oid'}='ifDescr_ifType_ifAdminStatus_ifOperStatus';
   $snmpcfg{'last'}='ifInOctets';
   $res=$snmp->core_snmp_table(\%snmpcfg);
	
	if (! defined $res) { return undef; }

	my %mdata=();
   my $metric_label = $data_global->{'label'};
   my $metric_items = $data_global->{'items'};

   for my $l ( @$res ) {

      my ($id,$descr1,$type,$admin,$oper)=split(':@:',$l);

		if (exists $IFNAME{$id}) { $descr1 = $IFNAME{$id}; }

		my $descr=$snmp->hex2ascii($descr1);

      #$data_global->{'label'}="Estado en $descr (".$device->{'full_name'}.')' ;
      #$data_global->{'items'}="UP|ADMIN DOWN|DOWN|UNK";
		$data_global->{'label'}="$metric_label $descr (".$device->{'full_name'}.')' ;
		$data_global->{'items'}=$metric_items .' ('.$id.')';
      $data_global->{'name'}=$data_global->{'subtype'}.'-'.$id;

#      $data{'mtype'}=$data_global->{'mtype'};
#      $data{'vlabel'}=$data_global->{'vlabel'};
#      $data{'mode'}=$data_global->{'mode'};
#      $data{'top_value'}=$data_global->{'top_value'};
#      $data{'get_iid'}=$data_global->{'get_iid'};
#      $data{'module'}=$data_global->{'module'};
#		$data{'iid'}=$id;
#      push (@mdata, \%data);


		ProvisionLite::_set_iid_data($id,$data_global,\%mdata);


   }

   return \%mdata;
}


1;
__END__

