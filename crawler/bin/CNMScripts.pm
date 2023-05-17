#######################################################################################################
# Fichero: CNMScripts
# Incluye soporte basico para scripts desarrollados en PERL
# - Acceso a BBDD
# - syslog
# - Chequeo de puerto tcp
########################################################################################################
package CNMScripts;
use lib '/opt/crawler/bin';
use strict;
use vars qw($VERSION);
use DBI;
use RRDs;
use IO::Socket;
use NetAddr::IP;
use File::Basename;
use Time::HiRes qw(gettimeofday tv_interval);
use Time::Local;
use Sys::Syslog qw(:DEFAULT setlogsock);
use Capture::Tiny ':all';
use Digest::MD5 qw(md5_hex);
use Stdout;
use Data::Dumper;
use JSON;

=pod

=head1 NAME

CNMScripts - Modulo con utilidades que simplifiquen el uso de scripts en CNM


=head1 SYNOPSIS

 use CNMScripts;
 my $script = CNMScripts->new();

 $script->usage();
 $script->test_init();
 $script->test_done();
 $script->print_metric_data();
 $script->log();
 $script->check_tcp_port();
 
 
=head1 DESCRIPTION
 
Modulo para simplificar el desarrollo de scripts en perl para CNM.
 
=cut


#----------------------------------------------------------------------------
$VERSION = '1.00';

#----------------------------------------------------------------------------
%CNMScripts::RESULTS=();
@CNMScripts::RESULTS=();

#----------------------------------------------------------------------------
my %LOG_PRIORITY = ( 'debug' => 0, 'info' => 1, 'notice' => 2, 'warning' => 3,
   						'error' => 4, 'crit' =>5, 'alert' => 6, 'emerg' => 7 );

#----------------------------------------------------------------------------
use constant LOG_NONE => 0;
use constant LOG_SYSLOG => 1;
use constant LOG_STDOUT => 2;
use constant LOG_BOTH => 3;

#----------------------------------------------------------------------------
# Constructor
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

	if (! exists $arg{nologinit}) {
	   #setlogsock('unix');
   	my $basename = basename($0);
   	openlog($basename,'pid','user');
   	$SIG{__WARN__} = \&log_warn;
   	$SIG{__DIE__}  = \&log_die;
	}

bless {
         _db =>$arg{db} || {	'DRIVERNAME' => 'mysql', 'SERVER'=>'localhost', 'PORT'=>3306, 
										'DATABASE'=>'onm', 'USER'=>'onm', },
         _cfg =>$arg{cfg} || '',
         _time_mark =>$arg{time_mark} || [0,0], #secs, microsecs
         _test_results=>$arg{test_results} || \%CNMScripts::RESULTS,
         _app_results=>$arg{app_results} || \@CNMScripts::RESULTS,
         _table_col_descriptor=>$arg{table_col_descriptor} || [],
         _err_str =>$arg{err_str} || '[OK]',
         _err_num =>$arg{err_num} || 0,
			_nologinit => $arg{nologinit} || 1,
			_log_mode => $arg{log_mode} || LOG_SYSLOG,
			_log_level => $arg{log_level} || 'info',
			_timeout => $arg{timeout} || 25,

         _store_dir =>$arg{store_dir} || '/opt/data/app-data/scripts',
         _store_limit =>$arg{store_limit} || 5,
         _store_id =>$arg{store_id} || 'default',

      }, $class;

}

#----------------------------------------------------------------------------
# db
#----------------------------------------------------------------------------
sub db {
my ($self,$db) = @_;
   if (defined $db) {
      $self->{_db}=$db;
   }
   else {
      return $self->{_db};
   }
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
# time_mark
#----------------------------------------------------------------------------
sub time_mark {
my ($self,$time_mark) = @_;
   if (defined $time_mark) {
      $self->{_time_mark}=$time_mark;
   }
   else {
      return $self->{_time_mark};

   }
}

#----------------------------------------------------------------------------
# test_results
#----------------------------------------------------------------------------
sub test_results {
my ($self,$test_results) = @_;
   if (defined $test_results) {
      $self->{_test_results}=$test_results;
   }
   else {
      return $self->{_test_results};

   }
}

#----------------------------------------------------------------------------
# app_results
#----------------------------------------------------------------------------
sub app_results {
my ($self,$app_results) = @_;
   if (defined $app_results) {
      $self->{_app_results}=$app_results;
   }
   else {
      return $self->{_app_results};

   }
}

#----------------------------------------------------------------------------
# table_col_descriptor
#----------------------------------------------------------------------------
sub table_col_descriptor {
my ($self,$table_col_descriptor) = @_;
   if (defined $table_col_descriptor) {
      $self->{_table_col_descriptor}=$table_col_descriptor;
   }
   else {
      return $self->{_table_col_descriptor};

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
# nologinit
#----------------------------------------------------------------------------
sub nologinit {
my ($self,$nologinit) = @_;
   if (defined $nologinit) {
      $self->{_nologinit}=$nologinit;
   }
   else {
      return $self->{_nologinit};
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
# timeout
#----------------------------------------------------------------------------
sub timeout {
my ($self,$timeout) = @_;
   if (defined $timeout) {
      $self->{_timeout}=$timeout;
   }
   else {
      return $self->{_timeout};
   }
}


#----------------------------------------------------------------------------
# store_dir
#----------------------------------------------------------------------------
sub store_dir {
my ($self,$store_dir) = @_;
   if (defined $store_dir) {
      $self->{_store_dir}=$store_dir;
   }
   else {
      return $self->{_store_dir};
   }
}

#----------------------------------------------------------------------------
# store_limit
#----------------------------------------------------------------------------
sub store_limit {
my ($self,$store_limit) = @_;
   if (defined $store_limit) {
      $self->{_store_limit}=$store_limit;
   }
   else {
      return $self->{_store_limit};
   }
}

#----------------------------------------------------------------------------
# store_id
#----------------------------------------------------------------------------
sub store_id {
my ($self,$store_id) = @_;
   if (defined $store_id) {
      $self->{_store_id}=$store_id;
   }
   else {
      return $self->{_store_id};
   }
}


#----------------------------------------------------------------------------
# set_store_id
# Genera un store_id (subdirectorio a partir de  store_dir)
# Se basa en:
# script_name
# params
# iid
#----------------------------------------------------------------------------
sub set_store_id {
my ($self,$iid) = @_;

#	my $key=basename($0);
#	foreach my $k (sort keys %$opts) {
#		$key.=$k.$opts->{$k};
#	}
#	$key.=$iid;

	my $key = basename($0).$iid;
	my $store_id = substr(md5_hex($key),0,10);
	$self->store_id($store_id);
	return $store_id;

}


#----------------------------------------------------------------------------
# Destructor
#----------------------------------------------------------------------------
#sub DESTROY {
#my $self = shift;
# 	if ($self->start_flag()) {
#  	 	$self->log('notice',"Ending $0 ($!)....");
#   	$> = $<;  # restaurando privilegios
#	}
#}


#--------------------------------------------------------------------------------------
sub dbConnect
{
my ($self)=@_;

	my $dbh=undef;
	my $db=$self->db();
   my $dsn = "DBI:mysql:database=$$db{DATABASE};host=$$db{SERVER};port=$$db{PORT};mysql_connect_timeout=5";
	$self->err_num(0);
	$self->err_str('[OK]');
	my $db_pwd = $self->get_db_credentials();

   eval {
      $dbh = DBI->connect($dsn,$$db{USER},$db_pwd,{PrintError => 1,RaiseError => 1,AutoCommit => 1}) ;
      $self->err_str($DBI::errstr);
      $self->err_num($DBI::err);

   };
   if ($@) {

      $self->err_str($@);
      $self->err_num(100);
   }

   return $dbh;
}

#--------------------------------------------------------------------------------------
sub dbDisconnect
{
my ($self,$dbh)=@_;

   my $rc=$dbh->disconnect;
}

#--------------------------------------------------------------------------------------
sub dbSelectAll
{
my ($self, $dbh, $sql, $key_val)=@_;
my $H=undef;

   $self->err_num(0);
   $self->err_str('[OK]');

   eval {
		if ((! $key_val) || ($key_val eq '')) {
			$H=$dbh->selectall_arrayref($sql);
      }
		else {
         $H=$dbh->selectall_hashref($sql, $key_val);
      }
	};

   if ($@) {

      $self->err_str($DBI::errstr);
      $self->err_num($DBI::err);
   }

   return $H;
}

#--------------------------------------------------------------------------------------
sub dbCmd
{
my($self,$dbh,$sql)=@_;
my @rows=();

   $self->err_num(0);
   $self->err_str('[OK]');

eval {

   my $sth = $dbh->prepare(qq{$sql});
   my $rc=$sth->execute();
   @rows=$sth->fetchrow_array();
};

if ($@) {

      $self->err_str($DBI::errstr);
      $self->err_num($DBI::err);
}

   return \@rows;
}


=head1 METHODS

=head2 Para gestionar los datos obtenidos

=over 1

=item B<$script-E<gt>test_init($tag,$descr)>

 En la propiedad test_results de la clase CNMScript se almacena un hash indexado por tag con los datos de cada test. Dicho hash es del tipo:
 tag => { tag=>xxx, descr=>'Test para hacer ...', result=>'unk|ok|nok', done=>0|1
 test_init inicializa los datos asociados a un detreminado tag. El tag y la descripcion son parametros y result se inicialioza a 'unk' y done a 0.

=cut


#----------------------------------------------------------------------------
# test_init
#----------------------------------------------------------------------------
sub test_init {
my ($self,$tag,$descr)=@_;

	my $results=$self->test_results();
	$results->{$tag}={'tag'=>$tag, 'descr'=>$descr, 'result'=>'unk', 'done'=>0};
	$self->test_results($results);
}


=item B<$script-E<gt>test_done($tag,$result)>

 Actualiza el resultado de un determinado tag con el resultado pasado como parametro. Tambien pone done a 1.
=cut

#----------------------------------------------------------------------------
# test_done
#----------------------------------------------------------------------------
sub test_done {
my ($self,$tag,$result)=@_;

   my $results=$self->test_results();

	if (exists $results->{$tag}) {
		$results->{$tag}->{'tag'}=$tag;
		$results->{$tag}->{'result'}=$result;
		$results->{$tag}->{'done'}=1;
	}
	else { $results->{$tag}={'tag'=>$tag, 'result'=>$result, 'done'=>1}; }

   $self->test_results($results);
}


=item B<$script-E<gt>print_metric_all($data)>

 Escribe todos los resultados de las metricas del script.
=cut

#----------------------------------------------------------------------------
# print_metric_all
#----------------------------------------------------------------------------
sub print_metric_all {
my ($self,$metric_data,$metric_info)=@_;

	foreach my $tag (sort keys %$metric_data) {
	   $self->test_done($tag,$metric_data->{$tag});
	}
   $self->print_metric_data();

	if ((!defined $metric_info)||(ref($metric_info) ne 'HASH')) { return; } 

   foreach my $tag (sort keys %$metric_info) {
		print $tag.' '.$metric_info->{$tag}."\n";
   }


}

=item B<$script-E<gt>app_init($tag,$descr)>

 En la propiedad test_results de la clase CNMScript se almacena un hash cuyas claves son las columnas de los resultados de ejecutar una aplicacion contra un determinado host, como por ejemplo:
 {kernel=>zzzz, uptime=>xxx, users=>2, load1=>0.03, load5=>0.02, load15=>0.00}

=cut


#----------------------------------------------------------------------------
# app_init
#----------------------------------------------------------------------------
sub app_init {
my ($self)=@_;

	%CNMScripts::RESULTS=();
   $self->test_results(\%CNMScripts::RESULTS);
}

#----------------------------------------------------------------------------
# app_merge_data
#----------------------------------------------------------------------------
sub app_merge_data {
my ($self,$data)=@_;

	my $results=$self->test_results();
	foreach my $k (keys %$data) { $results->{$k}=$data->{$k}; }
	$self->test_results($results);
}

#----------------------------------------------------------------------------
# app_done
#----------------------------------------------------------------------------
sub app_done {
my ($self)=@_;

   my $results=$self->test_results();

	my $app_results=$self->app_results();
	push @$app_results, $results;
	$self->app_results($app_results);

	return $app_results;
}

=item B<$script-E<gt>time_lapse()>

 Almacena en la propiedad time_mark de la clase el timestamp (secs, microsecs).
 Devuelve la diferencia de tiempo entre el valor actual y el almacenado previamente en time_mark.
=cut

#----------------------------------------------------------------------------
# time_lapse
#----------------------------------------------------------------------------
sub time_lapse {
my ($self,$ts)=@_;

	my $t0=$self->time_mark();
	my $t1=[gettimeofday];
  	my $elapsed = tv_interval ( $t0, $t1);
   my $elapsed3 = sprintf("%.6f", $elapsed);
	$self->time_mark($t1);
	return $elapsed3;

}

=item B<$script-E<gt>time2date()>

 Devuelve en formato "$year/$mon/$mday  $hour:$min:$sec" el valor del timestamp que se pasa como parametro.
 Si no se le pasa ningun timestamp considera el instante actual.
=cut

#----------------------------------------------------------------------------
# time2date
#----------------------------------------------------------------------------
sub time2date {
my ($self,$ts)=@_;

   if (! $ts) { $ts=time(); }
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($ts);
   $year += 1900;
   $mon += 1;
   my $datef=sprintf("%02d/%02d/%02d %02d:%02d:%02d",$year,$mon,$mday,$hour,$min,$sec);
   #return  "$year/$mon/$mday  $hour:$min:$sec";
   return  $datef;
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


=item B<$script-E<gt>check_tcp_port($ip,$port,$timeout)>

 Comprueba si responde un determinado puerto TCP. Si responde, devuelve un array con dos valore ($rc, $lapse)
 $rc: 1=>ok, 0=>nok
 $lapse es la latencia. Si no responde devuelve 'U'.
=cut


#----------------------------------------------------------------------------
# check_tcp_port
#----------------------------------------------------------------------------
sub check_tcp_port {
my ($self,$ip,$port,$timeout)=@_;

	$self->time_lapse();
   $ip=~/(\S+)/;
   my $socket = IO::Socket::INET->new(PeerAddr=>$1, PeerPort=>$port, Timeout=>$timeout);

	my $elapsed = $self->time_lapse();
	if (defined $socket) {return (1,$elapsed); }
	else { return (0,'U'); }

}


#----------------------------------------------------------------------------
# SYSLOG
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
=back

=head2 Para escribir a syslog

=over 1

=item B<$script-E<gt>init_log()>

 Inicializa el acceso a la facility de syslog especificada como parametro.
 En caso de no especificar una facility, se utiliza "user".
=cut

#----------------------------------------------------------------------------
# Funcion: init_log
# Descripcion: Inicializa el volcado a syslog en la facility FACILITY. Tambien
# redirige los warnings y errores de perl
#----------------------------------------------------------------------------
sub init_log {
my ($self,$facility)=@_;

	if (! $facility) { $facility='user'; }
   #setlogsock('unix');
   my $basename = basename($0);

   openlog($basename,'pid',$facility);
   $SIG{__WARN__} = \&log_warn;
   $SIG{__DIE__}  = \&log_die;
}

#----------------------------------------------------------------------------
# Funcion: _msg
# Descripcion: Funcion auxiliar para componer el mensaje
#----------------------------------------------------------------------------
sub _msg {
  my $msg = join('',@_) || "Registro de log";
  my ($pack,$filename,$line) = caller(0);
  $msg .= " en $filename linea $line\n" unless $msg =~ /\n$/;
  $msg;
}

#----------------------------------------------------------------------------
# Funcion: log_warn
# Descripcion: Se ocupa de registrar mensajes de warning
#----------------------------------------------------------------------------
sub log_warn   { eval { syslog('warning','%s',_msg(@_)); }; }

#----------------------------------------------------------------------------
# Funcion: log_die
# Descripcion: Se ocupa de registrar mensajes de terminacion del programa
#----------------------------------------------------------------------------
sub log_die {
  syslog('crit','%s',_msg(@_)) unless $^S;
  die @_;
}


=item B<$script-E<gt>log($level,@arg)>

 Permite escribir a syslog en /var/log/scripts.log
 $level = info
 @arg contiene el mensaje o lista de mensajes.
=cut

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

	#alert, crit, debug, emerg, err, error (deprecated synonym for err), info, notice, panic (deprecated synonym for emerg), warning, warn (deprecated synonym for warning)
   if ( ($level ne 'debug') && ($level ne 'notice') && ($level ne 'warning') && ($level ne 'crit') && ($level ne 'debug'))  {$level='info';}
   my $msg = join('',@arg) || "Logging ...";

   my ($filename,$line,$myfx) = (caller(0))[1..3];
	if (($level eq 'warning') || ($level eq 'error') || ($level eq 'crit')) {
   	$msg .= " ($myfx >> $filename $line)\n" unless $msg =~ /\n$/;
	}

	$msg=~s/\"/ /g;
	$msg =~ s/[^[:ascii:]]/_/g;

	chomp $msg;
   if ( $mode & 1) { syslog($level,'%s',$msg); }
   if ( $mode & 2) { print "$msg"; }

}

=back

=head2 Para conectividad TCP/IP 

=over 1

=item B<$script-E<gt>expand_subnet()>

 Valida un rango de ip y devuelve un vector con sus valores
 El rango de IPs se puede especificar de la forma:
 1. a.b.c.d./r   => LIMITADO A /12
 2. a.b.c.x-y
 3. a.b.c.d
 4. a.b.c.*
 5. a.b.*.*
=cut

#----------------------------------------------------------------------------
# RANGOS IP
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
# expand_subnet
#-------------------------------------------------------------------------------------------
# Valida un rango de ip y devuelve un vector con sus valores
# El rango de IPs se puede especificar de la forma:
# 1. a.b.c.d./r	=> LIMITADO A /12
# 2. a.b.c.x-y
# 3. a.b.c.d
# 4. a.b.c.*
# 5. a.b.*.*
# 6. a.*.*.*   	=> LO ELIMINO PORQUE LO DEJA SIN MEMORIA (limite 65535)
#-------------------------------------------------------------------------------------------
sub expand_subnet {
my ($self,$r1)=@_;

	my $range=undef;
   my @output_ranges=();
   my $input_ranges=$r1;
   if (ref($r1) ne "ARRAY") { 
		my @aa=split(',',$r1);
		$input_ranges=\@aa; 
	}

   foreach my $r (@$input_ranges) {

      $self->log('debug',"expand_subnet:: ....... RANGO IN=$r");

      #a.b.c.d./r
      if ($r=~/^(\d+\.\d+\.\d+\.\d+\/)(\d+)$/) {
         if ($2<12) { 
				$r=$1.12; 
				$self->log('info',"expand_subnet:: **LIMITO EL RANGO A /12** IN=$r");
			}
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
      elsif ($r=~/(\d+)\.\*\.\*\.\*/) {
			$self->log('info',"expand_subnet:: **NO CALCULO CLASE A** IN=$r");
#
#        # Una clase A lo deja sin memoria. Habria que partirlo en n clases B
#         $r=$1.'.0.0.0/8';
#        my $nip = new NetAddr::IP($r);
#        $range = $nip->hostenumref();
		}
      else {
         $self->log('info',"expand_subnet:: **RANGO INCORRECTO** IN=$r");
         next;
      }

      $self->log('debug',"expand_subnet:: RANGO IN=$r OUT=@$range");

		foreach my $r (@$range) {
			if ($r=~/^(\d+\.\d+\.\d+\.\d+)\/32$/) { push @output_ranges, $1; }
		}
   }

   return \@output_ranges;
}

#----------------------------------------------------------------------------
sub get_cnm_credential {
my ($self,$ip,$type)=@_;

   my $dbh = $self->dbConnect();
   my $sql="CALL sp_cnms_get_credential('$ip','$type');";
   if ($type eq 'snmp') { $sql="CALL sp_cnms_get_snmp_credential('$ip');"; }
   my $lines = $self->dbCmd($dbh, $sql);
   $self->dbDisconnect($dbh);

   if ($type eq 'snmp') {
      return {'type'=>'snmp', 'version'=>$lines->[1], 'community'=>$lines->[2], 'profile_name'=>$lines->[3], 'sec_name'=>$lines->[4], 'sec_level'=>$lines->[5], 'auth_proto'=>$lines->[6], 'auth_pass'=>$lines->[7], 'priv_proto'=>$lines->[8], 'priv_pass'=>$lines->[9] } ;
   }
   else {
      return {'type'=>$lines->[3], 'user'=>$lines->[4], 'pwd'=>$lines->[5], 'scheme'=>$lines->[6], 'port'=>$lines->[7], 'key_file'=>$lines->[8], 'passphrase'=>$lines->[9] } ;
   }
}

#----------------------------------------------------------------------------
sub get_name_from_ip {
my ($self,$ip)=@_;

	if (exists $ENV{'CNM_TAG_IP'}) { $ip=$ENV{'CNM_TAG_IP'}; }

   my $sql="SELECT name,domain FROM devices WHERE ip='$ip'";
   my $dbh = $self->dbConnect();
   my $lines = $self->dbSelectAll($dbh, $sql);
   $self->dbDisconnect($dbh);

	my $n=$lines->[0][0];
	$n=~s/^https*\:\/\/(\S+?)\:*\d*$/$1/;
	my $d=$lines->[0][1];
	if ($d=~/\w+/) { $n.='.'.$d; }
	
	$self->log('info',"****get_name_from_ip******::env=$ENV{'CNM_TAG_IP'} -- sql=$sql R=$lines->[0][0] -- n=$n");
#print $lines->[0][0]." n=$n\n";

	return $n;
}

#----------------------------------------------------------------------------
# provision_device_data
# Registra los valores de los atributos del script regitrados para una IP
# $ip  		IP del equipo sobre elque se registran los atributos
# $script  	Nombre del escript
# $data  	Ref. a hash con los datos. Se buscan las claves dadas de alta en 
#				el sistema como atributos y se actualiza elcorrespondiente campo de usuario.
#----------------------------------------------------------------------------
sub provision_device_data {
my ($self,$ip,$script,$data)=@_;

   if (exists $ENV{'CNM_TAG_IP'}) { $ip=$ENV{'CNM_TAG_IP'}; }

   my $sql="SELECT attr,col FROM attr2db WHERE script='$script' AND tab='devices'";
   my $dbh = $self->dbConnect();
   my $lines = $self->dbSelectAll($dbh, $sql);

	my @device_custom=();
	foreach my $h (@$lines) {
		if ($h->[1] !~ /columna/) { next; }
		if (exists $data->{$h->[0]}) {
			push @device_custom, $h->[1].'="'.$data->{$h->[0]}.'"'; 
		}
 	}

	if (scalar (@device_custom) == 0) { 
		$self->dbDisconnect($dbh);
		return; 
	}

	$sql="SELECT id_dev FROM devices WHERE ip='$ip'";
	$lines = $self->dbSelectAll($dbh, $sql);
	my $id_dev=$lines->[0][0];

	my $set = join(',', @device_custom);
	$sql="UPDATE devices_custom_data SET $set WHERE id_dev=$id_dev";
  	$lines = $self->dbCmd($dbh, $sql);
   $self->dbDisconnect($dbh);
		
   $self->log('info',"register:: ip=$ip >> $set");

   return;
}

=back

=head2 Para genear los formatos de salida

=over 1

=item B<$script-E<gt>print_metric_data()>

 Imprime los resultados de la metrica en formato <tag> Descripcion = valor
 Los datos se proporcionan en un hash de datos:
 a. Si la metrica es sin instancias
    { 'tag1'=> {'tag' => '001', 'done' => 1, 'result' => 1800, 'descr'=>'Disco C: usado' }
      'tag1'=> {'tag' => '001', 'done' => 1, 'result' => 1200, 'descr'=>'Disco C: libre' } }
 
 b. Si la metrica es con instancias
    { 'tag1'=> {'tag' => '001', 'done' => 1, 'result' => { 'C:'=>1800, 'D:'=>2800 }, 'descr'=>'Disco usado' }
      'tag1'=> {'tag' => '001', 'done' => 1, 'result' => { 'C:'=>1200, 'D:'=>800 }, 'descr'=>'Disco libre' } }

=cut

#----------------------------------------------------------------------------
sub print_metric_data {
my ($self,$data)=@_;

	if (!defined $data) { $data=$self->test_results(); }

	foreach my $tag (sort keys %$data) {
		my $r=$data->{$tag}->{'result'};
		if (ref($r) eq 'HASH') {
			foreach my $k (sort keys (%$r)) {
				print '<'.$tag.'.'.$k.'> '.$data->{$tag}->{'descr'}.' - '.$k.' = '.$r->{$k}."\n";
			}
		}
		else {
			print '<'.$tag.'> '.$data->{$tag}->{'descr'}.' = '.$r."\n";
		}
	}
}



#----------------------------------------------------------------------------
sub print_app_table {
my ($self,$results,$params)=@_;

	my $mode = (exists $params->{'mode'}) ? $params->{'mode'} : 'table';
	my $ip = $self->host();
	if (! defined $results) { $results=$self->app_results(); }

	if ($mode eq 'txt') {
		print "IP:\t$ip\n"; 
		
		foreach my $h (@$results) {
			foreach my $campo (sort keys %$h) {
				print "$campo:\t".$h->{$campo}."\n";
			}
			print "\n";
		}
		return;
	}

	elsif ($mode eq 'csv') {

		#dumph2csv : hash->csv
		print join (',', sort keys %{$results->[0]})."\n";
		foreach my $h (@$results) {
			my @line = ();
			foreach my $k (sort keys %$h) {
				my $val = $h->{$k};
				if ($val=~/\s+/) { push @line, '"'.$h->{$k}.'"'; }
				else { push @line, $h->{$k}; }
			}
			print join (',', @line)."\n";
		}
		return;

	}

	my $table_col_descriptor = $self->table_col_descriptor();
	my %col_map=();
	foreach my $h (@$table_col_descriptor) {
		$col_map{$h->{'name_col'}} = $h->{'label'};
	}

   my $ts=time;
   my $TIMEDATE=$self->time2date($ts);

   my $json = dumph2json($table_col_descriptor, \%col_map, $results, $TIMEDATE);
   print "$json\n";


}


=item B<$script-E<gt>summarize_oknok_metrics()>

 Genera una nueva metrica con la sumarizacion en base a ok, nok, unk y done de un grupo de metricas que se pasa como parametro.

=cut

#----------------------------------------------------------------------------
sub summarize_oknok_metrics {
my ($self,$new_tag,$descr,$tags)=@_;

	my $results=$self->test_results();
	$self->test_init($new_tag,$descr);
	my %result=('ok'=>0, 'nok'=>0, 'unk'=>0, 'done'=>0);
   foreach my $tag (@$tags) {
		my $r=$results->{$tag}->{'result'};
		if ( exists $result{$r}) { $result{$r} +=1; }
		if ($results->{$tag}->{'done'}) { $result{'done'} +=1; }
   }

	$self->test_done($new_tag,\%result);
}


=item B<$script-E<gt>print_app_data()>

 Imprime los datos de una aplicación contenidos en un hash con la siguiente estructura:
 %results = ( 
    'cmd1' => {'stdout'=>'xxx', 'stderr'=>'yyy', 'rc'=>z} ,
    'cmd2' => {'stdout'=>'xxx', 'stderr'=>'yyy', 'rc'=>z} ,
 )
 El formato se especifica en el parametro $format (json|txt|xml).
=cut

#----------------------------------------------------------------------------
sub print_app_data {
my ($self,$ip,$results,$format)=@_;

	my @vector_data=();  #  Caso JSON
	my $i=1;
   foreach my $cmd (sort keys %$results) {

		my $stdout=$results->{$cmd}->{'stdout'};
		my $stderr=$results->{$cmd}->{'stderr'};
		if ($format eq 'txt') {
			print "[$i] $cmd\n$stdout\n";
	   	if ($stderr ne '') {
      		print STDERR "*******STDERR*****\n$stderr\n";
   		}
			$i+=1;
		}	

		elsif ($format eq 'syslog') {

      	my @lines1 = split(/\n/, $stdout);
      	foreach my $l (@lines1) { $self->log('info', $l); }

         my @lines2 = split(/\n/, $stderr);
         foreach my $l (@lines2) { $self->log('info', $l); }

   	}

      elsif ($format eq 'json') {

			push @vector_data,{'cmd'=>$cmd, 'stdout'=>$stdout, 'stderr'=>$stderr};
      }

		else {


   		my @COL_KEYS = (
      		{'name_col'=>'descr', 'width'=>'60', 'sort'=>'str', 'align'=>'left', 'filter'=>'#text_filter'},
   		);

  	 		my %COL_MAP=('descr'=>'Description');


   		my $ts=time;
   		my $TIMEDATE=$self->time2date($ts);

   		my %results_vector=();
   		my %line=('descr'=>$stdout);
   		$results_vector{$ip}=[\%line];

   		my $xml = dumph2xml(\@COL_KEYS, \%COL_MAP, \%results_vector, $TIMEDATE);
   		print "$xml\n";

		}
	}



	if ($format eq 'json') {

      my @COL_KEYS = (
         {'name_col'=>'cmd', 'label'=>'CMD', 'width'=>'*', 'sort'=>'str', 'align'=>'left', 'filter'=>'#text_filter'},
         {'name_col'=>'stdout', 'label'=>'Results', 'width'=>'*', 'sort'=>'str', 'align'=>'left', 'filter'=>'#text_filter'},
         {'name_col'=>'stderr', 'label'=>'Errors', 'width'=>'*', 'sort'=>'str', 'align'=>'left', 'filter'=>'#text_filter'},
      );

      #my %COL_MAP=('ts'=>'Date/Time', 'ip'=>'IP', 'descr'=>'Description');
      my %COL_MAP=('cmd'=>'CMD', 'stdout'=>'Results', 'stderr'=>'Errors');

      my $ts=time;
      my $TIMEDATE=$self->time2date($ts);

		my $json = dumph2json(\@COL_KEYS, \%COL_MAP, \@vector_data, $TIMEDATE);
		print "$json\n";
	}

}

=item B<$script-E<gt>cmd()>

 Ejecuta los comandos especificados como parametros en local.
 $cmd_vector: Ref a array o a hash con los comandos a ejecutar.
 Resultado:   Ref a hash:
              a. Si $cmd_vector es array:
                    Las claves son los comandos
                    Los valores son otra ref. a hash con el resultado (stdout y stderr)
              a. Si $cmd_vector es hash:
                    Las claves son las claves de $cmd_vector
                    Los valores son otra ref. a hash con el resultado (stdout y stderr)

=cut

#----------------------------------------------------------------------------
# cmd
# Ejecuta los comandos especificados como parametros en local.
# $cmd_vector: Ref a array o a hash con los comandos a ejecutar.
# Resultado:   Ref a hash:
#              a. Si $cmd_vector es array:
#                    Las claves son los comandos
#                    Los valores son otra ref. a hash con el resultado (stdout y stderr)
#              a. Si $cmd_vector es hash:
#                    Las claves son las claves de $cmd_vector
#                    Los valores son otra ref. a hash con el resultado (stdout y stderr)
#----------------------------------------------------------------------------
sub cmd {
my ($self,$cmd_vector) = @_;

   my %results=();
   $Capture::Tiny::TIMEOUT=300;
   if (ref($cmd_vector) eq 'HASH') {
      foreach my $key (sort keys %$cmd_vector) {

         my $cmd = $cmd_vector->{$key};
	      my ($stdout, $stderr, $exit) = capture {   system( $cmd ); };
         chomp $stdout;
         chomp $stderr;
         $results{$key}->{'stdout'} = $stdout;
         $results{$key}->{'stderr'} = $stderr;
      }
   }
   else {
      foreach my $cmd (@$cmd_vector) {

			my ($stdout, $stderr, $exit) = capture {   system( $cmd ); };
         chomp $stdout;
         chomp $stderr;
         $results{$cmd}->{'stdout'} = $stdout;
         $results{$cmd}->{'stderr'} = $stderr;
      }
   }
   return \%results;
}

#----------------------------------------------------------------------------
# STORE
#----------------------------------------------------------------------------
=back

=head2 Para gestionar un almacen local de datos

=over 1

=item B<$script-E<gt>mkstore($level)>

 Crea un almacen de datos que puede ser utilizado por el script. 
 Se trata de un subdirectorio por debajo del directorio de datos que pueden usar los scripts.
 El directorio de datos se define a partir de los atributos store_dir y store_id de la clase. Si se utilizan los valores por defecto, el directorio de datos es '/opt/data/app-data/scripts/default'. A partir de este nivel, el subdirectorio de trabajo se define en el parametro $level.
 El valor devuelto es la ruta completa al directorio de trabajo.
=cut

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
sub mkstore {
my ($self,$level)=@_;

   my $store_dir = $self->store_dir() .'/'.$self->store_id();
	if ($level) { $store_dir.='/'.$level; }
   if (! -d $store_dir) {  `/bin/mkdir -p $store_dir`;  }
	return $store_dir;

}

=item B<$script-E<gt>rmfiles($level,$pattern)>

 Elimina del directorio de trabajo los ficheros especificados por $pattern 
=cut

#----------------------------------------------------------------------------
sub rmfiles {
my ($self,$level,$pattern)=@_;

   my $store_dir = $self->store_dir() .'/'.$self->store_id();
   if ($level) { $store_dir.='/'.$level; }

	opendir(DIR, $store_dir);
	#my @files = grep { /18701/ && -f } readdir( DIR );
	my @files = grep { /^$pattern/ } readdir( DIR );
	closedir(DIR);

	foreach my $f (@files) {
  		unlink $store_dir.'/'.$f;
	}


}

=item B<$script-E<gt>rmdata()>

 Elimina los ficheros del directorio de trabajo.
=cut

#----------------------------------------------------------------------------
sub rmstore {
my ($self,$level)=@_;

   my $store_dir = $self->store_dir() .'/'.$self->store_id();
	if ($level) { $store_dir.='/'.$level; }
   if (! -d $store_dir) {  `/bin/mkdir -p $store_dir`;  }

	#unlink
}

=item B<$script-E<gt>files_in_store()>

 Devuelve un array con los ficheros almacenados en el directorio de trabajo.
=cut

#----------------------------------------------------------------------------
sub files_in_store  {
my ($self,$level)=@_;

   my $store_dir = $self->store_dir() .'/'.$self->store_id();
	if ($level) { $store_dir.='/'.$level; }

   #--------------------------------------------------------------------------------------
   # Se obtinen los ficheros almacenados
   if (! -d $store_dir) { return []; }
   opendir (DIR,$store_dir);
   my @files =  grep { -f "$store_dir/$_" }   readdir(DIR);
   closedir(DIR);
   my @sorted_files = sort { $b cmp $a } @files;
   return \@sorted_files;
}

=item B<$script-E<gt>file_to_store()>

 Almacena un fichero en el store getionando que nunca haya mas de max_files
=cut

#----------------------------------------------------------------------------
sub file_to_store {
my ($self,$level,$file)=@_;

   my $store_dir = $self->store_dir() .'/'.$self->store_id();
	if ($level) { $store_dir.='/'.$level; }
   if (! -d $store_dir) {  `/bin/mkdir -p $store_dir`;  }


   my $stored_files = $self->files_in_store();

   #--------------------------------------------------------------------------------------
   # Se eliminan los que sobran (segun el limite de almacenamiento definido)
   my $NFILES = scalar (@$stored_files);
	my $store_limit=$self->store_limit();
   my $extra = $NFILES-$store_limit;
   while ($extra>=0) {
      my $f = pop @$stored_files;
      unlink "$store_dir/$f";
      $extra-=1;
   }

	my $ts=time;
   my $file_path = $store_dir.'/'.$ts.'-'.$file;
	return $file_path;

#   open (F,">$file_path");
#   foreach my $l (@$data) { print F $l; }
#   close F;

}

=item B<$script-E<gt>set_store_status()>

 Almacena un fichero de estado en el store
=cut

#----------------------------------------------------------------------------
sub set_store_status {
my ($self,$level,$data,$filename)=@_;

   my $store_dir = $self->store_dir() .'/'.$self->store_id();
   if ($level) { $store_dir.='/'.$level; }
   if (! -d $store_dir) {  `/bin/mkdir -p $store_dir`;  }

	my $file_status = (defined $filename) ? "$store_dir/$filename" : "$store_dir/status";
   open (F,">$file_status");
	while (my ($k,$v) = each %$data) {
		print F "$k=$v\n";
	}
	close F;
}

=item B<$script-E<gt>get_store_status()>

 Almacena un fichero de estado en el store
=cut

#----------------------------------------------------------------------------
sub get_store_status {
my ($self,$level,$filename)=@_;

   my $store_dir = $self->store_dir() .'/'.$self->store_id();
   if ($level) { $store_dir.='/'.$level; }

	my $file = (defined $filename) ? "$store_dir/$filename" : "$store_dir/status";
	if (! -f $file) { return {}; }

	my %data=();
   open (F,"<$file");
   while (<F>) {
		chomp;
		my ($k,$v) = split(/\s*=\s*/, $_);
      $data{$k}=$v;
   }
   close F;
	return \%data;

}


=item B<$script-E<gt>endpoint()>

 Permite hacer peticiones a un API REST usando curl.
=cut

#-----------------------------------------------------------------------------------
sub endpoint {
my ($self,$data) = @_;

	my $url =  $data->{'url'};
	my $request = $data->{'request'};
	my $headers = $data->{'headers'};
	my $params = $data->{'params'};


   my $cmd_base = 'curl -s -X GET ';
	if ($request =~/post/i) { $cmd_base = 'curl -s -X POST '; }

   my $headers_str = '';
   foreach my $k (sort keys %$headers) {
      my $x = '-H "'.$k.': '.$headers->{$k}.'" ';
      $headers_str .=  $x;
   }

   my $params_str = '';
   if (scalar keys %$params > 0) {
      $params_str = ' -d ';
      $params_str .= "'".encode_json($params)."'";
   }

   my $cmd = $cmd_base.$headers_str.' '.$params_str.' '.$url;

	$self->log('info',"endpoint:: $cmd");

   my $response = `$cmd`;
   return $response;

}

=item B<$script-E<gt>endpoint()>

 Obtiene datos de un fichero RRD
=cut

#-----------------------------------------------------------------------------------
sub fetch_avg_rrd  {
my ($self,$rrd,$lapse)=@_;
my $rc=undef;

	my ($start,$end) = ('-31d','-30d');
	if ($lapse =~ /(\d+)d/) {
		my $s = $1+1;
		$start = '-'.$s.'d';
		$end = '-'.$1.'d';
	}

#/opt/rrdtool/bin/rrdtool fetch /opt/data/rrd/elements/0000000237/custom_89dccce8-H2.rrd AVERAGE -s -31d -e -30d
	my $cmd = "/opt/rrdtool/bin/rrdtool fetch $rrd AVERAGE -s $start -e $end";
	print "$cmd\n";
   $self->log('debug',"fetch_avg_rrd::[DEBUG] FETCH CMD=$cmd");

	my @lines = `$cmd`;
	my $total = 0;
	my @avg = ();
	my @sum = ();
	foreach my $l (@lines) {
		chomp $l;
		if ($l=~/value/) {
			$l=~s/^\s+(value.*)$/$1/;
			my @vals = split(/\s+/,$l);
			foreach my $v (@vals) { push @sum,0; }
			next;
		}
		#1579459500: 8.0000000000e+00
		my @data = split(/\s+/,$l);
		shift @data;
		my $i=0;
		foreach my $v (@data) { 
			if ($v=~/nan/) { next; }
			$sum[$i]+=$v;
			$i++;
		}
		$total+=1;
#print "$l\n";
	}

	my $i=0;
	foreach my $v (@sum) { $avg[$i] = $v/$total; }
	$self->log('debug',"fetch_avg_rrd::[DEBUG] FETCH TOTAL=$total AVGs=@avg");
   return \@avg;
}


=item B<$script-E<gt>endpoint()>

 Obtiene datos de un fichero RRD
=cut

#-----------------------------------------------------------------------------------
sub wait_for_docker  {
my ($self)=@_;

	my $in_wait=1;
	my $CONCURRENCY_LIMIT = 3;
	my $ppid = getppid();
	my $ppname = `cat /proc/$ppid/cmdline | tr "\\0" " "`;

	while ($in_wait) {

		my $cmd = "docker ps -a -f 'status=created' --format '{{.ID}};{{.CreatedAt}};{{.Names}};{{.Image}};{{.Status}}'";
      my @lines = `$cmd`;
      my $counter = scalar(@lines);

      if ($counter < $CONCURRENCY_LIMIT) { $in_wait=0; }
		else { 
			$self->log('info',"wait_for_docker:: DOCKERWAIT [$ppname] Containers blocking = $counter");
			sleep 2; 
		}	
	}
}

#--------------------------------------------------------------------
# grep_patterns
# Crea las cadenas necesarias para parsear el log lapse secs, desde el instante actual
# Si tnow = Jul 14 20:26:10 y lapse=300 seran:
# Jul 14 20:21|Jul 14 20:22|Jul 14 20:23|Jul 14 20:24|Jul 14 20:25|Jul 14 20:26
#--------------------------------------------------------------------
sub grep_patterns {
my ($self,$lapse)=@_;

   my $nmin = int($lapse/60) + 1;
   my @patterns = ();
   my @month = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');
   my $ts_now = time;
   my $tx = $ts_now - $nmin*60;

   while ($nmin>=0) {
      my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($tx);
      my $px = sprintf("%s %02d %02d:%02d",$month[$mon],$mday,$hour,$min);
      $tx += 60;
      $nmin-=1;

      push @patterns,$px;
   }

   return \@patterns;

}


#----------------------------------------------------------------------------
# UTILIDADES
#----------------------------------------------------------------------------

=item B<$script-E<gt>usage()>

 Presenta el uso del script segun lo especificado en la cabecera, que debe tener el siguiente formato:
BEGIN { $MYHEADER = <<MYHEADER;
#----------------------------------------------------------------------------
# <CNMDOCU>
# NAME:  cnm_sript_template.pl
# AUTHOR: s30labs
# DATE: 27/01/2015
# VERSION: 1.0
#
# DESCRIPTION:
# Esta es la descripcion del script
# Numero de metricas (tags) = 2  (Con instancias=1)
#
# USAGE:
# cnm_sript_template.pl -n 1.1.1.1 -a apache  [-v]
# cnm_sript_template.pl -n 1.1.1.1 -u user -p pwd -a apache
# ....
# </CNMDOCU>
#----------------------------------------------------------------------------
MYHEADER
};


=cut

#----------------------------------------------------------------------------
sub usage {
my ($self,$header)=@_;


my $fname=$0;

   my %TAGS = ('NAME'=>'', 'DESCRIPTION'=>'', 'USAGE'=>'', 'AUTHOR'=>'', 'DATE'=>'', 'VERSION'=>'');
   my @fpth = split ('/',$fname,10);
   if ($fname=~/.+\/(.+)$/) { $fname=$1; }

   if ($header=~/#\s*NAME\:\s*(.*?)\n#\s*AUTHOR\:\s*(.*?)#\s*DATE\:\s*(.*?)#\s*VERSION\:\s*(.*?)\n*#*\s*\n#\s*DESCRIPTION\:\s*(.*?)#\s*USAGE\:\s*(.*?)<\/CNMDOCU>/s) {
      $TAGS{'NAME'}=$1;
      $TAGS{'AUTHOR'}=$2;
      $TAGS{'DATE'}=$3;
      $TAGS{'VERSION'}=$4;
      $TAGS{'DESCRIPTION'}=$5;
      $TAGS{'USAGE'}=$6;
   }

   chomp $TAGS{'NAME'};
   chomp $TAGS{'AUTHOR'};
   chomp $TAGS{'DATE'};
   chomp $TAGS{'VERSION'};
   chomp $TAGS{'DESCRIPTION'};
   chomp $TAGS{'USAGE'};

   $TAGS{'DESCRIPTION'} =~ s/#//g;
   $TAGS{'USAGE'} =~ s/#//g;

my $USAGE = <<USAGE;
$fname v$TAGS{'VERSION'}
(c)$TAGS{'AUTHOR'} $TAGS{'DATE'}

$TAGS{'USAGE'}
USAGE

   die $USAGE;
}





=item B<$script-E<gt>slurp_file()>

 Lee el contenido de un fichero en una variable escalar
=cut

#----------------------------------------------------------------------------
sub slurp_file {
my ($self,$file)=@_;

   local($/) = undef;  # slurp
   my $content = '';
   my $rc = open (F,"<$file");
   if ($rc) {
      $content = <F>;
      close F;
   }
   return $content;
}

#----------------------------------------------------------------------------
# Obtiene la lista de IPs locales
sub local_ip {
my ($self,$if)=@_;

	my @r=();
	if ($^O =~ /solaris/i) {
		@r =`/usr/sbin/ifconfig -a inet | awk '/inet/ {print $2}' | grep -v '127.0.0.1'`;
	}
	else {
		@r = `/sbin/ifconfig | /bin/grep -Eo 'inet (addr:)?([0-9]*\\.){3}[0-9]*' | /bin/grep -Eo '([0-9]*\\.){3}[0-9]*' | /bin/grep -v '127.0.0.1'`;
	}
	return \@r;

}

#----------------------------------------------------------------------------
# Comprueba si la ip pasada como parametro coincide con la ip local
sub is_local {
my ($self,$ip)=@_;

	my $local=0;
	my $ips = $self->local_ip();
	foreach my $local_ip (@$ips) {
		chomp $local_ip;

		if ( ($ip eq 'localhost') || ($ip eq '127.0.0.1') || ($ip eq $local_ip) ) { $local=1; last; }

	}

   return $local;
}


#----------------------------------------------------------------------------
# Obtiene el indice del menor valor del array mayor que cero pasado como parametro
sub mingt0 {
my ($self,$v) = @_;

   my $min_idx=0;
   for my $i (0..scalar(@$v)-1) {
      if ($v->[$i]==0) {next;}
      if ($v->[$min_idx]==0) { $min_idx=$i; }
      elsif ($v->[$i] < $v->[$min_idx]) { $min_idx=$i; }
   }
   return $min_idx;
}

#----------------------------------------------------------------------------
# Obtiene el indice del mayor valor del array pasado como parametro
sub max_index {
my ($self,$v) = @_;

   my $max_idx=0;
   for my $i (0..scalar(@$v)-1) {
		if ($v->[$i] !~ /^\d+$/) {next;}
     # if ($v->[$i]==0) {next;}
      if ($v->[$max_idx] !~ /^\d+$/) { $max_idx=$i; }
     	if ($v->[$i] > $v->[$max_idx]) { $max_idx=$i; }
   }
   return $max_idx;
}

1;

__END__

=back

=head1 LICENSE

This is released under the GPLv2 License.

=head1 AUTHOR

fmarin@s30labs.com - L<http://www.s30labs.com/>

=head1 SEE ALSO

L<perlpod>, L<perlpodspec>

=cut

