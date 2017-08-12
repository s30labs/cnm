#-------------------------------------------------------------------------------------------
# Fichero: CNMScripts/LogAnalysis.pm
# Descripcion:
# Modulo encargado de analizar los datos de log almacenados en las tablas logp_xxxx
#-------------------------------------------------------------------------------------------
use CNMScripts;
package CNMScripts::LogAnalysis;
@ISA=qw(CNMScripts);

use strict;
use File::Basename;
use Data::Dumper;

#-------------------------------------------------------------------------------------------
my $VERSION = '1.00';

#elect line  from logp_010002254223_varlogmessages WHERE ts>UNIX_TIMESTAMP(NOW()-300) AND line like '%Invalid user%';
#-------------------------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo CNMScripts::LogAnalysis
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
sub get_data_lines {
my ($self,$info)=@_;


	my $ip = $info->{'ip'};
	my $file = $info->{'file'};
	my $lapse = $info->{'lapse'};
	my $pattern = $info->{'pattern'};

	my $table = $self->get_table_name($ip,$file);

   my $sql ="SELECT line FROM $table WHERE ts>UNIX_TIMESTAMP(NOW()-$lapse)";
	if (exists $info->{'pattern'}) { $sql .= " AND line like '%$pattern%'"; }
	$sql .= " ORDER BY ts";

	my $dbh = $self->dbConnect();
   my $lines = $self->dbSelectAll($dbh, $sql);
	$self->dbDisconnect($dbh);

use Data::Dumper;
print Dumper($lines);

#print Dumper($activities)."---\n";
#          'ana_1234' => {
#                          'subtype' => 'status_mibii_if',
#                          'monitor' => 's_status_mibii_if-23f569ba',
#                          'type' => 'snmp',
#                          'asubtype' => 'ana_1234'
#                        }
#        };



#   foreach my $k (sort keys %$activities) {
#
#      my $subtype=$activities->{$k}->{'subtype'};
#      my $monitor=$activities->{$k}->{'monitor'};
#      my $expr=$activities->{$k}->{'expr'};
#
#	}

}


#----------------------------------------------------------------------------
sub get_table_name {
my ($self,$ip,$logfile)=@_;

   # ------------------------------------------------------
   # logp_ip_logfile   >> logp_010001001001_varlogmessages
   # logp_010002254223_varlogapacheerrorlog
   my @o = split(/\./,$ip);
   my @o3 = map { sprintf("%03d",$_) } @o;
   $logfile =~s/\///g;
   $logfile =~s/\.//g;
   $logfile =~s/\s//g;

   my $table = 'logp_'.join ('',@o3).'_'.$logfile;
	
	return $table;
}

1;

__END__

