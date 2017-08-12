#####################################################################################################
# Fichero: (Metrics::Base::udp_pkts.pm)   $Id$
# Descripcion: Metrics::Base::udp_pkts.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base::udp_pkts;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('udp_pkts', 'MIB-II', 300, 'PAQUETES UDP', 'Datagramas UDP IN|Datagramas UDP OUT','.1.3.6.1.2.1.7.1.0|.1.3.6.1.2.1.7.4.0','');
#----------------------------------------------------------------------------
=head1 udp_pkts

 OIDs: .1.3.6.1.2.1.7.1.0|.1.3.6.1.2.1.7.4.0
 TIPO: STD_AREA
 VALUES: Datagramas UDP IN|Datagramas UDP OUT
 VLABEL: num
 DESCR: Numero de datagramas UDP IN/OUT.

=cut

#----------------------------------------------------------------------------
sub udp_pkts {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_AREA</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>num</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>Datagramas UDP IN|Datagramas UDP OUT</values>
         <oid>.1.3.6.1.2.1.7.1.0|.1.3.6.1.2.1.7.4.0</oid>
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

   @Metrics::Base::OIDs=qw( .1.3.6.1.2.1.7.1.0 .1.3.6.1.2.1.7.4.0 );
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

	my $DESC='Trafico UDP';
   my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	$m=~s/--SEVERITY--/$Metrics::Base::METRIC{severity}/g;

   #my $label="Trafico UDP ($Metrics::Base::METRIC{name})";
	#$Metrics::Base::Desc{$Metrics::Base::METRIC{mname}}->{label}=$label;

   return $m;

}


1;
__END__


