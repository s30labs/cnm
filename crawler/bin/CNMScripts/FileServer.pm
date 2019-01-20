#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/FileServer.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::FileServer;
@ISA=qw(CNMScripts);

use strict;
use Digest::MD5 qw(md5_hex);
use Data::Dumper;
use Net::SFTP::Foreign;
#$Net::SFTP::Foreign::debug=-1;
use Filesys::SmbClient;
use Fcntl qw(S_ISDIR);

my $VERSION = '1.00';

#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::FileServer
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;


   my $self=$class->SUPER::new(%arg);
   $self->{_proto} = $arg{proto} || 'sftp';
   $self->{_host} = $arg{host} || '';
   $self->{_port} = $arg{port} || '22';
   $self->{_user} = $arg{user} || '';
   $self->{_pwd} = $arg{pwd} || '';
   $self->{_timeout} = $arg{timeout} || 20;
   $self->{_remote_dir} = $arg{remote_dir} || '/';
   $self->{_action} = $arg{action} || {};
   $self->{_remote} = $arg{remote} || undef;	#Connection Object handler

   return $self;
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
# remote_dir
#----------------------------------------------------------------------------
sub remote_dir {
my ($self,$remote_dir) = @_;
   if (defined $remote_dir) {
      $self->{_remote_dir}=$remote_dir;
   }
   else { return $self->{_remote_dir}; }
}

#----------------------------------------------------------------------------
# action
#----------------------------------------------------------------------------
sub action {
my ($self,$action) = @_;
   if (defined $action) {
      $self->{_action}=$action;
   }
   else { return $self->{_action}; }
}

#----------------------------------------------------------------------------
# remote
#----------------------------------------------------------------------------
sub remote {
my ($self,$remote) = @_;
   if (defined $remote) {
      $self->{_remote}=$remote;
   }
   else { return $self->{_remote}; }
}

#----------------------------------------------------------------------------
# check_remote_port
#----------------------------------------------------------------------------
sub check_remote_port {
my ($self,$ip)=@_;

	my $TIMEOUT=3;
	my $REMOTE_PORT = $self->port() || '22';
	my ($rc,$lapse) = $self->check_tcp_port($ip,$REMOTE_PORT,$TIMEOUT);
	if (! $rc) {
      $self->err_str("ERROR >> TCP CONNECT TO PORT $REMOTE_PORT");
      $self->err_num(1);
	}
	return ($rc,$lapse);
}


#----------------------------------------------------------------------------
# connect
#----------------------------------------------------------------------------
sub connect {
my ($self)=@_;

   my $proto = $self->proto();
   my $host = $self->host();
   my $port = $self->port();
   my $user = $self->user();
   my $pwd = $self->pwd();
   my $connect_timeout = $self->timeout();
   my $remote_dir = $self->remote_dir();
   my $action = $self->action();

	my $rc=0;
   if ($proto=~/sftp/i) {

      # -o => 'StrictHostKeyChecking=no'
      my $sftp = Net::SFTP::Foreign->new( $host, 'port'=>$port, 'user'=>$user, 'password'=>$pwd, 'timeout'=>$connect_timeout );
		$self->remote($sftp);
		my $rcstr = $sftp->error;

		$self->err_str($rcstr);
		if ($sftp->error) { $rc=1; }
   }

	elsif ($proto=~/smb/i) {

		my $workgroup = "";
		my $smb = new Filesys::SmbClient( username  => $user, password  => $pwd, workgroup => $workgroup, debug => 0);
		$self->remote($smb);

	}	


	$self->err_num($rc);
	return $rc;

}

#----------------------------------------------------------------------------
# ls
#----------------------------------------------------------------------------
sub ls {
my ($self)=@_;

	my $proto = $self->proto();
	my $host = $self->host();
	my $remote_dir = $self->remote_dir();
	my $rc = 0;
	my @files=();
	if ($proto=~/sftp/i) {

		my $sftp = $self->remote();

      my $ls = $sftp->ls($remote_dir);
		foreach my $l (@$ls) {
         my %item=('filename'=>'', 'longname'=>'', 'type'=>'', 'size'=>'', 'atime'=>'', 'atime_str'=>'');
         $item{'filename'} = $l->{filename}; 
         $item{'longname'} = "$remote_dir/$item{'filename'}";
			if (($item{'filename'} eq '.') || ($item{'filename'} eq '..')) { next; }

			if (S_ISDIR($l->{a}->perm)) { $item{'type'}='d' }
			else { $item{'type'}='f' }
			$item{'size'} = $l->{a}->{size};

         $item{'atime'} = $l->{a}->atime;
			$item{'atime_str'} = localtime($item{'atime'});
			push @files, \%item;
		}


	   my $rcstr = $sftp->error;
		$self->err_str($rcstr);
     	if ($sftp->error) { $rc=3; }
	}

	elsif ($proto=~/smb/i) {

		my $smb = $self->remote();
	   my $fd = $smb->opendir("smb://$host/$remote_dir");

   	foreach my $filename ($smb->readdir($fd)) {

			my %item=('filename'=>'', 'longname'=>'', 'type'=>'', 'size'=>'', 'atime'=>'', 'atime_str'=>'');
         $item{'filename'} = $filename;
         $item{'longname'} = "$remote_dir/$filename";
      	if (($item{'filename'} eq '.') || ($item{'filename'} eq '..')) { next; }
     		my @tab = $smb->stat("smb://$host/$remote_dir/$filename");
	      if ($#tab == 0) { 
				$self->err_str("**ERROR** in stat de $remote_dir/$filename: ($!)");
			}
   	   else {
      	   $item{'type'} = $tab[6];
      	   $item{'size'} = $tab[7];
         	$item{'atime'} = $tab[11];
         	$item{'atime_str'} = localtime($tab[11]);
      	}

			push @files,\%item;
		}
	}

	$self->err_num($rc);

	return \@files;
}

#----------------------------------------------------------------------------
# put
#----------------------------------------------------------------------------
sub put {
my ($self,$filetx,$filerx)=@_;

   my $ok = 1;
	my $proto = $self->proto();
   if ($proto=~/sftp/i) {

      my $sftp=$self->remote();
		$ok = $sftp->put($filetx, $filerx);
      my $rcstr = $sftp->error;
      $self->err_str($rcstr);
   }

   return $ok;
}

#----------------------------------------------------------------------------
# get
#----------------------------------------------------------------------------
sub get {
my ($self,$from,$to)=@_;

   my $ok = 1;
	my $proto = $self->proto();
   if ($proto=~/sftp/i) {

      my $sftp=$self->remote();
		$ok = $sftp->get($from,$to);

      my $rcstr = $sftp->error;
      $self->err_str($rcstr);
   }

   return $ok;
}


#----------------------------------------------------------------------------
# remove
#----------------------------------------------------------------------------
sub remove {
my ($self,$file)=@_;

   my $ok = 1;
	my $proto = $self->proto();
   if ($proto=~/sftp/i) {

		my $sftp=$self->remote();
      $sftp->remove($file);

      my $rcstr = $sftp->error;
      $self->err_str($rcstr);
   }

   return $ok;
}

#----------------------------------------------------------------------------
# status
#----------------------------------------------------------------------------
sub status {
my ($self)=@_;

   my $code = 0;
	my $proto = $self->proto();
   if ($proto=~/sftp/i) {

		my $sftp=$self->remote();
      $code = $sftp->status();

      my $rcstr = $sftp->error;
      $self->err_str($rcstr);
   }

   return $code;
}






#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

1;
__END__

