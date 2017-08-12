#####################################################################################################
# Fichero: (Metrics::CheckPoint::checkpoint_peakconex)   $Id$
# Descripcion: Metrics::CheckPoint::checkpoint_peakconex
# Set Tab=3
#####################################################################################################
package Metrics::CheckPoint::checkpoint_peakconex;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# Pico de Conexiones 
#
#	  fwPeakNumConn OBJECT-TYPE
#	  		  SYNTAX  INTEGER
#	  		  ACCESS  read-only
#	  		  STATUS  mandatory
#	  		  DESCRIPTION
#	  		          "Peak number of connections"
#	  		  ::= { fwPolicyStat 4 }	
#
#----------------------------------------------------------------------------
#sql insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid,oidn,oid_info) values ('checkpoint_peakconex', 'CHECKPOINT', 300, 'MAXIMO NUMERO DE CONEXIONES', 'fwPeakNumConn', '.1.3.6.1.4.1.2620.1.1.25.4.0', '','fwPeakNumConn','CHECKPOINT-MIB|fwPeakNumConn|INTEGER|Peak number of connections');

#----------------------------------------------------------------------------
=head1 checkpoint_peakconex

 OIDs: .1.3.6.1.4.1.2620.1.1.25.4.0
 TIPO: STD_BASE
 VALUES: Maximo numero de Conexiones
 VLABEL: Num.
 DESCR: Maximo Numero de Conexiones.

=cut
#----------------------------------------------------------------------------
sub checkpoint_peakconex {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
			<subtype>--SUBTYPE--</subtype>
         <vlabel>num</vlabel>
			<label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>fwPeakNumConn</values>
         <oid>.1.3.6.1.4.1.2620.1.1.25.4.0</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>GAUGE</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.4.1.2620.1.1.25.4.0);
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

	my $DESC='Maximo numero de Conexiones';
	my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	#$Metrics::Base::Desc{$Base::METRIC{mname}}->{label}="Numero de Conexiones ($Base::METRIC{name})";
   return $m;
}

1;
__END__

