#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/FreeTDS.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::FreeTDS;
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
# Descripcion: Crea un objeto del tipo CNMScripts::FreeTDS
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;


   my $self=$class->SUPER::new(%arg);
   $self->{_cmd} = $arg{cmd} || "docker run  core/freetds /bin/bash -c \"/usr/bin/tsql -H __HOST__ -p __PORT__ -D __DDBB__ -U __USER__ -P __PWD__ <<EOS
__SQL_QUERY__
GO
exit
EOS
\"";

   $self->{_host} = $arg{host} || '';
   $self->{_port} = $arg{port} || '1433';
   $self->{_user} = $arg{user} || '';
   $self->{_pwd} = $arg{pwd} || '';
   $self->{_db} = $arg{db} || '';
   $self->{_sqlcmd} = $arg{sqlcmd} || 'SELECT @@VERSION';
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
# sqlcmd
#----------------------------------------------------------------------------
sub sqlcmd {
my ($self,$sqlcmd) = @_;
   if (defined $sqlcmd) {
      $self->{_sqlcmd}=$sqlcmd;
   }
   else { return $self->{_sqlcmd}; }
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
	my $REMOTE_PORT = $self->port() || '1433';
	my ($rc,$lapse) = $self->check_tcp_port($ip,$REMOTE_PORT,$TIMEOUT);
	if (! $rc) {
      $self->err_str('FreeTDS_REMOTE_TIMEOUT');
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

	my $CMD = $self->cmd();
	my $host = $self->host();
	$CMD =~ s/__HOST__/$host/;
	my $CMD=$self->cmd().' '.$self->host().' -U '.$self->user().' -P '.$self->pwd.' -Q "SELECT @@VERSION"';

	capture sub { $rc=system($CMD); } => \$stdout, \$stderr;

   if ($stderr ne '') {
      $stderr=~s/\n/\. /g;
      $self->log('info',"check_remote >> **ERROR** [$rc] >> $stderr");
      $self->err_str("[ERR] $stderr");
      $self->err_num(1);
      $rc=0;
   }

   else {
		$stdout=~s/\n/ /g;
      $self->log('info',"check_remote >> OK $stdout");
   }

   return $rc;

}

#----------------------------------------------------------------------------
# sqlcmd_rum
#----------------------------------------------------------------------------
sub sqlcmd_run {
my ($self,$sql,$params)=@_;

   #$|=1;
   my $host = $self->host();
   my $status = $self->host_status($host);

   if ($status > 0) {
      $self->log('info',"sqlcmd_run >>SALTO HOST $host status=$status sql=$sql");
      return;
   }

	my $sqlcmd = 'SET NOCOUNT ON;'.$sql;
	if ((defined $params) && (ref($params) eq 'HASH')) {
		if (exists ($params->{'json'})) { $sqlcmd .= ' FOR JSON AUTO'; }
	}

   my ($rc,$stdout,$stderr)=(0,'','');
   $self->err_str('[OK]');
   $self->err_num(0);

   my $cmdc = $self->cmd().' '.$host.' -U '.$self->user().' -P '.$self->pwd.' -Q "'.$sqlcmd.'"';
   $self->log('info',"sqlcmd_run >> $cmdc");

	capture sub { $rc=system($cmdc); } => \$stdout, \$stderr;

	my $data=[];
   if ($stderr ne '') {

      # Para evitar salidas espureas
      $stderr=~s/\n/ /g;
      $self->err_str($stderr);
      $self->err_num(10);
      $self->log('error',"sqlcmd_run >> **ERROR** stderr=$stderr (cmdc=$cmdc)");
   }
	else {
		$stdout=~s/\r//g;
		$stdout=~s/\n//g;

		$data = eval { decode_json($stdout) };
		if ($@) {
			$data=[];
			$self->err_str($@);
	      $self->err_num(11);
   	   $self->log('error',"sqlcmd_run >> **ERROR JSON** $@ (cmdc=$cmdc)");
		}
	}

   $self->host_status($host,$self->err_num());

   return $data;

}

1;
__END__

