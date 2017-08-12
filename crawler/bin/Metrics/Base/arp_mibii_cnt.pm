#####################################################################################################
# Fichero: (Metrics::Base::arp_mibii_cnt.pm)   $Id$
# Descripcion: Metrics::Base::arp_mibii_cnt.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base::arp_mibii_cnt;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
#insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('arp_mibii_cnt', 'MIB-II', 3600, 'VECINOS EN LAN - ARP', 'Entradas en la tabla ARP','ipNetToMediaNetAddress_ipNetToMediaPhysAddress','');
#----------------------------------------------------------------------------

=head1 arp_mibii_cnt 

 OIDs: ipNetToMediaNetAddress_ipNetToMediaPhysAddress 
 TIPO: STD_BASE
 VALUES: Entradas en la tabla de ARP
 VLABEL: Entradas ARP
 DESCR: Numero de entradas en la tabla de ARP del equipo. Permite ver los vecinos en una LAN.

=cut

#----------------------------------------------------------------------------
sub arp_mibii_cnt {
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>Entradas ARP</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_walk</module>
         <values>Entradas en la tabla de ARP</values>
         <oid>ipNetToMediaNetAddress_ipNetToMediaPhysAddress</oid>
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

   @Metrics::Base::OIDs=qw( ipNetToMediaNetAddress ipNetToMediaPhysAddress );
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
	$Metrics::Base::Error='';

	# El chequeo de la metrica se hace con get_snmp_vector porque es una tabla
   # Los parametros de entrada y la forma de detectar si hay error cambian
	# respecto de check_snmp_oid !!!!!
   #my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
	my %snmpcfg=();
   $snmpcfg{host_ip}=$device->{ip};
   $snmpcfg{community}=$device->{community} || 'public';
   $snmpcfg{version}= $device->{version} || '1';
	$snmpcfg{oid}=join ('_',@Metrics::Base::OIDs);
	$snmpcfg{last}='ipNetToMediaType';
   &Metrics::Base::get_snmp_vector($device,\%snmpcfg);
	my $error=$Metrics::Base::SNMP->err_num();
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

	my $DESC='Vecinos en LAN';
   my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
	$m=~s/--SEVERITY--/$Metrics::Base::METRIC{severity}/g;

   #my $label="Vecinos en LAN ($Metrics::Base::METRIC{name})";
	#$Metrics::Base::Desc{$Metrics::Base::METRIC{mname}}->{label}=$label;

   return $m;

}

1;
__END__
