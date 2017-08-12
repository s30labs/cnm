#####################################################################################################
# Fichero: ProvisionLite::errors_mibii_if.pm
# Set Tab=3
#####################################################################################################
package ProvisionLite::errors_mibii_if;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
#insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('errors_mibii_if', 'MIB-II', 300, 'ERRORES EN INTERFAZ', 'errores in|errores out','.1.3.6.1.2.1.2.2.1.14.IID|.1.3.6.1.2.1.2.2.1.20.IID','./support/iid_mibii_if');
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# $data_global: (parametros globales de la metrica de cfg_monitor_snmp)
sub errors_mibii_if {
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

   $snmpcfg{'oid'}='ifType_ifInUcastPkts_ifInNUcastPkts_ifOutUcastPkts_ifOutNUcastPkts';
   $snmpcfg{'last'}='ifOutDiscards';
   $snmpcfg{'oid'}='ifDescr_ifType_ifInErrors_ifOutErrors';
   $snmpcfg{'last'}='ifOutQLen';

   my $res=$snmp->core_snmp_table(\%snmpcfg);
   #------------------------------------------------------

   if (! defined $res) { return undef; }

	my %mdata=();
   my $metric_label = $data_global->{'label'};
   my $metric_items = $data_global->{'items'};

   for my $l ( @$res ) {

		#my %data=();
      my ($id,$descr1,$type,$errors_in,$errors_out)=split(':@:',$l);
      my $descr=$snmp->hex2ascii($descr1);


#      $data{'label'}="Errores en $descr (".$device->{'full_name'}.')' ;
#      $data{'items'}="Errores IN ($id)|Errores OUT ($id)";
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
#

#      $data_global->{'label'}="Errores en $descr (".$device->{'full_name'}.')' ;
#      $data_global->{'items'}="Errores IN ($id)|Errores OUT ($id)";
      $data_global->{'label'}="$metric_label $descr (".$device->{'full_name'}.')' ;
      $data_global->{'items'}=$metric_items .' ('.$id.')';

      $data_global->{'name'}=$data_global->{'subtype'}.'-'.$id;
      ProvisionLite::_set_iid_data($id,$data_global,\%mdata);


   }

   return \%mdata;
}


1;
__END__

