#----------------------------------------------------------------------------
package ProxyCNM;
#----------------------------------------------------------------------------
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;

@EXPORT_OK = qw();
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#------------------------------------------------------------------------
use ONMConfig;
use WSCommon;
#use Crawler::Store;
use libSQL;

#------------------------------------------------------------------------
#unix
use File::Basename;
use Sys::Syslog qw(:DEFAULT setlogsock);

use constant FACILITY => 'local0';
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
my $LOGMSG_1='';


#----------------------------------------------------------------------------
# LAYOUT DE FICHEROS (linux/win32)
if ($^O eq 'win32') {
   $ProxyCNM::IDX_PATH='c:\opt\data\proxy\idx';
   $ProxyCNM::SCRIPTS_PATH='c:\opt\data\proxy\scripts';
   $ProxyCNM::RESULTS_PATH='c:\opt\data\proxy\out';
}
else {

   $ProxyCNM::IDX_PATH='/opt/data/proxy/idx';
   $ProxyCNM::SCRIPTS_PATH='/opt/data/proxy/scripts';
   $ProxyCNM::RESULTS_PATH='/opt/data/proxy/out';
}

my $SEPARATOR=" _o&o_ ";
my $TERMINATE=0;


#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Wbem
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

bless {
      _cfg =>$arg{'cfg'} || undef,
      _db => {'DRIVERNAME'=>'SQLite', 'DATABASE'=>''},
      _dbh => $arg{'dbh'} || undef,
      _sign =>$arg{'sign'} || '0',
      _range =>$arg{'range'} || '0',
		_log_level =>$arg{log_level} || 'info',
      _task_id =>$arg{'task_id'} || '',
      _timeout =>$arg{'timeout'} || 2,
      _retries =>$arg{'retries'} || 2,
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
   else { return $self->{_cfg}; }
}

#----------------------------------------------------------------------------
# db
#----------------------------------------------------------------------------
sub db {
my ($self,$db) = @_;
   if (defined $db) {
      $self->{_db}=$db;
   }
   else { return $self->{_db}; }
}

#----------------------------------------------------------------------------
# dbh
#----------------------------------------------------------------------------
sub dbh {
my ($self,$dbh) = @_;
   if (defined $dbh) {
      $self->{_dbh}=$dbh;
   }
   else { return $self->{_dbh}; }
}


#----------------------------------------------------------------------------
# dbname
#----------------------------------------------------------------------------
sub dbname {
my ($self,$dbname) = @_;
	my $db=$self->db();
   if (defined $dbname) {
		$db->{'DATABASE'}=$ProxyCNM::RESULTS_PATH.'/'.$dbname;
      $self->{_db}=$db;
   }
   else { 
		return $$db->{'DATABASE'};
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
   else { return $self->{_sign}; }
}

#----------------------------------------------------------------------------
# range
#----------------------------------------------------------------------------
sub range {
my ($self,$range) = @_;
   if (defined $range) {
      $self->{_range}=$range;
   }
   else { return $self->{_range}; }
}

#----------------------------------------------------------------------------
# log_level
#----------------------------------------------------------------------------
sub log_level {
my ($self,$level) = @_;
   if (defined $level) {
      $self->{_log_level}=$level;
   }
   else { return $self->{_log_level};  }
}

#----------------------------------------------------------------------------
# task_id
#----------------------------------------------------------------------------
sub task_id {
my ($self,$task_id) = @_;
   if (defined $task_id) {
      $self->{_task_id}=$task_id;
   }
   else { return $self->{_task_id}; }
}

#----------------------------------------------------------------------------
# timeout
#----------------------------------------------------------------------------
sub timeout {
my ($self,$timeout) = @_;
   if (defined $timeout) {
      $self->{_timeout}=$timeout;
   }
   else { return $self->{_timeout}; }
}

#----------------------------------------------------------------------------
# retries
#----------------------------------------------------------------------------
sub retries {
my ($self,$retries) = @_;
   if (defined $retries) {
      $self->{_retries}=$retries;
   }
   else { return $self->{_retries}; }
}


#----------------------------------------------------------------------------
# init
#----------------------------------------------------------------------------
sub init {
my ($self) = @_;


	if ($^O eq 'linux') {		
	  	setlogsock('unix');
  		my $basename = basename($0);
  		openlog($basename,'pid',FACILITY);
	}

	if (! -d $ProxyCNM::IDX_PATH) { system("mkdir -p $ProxyCNM::IDX_PATH"); }
	if (! -d $ProxyCNM::SCRIPTS_PATH) { system("mkdir -p $ProxyCNM::SCRIPTS_PATH"); }
	if (! -d $ProxyCNM::RESULTS_PATH) { system("mkdir -p $ProxyCNM::RESULTS_PATH"); }

	$self->dbname('store.db');
	my $db=$self->db();
	my $dbh=sqlConnect($db);
	$self->dbh($dbh);

	my $table='results001';
	my $fields='ts int, data varchar(255), rc int, rcstr varchar(255)';
	sqlCreate($dbh,$table,$fields,0);

}


#----------------------------------------------------------------------------
# procreate
# Solo valida para sistemas UNIX
#----------------------------------------------------------------------------
sub procreate {
my ($self, $range) = @_;

	use POSIX qw(:signal_h setsid WNOHANG);

   my $signals = POSIX::SigSet->new(SIGINT,SIGCHLD,SIGTERM,SIGHUP);
   sigprocmask(SIG_BLOCK,$signals);  # block inconvenient signals
   my $child = fork();
	if (! defined $child) {
		$self->log('warning',"procreate::[ERROR] en fork ");
	}
   elsif ($child==0) {

      #----------------------------------------------------
      POSIX::setsid();     # become session leader
      open(STDIN,"</dev/null");
      open(STDOUT,">/dev/null");
      open(STDERR,">&STDOUT");
      #my $CWD = getcwd;       # remember working directory
      chdir '/';           # change working directory
      umask(0);            # forget file mode creation mask
      $ENV{PATH} = '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin';
      delete @ENV{'IFS', 'CDPATH', 'ENV', 'BASH_ENV'};
      #$SIG{CHLD} = \&reap_child;
      #$SIG{USR1} = \&show_status;
      #----------------------------------------------------
      #change_privileges($self->user,$self->group);

      #$SIG{INT} = $SIG{CHLD} = 'DEFAULT';
      #$SIG{USR1} = \&show_status;
      #$SIG{HUP} = \&do_hup;
      #$SIG{TERM} = \&do_term;

      #my $n=$self->name();
      #my $idc = sprintf("%03d", $range);
		
		my $n='cnm-proxy';
		my $idc = sprintf("%03d", $range);
      $0='['.$n.'.'.$idc.']';
      $self->log('notice',"Starting $0...");

      #Creo fichero pid
      #my $fpid='/var/run/'."$n.$idc".'.pid';
      #open (F,">$fpid");
      #print F "$$\n";
      #close F;
   }

   sigprocmask(SIG_UNBLOCK,$signals);  # unblock signals
   return $child;
}



#----------------------------------------------------------------------------
# do_task
# 1. 	Lee (siempre) el fichero de tareas, que le debe haber puesto el CNM en 
#		el directorio de trabajo.
#----------------------------------------------------------------------------
sub do_task  {
my ($self,$lapse)=@_;
my @task=();
my $NM=0;   #Numero de metricas a procesar
my $NU=0;   #Numero de metricas a con respuesta=U


   while (1) {

		my $range=$self->range();

		#Siempre se lee el fichero de tareas. Es el gestor el que controla si ha habido cambios.
      my $rv=$self->get_crawler_task_from_file($range,\@task);
      if (!defined $rv) {
         $self->log('warning',"do_task::#RELOAD[WARN] Tarea no definida");
      }

      $NM=scalar @task;
      $self->log('info',"do_task::[INFO] -R- xagent.$lapse|IDX=$range|NM=$NM");

      my $tnext=time+$lapse;

      $NU=0;
      foreach my $desc (@task) {

         my $task_name=$desc->{module};
         my $task_id=$desc->{host_ip}.'-'.$desc->{name};
         $self->task_id($task_id);

#DBG--
         $self->log('info',"do_task::[DEBUG] ==================== RANGE=$range TAREA=$task_id ($task_name)" );
#/DBG--

         #----------------------------------------------------
         my $idmetric=$desc->{idmetric};
         if (! defined $idmetric) {
            $self->log('info',"do_task::[WARN] desc SIN IDMETRIC @{[$desc->{name}]} $task_name >> @{[$desc->{host_ip}]} @{[$desc->{host_name}]}");
         }

         #----------------------------------------------------
         my $script=$desc->{'script'};
			$self->log('info',"do_task::[DEBUG] EJECUTO $script" );
         #my ($rv,$ev)=$self->modules_supported($desc);
         #if ((defined $rv->[0]) && ($rv->[0] eq 'U')) {  $NU+=1;  }
         #----------------------------------------------------
         # Almaceno datos en local
         #my $results = `$script`;
         my $results = "1:2:3:4";
			$self->store_results_in_cache	($results);
      }

      #----------------------------------------------------
      # Envio los datos en local al servidor central
      
      #----------------------------------------------------
      if ($TERMINATE == 1) {
         $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
         exit 0;
      }
      my $wait = $tnext - time;
      if ($wait < 0) {
         $self->log('warning',"do_task::[WARN] *S* xagent.$lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
      }
      else {

         $self->log('info',"do_task::[INFO] -W- xagent.$lapse|IDX=$range|NM=$NM|NU=$NU|WAIT=$wait");
         sleep $wait;
      }
      #----------------------------------------------------
      if ($TERMINATE == 1) {
         $self->log('info',"do_task::[INFO] ***SIGTERM*** Terminamos recibida signal ...");
         exit 0;
      }

      #if ($descriptor->{once}) {exit;}

   }
}


#----------------------------------------------------------------------------
# get_file_idx
# Se ejecuta en cada iteracion de las tareas de crawler para comprobar si ha habido
# modificacion de tareas (metrica nueva/eliminada, monitor nuevo/eliminado ...)
# Chequea la firma  almacenada en la propiedad sign() con la posible nueva firma
# contenida en el nombre del fichero de tareas de un crawler determinado
# (0004.824cc92122aa177809ffe6f92202206b.info)
# IN:
#  Un idx concreto ($range).
# OUT:
#  0->sin cambios  1->con cambios
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
   opendir (DIR,$ProxyCNM::IDX_PATH);
   my @files = grep { /$idx\.\w+\.info/ } readdir(DIR);
   closedir(DIR);
   my $file_task=$files[0];

   my $new_sign=$file_task;
   #if ( $file_task =~ /$ProxyCNM::IDX_PATH\/$idx\.(\w+)\.info/ ) { $new_sign=$1; }
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
# Funcion: get_crawler_task_from_file
#----------------------------------------------------------------------------
# Descripcion: Obtiene el vector de tareas concreta para un crawler.
# Necesita el crwler_idx y el type (porque cada tipo almacena valores diferentes)
#
# snmp:
# d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.community,c.oid,c.version,a.watch,m.id_metric,d.id_dev,m.top_value,t.get_iid
# latency:
# d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.monitor,c.monitor_data,m.watch,m.id_metric,d.id_dev,m.top_value
# xagent:
# d.name,d.ip,m.name,m.type,m.mtype,m.mode,m.module,m.file,c.monitor,c.monitor_data,m.watch,m.id_metric,d.id_dev,m.top_value
#-----------------------------------------------------------------------------
sub get_crawler_task_from_file {
my ($self,$range,$task)=@_;

   #DBG--
   $self->log('debug',"get_crawler_task_from_file::#RELOAD RANGE=$range TASK=$task");
   #/DBG--

   my $idx = sprintf("%04d", $range);
   #my $file_task=glob("$ProxyCNM::IDX_PATH/$idx\.*\.info");
   # OJO!! aqui el glob no funcionaba bien ????
   opendir (DIR,$ProxyCNM::IDX_PATH);
   my @file_task = grep { /$idx\.\w+\.info/ } readdir(DIR);
   closedir(DIR);

   if (! scalar @file_task) {
      $self->log('warning',"get_crawler_task_from_file::#RELOAD[WARN] No se encuentra fichero para IDX=$idx");
      return undef;
   }

   my $ft=$ProxyCNM::IDX_PATH.'/'.$file_task[0];
   my $rc=open (F,"<$ft");
   if (! $rc) {
      $self->log('warning',"get_crawler_task_from_file::#RELOAD[WARN] error al abrir $ft ($!)");
      return undef;
   }
   $self->log('debug',"get_crawler_task_from_file::ABRO FICHERO $ft IDX_PATH=$ProxyCNM::IDX_PATH");

   # El contenido del fichero es del tipo k1=v1,k2=v2 .... por linea
   # Notar que hay parametros que pueden ser variables ( p. ej. en latency )
   @$task=();
   while (<F>) {
      #my @pair=split(',',$_);
      my @pair=split($SEPARATOR,$_);
      my %h=();
      foreach my $p (@pair) {
         # Hay que sustituirlo por un regex por el caso de params
         #my ($k,$v)= split(/\=/,$p);
         #$h{$k}=$v;
         $p=~/^(\S+?)\s*\=\s*(.*)$/;
         $h{$1}=$2;
      }
      push @$task, \%h;
   }

   close F;
   return 1;

}

#----------------------------------------------------------------------------
#sub log {
#my ($self,$level,$txt)=@_;
#
#	print "****$level>>$txt\n";
#
#}



#----------------------------------------------------------------------------
sub store_results_in_cache  {
my ($self,$results)=@_;


	my %table=();
   my $dbh = $self->dbh();
   my $table_name='results001';

	$table{'ts'} =  time();
	$table{'data'} = $results;
	$table{'rc'} =  0;
	$table{'rcstr'} =  '';
   my $rv=sqlInsert($dbh,$table_name,\%table);
	
   my $error = $libSQL::err;
   my $errorstr = $libSQL::errstr;
   my $lastcmd = $libSQL::cmd;

   if (defined $rv) {
      $self->log('debug',"store_results_in_cache::[DEBUG] STORED TS=$table{'ts'} DATA=$table{'data'} ");
	}
	else {
      $self->log('warning',"store_results_in_cache::[DEBUG] ERROR $error ($errorstr) CMD=$lastcmd ");
	}

   return $rv;

}

#----------------------------------------------------------------------------
# log
#----------------------------------------------------------------------------
sub log  {
my ($self,$level,@arg) = @_;


   #Valido el nivel de 'logging' configurado ------------------
   my $level_cfg=$self->log_level();
#syslog($level,'%s',"level=$level level_cfg=$level_cfg mode=$mode ++++");
   if ( $LOG_PRIORITY{$level} < $LOG_PRIORITY{$level_cfg} ) {return;}

   my $v=join('',@arg);
   return if ($v eq $LOGMSG_1);
   $LOGMSG_1=$v;

   if ( ($level ne 'debug') && ($level ne 'notice') && ($level ne 'warning') && ($level ne 'crit'))  {$level='notice';}

   my $msg = join('',@arg) || "Registro de log";

   my ($pack,$filename,$line) = caller;
   $msg .= " ($filename $line)\n" unless $msg =~ /\n$/;
   $msg=~s/%/p/g;

   syslog($level,'%s',$msg);
   #print "$msg";
}


1;

