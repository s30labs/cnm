#####################################################################################################
# Fichero: (Metrics::Base::status_mibii_if.pm)   $Id$
# Descripcion: Metrics::Base::status_mibii_if.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base::status_mibii_if;
$VERSION='1.00';
use strict;
use Crawler::SNMP;


#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('status_mibii_if', 'MIB-II', 300, 'ESTADO DE INTERFAZ', 'UNK|DOWN|ADMIN DOWN|UP','.1.3.6.1.2.1.2.2.1.7.IID|.1.3.6.1.2.1.2.2.1.8.IID','./support/iid_mibii_if');
#----------------------------------------------------------------------------
=head1 status_mibii_if

 OIDs: .1.3.6.1.2.1.2.2.1.7.IID/.1.3.6.1.2.1.2.2.1.8.IID
 TIPO: STD_SOLID
 VALUES: STATUS down(1) si adminstatus=up && operstatus=down | admin_down(2) si adminstatus=down | up(3) si adminstatus=up && operstatus=up | unknown(0) resto
 VLABEL: unk/down/admin_down/up (0/1/2/3)
 DESCR: Estado del interface

=cut

#----------------------------------------------------------------------------
sub status_mibii_if {
my ($device,$rcfg,$subtype)=@_;
my %snmpcfg=();
my $M='';

my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_SOLID</mtype>
			<subtype>--SUBTYPE--</subtype>
         <vlabel>estado</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get_ext:ext_status_if</module>
         <values>UP|ADMIN DOWN|DOWN|UNK</values>
         <oid>.1.3.6.1.2.1.2.2.1.7.--METRIC_IID--|.1.3.6.1.2.1.2.2.1.8.--METRIC_IID--</oid>
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

   @Metrics::Base::OIDs=qw( .1.3.6.1.2.1.2.2.1.7 .1.3.6.1.2.1.2.2.1.8);
   @Metrics::Base::IIDs=();
	#%Metrics::Base::Desc=();
	$Metrics::Base::Info='';

   # Miro si existe ifName -----------------------------------
   my %IFNAME=();
   $snmpcfg{oid}='ifName';
   $snmpcfg{last}='ifInMulticastPkts';
   my $res=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
   for my $l ( @$res ) {
      my ($id,$name)=split(':@:',$l);
      $IFNAME{$id}=$name;
   }

   #--------------------------------------------------------------------------------
   # PARCHE: Valido que el ifName es adecuado.
   # Hay casos en los que todos los valores del ifName son iguales (VH)
   my @N=values %IFNAME;
   my $ni=scalar @N;
   my $iguales=1;
   for my $i (1..$ni-1) {
      if ($N[$i] eq $N[$i-1]) { $iguales+=1; }
   }
   if ($iguales==$ni) { %IFNAME=(); }

   #----------------------------------------------------------

   $snmpcfg{oid}='ifDescr_ifType_ifAdminStatus_ifOperStatus';
   $snmpcfg{last}='ifInOctets';
   $Metrics::Base::Error='';

   $res=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
   if (! defined $res) { return undef; }

   for my $l ( @$res ) {
      my ($id,$descr1,$type,$admin,$oper)=split(':@:',$l);

		if (exists $IFNAME{$id}) { $descr1 = $IFNAME{$id}; }

		my $descr2=$Metrics::Base::SNMP->hex2ascii($descr1);

		#if ( ($Metrics::Base::Subset) && (&Metrics::Base::skip_interface($id,$type)) ) {next;}

		my $descr = &Metrics::Base::escape($descr2);

		my $DESC="Estado $descr";
		my $m=&Metrics::Base::m2txml_iid($device,$rcfg,$subtype,$DESC,$txml,$id,$type,\&Metrics::Base::get_status_mib2_interfaces);

      #if (&Metrics::Base::skip_interface($id,$type)) { $m=~s/--STATUS--/1/g; }
      #else { $m=~s/--STATUS--/0/g; }

		#my $label="Estado $descr ($Metrics::Base::METRIC{name})";
      #$m=~s/--METRIC_LABEL--/$label/g;

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

