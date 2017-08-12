#####################################################################################################
# Fichero: (Metrics::Base::users_cnt_mibhost.pm)   $Id$
# Descripcion: Metrics::Base::users_cnt_mibhost.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base::users_cnt_mibhost;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('users_cnt_mibhost', 'MIB-HOST - rfc2790',300, 'NUMERO DE USUARIOS', 'Numero de Usuarios','.1.3.6.1.2.1.25.1.5.0','');
#----------------------------------------------------------------------------
=head1 users_cnt_mibhost

 OIDs: .1.3.6.1.2.1.25.1.5.0 (hrSystemNumUsers)
 TIPO: STD_AREA
 VALUES: Numero de Usuarios
 VLABEL: usuarios
 DESCR: Numero de usuarios concurrentes en el sistema

=cut

#----------------------------------------------------------------------------
sub users_cnt_mibhost {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_AREA</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>usuarios</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>Numero de Usuarios</values>
         <oid>.1.3.6.1.2.1.25.1.5.0</oid>
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

   @Metrics::Base::OIDs=qw( .1.3.6.1.2.1.25.1.5.0 );
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

	my $DESC='Numero de Usuarios';
   my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	$m=~s/--SEVERITY--/$Metrics::Base::METRIC{severity}/g;

   #my $label="Numero de Usuarios ($Metrics::Base::METRIC{name})";
	#$Metrics::Base::Desc{$Metrics::Base::METRIC{mname}}->{label}=$label;

   return $m;

}


1;
__END__
