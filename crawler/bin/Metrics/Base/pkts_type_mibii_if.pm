#####################################################################################################
# Fichero: (Metrics::Base::pkts_type_mibii_if.pm)   $Id$
# Descripcion: Metrics::Base::pkts_type_mibii_if.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base::pkts_type_mibii_if;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('pkts_type_mibii_if', 'MIB-II', 300, 'TIPO DE TRAFICO EN INTERFAZ', 'PKTS ucast in|PKTS nucast in|PKTS ucast out|PKTS nucast out','.1.3.6.1.2.1.2.2.1.11.IID|.1.3.6.1.2.1.2.2.1.12.IID|.1.3.6.1.2.1.2.2.1.17.IID|.1.3.6.1.2.1.2.2.1.18.IID','./support/iid_mibii_if');
#----------------------------------------------------------------------------
=head1 pkts_type_mibii_if

 OIDs: .1.3.6.1.2.1.2.2.1.11.IID|.1.3.6.1.2.1.2.2.1.12.IID|.1.3.6.1.2.1.2.2.1.17.IID|.1.3.6.1.2.1.2.2.1.18.IID 
 TIPO: STD_AREA
 VALUES: pkts ucast in|pkts nucast in|pkts ucast out|pkts nucast out 
 VLABEL: pkts/seg
 DESCR: Paquetes unicast y no unicast en entrada y salida

=cut

#----------------------------------------------------------------------------
sub pkts_type_mibii_if {
my ($device,$rcfg,$subtype)=@_;
my %snmpcfg=();
my $M='';

my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_AREA</mtype>
			<subtype>--SUBTYPE--</subtype>
         <vlabel>pkts/seg</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
			<values>--METRIC_VAL_IN_UCAST--|--METRIC_VAL_IN_NUCAST--|--METRIC_VAL_OUT_UCAST--|--METRIC_VAL_OUT_NUCAST--</values>
         <oid>.1.3.6.1.2.1.2.2.1.11.--METRIC_IID--|.1.3.6.1.2.1.2.2.1.12.--METRIC_IID--|.1.3.6.1.2.1.2.2.1.17.--METRIC_IID--|.1.3.6.1.2.1.2.2.1.18.--METRIC_IID--</oid>
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

   @Metrics::Base::OIDs=qw( .1.3.6.1.2.1.2.2.1.11 .1.3.6.1.2.1.2.2.1.12 .1.3.6.1.2.1.2.2.1.17 .1.3.6.1.2.1.2.2.1.18);
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
	$Metrics::Base::Info='';
   $snmpcfg{oid}='ifType_ifInUcastPkts_ifInNUcastPkts_ifOutUcastPkts_ifOutNUcastPkts';
   $snmpcfg{last}='ifOutDiscards';
   $Metrics::Base::Error='';

   my $res=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
   if (! defined $res) { return undef; }

   for my $l ( @$res ) {
      my ($id,$descr1,$type,$ucastin,$nucastin,$ucastout,$nucastout)=split(':@:',$l);
      my $descr2=$Metrics::Base::SNMP->hex2ascii($descr1);

		#if ( ($Metrics::Base::Subset) && (&Metrics::Base::skip_interface($id,$type)) ) {next;}

      my $descr = &Metrics::Base::escape($descr2);

		my $DESC="Paquetes en $descr";
		my $m=&Metrics::Base::m2txml_iid($device,$rcfg,$subtype,$DESC,$txml,$id,$type,\&Metrics::Base::get_status_mib2_interfaces);

      #if (&Metrics::Base::skip_interface($id,$type)) { $m=~s/--STATUS--/1/g; }
      #else { $m=~s/--STATUS--/0/g; }

		#my $label="Paquetes en $descr ($Metrics::Base::METRIC{name})";

      #$m=~s/--METRIC_LABEL--/$label/g;
      $m=~s/--METRIC_VAL_IN_UCAST--/Pkts unicast IN ($id)/g;
      $m=~s/--METRIC_VAL_IN_NUCAST--/Pkts no unicast IN ($id)/g;
      $m=~s/--METRIC_VAL_OUT_UCAST--/Pkts unicast OUT ($id)/g;
      $m=~s/--METRIC_VAL_OUT_NUCAST--/Pkts no unicast OUT ($id)/g;
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

