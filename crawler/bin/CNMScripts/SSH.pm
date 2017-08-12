#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/SSH.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::SSH;
@ISA=qw(CNMScripts);

use strict;
use Net::OpenSSH;
use Expect;
use File::Basename;
use Data::Dumper;

=pod

=head1 NAME

CNMScripts::SSH - Modulo derivado de CNMScripts que contiene soporte para acceder por SSH a un equipo remoto.


=head1 SYNOPSIS

 use CNMScripts::SSH;
 my $ssh = CNMScripts::SSH->new();

 $ssh->prompt();
 $ssh->connect();
 $ssh->execute();
 $ssh->cmd();
 $ssh->ssh_cmd();
 $ssh->log_parser_fx();


=head1 DESCRIPTION

Modulo para simplificar el desarrollo de scripts en perl para CNM.

=cut


my $VERSION = '1.00';
#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::SSH
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_host} = $arg{host} || '';
   $self->{_port} = $arg{port} || '22';
   $self->{_credentials} = $arg{credentials} || {};
   $self->{_ssh} = $arg{ssh} || '';
   $self->{_openssh_cmd} = $arg{openssh_cmd} || '';
   $self->{_ssh_opts} = $arg{ssh_opts} || { 'master_opts' => [-o => "StrictHostKeyChecking=no"] };
   $self->{_mode} = $arg{mode} || 'default'; # default|interactive
   $self->{_prompt} = $arg{prompt} || '';
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
# Debe ser un hash del tipo
# {'user'=>xx, 'password'=>yy, 'passphrase'=>zz, 'key_path'=>abc ....  }
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
# ssh
#----------------------------------------------------------------------------
sub ssh {
my ($self,$ssh) = @_;
   if (defined $ssh) {
      $self->{_ssh}=$ssh;
   }
   else { return $self->{_ssh}; }
}

#----------------------------------------------------------------------------
# openssh_cmd
#----------------------------------------------------------------------------
sub openssh_cmd {
my ($self,$openssh_cmd) = @_;
   if (defined $openssh_cmd) {
      $self->{_openssh_cmd}=$openssh_cmd;
   }
   else { return $self->{_openssh_cmd}; }
}

#----------------------------------------------------------------------------
# ssh_opts
#----------------------------------------------------------------------------
sub ssh_opts {
my ($self,$ssh_opts) = @_;
   if (defined $ssh_opts) {
      $self->{_ssh_opts}=$ssh_opts;
   }
   else { return $self->{_ssh_opts}; }
}

#----------------------------------------------------------------------------
# mode
#----------------------------------------------------------------------------
sub mode {
my ($self,$mode) = @_;
   if (defined $mode) {
      $self->{_mode}=$mode;
   }
   else { return $self->{_mode}; }
}

#----------------------------------------------------------------------------
# prompt
#----------------------------------------------------------------------------
sub prompt {
my ($self,$prompt) = @_;
   if (defined $prompt) {
      $self->{_prompt}=$prompt;
   }
   else { return $self->{_prompt}; }
}

#----------------------------------------------------------------------------
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# connect
#----------------------------------------------------------------------------
sub connect {
my ($self) = @_;

   # --------------------------------------
   # $credentials es un hash del tipo
	# {'user'=>xx, 'password'=>yy, 'passphrase'=>zz, 'key_path'=>abc ....  }
   # -user=aaaa -pwd=bbb
	# -passphrase = xyz
   # --------------------------------------
   my $host=$self->host();
	my %ssh_opts = ();
   my $more_ssh_opts=$self->ssh_opts();
   foreach my $k (keys %$more_ssh_opts) { $ssh_opts{$k}=$more_ssh_opts->{$k}; }

	# --------------------------------------
   $ssh_opts{'port'}=$self->port();
   my $credentials=$self->credentials();
	if (exists $credentials->{'user'}) { 
		$ssh_opts{'user'}=$credentials->{'user'}; 
	}
	if (exists $credentials->{'password'}) {
		$ssh_opts{'password'}=$credentials->{'password'};
	}
	elsif (exists $credentials->{'key_file'}) {
		$ssh_opts{'key_path'} = ($credentials->{'key_file'}==1) ? '/etc/ssh/ssh_host_rsa_key' : $credentials->{'key_file'};
		if (exists $credentials->{'passphrase'}) { $ssh_opts{'passphrase'}=$credentials->{'passphrase'}; }
	}
	else {
      my $x = $self->get_cnm_credential($host,'ssh');
		#($user,$pwd)=($x->{'user'}, $x->{'pwd'});
      if (exists $x->{'port'}) { $ssh_opts{'port'}=$x->{'port'}; }
      if (exists $x->{'user'}) { $ssh_opts{'user'}=$x->{'user'}; }
      if (exists $x->{'password'}) { $ssh_opts{'password'}=$x->{'pwd'}; }
		if (exists $x->{'key_file'}) {
      	$ssh_opts{'key_path'} = ($x->{'key_file'}==1) ? '/etc/ssh/ssh_host_rsa_key' : $x->{'key_file'};
		}
      if (exists $x->{'passphrase'}) { $ssh_opts{'passphrase'}=$x->{'passphrase'}; }
	}

	if ($self->openssh_cmd() ne '') { $ssh_opts{'ssh_cmd'}=$self->openssh_cmd(); }

	# --------------------------------------
	my $ssh = undef;
	if ( (($ssh_opts{'user'} eq '') || ($ssh_opts{'password'} eq '')) && ($ssh_opts{'key_path'} eq '')) {
      $self->err_num(10);
      $self->err_str("ERROR con las credenciales $credentials. Parece que el equipo $host no tiene definida credencial SSH");
		$self->log('error',"ERROR con las credenciales $credentials. Parece que el equipo $host no tiene definida credencial SSH");
		return $ssh;
	}

	# --------------------------------------
   $ssh = Net::OpenSSH->new($host, %ssh_opts);
	$self->ssh($ssh);

	if ($ssh->error) {
		$self->err_num(1);
		$self->err_str($ssh->error);
		my $err=$ssh->error;
		$self->log('error',"ERROR en acceso a $host ($err)");
	}
	else {
		$self->err_num(0);
		$self->err_str("Acceso a $host >> OK");
		$self->log('info',"Acceso a $host OK");
	}
	return $ssh;
}


#----------------------------------------------------------------------------
# execute
# Ejecuta un script en el equipo remoto.
# 1. Se conecta
# 2. Copia el script
# 3. Ejecuta el script
#----------------------------------------------------------------------------
sub execute {
my ($self,$script_file_path,$params) = @_;

	# No se pueden ignorar los procesos hijos porque scp_put
	# fallaria al manejar el resultado
	local $SIG{CHLD}='';

	my $ssh = $self->connect();
	if ($self->err_num()) {
		return ('',$self->err_str());
	}

#print Dumper(\%ssh_opts);

	# --------------------------------------
	my($script_name, $directories, $suffix) = fileparse($script_file_path);
   my $rc = $ssh->scp_put({verbose=>1}, $script_file_path,'/tmp');
   if (! defined $rc) {
		my $err=$ssh->error;
		my $errstr = "ERROR en scp_put $script_file_path -> /tmp ($err)";
		$self->log('error',"ERROR en scp_put $script_file_path -> /tmp ($errstr)");
      return ('',$errstr);
   }

   print "scp $script_file_path ---> remote res=$rc\n";

	$self->log('info',"++++++++ scp $script_file_path ---> remote res=$rc");
#print "*****perl /tmp/$script_name $params\n";
	$self->log('info',"++++++++ perl /tmp/$script_name $params");

   my ($stdout, $stderr) = $ssh->capture2("perl /tmp/$script_name $params");

	return ($stdout, $stderr);
}


#----------------------------------------------------------------------------
# cmd
# Ejecuta los comandos especificados como parametros.
# $cmd_vector: Ref a array o a hash con los comandos a ejecutar.
# Resultado: 	Ref a hash: 
#					a. Si $cmd_vector es array: 
#							Las claves son los comandos
#							Los valores son otra ref. a hash con el resultado (stdout y stderr)
#					a. Si $cmd_vector es hash: 
#							Las claves son las claves de $cmd_vector
#							Los valores son otra ref. a hash con el resultado (stdout y stderr)
#----------------------------------------------------------------------------
sub cmd {
my ($self,$cmd_vector) = @_;

	$|=1;
	my %results=();
	my $ssh = $self->ssh();
   my $mode = $self->mode();
	my ($stdout, $stderr) = ('','');

	if (ref($cmd_vector) eq 'HASH') {
		foreach my $key (sort keys %$cmd_vector) {

			my $cmd = $cmd_vector->{$key};
   		if ($mode =~ /interactive/) { 
				($stdout, $stderr) = $self->ssh_cmd($cmd); 
			}
			else { 
   	   	($stdout, $stderr) = $ssh->capture2($cmd);
			}
			chomp $stdout;
			chomp $stderr;
			$results{$key}->{'stdout'} = $stdout;
			$results{$key}->{'stderr'} = $stderr;
		}
	}
	else {
      foreach my $cmd (@$cmd_vector) {

         if ($mode =~ /interactive/) {
            ($stdout, $stderr) = $self->ssh_cmd($cmd);
         }
         else {
            ($stdout, $stderr) = $ssh->capture2($cmd);
         }
         chomp $stdout;
         chomp $stderr;
         $results{$cmd}->{'stdout'} = $stdout;
         $results{$cmd}->{'stderr'} = $stderr;
      }
   }

	return \%results;
}

#----------------------------------------------------------------------------
sub ssh_cmd {
my ($self,$cmd) = @_;

   my ($stdout, $stderr) = ('','');
	my $fscratch='/tmp/kk.log';

   my $ssh = $self->ssh();

		my $prompt=$self->prompt();

$prompt='$';
print "PROMPT=$prompt\n";
      my ($pty, $pid) = $ssh->open2pty();
      my $expect = Expect->init($pty);
      $expect->raw_pty(1);
      #$expect->log_user(1);
      #$expect->log_stdout(1);
#		$expect->log_file(&log_parser_fx);
		$expect->log_file($fscratch,"w");
      my $timeout=20;
      $expect->expect($timeout, $prompt);
      $expect->send("$cmd\n");

      my $x=$expect->expect($timeout, $prompt);
		while (!defined $x) {
			$x=$expect->expect($timeout, $prompt);
		}

#open (R,"</tmp/kk.log");
#while(<R>) { print $_; }
#close R;

#      while(<$pty>) {
##         print "****** $. $_";
#         $stdout.=$_;
##			sleep 1;
##         last if ($expect->expect($timeout, $prompt));
#			last if ($_ =~/Tests marked with/);
#      }

$stdout=$self->slurp_file($fscratch);
#unlink $fscratch;

#print "stdout=$stdout\n";

   return ($stdout, $stderr);
}

sub log_parser_fx {
my ($self,$l)=@_;
	print "****> $l";
}

1;

__END__

