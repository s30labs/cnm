#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/Telnet.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::Telnet;
@ISA=qw(CNMScripts);

use strict;
use Net::Telnet;
use Data::Dumper;

my $VERSION = '1.00';

#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::SSH
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_host} = $arg{host} || '';
   $self->{_port} = $arg{port} || '23';
   $self->{_credentials} = $arg{credentials} || '';
   $self->{_telnet} = $arg{telnet} || '';
   $self->{_timeout} = $arg{timeout} || 3;
   $self->{_err_num} = $arg{er_num} || 0;
   $self->{_err_str} = $arg{err_str} || '';

   return $self;
}

#----------------------------------------------------------------------------
# host
#----------------------------------------------------------------------------
sub host {
my ($self,$host) = @_;
   if (defined $host) {
      $self->{_host}=$host;
   }
   else { return $self->{_host}; }
}

#----------------------------------------------------------------------------
# port
#----------------------------------------------------------------------------
sub port {
my ($self,$port) = @_;
   if (defined $port) {
      $self->{_port}=$port;
   }
   else { return $self->{_port}; }
}

#----------------------------------------------------------------------------
# credentials
#----------------------------------------------------------------------------
sub credentials {
my ($self,$credentials) = @_;
   if (defined $credentials) {
      $self->{_credentials}=$credentials;
   }
   else { return $self->{_credentials}; }
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
# telnet
#----------------------------------------------------------------------------
sub telnet {
my ($self,$telnet) = @_;
   if (defined $telnet) {
      $self->{_telnet}=$telnet;
   }
   else { return $self->{_telnet}; }
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
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# check_remote_port
#----------------------------------------------------------------------------
sub check_remote_port {
my ($self,$ip)=@_;

	my $REMOTE_PORT=$self->port();
	my $TIMEOUT=$self->timeout();
   my ($rc,$lapse) = $self->check_tcp_port($ip,$REMOTE_PORT,$TIMEOUT);
   if (! $rc) {
      $self->err_str('_REMOTE_TIMEOUT');
      $self->err_num(1);
   }
   return ($rc,$lapse);
}

#----------------------------------------------------------------------------
# connect
#----------------------------------------------------------------------------
sub connect {
my ($self) = @_;

   # --------------------------------------
   # $credentials puede ser del tipo:
   # -user=aaaa -pwd=bbb
	# -passphrase = xyz
   # --------------------------------------
   my ($user,$pwd)=('','');
   my $host=$self->host();
   my $credentials=$self->credentials();
   if ($credentials=~/\-user\s*\=\s*(\S+)/) { $user=$1; }
   if ($credentials=~/\-pwd\s*\=\s*(\S+)/) { $pwd=$1; }

#print "host=$host user=$user pwd=$pwd\n";

	my $timeout = $self->timeout();
	my $port = $self->port();

	#The default prompt is '/[\$%#>] $/'
	#Always use single quotes, instead of double quotes, to construct $matchop (e.g. '/bash\$ $/'). If you're constructing a DOS like file path, you'll need to use four backslashes to represent one (e.g. '/c:\\\\users\\\\bill>$/i').
   my $t = Net::Telnet->new (Timeout => $timeout, Port => $port, Prompt => '/\$ $/');
   $t->open($host);
   $t->login($user, $pwd);

	$self->telnet($t);
	$self->err_str($t->errmsg);
	return $t;
}


#----------------------------------------------------------------------------
# execute
# Ejecuta un script en el equipo remoto.
# 1. Se conecta
# 2. Copia el script
# 3. Ejecuta el script
#----------------------------------------------------------------------------
#sub execute {
#my ($self,$script_file_path) = @_;
#
#	my $ssh = $self->connect();
#	if ($self->err_num()) {
#		return ('',$self->err_str());
#	}
#
##print Dumper(\%ssh_opts);
#
#	# --------------------------------------
#	my($script_name, $directories, $suffix) = fileparse($script_file_path);
#   my $rc = $ssh->scp_put($script_file_path,'/tmp');
#   print "scp $script_file_path ---> remote res=$rc\n";
#   my ($stdout, $stderr) = $ssh->capture2("perl /tmp/$script_name");
#
#	return ($stdout, $stderr);
#}
#

#----------------------------------------------------------------------------
# cmd
# Ejecuta los comando especificados como parametros.
# $cmd_vector: Ref a array con los comandos a ejecutar.
# Resultado: 	Ref a hash: Las claves son los comandos
#					Los valores son los resultados obtenidos
#----------------------------------------------------------------------------
sub cmd {
my ($self,$cmd_vector) = @_;

	my %results=();
	my $t = $self->telnet();
	foreach my $cmd (@$cmd_vector) {
      my @out = $t->cmd($cmd);
		$results{$cmd}->{'stdout'} = join ('', @out);
	}
	return \%results;
}

1;

__END__

