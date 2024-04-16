#-------------------------------------------------------------------------------------------
# File: CNMScripts/SMB.pm
# Description: SMB client based on smbclient
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::SMB;
@ISA=qw(CNMScripts);

use strict;
use Digest::MD5 qw(md5_hex);
use Text::Diff;
use JSON;
use Time::Local;
use IO::CaptureOutput qw/capture/;
use Data::Dumper;

=pod

=head1 NAME

CNMScripts::SMB - Modulo derivado de CNMScripts que contiene soporte para acceder a ficheros remotos por SMB/CIFS.

=head1 SYNOPSIS

 use CNMScripts::SMB;
 my $smb = CNMScripts::SMB->new();

 $smb->host_status($ip,3);
 $wmi->get_files_in_dir();

 my $ok=$smb->check_remote_port($ip,3);
 if (! $ok) { $smb->host_status($ip,10);}

=head1 DESCRIPTION

Modulo para acceso a shares remotos windows por SMB/CIFS.

=cut

my $VERSION = '1.00';

#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::SMB
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;


   my $self=$class->SUPER::new(%arg);
	$self->{_cmd} = $arg{cmd} || '/usr/bin/smbclient -m __PROTOCOL__ __N__ -U __CREDENTIALS__ __DOMAIN__ -t __TIMEOUT__ __NET_SHARE__ -c "__SMB_CMD__" 2>&1';
	$self->{_path} = $arg{path} || '';
   $self->{_host} = $arg{host} || '';
   $self->{_user} = $arg{user} || '';
   $self->{_pwd} = $arg{pwd} || '';
   $self->{_credentials} = $arg{credentials} || '';
   $self->{_domain} = $arg{domain} || '';
   $self->{_share} = $arg{share} || 'C$';
   $self->{_proto} = $arg{proto} || '';
   $self->{_pattern} = $arg{pattern} || {};
   $self->{_host_status} = $arg{host_status} || {};

	$self->set_credentials();

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
# path
#----------------------------------------------------------------------------
sub path {
my ($self,$path) = @_;
   if (defined $path) {
      $self->{_path}=$path;
   }
   else { return $self->{_path}; }
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
# domain
#----------------------------------------------------------------------------
sub domain {
my ($self,$domain) = @_;
   if (defined $domain) {
      $self->{_domain}=$domain;
   }
   else { return $self->{_domain}; }
}

#----------------------------------------------------------------------------
# share
#----------------------------------------------------------------------------
sub share {
my ($self,$share) = @_;
   if (defined $share) {
      $self->{_share}=$share;
   }
   else { return $self->{_share}; }
}

#----------------------------------------------------------------------------
# proto
#----------------------------------------------------------------------------
sub proto {
my ($self,$proto) = @_;
   if (defined $proto) {
      $self->{_proto}=$proto;
   }
   else { return $self->{_proto}; }
}

#----------------------------------------------------------------------------
# pattern
#----------------------------------------------------------------------------
sub pattern {
my ($self,$pattern) = @_;
   if (defined $pattern) {
      $self->{_pattern}=$pattern;
   }
   else { return $self->{_pattern}; }
}

=head1 METHODS

=over 1

=item B<$wmi-E<gt>host_status($host,$status)>

 Almacena en el objeto (propiedad host_status) el estado de la conexión al host.
 Sirve para casos en los que se hacen varias llamadas a get_files_in_dir en un mismo script sobre un mismo host.
 De esta forma, si no responde no se ejecuta el resto de llamadas.
 $status = 0 => ok
 $status != 0 => nok

=cut

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
# set_credentials
#----------------------------------------------------------------------------
sub set_credentials {
my ($self) = @_;

	my $c = $self->user();
	if ($self->pwd() ne '') { $c = $self->user().'%'.$self->pwd(); }
	$self->credentials($c);
   return $c;

}


#----------------------------------------------------------------------------
# check_remote_port
#----------------------------------------------------------------------------
sub check_remote_port {
my ($self,$ip,$timeout)=@_;

	my $REMOTE_PORT='445'; #microsoft-ds

	if ((! defined $timeout) || ($timeout !~ /^\d+$/)) { $timeout=3; }
	my ($rc,$lapse) = $self->check_tcp_port($ip,$REMOTE_PORT,$timeout);
	if (! $rc) {
      $self->err_str('SMB_REMOTE_PORT_TIMEOUT');
      $self->err_num(1);
	}
	return ($rc,$lapse);
}

#----------------------------------------------------------------------------
# get_files_in_dir
#smbclient -m SMB3 -N -U front -W domain //172.1.1.1/C$ -c "ls dir1/dir2/"
#----------------------------------------------------------------------------
sub get_files_in_dir {
my ($self)=@_;


	my ($stdout, $stderr,$rc)=('','',0);
	my $CMD = $self->cmd();
   my $host = $self->host();
	my $proto = $self->proto();
	my $user = $self->user();
	my $pwd = $self->pwd();
	my $share = $self->share();
	my $path = $self->path();
	my $domain = $self->domain();
	my $pattern = $self->pattern();
	my $timeout = $self->timeout();

	$self->set_credentials();
	my $credentials = $self->credentials();

	$CMD =~ s/__PROTOCOL__/$proto/g;
	my $user_pwd = $user;
	if ($pwd eq '') { $CMD =~ s/__N__/-N/g; }
	else { $CMD =~ s/__N__//g; }
	$CMD =~ s/__CREDENTIALS__/$credentials/g;

	my $net_share = '//'.$host.'/'.$share;
	$CMD =~ s/__NET_SHARE__/$net_share/g;

	my $smb_cmd = 'ls '.$path;
	if ($path !~ /.+\/$/) { $smb_cmd = 'ls '.$path.'/'; }
	$CMD =~ s/__SMB_CMD__/$smb_cmd/g;

	if ($domain eq '') { $CMD =~ s/__DOMAIN__//g; }
	else { $CMD =~ s/__DOMAIN__/-W $domain/g; }

	$CMD =~ s/__TIMEOUT__/$timeout/g;


	my ($err_num,$err_msg) = (0,'');
	$self->err_num($err_num);
	$self->err_str($err_msg);
   my @result=();
   my ($file_counter,$dir_counter,$dir_size)=(0,0,0);
   my $status = $self->host_status($host);
   if ($status > 0) {
      $self->log('info',"get_files_in_dir:: SALTO HOST $host host_status=$status CMD=$CMD");
		return {'file_counter'=>$file_counter, 'dir_counter'=>$dir_counter, 'dir_size'=>$dir_size, 'data'=>\@result };
   }

	$self->log('info',"get_files_in_dir:: CRED=$credentials || CMD=$CMD");

   capture sub { $rc=system($CMD); } => \$stdout, \$stderr;

   my @lines = split (/\n/, $stdout);
	foreach my $l (@lines) {

   	chomp $l;
   	if ($l=~/option is deprecated/) { next; }
	   if ($l=~/^Domain/) { next;}

		#Connection to 172.17.63.174 failed (Error NT_STATUS_IO_TIMEOUT)
		#session setup failed: NT_STATUS_ACCESS_DENIED
		#NT_STATUS_OBJECT_PATH_NOT_FOUND listing \asw\buffer\
		if ($l=~/NT_STATUS/) { 
			$err_msg = $l;			
			$self->err_str($err_msg);
			if ($l=~/NT_STATUS_IO_TIMEOUT/) { $self->err_num(2); }
			elsif ($l=~/NT_STATUS_ACCESS_DENIED/) { $self->err_num(3); }
			elsif ($l=~/NT_STATUS_OBJECT_PATH_NOT_FOUND/) { $self->err_num(4); }
			else { $self->err_num(5); }
			$self->log('error',"get_files_in_dir:: **ERROR** $host $err_msg");
			last;
		}

   	if ($l=~/^\s*\.\s+/) { next;}
	   if ($l=~/^\s*\.\.\s+/) { next;}
   	if ($l !~ /^\s*(.+?)\s+(\w+)\s+(\d+)\s+(\w+\s+\w+\s+\d+\s+\d+\:\d+\:\d+\s+\d+)$/) {
			$self->log('debug',"get_raw_data >> L=$l");
      	next;
   	}
   	my ($file,$type,$size,$date) = ($1, $2, $3, $4);
		push @result, {'file'=>$file, 'type'=>$type, 'size'=>$size, 'date'=>$date};

	   $dir_size += $size;
   	if ($pattern ne '') {
      	if ($file=~/$pattern/) {
         	if ($type eq 'A') { $file_counter+=1; }
         	elsif (($type eq 'D')||($type eq 'DH')) { $dir_counter+=1; }
	      }
   	}
   	else {
      	if ($type eq 'A') { $file_counter+=1; }
      	elsif (($type eq 'D')||($type eq 'DH')) { $dir_counter+=1; }
   	}

		$self->log('debug',"get_files_in_dir:: file=$file type=$type size=$size date=$date file_counter=$file_counter");
	}

	return {'file_counter'=>$file_counter, 'dir_counter'=>$dir_counter, 'dir_size'=>$dir_size, 'data'=>\@result }; 

	$self->host_status($host,$self->err_num());

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

