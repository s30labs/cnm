#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/CIFS.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::CIFS;
@ISA=qw(CNMScripts);

use strict;
use IO::CaptureOutput qw/capture/;
use File::Basename;
use Data::Dumper;

#-------------------------------------------------------------------------------------------
my $VERSION = '1.00';


#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::CIFS
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_host} = $arg{host} || '';
   $self->{_credentials} = $arg{credentials} || 'username=abc,password=xyz';
   $self->{_share} = $arg{share} || '';
   $self->{_err_num} = $arg{err_num} || 0;
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
#----------------------------------------------------------------------------
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# check_remote_port
#----------------------------------------------------------------------------
sub check_remote_port {
my ($self,$ip)=@_;

my $REMOTE_PORT='445';
my $TIMEOUT=3;

   my ($rc,$lapse) = $self->check_tcp_port($ip,$REMOTE_PORT,$TIMEOUT);
   if (! $rc) {
      $self->err_str('CIFS_REMOTE_TIMEOUT');
      $self->err_num(1);
   }
   return ($rc,$lapse);
}


#----------------------------------------------------------------------------
# check_remote
#----------------------------------------------------------------------------
sub check_remote {
my ($self,$ip)=@_;

#root@cnm-pro:/opt/cnm# smbclient -U spectrum%1cyXslt -L v3krooc3
#Domain=[GRUPO] OS=[Windows Server 2003 3790 Service Pack 2] Server=[Windows Server 2003 5.2]

   $self->err_str('[OK]');
   $self->err_num(0);

	my $host = $self->host();
   my ($user,$pwd) = ('','');
   my $credentials = $self->credentials();
   if ($credentials =~ /\-user\s*\=\s*(\S+)/) { $user=$1; }
   if ($credentials =~ /\-pwd\s*\=\s*(\S+)/) { $pwd=$1; }



   my $cmd = "/usr/bin/smbclient -U $user\%$pwd -L $host";
#   my ($rc,$stdout, $stderr)=(0,'','');
#   capture sub { $rc=system($cmd); } => \$stdout, \$stderr;

	my $out = `$cmd 2>&1`;
   $out=~s/\n/\. /g;

   $self->log('debug',"check_remote >> CMD=$cmd");
   $self->log('debug',"check_remote >> OUT=$out");


   if ($out =~ /NT_STATUS/) {
      $self->err_num(20);
      $self->err_str("ERROR ACCESO CIFS - $out");
      $self->log('error',"ERROR ACCESO CIFS cmd=$cmd");
      $self->log('error',"ERROR ACCESO CIFS out=$out");
		return 0;
   }

	return 1;

}

#----------------------------------------------------------------------------
# connect
#----------------------------------------------------------------------------
sub connect {
my ($self) = @_;

	$self->err_num(0);
   $self->err_str('[OK]');

   my $host = $self->host();
	my $ok = $self->check_remote($host);
   if (! $ok ) {
      $self->err_num(1);
      $self->err_str("ERROR NO RESPONDE EL PUERTO DE SERVICIO");
		$self->log('error',"ERROR NO RESPONDE EL PUERTO DE SERVICIO");
      return undef;
   }

   # --------------------------------------
   # $credentials es del tipo:
   # -user=aaaa -pwd=bbb
   # --------------------------------------
   my ($user,$pwd,$mount_point) = ('','','');
   my $credentials = $self->credentials();
   if ($credentials =~ /\-user\s*\=\s*(\S+)/) { $user=$1; }
   if ($credentials =~ /\-pwd\s*\=\s*(\S+)/) { $pwd=$1; }

	if ( ($user eq '') || ($pwd eq '')) {
      $self->err_num(10);
      $self->err_str("ERROR con las credenciales $credentials. Lo correcto es -user=abc -pwd=xyz");
		$self->log('error',"ERROR con las credenciales $credentials. Lo correcto es -user=abc -pwd=xyz");
		return $mount_point;
	}

   my $share = $self->share();

   if ( ($host eq '') || ($share eq '')) {
      $self->err_num(11);
      $self->err_str("ERROR con host=$host o share=$share");
		$self->log('error',"ERROR con host=$host o share=$share");
      return $mount_point;
   }


#      my $check = '/usr/bin/smbclient -L '.$parts[0].' -U '.
#                  $config_channels->{$channel}->{$part}->{'user'}. ' '.
#                  $config_channels->{$channel}->{$part}->{'share'}. ' '.
#                  $config_channels->{$channel}->{$part}->{'password'}. ' 2>&1 | /bin/grep '.$parts[$n-1];
#
#      $logger->debug("share_connect[$$]:: ch=$channel EJECUTO1 $check");
#      my $res1=`$check`;

	my $share_mod=$share;
	$share_mod=~s/\//_/g;
   $mount_point = '/mnt/'.$host.'-'.$share_mod;

	if (! -d $mount_point) {  mkdir $mount_point; }

   # /bin/mount -t cifs -o username=s30,password= //10.2.254.71/log /opt/mnt/chx/0070
   my $connect = "/bin/mount -t cifs -o username=$user,password=$pwd //$host/$share $mount_point";

#/bin/mount -t cifs -o username=s30,password=s30 //10.2.254.71///log/ /mnt/10.2.254.71-__log_

	my ($rc,$stdout, $stderr)=(0,'','');
	capture sub { $rc=system($connect); } => \$stdout, \$stderr;
#        $self->log('info',"_start_external_cmd:: [$tag] ID=$id_qactions EXEC APP RAW IP=$ip cmd=$cmd file=$f format=$format");


#   my $res=`$connect 2>&1`;
#   $res=~s/\n/\. /g;
#
	$self->log('info',"CONNECT $connect (RES=$rc)");
   #$rc=$self->check_mounted_df($channel,$mount_point,$config_channels->{$channel}->{$part}->{'share'});

	if ($stderr ne '') {
		$stderr=~s/\n/\. /g;
      $self->err_num(20);
      $self->err_str("ERROR EN MOUNT  ($connect) $stderr");
		$self->log('error',"ERROR EN MOUNT  ($connect) $stderr");
	}	

	return $mount_point;
}


#----------------------------------------------------------------------------
# disconnect
#----------------------------------------------------------------------------
sub disconnect {
my ($self,$mount_point) = @_;

#	my $logger = $self->logger();
   my $disconnect =  "/bin/umount -f -l $mount_point";
   system ($disconnect);
	#$logger->info("[$$] EJECUTO $disconnect");
	$self->log('info',"EJECUTO $disconnect");

}

#-----------------------------------------------------------------------
# check_mounted_df
# A partir de un punto de montaje verifica si esta montado a un sistema de
# ficheros concreto
# oneway:/opt/oneway/bin# df -h /opt/mnt/chx/0070
# Filesystem            Size  Used Avail Use% Mounted on
# //10.2.254.211/usersmb1
#                       2.8G  853M  1.8G  33% /opt/mnt/chx/0070
#
# oneway:/opt/oneway/modules/SCom# df -h /opt/mnt/chx/0130
# Filesystem            Size  Used Avail Use% Mounted on
# curlftpfs#ftp://userftp1:passftp1@10.2.254.213:21/
#                      7.5T     0  7.5T   0% /opt/mnt/chx/0130
#
#-----------------------------------------------------------------------
#sub check_mounted_df {
#my ($self,$channel,$mnt_point,$share)=@_;
#
#   my $logger = $self->logger();
#   my $cmd="/bin/df -h $mnt_point 2>&1";
#   my @res=`$cmd`;
#   my ($share0, $size0, $used0, $avail0, $use0, $mnt_point0)= split (/\s+/,$res[1]);
#
#   my $rc=0;
#   $share0 =~ s/^(.*)\/$/$1/;
#   $share =~ s/^(.*)\/$/$1/;
#   if ($share eq $share0) { $rc=1; }
#
#   $logger->debug("check_mounted_df[$$]:: ch=$channel share0=$share0 share=$share ($mnt_point) rc=$rc");
#
#   return $rc;
#}

1;

__END__

