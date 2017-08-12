#####################################################################################################
# Fichero: (Metrics::Enterasys.pm)   $Id$
# Descripcion: Metrics::Enterasys.pm
# Set Tab=3
#####################################################################################################
package Metrics::Enterasys;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

=head1 METRICAS DEFINIDAS

=cut

#----------------------------------------------------------------------------
# Uso de CPU
# 
#   capCPUCurrentUtilization OBJECT-TYPE
#       SYNTAX      INTEGER (0..100)
#       MAX-ACCESS  read-only
#       STATUS      current
#       DESCRIPTION
#               "The CPU utilization expressed as an integer percentage.
#                This is calculated over the last 5 seconds at a 0.1 second
#                interval as a simple average."
#
#       ::= { capCPUEntry 2 }
#----------------------------------------------------------------------------
=head1 enterasys_cpu_usage

 OIDs: .1.3.6.1.4.1.52.2501.1.270.2.1.1.2.1
 TIPO: STD_BASE
 VALUES: Uso de CPU
 VLABEL: Porcentaje
 DESCR: Uso de CPU conmo porcentaje entero (calculado sobre los ultimos 5 segs.

=cut
#----------------------------------------------------------------------------
sub enterasys_cpu_usage {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
         <vlabel>percent</vlabel>
         <label>Uso actual de CPU (--HOST_NAME--)</label>
         <module>mod_snmp_get</module>
         <values>Uso de CPU</values>
         <oid>.1.3.6.1.4.1.52.2501.1.270.2.1.1.2.1</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>GAUGE</mode>
			<top_value>1</top_value>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.4.1.52.2501.1.270.2.1.1.2.1);
   @Metrics::Base::IIDs=();
   %Metrics::Base::Desc=();

	my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$txml);
	$Metrics::Base::Desc{$Base::METRIC{mname}}->{label}="Uso actual de CPU ($Base::METRIC{name})";
   return $m;
}



#----------------------------------------------------------------------------
# Flujos de Nivel 3
# 
#   capCPUL3Learned OBJECT-TYPE
#       SYNTAX      Counter32
#       MAX-ACCESS  read-only
#       STATUS      current
#       DESCRIPTION
#               "The total number of new layer 3 flows the CPU has processed and
#                programmed into the Layer 3 hardware flow tables. 
#                Layer 3 flows are packets for IP or IPX protocols that will
#                be routed from one subnet to another. Bridged flows or IP and
#                IPX flows that originate and terminate in the same subnet
#                are accounted for by capCPUL2Learned object."
#       ::= { capCPUEntry 3 }
#
#   capCPUL3Aged OBJECT-TYPE
#       SYNTAX      Counter32
#       MAX-ACCESS  read-only
#       STATUS      current
#       DESCRIPTION
#               "The total number of Layer 3flows that have been
#                removed from the layer 3 hardware flow tables across 
#                all modules by the Layer 3 aging task. This number may
#                increase quickly if routing protocols are not stable. Removal
#                or insertion of routes into the forwarding table will cause
#                premature aging of flows. Flows are normally aged/removed 
#                from the hardware when there are no more packets being sent
#                for a defined time period.  
#                This counter is cumulative from the time the system started."
#       ::= { capCPUEntry 4 }
#----------------------------------------------------------------------------
=head1 enterasys_flow3

 OIDs: .1.3.6.1.4.1.52.2501.1.270.2.1.1.3.1|.1.3.6.1.4.1.52.2501.1.270.2.1.1.4.1
 TIPO: STD_BASE
 VALUES: Flujos de nivel 3 Aprendidos|Flujos de nivel 3 Caducados
 VLABEL: Numero
 DESCR: Flujos de nivel 3 (aprendidos/caducados)

=cut
#----------------------------------------------------------------------------
sub enterasys_flow3 {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
         <vlabel>num</vlabel>
         <label>Distribucion de Flujos de Nivel 3 (--HOST_NAME--)</label>
         <module>mod_snmp_get</module>
         <values>F3 Aprendidos|F3 Caducados</values>
         <oid>.1.3.6.1.4.1.52.2501.1.270.2.1.1.3.1|.1.3.6.1.4.1.52.2501.1.270.2.1.1.4.1</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>COUNTER</mode>
			<top_value>1</top_value>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.4.1.52.2501.1.270.2.1.1.3.1|.1.3.6.1.4.1.52.2501.1.270.2.1.1.4.1);
   @Metrics::Base::IIDs=();
   %Metrics::Base::Desc=();

	my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$txml);
	$Metrics::Base::Desc{$Base::METRIC{mname}}->{label}="Flujos de Nivel 3 ($Base::METRIC{name})";
   return $m;
}



#----------------------------------------------------------------------------
# Flujos de Nivel 2
# 
#   capCPUL2Learned OBJECT-TYPE
#       SYNTAX      Counter32
#       MAX-ACCESS  read-only
#       STATUS      current
#       DESCRIPTION
#               "The number of L2 flows or addresses learned. 
#                The intended result here is to see how many stations 
#                attempt to establish switched communication through the SSR."
#       ::= { capCPUEntry 5 }
#
#   capCPUL2Aged OBJECT-TYPE
#       SYNTAX      Counter32
#       MAX-ACCESS  read-only
#       STATUS      current
#       DESCRIPTION
#               "The total number of L2 addresses or flows aged out.  Hosts
#                that end switched communication through the SSR are aged out
#                every 15 seconds."
#       ::= { capCPUEntry 6 }
#
#----------------------------------------------------------------------------
=head1 enterasys_flow2

 OIDs: .1.3.6.1.4.1.52.2501.1.270.2.1.1.5.1|.1.3.6.1.4.1.52.2501.1.270.2.1.1.6.1
 TIPO: STD_BASE
 VALUES: Flujos de nivel 2 Aprendidos|Flujos de nivel 2 Caducados
 VLABEL: Numero
 DESCR: Flujos de nivel 2 (aprendidos/caducados)

=cut
#----------------------------------------------------------------------------
sub enterasys_flow2 {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
         <vlabel>num</vlabel>
         <label>Distribucion de Flujos de Nivel 2 (--HOST_NAME--)</label>
         <module>mod_snmp_get</module>
         <values>F2 Aprendidos|F2 Caducados</values>
         <oid>.1.3.6.1.4.1.52.2501.1.270.2.1.1.5.1|.1.3.6.1.4.1.52.2501.1.270.2.1.1.6.1</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>COUNTER</mode>
			<top_value>1</top_value>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.4.1.52.2501.1.270.2.1.1.5.1|.1.3.6.1.4.1.52.2501.1.270.2.1.1.6.1);
   @Metrics::Base::IIDs=();
   %Metrics::Base::Desc=();

	my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$txml);
	$Metrics::Base::Desc{$Base::METRIC{mname}}->{label}="Flujos de Nivel 2 ($Base::METRIC{name})";
   return $m;
}



1;
__END__

