#####################################################################################################
# Fichero: (Metrics::Base::pkts_type_mibrmon_if.pm)   $Id$
# Descripcion: Metrics::Base::pkts_type_mibrmon_if.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base::pkts_type_mibrmon_if;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# insert into cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid) values ('pkts_type_mibrmon', 'MIB-RMON', 300, 'TIPO DE TRAFICO EN INTERFAZ', 'pkts totales |pkt broadcast |pkts multicast','.1.3.6.1.2.1.16.1.1.1.5.IID|.1.3.6.1.2.1.16.1.1.1.6.IID|.1.3.6.1.2.1.16.1.1.1.7.IID','./support/iid_mibii_if');
#----------------------------------------------------------------------------
=head1 pkts_type_mibrmon_if

 OIDs: .1.3.6.1.2.1.16.1.1.1.5.IID|.1.3.6.1.2.1.16.1.1.1.6.IID|.1.3.6.1.2.1.16.1.1.1.7.IID
 TIPO: STD_BASE
 VALUES: pkts totales |pkt broadcast |pkts multicast
 VLABEL: pkts/seg
 DESCR: Paquetes totales/broadcast/multicast por interfaz

=cut

#----------------------------------------------------------------------------
sub pkts_type_mibrmon_if {
my ($device,$rcfg,$subtype)=@_;
my %snmpcfg=();
my %idx2descr=();
my $M='';

my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
			<subtype>--SUBTYPE--</subtype>
         <vlabel>pkts/seg</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>--METRIC_VAL_TOTAL--|--METRIC_VAL_BCAST--|--METRIC_VAL_MCAST--</values>
         <oid>.1.3.6.1.2.1.16.1.1.1.5.--METRIC_IID--|.1.3.6.1.2.1.16.1.1.1.6.--METRIC_IID--|.1.3.6.1.2.1.16.1.1.1.7.--METRIC_IID--</oid>
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

   #BEGIN { $ENV{'MIBS'}='+RMON-MIB'; }
   @Metrics::Base::OIDs=qw( .1.3.6.1.2.1.16.1.1.1.5 .1.3.6.1.2.1.16.1.1.1.6 .1.3.6.1.2.1.16.1.1.1.7 );
   @Metrics::Base::IIDs=();
   #%Metrics::Base::Desc=();
   $Metrics::Base::Info='';
   
   $snmpcfg{oid}='ifDescr_ifType';
   $snmpcfg{last}='ifMtu';
   $Metrics::Base::Error='';

   my $res1=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
   if (! defined $res1) { return undef; }
   
   foreach my $v (@$res1) {
      my ($idx,$descr1,$type)=split(':@:',$v);
      my $descr2=$Metrics::Base::SNMP->hex2ascii($descr1);
      $idx2descr{$idx}={ descr=>$descr2, type=>$type };
   }

   #$snmpcfg{oid}='etherStatsIndex_etherStatsPkts_etherStatsBroadcastPkts_etherStatsMulticastPkts';
   $snmpcfg{oid}='etherStatsPkts_etherStatsBroadcastPkts_etherStatsMulticastPkts';
   $snmpcfg{last}='etherStatsCRCAlignErrors';
   
   my $res2=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
   if (! defined $res2) { return undef; }

	foreach my $l ( @$res2 ) {
      my ($idx,$total,$broadcast,$multicastt)=split(':@:',$l);

		my $type=$idx2descr{$idx}->{type};
		#if ( ($Metrics::Base::Subset) && (&Metrics::Base::skip_interface($idx,$type)) ) {next;}

      if (!defined $idx2descr{$idx}->{descr}) {next;}

      my $descr2=$idx2descr{$idx}->{descr};
      my $descr = &Metrics::Base::escape($descr2);

		my $DESC="Tipo de trafico en  $descr";
		my $m=&Metrics::Base::m2txml_iid($device,$rcfg,$subtype,$DESC,$txml,$idx,$type,\&Metrics::Base::get_status_mib2_interfaces);

      #if (&Metrics::Base::skip_interface($idx,$type)) { $m=~s/--STATUS--/1/g; }
      #else { $m=~s/--STATUS--/0/g; }

		#my $label="Tipo de trafico en  $descr ($Metrics::Base::METRIC{name})";

      #$m=~s/--METRIC_LABEL--/$label/g;
      $m=~s/--METRIC_VAL_TOTAL--/Pkts Totales $descr/g;
      $m=~s/--METRIC_VAL_BCAST--/Pkts Broadcast $descr/g;
      $m=~s/--METRIC_VAL_MCAST--/Pkts Multicast $descr/g;
		$m=~s/--SEVERITY--/$Metrics::Base::METRIC{severity}/g;

      $M .= $m;
		push @Metrics::Base::IIDs, $idx;
		#$Metrics::Base::Desc{$Metrics::Base::METRIC{mname}}->{label}=$label;
		$Metrics::Base::Info=$descr;
   }

   return $M;
}



1;
__END__

