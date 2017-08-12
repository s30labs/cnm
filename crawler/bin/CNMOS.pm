# --------------------------------------------------------------------------------------------
# Fichero: CNMOS.pm
# --------------------------------------------------------------------------------------------
package CNMOS;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;
use Sys::Syslog qw(:DEFAULT setlogsock);
use File::Basename;

@EXPORT_OK = qw();
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#------------------------------------------------------------------------
#use ExtUtils::Installed;
#use File::Copy;
#use Cwd;

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Wbem
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   setlogsock('unix');
   my $basename = basename($0);
   openlog($basename,'pid','cron');
   $SIG{__WARN__} = \&log_warn;
   $SIG{__DIE__}  = \&log_die;

bless {
      _cfg =>$arg{'cfg'} || undef,
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


#-------------------------------------------------------------------------------------------
#sub validate_dir {
#sub os2system{
#sub osbase2system{
#sub pre_system_configuration {
#sub prepare_runtime_dirs {
#sub prepare_git_dirs {
#sub post_system_configuration {

#-------------------------------------------------------------------------------------------
# Solo el directorio
my %CNMDIRS = (

	# MIBS
	'/opt/data/mibs' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' },
	'/opt/data/mibs000' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' },
	'/opt/data/app-data/mibs_private' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' },
	'/opt/custom_pro002/mibs002' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' },

#	'/cfg' => { 'perm'=>'755', 'user'=>'root', 'group'=>'www-data' }, #644?
#	'/home/cnm/backup/old_bbdd' => { 'perm'=>'666', 'user'=>'cnm', 'group'=>'www-data' }
#	'' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' }
#	'' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' }
#	'' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' }
#	'' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' }

);

#Ficheros incluidos en un directorio
my %CNMDIRFILES = (

   # MIBS
   '/opt/data/mibs' => { 'perm'=>'644', 'user'=>'root', 'group'=>'root' },
   '/opt/data/mibs000' => { 'perm'=>'644', 'user'=>'root', 'group'=>'root' },
   '/opt/data/app-data/mibs_private' => { 'perm'=>'644', 'user'=>'root', 'group'=>'root' },
   '/opt/custom_pro002/mibs002' => { 'perm'=>'644', 'user'=>'root', 'group'=>'root' },

#  '/cfg' => { 'perm'=>'755', 'user'=>'root', 'group'=>'www-data' }, #644?
#  '/home/cnm/backup/old_bbdd' => { 'perm'=>'666', 'user'=>'cnm', 'group'=>'www-data' }
#  '' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' }
#  '' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' }
#  '' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' }
#  '' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' }

);



my %CNMFILES = (

   '/etc/resolv.conf' => { 'perm'=>'664', 'user'=>'root', 'group'=>'www-data', 'touch'=>0 },
   '/cfg/onm.conf' => { 'perm'=>'776', 'user'=>'root', 'group'=>'www-data', 'touch'=>0 }, #776??
   '/cfg/onm.role' => { 'perm'=>'776', 'user'=>'root', 'group'=>'www-data', 'touch'=>0 }, #776??

   '/etc/cron.fast/cnm-watch' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root', 'touch'=>0 },
   '/etc/cron.daily/cnm-daily' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root', 'touch'=>0 },
   '/etc/cron.hourly/ntpdate' => { 'perm'=>'755', 'user'=>'root', 'group'=>'www-data', 'touch'=>0 },
   '/update/releases' => { 'perm'=>'644', 'user'=>'root', 'group'=>'root', 'touch'=>1 },
   '/etc/syslog-ng/syslog-ng-custom.conf' => { 'perm'=>'644', 'user'=>'root', 'group'=>'www-data' },

#   '' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' },
#   '' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' },

);


my %CNMLINKS = (

);

#-------------------------------------------------------------------------------------------
# validate_dir
# Si no existe el directorio especificado, lo crea.
# Reconfigura permisos y owner/group.
# $info es un hashref del tipo: { '/opt/data/mibs' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root' }, ... }
#-------------------------------------------------------------------------------------------
sub validate_dir {
my ($self,$info) = @_;

	if (! defined $info) { $info= \%CNMDIRS; }

	foreach my $dir (keys %$info) {

		my $perm = exists $info->{$dir}->{'perm'} ? $info->{$dir}->{'perm'} : '755';
		my $user = exists $info->{$dir}->{'user'} ? $info->{$dir}->{'user'} : 'root';
		my $group = exists $info->{$dir}->{'group'} ? $info->{$dir}->{'group'} : 'root';
				
		if (! -d $dir) {
			my $rc = system ("/bin/mkdir -p $dir");
			$self->log('info',"validate_dir:: MKDIR $dir ($rc)");
		}
		my $rc1 = system ("/bin/chmod $perm $dir");
		my $rc2 = system ("/bin/chown $user:$group $dir");
		$self->log('info',"validate_dir:: $perm ($user:$group) -> $dir ($rc1|$rc2)");
	}
}

#-------------------------------------------------------------------------------------------
sub validate_dir_files {
my ($self,$info) = @_;

   if (! defined $info) { $info= \%CNMDIRFILES; }

   foreach my $dir (keys %$info) {

      my $perm = exists $info->{$dir}->{'perm'} ? $info->{$dir}->{'perm'} : '755';
      my $user = exists $info->{$dir}->{'user'} ? $info->{$dir}->{'user'} : 'root';
      my $group = exists $info->{$dir}->{'group'} ? $info->{$dir}->{'group'} : 'root';

      if (! -d $dir) {
			$self->log('info',"validate_dir_files:: TERMINO NO EXISTE $dir");
			return;
		}

      my $rc1 = system ("/bin/chmod $perm $dir/* 2>/dev/null");
      my $rc2 = system ("/bin/chown $user:$group $dir/* 2>/dev/null");
      $self->log('info',"validate_dir_files:: $perm ($user:$group) -> $dir/* ($rc1|$rc2)");
   }
}

#-------------------------------------------------------------------------------------------
# validate_file
# Si no existe el directorio especificado, lo crea.
# Reconfigura permisos y owner/group de losficheros especificados
# $info es un hashref del tipo: {'/etc/resolv.conf' => { 'perm'=>'755', 'user'=>'root', 'group'=>'root', 'touch'=>0 }..}
#-------------------------------------------------------------------------------------------
sub validate_file {
my ($self,$info) = @_;

   if (! defined $info) { $info= \%CNMFILES; }

	my $RC;
   foreach my $file (keys %$info) {

      my $perm = exists $info->{$file}->{'perm'} ? $info->{$file}->{'perm'} : '755';
      my $user = exists $info->{$file}->{'user'} ? $info->{$file}->{'user'} : 'root';
      my $group = exists $info->{$file}->{'group'} ? $info->{$file}->{'group'} : 'root';
		my $touch = exists $info->{$file}->{'touch'} ? $info->{$file}->{'touch'} : 0;

      if (! -f $file) {
			if ($touch) {  
				$RC = system ("/bin/touch -p $file");
		      $RC = system ("/bin/chmod $perm $file");
      		$RC = system ("/bin/chown $user:$group $file");
			}
      }
		else {
         $RC = system ("/bin/chmod $perm $file");
         $RC = system ("/bin/chown $user:$group $file");
      }
   }
}






















#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# Funcion: init_log
# Descripcion: Inicializa el volcado a syslog en la facility FACILITY. Tambien
# redirige los warnings y errores de perl
#----------------------------------------------------------------------------
sub init_log {
my ($self,$facility)=@_;

   if (! $facility) { $facility='cron'; }
   setlogsock('unix');
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

#----------------------------------------------------------------------------
sub log  {
my ($self,$level,@arg) = @_;

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
   syslog($level,'%s',$msg);

}


1;
__END__
