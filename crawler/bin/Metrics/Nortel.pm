#####################################################################################################
# Fichero: (Metrics::Nortel.pm)   $Id$
# Descripcion: Metrics::Nortel.pm
# Set Tab=3
#####################################################################################################
package Metrics::Nortel;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

=head1 METRICAS DEFINIDAS

=cut

#----------------------------------------------------------------------------
# Metricas de uso de memoria/CPU
#----------------------------------------------------------------------------
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
         <label>Memoria (--HOST_NAME--)</label>
         <module>mod_snmp_get</module>
         <values>Bytes libres|Bytes totales</values>
         <oid>.1.3.6.1.4.1.18.3.3.2.5.7.1.6.1|.1.3.6.1.4.1.18.3.3.2.5.7.1.7.1</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>GAUGE</mode>
			<top_value>1</top_value>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw( .1.3.6.1.4.1.18.3.3.2.5.7.1.6.1 .1.3.6.1.4.1.18.3.3.2.5.7.1.7.1 );
   @Metrics::Base::IIDs=();
   %Metrics::Base::Desc=();

   my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$txml);
	$Metrics::Base::Desc{$Base::METRIC{mname}}->{label}="Memoria ($Base::METRIC{name})";
   return $m;
}

#----------------------------------------------------------------------------
=head1 nortel_cpu

 OIDs: .1.3.6.1.4.1.18.3.3.2.5.7.1.2.1 (wfResourceTotalCpuUsed)
 TIPO: STD_BASE
 VALUES: Uso de CPU
 VLABEL: porcentaje
 DESCR: Cantidad de CPU usada en csegs

=cut

#----------------------------------------------------------------------------
sub nortel_cpu {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>Porcentaje</vlabel>
         <label>CPU (--HOST_NAME--)</label>
         <module>mod_snmp_get</module>
         <values>Uso de CPU (csec)</values>
         <oid>.1.3.6.1.4.1.18.3.3.2.5.7.1.2.1</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>GAUGE</mode>
			<top_value>1</top_value>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw( .1.3.6.1.4.1.18.3.3.2.5.7.1.2.1 );
   @Metrics::Base::IIDs=();
   %Metrics::Base::Desc=();

   my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$txml);
	$Metrics::Base::Desc{$Base::METRIC{mname}}->{label}="CPU ($Base::METRIC{name})";
   return $m;
}

1;
__END__
