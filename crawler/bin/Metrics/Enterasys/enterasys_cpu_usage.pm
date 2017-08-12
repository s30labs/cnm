#####################################################################################################
# Fichero: (Metrics::Enterasys::enterasys_cpu_usage)   $Id$
# Descripcion: Metrics::Enterasys::enterasys_cpu_usage
# Set Tab=3
#####################################################################################################
package Metrics::Enterasys::enterasys_cpu_usage;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

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
#insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('enterasys_cpu_usage', 'ENTERASYS', 300, 'USO DE CPU', 'Uso de CPU', '.1.3.6.1.4.1.52.2501.1.270.2.1.1.2.1', '');
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
			<subtype>--SUBTYPE--</subtype>
         <vlabel>percent</vlabel>
			<label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>Uso de CPU</values>
         <oid>.1.3.6.1.4.1.52.2501.1.270.2.1.1.2.1</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>GAUGE</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.4.1.52.2501.1.270.2.1.1.2.1);
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

	my $DESC='Uso actual de CPU';
	my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	#$Metrics::Base::Desc{$Base::METRIC{mname}}->{label}="Uso actual de CPU ($Base::METRIC{name})";
   return $m;
}

1;
__END__

