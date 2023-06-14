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
   $self->{_domain} = $arg{domain} || '';
   $self->{_pwd} = $arg{pwd} || '';
   $self->{_timeout} = $arg{timeout} || 20;
   $self->{_remote_dir} = $arg{remote_dir} || '/none';
   $self->{_local_dir} = $arg{local_dir} || '/none';
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
# local_dir
#----------------------------------------------------------------------------
sub local_dir {
my ($self,$local_dir) = @_;
   if (defined $local_dir) {
      $self->{_local_dir}=$local_dir;
   }
   else { return $self->{_local_dir}; }
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
   my $domain = $self->domain();
   my $pwd = $self->pwd();
   my $connect_timeout = $self->timeout();
   my $remote_dir = $self->remote_dir();
   my $local_dir = $self->local_dir();
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

   elsif ($proto=~/smb3/i) {

		$remote_dir =~ s/^\///;
		if ($local_dir eq '/none') { 
			$local_dir = '/mnt/'.$host.'/'.$remote_dir; 
			$self->local_dir($local_dir);
		}

     	if (! -d $local_dir) { `mkdir -p $local_dir`; }

		my $domain_str = ($domain eq '') ? '' : "domain=$domain";
	
     	my $cmd_mount = "mount -v -t cifs -o vers=3.0,username=$user,password=$pwd,$domain_str //$host/$remote_dir $local_dir 2>&1";

		my $check_mount_cmd = "findmnt -n -o TARGET $local_dir";
		my $is_mounted = `$check_mount_cmd 2>&1`;
		chomp $is_mounted;
		if ($is_mounted eq $local_dir) {
			$self->log('debug',"MOUNTED PREVIOUSLY ($local_dir)");
		}
		else {
			my $x = `$cmd_mount`;
			$self->log('debug',"MOUNTING $host/$remote_dir -> $local_dir  ($x)");
		}

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

   elsif ($proto=~/smb3/i) {

		my $local_dir =  $self->local_dir();	
	   my $rcx = opendir (DIR,$local_dir);
      if ( ! $rcx) {
			$rc = 10;
         $self->err_str("**ERROR** EN OPENDIR $local_dir ($!)");
			return;
      }

   	while ( my $filename = readdir(DIR) ) {

			my %item=('filename'=>'', 'longname'=>'', 'type'=>'', 'size'=>'', 'atime'=>'', 'atime_str'=>'');
         $item{'filename'} = $filename;
         $item{'longname'} = "$remote_dir/$filename";
         if (($item{'filename'} eq '.') || ($item{'filename'} eq '..')) { next; }

			my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat("$local_dir/$filename");

			$item{'hlinks'} = $nlink;
			if ($item{'hlinks'}>1) { $item{'type'}='d' }
         else { $item{'type'}='f' }

         $item{'size'} = $size;
         $item{'atime'} = $mtime;
         $item{'atime_str'} = localtime($mtime);

			push @files,\%item;

		}

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
      	   $item{'hlinks'} = $tab[3];
				# Si el numero de hard links es mayor de 1 es un directorio
				# Si es 1 es un fichero.
				if ($item{'hlinks'}>1) { $item{'type'}='d' }
				else { $item{'type'}='f' }  
      	   #$item{'type'} = $tab[6];

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
	elsif ($proto=~/smb/i) {

		my $smb = $self->remote();
		my $remote_dir = $self->remote_dir();
		my $remote_file = ($remote_dir !~ /\/$/) ? "$remote_dir/$filerx" : $remote_dir.$filerx;
		if (open (L, "<$filetx")) {

			my $fw = $smb->open(">smb://$remote_file", 0666) or print "**ERROR** writing to $remote_file ($!)\n";

			while (<L>) {

				$smb->write($fw, $_); 
			}

			$smb->close($fw);
			close L;
		}
		else {

			$self->log('warning',"**ERROR** opening $remote_file ($!)");
		}
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
   elsif ($proto=~/smb/i) {

      my $smb = $self->remote();
      my $remote_dir = $self->remote_dir();

      my $remote_file = ($remote_dir !~ /\/$/) ? "$remote_dir/$from" : $remote_dir.$from;

		my $fr = $smb->open("<smb://$remote_file", 0666);
		open (G, ">$to");

		while (defined(my $l= $smb->read($fr,1024))) {

			print G $l; 
		}

		$smb->close();
		close G;

	}

   return $ok;
}

#----------------------------------------------------------------------------
# close
#----------------------------------------------------------------------------
sub close {
my ($self)=@_;

   my $proto = $self->proto();
	my $local_dir = $self->local_dir();
	if (($local_dir eq '/') || ($local_dir eq '/mnt')) {
		$self->log('warning',"**ERROR** Not allowed unmounting $local_dir");
		return; 
	}

   if ($proto=~/smb3/i) {
		my $cmd = "umount -flv $local_dir 2>&1";
		my $x = `$cmd`;
		chomp $x;
		if ($x !~ /unmounted/) {
			 $self->log('warning',"**ERROR** unmounting $local_dir ($x) ($cmd)");
		}
#print "cmd=$cmd >> ($x)\n";		
   }

   return; 
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



1;
__END__

