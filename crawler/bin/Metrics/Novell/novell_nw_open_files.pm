#####################################################################################################
# Fichero: (Metrics::Novell::novell_nw_open_files.pm)   $Id$
# Descripcion: Metrics::Novell::novell_nw_open_files.pm
# Set Tab=3
#####################################################################################################
package Metrics::Novell::novell_nw_open_files;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# INSERT INTO cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid,label,vlabel,community,mode,mtype,top_value) VALUES ('novell_nw_open_files','NOVELL',300,'FICHEROS EN USO','Ficheros abiertos','.1.3.6.1.4.1.23.2.28.2.7','',NULL,NULL,'public',NULL,NULL,NULL);
#----------------------------------------------------------------------------
=head1 novell_nw_open_files

 OIDs: ..1.3.6.1.4.1.23.2.28.2.7
 TIPO: STD_BASE
 VALUES: Ficheros Abiertos
 VLABEL: num
 DESCR: Ficheros Abiertos en el Servidor

=cut

#----------------------------------------------------------------------------
sub novell_nw_open_files{
my ($device,$rcfg,$subtype)=@_;
my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>num</vlabel>
			<label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>Ficheros Abiertos</values>
         <oid>.1.3.6.1.4.1.23.2.28.2.7.0</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>COUNTER</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.4.1.23.2.28.2.7.0);
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Error='';

   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }
	
	my $DESC='Ficheros en Uso';	
   my $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$DESC,$txml);
   #$Metrics::Base::Desc{$Base::Base::METRIC{mname}}->{label}="Ficheros en Uso ($Base::Base::METRIC{name})";

   return $m;

}	

1;
__END__

