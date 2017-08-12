#-------------------------------------------------------------------------------------------
# Fichero: Crawler/LogManager.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
package Crawler::LogManager;
@ISA=qw(Crawler);
use strict;
use Digest::MD5 qw(md5_hex);

my $VERSION = '1.00';
my $ETXT='KEY-ERROR';

#-------------------------------------------------------------------------------------------
# RELOAD FILE (/var/www/html/onm/tmp/trap_manager.reload) : Indica si hay que reiniciar procesos
# BANNED_FILE (/cfg/banned_devices.cfg) : Contiene la lista de IPs baneadas para traps.
#-------------------------------------------------------------------------------------------
my %TRAP2HOOK=();

#-------------------------------------------------------------------------------------------
#$TRAP2HOOK{'9.9.26.2.6..3'} = '/opt/crawler/apps/trap_manager/trap_hook_rdsi_level2';
#

#-------------------------------------------------------------------------------------------
#my %ALERT2EXPR=();
my %TRAP2ALERT=();
my %TRAP2ALERT_PATTERNS=();
#my %EVENT2DATA=();
my %LINE=();
my @VDATA=();


my %IP2NAME=();   				# Mapeo de ip a nombre
my %EVENT2ALERT=();				# Mapeos de evento a alerta
my %EVENT2ALERT_PATTERNS=();	# Patrones para mapeos de evento a alerts
my %EVENT2DATA=();				# Mapeo evkey->msg_custom
my %ALERT2EXPR=();				# Expresiones sobre los parametros de evento para ser alerta
my %ALERT2VIEWS=();				# Alertas que tienen impacto sobre las vistas
my %ACLS=();						# Lista de control de acceso. Solo se aceptan eventos de estos equipos (en el caso de LogManager son los configurados)
my @EVENTEXCLUDED=();			# Lista de eventos (o patrones de eventos) que no se almacenan en BBDD

#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::LogManager
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_cfg} = $arg{cfg} || '';
   $self->{_event} = $arg{event} || \%LINE;
   $self->{_event2alert} = $arg{event2alert} || \%EVENT2ALERT;
   $self->{_event2alert_patterns} = $arg{event2alert_patterns} || \%EVENT2ALERT_PATTERNS;
   $self->{_eventexcluded} = $arg{eventexcluded} || \@EVENTEXCLUDED;
   $self->{_alert2expr} = $arg{alert2expr} || \%ALERT2EXPR;
   $self->{_alert2views} = $arg{alert2views} || \%ALERT2VIEWS;
   $self->{_acls} = $arg{acls} || \%ACLS;
   $self->{_ip2name} = $arg{ip2name} || \%IP2NAME;
   $self->{_reload_file} = $arg{reload_file} || '/var/www/html/onm/tmp/trap_manager.reload';
   $self->{_banned_file} = $arg{banned_file} || '/cfg/banned_devices.cfg';
   $self->{_timeout} = $arg{timeout} || 2000000;  #Se mide en microsegundos.
   $self->{_retries} = $arg{retries} || 2;
   $self->{_tag} = $arg{tag} || 'unk';
   $self->{_version1} = $arg{version1} || '3.23.54';
   $self->{_version2} = $arg{version2} || '1.0.40';

   return $self;
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
# event
#----------------------------------------------------------------------------
sub event {
my ($self,$event) = @_;
   if (defined $event) {
      $self->{_event}=$event;
   }
   else { return $self->{_event}; }
}

#----------------------------------------------------------------------------
# event2data
#----------------------------------------------------------------------------
sub event2data {
my ($self,$event2data) = @_;
   if (defined $event2data) {
      $self->{_event2data}=$event2data;
   }
   else { return $self->{_event2data}; }
}

#----------------------------------------------------------------------------
# eventexcluded
#----------------------------------------------------------------------------
sub eventexcluded {
my ($self,$eventexcluded) = @_;
   if (defined $eventexcluded) {
      $self->{_eventexcluded}=$eventexcluded;
   }
   else { return $self->{_eventexcluded}; }
}

#----------------------------------------------------------------------------
# event2alert
#----------------------------------------------------------------------------
sub event2alert {
my ($self,$event2alert) = @_;
   if (defined $event2alert) {
      $self->{_event2alert}=$event2alert;
   }
   else { return $self->{_event2alert}; }
}

#----------------------------------------------------------------------------
# event2alertpatterns
#----------------------------------------------------------------------------
sub event2alert_patterns {
my ($self,$event2alert_patterns) = @_;
   if (defined $event2alert_patterns) {
      $self->{_event2alert_patterns}=$event2alert_patterns;
   }
   else { return $self->{_event2alert_patterns}; }
}

#----------------------------------------------------------------------------
# ip2name
#----------------------------------------------------------------------------
sub ip2name {
my ($self,$ip2name) = @_;
   if (defined $ip2name) {
      $self->{_ip2name}=$ip2name;
   }
   else { return $self->{_ip2name}; }
}

#----------------------------------------------------------------------------
# alert2expr
#----------------------------------------------------------------------------
sub alert2expr {
my ($self,$alert2expr) = @_;
   if (defined $alert2expr) {
      $self->{_alert2expr}=$alert2expr;
   }
   else { return $self->{_alert2expr}; }
}


#----------------------------------------------------------------------------
# alert2views
#----------------------------------------------------------------------------
sub alert2views {
my ($self,$alert2views) = @_;
   if (defined $alert2views) {
      $self->{_alert2views}=$alert2views;
   }
   else { return $self->{_alert2views}; }
}

#----------------------------------------------------------------------------
# acls
#----------------------------------------------------------------------------
sub acls {
my ($self,$acls) = @_;
   if (defined $acls) {
      $self->{_acls}=$acls;
   }
   else { return $self->{_acls}; }
}

#----------------------------------------------------------------------------
# reload_file
#----------------------------------------------------------------------------
sub reload_file {
my ($self,$reload_file) = @_;
   if (defined $reload_file) {
      $self->{_reload_file}=$reload_file;
   }
   else { return $self->{_reload_file}; }
}

#----------------------------------------------------------------------------
# banned_file
#----------------------------------------------------------------------------
sub banned_file {
my ($self,$banned_file) = @_;
   if (defined $banned_file) {
      $self->{_banned_file}=$banned_file;
   }
   else { return $self->{_banned_file}; }
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
# tag
#----------------------------------------------------------------------------
sub tag {
my ($self,$tag) = @_;
   if (defined $tag) {
      $self->{tag}=$tag;
   }
   else { return $self->{_tag}; }
}

#----------------------------------------------------------------------------
# version1
#----------------------------------------------------------------------------
sub version1 {
my ($self,$version) = @_;
   if (defined $version) {
      $self->{_version1}=$version;
   }
   else { return $self->{_version1}; }
}

#----------------------------------------------------------------------------
# version2
#----------------------------------------------------------------------------
sub version2 {
my ($self,$version) = @_;
   if (defined $version) {
      $self->{_version2}=$version;
   }
   else { return $self->{_version2}; }
}

#-------------------------------------------------------------------------------------------
# connect
#-------------------------------------------------------------------------------------------
sub connect {
my ($self) = @_;

	my $store=$self->store();
   my $dbh=$store->open_db();
	#$self->dbh($dbh);
   my $err=$store->error();
	if ($err) {
		my $errstr=$store->errorstr();
   	$self->log('warning',"connect:: RC=$err ($errstr) (DBH=$dbh)");
		$store->close_db($dbh);
      $dbh=$store->open_db();
		$self->dbh($dbh);
	}
	$self->dbh($dbh);
}


#-------------------------------------------------------------------------------------------
# disconnect
#-------------------------------------------------------------------------------------------
sub disconnect {
my ($self) = @_;

   my $store=$self->store();
   my $dbh=$self->dbh();
   $store->close_db($dbh);
   my $err=$store->error();
   if ($err) {
      my $errstr=$store->errorstr();
      $self->log('warning',"disconnect:: RC=$err ($errstr) (DBH=$dbh)");
   }
}


#------------------------------------------------------------------------------------------
# modify_counter
# in: Nombre del fichero donde se almacena el contador, Valor con el que se incrementa
# ---> file, value
#------------------------------------------------------------------------------------------
sub modify_counter {
my ($self,$file,$value)=@_;

	if (open(F,"<$file")) {
		my $c=<F>;
		close F;
		$c+=$value;
		open(F,">$file");
		print F "$c\n";
		close F;
	}
}

#------------------------------------------------------------------------------------------
# get_banned_devices
# in: Nombre del fichero donde se almacenan las IPs baneadas
# out: ref a hash donde clave=ip y valor=1
#------------------------------------------------------------------------------------------
sub get_banned_devices {
my ($self,$file)=@_;

	my %banned=();
   if (open(F,"<$file")) {
		while (<F>) {
			chomp;
			$banned{$_}=1;
		}
      close F;
   }
	return \%banned;
}



#------------------------------------------------------------------------------------------
# throttle
# Retorno: $rc=0 => No se aplica throttle | $rc=1 => Si se aplica throttle
#------------------------------------------------------------------------------------------
sub throttle {
my ($self,$rdata)=@_;

   my $tnow=time;
   my $rc=0;

   my $lapse=$rdata->{'lapse'};
   my $ref_time=$rdata->{'ref_time'};
   my $counter=$rdata->{'counter'};
   my $level=$rdata->{'level'};

   # Estamos en intervalo de lapse
   if ( $tnow < $ref_time + $lapse) {
      $rdata->{'lps'} = -1;
      $counter +=1;
   }
   else {
      my $lps = $counter/($tnow-$ref_time);
      $rdata->{'lps'} = $lps;
      if ($lps > $level) { $rc=1; }
   }

   return $rc;
}

1;
__END__
