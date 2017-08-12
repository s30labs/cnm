#####################################################################################################
# Fichero: Crawler/Analysis.pm
# Descripcion: Clase Crawler::Analysis
#####################################################################################################
use Crawler;
package Crawler::Analysis;

@ISA=qw(Crawler);
$VERSION='1.00';
use strict;
use Carp 'croak','cluck';
use Cwd;
use Digest::MD5 qw( md5_hex );
use Data::Dumper;

#----------------------------------------------------------------------------
my $ETXT='KEY-ERROR';
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Analysis
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

	my $self=$class->SUPER::new(%arg);
        
   $self->{_lapse} = $arg{lapse} || 60;			# Intervalo de testeo para el envio de avisos
   $self->{_cfg} = $arg{cfg} || '';					# Referencia a un hash con los parametros de configuracion.
   $self->{_snmp} = $arg{snmp} || undef;			# Objeto SNMP
   $self->{_snmpcfg} = $arg{snmpcfg} || undef;	# Configuracion SNMP
   $self->{_sysname} = $arg{sysname} || '';		# sysname
   $self->{_sysoid} = $arg{sysoid} || '';			# sysoid
   $self->{_bridge} = $arg{bridge} || 0;			# bridge=1 => Es switch
   $self->{_narp} = $arg{narp} || '';				# narp
   $self->{_ninterfaces} = $arg{ninterfaces} || '';				# ninterfaces
   $self->{_nips} = $arg{nips} || '';				# nips
   $self->{_ntrunks} = $arg{ntrunks} || '';		# ntrunks
        
   return $self;
}


#----------------------------------------------------------------------------
# lapse 
#----------------------------------------------------------------------------
sub lapse {
my ($self,$lapse) = @_;
   if (defined $lapse) {
      $self->{_lapse}=$lapse;
   }
   else { return $self->{_lapse}; }
}

#----------------------------------------------------------------------------
# cfg
#----------------------------------------------------------------------------
sub cfg {
my ($self,$cfg) = @_;
   if (defined $cfg) {
      $self->{_cfg}=$cfg;
   }
   else { return $self->{_cfg}; }
}

#----------------------------------------------------------------------------
# snmp
#----------------------------------------------------------------------------
sub snmp {
my ($self,$snmp) = @_;
   if (defined $snmp) {
      $self->{_snmp}=$snmp;
   }
   else { return $self->{_snmp}; }
}

#----------------------------------------------------------------------------
# snmpcfg
#----------------------------------------------------------------------------
sub snmpcfg {
my ($self,$snmpcfg) = @_;
   if (defined $snmpcfg) {
      $self->{_snmpcfg}=$snmpcfg;
   }
   else { return $self->{_snmpcfg}; }
}

#----------------------------------------------------------------------------
# sysname
#----------------------------------------------------------------------------
sub sysname {
my ($self,$sysname) = @_;
   if (defined $sysname) {
      $self->{_sysname}=$sysname;
   }
   else { return $self->{_sysname}; }
}

#----------------------------------------------------------------------------
# sysoid
#----------------------------------------------------------------------------
sub sysoid {
my ($self,$sysoid) = @_;
   if (defined $sysoid) {
      $self->{_sysoid}=$sysoid;
   }
   else { return $self->{_sysoid}; }
}

#----------------------------------------------------------------------------
# bridge
#----------------------------------------------------------------------------
sub bridge {
my ($self,$bridge) = @_;
   if (defined $bridge) {
      $self->{_bridge}=$bridge;
   }
   else { return $self->{_bridge}; }
}

#----------------------------------------------------------------------------
# narp
#----------------------------------------------------------------------------
sub narp {
my ($self,$narp) = @_;
   if (defined $narp) {
      $self->{_narp}=$narp;
   }
   else { return $self->{_narp}; }
}

#----------------------------------------------------------------------------
# ninterfaces
#----------------------------------------------------------------------------
sub ninterfaces {
my ($self,$ninterfaces) = @_;
   if (defined $ninterfaces) {
      $self->{_ninterfaces}=$ninterfaces;
   }
   else { return $self->{_ninterfaces}; }
}

#----------------------------------------------------------------------------
# nips
#----------------------------------------------------------------------------
sub nips {
my ($self,$nips) = @_;
   if (defined $nips) {
      $self->{_nips}=$nips;
   }
   else { return $self->{_nips}; }
}

#----------------------------------------------------------------------------
# ntrunks
#----------------------------------------------------------------------------
sub ntrunks {
my ($self,$ntrunks) = @_;
   if (defined $ntrunks) {
      $self->{_ntrunks}=$ntrunks;
   }
   else { return $self->{_ntrunks}; }
}


#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
sub get_system_info  {
my ($self,$indata)=@_;

   my $cfg=$self->cfg();
   my $snmp=Crawler::SNMP->new( 'cfg'=>$cfg );
   my $SNMPCFG=$snmp->get_snmp_credentials($indata);
	$self->snmp($snmp);
	$self->snmpcfg($SNMPCFG);

	my ($rc, $rcstr, $res)=$snmp->verify_snmp_data($SNMPCFG);
	$snmp->snmp_prepare_info($SNMPCFG);

	$self->sysname($SNMPCFG->{'sysname'});
	$self->sysoid($SNMPCFG->{'sysoid'});
}

#----------------------------------------------------------------------------
# get_arp_info
# ARP del dispositivo ---> kb_arp
#
# A partir de la tabla: RFC1213-MIB::atTable
#
#          '6.1.10.6.1.207' => {
#                                'atIfIndex' => '6',
#                                'atPhysAddress' => '"00 14 38 D9 F6 D1"',
#                                'atNetAddress' => '1.10.6.1'
#                              }
#	Tabla kb_arp:
#	+--------+--------------+-------------------+-------------+------------+
#	| id_arp | host_ip      | mac               | ip          | date       |
#	+--------+--------------+-------------------+-------------+------------+
#	|     77 | 10.6.254.254 | 00:16:9D:75:85:C1 | 10.0.103.10 | 1259062026 |
#	|     78 | 10.6.254.254 | 00:1D:A1:1C:38:00 | 10.0.103.9  | 1259062026 |
#
#----------------------------------------------------------------------------
sub get_arp_info  {
my ($self,$indata)=@_;

	my $cfg=$self->cfg();
	my $snmp = $self->snmp();
	my $SNMPCFG = $self->snmpcfg();

	if ( (! defined $snmp) || (! defined $SNMPCFG)) {
	   $snmp=Crawler::SNMP->new( 'cfg'=>$cfg );
		$SNMPCFG=$snmp->get_snmp_credentials($indata);
	}

   $SNMPCFG->{'oid'}='RFC1213-MIB::atTable';

	# Parche bug. No funciona bien el gettable para esta MIB en v1
	if ($SNMPCFG->{'version'} == 1) { $SNMPCFG->{'version'}=2; }
#print Dumper($SNMPCFG);

	my $ip = $SNMPCFG->{'host_ip'};
   my $time=time();
   my $r=$snmp->core_snmp_table_hash($SNMPCFG);

#print Dumper($r);

	my $narp=0;
	if ((! defined $r) || (ref($r) ne "HASH")) {
		$self->log('info',"get_arp_info::[DEBUG] [*ERR*] SIN DATOS de atTable IP=$ip");
		return;
	}

   my $store=$self->store();
   my $dbh=$self->dbh();
   foreach my $iid (sort keys %$r) {
		my %data=( 'host_ip'=>$ip, 'ip'=>'-', 'date'=>$time );
      my $macraw = $r->{$iid}->{'atPhysAddress'};
      chomp($macraw);
      $macraw =~ s/"//g;
      my @oct = split (/\s+/, $macraw);
      $data{'mac'}=lc (join(':',@oct));
      if ($iid =~ /.*?(\d+\.\d+\.\d+\.\d+)$/) { $data{'ip'} = $1; }

#print Dumper(\%data);
      $store->insert_to_db($dbh,'kb_arp',\%data);

      $store->insert_to_db($dbh,'kb_arp_global',\%data);
		my $error=$store->error();
		if (! $error) {
			$self->log('debug',"get_arp_info::[DEBUG] [ OK  ] IP1=$ip IP2=$data{'ip'} MAC=$data{'mac'}");
		}
		else {
			my $rcstr=$store->errorstr();
			$self->log('info',"get_arp_info::[DEBUG] [*ERR*] ($rcstr) IP1=$ip IP2=$data{'ip'} MAC=$data{'mac'}");
		}

		$narp+=1;
   }

	$self->narp($narp);
}

#----------------------------------------------------------------------------

# get_cdp_info
# CDP del dispositivo ---> kb_cdp
#
# A partir de la tabla: CISCO-CDP-MIB::cdpCacheTable
#
#          '10103.8' => {
#                         'cdpCachePowerConsumption' => '0',
#                         'cdpCachePrimaryMgmtAddr' => 'a:6:1:d7',
#                         'cdpCacheAddressType' => 'ip',
#                         'cdpCacheAddress' => 'a:6:1:d7',
#                       }
#  Tabla kb_cdp:
#	+--------+--------------+---------+------------+------------+
#	| id_cdp | host_ip      | iid     | ip         | date       |
#	+--------+--------------+---------+------------+------------+
#	|      1 | 10.6.254.254 | 10001.7 | 10.0.103.9 | 1258970135 |
#	|      2 | 10.6.254.254 | 10101.5 | 10.6.1.252 | 1258970135 |
#
#----------------------------------------------------------------------------
sub get_cdp_info  {
my ($self,$indata)=@_;

	my @results=();
   my $cfg=$self->cfg();
   my $snmp=Crawler::SNMP->new( 'cfg'=>$cfg );
   my $SNMPCFG=$snmp->get_snmp_credentials($indata);
   $SNMPCFG->{'oid'}='CISCO-CDP-MIB::cdpCacheTable';
#print Dumper($SNMPCFG);

   my $ip = $SNMPCFG->{'host_ip'};
   my $time=time();
   my $r=$snmp->core_snmp_table_hash($SNMPCFG);
   if ((! defined $r) || (ref($r) ne "HASH")) {
      $self->log('info',"get_cdp_info::[DEBUG] [*ERR*] SIN DATOS de cdpCacheTable IP=$ip");
      return \@results;
   }

#print Dumper($r);

   my $store=$self->store();
   my $dbh=$self->dbh();

eval {
   foreach my $iid (sort keys %$r) {
      my %data=( 'host_ip'=>$ip, 'iid'=>$iid, 'date'=>$time );
		# iid es del tipo 10001.7 siempre ???
      $data{'iid'} =~ s/(\d+)\..*$/$1/g;

		#'cdpCacheAddress' => '"0A 85 08 15 "',
		# Tambien puede utilizar como separador : (??)
      my $ipraw = $r->{$iid}->{'cdpCacheAddress'};
		$ipraw =~ s/^"(.*)"$/$1/g;
      my @oct = split (':', $ipraw);
		if (scalar(@oct) !=4 ) { @oct = split (/\s+/, $ipraw); }
		else { $self->log('debug',"get_cdp_info:: **OJO** ipraw=$ipraw NO SE DIVIDE EN OCTETOS ...");}
#print Dumper(\@oct);
#$VAR1 = [
#          '0A 85 08 1C '
#			         ];
#
      $data{'ip'} = hex($oct[0]).".".hex($oct[1]).".".hex($oct[2]).".".hex($oct[3]);

		# Otros campos interesantes
		$data{'device_id'} = $r->{$iid}->{'cdpCacheDeviceId'};
		$data{'platform'} = $r->{$iid}->{'cdpCachePlatform'};
		$data{'device_port'} = $r->{$iid}->{'cdpCacheDevicePort'};
		$data{'version'} = $r->{$iid}->{'cdpCacheVersion'};

#print Dumper(\%data);
		push @results, \%data;
      $store->insert_to_db($dbh,'kb_cdp',\%data);
      my $error=$store->error();
      if (! $error) {
         $self->log('debug',"get_cdp_info::[DEBUG] [ OK  ] IP1=$ip IP2=$data{'ip'} IID=$data{'iid'}");
      }
      else {
         my $rcstr=$store->errorstr();
         $self->log('info',"get_cdp_info::[DEBUG] [*ERR*] ($rcstr) IP1=$ip IP2=$data{'ip'} IID=$data{'iid'}");
      }
   }

};
	return \@results;
}



#----------------------------------------------------------------------------
# get_iftable
# ifTable del dispositivo ---> kb_interfaces
#
# A partir de la tabla: RFC1213-MIB::ifTable
#
#----------------------------------------------------------------------------
sub get_iftable  {
my ($self,$indata)=@_;

   my $cfg=$self->cfg();
   my $snmp=Crawler::SNMP->new( 'cfg'=>$cfg );
   my $SNMPCFG=$snmp->get_snmp_credentials($indata);
   $SNMPCFG->{'oid'}='RFC1213-MIB::ifTable';
#print Dumper($SNMPCFG);

my $iftable={};
eval {

   my $ip = $SNMPCFG->{'host_ip'};
   my $time=time();
   $iftable=$snmp->core_snmp_table_hash($SNMPCFG);
   if ((! defined $iftable) || (ref($iftable) ne "HASH")) {
      $self->log('info',"get_ifip::[DEBUG] [*ERR*] SIN DATOS de ifTable IP=$ip");
      return {};
   }

#print Dumper($r);
	my $ninterfaces=0;
   my $store=$self->store();
   my $dbh=$self->dbh();
   foreach my $id ( keys %$iftable ) {
		my %data=( 'host_ip'=>$ip, 'iid'=>$id, 'date'=>$time );		
      $data{'ifDescr'} = (exists $iftable->{$id}->{'ifDescr'}) ? $iftable->{$id}->{'ifDescr'} : '-';
      $data{'ifPhysAddress'} = (exists $iftable->{$id}->{'ifPhysAddress'}) ? chomp $iftable->{$id}->{'ifPhysAddress'} : '-';
      $data{'ifMtu'} = (exists $iftable->{$id}->{'ifMtu'}) ? $iftable->{$id}->{'ifMtu'} : '-';
      $data{'ifType'} = (exists $iftable->{$id}->{'ifType'}) ? $iftable->{$id}->{'ifType'} : '-';
      $data{'ifSpeed'} = (exists $iftable->{$id}->{'ifSpeed'}) ? $iftable->{$id}->{'ifSpeed'} : '-';
      $data{'ifOperStatus'} = (exists $iftable->{$id}->{'ifOperStatus'}) ? $iftable->{$id}->{'ifOperStatus'} : '-';
      $data{'ifAdminStatus'} =(exists $iftable->{$id}->{'ifAdminStatus'}) ? $iftable->{$id}->{'ifAdminStatus'} : '-';
      #$data{'MACS'}=[];

      $store->insert_to_db($dbh,'kb_interfaces',\%data);
      my $error=$store->error();
      if (! $error) {
         $self->log('debug',"get_iftable::[DEBUG] [ OK  ] IP=$ip IID=$data{'iid'} DESC=$data{'ifDescr'}");
      }
      else {
         my $rcstr=$store->errorstr();
         $self->log('info',"get_iftable::[DEBUG] [*ERR*] ($rcstr) IP=$ip IID=$data{'iid'} DESC=$data{'ifDescr'}");
      }
		$ninterfaces+=1;
   }

	$self->ninterfaces($ninterfaces);
};

	return $iftable;
}


#----------------------------------------------------------------------------
# get_ifip
# ifTable del dispositivo ---> kb_interfaces
#
# A partir de la tabla: RFC1213-MIB::ifTable
#
#----------------------------------------------------------------------------
sub get_ifip  {
my ($self,$indata)=@_;

   my $cfg=$self->cfg();
   my $snmp=Crawler::SNMP->new( 'cfg'=>$cfg );
   my $SNMPCFG=$snmp->get_snmp_credentials($indata);
   $SNMPCFG->{'oid'}='IP-MIB::ipAddrTable';

   # Parche bug. No funciona bien el gettable para esta MIB en v1
   if ($SNMPCFG->{'version'} == 1) { $SNMPCFG->{'version'}=2; }
#print Dumper($SNMPCFG);

   my $ip = $SNMPCFG->{'host_ip'};
   my $time=time();
   my $r=$snmp->core_snmp_table_hash($SNMPCFG);
#print Dumper($r);

   if ((! defined $r) || (ref($r) ne "HASH")) {
      $self->log('info',"get_ifip::[DEBUG] [*ERR*] SIN DATOS de ipAddrTable IP=$ip");
      return;
   }

	my $nips=0;
   my $store=$self->store();
   my $dbh=$self->dbh();
   foreach my $ifip (sort keys %$r) {
      my %data=( 'ifIp'=>$ifip  );

      $data{'iid'} = $r->{$ifip}->{'ipAdEntIfIndex'};
#print Dumper(\%data);

		my $condition="host_ip=\'$ip\' and iid=\'".$data{'iid'}."\'";
      $store->update_db($dbh,'kb_interfaces',\%data,$condition);
      #$store->insert_to_db($dbh,'kb_interfaces',\%data);

#my $sql=$store->lastcmd();
#print "SQL=$sql\n";

      my $error=$store->error();
      if (! $error) {
         $self->log('debug',"get_ifip::[DEBUG] [ OK  ] IP=$ip IID=$data{'iid'} ifIP=$data{'ifIp'}");
      }
      else {
         my $rcstr=$store->errorstr();
         $self->log('info',"get_ifip::[DEBUG] [*ERR*] ($rcstr) IP=$ip IID=$data{'iid'} ifIP=$data{'ifIp'}");
      }

		$nips+=1;
   }

	$self->nips($nips);
   return;
}

#----------------------------------------------------------------------------
# get_defined_vlans_cisco
# ifTable del dispositivo ---> kb_interfaces
#
# A partir de la tabla: RFC1213-MIB::ifTable
#
#----------------------------------------------------------------------------
sub is_bridge  {
my ($self,$indata)=@_;

   my $cfg=$self->cfg();
   my $snmp=Crawler::SNMP->new( 'cfg'=>$cfg );
   my $SNMPCFG=$snmp->get_snmp_credentials($indata);
   my $ip = $SNMPCFG->{'host_ip'};
   my $time=time();

	my $nb_ports=$snmp->snmp_get_bridge_ports($SNMPCFG,$ip);

	if ($nb_ports>0) { $self->bridge(1); }
	else { $self->bridge(0); }
}

#----------------------------------------------------------------------------
# get_defined_vlans_cisco
# ifTable del dispositivo ---> kb_interfaces
#
# A partir de la tabla: RFC1213-MIB::ifTable
#
#----------------------------------------------------------------------------
sub get_defined_vlans_cisco  {
my ($self,$indata)=@_;

   my $store=$self->store();
   my $dbh=$self->dbh();

	my %OPERATIONAL_VLANS=();
   my $cfg=$self->cfg();
   my $snmp=Crawler::SNMP->new( 'cfg'=>$cfg );
   my $SNMPCFG=$snmp->get_snmp_credentials($indata);
   my $ip = $SNMPCFG->{'host_ip'};
   my $time=time();

   $SNMPCFG->{'oid'}='CISCO-VTP-MIB::vlanTrunkPortDynamicStatus';
   my $vtpTrunkTable=$snmp->core_snmp_table($SNMPCFG);
   my @trunks = ();
   foreach my $x (@$vtpTrunkTable) {
		#10116:@:2
		my ($iid,$status)=split(':@:',$x);
      if ($status == 1) { push @trunks,$iid; }
   }

	my $ntrunks = scalar(@trunks);
	$self->ntrunks($ntrunks);
	if ($ntrunks > 0) {
	   my $condition="host_ip='$ip' AND iid IN (".join(',',@trunks).')';
   	$store->update_db($dbh,'kb_interfaces',{'trunk'=>1},$condition);
	
   	my $error=$store->error();
   	if (! $error) {
      	$self->log('debug',"get_defined_vlans_cisco::[DEBUG] [ OK  ] IP=$ip trunks >> $condition");
   	}
  	 	else {
      	my $rcstr=$store->errorstr();
      	$self->log('info',"get_defined_vlans_cisco::[DEBUG] [*ERR*] ($rcstr) IP=$ip trunks >> $condition");
   	}
	}	




   $SNMPCFG->{'oid'}='CISCO-VTP-MIB::vtpVlanTable';
   my $vtpTable=$snmp->core_snmp_table_hash($SNMPCFG);
   if ((! defined $vtpTable) || (ref($vtpTable) ne "HASH")) {
      $self->log('info',"get_defined_vlans_cisco::[DEBUG] [*ERR*] SIN DATOS de vtpVlanTable IP=$ip");
		return \%OPERATIONAL_VLANS;
   }

   foreach my $id ( keys %$vtpTable ) {
      my $vlan=$id;
      $vlan =~ s/.*?\.(\d+)$/$1/;

		#Chequear estado peracional ???? vtpVlanState.1.1 = INTEGER: operational(1)
      $OPERATIONAL_VLANS{$vlan}->{'id'} = $vlan;
      $OPERATIONAL_VLANS{$vlan}->{'name'} = $vtpTable->{$id}->{'vtpVlanName'};
      $OPERATIONAL_VLANS{$vlan}->{'state'} = $vtpTable->{$id}->{'vtpVlanState'};
   }

#print Dumper(\%OPERATIONAL_VLANS);


	return \%OPERATIONAL_VLANS;
}



#----------------------------------------------------------------------------
# get_vlan_bridge_port
#
# BRIDGE-MIB::dot1dBasePortTable
#
#          '81' => {
#                    'dot1dBasePortMtuExceededDiscards' => '0',
#                    'dot1dBasePortDelayExceededDiscards' => '0',
#                    'dot1dBasePortCircuit' => '.0.0',
#                    'dot1dBasePortIfIndex' => '10603',
#                    'dot1dBasePort' => '81'
#                  },
#
# BRIDGE-MIB::dot1dTpFdbTable
#
#          '0.36.129.15.138.8' => {
#                                   'dot1dTpFdbStatus' => 'learned',
#                                   'dot1dTpFdbAddress' => '',
#                                   'dot1dTpFdbPort' => '12'
#                                 },
#
# | ip     | varchar(15) |      | PRI |         |                |
# | iid    | varchar(50) |      |     |         |                |
# | mac    | varchar(50) |      | PRI | -       |                |
# | vlan   | varchar(20) |      | PRI | -       |                |
# | date   | int(11)     | YES  |     | NULL    |                |
# +--------+-------------+------+-----+---------+----------------+
#
#----------------------------------------------------------------------------
sub get_vlan_bridge_port {
my ($self,$vlan,$indata)=@_;

	my $vlan_id=$vlan->{'id'};
	my $vlan_name=$vlan->{'name'};
   my $cfg=$self->cfg();
   my $snmp=Crawler::SNMP->new( 'cfg'=>$cfg );
   my $SNMPCFG=$snmp->get_snmp_credentials($indata);
   $SNMPCFG->{'oid'}='BRIDGE-MIB::dot1dBasePortTable';
	$SNMPCFG->{'community'} .= "\@".$vlan_id;

   # Parche bug. No funciona bien el gettable para esta MIB en v1
   if ($SNMPCFG->{'version'} == 1) { $SNMPCFG->{'version'}=2; }
#print Dumper($SNMPCFG);

   my $ip = $SNMPCFG->{'host_ip'};
   my $time=time();
   my $portTable=$snmp->core_snmp_table_hash($SNMPCFG);
   if ((! defined $portTable) || (ref($portTable) ne "HASH")) {
      $self->log('info',"get_vlan_bridge_port::[DEBUG] [*ERR*] SIN DATOS de dot1dBasePortTable IP=$ip vlan_name=$vlan_name ($vlan_id)");
      return;
   }


#print Dumper($portTable);
	my %port2index=();
   foreach my $port (keys %$portTable) {
      $port2index{$port} = $portTable->{$port}->{'dot1dBasePortIfIndex'};
   }

   $SNMPCFG->{'oid'}='BRIDGE-MIB::dot1dTpFdbTable';
   my $fdbTable=$snmp->core_snmp_table_hash($SNMPCFG);
   if ((! defined $fdbTable) || (ref($fdbTable) ne "HASH")) {
      $self->log('debug',"get_vlan_bridge_port::[DEBUG] SIN DATOS de dot1dTpFdbTable IP=$ip vlan_name=$vlan_name ($vlan_id)");
      return;
   }

#print Dumper($fdbTable);
   my $store=$self->store();
   my $dbh=$self->dbh();
   foreach my $mac (keys %$fdbTable) {
		my %data=( 'host_ip'=>$ip, 'vlan_id'=>$vlan_id, 'vlan_name'=>$vlan_name, 'date'=>$time );
      $data{'mac'} = $self->_mac_formatter($mac);
      my $port=$fdbTable->{$mac}->{'dot1dTpFdbPort'};
      $data{'iid'} = $port2index{$port};

      $store->insert_to_db($dbh,'kb_cam',\%data);
      my $error=$store->error();
      if (! $error) {
         $self->log('debug',"get_vlan_bridge_port::[DEBUG] [ OK  ] IP=$ip IID=$data{'iid'} vlan_name=$vlan_name ($vlan_id)");
      }
      else {
         my $rcstr=$store->errorstr();
         $self->log('info',"get_vlan_bridge_port::[DEBUG] [*ERR*] ($rcstr) IP=$ip IID=$data{'iid'} vlan_name=$vlan_name ($vlan_id)");
      }
   }
}


#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
sub _mac_formatter {
my ($self,$mac)=@_;

   # Convierto la MAC a formato aa:bb:cc..
   my @hm = map { sprintf("%.2x",$_) } split(/\./,$mac);
   #my $hmac = join (':', @hm);
   return join (':', @hm);
}

1;
__END__

