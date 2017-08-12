#####################################################################################################
# Fichero: (Metrics::Nortel::nortel_memory.pm)   $Id$
# Descripcion: Metrics::Nortel::nortel_memory.pm
# Set Tab=3
#####################################################################################################
package Metrics::Nortel::nortel_memory;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('nortel_memory', 'NORTEL', 300, 'USO DE MEMORIA', ' Bytes libres|Bytes Totales','.1.3.6.1.4.1.18.3.3.2.5.7.1.6.1|.1.3.6.1.4.1.18.3.3.2.5.7.1.7.1','');
#----------------------------------------------------------------------------
=head1 nortel_memory

 OIDs: .1.3.6.1.4.1.18.3.3.2.5.7.1.6.1/.1.3.6.1.4.1.18.3.3.2.5.7.1.7.1
 TIPO: STD_BASE
 VALUES: Bytes libres/Bytes Totales
 VLABEL: bytes
 DESCR: Numero total de bytes libres/totales en el slot.

=cut

#----------------------------------------------------------------------------
sub nortel_memory {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>bytes</vlabel>
			<label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>Bytes libres|Bytes totales</values>
         <oid>.1.3.6.1.4.1.18.3.3.2.5.7.1.6.1|.1.3.6.1.4.1.18.3.3.2.5.7.1.7.1</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>GAUGE</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw( .1.3.6.1.4.1.18.3.3.2.5.7.1.6.1 .1.3.6.1.4.1.18.3.3.2.5.7.1.7.1 );
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

	my $DESC='"Memoria';
   my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	#$Metrics::Base::Desc{$Base::METRIC{mname}}->{label}="Memoria ($Base::METRIC{name})";
   return $m;
}

1;
__END__
