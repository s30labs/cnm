#####################################################################################################
# Fichero: ProvisionLite::traffic_mibii_if.pm
# Set Tab=3
#####################################################################################################
package ProvisionLite::traffic_mibii_if;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('traffic_mibii_if', 'MIB-II', 300, 'TRAFICO EN INTERFAZ ', 'Bits RX|Bits TX','.1.3.6.1.2.1.2.2.1.10.IID|.1.3.6.1.2.1.2.2.1.16.IID','./support/iid_mibii_if');
#----------------------------------------------------------------------------
=head1 traffic_mibii_if 

 OIDs: .1.3.6.1.2.1.2.2.1.10.IID/.1.3.6.1.2.1.2.2.1.16.IID
 TIPO: STD_TRAFFIC (bits=bytes*8)
 VALUES: RX | TX
 VLABEL: bits/sg
 DESCR: Numero Total de octetos rx/tx por el interfaz incluyendo cabeceras.

=cut

#ifHCInOctets  .1.3.6.1.2.1.31.1.1.1.6.--METRIC_IID--
#ifHCOutOctets .1.3.6.1.2.1.31.1.1.1.10.--METRIC_IID--
#----------------------------------------------------------------------------
sub traffic_mibii_if {
my ($device,$snmp,$data_global)=@_;
my %snmpcfg=();


   # Miro si existe ifName y se pueden sacar datos de trafico del ifXTable -----------------------------
   my %IFNAME=();
   my %IFHC=();

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

   $snmpcfg{'oid'}='ifName_ifHCInOctets_ifHCOutOctets';
   #$snmpcfg{'oid'}='ifName_ifInMulticastPkts_ifInBroadcastPkts';
   $snmpcfg{'last'}='ifHCOutMulticastPkts';

   my $res=$snmp->core_snmp_table(\%snmpcfg);

	#Check if $res = [ '1:@:U:@:0:@:0' ] and then try with ifAlias
	if ($res->[0] =~ /\d+\:\@\:U/) {
		$snmpcfg{'oid'}='ifAlias_ifHCInOctets_ifHCOutOctets';
		$res=$snmp->core_snmp_table(\%snmpcfg);
	}

   #------------------------------------------------------

	for my $l ( @$res ) {
      my ($id,$name,$in,$out)=split(':@:',$l);
		$name=~s/^\s*(.*)$/$1/g;
		$IFNAME{$id}=$name;
		
		if ( (defined $in) && (defined $out) ) { 
			# Testeo que el valor devuelto es un numero porque se pueden dar situaciones
			# curiosas. Dispositivo que responde a parte de la MIB extendida pero no a 
			# ifHCInOctets,ifHCOutOctets y devuelve enabled. (Cisco Aironet)
			# Tambien testeo que el valor no es cero ==> Eso implica que responde por los Counters32.
			if ( ($in=~/\d+/) && ($out=~/\d+/) && ($in != 0) && ($out != 0)) { 	
				#$IFHC=1;   
				$IFHC{$id}=1;
			}
			else { $IFHC{$id}=0; }
		}
		else { $IFHC{$id}=0; }
	}

	my $default_oid=$data_global->{'oid'};

#	# Si responde a la parte extendida utilizo los OIDs de trafico IF-MIB::ifHCInOctets IF-MIB::ifHCOutOctets
#	if ($IFHC) { 
#		#@Metrics::Base::OIDs=qw(.1.3.6.1.2.1.31.1.1.1.6 .1.3.6.1.2.1.31.1.1.1.10);  
#		#$txml=~s/<oid>\S+<\/oid>/<oid>.1.3.6.1.2.1.31.1.1.1.6.--METRIC_IID--|.1.3.6.1.2.1.31.1.1.1.10.--METRIC_IID--<\/oid>/g;
#
#		$data_global->{'oid'}='.1.3.6.1.2.1.31.1.1.1.6.IID|.1.3.6.1.2.1.31.1.1.1.10.IID';
#	}

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
	# Existen equipos que no reportan trafico por todos los interfaces
	# por eso se hace esta comprobacion previa.
	my %TRAFFIC_OK=();
   $snmpcfg{'host_ip'}=$device->{'ip'};
   $snmpcfg{'community'}=$device->{'community'} || 'public';
   $snmpcfg{'version'}= $device->{'version'} || '1';

	$snmpcfg{'oid'}='ifInOctets_ifOutOctets';
	$data_global->{'oid'}=$default_oid;
	$res=$snmp->core_snmp_table(\%snmpcfg);
	for my $l ( @$res ) { 
		my ($id,$in,$out)=split(':@:',$l);
		 if ( ($in=~/\d+/) && ($out=~/\d+/) ) {	$TRAFFIC_OK{$id}=1;  }
	}

	#----------------------------------------------------------
   $snmpcfg{'oid'}='ifDescr_ifType_ifSpeed';
   #OJO!! ifPhysAddress no siempre existe
   $snmpcfg{'last'}='ifAdminStatus';

   $res=$snmp->core_snmp_table(\%snmpcfg);
   #------------------------------------------------------

   if (! defined $res) { return undef; }

	my %mdata=();
	my $metric_label = $data_global->{'label'};
	my $metric_items = $data_global->{'items'};

	for my $l ( @$res ) {

		my ($id,$descr1,$type,$speed)=split(':@:',$l);

		my $itable='ifTable';
	   $snmpcfg{'oid'}='ifInOctets_ifOutOctets';
   	$data_global->{'oid'}=$default_oid;
   	if ( exists ($IFHC{$id}) && ($IFHC{$id}==1) ) {
			$itable='ifXTable';
      	$snmpcfg{'oid'}='ifHCInOctets_ifHCOutOctets';
      	$data_global->{'oid'}='.1.3.6.1.2.1.31.1.1.1.6.IID|.1.3.6.1.2.1.31.1.1.1.10.IID';
   	}
   	else {
			if (!exists $TRAFFIC_OK{$id}) { next; }
   	}

		if (exists $IFNAME{$id}) { $descr1 = $IFNAME{$id}; }

		my $descr=$snmp->hex2ascii($descr1);

      $data_global->{'label'}="$metric_label $descr (".$device->{'full_name'}.')' ;

		my @vmiid=();
		my @vmi=split(/\|/,$metric_items);
		foreach my $x (@vmi) { push @vmiid, $x.' - '.$itable.' ('.$id.')'; }
		$data_global->{'items'}=join('|', @vmiid);  

      $data_global->{'name'}=$data_global->{'subtype'}.'-'.$id;
		ProvisionLite::_set_iid_data($id,$data_global,\%mdata);

	}
	
	return \%mdata;
}


1;
__END__

