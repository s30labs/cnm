#####################################################################################################
# Fichero: (Metrics::Nortel::nortel_cpu.pm)   $Id$
# Descripcion: Metrics::Nortel::nortel_cpu.pm
# Set Tab=3
#####################################################################################################
package Metrics::Nortel::nortel_cpu;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('nortel_cpu', 'NORTEL', 300, 'USO DE CPU', ' Porcentaje de uso de CPU','.1.3.6.1.4.1.18.3.3.2.5.7.1.2.1','');
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
			<label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>Uso de CPU (csec)</values>
         <oid>.1.3.6.1.4.1.18.3.3.2.5.7.1.2.1</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>COUNTER</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw( .1.3.6.1.4.1.18.3.3.2.5.7.1.2.1 );
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }
	
	my $DESC='CPU';
   my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	#$Metrics::Base::Desc{$Metrics::Base::METRIC{mname}}->{label}="CPU ($Metrics::Base::METRIC{name})";
   return $m;
}

1;
__END__
