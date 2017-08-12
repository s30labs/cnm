#####################################################################################################
# Fichero: (Metrics::CheckPoint::checkpoint_numconex)   $Id$
# Descripcion: Metrics::CheckPoint::checkpoint_numconex
# Set Tab=3
#####################################################################################################
package Metrics::CheckPoint::checkpoint_numconex;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# Numero de Conexiones 
#
#      fwNumConn OBJECT-TYPE
#	  		  SYNTAX  INTEGER
#	  		  ACCESS  read-only
#	  		  STATUS  mandatory
#	  		  DESCRIPTION
#	  		          "Number of connections"
#	  		  ::= { fwPolicyStat 3 }
#
#----------------------------------------------------------------------------
#sql insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid,oidn,oid_info) values ('checkpoint_numconex', 'CHECKPOINT', 300, 'NUMERO DE CONEXIONES', 'fwNumConn', '.1.3.6.1.4.1.2620.1.1.25.3.0', '','fwNumConn','CHECKPOINT-MIB|fwNumConn|INTEGER|Number of connections.<br>');

#----------------------------------------------------------------------------
=head1 checkpoint_numconex

 OIDs: .1.3.6.1.4.1.2620.1.1.25.3.0
 TIPO: STD_BASE
 VALUES: Numero de Conexiones
 VLABEL: Num.
 DESCR: Numero de Conexiones.

=cut
#----------------------------------------------------------------------------
sub checkpoint_numconex {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
			<subtype>--SUBTYPE--</subtype>
         <vlabel>num</vlabel>
			<label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>fwNumConn</values>
         <oid>.1.3.6.1.4.1.2620.1.1.25.3.0</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>GAUGE</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.4.1.2620.1.1.25.3.0);
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

	my $DESC='Numero de Conexiones';
	my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	#$Metrics::Base::Desc{$Base::METRIC{mname}}->{label}="Numero de Conexiones ($Base::METRIC{name})";
   return $m;
}

1;
__END__

