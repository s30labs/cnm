#----------------------------------------------------------------------------
use Crawler;
package Crawler::WSClient;
@ISA=qw(Crawler);
$VERSION='1.00';
use strict;
use SOAP::Lite;
use WSCommon;
#use Crawler::WSServer;

#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo Crawler::Wbem
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

   my $self=$class->SUPER::new(%arg);
   $self->{_cfg} = $arg{cfg} || '';
   $self->{_store} = $arg{store} || '';
   $self->{_timeout} = $arg{timeout} || 2;
   $self->{_retries} = $arg{retries} || 2;
   $self->{_mserver} = $arg{mserver} || [];	# master server
   $self->{_bserver} = $arg{bserver} || [];	# backup-master server
   $self->{_pserver} = $arg{pserver} || [];	# poll server

   return $self;
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
# store
#----------------------------------------------------------------------------
sub store {
my ($self,$store) = @_;
   if (defined $store) {
      $self->{_store}=$store;
   }
   else { return $self->{_store}; }
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

#----------------------------------------------------------------------------
# mserver
#----------------------------------------------------------------------------
sub mserver {
my ($self,$mserver) = @_;
   if (defined $mserver) {
      $self->{_mserver}=$mserver;
   }
   else { return $self->{_mserver}; }
}

#----------------------------------------------------------------------------
# bserver
#----------------------------------------------------------------------------
sub bserver {
my ($self,$bserver) = @_;
   if (defined $bserver) {
      $self->{_bserver}=$bserver;
   }
   else { return $self->{_bserver}; }
}

#----------------------------------------------------------------------------
# pserver
#----------------------------------------------------------------------------
sub pserver {
my ($self,$pserver) = @_;
   if (defined $pserver) {
      $self->{_pserver}=$pserver;
   }
   else { return $self->{_pserver}; }
}


#-----------------------------------------------------------------------
# get_target
#-----------------------------------------------------------------------
sub get_target {
my ($self, $params)=@_;

	my %t=();
	my $host=$self->host();
   my $host_idx=$params->{'host_idx'};

	# Son target todos los masters
	# Siempre salto el host local
	my $mserver = $self->mserver();
	foreach my $s (@$mserver) {
		my ($idx,$name)=split(/\:/,$s);
print "***$host***$name***\n";

		if ($host eq $name) { next; }	
		$t{$name}=1;
	}

	# Es target host_idx si esta en el grupo de pollers
	# OJO: Revisar el caso de multiples host_idx
   my $pserver = $self->pserver();
   foreach my $s (@$pserver) {
      my ($idx,$name)=split(/\:/,$s);
      if ($host eq $name) { next; }
      if ($host_idx ne $idx) { next; }
      $t{$name}=1;
   }

	my @tt=keys %t;
	return \@tt
}


#-----------------------------------------------------------------------
# ws_check
#-----------------------------------------------------------------------
sub ws_check {
my ($self, $data, $params)=@_;

   my $target=$params->{'target'};
	my $host=$self->host();
	my @results=();
   foreach my $server (@$target) {

		if ($server eq $host) { next; }
		eval {
			$self->log('debug',"ws_check::CLIENT DATA >> $data (SERVER=$server)");
	      my $call = SOAP::Lite 
					-> uri("http://$server/WSServer")
					-> proxy("http://$server/ws-bin/ws")
					-> ws_check($data);

			if ($call->fault) {
				my $errstr= join ', ', $call->faultcode, $call->faultstring, $call->faultdetail;
	         $self->err_str("ERROR=$errstr");
	         $self->err_num(1);
				$self->log('warning',"ws_check::[ERROR $errstr]");

			}
			else {
				my $r=$call->result;
				push @results, "$server : $r";
			}

	   };

   	if ($@) {
      	$self->err_str("ERROR=$@");
      	$self->err_num(10);
			$self->log('warning',"ws_check::[ERROR $@]");
   	}
		
   }
   return \@results;

}


#-----------------------------------------------------------------------
# store_device
# Solo se almacena en mserver (el resto se sincronizan) para evitar errores
# de id_dev y de host_idx
#-----------------------------------------------------------------------
sub store_device {
my ($self, $data, $params)=@_;


	my $host=$self->host();
   my $target = $self->mserver();
	my @results=();
   foreach my $s (@$target) {

      eval {
	      my ($idx,$server)=split(/\:/,$s);
#   	   if ($host eq $server) {
#      	   $self->log('debug',"store_device:: SALTO SERVER=$server");
#         	next;
#      	}

         $self->log('debug',"store_device::CLIENT DATA >> $data (SERVER=$server)");
         my $call = SOAP::Lite
               -> uri("http://$server/WSServer")
               -> proxy("http://$server/ws-bin/ws")
               -> store_device($data);

         if ($call->fault) {
            my $errstr= join ', ', $call->faultcode, $call->faultstring, $call->faultdetail;
            $self->err_str("ERROR=$errstr");
            $self->err_num(1);
            $self->log('warning',"store_device::[ERROR $errstr]");

         }
         else {
            my $r=$call->result;
            push @results, $r;
         }

      };

      if ($@) {
         $self->err_str("ERROR=$@");
         $self->err_num(10);
         $self->log('warning',"store_device::[ERROR $@]");
      }

   }

	# Si existen bservers, los sincronizo directamente
	my $bserver=$self->bserver();
	if (scalar @$bserver > 0) {
		foreach my $id_dev (@results) {
			$self->sync_data( {'target'=> $bserver, 'type'=>'devices',  'where'=>"id_dev=$id_dev",} );
		}
	}
   return \@results;

}


#-----------------------------------------------------------------------
# store_qactions
#-----------------------------------------------------------------------
sub store_qactions {
my ($self, $data, $params)=@_;


	my $target=$self->get_target($params);
	my @results=();
   foreach my $server (@$target) {

      eval {
         $self->log('debug',"store_qactions::CLIENT DATA >> $data (SERVER=$server)");
         my $call = SOAP::Lite
               -> uri("http://$server/WSServer")
               -> proxy("http://$server/ws-bin/ws")
               -> store_qactions($data);

         if ($call->fault) {
            my $errstr= join ', ', $call->faultcode, $call->faultstring, $call->faultdetail;
            $self->err_str("ERROR=$errstr");
            $self->err_num(1);
            $self->log('warning',"store_qactions::[ERROR $errstr]");

         }
         else {
            my $r=$call->result;
            push @results, "$server : $r";
         }

      };

      if ($@) {
         $self->err_str("ERROR=$@");
         $self->err_num(10);
         $self->log('warning',"store_qactions::[ERROR $@]");
      }
   }

   return \@results;

}


#-----------------------------------------------------------------------
# sync_data  (client -> server)
# $params >>>
#		host_idx
#		type
#		where
#-----------------------------------------------------------------------
sub sync_data {
my ($self, $params )=@_;


	my $type=$params->{'type'};
	my $where=$params->{'where'};

   if ( (! exists $WS_DATA_WHAT{$type}) || (! exists $WS_DATA_FROM{$type}) ){
      $self->log('warning',"sync_data::[WARN] No definida operativa para TYPE=$type");
      $self->err_num(1);
      $self->err_str("[WARN] No definida operativa para TYPE=$type",0);
      return undef;
   }

	my $store=$self->store();
	my $dbh=$self->dbh();
   my $data=$store->get_from_db($dbh, $WS_DATA_WHAT{$type}, $WS_DATA_FROM{$type}, $where);

#print ">>>> ".$store->lastcmd()."\n";

   if (!defined $data) {
      $self->log('warning',"sync_data::[WARN] Sin datos TYPE=$type COND=$where");
      $self->err_num(1);
      $self->err_str("sync_data::[WARN] Sin datos TYPE=$type COND=$where",0);
      return undef;
   }

   #my $target=$params->{'target'};
	my $target = $params->{'target'};
	my @results=();
   foreach my $server (@$target) {

#print ">>>> TYPE=$type FROM=$WS_DATA_FROM{$type} DATA=$data\n";
#foreach my $d (@$data) {  print $d->[1]."\n";  }
      eval {
         $self->log('debug',"sync_data::CLIENT DATA >> $data (SERVER=$server)");
         my $call = SOAP::Lite
               -> uri("http://$server/WSServer")
               -> proxy("http://$server/ws-bin/ws")
               -> sync_data($type, $WS_DATA_FROM{$type}, $data);

         if ($call->fault) {
            my $errstr= join ', ', $call->faultcode, $call->faultstring, $call->faultdetail;
            $self->err_str("ERROR=$errstr");
            $self->err_num(1);
            $self->log('warning',"sync_data::[ERROR $errstr]");

         }
         else {
            my $r=$call->result;
            push @results, "$server : $r";
         }
      };

      if ($@) {
         $self->err_str("ERROR=$@");
         $self->err_num(10);
         $self->log('warning',"sync_data::[ERROR $@]");
      }
   }

   return \@results;

}





1;

