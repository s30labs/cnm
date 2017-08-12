#####################################################################################################
# Fichero: (Metrics::Brocade::brocade_frames_port.pm)   $Id$
# Descripcion: Metrics::Brocade::brocade_frames_port
# Set Tab=3
#####################################################################################################
package Metrics::Brocade::brocade_frames_port;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# Frames TX/RX por puerto
# 
# SW-MIB::swFCPortTxFrames
# swFCPortTxFrames OBJECT-TYPE
#  SYNTAX        Counter32
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "This object counts the number of (Fibre Channel)
#                frames that the port has transmitted."
# ::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) bcsi(1588) commDev(2) fibrechannel(1) fcSwitch(1) sw(1) swFCport(6) swFCPortTable(2) swFCPortEntry(1) 13 }
#
#SW-MIB::swFCPortRxFrames
#swFCPortRxFrames OBJECT-TYPE
#  SYNTAX        Counter32
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "This object counts the number of (Fibre Channel)
#                frames that the port has received."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) bcsi(1588) commDev(2) fibrechannel(1) fcSwitch(1) sw(1) swFCport(6) swFCPortTable(2) swFCPortEntry(1) 14 }
#----------------------------------------------------------------------------
# INSERT INTO cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid,label,vlabel,community,mode,mtype,top_value) VALUES ('brocade_frames_port','BROCADE',300,'TRAFICO POR PUERTO FIBER-CHANNEL','Frames Tx|Frames Rx','.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.13.IID|.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.14.IID','./support/iid_brocade_port',NULL,NULL,'public',NULL,NULL,NULL);
#----------------------------------------------------------------------------
=head1 brocade_frames_port

 OIDs: .1.3.6.1.4.1.1588.2.1.1.1.6.2.1.13.IID|.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.14.IID
 TIPO: STD_BASE
 VALUES: Frames Tx|Frames Rx
 VLABEL: frames
 DESCR: Frames transmitidas/recibidas por puerto.

=cut
#----------------------------------------------------------------------------
sub brocade_frames_port {
my ($device,$rcfg,$subtype)=@_;
my %snmpcfg=();
my $M='';

my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_BASE</mtype>
			<subtype>--SUBTYPE--</subtype>
         <vlabel>frames</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get</module>
         <values>--METRIC_VAL_TX--|--METRIC_VAL_RX--</values>
         <oid>.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.13.--METRIC_IID--|.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.14.--METRIC_IID--</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>COUNTER</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.13 .1.3.6.1.4.1.1588.2.1.1.1.6.2.1.14);
   @Metrics::Base::IIDs=();
   $Metrics::Base::Info='';
   #%Metrics::Base::Desc=();
   #BEGIN { $ENV{'MIBS'}='HOST-RESOURCES-MIB'; }
   #$snmpcfg{oid}='swFCPortIndex_swFCPortTxFrames_swFCPortRxFrames';
   $snmpcfg{oid}='swFCPortTxFrames_swFCPortRxFrames';
   $snmpcfg{last}='swFCPortTxC2Frames';
   $Metrics::Base::Error='';

   my $res=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
   if (! defined $res) { return undef; }

   for my $l ( @$res ) {

      my ($id,$tx,$rx)=split(':@:',$l);

      #my $descr=$Metrics::Base::SNMP->hex2ascii($descr1);
		my $descr=$id;
		#NOTA!! Revisar porque salen asi los datos
		if ($id=~/portNum-(\d+)/) { $id=$1+1; }

		my $DESC="Trafico en puerto fc $descr";
      my $m=&Metrics::Base::m2txml_iid($device,$rcfg,$subtype,$DESC,$txml,$id,'','');
		
      #my $label="Trafico en puerto fc $descr ($Metrics::Base::METRIC{name})";
      #my $label="Disco $descr";
      #$m=~s/--METRIC_LABEL--/$label/g;
      $m=~s/--METRIC_VAL_TX--/Frames Tx ($id)/g;
      $m=~s/--METRIC_VAL_RX--/Frames Rx ($id)/g;

      $M .= $m;
      push @Metrics::Base::IIDs, $id;
      #my $n="$subtype-$id";
      #$Metrics::Base::Desc{$n}->{label}=$label;
      $Metrics::Base::Info=$descr;
   }

   return $M;
}

1;

__END__
