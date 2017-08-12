#####################################################################################################
# Fichero: ProvisionLite::brocade_frames_port.pm
# Set Tab=3
#####################################################################################################
package ProvisionLite::brocade_frames_port;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# Frames TX/RX por puerto
# 
# SW-MIB::swFCPortTxFrames
# swFCPortTxFrames OBJECT-TYPE
#  SYNTAX        Counter32
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "This object counts the number of (Fibre Channel)
#                frames that the port has transmitted."
# ::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) bcsi(1588) commDev(2) fibrechannel(1) fcSwitch(1) sw(1) swFCport(6) swFCPortTable(2) swFCPortEntry(1) 13 }
#
#SW-MIB::swFCPortRxFrames
#swFCPortRxFrames OBJECT-TYPE
#  SYNTAX        Counter32
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "This object counts the number of (Fibre Channel)
#                frames that the port has received."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) bcsi(1588) commDev(2) fibrechannel(1) fcSwitch(1) sw(1) swFCport(6) swFCPortTable(2) swFCPortEntry(1) 14 }
#----------------------------------------------------------------------------
# INSERT INTO cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid,label,vlabel,community,mode,mtype,top_value) VALUES ('brocade_frames_port','BROCADE',300,'TRAFICO POR PUERTO FIBER-CHANNEL','Frames Tx|Frames Rx','.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.13.IID|.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.14.IID','./support/iid_brocade_port',NULL,NULL,'public',NULL,NULL,NULL);

#----------------------------------------------------------------------------
sub brocade_frames_port {
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
   $snmpcfg{'oid'}='swFCPortTxFrames_swFCPortRxFrames';
   $snmpcfg{'last'}='swFCPortTxC2Frames';

   my $res=$snmp->core_snmp_table(\%snmpcfg);
   #------------------------------------------------------

   if (! defined $res) { return undef; }

	my %mdata=();
   my $metric_label = $data_global->{'label'};
   my $metric_items = $data_global->{'items'};

   for my $l ( @$res ) {

		#my %data=();
      my ($id,$tx,$rx)=split(':@:',$l);

		my $descr=$id;
		#NOTA!! Revisar porque salen asi los datos
		if ($id=~/portNum-(\d+)/) { $id=$1+1; }


#      $data{'label'}="Trafico en puerto fc $descr (".$device->{'full_name'}.')' ;
#      $data{'items'}="Frames Tx ($id)|Frames Rx ($id)";
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

#      $data_global->{'label'}="Trafico en puerto fc $descr (".$device->{'full_name'}.')' ;
#      $data_global->{'items'}="Frames Tx ($id)|Frames Rx ($id)";
      $data_global->{'label'}="$metric_label $descr (".$device->{'full_name'}.')' ;
      $data_global->{'items'}=$metric_items .' ('.$id.')';

      $data_global->{'name'}=$data_global->{'subtype'}.'-'.$id;
      ProvisionLite::_set_iid_data($id,$data_global,\%mdata);


   }

   return \%mdata;
}

1;

__END__
