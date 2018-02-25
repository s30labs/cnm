#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/LDAP.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::LDAP;
@ISA=qw(CNMScripts);

use strict;
use Digest::MD5 qw(md5_hex);
use Text::Diff;
use JSON;
use Time::Local;
use IO::CaptureOutput qw/capture/;
use Net::LDAP;
use Data::Dumper;

my $VERSION = '1.00';

#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::LDAP
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;


   my $self=$class->SUPER::new(%arg);
   $self->{_host} = $arg{host} || '';
   $self->{_port} = $arg{port} || '1433';
   $self->{_user} = $arg{user} || '';
   $self->{_pwd} = $arg{pwd} || '';
   $self->{_version} = $arg{version} || '3';
   $self->{_host_status} = $arg{host_status} || {};

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
# version
#----------------------------------------------------------------------------
sub version {
my ($self,$version) = @_;
   if (defined $version) {
      $self->{_version}=$version;
   }
   else { return $self->{_version}; }
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
sub check_remote_port {
my ($self,$ip)=@_;

	my $TIMEOUT=3;
	my $REMOTE_PORT = $self->port() || '389';
	my ($rc,$lapse) = $self->check_tcp_port($ip,$REMOTE_PORT,$TIMEOUT);
	if (! $rc) {
      $self->err_str('LDAP_REMOTE_TIMEOUT');
      $self->err_num(1);
	}
	return ($rc,$lapse);
}


#----------------------------------------------------------------------------
# check_remote
#----------------------------------------------------------------------------
sub check_remote {
my ($self,$ip)=@_;


   $self->err_str('[OK]');
   $self->err_num(0);
	my ($rc,$stdout,$stderr)=(1,'','');

	my $host=$self->host();
	my $user=$self->user();
	my $pwd=$self->pwd();
	my $version=$self->version();

	my $ldap = Net::LDAP->new( $host );

	my $msg = $ldap->bind( $user, password => $pwd, version => $version );

	my $code = $msg->code();
	my $error = $msg->error();

	return ($code,$error);

}

1;
__END__

