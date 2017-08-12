#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/SyslogRaw.pm
# Descripcion:
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::SyslogRaw;
@ISA=qw(CNMScripts);

use strict;
use POSIX qw/strftime/;
use Net::RawIP;
use Data::Dumper;

my $VERSION = '1.00';

#-------------------------------------------------------------------------------------------
# TAG               CODE    DESCRIPTION
# =====================================
# kernel            0       kernel messages
# user              1       user-level messages
# mail              2       mail system
# system            3       system daemons
# security          4       security/authorization messages (note 1)
# internal          5       messages generated internally by syslogd
# print             6       line printer subsystem
# news              7       network news subsystem
# uucp              8       UUCP subsystem
# clock             9       clock daemon (note 2)
# security2        10       security/authorization messages (note 1)
# ftp              11       FTP daemon
# ntp              12       NTP subsystem
# logaudit         13       log audit (note 1)
# logalert         14       log alert (note 1)
# clock2           15       clock daemon (note 2)
# local0           16       local use 0  (local0)
# local1           17       local use 1  (local1)
# local2           18       local use 2  (local2)
# local3           19       local use 3  (local3)
# local4           20       local use 4  (local4)
# local5           21       local use 5  (local5)
# local6           22       local use 6  (local6)
# local7           23       local use 7  (local7)
my $i = 0;
my %FACILITIES = map {$_ => $i++ } qw/kernel user mail system security internal print news uucp clock security2 ftp ntp logaudit logalert clock2 local0 local1 local2 local3 local4 local5 local6 local7/;

#-------------------------------------------------------------------------------------------
# TAG             CODE    DESCRIPTION
# =====================================
# emerg           0       Emergency: system is unusable
# alert           1       Alert: action must be taken immediately
# crit            2       Critical: critical conditions
# err             3       Error: error conditions
# warn            4       Warning: warning conditions
# notice          5       Notice: normal but significant condition
# info            6       Informational: informational messages
# debug           7       Debug: debug-level messages
$i = 0;
my %SEVERITIES = map {$_ => $i++} qw/emerg alert crit err warn notice info debug/;

#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::SyslogRaw
#-------------------------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_src_ip} = $arg{src_ip} || '127.0.0.1';
   $self->{_dst_ip} = $arg{dst_ip} || '127.0.0.1';
   $self->{_facility} = $arg{facility} || 'user';
   $self->{_pname} = $arg{pname} || 'CNMScripts::SyslogRaw';
   $self->{_err_num} = $arg{err_num} || 0;
   $self->{_err_str} = $arg{err_str} || '';

   my %IPPkt = (saddr => $self->{_src_ip}, daddr => $self->{_dst_ip}, tos => 0, id => 0);
   my %UDPPkt = (source => '10666', dest   => '514');
   $self->{_packet} = Net::RawIP->new({ip => \%IPPkt, udp => \%UDPPkt });
	
   return $self;
}

#----------------------------------------------------------------------------
# src_ip
#----------------------------------------------------------------------------
sub src_ip {
my ($self,$src_ip) = @_;
   if (defined $src_ip) {
      $self->{_src_ip}=$src_ip;
   }
   else { return $self->{_src_ip}; }
}

#----------------------------------------------------------------------------
# dst_ip
#----------------------------------------------------------------------------
sub dst_ip {
my ($self,$dst_ip) = @_;
   if (defined $dst_ip) {
      $self->{_port}=$dst_ip;
   }
   else { return $self->{_dst_ip}; }
}

#----------------------------------------------------------------------------
# facility
#----------------------------------------------------------------------------
sub facility {
my ($self,$facility) = @_;
   if (defined $facility) {
      $self->{_facility}=$facility;
   }
   else { return $self->{_facility}; }
}

#----------------------------------------------------------------------------
# pname
#----------------------------------------------------------------------------
sub pname {
my ($self,$pname) = @_;
   if (defined $pname) {
      $self->{_pname}=$pname;
   }
   else { return $self->{_pname}; }
}

#----------------------------------------------------------------------------
# packet
#----------------------------------------------------------------------------
sub packet {
my ($self,$packet) = @_;
   if (defined $packet) {
      $self->{_packet}=$packet;
   }
   else { return $self->{_packet}; }
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

#my $syslog_raw=CNMScripts::SyslogRaw('src_ip'=>$src, 'dst_ip'=>$dst, 'facility'=>'local2');
#$syslog_raw->send($severity,$msg);

#----------------------------------------------------------------------------
# send 
#----------------------------------------------------------------------------
sub send {
my ($self,$severity,$tag,$txt) = @_;

	my $facility=$self->facility();
   my $datetime = strftime("%b %d %H:%M:%S", localtime());

	my $packet=$self->packet();
	my $src=$self->src_ip();
	my $pname=$self->pname();

   my $msg=$datetime." $src: [$pname] $tag >> $txt\n";
   my ($fac_sev) = ($FACILITIES{$facility} << 3) + $SEVERITIES{$severity};
   $packet->set({ udp => {  data => "<$fac_sev>$msg"  }  } );


   my($src1, $dst1, $data) = $packet->get( { udp => [qw/source dest data/]  }, );
   my $size = length($src1) + length($dst1) + length($data);
   $packet->set( {  udp => {  len   => $size, check => 0,  } });

	my ($delay, $amount)=(1,1);
   $packet->send($delay, $amount);
}

#----------------------------------------------------------------------------
# app_data2syslog
#----------------------------------------------------------------------------
sub app_data2syslog {
my ($self,$results)=@_;

   foreach my $cmd (sort keys %$results) {
		$self->send('info', $cmd, $results->{$cmd}->{'stdout'});
		if ($results->{$cmd}->{'stderr'} ne '') {
      	$self->send('info', $cmd, $results->{$cmd}->{'stderr'});
		}
	}
}

#----------------------------------------------------------------------------
# app_data2syslog_ml
#----------------------------------------------------------------------------
sub app_data2syslog_ml {
my ($self,$results)=@_;

   foreach my $cmd (sort keys %$results) {

      my $stdout=$results->{$cmd}->{'stdout'};
      my @lines1 = split(/\n/, $stdout);
      foreach my $l (@lines1) { $self->send('info', $cmd, $l);  }

      my $stderr=$results->{$cmd}->{'stderr'};
      my @lines2 = split(/\n/, $stderr);
      foreach my $l (@lines2) { $self->send('info', $cmd, $l); }
   }
}

1;

__END__

