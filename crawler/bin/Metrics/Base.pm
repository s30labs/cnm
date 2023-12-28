#####################################################################################################
# Fichero: (Metrics::Base.pm)   $Id: Base.pm,v 1.2 2004/05/02 15:36:39 fml Exp $
# Descripcion: Metrics::Base.pm
# Set Tab=3
#####################################################################################################
# latency -> m2txml_ipserv
# snmp escalar -> m2txml_snmp_simple (antes m2txml_base)
# snmp vector (iids) m2txml_iid)
# Para ampliar el nivel de debug:
# $snmp->log_level('debug');
# $snmp->log_mode(2);
#####################################################################################################
package Metrics::Base;
$VERSION='1.00';
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;

@EXPORT_OK = qw( @DEFAULT_INTERFACES @SKIP_INTERFACES %Functions $TASK_HEADER $DEVICE_HEADER $DEVICE_FOOTER  %METRIC custom sagent get_snmp_vector m2txml_iid m2txml_base escape check_ipserv_params m2txml_ipserv );
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

use Crawler::SNMP;
use Crawler::Latency;
use ONMConfig;
use Metrics::Base::disk_mibhost;
use Metrics::Base::proc_cnt_mibhost;
use Metrics::Base::users_cnt_mibhost;

use Metrics::Base::traffic_mibii_if;
use Metrics::Base::pkts_type_mibii_if;
use Metrics::Base::pkts_type_mibii_if_ext;

use Metrics::Base::pkts_type_mibrmon_if;
use Metrics::Base::pkts_discard_mibii_if;
use Metrics::Base::errors_mibii_if;
use Metrics::Base::status_mibii_if;
use Metrics::Base::arp_mibii_cnt;
use Metrics::Base::ip_pkts_discard;
use Metrics::Base::tcp_estab;
use Metrics::Base::tcp_ap;
use Metrics::Base::udp_pkts;

use Metrics::IPServ;
#use Metrics::IPServ::disp_icmp;
#use Metrics::IPServ::latency_icmp;
#use Metrics::IPServ::latency_dns;
#use Metrics::IPServ::latency_smtp;
#use Metrics::IPServ::latency_pop3;
#use Metrics::IPServ::latency_imap;
#use Metrics::IPServ::latency_http;
#use Metrics::IPServ::latency_tcp;
#use Metrics::IPServ::latency_ssh;

use Metrics::Nortel::nortel_memory;
use Metrics::Nortel::nortel_cpu;

use Metrics::Cisco;
#use Metrics::Cisco::cisco_memory;
#use Metrics::Cisco::cisco_cpu;
#use Metrics::Cisco::cisco_buffers_usage;
#use Metrics::Cisco::cisco_buffer_errors;
#use Metrics::Cisco::cisco_ds0_usage;
#use Metrics::Cisco::cisco_modem_usage;
#use Metrics::Cisco::cisco_ds0_errors;
#use Metrics::Cisco::cisco_wap_users;

use Metrics::Enterasys::enterasys_cpu_usage;
use Metrics::Enterasys::enterasys_flow3;
use Metrics::Enterasys::enterasys_flow2;

use Metrics::Brocade::brocade_frames_port;
use Metrics::Brocade::brocade_status_port;

use Metrics::Novell::novell_nw_disk_dir;
use Metrics::Novell::novell_nw_disk_usage;
use Metrics::Novell::novell_nw_fs_cache;
use Metrics::Novell::novell_nw_fs_read_write;
use Metrics::Novell::novell_nw_open_files;

use Metrics::CheckPoint::checkpoint_numconex;
use Metrics::CheckPoint::checkpoint_peakconex;

use Metrics::UCDavis::ucdavis_interrupts;
use Metrics::UCDavis::ucdavis_memory;

#----------------------------------------------------------------------------
my $FILE_CONF='/cfg/onm.conf';
#----------------------------------------------------------------------------
# INTERFACES CONSIDERADOS POR DEFECTO
#Por defecto quitamos el trafico ppp de las capturas
my @DEFAULT_INTERFACES=qw(ethernet-csmacd ethernetCsmacd gigabitEthernet iso88023-csmacd iso88024-tokenBus iso88025-tokenRing hssi frame-relay frameRelay adsl fibreChannel atm aal5 ds1 ds3 lapd propPointToPointSerial fastEther rfc877x25);

#----------------------------------------------------------------------------
# INTERFACES QUE EXPLICITAMENTE SE SALTAN
my @SKIP_INTERFACES=qw(lo loopback l0 dummy);


#----------------------------------------------------------------------------
# Hash con los tipos definidos en mib-host para disco.
# El valor 0/1 indica el valor de status
my %MIBHOST_DISK_TYPES = (
	'hrStorageFixedDisk' => 0,
	'hrStorageRemovableDisk' => 0,
	'hrStorageFloppyDisk' => 1,
	'hrStorageCompactDisc' => 1,
	'hrStorageRamDisk' => 0,
	'hrStorageNetworkDisk' => 1,
);

#----------------------------------------------------------------------------
# Hash con los tipos definidos en mib-host para memoria.
# El valor 0/1 indica el valor de status
my %MIBHOST_MEMORY_TYPES = (
   'hrStorageOther' => 0,
   'hrStorageRam' => 0,
   'hrStorageVirtualMemory' => 0,
   'hrStorageFlashMemory' => 0,
);


#------------------------------------------------------------------------
# Convenio para definir el nombre de las diferentes metricas:
# --METRIC_NAME-- ==>> nombre de metrica-id (si aplica, iterfaces, particiones ...)
# subtype-id
#------------------------------------------------------------------------
#------------------------------------------------------------------------
%Metrics::Base::Functions = (

	#------------------------------------------------------------
	'custom_txml' => \&Metrics::Base::custom_txml,

	'sagent' => \&Metrics::Base::sagent,
	'custom' => \&Metrics::Base::custom,

	'disk_mibhost' => \&Metrics::Base::disk_mibhost::disk_mibhost,
	'proc_cnt_mibhost' => \&Metrics::Base::proc_cnt_mibhost::proc_cnt_mibhost,
	'users_cnt_mibhost' => \&Metrics::Base::users_cnt_mibhost::users_cnt_mibhost,

	'traffic_mibii_if' => \&Metrics::Base::traffic_mibii_if::traffic_mibii_if,
	'pkts_type_mibii_if' => \&Metrics::Base::pkts_type_mibii_if::pkts_type_mibii_if,
	'pkts_type_mibii_if_ext' => \&Metrics::Base::pkts_type_mibii_if_ext::pkts_type_mibii_if_ext,
	'pkts_type_mibrmon' => \&Metrics::Base::pkts_type_mibrmon_if::pkts_type_mibrmon_if,
	'pkts_discard_mibii_if' => \&Metrics::Base::pkts_discard_mibii_if::pkts_discard_mibii_if,
	'errors_mibii_if' => \&Metrics::Base::errors_mibii_if::errors_mibii_if,
	'status_mibii_if' => \&Metrics::Base::status_mibii_if::status_mibii_if,
	'arp_mibii_cnt' => \&Metrics::Base::arp_mibii_cnt::arp_mibii_cnt,

	'ip_pkts_discard' => \&Metrics::Base::ip_pkts_discard::ip_pkts_discard,
	'tcp_estab' => \&Metrics::Base::tcp_estab::tcp_estab,
	'tcp_ap' => \&Metrics::Base::tcp_ap::tcp_ap,
	'udp_pkts' => \&Metrics::Base::udp_pkts::udp_pkts,
	
	#------------------------------------------------------------
	'disp_icmp' => \&Metrics::IPServ::disp_icmp,

	'mon_icmp' => \&Metrics::IPServ::latency_icmp,
	'mon_dns' => \&Metrics::IPServ::latency_dns,
	'mon_smtp' => \&Metrics::IPServ::latency_smtp,
	'mon_pop3' => \&Metrics::IPServ::latency_pop3,
	'mon_imap' => \&Metrics::IPServ::latency_imap,
	'mon_http' => \&Metrics::IPServ::latency_http,
	'mon_httprc' => \&Metrics::IPServ::latency_httprc,
	'mon_httplinks' => \&Metrics::IPServ::latency_httplinks,
	'mon_httppage' => \&Metrics::IPServ::latency_httppage,
	'mon_tcp' => \&Metrics::IPServ::latency_tcp,
	'mon_ssh' => \&Metrics::IPServ::latency_ssh,
	'mon_smb' => \&Metrics::IPServ::latency_smb,
	'mon_ntp' => \&Metrics::IPServ::latency_ntp,

	#------------------------------------------------------------
	'nortel_memory' => \&Metrics::Nortel::nortel_memory::nortel_memory,
   'nortel_cpu' => \&Metrics::Nortel::nortel_cpu::nortel_cpu,

	#------------------------------------------------------------
	'cisco_memory' => \&Metrics::Cisco::cisco_memory,
	'cisco_cpu' => \&Metrics::Cisco::cisco_cpu,	
	'cisco_buffer_usage' => \&Metrics::Cisco::cisco_buffer_usage,
	'cisco_buffer_errors' => \&Metrics::Cisco::cisco_buffer_errors,
	'cisco_ds0_usage' => \&Metrics::Cisco::cisco_ds0_usage,
	'cisco_modem_usage' => \&Metrics::Cisco::cisco_modem_usage,
	'cisco_ds0_errors' => \&Metrics::Cisco::cisco_ds0_errors,
	'cisco_modem_errors' => \&Metrics::Cisco::cisco_ds0_errors,
	'cisco_wap_users' => \&Metrics::Cisco::cisco_wap_users,

	#------------------------------------------------------------
	'enterasys_cpu_usage' => \&Metrics::Enterasys::enterasys_cpu_usage::enterasys_cpu_usage,
	'enterasys_flow3' => \&Metrics::Enterasys::enterasys_flow3::enterasys_flow3,
	'enterasys_flow2' => \&Metrics::Enterasys::enterasys_flow2::enterasys_flow2,

	#------------------------------------------------------------
	'brocade_frames_port' => \&Metrics::Brocade::brocade_frames_port::brocade_frames_port,
	'brocade_status_port' => \&Metrics::Brocade::brocade_status_port::brocade_status_port,

	#------------------------------------------------------------
	'novell_nw_disk_dir' => \&Metrics::Novell::novell_nw_disk_dir::novell_nw_disk_dir,
	'novell_nw_disk_usage' => \&Metrics::Novell::novell_nw_disk_usage::novell_nw_disk_usage,
	'novell_nw_fs_cache' => \&Metrics::Novell::novell_nw_fs_cache::novell_nw_fs_cache,
	'novell_nw_fs_read_write' => \&Metrics::Novell::novell_nw_fs_read_write::novell_nw_fs_read_write,
	'novell_nw_open_files' => \&Metrics::Novell::novell_nw_open_files::novell_nw_open_files,

	#------------------------------------------------------------
	'checkpoint_maxconex' => \&Metrics::CheckPoint::checkpoint_maxconex,
	'checkpoint_peakconex' => \&Metrics::CheckPoint::checkpoint_peakconex,

	#------------------------------------------------------------
  	'ucdavis_interrupts' => \&Metrics::UCDavis::ucdavis_interrupts,
  	'ucdavis_memory' => \&Metrics::UCDavis::ucdavis_memory,
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

# Lo usan las metricas de IPServ
%Metrics::Base::METRIC=();


$Metrics::Base::Error=''; 	#Cadena con mensaje de error.
$Metrics::Base::Info='';	#Info.
@Metrics::Base::OIDs=();	#OIDs de la metrica.
@Metrics::Base::IIDs=();	#IIDs de la metrica.

# Hash con las instancias activas de una determinada metrica.
# keys=iids, values=monitor o 0 (si no hay watch)
%Metrics::Base::AssignedIIDs=();	

# Hash con la descripcion (labels) de las metricas generadas
# las claves son los mnames.
%Metrics::Base::Desc=();


# Hash para almacenar datos globales por dispositivo.
# Por ahora guarda descripcion y estado.
# las claves son los mnames.
%Metrics::Base::InDevice=(
	mname => { label => '', 	status => '', }
);


#$Metrics::Base::Subset=1; #Obsoleto al poner status dentro de cada metrica
# Hash Active ==> k=id, value=watch (si no hay watch vale 0)
%Metrics::Base::Active=();

$Metrics::Base::SNMP=undef;	#Objeto SNMP (por eficiencia)

#----------------------------------------------------------------------------
# skip_metric
# Devuelve true si se tiene que saltar un iid porque no esta el Hash AssignedIIDs
#----------------------------------------------------------------------------
#sub skip_metric {
#my $iid=shift;
#
#	my $skip=1;
#   foreach my $di (sort keys %Metrics::Base::AssignedIIDs) { 
#		if (($di eq 'all') || ($di eq 'ALL')) {$skip=0; last; }
#		elsif ($di eq $iid) { $skip=0; last; } 
#	}
#	return $skip;
#}

#------------------------------------------------
#sub skip_interface  {
#my ($id,$type)=@_;
#
#   my $skip=1;
#   my @iids=sort keys %Metrics::Base::AssignedIIDs;
#   my $nmetrics=scalar @iids;
#
#   if (($nmetrics == 0) || (($nmetrics == 1) && ($iids[0] eq 'all'))) {
#      foreach my $di (@DEFAULT_INTERFACES) { if ($di eq $type) {$skip=0;last;} }
#   }
#   else {
#      foreach my $di (@iids) {
#         if ( ($di eq $id) || ($di eq 'all') ) {$skip=0;last;}
#      }
#   }
#
#   return $skip;
#}

#----------------------------------------------------------------------------
# get_metric_status
# Decide sobre el estado de la metrica en proceso. 
# status=0 (activa) o status=1 (baja).
# Considera 3 casos:
# 1. %Active. Este hash lo define el usuario en la generacion asistida de metricas.
# Si existe y tiene valores (distintos de '0') es el que manda. Si la 
# metrica esta en el hash la considera (status=0) y si no esta pone status=1. 
# En este caso, aqui termina la funcion.
# 2. $rdefault. Si existe una referencia a un vector con las metricas por defecto,
# solo considera las que pertenecen a dicho vector, el resto tendra status=1 y termina 
# la funcion. $vdefault es el valor a comparar con los del array.
# 3. %AssignedIIDs. Si vale 'all'. Todas tienen status=0. Si no, solo loa valores
# incluidos tienen status=0
#----------------------------------------------------------------------------
sub get_metric_status {
my ($iid,$mname,$value,$rfx)=@_;

   my $status=1;

   # Si existe hash definido por usuario este es el que decide !!
   #-------------------------------------------------
   my @metrics=sort keys %Metrics::Base::Active;
   if (scalar @metrics > 0) {
      foreach my $m (sort keys %Metrics::Base::Active) {
         if ($m eq $mname) { $status=0; last; }
      }
print "****>$mname :: $status\n";
      return $status;
   }

   # En caso contrario:
   # Si no hay iids => Activa
   # Si hay iids y iids=all => Activa salvo que existe rfx y obligue a lo contrario
   # Si hay iids y iids=valores concretos => Activa para los valores concretos
   #-------------------------------------------------
   # Si la metrica no tiene instancias $iid=-1
   if ($iid == -1) {
      $status=0;
      return $status;
   }
   else {
      foreach my $di (sort keys %Metrics::Base::AssignedIIDs) {
         if (($di eq 'all') || ($di eq 'ALL')) {
            $status=0;

            #----------------------------------------
            if ($rfx) { $status=&{$rfx}($value); }
            #----------------------------------------

            last;
         }
         elsif ($di eq $iid) { $status=0; last; }
      }
      return $status;
   }

   #-------------------------------------------------
   if ($rfx) {
      $status=&{$rfx}($value);
      return $status;
   }
}


#----------------------------------------------------------------------------
# get_status_mib2_interfaces
# Parametro: tipo de interfaz (string)
# Se compara con los valores de @DEFAULT_INTERFACES. Si esta en el array
# status=0 y si no status=1.
#----------------------------------------------------------------------------
sub get_status_mib2_interfaces {
my $type=shift;

	my $status=1;
	foreach my $di (@DEFAULT_INTERFACES) { 
		if ($di eq $type) {$status=0;last;} 
	}
	return $status;
}

#----------------------------------------------------------------------------
# get_status_mibhost_disk
# Parametro: Descripcion del disco (string)
# Se compara con una serie de expresiones regulares para eliminar los "discos"
# de poca relevancia.
# Para el resto status=0
#----------------------------------------------------------------------------
sub get_status_mibhost_disk {
my $desc=shift;
my $rc=0;

	my $status=0;
   if ($desc =~ /A\:\\.*/i) {$status=1;}
   elsif ($desc =~ /\/dev\/shm/) {$status=1;}
   elsif ($desc =~ /\/proc\/bus\/usb/) {$status=1;}
   return $status;
}

#----------------------------------------------------------------------------
# Metricas CUSTOM_TXML (se especifica el txml)
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
my $CUSTOM='';

=head1 custom

 DESCR: Definidas por usuario

=cut

#----------------------------------------------------------------------------
sub custom_txml {
my ($device,$rcfg,$subtype)=@_;
my $m;

	my $file=$device->{file};
   my $name=$device->{name} || $device->{ip};
   my $cnt=$device->{metric_cnt};

# print "FF=$file ($name)\n";
	local undef $/;
	open (my $fh, "<", $file);
	chomp($m = <$fh>);
	close $fh;

	$m=~s/--HOST_NAME--/$name/g;

   $device->{metric_cnt}=$cnt+1;
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
# Metricas CUSTOM configuradas por usuario de tipo SNMP
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

=head1 custom 

 DESCR: Metricas configuradas por usuario (SNMP)

=cut

#----------------------------------------------------------------------------
sub custom {
my ($device,$rcfg,$subtype)=@_;
my $txml='
      <metric name="--METRIC_NAME--">
         <mtype>--MTYPE--</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>--VLABEL--</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>--MODULE--</module>
         <values>--VALUES--</values>
         <oid>--OID--</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
         <version>--SNMP_VERSION--</version>
         <mode>--MODE--</mode>
         <top_value>--TOP_VALUE--</top_value>
         <status>--STATUS--</status>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>

';

	my $m='';

   if (! defined $device->{mdata}) { return;  }

   @Metrics::Base::IIDs=();
   %Metrics::Base::Desc=();

	my $l=$device->{mdata};

	#mtype,vlabel,label,items,mode,oid,top_value,get_iid

   my $mtype=$l->[0];
   my $vlabel=$l->[1];
   my $label=$l->[2];
   my $items=$l->[3];
   my $mode=$l->[4];
   my $oid=$l->[5];
   my $top_value=$l->[6];
   my $get_iid=$l->[7];
   my $module=$l->[8] || 'mod_snmp_get';

	@Metrics::Base::OIDs=split(/\|/, $oid);

   $txml=~s/--MTYPE--/$mtype/g;
   $txml=~s/--VLABEL--/$vlabel/g;
   $txml=~s/--MODE--/$mode/g;
   $txml=~s/--TOP_VALUE--/$top_value/g;
   $txml=~s/--MODULE--/$module/g;

	#Metrica tipo tabla con OIDs -------------------------------------
	if (($get_iid) && ($module !~ /mod_snmp_walk/)){ $m=generate_custom_iids($device,$rcfg,$txml,$subtype,$get_iid,$label,$items); }

	#Metrica simple sin IIDs -----------------------------------------
	else {

      #revisar si para label se puede usar m2txml_base
      #$txml=~s/--METRIC_LABEL--/$label/g;

      $txml=~s/--VALUES--/$items/g;
      $txml=~s/--OID--/$oid/g;

      $m=&Metrics::Base::m2txml_base($device,$rcfg,$subtype,$label,$txml);
      $Metrics::Base::Desc{$Metrics::Base::METRIC{mname}}->{label}="Memoria ($Metrics::Base::METRIC{name})";
   }

   return $m;

}

#----------------------------------------------------------------------------
sub generate_custom_iids {
my ($device,$rcfg,$txml,$subtype,$get_iid,$label,$items)=@_;
my %snmpcfg=();
my $M='';
my @OIDS=();


   $Metrics::Base::Info='';
   #$snmpcfg{oid}='ifDescr_ifType';
	my $noids=scalar @Metrics::Base::OIDs;

   @OIDS=();
   foreach my $o (@Metrics::Base::OIDs) { $o=~s/^.*\:\:(.*)$/$1/; push @OIDS,$o; }
	$get_iid=~s/^.*\:\:(.*)$/$1/;
	$snmpcfg{oid}=$get_iid.'_'.join('_',@OIDS);
   $Metrics::Base::Error='';

   my $res=&Metrics::Base::get_snmp_vector($device,\%snmpcfg);
   if (! defined $res) { return undef; }

	my @ITEMS=split(/\|/, $items);

	#tag oid, del tipo:
	#<oid>.1.3.6.1.2.1.2.2.1.10.--METRIC_IID--|.1.3.6.1.2.1.2.2.1.16.--METRIC_IID--</oid>
	@OIDS=();
	foreach my $o (@Metrics::Base::OIDs) {	push @OIDS,"$o\.--METRIC_IID--"; }
	my $oid = join('|',@OIDS);
	$txml=~s/--OID--/$oid/g	;


   for my $l ( @$res ) {

		#El primer valor es el id, luego la descr y luego los oids
      my ($id,$descr1,@data)=split(':@:',$l);
      my $descr2=$Metrics::Base::SNMP->hex2ascii($descr1);
      my $descr = "$label " . &Metrics::Base::escape($descr2);

      my $m=&Metrics::Base::m2txml_iid($device,$rcfg,$subtype,$descr,$txml,$id,'','');

		#tag values del tipo:
		#<values>--METRIC_VAL_RX--|--METRIC_VAL_TX--</values>
		my @ITEMSM=();
		foreach my $i (@ITEMS) {  push @ITEMSM, "$i:$id"; }
		my $itemsm=join('|',@ITEMSM);
		$m=~s/--VALUES--/$itemsm/g;

      $M .= $m;
      push @Metrics::Base::IIDs, $id;
      $Metrics::Base::Info=$descr;
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
   
   $Metrics::Base::SNMP=$snmp;
   return $res;
}

#----------------------------------------------------------------------------
sub m2txml_iid {
my ($device,$rcfg,$subtype,$desc,$m,$id,$value,$rfx)=@_;
#my $M='';

   $Metrics::Base::METRIC{name}=$device->{name} || $device->{ip};
   $Metrics::Base::METRIC{cnt}=$device->{metric_cnt};
	$Metrics::Base::METRIC{community}=$device->{community} || 'public';
	$Metrics::Base::METRIC{version}=$device->{version} || '1';
	$Metrics::Base::METRIC{id}=$id;
	$Metrics::Base::METRIC{mname}="$subtype-$id";
	$Metrics::Base::METRIC{subtype}=$subtype;

   $m=~s/--METRIC_IID--/$Metrics::Base::METRIC{id}/g;
   $m=~s/--METRIC_NAME--/$Metrics::Base::METRIC{mname}/g;
   $m=~s/--HOST_NAME--/$Metrics::Base::METRIC{name}/g;

   $m=~s/--METRIC_SNMP_COMMUNITY--/$Metrics::Base::METRIC{community}/g;
   $m=~s/--SNMP_VERSION--/$Metrics::Base::METRIC{version}/g;
   $m=~s/--METRIC_POSITION--/$Metrics::Base::METRIC{cnt}/g;
   $m=~s/--SUBTYPE--/$Metrics::Base::METRIC{subtype}/g;

	$Metrics::Base::METRIC{watch}=0;
	# Es vital testear primero el id antes de 'all'. Porque si no es asi pueden no asignarse
	# monitores de metricas por defecto (trafico,status) !!!!! 
   if (defined $Metrics::Base::AssignedIIDs{$id}) { $Metrics::Base::METRIC{watch}=$Metrics::Base::AssignedIIDs{$id}; }
   elsif (defined $Metrics::Base::AssignedIIDs{'all'}) { $Metrics::Base::METRIC{watch}=$Metrics::Base::AssignedIIDs{'all'}; }
   $m=~s/--WATCH--/$Metrics::Base::METRIC{watch}/g;

   $Metrics::Base::METRIC{status}=&Metrics::Base::get_metric_status($id,"$subtype-$id",$value,$rfx);
   $m=~s/--STATUS--/$Metrics::Base::METRIC{status}/g;

	my $label="$desc ($Metrics::Base::METRIC{name})";
	$m=~s/--METRIC_LABEL--/$label/g;

   $Metrics::Base::InDevice{$Metrics::Base::METRIC{mname}}->{label}=$label;
   $Metrics::Base::InDevice{$Metrics::Base::METRIC{mname}}->{status}=$Metrics::Base::METRIC{status};

	$Metrics::Base::METRIC{cnt}+=1;
	$device->{metric_cnt}=$Metrics::Base::METRIC{cnt};
   return $m;

}



#----------------------------------------------------------------------------
sub m2txml_base {
my ($device,$rcfg,$subtype,$desc,$m)=@_;
#my $M='';

   $Metrics::Base::METRIC{name}=$device->{name} || $device->{ip};
   $Metrics::Base::METRIC{cnt}=$device->{metric_cnt};
	$Metrics::Base::METRIC{community}=$device->{community} || 'public';
   $Metrics::Base::METRIC{version}=$device->{version} || '1';
   $Metrics::Base::METRIC{mname}=$subtype;
   $Metrics::Base::METRIC{subtype}=$subtype;

   $m=~s/--METRIC_NAME--/$Metrics::Base::METRIC{mname}/g;
   $m=~s/--HOST_NAME--/$Metrics::Base::METRIC{name}/g;
   $m=~s/--METRIC_SNMP_COMMUNITY--/$Metrics::Base::METRIC{community}/g;
	$m=~s/--SNMP_VERSION--/$Metrics::Base::METRIC{version}/g;
   $m=~s/--METRIC_POSITION--/$Metrics::Base::METRIC{cnt}/g;
	$m=~s/--SUBTYPE--/$Metrics::Base::METRIC{subtype}/g;

   $Metrics::Base::METRIC{watch} = (defined $Metrics::Base::AssignedIIDs{'all'}) ? $Metrics::Base::AssignedIIDs{'all'} : '0';
   $m=~s/--WATCH--/$Metrics::Base::METRIC{watch}/g;

   $Metrics::Base::METRIC{status}=&Metrics::Base::get_metric_status(-1,$subtype,'','');
   $m=~s/--STATUS--/$Metrics::Base::METRIC{status}/g;

   my $label="$desc ($Metrics::Base::METRIC{name})";
   $m=~s/--METRIC_LABEL--/$label/g;

   $Metrics::Base::InDevice{$Metrics::Base::METRIC{mname}}->{label}=$label;
   $Metrics::Base::InDevice{$Metrics::Base::METRIC{mname}}->{status}=$Metrics::Base::METRIC{status};


   #$Metrics::Base::Desc{$Metrics::Base::METRIC{mname}}->{label}="$desc ($Metrics::Base::METRIC{name})";

	$Metrics::Base::METRIC{cnt}+=1;
	$device->{metric_cnt}=$Metrics::Base::METRIC{cnt};

   return $m;

}

#----------------------------------------------------------------------------
sub m2txml_snmp_simple {
my ($device,$rcfg,$subtype,$desc)=@_;
my $m= '
      <metric name="--METRIC_NAME--">
         <mtype>--MTYPE--</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>--VLABEL--</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>--MODULE--</module>
         <values>--VALUES--</values>
         <oid>--OID--</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
         <version>--SNMP_VERSION--</version>
         <mode>--MODE--</mode>
         <top_value>--TOP_VALUE--</top_value>
         <status>--STATUS--</status>
			<severity>--SEVERITY--</severity>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   #Primero se chequea si el dispositivo responde al OID --------------------
   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0] ERROR=$error";
      return '';
   }

   #-------------------------------------------------------------------------
   @Metrics::Base::IIDs=();
   $Metrics::Base::Error='';
   $Metrics::Base::METRIC{oid}= join ('|', @Metrics::Base::OIDs);
   $Metrics::Base::METRIC{name}=$device->{name} || $device->{ip};
   $Metrics::Base::METRIC{cnt}=$device->{metric_cnt};
   $Metrics::Base::METRIC{community}=$device->{community} || 'public';
   $Metrics::Base::METRIC{version}=$device->{version} || '1';
   $Metrics::Base::METRIC{mname}=$subtype;   #Si no hay iids mname=subtype
   $Metrics::Base::METRIC{subtype}=$subtype;

   $m=~s/--METRIC_NAME--/$Metrics::Base::METRIC{mname}/g;
   $m=~s/--HOST_NAME--/$Metrics::Base::METRIC{name}/g;
   $m=~s/--METRIC_SNMP_COMMUNITY--/$Metrics::Base::METRIC{community}/g;
   $m=~s/--SNMP_VERSION--/$Metrics::Base::METRIC{version}/g;
   $m=~s/--METRIC_POSITION--/$Metrics::Base::METRIC{cnt}/g;
   $m=~s/--SUBTYPE--/$Metrics::Base::METRIC{subtype}/g;

   $m=~s/--MTYPE--/$Metrics::Base::METRIC{mtype}/g;
   $m=~s/--VLABEL--/$Metrics::Base::METRIC{vlabel}/g;
   $m=~s/--MODULE--/$Metrics::Base::METRIC{module}/g;
   $m=~s/--VALUES--/$Metrics::Base::METRIC{values}/g;
   $m=~s/--OID--/$Metrics::Base::METRIC{oid}/g;
   $m=~s/--MODE--/$Metrics::Base::METRIC{mode}/g;
   $m=~s/--TOP_VALUE--/$Metrics::Base::METRIC{top_value}/g;

   $Metrics::Base::METRIC{watch} = (defined $Metrics::Base::AssignedIIDs{'all'}) ? $Metrics::Base::AssignedIIDs{'all'} : '0';
   $m=~s/--WATCH--/$Metrics::Base::METRIC{watch}/g;

   $Metrics::Base::METRIC{status}=&Metrics::Base::get_metric_status(-1,$subtype,'','');
   $m=~s/--STATUS--/$Metrics::Base::METRIC{status}/g;
	$m=~s/--SEVERITY--/$Metrics::Base::METRIC{severity}/g;

   my $label="$Metrics::Base::METRIC{label} ($Metrics::Base::METRIC{name})";
   $m=~s/--METRIC_LABEL--/$label/g;

   $Metrics::Base::InDevice{$Metrics::Base::METRIC{mname}}->{label}=$label;
   $Metrics::Base::InDevice{$Metrics::Base::METRIC{mname}}->{status}=$Metrics::Base::METRIC{status};

   $Metrics::Base::METRIC{cnt}+=1;
   $device->{metric_cnt}=$Metrics::Base::METRIC{cnt};

   return $m;
}



#----------------------------------------------------------------------------
sub m2txml_snmp_class1 {
my ($device,$rcfg,$subtype,$desc)=@_;
my $m= '
      <metric name="--METRIC_NAME--">
         <mtype>--MTYPE--</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>--VLABEL--</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>--MODULE--</module>
         <values>--VALUES--</values>
         <oid>--OID--</oid>
         <community>--METRIC_SNMP_COMMUNITY--</community>
         <version>--SNMP_VERSION--</version>
         <mode>--MODE--</mode>
         <top_value>--TOP_VALUE--</top_value>
         <status>--STATUS--</status>
         <severity>--SEVERITY--</severity>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';



#   #---------------------------------------------------------------
#   @Metrics::Base::OIDs=qw( .1.3.6.1.4.1.9.2.1.46.0|.1.3.6.1.4.1.9.2.1.47.0 );
#   $Metrics::Base::METRIC{label}='Errores en los buffers de memoria';
#   $Metrics::Base::METRIC{mtype}='STD_BASE';
#   $Metrics::Base::METRIC{vlabel}='Num';
#   $Metrics::Base::METRIC{module}='mod_snmp_get';
#   $Metrics::Base::METRIC{values}='Buffer Failures|No Free Memory';
#   $Metrics::Base::METRIC{mode}='GAUGE';
#   $Metrics::Base::METRIC{top_value}=1;
#   #---------------------------------------------------------------


   #---------------------------------------------------------------
	# Se obtienen los parametros de la metrica de BD (cfg_monitor_snmp)
	my $what='mtype,vlabel,label,items,mode,oid,top_value,get_iid,module';
   my $where="subtype=\'$subtype\'";
	my $store=$Metrics::Base::SNMP->store();
	my $dbh=$Metrics::Base::SNMP->dbh();
   my $mdata=$store->get_from_db($dbh,$what,'cfg_monitor_snmp',$where);

   if (! defined $mdata->[0])  {
      print "[ERROR] NO HAY DATOS PARA GENERAR $subtype\n";
     	return; 
   }
   #---------------------------------------------------------------


   push ( @Metrics::Base::OIDs, $mdata->[0]->['oid'] );
   $Metrics::Base::METRIC{'label'}=$mdata->[0]->['label'];
   $Metrics::Base::METRIC{'mtype'}=$mdata->[0]->['mtype'];
   $Metrics::Base::METRIC{'vlabel'}=$mdata->[0]->['vlabel'];
   $Metrics::Base::METRIC{'module'}=$mdata->[0]->['module'];
   $Metrics::Base::METRIC{'values'}=$mdata->[0]->['items'];
   $Metrics::Base::METRIC{'mode'}=$mdata->[0]->['mode'];
   $Metrics::Base::METRIC{'top_value'}=$mdata->[0]->['top_value'];


   #Primero se chequea si el dispositivo responde al OID --------------------
   my $error=&Metrics::Base::check_snmp_oid($device,$Metrics::Base::OIDs[0]);
   if ($error) {
      $Metrics::Base::Error="NO RESPONDE AL OID=$Metrics::Base::OIDs[0]";
      return '';
   }

   #-------------------------------------------------------------------------
   @Metrics::Base::IIDs=();
   $Metrics::Base::Error='';
   $Metrics::Base::METRIC{'oid'}= join ('|', @Metrics::Base::OIDs);
   $Metrics::Base::METRIC{'name'}=$device->{'name'} || $device->{'ip'};
   $Metrics::Base::METRIC{'cnt'}=$device->{'metric_cnt'};
   $Metrics::Base::METRIC{'community'}=$device->{'community'} || 'public';
   $Metrics::Base::METRIC{'version'}=$device->{'version'} || '1';
   $Metrics::Base::METRIC{'mname'}=$subtype;   #Si no hay iids mname=subtype
   $Metrics::Base::METRIC{'subtype'}=$subtype;

   $m=~s/--METRIC_NAME--/$Metrics::Base::METRIC{'mname'}/g;
   $m=~s/--HOST_NAME--/$Metrics::Base::METRIC{'name'}/g;
   $m=~s/--METRIC_SNMP_COMMUNITY--/$Metrics::Base::METRIC{'community'}/g;
   $m=~s/--SNMP_VERSION--/$Metrics::Base::METRIC{'version'}/g;
   $m=~s/--METRIC_POSITION--/$Metrics::Base::METRIC{'cnt'}/g;
   $m=~s/--SUBTYPE--/$Metrics::Base::METRIC{subtype}/g;

   $m=~s/--MTYPE--/$Metrics::Base::METRIC{'mtype'}/g;
   $m=~s/--VLABEL--/$Metrics::Base::METRIC{'vlabel'}/g;
   $m=~s/--MODULE--/$Metrics::Base::METRIC{'module'}/g;
   $m=~s/--VALUES--/$Metrics::Base::METRIC{'values'}/g;
   $m=~s/--OID--/$Metrics::Base::METRIC{'oid'}/g;
   $m=~s/--MODE--/$Metrics::Base::METRIC{'mode'}/g;
   $m=~s/--TOP_VALUE--/$Metrics::Base::METRIC{'top_value'}/g;

   $Metrics::Base::METRIC{'watch'} = (defined $Metrics::Base::AssignedIIDs{'all'}) ? $Metrics::Base::AssignedIIDs{'all'} : '0';
   $m=~s/--WATCH--/$Metrics::Base::METRIC{'watch'}/g;

   $Metrics::Base::METRIC{'status'}=&Metrics::Base::get_metric_status(-1,$subtype,'','');
   $m=~s/--STATUS--/$Metrics::Base::METRIC{'status'}/g;
   $m=~s/--SEVERITY--/$Metrics::Base::METRIC{'severity'}/g;

   my $label="$Metrics::Base::METRIC{'label'} ($Metrics::Base::METRIC{'name'})";
   $m=~s/--METRIC_LABEL--/$label/g;


   $Metrics::Base::InDevice{$Metrics::Base::METRIC{'mname'}}->{'label'}=$label;
   $Metrics::Base::InDevice{$Metrics::Base::METRIC{'mname'}}->{'status'}=$Metrics::Base::METRIC{'status'};

   $Metrics::Base::METRIC{'cnt'}+=1;
   $device->{'metric_cnt'}=$Metrics::Base::METRIC{'cnt'};

   return $m;
}




#----------------------------------------------------------------------------
sub escape  {
my $data=shift;

	#OJO. LAs comillas impactan al javascript !!!! 
#   $data =~ s/\"//g;
#   $data =~ s/\'//g;
#   $data =~ s/\&//g;

	#ojo con el <> porque pueden tener impacto a la hora de generar el txml
#   $data =~ s/\<//g;
#   $data =~ s/\>//g;

	#Todo lo que sea distinto del grupo de caracteres permitido me lo pulo.
	#ES LO MAS SEGURO !!! Porque si hay algun caracter raro no funciona el XMLin
	$data=~s/[^\w\s\/\\\(\)\[\]\{\}\:\.\,\-\_\@]//g;

	#trim
	$data=~s/^\s*(.*?)\s*?/$1/g;

 
#   #$data =~ s/\s/_/g;
#   #$data =~ s/\//_/g;
#   #$data =~ s/\,/_/g;
#   #$data =~ s/\:/_/g;

 
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
# Solo es necesaria en el calculo del oid de las metricas que no tengan iids 
# asociados, porque en este caso la validacion la hace get_snmp_vector
sub check_snmp_oid {
my ($device,$oid)=@_;
my %snmpcfg=();

   $snmpcfg{host_ip}=$device->{ip};
   $snmpcfg{community}=$device->{community} || 'public';
   $snmpcfg{version}= $device->{version} || '1';
	$snmpcfg{oid}=$oid;
   my $name=$device->{name} || $device->{ip};

   my $snmp=Crawler::SNMP->new();
   if (!defined $snmp) {
      $Metrics::Base::Error='ERROR AL CREAR OBJETO SNMP';
      return undef;
   }

   my $res=$snmp->core_snmp_get(\%snmpcfg);
	my $rc=$snmp->err_num();

   return $rc;
}

#----------------------------------------------------------------------------
sub check_ipserv_params {
my ($m,$suplied)=@_;
#$suplied es del tipo (p. ej): 'url=http://sliromrtg1|type=GET'

	my $rcfgbase=conf_base($FILE_CONF);

	my $latency=Crawler::Latency->new(cfg=>$rcfgbase);
 	my $store=$latency->create_store();
	my $dbh=$store->open_db();

	my $rres=$store->get_from_db($dbh,'params','cfg_monitor',"monitor='$m'");
   my @par=split(/\|/,$rres->[0][0]);
	if ((scalar @par) == 0) { return undef };

	my %PARAMS=();
	foreach my $p (@par) { $PARAMS{$p}=''; }

   #my $needed=$PARAMS{$m};
   #my $needed=\%PARAMS;
   #if (! defined $needed) { return undef };

   my @p=split(/\|/,$suplied);
   foreach my $px (@p) {
      my ($k,$v)=split('=',$px,2);
      if (defined $PARAMS{$k}) { $PARAMS{$k}=$v; }
#print "*****> $k=$v\n";
#      if (defined $v) {$rcfgbase->{$k}->[0]=$v; print "$subtype PARAMS=>$k=$v\n";}
   }
   return \%PARAMS;
}

#----------------------------------------------------------------------------
sub m2txml_ipserv {
my ($device,$rcfg,$subtype)=@_;

my $m= '
      <metric name="--METRIC_NAME--">
         <mtype>--MTYPE--</mtype>
         <subtype>--SUBTYPE--</subtype>
         <vlabel>--VLABEL--</vlabel>
         <label>--METRIC_LABEL--</label>
         <module>--MODULE--</module>
         <values>--VALUES--</values>
         <monitor>--MONITOR--</monitor>
         <params>--PARAMS--</params>
         <mode>--MODE--</mode>
         <top_value>--TOP_VALUE--</top_value>
         <status>--STATUS--</status>
         <severity>--SEVERITY--</severity>
         <watch>--WATCH--</watch>
         <graph>--METRIC_POSITION--</graph>
      </metric>
';

   #--------------------------------------------------------------------
   $Metrics::Base::METRIC{name}=$device->{name} || $device->{ip};
   $Metrics::Base::METRIC{cnt}=$device->{metric_cnt};
   $device->{metric_cnt}=$Metrics::Base::METRIC{cnt}+1;

   $Metrics::Base::METRIC{mname} = (defined $rcfg->{'metric_name'}->[0]) ? $rcfg->{'metric_name'}->[0] : $subtype;
   $m=~s/--METRIC_NAME--/$Metrics::Base::METRIC{mname}/g;

   $m=~s/--HOST_NAME--/$Metrics::Base::METRIC{name}/g;
   $m=~s/--METRIC_POSITION--/$Metrics::Base::METRIC{cnt}/g;
   $m=~s/--SUBTYPE--/$subtype/g;
   $m=~s/--MONITOR--/$Metrics::Base::METRIC{monitor}/g;
   $m=~s/--PARAMS--/$Metrics::Base::METRIC{params}/g;

   $m=~s/--MTYPE--/$Metrics::Base::METRIC{mtype}/g;
   $m=~s/--VLABEL--/$Metrics::Base::METRIC{vlabel}/g;
   $m=~s/--MODULE--/$Metrics::Base::METRIC{module}/g;
   $m=~s/--VALUES--/$Metrics::Base::METRIC{values}/g;
   $m=~s/--MODE--/$Metrics::Base::METRIC{mode}/g;
   $m=~s/--TOP_VALUE--/$Metrics::Base::METRIC{top_value}/g;
   $m=~s/--WATCH--/0/g;

   my $mname=$rcfg->{'metric_name'}->[0];
   $Metrics::Base::METRIC{status}=&Metrics::Base::get_metric_status(-1,$mname,'','');
   $m=~s/--STATUS--/$Metrics::Base::METRIC{status}/g;
   $m=~s/--SEVERITY--/$Metrics::Base::METRIC{severity}/g;

   my $label="$Metrics::Base::METRIC{label} ($Metrics::Base::METRIC{name})";
   $m=~s/--METRIC_LABEL--/$label/g;

   $Metrics::Base::InDevice{$Metrics::Base::METRIC{mname}}->{label}=$label;
   $Metrics::Base::InDevice{$Metrics::Base::METRIC{mname}}->{status}=$Metrics::Base::METRIC{status};

   return $m;
}



1;
__END__
