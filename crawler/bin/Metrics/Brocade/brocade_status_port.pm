#####################################################################################################
# Fichero: (Metrics::Brocade::brocade_status_port.pm)   $Id$
# Descripcion: Metrics::Brocade::brocade_status_port
# Set Tab=3
#####################################################################################################
package Metrics::Brocade::brocade_status_port;
$VERSION='1.00';
use strict;
use Crawler::SNMP;

#----------------------------------------------------------------------------
# Estado de los puertos de FC
# 
#swFCPortAdmStatus OBJECT-TYPE
#  SYNTAX        INTEGER {online(1), offline(2), testing(3), faulty(4)}
#  MAX-ACCESS    read-write
#  STATUS        mandatory
#  DESCRIPTION   "The desired state of the port. A management station
#                may place the port in a desired state by setting this
#                object accordingly.  The testing(3) state indicates that
#                no user frames can be passed. As the result of
#                either explicit management action or per configuration
#                information accessible by the switch, swFCPortAdmStatus is
#                then changed to either the online(1) or testing(3)
#                states, or remains in the offline(2) state."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) bcsi(1588) commDev(2) fibrechannel(1) fcSwitch(1) sw(1) swFCport(6) swFCPortTable(2) swFCPortEntry(1) 5 }
#
#
#swFCPortOpStatus OBJECT-TYPE
#  SYNTAX        INTEGER {unknown(0), online(1), offline(2), testing(3), faulty(4)}
#  MAX-ACCESS    read-only
#  STATUS        mandatory
#  DESCRIPTION   "This object identifies the operational status of
#                the port. The online(1) state indicates that user frames
#                can be passed. The unknown(0) state indicates that likely
#                the port module is physically absent (see swFCPortPhyState)."
#::= { iso(1) org(3) dod(6) internet(1) private(4) enterprises(1) bcsi(1588) commDev(2) fibrechannel(1) fcSwitch(1) sw(1) swFCport(6) swFCPortTable(2) swFCPortEntry(1) 4 }
#
#----------------------------------------------------------------------------
# INSERT INTO cfg_monitor_snmp (subtype,class,lapse,descr,items,oid,get_iid,label,vlabel,community,mode,mtype,top_value) VALUES ('brocade_status_port','BROCADE',300,'ESTADO DEL PUERTO FIBER-CHANNEL','UP|DOWN|UNK','.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.5.IID|.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.4.IID','./support/iid_brocade_port',NULL,NULL,'public',NULL,NULL,NULL);
#----------------------------------------------------------------------------
=head1 brocade_status_port

 OIDs: .1.3.6.1.4.1.1588.2.1.1.1.6.2.1.5.IID|.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.4.IID
 TIPO: STD_SOLID
 VALUES: STATUS down(1) si adminstatus=up && operstatus=down | admin_down(2) si adminstatus=down | up(3) si adminstatus=up && operstatus=up | unknown(0) resto
 VLABEL: unk/down/admin_down/up (0/1/2/3)
 DESCR: Estado de los puertos de switch de FC

=cut
#----------------------------------------------------------------------------
sub brocade_status_port {
my ($device,$rcfg,$subtype)=@_;
my %snmpcfg=();
my $M='';

my $txml= '
      <metric name="--METRIC_NAME--">
         <mtype>STD_SOLID</mtype>
			<subtype>--SUBTYPE--</subtype>
         <vlabel>estado</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>mod_snmp_get_ext:ext_brocade_status_port</module>
         <values>UP|ADMIN DOWN|DOWN|UNK</values>
         <oid>.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.5.--METRIC_IID--|.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.4.--METRIC_IID--</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
			<version>--SNMP_VERSION--</version>
         <mode>GAUGE</mode>
			<top_value>1</top_value>
			<status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   @Metrics::Base::OIDs=qw(.1.3.6.1.4.1.1588.2.1.1.1.6.2.1.5 .1.3.6.1.4.1.1588.2.1.1.1.6.2.1.4);
   @Metrics::Base::IIDs=();
   $Metrics::Base::Info='';
   #%Metrics::Base::Desc=();
   #BEGIN { $ENV{'MIBS'}='HOST-RESOURCES-MIB'; }
   #$snmpcfg{oid}='swFCPortIndex_swFCPortOpStatus_swFCPortAdmStatus';
   $snmpcfg{oid}='swFCPortOpStatus_swFCPortAdmStatus';
   $snmpcfg{last}='swFCPortLinkState';
   $Metrics::Base::Error='';

   my $res=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
   if (! defined $res) { return undef; }

   for my $l ( @$res ) {

      my ($id,$oper,$sdmin)=split(':@:',$l);

      #my $descr=$Metrics::Base::SNMP->hex2ascii($descr1);
		my $descr=$id;
		#NOTA!! Revisar porque salen asi los datos
		if ($id=~/portNum-(\d+)/) { $id=$1+1; }

		my $DESC="Estado $descr";
      my $m=&Metrics::Base::m2txml_iid($device,$rcfg,$subtype,$DESC,$txml,$id,'','');

      #my $label="Estado $descr ($Metrics::Base::METRIC{name})";
      ##my $label="Disco $descr";
      #$m=~s/--METRIC_LABEL--/$label/g;

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
