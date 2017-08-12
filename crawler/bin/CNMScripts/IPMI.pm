#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/IPMI.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::IPMI;
@ISA=qw(CNMScripts);

use strict;
use Digest::MD5 qw(md5_hex);
use Text::Diff;
use JSON;
use Time::Local;
use IO::CaptureOutput qw/capture/;
use Data::Dumper;

my $VERSION = '1.00';

#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::IPMI
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;


   my $self=$class->SUPER::new(%arg);
   $self->{_cmd} = $arg{cmd} || "/usr/sbin/ipmimonitoring --sdr-cache-recreate ";
   $self->{_host} = $arg{host} || '';
   $self->{_user} = $arg{user} || '';
   $self->{_pwd} = $arg{pwd} || '';
   $self->{_host_status} = $arg{host_status} || {};

   return $self;
}

#----------------------------------------------------------------------------
# cmd
#----------------------------------------------------------------------------
sub cmd {
my ($self,$cmd) = @_;
   if (defined $cmd) {
      $self->{_cmd}=$cmd;
   }
   else { return $self->{_cmd}; }
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
# user
#----------------------------------------------------------------------------
sub user {
my ($self,$user) = @_;
   if (defined $user) {
      $self->{_user}=$user;
   }
   else { return $self->{_user}; }
}

#----------------------------------------------------------------------------
# pwd
#----------------------------------------------------------------------------
sub pwd {
my ($self,$pwd) = @_;
   if (defined $pwd) {
      $self->{_pwd}=$pwd;
   }
   else { return $self->{_pwd}; }
}

#----------------------------------------------------------------------------
# host_status
#----------------------------------------------------------------------------
sub host_status {
my ($self,$host,$status) = @_;
   if (defined $host) {
		if (defined $status) {
      	$self->{_host_status}->{$host}=$status;
		}
		else { 
			if (exists $self->{_host_status}->{$host}) {
				return $self->{_host_status}->{$host}; 
			}
			else { return 0; }
		}
   }
   else { return $self->{_host_status}; }
}


#----------------------------------------------------------------------------
# check_remote_port
#----------------------------------------------------------------------------
#sub check_remote_port {
#my ($self,$ip)=@_;
#
#my $REMOTE_PORT='135';
#my $TIMEOUT=3;
#
#	my ($rc,$lapse) = $self->check_tcp_port($ip,$REMOTE_PORT,$TIMEOUT);
#	if (! $rc) {
#      $self->err_str('IPMI_REMOTE_TIMEOUT');
#      $self->err_num(1);
#	}
#	return ($rc,$lapse);
#}


#----------------------------------------------------------------------------
# check_remote
#----------------------------------------------------------------------------
sub check_remote {
my ($self,$ip)=@_;


   $self->err_str('[OK]');
   $self->err_num(0);
	my ($rc,$stdout,$stderr)=(1,'','');

   my $ipmi_cmd = $self->cmd().' -h '.$self->host().' -u '.$self->user().' -p '.$self->pwd;

   capture sub { $rc=system($ipmi_cmd); } => \$stdout, \$stderr;

   my @lines = split (/\n/, $stdout);

	if ($stderr ne '') {
		$stderr=~s/\n/\. /g;
		$self->log('info',"check_remote >> **ERROR** [$rc] >> $stderr");
		$self->err_str("[ERR] $stderr");
		$self->err_num(1);
      $rc=0;
	}

	else { 
		my $n = scalar @lines;
		$self->log('info',"check_remote >> OK RES = $n elementos"); 
	}

   return $rc;
}


1;
__END__

