#####################################################################################################
# Fichero: (Metrics::Base::proc_cnt_mibhost.pm)   $Id$
# Descripcion: Metrics::Base::proc_cnt_mibhost.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base::proc_cnt_mibhost;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('proc_cnt_mibhost', 'MIB-HOST - rfc2790',300, 'NUMERO DE PROCESOS', 'Numero de Procesos','.1.3.6.1.2.1.25.1.6.0','');
#----------------------------------------------------------------------------
=head1 proc_cnt_mibhost

 OIDs: .1.3.6.1.2.1.25.1.6.0 (hrSystemProcesses)
 TIPO: STD_AREA
 VALUES: Numero de Procesos
 VLABEL: procesos
 DESCR: Numero de procesos ejecutandose en el sistema

=cut

#----------------------------------------------------------------------------
sub  proc_cnt_mibhost {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_AREA</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>procesos</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>Numero de Procesos</values>
         <oid>.1.3.6.1.2.1.25.1.6.0</oid>
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

   @Metrics::Base::OIDs=qw( .1.3.6.1.2.1.25.1.6.0 );
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

	my $DESC='Numero de Procesos';
   my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	$m=~s/--SEVERITY--/$Metrics::Base::METRIC{severity}/g;

   #my $label="Numero de Procesos ($Metrics::Base::METRIC{name})";
	#$Metrics::Base::Desc{$Metrics::Base::METRIC{mname}}->{label}=$label;

   return $m;
}


1;
__END__
