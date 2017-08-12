#----------------------------------------------------------------------------
use Crawler;
package Crawler::CNMWS;
@ISA=qw(Crawler);
$VERSION='1.00';
#----------------------------------------------------------------------------
use strict;
use JSON;
use CNMScripts::CNMAPI;

use Data::Dumper;

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::CNMWS
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_timeout} = $arg{timeout} || 3;
   $self->{_cid} = $arg{cid} || 'default';

   return $self;
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
# cid
#----------------------------------------------------------------------------
sub cid {
my ($self,$cid) = @_;
   if (defined $cid) {
      $self->{_cid}=$cid;
   }
   else { return $self->{_cid}; }
}


#----------------------------------------------------------------------------
# api_get_domain_data_from_remote
#----------------------------------------------------------------------------
# Sincroniza en el proxy (MULTI) los datos de un CNM remoto
# OUT: 0 -> OK, <>0 -> ERROR
#----------------------------------------------------------------------------
sub api_get_domain_data_from_remote  {
my ($self,$remote_cid_ip)=@_;

   my ($rc,$rcstr) = (0,'[OK]');
   $self->err_str($rcstr);
   $self->err_num($rc);

	my $log_level='info';
	my $api=CNMScripts::CNMAPI->new( 'host'=>$remote_cid_ip, 'timeout'=>10, 'nologinit'=>1 );
	my ($user,$pwd)=('admin','cnm123');
	my $sid = $api->ws_get_token($user,$pwd);

	my $endpoint='';
	my $class='multi.json';
	my $response = $api->ws_put($class,$endpoint);

	$rc=$response->{'rc'};
	$rcstr=$response->{'rcstr'};

   if ($rc != 0) {
      $self->log('warning',"api_get_domain_data_from_remote::[ERROR] CON $remote_cid_ip ($rc) $rcstr");
	}

   $self->err_str($rcstr);
   $self->err_num($rc);

   return $rc;

}


1;
