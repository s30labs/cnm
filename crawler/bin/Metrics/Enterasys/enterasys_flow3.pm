#####################################################################################################
# Fichero: (Metrics::Enterasys::enterasys_flow3)   $Id$
# Descripcion: Metrics::Enterasys::enterasys_flow3
# Set Tab=3
#####################################################################################################
package Metrics::Enterasys::enterasys_flow3;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

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
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('enterasys_flow3', 'ENTERASYS', 300, 'FLUJOS DE NIVEL3', ' Flujos de nivel 3 Aprendidos|Flujos de nivel 3 Caducados', '.1.3.6.1.4.1.52.2501.1.270.2.1.1.3.1|.1.3.6.1.4.1.52.2501.1.270.2.1.1.4.1', '');
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
			<subtype>--SUBTYPE--</subtype>
         <vlabel>num</vlabel>
			<label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>F3 Aprendidos|F3 Caducados</values>
         <oid>.1.3.6.1.4.1.52.2501.1.270.2.1.1.3.1|.1.3.6.1.4.1.52.2501.1.270.2.1.1.4.1</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>COUNTER</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.4.1.52.2501.1.270.2.1.1.3.1|.1.3.6.1.4.1.52.2501.1.270.2.1.1.4.1);
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

	my $DESC='Flujos de Nivel 3';
	my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	#$Metrics::Base::Desc{$Base::METRIC{mname}}->{label}="Flujos de Nivel 3 ($Base::METRIC{name})";
   return $m;
}

1;
__END__

