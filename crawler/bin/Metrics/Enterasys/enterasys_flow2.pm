#####################################################################################################
# Fichero: (Metrics::Enterasys::enterasys_flow2)   $Id$
# Descripcion: Metrics::Enterasys::enterasys_flow2
# Set Tab=3
#####################################################################################################
package Metrics::Enterasys::enterasys_flow2;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

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
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('enterasys_flow2', 'ENTERASYS', 300, 'FLUJOS DE NIVEL2', ' Flujos de nivel 2 Aprendidos|Flujos de nivel 2 Caducados', '.1.3.6.1.4.1.52.2501.1.270.2.1.1.5.1|.1.3.6.1.4.1.52.2501.1.270.2.1.1.6.1', '');
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
			<subtype>--SUBTYPE--</subtype>
         <vlabel>num</vlabel>
			<label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>F2 Aprendidos|F2 Caducados</values>
         <oid>.1.3.6.1.4.1.52.2501.1.270.2.1.1.5.1|.1.3.6.1.4.1.52.2501.1.270.2.1.1.6.1</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>COUNTER</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.4.1.52.2501.1.270.2.1.1.5.1|.1.3.6.1.4.1.52.2501.1.270.2.1.1.6.1);
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

	my $DESC='Flujos de Nivel 2';
	my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	#$Metrics::Base::Desc{$Base::METRIC{mname}}->{label}="Flujos de Nivel 2 ($Base::METRIC{name})";
   return $m;
}



1;
__END__

