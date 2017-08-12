#####################################################################################################
# Fichero: (Metrics::Base::pkts_discard_mibii_if.pm)   $Id$
# Descripcion: Metrics::Base::pkts_discard_mibii_if.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base::pkts_discard_mibii_if;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('pkts_discard_mibii_if', 'MIB-II', 300, 'PAQUETES DESCARTADOS EN INTERFAZ', 'pkts descartados in|pkts descartados out','.1.3.6.1.2.1.2.2.1.13.IID|.1.3.6.1.2.1.2.2.1.19.IID','./support/iid_mibii_if');
#----------------------------------------------------------------------------
=head1 pkts_discard_mibii_if

 OIDs: .1.3.6.1.2.1.2.2.1.13.IID|.1.3.6.1.2.1.2.2.1.19.IID (ifInDiscards|ifOutDiscards)
 TIPO: STD_AREA
 VALUES: pkts descartados in|pkts descartados out
 VLABEL: pkts
 DESCR: Paquetes descartados en entrada y salida

=cut

#----------------------------------------------------------------------------
sub pkts_discard_mibii_if {
my ($device,$rcfg,$subtype)=@_;
my %snmpcfg=();
my $M='';

my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_AREA</mtype>
			<subtype>--SUBTYPE--</subtype>
         <vlabel>pkts</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>--METRIC_VAL_IN_DISCARD--|--METRIC_VAL_OUT_DISCARD--</values>
         <oid>.1.3.6.1.2.1.2.2.1.13.--METRIC_IID--|.1.3.6.1.2.1.2.2.1.19.--METRIC_IID--</oid>
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

   @Metrics::Base::OIDs=qw( .1.3.6.1.2.1.2.2.1.13 .1.3.6.1.2.1.2.2.1.19 );
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
	$Metrics::Base::Info='';

	$snmpcfg{oid}='ifDescr_ifType_ifInDiscards_ifOutDiscards';
   $snmpcfg{last}='ifOutErrors';
   $Metrics::Base::Error='';

   my $res=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
   if (! defined $res) { return undef; }

   for my $l ( @$res ) {
      my ($id,$descr1,$type,$discard_in,$discard_out)=split(':@:',$l);
      my $descr2=$Metrics::Base::SNMP->hex2ascii($descr1);
      my $descr = escape($descr2);

      #my $skip=0;
      #foreach my $di (@SKIP_INTERFACES) { if ($descr =~ /$di/i) {$skip=1; last;} }
      #if ($skip) {next;}

		#if ( ($Metrics::Base::Subset) && (&Metrics::Base::skip_interface($id,$type)) ) {next;}

		my $DESC="Paquetes descartados en  $descr";
		my $m=&Metrics::Base::m2txml_iid($device,$rcfg,$subtype,$DESC,$txml,$id,$type,\&Metrics::Base::get_status_mib2_interfaces);

      #if (&Metrics::Base::skip_interface($id,$type)) { $m=~s/--STATUS--/1/g; }
      #else { $m=~s/--STATUS--/0/g; }

		#my $label="Paquetes descartados en  $descr ($Metrics::Base::METRIC{name})";

      #$m=~s/--METRIC_LABEL--/$label/g;
      $m=~s/--METRIC_VAL_IN_DISCARD--/Pkts descartados IN ($id)/g;
      $m=~s/--METRIC_VAL_OUT_DISCARD--/Pkts descartados OUT ($id)/g;
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

