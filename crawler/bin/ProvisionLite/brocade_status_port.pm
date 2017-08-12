#####################################################################################################
# Fichero: ProvisionLite::brocade_status_port.pm
# Set Tab=3
#####################################################################################################
package ProvisionLite::brocade_status_port;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# Estado de los puertos de FC
# 
#swFCPortAdmStatus OBJECT-TYPE
#  SYNTAX        INTEGER {online(1), offline(2), testing(3), faulty(4)}
#  MAX-ACCESS    read-write
#  STATUS        mandatory
#  DESCRIPTION   "The desired state of the port. A management station
#                may place the port in a desired state by setting this
#                object accordingly.  The testing(3) state indicates that
#                no user frames can be passed. As the result of
#                either explicit management action or per configuration
#                information accessible by the switch, swFCPortAdmStatus is
#                then changed to either the online(1) or testing(3)
#                states, or remains in the offline(2) state."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) bcsi(1588) commDev(2) fibrechannel(1) fcSwitch(1) sw(1) swFCport(6) swFCPortTable(2) swFCPortEntry(1) 5 }
#
#
#swFCPortOpStatus OBJECT-TYPE
#  SYNTAX        INTEGER {unknown(0), online(1), offline(2), testing(3), faulty(4)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "This object identifies the operational status of
#                the port. The online(1) state indicates that user frames
#                can be passed. The unknown(0) state indicates that likely
#                the port module is physically absent (see swFCPortPhyState)."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) bcsi(1588) commDev(2) fibrechannel(1) fcSwitch(1) sw(1) swFCport(6) swFCPortTable(2) swFCPortEntry(1) 4 }
#
#----------------------------------------------------------------------------
# INSERT INTO cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid,label,vlabel,community,mode,mtype,top_value) VALUES ('brocade_status_port','BROCADE',300,'ESTADO DEL PUERTO FIBER-CHANNEL','UP|DOWN|UNK','.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.5.IID|.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.4.IID','./support/iid_brocade_port',NULL,NULL,'public',NULL,NULL,NULL);

#----------------------------------------------------------------------------
sub brocade_status_port {
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

   $snmpcfg{'oid'}='swFCPortOpStatus_swFCPortAdmStatus';
   $snmpcfg{'last'}='swFCPortLinkState';

   my $res=$snmp->core_snmp_table(\%snmpcfg);
   #------------------------------------------------------

   if (! defined $res) { return undef; }

	my %mdata=();
   my $metric_label = $data_global->{'label'};
   my $metric_items = $data_global->{'items'};

   for my $l ( @$res ) {

	#	my %data=();
      my ($id,$oper,$sdmin)=split(':@:',$l);

      #my $descr=$snmp->hex2ascii($descr1);
		my $descr=$id;
		#NOTA!! Revisar porque salen asi los datos
		if ($id=~/portNum-(\d+)/) { $id=$1+1; }

#      $data{'label'}="Estado $descr (".$device->{'full_name'}.')' ;
#      $data{'items'}="UP|ADMIN DOWN|DOWN|UNK";
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



#      $data_global->{'label'}="Estado $descr (".$device->{'full_name'}.')' ;
#      $data_global->{'items'}="UP|ADMIN DOWN|DOWN|UNK";
      $data_global->{'label'}="$metric_label $descr (".$device->{'full_name'}.')' ;
      $data_global->{'items'}=$metric_items .' ('.$id.')';

      $data_global->{'name'}=$data_global->{'subtype'}.'-'.$id;
      ProvisionLite::_set_iid_data($id,$data_global,\%mdata);


   }

   return \%mdata;
}

1;

__END__
