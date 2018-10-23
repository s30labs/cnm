#######################################################################################################
# Fichero: ProvisionLite.pm
# Revision: Ver $VERSION
# Descripcion:
########################################################################################################
package ProvisionLite;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;

@EXPORT_OK = qw();
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);
$VERSION = '1.00';

#------------------------------------------------------------------------
use Crawler::Store;
use Crawler::SNMP;
use Crawler::WSClient;
use ONMConfig;
use XMLConfig;
use XML::Simple;
use Data::Dumper;
use Fcntl qw(:flock);
#use Stdout;
#use Metrics::Base;
use Digest::MD5 qw(md5_hex);
use NetAddr::IP;
use Monitor;
use Net::Ping;
use IO::Select;
use IO::Socket::INET;
use IPC::Shareable;
#use Storable;
use Socket;
use Nmap::Parser;

use ATypes;
#------------------------------------------------------------------------
#my $FILE_CONF='/cfg/onm.conf';

#------------------------------------------------------------------------
use Sys::Syslog qw(:DEFAULT setlogsock);
use Logger;
use constant FACILITY => 'local0';
use constant LOG_NONE => 0;
use constant LOG_SYSLOG => 1;
use constant LOG_STDOUT => 2;
use constant LOG_BOTH => 3;

my $LOGMSG_1='';

my %LOG_PRIORITY = (

   'debug' => 0,
   'info' => 1,
   'notice' => 2,
   'warning' => 3,
   'error' => 4,
   'crit' =>5,
   'alert' => 6,
   'emerg' => 7,
);

#-----------------------------------------------------------------------
%ProvisionLite::EXCLUDED_OIDS = (
	'RFC1213-MIB::ipRouteTable'=> 1,
	'CISCO-CCM-MIB::ccmPhoneTable'=>1,
);

#-----------------------------------------------------------------------
@ProvisionLite::LABEL_EXPR=();

#-----------------------------------------------------------------------
use ProvisionLite::disk_mibhost;
use ProvisionLite::traffic_mibii_if;
use ProvisionLite::pkts_type_mibii_if;
use ProvisionLite::pkts_type_mibii_if_ext;
use ProvisionLite::pkts_type_mibrmon_if;
use ProvisionLite::pkts_discard_mibii_if;
use ProvisionLite::errors_mibii_if;
use ProvisionLite::status_mibii_if;
use ProvisionLite::arp_mibii_cnt;
use ProvisionLite::brocade_frames_port;
use ProvisionLite::brocade_status_port;
use ProvisionLite::novell_nw_disk_dir;
use ProvisionLite::novell_nw_disk_usage;
use ProvisionLite::stp_port_status;
use ProvisionLite::snmp_class2_default;

#-----------------------------------------------------------------------
%ProvisionLite::Class2fx = (

   #------------------------------------------------------------
   'disk_mibhost' => \&ProvisionLite::disk_mibhost::disk_mibhost,

   #------------------------------------------------------------
   'traffic_mibii_if' => \&ProvisionLite::traffic_mibii_if::traffic_mibii_if,
   'pkts_type_mibii_if' => \&ProvisionLite::pkts_type_mibii_if::pkts_type_mibii_if,
   'pkts_type_mibii_if_ext' => \&ProvisionLite::pkts_type_mibii_if_ext::pkts_type_mibii_if_ext,
   'pkts_type_mibrmon_if' => \&ProvisionLite::pkts_type_mibrmon_if::pkts_type_mibrmon_if,
   'pkts_discard_mibii_if' => \&ProvisionLite::pkts_discard_mibii_if::pkts_discard_mibii_if,
   'errors_mibii_if' => \&ProvisionLite::errors_mibii_if::errors_mibii_if,
   'status_mibii_if' => \&ProvisionLite::status_mibii_if::status_mibii_if,
   'arp_mibii_cnt' => \&ProvisionLite::arp_mibii_cnt::arp_mibii_cnt,

   #------------------------------------------------------------
   'stp_port_status' => \&ProvisionLite::stp_port_status::stp_port_status,

   #------------------------------------------------------------
   'brocade_frames_port' => \&ProvisionLite::brocade_frames_port::brocade_frames_port,
   'brocade_status_port' => \&ProvisionLite::brocade_status_port::brocade_status_port,

   #------------------------------------------------------------
   'novell_nw_disk_dir' => \&ProvisionLite::novell_nw_disk_dir::novell_nw_disk_dir,
   'novell_nw_disk_usage' => \&ProvisionLite::novell_nw_disk_usage::novell_nw_disk_usage,

   #------------------------------------------------------------
   'snmp_class2_default' => \&ProvisionLite::snmp_class2_default::snmp_class2_default,

);
#-----------------------------------------------------------------------
#-----------------------------------------------------------------------


#-------------------------------------------------------------------------------
#	my $provision=ProvisionLite->new(log_level=>$log_level, log_mode=>$log_mode );
# 	$provision->init();
#-------------------------------------------------------------------------------

@ProvisionLite::metric_rules=();
@ProvisionLite::default_metrics=();
%ProvisionLite::assigned_watches=();
%ProvisionLite::assigned_status=();

#----------------------------------------------------------------------------
@ProvisionLite::default_snmp_communties = qw( public cnmrocom );
%ProvisionLite::db_snmp_communties=();

#----------------------------------------------------------------------------
$ProvisionLite::NO_SNMP_RESPONSE=0;
$ProvisionLite::SNMP_FORCED=0;
$ProvisionLite::NUM_REMOTE_ALERTS_ASSIGNED=0;

#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

bless {
      _istore =>$arg{'istore'} || undef,
      _dbh =>$arg{'dbh'} || undef,
      _wsclient =>$arg{'wsclient'} || undef,
      _snmp =>$arg{'snmp'} || undef,
      _wbem =>$arg{'wbem'} || undef,
      _xagent =>$arg{'xagent'} || undef,
      _latency =>$arg{'latency'} || undef,
		_cfg =>$arg{'cfg'} || undef,
		_default_metrics => [],
		_rc =>$arg{'rc'} || undef,
		_rcstr =>$arg{'rcstr'} || undef,
      _log_mode =>$arg{'log_mode'} || LOG_SYSLOG,
      _log_level =>$arg{'log_level'} || 'info',
      _tag =>$arg{'tag'} || 'tag',
	}, $class;

}



#----------------------------------------------------------------------------
# cfg
#----------------------------------------------------------------------------
sub cfg {
my ($self,$cfg) = @_;
   if (defined $cfg) {
      $self->{_cfg}=$cfg;
   }
   else {
      return $self->{_cfg};

   }
}

#----------------------------------------------------------------------------
# istore
# NO SE PUEDE LLAMAR store PARA EVITAR CONFLICTOS CON EL MODULO Storable
#----------------------------------------------------------------------------
sub istore  {
my ($self,$istore) = @_;
   if (defined $istore) {
      $self->{_istore}=$istore;
   }
   else {
      return $self->{_istore};
   }
}

#----------------------------------------------------------------------------
# dbh
#----------------------------------------------------------------------------
sub dbh  {
my ($self,$dbh) = @_;
   if (defined $dbh) {
      $self->{_dbh}=$dbh;
   }
   else {
      return $self->{_dbh};
   }
}

#----------------------------------------------------------------------------
# wsclient
#----------------------------------------------------------------------------
sub wsclient {
my ($self,$wsclient) = @_;
   if (defined $wsclient) {
      $self->{_wsclient}=$wsclient;
   }
   else {
      return $self->{_wsclient};
   }
}


#----------------------------------------------------------------------------
# snmp
#----------------------------------------------------------------------------
sub snmp {
my ($self,$snmp) = @_;
   if (defined $snmp) {
      $self->{_snmp}=$snmp;
   }
   else {
      return $self->{_snmp};
   }
}

#----------------------------------------------------------------------------
# wbem
#----------------------------------------------------------------------------
sub wbem {
my ($self,$wbem) = @_;
   if (defined $wbem) {
      $self->{_wbem}=$wbem;
   }
   else {
      return $self->{_wbem};
   }
}

#----------------------------------------------------------------------------
# xagent
#----------------------------------------------------------------------------
sub xagent {
my ($self,$xagent) = @_;
   if (defined $xagent) {
      $self->{_xagent}=$xagent;
   }
   else {
      return $self->{_xagent};
   }
}

#----------------------------------------------------------------------------
# latency
#----------------------------------------------------------------------------
sub latency {
my ($self,$latency) = @_;
   if (defined $latency) {
      $self->{_latency}=$latency;
   }
   else {
      return $self->{_latency};
   }
}

#----------------------------------------------------------------------------
# default_metrics
#----------------------------------------------------------------------------
sub default_metrics {
my ($self,$default_metrics) = @_;
   if (defined $default_metrics) {
      $self->{_default_metrics}=$default_metrics;
   }
   else {
      return $self->{_default_metrics};
   }
}


#----------------------------------------------------------------------------
# rc
#----------------------------------------------------------------------------
sub rc {
my ($self,$rc) = @_;
   if (defined $rc) {
      $self->{_rc}=$rc;
   }
   else {
      return $self->{_rc};
   }
}

#----------------------------------------------------------------------------
# rcstr
#----------------------------------------------------------------------------
sub rcstr {
my ($self,$rcstr,$reset) = @_;
   if (defined $rcstr) {
		if ($reset) { $self->{_rcstr}=""; }
      else { $self->{_rcstr} .= $rcstr; }
   }
   else {
      return $self->{_rcstr};
   }
}


#----------------------------------------------------------------------------
# log_mode
#----------------------------------------------------------------------------
sub log_mode {
my ($self,$mode) = @_;
   if (defined $mode) {
      $self->{_log_mode}=$mode;
   }
   else {
      return $self->{_log_mode};
   }
}

#----------------------------------------------------------------------------
# log_level
#----------------------------------------------------------------------------
sub log_level {
my ($self,$level) = @_;
   if (defined $level) {
      $self->{_log_level}=$level;
   }
   else {
      return $self->{_log_level};
   }
}

#----------------------------------------------------------------------------
# tag
#----------------------------------------------------------------------------
sub tag {
my ($self,$tag) = @_;
   if (defined $tag) {
      $self->{_tag}=$tag;
   }
   else {
      return $self->{_tag};
   }
}


#----------------------------------------------------------------------------
# log
#----------------------------------------------------------------------------
sub log  {
my ($self,$level,@arg) = @_;

   #Valido el modo de 'logging'--------------------------------
   my $mode=$self->log_mode();
   if ($mode == LOG_NONE) {return;}

   #Valido el nivel de 'logging' configurado ------------------
   my $level_cfg=$self->log_level();
#syslog($level,'%s',"level=$level level_cfg=$level_cfg mode=$mode ++++");
   if ( $LOG_PRIORITY{$level} < $LOG_PRIORITY{$level_cfg} ) {return;}

   my $v=join('',@arg);
   return if ($v eq $LOGMSG_1);
   $LOGMSG_1=$v;

   if ($level !~ /[debug|notice|warning|crit]/i) {$level='notice';}

  # my ($secs, $microsecs) = gettimeofday;
  # my $t="\[$secs:$microsecs\]";
  # my $msg = join('',$t,@arg) || "Registro de log";

   my $msg = join('',@arg) || "Registro de log";

   my ($pack,$filename,$line) = caller;
   $msg .= " ($filename $line)\n" unless $msg =~ /\n$/;
   #my $msgq=quotemeta($msg);
   #$msg=~s/\%/\\\%/g;
   $msg=~s/%/p/g;

   if ( $mode & 1) { syslog($level,'%s',$msg); }
   if ( $mode & 2) { print "$msg"; }

#   if (($mode == LOG_SYSLOG) || ($mode == LOG_BOTH)) {syslog($level,$msg);}
#   if (($mode == LOG_STDOUT) || ($mode == LOG_BOTH)) {print "[$level]:$msg\n";}

   #if ($level =~ /[crit]/i) {die @arg;}  ##### ?????
}







#----------------------------------------------------------------------------
# FUNCTION: init
# DESCRIPTION:
#
#	Inicializa los parametros necesarios de acceso a BD segun esta definido en
#	el fichero de configuracion. Esto incluye el objeto store y dbh.
#	Tambien inicializa el syslog
#
# INPUT:
#     $file : Fichero xml
#     $range : Rango
#
# OUTPUT:
#----------------------------------------------------------------------------
sub init  {
my ($self, $dbparams) = @_;

   init_log();

	my $rcfgbase=conf_base($FILE_CONF);
	my $db_server=(exists $dbparams->{'db_server'}) ? $dbparams->{'db_server'} : $rcfgbase->{'db_server'}->[0];
	my $db_name=(exists $dbparams->{'db_name'}) ? $dbparams->{'db_name'} : $rcfgbase->{'db_name'}->[0];
	my $db_user=(exists $dbparams->{'db_user'}) ? $dbparams->{'db_user'} : $rcfgbase->{'db_user'}->[0];
	my $db_pwd=(exists $dbparams->{'db_pwd'}) ? $dbparams->{'db_pwd'} : $rcfgbase->{'db_pwd'}->[0];

	my $STORE_PATH=$rcfgbase->{'store_path'}->[0];
	my $mserver=$rcfgbase->{'mserver'};
	my $pserver=$rcfgbase->{'pserver'};
	my $log_level=$self->log_level();
	my $log_mode=$self->log_mode();

	# STORE ------------------------------------
	my $store=Crawler::Store->new( store_path=>$STORE_PATH,
   	                            db_server=>$db_server,
      	                         db_name=>$db_name,
         	                      db_user=>$db_user,
            	                   db_pwd=>$db_pwd,
											 cfg=>$rcfgbase,
               	                log_level=>$log_level, log_mode=>$log_mode );

	my $dbh = (exists $dbparams->{'dbh'}) ? $dbparams->{'dbh'} : $store->open_db();
	#my $dbh=$store->open_db();

	$self->dbh($dbh);
	$self->cfg($rcfgbase);
	$self->istore($store);

   my $wsclient=Crawler::WSClient->new( store_path=>$STORE_PATH, cfg=>$rcfgbase );
	$wsclient->mserver($mserver);
	$wsclient->pserver($pserver);
   $self->wsclient($wsclient);
   $store->wsclient($wsclient);
	
	my $snmp=Crawler::SNMP->new( store_path=>$STORE_PATH, cfg=>$rcfgbase, 'log_mode'=>$log_mode, 'log_level' => $log_level, mode_flag=>{rrd=>0, alert=>0} );
	$snmp->store($store);
	#$snmp->reset_mapping(); Se hace en la rutina de provision
	$self->snmp($snmp);

   my $wbem=Crawler::Wbem->new( store_path=>$STORE_PATH, cfg=>$rcfgbase, 'log_mode'=>$log_mode, 'log_level' => $log_level, mode_flag=>{rrd=>0, alert=>0} );
   $wbem->store($store);
	$self->wbem($wbem);

   my $xagent=Crawler::Xagent->new( store_path=>$STORE_PATH, cfg=>$rcfgbase, 'log_mode'=>$log_mode, 'log_level' => $log_level, mode_flag=>{rrd=>0, alert=>0} );
   $xagent->store($store);
   $xagent->dbh($dbh);
   $self->xagent($xagent);

   my $latency=Crawler::Latency->new( store_path=>$STORE_PATH, cfg=>$rcfgbase, 'log_mode'=>$log_mode, 'log_level' => $log_level, mode_flag=>{rrd=>0, alert=>0} );
   $latency->store($store);
   $self->latency($latency);

}


#-------------------------------------------------------------------------------
# FUNCTION: get_devices_from_csv
# DESCRIPTION:
#
#
# INPUT:
#     $file : Fichero csv
#     $vector : Vector de dispositivos (fichero csv)
#					 nombre.dominio,ip,community,version,tipo,sysoid
#
# OUTPUT:
#-------------------------------------------------------------------------------
sub get_devices_from_csv {
my ($self,$file,$vector)=@_;

	open (F,"<$file");
   while (<F>) {
   	chomp;
      my @d=split(/\,/,$_);
		if (! scalar @d) {next; }
		#n+d,ip,community,version,type,sysoid,xxxx
		my ($n,$d)=($d[0],'');
		if ($d[0]=~/^(\w+)\.(\S+)$/) { ($n,$d)=($1,$2); }
      push @$vector, { name=>$n, domain=>$d, ip=>$d[1], community=>$d[2], version=>$d[3], type=>$d[4], sysoid=>$d[5] };
   }

	close F;
}

#-------------------------------------------------------------------------------
# FUNCTION: get_devices_from_csv_web
# DESCRIPTION:
#
#
# INPUT:
#     $file : Fichero csv con un separador especial y con la primera fila indicando los campos.
#     $vector : Vector de dispositivos (fichero csv)
#               nombre.dominio,ip,community,version,tipo,sysoid
#
# name&|&domain&|&ip&|&sysloc&|&sysdesc&|&sysoid&|&type&|&status&|&community&|&version&|&perfil_organizativo&|&host_idx&|&wbem_user&|&wbem_pwd&|&columna13&|&columna11&|&columna12&|&columna14&|&columna15&|&columna16&|&columna18&|&columna19
#portatil_fml&|&&|&10.1.254.70&|&Desconocido&|&Desconocido&|&Desconocido&|&xagent-register&|&0&|&public&|&1&|&&|&1&|&&|&&|&n.a&|&-&|&-&|&-&|&-&|&-&|&-&|&
#
# OUTPUT:
#-------------------------------------------------------------------------------
sub get_devices_from_csv_web {
my ($self,$file,$vector,$separator)=@_;

	my $dbh=$self->dbh();
	my $STORE=$self->istore();
	my $dir_base='/var/www/html/onm/tmp/';
	my $file_path=$dir_base.$file;
   open (F,"<$file_path");
	my $first=1;
	my $nfixed=15;	#Contiene el numero de campos por defecto de la tabla devices.
	my $ncols=0;

 	my $rv=$STORE->get_from_db($dbh,'id,descr','devices_custom_types');
	my %name2columnax=();
	# Mapeo de columna15->a107 o columna16="Proveedor..."
   foreach my $i (@$rv) {
      my $col='columna'.$i->[0];
		my $n=uc $i->[1];
      $name2columnax{$n}=$col;
		#$self->log('info',"get_devices_from_csv_web **FML0o** N=$n COL=$col ");
   }

	# Contiene los campos de usuario presentes en el fichero
	my %custom_in_file=();
   while (<F>) {
      chomp;
      my @d=split(/$separator/,$_);
		my %custom=();

		if ($first) {
			$first=0;
			#Obtengo el mapeo de campos custom del fichero de indice a nombre
			$ncols=scalar(@d);
			for my $i ($nfixed..$ncols-1) { $custom_in_file{$i}=$d[$i]; }
			next;
		}
		else {
      	if (! scalar @d) {next; }
#$self->log('info',"get_devices_from_csv_web ($dir_base$file):: $d[0] $d[1] $d[2] $d[8] $d[9] $d[6] $d[5]");
      	#push @$vector, { name=>$d[0], domain=>$d[1], ip=>$d[2], community=>$d[8], version=>$d[9], type=>$d[6], sysoid=>$d[5] };

			for my $i ($nfixed..$ncols-1) {
				if (!$d[$i]){$d[$i]='-';}
				my $col_name=uc $custom_in_file{$i}; #a105
				my $columnax=$name2columnax{$col_name};
#$self->log('info',"get_devices_from_csv_web **FML0** I=$i col_name=$col_name columnax=$columnax D=$d[$i]");
				$custom{$columnax}=$d[$i];
			}

#while (my($k,$v)=each %custom) {
#$self->log('info',"get_devices_from_csv_web **FML** K=$k -> V=$v");
#print "**FML** K=$k -> V=$v\n";  }
#NOMBRE&|&DOMINIO&|&IP&|&LOCALIZACION&|&DESCRIPCION&|&OID&|&MAC&|&CRIT&|&TIPO&|&ESTADO&|&COMUNIDAD&|&VERSION&|&PERFIL ORGANIZATIVO&|&GESTOR&|&PROVEEDOR&|&FABRICANTE&|&RESPONSABE INTERNO&|&DESCRIPCION
			
      	push @$vector, { name=>$d[0], domain=>$d[1], ip=>$d[2], sysloc=>$d[3], sysdesc=>$d[4], sysoid=>$d[5], mac=>$d[6], critic=>$d[7], type=>$d[8], status=>$d[9], community=>$d[10], version=>$d[11], perfil_organizativo=>$d[12], host_idx=>$d[13], geodata=>$d[14], custom=>\%custom };
		}
   }
   close F;

   # Se elimina el fichero para no acumular basura en el directorio tmp del serv. web
   unlink $file_path;

}


#-------------------------------------------------------------------------------
# FUNCTION: get_devices_from_xml
# DESCRIPTION:
#
#
# INPUT:
#     $file : Variable xml
#
#<datos>
#  <item>
#    <DNS>-</DNS>
#    <IP>10.1.254.229</IP>
#    <OID>.1.3.6.1.4.1.8072.3.2.10</OID>
#    <PING>SI</PING>
#    <SNMP>SI (v1,public)</SNMP>
#    <SYSNAME>cnm-devel</SYSNAME>
#    <id>1</id>
#    <status>0</status>
#  </item>
#</datos>
#
#     $vector : Vector de dispositivos (fichero csv)
#               nombre.dominio,ip,community,version,tipo,sysoid
#
# OUTPUT:
#-------------------------------------------------------------------------------
sub get_devices_from_xml {
my ($self,$xml,$vector)=@_;

	my $xs1 = XML::Simple->new();
	my $data = $xs1->XMLin($xml);
	#print Dumper($data);

open (F,'>/tmp/kk');
print F Dumper($data);

	if (exists $data->{'item'}->{'IP'}) {
		my $item=$data->{'item'};

   	my $dns=$item->{'DNS'};
	   my $sysname=$item->{'SYSNAME'};
   	my ($n,$d,$c,$v)=($sysname,'.','public',1);
   	if (($dns) && ($dns=~/^(\w+)\.(\S+)$/) ) { ($n,$d)=($1,$2); }
   	my $ip=$item->{'IP'};
	   my $snmp=$item->{'SNMP'};
   	if ($snmp=~/SI \(v(\d+),(\w+)\)/) {$v=$1; $c=$2; }
   	my $sysoid=$dns=$item->{'OID'};

print F "name=>$n, domain=>$d, ip=>$ip, community=>$c, version=>$v, type=>'auto', sysoid=>$sysoid\n";

   	push @$vector, { name=>$n, domain=>$d, ip=>$ip, community=>$c, version=>$v, type=>'auto', sysoid=>$sysoid };
	}

	else {
		my $N = scalar( keys %{$data->{'item'}->{'IP'}} );
		for (my$i=1; $i<=$N; $i++) {
			my $item=$data->{'item'}->{$i};

		   my $dns=$item->{'DNS'};
   		my $sysname=$item->{'SYSNAME'};
	   	my ($n,$d,$c,$v)=($sysname,'.','public',1);
	   	if (($dns) && ($dns=~/^(\w+)\.(\S+)$/) ) { ($n,$d)=($1,$2); }
   		my $ip=$item->{'IP'};
   		my $snmp=$item->{'SNMP'};
	   	if ($snmp=~/SI \(v(\d+),(\w+)\)/) {$v=$1; $c=$2; }
   		my $sysoid=$dns=$item->{'OID'};
print F "name=>$n, domain=>$d, ip=>$ip, community=>$c, version=>$v, type=>'auto', sysoid=>$sysoid\n";

   		push @$vector, { name=>$n, domain=>$d, ip=>$ip, community=>$c, version=>$v, type=>'auto', sysoid=>$sysoid };
		}
	}
close F;
}


#-------------------------------------------------------------------------------
sub prov_del_metric_data {
my ($self,$in)=@_;

   $self->rc(-1);
   $self->rcstr("",1);
   $self->log('info',"prov_del_metric_data::[INFO]");

   if (! exists $in->{'id_dev'}) { return; }
   if (! exists $in->{'subtype'}) { return; }
   if ($in->{'subtype'} eq '') { return; }

	my $subtype=$in->{'subtype'};
	my @id_devs=split(',',$in->{'id_dev'});
	foreach my $id_dev (@id_devs) {

		my $file='/opt/data/rrd/elements/'.sprintf("%010d",$id_dev).'/'.$subtype.'*';
		my $rc = unlink glob($file);

		if ($rc) {
	   	$self->rcstr("Eliminados datos de metricas de dispositivo ($id_dev) subtype=$subtype ($rc)\n",0);
   		$self->rc(0);
		}
		else { 
		   $self->rcstr("Error al eliminar datos de metricas de dispositivo ($id_dev) subtype=$subtype ($rc)\n",0);
   		$self->rc(1);
		}
	}

}


#-------------------------------------------------------------------------------
# FUNCTION: prov_do_set_device_metric
# DESCRIPTION:
#
# 	Provisiona dispositivo + metricas.
# 	Los dispositivos se pueden especificar de 2 formas:
# 	a) -in fichero.csv (n+d,ip,community,version,type,sysoid,xxxx)
#		R17O4302.of.cm.es,10.204.172.254,public,1,routers.oficinas.Telefonica.cisco-17xx.adsl,enterprises.9.1.416,no Modelado
# 	b) -ip -name -type -c community [-oid ...]
# 	Pregunta al dispositivo por snmp el sysloc,sysdesc
# 	Busca nombre a partir de dns o sysname y en el peor de los casos deja la ip
# 	como nombre
#
#	INPUT:
#	 $in: Referencia a un hash con los parametros de entrada.
#		id_dev 	=> Lista de id_dev separados por comas. En este caso  no hay que almacenar el dispositivo
#						Solo se provisionan metricas.
#		csv 		=> Fichero csv con la lista de dispositivos a provisionar.
#
#		xml 		=> Variable que contiene el xml con la lista de dispositivos a provisionar.
#				 		(Proviene de un audit)
#		
#		name => Nombre del dispositivo
#		ip => IP del dispositivo
#		type => Tipo del dispositivo
#		c => Community SNMP
#		v => Version SNMP
#		oid => SysObjectID
#
#		verbode => 1/0
#		debug => 1/0
#		custom => Especifica el path de un fichero txml con metricas definidas
#					 por usuario.
#		replace => 1/0 Permite reemplazar tadas las metricas del dispositivo (1)
#		app
#		txml => Especifica un fichero con las metricas a asociar al dispositivo.
#				  Si no se especifica nada, este fichero es construido internamente (txmlgen)	
#
#		cid => CLIENT ID
#		hidx => CLIENT ID
#
#	OUTPUT:
#
#		0 => OK
#		1 => ERROR
#
# ------------------------------------------------------------------------
#	GENERAR PLANTILLA DESDE ASISTENTE
#	$rc_sq = store_qactions('setmetric',"id_dev=$id_dev;init=2;default=$aux",'','GENERAR PLANTILLA DESDE ASISTENTE');
#	id_dev=240;init=2;default=1.60.latency.disp_icmp,1.300.latency.mon_icmp,1.300.snmp.traffic_mibii_if,.....
# ------------------------------------------------------------------------
#	GENERAR METRICAS DESDE ASISTENTE
#	id_dev=240;init=1;default=1.60.latency.disp_icmp,1.300.latency.mon_icmp,1.300.snmp.traffic_mibii_if,....
# ------------------------------------------------------------------------
# 	GENERAR METRICAS DESDE PLANTILLA
# 	id_dev=240
#-------------------------------------------------------------------------------
sub prov_do_set_device_metric {
my ($self,$in)=@_;

my ($rule_ip,$rule_name,$community,$file_dev,$name,$domain,$ip,$type,$sysoid,$mode,$version);
my $store_flag=1;


	$ProvisionLite::NO_SNMP_RESPONSE=0;
	$ProvisionLite::SNMP_FORCED=0;
   my $STORE=$self->istore();
   my $dbh=$self->dbh();
   #my $txml_path=$self->txml_path();
   my $rcfgbase=$self->cfg();
   #my $HOST=$self->host();
   my $SNMP=$self->snmp();
	$SNMP->reset_mapping();	#Garantizo que el fichero de cache de nuevos oids es correcto
   my $WBEM=$self->wbem();
   my $WSCLIENT=$self->wsclient();

	$self->rc(-1);	
	$self->rcstr("",1);	
	$self->log('info',"prov_do_set_device_metric::[INFO]");
	if (! exists $in->{'init'}) { $in->{'init'}=0; }
	
	my $cid=$in->{'cid'};

	# -------------------------------------------------------------------------------------
	# Obtiene el array de dispositivos ----------------------------------------------------
	# -------------------------------------------------------------------------------------
	my @DEVICES=();
	my @ID_DEVS=(); 	#Auxiliar

	#--------------------------------------------------------------------------------------
	if (defined $in->{'csv'}) {
		$file_dev=$in->{'csv'};
		$self->get_devices_from_csv($file_dev,\@DEVICES);
	}
   #--------------------------------------------------------------------------------------
   elsif (defined $in->{'file'}) {
      $file_dev=$in->{'file'};
      $self->get_devices_from_csv_web($file_dev,\@DEVICES,'&\|&');
		# print Dumper(\@DEVICES);
   }
	#--------------------------------------------------------------------------------------
   elsif (defined $in->{'xml'}) {
      $self->get_devices_from_xml($in->{'xml'},\@DEVICES);
   }
	#--------------------------------------------------------------------------------------
	elsif ( (defined $in->{'name'}) && (defined $in->{'ip'}) && (defined $in->{'type'}) ) {

		if ($in->{'name'}=~/^(\w+)\.(\S+)$/) {  	($name,$domain)=($1,$2); }
		else { ($name,$domain)=($in->{'name'},''); }

		$ip=$in->{'ip'};
		$type=$in->{'type'};
		$community = (defined $in->{'c'}) ? $in->{'c'} : 'public';
		$version = (defined $in->{'v'}) ? $in->{'v'} : '1';
   	$sysoid = (defined $in->{'oid'}) ? $in->{'oid'} : '1';
   	#if (defined $OPTS{'mode'}) {$mode=$OPTS{'mode'};}

		push @DEVICES, { name=>$name, domain=>$domain, ip=>$ip, community=>$community, version=>$version, type=>$type, sysoid=>$sysoid, wbem_user=>$in->{'wbem_user'}, wbem_pwd=>$in->{'wbem_pwd'} };	
	}
	#--------------------------------------------------------------------------------------
	elsif (defined $in->{'id_dev'}) {

		my $id_devs=$in->{'id_dev'};
	   my $rv=$STORE->get_from_db($dbh,'id_dev,name,domain,ip,community,version,type,sysoid,wbem_user,wbem_pwd,entity','devices',"id_dev in ($id_devs)");
   	if (!defined $rv) {
			$self->log('warning',"prov_do_set_device_metric::[WARN] No se encuentra el dispositivo/s solicitado/s $id_devs");
		   $self->rc(1);
		   $self->rcstr("[WARN] No se encuentra el dispositivo/s solicitado/s ($id_devs)",0);
			return undef;
		}

   	foreach (@$rv) {
			push @DEVICES, { name=>$_->[1], domain=>$_->[2], ip=>$_->[3], community=>$_->[4], version=>$_->[5], type=>$_->[6], sysoid=>$_->[7], id_dev=>$_->[0], wbem_user=>$_->[8], wbem_pwd=>$_->[9], entity=>$_->[10] };
		}
		# Mejor modificar siempre el dispositivo
		#$store_flag=0;
		$self->log('info',"prov_do_set_device_metric::[INFO] ID_DEV=$id_devs");

	}
	#--------------------------------------------------------------------------------------
	else {
		$self->log('warning',"prov_do_set_device_metric::[WARN] No hay desipositivos para trabajar");
      $self->rc(1);
      $self->rcstr("[WARN] No hay desipositivos para trabajar",0);
		return 1;
	}


	# -------------------------------------------------------------------------------------
	# -------------------------------------------------------------------------------------
	# -------------------------------------------------------------------------------------
	# -------------------------------------------------------------------------------------

	# -------------------------------------------------------------------------------------
	# Cargo los vectores de chequeo de metricas y aplicaciones.
	# Si el dispositivo es nuevo, no tiene las metricas del asistente instanciadas
	$self->get_check_vectors();

	$ProvisionLite::NUM_REMOTE_ALERTS_ASSIGNED=0;			
	# -------------------------------------------------------------------------------------
	my $cnt=0;
	foreach my $device (@DEVICES) {
		$cnt++;
		my $ID_DEV=0;

		if (! exists $device->{'ip'}) { 
			my $dump=Dumper($device);
			$self->log('warning',"prov_do_set_device_metric::[WARN] SALTO DEVICE SIN IP");
			$self->log('warning',"prov_do_set_device_metric::[WARN] DUMP=$dump");
			next; 
		}


		$self->reset_check_vectors();

		# Calculo $device->{'full_name'}
		if (($device->{'name'}) && ($device->{'domain'}) ) { $device->{'full_name'} = join ('.',$device->{'name'},$device->{'domain'}); }
		elsif ($device->{'name'}) { $device->{'full_name'} = $device->{'name'}; }	
		else { $device->{'full_name'} = $device->{'ip'}; }


      #---------------------------------------------------------------
      # Busco version SNMP.
		# Se obtienen los parametros snmp de configuracion (sysoid, sysloc ...
		# y se preparan adecuadamente ==> sysoid en numerico.
#      my $SNMP_VERSION=$SNMP->snmp_get_version($device->{ip},$device->{community},$device);
#		$SNMP->snmp_prepare_info($device);
#		$device->{'version'}=$SNMP_VERSION;

		my $SNMP_VERSION = 0;

		$device->{'host_ip'}=$device->{'ip'};


		my ($rc, $rcstr) = (0,'');
		if ($device->{'entity'} == 0) {

		if ($device->{'version'} == 3) {

			my $id_profile=$device->{'community'};
			if ($id_profile eq '') {
				$self->log('warning',"prov_do_set_device_metric::[WARN] DEVICE=$device->{'full_name'} SE ESPECIFICA SNMP V3 SIN ID_PROFILE");
			}
			else {
				my $v3 = $STORE->get_profiles_snmpv3($dbh,[$id_profile]);
				$device->{'sec_name'}=$v3->{$id_profile}->{'sec_name'};
				$device->{'sec_level'}=$v3->{$id_profile}->{'sec_level'};
				$device->{'auth_proto'}=$v3->{$id_profile}->{'auth_proto'};
				$device->{'auth_pass'}=$v3->{$id_profile}->{'auth_pass'};
				$device->{'priv_proto'}=$v3->{$id_profile}->{'priv_proto'};
				$device->{'priv_pass'}=$v3->{$id_profile}->{'priv_pass'};
			}
		}


      $SNMP->store($STORE);
      $SNMP->dbh($dbh);
      ($rc, $rcstr) = $SNMP->snmp_mib2_system($device);

		# ------------------------------------------------------------
		# Si el host esta incluido en el fichero /cfg/snmp-forced-hosts.conf
		# se provisiona como si respondiera a snmp.
		# ------------------------------------------------------------
		$ProvisionLite::SNMP_FORCED=0;
		my $FILE_SNMP_FORCED='/cfg/snmp-forced-hosts.conf';
		if (-f $FILE_SNMP_FORCED) {
			open (S,"<$FILE_SNMP_FORCED");
			while (<S>) {
				chomp;
				$_=~s/^\s*(\S+)\s*$/$1/;
				if ($_ eq $device->{'host_ip'}) {
					$ProvisionLite::SNMP_FORCED=1;
	   			$self->log('debug',"prov_do_set_device_metric::[DEBUG] DEVICE=$device->{'full_name'} [$device->{'host_ip'}] ***SNMP_FORCED***");
					last;
				}
			}
		}
		# ------------------------------------------------------------

      if (($rc == 0) || ($ProvisionLite::SNMP_FORCED)) {
         $SNMP_VERSION = $device->{'version'};
         $ProvisionLite::NO_SNMP_RESPONSE=0;
      }
      else {  $ProvisionLite::NO_SNMP_RESPONSE=1;  }

		}


		$self->log('debug',"prov_do_set_device_metric::[DEBUG] DEVICE=$device->{'full_name'} IP=$device->{ip} C=$device->{community} SNMP_VERSION=$SNMP_VERSION");

		if (! $SNMP_VERSION) {
	   	$self->log('debug',"prov_do_set_device_metric::[DEBUG] DEVICE=$device->{'full_name'} RC=$rc RCSTR=$rcstr");
		}
		else {
			$self->log('debug',"prov_do_set_device_metric::[DEBUG] DEVICE=$device->{'full_name'} SYSLOC=$device->{'sysloc'}");
			$self->log('debug',"prov_do_set_device_metric::[DEBUG] DEVICE=$device->{'full_name'} SYSOID=$device->{'sysoid'}");
			$self->log('debug',"prov_do_set_device_metric::[DEBUG] DEVICE=$device->{'full_name'} SYSDESC=$device->{'sysdesc'}");
			$self->log('debug',"prov_do_set_device_metric::[DEBUG] DEVICE=$device->{'full_name'} MAC=$device->{'mac'}");
			$self->log('debug',"prov_do_set_device_metric::[DEBUG] DEVICE=$device->{'full_name'} ENTERPRISE=$device->{'enterprise'}");
			$self->log('debug',"prov_do_set_device_metric::[DEBUG] DEVICE=$device->{'full_name'} NETWORK=$device->{'network'}");
			$self->log('debug',"prov_do_set_device_metric::[DEBUG] DEVICE=$device->{'full_name'} SWITCH=$device->{'switch'}");
		}


		#Se permite incluir un enterprise como parametro
		if (exists $in->{'enterprise'}) {
			if ((! exists $device->{'enterprise'}) || ($device->{'enterprise'} !~ /\d+/)) { $device->{'enterprise'} = $in->{'enterprise'}; }
			else {$device->{'enterprise'} = $device->{'enterprise'}.','.$in->{'enterprise'}; }
		}

      #---------------------------------------------------------------
      # Compruebo si existe el fichero ip.label
		# Esto permite tener expresiones regulares asociadas a ip que permitan tunear el label	
		@ProvisionLite::LABEL_EXPR=();	
		my $flabel='/cfg/'.$device->{'ip'}.'.label';
		if (-f $flabel) {
			open (F,"<$flabel");
			while (<F>) {
				chomp;
				if (/^#/) {next; }
				push @ProvisionLite::LABEL_EXPR,$_;
			}
			close (F);
		}
						
		# ----------------------------------------------------------------------------------
		# STORE/UPDATE DEVICE  -------------------------------------------------------------
		# ----------------------------------------------------------------------------------
		if ($store_flag) {
			$self->log('debug',"prov_do_set_device_metric::[DEBUG] STORE_FLAG=$store_flag");

			# Por ahora el host_idx esta fijado porque es clave y si no
         # se maneja bien puede crear problemas
         $device->{'host_idx'}=1;

			$ID_DEV=$STORE->store_device($dbh,$device);
			my $error=$STORE->error();
			if ($error) {
				my $errstr=$STORE->errorstr();
				$self->log('warning',"prov_do_set_device_metric::[WARN] $error [$cnt]:N=$device->{name},D=$device->{domain},IP=$device->{ip},TYPE=$device->{type},OID=$device->{sysoid}");
				next;
			}

			$STORE->store_device_custom_data($dbh,$ID_DEV,$device->{'custom'});

			$STORE->store_cfg_network($dbh,{'network'=>$device->{'network'}});


			# Se comprueba si el dispositivo tiene definido el perfil organizativo (update). En caso contrario, se da de altasolo
			# con  perfil organizativo global (esto se debe hacer solo la primera vez)
			my %op=();
			$op{'id_dev'}=$ID_DEV;
			$op{'cid'}=$cid;
			# Se da de alta con perfil organizativo global
			my $r=$STORE->get_from_db($dbh,'id_cfg_op','cfg_organizational_profile',"descr='Global'");
			if (scalar @$r) { $op{'id_cfg_op'}=$r->[0][0]; }
			else { $op{'id_cfg_op'}=1; }
			$STORE->store_device2organizational_profile($dbh,\%op);
		
			# Si pertenece a otros perfiles organizativos, tambien se incluyen	
			if (exists $device->{'perfil_organizativo'}) {
				my @d = map ("'".$_."'", split(',',$device->{'perfil_organizativo'}));
				my $cmp = join (',', @d);
				if ($cmp eq '') { $cmp="\'\'"; }

            $r=$STORE->get_from_db($dbh,'id_cfg_op','cfg_organizational_profile',"descr in ($cmp)");
				foreach my $l (@$r) {
					$op{'id_cfg_op'}=$l->[0];
					$STORE->store_device2organizational_profile($dbh,\%op);
				}
			}
			#Almacena ficha de dispositivo
			$STORE->store_device_record($dbh,$device->{'ip'});

			# Sincronizo el resto de servidores en caso de ser necesario
			#$WSCLIENT->store_device($device, { 'host_idx'=> 1 });

		}
		else { $ID_DEV=$device->{'id_dev'} }

		#--------------------------------------------------------------------------------
		# Si no responde a snmp se eliminan dela plantilla las mmetricas snmp
		# Se comenta para evitar riesgos
      #if (! $SNMP_VERSION) {
      #   $STORE->delete_from_template_metrics($dbh,$ID_DEV,'snmp');
      #}

		#--------------------------------------------------------------------------------
      my %nochange=();
      my %change=();
      my %remove=();
		my $rMETRIC;

		#--------------------------------------------------------------------------------
		# Preparamos el template con las metricas del dispositivo
		#--------------------------------------------------------------------------------
		# 3 situaciones:
      # 1. 	Generar metricas desde el asistente ==> Existe default ==> que especifica
		# 		cuales son las preseleccionadas (checked)
		# 2. 	Generar plantilla desde el asistente ==> Existe default ==> igual que antes
		# 		pero sin llegar a generar metricas.
		# 3. 	Generar metricas desde la plantilla ==> No existe default ==> Segun contenido de
		# 		las tablas prov_template_metrics y prov_template_metrics2iid
		#
		#	init=11 ==> Solo se da de alta el dispositivo. Sin asistente, aplicaciones y metricas (==>next)
		#	init=10 ==> Solo se da de alta el dispositivo. Con asistente, aplicaciones y sin metricas (==>next)
		#	init=0 ==> 	Desde plantilla (metricas activas)  -> Genera Metricas (Es el valor que se asume por defecto)
		#	init=1 ==> 	Desde asistente (metricas seleccionadas) -> Genera Metricas.
		#	init=2 ==> 	Desde asistente (metricas seleccionadas) -> Genera Plantilla (==>next)
		#	init=3 ==> 	Desde asistente (metricas seleccionadas = todas las activas).
		#	 				Previamente se borra la plantilla y las metricas en curso.
		#	init=4 ==>  Se incluyen las metricas activas del asistente pero sin borrar ni plantilla ni metricas en curso.
		#					Es para cuando se provisiona en bloque y se quiere aprovechar lo que haya nuevo
		#					en el asistente. En este caso hay que simular los valores del parametro default
		#					sacandolos directamente del propio asistente
		#
		#--------------------------------------------------------------------------------
#0: Desde plantilla -> Genera Metricas
#1: Desde asistente -> Genera Metricas
#2: Desde asistente -> Genera Plantilla
#3: Desde asistente -> Genera Plantilla (Resetea metricas)
#4: Desde inventario .csv


      #--------------------------------------------------------------------------------
      # init=11 ==>  Solo se da de alta el dispositivo. 
		#					No se generan metricas, ni asistente ni aplicaciones
      #--------------------------------------------------------------------------------
      if ( $in->{'init'}==11 ) { next; }

print "======================================prov_device_app_metrics===========================\n";
		# Se recalculan las aplicaciones y metricas del asistente
		$self->prov_device_app_metrics($ID_DEV);

		#--------------------------------------------------------------------------------
      # init=10 ==> 	Solo se da de alta el dispositivo.
		#					No se generan metricas pero si asistente y aplicaciones
		#--------------------------------------------------------------------------------
      if ( $in->{'init'}==10 ) { next; }

		#--------------------------------------------------------------------------------
		# $NM es el numero de metricas que existen en la tabla prov_template_metrics2iid asociadas a $ID_DEV
#		my $NM = $STORE->get_template_metrics_counter($dbh,$ID_DEV);
#      $self->log('debug',"prov_do_set_device_metric::[DEBUG] ID_DEV=$ID_DEV NM=$NM");
	

		#--------------------------------------------------------------------------------
      # init=3 ==> Reseteo metricas desde asistente
		#--------------------------------------------------------------------------------
      if ( $in->{'init'}==3 ) {
			# Elimino plantilla actual
			# delete from prov_template_metrics2iid where id_dev=242
			# delete from prov_template_metrics where id_dev=242

			$STORE->delete_from_db($dbh,'prov_template_metrics2iid',"id_dev=$ID_DEV");
			$STORE->delete_from_db($dbh,'prov_template_metrics',"id_dev=$ID_DEV");

			# Elimino metrcas en curso
			$STORE->delete_metrics($dbh, {id_dev=>$ID_DEV});

			# No se hace nada mas
			next;

#         @ProvisionLite::default_metrics=();
#         %ProvisionLite::assigned_watches = ();
#         %ProvisionLite::assigned_status = ();
#         $STORE->get_default_metrics2device($dbh,$ID_DEV);


#         my @TEMPLATE=();
#         $self->default2template_metrics($device,$SNMP_VERSION,$ID_DEV,\@ProvisionLite::default_metrics,\@TEMPLATE);
#         $STORE->store_template_metrics($dbh,$ID_DEV,\@TEMPLATE);
#         $self->log('debug',"prov_do_set_device_metric::[DEBUG] INICIALIZA PLANTILLA DE METRICAS (NO EXISTE)");

		}
	
		#--------------------------------------------------------------------------------
      # init=4 ==> Simulo que se han introducido como valores de default los que haya en la plantilla
      # Es el caso de provision por csv
		# Tambien se permite especificar metricas en $in->{'default'}
		#--------------------------------------------------------------------------------
      if ( $in->{'init'}==4 ) {
      	$self->log('debug',"prov_do_set_device_metric::[DEBUG] GENERA METRICAS DESDE CSV (INIT=4) ID_DEV=$ID_DEV");
         @ProvisionLite::default_metrics=();
         $STORE->get_default_metrics2device($dbh,$ID_DEV);

       	my @d=();
       	foreach my $m (@ProvisionLite::default_metrics) {
         	#'include'=>$m->[0], 'lapse'=>$m->[1],  'type' => $m->[2], 'subtype' => $m->[3]
         	if ($m->{'include'}) {
             	push @d, $m->{'include'}.'.'.$m->{'lapse'}.'.'.$m->{'type'}.'.'.$m->{'subtype'};
          	}
       	}
         @ProvisionLite::default_metrics=();
			if (exists $in->{'default'}) { $in->{'default'}=join(',', @d,$in->{'default'}); }
       	else { $in->{'default'}=join(',', @d); }
			my $def=$in->{'default'};
			$self->log('debug',"prov_do_set_device_metric::[DEBUG] INIT=4 DEFAULT=$def ID_DEV=$ID_DEV");
		}
      #--------------------------------------------------------------------------------
      # init=5 ==> Se genera asistente, plantilla y metricas a partir de un id_dev origen 
      #--------------------------------------------------------------------------------
      if ( $in->{'init'}==5 ) {
			my $id_dev_src=$in->{'id_dev_src'};
			$self->clone_template_metrics({'id_dev_src'=>$id_dev_src, 'id_dev_dst'=>$ID_DEV});
         $self->log('debug',"prov_do_set_device_metric::[DEBUG] GENERA METRICAS DESDE DISPOSITIVO DE REFERENCIA $id_dev_src -> $ID_DEV");
      }

      #--------------------------------------------------------------------------------
      # init=0 ==> Desde plantilla -> Genera Metricas
      #--------------------------------------------------------------------------------
      if ( $in->{'init'}==0 ) {
			# No se hace nada porque se supone que la plantilla ya existe y esta OK	
	  		$self->log('debug',"prov_do_set_device_metric::[DEBUG] GENERA METRICAS DESDE PLANTILLA (INIT=0) ID_DEV=$ID_DEV");
		}

      #--------------------------------------------------------------------------------
      # init=1 ==> Desde asistente -> Genera Metricas
      # init=2 ==> Desde asistente -> Genera Plantilla
      # init=4 ==> Desde asistente -> Genera Metricas (desde csv)
		# En este punto hacen lo mismo (estamos generando plantilla)
		# En init=2 luego se salta la generacion de metricas
      #--------------------------------------------------------------------------------
      if (( $in->{'init'}==1 ) || ( $in->{'init'}==2 ) || ( $in->{'init'}==4 ) ){
						
   		$self->log('debug',"prov_do_set_device_metric::[DEBUG] GENERA METRICAS DESDE ASISTENTE (INIT=$in->{'init'}) ID_DEV=$ID_DEV");

   		# Meto en @def_metrics las metricas (del asistente) seleccionadas por el usuario.
   		my @def_metrics=();
			my @m=();
   		if (exists $in->{'default'}) { @m=split(',',$in->{'default'}); }
   		foreach my $i (@m) {
      		my ($v1,$v2,$v3,$v4)=split(/\./,$i);
      		push @def_metrics, {'include'=>$v1, 'lapse'=>$v2,  'type' => $v3, 'subtype' => $v4 };
   		}

   		# Obtengo las metricas de la plantilla
   		my @DEFAULT=();
   		# Hay que hacer el join de las dos tablas para controlar que existan instancias definidas
   		# en prov_template_metrics2iid y que tengan status != 0
   		my $template=$STORE->get_from_db($dbh,'p.type,p.subtype,p.lapse,i.iid','prov_template_metrics p, prov_template_metrics2iid i',"i.id_template_metric=p.id_template_metric and  i.status=0 and p.id_dev=$ID_DEV");

   		# @def_metrics >> Contiene las metricas que el usuario ha seleccionado del asistente
   		# @$template son las metricas ya instanciadas de la plantilla
   		foreach my $d (@def_metrics) {
   	   	my $skip=0;
	   	   my $dsubtype = $d->{'subtype'};

      		foreach my $t (@$template) {
		         my $tsubtype=$t->[1];
      		   my $tiid=$t->[3];

         		# Salto este tipo de metrica si ya existe en la plantilla y no tiene instancias
					# A lo mejor habria que hacerlo siempre y no saltarse ninguna metrica.	
         		if (($dsubtype eq $tsubtype) && ($tiid eq 'ALL') ) {
		            $skip=1;
      		      $self->log('debug',"prov_do_set_device_metric::[DEBUG] salto metrica $tsubtype");
            		last;
         		}
		      }
		      # Si no esta en la plantilla la meto. Si no tiene iids es tal cual y si tiene iids me invento 1 instancia
      		# luego se arreglara
		      if (! $skip) {   push @DEFAULT, $d;  }
   		}

   		# Obtengo los posibles watches asignados y el status en caso de que exista
   		%ProvisionLite::assigned_watches=();
   		%ProvisionLite::assigned_status=();
		   my $watches=$STORE->get_from_db($dbh,'iid,label,watch,status','prov_template_metrics2iid',"id_dev=$ID_DEV");
		   foreach my $t (@$watches) {
      		my $iid=$t->[0];
		      my $label=$t->[1];
		      my $status=$t->[3];
      		my $watch = (defined $t->[2]) ? $t->[2] : '0';
		      if ($watch ne '0') {
			      $ProvisionLite::assigned_watches{$label} = { 'iid' => $iid, 'watch' => $watch};
    		     	$self->log('debug',"prov_do_set_device_metric::[DEBUG]**FML** WATCH=$watch L=$label");
      		}
				$ProvisionLite::assigned_status{$label} = { 'iid' => $iid, 'status' => $status};	
   		}
		
   		if (scalar @DEFAULT) {
      		my @TEMPLATE=();
      		$self->default2template_metrics($device,$SNMP_VERSION,$ID_DEV,\@DEFAULT,\@TEMPLATE);
      		$STORE->store_template_metrics($dbh,$ID_DEV,\@TEMPLATE);

print "---------------------ACTUALIZO PLANTILLA CON DEFAULT---------------------\n";
print Dumper(\@DEFAULT);
print "---------------------ACTUALIZO PLANTILLA CON DEFAULT (INSTANCIADO)---------------------\n";
print Dumper(\@TEMPLATE);

			}
		}

		# -------------------------------------------------------------------------------
      # Si existen reglas de provision para el dispositivo en BBDD, se rellena
		# @ProvisionLite::metric_rules=();
		# -------------------------------------------------------------------------------
#		@ProvisionLite::metric_rules=();
#      my $rules=$STORE->get_from_db($dbh,'rules','rule_prov2device',"id_dev=$ID_DEV");
#      if (scalar @$rules) {
#         my $xs1 = XML::Simple->new();
#         my $data = $xs1->XMLin($rules->[0][0]);
#         foreach my $rid (sort keys %{$data->{'rule'}}) {
#            push @ProvisionLite::metric_rules,$data->{'rule'}->{$rid};
#         }
#      }

		# -------------------------------------------------------------------------------
		# Obtengo las reglas que sean aplicables al dispositivo y
		# se modifica la plantilla (status=1 para los que cumplan la condicion)
      @ProvisionLite::metric_rules=();
      $self->get_applicable_rules($ID_DEV,\@ProvisionLite::metric_rules);
		$STORE->apply_rules_to_template_metrics($dbh,$ID_DEV,\@ProvisionLite::metric_rules);

		
		# -------------------------------------------------------------------------------
		# init=2 ==> Genero plantilla desde asistente. Paso al siguiente dispositivo.
		# -------------------------------------------------------------------------------
		#if ( $in->{'init'}==2 ) { next; }


		#-------------------------------------------------------------------------------
		# Para provisionar se utiliza la plantilla del dispositivo con las metricas ya estan instanciadas !!
		# Se obtiene la plantilla de la base de datos.
		# -------------------------------------------------------------------------------
		$rMETRIC = $STORE->get_template_metrics($dbh,$ID_DEV);


		if (! defined $rMETRIC) {
	
        	next;
     	}
				
     	$self->rcstr("DISPOSITIVO:$device->{name} ($device->{ip})<br>",0);
      my $ctot=0;
      my $cgen=1;
		my @TEMPLATE=();
#		my %IID=();
		my $MDATA;
#		my $new_metrics=0;

print "======================================prov_metrics===========================\n";
		#-------------------------------------------------------------------------------
		# Iteramos sobre cada una de las metricas+iid del dispositivo
		# type,subtype,watch,iid,mname,label,status,lapse
		foreach my $v (@$rMETRIC) {
		
my $kkk=Dumper($v);
print "========METRICAS+IIDS DEL DISPOSITIVO===========\n";
print "VVV=$kkk\n";
print "================================================\n";

									
			$ctot += 1;
#DBG--
	my @dbg_iids=keys(%{$v->{IIDS}});
	$self->log('debug',"prov_do_set_device_metric::[DEBUG] **PROVISIONO: $v->{subtype} TYPE=$v->{type} LAPSE=$v->{lapse} IIDS=@dbg_iids (CTOT=$ctot CGEN=$cgen)");
	while (my ($a,$b)=each %$v) {
	   $self->log('debug',"prov_do_set_device_metric::[DEBUG] V==> $a->$b");
	}
#/DBG--
		
			#-------------------------------------------------------------------------------
         # Si el dispositivo no responde por SNMP salto las metricas SNMP
         if ( (!$SNMP_VERSION ) && ($v->{'type'} eq 'snmp') ) {
				$self->log('info',"prov_do_set_device_metric::[INFO] SALTO METRICA SNMP: $v->{subtype} >> $device->{name} $device->{ip} (sin respusta snmp)");
				$self->rcstr("$ctot :METRICA    $device->{name} : $device->{type} (SIN RESPUESTA SNMP => Salto metrica)<br>",0);

				next;
			}


         #-------------------------------------------------------------------------------
         # Si no son metricas activas, lo unico que hago es borrarlas de en curso
         if ((exists $v->{'status'}) && ($v->{'status'} != 0)) {
				$STORE->delete_metrics($dbh, {'id_dev'=>$ID_DEV, 'subtype'=> $v->{'subtype'}});
            $self->log('info',"prov_do_set_device_metric::[INFO] $device->{name} $device->{ip} BORRO: $v->{subtype} >> $v->{label}");
            next;
         }

			#-------------------------------------------------------------------------------
			$self->rcstr("$ctot METRICA $cgen $v->{subtype} : $v->{type} ",0);		
			$v->{'version'}=$SNMP_VERSION;

			#-------------------------------------------------------------------------------
			if ($v->{'type'} eq 'snmp') {
			#-------------------------------------------------------------------------------
						
				#Hay que revisar como se diferencian las distintas metricas	
		      my $rv=$STORE->get_from_db($dbh,'cfg','cfg_monitor_snmp',"subtype='$v->{subtype}'");
		      if (!defined $rv) {
              $self->log('warning',"prov_do_set_device_metric::[WARN] Metrica SNMP NO cualificada por subtype=$v->{subtype}");
               next;
            }

				my $cfg=$rv->[0][0];
				$self->log('info',"prov_do_set_device_metric::$ctot PROV_METRICA $cgen $v->{subtype} : $v->{type} cfg=$cfg");
            if ( $cfg == 1 ) { $MDATA=$self->apply_metric_snmp_class1($v,$device);  }
				elsif ( $cfg == 2 )	{ $MDATA=$self->apply_metric_snmp_class2($v,$device); }
				elsif ( $cfg == 3 ) { $MDATA=$self->apply_metric_snmp_class3($v,$device);  }
				else { 	
					$self->log('warning',"prov_do_set_device_metric::[WARN] Metrica SNMP NO cualificada");
					next;
				}
			}

			#-------------------------------------------------------------------------------
			elsif ($v->{'type'} eq 'latency') {
			#-------------------------------------------------------------------------------
				$v->{'iid'}='ALL';
				$self->log('info',"prov_do_set_device_metric::$ctot PROV_METRICA $cgen $v->{subtype} : $v->{type}");
				$MDATA=$self->apply_metric_latency($v,$device);
			}

         #-------------------------------------------------------------------------------
         elsif ($v->{'type'} eq 'xagent') {
			#-------------------------------------------------------------------------------
				#$v->{'iid'}='ALL';
				$self->log('info',"prov_do_set_device_metric::$ctot PROV_METRICA $cgen $v->{subtype} : $v->{type}");
            $MDATA=$self->apply_metric_xagent($v,$device);
         }

         #-------------------------------------------------------------------------------
         else  {
				$self->log('warning',"prov_do_set_device_metric::$ctot PROV_METRICA **WARN** $cgen $v->{subtype} : $v->{type} NO CUALIFICADA");
            next;
         }

			#-------------------------------------------------------------------------------
			# Itero sobre las instancias de una metrica determinada reportadas por el dispositivo (dev_iid en %MDATA)
			# 1. Si dev_iid coincide con tpl_iid (plantilla) paso bola
			# 2. Si dev_iid no existe en tpl_iid la incluyo en la plantilla (sin chequear)
			# 3. Si tpl_iid ya no existe en el dispositivo lo borro de la plantilla
			# 4. Si dev_iid presenta algun cambio respecto a tpl_iid ==> actualizo
			%nochange=();
			%change=();
			%remove=();
		
print "========METRICAS PARA APLICAR (MDATA)===========\n";
print Dumper($MDATA);
print "================================================\n";

         my $label_in_tpl=0;
         my $iid_in_tpl=0;
				
			# %$MDATA CONTIENE LOS DATOS DEL DISPOSITIVO
   	   foreach my $dev_iid (sort keys %$MDATA) {
										
				$label_in_tpl=0;
				$iid_in_tpl=0;
				# %$V CONTIENE LOS DATOS DE la plantilla
				$self->log('debug',"prov_do_set_device_metric::[INFO] MDATA -> EL DISPOSITIVO RESPONDE A iid=$dev_iid LABEL=$MDATA->{$dev_iid}->{'label'}");

				foreach my $tpl_iid (sort keys %{$v->{'IIDS'}} ) {
				
#print "**FML** ITERO SOBRE dev_iid=$dev_iid tpl_iid=$tpl_iid\n";	
					#$self->log('debug',"prov_do_set_device_metric::[INFO] MDATA ITERO SOBRE dev_iid=$dev_iid tpl_iid=$tpl_iid");
					if ( $tpl_iid eq $dev_iid ) {
						$iid_in_tpl=1;
					 	$self->log('debug',"prov_do_set_device_metric::[INFO] EL iid=$dev_iid ESTA EN LA PLANTILLA CON LABEL=$v->{'IIDS'}->{$tpl_iid}->{'label'}");
						#1.
						if ( $MDATA->{$dev_iid}->{'label'} eq $v->{'IIDS'}->{$tpl_iid}->{'label'} ) {
							$nochange{$dev_iid} = {
                        'label' => $MDATA->{$dev_iid}->{'label'},
                        'status' => $v->{'IIDS'}->{$tpl_iid}->{'status'},
                        'watch' => $v->{'IIDS'}->{$tpl_iid}->{'watch'},
                        'type' => $v->{'type'},
                        'subtype' => $v->{'subtype'},
                        'lapse' => $v->{'lapse'} } ;
print "\tCHANGEIID iid=$dev_iid NO CHANGE \n";
								$self->log('debug',"prov_do_set_device_metric::[INFO] MDATA CHANGEIID iid=$dev_iid NO CHANGE");
                  }
						#4.
                  else {
                     # Si el label no coincide con el de la plantilla ==> change
                     $change{$dev_iid} = {
                        'label' => $MDATA->{$dev_iid}->{'label'},
                        'status'=> $v->{'IIDS'}->{$tpl_iid}->{'status'},
                        'watch'=> $v->{'IIDS'}->{$tpl_iid}->{'watch'},
                        'type' => $v->{'type'},
                        'subtype' => $v->{'subtype'},
								'mname' => $v->{'IIDS'}->{$tpl_iid}->{'mname'},
                        'lapse' => $v->{'lapse'} } ;
print "\tCHANGEIID iid=$dev_iid UPDATE  $MDATA->{$dev_iid}->{'label'} <> $v->{'IIDS'}->{$tpl_iid}->{'label'}\n";
								$self->log('debug',"prov_do_set_device_metric::[INFO] MDATA CHANGEIID iid=$dev_iid UPDATE  $MDATA->{$dev_iid}->{'label'} <> $v->{'IIDS'}->{$tpl_iid}->{'label'}");
                  }
					}
				}

				# Si es una metrica que no esta en la plantilla ==> change
				if (! $iid_in_tpl) {
					$self->log('debug',"prov_do_set_device_metric::[INFO] EL iid=$dev_iid NO ESTA EN LA PLANTILLA CON LABEL=$MDATA->{$dev_iid}->{'label'}");
					$change{$dev_iid} = {
						'label' => $MDATA->{$dev_iid}->{'label'},
                  'status'=> 1,
                  'watch'=> '0',
                  'type' => $v->{'type'},
                  'subtype' => $v->{'subtype'},
						#'mname' => $v->{'IIDS'}->{$dev_iid}->{'mname'},
						'mname' => $MDATA->{$dev_iid}->{'name'},
                  'lapse' => $v->{'lapse'} } ;
print "\tCHANGEIID $dev_iid UPDATE  nueva\n";
						$self->log('debug',"prov_do_set_device_metric::[INFO] MDATA CHANGEIID $dev_iid UPDATE  nueva");
				}
			}
				

			foreach my $tpl_iid (sort keys %{$v->{'IIDS'}} ) {
				if ( (! exists $change{$tpl_iid}) && (! exists $nochange{$tpl_iid}) ) {
					$remove{$tpl_iid} = {
                  'label' => $v->{'IIDS'}->{$tpl_iid}->{'label'},
                  'status'=> 1,
                  'watch'=> '0',
                  'type' => $v->{'type'},
                  'subtype' => $v->{'subtype'},
                  'mname' => $v->{'IIDS'}->{$tpl_iid}->{'mname'},
                  'lapse' => $v->{'lapse'} } ;
print "\tCHANGEIID iid=$tpl_iid BORRAR DE PLANTILLA\n";
						$self->log('debug',"prov_do_set_device_metric::[INFO] MDATA CHANGEIID iid=$tpl_iid BORRAR DE PLANTILLA");
					}
			}
			
print "CHANGE:\n";
print Dumper(\%change);
print "------------------------------\n";
print "NOCHANGE:\n";
print Dumper(\%nochange);
print "------------------------------\n";
print "REMOVE:\n";
print Dumper(\%remove);
print "------------------------------\n";
			if (scalar(keys %remove) > 0) {
				my $xaux=Dumper(\%remove);
				$xaux=~s/\n/ \./g;
				$self->log('info',"prov_do_set_device_metric::[INFO] TEMPLATE REMOVE: $xaux");
			}
#print "MDATA: (disp)\n";
#print Dumper($MDATA);
#print "------------------------------\n";
#print "v: (plantilla)\n";
#print Dumper($v);
#

	      # -------------------------------------------------------------------------------
			# Actualizao la plantilla segun el vector remove
			# Los cambios (updates o nuevas metricas) se hacen mas abajo en el store_template_metrics
	      # -------------------------------------------------------------------------------
         if (scalar(keys %change) > 0) {
            foreach my $iid (keys %change) {
					my %data=();
					$data{'label'}=$change{$iid}->{'label'};
					my $txt="$iid: ".$data{'label'}.' ('.$change{$iid}->{'mname'}.')';
					$self->log('info',"prov_do_set_device_metric::[INFO] CHANGEIIDS (ID_DEV=$ID_DEV) Se actualiza:  $txt");
					$STORE->log_qactions($dbh,{'descr'=>'Instancias modificadas', 'rc'=>'OK', 'rcstr'=>"Se actualiza:  $txt", 'atype'=>ATYPE_IIDS_MODIFIED});

            }
         }

			if (scalar(keys %remove) > 0) {
				my @aux0=();
				my @aux1=();
				foreach my $iid (keys %remove) {
					push @aux0, "'".$remove{$iid}->{'mname'}."'";
					push @aux1, "iid=$iid: ".$remove{$iid}->{'label'};
				}
				my $where="id_dev=$ID_DEV and mname in (".join(',', @aux0).")";
#print "WHERE = $where\n";

				$STORE->delete_from_db($dbh,'prov_template_metrics2iid',$where);
				my $txt=join(' ; ', @aux1);
				$self->log('info',"prov_do_set_device_metric::[INFO] CHANGEIIDS (ID_DEV=$ID_DEV) Se eliminan:  $txt (WHERE=$where)");
				$STORE->log_qactions($dbh,{'descr'=>'Instancias eliminadas', 'rc'=>'OK', 'rcstr'=>"Se eliminan:  $txt", 'atype'=>ATYPE_IIDS_ERASED});
			}

			# Genero metricas (nochange)
			foreach my $iid (sort keys %nochange) {
			
				my $m=$MDATA->{$iid};
        		my $kk=$m->{'label'};
        		$self->rcstr(" : $kk<br>",0);
        		$m->{'status'}=$nochange{$iid}->{'status'};
        		$m->{'watch'}=$nochange{$iid}->{'watch'};
        		$m->{'type'}=$nochange{$iid}->{'type'};
        		$m->{'subtype'}=$nochange{$iid}->{'subtype'};
        		$m->{'lapse'}=$nochange{$iid}->{'lapse'};
				$m->{'iid'}=$iid;

         # fml Revisar esta asignacion. Parece necesario en latency pero en snmp con iids falla.
        # if ($v->{'type'} eq 'latency') { $m->{'label'}=$v->{'label'}; }
#        	# Por ahora el host_idx esta fijado porque es clave y si no se maneja bien puede crear problemas
 				$m->{'host_idx'}=1;

  		      push (@TEMPLATE, { 'type' => $m->{'type'}, 'subtype' => $m->{'subtype'}, 'watch' => $m->{'watch'}, 'iid' => $m->{'iid'}, 'mname' => $m->{'mname'}, 'label' => $m->{'label'}, 'severity' => $m->{'severity'}, 'mname' => $m->{'name'}, 'lapse' => $m->{'lapse'}, 'status' => $m->{'status'} } );
      	  	$cgen += 1;
			
	         # -------------------------------------------------------------------------------
   	      # init=2 ==> Genero plantilla desde asistente. Salto generar metricas
      	   # -------------------------------------------------------------------------------
         	if ( $in->{'init'}!=2 ) {
		        	$self->metric2db($ID_DEV,$device,$m);
				}
			}
			
			# Genero metricas (change)
         foreach my $iid (sort keys %change) {
			
            my $m=$MDATA->{$iid};
            my $kk=$m->{'label'};
            $self->rcstr(" : $kk<br>",0);
            $m->{'status'}=$change{$iid}->{'status'};
            $m->{'watch'}=$change{$iid}->{'watch'};
            $m->{'type'}=$change{$iid}->{'type'};
            $m->{'subtype'}=$change{$iid}->{'subtype'};
            $m->{'lapse'}=$change{$iid}->{'lapse'};
            $m->{'host_idx'}=1;
				$m->{'iid'}=$iid;

            push (@TEMPLATE, { 'type' => $m->{'type'}, 'subtype' => $m->{'subtype'}, 'watch' => $m->{'watch'}, 'iid' => $m->{'iid'}, 'mname' => $m->{'mname'}, 'label' => $m->{'label'}, 'severity' => $m->{'severity'}, 'mname' => $m->{'name'}, 'lapse' => $m->{'lapse'}, 'status' => $m->{'status'} } );
           	$cgen += 1;

            # -------------------------------------------------------------------------------
            # init=2 ==> Genero plantilla desde asistente. Salto generar metricas
            # -------------------------------------------------------------------------------
            if ( $in->{'init'}!=2 ) {
	            $self->metric2db($ID_DEV,$device,$m);
				}
         }

		}

		# Se eliminan las metricas azules del dispositivo (en metrics) 
		# select mname from alerts where id_device=100 and severity=4;
      my $rx=$STORE->get_from_db($dbh,'mname,ip,type','alerts',"id_device=$ID_DEV and severity=4");
      if (scalar(@$rx)>0) {
			my @mnames=();
         foreach my $x (@$rx) {
				push @mnames,"'".$x->[0]."'";
				#/opt/data/mdata/output/default/a/10.72.0.22.4.snmp.49.mib2_glob_duplex
				my $file_mdata = '/opt/data/mdata/output/default/a/'.join('.', $x->[1],'4',$x->[2],$x->[0]);
				my $rx = unlink $file_mdata;
				$self->log('info',"prov_do_set_device_metric::[INFO] BORRAR AZULES ($rx) $file_mdata");
         }
			my $c1=join(',',@mnames);	
			$self->log('info',"prov_do_set_device_metric::[INFO] BORRAR AZULES name in ($c1) AND id_dev=$ID_DEV");			
			$STORE->delete_from_db($dbh,'metrics',"name in ($c1) AND id_dev=$ID_DEV");	
      }

			
print "-------TEMPL-----------------------\n";
print "TEMPLATE:\n";
print Dumper(\@TEMPLATE);

	   my $ok;
   	($dbh,$ok)=$self->chk_conex($dbh,$STORE,'devices');

		$STORE->store_template_metrics($dbh,$ID_DEV,\@TEMPLATE);


      if ( $in->{'init'}==5 ) {
			my $id_dev_src=$in->{'id_dev_src'};
         $self->clone_background_and_position({'id_dev_src'=>$id_dev_src, 'id_dev_dst'=>$ID_DEV});
         $self->log('debug',"prov_do_set_device_metric::[DEBUG] GENERA METRICAS DESDE DISPOSITIVO DE REFERENCIA $id_dev_src -> $ID_DEV");
      }

		push @ID_DEVS,$ID_DEV;
   }

	#Si ha habido mapeo de alertas remotas hay que reiniciar syslog-ng
	if ($ProvisionLite::NUM_REMOTE_ALERTS_ASSIGNED>0) { 
		system ("/etc/init.d/snmptrapd restart"); 
		system ("/etc/init.d/syslog-ng reload"); 
	}

	# Se preparan los crawlers .....
	# Se inicializa el campo subtable de metrics para todas aquellas metricas que lo tengan a -1
	$STORE->set_graph_subtables($dbh);
	my $tnow=time();
	foreach my $id_dev (@ID_DEVS) {
   	#Se regeneran las metricas en work_xxx para $id_dev
   	#Se generan los ficheros idx correspondientes para los crawlers
   	$STORE->store_crawler_work($dbh,$id_dev,$tnow,$cid);
	}

	
	$self->rcstr("END\n",0);
	$self->rc(0);
			
}


#----------------------------------------------------------------------------
# Funcion: get_applicable_rules
# Descripcion:
# Obtiene las reglas que aplican al dispositivo (ya sean especificas del mismo o generales)
# Lo almacena en un vector que se le pasa como parametro
#----------------------------------------------------------------------------
sub get_applicable_rules {
my ($self,$id_dev,$rules)=@_;

# fml
# Ahora como parche hago id_rules_template=1

   my $STORE=$self->istore();
   my $dbh=$self->dbh();


      #Primera version. Pillo solo de la tabla: prov_default_rules_templates
      #Habria que considerar todas las opciones: prov_default_rules2device + prov_default_rules_templates
      # Ahora como parche hago id_rules_template=1
      # Meterlo todo en otra funcion que componga @ProvisionLite::metric_rules=();
      my $r1=$STORE->get_from_db($dbh,'mtype,subtype,pattern,action,watch,mode','prov_default_rules_templates',"id_rules_template=1");
      if (scalar @$r1) {
         foreach my $r (@$r1) {
            push @$rules,$r;
         }
      }

}



#----------------------------------------------------------------------------
# Funcion: default2template_metrics
# Descripcion:
# Convierte metricas de tipo asistente (sin intanciar a metricas instanciadas para
# la plantilla.
# Inicializa la plantilla de metricas de un dispositivo (tablas prov_template_metrics
# y prov_template_metrics2iid) con los datos contenidos en @ProvisionLite::default_metrics
#----------------------------------------------------------------------------
#sub init_template_metrics {
sub default2template_metrics {
my ($self,$device,$snmp_version,$id_dev,$default,$template)=@_;

   my $STORE=$self->istore();
   my $dbh=$self->dbh();
	my $ctot=0;
	my $cgen=0;

	#my @TEMPLATE=();
	my $MDATA;
   #foreach my $v (@ProvisionLite::default_metrics) {
   foreach my $v (@$default) {

		#{'include'=>0/1, 'lapse'=>300/60...,  'type' =>snmp/latency..., 'subtype' => disk_mibhost... }
$self->log('debug',"default2template_metrics::[DEBUG] SUBTYPE=$v->{subtype} INCLUDE=$v->{'include'}");

		if (! $v->{'include'}) { next; }
		$ctot += 1;

#DBG--
	   while (my ($a,$b)=each %$v) {
   	   $self->log('debug',"default2template_metrics::[DEBUG] V==> $a->$b");
   	}
#/DBG--

      # Si el dispositivo no responde por SNMP salto las metricas SNMP
      if ( (!$snmp_version ) && ($v->{type} eq 'snmp') ) {
         $self->log('info',"default2template_metrics::[INFO] $device->{name} $device->{ip} Salto metrica SNMP");
         $self->rcstr("$ctot :METRICA    $v->{subtype} : $v->{type} (no snmp => Salto metrica)<br>",0);
         next;
      }
      else {
         $self->rcstr("$ctot METRICA $cgen $v->{subtype} : $v->{type} ",0);
      }
      $v->{'version'}=$snmp_version;

print "FML $ctot METRICA $cgen $v->{subtype} : $v->{type} \n";
$self->log('debug',"default2template_metrics::[DEBUG] FML $ctot METRICA $cgen $v->{subtype} : $v->{type}");

		# c.type,c.subtype,i.watch,i.iid,i.mname,i.label,i.status,c.lapse
		# falta i.iid,i.mname,i.label,i.status

      #-------------------------------------------------------------------------------
      if ($v->{'type'} eq 'snmp') {
		
         #Hay que revisar como se diferencian las distintas metricas
         #my $rv=$STORE->get_from_db($dbh,'module,oid,mtype,vlabel,mode,top_value,get_iid,descr,cfg','cfg_monitor_snmp',"subtype='$v->{subtype}'");
         my $rv=$STORE->get_from_db($dbh,'cfg','cfg_monitor_snmp',"subtype='$v->{subtype}'");
         if (!defined $rv) {
         	$self->log('warning',"default2template_metrics::[WARN] Metrica SNMP NO cualificada por subtype=$v->{subtype}");
            next;
         }

#         $v->{'module'}=$rv->[0][0];
#         $v->{'oid'}=$rv->[0][1];
#         $v->{'mtype'}=$rv->[0][2];
#         $v->{'vlabel'}=$rv->[0][3];
#         $v->{'mode'}=$rv->[0][4];
#         $v->{'top_value'}=$rv->[0][5];
#         $v->{'get_iid'}=$rv->[0][6];
#         my $cfg=$rv->[0][8];
#         $self->log('debug',"init_template_metrics::[DEBUG] type=snmp module=$v->{'module'} oid=$v->{'oid'}");

			my $cfg=$rv->[0][0];
         if ( $cfg == 1 ) { $MDATA=$self->apply_metric_snmp_class1($v,$device);  }
         elsif ( $cfg == 2 )  {  $MDATA=$self->apply_metric_snmp_class2($v,$device);   }
         elsif ( $cfg == 3 ) { $MDATA=$self->apply_metric_snmp_class3($v,$device);  }
         else {
            $self->log('warning',"default2template_metrics::[WARN] Metrica SNMP NO cualificada");
            next;
         }
		
     	}	

      #-------------------------------------------------------------------------------
      elsif ($v->{'type'} eq 'latency') {
         $MDATA=$self->apply_metric_latency($v,$device);
      }

      #-------------------------------------------------------------------------------
      elsif ($v->{'type'} eq 'xagent') {
         $MDATA=$self->apply_metric_xagent($v,$device);
      }

		foreach my $iid (sort keys %$MDATA) {

			my $m=$MDATA->{$iid};
         $m->{'type'}=$v->{'type'};
  	      $m->{'subtype'}=$v->{'subtype'};
     	   $m->{'lapse'}=$v->{'lapse'};

        	$m->{'watch'}=0;
			my $l=$m->{'label'};

#DBG
$self->log('debug',"default2template_metrics::[DEBUG]**FML** L = $l");
#foreach my $k (keys %ProvisionLite::assigned_watches) {
#	my $w=$m->{'watch'};
#	if (exists $ProvisionLite::assigned_watches{$l}{'watch'}) { $w=$ProvisionLite::assigned_watches{$k}{'watch'}; }
#	$self->log('debug',"init_template_metrics::[DEBUG]**FML** K = $k V=$w");
#}
#DBG

			if (exists $ProvisionLite::assigned_watches{$l}{'watch'}) {
				$m->{'watch'}=$ProvisionLite::assigned_watches{$l}{'watch'};
				my $w=$m->{'watch'};
				$self->log('debug',"default2template_metrics::[DEBUG] **FML** Se mantiene watch=$w en $l");
			}

			my $status=0;
         if (exists $ProvisionLite::assigned_status{$l}{'status'}) {
            $status=$ProvisionLite::assigned_status{$l}{'status'};
            $self->log('debug',"default2template_metrics::[DEBUG] **FML** Se mantiene status=$status en $l");
         }


        	#push (@TEMPLATE, { 'type' => $m->{'type'}, 'subtype' => $m->{'subtype'}, 'iid' => $iid, 'label' => $m->{'label'}, 'severity' => $m->{'severity'}, 'mname' => $m->{'name'}, 'lapse' => $m->{'lapse'}, 'watch' => $m->{'watch'}, 'status'=>0 } );
        	push (@$template, { 'type' => $m->{'type'}, 'subtype' => $m->{'subtype'}, 'iid' => $iid, 'label' => $m->{'label'}, 'severity' => $m->{'severity'}, 'mname' => $m->{'name'}, 'lapse' => $m->{'lapse'}, 'watch' => $m->{'watch'}, 'status'=>$status } );
         $cgen += 1;

      }
						
     # $STORE->store_template_metrics($dbh,$id_dev,\@TEMPLATE);
   }

	return $template;
}


#----------------------------------------------------------------------------
# Funcion: verify_metrics_in_use
# Descripcion:
# Valida que las metricas generadas siguen estando vigentes y que no hay cambio de oids
#----------------------------------------------------------------------------
sub verify_metrics_in_use {
my ($self,$where)=@_;


   my $STORE=$self->istore();
   my $dbh=$self->dbh();

   #---------------------------------------------------------------
   my $what='id_dev,ip,name,domain,community,version,status';
   my $from='devices';
   #my $where="";
   my $other='';
   my $rres=$STORE->get_from_db($dbh,$what,$from,$where,$other);

   foreach my $l (@$rres) {
		my %DEVICE=('id_dev'=>$l->[0] , 'ip'=>$l->[1]  , 'community'=>$l->[4] , 'version'=>$l->[5], 'status'=>$l->[6] );
#print Dumper(\%DEVICE);

		$self->verify_device_metrics(\%DEVICE);
	}


}


#----------------------------------------------------------------------------
# Funcion: verify_device_metrics
# Descripcion:
# Valida que las metricas generadas siguen estando vigentes y que no hay cambio de oids
#----------------------------------------------------------------------------
sub verify_device_metrics {
my ($self,$device)=@_;


   my $STORE=$self->istore();
	my $dbh=$self->dbh();

   #---------------------------------------------------------------
	# select m.subtype,m.iid,m.label from metrics m, cfg_monitor_snmp c where m.subtype=c.subtype and m.id_dev=xxx and c.get_iid!='' and c.get_iid!=1 and m.type='snmp' order by m.subtype;
	my $id_dev=$device->{'id_dev'};
   my $what='m.subtype,m.iid,m.label,m.status,m.watch';
	my $from='metrics m, cfg_monitor_snmp c';
   my $where="m.subtype=c.subtype and m.id_dev=$id_dev and c.get_iid!='' and c.get_iid!=1 and m.type='snmp'";
	my $other='order by m.subtype';
   my $rres=$STORE->get_from_db($dbh,$what,$from,$where,$other);


	my %MDATA_STORED=();
	my %NULL_STORED=();
	foreach my $l (@$rres) {
		my ($subtype,$iid, $label, $mstatus, $watch) = ($l->[0], $l->[1], $l->[2], $l->[3], $l->[4]);
		if ($iid eq '') {
			print ">> ; $device->{'ip'} ; $subtype ; **NULL IID** ;  L=$label  ; ==> ASOCIAR DESDE REPOSITORIO\n";
			$NULL_STORED{$subtype}=1;
		}

		$MDATA_STORED{$subtype}{$iid} = {'label' => $label, 'mstatus'=>$mstatus, 'watch'=>$watch };
	}


	my $dstatus = $device->{'status'};
   foreach my $subtype (keys %MDATA_STORED) {

		if (exists $NULL_STORED{$subtype}) { next; }

   	my $MDATA=$self->apply_metric_snmp_class2( {'subtype'=> $subtype}, $device);
   	#print Dumper($MDATA);

		foreach my $iid (keys %$MDATA) {

	      my ($new,$old)= ('','');
   	   if ($MDATA->{$iid}->{'label'} =~ /^(.+?)\(/)  { $new = $self->escape($1); }
      	if ($MDATA_STORED{$subtype}{$iid}->{'label'} =~ /^(.+?)\(/) { $old=$1; }

			my $mstatus=$MDATA_STORED{$subtype}{$iid}->{'mstatus'};
			if ($old eq '') {
				print ">>+ ; $device->{'ip'} ; $subtype ; **IID** ; $iid ; NUEVO=$new  ; DS=$dstatus ; MS=$mstatus ; NO ES METRICA EN CURSO\n";
			}
	      elsif ($new ne $old) {
   	      print ">>* ; $device->{'ip'} ; $subtype ; **CAMBIO IID** ; $iid ; NUEVO=$new  ;  OLD=$old ; DS=$dstatus ; MS=$mstatus ; ==> REGENERAR METRICA\n";
      	}
	      else {
   	      #print ">> $device->{'ip'} : IID ($iid) NUEVO=$new    OLD=$old\n";
      	}
		}

   }
}

#-------------------------------------------------------------------------------
# FUNCTION: apply_metric_snmp_class1
#-------------------------------------------------------------------------------
sub apply_metric_snmp_class1  {
my ($self,$minfo,$device)=@_;

	if ($device->{'entity'}) { return; }

   my $store=$self->istore();
   my $dbh=$self->dbh();
	my $subtype=$minfo->{'subtype'};
	$self->log('debug',"apply_metric_snmp_class1::[DEBUG] ******* $subtype");
	
   #---------------------------------------------------------------
   # Se obtienen los parametros de la metrica de BD (cfg_monitor_snmp)
   #my $what='mtype,vlabel,label,items,mode,oid,top_value,get_iid,module';
   my $what='mtype,vlabel,descr,items,mode,oid,top_value,get_iid,module';
   my $where="subtype=\'$subtype\'";
   my $rres=$store->get_from_db($dbh,$what,'cfg_monitor_snmp',$where);

   if (! defined $rres->[0])  {
		$self->log('warning',"apply_metric_snmp_class1::[WARN] NO HAY DATOS PARA GENERAR $subtype");
      return;
   }


   #-------------------------------------------------------
	# Se hace una minima validacion para evitar generar metricas azules
   my %snmpcfg=();
   $snmpcfg{'host_ip'}=$device->{'ip'};
   $snmpcfg{'host_name'}=$device->{'name'};
   $snmpcfg{'community'}=$device->{'community'} || 'public';
   $snmpcfg{'version'}= $device->{'version'} || '1';
   $snmpcfg{'auth_proto'}= $device->{'auth_proto'};
   $snmpcfg{'auth_pass'}= $device->{'auth_pass'};
   $snmpcfg{'priv_proto'}= $device->{'priv_proto'};
   $snmpcfg{'priv_pass'}= $device->{'priv_pass'};
   $snmpcfg{'sec_name'}= $device->{'sec_name'};
   $snmpcfg{'sec_level'}= $device->{'sec_level'};
   my @o=split(/\|/,$rres->[0][5]);
   $snmpcfg{'oid'} = $o[0];

	my $snmp=$self->snmp();
   my $r=$snmp->core_snmp_get(\%snmpcfg);
   my $result = $r->[0];
   my $rc=$snmp->err_num();
   my $rcstr=$snmp->err_str();
   if ($rc !=0) {
      $self->log('warning',"apply_metric_snmp_class1::[WARN] EL DISPOSITIVO NO RESPONDE A LA METRICA $subtype  rc=$rc ($rcstr)");
      return;
   }




	my %mdata=();
	my $label=$rres->[0][2].' ('.$device->{'full_name'}.')';
	$mdata{'ALL'} = { 'mtype'=>$rres->[0][0], 'vlabel'=> $rres->[0][1], 'label'=>$label, 'items'=>$rres->[0][3], 'mode'=>$rres->[0][4], 'oid'=>$rres->[0][5], 'top_value'=>$rres->[0][6], 'get_iid'=>$rres->[0][7], 'module'=>$rres->[0][8], 'name'=>$subtype, 'iid'=>'ALL' };

	return \%mdata;
}


#-------------------------------------------------------------------------------
# FUNCTION: apply_metric_snmp_class2
# IN:
#	$minfo:	Parametros globales de la metrica (cfg_monitor_snmp)
#	$device:	Parametros globales del dispositivo
#-------------------------------------------------------------------------------
sub apply_metric_snmp_class2  {
my ($self,$minfo,$device)=@_;

	if ($device->{'entity'}) { return; }

	my $snmp=$self->snmp();
   my $store=$self->istore();
	my $dbh=$self->dbh();
	my $f2key=$minfo->{'subtype'};

	my $task_id=$device->{'host_ip'}.'-'.$f2key;
	$snmp->task_id($task_id);

	my $rv=$store->get_from_db($dbh,'module,oid,mtype,vlabel,mode,top_value,get_iid,items,cfg,descr,esp','cfg_monitor_snmp',"subtype='$f2key'");
   if (!defined $rv) {
		$self->log('warning',"apply_metric_snmp_class2::[WARN] NO HAY DATOS PARA GENERAR $f2key");
      return;
   }

   $minfo->{'module'}=$rv->[0][0];
   $minfo->{'oid'}=$rv->[0][1];
   $minfo->{'mtype'}=$rv->[0][2];
   $minfo->{'vlabel'}=$rv->[0][3];
   $minfo->{'mode'}=$rv->[0][4];
   $minfo->{'top_value'}=$rv->[0][5];
   $minfo->{'get_iid'}=$rv->[0][6];
   $minfo->{'items'}=$rv->[0][7];
   $minfo->{'label'}=$rv->[0][9];
   my $esp = $rv->[0][10];

	# Metricas con instancias que se evaluan sobre el total
	# Solo hay un iid que es TOTAL. La metrica se calcula sobre el resultado de todas.
	if ($esp =~ /^TABLE/) {
			
		$self->log('debug',"apply_metric_snmp_class2::[DEBUG] **TABLE** SUBTYPE=$minfo->{'subtype'} FX=$f2key");

		my $iid = 'TABLE';
		#my $name = $minfo->{'subtype'}.'-'.$iid;
		my $name = $minfo->{'subtype'};
		my $label = $minfo->{'label'} .'('.$device->{'full_name'}.')' ; 
		my %tot_mdata=();
		$tot_mdata{$iid} = {   	'mtype'=>$minfo->{'mtype'},
	   			               'vlabel'=> $minfo->{'vlabel'},
   	         		        	'label'=>$minfo->{'label'},
            			         'items'=>$minfo->{'items'},
  				                  'mode'=>$minfo->{'mode'},
                    				'oid'=>$minfo->{'oid'},
			                     'top_value'=>$minfo->{'top_value'},
           				         'get_iid'=>$minfo->{'get_iid'},
			                     'module'=>$minfo->{'module'},
           				         'name'=>$name,
			                     'iid'=>$iid };

		return \%tot_mdata;
	}



	# Si el campo $minfo->{'subtype'} ($f2key) no contiene una clave de las funciones de procesado interno,
	# se utiliza la funcion por defecto de provision de matricas clase2
	if (!  exists $ProvisionLite::Class2fx{$f2key} ) { $f2key = 'snmp_class2_default';  }

	$self->log('debug',"apply_metric_snmp_class2::[DEBUG] MDATA SUBTYPE=$minfo->{'subtype'} FX=$f2key");

	my $mdata = &{$ProvisionLite::Class2fx{$f2key}}($device,$snmp,$minfo);

   return $mdata;
}



#-------------------------------------------------------------------------------
# FUNCTION: _set_iid_data
# Se ejecuta para cada valor de iid.
# Compone un hash cuyas claves son las instancias y los valores la estructura con los
# parametros relevantes de cada instancia de la metrica (label,mtype,name ...)
# IN:
#	$data	:	Parametros globales de la metrica (cfg_monitor_snmp)
#	$out	:	Valores de la metrica instanciada (MDATA)
#-------------------------------------------------------------------------------
sub _set_iid_data  {
my ($iid,$data,$out)=@_;


	my $oid = $data->{'oid'};
   $oid=~s/IID/$iid/g;


   $out->{$iid}= {   'mtype'=>$data->{'mtype'},
                     'vlabel'=> $data->{'vlabel'},
                     'label'=>$data->{'label'},
                     'items'=>$data->{'items'},
                     'mode'=>$data->{'mode'},
                     'oid'=>$oid,
                     'top_value'=>$data->{'top_value'},
                     'get_iid'=>$data->{'get_iid'},
                     'module'=>$data->{'module'},
                     'name'=>$data->{'name'},
                     'iid'=>$iid };

}



#-------------------------------------------------------------------------------
# FUNCTION: apply_metric_snmp_class3
#-------------------------------------------------------------------------------
sub apply_metric_snmp_class3  {
my ($self,$minfo,$device)=@_;

	if ($device->{'entity'}) { return; }

   my $store=$self->istore();
   my $dbh=$self->dbh();
   my $subtype=$minfo->{'subtype'};
	$self->log('debug',"apply_metric_snmp_class3::[DEBUG] ******* $subtype");

   #---------------------------------------------------------------
   # Se obtienen los parametros de la metrica de BD (cfg_monitor_snmp)
   my $what='mtype,vlabel,label,items,mode,oid,top_value,get_iid,module';
   my $where="subtype=\'$subtype\'";
   my $rres=$store->get_from_db($dbh,$what,'cfg_monitor_snmp',$where);

   if (! defined $rres->[0])  {
      $self->log('warning',"apply_metric_snmp_class3::[WARN] NO HAY DATOS PARA GENERAR $subtype");
      return;
   }


   #-------------------------------------------------------
   # Se hace una minima validacion para evitar generar metricas azules
   my %snmpcfg=();
   $snmpcfg{'host_ip'}=$device->{'ip'};
   $snmpcfg{'host_name'}=$device->{'name'};
   $snmpcfg{'community'}=$device->{'community'} || 'public';
   $snmpcfg{'version'}= $device->{'version'} || '1';
   $snmpcfg{'auth_proto'}= $device->{'auth_proto'};
   $snmpcfg{'auth_pass'}= $device->{'auth_pass'};
   $snmpcfg{'priv_proto'}= $device->{'priv_proto'};
   $snmpcfg{'priv_pass'}= $device->{'priv_pass'};
   $snmpcfg{'sec_name'}= $device->{'sec_name'};
   $snmpcfg{'sec_level'}= $device->{'sec_level'};
   $snmpcfg{'oid'} = $rres->[0][5];		# El oid es del tipo: hrProcessorFrwID_hrProcessorLoad

   my $snmp=$self->snmp();
   my $r=$snmp->core_snmp_table(\%snmpcfg);
   my $rc=$snmp->err_num();
   my $rcstr=$snmp->err_str();
   if ($rc !=0) {
      $self->log('warning',"apply_metric_snmp_class1::[WARN] EL DISPOSITIVO NO RESPONDE A LA METRICA $subtype  rc=$rc ($rcstr)");
      return;
   }

   #----------------------------------------------------------------------------
	# Hay metricas especiales que sumarizan instancias en una grafica (p. ej la de
	# cpu_mibhost ==> En una grafica se ponen los datos de varias CPUs de la maquina"	
	my $items=$rres->[0][3];
	my $oid=$rres->[0][5];
   if ($items =~ /items_fx\((.+)\)/) {
		my $txt=$1;
		$items=$self->items_fx($device,$oid,$txt);
	}
	if (! defined $items) { return undef;  }

   #----------------------------------------------------------------------------
   my %mdata=();
   my $label=$rres->[0][2].' ('.$device->{'full_name'}.')';
   $mdata{'ALL'} = { 'mtype'=>$rres->[0][0], 'vlabel'=> $rres->[0][1], 'label'=>$label, 'items'=>$items, 'mode'=>$rres->[0][4], 'oid'=>$oid, 'top_value'=>$rres->[0][6], 'get_iid'=>$rres->[0][7], 'module'=>$rres->[0][8], 'name'=>$subtype, 'iid'=>'ALL' };
   return \%mdata;

}


#-------------------------------------------------------------------------------
# FUNCTION: items_fx
#-------------------------------------------------------------------------------
sub items_fx  {
my ($self,$device,$oid,$txt)=@_;

   #----------------------------------------------------------------------------
   # Caso: items variable  => Hay que saber cuantas instancias tiene la tabla
   #  que se esta monitorizando porque cada una de ellas es un valor de la grafica
   #  p. ej: uso cpu
   my %D=();
   $D{'host_ip'} = $device->{'ip'};
   $D{'host_name'} = $device->{'name'};
   $D{'community'} = $device->{'community'};
   $D{'version'} = $device->{'version'};
   $D{'oid'} = $oid;

   #----------------------------------------------------------------------------
   my $snmp=$self->snmp();
   my $res=$snmp->core_snmp_table(\%D);
   my $n=scalar @$res;
	if ($n == -1) {
		$self->log('warning',"items_fx::[WARN] NO SE PUEDEN CALCULAR LOS ITEMS DE LA METRICA IP=$D{host_ip} C=$D{community} V=$D{version} OID=$D{oid} TXT=$txt");
		return undef;
	}

   #----------------------------------------------------------------------------
	# Empaqueto las instancias en bloques de 4 para no generar metricas demasiado sobrecargadas.
	
	my @I=();
	for my $i (1..$n) { push @I, "$txt-$i";  }
	return join ('|', @I);


#	my $max_metrics_in_graph=4;
#	my @b=();
#	my $block=0;
#	my %all_blocks=();
#	for my $i (0..$n-1) {
#		my $new_block = int(($i-1)/$max_metrics_in_graph);
#		if ($new_block == $block) { push @b, $I[$i];  }
#		else {
#			$all_blocks{$block} = join ('|', @b);
#		   @b=();
#			$block=$new_block;
#		}
#	}
#	if (scalar @b > 0) { $all_blocks{$block} = join ('|', @b); }


#DBG--
#while (my ($k,$v)=each %all_blocks) {
#	$self->log('debug',"items_fx::[DEBUG] ITEMS>> BLOQUE=$k VALOR=$v");
#}
#/DBG--


#	return \%all_blocks;

}



#-------------------------------------------------------------------------------
# FUNCTION: apply_metric_latency
#-------------------------------------------------------------------------------
sub apply_metric_latency  {
my ($self,$minfo,$device)=@_;

	if ($device->{'entity'}) { return; }

   my $store=$self->istore();
   my $dbh=$self->dbh();
   # En este caso subtype equivale al mname
   my $subtype=$minfo->{'subtype'};

   #---------------------------------------------------------------
   # Se obtienen los parametros de la metrica de BD (cfg_monitor)
   my $what='mtype,vlabel,description,items,module,mode,params,monitor,severity';
   my $where="monitor=\'$subtype\'";
   my $rres=$store->get_from_db($dbh,$what,'cfg_monitor',$where);

   if (! defined $rres->[0])  {
      $self->log('warning',"apply_metric_latency::[WARN] NO HAY DATOS PARA GENERAR $subtype");
      return;
   }

   my %mdata=();
   my $label=$rres->[0][2].' ('.$device->{'full_name'}.')';
   $mdata{'ALL'} = { 'mtype'=>$rres->[0][0], 'vlabel'=> $rres->[0][1], 'label'=>$label, 'items'=>$rres->[0][3], 'module'=>$rres->[0][4], 'mode'=>$rres->[0][5], 'params'=>$rres->[0][6], 'name'=>$rres->[0][7], 'monitor'=>$subtype, 'severity'=>$rres->[0][8], 'iid'=>'ALL' };

   return \%mdata;

}


#-------------------------------------------------------------------------------
# FUNCTION: apply_metric_xagent
# Se aplican metricas de tipo xagent.
# Si cfg=1 (sin iids). Se aplica sin mas y se actualiza laplantilla
# Si cfg=2 (con iids). Se valida que los iids son correctos.
#-------------------------------------------------------------------------------
sub apply_metric_xagent  {
my ($self,$minfo,$device)=@_;

   my $store=$self->istore();
   my $dbh=$self->dbh();
   my $subtype=$minfo->{'subtype'};

   my $iid=$minfo->{'iid'};
#$self->log('info',"apply_metric_xagent::[**FML**] IID=$iid");

   #---------------------------------------------------------------
   # Se obtienen los parametros de la metrica de BD (cfg_monitor_xagent)

# select a.mtype,a.vlabel,a.description,a.items,a.module,a.mode,a.class,a.params,a.severity,a.cfg,a.custom,a.script,a.get_iid,a.id_proxy,s.proxy_user  FROM cfg_monitor_agent a, cfg_monitor_agent_script s  where  a.script=s.script AND a.script='snmp_metric_count_proc_multiple_devices';


   my $what='a.mtype,a.vlabel,a.description,a.items,a.module,a.mode,a.class,a.params,a.severity,a.cfg,a.custom,a.script,a.get_iid,a.id_proxy,s.proxy_type,s.proxy_user,a.tag,a.esp';
   my $where="a.script=s.script AND subtype=\'$subtype\'";
   my $rres=$store->get_from_db($dbh,$what,'cfg_monitor_agent a, cfg_monitor_agent_script s',$where);

   if (! defined $rres->[0])  {
      $self->log('warning',"apply_metric_xagent::[WARN] NO HAY DATOS PARA GENERAR $subtype");
      return;
   }
#print "select $what from cfg_monitor_wbem where $where\n";

#   my %mdata=();
#   my $mname=$subtype;
#   if ($minfo->{'iid'} ne 'ALL') {
#      my $k=md5_hex($minfo->{'iid'});
#      $mname=$subtype.'-'.substr $k,0,8;
#   }


$self->log('warning',"apply_metric_xagent::{***DEBUG***} subtype=$subtype");


   my %mdata=();
   my $mname=$subtype;
	my $label='';
	my $cfg=$rres->[0][9];
	my $esp=$rres->[0][17];

   if ( ($cfg==1) || ($cfg==2 && $esp=~/^TABLE/) ){
		$label=$rres->[0][2].' ('.$device->{'full_name'}.')';

		$iid='ALL';
	   $mdata{$iid} = { 'mtype'=>$rres->[0][0], 'vlabel'=> $rres->[0][1], 'label'=>$label, 'items'=>$rres->[0][3], 'module'=>$rres->[0][4], 'mode'=>$rres->[0][5], 'class'=>$rres->[0][6], 'params'=>$rres->[0][7], 'name'=>$mname, 'monitor'=>$subtype, 'iid'=>$iid, 'id_proxy'=>$rres->[0][13]  };
	}

   elsif ($cfg==2) {

		my $XAGENT=$self->xagent();
		$XAGENT->store($store);
		$XAGENT->dbh($dbh);
      #my $xagent=Crawler::Xagent->new( 'timeout'=>20, 'log_level'=>$log_level);

#/opt/crawler/bin/libexec/get_iid -i 10.2.254.69 -o win32_metric_wmi_core.vbs -t xagent -u 0 -p "[;Clase;Win32_PerfRawData_PerfDisk_LogicalDisk]:[;Atributo;Name]"
      my %desc=();
      $desc{'host_ip'} = $device->{'ip'};
      $desc{'custom'} = $rres->[0][10];
      $desc{'script'} = $rres->[0][11];
      $desc{'params'} = $rres->[0][7];	# params es el campo get_iid
      $desc{'cfg'} = $cfg;		#Hay que ponerlo a 1 para chequear iids
      $desc{'id_proxy'} = $rres->[0][13];
      $desc{'proxy_type'} = $rres->[0][14];
      $desc{'proxy_user'} = $rres->[0][15];
      $desc{'tag'} = $rres->[0][16];
		$desc{'subtype'} = $subtype;
		$desc{'iid'} = 'ALL';

		my $credentials = $store->get_device_credentials($dbh,{'ip'=>$desc{'host_ip'}});		
	   my $exec_vector=$XAGENT->exec_vector();
		$exec_vector->{'params'}=$XAGENT->_compose_params($desc{'params'},$desc{'host_ip'},$credentials);
   	$exec_vector->{'file_script'}=$desc{'script'};
   	$exec_vector->{'proxy_type'}=$desc{'proxy_type'};
   	$exec_vector->{'proxy_user'}=$desc{'proxy_user'};
   	$XAGENT->exec_vector($exec_vector);


		#my $c1=$rres->[0][7];
		#if ($c1 =~ /(\S+)\:.*/) { $desc{'params'} = $1.':[;Atributo;'.$rres->[0][12].']'; }

$self->log('warning',"apply_metric_xagent::[**FML**] IIDS $desc{'host_ip'} - $desc{'custom'} - $desc{'script'} - $desc{'params'}");

      my $res=$XAGENT->mod_xagent_get_iids(\%desc);

      my $cnt=1;
      foreach my $iid (@$res) {

         $cnt +=1;

			#my ($tag,$iid)=('',$tag_iid);
			#if ($tag_iid =~ /(\S+)\.(\S+)/) { ($tag,$iid)=($1,$2); }

			#my $params=$rres->[0][7];
   	   #my $k=md5_hex($params);
      	#$mname=$subtype.'-'.substr $k,0,8;

         my $k=md5_hex($iid);
         $mname=$subtype.'-'.substr $k,0,8;

			if (length($iid)>15) {
				$label=$rres->[0][2].' '.$iid;
			}
			else {
				$label=$rres->[0][2].' '.substr($iid,0,22).' ('.$device->{'full_name'}.')';
			}

			if ($iid eq 'U') {
				$self->log('warning',"apply_metric_xagent::[**FML**] $cnt: SALTO IID=$iid MNAME=$mname");
				next;
			}
			$self->log('info',"apply_metric_xagent::[**FML**] $cnt: IID=$iid MNAME=$mname");

	   	$mdata{$iid} = { 'mtype'=>$rres->[0][0], 'vlabel'=> $rres->[0][1], 'label'=>$label, 'items'=>$rres->[0][3], 'module'=>$rres->[0][4], 'mode'=>$rres->[0][5], 'class'=>$rres->[0][6], 'params'=>$rres->[0][7], 'name'=>$mname, 'monitor'=>$subtype, 'iid'=>$iid };
		}

	}	




   return \%mdata;
}



#-------------------------------------------------------------------------------
# FUNCTION: metric2db
#-------------------------------------------------------------------------------
sub metric2db  {
my ($self,$ID_DEV,$device,$v)=@_;

   my $STORE=$self->istore();
   my $WSCLIENT=$self->wsclient();
	$WSCLIENT->store($STORE);
   my $dbh=$self->dbh();

	my %M=();

   $M{'name'}=$v->{'name'};

   $M{'type'}=$v->{'type'};
   $M{'subtype'}=$v->{'subtype'};
   $M{'mtype'}=$v->{'mtype'};

	# Se eliminan caracteres incomodos del titulo de la metrica
   $M{'label'}=$self->escape($v->{'label'});

   $M{'vlabel'}=$v->{'vlabel'};
   $M{'items'}=$v->{'items'};
   $M{'lapse'}=$v->{'lapse'};
   my ($create,$graph)=split('_',$v->{'mtype'});

   my $dir=sprintf ("%010d",$ID_DEV);
   $M{'file'}=$dir.'/'.$v->{'name'}.'-'.$create.'.rrd';

	# El nombre del host es el del servidor de CNM
	my $cfg=$self->cfg();
   $M{'host'}=$cfg->{'host_name'}->[0];

   $M{'graph'}=$v->{'graph'};
   $M{'mode'}=$v->{'mode'};
   $M{'module'}=$v->{'module'};
   $M{'watch'}=$v->{'watch'};
   $M{'refresh'}=1;

   $M{'status'}=$v->{'status'};
   # Si la metrica esta inactiva la borro, prefiero no tener metricas en estado inactivo
   if ($M{'status'} != 0) { $M{'status'}=3; }

  	$M{'severity'}=$v->{'severity'} || 2;
   $M{'iid'}=$v->{'iid'} || 'ALL';

   # Se supone que set_data_path tiene la inteligencia necesaria para asignar los diferentes discos
   # posibles  que tenga un determinado equipo

   #($M{file_path},$M{disk}) = $STORE->set_data_path ($rcfgbase->{disk},$M{lapse},$HOST);
   ($M{'file_path'},$M{'disk'}) = ('/opt/data/rrd/',0);

   $M{'file_path'}.=$STORE->store_subdir('elements');

   my $full_dir=$M{'file_path'}.sprintf ("%010d",$ID_DEV);

	$M{'subtable'}=0;

#DBG--
   $self->log('debug',"metric2db::[DEBUG] ++++++ STORE METRIC");
   while (my ($a,$b)=each %M) {
		if (!defined $b) { $b=' '; }
      $self->log('debug',"metric2db::[DEBUG] M==> $a->$b");
   }
#/DBG--


   my $id_metric=$STORE->store_metric($dbh,$ID_DEV,\%M);
	#$WSCLIENT->sync_data('metrics');




   my %T=();
	# SNMP -------------------------------------------------
   if ($M{'type'} eq 'snmp') {
   	$T{'id_dev'}=$ID_DEV;
      $T{'name'}=$M{'name'};
      $T{'community'}=$device->{'community'};
      #$T{'version'}= (defined $v->{version}) ? $v->{version} : '2';
      $T{'version'}= ($device->{'version'}) ? $device->{'version'} : '1';
      $T{'params'}=$v->{'params'};


      #Parseo los OIDS por si se han introducido con su nombre
      my @ov1=split(/\|/,$v->{'oid'});
      my @ov2=();
      my $on='';
      foreach my $os (@ov1) {
      	if ($os =~ /.*?\:\:.*/) {
         	$on=`/usr/local/bin/snmptranslate -On $os`;
            chomp $on;
            push @ov2,$on;
         }
         else { push @ov2,$os; }
      }
      $T{'oid'}=join('|',@ov2);


#DBG--
#FML
   $self->log('debug',"metric2db::[DEBUG] ++++++ METRIC2SNMP");
   while (my ($a,$b)=each %T) {
		if ($a eq 'params') {  next;  }
		$self->log('debug',"metric2db::[DEBUG] M==> $a->$b");
   }
#/DBG--



      $STORE->store_metric2snmp($dbh,\%T);
	}
	# LATENCY -----------------------------------------------
   elsif ($M{'type'} eq 'latency') {
		$T{'id_dev'}=$ID_DEV;
      $T{'name'}=$M{'name'};
      $T{'monitor'}=$v->{'monitor'};
      $T{'monitor_data'}=$v->{'params'};

#DBG--
   $self->log('debug',"metric2db::[DEBUG] ++++++ METRIC2LATENCY");
   while (my ($a,$b)=each %T) {
      $self->log('debug',"metric2db::[DEBUG] M==> $a->$b");
   }
#/DBG--

      $STORE->store_metric2latency($dbh,\%T);
	}

}


@ProvisionLite::LIST_SUPPORTED=();
%ProvisionLite::SNMP_CHECK_VECTOR=();
%ProvisionLite::LATENCY_CHECK_VECTOR=();
%ProvisionLite::XAGENT_CHECK_VECTOR=();
%ProvisionLite::SNMP_REMOTE_CHECK_VECTOR=();

%ProvisionLite::APPS2DEVICE=();
%ProvisionLite::METRICS2DEVICE=();

# ------------------------------------------------------------------------
# 	get_check_vectors
#  Obtiene todas las metricas y aplicaciones configuradas en el sistema
# 	organizadas en diferentes hashes para poder chequear si los dispositivos
#	responden a las mismas.
#	Los vectores son los siguientes:
# 	@ProvisionLite::LIST_SUPPORTED	
#		Almacena el listado de metricas y aplicaciones soportadas (informativo)
#	%ProvisionLite::SNMP_CHECK_VECTOR
#	%ProvisionLite::LATENCY_CHECK_VECTOR
#	%ProvisionLite::XAGENT_CHECK_VECTOR
#	OJO!! $range se convierte en clave global a los diferentes tipos de metricas/apps
#-------------------------------------------------------------------------------
sub get_check_vectors {
my ($self)=@_;

   my $STORE=$self->istore();
   my $dbh=$self->dbh();
   my $rcfgbase=$self->cfg();

   my $SNMP=$self->snmp();
   my $WBEM=$self->wbem();
   my $WSCLIENT=$self->wsclient();


	@ProvisionLite::LIST_SUPPORTED=();
	%ProvisionLite::SNMP_CHECK_VECTOR=();
	%ProvisionLite::LATENCY_CHECK_VECTOR=();
	%ProvisionLite::XAGENT_CHECK_VECTOR=();
	%ProvisionLite::SNMP_REMOTE_CHECK_VECTOR=();

	#-------------------------------------------------------------------------------------------
	# OBTENEMOS LAS METRICAS SNMP
	# GENERAMOS %SNMP_CHECK_VECTOR indexado por $enterprise (por eficiencia)
	# GENERAMOS %METRICS2DEVICE con clave=>range y valor ref a array con las metricas de dicho range
	# CONSIDERAMOS cfg=1 O cfg=2. EL CASO DE cfg=3 (SNMP ESPECIALES) HABRIA QUE VALIDARLO CON chk_metric
	my $rres=$STORE->get_from_db( $dbh, 'subtype,myrange,enterprise,descr,lapse,include,oidn,cfg,module,apptype', 'cfg_monitor_snmp', "", "order by cfg,enterprise");
	foreach my $l (@$rres) {
   	my ($subtype,$range,$enterprise,$descr,$lapse,$include,$oidn,$cfg,$module,$apptype)=($l->[0], $l->[1], $l->[2], $l->[3], $l->[4], $l->[5], $l->[6], $l->[7], $l->[8], $l->[9]);
		if ($range ne '') {

			if ( exists $ProvisionLite::EXCLUDED_OIDS{$range}) {
				$self->log('info',"get_check_vectors::EXCLUYO RANGE (METRIC) = $range");
 				next; 
			}
		   $ProvisionLite::SNMP_CHECK_VECTOR{$enterprise}{$range}=0;
   		push @{$ProvisionLite::METRICS2DEVICE{$range}}, { 'type'=>'snmp', 'subtype'=>$subtype, 'enterprise'=>$enterprise, 'descr'=>$descr, 'lapse'=>$lapse, 'include'=>$include, 'oidn'=>$oidn, 'cfg'=>$cfg, 'module'=>$module };
		}
		# Si cfg>0 (1,2,3) registro el error.
		elsif ($l->[7]>0){
			$self->log('warning',"get_check_vectors::[WARN] RANGE SIN VALOR en cfg_monitor_snmp SUBTYPE=$subtype cfg=$cfg ENT=$enterprise DESC=$descr OIDN=$oidn");
		}
   	push @ProvisionLite::LIST_SUPPORTED, {'item'=>'MET.snmp', 'range'=>$range, 'enterprise'=>$enterprise, 'subtype'=>$subtype, 'descr'=>$descr, 'apptype'=>$apptype};
	}



	#-------------------------------------------------------------------------------------------
	# OBTENEMOS LAS METRICAS LATENCY DE PUERTO TCP o ICMP
	# CONSIDERAMOS LAS METRICAS DE TIPO PUERTO
	# EL RESTO DE METRICAS DE TIPO LATENCY HABRIA QUE VALIDARLAS CON chk_metric
	#$rres=$STORE->get_from_db( $dbh, 'monitor as subtype,monitor as range,description as descr,lapse,include,port', 'cfg_monitor', "(monitor like '%mon_tcp%' or monitor like '%_icmp') and cfg=1", "");
	#monitor as range
	$rres=$STORE->get_from_db( $dbh, 'monitor as subtype,monitor,description as descr,lapse,include,port,apptype', 'cfg_monitor', "cfg=1", "");
	foreach my $l (@$rres) {
   	my ($subtype,$range,$descr,$lapse,$include,$port,$apptype)=($l->[0], $l->[1], $l->[2], $l->[3], $l->[4], $l->[5], $l->[6]);
		if ($range ne '') {
	   	$ProvisionLite::LATENCY_CHECK_VECTOR{$range}=0;
   		push @{$ProvisionLite::METRICS2DEVICE{$range}}, { 'type'=>'latency', 'subtype'=>$subtype, 'descr'=>$descr, 'lapse'=>$lapse, 'include'=>$include, 'port'=>$port };
   		push @ProvisionLite::LIST_SUPPORTED, {'item'=>'MET.latency', 'range'=>$range, 'enterprise'=>'0', 'subtype'=>$subtype, 'descr'=>$descr, 'apptype'=>$apptype};
		}
	}

	#-------------------------------------------------------------------------------------------
	# METRICAS DE TIPO XAGENT 
   $rres=$STORE->get_from_db( $dbh, 'subtype,myrange,proxy_type,description as descr,lapse,include,cfg,module,apptype', 'cfg_monitor_agent', "cfg>0", "order by proxy_type,cfg");
   foreach my $l (@$rres) {
      my ($subtype,$range,$proxy_type,$descr,$lapse,$include,$cfg,$module,$apptype)=($l->[0], $l->[1], $l->[2], $l->[3], $l->[4], $l->[5], $l->[6], $l->[7], $l->[8]);
		if ($range ne '') {
			$ProvisionLite::XAGENT_CHECK_VECTOR{$range}=0;
			push @{$ProvisionLite::METRICS2DEVICE{$range}}, { 'type'=>'xagent', 'subtype'=>$subtype, 'descr'=>$descr, 'lapse'=>$lapse, 'include'=>$include };
   		push @ProvisionLite::LIST_SUPPORTED, {'item'=>'MET.proxy', 'range'=>'', 'enterprise'=>$proxy_type, 'subtype'=>$subtype, 'descr'=>$descr, 'apptype'=>$apptype};
		}
   }


	#-------------------------------------------------------------------------------------------
	# OBTENEMOS LAS APLICACIONES (SNMP, LATENCY, XAGENT)
	# GENERAMOS LOS HASHES:
	# %SNMP_CHECK_VECTOR
	# %LATENCY_CHECK_VECTOR
	# %XAGENT_CHECK_VECTOR
	# GENERAMOS %APPS2DEVICE con clave=>range y valor ref a array con las aplicaciones de dicho range
	# Para las apps de tipo latency hay que obtener el puerto que es el parametro que define si se asocian o no.
	# Para cada una de ellas se corresponde con un valor diferente de hparam en la tabla cfg_app_param:
	# 30000013 -> Param Puerto en apps mon_smtp_ext
	# 30000011 -> Param Puerto en apps cnm-sslcerts
	# 3000000a -> Param Puerto en apps mon_tcp
	my %APP_PORTS=();
	$rres=$STORE->get_from_db( $dbh, 'aname,value', 'cfg_app_param', "hparam IN ('30000013','3000000a','30000011')", "");
	foreach my $l (@$rres) { 
		if ($l->[1] =~ /\d+/) { $APP_PORTS{$l->[0]} = $l->[1]; }
		else { $APP_PORTS{$l->[0]} = 0; }
	}

	$rres=$STORE->get_from_db( $dbh, 'id_monitor_app,myrange,name,type,platform,enterprise,aname,script,params,apptype', 'cfg_monitor_apps', "", "order by type");
	foreach my $l (@$rres) {
   	my ($id,$range,$name,$type,$platform,$enterprise,$aname,$script,$params,$apptype)=($l->[0], $l->[1], $l->[2], $l->[3], $l->[4], $l->[5], $l->[6],$l->[7],$l->[8],$l->[9]);

		if ($range eq '') { next; }

	   if ($type eq 'snmp') {

         if ( exists $ProvisionLite::EXCLUDED_OIDS{$range}) {
            $self->log('info',"get_check_vectors::EXCLUYO RANGE (APP) = $range");
            next;
         }

   	   $ProvisionLite::SNMP_CHECK_VECTOR{$enterprise}{$range}=0;
      	push @{$ProvisionLite::APPS2DEVICE{$range}}, {'id'=>$id,  'aname'=>$aname};
  	 	}
   	elsif ($type eq 'latency') {
      	$ProvisionLite::LATENCY_CHECK_VECTOR{$range}=0;
			my $p=$APP_PORTS{$aname};
			if (! defined $p) { $p=0; }
      	push @{$ProvisionLite::APPS2DEVICE{$range}}, {'id'=>$id,  'aname'=>$aname, 'script'=>$script, 'port'=>$p};
   	}
   	elsif ($type eq 'xagent') {
      	$ProvisionLite::XAGENT_CHECK_VECTOR{$range}=0;
	      push @{$ProvisionLite::APPS2DEVICE{$range}}, {'id'=>$id,  'aname'=>$aname, 'script'=>$script};
   	}
      push @ProvisionLite::LIST_SUPPORTED, {'item'=>'APP', 'range'=>$range, 'enterprise'=>$type, 'subtype'=>$aname, 'descr'=>$name, 'apptype'=>$apptype};

	}


   #-------------------------------------------------------------------------------------------
   # ALERTAS REMOTAS (para LIST_SUPPORTED)
   #
   #
   #$rres=$STORE->get_from_db( $dbh, 'SUBSTRING(subtype,1,40),descr,apptype,enterprise,id_remote_alert', 'cfg_remote_alerts', "subtype NOT LIKE '%Starix%'", "order by apptype");
   $rres=$STORE->get_from_db( $dbh, 'SUBSTRING(subtype,1,40),descr,apptype,enterprise,id_remote_alert', 'cfg_remote_alerts', '', "order by apptype");
   foreach my $l (@$rres) {
      my ($subtype,$descr,$apptype,$enterprise,$id_remote_alert)=($l->[0], $l->[1], $l->[2], $l->[3], $l->[4]);
#, $l->[3], $l->[4], $l->[5], $l->[6],$l->[7]);

      push @{$ProvisionLite::SNMP_REMOTE_CHECK_VECTOR{$enterprise}}, { 'id_remote_alert'=>$id_remote_alert };

      push @ProvisionLite::LIST_SUPPORTED, {'item'=>'REMOTE', 'range'=>'', 'enterprise'=>$enterprise, 'subtype'=>$subtype, 'descr'=>$descr, 'apptype'=>$apptype};
   }

}


#-------------------------------------------------------------------------------
# reset_check_vectors
# Se reinician los vectores de chequeo de metricas 
#-------------------------------------------------------------------------------
sub reset_check_vectors {
my ($self)=@_;

	foreach my $enterprise (keys %ProvisionLite::SNMP_CHECK_VECTOR) { 
		foreach my $m (keys %{$ProvisionLite::SNMP_CHECK_VECTOR{$enterprise}}) {
			$ProvisionLite::SNMP_CHECK_VECTOR{$enterprise}{$m}=0;
		}
	}

   foreach my $m (keys %ProvisionLite::LATENCY_CHECK_VECTOR) {
      $ProvisionLite::LATENCY_CHECK_VECTOR{$m}=0;
   }

   foreach my $range (keys %{$ProvisionLite::XAGENT_CHECK_VECTOR}) {
      $ProvisionLite::XAGENT_CHECK_VECTOR{$range}=0;
   }

}

#-------------------------------------------------------------------------------------------
sub list_supported {
my ($self)=@_;

my ($c1,$c2,$c3,$c4,$c5);
format FORMAT_DATA =
@<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@<<<<<<<@<<<<<<<<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$c1,     $c2,                                                         $c3,                   $c4,  $c5,					
.

   $~ = 'FORMAT_DATA';

	#{'item'=>'MET.snmp', 'range'=>$range, 'enterprise'=>$enterprise, 'subtype=>'=>$subtype, 'descr'=>$descr};

   for my $h (@ProvisionLite::LIST_SUPPORTED) {
		($c1,$c2,$c3,$c4,$c5)=($h->{'item'}, $h->{'range'}, $h->{'enterprise'}, $h->{'subtype'}, $h->{'descr'});
      write();
   }
}

#-------------------------------------------------------------------------------------------
sub list_supported_simple {
my ($self)=@_;

my ($c1,$c2,$c3,$c4,$c5);
format FORMAT_DATA1 =
@<<<<<<<<<<<@<<<<<<<<<@<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$c1,     $c2,                                                         $c3,                   $c4,  $c5
.

   $~ = 'FORMAT_DATA1';

   #{'item'=>'MET.snmp', 'range'=>$range, 'enterprise'=>$enterprise, 'subtype=>'=>$subtype, 'descr'=>$descr};

   for my $h (@ProvisionLite::LIST_SUPPORTED) {
      ($c1,$c2,$c3,$c4,$c5)=($h->{'item'}, $h->{'enterprise'}, $h->{'apptype'}, $h->{'subtype'}, $h->{'descr'});
      write();
   }
}


# ------------------------------------------------------------------------
#  clone_template_metricas
#  Replica las metricas de un dispostivo origen a un vector de dispositivos destino.
#
#  a. Validar que la metrica responde en DEST
#
#     ==> En caso afirmativo, se mete en el asistente de DEST
#
#     (INSERT id_dev,include,lapse,type,subtype,descr EN prov_default_metrics2device WHERE id_dev=DEST;)
#
#  b. Obtener el mapeo de iids (es decir ver si eth0 esta en la misma instancia o no y adaptar)
#
#     ==> Aplicar en base a lo hecho en orígen (con el nombre de la instancia) a la plantilla de DEST
#
#     Se obtienen del ID_DEV_ORIGEN las Descr correspondientes a los iids.
#     Se obtienen del DEST el mapeo iid->descr
#
#     ==> Meter tambien los monitores
#     ==> Modificar el label en consecuencia
#
#  IN: Referencia a un hash
#     id_dev_src => $id_dev_src:   id_dev origen
#     id_dev_dst=> $id_dev_dst:    id_devs destino separados por ','
#-------------------------------------------------------------------------------
sub clone_template_metrics {
my ($self,$params)=@_;

   my $id_dev_src=$params->{'id_dev_src'};
   #my $id_dev_dst=$params->{'id_dev_dst'};
	my @id_dev_dst=split(',',$params->{'id_dev_dst'});
   my $STORE=$self->istore();
   my $dbh=$self->dbh();
   my $rcfgbase=$self->cfg();
   my $SNMP=$self->snmp();
   my $LATENCY=$self->latency();
   my $XAGENT=$self->xagent();

	my ($c1,$c2)=(0,0);
   $self->rc(-1);
   $self->rcstr("",1);

  	$self->log('info',"clone_template_metrics:: ID_DEV_SRC=$id_dev_src a id_devs=@id_dev_dst");
print "----------------------------------------------------------------------\n";


   my $rMETRIC_SNMP = $STORE->get_template_metrics_by_type($dbh,$id_dev_src,'snmp');
print Dumper($rMETRIC_SNMP);
print "----------------------------------------------------------------------\n";
   my $rMETRIC_LATENCY = $STORE->get_template_metrics_by_type($dbh,$id_dev_src,'latency');
print Dumper($rMETRIC_LATENCY);
print "----------------------------------------------------------------------\n";
   my $rMETRIC_AGENT = $STORE->get_template_metrics_by_type($dbh,$id_dev_src,'xagent');
print Dumper($rMETRIC_AGENT);
print "----------------------------------------------------------------------\n";

	my $rREMOTE_ALERTS = $STORE->get_from_db( $dbh, 'r.id_remote_alert', 'cfg_remote_alerts2device r, devices d', "r.target=d.ip and d.id_dev=$id_dev_src", '');
print Dumper($rREMOTE_ALERTS);
print "----------------------------------------------------------------------\n";


   foreach my $id_dev (@id_dev_dst) {

      #-------------------------------------------------------------------------------
      # Para cada $id_dev destino chequeo las diferentes metricas de la plantilla origen
      #-------------------------------------------------------------------------------
      my @prov_default_metrics=();
      my @prov_template_metrics=();
      my $rres=$STORE->get_from_db( $dbh, 'ip,name,domain', 'devices', "id_dev=$id_dev", '');
      my ($host_ip,$host_name,$domain)=($rres->[0][0],$rres->[0][1],$rres->[0][2]);
      if (! $host_ip) { next; }

      my ($n1,$n2,$n3)=(scalar(@$rMETRIC_SNMP), scalar(@$rMETRIC_LATENCY), scalar(@$rMETRIC_AGENT));
		my $totp = $n1+$n2+$n3;
      $self->log('info',"clone_template_metrics:: [$id_dev_src >> $id_dev] TOTAL EN PLANTILLA ORIGEN=$totp  (SNMP=$n1, LATENCY=$n2, XAGENT=$n3)");
      #-------------------------------------------------------------------------------
      # SNMP
      #-------------------------------------------------------------------------------
      foreach my $item (@$rMETRIC_SNMP) {

         my @RESULTS=();
         my $subtype=$item->{'subtype'};
         my $descr=$item->{'descr'};
         my $lapse=$item->{'lapse'};
         my $include=$item->{'include'};
print "++++SNMP chk_metric id_dev=$id_dev host_ip=$host_ip subtype=$subtype++++\n";
         $SNMP->chk_metric( {id_dev => $id_dev, host_ip=>$host_ip, mname=>$subtype, 'only_value'=>1}, \@RESULTS );

         #data_out contiene el resultado de la validacion
         #****tcp_estab >> DATA_OUT=0 (sin iids
         #****custom_bc0bdcb0 >> DATA_OUT = ['0']
         #****errors_mibii_if >> DATA_OUT = ['1:@:0:@:0', '2:@:0:@:0', '3:@:0:@:0', '4:@:0:@:0', '5:@:0:@:0']
         #****pkteer_link_bytes >> DATA_OUT=U
         #****custom_41ca551c >> DATA_OUT=418715 397158
         my $DATA_OUT=$SNMP->data_out();
print Dumper($DATA_OUT);
print "----------------------------------------------------------------------\n";

         # Si no responde, la salto.
         if ($DATA_OUT->[0] =~ /U/) { next; }

         $self->log('debug',"clone_template_metrics:: snmp [$id_dev_src >> $id_dev] SE METE EN ASISTENTE $subtype ($descr) (DATA_OUT=@$DATA_OUT)...");
         push @prov_default_metrics, [$id_dev, 'snmp', $subtype, $descr, $lapse, $include];

         #%IIDS_IN_DEST contiene los iids a los que responde el dispositivo destino
         my %IIDS_IN_DEST=();
         if (! exists $item->{'IIDS'}->{'ALL'}) {
           foreach my $x (@$DATA_OUT) {
             my @v=split(':',$x);
             $IIDS_IN_DEST{$v[0]}=1;
            }
         }
			else { $IIDS_IN_DEST{'ALL'}=1;}

         #Para cada iid de la metrica en el dispositivo origen valido que esista
         #dicho iid en destino, Si no existe, lo salto y no lo considero
         foreach my $iid (keys %{$item->{'IIDS'}}) {

            if (! exists $IIDS_IN_DEST{$iid}) { next; }
#            'IIDS' => {
#                        'ALL' => {
#                                   'watch' => '0',
#                                   'status' => '1',
#                                   'mname' => 'users_cnt_mibhost',
#                                   'label' => 'NUMERO DE USUARIOS (cnm-devel2.s30labs.com)',
#                                   'iid' => 'ALL'
#                                 }
#                      },
#            'subtype' => 'users_cnt_mibhost',
#            'include' => 1,
#            'lapse' => '300',
#            'type' => 'snmp',
#            'descr' => 'NUMERO DE USUARIOS'

            my $watch=$item->{'IIDS'}->{$iid}->{'watch'};
            my $mname=$item->{'IIDS'}->{$iid}->{'mname'};
            my $label=$item->{'IIDS'}->{$iid}->{'label'};
            $label =~ s/^(.*)\(.*/$1\($host_name\.$domain auto \)/;
            my $status=$item->{'IIDS'}->{$iid}->{'status'};


         	$self->log('debug',"clone_template_metrics:: snmp [$id_dev_src >> $id_dev] SE METE EN PLANTILLA iid=$iid $subtype ($descr)...");
            push (@prov_template_metrics, { 'type' => 'snmp', 'subtype' => $subtype, 'watch' => $watch, 'iid' => $iid, 'mname' => $mname, 'label' => $label, 'lapse' => $lapse, 'status' => $status } );
         }#iids

      }#Bucle de metricas SNMP


      #-------------------------------------------------------------------------------
      # LATENCY
      #-------------------------------------------------------------------------------
      foreach my $item (@$rMETRIC_LATENCY) {

         my @RESULTS=();
         my $subtype=$item->{'subtype'};
         my $descr=$item->{'descr'};
         my $lapse=$item->{'lapse'};
         my $include=$item->{'include'};
print "++++LATENCY chk_metric id_dev=$id_dev host_ip=$host_ip subtype=$subtype++++\n";
         $LATENCY->chk_metric( {id_dev => $id_dev, host_ip=>$host_ip, mname=>$subtype, 'only_value'=>1}, \@RESULTS );
#print Dumper(\@RESULTS,$LATENCY);

#         #data_out contiene el resultado de la validacion
#         #****mon_icmp >> DATA_OUT=0.104
#         #****mon_icmp >> DATA_OUT=U
         my $DATA_OUT=$LATENCY->data_out();
print Dumper($DATA_OUT);
print "----------------------------------------------------------------------\n";

         # Si no responde, la salto.
         if ($DATA_OUT->[0] =~ /U/) { next; }

         $self->log('debug',"clone_template_metrics:: latency [$id_dev_src >> $id_dev] SE METE EN ASISTENTE $subtype ($descr) (DATA_OUT=@$DATA_OUT)...");
         push @prov_default_metrics, [$id_dev, 'latency', $subtype, $descr, $lapse, $include];

         my $watch=$item->{'IIDS'}->{'ALL'}->{'watch'};
         my $mname=$item->{'IIDS'}->{'ALL'}->{'mname'};
         my $label=$item->{'IIDS'}->{'ALL'}->{'label'};
         $label =~ s/^(.*)\(.*/$1\($host_name\.$domain auto \)/;
         my $status=$item->{'IIDS'}->{'ALL'}->{'status'};

         	$self->log('debug',"clone_template_metrics:: latency [$id_dev_src >> $id_dev] SE METE EN PLANTILLA iid=ALL $subtype ($descr)...");
         push (@prov_template_metrics, { 'type' => 'latency', 'subtype' => $subtype, 'watch' => $watch, 'iid' => 'ALL', 'mname' => $mname, 'label' => $label, 'lapse' => $lapse, 'status' => $status } );

      }#Bucle de metricas Latency

      #-------------------------------------------------------------------------------
      # XAGENT, PROXY ...
      #-------------------------------------------------------------------------------
      foreach my $item (@$rMETRIC_AGENT) {

         my @RESULTS=();
         my $subtype=$item->{'subtype'};
         my $descr=$item->{'descr'};
         my $lapse=$item->{'lapse'};
         my $include=$item->{'include'};
print "++++XAGENT chk_metric id_dev=$id_dev host_ip=$host_ip subtype=$subtype++++\n";
         $XAGENT->chk_metric( {id_dev => $id_dev, host_ip=>$host_ip, mname=>$subtype, 'only_value'=>1}, \@RESULTS );

         #data_out contiene el resultado de la validacion
         #****tcp_estab >> DATA_OUT=0 (sin iids
         #****custom_bc0bdcb0 >> DATA_OUT=0
         #****errors_mibii_if >> DATA_OUT=1:@:0:@:0 2:@:0:@:0 3:@:0:@:0 4:@:0:@:0 5:@:0:@:0
         #****pkteer_link_bytes >> DATA_OUT=U
         #****custom_41ca551c >> DATA_OUT=418715 397158
         my $DATA_OUT=$XAGENT->data_out();
print Dumper($DATA_OUT);
print "----------------------------------------------------------------------\n";

#         # Si no responde, la salto.
         if ($DATA_OUT->[0] =~ /U/) { next; }

			$self->log('debug',"clone_template_metrics:: xagent [$id_dev_src >> $id_dev] SE METE EN ASISTENTE $subtype ($descr) (DATA_OUT=@$DATA_OUT)...");

         push @prov_default_metrics, [$id_dev, 'xagent', $subtype, $descr, $lapse, $include];

         #%IIDS_IN_DEST contiene los iids a los que responde el dispositivo destino
         my %IIDS_IN_DEST=();
         if (! exists $item->{'IIDS'}->{'ALL'}) {
           foreach my $x (@$DATA_OUT) {
             my @v=split(':',$x);
             $IIDS_IN_DEST{$v[0]}=1;
            }
         }
			else { $IIDS_IN_DEST{'ALL'}=1; }

         #Para cada iid de la metrica en el dispositivo origen valido que esista
         #dicho iid en destino, Si no existe, lo salto y no lo considero
         foreach my $iid (keys %{$item->{'IIDS'}}) {

            if (! exists $IIDS_IN_DEST{$iid}) { next; }
#            'IIDS' => {
#                        'ALL' => {
#                                   'watch' => '0',
#                                   'status' => '1',
#                                   'mname' => 'users_cnt_mibhost',
#                                   'label' => 'NUMERO DE USUARIOS (cnm-devel2.s30labs.com)',
#                                   'iid' => 'ALL'
#                                 }
#                      },
#            'subtype' => 'users_cnt_mibhost',
#            'include' => 1,
#            'lapse' => '300',
#            'type' => 'snmp',
#            'descr' => 'NUMERO DE USUARIOS'

            my $watch=$item->{'IIDS'}->{$iid}->{'watch'};
            my $mname=$item->{'IIDS'}->{$iid}->{'mname'};
            my $label=$item->{'IIDS'}->{$iid}->{'label'};
            $label =~ s/^(.*)\(.*/$1\($host_name\.$domain auto \)/;
            my $status=$item->{'IIDS'}->{$iid}->{'status'};


         	$self->log('debug',"clone_template_metrics:: xagent [$id_dev_src >> $id_dev] SE METE EN PLANTILLA iid=$iid $subtype ($descr)...");
            push (@prov_template_metrics, { 'type' => 'xagent', 'subtype' => $subtype, 'watch' => $watch, 'iid' => $iid, 'mname' => $mname, 'label' => $label, 'lapse' => $lapse, 'status' => $status } );
         }#iids
     }#Bucle de metricas Xagent


print "----------------------------------------------------------------------\n";
print Dumper(\@prov_default_metrics);
print "----------------------------------------------------------------------\n";

      #-------------------------------------------------------------------------------
      # REMOTE_ALERTS
      #-------------------------------------------------------------------------------
		foreach my $ra (@$rREMOTE_ALERTS) {
			my %d=('target'=>$host_ip, 'id_remote_alert'=>0);
			$d{'id_remote_alert'} = $ra->[0];
         $STORE->insert_to_db($dbh,'cfg_remote_alerts2device',\%d);
		}

      my $tot_asistente = scalar(@prov_default_metrics);
      my $tot_plantilla = scalar(@prov_template_metrics);
      my $tot_remote = scalar(@$rREMOTE_ALERTS);
      $self->log('debug',"clone_template_metrics:: [$id_dev_src >> $id_dev] ASISTENTE=$tot_asistente PLANTILLA=$tot_plantilla REMOTE=$tot_remote");
	
   	#-------------------------------------------------------------------------------
		# SE REGENERA EL ASISTENTE DEL id_dev destino
   	#-------------------------------------------------------------------------------
		#$self->prov_device_app_metrics($id_dev);	

   	#-------------------------------------------------------------------------------
		# SE ELIMINA PLANTILLA Y METRICAS EN CURSO Y POSTERIORMENTE SE GENERA LA NUEVA PLANTILLA
   	#-------------------------------------------------------------------------------
   	# Elimino plantilla actual
   	# delete from prov_template_metrics2iid where id_dev=242
   	# delete from prov_template_metrics where id_dev=242
	   $STORE->delete_from_db($dbh,'prov_template_metrics2iid',"id_dev=$id_dev");
   	$STORE->delete_from_db($dbh,'prov_template_metrics',"id_dev=$id_dev");

   	# Elimino metrcas en curso
   	#$STORE->delete_metrics($dbh, {id_dev=>$id_dev});

   	#-------------------------------------------------------------------------------
   	$STORE->db_cmd_fast($dbh,\@prov_default_metrics,'INSERT IGNORE INTO prov_default_metrics2device (id_dev,type,subtype,descr,lapse,include) VALUES (?,?,?,?,?,?)');
   	$STORE->store_template_metrics($dbh,$id_dev,\@prov_template_metrics);
   	#-------------------------------------------------------------------------------
		#$self->prov_do_set_device_metric({'id_dev'=>$id_dev, 'init'=>0});
   	#-------------------------------------------------------------------------------


   }#Bucle de dispositivos destino

}

# ------------------------------------------------------------------------
#  clone_background_and_position
#  Instancia las metricas del asistenete para un dispositivo concreto (id_dev)
#  Provisiona las aplicaciones soportadas por dicho dispositivo
#~ Rquiere que esten rellenos los vectores de metricas
#-------------------------------------------------------------------------------
sub clone_background_and_position {
my ($self,$params)=@_;

   my $id_dev_src=$params->{'id_dev_src'};
   my $id_dev_dst=$params->{'id_dev_dst'};

   my $STORE=$self->istore();
   my $dbh=$self->dbh();

	my $res=$STORE->get_device($dbh,{'id_dev'=>$id_dev_src},'background');
	my $background=$res->[0][0];

	$STORE->update_db($dbh,'devices',{'background'=>$background},"id_dev=$id_dev_dst");

#	$STORE->store_device($dbh, {'ip'=>$ip, 'host_idx'=>$host_idx, 'background'=>$background});

	$res=$STORE->get_from_db( $dbh, 'name,host_idx,graph,size', 'metrics', "id_dev=$id_dev_src", '');
	foreach my $m (@$res) {
		my ($name,$host_idx,$graph,$size) = ($m->[0], $m->[1], $m->[2], $m->[3]);

#    name: disk_mibhost-10
#  id_dev: 1
#host_idx: 1
#   graph: 50000050
#    size: icon

		$self->log('debug',"clone_background_and_position::[INFO] id_dev_dst=$id_dev_dst name=$name >> graph=$graph size=$size");
		$STORE->update_db($dbh,'metrics',{'graph'=>$graph, 'size'=>$size},"id_dev=$id_dev_dst && name=\"$name\" && host_idx=$host_idx");
	}

}


# ------------------------------------------------------------------------
#  prov_device_app_metrics
#	Instancia las metricas del asistenete para un dispositivo concreto (id_dev)
#  Provisiona las aplicaciones soportadas por dicho dispositivo
#~	Rquiere que esten rellenos los vectores de metricas
#-------------------------------------------------------------------------------
sub prov_device_app_metrics {
my ($self,$id_dev)=@_;


   my $STORE=$self->istore();
   my $dbh=$self->dbh();
   my $rcfgbase=$self->cfg();

   #my $SNMP=$self->snmp();
   my $XAGENT=$self->xagent();

   my $rres=$STORE->get_from_db( $dbh, 'ip,version,community,enterprise,name,entity', 'devices', "id_dev=$id_dev", 'order by id_dev');
   my $host_ip=$rres->[0][0];
   my $host_name=$rres->[0][4];
   my $version=$rres->[0][1];
   my $community=$rres->[0][2];
   my $entity=$rres->[0][5];
	$self->log('info',"prov_device_app_metrics::[INFO] ++++>>> PROCESANDO ID_DEV=$id_dev host_ip=$host_ip entity=$entity");
   my @ents = split (',', $rres->[0][3]);
   my @ENT=(0, @ents);

   $STORE->delete_from_db( $dbh,'prov_default_metrics2device',"id_dev=$id_dev");
   $STORE->delete_from_db( $dbh,'prov_default_apps2device',"id_dev=$id_dev");

	my $PORTS=[];
	if ($entity == 0) {	
   	$PORTS=$self->check_tcp_ports($host_ip,{});
	}
	$self->log('info',"prov_device_app_metrics::[INFO] ++++>>> PROCESANDO ID_DEV=$id_dev ENT=@ENT PORTS=@$PORTS");


#   while (my ($k,$v)=each %ProvisionLite::LATENCY_CHECK_VECTOR) {
#      if ($k !~ /\d+/) { next; }
#      if ($k==0) { $ProvisionLite::LATENCY_CHECK_VECTOR{$k}=1; next; }
#      foreach my $p (@$PORTS) {
#         if ($p == $k) { $ProvisionLite::LATENCY_CHECK_VECTOR{$k}=1; last; }
#      }
#   }


   #----------------------------------------------------------------------------------------
   # SNMP
   #----------------------------------------------------------------------------------------
	$self->prov_device_app_metrics_snmp(\@ENT, {'id_dev'=>$id_dev, 'ip'=>$host_ip, 'name'=>$host_name, 'version'=>$version, 'community'=>$community, 'entity'=>$entity});

   #----------------------------------------------------------------------------------------
   # LATENCY
   #----------------------------------------------------------------------------------------
	$self->prov_device_app_metrics_latency($PORTS, {'id_dev'=>$id_dev, 'ip'=>$host_ip, 'name'=>$host_name, 'entity'=>$entity} );

   #----------------------------------------------------------------------------------------
   # XAGENT
   #----------------------------------------------------------------------------------------
   $self->prov_device_app_metrics_xagent($PORTS, {'id_dev'=>$id_dev, 'ip'=>$host_ip, 'name'=>$host_name, 'entity'=>$entity} );

   #----------------------------------------------------------------------------------------
   # REMOTE ALERTS
   #----------------------------------------------------------------------------------------
   $self->prov_device_remote_alerts_snmp(\@ENT, {'id_dev'=>$id_dev, 'ip'=>$host_ip, 'name'=>$host_name, 'version'=>$version, 'community'=>$community, 'entity'=>$entity});

   #----------------------------------------------------------------------------------------
   # LOCAL SCRIPTS FOR METRICS, APPS or REMOTE PROVISIONING
   #----------------------------------------------------------------------------------------
   my $CNM_LOCAL_DIR='/opt/cnm.local';

   local %ENV=();
   $ENV{'CNM_DEVICE_IP'} = $host_ip;
   $ENV{'CNM_DEVICE_ID_DEV'} = $id_dev;
   $ENV{'CNM_HOST_NAME'} = $host_name;

   my $post_cfg_device_metrics_script=$CNM_LOCAL_DIR.'/post_cfg_device_metrics';
   if (-f $post_cfg_device_metrics_script) {
      my $rc=system($post_cfg_device_metrics_script);
      if (($rc==0) || (($rc==-1) && ($SIG{CHLD} eq 'IGNORE')) ) {
         $self->log('info',"prov_device_app_metrics:: EXEC LOCAL $post_cfg_device_metrics_script $host_ip|$id_dev|$host_name [rc=$rc]");
      }
      else {
         $self->log('warning',"prov_device_app_metrics:: **ERROR** EXEC LOCAL $post_cfg_device_metrics_script $host_ip|$id_dev|$host_name [rc=$rc] ($!)");
      }
   }
   my $post_cfg_device_apps_script=$CNM_LOCAL_DIR.'/post_cfg_device_apps';
   if (-f $post_cfg_device_apps_script) {
      my $rc=system($post_cfg_device_apps_script);
      if (($rc==0) || (($rc==-1) && ($SIG{CHLD} eq 'IGNORE')) ) {
         $self->log('info',"prov_device_app_metrics:: EXEC LOCAL $post_cfg_device_apps_script $host_ip|$id_dev|$host_name [rc=$rc]");
      }
      else {
         $self->log('warning',"prov_device_app_metrics:: **ERROR** EXEC LOCAL $post_cfg_device_apps_script $host_ip|$id_dev|$host_name [rc=$rc] ($!)");
      }
   }
   my $post_cfg_device_remote_alerts_script=$CNM_LOCAL_DIR.'/post_cfg_device_remote_alerts';
   if (-f $post_cfg_device_remote_alerts_script) {
      my $rc=system($post_cfg_device_remote_alerts_script);
      if (($rc==0) || (($rc==-1) && ($SIG{CHLD} eq 'IGNORE')) ) {
         $self->log('info',"prov_device_app_metrics:: EXEC LOCAL $post_cfg_device_remote_alerts_script $host_ip|$id_dev|$host_name [rc=$rc]");
      }
      else {
         $self->log('warning',"prov_device_app_metrics:: **ERROR** EXEC LOCAL ($SIG{CHLD}) $post_cfg_device_remote_alerts_script $host_ip|$id_dev|$host_name [rc=$rc] ($!)");
      }
   }

}


#-------------------------------------------------------------------------------
sub prov_device_remote_alerts_snmp {
my ($self,$enterprise_list,$rparams)=@_;

	#Para servicios web no se provisionan alertas basadas en traps
	if ($rparams->{'entity'} == 1) { return; }

   my $STORE=$self->istore();
   my $dbh=$self->dbh();
   $STORE->dbh($dbh);
   my $rcfgbase=$self->cfg();

$self->log('info',"prov_device_remote_alerts_snmp:: COMPRUEBO ENTERPRISES >> @$enterprise_list");

   foreach my $e (@$enterprise_list) {

		# Solo contemplo enterprises decimales y >0
		my $range='unk';
		if ($e==0) { next; }
		elsif ($e=~/^\d+$/) { $range='ent.'.$e; }
		else { next; }

		$self->log('info',"prov_device_remote_alerts_snmp:: COMPRUEBO ENTERPRISE = $e range=$range");
		if (exists $ProvisionLite::SNMP_REMOTE_CHECK_VECTOR{$range}) {
			foreach my $h (@{$ProvisionLite::SNMP_REMOTE_CHECK_VECTOR{$range}}) { 
				my %data=('target'=>$rparams->{'ip'}, 'id_remote_alert'=>$h->{'id_remote_alert'});
				$STORE->insert_to_db($dbh,'cfg_remote_alerts2device',\%data);
				$ProvisionLite::NUM_REMOTE_ALERTS_ASSIGNED+=1;
				$self->log('info',"prov_device_remote_alerts_snmp:: MAPEO $data{'target'} -> $data{'id_remote_alert'}");
      	}
   	}
	}
}


# ------------------------------------------------------------------------
#  prov_device_app_metrics_snmp
#  Instancia las metricas del asistenete para un dispositivo concreto (id_dev)
#  Provisiona las aplicaciones soportadas por dicho dispositivo
#~ Rquiere que esten rellenos los vectores de metricas
#-------------------------------------------------------------------------------
sub prov_device_app_metrics_snmp {
my ($self,$enterprise_list,$rparams)=@_;

   #Para servicios web no se provisionan alertas basadas en traps
   if ($rparams->{'entity'} == 1) { return; }

   my $STORE=$self->istore();
   my $dbh=$self->dbh();
	$STORE->dbh($dbh);
   my $rcfgbase=$self->cfg();

   my $SNMP=$self->snmp();

   my %SNMPCFG = ();
   my $id_dev=$rparams->{'id_dev'};
   $SNMPCFG{'host_ip'}=$rparams->{'ip'};
   $SNMPCFG{'host_name'}=$rparams->{'name'};
   $SNMPCFG{'version'}=$rparams->{'version'};
   $SNMPCFG{'community'}=$rparams->{'community'};

	
   if ($SNMPCFG{'version'} == 3) {

      my $rres=$STORE->get_from_db( $dbh, 'sec_name,sec_level,auth_proto,auth_pass,priv_proto,priv_pass', 'profiles_snmpv3', "id_profile=$SNMPCFG{'community'}");

      $SNMPCFG{'sec_name'}=$rres->[0][0];
      $SNMPCFG{'sec_level'}=$rres->[0][1];
      $SNMPCFG{'auth_proto'}=$rres->[0][2];
      $SNMPCFG{'auth_pass'}=$rres->[0][3];
      $SNMPCFG{'priv_proto'}=$rres->[0][4];
      $SNMPCFG{'priv_pass'}=$rres->[0][5];
   }

   if ($SNMPCFG{'version'} !~ /\d+/) {
		$self->log('warning',"prov_device_app_metrics_snmp::[WARN] Version SNMP Incorrecta ($SNMPCFG{'version'}) de $SNMPCFG{'host_ip'} ID_DEV=$id_dev");
		return;
	}

   #Valido si el dispositivo responde por SNMP
	if ( $ProvisionLite::NO_SNMP_RESPONSE ) {
      $self->log('warning',"prov_device_app_metrics_snmp::[WARN] Sin respuesta SNMP (previa) IP=$SNMPCFG{'host_ip'} ID_DEV=$id_dev C=$SNMPCFG{'community'} V=$SNMPCFG{'version'}");
      return;
	}

   my ($rc, $rcstr, $res) = (0,'','');
	if ($ProvisionLite::SNMP_FORCED==0) { ($rc, $rcstr, $res)=$SNMP->verify_snmp_data(\%SNMPCFG); }
   if ($rc !=  0) {
		$self->log('warning',"prov_device_app_metrics_snmp::[WARN] Sin respuesta SNMP IP=$SNMPCFG{'host_ip'} ID_DEV=$id_dev C=$SNMPCFG{'community'} V=$SNMPCFG{'version'}");
		return;
	}

   foreach my $e (@$enterprise_list) {

print "snmp>>>>>>>>>>>>>>COMPRUEBO ENTERPRISE = $e\n";
      my $check_vector=$ProvisionLite::SNMP_CHECK_VECTOR{$e};
      if (! defined $check_vector) { next; }

		my $timeout_max=30;
      my $COLMAP=$SNMP->snmp_check_table_cols(\%SNMPCFG, $check_vector, $timeout_max);

#foreach my $b (@$kk) {
#  my @ke=keys(%$b);
#  my $v=$ke[0];
#  my @gg=keys(%{$b->{$v}});
#print "****FML***@gg\n";
#}
#print "-------COLMAP---------\n";
#print Dumper($COLMAP);
print "--------------SNMP_CHECK_VECTOR---------------\n";
print Dumper($check_vector);

      while (my ($k,$v)=each %$check_vector) {
         #print "++++ID_DEV=$id_dev\t$k == $v\n";
         # Si el range buscado (en este caso la MIB) esta asoportada
         # se provisionan las aplicaciones y metricas correspondientes
         if ($v) {
				# Aplicaciones
            foreach my $h (@{$ProvisionLite::APPS2DEVICE{$k}}) {
					my ($id,$aname)=($h->{'id'}, $h->{'aname'});
print "------------------------------ SOPORTA_APP (RANGE=$k) ---------------------------\n";
					$self->log('info',"prov_device_app_metrics_snmp::[DEBUG] +++SNMP APP: ID_DEV=$id_dev RANGE=$k ID=$id ANAME=$aname");
               my %prov_data=( 'id_dev'=>$id_dev, 'id_monitor_app'=> $id);
               $STORE->insert_to_db($dbh,'prov_default_apps2device',\%prov_data);

               my %cfg_app_data=( 'aname'=>$aname, 'ip'=> $rparams->{'ip'}, 'id_dev'=>$id_dev, 'who'=>0);
               $STORE->insert_to_db($dbh,'cfg_app2device',\%cfg_app_data);
            }

				# Metricas
            foreach my $id (@{$ProvisionLite::METRICS2DEVICE{$k}}) {

               my ($type, $subtype, $enterprise, $descr, $lapse, $include,$oidn, $cfg)=($id->{'type'}, $id->{'subtype'}, $id->{'enterprise'}, $id->{'descr'}, $id->{'lapse'}, $id->{'include'}, $id->{'oidn'}, $id->{'cfg'} );

					my ($n1,$n2)=(0,1);

#               # Una vez que responde a la MIB hay que ver que tambien responde a todos los oids involucrados en la metrica
#               my @vals=split(/\|/,$oidn);
#               my @newvals = ();
#               foreach my $l (@vals) {
#                  $l=~s/\.IID//;
#                  push @newvals,$l;
#               }
#               my $n1=scalar @newvals;
#               my $n2=0;
#               foreach my $k1 (@newvals) {
#                  if (exists $COLMAP->{$k}->{$k1}) { $n2++; }
#               }

print "------------------------------ VALIDO_METRICA ($cfg) $subtype ---------------------------\n";
					if ($cfg==1) { $n1=$n2; }
					elsif ($cfg==2) {

	               # Una vez que responde a la MIB hay que ver que tambien responde a todos los oids involucrados en la metrica
   	            my @vals=split(/\|/,$oidn);
      	         my @newvals = ();
         	      foreach my $l (@vals) {
            	      $l=~s/\.IID//;
               	   push @newvals,$l;
               	}
	               $n1=scalar @newvals;
   	            $n2=0;
      	         foreach my $k1_full (@newvals) {
							# Si los valores estan especificados con full oid, quito la parte de la MIB
							my $k1 = $k1_full;
							if ($k1 =~ /^\S+\:\:(\S+)$/) { $k1 = $1; }
							$self->log('debug',"prov_device_app_metrics_snmp::[DEBUG] SNMP CFG=2 $subtype CHEQUEO COLUMNA $k1");
         	         if (exists $COLMAP->{$k}->{$k1}) {
								$self->log('debug',"prov_device_app_metrics_snmp::[DEBUG] SNMP CFG=2 $subtype EXISTE COLUMNA $k1");
								$n2++;
							}
            	   }
					}
					elsif ($cfg==3) {
						my @RESULTS=();
						$SNMP->chk_metric( {id_dev => $id_dev, host_ip=>$SNMPCFG{'host_ip'}, host_name=>$SNMPCFG{'host_name'}, mname=>$subtype }, \@RESULTS, $STORE );

						# -------------------------------------------------
						#RESULTS es del tipo:
						#								[0]						[1]
						#@{$RESULTS[0]} >> Metrica (GAUGE): 		USO DE CPU ()
						#@{$RESULTS[1]} >> Valores monitorizados: items_fx(cpu)
						#@{$RESULTS[2]} >> Valores monitorizados: hrProcessorLoad.x
						#@{$RESULTS[3]} >> fx: 
						#@{$RESULTS[4]} >> Datos dispositivo: 		1
						# -------------------------------------------------

						# El el caso de num. procesos solo si el valor obtenido es distinto de 0 considero que 
						# si responde a la metrica. En otros casos no es asi

						chomp $RESULTS[4][1];
						my $result = $RESULTS[4][1];
						if ($k eq 'HOST-RESOURCES-MIB::hrSWRunPerfTable') {
							if ( ($result=~/\d+/) && ($result>0) ) {	
								$n1=$result;
								$n2=$result;
							}
						}
						else {
						   if ($result=~/\d+/)  {
							   $n1=$result;
								$n2=$result;
							}
						}
					}
					else {
						$self->log('debug',"prov_device_app_metrics_snmp::[DEBUG] ---SNMP MET: SIN VALIDAR $subtype POR CFG=$cfg ID_DEV=$id_dev RANGE=$k (N1=$n1 N2=$n2)");
					}

               # Si coinciden los contadores, responde a todos los valores de la tabla
               if ($n1==$n2) {
						$self->log('info',"prov_device_app_metrics_snmp::[DEBUG] +++SNMP MET: CHECK_OK $subtype ID_DEV=$id_dev lapse=$lapse RANGE=$k (N1=$n1 N2=$n2)");
                  my %prov_data=( 'id_dev'=>$id_dev, 'type'=> $type, 'subtype'=>$subtype, 'descr'=>$descr, 'lapse'=>$lapse, 'include'=>$include );
                  $STORE->insert_to_db($dbh,'prov_default_metrics2device',\%prov_data);
               }
               else {
						$self->log('info',"prov_device_app_metrics_snmp::[DEBUG] ---SNMP MET: CHECK_NOK $subtype ID_DEV=$id_dev lapse=$lapse RANGE=$k (N1=$n1 N2=$n2)");
					}
            }
         }
      }
   }

#cfg=3
#        $SNMP->chk_metric( {id_dev => $id_dev, id_metric => $id_metric, host_ip=>$ip, mname=>$mname}, \@RESULTS );

}


# ------------------------------------------------------------------------
#  prov_device_app_metrics_xagent
#  Instancia las metricas del asistenete para un dispositivo concreto (id_dev)
#  Provisiona las aplicaciones soportadas por dicho dispositivo
#  Requiere que esten rellenos los vectores de metricas
#-------------------------------------------------------------------------------
sub prov_device_app_metrics_xagent {
my ($self,$port_list, $rparams)=@_;

   my $STORE=$self->istore();
   my $dbh=$self->dbh();
   my $rcfgbase=$self->cfg();

   my $XAGENT=$self->xagent();
	my $timeout=60;
	$XAGENT->timeout($timeout);

   my $id_dev=$rparams->{'id_dev'};
   my $host_ip=$rparams->{'ip'};
   my ($ok_icmp,$mac)=$self->check_icmp($host_ip);

	my $credentials = $STORE->get_device_credentials($dbh,{'ip'=>$host_ip});	

	# Si es un servicio web adapto la IP
	if ($rparams->{'entity'} == 1) { $host_ip=~s/^(\d+\.\d+\.\d+\.\d+)\-\w+$/$1/; }


   # Hago el check del vector. Pongo a 1 en valor de las claves que corresponda
   while (my ($range,$response)=each %ProvisionLite::XAGENT_CHECK_VECTOR) {

      # Si range es cnm, son aplicaciones propias de cnm que no tiene sentido asociar a dispositivo
      if ($range eq 'cnm') { next; }

		my %exec_vector=('file_script'=>'', 'params'=>'', 'proxy_type'=>'', 'proxy_user'=>'root', 'proxy_pwd'=>'',  'proxy_passphrase'=>'', 'proxy_host'=>'localhost', 'proxy_port'=>'', 'task_id'=>'', 'timeout'=>$timeout);

#		range debe ser del tipo: script, parametros
#		vmware-check,[-n;IP;;2]:[-u;Usuario;$sec.vmware.user;1]:[-p;Clave;$sec.vmware.pwd;1]
#		La ruta del script es: /opt/cnm-sp/_check/vmware-check
		my ($basename,$params)=split(',',$range);

		if ($basename =~ /\//) { $exec_vector{'file_script'} = $basename; }
		else {
			$exec_vector{'file_script'} = '/opt/cnm-sp/_check/'.$basename;
		}

		if (! -f $exec_vector{'file_script'}) {
			$self->log('warning',"prov_device_app_metrics_xagent::[WARN] **NO EXISTE FICHERO** VALIDATE $exec_vector{'file_script'} (range=$range)");
			next;
		}
		else {
			$self->log('info',"prov_device_app_metrics_xagent::[WARN] VALIDATE $exec_vector{'file_script'} (range=$range)");
		}

		$exec_vector{'params'} = $XAGENT->_compose_params($params,$host_ip,$credentials);
		$exec_vector{'host_ip'} = $host_ip;

		# Si hay credenciales no resueltas no tiene sentido hacer el chequeo.
		if ($exec_vector{'params'} =~ /\$sec/) {
			$self->log('info',"prov_device_app_metrics_xagent:: SIN CREDENCIALES SALTO $exec_vector{'file_script'} $exec_vector{'params'}");
			next;
		}

		$XAGENT->exec_vector(\%exec_vector);


      # ip_script_md5(params)_tag
      #10.2.254.222-_check_icmp_dul-76e3f849
      $exec_vector{'task_id'} = $host_ip.'-'.$basename.'-'.substr(md5_hex($exec_vector{'params'}),0,8);

		my $out_cmd=$XAGENT->execScript();

		if ((exists $out_cmd->[0]) && ($out_cmd->[0]=~/^\d+$/)) { 
			$ProvisionLite::XAGENT_CHECK_VECTOR{$range} = $out_cmd->[0]; 
		}
	
   }

print "--------------XAGENT_CHECK_VECTOR---------------\n";
print Dumper(\%ProvisionLite::XAGENT_CHECK_VECTOR);

	my $ok;	
	($dbh,$ok)=$self->chk_conex($dbh,$STORE,'devices');

   while (my ($k,$v)=each %ProvisionLite::XAGENT_CHECK_VECTOR) {
      #print "++++ID_DEV=$id_dev\t$k == $v\n";
      if (! $v) { next; }


      foreach my $id (@{$ProvisionLite::METRICS2DEVICE{$k}}) {

         my ($type, $subtype, $descr, $lapse, $include)=($id->{'type'}, $id->{'subtype'}, $id->{'descr'}, $id->{'lapse'}, $id->{'include'});

         $self->log('info',"prov_device_app_metrics_xagent::[DEBUG] +++XAGENT MET: CHECK_OK $subtype ID_DEV=$id_dev lapse=$lapse [$descr] RANGE=$k");
         my %prov_data=( 'id_dev'=>$id_dev, 'type'=> $type, 'subtype'=>$subtype, 'descr'=>$descr, 'lapse'=>$lapse, 'include'=>$include);
         $STORE->insert_to_db($dbh,'prov_default_metrics2device',\%prov_data);
      }

      foreach my $h (@{$ProvisionLite::APPS2DEVICE{$k}}) {

         my ($id,$aname,$script)=($h->{'id'}, $h->{'aname'},$h->{'script'});

         $self->log('info',"prov_device_app_metrics_xagent::[DEBUG] +++XAGENT APP: ID_DEV=$id_dev RANGE=$k ID=$id ANAME=$aname script=$script");

         my %prov_data=( 'id_dev'=>$id_dev, 'id_monitor_app'=> $id);
         $STORE->insert_to_db($dbh,'prov_default_apps2device',\%prov_data);

         my %cfg_app_data=( 'aname'=>$aname, 'ip'=> $rparams->{'ip'}, 'id_dev'=>$id_dev, 'who'=>0);
         $STORE->insert_to_db($dbh,'cfg_app2device',\%cfg_app_data);
      }
   }
}

# ------------------------------------------------------------------------
#  prov_device_app_metrics_latency
#  Instancia las metricas del asistenete para un dispositivo concreto (id_dev)
#  Provisiona las aplicaciones soportadas por dicho dispositivo
#~ Rquiere que esten rellenos los vectores de metricas
#-------------------------------------------------------------------------------
sub prov_device_app_metrics_latency {
my ($self,$port_list, $rparams)=@_;

   #Para servicios web no se provisionan alertas basadas en traps
   if ($rparams->{'entity'} == 1) { return; }

   my $STORE=$self->istore();
   my $dbh=$self->dbh();
   my $rcfgbase=$self->cfg();

   my $LATENCY=$self->latency();

   my $id_dev=$rparams->{'id_dev'};
   my $host_ip=$rparams->{'ip'};
	my ($ok_icmp,$mac)=$self->check_icmp($host_ip);


	# Hago el check del vector. Pongo a 1 en valor de las claves que corresponda
   while (my ($k,$v)=each %ProvisionLite::LATENCY_CHECK_VECTOR) {

print "*****K=$k\n";

      # ---------------------------------------------
      # Aplicaciones
      # ---------------------------------------------
		if (	($k =~ /bin\/ping/) || ($k =~ /bin\/traceroute/) || ($k =~ /bin\/nmap/) || ($k =~ /libexec\/mon_tcp/) ||
				($k =~ /libexec\/mon_smtp/) || ($k =~ /libexec\/mon_ssh/)	) {
			$ProvisionLite::LATENCY_CHECK_VECTOR{$k}=1;
			next;
		}

		# ---------------------------------------------
		# Metricas
		# ---------------------------------------------
		if (($k =~ /icmp/) && ($ok_icmp)) {
			$ProvisionLite::LATENCY_CHECK_VECTOR{$k}=1;
#			if (($k eq 'mon_icmp') || ($k eq 'disp_icmp') ) {  $ProvisionLite::LATENCY_CHECK_VECTOR{$k}=1; }
#			else {  $ProvisionLite::LATENCY_CHECK_VECTOR{$k}=0; }
		}
		else {
      	my @RESULTS=();
			if (! exists $ProvisionLite::METRICS2DEVICE{$k}->[0]) { next; }
			my $id=$ProvisionLite::METRICS2DEVICE{$k}->[0];
         my ($type, $subtype, $descr, $lapse, $include, $port)=($id->{'type'}, $id->{'subtype'}, $id->{'descr'}, $id->{'lapse'}, $id->{'include'}, $id->{'port'});

			# Si responde al puerto, chequeo la posible metrica
			my $port_close=1;
			foreach my $p (@$port_list) {
			#print "-------($p)----($port)-----$k---\n";
				if ($p == $port) { $port_close=0; }
			}
			if ($port_close) { next;}

			# Si es una metrica tcp, como ya se que responde al puerto, la doy por buena
			if ($k =~ /mon_tcp/) { $ProvisionLite::LATENCY_CHECK_VECTOR{$k}=1; }
			# Si es una metrica http, antes de chequearla, miro si la url corresponde al host
			# en cuestion. Si no corresponde, ya la doy por mala
			elsif ($k =~ /mon_http/) {
				# Las metricas http no se pueden detectar de forma automatica porque lo que se chequea
				# es una URL que en muchos casos no se puede vincular directamente a un host (IPs virtuales ...)
				$ProvisionLite::LATENCY_CHECK_VECTOR{$k}=0;
			}
			else {
	         $LATENCY->chk_metric( {id_dev => $id_dev, host_ip=>$host_ip, mname=>$subtype}, \@RESULTS, $STORE );
   	      # Si el valor obtenido es distinto de 0. Considero que si responde a la metrica.
				chomp $RESULTS[3][1];
				#Resultado: 0.005724   	
				if ($RESULTS[3][1] =~ /\d+/) {
					#print "++++++*******+++++++++++MET =$k >> RES=$RESULTS[3][1]\n";
					$ProvisionLite::LATENCY_CHECK_VECTOR{$k}=1;
				}
			}
		}
	}

print "--------------LATENCY_CHECK_VECTOR---------------\n";
print Dumper(\%ProvisionLite::LATENCY_CHECK_VECTOR);
$self->log('debug',"prov_device_app_metrics_latency::[DEBUG] port_list=@$port_list");
   while (my ($k,$v)=each %ProvisionLite::LATENCY_CHECK_VECTOR) {
      #print "++++ID_DEV=$id_dev\t$k == $v\n";
      if ($v) {
         foreach my $id (@{$ProvisionLite::METRICS2DEVICE{$k}}) {
		
            my ($type, $subtype, $descr, $lapse, $include, $port)=($id->{'type'}, $id->{'subtype'}, $id->{'descr'}, $id->{'lapse'}, $id->{'include'}, $id->{'port'});

				# A la hora de provisionar el asistente, por defecto las metricas de ping de baja/media prioridad
				# no deben estar chequeadas.
				if ($k =~ /mon_ip_icmp/) { $include=0; }
				$self->log('info',"prov_device_app_metrics_latency::[DEBUG] +++LATENCY MET: CHECK_OK $subtype ID_DEV=$id_dev LATENCY: RANGE=$k");
            my %prov_data=( 'id_dev'=>$id_dev, 'type'=> $type, 'subtype'=>$subtype, 'descr'=>$descr, 'lapse'=>$lapse, 'include'=>$include);
            $STORE->insert_to_db($dbh,'prov_default_metrics2device',\%prov_data);
         }

         foreach my $h (@{$ProvisionLite::APPS2DEVICE{$k}}) {
				my ($id,$aname,$script,$script_port)=($h->{'id'}, $h->{'aname'},$h->{'script'},$h->{'port'});
				# -----------------------------------------------
				if ( ($script eq 'mon_tcp') || ($script eq 'mon_smtp_ext') || ($script eq 'cnm-sslcerts') ) {
         		my $port_in_device=0;

	        		foreach my $p (@$port_list) {
   	        		if ($p == $script_port) { $port_in_device=$p; last; }
					}

					# Si es el caso de mon_tcp generico no salta
         		if (($script_port != 0) && ($port_in_device == 0)) { next;}
				}


				$self->log('info',"prov_device_app_metrics_latency::[DEBUG] +++LATENCY APP: ID_DEV=$id_dev RANGE=$k ID=$id ANAME=$aname script=$script port=$script_port");

            my %prov_data=( 'id_dev'=>$id_dev, 'id_monitor_app'=> $id);
            $STORE->insert_to_db($dbh,'prov_default_apps2device',\%prov_data);

            my %cfg_app_data=( 'aname'=>$aname, 'ip'=> $rparams->{'ip'}, 'id_dev'=>$id_dev, 'who'=>0);
            $STORE->insert_to_db($dbh,'cfg_app2device',\%cfg_app_data);
         }
      }
   }
}


#-------------------------------------------------------------------------------------------
sub check_icmp_base {
my ($self,$host)=@_;

	my $p = Net::Ping->new( "icmp", 1, 64 );
	if ( $p->ping($host) ) { return 1; }
	else {return 0; }
}


#-------------------------------------------------------------------------------------------
sub check_tcp_ports_base {
my ($self,$host,$other)=@_;

	my @open_ports=();
	my $tstart=time;

   my $np = new Nmap::Parser;
	my @ports=(1..1024);
   $np->parsescan('/usr/bin/sudo /usr/bin/nmap','-sS -p 1-1024',$host);
	my $nphost=$np->get_host($host);


	for my $port (@ports) {

   	my $state=$nphost->tcp_port_state($port);

		if ((! defined $state) || ($state ne 'open')) { next; }
		$self->log('debug',"check_tcp_ports_base:: host=$host ***> port=$port state=$state");	


	   my $sock = IO::Socket::INET->new( PeerAddr => $host, PeerPort => $port, Timeout => 1, Proto => 'tcp');
   	my $error;
   	if ($sock) {
			push @open_ports, $port;
			$self->log('debug',"check_tcp_ports_base:: host=$host port=$port OK ($sock)");
   	}
   	elsif ($@ =~ /Connection refused/) {
			#$self->log('debug',"check_tcp_ports_base:: host=$host port=$port ERROR ($@)");
      	$error=1;
   	}
   	elsif ($@ =~ /No route to host/) {
			$self->log('debug',"check_tcp_ports_base:: Sin conectividad con $host ($@)");
			last;
      	$error=-1;
   	}
		#IO::Socket::INET: connect: timeout
      elsif ($@ =~ /timeout/) {
         $self->log('debug',"check_tcp_ports_base:: host=$host port=$port ($@)");
         $error=2;
			# Si las conexiones vencen por timeout, me puedo eternizar (1024*1sg=1024segs.)
			# Si llevo mas de 25 segs en el bucle termino
			if ((time - $tstart) > 120) {last; }
      }

		else {
			$self->log('info',"check_tcp_ports_base:: RESTO host=$host port=$port RESPUESTA NO CONTEMPLADA ($@)");
		}
	}
	return \@open_ports;

}

#-------------------------------------------------------------------------------------------
sub check_udp_ports_base {
my ($self,$host_ip,$ports)=@_;

	my @open_ports=();
	my $icmp_timeout=5; # Tiempo de espera del paquete  icmp "destination unreachable"
	my $icmp_sock = new IO::Socket::INET(Proto=>"icmp");
	my $read_set = new IO::Select();
	$read_set->add($icmp_sock);

	#Recorro los puertos solicitados
	foreach my $i (@$ports) {
    
		my $sock = new IO::Socket::INET(PeerAddr=>$host_ip, PeerPort=>$i, Proto=>"udp");
    	# Envio el paquete UDP
    	my $buf=sprintf("%05d",$i);
    	$sock->send("$buf");
    	close($sock);

    	# Espero los paquetes icmp
    	my ($new_readable) = IO::Select->select($read_set, undef, undef, $icmp_timeout);
    	my $icmp_arrived = 0;
    	foreach my $socket (@$new_readable) {
         # Si tengo un paquete en el spcket icmp asumo que es "destination unreachable"
         if ($socket == $icmp_sock) {
              $icmp_arrived = 1;
              $icmp_sock->recv($buf,50,0);
         }
    	}
    	if ( $icmp_arrived == 0 ) { push @open_ports, $i; }
	}
	close($icmp_sock);
	return \@open_ports;
}


#-------------------------------------------------------------------------------------------
sub check_tcp_ports {
my ($self,$host,$other)=@_;

   my @open_ports=();
#	if (defined $other) {
#		$other->{'name'}=''; $other->{'ip'}=''; 	
#	}
	$self->log('info',"check_tcp_ports::1-9...");
   my @lines=`/usr/bin/sudo /usr/bin/nmap -sS -T2 -P0 -p 1-9 $host`;
	my $filtered=0;
   foreach my $l (@lines) {
		chomp($l);
      #22/tcp  open  ssh
      if ($l =~ /(\d+)\/tcp\s+open/) { push @open_ports, $1; }
      if ($l =~ /(\d+)\/tcp\s+filtered/) { $filtered+=1; }
		#Interesting ports on 10.2.84.161:
		#Interesting ports on software.s30labs.com (213.186.47.112):
      elsif ($l =~ /Interesting ports on\s+(\S+)\s+\((\d+\.\d+\.\d+\.\d+)\)/) { $other->{'name'}=$1; $other->{'ip'}=$2;  }
      elsif ($l =~ /Interesting ports on\s+(\d+\.\d+\.\d+\.\d+)/) { $other->{'ip'}=$1;  }
   }

	if ($filtered==9) {
		$self->log('info',"check_tcp_ports:: Termino, los puertos estan filtrados...");
		return \@open_ports;
	}
	#Se parte en dos tramos porque si todos los puertos estan filtrados tarda mas de 100 segs.
   $self->log('info',"check_tcp_ports::10-1024...");
   @lines=`/usr/bin/sudo /usr/bin/nmap -sS -T2 -P0 -p 10-1024 --host-timeout 60s $host`;

   foreach my $l (@lines) {
      chomp($l);
      #22/tcp  open  ssh
      if ($l =~ /(\d+)\/tcp\s+open/) { push @open_ports, $1; }
      #Interesting ports on 10.2.84.161:
      #Interesting ports on software.s30labs.com (213.186.47.112):
      elsif ($l =~ /Interesting ports on\s+(\S+)\s+\((\d+\.\d+\.\d+\.\d+)\)/) { $other->{'name'}=$1; $other->{'ip'}=$2;  }
      elsif ($l =~ /Interesting ports on\s+(\d+\.\d+\.\d+\.\d+)/) { $other->{'ip'}=$1;  }
   }

   return \@open_ports;
}


#-------------------------------------------------------------------------------------------
#Solo se chequean puertos muy especificos
sub check_udp_ports {
my ($self,$host,$other)=@_;

   my @open_ports=();
#   if (defined $other) {
#      $other->{'name'}=''; $other->{'ip'}='';
#   }
$self->log('debug',"check_udp_ports::VOY A EJECUTAR /usr/bin/sudo /usr/bin/nmap -sU -p 161,514 $host");
   my @lines=`/usr/bin/sudo /usr/bin/nmap -sU -p 161,514 $host`;
$self->log('debug',"check_udp_ports::EJECUTADO /usr/bin/sudo /usr/bin/nmap -sU -p 161,514 $host");
   foreach my $l (@lines) {
		chomp($l);
		# 161/udp open|filtered snmp
      if ($l =~ /(\d+)\/udp\s+open/) { push @open_ports, $1; }
      #Interesting ports on 10.2.84.161:
      #Interesting ports on software.s30labs.com (213.186.47.112):
      elsif ($l =~ /Interesting ports on\s+(\S+)\s+\((\d+\.\d+\.\d+\.\d+)\)/) { $other->{'name'}=$1; $other->{'ip'}=$2;  }
      elsif ($l =~ /Interesting ports on\s+(\d+\.\d+\.\d+\.\d+)/) { $other->{'ip'}=$1;  }
   }
   return \@open_ports;
}

#-------------------------------------------------------------------------------------------
sub check_icmp_old {
my ($self,$host)=@_;

   my ($ok,$mac)=(0,'');
   my $cmd="/usr/bin/sudo /usr/bin/nmap -sP $host";
   my @lines=`$cmd`;
   foreach my $l (@lines) {
      if ($l =~ /Host \S+ appears to be up/) { $ok=1; }
      elsif ($l =~ /Host \S+ \(\S+\) appears to be up/) { $ok=1; }
      elsif ($l =~ /MAC Address\: (.*)$/) { $mac=$1; }
   }
   return ($ok,$mac);
}

#-------------------------------------------------------------------------------------------
sub check_icmp {
my ($self,$host)=@_;

   my ($ok,$mac)=(0,'');
	my %desc=('host_ip'=>$host);
	my $r=mon_icmp(\%desc);
	if ($r->[0] =~ /OK/) {$ok=1; }
   return ($ok,$mac);
}


#-------------------------------------------------------------------------------------------
# validate_range
# Valida un rango de ip y devuelve un vector con sus valores
# El rango de IPs de entrada se puede especificar de la forma:
# 1. a.b.c.d./r
# 2. a.b.c.x-y
# 3. a.b.c.d
# 4. a.b.c.*	
# 5. a.b.*.*	
# 6. a.*.*.*	LO ELIMINO PORQUE LO DEJA SIN MEMORIA (limite 65535)
#-------------------------------------------------------------------------------------------
sub validate_range {
my ($self,$r1)=@_;
my $range=undef;

	my $input_ranges=$r1;
	my @output_ranges=();
	if (ref($r1) ne "ARRAY") { $input_ranges=[$r1]; }

	foreach my $r (@$input_ranges) {

		$self->log('debug',"validate_range:: ....... RANGO IN=$r");

	   #a.b.c.d./r
   	if ($r=~/^(\d+\.\d+\.\d+\.\d+\/)(\d+)$/) {
			if ($2<12) { $r=$1.12; }
	      my $nip = new NetAddr::IP($r);
			$range = $nip->hostenumref();
   	}
	   #a.b.c.x-y
   	elsif ($r=~/^(\d+\.\d+\.\d+)\.(\d+)\-(\d+)$/) {
      	my $base=$1;
	      my $start=$2;
   	   my $end=$3;
      	my @v=();
	      for my $i ($start..$end){ push @v, "$base.$i\/32"; }
   	   $range=\@v;
   	}
	   #a.b.c.d
   	elsif ($r=~/^\d+\.\d+\.\d+\.\d+$/) {
	      $r.='/32';
      	#$range = new NetAddr::IP($r);
	      my $nip = new NetAddr::IP($r);
   	   $range = $nip->hostenumref();
	   }
   	#a.b.c.*
	   elsif ($r=~/^(\d+\.\d+\.\d+)\.\*$/) {
   	   $r=$1.'.0/24';
      	my $nip = new NetAddr::IP($r);
	      $range = $nip->hostenumref();
   	   #my @v= new NetAddr::IP($r);
#$range=\@v;
   	}
	   #a.b.*.*
   	elsif ($r=~/^(\d+\.\d+)\.\*\.\*$/) {
      	$r=$1.'.0.0/16';
      	my $nip = new NetAddr::IP($r);
      	$range = $nip->hostenumref();
   	}
	   #a.*.*.*
#  	 elsif ($r=~/(\d+)\.\*\.\*\.\*/) {
#	
#			# Una clase A lo deja sin memoria. Habria que partirlo en n clases B
#     	 $r=$1.'.0.0.0/8';
#      	my $nip = new NetAddr::IP($r);
#      	$range = $nip->hostenumref();
#   	}
		else {
			$self->log('info',"validate_range:: **RANGO INCORRECTO** IN=$r");
			next;
		}

		$self->log('debug',"validate_range:: RANGO IN=$r OUT=@$range");

		push @output_ranges, @$range;
	}

   return \@output_ranges;
}



#-------------------------------------------------------------------------------------------
# get_dns_name
#-------------------------------------------------------------------------------------------
sub get_dns_name {
my ($self,$numeric_ip)=@_;

	my $name='-';
	if ($numeric_ip=~/\d+\.\d+\.\d+\.\d+/) {
		$name = gethostbyaddr(inet_aton($numeric_ip), AF_INET);
		if ((! defined $name) || ($name eq '')) { $name='-'; }
	}
	return $name;
}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------
# audit_general
#-------------------------------------------------------------------------------------------
sub audit_general {
my ($self,$range_ip)=@_;

	my @DATA=();
   my @COLUMNS = (
      { 'width'=>'10' , 'name_col'=>'NOMBRE',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
      { 'width'=>'10' , 'name_col'=>'IP',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
      { 'width'=>'10' , 'name_col'=>'PING',  'sort'=>'text', 'align'=>'left', 'filter'=>'#select_filter' },
      { 'width'=>'10' , 'name_col'=>'TCP-PORTS',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
      { 'width'=>'10' , 'name_col'=>'COMMUNITY',  'sort'=>'text', 'align'=>'left', 'filter'=>'#select_filter' },
      { 'width'=>'10' , 'name_col'=>'VERSION',  'sort'=>'text', 'align'=>'left', 'filter'=>'#select_filter' },
      { 'width'=>'10' , 'name_col'=>'SYSOID',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
      { 'width'=>'10' , 'name_col'=>'SYSNAME',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
      { 'width'=>'10' , 'name_col'=>'SYSLOC',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
      { 'width'=>'10' , 'name_col'=>'SYSDESC',  'sort'=>'text', 'align'=>'left', 'filter'=>'#text_filter' },
   );

	my $IPS = $self->validate_range($range_ip);
$self->log('info',"audit_general:: rangos=@$range_ip IPS=$IPS");
	foreach my $host_ip (@$IPS) {
		$host_ip=~s/(\d+\.\d+\.\d+\.\d+)\/32/$1/;
      $self->log('debug',"audit_general::[DEBUG] START IP=$host_ip");

		my $SNMP_VERSION=0;
   	my ($dnsname,$sysname,$ping,$uptime,$community,$oid,$sysoid,$snmp_data,$rc,$rcstr,$res,$sysloc,$sysdesc) =
      	('-'    ,'-'     ,'NO' ,0      ,'-'        ,''  ,'-'     ,'',     ,'0', 'OK',  '' , '-',  '-');

		my %INFO=( 'name'=>'-', 'ip'=>$host_ip );


   	my $PORTS_TCP=$self->check_tcp_ports_base($host_ip,\%INFO);
$self->log('debug',"audit_general::[DEBUG] IP=$host_ip hecho scan tcp");

   	my $PORTS_UDP=$self->check_udp_ports($host_ip,\%INFO);
$self->log('debug',"audit_general::[DEBUG] IP=$host_ip hecho scan udp");
		my $tcp_ports=join(', ',@$PORTS_TCP);


		my $SEPARATOR=',';
		if ((scalar(@$PORTS_TCP)==0) && (scalar(@$PORTS_UDP)==0)) {
			#return join ($SEPARATOR, ($INFO{'name'},$INFO{'ip'},$ping,$snmp_data,$sysoid,$sysname,$sysloc,$sysdesc) );
			push @DATA, [$INFO{'name'},$INFO{'ip'},$ping,$tcp_ports,$community,$SNMP_VERSION,$sysoid,$sysname,$sysloc,$sysdesc];
			$self->log('debug',"audit_general::DEBUG] RES=$INFO{'name'},$INFO{'ip'},$ping,$community,$SNMP_VERSION,$sysoid,$sysname,$sysloc,$sysdesc");
			next;
			#return (\@COLUMNS,\@DATA);
		}

		$ping='SI';
		my $snmp_ok=0;
		foreach my $p (@$PORTS_UDP) {
			if ($p==161) { $snmp_ok=1; last; }
		}

		if (! $snmp_ok) {
			#return join ($SEPARATOR, ($INFO{'name'},$INFO{'ip'},$ping,$snmp_data,$sysoid,$sysname,$sysloc,$sysdesc) );
			push @DATA, [$INFO{'name'},$INFO{'ip'},$ping,$tcp_ports,$community,$SNMP_VERSION,$sysoid,$sysname,$sysloc,$sysdesc];
			$self->log('debug',"audit_general::DEBUG] RES=$INFO{'name'},$INFO{'ip'},$ping,$community,$SNMP_VERSION,$sysoid,$sysname,$sysloc,$sysdesc");
			next;
      	#return (\@COLUMNS,\@DATA);
		}

$self->log('debug',"audit_general::[DEBUG] IP=$host_ip check snmp");
		my $snmp=$self->snmp();
	
   	#---------------------------------------------------
		# debe mapear ip _> todos los parametros que definan la estructura snmp (comunidad, version, snmp v3 ...)
		#	if (exists $ProvisionLite::db_snmp_communties{$INFO{'ip'}}) {}
		$SNMP_VERSION=1;	
   	foreach my $c (@ProvisionLite::default_snmp_communties) {
      	my %snmp_info=();
      	#$oSNMP->timeout(1000000);
			#$self->log('info',"audit_general:: IP=$ip *******>C=$c ---> V=$SNMP_VERSION");

      	$snmp_info{'host_ip'} = $INFO{'ip'};
      	$snmp_info{'community'} = $c;
      	$snmp_info{'version'} = $SNMP_VERSION;

      	#sysDescr_sysObjectID_sysName_sysLocation
      	my ($rc, $rcstr, $res)=$snmp->verify_snmp_data(\%snmp_info);


			print "IP=$host_ip *******>C=$c ---> V=$SNMP_VERSION RES=($rc, $rcstr, $res) \n";
      	if ($rc==0) {
         	foreach my $l (@$res) {
            	my @rd=split(':@:', $l);
            	$sysdesc = $rd[1];
            	$sysoid = $rd[2];
            	$sysname =$rd[3];
            	$sysloc = $rd[4];
         	}
				last;
      	}
     	 	elsif ($rc==2) { $sysname ='U'; }
      	else { $sysname=undef; }

      	#if ( (defined $sysname) && ($sysname ne 'U') ){ $community=$c; last; }
   	}

		#return  join ($SEPARATOR, ($INFO{'name'},$INFO{'ip'},$ping,$snmp_data,$sysoid,$sysname,$sysloc,$sysdesc) );
		push @DATA, [$INFO{'name'},$INFO{'ip'},$ping,$tcp_ports,$community,$SNMP_VERSION,$sysoid,$sysname,$sysloc,$sysdesc];
		$self->log('debug',"audit_general::[DEBUG] RES=$INFO{'name'},$INFO{'ip'},$ping,$community,$SNMP_VERSION,$sysoid,$sysname,$sysloc,$sysdesc");

	}
   return (\@COLUMNS,\@DATA);
}


#-------------------------------------------------------------------------------
# Funcion auxiliar para escapar caracteres que tienen problemas a la hora de presentar
# metricas (sobre todo esta pensada para el label.
#----------------------------------------------------------------------------
sub escape  {
my ($self,$data)=@_;

   #OJO. LAs comillas impactan al javascript !!!!
#   $data =~ s/\"//g;
#   $data =~ s/\'//g;
#   $data =~ s/\&//g;

   #ojo con el <> porque pueden tener impacto a la hora de generar el txml
#   $data =~ s/\<//g;
#   $data =~ s/\>//g;

   #Todo lo que sea distinto del grupo de caracteres permitido me lo pulo.
   #ES LO MAS SEGURO !!! Porque si hay algun caracter raro no funciona el XMLin
   $data=~s/[^\w\s\/\\\(\)\[\]\{\}\:\.\,\-\_\@\%]//g;

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

   # Parche switches de 3Com ----------------------------
   $data=~s/RMON\:10\/100\s*(.+)/$1/;
   $data=~s/RMON\:\s*(.+)/$1/;
   return substr($data,0,150);
}


#----------------------------------------------------------------------------
# chk_conex
# Funcion auxiliar para validar el acceso a la BBDD
#----------------------------------------------------------------------------
sub chk_conex  {
my ($self,$dbh,$store,$table)=@_;

   my $ok=1;
   if (!defined $dbh) {
      $self->log('warning',"chk_conex::**NUEVA CONEX BBDD**");
      $dbh=$store->open_db(); $self->dbh($dbh); $store->dbh($dbh);
   }
   my $rres=$store->get_from_db( $dbh, 'count(*)', $table, '');

   my $error=$store->error();
   my $errstr=$store->errorstr();

   # Solo se contemplan errores por parte del cliente para forzar una reconexion
   # Errores de conexion a BBDD o errores como Mysql server has gone away (2006)
   if ($error>=2000) {
      $self->log('warning',"chk_conex::[ERROR BD] ($error) $errstr");
      $dbh=$store->open_db();
      $self->dbh($dbh);
      $store->dbh($dbh);
      if ($libSQL::err) {
         $ok=0;
         $self->log('warning',"chk_conex::[ERROR BD] NEW DBH ($error) $errstr");
      }
      else { $self->log('warning',"chk_conex::[INFO BD] NEW DBH OK");  }
   }

   return ($dbh,$ok);

}


#----------------------------------------------------------------------------
# time2date
# Funcion auxiliar para pasar de timestamp unix a fecha
# IN: $ts: Timestamp
# OUT: Fecha
#----------------------------------------------------------------------------
sub time2date {
my ($self,$ts)=@_;

   if (! $ts) { $ts=time(); }
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($ts);
   $year += 1900;
   $mon += 1;
   my $datef=sprintf("%02d/%02d/%02d %02d:%02d:%02d",$year,$mon,$mday,$hour,$min,$sec);
   #return  "$year-$mon-$mday  $hour:$min:$sec";
   return  $datef;
}



#----------------------------------------------------------------------------
# ip2str 
# Formatea cada octeto de una direccion IP a 3 digitos para que sea
# valida la ordenacion ASCII
# IN: $ip 
# OUT: $ip formateada
#----------------------------------------------------------------------------
sub ip2str {
my ($self,$ip)=@_;

	my ($o1,$o2,$o3,$o4)=split(/\./,$ip);
	return join('.', sprintf("%03d",$o1),sprintf("%03d",$o2),sprintf("%03d",$o3),sprintf("%03d",$o4));
}


#----------------------------------------------------------------------------
# lock
# Bloquea el acceso a un fichero.
#----------------------------------------------------------------------------
sub lock {
my ($self,$fh) = @_;

   flock($fh, LOCK_EX) or $self->log('warning', "lock[$$]:: No se puede bloquear $fh ($!)");

}

#----------------------------------------------------------------------------
# unlock
# Desbloquea el acceso a un fichero.
#----------------------------------------------------------------------------
sub unlock {
my ($self,$fh) = @_;

   flock($fh, LOCK_UN) or $self->log('warning', "unlock[$$]:: No se puede desbloquear $fh ($!)");

}


1;
__END__

