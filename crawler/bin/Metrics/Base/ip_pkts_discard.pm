#####################################################################################################
# Fichero: (Metrics::Base::ip_pkts_discard.pm)   $Id$
# Descripcion: Metrics::Base::ip_pkts_discard.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base::ip_pkts_discard;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('ip_pkts_discard', 'MIB-II', 300, 'PAQUETES IP DESCARTADOS', 'PKTS in|PKTS out','.1.3.6.1.2.1.4.8.0|.1.3.6.1.2.1.4.11.0','');
#----------------------------------------------------------------------------
=head1 ip_pkts_discard

 OIDs: .1.3.6.1.2.1.4.8.0|.1.3.6.1.2.1.4.11.0
 TIPO: STD_BASE
 VALUES: Pkts descartados IN|Pkts descartados OUT
 VLABEL: num
 DESCR: Numero de paquetes descartados a nivel IP en entrada y salida.

=cut

#----------------------------------------------------------------------------
sub ip_pkts_discard {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
			<subtype>--SUBTYPE--</subtype>
         <vlabel>num</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>Pkts descartados IN|Pkts descartados OUT</values>
         <oid>.1.3.6.1.2.1.4.8.0|.1.3.6.1.2.1.4.11.0</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
         <version>--SNMP_VERSION--</version>
         <mode>GAUGE</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
			<severity>--SEVERITY--</severity>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw( .1.3.6.1.2.1.4.8.0 .1.3.6.1.2.1.4.11.0 );
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

	my $DESC='Paquetes IP descartados';
   my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	$m=~s/--SEVERITY--/$Metrics::Base::METRIC{severity}/g;

	#my $label="Paquetes IP descartados ($Metrics::Base::METRIC{name})";
	#$Metrics::Base::Desc{$Metrics::Base::METRIC{mname}}->{label}=$label;

   return $m;
}



1;
__END__

