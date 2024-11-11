#######################################################################################################
# Fichero: (Crawler.pm) $Id: Crawler.pm,v 1.3 2004/05/02 15:36:09 fml Exp $
# Fecha: 15/08/2001
# Revision: Ver $VERSION
# Descripcion:
# TAGS DE SYSLOG:
# #RELOAD
########################################################################################################
package Crawler;
use strict;
use vars qw($VERSION);

use Fcntl qw(:flock);
use POSIX qw(:signal_h setsid WNOHANG);
use Time::HiRes qw(gettimeofday);
use Time::Local;
use Carp 'croak','cluck';
use Carp::Heavy;
use File::Basename;
use File::Copy;
use IO::File;
use IO::Socket;
use IO::Select;
use Cwd;
use Sys::Syslog qw(:DEFAULT setlogsock);
use Logger;
use ONMConfig qw(my_ip);
use Crawler::Store;
use Crawler::SNMP;
use Crawler::Latency;
use Crawler::Xagent;
use Crawler::Wbem;
use Crawler::WSClient;
use Digest::MD5 qw(md5_hex);
#use TDispatch;
use JSON;
$VERSION = '1.00';
use Socket;

use constant FACILITY => 'local0';
use vars qw(%CHILDREN);
my $CWD;
my $PROGRAM;
my $PARAMS='';
my $SOCKET;
my $PORT;
my $pid;
my $LASTPROC=0;
my $LASTHOUR_TS=0;
my $LASTDAY_TS=0;
my $LOGMSG_1='';

$Crawler::SEPARATOR=" _o&o_ ";
#----------------------------------------------------------------------------
$Crawler::TERMINATE=0;

use constant LOG_NONE => 0;
use constant LOG_SYSLOG => 1;
use constant LOG_STDOUT => 2;
use constant LOG_BOTH => 3;

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


my %TASK_TYPES = (
	snmp => [],
	latency => [],
);


my %CRAWLER=(
	snmp => '',
	latency => '',
);


my $IDX_PATH='/opt/data/idx';
$Crawler::MDATA_PATH='/opt/data/mdata';
$Crawler::TMARK_PATH='/var/log/tmark';
#$Crawler::SANITY_LAPSE=86400;  #24h
#$Crawler::SANITY_LAPSE=43200;  #12h
$Crawler::SANITY_LAPSE=21600;  #6h

#----------------------------------------------------------------------------
#my %MAX_METRICS_PER_CRAWLER= ( '60'=> 60, '300'=> 400, '3600'=> 4000, '86400'=> 10000 );
my %MAX_METRICS_PER_CRAWLER= ();
my %LAST_SIGN= ();
my $range_aux=1;
my %IDX2HOST= ();
my %IDM2HOST= ();
#----------------------------------------------------------------------------
$SIG{ALRM}=sub{ die "timeout" };


##############################################################################
# Funciones de la clase Crawler
#----------------------------------------------------------------------------
# Constructor
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   init_log();
	my $host_ip = my_ip();

	my $num_cpus=`/bin/cat /proc/cpuinfo | /bin/grep 'model name' | /usr/bin/wc -l`;
	chomp $num_cpus;
	if ($num_cpus !~ /\d+/) { $num_cpus=1; }

   #my $host=`/bin/hostname`;
   #$host=~s/(.*)\n/$1/;
	my $t=time();
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($t);
   $year+=1900; $mon+=1;
   my $tstr=sprintf("%04d%02d%02d",$year,$mon,$mday).'_'.sprintf("%02d%02d%02d",$hour,$min,$sec);

bless {
         _name => $arg{name} || 'crawler',
         _pid => $arg{pid} || '?',
         _user => $arg{user} || 'nobody',
         _group => $arg{group} || 'nobody',
         _start_flag => $arg{start_flag} || 0,
         _task_id =>$arg{task_id} || '',
   		_file_xml => $arg{file_xml} || '',
         _universe =>$arg{universe} || '',
         _store_path =>$arg{store_path} || 1,
         _store_subdir =>$arg{store_subdir} || {'elements' => 'elements', 'sla'=>'sla', onm=>'onm'},
         _data_path =>$arg{data_path} || 1,
         _store =>$arg{store} || '',
         _dbh =>$arg{dbh} || undef,
         _wsclient =>$arg{wsclient} || '',
         _mode_flag =>$arg{mode_flag} || {'rrd' => 1, 'db' => 0, 'alert'=>1},
         _response =>$arg{'response'} || 'OK',
         _event_data => [],
         _data_out => [],
         _host =>$arg{host} || 'localhost',
         _host_ip =>$arg{host_ip} || $host_ip,
         _host_idx =>$arg{host_idx} || 0,
         _cfg =>$arg{cfg} || {},
         _cfgsign =>$arg{cfgsign} || '',
         _range =>$arg{range} || 0,
         _log_mode =>$arg{log_mode} || LOG_SYSLOG,
         _log_level =>$arg{log_level} || 'info',
         _err_str =>$arg{err_str} || '[OK]',
         _err_num =>$arg{err_num} || 0,
         _severity =>$arg{severity} || 1,   #1: alta, 2: media, 3: baja
         _watch =>$arg{severity} || '0',
         _reload =>$arg{reload} || 1,
         _sign =>$arg{sign} || '0',
         _tdisp =>$arg{tdisp} || '',
         _thid =>$arg{thid} || 0,
         _hidx =>$arg{hidx} || 1,
         _cid =>$arg{cid} || 'unknown',
         _cid_ip =>$arg{cid_ip} || '',
         _fxm =>$arg{fxm} || '',
         _time_ref =>$arg{time_ref} || { 'time'=>$t, 'time_str'=>$tstr},
         _num_cpus =>$arg{num_cpus} || $num_cpus,
         _lang =>$arg{lang} || {},
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
# cfgsign
#----------------------------------------------------------------------------
sub cfgsign {
my ($self,$cfgsign) = @_;
   if (defined $cfgsign) {
      $self->{_cfgsign}=$cfgsign;
   }
   else {
      return $self->{_cfgsign};

   }
}



#----------------------------------------------------------------------------
# name
#----------------------------------------------------------------------------
sub name {
my ($self,$name) = @_;
   if (defined $name) {
      $self->{_name}=$name;
   }
   else {
      return $self->{_name};
   }
}

#----------------------------------------------------------------------------
# pid
#----------------------------------------------------------------------------
sub pid {
my ($self,$pid) = @_;
   if (defined $pid) {
      $self->{_pid}=$pid;
   }
   else {
      return $self->{_pid};
   }
}

#----------------------------------------------------------------------------
# user
#----------------------------------------------------------------------------
sub user {
my ($self,$user) = @_;
   if (defined $user) {
      $self->{_user}=$user;
   }
   else {
      return $self->{_user};
   }
}

#----------------------------------------------------------------------------
# group
#----------------------------------------------------------------------------
sub group {
my ($self,$group) = @_;
   if (defined $group) {
      $self->{_group}=$group;
   }
   else {
      return $self->{_group};
   }
}

#----------------------------------------------------------------------------
# start_flag
#----------------------------------------------------------------------------
sub start_flag {
my ($self,$start_flag) = @_;
   if (defined $start_flag) {
      $self->{_start_flag}=$start_flag;
   }
   else {
      return $self->{_start_flag};
   }
}


#----------------------------------------------------------------------------
# task_id
#----------------------------------------------------------------------------
sub task_id {
my ($self,$task_id) = @_;
   if (defined $task_id) {
      $self->{_task_id}=$task_id;
   }
   else {
      return $self->{_task_id};
   }
}

#----------------------------------------------------------------------------
# universe
#----------------------------------------------------------------------------
sub universe  {
my ($self,$universe) = @_;
   if (defined $universe) {
      $self->{_universe}=$universe;
   }
   else {
      return $self->{_universe};
   }
}
				
#----------------------------------------------------------------------------
# store_path
#----------------------------------------------------------------------------
sub store_path  {
my ($self,$store_path) = @_;
   if (defined $store_path) {
		if ($store_path !~ /(.*)\/$/) {$store_path .= '/'; }
      $self->{_store_path} = $store_path;
   }
   else {
      return $self->{_store_path};
   }
}

#----------------------------------------------------------------------------
# store_subdir
#----------------------------------------------------------------------------
sub store_subdir  {
my ($self,$store_subdir) = @_;

	if (ref($store_subdir) eq "HASH") {
      $self->{_store_subdir}=$store_subdir;
   }
   else {
   	my $s=$self->{_store_subdir}->{$store_subdir};
   	if ($s !~ /(.*)\/$/) {$s .= '/'; }
      return $s;
   }
}

#----------------------------------------------------------------------------
# data_path
#----------------------------------------------------------------------------
sub data_path  {
my ($self,$data_path) = @_;
   if (defined $data_path) {
      if ($data_path !~ /(.*)\/$/) {$data_path .= '/'; }
      $self->{_data_path} = $data_path;
   }
   else {
      return $self->{_data_path};
   }
}


#----------------------------------------------------------------------------
# store
#----------------------------------------------------------------------------
sub store  {
my ($self,$store) = @_;
   if (defined $store) {
      $self->{_store}=$store;
   }
   else {
      return $self->{_store};
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
sub wsclient  {
my ($self,$wsclient) = @_;
   if (defined $wsclient) {
      $self->{_wsclient}=$wsclient;
   }
   else {
      return $self->{_wsclient};
   }
}


#----------------------------------------------------------------------------
# mode_flag
# VALORES: {rrd=>0/1, alert=>0/1 }
#----------------------------------------------------------------------------
sub mode_flag  {
my ($self,$mode_flag) = @_;

   if (ref($mode_flag) eq "HASH") {
      $self->{_mode_flag}=$mode_flag;
   }
   elsif (!defined $mode_flag) { return $self->{_mode_flag}; }
}

#----------------------------------------------------------------------------
# response
#----------------------------------------------------------------------------
sub response {
my ($self,$response) = @_;
   if (defined $response) {
      $self->{_response}=$response;
   }
   else { return $self->{_response}; }
}

#----------------------------------------------------------------------------
# event_data
# Maneja el vector de eventos
#	1. Si no tiene parametros de entrada devuelve el array
#	2. Si el parametro de entrada es un array actualiza el vector con dicho array
#	3. Si el parametro de entrada es escalar lo mete en el array (push)
#----------------------------------------------------------------------------
sub event_data {
my ($self,$event_data) = @_;
   if (defined $event_data) {
      #$self->{_event_data}->[0]=$event_data;
		if ( ref($event_data) eq 'ARRAY') { $self->{_event_data} = $event_data; }
      else {  push @{$self->{_event_data}}, $event_data;  }
   }
   else { return $self->{_event_data}; }
}

#----------------------------------------------------------------------------
# data_out
# Almacena los datos obtenidos de la metrica
#  1. Si no tiene parametros de entrada devuelve el array
#  2. Si el parametro de entrada es un array actualiza el vector con dicho array
#  3. Si el parametro de entrada es escalar lo mete en el array (push)
#----------------------------------------------------------------------------
sub data_out {
my ($self,$data_out) = @_;
   if (defined $data_out) {
      if ( ref($data_out) eq 'ARRAY') { $self->{_data_out} = $data_out; }
      else {  push @{$self->{_data_out}}, $data_out;  }
   }
   else { return $self->{_data_out}; }
}


#----------------------------------------------------------------------------
# host
#----------------------------------------------------------------------------
sub host  {
my ($self,$host) = @_;
   if (defined $host) {
      $self->{_host}=$host;
   }
   else {
      return $self->{_host};
   }
}

#----------------------------------------------------------------------------
# host_idx
#----------------------------------------------------------------------------
sub host_idx  {
my ($self,$host_idx) = @_;
   if (defined $host_idx) {
      $self->{_host_idx}=$host_idx;
   }
   else {
      return $self->{_host_idx};
   }
}

#----------------------------------------------------------------------------
# host_ip
#----------------------------------------------------------------------------
sub host_ip  {
my ($self,$host_ip) = @_;
   if (defined $host_ip) {
      $self->{_host_ip}=$host_ip;
   }
   else {
      return $self->{_host_ip};
   }
}


#----------------------------------------------------------------------------
# file_xml
#----------------------------------------------------------------------------
sub file_xml {
my ($self,$file_xml) = @_;
   if (defined $file_xml) {
      $self->{_file_xml}=$file_xml;
   }
   else {
      return $self->{_file_xml};

   }
}

#----------------------------------------------------------------------------
# range
#----------------------------------------------------------------------------
sub range {
my ($self,$range) = @_;
   if (defined $range) {
      $self->{_range}=$range;
   }
   else {
      return $self->{_range};

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
# err_str
#----------------------------------------------------------------------------
sub err_str {
my ($self,$err_str) = @_;
   if (defined $err_str) {
      $self->{_err_str}=$err_str;
   }
   else {
      return $self->{_err_str};
   }
}

#----------------------------------------------------------------------------
# err_num
#----------------------------------------------------------------------------
sub err_num {
my ($self,$err_num) = @_;
   if (defined $err_num) {
      $self->{_err_num}=$err_num;
   }
   else {
      return $self->{_err_num};
   }
}

#----------------------------------------------------------------------------
# severity
#----------------------------------------------------------------------------
sub severity {
my ($self,$severity) = @_;
   if (defined $severity) {
      $self->{_severity}=$severity;
   }
   else {
      return $self->{_severity};
   }
}


#----------------------------------------------------------------------------
# watch
#----------------------------------------------------------------------------
sub watch {
my ($self,$watch) = @_;
   if (defined $watch) {
      $self->{_watch}=$watch;
   }
   else {
      return $self->{_watch};
   }
}


#----------------------------------------------------------------------------
# reload
#----------------------------------------------------------------------------
sub reload {
my ($self,$reload) = @_;
   if (defined $reload) {
      $self->{_reload}=$reload;
   }
   else {
      return $self->{_reload};
   }
}

#----------------------------------------------------------------------------
# sign
#----------------------------------------------------------------------------
sub sign {
my ($self,$sign) = @_;
   if (defined $sign) {
      $self->{_sign}=$sign;
   }
   else {
      return $self->{_sign};
   }
}

#----------------------------------------------------------------------------
# tdisp
#----------------------------------------------------------------------------
sub tdisp {
my ($self,$tdisp) = @_;
   if (defined $tdisp) {
      $self->{_tdisp}=$tdisp;
   }
   else { return $self->{_tdisp}; }
}


#----------------------------------------------------------------------------
# thid
#----------------------------------------------------------------------------
sub thid {
my ($self,$thid) = @_;
   if (defined $thid) {
      $self->{_thid}=$thid;
   }
   else { return $self->{_thid}; }
}

#----------------------------------------------------------------------------
# hidx
#----------------------------------------------------------------------------
sub hidx {
my ($self,$hidx) = @_;
   if (defined $hidx) {
      $self->{_hidx}=$hidx;
   }
   else { return $self->{_hidx}; }
}

#----------------------------------------------------------------------------
# cid
#----------------------------------------------------------------------------
sub cid {
my ($self,$cid) = @_;
   if (defined $cid) {
      $self->{_cid}=$cid;
   }
   else { return $self->{_cid}; }
}

#----------------------------------------------------------------------------
# cid_ip
#----------------------------------------------------------------------------
sub cid_ip {
my ($self,$cid_ip) = @_;
   if (defined $cid_ip) {
      $self->{_cid_ip}=$cid_ip;
   }
   else { return $self->{_cid_ip}; }
}

#----------------------------------------------------------------------------
# fxm
#----------------------------------------------------------------------------
sub fxm {
my ($self,$fxm) = @_;
   if (defined $fxm) {
      $self->{_fxm}=$fxm;
   }
   else { return $self->{_fxm}; }
}

#----------------------------------------------------------------------------
# time_ref
#----------------------------------------------------------------------------
sub time_ref {
my ($self,$time_ref) = @_;

	my %time_vector=();
   if (defined $time_ref) {

      my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time_ref);
      $year+=1900; $mon+=1;
		my $tstr=sprintf("%04d%02d%02d",$year,$mon,$mday).'_'.sprintf("%02d%02d%02d",$hour,$min,$sec);
      $self->{_time_ref}={ 'time'=>$time_ref, 'time_str'=>$tstr};
   }
   else { return $self->{_time_ref}; }
}

#----------------------------------------------------------------------------
# num_cpus
#----------------------------------------------------------------------------
sub num_cpus {
my ($self,$num_cpus) = @_;
   if (defined $num_cpus) {
      $self->{_num_cpus}=$num_cpus;
   }
   else { return $self->{_num_cpus}; }
}

#----------------------------------------------------------------------------
# lang
#----------------------------------------------------------------------------
sub lang {
my ($self,$lang) = @_;
   if (defined $lang) {
      $self->{_lang}=$lang;
   }
   else { return $self->{_lang}; }
}


#----------------------------------------------------------------------------
# get_metrics_for_crawler
#----------------------------------------------------------------------------
sub get_metrics_for_crawler {
my $self = shift;

	%MAX_METRICS_PER_CRAWLER= ();
	$MAX_METRICS_PER_CRAWLER{'snmp'}= {'60'=> 60, '300'=> 400, '3600'=> 4000, '86400'=> 10000 };
	$MAX_METRICS_PER_CRAWLER{'latency'}= {'60'=> 60, '300'=> 400, '3600'=> 4000, '86400'=> 10000 };
	$MAX_METRICS_PER_CRAWLER{'wbem'}= {'60'=> 60, '300'=> 400, '3600'=> 4000, '86400'=> 10000 };
	$MAX_METRICS_PER_CRAWLER{'xagent'}= {'60'=> 60, '300'=> 400, '3600'=> 4000, '86400'=> 10000 };

   my $rcfg=$self->cfg();

	my @types = ('snmp' , 'latency' , 'wbem', 'xagent');
	my @lapses = ('60' , '300', '3600', '86400');
	foreach my $type (@types) {
		foreach my $lapse (@lapses) {
			my $cfg_key_ext='max_'.$lapse.'_'.$type;  # p.ej max_60_snmp
			my $cfg_key='max_'.$lapse;  # p.ej max_60
			if ((exists $rcfg->{$cfg_key_ext}) && ($rcfg->{$cfg_key_ext} =~ /\d+/)) {
   			$MAX_METRICS_PER_CRAWLER{$type}->{$lapse}=$rcfg->{$cfg_key_ext}->[0];
			}
			elsif ($rcfg->{$cfg_key} =~ /\d+/) {
   		   $MAX_METRICS_PER_CRAWLER{$type}->{$lapse}=$rcfg->{$cfg_key}->[0];
   		}
			#En caso contrario, ya esta inicializada arriba

	#my $mm=$MAX_METRICS_PER_CRAWLER{$type}->{$lapse};
   #$self->log('debug',"register get_metrics_for_crawler****::[DEBUG]  TYPE=$type LAPSE=$lapse  (MAX_METRICS=$mm)");
		}
	}
}


#----------------------------------------------------------------------------
sub create_store_graph {
my $self = shift;

   # Objeto Store --------------------------------------
#   my $rcfg=$self->cfg();
#   my $db_server=$rcfg->{db_server}->[0];
#   my $db_name=$rcfg->{db_name}->[0];
#   my $db_user=$rcfg->{db_user}->[0];
#   my $db_pwd=$rcfg->{db_pwd}->[0];
#   my $host=$rcfg->{host_name}->[0];
#   my $log_level = $self->log_level();

   my ($db_server,$db_name,$db_user)=('localhost','onmgraph','onm');
	my $db_pwd = $self->get_db_credentials();
   my $log_level = $self->log_level();;

   my $store=Crawler::Store->new(db_server=>$db_server,db_name=>$db_name,db_user=>$db_user,db_pwd=>$db_pwd,
                                 log_level=>$log_level);

   my $dbh=$store->open_db();
   $store->dbh($dbh);
   return ($store,$dbh);
}

#----------------------------------------------------------------------------
sub create_store {
my $self = shift;

  	# Objeto Store --------------------------------------
 	my $rcfg=$self->cfg();
  	my $db_server=$rcfg->{db_server}->[0];
  	my $db_name=$rcfg->{db_name}->[0];
  	my $db_user=$rcfg->{db_user}->[0];
  	my $db_pwd=$rcfg->{db_pwd}->[0];
  	my $host=$rcfg->{host_name}->[0];
	my $log_level = $self->log_level();


$self->log('info',"create_store:: hidx db_server=$db_server db_name=$db_name db_user=$db_user db_pwd=$db_pwd");

  	my $store=Crawler::Store->new(db_server=>$db_server,db_name=>$db_name,db_user=>$db_user,db_pwd=>$db_pwd, cfg=>$rcfg,
											host=>$host, log_level=>$log_level);

	my $wsclient=Crawler::WSClient->new( cfg=>$rcfg, host=>$host );
	my $mserver=$rcfg->{'mserver'}->[0];
	my $pserver=$rcfg->{'pserver'}->[0];
	$wsclient->mserver($mserver);
	$wsclient->pserver($pserver);

   my $cid=$self->cid();
   $store->cid($cid);
   my $cid_ip=$self->cid_ip();
   $store->cid_ip($cid_ip);

  	$self->store($store);
  	$self->wsclient($wsclient);
	$store->wsclient($wsclient);

  	my $sp=$self->store_path();
  	$store->store_path($sp);

	my $dbh=$store->dbh();
	$self->dbh($dbh);
  	return $store;

}

#----------------------------------------------------------------------------
sub change_privileges {
  my ($user,$group) = @_;
  if ($user=~/^root$/i){return;}
  my $uid = getpwnam($user)  or die "Can't get uid for $user\n";
  my $gid = getgrnam($group) or die "Can't get gid for $group\n";
  $) = "$gid $gid";
  $( = $gid;
  $> = $uid;   # change the effective UID (but not the real UID)
}

#----------------------------------------------------------------------------
# SIGNAL USR1
#----------------------------------------------------------------------------
sub show_status {
my $t;
   $t=time;
   #syslog('notice',"USR1 -> $0. Estado= $STATE\[$t\]");

}

#----------------------------------------------------------------------------
# SIGNAL HUP
#----------------------------------------------------------------------------
sub do_hup {

   shutdown($SOCKET,2);
   log_warn("HUP -> $0. Reiniciando proceso .....");
   $> = $<;
   chdir $1 if $CWD =~ m!([./a-zA-z0-9_-]+)!;
   #my $port = $1 if $PORT =~ /(\d+)/;
   #exec 'perl','-w', $PROGRAM, $PORT or log_notice("Error en el exec .....");
   log_warn("$0 exec: $PROGRAM -p $PORT $PARAMS .....");
   exec "$PROGRAM -p $PORT $PARAMS" or log_warn("Error en el exec de $PROGRAM -p $PORT $PARAMS");
   die;
}


#----------------------------------------------------------------------------
# SIGNAL TERM
#----------------------------------------------------------------------------
sub do_term {
   #log_warn("TERM -> $0. Terminando proceso ....\n");
   #$SOCKET->shutdown(2);
   #die;
	$Crawler::TERMINATE=1;
}


#--------------------------------------------------------------------------------------
#sub check_memory {
#my $self=shift;
#
#   my $mem=`ps  -e -o pid,rss | grep $$`;
#   $mem=~s/^\s*\d+\s*(\d+)/$1/;
#   return $mem;
#}


#----------------------------------------------------------------------------
# check_cfgsign
#----------------------------------------------------------------------------
sub check_cfgsign {
my ($self,$file_cfg,$file_reload) = @_;

	my $cfg_sign=$self->cfg_sign();
	undef $/;
	open (F,$file_cfg);
	my $whole_file = <F>;
	close F;
	$/="\n";

	my $cfg_sign_new=md5_hex($whole_file);

	#Recargo file_cfg por no coincidir las firmas (==> Cambio en $file_cfg)	
	if ($cfg_sign_new ne $cfg_sign)  {

		$self->log('info',"check_cfgsign:: RELOAD de $file_cfg (OLD=$cfg_sign NEW=$cfg_sign_new)");
		my $rcfgbase=conf_base($file_cfg);
 		$self->cfg($rcfgbase);
		$self->cfg_sign($cfg_sign_new);
	}


	#Recargo file_cfg por detectar que existe fichero de recarga	
   elsif (-e $file_reload)  {

      $self->log('info',"check_cfgsign:: RELOAD de $file_cfg (-e $file_reload)");
      my $rcfgbase=conf_base($file_cfg);
      $self->cfg($rcfgbase);
      unlink $file_reload;
   }

}


#----------------------------------------------------------------------------
# procreate
#----------------------------------------------------------------------------
sub procreate {
my ($self, $type, $range, $lapse, $callback) = @_;

   my $signals = POSIX::SigSet->new(SIGINT,SIGCHLD,SIGTERM,SIGHUP);
   sigprocmask(SIG_BLOCK,$signals);  # block inconvenient signals
   log_die("Can't fork: $!") unless defined (my $child = fork());
   if ($child) {
      $CHILDREN{$child} = $callback || 1;
      my $dbh=$self->dbh();
      if (defined $dbh) { $dbh->{InactiveDestroy} = 1; }
   }
   else {

   	#----------------------------------------------------
   	POSIX::setsid();     # become session leader
   	open(STDIN,"</dev/null");
   	open(STDOUT,">/dev/null");
   	open(STDERR,">&STDOUT");
   	$CWD = getcwd;       # remember working directory
   	chdir '/';           # change working directory
   	umask(0);            # forget file mode creation mask
   	$ENV{PATH} = '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin';
   	delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};
   	$SIG{CHLD} = \&reap_child;
   	$SIG{USR1} = \&show_status;
   	#----------------------------------------------------
   	change_privileges($self->user,$self->group);

		#$SIG{INT} = $SIG{CHLD} = $SIG{TERM} = 'DEFAULT';
      $SIG{INT} = $SIG{CHLD} = 'DEFAULT';
      $SIG{USR1} = \&show_status;
      $SIG{HUP} = \&do_hup;
		$Crawler::TERMINATE=0;
      $SIG{TERM} = \&do_term;

		#my $name=$self->name().".$$";	

		#my $n=$self->name();
		#my $xml=$self->file_xml();
		#my $name="[$n.$num.$xml]";

		my $n=$self->name();
		my $idc = sprintf("%03d", $range);
		my $name="[$n.$idc.$type.$lapse]";

      $PROGRAM=$0;
      $0=$name;
      $self->pid($$);
      $self->log('notice',"Starting $0.... ($name) ....");

		#Creo fichero pid
      my $fpid='/var/run/'."$n.$idc".'.pid';
      open (F,">$fpid");
      print F "$$\n";
      close F;
		chmod 0664, $fpid;
   }

   sigprocmask(SIG_UNBLOCK,$signals);  # unblock signals
   return $child;
}

#----------------------------------------------------------------------------

# Signal CHLD
sub reap_child {
  while ( (my $child = waitpid(-1,WNOHANG)) > 0) {
    $CHILDREN{$child}->($child) if ref $CHILDREN{$child} eq 'CODE';
    delete $CHILDREN{$child};
  }
}

#----------------------------------------------------------------------------
# killall
#----------------------------------------------------------------------------
sub killall {
  kill TERM => keys %CHILDREN;
  # wait until all the children die
  sleep while %CHILDREN;
}
#----------------------------------------------------------------------------
# restart
#----------------------------------------------------------------------------
sub restart {
my $self = shift;

  $> = $<;  # regain privileges
  chdir $1 if $CWD =~ m!([./a-zA-z0-9_-]+)!;
  croak "bad program name" unless $0 =~ m!([./a-zA-z0-9_-]+)!;
  my $program = $1;
  my $port = $1 if $ARGV[0] =~ /(\d+)/;
  exec 'perl','-T',$program,$port or croak "Couldn't exec: $!";
}

#----------------------------------------------------------------------------
# real_lapse
# Obtiene real_lapse para ajustar el periodo de polling.
# Depende de lo configurado en /cfg/onm.conf
# Si no hay nada configurado, real_lapse=lapse
#----------------------------------------------------------------------------
sub real_lapse {
my ($self,$lapse) = @_;

   #Ajustes de real_lapse
   my $cfg=$self->cfg();
   my $real_lapse = $lapse;
   if (($lapse == 300) && (exists $cfg->{'real_lapse_300'}->[0]) && ($cfg->{'real_lapse_300'}->[0]=~/\d+/)) {
      $real_lapse = $cfg->{'real_lapse_300'}->[0];
   }
   elsif (($lapse == 3600) && (exists $cfg->{'real_lapse_3600'}->[0]) && ($cfg->{'real_lapse_3600'}->[0]=~/\d+/)) {
      $real_lapse = $cfg->{'real_lapse_3600'}->[0];
   }
   elsif (($lapse == 60) && (exists $cfg->{'real_lapse_60'}->[0]) && ($cfg->{'real_lapse_60'}->[0]=~/\d+/)) {
      $real_lapse = $cfg->{'real_lapse_60'}->[0];
   }

	return $real_lapse;
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

#   if ($level !~ /[debug|notice|warning|crit]/i) {$level='notice';}
   if ( ($level ne 'debug') && ($level ne 'notice') && ($level ne 'warning') && ($level ne 'crit'))  {$level='notice';}

  # my ($secs, $microsecs) = gettimeofday;
  # my $t="\[$secs:$microsecs\]";
  # my $msg = join('',$t,@arg) || "Registro de log";

   my $msg = join('',@arg) || "Registro de log";

   my ($pack,$filename,$line) = caller;
   $msg .= " ($filename $line)\n" unless $msg =~ /\n$/;
   #my $msgq=quotemeta($msg);
   #$msg=~s/\%/\\\%/g;
   $msg=~s/%/p/g;

   $msg =~ s/[^[:ascii:]]/_/g;

   if ( $mode & 1) { syslog($level,'%s',$msg); }
	if ( $mode & 2) { print "$msg"; }

#   if (($mode == LOG_SYSLOG) || ($mode == LOG_BOTH)) {syslog($level,$msg);}
#   if (($mode == LOG_STDOUT) || ($mode == LOG_BOTH)) {print "[$level]:$msg\n";}

   #if ($level =~ /[crit]/i) {die @arg;}  ##### ?????

}


#----------------------------------------------------------------------------
# Destructor
#----------------------------------------------------------------------------
sub DESTROY {
my $self = shift;
 	if ($self->start_flag()) {
  	 	$self->log('notice',"Ending $0 ($!)....");
   	$> = $<;  # restaurando privilegios
	}
}



#----------------------------------------------------------------------------
# sync_file_idx
# Sincroniza los ficheros idx creados en el directorio temporal ($IDX_PATH/tmp)
# al directorio final ($IDX_PATH).
# Esto se realiza una vez que se hayan generado todos en el temporal
#----------------------------------------------------------------------------
sub sync_file_idx {
my ($self)=@_;

   opendir (DIR,$IDX_PATH);
   my @files_base = grep { /\d+\.\w+\.info/ } readdir(DIR);
   closedir(DIR);

   opendir (DIR,"$IDX_PATH/tmp");
   my @files_tmp = grep { /\d+\.\w+\.info/ } readdir(DIR);
   closedir(DIR);

	# Actualizo los ficheros tmp -> base
	foreach my $file (@files_tmp) {
		my $file_tmp=$IDX_PATH.'/tmp/'.$file;
		my $file_base=$IDX_PATH.'/'.$file;


      my @file_previo=();
      $file=~/^(\d+)\./;
      my $idx=$1;
      foreach my $f (@files_base) {
         if ($f =~/^$idx\./) { push @file_previo,$f; }
      }

		my $nf=scalar @file_previo;
		if (! $nf) { move($file_tmp,$file_base); }
		else {
			# Este bucle solo tiene sentido en el caso espureo en que haya varios ficheros
			# para un mismo idx. En una situacion normal el array @file_previo debe ser de un valor.
			foreach my $ff (@file_previo) {
	   		#DBG--
	   		$self->log('debug',"sync_file_idx::#RELOAD previo=$ff new=$file");
  		 		#/DBG--

				if (! $ff) {
					move($file_tmp,$file_base);
					$self->log('info',"sync_file_idx::#RELOAD **CAMBIO** ");
				}
				elsif ($ff eq $file) { move($file_tmp,$file_base); }
				elsif ($ff ne $file) {
					my $fp=$IDX_PATH.'/'.$ff;
					unlink $fp;
					move($file_tmp,$file_base);
					$self->log('info',"sync_file_idx::#RELOAD **CAMBIO** ");
				}
			}
		}	
	}
}

#----------------------------------------------------------------------------
# set_file_idx
# Almacena el fichero con la descripcion de las metricas para el crawler_idx
# concreto (parametro range).
# $task es una referencia a un hash que contiene los valores necesarios para
# que el crawler obtenga las metricas
# Notar que estos valores son diferentes segun los distintos crawlers.
# La creacion de los ficheros se hace en un directorio temporal ($IDX_PATH/tmp)
# Cuando todos se han creado se mueven al directorio base ($IDX_PATH)
#----------------------------------------------------------------------------
sub set_file_idx {
my ($self,$range,$task,$new_sign)=@_;


   # Guardo la firma
   open (F,">$IDX_PATH/register/$range");
   print F $new_sign;
   close F;

   #-----------------------------------------------
   my $csv='';
	my @v1=();
	my @tofile=();

   foreach my $l (@$task) {

		my @k= sort keys (%$l);
		my %h=();
		foreach my $val (@k) {
			if (defined $l->{$val}) { push @v1,$l->{$val}; }
			$h{$val}=$l->{$val};
		}
		$csv.= join(',',@v1)."\n";
		#push @tofile,\%h;
		push @tofile,$l;
	}

   #my $csvh=md5_hex($csv);
   my $idx = sprintf("%05d", $range);
   #my $fdata="$IDX_PATH/tmp/$idx\.$csvh\.info";
   my $fdata="$IDX_PATH/tmp/$idx\.$new_sign\.info";
   #DBG--
   $self->log('debug',"set_file_idx::#RELOAD fdata=$fdata");
   #/DBG--

	# OJO!! aqui el glob no funcionaba bien ????
   opendir (DIR,$IDX_PATH);
   my @file_task = grep { /$idx\.\w+\.info/ } readdir(DIR);
   closedir(DIR);

	#foreach my $f (@file_task) { unlink $f; }

   open (F,">$fdata");
   #print F $csv;
	foreach my $l (@tofile) {
		my @pair=();
		my @k= sort keys (%$l);
		foreach my $val (@k) {
			if (defined $l->{$val}) { push @pair, $val.'='.$l->{$val};  }
			else { push @pair, $val.'= ';}
		}
		#print F join(',',@pair) . "\n";
		print F join($Crawler::SEPARATOR,@pair) . "\n";
	}
   close F;

}

#----------------------------------------------------------------------------
# get_file_idx
# Se ejecuta en cada iteracion de las tareas de crawler para comprobar si ha habido
# modificacion de tareas (metrica nueva/eliminada, monitor nuevo/eliminado ...)
# Chequea la firma  almacenada en la propiedad sign() con la posible nueva firma
# contenida en el nombre del fichero de tareas de un crawler determinado
# (0004.824cc92122aa177809ffe6f92202206b.info)
# IN:
# 	Un idx concreto ($range).
# OUT:
#	0->sin cambios  1->con cambios
#----------------------------------------------------------------------------
sub get_file_idx {
my ($self,$range,$task)=@_;

   #DBG--
	my $nm=scalar @$task;
   $self->log('debug',"get_file_idx::#RELOAD RANGE=$range NM=$nm metricas");
   #/DBG--

	my $sign=$self->sign();
	my $idx = sprintf("%04d", $range);

	# OJO!! aqui el glob no funcionaba bien ????
	opendir (DIR,$IDX_PATH);
	my @files = grep { /$idx\.\w+\.info/ } readdir(DIR);
	closedir(DIR);
	my $file_task=$files[0];

	my $new_sign=$file_task;
	#if ( $file_task =~ /$IDX_PATH\/$idx\.(\w+)\.info/ ) { $new_sign=$1; }
	if ( $file_task =~ /$idx\.(\w+)\.info/ ) { $new_sign=$1; }

	$self->sign($new_sign);

   #DBG--
   $self->log('debug',"get_file_idx::#RELOAD file_task=$file_task sign=$sign new_sign=$new_sign");
   #/DBG--

	# 0 => No ha cambiado la firma del fichero. No hay nada que hacer
	# 1 => Si ha cambiado la firma del fichero. Hay que actualizar la tarea del crawler
	if ($sign eq $new_sign) { return 0; }
	return 1;
}



#----------------------------------------------------------------------------
# set_data_path
# TODAVIA ES UN POCO BETA !!!!!)
# Calcula el file_path del fichero rrd con la metrica
# IN: vdisk (estructura de discos -> host_name:host_idx:disk:path remoto:path montado en master)
#		host (HOST), lapse
# OUT:   file_path y disk (indice del disco)
# NOTA:  file_path es redundante y con disk deberia ser suficiente (porque los nombres
#			se podra sacar del idx)
# NOTA: 	Por ahora el algoritmo de reparticion de los discos es basico.
#			Metricas > 60 a un disco, Metricas <= 60 a otro disco (por host)
#----------------------------------------------------------------------------
sub set_data_path {
my ($self,$vdisk,$lapse,$host)=@_;
my ($file_path,$disk);

$self->log('notice',"set_data_path::[****FML***] VDISK= @$vdisk");


	#DISK = __HOST_IP__:0:0:/opt/data/rrd/:/opt/data/rrd/
	my @host_disks = grep { /$host/ } @$vdisk;


$self->log('notice',"set_data_path::[****FML***] HOST=$host");

   my $ndisks=scalar @host_disks;
	if ($ndisks == 0) {
		$self->log('notice',"set_data_path::[ERROR] En HOST/DISKS de onm.conf");
		my $store_path=$self->store_path();
		return ($store_path,0);
	}
   elsif ($ndisks == 1) {  $disk = 0; }
   elsif ($ndisks == 2) {
   	if ( $lapse>60 ) { $disk = 0; }
      else { $disk = 1; }
   }

$self->log('notice',"set_data_path::[****FML***] NDISKS=$ndisks DISK=$disk");

   my @v=split(':', $host_disks[$disk]);
   $file_path = $v[4];
	if ($file_path !~ /(.*)\/$/) {$file_path .= '/'; }

	return ($file_path,$disk);

}


#----------------------------------------------------------------------------
# get_data_path
# Calcula el file_path del fichero rrd con la metrica
# IN: vdisk (estructura de discos -> host_name:host_idx:disk:path en la maquina de polling:path montado en master)
#     host (HOST), disk (indice del disco)
# OUT:   file_path
#----------------------------------------------------------------------------
sub get_data_path {
my ($self,$vdisk,$host,$disk)=@_;

   #DISK = __HOST_IP__:0:0:/opt/data/rrd/:/opt/data/rrd/
   my @host_disks = grep { /$host/ } @$vdisk;

   my @v=split(':', $host_disks[$disk]);
   my $file_path = $v[3];
   if ($file_path !~ /(.*)\/$/) {$file_path .= '/'; }

   return $file_path;
}


#----------------------------------------------------------------------------
# stop
#----------------------------------------------------------------------------
sub stop {
my  $self = shift;

   my $store=$self->create_store();
   my $dbh=$store->open_db();
   my $range=$self->range();

   if ($range) {
		my $rv=$store->get_crawler_pid($dbh,$range);
		my $pid=$rv->[0][0];
		$self->log('notice',"stop:: crawler $range [PID=$pid]");
		my $rc=kill 9, $pid;
		$self->log('notice',"stop:: crawler $range [RC=$rc]");
	}
	else {
		my $rv=$store->get_crawler_pid($dbh);
		foreach my $p (@$rv) {
			my $pid=$p->[0];
			$self->log('notice',"stop:: crawler [PID=$pid]");
			my $rc=kill 9, $pid;
			$self->log('notice',"stop:: crawler [RC=$rc]");
		}
	}
	
}


#----------------------------------------------------------------------------
# run
#----------------------------------------------------------------------------
sub run {
my ($self) = @_;
my $pid;

   my $store=$self->create_store();
   my $dbh=$store->open_db();
   $self->dbh($dbh);
   my $range=$self->range();
   my $spath=$self->store_path();
   my $dpath=$self->data_path();

   my $cfg=$self->cfg();
	my $mode_db=($cfg->{'mode_db'}->[0]=~/\d+/) ? $cfg->{'mode_db'}->[0] : 0;
	my $mode_rrd=($cfg->{'mode_rrd'}->[0]=~/\d+/) ? $cfg->{'mode_rrd'}->[0] : 1;
	my $mode_alert = ($cfg->{'mode_alert'}->[0]=~/\d+/) ? $cfg->{'mode_alert'}->[0] : 1;


   my $mapping=$store->get_crawler_work_descriptors($dbh);

   # Si no se ha definido un rango hay que arrancar todos los procesos
   # Por eso, lo primero que hago es eliminar los ficheros .pid
   if (! $range) {
      while (</var/run/crawler*.pid>) { unlink $_; }
   }
	# Si se ha especificado un crawler_idx (range) concreto, verifico que tiene tarea
	elsif (($range ne 'all') && (! exists $mapping->{$range})) {
      $self->log('warning',"run::[WARN] No hay descriptor de tarea para range=$range");
		# Si hay mapeos definidos y para este crawler no lo hay, eliminoel fichero de input
		if (scalar(keys %$mapping)>0) {
			my $fwork = $Crawler::MDATA_PATH.'/input/idx/0'.$range.'.info';
			my $rc=unlink $fwork;
      	$self->log('warning',"run::[WARN] Elimino fichero $fwork (rc=$rc)");
		}
      return;
   }

   foreach my $r (sort keys %$mapping) {

		if (($range ne 'all') && ($r ne $range)) { next; }

      my $lapse=$mapping->{$r}->{'lapse'};
      my $type=$mapping->{$r}->{'type'};

      if ( (! $type) || (! $range) || (! $lapse)) {
         $self->log('warning',"run::[WARN] NO definido tipo|rango|lapse");
         next;
      }

      $pid=$self->procreate($type,$r,$lapse);

      if ($pid == 0) {
         $self->start_flag(1);
         $self->log('info',"run:: crawler [range=$r|type=$type|lapse=$lapse] [mode_rrd=$mode_rrd mode_db=$mode_db mode_alert=$mode_alert] ($dpath)");

         my $log_level=$self->log_level();

         if ($type eq 'snmp') {
            my $snmp=Crawler::SNMP->new( store => $store, dbh => $dbh, store_path=>$spath, data_path=>$dpath, range=>$r, log_level=>$log_level, 'cfg'=>$cfg, mode_flag=>{'rrd' => $mode_rrd, 'db' => $mode_db, 'alert' => $mode_alert} );

            $snmp->do_task($lapse,$r);
         }
         elsif ($type eq 'latency') {
            my $latency=Crawler::Latency->new( store => $store, dbh => $dbh, store_path=>$spath, data_path=>$dpath, range=>$r, log_level=>$log_level, 'cfg'=>$cfg, mode_flag=>{'rrd' => $mode_rrd, 'db' => $mode_db, 'alert' => $mode_alert} );

            $latency->do_task($lapse,$r);
         }
         elsif ($type eq 'xagent') {
            my $xagent=Crawler::Xagent->new( store => $store, dbh => $dbh, store_path=>$spath, data_path=>$dpath, range=>$r, log_level=>$log_level, 'cfg'=>$cfg, mode_flag=>{'rrd' => $mode_rrd, 'db' => $mode_db, 'alert' => $mode_alert} );

            $xagent->do_task($lapse,$r);
         }
         else { $self->log('warning',"run::[WARN] Tipo=$type desconocido"); }
      }
      #sleep 3;
		select(undef, undef, undef, 0.5);
   }
}





#----------------------------------------------------------------------------
# register
#----------------------------------------------------------------------------
sub register {
my  $self = shift;
my $rv;

# 0   => [ rhash, rhash ..... rhash ]
# 10  => [ rhash, rhash ..... rhash ]
# 30  => [ rhash, rhash ..... rhash ]
# .....

   #---------------------------------------------------------------------------------------------------
   # Activo bloqueo, para no acumular tareas de tipo register concurrentemente
   # Notar que lo habitual es lanzarlas en crond
	my $lock_file='/opt/crawler/bin/register.lock';
   my $blocked = $self->init_lock($lock_file,300,1);
   if ($blocked) {
      $self->log('warning',"register::#RELOAD Bloqueo activo ($lock_file). No se hace el registro");
      return;
   }

   #---------------------------------------------------------------------------------------------------
   # Obtengo las firmas generadas en la ultima iteracion
	# Se lee el contenido de los ficheros /opt/data/idx/register/1 ..2,3 ... N y se almacena el dato
	# en %LAST_SIGN
   %LAST_SIGN= ();
   opendir (DIR,"$IDX_PATH/register");
   my @files_register = grep { /\d+/ } readdir(DIR);
   closedir(DIR);
   foreach my $f (@files_register) {
      open (FICH,"<$IDX_PATH/register/$f");
      $LAST_SIGN{$f}=<FICH>;
      close FICH;
   }


   #---------------------------------------------------------------------------------------------------
   # Si existe algun tipo de provision particular  en el fichero /cfg/custom_provision.sql
	# Se hace al principio para que la asignacion de PIDs lo contemple
   if ( -e '/cfg/custom_provision.sql' ) {
		my $db_pwd = $self->get_db_credentials();
      my $cmd="/usr/bin/mysql -u onm -p$db_pwd onm < /cfg/custom_provision.sql";
      system($cmd);
      $self->log('info',"register::#RELOAD existe custom CMD=$cmd ");
   }


   #---------------------------------------------------------------------------------------------------
	# Se obtienen del fichero de configuracion el numero de metricas que hay que asociar por crawler
   #my $rcfg=$self->cfg();
   #$MAX_METRICS_PER_CRAWLER{'60'}=$rcfg->{'max_60'}->[0];
   #$MAX_METRICS_PER_CRAWLER{'300'}=$rcfg->{'max_300'}->[0];
   #$MAX_METRICS_PER_CRAWLER{'3600'}=$rcfg->{'max_3600'}->[0];
   #$MAX_METRICS_PER_CRAWLER{'86400'}=$rcfg->{'max_86400'}->[0];

   #---------------------------------------------------------------------------------------------------
   # Se obtienen del fichero de configuracion el numero de metricas que hay que asociar por crawler
	# get_metrics_for_crawler inicializa %MAX_METRICS_PER_CRAWLER indexado por tipo
	$self->get_metrics_for_crawler();


   my $store=$self->create_store();
   my $dbh=$store->open_db();
   my $lapses=$store->get_crawler_lapses($dbh);
   my $host_idx=$self->host_idx();

	# Inicializa IDX2HOST (Esto ya no tiene sentido)
	$self->idx2host();

	# ------------------------------------------------------------------------------------------
	my ($base,$base_offset)=(0,1000);
   foreach my $lapse (@$lapses) {

      #if ((! $lapse) || (!defined $MAX_METRICS_PER_CRAWLER{$lapse})) {next;}
      if (! $lapse)  {next;}

      $self->register_type($lapse,'snmp',$base);		$base+=$base_offset;
      $self->register_type($lapse,'latency',$base);	$base+=$base_offset;
      $self->register_type($lapse,'xagent',$base);		$base+=$base_offset;
      $self->register_type_proxy($lapse,'xagent-proxy',$base);		$base+=$base_offset;
      #$self->register_type($lapse,'wbem',$base);		$base+=$base_offset;

   }
   $store->close_db($dbh);

   # Sincronizo los ficheros de tareas tmp->base
   $self->sync_file_idx();

   # Desactivo el bloqueo
   $self->close_lock('/opt/crawler/bin/register.lock');
}


#----------------------------------------------------------------------------
# register_type
# Rutina que hace el registro de los diferentes tipos de metricas..
# In:
# Out:
#----------------------------------------------------------------------------
sub register_type {
my ($self,$lapse,$type,$base)=@_;
my $new_sign='';
my @fields=();
my @idm_slice=();
my $raw='';
my $m=0;
my $id_previo=0;

   # Obtiene todos los datos para generar los ficheros de tareas
   my $store=$self->create_store();
   my $dbh=$store->open_db();
   %IDM2HOST=();
   my $rcfg=$self->cfg();
   my $host=$rcfg->{'host_name'}->[0];


   # IMP!! El vector de datos debe estar ordenado por id_dev porque para las metricas SNMP interesa que todo el
   # polling a un dispositivo concreto se haga desde el mismo crawler_idx.
   my $rv=$store->get_crawler_task($dbh,$type,$lapse,'',\%IDM2HOST);

	my $mm=$MAX_METRICS_PER_CRAWLER{$type}->{$lapse};
   if (!defined $rv) {
		$self->log('debug',"register_type::[INFO] SIN TAREA PARA TYPE=$type LAPSE=$lapse HOST=$host (MAX_METRICS=$mm)");
		return;
	}

#DBG--
	my $cntm=scalar( @{$IDM2HOST{$host}} );
   $self->log('info',"register_type::[DEBUG] TAREA PARA TYPE=$type LAPSE=$lapse HOST=$host METRICAS=$cntm|MAX==$mm");
#/DBG--

   if ($type eq 'wbem') {
      $self->log('debug',"register_type::[DEBUG] ***WBEM********");
		my $a=$IDM2HOST{$host};
      $self->log('debug',"register_type::[DEBUG] A=$a");
   }

   $raw='';
	my ($range_aux,$IDX)=(1,0);

	# Se itera sobre las metricas asociadas a este host
   foreach my $l ( @{$IDM2HOST{$host}} ) {
	
      $m++;
      $raw.= $l->{'hash'};

      #push @fields, [$IDX2HOST{$host}->[0],$host,$l->{'idmetric'}];
		$range_aux=$IDX+$base;
      push @fields, [$range_aux,$host,$l->{'idmetric'}];
      push @idm_slice, $l;


#   if ($type eq 'wbem') {
#my $id=$l->{'iddev'};
#my $n=$MAX_METRICS_PER_CRAWLER{$type}->{$lapse};
#$self->log('debug',"register_type::[DEBUG] M=$m <> N=$n iddev=$id TOT=$KK id_previo=$id_previo");
#}
		
			
      if ( ($m >= $MAX_METRICS_PER_CRAWLER{$type}->{$lapse}) && ($l->{'iddev'} != $id_previo) ) {

         $new_sign=md5_hex($raw);
         #my $range_aux= shift @{$IDX2HOST{$host}};

         #Compruebo si hay que actualizar los datos en B.D porque se haya producido alguna modificacion
         if ((! defined $LAST_SIGN{$range_aux}) || ($LAST_SIGN{$range_aux} ne $new_sign )) {

            $store->db_cmd_fast($dbh,\@fields,'UPDATE metrics SET crawler_idx=?,host=? WHERE id_metric=?');
            $self->set_file_idx($range_aux,\@idm_slice,$new_sign);
            $self->log('info',"register::#RELOAD **REGISTRO1** crawler-$type HOST=$host IDX=$range_aux Metricas=$m lapse=$lapse");
         }
         else { $self->log('debug',"register::#RELOAD NO registro1 crawler-$type HOST=$host IDX=$range_aux Metricas=$m lapse=$lapse"); }

         $m=0; @fields=(); @idm_slice=(); $raw='';
			$IDX +=1;
      }

      # Esto permite que no se corten  metricas SNMP de un mismo dispositivo en frontera de MAX_METRICS_PER_CRAWLER
      $id_previo=$l->{'iddev'};
   }

   if ($m) {

      $new_sign=md5_hex($raw);
      #my $range_aux= shift @{$IDX2HOST{$host}};
      if ( (scalar @idm_slice) ||  (! defined $LAST_SIGN{$range_aux}) || ($LAST_SIGN{$range_aux} ne $new_sign )) {

         $store->db_cmd_fast($dbh,\@fields,'UPDATE metrics SET crawler_idx=?,host=? WHERE id_metric=?');
         $self->set_file_idx($range_aux,\@idm_slice,$new_sign);
         $self->log('info',"register::#RELOAD **REGISTRO2** crawler-$type HOST=$host IDX=$range_aux Metricas=$m lapse=$lapse");
      }
      else { $self->log('debug',"register::#RELOAD NO registro2 crawler-$type HOST=$host IDX=$range_aux Metricas=$m lapse=$lapse"); }

      $m=0; @fields=(); @idm_slice=(); $raw='';
   }
}



#----------------------------------------------------------------------------
# register_type_proxy
# Rutina que hace el registro las metricas de tipo proxy
# In:
# Out:
#----------------------------------------------------------------------------
sub register_type_proxy {
my ($self,$lapse,$type,$base)=@_;
my $new_sign='';
my @fields=();
my @idm_slice=();
my $raw='';
my $m=0;
my $id_previo=0;

   # Obtiene todos los datos para generar los ficheros de tareas
   my $store=$self->create_store();
   my $dbh=$store->open_db();
   %IDM2HOST=();
   my $rcfg=$self->cfg();
   my $host=$rcfg->{'host_name'}->[0];

   # IMP!! El vector de datos debe estar ordenado por id_dev porque para las metricas SNMP interesa que todo el
   # polling a un dispositivo concreto se haga desde el mismo crawler_idx.
   my $rv=$store->get_crawler_task($dbh,$type,$lapse,'',\%IDM2HOST);

   my $mm=$MAX_METRICS_PER_CRAWLER{'xagent'}->{$lapse};
   if (!defined $rv) {
      $self->log('debug',"register_type_proxy::[INFO] SIN TAREA PARA TYPE=$type LAPSE=$lapse HOST=$host (MAX_METRICS=$mm)");
      return;
   }

#DBG--
   my $cntm=scalar( @{$IDM2HOST{$host}} );
   $self->log('info',"register_type_proxy::[DEBUG] TAREA PARA TYPE=$type LAPSE=$lapse HOST=$host METRICAS=$cntm|MAX==$mm");
#/DBG--

   $raw='';
   my ($range_aux,$IDX)=(1,0);

   # Se itera sobre las metricas asociadas a este host
   foreach my $l ( @{$IDM2HOST{$host}} ) {

      $m++;
      $raw.= $l->{'hash'};

      #push @fields, [$IDX2HOST{$host}->[0],$host,$l->{'idmetric'}];
      $range_aux=$IDX+$base;
      push @fields, [$range_aux,$host,$l->{'idmetric'}];
      push @idm_slice, $l;
	}

	$new_sign=md5_hex($raw);
	my $file_idx=$IDX_PATH.'/'.sprintf("%05d",$range_aux).'.'.$new_sign.'.info';
   $self->log('info',"register_type_proxy::[DEBUG] FILE_IDX=$file_idx");

   if ((! defined $LAST_SIGN{$range_aux}) || ($LAST_SIGN{$range_aux} ne $new_sign ) || (!-f $file_idx)) {

    	$store->db_cmd_fast($dbh,\@fields,'UPDATE metrics SET crawler_idx=?,host=? WHERE id_metric=?');
   	$self->set_file_idx($range_aux,\@idm_slice,$new_sign);
      $self->log('info',"register::#RELOAD **REGISTRO1** crawler-$type HOST=$host IDX=$range_aux Metricas=$m lapse=$lapse");
   }
}


#----------------------------------------------------------------------------
# idx2host
# Rutina que obtiene el vector con los idxs asignados a cada uno de los hosts
# definidos.
# Se basa en el numero de hostts definidos y sobre estos aplica un algoritmo de
# reparto (round-robin)
# In: -
# Out: %IDX2HOST(). Hash con una estructura idx -> host para un total de
# procesos de num.hosts * MAX_IDX_PER_HOST (200)
#----------------------------------------------------------------------------
sub idx2host {
my $self =shift;
my $new_sign='';

#   my $rcfg=$self->cfg();
#   my  $host_list=$rcfg->{host_list}->[0];
#	my @hosts=();
#	if ($host_list) { @hosts=split(';',$host_list);  }
#	else {  @hosts = ($rcfg->{'host_name'}->[0]);  }
#	my $n=scalar @hosts;
#	my $max_idx_per_host=$rcfg->{max_idx_per_host}->[0];
#	if (! $max_idx_per_host) { $max_idx_per_host=200;  }
#	my $total_idx=$n*$max_idx_per_host;
#	for (my $i=1; $i<=$total_idx; ) {
#		foreach my $h (@hosts) {
#			push @{$IDX2HOST{$h}}, $i;
#			$i+=1;
#		}
#	}

	my $rcfg=$self->cfg();
	my @hosts = ($rcfg->{'host_name'}->[0]);
	my $n=1;		# Numero de hosts (Se va a provisionar en cada poleador. No tiene sentido esto)
	my $max_idx_per_host=90;	# Otra chorrada, pero por no tocar todavia el IDX2HOST
	my $total_idx=$n*$max_idx_per_host;

   for (my $i=1; $i<=$total_idx; ) {
      foreach my $h (@hosts) {
         push @{$IDX2HOST{$h}}, $i;
         $i+=1;
      }
   }



}



#----------------------------------------------------------------------------
# set_new_metrics
# GLOBALES:
# 1. Ref a Hash cuyas claves son los hosts existentes y los valores una referencia
# 	  a un array con las metricas asignadas a dicho host.
# IN:
# 1. Ref a Array con las metricas no asignadas.
# 2. Ref a un Array con los hosts disponibles
# OUT:
# 	  En funcion de lo que decida, asigna las metricas no asignadas a host en el
#	  Hash global en la clave adecuada.
#----------------------------------------------------------------------------
sub set_new_metrics {
my ($self,$idm,$hosts)=@_;
my %cassigned=();

#	# Numero de metricas nuevas
#	my $cnew=scalar @$idm;
#
#	if ($cnew == 0) {return; }
#
#	foreach my $h (@$hosts) {	
#	
#		if (defined $IDM2HOST{$h}) {
#			$cassigned{$h}=scalar @{$IDM2HOST{$h}};
#		}
#		else { $cassigned{$h}=[]; }
#		$self->log('debug',"register.set_new_metrics:**>> HOST=$h CNEW=$cnew CASSIGNED=$cassigned{$h}");
#	}
#
#
#	# Por ahora la asignacion es muy simple. Todas las metricas nuevas se
#	# asignan al host con menor numero de metricas
#	my $hcandidate=$hosts->[0];
#	my $cmin=$cassigned{$hcandidate};
#	while ( my ($h,$c)=each %cassigned) {
#		if ($c < $cmin) { $hcandidate=$h; }
#	}
#
#	$self->log('info',"register.set_new_metrics:**>> ASSIGN $cnew metricas a HOST=$hcandidate CMIN=$cmin");
#
#	for (my $i=0; $i<$cnew; $i++) {
#		push @{$IDM2HOST{$hcandidate}},$idm->[$i];
#	}


   # Numero de metricas nuevas
   my $cnew=scalar @$idm;

   if ($cnew == 0) {return; }

	my $chosts=scalar @$hosts;

   # El criterio de asignacion es round-robin
   for (my $i=0; $i<$cnew; $i++) {
		my $hindex=($idm->[$i]->{'iddev'})%$chosts;
		my $hcandidate=$hosts->[$hindex];
      push @{$IDM2HOST{$hcandidate}},$idm->[$i];
   }



}


#----------------------------------------------------------------------------
# check_metrics
# In: atributo range del objeto (crwaler_idx)
# Out: Hash con el estado actual de las metricas manejadas por un determinado
# crawler.
# Realiza un query a la base de datos: id_metric,device.status,metrics.status
#----------------------------------------------------------------------------
#sub check_metrics {
#my ($self,$vector)=@_;
#
#	my %status=();
#   my $store=$self->store();
#   my $dbh=$self->dbh();
#   if (!defined $dbh) {  $dbh=$store->open_db(); }
#   $self->dbh($dbh);
#
#   my $range=$self->range();
#   my $rv=$store->get_metrics_status($dbh,$range);
#
#	my $e=$store->error();
#	if ($e) {
#		my $es=$store->errorstr();
#		$self->log('warning',"check_metrics::[WARN] ERROR en get_metrics_status $e: $es");
#		return;
#	}
#
#	foreach my $v (@$rv) {
#		my $idm=$v->[0];
#		my $dstat=$v->[1];
#		my $mstat=$v->[2];
#
##$self->log('info',"check_metrics ****:: [$idm $dstat $mstat]");
#
#		# Si a nivel de dispositivo esta acivo, el estado es el de la metrica
#		# Si a nivel de dispositivo  no esta acivo, el estado ya lo fija el dispositivo
#		if ($dstat==0) { $status{$idm}=$mstat; }
#		else { $status{$idm}=$dstat; }
#	}
#	$self->status(\%status);	
#}

#----------------------------------------------------------------------------
# get_metrics_from_txml (de un fichero .txml)
#----------------------------------------------------------------------------
sub get_metrics_from_txml {
my ($self,$cfg)=@_;
my @VECTOR=();
my %TASK=();

   foreach my $device (@$cfg) {
      foreach my $task (@{$device->{tasks}}) {
         my $done=0;
         #print "TASK=",$task,"\n";

         foreach my $k (keys %$task){
            #print "KEY=",$k,"\n";

            %TASK=();
            $TASK{host_ip}=$device->{ip};
            $TASK{host_name}=$device->{name};
				$TASK{host_name}=~s/^(.*?)\..*$/$1/;
            $TASK{lapse}=$task->{lapse};
            $TASK{once}=$task->{once};

				#$TASK{watch}=$task->{watch};
				#$TASK{vhigh}=$task->{vhigh};
				#$TASK{vlow}=$task->{vlow};
				#$TASK{vok}=$task->{vok};
				#$TASK{verror}=$task->{verror};

            $TASK{watch}=$task->{watch};
            $TASK{type}=$task->{type};
            $TASK{task_name}=$task->{name};
			
            if ($k ne 'metric') {next;}

            while ( my($k,$v)=each %{$task->{metric}}){
               #print "TARGET=$k->$v\n";

               #if (ref($v) eq "HASH") {
               if ((ref($v) eq "HASH") && (exists $v->{mtype})) {
                  #print "ES HASH (tipo=$type/$TASK{type})\n";

                  $TASK{name}=$k;
                  while ( my($k1,$v1)=each %{$v}){
							if (ref($v1) eq "HASH") { $v1=''; }
							$TASK{$k1}=$v1;
						}
                  #if ($TASK{type} eq $type) { push @VECTOR, {%TASK};}
                  push @VECTOR, {%TASK};
                  $done=1;
               }
               else {
						# Lo pongo aqui tambien por precaucion porque si algun valor no existe
						# es un hash y eso hace que se ponga done a 1 y no se almacenen los
						# valores de la metrica en @VECTOR.
						# Si el hash fuera el ultimo de los valores esto tampoco lo arregla, por eso
						# conviene inicializar todos los valores del txml
						$done=0;
                  $TASK{$k}=$v;
               }
            }

	         if ($done) {next;}
   	      #if ($TASK{type} eq $type) { push @VECTOR, {%TASK}; }
				push @VECTOR, {%TASK};
         }

      }
   }
   return \@VECTOR;

}





#----------------------------------------------------------------------------
# get_apps_from_txml (de un fichero .txml)
#----------------------------------------------------------------------------
sub get_apps_from_txml {
my ($self,$cfg)=@_;
my @VECTOR=();
my %TASK=();

   foreach my $device (@$cfg) {
      foreach my $task (@{$device->{tasks}}) {
         my $done=0;
         #print "TASK=",$task,"\n";

         foreach my $k (keys %$task){
            #print "KEY=",$k,"\n";

            %TASK=();
             $TASK{host_ip}=$device->{ip};
            $TASK{host_name}=$device->{name};
            $TASK{host_name}=~s/^(.*?)\..*$/$1/;
            $TASK{lapse}=$task->{lapse};
            $TASK{once}=$task->{once};

            #$TASK{watch}=$task->{watch};
            #$TASK{vhigh}=$task->{vhigh};
            #$TASK{vlow}=$task->{vlow};
            #$TASK{vok}=$task->{vok};
            #$TASK{verror}=$task->{verror};

            $TASK{watch}=$task->{watch};
            $TASK{type}=$task->{type};
            $TASK{task_name}=$task->{name};

            if ($k ne 'app') { next; }

            while ( my($k,$v)=each %{$task->{app}}){
               # print "TARGET=$k->$v\n";
               if ((ref($v) eq "HASH") && (exists $v->{atype})) {
                  #print "ES HASH (tipo=$TASK{type})\n";

                  $TASK{name}=$k;
                  while ( my($k1,$v1)=each %{$v}){
							if (ref($v1) eq "HASH") { $v1=''; }
							$TASK{$k1}=$v1;
						}
               	#if ($TASK{type} eq $type) { push @VECTOR, {%TASK};}
               	push @VECTOR, {%TASK};
               	$done=1;
              	}
               else {
                  # Lo pongo aqui tambien por precaucion porque si algun valor no existe
                  # es un hash y eso hace que se ponga done a 1 y no se almacenen los
                  # valores de la metrica en @VECTOR.
                  # Si el hash fuera el ultimo de los valores esto tampoco lo arregla, por eso
                  # conviene inicializar todos los valores del txml
                  $done=0;
						if (ref($v) eq "HASH") { $v=''; }
                  $TASK{$k}=$v;
               }
            }

            if ($done) {next;}
            #if ($TASK{type} eq $type) { push @VECTOR, {%TASK}; }
            push @VECTOR, {%TASK};
         }

      }
   }
   return \@VECTOR;

}



#----------------------------------------------------------------------------
# do_task
#----------------------------------------------------------------------------
sub do_task  {
my ($self,$lapse,$range,$task)=@_;

	my $spath=$self->store_path();
  	my $store=$self->store();
	my $snmp=Crawler::SNMP->new( store => $store, store_path=>$spath );
	my $latency=Crawler::Latency->new( store => $store, store_path=>$spath );
	my $C=scalar @$task;

	$self->log('info',"start_crawler:: crawler $range [lapse=$lapse|metricas=$C]");

my $dbh=$self->dbh();
$store->close_db($dbh);
exit;
   while (1) {

      my $tnext=time+$lapse;
		my $c=0;
	
      foreach my $desc (@$task) {

         my $task=$desc->{module};
		   #----------------------------------------------------

         if ($task =~ /mod_snmp_get_ext\:(\S+)/i) {
            $desc->{ext_function}=$1;
            $snmp->mod_snmp_get_ext($desc);
         }
         elsif ($task =~ /mod_snmp_get/i) { $snmp->mod_snmp_get($desc);}
         elsif ($task =~ /mod_snmp_count/i) { $snmp->mod_snmp_count($desc);}
         elsif ($task =~ /mod_snmp_walk/i) { $snmp->mod_snmp_walk($desc);}
			elsif ($task =~ /mod_monitor/i) { $latency->mod_monitor($desc);}
         else {$self->log('warning',"do_task::[WARN] No definida tarea: $task"); }
		
			$c++;
      }

      my $wait = $tnext - time;
      if ($wait < 0) {
         $self->log('warning',"do_task::[WARN] **SOLAPE** [$0:$$:$C|WAIT=$wait]");
      }
      else {
         $self->log('info',"do_task::[INFO] [$0:$$:$C|WAIT=$wait]");
         sleep $wait;
      }

   }
}

#----------------------------------------------------------------------------
# mod_alert
#
# $module_monitor= module&&monitor
#
#  module                              monitor
#  mod_monitor                         mon_icmp => 1VAL
#  mod_monitor                         mon_icmp|mon_pop3|mon_smtp => 3VAL
#  mod_monitor_ext:ext_dispo_base      mon_icmp => 4VAL
#  mod_snmp_get                        oid1 => 1VAL
#  mod_snmp_get                        oid1|oid2|oidN => NVAL
#  mod_snmp_get_ext:ext_status_if      oid1|oid2 => 2VAL
#  mod_snmp_get_ext:ext_mibhost_disk   oid1|oid2|oid3 => 2VAL
#
# $data:  ts:v1:v2:..:vN
# $desc:  ref a hash
# $event_data: ref a array. Eventos por monitor
#
# $severity= 1(rojo) | 2(naranja) | 3(amarillo)
# WATCHES: monitor enlaza metrics con alert_type.
# w25 en id_metric=1234 => Existe monitor=w25 en alert_type con los datos del watch
#----------------------------------------------------------------------------
sub mod_alert  {
my ($self,$module_monitor,$data,$desc,$event_data)=@_;

   # ----------------------------------------------
   my $task_id=$self->task_id();
	my $store=$self->store();

#DBG--
   $self->log('debug',"mod_alert::[DEBUG ID=$task_id] **PARAMS => MOD=$module_monitor DATA=$data**");
#/DBG--

	# ---------------------------------------------------------------------------------
	# Primero se contemplan los casos en los que no hay respuesta del agente remoto (snmp/xagent)
   #if ($data =~ /NOSNMP/) {
   if ($self->response() eq 'NOSNMP') {

#DBG--
   $self->log('debug',"mod_alert::[DEBUG ID=$task_id] RESPONSE=NOSNMP ]");
#/DBG--

      my $monitor='mon_snmp';
		$self->event_data('sin respuesta snmp (Timeout)');
      #$self->log('info',"mod_alert::[INFO ID=$task_id] $event_data->[$idx] -- NOSNMP");
      # En el caso de 'sin respuesta snmp' la severidad es 1 porque si no podemos vernos afectados
      # por la severidad de alguna metrica snmp concreta.
							 #$desc,			$ev,				$monitor,$severity,$cond,$mode
      $self->set_alert($desc,['sin respuesta snmp'],$monitor,1,'snmp-NOSNMP',0);
      return;
   }
   elsif ($self->response() eq 'NOXAGENT') {

#DBG--
   $self->log('debug',"mod_alert::[DEBUG ID=$task_id] RESPONSE=NOXAGENT ]");
#/DBG--

      my $monitor='mon_xagent';
		$self->event_data('sin respuesta cnm-agent (Timeout)');
      $self->set_alert($desc,['agente remoto no contesta'],$monitor,1,'agent-NOXAGENT',0);
      return;
   }

	if ($self->response() eq 'NOWBEM') {

#DBG--
   $self->log('debug',"mod_alert::[DEBUG ID=$task_id] RESPONSE=NOWBEM ]");
#/DBG--

      my $monitor='mon_wbem';
		$self->event_data('sin respuesta wbem (Timeout)');
      $self->set_alert($desc,$event_data->[0],$monitor,1,'wbem-NOWBEM',0);
      return;
   }

	# ---------------------------------------------------------------------------------

   # Control de alertas --------------------------
 	# $data = time:v1:....:vn
   # Si la metrica es de tipo COUNTER  hay que usar las diferencias (almacenadas en rrd) y no los
   # valores que hay en $data !!!!
   my @values=();
	my $data_ok=1;
   if ($desc->{'mode'} eq 'COUNTER') {
      my $r=$store->fetch_rrd_last($desc->{'file'});
		if ((! defined $r) || (ref($r) ne "ARRAY") ) {
			$self->log('warning',"mod_alert::[WARN ID=$task_id] COUNTER ERROR EN fetch_rrd_last de $desc->{file}");
			# Utilizo los valores obtenidos y no puedo computar el posible watch
	      @values=split(/\:/,$data);
	      shift @values; #El primer valor es el timestamp
			$data_ok=0;
		}
		else {
	      foreach my $v (@$r) {
				if ( (defined $v) && ($v =~ /\d+/))  { push @values,$v; }
			}
			# Hay que comprobar el caso de rrd sin datos (aspa) o con error de acceso
			if ((scalar @values) == 0) {
				#@values=('U');
	         # Utilizo los valores obtenidos y no puedo computar el posible watch
   	      @values=split(/\:/,$data);
      	   shift @values; #El primer valor es el timestamp
         	$data_ok=0;
			}

	      elsif ($desc->{subtype} eq 'traffic_mibii_if') {
   	      my @values8 = map { 8 * $_ } @values;
$self->log('debug',"mod_alert::[FML] ID=$task_id **rvd8 = @values8**rvd= @values");
      	   @values = @values8;
      	}

		}
#DBG--
   $self->log('debug',"mod_alert::[DEBUG ID=$task_id] COUNTER [@values] [$desc->{file}]");
#/DBG--

   }
   else {
      @values=split(/\:/,$data);
      shift @values; #El primer valor es el timestamp
   }


	# En las funciones de disponibilidad se monitoriza un valor pero el resultado son 4
	# Los valores son: [Disponible|No computable|No disponible|Desconocido]
	# Por eso hay que tratarlas de modo especial
	if ($desc->{module} =~ /\S+\:ext_dispo.*/) {
		if ($values[2]) { @values=('U'); }
		else {@values=(1); }
	}

   my ($mod,$mtor) = split(/&&/,$module_monitor);
   #my ($module,$ext) = split(/\:/,$mod);
	my @mon=split(/\|/,$mtor);
 	my $idx=-1;

#	my $U=0;
#	my $UMAX=scalar @values;

	my $mname=$desc->{name};
	my $monitor=undef;
	my $type=$desc->{type};
	my $severity=$desc->{severity} || 1;


 	# INCOMUNICADO (Sin respuesta del dispositivo) ----------------------------------
 	foreach my $val (@values) {

  		$idx +=1;

		#my $edata = (defined $event_data->[$idx]) ? $event_data->[$idx] : 'nada';
		#$self->event_data($edata);

		$self->log('debug',"mod_alert::[INFO ID=$task_id] Miro cada valor del resultado VAL=$val");

  		if ($val eq 'U') {
	
			$data_ok=0;	
			if ($type eq 'snmp') { 	
				# En este caso la severidad es baja. Es una alerta habitualmente de configuracion
				# y si no es asi puede tener que ver con comportamientos raros de los agentes.
				$severity=4;
				$self->event_data(["Sin respuesta en oid=$desc->{oid}"]);
				my $edata="Sin respuesta en oid=$desc->{oid}";
				$monitor = $mname;
				$self->set_alert($desc,[$edata],$monitor,$severity,'snmp-U',0);
				last;
			}
			#elsif ($type eq 'latency') { $self->set_alert($desc,[$edata],$mon[$idx],$severity,'U',0); }
			elsif ($type eq 'latency') {
				my $edata=$self->event_data();
				$monitor = ($mname =~ /^w_/) ? $mname : $mon[$idx];
				$self->set_alert($desc,$edata,$monitor,$severity,'latency-U',0);
				last;
			}
         elsif ($type eq 'xagent') {
            $severity=4;
				my $edata=$self->event_data();
           	$monitor =  $mname ;
            $self->set_alert($desc,$edata,$monitor,$severity,'xagent-U',0);
            last;
         }
         elsif ($type eq 'wbem') {
            $severity=4;
            $self->event_data(["Sin respuesta en instancia $desc->{oid}"]);
            my $edata="Sin respuesta en instancia=$desc->{oid}";
            $monitor = $desc->{'watch'};
            $self->set_alert($desc,[$edata],$monitor,$severity,'wbem-U',0);
            last;
         }

		}

		elsif (($val eq 'D') && ($type eq 'latency')) {
			my $edata=$self->event_data();
			$monitor=$mon[$idx].'_d';
			$severity=2;
         $self->set_alert($desc,[$edata],$monitor,$severity,'latency-D',0);
			last;
		}
 	}


#	#Ya se ha terminado de iterar por todos los valores (oids snmp)
#	if ( (defined $monitor) && ($type eq 'snmp') ) {
#		# Todos los valores obtenidos son U.
#		# Solo aplica a type=snmp porque tengo un monitor que puede medir varios valores
#		# En el caso de type=latency cada monitor mide solo un valor (en esta version)
#	 	if (($UMAX > 0) && ($U == $UMAX)) {
#         $self->set_alert($desc,$event_data,$monitor,$severity,'U',0);
#		}
#   }

 	# WATCHES DEFINIDOS -----------------------------------------------
   if ( (! defined $desc->{watch}) || (! $desc->{watch}) || (! $data_ok) ) { return; }
	
   $store=$self->store();
   my $dbh=$store->open_db();
	$monitor=$desc->{watch};
	$monitor=~s/\s//g;

	my $watches=$store->get_alert_type_info($dbh,{monitor=>$monitor});
	$store->close_db($dbh);

#DBG--
	$self->log('debug',"mod_alert::[DEBUG ID=$task_id] **TEST WATCH (1) => $monitor VALUES=@values**");
#/DBG--

 	foreach my $w (@$watches) {

		my $cause=$w->[0];
		my $severity=$w->[1];
		my $expr_long=$w->[2];
		my $wsize=$w->[3];

	   # Los watches que requieren analisis no se hacen en este modulo
	   # Esto es OBSOLETO !!
   	if ($expr_long =~ /\S+?;\S+?;\S+?/ )  { next; }

      my %expresions=();
      if ($expr_long =~ /\:/ )  {
         my @aux=split(/:/,$expr_long);
         my $s=1;
         foreach my $e (@aux) {
            if ($e ne '') {$expresions{$s} = $e;}
            $s +=1;
         }
      }
      else { %expresions=( $severity => $expr_long); }

      foreach my $sev (sort keys %expresions) {

         my $expr=$expresions{$sev};

#DBG--
	      $self->log('debug',"mod_alert::[DEBUG ID=$task_id] **TEST WATCH (2) => $monitor => CAUSE=$cause|EXPR=$expr|SEV=$sev** expr_long=$expr_long");
#/DBG--

  			my ($condition,$lval,$oper,$rval)=$self->watch_eval($expr,\@values,$desc->{'file'},$desc);

  			if ($condition) {	
				# Por ser una alerta de tipo watch el event_data es la expresion del watch
				$self->event_data($expr);
				$self->set_alert($desc,$event_data,$monitor,$sev,'WATCH',0);
#DBG--
				$self->log('info',"mod_alert::[DEBUG ID=$task_id] **WATCH** MONITOR=$monitor sev=$sev VAL=@values");
#/DBG--
				last;
			}
		}

	}
}

#----------------------------------------------------------------------------
# set_alert
# IN: Vector de datos ($desc), $alert_key, severidad
# OUT:1=>El watch se evalua como OK | 0=>El watch se evalua como NO OK
#----------------------------------------------------------------------------
sub set_alert  {
my ($self,$desc,$ev,$monitor,$severity,$cond,$mode)=@_;
my $iid;

   #Hash de correlacion de metricas uno a uno. Evita que aparezca duplicada una misma alerta
   my %correlate=( 'disp_icmp'=>'mon_icmp' );

   #-------------------------------------------------
   my $task_id=$self->task_id();

	# SET Alert --------------------------------------
   #my $store=$self->store();
   #my $dbh=$store->open_db();

   my %M=();
   $M{ip}=$desc->{host_ip};
   $M{watch}=$monitor;
   $M{type}=$desc->{type};
   $M{cause}=$desc->{cause};

#	$M{event_data}=$ev->[0];	#Puede haber varios valores, pero solo cojo el primero
#	if ($desc->{type} eq 'latency') {$M{event_data}=join(' | ',@$ev);}
#$M{event_data}=$self->event_data();
my $event_data=$self->event_data();
$M{event_data}= join (':', @$event_data);

	$M{severity} = (defined $severity) ? $severity : 1;

   $M{subtype}=$desc->{subtype};
   # Miro correlacion de alertas iguales proporcionadas por
   # metricas diferentes
   $M{mname}=$desc->{name};
   while (my ($k,$v)=each %correlate) {
      if ($M{mname} eq $k) { $M{mname}=$v; last; }
   }

	if ($cond eq 'snmp-NOSNMP') { $M{mname}='mon_snmp'; $M{id_metric}=0; }
	elsif ($cond eq 'wbem-NOWBEM') { $M{mname}='mon_wbem'; $M{id_metric}=0; }
	elsif ($cond eq 'agent-NOXAGENT') { $M{mname}='mon_xagent'; $M{id_metric}=0; }
	else { $M{id_metric}=$desc->{idmetric}; }
   $self->log('notice',"mod_alert::[INFO ID=$task_id] **SET:$cond** [$desc->{host_name}|EV=$M{event_data}|SEV=$severity|MNAME=$M{mname}|ID_METRIC=$M{id_metric}");

	#-----------------------------------------------------------------
	#-----------------------------------------------------------------
	#-----------------------------------------------------------------
	#-----------------------------------------------------------------
   my $cid='default';
   if (exists $desc->{'cid'}) { $cid=$desc->{'cid'}; }
	my $output_dir="$Crawler::MDATA_PATH/output/$cid/a";
   if (! -d $output_dir) {
      mkdir "$Crawler::MDATA_PATH/output";
      mkdir "$Crawler::MDATA_PATH/output/$cid";
      mkdir $output_dir;
   }

   $M{ip}=$desc->{host_ip};
   $M{watch}=$monitor;
   $M{type}=$desc->{type};
   $M{subtype}=$desc->{subtype};

	$M{host_ip}=$desc->{host_ip};
	$M{hname}=$desc->{hname};
	$M{hdomain}=$desc->{hdomain};
	
	#$M{'host_name'}=join('.', $M{hname},$M{hdomain});
	$M{'host_name'}=$desc->{host_name};
	$M{id_dev}=$desc->{iddev};

	#my $serial_alert_file=$M{type}.'-'.$M{mname}.'-'.$M{ip}.'.info';
	my $serial_alert_file=$M{ip}.'.'.$severity.'.'.$M{type}.'.'.$desc->{'iddev'}.'.'.$M{mname};
	my $serial_alert_data = encode_json(\%M);
	open (F,">$output_dir/$serial_alert_file");
	print F $serial_alert_data;
	close F;
   return 1;
}


#----------------------------------------------------------------------------
# watch_eval
# IN: $w: Expresion que define el watch.
#  $rvalues: Referencia a un array con los valores obtenidos.
# OUT:1=>El watch se evalua como OK | 0=>El watch se evalua como NO OK
#
# Definicion de los watches:
#
# (a) v1 => Primer valor del vector ($rvalues->[0])
#  v2 => Segundo valor del vector ($rvalues->[1])
#  y asi sucesivamente .........
# (b) Las expresiones pueden ser de los siguientes tipos:
#
# (b1) vx operador valor
#   donde: vx = v1, v2 o vn
#       operador = >, <, ==, !=
#      valor = n
# (b2) Combinaciones  de b1 (&&, ||)TCH=48712564>0
# (b3) Combinacion de diferentes valores en las expresiones
# (b4) Uso de funciones especiales (sin anidamiento de funciones)
#   values(v1,N) [>|<|==|!=] V => N valores seguidos de v1 >,<,==,!= V
#   mean(v1,N) => La media aritmetica de los ultimos N valores de v1
#----------------------------------------------------------------------------
sub watch_eval  {
my ($self,$watch,$rvalues,$rrd,$vardata)=@_;

	my ($rc,$lval,$rval,$oper)=(0,0,0,' ');
 	if ( (!defined $watch) || (! $watch) ){ return ($rc,$lval,$rval); }
 	if (!defined $rvalues) { return ($rc,$lval,$rval); }

   #-------------------------------------------------
   my $task_id=$self->task_id();
	my $store=$self->store();

	if ((defined $vardata) && (exists $vardata->{'top_value'}) && ($vardata->{'top_value'} ne '')) {
		my ($level1,$level2) = split (/\|/, $vardata->{'top_value'});
		$watch =~ s/\[LEVEL1\]/$level1/g;	
		$watch =~ s/\[LEVEL2\]/$level2/g;	
		$self->log('info',"mod_alert:watch_eval::[DEBUG ID=$task_id] LEVEL1,LEVEL2 >> $vardata->{'top_value'} **EXPR=$watch**");
	}

#DBG--
my $kk=join(' : ',@$rvalues);
$self->log('debug',"mod_alert:watch_eval::[DEBUG ID=$task_id] **EXPR=$watch VAL=$kk**");
#DBG--


   #----------------------------------------------------
   # Si el watch utiliza el ultimo valor almacenado, se obtiene.
   if ($watch =~ /LASTV\((.+)\)/) {
      my $expression=$1;
      my $new_val = 0;
      if ($expression =~ /v(\d+)/i) {
         my $idx=$1-1;
         #my $rrd='0000000002/mib2_ent_phy_parts-STD.rrd';
         my $o=$store->fetch_rrd_last($rrd);
         $new_val = $o->[$idx];
         $watch =~ s/(LASTV\(.+\))/$new_val/;
         $self->log('debug',"mod_alert:watch_eval::[DEBUG ID=$task_id] LASTV($expression) -> $new_val (idx=$idx) watch=$watch");
      }
      else {
         $self->log('warning',"mod_alert:watch_eval::[DEBUG ID=$task_id] ERROR al sustituir LASTV($expression) watch=$watch");
         return ($rc,$lval,$rval);
      }
   }

 	# Substitucion de vx por los valores del array ----------
 	for my $i (1..25) {
  		my $j=$i-1;
      if (($watch =~ /v$i\D+/i) || ($watch =~ /v$i$/i)) {
         $watch =~ s/v$i/$rvalues->[$j]/ig;
#DBG--
$self->log('debug',"mod_alert:watch_eval::[DEBUG ID=$task_id] **BUCLE SUBST WATCH=$watch ($i|$j)**");
#/DBG--
      }
 	}


 	my ($arg1,$arg2,$level,$rf);
 	# Funcion values -----------------------------------------
 #	while ( $watch =~ /values\((.*?),(\d+)\)\s*([<|>|==|!=])\s*(\d+)/ ) {
 # 		$arg1=eval $1;
 # 		$arg2=$2;
 # 		$oper=$3;
 # 		$level=$4;
 # 		$rf=wvalues($arg1,$arg2);
 # 		my $r=eval "$rf $oper $level";
 # 		$watch =~ s/values\(.*?,\d+\)\s*[<|>|==|!=]\s*\d+/$r/;
 #	}


	#----------------------------------------------------	
	# obsoleto ¿?
	# Funcion predefinida contains
	# vx contains('texto a buscar')
	$watch =~ s/^(.*?)match\((.+)\)$/$1 =~ \/$2\//;

	#----------------------------------------------------	
  	#Sustituyo = por ==
   #while ($watch =~ s/([^=]+)=([^=|^~]+)/$1==$2/g) {}
	while ($watch =~ s/([^=|^<|^>]+)=([^=|^~]+)/$1==$2/g) {}
   #Sustituyo <> por !=
   while ($watch =~ s/<>/!=/g) {}
   #Sustituyo (0/0) por (0)
   while ($watch =~ s/\(0\/0\)/\(0\)/g) {}
   #Sustituyo (0/0) por (0)
   $watch =~ s/^(.*?)(\s*[=|!]+~.*)$/'$1'$2/;

   #Sustituyo or por ||
   while ($watch =~ s/or/\|\|/gi) {}
   #Sustituyo and por &&
   while ($watch =~ s/and/\&\&/gi) {}

	#OJO !!! el eval devuelve 1 si true y nada si false.
	# Para hacer el eval 'untainted'
   if ($watch =~ /(.+)/) {
#		my $c=$1;
#		#Sustituyo = por ==
#		while ($c =~ s/([^=]+)=([^=]+)/$1==$2/g) {}
#		#Sustituyo <> por !=
#		while ($c =~ s/<>/!=/g) {}
#      #Sustituyo <> por !=
#      while ($c =~ s/0\/0/0/g) {}
#
		$rc = eval $1;
	}
	if (! defined $rc) {
		$self->log('warning',"mod_alert:watch_eval::[WARN ID=$task_id] ** AL EVALUAR $1 RC=UNDEF ($@) ($watch)");
	}
	elsif (! $rc) { $rc=0; }

	#caso texto
	if ($watch =~ /^(.+?)\s*([=~|!~]+)\s*(.+)$/) { $lval = $1;  $oper = $2; $rval = $3;}
	# ( (expr1) || (expr2) )
   elsif ($watch =~ /^\(*(.+?)\)*\s*(\|\|)\s*\(*(.+?)\)*$/) {  $lval = eval $1;  $oper = $2; $rval = eval $3; }
	# ( (expr1) && (expr2) )
   elsif ($watch =~ /^\(*(.+?)\)*\s*(\&\&)\s*\(*(.+?)\)*$/) {  $lval = eval $1;  $oper = $2; $rval = eval $3; }
	# expr1  algo [<= >= < > ==] algo
   elsif ($watch =~ /^(.+?)\s*([<=|>=|<|>|==|!=]+)\s*(.+)$/) {  $lval = eval $1;  $oper = $2; $rval = eval $3; }
	# expr1
	else { $lval = eval $watch;  $oper = ''; $rval = '';  }

   if (! defined $lval) {
      $self->log('warning',"mod_alert:watch_eval::[WARN ID=$task_id] ** AL EVALUAR LVAL=$1 RC=UNDEF ($@) ($watch)");
   }
   elsif (! defined $rval) {
      $self->log('warning',"mod_alert:watch_eval::[WARN ID=$task_id] ** AL EVALUAR RVAL=$3 RC=UNDEF ($@) ($watch)");
   }
   elsif ((! defined $oper) || (! $oper) ) {
      $self->log('warning',"mod_alert:watch_eval::[WARN ID=$task_id] ** AL EVALUAR OPER=$2 RC=UNDEF ($@) ($watch)");
   }
	else {
		if (! $lval) { $lval=0; }
		if (! $rval) { $rval=0; }
	}

#DBG--
my $rcval = (defined $rc) ? $rc : 'UNDEF';
$self->log('debug',"mod_alert:watch_eval::[DEBUG ID=$task_id] **TEST WATCH=$watch  LVAL=$lval RVAL=$rval OPER=$oper RC=$rcval** ($@)");
#/DBG--
 	return ($rc,$lval,$oper,$rval);
}


#----------------------------------------------------------------------------
# watch_eval_ext
# Es una evolucion de watch_eval para usarlo en alertas remotas
# IN:
# $alert2expr
# mysql> select * from cfg_remote_alerts2expr where id_remote_alert=1236;
# +-----------------+----+-----------------+----+------+
# | id_remote_alert | v  | descr           | fx | expr |
# +-----------------+----+-----------------+----+------+
# |            1236 | v3 | Variable 3      | =  | 2000 |
# +-----------------+----+-----------------+----+------+
# En este caso no fiene como parametro el fichero rrd. 
# (En alertas remotas no se almacena nada en rrd)
#----------------------------------------------------------------------------
sub watch_eval_ext  {
my ($self,$alert2expr,$expr_logic,$values)=@_;

	my ($ok,$left,$right)=(0,0,0);
	
   foreach my $e (@$alert2expr) {
      #a.id_remote_alert,a.expr as expr_logic, b.v,b.descr,b.fx,b.expr
#+-----------------+----+------------------+----+------+
#| id_remote_alert | v  | descr            | fx | expr |
#+-----------------+----+------------------+----+------+
#|              11 | v2 | clogHistSeverity | <= | 3    |
#|              12 | v2 | clogHistSeverity | =  | 4    |

      my $watch=$e->{'v'};
      my $descr=$e->{'descr'};
      my $fx=$e->{'fx'};
		if ($fx eq '=') { $fx='=='; }
      $right=$e->{'expr'};
      $ok=0;
		$left=0;

$self->log('debug',"watch_eval_ext:: **START** watch=$watch descr=$descr fx=$fx right=$right");
my $vv=1;
foreach my $x (@$values) {
	$self->log('debug',"watch_eval_ext:: **START** v$vv=$x");
	$vv+=1;
}
      #my $index=0;
      #if ($watch  =~ /v(\d+)/) { $index=$1; }


		# lvalue (puede ser de diferentes tipos:
		# v1
		# v1+v2/v3
		# 8*v1
		# .....
		# Ademas hay 3 casos: Numerico, logico, cadenas
	   for my $i (1..25) {
   	   my $j=$i-1;
			if (($watch =~ /v$i\D+/i) || ($watch =~ /v$i$/i)) {
         	$watch =~ s/v$i/$values->[$j]/ig;
      	}
   	}
$self->log('debug',"watch_eval_ext:: watch=$watch");
		
		if ($watch=~/[a-zA-Z]/) {
			$left = $watch;
		}
		else {
		   #----------------------------------------------------
   		#Sustituyo = por ==
  		 	while ($watch =~ s/([^=]+)=([^=|^~]+)/$1==$2/g) {}
		   #Sustituyo <> por !=
   		while ($watch =~ s/<>/!=/g) {}
   		#Sustituyo (0/0) por (0)
	  	 	while ($watch =~ s/\(0\/0\)/\(0\)/g) {}
	   	#Sustituyo (0/0) por (0)
   		$watch =~ s/^(.*?)(\s*[=|!]+~.*)$/'$1'$2/;

   		#OJO !!! el eval devuelve 1 si true y nada si false.
	   	# Para hacer el eval 'untainted'
   		if ($watch =~ /(.+)/s) {
      		$left = eval $1;
   		}
			if ( (! defined $left) || ($left eq '') ) {	
				$left = $watch;
			}
		}

$self->log('debug',"watch_eval_ext:: watch=$watch fx=$fx left=$left right=$right");

		# Conviene quitar todos los caracteres que tengan un significado especial en el motor
		# de regex para evitar problemas
		$left=~s/[\(|\)|\[|\]|\:|\?|\.|\*|\+]//g;
		$right=~s/[\(|\)|\[|\]|\:|\?|\.|\*|\+]//g;


		# Si right esta vacio se valida que left sea tre
		# En casocontrario se valida left + fx + right
      if (uc $fx =~ /MATCH/) {
			if ($right ne '') {
	         if ($left  =~ /$right/  ) { $ok=1; }
			}
			else {
				if ( $left ne $watch) { $ok=1; }
			}
      }
      elsif (uc $fx =~ /NOMATCH/) {
			if ($right ne '') {
         	if ($left !~ /$right/  ) { $ok=1; }
			}
         else {
            if ( $left eq $watch) { $ok=1; }
         }
      }
		else {
			my $condition="$left $fx $right";
			my $r = eval $condition;
			if ($r) { $ok=1; }
		}

		$self->log('debug',"watch_eval_ext:: OK=$ok CONDICION: $left $fx $right");

		# Segun $expr_logic se mira si termina OK o se siguen procesando valores
		if (uc $expr_logic eq 'OR') {
			if ($ok) { last; }
		}
      if (uc $expr_logic eq 'AND') {
			if (! $ok) { last; }
      }

	}

	return $ok;
}

#----------------------------------------------------------------------------
# watch_transform
# IN: $expr: Expresion que define el watch.
#  $rvalues: Referencia a un array con los valores obtenidos.
# OUT: watch aplicado segun la transformacion.
#		Por ahora es or para todos los valores
#----------------------------------------------------------------------------
sub watch_transform {
my ($self,$expr,$values)=@_;

   # or to all ------------------------------
   my @tmp=();

	if (! defined $values) { return ''; }
   my $n = scalar (@$values);

   if ($expr =~ s/v1/v_idx_/i) {
      for my $i (1..$n) {
         my $e=$expr;
         $e =~ s/v_idx_/v$i/i;
         push @tmp, $e;
      }
      return join ( ' || ', @tmp);
   }
   return '';
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
# time2cron
# Funcion auxiliar para pasar de timestamp unix a fecha para crontab
# IN: $ts: Timestamp
# OUT: 00 00 12 03 * 2012
#----------------------------------------------------------------------------
sub time2cron {
my ($self,$ts)=@_;

   if (! $ts) { $ts=time(); }
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($ts);
   $year += 1900;
   $mon += 1;
	
   my $datef=sprintf("%02d %02d %02d %02d \* %02d",$min,$hour,$mday,$mon,$year);
   return  $datef;
}

#----------------------------------------------------------------------------
# chk_conex
# Funcion auxiliar para validar el acceso a la BBDD
#----------------------------------------------------------------------------
sub chk_conex  {
my ($self,$dbh,$store,$table)=@_;

   my $ok=1;
   if (!defined $dbh) {
      $self->log('warning',"chk_conex:: **reconnect** dbh undef");
      $dbh=$store->open_db(); $self->dbh($dbh); $store->dbh($dbh);
   }
   my $rres=$store->get_from_db( $dbh, 'count(*)', $table, '');

   my $error=$store->error();
   my $errstr=$store->errorstr();
	my $res_db=$rres->[0][0] || 'unk';

   # Solo se contemplan errores por parte del cliente para forzar una reconexion
   # Errores de conexion a BBDD o errores como Mysql server has gone away (2006)
   if ($error>=2000) {
      $self->log('warning',"chk_conex:: **reconnect** ($error) $errstr dbh=$dbh store=$store res_db=$res_db");
		$store->close_db($dbh);
      $dbh=$store->open_db();
      $self->dbh($dbh);
      $store->dbh($dbh);


	   $rres=$store->get_from_db( $dbh, 'count(*)', $table, '');
  		$error=$store->error();
  		$errstr=$store->errorstr();
		$res_db=$rres->[0][0] || 'unk';

      if ($libSQL::err) {
         $ok=0;
         $self->log('warning',"chk_conex: **reconnect** ERROR EN CONEXION A BBDD open_db ($error) $errstr res_db=$res_db");
      }
      else { $self->log('info',"chk_conex:: **reconnect**  NEW DBH OK res_db=$res_db");  }
   }

   return ($dbh,$ok);

}

#----------------------------------------------------------------------------
sub get_ip_from_name  {
my ($self,$name)=@_;

	my $address = inet_ntoa(inet_aton($name));
	return $address;
}

#----------------------------------------------------------------------------
# get_all_child_pids
# Obtiene todos los procesos que cuelgan de un PID padre. 
# Itera sobre los hijos.
#----------------------------------------------------------------------------
sub get_all_child_pids {
my ($self,$pid)=@_;

   my @new_parents=($$);
	if ((defined $pid) && ($pid =~ /\d+/)) { @new_parents=($pid); } 
   my @pids=();
   my $childs;
   my $cnt=20; #Por precaucion
   do {
      $childs=$self->get_child(\@new_parents);
      @new_parents=();
      foreach my $child (@$childs) {
         if ($child=~/\d+/) {
            push @pids, $child;
            push @new_parents,$child;
         }
      }
      $cnt--;
   } while ((scalar(@new_parents)>0) && ($cnt>0));

   my @rev_pids=reverse(@pids);
   return \@rev_pids;
}

#----------------------------------------------------------------------------
# get_child
# Obtiene los hijos a primer nivel de una lista de procesos padre
#----------------------------------------------------------------------------
sub get_child {
my ($self,$parents)=@_;

   my @all_childs=();
   foreach my $pid (@$parents) {
      my $cmd="/bin/ps -o pid --ppid $pid";
      my @data=`$cmd`;
      shift @data;
      foreach my $child (@data) {
         chomp $child;
         $child=~s/\s+(\d+)\s+/$1/;
         push @all_childs,$child;
      }
   }
   return \@all_childs;
}


#----------------------------------------------------------------------------
# RUTINAS DE BLOQUEO
# Pensadas sobre todo para procesos en cron
# Retorno: 0->Se ha bloqueado 1->No se ha bloqueado. Estaba ya activo.
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
sub update_lock {
my ($self,$lock_file)=@_;

   if (-f  $lock_file) {
      system("echo $$ > $lock_file");
      #DBG--
      $self->log('debug',"update_lock:: bloqueo actualizad ($$) ");
      #/DBG--
   }
   return(0);
}

#----------------------------------------------------------------------------
sub init_lock {
my ($self,$lock_file,$max_lock_seconds,$kill)=@_;

	my $act_time=time;

	# Si no existe bloqueo, creo el fichero y termino
  	if (! -r  $lock_file) {
    	system("echo $$ > $lock_file");
      #DBG--
      $self->log('debug',"init_lock:: bloqueo generado ($$) ");
      #/DBG--
    	return(0);
	}
  	else {

   	# ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)
    	# data[9] es $mtime;
      my @data = stat($lock_file);
      my $chktime=($act_time - $data[9]);
		# Miro si ha vencido el timeout
      if ($chktime > $max_lock_seconds) {
			# Ha vencido el timeout y no mato proceso
			if ($kill==0){
				$self->log('notice',"init_lock:: Bloqueo activo (kill=0)");
				return(1);
			}
			# Ha vencido el timeout y si mato proceso
        	else {
          	open (FICH,"< $lock_file");
				my $pid=<FICH>;
          	if ($pid ) {
					chomp $pid;
           		if ( -r "/proc/$pid") {
						system ("kill -9 $pid");
						$self->log('notice',"init_lock:: kill $pid");
					}
          	}
				system("echo $$ > $lock_file");
				#DBG--
				$self->log('debug',"init_lock:: bloqueo generado ($pid) ");
				#/DBG--
          	return(0);
       	}
     	}
		# No ha pasado el timeout
		else {return(1);}
	}
}

#----------------------------------------------------------------------------
sub close_lock {
my ($self,$lock_file) = @_;
	
	unlink $lock_file;
   #DBG--
   $self->log('debug',"init_lock:: bloqueo eliminado ($$) ");
   #/DBG--

}



#----------------------------------------------------------------------------
# shared_write
#----------------------------------------------------------------------------
sub shared_write {
my ($self,$data,$fout) = @_;

   my $rc = open (F, ">$fout");
	if (! $rc) {
		$self->log('warning',"shared_write:: FILE OPEN ERROR $fout ($!)");
		return;
	}
	while ( my ($k,$v)=each %$data) {
		$v=~s/\n/ /g;
      print F "$k=$v\n";
   }
   close (F);
}



#----------------------------------------------------------------------------
# shared_read
#----------------------------------------------------------------------------
sub shared_read {
my ($self,$fout) = @_;

   my %data=();
   if (-f $fout) {
      my $rc = open (F, "<$fout");
	   if (! $rc) {
   	   $self->log('warning',"shared_read:: FILE OPEN ERROR $fout ($!)");
      	return \%data;
   	}

      while (<F>) {
         chomp;
			my ($k,$v)=split(/=/,$_,2);
         $data{$k}=$v;
      }
      close (F);
   }
   return \%data;
}


#----------------------------------------------------------------------------
# shared_init
#----------------------------------------------------------------------------
sub shared_init {
my ($self,$fout) = @_;


   unlink $fout;

}

#----------------------------------------------------------------------------
# shared_clean
#----------------------------------------------------------------------------
sub shared_clean {
my ($self,$dir) = @_;

	if (! -d $dir) { 
		$self->log('info',"shared_clean:: **ERROR** NO EXISTE $dir");
		return; 
	}

   opendir (DIR,$dir);
   my @files = readdir(DIR);
   closedir(DIR);

	foreach my $f (@files) {
		if ($f =~ /^\./) { next; }
		if ($f !~ /^_ipc/) { next; }
		unlink "$dir/$f";
	}	
}

#----------------------------------------------------------------------------
# init_tmark
# Inicializa el fichero tmark del proceso==> Lo borra
#----------------------------------------------------------------------------
sub init_tmark {
my ($self) = @_;

   my $file=$Crawler::TMARK_PATH.'/'.$0;
	unlink $file;
}

#----------------------------------------------------------------------------
# set_gui_mark
# Se actualiza el ts del fichero /opt/data/mdata/notificationsd-cid-cid_ip.out
# que indica al interfaz que debe volver a leer las alertas.
#----------------------------------------------------------------------------
sub set_gui_mark  {
my ($self,$cid,$cid_ip)=@_;

   my $file='/opt/data/mdata/notificationsd-'.$cid.'-'.$cid_ip.'.out';
   open (F,">$file");
   print F "DONE\n";
   close F;
}

#----------------------------------------------------------------------------
# log_tmark
# Registra la info correspondiente en el fichero tmark del proceso
# a. Gestiona $ts0;$tsf0 (timestamp de arranque del proceso)
# b. Almacena $cnt + pid + $ts0;$tsf0 +timestamp
# Devuelve el valor de $cnt
#----------------------------------------------------------------------------
sub log_tmark {
my ($self) = @_;

	my $file=$Crawler::TMARK_PATH.'/'.$0;
   my $ts=time();
	my $tsf=$self->time2date($ts);
	my ($ts0,$tsf0) = ($ts,$tsf);

   if (-f $file) { 
      open (F,"<$file");
      my $l=<F>;
      chomp $l;
      close(F);
		#8597;1574498769;2019/11/23 09:46:09;1574507157;2019/11/23 12:05:57
		#($pid, $ts0, $tsf0, $ts, $tsf)
      my @c=split(';', $l);
		$ts0=$c[1];
		$tsf0=$c[2];
	}

   my $rc = open (F,">$file");
   if ($rc) {
      print F "$$;$ts0;$tsf0;$ts;$tsf\n";
      close(F);
      $self->log('debug', "log_tmark[$$]:: file=$file --> $$;$ts0;$tsf0;$ts;$tsf");
   }
   else {
      $self->log('info', "log_tmark[$$]:: file=$file **WRITE ERROR** $! ($$;$ts0;$tsf0;$ts;$tsf)");
   }
   return $ts0;
}


#----------------------------------------------------------------------------
# chk_tmark_files
# Si los procesos no registran actividad en $max_time se reinician desde cnm-watch
#----------------------------------------------------------------------------
sub chk_tmark_files {
my ($self, $vector) = @_;

	if (ref($vector) ne "ARRAY") {
	   opendir (DIR,$Crawler::TMARK_PATH);
   	my @files_tmark = readdir(DIR);
   	closedir(DIR);
		$vector=\@files_tmark;
	}

	my $tnow=time();
	my $offset=3;

	foreach my $f (@$vector) {
		if ($f=~/^\./) { next; }
		my $file=$Crawler::TMARK_PATH.'/'.$f;		
		my ($proc,$proc_time) = ('crawler',900);
		#[crawler.4070.snmp.300]
		#[crawler.7000.snmp.3600]
      #[notificationsd.010.notificationsd.60]
      if ($f=~/^\[(\S+?)\.(\d+)\.(\w+)\.(\d+)\]$/) {  ($proc,$proc_time) = ($1,$4); } 

		# Si es actionsd -> $max_time = 7200
		# Para proc_time hasta 300 -> $max_time = 3*proc_time
		# Para proc_time hasta 3600 -> $max_time = 2*proc_time
		# Para proc_time >= 3600 -> $max_time = 1.1*proc_time
		my $max_time = $offset*$proc_time; #60, 300 ..
		if ($proc =~ /actionsd/) { $max_time = 7200; }
		elsif (($proc =~ /notificationsd/) && ($proc_time<=60)) { $max_time = 600; }
		elsif (($proc_time > 300) && ($proc_time < 3600)) { $max_time = 2*$proc_time; }
		elsif ($proc_time >= 3600) { $max_time = 1.1*$proc_time; }

#		#/actionsd/ y /notificationsd/ siguen otro criterio.
#		if ($proc =~ /actionsd/) { $max_time = 7200; }
#		elsif ($proc =~ /notificationsd/) { $max_time = 3600; }
#		elsif ($proc =~ /crawler-app/) { $max_time = 7200; }

		if (-s $file == 0) { next; }
   	open (F,"<$file");
		my $l=<F>;
		chomp $l;
   	close(F);
		#25490;1296852992;2011/02/04 21:56:32
		my ($pid, $ts0, $tsf0, $ts, $tsf)=split(';', $l);
		if ($pid !~ /\d+/) { next; }
		if ($ts !~ /\d+/) { next; }

		my $tdiff=$tnow-$ts;

		$self->log('debug', "chk_tmark[$$]:: f=$f PID=$pid tdiff=$tdiff max_time=$max_time (tsf0=$tsf0)");
		#$self->log('debug', "chk_tmark[$$]:: f=$f PID=$pid tdiff=$tdiff ($tnow - $ts) max_time=$max_time");

		if ($tdiff>$max_time) {
	      $self->log('info',"chk_tmark:: **RESTART $f** KILL PID=$pid proc=$proc ($tnow - $ts) $tdiff>$max_time");
   	   my $rc=kill 9, $pid;
      	$self->log('info',"chk_tmark:: RESTART DONE [RC=$rc]");
			unlink $file;
		}
	}
}

#-------------------------------------------------------------------------------------------
# start_crawler
#-------------------------------------------------------------------------------------------
sub start_crawler {
my ($self,$idx)=@_;
my $rc;

   my $MAX_OPEN_FILES=8192;
   $rc=system ("ulimit -n $MAX_OPEN_FILES && /opt/crawler/bin/crawler -s -c $idx");
   $self->log('notice',"start_crawler::[INFO] Starting crawler $idx ... (RC=$rc)");
}

#----------------------------------------------------------------------------
# slurp_file
#----------------------------------------------------------------------------
sub slurp_file {
my ($self,$file)=@_;

	local($/) = undef;  # slurp
	open (F,"<$file");
 	my $content = <F>;
	close F;
	return $content;
}

#----------------------------------------------------------------------------
# untag_ip
# Elimina el sufijo de la IP que se pone en el caso de entidades que no sean dispositivos.
# (entity=1). P.ej. servicios web.
#----------------------------------------------------------------------------
sub untag_ip {
my ($self,$ip) = @_;

	$ip=~s/^(\d+\.\d+\.\d+\.\d+)\-\w+$/$1/;
	return $ip;
}

#----------------------------------------------------------------------------
# check_mounted_df
# Chequea si la particion especificada esta montada. Util para validar:
# tmpfs                 128M     0  128M   0% /opt/data/mdata
#
# c->check_mounted_df('/opt/data/mdata','tmpfs');
#----------------------------------------------------------------------------
sub check_mounted_df {
my ($self,$mnt_point,$share)=@_;

   my $cmd="/bin/df -h $mnt_point 2>&1";
   my @res=`$cmd`;
   my ($share0, $size0, $used0, $avail0, $use0, $mnt_point0)= split (/\s+/,$res[1]);

   my $rc=0;
   $share0 =~ s/^(.*)\/$/$1/;
   $share =~ s/^(.*)\/$/$1/;
   if ($share eq $share0) { $rc=1; }

   $self->log('debug', "check_mounted_df[$$]:: share0=$share0 share=$share ($mnt_point) rc=$rc");

   return $rc;
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

#----------------------------------------------------------------------------
# get_host_by_name
#----------------------------------------------------------------------------
sub get_host_by_name {
my ($self,$name)=@_;

	my @addresses = gethostbyname($name) or $self->log('info', "get_host_by_name[$$]:: No se puede resolver $name");
	my $n = scalar(@addresses);	
	@addresses = map { inet_ntoa($_) } @addresses[4 .. $n];
	return \@addresses;
}

#----------------------------------------------------------------------------
# get_db_credentials
#----------------------------------------------------------------------------
sub get_db_credentials {
my ($self)=@_;

   my $file='/cfg/onm.conf';
   my $pwd='';
   open (F,"<$file");
   while (<F>) {

      chomp;
      if (/^#/) {next;}

      if (/\bDB_PWD\s*\=\s*(.*)$/) {
         $pwd=$1;
         last;
      }
   }
   return $pwd;
}

#----------------------------------------------------------------------------
# get_json_config
# Obtiene un hash con los datos de configuracion definidos en fichero json.
# Dos modos de funcionamiento según el parametro sea un fichero o un directorio
# a. Si es un fichero decodifica el json y devuelve la estructura que tenga
# b. Si es un directorio, recorre el directorio y devuelve un array de estructuras
# Se recomienda que cada fichero sea un hash y se eviten estructuras complejas
# salvo casos especiales.
#----------------------------------------------------------------------------
sub get_json_config {
my ($self, $path)=@_;

	my $cfg={};
   my @cfg_vector=();
   if (-d $path) {
      opendir (DIR,$path);
      my @cfg_files = readdir(DIR);
      closedir(DIR);
      foreach my $file (sort @cfg_files) {
         if (($file eq '.') || ($file eq '..')) { next; }
         my $data = $self->slurp_file("$path/$file");
         eval {
            $cfg=decode_json($data);
         };
         if ($@) { $self->log('warning',"get_json_config::**ERROR JSON** En $path/$file ($@)"); }
			else { push @cfg_vector, $cfg; }
      }
		return \@cfg_vector;
   }
	elsif (-f $path) {
      my $data = $self->slurp_file($path);
      eval {
         $cfg=decode_json($data);
      };
      if ($@) { $self->log('warning',"get_json_config::**ERROR JSON** En $path ($@)"); }
	}
	return [$cfg];
}

#----------------------------------------------------------------------------
# check_calendar
#my $CAL1= {
#
#   'exclude' => [
#
#      {'name'=>'rule-year-0', 'month_start'=>'5', 'mday_start'=>'1', 'hhmm_start'=>'0h0m', 'month_end'=>'5', 'mday_end'=>'3', 'hhmm_end'=>'0h0m' },
#
#      {'name'=>'rule-month-0', 'mday_start'=>'25', 'hhmm_start'=>'18h30m', 'mday_end'=>'25', 'hhmm_end'=>'20h38m' },
#
#      {'name'=>'rule-day-1', 'hhmm_start'=>'18h30m', 'hhmm_end'=>'20h38m','weekday'=>'*' },
#      {'name'=>'rule-day-2', 'hhmm_start'=>'0h30m', 'hhmm_end'=>'7h30m','weekday'=>'LUN' },
#
#   ]
#};
#----------------------------------------------------------------------------
sub check_calendar {
my ($self,$calendar,$ts) = @_;

	my $hhmm_start_window = 2; #Starts 2 min  before the configured hour+min time. 

   if (! defined $ts) { $ts = time(); }

	#$wday --> 0=Sunday 1=Monday
   my %weekdays = ('SUN'=>'0', 'MON'=>1, 'TUE'=>2, 'WED'=>3, 'THU'=>4, 'FRI'=>5, 'SAT'=>'6');

   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($ts);
   $year += 1900;
   $mon += 1;
   #my $date = ($opts{'date'}) ? $opts{'date'} : sprintf("%04d%02d%02d",$year,$mon,$mday);
   my $hm_now = $hour*60+$min;
   my $weekday_now = $wday;
   my $INRANGE=0;


#     {"name":"inmonth-12", "month":"12", "mday":"1,28", "hhmm_start":"18h0m", "hhmm_end":"19h0m" },
#
#     {"name":"inday-year-0", "month_start":"1", "month_end":"1", "mday_start":"2", "mday_end":"2", "hhmm_start":"18h0m", "hhmm_end":"19h0m" },
#     {"name":"inday-day_period-1", "hhmm_start":"02h00m", "hhmm_end":"06h00m", "weekday":"*" },
#     {"name":"inday-2", "hhmm_start":"19h00m", "hhmm_end":"20h00m", "weekday":"TUE,WED,THU,FRY,SAT" },
#     {"name":"inday-3", "hhmm_start":"17h45m", "hhmm_end":"18h45m", "weekday":"SUN" },

   # Section year
   foreach my $h (@{$calendar}) {

		my $rule_name = $h->{'name'};
		$self->log('debug',"check_calendar:: CHECK RULE $rule_name >> START");

      my ($month,$mdayx,$month_start,$month_end,$mday_start,$mday_end,$hhmm_start,$hhmm_end,$weekday);
      #----------------------------------------------
      if ((exists $h->{'month_start'}) && (exists $h->{'month_end'})) {
         if ($mon<$h->{'month_start'}) {next; }
         if ($mon>$h->{'month_end'}) {next; }
      }
      elsif (exists $h->{'month'}) {
         my @mx = split (',',$h->{'month'});
         my $month_ok=0;
         foreach my $m (@mx) {
            if ($m == $mon) { 
					$month_ok=1; 
					$self->log('debug',"check_calendar:: CHECK RULE $rule_name >> month ok ($m)");
					last; 
				}
         }
         if ($month_ok==0) { next; }
      }
      #----------------------------------------------
      if ((exists $h->{'mday_start'}) && (exists $h->{'mday_end'})) {
         if ($mon<$h->{'mday_start'}) {next; }
         if ($mon>$h->{'mday_end'}) {next; }
      }
      elsif (exists $h->{'mday'}) {
         my @dx = split (',',$h->{'mday'});
         my $mday_ok=0;
         foreach my $d (@dx) {
				$self->log('debug',"check_calendar:: CHECK RULE d=$d mday=$mday");
            if ($d == $mday) { 
					$mday_ok=1; 
					$self->log('debug',"check_calendar:: CHECK RULE $rule_name >> mday ok ($d)");
					last; 
				}
         }
         if ($mday_ok==0) { next; }
      }

      #----------------------------------------------
      my $weekday_ok = 0;
      if (exists $h->{'weekday'}) {
         if ($h->{'weekday'} eq '*') { $weekday_ok = 1; }
         else {
            my @d = split (',',$h->{'weekday'});
            foreach my $wd (@d) {
					$self->log('debug',"check_calendar:: wd=$wd wday=$wday ($weekdays{$wd})");
               if ((exists $weekdays{$wd}) && ($weekdays{$wd} == $wday)) {
                  $weekday_ok = 1;
						$self->log('debug',"check_calendar:: CHECK RULE $rule_name >> weekday ok ($wd)");
                  last;
               }
            }
         }
      }
      else { $weekday_ok = 1; }

      if (! $weekday_ok) { next; }


      #----------------------------------------------

      #----------------------------------------------
		#{"name":"daily-batch", "hhmm_start":"02h00m", "hhmm_end":"06h00m", "weekday":"*" },
      if ($h->{'hhmm_start'} =~ /(\d+)h(\d+)m/) { $hhmm_start = $1*60+$2; }
      if ($h->{'hhmm_end'} =~ /(\d+)h(\d+)m/) { $hhmm_end = $1*60+$2; }

		#Starts before the hour+min settings a value of $hhmm_start_window segs.
		$hhmm_start -= $hhmm_start_window;

      if (($hm_now>=$hhmm_start) && ($hm_now<$hhmm_end)) {
         $INRANGE=1;
			$self->log('debug',"check_calendar:: CHECK RULE **OK** $rule_name >> INRANGE >> hm_now|hhmm_start|hhmm_end ($hm_now|$hhmm_start|$hhmm_end)");
         last;
      }
   }

   return $INRANGE;

}

#----------------------------------------------------------------------------
# check_if_link
#root@cnm:~# mii-tool
#eth0: negotiated 1000baseT-FD flow-control, link ok
#eth0: no link
#root@cnm:~# ifconfig eth0
# TODO OK: UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
# SIN LINK: UP BROADCAST MULTICAST  MTU:1500  Metric:1
# IF DOWN: BROADCAST MULTICAST  MTU:1500  Metric:1
#
# Return: 
#	-1 => UNK
#	0	=>	LINK OK
#	1	=> NO LINK
#	2	=>	LINK OK PERO IF DOWN
#----------------------------------------------------------------------------
sub check_if_link {
my ($self,$ifname)=@_;

   my $rc=-1;
   if (! -f '/sbin/ifconfig') { return $rc; }
	my @data=`/sbin/ifconfig $ifname`;
	foreach my $l (@data) {
		chomp $l;
		# TODO OK: UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
		# SIN LINK: UP BROADCAST MULTICAST  MTU:1500  Metric:1
		# IF DOWN: BROADCAST MULTICAST  MTU:1500  Metric:1
		if ($l=~/BROADCAST/) { 
			if (($l=~/UP /) || ($l=~/UP,/)) {
         	if (($l=~/RUNNING /) || ($l=~/RUNNING,/)) { $rc=0; }
				else { $rc=1; }
			}
			else { $rc=2; }
			last;
		}
	}

	return $rc;
}

#----------------------------------------------------------------------------
# check_operation
# Checks operation rules in operaion file
# Return:
# {'no_alerts'=>0/1, 'no_notifications'=>0/1}
#----------------------------------------------------------------------------
sub check_operation {
my ($self)=@_;

   my %op_mode=('no_alerts'=>0, 'no_notifications'=>0); 
   my $operation_cfg_file = '/cfg/onm.operation';
   if (-f $operation_cfg_file) {
      my $x = $self->slurp_file($operation_cfg_file);
      if ($x =~ /noalerts/i) { $op_mode{'no_alerts'}=1; $op_mode{'no_notifications'}=1; }
      elsif ($x =~ /nonotifications/i) { $op_mode{'no_alerts'}=0; $op_mode{'no_notifications'}=1; }
		$self->log('info', "check_operation:: rule=$x no_alerts=$op_mode{'no_alerts'} no_notifications=$op_mode{'no_notifications'}");
   }
   return \%op_mode;
}

#----------------------------------------------------------------------------
sub reload_syslog {
my ($self)=@_;

	my $rc=0;
	my $RELOAD_FILE='/var/www/html/onm/tmp/syslog.reload';
	if (! -f $RELOAD_FILE) { return $rc; }

   my $cmd='/etc/init.d/syslog-ng reload 2>&1';
   my @x = `$cmd`;

	$rc = unlink $RELOAD_FILE;

	if ($x[0] =~ /Reload system logging: syslog-ng/) {
		chomp $x[0];
		$self->log('info', "reload_syslog:: >> $x[0] [$rc]");
	}
	else {
		foreach my $l (@x) {
			chomp $l;
			$self->log('warning', "reload_syslog:: **WARN** >> $l [$rc]");
		}
	}

	return $rc;
}



#----------------------------------------------------------------------------
sub core_i18n_global {
my ($self)=@_;

	my %data=();
	my $lang_config_file = '/cfg/onm.lang';
	my $lang = 'en';
	if (-f $lang_config_file) {
		my $x = $self->slurp_file($lang_config_file);
		chomp $x;
		if ($x=~/^(\w{2})_\w{2}$/) { $lang = $1; }
	}
	my $lang_data_file = '/opt/cnm/lang/'.$lang.'/'.$lang.'.lang';	

	if (-f $lang_data_file) {
		open (F,"<$lang_data_file");
		while (<F>) {
			chomp;
			my ($k,$v) = split (/\|\|/, $_);
			$data{$k}=$v;
		}
		close F;
	}

	return \%data;
}

#----------------------------------------------------------------------------
sub core_i18n_tag {
my ($self,$txt)=@_;

	my $all = $self->core_i18n_global();
	my $tag = (exists $all->{$txt}) ? $all->{$txt} : '';
	return $tag;

}


#----------------------------------------------------------------------------
sub wait_for_docker  {
my ($self,$filter,$action)=@_;

   my $in_wait=1;
	if ((! defined $filter) || ($filter eq '')) { $filter = 'status=created'; }
	my $max_level = ($filter=~/status=created/) ? 3 : 1;
	my $ts = time();
   while ($in_wait) {

		#docker ps -a -f status=created --format '{{.ID}};{{.CreatedAt}};{{.Names}};{{.Image}};{{.Status}}'
		#72f832e02ee7;2023-04-21 09:25:13 +0200 CEST;crawler.6015.4590;impacket:debian-11.3-slim;Created

		my $cmd = "docker ps -a -f $filter --format '{{.ID}};{{.CreatedAt}};{{.Names}};{{.Image}};{{.Status}}'";
		my @lines = `$cmd`;
		my $nc = scalar(@lines);
		$self->log('info',"wait_for_docker:: DOCKER CHECK $filter (current=$nc | max=$max_level)");
		my $counter = 0;
		my $error = 0;
		my %containers = ();
		my $t;
		foreach my $l (@lines) {
		   chomp $l;
		   my ($cid,$created,$name,$image,$status_raw) = split(';', $l);
   		my $tcreated=$ts;
   		if ($created=~/(\d{4})-(\d{2})-(\d{2}) (\d{2})\:(\d{2})\:(\d{2})/) {
      		my ($year,$mon,$mday,$hour,$min,$sec) = ($1,$2,$3,$4,$5,$6);
		      $year -= 1900;
     		 	$mon -= 1;
      		$tcreated = timelocal( $sec, $min, $hour, $mday, $mon, $year );

				$t = $ts - $tcreated;
				$containers{$cid}=$t;
				$self->log('debug',"wait_for_docker:: -DEBUG- DOCKER CONTAINER $cid with $filter ($t sec.) | name = $name | image=$image | status=$status_raw | created=$created");

  		 	}
			if ($t>=15) {  
				$counter += 1; 
				$self->log('info',"wait_for_docker:: DOCKER CONTAINER SLOW $cid with $filter ($t sec.) | name = $name | image=$image | status=$status_raw | created=$created | $l");
				#if ((defined $action) && ($action eq 'prune')) {
				if ((defined $action) && ($action eq 'prune') && ($filter ne 'status=created')) {

					my $cmd = "docker rm --force $cid 2>&1";
               $self->log('info',"wait_for_docker:: DOCKEREXEC RM $name ($cid) with $filter (time in creation = $t) cmd=$cmd");
               my @rx=`$cmd`;
               foreach my $l (@rx) {
                  chomp $l;
                  $self->log('info',"wait_for_docker:: DOCKEREXEC RM DONE $name ($cid) with $filter RES=$l");
               }
               sleep 1;
				}
			}
		}

      if ($counter < $max_level) { 
			$in_wait=0; 
			next;
		}

      if ((defined $action) && ($action eq 'prune')) {

         if ($filter=~/status=created/) {
            $cmd = "/sbin/init 6";
            $self->log('info',"wait_for_docker:: **RESTART DOCKER** CONTAINERS CREATED = $counter (max_level=$max_level)");
				foreach my $cid (keys %containers) {
					$self->log('info',"wait_for_docker:: CONTAINERS CREATED >> $cid T=$containers{$cid}");
				}
            system($cmd);
            sleep 5;
         }
		}
      else {
         $self->log('info',"wait_for_docker:: DOCKERWAIT Containers=$counter ($filter) max_level=$max_level (error=$error)");
         sleep 2;
      }
		


#      else {
#			
#			if ((defined $action) && ($action eq 'prune')) {
#   			#my $cmd = "docker container prune --force --filter \"until=30s\" 2>&1";
#   			#$self->log('info',"wait_for_docker:: DOCKEREXEC PRUNE (filter=$filter) $cmd");
#   			#my @rx=`$cmd`;
#   			#foreach my $l (@rx) {
#      		#	chomp $l;
#      		#	$self->log('info',"wait_for_docker:: DOCKEREXEC PRUNE >> $l");
#   			#}
#				foreach my $cid (keys %containers) {
#					if ($containers{$cid} < 30) { 
#						$self->log('info',"wait_for_docker:: SALTO $cid T=$containers{$cid}");
#						next; 
#					}
#
#					if ($filter=~/status=created/) {
#						$cmd = "/sbin/init 6";
#						$self->log('info',"wait_for_docker:: **RESTART DOCKER** $cid T=$containers{$cid}");
#						system($cmd);
#						sleep 5;
#					}
#	
#					#$cmd = "docker rm --force $cid 2>&1";
#					#$self->log('info',"wait_for_docker:: DOCKEREXEC RM (pre) $cid");
#					#my @rx=`$cmd`;
#					#foreach my $l (@rx) {
#					#	chomp $l;
#					#	$self->log('info',"wait_for_docker:: DOCKEREXEC RM (post) $cid >> $l");
#					#}
#					#sleep 1;
#				}
#			}
#
#			else {
#         	$self->log('info',"wait_for_docker:: DOCKERWAIT Containers=$counter ($filter) (error=$error)");
#         	sleep 10;
#			}
#      }

   }
}


1;
__END__

