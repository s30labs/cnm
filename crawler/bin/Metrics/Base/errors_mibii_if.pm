#####################################################################################################
# Fichero: (Metrics::Base::errors_mibii_if.pm)   $Id$
# Descripcion: Metrics::Base::errors_mibii_if.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base::errors_mibii_if;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
#insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('errors_mibii_if', 'MIB-II', 300, 'ERRORES EN INTERFAZ', 'errores in|errores out','.1.3.6.1.2.1.2.2.1.14.IID|.1.3.6.1.2.1.2.2.1.20.IID','./support/iid_mibii_if');
#----------------------------------------------------------------------------
=head1 errors_mibii_if

 OIDs: .1.3.6.1.2.1.2.2.1.14.METRIC_IID|.1.3.6.1.2.1.2.2.1.20.IID (ifInErrors|IfOutErrors)
 TIPO: STD_AREA
 VALUES: errores in|errores out
 VLABEL: errores
 DESCR: Errores de entrada y salida a nivel de interfaz

=cut

#----------------------------------------------------------------------------
sub errors_mibii_if {
my ($device,$rcfg,$subtype)=@_;
my %snmpcfg=();
my $M='';

my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_AREA</mtype>
			<subtype>--SUBTYPE--</subtype>
         <vlabel>errores</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>--METRIC_VAL_IN_ERRORS--|--METRIC_VAL_OUT_ERRORS--</values>
         <oid>.1.3.6.1.2.1.2.2.1.14.--METRIC_IID--|.1.3.6.1.2.1.2.2.1.20.--METRIC_IID--</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
         <version>--SNMP_VERSION--</version>
         <mode>COUNTER</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
			<severity>--SEVERITY--</severity>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.2.1.2.2.1.14 .1.3.6.1.2.1.2.2.1.20);
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
	$Metrics::Base::Info='';
	
   $snmpcfg{oid}='ifDescr_ifType_ifInErrors_ifOutErrors';
   $snmpcfg{last}='ifOutQLen';
   $Metrics::Base::Error='';

   my $res=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
   if (! defined $res) { return undef; }

   for my $l ( @$res ) {
      my ($id,$descr1,$type,$errors_in,$errors_out)=split(':@:',$l);
      my $descr2=$Metrics::Base::SNMP->hex2ascii($descr1);
      my $descr = &Metrics::Base::escape($descr2);

      #my $skip=0;
      #foreach my $di (@SKIP_INTERFACES) { if ($descr =~ /$di/i) {$skip=1; last;} }
      #if ($skip) {next;}

		#if ( ($Metrics::Base::Subset) && (&Metrics::Base::skip_interface($id,$type)) ) {next;}

		my $DESC="Errores en $descr";
		my $m=&Metrics::Base::m2txml_iid($device,$rcfg,$subtype,$DESC,$txml,$id,$type,\&Metrics::Base::get_status_mib2_interfaces);

      #if (&Metrics::Base::skip_interface($id,$type)) { $m=~s/--STATUS--/1/g; }
      #else { $m=~s/--STATUS--/0/g; }

      #my $label="Errores en $descr ($Metrics::Base::METRIC{name})";

      #$m=~s/--METRIC_LABEL--/$label/g;
      $m=~s/--METRIC_VAL_IN_ERRORS--/Errores IN $descr/g;
      $m=~s/--METRIC_VAL_OUT_ERRORS--/Errores OUT $descr/g;
		$m=~s/--SEVERITY--/$Metrics::Base::METRIC{severity}/g;

      $M .= $m;
		push @Metrics::Base::IIDs, $id;
		#$Metrics::Base::Desc{$Metrics::Base::METRIC{mname}}->{label}=$label;
		$Metrics::Base::Info=$descr;
   }

   return $M;
}


1;
__END__

