#####################################################################################################
# Fichero: (Metrics::Base.pm)   $Id: Base.pm,v 1.2 2004/05/02 15:36:39 fml Exp $
# Descripcion: Metrics::Base.pm
# Set Tab=3
#####################################################################################################
package Metrics::Base;
$VERSION='1.00';
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;

@EXPORT_OK = qw(@DEFAULT_INTERFACES @SKIP_INTERFACES %Functions $TASK_HEADER $DEVICE_HEADER $DEVICE_FOOTER %PARAMS skip_metric custom sagent get_snmp_vector m2txml_iid m2txml_base escape check_ipserv_params m2txml_ipserv);
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

use Crawler::SNMP;

#----------------------------------------------------------------------------
#Por defecto quitamos el trafico ppp de las capturas
my @DEFAULT_INTERFACES=qw(ethernet-csmacd ethernetCsmacd iso88023-csmacd iso88024-tokenBus iso88025-tokenRing hssi frame-relay frameRelay adsl atm aal5 ds1 ds3 lapd propPointToPointSerial);

#----------------------------------------------------------------------------
my @SKIP_INTERFACES=qw(lo loopback l0 dummy);

#----------------------------------------------------------------------------
# Parametros para el caso de monitores TCP
my %PARAMS=(
   'mon_icmp' => {},
   'mon_dns' => { 'rr'=>'www', 'port'=>'53' },
   'mon_smtp' => { 'port'=>'25' },
   'mon_pop3' => { 'user'=>'u', 'pwd'=>'p', 'port'=>'110' },
   'mon_imap' => { 'user'=>'u', 'pwd'=>'p', 'port'=>'143' },
   'mon_http' => { 'url'=>'http://www', 'type'=>'get', 'port'=>'80', 'params'=>'' },
   'mon_tcp' => { 'port'=>'111' },
   'mon_ssh' => { 'port'=>'22' },
);


#------------------------------------------------------------------------
# Convenio para definir el nombre de las diferentes metricas:
# --METRIC_NAME-- ==>> nombre de metrica-id (si aplica, iterfaces, particiones ...)
# subtype-id
#------------------------------------------------------------------------
#------------------------------------------------------------------------
%Metrics::Base::Functions = (

	#------------------------------------------------------------
	'custom' => \&Metrics::Base::custom,

	'sagent' => \&Metrics::Base::sagent,

	'disk_mibhost' => \&Metrics::Base::disk_mibhost,
	'proc_cnt_mibhost' => \&Metrics::Base::proc_cnt_mibhost,
	'users_cnt_mibhost' => \&Metrics::Base::users_cnt_mibhost,

	'traffic_mibii_if' => \&Metrics::Base::traffic_mibii_if,
	'pkts_type_mibii_if' => \&Metrics::Base::pkts_type_mibii_if,
	'pkts_type_mibii_if_ext' => \&Metrics::Base::pkts_type_mibii_if_ext,
	'pkts_type_mibrmon' => \&Metrics::Base::pkts_type_mibrmon_if,
	'pkts_discard_mibii_if' => \&Metrics::Base::pkts_discard_mibii_if,
	'errors_mibii_if' => \&Metrics::Base::errors_mibii_if,
	'status_mibii_if' => \&Metrics::Base::status_mibii_if,
	'arp_mibii_cnt' => \&Metrics::Base::arp_mibii_cnt,

	'ip_pkts_discard' => \&Metrics::Base::ip_pkts_discard,
	'tcp_estab' => \&Metrics::Base::tcp_estab,
	'tcp_ap' => \&Metrics::Base::tcp_ap,
	'udp_pkts' => \&Metrics::Base::udp_pkts,
	
	#------------------------------------------------------------
	'disp_icmp' => \&Metrics::IPServ::disp_icmp,

	'mon_icmp' => \&Metrics::IPServ::latency_icmp,
	'mon_dns' => \&Metrics::IPServ::latency_dns,
	'mon_smtp' => \&Metrics::IPServ::latency_smtp,
	'mon_pop3' => \&Metrics::IPServ::latency_pop3,
	'mon_imap' => \&Metrics::IPServ::latency_imap,
	'mon_http' => \&Metrics::IPServ::latency_http,
	'mon_tcp' => \&Metrics::IPServ::latency_tcp,
	'mon_ssh' => \&Metrics::IPServ::latency_ssh,

	#------------------------------------------------------------
	'nortel_memory' => \&Metrics::Nortel::nortel_memory,
   'nortel_cpu' => \&Metrics::Nortel::nortel_cpu,

	#------------------------------------------------------------
	'cisco_memory' => \&Metrics::Cisco::cisco_memory,
	'cisco_cpu' => \&Metrics::Cisco::cisco_cpu,	
	'cisco_buffers_usage' => \&Metrics::Cisco::cisco_buffers_usage,
	'cisco_buffer_errors' => \&Metrics::Cisco::cisco_buffer_errors,
	'cisco_ds0_usage' => \&Metrics::Cisco::cisco_ds0_usage,
	'cisco_modem_usage' => \&Metrics::Cisco::cisco_modem_usage,
	'cisco_ds0_errors' => \&Metrics::Cisco::cisco_ds0_errors,
	'cisco_modem_errors' => \&Metrics::Cisco::cisco_ds0_errors,

	#------------------------------------------------------------
	'enterasys_cpu_usage' => \&Metrics::Enterasys::enterasys_cpu_usage,
	'enterasys_flow3' => \&Metrics::Enterasys::enterasys_flow3,
	'enterasys_flow2' => \&Metrics::Enterasys::enterasys_flow2,
);

#------------------------------------------------------------------------
$Metrics::Base::TASK_HEADER= '
    <task type="--TASK_TYPE--">
      <name>--TASK_NAME--</name>
      <lapse>--TASK_LAPSE--</lapse>
      <once>--TASK_ONCE--</once>';
$Metrics::Base::TASK_FOOTER= "    </task>\n";

#------------------------------------------------------------------------
$Metrics::Base::DEVICE_HEADER= '
<universe1>
  <device name="--DEVICE_NAME--">
    <ip>--DEVICE_IP--</ip>';

$Metrics::Base::DEVICE_FOOTER= '
  </device>
</universe1>';

=head1 METRICAS DEFINIDAS

=cut


$Metrics::Base::Error='';
$Metrics::Base::Info='';
@Metrics::Base::OIDs=();
@Metrics::Base::IIDs=();
@Metrics::Base::AssignedIIDs=();
%Metrics::Base::Desc=();
$Metrics::Base::Subset=1;
# Hash Active ==> k=id, value=watch (si no hay watch vale 0)
%Metrics::Base::Active=();
my $SNMP=undef;
my %METRIC=();

#----------------------------------------------------------------------------
# skip_metric
# Devuelve true si se tiene que saltar un iid porque no esta el Active
#----------------------------------------------------------------------------
sub skip_metric {
my $iid=shift;

	my $skip=1;
   foreach my $di (sort keys %Metrics::Base::Active) { 
		if (($di eq 'all') || ($di eq 'ALL')) {$skip=0; last; }
		elsif ($di eq $iid) { $skip=0; last; } 
	}
	return $skip;
}


#----------------------------------------------------------------------------
# Metricas CUSTOM (definidas por usuario)
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
my $CUSTOM='';

=head1 custom

 DESCR: Definidas por usuario

=cut

#----------------------------------------------------------------------------
sub custom {
my ($device,$rcfg,$subtype)=@_;
my $m;

	my $file=$device->{file};
   my $name=$device->{name} || $device->{ip};
   my $cnt=$device->{metric_cnt};

# print "FF=$file ($name)\n";
	local undef $/;
	open (F, "<$file");
	chomp($m=<F>);
	close F;

	$m=~s/--HOST_NAME--/$name/g;

   $device->{metric_cnt}=$cnt+1;
 #print "MMMMMMM=$m\n";

   return $m;
}

#----------------------------------------------------------------------------
# Metricas de agente remoto (sagent)
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

=head1 sagent 

 DESCR: Agentes remotos

=cut

#----------------------------------------------------------------------------
sub sagent {
my ($device,$rcfg,$subtype)=@_;
my $M='';
my $txml='
      <metric name="--METRIC_NAME--">
         <mtype>--MTYPE--</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>--VLABEL--</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>--MODULE--</module>
         <values>--VALUES--</values>
         <mode>--MODE--</mode>
         <top_value>--TOP_VALUE--</top_value>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>

';

	my $cnt=$device->{metric_cnt};
	my $name=$device->{name} || $device->{ip};

	if (! defined $device->{mdata}) {
		return;
	}

	foreach my $l (@{$device->{mdata}}) {

	   my $mname=$l->[0];
	   my $mtype=$l->[1];
   	my $vlabel=$l->[2];
	   my $label=$l->[3];
   	my $items=$l->[4];
	   my $mode=$l->[5];
   	my $module=$l->[6];
	   my $top_value=$l->[7];
   	my $watch=$l->[8];

		$M .= $txml;
		
	   $M=~s/--METRIC_NAME--/$mname/g;
   	$M=~s/--MTYPE--/$mtype/g;
   	$M=~s/--SUBTYPE--/$subtype/g;
   	$M=~s/--VLABEL--/$vlabel/g;
   	$M=~s/--METRIC_LABEL--/$label/g;
   	$M=~s/--VALUES--/$items/g;
   	$M=~s/--MODE--/$mode/g;
   	$M=~s/--TOP_VALUE--/$top_value/g;
   	$M=~s/--WATCH--/$watch/g;
   	$M=~s/--METRIC_POSITION--/$cnt/g;

		#Esto lo mete el usuario si quiere en metric_label en DB
   	$M=~s/__NAME__/$name/g;

   	$cnt+=1;
   	$device->{metric_cnt}=$cnt;
	}

   return $M;

}



#----------------------------------------------------------------------------
sub get_snmp_vector {
my ($device,$snmpcfg,$snmp)=@_;
my %snmpcfg=();

   $snmpcfg->{host_ip}=$device->{ip};
   $snmpcfg->{community}=$device->{community} || 'public';
   $snmpcfg->{version}= $device->{version} || '1';
   my $name=$device->{name} || $device->{ip};

   if (!defined $snmp) { $snmp=Crawler::SNMP->new(); }
   if (!defined $snmp) { 
     	$Metrics::Base::Error='ERROR AL CREAR OBJETO SNMP';
      return undef;
   }
   
   my $res=$snmp->core_snmp_table($snmpcfg);
   if ( (!defined $res) || (! scalar @$res) ){
      $Metrics::Base::Error="NO HAY DATOS POR SNMP (IP=$snmpcfg->{host_ip} C=$snmpcfg->{community} V=$snmpcfg->{version})";
      return undef;
   }
   
   $SNMP=$snmp;
   return $res;
}

#----------------------------------------------------------------------------
sub m2txml_iid {
my ($device,$rcfg,$subtype,$m,$id)=@_;
my $M='';

   $METRIC{name}=$device->{name} || $device->{ip};
   $METRIC{cnt}=$device->{metric_cnt};
	$METRIC{community}=$device->{community} || 'public';
	$METRIC{version}=$device->{version} || '1';
	$METRIC{id}=$id;
	$METRIC{mname}="$subtype-$id";
	$METRIC{subtype}=$subtype;

   $m=~s/--METRIC_IID--/$METRIC{id}/g;
   $m=~s/--METRIC_NAME--/$METRIC{mname}/g;
   $m=~s/--HOST_NAME--/$METRIC{name}/g;

   $m=~s/--METRIC_SNMP_COMMUNITY--/$METRIC{community}/g;
   $m=~s/--SNMP_VERSION--/$METRIC{version}/g;
   $m=~s/--METRIC_POSITION--/$METRIC{cnt}/g;
   $m=~s/--SUBTYPE--/$METRIC{subtype}/g;

	$METRIC{watch}=0;
   if (defined $Metrics::Base::Active{'all'}) { $METRIC{watch}=$Metrics::Base::Active{'all'}; }
   elsif (defined $Metrics::Base::Active{$id}) { $METRIC{watch}=$Metrics::Base::Active{$id}; }
   $m=~s/--WATCH--/$METRIC{watch}/g;
	
	$METRIC{cnt}+=1;
	$device->{metric_cnt}=$METRIC{cnt};
   return $m;

}



#----------------------------------------------------------------------------
sub m2txml_base {
my ($device,$rcfg,$subtype,$m)=@_;
my $M='';

   $METRIC{name}=$device->{name} || $device->{ip};
   $METRIC{cnt}=$device->{metric_cnt};
	$METRIC{community}=$device->{community} || 'public';
   $METRIC{version}=$device->{version} || '1';
   $METRIC{mname}=$subtype;
   $METRIC{subtype}=$subtype;

   $m=~s/--METRIC_NAME--/$METRIC{mname}/g;
   $m=~s/--HOST_NAME--/$METRIC{name}/g;
   $m=~s/--METRIC_SNMP_COMMUNITY--/$METRIC{community}/g;
	$m=~s/--SNMP_VERSION--/$METRIC{version}/g;
   $m=~s/--METRIC_POSITION--/$METRIC{cnt}/g;
	$m=~s/--SUBTYPE--/$METRIC{subtype}/g;

   $METRIC{watch} = (defined $Metrics::Base::Active{'all'}) ? $Metrics::Base::Active{'all'} : '0';
   $m=~s/--WATCH--/$METRIC{watch}/g;

	$METRIC{cnt}+=1;
	$device->{metric_cnt}=$METRIC{cnt};

   return $m;

}


#----------------------------------------------------------------------------
sub escape  {
my $data=shift;
 
   $data =~ s/\"//g;
   $data =~ s/\'//g;

	#ojo con el <> porque pueden tener impacto a la hora de generar el txml
   $data =~ s/\<//g;
   $data =~ s/\>//g;
 
   #$data =~ s/\s/_/g;
   #$data =~ s/\//_/g;
   #$data =~ s/\,/_/g;
   #$data =~ s/\:/_/g;
 
   #Parche openvms --------------------------------------
   #$data=~s/IP_Interface__(\w+__OpenVMS_Adapter__\w+)___.*/$1/;
   $data=~s/(\w+_IP_Interface).*/$1/;

   $data=~s/_\(Microsofts_Packet_Scheduler\)_//;

	# Parhe para evitar texto innecesario al monitorizar discos
   $data=~s/Serial\s*Number\s*\w+//;

	# Parche switches de 3Com ----------------------------
	$data=~s/RMON\:10\/100\s*(.+)/$1/;
	$data=~s/RMON\:\s*(.+)/$1/;
   return substr($data,0,39);
}


#----------------------------------------------------------------------------
sub check_ipserv_params {
my ($m,$suplied)=@_;
#$suplied es del tipo (p. ej): 'url=http://sliromrtg1|type=GET'

   my $needed=$PARAMS{$m};
   if (! defined $needed) { return undef };

   my @p=split(/\|/,$suplied);
   foreach my $px (@p) {
      my ($k,$v)=split('=',$px,2);
      if (defined $needed->{$k}) { $needed->{$k}=$v; }
#print "*****> $k=$v\n";
#      if (defined $v) {$rcfgbase->{$k}->[0]=$v; print "$subtype PARAMS=>$k=$v\n";}
   }
   return $needed;
}

#----------------------------------------------------------------------------
sub m2txml_ipserv {
my ($device,$rcfg,$subtype,$m)=@_;
my %snmpcfg=();
my $M='';

   $METRIC{name}=$device->{name} || $device->{ip};
   $METRIC{cnt}=$device->{metric_cnt};
   $device->{metric_cnt}=$METRIC{cnt}+1;

   $METRIC{mname} = (defined $rcfg->{'metric_name'}->[0]) ? $rcfg->{'metric_name'}->[0] : $subtype;

   $m=~s/--METRIC_NAME--/$METRIC{mname}/g;
   $m=~s/--HOST_NAME--/$METRIC{name}/g;
   $m=~s/--METRIC_POSITION--/$METRIC{cnt}/g;
   $m=~s/--SUBTYPE--/$subtype/g;

   return $m;
}










1;
__END__
