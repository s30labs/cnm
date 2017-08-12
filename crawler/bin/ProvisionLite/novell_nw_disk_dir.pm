#####################################################################################################
# Fichero: ProvisionLite::novell_nw_disk_dir.pm
# Set Tab=3
#####################################################################################################
package ProvisionLite::novell_nw_disk_dir;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# INSERT INTO cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid,label,vlabel,community,mode,mtype,top_value) VALUES ('novell_nw_disk_dir','NOVELL',300,'USO DE DIRECTORIOS','Directorios Totales|Directorios en Uso','.1.3.6.1.4.1.23.2.28.2.14.1.11|.1.3.6.1.4.1.23.2.28.2.14.1.12','./support/iid_netware_disk',NULL,NULL,'public',NULL,NULL,NULL);

#----------------------------------------------------------------------------
sub novell_nw_disk_dir {
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

   $snmpcfg{'oid'}='nwVolPhysicalName_nwVolUsedDirEntries';
   $snmpcfg{'last'}='nwVolSegmentCount';

   my $res=$snmp->core_snmp_table(\%snmpcfg);
   #------------------------------------------------------

   if (! defined $res) { return undef; }

   my %mdata=();
   my $metric_label = $data_global->{'label'};
   my $metric_items = $data_global->{'items'};

	for my $l ( @$res ) {

#		my %data=();
		my ($id,$descr1,$used)=split(':@:',$l);

		#if (&Metrics::Base::skip_metric($id)) {next;}

      my $descr=$snmp->hex2ascii($descr1);

		if (skip_novell_nw_disk_dir($descr)) {next;}

#      $data{'label'}="Directorios NW en $descr (".$device->{'full_name'}.')' ;
#      $data{'items'}="Entradas Dir ($id)";
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


#      $data_global->{'label'}="Directorios NW en $descr (".$device->{'full_name'}.')' ;
#      $data_global->{'items'}="Entradas Dir ($id)";
      $data_global->{'label'}="$metric_label $descr (".$device->{'full_name'}.')' ;
      $data_global->{'items'}=$metric_items .' ('.$id.')';

      $data_global->{'name'}=$data_global->{'subtype'}.'-'.$id;
      ProvisionLite::_set_iid_data($id,$data_global,\%mdata);

   }

   return \%mdata;
}


#------------------------------------------------
sub skip_novell_nw_disk_dir {
my $desc=shift;
my $rc=0;

	#No se que saltarme ??
	return $rc;
}

#------------------------------------------------
#sub desc_novell_nw_disk_dir {
#my $desc=shift;
#
#   #$desc=~s/\s*Serial\s*Number\s*\w+//;
#	
#   $desc=substr($desc,0,22);
#   return $desc;
#}


1;
__END__

