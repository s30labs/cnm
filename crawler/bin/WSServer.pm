package WSServer;
use strict;
use vars qw(@EXPORT @ISA @EXPORT_OK $VERSION);
require Exporter;

@EXPORT_OK = qw();
@EXPORT = @EXPORT_OK;
@ISA = qw(Exporter);

#------------------------------------------------------------------------
use ONMConfig;
use WSCommon;
use Crawler::Store;


#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Wbem
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

bless {
      _cfg =>$arg{'cfg'} || undef,
      _timeout =>$arg{'timeout'} || 2,
      _retries =>$arg{'retries'} || 2,
   }, $class;

}

#----------------------------------------------------------------------------
# cfg
#----------------------------------------------------------------------------
sub cfg {
my ($self,$cfg) = @_;
   if (defined $cfg) {
      $self->{_cfg}=$cfg;
   }
   else { return $self->{_cfg}; }
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
# retries
#----------------------------------------------------------------------------
sub retries {
my ($self,$retries) = @_;
   if (defined $retries) {
      $self->{_retries}=$retries;
   }
   else { return $self->{_retries}; }
}


#-----------------------------------------------------------------------
# create_store
#-----------------------------------------------------------------------
sub create_store {
my ($self)=@_;

   my $rcfg=conf_base($FILE_CONF);
   my $db_server=$rcfg->{'db_server'}->[0];
   my $db_name=$rcfg->{'db_name'}->[0];
   my $db_user=$rcfg->{'db_user'}->[0];
   my $db_pwd=$rcfg->{'db_pwd'}->[0];
	my $host=$rcfg->{'host_name'}->[0];
	my $store_path=$rcfg->{'store_path'}->[0];
   my $log_level = 'info';

   my $store=Crawler::Store->new(db_server=>$db_server,db_name=>$db_name,db_user=>$db_user,db_pwd=>$db_pwd,
                                 host=>$host, store_path=>$store_path, log_level=>$log_level);

   my $dbh=$store->open_db();
   $store->dbh($dbh);
   return $store;
}


#-----------------------------------------------------------------------
# test
#-----------------------------------------------------------------------
sub ws_check {
my ($self, $data)=@_;

   return "**ok** $data (Modulo=$self)";

}


#-----------------------------------------------------------------------
# store_device
#-----------------------------------------------------------------------
sub store_device {
my ($self, $data)=@_;


	my $store=$self->create_store();
	my $dbh=$store->dbh();

	my $id_dev=$store->store_device($dbh,$data);

	return $id_dev;

}


#-----------------------------------------------------------------------
# store_qactions
# Permite almacenar tareas de:
# 1. Generacion de metricas
#-----------------------------------------------------------------------
sub store_qactions {
my ($self, $data)=@_;

   my $store=$self->create_store();
   my $dbh=$store->dbh();

   $store->store_device($dbh,$data);

   return 1;

}


#-----------------------------------------------------------------------
# sync_data
#-----------------------------------------------------------------------
sub sync_data {
my ($self, $type, $table, $data)=@_;

   my $store=$self->create_store();
   my $dbh=$store->dbh();

   foreach (@$data) {
		my %item=();

		#------------------------------------------------------------------
		if ($type eq 'devices') {

			%item=('id_dev'=>$_->[0], 'name'=>$_->[1], 'domain'=>$_->[2], 'ip'=>$_->[3], 'sysloc'=>$_->[4], 'sysdesc'=>$_->[5], 'sysoid'=>$_->[6], 'type'=>$_->[7], 'app'=>$_->[8], 'status'=>$_->[9], 'mode'=>$_->[10], 'community'=>$_->[11], 'version'=>$_->[12], 'refresh'=>$_->[13], 'wbem_user'=>$_->[14], 'wbem_pwd'=>$_->[15], 'aping'=>$_->[16], 'aping_date'=>$_->[17], 'id_cfg_op'=>$_->[18], 'host_idx'=>$_->[19], 'background'=>$_->[20]);

		}

		#------------------------------------------------------------------
		elsif ($type eq 'metrics') {

			%item=('id_metric'=>$_->[0], 'name'=>$_->[1], 'id_dev'=>$_->[2], 'type'=>$_->[3],  'subtype'=>$_->[4], 'label'=>$_->[5], 'items'=>$_->[6], 'lapse'=>$_->[7], 'file_path'=>$_->[8], 'file'=>$_->[9], 'host'=>$_->[10], 'vlabel'=>$_->[11], 'graph'=>$_->[12], 'top_value'=>$_->[13], 'mtype'=>$_->[14], 'mode'=>$_->[15], 'module'=>$_->[16], 'status'=>$_->[17], 'crawler_idx'=>$_->[18], 'crawler_pid'=>$_->[19], 'watch'=>$_->[20], 'refresh'=>$_->[21], 'disk'=>$_->[22], 'c_label'=>$_->[23], 'c_items'=>$_->[24], 'c_vlabel'=>$_->[25], 'c_mtype'=>$_->[26], 'severity'=>$_->[27],  'size'=>$_->[28], 'host_idx'=>$_->[29], 'iid'=>$_->[30]);

		}

		$store->insert_to_db($dbh,$table,\%item);
   }

   #return 1;
	my $r=$store->lastcmd();
   return $r;

}



1;

