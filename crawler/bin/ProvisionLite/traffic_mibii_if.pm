#####################################################################################################
# Fichero: ProvisionLite::traffic_mibii_if.pm
# Set Tab=3
#####################################################################################################
package ProvisionLite::traffic_mibii_if;
$VERSION='1.00';
use strict;
use Crawler::SNMP;
use ProvisionLite::IfLabels;

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


   # Etiqueta de cada interfaz (ProvisionLite::IfLabels) y si da trafico por ifXTable (64 bits)
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

   my $LABEL = ProvisionLite::IfLabels::if_labels($snmp,\%snmpcfg);

   $snmpcfg{'oid'}='ifHCInOctets_ifHCOutOctets';
   my $res=$snmp->core_snmp_table(\%snmpcfg);
   #------------------------------------------------------

	for my $l ( @$res ) {
      my ($id,$in,$out)=split(':@:',$l);
		next if ((! defined $id) || ($id !~ /^\d+$/));
		# Testeo que el valor devuelto es un numero porque se pueden dar situaciones
		# curiosas. Dispositivo que responde a parte de la MIB extendida pero no a 
		# ifHCInOctets,ifHCOutOctets y devuelve enabled. (Cisco Aironet)
		# Tambien testeo que el valor no es cero ==> Eso implica que responde por los Counters32.
		$IFHC{$id} = ((defined $in) && (defined $out) && ($in=~/^\d+$/) && ($out=~/^\d+$/) && ($in != 0) && ($out != 0)) ? 1 : 0;
	}

	my $default_oid=$data_global->{'oid'};


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

		if (exists $LABEL->{$id}) { $descr1 = $LABEL->{$id}->{'label'}; }

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

