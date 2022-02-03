#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/MySQL.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::MySQL;
@ISA=qw(CNMScripts);

use strict;
use Digest::MD5 qw(md5_hex);
use Text::Diff;
use JSON;
use Time::Local;
use IO::CaptureOutput qw/capture/;
use Data::Dumper;
use Encode qw(encode_utf8);
#use libSQL;

my $VERSION = '1.00';

#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::MySQL
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;


   my $self=$class->SUPER::new(%arg);
   $self->{_cmd} = $arg{cmd} || 'mysql --vertical';
   $self->{_host} = $arg{host} || '';
   $self->{_port} = $arg{port} || '3306';
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
   else { 
		my $timeout = $self->{_timeout} || 30;
		$self->{_cmd} =~ s/__TIMEOUT__/$timeout/;
		return $self->{_cmd}; 
	}
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
	my $REMOTE_PORT = $self->port() || '3306';
	my ($rc,$lapse) = $self->check_tcp_port($ip,$REMOTE_PORT,$TIMEOUT);
	if (! $rc) {
      $self->err_str('MySQL_REMOTE_TIMEOUT');
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

   my $database_option = '';
   if ($self->db() ne '') { $database_option = $self->db(); }
   my $CMD = $self->cmd().' -h '.$self->host().' -u '.$self->user().' -p'.$self->pwd.' '.$database_option.' -e "SELECT 1"';

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
my ($self,$sqlcmd,$params)=@_;

   #$|=1;
   my $host = $self->host();
   my $status = $self->host_status($host);

   if ($status > 0) {
      $self->log('info',"sqlcmd_run >>SALTO HOST $host status=$status sql=$sqlcmd");
      return;
   }

   my ($rc,$stdout,$stderr)=(0,'','');
   $self->err_str('[OK]');
   $self->err_num(0);

	my $fields = [];
	if ((exists $params->{'fields'}) && (ref($params->{'fields'}) eq 'ARRAY')) { $fields = $params->{'fields'}; }

   my $database_option = '';
   if ($self->db() ne '') { $database_option = $self->db();}

   my $cmdc = $self->cmd().' -h '.$host.' -u '.$self->user().' -p'.$self->pwd.' '.$database_option.' -e "'.$sqlcmd.'"';
   $self->log('info',"sqlcmd_run >> $cmdc");


   capture sub { $rc=system($cmdc); } => \$stdout, \$stderr;

   my @data=();
	my %result=();
   if ($stderr ne '') {

      # Para evitar salidas espureas
      $stderr=~s/\n/ /g;

		#ERROR 1146 (42S02) at line 1: Table ...
		my $rcode=1;
		if ($stderr=~/ERROR (\d+)/) { $rcode=$1; }
      $self->err_str($stderr);
      $self->err_num($rcode);
      $self->log('error',"sqlcmd_run >> **ERROR** stderr=$stderr (cmdc=$cmdc)");
   }
   else {

      my @lines = split (/\n/, $stdout);
      foreach my $l (@lines) {
			chomp $l;
			#*************************** 1. row ***************************
			if ($l=~/^\*+\s*(\d+)\.\s*row\s*\*+$/)	{
				if (scalar(keys %result)>0) { push @data, {%result}; }
				%result=();
			}
			else {
				my ($k,$v) = split(/\s*\:\s*/,$l);
				$k=~s/^\s+(.+)/$1/g;
				#$result{$k}=$v;
				$result{'label'}=$k;
				$result{'value'}=$v;
			}
		}
   }

	if (scalar(keys %result)>0) { push @data, \%result; }
	
	push @data, { 'label'=>'RC', 'value'=>$self->err_num() };


   $self->host_status($host,$self->err_num());

   return \@data;

}

1;
__END__

