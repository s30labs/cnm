#####################################################################################################
# Fichero: (Metrics::Base::tcp_estab.pm)   $Id$
# Descripcion: Metrics::Base::tcp_estab.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base::tcp_estab;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('tcp_estab', 'MIB-II', 300, 'SESIONES TCP ESTABLECIDAS', 'Sesiones TCP','.1.3.6.1.2.1.6.9.0','');
#----------------------------------------------------------------------------
=head1 tcp_estab

 OIDs: .1.3.6.1.2.1.6.9.0
 TIPO: STD_AREA
 VALUES: Sesiones TCP
 VLABEL: num
 DESCR: Numero de sesiones  total de bytes usados/libres en el pool de memoria.

=cut

#----------------------------------------------------------------------------
sub tcp_estab {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_AREA</mtype>
			<subtype>--SUBTYPE--</subtype>
         <vlabel>num</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>Sesiones TCP</values>
         <oid>.1.3.6.1.2.1.6.9.0</oid>
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

   @Metrics::Base::OIDs=qw( .1.3.6.1.2.1.6.9.0 );
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
	$Metrics::Base::Error='';

	my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
	if ($error) { 
		$Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]"; 
		return '';
	}
	my $DESC='Sesiones TCP establecidas';
   my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	$m=~s/--SEVERITY--/$Metrics::Base::METRIC{severity}/g;

   #my $label="Sesiones TCP establecidas ($Metrics::Base::METRIC{name})";
	#$Metrics::Base::Desc{$Metrics::Base::METRIC{mname}}->{label}=$label;

   return $m;
}


1;
__END__

