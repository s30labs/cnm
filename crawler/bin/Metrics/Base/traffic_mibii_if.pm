#####################################################################################################
# Fichero: (Metrics::Base::traffic_mibii_if.pm)   $Id$
# Descripcion: Metrics::Base::traffic_mibii_if.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base::traffic_mibii_if;
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
my ($device,$rcfg,$subtype)=@_;
my %snmpcfg=();
my $M='';

my $txml= '
      <metric name="--METRIC_NAME--">
        <mtype>STD_TRAFFIC</mtype>
        <subtype>--SUBTYPE--</subtype>
        <vlabel>bits/seg</vlabel>
        <label>--METRIC_LABEL--</label>
        <module>mod_snmp_get</module>
        <values>--METRIC_VAL_RX--|--METRIC_VAL_TX--</values>
        <oid>.1.3.6.1.2.1.2.2.1.10.--METRIC_IID--|.1.3.6.1.2.1.2.2.1.16.--METRIC_IID--</oid>
        <community>--METRIC_SNMP_COMMUNITY--</community>
        <version>--SNMP_VERSION--</version>
        <mode>COUNTER</mode>
        <top_value>1</top_value>
        <status>--STATUS--</status>
        <severity>--SEVERITY--</severity>
        <watch>--WATCH--</watch>
        <graph>--METRIC_POSITION--</graph>
     </metric>
';

	#BEGIN { $ENV{'MIBS'}='+IANAifType-MIB'; }
   @Metrics::Base::OIDs=qw(.1.3.6.1.2.1.2.2.1.10 .1.3.6.1.2.1.2.2.1.16);
   @Metrics::Base::IIDs=();
	#%Metrics::Base::Desc=();
	$Metrics::Base::Info='';

	# Miro si existe ifName y se pueden sacar datos de trafico del ifXTable -----------------------------
	my %IFNAME=();
	my $IFTX=0;
   $snmpcfg{oid}='ifName_ifHCInOctets_ifHCOutOctets';
   #$snmpcfg{last}='ifInMulticastPkts';
   $snmpcfg{last}='ifHCOutMulticastPkts';
   my $res=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
	for my $l ( @$res ) {
      my ($id,$name,$in,$out)=split(':@:',$l);
		$IFNAME{$id}=$name;
		if ( (defined $in) && (defined $out) ) { 
			# Testeo que el valor devuelto es un numero porque se pueden dar situaciones
			# curiosas. Dispositivo que responde a parte de la MIB extendida pero no a 
			# ifHCInOctets,ifHCOutOctets y devuelve enabled. (Cisco Aironet)
			if ( ($in=~/\d+/) && ($out=~/\d+/) ) { 	$IFTX=1;   }
		}
	}

	# Si responde a la parte extendida utilizo los OIDs de trafico IF-MIB::ifHCInOctets IF-MIB::ifHCOutOctets
	if ($IFTX) { 
		@Metrics::Base::OIDs=qw(.1.3.6.1.2.1.31.1.1.1.6 .1.3.6.1.2.1.31.1.1.1.10);  
		$txml=~s/<oid>\S+<\/oid>/<oid>.1.3.6.1.2.1.31.1.1.1.6.--METRIC_IID--|.1.3.6.1.2.1.31.1.1.1.10.--METRIC_IID--<\/oid>/g;
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

   $snmpcfg{oid}='ifDescr_ifType_ifSpeed';
	#OJO!! ifPhysAddress no siempre existe
	$snmpcfg{last}='ifAdminStatus';
   $Metrics::Base::Error='';

   $res=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
   if (! defined $res) { return undef; }

	for my $l ( @$res ) {

		my ($id,$descr1,$type,$speed)=split(':@:',$l);

		if (exists $IFNAME{$id}) { $descr1 = $IFNAME{$id}; }

		my $descr2=$Metrics::Base::SNMP->hex2ascii($descr1);

		#if ( ($Metrics::Base::Subset) && (&Metrics::Base::skip_interface($id,$type)) ) {next;}	

		my $descr = &Metrics::Base::escape($descr2);

		my $DESC="Trafico $descr";
		my $m=&Metrics::Base::m2txml_iid($device,$rcfg,$subtype,$DESC,$txml,$id,$type,\&Metrics::Base::get_status_mib2_interfaces);

		# Subset es boolean. 1=>Se computa el subset (es decir se usa skip_interfaces. 0=>Todos son activos
      #if ( ($Metrics::Base::Subset) && (&Metrics::Base::skip_interface($id,$type)) ) { $m=~s/--STATUS--/1/g; }
      #if (&Metrics::Base::skip_interface($id,$type)) { $m=~s/--STATUS--/1/g; }
		#else { $m=~s/--STATUS--/0/g; }

		#my $label="Trafico $descr ($Metrics::Base::METRIC{name})";
		##my $label="Trafico $descr";
		#$m=~s/--METRIC_LABEL--/$label/g;
		$m=~s/--METRIC_VAL_RX--/Bits rx ($id)/g;
		$m=~s/--METRIC_VAL_TX--/Bits tx ($id)/g;
		$m=~s/--SEVERITY--/$Metrics::Base::METRIC{severity}/g;

		$M .= $m;
		push @Metrics::Base::IIDs, $id;
		#$Metrics::Base::Desc{$Metrics::Base::METRIC{mname}}->{label}=$label;
		$Metrics::Base::Info=$descr;
	}
	return $M;
}


1;
__END__

