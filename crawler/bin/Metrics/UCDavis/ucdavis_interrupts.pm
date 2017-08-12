#####################################################################################################
# Fichero: (Metrics::UCDavis::ucdavis_interrupts)   $Id$
# Descripcion: Metrics::UCDavis::ucdavis_interrupts
# Set Tab=3
#####################################################################################################
package Metrics::UCDavis::ucdavis_interrupts;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
#ssRawInterrupts OBJECT-TYPE
#    SYNTAX      Counter32
#    MAX-ACCESS  read-only
#    STATUS      current
#    DESCRIPTION
#        "Number of interrupts processed"
#    ::= { systemStats 59 }
#
#ssRawContexts OBJECT-TYPE
#    SYNTAX      Counter32
#    MAX-ACCESS  read-only
#    STATUS      current
#    DESCRIPTION
#        "Number of context switches"
#    ::= { systemStats 60 }
#
#----------------------------------------------------------------------------
#sql insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid,oidn,oid_info) values ('ucdavis_interrupts', 'UCDAVIS', 300, 'USO DE INTERRUPCIONES', 'Interrupciones|Cambios de Contexto', '.1.3.6.1.4.1.2021.11.59.0|.1.3.6.1.4.1.2021.11.60.0', '','ssRawInterrupts|ssRawContexts','UCD-SNMP-MIB|ssRawInterrupts|Counter32|Number of interrupts processed.<br>UCD-SNMP-MIB|ssRawContexts|Counter32|Number of context switches.<br>');

#----------------------------------------------------------------------------
sub ucdavis_interrupts {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
			<subtype>--SUBTYPE--</subtype>
         <vlabel>num</vlabel>
			<label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>Interrupciones|Cambios de Contexto</values>
         <oid>.1.3.6.1.4.1.2021.11.59.0|.1.3.6.1.4.1.2021.11.60.0</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>COUNTER</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.4.1.2021.11.59.0 .1.3.6.1.4.1.2021.11.60.0);
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

	my $DESC='Uso de Interrupciones';
	my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	#$Metrics::Base::Desc{$Base::METRIC{mname}}->{label}="Uso de CPU ($Base::METRIC{name})";
   return $m;
}

1;
__END__

