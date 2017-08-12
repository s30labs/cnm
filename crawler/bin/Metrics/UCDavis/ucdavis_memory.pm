#####################################################################################################
# Fichero: (Metrics::UCDavis::ucdavis_cpu)   $Id$
# Descripcion: Metrics::UCDavis::ucdavis_cpu
# Set Tab=3
#####################################################################################################
package Metrics::UCDavis::ucdavis_cpu;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
#ssCpuRawUser OBJECT-TYPE
#    SYNTAX      Counter32
#    MAX-ACCESS  read-only
#    STATUS      current
#    DESCRIPTION
#        "user CPU time."
#    ::= { systemStats 50 }
#
#ssCpuRawSystem OBJECT-TYPE
#    SYNTAX      Counter32
#    MAX-ACCESS  read-only
#    STATUS      current
#    DESCRIPTION
#        "system CPU time."
#    ::= { systemStats 52 }
#
#ssCpuRawIdle OBJECT-TYPE
#    SYNTAX      Counter32
#    MAX-ACCESS  read-only
#    STATUS      current
#    DESCRIPTION
#        "idle CPU time."
#    ::= { systemStats 53 }
#
#----------------------------------------------------------------------------
#sql insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid,oidn,oid_info) values ('ucdavis_cpu', 'UCDAVIS', 300, 'USO DE CPU', 'User|System|Idle', '.1.3.6.1.4.1.2021.11.50.0|.1.3.6.1.4.1.2021.11.52.0|.1.3.6.1.4.1.2021.11.53.0', '','ssCpuRawUser|ssCpuRawSystem|ssCpuRawIdle','UCD-SNMP-MIB|ssCpuRawUser|Counter32|user CPU time.<br>UCD-SNMP-MIB|ssCpuRawSystem|Counter32|system CPU time.<br>UCD-SNMP-MIB|ssCpuRawIdle|Counter32|idle CPU time.<br>');

#----------------------------------------------------------------------------
sub ucdavis_cpu {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
			<subtype>--SUBTYPE--</subtype>
         <vlabel>num</vlabel>
			<label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>User|System|Idle</values>
         <oid>.1.3.6.1.4.1.2021.11.50.0|.1.3.6.1.4.1.2021.11.52.0|.1.3.6.1.4.1.2021.11.53.0</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>COUNTER</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.4.1.2021.11.50.0 .1.3.6.1.4.1.2021.11.52.0 .1.3.6.1.4.1.2021.11.53.0);
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

	my $DESC='Uso de CPU';
	my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	#$Metrics::Base::Desc{$Base::METRIC{mname}}->{label}="Uso de CPU ($Base::METRIC{name})";
   return $m;
}

1;
__END__

