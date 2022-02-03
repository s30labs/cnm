#----------------------------------------------------------------------------
package MQClient;
$VERSION='1.00';
use strict;
use Net::AMQP::RabbitMQ;
use JSON;
use Log::Log4perl qw(get_logger);
use Data::Dumper;


#----------------------------------------------------------------------------
# Funcion: Constructor
# Descripcion: Crea un objeto del tipo MQClient
#----------------------------------------------------------------------------
sub new {
my ($class,%arg) =@_;

	my $FILE_LOG_CONF = $arg{'log_config'} || '/opt/scripts/conf/log4perl.conf';
   Log::Log4perl->init($FILE_LOG_CONF);
   my $logger = get_logger($0);

bless {
      _cfg =>$arg{'cfg'} || undef,
      _timeout =>$arg{'timeout'} || 2,
      _log_config =>$arg{'log_config'} || '/opt/scripts/conf/log4perl.conf',
		_queue_config =>$arg{'queue_config'} || '/opt/scripts/conf/qdescriptor.json',
      _logger =>$logger,
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
# log_config
#----------------------------------------------------------------------------
sub log_config {
my ($self,$log_config) = @_;
   if (defined $log_config) {
      $self->{_log_config}=$log_config;
   }
   else { return $self->{_log_config}; }
}

#----------------------------------------------------------------------------
# queue_config
#----------------------------------------------------------------------------
sub queue_config {
my ($self,$queue_config) = @_;
   if (defined $queue_config) {
      $self->{_queue_config}=$queue_config;
   }
   else { return $self->{_queue_config}; }
}

#----------------------------------------------------------------------------
# logger
#----------------------------------------------------------------------------
sub logger {
my ($self,$logger) = @_;
   if (defined $logger) {
      $self->{_logger}=$logger;
   }
   else { return $self->{_logger}; }
}

#------------------------------------------------
#my %MSG = (
#   'class' => 'event',
#   'type' => 'trap',
#   'subtype' => '',
#   'label' => 'RX TRAP',
#   'params' => {}
#);

#-------------------------------------------------------------------------------------------
# queue_descriptor
#-------------------------------------------------------------------------------------------
# Input params
# GET >> $qidx Clave del hash de QDESCRIPTOR
#-------------------------------------------------------------------------------------------
sub queue_descriptor {
my ($self,$qidx) = @_;

   my $logger = $self->logger();
	
   my $file_json = $self->queue_config();
   if (! -f $file_json) {
  		$logger->info("queue_descriptor::Sin acceso a $file_json");
      return {};
   }
   my $rc = open my $fh, '<', $file_json;
   if (! $rc) {
      $logger->info("queue_descriptor::Error al abrir $file_json");
      return {};
   }
   local $/ = undef;
   my $data = <$fh>;
   close $fh;

   my $json=JSON->new();
   my $qdesc = $json->decode($data);

   my $q = (exists $qdesc->{$qidx}) ? $qdesc->{$qidx} : {};
   return $q;

}


#-------------------------------------------------------------------------------------------
# amq_put
#-------------------------------------------------------------------------------------------
# Input paramas
# $queue -> Descriptor de la cola
# $msg -> Hash con el mensaje
#-------------------------------------------------------------------------------------------
sub amq_put {
my ($self,$queue,$msg) = @_;

   my $logger = $self->logger();

   my $MQ_HOST=$queue->{'host'};
   my $MQ_USER=$queue->{'user'};
   my $MQ_PWD=$queue->{'pwd'};

   my $channel = $queue->{'channel'};
   my $exchange = $queue->{'exchange'};
   my $routing_key = $queue->{'routing_key'};
   my $queuename = $queue->{'queuename'};

   my $exchange_type = $queue->{'exchange_type'} || 'direct';
   my $passive = $queue->{'passive'} || 0;
   my $durable = $queue->{'durable'} || 0;
   my $auto_delete = $queue->{'auto_delete'} || 0;


   my $json=JSON->new();
   my $txmsg = $json->encode($msg);
  	$logger->info("amq_put::txmsg=$txmsg");


   my $mq = Net::AMQP::RabbitMQ->new();
   $mq->connect($MQ_HOST, { user=>$MQ_USER, password=>$MQ_PWD});
   $mq->channel_open($channel);

   my %exchange_options = (exchange_type => $exchange_type, passive => $passive, durable => $durable, auto_delete => $auto_delete);
   $mq->exchange_declare($channel,$exchange,\%exchange_options,{});
   $mq->queue_declare($channel,$queuename);
   $mq->queue_bind($channel, $queuename, $exchange, $routing_key, {});
   $mq->publish($channel,$routing_key,$txmsg,{exchange=>$exchange});

   $mq->disconnect();

}




#-------------------------------------------------------------------------------------------
# amq_recv_loop
#-------------------------------------------------------------------------------------------
# Input paramas
# $queue -> Descriptor de la cola
#-------------------------------------------------------------------------------------------
sub amq_recv_loop {
my ($self,$queue,$handler) = @_;

   my $logger = $self->logger();

   my $MQ_HOST=$queue->{'host'};
   my $MQ_USER=$queue->{'user'};
   my $MQ_PWD=$queue->{'pwd'};

   my $channel = $queue->{'channel'};
   my $exchange = $queue->{'exchange'};
   my $routing_key = $queue->{'routing_key'};
   my $queuename = $queue->{'queuename'};

   my $exchange_type = $queue->{'exchange_type'} || 'direct';
   my $passive = $queue->{'passive'} || 0;
   my $durable = $queue->{'durable'} || 0;
   my $auto_delete = $queue->{'auto_delete'} || 0;

   my $mq = Net::AMQP::RabbitMQ->new();
   $mq->connect($MQ_HOST, { user=>$MQ_USER, password=>$MQ_PWD});
   $mq->channel_open($channel);
   my %exchange_options = (exchange_type => $exchange_type, passive => $passive, durable => $durable, auto_delete => $auto_delete);

   #$mq->exchange_declare($channel,$exchange,\%exchange_options,{});
   #$mq->queue_declare($channel,$queuename);
   #$mq->queue_bind($channel, $queuename, $exchange, $routing_key);

   # Request that messages be sent and receive them until interrupted
   $mq->consume($channel, $queuename);

   while (my $message = $mq->recv(0)) {
     $logger->info("amq_recv_loop:: rx msg >> $message");
     #print Dumper($message);
     $handler->($message->{'body'});
   }

   $mq->disconnect();

}


1;
