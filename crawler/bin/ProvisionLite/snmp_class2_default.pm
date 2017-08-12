#####################################################################################################
# Fichero: ProvisionLite::snmp_class2_default.pm
# Set Tab=3
#####################################################################################################
package ProvisionLite::snmp_class2_default;
$VERSION='1.00';
use strict;
use Crawler::SNMP;
use Data::Dumper;

#----------------------------------------------------------------------------
#insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('errors_mibii_if', 'MIB-II', 300, 'ERRORES EN INTERFAZ', 'errores in|errores out','.1.3.6.1.2.1.2.2.1.14.IID|.1.3.6.1.2.1.2.2.1.20.IID','./support/iid_mibii_if');
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Hay 3 casos distintos de tablas
# A         index  descr  	v1        v2        ...         get_iid(descr)+oids
# B         index  v1		v2        v3        ...         oids
# C         descr  v1      v2        v3        ...
#
#----------------------------------------------------------------------------
#
#(A) 	get_iid_oid=.1.3.6.1.2.1.2.2.1.2		   			(ifDescr)		
#		$snmpcfg{'oid'}=ifDescr_ifInUnknownProtos			RESULTADO=2:@:eth0:@:0
#
#(B) 	get_iid_oid=.1.3.6.1.4.1.4555.1.1.1.1.4.4.1.1 	(socoupsOutputLineIndex)	
#		$snmpcfg{'oid'}=socoupsOutputPercentLoad			RESULTADO=1:@:1:@:5	=======> EN ESTE CASO SE REPITE EL IID (v0 y v1)
#
#(C) 	get_iid_oid=.1.3.6.1.4.1.30861.3.1.4.1.1  		(camID)
# 		$snmpcfg{'oid'}=camReliability						RESULTADO=7:@:"017107ECE":@:99

#----------------------------------------------------------------------------
sub snmp_class2_default {
my ($device,$snmp,$data_global)=@_;
my %snmpcfg=();

	my $subtype=$data_global->{'subtype'};
   #------------------------------------------------------
   $snmpcfg{'host_ip'}=$device->{'ip'};
   $snmpcfg{'host_name'}=$device->{'name'};
   $snmpcfg{'community'}=$device->{'community'} || 'public';
   $snmpcfg{'version'}= $device->{'version'} || '1';
   $snmpcfg{'auth_proto'}= $device->{'auth_proto'};
   $snmpcfg{'auth_pass'}= $device->{'auth_pass'};
   $snmpcfg{'priv_proto'}= $device->{'priv_proto'};
   $snmpcfg{'priv_pass'}= $device->{'priv_pass'};
   $snmpcfg{'sec_name'}= $device->{'sec_name'};
   $snmpcfg{'sec_level'}= $device->{'sec_level'};

   # En init ya se hace $snmp->reset_mapping();
   my $oid = $snmp->_oid_prepare($data_global->{'oid'});
	$snmp->log('debug',"snmp_class2_default:: **FML** [$subtype] _oid_prepare >> oid_in=$data_global->{'oid'} oid_out=$oid");
	#oid_in=.1.3.6.1.2.1.2.2.1.17.IID|.1.3.6.1.2.1.2.2.1.11.IID -> oid_out=ifOutUcastPkts_ifInUcastPkts
	#oid_in=.1.3.6.1.4.1.5624.1.2.49.1.1.1.1.4.IID -> oid_out=etsysResourceCpuLoad5min

   if (! defined $oid) {
		$snmp->log('error',"snmp_class2_default:: [$subtype] SIN VALOR DE oid **");
      return {};
   }

   if (! $data_global->{'get_iid'} ) {
      $snmp->log('error',"snmp_class2_default:: [$subtype] SIN VALOR DE get_iid **");
      return {};
   }

	my %mdata=();
	my $label=$data_global->{'label'};

#	my $x=$data_global->{'oid'};
#	$x=~s/(\S+)\.IID/$1/;
#	my $oidn=SNMP::translateObj($x);

	my @oidn=split('_',$oid);


#	#/opt/crawler/bin/libexec/get_iid1 -i 10.200.10.61 -o entPhysicalName -v 2 -c public -t snmp -j etsysResourceCpuLoad5min
#	my $CMD='/opt/crawler/bin/libexec/get_iid -i '.$device->{'ip'}.' -o '.$data_global->{'get_iid'}.' -v 2 -c public -t snmp -j '.$oidn[0];
#	$snmp->log('info',"snmp_class2_default:: CMD=$CMD");
#	my @R=`$CMD`;
#
#	foreach my $l (@R) {
#
#   	if ($l !~ /(\S+)\s*\:\s*(.*)$/) {next; }
#
#	   my ($id,$descr)=($1,$2);

	$snmpcfg{'oid_tab'} = $oidn[0];	#opcion j
	$snmpcfg{'oid'} = $data_global->{'get_iid'};	#opcion o

   my $IIDS = $snmp->snmp_get_iid(\%snmpcfg);
	foreach my $id (sort {$a<=>$b} keys %$IIDS) {

		my $descr=$IIDS->{$id};

   	$data_global->{'label'}="$label $descr (".$device->{'full_name'}.')'; # Ya instanciado
   	$data_global->{'items'}=~s/IID/$id/g;
   	$data_global->{'name'}=$data_global->{'subtype'}.'-'.$id;
   	ProvisionLite::_set_iid_data($id,$data_global,\%mdata);
	}


#use Data::Dumper;
#my $ff=Dumper(\%mdata);
#$ff=~s/\n/\. /g;
#$snmp->log('debug',"snmp_class2_default:: [$subtype] MDATA=$ff");
#$ff=Dumper($data_global);
#$ff=~s/\n/\. /g;
#$snmp->log('debug',"snmp_class2_default:: [$subtype] DATA_GLOBAL=$ff");

   return \%mdata;

}

1;
__END__

