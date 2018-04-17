#####################################################################################################
# Fichero: (ProvisionLite::disk_mibhost.pm)
# Descripcion:
# Set Tab=3
#####################################################################################################
package ProvisionLite::disk_mibhost;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# Hash con los tipos definidos en mib-host para disco.
# El valor 0/1 indica el valor de status
my %MIBHOST_DISK_TYPES = (
   'hrStorageFixedDisk' => 0,
   'hrStorageRemovableDisk' => 0,
   'hrStorageFloppyDisk' => 1,
   'hrStorageCompactDisc' => 1,
   'hrStorageRamDisk' => 0,
   'hrStorageNetworkDisk' => 1,
);

#----------------------------------------------------------------------------
# Hash con los tipos definidos en mib-host para memoria.
# El valor 0/1 indica el valor de status
my %MIBHOST_MEMORY_TYPES = (
   'hrStorageOther' => 0,
   'hrStorageRam' => 0,
   'hrStorageVirtualMemory' => 0,
   'hrStorageFlashMemory' => 0,
);

#----------------------------------------------------------------------------
#insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('disk_mibhost', 'MIB-HOST - rfc2790',300, 'USO DE DISCO', 'Disco Total|Disco Usado','.1.3.6.1.2.1.25.2.3.1.4.IID|.1.3.6.1.2.1.25.2.3.1.5.IID|.1.3.6.1.2.1.25.2.3.1.6.IID','./support/iid_mibhost_disk');
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
sub disk_mibhost {
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

   $snmpcfg{'oid'}='hrStorageDescr_hrStorageAllocationUnits_hrStorageSize_hrStorageUsed';
   $snmpcfg{'last'}='hrStorageAllocationFailures';
   my $res=$snmp->core_snmp_table(\%snmpcfg);
   #------------------------------------------------------
   if (! defined $res) { return undef; }

	my %mdata=();
   my $metric_label = $data_global->{'label'};
   my $metric_items = $data_global->{'items'};

   for my $l ( @$res ) {

#		my %data=();
		my ($id,$descr1,$units,$size,$used,$perc)=split(':@:',$l);
      my $descr2=$snmp->hex2ascii($descr1);

		#if (skip_disk_mibhost($descr2)) {}

		my $descr=desc_disk_mibhost($descr2);

#	   $data{'label'}="Disco $descr (".$device->{'full_name'}.')' ;
#   	$data{'items'}="Espacio total ($id)|Espacio usado ($id)";
#		$data{'oid'}=$data_global->{'oid'};
#   	$data{'oid'}=~s/IID/$id/g;
#   	$data{'name'}=$data_global->{'subtype'}.'-'.$id;
#
#	   $data{'mtype'}=$data_global->{'mtype'};
#   	$data{'vlabel'}=$data_global->{'vlabel'};
#	   $data{'mode'}=$data_global->{'mode'};
#   	$data{'top_value'}=$data_global->{'top_value'};
#	   $data{'get_iid'}=$data_global->{'get_iid'};
#   	$data{'module'}=$data_global->{'module'};
#		$data{'iid'}=$id;
#	   push (@mdata, \%data);


#      $data_global->{'label'}="Disco $descr (".$device->{'full_name'}.')' ;
#      $data_global->{'items'}="Espacio total ($id)|Espacio usado ($id)";

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


#------------------------------------------------
sub skip_disk_mibhost {
my $desc=shift;
my $rc=0;

	if ($desc =~ /A\:\\.*/i) {$rc=1;}
   elsif ($desc =~ /\/dev\/shm/) {$rc=1;}
   elsif ($desc =~ /\/proc\/bus\/usb/) {$rc=1;}
	return $rc;
}

#------------------------------------------------
sub desc_disk_mibhost {
my $desc=shift;

   $desc=~s/\s*Serial\s*Number\s*\w+//;
   $desc=substr($desc,0,80);
   return $desc;
}


1;
__END__

